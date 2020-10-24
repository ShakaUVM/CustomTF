/*=======================================================//
// guerilla.QC - CustomTF 3.2.OfN		   - 18/4/2004 - //
=========================================================//
 Guerilla job stuff - Revamped by OfteN [cp]
---------------------------------------------------------//
 Moved to its own file due to the huge changes
 The Guerilla Menu is also handled here
=========================================================*/

/*
** Guerilla Profession -
** Can set self-detonating land mines
**
** OfN - Modified and improved using JOB_EXTRA's
** No job extras = Everything as before
** 1 extra = Menu, can place level2 mines and special mines
** 2 extras = Menu, can place level3 and level2 mines, special mines
**			  and can convert grenades into mines.
** Appart from converted mines when u have "Specialist":
** When having any job extras a player can place NAPALM or BIO mines
** if he has Pyrotoys or napalm grens and medikit or bio grens respectively
*/

// Guerilla maximums and job setttings
#define GUERILLA_NOEXTRAS_MINEMAX 3
#define GUERILLA_EXTRA1_POINTSMIN 4
#define GUERILLA_EXTRA1_POINTSMAX 8
#define GUERILLA_EXTRA2_POINTSMIN 5
#define GUERILLA_EXTRA2_POINTSMAX 10
#define GUERILLA_FIXED_MINEMAX 5 // Mines hard max

// Bonuses
#define GUERILLA_BONUS1  20 // Number of mine kills to get 1st bonus
#define GUERILLA_BONUS2  36 // Number of mine kills to get 2nd bonus
#define GUERILLA_FRAGSFORPOINT 7 // Number of mine kills to get an extra point

//- Mine types -//

// Regular mines
#define MINE_REGULAR	  1
#define MINE_LEVEL1 	  1
#define MINE_LEVEL2 	  2
#define MINE_LEVEL3 	  3

// Special mines
#define MINE_CONCUSSION   4
#define MINE_PSIONIC	  5
#define MINE_BIO		  6 // specially avaliable
#define MINE_NAPALM 	  7 // specially avaliable
#define MINE_MIRV		  8

// Converted-only mines
#define MINE_NAIL		  9
#define MINE_GAS		  10
#define MINE_EMP		  11
#define MINE_FRAG		  12
#define MINE_KRAC		  13
#define MINE_CALTROP	  14
#define MINE_ANTIGRAV	  15

// Damage settings
#define MINE_DMG			200
#define MINE_UNARMED_DMG	60 // 80
#define MINE_DMG_LEVEL1 	200//200 // was 240 /215
#define MINE_DMG_LEVEL2 	250
#define MINE_DMG_LEVEL3 	300
#define MINE_LVL2_LEGDMG	1 // 2
#define MINE_LVL3_LEGDMG	2 // 4

// Flags for converted mines on player entity (2nd byte on .increase_team4 field)
#define GUERILLA_CONV1_SET 1
#define GUERILLA_CONV2_SET 2

// Various settings
#define GUERILLA_ACTIVATE_TIME 8 //Time until it turns on //- it was 3? prolly 10
#define GUERILLA_BEEP_RATE 4 //Delay between beeps //- it was 3
#define GUERILLA_MINE_DURATION 240 //WK 8/4/7 360. Time it lasts after being activated (WK Fixed, now is actual seconds.)
#define GUERILLA_JOB_DELAY 4 //Time between mine placements //- it was 10
#define GUERILLA_RADIUS 135 //-it was 150 without define
#define GUERILLA_MINE_COST 4 // OfN number of rockets a mine needs

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

For player entity:
------------------

.all_active 	- Used for the following stuff
				(byte1) Points spent on currently existing mines 
				(byte2) Mine points still avaliable for mines
				(byte3) Mine points earned

.increase_team4 - Used for the following stuff
	(WARNING: This field is used also for warlock/army status bar)
				(byte1) Number of mines up
				(byte2) Bitfield for converted grenade flags
					|1 Converted type1 grenade mine up
					|2 Converted type2 grenade mine up
				(byte3) UNUSED STILL
			   

.dont_do_triggerwork -
	(WARNING: This field is used also for warlock points/army rating)
				Kills achieved by mines

For mine entity:
----------------

.health 			- Remaining life time for the mine
.last_attacked_time - Controls delay between beeps on mine
.has_tesla			- Determines what to sprint to owner on mine explosion
.heat				- Time variable, determines if mine is charged
.has_sentry 		- Type of the mine
.has_sensor 		- Determines if this mine is a standard lvl1/lvl2/lvl3 mine or not
.has_fieldgen		- Flag used to flash mines on activation
.has_holo			- If 1 or 2, mine is a converted grenade, indicates grenade slot also

================================================================================================*/

float(entity player) GetMineSpentPoints;
float(entity player) GetMinePoints;
float(entity player) GetMineEarnedPoints;
void(entity player,float spentpoints) SetMineSpentPoints;
void(entity player,float points) SetMinePoints;
void(entity player,float points) SetMineEarnedPoints;

float(entity player) GetMineConvBitfield;
void(entity player, float bitfield) SetMineConvBitfield;
float(entity player) GetMinesUp;
void(entity player, float minesup) SetMinesUp;


void(float minetype, float converted) GuerillaSetMine;
string(float typ) GetGrenadeText;
float(float typ) IsMineConvertible;
string(float minetype) GetMineStr;
float(float grentype) ConvertGrenIDToMine;
void(entity player, entity mine) MineUp;
void(entity player, entity mine) MineDown;
float(entity player, float minetype, float converted) AttemptToSetMine;
float(float minetype) MineNeededPoints;
float(entity player) GuerillaGetMaxPointsForJob;
void(entity player) GuerillaUpgradeJob;
//float(entity player) GuerillaGetTotalPoints;

// External
void(entity pl, string s1, string s2, string s3, string s4, string s5, string s6, string s7) CenterPrint7;
void() ConcussionGrenadeExplode;
void() PsionicGrenadeExplode;
void() BioGrenadeExplode;
void() NapalmGrenadeExplode;
void() MirvGrenadeExplode;
void() NailGrenadeExplode;
void() GasGrenadeExplode;
void() EMPGrenadeExplode;
void() FragGrenadeExplode;
void() KracGrenadeExplode;
void() CaltropGrenadeExplode;
void() AntiGravGrenadeExplode;

float(entity player, float damage) HurtLegs;

//===============================================================
// Guerilla menu (only used if we have job extras)

