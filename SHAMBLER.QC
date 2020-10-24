
//void(float side) ShamFireball;
//void() sham_fireballl1;
//void() sham_fireballr1;
//void() shambler_fire_touch;
float (entity targ, entity inflictor) CanDamage;
#ifdef XMAS_STUFF
void() sham_xmas_removefx;
#endif
/*
==============================================================================

SHAMBLER

==============================================================================
*/

$cd /raid/quake/id1/models/shams
$scale 1.5
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 
$frame walk8 walk9 walk10 walk11 walk12

$frame	run1 run2 run3 run4 run5 run6

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 
$frame smash8 smash9 smash10 smash11 smash12

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame magic1 magic2 magic3 magic4 magic5 
$frame magic6 magic7 magic8 magic9 magic10 magic11 magic12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 
$frame death7 death8 death9 death10 death11

void() sham_stand1	=[	$stand1,	sham_stand2 ] {ai_stand();};
void() sham_stand2	=[	$stand2,	sham_stand3 ] {ai_stand();};
void() sham_stand3	=[	$stand3,	sham_stand4 ] {ai_stand();};
void() sham_stand4	=[	$stand4,	sham_stand5 ] {ai_stand();};
void() sham_stand5	=[	$stand5,	sham_stand6 ] {ai_stand();};
void() sham_stand6	=[	$stand6,	sham_stand7 ] {ai_stand();};
void() sham_stand7	=[	$stand7,	sham_stand8 ] {ai_stand();};
void() sham_stand8	=[	$stand8,	sham_stand9 ] {ai_stand();};
void() sham_stand9	=[	$stand9,	sham_stand10] {ai_stand();};
void() sham_stand10 =[	$stand10,	sham_stand11] {ai_stand();};
void() sham_stand11 =[	$stand11,	sham_stand12] {ai_stand();};
void() sham_stand12 =[	$stand12,	sham_stand13] {ai_stand();};
void() sham_stand13 =[	$stand13,	sham_stand14] {ai_stand();};
void() sham_stand14 =[	$stand14,	sham_stand15] {ai_stand();};
void() sham_stand15 =[	$stand15,	sham_stand16] {ai_stand();};
void() sham_stand16 =[	$stand16,	sham_stand17] {ai_stand();};
void() sham_stand17 =[	$stand17,	sham_stand1 ] {ai_stand();};

