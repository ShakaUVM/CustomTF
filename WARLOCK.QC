/*=======================================================//
// Warlock.QC - CustomTF 3.2.OfN6          - 30/1/2001 - //
=========================================================//
 Warlock stuff - Revamped on 04/04/2004 by OfteN [cp]
---------------------------------------------------------//
 Every knife kill give you a heart
 More Meat collected = more hp for monsters
 More Heads = more skills for monsters (many things)
=========================================================*/

// Warlock settings
#define WARLOCK_BONUS1   28 // Number of hearts to get 1st bonus
#define WARLOCK_BONUS2   42 // Number of hearts to get 2nd bonus

// Monster types
#define MONSTER_SCRAG    1
#define MONSTER_FISH     2
#define MONSTER_DEMON    3
#define MONSTER_GREMLIN  4
#define MONSTER_SHAMBLER 5
#define MONSTER_ARMY     6

// Monster health settings
#define SHAMBLER_MAX_HP          4000
#define GREMLIN_MAX_HP           3200
#define DEMON_MAX_HP             3000
#define SCRAG_MAX_HP             2000
#define FISH_MAX_HP              2000

#define SHAMBLER_MIN_HP          1200
#define GREMLIN_MIN_HP           900
#define DEMON_MIN_HP             800
#define SCRAG_MIN_HP             500
#define FISH_MIN_HP              500

// Meat/heads settings
#define SHAMBLER_MAX_HEADS       40
#define GREMLIN_MAX_HEADS        35
#define DEMON_MAX_HEADS          30
#define SCRAG_MAX_HEADS          20
#define FISH_MAX_HEADS           20

#define SHAMBLER_MAX_MEAT        240 
#define GREMLIN_MAX_MEAT         200
#define DEMON_MAX_MEAT           160
#define SCRAG_MAX_MEAT           120
#define FISH_MAX_MEAT            120

// monster HP regeneration
#define SCRAG_MAXREGEN      3
#define SCRAG_REGENRATE     1.5

#define FISH_MAXREGEN       4
#define FISH_REGENRATE      1

#define FIEND_MAXREGEN      3
#define FIEND_REGENRATE     1.5

#define GREMLIN_MAXREGEN    3.5
#define GREMLIN_REGENRATE   1.5

#define SHAMBLER_MAXREGEN   4
#define SHAMBLER_REGENRATE  1.4

#define AURA_ARMY_REGEN       3
#define AURA_ARMY_REGENRATE   1.5

//#define AURA_REGEN_MINHEAL    3

// Monster feature settings
#ifdef XMAS_STUFF
#define SHAMBLER_XMAS_RANGE   5000 // too much?
#define SHAMBLER_XMAS_DMG      400
#define SHAMBLER_XMAS_MAXHITS    4
#endif

// Gizmo - monster modes
#define SUMMON_MODE_HOLDPOSITION	0
#define SUMMON_MODE_FOLLOWOWNER	1
#define SUMMON_MODE_PATROLZONE	2

#define summon_mode			penance_time

/*================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

Entity fields used for summons:
-------------------------------

.increase_team1 - Slot the monster is using on owner player
.increase_team2 - "Type" of name used
.increase_team3 - Kind of monster (#monster_type)
.increase_team4 - Level of monster (#monster_level, 1 maxed, 0 no heads when summoned)

Entity fields used for player:
------------------------------

.demon_blood         - Contains number of hearts, heads and meat the player has
.g_e                 - Contains current selected soul number, and usage settings
.dont_do_triggerwork - Overall quantity of hearts the player has collected

=================================================================================*/


void() SummonThink; // external, used by demon menu thing
entity (vector location, float life, float type, entity sld) CreateWaypoint; // Create a new grunty waypoint

//- OfN - Gets the name of monster class (shambler, fiend, scrag or soldier)
string(entity themonster) GetMonsterName;
void() MonsterTouch;
void (entity themonster) MonsterIdle;
void(vector where) spawnFOG;

void (entity themonster) PutMonsterStand;
void (entity themonster) PutMonsterWalk;

float(entity player) GetHearts;
void(entity player, float knifekills) SetHearts;
float(entity warlock) GetNumSummons;

void(entity player, float soul) SetCurrentSoul;
/*void(entity player, float usage) SetMeatUsage;
void(entity player, float usage) SetHeadsUsage;*/ // declared in client.qc

float(entity player) GetCurrentSoul;
float(entity player) GetMeatUsage;
float(entity player) GetHeadsUsage;

entity(entity warlock, float numsummon) GetSummon;
void(entity warlock, float soulnum) KillSoul;
float(entity warlock, float input) GetNeededHearts;

float(entity monster) GetMonsterLevel;
float(entity monster) GetHPforMeat;

void(entity player) UpdateReserves;

float(entity thing) IsOwnedMonster;

// OfN - Moved files, declarations:
void() demon1_stand1;
void() demon1_walk1;
void() demon1_run1;
void() Demon_MeleeAttack;
void() demon1_jump1;
void(entity attacker, float damage) demon1_pain;
void() demon1_fire1;

void() sham_stand1;
void() sham_walk1;
void() sham_run1;
void() sham_melee;
void() sham_magic1;
void(entity attacker, float damage) sham_pain;
#ifdef XMAS_STUFF
void() sham_xmas1;
#endif

void() wiz_stand1;
void() wiz_walk1;
void() wiz_run1;
void() Wiz_Missile;
void(entity attacker, float damage) Wiz_Pain;

void() fish_stand1;
void() fish_walk1;
void() fish_run1;
void() fish_attack1;
void() fish_toss1;
void(entity attacker, float damage) fish_pain;

void() gremlin_main_stand;
void() gremlin_main_walk;
void() gremlin_run1;
void() Gremlin_MeleeAttack;
void() Gremlin_MissileAttack;
void(entity attacker, float damage) gremlin_pain;

void(entity wyp, entity soldier) RemoveWaypoint;
void(entity player, float slot) ResetSlotPointer;
entity(entity sold, entity viewpoint) ReturnEasyWaypoint;

float()	WizardCheckAttack;
float()  GremlinCheckAttack;
float(entity thing) IsSummon;
void(entity themonster) MonsterDie;
string(entity themonster) GetMonsterName;
void (entity themonster) PutMonsterStand;
float(entity thebuilding) IsOffenseBuilding;
void (entity themonster) PutMonsterWalk;
float() CheckAttack;
float(entity thing) StillValidEnemy;
void (entity themonster) MonsterIdle;

void() custom_demon_die;
void() custom_shambler_die;
void() custom_grunt_die;
void() wiz_die;
void() fish_death;
void() gremlin_die;

void() walkmonster_start;
void() flymonster_start;
void() swimmonster_start;
void() flymonster_start_go;

//WK Done -----------------------------

// SB - demon summon menu

