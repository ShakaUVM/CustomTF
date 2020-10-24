/*=======================================================//
// cmnd.QC - CustomTF 3.2.OfN			   - 18/3/2004 - //
// by Sergio FumaÒa Grunwaldt - OfteN [cp]				 //
=========================================================//
 Client Command stuff - Requires PROZAC qwsv
=========================================================//
 This is a giant command system that expands the possible
 commands from users without using aliases, neither
 having almost any limitation.
 --------------------------------------------------------
 Our server code will call ClientCommand() function with
 the appropiate arguments set after a client enters
 any command in console with the "cmd" prefix.
=========================================================*/

// Flags

// Settings

#define CMD_MSGRATE 0.4  // Minimum delay to occur between error and help prints
#define CMD_MAX_ADMINATTEMPTS 5 // Maximum times a client is allowed to attempt admin password
#define CMD_MAX_MAPREQUESTS 5 // Maximum custom map requests

#define MAX_SNAME_LEN 24 // WARNING: Our qwsv max for perm strings is 32 chars

#define SECS_SNAMECHANGE_THRES 15
#define NUM_SNAMECHANGE_THRES 3
#define TIME_SNAME_INHIBITED 30

#define CMD_DEFAULT_MUTE_TIME 20
#define CMD_DEFAULT_CUFF_TIME 10

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

For player entity:
------------------

