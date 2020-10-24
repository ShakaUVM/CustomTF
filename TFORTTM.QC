/* 
	TeamFortress 2.1	-	22/1/97

	TeamFortress Software
	Robin Walker, John Cook, Ian Caughley.

	Functions handling all the help displaying for TeamFortress. 
*/
// Prototypes
// Team Functions
void (float full_clean) CleanUpEverything;
float() TeamFortress_TeamPutPlayerInTeam;
float(float tno) TeamFortress_TeamSet;
float(float tno) TeamFortress_TeamGetColor;
void(float tno) TeamFortress_TeamSetColor;
void() TeamFortress_CheckTeamCheats;
void(float tno, float scoretoadd) TeamFortress_TeamIncreaseScore;
float(float tno) TeamFortress_TeamGetScore;
float (float tno) TeamFortress_TeamGetLives;
float(float tno) TeamFortress_TeamGetNoPlayers;
float (float tno) TeamFortress_TeamGetMaxPlayers;
float() TeamFortress_TeamGetWinner;
void(float all, float teamscored, float scorepoints) TeamFortress_TeamShowScores;
string(float tno) TeamFortress_TeamGetColorString;
void(entity Player) TeamFortress_TeamShowMemberClasses;
float(float tno) TeamFortress_TeamGetIllegalClasses;
float(float tno) TeamFortress_TeamIsCivilian;
#ifdef QUAKE_WORLD
void(entity p) SetTeamName;
#endif
string(float tno) GetTrueTeamName;

//-------- OfN ---------------------------------//
void(float tno, entity ignore) teamprefixsprint;

//- OfN - Extra cheat checking...
float (string skin_str) Is_TF_Skin;
float (float tno, float theColor ) IsValidTopColor;

//=========================================================================
// TEAM FUNCTIONS
//=========================================================================
// Put the player into the team with the least number of players in it. Return #TRUE if successful
float() TeamFortress_TeamPutPlayerInTeam =
{
	local float i, j, lowest, likely_team;
	//local string st;

	//WK 1/7/7 Use KKMay's Server Side function to do this??

	i = 1;
	likely_team = random() * number_of_teams;
	likely_team = ceil(likely_team);
	if (likely_team == 0)
		likely_team = number_of_teams;
	lowest = 33;
	while (i < (number_of_teams + 1))
	{
		j = TeamFortress_TeamGetNoPlayers(i);
		if (j <= lowest) //WK j < lowest
		{
			// Is the team full?
			if (TeamFortress_TeamGetMaxPlayers(i) > j)
			{
				if (lowest == j) { //WK tie
					if (random() < (1/number_of_teams)) {
						lowest = j;
						likely_team = i;
					}
				}
				else {
					lowest = j;
					likely_team = i;
				}
			}
		}
		i = i + 1;
	}

	// Put the player in likely_team
	return TeamFortress_TeamSet(likely_team);
};

//=========================================================================
// Return the color for the team corresponding to the no passed in
float(float tno) TeamFortress_TeamGetColor =
{
	if (tno == 1)
		return #DARKBLUE;
	if (tno == 2)
	{
		// Neo mode
		if (neo) return #WHITE;

		return #RED;
	}
	if (tno == 3)
		return #YELLOW;
	if (tno == 4)
		return #DARKGREEN;

	return 0;
};

//=========================================================================
// Set the color for the team corresponding to the no passed in, to self.team_no
void(float tno) TeamFortress_TeamSetColor =
{
	if (tno == 1)
	{
		team1col = #DARKBLUE;
		return;
	}
	if (tno == 2)
	{
		if (neo) team2col = #WHITE; // Neo mode
		else team2col = #RED;
		return;
	}
	if (tno == 3)
	{
		team3col = #YELLOW;
		return;
	}
	if (tno == 4)
	{
		team4col = #DARKGREEN;
		return;
	}
};

