/*======================================================
	TFORT.QC			Custom TeamFortress v3.2	

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney			9/16/00
	(c) Craig Hauser				19/3/00
========================================================
Class handling and other utility functions
======================================================*/
// Function Prototypes
//void() RemoveFlare;
void() GrenadeExplode;
void() spike_touch;
void(entity p) bound_other_ammo;
void(entity Goal, entity Player, entity Item) DisplayItemStatus;
void (entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage;

// Map Function Prototypes
void(entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;

// Help Functions
void() TeamFortress_MOTD;

// Team Functions
float(float tno) TeamFortress_TeamGetColor;
void(float tno) TeamFortress_TeamSetColor;
float() TeamFortress_TeamPutPlayerInTeam;
float(float tno) TeamFortress_TeamGetScore;
float(float tno) TeamFortress_TeamGetIllegalClasses;

//WK
void() DropToCustomClassGen; //In custom.qc
float() W_BestWeapon; //In weapons.qc
void() FragGrenadeTouch; //In custom.qc
void() FragGrenadeExplode;
void() KracGrenadeTouch;
void() KracGrenadeExplode;
void() AntiGravGrenadeExplode;
void() Autoitem_think;
void() DetonateAllGuns;

// Impulse Functions
void() TeamFortress_ChangeClass;
void() TeamFortress_DisplayLegalClasses;
void() TeamFortress_Inventory;
void( entity printDest, entity g, float printLevel ) Grunty_PrintDetails;
void() TeamFortress_ShowTF;
void() TeamFortress_PrimeGrenade;
void() TeamFortress_ThrowGrenade;
void() TeamFortress_DisplayDetectionItems;

// Player Class Handling Functions
float(float pc) IsLegalClass;
//void() TeamFortress_SetAlias; //WK
void() TeamFortress_SetHealth;
void() TeamFortress_SetEquipment;
void(entity p) TeamFortress_SetSpeed;
void(entity p) TeamFortress_SetSkin;
void(entity Viewer, float pc, float rpc) TeamFortress_PrintClassName;
void() TeamFortress_RemoveTimers;
void(float Suicided) TeamFortress_SetupRespawn;
void() TeamFortress_CheckClassStats;
float(entity Retriever, float AmmoType) TeamFortress_GetMaxAmmo;
float(entity Retriever, float WeaponType) TeamFortress_CanGetWeapon;
float(entity Retriever, entity Items) TeamFortress_AddBackpackItems;
float(entity Player, float Armorclass) TeamFortress_DescribeArmor;
#ifdef SPEECH
void(entity player) TeamFortress_SayClassName;
#endif

// AmmoBox Handling Functions
void () TeamFortress_AmmoboxTouch;
float (float tno) num_team_ammoboxes;
void(float tno) RemoveOldAmmobox;
void(float tno) increment_team_ammoboxes;
void(float tno) decrement_team_ammoboxes;

// Weapon Handling Functions
void() TeamFortress_ExplodePerson;
void() NormalGrenadeTouch;
void() NormalGrenadeExplode;
void() PlayerObserverMode;

// Utility Functions
void(string halias, float himpulse1, float himpulse2) TeamFortress_Alias;

// Cyclic Event Functions
void() TeamFortress_Regenerate;
void() TeamFortress_RegenerateCyber;
void() TeamFortress_RegenerateCells;

//CH
float(entity p) Return_Custom_Skins;

//- OfN
void() FlareGrenadeTouch;
void() FlareGrenadeExplode;
void() FlareBounce;
void(entity sld) grunty_boundammo;
void(entity player) UpdateCells;
void () BioGrenadeTouch;
void () BioGrenadeExplode;
float(entity theplayer, float grenslot) GetMaxGrens;
string(float runetype) GetRuneString;
float(entity player) StripDisallowed;
float(entity player) GiveFreeStuff;
float(entity player) RestoreOriginalItems;
void(entity player) ResetStripedAndGiven;

//=========================================================================
// IMPULSE FUNCTIONS
//=========================================================================
// Uses a class dependant special skill
void() UseSpecialSkill =
{
	self.impulse = 0;

	if (self.cutf_items & #CUTF_SENTRYGUN || self.tf_items & #NIT_TESLA || self.tf_items & #NIT_SECURITY_CAMERA || self.tf_items & #NIT_TELEPORTER || self.cutf_items & #CUTF_DISPENSER || self.cutf_items & #CUTF_FIELDGEN)
		self.impulse = #TF_ENGINEER_BUILD;
	else if (self.cutf_items & #CUTF_SPY_KIT)
		self.impulse = #TF_SPY_SPY;
	else if (self.weapons_carried & #WEAP_GRENADE_LAUNCHER)
		self.impulse = #TF_PB_DETONATE;
	else if (self.tf_items & #NIT_SCANNER)
		self.impulse = #TF_SCAN_30;
	else if (self.weapons_carried & #WEAP_SNIPER_RIFLE)
		self.impulse = #TF_AUTOZOOM;
	else
		self.impulse = #TF_RELOAD;

	//WK Since most people don't know "disguise" or "build"
	// we'll allow them to toggle between the two with special.
	// This wipes out .money, so watch out for side effects.
	if (!(self.done_custom & #CUSTOM_BUILDING) && (self.impulse == #TF_ENGINEER_BUILD) && (self.cutf_items & #CUTF_SPY_KIT))
	{
		if (self.money) self.money = 0;
		else self.money = 1;

		if (self.money)
			self.impulse = #TF_ENGINEER_BUILD;
		else 
		{
			if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT)) //CH why not have the check here too, saves a keypress
				self.impulse = #TF_ENGINEER_BUILD;
			else
				self.impulse = #TF_SPY_SPY;
		}
	}
};


//=========================================================================
// Player change class function
// If self.impulse == 1, change to Civilian class
void() TeamFortress_ChangeClass =
{
	local entity spot, te;
	//local float tc;
	local string st;
	//local string scratch;

	//WK - Handle Custom Class Restarting
	if (self.playerclass == #PC_CUSTOM && self.done_custom & #CUSTOM_BUILDING) {
		DropToCustomClassGen(); //Comatose state
		return;
	}

	if (self.playerclass != #PC_UNDEFINED && !(self.playerclass == #PC_CUSTOM && (self.done_custom & #CUSTOM_BUILDING)))
	{
		// In Deathmatch 3, you can change class after you die
		if (deathmatch != 3)
			return;

		// Civilian Teams can never change class
		if (TeamFortress_TeamIsCivilian(self.team_no))
		{
			sprint(self, #PRINT_HIGH, "You're a civilian. Learn to live with it.\n");
			return; 		
		}

		if (!IsLegalClass(self.impulse - #TF_CHANGEPC))
		{
			sprint(self, #PRINT_HIGH, "Your team cannot play that class.\n");

			TeamFortress_DisplayLegalClasses();
			return;
		}

		self.nextpc = self.impulse - #TF_CHANGEPC;
		//WK - Handle Custom Class
		if (self.nextpc == #PC_CUSTOM)
		{
			self.done_custom = self.done_custom | #CUSTOM_ON_SPAWN; //Generate a new custom class when we respawn
		}

		sprint(self, #PRINT_HIGH, "After dying, you will return as a ");
		st = TeamFortress_GetClassName(self.nextpc);
		st = colstr(st,#COLSTR_RED);
		sprint(self, #PRINT_HIGH, st, "\n");
		return;
	}

	// players must join a team, if teamplay is on
	if (teamplay && self.team_no == 0) 
	{
		sprint(self, #PRINT_HIGH, "You must join a team first. \n");
		return;
	}

	// Only change if you've got any lives left
	if ( self.lives == 0 )
	{
		sprint(self, #PRINT_HIGH, "You have no lives left.\n");

		return;
	}

	if (!IsLegalClass(self.impulse - #TF_CHANGEPC) && (self.impulse != 1))
	{
		sprint(self, #PRINT_HIGH, "You cannot play that playerclass on this map. \n");

		TeamFortress_DisplayLegalClasses();
		return;
	}

	// Spy may be disabled
	if ((spy_off == #TRUE) && ((self.impulse - #TF_CHANGEPC) == #PC_SPY))
	{
		sprint(self, #PRINT_HIGH, "The spy class has been disabled on the server by the administrator.\n");
		return;
	}

	if (self.impulse != 1)
		self.playerclass = self.impulse - #TF_CHANGEPC;
	else
		self.playerclass = #PC_CIVILIAN;

	self.nextpc = 0;

	// Turn off #PC_UNDEFINED's nomove and invincibility
	self.takedamage = #DAMAGE_AIM;
	//WK Prevent bad movetype errors, or something
	if (self.classname != "player") {
		RPrint("BUG BUG BUG BUG BUG BUG BUG BUG BUG\n");
		RPrint("Non-player was in tfort.qc::changeclass()!\n");
		return;
	}
	
	self.movetype = #MOVETYPE_WALK;
	self.flags = #FL_CLIENT | #FL_ONGROUND;
	self.waterlevel = 0;
	self.air_finished = time + 12;

	// give them a model, and a new spawn point
	self.solid = #SOLID_SLIDEBOX;
	// pausetime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
	spot = SelectSpawnPoint ();

#ifdef MAP_DEBUG
	RPrint(self.netname);
	RPrint(" spawned at a ");
	RPrint(spot.netname);
	if (spot.team_no != 0)
	{
		RPrint(", team_no of ");
		st = ftos(spot.team_no);
		RPrint(st);
	}
	RPrint("\n");
#endif

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = #TRUE;		// turn this way immediately

	setmodel (self, string_null);
	modelindex_null = self.modelindex;

	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, #VEC_HULL_MIN, #VEC_HULL_MAX);	

	self.view_ofs = '0 0 22';
	player_stand1 ();
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	// Display chosen class
	if ( self.playerclass == #PC_RANDOM )
	{
		sprint(self, #PRINT_HIGH, "Random Playerclass.\n");

		self.tfstate = (self.tfstate | #TFSTATE_RANDOMPC);
		self.playerclass = 1 + floor(random() * (#PC_RANDOM - 1));
	}

	// If this is a TeamSpawnpoint, check to see if it
	// gives out a GoalItem, or displays a message
	if (spot.classname == "info_player_teamspawn")
	{
		if (spot.items != 0)
		{
			te = Finditem(spot.items);
			if (te)
				tfgoalitem_GiveToPlayer(te, self, self);

			if (!(spot.goal_activation & #TFSP_MULTIPLEITEMS))
				spot.items = 0;
		}

		if (spot.message)
		{
			CenterPrint(self, spot.message);

			if (!(spot.goal_activation & #TFSP_MULTIPLEMSGS))
				spot.message = string_null;
		}

		// TeamSpawn points can remove themselves after being spawned on
		if (spot.goal_effects == #TFSP_REMOVESELF)
		{
			spot.classname = "deadpoint";
			spot.team_str_home = string_null;
			spot.nextthink = time + 1;
			spot.think = SUB_Remove;
		}
	}

	//WK - Handle Custom Class
	if (self.playerclass == #PC_CUSTOM) {
		DropToCustomClassGen(); //Comatose state 
	}

	ResetMenu();
	TeamFortress_PrintClassName(self,self.playerclass, (self.tfstate & #TFSTATE_RANDOMPC));
#ifdef SPEECH
	TeamFortress_SayClassName(self);
#endif
	TeamFortress_SetEquipment();
	TeamFortress_SetHealth();
	TeamFortress_SetSpeed(self);
	TeamFortress_SetSkin(self);
	//WK Give them invincibility if they are a normal class or bought it
	if (self.playerclass >= #PC_SCOUT && self.playerclass <= #PC_RANDOM) {
		self.items = self.items + #IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + #RESPAWN_GUARD_TIME;
	}
};

//=========================================================================
// Display a list of all the legal classes for this map
void() TeamFortress_DisplayLegalClasses =
{
	local float gotone, ill;

	sprint(self, #PRINT_HIGH, "Legal Classes for your team are:\n");
	gotone = #FALSE;

	ill = TeamFortress_TeamGetIllegalClasses(self.team_no);

	if (!(illegalclasses & #TF_ILL_SCOUT) && !(ill & #TF_ILL_SCOUT))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Scout");
	}
	if (!(illegalclasses & #TF_ILL_SNIPER) && !(ill & #TF_ILL_SNIPER))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Sniper");
	}
	if (!(illegalclasses & #TF_ILL_SOLDIER) && !(ill & #TF_ILL_SOLDIER))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Soldier");
	}
	if (!(illegalclasses & #TF_ILL_DEMOMAN) && !(ill & #TF_ILL_DEMOMAN))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Demolitions Man");
	}
	if (!(illegalclasses & #TF_ILL_MEDIC) && !(ill & #TF_ILL_MEDIC))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Combat Medic");
	}
	if (!(illegalclasses & #TF_ILL_HVYWEP) && !(ill & #TF_ILL_HVYWEP))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Heavy Weapons Guy");
	}
	if (!(illegalclasses & #TF_ILL_PYRO) && !(ill & #TF_ILL_PYRO))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Pyro");
	}
	if (!(illegalclasses & #TF_ILL_SPY) && !(ill & #TF_ILL_SPY))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Spy");
	}
	if (!(illegalclasses & #TF_ILL_ENGINEER) && !(ill & #TF_ILL_ENGINEER))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "Engineer");
	}
	if (!(illegalclasses & #TF_ILL_RANDOMPC) && !(ill & #TF_ILL_RANDOMPC))
	{
		if (gotone)
			sprint(self, #PRINT_HIGH, ", ");
		gotone = #TRUE;
		sprint(self, #PRINT_HIGH, "RandomPC");
	}

	sprint(self, #PRINT_HIGH, "\n");
};

//=========================================================================
// Displays the player's inventory
void() TeamFortress_Inventory =
{
	local entity tg;
	local string ac;
	local float col;
	local float special; //CH used to determine if a \n is needed for a line
	special = 0;

	// Display Team
	col = TeamFortress_TeamGetColor(self.team_no);

	sprint(self, #PRINT_HIGH, "You're in team ");
	ac = ftos(self.team_no);
	sprint(self, #PRINT_HIGH, ac);
	sprint(self, #PRINT_HIGH, ", color ");
	ac = ftos(col);
	sprint(self, #PRINT_HIGH, ac);
	sprint(self, #PRINT_HIGH, ".\n");

	// Display Lives, if applicable
	if (self.lives != -1)
	{
		ac = ftos(self.lives);

		sprint(self, #PRINT_HIGH, "You've got ");
		sprint(self, #PRINT_HIGH, ac);
		if (self.lives == 1)
			sprint(self, #PRINT_HIGH, " life.\n");
		else 
			sprint(self, #PRINT_HIGH, " lives.\n");

	}

	// Display Number of Grenades of each type
	//WK Fix BUG grenades
	if (self.tp_grenades_1 == 0)
		self.no_grenades_1 = 0;
	if (self.tp_grenades_2 == 0)
		self.no_grenades_2 = 0;

	if (self.no_grenades_1 > 0)
	{
		sprint(self, #PRINT_HIGH, "Gren.Type 1: ");
		if (self.tp_grenades_1 == #GR_TYPE_NORMAL)
			sprint(self, #PRINT_HIGH, "Normal(");
		else if (self.tp_grenades_1 == #GR_TYPE_CONCUSSION)
			sprint(self, #PRINT_HIGH, "Concussion(");
		else if (self.tp_grenades_1 == #GR_TYPE_ANTIGRAV)
			sprint(self, #PRINT_HIGH, "AntiGrav(");
		else if (self.tp_grenades_1 == #GR_TYPE_NAIL)
			sprint(self, #PRINT_HIGH, "Nail(");
		else if (self.tp_grenades_1 == #GR_TYPE_MIRV)
			sprint(self, #PRINT_HIGH, "Mirv(");
		else if (self.tp_grenades_1 == #GR_TYPE_NAPALM)
			sprint(self, #PRINT_HIGH, "Napalm(");
		else if (self.tp_grenades_1 == #GR_TYPE_FLARE)
			sprint(self, #PRINT_HIGH, "Flare(");
		else if (self.tp_grenades_1 == #GR_TYPE_GAS)
			sprint(self, #PRINT_HIGH, "Hallucinogenic(");
		else if (self.tp_grenades_1 == #GR_TYPE_EMP)
			sprint(self, #PRINT_HIGH, "EMP(");
		#ifdef OLD_FLASH
		else if (self.tp_grenades_1 == #GR_TYPE_FLASH)
			sprint(self, #PRINT_HIGH, "Flash(");
		#else
		else if (self.tp_grenades_1 == #GR_TYPE_PSIONIC)
			sprint(self, #PRINT_HIGH, "Psionic(");
		#endif
		else if (self.tp_grenades_1 == #GR_TYPE_FRAG)
			sprint(self, #PRINT_HIGH, "Frag(");
		else if (self.tp_grenades_1 == #GR_TYPE_KRAC)
			sprint(self, #PRINT_HIGH, "Krac(");
		else if (self.tp_grenades_1 == #GR_TYPE_CALTROP)
			sprint(self, #PRINT_HIGH, "Caltrop(");
		else if (self.tp_grenades_1 == #GR_TYPE_BIO)
			sprint(self, #PRINT_HIGH, "Biological(");
		else 
			sprint(self, #PRINT_HIGH, "BUG(");

		ac = ftos(self.no_grenades_1);
		sprint(self, #PRINT_HIGH, ac);
		sprint(self, #PRINT_HIGH, ")\n");
	}
	if (self.no_grenades_2 > 0)
	{
		sprint(self, #PRINT_HIGH, "Gren.Type 2: ");
		if (self.tp_grenades_2 == #GR_TYPE_NORMAL)
			sprint(self, #PRINT_HIGH, "Normal(");
		else if (self.tp_grenades_2 == #GR_TYPE_CONCUSSION)
			sprint(self, #PRINT_HIGH, "Concussion(");
		else if (self.tp_grenades_2 == #GR_TYPE_NAIL)
			sprint(self, #PRINT_HIGH, "Nail(");
		else if (self.tp_grenades_2 == #GR_TYPE_ANTIGRAV)
			sprint(self, #PRINT_HIGH, "AntiGrav(");
		else if (self.tp_grenades_2 == #GR_TYPE_CALTROP)
			sprint(self, #PRINT_HIGH, "Caltrop(");
		else if (self.tp_grenades_2 == #GR_TYPE_MIRV)
			sprint(self, #PRINT_HIGH, "Mirv(");
		else if (self.tp_grenades_2 == #GR_TYPE_BIO)
			sprint(self, #PRINT_HIGH, "Biological(");
		else if (self.tp_grenades_2 == #GR_TYPE_NAPALM)
			sprint(self, #PRINT_HIGH, "Napalm(");
		else if (self.tp_grenades_2 == #GR_TYPE_FLARE)
			sprint(self, #PRINT_HIGH, "Flare(");
		else if (self.tp_grenades_2 == #GR_TYPE_GAS)
			sprint(self, #PRINT_HIGH, "Hallucinogenic(");
		else if (self.tp_grenades_2 == #GR_TYPE_EMP)
			sprint(self, #PRINT_HIGH, "EMP(");
		#ifdef OLD_FLASH
		else if (self.tp_grenades_2 == #GR_TYPE_FLASH)
			sprint(self, #PRINT_HIGH, "Flash(");
		#else
		else if (self.tp_grenades_2 == #GR_TYPE_PSIONIC)
			sprint(self, #PRINT_HIGH, "Psionic(");
		#endif
		else if (self.tp_grenades_2 == #GR_TYPE_FRAG)
			sprint(self, #PRINT_HIGH, "Frag(");
		else if (self.tp_grenades_2 == #GR_TYPE_KRAC)
			sprint(self, #PRINT_HIGH, "Krac(");
		else 
			sprint(self, #PRINT_HIGH, "BUG(");

		ac = ftos(self.no_grenades_2);
		sprint(self, #PRINT_HIGH, ac);
		sprint(self, #PRINT_HIGH, ")\n");
	}


	// Scanner
	if (self.tf_items & #NIT_SCANNER)
	{
		sprint(self, #PRINT_HIGH, "Scanner. ");
		special = special + 1; //CH determines \n
	}
	if (self.cutf_items & #CUTF_JAMMER)
	{
		sprint(self, #PRINT_HIGH, "Jammer. ");
		special = special + 1; //CH determines \n
	}

	if (self.cutf_items & #CUTF_CYBERAUG && !(self.weapons_carried & #WEAP_MEDIKIT))
	{
		sprint(self, #PRINT_HIGH, "CyberAug (");
		ac = ftos(self.ammo_medikit);
		sprint(self, #PRINT_HIGH, ac);
		sprint(self, #PRINT_HIGH, "). ");
		special = special + 1; //CH determines \n
	}
	else if (self.cutf_items & #CUTF_CYBERAUG && self.weapons_carried & #WEAP_MEDIKIT)
		sprint(self, #PRINT_HIGH, "CyberAug/");
	// Medikit and ammo
	if (self.weapons_carried & #WEAP_MEDIKIT)
	{
		sprint(self, #PRINT_HIGH, "Medikit (");
		ac = ftos(self.ammo_medikit);
		sprint(self, #PRINT_HIGH, ac);
		sprint(self, #PRINT_HIGH, "). ");
		special = special + 1; //CH determines \n
	}

	//if (self.cutf_items & #CUTF_INTERFACE)  //- OfN -
	//	sprint(self, #PRINT_HIGH, "Cyber Interface. ");


	// Detpack
	if (self.cutf_items & #CUTF_DETPACK)
	{
		if (self.ammo_detpack > 0)
		{
			ac = ftos(self.ammo_detpack);

			sprint(self, #PRINT_HIGH, ac);
			sprint(self, #PRINT_HIGH, " Detpack");
			if (self.ammo_detpack > 1)
				sprint(self, #PRINT_HIGH, "s");
			sprint(self, #PRINT_HIGH, ". ");
			special = special + 1; //CH determines \n
		}
	}
	if (self.cutf_items & #CUTF_TOSSABLEDET)
	{
		if (self.ammo_c4det > 0)
		{
			ac = ftos(self.ammo_c4det);

			sprint(self, #PRINT_HIGH, ac);
			sprint(self, #PRINT_HIGH, " Tossable Detpack");
			if (self.ammo_c4det > 1)
				sprint(self, #PRINT_HIGH, "s");
			sprint(self, #PRINT_HIGH, ". ");
			special = special + 1; //CH determines \n
		}
	}

	// GoalItems
	tg = find (world, classname, "item_tfgoal");
	while (tg)
	{
		if (tg.owner == self)
		{
			sprint(self, #PRINT_HIGH, tg.netname);
			sprint(self, #PRINT_HIGH, ". ");
			special = special + 1; //CH determines \n
		}

		tg = find(tg, classname, "item_tfgoal");
	}

	// Armor
	if (self.armorvalue > 0)
	{
		special = special + TeamFortress_DescribeArmor(self, self.armorclass);
	}
if (special > 0)
	sprint(self, #PRINT_HIGH, "\n");

if (!invis_only)
{
	// Spy gets told what skin and color he/she is wearing
	if ((self.cutf_items & #CUTF_SPY_KIT) && invis_only == #FALSE)
	{
		sprint (self, #PRINT_HIGH, "Skin : ");
		if (self.undercover_skin != 0)
			TeamFortress_PrintClassName(self,self.undercover_skin,0);
		else
			TeamFortress_PrintClassName(self,self.skin,0);

		sprint (self, #PRINT_HIGH, "Colors : Team ");
		if (self.undercover_team != 0)
			ac = ftos(self.undercover_team);
		else
			ac = ftos(self.team_no);
		sprint (self, #PRINT_HIGH, ac);
		sprint(self, #PRINT_HIGH, "\n");
	}
}

	// OfN - Display the health of any summons/army guys
	if (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY) 
	{
		if (self.demon_one)
		{
			ac=GetMonsterName(self.demon_one);

			sprint (self, #PRINT_HIGH, "Your ");
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH," ");
			sprint (self, #PRINT_HIGH,self.demon_one.netname);
			sprint(self, #PRINT_HIGH," has ");

			ac = ftos(ceil(self.demon_one.health));
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH, "―");
			ac = ftos(ceil(self.demon_one.max_health));
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH, " HP\n");
		}

		if (self.demon_two)
		{
			ac=GetMonsterName(self.demon_two);

			sprint (self, #PRINT_HIGH, "Your ");
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH," ");
			sprint (self, #PRINT_HIGH,self.demon_two.netname);
			sprint(self, #PRINT_HIGH," has ");

			ac = ftos(ceil(self.demon_two.health));
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH, "―");
			ac = ftos(ceil(self.demon_two.max_health));
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH, " HP\n");
		}

		if (self.demon_three)
		{
			ac=GetMonsterName(self.demon_three);

			sprint (self, #PRINT_HIGH, "Your ");
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH," ");
			sprint (self, #PRINT_HIGH,self.demon_three.netname);
			sprint(self, #PRINT_HIGH," has ");

			ac = ftos(ceil(self.demon_three.health));
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH, "―");
			ac = ftos(ceil(self.demon_three.max_health));
			sprint (self, #PRINT_HIGH, ac);
			sprint (self, #PRINT_HIGH, " HP\n");
		}
	}

	if (self.has_sentry)
	{
		tg = find(world, classname, "building_sentrygun");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				
				if (!tg.dont_do_triggerwork || !(self.cutf_items & #CUTF_DOUBLESENTRY))
					sprint (self, #PRINT_HIGH, "σεξτςω: ");
				else
				{
					if (tg.dont_do_triggerwork == 1)
						sprint (self, #PRINT_HIGH, "σεξτςω £: ");
					else if (tg.dont_do_triggerwork == 2)
						sprint (self, #PRINT_HIGH, "σεξτςω £: ");
					else
						sprint (self, #PRINT_HIGH, "σεξτςω: ");
				}
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " θπ\n");

			}
			tg = find(tg, classname, "building_sentrygun");
		}
	}
	if (self.has_tesla)
	{
		tg = find(world, classname, "building_tesla");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));

				
				if (!tg.dont_do_triggerwork || !(self.tf_items & #NIT_DOUBLETESLA))
					sprint (self, #PRINT_HIGH, "τεσμα: ");
				else
				{
					if (tg.dont_do_triggerwork == 1)
						sprint (self, #PRINT_HIGH, "τεσμα £: ");
					else if (tg.dont_do_triggerwork == 2)
						sprint (self, #PRINT_HIGH, "τεσμα £: ");
					else
						sprint (self, #PRINT_HIGH, "τεσμα: ");
				}

				//sprint (self, #PRINT_HIGH, "τεσμα: ");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " θπ\n");

			}
			tg = find(tg, classname, "building_tesla");
		}
	}
	if (self.has_dispenser)
	{
		tg = find(world, classname, "building_dispenser");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				sprint (self, #PRINT_HIGH, "δισπεξσες: ");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " θπ\n");

			}
			tg = find(tg, classname, "building_dispenser");
		}
	}
	if (self.has_sensor)
	{
		tg = find(world, classname, "building_sensor");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				sprint (self, #PRINT_HIGH, "σεξσος: ");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " θπ\n");

			}
			tg = find(tg, classname, "building_sensor");
		}
	}
	if (self.has_camera)
	{
		tg = find(world, classname, "building_camera");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				sprint (self, #PRINT_HIGH, "γανεςα: ");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " θπ\n");

			}
			tg = find(tg, classname, "building_camera");
		}
	}
	if (self.has_teleporter > 0)
	{
		tg = find(world, classname, "building_teleporter");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				sprint (self, #PRINT_HIGH, "τεμεποςτες: ");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "θπ ");

				ac = ftos(ceil(tg.ammo_cells));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.maxammo_cells));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "γεμμσ");
				
				if (!(tg.tf_items & #NIT_TURRET))
				{
					sprint (self, #PRINT_HIGH, "\n");					 
				}
				else
				{
					sprint (self, #PRINT_HIGH, "¨T©\n");
				}

			}
			tg = find(tg, classname, "building_teleporter");
		}
	}
	if (self.has_fieldgen > 0)
	{
		tg = find(world, classname, "building_fieldgen");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				sprint (self, #PRINT_HIGH, "Ζιεμδ Ηεξεςατος: ");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "θπ ");

				ac = ftos(ceil(tg.ammo_cells));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "―");
				ac = ftos(ceil(tg.maxammo_cells));
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, "γεμμσ\n");

			}
			tg = find(tg, classname, "building_fieldgen");
		}
	}

	/*if (self.job & #JOB_WARLOCK && self.job & #JOB_DEMON_OUT)
	{
		sprint (self, #PRINT_HIGH, "You have a ");
		ac=GetMonsterName(self.demon_two);
		sprint (self, #PRINT_HIGH, ac);
		sprint (self, #PRINT_HIGH, " summoned: ");

		tg = find(world, classname, "monster_demon1");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				//sprint (self, #PRINT_HIGH, " (");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " HP ");
			}
			tg = find(tg, classname, "monster_demon1");
		}
		
		tg = find(world, classname, "monster_army");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				sprint (self, #PRINT_HIGH, " (");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, ") ");
			}
			tg = find(tg, classname, "monster_army");
		}

		tg = find(world, classname, "monster_shambler");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				//sprint (self, #PRINT_HIGH, " (");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " HP ");
			}
			tg = find(tg, classname, "monster_shambler");
		}

		tg = find(world, classname, "monster_wizard");
		while (tg)
		{
			if (tg.real_owner == self)
			{
				ac = ftos(ceil(tg.health));
				//sprint (self, #PRINT_HIGH, " (");
				sprint (self, #PRINT_HIGH, ac);
				ac = ftos(ceil(tg.max_health));
				sprint (self, #PRINT_HIGH, "―");
				sprint (self, #PRINT_HIGH, ac);
				sprint (self, #PRINT_HIGH, " HP ");
			}
			tg = find(tg, classname, "monster_wizard");
		}

		//sprint (self, #PRINT_HIGH, ac);
		sprint (self, #PRINT_HIGH, "\n");
	}*/
	
	/*if (self.job & #JOB_WARLOCK) // they can see that on warlock menu
	{
		ac = ftos (self.demon_blood);
		sprint (self, #PRINT_HIGH, "Knife kills: ", ac, "\n");	// knife kills
	}*/    

	//CH if you have boots, state percent of fuel
	if (self.tf_items & #NIT_HOVER_BOOTS)
	{
		if (self.hover_time <= 0)
			ac = "0";
		else
			ac = ftos(floor(100 * (self.hover_time / #MAX_HOVER_FUEL)));
		sprint (self, #PRINT_HIGH, "Boot Charge: ");
		sprint (self, #PRINT_HIGH, ac);
		sprint (self, #PRINT_HIGH, "%  ");
	}
	//CH if you have a job.  tell when can work
	if (self.job & #JOB_ALL)
	{
		if ((self.job_finished - time) <= 0)
			sprint (self,#PRINT_HIGH, "Skill Time: ");
		else
		{
			ac = ftos(ceil(self.job_finished - time));
		sprint (self,#PRINT_HIGH, "Skill Time:");
		sprint (self, #PRINT_HIGH, ac);
		if (ceil(self.job_finished - time) == 1)
			sprint (self, #PRINT_HIGH, " second");
		else
			sprint (self, #PRINT_HIGH, " seconds");
		}
	}

	if (self.aura) //- OfN - If we have an aura it should tell
	{
		if (self.crusader_inspirator != world && self.crusader_inspirator.is_connected && self.crusader_inspirator.classname == "player")
		{
			sprint(self,#PRINT_HIGH,"\n");
			sprint(self,#PRINT_HIGH,self.crusader_inspirator.netname);
			sprint(self,#PRINT_HIGH," grants you the AURA of ");
		}
		else
			sprint(self,#PRINT_HIGH,"\nYou enjoy the AURA of ");
		
		if (self.aura == #AURA_POWER)
			sprint(self,#PRINT_HIGH,"ποχες.");
		else if (self.aura == #AURA_RESIS)
			sprint(self,#PRINT_HIGH,"ςεσισταξγε.");
		else if (self.aura == #AURA_HASTE)
			sprint(self,#PRINT_HIGH,"θαστε.");
		else if (self.aura == #AURA_INVIS)
			sprint(self,#PRINT_HIGH,"ιξφισιβιμιτω.");
		else if (self.aura == #AURA_REGEN)
			sprint(self,#PRINT_HIGH,"ςεηεξεςατιοξ.");
		else if (self.aura == #AURA_SPEED)
			sprint(self,#PRINT_HIGH,"σπεεδ.");
	}

	if (!neo && self.#runes) // OfN - List all the runes we own // Neo mod
	{
		if (self.#runes & #RUNE_TRIAD)
		{
			ac = GetRuneString(#RUNE_TRIAD);
			sprint(self,#PRINT_HIGH,"\nYou have the ",ac,".");
		}
		if (self.#runes & #RUNE_RESIS)
		{
			ac = GetRuneString(#RUNE_RESIS);
			sprint(self,#PRINT_HIGH,"\nYou have the ",ac,".");
		}
		if (self.#runes & #RUNE_SPEED)
		{
			ac = GetRuneString(#RUNE_SPEED);
			sprint(self,#PRINT_HIGH,"\nYou have the ",ac,".");
		}
		if (self.#runes & #RUNE_REGEN)
		{
			ac = GetRuneString(#RUNE_REGEN);
			sprint(self,#PRINT_HIGH,"\nYou have the ",ac,".");
		}
	}
	// Attackers Go Red mode -PZ
	if (agr) AGR_invPrint();

	// Neo mode
	if (neo) Neo_invPrint();

	sprint (self, #PRINT_HIGH, "\n");
};

//=========================================================================
// Displays the state of the ToggleFlags
void() TeamFortress_ShowTF =
{
	local string st;

	// Class Persistence between lvls On/Off
	if (toggleflags & #TFLAG_CLASS_PERSIST)
		sprint (self, #PRINT_HIGH, "Class Persistence On.\n");
	else
		sprint (self, #PRINT_HIGH, "Class Persistence Off.\n");

	// Cheat Checking On/Off
	if (toggleflags & #TFLAG_CHEATCHECK)
		sprint (self, #PRINT_HIGH, "Cheat Checking On.\n");
	else
		sprint (self, #PRINT_HIGH, "Cheat Checking Off.\n");

	// AutoTeam On/Off
	if (toggleflags & #TFLAG_AUTOTEAM)
		sprint (self, #PRINT_HIGH, "AutoTeam On.\n");
	else
		sprint (self, #PRINT_HIGH, "AutoTeam Off.\n");

	// RespawnDelay
	if (toggleflags & #TFLAG_RESPAWNDELAY)
		st = ftos(respawn_delay_time);
	else
		st = "No";
	sprint (self, #PRINT_HIGH, st);
	if (st != "No")
		sprint (self, #PRINT_HIGH, " second");
	sprint (self, #PRINT_HIGH, " Respawn Delay.\n");

	// TeamFrags On/Off
	if (toggleflags & #TFLAG_TEAMFRAGS)
		sprint (self, #PRINT_HIGH, "TeamFrags On.\n");
	else
		sprint (self, #PRINT_HIGH, "TeamFrags Off.\n");

	// Grapple hook
	if (allow_hook)
		sprint (self, #PRINT_HIGH, "Grapple On.\n");
	else
		sprint (self, #PRINT_HIGH, "Grapple Off.\n");

};

void() TeamFortress_GrenadePrimed;

//=========================================================================
// Primes a grenade of the type corresponding to the player's impulse
void() TeamFortress_PrimeGrenade =
{
	local float gtype,gsd;
	local string st, gs, ptime;
	local entity tGrenade;

	if (self.job & #JOB_THIEF && self.job & #JOB_FULL_HIDE) {
		sprint(self,#PRINT_HIGH,"You can't throw grens while fully invisible\n");
		return;
	}

	// If you've already primed a grenade, return
	if ((self.tfstate & #TFSTATE_GRENPRIMED) || (self.tfstate & #TFSTATE_GRENTHROWING))
	{
		return;
	}

	// WK 6/1/7 Add in serverinfo for grenade spam delay, "gsd"
	// WK 5-15-08 Reduced delay to 2 from 2.2
#define GRENADE_SPAM_DELAY 2
	gsd = #GRENADE_SPAM_DELAY;
	st = infokey(world,"gsd");
	if (st != string_null) {
		gsd = stof(st);
		if (gsd < 0 || gsd > 6) gsd = #GRENADE_SPAM_DELAY;
	}
	// WK 2/8/7 You can only prime one grenade per 3 seconds
	if (time < self.last_grenade_primed + gsd)
	{
		//sprint(self,#PRINT_HIGH,"You can only prime one grenade every 3 seconds\n");
		return;
	}

	// OfN - Psionized guys can't prime grenades
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self,#PRINT_HIGH,"You hardly have control over your hands!\n");
		return;
	}

	if (self.impulse == #TF_GRENADE_1)
	{
#define SPAM_TIME 7
		//WK Stop frag spammming // enabled again
		if (self.tp_grenades_1 == #GR_TYPE_FRAG && self.no_grenades_1 > 0) {
			if ((self.team_no == 1 && team1nextspam >= time) ||
				  (self.team_no == 2 && team2nextspam >= time) ||
					  (self.team_no == 3 && team3nextspam >= time) ||
				(self.team_no == 4 && team4nextspam >= time)) {
				sprint(self,#PRINT_HIGH,"Your team already has a spam grenade in the world.\n");
				return;
			}
			if (self.team_no == 1) team1nextspam = time + #SPAM_TIME;
			if (self.team_no == 2) team2nextspam = time + #SPAM_TIME;
			if (self.team_no == 3) team3nextspam = time + #SPAM_TIME;
			if (self.team_no == 4) team4nextspam = time + #SPAM_TIME;
			
		} // OfN Removed spam control // enabled again
		gtype = self.tp_grenades_1;
		if (gtype == #GR_TYPE_CONCUSSION)
			gs = "Concussion grenade";
		else if (gtype == #GR_TYPE_ANTIGRAV)
			gs = "AntiGrav grenade";
		else if (gtype == #GR_TYPE_BIO)
			gs = "Biological grenade";
		else if (gtype == #GR_TYPE_CALTROP)
			gs = "Caltrop grenade";
		else if (gtype == #GR_TYPE_NAIL)
			gs = "Nail grenade";
		else if (gtype == #GR_TYPE_MIRV)
			gs = "Mirv grenade";
		else if (gtype == #GR_TYPE_NAPALM)
			gs = "Napalm grenade";
		else if (gtype == #GR_TYPE_FLARE)
			gs = "Flare";
		else if (gtype == #GR_TYPE_GAS)
			gs = "Gas grenade";
		else if (gtype == #GR_TYPE_EMP)
			gs = "EMP grenade";
		#ifdef OLD_FLASH
		else if (gtype == #GR_TYPE_FLASH)
			gs = "Flash grenade";
		#else
		else if (gtype == #GR_TYPE_PSIONIC)
			gs = "Psionic grenade";
		#endif
		else if (gtype == #GR_TYPE_FRAG)
			gs = "Fragmentation grenade";
		else if (gtype == #GR_TYPE_KRAC)
			gs = "Krac grenade";
		else
			gs = "Grenade";

		if (self.no_grenades_1 >= 1)
		{
			ptime = ftos( #GR_PRIMETIME );

			sprint(self, #PRINT_HIGH, gs);
			sprint(self, #PRINT_HIGH, " primed, ");
			sprint(self, #PRINT_HIGH, ptime);
			sprint(self, #PRINT_HIGH, " seconds...\n");

			/*if ((self.tp_grenades_1 == #GR_TYPE_NAIL || self.tp_grenades_1 == #GR_TYPE_FRAG) && self.no_grenades_1 > 2)
				self.no_grenades_1 = 2;*/

			if (self.no_grenades_1 > GetMaxGrens(self,1))
				self.no_grenades_1 = GetMaxGrens(self,1);


			self.no_grenades_1 = self.no_grenades_1 - 1;
			self.last_grenade_primed = time; //WK 2/26/7 Gren prime bugfix

			// OfN 
			//sound(self, #CHAN_MISC, "weapons/pinpull.wav", 1, #ATTN_IDLE);
		}
		else
		{
			sprint(self, #PRINT_HIGH, "No ");
			sprint(self, #PRINT_HIGH, gs);
			sprint(self, #PRINT_HIGH, "s left.\n");
			return;
		}
	}
	if (self.impulse == #TF_GRENADE_2)
	{
		if (self.tp_grenades_2 == #GR_TYPE_FRAG  && self.no_grenades_2 > 0) {
			if ((self.team_no == 1 && team1nextspam >= time) ||
				(self.team_no == 2 && team2nextspam >= time) ||
					  (self.team_no == 3 && team3nextspam >= time) ||
				(self.team_no == 4 && team4nextspam >= time)) {
				sprint(self,#PRINT_HIGH,"Your team already has a spam grenade in the world.\n");
				return;
			}
			if (self.team_no == 1) team1nextspam = time + #SPAM_TIME + 1;
			if (self.team_no == 2) team2nextspam = time + #SPAM_TIME + 1;
			if (self.team_no == 3) team3nextspam = time + #SPAM_TIME + 1;
			if (self.team_no == 4) team4nextspam = time + #SPAM_TIME + 1;
			
		} // OfN Removed spam control
		gtype = self.tp_grenades_2;
		if (gtype == #GR_TYPE_CONCUSSION)
			gs = "Concussion grenade";
		else if (gtype == #GR_TYPE_ANTIGRAV)
			gs = "AntiGrav grenade";
		else if (gtype == #GR_TYPE_BIO)
			gs = "Biological grenade";
		else if (gtype == #GR_TYPE_CALTROP)
			gs = "Caltrop grenade";
		else if (gtype == #GR_TYPE_NAIL)
			gs = "Nail grenade";
		else if (gtype == #GR_TYPE_MIRV)
			gs = "Mirv grenade";
		else if (gtype == #GR_TYPE_NAPALM)
			gs = "Napalm grenade";
		else if (gtype == #GR_TYPE_FLARE)
			gs = "Flare";
		else if (gtype == #GR_TYPE_GAS)
			gs = "Gas grenade";
		else if (gtype == #GR_TYPE_EMP)
			gs = "EMP grenade";
		#ifdef OLD_FLASH
		else if (gtype == #GR_TYPE_FLASH)
			gs = "Flash grenade";
		#else
		else if (gtype == #GR_TYPE_PSIONIC)
			gs = "Psionic grenade";
		#endif
		else if (gtype == #GR_TYPE_FRAG)
			gs = "Fragmentation grenade";
		else if (gtype == #GR_TYPE_KRAC)
			gs = "Krac grenade";
		else
			gs = "Grenade";

		
/*		  if (gtype == #GR_TYPE_CONCUSSION)
			gs = "Concussion grenade";
		else if (gtype == #GR_TYPE_NAIL)
			gs = "Nail grenade";
		else if (gtype == #GR_TYPE_MIRV)
			gs = "Mirv grenade";
		else if (gtype == #GR_TYPE_NAPALM)
			gs = "Napalm grenade";
		else if (gtype == #GR_TYPE_FLARE)
			gs = "Flare";
		else if (gtype == #GR_TYPE_GAS)
			gs = "Gas grenade";
		else if (gtype == #GR_TYPE_EMP)
			gs = "EMP grenade";
		else if (gtype == #GR_TYPE_FLASH)
			gs = "Flash grenade";
		else if (gtype == #GR_TYPE_FRAG)
			gs = "Fragmentation grenade";
		else if (gtype == #GR_TYPE_BIO)
			gs = "BioInfection grenade";
		else if (gtype == #GR_TYPE_CALTROP)
			gs = "Caltrop grenade";

		else if (gtype == #GR_TYPE_KRAC)
			gs = "Krac grenade";
		else
			gs = "Grenade";*/

		if (self.no_grenades_2 >= 1)
		{
			ptime = ftos( #GR_PRIMETIME );

			sprint(self, #PRINT_HIGH, gs);
			sprint(self, #PRINT_HIGH, " primed, ");
			sprint(self, #PRINT_HIGH, ptime);
			sprint(self, #PRINT_HIGH, " seconds...\n");

			//WK Limit Nail grenades to 2 - ofn and frag
			
			if (self.no_grenades_2 > GetMaxGrens(self,2))
				self.no_grenades_2 = GetMaxGrens(self,2);

			/*if ((self.tp_grenades_2 == #GR_TYPE_NAIL || self.tp_grenades_2 == #GR_TYPE_FRAG) && self.no_grenades_2 > 2)
				self.no_grenades_2 = 2;*/

			self.no_grenades_2 = self.no_grenades_2 - 1;
			self.last_grenade_primed = time; //WK 2/26/7 Gren Prime Bugfix

			//sound(self, #CHAN_MISC, "weapons/pinpull.wav", 1, #ATTN_IDLE);
		}
		else
		{
			sprint(self, #PRINT_HIGH, "No ");
			sprint(self, #PRINT_HIGH, gs);
			sprint(self, #PRINT_HIGH, "s left.\n");
			return;
		}
	}

	self.tfstate = (self.tfstate | #TFSTATE_GRENPRIMED);
	tGrenade = spawn();
	tGrenade.owner = self;
	tGrenade.weapon = gtype;
	tGrenade.classname = "grenade_timer"; // OfN - New classname to fix gren in spawn
	tGrenade.nextthink = time + 0.8;
	tGrenade.heat = time + #GR_PRIMETIME + 0.8;
	tGrenade.think = TeamFortress_GrenadePrimed;
	if (gtype == #GR_TYPE_CALTROP)
		tGrenade.heat = tGrenade.heat - #GR_PRIMETIME;
};

void() TeamFortress_GrenadePrimed =
{
	local entity user;
	local entity oldself;

	user = self.owner;

	if (!(user.tfstate & #TFSTATE_GRENTHROWING) && !user.deadflag)
	{
		self.nextthink = time + 0.1;

		if (!self.think)
			dremove(self);
		
		if (time > self.heat)
			TeamFortress_ExplodePerson();

		return;
	}

	if (!(user.tfstate & #TFSTATE_GRENPRIMED))
	{
		RPrint("GrenadePrimed logic error\n"); // OFN: FIXME: This happens!
		dremove(self); // OfN <-- fixed ancient bug?
		return; // OfN <-- fixed ancient bug?
	}

	user.tfstate = user.tfstate - (user.tfstate & #TFSTATE_GRENPRIMED);
	user.tfstate = user.tfstate - (user.tfstate & #TFSTATE_GRENTHROWING);

	// ofn
	if (self.weapon == #GR_TYPE_FLARE)
		sound (user, #CHAN_WEAPON, "weapons/flmfire2.wav", 1, #ATTN_NORM);
	else
		sound (user, #CHAN_WEAPON, "weapons/grenade.wav", 1, #ATTN_NORM);
		//sound (user, #CHAN_WEAPON, "weapons/throw.wav", 1, #ATTN_NORM);

	KickPlayer(-1, user);
	newmis = spawn ();
	newmis.owner = user;
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_BBOX;
	newmis.classname = "grenade";
	
	// set grenade speed
	makevectors (user.v_angle);

	if (user.deadflag)
	{
		// if user is dead, throw grenade directly up
		newmis.velocity = '0 0 200';
	}
	else
	{
		if (user.v_angle_x)
		{
			newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;

			if (user.tfstate & #TFSTATE_PSIONIZED) // Weak toss when psionized
				newmis.velocity = newmis.velocity * 0.3;
		}
		else
		{
			newmis.velocity = aim(user, 10000);
			newmis.velocity = newmis.velocity * 600;
			newmis.velocity_z = 200;

			if (user.tfstate & #TFSTATE_PSIONIZED) // Weak toss when psionized
				newmis.velocity = newmis.velocity * 0.3;
		}
	}

	newmis.angles = vectoangles(newmis.velocity);

	// set the grenade's thinktime to when the PRIMETIME runs out
	newmis.think = SUB_Null;
	newmis.nextthink = self.heat;

	// set the think and touches to the appropriate grenade type
	if (self.weapon == #GR_TYPE_NORMAL)
	{
		newmis.touch = NormalGrenadeTouch;
		newmis.think = NormalGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");

	}
	else if (self.weapon == #GR_TYPE_CONCUSSION)
	{
		newmis.touch = ConcussionGrenadeTouch;
		newmis.think = ConcussionGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_BIO)
	{
		newmis.touch = BioGrenadeTouch;
		newmis.think = BioGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_CALTROP)
	{
		newmis.touch = SUB_Null;
		newmis.think = CaltropGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '0 0 0';
		newmis.velocity = '0 0 0';
		setmodel (newmis, string_null);
	}
	else if (self.weapon == #GR_TYPE_ANTIGRAV)
	{
		newmis.touch = ConcussionGrenadeTouch;
		newmis.think = AntiGravGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_NAIL)
	{
		newmis.touch = NailGrenadeTouch;
		newmis.think = NailGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '0 300 0';
		setmodel (newmis, "progs/biggren.mdl");
	}
	else if (self.weapon == #GR_TYPE_MIRV)
	{
		newmis.touch = MirvGrenadeTouch;
		newmis.think = MirvGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '0 300 0';
		setmodel (newmis, "progs/biggren.mdl");
	}
	else if (self.weapon == #GR_TYPE_NAPALM)
	{
		newmis.touch = NapalmGrenadeTouch;
		newmis.think = NapalmGrenadeExplode;
		newmis.skin = 2;
		newmis.avelocity = '100 300 100';
		setmodel (newmis, "progs/biggren.mdl");
	}
	else if (self.weapon == #GR_TYPE_FLARE)
	{
		newmis.movetype = #MOVETYPE_FLY;
			newmis.touch = FlareGrenadeTouch;
		newmis.think = FlareGrenadeExplode;
		newmis.weapon = #GR_TYPE_FLARE; //WK 6/1/7 Needed for HEAT_SEEKING rox
		newmis.avelocity = '0 0 0'; 	   
			makevectors (user.v_angle);
		newmis.velocity = v_forward;
		newmis.velocity = newmis.velocity * 2000;
		setmodel (newmis, "progs/flarefly.mdl");
		newmis.skin=0;
		newmis.has_holo=0; //flag turned on when explodes
	}
	else if (self.weapon == #GR_TYPE_GAS)
	{
		newmis.touch = GasGrenadeTouch;
		newmis.think = GasGrenadeExplode;
		newmis.skin = 3;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}
	else if (self.weapon == #GR_TYPE_EMP)
	{
		newmis.touch = EMPGrenadeTouch;
		newmis.think = EMPGrenadeExplode;
		newmis.skin = 4;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}
	#ifdef OLD_FLASH
	else if (self.weapon == #GR_TYPE_FLASH)
	{
		newmis.touch = FlashGrenadeTouch;
		newmis.think = FlashGrenadeExplode;
		newmis.skin = 2;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	#else
	else if (self.weapon == #GR_TYPE_PSIONIC)
	{
		newmis.touch = PsionicGrenadeTouch;
		newmis.think = PsionicGrenadeExplode;
		newmis.skin = 2;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	#endif
//WK New Grenades
	else if (self.weapon == #GR_TYPE_FRAG)
	{
		newmis.touch = FragGrenadeTouch;
		newmis.think = FragGrenadeExplode;
		newmis.skin = 0; //WK Green Skin
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_KRAC)
	{
		newmis.touch = KracGrenadeTouch;
		newmis.think = KracGrenadeExplode;
		newmis.skin = 1; //WK Conc skin
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}

	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, user.origin);

	// OfN
	if (self.weapon == #GR_TYPE_FLARE)
	{
	  setorigin (newmis, user.origin + '0 0 16');
	}

	oldself = self;
	self = self.owner;
	self = oldself;

	// Remove primed grenade object 
	dremove(self);
};

//=========================================================================
// Throws a currently primed grenade
void() TeamFortress_ThrowGrenade =
{
	// If no grenade is primed, return
	if (!(self.tfstate & #TFSTATE_GRENPRIMED))
		return;

	//WK Tossing a gren reveals yourself (so people don't spam)
	//if (self.job & #JOB_THIEF && (self.job & #JOB_ACTIVE || self.job & #JOB_FULL_HIDE))
	if (self.job & #JOB_THIEF && self.job & #JOB_FULL_HIDE)
		RevealThief(self,#FALSE);

	self.tfstate = self.tfstate | #TFSTATE_GRENTHROWING;
};

//=========================================================================
// PLAYER CLASS HANDLING FUNCTIONS
//=========================================================================
// Return #TRUE is this class is allowed on this map
float(float pc) IsLegalClass =
{
	local float bit;

	// Spy may be turned off
	if (spy_off == #TRUE && pc == #PC_SPY)
		return #FALSE;

	if (pc == #PC_SCOUT)
		bit = #TF_ILL_SCOUT;
	else if (pc == #PC_SNIPER)
		bit = #TF_ILL_SNIPER;
	else if (pc == #PC_SOLDIER)
		bit = #TF_ILL_SOLDIER;
	else if (pc == #PC_DEMOMAN)
		bit = #TF_ILL_DEMOMAN;
	else if (pc == #PC_MEDIC)
		bit = #TF_ILL_MEDIC;
	else if (pc == #PC_HVYWEAP)
		bit = #TF_ILL_HVYWEP;
	else if (pc == #PC_PYRO)
		bit = #TF_ILL_PYRO;
	else if (pc == #PC_SPY)
		bit = #TF_ILL_SPY;
	else if (pc == #PC_ENGINEER)
		bit = #TF_ILL_ENGINEER;
	else if (pc == #PC_RANDOM)
//WK	else if (pc == #PC_RANDOM || pc == #PC_CUSTOM) //WK Disabling randompc disables //WK customclass
		bit = #TF_ILL_RANDOMPC;

	if ((illegalclasses & bit) || (TeamFortress_TeamGetIllegalClasses(self.team_no) & bit))
		return #FALSE;

	return #TRUE;
};

//=========================================================================
// Alter the player's Movement based on class
void(entity p) TeamFortress_SetSpeed =
{
	//local string sp;
	local float tf;
	local entity te;

	//stuffcmd(p,"cl_movespeedkey 1\n");

	makeImmune(self,time + 1.1); //WK Don't boot someone decelerating

	// - OfN -//
	//-------------------------------------------------------------------------//
	// STOP THAT SILLY DAMN BUGS, SPY SLIDING ETC.. !!!!!!!!!!!!!!!!!!!!!!!!! -//
	if (p.is_feigning || p.is_haxxxoring || p.is_detpacking || p.is_building)
		p.tfstate = p.tfstate | #TFSTATE_CANT_MOVE;
	//-------------------------------------------------------------------------//

	// Check for any reason why they can't move at all
	if (p.tfstate & #TFSTATE_CANT_MOVE)
	{
		if (#STOP_MOUSE_MOVEMENT == #ON)
		{
			stuffcmd(p,"m_forward 0\n");
			stuffcmd(p,"m_side 0\n");
		}

		p.velocity = '0 0 0';
		stuffcmd(p,"cl_backspeed 0\n");
		stuffcmd(p,"cl_forwardspeed 0\n");
		stuffcmd(p,"cl_sidespeed 0\n");
		p.maxspeed = 0;
		return;
	}
	else
	{
		if (#STOP_MOUSE_MOVEMENT == #ON)
		{
			stuffcmd(p,"m_forward 1\n");
			stuffcmd(p,"m_side 0.8\n");
		}
	}

	// First, get their max class speed
	// WK We don't use this block much any more
	if ( p.playerclass == #PC_SCOUT )
	{p.maxspeed = #PC_SCOUT_MAXSPEED;}
	else if ( p.playerclass == #PC_SNIPER )
	{p.maxspeed = #PC_SNIPER_MAXSPEED;}
	else if ( p.playerclass == #PC_SOLDIER )
	{p.maxspeed = #PC_SOLDIER_MAXSPEED;}
	else if ( p.playerclass == #PC_DEMOMAN )
	{p.maxspeed = #PC_DEMOMAN_MAXSPEED;}
	else if ( p.playerclass == #PC_MEDIC )
	{p.maxspeed = #PC_MEDIC_MAXSPEED;}
	else if ( p.playerclass == #PC_HVYWEAP )
	{p.maxspeed = #PC_HVYWEAP_MAXSPEED;}
	else if ( p.playerclass == #PC_PYRO )
	{p.maxspeed = #PC_PYRO_MAXSPEED;}
	else if ( p.playerclass == #PC_CIVILIAN )
	{p.maxspeed = #PC_CIVILIAN_MAXSPEED;}
	else if ( p.playerclass == #PC_SPY )
	{p.maxspeed = #PC_SPY_MAXSPEED;}
	else if ( p.playerclass == #PC_ENGINEER )
	{p.maxspeed = #PC_ENGINEER_MAXSPEED;}
	else if ( p.playerclass == #PC_UNDEFINED )
	{p.maxspeed = 320;return;}

	else if ( p.playerclass == #PC_CUSTOM )
	{
		p.maxspeed = p.custom_speed;
		if (p.done_custom & #CUSTOM_BUILDING) //We are building a class
			p.maxspeed = 0;
	}

	//1st if we have scuba gear and are underwater, increase speed
	if ((p.tf_items & #NIT_SCUBA) && (p.flags & #FL_INWATER))
		p.maxspeed = p.maxspeed + 200;
	//Fins slow us down out of water
	if ((p.tf_items & #NIT_SCUBA) && !(p.flags & #FL_INWATER))
		p.maxspeed = p.maxspeed - 10; //WK 1-7-7 20

	// 2nd, see if any GoalItems are slowing them down
	tf = 0;
	te = find (world, classname, "item_tfgoal");
	while ((te != world) && (tf == 0))
	{
		if (te.owner == p)
		{
			if (te.goal_activation & #TFGI_SLOW)
			{
				tf = 1;
				p.maxspeed = p.maxspeed / 2;
			}
		}
		te = find(te, classname, "item_tfgoal");
	}

	// 3rd, See if they're tranquilised
	if (p.tfstate & #TFSTATE_TRANQUILISED)
	{
		//WK p.maxspeed = (p.maxspeed / 3) * 2;
		if (p.maxspeed > 170)
			p.maxspeed = 170;
	}
	
	if (p.tfstate & #TFSTATE_C4THROW)
		p.maxspeed = p.maxspeed / 3;

	// 4th, check for leg wounds
	if (p.leg_damage)
	{
		if (p.leg_damage > 9)
			p.leg_damage = 9;

		// reduce speed by 10% per leg wound
		p.maxspeed = (p.maxspeed * ((10 - p.leg_damage) / 10));
	}

	// 5th, if they're a sniper, and they're aiming, their speed must be 60 or less
	//WK Changed to allow aiming at half base leg speed, it's more fun that way.
	if (p.tfstate & #TFSTATE_AIMING)
	{
		if (p.maxspeed > 60)
			p.maxspeed = p.maxspeed / 2;
	}

	// WK 6th, See if they're partially hidden
	//WK 10/10/7 Shadowsprint allows full movement speed while hiding
	if (p.job & #JOB_THIEF)
	{
		if (p.job & #JOB_ACTIVE || p.job & #JOB_FULL_HIDE)
			if (!(p.job & #JOB_EXTRA2))
				p.maxspeed = (p.maxspeed * 3) / 4;
	}

	//WK 7th, Check to see if they are sprinting or recovering
	//Note that tired is both ACTIVE and TIRED
	if (p.job & #JOB_RUNNER) {
		if (p.job & #JOB_TIRED)
			p.maxspeed = 2 * p.maxspeed / 3;
		else if (p.job & #JOB_ACTIVE)
			p.maxspeed = p.maxspeed + 200;
	}

	//WK Check to see if we're psionically carrying something
	if (p.job & #JOB_PSION && p.job & #JOB_ACTIVE)
		p.maxspeed = p.maxspeed / 2;

	// OfN - Speed aura miltiplies our final speed
	if (p.aura == #AURA_SPEED)
		p.maxspeed = p.maxspeed * #SPEEDAURA_FACTOR;

	// OfN - Speed rune muliplies our speed too
	if (p.#runes & #RUNE_SPEED)
		p.maxspeed = p.maxspeed * #SPEEDRUNE_FACTOR;

	// OfN - Finally, the psionic stuff
	/* WK 1-7-7 Psionic grenades no longer slow
	if (p.tfstate & #TFSTATE_PSIONIZED)
		p.maxspeed = p.maxspeed * #PSIONIC_MOVEFACTOR;
	*/

	// WK See if they are ass cannoning WK 2/26/7 -- Slowed down 
	// WK 2/8/7 We allow ass cannons to move now, slowly
	if (p.button0 && p.current_weapon == #WEAP_ASSAULT_CANNON)
	{
		p.maxspeed = p.maxspeed / 3;
	}



	#ifdef QUAKE_WORLD
		stuffcmd(p,"cl_backspeed 1000\n");
		stuffcmd(p,"cl_forwardspeed 1000\n");
		stuffcmd(p,"cl_sidespeed 1000\n");
	#else
		sp = ftos(p.maxspeed);
		stuffcmd(p,"cl_backspeed ");
		stuffcmd(p,sp);
		stuffcmd(p,"\n");
		stuffcmd(p,"cl_forwardspeed ");
		stuffcmd(p,sp);
		stuffcmd(p,"\n");
		sp = ftos(p.maxspeed);
		stuffcmd(p,"cl_sidespeed ");
		stuffcmd(p,sp);
		stuffcmd(p,"\n");
	#endif
};

//=========================================================================
// Set the max_health of a player based on his/her class
void() TeamFortress_SetHealth = 
{
	if ( self.playerclass == #PC_SCOUT )
		self.max_health = #PC_SCOUT_MAXHEALTH;
	else if ( self.playerclass == #PC_SNIPER )
		self.max_health = #PC_SNIPER_MAXHEALTH;
	else if ( self.playerclass == #PC_SOLDIER )
		self.max_health = #PC_SOLDIER_MAXHEALTH;
	else if ( self.playerclass == #PC_DEMOMAN )
		self.max_health = #PC_DEMOMAN_MAXHEALTH;
	else if ( self.playerclass == #PC_MEDIC )
		self.max_health = #PC_MEDIC_MAXHEALTH;
	else if ( self.playerclass == #PC_HVYWEAP )
		self.max_health = #PC_HVYWEAP_MAXHEALTH;
	else if ( self.playerclass == #PC_PYRO )
		self.max_health = #PC_PYRO_MAXHEALTH;
	else if ( self.playerclass == #PC_CIVILIAN )
		self.max_health = #PC_CIVILIAN_MAXHEALTH;
	else if ( self.playerclass == #PC_SPY )
		self.max_health = #PC_SPY_MAXHEALTH;
	else if ( self.playerclass == #PC_ENGINEER )
		self.max_health = #PC_ENGINEER_MAXHEALTH;
	else if ( self.playerclass == #PC_UNDEFINED )
	{
		self.max_health = 1; 
		self.takedamage = 0; // Prevent damage to #PC_UNDEFINED players
	}

	self.health = self.max_health;
};
//==================================================
//CH returns value for skin.  used here and tfortmap.qc
float(entity p) Return_Custom_Skins =
{
	if (p.weapons_carried & #WEAP_SNIPER_RIFLE)
		return #PC_SNIPER;
	else if (p.weapons_carried & #WEAP_ASSAULT_CANNON)
		return #PC_HVYWEAP;
	else if (p.weapons_carried & #WEAP_ROCKET_LAUNCHER)
		return #PC_SOLDIER;
	else if (p.weapons_carried & #WEAP_FLAMETHROWER)
		return #PC_PYRO;
	else if (p.weapons_carried & #WEAP_GRENADE_LAUNCHER)
		return #PC_DEMOMAN;
	else if (p.weapons_carried & #WEAP_MEDIKIT)
		return #PC_MEDIC;
	else if (p.weapons_carried & #WEAP_SPANNER)
		return #PC_ENGINEER;
	else if (p.weapons_carried & #WEAP_NAILGUN)
		return #PC_SCOUT;
	else if (p.job & #JOB_GUERILLA)
		return #PC_DEMOMAN;
	else if (p.custom_speed > 320 || p.job & #JOB_RUNNER)
		return #PC_SCOUT;
	else if (p.cutf_items & #CUTF_SPY_KIT)
		return #PC_SPY;
	else if (p.cutf_items & #CUTF_SENTRYGUN || p.tf_items & #NIT_TESLA)
		return #PC_ENGINEER;
	else
		return #PC_SOLDIER;
};
//=========================================================================
// Set the skin of a player based on his/her class, if Classkin is on
void(entity p) TeamFortress_SetSkin = 
{
	//local string st;

	makeImmune(self,time + 4);
	//self.immune_to_check = time + 4;


	if ((p.cutf_items & #CUTF_SPY_KIT) && p.undercover_skin != 0)
		p.skin = p.undercover_skin;
	else
		p.skin = p.playerclass;

#ifdef QUAKE_WORLD
	if (p.skin != #PC_UNDEFINED)
	{
		stuffcmd(p, "skin ");

	//WK Figure out what Mr.Custom Should look like
		if (p.playerclass == #PC_CUSTOM && p.undercover_skin == 0)
		{
			p.skin = Return_Custom_Skins(p); //CH
		}

		if ( p.team_no == 4)
		{
			if ( p.skin == #PC_SCOUT )
				stuffcmd(p, #TEAM4_SCOUT_SKIN);
			else if ( p.skin == #PC_SNIPER )
				stuffcmd(p, #TEAM4_SNIPER_SKIN);
			else if ( p.skin == #PC_SOLDIER )
				stuffcmd(p, #TEAM4_SOLDIER_SKIN);
			else if ( p.skin == #PC_DEMOMAN )
				stuffcmd(p, #TEAM4_DEMOMAN_SKIN);
			else if ( p.skin == #PC_MEDIC )
				stuffcmd(p, #TEAM4_MEDIC_SKIN);
			else if ( p.skin == #PC_HVYWEAP )
				stuffcmd(p, #TEAM4_HVYWEAP_SKIN);
			else if ( p.skin == #PC_PYRO )
				stuffcmd(p, #TEAM4_PYRO_SKIN);
			else if ( p.skin == #PC_SPY )
				stuffcmd(p, #TEAM4_SPY_SKIN);
			else if ( p.skin == #PC_ENGINEER )
				stuffcmd(p, #TEAM4_ENGINEER_SKIN);
		}
		else if ( p.team_no == 3)
		{
			if ( p.skin == #PC_SCOUT )
				stuffcmd(p, #TEAM3_SCOUT_SKIN);
			else if ( p.skin == #PC_SNIPER )
				stuffcmd(p, #TEAM3_SNIPER_SKIN);
			else if ( p.skin == #PC_SOLDIER )
				stuffcmd(p, #TEAM3_SOLDIER_SKIN);
			else if ( p.skin == #PC_DEMOMAN )
				stuffcmd(p, #TEAM3_DEMOMAN_SKIN);
			else if ( p.skin == #PC_MEDIC )
				stuffcmd(p, #TEAM3_MEDIC_SKIN);
			else if ( p.skin == #PC_HVYWEAP )
				stuffcmd(p, #TEAM3_HVYWEAP_SKIN);
			else if ( p.skin == #PC_PYRO )
				stuffcmd(p, #TEAM3_PYRO_SKIN);
			else if ( p.skin == #PC_SPY )
				stuffcmd(p, #TEAM3_SPY_SKIN);
			else if ( p.skin == #PC_ENGINEER )
				stuffcmd(p, #TEAM3_ENGINEER_SKIN);
		}
		else if ( p.team_no == 2)
		{
			if ( p.skin == #PC_SCOUT )
				stuffcmd(p, #TEAM2_SCOUT_SKIN);
			else if ( p.skin == #PC_SNIPER )
				stuffcmd(p, #TEAM2_SNIPER_SKIN);
			else if ( p.skin == #PC_SOLDIER )
				stuffcmd(p, #TEAM2_SOLDIER_SKIN);
			else if ( p.skin == #PC_DEMOMAN )
				stuffcmd(p, #TEAM2_DEMOMAN_SKIN);
			else if ( p.skin == #PC_MEDIC )
				stuffcmd(p, #TEAM2_MEDIC_SKIN);
			else if ( p.skin == #PC_HVYWEAP )
				stuffcmd(p, #TEAM2_HVYWEAP_SKIN);
			else if ( p.skin == #PC_PYRO )
				stuffcmd(p, #TEAM2_PYRO_SKIN);
			else if ( p.skin == #PC_SPY )
				stuffcmd(p, #TEAM2_SPY_SKIN);
			else if ( p.skin == #PC_ENGINEER )
				stuffcmd(p, #TEAM2_ENGINEER_SKIN);
		}
		else // if ( p.team_no == 1)
		{
			if ( p.skin == #PC_SCOUT )
				stuffcmd(p, #TEAM1_SCOUT_SKIN);
			else if ( p.skin == #PC_SNIPER )
				stuffcmd(p, #TEAM1_SNIPER_SKIN);
			else if ( p.skin == #PC_SOLDIER )
				stuffcmd(p, #TEAM1_SOLDIER_SKIN);
			else if ( p.skin == #PC_DEMOMAN )
				stuffcmd(p, #TEAM1_DEMOMAN_SKIN);
			else if ( p.skin == #PC_MEDIC )
				stuffcmd(p, #TEAM1_MEDIC_SKIN);
			else if ( p.skin == #PC_HVYWEAP )
				stuffcmd(p, #TEAM1_HVYWEAP_SKIN);
			else if ( p.skin == #PC_PYRO )
				stuffcmd(p, #TEAM1_PYRO_SKIN);
			else if ( p.skin == #PC_SPY )
				stuffcmd(p, #TEAM1_SPY_SKIN);
			else if ( p.skin == #PC_ENGINEER )
				stuffcmd(p, #TEAM1_ENGINEER_SKIN);
		}

		if ( p.skin == #PC_CIVILIAN )
			stuffcmd(p, "base\n"); // Need a civilian skin
	}
	else
	{
		stuffcmd(p, "skin base\n"); //WK Need a custom skin, or fake it
	}
#endif
};

//=========================================================================
// Set the details of a player based on his/her class
void() TeamFortress_SetEquipment =
{
	local entity te;
	local entity automan;
	local string st;
	local float kept_items;

	if (self.classname != "player")
		return;

	kept_items = self.tf_items & (#IT_KEY1 | #IT_KEY2);
	
	if (self.playerclass != #PC_CUSTOM) { //WK -----v
		self.items = 0;
		self.current_weapon = 0;
		self.weapons_carried = 0;

		self.armorclass = 0;

		self.ammo_medikit = 0;
		self.maxammo_medikit = 0;
		self.ammo_detpack = 0;
		self.ammo_c4det = 0;
		self.maxammo_detpack = 0;
		self.items_allowed = 0;
		self.armor_allowed = 0;
		self.gravity = 1;
		self.maxarmor = 0;
		self.weaponmode = 0;
		self.tf_items = 0;
		self.tf_items_flags = 0;
		self.cutf_items = 0;
		self.cutf2_items = 0;
		self.done_custom = 0;

		//Clear job without losing track of demons, etc.
		self.job = self.job - (self.job & (#JOB_ALL|#JOB_EXTRA1|#JOB_EXTRA2));
	}
 //WK ------^
		
	self.hover_time = 0;
	if (self.tf_items & #NIT_HOVER_BOOTS)
		self.hover_time = #MAX_HOVER_FUEL; //10 secs of hovering or so
	self.respawn_time = 0;
	self.heat = 0;
	self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_RELOADING);
	if (self.tf_items & #NIT_SCUBA) //WK We're a scuba commando!
	{
		self.items = self.items | #IT_SUIT;
		self.rad_time = 1;
		self.tfstate = self.tfstate | #TFSTATE_RADSUIT;
		self.radsuit_finished = time + 666;
	}
	else
	{
		self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_RADSUIT);
		self.items = 0;
		self.rad_time = 0;
		self.radsuit_finished = 0;
	}
	self.undercover_skin = 0;
	if (self.undercover_team != 0)
	{
		makeImmune(self,time + 4);
		//self.immune_to_check = time + 4;

		self.undercover_team = 0;
		// Set their color 
		stuffcmd(self, "color ");
		st = ftos(TeamFortress_TeamGetColor(self.team_no) - 1);
		 //- OfN - Nice colors
		if (nicecolors==1) st =TeamGetNiceColor(self.team_no);

		stuffcmd(self, st);
		stuffcmd(self, "\n");
	}

	self.is_building = 0;
	self.is_toffingadet = 0;
	self.is_haxxxoring = 0;
	self.is_detpacking = 0;
	self.is_undercover = 0;
	self.is_feigning = 0;
	self.is_unabletospy = 0;
	self.is_malfunctioning = 0;
	self.is_abouttodie = 0; // reset preventing automartyr flag
	
	self.impulse = 0;

	if (self.team_no == 0)
		self.lives = -1;

	self.items = self.items | kept_items;

	// Start the Cheat-Checking Cyclic Event if CheatChecking Toggleflag is on
	if (!stof(infokey(world,"nospeed")) && (toggleflags&#TFLAG_CHEATCHECK))
	{
		te = spawn(); //Cyto
		te.nextthink = time + 2;
		te.think = TeamFortress_CheckForSpeed;
		te.owner = self;
		te.classname = "timer";
	}

	//WK -- Remove flags for job state
	self.job = self.job - (self.job & #JOB_ACTIVE);
	self.job = self.job - (self.job & #JOB_FULL_HIDE);
	self.job = self.job - (self.job & #JOB_TIRED);
	//self.job = self.job - (self.job & #JOB_MARTYR_ENEMY);
	self.job_finished = time;
	self.martyr_enemy = self; // reset martyr enemy
	self.stored_deathmsg = 0; // reset stored death message

	if ( self.playerclass == #PC_CUSTOM ) //WK - Reset the custom class
	{
		/*self.no_grenades_1 = GetMaxGrens(self,1);
		self.no_grenades_2 = GetMaxGrens(self,2);*/ //done at the end of this func

		if (self.tf_items & #NIT_AMMO_BANDOLIER)
		{
			self.ammo_rockets = self.maxammo_rockets / 2;
			self.ammo_nails = (3 * self.maxammo_nails) / 4;
			self.ammo_shells = (3 * self.maxammo_shells) / 4;
			self.ammo_cells = (2 * self.maxammo_cells) / 3; 		
		}
		else
		{
			self.ammo_rockets = self.maxammo_rockets / 4;
			self.ammo_nails = self.maxammo_nails / 2;
			self.ammo_shells = self.maxammo_shells / 2;
			self.ammo_cells = self.maxammo_cells / 2;
		}
		self.ammo_detpack = self.maxammo_detpack;
		self.ammo_c4det = self.maxammo_detpack;
		self.ammo_medikit = self.maxammo_medikit;
		if (self.ammo_medikit > 0 && self.weapons_carried & #WEAP_MEDIKIT) {
			te = spawn();
			te.nextthink = time + #PC_MEDIC_REGEN_TIME;
			te.think = TeamFortress_Regenerate;
			te.owner = self;
			te.classname = "timer";
		}
		if (self.cutf_items & #CUTF_CYBERAUG)
		{
			te = spawn();
			te.nextthink = time + #PC_MEDIC_REGEN_TIME;
			te.think = TeamFortress_RegenerateCyber;
			te.owner = self;
			te.classname = "timer";
		}

		// SB only need to activate this with skill
		/*if (self.job & #JOB_THIEF)
		{
			te = spawn();
			te.nextthink = time + #PC_SPY_CELL_REGEN_TIME;
			te.think = TeamFortress_RegenerateCells;
			te.owner = self;
			te.classname = "timer";
		} */
	
		if (self.cutf_items & #CUTF_FULLARMOUR)
			self.armorvalue = self.maxarmor;
		else
			self.armorvalue = self.maxarmor / 2;
		self.armortype = self.armor_allowed; //Start with red if red's allowed
		self.armorclass = 0; //Default to no special armor type
		if (self.tf_items & #NIT_KEVLAR)
			self.armorclass = self.armorclass | #AT_SAVESHOT;
		if (self.tf_items & #NIT_GEL)
			self.armorclass = self.armorclass | #AT_SAVEMELEE;
		if (self.tf_items & #NIT_BLAST)
			self.armorclass = self.armorclass | #AT_SAVEEXPLOSION;
		if (self.tf_items & #NIT_CERAMIC)
			self.armorclass = self.armorclass | #AT_SAVEELECTRICITY;
		if (self.tf_items & #NIT_ASBESTOS) //Buying flamer gives this
			self.armorclass = self.armorclass | #AT_SAVEFIRE;

		//Support for the "Auto" class itemry
		//WK 6/1/7 Added Psion auto-uncover timer
		if (self.tf_items & #NIT_AUTOSCANNER || self.weapons_carried & #WEAP_MEDIKIT || self.tf_items & #NIT_AUTOID || self.job & #JOB_PSION) {
				automan = spawn ();
				automan.classname = "timer";
				automan.nextthink = time + 2;
				automan.think = Autoitem_think;
				automan.owner = self;
				automan.enemy = self;
		}

		self.current_weapon = W_BestWeapon ();
		//#ifdef CUSTOM_PC_ITEMS_PLAYING
		UpdateWeaponItems();
		//#endif
	}
	else if ( self.playerclass == #PC_SCOUT )
	{
		self.weapons_carried = self.weapons_carried | #PC_SCOUT_WEAPONS;
		self.ammo_rockets = #PC_SCOUT_INITAMMO_ROCKET;
		self.ammo_nails = #PC_SCOUT_INITAMMO_NAIL;
		self.ammo_shells = #PC_SCOUT_INITAMMO_SHOT;
		self.ammo_cells = #PC_SCOUT_INITAMMO_CELL;
		self.maxammo_rockets = #PC_SCOUT_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_SCOUT_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_SCOUT_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_SCOUT_MAXAMMO_CELL;

		self.no_grenades_1 = #PC_SCOUT_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_SCOUT_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_SCOUT_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_SCOUT_GRENADE_TYPE_2;
		self.tf_items = #PC_SCOUT_TF_ITEMS;
		self.cutf_items = #PC_SCOUT_CUTFITEMS;
		self.job = self.job | #PC_SCOUT_JOB;

		// the scanner defaults to enemy scanning ON, friendly scanning OFF
		// and movement scanner only OFF
		self.tf_items_flags = self.tf_items_flags | #NIT_SCANNER_ENEMY;

		self.armorclass = self.armorclass | #PC_SCOUT_INITARMORCLASS;
		self.armortype = #PC_SCOUT_INITARMORTYPE;
		self.armorvalue = #PC_SCOUT_INITARMOR;
		self.armor_allowed = #PC_SCOUT_MAXARMORTYPE;
		self.maxarmor = #PC_SCOUT_MAXARMOR;
		self.current_weapon = #WEAP_NAILGUN;

		self.items_allowed = #PC_SCOUT_WEAPONS;
		//kill_my_demons();

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_NAILGUN;
	}
	else if ( self.playerclass == #PC_SNIPER )
	{
		self.weapons_carried = self.weapons_carried | #PC_SNIPER_WEAPONS;
		self.ammo_rockets = #PC_SNIPER_INITAMMO_ROCKET;
		self.ammo_nails = #PC_SNIPER_INITAMMO_NAIL;
		self.ammo_shells = #PC_SNIPER_INITAMMO_SHOT;
		self.ammo_cells = #PC_SNIPER_INITAMMO_CELL;
		self.maxammo_rockets = #PC_SNIPER_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_SNIPER_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_SNIPER_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_SNIPER_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_SNIPER_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_SNIPER_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_SNIPER_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_SNIPER_GRENADE_TYPE_2;
		self.tf_items = #PC_SNIPER_TF_ITEMS;
		self.job = self.job | #PC_SNIPER_JOB;

		self.armorclass = self.armorclass | #PC_SNIPER_INITARMORCLASS;
		self.armortype = #PC_SNIPER_INITARMORTYPE;
		self.armorvalue = #PC_SNIPER_INITARMOR;
		self.armor_allowed = #PC_SNIPER_MAXARMORTYPE;
		self.maxarmor = #PC_SNIPER_MAXARMOR;
		self.current_weapon = #WEAP_SNIPER_RIFLE;

		self.items_allowed = #PC_SNIPER_WEAPONS;
		self.cutf_items = #PC_SNIPER_CUTF_ITEMS; // OFN -OTR

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_SUPER_SHOTGUN | #IT_NAILGUN;
		//kill_my_demons();
	}
	else if ( self.playerclass == #PC_SOLDIER )
	{
		self.weapons_carried = self.weapons_carried | #PC_SOLDIER_WEAPONS;
		self.ammo_rockets = #PC_SOLDIER_INITAMMO_ROCKET;
		self.ammo_nails = #PC_SOLDIER_INITAMMO_NAIL;
		self.ammo_shells = #PC_SOLDIER_INITAMMO_SHOT;
		self.ammo_cells = #PC_SOLDIER_INITAMMO_CELL;
		self.maxammo_rockets = #PC_SOLDIER_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_SOLDIER_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_SOLDIER_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_SOLDIER_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_SOLDIER_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_SOLDIER_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_SOLDIER_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_SOLDIER_GRENADE_TYPE_2;
		self.tf_items = #PC_SOLDIER_TF_ITEMS;
		self.job = self.job | #PC_SOLDIER_JOB;

		self.armorclass = self.armorclass | #PC_SOLDIER_INITARMORCLASS;
		self.armortype = #PC_SOLDIER_INITARMORTYPE;
		self.armorvalue = #PC_SOLDIER_INITARMOR;
		self.armor_allowed = #PC_SOLDIER_MAXARMORTYPE;
		self.maxarmor = #PC_SOLDIER_MAXARMOR;
		self.current_weapon = #WEAP_ROCKET_LAUNCHER;

		self.items_allowed = #PC_SOLDIER_WEAPONS;

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_SUPER_SHOTGUN | #IT_ROCKET_LAUNCHER;
		//kill_my_demons();
	}
	else if ( self.playerclass == #PC_DEMOMAN )
	{
		self.weapons_carried = self.weapons_carried | #PC_DEMOMAN_WEAPONS;
		self.ammo_rockets = #PC_DEMOMAN_INITAMMO_ROCKET;
		self.ammo_nails = #PC_DEMOMAN_INITAMMO_NAIL;
		self.ammo_shells = #PC_DEMOMAN_INITAMMO_SHOT;
		self.ammo_cells = #PC_DEMOMAN_INITAMMO_CELL;
		self.maxammo_rockets = #PC_DEMOMAN_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_DEMOMAN_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_DEMOMAN_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_DEMOMAN_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_DEMOMAN_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_DEMOMAN_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_DEMOMAN_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_DEMOMAN_GRENADE_TYPE_2;
		self.tf_items = #PC_DEMOMAN_TF_ITEMS;
		self.job = self.job | #PC_DEMOMAN_JOB;
		self.cutf_items = #PC_DEMOMAN_CUTFITEMS;

		// Detpacks
		self.ammo_detpack = #PC_DEMOMAN_INITAMMO_DETPACK;
		self.maxammo_detpack = #PC_DEMOMAN_MAXAMMO_DETPACK;

		self.armorclass = self.armorclass | #PC_DEMOMAN_INITARMORCLASS;
		self.armortype = #PC_DEMOMAN_INITARMORTYPE;
		self.armorvalue = #PC_DEMOMAN_INITARMOR;
		self.armor_allowed = #PC_DEMOMAN_MAXARMORTYPE;
		self.maxarmor = #PC_DEMOMAN_MAXARMOR;
		self.current_weapon = #WEAP_GRENADE_LAUNCHER;
		//kill_my_demons();

		self.ammo_c4det = 1; // - OfN

		self.items_allowed = #PC_DEMOMAN_WEAPONS;

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_GRENADE_LAUNCHER;
	}
	else if ( self.playerclass == #PC_MEDIC )
	{
		self.weapons_carried = self.weapons_carried | #PC_MEDIC_WEAPONS;
		self.ammo_rockets = #PC_MEDIC_INITAMMO_ROCKET;
		self.ammo_nails = #PC_MEDIC_INITAMMO_NAIL;
		self.ammo_shells = #PC_MEDIC_INITAMMO_SHOT;
		self.ammo_cells = #PC_MEDIC_INITAMMO_CELL;
		self.maxammo_rockets = #PC_MEDIC_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_MEDIC_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_MEDIC_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_MEDIC_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_MEDIC_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_MEDIC_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_MEDIC_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_MEDIC_GRENADE_TYPE_2;
		self.tf_items = #PC_MEDIC_TF_ITEMS;
		self.job = self.job | #PC_MEDIC_JOB;

		self.armorclass = self.armorclass | #PC_MEDIC_INITARMORCLASS;
		self.armortype = #PC_MEDIC_INITARMORTYPE;
		self.armorvalue = #PC_MEDIC_INITARMOR;
		self.armor_allowed = #PC_MEDIC_MAXARMORTYPE;
		self.maxarmor = #PC_MEDIC_MAXARMOR;
		self.current_weapon = #WEAP_LIGHT_ASSAULT;

		self.ammo_medikit = #PC_MEDIC_INITAMMO_MEDIKIT;
		self.maxammo_medikit = #PC_MEDIC_MAXAMMO_MEDIKIT;

		// Start the Regeneration Cyclic Event
		te = spawn();
		te.nextthink = time + #PC_MEDIC_REGEN_TIME;
		te.think = TeamFortress_Regenerate;
		te.owner = self;
		te.classname = "timer";

		self.items_allowed = #PC_MEDIC_WEAPONS;

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_SUPER_SHOTGUN | #IT_LIGHT_ASSAULT;
		//kill_my_demons();
	}
	else if ( self.playerclass == #PC_HVYWEAP )
	{
		self.weapons_carried = self.weapons_carried | #PC_HVYWEAP_WEAPONS;
		self.ammo_rockets = #PC_HVYWEAP_INITAMMO_ROCKET;
		self.ammo_nails = #PC_HVYWEAP_INITAMMO_NAIL;
		self.ammo_shells = #PC_HVYWEAP_INITAMMO_SHOT;
		self.ammo_cells = #PC_HVYWEAP_INITAMMO_CELL;
		self.maxammo_rockets = #PC_HVYWEAP_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_HVYWEAP_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_HVYWEAP_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_HVYWEAP_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_HVYWEAP_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_HVYWEAP_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_HVYWEAP_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_HVYWEAP_GRENADE_TYPE_2;
		self.tf_items = #PC_HVYWEAP_TF_ITEMS;
		self.job = self.job | #PC_HVYWEAP_JOB;

		self.armorclass = self.armorclass | #PC_HVYWEAP_INITARMORCLASS;
		self.armortype = #PC_HVYWEAP_INITARMORTYPE;
		self.armorvalue = #PC_HVYWEAP_INITARMOR;
		self.armor_allowed = #PC_HVYWEAP_MAXARMORTYPE;
		self.maxarmor = #PC_HVYWEAP_MAXARMOR;
		self.current_weapon = #WEAP_SUPER_SHOTGUN;
		self.cutf_items = #CUTF_HWGUY;

		self.items_allowed = #PC_HVYWEAP_WEAPONS;

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_SUPER_SHOTGUN | #IT_ROCKET_LAUNCHER;
		//kill_my_demons();
	}
	else if ( self.playerclass == #PC_PYRO )
	{
		self.weapons_carried = self.weapons_carried | #PC_PYRO_WEAPONS;
		self.ammo_rockets = #PC_PYRO_INITAMMO_ROCKET;
		self.ammo_nails = #PC_PYRO_INITAMMO_NAIL;
		self.ammo_shells = #PC_PYRO_INITAMMO_SHOT;
		self.ammo_cells = #PC_PYRO_INITAMMO_CELL;
		self.maxammo_rockets = #PC_PYRO_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_PYRO_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_PYRO_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_PYRO_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_PYRO_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_PYRO_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_PYRO_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_PYRO_GRENADE_TYPE_2;
		self.tf_items = #PC_PYRO_TF_ITEMS;
		self.job = self.job | #PC_PYRO_JOB;

		self.armorclass = self.armorclass | #PC_PYRO_INITARMORCLASS;
		self.armortype = #PC_PYRO_INITARMORTYPE;
		self.armorvalue = #PC_PYRO_INITARMOR;
		self.armor_allowed = #PC_PYRO_MAXARMORTYPE;
		self.maxarmor = #PC_PYRO_MAXARMOR;
		self.current_weapon = #WEAP_FLAMETHROWER;
		self.items_allowed = #PC_PYRO_WEAPONS;
		//kill_my_demons();

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_GRENADE_LAUNCHER | #IT_ROCKET_LAUNCHER;
	}
	else if ( self.playerclass == #PC_CIVILIAN )
	{
		self.weapons_carried = self.weapons_carried | #PC_CIVILIAN_WEAPONS;
		self.ammo_rockets = #PC_CIVILIAN_INITAMMO_ROCKET;
		self.ammo_nails = #PC_CIVILIAN_INITAMMO_NAIL;
		self.ammo_shells = #PC_CIVILIAN_INITAMMO_SHOT;
		self.ammo_cells = #PC_CIVILIAN_INITAMMO_CELL;
		self.maxammo_rockets = #PC_CIVILIAN_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_CIVILIAN_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_CIVILIAN_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_CIVILIAN_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_CIVILIAN_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_CIVILIAN_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_CIVILIAN_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_CIVILIAN_GRENADE_TYPE_2;
		self.tf_items = #PC_CIVILIAN_TF_ITEMS;
		self.job = self.job | #PC_CIVILIAN_JOB;

		self.armorclass = self.armorclass | #PC_CIVILIAN_INITARMORCLASS;
		self.armortype = #PC_CIVILIAN_INITARMORTYPE;
		self.armorvalue = #PC_CIVILIAN_INITARMOR;
		self.armor_allowed = #PC_CIVILIAN_MAXARMORTYPE;
		self.maxarmor = #PC_CIVILIAN_MAXARMOR;
		self.current_weapon = #WEAP_AXE;
		self.items_allowed = #PC_CIVILIAN_WEAPONS;
		self.cutf_items = #PC_CIVILIAN_CUTFITEMS;

		// set the weapon icons on the status bar
		self.items = 0;
		//kill_my_demons();
	}
	else if ( self.playerclass == #PC_SPY )
	{
		self.weapons_carried = self.weapons_carried | #PC_SPY_WEAPONS;
		self.ammo_rockets = #PC_SPY_INITAMMO_ROCKET;
		self.ammo_nails = #PC_SPY_INITAMMO_NAIL;
		self.ammo_shells = #PC_SPY_INITAMMO_SHOT;
		self.ammo_cells = #PC_SPY_INITAMMO_CELL;
		self.maxammo_rockets = #PC_SPY_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_SPY_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_SPY_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_SPY_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_SPY_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_SPY_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_SPY_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_SPY_GRENADE_TYPE_2;
		self.tf_items = #PC_SPY_TF_ITEMS;
		self.job = self.job | #PC_SPY_JOB;

		self.armorclass = self.armorclass | #PC_SPY_INITARMORCLASS;
		self.armortype = #PC_SPY_INITARMORTYPE;
		self.armorvalue = #PC_SPY_INITARMOR;
		self.armor_allowed = #PC_SPY_MAXARMORTYPE;
		self.maxarmor = #PC_SPY_MAXARMOR;
		self.current_weapon = #WEAP_TRANQ;
		self.items_allowed = #PC_SPY_WEAPONS;
		self.cutf_items = #PC_SPY_CUTFITEMS;

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_SUPER_SHOTGUN | #IT_NAILGUN;
		

		// If the Spy only has invis, start the Spy's cell regen timer
		if (invis_only == #TRUE)
		{
			te = spawn();
			te.nextthink = time + #PC_SPY_CELL_REGEN_TIME;
			te.think = TeamFortress_RegenerateCells;
			te.owner = self;
			te.classname = "timer";
		}
	}
	else if ( self.playerclass == #PC_ENGINEER )
	{
		self.weapons_carried = self.weapons_carried | #PC_ENGINEER_WEAPONS;
		self.ammo_rockets = #PC_ENGINEER_INITAMMO_ROCKET;
		self.ammo_nails = #PC_ENGINEER_INITAMMO_NAIL;
		self.ammo_shells = #PC_ENGINEER_INITAMMO_SHOT;
		self.ammo_cells = #PC_ENGINEER_INITAMMO_CELL;
		self.maxammo_rockets = #PC_ENGINEER_MAXAMMO_ROCKET;
		self.maxammo_nails = #PC_ENGINEER_MAXAMMO_NAIL;
		self.maxammo_shells = #PC_ENGINEER_MAXAMMO_SHOT;
		self.maxammo_cells = #PC_ENGINEER_MAXAMMO_CELL;
	
		self.no_grenades_1 = #PC_ENGINEER_GRENADE_INIT_1;
		self.no_grenades_2 = #PC_ENGINEER_GRENADE_INIT_2;
		self.tp_grenades_1 = #PC_ENGINEER_GRENADE_TYPE_1;
		self.tp_grenades_2 = #PC_ENGINEER_GRENADE_TYPE_2;
		self.tf_items = #PC_ENGINEER_TF_ITEMS;
		self.job = self.job | #PC_ENGINEER_JOB;

		self.armorclass = self.armorclass | #PC_ENGINEER_INITARMORCLASS;
		self.armortype = #PC_ENGINEER_INITARMORTYPE;
		self.armorvalue = #PC_ENGINEER_INITARMOR;
		self.armor_allowed = #PC_ENGINEER_MAXARMORTYPE;
		self.maxarmor = #PC_ENGINEER_MAXARMOR;
		self.current_weapon = #WEAP_RAILGUN;
		self.items_allowed = #PC_ENGINEER_WEAPONS;
		self.cutf_items = #PC_ENGINEER_CUTFITEMS;

		// set the weapon icons on the status bar
		self.items = self.items | #IT_SHOTGUN | #IT_SUPER_SHOTGUN;
		//kill_my_demons();
	}
	else if ( self.playerclass == #PC_UNDEFINED )
	{
		self.items = 0;
		self.ammo_rockets = 0;
		self.ammo_nails = 0;
		self.ammo_shells = 0;
		self.ammo_cells = 0;

		self.no_grenades_1 = 0;
		self.no_grenades_2 = 0;
		self.tp_grenades_1 = 0;
		self.tp_grenades_2 = 0;
	
		self.armorclass = 0;
		self.armortype = 0;
		self.armorvalue = 0;
		self.weapon = 0;
		self.current_weapon = 0;
		self.weapons_carried = 0;

		self.flags = #FL_CLIENT | #FL_NOTARGET; // | #FL_ONGROUND;
		self.waterlevel = 3;
		self.takedamage = #DAMAGE_NO;
		self.solid = #SOLID_NOT;
		self.movetype = #MOVETYPE_NOCLIP;

		self.model = string_null;
		self.mdl = string_null;
		self.modelindex = 0;
		self.weaponmodel = string_null;
		modelindex_player = 0;
		self.tfstate = self.tfstate | #TFSTATE_RELOADING;
	
		setmodel(self, string_null);
	}	 
	
	/*if (stock_mode==1) //- OfN - Stock classes don't get a job when stock_mode is 1
		self.job=0;*/

	//- OfN - Set initial grens number
	self.no_grenades_1 = GetMaxGrens(self,1);
	self.no_grenades_2 = GetMaxGrens(self,2);	
	
	if (!(self.job & #JOB_ARMY) && !(self.job & #JOB_WARLOCK))
		kill_my_demons();
	
	// Initialize any job stuff if needed
	InitJobStuff();
		
	// Give normal classes the hook
	// Custom classes get it in 'drop into custom class gen'
	if (allow_hook && self.playerclass != #PC_UNDEFINED && self.playerclass != #PC_CUSTOM)
		self.weapons_carried = self.weapons_carried | #WEAP_HOOK;

	// Restore our original items if needed
	if (self.playerclass == #PC_CUSTOM)
		RestoreOriginalItems(self);
	else
		ResetStripedAndGiven(self);
	
	// Remove disallowed items on player, if any
	StripDisallowed(self);
	// Give free items, if any
	GiveFreeStuff(self);
	
	W_SetCurrentAmmo ();
};

//=========================================================================
// Return the max amount of ammo the Retriever can carry, based on his class
float(entity Retriever, float AmmoType) TeamFortress_GetMaxAmmo =
{
	if (AmmoType == #IT_SHELLS)
		return Retriever.maxammo_shells;
	else if (AmmoType == #IT_NAILS)
		return Retriever.maxammo_nails;
	else if (AmmoType == #IT_CELLS)
		return Retriever.maxammo_cells;
	else if (AmmoType == #IT_ROCKETS)
		return Retriever.maxammo_rockets;
	else if (AmmoType == #WEAP_MEDIKIT)
		return Retriever.maxammo_medikit;
	else if (AmmoType == 131072) //WK Used to be #WEAP_DETPACK
		return Retriever.maxammo_detpack;

	RPrint("Error in TeamFortress_GetMaxAmmo()\n");
	RPrint("Invalid ammo type passed.\n");
	return 0;
};

//=========================================================================
// Return 1 if the Retriever is allowed to pick up the Weapon
float(entity Retriever, float WeaponType) TeamFortress_CanGetWeapon =
{
	if ( Retriever.items_allowed & WeaponType )
		return #TRUE;

	return #FALSE;
};


//=========================================================================
// Print a string to Player, describing this type of armor
//CH returns number effected
float(entity Player, float Armorclass) TeamFortress_DescribeArmor =
{
	//local string st;
	local float num;
	num = 0;
	if (Armorclass == 0)
		return num;

	if (Armorclass & #AT_SAVEFIRE) {
		sprint (Player, #PRINT_HIGH, "Asbestos ");
		num = num + 1;
	}
	if (Armorclass & #AT_SAVEEXPLOSION) {
		sprint (Player, #PRINT_HIGH, "Blast ");
		num = num + 1;
	}
	if (Armorclass & #AT_SAVEELECTRICITY) {
		sprint (Player, #PRINT_HIGH, "Ceramic ");
		num = num + 1;
	}
	if (Armorclass & #AT_SAVEMELEE) {
		sprint (Player, #PRINT_HIGH, "Gel ");
		num = num + 1;
	}
	if (Armorclass & #AT_SAVESHOT) {
		sprint (Player, #PRINT_HIGH, "Kevlar ");
		num = num + 1;
	}

	sprint (Player, #PRINT_HIGH, "armor");
	return num;
};

//=========================================================================
// Controls the equipment a class receives from backpacks
float(entity Retriever, entity Items) TeamFortress_AddBackpackItems =
{
	// If you want the classes to _not_ start off with all their legal
	// weapons, then you may want them to be able to pick up weapons
	// from backpacks. If so, this is where to do it.
	// For now, return. 
	return;
};

//=========================================================================
// Return a string containing the class name for pc
string(float pc) TeamFortress_GetClassName =
{
	if ( pc == #PC_SCOUT )
		return "Scout";
	else if ( pc == #PC_SNIPER )
		return "Sniper";
	else if ( pc == #PC_SOLDIER )
		return "Soldier";
	else if ( pc == #PC_DEMOMAN )
		return "Demolitions Man";
	else if ( pc == #PC_MEDIC )
		return "Combat Medic";
	else if ( pc == #PC_HVYWEAP )
		return "Heavy Weapons Guy";
	else if ( pc == #PC_PYRO )
		return "Pyro";
	else if ( pc == #PC_SPY )
		return "Spy";
	else if ( pc == #PC_ENGINEER )
		return "Engineer";
	else if ( pc == #PC_CIVILIAN )
		return "Civilian";
	else if ( pc == #PC_UNDEFINED )
		return "Observer";
	else if ( pc == #PC_RANDOM)
		return "Random Playerclass";
	else if ( pc == #PC_CUSTOM)
		return "Custom Playerclass";
};

//=========================================================================
// Return a string containing the class name for pc
string(float pc) TeamFortress_GetJobName =
{
	if ( pc & #JOB_THIEF )
		return "Thief";
	else if ( pc & #JOB_RUNNER )
		return "Runner";
	else if ( pc & #JOB_WARLOCK )
		return "Warlock";
	else if ( pc & #JOB_CHAPLAN )
		return "Combat Chaplan";
	else if ( pc & #JOB_BERSERKER )
		return "Nordish Berserker";
	else if ( pc & #JOB_GUERILLA )
		return "Communist Rebel";
	else if ( pc & #JOB_JUDOKA )
		return "Judo Black Belt";
	else if ( pc & #JOB_ARMY )
		return "Army Officer";
	else if ( pc & #JOB_HACKER )
		return "Hacker";
	else if ( pc & #JOB_MARTYR )
		return "Martyr";
	else if ( pc & #JOB_CRUSADER )
		return "Crusader";
	else if ( pc & #JOB_TKD)
		return "Taekwondo Black Belt";
	else if ( pc & #JOB_PSION)
		return "Psychic Warrior";
	else
		return "Custom Playerclass";
};

//=========================================================================
// Display the class of Player to Viewer
void(entity Viewer, float pc, float rpc) TeamFortress_PrintClassName =
{
	local string st;
	st = TeamFortress_GetClassName(pc);
	sprint (Viewer, #PRINT_HIGH, st);

	if (rpc != 0)
		sprint (Viewer, #PRINT_HIGH, " (Random)");
	sprint (Viewer, #PRINT_HIGH, "\n");
};

//=========================================================================
// Display the job of a custom class to Viewer
void(entity Viewer, float pc) TeamFortress_PrintJobName =
{
	local string st;
	st = TeamFortress_GetJobName(pc);
	sprint (Viewer, #PRINT_HIGH, st);
	sprint (Viewer, #PRINT_HIGH, "\n");
};

//=========================================================================
// Say the class of Player to him/her
#ifdef SPEECH
void(entity player) TeamFortress_SayClassName =
{
	if ( player.playerclass == #PC_SCOUT )
		stuffcmd(player, "play speech/scout.wav\n");
	else if ( player.playerclass == #PC_SNIPER )
		stuffcmd(player, "play speech/sniper.wav\n");
	else if ( player.playerclass == #PC_SOLDIER )
		stuffcmd(player, "play speech/soldier.wav\n");
	else if ( player.playerclass == #PC_DEMOMAN )
		stuffcmd(player, "play speech/demoman.wav\n");
	else if ( player.playerclass == #PC_MEDIC )
		stuffcmd(player, "play speech/medic.wav\n");
	else if ( player.playerclass == #PC_HVYWEAP )
		stuffcmd(player, "play speech/hvyweap.wav\n");
	else if ( player.playerclass == #PC_PYRO )
		stuffcmd(player, "play speech/pyro.wav\n");
	else if ( player.playerclass == #PC_SPY )
		stuffcmd(player, "play speech/spy.wav\n");
	else if ( player.playerclass == #PC_ENGINEER )
		stuffcmd(player, "play speech/engineer.wav\n");
	else if ( player.playerclass == #PC_CIVILIAN )
		stuffcmd(player, "play speech/civilian.wav\n");
};
#endif

//=========================================================================
// Remove all the timers for this player
// This function is _always_ called when a player dies.
void() TeamFortress_RemoveTimers =
{
	local entity te;
	local entity oself;

	self.leg_damage = 0;
	self.is_undercover = 0;
	self.is_building = 0;
	self.building = world;

	//CH - TOFIX: IS THIS WHAT CAUSES GRENS TO BE TRHOWN AFTER RESPAWNING??
	//stuffcmd (self, "throwgren\n"); //Throw any grenades
	TeamFortress_ThrowGrenade();

	if (self.tfstate & #TFSTATE_GRENTHROWING)
	{
		oself = self;

		te = find(world,classname,"grenade");

		while (te)
		{
			if (te.owner == oself)
			if (te.think == TeamFortress_GrenadePrimed)
			{
				self = te;
				TeamFortress_GrenadePrimed();
			}

			te = find(te,classname,"grenade");
		}

		self = oself;
	}
	//stuffcmd (self, "impulse 169\n"); //Stop laying dets

	TeamFortress_DetpackStop(#FALSE);

	// Clear the sniper's aiming
	if (self.tfstate & #TFSTATE_AIMING)
	{
		self.tfstate = self.tfstate - #TFSTATE_AIMING;
		TeamFortress_SetSpeed(self);
		self.heat = 0;
	}

	// Remove all the timer entities for this player
	te = find(world, classname, "timer");
	while (te != world)
	{
		//WK Judokatimer is a little weird
		if (te.netname == "judokatimer" && te.think == JudokaRearm)
		{
			if (te.owner == self || te.enemy == self)
			{
				oself = self;
				self = te;
				self.think();
				self = oself;
				te.think = SUB_Remove;
				te.nextthink = time + 0.1;
			}
			te = find(te, classname, "timer");
		}
		else if (te.netname == "haulingtimer") { //Or we can clean up the psion timer directly.
			if (te.owner == self) {
				//Clear active flag, which will make the timer drop the item without blowing
				//self.job = self.job - (self.job & #JOB_ACTIVE);
				self.job = self.job | #JOB_TIRED; //Force the drop
				oself = self;
				self = te;
				if (self.think != SUB_Remove)
					self.think();
				self = oself;
				te.think = SUB_Remove;
				te.nextthink = time + 0.01;
			}
			te = find(te, classname, "timer");
		}
		else if (te.owner == self)
		{
			//WK Fix our new little flash timer
			if (te.netname == "flashtimer")
			{
				self.FlashTime = 0;
				stuffcmd(self, "v_cshift 0\n");
				stuffcmd(self, "r_norefresh 0;wait;echo;wait;echo;wait;echo;wait;echo\n");
				dremove(te);
				te = find(world, classname, "timer");
			}
			//WK Support for the curse timer
			else if (te.netname == "bastardtimer")
			{
				if (self.is_connected == #FALSE)
				{
					dremove(te);
					te = find(world, classname, "timer");
				}
				else 
					te = find(te, classname, "timer");
			}
			else if (te.netname == "alias") // Ignore alias timer
			{
				// do nothing, just skip it (IT MUST NOT BE REMOVED EVER)
				te = find(te, classname, "timer");
			}
			else
			{
				dremove(te);
				te = find(world, classname, "timer");
			}
		}
		else
			te = find(te, classname, "timer");
	}

	// Drop any GoalItems
	te = find (world, classname, "item_tfgoal");
	while (te)
	{
		if (te.owner == self)
		{
			// Remove it from the player, if it is supposed to be
			if (!(te.goal_activation & #TFGI_KEEP))
			{
				tfgoalitem_RemoveFromPlayer(te, self, 0);
			}

			// CTF support
			if (CTF_Map == #TRUE && te.goal_no == #CTF_FLAG1)
			{
				bprint(#PRINT_HIGH, self.netname);
				bprint(#PRINT_HIGH, " ΜΟΣΤ the ΒΜΥΕ flag!\n");
			}
			else if (CTF_Map == #TRUE && te.goal_no == #CTF_FLAG2)
			{
				bprint(#PRINT_HIGH, self.netname);
				bprint(#PRINT_HIGH, " ΜΟΣΤ the ÒΕΔ flag!\n");
			}

		}
		te = find(te, classname, "item_tfgoal");
	}

	// Reset detpacks being disarmed to not being disarmed
	te = find (world, classname, "detpack");
	while (te)
	{
		if ((te.weaponmode == 1) && (te.enemy == self))
		{
			te.weaponmode = 0;
		}
		te = find(te, classname, "detpack");
	}

	// detonate all of the players pipebombs
	TeamFortress_DetonatePipebombs();

	// OfN Remove holo if player dies! 
	if (self.has_holo > 0) RemoveHolo(self);

	stuffcmd(self, "v_idlescale 0\n");
	stuffcmd(self, "v_cshift 0 0 0 0\n");
	self.item_list = 0;
	self.FlashTime = 0;

	// Remove Menu
	CenterPrint(self, "\n");
	self.menu_count = #MENU_REFRESH_RATE;
	self.current_menu = #MENU_DEFAULT;
	self.impulse = 0;
};

//=========================================================================
// Setup the Respawn delays for this player
void(float Suicided) TeamFortress_SetupRespawn =
{
	local float restime;//,teamsup;
	local string db;

	if (self.respawn_time > time)
		return; 	// already respawning

	// Setup Respawn Delay
	if (toggleflags & #TFLAG_RESPAWNDELAY)
		restime = respawn_delay_time;
	else 
		restime = 0;

	// Suiciders can't respawn immediately
	if (Suicided)
		restime = restime + #SUICIDE_RESPAWN_DELAY;

	// Remove a life
	if (self.lives > 0 && prematch < time)
	{
		self.lives = self.lives - 1;
/*		if (self.team_no == 1) team1total = team1total - 1;
		else if (self.team_no == 2) team1total = team2total - 1;
		else if (self.team_no == 3) team1total = team3total - 1;
		else if (self.team_no == 4) team1total = team4total - 1;*///- ???
		
		
	}

	if (self.lives != -1)
	{
		if (self.lives == 0)
		{
			// Move to Observer mode when you die
			PlayerObserverMode();
			//if (livesperguy > 1)
			//{
				sprint (self, #PRINT_HIGH, "NO lives left, returning to Observer mode.\n");
				bprint (#PRINT_MEDIUM, self.netname);
				bprint (#PRINT_MEDIUM, " ran out of lives!\n");
			//}
			return;
		}

		if (self.lives == 1)
			sprint (self, #PRINT_HIGH, "LAST life.\n");
		else
		{
			db = ftos(self.lives);
			sprint(self, #PRINT_HIGH, db);
			sprint (self, #PRINT_HIGH, " lives left.\n");
		}
	}//*/// ???

	// Do this after life calculation, so people without any
	// lives left can respawn back to Observer mode without a delay.
	self.respawn_time = time + restime;

	if (restime > 3)
	{
		db = ftos(restime);

		sprint(self, #PRINT_HIGH, db);
		sprint(self, #PRINT_HIGH, " seconds till respawn.\n");
	}
};

//=========================================================================
// Check all stats to make sure they're good for this class
void() TeamFortress_CheckClassStats =
{
	// Check armor
	if (self.armortype > self.armor_allowed)
		self.armortype = self.armor_allowed;
	if (self.armorvalue > self.maxarmor)
		self.armorvalue = self.maxarmor;
	if (self.armortype < 0)
		self.armortype = 0;
	if (self.armorvalue < 0)
		self.armorvalue = 0;
	// Check ammo
	if (self.ammo_shells > TeamFortress_GetMaxAmmo(self,#IT_SHELLS))
		self.ammo_shells = TeamFortress_GetMaxAmmo(self,#IT_SHELLS);
	if (self.ammo_shells < 0)
		self.ammo_shells = 0;
	if (self.ammo_nails > TeamFortress_GetMaxAmmo(self,#IT_NAILS))
		self.ammo_nails = TeamFortress_GetMaxAmmo(self,#IT_NAILS);
	if (self.ammo_nails < 0)
		self.ammo_nails = 0;
	if (self.ammo_rockets > TeamFortress_GetMaxAmmo(self,#IT_ROCKETS))
		self.ammo_rockets = TeamFortress_GetMaxAmmo(self,#IT_ROCKETS);		
	if (self.ammo_rockets < 0)
		self.ammo_rockets = 0;
	if (self.ammo_cells > TeamFortress_GetMaxAmmo(self,#IT_CELLS))
		self.ammo_cells = TeamFortress_GetMaxAmmo(self,#IT_CELLS);		
	if (self.ammo_cells < 0)
		self.ammo_cells = 0;
	if (self.ammo_medikit > TeamFortress_GetMaxAmmo(self,#WEAP_MEDIKIT))
		self.ammo_medikit = TeamFortress_GetMaxAmmo(self,#WEAP_MEDIKIT);		
	if (self.ammo_medikit < 0)
		self.ammo_medikit = 0;
	if (self.ammo_detpack > TeamFortress_GetMaxAmmo(self,131072))
		self.ammo_detpack = TeamFortress_GetMaxAmmo(self,131072);		
	if (self.ammo_detpack < 0)
		self.ammo_detpack = 0;
	// Check Grenades
	if (self.no_grenades_1 < 0)
		self.no_grenades_1 = 0;
	if (self.no_grenades_2 < 0)
		self.no_grenades_2 = 0;
	// Check health
	if (self.health > self.max_health && !(self.items & #IT_SUPERHEALTH))
		TF_T_Damage (self, world, world, (self.max_health - self.health), 0, #TF_TD_NOSOUND);
	if (self.health < 0)
		T_Heal(self, (self.health - self.health), 0);

	// Update armor picture
	self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
	if (self.armortype >= 0.8)
		self.items = self.items | #IT_ARMOR3;
	else if (self.armortype >= 0.6)
		self.items = self.items | #IT_ARMOR2;
	else if (self.armortype >= 0.3)
		self.items = self.items | #IT_ARMOR1;
};

//=========================================================================
// AMMOBOX Handling
//=========================================================================
// Throw an ammo box with 10 shells, 10 nails, 5 cells or 5 rockets
void (float type) TeamFortress_DropAmmo =
{
	local float ammo;

	if (type == 1)
	{
		ammo = #DROP_SHELLS;
		if (self.ammo_shells < ammo)
		{
/*CH who cares, we need space
			// ENGINEER can make ammo
			if (self.playerclass == #PC_ENGINEER)
			{
				if ((self.ammo_cells / #AMMO_COST_SHELLS) > (ammo - self.ammo_shells))
				{
					sprint (self, #PRINT_HIGH, "you make some shells.\n");
					self.ammo_cells = self.ammo_cells - ((ammo - self.ammo_shells) * #AMMO_COST_SHELLS);
					self.ammo_shells = ammo;
				}
			}

			if (self.ammo_shells < ammo)
*/				return;
		}

		self.ammo_shells = self.ammo_shells - ammo;
	}
	else if (type == 2)
	{
		ammo = #DROP_NAILS;
		if (self.ammo_nails < ammo)
		{
/*CH who cares, we need space
			// ENGINEER can make ammo
			if (self.playerclass == #PC_ENGINEER)
			{
				if ((self.ammo_cells / #AMMO_COST_NAILS) > (ammo - self.ammo_nails))
				{
					sprint (self, #PRINT_HIGH, "you make some nails.\n");
					self.ammo_cells = self.ammo_cells - ((ammo - self.ammo_nails) * #AMMO_COST_NAILS);
					self.ammo_nails = ammo;
				}
			}

			if (self.ammo_nails < ammo)
*/				return;
		}

		self.ammo_nails = self.ammo_nails - ammo;
	}
	else if (type == 3)
	{
		ammo = #DROP_ROCKETS;
		if (self.ammo_rockets < ammo)
		{
/*CH who cares, we need space
			// ENGINEER can make ammo
			if (self.playerclass == #PC_ENGINEER)
			{
				if ((self.ammo_cells / #AMMO_COST_ROCKETS) > (ammo - self.ammo_rockets))
				{
					sprint (self, #PRINT_HIGH, "you make some rockets.\n");
					self.ammo_cells = self.ammo_cells - ((ammo - self.ammo_rockets) * #AMMO_COST_ROCKETS);
					self.ammo_rockets = ammo;
				}
			}

			if (self.ammo_rockets < ammo)
*/				return;
		}

		self.ammo_rockets = self.ammo_rockets - ammo;
	}
	else if (type == 4)
	{
		ammo = #DROP_CELLS;
		if (self.ammo_cells < ammo)
		{
/*CH who cares, we need space
			// ENGINEER can make ammo
			if (self.playerclass == #PC_ENGINEER)
			{
				if ((self.ammo_cells / #AMMO_COST_CELLS) > (ammo - self.ammo_cells))
				{
					sprint (self, #PRINT_HIGH, "you make some cells.\n");
					self.ammo_cells = self.ammo_cells - ((ammo - self.ammo_cells) * #AMMO_COST_CELLS);
					self.ammo_cells = ammo;
				}
			}

			if (self.ammo_cells < ammo)
*/				return;
		}

		self.ammo_cells = self.ammo_cells - ammo;
	}
	W_SetCurrentAmmo();

	if (self.team_no != 0)
	{
		increment_team_ammoboxes(self.team_no);
		if (num_team_ammoboxes(self.team_no) > (#MAX_WORLD_AMMOBOXES / number_of_teams))
			RemoveOldAmmobox(self.team_no);
	}
	else 
	{
		num_world_ammoboxes = num_world_ammoboxes + 1;
		if (num_world_ammoboxes > #MAX_WORLD_AMMOBOXES)
			RemoveOldAmmobox(0);
	}

	newmis = spawn();
	newmis.aflag = ammo;
	newmis.weapon = type;
	if (newmis.weapon == 1)
		newmis.ammo_shells = ammo;
	else if (newmis.weapon == 2)
		newmis.ammo_nails = ammo;
	else if (newmis.weapon == 3)
		newmis.ammo_rockets = ammo;
	else if (newmis.weapon == 4)
		newmis.ammo_cells = ammo;
	newmis.enemy = self;
	newmis.health = time;
	newmis.movetype = #MOVETYPE_TOSS;
	newmis.solid = #SOLID_TRIGGER;
	newmis.classname = "ammobox";
	newmis.team_no = self.team_no;

	makevectors (self.v_angle);

	if (self.v_angle_x)
		newmis.velocity = v_forward*400 + v_up * 200;
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 400;
		newmis.velocity_z = 200;
	}

	newmis.avelocity = '0 300 0';
	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, self.origin);
	newmis.nextthink = time + 30;	// remove after 30 seconds
	newmis.think = SUB_Remove;
	newmis.touch = TeamFortress_AmmoboxTouch;
	newmis.skin = type - 1;
	setmodel (newmis, "progs/ammobox.mdl");
};

void () TeamFortress_AmmoboxTouch =
{
	local float took;
	local string quantity;

	took = 0;

	// Cant touch own ammobox for 2 seconds after throwing
	if ((other == self.enemy) && (time < self.health + 2))
		return; 		

	if (other.health <= 0)
		return;

	
	// Return if other is not a player
	if (other.classname != "player") //- OfN - Now grunt can take em
	{
		if (other.classname != "monster_army") return;

		num_world_ammoboxes = num_world_ammoboxes - 1;
		decrement_team_ammoboxes(self.team_no);

		other.ammo_shells = other.ammo_shells + self.ammo_shells;
		other.ammo_nails = other.ammo_nails + self.ammo_nails;
		other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
		other.ammo_cells = other.ammo_cells + self.ammo_cells;

		grunty_boundammo(other);

		PrintFromSoldier(other,other.real_owner,"i picked up some ammo.\n",#PRINT_MEDIUM);

		sound (other, #CHAN_ITEM, "weapons/lock4.wav", 1, #ATTN_NORM);

		dremove(self);
		self = other;

		return;
	}

	num_world_ammoboxes = num_world_ammoboxes - 1;
	decrement_team_ammoboxes(self.team_no);

	// discard backpack
	if (self.weapon == 0)
	{
		sprint(other, #PRINT_LOW, "You got ");
		if (self.ammo_shells > 0)
		{
			other.ammo_shells = other.ammo_shells + self.ammo_shells;
			quantity = ftos(self.ammo_shells);
			sprint2(other, #PRINT_LOW, quantity, " shells  ");
		}	
		if (self.ammo_nails > 0)
		{
			other.ammo_nails = other.ammo_nails + self.ammo_nails;
			quantity = ftos(self.ammo_nails);
			sprint2(other, #PRINT_LOW, quantity, " nails  ");
		}	
		if (self.ammo_rockets > 0)
		{
			other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
			quantity = ftos(self.ammo_rockets);
			sprint2(other, #PRINT_LOW, quantity, " rockets  ");
		}	
		if (self.ammo_cells > 0)
		{
			other.ammo_cells = other.ammo_cells + self.ammo_cells;
			quantity = ftos(self.ammo_cells);
			sprint2(other, #PRINT_LOW, quantity, " cells  ");
		}	
		sprint(other, #PRINT_LOW, "\n");
	}
	// shotgun
	else if (self.weapon == 1)
	{
		if (other.ammo_shells >= TeamFortress_GetMaxAmmo(other,#IT_SHELLS))
			return;
		other.ammo_shells = other.ammo_shells + self.aflag;
		self.netname = "shells";
	}
	// spikes
	else if (self.weapon == 2)
	{
		if (other.ammo_nails >= TeamFortress_GetMaxAmmo(other,#IT_NAILS))
			return;
		other.ammo_nails = other.ammo_nails + self.aflag;
		self.netname = "nails";
	}
	//	rockets
	else if (self.weapon == 3)
	{
		if (other.ammo_rockets >= TeamFortress_GetMaxAmmo(other,#IT_ROCKETS))
			return;
		other.ammo_rockets = other.ammo_rockets + self.aflag;
		self.netname = "rockets";
	}
	//	cells
	else if (self.weapon == 4)
	{
		if (other.ammo_cells >= TeamFortress_GetMaxAmmo(other,#IT_CELLS))
			return;
		other.ammo_cells = other.ammo_cells + self.aflag;
		self.netname = "cells";
	}

	bound_other_ammo (other);

	// Discard backpacks do their own printing
	if (self.weapon > 0)
	{
		quantity = ftos(self.aflag);
		sprint5(other, #PRINT_LOW, "You picked up ", quantity, " ", self.netname, "\n");
	}

	sound (other, #CHAN_ITEM, "weapons/lock4.wav", 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");

	dremove(self);
	self = other;
	W_SetCurrentAmmo();
};

// Return the number of pipebombs in existence for a particular team
float (float tno) num_team_ammoboxes =
{
	if (tno == 1)
		return num_team_ammoboxes_1;
	else if (tno == 2)
		return num_team_ammoboxes_2;
	else if (tno == 3)
		return num_team_ammoboxes_3;
	else if (tno == 4)
		return num_team_ammoboxes_4;

	return 0;
};

// Remove enough old ammoboxes to bring the count down to the max level
void(float tno) RemoveOldAmmobox =
{
	local entity old;
	local float index;

	if (tno != 0)
	{
		index = num_team_ammoboxes(tno);
		index = index - (#MAX_WORLD_AMMOBOXES / number_of_teams);
	}
	else
	{
		index = num_world_ammoboxes - #MAX_WORLD_AMMOBOXES;
	}

	old = find(world, classname, "ammobox");
	while (index > 0)
	{
		if (old == world)
		{
//			RPrint("*** ERROR: RemoveOldAmmobox. ***\n");
//			RPrint("*** Shaka thought he fixed this ***\n");
			num_world_ammoboxes = num_world_ammoboxes - 1;
			decrement_team_ammoboxes(old.team_no);
			return;
		}

		if (old.team_no == tno || tno == 0)
		{
			old.think = SUB_Remove;
			old.nextthink = time + 0.1;
			index = index - 1;

			num_world_ammoboxes = num_world_ammoboxes - 1;
			decrement_team_ammoboxes(old.team_no);
		}

		old = find(old, classname, "ammobox");
	}
};

void(float tno) increment_team_ammoboxes =
{
	if (tno == 1)
		num_team_ammoboxes_1 = num_team_ammoboxes_1 + 1;
	else if (tno == 2)
		num_team_ammoboxes_2 = num_team_ammoboxes_2 + 1;
	else if (tno == 3)
		num_team_ammoboxes_3 = num_team_ammoboxes_3 + 1;
	else if (tno == 4)
		num_team_ammoboxes_4 = num_team_ammoboxes_4 + 1;
};

void(float tno) decrement_team_ammoboxes =
{
	if (tno == 1)
		num_team_ammoboxes_1 = num_team_ammoboxes_1 - 1;
	else if (tno == 2)
		num_team_ammoboxes_2 = num_team_ammoboxes_2 - 1;
	else if (tno == 3)
		num_team_ammoboxes_3 = num_team_ammoboxes_3 - 1;
	else if (tno == 4)
		num_team_ammoboxes_4 = num_team_ammoboxes_4 - 1;
};

//=========================================================================
// WEAPON HANDLING FUNCTIONS
//=========================================================================
//=========================================================================
// Assault Cannon selection function
void() TeamFortress_AssaultWeapon =
{
	//local float	it;
	
	self.impulse = 0;

	if (self.tfstate & #TFSTATE_RELOADING)
		return;

	if (!(self.weapons_carried & #WEAP_ASSAULT_CANNON)) 
		return;

	if (self.heat > 0)
	{
		sprint (self, #PRINT_HIGH, "the assault cannon is still overheated.\n");
		return;
	}

	if (self.ammo_shells < 1)
	{	// don't have the ammo
		sprint (self, #PRINT_HIGH, "not enough ammo.\n");
		return;
	}
	// The cannon also needs 6 cells to power up 
	if (self.ammo_cells < 6)
	{
		sprint (self, #PRINT_HIGH, "not enough cells to power the assault cannon.\n");
		return;
	}

	self.current_weapon = #WEAP_ASSAULT_CANNON;

	W_SetCurrentAmmo ();
};

//=========================================================================
// If this gets called, the players holding onto an exploding grenade :)
void() TeamFortress_ExplodePerson =
{
	//local entity te;

	// Removes the owners grenade
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_GRENPRIMED);

	KickPlayer(-2, self.owner);

	newmis = spawn ();
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_BBOX;
	newmis.classname = "grenade";
	newmis.team_no = self.owner.team_no;
	newmis.owner = self.owner;
		
	// Don't bother calculating a velocity
	newmis.velocity = '0 0 0';
	newmis.angles = vectoangles(newmis.velocity);
	
	// set the grenades thinktime to now
	newmis.think = SUB_Null;
	newmis.nextthink = time + 0.1;

	// set the think and touches to the appropriate grenade type
	if (self.weapon == #GR_TYPE_NORMAL)
	{
		newmis.touch = NormalGrenadeTouch;
		newmis.think = NormalGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_CONCUSSION)
	{
		newmis.touch = ConcussionGrenadeTouch;
		newmis.think = ConcussionGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_BIO)
	{
		newmis.touch = BioGrenadeTouch;
		newmis.think = BioGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_ANTIGRAV)
	{
		newmis.touch = ConcussionGrenadeTouch;
		newmis.think = AntiGravGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_NAIL)
	{
		newmis.touch = NailGrenadeTouch;
		newmis.think = NailGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '0 300 0';
		setmodel (newmis, "progs/biggren.mdl");
	}
	else if (self.weapon == #GR_TYPE_CALTROP)
	{
		newmis.touch = NormalGrenadeTouch;
		newmis.think = CaltropGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
	else if (self.weapon == #GR_TYPE_MIRV)
	{
		newmis.touch = MirvGrenadeTouch;
		newmis.think = MirvGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '0 300 0';
		setmodel (newmis, "progs/biggren.mdl");
	}
	else if (self.weapon == #GR_TYPE_NAPALM)
	{
		newmis.touch = NapalmGrenadeTouch;
		newmis.think = NapalmGrenadeExplode;
		newmis.skin = 2;
		newmis.avelocity = '0 300 0';
		setmodel (newmis, "progs/biggren.mdl");
	}
	else if (self.weapon == #GR_TYPE_FLARE)
	{
		//sprint(self.owner, #PRINT_HIGH, "Flare lit.\n");
		sprint(self.owner, #PRINT_HIGH, "The flare burns on your hand!\n");
		deathmsg = 0; // TODO
		T_Damage(self.owner, self.owner, self.owner,12);
		stuffcmd(self.owner, "bf\nbf\n");

		newmis.touch = FlareBounce;
		newmis.think = FlareGrenadeExplode;
		newmis.skin = 0;
		newmis.has_holo=1;
		newmis.avelocity = '0 0 0';
		setmodel (newmis, "progs/flarefly.mdl");

		/*te = spawn();
		te.touch = SUB_Null;
		te.think = SUB_Remove;//FlareGrenadeExplode;//RemoveFlare;
		te.nextthink = time + 25;
		te.owner = self.owner;
		te.solid = #SOLID_NOT;
		self.owner.effects = self.owner.effects | #EF_BRIGHTLIGHT;*/

		setsize (newmis, '0 0 0', '0 0 0'); 	
		setorigin (newmis, self.owner.origin);

		
		dremove(self);
		//dremove(newmis);
		return;
	}
	else if (self.weapon == #GR_TYPE_GAS)
	{
		newmis.touch = GasGrenadeTouch;
		newmis.think = GasGrenadeExplode;
		newmis.skin = 2;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}
	else if (self.weapon == #GR_TYPE_EMP)
	{
		newmis.touch = EMPGrenadeTouch;
		newmis.think = EMPGrenadeExplode;
		newmis.skin = 4;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}
	#ifdef OLD_FLASH
	else if (self.weapon == #GR_TYPE_FLASH)
	{
		newmis.touch = FlashGrenadeTouch;
		newmis.think = FlashGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}
	#else
	else if (self.weapon == #GR_TYPE_PSIONIC)
	{
		newmis.touch = PsionicGrenadeTouch;
		newmis.think = PsionicGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}
	#endif
	else if (self.weapon == #GR_TYPE_FRAG)
	{
		newmis.touch = FragGrenadeTouch;
		newmis.think = FragGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}
	else if (self.weapon == #GR_TYPE_KRAC)
	{
		newmis.touch = KracGrenadeTouch;
		newmis.think = KracGrenadeExplode;
		newmis.skin = 1;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/grenade2.mdl");
	}

	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, self.owner.origin);

	//bprint(#PRINT_MEDIUM, "No ");
	//bprint(#PRINT_MEDIUM, self.owner.netname);
	//bprint(#PRINT_MEDIUM, ", throw the grenade, not the pin!\n");

	bprint(#PRINT_MEDIUM, "No ");
	bprint(#PRINT_MEDIUM, self.owner.netname);
	bprint(#PRINT_MEDIUM, ", you are supposed to THROW the grenade!\n");

	// Remove primed grenade object 
	dremove(self);
};

//=========================================================================
// Thrown Grenade touch function.
void() NormalGrenadeTouch =
{
	if (other == self.owner)
		return; 	// don't explode on owner

	// Thrown grenades don't detonate when hitting an enemy

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Thrown grenade explosion. 50% more powerful as grenade launcher grenades.
void() NormalGrenadeExplode =
{
	deathmsg = #DMSG_GREN_HAND;
	T_RadiusDamage (self, self.owner, 180, world);

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
	dremove(self);
#else
	BecomeExplosion ();
#endif
};

//=========================================================================
// Displays the state of the items in the Detection Entity
void() TeamFortress_DisplayDetectionItems =
{
	local entity Goal, te;

	Goal = find(world, classname, "info_tfdetect");
	if (!Goal)
		return;

	// Check to make sure they've got some strings
	if (Goal.team_str_home == string_null)
		return;

	if (Goal.display_item_status1 != 0)
	{
		te = Finditem(Goal.display_item_status1);
		if (te)
			DisplayItemStatus(Goal, self, te);
		else
			sprint (self, #PRINT_HIGH, "Item is missing.\n");
	}
	else
		return;

	if (Goal.display_item_status2 != 0)
	{
		te = Finditem(Goal.display_item_status2);
		if (te)
			DisplayItemStatus(Goal, self, te);
		else
			sprint (self, #PRINT_HIGH, "Item is missing.\n");
	}
	else
		return;

	if (Goal.display_item_status3 != 0)
	{
		te = Finditem(Goal.display_item_status3);
		if (te)
			DisplayItemStatus(Goal, self, te);
		else
			sprint (self, #PRINT_HIGH, "Item is missing.\n");
	}
	else
		return;

	if (Goal.display_item_status4 != 0)
	{
		te = Finditem(Goal.display_item_status4);
		if (te)
			DisplayItemStatus(Goal, self, te);
		else
			sprint (self, #PRINT_HIGH, "Item is missing.\n");
	}
};

//=========================================================================
// ITEM HANDLING FUNCTIONS
//=========================================================================
// Function for handling the BioInfection Decay of players
void() BioInfection_Decay =
{
	// Remove infections which can't hurt the owner
	if ((teamplay & #TEAMPLAY_NOEXPLOSIVE) && Teammate(self.owner, self.enemy))
	{
		self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_INFECTED);
		dremove(self);
		return;
	}

	if (self.invincible_finished > time)
	{
		self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_INFECTED);
		dremove(self);
		return;
	}

	if (self.owner.current_weapon == #WEAP_MEDIKIT)
	{
		sprint(self.owner,#PRINT_HIGH,"You heal yourself of your infection.\n");
		self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_INFECTED);
		dremove(self);
		return;
	}

	// remove this entity if the infection is gone
	if ( !(self.owner.tfstate & #TFSTATE_INFECTED) )
	{
		dremove(self);
		return;
	}

	self.nextthink = time + 2;

	deathmsg = #DMSG_BIOWEAPON;
	TF_T_Damage(self.owner, self, self.enemy, 5, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);

	SpawnBlood(self.owner.origin, 30);	
};

//========================================================================
// Function for handling the BioInfection Decay of monsters
void() BioInfection_MonsterDecay =
{
	local float drmg;

	if (!self.enemy)
	{
		dremove(self);
		return;
	}

	if (!(self.enemy.tfstate & #TFSTATE_INFECTED)) {
		dremove(self);
		return;
	}

	if (self.enemy.health <= 0)
	{
		dremove(self);
		return;
	}

	drmg = 125 * random(); // was 200
	drmg = drmg * random();

	self.nextthink = time + 2;

	if (self.enemy.health + 30 < drmg)
		drmg = self.enemy.health + 29;

	//T_Damage(self.enemy, self, self.owner, drmg);
	TF_T_Damage(self.enemy, self, self.owner, drmg, #TF_TD_NOPAIN,0);

	SpawnBlood(self.enemy.origin, drmg+10);

	if (self.enemy.health > 1 && self.enemy.classname == "monster_army")
	{
		if (random() < 0.10)
		{
			local float rnum;
			rnum = random();

			if (rnum > 0.66)
				PrintFromSoldier(self.enemy,self.enemy.real_owner,"Argh! Medic!!\n",#PRINT_HIGH);
			else if (rnum > 0.33)
				PrintFromSoldier(self.enemy,self.enemy.real_owner,"Are you going to heal me?\n",#PRINT_HIGH);
			else
				PrintFromSoldier(self.enemy,self.enemy.real_owner,"My medikits won't cure me! Help!!\n",#PRINT_HIGH);

			sound(self.enemy, #CHAN_VOICE, "speech/saveme1.wav", 1, #ATTN_NORM);
		}
	}		
};

//=========================================================================
// UTILITY FUNCTIONS
//=========================================================================
// Stuff an alias. This is a little messy since we insisted
// on maintaining the ability to alter the impulse numbers in the defs.qc 
// and not have to change any code. 
void(string halias, float himpulse1, float himpulse2) TeamFortress_Alias =
{
	local string imp;

	stuffcmd(self, "alias ");
	stuffcmd(self, halias);
	stuffcmd(self, " \"impulse ");
	imp = ftos(himpulse1);
	stuffcmd(self, imp);

	// if himpulse2 is not zero, assume that himpulse1 is a preimpulse 
	// and complete the alias
	if (himpulse2 != 0)
	{
		stuffcmd(self, ";wait; impulse ");
		imp = ftos(himpulse2);
		stuffcmd(self, imp);
	}
	stuffcmd(self, "\"\n");
};

//=========================================================================
// CYCLIC EVENT FUNCTIONS
//=========================================================================
//=========================================================================
// Regenerates the entity which owns this cyclictimer
void() TeamFortress_Regenerate =
{
//WK	if (self.owner.playerclass == #PC_MEDIC)
	if (self.is_abouttodie)
		return;
	if (self.owner.weapons_carried & #WEAP_MEDIKIT) //WK Custom class friendly
	{
		self.nextthink = time + #PC_MEDIC_REGEN_TIME;

		if (self.owner.health >= self.owner.max_health)
			return;

		if (self.owner.ammo_medikit == 0)
			return;

		if (self.owner.ammo_medikit < #PC_MEDIC_REGEN_AMOUNT)
		{
			self.owner.health = self.owner.health + self.owner.ammo_medikit;
			self.owner.ammo_medikit = 0;
		}
		else
		{
			self.owner.health = self.owner.health + #PC_MEDIC_REGEN_AMOUNT;
			self.owner.ammo_medikit = self.owner.ammo_medikit - #PC_MEDIC_REGEN_AMOUNT;
		}

		if (self.owner.health > self.owner.max_health)
			self.owner.health = self.owner.max_health;
	}
};

void() CyberAugSleep =
{
	if (self.owner.velocity_z == 0 && self.owner.velocity_y == 0 && self.owner.velocity_x == 0)
		self.think = TeamFortress_RegenerateCyber;
	
	self.nextthink = time + 2;
};

void() TeamFortress_RegenerateCyber =
{
	//local entity te;
	if (self.is_abouttodie)
		return;
	
//WK	if (self.owner.playerclass == #PC_MEDIC)
	if (self.owner.velocity_z > 0 || self.owner.velocity_y > 0 || self.owner.velocity_x > 0)
	{
		self.nextthink = time + 2;
		self.think = CyberAugSleep;
		return;
	}

	if (self.owner.cutf_items & #CUTF_CYBERAUG && !(self.owner.is_malfunctioning)) //WK Custom class friendly
	{
		self.owner.armortype = self.owner.armor_allowed;
		W_SetCurrentAmmo();
		if (self.owner.health < self.owner.max_health)
		{
			if (self.owner.ammo_medikit == 0)
				self.owner.health = self.owner.health + 1;
			else if (self.owner.ammo_medikit < #PC_MEDIC_REGEN_AMOUNT / 2)
			{
				self.owner.health = self.owner.health + self.owner.ammo_medikit * 2;
				self.owner.ammo_medikit = 0;
			}
			else
			{
				self.owner.health = self.owner.health + #PC_MEDIC_REGEN_AMOUNT;
				self.owner.ammo_medikit = self.owner.ammo_medikit - #PC_MEDIC_REGEN_AMOUNT / 2;
			}
		}
		
		if (self.owner.armorvalue < self.owner.maxarmor)
		{
			if (self.owner.ammo_cells == 0)
				self.owner.armorvalue = self.owner.armorvalue + 2;
			else if (self.owner.ammo_cells < #PC_MEDIC_REGEN_AMOUNT)
			{
				self.owner.armorvalue = self.owner.armorvalue + self.owner.ammo_cells * 2;
				self.owner.ammo_cells = 0;
			}
			else
			{
				self.owner.armorvalue = self.owner.armorvalue + #PC_MEDIC_REGEN_AMOUNT * 2;
				self.owner.ammo_cells = self.owner.ammo_cells - #PC_MEDIC_REGEN_AMOUNT;
			}
		}

		UpdateCells(self.owner);

		if (self.owner.armorvalue > self.owner.maxarmor)
			self.owner.armorvalue = self.owner.maxarmor;
		if (self.owner.health > self.owner.max_health)
			self.owner.health = self.owner.max_health;
	}
	else if (self.owner.cutf_items & #CUTF_CYBERAUG && self.owner.is_malfunctioning == 1)
	{
		if (self.owner.health > 3)
			TF_T_Damage(self.owner, self.owner, self.owner, 3, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
		else if (self.owner.health < 3 && self.owner.health > 1)
			self.owner.health = 1;
		if (self.owner.armorvalue > 3)
			self.owner.armorvalue = self.owner.armorvalue - 3;
		else if (self.owner.armorvalue < 3)
			self.owner.armorvalue = 0;
	}
	
	self.nextthink = time + #PC_MEDIC_REGEN_TIME;

};
//=========================================================================
// Activates when we go hidden
// If we're moving, make us not invis
void() TeamFortress_RegenerateCells =
{
	//WK Borrow this code from TF, since there's no reason to
	// duplicate it.
	if (!(self.owner.job & #JOB_THIEF))
		dremove(self);
	if (!(self.owner.job & #JOB_ACTIVE))
		dremove(self);
	if (self.owner.health <= 0)
		dremove(self);
	self.nextthink = time + #PC_SPY_CELL_REGEN_TIME;
	if (self.owner.job & #JOB_ACTIVE)
	{
		if (vlen(self.owner.velocity) > 0 && self.owner.job & #JOB_FULL_HIDE && !self.owner.shadowstep_active)
		{		
				//WK 10/10/7 reworked to incorporate shadowstep
				self.owner.items = self.owner.items - (self.owner.items & #IT_INVISIBILITY); //Clear icon
				if (self.owner.shadowstep_time > 0) self.owner.shadowstep_time = 0; //Clear shadowstep 'fuel'

				self.owner.frame = 0;
				self.owner.weaponframe = 0;
				self.owner.modelindex = modelindex_eyes;
				self.owner.job = self.owner.job - (self.owner.job & #JOB_FULL_HIDE);
				TeamFortress_SetSpeed(self.owner);			
		}
		else if (vlen(self.owner.velocity) == 0 && !(self.owner.job & #JOB_FULL_HIDE))
		{
				self.owner.frame = 0;
				self.owner.weaponframe = 0;
				self.owner.modelindex = modelindex_null;
				self.owner.job = self.owner.job | #JOB_FULL_HIDE;
		}
	}

	/*
	if (self.owner.playerclass == #PC_SPY)
	{
		self.nextthink = time + #PC_SPY_CELL_REGEN_TIME;

		// If the spy is undercover, decrease the number of cells
		if (self.owner.is_undercover == 1)
		{
			// If the spy has no cells left, he becomes visible again
			if (self.owner.ammo_cells == 0)
			{
				self.owner.is_undercover = 0;
				self.owner.modelindex = modelindex_player;	// return to normal
				self.owner.items = self.owner.items - (self.owner.items & #IT_INVISIBILITY);
			}
			else // Decrease cells
			{
				self.owner.ammo_cells = self.owner.ammo_cells - #PC_SPY_CELL_USAGE;
				if (self.owner.ammo_cells < 0)
					self.owner.ammo_cells = 0;
			}
		}
		else	// Increase cell ammo
		{
			if (self.owner.ammo_cells >= self.owner.maxammo_cells)
				return;

			self.owner.ammo_cells = self.owner.ammo_cells + #PC_SPY_CELL_REGEN_AMOUNT;

			if (self.owner.ammo_cells > self.owner.maxammo_cells)
				self.owner.ammo_cells = self.owner.maxammo_cells;
		}

		return;
	}
	*/
};

//============================================================================
// sends a player to observer mode
void() PlayerObserverMode =
{
	DetonateAllGuns();
	kill_my_demons();
	self.current_menu = #MENU_DEFAULT;
	self.impulse = 0;
	self.playerclass = #PC_UNDEFINED;
	self.lives = 0;
	self.health = 1;
	self.gravity = 0; //WK Make em float so prediction doesn't get all annoying-like
	if (self.team_no > 0) self.old_team_no = self.team_no; //WK Save old team for scoreboard
	self.team_no = -1;

	self.flags = #FL_CLIENT | #FL_NOTARGET | #FL_ONGROUND;
	self.waterlevel = 3;
	self.takedamage = #DAMAGE_NO;
	self.solid = #SOLID_NOT;
	//self.movetype = #MOVETYPE_NOCLIP;
	self.movetype = #MOVETYPE_FLY;

	self.model = string_null;
	self.mdl = string_null;
	setmodel(self, string_null);

	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';

	sprint (self, #PRINT_HIGH, "Observer mode\n");
	CenterPrint(self, "\n");
	stuffcmd(self, "color 0; wait; cl_rollangle 0\n");
};

//============================================================================
// Return the crossproduct of 2 vectors
float(vector veca, vector vecb) crossproduct =
{
	local float result;

	result = (veca_x * vecb_y) - (vecb_x * veca_y);
	return result;
};