void() Menu_Guerilla =
{
	local string header, st1, st2, st3, st4, st5, foot, tmp;
	local float extras, points, bitfield, minesup;
	
	extras = GetJobExtras(self);
	points = GetMinePoints(self);
	minesup = GetMinesUp(self);

	if (extras == 1) // Technician
	{
		if (!minesup)
		{
			header = "Τεγθξιγιαξ:     ¨no mines up©\n\n";
		}
		else if (minesup == 1)
		{
			header = "Τεγθξιγιαξ:      ¨1 mine up©\n\n";
		}
		else
		{
			header = "Τεγθξιγιαξ:      ¨";
			tmp = ftos(minesup);
			header = strcat(header,tmp);
			header = strcat(header," mines up©\n\n");
		}
		
		if (points == 0)
		{
			st1 = ".. Level 1 Mine        (1 point)\n.. Level 2 Mine       (2 points)\n\n.. Concussion Mine     (1 point)\n.. Psionic Mine       (2 points)\n";
			
			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        (3 points)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    (2 points)\n";
			else
				st2 = "\n";

			st3 = ".. MIRV Mine          (3 points)\n\n";
		}
		else if (points == 1)
		{
			st1 = ".. Level 1 Mine        ( ποιξτ)\n.. Level 2 Mine       (2 points)\n\n.. Concussion Mine     ( ποιξτ)\n.. Psionic Mine       (2 points)\n";
			
			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        (3 points)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    (2 points)\n";
			else
				st2 = "\n";

			st3 = ".. MIRV Mine          (3 points)\n\n";
		}
		else if (points == 2)
		{
			st1 = ".. Level 1 Mine        ( ποιξτ)\n.. Level 2 Mine       ( ποιξτσ)\n\n.. Concussion Mine     ( ποιξτ)\n.. Psionic Mine       ( ποιξτσ)\n";
			
			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        (3 points)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    ( ποιξτσ)\n";
			else
				st2 = "\n";
			
			st3 = ".. MIRV Mine          (3 points)\n\n";
		}
		else if (points > 2)
		{
			st1 = ".. Level 1 Mine        ( ποιξτ)\n.. Level 2 Mine       ( ποιξτσ)\n\n.. Concussion Mine     ( ποιξτ)\n.. Psionic Mine       ( ποιξτσ)\n";

			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        ( ποιξτσ)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    ( ποιξτσ)\n";
			else
				st2 = "\n";

			st3 = ".. MIRV Mine          ( ποιξτσ)\n\n";
		}
					
		st4 = "";
		st5 = "";
	}
	else // Specialist
	{
		if (!minesup)
		{
			header = "Σπεγιαμιστ:     ¨no mines up©\n\n";
		}
		else if (minesup == 1)
		{
			header = "Σπεγιαμιστ:      ¨1 mine up©\n\n";
		}
		else
		{
			header = "Σπεγιαμιστ:      ¨";
			tmp = ftos(minesup);
			header = strcat(header,tmp);
			header = strcat(header," mines up©\n\n");
		}
			
		if (points == 0)
		{
			st1 = ".. Level 1 Mine        (1 point)\n.. Level 2 Mine       (2 points)\n.. Level 3 Mine       (3 points)\n\n.. Concussion Mine     (1 point)\n.. Psionic Mine       (2 points)\n";
			
			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        (3 points)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    (2 points)\n";
			else
				st2 = "\n";

			st3 = ".. MIRV Mine          (3 points)\n\n";
		}
		else if (points == 1)
		{
			st1 = ".. Level 1 Mine        ( ποιξτ)\n.. Level 2 Mine       (2 points)\n.. Level 3 Mine       (3 points)\n\n.. Concussion Mine     ( ποιξτ)\n.. Psionic Mine       (2 points)\n";
			
			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        (3 points)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    (2 points)\n";
			else
				st2 = "\n";

			st3 = ".. MIRV Mine          (3 points)\n\n";
		}
		else if (points == 2)
		{
			st1 = ".. Level 1 Mine        ( ποιξτ)\n.. Level 2 Mine       ( ποιξτσ)\n.. Level 3 Mine       (3 points)\n\n.. Concussion Mine     ( ποιξτ)\n.. Psionic Mine       ( ποιξτσ)\n";
			
			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        (3 points)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    ( ποιξτσ)\n";
			else
				st2 = "\n";
			
			st3 = ".. MIRV Mine          (3 points)\n\n";
		}
		else if (points > 2)
		{
			st1 = ".. Level 1 Mine        ( ποιξτ)\n.. Level 2 Mine       ( ποιξτσ)\n.. Level 3 Mine       ( ποιξτσ)\n\n.. Concussion Mine     ( ποιξτ)\n.. Psionic Mine       ( ποιξτσ)\n";

			if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
				st2 = ".. Napalm Mine        ( ποιξτσ)\n";
			else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
				st2 = ".. Biological Mine    ( ποιξτσ)\n";
			else
				st2 = "\n";

			st3 = ".. MIRV Mine          ( ποιξτσ)\n\n";
		}
				
		st4="";
		st5="";

		bitfield = GetMineConvBitfield(self);

		if (!(bitfield & #GUERILLA_CONV1_SET))
		if (self.no_grenades_1 >= 1)
		if (IsMineConvertible(self.tp_grenades_1))
		{
			st4 = ".. Convert ";
			tmp = GetGrenadeText(self.tp_grenades_1);
			st4 = strcat(st4,tmp);
			st4 = strcat(st4," Grenade");
			st4 = padstr(st4,33);
			st4 = strcat(st4,"\n");
		}

		if (!(bitfield & #GUERILLA_CONV2_SET))
		if (self.no_grenades_2 >= 1)
		if (IsMineConvertible(self.tp_grenades_2))
		{
			st5 = ".. Convert ";
			tmp = GetGrenadeText(self.tp_grenades_2);
			st5 = strcat(st5,tmp);
			st5 = strcat(st5," Grenade");
			st5 = padstr(st5,33);
			st5 = strcat(st5,"\n");
		}
	}

	foot =	  "\n.. Ξοτθιξη                      \n\nΗυεςιμμα Ποιξτσ: ";
	
	tmp = ftos(points);
	foot = strcat(foot,tmp);
	foot = strcat(foot,"―");

	bitfield = GetMineSpentPoints(self);
	tmp = ftos(points + bitfield);
	foot = strcat(foot,tmp);
	
	CenterPrint7(self,header,st1,st2,st3,st4,st5,foot);
};

//======================================================================
// Guerilla menu handler

void(float inp) Menu_Guerilla_Input =
{
	if (inp == 10)
	{
		ResetMenu();
		self.impulse = 0;
	}

	// are we a specialist? if so.. we can convert grenades
	if (self.job & #JOB_EXTRA2)
	{
		local float convID;
		local float bitfield;

		bitfield = GetMineConvBitfield(self);

		if (inp == 8) // conversion of grenade 1
		{
			if (!(bitfield & #GUERILLA_CONV1_SET))
			if (self.no_grenades_1 >= 1)
			if (IsMineConvertible(self.tp_grenades_1))
			{
				convID = ConvertGrenIDToMine(self.tp_grenades_1);
				GuerillaSetMine(convID,1);
			}
		}

		if (inp == 9) // conversion of grenade 2
		{
			if (!(bitfield & #GUERILLA_CONV2_SET))
			if (self.no_grenades_2 >= 1)
			if (IsMineConvertible(self.tp_grenades_2))
			{
				convID = ConvertGrenIDToMine(self.tp_grenades_2);
				GuerillaSetMine(convID,2);
			}	 
		}
	}

	if (inp == 1)
		GuerillaSetMine(#MINE_LEVEL1,0);		
	else if (inp == 2)
		GuerillaSetMine(#MINE_LEVEL2,0);
	else if (inp == 3 && self.job & #JOB_EXTRA2)
		GuerillaSetMine(#MINE_LEVEL3,0);
	else if (inp == 4)
		GuerillaSetMine(#MINE_CONCUSSION,0);
	else if (inp == 5)
		GuerillaSetMine(#MINE_PSIONIC,0);
	else if (inp == 6)
	{
		if (self.tp_grenades_1 == #GR_TYPE_NAPALM || self.tp_grenades_2 == #GR_TYPE_NAPALM || self.weapons_carried & #WEAP_FLAMETHROWER)
			GuerillaSetMine(#MINE_NAPALM,0);
		else if (self.tp_grenades_1 == #GR_TYPE_BIO || self.tp_grenades_2 == #GR_TYPE_BIO || self.weapons_carried & #WEAP_MEDIKIT)
			GuerillaSetMine(#MINE_BIO,0);		 
	}
	else if (inp == 7)
		GuerillaSetMine(#MINE_MIRV,0);
		
	self.impulse = 0;
};

//======================================================================
// A mine blows up

void() GuerillaExplode =
{
	// Only call minedown() if we r still guerilla, this avoids garbage on clean up
	if (self.owner.job & #JOB_GUERILLA)
		MineDown(self.owner,self);

	local string st,st2;
	local float charged;
	
	if (time < self.heat + #GUERILLA_ACTIVATE_TIME)
		charged = #FALSE;
	else
		charged = #TRUE;

	self.health = 0; //CH would cause tesla to act weird without
	
	if (self.has_sensor) // Standard mines
	{
		local float hitdamage, legdmg;
		local float joblevel;

		joblevel = GetJobExtras(self.owner);

		legdmg = 0;

		if (self.has_sentry == #MINE_LEVEL1)
			hitdamage = #MINE_DMG_LEVEL1;
		else if (self.has_sentry == #MINE_LEVEL2)
		{
			hitdamage = #MINE_DMG_LEVEL2;

			legdmg = #MINE_LVL2_LEGDMG;
			
			if (charged)
				SpawnSprite(1,#SPRITE_AIRBURST,self.origin,'0 0 0',#SPRITEMOVE_UP,0.1);
		}
		else
		{
			hitdamage = #MINE_DMG_LEVEL3;

			legdmg = #MINE_LVL3_LEGDMG;
			
			if (charged)
				SpawnSprite(3,#SPRITE_AIRBURST,self.origin,'0 0 0',#SPRITEMOVE_UP,0.15);
		}

		deathmsg = #DMSG_LAND_MINE;

		if (joblevel == 0)
		{
		  if (self.has_tesla == 2) // set by GuerillaSwep for trace weapons
			sprint(self.owner,#PRINT_HIGH,"your mine is destroyed\n");

		  if (self.has_tesla == 0) // default 
			sprint(self.owner,#PRINT_HIGH,"your mine explodes\n");
		
		  // if has_tesla is 1 print nothing, as this is set by DetonateMines() and GuerillaThink
		}
		else // specialist or technician
		{			 
			st = GetMineStr(self.has_sentry);
			st2 = "";

			if (self.has_holo)
				st2 = " converted";

			if (self.has_tesla == 2) // set by GuerillaSwep for trace weapons
				sprint(self.owner,#PRINT_HIGH,"Your ",st,st2," mine is destroyed\n");
			
			if (self.has_tesla == 0) // default 
				sprint(self.owner,#PRINT_HIGH,"Your ",st,st2," mine explodes\n");			 
		}

		if (!charged) //If not charged, do less damage when blowing up
		   T_RadiusDamage (self, self.owner, #MINE_UNARMED_DMG, world); //- damage was 80
		else 
		{
		   T_RadiusDamage (self, self.owner, hitdamage, world); //- damage was 160
		   
		   // legdamage for lvl2 and lvl3 mines if was hit from below (on ground usually)
		   if (legdmg)
		   {
			   local entity te;

			   te = findradius(self.origin, hitdamage + 15);
			   
			   while (te)
			   {
					if (te.classname == "player")
					if (CanDamage (te, self))
					if (te.health > 0)
					if (te.playerclass != #PC_UNDEFINED)
					if (!Teammate(te, self.owner) || te == self.owner)
					if (!(te.invincible_finished > time))
					if (te.is_connected)
					if (!(te.armorclass & #AT_SAVEEXPLOSION) || random() < 0.25) // blast armor avoids our legs to be hurt most of the time
					if (te.origin_z > self.origin_z) // only hurt legs if hit from below..
					{
						if (HurtLegs(te,legdmg))
						{
							if (legdmg == #MINE_LVL3_LEGDMG)
								sprint(te,#PRINT_HIGH,"Woah! That mine really hurts your legs!\n");   
							else
								sprint(te,#PRINT_HIGH,"That mine hurts your legs!\n");
						}
					}

					te = te.chain;
			   }
		   }
		}
		
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
		WriteCoord (#MSG_BROADCAST, self.origin_x);
		WriteCoord (#MSG_BROADCAST, self.origin_y);
		WriteCoord (#MSG_BROADCAST, self.origin_z);
	#ifdef QUAKE_WORLD
		multicast (self.origin, #MULTICAST_PHS);
		dremove(self);
	#else
		BecomeExplosion ();
	#endif
	 }
	 else // Non-standard mines
	 {
		self.netname = "special_mine"; // avoids recursive calls and lets us identify mines vs grens
		self.touch = SUB_Null;
		self.think = SUB_Null;
		self.nextthink = -1;
		self.takedamage = #DAMAGE_NO; // NEEDED or crash

		st = GetMineStr(self.has_sentry);
		st2 = "";

		if (self.has_holo)
			st2 = " converted";

		if (self.has_tesla == 2) // set by GuerillaSwep for trace weapons
			sprint(self.owner,#PRINT_HIGH,"Your ",st,st2," mine is destroyed\n");
			
		if (self.has_tesla == 0) // default 
			sprint(self.owner,#PRINT_HIGH,"Your ",st,st2," mine explodes\n");
		
		if (!charged) // not armed?
		{
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
			WriteCoord (#MSG_BROADCAST, self.origin_x);
			WriteCoord (#MSG_BROADCAST, self.origin_y);
			WriteCoord (#MSG_BROADCAST, self.origin_z);
		#ifdef QUAKE_WORLD
			multicast (self.origin, #MULTICAST_PHS);
			dremove(self);
		#else
			BecomeExplosion ();
		#endif
		}
		else // special mine is charged..
		{
			if (self.has_sentry == #MINE_CONCUSSION)
				ConcussionGrenadeExplode();
			else if (self.has_sentry == #MINE_PSIONIC)
				PsionicGrenadeExplode();
			else if (self.has_sentry == #MINE_BIO)
				BioGrenadeExplode();
			else if (self.has_sentry == #MINE_NAPALM)
				NapalmGrenadeExplode();
			else if (self.has_sentry == #MINE_MIRV)
				MirvGrenadeExplode();
			else if (self.has_sentry == #MINE_NAIL)
				NailGrenadeExplode();
			else if (self.has_sentry == #MINE_GAS)
				GasGrenadeExplode();
			else if (self.has_sentry == #MINE_EMP)
				EMPGrenadeExplode();
			else if (self.has_sentry == #MINE_FRAG)
				FragGrenadeExplode();
			else if (self.has_sentry == #MINE_KRAC)
				KracGrenadeExplode();
			else if (self.has_sentry == #MINE_CALTROP)
				CaltropGrenadeExplode();
			else if (self.has_sentry == #MINE_ANTIGRAV)
				AntiGravGrenadeExplode();
			else
			{
				RPrint("BUG: Unknown mine type on GuerillaExplode()!\n");
				dremove(self);
				return;
			}
		}
	 }
};

//=========================================================================
// Detonate all mines the mine_owner player entity has

void(entity mine_owner) DetonateMines =
{
	local entity e;
	local entity oself;

	oself = self;

	// Find any mine
	e = find(world, netname, "land_mine");
	
	while (e != world)
	{
	   if(e.classname == "grenade")
	   if(e.owner == mine_owner) {
		 /*e.heat = time;
		 e.has_tesla = 1; //- display no message on GuerillaExplode
		 e.think = GuerillaExplode;
		 e.nextthink = time;*/
		 self = e;
		 e.heat = time;
		 e.has_tesla = 1;
		 GuerillaExplode();
	   }
	   e = find(e, netname, "land_mine");
	}

	self = oself;
};

//====================================================
//Code to detonate the guerilla mines on traceattack weapons.
//Has small radius, just large enough to hit what was aimed at

void(vector startpos) GuerillaMineSweep =
{
	local entity head;
	head = findradius(startpos, 30);	
	while (head)
	{
		if (head.classname == "grenade" && head.netname == "land_mine") {
				  
		  head.has_tesla = 2; // "mine is destroyed" message on guerillaexplode()
		  head.think = GuerillaExplode;
		  head.nextthink = time + 0.1;				
				  
		}
		head = head.chain;
	}
};

//============================================================
// Think of mines, makes sound, scans and explodes if needed

void() GuerillaThink = //Every second see if we have enemy nearby
{
	if (!self.owner.is_connected)
	{
		dremove(self);
		return;
	}
	
	local entity head;
	local float finished; //Only blow up once
	
	if (self.has_fieldgen == 1)
	{
		self.effects = 0;
		self.has_fieldgen = 2;
		self.nextthink = time + 0.1;
		return;
	}
	if (self.has_fieldgen == 2)
	{
		self.effects = #EF_DIMLIGHT;
		self.has_fieldgen = 3;
		self.nextthink = time + 0.1;
		return;
	}
	if (self.has_fieldgen == 3)
	{
		self.effects = 0;
		self.has_fieldgen = 4;		  
	}
	
	finished = 0;
	
	self.nextthink = time + #MINE_SCANRATE;
	
	if (time < self.heat + #GUERILLA_ACTIVATE_TIME)
		return;
	
	if (time > self.last_attacked_time) {
		sound (self, #CHAN_WEAPON, "weapons/guerblip.wav", 1, #ATTN_IDLE);
		self.last_attacked_time = time + #GUERILLA_BEEP_RATE;

		if (!self.has_fieldgen)
		{
			self.has_fieldgen = 1;
			self.effects = #EF_DIMLIGHT;
			self.nextthink = time + 0.1;
			return;
		}
	}

	local string desc, conv;
	local float hasextras;

	if (self.has_holo)
		conv = " converted";
	else
		conv = "";

	if (self.owner.job & #JOB_EXTRA1 || self.owner.job & #JOB_EXTRA2)
		hasextras = #TRUE;
	else
		hasextras = #FALSE;

	desc = GetMineStr(self.has_sentry);
	
	self.health = self.health - #MINE_SCANRATE;

	if (self.health <= 0) { //Detonate mine cause we ran out of time

		local float minesup;

		minesup = GetMinesUp(self.owner);

		self.heat = time; //Make it a smaller explosion

		if (hasextras)
			sprint(self.owner,#PRINT_HIGH,"Your ",desc,conv," mine runs out of energy, ");
		else
			sprint(self.owner,#PRINT_HIGH,"Your mine runs out of energy, ");
		
		if (minesup > 1) {
		   local string st;
		   st = ftos (minesup - 1);
		   
		   if (self.owner.job & #JOB_EXTRA1 || self.owner.job & #JOB_EXTRA2)
		   {
			   sprint(self.owner,#PRINT_HIGH,"you still have ");
			   sprint(self.owner,#PRINT_HIGH,st);
			   sprint(self.owner,#PRINT_HIGH," mines up\n");
		   }
		   else
		   {
			   sprint(self.owner,#PRINT_HIGH,"you still have ");
			   sprint(self.owner,#PRINT_HIGH,st);
			   sprint(self.owner,#PRINT_HIGH,"/#GUERILLA_NOEXTRAS_MINEMAX mines up\n");
		   }
		}
		else
		   sprint(self.owner,#PRINT_HIGH,"you currently have no active mines\n");
		self.has_tesla = 1; //- display no message on GuerillaExplode
		GuerillaExplode();
		finished = 1;
	}
	head = findradius(self.origin,#GUERILLA_RADIUS);//OfN it was 150
	while (head != world && !finished) {
		if (head.classname == "player" && head.health > 0)
		{
			if (head.playerclass != #PC_UNDEFINED) // skip Observers
			{
				//Mines detonate on either enemies or yourself
				if (CanDamage(head,self)) {
				   if (!Teammate(head, self.owner) && head.undercover_team != self.owner.team_no)
				   {
						//WK 5-15-08 Blow up only if they are running away, stopped, or we are MIRV/NAPALM mines
						local vector vect_to_target;
						local float dotpro, boom;
						boom = 0;
						vect_to_target = head.origin - self.origin;
						dotpro = vect_to_target * head.velocity;
						if (dotpro > 0) boom = 1;
						if (vlen(head.velocity) < 120) boom = 1;
						if (self.has_sentry == #MINE_NAPALM || self.has_sentry == #MINE_MIRV) boom = 1;
						if (boom) {
							//Uncovered ENEMY
							if (hasextras)
								sprint(self.owner,#PRINT_HIGH,"your ",desc,conv," mine explodes on ");
							else
								sprint(self.owner,#PRINT_HIGH,"your mine explodes on ");

							sprint(self.owner,#PRINT_HIGH,head.netname);
						
							if (head.origin_z > self.origin_z)
								sprint(self.owner,#PRINT_HIGH,"'s ass!\n");
							else
								sprint(self.owner,#PRINT_HIGH,"'s face!\n");

							self.has_tesla = 1; //- display no message on GuerillaExplode
							GuerillaExplode();
							finished = 1;
						}
				   } else if (head == self.owner) { // ourselves
							
					   self.has_tesla = 1; //- display no message on GuerillaExplode
					   GuerillaExplode();
					   finished = 1;
				   }
				}
			}
		}
		else if (IsMonster(head) && !Teammate(head.real_owner, self.owner)) { //- OfN - monsters and grunt are affected
			T_Damage(head,self,self.owner,#MINE_DMG); //Demons are vulnerable
			self.has_tesla = 1; //- display no message on GuerillaExplode
			GuerillaExplode();
			finished = 1;
		}
		head = head.chain;
	}
	//if (finished && self.has_sensor)
	//	dremove(self);
};

//================================================================
// What happens when someone runs it over

void() GuerillaTouch = 
{
	if (time < self.heat + #GUERILLA_ACTIVATE_TIME)
		return;

	if (other.playerclass == #PC_UNDEFINED) // skip Observers
		return;   

	#ifdef MINES_IGNORE_TEAMMATETOUCH
	if (other != self.owner)
	if (other.classname == "player" || IsMonster(other))
	if (Teammate(self.owner, other))
	if (other.health > 0)
		return;
	#endif

	if (other.classname == "player")
	if (other.health > 0)
	if (other.is_connected)
	{
		local string desc, conv;
		conv = "";
		desc = GetMineStr(self.has_sentry);

		if (self.has_holo)
			conv = " converted";

		if (self.owner.job & #JOB_EXTRA1 || self.owner.job & #JOB_EXTRA2)
			sprint(self.owner,#PRINT_HIGH,other.netname," touches your ",desc,conv," mine!\n");
		else
			sprint(self.owner,#PRINT_HIGH,other.netname," touches your mine!\n");
	}

	GuerillaExplode();
};

void() GuerillaTossTouch = 
{
	if (other != world) {
		GuerillaTouch();
		return;
	}

	if (pointcontents(self.origin) == #CONTENT_SKY || pointcontents(self.origin) == #CONTENT_SOLID) //CH if in wall or sky
	{
		self.health = 0; //CH needed for tesla
		// OfN CAUSES ANY PROBLEM? Is this needed?
				
		MineDown(self.owner,self);

		dremove(self);
		return;
	}

	self.angles = self.velocity = self.avelocity = '0 0 0';
	self.movetype = #MOVETYPE_NONE;
	sound (self, #CHAN_WEAPON, "weapons/guerset.wav", 1, #ATTN_NORM);
	self.touch = GuerillaTouch;
	self.think = GuerillaThink;
	self.nextthink = time + 1;
};

//==================================================================
// Called when a guerilla player uses 'skill'

void() JobGuerilla =
{
	if (self.job & #JOB_EXTRA1 || self.job & #JOB_EXTRA2)
	{
		if (self.current_menu == #MENU_GUERILLA)
		{
			GuerillaSetMine(#MINE_LEVEL1,0);
			return; 
		}

		self.current_menu = #MENU_GUERILLA;
		self.menu_count = #MENU_REFRESH_RATE; 
		return;
	}
	
	GuerillaSetMine(#MINE_REGULAR,0);
};

//============================================================================
// Sets a mine of the specified kind

void(float minetype, float converted) GuerillaSetMine =
{
	if (!minetype) 
	{
		// if this gets executed its a bug
		RPrint("BUG: Invalid mine type on GuerillaSetMine()\n");
		return; 
	}
	
	if (!AttemptToSetMine(self,minetype,converted)) return;

	self.ammo_rockets = self.ammo_rockets - #GUERILLA_MINE_COST;
	//WK 9/15/7 Fix rocket ammo not updating on guerilla
	if (self.items & #IT_ROCKETS) self.currentammo = self.ammo_rockets;

	self.job_finished = time + #GUERILLA_JOB_DELAY;
		
	if (self.job & #JOB_EXTRA1 || self.job & #JOB_EXTRA2)
	{
		local string st;
		st = GetMineStr(minetype);
		
		if (converted)
			sprint(self,#PRINT_HIGH,"you convert a grenade into a ",st," mine...\n");		 
		else
			sprint(self,#PRINT_HIGH,"you place a ",st," mine...\n");		
	}
	else
		sprint(self,#PRINT_HIGH,"you place a mine...\n");

	if (self.current_menu == #MENU_GUERILLA)
		ResetMenu();
	
	#ifdef TEAM_MINE_REPORTS
	teamprefixsprint(self.team_no,self);
	teamsprint(self.team_no,self,self.netname);
	teamsprint(self.team_no,self," places a mine\n");
	#endif

	//Set all the critical crap on the mine
	newmis = spawn();
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_BBOX;
	newmis.takedamage = #DAMAGE_AIM;
	newmis.classname = "grenade";
	newmis.netname	 = "land_mine";
	//newmis.flags = #FL_FINDABLE_NONSOLID; // For mine ID
	//setsize (newmis, '-1 -1 0', '1 1 0.5');		
	setsize (newmis, '0 0 0','0 0 0');
	//setsize (newmis, '-0.5 -0.5 -0.5', '1 1 1');		
	setorigin (newmis, self.origin);
	newmis.owner = self;
	makevectors (self.v_angle);
	newmis.avelocity = '300 300 300';
	newmis.velocity = v_forward*600 + v_up * 200 + v_right*10 + v_up*10;
	newmis.angles = vectoangles(newmis.velocity);
	
	if (minetype == #MINE_NAPALM)
		newmis.skin = 2;
	else if (minetype == #MINE_MIRV)
		newmis.skin = 0;
	else // default look
		newmis.skin = 1;

	//setmodel (newmis, "progs/lndmine.mdl");
	setmodel (newmis, "progs/biggren.mdl");

	newmis.heat = time; //Controls when mine can first go off
	newmis.has_tesla = 0; // OfN flag to Control what to sprint to owner of the mine when it exlodes
	newmis.last_attacked_time = time; // Controls beeps
	newmis.health = #GUERILLA_MINE_DURATION; //Max time for mine to live
	newmis.touch = GuerillaTossTouch;
	newmis.think = GuerillaThink;
	newmis.nextthink = time + #GUERILLA_ACTIVATE_TIME;

	newmis.has_sentry = minetype;

	newmis.has_fieldgen = 0;

	if (minetype == #MINE_LEVEL1 || minetype == #MINE_LEVEL2 || minetype == #MINE_LEVEL3)
		newmis.has_sensor = 1; // Standard mine
	else
		newmis.has_sensor = 0; // Non-standard mine

	newmis.has_holo = converted;

	MineUp(self,newmis);
};

//==============================================================================
// We have just killed some1 with our mines, award point/bonuses if appropiate

void(entity player) MineKill =
{
	if (!(player.job & #JOB_GUERILLA))
	{
		//RPrint("BUG: Non-guerilla was in MineKill()!\n");
			// ^_^ not a bug, may happen on cleanup
		return;
	}
	
	// increase our mine kills counter
	player.dont_do_triggerwork = player.dont_do_triggerwork + 1;

	// award extra guerilla points if appropiate
	if (player.job & #JOB_EXTRA1 || player.job & #JOB_EXTRA2)
	{
		local float tfloat, tint, maxpoints, spent;

		tfloat = player.dont_do_triggerwork / #GUERILLA_FRAGSFORPOINT;
		tint = floor(player.dont_do_triggerwork / #GUERILLA_FRAGSFORPOINT);
		
		if (tfloat == tint)
		{
			tfloat = GetMineEarnedPoints(player);
			tint = GetMinePoints(player);
			spent = GetMineSpentPoints(player);
			maxpoints = GuerillaGetMaxPointsForJob(player);

			if ((tint + spent + 1) > maxpoints)
			{
				// Do nothing
			}
			else
			{
				sprint(player,#PRINT_HIGH,"You have earned an extra guerilla point!\n");

				SetMinePoints(player, tint + 1);
				SetMineEarnedPoints(player, tfloat + 1);
			}
			
		}
	}

	if (extras_mode == 2)
		return;

	// reward with job extras
	if (player.dont_do_triggerwork == #GUERILLA_BONUS1)
		GuerillaUpgradeJob(player);
	else if (player.dont_do_triggerwork == #GUERILLA_BONUS2)
		GuerillaUpgradeJob(player);    
};

//====================================================================
// We use the 3 different bytes on .all_active field for the stuff

float(entity player) GetMineSpentPoints =
{
	return GetByte1(player.all_active);
};

float(entity player) GetMinePoints =
{
	return GetByte2(player.all_active);
};

float(entity player) GetMineEarnedPoints =
{
	return GetByte3(player.all_active);
};

void(entity player,float spentpoints) SetMineSpentPoints =
{
	player.all_active = AssignByte1(player.all_active,spentpoints);
};

void(entity player,float points) SetMinePoints =
{
	player.all_active = AssignByte2(player.all_active,points);
};

void(entity player,float points) SetMineEarnedPoints =
{
	player.all_active = AssignByte3(player.all_active,points);
};

//============================================================
// Returns an appropiate text for the given kind of gren

string(float typ) GetGrenadeText =
{
	local string st;

	if (typ == #GR_TYPE_NORMAL)
		st = "Normal";
	else if (typ == #GR_TYPE_CONCUSSION)
		st = "Concussion";
	else if (typ == #GR_TYPE_NAIL)
		st = "Nail";
	else if (typ == #GR_TYPE_MIRV)
		st = "Mirv";
	else if (typ == #GR_TYPE_NAPALM)
		st = "Napalm";
	else if (typ == #GR_TYPE_FLARE)
		st = "Flare";
	else if (typ == #GR_TYPE_GAS)
		st = "Gas";
	else if (typ == #GR_TYPE_EMP)
		st = "EMP";
	#ifdef OLD_FLASH
	else if (typ == #GR_TYPE_FLASH)
		st = "Flash";
	#else
	else if (typ == #GR_TYPE_PSIONIC)
		st = "Psionic";
	#endif
	else if (typ == #GR_TYPE_FRAG)
		st = "Fragmentation";
	else if (typ == #GR_TYPE_KRAC)
		st = "KRAC";
	else if (typ == #GR_TYPE_CALTROP)
		st = "Caltrop";
	else if (typ == #GR_TYPE_BIO)
		st = "Biological";
	else if (typ == #GR_TYPE_ANTIGRAV)
		st = "Antigrav";
	else st = "ERROR!";

	return st;
};

//====================================================================
// Returns TRUE if the specified gren type is "convertible" to a mine

float(float typ) IsMineConvertible =
{
	if (typ == #GR_TYPE_NORMAL)
		return #TRUE;
	if (typ == #GR_TYPE_CONCUSSION)
		return #TRUE;
	if (typ == #GR_TYPE_NAIL)
		return #TRUE;
	if (typ == #GR_TYPE_MIRV)
		return #TRUE;
	if (typ == #GR_TYPE_NAPALM)
		return #TRUE;
	if (typ == #GR_TYPE_FLARE)
		return #FALSE;
	if (typ == #GR_TYPE_GAS)
		return #TRUE;
	if (typ == #GR_TYPE_EMP)
		return #TRUE;
	if (typ == #GR_TYPE_PSIONIC)
		return #TRUE;
	if (typ == #GR_TYPE_FRAG)
		return #TRUE;
	if (typ == #GR_TYPE_KRAC)
		return #TRUE;
	if (typ == #GR_TYPE_CALTROP)
		return #TRUE;
	if (typ == #GR_TYPE_BIO)
		return #TRUE;
	if (typ == #GR_TYPE_ANTIGRAV)
		return #TRUE;
	
	return #FALSE;
};

//===========================================================================
// Gets the name of the given mine kind

string(float minetype) GetMineStr =
{
	if (minetype == #MINE_LEVEL1)
		return "level 1";
	if (minetype == #MINE_LEVEL2)
		return "level 2";
	if (minetype == #MINE_LEVEL3)
		return "level 3";
	if (minetype == #MINE_CONCUSSION)
		return "concussion";
	if (minetype == #MINE_PSIONIC)
		return "psionic";
	if (minetype == #MINE_BIO)
		return "biological";
	if (minetype == #MINE_NAPALM)
		return "napalm";
	if (minetype == #MINE_MIRV)
		return "MIRV";
	if (minetype == #MINE_NAIL)
		return "nail";
	if (minetype == #MINE_GAS)
		return "gas";
	if (minetype == #MINE_EMP)
		return "EMP";
	if (minetype == #MINE_FRAG)
		return "fragmentation";
	if (minetype == #MINE_KRAC)
		return "krac";
	if (minetype == #MINE_CALTROP)
		return "caltrop";
	if (minetype == #MINE_ANTIGRAV)
		return "antigrav";
	 
	return "ERROR!";
};

//==========================================================
// Converts gren ID number into its corresponding mine ID

float(float grentype) ConvertGrenIDToMine =
{
	if (grentype == #GR_TYPE_NORMAL)
		return #MINE_REGULAR;
	if (grentype == #GR_TYPE_CONCUSSION)
		return #MINE_CONCUSSION;
	if (grentype == #GR_TYPE_NAIL)
		return #MINE_NAIL;
	if (grentype == #GR_TYPE_MIRV)
		return #MINE_MIRV;
	if (grentype == #GR_TYPE_NAPALM)
		return #MINE_NAPALM;
	if (grentype == #GR_TYPE_GAS)
		return #MINE_GAS;
	if (grentype == #GR_TYPE_EMP)
		return #MINE_EMP;
	if (grentype == #GR_TYPE_PSIONIC)
		return #MINE_PSIONIC;
	if (grentype == #GR_TYPE_FRAG)
		return #MINE_FRAG;
	if (grentype == #GR_TYPE_KRAC)
		return #MINE_KRAC;
	if (grentype == #GR_TYPE_CALTROP)
		return #MINE_CALTROP;
	if (grentype == #GR_TYPE_BIO)
		return #MINE_BIO;
	if (grentype == #GR_TYPE_ANTIGRAV)
		return #MINE_ANTIGRAV;
	
	return 0; // Bug if happens
};

//========================================================================
// The following funcs are used to update stuff when a mine goes down/up

void(entity player, entity mine) MineUp =
{
	#ifdef MINE_DEBUG
	if (debug_target == player)
	if (debug_target.is_connected)
	{
		sprint(debug_target,#PRINT_HIGH,"MineUp()\n");	  
	}
	#endif
	
	local float minesup;
	
	minesup = GetMinesUp(player);

	if (mine.has_holo) // Converted grenade mine
	{
		local float bitfield;

		bitfield = GetMineConvBitfield(player);

		if (bitfield & mine.has_holo)
			RPrint("BUG: Double conversion of mine!\n"); // shouldnt happen

		bitfield = bitfield | mine.has_holo;

		SetMineConvBitfield(player,bitfield);

		if (mine.has_holo == 1)
		{
			if (!player.no_grenades_1)
				RPrint("BUG: MineUp() called with no grenades to be able to convert!\n");
			else
				player.no_grenades_1 = player.no_grenades_1 - 1;
		}
		else
		{
			if (!player.no_grenades_2)
				RPrint("BUG: MineUp() called with no grenades to be able to convert!\n");
			else
				player.no_grenades_2 = player.no_grenades_2 - 1;
		}
	}
	else // non-converted mine
	{	
		local float points;
		local float neededpoints;
		local float spent;

		points = GetMinePoints(player);
		neededpoints = MineNeededPoints(mine.has_sentry);
		
		if (neededpoints > points) // shouldnt happen
			RPrint("BUG: Points error in MineUp()!\n");
		
		// decrease our guerilla avaliable points
		SetMinePoints(player, points - neededpoints);

		// increase our spent points counter
		spent = GetMineSpentPoints(player);
		SetMineSpentPoints(player, spent + neededpoints);

		#ifdef MINE_DEBUG
		if (debug_target == player)
		if (debug_target.is_connected)
		{
			local string st, st2;

			st = ftos(points);
			st2 = ftos(neededpoints);

			sprint(player,#PRINT_HIGH,"points: ",st," needed: ",st2,"\n");
			
			st = ftos(spent);
			st2 = ftos(points - neededpoints);

			sprint(player,#PRINT_HIGH,"spent: ",st," result: ",st2, "\n");

			st = ftos (minesup + 1);
			sprint (player,#PRINT_HIGH,"Res mines: ",st,"\n");			  
		}
		#endif
	}

	// increase our mine counter
	SetMinesUp(player, minesup + 1);
};

void(entity player, entity mine) MineDown =
{
	#ifdef MINE_DEBUG
	if (debug_target == player)
	if (debug_target.is_connected)
	{
		sprint(debug_target,#PRINT_HIGH,"MineDown()\n");	
	}
	#endif
	
	local float minesup;
	
	minesup = GetMinesUp(player);

	if (mine.has_holo) // converted grenade mine
	{
		local float bitfield;

		bitfield = GetMineConvBitfield(player);

		/*if (!(bitfield & mine.has_holo))
			RPrint("BUG: Wrong assignment of converted mine detected!\n"); // shouldnt happen*/

			// ^_^ this happens when CleanUpEverything() is called

		bitfield = bitfield - (bitfield & mine.has_holo);

		SetMineConvBitfield(player,bitfield);
	}
	else // non-converted mine
	{
		local float points;
		local float neededpoints;
		local float spent;

		points = GetMinePoints(player);
		neededpoints = MineNeededPoints(mine.has_sentry);
		
		// increase our guerilla avaliable points
		SetMinePoints(player,points + neededpoints);

		// decrease our spent points counter
		spent = GetMineSpentPoints(player);
		SetMineSpentPoints(player,spent - neededpoints);

		#ifdef MINE_DEBUG
		if (debug_target == player)
		if (debug_target.is_connected)
		{
			local string st, st2;

			st = ftos(points);
			st2 = ftos(neededpoints);

			sprint(player,#PRINT_HIGH,"points: ",st," needed: ",st2,"\n");
			
			st = ftos(spent);
			st2 = ftos(spent - neededpoints);

			sprint(player,#PRINT_HIGH,"spent: ",st," result: ",st2, "\n");

			st = ftos (minesup - 1);
			sprint (player,#PRINT_HIGH,"Res mines: ",st,"\n");			  
		}
		#endif
	}

	// decrease our mine counter
	SetMinesUp(player, minesup - 1);
};

//========================================================================
// Returns TRUE if able to set the specified mine, and reports if not

float(entity player, float minetype, float converted) AttemptToSetMine =
{	 
	local float minesup;
	
	minesup = GetMinesUp(player);
	
	// have we set too many mines already? (fixed max)
	if (minesup >= #GUERILLA_FIXED_MINEMAX) 
	{
		sprint(player,#PRINT_HIGH,"you can't set more than #GUERILLA_FIXED_MINEMAX mines!\n");
		
		player.job_finished = time + 1;
		return #FALSE;
	}

	// not enough ammo for mine? (rockets)
	if (player.ammo_rockets < #GUERILLA_MINE_COST) 
	{
		sprint(player,#PRINT_HIGH,"every mine needs #GUERILLA_MINE_COST rockets to work!\n");		
		
		player.job_finished = time + 1;
		return #FALSE;
	}	 

	// converted grenade?
	if (converted)
	{
		// we already have this mine up?
		local float bitfield;
		bitfield = GetMineConvBitfield(player);

		if (bitfield & converted)
			return #FALSE;
		else
			return #TRUE; //..ok, set mine		  
	}
	else // non-converted mines
	{
		if (player.job & #JOB_EXTRA1 || player.job & #JOB_EXTRA2)
		{
			local float points, neededpoints;

			points = GetMinePoints(player);
			neededpoints = MineNeededPoints(minetype);

			if (points < neededpoints)
			{
				sprint(player,#PRINT_HIGH,"not enough guerilla points to set that mine!\n");
				return #FALSE;
			}
			else
				return #TRUE; //..ok, set mine
		}
		else // standard guerilla (no job extras)
		{
			if (minesup >= #GUERILLA_NOEXTRAS_MINEMAX)
			{
				sprint(player,#PRINT_HIGH,"you can set upto #GUERILLA_NOEXTRAS_MINEMAX mines!\n");
				return #FALSE;
			}
			else
				return #TRUE; //..ok, set mine
		}		 
	}

	return #FALSE; // wont happen anyway..
};

//===========================================================
// Returns needed points for the given mine type

float(float minetype) MineNeededPoints =
{
	if (minetype == #MINE_LEVEL1)
		return 1;
	if (minetype == #MINE_LEVEL2)
		return 2;
	if (minetype == #MINE_LEVEL3)
		return 3;
	if (minetype == #MINE_CONCUSSION)
		return 1;
	if (minetype == #MINE_PSIONIC)
		return 2;
	if (minetype == #MINE_BIO)
		return 2;
	if (minetype == #MINE_NAPALM)
		return 3;
	if (minetype == #MINE_MIRV)
		return 3;

	/*if (minetype == #MINE_NAIL)
		return ;
	if (minetype == #MINE_GAS)
		return ;
	if (minetype == #MINE_EMP)
		return ;
	if (minetype == #MINE_FRAG)
		return ;
	if (minetype == #MINE_KRAC)
		return ;
	if (minetype == #MINE_CALTROP)
		return ;
	if (minetype == #MINE_ANTIGRAV)
		return ;*/

	return 99; // bug if this value is taken into account	 
};

//==============================================================================
// Initializes guerilla points (MUST BE CALLED WITH NO MINES UP and only once)

void(entity player) GuerillaInit =
{
	player.all_active = 0; // first reset everything
	
	// then add the corresponding points
	if (player.job & #JOB_EXTRA1)
		SetMinePoints(player, #GUERILLA_EXTRA1_POINTSMIN);
	else if (player.job & #JOB_EXTRA2)
		SetMinePoints(player, #GUERILLA_EXTRA2_POINTSMIN);
	else SetMinePoints(player, #GUERILLA_NOEXTRAS_MINEMAX);

	// also reset mines up flags and counter
	player.increase_team4 = 0;
};

//===========================================================================
// Functions to handle flags and variables on .increase_team4 field

float(entity player) GetMinesUp =
{
	return GetByte1(player.increase_team4);
};

void(entity player, float minesup) SetMinesUp =
{
	player.increase_team4 = AssignByte1(player.increase_team4,minesup);
};

float(entity player) GetMineConvBitfield =
{
	return GetByte2(player.increase_team4);
};

void(entity player, float bitfield) SetMineConvBitfield =
{
	player.increase_team4 = AssignByte2(player.increase_team4,bitfield);
};

//=================================================================
// Returns the max number of points the player may have by job

float(entity player) GuerillaGetMaxPointsForJob =
{
	if (player.job & #JOB_GUERILLA)
	{
		if (player.job & #JOB_EXTRA2)
			return #GUERILLA_EXTRA2_POINTSMAX;
		else if (player.job & #JOB_EXTRA1)
			return #GUERILLA_EXTRA1_POINTSMAX;
		else 
			return #GUERILLA_NOEXTRAS_MINEMAX;
	}
	else 
		return 0;
};

//==================================================================
// Upgrades job, called from MineKill() if needed

void(entity player) GuerillaUpgradeJob =
{
	if (player.job & #JOB_EXTRA2)
		return; // cant upgrade anymore
	 
	if (player.job & #JOB_EXTRA1)
	{
		sprint(player,#PRINT_HIGH,"You are now a guerilla specialist!\n");

		player.job = (player.job | #JOB_EXTRA2) - #JOB_EXTRA1;

		// adjust points if needed and for sanity
		local float currentpoints, spent;
		spent = GetMineSpentPoints(player);
		currentpoints = GetMinePoints(player) + spent;
		
		if (currentpoints < #GUERILLA_EXTRA2_POINTSMIN)
		{
			SetMinePoints(player, #GUERILLA_EXTRA2_POINTSMIN - spent);
			currentpoints = GetMinePoints(player);
		}

		if (currentpoints > #GUERILLA_EXTRA2_POINTSMAX)
			SetMinePoints(player, #GUERILLA_EXTRA2_POINTSMAX - spent);			  
	}
	else // no extras
	{
		sprint(player,#PRINT_HIGH,"You have become a guerilla technician!\n");

		player.job = player.job | #JOB_EXTRA1;

		// adjust points if needed and for sanity
		local float currentpoints, spent;
		spent = GetMineSpentPoints(player);
		currentpoints = GetMinePoints(player) + spent;
		
		if (currentpoints < #GUERILLA_EXTRA1_POINTSMIN)
		{
			SetMinePoints(player, #GUERILLA_EXTRA1_POINTSMIN - spent);
			currentpoints = GetMinePoints(player);
		}

		if (currentpoints > #GUERILLA_EXTRA1_POINTSMAX)
			SetMinePoints(player, #GUERILLA_EXTRA1_POINTSMAX - spent);			  
	}
};

//=================================================================
// returns the total points a player has (avaliable+spent)

/*float(entity player) GuerillaGetTotalPoints =
{
	local float spent, avail;
	avail = GetMinePoints(player);
	spent = GetMineSpentPoints(player);

	return spent + avail;
};*/
