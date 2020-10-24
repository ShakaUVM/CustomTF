/*==============================================
	SPY.QC

TeamFortress v2.5	 29/2/97
========================================================
Functions for the SPY class and associated weaponry 						 
========================================================*/
void() TeamFortress_SpyGoUndercover;
void(float type) TeamFortress_SpyFeignDeath;
void(entity spy) TeamFortress_SpyCalcName;
void() TeamFortress_SpyUndercoverThink;
void(float class) TeamFortress_SpyChangeSkin;
void(float teamno) TeamFortress_SpyChangeColor;
void() GasGrenadeMakeGas;
void() HallucinationTimer;
void() W_FireTranq;
void() T_TranqDartTouch;
void() TranquiliserTimer;
void() TranquiliserTimer2; //CH for demons
void(entity spy) Spy_RemoveDisguise;

// Spy Feign Death Handling
$cd /raid/quake/id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6
$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6
$frame stand1 stand2 stand3 stand4 stand5
$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6
$frame pain1 pain2 pain3 pain4 pain5 pain6
$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9
$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11
$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15
$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9
$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

/*
$frame nailatt1 nailatt2
$frame light1 light2
$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6
$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6
$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6
$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6
$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6
$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6
*/

// Spy Feign Death Frames
void()	spy_diea1	=	[	$deatha1,	spy_diea2	] {};
void()	spy_diea2	=	[	$deatha2,	spy_diea3	] {};
void()	spy_diea3	=	[	$deatha3,	spy_diea4	] {};
void()	spy_diea4	=	[	$deatha4,	spy_diea5	] {};
void()	spy_diea5	=	[	$deatha5,	spy_diea6	] {};
void()	spy_diea6	=	[	$deatha6,	spy_diea7	] {};
void()	spy_diea7	=	[	$deatha7,	spy_diea8	] {};
void()	spy_diea8	=	[	$deatha8,	spy_diea9	] {};
void()	spy_diea9	=	[	$deatha9,	spy_diea10	] {};
void()	spy_diea10	=	[	$deatha10,	spy_diea11	] {};
void()	spy_diea11	=	[	$deatha11,	spy_diea11	] {};

void()	spy_dieb1	=	[	$deathb1,	spy_dieb2	] {};
void()	spy_dieb2	=	[	$deathb2,	spy_dieb3	] {};
void()	spy_dieb3	=	[	$deathb3,	spy_dieb4	] {};
void()	spy_dieb4	=	[	$deathb4,	spy_dieb5	] {};
void()	spy_dieb5	=	[	$deathb5,	spy_dieb6	] {};
void()	spy_dieb6	=	[	$deathb6,	spy_dieb7	] {};
void()	spy_dieb7	=	[	$deathb7,	spy_dieb8	] {};
void()	spy_dieb8	=	[	$deathb8,	spy_dieb9	] {};
void()	spy_dieb9	=	[	$deathb9,	spy_dieb9	] {};

void()	spy_diec1	=	[	$deathc1,	spy_diec2	] {};
void()	spy_diec2	=	[	$deathc2,	spy_diec3	] {};
void()	spy_diec3	=	[	$deathc3,	spy_diec4	] {};
void()	spy_diec4	=	[	$deathc4,	spy_diec5	] {};
void()	spy_diec5	=	[	$deathc5,	spy_diec6	] {};
void()	spy_diec6	=	[	$deathc6,	spy_diec7	] {};
void()	spy_diec7	=	[	$deathc7,	spy_diec8	] {};
void()	spy_diec8	=	[	$deathc8,	spy_diec9	] {};
void()	spy_diec9	=	[	$deathc9,	spy_diec10	] {};
void()	spy_diec10	=	[	$deathc10,	spy_diec11	] {};
void()	spy_diec11	=	[	$deathc11,	spy_diec12	] {};
void()	spy_diec12	=	[	$deathc12,	spy_diec13	] {};
void()	spy_diec13	=	[	$deathc13,	spy_diec14	] {};
void()	spy_diec14	=	[	$deathc14,	spy_diec15	] {};
void()	spy_diec15	=	[	$deathc15,	spy_diec15	] {};

void()	spy_died1	=	[	$deathd1,	spy_died2	] {};
void()	spy_died2	=	[	$deathd2,	spy_died3	] {};
void()	spy_died3	=	[	$deathd3,	spy_died4	] {};
void()	spy_died4	=	[	$deathd4,	spy_died5	] {};
void()	spy_died5	=	[	$deathd5,	spy_died6	] {};
void()	spy_died6	=	[	$deathd6,	spy_died7	] {};
void()	spy_died7	=	[	$deathd7,	spy_died8	] {};
void()	spy_died8	=	[	$deathd8,	spy_died9	] {};
void()	spy_died9	=	[	$deathd9,	spy_died9	] {};

