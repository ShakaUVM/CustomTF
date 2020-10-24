
/*======================================================
	STATUS.QC			TeamFortress v2.5	

	(c) TeamFortress Software Pty Ltd	13/5/97
	(c) Craig Hauser			26/3/00
========================================================
TF status bar functions
=======================================================*/

float(float tno) TeamFortress_TeamGetScore;

////////////////////////////////////////////////////
//	NumberToStringxxx functions
//	take an integer, return a constant string.
#ifdef STATUSBAR

void(entity pl, float fTime, string s1) StatusPrint;

string(entity pl) GetStatusSize;

string(entity pl) ClipSizeToString100;
//string(float num) NumberToString10;
string(entity te, float devicenum) SentryDetailsToString;
string(entity te, float devicenum) TeslaDetailsToString;

//used for print
string(float tno) GetTrueTeamName;
string(float pc) TeamFortress_GetClassName;
string(float pc) TeamFortress_GetJobName;

//void(entity demon) custom_demon_name;

//- OfN -
float(entity thing) IsMonster;
float(entity player) HasMonster;
entity(entity warlock, float numsummon) GetSummon;
float(entity player, float type) GetNumTypeMonster;

/////////////////////////////////////////////////////////////////
// CenterPrint replacement.  Takes into account the status bar //
/////////////////////////////////////////////////////////////////
void(entity pl, string s1) CenterPrint =
{
	centerprint(pl, s1);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2) CenterPrint2 =
{
	centerprint(pl, s1, s2);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3) CenterPrint3 =
{
	centerprint(pl, s1, s2, s3);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4) CenterPrint4 =
{
	centerprint(pl, s1, s2, s3, s4);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4, string s5) CenterPrint5 =
{
	centerprint(pl, s1, s2, s3, s4, s5);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6) CenterPrint6 =
{
	centerprint(pl, s1, s2, s3, s4, s5, s6);
	pl.StatusRefreshTime = time + 1;
};

void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6, string s7) CenterPrint7 =
{
	centerprint(pl, s1, s2, s3, s4, s5, s6, s7);
	pl.StatusRefreshTime = time + 1;
};

//////////////////////////////////////////////////////////////////
// StatusPrint - like centerprint, but works with the status bar
void(entity pl, float fTime, string s1) StatusPrint =
{
	centerprint(pl, s1);
	pl.StatusRefreshTime = time + fTime;
};

