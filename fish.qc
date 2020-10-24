$cd id1/models/fish
$origin 0 0 24
$base base		
$skin skin

$frame attack1 attack2 attack3 attack4 attack5 attack6 
$frame attack7 attack8 attack9 attack10 attack11 attack12 attack13 
$frame attack14 attack15 attack16 attack17 attack18 

$frame death1 death2 death3 death4 death5 death6 death7 
$frame death8 death9 death10 death11 death12 death13 death14 death15 
$frame death16 death17 death18 death19 death20 death21 

$frame swim1 swim2 swim3 swim4 swim5 swim6 swim7 swim8 
$frame swim9 swim10 swim11 swim12 swim13 swim14 swim15 swim16 swim17 
$frame swim18 

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8 
$frame pain9 

void() swimmonster_start;

void() fish_stand1	=[		$swim1, fish_stand2 ] {ai_stand();};
void() fish_stand2	=[		$swim2, fish_stand3 ] {ai_stand();};
void() fish_stand3	=[		$swim3, fish_stand4 ] {ai_stand();};
void() fish_stand4	=[		$swim4, fish_stand5 ] {ai_stand();};
void() fish_stand5	=[		$swim5, fish_stand6 ] {ai_stand();};
void() fish_stand6	=[		$swim6, fish_stand7 ] {ai_stand();};
void() fish_stand7	=[		$swim7, fish_stand8 ] {ai_stand();};
void() fish_stand8	=[		$swim8, fish_stand9 ] {ai_stand();};
void() fish_stand9	=[		$swim9, fish_stand10  ] {ai_stand();};
void() fish_stand10 =[		$swim10, fish_stand11 ] {ai_stand();};
void() fish_stand11 =[		$swim11, fish_stand12 ] {ai_stand();};
void() fish_stand12 =[		$swim12, fish_stand13 ] {ai_stand();};
void() fish_stand13 =[		$swim13, fish_stand14 ] {ai_stand();};
void() fish_stand14 =[		$swim14, fish_stand15 ] {ai_stand();};
void() fish_stand15 =[		$swim15, fish_stand16 ] {ai_stand();};
void() fish_stand16 =[		$swim16, fish_stand17 ] {ai_stand();};
void() fish_stand17 =[		$swim17, fish_stand18 ] {ai_stand();};
void() fish_stand18 =[		$swim18, fish_stand1 ] {ai_stand();};

void() fish_walk1  =[	   $swim1, fish_walk2 ] {ai_walk(18);}; // original is 8
void() fish_walk2  =[	   $swim2, fish_walk3 ] {ai_walk(18);};
void() fish_walk3  =[	   $swim3, fish_walk4 ] {ai_walk(18);};
void() fish_walk4  =[	   $swim4, fish_walk5 ] {ai_walk(18);};
void() fish_walk5  =[	   $swim5, fish_walk6 ] {ai_walk(18);};
void() fish_walk6  =[	   $swim6, fish_walk7 ] {ai_walk(18);};
void() fish_walk7  =[	   $swim7, fish_walk8 ] {ai_walk(18);};
void() fish_walk8  =[	   $swim8, fish_walk9 ] {ai_walk(18);};
void() fish_walk9  =[	   $swim9, fish_walk10	] {ai_walk(18);};
void() fish_walk10 =[	   $swim10, fish_walk11 ] {ai_walk(18);};
void() fish_walk11 =[	   $swim11, fish_walk12 ] {ai_walk(18);};
void() fish_walk12 =[	   $swim12, fish_walk13 ] {ai_walk(18);};
void() fish_walk13 =[	   $swim13, fish_walk14 ] {ai_walk(18);};
void() fish_walk14 =[	   $swim14, fish_walk15 ] {ai_walk(18);};
void() fish_walk15 =[	   $swim15, fish_walk16 ] {ai_walk(18);};
void() fish_walk16 =[	   $swim16, fish_walk17 ] {ai_walk(18);};
void() fish_walk17 =[	   $swim17, fish_walk18 ] {ai_walk(18);};
void() fish_walk18 =[	   $swim18, fish_walk1 ] {ai_walk(18);};

