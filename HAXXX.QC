
/*=======================================================//
// haxxx.QC - CustomTF 3.2.OfN			   - 30/1/2001 - //
// Idea and base code by SB-1 tech, rewritten by often	 //
//=======================================================//
// Hacker related stuff 								 //
//=======================================================*/

void(float input) InitiateInterface;
string(entity thebuilding) GetBuildingName;
//float(float input) itob;
float (entity hacked) GetICELevel;
float() CheckHaxxx;
void(entity ignore, string st, string st2, string st3, string st4, string st5, string st6) teamsprint6;
void(entity ent) MuzzleFlash;
float() Engineer_RearmSentryGun;
float() Engineer_RepairSentryGun;
float() Engineer_RepairTesla;

void () Menu_Friend_Hax =
{
	if (self.demon_two == world) // safety
	{
		sprint(self,#PRINT_HIGH,"You have lost the connection!\n");
		ResetMenu();
		return;
	}
	
	local string st,st2,st3,st4,st5,st6,st7;

	st6="\n\nCom≠Link ÂÛÙ·‚ÏÈÛËÂ‰";
	st7=" ¡„ÙÈÔÓ:                    \n\n";
	st5="\n\n.. Hack-Repair      €10 sec›\n\n.. ŒÔÙËÈÓÁ                  "; 
	st4="";
	st2="\n.. Add ÏÂˆÂÏ  ICE  €20 sec›";

	if (!visible2x(self,self.demon_two)) st6="\n\nLost connection with target!\n";
/*	  else 
	{
		local float dist;
		dist = vlen(self.origin - self.demon_two.origin);
		if (dist > #HAX_UNSTABLEDIST)
		{
			st6="\n\nUnstable connection with target!\n";
		}
	}*/

	if (Teammate(self.demon_two.real_owner, self))
	{
		if (self.demon_two.classname == "building_dispenser")
		{
			st7="Target∫ Friendly Dispenser\n\n"; 
			st=".. Improve capacity €15 sec›"; // DONE
			st3="\n.. Enhance armour   €10 sec›"; // DONE
			st4="\n.. Upgrade          €30 sec›";
		}
		else if (self.demon_two.classname == "building_sentrygun")
		{
			st7="Target∫ Friendly Sentry Gun\n\n";			
			st=".. Improve capacity €10 sec›"; // DONE - increase shells only
			st3="\n.. Enhance armour   €25 sec›";
			st4="\n.. Enhance circuits €30 sec›"; // DONE
		}
		else if (self.demon_two.classname == "building_tesla")
		{
			st7="Target∫ Friendly Tesla Sentry\n\n";
			st=".. Improve capacity €10 sec›"; // DONE
			st3="\n.. Enhance armour   €25 sec›"; // DONE
			st4="\n.. Enhance circuits €30 sec›"; //\n.. Add TractorBeam €20 sec›");
		}
		else if (self.demon_two.classname == "building_camera")
		{
			st7="Target∫ Friendly Camera\n\n";
			st=".. Improve sensors  €20 sec›"; // DONE
			st3="\n.. Enhance armour   €20 sec›"; // DONE		 
		}
		else if (self.demon_two.classname == "building_sensor")
		{
			st7="Target∫ Friendly Motion Sensor\n\n";
			st=".. Improve range    €20 sec›"; // DONE
			st3="\n.. Enhance armour   €10 sec›"; // DONE
			st4="\n.. Add spy revealer €25 sec›"; // DONE
		}
		else if (self.demon_two.classname == "building_teleporter")
		{
			st7="Target∫ Friendly Teleporter\n\n";
			st=".. Improve capacity  €5 sec›"; // DONE
			st3="\n.. Enhance armour   €20 sec›"; // DONE
			st4="\n.. Increase range   €30 sec›"; // DONE
		}
		else if (self.demon_two.classname == "building_fieldgen")
		{
			st7="Target∫ Friendly Field Generator\n\n";
			st=   ".. Improve capacity €10 sec›"; // DONE
			st3="\n.. Enhance armour   €15 sec›"; // DONE
			st4="\n.. Increase range   €20 sec›"; // DONE
		}
	}

	if (self.demon_two.all_active & #IMPROVED_ONE)
	{
		st="";
	}
	if (self.demon_two.all_active & #IMPROVED_TWO)
	{
		st2="\n.. Add ÏÂˆÂÏ  ICE  €25 sec›";
		if (self.demon_two.all_active & #IMPROVED_FIVE)
		{
			st2="\n.. Add ÏÂˆÂÏ  ICE  €30 sec›";

			if (self.demon_two.all_active & #IMPROVED_SIX)
			   st2="\n";
		}
		
	}
	if (self.demon_two.all_active & #IMPROVED_THREE)
	{
		st3="\n";
	}
	
	if (self.demon_two.classname != "building_sensor")
	{
		if (self.demon_two.all_active & #IMPROVED_FOUR)
		{
		 st4="\n";
		}
	}
	else
	{
		if (self.demon_two.all_active & #IMPROVED_FOUR)
		{
			if (self.demon_two.all_active & #IMPROVED_SEVEN)
				st4="\n";
			else
				st4="\n.. Thief revealer   €25 sec›";
		}
	}

	CenterPrint7(self,st7,st,st2,st3,st4,st5,st6);	 

};

void(float inp) Menu_FriendHax_Inp =
{
	if (self.classname != "player" || self.demon_two == world)
		return;
	
	if (inp == 10)
	{
		self.impulse=0;
		self.demon_two=world;
		BackFlash(self,1);
		sprint(self,#PRINT_LOW,"Leaving connection with device..\n");
		//CuTFMenuSound(#MENUSOUND_SELL);
		ResetMenu();
		return;
	}
	if (inp == 8)
	{
		self.impulse=0;
		InitiateInterface(inp);
		ResetMenu();
		return;
	}
	if (inp < 5 && inp > 0)
	{
		
		if (inp == 4)
		{
			if (self.demon_two.classname == "building_sensor")
			{
				if (self.demon_two.all_active & #IMPROVED_FOUR)
					inp = 7; // already has spy revealer so go for thief, check if it already has thief revealer below..
			}
			else if (self.demon_two.classname == "building_camera")
				return; // CAMERAS doenst have a 4th frienly hack
		}
		if (inp == 2 && self.demon_two.all_active & #IMPROVED_SIX)
			return; // device completelly iced, so do nothing
		
		if (self.demon_two.all_active & itob(inp) && inp != 2) // exclude ICE's
			return; // device already has this hack done, so do nothing

		InitiateInterface(inp);
		ResetMenu();		
		self.impulse = 0;
	}

};

void(float inp) Menu_EnemyHax_Inp =
{
	if (self.classname != "player" || self.demon_two == world)
		return;
	
	if (inp == 10)
	{
		self.impulse=0;
		self.demon_two=world;
		BackFlash(self,1);
		sprint(self,#PRINT_LOW,"Leaving connection with device..\n");
		//CuTFMenuSound(#MENUSOUND_SELL);
		ResetMenu();
		return;
	}
	if (inp < 5 && inp > 0)
	{
		if (self.demon_two.is_malfunctioning & itob(inp))
			return;
		
		InitiateInterface(inp);
		ResetMenu();		
		self.impulse = 0;
	}

};

void () Menu_Enemy_Hax =
{
	if (self.demon_two == world) // safety
	{
		sprint(self,#PRINT_HIGH,"You have lost the connection!\n");
		ResetMenu();
		return;
	}

	local string st,st2,st3,st4,st5,st6,st7;

	st6="\n\nCom≠Link ÂÛÙ·‚ÏÈÛËÂ‰";
	st5="\n\n.. ŒÔÙËÈÓÁ                  ";
	st7=" ¡„ÙÈÔÓ:                    \n\n";

	if (!visible2x(self,self.demon_two)) st6="\n\nLost connection with target!\n";
	else 
	{
		local float dist;
		dist = vlen(self.origin - self.demon_two.origin);
		if (dist > #HAX_UNSTABLEDIST)
		{
			st6="\n\nUnstable connection with target!\n";
		}
	}

	if (!Teammate(self.demon_two.real_owner, self))
	{
		if (self.demon_two.classname == "building_dispenser")
		{
			st7="‘·ÚÁÂÙ: ≈ÓÂÌ˘ Dispenser\n\n";
			st=".. Disable           €3 sec›";
			st2="\n.. Booby trap        €6 sec›";
			st3="\n.. No production     €3 sec›";
			st4="\n.. Subtle bomb       €4 sec›";			  
		}
		else if (self.demon_two.classname == "building_sentrygun")
		{
			st7="‘·ÚÁÂÙ: ≈ÓÂÌ˘ Sentry Gun\n\n";
			st=".. Incapacitate      €3 sec›";
			st2="\n.. Reduce accuracy   €5 sec›";
			st3="\n.. RL malfunction    €4 sec›";
			st4="\n.. Hostile takeover €12 sec›";			  
		}
		else if (self.demon_two.classname == "building_tesla")
		{
			st7="‘·ÚÁÂÙ: ≈ÓÂÌ˘ Tesla Sentry\n\n";			 
			st=".. Incapacitate      €8 sec›";
			st2="\n.. Reduce output     €6 sec›";
			st3="\n.. Overload          €7 sec›";
			st4="\n.. Hostile takeover €15 sec›";
		}
		else if (self.demon_two.classname == "building_camera")
		{
			st7="‘·ÚÁÂÙ: ≈ÓÂÌ˘ Camera\n\n";
			st=".. Disable comms     €5 sec›";
			st2="\n.. Disable speaker   €2 sec›";
			st3="\n.. Sensor ghosts     €6 sec›";
			st4="\n.. Hostile takeover  €5 sec›";
		}
		else if (self.demon_two.classname == "building_sensor")
		{
			st7="‘·ÚÁÂÙ: ≈ÓÂÌ˘ Motion Sensor\n\n";
			st=".. Disable sound     €5 sec›";
			st2="\n.. Disable light     €5 sec›";
			st3="\n.. Deactivate        €5 sec›";
			st4="\n.. Hostile takeover  €5 sec›";
		}
		else if (self.demon_two.classname == "building_teleporter")
		{
			st7="‘·ÚÁÂÙ: ≈ÓÂÌ˘ Teleporter\n\n";
			st=".. Item stripper     €3 sec›";
			st2="\n.. Void location     €7 sec›";
			st3="\n.. Target builder    €5 sec›";
			st4="\n.. Disable           €2 sec›";
		}
		else if (self.demon_two.classname == "building_fieldgen")
		{
			st7="‘·ÚÁÂÙ: ≈ÓÂÌ˘ Field Generator\n\n";
			st=".. Corrupt Generator €3 sec›";
			st2="\n.. Engineer Trap     €7 sec›";
			st3="\n.. Reduce Output     €5 sec›";
			st4="\n.. Disable           €2 sec›";
		}

	}

	if (self.demon_two.is_malfunctioning & #SCREWUP_ONE)
	{
		st="";
	}
	if (self.demon_two.is_malfunctioning & #SCREWUP_TWO)
	{
		st2="\n";
	}
	if (self.demon_two.is_malfunctioning & #SCREWUP_THREE)
	{
		st3="\n";
	}
	if (self.demon_two.is_malfunctioning & #SCREWUP_FOUR)
	{
		st4="\n";
	}

	CenterPrint7(self,st7,st,st2,st3,st4,st5,st6);	 
};

/*
===============
SBFireInterface

Uses the Cyber Interface on whatever you're looking at.

OfN - Rewritten
===============
*/

void() SBFireInterface =
{
	if (CheckHaxxx() == #FALSE) return;
	
	local entity oself;
	local entity targ;
	local float hackThis;
	local float healed;

	targ = self.martyr_enemy;
	hackThis = self.has_camera;   
	
	oself = self;
	
	self = self.owner;
	
	oself.think = SUB_Remove;	
	oself.nextthink = 0.1;
	dremove(oself);
	
	self.is_haxxxoring = 0;

	self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
	TeamFortress_SetSpeed(self);

	if (hackThis == -2)
	{
		sprint(self, #PRINT_HIGH, "Hack aborted.\n");
		return;
	}

	if (targ.classname == "player" && (targ.cutf_items & #CUTF_CYBERAUG))
	{
		if (!Teammate(targ, self))
		{
			targ.is_malfunctioning = 1;
			sprint(targ, #PRINT_HIGH, "Oh no! Your cybernetic augmentations are malfunctioning!\n");
			sprint(self, #PRINT_HIGH, "You tamper with ", targ.netname, "'s cybernetic augmentations.\n");
		}
		else if (Teammate(targ, self) && targ.is_malfunctioning)
		{
			targ.is_malfunctioning = 0;
			sprint(targ, #PRINT_HIGH, self.netname, " adjusts your cybernetics to work properly again.\n");
			sprint(self, #PRINT_HIGH, "You readjust ", targ.netname, "'s CyberAugs to work properly again.\n");
		}
	}
	else if (IsBuilding(targ))
	{
		if (!Teammate(targ.real_owner, self) && GetICELevel(targ)==1 && random() < 0.2)
		{
			sprint(self, #PRINT_HIGH, "This device has a level 1 ICE, it's not easy to hack!\n");
			//sprint(targ.real_owner, #PRINT_HIGH,"Somebody tried to hack your stuff...\n");
			return;
		}
		if (!Teammate(targ.real_owner, self) && GetICELevel(targ)==2)
		{
			sprint(self, #PRINT_HIGH, "This device is hack-protected.\n");
			sprint(targ.real_owner, #PRINT_HIGH,"Somebody just tried to hack your stuff...\n");
			return;
		}
		if (!Teammate(targ.real_owner, self) && GetICELevel(targ)==3)
		{
			sprint(self, #PRINT_HIGH, "This device is hack-protected with a level 3 ICE!\n");
			deathmsg=#DMSG_ANTIHACK;
			TF_T_Damage(self, self, targ, self.health + 50, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
			
			sound (self, #CHAN_MISC, "effects/crunch.wav", 1, #ATTN_NONE);

			return;
		}
		
		MuzzleFlash(targ);
		sound(targ,#CHAN_MISC,"weapons/cambeep.wav",1, #ATTN_NORM);

		BackFlash(self,1);
		
		if (!Teammate(targ.real_owner, self))
		{
			sprint(self, #PRINT_HIGH, "You make a few adjustments...\n");
			if (hackThis == #SCREWUP_ONE)
			{
				targ.is_malfunctioning = targ.is_malfunctioning | #SCREWUP_ONE;
				if (targ.classname == "building_sentrygun") // 
					sprint(self, #PRINT_HIGH, "The sentrygun is now incapacitated.\n");
				else if (targ.classname == "building_tesla")
					sprint(self, #PRINT_HIGH, "The tesla won't shoot any more.\n");
				else if (targ.classname == "building_sensor")
					sprint(self, #PRINT_HIGH, "Better when it doesn't make so much noise.\n");
				else if (targ.classname == "building_dispenser")
					sprint(self, #PRINT_HIGH, "This is one dispenser that won't dispense any more.\n");
				else if (targ.classname == "building_camera")
					sprint(self, #PRINT_HIGH, "The camera won't be reporting to its owner any longer, but to all outward appearances remains the same.\n");
				else if (targ.classname == "building_teleporter")
					sprint(self, #PRINT_HIGH, "The teleporter will now strip the items off all who enter...\n");
				else if (targ.classname == "building_fieldgen")
					sprint(self, #PRINT_HIGH, "The field generator is now rigged to hurt teammates...\n");
			}
			else if (hackThis == #SCREWUP_TWO)
			{
				targ.is_malfunctioning = targ.is_malfunctioning | #SCREWUP_TWO;
				if (targ.classname == "building_sentrygun")
					sprint(self, #PRINT_HIGH, "The sentrygun's accuracy is now reduced.\n");
				else if (targ.classname == "building_tesla")
					sprint(self, #PRINT_HIGH, "This tesla won't put out enough amperage to hurt a fly.\n");
				else if (targ.classname == "building_camera")
					sprint(self, #PRINT_HIGH, "The camera is silenced.\n");
				else if (targ.classname == "building_sensor")
					sprint(self, #PRINT_HIGH, "That glow was always pretty annoying anyway.\n");
				else if (targ.classname == "building_dispenser")
				{
					sprint(self, #PRINT_HIGH, "The dispenser is now rigged to explode!\n");
					targ.martyr_enemy = self;
				}
				else if (targ.classname == "building_teleporter")
				{
					sprint(self, #PRINT_HIGH, "Entering this teleporter could be unhealthy...\n");
					targ.martyr_enemy = self;
				}
				else if (targ.classname == "building_fieldgen")
				{
					sprint(self, #PRINT_HIGH, "Better not use a spanner on this one...\n");
					//targ.martyr_enemy = self; // FIX: used on fieldgens to point to field
				}
			}
			else if (hackThis == #SCREWUP_THREE)
			{
				targ.is_malfunctioning = targ.is_malfunctioning | #SCREWUP_THREE;
				if (targ.classname == "building_sentrygun")
					sprint(self, #PRINT_HIGH, "The sentrygun rocket launcher will now malfunction...\n");
				else if (targ.classname == "building_tesla")
					sprint(self, #PRINT_HIGH, "The tesla may experience some technical difficulties the next time it fires...\n");
				else if (targ.classname == "building_camera")
					sprint(self, #PRINT_HIGH, "This camera will be reading ghosts now...\n");
				else if (targ.classname == "building_dispenser")
					sprint(self, #PRINT_HIGH, "The dispenser will no longer regenerate ammo.\n");
				else if (targ.classname == "building_teleporter")
					sprint(self, #PRINT_HIGH, "The teleporter will now teleport directly to its builder!\n");
				else if (targ.classname == "building_sensor")
					sprint(self, #PRINT_HIGH, "The sensor is now off.\n");
				else if (targ.classname == "building_fieldgen")
					sprint(self, #PRINT_HIGH, "The field generator won't hurt too much now.\n");
			}
			else if (hackThis == #SCREWUP_FOUR)
			{
				if (targ.classname != "building_dispenser" && targ.classname != "building_teleporter" && targ.classname != "building_fieldgen")
				{
					local string st;
					st=GetBuildingName(targ);

					sprint(targ.real_owner, #PRINT_HIGH,"You've lost the control of your ");
					sprint(targ.real_owner, #PRINT_HIGH, st);
					sprint(targ.real_owner, #PRINT_HIGH, "!!\n");

					sprint (self, #PRINT_HIGH, "The ");
					sprint (self, #PRINT_HIGH, st);
					sprint (self,#PRINT_HIGH," is now yours!\n");	

					teamprefixsprint(self.team_no,self);
					teamsprint6(self,self.netname," hacked ",targ.real_owner.netname,"'s ",st,", now it's ours!\n");

					teamprefixsprint(targ.real_owner.team_no,targ.real_owner);
					teamsprint6(targ.real_owner,targ.real_owner.netname," has lost the control of his ",st,"!\n","","");

					if (targ.classname == "building_sentrygun")
					{
						targ.real_owner.has_sentry = targ.real_owner.has_sentry - (targ.real_owner.has_sentry & targ.dont_do_triggerwork);
						targ.dont_do_triggerwork = 0;
						//self.has_sentry = #TRUE;
					}
					else if (targ.classname == "building_tesla")
					{
						targ.real_owner.has_tesla = targ.real_owner.has_tesla - (targ.real_owner.has_tesla & targ.dont_do_triggerwork);
						targ.dont_do_triggerwork = 0;

						//targ.real_owner.has_tesla = #FALSE;
						//self.has_tesla = #TRUE;
					}
					else if (targ.classname == "building_camera")
					{
						targ.real_owner.has_camera = #FALSE;
						//self.has_camera = #TRUE;
					}
					else if (targ.classname == "building_sensor")
					{
						targ.real_owner.has_sensor = #FALSE;
						//self.has_sensor = #TRUE;
					}

					targ.real_owner = self;
					targ.team_no = self.team_no;				
				}		 
				else if (targ.classname == "building_fieldgen")
				{
					sprint(self, #PRINT_HIGH, "The field generator is now disabled.\n");
					targ.is_malfunctioning = #SCREWUP_FOUR;
				}
				else if (targ.classname == "building_teleporter")
				{
					sprint(self, #PRINT_HIGH, "The teleporter is now broken.\n");
					targ.is_malfunctioning = #SCREWUP_FOUR;
				}
				else if (targ.classname == "building_dispenser")
				{
					sprint(self, #PRINT_HIGH, "The dispenser will explode when someone attempts to withdraw armour!\n");
					targ.martyr_enemy = self;
					targ.is_malfunctioning = #SCREWUP_FOUR;
				}
			}
			else
			{
				sprint(self, #PRINT_HIGH, "Your attempt at hacking fails.\n");
			}
		}
		else if (Teammate(targ, self) && hackThis == -1)
		{
			if (targ.is_malfunctioning)
			{
				targ.is_malfunctioning = 0;

				sprint(self, #PRINT_HIGH, "You correct the machine's malfunction.\n");
				
				local string st;
				st=GetBuildingName(targ);

				if (self!=targ.real_owner)
				{					 
					sprint(targ.real_owner, #PRINT_HIGH, "your ");
					sprint(targ.real_owner, #PRINT_HIGH, st);
					sprint(targ.real_owner, #PRINT_HIGH," has been fixed by ");
					sprint(targ.real_owner, #PRINT_HIGH, self.netname);
					sprint(targ.real_owner, #PRINT_HIGH, "\n");

					teamprefixsprintbi(self.team_no,self,targ.real_owner);
					teamsprintbi(self,targ.real_owner,targ.real_owner.netname,"'s malfunctioning ",st," has been fixed by ",self.netname,"\n");
				}
				else
				{
					teamprefixsprint(self.team_no,self);
					teamsprint6(self,self.netname, " fixes his malfuntioning ",st,"\n","","");
				}
			}
			else
			{
				//WK 1/15/08 Hack repair now actually repairs and recharges sentries and teslas
				if (targ.classname=="building_tesla") {
					self.building = targ;
					healed = Engineer_RepairTesla();
					if (healed > 0) 
						sprint(self, #PRINT_HIGH, "You repair and recharge the tesla.\n");
					else
						sprint(self, #PRINT_HIGH, "There is nothing wrong with this machine.\n");
				}
				else if (targ.classname=="building_sentrygun") {
					self.building = targ;
					healed = Engineer_RearmSentryGun();
					healed = healed + Engineer_RepairSentryGun();
					if (healed) 
						sprint(self, #PRINT_HIGH, "You repair and rearm the sentry gun.\n");
					else
						sprint(self, #PRINT_HIGH, "There is nothing wrong with this machine.\n");
				}
			}
		}
		else if (Teammate(targ, self))
		{
			//FRIENDLY IMPROVEMENTS
			targ.all_active = targ.all_active | hackThis;

			local string st;
			st=GetBuildingName(targ);

			sprint(self, #PRINT_HIGH, "You make a few adjustments...\n");
			
			if (hackThis == #IMPROVED_ONE)
			{
				if (targ.classname=="building_sensor")
				{
					sprint(self, #PRINT_HIGH, "The sensor has greater detection range now.\n");
					
					if (self != targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH,"your motion sensor has greater detection range thanks to ");
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, ".\n");
					}
				}
				else if (targ.classname=="building_camera")
				{
					sprint(self, #PRINT_HIGH, "The camera has greater range of view now.\n");
					
					if (self != targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH," hacked your camera, it has better sensors now.\n");
					}

				}
				else if (targ.classname=="building_tesla") 
				{
					targ.maxammo_cells=targ.maxammo_cells*2;
					sprint(self, #PRINT_HIGH, "The tesla has extra cells capacity now.\n");
					
					if (self != targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH," hacked your tesla, it has extra capacity for cells now.\n");
					}


				}
				else if (targ.classname=="building_sentrygun")
				{				 
					targ.maxammo_shells=targ.maxammo_shells*2;
					sprint(self, #PRINT_HIGH, "The sentry gun has greater ammo capacity for shells now.\n");
					
					if (self != targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH," hacked your sentry gun, it has extra capacity for shells now.\n");
					}

				}
				else if (targ.classname=="building_dispenser")
				{				 
					sprint(self, #PRINT_HIGH, "The dispenser capacity was increased.\n");
					
					if (self != targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH," hacked your dispenser to increase its capacity.\n");
					}

				}
				else if (targ.classname=="building_teleporter")
				{				 
					targ.maxammo_cells=targ.maxammo_cells*2;

					sprint(self, #PRINT_HIGH, "The teleporter cells capacity was increased.\n");
					
					if (self != targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH," hacked your teleporter to increase its cells capacity.\n");
					}

				}
				else if (targ.classname=="building_fieldgen")
				{				 
					targ.maxammo_cells=targ.maxammo_cells*2;

					sprint(self, #PRINT_HIGH, "The field generator cells capacity was increased.\n");
					
					if (self != targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH," hacked your field generator to increase its cells capacity.\n");
					}

				}


			}
			else if (hackThis == #IMPROVED_TWO) //- ICE level 1
			{
				sprint(self, #PRINT_HIGH, "You add a ÏÂˆÂÏ  ICE to the ");
				sprint(self, #PRINT_HIGH, st);
				sprint(self, #PRINT_HIGH,".\n");

				if (self!=targ.real_owner)
				{
					sprint(targ.real_owner, #PRINT_HIGH, self.netname);
					sprint(targ.real_owner, #PRINT_HIGH," adds a ÏÂˆÂÏ  ICE to your ");
					sprint(targ.real_owner, #PRINT_HIGH, st);
					sprint(targ.real_owner, #PRINT_HIGH, ".\n");
				}

			}
			else if (hackThis == #IMPROVED_FIVE) //- ICE level 2
			{
				sprint(self, #PRINT_HIGH, "You add a ÏÂˆÂÏ  ICE to the ");
				sprint(self, #PRINT_HIGH, st);
				sprint(self, #PRINT_HIGH,".\n");

				if (self!=targ.real_owner)
				{
					sprint(targ.real_owner, #PRINT_HIGH, self.netname);
					sprint(targ.real_owner, #PRINT_HIGH," adds a ÏÂˆÂÏ  ICE to your ");
					sprint(targ.real_owner, #PRINT_HIGH, st);
					sprint(targ.real_owner, #PRINT_HIGH, ".\n");
				}

			}
			else if (hackThis == #IMPROVED_SIX) //- ICE level 3
			{
				sprint(self, #PRINT_HIGH, "You add a ÏÂˆÂÏ  ICE to the ");
				sprint(self, #PRINT_HIGH, st);
				sprint(self, #PRINT_HIGH,".\n");

				if (self!=targ.real_owner)
				{
					sprint(targ.real_owner, #PRINT_HIGH, self.netname);
					sprint(targ.real_owner, #PRINT_HIGH," adds a ÏÂˆÂÏ  ICE to your ");
					sprint(targ.real_owner, #PRINT_HIGH, st);
					sprint(targ.real_owner, #PRINT_HIGH, ".\n");
				}

			}
			else if (hackThis == #IMPROVED_THREE)
			{
				sprint(self, #PRINT_HIGH, "You enhance the armour of the ");
				sprint(self, #PRINT_HIGH, st);
				sprint(self, #PRINT_HIGH,".\n");
					
				if (self!=targ.real_owner)
				{
					sprint(targ.real_owner, #PRINT_HIGH, self.netname);
					sprint(targ.real_owner, #PRINT_HIGH," enhances the armour of your ");
					sprint(targ.real_owner, #PRINT_HIGH, st);
					sprint(targ.real_owner, #PRINT_HIGH, ".\n");
				}
				
				local float num;				
				
				num=targ.health/targ.max_health;
				targ.max_health=floor(targ.max_health*1.5); //WK 1-7-7 Toned down hacking, 2
				targ.health=num*targ.max_health;
				
			}
			else if (hackThis == #IMPROVED_SEVEN)
			{
				if (targ.classname=="building_sensor")
				{
					sprint(self, #PRINT_HIGH, "The sensor will be able to uncover thieves now.\n");
					
					if (self!=targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, "your motion sensor can now uncover thieves after ");
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, "'s hack.\n");
					}
				}
			}
			else if (hackThis == #IMPROVED_FOUR)
			{
				if (targ.classname=="building_dispenser")
				{
					sprint(self, #PRINT_HIGH, "The dispenser has been upgraded.\n");
					
					if (self!=targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, "your dispenser has been upgraded by ");
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, "\n");
					}
				}
				else if (targ.classname=="building_sensor")
				{
					sprint(self, #PRINT_HIGH, "The sensor will be able to uncover spies now.\n");
					
					if (self!=targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, "your motion sensor can now detect spies after ");
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, "'s hack.\n");
					}
				}
				else if (targ.classname=="building_teleporter")
				{
					sprint(self, #PRINT_HIGH, "The teleporter had its range increased.\n");
					
					if (self!=targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, "your teleporter had its range increased by ");
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, "'s hack.\n");
					}
				}
				else if (targ.classname=="building_fieldgen")
				{
					sprint(self, #PRINT_HIGH, "The field generator had its range increased.\n");
					
					if (self!=targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, "your field generator had its range increased by ");
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, "'s hack.\n");
					}
				}
				else if (targ.classname=="building_tesla")
				{
					sprint(self, #PRINT_HIGH, "The tesla has a better chip-set now.\n");
					
					if (self!=targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, " enhances your tesla main circuits.\n");
					}
				}
				else if (targ.classname=="building_sentrygun")
				{
					sprint(self, #PRINT_HIGH, "The sentry gun has a better chip-set now.\n");
					
					if (self!=targ.real_owner)
					{
						sprint(targ.real_owner, #PRINT_HIGH, self.netname);
						sprint(targ.real_owner, #PRINT_HIGH, " enhances your sentry gun main circuits.\n");
					}
				}
			}
			else
			{
				sprint(self, #PRINT_HIGH, "BUG!: unknown hack value BUG! (wtf u hacked)\n");
				RPrint(self.netname);
				RPrint(" just made an unknown hack. (bug)\n");
			}
		}
	}
	
	//else
	//	sprint(self, #PRINT_HIGH, "There is nothing there to hack!\n");
};

float(entity hacked, float r) ReturnFHackDelay;

// SB hax0r tool - Cyber Interface
// OfN - Rewritten
void(float input) InitiateInterface =
{
	local entity te;

	if (!visible2x(self,self.demon_two))
	{
		sprint(self, #PRINT_HIGH, "You are not connected to the target.\n");
		self.demon_two=world;
		return;
	}

	// DOUBLE CHECK, THIS ONE AFTER MENU, THE OTHER ON JOB_HACKER //
	if (self.is_feigning)
	{
		sprint(self, #PRINT_HIGH, "You cannot hack while feigning.\n");
		return;
	}
	if (self.is_detpacking || self.is_toffingadet)
	{
		sprint(self, #PRINT_HIGH, "You can't hack something while setting a detpack.\n");
		return;
	}
	if (self.is_building)
	{
		sprint(self, #PRINT_HIGH, "You can't hack while building!\n");
		return;
	}
	// DOUBLE CHECK, THIS ONE AFTER MENU, THE OTHER ON JOB_HACKER //

	self.is_haxxxoring = 1;
	
	te = spawn();
	te.owner = self;
	te.classname = "timer";
	te.origin = self.demon_two.origin;
	te.nextthink = time + 1;
	
	te.has_holo = self.demon_two.team_no; // checked on think to break hacking if changes of team
	
	te.has_camera = itob(input);
	
	if (!Teammate(self.demon_two, self))
	{			 
		te.heat = ReturnHackDelay(self.demon_two, input);
		
		if (GetICELevel(self.demon_two)==1) // if it has a level1 ice add more delay to the hack
			te.heat=te.heat*2.5;

		local string st;
		st=GetBuildingName(self.demon_two);

		teamprefixsprint(self.team_no,self);
		teamsprint6(self,self.netname," started to hack ",self.demon_two.real_owner.netname,"'s ",st,"\n");

		local float dist;
		dist = vlen(self.origin - self.demon_two.origin);
		if (dist > #HAX_UNSTABLEDIST)
		{
			sprint(self,#PRINT_HIGH,"Connection unstable, it will take longer...");
			te.heat=te.heat*2;
		}
	}
	else
	{	 
		te.heat = ReturnFHackDelay(self.demon_two, input);
		if (input==2 && self.demon_two.all_active & #IMPROVED_TWO)
		{
			te.has_camera=#IMPROVED_FIVE;
			if (self.demon_two.all_active & #IMPROVED_FIVE)
				te.has_camera=#IMPROVED_SIX;
		}

		if (input==8) te.has_camera=-1;
	}

	
	te.martyr_enemy = self.demon_two;
	te.think = SBHackDotTimerThink;
	
	self.tfstate = self.tfstate | #TFSTATE_CANT_MOVE;
	TeamFortress_SetSpeed(self);
	
	if (te.has_camera==-1)
		sprint (self, #PRINT_HIGH, "Scanning device for enemy modifications or damage...\n");
	else
		sprint (self, #PRINT_HIGH, "You immerse yourself in the cybernet...\n");

	sound(self.demon_two,#CHAN_MISC,"weapons/cambeep.wav",1, #ATTN_NORM);
	
	makeImmune(self,time + te.heat); //- OfN - WORKS? yup

	te.ltime = te.heat;
	self.demon_two=te;
};

float (entity hacked) GetICELevel =
{
	local float retval;
	retval=0;

	if (hacked.all_active & #IMPROVED_TWO)
		retval=1;
	if (hacked.all_active & #IMPROVED_FIVE)
		retval=2;
	if (hacked.all_active & #IMPROVED_SIX)
		retval=3;
	
	return retval;
	
};

float(entity hacked, float r) ReturnHackDelay =
{
	if (hacked.classname == "player")
		return 5; // cyberaug hack
	else if (hacked.classname == "building_dispenser")
	{
		if (r == 1)
			return 3;
		else if (r == 2)
			return 6;
		else if (r == 3)
			return 3;
		else
			return 4;
	}
	else if (hacked.classname == "building_sentrygun")
	{
		if (r == 1)
			return 3;
		else if (r == 2)
			return 5;
		else if (r == 3)
			return 4;
		else
			return 12;
	}
	else if (hacked.classname == "building_tesla")
	{
		if (r == 1)
			return 8;
		else if (r == 2)
			return 6;
		else if (r == 3)
			return 7;
		else
			return 15;
	}
	else if (hacked.classname == "building_sensor")
		return 5;
	else if (hacked.classname == "building_camera")
	{
		if (r == 1)
			return 5;
		else if (r == 2)
			return 2;
		else if (r == 3)
			return 6;
		else
			return 5;
	}
	else if (hacked.classname == "building_teleporter")
	{
		if (r == 1)
			return 3;
		else if (r == 2)
			return 7;
		else if (r == 3)
			return 5;
		else
			return 2;
	}
	else if (hacked.classname == "building_fieldgen")
	{
		if (r == 1)
			return 3;
		else if (r == 2)
			return 7;
		else if (r == 3)
			return 5;
		else
			return 2;
	}
};

float(entity hacked, float r) ReturnFHackDelay =
{
	if (hacked.classname == "player")
		return 5; // cyberaug hack
	else if (r == 8) return 10; // repairing.. //WK 1/15/08 Was 8 seconds, now 10
	else if (r == 2 && IsBuilding(hacked))
	{
		if (!hacked.all_active & #IMPROVED_TWO)
			return 20; // level 1 ICE lasts for 20 seconds always
		if (!hacked.all_active & #IMPROVED_FIVE)
			return 25; // level 2 ICE lasts for 25 seconds always
		if (!hacked.all_active & #IMPROVED_SIX)
			return 30;	  
	}
	else if (hacked.classname == "building_dispenser")
	{
		if (r == 1)
			return 15;
//		else if (r == 2)
//			return 30;
		else if (r == 3)
			return 10;
		else
			return 30;
	}
	else if (hacked.classname == "building_sentrygun")
	{
		if (r == 1)
			return 10;
//		else if (r == 2)
//			return 30;
		else if (r == 3)
			return 25;
		else
			return 30;
	}
	else if (hacked.classname == "building_tesla")
	{
		if (r == 1)
			return 10;
//		else if (r == 2)
//			return 30;
		else if (r == 3)
			return 25;
		else
			return 30;
	}
	else if (hacked.classname == "building_sensor")
	{
		if (r == 1)
			return 20;
//		else if (r == 2)
//			return 30;
		else if (r == 3)
			return 10;
		else //if (r == 4)
			return 25;
		//else
		//	  return 8;
	}
	else if (hacked.classname == "building_camera")
	{
		if (r == 1)
			return 20;
//		else if (r == 2)
//			return 30;
		else // if (r == 3)
			return 20;
		//else
		//	return 8;
	}
	else if (hacked.classname == "building_teleporter")
	{
		if (r == 1)
			return 5;
//		else if (r == 2)
//			return 30;
		else if (r == 3)
			return 20;
		else// if (r == 4)
			return 30;
		//else
		//	  return 8;
		
	}
	else if (hacked.classname == "building_fieldgen")
	{
		if (r == 1)
			return 10;
//		else if (r == 2)
//			return 30;
		else if (r == 3)
			return 15;
		else// if (r == 4)
			return 20;
		//else
		//	  return 8;
		
	}

	return 999; // hehe, punishment to the bug generator :)
};

float() CheckHaxxx =
{
	local float retval;
	retval = #TRUE;
		
	if (self.martyr_enemy == world) // BUG!
		retval = #FALSE;
	else if (!(IsBuilding(self.martyr_enemy))) // BUG! 2
		retval = #FALSE;
	else if (self.martyr_enemy.health <= 0)
	{
		sprint (self.owner, #PRINT_HIGH, "Your target has been destroyed!\n");
		
		if (self.has_camera != -2)
		{
			deathmsg=#DMSG_CYBERNET;
			TF_T_Damage(self.owner, self.owner, self.martyr_enemy, self.owner.health + 10, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
			sound (self.owner, #CHAN_MISC, "effects/crunch.wav", 1, #ATTN_NONE);
		}

		retval = #FALSE;
	}
	else if (self.martyr_enemy.team_no != self.has_holo) // target switched team? if so.. abort
	{
		sprint (self.owner, #PRINT_HIGH, "The communication has been lost!\n");
		retval = #FALSE;
	}
	else if (self.has_camera == -2)
	{
		retval = #TRUE;
	}
	else if (Teammate(self.martyr_enemy, self.owner) && self.martyr_enemy.all_active & self.has_camera && self.has_camera != -1)
	{
		sprint (self.owner, #PRINT_HIGH, "Somebody improved that first.\n");
		retval = #FALSE;
	}
	else if (!Teammate(self.martyr_enemy, self.owner) && self.martyr_enemy.is_malfunctioning & self.has_camera)
	{
		sprint (self.owner, #PRINT_HIGH, "Somebody screwed that up first! heh\n");
		retval = #FALSE;
	}

	if (!retval)
	{
		self.owner.is_haxxxoring = 0;
		self.owner.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
		TeamFortress_SetSpeed(self.owner);
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
		dremove(self);
	}

	return retval;
};

void() SBHackDotTimerThink =
{
	if (CheckHaxxx() == #FALSE) return;

	local vector org;	 
  
	if (random() < 0.4) //-ofn was 0.3
	{
		org = self.martyr_enemy.origin;
		if (self.martyr_enemy.classname == "building_tesla" && self.martyr_enemy.tf_items & #NIT_TURRET)
			org_z = org_z - 7; // - 32;
		else if (self.martyr_enemy.classname == "building_tesla")
			org_z = org_z + 7; // + 32;
		else if (self.martyr_enemy.classname == "building_sentrygun" && self.martyr_enemy.tf_items & #NIT_TURRET)
			org_z = org_z - 16;
		else if (self.martyr_enemy.classname == "building_sentrygun")
			org_z = org_z + 16;
		else if (self.martyr_enemy.classname == "building_dispenser")
			org_z = org_z + 16;
		else if (self.martyr_enemy.classname == "building_fieldgen")
			org_z = org_z + 32;

		if (random() < 0.20)
		{
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
			WriteByte (#MSG_MULTICAST, 4); // Original 3
						
			WriteCoord (#MSG_BROADCAST, org_x);
			WriteCoord (#MSG_BROADCAST, org_y);
			WriteCoord (#MSG_BROADCAST, org_z);
			multicast (org, #MULTICAST_PVS);
			MuzzleFlash(self.martyr_enemy);
		}
		else
		{		 
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
			WriteByte (#MSG_MULTICAST, 3); // Original 3
			
			WriteCoord (#MSG_BROADCAST, org_x);
			WriteCoord (#MSG_BROADCAST, org_y);
			WriteCoord (#MSG_BROADCAST, org_z);
			multicast (org, #MULTICAST_PVS);
		}
					
	}
	
	self.heat = self.heat - 1;
	
	if (self.heat <= 0)
	{
		SBFireInterface();
		return;
	}
	
	self.nextthink = time + 1;
};

void() JobHacker =
{
	local vector source;
	
	self.job_finished = time + #HACKER_ATTEMPTRATE;

	if (self.is_haxxxoring)
	{		
		if (self.demon_two.has_camera == -2) return; // if we ralready aborting a hack...
		sprint(self, #PRINT_HIGH, "Aborting hack...\n");
		self.demon_two.heat = 1 + 2 * random();
		self.demon_two.has_camera = -2;
		return;
	}
	if (self.is_feigning)
	{
		sprint(self, #PRINT_HIGH, "You cannot hack while feigning.\n");
		return;
	}
	if (self.is_detpacking || self.is_toffingadet)
	{
		sprint(self, #PRINT_HIGH, "You can't hack something while setting a detpack.\n");
		return;
	}
	if (self.is_building)
	{
		sprint(self, #PRINT_HIGH, "You can't hack while building!\n");
		return;
	}	 

	source = self.origin + '0 0 16';

	traceline (source, source + v_forward*500, #TL_ANY_SOLID, self);
	
	if ( (IsBuilding(trace_ent) && trace_ent.classname != "building_sentrygun_base") || trace_ent.classname == "player")
	{
		if (!Teammate(trace_ent, self))
		{
			if (trace_ent.is_malfunctioning == #SCREWUP_ONE + #SCREWUP_TWO + #SCREWUP_THREE + #SCREWUP_FOUR)
			{
				sprint(self, #PRINT_HIGH, "You couldn't possibly screw that up more than it already is.\n");
				return;
			}
			else if (IsBuilding(trace_ent) && trace_ent.classname != "building_sentrygun_base")
			{
				self.current_menu = #MENU_E_HACK;
				self.menu_count = #MENU_REFRESH_RATE;
			}				
		}
		else if (IsBuilding(trace_ent) && trace_ent.classname != "building_sentrygun_base")
		{
			self.current_menu = #MENU_F_HACK;
			self.menu_count = #MENU_REFRESH_RATE;
		}


		self.demon_two = trace_ent;

		if (trace_ent.classname=="player")
		{
			if (!(trace_ent.cutf_items & #CUTF_CYBERAUG))
			{
				sprint(self, #PRINT_HIGH, "You can't hack him.\n");
				ResetMenu();
				self.demon_two=world;
				return;
			}
		
			sprint (self, #PRINT_HIGH, "\nScanning for cyberaug equipment...\n");
			InitiateInterface(0);
			ResetMenu();
		}
		else
		{
			sprint (self, #PRINT_HIGH, "\nEstablishing connection...\n");
			
			local string st;

			st=GetBuildingName(self.demon_two);
			
			sprint (self, #PRINT_HIGH, "Target Ù˘Â: ");
			sprint (self, #PRINT_HIGH, st);
			sprint (self, #PRINT_HIGH, "\nTarget Ô˜ÓÂÚ: "); 	   
			sprint (self, #PRINT_HIGH, self.demon_two.real_owner.netname);
			
			if (Teammate(self, self.demon_two))
				sprint (self, #PRINT_HIGH, "\nFriendly device.\n");
			else
				sprint (self, #PRINT_HIGH, "\n≈ÓÂÌ˘ device!\n");

			// Create Lightning Signal
			msg_entity = self;
			WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
			WriteByte (#MSG_ONE, #TE_LIGHTNING2);
			WriteEntity (#MSG_ONE, self);
			WriteCoord (#MSG_ONE, self.origin_x);
			WriteCoord (#MSG_ONE, self.origin_y);
			WriteCoord (#MSG_ONE, self.origin_z);
			WriteCoord (#MSG_ONE, self.demon_two.origin_x);
			WriteCoord (#MSG_ONE, self.demon_two.origin_y);
			WriteCoord (#MSG_ONE, self.demon_two.origin_z);
			
			// flash machine - Nah..
			/*WriteByte (#MSG_MULTICAST, #SVC_MUZZLEFLASH);
			WriteEntity (#MSG_MULTICAST, self.demon_two);
			multicast (self.demon_two.origin, #MULTICAST_PVS);*/

			stuffcmd(self,"playvol misc/ffact.wav 0.4\n");

			BackFlash(self,1);
		}
	}
	else
	{
		sprint (self, #PRINT_HIGH, "There is nothing there to hack!\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		return;
	}
	
};