void(entity pl) RefreshStatusBar =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;
	local float num;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == #PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);
	num = ceil(team1score);
	/*if (num >= 1000)
	{
		s3 = s4 = s5 = "9";
	}
	else
	{
//CH The below functions take a number and print out each character
		if (num >= 100)
			s3 = NumberToString10(floor(num/100));
		else
			s3 = " ";
		if (num >= 10)
			s4 = NumberToString10(floor((num - (floor(num/100)*100))/10));
		else
			s4 = " ";
		if (num > 0)
			s5 = NumberToString10(floor((num - (floor(num/10)*10))));
		else
			s5 = "0";
	}*/

	s2 = "Blue: ";

	s3 = (ftos(ceil(team1score)));

	if (ceil(team1score) < 10)
		s3 = strcat("  ",s3);
	else if (ceil(team1score < 100))
		s3 = strcat(" ",s3);
	
	//s2 = "Βμυε: ";
	//s3 = (ftos(ceil(team1score)));
	//s4 = " Òεδ: "
	//s5 = (ftos(ceil(team2score)));

	s4 = (ftos(ceil(team2score)));

	if (ceil(team2score) < 10)
		s4 = strcat("  ",s4);
	else if (ceil(team2score < 100))
		s4 = strcat(" ",s4);
	
	s4 = strcat("  Red : ",s4);

	s5 = ClipSizeToString100(pl);
	s6 = "";
	s7 = "";

	if (number_of_teams == 3)
	{
		s6 = (ftos(ceil(team3score)));

		if (ceil(team3score) < 10)
			s6 = strcat("  ",s6);
		else if (ceil(team3score < 100))
			s6 = strcat(" ",s6);
	
		s6 = strcat("\nYellow: ",s6);
	}

	if (number_of_teams == 4)
	{
		s6 = (ftos(ceil(team3score)));

		if (ceil(team3score) < 10)
			s6 = strcat("  ",s6);
		else if (ceil(team3score < 100))
			s6 = strcat(" ",s6);
	
		s6 = strcat("\nYell: ",s6);

		s7 = (ftos(ceil(team4score)));

		if (ceil(team4score) < 10)
			s7 = strcat("  ",s7);
		else if (ceil(team4score < 100))
			s7 = strcat(" ",s7);

		s7 = padstr(s7,12);
		
		s7 = strcat("  Teal: ",s7);
	}
		
	//s7 = ClipSizeToString100(pl);
	centerprint(pl, s1, s2, s3, s4, s5, s6,s7);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if ((self.has_sentry & 1) || (self.has_tesla & 1 && self.tf_items & #NIT_DOUBLETESLA))
		self.StatusBarScreen = 1;
	else if (self.has_tesla || self.has_sentry & 2)
		self.StatusBarScreen = 4;
	else if (self.scaned != self)
		self.StatusBarScreen = 5;
	else if (self.is_undercover != 0)
		self.StatusBarScreen = 2;  // (self.job & #JOB_WARLOCK && self.job & #JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & #JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//sentry bar :)
void(entity pl) RefreshStatusBar1 =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;
	//local string val;
	//local float num;
	local entity te;
	local entity sent;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == #PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);

	if (self.tf_items & #NIT_DOUBLETESLA)
	{
		te = find(world, classname, "building_tesla");
		while (te)
		{
			if (te.real_owner == self)
			if (te.dont_do_triggerwork & 1)
			{
				sent = te;
			}
			te = find(te, classname, "building_tesla");
		}
		//- OfN - if (sent.enemy.classname == "monster_demon1" || sent.enemy.classname == "monster_army" || sent.enemy.classname == "monster_shambler" )
		/*if (IsMonster(sent.enemy))
			custom_demon_name(sent.enemy); //CH*/
		
		s2 = TeslaDetailsToString(sent,1);
		s3 = ftos(floor((sent.health / sent.max_health) * 100));
		s4 = "₯ health  ";
		if (sent.oldenemy != world)
		{
			s5 = "\nΑτταγλιξη: ";
			s6 = sent.enemy.netname;
		}
		else
		{
			s5 = "Idle";
			s6 = " ";
		}
	}
	else
	{
		te = find(world, classname, "building_sentrygun");
		while (te)
		{
			if (te.real_owner == self)
			if (te.dont_do_triggerwork & 1)
			{
				
				sent = te;
			}
			te = find(te, classname, "building_sentrygun");
		}

		if (self.cutf_items & #CUTF_DOUBLESENTRY)
			s2 = SentryDetailsToString(sent,1);
		else
			s2 = SentryDetailsToString(sent,0);
		
		s3 = ftos(floor((sent.health / sent.max_health) * 100));
		s4 = "₯ health  ";

		if (sent.enemy != world)
		{
			s5 = "\nΑτταγλιξη: ";
			s6 = sent.enemy.netname;
		}
		else
		{
			s5 = "Idle";
			s6 = " ";
		}
	}
		
	if (self.is_building)
	{
		s7 = "\n  building...     \n";
	}
	else
	{
		s7 = ClipSizeToString100(pl);
	}

	centerprint(pl, s1, s2, s3, s4, s5, s6,s7);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if ((self.has_tesla && !(self.tf_items & #NIT_DOUBLETESLA)) || (self.has_sentry & 2) || (self.has_tesla & 2))
		self.StatusBarScreen = 4;
	else if (self.scaned != self)
		self.StatusBarScreen = 5;
	else if (self.is_undercover != 0)
		self.StatusBarScreen = 2; //(self.job & #JOB_WARLOCK && self.job & #JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & #JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//Tesla bar :)
void(entity pl) RefreshStatusBar4 =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;
	//local string val;
	//local float num;
	local entity te;
	local entity sent;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == #PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);

	if (self.cutf_items & #CUTF_DOUBLESENTRY)
	{
		te = find(world, classname, "building_sentrygun");
		while (te)
		{
			if (te.real_owner == self)
			if (te.dont_do_triggerwork & 2)
			{
				sent = te;
			}
			te = find(te, classname, "building_sentrygun");
		}

		s2 = SentryDetailsToString(sent,2);
		s3 = ftos(floor((sent.health / sent.max_health) * 100));
		s4 = "₯ health  ";

		if (sent.enemy != world)
		{
			s5 = "\nΑτταγλιξη: ";
			s6 = sent.enemy.netname;
		}
		else
		{
			s5 = "Idle";
			s6 = " ";
		}
	}
	else
	{
		te = find(world, classname, "building_tesla");
		while (te)
		{
			if (te.real_owner == self)
			if (!(self.tf_items & #NIT_DOUBLETESLA) || te.dont_do_triggerwork & 2)
			{
				sent = te;
			}
			te = find(te, classname, "building_tesla");
		}
		//- OfN - if (sent.enemy.classname == "monster_demon1" || sent.enemy.classname == "monster_army" || sent.enemy.classname == "monster_shambler" )
		/*if (IsMonster(sent.enemy))
			custom_demon_name(sent.enemy); //CH*/
		
		if (self.tf_items & #NIT_DOUBLETESLA)
			s2 = TeslaDetailsToString(sent,2);
		else
			s2 = TeslaDetailsToString(sent,0);
		
		s3 = ftos(floor((sent.health / sent.max_health) * 100));
		s4 = "₯ health  ";
		if (sent.oldenemy != world)
		{
			s5 = "\nΑτταγλιξη: ";
			s6 = sent.enemy.netname;
		}
		else
		{
			s5 = "Idle";
			s6 = " ";
		}
	}

	if (self.is_building)
	{
		s7 = "\n  building...     \n";
	}
	else
	{
		s7 = ClipSizeToString100(pl);
	}

	centerprint(pl, s1, s2, s3, s4, s5, s6,s7);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if (self.scaned != self)
		self.StatusBarScreen = 5;
	else if (self.is_undercover != 0)
		self.StatusBarScreen = 2; //(self.job & #JOB_WARLOCK && self.job & #JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & #JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//Scanner Screen
void(entity pl) RefreshStatusBar5 =
{
	local string s1, s2, s3, s4;
	local string s5, s6, s7;
	//local entity tg;
	//local float num;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == #PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);
	s6 = ftos(ceil(vlen(self.scaned.origin - self.origin)));
	s7 = ClipSizeToString100(pl);
	if (self.scaned.classname == "player" && self.scaned.playerclass != #PC_UNDEFINED)
	{
		s2 = GetTrueTeamName(self.scaned.team_no);
		s3 = ": ";
		if (self.enemy.playerclass != #PC_CUSTOM)
			s4 = TeamFortress_GetClassName(self.scaned.playerclass);
		else 
			s4 = TeamFortress_GetJobName(self.scaned.job);
		s5 = "\nRange: ";
		centerprint(pl, s1, s2, s3, s4, s5, s6,s7);
	}
	//else if ((self.scaned.classname == "building_sentrygun" || self.scaned.classname == "building_tesla" || self.scaned.classname == "building_teleporter" || self.scaned.classname == "monster_demon1") && self.scaned.health > 0)
	else if ((self.scaned.classname == "building_sentrygun" || self.scaned.classname == "building_tesla" || self.scaned.classname == "building_teleporter" || IsMonster(self.scaned)) && self.scaned.health > 0)
	{
		//- OfN - if (self.scaned.classname == "monster_demon1" || self.scaned.classname == "monster_army" || self.scaned.classname == "monster_shambler")
		if (IsMonster(self.scaned))
		{
			//custom_demon_name(self.scaned); //CH
			s2 = GetTrueTeamName(self.scaned.real_owner.team_no); //demons are special
		}
		else
			s2 = GetTrueTeamName(self.scaned.team_no);
		if (self.scaned.classname == "building_sentrygun")
			s3 = ": Sentry Gun (";
		else if (self.scaned.classname == "building_tesla")
			s3 = ": Tesla Sentry (";
		else if (self.scaned.classname == "building_teleporter")
			s3 = ": Teleporter Pad (";
		else if (self.scaned.classname == "monster_demon1")
			s3 = ": Demon (";
		else if (self.scaned.classname == "monster_army")
			s3 = ": Soldier (";
		else if (self.scaned.classname == "monster_shambler")
			s3 = ": Shambler (";
		else if (self.scaned.classname == "monster_wizard")
			s3 = ": Scrag (";
		else if (self.scaned.classname == "monster_fish")
			s3 = ": Piranha (";
		else if (self.scaned.classname == "monster_gremlin")
			s3 = ": Gremlin (";
		else 
			s3 = "!!!ERROR!!!";
		s4 = self.scaned.real_owner.netname;
		s5 = ")\nRange: ";
		centerprint(pl, s1, s2, s3, s4, s5, s6, s7);
	}
	else if (self.scaned.classname == "item_tfgoal")
	{
		s2 = GetTrueTeamName(self.scaned.owned_by);
		s3 = ": Item(";
		s4 = self.scaned.netname;
		s5 = ")\nRange: ";
		centerprint(pl, s1, s2, s3, s4, s5, s6, s7);
	}
	else
		pl.StatusRefreshTime = time + 0.1;

	self.scaned = self; //Reset it.

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
	if (self.is_undercover != 0)
		self.StatusBarScreen = 2; //(self.job & #JOB_WARLOCK && self.job & #JOB_DEMON_OUT)
	else if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & #JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;
};

//Spy Screen
void(entity pl) RefreshStatusBar2 =
{
	local string s1, s2, s3, s4;
	local string s5;//, s6, s7;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == #PC_UNDEFINED)
		return;

	s1 = GetStatusSize(pl);
	
	if (self.is_undercover == 2)
		s2 = "Disguising: ";
	else if (self.is_undercover == 1)
		s2 = "Σλιξ: ";
	else
		s2 = "Uncovered ";
	if (invis_only)
	{
		s3 = "     Inviso     ";
		s4 = "\n";
	}
	else
	{
		if (self.undercover_team >= 1 && self.undercover_team <= 4)
			s3 = GetTrueTeamName(self.undercover_team);
		else
			s3 = "      ";
		if (self.undercover_skin == 1)
			s4 = " Scout   ";
		else if (self.undercover_skin == 2)
			s4 = " Sniper  ";
		else if (self.undercover_skin == 3)
			s4 = " Soldier ";
		else if (self.undercover_skin == 4)
			s4 = " Demoman ";
		else if (self.undercover_skin == 5)
			s4 = " Medic   ";
		else if (self.undercover_skin == 6)
			s4 = " Hvy Wpns";
		else if (self.undercover_skin == 7)
			s4 = " Pyro    ";
		else if (self.undercover_skin == 8)
			s4 = " Spy     ";
		else if (self.undercover_skin == 9)
			s4 = " Engineer";
		else
			s4 = "         ";
	}
	s5 = ClipSizeToString100(pl);
	centerprint(pl, s1, s2, s3, s4, s5);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
							//(self.job & #JOB_WARLOCK && self.job & #JOB_DEMON_OUT)||(self.job & #JOB_ARMY && self.job & #JOB_DEMON_OUT)
	if (self.is_detpacking || HasMonster(self) || (self.is_haxxxoring && self.job & #JOB_HACKER))
		self.StatusBarScreen = 3;
	else
		self.StatusBarScreen = 0;

};
//Misc Screen
void(entity pl) RefreshStatusBar3 =
{
	local string s1, s2, s3, s4;
	local string s5, s6;//, s7;
	//local entity tg;
	//local float num;

	if (pl.StatusBarSize == 0)
	{
		pl.StatusRefreshTime = time + 60;
		return;
	}

	pl.StatusRefreshTime = time + 1.0;
	if (pl.playerclass == #PC_UNDEFINED)
		return;

	s4 = "";
	s5 = "";

	s1 = GetStatusSize(pl);

	   //(self.job & #JOB_WARLOCK && self.job & #JOB_DEMON_OUT)||(self.job & #JOB_ARMY && self.job & #JOB_DEMON_OUT)
	if (self.is_haxxxoring && self.job & #JOB_HACKER)
	{
		if (self.demon_two.has_camera == -2) // we r aborting hack...
		{
			s2 = "\nΘαγλ: Aborting...";
			s3 = "";
			s4 = "";
		}
		else
		{
			s2 = "\nΘαγλ: ";
			s3 = ftos(100 - floor((self.demon_two.heat/self.demon_two.ltime) * 100));
			s4 = "₯ completed";
		}
	}	 
	else if (HasMonster(pl))
	{
		local entity targ;
		local float targnum;
		
		if (self.increase_team4 > 2) // because guerilla may set this field
			self.increase_team4 = 0;

		targ = GetSummon(self,self.increase_team4);

		targnum = self.increase_team4;

		if (!targ)
		{
			targnum = targnum +1;
			if (targnum > 2)
				targnum = 0;

			targ = GetSummon(self,targnum);

			if (!targ)
			{
				targnum = targnum +1;
				if (targnum > 2)
					targnum = 0;

				targ = GetSummon(self,targnum);

				if (!targ)
				{
					targnum = targnum +1;
					if (targnum > 2)
						targnum = 0;

					targ = GetSummon(self,targnum);
				}
			}
		}

		self.increase_team4 = targnum;

		if (!targ)
		{
			centerprint(self,"\n\n\n\n\n\nERROR in monsters status bar!\n\nTell to OfteN[cp], please!");
			return;
		}
				
		if (targ.classname == "monster_army")
			s2 = "\nΣομδιες";
		else if (targ.classname == "monster_shambler")
			s2 = "\nΣθανβμες";
		else if (targ.classname == "monster_wizard")
			s2 = "\nΣγςαη";
		else if (targ.classname == "monster_demon1")
			s2 = "\nΖιεξδ";
		else if (targ.classname == "monster_fish")
			s2 = "\nΠιςαξθα";
		else if (targ.classname == "monster_gremlin")
			s2 = "\nΗςενμιξ";

		if (self.job & #JOB_WARLOCK)
		{
			// Get number of monsters of this kind the player has
			local float thiskind;
			thiskind = GetNumTypeMonster(self,targ.#monster_type);
			
			if (thiskind > 1) // More than one?
			{
				// Ok then, show number of soul also
				local string tmp;
				tmp = ftos(targnum+1);
				tmp = colstr(tmp,#COLSTR_NUMBER);

				if (self.job & #JOB_WARLOCK)
				{
					s2 = strcat(s2," ¨soul ");
					s2 = strcat(s2,tmp);
					s2 = strcat(s2,"©: ");
				}
			}
			else // no need to display number of soul
				s2 = strcat(s2,": ");
		}
		else // army 
		{
			if (GetJobExtras(self) == 0)
				s2 = strcat(s2,": ");
			else
			{
				local string tmp;
				tmp = ftos(targnum+1);
				tmp = colstr(tmp,#COLSTR_NUMBER);

				s2 = strcat(s2," ");
				s2 = strcat(s2,tmp);
				s2 = strcat(s2,": ");
			}
		}
			
		s3 = ftos(floor((targ.health / targ.max_health) * 100));
		s4 = "₯ health";

		self.increase_team4 = self.increase_team4 +1;
		if (self.increase_team4 > 2)
			self.increase_team4 = 0;
	}
	else
	{
		s2 = "";
		s3 = "";
	}
	
	if (self.is_detpacking)
	{
		//s4 = "\n\n "; //- OfN \n\n
		s5 = "\n Setting Detpack... ";
	}
	
	//else
		
	s6 = ClipSizeToString100(pl);
	centerprint(pl, s1, s2, s3, s4, s5, s6);

//CH determines which screen to show next (its at the end of all RefreshStatusBars)
		self.StatusBarScreen = 0;
};

//////////////////////////////////////////////////////////////////
// Status Bar Resolution Settings 
// Thanks goes to Dave 'Zoid' Kirsch (zoid@threewave.com) from CTF
// for the res settings.
string(entity pl) GetStatusSize =
{
	if (pl.StatusBarSize == 1)
	{
		if (pl.StatusBarRes > 7) // 768 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 7) // 600 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 6) // 480 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 5) // 400
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 4) // 384 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 3) // 350 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 2) // 300 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 1) // 240 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		// 200 
		return "\n\n\n\n\n\n\n\n\n\n";
	}
	else // if (pl.StatusBarSize == 2)
	{
		if (pl.StatusBarRes > 7) // 768 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 7) // 600 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 6) // 480 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 5) // 400
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 4) // 384 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 3) // 350 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 2) // 300 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		else if (pl.StatusBarRes == 1) // 240 
			return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		// 200 
		return "\n\n\n\n\n\n\n\n\n\n\n\n\n";
	}
};

void(float res) StatusRes =
{
	self.StatusBarRes = res;

	if (res > 7) // 768 
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 1024x768.\n");
	else if (res == 7) // 600 
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 800x600.\n");
	else if (res == 6) // 480 
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 640x480.\n");
	else if (res == 5) // 400
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 640x400.\n");
	else if (res == 4) // 384 
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 512x384.\n");
	else if (res == 3) // 350 
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 320x350.\n");
	else if (res == 2) // 300 
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 400x300.\n");
	else if (res == 1) // 240 
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 320x240.\n");
	else
		sprint(self, #PRINT_HIGH, "Status Bar Res set to 320x200.\n");
};

string(entity pl) ClipSizeToString100 =
//CH edited b/c nothing has over 20
{
	//---------------- CLIP EXTENDER (same as below but with _EX values -------------//
	if (pl.cutf_items & #CUTF_CLIPEXTEND)
	{
		//---//
		local float num;

		if (pl.current_weapon == #WEAP_SHOTGUN)
		{
			if (#RE_SHOTGUN_EX - pl.reload_shotgun > pl.ammo_shells)
				pl.reload_shotgun = #RE_SHOTGUN_EX - pl.ammo_shells;
			num = #RE_SHOTGUN_EX - pl.reload_shotgun;
		}
		else if (pl.current_weapon == #WEAP_SUPER_SHOTGUN)
		{
			if (#RE_SUPER_SHOTGUN_EX - pl.reload_super_shotgun > pl.ammo_shells)
				pl.reload_super_shotgun = #RE_SUPER_SHOTGUN_EX - pl.ammo_shells;
			num = #RE_SUPER_SHOTGUN_EX - pl.reload_super_shotgun;
		}
		else if (pl.current_weapon == #WEAP_GRENADE_LAUNCHER)
		{
			if (#RE_GRENADE_LAUNCHER_EX - pl.reload_grenade_launcher > pl.ammo_rockets)
				pl.reload_grenade_launcher = #RE_GRENADE_LAUNCHER_EX - pl.ammo_rockets;
			num = #RE_GRENADE_LAUNCHER_EX - pl.reload_grenade_launcher;
		}
		else if (pl.current_weapon == #WEAP_ROCKET_LAUNCHER)
		{
			if (#RE_ROCKET_LAUNCHER_EX - pl.reload_rocket_launcher > pl.ammo_rockets)
				pl.reload_rocket_launcher = #RE_ROCKET_LAUNCHER_EX - pl.ammo_rockets;
			num = #RE_ROCKET_LAUNCHER_EX - pl.reload_rocket_launcher;
		}
		else if (pl.current_weapon == #WEAP_LIGHT_ASSAULT)
		{
			if (#RE_LIGHT_ASSAULT_EX - pl.reload_light_assault > pl.ammo_nails)
				pl.reload_light_assault = #RE_LIGHT_ASSAULT_EX - pl.ammo_nails;
			num = #RE_LIGHT_ASSAULT_EX - pl.reload_light_assault;
		}
		else if (pl.current_weapon == #WEAP_LASERCANNON)
		{
			if (#RE_LASER_CANNON_EX - pl.reload_laser_cannon > pl.ammo_cells)
				pl.reload_laser_cannon = #RE_LASER_CANNON_EX - pl.ammo_cells;
			num = #RE_LASER_CANNON_EX - pl.reload_laser_cannon;
		}
		else
		{
			return "         ";
		}	
	
	}	//---// CLIP EXTENDER
	else
	{
		local float num;

		if (pl.current_weapon == #WEAP_SHOTGUN)
		{
			if (#RE_SHOTGUN - pl.reload_shotgun > pl.ammo_shells)
				pl.reload_shotgun = #RE_SHOTGUN - pl.ammo_shells;
			num = #RE_SHOTGUN - pl.reload_shotgun;
		}
		else if (pl.current_weapon == #WEAP_SUPER_SHOTGUN)
		{
			if (#RE_SUPER_SHOTGUN - pl.reload_super_shotgun > pl.ammo_shells)
				pl.reload_super_shotgun = #RE_SUPER_SHOTGUN - pl.ammo_shells;
			num = #RE_SUPER_SHOTGUN - pl.reload_super_shotgun;
		}
		else if (pl.current_weapon == #WEAP_GRENADE_LAUNCHER)
		{
			if (#RE_GRENADE_LAUNCHER - pl.reload_grenade_launcher > pl.ammo_rockets)
				pl.reload_grenade_launcher = #RE_GRENADE_LAUNCHER - pl.ammo_rockets;
			num = #RE_GRENADE_LAUNCHER - pl.reload_grenade_launcher;
		}
		else if (pl.current_weapon == #WEAP_ROCKET_LAUNCHER)
		{
			if (#RE_ROCKET_LAUNCHER - pl.reload_rocket_launcher > pl.ammo_rockets)
				pl.reload_rocket_launcher = #RE_ROCKET_LAUNCHER - pl.ammo_rockets;
			num = #RE_ROCKET_LAUNCHER - pl.reload_rocket_launcher;
		}
		else if (pl.current_weapon == #WEAP_LIGHT_ASSAULT)
		{
			if (#RE_LIGHT_ASSAULT - pl.reload_light_assault > pl.ammo_nails)
				pl.reload_light_assault = #RE_LIGHT_ASSAULT - pl.ammo_nails;
			num = #RE_LIGHT_ASSAULT - pl.reload_light_assault;
		}
		else if (pl.current_weapon == #WEAP_LASERCANNON)
		{
			if (#RE_LASER_CANNON - pl.reload_laser_cannon > pl.ammo_cells)
				pl.reload_laser_cannon = #RE_LASER_CANNON - pl.ammo_cells;
			num = #RE_LASER_CANNON - pl.reload_laser_cannon;
		}
		else
		{
			return "         ";
		}
	
	} // END ELSE CLIP EXTENDER

	local string tmps,tmps2,tmps3;
	
	tmps = ftos(num);
	
	if (pl.tfstate & #TFSTATE_RELOADING)
		tmps2 = "";
	else
		tmps2 = colstr(tmps,#COLSTR_NUMBER);

	#ifdef OLD_SBARLOOK
	tmps3 = strcat("γμιπ: ",tmps2);
	#else
	if (num < 10 || pl.tfstate & #TFSTATE_RELOADING)
		tmps3 = strcat("  γμιπ: ",tmps2);
	else	
		tmps3 = strcat("  γμιπ:",tmps2);
	#endif

	return tmps3;

	/*if (num < 10)
	{
		if (num < 5)
		{
			if (num == 0)
				return "\nγμιπ: 0";
			else if (num == 1)
				return "\nγμιπ: 1";
			else if (num == 2)
				return "\nγμιπ: 2";
			else if (num == 3)
				return "\nγμιπ: 3";
			else
				return "\nγμιπ: 4";
		}
		else
		{
			if (num == 5)
				return "\nγμιπ: 5";
			else if (num == 6)
				return "\nγμιπ: 6";
			else if (num == 7)
				return "\nγμιπ: 7";
			else if (num == 8)
				return "\nγμιπ: 8";
			else if (num == 9)
				return "\nγμιπ: 9";
		}
	}
	else if (num < 20)
	{
		if (num < 15)
		{
			if (num == 10)
				return "\nγμιπ:10";
			else if (num == 11)
				return "\nγμιπ:11";
			else if (num == 12)
				return "\nγμιπ:12";
			else if (num == 13)
				return "\nγμιπ:13";
			else
				return "\nγμιπ:14";
		}
		else
		{
			if (num == 15)
				return "\nγμιπ:15";
			else if (num == 16)
				return "\nγμιπ:16";
			else if (num == 17)
				return "\nγμιπ:17";
			else if (num == 18)
				return "\nγμιπ:18";
			else if (num == 19)
				return "\nγμιπ:19";
		}
	}
	else if (num < 30)
	{
		if (num < 25)
		{
			if (num == 20)
				return "\nγμιπ:20";
			else if (num == 21)
				return "\nγμιπ:21";
			else if (num == 22)
				return "\nγμιπ:22";
			else if (num == 23)
				return "\nγμιπ:23";
			else if (num == 24)
				return "\nγμιπ:24";
		}
		else
		{
			if (num == 25)
				return "\nγμιπ:25";
			if (num == 26)
				return "\nγμιπ:26";
			if (num == 27)
				return "\nγμιπ:27";
			if (num == 28)
				return "\nγμιπ:28";
			if (num == 29)
				return "\nγμιπ:29";
		}
	}
	else if (num < 40)
	{
		if (num < 35)
		{
			if (num == 30)
				return "\nγμιπ:30";
			else if (num == 31)
				return "\nγμιπ:31";
			else if (num == 32)
				return "\nγμιπ:32";
			else if (num == 33)
				return "\nγμιπ:33";
			else if (num == 34)
				return "\nγμιπ:34";
		}
		else
		{
			if (num == 35)
				return "\nγμιπ:35";
			if (num == 36)
				return "\nγμιπ:36";
			if (num == 37)
				return "\nγμιπ:37";
			if (num == 38)
				return "\nγμιπ:38";
			if (num == 39)
				return "\nγμιπ:39";
		}
	}
	else if (num < 50)
	{
		if (num < 45)
		{
			if (num == 40)
				return "\nγμιπ:40";
			else if (num == 41)
				return "\nγμιπ:41";
			else if (num == 42)
				return "\nγμιπ:42";
			else if (num == 43)
				return "\nγμιπ:43";
			else if (num == 44)
				return "\nγμιπ:44";
		}
		else
		{
			if (num == 45)
				return "\nγμιπ:45";
			if (num == 46)
				return "\nγμιπ:46";
			if (num == 47)
				return "\nγμιπ:47";
			if (num == 48)
				return "\nγμιπ:48";
			if (num == 49)
				return "\nγμιπ:49";
		}
	}
	else if (num >= 50)
		return "\nγμιπ:50";
*/
	//return num;
};
//==========
string(entity te, float devicenum) SentryDetailsToString =
{
	if (!devicenum)
	{
		if (te.ammo_shells == 0)
		{
			if (te.ammo_rockets == 0 && te.weapon == 3)
				return "Σεξτςω: no ammo   \n        ";
			else	   
				return "Σεξτςω: no shells \n        ";
		}
		else if (te.ammo_rockets == 0 && te.weapon == 3)
		{
			return "Σεξτςω: no rockets\n        ";
		}		   
		else
		{		   
			return "                  \nΣεξτςω: ";
		}
	}
	else if (devicenum == 1)
	{
		if (te.ammo_shells == 0)
		{
			if (te.ammo_rockets == 0 && te.weapon == 3)
				return "Σεξτςω £: no ammo   \n           ";
			else	   
				return "Σεξτςω £: no shells \n           ";
		}
		else if (te.ammo_rockets == 0 && te.weapon == 3)
		{
			return "Σεξτςω £: no rockets\n           ";
		}		   
		else
		{		   
			return "                  \nΣεξτςω £: ";
		}	 
	}
	else if (devicenum == 2)
	{
		if (te.ammo_shells == 0)
		{
			if (te.ammo_rockets == 0 && te.weapon == 3)
				return "Σεξτςω £: no ammo   \n           ";
			else	   
				return "Σεξτςω £: no shells \n           ";
		}
		else if (te.ammo_rockets == 0 && te.weapon == 3)
		{
			return "Σεξτςω £: no rockets\n           ";
		}		   
		else
		{		   
			return "                  \nΣεξτςω £: ";
		}	 
	}

	return "                           \n"; // should never happen
};
//==========
string(entity te, float devicenum) TeslaDetailsToString =
{
	if (!devicenum)
	{
		if (te.ammo_cells == 0)
		{
			return "Τεσμα:     No cells\n       ";
		}
		else if (te.ammo_cells <= 30)
		{
			return "Τεσμα: Low on cells\n       ";
		}
		else
		{		   
			return "                   \nΤεσμα: ";
		}
	}
	else if (devicenum == 1)
	{
		if (te.ammo_cells == 0)
		{
			return "Τεσμα £:     No cells\n          ";
		}
		else if (te.ammo_cells <= 30)
		{
			return "Τεσμα £: Low on cells\n        : ";
		}
		else
		{		   
			return "                   \nΤεσμα £: ";
		}
	}
	else if (devicenum == 2)
	{
		if (te.ammo_cells == 0)
		{
			return "Τεσμα £:     No cells\n          ";
		}
		else if (te.ammo_cells <= 30)
		{
			return "Τεσμα £: Low on cells\n          ";
		}
		else
		{		   
			return "                   \nΤεσμα £: ";
		}
	}

	return "                           \n"; // should never happen
};
/*string(float num) NumberToString10 =
{
	if (num == 0)
		return "0";
	else if (num == 1)
		return "1";
	else if (num == 2)
		return "2";
	else if (num == 3)
		return "3";
	else if (num == 4)
		return "4";
	else if (num == 5)
		return "5";
	else if (num == 6)
		return "6";
	else if (num == 7)
		return "7";
	else if (num == 8)
		return "8";
	else if (num == 9)
		return "9";
	else
		return "A"; //CH just in case
};*/

#endif
