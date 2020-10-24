/*=======================================================//
// field.QC - CustomTF 3.2.OfN			   - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN [cp]				 //
=========================================================//
 Field generator stuff - Written all by myself! :)
 I took the model and some sounds from deadlode mod
 One sound is from megaTF
=========================================================*/

// field generator status flags, DO NOT MODIFY

#define FIELDGEN_ISOFF		0 // no field, not linked, and its not trying to link (several possible reasons)
#define FIELDGEN_ISIDLE 	1 // no field, not linked, trying to link with other generator
#define FIELDGEN_ISDISABLED 2 // no field, linked, its disabled temporary (teammate passing thru field)
#define FIELDGEN_ISENABLED	3 // field, linked, and cells enough, waiting for shock, only hum sound
#define FIELDGEN_ISWORKING	4 // field, linked, glowing and all the field visual/sound effects are on

// field generator settings

#define FIELDGEN_WORKTIME		3	// seconds the generators remain "working", glowing and doing lightning after a shock
#define FIELDGEN_WORKING_RATE	1	// interval in seconds for fieldgens to use cells
#define FIELDGEN_LINKTIME		3.5 // seconds between tries to link with other generator (only visual)
#define FIELDGEN_TIMEDISABLED	1.5 // time fieldgens remain disabled
#define FIELDGEN_CELLSCOST		2	// cells cost for each "FIELDGEN_ISWORKING" pass

// force field settings

#define FIELD_DMG				250//160 //was 80 - normal damag when touching
#define FIELD_DMGINSIDE 		500//420 //was 120 - damage when trapped inside field
#define FIELD_SOUNDSRATE		1	// Rate in seconds at which hum/shield sound is played
#define FIELD_VISUALFACTOR		0.5 // 1 = always generate lightning for visuals, when working. 0 = never

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

For field generator entity:
---------------------------

.has_holo		 - Holds current status of every field generator, FIELDGEN_ISXXXX determines
.has_sensor 	 - Boolean value, determines if field generator is currently supporting a force field
.martyr_enemy	 - This points to the force field, if none its always 'world'
.no_grenades_1	 - Controls delay between tries to link (only affects sound/flash, it tries to link every frame)
.no_grenades_2	 - Controls delay for field to go up again after beeing disabled
.tp_grenades_1	 - Controls delay of the WORKING status
.has_teleporter  - Used to flash generators when field is activated
.has_camera 	 - Controls delay between cells take
.has_tesla		 - Boolean, forced status.

For force field entity:
-----------------------

.demon_one		- Points to the first field generator
.demon_two		- Points to the 2nd generator
.has_holo		- Hum sound running, boolean
.has_sensor 	- Shield sound running, boolean
.has_tesla		- Controls delay between hums
.has_sentry 	- Controls delay between shield sounds
.cnt			- Orientation of field (x or y)
.dmg			- Next damage the field will do
.has_camera 	- Used to control the rate at which the field touch sound/visual effects are done (4hz)

================================================================================================*/

void() CheckDistance;
entity(entity fieldgen) Find_OtherGen;
float(entity fieldgen1, entity fieldgen2) FieldGens_CanLink;
float(entity fieldgen) FieldGen_CanIdle;
float(entity fieldgen) IsValidFieldGen;
float (vector targ, vector check) vis2orig;
float(entity field) IsValidField;
void(entity tfield, entity gen1) Field_UpdateSounds;
void(entity tfield) Field_StopSounds;
void(entity tfield) Field_MakeVisual;
float(entity tfield) FieldIsImproved;
float(entity tfield) FieldIsMalfunctioning;
void() Field_touch;
void() Field_touch_SUB;
float(entity e1, entity e2) EntsTouching2;
void(entity tfield, vector where, entity thing) FieldExplosion;
void(entity field) PutFieldWork;
float(entity tfield, entity who) Field_ItCanPass;
float(entity tfield, entity who) Field_ShouldDamage;

#ifdef FIELD_FORCEMODE
entity(entity myself) GetMyFieldGen;
float(entity tfield) Field_GetForcedStatus;
void(float value) SetFieldForcedStatus; // player function (self = player) cuts disabled time also
float() GetFieldForcedStatus; // player
#endif

//=========================================================================================
// field generator model and sounds

void() Field_Precache =
{
	precache_sound ("misc/null.wav");
	precache_sound2("misc/ffhum.wav");
	precache_sound2("misc/ffbeep.wav");
	precache_sound2("misc/ffield.wav");
	precache_sound2("misc/ffact.wav");
	precache_sound2("misc/fffail.wav");
	precache_model2("progs/ffgen2.mdl");
};

//==================================================================================================
// checks for field generators and removes itself if needed, checks for stuck entities inside field 

