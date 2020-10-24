/*=======================================================//
// Vote.QC - CustomTF 3.2.OfN			  - 04/11/2002 - //
// by Sergio FumaÒa Grunwaldt - OfteN [cp]				 //
=========================================================//
 Voting system functions and stuff...
 (Requires PROZAC qwsv, uses special built-ins)
=========================================================*/
// modified vote system provided by randomer. -Pulseczar (1/15/07)
//=======================================================

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

Global vars used:
-----------------

current_voteent   - Points to current vote entity, if any, if not it points to world

For player entity:
------------------

.g_a			  - Contains the type of punishment selected on menu
.goal_no		  - Controls delay between same client votes
.group_no		  - Flag determines if we are choosing next map, or switch to modes
					PZ - 0 = nextmap, 1 = map, 2 = nextmap Neo, 3 = map Neo,
						 4 = nextmap AGR, 5 = map AGR
.goal_state 	  - Determines what page of maps to be shown for voting
.owned_by		  - Contains #VOTED_XXXX, yes, no or none

For vote entity:
----------------

.has_sentry 		 - Type of vote
.g_a				 - Type of punishment to vote
.admin_kick 		 - Player to be punished
.all_active 		 - Number of affirmative votes
.has_holo			 - Number of negative votes
.group_no			 - Type of votemap, nextmap or switchmap
					PZ - 0 = nextmap, 1 = map, 2 = nextmap Neo, 3 = map Neo,
					4 = nextmap AGR, 5 = map AGR
.has_tesla			 - Number of map beeing voted
.dont_do_triggerwork - If TRUE, means the player to be banned has left
	(when banning a user that left)
.t_s_h				 - Permanent string containing IP to be banned
.t_s_m				 - Permanent string with the name of user to be banned
	(when map voting)
.netname			 - Permanent string that is the name of map

===============================================================================================*/

void() PunishClientCycle;
void() StartPunishmentVote;
void() CleanClientVotes;
void() ResetClientsMenu;
float() ValidVoteEnt;
float(float final) CheckVoting;
void(float nummap, string themap) StartVoteMap;
string(float themap) GetMapString;
void() bprintVotesLeft;
//float() GetRemainingVotes;
void() CleanUpSleepVote;
void() VoteSleep_think;

// External
void(string text) CmdMsg;

//====================================================================================================
// both player and spectators share the same menu handlers for voting, so we need this

void() AllResetMenu =
{
	if (self.classname == "spec")
		SpecResetMenu();
	else if (self.classname == "player")
		ResetMenu();  
};

