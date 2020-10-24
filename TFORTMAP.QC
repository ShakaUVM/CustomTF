/*======================================================
	TFORTMAP.QC 		Custom TeamFortress v3.1	

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney			2/23/00
	(c) Craig Hauser				2/23/00
========================================================
Functions handling TeamFortress Map Entities
======================================================*/
// Prototypes
// Team Functions
void(float tno, float scoretoadd) TeamFortress_TeamIncreaseScore;
void(float all, float teamscored, float scorepoints) TeamFortress_TeamShowScores;
float() TeamFortress_TeamGetWinner;

// Functions to handle entity placement when spawned
void() TF_PlaceItem;
void() TF_StartItem;
void() TF_PlaceGoal;
void() TF_StartGoal;

// Spawn functions for all Map Entities
float() CheckExistence;
void() info_tfdetect;
void() info_player_teamspawn;
void() info_tfgoal;
void() info_tfgoal_timer;
void() item_tfgoal;

// AutoDetection Function
void(entity AD) ParseTFDetect;

// Generic Functions
entity(float ino) Finditem;
entity(float gno) Findgoal;
entity(float gno) Findteamspawn;
void(entity Goal) InactivateGoal;
void(entity Goal) RestoreGoal;
void(entity Goal) RemoveGoal;
float(entity Goal, entity Player, entity AP) IsAffectedBy;
void(entity Goal, entity Player, entity AP, float addb) Apply_Results;
float(entity Goal, entity AP) APMeetsCriteria;
void(entity Goal) SetupRespawn;
void() DoRespawn;
void(entity Goal, entity AP) DoGoalWork;
void(entity Goal, entity AP) DoGroupWork;
void(entity Item, entity AP) DoItemGroupWork;
void(entity Goal, entity AP) DoTriggerWork;
void(entity Goal, entity AP, float addb) DoResults;
void(entity Goal, entity Player) RemoveResults;

//CH
void() tfgoalitem_dropthink2;
void() tfgoalitem_settouchandthink;
//CH 3 checks for a returning goalitem
void() tfgoalitem_checkoriginagain;
void() tfgoalitem_checkoriginagain2;
void() tfgoalitem_checkoriginagain3;

// Goal Functions
void() tfgoal_touch;
void() info_tfgoal_use;

// Timer Goal Functions
void() tfgoal_timer_tick;