void()	spy_diee1	=	[	$deathe1,	spy_diee2	] {};
void()	spy_diee2	=	[	$deathe2,	spy_diee3	] {};
void()	spy_diee3	=	[	$deathe3,	spy_diee4	] {};
void()	spy_diee4	=	[	$deathe4,	spy_diee5	] {};
void()	spy_diee5	=	[	$deathe5,	spy_diee6	] {};
void()	spy_diee6	=	[	$deathe6,	spy_diee7	] {};
void()	spy_diee7	=	[	$deathe7,	spy_diee8	] {};
void()	spy_diee8	=	[	$deathe8,	spy_diee9	] {};
void()	spy_diee9	=	[	$deathe9,	spy_diee9	] {};

void()	spy_die_ax1 =	[	$axdeth1,	spy_die_ax2 ] {};
void()	spy_die_ax2 =	[	$axdeth2,	spy_die_ax3 ] {};
void()	spy_die_ax3 =	[	$axdeth3,	spy_die_ax4 ] {};
void()	spy_die_ax4 =	[	$axdeth4,	spy_die_ax5 ] {};
void()	spy_die_ax5 =	[	$axdeth5,	spy_die_ax6 ] {};
void()	spy_die_ax6 =	[	$axdeth6,	spy_die_ax7 ] {};
void()	spy_die_ax7 =	[	$axdeth7,	spy_die_ax8 ] {};
void()	spy_die_ax8 =	[	$axdeth8,	spy_die_ax9 ] {};
void()	spy_die_ax9 =	[	$axdeth9,	spy_die_ax9 ] {};

// Spy Feign Death... getting up Frames
void()	spy_upb1	=	[	$deathb9,	spy_upb2	] {};
void()	spy_upb2	=	[	$deathb8,	spy_upb3	] {};
void()	spy_upb3	=	[	$deathb7,	spy_upb4	] {};
void()	spy_upb4	=	[	$deathb6,	spy_upb5	] {};
void()	spy_upb5	=	[	$deathb5,	spy_upb6	] {};
void()	spy_upb6	=	[	$deathb4,	spy_upb7	] {};
void()	spy_upb7	=	[	$deathb3,	spy_upb8	] {};
void()	spy_upb8	=	[	$deathb2,	spy_upb9	] {};
void()	spy_upb9	=	[	$deathb1,	spy_upb9	] 
{
	player_stand1();
};

void()	spy_upc1	=	[	$deathc15,	spy_upc2	] {};
void()	spy_upc2	=	[	$deathc14,	spy_upc3	] {};
void()	spy_upc3	=	[	$deathc13,	spy_upc4	] {};
void()	spy_upc4	=	[	$deathc12,	spy_upc5	] {};
void()	spy_upc5	=	[	$deathc11,	spy_upc6	] {};
void()	spy_upc6	=	[	$deathc10,	spy_upc7	] {};
void()	spy_upc7	=	[	$deathc9,	spy_upc8	] {};
void()	spy_upc8	=	[	$deathc8,	spy_upc9	] {};
void()	spy_upc9	=	[	$deathc7,	spy_upc10	] {};
void()	spy_upc10	=	[	$deathc6,	spy_upc11	] {};
void()	spy_upc11	=	[	$deathc5,	spy_upc12	] {};
void()	spy_upc12	=	[	$deathc4,	spy_upc13	] {};
void()	spy_upc13	=	[	$deathc3,	spy_upc14	] {};
void()	spy_upc14	=	[	$deathc2,	spy_upc15	] {};
void()	spy_upc15	=	[	$deathc1,	spy_upc15  ] 
{
	player_stand1();
};

void()	spy_upd1	=	[	$deathd9,	spy_upd2	] {};
void()	spy_upd2	=	[	$deathd8,	spy_upd3	] {};
void()	spy_upd3	=	[	$deathd7,	spy_upd4	] {};
void()	spy_upd4	=	[	$deathd6,	spy_upd5	] {};
void()	spy_upd5	=	[	$deathd5,	spy_upd6	] {};
void()	spy_upd6	=	[	$deathd4,	spy_upd7	] {};
void()	spy_upd7	=	[	$deathd3,	spy_upd8	] {};
void()	spy_upd8	=	[	$deathd2,	spy_upd9	] {};
void()	spy_upd9	=	[	$deathd1,	spy_upd9	] 
{
	player_stand1();
};

void()	spy_upe1	=	[	$deathe1,	spy_upe9	] {};
void()	spy_upe2	=	[	$deathe2,	spy_upe8	] {};
void()	spy_upe3	=	[	$deathe3,	spy_upe7	] {};
void()	spy_upe4	=	[	$deathe4,	spy_upe6	] {};
void()	spy_upe5	=	[	$deathe5,	spy_upe5	] {};
void()	spy_upe6	=	[	$deathe6,	spy_upe4	] {};
void()	spy_upe7	=	[	$deathe7,	spy_upe3	] {};
void()	spy_upe8	=	[	$deathe8,	spy_upe2	] {};
void()	spy_upe9	=	[	$deathe9,	spy_upe1	] 
{
	player_stand1();
};