void() sham_walk1		=[		$walk1, 	   sham_walk2 ] {ai_walk(10);};
void() sham_walk2		=[		$walk2, 	   sham_walk3 ] {ai_walk(9);};
void() sham_walk3		=[		$walk3, 	   sham_walk4 ] {ai_walk(9);};
void() sham_walk4		=[		$walk4, 	   sham_walk5 ] {ai_walk(5);};
void() sham_walk5		=[		$walk5, 	   sham_walk6 ] {ai_walk(6);};
void() sham_walk6		=[		$walk6, 	   sham_walk7 ] {ai_walk(12);};
void() sham_walk7		=[		$walk7, 	   sham_walk8 ] {ai_walk(8);};
void() sham_walk8		=[		$walk8, 	   sham_walk9 ] {ai_walk(3);};
void() sham_walk9		=[		$walk9, 	   sham_walk10] {ai_walk(13);};
void() sham_walk10		=[		$walk10,	   sham_walk11] {ai_walk(9);};
void() sham_walk11		=[		$walk11,	   sham_walk12] {ai_walk(7);};
void() sham_walk12		=[		$walk12,	   sham_walk1 ] {ai_walk(7);
if (random() > 0.8)
	sound (self, #CHAN_VOICE, "shambler/sidle.wav", 1, #ATTN_IDLE);};

void() sham_run1	   =[	   $run1,		 sham_run2		] {ai_run(20);};
void() sham_run2	   =[	   $run2,		 sham_run3		] {ai_run(24);};
void() sham_run3	   =[	   $run3,		 sham_run4		] {ai_run(20);};
void() sham_run4	   =[	   $run4,		 sham_run5		] {ai_run(20);};
void() sham_run5	   =[	   $run5,		 sham_run6		] {ai_run(24);};
void() sham_run6	   =[	   $run6,		 sham_run1		] {ai_run(20);
if (random() > 0.8)
	sound (self, #CHAN_VOICE, "shambler/sidle.wav", 1, #ATTN_IDLE);

//if (self.enemy
};

void() sham_smash1	   =[	   $smash1, 	  sham_smash2	 ] {
sound (self, #CHAN_VOICE, "shambler/melee1.wav", 1, #ATTN_NORM);
ai_charge(12);};
void() sham_smash2	   =[	   $smash2, 	  sham_smash3	 ] {ai_charge(12);}; // spd trple
void() sham_smash3	   =[	   $smash3, 	  sham_smash4	 ] {ai_charge(12);};
void() sham_smash4	   =[	   $smash4, 	  sham_smash5	 ] {ai_charge(10);};
void() sham_smash5	   =[	   $smash5, 	  sham_smash6	 ] {ai_charge(8);};
void() sham_smash6	   =[	   $smash6, 	  sham_smash7	 ] {ai_charge(2);};
void() sham_smash7	   =[	   $smash7, 	  sham_smash8	 ] {ai_charge(0);
	MonsterAuraPower();
};
void() sham_smash8	   =[	   $smash8, 	  sham_smash9	 ] {ai_charge(0);};
void() sham_smash9	   =[	   $smash9, 	  sham_smash10	 ] {ai_charge(0);};
void() sham_smash10    =[	   $smash10,	  sham_smash11	 ] {
local vector	delta;//, smack_origin, source;
local float 	ldmg;
//local entity	head;

	if (!self.enemy)
		return;
	ai_charge(0);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 200)
		return;
	if (!CanDamage (self.enemy, self))
		return;
		
	ldmg = (random() + random() + random()) * 200 + 30*self.has_tesla;
	deathmsg = 0;
	if (self.enemy.tf_items & #NIT_GEL) ldmg = ldmg / 2;
	if (self.enemy.cutf_items & #CUTF_DEMONLORE) ldmg = ldmg / 2;
	//T_Damage (self.enemy, self, self, ldmg);
	TF_T_Damage(self.enemy, self, self, ldmg,0,#TF_TD_MELEE); //WK 4/27/7
	sound (self, #CHAN_VOICE, "shambler/smack.wav", 1, #ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);

};
void() sham_smash11    =[	   $smash11,	  sham_smash12	 ] {ai_charge(10 * (0.7 + self.has_tesla * 0.2));}; // spd dbl
void() sham_smash12    =[	   $smash12,	  sham_run1    ] {ai_charge(8 * (0.7 + self.has_tesla * 0.2));};

void() sham_swingr1;

void(float side) ShamClaw =
{
local vector	delta;
//local vector	smack_origin, source;
local float 	ldmg;
//local entity	head;


	if (!self.enemy)
		return;
	ai_charge(20 * (0.7 + self.has_tesla * 0.2)); //spd dbl

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 200)
		return;
		
	deathmsg = 0;
	
	ldmg = (random() + random() + random()) * 75 + 15*self.has_tesla;
	if (self.enemy.tf_items & #NIT_GEL) ldmg = ldmg / 2;
	if (self.enemy.cutf_items & #CUTF_DEMONLORE) ldmg = ldmg * 0.8;
	if (self.has_tesla == 5)
	{
		if (ldmg < self.enemy.health && self.enemy.health > 0)
			self.health = self.health + (ldmg / 20);
		else if (self.enemy.health > 0)
			self.health = self.health + (self.enemy.health / 20);
		if (self.health > self.max_health)
			self.health = self.max_health;
	}
	//T_Damage (self.enemy, self, self, ldmg);
	TF_T_Damage(self.enemy, self, self, ldmg,0,#TF_TD_MELEE); //WK 4/27/7
	sound (self, #CHAN_VOICE, "shambler/smack.wav", 1, #ATTN_NORM);

	if (side)
	{
		makevectors (self.angles);
		SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}

};

void() sham_swingl1 =[		$swingl1,	   sham_swingl2   ] {
sound (self, #CHAN_VOICE, "shambler/melee2.wav", 1, #ATTN_NORM);
	MonsterAuraPower();
ai_charge(10);};
void() sham_swingl2 =[		$swingl2,	   sham_swingl3   ] {ai_charge(6);}; //speed doubled
void() sham_swingl3 =[		$swingl3,	   sham_swingl4   ] {ai_charge(14);};
void() sham_swingl4 =[		$swingl4,	   sham_swingl5   ] {ai_charge(6);};
void() sham_swingl5 =[		$swingl5,	   sham_swingl6   ] {ai_charge(14);};
void() sham_swingl6 =[		$swingl6,	   sham_swingl7   ] {ai_charge(18);};
void() sham_swingl7 =[		$swingl7,	   sham_swingl8   ] {ai_charge(10); ShamClaw(250);
	//if (self.enemy.health <= 0 || self.enemy.has_disconnected)
	if (!StillValidEnemy(self.enemy))
	{
	self.enemy = world;
	// FIXME: look all around for other targets
		//if (self.oldenemy.health > 0 && !self.oldenemy.has_disconnected)
		if (StillValidEnemy(self.oldenemy))
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else
		{ //FIXES MAD SHAMBLERs?
			MonsterIdle(self);
			
			/*if (self.movetarget)
				self.th_walk ();
			else
				self.th_stand ();*/

			return;
		}
	}
};
void() sham_swingl8 =[		$swingl8,	   sham_swingl9   ] {ai_charge(8);};
void() sham_swingl9 =[		$swingl9,	   sham_run1  ] {
ai_charge(16);
if (random()<0.5)
	self.think = sham_swingr1;
};

void() sham_swingr1 =[		$swingr1,	   sham_swingr2   ] {
	sound (self, #CHAN_VOICE, "shambler/melee1.wav", 1, #ATTN_NORM);
	MonsterAuraPower();

	ai_charge(2);};
void() sham_swingr2 =[		$swingr2,	   sham_swingr3   ] {ai_charge(16);};
void() sham_swingr3 =[		$swingr3,	   sham_swingr4   ] {ai_charge(28);};
void() sham_swingr4 =[		$swingr4,	   sham_swingr5   ] {ai_charge(14);}; // speed dbl
void() sham_swingr5 =[		$swingr5,	   sham_swingr6   ] {ai_charge(6);};
void() sham_swingr6 =[		$swingr6,	   sham_swingr7   ] {ai_charge(12);};
void() sham_swingr7 =[		$swingr7,	   sham_swingr8   ] {ai_charge(12); ShamClaw(-250);
	//if (self.enemy.health <= 0 || self.enemy.has_disconnected)
	if (!StillValidEnemy(self.enemy))
	{
		self.enemy = world;
	// FIXME: look all around for other targets
		//if (self.oldenemy.health > 0 && !self.oldenemy.has_disconnected)
		if (StillValidEnemy(self.oldenemy))
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else
		{ //FIXES MAD SHAMBLERs? - no
			MonsterIdle(self);
			
			/*if (self.movetarget)
				self.th_walk ();
			else
				self.th_stand ();*/

			return;
		}
	}
};
void() sham_swingr8 =[		$swingr8,	   sham_swingr9   ] {ai_charge(6);};
void() sham_swingr9 =[		$swingr9,	   sham_run1  ] {ai_charge(2);
//if ((self.has_sensor && self.enemy.health > 0 && random()<0.5) || (!self.has_sensor && self.enemy.health <= 0 && random()<0.5))
// TOCHECK: WTF is this for??
if ((self.has_sensor && StillValidEnemy(self.enemy) && random()<0.5) || (!self.has_sensor && !StillValidEnemy(self.enemy) && random()<0.5))
	self.think = sham_swingl1;
};

void() sham_melee =
{
	local float chance;
	
	chance = random();
	self.has_sensor = 1;
	if (chance > 0.7)
		sham_smash1 ();
	else if (chance > 0.35)
		sham_swingr1 ();
	else
		sham_swingl1 ();
};


//============================================================================

void() CastLightning =
{
	local	vector	org, dir;
	local	float	ldmg;
	
	self.effects = self.effects | #EF_DIMLIGHT;

	ai_face ();

	org = self.origin + '0 0 40';

	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);

	// OfN - Check for force field
	traceline (org, self.origin + dir*3000, #TL_ANY_SOLID, self);

	if (trace_ent.classname == "force_field")
	{
		FieldEvent(trace_ent,trace_endpos,trace_ent);

		/*FieldExplosion(trace_ent,trace_endpos,trace_ent);
		PutFieldWork(trace_ent);*/

		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_LIGHTNING1);
		WriteEntity (#MSG_BROADCAST, self);
		WriteCoord (#MSG_BROADCAST, org_x);
		WriteCoord (#MSG_BROADCAST, org_y);
		WriteCoord (#MSG_BROADCAST, org_z);
		WriteCoord (#MSG_BROADCAST, trace_endpos_x);
		WriteCoord (#MSG_BROADCAST, trace_endpos_y);
		WriteCoord (#MSG_BROADCAST, trace_endpos_z);
	#ifdef QUAKE_WORLD
		multicast (org, #MULTICAST_PHS);
	#endif

		return;
	}
	//_------------------------------------_//

	traceline (org, self.origin + dir*3000, #TL_BSP_ONLY, self);

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_LIGHTNING1);
	WriteEntity (#MSG_BROADCAST, self);
	WriteCoord (#MSG_BROADCAST, org_x);
	WriteCoord (#MSG_BROADCAST, org_y);
	WriteCoord (#MSG_BROADCAST, org_z);
	WriteCoord (#MSG_BROADCAST, trace_endpos_x);
	WriteCoord (#MSG_BROADCAST, trace_endpos_y);
	WriteCoord (#MSG_BROADCAST, trace_endpos_z);

#ifdef QUAKE_WORLD
	multicast (org, #MULTICAST_PHS);
#endif

	ldmg = 5 + self.has_tesla * 5;
	if (self.has_tesla == 5)
		if (ldmg < self.enemy.health)
			self.health = self.health + (ldmg / 10);
		else
			self.health = floor(self.health + (self.enemy.health / 10));
		if (self.health > self.max_health)
			self.health = self.max_health;
	
	#ifdef SHAMBLER_SHOCK_SOUND
	
	// OfN - hackish, sry, but better than modifying the ancient LightningDamage :)
	local float oldhp;
	oldhp = self.enemy.health;
		
	LightningDamage (org, trace_endpos, self, 5 + self.has_tesla * 5);

	// They got electrified, dont they? so..
	if (self.enemy.health != oldhp)
		sound (self.enemy, #CHAN_WEAPON, "weapons/lhit.wav", 0.75, #ATTN_NORM);
	
	#else

	LightningDamage (org, trace_endpos, self, 5 + self.has_tesla * 5);

	#endif

};

void() sham_magic1	   =[	   $magic1, 	  sham_magic2	 ] {ai_face();
	sound (self, #CHAN_WEAPON, "shambler/sattck1.wav", 1, #ATTN_NORM);
};
void() sham_magic2	   =[	   $magic2, 	  sham_magic3	 ] {ai_face();};
void() sham_magic3	   =[	   $magic3, 	  sham_magic4	 ] {ai_face();self.nextthink = self.nextthink + 0.2;
local entity o;

self.effects = self.effects | #EF_DIMLIGHT;
ai_face();
self.owner = spawn();
o = self.owner;
setmodel (o, "progs/s_light.mdl");
setorigin (o, self.origin);
o.angles = self.angles;
o.nextthink = time + 0.7;
o.think = SUB_Remove;
};
void() sham_magic4	   =[	   $magic4, 	  sham_magic5	 ]
{
	MonsterAuraPower();
self.effects = self.effects | #EF_DIMLIGHT;
self.owner.frame = 1;
};
void() sham_magic5	   =[	   $magic5, 	  sham_magic6	 ]
{
self.effects = self.effects | #EF_DIMLIGHT;
self.owner.frame = 2;
};
void() sham_magic6	   =[	   $magic6, 	  sham_magic9	 ]
{
remove (self.owner);
CastLightning();
sound (self, #CHAN_WEAPON, "shambler/sboom.wav", 1, #ATTN_NORM);
};
void() sham_magic9	   =[	   $magic9, 	  sham_magic10	 ]
{CastLightning();};
void() sham_magic10    =[	   $magic10,	  sham_magic11	 ]
{CastLightning();};
void() sham_magic11    =[	   $magic11,	  sham_magic12	 ]
{
if (skill == 3)
	CastLightning();
};
void() sham_magic12    =[	   $magic12,	  sham_run1    ] {self.effects = 0;};



void() sham_pain1		=[		$pain1, sham_pain2		] {};
void() sham_pain2		=[		$pain2, sham_pain3		] {};
void() sham_pain3		=[		$pain3, sham_pain4		] {};
void() sham_pain4		=[		$pain4, sham_pain5		] {};
void() sham_pain5		=[		$pain5, sham_pain6		] {};
void() sham_pain6		=[		$pain6, sham_run1	   ] {};

void(entity attacker, float damage) sham_pain =
{		
	//self.real_owner.StatusRefreshTime = time + 0.2;
	//self.real_owner.StatusBarScreen = 3;	

	if (self.has_holo) return; // there is no pain during xmas! :)

	if (self.pain_finished > time)
		return;

	if (self.health <= 0)
		return; 	// allready dying, don't go into pain frame
	  
	if (random()*100 > damage) // was 70
		return; 	// didn't flinch

	AI_CheckAttacker(attacker);

	sound (self, #CHAN_VOICE, "shambler/shurt2.wav", 1, #ATTN_NORM);

	//self.pain_finished = time + 2; wasnt comented
	self.pain_finished = time + 1.5 + random() * 1.2; //-OfN first was 1, then 1.5
	self.effects=0;
		
	sham_pain1 ();
};

void() sham_death1		=[		$death1,	   sham_death2	   ] {};
void() sham_death2		=[		$death2,	   sham_death3	   ] {};
void() sham_death3		=[		$death3,	   sham_death4	   ] {self.solid = #SOLID_NOT;};
void() sham_death4		=[		$death4,	   sham_death5	   ] {};
void() sham_death5		=[		$death5,	   sham_death6	   ] {};
void() sham_death6		=[		$death6,	   sham_death7	   ] {};
void() sham_death7		=[		$death7,	   sham_death8	   ] {};
void() sham_death8		=[		$death8,	   sham_death9	   ] {};
void() sham_death9		=[		$death9,	   sham_death10    ] {};
void() sham_death10 	=[		$death10,	   sham_death11    ] {};
void() sham_death11 	=[		$death11,	   sham_death11    ] 
{
	//self.nextthink = time + 40 + 40*random(); 
	//self.think = SUB_Remove;
	MonsterCorpse();
};

void() custom_shambler_die = 
{
	self.effects=0;

	if (self.demon_three != world)
		dremove(self.demon_three);
	
	self.demon_three = world;
	
	if (self.real_owner.classname == "player")
	{
		sprint(self.real_owner,#PRINT_HIGH,"Your shambler ");
		sprint(self.real_owner,#PRINT_HIGH,self.netname);
		sprint(self.real_owner,#PRINT_HIGH," is dead.\n");
		self.real_owner.job_finished = time + 5; //Can't summon streams of demons SB can so
		ResetSlotPointer(self.real_owner, self.increase_team1);
	}
	
	// check for gib
	if (self.health < -50)
	{
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_MONSTERDIE);
		ThrowMonsterHead ("progs/h_shams.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health, #TRUE, 0,#GIB1_KGS, #FALSE);
		ThrowGib ("progs/gib2.mdl", self.health, #TRUE, 0,#GIB2_KGS, #FALSE);
		ThrowGib ("progs/gib3.mdl", self.health, #TRUE, 0,#GIB3_KGS, 0.33); 		
		ThrowGib ("progs/gib3.mdl", self.health, #TRUE, 0,#GIB3_KGS, 0.66);
		SpawnBloodEx(self.origin,0.66,9);

		dremove(self);
		return;
	}

	sound (self, #CHAN_VOICE, "shambler/sdeath.wav", 1, #ATTN_MONSTERDIE);

	// Spawn bubbles if under water/slime
	local float contres;
	contres = pointcontents(self.origin);
	if (contres == #CONTENT_WATER || contres == #CONTENT_SLIME)
		DeathBubbles(5);

	//self.classname = "monster_corpse";
	MonsterDead();
	self.think=SUB_Null;
	sham_death1();
};

float () CheckShamMelee =
{
	local vector dist;
	local float d;
	
	dist = self.enemy.origin - self.origin;
	d = vlen(dist);
	if (d < 150) //CH Check reach
	{
		self.attack_state = #AS_MELEE;
		return #TRUE;
	}
	return #FALSE;
};

float () CheckShamLightning =
{
	local	vector	dist;
	local	float	d;
	local	float	d2;

	if (!visible2(self.enemy, self)) //If can see
		return #FALSE;
	dist = self.enemy.origin - self.origin;
	dist_z = 0; //CH only need x,y
	d2 = vlen(dist);
	dist = self.enemy.origin - self.origin;
	dist_x = dist_y = 0; //CH only need z
	d = vlen(dist);
	if (self.has_tesla == 1)
		return #FALSE;
	if (random() > self.has_tesla * 0.07) //CH as not to fire all the time
		return #FALSE;
	if (d2 < 1500 - self.has_tesla * 300 && d < 100)
		return #FALSE;
	if (d2 > 2000 + self.has_tesla * 200) //Min X,Y distance away before zap
		return #FALSE;
	/*if (self.has_tesla > 3 && random() > 0.5) 
		self.attack_state = #AS_FIREBALL;
	//else /// OFTEN*/
		self.attack_state = #AS_MISSILE;
	return #TRUE;
};

float() ShamCheckAttack =
{
	//local vector	vec;
	
// if close enough for slashing, go for it
	if (CheckShamMelee ())
	{
		self.attack_state = #AS_MELEE;
		return #TRUE;
	}
	if (CheckShamLightning ())
		return #TRUE;

	return #FALSE;
};

// Shambler shoots fireballs!

/*
void() sham_fireball =
{
	local float 	r;
	
	r = random();
	
	if (r > 0.5)
		sham_fireballl1();
	else
		sham_fireballr1();
		
};

void() sham_fireballl1	=[		$swingl1,	   sham_fireballl2	 ] {
sound (self, #CHAN_VOICE, "shambler/melee2.wav", 1, #ATTN_NORM);
ai_charge(15 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl2 =[	   $swingl2,	  sham_fireballl3	] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));}; //speed doubled
void() sham_fireballl3 =[	   $swingl3,	  sham_fireballl4	] {ai_charge(21 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl4 =[	   $swingl4,	  sham_fireballl5	] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl5 =[	   $swingl5,	  sham_fireballl6	] {ai_charge(21 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl6 =[	   $swingl6,	  sham_fireballl7	] {ai_charge(27 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl7 =[	   $swingl7,	  sham_fireballl8	] {ai_charge(15 * (0.7 + self.has_tesla * 0.2)); ShamFireball(250);};
void() sham_fireballl8 =[	   $swingl8,	  sham_fireballl9	] {ai_charge(12 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballl9 =[	   $swingl9,	  sham_run1  ] {
ai_charge(24 * (0.7 + self.has_tesla * 0.2));
if (random() < 0.2)
	self.think = sham_fireballr1;
};

void() sham_fireballr1	=[		$swingr1,	   sham_fireballr2	 ] {
sound (self, #CHAN_VOICE, "shambler/melee1.wav", 1, #ATTN_NORM);
ai_charge(3 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr2	=[		$swingr2,	   sham_fireballr3	 ] {ai_charge(24 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr3 =[	   $swingr3,	  sham_fireballr4	] {ai_charge(42 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr4 =[	   $swingr4,	  sham_fireballr5	] {ai_charge(21 * (0.7 + self.has_tesla * 0.2));}; // speed dbl
void() sham_fireballr5 =[	   $swingr5,	  sham_fireballr6	] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr6 =[	   $swingr6,	  sham_fireballr7	] {ai_charge(18 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr7 =[	   $swingr7,	  sham_fireballr8	] {ai_charge(18 * (0.7 + self.has_tesla * 0.2)); ShamFireball(-250);};
void() sham_fireballr8 =[	   $swingr8,	  sham_fireballr9	] {ai_charge(9 * (0.7 + self.has_tesla * 0.2));};
void() sham_fireballr9 =[	   $swingr9,	  sham_run1  ] {ai_charge(30 * (0.7 + self.has_tesla * 0.2));
if (random() < 0.2)
	self.think = sham_fireballl1;
};

void(float side) ShamFireball =
{
	local	float	ldmg;
	local	vector	delta;
	local	vector	offang;
	local	vector	org, dir;
	
	ai_face ();

	delta = self.enemy.origin - self.origin;
	offang = vectoangles (delta);
	makevectors (offang);
	
	sound (self, #CHAN_WEAPON, "hknight/attack1.wav", 1, #ATTN_NORM); //Odd, it was already precached

	if (side > 0) //CH cause to spawn on side of demon.
		org = self.origin + (v_forward * 10) + (v_right * 20);
	else
		org = self.origin + (v_forward * 10) - (v_right * 20);

// set missile speed
	dir = normalize (v_forward);

//CH demons are not good at throwing
	dir_z = 0 - dir_z; //Random Z addage
	//dir_x = dir_x + (random() - 0.5)*0.05; //Random X addage
	//dir_y = dir_y + (random() - 0.5)*0.05; //Random Y addage
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_NOCLIP;
	newmis.solid = #SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = shambler_fire_touch;
	newmis.weapon = #DMSG_DEMON_FIRE;
	newmis.classname = "demon_fire";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 10;
	setmodel (newmis, "progs/lavaball.mdl");
	setsize (newmis, '-8 -16 -8', '20 16 28'); //CH actual mdl bounds
//	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);
	newmis.velocity = dir * 1000 * (self.has_tesla - 3);
};
*/

/*void() shambler_fire_touch = -OFN fireballs out!
{
	local float fire_dmg;
	fire_dmg = 10 + random() * 25;
	fire_dmg = fire_dmg * self.owner.has_tesla;
	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		dremove(self);
		return;
	}

	deathmsg = self.weapon;
	T_RadiusDamage (self, self.owner, fire_dmg , self.owner);

	self.origin = self.origin - 8*normalize(self.velocity); //???

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
};
*/

//================================================
// OfN - Xmas stuff
#ifdef XMAS_STUFF

void() sham_xmas1 =[$magic12, sham_xmas2] {self.has_holo = 1;sound(self,#CHAN_VOICE,"misc/shamxmas.wav",1,#ATTN_NONE);};
void() sham_xmas2 =[$magic11, sham_xmas3] {MonsterAuraPower();};
void() sham_xmas3 =[$magic10, sham_xmas4] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.2;

if (self.demon_three) return;

local entity lightfx;

lightfx = spawn();
lightfx.owner = self;
lightfx.movetype = #MOVETYPE_FLY;
lightfx.solid = #SOLID_NOT;
lightfx.effects = #EF_DIMLIGHT;
setmodel (lightfx, "progs/s_light.mdl");
setorigin (lightfx, self.origin);
lightfx.angles = self.angles;
lightfx.nextthink = time + 3;
lightfx.think = sham_xmas_removefx;
lightfx.avelocity = '400 400 400';
lightfx.velocity = '0 0 5';

self.demon_three = lightfx;
};

void() sham_xmas4 =[$magic10, sham_xmas5] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.2;};
void() sham_xmas5 =[$magic10, sham_xmas6] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.2;};
void() sham_xmas6 =[$magic10, sham_xmas7] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.2;};
void() sham_xmas7 =[$magic10, sham_xmas8] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.2;};
void() sham_xmas8 =[$magic10, sham_xmas9] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.2;};
void() sham_xmas9 =[$magic10, sham_xmas10] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.2;};

void() sham_xmas10 =[$magic10, sham_xmas11] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.2;};
void() sham_xmas11 =[$magic10, sham_xmas12] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.2;};
void() sham_xmas12 =[$magic10, sham_xmas13] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.2;};

void() sham_xmas13 =[$magic10, sham_xmas14] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.1;};
void() sham_xmas14 =[$magic10, sham_xmas15] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.1;};
void() sham_xmas15 =[$magic10, sham_xmas16] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.1;};

void() sham_xmas16 =[$magic10, sham_xmas17] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.1;};
void() sham_xmas17 =[$magic10, sham_xmas18] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.1;};
void() sham_xmas18 =[$magic10, sham_xmas19] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.1;};
void() sham_xmas19 =[$magic10, sham_xmas20] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.1;};
void() sham_xmas20 =[$magic10, sham_xmas21] {self.effects = #EF_BRIGHTLIGHT;self.nextthink = time + 0.1;};
void() sham_xmas21 =[$magic10, sham_xmas22] {self.effects = #EF_DIMLIGHT;self.nextthink = time + 0.1;};

void() sham_xmas22 =[$magic11, sham_xmas23] {self.effects = 0;};
void() sham_xmas23 =[$magic9, sham_xmas24] {self.effects = #EF_BRIGHTLIGHT;};
void() sham_xmas24 =[$magic8, sham_xmas25] {};
void() sham_xmas25 =[$magic7, sham_xmas26] {};
void() sham_xmas26 =[$magic6, sham_xmas27] {MonsterAuraPower();};
void() sham_xmas27 =[$magic7, sham_xmas28] {};
void() sham_xmas28 =[$magic8, sham_xmas29] {};
void() sham_xmas29 =[$magic7, sham_xmas30] {};
void() sham_xmas30 =[$magic6, sham_xmas31] {};
void() sham_xmas31 =[$magic7, sham_xmas32] {};
void() sham_xmas32 =[$magic8, sham_xmas33] {
	
	// xmas dance! // TODO: make it a function and spread hits among above frames
	local entity te;
	local float xmashits;

	xmashits = 0;

	te = findradius(self.origin,#SHAMBLER_XMAS_RANGE);

	while (te!=world && xmashits <= #SHAMBLER_XMAS_MAXHITS)
	{
		if (te.classname == "player")
		if (te.is_connected)
		if (te.health > 0)
		#ifndef MAD_MONSTERS
		if (!Teammate(self, te))
		#endif
		if (!(te.job & #JOB_THIEF && (te.job & #JOB_ACTIVE || te.job & #JOB_FULL_HIDE)))
		if (!(te.items & #IT_INVISIBILITY))
		{
			#ifndef XMAS_TEST
			deathmsg = #DMSG_XMAS;
			TF_T_Damage(te,self,self,#SHAMBLER_XMAS_DMG,0,#TF_TD_ELECTRICITY);
			#endif

			// lightning
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_LIGHTNING1);
			WriteEntity (#MSG_BROADCAST, self);
			WriteCoord (#MSG_BROADCAST, self.origin_x);
			WriteCoord (#MSG_BROADCAST, self.origin_y);
			WriteCoord (#MSG_BROADCAST, self.origin_z + 67);
			WriteCoord (#MSG_BROADCAST, te.origin_x);
			WriteCoord (#MSG_BROADCAST, te.origin_y);
			WriteCoord (#MSG_BROADCAST, te.origin_z);
			#ifdef QUAKE_WORLD
			multicast (self.origin, #MULTICAST_PHS);
			#endif

			SpawnSprite(1,#SPRITE_AIRBURST,self.origin + '0 0 65','0 0 0',#SPRITEMOVE_UPSLOW,0.15);
			
			SpawnSprite(1,#SPRITE_AIRBURST,te.origin + '0 0 40','0 0 0',#SPRITEMOVE_UPSLOW,0.15);

			sound (te, #CHAN_WEAPON, "weapons/lhit.wav", 1, #ATTN_NONE);

			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
			WriteCoord (#MSG_BROADCAST, te.origin_x);
			WriteCoord (#MSG_BROADCAST, te.origin_y);
			WriteCoord (#MSG_BROADCAST, te.origin_z);
			#ifdef QUAKE_WORLD
			multicast (te.origin, #MULTICAST_PHS);
			#endif

			xmashits = xmashits + 1;
		}

		te = te.chain;
	}

	// Special message if maximum hits is achieved..
	if (xmashits >= #SHAMBLER_XMAS_MAXHITS)
		bprint(#PRINT_MEDIUM,self.netname," wishes you #SHAMBLER_XMAS_MAXHITS a merry xmas!\n");

};
void() sham_xmas33 =[$magic9, sham_run1] {self.effects = 0;self.has_holo = 0;};

void() sham_xmas_removefx =
{
	self.owner.demon_three = world;
	dremove(self);
};

#endif