// Item Functions
void() item_tfgoal_touch;
void(entity Item, entity AP, entity Goal) tfgoalitem_GiveToPlayer;
void(float Item)Update_team_with_flag_touch;
void(float Item)Update_team_with_flag_drop;
void(entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;
void() tfgoalitem_remove;
void(entity Item, float tossed) tfgoalitem_drop;
void(entity Item) tfgoalitem_checkgoalreturn;
void() ReturnItem;
void(entity Goal, entity Player, entity Item) DisplayItemStatus;

// CTF Support Functions
void() CTF_FlagCheck;

// Chris Support Functions
//void (float winner) RoundStop;

//=========================================================================
// ENTITY PLACEMENT HANDLING FUNCTIONS
//=========================================================================
// Copy the abbreviations into their storage areas
void(entity Goal) UpdateAbbreviations =
{
	// The first time we enter this, copy the abbreviations
	if (Goal.is_connected == #FALSE)
	{
		// Floats
		if (Goal.g_a != 0 && Goal.goal_activation == 0)
			Goal.goal_activation = Goal.g_a;
		if (Goal.g_e != 0 && Goal.goal_effects == 0)
			Goal.goal_effects = Goal.g_e;
		// Strings
		if (Goal.t_s_h != string_null)
			Goal.team_str_home = Goal.t_s_h;
		if (Goal.t_s_m != string_null)
			Goal.team_str_moved = Goal.t_s_m;
		if (Goal.t_s_c != string_null)
			Goal.team_str_carried = Goal.t_s_c;
		if (Goal.n_s_h != string_null)
			Goal.non_team_str_home = Goal.n_s_h;
		if (Goal.n_s_m != string_null)
			Goal.non_team_str_moved = Goal.n_s_m;
		if (Goal.n_s_c != string_null)
			Goal.non_team_str_carried = Goal.n_s_c;
		if (Goal.b_b != string_null)
			Goal.broadcast = Goal.b_b;
		if (Goal.b_t != string_null)
			Goal.team_broadcast = Goal.b_t;
		if (Goal.b_n != string_null)
			Goal.non_team_broadcast = Goal.b_n;
		if (Goal.b_o != string_null)
			Goal.owners_team_broadcast = Goal.b_o;
		if (Goal.n_b != string_null)
			Goal.netname_broadcast = Goal.n_b;
		if (Goal.n_t != string_null)
			Goal.netname_team_broadcast = Goal.n_t;
		if (Goal.n_n != string_null)
			Goal.netname_non_team_broadcast = Goal.n_n;
		if (Goal.n_o != string_null)
			Goal.netname_owners_team_broadcast = Goal.n_o;
		if (Goal.d_t != string_null)
			Goal.team_drop = Goal.d_t;
		if (Goal.d_n != string_null)
			Goal.non_team_drop = Goal.d_n;
		if (Goal.d_n_t != string_null)
			Goal.netname_team_drop = Goal.d_n_t;
		if (Goal.d_n_n != string_null)
			Goal.netname_non_team_drop = Goal.d_n_n;
		Goal.is_connected = #TRUE;
	}
};

// Place the Goal Item
void() TF_PlaceItem =
{
	//local float	oldz;
	local vector temp1;
	local vector temp2;
	
	#ifdef IDABLE_TFITEMS
	self.flags = #FL_ITEM | (self.flags & #FL_FINDABLE_NONSOLID);				// make extra wide
	#else
	self.flags = #FL_ITEM;
	#endif

	self.touch = item_tfgoal_touch;
	setorigin(self, self.origin);
	self.goal_state = #TFGS_INACTIVE;

//CH my updates
	if (self.goal_activation & #TFGI_GOAL_TO_GROUND)
	{
		self.oldorigin = self.origin;
		self.movetype = #MOVETYPE_TOSS;

		self.velocity_z = -40;
		self.velocity_x = 0; //-50 + (random() * 100);
		self.velocity_y = 0; //-50 + (random() * 100);
		
		self.nextthink = time + 5.0;		// give it 5 seconds
		self.think = tfgoalitem_dropthink2;  // and then find where it ended up
	}
	else
	{
		self.velocity = '0 0 0';
		self.movetype = #MOVETYPE_NONE;
		self.oldorigin = self.origin;
	}

//CH sets goal bounding box size

	if (self.goal_min != vector_null)
		temp1 = self.goal_min;
	else
		temp1 = '-16 -16 -24';
	if (self.goal_max != vector_null)
		temp2 = self.goal_max;
	else
		temp2 = '16 16 32';

	setsize (self, temp1, temp2); //CH sets box size from above

	if (self.goal_activation & #TFGI_GOAL_IS_SOLID)
		self.solid = #SOLID_BBOX;
	else
		self.solid = #SOLID_TRIGGER;
	
//CH end my updates

//On tfgoalitem_dropthink2
//	self.velocity = '0 0 0';
//	self.oldorigin = self.origin;		// So we can return it later

	if (self.goal_activation & #TFGI_ITEMGLOWS)
		self.effects = self.effects | #EF_DIMLIGHT;

	#ifdef TEAMITEMS_COLORGLOW
	// Make it glow with an appropiate color!
	if (number_of_teams == 2)
	if (self.team_no)
	{
		#ifdef TEAMITEMS_FORCEDGLOW
		if (self.team_no == 1 || self.team_no == 2)
			self.effects = self.effects | #EF_DIMLIGHT;
		#endif
		
		if (self.goal_activation & #TFGI_REVERSE_AP) // Reversed criteria
		{
			if (self.team_no == 1) // Blue team
				self.effects = self.effects | #EF_BLUE;
			else if (self.team_no == 2)
				self.effects = self.effects | #EF_RED;
		}
		else // Normal criteria
		{
			if (self.team_no == 1) // Blue team
				self.effects = self.effects | #EF_RED;
			else if (self.team_no == 2)
				self.effects = self.effects | #EF_BLUE;
		}
	}
	#endif

	// Setup the item_list mask
	if (item_list_bit == 0)
		item_list_bit = 1;

	self.item_list = item_list_bit;
	item_list_bit = item_list_bit * 2;
};

//=========================================================================
// Start the Goal Item
void() TF_StartItem =
{
	UpdateAbbreviations(self);
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = TF_PlaceItem;

	if (self.goal_state == #TFGS_REMOVED)
		RemoveGoal(self);
};

//=========================================================================
// Place the Goal 
void() TF_PlaceGoal =
{
	//local float	oldz;

	if (self.classname != "info_tfgoal_timer")
	{
		// Only give touch functions to goals that can be activated by touch
		if (self.goal_activation & #TFGA_TOUCH)
			self.touch = tfgoal_touch;
	}
	else
	{
		// Set up the next Timer Tick
		self.think = tfgoal_timer_tick;
		self.nextthink = time + self.search_time;

		// So searches for this goal work later on
		self.classname = "info_tfgoal";
	}

	self.flags = #FL_ITEM;				// make extra wide
	self.movetype = #MOVETYPE_NONE; 
	self.velocity = '0 0 0';
	self.oldorigin = self.origin;		// So we can return it later
};

//=========================================================================
// Start the Goal 
void() TF_StartGoal =
{
	UpdateAbbreviations(self);
	self.nextthink = time + 0.2;	// goals start after other solids
	self.think = TF_PlaceGoal;
	self.use = info_tfgoal_use;

	if (self.goal_state == #TFGS_REMOVED)
		RemoveGoal(self);
};





//=========================================================================
// SPAWN FUNCTIONS
//=========================================================================
// Checks whether this entity should exist under the current settings
float() CheckExistence =
{
	UpdateAbbreviations(self);

	if (self.ex_skill_min && (skill <= self.ex_skill_min))
		return #FALSE;
	else if (self.ex_skill_max && (skill >= self.ex_skill_max))
		return #FALSE;

	return #TRUE;
};

//=========================================================================
// Spawn a detection entity
void() info_tfdetect =
{
	UpdateAbbreviations(self);
	// The rest of the checking is done in the ParseTFDetect() function,
	// which is called the first time someone enters the map, in client.qc
};

//=========================================================================
// Spawn a Team Spawn Point
void() info_player_teamspawn =
{
	local entity te;

	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	// find the highest team number
	if (number_of_teams < self.team_no)
		number_of_teams = self.team_no;

	// Team spawnpoints must have a team associated with them
	if (self.team_no <= 0)
	{
		RPrint("no team_no associated with info_player_teamspawn\n");
		dremove(self);
	}

	// Does this give out a GoalItem?
	if (self.items != 0)
	{
		te = Finditem(self.items);
		if (!te)
		{
			RPrint("info_player_teamspawn specifies a GoalItem that does not exist\n");
			dremove(self);
		}
	}

	if (self.team_no == 1)
		self.team_str_home = "ts1";
	else if (self.team_no == 2)
		self.team_str_home = "ts2";
	else if (self.team_no == 3)
		self.team_str_home = "ts3";
	else if (self.team_no == 4)
		self.team_str_home = "ts4";

	if (neo) // for Neo mode (makes all spawns red spawns)
	{
		self.team_no = 2;
		self.team_str_home = "ts2";
	}
};

void() i_p_t =
{
	self.classname = "info_player_teamspawn";
	info_player_teamspawn();
};


//=========================================================================
// Spawn a goal entity
void() info_tfgoal =
{
	local vector temp1;
	local vector temp2;

	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	// Graphic
	if (self.mdl)
	{
		// We try both, so at least one will work
		precache_model(self.mdl);
		precache_model2(self.mdl);
		setmodel(self, self.mdl);
	}
	// Activation sound
	if (self.noise)
	{
		// We try both, so at least one will work
		precache_sound(self.noise);
		precache_sound2(self.noise);
	}

	// For the powerups
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	precache_sound2 ("items/protect2.wav");
	precache_sound2 ("items/protect3.wav");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");

//CH set solid state
	if (self.goal_activation & #TFGI_GOAL_IS_SOLID)
		self.solid = #SOLID_BBOX;
	else
		self.solid = #SOLID_TRIGGER;
	if (self.goal_state == 0)
		self.goal_state = #TFGS_INACTIVE;

//CH sets goal bounding box size
	if (self.goal_min != vector_null)
		temp1 = self.goal_min;
	else
		temp1 = '-16 -16 -24';
	if (self.goal_max != vector_null)
		temp2 = self.goal_max;
	else
		temp2 = '16 16 32';

	setsize (self, temp1, temp2); //CH sets box size from above

	TF_StartGoal ();
};

void() i_t_g =
{
	self.classname = "info_tfgoal";
	info_tfgoal();
};

//=========================================================================
// Spawn a Timer goal entity
void() info_tfgoal_timer =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	// Graphic
	if (self.mdl)
	{
		// We try both, so at least one will work
		precache_model(self.mdl);
		precache_model2(self.mdl);
		setmodel(self, self.mdl);
	}
	// Activation sound
	if (self.noise)
	{
		// We try both, so at least one will work
		precache_sound(self.noise);
		precache_sound2(self.noise);
	}

	// Timer Goals must have a time specified
	if (self.search_time <= 0)
	{
		RPrint("Timer Goal created with no specified time.\n");
		dremove(self);
	}

	self.solid = #SOLID_NOT;
	if (self.goal_state == 0)
		self.goal_state = #TFGS_INACTIVE;
	setsize (self, '-16 -16 -24', '16 16 32');
	TF_StartGoal ();
};

void() i_t_t =
{
	self.classname = "info_tfgoal_timer";
	info_tfgoal_timer();
};

//=========================================================================
// Spawn a goalitem entity
void() item_tfgoal =
{
	local vector temp1;
	local vector temp2;
	
	// Neo mode: probably don't need any item_tfgoals in Neo mode (we'll see)
	if (neo) return;

	// Attackers Go Red mode -PZ
	// don't spawn Red's flag in AGR
	if (agr) if (self.team_no == 1) return; // team_no indicates which team can use the item
		
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	// Graphic
	if (self.mdl)
	{
		// We try both, so at least one will work
		precache_model(self.mdl);
		precache_model2(self.mdl);
		setmodel(self, self.mdl);
	}
	else
	{
		// Default mdl for a GoalItem
		self.mdl = "";
		setmodel(self, "");
	}

	// Respawn sound
	precache_sound2("items/itembk2.wav");

	// Activation sound
	if (self.noise)
	{
		// We try both, so at least one will work
		precache_sound(self.noise);
		precache_sound2(self.noise);
	}

	self.touch = item_tfgoal_touch;
	if (self.goal_state == 0)
		self.goal_state = #TFGS_INACTIVE;

//CH sets how it is
	if (self.goal_activation & #TFGI_GOAL_IS_SOLID)
		self.solid = #SOLID_BBOX;
	else
		self.solid = #SOLID_TRIGGER;

	setorigin(self, self.origin);

	/*if (!(self.netname))
		self.netname = "goalitem";*/
		// OfN
	#ifdef IDABLE_TFITEMS
	if (self.netname)
		self.flags = #FL_FINDABLE_NONSOLID;
	#endif

	if (self.pausetime <= 0)
		self.pausetime = 60;

	// for backwards compatability
	if (self.delay != 0 && self.pausetime == 0)
		self.pausetime = self.delay;

//CH sets goal bounding box size
	if (self.goal_min != vector_null)
		temp1 = self.goal_min;
	else
		temp1 = '-16 -16 -24';
	if (self.goal_max != vector_null)
		temp2 = self.goal_max;
	else
		temp2 = '16 16 32';

	setsize (self, temp1, temp2); //CH sets box size from above

	// OfN - Applies default to dropable-item if we should do
	if (drop_items)
	if (!(self.goal_activation & #TFGR_DROPITEMS))
		self.goal_activation = self.goal_activation + #TFGR_DROPITEMS;
	// OfN - END

	TF_StartItem ();
};


//=========================================================================
// AUTODETECTION FUNCTIONS
//=========================================================================
// Parse the Detection entities variables and set anything relevant
void(entity AD) ParseTFDetect =
{
	// Check Version
/*
	if (AD.broadcast != string_null)
	{
		if (AD.broadcast != "TeamFortress v2.5")
		{
			RPrint("This map was designed to be run on ");
			RPrint(AD.broadcast);
			RPrint("\nYou are using TeamFortress v2.5\n");
			RPrint("You can get the latest version of this patch at: ");
			RPrint("http://www.planetquake.com/teamfortress/\n");
		}
	}
*/

	// Set the team menu string
	if (AD.team_broadcast != string_null)
		team_menu_string = AD.team_broadcast;

	// Set toggleflags (DEFUNCT)
//	toggleflags = AD.impulse;

	// Do localcmds
	localcmd(AD.message);
#ifndef QUAKE_WORLD
	cvar_set("sv_maxspeed", "500");
#endif

	// Set life limits
	team1lives = AD.ammo_shells;
	team2lives = AD.ammo_nails;
	team3lives = AD.ammo_rockets;
	team4lives = AD.ammo_cells;
	// If the lives of any of the teams are 0, they want infinite lives,
	// so we set their number to -1
	if (team1lives == 0)
		team1lives = -1;
	if (team2lives == 0)
		team2lives = -1;
	if (team3lives == 0)
		team3lives = -1;
	if (team4lives == 0)
		team4lives = -1;

	// Prevent hook use
	if ((AD.hook_out == 1) || no_grapple == 1)
		allow_hook = #FALSE;

	// Set player number limits for each team
	team1maxplayers = AD.ammo_medikit;
	team2maxplayers = AD.ammo_detpack;
	team3maxplayers = AD.maxammo_medikit;
	team4maxplayers = AD.maxammo_detpack;
	if (team1maxplayers == 0)
		team1maxplayers = 100;
	if (team2maxplayers == 0)
		team2maxplayers = 100;
	if (team3maxplayers == 0)
		team3maxplayers = 100;
	if (team4maxplayers == 0)
		team4maxplayers = 100;

	// Set illegal playerclasses
	illegalclasses = AD.playerclass;
	illegalclasses1 = AD.maxammo_shells;
	illegalclasses2 = AD.maxammo_nails;
	illegalclasses3 = AD.maxammo_rockets;
	illegalclasses4 = AD.maxammo_cells;

	civilianteams = 0;
	// Civilian team checking
	if (illegalclasses1 == -1)
	{
		illegalclasses1 = 0;
		civilianteams = civilianteams | #TEAM1_CIVILIANS;
	}
	if (illegalclasses2 == -1)
	{
		illegalclasses2 = 0;
		civilianteams = civilianteams | #TEAM2_CIVILIANS;
	}
	if (illegalclasses3 == -1)
	{
		illegalclasses3 = 0;
		civilianteams = civilianteams | #TEAM3_CIVILIANS;
	}
	if (illegalclasses4 == -1)
	{
		illegalclasses4 = 0;
		civilianteams = civilianteams | #TEAM4_CIVILIANS;
	}
};




//=========================================================================
// GENERIC FUNCTIONS
//=========================================================================
// Return the item with a goal_no equal to ino
entity(float ino) Finditem =
{
	local entity tg;
	local string st;

	// Look for the goal
	tg = find (world, classname, "item_tfgoal");
	while (tg)
	{
		if (tg.goal_no == ino)
			return tg;

		tg = find(tg, classname, "item_tfgoal");
	}

	// Goal does not exist
	RPrint("Could not find an item with a goal_no of ");
	st = ftos(ino);
	RPrint(st);
	RPrint(".\n");
};

//=========================================================================
// Return the goal with a goal_no equal to gno
entity(float gno) Findgoal =
{
	local entity tg;
	local string st;

	// Look for the goal
	tg = find (world, classname, "info_tfgoal");
	while (tg)
	{
		if (tg.goal_no == gno)
		{
			return tg;
		}

		tg = find(tg, classname, "info_tfgoal");
	}

	// Goal does not exist
	RPrint("Could not find a goal with a goal_no of ");
	st = ftos(gno);
	RPrint(st);
	RPrint(".\n");
};

//=========================================================================
// Return the TeamSpawn with a goal_no equal to gno
entity(float gno) Findteamspawn =
{
	local entity tg;
	local string st;

	// Look for the goal
	tg = find (world, classname, "info_player_teamspawn");
	while (tg)
	{
		if (tg.goal_no == gno)
			return tg;

		tg = find(tg, classname, "info_player_teamspawn");
	}

	// Goal does not exist
	RPrint("Could not find a Teamspawn with a goal_no of ");
	st = ftos(gno);
	RPrint(st);
	RPrint(".\n");
};

//=========================================================================
// Inactivate a Timer/Goal
void(entity Goal) InactivateGoal =
{
#ifdef MAP_DEBUG
	RPrint("Attempting to Inactivate ");
	RPrint(Goal.netname);
#endif

	if (Goal.goal_state == #TFGS_ACTIVE)
	{
		// Not a timer goal
		if (Goal.search_time == 0) {
			if (Goal.goal_activation & #TFGI_GOAL_IS_SOLID)
				Goal.solid = #SOLID_BBOX;
			else
				Goal.solid = #SOLID_TRIGGER;
		}
		Goal.goal_state = #TFGS_INACTIVE;
		if (Goal.mdl != string_null)
			setmodel(Goal, Goal.mdl);
	}
#ifdef MAP_DEBUG
	else
	{
		RPrint("... failed. Goal is ");
		if (Goal.goal_state == #TFGS_INACTIVE)
			RPrint("inactive\n");
		else if (Goal.goal_state == #TFGS_REMOVED)
			RPrint("removed\n");
		else if (Goal.goal_state == #TFGS_DELAYED)
			RPrint("delayed\n");
	}
#endif
};

//=========================================================================
void(entity Goal) RestoreGoal =
{
#ifdef MAP_DEBUG
	RPrint("Attempting to Restore ");
	RPrint(Goal.netname);
#endif
	if (Goal.search_time == 0)
	{
		if (Goal.goal_activation & #TFGI_GOAL_IS_SOLID)
			Goal.solid = #SOLID_BBOX;
		else
			Goal.solid = #SOLID_TRIGGER;

		if (Goal.mdl != string_null)
			setmodel(Goal, Goal.mdl);

		if (Goal.goal_state == #TFGS_REMOVED)
			Goal.goal_state = #TFGS_INACTIVE;
	}


	if (Goal.goal_state == #TFGS_REMOVED)
	{
#ifdef MAP_DEBUG
		RPrint("... succeeded.\n");
#endif
		// Not a timer goal
		if (Goal.search_time != 0)
//			{
//				if (Goal.goal_activation & #TFGI_GOAL_IS_SOLID)
//					Goal.solid = #SOLID_BBOX;
//				else
//					Goal.solid = #SOLID_TRIGGER;
//			}
//		else
			Goal.nextthink = time + Goal.search_time;
		Goal.goal_state = #TFGS_INACTIVE;

//		if (Goal.mdl != string_null)
//			setmodel(Goal, Goal.mdl);
	}
#ifdef MAP_DEBUG
	else
	{
		RPrint("... failed. Goal is ");
		if (Goal.goal_state == #TFGS_INACTIVE)
			RPrint("inactive\n");
		else if (Goal.goal_state == #TFGS_ACTIVE)
			RPrint("active\n");
		else if (Goal.goal_state == #TFGS_DELAYED)
			RPrint("delayed\n");
	}
#endif
};

//=========================================================================
// Remove a Timer/Goal
void(entity Goal) RemoveGoal =
{
#ifdef MAP_DEBUG
	RPrint("Removing ");
	RPrint(Goal.netname);
	RPrint("\n");
#endif

	Goal.solid = #SOLID_NOT;
	Goal.goal_state = #TFGS_REMOVED;
	if (Goal.mdl != string_null)
		setmodel(Goal, string_null);
};

//=========================================================================
// Return #TRUE if the player is affected by the goal
float(entity Goal, entity Player, entity AP) IsAffectedBy =
{
	local float genv;

	// Don't affect anyone who isn't alive or is in Observer mode
	if (Player.playerclass == #PC_UNDEFINED)
		return #FALSE;
//	if (Player.health <= 0)
//		return #FALSE;

	// Same Environment Check
	if (Goal.goal_effects & #TFGE_SAME_ENVIRONMENT)
	{
		genv = pointcontents(Goal.origin);
		if (pointcontents(Player.origin) != genv)
			return #FALSE;
	}

	if (Goal.t_length != 0)
	{
		// Within radius?
		if (vlen(Goal.origin - Player.origin) <= Goal.t_length)
		{
			// Obstructed by walls?
			if (Goal.goal_effects & #TFGE_WALL)
			{
				traceline (Goal.origin, Player.origin, #TL_BSP_ONLY, Goal);

				if (trace_fraction == 1)
					return #TRUE;
			}
			else
				return #TRUE;
		}
	}	

	if (Goal.classname != "info_tfgoal_timer")
	{
		if ((Goal.goal_effects & #TFGE_AP) && (Player == AP))
			return #TRUE;
	
		if ((Goal.goal_effects & #TFGE_AP_TEAM) && (AP.team_no == Player.team_no))
			return #TRUE;
	
		if ((Goal.goal_effects & #TFGE_NOT_AP_TEAM) && (AP.team_no != Player.team_no))
			return #TRUE;
		
		if ((Goal.goal_effects & #TFGE_NOT_AP) && (Player != AP))
			return #TRUE;
	}

	if ((Goal.maxammo_shells != 0) && (Player.team_no == Goal.maxammo_shells))
		return #TRUE;

	if ((Goal.maxammo_nails != 0) && (Player.team_no != Goal.maxammo_shells))
		return #TRUE;

	return #FALSE;
};

//=========================================================================
// Apply modifications to the Player passed in
void(entity Goal, entity Player, entity AP, float addb) Apply_Results =
{
	local entity oldself, te, oldte;
	//local float tc;
	//local string st;

	stuffcmd(Player, "bf\n");

#ifdef MAP_DEBUG
	RPrint("Applying Results from ");
	RPrint(Goal.netname);
	RPrint(" to ");
	RPrint(AP.netname);
	RPrint("\n");
#endif

	// If this is a goalitem, record the fact that this player
	// has been affected by it.
	if (Goal.classname == "item_tfgoal")
		Player.item_list = Player.item_list | Goal.item_list;

	if (Player == AP)
	{
		// Increase the team score
		if (Goal.count > 0)
		{
			if (Player.team_no > 0)
			{	
				TeamFortress_TeamIncreaseScore(Player.team_no, Goal.count);
				// Display short team scores
				TeamFortress_TeamShowScores(2,Player.team_no,Goal.count);
				// Attackers Go Red mode -PZ
				if (agr) if (Player.team_no == 2) if (Goal.count >= 10)
				{
					local entity player;
					player = find(world, classname, "player");
					while (player)
					{
						CenterPrint(player, " Red Captures Blue's Flag! \n");
						player = find(player, classname, "player");
					}
					BroadcastSound("boss2/pop2.wav");
					AGR_resetTimer();
				}
			}
		}
	}

	// Apply Stats, only if told to
	if (addb)
	{
#ifdef MAP_DEBUG
	RPrint("Adding bonuses.\n");
#endif
		// Some results are not applied to dead players
		if (Player.health > 0)
		{
			if (Goal.health > 0)
				T_Heal(Player, Goal.health, 0);
			if (Goal.health < 0)
			{
				if (Goal.invincible_finished < 0)
				{
					// KK allow goal to strip invinc cheats
					Player.items = Player.items + #IT_INVULNERABILITY;
					Player.invincible_time = 0;
					Player.invincible_finished = 0;
				}	
				// Make sure we don't gib them. We don't want to gib, because
				// it creates too many entities if a lot of players are affected
				// by this Goal.
				if ((0 - Player.health) > Goal.health)
					TF_T_Damage (Player, Goal, Goal, (Player.health + 1), #TF_TD_IGNOREARMOUR | #TF_TD_IGNORERESIST, #TF_TD_OTHER);
				else
					TF_T_Damage (Player, Goal, Goal, (0 - Goal.health), #TF_TD_IGNOREARMOUR | #TF_TD_IGNORERESIST, #TF_TD_OTHER);
			}
		}

		// The player may be dead now, so check again
		if (Player.health > 0)
		{
			if (Goal.armortype)
				Player.armortype = Goal.armortype;
			Player.armorvalue = Player.armorvalue + Goal.armorvalue;

			// OfN - Fixed ancient bug
			if (Player.armorvalue > 0)
				UpdateArmorItem(Player);

			if (Goal.armorclass)
			{ //WK Modify to | it with bought armor
//TODO: Make this a map specific option
				//WK Don't give wooden armor since it doesn't exist
				// any more. And we don't want gel for free, right?
				Player.armorclass = Goal.armorclass - (Goal.armorclass & #AT_SAVEMELEE);
				if (Player.tf_items & #NIT_KEVLAR)
					Player.armorclass = Player.armorclass | #AT_SAVESHOT;
				if (Player.tf_items & #NIT_GEL)
					Player.armorclass = Player.armorclass | #AT_SAVEMELEE;
				if (Player.tf_items & #NIT_BLAST)
					Player.armorclass = Player.armorclass | #AT_SAVEEXPLOSION;
				if (Player.tf_items & #NIT_CERAMIC)
					Player.armorclass = Player.armorclass | #AT_SAVEELECTRICITY;
				if (Player.tf_items & #NIT_ASBESTOS)
					Player.armorclass = Player.armorclass | #AT_SAVEFIRE;
			}

			Player.ammo_shells = Player.ammo_shells + Goal.ammo_shells;
			Player.ammo_nails = Player.ammo_nails + Goal.ammo_nails;
			Player.ammo_rockets = Player.ammo_rockets + Goal.ammo_rockets;
			Player.ammo_cells = Player.ammo_cells + Goal.ammo_cells;
			Player.ammo_medikit = Player.ammo_medikit + Goal.ammo_medikit;
			Player.ammo_detpack = Player.ammo_detpack + Goal.ammo_detpack;
			if (Player.tp_grenades_1 != 0) //WK Stop Bug grenades
				Player.no_grenades_1 = Player.no_grenades_1 + Goal.no_grenades_1;
			if (Player.tp_grenades_2 != 0) //WK Stop Bug grenades
				Player.no_grenades_2 = Player.no_grenades_2 + Goal.no_grenades_2;
			
			if (Player.no_grenades_1 > GetMaxGrens(Player,1))
				Player.no_grenades_1 = GetMaxGrens(Player,1);

			if (Player.no_grenades_2 > GetMaxGrens(Player,2))
				Player.no_grenades_2 = GetMaxGrens(Player,2);

			/*if (Player.no_grenades_1 > 4)
				if (Player.tf_items & #NIT_AMMO_BANDOLIER)
					Player.no_grenades_1 = 5;
				else
					Player.no_grenades_1 = 4;
			if (Player.no_grenades_2 > 4)
				if (Player.tf_items & #NIT_AMMO_BANDOLIER)
					Player.no_grenades_2 = 5;
				else
					Player.no_grenades_2 = 4;*/
			if (Player.ammo_detpack > Player.maxammo_detpack)
				Player.ammo_detpack = Player.maxammo_detpack;

			// Apply any powerups
			if (Goal.invincible_finished > 0)
			{
				Player.items = Player.items | #IT_INVULNERABILITY;
				Player.invincible_time = 1;
				Player.invincible_finished = time + Goal.invincible_finished;
				// if its a GoalItem, powerup is permanent, so we use TFSTATE flags
				if (Goal.classname == "item_tfgoal")
				{
					Player.tfstate = Player.tfstate | #TFSTATE_INVINCIBLE;
					Player.invincible_finished = time + 666;
				}
			}
			if (Goal.invisible_finished > 0)
			{
				Player.items = Player.items | #IT_INVISIBILITY;
				Player.invisible_time = 1;
				Player.invisible_finished = time + Goal.invisible_finished;
				// if its a GoalItem, powerup is permanent, so we use TFSTATE flags
				if (Goal.classname == "item_tfgoal")
				{
					Player.tfstate = Player.tfstate | #TFSTATE_INVISIBLE;
					Player.invisible_finished = time + 666;
				}
			}
			if (Goal.super_damage_finished > 0)
			{
				//WK Remove Inspiration when we get the real thing
				Player.tfstate = Player.tfstate - (Player.tfstate & #TFSTATE_INSPIRED);
				Player.items = Player.items | #IT_QUAD;
				Player.super_time = 1;
				Player.super_damage_finished = time + Goal.super_damage_finished;
				// if its a GoalItem, powerup is permanent, so we use TFSTATE flags
				if (Goal.classname == "item_tfgoal")
				{
					Player.tfstate = Player.tfstate | #TFSTATE_QUAD;
					Player.super_damage_finished = time + 666;
				}
			}
			if (Goal.radsuit_finished > 0)
			{
				Player.items = Player.items | #IT_SUIT;
				Player.rad_time = 1;
				Player.radsuit_finished = time + Goal.radsuit_finished;
				// if its a GoalItem, powerup is permanent, so we use TFSTATE flags
				if (Goal.classname == "item_tfgoal")
				{
					Player.tfstate = Player.tfstate | #TFSTATE_RADSUIT;
					Player.radsuit_finished = time + 666;
				}
			}
		}

		// These results are applied to dead and living players
		if (Goal.lives < 0) 
			bprint(#PRINT_HIGH,"ERROR: GOAL GAVE OUT NEGATIVE LIVES. CUSTOMTF DOESN'T SUPPORT THAT YET\n");

		Player.lives = Player.lives + Goal.lives;
		
		Player.real_frags = Player.real_frags + Goal.frags;
		if (!(toggleflags & #TFLAG_TEAMFRAGS))
			Player.frags = Player.real_frags;
		
		// Now apply the Playerclass limitations & Redisplay Ammo counts
		oldself = self;
		self = Player;
		TeamFortress_CheckClassStats();
		//WK Fix CH's bug fix with this if statement :)
		if (!(self.current_weapon == #WEAP_ASSAULT_CANNON && self.heat >= 0))
			W_SetCurrentAmmo(); //CH stops interrupt weapon fire bug
		self = oldself;
	}
#ifdef MAP_DEBUG
	else
	{
		RPrint("NOT Adding bonuses.\n");
	}
#endif

	if (Goal.goal_result & #TFGR_CAUSERESPAWN && Player != world)
	{
		if ((Player.playerclass == #PC_CUSTOM && Player.done_custom & #CUSTOM_FINISHED) || (Player.playerclass != #PC_UNDEFINED && Player.playerclass != #PC_CUSTOM)) //CH respawn player
		{
//CH this needs lots of testing
//*CH
		local entity temp;
		temp = self;
		self = Player;
		PutClientInServer();
		self = temp;
		}
	}

	// If the Goal resets Spy skin/color then do it
//CH added looking for spykit also removes thief
	if (Goal.goal_result & #TFGR_REMOVE_DISGUISE)
	{
		if (Player.job & #JOB_THIEF && (Player.job & #JOB_ACTIVE || Player.job & #JOB_FULL_HIDE))
			RevealThief(Player,#FALSE);

		if (Player.playerclass == #PC_SPY || Player.cutf_items & #CUTF_SPY_KIT)
		{
			makeImmune(self,time + 4);
			//self.immune_to_check = time + 4;
			Spy_RemoveDisguise(Player);
		}
	}

	// If there's a GoalItem for this goal, give it to the player
	// GoalItems use "items" for the console lights... so don't do it for items.
	if (Goal.items != 0 && Goal.classname != "item_tfgoal")
	{
		// Find the item
		te = Finditem(Goal.items);
		if (te)
			tfgoalitem_GiveToPlayer(te, Player, Goal);
	}

	// If this goal removes an item from the player, remove it
	if (Goal.axhitme != 0)
	{
		te = Finditem(Goal.axhitme);
		if (te.owner == Player)
		{
			tfgoalitem_RemoveFromPlayer(te, Player, 1);
		}
	}

	// if this goal removes a group of items from the player, remove them
	if (Goal.remove_item_group != 0)
	{
		// Find all goals
		te = find (world, classname, "item_tfgoal");
		while (te)
		{
			if (te.group_no == Goal.remove_item_group && te.owner == AP)
			{
				// messy, since we need the item to find the next one,
				// and we also want to remove it
				oldte = te;
				te = find(te, classname, "item_tfgoal");

				tfgoalitem_RemoveFromPlayer(oldte, Player, 1);
			}
			else
			{
				te = find(te, classname, "item_tfgoal");
			}
		}
	}

	// If this goal displays some Item statuses, then do so
	if (Goal.display_item_status1 != 0)
	{
		te = Finditem(Goal.display_item_status1);
		if (te)
			DisplayItemStatus(Goal, Player, te);
		else
			sprint(Player, #PRINT_HIGH, "Item is missing.\n");
	}
	if (Goal.display_item_status2 != 0)
	{
		te = Finditem(Goal.display_item_status2);
		if (te)
			DisplayItemStatus(Goal, Player, te);
		else
			sprint(Player, #PRINT_HIGH, "Item is missing.\n");
	}
	if (Goal.display_item_status3 != 0)
	{
		te = Finditem(Goal.display_item_status3);
		if (te)
			DisplayItemStatus(Goal, Player, te);
		else
			sprint(Player, #PRINT_HIGH, "Item is missing.\n");
	}
	if (Goal.display_item_status4 != 0)
	{
		te = Finditem(Goal.display_item_status4);
		if (te)
			DisplayItemStatus(Goal, Player, te);
		else
			sprint(Player, #PRINT_HIGH, "Item is missing.\n");
	}
};

//=========================================================================
// Remove any results applied to this player by the Goal
// Used when a GoalItem is dropped/removed
void (entity Goal, entity Player) RemoveResults =
{
	local entity oldself, te;
	local float puinvin, puinvis, puquad, purad;

	// Only remove the stats if the player has been affected
	// by this item. This is needed because the player may have
	// died since being affected
	if (Goal.classname == "item_tfgoal")
	{
		if (!(Player.item_list & Goal.item_list))
			return;

		if (Goal.goal_activation & #TFGI_DONTREMOVERES)
			return;

		// Remove the affected flag
		Player.item_list = Player.item_list - (Player.item_list & Goal.item_list);
	}

	if (Goal.health > 0)
		TF_T_Damage (Player, Goal, Goal, Goal.health, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
	if (Goal.health < 0)
		T_Heal(Player, (0 - Goal.health), 0);
	Player.lives = Player.lives - Goal.lives;
	Player.armortype = Player.armortype - Goal.armortype;
	Player.armorvalue = Player.armorvalue - Goal.armorvalue;
	Player.armorclass = Player.armorclass - (Player.armorclass & Goal.armorclass);
	
	Player.real_frags = Player.real_frags - Goal.frags;
	if (!(toggleflags & #TFLAG_TEAMFRAGS))
		Player.frags = Player.real_frags;

	Player.ammo_shells = Player.ammo_shells - Goal.ammo_shells;
	Player.ammo_nails = Player.ammo_nails - Goal.ammo_nails;
	Player.ammo_rockets = Player.ammo_rockets - Goal.ammo_rockets;
	Player.ammo_cells = Player.ammo_cells - Goal.ammo_cells;
	Player.ammo_medikit = Player.ammo_medikit - Goal.ammo_medikit;
	Player.ammo_detpack = Player.ammo_detpack - Goal.ammo_detpack;
	Player.no_grenades_1 = Player.no_grenades_1 - Goal.no_grenades_1;
	Player.no_grenades_2 = Player.no_grenades_2 - Goal.no_grenades_2;

	puinvin = #FALSE;
	puinvis = #FALSE;
	puquad = #FALSE;
	purad = #FALSE;
	// Make sure we don't remove an effect another Goal is also supplying
	te = find (world, classname, "item_tfgoal");
	while (te)
	{
		if ((te.owner == Player) && (te != Goal))
		{
			if (te.invincible_finished > 0)
				puinvin = #TRUE;
			if (te.invisible_finished > 0)
				puinvis = #TRUE;
			if (te.super_damage_finished > 0)
				puquad = #TRUE;
			if (te.radsuit_finished > 0)
				purad = #TRUE;
		}
		te = find(te, classname, "item_tfgoal");
	}


	// Remove all powerups
	if ((Goal.invincible_finished > 0) && (!puinvin))
	{
		// if its a GoalItem, powerup was permanent, so we remove TFSTATE flag
		Player.tfstate = Player.tfstate - (Player.tfstate & #TFSTATE_INVINCIBLE);
		Player.items = Player.items | #IT_INVULNERABILITY;
		Player.invincible_time = 1;
		Player.invincible_finished = time + Goal.invincible_finished;
	}
	if ((Goal.invisible_finished > 0) && (!puinvis))
	{
		// if its a GoalItem, powerup was permanent, so we remove TFSTATE flag
		Player.tfstate = Player.tfstate - (Player.tfstate & #TFSTATE_INVISIBLE);
		Player.items = Player.items | #IT_INVISIBILITY;
		Player.invisible_time = 1;
		Player.invisible_finished = time + Goal.invisible_finished;
	}
	if ((Goal.super_damage_finished > 0) && (!puquad))
	{
		// if its a GoalItem, powerup was permanent, so we remove TFSTATE flag
		Player.tfstate = Player.tfstate - (Player.tfstate & #TFSTATE_QUAD);
		Player.items = Player.items | #IT_QUAD;
		Player.super_time = 1;
		Player.super_damage_finished = time + Goal.super_damage_finished;
	}
	//WK Don't remove the scuba gear
	if ((Goal.radsuit_finished > 0) && (!purad) && !(Player.tf_items & #NIT_SCUBA))
	{
		// if its a GoalItem, powerup was permanent, so we remove TFSTATE flag
		Player.tfstate = Player.tfstate - (Player.tfstate & #TFSTATE_RADSUIT);
		Player.items = Player.items | #IT_SUIT;
		Player.rad_time = 1;
		Player.radsuit_finished = time + Goal.radsuit_finished;
	}

	// Now apply the Playerclass limitations & Redisplay Ammo counts
	oldself = self;
	self = Player;
	TeamFortress_CheckClassStats();
	W_SetCurrentAmmo ();
	self = oldself;
};

//=========================================================================
// Return #TRUE if the player meets the AP criteria
float(entity Goal, entity AP) APMeetsCriteria =
{
	local float gotone, temp;
	local entity te;
	//local string db;

#ifdef MAP_DEBUG
	RPrint("==========================\n");
	#ifdef VERBOSE
		RPrint("AP Criteria Checking\n");
		RPrint("Goal: ");
	#else
		RPrint("APCriteria: ");
	#endif
	RPrint(Goal.netname);
#endif

	if (AP != world)
	{
	#ifdef MAP_DEBUG
		#ifdef VERBOSE
			RPrint("\nAP  : ");
		#else
			RPrint(" by ");
		#endif
		RPrint(AP.netname);
		RPrint("\n");
		RPrint("   Checking team.");
	#endif

		// If a player of a specific team can only activate this
		if (Goal.team_no)
		{
			if (!neo && Goal.team_no != AP.team_no) // Neo mode: allow anyone to activate anything
				return #FALSE;
		}

	#ifdef MAP_DEBUG
		#ifdef VERBOSE
			RPrint("passed.\n   Checking class...");
		#else
			RPrint("class.");
		#endif
	#endif

//CH uses function in tfort.qc to return the class for evaluation
		if (AP.playerclass == #PC_CUSTOM && (Goal.playerclass))
		{
			temp = Return_Custom_Skins(AP);
//CH now that we have their 'class' check
			if (Goal.playerclass != temp)
				return #FALSE;
		}
		// If a player of a specific class can only activate this
		else if (Goal.playerclass)
		{
			if (Goal.playerclass != AP.playerclass)
				return #FALSE;
		}

	#ifdef MAP_DEBUG
		#ifdef VERBOSE
			RPrint("passed.\n   Checking items...");
		#else
			RPrint("items.");
		#endif
	#endif

		// If this activation needs a GoalItem, make sure the player has it
		if (Goal.items_allowed)
		{
			te = Finditem(Goal.items_allowed);
			if (te.owner != AP)
				return #FALSE;
		}

	#ifdef MAP_DEBUG
		#ifdef VERBOSE
			RPrint("passed.\n   Checking goal states...");
		#else
			RPrint("goal states.");
		#endif
	#endif
	}

#ifdef MAP_DEBUG
	#ifdef VERBOSE
	if (AP != world)
		RPrint("passed.\n   Checking Goal States...");
	else
		RPrint("\nChecking Goal States...");
	#else
		RPrint("Goal States.");
	#endif
#endif

	// Check Goal states
	if (Goal.if_goal_is_active)
	{
		te = Findgoal(Goal.if_goal_is_active);
		if (te.goal_state != #TFGS_ACTIVE)
			return #FALSE;
	}

	if (Goal.if_goal_is_inactive)
	{
		te = Findgoal(Goal.if_goal_is_inactive);

		if (te.goal_state != #TFGS_INACTIVE)
			return #FALSE;
	}

	if (Goal.if_goal_is_removed)
	{
		te = Findgoal(Goal.if_goal_is_removed);
		if (te.goal_state != #TFGS_REMOVED)
			return #FALSE;
	}

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("passed.\n   Checking group states...");
	#else
		RPrint("group states.");
	#endif
#endif
 
	if (Goal.if_group_is_active)
	{
		// Find all goals in the group
		te = find (world, classname, "info_tfgoal");
		while (te)
		{
			if (te.group_no == Goal.if_group_is_active)
			{
				if (te.goal_state != #TFGS_ACTIVE)
					return #FALSE;
			}

			te = find(te, classname, "info_tfgoal");
		}
	}

	if (Goal.if_group_is_inactive)
	{
		// Find all goals in the group
		te = find (world, classname, "info_tfgoal");
		while (te)
		{
			if (te.group_no == Goal.if_group_is_inactive)
			{
				if (te.goal_state != #TFGS_INACTIVE)
					return #FALSE;
			}

			te = find(te, classname, "info_tfgoal");
		}
	}

	if (Goal.if_group_is_removed)
	{
		// Find all goals in the group
		te = find (world, classname, "info_tfgoal");
		while (te)
		{
			if (te.group_no == Goal.if_group_is_removed)
			{
				if (te.goal_state != #TFGS_REMOVED)
					return #FALSE;
			}

			te = find(te, classname, "info_tfgoal");
		}
	}

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("passed.\n   Checking item states...");
	#else
		RPrint("item states.");
	#endif
#endif

	if (Goal.if_item_has_moved)
	{
		// Find the item
		te = Finditem(Goal.if_item_has_moved);
		if (te)
		{
			if (te.goal_state != #TFGS_ACTIVE && te.origin == te.oldorigin )
				return #FALSE;
		}
	}

	if (Goal.if_item_hasnt_moved)
	{
		// Find the item
		te = Finditem(Goal.if_item_hasnt_moved);
		if (te)
		{
			if (te.goal_state == #TFGS_ACTIVE || te.origin != te.oldorigin )
				return #FALSE;
		}
	}

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("passed.\n   Checking item groups...");
	#else
		RPrint("item groups ");
	#endif
#endif

	if (AP != world)
	{
		gotone = #FALSE;
		if (Goal.has_item_from_group)
		{
			// Find all goals
			te = find (world, classname, "item_tfgoal");
			while (te != world && !gotone)
			{
				if (te.group_no == Goal.has_item_from_group && te.owner == AP)
					gotone = #TRUE;
		
				te = find(te, classname, "item_tfgoal");
			}

			if (!gotone)
				return #FALSE;
		}
	}

#ifdef MAP_DEBUG
	RPrint("passed.\n");
#endif
	return #TRUE;
};

//=========================================================================
// Setup the way this Timer/Goal/Item will respawn
void(entity Goal) SetupRespawn =
{
	// Timer Goal?
	if (Goal.search_time != 0)
	{
		InactivateGoal(Goal);
		Goal.think = tfgoal_timer_tick;
		Goal.nextthink = time + Goal.search_time;
		return;
	}

	// Check status of respawn for this goal
	// Single Activation, do nothing
	if (Goal.goal_result & #TFGR_SINGLE)
	{
		RemoveGoal(Goal);
		return;
	}

	// Respawn Activation, set up respawn
	if (Goal.wait > 0)
	{
		Goal.nextthink = time + Goal.wait;
		Goal.think = DoRespawn;
		if (Goal.mdl != string_null)	   //CH if it has mdl, remove it so
			setmodel(Goal, string_null); //that people dont think it works
		return;
	}
	// Permanently active goal?
	else if (Goal.wait == -1)
		return;

	// Otherwise, it's a Multiple Goal
	InactivateGoal(Goal);
};

//=========================================================================
// Respawn the goal
void() DoRespawn =
{
	RestoreGoal(self);
	InactivateGoal(self);
};

//=========================================================================
// THE Function for knowing whether to activate or not
// Fuck this map code is a mess!
// Returns #TRUE if you should activate, #FALSE if not
float(entity Goal, entity AP) Activated =
{
	local float APMet, RevAct, Act;

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("\nDoIActivate: ");
	#else
		RPrint("\nGoal: ");
	#endif
	if (Goal.netname == string_null)
		RPrint(Goal.classname);
	else
		RPrint(Goal.netname);
	RPrint(", AP: ");
	RPrint(AP.netname);
	RPrint("\n");
#endif

	if (Goal.goal_state == #TFGS_ACTIVE)
	{
#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("-- Goal already active --\n");
	#endif		
#endif		
		return #FALSE;
	}
	if (Goal.goal_state == #TFGS_REMOVED)
	{
#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("-- Goal is in Removed state --\n");
	#endif		
#endif		
		return #FALSE;
	}
	if (Goal.goal_state == #TFGS_DELAYED)
	{
#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("-- Goal is being Delayed --\n");
	#endif		
#endif		
		return #FALSE;
	}

	APMet = APMeetsCriteria(Goal, AP);
	if (Goal.classname == "item_tfgoal")
		RevAct = Goal.goal_activation & #TFGI_REVERSE_AP;
	else
		RevAct = Goal.goal_activation & #TFGA_REVERSE_AP;
	Act = #FALSE;

	// Does the AP match the AP Criteria?
	if (APMet)
	{

#ifdef MAP_DEBUG
		RPrint("\n");
	#ifdef VERBOSE
		RPrint("-- Criteria met --\n");
	#endif
#endif

		if (!RevAct)
			Act = #TRUE;
	}
	else
	{

#ifdef MAP_DEBUG
		RPrint("\n");
	#ifdef VERBOSE
		RPrint("-- Criteria not met --\n");
	#endif
#endif

		if (RevAct)
		{
			Act = #TRUE;

			#ifdef MAP_DEBUG
				#ifdef VERBOSE
				RPrint("Reverse \n");
				#endif
			#endif
		}
	}

	#ifdef MAP_DEBUG
		#ifdef VERBOSE
	if (Act)
	{
		RPrint("Activation.\n");
	}
	else
	{
		RPrint("NO Activation.\n");
	}
		#endif
	#endif

	return Act;
};

//=========================================================================
// Attempt to activate a Goal
void(entity Goal, entity AP, entity ActivatingGoal) AttemptToActivate =
{
	local entity te;
	//local string st;

	if (Activated(Goal, AP))
	{
		// It's all cool. Do the Results.
		if (ActivatingGoal == Goal)
			DoResults(Goal, AP, #TRUE);
		else if (ActivatingGoal != world)
			DoResults(Goal, AP, (ActivatingGoal.goal_result & #TFGR_ADD_BONUSES));
		else
			DoResults(Goal, AP, 0);
	}
	else
	{
		// If an else goal should be activated, activate it
		if (Goal.else_goal != 0)
		{
		#ifdef MAP_DEBUG
			#ifdef VERBOSE
				RPrint("   Else Goal.\n");
			#endif
		#endif

			te = Findgoal(Goal.else_goal);
			if (te)
				AttemptToActivate(te, AP, ActivatingGoal);
		}
	}
};

//=========================================================================
// Do all the activation/inactivation/etc of individual Goals
void(entity Goal, entity AP) DoGoalWork =
{
	local entity te, RI;

	// If another goal should be activated, activate it
	if (Goal.activate_goal_no != 0)
	{
		Update_team_with_flag_touch(Goal.activate_goal_no);
		te = Findgoal(Goal.activate_goal_no);
		if (te)
			AttemptToActivate(te, AP, Goal);
	}

	// If another goal should be inactivated, inactivate it
	if (Goal.inactivate_goal_no != 0)
	{
		Update_team_with_flag_drop(Goal.inactivate_goal_no);
		te = Findgoal(Goal.inactivate_goal_no);
		if (te)
			InactivateGoal(te);
	}

	// If another goal should be restored, restore it
	if (Goal.restore_goal_no != 0)
	{
		te = Findgoal(Goal.restore_goal_no);
		if (te)
			RestoreGoal(te);
	}

	// If another goal should be removed, remove it
	if (Goal.remove_goal_no != 0)
	{
		te = Findgoal(Goal.remove_goal_no);
		if (te)
			RemoveGoal(te);
	}

	// If a GoalItem should be returned, return it
	if (Goal.return_item_no != 0)
	{
		te = Finditem(Goal.return_item_no);
		if (te)
		{
			if (te.goal_state == #TFGS_ACTIVE)
				tfgoalitem_RemoveFromPlayer(te, te.owner, 1);

			RI = spawn();
			RI.enemy = te;
			RI.think = ReturnItem;
			RI.nextthink = time + 0.1;
			te.solid = #SOLID_NOT;
		}
	}

	// Spawnpoint behaviour
	if (Goal.remove_spawnpoint != 0)
	{
		te = Findteamspawn(Goal.remove_spawnpoint);
		if (te)
		{
			te.goal_state = #TFGS_REMOVED;
			te.team_str_home = string_null;
		}
	}

	if (Goal.restore_spawnpoint != 0)
	{
		te = Findteamspawn(Goal.restore_spawnpoint);
		if (te)
		{
			if (te.goal_state == #TFGS_REMOVED)
			{
				te.goal_state = #TFGS_INACTIVE;
				if (te.team_no == 1)
					te.team_str_home = "ts1";
				else if (te.team_no == 2)
					te.team_str_home = "ts2";
				else if (te.team_no == 3)
					te.team_str_home = "ts3";
				else if (te.team_no == 4)
					te.team_str_home = "ts4";
			}
		}
	}
};

//=========================================================================
// Do all the activation/inactivation/etc of Goal Groups
void(entity Goal, entity AP) DoGroupWork =
{
	local string st;
	local entity tg;
	local float allset;

	// Check all goals activated flag
	if (Goal.all_active != 0)
	{
		if (Goal.last_impulse == 0)
		{
			// No goal specified in .lastimpulse. Print error.
			RPrint("Goal ");
			st = ftos(Goal.goal_no);
			RPrint(st);
			RPrint(" has a .all_active specified, but no .last_impulse\n");
		}
		else
		{

		#ifdef MAP_DEBUG
			#ifdef VERBOSE
				RPrint("All Active Group Check.\n");
			#endif
		#endif

			allset = 1;
			// Find all goals
			tg = find (world, classname, "info_tfgoal");
			while (tg)
			{
				if (tg.group_no == Goal.all_active)
				{
					if (tg.goal_state != #TFGS_ACTIVE)
						allset = 0;
				}
		
				tg = find(tg, classname, "info_tfgoal");
			}

			// If all goals in this group are activated, do it
			if (allset)
			{

		#ifdef MAP_DEBUG
			#ifdef VERBOSE
				RPrint("All Active, Activating last_impulse.\n");
			#endif
		#endif

				tg = Findgoal(Goal.last_impulse);
				if (tg)
					DoResults(tg, AP, (Goal.goal_result & #TFGR_ADD_BONUSES));
			}
		#ifdef MAP_DEBUG
			#ifdef VERBOSE
			else
			{
				RPrint("Not all Active.\n");
			}
			#endif
		#endif
		}
	}

	// Check Activate all in the group flag
	if (Goal.activate_group_no != 0)
	{
		// Find all goals
		tg = find (world, classname, "info_tfgoal");
		while (tg)
		{
			if (tg.group_no == Goal.activate_group_no)
				DoResults(tg, AP, 0);	// Don't apply bonuses

			tg = find(tg, classname, "info_tfgoal");
		}
	}

	// Check Inactivate all in the group flag
	if (Goal.inactivate_group_no != 0)
	{
		// Find all goals
		tg = find (world, classname, "info_tfgoal");
		while (tg)
		{
			if (tg.group_no == Goal.inactivate_group_no)
				InactivateGoal(tg);
	
			tg = find(tg, classname, "info_tfgoal");
		}
	}

	// Check Remove all in the group flag
	if (Goal.remove_group_no != 0)
	{
		// Find all goals
		tg = find (world, classname, "info_tfgoal");
		while (tg)
		{
			if (tg.group_no == Goal.remove_group_no)
				RemoveGoal(tg);
	
			tg = find(tg, classname, "info_tfgoal");
		}
	}
	
	// Check Restore all in the group flag
	if (Goal.restore_group_no != 0)
	{
		// Find all goals
		tg = find (world, classname, "info_tfgoal");
		while (tg)
		{
			if (tg.group_no == Goal.restore_group_no)
				RestoreGoal(tg);
	
			tg = find(tg, classname, "info_tfgoal");
		}
	}

	// Spawnpoint behaviour
	if (Goal.remove_spawngroup != 0)
	{
		// Find all goals
		tg = find (world, classname, "info_player_teamspawn");
		while (tg)
		{
			if (tg.group_no == Goal.remove_spawngroup)
			{
				tg.goal_state = #TFGS_REMOVED;
				tg.team_str_home = string_null;
			}
	
			tg = find(tg, classname, "info_player_teamspawn");
		}
	}

	if (Goal.restore_spawngroup != 0)
	{
		// Find all goals
		tg = find (world, classname, "info_player_teamspawn");
		while (tg)
		{
			if (tg.group_no == Goal.restore_spawngroup)
			{
				tg.goal_state = #TFGS_INACTIVE;
				if (tg.team_no == 1)
					tg.team_str_home = "ts1";
				else if (tg.team_no == 2)
					tg.team_str_home = "ts2";
				else if (tg.team_no == 3)
					tg.team_str_home = "ts3";
				else if (tg.team_no == 4)
					tg.team_str_home = "ts4";
			}
	
			tg = find(tg, classname, "info_player_teamspawn");
		}
	}
};

//=========================================================================
// Do all the checking of Item Groups
void(entity Item, entity AP) DoItemGroupWork =
{
	local entity tg, carrier;
	local float allcarried;
	local string st;

	allcarried = #TRUE;
	if (Item.distance != 0)
	{
		if (Item.pain_finished == 0)
		{
			// No goal specified in .pain_finished. Print error.
			RPrint("GoalItem ");
			st = ftos(Item.goal_no);
			RPrint(st);
			RPrint(" has a .distance specified, but no .pain_finished\n");
		}

		// Find all goals
		tg = find (world, classname, "item_tfgoal");
		while (tg)
		{
			if (tg.group_no == Item.distance)
			{
				if (tg.goal_state != #TFGS_ACTIVE)
					allcarried = #FALSE;
			}
	
			tg = find(tg, classname, "item_tfgoal");
		}

		if (allcarried == #TRUE)
		{
			tg = Findgoal(Item.pain_finished);
			if (tg)
				DoResults(tg, AP, (Item.goal_result & #TFGR_ADD_BONUSES));
		}
	}

	allcarried = #TRUE;
	if (Item.speed != 0)
	{
		if (Item.attack_finished == 0)
		{
			// No goal specified in .attack_finished. Print error.
			RPrint("GoalItem ");
			st = ftos(Item.goal_no);
			RPrint(st);
			RPrint(" has a .speed specified, but no .attack_finished\n");
		}

		carrier = world;
		// Find all goals
		tg = find (world, classname, "item_tfgoal");
		while (tg)
		{
			if (tg.group_no == Item.speed)
			{
				if (tg.goal_state != #TFGS_ACTIVE)
					allcarried = #FALSE;
				else if (carrier == world)
					carrier = tg.owner;
				else if (carrier != tg.owner)
					allcarried = #FALSE;
			}
	
			tg = find(tg, classname, "item_tfgoal");
		}

		if (allcarried == #TRUE)
		{
			tg = Findgoal(Item.attack_finished);
			if (tg)
				DoResults(tg, AP, (Item.goal_result & #TFGR_ADD_BONUSES));
		}
	}
};

//=========================================================================
// Do all the activation/removal of Quake Triggers
void(entity Goal, entity AP) DoTriggerWork =
{
	local entity otemp, stemp, t;

#ifdef MAP_DEBUG
	if (Goal.killtarget != string_null)
	{
		RPrint("Killing Target(s): ");
		RPrint(Goal.killtarget);
		RPrint("\n");
	}
#endif

	// remove targets
	if (Goal.killtarget)
	{
		t = world;
		do
		{
			t = find(t, targetname, Goal.killtarget);

			if (t != world)
				remove(t);

		} while ( t != world );
	}

#ifdef MAP_DEBUG
	if (Goal.target != string_null)
	{
		RPrint("Activating Target(s): ");
		RPrint(Goal.target);
		RPrint("\n");
	}
#endif
	
	// fire targets
	if (Goal.target)
	{
		t = world;
		activator = AP;
		do
		{
			t = find (t, targetname, Goal.target);
			if (t == world)
				return;
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use ();
			}
			self = stemp;
			other = otemp;
			activator = AP;
		} while ( t != world );
	}
};

//=========================================================================
// Handles Delayed Activation of Goals
void() DelayedResult =
{
	if (self.enemy.goal_state == #TFGS_DELAYED)
		DoResults(self.enemy, self.owner, self.weapon);
	
	dremove(self);
};

//=========================================================================
// Do the results for the Timer/Goal/Item
void(entity Goal, entity AP, float addb) DoResults =
{
	local entity te;//, oldself;
//	local string st;
	local float winners;

	// Is the goal already activated?
	// This check is needed for goals which are being activated by other goals
	if (Goal.goal_state == #TFGS_ACTIVE)
		return;

	// Delayed Activation?
	if (Goal.delay_time > 0 && Goal.goal_state != #TFGS_DELAYED)
	{
	#ifdef MAP_DEBUG
		RPrint("Delaying Results of ");
		RPrint(Goal.netname);
		RPrint("\n");
	#endif
		Goal.goal_state = #TFGS_DELAYED;
		te = spawn();
		te.think = DelayedResult;
		te.nextthink = time + Goal.delay_time;
		te.owner = AP;
		te.enemy = Goal;
		te.weapon = addb;
		return;
	}

	UpdateAbbreviations(Goal);

	Goal.goal_state = #TFGS_INACTIVE;

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("-= Doing Results =-\n");
		RPrint("Goal: ");
	#else
		RPrint("DoRes: ");
	#endif

	RPrint(Goal.netname);

	#ifdef VERBOSE
		RPrint("\nAP  : ");
	#else
		RPrint(" by ");
	#endif

	RPrint(AP.netname);

	if (addb)
		RPrint("\n  adding bonuses");
	else
		RPrint("\nNOT adding bonuses");

	#ifdef VERBOSE
		RPrint("\n-=================-\n");
	#else
		RPrint("\n");
	#endif
#endif

	//- OfN if Goal.option is 1 then no sound attenuation (ATTN_NONE)
	local float attn_value;
	attn_value=#ATTN_NORM;

	if (Goal.option == 1)
		attn_value=#ATTN_NONE;

	// Make the sound
	if (Goal.noise)
		sound (other, #CHAN_ITEM, Goal.noise, 1, attn_value);

	winners = #FALSE;
	// Increase scores
	if (Goal.increase_team1 != 0)
	{
		TeamFortress_TeamIncreaseScore(1, Goal.increase_team1);
		//if (chris)
		//	RoundStop(1);
		winners = 1;
	}
	if (Goal.increase_team2 != 0)
	{
		TeamFortress_TeamIncreaseScore(2, Goal.increase_team2);

		// Attackers Go Red mode -PZ
		if (agr) if (Goal.increase_team2 >= 10)
		{
			local entity player;
			player = find(world, classname, "player");
			while (player)
			{
				CenterPrint(player, " Red Captures Blue's Flag! \n");
				player = find(player, classname, "player");
			}
			BroadcastSound("boss2/pop2.wav");
			AGR_resetTimer();
		}

		//if (chris)
		//	RoundStop(2);
		if (winners)
			winners = 100;
		else
			winners = 2;
	}
	if (Goal.increase_team3 != 0)
	{
		TeamFortress_TeamIncreaseScore(3, Goal.increase_team3);
		//if (chris)
		//	RoundStop(3);
		if (winners)
			winners = 100;
		else
			winners = 3;
	}
	if (Goal.increase_team4 != 0)
	{
		TeamFortress_TeamIncreaseScore(4, Goal.increase_team4);
		//if (chris)
		//	RoundStop(4);
		//winners = #TRUE;

		if (winners)
			winners = 100;
		else
			winners = 4;
	}
	// Display short team scores only if scores changed
	if (winners)
	{
		if (winners == 1)
			TeamFortress_TeamShowScores(2,1,Goal.increase_team1);
		else if (winners == 2)
			TeamFortress_TeamShowScores(2,2,Goal.increase_team2);
		else if (winners == 3)
			TeamFortress_TeamShowScores(2,3,Goal.increase_team3);
		else if (winners == 4)
			TeamFortress_TeamShowScores(2,4,Goal.increase_team4);
		else
			TeamFortress_TeamShowScores(2,0,0);
	}

	// CTF Map support
	if (CTF_Map == #TRUE)
	{
		if (AP != world)
		{
			if (Goal.goal_no == #CTF_FLAG1)
			{
				te = find(world, classname, "player");
				while (te != world)
				{
					if (te.team_no == 2)
					{
						if (te == AP)
						{
							winners = random();
							if (winners < 0.1)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM1);
							else if (winners < 0.2)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM2);
							else if (winners < 0.6)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM3);
							else if (winners < 0.7)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM4);
							else if (winners < 0.8)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM5_2);
							else if (winners < 0.95)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM6);
							else 
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM7);
						}
						else
							CenterPrint2(te, "\n\n\n", "Your team гот the енемы flag!!");
					}
					else
						CenterPrint2(te, "\n\n\n", "Your flag has been такен!!");

					te = find(te, classname, "player");
				}
				bprint(#PRINT_HIGH, AP.netname);
				bprint(#PRINT_HIGH, " гот the блуе flag!\n");

				AP.items = AP.items | #IT_KEY1;
			}
			else if (Goal.goal_no == #CTF_FLAG2)
			{
				te = find(world, classname, "player");
				while (te != world)
				{
					if (te.team_no == 1)
					{
						if (te == AP)
						{
							winners = random();
							if (winners < 0.1)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM1);
							else if (winners < 0.2)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM2);
							else if (winners < 0.6)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM3);
							else if (winners < 0.7)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM4);
							else if (winners < 0.8)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM5_1);
							else if (winners < 0.95)
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM6);
							else 
								CenterPrint2(te, "\n\n\n", #MSG_CTF_FLAG_GRAB_TEAM7);
						}
						else
							CenterPrint2(te, "\n\n\n", "Your team гот the енемы flag!!");
					}
					else
						CenterPrint2(te, "\n\n\n", "Your flag has been такен!!");

					te = find(te, classname, "player");
				}
				bprint(#PRINT_HIGH, AP.netname);
				bprint(#PRINT_HIGH, " гот the ред flag!\n");
				AP.items = AP.items | #IT_KEY2;
			}
			else if (Goal.goal_no == #CTF_DROPOFF1)
			{
				te = find(world, classname, "player");
				while (te != world)
				{
					if (te.team_no == 2)
					{
						if (te == AP)
							CenterPrint2(te, "\n\n\n", "You цаптуред the flag!!");
						else
							CenterPrint2(te, "\n\n\n", "Your flag was цаптуред!!");
					}
					else
						CenterPrint2(te, "\n\n\n", "Your team цаптуред the flag!!");

					te = find(te, classname, "player");
				}
				bprint(#PRINT_HIGH, AP.netname);
				bprint(#PRINT_HIGH, " цаптуред the ред flag!\n");
				AP.items = AP.items - (AP.items & #IT_KEY2);

			}
			else if (Goal.goal_no == #CTF_DROPOFF2)
			{
				te = find(world, classname, "player");
				while (te != world)
				{
					if (te.team_no == 1)
					{
						if (te == AP)
							CenterPrint2(te, "\n\n\n", "You цаптуред the flag!!");
						else
							CenterPrint2(te, "\n\n\n", "Your flag was цаптуред!!");
					}
					else
						CenterPrint2(te, "\n\n\n", "Your team цаптуред the flag!!");

					te = find(te, classname, "player");
				}
				bprint(#PRINT_HIGH, AP.netname);
				bprint(#PRINT_HIGH, " цаптуред the блуе flag!\n");
				AP.items = AP.items - (AP.items & #IT_KEY1);
			}
		}
	}

	// Go through all the players and do any results
	te = find(world, classname, "player");
	while (te != world)
	{
		// Centerprinting
		if (Goal.broadcast != string_null && CTF_Map == #FALSE)
			CenterPrint2(te, "\n\n\n", Goal.broadcast);
		if (Goal.netname_broadcast != string_null && CTF_Map == #FALSE)
		{
			sprint(te, #PRINT_HIGH, AP.netname);
			sprint(te, #PRINT_HIGH, Goal.netname_broadcast);
		}

		if (AP == te)
		{
			if (Goal.message != string_null)
				CenterPrint2(te, "\n\n\n", Goal.message);
		}
		else if (AP.team_no == te.team_no)
		{
			if (Goal.owners_team_broadcast != string_null && te.team_no == Goal.owned_by)
				CenterPrint2(te, "\n\n\n", Goal.owners_team_broadcast);
			else if (Goal.team_broadcast != string_null)
				CenterPrint2(te, "\n\n\n", Goal.team_broadcast);

			if (Goal.netname_owners_team_broadcast != string_null && te.team_no == Goal.owned_by)
			{
				sprint(te, #PRINT_HIGH, AP.netname);
				sprint(te, #PRINT_HIGH, Goal.netname_owners_team_broadcast);
			}
			else if (Goal.netname_team_broadcast != string_null)
			{
				sprint(te, #PRINT_HIGH, AP.netname);
				sprint(te, #PRINT_HIGH, Goal.netname_team_broadcast);
			}
		}
		else
		{
			if (Goal.owners_team_broadcast != string_null && te.team_no == Goal.owned_by)
				CenterPrint2(te, "\n\n\n", Goal.owners_team_broadcast);
			else if (Goal.non_team_broadcast != string_null)
				CenterPrint2(te, "\n\n\n", Goal.non_team_broadcast);

			if (Goal.netname_owners_team_broadcast != string_null && te.team_no == Goal.owned_by)
			{
				sprint(te, #PRINT_HIGH, AP.netname);
				sprint(te, #PRINT_HIGH, Goal.netname_owners_team_broadcast);
			}
			else if (Goal.netname_non_team_broadcast != string_null)
			{
				sprint(te, #PRINT_HIGH, AP.netname);
				sprint(te, #PRINT_HIGH, Goal.netname_non_team_broadcast);
			}
		}

		if (IsAffectedBy(Goal, te, AP))
		{
			// If its a Timer Goal, see if it needs to check Criteria again
			if (Goal.search_time != 0 && Goal.goal_effects & #TFGE_TIMER_CHECK_AP)
			{
				if (APMeetsCriteria(Goal, te))
					Apply_Results(Goal, te, AP, addb);
			}
			else
			{
				Apply_Results(Goal, te, AP, addb);
			}
		}

		te = find(te, classname, "player");
	}

	// Goal is now active
	// Items are not always set to active. They handle their modes.
	if (Goal.classname != "item_tfgoal")
		Goal.goal_state = #TFGS_ACTIVE;

	// EndGame checking 
	if (Goal.goal_result & #TFGR_ENDGAME)
	{
		// Display Long TeamScores to everyone
		TeamFortress_TeamShowScores(1,0,0);
		winners = TeamFortress_TeamGetWinner();

		// Stop everyone
		te = find (world, classname, "player");
		while (te)
		{
			te.takedamage = 0;
			te.movetype = #MOVETYPE_NONE;
			te.velocity = '0 0 0';
			te.avelocity = '0 0 0';

			te = find(te, classname, "player");
		}

		te = spawn();
		te.nextthink = time + 5; // Allow 5 secs to read the scores
		te.think = execute_changelevel;

		dremove(Goal);
		return;
	}

//CH spawn explosions if so needed
	if (Goal.goal_effects & #TFGE_CAUSE_EXPLOSION)
	{
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
		WriteCoord (#MSG_BROADCAST, self.origin_x);
		WriteCoord (#MSG_BROADCAST, self.origin_y);
		WriteCoord (#MSG_BROADCAST, self.origin_z);
	#ifdef QUAKE_WORLD
		multicast (self.origin, #MULTICAST_PHS);
	#endif
//		BecomeExplosion();
	}

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("Doing Groupwork...\n");
	#endif
#endif

	// Do Goal Group checking
	DoGroupWork(Goal, AP);

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("Doing Goalwork...\n");
	#endif
#endif

	// Do Goal checking
	DoGoalWork(Goal, AP);

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("Doing Triggerwork...\n");
	#endif
#endif

	// Do Quake Trigger actions
	DoTriggerWork(Goal, AP);

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("Setting up Respawn...\n");
	#endif
#endif

	// Setup for Respawn
	// Items and Triggers do their own respawn work
	if (Goal.classname == "info_tfgoal")
		SetupRespawn(Goal);
};

//=========================================================================
// GOAL FUNCTIONS
//=========================================================================
// Touch function for Goals
void() tfgoal_touch =
{
	local entity te;

	// If it is not activated in by the player's touch, return
	if (!(self.goal_activation & #TFGA_TOUCH))
		return;

	if (other.classname != "player")
		return;

	// If we're in prematch mode, ignore the touch
	if (prematch >= time)
		return;

	if (other.health <= 0) // dead players out
		return;
		
	if (other.penance_time >= time)
		return;
	
	// If it's already active, don't bother
	if (self.goal_state == #TFGS_ACTIVE)
	{
#ifdef MAP_DEBUG
		RPrint("Goal already active. aborting touch.\n");
#endif
		return;
	}

	// Neo mode: don't let Neo pick up resupply packs
	// Let's hope this doesn't kill any neat map features..
	// WK 2-2-09 Maybe it should just prevent gains from goals?
	if (neo) if (other == neoLives)
		return;
	
	// CTF Hack to make sure the key is in place.
	// Temporary hack :)
	if (CTF_Map == #TRUE)
	{
		if ((self.goal_no == #CTF_DROPOFF1) && (other.team_no == 1))
		{
			te = Finditem(#CTF_FLAG1);
			if ((te.goal_state == #TFGS_ACTIVE) || (te.origin != te.oldorigin))
				return;
		}
		if ((self.goal_no == #CTF_DROPOFF2) && (other.team_no == 2))
		{
			te = Finditem(#CTF_FLAG2);
			if ((te.goal_state == #TFGS_ACTIVE) || (te.origin != te.oldorigin))
				return;
		}
	}

	AttemptToActivate(self, other, self);
};

//=========================================================================
// Use (Triggered) function for Goals
void() info_tfgoal_use =
{
#ifdef MAP_DEBUG
	RPrint("\n");
	RPrint("TFGoal triggered by other entity.\n");
#endif

	AttemptToActivate(self, activator, self);
};

//=========================================================================
// Timer goal tick
void() tfgoal_timer_tick =
{
	// Check criteria
	if (self.goal_state != #TFGS_REMOVED)
	{
	#ifdef MAP_DEBUG
		RPrint("==========================\n");
		#ifdef VERBOSE
			RPrint("Timer Tick for: ");
		#else
			RPrint("Tick: ");
		#endif
		RPrint(self.netname);
		RPrint("   Checking criteria...");
	#endif

		if (APMeetsCriteria(self, world))
		{
			DoResults(self, world, #TRUE);
		}
		else
		{
			InactivateGoal(self);
			self.think = tfgoal_timer_tick;
			self.nextthink = time + self.search_time;
		}
	}
};


//=========================================================================
// GOALITEM FUNCTIONS
//=========================================================================
// Touch function for the goalitem entity
void() item_tfgoal_touch =
{
	#ifdef QUAKE_WORLD
	/*if (infokey(world,"ceasefire")=="on") //OfN
		return;*/

	if (ceasefire)
		return;
	#endif

	// Attackers Go Red mode -PZ
	// don't let Red have flag if Blue has no players
	if (agr) if (self.team_no == 2) if(!agrTimerRunning)
		return;

	//local string st;
	local entity te;

	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;
	
	// Don't let them take goalitems in prematch
	if (prematch >= time)
		return;
		
	// Don't let lame teamkillers take items
	if (other.penance_time >= time)
		return;

	// OfN - Dont let them pick it up repeatedly
	if (self.demon_one == other)
	if (self.has_holo > time)
		return;
	
	// CTF Hack to return your key.
	// Temporary hack :)
	if (CTF_Map == #TRUE)
	{
		if (self.goal_no == #CTF_FLAG1)
		{
			// Flag not at home?
			if (self.origin != self.oldorigin)
			{
				if (other.team_no == 1)
				{
					bprint(#PRINT_HIGH, other.netname);
					bprint(#PRINT_HIGH, " ретурнед the блуе flag!\n");

					te = find(world, classname, "player");
					while (te != world)
					{
						if (te.team_no == 1)
							CenterPrint2(te, "\n\n\n", "Your flag was ретурнед!!");
						else
							CenterPrint2(te, "\n\n\n", "The енемы flag was ретурнед!!");

						te = find(te, classname, "player");
					}
	
					self.goal_state = #TFGS_INACTIVE;
					self.solid = #SOLID_TRIGGER;
					self.touch = item_tfgoal_touch;
					self.origin = self.oldorigin;
					setmodel(self, self.mdl);
					setorigin(self, self.origin);
					sound (self, #CHAN_VOICE, "items/itembk2.wav", 1, #ATTN_NORM);
					return;
				}
			}
			else
			{
				if (other.team_no == 1)
					return;
			}
		}
		else if (self.goal_no == #CTF_FLAG2)
		{
			// Flag not at home?
			if (self.origin != self.oldorigin)
			{
				if (other.team_no == 2)
				{
					bprint(#PRINT_HIGH, other.netname);
					bprint(#PRINT_HIGH, " ретурнед the ред flag!\n");

					te = find(world, classname, "player");
					while (te != world)
					{
						if (te.team_no == 2)
							CenterPrint(te, "\n\n\n Your flag was ретурнед!!");
						else
							CenterPrint(te, "\n\n\n The енемы flag was ретурнед!!");

						te = find(te, classname, "player");
					}
	
					self.goal_state = #TFGS_INACTIVE;
					self.solid = #SOLID_TRIGGER;
					self.touch = item_tfgoal_touch;
					self.origin = self.oldorigin;
					setmodel(self, self.mdl);
					setorigin(self, self.origin);
					sound (self, #CHAN_VOICE, "items/itembk2.wav", 1, #ATTN_NORM);
					return;
				}
			}
			else
			{
				if (other.team_no == 2)
					return;
			}
		}
	}

	if (Activated(self, other))
	{
		// Give it to the player
		tfgoalitem_GiveToPlayer(self, other, self);
		self.goal_state = #TFGS_ACTIVE;
	}
	else
	{
		// If an else goal should be activated, activate it
		if (self.else_goal != 0)
		{

#ifdef MAP_DEBUG
	#ifdef VERBOSE
		RPrint("   Else Goal.\n");
	#endif
#endif

			te = Findgoal(self.else_goal);
			if (te)
				AttemptToActivate(te, other, self);
		}
	}
};

//=========================================================================
// Give the GoalItem to a Player. 
void(entity Item, entity AP, entity Goal) tfgoalitem_GiveToPlayer =
{
	//local string sp;

#ifdef MAP_DEBUG
	RPrint("Giving ");
	RPrint(Item.netname);
	RPrint(" to ");
	RPrint(AP.netname);
	RPrint("\n");
#endif

	Item.owner = AP;
	// Remove it from the map
	if (Item.mdl != string_null)
		setmodel(Item, string_null);
	Item.solid = #SOLID_NOT;

	// Do the deeds on the player
	if (Item.goal_activation & #TFGI_GLOW)
		AP.effects = AP.effects | #EF_DIMLIGHT;
	if (Item.goal_activation & #TFGI_SLOW)
		TeamFortress_SetSpeed(AP);

	#ifdef TEAMITEMS_COLORGLOW
	// Make player glow with an appropiate color!
	if (Item.goal_activation & #TFGI_GLOW) // Only if supposed to give glow to players
	if (number_of_teams == 2) // Only if blue and red teams on map
	if (Item.team_no) // Is this item for a team?
	{
		local float glowcolor;
		glowcolor = 0;
		
		if (Item.goal_activation & #TFGI_REVERSE_AP) // Reversed criteria
		{
			if (Item.team_no == 1) // Blue team
				glowcolor = #EF_BLUE;				 
			else if (Item.team_no == 2) // Red team
				glowcolor = #EF_RED;				
		}
		else // Normal criteria
		{
			if (Item.team_no == 1) // Blue team
				glowcolor = #EF_RED;
			else if (Item.team_no == 2) // Red team
				glowcolor = #EF_BLUE;				 
		}
		
		// Set color to player
		// TODO/FIXME: This doesn't take into account multiple items that would cause the color
		#ifdef TEAMITEMS_PLAYERCOLOR
		AP.effects = AP.effects | glowcolor;
		#endif
	}
	#endif

	if (Item.goal_activation & #TFGI_ITEMGLOWS)
		Item.effects = Item.effects - (Item.effects | #EF_DIMLIGHT);

	// Light up console icons
	if (Item.items & #IT_KEY1)
		AP.items = AP.items | #IT_KEY1;
	if (Item.items & #IT_KEY2)
		AP.items = AP.items | #IT_KEY2;

	// Only do the results if we're allowed to
	if (Goal != Item)
	{
		if (Goal.goal_result & #TFGR_NO_ITEM_RESULTS)
		{
			Item.goal_state = #TFGS_ACTIVE;
			return;
		}
	}

#ifdef MAP_DEBUG
	#ifdef VERBOSE
			RPrint("Doing item results...\n");
	#endif
#endif

	// Prevent the Player from disguising themself if applicable
//CH added looking for spykit & thief
	if (Item.goal_result & #TFGR_REMOVE_DISGUISE)
	{
		if (AP.job & #JOB_THIEF && (AP.job & #JOB_ACTIVE || AP.job & #JOB_FULL_HIDE))
			RevealThief(AP,#FALSE);

		if (AP.playerclass == #PC_SPY || AP.cutf_items & #CUTF_SPY_KIT)
		{
			AP.is_unabletospy = 1;
		}
	}

	// Do the Results, adding the bonuses
	DoResults(Item, AP, #TRUE);

	// Check the Item Group Stuff
	DoItemGroupWork(Item, AP);
	
};

//=========================================================================
//Update which team has the flag
void(float item) Update_team_with_flag_touch =
{
	if ( mapname != "steal4d" )
	{
		team_with_flag = 0;
		return;
	}
	if (item == 103)
	{
		team_with_flag = 1; 
		friends1_mask = 0;
		friends2_mask = friends3_mask = friends4_mask = 14;
		return;
	}
	if (item == 203) {
		team_with_flag = 2; 
		friends2_mask = 0;
		friends1_mask = friends3_mask = friends4_mask = 13;
		return;
	}
	if (item == 303) {
		team_with_flag = 3; 
		friends3_mask = 0;
		friends1_mask = friends2_mask = friends4_mask = 11;
		return;
	}
	if (item == 403) {
		team_with_flag = 4; 
		friends4_mask = 0;
		friends1_mask = friends2_mask = friends3_mask = 7;
		return;
	}
};

//=========================================================================
//Update which team has the flag
void(float item) Update_team_with_flag_drop =
{
	if ( mapname != "steal4d" ){
		team_with_flag = 0;
		return;
	}
	if (item != 103 && item != 203 && item != 303 && item != 403)
		return;
	team_with_flag= 0;
	friends1_mask= friends2_mask= friends3_mask= friends4_mask= 0;
};

//=========================================================================
// Return the Item to its starting point
void() ReturnItem =
{
	self.enemy.goal_state = #TFGS_INACTIVE;
//CH sets solid type
	if (self.enemy.goal_activation & #TFGI_GOAL_IS_SOLID)
		self.enemy.solid = #SOLID_BBOX;
	else
		self.enemy.solid = #SOLID_TRIGGER;
	self.enemy.movetype = #MOVETYPE_NONE;
	self.enemy.touch = item_tfgoal_touch;
	self.enemy.origin = self.enemy.oldorigin;
	if (self.enemy.mdl != string_null)
		setmodel(self.enemy, self.enemy.mdl);
	setorigin(self.enemy, self.enemy.origin);
	sound(self.enemy, #CHAN_VOICE, "items/itembk2.wav", 1, #ATTN_NORM);

	// Restore a goal if needed
	tfgoalitem_checkgoalreturn(self.enemy);

	dremove(self);
};

//=========================================================================
// Remove the GoalItem from a Player. 
void(entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer =
{
	local entity te;
	local float lighton, slowon;
	local float key1on, key2on;
	local float spyoff;
	//local string db1;
	local entity DelayReturn;

	if (Item == world)
	{
		RPrint("error: tfgoalitem_RemoveFromPlayer(): Item == world");
		return;
	}

#ifdef MAP_DEBUG
	RPrint("Removing ");
	RPrint(Item.netname);
	RPrint(" from ");
	RPrint(AP.netname);
	RPrint("\n");
#endif

	lighton = #FALSE;
	slowon = #FALSE;
	key1on = #FALSE;
	key2on = #FALSE;
	spyoff = #FALSE;
	// Remove the deeds from the player
	// Make sure we don't remove an effect another Goal is also supplying
	te = find (world, classname, "item_tfgoal");
	while (te)
	{
		if ((te.owner == AP) && (te != Item))
		{
			if (te.goal_activation & #TFGI_GLOW)
				lighton = #TRUE;
			if (te.goal_activation & #TFGI_SLOW)
				slowon = #TRUE;

			if (te.items & #IT_KEY1)
				key1on = #TRUE;
			if (te.items & #IT_KEY2)
				key2on = #TRUE;

			if (te.goal_result & #TFGR_REMOVE_DISGUISE)
				spyoff = 1;
		}
		te = find(te, classname, "item_tfgoal");
	}

	// Check Powerups too
	if (!lighton)
	{
		if (AP.invincible_finished > time + 3)
			lighton = #TRUE;
	}

	if (!lighton)
		AP.effects = AP.effects - (AP.effects & #EF_DIMLIGHT);

	if (Item.goal_activation & #TFGI_ITEMGLOWS)
		Item.effects = Item.effects | #EF_DIMLIGHT;
	
	#ifdef TEAMITEMS_COLORGLOW
	// Make it glow with an appropiate color!
	if (number_of_teams == 2) // Only if blue and red teams on map
	if (Item.team_no) // Is this item for a team?
	{
		local float glowcolor;
		glowcolor = 0;

		#ifdef TEAMITEMS_FORCEDGLOW
		if (Item.team_no == 1 || Item.team_no == 2)
			Item.effects = Item.effects | #EF_DIMLIGHT;
		#endif
		
		if (Item.goal_activation & #TFGI_REVERSE_AP) // Reversed criteria
		{
			if (Item.team_no == 1) // Blue team
				glowcolor = #EF_BLUE;				 
			else if (Item.team_no == 2) // Red team
				glowcolor = #EF_RED;				
		}
		else // Normal criteria
		{
			if (Item.team_no == 1) // Blue team
				glowcolor = #EF_RED;
			else if (Item.team_no == 2) // Red team
				glowcolor = #EF_BLUE;				 
		}

		Item.effects = Item.effects | glowcolor;

		// Remove color from player
		// TODO/FIXME: This doesn't take into account multiple items that would cause the color
		#ifdef TEAMITEMS_PLAYERCOLOR
		AP.effects = AP.effects - (AP.effects & glowcolor);
		#endif
	}
	#endif	  

	// Remove the Spy prevention
	if (!spyoff)
		AP.is_unabletospy = 0;

	// Remove the Light up of console icons
	if (!key1on)
		AP.items = AP.items - (AP.items & #IT_KEY1);
	if (!key2on)
		AP.items = AP.items - (AP.items & #IT_KEY2);

	// Remove AP Modifications
	// Go through all the players and do any results
	te = find(world, classname, "player");
	while (te != world)
	{
		if (IsAffectedBy(Item, te, AP))
		{
			RemoveResults(Item, te);
		}

		te = find(te, classname, "player");
	}

/*
	db1 = ftos(method);
	RPrint("returning via method : ");
	RPrint(db1);
	RPrint("\n");
*/

	// Return it to the starting point if the flag is set
	if (method == 0 || method == 2) 	// Dropped by a dying player
	{
		// Do messages
		te = find(world, classname, "player");
		while (te != world)
		{
			if (te.team_no == Item.owned_by)
			{
				if (Item.team_drop != string_null)
					CenterPrint2(te, "\n\n\n", Item.team_drop);
				if (Item.netname_team_drop != string_null)
				{
					sprint(te, #PRINT_HIGH, AP.netname);
					sprint(te, #PRINT_HIGH, Item.netname_team_drop);
				}
			}
			else // (te.team_no != Item.owned_by)
			{
				if (Item.non_team_drop != string_null)
					CenterPrint2(te, "\n\n\n", Item.non_team_drop);
				if (Item.netname_non_team_drop != string_null)
				{
					sprint(te, #PRINT_HIGH, AP.netname);
					sprint(te, #PRINT_HIGH, Item.netname_non_team_drop);
				}
			}

			te = find(te, classname, "player");
		}
	
		// Drop it if the flag is set
		if (Item.goal_activation & #TFGI_RETURN_DROP)
		{
			DelayReturn = spawn();
			DelayReturn.enemy = Item;
			DelayReturn.think = ReturnItem;
			DelayReturn.nextthink = time + 0.5;
/*
			Item.solid = #SOLID_TRIGGER;
			Item.touch = item_tfgoal_touch;
			Item.origin = Item.oldorigin;
			setmodel(Item, Item.mdl);
			setorigin(Item, Item.origin);
			sound (Item, #CHAN_VOICE, "items/itembk2.wav", 1, #ATTN_NORM);
*/
		}
		else if (Item.goal_activation & #TFGI_DROP)
		{
			if (method == 2)
				tfgoalitem_drop(Item, #TRUE);
			else
				tfgoalitem_drop(Item, #FALSE);
		}
		else
		{
			// Remove the Item
			Item.owner = world;
			dremove(Item);
			TeamFortress_SetSpeed(AP);
			return;
		}
		Item.owner = world;
		TeamFortress_SetSpeed(AP);
		return;
	}

	// Return it to the starting point if the flag is set
	if (method == 1)		// Removed by a goal activation
	{
/*
		bprint(Item.netname);
		bprint(" ");
		bprint(Item.mdl);
		bprint(" ");
		bprint(vtos(Item.origin));
		bprint(" ");
		bprint(vtos(Item.oldorigin));
		bprint("\n");
*/

		if (Item.goal_activation & #TFGI_RETURN_GOAL)
		{
			DelayReturn = spawn();
			DelayReturn.enemy = Item;
			DelayReturn.think = ReturnItem;
			DelayReturn.nextthink = time + 0.5;
/*
			Item.origin = Item.oldorigin;
			setorigin(Item, Item.origin);
			Item.solid = #SOLID_TRIGGER;
			Item.touch = item_tfgoal_touch;
			setmodel(Item, Item.mdl);
			sound (Item, #CHAN_VOICE, "items/itembk2.wav", 1, #ATTN_NORM);

			// Restore a goal if needed
			tfgoalitem_checkgoalreturn(Item);
*/

			Item.owner = world;
			TeamFortress_SetSpeed(AP);
			return;
		}

		// Don't remove it, since it may be given away again later
		Item.solid = #SOLID_NOT;
		Item.owner = world;
		TeamFortress_SetSpeed(AP);
		return;
	}

	RPrint("Invalid method passed into tfgoalitem_RemoveFromPlayer\n");
};

//=========================================================================
// A quick check to make sure the items is not in a wall
void() tfgoalitem_dropthink =
{
	local float pos;

#ifdef #MAP_DEBUG
	RPrint("DropThink for ");
	RPrint(self.netname);
	RPrint("\n");
#endif

	// If the flag is set, remove it after 2 minutes
	self.movetype = #MOVETYPE_TOSS;

	if (self.pausetime != 0)
	{
		pos = pointcontents(self.origin); // find the location of the Item
	
		if (pos == #CONTENT_SLIME)
			self.nextthink = time + (self.pausetime / 4);	
		else if (pos == #CONTENT_LAVA)
			self.nextthink = time + 5;
		else if (pos == #CONTENT_SOLID || pos == #CONTENT_SKY) // oh shit!
			self.nextthink = time + 2;
		else
			self.nextthink = time + self.pausetime; 
		
		self.think = tfgoalitem_remove;
	}

};
//CH does same as above but sets origion when done.
void() tfgoalitem_dropthink2 =
{
	local float pos;

#ifdef #MAP_DEBUG
	RPrint("DropThink for ");
	RPrint(self.netname);
	RPrint("\n");
#endif

	// If the flag is set, remove it after 2 minutes
	self.movetype = #MOVETYPE_TOSS;
/* CH leave this as it is working code. that below this is a test, which seems to work well.
//	if (self.pausetime != 0)
//	{
		pos = pointcontents(self.origin); // find the location of the Item
	
		if (pos == #CONTENT_SLIME)
			self.nextthink = time + (self.pausetime / 4);	
		else if (pos == #CONTENT_LAVA)
			self.nextthink = time + 5;	
		else if (pos == #CONTENT_SOLID || pos == #CONTENT_SKY) // oh shit!
			self.nextthink = time + 2;	
		else
			self.nextthink = time + self.pausetime; 
		
		self.think = tfgoalitem_remove;

		self.velocity = '0 0 0';
		self.oldorigin = self.origin;
//	}
*/

//	if (self.pausetime != 0)
//	{
		pos = pointcontents(self.origin); // find the location of the Item
	
		if (pos == #CONTENT_SLIME)
			setorigin(self, self.oldorigin);	
		else if (pos == #CONTENT_LAVA)
			setorigin(self, self.oldorigin);	
		else if (pos == #CONTENT_SOLID || pos == #CONTENT_SKY) // oh shit!
			setorigin(self, self.oldorigin);	
		else
			setorigin(self, self.origin);	

		self.velocity = '0 0 0';
		self.oldorigin = self.origin;
//	}
};

//=========================================================================
// Drop the item just like a backpack
void(entity Item, float tossed) tfgoalitem_drop =
{
	local vector temp1;
	local vector temp2;
	
	//Item.origin = Item.owner.origin - '0 0 8'; // OfN - why this? it causes them to go trhu walls an fall off of map sometimes..
	Item.origin = Item.owner.origin;
			
	if (tossed)
	{		 
		makevectors(Item.owner.v_angle);
		Item.velocity = Item.owner.velocity + v_forward * 256 + '0 0 340';

		// OfN - Set stuff to avoid picking this item repeatedly
		Item.demon_one = Item.owner;
		Item.has_holo = time + #TFITEM_SAFEDROP_TIME;
	}
	else
	{		 
		Item.velocity_z = 400;
		Item.velocity_x = -50 + (random() * 100);
		Item.velocity_y = -50 + (random() * 100);
	}

	Item.movetype = #MOVETYPE_TOSS;
//CH set solid state
	if (Item.goal_activation & #TFGI_GOAL_IS_SOLID)
		Item.solid = #SOLID_BBOX;
	else
		Item.solid = #SOLID_TRIGGER;
	setorigin(Item, Item.origin);

//CH sets goal bounding box size
	if (Item.goal_min != vector_null)
		temp1 = Item.goal_min;
	else
		temp1 = '-16 -16 -24';
	if (Item.goal_max != vector_null)
		temp2 = Item.goal_max;
	else
		temp2 = '16 16 32';

	setsize (Item, temp1, temp2); //CH sets box size from above

	if (Item.mdl != string_null)
		setmodel(Item, Item.mdl);
	if (Item.goal_activation & #TFGR_DROPITEMS) //checks for dropitems - Grievre fix, was goal_result
	{
		Item.nextthink = time + 1; //CH wait a sec then make it pickupable
		Item.think = tfgoalitem_settouchandthink;
	}
	else
	{
		Item.nextthink = time + 5.0;		// give it five seconds
		Item.think = tfgoalitem_dropthink;	// and then find where it ended up

		Item.goal_state = #TFGS_INACTIVE;
		Item.touch = item_tfgoal_touch;
	}
};

//CH brings the item online after 1 sec
void() tfgoalitem_settouchandthink =
{
	self.nextthink = time + 4.0;		// give it five seconds
	self.think = tfgoalitem_dropthink;	// and then find where it ended up

	self.goal_state = #TFGS_INACTIVE;
	self.touch = item_tfgoal_touch;
};

//=========================================================================
// Remove the item, or Return it if needed
void() tfgoalitem_remove =
{
	local entity te;
	//local vector temp1, temp2;

#ifdef #MAP_DEBUG
	RPrint("RemoveItem for ");
	RPrint(self.netname);
	RPrint("... ");
#endif

	// Has someone picked it up?
	if (self.goal_state == #TFGS_ACTIVE)
		return;

	// Should it be returned?
	if (self.goal_activation & #TFGI_RETURN_REMOVE)
	{
	#ifdef #MAP_DEBUG
		RPrint("Returned.\n");
	#endif

		//CH set solid state
		if (self.goal_activation & #TFGI_GOAL_IS_SOLID)
			self.solid = #SOLID_BBOX;
		else
			self.solid = #SOLID_TRIGGER;

		self.movetype = #MOVETYPE_NONE;
		self.touch = item_tfgoal_touch;

		self.origin = self.oldorigin;
		if (self.mdl != string_null)
			setmodel(self, self.mdl);
		setorigin (self, self.origin);

		sound (self, #CHAN_VOICE, "items/itembk2.wav", 1, #ATTN_NORM);	

		// Restore a goal if needed
		tfgoalitem_checkgoalreturn(self);

		//CH could it check origin again??	nah...
		//CH a better question would be why does it need this to work right???
		self.think = tfgoalitem_checkoriginagain;
		self.nextthink = time + 1;

		// Do we need to do any CenterPrint2ing?
		if (self.noise3 != string_null || self.noise4 != string_null)
		{
			te = find (world, classname, "player");
			while (te)
			{
				if (te.team_no == self.owned_by)
					CenterPrint2(te, "\n\n\n", self.noise3);
				else // (te.team_no != self.owned_by)
					CenterPrint2(te, "\n\n\n", self.noise4);

				te = find(te, classname, "player");
			}
		}

		return;
	}

#ifdef #MAP_DEBUG
	RPrint("Removed.\n");
#endif

	dremove(self);
	
};
//===================
//CH i wonder what this does?
//CH WHY THE HELL DOES IT NEED THIS!!!!!!!
//CH first check
void() tfgoalitem_checkoriginagain =
{
//	RPrint("Check #1 for return goalitem\n");
	if (self.origin != self.oldorigin && self.goal_state != #TFGS_ACTIVE)
	{
		self.origin = self.oldorigin;
		setorigin (self, self.origin);
		self.think = tfgoalitem_checkoriginagain2;
		self.nextthink = time + 1;
	}
};
//===================
//CH second check
void() tfgoalitem_checkoriginagain2 =
{
//	RPrint("Check #2 for return goalitem\n");
	if (self.origin != self.oldorigin && self.goal_state != #TFGS_ACTIVE)
	{
		self.origin = self.oldorigin;
		setorigin (self, self.origin);
		self.think = tfgoalitem_checkoriginagain3;
		self.nextthink = time + 1;
	}
};
//===================
//CH third and final check
void() tfgoalitem_checkoriginagain3 =
{
//	RPrint("Check #3 for return goalitem\n");
	if (self.origin != self.oldorigin && self.goal_state != #TFGS_ACTIVE)
	{
		self.origin = self.oldorigin;
		setorigin (self, self.origin);
	}
};
//=========================================================================
// Activate a goal when this item is removed, if needed
void(entity Item) tfgoalitem_checkgoalreturn =
{
	//local string st;
	local entity te;

	// Do we need to activate a goal somewhere?
	if (Item.impulse != 0)
	{
		// Find the goal
		te = Findgoal(Item.impulse);
		if (te)
		{
			te = Findgoal(Item.impulse);
			if (te)
				AttemptToActivate(te, world, Item);
		}
	}
};

//=========================================================================
// Displays the state of a GoalItem
void(entity Goal, entity Player, entity Item) DisplayItemStatus = 
{
	//local string ac;

	if (Item.goal_state == #TFGS_ACTIVE)
	{
		if (Player.team_no == Item.owned_by)
			sprint(Player, #PRINT_HIGH, Goal.team_str_carried);
		else
			sprint(Player, #PRINT_HIGH, Goal.non_team_str_carried);

		sprint(Player, #PRINT_HIGH, " ");

		if (Player == Item.owner)
			sprint(Player, #PRINT_HIGH, " You");
		else
			sprint(Player, #PRINT_HIGH, Item.owner.netname);

		sprint(Player, #PRINT_HIGH, ".");
	}
	else if (Item.origin != Item.oldorigin)
	{
		if (Player.team_no == Item.owned_by)
			sprint(Player, #PRINT_HIGH, Goal.team_str_moved);
		else
			sprint(Player, #PRINT_HIGH, Goal.non_team_str_moved);
	}
	else
	{
		if (Player.team_no == Item.owned_by)
			sprint(Player, #PRINT_HIGH, Goal.team_str_home);
		else
			sprint(Player, #PRINT_HIGH, Goal.non_team_str_home);
	}
/*CH  prints out the origin and oldorigin via flaginfo
	sprint(Player, #PRINT_HIGH, "\n");
		ac = vtos(Item.origin);
	sprint(Player, #PRINT_HIGH, ac);
	sprint(Player, #PRINT_HIGH, "  ");
		ac = vtos(Item.oldorigin);
	sprint(Player, #PRINT_HIGH, ac);
*/
	sprint(Player, #PRINT_HIGH, "\n");
};

//=========================================================================
// CTF SUPPORT
//=========================================================================
// Spawn Functions for CTF entities.
// Team 1 spawnpoints
void() info_player_team1 =
{
	CTF_Map = #TRUE;
	// Convert to a TeamFortress TeamSpawn point
	self.classname = "info_player_teamspawn";
	// We swap them, so that the colors match ours
	self.team_no = 2;
	// Make this point remove itself after being spawned on
	self.goal_effects = #TFSP_REMOVESELF;
	self.team_str_home = "ts2";
};

// Team 2 spawnpoints
void() info_player_team2 =
{
	CTF_Map = #TRUE;
	// Convert to a TeamFortress TeamSpawn point
	self.classname = "info_player_teamspawn";
	// We swap them, so that the colors match ours
	self.team_no = 1;
	// Make this point remove itself after being spawned on
	self.goal_effects = #TFSP_REMOVESELF;
	self.team_str_home = "ts1";
};

// Team 2 flag
void() item_flag_team2 =
{
	local entity dp;

	CTF_Map = #TRUE;
	precache_model ("progs/w_s_key.mdl");
	precache_sound ("ogre/ogwake.wav");
	precache_sound ("boss2/pop2.wav");
	// Convert the flag to a TeamFortress Goal Item
	self.classname = "item_tfgoal";
	self.netname = "Team 1 Flag";
	self.broadcast = " гот the enemy team's flag!\n";
	self.deathtype = "You've got the enemy flag!\n";
	self.noise = "ogre/ogwake.wav";
	self.mdl = "progs/tf_flag.mdl";
	self.skin = 0;
	setmodel (self, self.mdl);
	self.goal_no = #CTF_FLAG1;
	self.goal_activation = #TFGI_GLOW | #TFGI_DROP | #TFGI_REMOVE | #TFGI_RETURN_REMOVE | #TFGI_RETURN_GOAL | #TFGI_ITEMGLOWS;
	self.goal_effects = 1;
	self.pausetime = 128;
	setsize (self, '-16 -16 -24', '16 16 32');
	self.touch = item_tfgoal_touch;
	self.goal_state = #TFGS_INACTIVE;
	self.solid = #SOLID_TRIGGER;
	setorigin(self, self.origin);
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = TF_PlaceItem;

	// Create the dropoff point Goal
	dp = spawn();
	dp.origin = self.origin;
	dp.classname = "info_tfgoal";
	dp.goal_activation = 1;
	dp.team_no = 1;
	dp.items_allowed = #CTF_FLAG2;
	dp.goal_no = #CTF_DROPOFF1;
	dp.goal_effects = 3;
	dp.broadcast = " цаптуред the enemy flag!\n";
	dp.message = "You цаптуред the enemy flag!\n";
	dp.noise = "boss2/pop2.wav";
	dp.goal_result = #TFGR_ADD_BONUSES;
	dp.activate_goal_no = #CTF_SCORE1;
	dp.axhitme = #CTF_FLAG2;
	dp.count = 10;
	dp.frags = 10;
	dp.solid = #SOLID_TRIGGER;
	dp.goal_state = #TFGS_INACTIVE;
	setsize (dp, '-16 -16 -24', '16 16 32');
	dp.nextthink = time + 0.2;		// goals start after other solids
	dp.think = TF_PlaceGoal;

	// Create the extra scoring goal
	dp = spawn();
	dp.origin = dp.origin;
	dp.classname = "info_tfgoal";
	dp.goal_effects = 1;
	dp.frags = 5;
	dp.goal_activation = 0;
	dp.goal_no = #CTF_SCORE1;
	dp.solid = #SOLID_NOT;
	dp.goal_state = #TFGS_INACTIVE;
	setsize (dp, '-16 -16 -24', '16 16 32');
	dp.nextthink = time + 0.2;		// goals start after other solids
	dp.think = TF_PlaceGoal;
};

// Team 1 flag
void() item_flag_team1 =
{
	local entity dp;

	CTF_Map = #TRUE;
	precache_model ("progs/tf_flag.mdl");
	precache_sound ("ogre/ogwake.wav");
	precache_sound ("boss2/pop2.wav");
	// Convert the flag to a TeamFortress Goal Item
	self.classname = "item_tfgoal";
	self.netname = "Team 2 Flag";
	self.broadcast = " гот the enemy team's flag!\n";
	self.deathtype = "You've got the enemy flag!\n";
	self.noise = "ogre/ogwake.wav";
	self.mdl = "progs/tf_flag.mdl";
	setmodel (self, self.mdl);
	self.skin = 1;
	self.goal_no = #CTF_FLAG2;
	self.goal_activation = #TFGI_GLOW | #TFGI_DROP | #TFGI_REMOVE | #TFGI_RETURN_REMOVE | #TFGI_RETURN_GOAL | #TFGI_ITEMGLOWS;
	self.goal_effects = 1;
	self.pausetime = 128;
	setsize (self, '-16 -16 -24', '16 16 32');
	self.touch = item_tfgoal_touch;
	self.goal_state = #TFGS_INACTIVE;
	self.solid = #SOLID_TRIGGER;
	setorigin(self, self.origin);
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = TF_PlaceItem;

	// Create the dropoff point Goal
	dp = spawn();
	dp.origin = self.origin;
	dp.classname = "info_tfgoal";
	dp.goal_activation = 1;
	dp.team_no = 2;
	dp.items_allowed = #CTF_FLAG1;
	dp.goal_no = #CTF_DROPOFF2;
	dp.goal_effects = 3;
	dp.broadcast = " цаптуред the enemy flag!\n";
	dp.message = "You цаптуред the enemy flag!\n";
	dp.noise = "boss2/pop2.wav";
	dp.goal_result = #TFGR_ADD_BONUSES;
	dp.activate_goal_no = #CTF_SCORE2;
	dp.axhitme = #CTF_FLAG1;
	dp.count = 10;
	dp.frags = 10;
	dp.solid = #SOLID_TRIGGER;
	dp.goal_state = #TFGS_INACTIVE;
	setsize (dp, '-16 -16 -24', '16 16 32');
	dp.nextthink = time + 0.2;		// goals start after other solids
	dp.think = TF_PlaceGoal;

	// Create the extra scoring goal
	dp = spawn();
	dp.origin = dp.origin;
	dp.classname = "info_tfgoal";
	dp.goal_effects = 1;
	dp.frags = 5;
	dp.goal_activation = 0;
	dp.goal_no = #CTF_SCORE2;
	dp.solid = #SOLID_NOT;
	dp.goal_state = #TFGS_INACTIVE;
	setsize (dp, '-16 -16 -24', '16 16 32');
	dp.nextthink = time + 0.2;		// goals start after other solids
	dp.think = TF_PlaceGoal;
};

//=========================================================================
// Checks to make sure either flag hasn't got into bad state, and if
// it has, returns it.
void() CTF_FlagCheck =
{
	local entity te;
	local float flagcount, pos;

	flagcount = 0;
	te = find(world, classname, "item_tfgoal");
	while (te != world)
	{
		if (te.goal_no == #CTF_FLAG1)
		{
			pos = pointcontents(te.origin); // find the location of the Flag
		
			if (pos == #CONTENT_SOLID || pos == #CONTENT_SKY) 
			{
				RPrint("*****BUG*****\nFlag(s) outside world.\nPlease report this.\n");
				te.nextthink = time + 0.2;
				te.think = tfgoalitem_remove;
			}
			
			flagcount = flagcount + 1;
		}
		else if (te.goal_no == #CTF_FLAG2)
		{
			pos = pointcontents(te.origin); // find the location of the Flag
		
			if (pos == #CONTENT_SOLID || pos == #CONTENT_SKY) 
			{
				RPrint("*****BUG*****\nFlag(s) outside world.\nPlease report this.\n");
				te.nextthink = time + 0.2;
				te.think = tfgoalitem_remove;
			}
			
			flagcount = flagcount + 1;
		}
		te = find(te, classname, "item_tfgoal");
	}

	if (flagcount != 2)
		RPrint("*****BUG*****\nFlag(s) missing.\nPlease report this.\n");

	self.nextthink = time + 30;
};