.option2		- Controls the flow of messages displayed to client (some messages skip this check)
.ex_skill_max	- Controls the flow of client commands (avoids multiple commands to be executed)
.ex_skill_min	- Counter of the times the user attempted to be admin by supplying a bad password
.t_s_h; 		- Monster 1 name string (string using permanent buffer) (#sname1)
.t_s_m; 		- Monster 2 name string (string using permanent buffer) (#sname2)
.t_s_c; 		- Monster 3 name string (string using permanent buffer) (#sname3)
.increase_team1 - Holds number of custom map voting requests this user have made
.increase_team2 - Number of monster name changes this user has performed consecutively
.increase_team3 - Time of silent monster name changes for user or time of last change

================================================================================================

 Commands Structure:
 -------------------

help
  (command)

admin
  login passsword
  logout
  online (shows logged admins)
  tell

  // the following are only accessible by a current admin
  ceasefire [1/on|0/off] (if no argument, just toggle)
  get [user]  
  kick [user]
  ban [user] 
  mute [user [time]]
  curse [user]
  team 1|2|3|4 [user]
  cmnd "command/s" [user]
  TODO: getalias

  // exist but never shown on help, even if an admin
  debug
  infos
  daylight
  storm
  earthquake
  daytime
  runes
  killstuff
  endgame
  silence

  stuff
	makefree ITEM PAGE|all
	delfree ITEM PAGE|all
	disable ITEM PAGE|all
	enable ITEM PAGE|all

vote
  map xxxxxx
	neo // Neo mode
	agr // PZ - Attackers Go Red mode
  nextmap xxxx
	neo // Neo mode
	agr // PZ
  kick xxxxx
  curse xxxx
  ban xxxxx
  mute xxxx

Cheater xxxxx "reasons for accusing.."

game
	//summon xxxxx
	sname x monstername
	build xxxxxxx
	fgens [1/on|0/off] (if no argument just toggle)
	//det x
	//disguise x
	//spyskin x
	drop
		items
		runes
		rune x
		cells x
		rockets x
		nails x
		shells x	

==========================================================================================*/

float(string mapstr) validatemap;
float(float itemnum, float page, float permanent) DisableItem;
float(float itemnum, float page, float permanent) EnableItem;

float(float itemnum,float page, float permanent) MakeFree;
float(float itemnum,float page, float permanent) DelFree;

// External functions
void(float oldrunes) UpdateRuneStuff;
float(entity player, float runenum) DropSpecificRune;

//======================================================================================
// The following is used to crash the server, yeah
// I wanted to see server crashing with ents >512 error to test crash logging on qwsv

#ifdef CRASH_TEST
void() CrashThink =
{
	newmis = spawn();
	self.nextthink = time + 0.1;
};

void() StartCrash =
{
	local entity ent;
	ent = spawn();
	ent.think = CrashThink;
	ent.nextthink = time + 0.1;
};
#endif

//====================================================================================
// To avoid problems, error and help messages on client commands have a limited rate

void(string text) CmdMsg =
{
	if (self.option2 > time)
		return;

	self.option2 = time + #CMD_MSGRATE;
	sprint(self,#PRINT_HIGH,text);
};

// Possible help command requests:

#define CMDHELP_DEFAULT 			0 // displays all avaliable commands
	
#define CMDHELP_ADMIN				1 // admin commands
	// Any player allowed admin commmands
	#define CMDHELP_ADMIN_LOGIN 	2
	#define CMDHELP_ADMIN_LOGOUT	3
	#define CMDHELP_ADMIN_ONLINE	4
	#define CMDHELP_ADMIN_TELL		5
	// Admin-only allowed admin commmands
	#define CMDHELP_ADMIN_CEASEFIRE 16
	#define CMDHELP_ADMIN_GET		17
	#define CMDHELP_ADMIN_KICK		18
	#define CMDHELP_ADMIN_BAN		19
	#define CMDHELP_ADMIN_MUTE		20
	#define CMDHELP_ADMIN_CUFF		21
	#define CMDHELP_ADMIN_CURSE 	22
	#define CMDHELP_ADMIN_TEAM		23
	#define CMDHELP_ADMIN_CMND		24
	#define CMDHELP_ADMIN_ENDGAME	25
	#define CMDHELP_ADMIN_CHECK 	26

// Voting
#define CMDHELP_VOTE				32
	#define CMDHELP_MAP 			33
	#define CMDHELP_NEXTMAP 		34
	#define CMDHELP_KICK			35
	#define CMDHELP_BAN 			36
	#define CMDHELP_MUTE			37
	#define CMDHELP_CURSE			38
	#define CMDHELP_CUFF			39

// Misc
#define CMDHELP_CHEATER 			64

// Game commands
#define CMDHELP_GAME				128
	#define CMDHELP_BUILD			129
//	  #define CMDHELP_SUMMON		  130
	#define CMDHELP_SNAME			131
	#define CMDHELP_DROP			132

// Special commands
#define CMDHELP_SPECIAL 			160
	#define CMDHELP_GETLIT			161


//=========================================================================
// Displays help about specific command or subcommand

void(string cmdstr, string helpstr, string cmdlist, string finalstr) CmdHelpParse =
{
	local string xstr;

	xstr = "";

	if (cmdstr != "")
	{
		xstr = strcat("Command ¢",cmdstr);
		xstr = strcat(xstr,"¢ description:\n");
	}

	xstr = strcat(xstr,helpstr);

	if (cmdlist != "")
	{
		xstr = strcat(xstr,"[");
		cmdlist = colstr(cmdlist,#COLSTR_RED);
		xstr = strcat(xstr,cmdlist);
		xstr = strcat(xstr,"]\n");
	}

	if (finalstr != "")
	{
		xstr = strcat(xstr,finalstr);
	}

	CmdMsg(xstr);
};

#define CMDS "Help Game Vote Admin Special Cheater"
#define CMDS_ADMIN_ADMIN "LogOut OnLine Get Team Kick Ban Mute Cuff CeaseFire"
#define CMDS_ADMIN_USER "OnLine Tell LogIn LogOut"
#define CMDS_BUILD "Sentry Tesla Camera Sensor Teleporter Dispenser FieldGen"
#define CMDS_GAME "Drop SName Build" // summon
#define CMDS_VOTE "Map NextMap Kick Ban Mute Curse Cuff"
#define CMDS_SPECIAL "GetLit GetSky GetHRT"

void(float command) CmdHelp =
{
	if (command == #CMDHELP_DEFAULT)
		CmdHelpParse("","Possible client commands are∫\n",#CMDS,"To get help on specific commands just type ¢cmd help COMMAND¢\n");
	else if (command == #CMDHELP_BUILD)
		CmdHelpParse("Build","Builds an item if you are able to, possible items are:\n",#CMDS_BUILD,"");
	/*else if (command == #CMDHELP_SUMMON)
		CmdMsg("Command ¢Summon¢ Description∫\nSummons a monster or teleports a soldier if you are able to, the parameter for this command should be one of:\n(”„Ú·Á –ÈÚ·ÓË· ∆ÈÂÓ‰ ”Ë·Ì‚ÏÂÚ ”ÔÏ‰ÈÂÚ)\n");
	*/
	else if (command == #CMDHELP_ADMIN)
	{
		if (self.admin_flag)
			CmdHelpParse("Admin","Performs several admin actions, this command requires a subcommand to be one of:\n",#CMDS_ADMIN_ADMIN,"");
		else
			CmdHelpParse("Admin","Admin related actions, this command requires a subcommand to be one of:\n",#CMDS_ADMIN_USER,"You must log in to use the other admin commands.\n");
	}
	else if (command == #CMDHELP_ADMIN_LOGIN)
		CmdHelpParse("LogIn","Logs in as an administrator, you must supply a valid password.\n","","");
	else if (command == #CMDHELP_ADMIN_LOGOUT)
		CmdHelpParse("LogOut","Logs out as an administrator.\n","","");
	else if (command == #CMDHELP_ADMIN_ONLINE)
		CmdHelpParse("OnLine","Displays list of current admins that logged on server.\n","","");
	else if (command == #CMDHELP_ADMIN_TELL)
		CmdHelpParse("Tell","Tells a private message to all admins logged on server, if any.\nSyntax∫ cmd admin tell \"message to admins\"\n","","");
	else if (command == #CMDHELP_ADMIN_CEASEFIRE)
		CmdHelpParse("CeaseFire","Forces a ceasefire on the server, players will not be able to attack until ceasefire ends.\nSyntax∫ cmd admin ceasefire [on|off]\n","","");
	else if (command == #CMDHELP_ADMIN_TEAM)
		CmdHelpParse("Team","Assign given player to the specified team.\nSyntax∫ cmd admin team n [user]\n","","");
	else if (command == #CMDHELP_ADMIN_CMND)
		CmdHelpParse("Cmnd","Executes given commands for the currently selected or specified client.\nSyntax∫ cmd admin cmnd \"commands\" [user]\n","","");
	else if (command == #CMDHELP_ADMIN_GET)
		CmdHelpParse("Get","Tries to select the given client as target for admin actions, if no parameter is supplied just cycles thru possible clients.\nSyntax∫ cmd admin get [user]\n","","");
	else if (command == #CMDHELP_ADMIN_KICK)
		CmdHelpParse("Kick","Kicks given client, if none specified, currently selected one.\nSyntax∫ cmd admin kick [user]\n","","");
	else if (command == #CMDHELP_ADMIN_BAN)
		CmdHelpParse("Ban","Bans given client from server, if none is specified uses currently selected one.\nSyntax∫ cmd admin ban [user]\n","","");
	else if (command == #CMDHELP_ADMIN_MUTE)
		CmdHelpParse("Mute","Mutes a client, if none is specified uses currently selected one.\nSyntax∫ cmd admin mute [user [time]]\n","","");
	else if (command == #CMDHELP_ADMIN_CUFF)
		CmdHelpParse("Cuff","Cuffs a client for the specified time.\nSyntax∫ cmd admin cuff [user [time]]\n","","");
	else if (command == #CMDHELP_ADMIN_CURSE)
		CmdHelpParse("Curse","Curses given player, if none is specified uses currently selected one.\nSyntax∫ cmd admin curse [user]\n","","");
	else if (command == #CMDHELP_ADMIN_ENDGAME)
		CmdHelpParse("EndGame","Ends the current map.\n","","");
	else if (command == #CMDHELP_ADMIN_CHECK)
		CmdHelpParse("Check","Prints information about the specified client.\n","","");
	else if (command == #CMDHELP_CHEATER)
		CmdHelpParse("Cheater","Accuses given player of cheating, warning other users and logging it on server.\nSyntax∫ cmd cheater (user) [\"Reasons for accusation\"]\n","","");
	else if (command == #CMDHELP_VOTE)
		CmdHelpParse("Vote","Commands for starting several kind of votes.\nAvaliable vote types are:\n",#CMDS_VOTE,"");
	else if (command == #CMDHELP_MAP)
		CmdHelpParse("Map","Starts voting for a switch to the specified map.\nSyntax∫ cmd vote map (MapName) [neo] [agr]\n","",""); // PZ - added AGR and Neo mode
	else if (command == #CMDHELP_NEXTMAP)
		CmdHelpParse("NextMap","Suggests the specified map as next map.\nSyntax∫ cmd vote nextmap (MapName) [neo] [agr]\n","",""); // PZ - added AGR and Neo mode
	else if (command == #CMDHELP_KICK)
		CmdHelpParse("Kick","Proposes to kick the specified user from server.\nSyntax∫ cmd vote kick (user)\n","","");
	else if (command == #CMDHELP_CURSE)
		CmdHelpParse("Curse","Proposes to curse the specified player.\nSyntax∫ cmd vote curse (user)\n","","");
	else if (command == #CMDHELP_BAN)
		CmdHelpParse("Ban","Proposes to ban the specified user from server.\nSyntax∫ cmd vote ban (user)\n","","");
	else if (command == #CMDHELP_MUTE)
		CmdHelpParse("Mute","Proposes to mute the specified client.\nSyntax∫ cmd vote mute (user)\n","","");
	else if (command == #CMDHELP_CUFF)
		CmdHelpParse("Cuff","Proposes to cuff the specified player.\nSyntax∫ cmd vote cuff (user)\n","","");
	else if (command == #CMDHELP_GAME)
		CmdHelpParse("Game","Several in-game related commands.\nAvaliable commands are:\n",#CMDS_GAME,"");
	else if (command == #CMDHELP_SNAME)
		CmdHelpParse("SName","Displays or changes the custom names for summons and army soldiers.\nSyntax∫ cmd game sname n [\"CustomName\"]\n","","");
	else if (command == #CMDHELP_DROP)
		CmdHelpParse("Drop","Drops items, runes or ammo. Depending on what to be dropped a number should be specified.\nSyntax∫ cmd game drop (items|runes|rune n|shells n|nails n|rockets n|cells n)\n","","");
	else if (command == #CMDHELP_SPECIAL)
		CmdHelpParse("Special","Several special actions, a subcommand must be one of:\n",#CMDS_SPECIAL,"");
	else if (command == #CMDHELP_GETLIT)
		CmdHelpParse("GetLit","Attempts to download a coloured lighting file for current map, if it exists.\n","","");
};

//========================================================================
// Reports a bad argument error

void(string text1, string badarg, string text2) CmdBadArg =
{
	local string tmp;

	tmp = strcat(text1, badarg);
	tmp = strcat(tmp,text2);

	CmdMsg(tmp);
};

//========================================================================
// Reports an invalid string as target client for admin or vote command

void(string text) CmdClientErr =
{
	sprint(self,#PRINT_HIGH,"Can't find an unique match for ¢");
	sprint(self,#PRINT_HIGH,text);
	sprint(self,#PRINT_HIGH,"¢!\nYou must specify an user ID or name substring.\n");	
};

//==============================================================
// Returns TRUE if self should be able to start a map vote

float() HisMapVoteAllowed =
{	 
	if (self.goal_no > time)
	{
		CmdMsg("You just have ran a vote!\n");
		return #FALSE;
	}

	if (current_voteent != world)
	{
		CmdMsg("Already running a vote!\n");
		return #FALSE;
	}

	if (time/60 < #MIN_MINUTES_TOVOTEMAP)
	{
		CmdMsg("Too early for a map change!\n");
		return #FALSE;
	}

	if (ServerUpdating())
	{
		CmdMsg("Server update is taking place, no map changes are allowed!\n");
		return #FALSE;
	}

	return #TRUE;
};

//==============================================================
// Returns TRUE if self has a "punisheable" valid client

float() HisPunishmentAllowed =
{	 
	if (self.goal_no > time)
	{
		CmdMsg("You just have ran a vote!\n");
		return #FALSE;
	}
	else if (current_voteent != world)
	{
		CmdMsg("Already running a vote!\n");
		return #FALSE;
	}
	else if (self.admin_kick == world)
	{
		CmdMsg("No user selected!\n");
		return #FALSE;
	}
	else if (!self.admin_kick.is_connected)
	{
		CmdMsg("User has left the server!\n");
		return #FALSE;
	}
	#ifndef VOTING_TEST
	else if (self.admin_kick == self)
	{
		CmdMsg("Are you trying to punish yourself? weird..\n");
		self.admin_kick = world;
		return #FALSE;
	}
	#endif
	else if (self.g_a == #PUNISH_CURSE)
	{
		if (self.admin_kick.classname=="spec")
		{
			CmdMsg("Can't curse spectators!\n");
			return #FALSE;
		}
		else if (self.admin_kick.playerclass == #PC_UNDEFINED)
		{
			CmdBadArg("Player ",self.admin_kick.netname," is observing the game!\n");
			return #FALSE;
		}
		else if (self.admin_kick.done_custom & #CUSTOM_BUILDING)
		{
			CmdBadArg("Player ",self.admin_kick.netname," is still customizing!\n");
			return #FALSE;
		}
	}
	else if (self.g_a == #PUNISH_CUFF)
	{
		if (self.admin_kick.classname=="spec")
		{
			CmdMsg("Can't cuff spectators!\n");
			return #FALSE;
		}
	}
	
	if (self.admin_kick.classname != "spec" && self.admin_kick.classname != "player")
	{
		CmdMsg("Invalid user selected!\n");
		return #FALSE;
	}
	
	return #TRUE;
};

//===================================================================
// This is the anti-spam mechanism used for monster name changes
// Also used for anti-spam on "cheater" commands

float() MonsterNameAllowed =
{
	if (self.increase_team3 < time)
	{
		if (time - self.increase_team3 < #SECS_SNAMECHANGE_THRES)
		{
			self.increase_team2 = self.increase_team2 +1;
			if (self.increase_team2 >= #NUM_SNAMECHANGE_THRES)
				self.increase_team3 = time + #TIME_SNAME_INHIBITED; 					   
		}
		else
		{
			self.increase_team2 = 0;
			self.increase_team3 = time;
		}

		return #TRUE;
	}
	else
	{
		CmdMsg("Don't spam the server please!\n");
		return #FALSE;
	}
};

//===========================================================================================
// A client just typed a command and server hasn't found a regular command handler for it
// If this function returns 0 (FALSE), unhandling is assumed, and "Bad user command" message is shown
// It should return a non-zero value (like TRUE) if it processes the command, even with errors,
// which should be reported by this function itself

float(float num_args, string arg1, string arg2, string arg3, string arg4, string arg5, string arg6, string arg7) ClientCommand =
{
	// First of all, check if we allow a client command from this user right now..
	if (self.ex_skill_max > time)
		return #TRUE; // dont report anything!
		
	if (self.flags & #FL_FINALIZED)
		return #TRUE;
	
	if (intermission_running)
	{
		CmdMsg("No client commands are allowed during an intermission!\n");
		return #TRUE;
	}
	
	if (!self.is_connected)
		return #FALSE;
	 
	if (self.classname != "player" && self.classname != "spec")
		return #TRUE;

	if (num_args <= 0) //NOT NEEDED
		return #FALSE; 

	#ifdef CRASH_TEST
	if (!strcasecmp(arg1,"crash"))
	{
		sprint(self,#PRINT_HIGH,"Crashing server... just a few seconds :P\n");
		StartCrash();
		return #TRUE;
	}
	#endif

	local entity targ;
	local string st;
	local float tmpf, tmpf2;

	// Player/Spectator valid commands:
	if (!strcasecmp(arg1,"admin")) // ADMIN
	{
		// No arguments
		if (num_args < 2)
		{
			CmdHelp(#CMDHELP_ADMIN);
			return #TRUE;
		}

		// Any-player admin commands				
		if (!strcasecmp(arg2,"login")) // ADMIN - LOGIN
		{
			// Check if client is trying to hack the admin password
			if (self.ex_skill_min >= #CMD_MAX_ADMINATTEMPTS)
			{
				CmdMsg("Go away, hacker wannabe!\n");
				return #TRUE;
			}

			// No argument
			if (num_args < 3)
			{
				CmdHelp(#CMDHELP_ADMIN_LOGIN);
				return #TRUE;
			}

			st = infokey(world,"adminpwd");

			// If no adminpwd is set, abort and report it
			if (st == "")
			{
				CmdMsg("Unable to log in as admin, no password has been set!\n");
				return #TRUE;
			}

			if (arg3 == st)
			{
				if (self.admin_flag)
				{
					CmdMsg("Already logged as admin!\n");
					return #TRUE;
				}
				else
				{
					PrintAdmins(#FALSE,#TRUE); // show our colleagues, if any					 
					sprint(self,#PRINT_HIGH,"Loginç You logged in as admin.\n");
					PlayClientSound(self,"doors/baseuse.wav");
					AdminLoggedIn(self);
					self.admin_flag = #TRUE;
					return #TRUE;
				}
			}
			else
			{
				CmdMsg("Loginç Bad admin password!\n"); 
				PlayClientSound(self,"doors/basetry.wav");
			   
				if (!self.admin_flag) // Not an admin?
					self.ex_skill_max = time + 5; // then do not allow another attempt for x seconds from this user
				else // he was an admin lol
					AdminLoggedOut(self);	 
				
				// increase our hacker detection counter :)
				self.ex_skill_min = self.ex_skill_min + 1;

				self.admin_flag = #FALSE;
				return #TRUE;
			}
		}
		else if (!strcasecmp(arg2,"logout")) // ADMIN - LOGOUT
		{
			if (self.admin_flag)
			{
				sprint(self,#PRINT_HIGH,"You logged out as admin.\n");
				self.admin_flag = #FALSE;
				AdminLoggedOut(self);
				return #TRUE;
			}
			else
			{
				CmdMsg("Not logged as admin!\n");
				return #TRUE;
			}
		}
		else if (!strcasecmp(arg2,"online")) // ADMIN - Show online admins
		{
			if (self.option2 < time)
			{
				PrintAdmins(#TRUE,#FALSE);
				self.option2 = time + #CMD_MSGRATE;
			}
			
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"tell"))
		{
			if (num_args == 2)
			{
				CmdHelp(#CMDHELP_ADMIN_TELL);
				return #TRUE;
			}

			if (num_args > 3)
			{
				CmdMsg("Use your message text inside \"quotes like this\"!\n");
				return #TRUE;
			}
			
			Admin_Tell(self,arg3);
			return #TRUE;
		}

		// Admin-only admin commands
		if (self.admin_flag)
		{
			if (mutedtime(self))
			{
				CmdMsg("You have been muted beeing an admin, now think about why...\n");
				return #TRUE;
			}

			if (!strcasecmp(arg2,"get"))
			{
				if (num_args == 2)
				{
					Admin_Kick_Cycle();
					return #TRUE;
				}
				
				targ = getclient(arg3);
				
				if (targ)
				{
					self.admin_kick = targ; //Set current selected person

					if (self.admin_kick.classname == "spec")
						sprint(self, #PRINT_HIGH, "√ÏÈÂÓÙ ®Spectator©: ");
					else
						sprint(self, #PRINT_HIGH, "√ÏÈÂÓÙ: ");

					sprint(self, #PRINT_HIGH, self.admin_kick.netname);
					sprint(self, #PRINT_HIGH, " selected ®");

					st = ftos(getuid(self.admin_kick));
					st = colstr(st,#COLSTR_NUMBER);

					sprint(self, #PRINT_HIGH, "’ÛÂÚ…ƒ∫",st," …–∫"); 
					st = infokey(self.admin_kick,"ip");
					st = colstr(st,#COLSTR_NUMBER);
					sprint(self,#PRINT_HIGH,st,"©\n");

					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"debug"))
			{
				MakeMeDebug(self);
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"infos"))
			{
				UpdateInfos(#FALSE);
				if (debug_target!=self) sprint(self,#PRINT_HIGH,"Localinfos updated succesfully.\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"light"))
			{
				st = ftos(current_brightness);

				sprint(self,#PRINT_HIGH,"Current Brightness = ",st,"\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"endgame"))
			{
				Admin_EndGame();
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"killstuff"))
			{
				if (num_args == 2)
				{					 
					Admin_KillStuff();
					return #TRUE;
				}

				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;
					Admin_KillStuff();					  
					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			#ifdef STORM_TEST
			else if (!strcasecmp(arg2,"thunder"))
			{
				StormSpecialEvent(self);
				return #TRUE;
			}
			#endif
			else if (!strcasecmp(arg2,"storm"))
			{
				if (num_args == 2)
				{
					st = ftos(storm);

					sprint(self,#PRINT_HIGH,"Storm setting is ",st,"\n");
					return #TRUE;
				}

				tmpf = storm;

				storm = stof(arg3);

				if (storm < 0 || storm > 1)
				{
					sprint(self,#PRINT_HIGH,"Invalid storm setting!\n");
					storm = tmpf;
					return #TRUE;
				}

				if (storm != tmpf)
				{
					sprint(self,#PRINT_HIGH,"New storm setting is applied\n");
					UpdateEnvironment(tmpf,earthquake,daytime,runes);
					return #TRUE;
				}

				sprint(self,#PRINT_HIGH,"No change on storm setting!\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"earthquake"))
			{
				if (num_args == 2)
				{
					st = ftos(earthquake);

					sprint(self,#PRINT_HIGH,"Earthquake setting is ",st,"\n");
					return #TRUE;
				}

				tmpf = earthquake;

				earthquake = stof(arg3);

				if (earthquake < 0 || earthquake > 1)
				{
					sprint(self,#PRINT_HIGH,"Invalid earthquake setting!\n");
					storm = tmpf;
					return #TRUE;
				}

				if (earthquake != tmpf)
				{
					sprint(self,#PRINT_HIGH,"New earthquake setting is applied\n");
					UpdateEnvironment(storm,tmpf,daytime,runes);
					return #TRUE;
				}

				sprint(self,#PRINT_HIGH,"No change on earthquake setting!\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"runes"))
			{
				if (num_args == 2)
				{
					st = ftos(runes);

					sprint(self,#PRINT_HIGH,"Runes setting is ",st,"\n");
					return #TRUE;
				}

				// Neo mode: don't allow admins to spawn runes
				if (neo)
				{
					sprint(self, #PRINT_HIGH, "Rune-spawning command is disabled in Neo mode.\nIn Neo mode, it doesn't work right.\n");
					return #TRUE;
				}

				tmpf = runes;

				runes = floor(stof(arg3));

				if (runes < 0 || runes > 4)
				{
					sprint(self,#PRINT_HIGH,"Invalid runes setting! (0-4 allowed)\n");
					runes = tmpf;
					return #TRUE;
				}

				if (runes != tmpf)
				{
					sprint(self,#PRINT_HIGH,"New runes setting is applied\n");
					UpdateEnvironment(storm,earthquake,daytime,tmpf);
					return #TRUE;
				}

				sprint(self,#PRINT_HIGH,"No change on the runes setting!\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"daytime"))
			{
				if (num_args == 2)
				{
					st = ftos(daytime);

					sprint(self,#PRINT_HIGH,"DayTime setting is ",st,"\n");
					return #TRUE;
				}

				tmpf = daytime;

				daytime = stof(arg3);

				if (daytime < 0 || daytime > 360)
				{
					sprint(self,#PRINT_HIGH,"Invalid daytime setting!\n");
					daytime = tmpf;
					return #TRUE;
				}

				if (daytime != tmpf)
				{
					sprint(self,#PRINT_HIGH,"New DayTime setting is applied\n");
					UpdateEnvironment(storm,earthquake,tmpf,runes);
					return #TRUE;
				}

				sprint(self,#PRINT_HIGH,"No change on DayTime setting!\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"daylight"))
			{
				if (daytime != 0)
				{
					sprint(self,#PRINT_HIGH,"Unable to adjust brighness with DayTime enabled!\n");
					return #TRUE;
				}
				
				if (num_args == 2)
				{
					st = ftos(daylight);
					sprint(self,#PRINT_HIGH,"Daylight intensity is ",st,"\n");
					return #TRUE;
				}
				
				tmpf = stof(arg3);
				tmpf = rint(tmpf);

				if (tmpf < 0 || tmpf > 25)
				{
					sprint(self,#PRINT_HIGH,"Valid daylight value ranges from 0 to 25!\n");
					return #TRUE;
				}
				
				targ = FadeWorld(tmpf,0,0,0);

				if (targ)
					targ.has_teleporter = 3; // Set daylight along with fade

				return #TRUE;
			}
			else if (!strcasecmp(arg2,"silence"))
			{
				if (num_args == 2)
				{
					Admin_Silence(0,#DEFAULT_SILENCE_TIME);
					return #TRUE;
				}

				tmpf = stof(arg3);

				if (num_args == 3)
				{
					Admin_Silence(0,tmpf);
					return #TRUE;
				}

				if (!strcasecmp(arg4,"players"))
				{
					Admin_Silence(1,tmpf);
					return #TRUE;
				}
				else if (!strcasecmp(arg4,"specs") || !strcasecmp(arg4,"spectators"))
				{
					Admin_Silence(2,tmpf);
					return #TRUE;
				}

				sprint(self,#PRINT_HIGH,"Bad syntax!\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"cuff"))
			{
				st = ftos(#CMD_DEFAULT_CUFF_TIME);
				
				if (num_args == 2)
				{					 
					Admin_Cuff(st);
					return #TRUE;
				}

				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;

					if (num_args == 3)
						Admin_Cuff(st);
					else
						Admin_Cuff(arg4);

					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"sermon"))
			{				 
				if (num_args < 4)
				{					 
					sprint(self,#PRINT_HIGH,"Sermon command syntax is: cmd admin sermon (player) \"Sermon text\" [kick|ban]\n");
					return #TRUE;
				}

				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;
					
					if (num_args > 4)
					{
						if (!strcasecmp(arg5,"ban"))
							Admin_Sermon(arg4,2);	 
						else if (!strcasecmp(arg5,"kick"))
							Admin_Sermon(arg4,1);	 
						else
							Admin_Sermon(arg4,0);
					}	 
					else
						Admin_Sermon(arg4,0);

					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"mute"))
			{
				st = ftos(#CMD_DEFAULT_MUTE_TIME);
				
				if (num_args == 2)
				{					 
					Admin_Mute(st);
					return #TRUE;
				}

				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;

					if (num_args == 3)
						Admin_Mute(st);
					else
						Admin_Mute(arg4);

					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"curse"))
			{
				if (num_args == 2)
				{
					Admin_Curse();
					return #TRUE;
				}

				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;
					Admin_Curse();
					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"kick"))
			{
				if (num_args == 2)
				{
					Admin_Kick_Person();
					return #TRUE;
				}

				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;
					Admin_Kick_Person();
					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"ban"))
			{
				if (num_args == 2)
				{
					Admin_Ban_Person();
					return #TRUE;
				}

				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;
					Admin_Ban_Person();
					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"ceasefire"))
			{
				// No argument.. so just toggle it
				if (num_args == 2)
				{
					Admin_Call_Ceasefire();
					return #TRUE;
				}

				if (arg3=="0" || !strcasecmp("off",arg3))
				{
					if (ceasefire)
					{
						Admin_Call_Ceasefire(); 					   
						return #TRUE;
					}
					else
					{
						sprint(self,#PRINT_HIGH,"Ceasefire is already off!\n");
						return #TRUE;
					}
				}
				else if (arg3=="1" || !strcasecmp("on",arg3))
				{
					if (!ceasefire)
					{
						Admin_Call_Ceasefire();
						return #TRUE;
					}
					else
					{
						sprint(self,#PRINT_HIGH,"Already on a Ceasefire!\n");
						return #TRUE;
					}
				}

				// bad ceasefire argument 
				CmdBadArg("√Â·ÛÂ∆ÈÚÂ: Bad parameter ¢",arg3,"¢ passed in!\nType ¢cmd help ceasefire¢ to see possible parameters.\n");
				return #TRUE;
			}
			else if (!strcasecmp(arg2,"team")) // Team assignmnent
			{
				// No argument
				if (num_args == 2)
				{
					CmdHelp(#CMDHELP_ADMIN_TEAM); // so show help
					return #TRUE;
				}

				// Neo mode: don't allow admins to assign teams to players
				if (neo)
				{
					sprint(self, #PRINT_HIGH, "Team assignment command is disabled in Neo mode.\nIn Neo mode, it doesn't work right and there should be no use for it.\n");
					return #TRUE;
				}

				// Check if valid team number parameter
				tmpf = stof(arg3);

				if (tmpf < 1 || tmpf > 4)
				{
					CmdBadArg("‘Â·Ì: Bad team number ¢",arg3,"¢ passed in!\nType ¢cmd help team¢ to see possible parameters.\n");
					return #TRUE;
				}

				// No client argument
				if (num_args == 3)
				{
					Admin_Assign(tmpf);
					return #TRUE;
				}

				// Parse Given client argument
				targ = getclient(arg4);
				if (targ)
				{
					self.admin_kick = targ;
					Admin_Assign(tmpf);
					return #TRUE;
				}
				else
				{
					CmdClientErr(arg4);
					return #TRUE;
				}
			}
			else if (!strcasecmp(arg2,"cmnd")) // CMND
			{
				// No argument
				if (num_args == 2)
				{
					CmdHelp(#CMDHELP_ADMIN_CMND); // so show help
					return #TRUE;
				}
				
				// No client argument
				if (num_args == 3)
				{
					Admin_Cmd(arg3);
					return #TRUE;
				}

				// Parse Given client argument
				targ = getclient(arg4);
				if (targ)
				{
					self.admin_kick = targ;
					Admin_Cmd(arg3);
					return #TRUE;
				}
				else
				{
					CmdClientErr(arg4);
					return #TRUE;
				}				 
			}
			else if (!strcasecmp(arg2,"check")) // Check
			{
				if (num_args == 2)
				{
					if (!self.admin_kick)
					{
						CmdHelp(#CMDHELP_ADMIN_CHECK);
						return #TRUE;
					}
					else
					{
						Admin_Check();
						return #TRUE;
					}
				}

				// Parse Given client argument
				targ = getclient(arg3);
				if (targ)
				{
					self.admin_kick = targ;
					Admin_Check();
					return #TRUE;
				}
				else
				{
					CmdClientErr(arg3);
					return #TRUE;
				}

			}
			else if (!strcasecmp(arg2,"stuff")) // Stuff
			{
				if (num_args == 2)
				{
					sprint(self,#PRINT_HIGH,"Syntax: cmd admin stuff disable|enable|makefree|delfree (item) (page) [permanent]\n");
					return #TRUE;
				}

				if (!strcasecmp(arg3,"disable"))
				{
					if (num_args < 5)
					{
						sprint(self,#PRINT_HIGH,"You need to specify a page and item number!\n");
						return #TRUE;
					}

					tmpf = stof(arg4);
					tmpf2 = stof(arg5);

					if (tmpf2 < 1 || tmpf2 > 15 || tmpf < 1 || tmpf > 7)
					{
						sprint(self,#PRINT_HIGH,"Invalid page/item specified!\n");
						return #TRUE;
					}

					sprint(self,#PRINT_HIGH,"Item ",arg4," in page ",arg5," has been disabled");

					if (!(strcasecmp(arg6,"perm")) || !(strcasecmp(arg6,"permanent")))
					{
						sprint(self,#PRINT_HIGH," permanently");
						tmpf = DisableItem(tmpf,tmpf2,#TRUE);
					}
					else
						tmpf = DisableItem(tmpf,tmpf2,#FALSE);

					if (tmpf)
						sprint(self,#PRINT_HIGH,".\n");
					else
						sprint(self,#PRINT_HIGH," (no change).\n");
						
					return #TRUE;					 
				}
				else if(!strcasecmp(arg3,"enable"))
				{
					if (num_args < 5)
					{
						if (num_args == 4)
						if (!strcasecmp(arg4,"all"))
						{
							if (disabledstuff1 | disabledstuff2 | disabledstuff3 | disabledstuff4 | disabledstuff5)
							{
								disabledstuff1 = disabledstuff2 = disabledstuff3 = disabledstuff4 = disabledstuff5 = 0;
								sprint(self,#PRINT_HIGH,"All items have been enabled.\n");
							}
							else
								sprint(self,#PRINT_HIGH,"No items disabled currently!\n");
							
							return #TRUE;
						}

						sprint(self,#PRINT_HIGH,"You need to specify a page and item number!\n");
						return #TRUE;
					}

					tmpf = stof(arg4);
					tmpf2 = stof(arg5);

					if (tmpf2 < 1 || tmpf2 > 15 || tmpf < 1 || tmpf > 7)
					{
						sprint(self,#PRINT_HIGH,"Invalid page/item specified!\n");
						return #TRUE;
					}

					sprint(self,#PRINT_HIGH,"Item ",arg4," in page ",arg5," has been enabled");

					if (!(strcasecmp(arg6,"perm")) || !(strcasecmp(arg6,"permanent")))
					{
						sprint(self,#PRINT_HIGH," permanently");
						tmpf = EnableItem(tmpf,tmpf2,#TRUE);
					}
					else
						tmpf = EnableItem(tmpf,tmpf2,#FALSE);

					if (tmpf)
						sprint(self,#PRINT_HIGH,".\n");
					else
						sprint(self,#PRINT_HIGH," (no change).\n");

					return #TRUE;
				}
				else if(!strcasecmp(arg3,"makefree"))
				{
					if (num_args < 5)
					{
						sprint(self,#PRINT_HIGH,"You need to specify a page and item number!\n");
						return #TRUE;
					}

					tmpf = stof(arg4);
					tmpf2 = stof(arg5);

					if (tmpf2 < 1 || tmpf2 > 15 || tmpf < 1 || tmpf > 7)
					{
						sprint(self,#PRINT_HIGH,"Invalid page/item specified!\n");
						return #TRUE;
					}

					sprint(self,#PRINT_HIGH,"Item ",arg4," in page ",arg5," is now free");

					if (!(strcasecmp(arg6,"perm")) || !(strcasecmp(arg6,"permanent")))
					{
						sprint(self,#PRINT_HIGH," permanently");
						tmpf = MakeFree(tmpf,tmpf2,#TRUE);
					}
					else
						tmpf = MakeFree(tmpf,tmpf2,#FALSE);

					if (tmpf)
						sprint(self,#PRINT_HIGH,".\n");
					else
						sprint(self,#PRINT_HIGH," (no change).\n");
						
					return #TRUE;
				}
				else if(!strcasecmp(arg3,"delfree"))
				{
					if (num_args < 5)
					{
						if (num_args == 4)
						if (!strcasecmp(arg4,"all"))
						{
							if (givenstuff1 | givenstuff2 | givenstuff3 | givenstuff4 | givenstuff5)
							{
								givenstuff1 = givenstuff2 = givenstuff3 = givenstuff4 = givenstuff5 = 0;
								sprint(self,#PRINT_HIGH,"All free items removed.\n");
							}
							else
								sprint(self,#PRINT_HIGH,"No free items currently!\n");
							
							return #TRUE;
						}

						sprint(self,#PRINT_HIGH,"You need to specify a page and item number!\n");
						return #TRUE;
					}

					tmpf = stof(arg4);
					tmpf2 = stof(arg5);

					if (tmpf2 < 1 || tmpf2 > 15 || tmpf < 1 || tmpf > 7)
					{
						sprint(self,#PRINT_HIGH,"Invalid page/item specified!\n");
						return #TRUE;
					}

					sprint(self,#PRINT_HIGH,"Item ",arg4," in page ",arg5," has been removed from free items");

					if (!(strcasecmp(arg6,"perm")) || !(strcasecmp(arg6,"permanent")))
					{
						sprint(self,#PRINT_HIGH," permanently");
						tmpf = DelFree(tmpf,tmpf2,#TRUE);
					}
					else
						tmpf = DelFree(tmpf,tmpf2,#FALSE);

					if (tmpf)
						sprint(self,#PRINT_HIGH,".\n");
					else
						sprint(self,#PRINT_HIGH," (no change).\n");

					return #TRUE;
				}

				return #TRUE;
			}
		}

		// non-valid admin command 
		CmdBadArg("¡‰ÌÈÓ: Bad admin command ¢",arg2,"¢ passed in!\nType ¢cmd help admin¢ to see possible admin commands.\n");
		return #TRUE;
	}
	else if (!strcasecmp(arg1,"help")) // HELP
	{
		// Main help (no argument)
		if (num_args == 1)
		{
			CmdHelp(#CMDHELP_DEFAULT);
			return #TRUE;
		}
		
		// help items
		/*if (!strcasecmp(arg2,"build"))
		{
			CmdHelp(#CMDHELP_BUILD);
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"summon"))
		{
			CmdHelp(#CMDHELP_SUMMON);
			return #TRUE;
		}*/

		if (!strcasecmp(arg2,"special"))
		{
			if (num_args == 2)
			{
				CmdHelp(#CMDHELP_SPECIAL);
				return #TRUE;
			}

			if (!strcasecmp(arg3,"getlit"))
			{
				CmdHelp(#CMDHELP_GETLIT);
				return #TRUE;
			}

			CmdBadArg("»ÂÏ: Invalid special command ¢",arg3,"¢ passed in!\nType ¢cmd help special¢ to see possible commands.\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"cheater"))
		{
			CmdHelp(#CMDHELP_CHEATER);
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"game"))
		{
			if (num_args == 2)
			{
				CmdHelp(#CMDHELP_GAME);
				return #TRUE;
			}

			if (!strcasecmp(arg3,"build"))
			{
				CmdHelp(#CMDHELP_BUILD);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"sname"))
			{
				CmdHelp(#CMDHELP_SNAME);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"drop"))
			{
				CmdHelp(#CMDHELP_DROP);
				return #TRUE;
			}

			// Unknown game command help request
			CmdBadArg("»ÂÏ: Invalid game command ¢",arg3,"¢ passed in!\nType ¢cmd help game¢ to see possible commands.\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"vote"))
		{
			if (num_args == 2)
			{
				CmdHelp(#CMDHELP_VOTE);
				return #TRUE;
			}

			if (!strcasecmp(arg3,"map"))
			{
				CmdHelp(#CMDHELP_MAP);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"nextmap"))
			{
				CmdHelp(#CMDHELP_NEXTMAP);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"kick"))
			{
				CmdHelp(#CMDHELP_KICK);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"ban"))
			{
				CmdHelp(#CMDHELP_BAN);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"cuff"))
			{
				CmdHelp(#CMDHELP_CUFF);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"curse"))
			{
				CmdHelp(#CMDHELP_CURSE);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"mute"))
			{
				CmdHelp(#CMDHELP_MUTE);
				return #TRUE;
			}

			// Unknown vote command help request
			CmdBadArg("»ÂÏ: Invalid vote command ¢",arg3,"¢ passed in!\nType ¢cmd help vote¢ to see possible commands.\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"admin"))
		{
			if (num_args == 2)
			{
				CmdHelp(#CMDHELP_ADMIN);
				return #TRUE;
			}

			if (!strcasecmp(arg3,"login"))
			{
				CmdHelp(#CMDHELP_ADMIN_LOGIN);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"logout"))
			{
				CmdHelp(#CMDHELP_ADMIN_LOGOUT);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"online"))
			{
				CmdHelp(#CMDHELP_ADMIN_ONLINE);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"ceasefire"))
			{
				CmdHelp(#CMDHELP_ADMIN_CEASEFIRE);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"get"))
			{
				CmdHelp(#CMDHELP_ADMIN_GET);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"kick"))
			{
				CmdHelp(#CMDHELP_ADMIN_KICK);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"ban"))
			{
				CmdHelp(#CMDHELP_ADMIN_BAN);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"mute"))
			{
				CmdHelp(#CMDHELP_ADMIN_MUTE);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"curse"))
			{
				CmdHelp(#CMDHELP_ADMIN_CURSE);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"team"))
			{
				CmdHelp(#CMDHELP_ADMIN_TEAM);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"cmnd"))
			{
				CmdHelp(#CMDHELP_ADMIN_CMND);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"cuff"))
			{
				CmdHelp(#CMDHELP_ADMIN_CUFF);
				return #TRUE;
			}

			// Unknown admin command help request
			CmdBadArg("»ÂÏ: Invalid admin command ¢",arg3,"¢ passed in!\nType ¢cmd help admin¢ to see possible commands.\n");
			return #TRUE;
		}

		// Unknown command help request
		CmdBadArg("»ÂÏ: Unknown command ¢",arg2,"¢ passed in!\nType ¢cmd help¢ to see possible commands.\n");
		return #TRUE;
	}
	else if (!strcasecmp("cheater",arg1))
	{
		// If this player is muted, go away
		if (mutedtime(self))
		{
			CmdMsg("Don't spam the server, please.\n");
			return #TRUE;
		}

		// Extra anti-spam safety
		if (!MonsterNameAllowed())
			return #TRUE;
		
		if (num_args == 1) // no arguments?
		{
			CmdHelp(#CMDHELP_CHEATER); // then show help
			return #TRUE;
		}

		targ = getclient(arg2);
		if (targ)
		{
			#ifndef VOTING_TEST
			if (targ == self)
			{
				CmdMsg("You want to accuse yourself of cheating? weird..\n");
				return #TRUE;
			}
			#endif

			if (targ.classname != "player")
			{
				CmdMsg("You can only accuse of cheating a player!\n");
				return #TRUE;
			}
			
			RPrint(self.netname);
			RPrint(" accuses ");
			RPrint(targ.netname);
			if (num_args == 2)
				RPrint(" of cheating\n");
			else
			{
				RPrint(" of cheating. Reason:\n");
				RPrint(arg3);
				RPrint("\n");
			}
			
			bprint(#PRINT_HIGH,"®logged© ");
			bprint(#PRINT_HIGH,self.netname);
			bprint(#PRINT_HIGH," accuses ");
			bprint(#PRINT_HIGH,targ.netname);

			if (num_args == 2)
				bprint(#PRINT_HIGH," of √»≈¡‘…Œ«!\n");
			else
			{
				bprint(#PRINT_HIGH," of √»≈¡‘…Œ«!\n“Â·ÛÔÓ/Û: ");
				bprint(#PRINT_HIGH,arg3);
				bprint(#PRINT_HIGH,"\n");
			}

			st = GetClientDescription(targ);

			bprint(#PRINT_HIGH,"[",targ.netname," claims to be using ",st,"]\n");

			BroadcastSound("zombie/z_hit");
			putsaytime(self);
			return #TRUE;
		}
		else
		{
			CmdClientErr(arg2);
			return #TRUE;
		}		 
	}
	else if (!strcasecmp("vote",arg1))
	{
		if (num_args == 1)
		{
			CmdHelp(#CMDHELP_VOTE);
			return #TRUE;
		}

		if (mutedtime(self))
		{
			CmdMsg("You are muted, unable to vote!\n");
			return #TRUE;
		}		 

		if (!strcasecmp("nextmap",arg2))
		{
			if (num_args == 2 || arg3 == "")
			{	
				CmdHelp(#CMDHELP_NEXTMAP);
				return #TRUE;
			}

			if (HisMapVoteAllowed())
			{
				if (self.increase_team1 < #CMD_MAX_MAPREQUESTS)
				{
					if (validatemap(arg3))
					{	
						if (arg4 != "") // PZ - begin AGR code
						{	
							if (!strcasecmp(arg4, "neo"))
								self.group_no = 2; // next map in Neo mode
							else if (!strcasecmp(arg4, "agr"))
								self.group_no = 4; // next map in AGR mode
							else
							{
								sprint3(self, #PRINT_HIGH, "Unrecognized command argument: ", arg4, "\n");
								return #TRUE;
							}
						}
						else			// PZ - end AGR code
							self.group_no = 0; // next map mode 

						StartVoteMap(0,arg3);						 
						return #TRUE;
					}
					else
					{
						sprint(self,#PRINT_HIGH,"The server doesn't have the ¢");
						sprint(self,#PRINT_HIGH,arg3);
						sprint(self,#PRINT_HIGH,"¢ map\n");
					}

					self.increase_team1 = self.increase_team1 + 1;
					return #TRUE;
				}
				else
				{
					st = ftos(#CMD_MAX_MAPREQUESTS);
					st = strcat("Only ",st);
					st = strcat(st," custom map requests per game is allowed, sorry\n");
					CmdMsg(st);
					return #TRUE;
				}
			}
			else
				return #TRUE;
		}
		else if (!strcasecmp("map",arg2))
		{
			if (num_args == 2 || arg3 == "")
			{	
				CmdHelp(#CMDHELP_MAP);
				return #TRUE;
			}			 

			if (HisMapVoteAllowed())
			{
				if (self.increase_team1 < #CMD_MAX_MAPREQUESTS)
				{
					if (validatemap(arg3))
					{
						if (arg4 != "") // PZ - begin AGR code
						{
							if (!strcasecmp(arg4, "neo"))
								self.group_no = 3; // switch map in Neo mode
							else if (!strcasecmp(arg4, "agr"))
								self.group_no = 5; // switch map in AGR mode
							else
							{
								sprint3(self, #PRINT_HIGH, "Unrecognized command argument: ", arg4, "\n");
								return #TRUE;
							}
						}
						else			// PZ - end AGR code
							self.group_no = 1; // switch to mode											 
						StartVoteMap(0,arg3);						 
						return #TRUE;
					}
					else
					{
						sprint(self,#PRINT_HIGH,"The server doesn't have the ¢");
						sprint(self,#PRINT_HIGH,arg3);
						sprint(self,#PRINT_HIGH,"¢ map\n");
					}

					self.increase_team1 = self.increase_team1 + 1;
					return #TRUE;
				}
				else
				{
					st = ftos(#CMD_MAX_MAPREQUESTS);
					st = strcat("Only ",st);
					st = strcat(st," custom map requests per game is allowed, sorry\n");
					CmdMsg(st);
					return #TRUE;
				}
			}
			else
				return #TRUE;
		}
		else if (!strcasecmp(arg2,"kick"))
		{
			if (num_args == 2)
			{	
				CmdHelp(#CMDHELP_KICK);
				return #TRUE;
			}

			targ = getclient(arg3);

			if (targ)
			{
				self.admin_kick = targ;
				self.g_a = #PUNISH_KICK;

				if (HisPunishmentAllowed())
					StartPunishmentVote();
				
				return #TRUE;
			}
			else
			{
				CmdClientErr(arg3);
				return #TRUE;
			}
		}
		else if (!strcasecmp(arg2,"curse"))
		{
			if (num_args == 2)
			{	
				CmdHelp(#CMDHELP_CURSE);
				return #TRUE;
			}

			targ = getclient(arg3);

			if (targ)
			{
				self.admin_kick = targ;
				self.g_a = #PUNISH_CURSE;

				if (HisPunishmentAllowed())
					StartPunishmentVote();
				
				return #TRUE;
			}
			else
			{
				CmdClientErr(arg3);
				return #TRUE;
			}
		}
		else if (!strcasecmp(arg2,"mute"))
		{
			if (num_args == 2)
			{	
				CmdHelp(#CMDHELP_MUTE);
				return #TRUE;
			}

			targ = getclient(arg3);

			if (targ)
			{
				self.admin_kick = targ;
				self.g_a = #PUNISH_MUTE;

				if (HisPunishmentAllowed())
					StartPunishmentVote();
				
				return #TRUE;
			}
			else
			{
				CmdClientErr(arg3);
				return #TRUE;
			}
		}
		else if (!strcasecmp(arg2,"cuff"))
		{
			if (num_args == 2)
			{	
				CmdHelp(#CMDHELP_CUFF);
				return #TRUE;
			}

			targ = getclient(arg3);

			if (targ)
			{
				self.admin_kick = targ;
				self.g_a = #PUNISH_CUFF;

				if (HisPunishmentAllowed())
					StartPunishmentVote();
				
				return #TRUE;
			}
			else
			{
				CmdClientErr(arg3);
				return #TRUE;
			}
		}
		else if (!strcasecmp(arg2,"ban"))
		{
			if (num_args == 2)
			{	
				CmdHelp(#CMDHELP_BAN);
				return #TRUE;
			}

			targ = getclient(arg3);

			if (targ)
			{
				self.admin_kick = targ;
				self.g_a = #PUNISH_BAN;

				if (HisPunishmentAllowed())
					StartPunishmentVote();
				
				return #TRUE;
			}
			else
			{
				CmdClientErr(arg3);
				return #TRUE;
			}
		}

		// Unknown vote command
		CmdBadArg("÷ÔÙÂ: Unknown vote command ¢",arg2,"¢ passed in!\nType ¢cmd help vote¢ to see possible commands.\n");
		return #TRUE;
	}
	else if (!strcasecmp(arg1,"special"))
	{
		if (num_args == 1)
		{
			CmdHelp(#CMDHELP_SPECIAL);
			return #TRUE;
		}

		if (!strcasecmp(arg2,"getlit"))
		{
			if (self.cltype != #CLTYPE_PROZACQW && self.cltype != #CLTYPE_FUHQUAKE && self.cltype != #CLTYPE_AMFQUAKE)
			{
				CmdMsg("You must use a coloured lighting capable and compatible client to use this feature, sorry!\n");
				return #TRUE;
			}

			if (validatelit())
			{
				sprint(self,#PRINT_HIGH,"Attempting to download coloured lighting file for the map...\n");
				stuffcmd(self,"download maps/");
				stuffcmd(self,mapname);
				stuffcmd(self,".lit\n");
			}
			else
			{
				CmdMsg("The server doesn't have a coloured lighting file for this map!\n");
			}

			return #TRUE;
		}
		else if (!strcasecmp(arg2,"getsky"))
		{
			if (self.cltype != #CLTYPE_PROZACQW)
			{
				CmdMsg("Feature not compatible with your client, sorry!\n");	
				return #TRUE;
			}

			CmdMsg("Still unimplemented, sorry!\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"gethrt"))
		{
			if (self.cltype != #CLTYPE_PROZACQW)
			{
				CmdMsg("Feature not compatible with your client, sorry!\n");	
				return #TRUE;
			}

			CmdMsg("Still unimplemented, sorry!\n");
			return #TRUE;
		}
		
		// Unknown/invalid special command
		CmdBadArg("”Â„È·Ï: Unknown special command ¢",arg2,"¢ passed in!\nType ¢cmd help special¢ to see possible commands.\n");
		return #TRUE;
	}

	// if we are an spectator, go away.. (return FALSE --> will make server display error to client)
	if (self.classname != "player")
		return #FALSE;

	// Player-only commands:
	if (!strcasecmp(arg1, "game"))
	{
		if (num_args == 1)
		{
			CmdHelp(#CMDHELP_GAME);
			return #TRUE;
		}

		if (!strcasecmp(arg2,"drop"))
		{
			if (num_args == 2)
			{
				CmdHelp(#CMDHELP_DROP);
				return #TRUE;
			}

			if (!strcasecmp(arg3,"items"))
			{				 
				tmpf = TeamFortress_DropItems();
				
				if (tmpf == 0)
					CmdMsg("You have no items to drop!\n");
				else
				{					 
					if (tmpf > 1)
					{	st = ftos(tmpf);
						st = strcat("You have dropped ",st);
						st = strcat(st," items.\n");
					}
					else
						st = "You have dropped one item.\n";
					
					CmdMsg(st);
				}

				return #TRUE;
			}
			else if (!strcasecmp(arg3,"runes"))
			{
				// Neo mode
				if (neo)
				{
					CmdMsg("This command is disabled in Neo mode.\n");
					return #TRUE;
				}

				if (self.#runes == 0)
				{
					CmdMsg("You have no runes to drop!\n");
					return #TRUE;
				}

				PlayerDropRunes(self);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"rune"))
			{
				// Neo mode
				if (neo)
				{
					CmdMsg("This command is disabled in Neo mode.\n");
					return #TRUE;
				}

				if (num_args == 3)
				{
					CmdMsg("You should specify which rune to drop!\n");
					return #TRUE;
				}

				tmpf = floor(stof(arg4));

				if (tmpf < 1 || tmpf > 4)
				{
					CmdMsg("Valid rune numbers are from 1 to 4!\n");
					return #TRUE;
				}

				if (DropSpecificRune(self,tmpf))
					return #TRUE;
				else
				{
					CmdMsg("You do not have that rune!\n");
					return #TRUE;
				}
			}
		}		 
		else if (!strcasecmp(arg2,"build")) // BUILD
		{
			if (num_args == 2) // We didnt specify something to build
			{
				CmdHelp(#CMDHELP_BUILD); //..so show help
				return #TRUE;
			}

			// What should we build?
			if (!strcasecmp(arg3,"sentry"))
			{
				TeamFortress_Build(#BUILD_SENTRYGUN,1);
				return #TRUE;
			} 
			else if (!strcasecmp(arg3,"tesla"))
			{
				TeamFortress_Build(#BUILD_TESLA,1);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"sensor"))
			{
			// TODO    TeamFortress_Build(#BUILD_SENSOR);
				SBBuildSensor();
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"camera"))
			{
				TeamFortress_Build(#BUILD_SECURITY_CAMERA,1);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"teleporter"))
			{
				TeamFortress_Build(#BUILD_TELEPORTER,1);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"fieldgen"))
			{
				TeamFortress_Build(#BUILD_FIELDGEN,1);
				return #TRUE;
			}
			else if (!strcasecmp(arg3,"dispenser"))
			{
				TeamFortress_Build(#BUILD_DISPENSER,1);
				return #TRUE;
			}
			
			// Not a valid item to build
			CmdBadArg("¬ıÈÏ‰: Bad item ¢",arg3,"¢ passed in!\nUse ¢cmd help game build¢ to see possible choices.\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"sname"))
		{
			if (num_args == 2)
			{
				CmdHelp(#CMDHELP_SNAME);
				return #TRUE;
			}

			tmpf = stof(arg3);
			tmpf = rint(tmpf);

			if (tmpf < 1 || tmpf > 3)
			{
				CmdBadArg("”Œ·ÌÂ: Bad name slot ¢",arg3,"¢ specified!\nUse ¢cmd help game sname¢ to see syntax.\n");
				return #TRUE;
			}
			
			if (num_args == 3) // Display name?
			{
				if (tmpf == 1)
				{
					if (self.#sname1 == "")
					{
						CmdMsg("No custom name on slot 1\n");	 
						return #TRUE;
					}
					else
					{
						st = strcat("SName 1 is: ",self.#sname1);
						st = strcat(st,"\n");
						CmdMsg(st);
						return #TRUE;
					}
				}
				else if (tmpf == 2)
				{
					if (self.#sname2 == "")
					{
						CmdMsg("No custom name on slot 2\n");	 
						return #TRUE;
					}
					else
					{
						st = strcat("SName 2 is: ",self.#sname2);
						st = strcat(st,"\n");
						CmdMsg(st);
						return #TRUE;
					}
				}
				else if (tmpf == 3)
				{
					if (self.#sname3 == "")
					{
						CmdMsg("No custom name on slot 3\n");	 
						return #TRUE;
					}
					else
					{
						st = strcat("SName 3 is: ",self.#sname3);
						st = strcat(st,"\n");
						CmdMsg(st);
						return #TRUE;
					}
				}
			}

			// Check for valid string length
			if (strlen(arg4) > #MAX_SNAME_LEN)
			{			
				CmdMsg("Custom name too long! (maximum is #MAX_SNAME_LEN chars)\n");
				return #TRUE;
			}

			// We should set the name then
			if (tmpf == 1)
			{				
				if (arg4 == "") // Empty string as name argument
				{
					if (self.#sname1 != "") // he has a custom name set
					{
						sprint(self,#PRINT_HIGH,"Custom name 1 has been removed.\n");
						
						if (self.demon_one != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							self.demon_one.increase_team2 = GetNameType(self,0,#TRUE); // default name type
							MakeMonsterName(self.demon_one);
							
							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_one);
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.#sname1);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,self.demon_one.netname);
								bprint(#PRINT_HIGH,"\n");
							}
						}						 
						
						delstr(self.#sname1);						 
						self.#sname1 = "";
					}
					else
						CmdMsg("Custom name 1 is already empty!\n");
				}
				else // String with something as name argument
				{
					if (self.#sname1 == arg4)
					{
						CmdMsg("No changes on custom name 1\n");
						return #TRUE;
					}
					
					if (self.#sname1 != "") // he has a custom name set
					{
						sprint(self,#PRINT_HIGH,"Custom name 1 has been changed.\n");
						
						if (self.demon_one != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_one);
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.#sname1);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,arg4);
								bprint(#PRINT_HIGH,"\n");
							}
						}						   

						delstr(self.#sname1);
						self.#sname1 = makestr(arg4);
					}
					else // no custom name currently..
					{
						sprint(self,#PRINT_HIGH,"Custom name 1 has been set.\n");

						if (self.demon_one != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							self.demon_one.increase_team2 = 0; // custom name type

							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_one);								
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.demon_one.netname);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,arg4);
								bprint(#PRINT_HIGH,"\n");
							}
						}												 

						self.#sname1 = makestr(arg4);
						
						if (self.demon_one != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
							self.demon_one.netname = self.#sname1;
					}
				}
			}
			else if (tmpf == 2)
			{
				if (arg4 == "") // Empty string as name argument
				{
					if (self.#sname2 != "") // he has a custom name set
					{
						sprint(self,#PRINT_HIGH,"Custom name 2 has been removed.\n");
						
						if (self.demon_two != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							self.demon_two.increase_team2 = GetNameType(self,1,#TRUE); // default name type
							MakeMonsterName(self.demon_two);
							
							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_two);
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.#sname2);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,self.demon_two.netname);
								bprint(#PRINT_HIGH,"\n");
							}
						}						 
						
						delstr(self.#sname2);						 
						self.#sname2 = "";
					}
					else
						CmdMsg("Custom name 2 is already empty!\n");
				}
				else // String with something as name argument
				{
					if (self.#sname2 == arg4)
					{
						CmdMsg("No changes on custom name 2\n");
						return #TRUE;
					}

					if (self.#sname2 != "") // he has a custom name set
					{
						sprint(self,#PRINT_HIGH,"Custom name 2 has been changed.\n");
						
						if (self.demon_two != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_two);
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.#sname2);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,arg4);
								bprint(#PRINT_HIGH,"\n");
							}
						}

						delstr(self.#sname2);
						self.#sname2 = makestr(arg4);
					}
					else // no custom name currently..
					{
						sprint(self,#PRINT_HIGH,"Custom name 2 has been set.\n");

						if (self.demon_two != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							self.demon_two.increase_team2 = 0; // custom name type

							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_two);								
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.demon_two.netname);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,arg4);
								bprint(#PRINT_HIGH,"\n");
							}
						}												 

						self.#sname2 = makestr(arg4);
						
						if (self.demon_two != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
							self.demon_two.netname = self.#sname2;
					}
				}
			}
			else
			{
				if (arg4 == "") // Empty string as name argument
				{
					if (self.#sname3 != "") // he has a custom name set
					{
						sprint(self,#PRINT_HIGH,"Custom name 3 has been removed.\n");
						
						if (self.demon_three != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							self.demon_one.increase_team2 = GetNameType(self,2,#TRUE); // default name type
							MakeMonsterName(self.demon_three);
							
							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_three);
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.#sname3);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,self.demon_three.netname);
								bprint(#PRINT_HIGH,"\n");
							}
						}						 
						
						delstr(self.#sname3);						 
						self.#sname3 = "";
					}
					else
						CmdMsg("Custom name 3 is already empty!\n");
				}
				else // String with something as name argument
				{
					if (self.#sname3 == arg4)
					{
						CmdMsg("No changes on custom name 3\n");
						return #TRUE;
					}

					if (self.#sname3 != "") // he has a custom name set
					{
						sprint(self,#PRINT_HIGH,"Custom name 3 has been changed.\n");
						
						if (self.demon_three != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_three);
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.#sname3);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,arg4);
								bprint(#PRINT_HIGH,"\n");
							}
						}

						delstr(self.#sname3);
						self.#sname3 = makestr(arg4);
					}
					else // no custom name currently..
					{
						sprint(self,#PRINT_HIGH,"Custom name 3 has been set.\n");

						if (self.demon_three != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
						{
							self.demon_three.increase_team2 = 0; // custom name type
							
							if (MonsterNameAllowed())
							if (!mutedtime(self))
							{
								st = GetMonsterName(self.demon_three);
								bprint(#PRINT_HIGH,"The ");
								bprint(#PRINT_HIGH,st);
								bprint(#PRINT_HIGH," ");
								bprint(#PRINT_HIGH,self.demon_three.netname);
								bprint(#PRINT_HIGH," (");
								bprint(#PRINT_HIGH,self.netname);
								bprint(#PRINT_HIGH,") is now known as ");
								bprint(#PRINT_HIGH,arg4);
								bprint(#PRINT_HIGH,"\n");
							}
						}												 

						self.#sname3 = makestr(arg4);
						
						if (self.demon_three != world && (self.job & #JOB_WARLOCK || self.job & #JOB_ARMY))
							self.demon_three.netname = self.#sname3;
					}
				}
			}

			return #TRUE;
		}

		// Not a recognized game command 
		CmdBadArg("«·ÌÂ: Unrecognized command ¢",arg2,"¢ passed in!\nUse ¢cmd help game¢ to see avaliable commands.\n");
		return #TRUE;
	}/*
	else if (!strcasecmp(arg1,"summon")) // SUMMON
	{
		if (num_args == 1) // We didnt specify something to summon
		{
			CmdHelp(#CMDHELP_SUMMON); //..so show help
			return #TRUE;
		}

		// What should we summon?
		if (!strcasecmp(arg2,"scrag"))
		{
			CmdMsg("You summon a scrag!\n");
			return #TRUE;
		} 
		else if (!strcasecmp(arg2,"piranha"))
		{
			CmdMsg("You summon a piranha!\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"fiend"))
		{
			CmdMsg("You summon a fiend!\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"shambler"))
		{
			CmdMsg("You summon a shambler!\n");
			return #TRUE;
		}
		else if (!strcasecmp(arg2,"soldier"))
		{
			CmdMsg("You teleport a soldier!\n");
			return #TRUE;
		}
		
		// Not a recognized parameter
		CmdBadArg("”ıÌÌÔÓ: Bad argument ¢",arg2,"¢ passed in!\nUse ¢cmd help summon¢ to see possible choices.\n");
		return #TRUE;
	}*/

	// Not a command handled by us..
	return #FALSE;
};

//========================================================================
// Subroutine to check if a map exists on server

float(string mapstr) validatemap =
{
	mapstr = strcat("maps/",mapstr);
	mapstr = strcat(mapstr,".bsp");

	return validatefile(mapstr);
};

//========================================================================
// Functions to enable/disable specific items using "cmd" commands

float(float itemnum, float page, float permanent) DisableItem =
{
	local float fieldnum;
	local float curval;
	local float bit;

	fieldnum = floor((page - 1) /3)+1;
	curval = DisabledStuff(fieldnum);
	bit = (itemnum + ((page - 1)*7)) - ((fieldnum - 1)*3*7);
	bit = itob(bit);

	if (curval & bit)
		return #FALSE;
	else
	{
		SetDisabledStuff(fieldnum,curval | bit);

		if (permanent)
		{
			local string st;
			st = ftos(fieldnum);
			localcmd("localinfo dstuff");
			localcmd(st);
			st = ftos(curval | bit);
			localcmd(" ");
			localcmd(st);
			localcmd("\n");
		}

		return #TRUE;
	}
};

float(float itemnum, float page, float permanent) EnableItem =
{
	local float fieldnum;
	local float curval;
	local float bit;

	fieldnum = floor((page - 1)/3)+1;
	curval = DisabledStuff(fieldnum);
	bit = (itemnum + ((page - 1)*7)) - ((fieldnum - 1)*3*7);
	bit = itob(bit);

	if (curval & bit)
	{
		SetDisabledStuff(fieldnum,curval - bit);

		if (permanent)
		{
			local string st;
			st = ftos(fieldnum);
			localcmd("localinfo dstuff");
			localcmd(st);
			st = ftos(curval - bit);
			localcmd(" ");
			localcmd(st);
			localcmd("\n");
		}

		return #TRUE;
	}
	else
		return #FALSE;
};

float(float itemnum, float page, float permanent) MakeFree =
{
	local float fieldnum;
	local float curval;
	local float bit;

	fieldnum = floor((page - 1)/3)+1;
	curval = GivenStuff(fieldnum);
	bit = (itemnum + ((page - 1)*7)) - ((fieldnum - 1)*3*7);		
	bit = itob(bit);

	if (curval & bit)
		return #FALSE;
	else
	{
		SetGivenStuff(fieldnum,curval | bit);

		if (permanent)
		{
			local string st;
			st = ftos(fieldnum);
			localcmd("localinfo gstuff");
			localcmd(st);
			st = ftos(curval | bit);
			localcmd(" ");
			localcmd(st);
			localcmd("\n");
		}

		return #TRUE;
	}
};

float(float itemnum, float page, float permanent) DelFree =
{
	local float fieldnum;
	local float curval;
	local float bit;

	fieldnum = floor((page - 1)/3)+1;
	curval = GivenStuff(fieldnum);
	bit = (itemnum + ((page - 1)*7)) - ((fieldnum - 1)*3*7);
	bit = itob(bit);

	if (curval & bit)
	{
		SetGivenStuff(fieldnum,curval - bit);

		if (permanent)
		{
			local string st;
			st = ftos(fieldnum);
			localcmd("localinfo gstuff");
			localcmd(st);
			st = ftos(curval - bit);
			localcmd(" ");
			localcmd(st);
			localcmd("\n");
		}

		return #TRUE;
	}
	else
		return #FALSE;
};