#ifdef QUAKE_WORLD
string(float tno) GetTeamName =
{
	local string st;

	if (tno == 1)
	{
		/*if (world.b_b != "" && world.b_b != string_null)
		{
			return world.b_b;
		}*/

		// for Neo mode
		if (neo)
		{
			local string temp;
			temp = colstr("Neo", #COLSTR_RED);
			return temp;
		}

		st = infokey(world, "team1");
		if (st == string_null)
			st = infokey(world, "t1");

		if (st == string_null || st == "")
			return "blue";
	}
	else if (tno == 2)
	{
		/*if (world.b_t != "" && world.b_t != string_null)
		{
			return world.b_t;
		}*/

		// for Neo mode
		if (neo) return "Smth";
		
		st = infokey(world, "team2");
		if (st == string_null)
			st = infokey(world, "t2");

		if (st == string_null || st == "")
			return "red";
	}
	else if (tno == 3)
	{
		/*if (world.b_n != "" && world.b_n != string_null)
		{
			return world.b_n;
		}*/
		
		st = infokey(world, "team3");
		if (st == string_null)
			st = infokey(world, "t3");

		if (st == string_null || st == "")
			return "yell";
	}
	else if (tno == 4)
	{
		/*if (world.b_o != "" && world.b_o != string_null)
		{
			return world.b_o;
		}*/

		st = infokey(world, "team4");
		if (st == string_null)
			st = infokey(world, "t4");

		if (st == string_null || st == "")
			return "teal";
	}
	else 
		st = "\"\"";

	return st;
};
//returns only the team color
string(float tno) GetTrueTeamName =
{
	if (tno == 1)
		return "Âìõå";
	else if (tno == 2)
		return "Òåä";
	else if (tno == 3)
		return "Ùåììï÷";
	else if (tno == 4)
		return "Çòååî";
	else 
		return "ERROR";
};
#endif

#ifdef QUAKE_WORLD
void(entity p) SetTeamName =
{
	local string st;

	stuffcmd(p, "team ");
	st = GetTeamName(p.team_no);
	stuffcmd(p, st);
	stuffcmd(p, "\n");
};
#endif

//=========================================================================
// Set the current player's.team_no to self.impulse. Return #TRUE if successful
float(float tno) TeamFortress_TeamSet =
{
	local string st;
	local float tc;

	if (teamplay < 1)
	{
		sprint (self, #PRINT_HIGH, "Teamplay is not On, so FortressTeams are inactive.\n");
		return #FALSE;
	}
	
/*	if (chris)
		if (prematch > time)
		{
			sprint(self, #PRINT_HIGH, "Sorry, Chris' Teamplay Plus Mode is active and a round is in progress. Please wait for the next round to begin.\n");
			PlayerObserverMode();
		}*/

	if (tno > number_of_teams && number_of_teams != 0)
	{
		sprint (self, #PRINT_HIGH, "There can be only ");
		st = ftos(number_of_teams);
		sprint (self, #PRINT_HIGH, st);
		sprint (self, #PRINT_HIGH, " teams on this map.\nTry again\n");
		return #FALSE;
	}

	if (self.team_no > 0)
	{
	/* WK 5-15-08 We allow people to switch teams in play now
		It just blows up all your stuff
		sprint (self, #PRINT_HIGH, "You're already in Team No ");
		st = ftos(self.team_no);
		sprint (self, #PRINT_HIGH, st);
		sprint (self, #PRINT_HIGH, ".\n");
		return #FALSE;
		*/
		CleanUpEverything(#TRUE);
	}

	tc = TeamFortress_TeamGetNoPlayers(tno);
	if (tc >= TeamFortress_TeamGetMaxPlayers(tno))
	{
		//- OfN
		if (mapname == "huntedr")
		{
			if (tno == 3)
				sprint (self, #PRINT_HIGH, "The game has already enough assassins, be a bodyguard.\n");
			else if (tno == 1)
				sprint (self, #PRINT_HIGH, "You wanna be the vicepresident or what?\n");
		}
		else
			sprint (self, #PRINT_HIGH, "That team is full. Pick another.\n");

		return #FALSE;
	}

	// If the color for the team this player is changing to is 0,
	// then this is the first player in this team, and we set the
	// teamcolor to this player's pants color.
	// If not, we change this player's color to this team.
	if (TeamFortress_TeamGetColor(tno) == 0)
	{
		TeamFortress_TeamSetColor(tno);
		// If the color wasn't set
		if (TeamFortress_TeamGetColor(tno) == 0)
		{
			sprint (self, #PRINT_HIGH, "You can't start a new team with your color, since another ");
			sprint (self, #PRINT_HIGH, "already using that color. Change your pants color, then try again.\n");
			return #FALSE;
		}

		// Announce the new team
		bprint(#PRINT_HIGH, self.netname);
		bprint(#PRINT_HIGH, " has started Team No ");
		st = ftos(tno);
		bprint(#PRINT_HIGH, st);
		bprint(#PRINT_HIGH, ".\n");

		// Prevent the cheatchecking mechanism from nabbing them b4 the 
		// color command works.
		makeImmune(self,time+10);
		//self.immune_to_check = time + 10;

		// Set the player's color
		stuffcmd(self, "color ");
		tc = TeamFortress_TeamGetColor(tno) - 1;
		st = ftos(tc);

		 //- OfN - Nice colors
		if (nicecolors==1) st =TeamGetNiceColor(tno);

		stuffcmd(self, st);
		stuffcmd(self, "\n");

		self.team_no = tno;
		self.connect_time = time; //WK 5-15-08 Start their time they "connected" from the time they joined the team. This gets reset if they switch teams to stop abuse from joining a team to force a reteam of someone on the other side.
		self.lives = TeamFortress_TeamGetLives(tno);

	#ifdef QUAKE_WORLD
		SetTeamName(self);
	#endif

		// Set the Civilian Class of anyone in a Civilian Team
		if (self.playerclass == #PC_UNDEFINED)
		{
			if (TeamFortress_TeamIsCivilian(self.team_no))
			{
				self.impulse = 1;
				TeamFortress_ChangeClass();
			}
		}

		return #TRUE;
	}

	// Announce the new teammember
	#ifndef OLD_TEAM_ANNOUNCEMENTS
	bprint(#PRINT_HIGH, self.netname);
	bprint(#PRINT_HIGH, " has joined Team No ");
	st = ftos(tno);
	bprint(#PRINT_HIGH, st);
	st = GetTrueTeamName(tno);
	bprint(#PRINT_HIGH, " (", st, " team)\n");

	#else
	
	bprint(#PRINT_HIGH, self.netname);
	bprint(#PRINT_HIGH, " has joined Team No ");
	st = ftos(tno);
	bprint(#PRINT_HIGH, ".\n");
	#endif
	
	// Set the player's color
	stuffcmd(self, "color ");
	tc = TeamFortress_TeamGetColor(tno) - 1;
	st = ftos(tc);

	//- OfN - Nice colors
	if (nicecolors==1) st =TeamGetNiceColor(tno);

	stuffcmd(self, st);
	stuffcmd(self, "\n");

	self.team_no = tno;
	self.connect_time = time; //WK 5-15-08 Start their time they "connected" from the time they joined the team. This gets reset if they switch teams to stop abuse from joining a team to force a reteam of someone on the other side.

	// Prevent the cheatchecking mechanism from nabbing them b4 the 
	// color command works.
	makeImmune(self,time+10);
	//self.immune_to_check = time + 10;
	self.lives = TeamFortress_TeamGetLives(tno);

	// Tell them what class the other members of their team are
	TeamFortress_TeamShowMemberClasses(self);

#ifdef QUAKE_WORLD
	SetTeamName(self);
#endif

	// Set the Civilian Class of anyone in a Civilian Team
	if (self.playerclass == #PC_UNDEFINED)
	{
		if (TeamFortress_TeamIsCivilian(self.team_no))
		{
			self.impulse = 1;
			TeamFortress_ChangeClass();
		}
	}
//RJM
	if (toggleflags & #TFLAG_TEAMFRAGS)
		self.frags = TeamFortress_TeamGetScore(self.team_no);
//RJM

	//- OfN Team3 should have less players than red in Hunted
	if (mapname == "huntedr")
	{
		local float result;
		result = floor(TeamFortress_TeamGetNoPlayers(2) * #HUNTED_YELLOWTEAM_FACTOR);
		team3maxplayers = result;
		if (team3maxplayers < 1) team3maxplayers = 1;
	}
	else
	if (mapname == "border1" || mapname == "border1r")
	{
		local float result;
		result = floor(TeamFortress_TeamGetNoPlayers(2) * #BORDER_FACTOR);
		team3maxplayers = result;
		team1maxplayers = result;
		if (team3maxplayers < 1) team3maxplayers = 1;
		if (team1maxplayers < 1) team1maxplayers = 1;
	}

	// OfN - Adjust his teammates army rating as needed
	ArmyRatingJoin(self);

	// PZ - created playersOnTeam# for AGR mode
	if		(self.team_no == 1) playersOnTeam1 = playersOnTeam1 + 1;
	else if (self.team_no == 2) playersOnTeam2 = playersOnTeam2 + 1;
	else if (self.team_no == 3) playersOnTeam3 = playersOnTeam3 + 1;
	else if (self.team_no == 4) playersOnTeam4 = playersOnTeam4 + 1;

	return #TRUE;
};

//=========================================================================
// Make sure no-one is changing their colors
void() TeamFortress_CheckTeamCheats =
{
	local string st, sk;
	local float tc;
	local float rate;

	if (self.immune_to_chec > time)
		return;

	if (self.deadflag)
		return;

#ifdef COOP_MODE
	if (coop && !deathmatch)	// don't worry about it if in coop game
		return;
#endif

	//WK Add in hack for "skins" cheat. This is as good a place as any
	if (self.netname == string_null) {
		stuffcmd(self,"name \"I'm a cheater even when RENAMED\"\n");
		stuffcmd(self,"disconnect\n");
	}

#ifdef QUAKE_WORLD
	//WK Limit rate to 10k?
	st = infokey(self,"rate");
	if (st != string_null)
		rate = stof(st);
	if (rate > 10000) {
		stuffcmd(self,"rate 10000\n");
	}
#endif

	//- OfN - Added checking for topcolor changes... (see IsValidTopColor in OfteN.qc)
	local float tTopColor;
	st = infokey(self,"topcolor");
	tTopColor=stof(st);

	// Have they changed color?
	if (self.team_no > 0 && teamplay > 0)
	{
	#ifndef QUAKE_WORLD
		// if they're a spy, check to see if they've changed colors manually
		if ((self.cutf_items & #CUTF_SPY_KIT) && self.undercover_team != 0)
		{
			if (TeamFortress_TeamGetColor(self.undercover_team) != self.team) //- OfN
			//if ((TeamFortress_TeamGetColor(self.undercover_team) != self.team) || !IsValidTopColor(self.undercover_team,tTopColor))
			//	|| !IsValidTopColor(self.undercover_team,tTopColor)
			{
				// Set their color 
				stuffcmd(self, "color ");
				tc = TeamFortress_TeamGetColor(self.undercover_team) - 1;
				
				st = ftos(tc);

				//- OfN - Nice colors
				if (nicecolors==1) st =TeamGetNiceColor(self.undercover_team);

				stuffcmd(self, st);
				stuffcmd(self, "\n");

				bprint2(#PRINT_MEDIUM, self.netname, " has been kicked for changing color.\n");
				sprint(self, #PRINT_HIGH, "You have been kicked for changing your color. Don't do it.\n");
				stuffcmd(self, "disconnect\n");
				return;
			}
		}
		else if (TeamFortress_TeamGetColor(self.team_no) != self.team)
		{
			// Set their color 
			stuffcmd(self, "color ");
			tc = TeamFortress_TeamGetColor(self.team_no) - 1;
			st = ftos(tc);

			//- OfN - Nice colors
			if (nicecolors==1) st =TeamGetNiceColor(self.team_no);

			stuffcmd(self, st);
			stuffcmd(self, "\n");

			bprint2(#PRINT_MEDIUM, self.netname, " has been kicked for changing color.\n");
			sprint(self, #PRINT_HIGH, "You have been kicked for changing your color. Don't do it.\n");
			stuffcmd(self, "disconnect\n");
			return;
		}
	#else
		// QuakeWorld
		st = infokey(self, "bottomcolor");
		tc = stof(st);
		// if they're a spy, check to see if they've changed colors manually
		if ((self.cutf_items & #CUTF_SPY_KIT) && self.undercover_team != 0)
		{
			if ((TeamFortress_TeamGetColor(self.undercover_team) - 1) != tc || !IsValidTopColor(self.undercover_team,tTopColor))
			{
			#ifdef CHEAT_WARNINGS
				RPrint(self.netname);
				RPrint(" had his colors reset.\n");
			#endif

				// Set the player's color
				stuffcmd(self, "color ");
				tc = TeamFortress_TeamGetColor(self.undercover_team) - 1;
				st = ftos(tc);

				//- OfN - Nice colors
				if (nicecolors==1) st =TeamGetNiceColor(self.undercover_team);

				stuffcmd(self, st);
				stuffcmd(self, "\n");

				bprint2(#PRINT_MEDIUM, self.netname, " has been kicked for changing color.\n");
				sprint(self, #PRINT_HIGH, "You have been kicked for changing your color. Don't do it.\n");
				stuffcmd(self, "disconnect\n");
				return;
			}
		}
		else if (tc != (TeamFortress_TeamGetColor(self.team_no) - 1) || !IsValidTopColor(self.team_no,tTopColor))
		{
		#ifdef CHEAT_WARNINGS
			RPrint(self.netname);
			RPrint(" had his colors reset.\n");
		#endif

			// Set the player's color
			stuffcmd(self, "color ");
			tc = TeamFortress_TeamGetColor(self.team_no) - 1;
			st = ftos(tc);

			//- OfN - Nice colors
			if (nicecolors==1) st =TeamGetNiceColor(self.team_no);

			stuffcmd(self, st);
			stuffcmd(self, "\n");

			bprint2(#PRINT_MEDIUM, self.netname, " has been kicked for changing color.\n");
			sprint(self, #PRINT_HIGH, "You have been kicked for changing your color. Don't do it.\n");
			stuffcmd(self, "disconnect\n");
			return;
		}

	#endif

		// Have they changed their skin?
	#ifdef QUAKE_WORLD
		if (self.playerclass != #PC_UNDEFINED)
		{
			//WK For some reason, this isn't reading right for el PC_CUSTOM
			st = infokey(self, "skin");
			tc = 0;

			// OfN kick custom player classes using a non TF-skin
			if (self.playerclass == #PC_CUSTOM && !Is_TF_Skin(st))
			{
				TeamFortress_SetSkin(self);

				bprint2(#PRINT_MEDIUM, self.netname, " has been kicked for changing skin.\n");
				sprint(self, #PRINT_HIGH, "You have been kicked for changing your skin. Don't do it.\n");
				stuffcmd(self, "disconnect\n"); 			   
			}

			if ((self.cutf_items & #CUTF_SPY_KIT) && self.undercover_skin != 0)
			{
				//WK tc = #PC_SPY;
				tc = self.playerclass;
				self.playerclass = self.undercover_skin;
			}

			if ( self.playerclass == #PC_SCOUT )
				sk = "tf_scout";
			else if ( self.playerclass == #PC_SNIPER )
				sk = "tf_snipe";
			else if ( self.playerclass == #PC_SOLDIER )
				sk = "tf_sold";
			else if ( self.playerclass == #PC_DEMOMAN )
				sk = "tf_demo";
			else if ( self.playerclass == #PC_MEDIC )
				sk = "tf_medic";
			else if ( self.playerclass == #PC_HVYWEAP )
				sk = "tf_hwguy";
			else if ( self.playerclass == #PC_PYRO )
				sk = "tf_pyro";
			else if ( self.playerclass == #PC_SPY )
				sk = "tf_spy";
			else if ( self.playerclass == #PC_ENGINEER )
				sk = "tf_eng";
			else
			{
				if ((self.cutf_items & #CUTF_SPY_KIT) && self.undercover_skin != 0)
				{
					self.playerclass = tc;
				}
				return; //WK Don't check as a safety precaution.
			}

			if (self.cutf_items & #CUTF_SPY_KIT && self.undercover_skin != 0)
				{
					//sprint(self,#PRINT_HIGH,"Mommy Wuvs You!\n");
					self.playerclass = tc;
				}

			//WK Ignore our custom, spy-kitting friends. Kick everyone else
			if ((st != sk) && !((self.playerclass == #PC_CUSTOM) && (self.cutf_items & #CUTF_SPY_KIT)))
			{
				#ifdef CHEAT_WARNINGS
					RPrint(self.netname);
					RPrint(" had his skin reset.\n");
				#endif

				TeamFortress_SetSkin(self);

				bprint2(#PRINT_MEDIUM, self.netname, " has been kicked for changing skin.\n");
				sprint(self, #PRINT_HIGH, "You have been kicked for changing your skin. Don't do it.\n");
				stuffcmd(self, "disconnect\n");
			}

		}


		// Have they Changed their Team?
		st = GetTeamName(self.team_no);
		if (st != infokey(self, "team"))
		{
		if (self.penance_time < time) { //Ignore if we're cursed

		#ifdef CHEAT_WARNINGS
			RPrint(self.netname);
			RPrint(" had his team reset.\n");
		#endif

			// Set the player's team
			SetTeamName(self);
			bprint2(#PRINT_MEDIUM, self.netname, " has been kicked for changing team.\n");
			sprint(self, #PRINT_HIGH, "You have been kicked for changing your team. Don't do it.\n");
			stuffcmd(self, "disconnect\n");
			return;
		}
		}
	#endif
	}
};

//=========================================================================
// Increase the score of a team
void(float tno, float scoretoadd) TeamFortress_TeamIncreaseScore =
{
	local entity e;

	if (tno == 0 || scoretoadd == 0)
		return;

	if (tno == 1)
		team1score = team1score + scoretoadd;
	if (tno == 2)
		team2score = team2score + scoretoadd;
	if (tno == 3)
		team3score = team3score + scoretoadd;
	if (tno == 4)
		team4score = team4score + scoretoadd;

	// If TeamFrags is on, update all the team's player's frags.
	if (toggleflags & #TFLAG_TEAMFRAGS)
	{
		e = find(world, classname, "player");
		while (e)
		{
			if (e.team_no == tno)
				e.frags = TeamFortress_TeamGetScore(tno);
			e = find(e, classname, "player");
		}
	}
};

//=========================================================================
// Return the score of a team
float (float tno) TeamFortress_TeamGetScore =
{
	if (tno == 1)
		return team1score;
	if (tno == 2)
		return team2score;
	if (tno == 3)
		return team3score;
	if (tno == 4)
		return team4score;

	return 0;
};

//=========================================================================
// Return the number of lives each team member in a team has
float (float tno) TeamFortress_TeamGetLives =
{
	if (tno == 1)
		return team1lives;
	if (tno == 2)
		return team2lives;
	if (tno == 3)
		return team3lives;
	if (tno == 4)
		return team4lives;

	return 0;
};

//=========================================================================
// WK -- Return the number of players in the game
// WK -- We really needed a function like this for a while. =p (4/27/7)
float () TeamFortress_GetNoPlayers =
{
	local float playercount;
	local entity search;

	playercount = 0;
	search = find (world, classname, "player");
	while (search != world)
	{
		playercount = playercount + 1;
		search = find (search, classname, "player");
	}

	return playercount;
};

//=========================================================================
// Return the number of players in a team
float (float tno) TeamFortress_TeamGetNoPlayers =
{
	local float size_team;
	local entity search;
	//local string st;

	search = find (world, classname, "player");
	while (search != world)
	{
		if (search.team_no == tno)
			size_team = size_team + 1;
		search = find (search, classname, "player");
	}

	return size_team;
};

//=========================================================================
// Return the number of lives each team member in a team has
float (float tno) TeamFortress_TeamGetMaxPlayers =
{
	if (tno == 1)
		return team1maxplayers;
	if (tno == 2)
		return team2maxplayers;
	if (tno == 3)
		return team3maxplayers;
	if (tno == 4)
		return team4maxplayers;

	return 0;
};

//=========================================================================
// Return the team that's winning
float() TeamFortress_TeamGetWinner =
{
	local float i,j,highest,highestteam;

	i = 1;
	highest = 0;
	highestteam = 0;
	while (i < (number_of_teams + 1))
	{
		j = TeamFortress_TeamGetScore(i);
		if (j > highest)
		{
			highest = j;
			highestteam = i;
		}
		i = i + 1;
	}

	return highestteam;
};

//=========================================================================
// Return the team that's winning
/*CH i saw no uses
float() TeamFortress_TeamGetSecond =
{
	local float i,j,highest,highestteam, secondteam, second;

	i = 1;
	highestteam = TeamFortress_TeamGetWinner();
	highest = TeamFortress_TeamGetScore(highestteam);
	secondteam = 0;
	second = 0;
	while (i < (number_of_teams + 1))
	{
		j = TeamFortress_TeamGetScore(i);
		if (j < highest && j > second)
		{
			second = j;
			secondteam = i;
		}
		i = i + 1;
	}

	return secondteam;
};
*/
//=========================================================================
// Display all the Team Scores
void(float all, float teamscored, float scorepoints) TeamFortress_TeamShowScores =
{
	local string st;
	local float i,j;

	i = 1;

	// OfN - End of map team scores
	if (all == 3)
	{
		// long scores
		while (i <= number_of_teams)
		{
			if (TeamFortress_TeamGetColor(i) > 0)
			{
				st = ftos(i);
				bprint (#PRINT_HIGH, "Team ", st, " (");

				st = GetTrueTeamName(i);
				st = strcat(st,") ");
				st = padstr(st,8);
				st = strcat(st,": ");
				bprint (#PRINT_HIGH, st); 
				
				j = TeamFortress_TeamGetScore(i);
				st = ftos(j);
				st = colstr(st,#COLSTR_NUMBER);

				if (j < 10)
					bprint(#PRINT_HIGH,"  ");
				else if (j < 100)
					bprint(#PRINT_HIGH," ");				

				bprint (#PRINT_HIGH, st, " points\n");
			}
			i = i + 1;
		}
		return;
	}
		
	// short scores
	if (all == 2)
	{
		while (i <= number_of_teams)
		{
			if (TeamFortress_TeamGetColor(i) > 0)
			{
				j = TeamFortress_TeamGetScore(i);
				st = TeamFortress_TeamGetColorString(i);

				bprint(#PRINT_HIGH, st);
				bprint(#PRINT_HIGH, ": ");
				st = ftos(j);
				bprint(#PRINT_HIGH, st);
				bprint(#PRINT_HIGH, " ");
			}
			i = i + 1;
		}
		
		if (!teamscored)
			bprint(#PRINT_HIGH," (mixed scoring)\n");
		else
		{
			st = GetTrueTeamName(teamscored);
			bprint(#PRINT_HIGH," [",st," scores ");
			st = ftos(scorepoints);
			st = colstr(st,#COLSTR_NUMBER);
			bprint(#PRINT_HIGH,st,"]\n");		
		}

		return;
	}

	// long scores
	while (i <= number_of_teams)
	{
		if (TeamFortress_TeamGetColor(i) > 0)
		{
			if (all)
				bprint (#PRINT_HIGH, "Team ");
			else
				sprint (self, #PRINT_HIGH, "Team ");

			st = ftos(i);
			if (all)
				bprint (#PRINT_HIGH, st);
			else
				sprint (self, #PRINT_HIGH, st);

			if (all)
				bprint (#PRINT_HIGH, " (");
			else
				sprint (self, #PRINT_HIGH, " (");

			st = TeamFortress_TeamGetColorString(i);
			if (all)
				bprint (#PRINT_HIGH, st);
			else
				sprint (self, #PRINT_HIGH, st);

			if (all)
				bprint (#PRINT_HIGH, ") : ");
			else
				sprint (self, #PRINT_HIGH, ") : ");
			
			j = TeamFortress_TeamGetScore(i);
			st = ftos(j);

			if (all)
				bprint (#PRINT_HIGH, st);
			else
				sprint (self, #PRINT_HIGH, st);

			if (all)
				bprint (#PRINT_HIGH, "\n");
			else
				sprint (self, #PRINT_HIGH, "\n");
		}
		i = i + 1;
	}
};

//=========================================================================
// Return a string containing the color of the team passed in tno
string(float tno) TeamFortress_TeamGetColorString =
{
	local float col;

	col = TeamFortress_TeamGetColor(tno);
	if (col == 1)
		return "White";
	if (col == 2)
		return "Brown";
	if (col == 3)
		return "LightBlue"; //- OfN was blue
	if (col == 4)
		return "Green";
	if (col == 5)
		return "Red";
	if (col == 6)
		return "Tan";
	if (col == 7)
		return "Pink";
	if (col == 8)
		return "Orange";
	if (col == 9)
		return "Purple";
	if (col == 10)
		return "DarkPurple";
	if (col == 11)
		return "Grey";
	if (col == 12)
		return "Teal";//"DarkGreen";
	if (col == 13)
		return "Yellow";

	return "Blue"; // was DarkBlue
};

//=========================================================================
// Print to the Player's screen a list of all the members of his/her
// team, and the class they've chosen
void(entity Player) TeamFortress_TeamShowMemberClasses =
{
	/*local string st;
	st = infokey(world, "no_showmembers");	*/
	
	local entity e;
	local float found;

	found = #FALSE;

	e = find(world, classname, "player");
	while (e)
	{
		if (((e.team_no == Player.team_no) || (e.team_no == 0)) && (e != Player))
		{
			if (e.model != string_null) // check if valid player
			{
				if (!found)
				{
					found = #TRUE;
					sprint (self, #PRINT_HIGH, "The other members of your team are:\n");
				}

				sprint (Player, #PRINT_HIGH, e.netname);
				sprint (Player, #PRINT_HIGH, " : ");
				if (e.playerclass != #PC_CUSTOM)
					TeamFortress_PrintClassName(Player,e.playerclass, (e.tfstate & #TFSTATE_RANDOMPC));
				else
					TeamFortress_PrintJobName(Player,e.job);
					
			}
		}
		e = find(e, classname, "player");
	}

	if (!found)
	{
		sprint (Player, #PRINT_HIGH, "There are no other players on your team.\n");
	}
};


void() CalculateTeamEqualiser =
{
	local float t1, t2, t3, t4;
	local float t_ave, calc;

	team1advantage = 1;
	team2advantage = 1;
	team3advantage = 1;
	team4advantage = 1;

	if (number_of_teams < 2)
	{
		// not enought teams!
		// wait a while, then try again (more teams may be created)
		self.nextthink = time + 60;
		return;
	}
	
	if (teamplay & #TEAMPLAY_LESSPLAYERSHELP)
	{

		t1 = TeamFortress_TeamGetNoPlayers(1);
		t2 = TeamFortress_TeamGetNoPlayers(2);
		t3 = TeamFortress_TeamGetNoPlayers(3);
		t4 = TeamFortress_TeamGetNoPlayers(4);

		if ((t1 + t2 + t3 + t4) < 1)  // is there any players at all?
		{
			self.nextthink = time + 30;
			return;
		}
		
		t_ave = (t1 + t2 + t3 + t4) / number_of_teams;

		// calulate teams equalisation ratio
		if (t1 > 0)
		{
			calc = (t_ave / t1) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team1advantage = calc;
		}
		
		if (t2 > 0 && number_of_teams >= 2)
		{
			calc = (t_ave / t2) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team2advantage = calc;
		}

		if (t3 > 0 && number_of_teams >= 3)
		{
			calc = (t_ave / t3) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team3advantage = calc;
		}

		if (t4 > 0 && number_of_teams >= 4)
		{
			calc = (t_ave / t4) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team4advantage = calc;
		}
	}
	
	if (teamplay & #TEAMPLAY_LESSSCOREHELP)
	{
		t1 = team1score + #TEAM_HELP_RATE;
		
		if (number_of_teams >= 2)
				t2 = team2score + #TEAM_HELP_RATE;
		else
				t2 = 0;

		if (number_of_teams >= 3)
			t3 = team3score + #TEAM_HELP_RATE;
		else
			t3 = 0;

		if (number_of_teams >= 4)
			t4 = team4score + #TEAM_HELP_RATE;
		else 
			t4 = 0;


		// calulate teams equalisation ratio
		t_ave = (t2 + t3 + t4) / (number_of_teams - 1);

		calc = (t_ave / t1) - 1;

		if (calc != 0)
			calc = (calc / 3) + 1;
		else
			calc = calc + 1;

		team1advantage = calc * team1advantage;
	
		if (number_of_teams >= 2)
		{
			t_ave = (t1 + t3 + t4) / (number_of_teams - 1);

			calc = (t_ave / t2) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team2advantage = calc * team2advantage;
		}

		if (number_of_teams >= 3)
		{
			t_ave = (t2 + t1 + t4) / (number_of_teams - 1);
	
			calc = (t_ave / t3) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team3advantage = calc * team3advantage;
		}

		if (number_of_teams >= 4)
		{
			t_ave = (t2 + t3 + t1) / (number_of_teams - 1);

			calc = (t_ave / t4) - 1;

			if (calc != 0)
				calc = (calc / 3) + 1;
			else
				calc = calc + 1;

			team4advantage = calc * team4advantage;
		}
	}		

	self.nextthink = time + 10;
};


void() SetupTeamEqualiser =
{
	team1advantage = 1;
	team2advantage = 1;
	team3advantage = 1;
	team4advantage = 1;
	
	if (!(teamplay & (#TEAMPLAY_LESSPLAYERSHELP | #TEAMPLAY_LESSSCOREHELP)))
		return;

	// setup teamplay timer
	local entity TE;

	TE = spawn();
	TE.classname = "Team Equaliser";
	TE.think = CalculateTeamEqualiser;
	TE.nextthink = time + 30;	
};


float (entity targ, entity attacker, float damage) TeamEqualiseDamage =
{
	if (targ.classname != "player" || attacker.classname != "player")
		return damage;
	
	if (Teammate(targ, attacker))
		return damage;

	local float adv, newdam;

	// increase damage done by attacker's team advantage
	if (attacker.team_no == 1)
		adv = team1advantage;
	else if (attacker.team_no == 2)
		adv = team2advantage;
	else if (attacker.team_no == 3)
		adv = team3advantage;
	else if (attacker.team_no == 4)
		adv = team4advantage;

	if (adv == 0)
	{
		RPrint("There is a team with an advantage of 0\n");
		adv = 0.1;
	}

	newdam = damage * adv;

	// reduce damage done by target's team advantage
	if (targ.team_no == 1)
		adv = team1advantage;
	else if (targ.team_no == 2)
		adv = team2advantage;
	else if (targ.team_no == 3)
		adv = team3advantage;
	else if (targ.team_no == 4)
		adv = team4advantage;
	
	if (adv == 0)
	{
		RPrint("There is a team with an advantage of 0\n");
		adv = 0.1;
	}

	newdam = newdam * (1 / adv);

	return newdam;
};

//=========================================================================
// StatusQuery
void() TeamFortress_StatusQuery =
{
	local float ft;
	local string st;

	sprint (self, #PRINT_HIGH, "players per team: ");

	ft = TeamFortress_TeamGetNoPlayers(1);	
	st = ftos(ft);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, "  ");
	ft = TeamFortress_TeamGetNoPlayers(2);	
	st = ftos(ft);
	sprint (self, #PRINT_HIGH, st);

	sprint (self, #PRINT_HIGH, "  ");
	ft = TeamFortress_TeamGetNoPlayers(3);	
	st = ftos(ft);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, "  ");
	ft = TeamFortress_TeamGetNoPlayers(4);	
	st = ftos(ft);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, "\n");

	sprint (self, #PRINT_HIGH, "    equalisation: ");

	st = ftos(team1advantage);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, "  ");
	st = ftos(team2advantage);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, "  ");
	st = ftos(team3advantage);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, "  ");
	st = ftos(team4advantage);
	sprint (self, #PRINT_HIGH, st);

	sprint (self, #PRINT_HIGH, "\n");

	st = ftos(teamplay);
	sprint (self, #PRINT_HIGH, "Teamplay is ");
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, "\n");

};

//=========================================================================
// Return the illegal classes for this team
float(float tno) TeamFortress_TeamGetIllegalClasses =
{
	if (tno == 1)
		return illegalclasses1;
	if (tno == 2)
		return illegalclasses2;
	if (tno == 3)
		return illegalclasses3;
	if (tno == 4)
		return illegalclasses4;

	return 0;
};

//=========================================================================
// Return TRUE if this team is restricted to Civilian class
float(float tno) TeamFortress_TeamIsCivilian =
{
	//local entity te;

	if (tno == 1)
	{
		if (civilianteams & #TEAM1_CIVILIANS)
			return #TRUE;
	}
	else if (tno == 2)
	{
		if (civilianteams & #TEAM2_CIVILIANS)
			return #TRUE;
	}
	else if (tno == 3)
	{
		if (civilianteams & #TEAM3_CIVILIANS)
			return #TRUE;
	}
	else // if (tno == 4)
	{
		if (civilianteams & #TEAM4_CIVILIANS)
			return #TRUE;
	}

	return #FALSE;
};

//=========================================================================
// Sprints to all the members on one team except one 
float(float tno, entity ignore, string st) teamsprint =
{
	// Don't do teamprints in DM
	if (tno == 0)
		return;
	
	local entity te;

	te = find(world, classname, "player");
	while (te)
	{
		temp_e.team_no = tno; // for Neo mode (modified Teammate())
		if (Teammate(te, temp_e) && te != ignore)
		{
			sprint(te, #PRINT_HIGH, st);
		}

		te = find(te, classname, "player");
	}
};