void()	spy_upaxe1	  = [	$axdeth9,	spy_upaxe2	  ] {};
void()	spy_upaxe2	  = [	$axdeth8,	spy_upaxe3	  ] {};
void()	spy_upaxe3	  = [	$axdeth7,	spy_upaxe4	  ] {};
void()	spy_upaxe4	  = [	$axdeth6,	spy_upaxe5	  ] {};
void()	spy_upaxe5	  = [	$axdeth5,	spy_upaxe6	  ] {};
void()	spy_upaxe6	  = [	$axdeth4,	spy_upaxe7	  ] {};
void()	spy_upaxe7	  = [	$axdeth3,	spy_upaxe8	  ] {};
void()	spy_upaxe8	  = [	$axdeth2,	spy_upaxe9	  ] {};
void()	spy_upaxe9	  = [	$axdeth1,	spy_upaxe9	  ] 
{
	player_stand1();
};

//=========================================================================
// Function handling the Spy's feign death ability
void(float type) TeamFortress_SpyFeignDeath =
{
	local float i;
	local entity at_spot;

	if (self.is_feigning)
	{
		// Check to make sure there isn't anyone on top of us
		at_spot = findradius(self.origin, 64);
		i = #TRUE;

		while (at_spot != world)
		{
			if (at_spot.classname == "player" && at_spot.health > 0 && at_spot.deadflag == #DEAD_NO && self != at_spot)
				i = #FALSE;
			
			at_spot = at_spot.chain;			
		}

		if (i == #TRUE)
		{
			i = 1 + floor(random()*5);

			self.velocity = '0 0 0';
			//WK Jump em up since they fall down now when feigning
			//setorigin (self, self.origin + '0 0 30');
			setsize (self, #VEC_HULL_MIN, #VEC_HULL_MAX);
			self.view_ofs = '0 0 22';
			//Prevent bad movetype errors, or something
			if (self.classname != "player") {
				RPrint("BUG BUG BUG BUG BUG BUG BUG BUG BUG\n");
				RPrint("Non-player tried to un-feign!\n");
				return;
			}
			self.movetype = #MOVETYPE_WALK;
			self.is_feigning = #FALSE;
			self.current_weapon = self.weapon;
			W_SetCurrentAmmo();

		#ifdef QUAKE_WORLD
			self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
			TeamFortress_SetSpeed(self);
		#endif

			// Check .weapon, because .current_weapon has been reset
			if (self.weapon <= #WEAP_AXE)
			{
				spy_upaxe1 ();
				return;
			}
			
			if (i == 1)
				spy_upb1();
			else if (i == 2)
				spy_upc1();
			else if (i == 3)
				spy_upd1();
			else
				spy_upe1();
		}
		else
		{
			sprint(self, #PRINT_HIGH, "You can't get up while someone\nis standing on you.\n");
		}
	}
	else
	{
		if (!(self.flags & #FL_ONGROUND) && (self.waterlevel == 0))
		{
			sprint(self, #PRINT_HIGH, "You can't feign in the air.\n");
			return;
		}
		
		//WK - Can't feign while carrying flag. King cheater!
		if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT)) { 
			sprint(self, #PRINT_HIGH, "Can't feign while glowing, you sloppy bitch.\n");
			return;
		}
		//WK - Can't feign while shooting grapple. Crash fix?
		if (self.hook_out) { 
			sprint(self, #PRINT_HIGH, "Can't feign and grapple, silly\n");
			return;
		}
		//WK - No feign detpackers
		if (self.is_detpacking) { 
			sprint(self, #PRINT_HIGH, "Can't feign while setting a detpack, fool\n");
			return;
		}
		if (self.is_toffingadet) //SB same for C4 det
		{
			sprint(self, #PRINT_HIGH, "How are you going to throw a detpack while lying down?\n");
			return;
		}
		if (self.is_haxxxoring) // SB No sleep-hackers
		{
			sprint(self, #PRINT_HIGH, "You can't fall asleep AND hack, do one or the other.\n");
			return;
		}
		//WK Stop detpackers
		if (self.tfstate & #TFSTATE_CANT_MOVE) {
			sprint(self,#PRINT_HIGH, "Can't feign whilst stationary\n");
			return;
		}
		//WK Prevent sliders
		if (self.is_building == #TRUE) {
			sprint(self, #PRINT_HIGH, "Can't feign while building, beeatch.\n");
			return;
		}
		//WK Prevent worker/feigners
		if (self.job & #JOB_ACTIVE) {
			sprint(self, #PRINT_HIGH, "Can't rest while working, you lazy bum!\n");
			return;
		}
		//CH Prevents the most evil bug of all, so evil that I can not speak of it.... j/k
		if (self.done_custom & #CUSTOM_BUILDING) {
			sprint (self, #PRINT_HIGH, "You can't pretend to die when you're not alive!\n");
			return;
		}

		// Check to make sure there isn't anyone on top of us
		at_spot = findradius(self.origin, 64);
		while (at_spot != world)
		{
			if (at_spot.classname == "player" && at_spot.health > 0 && self != at_spot && at_spot.is_feigning == #TRUE)
			{
				sprint(self, #PRINT_HIGH, "You can't feign on top of another spy!\n");
			}
			
			at_spot = at_spot.chain;			
		}

	#ifdef QUAKE_WORLD
		makeImmune(self,time+2);
		//self.immune_to_check = time + 2;
		self.tfstate = self.tfstate | #TFSTATE_CANT_MOVE;
		TeamFortress_SetSpeed(self);
	#endif

		self.is_feigning = #TRUE;
		Attack_Finished(0.8);

		// make dead guy release hook (wedge)
		if (self.hook_out)
		{
			Reset_Grapple (self.hook);
			Attack_Finished(0.75);
			self.hook_out = #TRUE;	// PutClientInServer will reset this
		}

		if (self.undercover_team == 0 && self.undercover_skin == 0)
			self.items = self.items - (self.items & #IT_INVISIBILITY);
		self.invisible_finished = 0;
		self.modelindex = modelindex_player;	// don't use eyes

		// Save the current weapon and remove it
		self.weapon = self.current_weapon;
		self.current_weapon = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;

		//WK setsize (self, '-16 -16 -24', '16 16 4');
		//WK Make people fall to the ground when they feign
		// Ambush, the guy that made MegaTF swears that there is no way
		// to lower the camera angle, and even has a letter from Carmack
		// testifying to that fact...
		// Here's how you do it, moron:
		// setsize (self, '0 0 -10', '0 0 0');
		setsize (self, '-16 -16 -24', '16 16 4');
		self.view_ofs = '0 0 4';
		self.movetype = #MOVETYPE_TOSS;

		if (type == 1) //CH normal feign
			DeathSound();
		
		self.angles_x = 0;
		self.angles_z = 0;

		// Check .weapon, because .current_weapon has been reset
		if (self.weapon <= #WEAP_AXE)
		{
			spy_die_ax1 ();
			return;
		}

		i = 1 + floor(random()*6);
		
		if (i == 1)
			spy_diea1();
		else if (i == 2)
			spy_dieb1();
		else if (i == 3)
			spy_diec1();
		else if (i == 4)
			spy_died1();
		else
			spy_diee1();
	}
};

//=========================================================================
// If its a net game, the SPY goes invisible.
// If its a LAN game, the class/skin changing menu pops up.
void() TeamFortress_SpyGoUndercover =
{
	local entity te;

	if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT))
	{
		sprint(self, #PRINT_MEDIUM, "You cannot disguise while glowing.\n");
		return;
	}

	if (invis_only == #TRUE)
	{
		// If the spy is already invisible, become visible
		if (self.is_undercover == 1)
		{
			self.is_undercover = 0;
			self.modelindex = modelindex_player;	// return to normal
//WK			self.items = self.items - (self.items & #IT_INVISIBILITY);
		}
		else if (self.is_undercover == 2)	
		{
			sprint(self, #PRINT_HIGH, "You stop going undercover.\n");
			self.is_undercover = 0;
		}
		else // Become invisible
		{
			if (self.ammo_cells > 1)
			{
				sprint(self, #PRINT_HIGH, "Going undercover...\n");

				self.is_undercover = 2;

				// Start a timer, which turns the player invisible when it ticks
				te = spawn();
				te.classname = "timer";
				te.owner = self;
				te.think = TeamFortress_SpyUndercoverThink;
				te.nextthink = time + #PC_SPY_GO_UNDERCOVER_TIME;
			}
		}
		self.StatusRefreshTime = time + 0.1;
	}
	else
	{
		// Pop up the menu
		if (self.is_undercover != 2)
		{
			self.current_menu = #MENU_SPY;
			self.menu_count = #MENU_REFRESH_RATE;
		}
		else // if (self.is_undercover == 2)
		{
			//WK Fix TF2.5 bug
			sprint(self, #PRINT_HIGH, "You stop going undercover.\n");
			if (self.undercover_team != 0 || self.undercover_skin != 0)
				self.is_undercover = 1;
			else
				self.is_undercover = 0;
		}
	}
};

//=========================================================================
// Try and find the player's name who's skin and team closest fit the 
// current disguise of the spy
void(entity spy) TeamFortress_SpyCalcName =
{
	local entity te;

	spy.undercover_name = string_null;
	// Find a player on the team the spy is disguised as to pretend to be
	if (spy.undercover_team != 0)
	{
		te = find(world, classname, "player");
		while (te)
		{
			// First, try to find a player with same color and skins
			if (te.team_no == spy.undercover_team && te.skin == spy.undercover_skin)
			{
				spy.undercover_name = te.netname;
				te = world;
			}
			else
				te = find(te, classname, "player");
		}

		// If we couldn't, just find one of that team
		if (spy.undercover_name == string_null)
		{
			te = find(world, classname, "player");
			while (te)
			{
				if (te.team_no == spy.undercover_team)
				{
					spy.undercover_name = te.netname;
					te = world;
				}
				else
					te = find(te, classname, "player");
			}
		}
	}
};

//=========================================================================
// Make the spy who owns this timer undercover, and then remove itself
void() TeamFortress_SpyUndercoverThink =
{
	local float tc;
	local string st;

	if (!(self.owner.cutf_items & #CUTF_SPY_KIT)) //WK
		return;

	if (self.owner.is_undercover == 2)
	{
//WK		self.owner.items = self.owner.items | #IT_INVISIBILITY;
		if (invis_only == #TRUE)
		{
			self.owner.frame = 0;
			self.owner.modelindex = modelindex_eyes;
			self.owner.is_undercover = 1;
		}
		else
		{
			makeImmune(self.owner,time + 4);
			//self.owner.immune_to_check = time + 4;

			// Skin change?
			if (self.skin != 0)
			{
				sprint(self.owner, #PRINT_HIGH, "Skin set to ");
				TeamFortress_PrintClassName(self.owner,self.skin,0);
				
				self.owner.undercover_skin = self.skin;
				TeamFortress_SetSkin(self.owner);
			}

			// Color change
			if (self.team != 0)
			{
				sprint(self.owner, #PRINT_HIGH, "Colors set to Team ");
				st = ftos(self.team);
				sprint(self.owner, #PRINT_HIGH, st);
				sprint(self.owner, #PRINT_HIGH, "\n");

				self.owner.undercover_team = self.team;
				// Set their color 
				stuffcmd(self.owner, "color ");
				tc = TeamFortress_TeamGetColor(self.team) - 1;
				
				st = ftos(tc);
				 //- OfN - Nice colors						 //? team_no
				if (nicecolors==1) st =TeamGetNiceColor(self.team);

				stuffcmd(self.owner, st);
				stuffcmd(self.owner, "\n");
			}

			TeamFortress_SpyCalcName(self.owner);

			if (self.owner.StatusBarSize == 0)
				CenterPrint(self.owner, "You are now disguised.\n");

			self.owner.is_undercover = 1;
		}
	}

	self.owner.StatusRefreshTime = time + 0.1;
//CH go to special bar :)
	self.owner.StatusBarScreen = 2;
	
	dremove(self);
};

//=========================================================================
// Change the Spy's skin to the class they chose
void(float class) TeamFortress_SpyChangeSkin =
{
	local entity te;

	// OfN - Psionized guys can't do it
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self,#PRINT_HIGH,"You hardly can do anything right now!\n");
		return;
	}

	// If they're returning their skin to their Spy, just reset it
	if (class == #PC_SPY && self.playerclass == #PC_SPY) //WK
	{
		sprint (self, #PRINT_HIGH, "Skin reset.");
		self.undercover_skin = 0;
		TeamFortress_SetSkin(self);

		if (self.undercover_team == 0)
		{
//WK			self.items = self.items - (self.items & #IT_INVISIBILITY);
			self.is_undercover = 0;
		}
		return;
	}

	sprint(self, #PRINT_HIGH, "Going undercover...\n");

	self.is_undercover = 2;

	// Start a timer, which changes the spy's skin to the chosen one
	te = spawn();
	te.classname = "timer";
	te.owner = self;
	te.think = TeamFortress_SpyUndercoverThink;
	te.nextthink = time + #PC_SPY_GO_UNDERCOVER_TIME;
	te.skin = class;
	TeamFortress_SetSkin(self);
};

//=========================================================================
// Change the Spy's color to that of the Team they chose
void(float teamno) TeamFortress_SpyChangeColor =
{
	local entity te;
	local string st;
	local float tc;

	// OfN - Psionized guys can't do it
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self,#PRINT_HIGH,"You hardly can do anything right now!\n");
		return;
	}

	// If they're returning their color to their own team, just reset it
	if (teamno == self.team_no)
	{
		sprint (self, #PRINT_HIGH, "Colors reset.\n");

		makeImmune(self,time + 4);
		//self.immune_to_check = time + 4;
		self.undercover_team = 0;
		stuffcmd(self, "color ");
		tc = TeamFortress_TeamGetColor(self.team_no) - 1;
		st = ftos(tc);
		
		//- OfN - Nice colors
		if (nicecolors==1) st =TeamGetNiceColor(self.team_no);

		stuffcmd(self, st);
		stuffcmd(self, "\n");

		if (self.undercover_skin == 0)
		{
//WK			self.items = self.items - (self.items & #IT_INVISIBILITY);
			self.is_undercover = 0;
		}
		return;
	}

	sprint(self, #PRINT_HIGH, "Going undercover...\n");

	self.is_undercover = 2;

	// Start a timer, which changes the spy's skin to the chosen one
	te = spawn();
	te.classname = "timer";
	te.owner = self;
	te.think = TeamFortress_SpyUndercoverThink;
	te.nextthink = time + #PC_SPY_GO_UNDERCOVER_TIME;
	te.team = teamno;
};

//=========================================================================
// Gas Grenade touch function.
void() GasGrenadeTouch =
{
	// Thrown grenades don't detonate when hitting an enemy

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Gas grenade explosion. Throws up the particle cloud.
void() GasGrenadeExplode =
{
	local entity te;
	local float pos;

	sound(self,#CHAN_WEAPON,"misc/vapeur2.wav",1,#ATTN_NORM);

	// Check the pointcontents to prevent detpack outside the world
	pos = pointcontents(self.origin); 
	if (pos == #CONTENT_EMPTY) 
	{
		te = spawn();
		te.think = GasGrenadeMakeGas;
		te.nextthink = time + 0.1;
		te.heat = 0;
		te.origin = self.origin;
		te.owner = self.owner;
		te.team_no = self.owner.team_no;
		te.weapon = 0;
	}
	else
	{
		// Make some bubbles :)
		pos = 0;
		while (pos < 10)
		{
			newmis = spawn();
			setmodel (newmis, "progs/s_bubble.spr");
			setorigin (newmis, self.origin);
			newmis.movetype = #MOVETYPE_NOCLIP;
			newmis.solid = #SOLID_NOT;
			newmis.velocity = '0 0 15';
			newmis.velocity_z = 10 + (random() * 20);
			newmis.nextthink = time + 0.5;
			newmis.think = bubble_bob;
			newmis.classname = "bubble";
			newmis.frame = 0;
			newmis.cnt = 0;
			setsize (newmis, '-8 -8 -8', '8 8 8');

			pos = pos + 1;
		}
	}

#ifndef QUAKE_WORLD
	BecomeExplosion ();
#else		
	dremove(self);
#endif
};

//=========================================================================
// Gas Grenade Gas function
void() GasGrenadeMakeGas =
{
	local entity te, timer;

	self.nextthink = time + 0.75;

	// Do the Effects
	te = findradius(self.origin, 200);
	while (te != world)
	{
		if (te.classname == "player" && te.deadflag == #DEAD_NO && te.health > 0)
		{
			//Dont affect those with gas masks or invincible or biosuits
			if (!(te.tf_items & #NIT_SCUBA || te.invincible_finished > time || te.radsuit_finished > time)) //WK
			{
			// Damage
			deathmsg = #DMSG_GREN_GAS;
			/*
			if (self.heat == 0) // Grievre fix
				TF_T_Damage (te, world, self.owner, 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
				TF_T_Damage (te, world, self.owner, 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
			else
				TF_T_Damage (te, world, self.owner, 40, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
				*/
			//WK 4/27/7 The above makes no sense.
				TF_T_Damage (te, world, self.owner, 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
			
			// Make them hallucinate
			if (te.tfstate & #TFSTATE_HALLUCINATING)
			{
				// Already Hallucination, so just increase the time
				timer = find(world, classname, "timer");
				while (((timer.owner != te) || (timer.think != HallucinationTimer)) && (timer != world))
				{
					timer = find(timer, classname, "timer");
				}
				if (timer != world)
				{
					timer.health = timer.health + 50; //SB used to be 25
					if (timer.health > 100)
						timer.health = 100;
					timer.nextthink = time + #GR_HALLU_TIME;
				}
			}
			else
			{
				sprint(te, #PRINT_HIGH, "You stop breathing as the poison attacks your nerves...\n");
				te.tfstate = te.tfstate | #TFSTATE_HALLUCINATING;
				// Create a timer entity
				timer = spawn();
				timer.nextthink = time + #GR_HALLU_TIME;
				timer.think = HallucinationTimer;
				timer.classname = "timer";
				timer.owner = te;
				timer.health = 75; //WK 100 - this makes it more balanced
									//SB 25 - this makes it more funner
				timer.team_no = self.team_no;
			}
			} //WK --^
		}
		te = te.chain;
	}

	self.heat = self.heat + 1;

	// Do the cloud
	if (self.heat == 1)
	{
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_TAREXPLOSION);
		WriteCoord (#MSG_BROADCAST, self.origin_x);
		WriteCoord (#MSG_BROADCAST, self.origin_y);
		WriteCoord (#MSG_BROADCAST, self.origin_z);
	#ifdef QUAKE_WORLD
		multicast (self.origin, #MULTICAST_PVS);
	#endif
		return;
	}
	if (self.heat <= #GAS_GREN_CYCLES)
	{
		self.weapon = self.weapon + 1;
		if (self.weapon == 1)
		{
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_LAVASPLASH);
			WriteCoord (#MSG_BROADCAST, self.origin_x);
			WriteCoord (#MSG_BROADCAST, self.origin_y);
			WriteCoord (#MSG_BROADCAST, self.origin_z - 24);
		#ifdef QUAKE_WORLD
			multicast (self.origin, #MULTICAST_PVS);
		#endif
		}
		else if (self.weapon == 2)
		{
			self.weapon = 0;
		}

		return;
	}

	dremove(self);
};

//=========================================================================
// Timer function for Hallucinations.
void() HallucinationTimer =
{
	local entity te;
	local float tmpx, tmpy, halltype;

	// Setup for the next Think
	self.health = self.health - #GR_HALLU_DEC;
	// medic recovers twice as fast
	if (self.owner.weapons_carried & #WEAP_MEDIKIT) //WK
		self.health = self.health - #GR_HALLU_DEC;
	if (self.health <= 0)
		self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_HALLUCINATING);
	if (!(self.owner.tfstate & #TFSTATE_HALLUCINATING))
	{
		sprint(self.owner, #PRINT_HIGH, "You feel a little better now.\n");
		dremove(self);
		return;
	}

	self.nextthink = time + #GR_HALLU_TIME;

	// Kick
	if (random() < 0.5)
	{
		KickPlayer(-10, self.owner);
	}

	// Do the Hallucinations
	tmpx = (random() * 800) - 400;
	tmpy = (random() * 800) - 400;
	halltype = random();
	msg_entity = self.owner;
	// Explosions
	if (halltype < 0.4) //WK .4 We want all hallucination to be explosions. :)
	{
		WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
		if (halltype < 0.4)
			WriteByte (#MSG_ONE, #TE_EXPLOSION);
		else if (halltype < 0.6)
			WriteByte (#MSG_ONE, #TE_TAREXPLOSION);
		else // if (halltype < 0.4)
			WriteByte (#MSG_ONE, #TE_LAVASPLASH);
		WriteCoord (#MSG_ONE, msg_entity.origin_x + tmpx);
		WriteCoord (#MSG_ONE, msg_entity.origin_y + tmpy);
		WriteCoord (#MSG_ONE, msg_entity.origin_z);
	}
	// Teleport
	else if (halltype < 0.7)
	{
		WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
		WriteByte (#MSG_ONE, #TE_TELEPORT);
		WriteCoord (#MSG_ONE, msg_entity.origin_x + tmpx);
		WriteCoord (#MSG_ONE, msg_entity.origin_y + tmpy);
		WriteCoord (#MSG_ONE, msg_entity.origin_z);
	}
	// Lightning
	else // if (halltype < 1)
	{
		te = spawn();
		te.origin_x = msg_entity.origin_x + tmpx;
		te.origin_y = msg_entity.origin_y + tmpy;
		te.origin_z = msg_entity.origin_z;
		WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
		WriteByte (#MSG_ONE, #TE_LIGHTNING2);
		WriteEntity (#MSG_ONE, te);
		WriteCoord (#MSG_ONE, te.origin_x);
		WriteCoord (#MSG_ONE, te.origin_y);
		WriteCoord (#MSG_ONE, te.origin_z);
		tmpx = (random() * 800) - 400;
		tmpy = (random() * 800) - 400;
		WriteCoord (#MSG_ONE, msg_entity.origin_x + tmpx);
		WriteCoord (#MSG_ONE, msg_entity.origin_y + tmpy);
		WriteCoord (#MSG_ONE, msg_entity.origin_z);
		dremove(te);
	}
};

//=========================================================================
// Firing Function for the Tranquiliser Gun
void() W_FireTranq =
{
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	
	KickPlayer(-2, self);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_FLYMISSILE;
	newmis.solid = #SOLID_BBOX;
		
	makevectors (self.v_angle);
	newmis.velocity = v_forward;
	newmis.velocity = newmis.velocity * 2400;	//WK 2/8/7 4000 //WK 1/7/7 Tranq upgrade //Faster than a normal nail WK 1500
	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = T_TranqDartTouch;

	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;

	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');
};

//=========================================================================
// Touch Function for the Tranquiliser Darts
void() T_TranqDartTouch =
{
	local entity timer;
	local float tranq_damage;

	if (other.solid == #SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		dremove(self);
		return;
	}

	//WK Sweep for mines at point of contact	
	GuerillaMineSweep(self.origin);

	// hit something that bleeds
	if (other.takedamage)
	{
		//WK Make sure they aren't immune
		if (!(other.tf_items & #NIT_SCUBA || other.invincible_finished > time || other.radsuit_finished > time))
		{
		spawn_touchblood (9);
		deathmsg = #DMSG_TRANQ;

		// Do the Damage
		//WK 1/7/7 Increased power of tranq to 25-45, ignoring armor
		//WK 2/8/7 Lowered to 20-25, lowered speed from 4000 to 2400
		//WK 2/26/7 Lowered to 8-12, because people kept bitching
		tranq_damage = 8+floor(4*random()); //WK 1/7/7 Note: if you put this formula in the function call, it crashes the server!
		TF_T_Damage (other, self, self.owner, tranq_damage, #TF_TD_NOTTEAM | #TF_TD_IGNOREARMOUR, #TF_TD_NAIL);
		
		if (other.classname == "player")
		if (other.#runes & #RUNE_RESIS)
			return;

		// If its a player or demon, tranquilise them
		//- OfN if (other.classname == "monster_demon1" && !(Teammate(other.real_owner.team_no,self.owner.team_no) && (teamplay & (#TEAMPLAY_HALFDIRECT | #TEAMPLAY_NODIRECT))))
		if (IsMonster(other))// && !(Teammate(other.real_owner.team_no,self.owner.team_no) && (teamplay & (#TEAMPLAY_HALFDIRECT | #TEAMPLAY_NODIRECT))))
		{
			//bprint(#PRINT_HIGH, "demon tranq!\n");
			// If they're already tranquilised, just make it last longer
			if (other.tfstate & #TFSTATE_TRANQUILISED)
			{
				timer = find(world, classname, "timer");
				while (((timer.owner != other) || (timer.think != TranquiliserTimer2)) && (timer != world))
				{
					timer = find(timer, classname, "timer");
				}
				if (timer != world)
				{
					timer.nextthink = time + #TRANQ_TIME;
				}
			}
			else
			{
				other.tfstate = other.tfstate | #TFSTATE_TRANQUILISED;
				// Create a timer entity
				timer = spawn();
				timer.nextthink = time + #TRANQ_TIME;
				timer.think = TranquiliserTimer2;
				timer.classname = "timer";
				timer.owner = other;
				timer.team_no = self.owner.team_no;
			}
		}
		if (other.classname == "player" && !(Teammate(other, self.owner) && (teamplay & (#TEAMPLAY_HALFDIRECT | #TEAMPLAY_NODIRECT))))
		{
			// If they're already tranquilised, just make it last longer
			if (other.tfstate & #TFSTATE_TRANQUILISED)
			{
				timer = find(world, classname, "timer");
				while (((timer.owner != other) || (timer.think != TranquiliserTimer)) && (timer != world))
				{
					timer = find(timer, classname, "timer");
				}
				if (timer != world)
				{
					timer.nextthink = time + #TRANQ_TIME;
				}
			}
			else
			{
				sprint(other, #PRINT_HIGH, "You stop breathing...\n");
				other.tfstate = other.tfstate | #TFSTATE_TRANQUILISED;
				// Create a timer entity
				timer = spawn();
				timer.nextthink = time + #TRANQ_TIME;
				timer.think = TranquiliserTimer;
				timer.classname = "timer";
				timer.owner = other;
				timer.team_no = self.owner.team_no;

				// now slow them down
				TeamFortress_SetSpeed(other);
			}
		}
		}
	}
	else
	{
	   if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
			FieldEvent(other,self.origin,self);//FieldExplosion(other,self.origin,self);
		else
		{
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_SPIKE);
			WriteCoord (#MSG_BROADCAST, self.origin_x);
			WriteCoord (#MSG_BROADCAST, self.origin_y);
			WriteCoord (#MSG_BROADCAST, self.origin_z);
		#ifdef QUAKE_WORLD
			multicast (self.origin, #MULTICAST_PVS);
		#endif
		}
	}

	dremove(self);
};

//=========================================================================
// Think function for Tranquilisation.
// Just remove the player's tranquilisation.
void() TranquiliserTimer =
{
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_TRANQUILISED);

	TeamFortress_SetSpeed(self.owner);

	sprint(self.owner, #PRINT_HIGH, "You feel more alert now\n");

	dremove(self);
};
//CH used for demons
void() TranquiliserTimer2 =
{
	if (self.owner.tfstate & #TFSTATE_TRANQUILISED) //Just in case
		self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_TRANQUILISED);
	dremove(self);
};

// Reset spy skin and color or remove invisibility
void(entity spy) Spy_RemoveDisguise =
{
	local string st;
	local float tc;
	//local float reset;

	if (invis_only != #TRUE)
	{
		if (spy.cutf_items & #CUTF_SPY_KIT)
		{
			// Reset the Skin
			if (spy.undercover_skin != 0)
			{
//WK				spy.items = spy.items - (spy.items & #IT_INVISIBILITY);
				makeImmune(spy,time + 4);
				//spy.immune_to_check = time + 4;
				spy.undercover_skin = 0;
				spy.skin = 0;
				TeamFortress_SetSkin(spy);
			}

			// Set their color 
			if (spy.undercover_team != 0)
			{
//WK				spy.items = spy.items - (spy.items & #IT_INVISIBILITY);
				makeImmune(spy,time + 4);
				//spy.immune_to_check = time + 4;
				spy.undercover_team = 0;

				stuffcmd(spy, "color ");
				tc = TeamFortress_TeamGetColor(spy.team_no) - 1;
				
				st = ftos(tc);

				//- OfN - Nice colors
				if (nicecolors==1) st =TeamGetNiceColor(spy.team_no);

				stuffcmd(spy, st);
				stuffcmd(spy, "\n");
			}

			spy.is_undercover = 0;
			self.StatusRefreshTime = time + 0.1;

			TeamFortress_SpyCalcName(spy);
		}
	}
	else
	{
		if (spy.is_undercover)
		{
			// remove the invisibility	
			spy.is_undercover = 0;
			spy.modelindex = modelindex_player; // return to normal
			
//WK			if (spy.items & #IT_INVISIBILITY)
//WK				spy.items = spy.items - #IT_INVISIBILITY;

			self.StatusRefreshTime = time + 0.1;
		}
	}
};
