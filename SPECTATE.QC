// Spectator functions
// Added Aug11'97 by Zoid <zoid@idsoftware.com>
//
// These functions are called from the server if they exist.
// Note that Spectators only have one think since they movement code doesn't
// track them much.  Impulse commands work as usual, but don't call
// the regular ImpulseCommand handler in weapons.qc since Spectators don't
// have any weapons and things can explode.
//
//	 --- Zoid.

// OfteN -> I'm adding some stuff to spectator mode

#define CHARGE_SENSORS_TIME 				4

// MENU Id's
#define SPEC_MENU_NONE						0
#define SPEC_MENU_DEFAULT					1
#define SPEC_MENU_PUNISH					2
#define SPEC_MENU_VOTEMAP					3

//-----------------------//
void() Spec_ID;
void() Player_Punish;
void() Player_VoteMap;

// Resets to MENU_NONE
void() SpecResetMenu;

// Local sounds functions
void(entity player, string thesound) PlayClientSound =
{
	stuffcmd(player, "play ");
	stuffcmd(player,thesound);
	stuffcmd(player,"\n");
};

// used in vote.qc
void(string thesound) BroadcastSound =
{
	local entity te;

	te = find(world, classname, "player");
	while (te != world)
	{
		if (te.is_connected)
			PlayClientSound(te,thesound);
		
		te = find(te, classname, "player");
	}	 

	te = find(world, classname, "spec");
	while (te != world)
	{
		if (te.is_connected)
			PlayClientSound(te,thesound);
		
		te = find(te, classname, "spec");
	}	 
};

/*void () menu_sound =
{
		stuffcmd(self, "play misc/menu3\nbf\n");
};*/  

void () chargesound =
{
	stuffcmd(self, "play weapons/guerset\nbf\n");
};

void ()MachineryScan;
void ()HelpersScan;
void ()ClassScan;
void (float teamnum) GetTeamClassScan;

//


// Menu handlers

void(float inp) Menu_Default_Inp;
void() Menu_Default;	 
void() Menu_Charging;	  


