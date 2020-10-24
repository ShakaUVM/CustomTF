/*=======================================================//
// prozac.QC - CustomTF 3.2.OfN 		  - 15/11/2004 - //
// by Sergio Fumaña Grunwaldt - OfteN [cp]				 //
=========================================================//
 ProZac Message Of The Day (MOTD) and un/related stuff :)
=========================================================*/

#define MSG_OFTEN_CUTFVERSION "Running progs build 272 Û02¯02¯2009İ\n"

#define MSG_INFO "\nType ¢cmd help¢ to see additional client commands.\n"

#define MSG_CUTFVERSION   "ĞÒÏÚÁÃ CustomÔÆ VERSION 02-02-09" //WK Version Number

#define MSG_INTRO  "Welcome to ĞÒÏÚÁÃ CustomÔÆ\na Quake ÔÆ MOD by ShakaUVM\nwww®customtf®com\n\nŸ\n\n"
#define MSG_INTRO2 "Based on the aussie ver by SB-1\nModified version by Clan Prozac\n\n" // Ÿ\n\n
#define MSG_INTRO3 "Post bug reports and comments on:\nhttp:¯¯customtf®sourceforge®net¯forum¯"

//WK 152 Default, must be > 6.
#define MOTD_FINISHED 152 //WK 1/7/7 420 //242		//Delay in 1/10th seconds for motd to show

void() PrintProzacMOTD =
{
	local string st;   

	st = "Ÿ Celebrating *10* years!! Ÿ\n\n";
	
	if ((self.#cprint_fx & 3) == 3)
		st = colstr(st,#COLSTR_MIX1);
	else if (self.#cprint_fx & 2)
		st = colstr(st,#COLSTR_RED);
	else if (self.#cprint_fx & 1)
		st = colstr(st,#COLSTR_MIX2);
	
	CenterPrint4(self,#MSG_INTRO,#MSG_INTRO2,st,#MSG_INTRO3);

	self.#cprint_fx = self.#cprint_fx + 1;
};

void() PrintProzacIntro =
{
	if (!no_votemap && !no_punish)
		sprint(self,#PRINT_HIGH,"\nVoting You can issue a vote by using the ¢VoteMap¢ and ¢Punish¢ aliases.\n");
	else
	{
		if (!no_punish)
			sprint(self,#PRINT_HIGH,"\nVoting You can issue a vote by using ¢VoteMap¢ alias.\n");
		else if (!no_votemap)
			sprint(self,#PRINT_HIGH,"\nVoting You can issue a vote by using ¢Punish¢ alias.\n");
	}

	//sprint (self, #PRINT_HIGH, #MSG_INFO, "\n",#MSG_OFTEN_CUTFVERSION, "\nŸ ", #MSG_CUTFVERSION, " Ÿ\n       Éîæïòíáôéïî èïíåğáçå:\n     www®telefragged®com¯shaka\nŸ\n\n");
	sprint (self, #PRINT_HIGH, #MSG_INFO, "\n",#MSG_OFTEN_CUTFVERSION, "\nŸ ", #MSG_CUTFVERSION, " Ÿ\n       Éîæïòíáôéïî èïíåğáçå:\n  http:¯¯www®customtf®org¯forums\nŸ\n\n");

	// PZ - Attackers Go Red mode
	if (agr) { AGR_introducePlayer(); sprint(self, #PRINT_HIGH, "\n"); }

	// for Neo mode
	if (neo) { Neo_introducePlayer(); sprint(self, #PRINT_HIGH, "\n"); }
};
