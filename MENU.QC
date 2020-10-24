/*======================================================
	MENU.QC 		Custom TeamFortress v2.3	

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney					 6/1/07
	(c) Craig Hauser					19/3/00
========================================================
This file handles all menu functions and displays.
OfN - Custom menu is on cutfmenu.qc and other menus
are on their respective files now.
======================================================*/

void(vector where) spawnFOG;
void(entity pl, string s1, string s2, string s3, string s4) CenterPrint4;
void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6, string s7) CenterPrint7;
void() bprintVoteIssue;
void(string thesound) BroadcastSound;
void() ResetVoteEnt;
float(float checkIP, float noIdlers) GetNoPlayers;
float() NormalTF; //WK Returns true on a normal 2 team map
 
#define MENU_DEFAULT				1
#define MENU_TEAM					2
#define MENU_CLASS				3
#define MENU_DROP					4
#define MENU_INTRO				5
#define MENU_CLASSHELP				6
#define MENU_CLASSHELP2 			7
#define MENU_REPEATHELP 			8
#define MENU_PICKBINDS				9
#define MENU_SHOWBINDS1 			10
#define MENU_SHOWBINDS2 			11
#define MENU_SPY					12
#define MENU_SPY_SKIN				13
#define MENU_SPY_COLOR				14

#define MENU_ENGINEER				15

#define MENU_ENGINEER_FIX_DISPENSER 	16
#define MENU_ENGINEER_FIX_SENTRYGUN 	17
#define MENU_ENGINEER_FIX_TESLA 		18
#define MENU_ENGINEER_FIX_TESLA2		19
#define MENU_DISPENSER				20
#define MENU_ENGINEER_FIX_CAMERA		21
#define MENU_ENGINEER_FIX_TELEPORTER	22
#define MENU_ENGINEER_FIX_SENSOR		23
#define MENU_ENGINEER_FIX_FIELDGEN		24

#define MENU_DEMON				26	// SB menu for demon summon, I use 26 in the hope that nobody
								// has made anything conflicting with this for future vers.
								// Not that I expect anyone else to ever do anything...
#define MENU_ARMY					27
#define MENU_F_HACK 				28
#define MENU_E_HACK 				29

#define MENU_CRUSADER				30

#define MENU_GUERILLA				31

//- Voting System -//
#define MENU_PUNISH 				32
#define MENU_VOTEMAP				33

//WK 1/25/8 Add menu for new building frag upgrade options
#define MENU_BUILDING_FRAG_UPGRADE		34

//WK - Menus for making a custom class
//WK 6/1/7 Redid the menus
#define MENU_SNIPER_WEAPON			36
#define MENU_ROCKET_WEAPON			37
#define MENU_SHOTGUN_WEAPON 			38
#define MENU_OTHER_WEAPON			39
#define MENU_TOOLS				40
#define MENU_LEGS					41
#define MENU_HEALTH 				42
#define MENU_ARMOR				43
#define MENU_SPECIAL				44
#define MENU_SPECIAL2				45
#define MENU_GREN1				46
#define MENU_GREN2				47
#define MENU_ENGINEERING			48
#define MENU_PROFESSION 			49
#define MENU_PROFESSION2			50
#define MENU_PROFICIENCY			51
#define MENU_OPTION 				52
#define MENU_KNOCKTATION			53

//If we extend this, search for "MENU_KNOCKTATION" below
//WK ------------------------------------

#define MENU_REFRESH_RATE			25