/*
===========
SpectatorConnect

called when a spectator connects to a server
============
*/
void() SpectatorConnect =
{
	bprint (#PRINT_MEDIUM, "Spectator ");
	bprint (#PRINT_MEDIUM, self.netname);
	bprint (#PRINT_MEDIUM, " connected\n");

	stuffcmd(self, "bind 9 \"impulse 9\"\n");
	stuffcmd(self, "bind 0 \"impulse 10\"\n");

	TeamFortress_Alias("punish", #IMPULSE_PUNISH, 0);
	TeamFortress_Alias("votemap", #IMPULSE_VOTEMAP, 0);
	TeamFortress_Alias("voteyes", #IMPULSE_VOTEYES, 0);
	TeamFortress_Alias("voteno", #IMPULSE_VOTENO, 0);

	self.ex_skill_min = 0; // OfN - Used as password attempt count
	self.ex_skill_max = time; // OfN - Used on cmnd.qc
	self.option2 = time; // OfN - Used on cmnd.qc

	self.owned_by = 0; //#VOTED_JUSTJOINED;
	
	self.is_connected = #TRUE;

	if (spec_menu == 1)
	{
		stuffcmd(self, "cl_chasecam 0\n"); // see thru eyes (default state now)
		self.has_camera = 0;

		self.current_menu = #SPEC_MENU_DEFAULT;
		self.menu_count = #MENU_REFRESH_RATE;

		self.has_sensor = time;

		self.tf_items = self.tf_items | #NIT_AUTOSCANNER;
	}

	self.classname = "spec"; // spectators classname is always "spec", for admin code handling by now
	
	self.admin_kick = world;

	num_specs = num_specs + 1;

	if (num_specs == 1 && num_players == 0)
		World_FadeMid(3,0,2);
	
	//self.goalentity = world; // used for impulse 1 below
};

/*
===========
SpectatorDisconnect

called when a spectator disconnects from a server
============
*/
void() SpectatorDisconnect =
{
	bprint (#PRINT_MEDIUM, "Spectator ");
	bprint (#PRINT_MEDIUM, self.netname);
	bprint (#PRINT_MEDIUM, " leaves the server\n");

	if (self.admin_flag)
		AdminLoggedOut(self);

	self.is_connected = #FALSE;
	self.classname = ""; // FIXED: if this isnt here, admin kick-cycle reports "phantom" spectators

	num_specs = num_specs - 1;

	if (num_specs < 0)
		num_specs = 0;

	if (num_specs == 0)
	{
		if (num_players == 0)
		{
			if (ceasefire)
			{
				ceasefire = #FALSE;
				bprint(#PRINT_HIGH,"No clients on server, ceasefire ends automatically..\n");
			}

			World_FadeOut(0,0,0);
		}
	}
};

/*
================
SpectatorImpulseCommand

Called by SpectatorThink if the spectator entered an impulse
================
*/
void() SpectatorImpulseCommand =
{
	/*if (self.impulse == 1) {
		// teleport the spectator to the next spawn point
		// note that if the spectator is tracking, this doesn't do
		// much
		self.goalentity = find(self.goalentity, classname, "info_player_deathmatch");
		if (self.goalentity == world)
			self.goalentity = find(self.goalentity, classname, "info_player_deathmatch");
		if (self.goalentity != world) {
			setorigin(self, self.goalentity.origin);
			self.angles = self.goalentity.angles;
			self.fixangle = #TRUE;			 // turn this way immediately
		}
	}*/
	
	if (self.impulse == #IMPULSE_PUNISH)
	{
		Player_Punish();
	}
	else if (self.impulse == #IMPULSE_VOTEMAP)
	{
		Player_VoteMap();
	}
	else if (self.impulse == #IMPULSE_VOTEYES)
	{
		Player_VoteYes();
	}
	else if (self.impulse == #IMPULSE_VOTENO)
	{
		Player_VoteNo();
	}	 
	else if (self.impulse == #TF_DISPLAYLOCATION)
	{
		display_location();
	}

	if (spec_menu == 0) // Return if spec menus are disabled..
	{
		self.impulse = 0;
		return;
	}

	// Are we inside a menu? then.. use a menu handler
	if (self.current_menu > #SPEC_MENU_NONE && self.impulse <= 10)
	{
		if (self.current_menu == #SPEC_MENU_DEFAULT && self.has_sensor <= time)
			Menu_Default_Inp(self.impulse);
		else if (self.current_menu == #SPEC_MENU_PUNISH)
			Menu_Punish_Input(self.impulse);
		else if (self.current_menu == #SPEC_MENU_VOTEMAP)
			Menu_VoteMap_Input(self.impulse);

	}
	else if (self.current_menu == #SPEC_MENU_NONE && self.impulse == 10)
	{
		self.current_menu = #SPEC_MENU_DEFAULT;
		self.menu_count = #MENU_REFRESH_RATE;
		CuTFMenuSound(#MENUSOUND_BROWSE);
	}

	self.impulse = 0;
};

/*
================
SpectatorThink

Called every frame after physics are run
================
*/
void() SpectatorThink =
{
	// self.origin, etc contains spectator position, so you could
	// do some neat stuff here

	if (self.impulse)
		SpectatorImpulseCommand();

	// TODO: motd

	if (spec_menu == 0)
	{
		return;
	}

	// Time to show the menu? (refresh)
	if (self.current_menu > #SPEC_MENU_NONE)
	{
		// menu refresh loop function
		if (self.menu_count > #MENU_REFRESH_RATE)
		{
			self.menu_count = 0;
		}
		else
		{
			self.menu_count = self.menu_count + 1;
			return; // exits without centerprint the menu
		}
	}
	else
	{
		if (self.tf_items & #NIT_AUTOSCANNER) 
			Spec_ID();
	}


	// Menu Displayers
	if (self.current_menu == #SPEC_MENU_DEFAULT)
	{
		if (self.has_sensor <= time)
			Menu_Default();
		else
			Menu_Charging();
	}
	else if (self.current_menu == #SPEC_MENU_PUNISH)
	{
		Menu_Punish();
	}
	else if (self.current_menu == #SPEC_MENU_VOTEMAP)
	{
		Menu_VoteMap();
	}
};

//=============================================================
// Resets menu to default state

void() SpecResetMenu =
{
	self.menu_count = #MENU_REFRESH_RATE;
	self.current_menu = #SPEC_MENU_NONE;
	CenterPrint(self,"\n");
};

//=====================================================//
// MENUS - Display functions and menu impulse Handlers //
//-----------------------------------------------------//

void() Menu_Default =
{
	local string st2;

	if (self.has_camera != 1)
	{
		if (self.tf_items & #NIT_AUTOSCANNER)
			st2 = ".. Óãáîîåò state (ïî)           \n.. ÃèáóåÃáí state (ïî)          \n\n";
		else
			st2 = ".. Scanner state (off)          \n.. ÃèáóåÃáí state (ïî)          \n\n";
	}
	else
	{
		if (self.tf_items & #NIT_AUTOSCANNER)
			st2 = ".. Óãáîîåò state (ïî)           \n.. ChaseCam state (off)         \n\n";
		else
			st2 = ".. Scanner state (off)          \n.. ChaseCam state (off)         \n\n";
	}		 

	centerprint(self,"€‚ Óðåãôáôïò Íåîõ: €‚Ÿ\n\n.. Machinery Battlefield Scan   \n.. Helpers Battlefield Scan     \n.. Player Classes Scan          \n.. Overall Balance (N/A)        \n.. SentryGun detail report (N/A)\n.. Tesla detail report (N/A)    \n..                              \n",st2,"®® Hide Menu                    \n\n€‚žžžžžžžžžžžžžžžžž€‚Ÿ");
};					  

void(float inp) Menu_Default_Inp =
{
	if (inp == 10)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		SpecResetMenu();
		centerprint(self,"Ôõòîéîç ïææ óåîóïòó...\n\nPress ¢¢ to ôïççìå status");
	}
	else if (inp == 9)
	{
		if (self.has_camera == 1)
		{
			stuffcmd(self, "cl_chasecam 0\n");
		}
		else
		{
			stuffcmd(self, "cl_chasecam 1\n");
		}		 
		
		self.has_camera = !self.has_camera;
		CuTFMenuSound(#MENUSOUND_BROWSE);
		Menu_Default();
	}
	else if (inp == 8)
	{
		if (self.tf_items & #NIT_AUTOSCANNER)
			self.tf_items = self.tf_items - (self.tf_items & #NIT_AUTOSCANNER);
		else
			self.tf_items = self.tf_items | #NIT_AUTOSCANNER;

		CuTFMenuSound(#MENUSOUND_BROWSE);
		Menu_Default();
	}
	else if (inp == 1)
	{
		chargesound();
		MachineryScan();
		self.has_sensor = time + #CHARGE_SENSORS_TIME;
		Menu_Charging();
	}
	else if (inp == 2)
	{
		chargesound();
		HelpersScan();
		self.has_sensor = time + #CHARGE_SENSORS_TIME;
		Menu_Charging();
	}
	else if (inp == 3)
	{
		chargesound();
		ClassScan();
		self.has_sensor = time + #CHARGE_SENSORS_TIME;
		Menu_Charging();
	}
	/*else if (inp == 5)
	{
		chargesound();
		ClassScan();
		self.has_sensor = time + #CHARGE_SENSORS_TIME;
		Menu_Charging();
	}*/
};


//=========================================================================
// ID's the player in your sights, and if you're a medic or engineer,
// reports their health and armor.

void() Spec_ID =
{
	// OfN Returns if any menu is being displayed
	if (self.current_menu != 0) 
		return;

	//WK All the inAuto and spacer stuff I added
	local vector src;
	local string st, cls;
	local string spacer;
	src = self.origin + v_forward*15; // was 10
	src_z = self.absmin_z + self.size_z * 0.7;

	//makevectors(self.angles); // Added - NEEDED?
	traceline (src, src + v_forward*2048, #TL_ANY_SOLID, self.goalentity);

	// Skip player beeing tracked by ourselves
	if (trace_ent == self.goalentity || trace_ent == world)
	{
		//src = self.goalentity.origin + v_forward*15; // was 10
		//src_z = self.absmin_z + self.size_z * 0.7;

		//traceline (src, src + v_forward*2048, #TL_ANY_SOLID, self.goalentity);
		//sprint(self,#PRINT_HIGH,self.goalentity.classname);
		return; 	
	}
		
	spacer = "\n";
	
	if (trace_ent != world && trace_ent.origin != world.origin )
	{
		if (trace_ent.classname == "player" && trace_ent.health > 0)
		{
			self.StatusRefreshTime = time + 1.5;

			if (trace_ent.playerclass == #PC_CUSTOM)
				cls = TeamFortress_GetJobName(trace_ent.job);
			else
				cls = TeamFortress_GetClassName(trace_ent.playerclass);

			st = ftos(trace_ent.health);

			centerprint(self, spacer, trace_ent.netname, "\n\n", cls, "\n\n", st, " health\n");
		}
		else if (trace_ent.classname == "building_dispenser")
		{
			self.StatusRefreshTime = time + 1.5;
			
			centerprint(self, spacer,"Dispenser made by\n\n", trace_ent.real_owner.netname);
		}
		else if (trace_ent.classname == "building_fieldgen")
		{
			self.StatusRefreshTime = time + 1.5;
			
			centerprint(self, spacer,"Field Generator made by\n\n", trace_ent.real_owner.netname);
		}

		else if (trace_ent.classname == "building_sentrygun" || trace_ent.classname == "building_sentrygun_base")
		{
			self.StatusRefreshTime = time + 1.5;

			centerprint(self, spacer,"Sentrygun made by\n\n", trace_ent.real_owner.netname,"\n");
		}	
		else if (trace_ent.classname == "building_tesla")
		{
			self.StatusRefreshTime = time + 1.5;

			centerprint(self, spacer,"Tesla Sentry made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_camera")
		{
			self.StatusRefreshTime = time + 1.5;

			centerprint(self, spacer,"Security Camera made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_sensor")
		{
			self.StatusRefreshTime = time + 1.5;
			
			centerprint(self, spacer,"Motion Sensor made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_teleporter")
		{
			self.StatusRefreshTime = time + 1.5;

			centerprint(self, spacer,"Teleporter Pad made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "monster_demon1")
		{
			//custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);

			centerprint(self, spacer,"Demon summoned by\n\n", trace_ent.real_owner.netname,"\n\n", st, " health");
		}
		else if (trace_ent.classname == "monster_army")
		{
			//custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);

			centerprint(self, spacer,"Soldier in the pay of\n\n", trace_ent.real_owner.netname,"\n\n", st, " health");
		}
		else if (trace_ent.classname == "monster_shambler")
		{
			//custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);

			centerprint(self, spacer,"Shambler under control of\n\n", trace_ent.real_owner.netname,"\n\n", st, " health");
		}
		else if (trace_ent.classname == "monster_wizard") //- OfN
		{
			//custom_demon_name(trace_ent); 
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);

			centerprint(self, spacer,"Scrag under control of\n\n", trace_ent.real_owner.netname,"\n\n", st, " health");
		}
		else if (trace_ent.classname == "monster_fish") //- OfN
		{
			//custom_demon_name(trace_ent); 
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);

			centerprint(self, spacer,"Piranha under control of\n\n", trace_ent.real_owner.netname,"\n\n", st, " health");
		}
		else if (trace_ent.classname == "monster_gremlin") //- OfN
		{
			//custom_demon_name(trace_ent); 
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);

			centerprint(self, spacer,"Gremlin under control of\n\n", trace_ent.real_owner.netname,"\n\n", st, " health");
		}
	}

	// teamplay = oldteamplay;
};

#define DISPENSER_DEF_POWER 	1
#define CAMERA_DEF_POWER		0.25
#define SENSOR_DEF_POWER		0.5 // spy 1.25 thief 1.60
	#define SENSOR_DEF_PW2		  0.75
	#define SENSOR_DEF_PW3		  0.35
#define SENTRY_DEF_POWER		2.5 // base 3, 3.5 4
//#define TESLA_DEF_POWER		  3 // base 3, 4, 5
#define FIELDGEN_DEF_POWER		2 // 2=1 field
#define TELEPORTER_DEF_POWER	1.75 // 2=1 Route


//TODO: x Teleporter routes
//TODO: x Working force fields
//TODO: tesla upgrade ++ power, circuits ++ power
//TODO: sentry upgrade ++ power, circuits ++ power

#define SCRAG_POWER 			1
#define FIEND_POWER 			3
#define SHAMBLER_POWER			6
#define ARMY_POWER				4

#define ARMY_POWER_INC			10

void() Menu_Charging =
{
	local string st2;

	if (self.has_camera == 1)
	{
		if (self.tf_items & #NIT_AUTOSCANNER)
			st2 = "    Óãáîîåò state (ïî)           \n    ÃèáóåÃáí state (ïî)          \n\n";
		else
			st2 = "    Scanner state (off)          \n    ÃèáóåÃáí state (ïî)          \n\n";
	}
	else
	{
		if (self.tf_items & #NIT_AUTOSCANNER)
			st2 = "    Óãáîîåò state (ïî)           \n    ChaseCam state (off)         \n\n";
		else
			st2 = "    Scanner state (off)          \n    ChaseCam state (off)         \n\n";
	}		 
	
	centerprint(self,"€‚ Óðåãôáôïò Íåîõ: €‚Ÿ\n\n    Machinery Battlefield Scan   \n    Helpers Battlefield Scan     \n    Player Classes Scan          \n    Overall Balance              \n    Sentry gun detail report     \n    Tesla detail report          \n                                 \n",st2,"    Hide Menu                    \n\n€‚žžžžžžžžžžžžžžžžž€‚Ÿ\n\nCharging sensors...");
	stuffcmd(self,"bf\n");
//	centerprint(self,"Charging sensors...\n");
};

void (float team_num)GetTeamMachineryScan;

/*void ()sprintline =
{
	sprint(self, #PRINT_HIGH, "\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\n");
};*/
void ()sprintlineb =
{
	sprint(self, #PRINT_HIGH, "\n€‚\n\n");
};
void (float num)sprintlineteam =
{
	if (num == 1)
		sprint(self, #PRINT_HIGH, "\nžžžžžžžžžžŸ Blue Team žžžžžžžžžžžŸ\n\n");
	else if (num == 2)
		sprint(self, #PRINT_HIGH, "\nžžžžžžžžžžžŸ Red Team žžžžžžžžžžžŸ\n\n");
	else if (num == 3)
		sprint(self, #PRINT_HIGH, "\nžžžžžžžžžŸ Yellow Team žžžžžžžžžžŸ\n\n");	
	else if (num == 4)
		sprint(self, #PRINT_HIGH, "\nžžžžžžžžžžŸ Green Team žžžžžžžžžžŸ\n\n");
};

void ()MachineryScan =
{
	sprint(self, #PRINT_HIGH, "\n€‚ Machinery Scan €‚\n");

	sprintlineteam(1);
	GetTeamMachineryScan(1);	
	
	sprintlineteam(2);
	GetTeamMachineryScan(2);

	//TODO: TEam 3 and 4?
	if (number_of_teams > 2)
	{
		sprintlineteam(3);		  
		GetTeamMachineryScan(3);
		
		if (number_of_teams > 3)
		{
			sprintlineteam(4);
			GetTeamMachineryScan(4);
		}
	}
	
	sprintlineb();
};

void (float team_num)GetTeamMachineryScan =
{
	local entity te;
	local float num, defpw;
	local string str;

	defpw = 0;
   

	// Dispensers
	te = find(world,classname,"building_dispenser");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #DISPENSER_DEF_POWER;
		}

		te = find (te,classname,"building_dispenser");
	}

	if (num > 0 )
	{
		sprint(self,#PRINT_HIGH,"Dispensers: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Cameras
	te = find(world,classname,"building_camera");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #CAMERA_DEF_POWER;
		}

		te = find (te,classname,"building_camera");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Cameras: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Motion Sensors
	te = find(world,classname,"building_sensor");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #SENSOR_DEF_POWER;

			if (te.all_active & #IMPROVED_FOUR) // Spy detector
			{
				defpw = defpw + #SENSOR_DEF_PW2;
				if (te.all_active & #IMPROVED_SEVEN) // + thief detector
				{
					defpw = defpw + #SENSOR_DEF_PW3;
				}
			}
		}

		te = find (te,classname,"building_sensor");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"M.Sensors: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Teleporter routes
	te = find(world,classname,"player");

	num = 0;

	while (te)
	{
		if (te.team_no == team_num) // Matches Team number
		{
			if (te.has_teleporter == 2)
			{
				num = num + 1;	
				defpw = defpw + #TELEPORTER_DEF_POWER;
			}
		}

		te = find (te,classname,"player");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Teleporter routes: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Working force fields
	te = find(world,classname,"player");

	num = 0;

	while (te)
	{
		if (te.team_no == team_num) // Matches Team number
		{
			if (te.has_fieldgen == 2)
			{
				num = num + 1;	
				defpw = defpw + #FIELDGEN_DEF_POWER;
			}
		}

		te = find (te,classname,"player");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Working force fields: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Sentry guns
	te = find(world,classname,"building_sentrygun");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #SENTRY_DEF_POWER;

			if (te.weapon == 2) // level 2 sentry gun
				defpw = defpw + 0.5;

			if (te.weapon > 2) // level 3 sentry gun
				defpw = defpw + 1;

			if (te.all_active & #IMPROVED_FOUR) //enhanced circuits
				defpw = defpw + 0.5;
		}

		te = find (te,classname,"building_sentrygun");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Sentry Guns: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Tesla
	te = find(world,classname,"building_tesla");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #SENTRY_DEF_POWER;

			if (te.real_owner.tf_items & #NIT_TESLA_UPGRADE)
				defpw = defpw + 1;
			
			if (te.all_active & #IMPROVED_FOUR) //enhanced circuits
				defpw = defpw + 0.5;
		}

		te = find (te,classname,"building_tesla");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Teslas: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}
	
	// Number of engineers 
	te = find(world,classname,"player");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num && te.playerclass == #PC_ENGINEER) // Matches Team number
		{
			num = num + 1;				
		}

		te = find (te,classname,"player");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Reg.Engineers: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	//Defensive power sprint
	sprint(self,#PRINT_HIGH,"\nÄåæåîóéöå Ðï÷åò: ");
	str=ftos(defpw);
	sprint(self,#PRINT_HIGH,str);
	sprint(self,#PRINT_HIGH,"\n");

};

void (float team_num)GetTeamHelpersScan;

void ()HelpersScan =
{
	sprint(self, #PRINT_HIGH, "\n€‚ Helpers Scan €‚\n");

	sprintlineteam(1);
	GetTeamHelpersScan(1);	  
	
	sprintlineteam(2);
	GetTeamHelpersScan(2);

	//TODO: TEam 3 and 4?
	if (number_of_teams > 2)
	{
		sprintlineteam(3);		  
		GetTeamHelpersScan(3);
		
		if (number_of_teams > 3)
		{
			sprintlineteam(4);
			GetTeamHelpersScan(4);
		}
	}
	
	sprintlineb();
	
};

void (float team_num)GetTeamHelpersScan =
{
	local entity te;
	local float num, defpw;
	local string str;

	defpw = 0;
   

	// Scrags
	te = find(world,classname,"monster_wizard");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #SCRAG_POWER;
		}

		te = find (te,classname,"monster_wizard");
	}

	if (num > 0 )
	{
		sprint(self,#PRINT_HIGH,"Scrags: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Fiends
	te = find(world,classname,"monster_demon1");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #FIEND_POWER;
		}

		te = find (te,classname,"monster_demon1");
	}

	if (num > 0 )
	{
		sprint(self,#PRINT_HIGH,"Fiends: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Shamblers
	te = find(world,classname,"monster_shambler");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #SHAMBLER_POWER;
		}

		te = find (te,classname,"monster_shambler");
	}

	if (num > 0 )
	{
		sprint(self,#PRINT_HIGH,"Shamblers: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Soldiers
	te = find(world,classname,"monster_army");

	num = 0;

	while (te)
	{
		if (te.real_owner.team_no == team_num) // Matches Team number
		{
			num = num + 1;	
			defpw = defpw + #ARMY_POWER;

			defpw = defpw + ((te.has_sensor/17)* #ARMY_POWER_INC);
		}

		te = find (te,classname,"monster_army");
	}

	if (num > 0 )
	{
		sprint(self,#PRINT_HIGH,"Soldiers: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Warlocks 
	te = find(world,classname,"player");

	num = 0;

	while (te)
	{
		if (te.job & #JOB_WARLOCK) // Matches Team number
		{
			num = num + 1;				
		}

		te = find (te,classname,"player");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Warlocks: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}

	// Army members 
	te = find(world,classname,"player");

	num = 0;

	while (te)
	{
		if (te.job & #JOB_ARMY) // Matches job
		{
			num = num + 1;				
		}

		te = find (te,classname,"player");
	}

	if (num >0)
	{
		sprint(self,#PRINT_HIGH,"Army Officers: ");
		str=ftos(num);
		sprint(self,#PRINT_HIGH,str);
		sprint(self,#PRINT_HIGH,"\n");
	}	 
	
	//Defensive power sprint
	sprint(self,#PRINT_HIGH,"\nÈåìðåòó Ðï÷åò: ");
	str=ftos(defpw);
	sprint(self,#PRINT_HIGH,str);
	sprint(self,#PRINT_HIGH,"\n");

};

void () ClassScan =
{
	sprint(self, #PRINT_HIGH, "\n€‚ Classes Scan €‚\n");

	sprintlineteam(1);
	GetTeamClassScan(1);	
	
	sprintlineteam(2);
	GetTeamClassScan(2);

	//TODO: TEam 3 and 4?
	if (number_of_teams > 2)
	{
		sprintlineteam(3);		  
		GetTeamClassScan(3);
		
		if (number_of_teams > 3)
		{
			sprintlineteam(4);
			GetTeamClassScan(4);
		}
	}
	
	sprintlineb();
	
};

//====================================================================================
// same as in TeamFortress_TeamShowMemberClasses on TFortTM.qc, slightly modified

void (float teamnum) GetTeamClassScan =
{
	/*local string st;
	st = infokey(world, "no_showmembers");	*/
	
	local entity e;
	local float found;

	found = #FALSE;

	e = find(world, classname, "player");
	while (e)
	{
		if (e.team_no == teamnum)
		{
			if (e.model != string_null) // check if valid player
			{
				if (!found)
				{
					found = #TRUE;
					//sprint (self, #PRINT_HIGH, "The other members of your team are:\n");
				}

				sprint (self, #PRINT_HIGH, e.netname);
				sprint (self, #PRINT_HIGH, " : ");
				if (e.playerclass == #PC_CUSTOM)
					TeamFortress_PrintClassName(self,e.playerclass, (e.tfstate & #TFSTATE_RANDOMPC));
				else
					TeamFortress_PrintJobName(self,e.job);
					
			}
		}
		e = find(e, classname, "player");
	}

	if (!found)
	{
		//sprint (Player, #PRINT_HIGH, "There are no other players on your team.\n");
		sprint(self,#PRINT_HIGH,"No players on this team.\n");
	}
};

