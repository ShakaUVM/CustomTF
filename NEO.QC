// NEO.QC									   ver. January 29, 2009
// Author: Pulseczar
//
// Votable Neo Mode
// Based on idea by =STG=Gnarler and [cp]Snake.

// Everyone is on the Smith team, except Neo; he's by himself. Neo
// alternates from player to player, such that the first player
// to get a kill (starts in deathmatch mode) becomes Neo, and from
// there on, every time a player kills Neo, the player becomes Neo.
// Neo has the equivalent property of having all CustomTF runes at
// once (triple damage, damage resistance, regeneration, faster
// firing, and increased movement speed), though Neo's powers vary
// according to the number of players in the server. However, the
// speed rune does not scale according to the number of players.
//
// There are no flags in Neo mode. The sole objective is to be Neo
// as much as you can and keep others from being Neo.
// 
// Using the 'inv' command will tell you what Neo's enhancement 
// stats are, which change according to the number of players.
//
// Other rules:
// > Neo can't use thief skill.
// > Neo can't hide from other players. Doors and teleporters are
//	 open to all players.
// > If Neo kills himself or the environment kills him, he becomes
//	 a Smith and the first player to kill another player becomes
//	 Neo.
// > Neo can't use resupply packs. Grenades and detpacks have been
//   made to slowly regenerate along with the usual regeneration.
 
// I tried to fit everything I could into this file. The things
// that could not go here can be found by searching for 'Neo'.

// This code uses the already-existing rune code by Often. Further,
// runes cannot be added by admins to a game of Neo, because,
// currently, adding runes will not work right with Neo mode.

// Thanks to Major Major Major Major for most of the event messages.

/*
to do:
- how about making bots out of grunts to play with in Neo mode?
  - rip navigation code from Reaper bot or something?
- give multiple frags for killing Neo?
- verify that teleporters work right (let everyone pass through)
- check that when armor reaches 0 and regen adds more to it, that
  the armor actually works and isn't disabled by something when it
  hits 0
*/

#ifdef OMGWTFBBQ
//=================================================================
// globals defined in defs.qc
//=================================================================

// cvars - requires 'localinfo' to set these
float neo;				// global cvar, just on or off (requires 'localinfo neo 1' to be on)
float neo_base_dmg; 	// Neo's damage factor when there's 0 people in the game
float neo_dmg_factor;	// how much damage factor increases with each player past playercount of 0
float neo_base_res; 	// Neo's resistance factor when there's 0 people in the game
float neo_res_factor;	// how much resistance factor increases with each player past playercount of 0
float neo_base_regen;	// Neo's regeneration factor when there's 0 people in the game
float neo_regen_factor; // how much regeneration factor increases with each player past playercount of 0

// globals
entity neoLives;		 // is there currently a Neo? if so, who?
float oldTeamplayValue;  // used in teamplay mode changing
float lastNadeRegen;     // last time Neo had a grenade regenerated
float lastDetRegen;      // last time Neo had a detpack (tossable or not) regenerated
float neoDamageFactor;   // final damage factor (sorry about name redundancy)
float neoResistFactor;   // final resist factor
float neoRegenFactor;    // final regen factor

// definitions
#define WHOA_LIKELINESS 0.25 // how likely Neo is to say 'Whoa..'; set between 0 and 1
							 // not a 'true' percentage; look at how it's used
#endif

#define CUTF_URL customtf.net/forum/