void() Player_Punish = 
{
	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;
	
	if (current_voteent != world)
	{
		sprint(self,#PRINT_HIGH,"Already running a vote!\n");
		return;
	}
	
	if (self.goal_no > time)
	{
		sprint(self,#PRINT_HIGH,"You just have ran a vote!\n");
		return;
	}

	if (self.classname == "player")
		self.current_menu = #MENU_PUNISH;
	else if (self.classname == "spec")
		self.current_menu = #SPEC_MENU_PUNISH;
	else
		return;
		//RPrint("BUG: Non-spec/player on Player_Punish()\n");

	CuTFMenuSound(#MENUSOUND_BUY);
	Menu_Punish();
	BackFlash(self,1);
};

void() Menu_Punish =
{
	local string st, st2, st3;
		
	// if we didn't disconnect and we are a valid class, player or spectator..
	if (HasValidAdminTarget2(self))
	{
		st2 = self.admin_kick.netname;	  
		
		if (self.admin_kick.classname == "spec")
			st="’ÛÂÚ: ®spectator© \n\n";
		else
			st="’ÛÂÚ:             \n\n";
	}
	else
		st2 = "’ÛÂÚ:             \n\nNo user selected! ";

	if (self.g_a == #PUNISH_BAN)
		st3 = ".. Ban°          ";
	else if (self.g_a == #PUNISH_KICK)
		st3 = ".. Kick°         ";
	else if (self.g_a == #PUNISH_MUTE)
		st3 = ".. Mute°         ";
	else if (self.g_a == #PUNISH_CUFF)
		st3 = ".. Cuff°         ";
	else { //WK Fix bug where a vote could do down without .g_a being set
		st3 = ".. Curse°        ";
		self.g_a = #PUNISH_CURSE; //Initialize it here, i.e.
	}		 

	CenterPrint5(self,st,st2,"\n\n.. Next UserÆÆÆ  \n\n.. √ËÔÔÛÂ ¡„ÙÈÔÓ:\n\n",st3,"\n\nÆÆ ≈¯ÈÙ          \n");
														   
};

void(float input) Menu_Punish_Input =
{
	if (input == 1)
	{
		PunishClientCycle();
		CuTFMenuSound(#MENUSOUND_BROWSE);
		Menu_Punish();
		self.impulse = 0;
		return;
	}
	else if (input == 2)
	{
		if (self.g_a == #PUNISH_CURSE)
			self.g_a = #PUNISH_KICK;
		else if (self.g_a == #PUNISH_KICK)
			self.g_a = #PUNISH_MUTE;
		else if (self.g_a == #PUNISH_MUTE)
			self.g_a = #PUNISH_BAN;
		else if (self.g_a == #PUNISH_BAN)
			self.g_a = #PUNISH_CUFF;
		else self.g_a = #PUNISH_CURSE;

		CuTFMenuSound(#MENUSOUND_BUY);
		Menu_Punish();
		self.impulse = 0;
		return;
	}
	else if (input == 3)
	{
		self.impulse = 0;
		
		if (current_voteent != world)
		{
			sprint(self,#PRINT_HIGH,"Already running a vote!\n");
			AllResetMenu();
			return;
		}
		else if (self.admin_kick == world)
			sprint(self,#PRINT_HIGH,"No user selected!\n");
		else if (!self.admin_kick.is_connected)
		{
			sprint(self,#PRINT_HIGH,"User has left the server!\n");
			PunishClientCycle();
		}
		else if (self.admin_kick.classname=="spec" && self.g_a == #PUNISH_CURSE)
			sprint(self,#PRINT_HIGH,"Can't curse spectators!\n");
		else if (self.admin_kick.classname=="spec" && self.g_a == #PUNISH_CUFF)
			sprint(self,#PRINT_HIGH,"Can't cuff spectators!\n");
		else if (self.admin_kick.classname != "spec" && self.admin_kick.classname != "player")
			sprint(self,#PRINT_HIGH,"Invalid user selected!\n");
		else
		{
			StartPunishmentVote();
			AllResetMenu();
			return;
		}

		CuTFMenuSound(#MENUSOUND_WRONG);
	}
	else if (input == 10)
	{
		AllResetMenu();
		CuTFMenuSound(#MENUSOUND_SELL);
		BackFlash(self,1);
		self.impulse = 0;
		return;
	}
	
	self.impulse = 0;
};

void() Player_VoteMap = 
{
	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;
	
	if (current_voteent != world)
	{
		sprint(self,#PRINT_HIGH,"Already running a vote!\n");
		return;
	}

	if (time < #VOTE_MIN_TIME)
	{
		sprint(self,#PRINT_HIGH,"Too early for a map vote!\n");
		return;
	}

	if (self.goal_no > time)
	{
		sprint(self,#PRINT_HIGH,"You just have ran a vote!\n");
		return;
	}

	if (ServerUpdating())
	{
		sprint(self,#PRINT_HIGH,"Server update is taking place, no map changes are allowed!\n");
		return;
	}

	if (self.classname == "player")
		self.current_menu = #MENU_VOTEMAP;
	else if (self.classname == "spec")
		self.current_menu = #SPEC_MENU_VOTEMAP;
	else 
		return;
	//RPrint("BUG: Non-spec/player on Player_VoteMap()\n");

	CuTFMenuSound(#MENUSOUND_BUY);
	Menu_VoteMap();
	BackFlash(self,1);
};	

void() Menu_VoteMap =
{
	local string paddedstr,st1,st2,st3,st4,st5,st6,st7,keyst,color;
	
	keyst = GetMapString(self.goal_state*6+1);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	if (self.goal_state == 0)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 1Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 1)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 2Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 2)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 3Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 3)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 4Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 4)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 5Ø6©\n\n.. ",paddedstr);
	else
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 6Ø6©\n\n.. ",paddedstr);
		
	keyst = GetMapString(self.goal_state*6+2);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st2 = strcat("\n.. ",paddedstr);
		
	keyst = GetMapString(self.goal_state*6+3);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st3 = strcat("\n.. ",paddedstr);
	
	keyst = GetMapString(self.goal_state*6+4);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st4 = strcat("\n.. ",paddedstr);

	keyst = GetMapString(self.goal_state*6+5);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st5 = strcat("\n.. ",paddedstr);

	keyst = GetMapString(self.goal_state*6+6);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st6 = strcat("\n.. ",paddedstr);

	// PZ - begin AGR modification
	if (self.group_no == 0)
		st7 ="\n\n.. ÕÔ‰Â: as next map \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	else if (self.group_no == 1)
		st7 ="\n\n.. ÕÔ‰Â: play now°   \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	// Neo mode
	else if (self.group_no == 2)
		st7 ="\n\n.. ÕÔ‰Â: as next map \n      ŒÂÔ ÕÔ‰Â\n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	else if (self.group_no == 3)
		st7 ="\n\n.. ÕÔ‰Â: play now°   \n      ŒÂÔ ÕÔ‰Â\n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	// end Neo code
	else if (self.group_no == 4)
		st7 ="\n\n.. ÕÔ‰Â: as next map \n              ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰\n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	else				   // 5
		st7 ="\n\n.. ÕÔ‰Â: play now°   \n              ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰\n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	// PZ - end AGR modification

	CenterPrint7(self,st1,st2,st3,st4,st5,st6,st7);

	self.#cprint_fx = self.#cprint_fx + 1;
};

void(float input) Menu_VoteMap_Input =
{
	if (input >= 1 && input <= 6)
	{
		if (current_voteent != world)
		{
			sprint(self,#PRINT_HIGH,"Already running a vote!\n");
			AllResetMenu();
			self.impulse = 0;
			return;
		}

		local float nummap;
		
		nummap = input + (self.goal_state*6);

		StartVoteMap(nummap,"");
		AllResetMenu();
	}	
	else if (input == 7)
	{
		// PZ - begin AGR code
		if		(self.group_no == 0)
					self.group_no = 1;
		else if (self.group_no == 1)
					self.group_no = 2;
		// Neo mode
		else if (self.group_no == 2)
					self.group_no = 3;
		else if (self.group_no == 3)
					self.group_no = 4;
		// Neo end
		else if (self.group_no == 4)
					self.group_no = 5;
		else				   // 5
					self.group_no = 0;
		// PZ - end AGR code

		CuTFMenuSound(#MENUSOUND_BUY);

		NoCprintFX();
		Menu_VoteMap();
	}	 
	else if (input == 8)
	{
		self.goal_state = self.goal_state - 1;
		if (self.goal_state < 0)
			self.goal_state = 5;
				
		CuTFMenuSound(#MENUSOUND_BROWSE);

		NoCprintFX();
		Menu_VoteMap();
	}	 
	else if (input == 9)
	{
		self.goal_state = self.goal_state + 1;
		if (self.goal_state > 5)
			self.goal_state = 0;
							
		CuTFMenuSound(#MENUSOUND_BROWSE);
		
		NoCprintFX();
		Menu_VoteMap();
	}	 
	else if (input == 10)
	{
		AllResetMenu();
		CuTFMenuSound(#MENUSOUND_SELL);
		BackFlash(self,1);
	}	 

	self.impulse = 0;
};

//===============================================================
// bprints the current voting issue

void() bprintVoteIssue =
{
	if (current_voteent.has_sentry == #VOTE_PUNISH)
	{
		if (current_voteent.dont_do_triggerwork) // Special ban (client has left)
		{
			bprint(#PRINT_HIGH," ®ban ");
			bprint(#PRINT_HIGH,current_voteent.t_s_m);
			bprint(#PRINT_HIGH,"©");
		}
		else
		{
			if (current_voteent.g_a == #PUNISH_CURSE)
				bprint(#PRINT_HIGH," ®curse ");
			else if (current_voteent.g_a == #PUNISH_KICK)
				bprint(#PRINT_HIGH," ®kick ");
			else if (current_voteent.g_a == #PUNISH_BAN)
				bprint(#PRINT_HIGH," ®ban ");
			else if (current_voteent.g_a == #PUNISH_MUTE)
				bprint(#PRINT_HIGH," ®mute ");
			else if (current_voteent.g_a == #PUNISH_CUFF)
				bprint(#PRINT_HIGH," ®cuff ");

			bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
			bprint(#PRINT_HIGH,"©");
		}
	}
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP) // as next map
	{
		bprint(#PRINT_HIGH," ®"); // FIXME: CPQCCX compiler says 'Not a name' if only "(" is used ???
		bprint(#PRINT_HIGH, current_voteent.netname);
		bprint(#PRINT_HIGH," as next map©");
	} 
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP)
	{
		bprint(#PRINT_HIGH," ®switch to ");
		bprint(#PRINT_HIGH,current_voteent.netname);
		bprint(#PRINT_HIGH,"©");
	}	 
	// Neo mode
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP_NEO) // as next map
	{
		bprint(#PRINT_HIGH," ®");
		bprint(#PRINT_HIGH, current_voteent.netname);
		bprint(#PRINT_HIGH," as next map, in ŒÂÔ ÕÔ‰Â©");
	} 
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP_NEO)
	{
		bprint(#PRINT_HIGH," ®switch to ");
		bprint(#PRINT_HIGH, current_voteent.netname);
		bprint(#PRINT_HIGH,", in ŒÂÔ ÕÔ‰Â©");
	}
	// end Neo
	// PZ - begin AGR code
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP_AGR) // as next map
	{
		bprint(#PRINT_HIGH," ®");
		bprint(#PRINT_HIGH, current_voteent.netname);
		bprint(#PRINT_HIGH," as next map, in ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰ mode©");
	} 
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP_AGR)
	{
		bprint(#PRINT_HIGH," ®switch to ");
		bprint(#PRINT_HIGH,current_voteent.netname);
		bprint(#PRINT_HIGH,", in ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰ mode©");
	}
	// PZ - end AGR code
};

//==============================================================
// user has used the VoteYes impulse command

float() TeamFortress_GetNoPlayers; //WK Used to count all the people in the world.

void() Player_VoteYes =
{
	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;

	if (current_voteent == world)
	{
		sprint(self,#PRINT_HIGH,"Not voting currently!\n");
		return;
	}

	#ifndef VOTING_TEST
	if (current_voteent.admin_kick == self) //WK 4-27-7 We allow people to vote only *no* on punishing themselves in small games
	{
		sprint(self,#PRINT_HIGH,"You are not allowed to vote!\n");
		return;
	}

	else if (self.owned_by == #VOTED_NO || self.owned_by == #VOTED_YES)
	{
	// FIXME: Allow the person to change their vote. -randomer 2006-02-24
	sprint(self,#PRINT_HIGH,"You already voted!\n");
	}
	else
	{
	#endif		  
		BackFlash(self,1);
		
		bprint(#PRINT_HIGH,"Votingç ");
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH," agrees");

		self.owned_by = #VOTED_YES;

		bprintVoteIssue();
				
		BroadcastSound("misc/basekey");
		
		current_voteent.all_active = current_voteent.all_active + 1;

		if (current_voteent.nextthink < time + #VOTE_TIME_REFRESH)
			current_voteent.nextthink = time + #VOTE_TIME_REFRESH;
				
		bprintVotesLeft();
		CheckVoting(#FALSE);
	#ifndef VOTING_TEST
	}
	#endif
};

//==============================================================
// user has used the VoteNo impulse command

void() Player_VoteNo =
{
	local float playercount;

	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;
	
	if (current_voteent == world)
	{
		sprint(self,#PRINT_HIGH,"Not voting currently!\n");
		return;
	}
	
	#ifndef VOTING_TEST

	//WK Allow voting "no" on self in <= 4 player games
	playercount = TeamFortress_GetNoPlayers();
	if (current_voteent.admin_kick == self && playercount > 4) //WK 4-27-7 Stop silliness in small votes
	{
		sprint(self,#PRINT_HIGH,"You are not allowed to vote on yourself if there are more than 4 players!\n");
		return;
	}
	else if (self.owned_by == #VOTED_NO || self.owned_by == #VOTED_YES)
	{
		sprint(self,#PRINT_HIGH,"You already voted!\n");
	}
	else
	{
	#endif
		BackFlash(self,1);

		bprint(#PRINT_HIGH,"Votingç ");
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH," disagrees");

		self.owned_by = #VOTED_NO;

		bprintVoteIssue();
		
		BroadcastSound("doors/basetry.wav"); // PZ - was misc/basekey just like voteyes
		// changed to differentiate vote sounds from affirmative to negative
		
		current_voteent.has_holo = current_voteent.has_holo +1;
		
		if (current_voteent.nextthink < time + #VOTE_TIME_REFRESH)
			current_voteent.nextthink = time + #VOTE_TIME_REFRESH;
				
		bprintVotesLeft();
		CheckVoting(#FALSE);

	#ifndef VOTING_TEST
	}
	#endif
};

//========================================================================
// cycles through all clients as target for punishment

void() PunishClientCycle =
{
	local entity te;
	local float num;
	num = #FALSE;

	te = world; // none 
	
	te = find(self.admin_kick, classname, "player");
	while (te != world && num == #FALSE)
	{
		num = #TRUE;

		if (!te.is_connected)
			num = #FALSE;
		
		if (self.admin_kick==te)
			num = #FALSE;

		#ifndef VOTING_TEST
		if (te == self)
			num = #FALSE;
		#endif
		
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

			#ifndef VOTING_TEST
			if (te == self)
				num = #FALSE;
			#endif

			if (num == #FALSE) te = find(te, classname, "spec");
		}
	}

	if (te == world) 
		self.admin_kick=world; // No clients found!
	else
		self.admin_kick = te;
};

//========================================================================
// deletes current vote entity, if it exists, and performs clean up

void() ResetVoteEnt =
{
	if (current_voteent.classname == "voteent")
	{
		//WK 5-15-08 Added NEO to this
		if (current_voteent.has_sentry == #VOTE_NEXTMAP || 
			current_voteent.has_sentry == #VOTE_SWITCHMAP ||
			current_voteent.has_sentry == #VOTE_NEXTMAP_AGR ||
			current_voteent.has_sentry == #VOTE_SWITCHMAP_AGR ||
			current_voteent.has_sentry == #VOTE_NEXTMAP_NEO ||
			current_voteent.has_sentry == #VOTE_SWITCHMAP_NEO)
				delstr(current_voteent.netname);

		if (current_voteent.dont_do_triggerwork)
		{
			delstr(current_voteent.t_s_h);
			delstr(current_voteent.t_s_m);
		}
		
		dremove(current_voteent);
		current_voteent = world;
	}
	else current_voteent = world;
};

//==========================================================================
// gets number of clients currently on server, including spectators

float() GetNoClients =
{
	return num_players + num_specs;

	/*local entity te;
	local float clients;
	clients = 0;

	te = find(world, classname, "player");
	while (te != world)
	{
		if (!te.has_disconnected)
			clients = clients + 1;
		
		te = find(te, classname, "player");
	}	 

	te = find(world, classname, "spec");
	while (te != world)
	{
		if (!te.has_disconnected)
			clients = clients + 1;
		
		te = find(te, classname, "spec");
	}	 

	return clients;*/
};

//WK 4/27/7 Add 15 second warning to voting system, reminding people to vote.
void() WarnVote_Think =
{
	local entity te;
	te = find(world, classname, "player");
	while (te != world)
	{
		if (te.is_connected && te.owned_by == #VOTED_READY)
		{
			te.StatusRefreshTime = time + 5;
			centerprint(te,"WARNING: Voting ends in 15 seconds.\n");
			stuffcmd(te,"play enforcer/sight3.wav\n");
		}
		te = find(te, classname, "player");
	} 
	bprintVoteIssue(); //BPrint the current vote up top.
	bprintVotesLeft(); //And the current number of votes left

	//bprint(#PRINT_MEDIUM,"Voting Ends in 15 Seconds.\n");
	//BroadcastSound("misc/medkey");
	dremove(self);
};

void() PunishVote_Think;

//=================================================================
// Start punishment voting, self = player issuer of vote

void() StartPunishmentVote =
{
	if (no_punish)
	{
		CmdMsg("Punishment votes are disabled, sorry!\n");
		return;
	}

	if (self.classname != "player" && self.classname != "spec")
	{
		sprint(self,#PRINT_HIGH,"You can't vote still, join the game first!\n");
		return;
	}
	
	if (mutedtime(self))
	{
		sprint(self,#PRINT_HIGH,"You can't start a vote while muted!\n");
		return;
	}
	
	BackFlash(self,1);

	CleanClientVotes();
  
	//WK Broadcast a warning to the server that the vote is going to end in 15 seconds
	local entity warnent;
	warnent = spawn();
	warnent.think = WarnVote_Think;
	warnent.nextthink = time + #WARN_TIME;
	warnent.owner = world;
  
	local entity voteent;

	voteent = spawn();
	voteent.g_a = self.g_a;
	voteent.think = PunishVote_Think;
	voteent.nextthink = time + #VOTE_TIME;
	voteent.classname = "voteent";
	voteent.owner = world; // ADDED

	voteent.all_active = 1;
	voteent.has_holo = 0;

	voteent.demon_one = self;

	voteent.admin_kick = self.admin_kick;

	voteent.has_sentry = #VOTE_PUNISH;

	self.goal_no = time + #VOTE_DELAY;

	self.owned_by = #VOTED_YES; // we already voted yes

	BroadcastSound("misc/medkey");

	bprint(#PRINT_HIGH,"Votingç ");

	bprint(#PRINT_HIGH,self.netname);
	last_vote_starter = self.netname; // for AGR -PZ
	bprint(#PRINT_HIGH," proposes to ");

	if (self.g_a == #PUNISH_CURSE)
		bprint(#PRINT_HIGH,"curse ");
	else if (self.g_a == #PUNISH_KICK)
		bprint(#PRINT_HIGH,"kick ");
	else if (self.g_a == #PUNISH_MUTE)
		bprint(#PRINT_HIGH,"mute ");
	else if (self.g_a == #PUNISH_BAN)
		bprint(#PRINT_HIGH,"ban ");
	else if (self.g_a == #PUNISH_CUFF)
		bprint(#PRINT_HIGH,"cuff ");

	bprint(#PRINT_HIGH,self.admin_kick.netname);

	bprint(#PRINT_HIGH,", type ¢VoteYes¢ or ¢VoteNo¢ to vote\n");

	current_voteent = voteent;

	current_voteent.dont_do_triggerwork = #FALSE;
		
	ResetClientsMenu(); // reset menus on players/specs who are on MENU_PUNISH or MENU_VOTEMAP

	CheckVoting(#FALSE); // If we are the only player on server, checks
};

void() PunishVote_Think =
{
	CheckVoting(#TRUE);
	
#ifdef NOTDEFINED
	bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
	bprintVoteIssue();
	bprint(#PRINT_HIGH,"\n");

	BroadcastSound("misc/runekey");

	ResetVoteEnt();
#endif
};

void() VoteMap_Think;

//=================================================================
// Start map voting, self = player issuer of vote

void(float nummap, string themap) StartVoteMap =
{
	local string temp;

	if (no_votemap)
	{
		CmdMsg("Map voting within the mod is disabled, sorry!\n");
		return;
	}

	if (self.classname != "player" && self.classname != "spec")
	{
		sprint(self,#PRINT_HIGH,"You can't vote still, join the game first!\n");
		return;
	}

	if (time < #VOTE_MIN_TIME)
	{
		sprint(self,#PRINT_HIGH,"Too early for a map change!\n");
		return;
	}
	
	if (mutedtime(self))
	{
		sprint(self,#PRINT_HIGH,"You can't start a vote while muted!\n");
		return;
	}

	if (ServerUpdating())
	{
		sprint(self,#PRINT_HIGH,"Server update is taking place, no map changes are allowed!\n");
		return;
	}
/* WK 5-15-08 Removed agr vote max
	// PZ - AGR begin
	if (self.group_no == 2 || self.group_no == 3)
	{
		local float x;
		x = GetNoPlayers(#TRUE, #TRUE);
		if (agr_vote_max != 0 && x > agr_vote_max)
		{
			sprint(self, #PRINT_HIGH, "Votingç Max number of players allowed for an ¡«“ vote is ");
			temp = ftos(agr_vote_max);
			temp = colstr(temp, #COLSTR_NUMBER);
			sprint(self, #PRINT_HIGH, temp);
			sprint(self, #PRINT_HIGH, " players.\n");
			return;
		}
	}
	// AGR end
*/

	BackFlash(self,1);

	//WK Broadcast a warning to the server that the vote is going to end in 15 seconds
	local entity warnent;
	warnent = spawn();
	warnent.think = WarnVote_Think;
	warnent.nextthink = time + #WARN_TIME;
	warnent.owner = world;
  
	local entity voteent;

	voteent = spawn();
	voteent.g_a = self.g_a;
	voteent.think = VoteMap_Think;
	voteent.nextthink = time + #VOTE_TIME;
	voteent.classname = "voteent";
	voteent.owner = world; // ADDED

	if (!nummap)
	{
		voteent.netname = themap;

		#ifdef UNABLE_TOVOTE_FORSAME_MAP
		// Don't let votes to switch to current map
		// PZ ..unless they are changing to/from AGR (or Neo mode)
		if (voteent.netname == mapname && 
		   ((self.group_no == 1 && !agr && !neo) || (self.group_no == 5 && agr) ||
			(self.group_no == 3 && neo)))
		{
			sprint(self,#PRINT_HIGH,"You can't start voting for a map that is currently being played!\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
			dremove(voteent);
			dremove(warnent);
			voteent = world;
			return;
		}
		#endif

		voteent.netname = makestr(voteent.netname);
		voteent.has_tesla = 0;
	}
	else
	{
		voteent.netname = GetMapString(nummap);

		// Abort if empty map name on localinfo
		if (voteent.netname == "")
		{
			sprint(self,#PRINT_HIGH,"You can't choose an empty map slot!\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
			dremove(voteent);
			dremove(warnent);
			voteent = world;
			return;
		}

		#ifdef UNABLE_TOVOTE_FORSAME_MAP
		// Don't let votes to switch to current map
		// PZ ..unless they are changing to/from AGR (or Neo mode)
		if (voteent.netname == mapname && 
		   ((self.group_no == 1 && !agr && !neo) || (self.group_no == 5 && agr) ||
			(self.group_no == 3 && neo)))
		{
			sprint(self,#PRINT_HIGH,"You can't start voting for a map that is currently being played!\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
			dremove(voteent);
			dremove(warnent);
			voteent = world;
			return;
		}
		#endif

		voteent.netname = makestr(voteent.netname);
		voteent.has_tesla = nummap;
	}

	CleanClientVotes();

	voteent.all_active = 1;
	voteent.has_holo = 0;

	if (self.group_no == 0)
		voteent.has_sentry = #VOTE_NEXTMAP;
	else if (self.group_no == 1)
		voteent.has_sentry = #VOTE_SWITCHMAP;  
	else if (self.group_no == 2) // Neo mode
		voteent.has_sentry = #VOTE_NEXTMAP_NEO;
	else if (self.group_no == 3) // Neo mode
		voteent.has_sentry = #VOTE_SWITCHMAP_NEO;
	else if (self.group_no == 4) // PZ - AGR mode
		voteent.has_sentry = #VOTE_NEXTMAP_AGR;
	else				   // 5  // PZ - AGR mode
		voteent.has_sentry = #VOTE_SWITCHMAP_AGR;

	current_voteent = voteent;

	self.goal_no = time + #VOTE_DELAY;

	self.owned_by = #VOTED_YES; // we already voted yes
	
	voteent.group_no = self.group_no;

	current_voteent.dont_do_triggerwork = #FALSE;

	//WK 5-15-08 Replace with voting sounds BroadcastSound("misc/medkey");

	themap = colstr(current_voteent.netname,#COLSTR_RED);

	bprint(#PRINT_HIGH,"Votingç ",self.netname);
	last_vote_starter = self.netname; // for AGR -PZ
	
	if (self.group_no == 0)
		bprint(#PRINT_HIGH," suggests ",themap," as next map");
	else if (self.group_no == 1)
		bprint(#PRINT_HIGH," wants to play ",themap," right now");
	else if (self.group_no == 2) // Neo mode
		bprint(#PRINT_HIGH," suggests ",themap," as next map, in ŒÂÔ ÕÔ‰Â");
	else if (self.group_no == 3) // Neo mode
		bprint(#PRINT_HIGH," wants to play ",themap," right now, in ŒÂÔ ÕÔ‰Â");   
	else if (self.group_no == 4) // PZ - AGR mode
		bprint(#PRINT_HIGH," suggests ",themap," as next map, in ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰ mode");
	else				   // 5  // PZ - AGR mode
		bprint(#PRINT_HIGH," wants to play ",themap," right now, in ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰ mode");		
	
	local float rnum;
	rnum = random();

	//WK 5-15-08 Added vote voice broadcasts
	if (self.group_no == 0 || self.group_no == 1) { //Normal Mode
		if (agr || neo) { //We're changing back to normal mode
			if (rnum < 0.4) BroadcastSound("shaka/voting_new3");
			else BroadcastSound("shaka/voting_new4");
		}
		else {
			if (rnum < 0.45) BroadcastSound("shaka/voting_new2");
			else if (rnum < 0.75) BroadcastSound("shaka/voting_new3");
			else BroadcastSound("shaka/voting_new");
		}
	}
	else if (self.group_no == 2 || self.group_no == 3) {
		BroadcastSound("shaka/voting_neo");
	}
	else {
		BroadcastSound("shaka/voting_agr");
	}

	bprint(#PRINT_HIGH,", type ¢VoteYes¢ or ¢VoteNo¢ to vote\n");
		
	ResetClientsMenu(); // reset menus on players/specs which r on MENU_PUNISH or MENU_VOTEMAP

	CheckVoting(#FALSE); // If we are the only player on server must check
};

void() VoteMap_Think =
{
	CheckVoting(#TRUE);
	
#ifdef NOTDEFINED
	bprint(#PRINT_HIGH,"Votingç Map voting failed");

	bprintVoteIssue();

	bprint(#PRINT_HIGH,"\n");

	BroadcastSound("misc/runekey");

	ResetVoteEnt();
#endif
};

//==================================================================
// resets all clients to ready-to-vote state

void() CleanClientVotes =
{
	local entity te;

	te = find(world, classname, "player");
	while (te != world)
	{
		if (te.is_connected)
			te.owned_by = #VOTED_READY;
		
		te = find(te, classname, "player");
	}	 

	te = find(world, classname, "spec");
	while (te != world)
	{
		if (te.is_connected)
			te.owned_by = #VOTED_READY;
		
		te = find(te, classname, "spec");
	}	 
};

//=============================================================================
// clear menus of clients that have vote menus on - WATCHOUT - Using self

void() ResetClientsMenu =
{
	local entity te;

	te = find(world, classname, "player");
	while (te != world)
	{
		if (te.is_connected)
		if (te != self)
		if (te.current_menu == #MENU_PUNISH || te.current_menu == #MENU_VOTEMAP)
		{
			sprint(te,#PRINT_HIGH,"Already running a vote!\n"); 
			CenterPrint(te,"\n");
			te.current_menu = #MENU_DEFAULT;
		}

		te = find(te, classname, "player");
	}	 

	te = find(world, classname, "spec");
	while (te != world)
	{
		if (te.is_connected)
		if (te != self)
		if (te.current_menu == #SPEC_MENU_PUNISH || te.current_menu == #SPEC_MENU_VOTEMAP)
		{
			sprint(te,#PRINT_HIGH,"Already running a vote!\n"); 
			CenterPrint(te,"\n");
			te.current_menu = #SPEC_MENU_NONE;
		}

		te = find(te, classname, "spec");
	}	 
};

//==========================================================================
// called after each vote (yes or no) to see if its a succesfull vote

float(float final) CheckVoting =
{
	// this shouldn't be needed
	if (current_voteent == world || current_voteent.classname!="voteent")
	{
		bprint(#PRINT_HIGH,"Votingç Error in voting system!\n");
		ResetVoteEnt();
		return #TRUE;
	}	 

	local float num_for, num_against, num_total;
	local entity te;
	
	// Count the number of votes for, against and total clients.
	te = nextent(world);
	while (te != world) {
		if (te.classname == "player" || te.classname == "spec") {
			num_total = num_total + 1;
			if (te.owned_by == #VOTED_YES) {
				num_for = num_for + 1;
			} else if (te.owned_by == #VOTED_NO) {
				num_against = num_against + 1;
			}
		}
		te = nextent(te);
	}
	
	// If this is the final check then only count the people who actually voted.
	if (final)
		num_total = num_for + num_against;

	//WK 5-15-08 Neo bugfix
	// If an update is taking place, dont allow map voting
	if (current_voteent.has_sentry == #VOTE_NEXTMAP || 
		current_voteent.has_sentry == #VOTE_SWITCHMAP ||
		current_voteent.has_sentry == #VOTE_NEXTMAP_AGR || 
		current_voteent.has_sentry == #VOTE_SWITCHMAP_AGR ||
		current_voteent.has_sentry == #VOTE_NEXTMAP_NEO || 
		current_voteent.has_sentry == #VOTE_SWITCHMAP_NEO)
	if (ServerUpdating())
	{
		bprint(#PRINT_HIGH,"Votingç Server update is taking place, no map changes are allowed\n");
		ResetVoteEnt();
		return #TRUE;
	}

	local float numclients;
	local string st;
	
	//numclients = GetNoClients();
	numclients = TeamFortress_GetNoPlayers(); //WK 4/27/7 Just count players, not spects for reaching a quorum.

	//WK 4/27/7 Require a quorum of 40% votes to succeed
	if (final) {
		//WK 5-15-08 AGR and NEO votes require 60% quorum
		if (current_voteent.has_sentry == #VOTE_NEXTMAP_AGR || 
		current_voteent.has_sentry == #VOTE_SWITCHMAP_AGR ||
		current_voteent.has_sentry == #VOTE_NEXTMAP_NEO || 
		current_voteent.has_sentry == #VOTE_SWITCHMAP_NEO) {
			if (num_total < numclients * 0.6) { 
				bprint(#PRINT_HIGH,"Votingç Did not reach a 60% quorum -- the vote fails.\n");
				ResetVoteEnt();
				return #TRUE;
			}
		}
		else {
			if (num_total < numclients * 0.4) {
				bprint(#PRINT_HIGH,"Votingç Did not reach a 40% quorum -- the vote fails.\n");
				ResetVoteEnt();
				return #TRUE;
			}
		}
	}

	if (current_voteent.has_sentry == #VOTE_PUNISH) // Punishment voting
	{
		// Check for a valid client as target
		if (!current_voteent.dont_do_triggerwork) // only if not a special ban (user left)
		if ((current_voteent.admin_kick.classname != "player" && current_voteent.admin_kick.classname != "spec") || !current_voteent.admin_kick.is_connected)
		{
			bprint(#PRINT_HIGH,"Votingç Invalid client as target for vote!\n");
			ResetVoteEnt();
			return #TRUE;
		}
		
		if (current_voteent.g_a == #PUNISH_CURSE) // Curse
		{
			if (num_for > num_total * #VOTESNEEDED_CURSE) // success?
			{
				local float tf;
				
				tf = 0;
				st = infokey(world, "curse");
				
				if (st == string_null) 
					tf = stof(st);
				
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," must be cursed\n");

				BroadcastSound("doors/runeuse");
				
				createBastard(current_voteent.admin_kick,tf);

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
			else if (num_against >= num_total * (1 - #VOTESNEEDED_CURSE))
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
		else if (current_voteent.g_a == #PUNISH_KICK) // Kick
		{
			if (num_for > num_total * #VOTESNEEDED_KICK) // success?
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," must be kicked\n");

				bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH, " is À…√À≈ƒ from the server\n");

				sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been À…√À≈ƒ from the server!\n");

				stuffcmd(current_voteent.admin_kick, "disconnect\n"); //Kick them!

				BroadcastSound("player/teledth1");

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
			else if (num_against >= num_total * (1 - #VOTESNEEDED_KICK))
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
		else if (current_voteent.g_a == #PUNISH_BAN) // Ban!
		{
			if (num_for > num_total * #VOTESNEEDED_BAN) // success?
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");

				if (current_voteent.dont_do_triggerwork) // Special ban (user has left)
				{					 
					bprint(#PRINT_HIGH,current_voteent.t_s_m);
					bprint(#PRINT_HIGH," must be banned\n");

					bprint(#PRINT_HIGH, current_voteent.t_s_m);
					bprint(#PRINT_HIGH, " is ¬¡ŒŒ≈ƒ from the server\n");

					localcmd("addip ");
					localcmd(current_voteent.t_s_h);
					localcmd(" #BAN_VOTED_TIME");
					localcmd("\n");

					BroadcastSound("doors/runeuse");
				}
				else
				{					 
					bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
					bprint(#PRINT_HIGH," must be banned\n");

					bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
					bprint(#PRINT_HIGH, " is ¬¡ŒŒ≈ƒ from the server\n");

					sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been ¬¡ŒŒ≈ƒ from the server!\n");
					
					stuffcmd(current_voteent.admin_kick, "disconnect\n"); //Kick them!
					
					st = infokey(current_voteent.admin_kick,"ip");
					localcmd("addip ");
					localcmd(st);
					localcmd(" #BAN_VOTED_TIME");
					localcmd("\n");   
					
					BroadcastSound("player/teledth1");
				}				

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
			else if (num_against >= num_total * (1 - #VOTESNEEDED_BAN))
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
		else if (current_voteent.g_a == #PUNISH_MUTE) // Mute
		{
			if (num_for > num_total * #VOTESNEEDED_MUTE) // success?  
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," must be muted =)\n");

				bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH, " is muted.\n");

				BroadcastSound("doors/runeuse");

				sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been muted!\n");
				
				local float uid;
				
				uid = getuid(current_voteent.admin_kick);
				st = ftos(uid);

				localcmd("mute 00");
				localcmd(st);
				localcmd(" #MUTE_VOTED_TIME");
				localcmd("\n");

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
			else if (num_against >= num_total * (1 - #VOTESNEEDED_MUTE))
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}		 
		else if (current_voteent.g_a == #PUNISH_CUFF) // Cuff
		{
			if (num_for > num_total * #VOTESNEEDED_CUFF) // success?  
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," is annoying\n");

				bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH, " is cuffed.\n");

				BroadcastSound("doors/runeuse");

				sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been cuffed!\n");
				
				local float uid;
				
				uid = getuid(current_voteent.admin_kick);
				st = ftos(uid);

				localcmd("cuff 00");
				localcmd(st);
				localcmd(" #CUFF_VOTED_TIME");
				localcmd("\n");

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
			else if (num_against >= num_total * (1 - #VOTESNEEDED_CUFF))
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
	}
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP)
	{
		if (num_for > num_total * #VOTESNEEDED_NEXTMAP) // success?
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);
			
			bprint(#PRINT_HIGH,"Votingç Success° Setting ",st," as next map\n");

			localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
			localcmd("localinfo neo \"\"\n"); // make sure Neo mode is going to be off

			localcmd("localinfo nmap \"");
			localcmd(current_voteent.netname);
			localcmd("\"\n");
			
			BroadcastSound("misc/runekey");

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
		else if (num_against >= num_total * (1 - #VOTESNEEDED_NEXTMAP))
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	}
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP)
	{
		if (num_for > num_total * #VOTESNEEDED_MAP) // success?
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);

			bprint(#PRINT_HIGH,"Votingç Success° Switching map to ",st,"\n");

			localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
			// begin Neo modification
			localcmd("localinfo neo \"\"\n"); // make sure Neo mode is going to be off

			BroadcastSound("misc/runekey");

			LaunchMap(current_voteent.netname);

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
		else if (num_against >= num_total * (1 - #VOTESNEEDED_MAP))
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	}
	// Neo mode
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP_NEO) 
	{
		if (num_for > num_total * #VOTESNEEDED_NEXTMAP) // success?
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);
			
			bprint(#PRINT_HIGH,"\nVotingç Success° Setting ",st," as next map, in ŒÂÔ ÕÔ‰Â\n");

			localcmd("localinfo neo 1\n");
			localcmd("localinfo agr \"\"\n"); // make sure AGR mode is going to be off

			localcmd("localinfo nmap \"");
			localcmd(current_voteent.netname);
			localcmd("\"\n");
			
			BroadcastSound("misc/runekey");

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
		else if (num_against >= num_total * (1 - #VOTESNEEDED_NEXTMAP))
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	}
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP_NEO)
	{
		if (num_for > num_total * #VOTESNEEDED_MAP) // success?
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);

			bprint(#PRINT_HIGH,"\nVotingç Success° Switching map to ",st,", in ŒÂÔ ÕÔ‰Â\n");

			localcmd("localinfo neo 1\n");
			localcmd("localinfo agr \"\"\n"); // make sure AGR mode is going to be off
			// end Neo modification
			BroadcastSound("misc/runekey");

			LaunchMap(current_voteent.netname);

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
		else if (num_against >= num_total * (1 - #VOTESNEEDED_MAP))
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	}
	// end Neo
	// PZ - begin AGR code
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP_AGR) 
	{
		if (num_for > num_total * #VOTESNEEDED_NEXTMAP) // success?
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);
			
			bprint(#PRINT_HIGH,"\nVotingç Success° Setting ",st," as next map, in ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰ mode\n");

			localcmd("localinfo agr 1\n");
			localcmd("localinfo neo \"\"\n"); // make sure Neo mode is going to be off

			localcmd("localinfo nmap \"");
			localcmd(current_voteent.netname);
			localcmd("\"\n");
			
			BroadcastSound("misc/runekey");

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
		else if (num_against >= num_total * (1 - #VOTESNEEDED_NEXTMAP))
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	}
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP_AGR)
	{
		if (num_for > num_total * #VOTESNEEDED_MAP) // success?
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);

			bprint(#PRINT_HIGH,"\nVotingç Success° Switching map to ",st,", in ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰ mode\n");

			localcmd("localinfo agr 1\n");
			localcmd("localinfo neo \"\"\n"); // make sure Neo mode is going to be off

			BroadcastSound("misc/runekey");

			LaunchMap(current_voteent.netname);

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
		else if (num_against >= num_total * (1 - #VOTESNEEDED_MAP))
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	} 
	// PZ - end AGR code

	return #FALSE;
};

//==========================================================================
// Checks if valid vote entity

float() ValidVoteEnt =
{
	if (current_voteent == world)
		return #FALSE;

	if (current_voteent.classname != "voteent")
		return #FALSE;
	
	return #TRUE;
};


//============================================================
// gets the map localinfo string for the number passed in

string(float themap) GetMapString =
{
	local string st, mapnum, temp;
	
	mapnum = ftos(themap);

	temp = strcat("m",mapnum);
	st = infokey(world,temp);
	
	return st;
};

//===============================================================
// Prints remaining votes for success

void() bprintVotesLeft =
{
	local string st;
	local float num_for, num_against;
	local entity te;
	
	// Count the number of votes for and against.
	te = nextent(world);
	while (te != world) {
		if (te.classname == "player" || te.classname == "spec") {
			if (te.owned_by == #VOTED_YES) {
				num_for = num_for + 1;
			} else if (te.owned_by == #VOTED_NO) {
				num_against = num_against + 1;
			}
		}
		te = nextent(te);
	}
	
	st = colstr(ftos(num_for), #COLSTR_NUMBER);
	bprint(#PRINT_HIGH, " €", st, " for Ø ");
	
	st = colstr(ftos(num_against), #COLSTR_NUMBER);
	bprint(#PRINT_HIGH, st, " against›\n");
	
	//›\n
};

//======================================================================================
// The current punishment vote goes to sleep (player to be muted/cuffed hides away)

// Warning: here we assume self is the player leaving server to be punished
void() VoteToSleep =
{
	local string st;
	
	// First clean up any sleeping vote
	CleanUpSleepVote();

	current_voteent.think = VoteSleep_think;
	current_voteent.nextthink = time + #VOTESLEEP_RATECHECK;
	current_voteent.classname = "sleepvote";

	st = infokey(self,"ip");

	current_voteent.message = makestr(st);
	current_voteent.admin_kick = world;
	current_voteent.ltime = time;

	current_voteent = world;

	votesleeping = #TRUE;
};

void() VoteSleep_think =
{
	self.nextthink = time + #VOTESLEEP_RATECHECK;

	if (!ValidVoteEnt())
	{
		if (self.admin_kick != world)
		{
			if (!self.admin_kick.is_connected) // He tries to hide again? lol
				self.admin_kick = world; // reset
			else
				SleepVoteResume(self, self.admin_kick);
		}
	}

	// Check if we should discard this sleeping vote
	if (floor((time - self.ltime) / 60) > #VOTESLEEP_DURATION)
	{
		delstr(self.message);
		dremove(self);
		votesleeping = #FALSE;
	}
};

void() CleanUpSleepVote =
{
	local entity te;

	te = find(world,classname,"sleepvote");

	while (te)
	{
		delstr(te.message);
		dremove(te);

		te = find(te,classname,"sleepvote");
	}

	votesleeping = #FALSE;
};

entity() GetSleepVote =
{
	local entity te;

	te = find(world,classname,"sleepvote");

	return te;
};

void(entity sleepent, entity targetclient) SleepVoteResume =
{
	delstr(sleepent.message);
	
	current_voteent = sleepent;
	current_voteent.think = PunishVote_Think;
	current_voteent.nextthink = time + #VOTE_TIME;
	current_voteent.classname = "voteent";
	current_voteent.admin_kick = targetclient;

	votesleeping = #FALSE;

	BroadcastSound("misc/medkey");

	bprint(#PRINT_HIGH,"Votingç Resuming vote to ");
	if (current_voteent.g_a == #PUNISH_MUTE)
		bprint(#PRINT_HIGH,"mute ");
	else if (current_voteent.g_a == #PUNISH_CUFF)
		bprint(#PRINT_HIGH,"cuff ");
	bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
	bprintVotesLeft();
};