void() Field_think =
{
	/* NOT NEEDED - if (self.classname != "force_field")
	{
		RPrint("BUG: Not a force field entity was in 'FieldThink()'!\n");
		return;
	}*/ 

	self.has_camera = #FALSE; // resets flag for visuals

	// check field generators, removal of this field if needed... (for safety only)
	if (!IsValidFieldGen(self.demon_one) || !IsValidFieldGen(self.demon_two))
	{
		if (IsValidFieldGen(self.demon_one))
		{
			self.demon_one.has_sensor = #FALSE;
			self.demon_one.martyr_enemy = world;
		}

		if (IsValidFieldGen(self.demon_two))
		{
			self.demon_two.has_sensor = #FALSE;
			self.demon_two.martyr_enemy = world;
		}

		self.demon_one = world;
		self.demon_two = world;
		
		dremove(self);

		// report this, as it shouldnt happen
		RPrint("Debug: Field entity removed in Field_think()\n"); 
		return;
	}
	else
		self.nextthink = time + 0.25; // 4hz rate

	// Make visuals if needed
	if (self.demon_one.has_holo == #FIELDGEN_ISWORKING)
		Field_MakeVisual(self); 	   
   
	// checks for anything stuck in field :)
	local entity te;
	local float frange;

	frange = #FIELDGEN_RANGE;

	if (FieldIsImproved(self) & #IMPROVED_FOUR)
	{
		frange = #FIELDGEN_HACKEDRANGE; // at least 1 hacked for range

		if (self.demon_one.all_active & #IMPROVED_FOUR && self.demon_two.all_active & #IMPROVED_FOUR)
			frange = #FIELDGEN_HACKEDRANGE2; // both field generators hacked
	}

	te = findradius(self.origin,frange);
	while (te)
	{
		if (te != self)
		if (te != self.demon_one)
		if (te != self.demon_two)
		if (te.velocity == '0 0 0')
		if (te.classname != "force_field")
		if (EntsTouching2(te,self))
		{
			other = te;
			deathmsg = #DMSG_STUCK_FORCEFIELD; 
			self.dmg = #FIELD_DMGINSIDE; // this gonna hurt
			Field_touch_SUB();
		}

		te = te.chain;
	}
};

//=============================================================================================
// is one entity actually intersecting the other one? (this avoids using a stupid trigger)

float(entity e1, entity e2) EntsTouching2 =
{
	if (e1.absmin_x > e2.absmax_x)
		return #FALSE;
	if (e1.absmin_y > e2.absmax_y)
		return #FALSE;
	if (e1.absmin_z > e2.absmax_z)
		return #FALSE;

	if (e1.absmax_x < e2.absmin_x)
		return #FALSE;
	if (e1.absmax_y < e2.absmin_y)
		return #FALSE;
	if (e1.absmax_z < e2.absmin_z)
		return #FALSE;

	return #TRUE;
};

//=================================================================================
// these 2 functions return the current hacks that should apply to the field

float(entity tfield) FieldIsImproved =
{
	if (IsValidFieldGen(tfield.demon_one) && IsValidFieldGen(tfield.demon_two))
		return tfield.demon_one.all_active | tfield.demon_two.all_active;

	if (IsValidFieldGen(tfield.demon_one))
		return tfield.demon_one.all_active;

	if (IsValidFieldGen(tfield.demon_two))
		return tfield.demon_two.all_active;

	return 0;
};

float(entity tfield) FieldIsMalfunctioning =
{
	if (IsValidFieldGen(tfield.demon_one) && IsValidFieldGen(tfield.demon_two))
		return tfield.demon_one.is_malfunctioning | tfield.demon_two.is_malfunctioning;

	if (IsValidFieldGen(tfield.demon_one))
		return tfield.demon_one.is_malfunctioning;

	if (IsValidFieldGen(tfield.demon_two))
		return tfield.demon_two.is_malfunctioning;

	return 0;
};

//=================================================================
// disables force field

void(entity tfield, float timedisable) DisableField =
{
	if (IsValidFieldGen(tfield.demon_one))
	{
		tfield.demon_one.has_holo = #FIELDGEN_ISDISABLED;
		
		if (tfield.demon_one.no_grenades_2 < time + timedisable)
			tfield.demon_one.no_grenades_2 = time + timedisable;
	}
			
	if (IsValidFieldGen(tfield.demon_two))
	{
		tfield.demon_two.has_holo = #FIELDGEN_ISDISABLED;

		if (tfield.demon_two.no_grenades_2 < time + timedisable)
			tfield.demon_two.no_grenades_2 = time + timedisable;
	}	 

	sound (tfield, #CHAN_VOICE, "misc/ffbeep.wav", 0.4, #ATTN_IDLE);
};

//=========================================================================================
// applies damage and makes the sound and visual effect for the forcefield shock

void() Field_touch_SUB =
{
	if (FieldIsMalfunctioning(self) & #SCREWUP_THREE) // reduce output
		self.dmg = 1;

	#ifdef GIBABLE_CORPSES
	if (other.#corpseflag == #STRFLAG_CORPSE) // Corpses
	{
		if (Field_ItCanPass(self, other))  
		{
			DisableField(self,#FIELDGEN_TIMEDISABLED);						  
			return;
		}
		else
		{
			if (Field_ShouldDamage(self,other))
				TF_T_Damage (other, self, self.real_owner, self.dmg, 0, #TF_TD_ELECTRICITY);
		}
	}
	else 
	#endif
	if (other.classname == "player" && other.health > 0) // PLAYERS (alive)
	{
		if (other.playerclass == #PC_UNDEFINED) // Observers (they have 1 hp)
			return; 		
		
		if (Field_ItCanPass(self, other))  
		{
			DisableField(self,#FIELDGEN_TIMEDISABLED);						  
			return;
		}
		else
		{
			if (Field_ShouldDamage(self,other))
				TF_T_Damage (other, self, self.real_owner, self.dmg, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
		}
	}
	else // non player entities (or player heads)
	{
		if (IsMonster(other))
		{
			if (Field_ItCanPass(self, other))
			{
				DisableField(self,#FIELDGEN_TIMEDISABLED);
				return;
			}
			else if (Field_ShouldDamage(self,other))
				TF_T_Damage (other, self, self.real_owner, self.dmg, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
		}
		else // non-monsters non-alive-players entities (EVERYTHING ELSE)
		{
			// excludes entities that shouldnt be moved, doors plats etc..
			if(other.movetype == #MOVETYPE_NONE 
				|| other.movetype == #MOVETYPE_PUSH
				|| other == world)
				return;

			if (other.flags & #FL_ONGROUND)
				other.velocity_z = other.velocity_z + 100 + 160*random();

			other.flags = other.flags - (other.flags & #FL_ONGROUND);
						
			if (self.cnt) // Y Alignment
			{
				if (other.origin_x < self.origin_x)
					other.velocity_x = (0 - other.velocity_x) - (80 + 100 * random());
				else
					other.velocity_x = (0 - other.velocity_x) + (80 + 100 * random());
			}
			else // X Alignment
			{
				if (other.origin_y < self.origin_y)
					other.velocity_y = (0 - other.velocity_y) - (80 + 100 * random());
				else
					other.velocity_y = (0 - other.velocity_y) + (80 + 100 * random());
			}
		}
	}

	// Do the effects for shock
	FieldExplosion(self,other.origin,other);
	PutFieldWork(self);
};

#ifdef FIELD_FORCEMODE

//==========================================================================
// gets one of our field generators

entity(entity myself) GetMyFieldGen =
{
	local entity te;
	local float foundit;
	te = world;
	foundit = #FALSE;

	te = find(world, classname, "building_fieldgen");
	while (te != world && foundit == #FALSE)
	{
		if (te.real_owner == myself) // is it ours?
			foundit = #TRUE; // yeah, found it
		
		if (foundit == #FALSE) // our search must continue...
			te = find(te, classname, "building_fieldgen");
	}

	return te;
};

//=========================================================================
// these functions retrieve and set the current 'forced status' on a field

float(entity tfield) Field_GetForcedStatus =
{
	if (IsValidFieldGen(tfield.demon_one) && IsValidFieldGen(tfield.demon_two))
	{
		if (tfield.demon_two.has_tesla || tfield.demon_one.has_tesla)
			return #TRUE;
	}
	else if (IsValidFieldGen(tfield.demon_one))
	{
		if (tfield.demon_one.has_tesla)
			return #TRUE;
	}
	else if (IsValidFieldGen(tfield.demon_two))
	{
		if (tfield.demon_two.has_tesla)
			return #TRUE;
	}

	return #FALSE;
};

//==============================================================================
// player functions called on menu.qc to disable/enable forced status on field

void(float value) SetFieldForcedStatus =
{
	local entity gen1, gen2;
	gen1 = GetMyFieldGen(self);
	gen2 = Find_OtherGen(gen1);

	if (IsValidFieldGen(gen1))
	{
		gen1.has_tesla = value;
		if (value)
			gen1.no_grenades_2 = time;
	}

	if (IsValidFieldGen(gen2))
	{
		gen2.has_tesla = value;
		if (value)
			gen2.no_grenades_2 = time;
	}
};

float() GetFieldForcedStatus =
{
	local entity gen1, gen2;
	gen1 = GetMyFieldGen(self);
	gen2 = Find_OtherGen(gen1);

	if (IsValidFieldGen(gen1) && IsValidFieldGen(gen2))
	{
		if (gen1.has_tesla || gen2.has_tesla)
			return #TRUE;
	}
	else if (IsValidFieldGen(gen1))
		return gen1.has_tesla;
	else if (IsValidFieldGen(gen2))
		return gen2.has_tesla;

	return #FALSE;

};

#endif

//=========================================================================
// returns TRUE if 'who' entity should be able to pass thru the field

float(entity tfield, entity who) Field_ItCanPass =
{

#ifdef FIELD_TEST
	return #FALSE;
#endif	  
	
	if (FieldIsMalfunctioning(tfield) & #SCREWUP_ONE) // Malfunctioning, always block
		return #FALSE;

	if (who == tfield.real_owner) // field owner - always pass
		return #TRUE;

#ifdef FIELD_FORCEMODE

	if (Field_GetForcedStatus(tfield)) 
		return #FALSE;

#endif
	
	if (who.classname == "player") // PLAYERS
	{
		if (who.job & #JOB_TKD) //WK 4/27/7 TKD people are so tough they can walk through field gens!
			return #TRUE;

		if (Teammate(who, tfield.real_owner)) // teammate
			return #TRUE;
		
		if (UndercoverTeammate(who, tfield.real_owner)) // spies disguised as our team
		{
			return #TRUE;
		}
	}
	else if (IsMonster(who))  // MONSTERS/ARMY
	{
		if (Teammate(who.real_owner, tfield.real_owner)) // team monster
			return #TRUE;
	}
	#ifdef GIBABLE_CORPSES
	else if (who.#corpseflag == #STRFLAG_CORPSE) // CORPSES
	{
		if (Teammate(who, tfield.real_owner)) // team corpse
			return #TRUE;
	}
	#endif

	return #FALSE;
};

//=========================================================================
// returns TRUE if 'who' entity should be damaged by the field

float(entity tfield, entity who) Field_ShouldDamage =
{
#ifdef FIELD_TEST
	return #TRUE;
#endif	 
	
	if (FieldIsMalfunctioning(tfield) & #SCREWUP_ONE) // Malfunctioning, hurts always
		return #TRUE;

	if (who.classname == "player") // PLAYERS
	{
		if (who.job & #JOB_TKD) //WK 4/27/7 TKD people are so tough they can walk through field gens!
			return #FALSE;

		if (who == tfield.real_owner) // field owner
			return #FALSE;

		if (Teammate(who, tfield.real_owner)) // teammate
			return #FALSE;

		if (UndercoverTeammate(who, tfield.real_owner)) // spies disguised as our team
		{
			return #FALSE;
		}
	}
	else if (IsMonster(who))  // MONSTERS/ARMY
	{
		if (Teammate(who.real_owner, tfield.real_owner)) // team monster
			return #FALSE;
	}
	#ifdef GIBABLE_CORPSES
	else if (who.#corpseflag == #STRFLAG_CORPSE) // CORPSES
	{
		if (Teammate(who, tfield.real_owner)) // team corpse
			return #FALSE;
	}
	#endif

	return #TRUE;
};

//=============================================================================
// applies the particle effect and electric sound (at max 4hz rate)

void(entity tfield, vector where, entity thing) FieldExplosion =
{
	if (!tfield.has_camera)
	{
		if (thing == world || thing.is_removed) return;

		local vector whereFX;
		whereFX = where;
		whereFX_z = tfield.origin_z;

		spawnFOG(whereFX);
		sound(tfield,#CHAN_BODY,"effects/crunch.wav",0.5,#ATTN_NORM);

		tfield.has_camera = #TRUE; // cya soon (this gets reset on every field think)
	}
};

//================================================================
// Refresh working time for the force field

void(entity field) PutFieldWork =
{
	if (IsValidFieldGen(field.demon_one))
		field.demon_one.tp_grenades_1 = time + #FIELDGEN_WORKTIME;		  
	if (IsValidFieldGen(field.demon_two))
		field.demon_two.tp_grenades_1 = time + #FIELDGEN_WORKTIME;
};

//==============================================================
// Force field touch function

void() Field_touch =
{
	if (other.classname == "force_field") return; //avoid weird loops with other fields

	self.dmg = #FIELD_DMG;

	deathmsg = #DMSG_FORCEFIELD;
	Field_touch_SUB();
};

//===================================================================================
// creates the force field between the 2 generators (only if none currently on)

void(entity gen1, entity gen2) Create_Field =
{
	// Check for existing force field, and abort if any
	if (gen1.has_sensor || gen2.has_sensor)
		return;

	if (gen1.martyr_enemy != world || gen2.martyr_enemy != world) // 2nd CHECK
		return;

	// already checked b4 on CanLink -> CanIdle
	/*if (!IsValidFieldGen(gen1) || !IsValidFieldGen(gen2))
		return;*/
		
	gen1.has_holo = #FIELDGEN_ISENABLED;
	gen2.has_holo = #FIELDGEN_ISENABLED;

	gen1.has_sensor = #TRUE;
	gen2.has_sensor = #TRUE;

	local entity tfield;

	// generate field
	tfield = spawn();
	tfield.classname = "force_field";
	tfield.owner = world;
	tfield.real_owner = gen1.real_owner; // --> player

	tfield.think = Field_think;
	tfield.touch = Field_touch;
	tfield.nextthink = time + 0.25;

	// set pos and size
	tfield.origin = gen1.origin + '0 0 32';
	tfield.absmin_z = gen1.origin_z - 32;
	tfield.absmax_z = gen1.origin_z + 32;

	tfield.mins_z = 0 - 32;
	tfield.maxs_z = 32;
	tfield.size_z = 64;

	local float diff;

	if (gen1.origin_x == gen2.origin_x)
	{
		tfield.cnt = 0; 
		
		tfield.origin_x = gen1.origin_x;
		tfield.absmin_x = gen1.origin_x - 2;
		tfield.absmax_x = gen1.origin_x + 2;

		tfield.maxs_x = 2;
		tfield.mins_x = 0 - 2;
		tfield.size_x = 4;

		if (gen1.origin_y > gen2.origin_y)
		{
			diff = (gen1.origin_y - gen2.origin_y)/2;
			
			tfield.origin_y = gen1.origin_y - diff;
			tfield.absmin_y = gen2.origin_y;
			tfield.absmax_y = gen1.origin_y;

			tfield.maxs_y = diff;
			tfield.mins_y = 0 - diff;
			tfield.size_y = diff * 2;
		}
		else
		{
			diff = (gen2.origin_y - gen1.origin_y)/2;

			tfield.origin_y = gen2.origin_y - diff;
			tfield.absmin_y = gen1.origin_y;
			tfield.absmax_y = gen2.origin_y;

			tfield.maxs_y = diff;
			tfield.mins_y = 0 - diff;
			tfield.size_y = diff * 2;
		}
	}
	else
	{
		tfield.cnt = 1; 

		tfield.origin_y = gen1.origin_y;
		tfield.absmin_y = gen1.origin_y - 2;
		tfield.absmax_y = gen1.origin_y + 2;
		
		tfield.maxs_y = 2;
		tfield.mins_y = 0 - 2;
		tfield.size_y = 4;

		if (gen1.origin_x > gen2.origin_x)
		{
			diff = (gen1.origin_x - gen2.origin_x)/2;
			
			tfield.origin_x = gen1.origin_x - diff;
			tfield.absmin_x = gen2.origin_x;
			tfield.absmax_x = gen1.origin_x;

			tfield.maxs_x = diff;
			tfield.mins_x = 0 - diff;
			tfield.size_x = diff * 2;

		}
		else
		{
			diff = (gen2.origin_x - gen1.origin_x)/2;
			
			tfield.origin_x = gen2.origin_x - diff;
			tfield.absmin_x = gen1.origin_x;
			tfield.absmax_x = gen2.origin_x;

			tfield.maxs_x = diff;
			tfield.mins_x = 0 - diff;
			tfield.size_x = diff * 2;
		}
	}	 

	// apply stuff
	tfield.movetype = #MOVETYPE_NONE;
	tfield.solid = #SOLID_BBOX;
	setsize(tfield, tfield.mins, tfield.maxs);
	setorigin(tfield, tfield.origin);

	// assign the pointers on the field generators
	gen1.martyr_enemy = tfield;
	gen2.martyr_enemy = tfield;

	// assign the pointers to generators on ourselves
	tfield.demon_one = gen1;
	tfield.demon_two = gen2;

	// make activation sound
	sound (tfield, #CHAN_VOICE, "misc/ffact.wav", 0.2, #ATTN_NORM);

	// initialize sound flags on field
	tfield.has_sensor = #FALSE;
	tfield.has_holo = #FALSE;

	// flash generators
	gen1.effects = #EF_DIMLIGHT | #EF_RED;
	gen1.has_teleporter = #TRUE;
	gen1.skin = 2;
	gen2.effects = #EF_DIMLIGHT | #EF_RED;
	gen2.has_teleporter = #TRUE;
	gen2.skin = 2;
};

//=================================================================
// removes the force field (if any)

void(entity gen1, entity gen2) Remove_Field =
{
	local float soundsoff;
	soundsoff = #FALSE;
	
	if (IsValidFieldGen(gen1))
	{	
		gen1.has_sensor = #FALSE;

		if (IsValidField(gen1.martyr_enemy))
		{
			Field_StopSounds(gen1.martyr_enemy); // Stops sounds on force field
			soundsoff = #TRUE;
			
			dremove(gen1.martyr_enemy);
			gen1.martyr_enemy = world;
		}
	}

	if (IsValidFieldGen(gen2))
	{
		gen2.has_sensor = #FALSE;
		
		if (IsValidField(gen2.martyr_enemy))
		{
			if (!soundsoff)
				Field_StopSounds(gen2.martyr_enemy); // Stops sounds on force field if not done

			dremove(gen2.martyr_enemy);
			gen2.martyr_enemy = world;
		}
	}
};

//======================================================================
// The following 2 functions are used for safety everywhere

float(entity field) IsValidField =
{
	if (field == world)
		return #FALSE;
	
	if (field.classname != "force_field")
		return #FALSE;

	return #TRUE;
};

float(entity fieldgen) IsValidFieldGen =
{
	if (fieldgen == world)
		return #FALSE;
	
	if (fieldgen.classname != "building_fieldgen")
		return #FALSE;
  
	return #TRUE;
};

//========================================================
// starts or removes sounds on the field

void(entity tfield, entity gen1) Field_UpdateSounds =
{
	//.has_holo   : hum
	//.has_sensor : shield
	
	if (IsValidField(tfield)) // only if there is a field currently
	{
		local float playhum, playshield;

		playhum = #FALSE; 
		playshield = #FALSE;

		/*if (gen1.has_holo == #FIELDGEN_ISOFF) // for some reason we r not working
		{
			playhum = #FALSE;
			playshield = #FALSE;
		}
		else if (gen1.has_holo == #FIELDGEN_ISIDLE) // awaiting for link
		{
			playhum = #FALSE;
			playshield = #FALSE;
		}
		else if (gen1.has_holo == #FIELDGEN_ISDISABLED) // teammate passing thru the field?
		{
			playhum = #FALSE;
			playshield = #FALSE;			
		}
		else*/
		
		if (gen1.has_holo == #FIELDGEN_ISENABLED)
		{
			playhum = #TRUE;
			playshield = #FALSE;
		}
		else if (gen1.has_holo == #FIELDGEN_ISWORKING)
		{
			playhum = #TRUE;
			playshield = #TRUE; 	   
		}

		// ok, lets update the sounds if needed..
		if (!playhum)
		{
			if (tfield.has_holo)
			{
				sound(tfield,#CHAN_MISC,"misc/null.wav",0.5,#ATTN_NORM);
				tfield.has_holo = #FALSE;
			}
		}
		else
		{
			if (!tfield.has_holo || tfield.has_tesla < time)
			{
				sound(tfield,#CHAN_MISC,"misc/ffhum.wav",0.4,#ATTN_NORM);
				tfield.has_tesla = time + #FIELD_SOUNDSRATE;
				tfield.has_holo = #TRUE;
			}
		}

		if (!playshield)
		{
			if (tfield.has_sensor)
			{
				sound(tfield,#CHAN_ITEM,"misc/null.wav",0.5,#ATTN_NORM);
				tfield.has_sensor = #FALSE;
			}
		}
		else
		{
			if (!tfield.has_sensor || tfield.has_sentry < time)
			{
				//TODO?: lower volume as (FIELDGEN_WORKTIME - time) decreases
				
				sound(tfield,#CHAN_ITEM,"misc/ffield.wav",0.5,#ATTN_NORM);
				tfield.has_sentry = time + #FIELD_SOUNDSRATE;
				tfield.has_sensor = #TRUE;
			}
		}	 
	}
};

//====================================================================
// Called on each force field removal to stop any sounds from it

void(entity tfield) Field_StopSounds =
{
	// We dont do any check because this function is called with everything already checked
	sound(tfield,#CHAN_ITEM,"misc/null.wav",0.5,#ATTN_NORM);
	sound(tfield,#CHAN_MISC,"misc/null.wav",0.5,#ATTN_NORM);
	tfield.has_sensor = #FALSE;
	tfield.has_holo = #FALSE;
};

//====================================================================
// do the lightning stuff while field is FIELDGEN_ISWORKING

void(entity tfield) Field_MakeVisual =
{
	// To avoid some overhead, only do visual lightning effect sometimes
	if (random() < #FIELD_VISUALFACTOR)
		return;
	
	if (IsValidField(tfield))
	{	   
		local float fx, fy;
		local vector tmpvec;

		if (tfield.cnt)
		{
			fy = tfield.origin_y;
			fx = tfield.origin_x + (tfield.size_x/2 - tfield.size_x * random());
		}
		else
		{
			fx = tfield.origin_x;
			fy = tfield.origin_y + (tfield.size_y/2 - tfield.size_y * random());
		}

		tmpvec_x = fx;
		tmpvec_y = fy;
		tmpvec_z = tfield.origin_z - 12;

		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		
		if (random() > 0.5)
			WriteByte (#MSG_BROADCAST, #TE_LIGHTNING2);
		else
			WriteByte (#MSG_BROADCAST, #TE_LIGHTNING1);

		WriteEntity (#MSG_BROADCAST, tfield);

		if (random() > 0.5)
		{
			WriteCoord (#MSG_BROADCAST, fx);
			WriteCoord (#MSG_BROADCAST, fy);
			WriteCoord (#MSG_BROADCAST, tfield.origin_z - 12);
			WriteCoord (#MSG_BROADCAST, fx);
			WriteCoord (#MSG_BROADCAST, fy);
			WriteCoord (#MSG_BROADCAST, tfield.origin_z + 12);
		}
		else
		{
			WriteCoord (#MSG_BROADCAST, fx);
			WriteCoord (#MSG_BROADCAST, fy);
			WriteCoord (#MSG_BROADCAST, tfield.origin_z + 22);
			WriteCoord (#MSG_BROADCAST, fx);
			WriteCoord (#MSG_BROADCAST, fy);
			WriteCoord (#MSG_BROADCAST, tfield.origin_z - 2);
		}

		#ifdef QUAKE_WORLD
		multicast (tmpvec, #MULTICAST_PHS);
		#endif
	}
};

//==================================================
// called every frame by the field generators

void() FieldGen_think =
{
	local entity othergen;
	othergen = Find_OtherGen(self); // get our brother
	
	// Create the force field if it's possible, or remove it if not and exists
	if (FieldGens_CanLink(self,othergen))
		Create_Field(self,othergen); // checks redundancy itself
	else
		Remove_Field(self,othergen); // checks redundancy itself

	// field gens main loop (ai? heh.. my cat is smarter than these force fields)
	if (self.has_holo == #FIELDGEN_ISOFF) // for some reason we r not working
	{
		self.effects = 0;
		self.skin = 0;

		if (FieldGen_CanIdle(self)) // can we go idle?
			self.has_holo = #FIELDGEN_ISIDLE;
	}
	else if (self.has_holo == #FIELDGEN_ISIDLE) // trying to link
	{
		self.effects = 0;
		self.skin = 0;
		
		if (self.no_grenades_1 < time) // trying to link sound/flash time
		{
			sound (self, #CHAN_WEAPON, "misc/fffail.wav", 0.5, #ATTN_IDLE);
			self.skin = 1;
			self.effects = #EF_DIMLIGHT;
			self.no_grenades_1 = time + #FIELDGEN_LINKTIME;
		}
	}
	else if (self.has_holo == #FIELDGEN_ISDISABLED) // teammate passing thru the field?
	{
		self.effects = 0;
		self.skin = 0;

		// time check
		if (self.no_grenades_2 < time) // can we go idle?
		{	 
			self.has_holo = #FIELDGEN_ISIDLE;
			self.tp_grenades_1 = 0;
		}		 
	}
	else if (self.has_holo == #FIELDGEN_ISENABLED) // we r ready and linked
	{
		if (!self.has_teleporter)
		{
			self.effects = 0;
			self.skin = 1;
		}

		if (self.has_sensor == #FALSE)
			self.has_holo = #FIELDGEN_ISIDLE;
		
		if (self.tp_grenades_1 >= time)
			self.has_holo = #FIELDGEN_ISWORKING;
	}
	else if (self.has_holo == #FIELDGEN_ISWORKING) // hopefully after killing some1..
	{
		self.effects = #EF_DIMLIGHT;
		self.skin = 2;	  
		
		if (self.has_camera <= time)
		{
			self.ammo_cells = self.ammo_cells - #FIELDGEN_CELLSCOST;

			if (self.ammo_cells <= 24 && self.ammo_cells > 24 - #FIELDGEN_CELLSCOST)
				sprint(self.real_owner,#PRINT_HIGH,"Your field generator is low on cells\n");
			else if (self.ammo_cells < #FIELDGEN_CELLSCOST)
				sprint(self.real_owner,#PRINT_HIGH,"Your field generator has run out of cells\n");

			self.has_camera = time + #FIELDGEN_WORKING_RATE;
		}

		if (self.has_sensor == #FALSE)
			self.has_holo = #FIELDGEN_ISIDLE;
		else if (self.tp_grenades_1 <= time)
			self.has_holo = #FIELDGEN_ISENABLED;
	}

	if (!FieldGen_CanIdle(self)) // turn us off if needed
		self.has_holo = #FIELDGEN_ISOFF;
	
	Field_UpdateSounds(self.martyr_enemy,self); // update force field sounds
   
	self.has_teleporter = #FALSE; // resets 'flash' status bypass
	self.nextthink = time + 0.1;
};

//=======================================================================
// returns TRUE if the generator could currently go to idle status

float(entity fieldgen) FieldGen_CanIdle =
{
	if (!(IsValidFieldGen(fieldgen)))
		return #FALSE;

	if (fieldgen.ammo_cells >= #FIELDGEN_CELLSCOST &&
		!(fieldgen.is_malfunctioning & #SCREWUP_FOUR)
		&& fieldgen.health > 0)
		return #TRUE;

	return #FALSE;
};

//=======================================================================
// returns TRUE if both generators could currently generate the field

float(entity fieldgen1, entity fieldgen2) FieldGens_CanLink =
{
	if (!(IsValidFieldGen(fieldgen1)) || !(IsValidFieldGen(fieldgen2)))
		return #FALSE;

	if (!visible2(fieldgen1,fieldgen2))
		return #FALSE;
	
	local float r;
	r = vlen(fieldgen1.origin - fieldgen2.origin); // get distance between generators

	// Both fieldgens hacked
	if ((fieldgen1.all_active & #IMPROVED_FOUR && fieldgen2.all_active & #IMPROVED_FOUR) && r > #FIELDGEN_HACKEDRANGE2)
		return #FALSE;

	// Only 1 fieldgen hacked
	if ( ((fieldgen1.all_active & #IMPROVED_FOUR && !(fieldgen2.all_active & #IMPROVED_FOUR)) || (fieldgen2.all_active & #IMPROVED_FOUR && !(fieldgen1.all_active & #IMPROVED_FOUR))) && r > #FIELDGEN_HACKEDRANGE)
		return #FALSE;

	// None hacked for range
	if (r > #FIELDGEN_RANGE && !(fieldgen1.all_active & #IMPROVED_FOUR || fieldgen2.all_active & #IMPROVED_FOUR))
		return #FALSE;

	if (fieldgen1.origin_z != fieldgen2.origin_z) // Different heights?
		return #FALSE;

	if (fieldgen1.origin_x != fieldgen2.origin_x && fieldgen1.origin_y != fieldgen2.origin_y) // Unaligned?
		return #FALSE;
	
	if (fieldgen1.has_holo == #FIELDGEN_ISDISABLED || fieldgen2.has_holo == #FIELDGEN_ISDISABLED)
		return #FALSE;

	if (fieldgen1.has_holo == #FIELDGEN_ISOFF || fieldgen2.has_holo == #FIELDGEN_ISOFF)
		return #FALSE;

	// Return TRUE only if basic conditions on CanIdle() are meet
	if (FieldGen_CanIdle(fieldgen1) && FieldGen_CanIdle(fieldgen2))
		return #TRUE;
	
	return #FALSE;
};

//=============================================================================================
// initialize field generator stuff just after beeing built, called on engineer.qc

void(entity fieldgen) FieldGen_Built =
{
	fieldgen.touch = SUB_Null;
	fieldgen.think = FieldGen_think;
	fieldgen.nextthink = time + 0.1;
	fieldgen.has_holo = #FIELDGEN_ISIDLE; // we start on IDLE status (searching for other gen to link)
	fieldgen.has_sensor = #FALSE;
	fieldgen.no_grenades_1 = time + 3;
	fieldgen.martyr_enemy = world;
};

//==============================================================
// returns our other generator (if any)

entity(entity fieldgen) Find_OtherGen =
{
	local entity te;
	local float foundit;
	te = world;
	foundit = #FALSE;

	te = find(world, classname, "building_fieldgen");
	while (te != world && foundit == #FALSE)
	{
		if (te.real_owner == fieldgen.real_owner) // is it ours?
		if (te != fieldgen) 					  // and not the same generator..
			foundit = #TRUE; // yeah, found it
		
		if (foundit == #FALSE) // our search must continue...
			te = find(te, classname, "building_fieldgen");
	}

	return te;
};

//=========================================================================================
// returns the place where field gen will be built related to player current pos and yaw
// called on engineer.qc, place is the origin passed where other kind of buildings are placed

vector(vector place) WhereGen =
{
	// if we have no field generator currently, it can be placed anywhere
	if (self.has_fieldgen == 0) return place;

	local vector retval;
	local float r, distx, disty, foundit;
	local entity te;

	foundit = #FALSE;

	// find the other generator
	te = find(world, classname, "building_fieldgen");
	while (te != world && foundit == #FALSE)
	{
		if (te.real_owner == self) // is it ours?
			foundit = #TRUE; // yeah, found it
		
		if (foundit == #FALSE) // our search must continue...
			te = find(te, classname, "building_fieldgen");
	}

	// check for error getting the other gen
	if (te == world || te.classname != "building_fieldgen" || foundit == #FALSE)
	{
		RPrint("BUG: Error in field generator placement routine. 'WhereGen()'\n");
		return place;
	}

	// calculate the new generator pos
	distx = fabs(place_x - te.origin_x);
	disty = fabs(place_y - te.origin_y);
	retval = place;

	if (distx < disty)
	{
		retval_x = te.origin_x; // adjust it in line

		r = vlen(self.origin - retval); // get distance from us (player)
		if (r > 200) // we r too far away?
			retval = place; // then bypass the calc
	}
	else
	{
		retval_y = te.origin_y; // adjust line up

		r = vlen(self.origin - retval); // get distance from us (player)
		if (r > 200) // we r too far away?
			retval = place; // then bypass the calc
	}
	
	// print message if they wont link
	if (!vis2orig(te.origin,retval))
		sprint(self, #PRINT_HIGH, "Your field generators won't link, there are obstacles between them!\n");
	
	r = vlen(te.origin - retval); // get distance between generators
	if (te.all_active & #IMPROVED_FOUR && r > #FIELDGEN_HACKEDRANGE)
		sprint(self, #PRINT_HIGH, "Your field generators are too far away to link, even hacked\n");
	
	if (r > #FIELDGEN_RANGE && !(te.all_active & #IMPROVED_FOUR))
		sprint(self, #PRINT_HIGH, "Your field generators are too far away to link\n");
	
	/*if (retval_z != te.origin_z)
		sprint(self, #PRINT_HIGH, "Your field generators are at different heights, they won't link\n");*/
	
	if (retval_x != te.origin_x && retval_y != te.origin_y)
		sprint(self, #PRINT_HIGH, "Your field generators are not lined up, they won't link\n");

	// return the final building place
	return retval;
};

//======================================================================
// damn! our field generator was destroyed. Force field must go down..

void() FieldGen_Die =
{
	self.real_owner.has_fieldgen = self.real_owner.has_fieldgen - 1;
	if (self.real_owner.has_fieldgen < 0) self.real_owner.has_fieldgen = 0;

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
#endif

	// check if field should be removed..
	local entity othergen;
	othergen = Find_OtherGen(self);
	
	if (IsValidFieldGen(othergen))
	   Remove_Field(self, othergen);	
	else
	   Remove_Field(self, world); // extra removal, not needed i think...
	
	sprint(self.real_owner, #PRINT_HIGH, "Your field generator was destroyed.\n");

	local entity sprite;

	sprite = SpawnSprite(1,#SPRITE_AIRBURST,self.origin,'0 0 0',#SPRITEMOVE_UPSLOW,0.1);

	if (sprite)
	{
		sprite.effects = #EF_DIMLIGHT;

		if (self.real_owner.team_no == 1)
			sprite.effects = #EF_DIMLIGHT | #EF_BLUE;
		else if (self.real_owner.team_no == 2)
			sprite.effects = #EF_DIMLIGHT | #EF_RED;
	}

	ThrowGib("progs/tesgib3.mdl", -70,#TRUE,0,0, #FALSE);

	dremove(self);
};

//=========================================================================
// Engineer has used a Spanner on the field generator

void(entity field) Engineer_UseFieldGen =
{
	self.building = field;
	
	// Neo mode modification
	if (Teammate(self.building.real_owner, self) && self.building.is_malfunctioning & #SCREWUP_THREE)
	{		 
		sprint(self,#PRINT_HIGH,"Trapped field generator, have a nice day!\n");
			
		deathmsg = #DMSG_FGTRAP;
		sound (self, #CHAN_MISC, "effects/crunch.wav", 1, #ATTN_NONE);
		TF_T_Damage(self, self, self, self.health + 60, 0, #TF_TD_OTHER);
		return;
	}

	local entity dist_checker;
	local string st;

	sprint(self, #PRINT_HIGH, "Field Generator has ");
	st = ftos(field.health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(field.max_health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " èåáìôè, ");
	st = ftos(field.ammo_cells);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(field.maxammo_cells);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " ãåììó\n");

	// Pop up the menu
	self.current_menu = #MENU_ENGINEER_FIX_FIELDGEN;
	self.menu_count = #MENU_REFRESH_RATE;

	//dodgy
	// Neo mode modification
	if (teamplay != 0 && !Teammate(self.building.real_owner, self)) {
		Menu_EngineerFix_FieldGen_Input(4);
		return;
	}

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the field generator.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = field;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};

//===========================================================================
// Any external code should use this function, where needed

void(entity tfield, vector where, entity thing) FieldEvent =
{
	FieldExplosion(tfield, where, thing);
	PutFieldWork(tfield);
};
