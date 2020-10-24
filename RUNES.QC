/*=======================================================//
// runes.QC - CustomTF 3.2.OfN			   - 28/9/2004 - //
// by Sergio FumaÒa Grunwaldt - OfteN [cp]				 //
=========================================================//
 This file contains all the runes-specific code
---------------------------------------------------------//
 Runes are randomly scattered on map start if the server 
 has enabled it with the info key named "runes".
 The possible choices for this setting are:
 0 = no runes, 1 to 4 a single player can hold upto this
 number of runes simultaneously, for himself.
 I recommend a setting of 1 or 2 for ovbious reasons! :)
 ________________________________________________________

 Every rune gives to the player that owns it a special
 efficiency increase, each rune in a different area.
 There are ALWAYS 4 runes anytime:

  1.- Triad Rune		   (like quad but does x3 damage)
  2.- Resist Rune	(protects from damage and bad states)
  3.- Speed Rune (faster shoting + player speed increase)
  4.- Regen Rune	  (regenerates health/armor and ammo)

 --------------------------------------------------------
 The effects of any rune are accumulated with other items 
 or ability the player already has, like Quad, Auras etc.
 --------------------------------------------------------

 The Resist Rune cuts incoming damage for player that
 holds it, and also protects from judo, infection and
 most affections a player usually is vulnerable to.

 The Speed Rune increases player movement speed and acts
 as the aura of haste too (making player shot faster).
 It also cuts down reload times a bit.

 The Regen Rune refills health and armor at a greater 
 rate than the regeneration aura, and it also refills
 all basic ammo's (shells, nails, rockets and cells).

=========================================================*/

// Rune type flags - DO NOT MODIFY

/* Defined in ofndefs.qc
#define RUNE_TRIAD	1
#define RUNE_RESIS	2
#define RUNE_SPEED	4
#define RUNE_REGEN	8
*/

// Rune state possible values

//#define RUNESTATE_SPAWN		0 // Default, just spawned
#define RUNESTATE_READY 	  1 // Everything assumed to be right
#define RUNESTATE_WRONG 	  2 // Invalid rune, need to respawn
#define RUNESTATE_RESPAWN	  3 // Although probably a correct rune, need to respawn
#define RUNESTATE_DROPED	  4 // Just droped by a player, we should check stuff

// Miscellaneous settings for runes

#define RUNES_DROPDISABLE_TIME	 4 // Seconds for a player to not be able to pick up a rune after droping it
#define RUNES_DECLAREDEAD_TIME	10 // Minutes to pass until a rune is considered unreachable and respawns
#define RUNESPOT_ATTEMPTS	   250 // Attempts for GetRuneSpot to do before failing
#define COLOURED_RUNEFLASH		   // If defined rune's flash will get a purple color (on gl clients only)

// Regeneration rune settings

#define REGENRUNE_RATE			 0.5
#define REGENRUNE_NADE_RATE      15   // only currently used in Neo mode
#define REGENRUNE_DET_RATE       60   // only currently used in Neo mode
#define REGENRUNE_HP_AMMOUNT	 2.25
#define REGENRUNE_ARMOR_AMMOUNT  2.25
#define REGENRUNE_AMMO_AMMOUNT	 1

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

For a rune entity:
------------------

.has_sentry 	- Kind of rune
.enemy			- Last person that droped this rune
.pain_finished	- Time at which this rune has been droped the last time
.tfstate		- Status of rune, see the rune state defines
.ltime			- Indicates the time this rune was spawned at

For the player entity:
----------------------

.#runes   - Indicates what runes the player is carrying, if 0 then none 
			(field used defined on ofndefs.qc, currently we use a dedicated field called runes_owned) 

================================================================================================*/

// Function declarations

void() StartRunes;
void() EndRunes;
void(float oldrunes) UpdateRuneStuff;
entity(float runetype) SpawnRune;
void(float runetype) SpawnNewRune;
float(entity player) GetPlayerNoRunes;
void(entity player, entity rune) PlayerTakesRune;
void(entity player) PlayerDropRunes;
vector() GetRuneSpot;
float(vector spot) CheckRuneSpot;
void(entity player, float runetype) ReportRuneTaken;
void(entity player, float runetype) ReportRuneDrop;
void(entity rune) RuneDisappear;
void(entity rune) RuneAppear;
string(float runetype) GetRuneString;
void(entity player, float runetype, float throw) PlayerDropsRune;
void(entity player, float runetype) RuneEndEffects;
void(entity player, float runetype) RuneStartEffects;
void(entity player) SpawnRegenRuneTimer;
void(entity player) RemoveRegenRuneTimer;
void(entity rune) InvalidateRune;
float(entity rune) RuneOnSky;
void(entity rune, float nice) RespawnRune;