//=================================================================
// called by the localinfo key initializing function
//=================================================================
void() Neo_initialize =
{
	local string st;

	st = infokey(world, "neo");
	if (st == string_null) st = "0"; // sets default
	neo = stof(st);
	if (neo != 1) neo = 0; // has to be set to 1 to engage Neo mode

	if (neo)
	{
		// basically just makes sure friendly-fire is on 
		// and team half damage and such is off
		oldTeamplayValue = cvar("teamplay");
		cvar_set("teamplay", "1");

		st = infokey(world, "neo_base_dmg");
		if (st == string_null) st = "1"; // sets default
		neo_base_dmg = stof(st);

		st = infokey(world, "neo_dmg_factor");
		if (st == string_null) st = "0.5"; // sets default
		neo_dmg_factor = stof(st);

		st = infokey(world, "neo_base_res");
		if (st == string_null) st = "0.8"; // sets default
		neo_base_res = stof(st);

		// currently not being used in resist calculation
		st = infokey(world, "neo_res_factor");
		if (st == string_null) st = "0.016"; // sets default
		neo_res_factor = stof(st);

		st = infokey(world, "neo_base_regen");
		if (st == string_null) st = "0.4"; // sets default
		neo_base_regen = stof(st);

		st = infokey(world, "neo_regen_factor");
		if (st == string_null) st = "0.15"; // sets default
		neo_regen_factor = stof(st);
	}
};
//=================================================================
// alerts joining players of Neo mode being active
//=================================================================
void() Neo_introducePlayer =
{
	sprint(self, #PRINT_HIGH, " ŒÂÔ ÕÔ‰Â Enabled \n");
	//DELETE this once out of 'test period'
	local string temp; 
	temp = colstr("This is a TEST version.\nPlease report bugs to #CUTF_URL.\n", #COLSTR_RED);
	sprint(self, #PRINT_HIGH, temp);
	//DELETE end
	sprint(self, #PRINT_HIGH, "Welcome to the Matrix, Agent Smith.\n");
	if (neoLives)
	{
		sprint(self, #PRINT_HIGH, neoLives.netname);
		sprint(self, #PRINT_HIGH, " is currently Neo.\n");
		sprint(self, #PRINT_HIGH, "Find and destroy him! (look for gibs amongst a blue haze)\n");
	}
	else
		sprint(self, #PRINT_HIGH, "First player to kill another player becomes Neo.\n");

	sprint(self, #PRINT_HIGH, "\n");
	stuffcmd(self, "play boss1/sight1.wav\n");
};
//=================================================================
// calculates global Neo factor values (for scaling Neo's power
// according to number of players)
//=================================================================
void() Neo_calcNeoFactors =
{
	local float playerCount; 
	playerCount = GetNoPlayers(#TRUE, #TRUE);

	/**************************
	  calculate damage factor
	**************************/
	neoDamageFactor = neo_base_dmg + (playerCount * neo_dmg_factor);

	/******************************
	  calculate resistance factor
	  - simplified: neo_base_res * (1 - (playerCount / 32))
	******************************/
	neoResistFactor = 1 - (playerCount / 32);
	neoResistFactor = neo_base_res * neoResistFactor; 
	if (neoResistFactor < 0.05)
		neoResistFactor = 0.05; // make sure he never ends up impossible to kill because of Resist

	/********************************
	  calculate regeneration factor
	  - simplified: neo_base_regen + (playerCount * neo_regen_factor)
	********************************/
	neoRegenFactor = playerCount * (neo_regen_factor * 1000);
	neoRegenFactor = (neo_base_regen * 1000) + neoRegenFactor; 
	neoRegenFactor = neoRegenFactor / 1000;
	// doing all the multiplying and dividing by 1000 because the server will
	// round the float values, otherwise
};
//=================================================================
// called in obits every time a player dies; handles death events
//=================================================================
void(entity targ, entity attacker) Neo_deathThink =
{
	if (!neo) return;

	local float rnum, playerCount;
	local entity oldSelf;
	local entity realAttacker;

	playerCount = GetNoPlayers(#FALSE, #FALSE);
	rnum = random();

	/*
	there's no Neo 
	*/

	if (!neoLives && targ.classname == "player")
	{
		// something killed a Smith
		if (attacker.classname == "player" && attacker != targ)
		{
			// a Smith killed a Smith; make killer Neo
			realAttacker = attacker;
		}
		else if ((attacker.flags & #FL_MACHINE || attacker.flags & #FL_MONSTER)
				 && attacker.real_owner != targ)
		{
			// a Smith's object killed a Smith; make the object's owner Neo
			realAttacker = attacker.real_owner;
		}
		else 
			return; // keep it from executing the following

		bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
		if		(rnum < 0.333)
		{
			bprint(#PRINT_HIGH, realAttacker.netname); bprint(#PRINT_HIGH, " knows kung fu!\n");
		}
		else if (rnum < 0.666)
		{
			bprint(#PRINT_HIGH, realAttacker.netname); bprint(#PRINT_HIGH, " frees his mind!\n");
		}
		else // rnum >= 0.666
		{
			bprint(#PRINT_HIGH, realAttacker.netname); 
			bprint(#PRINT_HIGH, " learns that there is no spoon!\n");
		}
		bprint(#PRINT_HIGH, realAttacker.netname); bprint(#PRINT_HIGH, " becomes Neo.\n");
		bprint(#PRINT_HIGH, "\n");
		oldSelf = self;
		Neo_assignNeo(realAttacker);
		self = oldSelf;
		BroadcastSound("boss1/sight1.wav");
		rnum = random();
		if (rnum < (1 / playerCount) * #WHOA_LIKELINESS)
			stuffcmd(realAttacker, "say Whoa..\n");
		return;
	}

	/*
	Neo exists 
	*/

	if (neoLives)
	{
		// Neo was killed
		if (targ == neoLives)
		{
			// a player killed Neo
			if (attacker.classname == "player")
			{
				// Neo killed himself; make him a Smith
				if (attacker == targ)
				{
					Neo_removeNeo(attacker);
					bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
					bprint(#PRINT_HIGH, "Neo ("); bprint(#PRINT_HIGH, attacker.netname); 
					bprint(#PRINT_HIGH, ") learns that the body cannot live\nwithout the mind.");
					bprint(#PRINT_HIGH, " Kill someone to become Neo!\n");
					bprint(#PRINT_HIGH, "\n");
					BroadcastSound("boss1/sight1.wav");
					Neo_centerPrint();
					return;
				}
				// a Smith killed Neo; make the Smith Neo
				else
				{
					bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
					if (rnum < 0.5)
					{
						bprint(#PRINT_HIGH, targ.netname); bprint(#PRINT_HIGH, " has been deleted.\n");
					}
					else
					{
						bprint(#PRINT_HIGH, "Bullet-time was not slow enough for Neo ("); 
						bprint(#PRINT_HIGH, targ.netname); bprint(#PRINT_HIGH, ").\n");
					}
					bprint(#PRINT_HIGH, attacker.netname); bprint(#PRINT_HIGH, " is... THE ONE!\n");
					bprint(#PRINT_HIGH, "\n");
					oldSelf = self;
					Neo_assignNeo(attacker);
					self = oldSelf;
					BroadcastSound("boss1/sight1.wav");
					rnum = random();
					if (rnum < (1 / playerCount) * #WHOA_LIKELINESS)
						stuffcmd(attacker, "say Whoa..\n");
					return;
				}
			}

			// Neo was killed by an engineer building
			else if (attacker.classname == "building_sentrygun" ||
					 attacker.classname == "building_tesla" ||
					 attacker.classname == "building_fieldgen" ||
					 attacker.classname == "force_field" || 	// not sure if this is necessary
					 attacker.classname == "building_dispenser")
			{
				// Neo's own building killed him; make Neo a Smith
				if (attacker.real_owner == targ)
				{
					Neo_removeNeo(targ);
					bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
					bprint(#PRINT_HIGH, "Neo ("); bprint(#PRINT_HIGH, targ.netname); 
					bprint(#PRINT_HIGH, ") was killed by his own devices!\n");
					bprint(#PRINT_HIGH, "Kill someone to become Neo!\n");
					bprint(#PRINT_HIGH, "\n");
					BroadcastSound("boss1/sight1.wav");
					Neo_centerPrint();
					return;
				}
				// a Smith's building killed Neo; make the Smith Neo
				else
				{
					Neo_removeNeo(targ);
					bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
					bprint(#PRINT_HIGH, "Neo ("); bprint(#PRINT_HIGH, targ.netname); 
					bprint(#PRINT_HIGH, ") was killed by "); bprint(#PRINT_HIGH, attacker.real_owner.netname);
					bprint(#PRINT_HIGH, "'s building!\n");
					bprint(#PRINT_HIGH, attacker.real_owner.netname); bprint(#PRINT_HIGH, " becomes Neo!\n");
					bprint(#PRINT_HIGH, "\n");
					oldSelf = self;
					Neo_assignNeo(attacker.real_owner);
					self = oldSelf;
					BroadcastSound("boss1/sight1.wav");
					rnum = random();
					if (rnum < (1 / playerCount) * #WHOA_LIKELINESS)
						stuffcmd(attacker.real_owner, "say Whoa..\n");
					return;
				}
			}

			// Neo was killed by a summon
			else if (attacker.classname == "monster_wizard" ||
					 attacker.classname == "monster_fish" ||
					 attacker.classname == "monster_demon1" ||
					 attacker.classname == "monster_gremlin" ||
					 attacker.classname == "monster_shambler" ||
					 attacker.classname == "monster_army")
			{
				// Neo's own summon killed him; make Neo a Smith
				if (attacker.real_owner == targ)
				{
					Neo_removeNeo(targ);
					bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
					bprint(#PRINT_HIGH, "Neo ("); bprint(#PRINT_HIGH, targ.netname); 
					bprint(#PRINT_HIGH, ") was killed by his own creature!\n");
					bprint(#PRINT_HIGH, "Kill someone to become Neo!\n");
					bprint(#PRINT_HIGH, "\n");
					BroadcastSound("boss1/sight1.wav");
					Neo_centerPrint();
					return;
				}
				// a Smith's summon killed Neo; make the Smith Neo
				else
				{
					Neo_removeNeo(targ);
					bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
					bprint(#PRINT_HIGH, "Neo ("); bprint(#PRINT_HIGH, targ.netname); 
					bprint(#PRINT_HIGH, ") was killed by "); bprint(#PRINT_HIGH, attacker.real_owner.netname);
					bprint(#PRINT_HIGH, "'s summon!\n");
					bprint(#PRINT_HIGH, attacker.real_owner.netname); bprint(#PRINT_HIGH, " becomes Neo!\n");
					bprint(#PRINT_HIGH, "\n");
					oldSelf = self;
					Neo_assignNeo(attacker.real_owner);
					self = oldSelf;
					BroadcastSound("boss1/sight1.wav");
					rnum = random();
					if (rnum < (1 / playerCount) * #WHOA_LIKELINESS)
						stuffcmd(attacker.real_owner, "say Whoa..\n");
					return;
				}
			}

			// Neo was killed by the environment; make Neo a Smith
			else if (attacker.classname != "player")
			{
				Neo_removeNeo(targ);
				bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
				if (rnum < 0.5)
				{
					bprint(#PRINT_HIGH, "Neo ("); bprint(#PRINT_HIGH, targ.netname); 
					bprint(#PRINT_HIGH, ") went too far down the rabbit hole...\n");
				}
				else // rnum >= 0.5
				{
					bprint(#PRINT_HIGH, "Neo ("); bprint(#PRINT_HIGH, targ.netname); 
					bprint(#PRINT_HIGH, ") proves that you should never send a human to do a machine's job...\n");
				}
				bprint(#PRINT_HIGH, "No one is Neo. Kill someone to become Neo!\n");
				bprint(#PRINT_HIGH, "\n");
				BroadcastSound("boss1/sight1.wav");
				Neo_centerPrint();
				return;
			}
		}
		// Neo killed a Smith
		else if (attacker == neoLives && targ != neoLives && !Neo_teammate(attacker, targ))
		{
			// just randomly cause Neo to say "Whoa.."
			rnum = random();
			if (rnum < (1 / playerCount) * #WHOA_LIKELINESS)
				stuffcmd(attacker, "say Whoa..\n");
		}
	}
};
//=================================================================
// makes player [attacker] Neo; if there's currently a player with
// Neo status, this function will remove Neo status from that
// player
//=================================================================
void(entity attacker) Neo_assignNeo =
{
	// if a player is already Neo, remove Neo from that player
	if (neoLives) Neo_removeNeo(neoLives);

	// if player is dead when they become Neo, don't give them Neo status (no one will be Neo)
	if (attacker.health <= 0 || attacker.deadflag != #DEAD_NO || attacker.penance_time > time
		|| !attacker.is_connected)
	{
		bprint(#PRINT_HIGH, "\n ŒÂÔ ÕÔ‰Â \n");
		bprint(#PRINT_HIGH, "Unfortunately, Neo ("); bprint(#PRINT_HIGH, attacker.netname); 
		bprint(#PRINT_HIGH, ") was dead,\nor just not available. Kill someone to become Neo!\n");
		bprint(#PRINT_HIGH, "\n");
		Neo_centerPrint();
		return;
	}

	// unthief [attacker] if he's thieving
	if (attacker.job & #JOB_THIEF && (attacker.job & #JOB_ACTIVE || attacker.job & #JOB_FULL_HIDE))
		RevealThief(attacker, #FALSE);

	neoLives = attacker;
	local string temp; temp = ftos(oldTeamplayValue);
	cvar_set("teamplay", temp); // return the server to its 'actual' teamplay setting

	// centerprint "YOU ARE NEO!"
	temp =              "\n";
	temp = strcat(temp, " Ÿœ’ ¡“≈ Œ≈œ° \n");
	temp = strcat(temp, "\n");
	CenterPrint(attacker, temp);

	// put attacker on blue team alone
	self = attacker;
	self.admin_kick = attacker;
	Admin_Assign(1);
	Neo_possessionsChangeTeam(attacker, 1);

	// give attacker (Neo) all the CuTF runes
	SpawnNewRune(#RUNE_TRIAD); SpawnNewRune(#RUNE_RESIS);
	SpawnNewRune(#RUNE_SPEED); SpawnNewRune(#RUNE_REGEN);

	local entity rune;
	rune = find(world, classname, "rune");
	while (rune)
	{
		PlayerTakesRune(attacker, rune);
		rune = find(rune, classname, "rune");
	}
	rune = find(world, classname, "runewrong");
	while (rune)
	{
		PlayerTakesRune(attacker, rune);
		rune = find(rune, classname, "runewrong");
	}
	attacker.effects = attacker.effects | (#EF_BLUE | #EF_BRIGHTLIGHT);
};
//=================================================================
// removes Neo status from [player]
//=================================================================
void(entity player) Neo_removeNeo =
{
	// put player back on Smith team (team 2)
	neoLives = world;
	cvar_set("teamplay", "1"); // make sure settings are right for 'deathmatch'

	local entity oldSelf;
	oldSelf = self;
	self = player;
	self.admin_kick = player;
	Admin_Assign(2);
	self = oldSelf;
	Neo_possessionsChangeTeam(player, 2);

	// remove player's runes
	EndRunes();
	player.effects = player.effects - (player.effects & (#EF_BRIGHTLIGHT | #EF_BLUE));
};
//=================================================================
// find [player]'s possessions, and change the team of their 
// possessions to [teamNumber]
//=================================================================
void(entity player, float teamNumber) Neo_possessionsChangeTeam =
{
	local entity ent;

	// buildings
	ent = nextent(world);
	while (ent)
	{
		if (ent.flags & #FL_MACHINE) // is it a building?
		if (ent.real_owner == player) // is it owned by [player]?
		{
			ent.team_no = teamNumber;
			if (teamNumber == 1)
			{
				if (ent.classname == "building_sentrygun")
					ent.skin = 0;
				else
					ent.skin = 1;
			}
			else
				ent.skin = 3;
		}
		ent = nextent(ent);
	}

	// summons
	if (player.job & #JOB_WARLOCK)
	{
		local float i; i = 0;
		while (i < 3)
		{
			ent = GetSummon(player, i);
			if (ent)
			{
				ent.team_no = teamNumber;
				if (teamNumber == 1)
					ent.effects = ent.effects | (#EF_BRIGHTLIGHT | #EF_BLUE);
				else
					ent.effects = ent.effects - (ent.effects & (#EF_BRIGHTLIGHT | #EF_BLUE));
			}
			i = i + 1;
		}
	}

	// army grunts
	else if (player.job & #JOB_ARMY)
	{
		ent = find(world, classname, "monster_army");
		while (ent)
		{
			if (ent.real_owner == player)
			{
				ent.team_no = teamNumber;
				if (teamNumber == 1)
					ent.skin = 0;
				else
					ent.skin = 3;
			}
			ent = find(ent, classname, "monster_army");
		}
	}

	// mines
	else if (player.job & #JOB_GUERILLA)
	{
		ent = find(world, netname, "land_mine");
		while (ent)
		{
			if (ent.real_owner == player)
				ent.team_no = teamNumber;
			ent = find(ent, netname, "land_mine");
		}
	}

	// holograms (not sure this is necessary)
	if (player.cutf_items & #CUTF_HOLO)
	{
		ent = find(world, classname, "holo");
		while (ent)
		{
			if (ent.real_owner == player)
				ent.team_no = teamNumber;
			ent = find(ent, classname, "holo");
		}
	}
};
//=================================================================
// tests whether [a] and [b] are teammates (for Neo mode only)
//=================================================================
float(entity a, entity b) Neo_teammate =
{
	if (!neo)
		return #TRUE;

	if (a == b) return #TRUE;

	// basically act normal if there's a Neo
	if (neoLives)
	{
		if (a.team_no == b.team_no) return #TRUE;
		else return #FALSE;
	}
	
	// no one is a teammate when there's no Neo, except objects and their owners
	else
	{
		if (a.classname == "player" && b.classname == "player")
		{
			return #FALSE;
		}
		else if (a.classname == "player" && b.classname != "player")
		{
			// if b's owner is a, return true.. else return false
			{
				if (b.real_owner == a) return #TRUE;
				else return #FALSE;
			}
		}
		else if (a.classname != "player" && b.classname == "player")
		{
			// if a's owner is b, return true.. else return false
			{
				if (a.real_owner == b) return #TRUE;
				else return #FALSE;
			}
		}
		else if (a.classname != "player" && b.classname != "player")
		{
			// whatever it is.. if it has the same owner, it's on same team
			if (a.real_owner == b.real_owner) return #TRUE;
			else return #FALSE;
		}
	}

	bprint(#PRINT_HIGH, "Error: Neo_teammate() had no answer\n");
	return #FALSE;
};
//=================================================================
// prints Neo's stats when 'inv' command is invoked
//=================================================================
void() Neo_invPrint =
{
	local float integer, fraction; 
	local string temp;

	sprint(self, #PRINT_HIGH, "\nŒÂÔßÛ ÛÙ·ÙÛ: ");
	// damage
	sprint(self, #PRINT_HIGH, "damage: x");
	integer = floor(neoDamageFactor); fraction = neoDamageFactor - integer; fraction = fraction * 10;
	fraction = floor(fraction); temp = ftos(integer); temp = colstr(temp, #COLSTR_NUMBER);
	sprint(self, #PRINT_HIGH, temp); sprint(self, #PRINT_HIGH, "."); temp = ftos(fraction);
	temp = colstr(temp, #COLSTR_NUMBER); sprint(self, #PRINT_HIGH, temp);
	// resistance
	sprint(self, #PRINT_HIGH, ", resist: /");
	integer = floor(neoResistFactor); fraction = neoResistFactor - integer; fraction = fraction * 1000;
		// invert it, for people to read it more easily
		neoResistFactor = 1000 / fraction; integer = floor(neoResistFactor); fraction = neoResistFactor - integer; 
		fraction = fraction * 100; fraction = floor(fraction);
	temp = ftos(integer); temp = colstr(temp, #COLSTR_NUMBER); sprint(self, #PRINT_HIGH, temp);
	sprint(self, #PRINT_HIGH, "."); temp = ftos(fraction); 
	temp = colstr(temp, #COLSTR_NUMBER); sprint(self, #PRINT_HIGH, temp);
	// regeneration
	sprint(self, #PRINT_HIGH, ", regen: x");
	integer = floor(neoRegenFactor); fraction = neoRegenFactor - integer;
	fraction = fraction * 100; fraction = floor(fraction); 
	temp = ftos(integer); temp = colstr(temp, #COLSTR_NUMBER); sprint(self, #PRINT_HIGH, temp);
	sprint(self, #PRINT_HIGH, "."); temp = ftos(fraction); 
	temp = colstr(temp, #COLSTR_NUMBER); sprint(self, #PRINT_HIGH, temp);
	// firing rate

	// movement speed

};
//=================================================================
// when there's no Neo, this function is used to centerprint the 
// message to everyone, "THERE'S NO NEO! KILL SOMEONE TO BE NEO!"
//=================================================================
void() Neo_centerPrint =
{
	local entity player;
	local string temp;

	temp =              "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
	temp = strcat(temp, "\n");
	temp = strcat(temp, "     ‘»≈“≈‡” Œœ Œ≈œ°     \n");
	temp = strcat(temp, " À…ÃÃ ”œÕ≈œŒ≈ ‘œ ¬≈ Œ≈œ° \n");
	temp = strcat(temp, "\n");

	player = find(world, classname, "player");
	while (player)
	{
		CenterPrint(player, temp);
		player = find(player, classname, "player");
	}
};

#define NEO_ERROR_MESSAGE "Neo Mode error detected!\nPlease report bugs to #CUTF_URL.\n"

//=================================================================
// general error checking; broadcasts error messages to all players
// if error is detected; called every frame in StartFrame()
//=================================================================
void() Neo_errorCheck =
{
	// TODO: devise a better system that doesn't spam messages to players

	local float f_1;

	if (neoLives)
	{
		// Neo should always have all four runes
		f_1 = GetPlayerNoRunes(neoLives);
		if (f_1 != 4)
		{
			bprint(#PRINT_HIGH, #NEO_ERROR_MESSAGE);
			bprint(#PRINT_HIGH, "Error: Neo does not have all 4 runes.\n");
		}
	}
};