void(entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage;
void() W_SetCurrentAmmo;
void(entity p) bound_other_ammo;
float(float tno) TeamFortress_TeamSet;
void(entity p) TeamFortress_SetSkin;
float(float tno) TeamFortress_TeamGetColor;
void() TeamFortress_ChangeClass;
void(float type) TeamFortress_DropAmmo;
float() TeamFortress_TeamPutPlayerInTeam;
float(float tno) TeamFortress_TeamIsCivilian;
void(float class) TeamFortress_SpyChangeSkin;
void(float teamno) TeamFortress_SpyChangeColor;
void(float building, float devicenum) TeamFortress_Build;
void(float type) TeamFortress_SpyFeignDeath;
void(entity spy) Spy_RemoveDisguise;
void() lvl1_sentry_stand;
void() lvl2_sentry_stand;
void() lvl3_sentry_stand;
float (float tno) TeamFortress_TeamGetNoPlayers;
float(float myteam) HasFlag; 

/* WK void(float menu_no) DisplayMenu; */
// Assorted menus
void() Menu_Team;
void() Menu_Class;
void() Menu_Drop;
void() Menu_Intro;
void() PlayerObserverMode;
// Classhelp
void() Menu_ClassHelp;
void() Menu_ClassHelp2;
void() Menu_StuffClassHelp;
void(float inp) Menu_ClassHelp_Input;
// Bindings
void() Menu_DoBindings;
void() Menu_ShowBindings1;
void() Menu_ShowBindings2;
void() Menu_RepeatHelp;
// Spy
void() Menu_Spy;
void() Menu_Spy_Skin;
void() Menu_Spy_Color;
void(float inp) Menu_Spy_Input;
void(float inp) Menu_Spy_Skin_Input;
void(float inp) Menu_Spy_Color_Input;
// Engineer
void() Menu_Engineer;
void() Menu_EngineerFix_Dispenser;
void() Menu_EngineerFix_SentryGun;
void() Menu_EngineerFix_Tesla;
void() Menu_EngineerFix_Tesla2;
void() Menu_EngineerFix_Camera;
void() Menu_EngineerFix_Sensor;
void() Menu_EngineerFix_Teleporter;
void() Menu_EngineerFix_FieldGen;
void(float inp) Menu_Engineer_Input;
void(float inp) Menu_EngineerFix_Dispenser_Input;
void(float inp) Menu_EngineerFix_SentryGun_Input;
void(float inp) Menu_EngineerFix_Tesla_Input;
void(float inp) Menu_EngineerFix_Tesla_Input2;
void(float inp) Menu_EngineerFix_Camera_Input;
void(float inp) Menu_EngineerFix_Sensor_Input;
void(float inp) Menu_EngineerFix_Teleporter_Input;
void(float inp) Menu_EngineerFix_FieldGen_Input;

// Demons
void() Menu_Demon;
void(float inp) Menu_Demon_Input;
void() kill_my_demons;

// Buildings
void() Menu_Dispenser;
void(float inp) Menu_Dispenser_Input;

float(entity obj, entity builder) CheckArea;

// WK - Custom Class
void() DropFromCustomClassGen; //Extern
void() PrintMoney;
void(float cost,float type) BuyWeapon;
void(float cost,float type) BuyCuTF;
void(float cost,float type) BuyItem;
void(float cost, float type) BuyJob;
/*void(float cost,float type) BuyGren1;
void(float cost,float type) BuyGren2;*/
void(float in) PrintRefund;
void(float in) PrintNotEnoughMoney;
//WK 6/1/7 Total Revamp
void() Menu_SniperWeapon;
void(float inp) Menu_SniperWeapon_Input;
void() Menu_RocketWeapon;
void(float inp) Menu_RocketWeapon_Input;
void() Menu_ShotgunWeapon;
void(float inp) Menu_ShotgunWeapon_Input;
void() Menu_OtherWeapon;
void(float inp) Menu_OtherWeapon_Input;
void() Menu_Tools;
void(float inp) Menu_Tools_Input;
void() Menu_Legs;
void(float inp) Menu_Legs_Input;
void() Menu_Health;
void(float inp) Menu_Health_Input;
void() Menu_Armor;
void(float inp) Menu_Armor_Input;
void() Menu_Special;
void(float inp) Menu_Special_Input;
void() Menu_Special2;
void(float inp) Menu_Special2_Input;
void() Menu_Gren1;
void(float inp) Menu_Gren1_Input;
void() Menu_Gren2;
void(float inp) Menu_Gren2_Input;
void() Menu_Engineering;
void(float inp) Menu_Engineering_Input;
void() Menu_Profession;
void(float inp) Menu_Profession_Input;
void() Menu_Profession2;
void(float inp) Menu_Profession2_Input;
void() Menu_Proficiency;
void(float inp) Menu_Proficiency_Input;
void() Menu_Option;
void(float inp) Menu_Option_Input;
void() Menu_Knocktation;
void(float inp) Menu_Knocktation_Input;

//OFN
void() Menu_Crusader;
void(float inp) Menu_Crusader_Input;
void() Menu_Punish;
void(float inp) Menu_Punish_Input;
void() Menu_VoteMap;
void(float inp) Menu_VoteMap_Input;
void() Menu_Guerilla;
void(float inp) Menu_Guerilla_Input;
void() Menu_BuildingFragUpgrade;
void(float inp) Menu_BuildingFragUpgrade_Input;

//WK Needed for rotate
float(float v) anglemod;
//WK Needed to det sentries et al.
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;
//WK Needed to make a bastard
void(entity bastard,float threshold) createBastard;
//CY Tinker
void() DoTinker;
//WW Needed for the Dismantling
void(entity targ, entity attacker) ClientObituary;

// WK --------------

//- OfN - Warlock menu (now in warlock.qc) --//
void(float inp) Menu_Demon_Input;		 //
void() Menu_Demon;				 //
//-------------------------------------------//
//- OfN - Army menu (now in army.qc) --------//
void(float inp) Menu_Army_Input;		 //
void() Menu_Army;					 //
//-------------------------------------------//
//- OfN - Hack menu (now in haxxx.qc) -------//
void(float inp) Menu_EnemyHax_Inp;		 //
void() Menu_Enemy_Hax;				 //
void(float inp) Menu_FriendHax_Inp; 	 //
void() Menu_Friend_Hax; 			 //
//-------------------------------------------//
void (float cost1, float cost2) BuyExtra;
void() UpdateWeaponItems;
float() CheckEnemyDismantle;
void() SBBuildSensor;
void() Tesla_Lose_Glow;
entity(entity OldTesla) TeslaClone;
float(entity theplayer, float grenslot) GetMaxGrens;
void (float cost, float type) BuyGren;
string(float typ) GetGrenadeText;
//void(entity thing) RemoveMyTimers;
void(entity player) GuerillaInit;
float(float inp) CanBuyItem;
float(float inp) ItemIsFree;
void() MenuResetCount;

#ifdef FIELD_FORCEMODE
void(float value) SetFieldForcedStatus; // player function (self = player) cuts disabled time also
float() GetFieldForcedStatus; // player
#endif

//------------------------------------------//
#ifdef MENU_SOUNDS
float menu_sounds;
#endif

void() MenuPrecache =
{
	#ifdef MENU_SOUNDS
	precache_sound("cutfmenu/menu1.wav");
	precache_sound("cutfmenu/menu2.wav");
	precache_sound("cutfmenu/menu3.wav");
	precache_sound("cutfmenu/menu4.wav");
	#endif
};

#define MENUSOUND_BROWSE 1
#define MENUSOUND_BUY	 2
#define MENUSOUND_SELL	 3
#define MENUSOUND_WRONG  4

void(float sample) CuTFMenuSound =
{
	#ifdef MENU_SOUNDS
	if (!menu_sounds)
		return;

	if (sample == #MENUSOUND_BROWSE)
		stuffcmd(self,"playvol cutfmenu/menu1.wav 0.30\n"); // 0.4
	else if (sample == #MENUSOUND_BUY)
		stuffcmd(self,"playvol cutfmenu/menu2.wav 0.30\n"); // 0.4
	else if (sample == #MENUSOUND_SELL)
		stuffcmd(self,"playvol cutfmenu/menu3.wav 0.5\n"); // 0.4
	else if (sample == #MENUSOUND_WRONG)
		stuffcmd(self,"playvol cutfmenu/menu4.wav 0.7\n"); // 0.6
	#endif
};


void() ResetMenu =
{
	if (self.StatusBarSize == 0)
		CenterPrint(self, "\n");
	else
		self.StatusRefreshTime = time + 0.1;
	self.menu_count = #MENU_REFRESH_RATE;
	self.current_menu = #MENU_DEFAULT;
};

void() Player_Menu =
{
	// loop function
	if (self.menu_count > #MENU_REFRESH_RATE)
	{
		self.menu_count = 0;
	}
	else
	{
		self.menu_count = self.menu_count + 1;
		return;
	}

	// determine which menu to display
	// WK - Check to see if the custom class menu is overriding us
	if ((self.done_custom & #CUSTOM_BUILDING) && !(self.done_custom & #CUSTOM_OVERRIDE) && self.playerclass == #PC_CUSTOM) {
		self.current_menu = #MENU_SNIPER_WEAPON;
		self.done_custom = self.done_custom | #CUSTOM_OVERRIDE;
	}

	//Don't flash status bars
	if (self.current_menu >= #MENU_SNIPER_WEAPON && self.current_menu <= #MENU_KNOCKTATION)
		self.StatusRefreshTime = time + 1.5;

	if (self.current_menu == #MENU_INTRO)
	{
		Menu_Intro();
		self.current_menu = #MENU_DEFAULT;
	}
	else if (self.current_menu == #MENU_CLASSHELP)
	{
		Menu_ClassHelp();
		if (self.menu_displaytime > 8)
		{
			Menu_StuffClassHelp();
			self.current_menu = #MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == #MENU_CLASSHELP2)
	{
		Menu_ClassHelp2();
		if (self.menu_displaytime > 5)
		{
			Menu_StuffClassHelp();
			self.current_menu = #MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == #MENU_SHOWBINDS1)
	{
		Menu_ShowBindings1();
		if (self.menu_displaytime > 8)
		{
			self.current_menu = #MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == #MENU_SHOWBINDS2)
	{
		Menu_ShowBindings2();
		if (self.menu_displaytime > 8)
		{
			self.current_menu = #MENU_DEFAULT;
		}
		else
			self.menu_displaytime = self.menu_displaytime + 1;
	}
	else if (self.current_menu == #MENU_DROP)
	{	
		Menu_Drop();
	}
	else if (self.current_menu == #MENU_CLASS) //WK 5-15-08 Added in changeclass
	{	
		Menu_Class();
	}
	else if (self.current_menu == #MENU_TEAM) //WK 5-15-08 Added in changeteam
	{	
		Menu_Team();
	}
	else if (self.current_menu == #MENU_SPY)
	{
		Menu_Spy();
	}
	else if (self.current_menu == #MENU_SPY_SKIN)
	{
		Menu_Spy_Skin();
	}
	else if (self.current_menu == #MENU_SPY_COLOR)
	{
		Menu_Spy_Color();
	}
	else if (self.current_menu == #MENU_ENGINEER)
	{
		Menu_Engineer();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_DISPENSER)
	{
		Menu_EngineerFix_Dispenser();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_SENTRYGUN)
	{
		Menu_EngineerFix_SentryGun();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_TESLA)
	{
		Menu_EngineerFix_Tesla();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_TESLA2)
	{
		Menu_EngineerFix_Tesla2();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_CAMERA)
	{
		Menu_EngineerFix_Camera();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_SENSOR)
	{
		Menu_EngineerFix_Sensor();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_TELEPORTER)
	{
		Menu_EngineerFix_Teleporter();
	}
	else if (self.current_menu == #MENU_ENGINEER_FIX_FIELDGEN)
	{
		Menu_EngineerFix_FieldGen();
	}
	else if (self.current_menu == #MENU_DISPENSER)
	{
		Menu_Dispenser();
	}
	else if (self.current_menu == #MENU_REPEATHELP)
	{	
		Menu_RepeatHelp();
		self.current_menu = #MENU_DEFAULT;
	}
	else if (self.current_menu == #MENU_PICKBINDS)
	{	
		Menu_DoBindings();
	}
	else if (self.current_menu == #MENU_DEMON)
	{
		Menu_Demon();
	}
	else if (self.current_menu == #MENU_ARMY) //- OfN
	{
		Menu_Army();
	}
	else if (self.current_menu == #MENU_E_HACK) //- OfN
	{
		Menu_Enemy_Hax();
	}
	else if (self.current_menu == #MENU_F_HACK) //- OfN
	{
		Menu_Friend_Hax();
	}
	else if (self.current_menu == #MENU_CRUSADER)
	{
		Menu_Crusader();
	}
	else if (self.current_menu == #MENU_GUERILLA)
	{
		Menu_Guerilla();
	}
	//- OfN - Democracy
	else if (self.current_menu == #MENU_PUNISH)
	{
		Menu_Punish();
	}
	else if (self.current_menu == #MENU_VOTEMAP)
	{
		Menu_VoteMap();
	}
	else if (self.current_menu == #MENU_BUILDING_FRAG_UPGRADE)
	{
		Menu_BuildingFragUpgrade();
	}
	//WK ------------------
	else if (self.current_menu == #MENU_SNIPER_WEAPON)
	{
		Menu_SniperWeapon();
	}
	else if (self.current_menu == #MENU_ROCKET_WEAPON)
	{
		Menu_RocketWeapon();
	}
	else if (self.current_menu == #MENU_SHOTGUN_WEAPON)
	{
		Menu_ShotgunWeapon();
	}
	else if (self.current_menu == #MENU_OTHER_WEAPON)
	{
		Menu_OtherWeapon();
	}
	else if (self.current_menu == #MENU_TOOLS)
	{
		Menu_Tools();
	}
	else if (self.current_menu == #MENU_LEGS)
	{
		Menu_Legs();
	}
	else if (self.current_menu == #MENU_HEALTH)
	{
		Menu_Health();
	}
	else if (self.current_menu == #MENU_ARMOR)
	{
			Menu_Armor();
	}
	else if (self.current_menu == #MENU_SPECIAL)
	{
		Menu_Special();
	}
	else if (self.current_menu == #MENU_SPECIAL2)
	{
		Menu_Special2();
	}
	else if (self.current_menu == #MENU_GREN1)
	{
		Menu_Gren1();
	}
	else if (self.current_menu == #MENU_GREN2)
	{
		Menu_Gren2();
	}
	else if (self.current_menu == #MENU_ENGINEERING)
	{
		Menu_Engineering();
	}
	else if (self.current_menu == #MENU_PROFESSION)
	{
		Menu_Profession();
	}
	else if (self.current_menu == #MENU_PROFESSION2)
	{
		Menu_Profession2();
	}
	else if (self.current_menu == #MENU_PROFICIENCY)
	{
		Menu_Proficiency();
	}
	else if (self.current_menu == #MENU_OPTION)
	{
		Menu_Option();
	}	 
	else if (self.current_menu == #MENU_KNOCKTATION)
	{
		Menu_Knocktation();
	}	 
	
	//WK ----------------
	else if (self.team_no == 0 && teamplay && (self.lives != 0))
	{
		if (self.motd >= #MOTD_FINISHED) {
			self.current_menu = #MENU_TEAM;
			Menu_Team();
		}
	}
//WK Default to custom class gen - OfN - nope!
	else if (self.playerclass == #PC_UNDEFINED && (self.lives != 0))
	{
		//- OfN - stock_mode applies
		if (stock_mode < 2) {
			self.current_menu = #MENU_CLASS;//-was commented
			Menu_Class();//-was commented
		}
		else
		{
			self.impulse = #PC_CUSTOM + #TF_CHANGEPC; //-wasnt commented
			TeamFortress_ChangeClass();//-wasnt commented
		}
	}
	else
		self.current_menu = 0;
};

void(float inp) Menu_Team_Input;

void() Menu_Team =
{
	local float should_autoteam,team1count,team2count, teamSet, changing_team;

	if(self.team_no > 0) changing_team = 1;
	else changing_team = 0;

	should_autoteam = 0;
	if (!NormalTF()) {	
		should_autoteam = 0; //Don't autoteam on nonstandard maps
	} else {
		team1count = TeamFortress_TeamGetNoPlayers(1);
		team2count = TeamFortress_TeamGetNoPlayers(2);

		//If we're currently playing, only autoteam if we're on a team with +2 or more players than the smaller team
		if (self.team_no) {
			if (self.team_no == 1 && team1count > team2count + 1) should_autoteam = 1;
			else if (self.team_no == 2 && team2count > team1count + 1) should_autoteam = 1;
		}
		//If we're a new player, then autoteam if the teams are uneven at all
		else if (team1count != team2count) should_autoteam = 1;
	}

	if (time < 300) should_autoteam = 0; //Don't force autoteam in first 5 minutes

	//Timeout autoteam (people idle 30s at login)
	if ((toggleflags & #TFLAG_AUTOTEAM))
		should_autoteam = 1;

	//Autoteaming can be disabled entirely
	//WK 1-19-09 Especially in Neo mode
	if (infokey(world, "at") == "off" || infokey(world, "at") == "0" || neo)
		should_autoteam = 0;

	// Autoassign player a team
	if (should_autoteam && teamplay)
	{
		teamSet = TeamFortress_TeamPutPlayerInTeam();
		if (changing_team && teamSet) {
			ClientKill();
		}
		//WK 1-19-09 Fix the double-autoteam bug by advancing to the correct menu - it was autoteaming and leaving it on MENU_TEAM
		if (!changing_team && teamSet) {
			self.current_menu = #MENU_CLASS;
			self.impulse = 0;
		}
		if (teamSet)
			return;
	}

	// PZ - Attackers Go Red: begin code
	local float x;

	// The Detection entity may have specified a Team Menu String
	if (team_menu_string != string_null)
	{
		if (agr)
		{
			x = floor(time);
			if (x - (2 * floor(x / 2)) == 0) // x mod 2 == 0
				CenterPrint2(self, team_menu_string, "\n\n Áôôáãëåòó Çï Òåä \n");
			else
				CenterPrint2(self, team_menu_string, "\n\n Attackers Go Red \n");
		}
		else
			CenterPrint(self, team_menu_string);
		return;
	}

	if (CTF_Map == #TRUE)
	{
		if (agr)
			CenterPrint2(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Blue Team           \n.. Red Team            \n\n\n\n.. Bind my keys for me!\n\nFor full details on this patch:\nhttp://www.telefragged.com/teamfortress/\n", "\n\n Áôôáãëåòó Çï Òåä \n");
		else
			CenterPrint(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Blue Team           \n.. Red Team            \n\n\n\n.. Bind my keys for me!\n\nFor full details on this patch:\nhttp://www.telefragged.com/teamfortress/\n");
	}
	else if (number_of_teams == 1)
	{
		if (agr)
			CenterPrint2(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n", "\n\n Áôôáãëåòó Çï Òåä \n");
		else
			CenterPrint(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n");
	}
	else if (number_of_teams == 2)
	{
		if (agr)
			CenterPrint2(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n.. Team Two  \n              \n              \n\n.. Áõôï Ôåáí \n", "\n\n Áôôáãëåòó Çï Òåä \n");
		else
			CenterPrint(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n.. Team Two  \n              \n              \n\n.. Áõôï Ôåáí \n");
	}
	else if (number_of_teams == 3)
	{
		if (agr)
			CenterPrint2(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n.. Team Two  \n.. Team Three\n              \n\n.. Áõôï Ôåáí \n", "\n\n Áôôáãëåòó Çï Òåä \n");
		else
			CenterPrint(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n.. Team Two  \n.. Team Three\n              \n\n.. Áõôï Ôåáí \n");
	}
	else // if (number_of_teams == 4)
	{
		if (agr)
			CenterPrint2(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n.. Team Two  \n.. Team Three\n.. Team Four \n\n.. Áõôï Ôåáí \n", "\n\n Áôôáãëåòó Çï Òåä \n");
		else
			CenterPrint(self, "žŸ Ãèïïóå Ùïõò Ôåáí žŸ\n\n.. Team One  \n.. Team Two  \n.. Team Three\n.. Team Four \n\n.. Áõôï Ôåáí \n");
	}
	// PZ - AGR end code
};

void(float inp) Menu_Team_Input =
{
	local float teamSet; // bool
	local float changing_team; //WK 5-15-08 We allow people to reteam inside the game now, this holds if they are, indeed
	local float team1count, team2count, fullteam;

	//WK 5-15-08 Stop people from accidentally joining their own teams (would suicide them needlessly)
	if (inp && inp == self.team_no) {
		sprint(self,#PRINT_HIGH,"You're already on that team!\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		ResetMenu();		
		self.impulse = 0;
		return;
	}

	//WK 5-15-08 On a normal TF map, after 5 minutes we don't allow people to pick a team that will unbalance the sides
	if (NormalTF() && time > 300) {
		fullteam = 0;
		team1count = TeamFortress_TeamGetNoPlayers(1);
		if (self.team_no == 1) team1count = team1count - 1; //Don't count ourselves
		team2count = TeamFortress_TeamGetNoPlayers(2);
		if (self.team_no == 2) team2count = team2count - 1; //Don't count ourselves

		if (inp == 1 && team1count > team2count) fullteam = 1;
		if (inp == 2 && team2count > team1count) fullteam = 1;
		if (fullteam) {
			inp = 5; //Autoteam them instead
			sprint(self,#PRINT_HIGH,"That team is full! Autoteaming instead.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
			ResetMenu();		
			self.impulse = 0;
			return;
		}
	}	

	//WK Remove starting observer gravity. It might come right back.
	self.gravity = 1;

	if(self.team_no > 0) changing_team = 1;
	else changing_team = 0;

	//WK 1-19-09 Disable autoteam in Neo mode
	if (neo && inp == 5) inp = 0;

	if (inp == 5) { // auto team
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH," picks a random team!\n");
		teamSet = TeamFortress_TeamPutPlayerInTeam();
	}
	else if (inp <= number_of_teams && inp > 0)
		teamSet = TeamFortress_TeamSet(inp);		
	else if (number_of_teams == 0 && inp <= #TM_MAX_NO)
		teamSet = TeamFortress_TeamSet(inp);
	else //- OfN
	{
		//ResetMenu();		
		self.impulse = 0;
		return;
	}

	//WK 5-15-08 Suicide if they switch teams inside the game. Prevents abuses.
	if (changing_team && teamSet) {
		ClientKill();
	}

	/*else if (inp == 7)
		self.current_menu = #MENU_PICKBINDS;
	else if (inp == 8)
		PlayerObserverMode();*/

	//WK 1-19-09 We don't need this any more
	//if (custom_mode!=2) sprint(self, #PRINT_MEDIUM, "Press ¢¢ for a custom player class\n");

	ResetMenu();		
	self.impulse = 0;
};

void() Menu_Class =
{
	local entity AD;

	AD = find(world, classname, "info_tfdetect");

	if (AD)
	{
		if (self.team_no == 1)
		{
			if (AD.noise1 != string_null)
			{
				CenterPrint(self, AD.noise1);
				return;
			}
		}
		else if (self.team_no == 2)
		{
			if (AD.noise2 != string_null)
			{
				CenterPrint(self, AD.noise2);
				return;
			}
		}
		else if (self.team_no == 3)
		{
			if (AD.noise3 != string_null)
			{
				CenterPrint(self, AD.noise3);
				return;
			}
		}
		else if (self.team_no == 4)
		{
			if (AD.noise4 != string_null)
			{
				CenterPrint(self, AD.noise4);
				return;
			}
		}
	}

	local float x;
	if (custom_mode!=2)
	{
		if (TeamFortress_TeamIsCivilian(self.team_no))
			CenterPrint(self, "Your team can only be Civilians.\n");
		else if (spy_off == #TRUE)
			CenterPrint(self, "žŸ Ãèïïóå ùïõò ãìáóó žŸ\n\n.. Scout   \n.. Sniper  \n.. Soldier \n.. Demoman \n.. Medic   \n.. Hwguy   \n.. Pyro    \n.. Engineer\n\n.. Ãõóôïí! \n");
		else
		{
			// begin Neo mod
			if (neo)
			{
				x = floor(time);
				if (x - (2 * floor(x / 2)) == 0) // x mod 2 == 0
					CenterPrint(self, "žŸ Ãèïïóå ùïõò ãìáóó žŸ\n\n.. Scout   \n.. Sniper  \n.. Soldier \n.. Demoman \n.. Medic   \n.. Hwguy   \n.. Pyro    \n.. Spy     \n.. Engineer\n\n.. Ãõóôïí! \n\n\n\n Neo Mode - ÂÅÔÁ \n");
				else
					CenterPrint(self, "žŸ Ãèïïóå ùïõò ãìáóó žŸ\n\n.. Scout   \n.. Sniper  \n.. Soldier \n.. Demoman \n.. Medic   \n.. Hwguy   \n.. Pyro    \n.. Spy     \n.. Engineer\n\n.. Ãõóôïí! \n\n\n\n Neo Mode - BETA \n");
			}
			else
				CenterPrint(self, "žŸ Ãèïïóå ùïõò ãìáóó žŸ\n\n.. Scout   \n.. Sniper  \n.. Soldier \n.. Demoman \n.. Medic   \n.. Hwguy   \n.. Pyro    \n.. Spy     \n.. Engineer\n\n.. Ãõóôïí! \n");
			// end Neo mod
		}
	}
	else
	{
		if (TeamFortress_TeamIsCivilian(self.team_no))
			CenterPrint(self, "Your team can only be Civilians.\n");
		else if (spy_off == #TRUE)
			CenterPrint(self, "žŸ Ãèïïóå ùïõò ãìáóó žŸ\n\n.. Scout   \n.. Sniper  \n.. Soldier \n.. Demoman \n.. Medic   \n.. Hwguy   \n.. Pyro    \n.. Engineer\n");
		else  
			CenterPrint(self, "žŸ Ãèïïóå ùïõò ãìáóó žŸ\n\n.. Scout   \n.. Sniper  \n.. Soldier \n.. Demoman \n.. Medic   \n.. Hwguy   \n.. Pyro    \n.. Spy     \n.. Engineer\n");
	}
};

void(float inp) Menu_Class_Input =
{
	if (inp > 10 || inp < 1)
		return;

	if (inp==10 && custom_mode==2)
	{
	  self.impulse = 0;
	  return;
	}

	self.impulse = inp + #TF_CHANGEPC;
	if (inp == 10) //We picked custom, chnage it from random
		self.impulse = #PC_CUSTOM + #TF_CHANGEPC;
		
	TeamFortress_ChangeClass(); 		
	ResetMenu();		

	self.current_menu = #MENU_DEFAULT;

	self.menu_displaytime = 0;
	self.impulse = 0;
};

void () Menu_Drop =
{
	if (self.weapons_carried & #WEAP_SPANNER)
		CenterPrint(self, "Äòïð ïò Íáëå:                   \n\n.. Shells                      \n.. Nails                       \n.. Rockets                     \n.. Cells                       \n\n.. Îïôèéîç                     \n\n");
	else
		CenterPrint(self, "Äòïð:                           \n\n.. Shells                      \n.. Nails                       \n.. Rockets                     \n.. Cells                       \n\n.. Îïôèéîç                     \n\n");
};

void () Menu_RepeatHelp =
{
	CenterPrint(self, "Press  to see this help again\n");
};

void(float inp) Menu_Drop_Input =
{
	if ((inp > 0) && (inp < 5))
	{
		TeamFortress_DropAmmo(inp);
	}
	
	//if ((inp > 0) && (inp < 6))
	if (inp == 10)
		ResetMenu();		

	self.impulse = 0;
};

void(float inp) Menu_DoBindings_Input =
{/*- unusefull
	local string st;

	if (inp < 4)
	{
		self.impulse = 0;
		if (inp == 1)
		{
			// Flag info
			stuffcmd(self, "bind q \"impulse 23\"\n");
			// Hook
			stuffcmd(self, "bind e \"impulse 22\"\n");
			// Grenade 1
			stuffcmd(self, "bind r \"+gren1\"\n");
			// Grenade 2
			stuffcmd(self, "bind f \"+gren2\"\n");
			// Detonate Pipebombs
			stuffcmd(self, "bind v \"detpipe\"\n");
			// Drop ammo
			stuffcmd(self, "bind c \"dropammo\"\n");
			// Scan
			stuffcmd(self, "bind x \"scan50\"\n");
			// Showclasses
			stuffcmd(self, "bind g \"showclasses\"\n");
			// Inventory
			stuffcmd(self, "bind z \"inv\"\n");
		
			self.menu_count = #MENU_REFRESH_RATE;
			self.current_menu = #MENU_SHOWBINDS1;
			self.menu_displaytime = 0;
			return;
		}
		else if (inp == 2)
		{
			// Flag info
			stuffcmd(self, "bind s \"impulse 23\"\n");
			// Hook
			stuffcmd(self, "bind x \"impulse 22\"\n");
			// Grenade 1
			stuffcmd(self, "bind d \"+gren1\"\n");
			// Grenade 2
			stuffcmd(self, "bind c \"+gren2\"\n");
			// Detonate Pipebombs
			stuffcmd(self, "bind f \"detpipe\"\n");
			// Drop ammo
			stuffcmd(self, "bind v \"dropammo\"\n");
			// Scan
			stuffcmd(self, "bind b \"scan50\"\n");
			// Showclasses
			stuffcmd(self, "bind g \"showclasses\"\n");
			// Inventory
			stuffcmd(self, "bind n \"inv\"\n");
		
			self.menu_count = #MENU_REFRESH_RATE;
			self.current_menu = #MENU_SHOWBINDS2;
			self.menu_displaytime = 0;
			return;
		}
		ResetMenu();		
	}*///- save space
};

void(float inp) Menu_Input =
{
	if (self.current_menu >= #MENU_SNIPER_WEAPON && self.current_menu <= #MENU_KNOCKTATION)
	if (inp >= 1 && inp <= 7)
	{
		if (!CanBuyItem(inp))
		{
			CuTFMenuSound(#MENUSOUND_WRONG);
			sprint(self,#PRINT_HIGH,"This specific item is disabled, sorry!\n");
			self.impulse = 0;
			return;
		}

		if (ItemIsFree(inp))
		{
			CuTFMenuSound(#MENUSOUND_WRONG);
			sprint(self,#PRINT_HIGH,"You can not sell this item, sorry!\n");
			self.impulse = 0;
			return;
		}
	}

	if (self.current_menu == #MENU_TEAM)
		Menu_Team_Input(inp);
	else if (self.current_menu == #MENU_CLASS)
		Menu_Class_Input(inp);
	else if (self.current_menu == #MENU_DROP)
		Menu_Drop_Input(inp);
	else if (self.current_menu == #MENU_SPY)
		Menu_Spy_Input(inp);
	else if (self.current_menu == #MENU_SPY_SKIN)
		Menu_Spy_Skin_Input(inp);
	else if (self.current_menu == #MENU_SPY_COLOR)
		Menu_Spy_Color_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER)
		Menu_Engineer_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_DISPENSER)
		Menu_EngineerFix_Dispenser_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_TESLA)
		Menu_EngineerFix_Tesla_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_TESLA2)
		Menu_EngineerFix_Tesla_Input2(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_SENTRYGUN)
		Menu_EngineerFix_SentryGun_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_CAMERA)
		Menu_EngineerFix_Camera_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_SENSOR)
		Menu_EngineerFix_Sensor_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_TELEPORTER)
		Menu_EngineerFix_Teleporter_Input(inp);
	else if (self.current_menu == #MENU_ENGINEER_FIX_FIELDGEN)
		Menu_EngineerFix_FieldGen_Input(inp);
	else if (self.current_menu == #MENU_DISPENSER)
		Menu_Dispenser_Input(inp);
	else if (self.current_menu == #MENU_CLASSHELP)
		Menu_ClassHelp_Input(inp);
	else if (self.current_menu == #MENU_PICKBINDS)
		Menu_DoBindings_Input(inp);
	else if (self.current_menu == #MENU_DEMON)
		Menu_Demon_Input(inp);
	else if (self.current_menu == #MENU_ARMY)
		Menu_Army_Input(inp);
	else if (self.current_menu == #MENU_E_HACK)
		Menu_EnemyHax_Inp(inp);
	else if (self.current_menu == #MENU_F_HACK)
		Menu_FriendHax_Inp(inp);
	else if (self.current_menu == #MENU_CRUSADER)
		Menu_Crusader_Input(inp);
	else if (self.current_menu == #MENU_GUERILLA)
		Menu_Guerilla_Input(inp);
	else if (self.current_menu == #MENU_PUNISH)
		Menu_Punish_Input(inp);
	else if (self.current_menu == #MENU_VOTEMAP)
		Menu_VoteMap_Input(inp);
	else if (self.current_menu == #MENU_BUILDING_FRAG_UPGRADE)
		Menu_BuildingFragUpgrade_Input(inp);
	else if (self.current_menu == #MENU_SNIPER_WEAPON) //WK --
		Menu_SniperWeapon_Input(inp);
	else if (self.current_menu == #MENU_ROCKET_WEAPON)
		Menu_RocketWeapon_Input(inp);
	else if (self.current_menu == #MENU_SHOTGUN_WEAPON)
		Menu_ShotgunWeapon_Input(inp);
	else if (self.current_menu == #MENU_OTHER_WEAPON)
		Menu_OtherWeapon_Input(inp);
	else if (self.current_menu == #MENU_TOOLS)
		Menu_Tools_Input(inp);
	else if (self.current_menu == #MENU_LEGS)
		Menu_Legs_Input(inp);
	else if (self.current_menu == #MENU_HEALTH)
		Menu_Health_Input(inp);
	else if (self.current_menu == #MENU_ARMOR)
		Menu_Armor_Input(inp);
	else if (self.current_menu == #MENU_SPECIAL)
		Menu_Special_Input(inp);
	else if (self.current_menu == #MENU_SPECIAL2)
		Menu_Special2_Input(inp);
	else if (self.current_menu == #MENU_GREN1)
		Menu_Gren1_Input(inp);
	else if (self.current_menu == #MENU_GREN2)
		Menu_Gren2_Input(inp);
	else if (self.current_menu == #MENU_ENGINEERING)
		Menu_Engineering_Input(inp);
	else if (self.current_menu == #MENU_PROFESSION)
		Menu_Profession_Input(inp);
	  else if (self.current_menu == #MENU_PROFESSION2)
		Menu_Profession2_Input(inp);
	else if (self.current_menu == #MENU_PROFICIENCY)
		Menu_Proficiency_Input(inp);
	else if (self.current_menu == #MENU_OPTION)
		Menu_Option_Input(inp); 
	else if (self.current_menu == #MENU_KNOCKTATION)
		Menu_Knocktation_Input(inp); //WK 1-19-09
};

void() Menu_Intro =
{
	//CenterPrint3(self, #MSG_INTRO, #MSG_INTRO2, #MSG_INTRO3);
	PrintProzacMOTD();
};

void() Menu_ClassHelp =
{
	if (self.menu_displaytime < 5)
	{
		if (self.playerclass == #PC_SCOUT)
			CenterPrint(self, "ÓÃÏÕÔ Details:               \n\n×ÅÁÐÏÎÓ:                     \n2.. Shotgun                  \n4.. Nailgun                  \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_SNIPER)
			CenterPrint(self, "ÓÎÉÐÅÒ Details:              \n\n×ÅÁÐÏÎÓ:                     \n2.. Sniper Rifle/Auto Rifle  \n4.. Nailgun                  \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_SOLDIER)
			CenterPrint(self, "ÓÏÌÄÉÅÒ Details:             \n\n×ÅÁÐÏÎÓ:                     \n2.. Shotgun                  \n3.. Super Shotgun            \n7.. Rocket Launcher          \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_DEMOMAN)
			CenterPrint(self, "ÄÅÍÏÌÉÔÉÏÎÓ ÍÁÎ Details:     \n\n×ÅÁÐÏÎÓ:                     \n2.. Shotgun                  \n6.. Grenade/Pipebomb Launcher\n                             \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_MEDIC)
			CenterPrint(self, "ÍÅÄÉÃ Details:               \n\n×ÅÁÐÏÎÓ:                     \n1.. Medikit/BioWeapon        \n2.. Shotgun                  \n3.. Super Shotgun            \n5.. Super Nailgun            \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_HVYWEAP)
			CenterPrint(self, "ÈÅÁÖÙ ×ÅÁÐÏÎÓ ÇÕÙ Details:   \n\n×ÅÁÐÏÎÓ:                     \n2.. Shotgun                  \n3.. Super Shotgun            \n7.. Assault Cannon           \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_PYRO)
			CenterPrint(self, "ÐÙÒÏ Details:                \n\n×ÅÁÐÏÎÓ:                     \n2.. Shotgun                  \n6.. Flamethrower             \n7.. Incendiary Cannon        \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_SPY)
			CenterPrint(self, "ÓÐÙ Details:                 \n\n×ÅÁÐÏÎÓ:                     \n2.. Tranquiliser Gun         \n3.. Super Shotgun            \n4.. Nailgun                  \n\nPress  for alias help\n");
		else if (self.playerclass == #PC_ENGINEER)
			CenterPrint(self, "ÅÎÇÉÎÅÅÒ Details:            \n\n×ÅÁÐÏÎÓ:                     \n1.. Spanner                  \n2.. RailGun                  \n3.. Super Shotgun            \n\nPress  for alias help\n");
	}
	else
	{
		if (self.playerclass == #PC_SCOUT)
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nFlash Grenade       \nConcussion Grenade  \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nScanner: scan10,scan50,scan250\nHolograph:  holo        \n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_SNIPER)
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nFlare               \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nautozoom : Toggle Rifle Autozooming\n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_SOLDIER)																							
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nNail Grenade        \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nNone\n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_DEMOMAN)																																																															
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nMirv Grenade        \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nThe Detpack : det5,det20,det50\nDetonate Pipebombs : detpipe  \n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_MEDIC)
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nConcussion Grenade  \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nNone\n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_HVYWEAP)
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nMirv Grenade        \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nNone\n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_PYRO)
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nNapalm Grenade      \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nNone\n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_SPY)
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nHallucinogen Grenade\n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nGo Undercover : disguise\nStart feigning: feign\n\n\nPress  for alias help\n");
		else if (self.playerclass == #PC_ENGINEER)
			CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nHand Grenade        \nEMP Grenade         \n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:   \nStart Building : build  \n\n\nPress  for alias help\n");
		/* WK Stop GRENADES - Build your own class from appearing
			else if (self.playerclass == #PC_CUSTOM)
				CenterPrint(self, "ÇÒÅÎÁÄÅÓ:            \nBuild your own class!\n\n");
		*/
	}
};

void() Menu_StuffClassHelp =
{
	/*
	if (self.playerclass == #PC_SCOUT)
	{
		sprint(self, #PRINT_HIGH, "ÓÃÏÕÔ Details:\n×ÅÁÐÏÎÓ:\n   2.. Shotgun\n   4.. Nailgun\n");
		sprint(self, #PRINT_HIGH, "ÇÒÅÎÁÄÅÓ:\n   Concussion Grenade\n   Flare\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n");
		sprint(self, #PRINT_HIGH, "Scanner: scan10,scan30,scan100\nHolograph: holo\n\n\n");
	}
	else if (self.playerclass == #PC_SNIPER)
	{
		sprint (self, #PRINT_HIGH, "ÓÎÉÐÅÒ Details:\n\n×ÅÁÐÏÎÓ:\n   2.. Sniper Rifle/Auto Rifle\n");
		sprint (self, #PRINT_HIGH, "4.. Nailgun\nÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n\n\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n");
		sprint (self, #PRINT_HIGH, "  autozoom : Toggle Rifle Autozooming\n\n\n");
	}
	else if (self.playerclass == #PC_SOLDIER)
	{
		sprint (self, #PRINT_HIGH, "ÓÏÌÄÉÅÒ Details:\n\n×ÅÁÐÏÎÓ:\n   2.. Shotgun\n   3.. Super Shotgun\n");
		sprint (self, #PRINT_HIGH, "   7.. Rocket Launcher\nÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n   Nail Grenade\n");
		sprint (self, #PRINT_HIGH, "ÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n   None\n\n\n");
	}
	else if (self.playerclass == #PC_DEMOMAN)
	{
		sprint (self, #PRINT_HIGH, "ÄÅÍÏÌÉÔÉÏÎÓ ÍÁÎ Details:\n\n×ÅÁÐÏÎÓ:\n   2.. Shotgun\n   6.. Grenade/Pipebomb Launcher\n");
		sprint (self, #PRINT_HIGH, "ÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n   Mirv Grenade\n");
		sprint (self, #PRINT_HIGH, "ÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n   The Detpack : det5,det20,det50\n   Detonate Pipebombs : detpipe\n\n\n");
	}
	else if (self.playerclass == #PC_MEDIC)
	{
		sprint (self, #PRINT_HIGH, "ÍÅÄÉÃ Details:\n\n×ÅÁÐÏÎÓ:\n   1.. Medikit/BioWeapon\n   2.. Shotgun\n   3.. Super Shotgun\n");
		sprint (self, #PRINT_HIGH, "   5.. Super Nailgun\nÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n   Concussion Grenade\n");
		sprint (self, #PRINT_HIGH, "ÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n   None\n\n\n");
	}
	else if (self.playerclass == #PC_HVYWEAP)
	{
		sprint (self, #PRINT_HIGH, "ÈÅÁÖÙ ×ÅÁÐÏÎÓ ÇÕÙ Details:\n\n×ÅÁÐÏÎÓ:\n   2.. Shotgun\n   3.. Super Shotgun\n");
		sprint (self, #PRINT_HIGH, "   7.. Assault Cannon\nÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n");
		sprint (self, #PRINT_HIGH, "   Mirv Grenade\nÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n   None\n\n\n");
	}
	else if (self.playerclass == #PC_PYRO)
	{
		sprint (self, #PRINT_HIGH, "ÐÙÒÏ Details:\n\n×ÅÁÐÏÎÓ:\n   2.. Shotgun\n   6.. Flamethrower\n   7.. Incendiary Cannon\n");
		sprint (self, #PRINT_HIGH, "ÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n   Napalm Grenade\n");
		sprint (self, #PRINT_HIGH, "ÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n   None\n\n\n");
	}
	else if (self.playerclass == #PC_SPY)
	{
		sprint (self, #PRINT_HIGH, "ÓÐÙ Details:\n\n×ÅÁÐÏÎÓ:\n   2.. Tranquiliser Gun\n   3.. Super Shotgun\n   4.. Nailgun\n");
		sprint (self, #PRINT_HIGH, "ÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n   Hallucinogenic Grenade\n");
		sprint (self, #PRINT_HIGH, "ÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n   Go Undercover : disguise\n   Start feigning: feign\n\n\n");
	}
	else if (self.playerclass == #PC_ENGINEER)
	{
		sprint (self, #PRINT_HIGH, "ÅÎÇÉÎÅÅÒ Details:\n\n×ÅÁÐÏÎÓ:\n   1.. Spanner\n   2.. RailGun\n   3.. Super Shotgun\n");
		sprint (self, #PRINT_HIGH, "ÇÒÅÎÁÄÅÓ:\n   Hand Grenade\n   EMP Grenade\n");
		sprint (self, #PRINT_HIGH, "ÓÐÅÃÉÁÌ ÃÏÍÍÁÎÄÓ:\n   Start Building : build\n\n\n");
	}
	*/
};

void() Menu_ClassHelp2 =
{								  
	CenterPrint(self, "Ãïííáîäó:     \n\ninv       : Show inventory \n+gren1    : Throw grenade 1\n+gren2    : Throw Grenade 2\nreload    : Force a reload \ndropammo  : drop some ammo \nskill     : use job ability\ntaunt1 : taunts(also 2,3,4)\n");
};																																																		//	  \nskill	  : use job ability

void(float inp) Menu_ClassHelp_Input =
{
	if (self.playerclass == #PC_UNDEFINED) return;

//CH changed inp from 8 to 9,  lgun uses 8
	if (inp == 9)
	{
		Menu_ClassHelp2();
		self.menu_count = #MENU_REFRESH_RATE;
		self.current_menu = #MENU_CLASSHELP2;
		self.menu_displaytime = 0;
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

void() Menu_DoBindings =
{																						 
	//CenterPrint(self, ".. Use keys: E R F V C Q X G Z\n.. Use keys: S X D C F V B G N\n.. Don't make bindings        \n");
};

void() Menu_ShowBindings1 =
{
	//CenterPrint(self, "Ñ.. Flaginfo      \nÅ.. Hook          \nÒ.. Throw Gren 1  \nÆ.. Throw Gren 2  \nÖ.. Det. Pipebombs\nÃ.. Drop ammo     \nØ.. Use Scanner   \nÇ.. Showclasses   \nÚ.. inventory     \n");
};

void() Menu_ShowBindings2 =
{
	//CenterPrint(self, "Ó.. Flaginfo      \nØ.. Hook          \nÄ.. Throw Gren 1  \nÃ.. Throw Gren 2  \nÆ.. Det. Pipebombs\nÖ.. Drop ammo     \nÂ.. Use Scanner   \nÇ.. Showclasses   \nÎ.. inventory     \n");
};

//============================================================================
// SPY menus for the Skin and Color changing ability
void() Menu_Spy =
{
		if (self.is_feigning)
	{
		if (self.undercover_team != 0 && self.undercover_skin != 0)
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Stop Feigning               \n.. Reset Skin and Color        \n\n.. Îïôèéîç                     \n\n");
		else if (self.undercover_team != 0)
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Stop Feigning               \n.. Reset Color                 \n\n.. Îïôèéîç                     \n\n");
		else if (self.undercover_skin != 0)
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Stop Feigning               \n.. Reset Skin                  \n\n.. Îïôèéîç                     \n\n");
		else
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Stop Feigning               \n\n.. Îïôèéîç                     \n\n");
	}
	else
	{
		if (self.undercover_team != 0 && self.undercover_skin != 0)
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Start Feigning              \n.. Reset Skin and Color        \n\n.. Îïôèéîç                     \n\n");
		else if (self.undercover_team != 0)
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Start Feigning              \n.. Reset Color                 \n\n.. Îïôèéîç                     \n\n");
		else if (self.undercover_skin != 0)
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Start Feigning              \n.. Reset Skin                  \n\n.. Îïôèéîç                     \n\n");
		else
			CenterPrint(self, "Áãôéïî:                           \n\n.. Change Skin                 \n.. Change Color                \n.. Start Feigning              \n\n.. Îïôèéîç                     \n\n");
	}
};

void(float inp) Menu_Spy_Input =
{
	//local float tc;
	//local string st;
	
	if (inp == 1 || inp == 2)
	{
		if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT))
		{
			sprint(self, #PRINT_HIGH, "You can't go undercover while glowing.\n");
			ResetMenu();		
			self.impulse = 0;
			return;
		}
		if (self.is_unabletospy == 1)
		{
			sprint(self, #PRINT_HIGH, "You can't go undercover right now.\n");
			ResetMenu();		
			self.impulse = 0;
			return;
		}
	}

	if (inp == 1)
	{
		Menu_Spy_Skin();
		self.menu_count = #MENU_REFRESH_RATE;
		self.current_menu = #MENU_SPY_SKIN;
		self.menu_displaytime = 0;
		self.impulse = 0;
	}
	else if (inp == 2)
	{
		Menu_Spy_Color();
		self.menu_count = #MENU_REFRESH_RATE;
		self.current_menu = #MENU_SPY_COLOR;
		self.menu_displaytime = 0;
		self.impulse = 0;
	}
	else if (inp == 3)
	{
		TeamFortress_SpyFeignDeath(1); //CH Normal feign
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 4)
	{
		Spy_RemoveDisguise(self);

		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 5 && (self.undercover_team != 0 || self.undercover_skin != 0))
	{
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

void() Menu_Spy_Skin =
{
	CenterPrint(self, "Ãèáîçå Óëéî ôï:\n\n.. Scout   \n.. Sniper  \n.. Soldier \n.. Demoman \n.. Medic   \n.. Hwguy   \n.. Pyro    \n.. Spy     \n.. Engineer\n\n");
};

void(float inp) Menu_Spy_Skin_Input =
{
	if (inp < 10 && inp > 0)
	{
		TeamFortress_SpyChangeSkin(inp);
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

void() Menu_Spy_Color =
{
	if (number_of_teams == 0)
	{
		sprint(self, #PRINT_HIGH, "No Color changing allowed in deathmatch.\n");
		ResetMenu();		
		self.impulse = 0;
		return;
	}

	if (number_of_teams == 1)											 
		CenterPrint(self, "Ãèáîçå Ãïìïò ôï:\n\n.. Team One  \n\n");
	else if (number_of_teams == 2)
		CenterPrint(self, "Ãèáîçå Ãïìïò ôï:\n\n.. Team One  \n.. Team Two  \n\n");
	else if (number_of_teams == 3)
		CenterPrint(self, "Ãèáîçå Ãïìïò ôï:\n\n.. Team One  \n.. Team Two  \n.. Team Three\n\n");
	else // if (number_of_teams == 4)
		CenterPrint(self, "Ãèáîçå Ãïìïò ôï:\n\n.. Team One  \n.. Team Two  \n.. Team Three\n.. Team Four \n\n");
};

void(float inp) Menu_Spy_Color_Input =
{
	if (inp >= 1 && inp <= number_of_teams)
	{
		TeamFortress_SpyChangeColor(inp);
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

//============================================================================
// ENGINEER menus for the building ability
//WK Rewritten for better extensibility and less lines of code

void() Menu_Engineer =
{
	//Set up empty menu
	local string line1;
	local string line2;
	local string line3;
	local string line4;
	local string line5;
	local string line6;
	local string line7;

	//Check line for Dispenser
	if (self.has_dispenser == #TRUE)
		line1 = "Áãôéïî:                           \n\n®® Destroy Dispenser             \n";
	else if (self.ammo_cells >= #BUILD_COST_DISPENSER && (self.cutf_items & #CUTF_DISPENSER))//SB
		line1 = "Áãôéïî:                           \n\n.. Build Dispenser               \n";
	else
		line1 = "Áãôéïî:                           \n\n                                  \n";

	if (self.cutf_items & #CUTF_SENTRYGUN && self.cutf_items & #CUTF_DOUBLESENTRY) // 2 sentries
	{
		if (self.has_sentry & 1) // 1st sentry up
			line2 = "®® Destroy Sentry Gun #1         \n";
		else if (self.ammo_cells >= #BUILD_COST_SENTRYGUN)
			line2 = ".. Build Sentry Gun #1           \n";
		else line2 = "                                  \n";
		
		if (self.has_sentry & 2) // 2nd sentry up
			line3 = "®® Destroy Sentry Gun #2         \n";
		else if (self.ammo_cells >= #BUILD_COST_SENTRYGUN)
			line3 = ".. Build Sentry Gun #2           \n";
		else line3 = "                                  \n";
	}
	else if (self.tf_items & #NIT_TESLA && self.tf_items & #NIT_DOUBLETESLA) // 2 teslas
	{
		if (self.has_tesla & 1) // 1st sentry up
			line2 = "®® Destroy Tesla Coil #1         \n";
		else if (self.ammo_cells >= #BUILD_COST_TESLA)
			line2 = ".. Build Tesla Coil #1           \n";
		else line2 = "                                  \n";
		
		if (self.has_tesla & 2) // 2nd sentry up
			line3 = "®® Destroy Tesla Coil #2         \n";
		else if (self.ammo_cells >= #BUILD_COST_TESLA)
			line3 = ".. Build Tesla Coil #2           \n";
		else line3 = "                                  \n";
	}
	else
	{
		if (self.has_sentry)
			line2 = "®® Destroy Sentry Gun            \n";
		else if (self.ammo_cells >= #BUILD_COST_SENTRYGUN && self.cutf_items & #CUTF_SENTRYGUN)
			line2 = ".. Build Sentry Gun              \n";
		else
			line2 = "                                  \n";

		if (self.has_tesla)
			line3 = "®® Destroy Tesla Coil            \n";
		else if (self.ammo_cells >= #BUILD_COST_TESLA && self.tf_items & #NIT_TESLA)
			line3 = ".. Build Tesla Coil              \n";
		else
			line3 = "                                  \n";
	}

	if (self.has_camera == #TRUE)
		line4 = "®® Destroy Security Camera       \n"; //CH impulse 4 for both
	else if (self.ammo_cells >= #BUILD_COST_CAMERA && self.tf_items & #NIT_SECURITY_CAMERA)
		line4 = ".. Launch Security Camera        \n";
	else
		line4 = "                                  \n";
	
	if (self.has_teleporter != 0) //CH messy, yes
	{
		if (self.has_teleporter == 1 && self.ammo_cells >= #BUILD_COST_TELEPORTER)
			line5 = ".. Build a Teleporter Pad        \n®® Destroy a Teleporter Pad      \n"; //ofn the number is 5
		else if (self.has_teleporter == 1 && self.ammo_cells < #BUILD_COST_TELEPORTER)
			line5 = "®® Destroy a Teleporter Pad      \n"; // 6
		if (self.has_teleporter == 2)
			line5 = "®® Destroy Both Teleporter Pads  \n"; // 6
	}
	else if (self.ammo_cells >= #BUILD_COST_TELEPORTER && self.tf_items & #NIT_TELEPORTER)
		line5 = ".. Build a Teleporter Pad        \n";
	else
		line5 = "                                  \n";

	if (self.has_sensor==#TRUE)
	{
		line6 = "®® Destroy Motion Sensor         \n";
	}
	else if (self.ammo_cells >= #BUILD_COST_SENSOR && self.cutf_items & #CUTF_SENSOR)
	{
		line6 = ".. Deploy Motion Sensor          \n"; 	
	}
	else
	{
		line6 = "                                  \n";
	}

	if (self.has_fieldgen != 0) //CH messy, yes
	{
		if (self.has_fieldgen == 1 && self.ammo_cells >= #BUILD_COST_FIELDGEN)
			line7 = ".. Build a Field Generator       \n®® Destroy a Field Generator     \n\n.. Îïôèéîç                       \n"; //ofn the number is 5
		else if (self.has_fieldgen == 1 && self.ammo_cells < #BUILD_COST_FIELDGEN)
			line7 = "®® Destroy a Field Generator     \n\n.. Îïôèéîç                       \n"; // 6

#ifdef FIELD_FORCEMODE

		if (self.has_fieldgen >= 2)
		{
			if (GetFieldForcedStatus())
				line7 = ".. Force field: Ãìïóåä Íïäå      \n®® Destroy Both Field Generators \n\n.. Îïôèéîç                       \n";
			else
				line7 = ".. Force field: Éîôåììéçåîô Íïäå \n®® Destroy Both Field Generators \n\n.. Îïôèéîç                       \n";
		}

#else

		if (self.has_fieldgen >= 2)
			line7 = "®® Destroy Both Field Generators \n\n.. Îïôèéîç                       \n"; // 6

#endif

	}
	else if (self.ammo_cells >= #BUILD_COST_FIELDGEN && self.cutf_items & #CUTF_FIELDGEN)
		line7 = ".. Build a Field Generator       \n\n.. Îïôèéîç                       \n";
	else
		line7 = "                                  \n.. Îïôèéîç                       \n";


	//Finally, we output the menu...
	CenterPrint7(self,line1,line2,line3,line4,line5,line6,line7);
 
};

void(float inp) Menu_Engineer_Input =
{
	local entity te, te2;

	// OfN - Handle double stuff first
	if (inp >= 2 && inp <=3)
	if (self.cutf_items & #CUTF_DOUBLESENTRY || self.tf_items & #NIT_DOUBLETESLA)
	{
		if (self.cutf_items & #CUTF_DOUBLESENTRY)
		{
			if (inp == 2)
			{
				if (self.has_sentry & 1)
				{
					te = find(world, classname, "building_sentrygun");
					while (te)
					{
						if (te.dont_do_triggerwork == 1)
						{
							Find_And_Dmg("building_sentrygun",self,1,1);
						}
						
						te = find(te, classname, "building_sentrygun");
					}					 
				}
				else
					TeamFortress_Build(#BUILD_SENTRYGUN,1);
			}
			else if (inp == 3)
			{
				if (self.has_sentry & 2)
				{
					te = find(world, classname, "building_sentrygun");
					while (te)
					{
						if (te.dont_do_triggerwork == 2)
						{
							Find_And_Dmg("building_sentrygun",self,1,2);
						}
						
						te = find(te, classname, "building_sentrygun");
					}					 
				}
				else
					TeamFortress_Build(#BUILD_SENTRYGUN,2);
			}
		}
		else if (self.tf_items & #NIT_DOUBLETESLA)
		{
			if (inp == 2)
			{
				if (self.has_tesla & 1)
				{
					te = find(world, classname, "building_tesla");
					while (te)
					{
						if (te.dont_do_triggerwork == 1)
						{
							if (te.real_owner == self)
							{
								if (te.tf_items & #NIT_SECURITY_CAMERA) {
									sprint(self, #PRINT_HIGH, "Can't detonate a rogue tesla. Sorry, it's not that easy.\n");
									ResetMenu();		
									self.impulse = 0;
									return;
								}
							}

							Find_And_Dmg("building_tesla",self,1,1);
						}
						te = find(te, classname, "building_tesla");
					}				 
				}					 
				else
					TeamFortress_Build(#BUILD_TESLA,1);
			}
			else if (inp == 3)
			{
				if (self.has_tesla & 2)
				{
					te = find(world, classname, "building_tesla");
					while (te)
					{
						if (te.dont_do_triggerwork == 2)
						{
							if (te.real_owner == self)
							{
								if (te.tf_items & #NIT_SECURITY_CAMERA) {
									sprint(self, #PRINT_HIGH, "Can't detonate a rogue tesla. Sorry, it's not that easy.\n");
									ResetMenu();		
									self.impulse = 0;
									return;
								}
							}

							Find_And_Dmg("building_tesla",self,1,2);
						}
						te = find(te, classname, "building_tesla");
					}					 
				}					 
				else
					TeamFortress_Build(#BUILD_TESLA,2);
			}
		}

		ResetMenu();
		self.impulse = 0;
		return;
	}

	if (inp == 1 && self.ammo_cells >= #BUILD_COST_DISPENSER && self.has_dispenser == #FALSE)
	{
		//if (!self.has_dispenser)
		TeamFortress_Build(#BUILD_DISPENSER,0);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 2 && self.ammo_cells >= #BUILD_COST_SENTRYGUN && self.has_sentry == #FALSE)
	{
		if (HasFlag(self.team_no) == #FALSE) {
			CenterPrint(self, "No building until your team has the flag!\n");
			return; 	
		}
	
		TeamFortress_Build(#BUILD_SENTRYGUN,1);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 3 && self.ammo_cells >= #BUILD_COST_TESLA && self.has_tesla == #FALSE)
	{
		if (HasFlag(self.team_no) == #FALSE) {
			CenterPrint(self, "No building until your team has the flag!\n");
			return; 	
		}
		
		TeamFortress_Build(#BUILD_TESLA,1);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 4)
	{
		if (!self.has_camera)
			TeamFortress_Build(#BUILD_SECURITY_CAMERA,0);
		else
		{
			if (self.option < time)
				Find_And_Dmg("building_camera", self, 1,0);
			else
			{
				self.impulse = 0;
				return;
			}
		}
		ResetMenu();		
		self.impulse = 0;
	}
//CH uses 5 and 6 
	else if (inp == 5 && (self.has_teleporter == 0 || self.has_teleporter == 1) && self.ammo_cells >= #BUILD_COST_TELEPORTER) //ch if have one out, can build
	{
		if (HasFlag(self.team_no) == #FALSE) {
				CenterPrint(self, "No building until your team has the flag!\n");
				return; 	
		}

		if (self.has_teleporter == 1)
		{
				local float r;
				te = find(world, classname, "building_teleporter");
				while (te)
				{
					if (te.real_owner == self)
					{
						r = vlen(te.origin - self.origin);
						if (r > #TELEPORTER_RANGE && !(te.all_active & #IMPROVED_FOUR))
						{							
							sprint(self, #PRINT_HIGH, "Other Teleporter is too far away\n");
						}
						else
						{
							TeamFortress_Build(#BUILD_TELEPORTER,0);	
							ResetMenu();		
							self.impulse = 0;
						}
					}
					te = find(te, classname, "building_teleporter");
				}	
		}
		else
		{
			TeamFortress_Build(#BUILD_TELEPORTER,0);	
			ResetMenu();		
			self.impulse = 0;
		}
	
	}
	else if (inp == 6 && (self.has_teleporter == 1 || self.has_teleporter == 2)) //ch if have one out. can destroy
	{
		Find_And_Dmg("building_teleporter", self, 1,0);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 7 && (self.ammo_cells >= #BUILD_COST_SENSOR || self.has_sensor) && self.cutf_items & #CUTF_SENSOR)
	{
		SBBuildSensor();
		ResetMenu();		
		self.impulse = 0;
	}
	//CH uses 5 and 6 
	else if (inp == 8) //ch if have one out, can build
	{
		if ((self.has_fieldgen == 0 || self.has_fieldgen == 1) && self.ammo_cells >= #BUILD_COST_FIELDGEN)
		{
			if (HasFlag(self.team_no) == #FALSE) {
				CenterPrint(self, "No building until your team has the flag!\n");
				return; 	
			}
			
			#ifndef NO_FIELDGEN_INTERFERENCE

			// find if there are other generators too close, if this is our first generator only - nope
			
			local float r, mindist;
			mindist = 3000;

			te = find(world, classname, "building_fieldgen");
			while (te)
			{
				if (!te.real_owner == self)
				{
					r = vlen(te.origin - self.origin);

					if (r < mindist)
						mindist = r;
				}
				te = find(te, classname, "building_fieldgen");
			}
			
			if (mindist < #FIELDGEN_HACKEDRANGE) // * 2
			{							
				sprint(self, #PRINT_HIGH, "There are interferences with other field generators here!\n");
			}
			else
			{			 
				TeamFortress_Build(#BUILD_FIELDGEN,0);	
				ResetMenu();		
				self.impulse = 0;			 
			}
			
			#else
			
			TeamFortress_Build(#BUILD_FIELDGEN,0);	
			ResetMenu();		
			self.impulse = 0;			 

			#endif
		}

#ifdef FIELD_FORCEMODE

		else if (self.has_fieldgen > 1)
		{
			if (GetFieldForcedStatus())
			{
				SetFieldForcedStatus(#FALSE);
				sprint(self,#PRINT_HIGH,"You set the force field to Intelligent Mode\n");
			}
			else
			{
				SetFieldForcedStatus(#TRUE);
				sprint(self,#PRINT_HIGH,"You set the force field to Closed Mode\n");
			}

			ResetMenu();
			self.impulse = 0;
		}

#endif

	}
	else if (inp == 9 && (self.has_fieldgen >= 1)) //ch if have one out. can destroy
	{
		Find_And_Dmg("building_fieldgen", self, 1,0);
		self.has_fieldgen = 0; // FIXME: shouldnt be needed
		ResetMenu();		
		self.impulse = 0;
	}
//-----------------------------------------------------------------//
	else if (inp == 1 && self.has_dispenser == #TRUE)
	{
		Find_And_Dmg("building_dispenser", self, 1,0);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 2 && self.has_sentry == #TRUE)
	{
		te2 = world;
		te = find(world,classname,"building_sentrygun");
		while(te != world && te2 == world)
		{
			if (te.real_owner == self)
				te2 = te;

			te = find(te, classname,"building_sentrygun");
		}

		if (te2 == world)
			return;

/* WK 1/7/7 This is silly... you can get stuck with damaged or ammo empty turrets that you can't fix
		if ((te2.max_health - te2.health) > (te2.max_health * #SENTRIES_MINIMUMHP_TODETONATE_FACTOR))
		{
			sprint(self,#PRINT_HIGH,"Your sentry holds too much damage to be able to detonate it remotely!\n");
			self.impulse = 0;
			return;
		}		 
*/

		Find_And_Dmg("building_sentrygun", self, 1,0);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 3 && self.has_tesla == #TRUE)
	{
		te = find(world, classname, "building_tesla");
		while (te)
		{
			if (te.real_owner == self)
			{
				if (te.tf_items & #NIT_SECURITY_CAMERA) {
					sprint(self, #PRINT_HIGH, "Can't detonate a rogue tesla. Sorry, it's not that easy.\n");
					ResetMenu();		
					self.impulse = 0;
					return;
				}
/* WK 6/1/7 This is a silly feature.
				if ((te.max_health - te.health) > (te.max_health * #SENTRIES_MINIMUMHP_TODETONATE_FACTOR))
				{
					sprint(self,#PRINT_HIGH,"Your tesla holds too much damage to be able to detonate it remotely!\n");
					self.impulse = 0;
					return;
				}
*/
			}
			te = find(te, classname, "building_tesla");
		}

		Find_And_Dmg("building_tesla", self, 1,0);
		ResetMenu();		
		self.impulse = 0;
	}
	else if (inp == 10) //CH was 4
	{
		ResetMenu();		
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};
//CH to reduce code.
void(entity person, string build) Add_Building_Teamkill =
{
	local string st;
	local float threshold;
	threshold = 0;
	bprint (#PRINT_HIGH, person.netname);
	bprint (#PRINT_HIGH, " has dismantled a friendly ");
	bprint (#PRINT_HIGH, build);
	bprint (#PRINT_HIGH, "!\n");

	st = infokey(world, "curse");
	if (st != string_null)
	threshold = stof(st);
	person.ff_count = person.ff_count + 2; //Increase their bastard rating
	//Increase the engineers bastard rating so they
	//can't block everyone.
	person.building.real_owner.ff_count = person.building.real_owner.ff_count + 0.5;
	if (threshold >= 1)
	{
		if (person.ff_count >= threshold) createBastard(person,threshold);
		if (person.building.real_owner.ff_count >= threshold) createBastard(person.building.real_owner,threshold);
		if ((person.ff_count == threshold - 2) || (person.ff_count == threshold - 1.5) || (person.ff_count == threshold - 1) || (person.ff_count == threshold - 0.5))
		{
			sprint (person, #PRINT_MEDIUM, "One more dismantling and you will be cursed.\n");
		}
	}
};

//============================================================================
// ENGINEER menus for fixing buildings

void() Menu_EngineerFix_Dispenser =
{
	CenterPrint(self, "Áãôéïî:                            \n\n.. Put Ammo into Dispenser     \n.. Put Armor into Dispenser    \n.. Repair Dispenser            \n.. Dismantle Dispenser         \n\n.. Îïôèéîç                     \n\n");
};

void(float inp) Menu_EngineerFix_Dispenser_Input =
{
	local float metalcost;
	local float am;

	if (self.classname != "player" || self.building == world)
		return;

	local float iI; // is Improved?
	iI=1;
	if (self.building.all_active & #IMPROVED_ONE)
		iI=2;

	if (inp == 1)
	{
		// shells
		am = (#DROP_SHELLS * 2);
		if (am > self.ammo_shells)
			am = self.ammo_shells; 
		if (am > (#BUILD_DISPENSER_MAX_SHELLS*iI - self.building.ammo_shells))
			am = #BUILD_DISPENSER_MAX_SHELLS*iI - self.building.ammo_shells;
		self.ammo_shells = self.ammo_shells - am;
		self.building.ammo_shells = self.building.ammo_shells + am;

		// nails
		am = (#DROP_NAILS * 2);
		if (am > self.ammo_nails)
			am = self.ammo_nails; 
		if (am > (#BUILD_DISPENSER_MAX_NAILS*iI - self.building.ammo_nails))
			am = #BUILD_DISPENSER_MAX_NAILS*iI - self.building.ammo_nails;
		self.ammo_nails = self.ammo_nails - am;
		self.building.ammo_nails = self.building.ammo_nails + am;

		// rockets
		am = (#DROP_ROCKETS * 2);
		if (am > self.ammo_rockets)
			am = self.ammo_rockets; 
		if (am > (#BUILD_DISPENSER_MAX_ROCKETS*iI - self.building.ammo_rockets))
			am = #BUILD_DISPENSER_MAX_ROCKETS*iI - self.building.ammo_rockets;
		self.ammo_rockets = self.ammo_rockets - am;
		self.building.ammo_rockets = self.building.ammo_rockets + am;

		// cells
		am = (#DROP_CELLS * 2);
		if (am > self.ammo_cells)
			am = self.ammo_cells; 
		if (am > (#BUILD_DISPENSER_MAX_CELLS*iI - self.building.ammo_cells))
			am = #BUILD_DISPENSER_MAX_CELLS*iI - self.building.ammo_cells;
		self.ammo_cells = self.ammo_cells - am;
		self.building.ammo_cells = self.building.ammo_cells + am;
	}
	else if (inp == 2)
	{
		// armor
		am = (#DROP_ARMOR * 2);
		if (am > self.armorvalue)
			am = self.armorvalue; 
		if (am > (#BUILD_DISPENSER_MAX_ARMOR*iI - self.building.armorvalue))
			am = #BUILD_DISPENSER_MAX_ARMOR*iI - self.building.armorvalue;
		self.armorvalue = self.armorvalue - am;
		self.building.armorvalue = self.building.armorvalue + am;
	}
	else if (inp == 3)
	{
		//local string f1;

		metalcost = (self.building.max_health - self.building.health) / 5;

		if (metalcost > self.ammo_cells)
			metalcost = self.ammo_cells;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 5);
	}
	else if (inp == 4)
	{
		if (CheckEnemyDismantle()==#FALSE) {ResetMenu(); self.impulse=0; return;}

		sprint (self, #PRINT_HIGH, "You dismantle the Dispenser.\n");
		self.ammo_cells = self.ammo_cells + (#BUILD_COST_DISPENSER / 2);
///////////////////////////
#ifdef QUAKE_WORLD
		if (Teammate(self.building.real_owner, self) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "dispenser");
		}
#endif

		self.building.health=0; // - OfN aborts hacks on it
		self.building.real_owner.has_dispenser = #FALSE;
		dremove(self.building);

	}

	if (inp >= 1 && inp <= 5)
	{
		ResetMenu();		
		self.impulse = 0;
		self.building = world;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}

	// Otherwise, the impulse is passed on
};

//WK 1/15/08 New frag upgrade menus
// .frags holds total building kills. .money holds frags spent
// .demon_blood holds new upgrades bought
void() Menu_BuildingFragUpgrade =
{
	local float ups;
	local string s1,s2,s3,s4,s5,s6,s7,temp;
	ups = self.building.frags - self.building.money;
	if (self.building.frags > 18) //18 = all 9 upgrades
		ups = 18 - self.building.money;
	if (ups < 0) ups = 0;
	if (ups > 18) ups = 18;
	s1 = "== Experienced Sentry Upgrade Center ==\n 2 frags per upgrade, frags available: ";
	temp = ftos(ups);
	s1 = strcat(s1,temp);
	s1 = strcat(s1,"\n");

	if (self.building.demon_blood & #BUILD_FLAME_ADDITION) 
		s2 = "*. Flame Sentry Addition        \n";
	else
		s2 = " . Flame Sentry Addition        \n";

	if (self.building.demon_blood & #BUILD_FROST_ADDITION) 
		s2 = strcat(s2,"*. Frost Sentry Addition        \n");
	else
		s2 = strcat(s2," . Frost Sentry Addition        \n");

	if (self.building.demon_blood & #BUILD_AIR_ADDITION) 
		s3 = "*. Airfist Sentry Addition      \n";
	else
		s3 = " . Airfist Sentry Addition      \n";

	if (self.building.demon_blood & #BUILD_WOOD_ADDITION) 
		s3 = strcat(s3,"*. Wood Flak Addition           \n");
	else
		s3 = strcat(s3," . Wood Flak Addition           \n");

	if (self.building.demon_blood & #BUILD_WEAPON_UPGRADE) 
		s4 = "*. Main Weapon Upgrade          \n";
	else
		s4 = " . Main Weapon Upgrade          \n";

	if (self.building.demon_blood & #BUILD_OPTIC_UPGRADE) 
		s4 = strcat(s4,"*. Optics Upgrade               \n");
	else
		s4 = strcat(s4," . Optics Upgrade               \n");

	if (self.building.demon_blood & #BUILD_BLACK_HOLE) 
		s5 = "*. Black Hole Gun               \n";
	else
		s5 = " . Black Hole Gun               \n";

	if (self.building.demon_blood & #BUILD_ANTIPSIONIC_AI) 
		s5 = strcat(s5,"*. Antipsionic AI               \n");
	else
		s5 = strcat(s5," . Antipsionic AI               \n");

	if (self.building.armorclass & #AT_SAVEMELEE) 
		s6 = "*. Gel Armor                    \n";
	else
		s6 = " . Gel Armor                    \n";

	s7 = " 0. Îïôèéîç                     \n";

	CenterPrint7(self,s1,s2,s3,s4,s5,s6,s7);

};

void(float inp) Menu_BuildingFragUpgrade_Input =
{
	if (inp >= 1 && inp <= 10) {
		sprint(self, #PRINT_HIGH, "Hello, World!\n");
		ResetMenu();		
		self.impulse = 0;
	}
};

void() Menu_EngineerFix_SentryGun =
{
	if (self.building.weapon < 4 && self.ammo_cells >= #BUILD_COST_SENTRYGUN) //WK 1/15/8 Was < 3
	{
		if (!(self.tf_items & #NIT_TURRET)) // TODO: Action --> OfteN's sentry gun
			CenterPrint(self, "Áãôéïî:                            \n\n.. Put Ammo into Sentry Gun    \n.. Upgrade Sentry Gun          \n.. Repair Sentry Gun           \n\n.. Îïôèéîç                     \n\n.. Dismantle Sentry Gun        \n.. Rotate Clockwise            \n.. Rotate Counter-Clockwise    \n");
		else
			CenterPrint(self, "Áãôéïî:                            \n\n.. Put Ammo into Sentry Gun    \n.. Upgrade Sentry Gun          \n.. Repair Sentry Gun           \n\n.. Îïôèéîç                     \n\n.. Dismantle Sentry Gun        \n.. Rotate Clockwise            \n.. Rotate Counter-Clockwise    \n.. Create Turret               \n");
	}
	else
	{
		if (!(self.tf_items & #NIT_TURRET))
			CenterPrint(self, "Áãôéïî:                            \n\n.. Put Ammo into Sentry Gun    \n.. Repair Sentry Gun           \n\n.. Îïôèéîç                     \n\n.. Dismantle Sentry Gun        \n.. Rotate Clockwise            \n.. Rotate Counter-Clockwise    \n");
		else
			CenterPrint(self, "Áãôéïî:                            \n\n.. Put Ammo into Sentry Gun    \n.. Repair Sentry Gun           \n\n.. Îïôèéîç                     \n\n.. Dismantle Sentry Gun        \n.. Rotate Clockwise            \n.. Rotate Counter-Clockwise    \n.. Create Turret               \n");
	}
};

//WK 1/15/8 Rearm and Repair in Engineer.qc now
float() Engineer_RearmSentryGun;
float() Engineer_RepairSentryGun;
float() Engineer_RepairTesla;

void(float inp) Menu_EngineerFix_SentryGun_Input =
{
	local float am, metalcost;
	local string st;

	if (self.classname != "player" || self.building == world)
		return;

	//Rearm Sentry
	if (inp == 1)
	{
		Engineer_RearmSentryGun();
	}
	//Upgrade Sentry
	//WK 1/15/08 Added support for level 4 sentries -- need 1 frag to upgrade
	else if (inp == 2 && self.ammo_cells >= #BUILD_COST_SENTRYGUN) {
		if (self.building.weapon < 3 || (self.building.weapon == 3 && self.building.frags >= 1))
		{
			self.ammo_cells = self.ammo_cells - #BUILD_COST_SENTRYGUN;
			self.building.weapon = self.building.weapon + 1;

			local float HPfactor,AMMOfactor;
			if (self.building.all_active & #IMPROVED_THREE)
				HPfactor=1.5; //WK 1-7-7 Toned down hacking, 2
			else
				HPfactor=1;

			if (self.building.all_active & #IMPROVED_ONE)
				AMMOfactor=2;
			else
				AMMOfactor=1;
		
			// Change the skin and frames
			if (self.building.weapon == 2)
			{
				sound (self.building, #CHAN_ITEM, "weapons/turrset.wav", 1, #ATTN_NORM);
				self.building.think = lvl2_sentry_stand;
				//self.building.skin = 1;
				self.building.max_health = floor(225 * HPfactor); //WK 1-7-7 180
				self.building.maxammo_shells = 120 * AMMOfactor;
			}
			else if (self.building.weapon == 3)
			{
				sound (self.building, #CHAN_ITEM, "weapons/turrset.wav", 1, #ATTN_NORM);
				self.building.think = lvl3_sentry_stand;
				//self.building.skin = 2;
				self.building.max_health = floor(300 * HPfactor); //WK 1-7-7 220
				self.building.maxammo_shells = 144 * AMMOfactor;
			}
			//WK 1/15/8 Level 4 Upgrade
			else {
				sound (self.building, #CHAN_ITEM, "weapons/turrset.wav", 1, #ATTN_NORM);
				self.building.think = lvl3_sentry_stand;
				self.building.max_health = floor(400 * HPfactor); //WK 1-7-7 220
				self.building.maxammo_shells = 200 * AMMOfactor;
			}
		
			self.building.health = self.building.max_health;

			sprint(self, #PRINT_HIGH, "You upgrade the Sentry Gun to level ");
			st = ftos(self.building.weapon); 
			sprint(self, #PRINT_HIGH, st);
			sprint(self, #PRINT_HIGH, "\n");
		}
		else if (self.building.weapon == 3 && self.building.frags < 1) {
			sprint(self, #PRINT_HIGH, "Your gun needs to get a frag before you can upgrade it to level 4!\n");
		}
	}
	else if (inp == 3)
	{
		Engineer_RepairSentryGun();
	}
	else if (inp == 5)
	{
		if (CheckEnemyDismantle()==#FALSE) return;

		//RemoveMyTimers(self.building); // psionic clean-up
		
		sprint(self, #PRINT_HIGH, "You dismantle the Sentry Gun.\n");
//CH give .5 of build cost====give 25*level
		self.ammo_cells = self.ammo_cells + (#BUILD_COST_SENTRYGUN / 2) + (self.building.weapon * 25);

#ifdef QUAKE_WORLD
		if (Teammate(self.building.real_owner, self) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "sentry gun");
		}
#endif
		//self.building.real_owner.has_sentry = #FALSE;
		self.building.real_owner.has_sentry = self.building.real_owner.has_sentry - (self.building.real_owner.has_sentry & self.building.dont_do_triggerwork);
		dremove(self.building.trigger_field);
		self.building.health=0; // - OfN aborts hacks on it
		dremove(self.building);
	}
	else if (inp == 6) //WK
	{
		sprint(self, #PRINT_HIGH, "You rotate it clockwise 45 degrees\n");
		
		#ifdef SENTRY_SMOOTHROTATION
		self.building.angles_y = anglemod(self.building.angles_y - 45);
		#else
		self.building.angles_y = anglemod((self.building.waitmax - #SENTRY_ROTATIONWIDTH) - 45);
		#endif

			self.building.angles_y = ((ceil(self.building.angles_y / 10)) * 10); //CH set last int to 0
		
		#ifdef SENTRY_SMOOTHROTATION
		self.building.waitmin = self.building.angles_y - #SENTRY_ROTATIONWIDTH;
		self.building.waitmax = self.building.angles_y + #SENTRY_ROTATIONWIDTH;
		self.building.heat = rint(#SENTRY_ROTATIONSTEPS/2);
		#else
		self.building.waitmin = anglemod(self.building.angles_y - #SENTRY_ROTATIONWIDTH);
		self.building.waitmax = anglemod(self.building.angles_y + #SENTRY_ROTATIONWIDTH);
		self.building.heat = 0;
		#endif
	}
	else if (inp == 7) //WK
	{
		sprint(self, #PRINT_HIGH, "You rotate it counter-clockwise 45 degrees\n");
		
		#ifdef SENTRY_SMOOTHROTATION
		self.building.angles_y = anglemod((self.building.waitmin + #SENTRY_ROTATIONWIDTH) + 45);
		#else
		self.building.angles_y = anglemod(self.building.angles_y + 45);
		#endif
		
			self.building.angles_y = ((ceil(self.building.angles_y / 10)) * 10); //CH set last int to 0
		
		#ifdef SENTRY_SMOOTHROTATION
		self.building.waitmin = self.building.angles_y - #SENTRY_ROTATIONWIDTH;
		self.building.waitmax = self.building.angles_y + #SENTRY_ROTATIONWIDTH;
		self.building.heat = 0;
		#else
		self.building.waitmin = anglemod(self.building.angles_y - #SENTRY_ROTATIONWIDTH);
		self.building.waitmax = anglemod(self.building.angles_y + #SENTRY_ROTATIONWIDTH);
		self.building.heat = 1;
		#endif
	}
	//WK Turret Sentries!
	else if (inp == 8)
	{
		if (self.building.tf_items & #NIT_TURRET) {
			sprint(self, #PRINT_HIGH, "Gun is already deployed\n");
		}
		else if (!(self.tf_items & #NIT_TURRET)) {
			sprint(self, #PRINT_HIGH, "You need to purchase the turret upgrade\n");
		}
		else if (self.ammo_cells < #BUILD_COST_TURRET)
		{
			sprint(self, #PRINT_HIGH, "Creating a turret costs #BUILD_COST_TURRET metal\n");
		}
		else {
			self.building.origin_z = self.building.origin_z + 15; //Elevate for the check
			//Make sure the launch area is clear
			if (CheckArea(self.building,self) == #FALSE) {
				sprint(self, #PRINT_HIGH, "You need a clear area to launch\n"); 	
				self.building.origin_z = self.building.origin_z - 15; //Set back down
			}
			else {
				self.building.origin_z = self.building.origin_z + 25; //Finish liftoff
				sprint(self, #PRINT_HIGH, "You launch the sentrygun\n");
				self.ammo_cells = self.ammo_cells - #BUILD_COST_TURRET;
				self.building.angles_z = 180;
				setmodel(self.building.trigger_field,string_null);
				self.building.trigger_field.solid = #SOLID_NOT;
				self.building.flags = self.building.flags - (self.building.flags & #FL_ONGROUND);
				self.building.movetype = #MOVETYPE_FLY;
				self.building.velocity_z = 200;
				setsize (self.building, '-16 -16 -40', '16 16 -10'); //WK -40, -10
				self.building.tf_items = self.building.tf_items | #NIT_TURRET;
			}
		}
	}
	//WK 1/15/8 New upgrades payable by frags
	else if (inp == 9)
	{
		self.current_menu = #MENU_BUILDING_FRAG_UPGRADE;
		Menu_BuildingFragUpgrade();
		self.impulse = 0;
	}
	if (inp >= 1 && inp <= 8)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}
};

void() Menu_EngineerFix_Sensor =
{
	CenterPrint(self, "Áãôéïî:              \n\n.. Repair Sensor      \n\n.. Îïôèéîç            \n\n.. Dismantle          \n");
}; 
void(float inp) Menu_EngineerFix_Sensor_Input =
{
//*ch
	local float metalcost; //am,
	//local string st;

	if (self.classname != "player" || self.building == world)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 10;

		if (metalcost > self.ammo_cells)
			metalcost = self.ammo_cells;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 10);
	}
	else if (inp == 3)
	{
		if (CheckEnemyDismantle() == #FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)
		
		sprint(self, #PRINT_HIGH, "You dismantle the Motion Sensor.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (#BUILD_COST_SENSOR * 0.5) + floor(self.building.health / 40);
		self.building.real_owner.has_sensor = #FALSE;

#ifdef QUAKE_WORLD
		if (Teammate(self.building.real_owner, self) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "motion sensor");
		}
#endif

		self.building.health=0; // - OfN aborts hacks on it
		dremove(self.building);
	}
	if (inp >= 1 && inp <= 3)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}
};

void() Menu_EngineerFix_Camera =
{
	CenterPrint(self, "Áãôéïî:                \n\n.. Repair Camera      \n\n.. Îïôèéîç            \n\n.. Dismantle          \n");
};
void(float inp) Menu_EngineerFix_Camera_Input =
{
//*ch
	local float metalcost; //am,
	//local string st;

	if (self.classname != "player" || self.building == world)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 10;

		if (metalcost > self.ammo_cells)
			metalcost = self.ammo_cells;

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 10);
	}
	else if (inp == 3)
	{
		if (CheckEnemyDismantle() == #FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)

		sprint(self, #PRINT_HIGH, "You dismantle the Security Camera.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (#BUILD_COST_CAMERA * 0.5) + floor(self.building.health / 40);
		self.building.real_owner.has_camera = #FALSE;

#ifdef QUAKE_WORLD
		if (Teammate(self.building.real_owner, self) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "security camera");
		}
#endif

		self.building.health=0; // - OfN aborts hacks on it
		dremove(self.building);
	}
	if (inp >= 1 && inp <= 3)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}
};

void() Menu_EngineerFix_Teleporter =
{
	if (self.building.classname == "building_teleporter" && (self.building.tf_items & #NIT_TURRET))
	{
		CenterPrint(self, "Áãôéïî:                \n\n.. Repair Teleporter     \n.. Recharge Teleporter   \n\n.. Îïôèéîç               \n\n.. Dismantle             \n");
	}
	else
	{
		CenterPrint(self, "Áãôéïî:                \n\n.. Repair Teleporter     \n.. Recharge Teleporter   \n.. Turretize Teleleporter\n\n.. Îïôèéîç               \n\n.. Dismantle             \n");
	}
};
void(float inp) Menu_EngineerFix_Teleporter_Input =
{
//*ch
	local float metalcost; //am,
	//local string st;

	if (self.classname != "player" || self.building == world)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 5;

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 5);
	}
	else if (inp == 2)
	{
		metalcost = (self.building.maxammo_cells - self.building.ammo_cells);

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);
		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.ammo_cells = self.building.ammo_cells + metalcost;
		if (self.building.ammo_cells > self.building.maxammo_cells)
			self.building.ammo_cells = self.building.maxammo_cells;
	}
	else if (inp == 8)
	{
		if (CheckEnemyDismantle() == #FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)

		sprint(self, #PRINT_HIGH, "You dismantle the Teleporter Pad.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (#BUILD_COST_TELEPORTER * 0.5) + floor(self.building.health / 15);
		self.building.real_owner.has_teleporter = (self.building.real_owner.has_teleporter - 1);

#ifdef QUAKE_WORLD
		if (Teammate(self.building.real_owner, self) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "teleporter");
		}
#endif

		self.building.health=0; // - OfN aborts hacks on it
		dremove(self.building);
	}
	else if (inp == 3 && !(self.building.tf_items & #NIT_TURRET))
	{
		if (self.ammo_cells < #TELEPORTER_TURRETIZE_CELLS_COST)
		{
			sprint(self,#PRINT_HIGH,"You don't have enough cells to turretize the teleporter\n");
			ResetMenu();
			self.impulse = 0;
			return;
		}
		
		sprint(self,#PRINT_HIGH,"You launch the teleporter\n");

		self.ammo_cells = self.ammo_cells - #TELEPORTER_TURRETIZE_CELLS_COST;

		self.building.origin_z = self.building.origin_z + 32;
		self.building.angles_z = 180;

		self.building.flags = self.building.flags - (self.building.flags & #FL_ONGROUND);
		self.building.movetype = #MOVETYPE_FLY;
		self.building.velocity_z = 200;
		setsize (self.building, '-16 -16 -8', '16 16 -4');
		//setsize (self.building, '-16 -16 -48', '16 16 -52');

		self.building.tf_items = self.building.tf_items | #NIT_TURRET;
		//self.building.is_haxxxoring=1;

		ResetMenu();		
		self.impulse = 0;

	}
	
	else if (inp == 10)
	{
		ResetMenu();		
		self.impulse = 0;
		return;
	}
	
	if ((inp >= 1 && inp <= 4) || inp == 8)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}
};

//=========================================================================
// field generator

void() Menu_EngineerFix_FieldGen =
{
	CenterPrint(self, "Áãôéïî:                \n\n.. Repair Field Generator  \n.. Recharge Field Generator\n\n.. Îïôèéîç                 \n\n.. Dismantle               \n");
};
void(float inp) Menu_EngineerFix_FieldGen_Input =
{
	local float metalcost; //am,
	//local string st;

	if (self.classname != "player" || self.building == world)
		return;

	if (inp == 1)
	{
		metalcost = (self.building.max_health - self.building.health) / 5;

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);

		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.health = self.building.health + (metalcost * 5);
	}
	else if (inp == 2)
	{
		metalcost = (self.building.maxammo_cells - self.building.ammo_cells);

		if (metalcost > self.ammo_cells)
			metalcost = ceil(self.ammo_cells);
		self.ammo_cells = self.ammo_cells - metalcost;
		self.building.ammo_cells = self.building.ammo_cells + metalcost;
		if (self.building.ammo_cells > self.building.maxammo_cells)
			self.building.ammo_cells = self.building.maxammo_cells;
	}
	else if (inp == 4)
	{
		if (CheckEnemyDismantle() == #FALSE) return; //- OfN - ICE avoids enemy dismantle (see often.qc)

		sprint(self, #PRINT_HIGH, "You dismantle the Field Generator.\n");
//CH will give you half of cost + max of 20
		self.ammo_cells = self.ammo_cells + (#BUILD_COST_FIELDGEN * 0.5) + floor(self.building.health / 15);
		self.building.real_owner.has_fieldgen = (self.building.real_owner.has_fieldgen - 1);

#ifdef QUAKE_WORLD
		if (Teammate(self.building.real_owner, self) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "field generator");
		}
#endif

		self.building.health=0; // - OfN aborts hacks on it
		dremove(self.building);
	}
	if (inp >= 1 && inp <= 4)
	{
		ResetMenu();		
		self.impulse = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}
};


//CH
string(float num) Return_Colored_Num =
{
	if (num == 0)
		return "";
	else if (num == 1)
		return "";
	else if (num == 2)
		return "";
	else if (num == 3)
		return "";
	else if (num == 4)
		return "";
	else if (num == 5)
		return "";
	else if (num == 6)
		return "";
	else if (num == 7)
		return "";
	else if (num == 8)
		return "";
	else if (num == 9)
		return "";
	else
		return "£"; //Should never happen // OfN - It does when a tesla is in upgrade for frags
};
//Upgrades tesla, type 1=volt 2=amps 3=health 4=spy 5=kevlar 6=blast 7=turret 8=improve 9=cloak
//menu 0=normal 1=misc
float(float ups, entity person, entity sent, float type, float menu) Check_Tesla_Ups =
{
#define UPGRADE 100 //Cells per upgrade //WK 2/8/7 125 
//#define MAXUPGRADES 6
#define MAXCELLS0 50
#define MAXCELLS1 120
#define MAXCELLS2 200
#define MAXCELLS3 300
#define ADDCELLS1 70 //how much to add with upgrade
#define ADDCELLS2 80
#define ADDCELLS3 100
	local float upgrades;

	if (menu == 1)
		upgrades = sent.has_tesla; //misc
	else
		upgrades = sent.has_sentry; //normal
	if (ups > upgrades) {//not enough upgrades
		sprint(person,#PRINT_HIGH,"You do not have enough upgrades to improve the tesla\n");
		return #FALSE;
	}
	if (type == 4 || type == 5) { //Spy detector and frag to upgrade
		if (person.ammo_cells < (ups / 2) * #UPGRADE) {//not enough cells
			sprint(person,#PRINT_HIGH,"You need more cells to upgrade the tesla\n");
			return #FALSE;
		}
	}
	else
	{
		if (person.ammo_cells < ups * #UPGRADE) {//not enough cells
			sprint(person,#PRINT_HIGH,"You need more cells to upgrade the tesla\n");
			return #FALSE;
		}
	}
	if (type ==1)
	{
		if (sent.ammo_shells >= 3) {
			sprint(self,#PRINT_HIGH,"You can only upgrade voltage 3 times\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return #TRUE;
		}
	}
	if (type ==2)
	{
		if (sent.ammo_nails >= 3) {
			sprint(person,#PRINT_HIGH,"You can only upgrade amperage 3 times\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return #TRUE;
		}
	}
	if (type ==3)
	{
		if (sent.ammo_rockets >= 3) {
			sprint(person,#PRINT_HIGH,"You can only upgrade the capacitor 3 times\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return #TRUE;
		}
	}
	if (type ==4)
	{
		if (sent.tf_items & #NIT_AUTOID) {
			sprint(person,#PRINT_HIGH,"You already built a spy detector\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return #TRUE;
		}
	}
	if (type ==5)
	{
		if (sent.tf_items & #NIT_TELEPORTER) {
			sprint(person,#PRINT_HIGH,"You already have the upgrade\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_sentry = sent.has_sentry - ups;
			return #TRUE;
		}
	}
	if (type ==6)
	{
		if (sent.tf_items & #NIT_KEVLAR) {
			sprint(person,#PRINT_HIGH,"The Tesla already has Kevlar Armor\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return #TRUE;
		}
	}
	if (type ==7)
	{
		if (sent.tf_items & #NIT_BLAST) {
			sprint(person,#PRINT_HIGH,"The Tesla already has Blast Armor\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return #TRUE;
		}
	}
	if (type ==8)
	{
		if (sent.tf_items & #NIT_ASBESTOS) {
			sprint(person,#PRINT_HIGH,"The Tesla already has Asbestos Armor\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return #TRUE;
		}
	}
	if (type ==9)
	{
		if (sent.tf_items & #NIT_TURRET) {
			sprint(person,#PRINT_HIGH,"The Tesla is already a turret!\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return #TRUE;
		}
	}
	if (type ==10)
	{
		if (sent.tf_items & #NIT_SCANNER) {
			sprint(person,#PRINT_HIGH,"The Tesla already has an improved targeter\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return #TRUE;
		}
	}
	if (type ==11)
	{
		
		//sprint(person,#PRINT_HIGH,"Not implemented yet!\n");
		//	return #FALSE;
		if (sent.tf_items & #NIT_TESLA_CLOAKING) {
			sprint(person,#PRINT_HIGH,"The Tesla already has a cloaking device\n");
			return #FALSE;
		}
		else {
			self.ammo_cells = self.ammo_cells - (ups * #UPGRADE);
			sent.has_tesla = sent.has_tesla - ups;
			return #TRUE;
		}
	}
	return #FALSE; //Should not happen
	
};

void() Menu_EngineerDismantle_Tesla =
{
	if (!self.building)
		return;

	if (self.building.tf_items & #NIT_SECURITY_CAMERA) { //Crazy Tesla
		sprint(self, #PRINT_HIGH, "You can't dismantle it. It's not that easy!\n");
		return;
	}

	if (CheckEnemyDismantle() == #FALSE) return;

	//RemoveMyTimers(self.building); // psionic clean-up

	sprint(self, #PRINT_HIGH, "You dismantle the Tesla Gun.\n");
//CH give .5 of ammount of build====give 25*health level (0-3)====give .5 of cells
	self.ammo_cells = self.ammo_cells + (#BUILD_COST_TESLA / 2) + (self.building.ammo_rockets * 25) + (self.building.ammo_cells / 2);
	//self.building.real_owner.has_tesla = #FALSE;
	self.building.real_owner.has_tesla = self.building.real_owner.has_tesla - (self.building.real_owner.has_tesla & self.building.dont_do_triggerwork);

#ifdef QUAKE_WORLD
		if (Teammate(self.building.real_owner, self) && teamplay != 0 && self.building.real_owner != self) { //Boot em if they dismantle too many
			Add_Building_Teamkill (self, "tesla");
		}
#endif
	dremove(self.building);
};
//CH does random and picks what upgrade to give
void(entity sent, entity who) Tesla_Add_Rand_Upgrade =
{
	local float num;
	num = random();
	if (num <= 0.8) //give them a normal upgrade
	{
		sprint(who,#PRINT_HIGH,"The tesla got a normal upgrade!\n");
		sent.has_sentry = sent.has_sentry + 1;
	}
	else
	{
		sprint(who,#PRINT_HIGH,"The tesla got a misc upgrade!\n");
		sent.has_tesla = sent.has_tesla + 1;
	}
};
void() Menu_EngineerFix_Tesla =
{
	local string l1,l2;

	l1 = Return_Colored_Num(self.building.has_sentry);
	l2 = ".. Upgrade Voltage           ­ 1u\n.. Upgrade Amperage          ­ 1u\n.. Upgrade Power Supply      ­ 1u\n.. Add Spy Detector          ­ 4u\n.. Upgrades from frags       ­ 3u\n.. Tinker                        \n.. Repair and Recharge           \n.. Dismantle                     \n.. Îïôèéîç                       \n\n.. Misc Upgrades  \n";
	
	  CenterPrint4(self, "Tesla Íïäéæéãáôéïî Ìáâ: ",l1, " Upgrades Left\n\nžžžžžžŸ Normal Tesla Upgrades žžžžžžŸ\n\n" ,l2);

};
void(float inp) Menu_EngineerFix_Tesla_Input =
{
	if (self.classname != "player" || self.building == world)
		return;

	if (inp <= 10 && inp >= 1)
	{
	if (self.building.real_owner != self && (inp < 7 || inp == 10) ) {
		sprint(self,#PRINT_HIGH,"Sorry, only the owner can do that\n");
		return;
	}
		
	if (inp == 1) { //Upgrade volt
		if (Check_Tesla_Ups(1, self, self.building, 1, 0))
		{
			self.building.ammo_shells = self.building.ammo_shells + 1;
			self.building.waitmin = (self.building.ammo_shells + 2) * (self.building.ammo_nails + 2); //Ammo consumption
		}
	}
	if (inp == 2) { //Upgrade amperage
		if (Check_Tesla_Ups(1, self, self.building, 2, 0))
		{
			self.building.ammo_nails = self.building.ammo_nails + 1;
			self.building.waitmin = (self.building.ammo_shells + 2) * (self.building.ammo_nails + 2); //Ammo consumption
		}
	}
	if (inp == 3) { //Upgrade power supply
		if (Check_Tesla_Ups(1, self, self.building, 3, 0))
		{
			local float HPfactor,num,AMMOfactor;
			if (self.building.all_active & #IMPROVED_THREE)
				HPfactor=1.5; //WK 1-7-7 Toned down hacking, 2
			else
				HPfactor=1;
			
			if (self.building.all_active & #IMPROVED_ONE)
				AMMOfactor=2;
			else
				AMMOfactor=1;			 

			num=self.building.health/self.building.max_health;

			self.building.ammo_rockets = self.building.ammo_rockets + 1;
			//Upgrade them //- OfN - teslas start with 150 hp
			if (self.building.ammo_rockets == 1) {
				//self.building.max_health = self.building.max_health + 75; // 225
				self.building.max_health = floor(225*HPfactor);
				//self.building.health = self.building.health + 75;
				self.building.maxammo_cells = (#MAXCELLS0 + #ADDCELLS1) * AMMOfactor;
				self.building.ammo_cells = self.building.maxammo_cells;
			}
			else if (self.building.ammo_rockets == 2) {
				//self.building.max_health = self.building.max_health + 100;// 325
				self.building.max_health = floor(325*HPfactor);// 325
				//self.building.health = self.building.health + 100;
				//self.building.maxammo_cells = self.building.maxammo_cells + #ADDCELLS2; //Add
				self.building.maxammo_cells = (#MAXCELLS0 + #ADDCELLS1 + #ADDCELLS2)*AMMOfactor;
				self.building.ammo_cells = self.building.maxammo_cells;
			}
			else if (self.building.ammo_rockets == 3) {
				//self.building.max_health = self.building.max_health + 75; // 400
				self.building.max_health = floor(400*HPfactor); // 400
				//self.building.health = self.building.health + 75;
				self.building.maxammo_cells = (#MAXCELLS0 + #ADDCELLS1 + #ADDCELLS2 + #ADDCELLS3)*AMMOfactor; //Add
				self.building.ammo_cells = self.building.maxammo_cells;
			}

			self.building.health=self.building.max_health*num;
		}
	}
	if (inp == 4) { //Spy Detector
		if (Check_Tesla_Ups(4, self, self.building, 4, 0))
		{
			self.building.tf_items = self.building.tf_items | #NIT_AUTOID;
		}
	}
	if (inp == 5) { //CH Get frags for upgrades
		if (Check_Tesla_Ups(3, self, self.building, 5, 0))
		{
			self.building.tf_items = self.building.tf_items | #NIT_TELEPORTER;
		}
	}
	if (inp == 6){ // Tinker by Cyt0  Remade by CH to fit with new code
		if (self.building.tf_items & #NIT_TELEPORTER) //- ofn - workaround to solve the HP/cells increase by tinker combined with the hack
		{
			sprint(self,#PRINT_HIGH,"You can't tinker a tesla in upgrade from frags mode!\n");			  
		}
		else
		{
			DoTinker();
		}
	}
	if (inp == 7) { //Repair and Rearm
		Engineer_RepairTesla();
	}
	if (inp == 8) {
		Menu_EngineerDismantle_Tesla();
	}
//	if (inp == 9) {
//	}
	if (inp == 10) {
		self.impulse = 0;
		Menu_EngineerFix_Tesla2();
		self.current_menu = #MENU_ENGINEER_FIX_TESLA2;
		CuTFMenuSound(#MENUSOUND_BROWSE);
	}

	if (inp >= 1 && inp <= 9)
	{
		ResetMenu();		
		self.impulse = 0;

		if (self.ammo_cells < 0) self.ammo_cells = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}
	}
};
void() Menu_EngineerFix_Tesla2 =
{
	local string l1,l2;

	l1 = Return_Colored_Num(self.building.has_tesla);
	//l2 = ".. Cloaking Tesla            ­ 2u";
	l2 = ".. Kevlar Armor              ­ 1u\n.. Blast Armor               ­ 1u\n.. Asbestos Armor            ­ 1u\n.. Make TeslaTurret(tm)      ­ 1u\n.. Improved Targeting System ­ 1u\n.. Cloaking Device           ­ 1u\n.. Repair and Recharge           \n.. Dismantle                     \n.. Îïôèéîç                       \n\n.. Normal Upgrades\n";
	//l2 = ".. Kevlar Armor              ­ 1u\n.. Blast Armor               ­ 1u\n.. Asbestos Armor            ­ 1u\n.. Make TeslaTurret(tm)      ­ 1u\n.. Improved Targeting System ­ 1u\n\n.. Repair and Recharge           \n.. Dismantle                     \n.. Îïôèéîç                       \n\n.. Normal Upgrades\n";
	CenterPrint4(self, "Tesla Íïäéæéãáôéïî Ìáâ: ",l1, " Upgrades Left\n\n€‚ Misc Tesla Upgrades €‚\n\n" ,l2);
};
void(float inp) Menu_EngineerFix_Tesla_Input2 =
{
	//local string temp;
	//local float cost = 0;
	//local float maxcells;
	if (self.classname != "player" || self.building == world)
		return;

	if (inp <= 10 && inp >= 1)
	{
	if (inp == 1) { //Kevlar
		if (Check_Tesla_Ups(1, self, self.building, 6, 1))
		{
			self.building.tf_items = self.building.tf_items | #NIT_KEVLAR;
			self.building.armorclass = self.building.armorclass | #AT_SAVESHOT;
		}
	}
	if (inp == 2) { //Blast
		if (Check_Tesla_Ups(1, self, self.building, 7, 1))
		{
			self.building.tf_items = self.building.tf_items | #NIT_BLAST;
			self.building.armorclass = self.building.armorclass | #AT_SAVEEXPLOSION;
		}
	}
	if (inp == 3) { //Blast
		if (Check_Tesla_Ups(1, self, self.building, 8, 1))
		{
			self.building.tf_items = self.building.tf_items | #NIT_ASBESTOS;
			self.building.armorclass = self.building.armorclass | #AT_SAVEFIRE;
		}
	}
	if (inp == 4) { //Tesla Turret(tm)
		
		if (Check_Tesla_Ups(1, self, self.building, 9, 1))
		{
			if (self.building.tf_items & #NIT_TURRET) {
				sprint(self, #PRINT_HIGH, "Gun is already deployed\n");
			}
			else {
				self.building.origin_z = self.building.origin_z + 15; // +15//Elevate for the check
				//Make sure the launch area is clear
				if (#FALSE) {
				//if (CheckArea(self.building,self) == #FALSE) {
					sprint(self, #PRINT_HIGH, "You need a clear area to launch\n"); 	
					self.building.origin_z = self.building.origin_z - 15; //-15//Set back down
				}
				else {
					//self.building.origin_z = self.building.origin_z + 25; //+ 25 //Finish liftoff
					self.building.origin_z = self.building.origin_z - 35;//- 25;//40;//- 25; //often fixes tesla not touchin ceiling//+ 25 //Finish liftoff
					sprint(self, #PRINT_HIGH, "You turretize the tesla\n");

					if (self.building.job == 1 && self.building.tf_items & #NIT_TESLA_CLOAKING)
					{	 
						local entity TSelf, OSelfB;
						OSelfB=self.building;
						TSelf=TeslaClone(OSelfB);
						dremove(OSelfB);
						self.building=TSelf; // NEEDED? teslaclone should have updated this pointer anyway..						
 
						spawnFOG(self.building.origin);
						sound (self.building, #CHAN_MISC, "misc/r_tele4.wav", 1, #ATTN_NORM);
					}	 
					
					self.building.angles_z = 180;
					self.building.flags = self.building.flags - (self.building.flags & #FL_ONGROUND);
					self.building.movetype = #MOVETYPE_FLY;
					self.building.velocity_z = 200;
					setsize (self.building, '-16 -16 10', '16 16 40');//35');//'-16 -16 -40', '16 16 -10'); //WK -40, -10
					self.building.tf_items = self.building.tf_items | #NIT_TURRET;
					self.building.is_haxxxoring=1; //flag determines if flying and it's used for cloaking teslas, set to 0 when landed
					
				}
			}
		}
	}
	if (inp == 5) { //Improved Targeter
		if (Check_Tesla_Ups(1, self, self.building, 10, 1))
		{
			self.building.tf_items = self.building.tf_items | #NIT_SCANNER;
		}
	}
//CH its commented out here and in the centerprint - OfN nomore!
	if (inp == 6) { //Cloaking tesla
		if (Check_Tesla_Ups(1, self, self.building, 11, 1))
		{
			self.building.tf_items = self.building.tf_items | #NIT_TESLA_CLOAKING;
			if (self.building.job == 1)
			{
				local entity oself;
				oself=self;
				self=self.building;
				self.job=3; //- OfN - this flag indicates it must skip condition on lose_glow
				Tesla_Lose_Glow();
				self=oself;
			}
		}
	}

	if (inp == 7) { //Repair and Rearm
		Engineer_RepairTesla();
	}
	if (inp == 8) {
		Menu_EngineerDismantle_Tesla();
	}
//	if (inp == 9) {
//	}
	if (inp == 10) {
		self.impulse = 0;
		Menu_EngineerFix_Tesla();
		self.current_menu = #MENU_ENGINEER_FIX_TESLA;
		CuTFMenuSound(#MENUSOUND_BROWSE);
	}

	if (inp >= 1 && inp <= 9)
	{
		ResetMenu();		
		self.impulse = 0;

		if (self.ammo_cells < 0) self.ammo_cells = 0;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}
	}
};

//============================================================================
// Menu for using buildings
void() Menu_Dispenser =
{
	if (self.classname != "player" || self.building == world || self.building.classname != "building_dispenser")
		return;
		
	if (self.building.all_active & #IMPROVED_FOUR)
	{
		local string st, st2, st3, st4;
		
		st = "Õóå Äéóðåîóåò:              \n\n.. Withdraw some ammo          \n.. Withdraw some Armor         \n\n";
		
		if (self.maxammo_detpack > 0) 
			st2 = ".. Get detpack                 \n";
		else st2 = "\n";

		if (self.cutf_items & #CUTF_TOSSABLEDET )
			st3 = ".. Get C4 detpack              \n";
		else st3 = "\n";

		st4 = ".. Get medikit                 \n\n.. Îïôèéîç                     \n\n";

		CenterPrint4(self, st, st2, st3, st4);
	}
	else
		CenterPrint(self, "Õóå Äéóðåîóåò:             \n\n.. Withdraw some ammo          \n.. Withdraw some armor         \n\n.. Îïôèéîç                     \n\n");
};

float(entity doc, entity patient, vector org) CureAdverseEffects;

void(float inp) Menu_Dispenser_Input =
{
	if (self.classname != "player" || self.building == world)
		return;
	
	local float am, empty;

	empty = #FALSE;
	if (inp == 1)
	{
		if (self.building.ammo_shells == 0 && self.building.ammo_nails == 0 && 
			self.building.ammo_rockets == 0 && self.building.ammo_cells == 0)
		{
			empty = #TRUE;
		}
		else
		{
			local float anydone; // OfN - To determine if sound should be played
			local string tmpstr;
			anydone = #FALSE;

			// shells
			am = self.maxammo_shells - self.ammo_shells;
			if (am > self.building.ammo_shells)
				am = self.building.ammo_shells; 
			self.building.ammo_shells = self.building.ammo_shells - am;
			self.ammo_shells = self.ammo_shells + am;

			if (am > 0)
			{
				anydone = #TRUE;
				tmpstr = ftos(floor(am));
				sprint(self,#PRINT_LOW,"You get ",tmpstr," shells.\n");
			}

			// nails
			am = self.maxammo_nails - self.ammo_nails;
			if (am > self.building.ammo_nails)
				am = self.building.ammo_nails; 
			self.building.ammo_nails = self.building.ammo_nails - am;
			self.ammo_nails = self.ammo_nails + am;

			if (am > 0)
			{
				anydone = #TRUE;
				tmpstr = ftos(floor(am));
				sprint(self,#PRINT_LOW,"You get ",tmpstr," nails.\n");
			}

			// rockets
			am = self.maxammo_rockets - self.ammo_rockets;
			if (am > self.building.ammo_rockets)
				am = self.building.ammo_rockets; 
			self.building.ammo_rockets = self.building.ammo_rockets - am;
			self.ammo_rockets = self.ammo_rockets + am;

			if (am > 0)
			{
				anydone = #TRUE;
				tmpstr = ftos(floor(am));
				sprint(self,#PRINT_LOW,"You get ",tmpstr," rockets.\n");
			}

			// cells
			am = self.maxammo_cells - self.ammo_cells;
			if (am > self.building.ammo_cells)
				am = self.building.ammo_cells; 
			self.building.ammo_cells = self.building.ammo_cells - am;
			self.ammo_cells = self.ammo_cells + am;

			if (am > 0)
			{
				anydone = #TRUE;
				tmpstr = ftos(floor(am));
				sprint(self,#PRINT_LOW,"You get ",tmpstr," cells.\n");
			}

			// SB gren1s
			local float grenammo;
			grenammo = GetMaxGrens(self,1);

			am =  grenammo - self.no_grenades_1;
			if (am*15 > self.building.ammo_rockets)
				am = floor(self.building.ammo_rockets / 15);
			self.building.ammo_rockets = self.building.ammo_rockets - am * 15;
			self.no_grenades_1 = self.no_grenades_1 + am;

			if (am > 0)
			{
				anydone = #TRUE;
				tmpstr = ftos(floor(am));
				local string desc;
				desc = GetGrenadeText(self.tp_grenades_1);
				sprint(self,#PRINT_LOW,"You get ",tmpstr," ",desc," grenades.\n");
			}

			// SB gren2s
			grenammo = GetMaxGrens(self,2);

			am =  grenammo - self.no_grenades_2;
			if (am*15 > self.ammo_rockets)
				am = floor(self.ammo_rockets / 15);
			self.building.ammo_rockets = self.building.ammo_rockets - am * 15;
			self.no_grenades_2 = self.no_grenades_2 + am;

			if (am > 0)
			{
				anydone = #TRUE;
				tmpstr = ftos(floor(am));
				local string desc;
				desc = GetGrenadeText(self.tp_grenades_2);
				sprint(self,#PRINT_LOW,"You get ",tmpstr," ",desc," grenades.\n");
			}

			if (anydone)
				sound(self.building,#CHAN_MISC,"weapons/lock4.wav",1,#ATTN_IDLE);
		}
	}
	else if (inp == 2)
	{
		if (self.building.is_malfunctioning & #SCREWUP_FOUR)
		{	
			sprint(self,#PRINT_HIGH,"Trapped dispenser, have a nice day!\n");
			TF_T_Damage(self.building, self.building, self.building, 500, 0, #TF_TD_OTHER);
			return;
		}
			
		if (self.building.armorvalue == 0)
		{
			empty = #TRUE;
		}
		else
		{
			// armor
			am = self.maxarmor - self.armorvalue;
			if (am > self.building.armorvalue)
				am = self.building.armorvalue; 

			if (self.armortype == 0)
			{
				self.armortype = self.armor_allowed;
				//self.items = self.items | #IT_ARMOR1;
				W_SetCurrentAmmo();
			}

			self.building.armorvalue = self.building.armorvalue - am;
			self.armorvalue = self.armorvalue + am;

			if (am > 0)
			{
				sound(self.building,#CHAN_MISC,"items/armor1.wav",1,#ATTN_IDLE);
				sprint(self,#PRINT_LOW,"You get some armor.\n");
			}
		}
	}
	else if (inp == 3 && self.maxammo_detpack > 0)
	{
		if (self.building.ammo_detpack < 1)
		{
			empty = #TRUE;
		}
		else
		{			 
			// detpacks
			am = floor(self.maxammo_detpack - self.ammo_detpack);
			if (am > floor(self.building.ammo_detpack))
				am = floor(self.building.ammo_detpack); 
			self.building.ammo_detpack = self.building.ammo_detpack - am;
			self.ammo_detpack = self.ammo_detpack + am;

			if (am < 1)
				sprint(self,#PRINT_HIGH,"You can not carry more detpacks!\n");
		}
	}
	else if (inp == 4 && self.cutf_items & #CUTF_TOSSABLEDET)
	{
		if (self.building.ammo_c4det < 1)
		{
			empty = #TRUE;
		}
		else
		{			 
			// detpacks
			am = floor(self.maxammo_detpack - self.ammo_c4det);
			if (am > floor(self.building.ammo_c4det))
				am = floor(self.building.ammo_c4det); 
			self.building.ammo_c4det = self.building.ammo_c4det - am;
			self.ammo_c4det = self.ammo_c4det + am;
	
			if (am < 1)
				sprint(self,#PRINT_HIGH,"You can not carry more Ã detpacks!\n");
		}
	}
	else if (inp == 5 && self.building.all_active & #IMPROVED_FOUR)
	{		 
		if (self.building.ammo_medikit < #DISPENSER_MEDIKIT_MINIMUM) // OfN minimum
		{
			empty = #TRUE;
		}
		else
		{			 
			CureAdverseEffects(self,self, self.origin);
			
			am = floor(self.max_health - self.health);
			
			if (am > floor(self.building.ammo_medikit))
				am = floor(self.building.ammo_medikit); 
			
			if (am >= 1)
			{
				T_Heal(self, am, #FALSE);
				sound(self, #CHAN_WEAPON, "items/r_item1.wav", 1, #ATTN_NORM);
				sprint(self,#PRINT_LOW,"You get some medikit.\n");
			}

			self.building.ammo_medikit = self.building.ammo_medikit - am;
			
		}
	}

	if (inp >= 1 && inp <= 5)
	{
		if (empty)
		{
			if (inp == 5)
				sprint(self, #PRINT_HIGH, "Not enough medikit on dispenser.\n");
			else
				sprint(self, #PRINT_HIGH, "The dispenser is empty.\n");
		}
		ResetMenu();		
		self.impulse = 0;
		self.building = world;
		self.building_wait = time + 0.5;

		bound_other_ammo(self);

		if (self.armorvalue == 0)
		{
			self.armortype = 0; // lost all armor
			self.armorclass = 0; // lost special armor
			self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
		}

		W_SetCurrentAmmo();
	}

	if (inp == 10)
	{
		ResetMenu();
		self.impulse = 0;
	}

	// Otherwise, the impulse is passed on
};

void() MenuResetCount =
{
	self.menu_count = 0;
	self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_NOTENOUGHMONEY);
};