//==================================================
// Rune models get precacheed in this function

void() PrecacheRuneModels =
{
	precache_model("progs/end1.mdl");
	precache_model("progs/end2.mdl");
	precache_model("progs/end3.mdl");
	precache_model("progs/end4.mdl");
};

//==============================================================================
// Retrieves server setting about runes

void() GetRunesGlobal =
{
	local string st;

	// Get rune setting for map, if any
	st = infokey(world,"runes");

	if (st != "")
	{
		runes = floor(stof(st)); // we use the custom setting..

		// Cap minimum/maximum's
		if (runes < 0)
			runes = 0;

		if (runes > 4)
			runes = 4;		  
	}
};

//===============================================================================
// Applies any changes on the rune setting

void(float oldrunes) UpdateRuneStuff =
{
	if (oldrunes == 0 && runes != 0)
		StartRunes(); // We should start the party
	else if (oldrunes != 0 && runes == 0)
		EndRunes(); // We must close the store

	// TODO: Make players drop runes if needed after a runes setting change to less runes per player
};

//=========================================================================
// Spawns the 4 runes and places them randomly on the map

void() StartRunes =
{
	if (runes == 0) return;

	// Spawn our 4 runes from scratch
	SpawnNewRune(#RUNE_TRIAD);
	SpawnNewRune(#RUNE_RESIS);
	SpawnNewRune(#RUNE_SPEED);
	SpawnNewRune(#RUNE_REGEN);

	// Notify to everybody!
	bprint(#PRINT_HIGH,"Environmentç Ancient Runes located around the zone!\n");
};

//=========================================================================
// Deletes the runes including any runes affecting players (not entities)

void() EndRunes =
{
	local entity te;
	local float tmp;

	// Find and remove any rune entities
	te = find(world,classname,"rune");

	while (te)
	{
		// Make it disappear nicely
		RuneDisappear(te);

		te = find(te,classname,"rune");
	}

	// Find and remove any wrong rune entities
	te = find(world,classname,"runewrong");

	while (te)
	{
		// Remove it like anything, this entity is not even visible
		dremove(te);

		te = find(te,classname,"runewrong");
	}

	// Remove any runes "carried" by the players
	te = find(world,classname,"player");

	while (te)
	{
		if (te.is_connected)
		{					
			if (te.#runes != 0)
			{				 
				if (!neo) // modded for Neo mode
				{
					if (GetPlayerNoRunes(te) > 1)
						sprint(te,#PRINT_HIGH,"Your runes have lost their power.\n");
					else
						sprint(te,#PRINT_HIGH,"You have lost the power of your rune.\n");
				}

				stuffcmd(te,"bf\nplay items/itembk2.wav\n");
				tmp = te.#runes;
				te.#runes = 0;
				RuneEndEffects(te,tmp);
			}
		}

		te = find(te,classname,"player");
	}

	// Notify to everybody the party is over!
	if (!neo) // modded for Neo mode
		bprint(#PRINT_HIGH,"Environmentç Ancient Runes don't exist anymore!\n");
};

//===========================================================================
// Returns a random valid point inside level to spawn a rune on

vector() GetRuneSpot =
{
	local vector retvec;
	local float num;

	num = #RUNESPOT_ATTEMPTS;

	while (num > 0)
	{
		retvec_x = (random() * 8192) - 4096;
		retvec_y = (random() * 8192) - 4096;
		retvec_z = (random() * 8192) - 4096;

		if (CheckRuneSpot(retvec))
			return retvec;
		
		num = num - 1;
	}
	
	// Return an always-invalid vector to identify the fail of this function
	return '4096 4096 4096';
};

//========================================================================================
// Returns TRUE if the origin is a valid place for a rune (no solid, sky, slime or lava)

float(vector spot) CheckRuneSpot =
{
	local float content;

	// This gonna be fun to do
	content = pointcontents(spot);
	if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)    
	{
		content = pointcontents(spot + '-16 -16 -24');
		if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
		{
			content = pointcontents(spot + '16 16 32');
			if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
			{
				content = pointcontents(spot + '-16 16 32');
				if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
				{
					content = pointcontents(spot + '16 -16 32');
					if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
					{
						content = pointcontents(spot + '16 16 -24');
						if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
						{
							content = pointcontents(spot + '16 -16 -24');
							if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
							{
								content = pointcontents(spot + '-16 16 -24');
								if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
								{
									content = pointcontents(spot + '-16 -16 32');
									if (content == #CONTENT_EMPTY || content == #CONTENT_WATER)
										return #TRUE; // ok, spot *seems* fine (not 100% sure)
								}
							}
						}
					}
				}
			}
		}
	}

	// Spot isn't a valid place for a rune
	return #FALSE;
};

//=====================================================================================
// Checks if the rune has landed on sky (seriously.. may happen)

float(entity rune) RuneOnSky =
{
	if (pointcontents(rune.origin - '0 0 24.1') == #CONTENT_SKY)
		return #TRUE;
	
	return #FALSE;
};

//=====================================================================================
// Main think routine for runes, does visual/sound stuff, checks for any needed respawn

void() Rune_think =
{
	// Check if we need to relocate/respawn this rune
	if (self.tfstate == #RUNESTATE_WRONG) // Invalid rune?
	{
		// Respawn a new one of same kind
		RespawnRune(self, #FALSE);
		return;
	}
	else if (self.tfstate == #RUNESTATE_RESPAWN) // Unreachable rune?
	{
		// Reallocate another rune of same kind
		RespawnRune(self, #TRUE);		 
		return;
	}
	// also check if this has been droped and got into a valid location or not
	else if (self.tfstate == #RUNESTATE_DROPED)
	{
		if (!CheckRuneSpot(self.origin)) // Invalid current position?
		{
			// Reallocate another rune of same kind
			RespawnRune(self, #TRUE);
			return;
		}		
		
		// If the last check was done with the rune already on ground we can stop checking
		if (self.flags & #FL_ONGROUND)
		{
			if (RuneOnSky(self)) // Landed on sky? lol
			{
				// Replace the rune elsewhere
				RespawnRune(self, #TRUE);
				return;
			}

			// Everything seems fine then, apparently we have been dropped well..
			self.tfstate = #RUNESTATE_READY; // so reset state
		}			 
	}

	// Check if we should declare this rune in dead/unreachable spot to respawn it
	if (time > (self.ltime + (#RUNES_DECLAREDEAD_TIME * 60)))
		self.tfstate = #RUNESTATE_RESPAWN;
	
	// If on ground, do a little hop with light, sprite and sound, for players to be able to notice this rune easily
	if (self.flags & #FL_ONGROUND)
	{
		// Make it hop a little
		self.velocity_z = 190 + crandom()*50;

		// Make it do a magic sound
		sound(self,#CHAN_BODY,"player/slimbrn2.wav",1,#ATTN_NORM);

		// Spawn a magic sprite..
		local entity te;

		// (the kind of sprite depends on content this rune is on)
		if (pointcontents(self.origin) ==  #CONTENT_EMPTY)
			te = SpawnSprite(1,#SPRITE_AIRBURST,self.origin + '0 0 40','0 0 0',#SPRITEMOVE_UPSLOW,0.1);
		else
			te = SpawnSprite(1,#SPRITE_ABLAST,self.origin + '0 0 40','0 0 0',#SPRITEMOVE_UPSLOW,0.2);

		//..and lit it		  
		#ifdef COLOURED_RUNEFLASH
		te.effects = #EF_DIMLIGHT | #EF_PURPLE;
		#else
		te.effects = #EF_DIMLIGHT;
		#endif
		
		// flash the rune also
		MuzzleFlash(self);		  
	}

	// Set next think time
	self.nextthink = time + 3 + random()*7;
};

//======================================================================
// Touch function for runes, checks if able to be picked up

void() Rune_touch =
{
	if (!ceasefire && !intermission_running) // not allowed during ceasefire or intermission
	if (prematch < time) // Only if not in prematch
	if (other.classname == "player")
	if (other.is_connected)
	if (other.health > 0) // alive?
	if (!(other.done_custom & #CUSTOM_BUILDING)) // skip ppl customizing
	if (other.playerclass != #PC_UNDEFINED) // skip observers
	if (other.penance_time < time) // Don't let lame teamkillers take runes
	{
		// First of all check if too early for this person to take it again
		if (self.enemy == other)
		if ((time - self.pain_finished) < #RUNES_DROPDISABLE_TIME)
			return; // too early still, dont take it

		// Then check if allowed to take another rune
		local float numrunes;		 
		numrunes = GetPlayerNoRunes(other);

		// Does this player should take another one?
		if ((numrunes + 1) > runes)
			return; // nope.. so just ignore touch

		// Ok, he/she picks it up!
		PlayerTakesRune(other, self);
	}
};

//====================================================================
// Spawns and sets the basic stuff on a rune entity

entity(float runetype) SpawnRune =
{
	local entity rune;
	rune = world;

	// Spawn a new entity for it
	rune = spawn();

	// This is the safest entity spawn ever on a quakeworld mod! :-)
	if (rune)
	{
		// Critical entity settings
		#ifndef IDABLE_RUNES
		rune.flags = #FL_ITEM;
		#else
		rune.flags = #FL_ITEM | #FL_FINDABLE_NONSOLID;
		#endif
		rune.classname = "rune";	
		rune.movetype = #MOVETYPE_TOSS;
		rune.solid = #SOLID_TRIGGER;	
		rune.takedamage = #DAMAGE_NO;
		rune.owner = world;  
		
		// Choose the correspoding model
		if (runetype == #RUNE_TRIAD)
			rune.mdl = "progs/end1.mdl";
		else if (runetype == #RUNE_RESIS)
			rune.mdl = "progs/end2.mdl";
		else if (runetype == #RUNE_SPEED)
			rune.mdl = "progs/end3.mdl";
		else if (runetype == #RUNE_REGEN)
			rune.mdl = "progs/end4.mdl";
		else
		{
			RPrint("BUG: Unknown rune type on SpawnRune()!\n");
			dremove(rune);
			return;
		}

		// Assign model
		setmodel(rune,rune.mdl);

		// Use standard item size
		setsize (rune, '-16 -16 -24', '16 16 32');
		
		// Indicate which kind of rune this one is
		rune.has_sentry = runetype;

		// Assign description to it
		rune.netname = GetRuneString(runetype);

		// Set its main subroutines
		rune.think = Rune_think;
		rune.touch = Rune_touch;

		// First "rune-hop" or think
		rune.nextthink = time + 6 + random()*6;

		// Set our "spawned at" time flag
		rune.ltime = time;
	}

	// Return a pointer to our rune
	return rune;
};

//=========================================================================
// Creates from scratch a rune of the specified kind and places it

void(float runetype) SpawnNewRune =
{
	local entity rune, oself;

	// Spawn our new rune
	rune = SpawnRune(runetype);

	// Check for error doing it
	if (!rune)
	{
		RPrint("BUG: Unable to create entity on SpawnNewRune()!\n");
		return;
	}

	// Initialize with neutral values, our pointer and time for disable time after drop
	rune.enemy = world;
	rune.pain_finished = time;

	// Get a valid random start origin on the map
	rune.origin = GetRuneSpot(); 

	// Check if success getting the random point
	if (rune.origin == '4096 4096 4096') // nope?
	{
		InvalidateRune(rune); // another one will spawn and appear elsewhere
		return; // do nothing else
	}
	
	// And set it
	setorigin(rune,rune.origin);

	// Adjust it on ground and set ready flag if everything seems ok
	oself = self;
	self = rune;

	if (!droptofloor()) // didn't land?
		InvalidateRune(self); // another one will spawn and appear elsewhere
	else
	{
		// Do a content check on our final position
		if (CheckRuneSpot(self.origin))
		{		 
			// Landed on sky? lol
			if (RuneOnSky(self))
				InvalidateRune(self); // another one will spawn and appear elsewhere
			else
			{
				// Ok, everything seems correct, flag rune as valid and perform appearing effects
				self.tfstate = #RUNESTATE_READY;
				if (!neo) // modified for Neo mode
					RuneAppear(self);
			}
		}
		else // invalid location?
			InvalidateRune(self); // another rune will spawn and appear elsewhere
	}

	self = oself;
};

//============================================================================
// Removes inapropiate stuff from a wrong rune, and prepares it for respawn

void(entity rune) InvalidateRune =
{
	// Flag it as wrong rune, which will make next think to respawn it
	rune.tfstate = #RUNESTATE_WRONG;

	// Make it invisible
	rune.modelindex = modelindex_null;

	// Stop it, and make it not trigger anything
	rune.classname = "runewrong";
	rune.movetype = #MOVETYPE_NONE;
	rune.velocity = '0 0 0';
	rune.solid = #SOLID_NOT;

	// Remove touch function
	rune.touch = SUB_Null;

	// IMPORTANT: Do not RESET or CHANGE the think function of this entity, it's NEEDED FOR IT TO RESPAWN
};

//============================================================================
// A player is taking a rune (already checked if possible on rune touch)

void(entity player, entity rune) PlayerTakesRune =
{
	// Check for error first
	if (player.#runes & rune.has_sentry) // Already has it? wtf..
	{
		RPrint("BUG: Player double picking up a rune!\n");
		return;
	}
	
	// Update our C+quakeC field for rune indication flag which will
	// update client status bar rune items also (done on C)
	player.#runes = player.#runes | rune.has_sentry;

	// Make rune sound as it's picked up
	sound (player, #CHAN_ITEM, "auras/aura3b.wav", 1, #ATTN_NORM);

	// Flash player screen
	stuffcmd(player,"bf;bf\n");

	// Flash player entity
	MuzzleFlash(player);

	// Report the rune has been taken by this bastard
	if (!neo) // modded for Neo mode
		ReportRuneTaken(player,rune.has_sentry);

	// Starts any rune effects needed on player
	RuneStartEffects(player,rune.has_sentry);

	// Remove rune entity
	dremove(rune);	  
};

//===============================================================================
// A player drops a rune, spawn entity and set its velocity

void(entity player, float runetype, float throw) PlayerDropsRune =
{
	// Check for error first
	if (!(player.#runes & runetype)) // Doesn't have it? wtf..
	{
		RPrint("BUG: Player dropping a buggy rune!\n");
		return;
	}

	// Remove our rune type flag and update client runes in status bar items (done by server code)
	player.#runes = player.#runes - runetype;

	// Spawn rune entity and launch it away
	local entity rune;
	rune = SpawnRune(runetype);
	
	if (rune)
	{
		rune.origin = player.origin;
		setorigin(rune,rune.origin);

		if (throw) // Use player aiming, as we have thrown this rune on purpose
		{
			makevectors(player.v_angle);
			rune.velocity = player.velocity + v_forward * 256 + '0 0 340';			  
		}
		else // Thrown not on purpose, so in a random direction, mainly above player
		{
			rune.velocity_z = 320+random()*30; 
			rune.velocity_x = crandom()*60;
			rune.velocity_y = crandom()*60; 	   

			// Add player velocity for extra realism :P
			rune.velocity = rune.velocity + player.velocity;
		}

		// Set last drop pointer and time, that avoids picking it up repeatedly by same player
		rune.enemy = player;
		rune.pain_finished = time;

		// Flag this rune as a droped one, which will make the think sub to check for valid position
		rune.tfstate = #RUNESTATE_DROPED;
	}
	else
		RPrint("BUG: Unable to spawn rune entity on PlayerDropsRune()!\n");
	
	// Report this rune drop
	ReportRuneDrop(player,runetype);

	// End rune effects on player if needed
	RuneEndEffects(player,runetype);
};

//================================================================================
// Called whenever a player is unable to keep his runes (dies, quits game etc..)

void(entity player) PlayerDropRunes =
{
	if (player.#runes == 0) return; // no runes to drop
	
	// Perform "drop" of any runes if needed
	if (player.#runes & #RUNE_TRIAD)
		PlayerDropsRune(player,#RUNE_TRIAD,#FALSE);
	
	if (player.#runes & #RUNE_RESIS)
		PlayerDropsRune(player,#RUNE_RESIS,#FALSE);
	
	if (player.#runes & #RUNE_SPEED)
		PlayerDropsRune(player,#RUNE_SPEED,#FALSE);
	
	if (player.#runes & #RUNE_REGEN)
		PlayerDropsRune(player,#RUNE_REGEN,#FALSE);
	
	// Reset our rune indicator to 0 for safety
	player.#runes = 0;
};

//==============================================================================
// Gets number of runes a player is carrying

float(entity player) GetPlayerNoRunes =
{
	local float numrunes;
	numrunes = 0;

	if (player.#runes & #RUNE_TRIAD)
		numrunes = numrunes + 1;
	if (player.#runes & #RUNE_RESIS)
		numrunes = numrunes + 1;
	if (player.#runes & #RUNE_SPEED)
		numrunes = numrunes + 1;
	if (player.#runes & #RUNE_REGEN)
		numrunes = numrunes + 1;

	return numrunes;
};

//====================================================================
// Gets the string describing a rune

string(float runetype) GetRuneString =
{
	if (runetype == #RUNE_TRIAD)
		return "‘ÚÈ·‰ “ıÓÂ";
	if (runetype == #RUNE_RESIS)
		return "“ÂÛÈÛÙ “ıÓÂ";
	if (runetype == #RUNE_SPEED)
		return "”ÂÂ‰ “ıÓÂ";
	if (runetype == #RUNE_REGEN)
		return "“ÂÁÂÓ “ıÓÂ";

	return "ERROR!";
};

//==================================================================
// Prints any messages needed when a rune is taken

void(entity player, float runetype) ReportRuneTaken =
{
	local string st, st2;
	local float rnum;
	rnum = random();
	st = GetRuneString(runetype);

	if (rnum < 0.2)
		st2 = " got";
	else if (rnum < 0.4)
		st2 = " has";
	else if (rnum < 0.6)
		st2 = " took";
	else if (rnum < 0.8)
		st2 = " gets";
	else
		st2 = " takes";

	bprint(#PRINT_MEDIUM,player.netname,st2," the ",st,"!\n");

	sprint(player,#PRINT_HIGH,"The ",st," is now yours!\n");
};

//=================================================================
// Prints any messages needed when a rune is droped

void(entity player, float runetype) ReportRuneDrop =
{
	local string st;
	st = GetRuneString(runetype);
	bprint(#PRINT_MEDIUM,player.netname," dropped the ",st,"\n");

	sprint(player,#PRINT_HIGH,"You drop the ",st,".\n");
};

//=================================================================
// Does visual/sound effects and removes the rune

void(entity rune) RuneDisappear =
{
	spawnFOG(rune.origin);
	SpawnSprite(1,#SPRITE_ABLAST,rune.origin,'0 0 0',#SPRITEMOVE_UPSLOW,0.1);
	sound(rune,#CHAN_BODY,"items/itembk2.wav",1,#ATTN_NORM);
	dremove(rune);
};

//=================================================================
// Does visual/sound effects stuff when a rune appears

void(entity rune) RuneAppear =
{
	spawnFOG(rune.origin);
	MuzzleFlash(rune);
	sound(rune,#CHAN_BODY,"items/itembk2.wav",1,#ATTN_NORM);
};

//================================================================================
// Drops the specified rune number (1-4, not bitfield) from a player if possible

float(entity player, float runenum) DropSpecificRune =
{
	runenum = floor(runenum);

	if (runenum < 1 || runenum > 4)
		return #FALSE;

	if (runenum == 1)
	{
		if (player.#runes & #RUNE_TRIAD)
		{
			PlayerDropsRune(player,#RUNE_TRIAD,#TRUE);
			return #TRUE;
		}

		return #FALSE;
	}
	else if (runenum == 2)
	{
		if (player.#runes & #RUNE_RESIS)
		{
			PlayerDropsRune(player,#RUNE_RESIS,#TRUE);
			return #TRUE;
		}

		return #FALSE;
	}
	else if (runenum == 3)
	{
		if (player.#runes & #RUNE_SPEED)
		{
			PlayerDropsRune(player,#RUNE_SPEED,#TRUE);
			return #TRUE;
		}

		return #FALSE;
	}
	else if (runenum == 4)
	{
		if (player.#runes & #RUNE_REGEN)
		{
			PlayerDropsRune(player,#RUNE_REGEN,#TRUE);
			return #TRUE;
		}

		return #FALSE;
	}

	return #FALSE;
};

//=============================================================
// Used to start any stuff needed by a rune/s on player

void(entity player, float runetype) RuneStartEffects =
{
	// NOTE: For resist and triad runes, no action is needed

	if (runetype & #RUNE_SPEED)
	{
		// Update player speed
		TeamFortress_SetSpeed(player);
	}
	
	if (runetype & #RUNE_REGEN)
	{
		// Spawn regen timer
		SpawnRegenRuneTimer(player);
	}
};

//=============================================================
// Cleans up the effect of a rune/s on a player 

void(entity player, float runetype) RuneEndEffects =
{
	// NOTE: For resist and triad runes, no action is needed

	if (runetype & #RUNE_SPEED)
	{
		// Update player speed
		TeamFortress_SetSpeed(player);
	}
	
	if (runetype & #RUNE_REGEN)
	{
		// Remove regen timer
		RemoveRegenRuneTimer(player);
	}
};

//===============================================================
// Regen Rune timer main think

void() RegenRuneTimer_think =
{
	if (!self.owner.is_connected || self.owner.classname != "player" || !(self.owner.#runes & #RUNE_REGEN))
	{
		dremove(self);
		return;
	}	 

	if (self.owner.is_abouttodie || self.owner.health <= 0)
	{
		dremove(self);
		return;
	}

	// begin Neo mod
	// calculate regen multiplier for Neo mode scaling
	local float neoFactor; neoFactor = 1;
	if (neo) neoFactor = neoRegenFactor;

	// Regenerate health
	if (self.owner.health < self.owner.max_health) // Check
	{
		if (self.owner.health + (#REGENRUNE_HP_AMMOUNT * neoFactor) > self.owner.max_health)
			self.owner.health = self.owner.max_health;
		else
			self.owner.health = self.owner.health + (#REGENRUNE_HP_AMMOUNT * neoFactor);
	}
	
	// Regenerate armor, but only if any left
		// I don't understand the point of this. I'm making it always regen armor in Neo mode. -PZ
	if (self.owner.armorvalue > 0 || neo)
	{
		if (self.owner.armorvalue + (#REGENRUNE_ARMOR_AMMOUNT * neoFactor) > self.owner.maxarmor)
			self.owner.armorvalue = self.owner.maxarmor;
		else
			self.owner.armorvalue = self.owner.armorvalue + (#REGENRUNE_ARMOR_AMMOUNT * neoFactor);
	}

	// Regenerate all the ammo
	if (self.owner.ammo_shells + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > self.owner.maxammo_shells)
		self.owner.ammo_shells = self.owner.maxammo_shells;
	else
		self.owner.ammo_shells = self.owner.ammo_shells + (#REGENRUNE_AMMO_AMMOUNT * neoFactor);

	if (self.owner.ammo_nails + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > self.owner.maxammo_nails)
		self.owner.ammo_nails = self.owner.maxammo_nails;
	else
		self.owner.ammo_nails = self.owner.ammo_nails + (#REGENRUNE_AMMO_AMMOUNT * neoFactor);
	
	if (self.owner.ammo_rockets + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > self.owner.maxammo_rockets)
		self.owner.ammo_rockets = self.owner.maxammo_rockets;
	else
		self.owner.ammo_rockets = self.owner.ammo_rockets + (#REGENRUNE_AMMO_AMMOUNT * neoFactor);
	
	if (self.owner.ammo_cells + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > self.owner.maxammo_cells)
		self.owner.ammo_cells = self.owner.maxammo_cells;
	else
		self.owner.ammo_cells = self.owner.ammo_cells + (#REGENRUNE_AMMO_AMMOUNT * neoFactor);

	// Neo Mode:
	// Neo can't pick up resupply packs. So, we're going to allow him to regen grenades and detpacks.
	if (neo)
	{
		local float maxAmmo, increase;

		// Grenades
		if (lastNadeRegen + (#REGENRUNE_NADE_RATE / neoFactor) <= time)
		{
			lastNadeRegen = time;
			if (self.owner.tp_grenades_1 != #GR_TYPE_NONE)
			{
				maxAmmo = GetMaxGrens(self.owner, 1);
				if (self.owner.no_grenades_1 + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > maxAmmo)
					self.owner.no_grenades_1 = maxAmmo;
				else
				{
					increase = #REGENRUNE_AMMO_AMMOUNT * neoFactor;
					if (increase < 1) increase = 1;
					else increase = floor(increase);
					self.owner.no_grenades_1 = self.owner.no_grenades_1 + increase;
				}
			}
			if (self.owner.tp_grenades_2 != #GR_TYPE_NONE)
			{
				maxAmmo = GetMaxGrens(self.owner, 2);
				if (self.owner.no_grenades_2 + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > maxAmmo)
					self.owner.no_grenades_2 = maxAmmo;
				else
				{
					increase = #REGENRUNE_AMMO_AMMOUNT * neoFactor;
					if (increase < 1) increase = 1;
					else increase = floor(increase);
					self.owner.no_grenades_2 = self.owner.no_grenades_2 + increase;
				}
			}
		}
		// Detpacks
		if (lastDetRegen + (#REGENRUNE_DET_RATE / neoFactor) <= time)
		{
			lastDetRegen = time;
			if (self.owner.cutf_items & #CUTF_DETPACK)
			{
				maxAmmo = self.owner.maxammo_detpack;
				if (self.owner.ammo_detpack + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > maxAmmo)
					self.owner.ammo_detpack = maxAmmo;
				else
				{
					increase = #REGENRUNE_AMMO_AMMOUNT * neoFactor;
					if (increase < 1) increase = 1;
					else increase = floor(increase);
					self.owner.ammo_detpack = self.owner.ammo_detpack + increase;
				}
			}
			if (self.owner.cutf_items & #CUTF_TOSSABLEDET)
			{
				maxAmmo = self.owner.maxammo_detpack;
				if (self.owner.ammo_c4det + (#REGENRUNE_AMMO_AMMOUNT * neoFactor) > maxAmmo)
					self.owner.ammo_c4det = maxAmmo;
				else
				{
					increase = #REGENRUNE_AMMO_AMMOUNT * neoFactor;
					if (increase < 1) increase = 1;
					else increase = floor(increase);
					self.owner.ammo_c4det = self.owner.ammo_c4det + increase;
				}
			}
		}
	}

	// Update current ammo if needed
	if (self.owner.items & #IT_SHELLS)
		self.owner.currentammo = self.owner.ammo_shells;
	else if (self.owner.items & #IT_NAILS)
		self.owner.currentammo = self.owner.ammo_nails;
	else if (self.owner.items & #IT_ROCKETS)
		self.owner.currentammo = self.owner.ammo_rockets;
	else if (self.owner.items & #IT_CELLS)
		self.owner.currentammo = self.owner.ammo_cells;    
	else if (self.owner.current_weapon == #WEAP_SPANNER)
		self.owner.currentammo = self.owner.ammo_cells;

	// Cya soon!
	self.nextthink = time + (#REGENRUNE_RATE / neoFactor);
	// end Neo mod
};

//==============================================================
// Clean up any regen rune timer for player

void(entity player) RemoveRegenRuneTimer =
{
	// Find any regen rune timers for this player..
	local entity te;

	te = find(world,classname,"regenrune_timer");

	while (te)
	{
		// .. and remove them if ours
		if (te.owner == player)
			dremove(te);

		te = find(te,classname,"regenrune_timer");
	}
};

//===============================================================
// Spawns a new regen rune timer for a player

void(entity player) SpawnRegenRuneTimer =
{
	local entity regenrune_timer;

	regenrune_timer = spawn();
	regenrune_timer.owner = player;
	regenrune_timer.classname = "regenrune_timer";
	regenrune_timer.think = RegenRuneTimer_think;	 
	regenrune_timer.nextthink = time + #REGENRUNE_RATE;
};

//==========================================================================================
// Respawns a rune elsewhere, doing nice effects for the rune that disappears if specified

void(entity rune, float nice) RespawnRune =
{
	// Create a new rune of same kind elsewhere
	SpawnNewRune(rune.has_sentry);
	
	// Should we do any effect for the disappearing rune?
	if (nice)
		RuneDisappear(rune); // Disappear nicely and remove entity
	else
		dremove(rune); // Just remove the rune entity
};