void() fish_run1  =[	  $swim1, fish_run2 ] {ai_run(28); // original is 12
	if (random() < 0.2)
		sound (self, #CHAN_VOICE, "fish/idle.wav", 1, #ATTN_NORM);
};
void() fish_run2  =[	  $swim3, fish_run3 ] {ai_run(28);};
void() fish_run3  =[	  $swim5, fish_run4 ] {ai_run(28);};
void() fish_run4  =[	  $swim7, fish_run5 ] {ai_run(28);};
void() fish_run5  =[	  $swim9, fish_run6 ] {ai_run(28);};
void() fish_run6  =[	  $swim11, fish_run7 ] {ai_run(28);};
void() fish_run7  =[	  $swim13, fish_run8 ] {ai_run(28);};
void() fish_run8  =[	  $swim15, fish_run9 ] {ai_run(28);};
void() fish_run9  =[	  $swim17, fish_run1 ] {ai_run(28);};

void() fish_melee =
{
	local vector	delta;
	local float 	ldmg;
						// dont bite if enemy dead
	//if (!self.enemy || self.enemy.health <= 0 || self.enemy.has_disconnected)
	if (!StillValidEnemy(self.enemy))
	{
		self.enemy = world;

		fish_run2(); // not f_run1 cause we dont want idle sounds
		return; 	// removed before stroke
	}
		
	delta = self.enemy.origin - self.origin;

	MonsterAuraPower();
	
	if (vlen(delta) > 85) // Original was 60 THEN 80
		return;
		
	sound (self, #CHAN_VOICE, "fish/bite.wav", 1, #ATTN_NORM);
	
	ldmg = random()* 100 + 25;

	TF_T_Damage(self.enemy, self, self, ldmg, #TF_TD_DONTGIB, #TF_TD_OTHER);
	//T_Damage (self.enemy, self, self, ldmg);
};

void() fish_attack1 	   =[	   $attack1,	   fish_attack2 ] {ai_charge(10);}; // original is 10
void() fish_attack2 	   =[	   $attack2,	   fish_attack3 ] {ai_charge(10);};
void() fish_attack3 	   =[	   $attack3,	   fish_attack4 ] {fish_melee();};
void() fish_attack4 	   =[	   $attack4,	   fish_attack5 ] {ai_charge(10);};
void() fish_attack5 	   =[	   $attack5,	   fish_attack6 ] {ai_charge(10);};
void() fish_attack6 	   =[	   $attack6,	   fish_attack7 ] {ai_charge(10);};
void() fish_attack7 	   =[	   $attack7,	   fish_attack8 ] {ai_charge(10);};
void() fish_attack8 	   =[	   $attack8,	   fish_attack9 ] {ai_charge(10);};
void() fish_attack9 	   =[	   $attack9,	   fish_attack10] {fish_melee();};
void() fish_attack10	   =[	   $attack10,	   fish_attack11] {ai_charge(10);};
void() fish_attack11	   =[	   $attack11,	   fish_attack12] {ai_charge(10);};
void() fish_attack12	   =[	   $attack12,	   fish_attack13] {ai_charge(10);};
void() fish_attack13	   =[	   $attack13,	   fish_attack14] {ai_charge(10);};
void() fish_attack14	   =[	   $attack14,	   fish_attack15] {ai_charge(10);};
void() fish_attack15	   =[	   $attack15,	   fish_attack16] {fish_melee();};
void() fish_attack16	   =[	   $attack16,	   fish_attack17] {ai_charge(10);};
void() fish_attack17	   =[	   $attack17,	   fish_attack18] {ai_charge(10);};
void() fish_attack18	   =[	   $attack18,	   fish_run1	] {ai_charge(10);};

void() fish_death1 =[	   $death1, 	   fish_death2		  ] {
	sound (self, #CHAN_VOICE, "fish/death.wav", 1, #ATTN_MONSTERDIE);
	
	// Hackish fix for visuals if outside water
	if (pointcontents(self.origin) ==  #CONTENT_EMPTY)
		self.movetype = #MOVETYPE_TOSS;
};
void() fish_death2 =[	   $death2, 	   fish_death3		  ] {};
void() fish_death3 =[	   $death3, 	   fish_death4		  ] {self.solid = #SOLID_NOT;};
void() fish_death4 =[	   $death4, 	   fish_death5		  ] {};
void() fish_death5 =[	   $death5, 	   fish_death6		  ] {};
void() fish_death6 =[	   $death6, 	   fish_death7		  ] {};
void() fish_death7 =[	   $death7, 	   fish_death8		  ] {};
void() fish_death8 =[	   $death8, 	   fish_death9		  ] {};
void() fish_death9 =[	   $death9, 	   fish_death10 	  ] {};
void() fish_death10 =[		$death10,		fish_death11	   ] {};
void() fish_death11 =[		$death11,		fish_death12	   ] {};
void() fish_death12 =[		$death12,		fish_death13	   ] {};
void() fish_death13 =[		$death13,		fish_death14	   ] {};
void() fish_death14 =[		$death14,		fish_death15	   ] {};
void() fish_death15 =[		$death15,		fish_death16	   ] {};
void() fish_death16 =[		$death16,		fish_death17	   ] {};
void() fish_death17 =[		$death17,		fish_death18	   ] {};
void() fish_death18 =[		$death18,		fish_death19	   ] {};
void() fish_death19 =[		$death19,		fish_death20	   ] {};
void() fish_death20 =[		$death20,		fish_death21	   ] {};
void() fish_death21 =[		$death21,		fish_death21	   ] {
	//self.nextthink = time + 40 + 40*random(); 
	//self.think = SUB_Remove;

	//self.solid = #SOLID_NOT;
	MonsterCorpse();
};

void() fish_pain1  =[	   $pain1, fish_pain2 ] {};
void() fish_pain2  =[	   $pain2, fish_pain3 ] {ai_pain(6);}; // original is 6
void() fish_pain3  =[	   $pain3, fish_pain4 ] {ai_pain(6);};
void() fish_pain4  =[	   $pain4, fish_pain5 ] {ai_pain(6);};
void() fish_pain5  =[	   $pain5, fish_pain6 ] {ai_pain(6);};
void() fish_pain6  =[	   $pain6, fish_pain7 ] {ai_pain(6);};
void() fish_pain7  =[	   $pain7, fish_pain8 ] {ai_pain(6);};
void() fish_pain8  =[	   $pain8, fish_pain9 ] {ai_pain(6);};
void() fish_pain9  =[	   $pain9, fish_run1 ] {ai_pain(6);};

void(entity attacker, float damage) fish_pain =
{	
	if (self.health <= 0)
		return;

	if (self.pain_finished > time)
		return;

// fish allways do pain frames - OfN - nope
	if (random() > 0.85 || (damage > random()*50))
		fish_pain1 ();

	AI_CheckAttacker(attacker);
	
	self.pain_finished = time +1 +random();
};

void() fish_death =
{
	if (self.real_owner.classname == "player")
	{
		sprint(self.real_owner,#PRINT_HIGH,"Your piranha ");
		sprint(self.real_owner,#PRINT_HIGH,self.netname);
		sprint(self.real_owner,#PRINT_HIGH," is dead.\n");
		self.real_owner.job_finished = time + 5; // delay between summons
		ResetSlotPointer(self.real_owner, self.increase_team1);
	}	

// check for gib
	if (self.health < -35) // was 30
	{
		//sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_MONSTERDIE);
		
		ThrowGib ("progs/gib2.mdl", self.health,#TRUE,0,#GIB2_KGS, #FALSE);
		ThrowGib ("progs/gib3.mdl", self.health,#TRUE,0,#GIB3_KGS, #FALSE);

		dremove(self);		  
		return;
	}
	
	// show bubbles if fish is in liquid
	if (pointcontents(self.origin) != #CONTENT_EMPTY)
		DeathBubbles(4);

	//self.classname = "monster_corpse";
	MonsterDead();
	self.think=SUB_Null;
	self.nextthink = time + 0.1;

	fish_death1();
};

/*QUAKED monster_fish (1 0 0) (-16 -16 -24) (16 16 24) Ambush
*/
/*
void() monster_fish =
{
	if (deathmatch)
	{
		dremove(self);
		return;
	}
	precache_model2 ("progs/fish.mdl");

	precache_sound2 ("fish/death.wav");
	precache_sound2 ("fish/bite.wav");
	precache_sound2 ("fish/idle.wav");

	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;

	setmodel (self, "progs/fish.mdl");

	setsize (self, '-16 -16 -24', '16 16 24');
	self.health = 25;
	
	self.th_stand = f_stand1;
	self.th_walk = f_walk1;
	self.th_run = f_run1;
	self.th_die = fish_death;
	self.th_pain = fish_pain;
	self.th_melee = f_attack1;
	
	swimmonster_start ();
};*/

void() Fish_Precache =
{
	precache_model ("progs/fish.mdl");

	precache_sound ("fish/death.wav");
	precache_sound ("fish/bite.wav");
	precache_sound ("fish/idle.wav");
};

void() fish_toss =
{
	local float contenttype;
	contenttype = pointcontents(self.origin);

	if (contenttype != #CONTENT_EMPTY) // we have been tossed and now we got into water/slime or lava
	{
		if (contenttype == #CONTENT_SKY || contenttype == #CONTENT_SOLID) // on a invalid place
		{
			sprint(self.real_owner,#PRINT_HIGH,"Your piranha gets into the twilight zone!\n");
			self.health = -50;
			MonsterDie(self);
			return;
		}

		// make splash sound (we got into liquid)
		sound(self,#CHAN_BODY,"player/inh2o.wav",1,#ATTN_NORM);

		DeathBubbles(3); // Not dying tho
		
		// ok, fish is ready to go..
		self.movetype = #MOVETYPE_STEP;
		self.velocity = '0 0 0';
		self.think = swimmonster_start_go;
		self.nextthink = time + 0.1;
		return;
	}

	// are we on ground? if so, die (also die if 15 seconds passed since toss)
	if (self.flags & #FL_ONGROUND || time > self.ltime + 15)
	{
		self.dmgtime = time; // check now
		self.nextthink = time + 0.1;
		self.think = swimmonster_start_go; // will call AI_check_contents
	}
};

void() fish_toss1  =[	   $swim1, fish_toss2 ] {fish_toss();};
void() fish_toss2  =[	   $swim2, fish_toss3 ] {fish_toss();};
void() fish_toss3  =[	   $swim3, fish_toss4 ] {fish_toss();};
void() fish_toss4  =[	   $swim4, fish_toss5 ] {fish_toss();};
void() fish_toss5  =[	   $swim5, fish_toss6 ] {fish_toss();};
void() fish_toss6  =[	   $swim6, fish_toss7 ] {fish_toss();};
void() fish_toss7  =[	   $swim7, fish_toss8 ] {fish_toss();};
void() fish_toss8  =[	   $swim8, fish_toss9 ] {fish_toss();};
void() fish_toss9  =[	   $swim9, fish_toss10	] {fish_toss();};
void() fish_toss10 =[	   $swim10, fish_toss11 ] {fish_toss();};
void() fish_toss11 =[	   $swim11, fish_toss12 ] {fish_toss();};
void() fish_toss12 =[	   $swim12, fish_toss13 ] {fish_toss();};
void() fish_toss13 =[	   $swim13, fish_toss14 ] {fish_toss();};
void() fish_toss14 =[	   $swim14, fish_toss15 ] {fish_toss();};
void() fish_toss15 =[	   $swim15, fish_toss16 ] {fish_toss();};
void() fish_toss16 =[	   $swim16, fish_toss17 ] {fish_toss();};
void() fish_toss17 =[	   $swim17, fish_toss18 ] {fish_toss();};
void() fish_toss18 =[	   $swim18, fish_toss1 ] {fish_toss();};

//TODO: void PiranhaElectric() with checks for start of electricity charge, sets lits on fish and gets called EVERYWHERE