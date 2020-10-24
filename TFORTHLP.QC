/*======================================================
	TFORTHLP.QC 		CustomTeamFortress v3.1 

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney			5/22/00
	parts (c) Craig Hauser
========================================================
Functions handling all the help displaying for TeamFortress. 
========================================================*/
// Prototypes
// Help Functions
void() TeamFortress_MOTD;
void() TeamFortress_HelpMap;
void() AliasTimer;

//ofN
void() bprintline;
void(entity player, string thesound) PlayClientSound;

//=========================================================================
// HELP FUNCTIONS
//=========================================================================
void() TeamFortress_MOTD =
{
	local string ya;
	local string st;
	local entity atimer;

	// Neo mode
	// for forcing the new player to team 2 (Smiths)
	if (neo && self.team_no == 0) Menu_Team_Input(2);

	// check if player already has aliases
	if (self.motd == 4) {
		stuffcmd(self,"prozac2\n");
		self.show_hostile = 0;
	}

	if (self.motd <= #MOTD_FINISHED - 2)
	{
		if (self.show_hostile < time) {
			//CenterPrint3(self,#MSG_INTRO,#MSG_INTRO2,#MSG_INTRO3);//,CP_MOTD);
			PrintProzacMOTD();
			self.show_hostile = time + #MOTD_REFRESHRATE; //was 1 //.5? 			
		}
		self.menu_count = #MENU_REFRESH_RATE;
		self.current_menu = #MENU_DEFAULT;

		self.motd = self.motd + 1;
		return;
	}

	if (self.motd == #MOTD_FINISHED - 1)
	{
		#ifdef QUAKE_WORLD
			//WK CHECK TO SEE IF WE ARE REDIRECTING PLAYERS
			st = infokey(world, "redir");
			if (st != string_null && st != "off") {
				stuffcmd(self,"connect ");
				stuffcmd(self,st);
				stuffcmd(self,"\n");
			}
		#endif

		// Set Default autozoom
		if (#DEFAULT_AUTOZOOM == #OFF)
			self.tfstate = self.tfstate | #TFSTATE_ZOOMOFF;

		// Set their color to white, so they stand out from teams
		if ((teamplay != 0) && (self.team_no == 0))
		{
			stuffcmd(self, "color ");
			ya = ftos(#WHITE - 1);
			stuffcmd(self, ya);
			stuffcmd(self, "\n");
		}

/*		if (self.got_aliases == #FALSE)
			sprint(self, #PRINT_HIGH, "\n\n\n");*/

//CH prints customTF version.  Edit in messages.qc
		PrintProzacIntro();

		self.current_menu = #MENU_INTRO;
		self.menu_count = #MENU_REFRESH_RATE;
   
		self.motd = #MOTD_FINISHED;

		//WK CustomTF Commands
		TeamFortress_Alias("custom", (#TF_CHANGEPC + #PC_CUSTOM), 0);
		TeamFortress_Alias("upgrade", (#TF_SELL), 0);
		TeamFortress_Alias("skill", (#TF_SKILL), 0);
		TeamFortress_Alias("throwdet", (#IMPULSE_THROWDETPACK), 0);
		TeamFortress_Alias("holo", (#IMPULSE_HOLO), 0);
		TeamFortress_Alias("range", #IMPULSE_TESTRANGE, 0);
		//TeamFortress_Alias("debug", (#IMPULSE_DEBUG), 0); 193
		
		// check if player already has aliases
		if (self.got_aliases == #TRUE)
			return;

		//WK If not, spawn off a timer to slowly send the aliases to
		//prevent overflow
		atimer = spawn ();
		atimer.classname = "timer";
		atimer.netname = "alias"; // OfN - For not removing on removetimers func
		atimer.owner = self;
		atimer.nextthink = time + 0.5;
		atimer.heat = 0;
		atimer.think = AliasTimer;
	}
};

//=========================================================================
// Help displayed when someone types the alias "maphelp"
void() TeamFortress_HelpMap =
{
	// Anti-abuse code
	if (self.option2 > time)
		return;

	self.option2 = time + 1.25;
	
	// OfN - Display settings
	PrintGameSettings(#FALSE);

	sprint(self,#PRINT_HIGH,"Íáð Èåìð:\n");

	local entity te;

	te = find(world, classname, "info_tfdetect");
	if (te)
	{
		if (te.non_team_broadcast != string_null)
		{
			sprint (self, #PRINT_HIGH, te.non_team_broadcast);
			return;
		}
	}
	
	// sprint (self, #PRINT_HIGH, "There is no help for you.\n");
	sprint (self, #PRINT_HIGH, "There is no map-specific help.\n");
};

void() AliasTimer = {
	
	if (!self.owner.is_connected)
	{
		dremove(self);
		return;
	}
	
	local entity oself;
	local float myheat;
	myheat = self.heat = self.heat + 1;
	if (self.heat > 5) {
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}
	oself = self;
	self = self.owner;

	if (myheat == 1) {
		sprint (self, #PRINT_HIGH, "binding aliases...\n");

		// Stuff Aliases

		// Grenades
		TeamFortress_Alias("primeone", #TF_GRENADE_1, 0);
		TeamFortress_Alias("primetwo", #TF_GRENADE_2, 0);
		TeamFortress_Alias("throwgren", #TF_GRENADE_T, 0);
		TeamFortress_Alias("+gren1", #TF_GRENADE_1, 0);
		TeamFortress_Alias("+gren2", #TF_GRENADE_2, 0);
		TeamFortress_Alias("-gren1", #TF_GRENADE_T, 0);
		TeamFortress_Alias("-gren2", #TF_GRENADE_T, 0);

		// Pipebombs
		TeamFortress_Alias("detpipe", #TF_PB_DETONATE, 0);
		TeamFortress_Alias("uncustom", #TF_UNCUSTOM, 0);
		

		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Finished alias pack number 1\n");
		#endif
	}
	else if (myheat == 2) {

		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Starting alias pack number 2\n");
		#endif

		// Reloading
		TeamFortress_Alias("reload", #TF_RELOAD, 0);

		// Actions
		TeamFortress_Alias("special", #TF_SPECIAL_SKILL, 0);
		TeamFortress_Alias("saveme", #TF_MEDIC_HELPME, 0);
		TeamFortress_Alias("discard", #TF_DISCARD, 0);
		TeamFortress_Alias("id", #TF_ID, 0);
		TeamFortress_Alias("inv",#TF_INVENTORY, 0);

		// Class Ability Impulses
		TeamFortress_Alias("disguise", #TF_SPY_SPY, 0);
		TeamFortress_Alias("feign", #TF_SPY_DIE, 0);
		TeamFortress_Alias("sfeign", #TF_SPY_DIE2, 0);
		TeamFortress_Alias("build", #TF_ENGINEER_BUILD, 0);
		TeamFortress_Alias("detdispenser", (#TF_ENGINEER_BUILD), 1); //WK 5-15-08 Fixed detdispenser

		// General
		TeamFortress_Alias("dropammo", #TF_DROP_AMMO, 0);
		TeamFortress_Alias("flaginfo", #FLAG_INFO, 0);
		TeamFortress_Alias("autozoom", #TF_AUTOZOOM, 0);
		//TeamFortress_Alias("showloc", #TF_DISPLAYLOCATION, 0);
		TeamFortress_Alias("changeclass",#TF_CHANGECLASS, 0); //WK 5-15-08 Added changeclass back in
		TeamFortress_Alias("changeteam",#TF_CHANGETEAM, 0); //WK 5-15-08 Added changeteam in
									//- OfN - it was(#TF_CHANGEPC + #PC_CUSTOM)

		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Finished alias pack number 2\n");
		#endif
	}
	else if (myheat == 3) {

		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Starting alias pack number 3\n");
		#endif		  

		//Taunts
		TeamFortress_Alias("taunt1", #TF_TAUNT, 0);
		TeamFortress_Alias("taunt2", #TF_TAUNT2, 0);
		TeamFortress_Alias("taunt3", #TF_TAUNT3, 0);
		TeamFortress_Alias("taunt4", #TF_TAUNT4, 0);
		TeamFortress_Alias("taunt5", #TF_TAUNT5, 0);

		// Class Changing
		TeamFortress_Alias("scout",(#TF_CHANGEPC + #PC_SCOUT), 0);
		TeamFortress_Alias("sniper",(#TF_CHANGEPC + #PC_SNIPER), 0);
		TeamFortress_Alias("soldier",(#TF_CHANGEPC + #PC_SOLDIER), 0);
		TeamFortress_Alias("demoman",(#TF_CHANGEPC + #PC_DEMOMAN), 0);
		TeamFortress_Alias("medic",(#TF_CHANGEPC + #PC_MEDIC), 0);
		TeamFortress_Alias("hwguy",(#TF_CHANGEPC + #PC_HVYWEAP), 0);
		TeamFortress_Alias("pyro",(#TF_CHANGEPC + #PC_PYRO), 0);
		TeamFortress_Alias("spy",(#TF_CHANGEPC + #PC_SPY), 0);
		TeamFortress_Alias("engineer",(#TF_CHANGEPC + #PC_ENGINEER), 0);
		TeamFortress_Alias("randompc",(#TF_CHANGEPC + #PC_RANDOM), 0);

		TeamFortress_Alias("showtf",#TF_SHOWTF, 0);
		TeamFortress_Alias("maphelp", #TF_HELP_MAP, 0); 
		#ifdef COOP_MODE
		if (coop)
			TeamFortress_Alias("dropkey", #TF_DROPKEY, 0);
		#endif

		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Finished alias pack number 3\n");
		#endif
	}
	else if (myheat == 4) {

		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Starting alias pack number 4\n");
		#endif

		// Sample aliases for the Scanner
		TeamFortress_Alias("scan10", #TF_SCAN_10, 0);
		TeamFortress_Alias("scan30", #TF_SCAN_30, 0);
		TeamFortress_Alias("scan100", #TF_SCAN_100, 0);
		TeamFortress_Alias("scanf", #TF_SCAN_FRIENDLY, 0);
		TeamFortress_Alias("scane", #TF_SCAN_ENEMY, 0);

		// Team handlers
		TeamFortress_Alias("showscores",#TF_TEAM_SCORES, 0);
		TeamFortress_Alias("showclasses",#TF_TEAM_CLASSES, 0);
		TeamFortress_Alias("query", #TF_STATUS_QUERY, 0);

		// Sample aliases for the Detpack
		TeamFortress_Alias("det5", #TF_DETPACK_5, 0);
		TeamFortress_Alias("det20", #TF_DETPACK_20, 0);
		TeamFortress_Alias("det50", #TF_DETPACK_50, 0);
		TeamFortress_Alias("+det5", #TF_DETPACK_5, 0);
		TeamFortress_Alias("-det5", #TF_DETPACK_STOP, 0);
		TeamFortress_Alias("+det20", #TF_DETPACK_20, 0);
		TeamFortress_Alias("-det20", #TF_DETPACK_STOP, 0);
		TeamFortress_Alias("+det50", #TF_DETPACK_50, 0);
		TeamFortress_Alias("-det50", #TF_DETPACK_STOP, 0);

		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Finished alias pack number 4\n");
		#endif
	}
	else if (myheat == 5) {
		
		#ifdef ALIASES_TEST
		sprint(self,#PRINT_HIGH,"Starting alias pack number 5\n");
		#endif

		//Get rid of silly MegaTF 10 year olds
		TeamFortress_Alias("lay", #TF_LAY, 0);
		//CH allow dropitems
		TeamFortress_Alias("dropitems", #TF_DROPITEMS, 0);
		
		//TeamFortress_Alias("get", #TF_ADMIN_KICK_CYCLE, 0);
		//TeamFortress_Alias("kick", #TF_ADMIN_KICK_PERSON, 0);
		//TeamFortress_Alias("ban", #TF_ADMIN_BAN_PERSON, 0);
		//TeamFortress_Alias("ceasefire", #TF_ADMIN_CEASEFIRE, 0);
		//TeamFortress_Alias("cmnd", #IMPULSE_STUFFCMD, 0);

		//- OfN
		TeamFortress_Alias("punish", #IMPULSE_PUNISH, 0);
		TeamFortress_Alias("votemap", #IMPULSE_VOTEMAP, 0);
		TeamFortress_Alias("voteyes", #IMPULSE_VOTEYES, 0);
		TeamFortress_Alias("voteno", #IMPULSE_VOTENO, 0);


#ifdef STATUSBAR
		TeamFortress_Alias("sbar_on", #TF_STATUSBAR_ON, 0);
		TeamFortress_Alias("sbar_off", #TF_STATUSBAR_OFF, 0);
		TeamFortress_Alias("sbar_200", #TF_STATUSBAR_RES_START, 0);
		TeamFortress_Alias("sbar_240", #TF_STATUSBAR_RES_START + 1, 0);
		TeamFortress_Alias("sbar_300", #TF_STATUSBAR_RES_START + 2, 0);
		TeamFortress_Alias("sbar_350", #TF_STATUSBAR_RES_START + 3, 0);
		TeamFortress_Alias("sbar_384", #TF_STATUSBAR_RES_START + 4, 0);
		TeamFortress_Alias("sbar_400", #TF_STATUSBAR_RES_START + 5, 0);
		TeamFortress_Alias("sbar_480", #TF_STATUSBAR_RES_START + 6, 0);
		TeamFortress_Alias("sbar_600", #TF_STATUSBAR_RES_START + 7, 0);
		TeamFortress_Alias("sbar_768", #TF_STATUSBAR_RES_START + 8, 0);
#endif
		// Set up the alias check
		TeamFortress_Alias("prozac2", #TF_ALIAS_CHECK, 0);

		// Do the binds
		stuffcmd(self, "bind 9 \"impulse 9\"\n");
		stuffcmd(self, "bind 0 \"impulse 10\"\n");

		//WK INTRO THUNDER
		// OfN - now we have four :P
		
		myheat = rint(random()*3);

		if (myheat == 0)
			stuffcmd(self, "play ambience/thunder1\n");
		else if (myheat == 1)
			stuffcmd(self, "play environ/thunder2\n");
		else if (myheat == 2)
			stuffcmd(self, "play environ/thunder3\n");
		else
			stuffcmd(self, "play environ/thunder4\n");

		sprint(self,#PRINT_HIGH,"The aliases have been set. Welcome!\n");
	}

	self = oself;
	self.nextthink = time + 1;
};