void() Menu_Demon =
{
	local string st,st3,st2,st4,st5,st6,st7;
	
    local float knifekills;
    knifekills = GetHearts(self);

    local float currentsoul;
    currentsoul = GetCurrentSoul(self);

    local entity soul;
    soul = GetSummon(self,currentsoul);

    local float extras;
    extras = GetJobExtras(self);
    
    if (extras == 0)
    {
        st3 = "¡„ÙÈÔÓ";
    }
    else
    {
        if (currentsoul == 0)
            st3 = "”ÔıÏ £±";
        else if (currentsoul == 1)
            st3 = "”ÔıÏ £≤";
        else
            st3 = "”ÔıÏ £≥";
    }

	if (soul!=world)
    {    
        st=GetMonsterName(soul);

        st3 = strcat("\n\n",st3);

        if (soul.penance_time == 0)
        {
            st2 = strcat(st3,":                  \n\n.. Come here, damn beast°   \nî.. Patrol the zone°         ");
            
            if (extras == 0)
                st4 = "\n* .. Stop there°                \n\nÆÆ Unsummon                 \n\n.. ŒÔÙËÈÓÁ                  \n\n";
            else
                st4 = "\n* .. Stop there°                \n\nÆÆ Unsummon                 \n\n.. ŒÔÙËÈÓÁ     .. ŒÂ¯Ù ”ÔıÏ\n\n";
        }
        else if (soul.penance_time == 1)
        {
            st2 = strcat(st3,":                  \n\n* .. Come here, damn beast°     \n.. Patrol the zone°         ");
            
            if (extras == 0)
                st4 = "\n.. Stop there°              \n\nÆÆ Unsummon                 \n\n.. ŒÔÙËÈÓÁ                  \n\n";
            else
                st4 = "\n.. Stop there°              \n\nÆÆ Unsummon                 \n\n.. ŒÔÙËÈÓÁ     .. ŒÂ¯Ù ”ÔıÏ\n\n";
        }
        else if (soul.penance_time == 2)
        {
            st2 = strcat(st3,":                  \n\n.. Come here, damn beast°   \n* .. Patrol the zone°           ");

            if (extras == 0)
                st4 = "\n.. Stop there°              \n\nÆÆ Unsummon                 \n\n.. ŒÔÙËÈÓÁ                  \n\n";
            else
                st4 = "\n.. Stop there°              \n\nÆÆ Unsummon                 \n\n.. ŒÔÙËÈÓÁ     .. ŒÂ¯Ù ”ÔıÏ\n\n";
        }
		else
			st2 = st4 = "";
        
        st6 = ftos(GetMeat(self));

        st5 = ftos(knifekills);
        if (strlen(st5)==1)
            st5 = strcat(" ",st5);
        st5 = strcat("ËÂ·ÚÙÛ: ",st5);
        st5 = padstr(st5,21);

        
        st5 = strcat(st5,"\n");

        if (strlen(st6)==1)
            st6 = strcat("  ",st6);
        else if (strlen(st6)==2)
            st6 = strcat(" ",st6);

        st7 = strcat("ÌÂ·Ù:  ",st6);
        st7 = strcat(st7," ÎÁÛ");
        st7 = padstr(st7,21);


        st5 = strcat(st5,st7);

        
        st5 = strcat(st5,"\n");
        
        st6 = ftos(GetHeads(self));
        if (strlen(st6)==1)
            st6 = strcat("  ",st6);
        else if (strlen(st6)==2)
            st6 = strcat(" ",st6);
        st7 = strcat("ËÂ·‰Û: ",st6);
        st7 = padstr(st7,21);

        
        st5 = strcat(st5,st7);

        CenterPrint7(self, soul.netname," º",st,"æ", st2,st4, st5);
    }
    else
    {        
        local float numsummons;
        numsummons = GetNumSummons(self);

        local float meatusage;
        local float headsusage;

        meatusage = GetMeatUsage(self);
        headsusage = GetHeadsUsage(self);

        if (numsummons == 0)
        {
            if (self.job & #JOB_BLOODY_KNIFE)
                st=strcat(st3,":                  \n\n.. Summon Scrag        (‚ÏÔÔ‰)\n.. Summon Piranha      (‚ÏÔÔ‰)");
            else
                st=strcat(st3,":                  \n\n.. Summon Scrag        (blood)\n.. Summon Piranha      (blood)");

            if (knifekills>1)
               st2="\n.. Summon Fiend     ( ËÂ·ÚÙÛ)";
            else     
               st2="\n.. Summon Fiend     (2 hearts)";

            if (knifekills>2)
               st3="\n.. Summon Gremlin   ( ËÂ·ÚÙÛ)";
            else
               st3="\n.. Summon Gremlin   (3 hearts)";

            if (knifekills>4)
               st4="\n.. Summon Shambler  ( ËÂ·ÚÙÛ)";
            else
               st4="\n.. Summon Shambler  (5 hearts)";
        }
        else if (numsummons == 1)
        {
            if (knifekills > 0)
                st=strcat(st3,":                  \n\n.. Summon Scrag      ( ËÂ·ÚÙ)\n.. Summon Piranha    ( ËÂ·ÚÙ)");
            else
                st=strcat(st3,":                  \n\n.. Summon Scrag      (1 heart)\n.. Summon Piranha    (1 heart)");
            
            if (knifekills>3)
               st2="\n.. Summon Fiend     ( ËÂ·ÚÙÛ)";
            else     
               st2="\n.. Summon Fiend     (4 hearts)";

            if (knifekills>5)
               st3="\n.. Summon Gremlin   ( ËÂ·ÚÙÛ)";
            else
               st3="\n.. Summon Gremlin   (6 hearts)";

            if (knifekills>9)
               st4="\n.. Summon Shambler ( ËÂ·ÚÙÛ)";
            else
               st4="\n.. Summon Shambler (10 hearts)";
        }
        else 
        {
            if (knifekills > 1)
                st=strcat(st3,":                  \n\n.. Summon Scrag     ( ËÂ·ÚÙÛ)\n.. Summon Piranha   ( ËÂ·ÚÙÛ)");
            else
                st=strcat(st3,":                  \n\n.. Summon Scrag     (2 hearts)\n.. Summon Piranha   (2 hearts)");

            if (knifekills>5)
               st2="\n.. Summon Fiend     ( ËÂ·ÚÙÛ)";
            else     
               st2="\n.. Summon Fiend     (6 hearts)";

            if (knifekills>8)
               st3="\n.. Summon Gremlin   ( ËÂ·ÚÙÛ)";
            else
               st3="\n.. Summon Gremlin   (9 hearts)";

            if (knifekills>14)
               st4="\n.. Summon Shambler ( ËÂ·ÚÙÛ)";
            else
               st4="\n.. Summon Shambler (15 hearts)";
        }

        
        st6 = ftos(GetMeat(self));

        st5 = ftos(knifekills);
        if (strlen(st5)==1)
            st5= strcat(" ",st5);
        st5 = strcat("ËÂ·ÚÙÛ: ",st5);
        st5 = padstr(st5,31);

        
        st5 = strcat(st5,"\n");

        
        if (strlen(st6)==1)
            st6 = strcat("  ",st6);
        else if (strlen(st6)==2)
            st6 = strcat(" ",st6);
        st7 = strcat("ÌÂ·Ù:  ",st6);
        st7 = strcat(st7," ÎÁÛ");
        st7 = padstr(st7,15);

        if (meatusage == 0)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ   0•\n");
        else if (meatusage == 1)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ  25•\n");
        else if (meatusage == 2)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ  50•\n");
        else if (meatusage == 3)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ  75•\n");
        else if (meatusage == 4)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ 100•\n");
        
        st5 = strcat(st5,st7);

      
        st6 = ftos(GetHeads(self));
        if (strlen(st6)==1)
            st6 = strcat("  ",st6);
        else if (strlen(st6)==2)
            st6 = strcat(" ",st6);
        st7 = strcat("ËÂ·‰Û: ",st6);
        st7 = padstr(st7,15);

        if (headsusage == 0)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ   0•");
        else if (headsusage == 1)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ  25•");
        else if (headsusage == 2)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ  50•");
        else if (headsusage == 3)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ  75•");
        else if (headsusage == 4)
            st7 = strcat(st7,"  .. ıÛ·ÁÂ 100•");

        st5 = strcat(st5,st7);
        

        if (extras == 0)
            CenterPrint6(self, st,st2,st3,st4,"\n\n.. ŒÔÙËÈÓÁ                    \n\n",st5);
        else
            CenterPrint6(self, st,st2,st3,st4,"\n\n.. ŒÔÙËÈÓÁ      .. ŒÂ¯Ù ”ÔıÏ \n\n",st5);

    }

    // Ignore enemy!
    // Engage enemy!


    //menu 2
    //health
    //frags
    //status
    //enemy
            
};

/*
** Warlock Profession -
** Hit an enemy with knife for blood, use that to summon a happy demon
*/
void() SummonThink =
{
	if (self.heat == 0)
	{
		self.heat = 1;
		stuffcmd(self.owner,"v_idlescale 0\n");
		self.nextthink = time + 1.5;
		return;
	}
	local entity oself;
	oself = self;
	self = self.owner;
	custom_demon_create(oself.has_tesla,oself.has_fieldgen);
    //spawnFOG(oself.origin); MOVED

    self = oself;
	dremove(self);
};

void(float inp) Menu_Demon_Input =
{
	local entity SummonTimer;
	local float points;
	local float knifekills;
	local float neededhearts;
	local string st;
	local entity soul;
	local float currentsoul;
	local float extras;

    knifekills = GetHearts(self);

    currentsoul = GetCurrentSoul(self);
    soul = GetSummon(self,currentsoul);

    extras = GetJobExtras(self);
	
    if (inp == 10) // nothing
	{	
		ResetMenu();
		self.impulse = 0;
        return;
	}
    if (inp == 1 && soul != world) // Come here!
    {	        
        if (!IsOwnedMonster(soul)) return;

        soul.penance_time = 1;

        st=GetMonsterName(soul);
        
        if (soul.enemy != world)
        {
            if (visible2(soul,soul.enemy))
            {
                sprint(self,#PRINT_HIGH,"Your ");
                sprint(self,#PRINT_HIGH,st);
                sprint(self,#PRINT_HIGH," is busy trying to kill!\n");
                self.impulse=0;
                return;
            }
        }

        if (soul.goalentity == self) 
        {
            sprint(self,#PRINT_HIGH,"Your ");
            sprint(self,#PRINT_HIGH,st);
            sprint(self,#PRINT_HIGH," is already trying to reach your position!\n");
            self.impulse=0;
            return;
        }
        
        MonsterIdle(soul);
        //CuTFMenuSound(#MENUSOUND_BUY);

        sprint(self,#PRINT_HIGH,"You call your ");
        sprint(self,#PRINT_HIGH,st);
        sprint(self,#PRINT_HIGH,".\n");
        ResetMenu();
        self.impulse=0;
        return;
	}
    else if (inp == 2 && soul != world) // patrol!
	{	
		if (!IsOwnedMonster(soul)) return;

		soul.penance_time = 2;

        st=GetMonsterName(soul);
        
        if (soul.enemy != world)
        {
            if (visible2(soul,soul.enemy))
            {
                sprint(self,#PRINT_HIGH,"Your ");
                sprint(self,#PRINT_HIGH,st);
                sprint(self,#PRINT_HIGH," is busy trying to kill!\n");
                self.impulse=0;
                return;
            }
        }

        if (soul.goalentity == soul) 
        {
            sprint(self,#PRINT_HIGH,"Your ");
            sprint(self,#PRINT_HIGH,st);
            sprint(self,#PRINT_HIGH," is already patroling!\n");
            self.impulse=0;
            return;
        }

        MonsterIdle(soul);
        //CuTFMenuSound(#MENUSOUND_BUY);

        sprint(self,#PRINT_HIGH,"Your ");
        sprint(self,#PRINT_HIGH,st);
        sprint(self,#PRINT_HIGH," will patrol the zone now...\n");

        ResetMenu();
        self.impulse=0;
        return;
	}
    else if (inp == 3 && soul != world) // stop there!
	{	
		if (!IsOwnedMonster(soul)) return;

        soul.penance_time = 0;

        st=GetMonsterName(soul);
        
        if (soul.enemy != world)
        {
            if (visible2(soul,soul.enemy))
            {
                sprint(self,#PRINT_HIGH,"Your ");
                sprint(self,#PRINT_HIGH,st);
                sprint(self,#PRINT_HIGH," is busy trying to kill!\n");
                self.impulse=0;
                return;
            }
        }

        MonsterIdle(soul);
        //CuTFMenuSound(#MENUSOUND_BUY);
        
        ResetMenu();
        self.impulse=0;
        return;
	}
    else if (inp == 8) // unsummon or meat usage
	{
		if (soul != world)
        {
			local string MName;
			MName=GetMonsterName(soul);    

			teamprefixsprint(self.team_no, self);

			teamsprint6(self,self.netname, " unsummons his ",MName, " ",soul.netname,"\n");

			KillSoul(self,soul.increase_team1);
        }
        else // meat usage
        {
            local float meatusage;
            meatusage = GetMeatUsage(self);
            meatusage = meatusage - 1;
            if (meatusage < 0)
                meatusage = 4;

            SetMeatUsage(self,meatusage);

            Menu_Demon();
            CuTFMenuSound(#MENUSOUND_BROWSE);

            self.impulse = 0;
            return;
        }

        ResetMenu();
		self.impulse = 0;
		return;
	}
    else if (inp == 9 && soul == world)
    {
        local float headsusage;
        headsusage = GetHeadsUsage(self);
        headsusage = headsusage - 1;
        if (headsusage < 0)
            headsusage = 4;

        SetHeadsUsage(self,headsusage);

        Menu_Demon();
        CuTFMenuSound(#MENUSOUND_BROWSE);

        self.impulse = 0;
        return;
    }
    else if (inp == 7 && extras != 0)
    {
        currentsoul = currentsoul + 1;
        if (currentsoul > extras)
            currentsoul = 0;
        
        SetCurrentSoul(self,currentsoul);

        CuTFMenuSound(#MENUSOUND_BROWSE);

        Menu_Demon();

        self.impulse = 0;
        return;
    }
    else if (inp >=1 && inp <=5)
    {
        SUB_Null();
    }    
    else
        return;
	
    if (soul != world)
    {
        self.impulse = 0;
        return;
    }
    
    if (inp < 1 || inp > 5)
    {
        self.impulse = 0;
        return;
    }

    neededhearts = GetNeededHearts(self,inp);

    if (neededhearts > knifekills)
    {
        sprint(self,#PRINT_HIGH,"You need more bloody hearts!\n");
        ResetMenu();
        self.impulse = 0;
        return;
    }

#ifndef WARLOCK_TEST

    if (neededhearts == 0)
    {
        if (!(self.job & #JOB_BLOODY_KNIFE))
        {
            if (inp == 1)
                sprint(self,#PRINT_HIGH,"You have to get blood from an enemy to summon a scrag!\n");
            else if (inp == 2)
                sprint(self,#PRINT_HIGH,"You have to get blood from an enemy to summon a piranha!\n");

            ResetMenu();
            self.impulse = 0;
            return;
        }
    }

#endif    

#ifdef GREMLIN_NOTDONE

    if (inp == 4)
    {
        sprint(self,#PRINT_HIGH,"Gremlin still not implemented properly, sorry!\n");
        return;
    }

#endif

#ifdef FISH_NOTDONE

    if (inp == 2)
    {
        sprint(self,#PRINT_HIGH,"Piranha still not implemented properly, sorry!\n");
        return;
    }
#endif

    
    self.impulse = 0;
    ResetMenu();
    
    // TEMP
    points = 5;

	// Gizmo - renabled this, if the monster goes inside a wall, we'll give the hearts back
	// it's done like this so the warlock will lose hearts if he dies while summoning
	// but not lose hearts if there's not enough room
	SetHearts(self,knifekills - neededhearts);
    
	if (!neededhearts)
	{
		if (self.job & #JOB_BLOODY_KNIFE && (inp == 1 || inp == 2))
			self.job = self.job - #JOB_BLOODY_KNIFE; //- OfN - caused bug
        
		if (self.current_weapon == #WEAP_AXE && (inp == 1 || inp == 2))
		{
			self.weaponmode = 0; // Remove blood on the knife
			self.weaponmodel = "progs/v_knife.mdl";
		}
	}

    stuffcmd(self,"v_idlescale 100000\n");

    //r = random(); //Random summon sounds. :)
    //if (r < 0.33) 
        sound (self, #CHAN_WEAPON, "boss2/sight.wav", 1, #ATTN_NORM);
    //else if (r < 0.66)
    //	sound (self, #CHAN_WEAPON, "wizard/widle2.wav", 1, #ATTN_NORM);
    //else
    //	sound (self, #CHAN_WEAPON, "shambler/sdeath.wav", 1, #ATTN_NORM);

    SummonTimer = spawn ();
    SummonTimer.classname = "timer";
    SummonTimer.owner = self;
    SummonTimer.nextthink = time + 1.5; //Small delays are cool
    SummonTimer.think = SummonThink;
    SummonTimer.has_tesla = points;
    SummonTimer.heat = 0;
    SummonTimer.has_fieldgen = inp;
    self.job_finished = time + 5; //Delay if summon goes bad SB reduced to 5
    self.attack_finished = time + 2.1;
};

//================================================================
// Returns TRUE if the given "name type" is free for given player

float(entity player, float nametype) IsNameTypeFree =
{
    if (player.demon_one)
        if (player.demon_one.increase_team2 == nametype)
            return #FALSE;
    
    if (player.demon_two)
        if (player.demon_two.increase_team2 == nametype)
            return #FALSE;

    if (player.demon_three)
        if (player.demon_three.increase_team2 == nametype)
            return #FALSE;
    
    return #TRUE;
};

//============================================================
// Gets the "name type" a monster should use for given player

float(entity player, float slot, float forced) GetNameType =
{
    if (!forced) // If we aren't forcing check for custom names
    {
        if (slot == 0)
        {
            if (player.#sname1 != "")
                return 0;
        }
        else if (slot == 1)
        {
            if (player.#sname2 != "")
                return 0;
        }
        else if (slot == 2)
        {
            if (player.#sname3 != "")
                return 0;
        }
    }
        
    local float rnum;
    rnum = random()*2;
    rnum = rint(rnum);
    rnum = rnum +1;

    if (IsNameTypeFree(player,rnum))
        return rnum; //name type
    
    rnum = rnum + 1;

    if (rnum == 4)
        rnum = 1;

    if (IsNameTypeFree(player,rnum))
        return rnum; //name type

    rnum = rnum + 1;

    if (rnum == 4)
        rnum = 1;

    return rnum;               
};

//==============================================================
// Assigns a name to the given monster

void(entity monster) MakeMonsterName =
{
    local string happy;
    local float r;

	// ~~~
    if (monster.increase_team2 == 0)
    {
		if (monster.increase_team1 == 0) // 1st monster slot, ".demon_one"
            happy = monster.real_owner.#sname1;
		else if (monster.increase_team1 == 1)
            happy = monster.real_owner.#sname2;
 //		else if (monster.increase_team1 == 2)
		else
            happy = monster.real_owner.#sname3;
    } else
		happy = "";
    
    if (happy == "") // should we use a default name?
    {
        r = random();

        if (monster.increase_team2 == 1) // TYPE 1
        {
            if (monster.classname == "monster_demon1")
            {
                //Make random name
                if (r < 0.1)
                    happy = "The Fiend Lazarat";
                else if (r < 0.2)
                    happy = "Lysander of Blood"; //WK 2-2-09 It was supposed to be Lysander
                else if (r < 0.3)
                    happy = "Childers Nightmare";
                else if (r < 0.4)
                    happy = "Minion of Lesric";
                else if (r < 0.5)
                    happy = "Archdemon Boris";
                else if (r < 0.6)
                    happy = "Talon";
                else if (r < 0.7)
                    happy = "Oathrender";
                else if (r < 0.8)
                    happy = "The Fiend Roeder";
                else if (r < 0.9)
                    happy = "The Fiend Warrek";
                else
                    happy = "Mourning Breath";
            }
            else if (monster.classname == "monster_army")
            {
                if ( r < 0.1 )
                    happy = "F.Lee";
                else if ( r < 0.2 )
                    happy = "A.Hoffman";
                else if ( r < 0.3 )
                    happy = "J.Garcia";
                else if ( r < 0.4 )
                    happy = "H.Dail";
                else if ( r < 0.5 )
                    happy = "R.Gustafson";
                else if ( r < 0.6 )
                    happy = "F.Gump";
                else if ( r < 0.7 )
                    happy = "A.McNab";
                else if ( r < 0.8 )
                    happy = "C.Ryan";
                else if ( r < 0.9 )
                    happy = "K.Johnson";
                else
                    happy = "W.Kerney";
            }
            else if (monster.classname == "monster_shambler")
            {
                if (r < 0.1)
                    happy = "Necrotopos";
                else if (r < 0.2)
                    happy = "Gorgon";
                else if (r < 0.3)
                    happy = "Ogroth";
                else if (r < 0.4)
                    happy = "Krogoth";
                else if (r < 0.5)
                    happy = "Karnom";
                else if (r < 0.6)
                    happy = "Rudrigan";
                else if (r < 0.7)
                    happy = "Heggor";
                else if (r < 0.8)
                    happy = "Jollgahn";
                else if (r < 0.9)
                    happy = "Ormandre";
                else
                    happy = "Llama Crusher";
            }
            else if (monster.classname == "monster_wizard") //- OfN -
            {
                if (r < 0.1)
                    happy = "Dark Spawn";
                else if (r < 0.2)
                    happy = "White Poison";
                else if (r < 0.3)
                    happy = "Lorgrath";
                else if (r < 0.4)
                    happy = "White Mask"; //WK 2-2-09
                else if (r < 0.5)
                    happy = "Polkram";
                else if (r < 0.6)
                    happy = "Yumnian";
                else if (r < 0.7)
                    happy = "Guellish";
                else if (r < 0.8)
                    happy = "Ceingum";
                else if (r < 0.9)
                    happy = "Trajeor";
                else 
                    happy = "Phitermos";
            }
            else if (monster.classname == "monster_fish") //- OfN -
            {
                if (r < 0.1)
                    happy = "Prekor";
                else if (r <0.2)
                    happy = "Grinte";
                else if (r <0.3)
                    happy = "Hubellish";
                else if (r <0.4)
                    happy = "Lergome";
                else if (r <0.5)
                    happy = "Hydrossei";
                else if (r <0.6)
                    happy = "Lordena";
                else if (r <0.7)
                    happy = "Castride";
                else if (r <0.8)
                    happy = "Fraff";
                else if (r <0.9)
                    happy = "Bolmdema";
                else 
                    happy = "Nardam";
            }
            else if (monster.classname == "monster_gremlin") //- OfN -
            {
                if (r < 0.1)
                    happy = "Oishonko";
                else if (r <0.2)
                    happy = "Prishonko";
                else if (r <0.3)
                    happy = "Druishonko";
                else if (r <0.4)
                    happy = "Melrshonko";
                else if (r <0.5)
                    happy = "Guishonko";
                else if (r <0.6)
                    happy = "Jelprime";
                else if (r <0.7)
                    happy = "Banshoi";
                else if (r <0.8)
                    happy = "Yulgrok";
                else if (r <0.9)
                    happy = "Amnide";
                else 
                    happy = "Tylogh";
            }
        }
        else if (monster.increase_team2 == 2) // TYPE 2
        {
            if (monster.classname == "monster_demon1")
            {
                //Make random name
                if (r < 0.1)
                    happy = "The Fiend Randolf";
                else if (r < 0.2)
                    happy = "Gelloshram";
                else if (r < 0.3)
                    happy = "Bloodest Roam";
                else if (r < 0.4)
                    happy = "Minion of Renime";
                else if (r < 0.5)
                    happy = "Archdemon Kessara";
                else if (r < 0.6)
                    happy = "Krasse";
                else if (r < 0.7)
                    happy = "Yoffre";
                else if (r < 0.8)
                    happy = "The Fiend Gashir";
                else if (r < 0.9)
                    happy = "The Fiend Nurigg";
                else
                    happy = "Frimego";
            }
            else if (monster.classname == "monster_army")
            {
                if ( r < 0.1 )
                    happy = "S.Howards";
                else if ( r < 0.2 )
                    happy = "A.Roberts";
                else if ( r < 0.3 )
                    happy = "J.Dell";
                else if ( r < 0.4 )
                    happy = "K.Smith";
                else if ( r < 0.5 )
                    happy = "H.Jackson";
                else if ( r < 0.6 )
                    happy = "L.Gaussen";
                else if ( r < 0.7 )
                    happy = "A.Petterson";
                else if ( r < 0.8 )
                    happy = "J.Phoenix";
                else if ( r < 0.9 )
                    happy = "P.Thomson";
                else
                    happy = "W.Collins";
            }
            else if (monster.classname == "monster_shambler")
            {
                if (r < 0.1)
                    happy = "Frandamo";
                else if (r < 0.2)
                    happy = "Kreigger";
                else if (r < 0.3)
                    happy = "Ontromader";
                else if (r < 0.4)
                    happy = "Squisher";
                else if (r < 0.5)
                    happy = "Gorgor";
                else if (r < 0.6)
                    happy = "Rimander";
                else if (r < 0.7)
                    happy = "Dellarmo";
                else if (r < 0.8)
                    happy = "Dantrapos";
                else if (r < 0.9)
                    happy = "Hellgor";
                else
                    happy = "Denoyall";
            }
            else if (monster.classname == "monster_wizard") //- OfN -
            {
                if (r < 0.1)
                    happy = "Danburn";
                else if (r < 0.2)
                    happy = "Cokrime";
                else if (r < 0.3)
                    happy = "Sinerdam";
                else if (r < 0.4)
                    happy = "Traedder";
                else if (r < 0.5)
                    happy = "Jeggish";
                else if (r < 0.6)
                    happy = "Haders";
                else if (r < 0.7)
                    happy = "Blind Light";
                else if (r < 0.8)
                    happy = "Ionizer";
                else if (r < 0.9)
                    happy = "Onergam";
                else 
                    happy = "Urapt";
            }
            else if (monster.classname == "monster_fish") //- OfN -
            {
                if (r < 0.1)
                    happy = "Shraedder";
                else if (r <0.2)
                    happy = "Troheer";
                else if (r <0.3)
                    happy = "Hugham";
                else if (r <0.4)
                    happy = "Keckarm";
                else if (r <0.5)
                    happy = "Greydom";
                else if (r <0.6)
                    happy = "Gallopos";
                else if (r <0.7)
                    happy = "Celish";
                else if (r <0.8)
                    happy = "Skummy";
                else if (r <0.9)
                    happy = "Antema";
                else 
                    happy = "Frindem";
            }
            else if (monster.classname == "monster_gremlin") //- OfN -
            {
                if (r < 0.1)
                    happy = "Kokrantim";//"Oishonko";
                else if (r <0.2)
                    happy = "Yolio";//"Prishonko";
                else if (r <0.3)
                    happy = "Sondramt";//"Druishonko";
                else if (r <0.4)
                    happy = "Hafnide";//"Melrshonko";
                else if (r <0.5)
                    happy = "Trontome";//"Guishonko";
                else if (r <0.6)
                    happy = "Valemntro";//"Jelprime";
                else if (r <0.7)
                    happy = "Lusant";//"Banshoi";
                else if (r <0.8)
                    happy = "Firsthell";//"Yulgrok";
                else if (r <0.9)
                    happy = "Lasthell";//"Amnide";
                else 
                    happy = "Hell Spawn";//"Tylogh";
            }
        }
        else // TYPE 3
        {
            if (monster.classname == "monster_demon1")
            {
                //Make random name
                if (r < 0.1)
                    happy = "The Fiend Gustave";
                else if (r < 0.2)
                    happy = "Tandam";
                else if (r < 0.3)
                    happy = "Bloodest Shink";
                else if (r < 0.4)
                    happy = "Minion of Lindos";
                else if (r < 0.5)
                    happy = "Archdemon Nempshi";
                else if (r < 0.6)
                    happy = "Kroarh";
                else if (r < 0.7)
                    happy = "Weldor";
                else if (r < 0.8)
                    happy = "The Fiend Wiskor";
                else if (r < 0.9)
                    happy = "The Fiend Poltrem";
                else
                    happy = "Donnish";
            }
            else if (monster.classname == "monster_army")
            {
                if ( r < 0.1 )
                    happy = "J.Fernandez";
                else if ( r < 0.2 )
                    happy = "C.Gordon";
                else if ( r < 0.3 )
                    happy = "A.Williams";
                else if ( r < 0.4 )
                    happy = "G.Kaine";
                else if ( r < 0.5 )
                    happy = "I.Montrov";
                else if ( r < 0.6 )
                    happy = "J.Ming";
                else if ( r < 0.7 )
                    happy = "C.Edwards";
                else if ( r < 0.8 )
                    happy = "P.Craig";
                else if ( r < 0.9 )
                    happy = "A.Harrison";
                else
                    happy = "B.Thomas";
            }
            else if (monster.classname == "monster_shambler")
            {
                if (r < 0.1)
                    happy = "Memkro";
                else if (r < 0.2)
                    happy = "Polledag";
                else if (r < 0.3)
                    happy = "Rofreg";
                else if (r < 0.4)
                    happy = "Ortrepos";
                else if (r < 0.5)
                    happy = "Northspell";
                else if (r < 0.6)
                    happy = "Saargh";
                else if (r < 0.7)
                    happy = "Lintirm";
                else if (r < 0.8)
                    happy = "Jolghor";
                else if (r < 0.9)
                    happy = "Harmiter";
                else
                    happy = "Housher";
            }
            else if (monster.classname == "monster_wizard") //- OfN -
            {
                if (r < 0.1)
                    happy = "Ranierd";
                else if (r < 0.2)
                    happy = "Flusher";
                else if (r < 0.3)
                    happy = "Bodder";
                else if (r < 0.4)
                    happy = "Moemna";
                else if (r < 0.5)
                    happy = "Ezdream";
                else if (r < 0.6)
                    happy = "Scamnar";
                else if (r < 0.7)
                    happy = "Scaler";
                else if (r < 0.8)
                    happy = "Skyflomer";
                else if (r < 0.9)
                    happy = "Xerxo";
                else 
                    happy = "Jellabe";
            }
            else if (monster.classname == "monster_fish") //- OfN -
            {
                if (r < 0.1)
                    happy = "Runidram";
                else if (r <0.2)
                    happy = "Hydrodeaz";
                else if (r <0.3)
                    happy = "Glublish";
                else if (r <0.4)
                    happy = "Ornemok";
                else if (r <0.5)
                    happy = "Idrethor";
                else if (r <0.6)
                    happy = "Vollem";
                else if (r <0.7)
                    happy = "Carlgeh";
                else if (r <0.8)
                    happy = "Glubber";
                else if (r <0.9)
                    happy = "Donelam";
                else 
                    happy = "Frindo";
            }
            else if (monster.classname == "monster_gremlin") //- OfN -
            {
                if (r < 0.1)
                    happy = "Vonatrim";//"Kokrantim";//"Oishonko";
                else if (r <0.2)
                    happy = "Ruidatrim";//"Yolio";//"Prishonko";
                else if (r <0.3)
                    happy = "Merlstrim";//"Sondramt";//"Druishonko";
                else if (r <0.4)
                    happy = "Oishtrim";//"Hafnide";//"Melrshonko";
                else if (r <0.5)
                    happy = "Qoada";//"Trontome";//"Guishonko";
                else if (r <0.6)
                    happy = "Qoatropos";//"Valemntro";//"Jelprime";
                else if (r <0.7)
                    happy = "Qoasant";//"Lusant";//"Banshoi";
                else if (r <0.8)
                    happy = "Qoashonko";//"Firsthell";//"Yulgrok";
                else if (r <0.9)
                    happy = "Qoadrine";//"Lasthell";//"Amnide";
                else 
                    happy = "Wallim";//"Hell Spawn";//"Tylogh";
            }
        }
    }

    monster.netname = happy;
};


void (float points, float type) custom_demon_create = 
{
	local float slotnum;
    slotnum = GetCurrentSoul(self);

	//Play random summoning sound here
	//r = random();
	//if (r < 0.33)
	    sound (self, #CHAN_VOICE, "ambience/thunder1.wav", 1, #ATTN_NORM);
	//else if (r < 0.66)
	//    sound (self, #CHAN_WEAPON, "boss1/sight1.wav", 1, #ATTN_NORM);
	//else
	  //  sound (self, #CHAN_WEAPON, "boss1/out1.wav", 1, #ATTN_NORM);

	makevectors (self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward) * 64;

	newmis = spawn();
	newmis.owner = newmis; //WK Self
	newmis.real_owner = self;
	
	if (type == 1)
	{
		newmis.classname = "monster_wizard";
        newmis.mdl = "progs/wizard.mdl";
	}
	else if (type == 2)
	{
		newmis.classname = "monster_fish";
        newmis.mdl = "progs/fish.mdl";        
	}
	else if (type == 3)
	{
        newmis.classname = "monster_demon1";
        newmis.mdl = "progs/demon.mdl";
	}
    else if (type == 4)
	{
		newmis.classname = "monster_gremlin";
        newmis.mdl = "progs/grem.mdl";
	}
    else if (type == 5)
	{
		newmis.classname = "monster_shambler";
        newmis.mdl = "progs/shambler.mdl";
	}
	
    newmis.team_no = self.team_no; //Go team red! ;)

    newmis.origin = self.origin + v_forward;
	newmis.has_camera = 4;
	
    newmis.increase_team1 = slotnum; //slot
    newmis.increase_team2 = GetNameType(self,newmis.increase_team1,#FALSE);
    newmis.#monster_type = type; // kind of monster

    MakeMonsterName(newmis);

	// checkarea used to be here

    setmodel (newmis, newmis.mdl);

    if ( type == 1 )
	{
        //setmodel (newmis, "progs/wizard.mdl");
        setsize (newmis, '-16 -16 -24', '16 16 40');
        setorigin (newmis, newmis.origin + '0 0 30');
	}
    else if ( type == 2 )
	{
        //setmodel (newmis, "progs/fish.mdl");
        setsize (newmis, '-16 -16 -24', '16 16 24');
		setorigin (newmis, newmis.origin + '0 0 20');
	}
	else if ( type == 3 )
	{
        //setmodel (newmis, "progs/demon.mdl");        
        setsize (newmis, #VEC_HULL2_MIN, #VEC_HULL2_MAX);	
		setorigin (newmis, newmis.origin + '0 0 30');
    }
    else if ( type == 4 )
    {
        //setmodel (newmis, "progs/grem.mdl");
		setsize (newmis, #VEC_HULL_MIN, #VEC_HULL_MAX);
		setorigin (newmis, newmis.origin + '0 0 30');
    }
    else if ( type == 5 )
    {
        //setmodel (newmis, "progs/shambler.mdl");
		setsize (newmis, #VEC_HULL2_MIN, #VEC_HULL2_MAX);
		setorigin (newmis, newmis.origin + '0 0 30');
    }

	// Gizmo - moved this after size and origin
	newmis.owner = self;
	if (!CheckArea(newmis,self)) { //No room for el diablo
		sprint(self,#PRINT_HIGH,"Not enough room to summon creature!\n");
		newmis.think = SUB_Remove;
		newmis.nextthink = time + 0.1;

		// Gizmo - don't let the initial monster be visible when spawn position is invalid
		setmodel( newmis, "" );

		// Gizmo - give back the hearts used
		local float knifekills, neededhearts;

		knifekills = GetHearts( self );
		neededhearts = GetNeededHearts( self, type );	// type should be same as input
		SetHearts( self, knifekills + neededhearts );
		return;
	}
	newmis.owner = newmis;
	
	//Test successful, so go ahead and finish summon

    newmis.skin=0;      
    
    newmis.ltime=time;
    
    local string MName;
    MName=GetMonsterName(newmis);    

    teamprefixsprint(self.team_no,self);
    teamsprint6(self,self.netname," has summoned the ", MName, " ", newmis.netname,"\n");

	//self.job = self.job | #JOB_DEMON_OUT; 
	self.job_finished = time + 3;	//Don't let em kill demon for 15 secs.
									// SB 15 is tight; 10
									// 10 is tight; 5
                                    // OfN 5 is tight; 3 ;)
    if (type==3) 
        sound (self, #CHAN_BODY, "demon/sight2.wav", 1, #ATTN_NORM);    

	newmis.velocity = v_forward * 10;// + '0 0 250';
    newmis.angles = vectoangles(newmis.velocity);

	if (newmis.flags & #FL_ONGROUND)
		newmis.flags = newmis.flags - #FL_ONGROUND;
    
    newmis.velocity = v_forward * 10;

	// Gizmo - removed '.takedamage = DAMAGE_AIM' as it causes a bug if the demon gets hurt before *monster_start_go is called
	// ... the monster start function sets .takedamage
    newmis.movetype = #MOVETYPE_TOSS;
    newmis.solid = #SOLID_SLIDEBOX;

    if (type==1) // scrags start specially
    {
        newmis.velocity='0 0 0';
        newmis.movetype = #MOVETYPE_STEP;
    }

    //if ( newmis.classname == "monster_demon1" )
    if (type == 3)
	{
		//newmis.health = #DEMON_HP; //WK 300
		newmis.armorclass = #AT_SAVEFIRE; //#AT_SAVESHOT | #AT_SAVEFIRE;
		newmis.last_saveme_sound = 0;
		newmis.has_tesla = 0; //CH determines if jello jump
		newmis.has_sentry = 0; //CH stuck jump
		newmis.th_stand = demon1_stand1;
		newmis.th_walk = demon1_walk1;
		newmis.th_run = demon1_run1;
		newmis.th_die = custom_demon_die;
		newmis.th_melee = Demon_MeleeAttack;		// one of two attacks
		newmis.th_missile = demon1_jump1;			// jump attack
		newmis.th_pain = demon1_pain;
		newmis.th_fireball = demon1_fire1; //CH
		newmis.think = walkmonster_start;
		newmis.nextthink = time + 1;
		//newmis.touch = Demon_JumpTouch;
		
        //newmis.touch = SUB_Null;

   		sprint(self, #PRINT_HIGH, "You summon a fiend.\n");
	}
	//else if ( newmis.classname == "monster_shambler" )
    else if (type == 5)
	{
		//newmis.health = #SHAMBLER_HP;//750 + points * 350; //WK 300
		newmis.armorclass = 0;// ofn- #AT_SAVEEXPLOSION | #AT_SAVEMELEE;
		newmis.last_saveme_sound = 0;
		newmis.has_tesla = points;
		newmis.has_sentry = 0;
		newmis.th_stand = sham_stand1;
		newmis.th_walk = sham_walk1;
		newmis.th_run = sham_run1;
		newmis.th_die = custom_shambler_die;
		newmis.th_melee = sham_melee;		// one of two attacks
		newmis.th_missile = sham_magic1;
		newmis.th_pain = sham_pain;
		//newmis.th_fireball = sham_fireball; //- OfN - this, uglyness apart, didn't work anyway
		newmis.think = walkmonster_start;
		newmis.nextthink = time + 1;
		//newmis.touch = Demon_JumpTouch;
		//newmis.touch = SUB_Null;
		////newmis.real_owner.demon_blood = 0; marduk bug
        //newmis.th_missile = sham_xmas1; // OfN
        newmis.demon_three = world;
		sprint(self, #PRINT_HIGH, "You summon a shambler.\n");
	}
	//else if (newmis.classname == "monster_fish")
    else if (type == 2)
    {
        //newmis.health = #FISH_HP;
	
	    newmis.th_stand = fish_stand1;
    	newmis.th_walk = fish_walk1;
    	newmis.th_run = fish_run1;
    	newmis.th_die = fish_death;
    	newmis.th_pain = fish_pain;
    	newmis.th_melee = fish_attack1;
    	newmis.nextthink = time + 0.05;
    	newmis.think = fish_toss1;
    	
        newmis.dmgtime = time + 5;

        sprint(self, #PRINT_HIGH, "You summon a piranha.\n");
        //total_monsters = total_monsters + 1;
	    //set_monster_health();
    }
    //else if (newmis.classname == "monster_wizard")
    else if (type == 1)
	{        
        //newmis.health = #SCRAG_HP;
		newmis.think =flymonster_start_go;// walkmonster_start;
        newmis.th_stand = wiz_stand1;
	    newmis.th_walk = wiz_walk1;
	    newmis.th_run = wiz_run1;
	    newmis.th_missile = Wiz_Missile;
    	newmis.th_pain = Wiz_Pain;
	    newmis.th_die = wiz_die;

        newmis.nextthink = time + 0.05;
		//newmis.armorclass = 0; //- OfN - none #AT_SAVESHOT; // kevlar
		newmis.last_saveme_sound = 0; // ? oh that
		//newmis.touch = SUB_Null;

        newmis.yaw_speed = 20;

		sprint(self, #PRINT_HIGH, "You summon a scrag.\n");
    }
    else if (type == 4)
    {
        newmis.th_stand = gremlin_main_stand;
        newmis.th_walk = gremlin_main_walk;
        newmis.th_run = gremlin_run1;
        newmis.th_die = gremlin_die;
        newmis.th_melee = Gremlin_MeleeAttack;     // one of two attacks
        newmis.th_missile = Gremlin_MissileAttack; // check for random jump or firing of weapon
        newmis.th_pain = gremlin_pain;

        newmis.think = walkmonster_start;
		newmis.nextthink = time + 1;

        sprint(self,#PRINT_HIGH,"You summon a gremlin.\n");

        //newmis.health = #GREMLIN_HP;
        newmis.yaw_speed = 35; // Original 40
    }

    newmis.touch = MonsterTouch;

    newmis.#monsterflag = #STRFLAG_MONSTER; // flag to identify monsters/army for sentry targetting

    if (slotnum == 0)
    	newmis.real_owner.demon_one = newmis;
    else if (slotnum == 1)
        newmis.real_owner.demon_two = newmis;
    else
        newmis.real_owner.demon_three = newmis;

	// Gizmo - .increase_team4 used to be right above MakeMonsterName(), moved it down here so heads aren't lost if inside wall
	newmis.increase_team4 = GetMonsterLevel(newmis);
	// Gizmo - .health used to be right above MakeMonsterName(), moved it down here so meat isn't lost if inside wall
	newmis.health = GetHPforMeat(newmis);
	newmis.max_health = newmis.health;

    newmis.penance_time = 0; // Start in standing mode

    #ifdef MONSTERS_AURA
    newmis.aura = #MONSTERS_AURA;
    #else
    newmis.aura = 0;
    #endif

    spawnFOG(newmis.origin);
    
    newmis.enemy = world;
    newmis.oldenemy = world;

    #ifdef #MONSTERS_STATE
    newmis.tfstate = #MONSTERS_STATE; //#TFSTATE_INFECTED;
    #else
    newmis.tfstate = 0;
    #endif

    newmis.is_connected = #TRUE;
    newmis.flags = newmis.flags | #FL_MONSTER;

	// for Neo mode
	if (neo && newmis.real_owner == neoLives)
		newmis.effects = newmis.effects | (#EF_BRIGHTLIGHT | #EF_BLUE);
};

void () custom_demon_precache =
{
    precache_model ("progs/demon.mdl");

	precache_model ("progs/h_demon.mdl");

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/sight2.wav");

	//precache_model ("progs/soldier.mdl");
	//precache_model ("progs/h_guard.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	/*precache_sound ("soldier/death1.wav");
	precache_sound ("soldier/idle.wav");
	precache_sound ("soldier/pain1.wav");
	precache_sound ("soldier/pain2.wav");
	precache_sound ("soldier/sattck1.wav");
	precache_sound ("soldier/sight1.wav");*/ // OfN Unused
	
    precache_model ("progs/shambler.mdl");

	precache_model ("progs/s_light.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/bolt.mdl");
	
	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("shambler/sdeath.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("shambler/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");

    #ifdef XMAS_STUFF
    precache_sound ("misc/shamxmas.wav");
    #endif

	//Also use ambience/thunder1 for out of knife
	//precache_sound ("boss1/sight1.wav"); //Out of knife - OfN unused
	//precache_sound ("boss1/out1.wav"); //Out of knife - OfN unused
	precache_sound ("boss2/sight.wav"); //Summon
//	precache_sound ("wizard/widle2.wav"); //Summon - OfN cacheed on wizard.qc
	//precache_sound ("shambler/sdeath.wav"); //Summon

    //------------------------------------//
   /* precache_model ("progs/knight.mdl");
	precache_model ("progs/h_knight.mdl");

	precache_sound ("knight/kdeath.wav");
	precache_sound ("knight/khurt.wav");
	precache_sound ("knight/ksight.wav");
	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");
	precache_sound ("knight/idle.wav");
    //----------------------------------//


    precache_model2 ("progs/hknight.mdl");
	precache_model2 ("progs/k_spike.mdl");
	precache_model2 ("progs/h_hellkn.mdl");

	
	precache_sound2 ("hknight/attack1.wav");
	precache_sound2 ("hknight/death1.wav");
	precache_sound2 ("hknight/pain1.wav");
	precache_sound2 ("hknight/sight1.wav");
	precache_sound ("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound2 ("hknight/slash1.wav");
	precache_sound2 ("hknight/idle.wav");
	precache_sound2 ("hknight/grunt.wav");

	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");*/

};

/*void () kill_my_demons;

void (entity player) kill_his_demons = 
{
   if (player.classname!="player") return;
   
   local entity temp;

   temp=self;

   self=player;
   kill_my_demons();

   self=temp;
};*/


void () kill_my_demons = 
{
	/*local entity te;
	local entity oself;
	//WK Clean up demons
	te = find(world, classname, "monster_demon1");
	while (te)
	{
		if (te.real_owner == self) {
			oself = self;
			self = te;
			
            //Must get... blood....
			ThrowMonsterHead ("progs/h_demon.mdl", -90);
			ThrowGib ("progs/gib1.mdl", -10);
            ThrowGib ("progs/gib2.mdl", -70);
            ThrowGib ("progs/gib3.mdl", -80);
            
			sound (self, #CHAN_VOICE, "demon/ddeath.wav", 1, #ATTN_NORM);
			self = oself;
			te.think = SUB_Remove;
			te.touch = SUB_Null;
			te.nextthink = time + 0.1;

			sprint(self, #PRINT_HIGH, "Your fiend ");
            sprint (self, #PRINT_HIGH, te.netname);
            sprint (self, #PRINT_HIGH, " is dead.\n");
			self.job = self.job - (self.job & #JOB_DEMON_OUT);
		}

		te = find(te, classname, "monster_demon1");
	}
	
	te = find(world, classname, "monster_army");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
			self.health = -100;
			//Must get... blood....
			ThrowMonsterHead ("progs/h_guard.mdl", -90);
			ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib2.mdl", -70);
            ThrowGib ("progs/gib3.mdl", -70);
            ThrowGib ("progs/gib2.mdl", -70);
			sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
//			custom_grunt_die;
			te.think = SUB_Remove;
			te.touch = SUB_Null;
			te.nextthink = time + 0.1;

            // Remove any waypoints
            if (self.martyr_enemy != world)
            #ifdef ARMY_DEBUG
            RemoveWaypoint(self.martyr_enemy, "KillMyDemon() martyr", self);
            #else
            RemoveWaypoint(self.martyr_enemy, self);
            #endif
            
            if (self.demon_one != world)
            #ifdef ARMY_DEBUG
            RemoveWaypoint(self.demon_one, "KillMyDemon() demon_one", self);
            #else
            RemoveWaypoint(self.demon_one, self);
            #endif
            
            if (self.demon_two != world)            
            #ifdef ARMY_DEBUG
            RemoveWaypoint(self.demon_two, "KillMyDemon() demon_two", self);
            #else
            RemoveWaypoint(self.demon_two, self);
            #endif

			self = oself;
            
            sprint (self, #PRINT_HIGH, "Your soldier ");
            sprint (self, #PRINT_HIGH, te.netname);
            sprint (self, #PRINT_HIGH, " is dead.\n");
			
            //SetArmyTimer(warlock);
		}

		te = find(te, classname, "monster_army");
	}
    
    
    te = find(world, classname, "monster_shambler");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
			ThrowMonsterHead ("progs/h_shams.mdl", -90);
			ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib3.mdl", -30);
			ThrowGib ("progs/gib3.mdl", -70);
			sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
			te.think = SUB_Remove;
			te.touch = SUB_Null;
			te.nextthink = time + 0.1;
			self = oself;

			sprint (self, #PRINT_HIGH, "Your shambler ");
            sprint (self, #PRINT_HIGH, te.netname);
            sprint (self, #PRINT_HIGH, " is dead.\n");
		}
		te = find(te, classname, "monster_shambler");
	}

    
    te = find(world, classname, "monster_wizard");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
			ThrowMonsterHead ("progs/h_wizard.mdl", -90);
			ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib3.mdl", -30);
			ThrowGib ("progs/gib3.mdl", -70);
			sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
			te.think = SUB_Remove;
			te.touch = SUB_Null;
			te.nextthink = time + 0.1;
			self = oself;

			sprint (self, #PRINT_HIGH, "Your scrag ");
            sprint (self, #PRINT_HIGH, te.netname);
            sprint (self, #PRINT_HIGH, " is dead.\n");
		}
		te = find(te, classname, "monster_wizard");
	}   

    te = find(world, classname, "monster_fish");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
			//ThrowGib ("progs/gib1.mdl", -10);
			ThrowGib ("progs/gib2.mdl", -20);
			ThrowGib ("progs/gib3.mdl", -40);
			sound (self, #CHAN_VOICE, "fish/death.wav", 1, #ATTN_NORM);
			te.think = SUB_Remove;
			te.touch = SUB_Null;
			te.nextthink = time + 0.1;
			self = oself;

			sprint (self, #PRINT_HIGH, "Your piranha ");
   			sprint (self, #PRINT_HIGH, te.netname);
            sprint (self, #PRINT_HIGH, " is dead.\n");
		}
		te = find(te, classname, "monster_fish");
	}   

    te = find(world, classname, "monster_gremlin");
	
	while (te)
	{
		if (te.real_owner == self)
		{
			oself = self;
			self = te;
            ThrowMonsterHead ("progs/h_grem.mdl", -80);
			ThrowGib ("progs/gib1.mdl", -30);
			ThrowGib ("progs/gib2.mdl", -35);
			ThrowGib ("progs/gib3.mdl", -40);
			sound (self, #CHAN_VOICE, "grem/death.wav", 1, #ATTN_NORM);
			te.think = SUB_Remove;
			te.touch = SUB_Null;
			te.nextthink = time + 0.1;
			self = oself;

			sprint (self, #PRINT_HIGH, "Your gremlin ");
			sprint (self, #PRINT_HIGH, te.netname);
            sprint (self, #PRINT_HIGH, " is dead.\n");
		}
		te = find(te, classname, "monster_gremlin");
	}   

    self.job = self.job - (self.job & #JOB_DEMON_OUT);
    self.demon_one = world;
    self.demon_two = world;
    self.demon_three = world;*/

    KillSoul(self,0);
    KillSoul(self,1);
    KillSoul(self,2);
};

//=================================================================
// Monsters touch function (infection from them is handled here)

void() MonsterTouch =
{
    if (self.health <= 0) // If we r dead, go away
        return;

    local entity Bio;
	local string tmps;

    if (self.tfstate & #TFSTATE_INFECTED)
    {
        if (other.classname == "player")
        {
            if (!(other.invincible_finished > time)) // Dont infect if we r invincible
            if (!(other.weapons_carried & #WEAP_MEDIKIT)) // neither if we got medikit
            if (!(other.tfstate & #TFSTATE_INFECTED)) // Dont if we r already infected
            if (other.is_connected)
            if (other.health > 0) // alive?
            if (!(other.done_custom & #CUSTOM_BUILDING)) // ppl customizing
            if (other.playerclass != #PC_UNDEFINED) // observers
            {
                // infect 'em
                Bio = spawn ();
                Bio.nextthink = time + 2;
                Bio.think = BioInfection_Decay;
                Bio.enemy = self; //Person causing infection
                Bio.owner = other; //Person getting hurt
                Bio.classname = "timer";
                Bio.netname = "biotimer";

                other.tfstate = other.tfstate | #TFSTATE_INFECTED;
                other.infection_team_no = self.infection_team_no;

                tmps = GetMonsterName(self);

                sprint(other, #PRINT_MEDIUM, "You have been infected by the ");
                sprint(other, #PRINT_MEDIUM, tmps);
                sprint(other, #PRINT_MEDIUM, " ");
                sprint(other, #PRINT_MEDIUM, self.netname);
                sprint(other, #PRINT_MEDIUM, "!\n");

                teamprefixsprint(other.team_no,other);
                teamsprint(other.team_no,other, other.netname);
                teamsprint(other.team_no,other, " has been infected!\n");
            }
        }
        else if (IsOwnedMonster(other))
        {
            if (!(other.tfstate & #TFSTATE_INFECTED))
            {
                // Report to owner
                tmps = GetMonsterName(other);
                sprint(other.real_owner,#PRINT_HIGH,"Your ",tmps," ",other.netname," has been infected!\n");

                // Report to teammates of owner
                tmps = GetMonsterName(other);
                teamprefixsprint(other.real_owner.team_no,other.real_owner);
                teamsprint6(other.real_owner,"The ",tmps," ", other.netname," has been infected!\n","");

                // Update infection flag
                other.tfstate = other.tfstate | #TFSTATE_INFECTED;

                // Infect it!
                Bio = spawn ();
                Bio.classname = "timer";
                Bio.classname = "biotimer";
                Bio.nextthink = time + 2;
                Bio.think = BioInfection_MonsterDecay;
                Bio.owner = self;
                Bio.enemy = other;

                other.infection_team_no = self.infection_team_no;
            }
        }
#ifdef COOP_MODE_ENHANCED
		else if ( COOP_IsCoopMonster( other ) ) {
			if (!(other.tfstate & #TFSTATE_INFECTED))
			{
				// Update infection flag
				other.tfstate = other.tfstate | #TFSTATE_INFECTED;

				// Infect it!
				Bio = spawn ();
				Bio.classname = "timer";
				Bio.classname = "biotimer";
				Bio.nextthink = time + 2;
				Bio.think = BioInfection_MonsterDecay;
				Bio.owner = self;
				Bio.enemy = other;

				other.infection_team_no = self.infection_team_no;
			}
		}
#endif
    }
};

//=========================================================================
// The following is used to "route" any monster to appropiate animation

void (entity themonster) PutMonsterStand =
{
    if (themonster.classname=="monster_shambler")
        themonster.think=sham_stand1;
    else if (themonster.classname=="monster_demon1")
        themonster.think=demon1_stand1;
    else if (themonster.classname=="monster_wizard")
        themonster.think=wiz_stand1;     
    else if (themonster.classname=="monster_fish")
        themonster.think=fish_stand1;     
    else if (themonster.classname=="monster_gremlin")
        themonster.think=gremlin_main_stand;
};

void (entity themonster) PutMonsterWalk =
{
    if (themonster.classname=="monster_shambler")
        themonster.think=sham_walk1;
    else if (themonster.classname=="monster_demon1")
        themonster.think=demon1_walk1;
    else if (themonster.classname=="monster_wizard")
        themonster.think=wiz_walk1;  
    else if (themonster.classname=="monster_fish")
        themonster.think=fish_walk1;  
    else if (themonster.classname=="monster_gremlin")
        themonster.think=gremlin_main_walk;
};

//=====================================================
// Called for any monster when it goes to idle state

void (entity themonster) MonsterIdle =
{
    if (themonster.health <= 0) return;

    if (themonster.penance_time == 0) // Stand
    {
        themonster.enemy=world;
        themonster.oldenemy=world;
        themonster.goalentity=world;
        themonster.nextthink=time+0.1;
        
        PutMonsterStand(themonster);
    }
    else if (themonster.penance_time == 1) // Follow owner
    {
        themonster.enemy=world;
        themonster.oldenemy=world;
        themonster.goalentity=themonster.real_owner;
        themonster.nextthink=time+0.1;

        PutMonsterWalk(themonster);
    }
    else if (themonster.penance_time == 2) // Patrol
    {
        themonster.enemy=world;
        themonster.oldenemy=world;
        themonster.goalentity=themonster;
        themonster.nextthink=time+0.1;
        
        PutMonsterWalk(themonster);
    }
};

//==============================================
// Put the stuff into the appropiate bytes

void(entity player, float knifekills) SetHearts =
{
    if (knifekills > 60) // upto 63 (6 bits value) WARNING: we pad this value string to 2 chars
        knifekills = 60;
    player.demon_blood = AssignWarlock1(player.demon_blood,knifekills);
};

void(entity player, float numgibs) SetMeat =
{
    if (numgibs > 950) // 10 bits value so we can set this upto 1023 WARNING: we pad this value string to 3 chars (so should be 999 max)
        numgibs = 950;
    player.demon_blood = AssignWarlock2(player.demon_blood,numgibs);
};

void(entity player, float numheads) SetHeads =
{
    if (numheads > 250) // 8 bits (upto 255)
        numheads = 250;
    player.demon_blood = AssignByte3(player.demon_blood,numheads);
};

void(entity player, float soul) SetCurrentSoul =
{
    player.g_e = AssignByte1(player.g_e,soul);
};

void(entity player, float usage) SetMeatUsage =
{
    player.g_e = AssignByte2(player.g_e,usage);
};

void(entity player, float usage) SetHeadsUsage =
{
    player.g_e = AssignByte3(player.g_e,usage);
};

//====================================================
// Retrieval of the stuff from the appropiate bytes

float(entity player) GetHearts =
{
    return GetWarlock1(player.demon_blood);
};

float(entity player) GetMeat =
{
    return GetWarlock2(player.demon_blood);
};

float(entity player) GetHeads =
{
    return GetByte3(player.demon_blood);
};

float(entity player) GetCurrentSoul =
{
    return GetByte1(player.g_e);
};

float(entity player) GetMeatUsage =
{
    return GetByte2(player.g_e);
};

float(entity player) GetHeadsUsage =
{
    return GetByte3(player.g_e);
};

//===============================================
// Gets the number of summons a warlock has

float(entity warlock) GetNumSummons =
{
    local float res;
    res = 0;

    if (warlock.demon_one)
        res = 1;

    if (warlock.demon_two)
        res = res + 1;
    
    if (warlock.demon_three)
        res = res + 1;
    
    return res;
};

//=============================================
// Gets pointer to the specified summon

entity(entity warlock, float numsummon) GetSummon =
{
    if (numsummon == 0)
        return warlock.demon_one;
    if (numsummon == 1)
        return warlock.demon_two;
    if (numsummon == 2)
        return warlock.demon_three;

    return world;
};

//=====================================================
// Gets number of given monster kind a player has

float(entity player, float type) GetNumTypeMonster =
{
    local float res;
    res = 0;

    if (player.demon_one)
    if (player.demon_one.#monster_type == type)
        res = 1;

    if (player.demon_two)
    if (player.demon_two.#monster_type == type)
        res = res +1;

    if (player.demon_three)
    if (player.demon_three.#monster_type == type)
        res = res +1;
    
    return res;
};

//===============================================
// Gibs picking up sound

void(entity warlock) GibPickSound =
{
    sound(warlock,#CHAN_AUTO,"gibs/gibpick.wav",1,#ATTN_IDLE);
};

//=====================================================================
// We killed someone with knife, so give us a heart (if we are a warlock)

void (entity attacker) WarlockKnifeKill =
{
	local float extras;

    if (attacker.job & #JOB_WARLOCK)
    {
        local float numhearts;
        numhearts = GetHearts(attacker);
        SetHearts(attacker,numhearts +1);

        sprint(attacker,#PRINT_HIGH,"You get a fresh living heart!\n");

        if (extras_mode == 2)
            return;

        attacker.dont_do_triggerwork = attacker.dont_do_triggerwork + 1;
        numhearts = attacker.dont_do_triggerwork;

        if (numhearts == #WARLOCK_BONUS1)
        {
            bprint(#PRINT_HIGH,attacker.netname);
            bprint(#PRINT_HIGH," has collected #WARLOCK_BONUS1 hearts!\n");

            extras = GetJobExtras(attacker);

            if (extras == 0)
            {
                sprint(attacker, #PRINT_HIGH, "Your warlock skills have been improved!\n");
                SetJobExtras(attacker,1);
                return;
            }
            else if (extras == 1)
            {
                sprint(attacker, #PRINT_HIGH, "Your warlock skills have been maxed out!\n");
                SetJobExtras(attacker,2);
                return;
            }
        }

        if (numhearts == #WARLOCK_BONUS2)
        {
            bprint(#PRINT_HIGH,attacker.netname);
            bprint(#PRINT_HIGH," has collected #WARLOCK_BONUS2 hearts!!\n");

            extras = GetJobExtras(attacker);

            if (extras == 0) // this only would happen by toggling extras_mode but..
            {
                sprint(attacker, #PRINT_HIGH, "Your warlock skills have been improved!\n");
                SetJobExtras(attacker,1);
                return;
            }
            else if (extras == 1)
            {
                sprint(attacker, #PRINT_HIGH, "Your warlock skills have been maxed out!\n");
                SetJobExtras(attacker,2);
                return;
            }
        }
    }
};

//================================================================
// Returns 0 = no heads when summoned, 1 = maxed out

float(entity monster) GetMonsterLevel =
{
    local float level, type, heads, headsusage, headsused;
    
    type = monster.#monster_type;
    heads = GetHeads(monster.real_owner);
    headsusage = GetHeadsUsage(monster.real_owner);

    // Apply usage setting
    headsused = rint((heads/100)*(headsusage*25));

    level = 0;
    
    if (type == #MONSTER_SHAMBLER)
    {
        if (headsused > #SHAMBLER_MAX_HEADS)
        {
            headsused = #SHAMBLER_MAX_HEADS;
            level = 1;
        }
        else
            level = headsused/#SHAMBLER_MAX_HEADS;
    }
    else if (type == #MONSTER_GREMLIN)
    {
        if (headsused > #GREMLIN_MAX_HEADS)
        {
            headsused = #GREMLIN_MAX_HEADS;
            level = 1;
        }
        else
            level = headsused/#GREMLIN_MAX_HEADS;
    }
    else if (type == #MONSTER_DEMON)
    {
        if (headsused > #DEMON_MAX_HEADS)
        {
            headsused = #DEMON_MAX_HEADS;
            level = 1;
        }
        else
            level = headsused/#DEMON_MAX_HEADS;
    }
    else if (type == #MONSTER_SCRAG)
    {
        if (headsused > #SCRAG_MAX_HEADS)
        {
            headsused = #SCRAG_MAX_HEADS;
            level = 1;
        }
        else
            level = headsused/#SCRAG_MAX_HEADS;
    }
    else if (type == #MONSTER_FISH)
    {
        if (headsused > #FISH_MAX_HEADS)
        {
            headsused = #FISH_MAX_HEADS;
            level = 1;
        }
        else
            level = headsused/#FISH_MAX_HEADS;
    }

    // Decrease our used heads ammount
    SetHeads(monster.real_owner,heads - headsused);

    return level;
};

//================================================================
// Get max hp for the given monster kind and kgs of meat

float(entity monster) GetHPforMeat =
{
    local float hp, type, meatkgs, meatusage, meatused;
    
    type = monster.#monster_type;
    meatkgs = GetMeat(monster.real_owner);
    meatusage = GetMeatUsage(monster.real_owner);
    
    // Apply usage setting
    meatused = rint((meatkgs/100)*(meatusage*25));

    if (type == #MONSTER_SHAMBLER)
    {
        if (meatused > #SHAMBLER_MAX_MEAT)
        {
            hp = #SHAMBLER_MAX_HP;
            meatused = #SHAMBLER_MAX_MEAT;
        }
        else
            hp = rint(#SHAMBLER_MIN_HP + ((#SHAMBLER_MAX_HP - #SHAMBLER_MIN_HP)*(meatused/#SHAMBLER_MAX_MEAT)));
    }
    else if (type == #MONSTER_GREMLIN)
    {
        if (meatused > #GREMLIN_MAX_MEAT)
        {
            hp = #GREMLIN_MAX_HP;
            meatused = #GREMLIN_MAX_MEAT;
        }
        else
            hp = rint(#GREMLIN_MIN_HP + ((#GREMLIN_MAX_HP - #GREMLIN_MIN_HP)*(meatused/#GREMLIN_MAX_MEAT)));
    }
    else if (type == #MONSTER_DEMON)
    {
        if (meatused > #DEMON_MAX_MEAT)
        {
            hp = #DEMON_MAX_HP;
            meatused = #DEMON_MAX_MEAT;
        }
        else
            hp = rint(#DEMON_MIN_HP + ((#DEMON_MAX_HP - #DEMON_MIN_HP)*(meatused/#DEMON_MAX_MEAT)));
    }
    else if (type == #MONSTER_SCRAG)
    {
        if (meatused > #SCRAG_MAX_MEAT)
        {
            hp = #SCRAG_MAX_HP;
            meatused = #SCRAG_MAX_MEAT;
        }
        else
            hp = rint(#SCRAG_MIN_HP + ((#SCRAG_MAX_HP - #SCRAG_MIN_HP)*(meatused/#SCRAG_MAX_MEAT)));
    }
//    else if (type == #MONSTER_FISH)
	else
    {
        if (meatused > #FISH_MAX_MEAT)
        {
            hp = #FISH_MAX_HP;
            meatused = #FISH_MAX_MEAT;
        }
        else
            hp = rint(#FISH_MIN_HP + ((#FISH_MAX_HP - #FISH_MIN_HP)*(meatused/#FISH_MAX_MEAT)));
    }

    // Decrease our used meat ammount
    SetMeat(monster.real_owner,meatkgs - meatused);

    return hp;
};

//=================================================================
// Touch function for monster heads

void() monster_head_touch =
{
    if (self.velocity == '0 0 0') // stoped?
    {
        self.avelocity = '0 0 0';
        #ifdef KICKABLE_HEADS
        self.t_width = #TRUE;
        #endif
    }
    
    if (other.classname == "player")
    {
        if (other.health <= 0)
            return;

        if (other.playerclass == #PC_UNDEFINED) // Skip Observers
            return;

        if (other.done_custom & #CUSTOM_BUILDING) // ppl customizing
            return;

        if (other.job & #JOB_WARLOCK) // Warlock collects this head
        #ifndef WARLOCK_TEST
        if (!Teammate(other,self)) // Only enemy heads can be picked up
        #endif    
        {
            self.modelindex = modelindex_null;
            self.touch = SUB_Null;
            self.solid = #SOLID_NOT;

            sprint(other,#PRINT_HIGH,"You pick up a");

            if (self.increase_team1 == #MONSTER_SHAMBLER)
                sprint(other,#PRINT_HIGH," shambler");
            else if (self.increase_team1 == #MONSTER_GREMLIN)
                sprint(other,#PRINT_HIGH," gremlin");
            else if (self.increase_team1 == #MONSTER_DEMON)
                sprint(other,#PRINT_HIGH," fiend");
            else if (self.increase_team1 == #MONSTER_SCRAG)
                sprint(other,#PRINT_HIGH," scrag");
            else if (self.increase_team1 == #MONSTER_FISH)
                sprint(other,#PRINT_HIGH," piranha");
            else if (self.increase_team1 == #MONSTER_ARMY)            
                sprint(other,#PRINT_HIGH,"n army soldier");
            else sprint(other,#PRINT_HIGH," monster"); // default, shouldnt be used anyway

            sprint(other,#PRINT_HIGH," head\n");
            
            GibPickSound(other);
            stuffcmd(other,"bf\n");

            local float numheads;
            numheads = GetHeads(other);
            SetHeads(other,numheads+1);

            dremove(self);
            return;
        }

        #ifdef KICKABLE_HEADS
        if (!kickable_heads)
            return;

        if (!self.t_width)
            return;
        
        if (self.oldenemy == other) // we are the last person that kicked this head
            if (self.t_length + #KICKHEAD_RATE_PERUSER > time) // too early for him?
                return;
        
        if (self.t_length + #KICKHEAD_RATE > time) // too early?
            return; // ok, do nothing, dont bounce or anything

        if (other.velocity == '0 0 0') // Dont kick if the player is not moving
            return;

        //ok, kick it out
        self.oldenemy = other;
        self.t_length = time;
        makevectors (other.v_angle);
        self.velocity = other.velocity * 1.5 + v_forward * 128 + '0 0 260' + '0 0 300'*random();  
        self.flags = self.flags - (self.flags & #FL_ONGROUND);
    	
        self.avelocity = crandom() * '0 600 0';

        sound(self,#CHAN_BODY,"zombie/z_miss.wav",0.5, #ATTN_IDLE);
        #endif
    }
};

//================================================================
// Throws a monster head

void(string gibname, float dm) ThrowMonsterHead =
{
    newmis = spawn();
	newmis.origin = self.origin;
	setmodel (newmis, gibname);
	setsize (newmis, '-4 -4 0', '4 4 8');

	newmis.velocity = VelocityForDamage (dm);
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_TRIGGER;
    newmis.avelocity = crandom() * '0 600 0';
	newmis.think = SUB_Remove;
	newmis.ltime = time;
#ifdef COOP_MODE_ENHANCED
	local float r;

	if ( self.endtime > 0 && COOP_IsCoopMonster( self ) ) {
		r = random();
		if ( r < 0.5 )
			r = 0.5 + random()*0.5;

		newmis.nextthink = time + self.endtime*r;
	} else
#endif
	newmis.nextthink = time + #MIN_HEAD_TIME + (#MAX_HEAD_TIME - #MIN_HEAD_TIME)*random();
	newmis.frame = 0;
	newmis.flags = 0;

    newmis.touch = monster_head_touch;
    
    newmis.team_no = self.team_no;
    newmis.increase_team1 = self.#monster_type; // to determine picking up text

    #ifdef COOL_GIBS
    newmis.classname = "monster_head";
    newmis.#coolflag = #STRFLAG_COOL;
    #endif

    #ifdef KICKABLE_HEADS
    newmis.t_width = #FALSE;
    newmis.oldenemy = world;
    newmis.t_length = time;
    #endif
};

//====================================================
// Returns the needed hearts to summon something

float(entity warlock, float input) GetNeededHearts =
{
    #ifdef WARLOCK_TEST
    return 0;
    #endif

    local float numsummons;
    numsummons = GetNumSummons(warlock);

    if (numsummons == 0)
    {
        if (input == 3) // fiend
            return 2;
        if (input == 4) // gremlin
            return 3;
        if (input == 5) // shambler
            return 5;
        
        return 0; // scrag and piranha (no needed hearts)
    }
    else if (numsummons == 1)
    {
        if (input == 1 || input == 2) // scrag and piranha
            return 1;
        if (input == 3) // fiend
            return 4;
        if (input == 4) // gremlin
            return 6;
        if (input == 5) // shambler
            return 10;
    }
    else 
    {
        if (input == 1 || input == 2) // scrag and piranha
            return 2;
        if (input == 3) // fiend
            return 6;
        if (input == 4) // gremlin
            return 9;
        if (input == 5) // shambler
            return 15;
    }

    return 255; // Punishment for bug generator :)
};

//=====================================================
// function to kill specific souls

void(entity warlock, float soulnum) KillSoul =
{
    local float doclean;
    local entity soul, oself;
    soul = GetSummon(warlock, soulnum);

    doclean = #FALSE;

    if (soul) // existing thing
    if (soul.real_owner == warlock) // and its ours
    {
        oself = self;
        self = soul;            

        if (soul.classname == "monster_demon1")
        {
			soul.health = -100;

            ThrowMonsterHead ("progs/h_demon.mdl", -90);
			ThrowGib ("progs/gib1.mdl", -10,#TRUE,0,#GIB1_KGS, #FALSE);
            ThrowGib ("progs/gib2.mdl", -70,#TRUE,0,#GIB2_KGS, #FALSE);
            ThrowGib ("progs/gib3.mdl", -80,#TRUE,0,#GIB3_KGS, 0.2);
            SpawnBloodEx(self.origin,0.66,9);
            
			sound (soul, #CHAN_VOICE, "demon/ddeath.wav", 1, #ATTN_NORM);

            soul.think = SUB_Remove;
			soul.touch = SUB_Null;
			soul.nextthink = time + 0.05;

			sprint(warlock, #PRINT_HIGH, "Your fiend ");
            sprint (warlock, #PRINT_HIGH, soul.netname);
            sprint (warlock, #PRINT_HIGH, " is dead.\n");

            doclean = #TRUE;
        }
        else if (soul.classname == "monster_shambler")
        {
            soul.health = -100;

            ThrowMonsterHead ("progs/h_shams.mdl", -90);
            ThrowGib ("progs/gib1.mdl", -10,#TRUE,0,#GIB1_KGS, #FALSE);
            ThrowGib ("progs/gib3.mdl", -30,#TRUE,0,#GIB3_KGS, 0.33);
            ThrowGib ("progs/gib2.mdl", -40,#TRUE,0,#GIB2_KGS, #FALSE);
            ThrowGib ("progs/gib3.mdl", -70,#TRUE,0,#GIB3_KGS, 0.66);
            SpawnBloodEx(self.origin,0.66,9);
            
            sound (soul, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);

            if (soul.demon_three != world)
                dremove(soul.demon_three);
            
            soul.demon_three = world;
            
            soul.think = SUB_Remove;
            soul.touch = SUB_Null;
            soul.nextthink = time + 0.05;
            
            sprint (warlock, #PRINT_HIGH, "Your shambler ");
            sprint (warlock, #PRINT_HIGH, soul.netname);
            sprint (warlock, #PRINT_HIGH, " is dead.\n");

            doclean = #TRUE;
        }
        else if (soul.classname == "monster_wizard")
        {
            soul.health = -100;
            
            ThrowMonsterHead ("progs/h_wizard.mdl", -90);
			ThrowGib ("progs/gib2.mdl", -10,#TRUE,0,#GIB2_KGS, #FALSE);
			ThrowGib ("progs/gib3.mdl", -30,#TRUE,0,#GIB3_KGS, #FALSE);
			ThrowGib ("progs/gib3.mdl", -70,#TRUE,0,#GIB3_KGS, 0.25);
            SpawnBloodEx(self.origin,0.66,9);
			
            sound (soul, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
			
            soul.think = SUB_Remove;
			soul.touch = SUB_Null;
			soul.nextthink = time + 0.05;			

			sprint (warlock, #PRINT_HIGH, "Your scrag ");
            sprint (warlock, #PRINT_HIGH, soul.netname);
            sprint (warlock, #PRINT_HIGH, " is dead.\n");

            doclean = #TRUE;
        }
        else if (soul.classname == "monster_army")
        {
            soul.health = -100;
            
            ThrowMonsterHead ("progs/h_player.mdl", -90);
			ThrowGib ("progs/gib1.mdl", -10,#TRUE,0,#GIB1_KGS, #FALSE);
			ThrowGib ("progs/gib2.mdl", -30,#TRUE,0,#GIB2_KGS, #FALSE);
            ThrowGib ("progs/gib3.mdl", -40,#TRUE,0,#GIB3_KGS, 0.33);
            ThrowGib ("progs/gib3.mdl", -50,#TRUE,0,#GIB3_KGS, 0.66);
            SpawnBloodEx(self.origin,0.66,9);
			sound (soul, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);

            soul.think = SUB_Remove;
			soul.touch = SUB_Null;
			soul.nextthink = time + 0.05;

            // Remove any waypoints
            if (soul.martyr_enemy != world)
                RemoveWaypoint(soul.martyr_enemy, soul);
            
            if (soul.demon_one != world)
                RemoveWaypoint(soul.demon_one, soul);
            
            if (soul.demon_two != world)            
                RemoveWaypoint(soul.demon_two, soul);
            
            sprint (warlock, #PRINT_HIGH, "Your soldier ");
            sprint (warlock, #PRINT_HIGH, soul.netname);
            sprint (warlock, #PRINT_HIGH, " is dead.\n");
			
            // We need to reset the pointer on player before calling UpdateReserves()
            ResetSlotPointer(warlock,soul.increase_team1);

            UpdateReserves(warlock);
            SetArmyTimer(warlock, #FALSE);

            // No clean-up of pointer (already done ^ on ResetSlotPointer() so doclean = #FALSE)
            doclean = #FALSE;
        }
        else if (soul.classname == "monster_fish")
        {
            soul.health = -100;
            
            ThrowGib ("progs/gib2.mdl", -20,#TRUE,0,#GIB2_KGS, #FALSE);
			ThrowGib ("progs/gib3.mdl", -40,#TRUE,0,#GIB3_KGS, #FALSE);
            SpawnBloodEx(self.origin,0.66,9);
			
            sound (soul, #CHAN_VOICE, "fish/death.wav", 1, #ATTN_NORM);
			
            soul.think = SUB_Remove;
			soul.touch = SUB_Null;
			soul.nextthink = time + 0.05;

			sprint (warlock, #PRINT_HIGH, "Your piranha ");
   			sprint (warlock, #PRINT_HIGH, soul.netname);
            sprint (warlock, #PRINT_HIGH, " is dead.\n");

            doclean = #TRUE;
        }
        else if (soul.classname == "monster_gremlin")
        {
            soul.health = -100;
            
            ThrowMonsterHead ("progs/h_grem.mdl", -80);
			ThrowGib ("progs/gib1.mdl", -30,#TRUE,0,#GIB1_KGS, #FALSE);
			ThrowGib ("progs/gib2.mdl", -35,#TRUE,0,#GIB2_KGS, #FALSE);
			ThrowGib ("progs/gib3.mdl", -40,#TRUE,0,#GIB3_KGS, 0.5);
            SpawnBloodEx(self.origin,0.66,9);
			
            sound (soul, #CHAN_VOICE, "grem/death.wav", 1, #ATTN_NORM);
			
            soul.think = SUB_Remove;
			soul.touch = SUB_Null;
			soul.nextthink = time + 0.05;

			sprint (warlock, #PRINT_HIGH, "Your gremlin ");
			sprint (warlock, #PRINT_HIGH, soul.netname);
            sprint (warlock, #PRINT_HIGH, " is dead.\n");

            doclean = #TRUE;
        }

        self = oself;

        // Cleaning up of the appropiate pointer (only if needed)
        if (doclean)
            ResetSlotPointer(warlock,soul.increase_team1);
    }
};

//==========================================================================
// Called on every monster death, resets the appropiate pointer on player

void(entity player, float slot) ResetSlotPointer =
{
    if (slot == 0)
        player.demon_one = world;
    else if (slot == 1)
        player.demon_two = world;
    else if (slot == 2)
        player.demon_three = world;
};

//============================================================================
// Called on AI_Check_Contents to perform regeneration when needed

float(entity ai_entity) AI_Regenerate =
{
    local float heal, rate;
    heal = 3;
    rate = 1.5;

    if (ai_entity.#monster_type == #MONSTER_SHAMBLER)
    {
        heal = #SHAMBLER_MAXREGEN * ai_entity.#monster_level;
        rate = #SHAMBLER_REGENRATE;
    }
    else if (ai_entity.#monster_type == #MONSTER_SCRAG)
    {
        heal = #SCRAG_MAXREGEN * ai_entity.#monster_level;
        rate = #SCRAG_REGENRATE;
    }
    else if (ai_entity.#monster_type == #MONSTER_DEMON)
    {
        heal = #FIEND_MAXREGEN * ai_entity.#monster_level;
        rate = #FIEND_REGENRATE;
    }
    else if (ai_entity.#monster_type == #MONSTER_FISH)
    {
        heal = #FISH_MAXREGEN * ai_entity.#monster_level;
        rate = #FISH_REGENRATE;
    }
    else if (ai_entity.#monster_type == #MONSTER_GREMLIN)
    {
        heal = #GREMLIN_MAXREGEN * ai_entity.#monster_level;
        rate = #GREMLIN_REGENRATE;
    }
    else if (ai_entity.#monster_type == #MONSTER_ARMY)
    {    
        heal = #AURA_ARMY_REGEN;
        rate = #AURA_ARMY_REGENRATE;
    }

    if (ai_entity.aura == #AURA_REGEN && ai_entity.#monster_type != #MONSTER_ARMY)
        heal = heal * #AURA_MONSTER_REGEN_FACTOR;

    ai_entity.dmgtime = time + rate;
    ai_entity.health = ai_entity.health + heal;
    
    if (ai_entity.health > ai_entity.max_health)
        ai_entity.health = ai_entity.max_health;
};

//============================================================================

/*
==============
Summon_GetActionString

printDest can be world.
==============
*/
string( entity printDest, entity se ) Summon_GetActionString = {
	if ( se.#summon_mode == #SUMMON_MODE_HOLDPOSITION )
		return "holding position";
	if ( se.#summon_mode == #SUMMON_MODE_FOLLOWOWNER ) {
		if ( printDest == se.real_owner )
			return "following you";
		return "following it's owner";
	}
	return "patroling the zone";
};

/*
==============
Summon_PrintDetails

Prints details about a summon/demon.
All functions that print details about a summon should
use this function to keep everything contained.
==============
*/
void( entity printDest, entity se ) Summon_PrintDetails = {
	local string	st;

	st = GetMonsterName( se );
	st = colstr( st, #COLSTR_RED );
	if ( printDest == se.real_owner )
		sprint( printDest, #PRINT_HIGH, "Your ", st, " ", se.netname, " has " );
	else
		sprint( printDest, #PRINT_HIGH, "The ", st, " ", se.netname, " has " );
	st = ftos( se.health );
	sprint( printDest, #PRINT_HIGH, st, "Ø" );
	st = ftos( se.max_health );
	sprint( printDest, #PRINT_HIGH, st, " ËÂ·ÏÙË, and is " );

	if ( se.enemy != world ) {
		st = GetEnemyName( se.enemy );
		sprint( printDest, #PRINT_HIGH, "·ÙÙ·„ÎÈÓÁ ", st, "\n" );
	} else {
		st = Summon_GetActionString( printDest, se );
		sprint( printDest, #PRINT_HIGH, st, "\n" );
	}
};
