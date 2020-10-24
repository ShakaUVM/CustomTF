/*=======================================================//
// CPStuff.QC - CustomTF 3.2.OfN		   - 30/1/2001 - //
// by Sergio FumaÒa Grunwaldt  - OfteN [cp] 			 //
=========================================================//
 Additional stuff, basicaly things i dunno where to put :)
=========================================================*/

void() HoloThink;
void(entity player) RemoveHolo;
float(entity player, float itemid, float storechange, float resetstored) StripSpecificItem;
//float(float itemid, float stuff1, float stuff2, float stuff3, float stuff4, float stuff5) ItemInside;
float(entity player) StripDisallowed;
float(entity player, float itemid, float storechange, float resetstored) GiveSpecificItem;
float(entity player) GiveFreeStuff;
float(entity ent, float type, float itemid, float value) SetItemInside;
float(entity player) RestoreOriginalItems;
string(float ver) ver_ftos;
void() InitMegaTF;

//====================================================================//
// Initialize stuff, localinfos etc...								  //
// This is called on worldspawn and with the Admin infos command	  //
//====================================================================//

// If startup is TRUE, even values that imply precachees are updated
// so it should only be set on wordspawn

void (float startup) UpdateInfos = 
{
	local string st;
	
	st = infokey(world, "allow_debug"); //
	if (st == "1" || st =="on")
		allow_debug = 1;
	else
	{
		debug_target=world;
		allow_debug = 0;
	}

	st = infokey(world, "bodyque_size"); //
	bodyque_size = stof(st);
	if (bodyque_size < 4)
		bodyque_size = #DEFAULT_BODYQUE_SIZE;
	if (bodyque_size > 40)
		bodyque_size = 40;
	
	#ifdef COOL_GIBS
	st = infokey(world, "cool_gibs"); //
	if (st == "0" || st =="off")
		cool_gibs = 0;
	else
		cool_gibs = 1;
	#endif

	#ifdef KICKABLE_HEADS
	st = infokey(world,"kickable_heads");
	if (st == "0" || st =="off")
		kickable_heads = 0;
	else
		kickable_heads = 1;
	#endif

	#ifdef MENU_SOUNDS
	//if (startup) // Only update on map restart, avoids precache error
	//{
	
	st = infokey(world,"menu_sounds");
	if (st == "0" || st =="off")
		menu_sounds = 0;
	else
		menu_sounds = 1;
	
	//}
	#endif

	st = infokey(world, "drop_items"); //
	if (st == "1" || st == "on")
		drop_items = 1;
	else
		drop_items = 0;

	st = infokey(world, "pay_msgs"); //
	if (st == "1" || st =="on")
		pay_msgs = 1;
	else
		pay_msgs = 0;

	st = infokey(world, "team_prefix"); //
	if (st == "0" || st =="off")
		team_prefix = 0;
	else
		team_prefix = 1;

	/*st = infokey(world, "headless"); //
	if (st == "1" || st =="on" )
		headless = 1;
	else
		headless = 0;*/

	st = infokey(world, "no_grapple"); //
	if (st == "1" || st =="on" )
		no_grapple = 1;
	else
		no_grapple = 0;

	/*st = infokey(world, "smooth_sentry");
	if (st == "1" || st == "on")
		smooth_sentry = 1;
	else
		smooth_sentry = 0;*/

	st = infokey(world, "nicecolors"); //
	if (st == "1" || st =="on" )
		nicecolors = 1;
	else
		nicecolors = 0;

	st = infokey(world, "relax_cheatcheck"); //
	if (st == "1" || st =="on" )
		relax_cheatcheck = 1;
	else
		relax_cheatcheck = 0;

	st = infokey(world, "no_punish"); //
	if (st == "1" || st =="on" )
		no_punish = 1;
	else
		no_punish = 0;

	st = infokey(world, "no_votemap"); //
	if (st == "1" || st =="on" )
		no_votemap = 1;
	else
		no_votemap = 0;

	st = infokey(world, "no_detpush"); //
	if (st == "1" || st =="on" )
		no_detpush = 1;
	else
		no_detpush = 0;

	/*st = infokey(world, "no_monstercolors"); //
	if (st == "1" || st =="on" )
		no_monstercolors = 1;
	else
		no_monstercolors = 0;*/

	st = infokey(world, "custom_mode"); //
	if (st==string_null) st="0"; //sets default
	custom_mode = stof(st);
	if (custom_mode < 0 ) custom_mode = 0; // the allowed minimum 
	else if (custom_mode > 2) custom_mode = 2; //the allowed maximum

	st = infokey(world, "stock_mode"); //
	if (st==string_null) st="0"; //sets default
	stock_mode = stof(st);
	if (stock_mode < 0 ) stock_mode = 0; // the allowed minimum 
	else if (stock_mode > 2) stock_mode = 2; //the allowed maximum

	st = infokey(world, "extras_mode"); //
	if (st==string_null) st="0"; //sets default
	extras_mode = stof(st);
	if (extras_mode < 0 ) extras_mode = 0; // the allowed minimum 
	else if (extras_mode > 2) extras_mode = 2; //the allowed maximum

	st = infokey(world, "sniper_factor"); //ARE YOU HAPPY XSETZER?? :P
	if (st==string_null) st="1"; //WK 6/1/7 .85 //sets default
	sniper_factor = stof(st);
	if (sniper_factor < 0.1 ) sniper_factor = 0.1; // the allowed minimum 
	else if (sniper_factor > 2) sniper_factor = 2; //the allowed maximum

	if (stock_mode == 2 && custom_mode == 2) custom_mode = 0;

	// Attackers Go Red mode -PZ
	AGR_initialize();

	// Neo mode
	Neo_initialize();

	st = infokey(world, "army_delay"); //
	if (st==string_null) st="3"; //WK 6/1/7 5 //was 5 ,sets default
	army_delay = stof(st);
	if (army_delay < 2 ) army_delay = 1; //WK 6/1/7 2 // the allowed minimum 
	else if (army_delay > 60) army_delay = 60; //the allowed maximum

	st = infokey(world, "allow_watermonsters"); //
	if (st == "1" || st =="on" || mapname == "frontlin") //
		allow_watermonsters = 1;
	else
		allow_watermonsters = 0;

	st = infokey(world, "spec_menu"); //
	if (st == "0" || st =="off")
		spec_menu = 0;
	else
		spec_menu = 1;

	// Gets amount of money 
	st = infokey(world, "m");
	if (st == string_null)
		st = infokey(world, "money");
	local float numba;
	numba = stof(st);
	if (numba)
		custom_money = numba;
	else
		custom_money = #DEFAULT_MONEY;

	if (startup) // Map startup?
	{
		// Retrieve and do precaches if needed for megatf stuff..
		InitMegaTF();

		// Report initialization has been done
		RPrint("INFO: Prozac-specific localinfos retrieved and initialized.\n");
	}
	else
	{
		// Retrieve environment settings and apply them
		local float oldstorm, oldeq, olddt, oldrunes;

		oldstorm = storm;
		oldeq = earthquake;
		olddt = daytime;
		oldrunes = runes;
		
		GetEnvironmentGlobals();

		UpdateEnvironment(oldstorm,oldeq,olddt,oldrunes);

		if (!ceasefire && !specialstate)
			World_FadeIn(0,0,0);

		RPrint("INFO: Localinfos updated successfully.\n");
	}
};

//====================================================================//
// Sprints to all the members on one team except one the Team> Prefix //
// It should be used prior any teamsprint (look at tforttm.qc)		  //
//====================================================================//

