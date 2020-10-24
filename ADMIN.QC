/* 

	Functions handling TeamFortress Administration for Net Servers
	!NOTE! parm15 is used to pass admin status across maps
*/

#define DEFAULT_SILENCE_TIME 20 //minutes

void (entity player) RemoveHolo;
float (float tno) TeamFortress_TeamGetLives;
void(entity p) SetTeamName;
void () kill_my_demons;
void() DetonateAllGunsForced;
float() TeamFortress_DropItems;

void(float delaytime, float fadetime, float factor) World_FadeIn;
void(float delaytime, float fadetime, float factor) World_FadeOut;
void(float delaytime, float fadetime, float factor) World_FadeMid;
entity(float brightness, float fadetime, float delaytime, float factor) FadeWorld;
float() ServerUpdating;
void() NextLevel;
void(string thesound) BroadcastSound;

void(entity player) ArmyRatingJoin;
void(entity player) ArmyRatingLeave;

string(entity client) GetClientDescription;
void(entity player, string st, float action, float predefined) PlayerFinal;

string(float tno) GetTrueTeamName;

float(entity theAdmin) HasValidAdminTarget =
{
	if (theAdmin.admin_kick.classname != "player" && theAdmin.admin_kick.classname != "spec") {
	//if (theAdmin.admin_kick.classname != "player") {
		sprint(theAdmin, #PRINT_HIGH, "No user selected!\n");
		theAdmin.admin_kick = world;
		return #FALSE;
	}
	if (!theAdmin.admin_kick.is_connected) {
		sprint(theAdmin, #PRINT_HIGH, "User has disconnected!\n");
		theAdmin.admin_kick = world;
		return #FALSE;
	}

	return #TRUE;
};

//=====================================================================
// same thing but doesn't display messages, used in vote.qc

float(entity theAdmin) HasValidAdminTarget2 =
{
	if (theAdmin.admin_kick.classname != "player" && theAdmin.admin_kick.classname != "spec") {
		theAdmin.admin_kick = world;
		return #FALSE;
	}
	if (!theAdmin.admin_kick.is_connected) {
		theAdmin.admin_kick = world;
		return #FALSE;
	}

	return #TRUE;
};

float(entity player) ValidClientState =
{
	if (player.playerclass == #PC_UNDEFINED)
	{
		sprint(self,#PRINT_HIGH,"Player ");
		sprint(self,#PRINT_HIGH,self.admin_kick.netname);
		sprint(self,#PRINT_HIGH," is observing the game\n");
	   
		return #FALSE;
	}
	if (player.done_custom & #CUSTOM_BUILDING)
	{
		sprint(self,#PRINT_HIGH,"Player ");
		sprint(self,#PRINT_HIGH,self.admin_kick.netname);
		sprint(self,#PRINT_HIGH," is still customizing\n");
	   
		return #FALSE;
	}

	return #TRUE;
};

void() Admin_Kick_Cycle =
{
	local entity te;
	local float num;
	local string st;

	num = #FALSE;

	te = find(self.admin_kick, classname, "player");
	while (te != world && num == #FALSE)
	{
		num = #TRUE;

		if (!te.is_connected)
			num = #FALSE;
		
		if (self.admin_kick==te)
			num = #FALSE;
		
		if (num == #FALSE) te = find(te, classname, "player");
	}	 
	
	if (te == world) // if out of players on our search lets scan for spectators
	{
		te = find(self.admin_kick, classname, "spec");
		while (te != world && num == #FALSE)
		{
			num = #TRUE;
	
			if (!te.is_connected)
				num = #FALSE;
			
			if (self.admin_kick==te)
				num = #FALSE;
			
			if (num == #FALSE) te = find(te, classname, "spec");
		}
	}
	
	if (te == world) 
	{
		sprint(self, #PRINT_HIGH, "No Clients Found! ®end of list©\n");
		self.admin_kick=world;
	} 
	else
	{
		self.admin_kick = te; //Set current selected person
		//sprint(self, #PRINT_HIGH, "You can type ÎÈ„Î or ‚·Ó to throw them out. Type ÁÂÙ again to select someone else.");

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
	}
};
void() Admin_Kick_Person =
{
	if (self.admin_kick != world) //Bad
	{
		if (!HasValidAdminTarget(self))
			return;

		RPrint(self.netname);
		RPrint(" kicks ");
		RPrint(self.admin_kick.netname);
		RPrint("\n");
		
		bprint(#PRINT_HIGH, self.admin_kick.netname);
		bprint(#PRINT_HIGH, " has been À…√À≈ƒ by the admin ");
		bprint(#PRINT_HIGH, self.netname);
		bprint(#PRINT_HIGH, "\n");

		sprint(self.admin_kick,#PRINT_HIGH,"\nYou have been À…√À≈ƒ from the server!\n");

		stuffcmd(self.admin_kick, "disconnect\n"); //Kick them!

		BroadcastSound("player/teledth1");

		self.admin_kick = world; //Clear it //WK BUG! Used to be ==
	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};
//WK Same code as Bloggy's, but with some happy code for banning
void() Admin_Ban_Person =
{
	local string foo;
	
	if (self.admin_kick != world) //Bad
	{
		//WK Add checks so that it doesn't crash the server!
		if (!HasValidAdminTarget(self))
			return;

		RPrint(self.netname);
		RPrint(" bans ");
		RPrint(self.admin_kick.netname);
		RPrint("\n");

		bprint(#PRINT_HIGH, self.admin_kick.netname);
		bprint(#PRINT_HIGH, " has been ¬¡ŒŒ≈ƒ by the admin ");
		bprint(#PRINT_HIGH, self.netname);
		bprint(#PRINT_HIGH, "\n");

		sprint(self.admin_kick,#PRINT_HIGH,"\nYou have been ¬¡ŒŒ≈ƒ from the server!\n");

		foo = infokey(self.admin_kick,"ip");
		localcmd("addip ");
		localcmd(foo);
		localcmd("\n");

		stuffcmd(self.admin_kick, "disconnect\n"); //Kick them!

		BroadcastSound("player/teledth1");

		self.admin_kick = world; //Clear it //WK BUG! Used to be ==
	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};

void() Admin_Curse =
{
	if (self.admin_kick != world) //Bad
	{
		//WK Add checks so that it doesn't crash the server!
		if (!HasValidAdminTarget(self))
			return;

		if (self.admin_kick.classname != "player")
		{
			sprint(self,#PRINT_HIGH,"You can only curse players!\n");
			return;
		}

		if (!ValidClientState(self.admin_kick))
			return;

		RPrint(self.netname);
		RPrint(" curses the player ");
		RPrint(self.admin_kick.netname);
		RPrint("\n");

		bprint(#PRINT_HIGH, self.admin_kick.netname);
		bprint(#PRINT_HIGH, " has been √’“”≈ƒ by the admin ");
		bprint(#PRINT_HIGH, self.netname);
		bprint(#PRINT_HIGH, "\n");

		local float tf;
		local string st2;
			
		tf = 0;
		st2 = infokey(world, "curse");
			
		if (st2 == string_null) 
			tf = stof(st2); 		   

		createBastard(self.admin_kick,tf);
	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};

void(float targetteam) Admin_Assign =
{
	if (self.admin_kick != world) //Bad
	{
		//WK Add checks so that it doesn't crash the server!
		if (!HasValidAdminTarget(self))
			return;

		local string st;
		local float tc;

		targetteam = floor(targetteam);
		
		if (targetteam == 3)
		{
			if (number_of_teams < 3)
			{
				sprint(self,#PRINT_HIGH,"No team 3 on this map!\n");
				return;
			}				 

			targetteam = 3;
		}
		else if (targetteam == 4)
		{
			if (number_of_teams < 4)
			{
				sprint(self,#PRINT_HIGH,"No team 4 on this map!\n");
				return;
			} 

			targetteam = 4; 		   
		}
		else if (targetteam < 1 || targetteam > 4)
		{
			sprint(self,#PRINT_HIGH,"Invalid team number!\n");
			return;
		}

		if (self.admin_kick.team_no == targetteam)
		{
			st = ftos(targetteam);
			sprint(self,#PRINT_HIGH,"Player ");
			sprint(self,#PRINT_HIGH,self.admin_kick.netname);
			sprint(self,#PRINT_HIGH," is already on team ");
			sprint(self,#PRINT_HIGH,st);
			sprint(self,#PRINT_HIGH,"!\n");
			return;
		}

		// if our target is observer or he's building a class, return
		if (!ValidClientState(self.admin_kick))
			return;

		if (!neo) // Neo mode
		{
			bprint(#PRINT_HIGH,"The admin ",self.netname," performs team adjustment:\n");

			st = ftos(targetteam);
			RPrint(self.netname);
			RPrint(" puts the player ");
			RPrint(self.admin_kick.netname);
			RPrint(" on team ");
			RPrint(st);
			RPrint("\n");
		}
			
		ArmyRatingLeave(self.admin_kick);

		local entity oself;
		if (!neo) // Neo mode
		{
			oself = self;

			self = self.admin_kick;
			
			// Detonate and kill all our stuff
			if (self.has_holo > 0 ) RemoveHolo(self);
			kill_my_demons();
			DetonateMines(self);
			DetonateAllGunsForced();	
			TeamFortress_DropItems();
			self = oself;
		}
		// end Neo mod

		// Set the player's color
		stuffcmd(self.admin_kick, "color ");
		tc = TeamFortress_TeamGetColor(targetteam) - 1;
		st = ftos(tc);

		tc = self.admin_kick.team_no;

		// Nice colors
		if (nicecolors==1) st =TeamGetNiceColor(targetteam);

		stuffcmd(self.admin_kick, st);
		stuffcmd(self.admin_kick, "\n");

		self.admin_kick.team_no = targetteam;
		makeImmune(self.admin_kick,time+15);

		self.admin_kick.lives = TeamFortress_TeamGetLives(targetteam);

		SetTeamName(self.admin_kick);

		if (!neo) // Neo mode
			bprint(#PRINT_HIGH,"Player ",self.admin_kick.netname," is assigned to team ");

		// PZ - modified for AGR.. changes playersOnTeam#
		if (targetteam == 1)
		{
			playersOnTeam1 = playersOnTeam1 + 1;
			if (!neo) // Neo mode
				bprint(#PRINT_HIGH,"1");
		}
		else if (targetteam == 2)
		{
			playersOnTeam2 = playersOnTeam2 + 1;
			if (!neo) // Neo mode
				bprint(#PRINT_HIGH,"2");
		}
		else if (targetteam == 3)
		{
			playersOnTeam3 = playersOnTeam3 + 1;
			if (!neo) // Neo mode
				bprint(#PRINT_HIGH,"3");
		}
		else
		{
			playersOnTeam4 = playersOnTeam4 + 1;
			if (!neo) // Neo mode
				bprint(#PRINT_HIGH,"4");
		}
		if		(tc == 1) playersOnTeam1 = playersOnTeam1 - 1; // tc is old team number
		else if (tc == 2) playersOnTeam2 = playersOnTeam2 - 1;
		else if (tc == 3) playersOnTeam3 = playersOnTeam3 - 1;
		else			  playersOnTeam4 = playersOnTeam4 - 1;
		// PZ - end AGR mod

		if (!neo) // Neo mode
		{
			st = GetTrueTeamName(targetteam);
			bprint(#PRINT_HIGH, " (", st, " <= ");
			st = GetTrueTeamName(tc);
			bprint(#PRINT_HIGH, st,")\n");
		}

		ArmyRatingJoin(self.admin_kick);

		// Make him/her respawn away
		if (!neo) // Neo Mode: don't make them respawn
		{
			oself = self;
			self = self.admin_kick;
			PutClientInServer();
			self = oself;
		}
	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};

//======================================================================
// The admin wants to type on a client console

void(string cmd) Admin_Cmd =
{
	if (self.admin_kick != world) //Bad
	{
		if (!HasValidAdminTarget(self))
			return;
			
		#ifdef ADMIN_CMND_ALLOWED
		stuffcmd(self.admin_kick,cmd); // execute command
		stuffcmd(self.admin_kick,"\n");
		sprint(self,#PRINT_HIGH, "Command \"");
		sprint(self,#PRINT_HIGH, cmd);
		sprint(self,#PRINT_HIGH, "\" is executed for ");
		sprint(self, #PRINT_HIGH, self.admin_kick.netname);
		sprint(self, #PRINT_HIGH, "\n");
		RPrint(self.netname);
		RPrint(" executes '");
		RPrint(cmd);
		RPrint("' for client ");
		RPrint(self.admin_kick.netname);
		RPrint("\n");
		#else
		sprint(self,#PRINT_HIGH, "Use of CMND's is not allowed.\n");
		#endif
	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};

void(string arg) Admin_Cuff =
{
	if (self.admin_kick != world) //Bad
	{
		if (!HasValidAdminTarget(self))
			return;

		local string tmps;
		local float tmpf,tmpf2;

		tmpf = getuid(self.admin_kick);
		
		if (tmpf) // We got a valid user ID?
		{
			tmps = ftos(tmpf);
			tmpf2 = stof(arg); // Get the argument as float

			if (tmpf2 != 0) // Are we cuffing? or uncuffing?
			{
				RPrint(self.netname);
				RPrint(" cuffs the client ");
				RPrint(self.admin_kick.netname);
				RPrint("\n");	 
				
				bprint(#PRINT_HIGH,self.admin_kick.netname);
				bprint(#PRINT_HIGH," has been √’∆∆≈ƒ by the admin ");
				bprint(#PRINT_HIGH,self.netname);
				bprint(#PRINT_HIGH,"\n");
			}
			else
			{
				RPrint(self.netname);
				RPrint(" uncuffs ");
				RPrint(self.admin_kick.netname);
				RPrint("\n");	
				
				bprint(#PRINT_HIGH,"The admin ");
				bprint(#PRINT_HIGH,self.netname);
				bprint(#PRINT_HIGH," uncuffs ");
				bprint(#PRINT_HIGH,self.admin_kick.netname);
				bprint(#PRINT_HIGH,"\n");
			}
			
			// Perform the command
			localcmd("cuff ");
			localcmd(tmps);
			localcmd(" ");
			localcmd(arg);
			localcmd("\n");
		}
		else
			sprint(self,#PRINT_HIGH,"ERROR: Can't get the user ID!\n");

	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};

void(string arg) Admin_Mute =
{
	if (self.admin_kick != world) //Bad
	{
		if (!HasValidAdminTarget(self))
			return;

		local string tmps;
		local float tmpf,tmpf2;

		tmpf = getuid(self.admin_kick);
		
		if (tmpf) // We got a valid user ID?
		{
			tmps = ftos(tmpf);
			tmpf2 = stof(arg); // Get the argument as float

			if (tmpf2 != 0) // Are we muting? or unmuting?
			{
				RPrint(self.netname);
				RPrint(" mutes the client ");
				RPrint(self.admin_kick.netname);
				RPrint("\n");	 
				
				bprint(#PRINT_HIGH,self.admin_kick.netname);
				bprint(#PRINT_HIGH," has been Õ’‘≈ƒ by the admin ");
				bprint(#PRINT_HIGH,self.netname);
				bprint(#PRINT_HIGH,"\n");
			}
			else
			{
				RPrint(self.netname);
				RPrint(" allows ");
				RPrint(self.admin_kick.netname);
				RPrint(" to speak\n");	 
				
				bprint(#PRINT_HIGH,"The admin ");
				bprint(#PRINT_HIGH,self.netname);
				bprint(#PRINT_HIGH," allows ");
				bprint(#PRINT_HIGH,self.admin_kick.netname);
				bprint(#PRINT_HIGH," to speak\n");
			}
			
			// Perform the command
			localcmd("mute ");
			localcmd(tmps);
			localcmd(" ");
			localcmd(arg);
			localcmd("\n");
		}
		else
			sprint(self,#PRINT_HIGH,"ERROR: Can't get the user ID!\n");

	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};


void() Admin_Call_Ceasefire =
{
	if (intermission_running) return;

	if (ceasefire)
	{
		ceasefire = #FALSE;
		bprint(#PRINT_HIGH, "The game resumes now.\n");

		RPrint(self.netname);
		RPrint(" ends the ceasefire\n");		

		if (num_players)
			World_FadeIn(0,0,0);
		else if (num_specs)
			World_FadeMid(0,0,0);
		else World_FadeOut(0,0,0);
	}
	else
	{
		ceasefire = #TRUE;
		bprint(#PRINT_HIGH, self.netname);
		bprint(#PRINT_HIGH, " forced a ceasefire.\n");

		RPrint(self.netname);
		RPrint(" forces a ceasefire\n");

		World_FadeMid(0,0,0);
	}
};

void() Admin_KillStuff =
{
	if (self.admin_kick != world) //Bad
	{
		if (!HasValidAdminTarget(self))
			return;

		local entity oself;
		oself = self;
		self = self.admin_kick;
		
		// Detonate and kill all his/her stuff
		if (self.has_holo > 0 ) RemoveHolo(self);
		kill_my_demons();
		DetonateMines(self);
		DetonateAllGunsForced();	
		TeamFortress_DropItems();
		self = oself;

		bprint(#PRINT_HIGH,"The admin ");
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH," detonates all the stuff belonging to ");
		bprint(#PRINT_HIGH,self.admin_kick.netname);
		bprint(#PRINT_HIGH,"\n");
	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};

//contains the list of impulses that can be used during ceasefire
//returns TRUE if its good
float(float inp) GoodCeasefireImpulse =
{
	if (inp >= 0 && inp <= 10) // Allow them for menus
		return #TRUE;
	
	if (inp == #TF_MEDIC_HELPME ||
	inp == #TF_TAUNT ||
	inp == #TF_TAUNT2 ||
	inp == #TF_TAUNT3 ||
	inp == #TF_TAUNT4 ||
	inp == #TF_TAUNT5 ||
	inp == #TF_STATUS_QUERY ||
	inp == #TF_DISPLAYLOCATION	 ||
	inp == #TF_STATUS_QUERY ||
	inp == #TF_HELP_MAP ||
	inp == #TF_INVENTORY ||
	inp == #TF_SHOWTF ||
	inp == #FLAG_INFO ||
	inp == #I_CHEAT_ONE ||
	inp == #I_CHEAT_TWO ||
	inp == #I_CHEAT_THREE || 
	inp == #IMPULSE_PUNISH ||
	inp == #IMPULSE_VOTEMAP ||
	inp == #IMPULSE_VOTEYES ||
	inp == #IMPULSE_VOTENO ||
	inp == #IMPULSE_TESTRANGE) //- OfN -
		return #TRUE;

	return #FALSE;

};

//contains the list of impulses that can be used during ceasefire
//returns TRUE if its good

/* OfN UNUSED
float(float inp) Good_Impulse_OnMenu =
{
	if (/*inp == #TF_MEDIC_HELPME ||
	inp == #TF_TAUNT ||
	inp == #TF_TAUNT2 ||
	inp == #TF_TAUNT3 ||
	inp == #TF_TAUNT4 ||
	inp == #TF_TAUNT5 ||*//*
	inp == #TF_STATUS_QUERY ||
	inp == #TF_DISPLAYLOCATION	 ||
	inp == #TF_STATUS_QUERY ||
	inp == #TF_HELP_MAP ||
	inp == #TF_INVENTORY ||
	inp == #TF_SHOWTF ||
	inp == #FLAG_INFO ||
	inp == #I_CHEAT_ONE ||
	inp == #I_CHEAT_TWO ||
	inp == #I_CHEAT_THREE || 
	inp == #IMPULSE_PUNISH || 
	inp == #IMPULSE_VOTEMAP ||
	inp == #IMPULSE_VOTEYES ||
	inp == #IMPULSE_VOTENO) //- OfN -
		return #TRUE;

	return #FALSE;

};*/

//=================================================================================
// Prints a list of current admins, if param is TRUE print a "none found" message

void(float none, float isadmin) PrintAdmins =
{
	local float counter, tmpf;
	local entity te;
	local string tmps;

	counter = 0;

	te = find(world, classname, "player");
	while (te)
	{			 
		if (te.admin_flag)
		if (te.is_connected)
		{
			if (!counter)
				sprint(self,#PRINT_HIGH,"Current admins logged on server∫\n");
			
			counter = counter + 1;

			tmps = ftos(counter);
			tmps = colstr(tmps,#COLSTR_NUMBER);
			
			sprint(self,#PRINT_HIGH,tmps);
			sprint(self,#PRINT_HIGH,"∫ ");
			sprint(self,#PRINT_HIGH,te.netname);

			if (isadmin || self.admin_flag)
			{
				tmps = ftos(getuid(te));
				tmps = colstr(tmps,#COLSTR_NUMBER);

				sprint(self, #PRINT_HIGH, " ®’ÛÂÚ…ƒ∫",tmps," …–∫"); 
				tmps = infokey(te,"ip");
				tmps = colstr(tmps,#COLSTR_NUMBER);
				sprint(self,#PRINT_HIGH,tmps,"©\n");
			}
			else
			{
				sprint(self,#PRINT_HIGH," ®UserID∫");
			
				tmpf = getuid(te);
				tmps = ftos(tmpf);
				sprint(self,#PRINT_HIGH,tmps,"©\n");
			}
		}

		te = find(te, classname, "player");
	}
	
	te = find(world, classname, "spec");
	while (te)
	{			 
		if (te.admin_flag)
		if (te.is_connected)
		{
			if (!counter)
				sprint(self,#PRINT_HIGH,"Current admins logged on server∫\n");
			
			counter = counter + 1;

			tmps = ftos(counter);
			tmps = colstr(tmps,#COLSTR_NUMBER);
			
			sprint(self,#PRINT_HIGH,tmps);
			sprint(self,#PRINT_HIGH,"∫ ");
			sprint(self,#PRINT_HIGH,te.netname);
			sprint(self,#PRINT_HIGH," ®spectator©");
			
			if (isadmin || self.admin_flag)
			{
				tmps = ftos(getuid(te));
				tmps = colstr(tmps,#COLSTR_NUMBER);

				sprint(self, #PRINT_HIGH, " ®’ÛÂÚ…ƒ∫",tmps," …–∫"); 
				tmps = infokey(te,"ip");
				tmps = colstr(tmps,#COLSTR_NUMBER);
				sprint(self,#PRINT_HIGH,tmps,"©\n");
			}
			else
			{
				sprint(self,#PRINT_HIGH," ®UserID∫");
				tmpf = getuid(te);
				tmps = ftos(tmpf);
				sprint(self,#PRINT_HIGH,tmps,"©\n");
			}
		}

		te = find(te, classname, "spec");
	}	 

	if (!counter && none)
		sprint(self,#PRINT_HIGH,"No admins currently logged on server.\n");
};

//========================================================================
// Prints given text to all admins

void(string text) NotifyAdmins =
{
	local entity te;

	te = find(world, classname, "player");
	while (te)
	{			 
		if (te.admin_flag)
		if (te.is_connected)
			sprint(te,#PRINT_HIGH,text);

		te = find(te, classname, "player");
	}
	
	te = find(world, classname, "spec");
	while (te)
	{			 
		if (te.admin_flag)
		if (te.is_connected)
			sprint(te,#PRINT_HIGH,text);

		te = find(te, classname, "spec");
	}
};

void(string s1, string s2, string s3, string s4, string s5, string s6, string s7, string s8) PrintToAdmins =
{
	local entity te;

	te = find(world, classname, "player");
	while (te)
	{			 
		if (te.admin_flag)
		if (te.is_connected)
		{
			sprint(te,#PRINT_HIGH,s1);			  
			sprint(te,#PRINT_HIGH,s2);
			sprint(te,#PRINT_HIGH,s3);
			sprint(te,#PRINT_HIGH,s4);
			sprint(te,#PRINT_HIGH,s5);
			sprint(te,#PRINT_HIGH,s6);
			sprint(te,#PRINT_HIGH,s7);
			sprint(te,#PRINT_HIGH,s8);
		}

		te = find(te, classname, "player");
	}
	
	te = find(world, classname, "spec");
	while (te)
	{			 
		if (te.admin_flag)
		if (te.is_connected)
		{
			sprint(te,#PRINT_HIGH,s1);			  
			sprint(te,#PRINT_HIGH,s2);
			sprint(te,#PRINT_HIGH,s3);
			sprint(te,#PRINT_HIGH,s4);
			sprint(te,#PRINT_HIGH,s5);
			sprint(te,#PRINT_HIGH,s6);
			sprint(te,#PRINT_HIGH,s7);
			sprint(te,#PRINT_HIGH,s8);
		}

		te = find(te, classname, "spec");
	}
};

//===============================================================
// Admin logged in event

void(entity admin) AdminLoggedIn =
{
	local string text;

	text = strcat("User ",admin.netname);
	text = strcat(text," logged in as admin.\n");
	
	RPrint(text);
	NotifyAdmins(text);
};

//===============================================================
// Admin logged out event

void(entity admin) AdminLoggedOut =
{
	local string text;

	text = strcat("User ",admin.netname);
	text = strcat(text," logged out as admin.\n");

	RPrint(text);
	NotifyAdmins(text);
};

//================================================================
// Tells a message from an user to all admins logged in

float(entity user, string str) Admin_Tell =
{
	local float numadmins;
	local entity admin;
	local string st;

	if (mutedtime(user))
	{
		sprint(user,#PRINT_HIGH,"You are muted!\n");
		return 99;
	}

	st = colstr(str,#COLSTR_RED);

	numadmins = 0;

	admin = find(world,classname,"player");

	while (admin)
	{
		if (admin.admin_flag)
		if (admin.is_connected)
		{
			numadmins = numadmins + 1;
			sprint(admin,#PRINT_HIGH,"To Adminsç (",user.netname,"): ",st,"\n");
			stuffcmd(admin,"play misc/talk\n");
		}
		
		admin = find(admin,classname,"player");
	}

	admin = find(world,classname,"spec");

	while (admin)
	{
		if (admin.admin_flag)
		if (admin.is_connected)
		{
			numadmins = numadmins + 1;
			sprint(admin,#PRINT_HIGH,"To Adminsç (",user.netname,"): ",st,"\n");
			stuffcmd(admin,"play misc/talk\n");
		}
		
		admin = find(admin,classname,"spec");
	}

	putsaytime(user);

	if (!user.admin_flag && numadmins > 0)
	{
		sprint(user,#PRINT_HIGH,"To Adminsç (",user.netname,"): ",st,"\n");
		stuffcmd(user,"play misc/talk\n");
	}

	dprint("To Adminsç (");
	dprint(user.netname);
	dprint("): ");
	dprint(str);
	dprint("\n");

	if (!numadmins)
		sprint(user,#PRINT_HIGH,"No admins logged in server currently!\n");
	else
	{
		if (numadmins == 1)
			sprint(user,#PRINT_HIGH,"€ admin reading this›\n");
		else
		{
			st = ftos(numadmins);
			st = colstr(st,#COLSTR_NUMBER);

			sprint(user,#PRINT_HIGH,"€",st," admins reading this›\n");			  
		}
	}

	return numadmins;
};

//=======================================================================
// Ends current map if possible

void() Admin_EndGame =
{
	if (intermission_running)
	{
		sprint(self,#PRINT_HIGH,"The map already ended!\n");
		return;
	}

	if (ServerUpdating())
	{
		sprint(self,#PRINT_HIGH,"Unable to end the map during a server update!\n");
		return;
	}

	if (time < 20)
	{
		sprint(self,#PRINT_HIGH,"There must pass 20 seconds at least to be able to end a map!\n");
		return;
	}

	ceasefire = #FALSE;

	bprint(#PRINT_HIGH,"The admin ",self.netname," ends the current game.\n");
								
	NextLevel ();
};

//==========================================================
// Prints a sermon on a player client

void(string st, float action) Admin_Sermon =
{
	local float predef;

	predef = 0;

	if (st == "1") // TK
		predef = 1;
	else if (st == "2") // Cheating
		predef = 2;
		
	if (self.admin_kick == world || self.admin_kick.classname != "player" || !self.admin_kick.is_connected)
	{
		sprint(self,#PRINT_HIGH,"Bad player selected as target for sermon!\n");
		return;
	}

	if (self.flags & #FL_FINALIZED)
	{
		sprint(self,#PRINT_HIGH,"Already showing a sermon for that player!\n");
		return;
	}

	if (st == "")
	{
		sprint(self,#PRINT_HIGH,"You should specify a string for the sermon or a number (1=tk or 2=cheats)!\n");
		return;
	}

	PlayerFinal(self.admin_kick,st,action,predef);

	if (action == 2)
		bprint(#PRINT_HIGH,"The admin ",self.netname, " decides to ban ",self.admin_kick.netname," after a sermon");
	else if (action == 1)
		bprint(#PRINT_HIGH,"The admin ",self.netname, " decides to kick ",self.admin_kick.netname," after a sermon");
	else
		bprint(#PRINT_HIGH,"The admin ",self.netname, " sermonizes ",self.admin_kick.netname);

	if (predef == 1)
		bprint(#PRINT_HIGH," about teamkilling\n");
	else if (predef == 2)
		bprint(#PRINT_HIGH," about cheating\n");
	else
		bprint(#PRINT_HIGH,"\n");
};

//==============================================================================
// Isn't the bitching of kids annoying sometimes while playing?

float(float mode, float mutetime) Admin_Silence =
{
	local entity te;
	local string st, st2;
	local float fl, counter;

	if (mode == 0 || mode == 1) // Players
	{
		te = find(te,classname,"player");

		while (te)
		{
			if (te.is_connected)
			if (!te.admin_flag)
			{
				fl = getuid(te);
				st = ftos(fl);
				st2 = ftos(mutetime);

				localcmd("mute 00");
				localcmd(st);
				localcmd(" ");
				localcmd(st2);
				localcmd("\n");

				counter = counter + 1;
			}
			
			te = find(te,classname,"player");
		}
	}
	
	if (mode == 2 || mode == 0) // Spectators
	{
		te = find(te,classname,"spec");

		while (te)
		{
			if (te.is_connected)
			if (!te.admin_flag)
			{
				fl = getuid(te);
				st = ftos(fl);
				st2 = ftos(mutetime);

				localcmd("mute 00");
				localcmd(st);
				localcmd(" ");
				localcmd(st2);
				localcmd("\n");

				counter = counter + 1;
			}

			te = find(te,classname,"spec");
		}
	}

	if (mutetime > 0)
	{
		bprint(#PRINT_HIGH,"The admin ",self.netname," imposes silence ");
		if (mode == 0)
			bprint(#PRINT_HIGH,"among all clients\n");
		else if (mode == 1)
			bprint(#PRINT_HIGH,"among players\n");
		else if (mode == 2)
			bprint(#PRINT_HIGH,"among spectators\n");
	}
	else
	{
		bprint(#PRINT_HIGH,"The admin ",self.netname," allows all ");
		if (mode == 0)
			bprint(#PRINT_HIGH,"clients");
		else if (mode == 1)
			bprint(#PRINT_HIGH,"players");
		else if (mode == 2)
			bprint(#PRINT_HIGH,"spectators");
		bprint(#PRINT_HIGH," to speak\n");
	}

	return counter;
};

//=======================================================================
// Admin requests info about a client

void() Admin_Check =
{
	local string st;
	local float tmpf;

	if (self.admin_kick != world) //Bad
	{
		if (!HasValidAdminTarget(self))
			return;

		sprint(self,#PRINT_HIGH,"ùûûü √ÏÈÂÓÙ …ÓÊÔÚÌ·ÙÈÔÓ √ËÂ„ÎÛ: ùûûü\n");
		tmpf = getuid(self.admin_kick);
		st = ftos(tmpf);
		st = colstr(st,#COLSTR_NUMBER);
		sprint(self, #PRINT_HIGH,"Œ·ÌÂ: ",self.admin_kick.netname,"\n’ÛÂÚ…ƒ: ",st," ú …–: ");
		st = infokey(self.admin_kick,"ip");
		st = colstr(st,#COLSTR_NUMBER);
		sprint(self, #PRINT_HIGH,st,"\n√Ï·ÈÌÂ‰: ");
		st = GetClientDescription(self.admin_kick);
		sprint(self, #PRINT_HIGH,st,"\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n");
	}
	else
		sprint(self, #PRINT_HIGH, "No target client selected!\n");
};