void(float tno, entity ignore) teamprefixsprint =
{
	if ( team_prefix != 1 )
	  return;
	
	local entity te;

	// Don't do teamprints in DM
	if (tno == 0)
		return;

	te = find(world, classname, "player");
	temp_e.team_no = tno; // for Neo mode (modified Teammate())
	while (te)
	{
		// Neo mode modification
		if (Teammate(te, temp_e) && te != ignore)
			sprint(te, #PRINT_HIGH, "Teamç ");

		te = find(te, classname, "player");
	}
};

//==========================================================
// same shit but ignores 2 players

void(float tno, entity ignore, entity ignore2) teamprefixsprintbi =
{
	if ( team_prefix != 1 )
	  return;
	
	local entity te;

	// Don't do teamprints in DM
	if (tno == 0)
		return;

	te = find(world, classname, "player");
	temp_e.team_no = tno; // for Neo mode (modified Teammate())
	while (te)
	{
		if (Teammate(te, temp_e) && te != ignore && te != ignore2)
		{
			sprint(te, #PRINT_HIGH, "Teamç ");
		}

		te = find(te, classname, "player");
	}
};

//- For better performance i added this: --//
void(entity ignore, string st, string st2, string st3, string st4, string st5, string st6) teamsprint6 =
{
	local entity te;

	te = find(world, classname, "player");
	while (te)
	{
		if (Teammate(te, ignore) && te != ignore)
		{
			sprint(te, #PRINT_HIGH, st);
			sprint(te, #PRINT_HIGH, st2);
			sprint(te, #PRINT_HIGH, st3);
			sprint(te, #PRINT_HIGH, st4);
			sprint(te, #PRINT_HIGH, st5);
			sprint(te, #PRINT_HIGH, st6);
		}

		te = find(te, classname, "player");
	}
};

//==========================================================
// same shit but ignores 2 players

void(entity ignore, entity ignore2, string st, string st2, string st3, string st4, string st5, string st6) teamsprintbi =
{
	local entity te;

	te = find(world, classname, "player");
	while (te)
	{
		if (Teammate(te, ignore) && te != ignore && te != ignore2)
		{
			sprint(te, #PRINT_HIGH, st);
			sprint(te, #PRINT_HIGH, st2);
			sprint(te, #PRINT_HIGH, st3);
			sprint(te, #PRINT_HIGH, st4);
			sprint(te, #PRINT_HIGH, st5);
			sprint(te, #PRINT_HIGH, st6);
		}

		te = find(te, classname, "player");
	}
};

//================================================//
// Kicks any player with no TF skin on tforttm.qc //
//================================================//

float (string skin_str) Is_TF_Skin =
{
   // if relax_cheatcheck is "on" return its a valid skin
   if (relax_cheatcheck==1) return #TRUE;
   
   if ( skin_str != "tf_scout"
	&& skin_str != "tf_snipe"
	&& skin_str != "tf_sold"
	&& skin_str != "tf_demo"
	&& skin_str != "tf_medic"
	&& skin_str != "tf_hwguy"
	&& skin_str != "tf_pyro"
	&& skin_str != "tf_spy"
	&& skin_str != "tf_eng")
		return #FALSE;
   else
		return #TRUE;
};

//============================================================================//
// Return the new "NICE" color for the team corresponding to the no passed in //
//============================================================================//

string (float tno) TeamGetNiceColor =
{
	// Neo mode
	if (neo) return "";

	if (tno == 1)
		return "2 13";
	if (tno == 2)
		return "9 4";
	if (tno == 3)
		return "5 12";
	if (tno == 4)
		return "3 11";

	return "";
};

float (float tno, float theColor ) IsValidTopColor =
{
	// Neo mode
	if (neo) return #TRUE;

	theColor = floor(theColor);
	
	// if relax_cheatcheck is "on" return its a valid color value
	if (relax_cheatcheck==1)
	{
		if (theColor > 13 || theColor < 0)
			return #FALSE;
		
		if (tno == 1)
		{
			if (theColor == 4)
				return #FALSE;
			
			if (number_of_teams > 2 && theColor == 12)
				return #FALSE;
			if (number_of_teams > 3 && theColor == 11)
				return #FALSE;
		}
		
		if (tno == 2)
		{
			if (theColor == 13)
				return #FALSE;
		
			if (number_of_teams > 2 && theColor == 12)
				return #FALSE;
			if (number_of_teams > 3 && theColor == 11)
				return #FALSE;
		}
		
		if (tno == 3)
		{
			if (theColor==4||theColor==13)
				return #FALSE;

			if (number_of_teams > 3 && theColor == 11)
				return #FALSE;
		}

		if (tno == 4 && (theColor==4||theColor==13||theColor==12))
			return #FALSE;

		return #TRUE;
	}

	if (tno == 1 && (theColor==2||theColor==13))
		return #TRUE;
	if (tno == 2 && (theColor==9||theColor==4))
		return #TRUE;
	if (tno == 3 && (theColor==12||theColor==5))
		return #TRUE;
	if (tno == 4 && (theColor==11||theColor==3))
		return #TRUE;

	return #FALSE;
};


//==========================//
// The new holograph device //
//==========================//

//WK 6/1/7 TODO: Make Holo animate
void(entity player) UpdateCells =
{
	if (player.items & #IT_CELLS)
		player.currentammo = player.ammo_cells;
	else if (player.current_weapon == #WEAP_SPANNER)
		player.currentammo = player.ammo_cells;
};

void(entity player) ActivateHolo =
{
	if (!(player.cutf_items & #CUTF_HOLO))
	{
		//sprint(player, #PRINT_MEDIUM, "You do not have the holograph!\n");
		return;
	}

	if (player.has_holo == 2) return; // avoids overflow, turns to 1 after first think

	if (player.ammo_cells < 10 && player.has_holo == 0)
	{
		local string st;
		sprint(player, #PRINT_HIGH, "Your holograph needs "); 
		st=ftos(#HOLO_POWER_COST);
		sprint(player, #PRINT_HIGH, st);
		sprint(player, #PRINT_HIGH," cells at least!\n");
		return;
	}

	if (player.has_holo == 1)
	{
		sprint(player, #PRINT_HIGH, "You turn off the holograph device\n");
		RemoveHolo(player);
		return;
	}

	newmis = spawn();
	newmis.solid = #SOLID_NOT;
	newmis.movetype = #MOVETYPE_NOCLIP;
	newmis.origin = player.origin;
	newmis.angles = player.angles;
	newmis.colormap = player.colormap;
	newmis.skin = player.skin;
	setmodel (newmis, "progs/player.mdl");
	newmis.classname = "holo";
	newmis.owner=player;
	newmis.frame=player.frame;
	newmis.nextthink = time + #HOLO_CYCLE_TIME; 
	newmis.think = HoloThink;
//WK 1/15/8 Don't make holo glow, it gives it away too easily
//newmis.effects = #EF_DIMLIGHT;
	newmis.current_weapon = player.current_weapon; //WK 1/15/8 Give holo the weapon in case we want to shoot

	player.ammo_cells = player.ammo_cells - #HOLO_POWER_COST;

	newmis.has_holo = 1; // needed for targeting - has_holo goes to 0 b4 removed
	newmis.team_no = player.team_no;
	newmis.takedamage = #DAMAGE_NO;
	newmis.real_owner = player;
	newmis.netname = "øøø";
	//newmis.health = 1; // needed for tesla?
	
	UpdateCells(player);

	stuffcmd (player, "bf\nbf\n");
	sprint(player,#PRINT_HIGH,"you turn on your holograph...\n");
	//sound (newmis, #CHAN_MISC, "effects/bodyhit2.wav", 0.5, #ATTN_NORM);
	player.has_holo = 2; // 2 makes it wait until first think for turning off the holo 
};

void() player_run;

void() HoloThink =
{
	//local entity oldself;

	//WK 1/15/8 Animate Holo... mimic its player
	self.angles = self.owner.angles;
	self.frame = self.owner.frame;

	if (self.owner.ammo_cells < #HOLO_CYCLE_COST)
	{
		sprint(self.owner, #PRINT_MEDIUM, "your hologram runs out of energy\n");
		//sound (self, #CHAN_MISC, "effects/bodyhit1.wav", 0.6, #ATTN_NORM);
		spawnFOG(self.origin);
		self.owner.has_holo = 0;
		self.has_holo = 0; // notifies to "targeters" as a dead holo
		//self.health = 0;
		dremove(self);
		return;
	}

	self.owner.ammo_cells = self.owner.ammo_cells - #HOLO_CYCLE_COST;

	UpdateCells(self.owner);
	
	self.nextthink = time + #HOLO_CYCLE_TIME;	
	self.owner.has_holo = 1; // ready to be turned off
};

void (entity player) RemoveHolo =
{
	local entity te;
	te = find(world, classname, "holo");
	while (te)
	{
		if (te.owner == player) {
		  te.owner.has_holo = 0;
		  //sound (te, #CHAN_MISC, "effects/bodyhit1.wav", 0.6, #ATTN_NORM);
		  spawnFOG(te.origin);
		  te.has_holo = 0;
		  //te.health = 0;
		  dremove(te);
		  return;
		}

		te = find(te, classname, "holo");
	}
};

//===========================//
// THE FLARES ARE BACK! hehe //
//===========================//

void() FlareBounce;

//---------------------------//
// Flare touch function.	 //

void() FlareGrenadeTouch =
{
	if (other == self.owner)
		return; 	// don't bounce on owner

	if (pointcontents(self.origin) == #CONTENT_SKY || pointcontents(self.origin) == #CONTENT_SOLID) // if in wall or sky
	{
		dremove(self);
		return;
	}

	if (self.has_holo==0)
	{
		self.skin=1;
		//setmodel (self, "progs/flare.mdl");
	}

	if (other == world && self.movetype != #MOVETYPE_BOUNCE)
	{
		self.velocity = '0 0 0';
		
		//WK 6/1/7 Re-enable flare hitting sounds
		if (random()<0.6)
		{
			sound (self, #CHAN_MISC, "effects/bodyhit2.wav", 0.7, #ATTN_NORM);	// bounce sound
		}
		else
		{
			sound (self, #CHAN_MISC, "effects/bodyhit1.wav", 0.6, #ATTN_NORM);	// bounce sound
		}
	}
	else
	{
		self.movetype = #MOVETYPE_BOUNCE;
		self.avelocity = '1000 200 850';
		self.touch = FlareBounce;
	}

	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
	
};

void() FlareBounce =
{
	if (other == self.owner)
		return; 	// don't bounce on owner

   
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//---------------------------//
// Flare grenade explosion.  //

void() FlareGrenadeExplode =
{
	sound (self, #CHAN_MISC, "items/flare1.wav", 1, #ATTN_NORM);

	//setmodel (self, "progs/flare.mdl");
	self.skin=0;
	self.has_holo=1;

	local vector org;
	org=self.origin;

		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
		#ifdef QUAKE_WORLD
			WriteByte (#MSG_MULTICAST, 3);
		#endif
		WriteCoord (#MSG_BROADCAST, org_x);
		WriteCoord (#MSG_BROADCAST, org_y);
		WriteCoord (#MSG_BROADCAST, org_z);
		#ifdef QUAKE_WORLD
			multicast (org, #MULTICAST_PVS);
		#endif

	self.effects = self.effects | #EF_DIMLIGHT;

	self.think = SUB_Remove;
	self.nextthink = time + #FLARE_DURATION;
};

//========================================================//
// My stupid contributions to optimize something!		  //
//========================================================//

float(entity thing) IsMonster =
{
	if (thing.flags & #FL_MONSTER)
		return #TRUE;
	return #FALSE;
};

float(entity thing) IsMonsterNonArmy =
{
	if (thing.flags & #FL_MONSTER && thing.classname != "monster_army")
		return #TRUE;
	
	return #FALSE;
};

float(entity player) HasMonster =
{
	local float res;
	res = 0;

	if ((player.job & #JOB_WARLOCK)
	  ||(player.job & #JOB_ARMY))
	{
		if (player.demon_one)
			res = 1;	 
		if (player.demon_two)
			res = res + 1;
		if (player.demon_three)
			res = res + 1;
	}	 
   
	return res;
};

string(entity themonster) GetMonsterName =
{
	if (themonster.classname == "monster_wizard")
		return "scrag";
	if (themonster.classname == "monster_shambler")
		return "shambler";
	if (themonster.classname == "monster_demon1")
		return "fiend";
	if (themonster.classname == "monster_army")
		return "army soldier";
	if (themonster.classname == "monster_fish")
		return "piranha";
	if (themonster.classname == "monster_gremlin")
		return "gremlin";
	
	return "unknown monster";
};

void(entity themonster) MonsterDie =
{
	//Needed for "die" functions
	local entity oself;
	oself=self;

	self=themonster;

	if (self.th_die)
		self.th_die();

	self=oself;
};

string(entity thebuilding) GetBuildingName =
{
	if (thebuilding.classname == "building_dispenser")
		return "dispenser";
	if (thebuilding.classname == "building_sentrygun")
		return "sentry gun";
	if (thebuilding.classname == "building_tesla")
		return "tesla sentry";
	if (thebuilding.classname == "building_sensor")
		return "motion sensor";
	if (thebuilding.classname == "building_camera")
		return "security camera";
	if (thebuilding.classname == "building_teleporter")
		return "teleporter";
	if (thebuilding.classname == "building_fieldgen")
		return "field generator";

	return "unknown machine";
};

// soldiers don't target unoffensive buildings, or cloaked teslas!
float(entity thebuilding) IsOffenseBuilding =
{
	if (!IsBuilding(thebuilding))
		return #FALSE;

	if (thebuilding.classname == "building_sentrygun") 
		return #TRUE;

	if (thebuilding.classname == "building_tesla")
	{
		if (thebuilding.tf_items & #NIT_TESLA_CLOAKING)  
		{
			if (thebuilding.job == 2)
				return #TRUE; // tesla is uncloaked, so soldier can see it
		}
		else
		{
			return #TRUE;
		}
	}

	return #FALSE;
};

string(entity thething) GetEnemyName =
{
	if (thething.classname == "player")
		return thething.netname;

	if (IsMonster(thething))
		return GetMonsterName(thething);
	
	if (IsBuilding(thething))
		return GetBuildingName(thething);

	if (thething.classname == "grenade" && thething.netname == "land_mine")
		return "land mine";
	
	if (thething.netname != "")
		return thething.netname;
	
	if (thething.classname != "")
		return thething.classname;
	   
	return "unknown stuff";
};

//======================================================//
void() ExpBodyThink;

void(entity body) ExpBody =
{	 
	newmis=spawn();
	newmis.owner=body;
	newmis.think=ExpBodyThink;
	newmis.nextthink=time;	  
	newmis.origin=body.origin;
	newmis.origin_z = newmis.origin_z - 46;
	newmis.origin_x = newmis.origin_x - crandom()*6;
	newmis.origin_y = newmis.origin_y - crandom()*6;
};

void() ExpBodyThink =
{
	if (self.owner.classname != "player" || !self.owner.is_connected)
	{
		dremove(self);
		return;
	}
	
	TF_T_Damage(self.owner, self.owner, self.owner.martyr_enemy, self.owner.health + 60, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);// #TF_TD_OTHER);

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
  #ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
  #endif

	deathmsg = #DMSG_EXPBODY;
	T_RadiusDamage (self.owner, self.owner, #EXPBODY_DMG, self.owner);

	dremove(self);
};

//===========================================//

void(vector where) spawnFOG =
{
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_TELEPORT);
	WriteCoord (#MSG_BROADCAST, where_x);
	WriteCoord (#MSG_BROADCAST, where_y);
	WriteCoord (#MSG_BROADCAST, where_z);
#ifdef QUAKE_WORLD
	multicast (where, #MULTICAST_PHS);
#endif
};

//=========================================================//
// called on any try to dismantle something from menu.qc
// returns true if the thing should be dismantled

float() CheckEnemyDismantle =
{
	if (Teammate(self.building.real_owner, self)) return #TRUE;

	local string st;
	st=GetBuildingName(self.building); 
	
	if (GetICELevel(self.building) == 1 && random() > 0.25)
	{
		sprint(self, #PRINT_HIGH, "This ");
		sprint(self, #PRINT_HIGH, st);
		sprint(self, #PRINT_HIGH, " isn't easy to dismantle, it has a level 1 ICE!\n");

		sprint(self.building.real_owner, #PRINT_HIGH, "Somebody is trying to dismantle your ");
		sprint(self.building.real_owner, #PRINT_HIGH,st);
		sprint(self.building.real_owner, #PRINT_HIGH, "!\n");

		return #FALSE;
	} 
	else if (GetICELevel(self.building) == 2)
	{
		sprint(self, #PRINT_HIGH, "You can't dismantle this ");
		sprint(self, #PRINT_HIGH, st);
		sprint(self, #PRINT_HIGH, ", it's protected with a level 2 ICE!\n");

		sprint(self.building.real_owner, #PRINT_HIGH, "Somebody tried to dismantle your ");
		sprint(self.building.real_owner, #PRINT_HIGH,st);
		sprint(self.building.real_owner, #PRINT_HIGH, "!\n");

		return #FALSE;
	} 
	else if (GetICELevel(self.building) == 3)
	{
		sprint(self, #PRINT_HIGH, "This ");
		sprint(self, #PRINT_HIGH, st);
		sprint(self, #PRINT_HIGH, " is protected with a level 3 ICE!\n");
		deathmsg=#DMSG_ANTIDISM;
		TF_T_Damage(self, self, self.building, self.health + 50, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
		sound (self, #CHAN_MISC, "effects/crunch.wav", 1, #ATTN_NONE);

		return #FALSE;
	}
	
	bprint(#PRINT_MEDIUM, self.building.real_owner.netname);
	bprint(#PRINT_MEDIUM, "'s ");
	bprint(#PRINT_MEDIUM, st);
	bprint(#PRINT_MEDIUM, " has been dismantled by ");
	bprint(#PRINT_MEDIUM, self.netname);
	bprint(#PRINT_MEDIUM, "\n");

	sprint(self.building.real_owner, #PRINT_HIGH, "The enemy has dismantled your ");
	sprint(self.building.real_owner, #PRINT_HIGH, st);
	sprint(self.building.real_owner, #PRINT_HIGH, "!\n");

#ifdef QUAKE_WORLD
	logfrag(self, self.building.real_owner);
#endif
	
	self.real_frags = self.real_frags + 1; 
	if (!(toggleflags & #TFLAG_TEAMFRAGS))
		self.frags = self.real_frags;

	return #TRUE;
};

//- OfN - Checks spots are visible between them
float (vector spot1, vector spot2) vis2orig =
{
	traceline (spot1, spot2, #TL_BSP_ONLY, world);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return #FALSE;			// sight line crossed contents

	if (trace_fraction == 1 && trace_endpos == spot2) //CH just extra check
		return #TRUE;

	return #FALSE;
};

//=========================================================================
// Return the number of players in game
// PZ - use checkIP option to differentiate IP's of users 
//		(counts unique IP's instead of counting players)
// PZ - use noIdlers option to not count players not on a team 
//		(has no effect if checkIP is off)
float(float checkIP, float noIdlers) GetNoPlayers =
{
	if (!checkIP)
		return num_players;

	// PZ - one part stolen from Often's modified bodyque
	// linked list of ip addresses
	local entity ipList; ipList = world; // always the first entity in the list
	local entity element; element = world; // varies with traversal of the list
	local entity player; player = world;
	local string ip;
	local float ipCount; ipCount = 0;
	local float counter;
	local entity pt; pt = world; // first empty slot in list
	local float listed; // bool

	/*
	construct the list
	*/

	counter = 1;
	element = spawn();
	element.ltime = 0;
	element.classname = "playerIP";
	element.modelindex = modelindex_null;
	ipList = element;

	while (counter < num_players)
	{
		element.owner = spawn();
		element.owner.ltime = 0;
		element.owner.classname = "playerIP";
		element.owner.modelindex = modelindex_null;
		
		element = element.owner;

		counter = counter + 1;
	}
	element.owner = world;

	/*
	enter IP's into the list - only if they're not already listed
	*/

	player = find(world, classname, "player");
	while (player != world)
	{
		if (!noIdlers || player.team_no)
		{
			pt = world; // first empty slot in list
			ip = infokey(player, "ip");
			ip = strcat(ip, ""); // this is simply to get around Quake string buffer issue..
								 // a problem which I don't completely understand at the moment

			counter = 1;
			element = ipList;
			listed = #FALSE;
			while (counter <= num_players)
			{
				// is this an empty slot?
				if (element.netname == string_null)
				{
					if (pt == world) // only set pt to this element if pt isn't already set
						pt = element;
				}
				// if this element of the list holds this player's IP ..
				else if (!strcasecmp(element.netname, ip))
				{
					listed = #TRUE;
					break;
				}
				// else continue looking through list
				element = element.owner;
				counter = counter + 1;
			}
			if (!listed) // if the player's IP is not listed, list in first empty slot
			{
				pt.netname = ip;
				ipCount = ipCount + 1;
			}
		}

		player = find(player, classname, "player");
	}

	/*
	clean-up.. remove list
	*/
	
	element = find(world, classname, "playerIP");
	while (element != world)
	{
		dremove(element);
		element = find(element, classname, "playerIP");
	}

	/*
	return the number of individual IP addresses
	*/

	return ipCount;
	// PZ - end
};

//==================================================================
// prints the overall resutls, best player etc.. on intermission

entity() GetBestPlayer =
{
	local float bestscore;//, tempscore;
	local entity theplayer, search;

	theplayer = world;
	search = world;
	bestscore = 0;

	search = find (world, classname, "player");
	while (search != world)
	{
		if (search.frags > bestscore)
		{
			bestscore = search.frags;
			theplayer = search;
		}

		search = find (search, classname, "player");
	}

	return theplayer;
};

entity() GetBestKiller =
{
	local float bestscore;//, tempscore;
	local entity theplayer, search;

	theplayer = world;
	search = world;
	bestscore = 0;

	search = find (world, classname, "player");
	while (search != world)
	{
		if (search.frags - TeamFortress_TeamGetScore(search.team_no) > bestscore && search.team_no > 0)
		{
			bestscore = search.frags - TeamFortress_TeamGetScore(search.team_no);
			theplayer = search;
		}

		search = find (search, classname, "player");
	}

	return theplayer;
};

void() bprintline =
{
	bprint(#PRINT_HIGH,"\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n\n");
};

void() PrintResults =
{
	local string winteam;
	local entity theplayer;    

	local string tmps;
	local float tmpf,tmpf2;
	
	//bprintline();

	bprint(#PRINT_HIGH,"\nùûûûûûûûûûü ≈Ó‰ œÊ «·ÌÂ! ùûûûûûûûûûü\n\n");
	
	if (time >= timelimit)
	{
		bprint(#PRINT_HIGH,"Time limit reached!\n");
	}	 

	tmpf = time/60;
	tmpf2 = floor(tmpf);
	tmps = ftos(tmpf2);

	bprint(#PRINT_HIGH,"Map ");
	bprint(#PRINT_HIGH,mapname);
	bprint(#PRINT_HIGH," was played for ");
	bprint(#PRINT_HIGH,tmps);
	bprint(#PRINT_HIGH," minutes\n");

	bprint(#PRINT_HIGH,"\nùûûûûûûûûûûü “ÂÛıÏÙÛ: ùûûûûûûûûûûûûü\n\n");
		
	winteam = GetTrueTeamName(TeamFortress_TeamGetWinner());

	if (winteam != "ERROR")
	{
		bprint(#PRINT_HIGH,winteam);
		bprint(#PRINT_HIGH," team ◊…Œ” the game!!\n\n");
	}

	TeamFortress_TeamShowScores(3,0,0);
	
	bprint(#PRINT_HIGH,"\n¬ÂÛÙ –Ï·˘ÂÚ: ");
	theplayer = GetBestPlayer();
	
	if (theplayer != world)
	{
		tmpf = floor(theplayer.frags);
		tmps = ftos(tmpf);
		
		bprint(#PRINT_HIGH,theplayer.netname);
		bprint(#PRINT_HIGH," (");
		bprint(#PRINT_HIGH,GetTrueTeamName(theplayer.team_no));
		bprint(#PRINT_HIGH,") with ");
		bprint(#PRINT_HIGH,tmps);
		bprint(#PRINT_HIGH," frags");
	}
	else
		bprint(#PRINT_HIGH,"None");
	
	bprint(#PRINT_HIGH,"\nÀÈÏÏÈÓÁ Õ·„ËÈÓÂ: ");
	theplayer = GetBestKiller();
	
	if (theplayer != world)
	{
		tmpf = floor(theplayer.frags - TeamFortress_TeamGetScore(theplayer.team_no));
		tmps = ftos(tmpf);

		bprint(#PRINT_HIGH,theplayer.netname);
		bprint(#PRINT_HIGH," (");
		bprint(#PRINT_HIGH,GetTrueTeamName(theplayer.team_no));
		bprint(#PRINT_HIGH,") with ");
		bprint(#PRINT_HIGH,tmps);
		bprint(#PRINT_HIGH," kills");
	}
	else
		bprint(#PRINT_HIGH,"None");

	bprint(#PRINT_HIGH,"\n");
	bprintline();
};

//======================================================================================
// called on clientobituary to check if warlock knife kills should be increased

void(entity attacker) MonsterKill =
{
	if (attacker.job & #JOB_WARLOCK)
		if (deathmsg == #DMSG_AXE || deathmsg == #DMSG_BACKSTAB)
			WarlockKnifeKill(attacker);
};

//===============================================================================
// this function returns the max amount of grens a player can carry

float(entity theplayer, float grenslot) GetMaxGrens =
{
	#ifdef GRENADES_TEST
	return 999;
	#endif

	//WK 6/1/7 Stock demoman gets more grenades than custom classes
	if (theplayer.playerclass == #PC_DEMOMAN) {
		if (grenslot == 1) return #PC_DEMOMAN_GRENADE_INIT_1;
		else return #PC_DEMOMAN_GRENADE_INIT_2;
	}
	
	if (theplayer.tf_items & #NIT_AMMO_BANDOLIER) // player can carry more grens cause he got bandolier
	{
		if (grenslot == 2) //2nd slot
		{
			if (theplayer.tp_grenades_2 == 0)
				return 0;

			#ifndef OLD_FLASH
			if (theplayer.tp_grenades_2 == #GR_TYPE_PSIONIC)
				return 4;
			#endif
			
			if (theplayer.tp_grenades_2 == #GR_TYPE_NAIL)
				return 3;// was 1
			if (theplayer.tp_grenades_2 == #GR_TYPE_FRAG)
				return 4;// was 1
			if (theplayer.tp_grenades_2 == #GR_TYPE_CALTROP)
				return 4;// was 1
			if (theplayer.tp_grenades_2 == #GR_TYPE_MIRV)
				return 3;// was 1
			if (theplayer.tp_grenades_2 == #GR_TYPE_FLARE)
				return 6;
			if (theplayer.tp_grenades_2 == #GR_TYPE_NAPALM)
				return 3;

			return 5;
		}
		else // first slot, or bug :)
		{
			if (theplayer.tp_grenades_1 == 0)
				return 0;

			#ifndef OLD_FLASH
			if (theplayer.tp_grenades_1 == #GR_TYPE_PSIONIC)
				return 4;
			#endif

			if (theplayer.tp_grenades_1 == #GR_TYPE_NAIL)
				return 3;// was 1
			if (theplayer.tp_grenades_1 == #GR_TYPE_FRAG)
				return 4;// was 1
			if (theplayer.tp_grenades_1 == #GR_TYPE_CALTROP)
				return 4;// was 1
			if (theplayer.tp_grenades_1 == #GR_TYPE_MIRV)
				return 3;// was 1
			if (theplayer.tp_grenades_1 == #GR_TYPE_FLARE)
				return 6;
			if (theplayer.tp_grenades_1 == #GR_TYPE_NAPALM)
				return 3;
			
			return 5;
		}		 
	}
	
	if (grenslot == 2) //2nd slot
	{
		if (theplayer.tp_grenades_2 == 0)
			return 0;

		#ifndef OLD_FLASH
		if (theplayer.tp_grenades_2 == #GR_TYPE_PSIONIC)
			return 3;
		#endif

		if (theplayer.tp_grenades_2 == #GR_TYPE_NAIL)
			return 2;// was 1
		if (theplayer.tp_grenades_2 == #GR_TYPE_FRAG)
			return 3;// was 1
		if (theplayer.tp_grenades_2 == #GR_TYPE_CALTROP)
			return 3;// was 1
		if (theplayer.tp_grenades_2 == #GR_TYPE_MIRV)
			return 2;// was 1
		if (theplayer.tp_grenades_2 == #GR_TYPE_FLARE)
			return 5;
		if (theplayer.tp_grenades_2 == #GR_TYPE_NAPALM)
			return 2;

		return 4;
	}
	else // first slot, or bug :)
	{
		if (theplayer.tp_grenades_1 == 0)
			return 0;

		#ifndef OLD_FLASH
		if (theplayer.tp_grenades_1 == #GR_TYPE_PSIONIC)
			return 3;
		#endif

		if (theplayer.tp_grenades_1 == #GR_TYPE_NAIL)
			return 2;// was 1
		if (theplayer.tp_grenades_1 == #GR_TYPE_FRAG)
			return 3;// was 1
		if (theplayer.tp_grenades_2 == #GR_TYPE_CALTROP)
			return 3;// was 1
		if (theplayer.tp_grenades_1 == #GR_TYPE_MIRV)
			return 2;// was 1
		if (theplayer.tp_grenades_1 == #GR_TYPE_FLARE)
			return 5;
		if (theplayer.tp_grenades_1 == #GR_TYPE_NAPALM)
			return 2;
		
		return 4;
	}

	return 0; // shouldnt happen ever.
};

//=====================================================//

/*void(entity attacker) Check_PainInflictor =
{
	if (self.health <= 0)
		return;

	local entity real_attacker;
	real_attacker = attacker;

	if (!IsMonster(attacker) && attacker.classname!="player")
	{
		if (!IsMonster(atta
	}
	  
	
	if (self.enemy!=self && self.enemy!=world && self.enemy!=attacker && self.enemy!=attacker.owner)
	{
		if (!visible(self.enemy))
		{
			

		}
	}
};*/
/*

void(entity player) SwitchToCamera =
{
	if (player.classname!="player")
	{
		RPrint("OFTEN BUG REPORT: Object '");
		RPrint(player.classname);
		RPrint("' in SwitchToCamera()\n");
		return;
	}

	local entity camera;
	local float done;
	
	if (!player.has_camera)
		return;
	if (player.is_cameraviewing)
		return;

	 // FIXME: no inair, no water, no moving, no haxxxoring, no building, no detpacking, no throwing a det, 
	 // no feinginG? (special)
	
	camera = find(world, classname, "building_camera");
	if (camera.real_owner == player)
		done = #TRUE;
	while (!done)
	{
		camera = find(camera, classname, "building_camera");
		if (camera.real_owner == player)
			done = #TRUE;
		if (camera == world)
			done = #TRUE;
	}
	
	if (camera == world)
		return;
		
	/*
	
	msg_entity = player;
	WriteByte(#MSG_ONE, #SVC_SETVIEWPORT);
	WriteEntity(#MSG_ONE, camera);
	WriteByte(#MSG_ONE, #SVC_SETANGLES);
	WriteAngle(#MSG_ONE, camera.angles_x);
	WriteAngle(#MSG_ONE, camera.angles_y);
	WriteAngle(#MSG_ONE, camera.angles_z);
	
	*/

	/*

	//- OfN create the "fake" player image
	newmis=spawn();
	newmis.solid = #SOLID_BBOX; //#SOLID_BSP
	newmis.movetype = #MOVETYPE_NONE;
	newmis.takedamage = #DAMAGE_AIM;
	newmis.origin = player.origin;
	newmis.angles = player.angles;
	newmis.colormap = player.colormap;
	newmis.skin = player.skin;
	setmodel (newmis, "progs/player.mdl");
	//setsize (newmis,????); // NEEDED?
	//setorigin (newmis, newmis.origin); // NEEDED?
	newmis.classname = "fake_player";
	newmis.owner=player;
	newmis.frame=player.frame;
	
	newmis.th_pain = FakePain;
	newmis.th_die = FakeDie;
	
	newmis.max_health = 9999;
	newmis.health = 9999;

	//newmis.nextthink = time + #HOLO_CYCLE_TIME;	
	//newmis.think = HoloThink;
	//newmis.effects = #EF_DIMLIGHT;
	//player.ammo_cells = player.ammo_cells - #HOLO_POWER_COST;

	player.fixangle = #TRUE;
	player.is_cameraviewing = #TRUE;
	player.t_s_h = player.weaponmodel; // FIXME: reloadingø?
	player.weaponmodel= ""; // FIXME: reloadingø?
	player.view_ofs = '0 0 0';

	setorigin (player, camera.origin);

	sprint(player, #PRINT_HIGH, "Camera view activated.\n");
};

void(entity player) SwitchFromCamera =
{
	if (player.classname!="player")
	{
		RPrint("OFTEN BUG REPORT: Object '");
		RPrint(player.classname);
		RPrint("' in SwitchFromCamera()\n");
		return;
	}
	
	if (!player.has_camera)
		return;
	if (!player.is_cameraviewing)
		return;
	
	/*
	
	msg_entity = player;
	WriteByte(#MSG_ONE, #SVC_SETVIEWPORT);
	WriteEntity(#MSG_ONE, player);
	WriteByte(#MSG_ONE, #SVC_SETANGLES);
	WriteAngle(#MSG_ONE, player.angles_x);
	WriteAngle(#MSG_ONE, player.angles_y);
	WriteAngle(#MSG_ONE, player.angles_z);
	
	*/

	/*

	player.fixangle = #FALSE;

	player.weaponmodel = player.t_s_h; // FIXME: reloadingø?
	player.view_ofs = '0 0 22';
	
	player.is_cameraviewing = #FALSE;
};

*/

//==========================================================================================================
// used on players after teleporting to a turretized teleport to see if its stuck in wall or outside world

float(entity player) IsOutWorld =
{
	if (pointcontents(player.origin) == #CONTENT_SOLID || pointcontents(player.origin) == #CONTENT_SKY)
		return #TRUE;
	
	if (pointcontents(player.absmax) == #CONTENT_SOLID || pointcontents(player.absmax) == #CONTENT_SKY)
		return #TRUE;

	if (pointcontents(player.absmin) == #CONTENT_SOLID || pointcontents(player.absmin) == #CONTENT_SKY)
		return #TRUE;
   
	return #FALSE;
};

//===================================================================================================
// Removes timers set on anything, used for psionic clean-up on sentries and teslas

/*void(entity thing) RemoveMyTimers =
{
	local entity te;
	
	te = find(world,classname,"timer");

	while(te)
	{
		if (te.owner == thing)
		{
			te.think = SUB_Remove;
			te.nextthink = time + 0.1;
		}

		te = find(te,classname,"timer");
	}
};*/

//=============================================================
// returns FALSE if tesla/sentry is in invalid location

/*
float(entity gun) IsInValidLocation =
{
	local vector tmpvec;

	if (gun.tf_items & #NIT_TURRET)
	{
		if (pointcontents(gun.origin) == #CONTENT_SOLID || pointcontents(gun.origin) == #CONTENT_SKY)
			return #FALSE;
		
		tmpvec = gun.absmax - '1 1 41';

		if (pointcontents(tmpvec) == #CONTENT_SOLID || pointcontents(tmpvec) == #CONTENT_SKY)
			return #FALSE;

		tmpvec = gun.absmin + '1 1 -11';

		if (pointcontents(tmpvec) == #CONTENT_SOLID || pointcontents(tmpvec) == #CONTENT_SKY)
			return #FALSE;
	}
	else
	{
		if (pointcontents(gun.origin) == #CONTENT_SOLID || pointcontents(gun.origin) == #CONTENT_SKY)
			return #FALSE;
		
		tmpvec = gun.absmax - '1 1 1';

		if (pointcontents(tmpvec) == #CONTENT_SOLID || pointcontents(tmpvec) == #CONTENT_SKY)
			return #FALSE;

		tmpvec = gun.absmin + '1 1 1';

		if (pointcontents(tmpvec) == #CONTENT_SOLID || pointcontents(tmpvec) == #CONTENT_SKY)
			return #FALSE;
	}
   
	return #TRUE;
};*/


float(float imp) GoodIntermissionImpulse =
{
	if (imp == #TF_STATUS_QUERY ||
	imp == #TF_DISPLAYLOCATION	 ||
	imp == #TF_STATUS_QUERY ||
	imp == #TF_HELP_MAP ||
	imp == #TF_SHOWTF ||
	imp == #I_CHEAT_ONE ||
	imp == #I_CHEAT_TWO ||
	imp == #I_CHEAT_THREE || 
	//imp == #IMPULSE_PUNISH ||
	//imp == #IMPULSE_VOTEMAP ||
	imp == #IMPULSE_VOTEYES ||
	imp == #IMPULSE_VOTENO)
	//inp == #IMPULSE_TESTRANGE)
	return #TRUE;

	return #FALSE;
};

//==================================================================
// Returns TRUE if a server update is taking place

float() ServerUpdating =
{
	if (cvar("sv_updating")==0)
		return #FALSE;

	return #TRUE;
};

//============================================================
// Reports current server main settings

void(float broadcastmsg) PrintGameSettings =
{
	local string st, temp;
	local float fl, fl2;

	st = strcat("\nùûûûûûûü Õ·ÈÓ «·ÌÂ ”ÂÙÙÈÓÁÛ ùûûûûûûü\nÕ·: ¢",mapname);

	st = strcat(st, "¢ ú ‘ÈÌÂ ÃÂÊÙ: ");

	if (timelimit <= 0)
		st = strcat(st,"No limit");
	else
	{
		if (time >= timelimit)
			return;

		fl = floor(((timelimit - time)/60)/60);
		temp = ftos(fl);
		st = strcat(st,temp);
		st = strcat(st,"∫");

		fl2 = floor((timelimit - time)/60);
		fl = fl2 - (fl*60);
		temp = ftos(fl);
		if (strlen(temp)< 2)
			st = strcat(st,"0");	
		st = strcat(st,temp);
		st = strcat(st,"∫");
		
		fl = floor(timelimit - time) - (fl2*60);
		temp = ftos(fl);
		if (strlen(temp)< 2)
			st = strcat(st,"0");	
		st = strcat(st,temp);	 
	}

	st = strcat(st,"\n√ıÛÙÔÌ");

	if (custom_mode == 0)
	{
		temp = ftos(custom_money);
		temp = colstr(temp,#COLSTR_NUMBER);

		st = strcat(st,": Enabled ú ÕÔÓÂ˘: ");
		st = strcat(st,temp);		 
	}
	else
		st = strcat(st," √Ï·ÛÛÂÛ: Disabled");

	// first step printing purge (due to strcat limit)
	if (broadcastmsg)
		bprint(#PRINT_HIGH,st);
	else
		sprint(self,#PRINT_HIGH,st);
	
	st = "";

	st = strcat(st,"\n≈ÓˆÈÚÔÓÌÂÓÙ: ");

	if (!(storm | earthquake | daytime | runes))
		st = strcat(st,"Standard World");
	else
	{
		local float first;

		first = #TRUE;

		if (storm != 0)
		{
			st = strcat(st,"Lightning Storm º");
			temp = ftos(floor(storm*100));
			temp = colstr(temp,#COLSTR_NUMBER);
			st = strcat(st,temp);
			st = strcat(st,"•©");
			
			first = #FALSE;
		}

		if (earthquake != 0)
		{
			if (first)
				st = strcat(st,"EarthQuakes º");
			else
				st = strcat(st,"\n             EarthQuakes º");

			temp = ftos(floor(earthquake*100));
			temp = colstr(temp,#COLSTR_NUMBER);
			st = strcat(st,temp);
			st = strcat(st,"•©");

			first = #FALSE;
		}

		// second step printing (due to strcat limit)
		if (broadcastmsg)
			bprint(#PRINT_HIGH,st);
		else
			sprint(self,#PRINT_HIGH,st);
	
		st = "";

		if (daytime != 0)
		{
			if (first)
				st = strcat(st,"Day Light º");
			else
				st = strcat(st,"\n             Day Light º");

			temp = ftos(floor(daytime));
			temp = colstr(temp,#COLSTR_NUMBER);
			st = strcat(st,temp);
			st = strcat(st," ‰·˘Û©");
			
			first = #FALSE;
		}		 

		if (runes != 0)
		{
			if (first)
				st = strcat(st,"Ancient Runes º");
			else
				st = strcat(st,"\n             Ancient Runes º");

			temp = ftos(floor(runes));
			temp = colstr(temp,#COLSTR_NUMBER);
			st = strcat(st,temp);
			st = strcat(st,"©");
		}
	}

	// third step printing (due to strcat limit)
	if (broadcastmsg)
		bprint(#PRINT_HIGH,st);
	else
		sprint(self,#PRINT_HIGH,st);

	//st = "\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n\n";
	st = "\n\n";

	// 4th step printing (due to strcat limit)
	if (broadcastmsg)
		bprint(#PRINT_HIGH,st);
	else
		sprint(self,#PRINT_HIGH,st);
};

//==========================================================================
// Used on TF_T_Damage, returns the outgoing damage multiplier for entity

float(entity attacker, entity targ) GetDamageOutFactor =
{
	local float factor;
	factor = 1;
	
	//WK 8/4/7 Changed the code so that only the best damage multiplier works now.
	if (attacker.super_damage_finished > time) {
		if (attacker.job & #JOB_BERSERKER && attacker.job & #JOB_ACTIVE)
			factor = #BERSERKER_DMGFACTOR;
		if (attacker.tfstate & #TFSTATE_INSPIRED)
			if (factor < #CHAPLAN_DMGFACTOR) factor = #CHAPLAN_DMGFACTOR;
		if (attacker.job & #JOB_TKD && attacker.martyr_enemy != targ)
			if (factor < 1.5) factor = 1.15; //WK 5-15-08 We do only a little more when quadded in TKD to people not our enemy
		if (factor == 1) factor = 4; // Else, we have quad
	}
	// modded for Neo mode
	if (attacker.aura == #AURA_POWER)
		if (factor < #POWERAURA_DMGFACTOR) factor = #POWERAURA_DMGFACTOR;

	if (!neo)
	{
		if (attacker.#runes & #RUNE_TRIAD)
			if (factor < 3) factor = 3;
	  
		if (factor > #MAX_OUT_DMGFACTOR) //Not really needed now that they don't stack, but leave in for sanity
			factor = #MAX_OUT_DMGFACTOR;
	}
	else if (neoLives == attacker)
		factor = factor * neoDamageFactor;
	// end Neo mod

	return factor;
};

//==========================================================================
// Used on TF_T_Damage, returns the incoming damage multiplier for entity

float(entity thing) GetDamageInFactor =
{
	local float factor;
	factor = 1;

	if (thing.aura == #AURA_RESIS)
		factor = factor * #RESISAURA_DMGFACTOR;

	if (thing.tfstate & #TFSTATE_INSPIRED) //Chaplan defense
		factor = factor * #CHAPLAN_DEFENSE_DMGFACTOR;

	// modded for Neo mode
	if (!neo)
	{
		if (thing.#runes & #RUNE_RESIS)
			factor = factor * #RESISRUNE_DMGFACTOR;
	   
		if (factor < #MIN_IN_DMGFACTOR)
			factor = #MIN_IN_DMGFACTOR;
	}
	else if (neoLives == thing)
	{
		factor = factor * neoResistFactor;

		if (factor < 0.05)
			factor = 0.05; // make sure he never ends up impossible to kill because of Resist
	}

	if (factor > 1) bprint(#PRINT_HIGH, "Error: GetDamageInFactor() result greater than 1\n");
	// end Neo mod

	return factor;
};

//=========================================================================
// Used to muzzle flash any entity

void(entity ent) MuzzleFlash =
{
	#ifdef QUAKE_WORLD
	WriteByte (#MSG_MULTICAST, #SVC_MUZZLEFLASH);
	WriteEntity (#MSG_MULTICAST, ent);
	multicast (ent.origin, #MULTICAST_PVS);
	#else
	ent.effects = ent.effects | #EF_MUZZLEFLASH;
	#endif
};

//===========================================================================
// This is used for any leg damage performed, returns the damage done if any

float(entity player, float damage) HurtLegs =
{
	local float excess;
	excess = 0;

	if (player.classname != "player") return 0;
	
	if (player.#runes & #RUNE_RESIS)
		return 0;

	player.leg_damage = player.leg_damage + damage;
	//WK 6/1/7 Cap leg_damage at 8 (80% slowdown)
	if (player.leg_damage > 8) {
		excess = player.leg_damage - 8;
		player.leg_damage = 8;
	}

	TeamFortress_SetSpeed(player);

	return damage-excess;
};

//==========================================================================
// This restores leg damage on player

void(entity player) HealLegs =
{
	if (player.classname != "player") return;

	player.leg_damage = 0;
	TeamFortress_SetSpeed(player);
};

//==========================================================================
// Displays a lesson when a player really needs it :P (ban/kick etc..)

#define FINAL_PREDEF_MSG_TK    "You are supposed to not kill your\nteammates in this game, if you are\nunable to understand that you better\ngo to play on another server.\n"
#define FINAL_PREDEF_MSG_CHEAT "Don't cheat on this server please,\nwe all want to play and have fun here.\nPeople that cheat spoil the game, and\nwill not be tolerated.\n"

void(entity player, string st, float action, float predefined) PlayerFinal =
{
	if (player.classname != "player")
		return;
	
	local entity oself;
	oself = self;
			
	self = player;

	self.message = "";
	
	// Throw gib/head stuff if appropiate only
	if (!(self.done_custom & #CUSTOM_BUILDING)) // customizing, so nope
	if (!(self.playerclass == #PC_UNDEFINED))	// observing, so nope
	if (self.modelindex == modelindex_player)	// are we visible and on a player model? (not a head)
		GibPlayerOut(); // ok, gib him

	CleanUpEverything(#TRUE);

	// Drop any runes he would carry
	PlayerDropRunes(self);

	player.effects = 0;
	player.job = 0;
	player.current_menu = 0;
	player.items = 0;
	player.weapon = 0;
	player.weapons_carried = 0;
	player.cutf_items = 0;
	player.cutf2_items = 0;
	player.tf_items = 0;
	player.aura = 0;
	player.takedamage = 0;
	player.tfstate = 0;

	player.flags = player.flags | #FL_FINALIZED; // Our server code ignores centerprints for players with this set, any centerprint clears the FINALE text

	// QF guys told me the following does nothing on player entity but..
	self.solid = #SOLID_NOT;
	self.movetype = #MOVETYPE_NONE; 
	//-
	
	self.modelindex = modelindex_null;
	setsize(self, '0 0 0', '0 0 0');
	self.touch = SUB_Null;
	self.velocity = '0 0 0';
	self.gravity = 0;
	self.playerclass = #PC_UNDEFINED;

	msg_entity = self;
	WriteByte (#MSG_ONE, #SVC_FINALE);
		
	if (predefined == 1)
		WriteString(#MSG_ONE,#FINAL_PREDEF_MSG_TK);
	else if (predefined == 2)
		WriteString(#MSG_ONE,#FINAL_PREDEF_MSG_CHEAT);
	else
		WriteString (#MSG_ONE, st);

	self.health = 0;
	self.deadflag = #DEAD_DEAD; 

	stuffcmd(self,"color 1 1\n");

	if (action == 1)
		stuffcmd(self,"team kick\n");
	else if (action == 2)
		stuffcmd(self,"team ban\n");
	else
		stuffcmd(self,"team serm\n");

	if (action == 2)
		sprint(self,#PRINT_HIGH,"You are going to be banned after reading the sermon, if you disconnect you will be banned anyway, so better read it!\n");

	self.dont_do_triggerwork = action;

	self.ex_skill_max = time;
	self.ex_skill_min = time + #FINALIZED_RATE_TEAMFLASH;
	self.option2 = #FALSE;

	self = oself;	 
};

void() FinalizedPerformAction =
{
	local string foo;

	if (self.dont_do_triggerwork == 2) // Ban
	{
		bprint(#PRINT_HIGH, self.netname);
		bprint(#PRINT_HIGH, " is ¬¡ŒŒ≈ƒ after the sermon\n");

		sprint(self,#PRINT_HIGH,"\nYou have been ¬¡ŒŒ≈ƒ from the server!\n");
		
		foo = infokey(self,"ip");
		localcmd("addip ");
		localcmd(foo);
		localcmd("\n");

		self.dont_do_triggerwork = 4;

		stuffcmd(self, "disconnect\n"); //Kick them!

		BroadcastSound("player/teledth1");
	}
	else if (self.dont_do_triggerwork == 1) // Kick
	{
		bprint(#PRINT_HIGH, self.netname);
		bprint(#PRINT_HIGH, " is À…√À≈ƒ after the sermon\n");

		sprint(self,#PRINT_HIGH,"\nYou have been À…√À≈ƒ from the server!\n");
		
		stuffcmd(self, "disconnect\n"); //Kick them!

		BroadcastSound("player/teledth1");
	}
	else
	{
		self.dont_do_triggerwork = 4; // Stop team flashes
	}
};

//=========================================================================
// Improved/extended SpawnBlood()

void(vector where, float bloodtype, float bloodammount) SpawnBloodEx =
{
	if (random() < bloodtype)
	{
		WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_MULTICAST, #TE_LIGHTNINGBLOOD);
		WriteCoord (#MSG_MULTICAST, where_x);
		WriteCoord (#MSG_MULTICAST, where_y);
		WriteCoord (#MSG_MULTICAST, where_z);
		multicast (where, #MULTICAST_PVS);
	}
	else
	{
		WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_MULTICAST, #TE_BLOOD);
		WriteByte (#MSG_MULTICAST, bloodammount);
		WriteCoord (#MSG_MULTICAST, where_x);
		WriteCoord (#MSG_MULTICAST, where_y);
		WriteCoord (#MSG_MULTICAST, where_z);
		multicast (where, #MULTICAST_PVS);
	}
};

//==========================================================================
// Same thing but for spike particles instead

void(vector where, float spiketype) SpawnSpikeFX =
{
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	if (random() < spiketype)
		WriteByte (#MSG_BROADCAST, #TE_SUPERSPIKE);
	else
		WriteByte (#MSG_BROADCAST, #TE_SPIKE);
	WriteCoord (#MSG_BROADCAST, where_x);
	WriteCoord (#MSG_BROADCAST, where_y);
	WriteCoord (#MSG_BROADCAST, where_z);
	multicast (where, #MULTICAST_PHS);
};

//=========================================================================================
// Does effect stuff on the entity ala SpawnBlood but with the specified type of blood
// Also takes into account the type of effect, if player is invincible, or target is
// a machine or bsp solid, no blood and does spike effect stuff instead

void(entity targetent, vector where, float spiketype, float bloodtype, float bloodammount) SpawnDmgFX =
{
	// If the specified spot is in sky, do nothing
	if (pointcontents(where) == #CONTENT_SKY)
		return;
	
	// handle effect on BSP
	if (targetent == world || targetent.solid == #SOLID_BSP)
	{		 
		SpawnSpikeFX(where,spiketype);
		return;
	}

	// Solid models that doesnt take damage
	if (targetent.takedamage == #DAMAGE_NO)
	{
		SpawnSpikeFX(where,spiketype);
		return;
	}

	// handle effect on machines
	if (IsBuilding(targetent))
	{
		SpawnSpikeFX(where,spiketype);		  
		return;
	}

	// handle effect on monsters
	if (IsMonster(targetent))
	{
		SpawnBloodEx(where,bloodtype,bloodammount);
		return;
	}

	// handle effect on players
	if (targetent.classname == "player") 
	{
		if (!targetent.is_connected) return;
		if (targetent.health <= 0) return;
		if (targetent.done_custom & #CUSTOM_BUILDING) // skip ppl customizing
			return;
		if (targetent.playerclass == #PC_UNDEFINED) // skip observers
			return;

		// If invincible spawn spike particle
		if ((targetent.invincible_finished > time) || (targetent.items & #IT_INVULNERABILITY))
			SpawnSpikeFX(where,spiketype);
		else // Otherwise just bleed..
			SpawnBloodEx(where,bloodtype,bloodammount);
	}
};

//========================================================================
// Returns TRUE if a player has enough ammo to build something

float(entity player, float buildtype) EnoughToBuild =
{
	if (buildtype == #BUILD_SECURITY_CAMERA)
	{
		if (player.ammo_cells >= #BUILD_COST_CAMERA)
			return #TRUE;
	}
	else if (buildtype == #BUILD_SENSOR)
	{
		if (player.ammo_cells >= #BUILD_COST_SENSOR)
			return #TRUE;
	}
	else if (buildtype == #BUILD_DISPENSER)
	{
		if (player.ammo_cells >= #BUILD_COST_DISPENSER)
			return #TRUE;
	}
	else if (buildtype == #BUILD_SENTRYGUN)
	{
		if (player.ammo_cells >= #BUILD_COST_SENTRYGUN)
			return #TRUE;
	}
	else if (buildtype == #BUILD_TESLA)
	{
		if (player.ammo_cells >= #BUILD_COST_TESLA)
			return #TRUE;
	}
	else if (buildtype == #BUILD_FIELDGEN)
	{
		if (player.ammo_cells >= #BUILD_COST_FIELDGEN)
			return #TRUE;
	}
	else if (buildtype == #BUILD_TELEPORTER)
	{
		if (player.ammo_cells >= #BUILD_COST_TELEPORTER)
			return #TRUE;
	}
	
	return #FALSE;
};

//=============================================================================
// Subroutine to engage a map change, takes stuff into account

void() ExecCycleStandard;

void(string nfmap) LaunchMap =
{
	local string temp;

	bprint(#PRINT_HIGH,"\nLoading ");
	bprint(#PRINT_HIGH,nfmap);
	bprint(#PRINT_HIGH," map file...\n");

	localcmd("localinfo nmap \"\"\n");

	ExecCycleStandard();
	
	// Set a local indicating map to be executed - used only only for timeout/error timers report
	localcmd("localinfo tmap \"");
	localcmd(nfmap);
	localcmd("\"\n");

	// execute map cfg
	temp = infokey(world, "cycledir");
	if ( temp == string_null )
		localcmd("exec #DEFAULT_CYCLEDIR/");
	else
	{
		localcmd("exec ");
		localcmd(temp);
		localcmd("/");
	} //.................//

	localcmd(nfmap);
	localcmd(".cfg\n");

	// Set timeout timer just in case couldn't launch map yet
	SetCycleTimeoutTimer();
};

void() ExecCycleStandard =
{
	if (infokey(world,"specialmap")!="") return;

	local string temp;
		
	// Exec "standard.cfg" also to reset stuff if needed if changed by any custom map
	temp = infokey(world, "cycledir");
	if ( temp == string_null )
		localcmd("exec #DEFAULT_CYCLEDIR/");
	else
	{
		localcmd("exec ");
		localcmd(temp);
		localcmd("/");
	} 

	localcmd("standard.cfg\n");
};

//=============================================================================
// Removes the stuff that is currently disallowed on a player

float(entity player) StripDisallowed =
{
	if (!(disabledstuff1 | disabledstuff2 | disabledstuff3 | disabledstuff4 | disabledstuff5))
		return 0;

	local float itemid, counter;

	counter = 0;

	if (disabledstuff1)
	{
		itemid = 1;
	
		while (itemid < 22)
		{
			if (disabledstuff1 & itob(itemid))
			if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}

	if (disabledstuff2)
	{
		itemid = 25;

		while (itemid < 22 + 24)
		{
			if (disabledstuff2 & itob(itemid - 24))
			if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}
	
	if (disabledstuff3)
	{
		itemid = 25+24;

		while (itemid < 22 + 24 + 24)
		{
			if (disabledstuff3 & itob(itemid - (24+24)))
			if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}
	
	if (disabledstuff4)
	{
		itemid = 25+24+24;

		while (itemid < 22 + 24 + 24 + 24)
		{
			if (disabledstuff4 & itob(itemid - (24+24+24)))
			if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}
	
	if (disabledstuff5)
	{
		itemid = 25+24+24+24;

		while (itemid < 22 + 24 + 24 + 24 + 24)
		{
			if (disabledstuff5 & itob(itemid - (24+24+24+24)))
			if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}

	if (counter)
	{
		local entity oself;
		oself = self;
		self = player;
		self.current_weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		
		UpdateWeaponItems();
		self = oself;		 
	}

	return counter;
};

//====================================================================================================
// Removes an specific item from a player, storing change for restore, or cleaning up stored flag

float(entity player, float itemid, float storechange, float resetstored) StripSpecificItem =
{
	local float done;
	done = #FALSE;
	
	// PAGE 1 - Primary Weapons
	if (itemid == 1)
	{
		if (player.weapons_carried & #WEAP_SNIPER_RIFLE)
		{
			player.weapons_carried = player.weapons_carried - (player.weapons_carried & (#WEAP_SNIPER_RIFLE | #WEAP_AUTO_RIFLE));
			done = #TRUE;
		}		 
	}	
	else if (itemid == 2)
	{
		if (player.weapons_carried & #WEAP_ASSAULT_CANNON)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_ASSAULT_CANNON;
			done = #TRUE;
		}		 
	}
	else if (itemid == 3)
	{
		if (player.weapons_carried & #WEAP_ROCKET_LAUNCHER)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_ROCKET_LAUNCHER;
			done = #TRUE;
		}		 
	}
	else if (itemid == 4)
	{
		if (player.weapons_carried & #WEAP_INCENDIARY) 
		{
			player.weapons_carried = player.weapons_carried - (player.weapons_carried & (#WEAP_INCENDIARY | #WEAP_FLAMETHROWER));
			done = #TRUE;
		}		 
	}  
	else if (itemid == 5)
	{
		if (player.weapons_carried & #WEAP_GRENADE_LAUNCHER)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_GRENADE_LAUNCHER;
			done = #TRUE;
		}		 
	}
	else if (itemid == 6)
	{
		if (player.weapons_carried & #WEAP_LIGHTNING)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_LIGHTNING;
			done = #TRUE;
		}		 
	}
	else if (itemid == 7)
	{
		if (player.weapons_carried & #WEAP_LIGHT_ASSAULT)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_LIGHT_ASSAULT;
			done = #TRUE;
		}		 
	}

	// PAGE 2 - Secondary Weapons
	else if (itemid == 8)
	{
		if (player.weapons_carried & #WEAP_SNG)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_SNG;
			done = #TRUE;
		}		 
	}	
	else if (itemid == 9)
	{
		if (player.cutf_items & #CUTF_KNIFE)
		{
			player.cutf_items = player.cutf_items - #CUTF_KNIFE;
			done = #TRUE;
		}		 
	}
	else if (itemid == 10)
	{
		if (player.weapons_carried & #WEAP_SUPER_SHOTGUN)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_SUPER_SHOTGUN;
			done = #TRUE;
		}		 
	}
	else if (itemid == 11)
	{
		if (player.weapons_carried & #WEAP_RAILGUN) 
		{
			player.weapons_carried = player.weapons_carried - #WEAP_RAILGUN;
			done = #TRUE;
		}		 
	}  
	else if (itemid == 12)
	{
		if (player.weapons_carried & #WEAP_NAILGUN)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_NAILGUN;
			done = #TRUE;
		}		 
	}
	else if (itemid == 13)
	{
		if (player.weapons_carried & #WEAP_TRANQ)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_TRANQ;
			done = #TRUE;
		}		 
	}
	else if (itemid == 14)
	{
		if (player.weapons_carried & #WEAP_SHOTGUN)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_SHOTGUN;
			done = #TRUE;
		}		 
	}

	// PAGE 3 - Misc/Extra Weapons
	else if (itemid == 15)
	{
		if (player.weapons_carried & #WEAP_MAUSER)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_MAUSER;
			done = #TRUE;
		}		 
	}	
	else if (itemid == 16)
	{
		if (player.weapons_carried & #WEAP_AIRF)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_AIRF;
			done = #TRUE;
		}		 
	}
	else if (itemid == 17)
	{
		if (player.cutf_items & #CUTF_AIRFISTUPGRADE)
		{
			player.cutf_items = player.cutf_items - #CUTF_AIRFISTUPGRADE;
			done = #TRUE;
		}		 
	}
	else if (itemid == 18)
	{
		if (player.weapons_carried & #WEAP_DAEDALUS) 
		{
			player.weapons_carried = player.weapons_carried - #WEAP_DAEDALUS;
			done = #TRUE;
		}		 
	}  
	else if (itemid == 19)
	{
		if (player.weapons_carried & #WEAP_LASERCANNON)
		{
			player.weapons_carried = player.weapons_carried - #WEAP_LASERCANNON;
			done = #TRUE;
		}		 
	}
	else if (itemid == 20)
	{
		if (player.cutf_items & #CUTF_HOLO)
		{
			player.cutf_items = player.cutf_items - #CUTF_HOLO;
			done = #TRUE;
		}		 
	}
	else if (itemid == 21)
	{
		if (player.cutf_items & #CUTF_CLIPEXTEND)
		{
			player.cutf_items = player.cutf_items - #CUTF_CLIPEXTEND;
			done = #TRUE;
		}		 
	}

	// (skipped: Legs and Health)...

	// PAGE 6 - Special Armors & Ammo
	else if (itemid == 39)
	{
		if (player.tf_items & #NIT_CERAMIC)
		{
			player.tf_items = player.tf_items - #NIT_CERAMIC;
			done = #TRUE;
		}		 
	}	
	else if (itemid == 40)
	{
		if (player.tf_items & #NIT_GEL)
		{
			player.tf_items = player.tf_items - #NIT_GEL;
			done = #TRUE;
		}		 
	}
	else if (itemid == 41)
	{
		if (player.tf_items & #NIT_ASBESTOS)
		{
			player.tf_items = player.tf_items - #NIT_ASBESTOS;
			done = #TRUE;
		}		 
	}
	else if (itemid == 42)
	{
		if (player.tf_items & #NIT_KEVLAR) 
		{
			player.tf_items = player.tf_items - #NIT_KEVLAR;
			done = #TRUE;
		}		 
	}  
	else if (itemid == 43)
	{
		if (player.tf_items & #NIT_BLAST)
		{
			player.tf_items = player.tf_items - #NIT_BLAST;
			done = #TRUE;
		}		 
	}
	else if (itemid == 44)
	{
		if (player.tf_items & #NIT_AMMO_BACKPACK)
		{
			player.tf_items = player.tf_items - #NIT_AMMO_BACKPACK;
			done = #TRUE;
		}		 
	}
	else if (itemid == 45)
	{
		if (player.tf_items & #NIT_AMMO_BANDOLIER)
		{
			player.tf_items = player.tf_items - #NIT_AMMO_BANDOLIER;
			done = #TRUE;
		}		 
	}
	
	if (done)
	{
		if (storechange)
			SetItemInside(player,0,itemid,#TRUE);
	}

	if (resetstored)
		SetItemInside(player,1,itemid,#FALSE);

	return done;
};

//====================================================================================================
// Gives an specific item to a player, storing change for restore, or cleaning up stored flag

float(entity player, float itemid, float storechange, float resetstored) GiveSpecificItem =
{
	local float done;
	done = #FALSE;
	
	// PAGE 1 - Primary Weapons
	if (itemid == 1)
	{
		if (!player.weapons_carried & #WEAP_SNIPER_RIFLE)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_SNIPER_RIFLE | #WEAP_AUTO_RIFLE;
			done = #TRUE;
		}		 
	}
	else if (itemid == 2)
	{
		if (!player.weapons_carried & #WEAP_ASSAULT_CANNON)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_ASSAULT_CANNON;
			done = #TRUE;
		}		 
	}
	else if (itemid == 3)
	{
		if (!player.weapons_carried & #WEAP_ROCKET_LAUNCHER)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_ROCKET_LAUNCHER;
			done = #TRUE;
		}		 
	}
	else if (itemid == 4)
	{
		if (!player.weapons_carried & #WEAP_INCENDIARY)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_INCENDIARY | #WEAP_FLAMETHROWER;
			done = #TRUE;
		}		 
	}
	else if (itemid == 5)
	{
		if (!player.weapons_carried & #WEAP_GRENADE_LAUNCHER)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_GRENADE_LAUNCHER;
			done = #TRUE;
		}		 
	}
	else if (itemid == 6)
	{
		if (!player.weapons_carried & #WEAP_LIGHTNING)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_LIGHTNING;
			done = #TRUE;
		}		 
	}
	else if (itemid == 7)
	{
		if (!player.weapons_carried & #WEAP_LIGHT_ASSAULT)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_LIGHT_ASSAULT;
			done = #TRUE;
		}		 
	}

	// PAGE 2 - Secondary Weapons
	else if (itemid == 8)
	{
		if (!player.weapons_carried & #WEAP_SNG)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_SNG;
			done = #TRUE;
		}		 
	}
	else if (itemid == 9)
	{
		if (!player.cutf_items & #CUTF_KNIFE)
		{
			player.cutf_items = player.cutf_items | #CUTF_KNIFE;
			done = #TRUE;
		}		 
	}
	else if (itemid == 10)
	{
		if (!player.weapons_carried & #WEAP_SUPER_SHOTGUN)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_SUPER_SHOTGUN;
			done = #TRUE;
		}		 
	}
	else if (itemid == 11)
	{
		if (!player.weapons_carried & #WEAP_RAILGUN)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_RAILGUN;
			done = #TRUE;
		}		 
	}
	else if (itemid == 12)
	{
		if (!player.weapons_carried & #WEAP_NAILGUN)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_NAILGUN;
			done = #TRUE;
		}		 
	}
	else if (itemid == 13)
	{
		if (!player.weapons_carried & #WEAP_TRANQ)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_TRANQ;
			done = #TRUE;
		}		 
	}
	else if (itemid == 14)
	{
		if (!player.weapons_carried & #WEAP_SHOTGUN)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_SHOTGUN;
			done = #TRUE;
		}		 
	}
	
	// PAGE 3 - Misc/Extra Weapons
	else if (itemid == 15)
	{
		if (!player.weapons_carried & #WEAP_MAUSER)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_MAUSER;
			done = #TRUE;
		}		 
	}
	else if (itemid == 16)
	{
		if (!player.weapons_carried & #WEAP_AIRF)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_AIRF;
			done = #TRUE;
		}		 
	}
	else if (itemid == 17)
	{
		if (!player.cutf_items & #CUTF_AIRFISTUPGRADE)
		{
			player.cutf_items = player.cutf_items | #CUTF_AIRFISTUPGRADE;
			done = #TRUE;
		}		 
	}
	else if (itemid == 18)
	{
		if (!player.weapons_carried & #WEAP_DAEDALUS)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_DAEDALUS;
			done = #TRUE;
		}		 
	}
	else if (itemid == 19)
	{
		if (!player.weapons_carried & #WEAP_LASERCANNON)
		{
			player.weapons_carried = player.weapons_carried | #WEAP_LASERCANNON;
			done = #TRUE;
		}		 
	}
	else if (itemid == 20)
	{
		if (!player.cutf_items & #CUTF_HOLO)
		{
			player.cutf_items = player.cutf_items | #CUTF_HOLO;
			done = #TRUE;
		}		 
	}
	else if (itemid == 21)
	{
		if (!player.cutf_items & #CUTF_CLIPEXTEND)
		{
			player.cutf_items = player.cutf_items | #CUTF_CLIPEXTEND;
			done = #TRUE;
		}		 
	}

	// (skipped: Legs and Health)...

	// PAGE 6 - Special Armors & Ammo
	else if (itemid == 39)
	{
		if (!player.tf_items & #NIT_CERAMIC)
		{
			player.tf_items = player.tf_items | #NIT_CERAMIC;
			done = #TRUE;
		}		 
	}
	else if (itemid == 40)
	{
		if (!player.tf_items & #NIT_GEL)
		{
			player.tf_items = player.tf_items | #NIT_GEL;
			done = #TRUE;
		}		 
	}
	else if (itemid == 41)
	{
		if (!player.cutf_items & #NIT_ASBESTOS)
		{
			player.cutf_items = player.cutf_items | #NIT_ASBESTOS;
			done = #TRUE;
		}		 
	}
	else if (itemid == 42)
	{
		if (!player.tf_items & #NIT_KEVLAR)
		{
			player.tf_items = player.tf_items | #NIT_KEVLAR;
			done = #TRUE;
		}		 
	}
	else if (itemid == 43)
	{
		if (!player.tf_items & #NIT_BLAST)
		{
			player.tf_items = player.tf_items | #NIT_BLAST;
			done = #TRUE;
		}		 
	}
	else if (itemid == 44)
	{
		if (!player.cutf_items & #NIT_AMMO_BACKPACK)
		{
			player.cutf_items = player.cutf_items | #NIT_AMMO_BACKPACK;
			done = #TRUE;
		}		 
	}
	else if (itemid == 45)
	{
		if (!player.cutf_items & #NIT_AMMO_BANDOLIER)
		{
			player.cutf_items = player.cutf_items | #NIT_AMMO_BANDOLIER;
			done = #TRUE;
		}		 
	}

	if (done)
	{
		if (storechange)
			SetItemInside(player,1,itemid,#TRUE);		 
	}

	if (resetstored)
		SetItemInside(player,0,itemid,#FALSE);

	return done;
};

//==================================================================================
// Gives the free stuff to the player (no cost and every1 gets it)

float(entity player) GiveFreeStuff =
{
	if (!(givenstuff1 | givenstuff2 | givenstuff3 | givenstuff4 | givenstuff5))
		return 0;

	local float itemid, counter;
	local entity oself;
	
	counter = 0;
	
	if (givenstuff1)
	{
		itemid = 1;

		while (itemid < 22)
		{
			if (givenstuff1 & itob(itemid))
			if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}
	
	if (givenstuff2)
	{
		itemid = 25;

		while (itemid < 22 + 24)
		{
			if (givenstuff2 & itob(itemid - 24))
			if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}
	
	if (givenstuff3)
	{
		itemid = 25+24;

		while (itemid < 22 + 24 + 24)
		{
			if (givenstuff3 & itob(itemid - (24+24)))
			if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}

	if (givenstuff4)
	{
		itemid = 25+24+24;

		while (itemid < 22 + 24 + 24 + 24)
		{
			if (givenstuff4 & itob(itemid - (24+24+24)))
			if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}

	if (givenstuff5)
	{
		itemid = 25+24+24+24;

		while (itemid < 22 + 24 + 24 + 24 + 24)
		{
			if (givenstuff5 & itob(itemid - (24+24+24+24)))
			if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
				counter = counter + 1;
			
			itemid = itemid + 1;
		}
	}

	if (counter)
	{
		oself = self;
		self = player;
		UpdateWeaponItems();
		self = oself;
	}

	return counter;
};

//=====================================================================================
// Checks if the specified item flag is in the supplied fields or not

/*float(float itemid, float stuff1, float stuff2, float stuff3, float stuff4, float stuff5) ItemInside =
{
	local float bit;

	bit = itemid - (floor(itemid/24)*24);

	if (itemid < 24)
	{
		if (stuff1 & itob(bit))
			return #TRUE;
	}
	else if (itemid < 48)
	{
		if (stuff2 & itob(bit))
			return #TRUE;
	}
	else if (itemid < 72)
	{
		if (stuff3 & itob(bit))
			return #TRUE;
	}
	else if (itemid < 96)
	{
		if (stuff4 & itob(bit))
			return #TRUE;
	}
	else if (itemid < 120)
	{
		if (stuff5 & itob(bit))
			return #TRUE;
	}
	else
		return #FALSE; // bug, anyway

	return #FALSE;
};*/

//=====================================================================
// Modifies the striped/given flags on an entity

float(entity ent, float type, float itemid, float value) SetItemInside =
{
	local float bit;

	bit = itemid - (floor(itemid/24)*24);
	bit = itob(bit);

	if (type == 0) // Striped/Disabled fields
	{
		if (value) // Set bit
		{
			if (itemid < 24)
			{
				if (!(ent.#disabledstuff1 & bit))
				{
					ent.#disabledstuff1 = ent.#disabledstuff1 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 48)
			{
				if (!(ent.#disabledstuff2 & bit))
				{
					ent.#disabledstuff2 = ent.#disabledstuff2 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 72)
			{
				if (!(ent.#disabledstuff3 & bit))
				{
					ent.#disabledstuff3 = ent.#disabledstuff3 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 96)
			{
				if (!(ent.#disabledstuff4 & bit))
				{
					ent.#disabledstuff4 = ent.#disabledstuff4 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 120)
			{
				if (!(ent.#disabledstuff5 & bit))
				{
					ent.#disabledstuff5 = ent.#disabledstuff5 | bit;
					return #TRUE;
				}
			}
			else
				return #FALSE; // bug, anyway
		}
		else // un-set bit
		{
			if (itemid < 24)
			{
				if (ent.#disabledstuff1 & bit)
				{
					ent.#disabledstuff1 = ent.#disabledstuff1 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 48)
			{
				if (ent.#disabledstuff2 & bit)
				{
					ent.#disabledstuff2 = ent.#disabledstuff2 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 72)
			{
				if (ent.#disabledstuff3 & bit)
				{
					ent.#disabledstuff3 = ent.#disabledstuff3 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 96)
			{
				if (ent.#disabledstuff4 & bit)
				{
					ent.#disabledstuff4 = ent.#disabledstuff4 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 120)
			{
				if (ent.#disabledstuff5 & bit)
				{
					ent.#disabledstuff5 = ent.#disabledstuff5 - bit;
					return #TRUE;
				}
			}
			else
				return #FALSE; // bug, anyway
		}
	}
	else // Given fields
	{
		if (value) // Set bit
		{
			if (itemid < 24)
			{
				if (!(ent.#givenstuff1 & bit))
				{
					ent.#givenstuff1 = ent.#givenstuff1 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 48)
			{
				if (!(ent.#givenstuff2 & bit))
				{
					ent.#givenstuff2 = ent.#givenstuff2 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 72)
			{
				if (!(ent.#givenstuff3 & bit))
				{
					ent.#givenstuff3 = ent.#givenstuff3 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 96)
			{
				if (!(ent.#givenstuff4 & bit))
				{
					ent.#givenstuff4 = ent.#givenstuff4 | bit;
					return #TRUE;
				}
			}
			else if (itemid < 120)
			{
				if (!(ent.#givenstuff5 & bit))
				{
					ent.#givenstuff5 = ent.#givenstuff5 | bit;
					return #TRUE;
				}
			}
			else
				return #FALSE; // bug, anyway
		}
		else // un-set bit
		{
			if (itemid < 24)
			{
				if (ent.#givenstuff1 & bit)
				{
					ent.#givenstuff1 = ent.#givenstuff1 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 48)
			{
				if (ent.#givenstuff2 & bit)
				{
					ent.#givenstuff2 = ent.#givenstuff2 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 72)
			{
				if (ent.#givenstuff3 & bit)
				{
					ent.#givenstuff3 = ent.#givenstuff3 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 96)
			{
				if (ent.#givenstuff4 & bit)
				{
					ent.#givenstuff4 = ent.#givenstuff4 - bit;
					return #TRUE;
				}
			}
			else if (itemid < 120)
			{
				if (ent.#givenstuff5 & bit)
				{
					ent.#givenstuff5 = ent.#givenstuff5 - bit;
					return #TRUE;
				}
			}
			else
				return #FALSE; // bug, anyway
		}
	}
	
	return #FALSE;
};

//=================================================================================
// Returns/strips on a player the stuff that has been striped/given to him or her

float(entity player) RestoreOriginalItems =
{	 
	local float itemid, counter, all;
	local entity oself;

	all = 0;
	counter = 0;

	if (player.#givenstuff1 | player.#givenstuff2 | player.#givenstuff3 | player.#givenstuff4 | player.#givenstuff5)
	{		 
		if (player.#givenstuff1)
		{
			itemid = 1;

			while (itemid < 22)
			{
				if (player.#givenstuff1 & itob(itemid))
				if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (player.#givenstuff2)
		{
			itemid = 25;
			
			while (itemid < 22 + 24)
			{
				if (player.#givenstuff2 & itob(itemid - 24))
				if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (player.#givenstuff3)
		{
			itemid = 25+24;
			
			while (itemid < 22 + 24 + 24)
			{
				if (player.#givenstuff3 & itob(itemid - (24+24)))
				if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (player.#givenstuff4)
		{
			itemid = 25+24+24;

			while (itemid < 22 + 24 + 24 + 24)
			{
				if (player.#givenstuff4 & itob(itemid - (24+24+24)))
				if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (player.#givenstuff5)
		{
			itemid = 25+24+24+24;

			while (itemid < 22 + 24 + 24 + 24 + 24)
			{
				if (player.#givenstuff5 & itob(itemid - (24+24+24+24)))
				if (StripSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (counter)
		{			 
			oself = self;
			self = player;
			self.current_weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
			UpdateWeaponItems();
			self = oself;
		}
	}
	
	if (player.#disabledstuff1 | player.#disabledstuff2 | player.#disabledstuff3 | player.#disabledstuff4 | player.#disabledstuff5)
	{
		all = counter;
		counter = 0;
				
		if (player.#disabledstuff1)
		{
			itemid = 1;
		
			while (itemid < 22)
			{
				if (player.#disabledstuff1 & itob(itemid))
				if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (player.#disabledstuff2)
		{
			itemid = 25;

			while (itemid < 22 + 24)
			{
				if (player.#disabledstuff2 & itob(itemid - 24))
				if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (player.#disabledstuff3)
		{
			itemid = 25+24;

			while (itemid < 22 + 24 + 24)
			{
				if (player.#disabledstuff3 & itob(itemid - (24+24)))
				if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (player.#disabledstuff4)
		{
			itemid = 25+24+24;

			while (itemid < 22 + 24 + 24 + 24)
			{
				if (player.#disabledstuff4 & itob(itemid - (24+24+24)))
				if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (player.#disabledstuff5)
		{
			itemid = 25+24+24+24;

			while (itemid < 22 + 24 + 24 + 24 + 24)
			{
				if (player.#disabledstuff5 & itob(itemid - (24+24+24+24)))
				if (GiveSpecificItem(player,itemid,#FALSE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (counter)
		{
			oself = self;
			self = player;
			UpdateWeaponItems();
			self = oself;			 
		}
	}

	// Clear bits
	ResetStripedAndGiven(player);

	return all + counter;
};

//============================================================================
// Subroutine for easy checking the disabled global fields

float(float fieldnum) DisabledStuff =
{
	if (fieldnum == 1)
		return disabledstuff1;
	else if (fieldnum == 2)
		return disabledstuff2;
	else if (fieldnum == 3)
		return disabledstuff3;
	else if (fieldnum == 4)
		return disabledstuff4;
	else if (fieldnum == 5)
		return disabledstuff5;

	return 0;
};

//============================================================================
// Subroutine for easy changing the disabled global fields

void(float fieldnum, float value) SetDisabledStuff =
{
	if (fieldnum == 1)
		disabledstuff1 = value;
	else if (fieldnum == 2)
		disabledstuff2 = value;
	else if (fieldnum == 3)
		disabledstuff3 = value;
	else if (fieldnum == 4)
		disabledstuff4 = value;
	else if (fieldnum == 5)
		disabledstuff5 = value;
};

//============================================================================
// Subroutine for easy checking the free items global fields

float(float fieldnum) GivenStuff =
{
	if (fieldnum == 1)
		return givenstuff1;
	else if (fieldnum == 2)
		return givenstuff2;
	else if (fieldnum == 3)
		return givenstuff3;
	else if (fieldnum == 4)
		return givenstuff4;
	else if (fieldnum == 5)
		return givenstuff5;

	return 0;
};

//============================================================================
// Subroutine for easy changing the free items global fields

void(float fieldnum, float value) SetGivenStuff =
{
	if (fieldnum == 1)
		givenstuff1 = value;
	else if (fieldnum == 2)
		givenstuff2 = value;
	else if (fieldnum == 3)
		givenstuff3 = value;
	else if (fieldnum == 4)
		givenstuff4 = value;
	else if (fieldnum == 5)
		givenstuff5 = value;
};

//=======================================================================
// Resets directly all the striped/given flags on a player

void(entity player) ResetStripedAndGiven =
{
	player.#disabledstuff1 = 0;
	player.#disabledstuff2 = 0;
	player.#disabledstuff3 = 0;
	player.#disabledstuff4 = 0;
	player.#disabledstuff5 = 0;

	player.#givenstuff1 = 0;
	player.#givenstuff2 = 0;
	player.#givenstuff3 = 0;
	player.#givenstuff4 = 0;
	player.#givenstuff5 = 0;
};

//==========================================================================
// Returns a string with client's description and version number

string(entity client) GetClientDescription =
{
	local string result, tmp;

	if (client.cltype == #CLTYPE_DEFAULT)
	{
		result = "OriginalØUnknown client";

		if (client.clversion != 0)
		{
			tmp = ver_ftos(client.clversion);
			result = strcat(result," ˆ");
			result = strcat(result,tmp);
		}

		return result;
	}

	if (client.cltype == #CLTYPE_PROZACQW)
	{
		result = "–rozac—◊";

		tmp = ver_ftos(client.clversion);
		result = strcat(result," ˆ");
		result = strcat(result,tmp);
		
		return result;
	}

	if (client.cltype == #CLTYPE_FUHQUAKE)
	{
		result = "∆uh—uake";

		tmp = ver_ftos(client.clversion);
		result = strcat(result," ˆ");
		result = strcat(result,tmp);
		
		return result;
	}

	if (client.cltype == #CLTYPE_AMFQUAKE)
	{
		result = "¡Õ∆—uake";

		tmp = ver_ftos(client.clversion);
		result = strcat(result," ˆ");
		result = strcat(result,tmp);
		
		return result;
	}

	if (client.cltype == #CLTYPE_ZQUAKE)
	{
		result = "⁄—uake";

		tmp = ver_ftos(client.clversion);
		result = strcat(result," ˆ");
		result = strcat(result,tmp);
		
		return result;
	}

	if (client.cltype == #CLTYPE_QUAKEFORGE)
	{
		result = "—uake∆orge";

		tmp = ver_ftos(client.clversion);
		result = strcat(result," ˆ");
		result = strcat(result,tmp);
		
		return result;
	}

	if (client.cltype == #CLTYPE_FTEQUAKE)
	{
		result = "FTEquake";
		return result;
	}

	if (client.cltype == #CLTYPE_EZQUAKE)
	{
		result = "EZQuake";
		return result;
	}	 

	return "unrecognized"; // wont happen
};

//===========================================================
// Same thing but puts description inside "[]" chars

string(entity client) GetBracedClDesc =
{
	local string result;

	if (client.cltype <= #CLTYPE_DEFAULT)
	{
		result = GetClientDescription(client);
		result = strcat("€",result);
		result = strcat(result,"›");
	}
	else
	{
		result = GetClientDescription(client);
		result = strcat("[",result);
		result = strcat(result,"]");
	}

	return result;
};

//==============================================================
// Transforms a version float into a version string

string(float ver) ver_ftos =
{
	local float tmpf;
	local string result, tmpst;

	tmpf = floor(ver);
	result = ftos(tmpf);
	result = strcat(result,"Æ");
	tmpf = floor((ver - tmpf) * 100);
	tmpst = ftos(tmpf);
	result = strcat(result,tmpst);
	result = colstr(result,#COLSTR_NUMBER);

	return result;
};

//=============================================================================
// Extended version of SpawnMeatSpray()

entity(vector org, vector dir, float meatduration) SpawnMeatSprayEx =
{
	local	entity missile;
	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = #MOVETYPE_BOUNCE;
	missile.solid = #SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = dir;

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + meatduration;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);

	return missile;
};

//===========================================================================
// Corpse related functions

void(entity corpse) GibCorpse =
{
	#ifdef GIBABLE_CORPSES

	local entity oself;
	
	oself = self;
	self = corpse;
	
	if (self.modelindex == modelindex_player)
	{
		ThrowHeadOut("progs/h_player.mdl", 0);
		ThrowGib ("progs/gib1.mdl", 0,#TRUE,0,#GIB1_KGS,#TRUE);
		ThrowGib ("progs/gib2.mdl", 0,#TRUE,0,#GIB2_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0,#TRUE,0,#GIB3_KGS,#TRUE);
	}
	else if (self.#monster_type == #MONSTER_SCRAG)
	{
		ThrowMonsterHead("progs/h_wizard.mdl",0);
		ThrowGib ("progs/gib2.mdl", 0, #TRUE, 0, #GIB2_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0, #TRUE, 0, #GIB3_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0, #TRUE, 0, #GIB3_KGS,#TRUE);
	}
	else if (self.#monster_type == #MONSTER_FISH)
	{
		ThrowGib ("progs/gib2.mdl", 0, #TRUE, 0, #GIB2_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0, #TRUE, 0, #GIB3_KGS,#TRUE);
	}
	else if (self.#monster_type == #MONSTER_DEMON)
	{
		ThrowMonsterHead("progs/h_demon.mdl",0);
		ThrowGib ("progs/gib3.mdl", 0, #TRUE, 0, #GIB3_KGS,#TRUE);
		ThrowGib ("progs/gib2.mdl", 0, #TRUE, 0, #GIB2_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0, #TRUE, 0, #GIB3_KGS,#TRUE);
	}
	else if (self.#monster_type == #MONSTER_GREMLIN)
	{
		ThrowMonsterHead("progs/h_grem.mdl",0);
		ThrowGib ("progs/gib1.mdl", 0,#TRUE,0,#GIB1_KGS,#TRUE);
		ThrowGib ("progs/gib2.mdl", 0,#TRUE,0,#GIB2_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0,#TRUE,0,#GIB3_KGS,#TRUE);
	}
	else if (self.#monster_type == #MONSTER_SHAMBLER)
	{
		ThrowMonsterHead("progs/h_shams.mdl",0);
		ThrowGib ("progs/gib1.mdl", 0, #TRUE, 0,#GIB1_KGS,#TRUE);
		ThrowGib ("progs/gib2.mdl", 0, #TRUE, 0,#GIB2_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0, #TRUE, 0,#GIB3_KGS,#TRUE);		
		ThrowGib ("progs/gib3.mdl", 0, #TRUE, 0,#GIB3_KGS,#TRUE);
	}
	else if (self.#monster_type == #MONSTER_ARMY)
	{
		ThrowMonsterHead("progs/h_player.mdl",0);
		ThrowGib ("progs/gib1.mdl", 0,#TRUE,0,#GIB1_KGS,#TRUE);
		ThrowGib ("progs/gib2.mdl", 0,#TRUE,0,#GIB2_KGS,#TRUE);
		ThrowGib ("progs/gib3.mdl", 0,#TRUE,0,#GIB3_KGS,#TRUE);
	}

	SpawnBloodEx(self.origin,0.66,9);

	self = oself;

	#endif
};

void(entity corpse, float damage, vector where, entity attacker, float directdmg) DamageCorpse =
{
	#ifdef GIBABLE_CORPSES

	local float points;
	
	// Safety checks, first
	if (corpse.#corpse_HP <= 0)
		return;
	if (corpse.modelindex == modelindex_null)
		return;
	if (damage <= 0)
		return;

	// Calculate damage if needed
	if (directdmg) // Direct damage, normal
		points = damage;
	else // Radius/Blast damage, we should adjust damage based on distance to explosion
	{
		points = 0.5*vlen (where - corpse.origin);

		if (points < 0)
			points = 0;

		points = damage - points;

		if (points <= 0)
			return;
	}
	
	// Apply damage to the corpse
	corpse.#corpse_HP = corpse.#corpse_HP - points;

	if (corpse.#corpse_HP <= 0) // got destroyed?
	{
		// Corpse explodes.. throw gibs!
		// Throw an appropiate head too! :)
		GibCorpse(corpse);		  
		
		// If this is a monster corpse, just remove entity
		if (corpse.classname == "monster_corpse")
		{			 
			dremove(corpse);
			return;
		}
		// If a player and still on the corpse, report his corpse is destroyed and who is gibbing it
		else if (corpse.classname == "player" && corpse.is_connected)
		{
			if (attacker)
			if (attacker.classname == "player" && attacker.is_connected)
			{
				if (corpse != attacker)
				{
					sprint(corpse,#PRINT_MEDIUM,attacker.netname," destroys your corpse!\n");
					sprint(attacker,#PRINT_LOW,"You destroy ",corpse.netname,"'s corspe!\n");
				}	  
				else
					sprint(corpse,#PRINT_MEDIUM,"You destroy your own corpse!\n");
			}
		}

		// Make corpse disappear, and "unmark" entity as corpse, doing cleanup
		corpse.modelindex = modelindex_null;
		corpse.solid = #SOLID_NOT;
		corpse.#corpseflag = "";
		corpse.flags = corpse.flags - (corpse.flags & #FL_FINDABLE_NONSOLID);
		corpse.takedamage = #DAMAGE_NO;
	}
	else // still not destroyed, it should bleed
	{
		// Spawn corresponding ammount of blood
		SpawnBloodEx(corpse.origin, 0.5, #MAX_CORPSE_BLOOD);
		
		// If not enough damage, dont spawn meat spray, sometimes dont also even if enough dmg
		if (random() > 0.6 || points < 20)
			return;

		// Calculate random direction for meat spray
		where_x = crandom()*120;
		where_y = crandom()*120;
		where_z = (200 + crandom()*60)*(points/40);
		if (where_z > 300)
			where_z = 300;

		// Launch meat spray
		SpawnMeatSprayEx(corpse.origin,where,1);
	}

	#endif
};

//===========================================================================
// Prepares an entity for corpse damage

void(entity deadone, float corpse_dmg_tolerance) MakeCorpse =
{
	#ifdef USE_CORPSE_CODE

	deadone.#corpseflag = #STRFLAG_CORPSE;
	deadone.#corpse_HP = corpse_dmg_tolerance + crandom()*40 - random()*60;
	if (deadone.#corpse_HP < 1)
		deadone.#corpse_HP = 1;
	deadone.touch = SUB_Null;
	deadone.flags = deadone.flags | #FL_FINDABLE_NONSOLID; 
	deadone.maxs_z = deadone.mins_z + 15;
	setsize (deadone, deadone.mins, deadone.maxs);
	deadone.takedamage = #DAMAGE_YES;
	
	#endif
};

//=======================================================================
// Reverts last increase of CPrint FX's counter/indicator

void() NoCprintFX =
{
	self.#cprint_fx = self.#cprint_fx - 1;
};

//=======================================================================
// Flashes background of a client, using "bf" command the specified times

void(entity client, float ammount) BackFlash =
{
	local string tstr;
	local float counter;

	counter = 1;

	tstr = "bf";

	while (counter < ammount)
	{
		tstr = strcat(tstr,";bf");

		counter = counter + 1;
	}

	tstr = strcat(tstr,"\n");

	stuffcmd(client,tstr);
};

//==============================================================
// Gizmo

float(entity thing) IsOwnedMonster =
{
/*
	if (thing.classname=="monster_shambler")
		return #TRUE;
	if (thing.classname=="monster_demon1")
		return #TRUE;
	if (thing.classname=="monster_wizard")
		return #TRUE;
	if (thing.classname=="monster_army")
		return #TRUE;
	if (thing.classname=="monster_fish")
		return #TRUE;
	if (thing.classname=="monster_gremlin")
		return #TRUE;
*/

	if ( thing.flags & #FL_MONSTER )
	if ( thing.real_owner != world )	// Gizmo - added this because not all monsters are pets
		return #TRUE;

	return #FALSE;
};

float(entity thing) IsSummon =
{
/*
	if (thing.classname=="monster_shambler")
		return #TRUE;
	if (thing.classname=="monster_demon1")
		return #TRUE;
	if (thing.classname=="monster_wizard")
		return #TRUE;
	if (thing.classname=="monster_fish")
		return #TRUE;
	if (thing.classname=="monster_gremlin")
		return #TRUE;
*/

	if ( thing.flags & #FL_MONSTER )
	if ( thing.real_owner != world )	// Gizmo - added this because not all monsters are pets
	if ( thing.classname != "monster_army" )
		return #TRUE;
	
	return #FALSE;
};
