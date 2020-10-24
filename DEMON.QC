void (float points, float type) custom_demon_create;
void () custom_demon_precache;
void () custom_grunt_die;
void () custom_shambler_die;
//Extern

/*void () army_stand1;
void () army_walk1;
void () army_run1;
void () army_atk1;*/

//void (entity attacker, float damage) army_pain;

void () sham_stand1;
void () sham_walk1;
void () sham_run1;
void () sham_melee;
void () sham_magic1;

//void () sham_fireball;

void (entity attacker, float damage) sham_pain;

float(entity obj, entity builder) CheckArea; //For demon summons

// -- OfN --
void(float tno, entity ignore) teamprefixsprint;
void() MonsterTouch;
void(string gibname, float dm) ThrowMonsterHead;
void(entity player, float slot) ResetSlotPointer;

/*
==============================================================================

DEMON

==============================================================================
*/

$cd /raid/quake/id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

//============================================================================
void() Demon_Water_Jump;
void()	Demon_JumpTouch;

void()	demon1_stand1	=[	$stand1,	demon1_stand2	] {ai_stand();};//Demon_Water_Jump();};
void()	demon1_stand2	=[	$stand2,	demon1_stand3	] {ai_stand();};
void()	demon1_stand3	=[	$stand3,	demon1_stand4	] {ai_stand();};
void()	demon1_stand4	=[	$stand4,	demon1_stand5	] {ai_stand();};
void()	demon1_stand5	=[	$stand5,	demon1_stand6	] {ai_stand();};
void()	demon1_stand6	=[	$stand6,	demon1_stand7	] {ai_stand();};
void()	demon1_stand7	=[	$stand7,	demon1_stand8	] {ai_stand();};
void()	demon1_stand8	=[	$stand8,	demon1_stand9	] {ai_stand();};
void()	demon1_stand9	=[	$stand9,	demon1_stand10	] {ai_stand();};
void()	demon1_stand10	=[	$stand10,	demon1_stand11	] {ai_stand();};
void()	demon1_stand11	=[	$stand11,	demon1_stand12	] {ai_stand();};
void()	demon1_stand12	=[	$stand12,	demon1_stand13	] {ai_stand();};
void()	demon1_stand13	=[	$stand13,	demon1_stand1	] {ai_stand();};

//WK Speeds doubled
#define DEMON_WALKFACTOR 1.25

void()	demon1_walk1	=[	$walk1, 	demon1_walk2	] {
Demon_Water_Jump();
if (random() < 0.2)
	sound (self, #CHAN_VOICE, "demon/idle1.wav", 1, #ATTN_IDLE);
ai_walk(8*#DEMON_WALKFACTOR); //8
};
void()	demon1_walk2	=[	$walk2, 	demon1_walk3	] {ai_walk(6*#DEMON_WALKFACTOR);}; //6
void()	demon1_walk3	=[	$walk3, 	demon1_walk4	] {ai_walk(6*#DEMON_WALKFACTOR);}; //6
void()	demon1_walk4	=[	$walk4, 	demon1_walk5	] {ai_walk(7*#DEMON_WALKFACTOR);}; //7
void()	demon1_walk5	=[	$walk5, 	demon1_walk6	] {ai_walk(4*#DEMON_WALKFACTOR);}; //4
void()	demon1_walk6	=[	$walk6, 	demon1_walk7	] {ai_walk(6*#DEMON_WALKFACTOR);}; //6
void()	demon1_walk7	=[	$walk7, 	demon1_walk8	] {ai_walk(10*#DEMON_WALKFACTOR);}; //10
void()	demon1_walk8	=[	$walk8, 	demon1_walk1	] {ai_walk(10*#DEMON_WALKFACTOR);}; //10

//WK Speeds doubled
void()	demon1_run1 =[	$run1,		demon1_run2 ] {
//Demon_Water_Jump();
if (random() < 0.2)
	sound (self, #CHAN_VOICE, "demon/idle1.wav", 1, #ATTN_IDLE);
ai_run(20);};
void()	demon1_run2 =[	$run2,		demon1_run3 ] {ai_run(15);};
void()	demon1_run3 =[	$run3,		demon1_run4 ] {ai_run(36);};
void()	demon1_run4 =[	$run4,		demon1_run5 ] {ai_run(20);};
void()	demon1_run5 =[	$run5,		demon1_run6 ] {ai_run(15);};
void()	demon1_run6 =[	$run6,		demon1_run1 ] {ai_run(36);};

void()	demon1_jump1	=[	$leap1, 	demon1_jump2	] {ai_face();};
void()	demon1_jump2	=[	$leap2, 	demon1_jump3	] {ai_face();};
void()	demon1_jump3	=[	$leap3, 	demon1_jump4	] {ai_face();};
void()	demon1_jump4	=[	$leap4, 	demon1_jump5	]
{
	ai_face();

	MonsterAuraPower();
	
	self.touch = Demon_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	if (self.tfstate & #TFSTATE_TRANQUILISED) //Cant jump as far
		self.velocity = v_forward * (600 * (#AI_TRANQ_FACTOR_UP / #AI_TRANQ_FACTOR_DN)) + '0 0 250';
	else
		self.velocity = v_forward * 600 + '0 0 250';
	if (self.has_sentry == #TRUE) //CH if stuck jump, jump higher
	{
		self.velocity_z = self.velocity_z + 200;
		self.has_sentry = 0;
	}

	if (self.has_tesla == #TRUE) //CH why tesla??  I like teslas and its a float
	{
//		sprint(self.real_owner,#PRINT_HIGH,"Demon Jello Jump!\n");
//		sound (self, #CHAN_VOICE, "misc/vapeur2.wav", 1, #ATTN_NONE);
		if (jello == #TRUE) //Binary on/off
			self.velocity_z = self.velocity_z + 1000;
		else
			self.velocity_z = self.velocity_z + jello;
		self.has_tesla = 0;
	}
	if (self.flags & #FL_ONGROUND)
		self.flags = self.flags - #FL_ONGROUND;
};
void()	demon1_jump5	=[	$leap5, 	demon1_jump6	] {};
void()	demon1_jump6	=[	$leap6, 	demon1_jump7	] {};
void()	demon1_jump7	=[	$leap7, 	demon1_jump8	] {};
void()	demon1_jump8	=[	$leap8, 	demon1_jump9	] {};
void()	demon1_jump9	=[	$leap9, 	demon1_jump10	] {self.has_teleporter = 0;};
//CH rather then a 3 sec wait.	bust up into 5	better jello effect
void()	demon1_jump10	=[	$leap10,	demon1_jump13	] {
	Demon_Water_Jump();
//CH just in case have a loop catcher
	self.has_teleporter = self.has_teleporter + 1;
	if (self.has_teleporter > 40 || self.velocity == '0 0 0') {
		self.has_sentry = #TRUE; //CH Stuck Jump
		self.think = demon1_jump1;
	}
	self.nextthink = time + 0.1;
};
void()	demon1_jump13	=[	$leap10,	demon1_jump10	] {
Demon_Water_Jump();
self.nextthink = time + 0.02;
};


void()	demon1_jump11	=[	$leap11,	demon1_jump12	] {};
void()	demon1_jump12	=[	$leap12,	demon1_run1 ] {};

//WK Speeds doubled
void()	demon1_atta1	=[	$attacka1,		demon1_atta2	] {ai_charge(8);};
void()	demon1_atta2	=[	$attacka2,		demon1_atta3	] {ai_charge(0);};
void()	demon1_atta3	=[	$attacka3,		demon1_atta4	] {ai_charge(0);
	MonsterAuraPower();
};
void()	demon1_atta4	=[	$attacka4,		demon1_atta5	] {ai_charge(2);};
void()	demon1_atta5	=[	$attacka5,		demon1_atta6	] {ai_charge(4); Demon_Melee(200);};
void()	demon1_atta6	=[	$attacka6,		demon1_atta7	] {ai_charge(2);};
void()	demon1_atta7	=[	$attacka7,		demon1_atta8	] {ai_charge(12);};
void()	demon1_atta8	=[	$attacka8,		demon1_atta9	] {ai_charge(16);};
void()	demon1_atta9	=[	$attacka9,		demon1_atta10] {ai_charge(8);};
void()	demon1_atta10	=[	$attacka10, 	demon1_atta11] {ai_charge(4);
	MonsterAuraPower();
};
void()	demon1_atta11	=[	$attacka11, 	demon1_atta12] {Demon_Melee(-200);};
void()	demon1_atta12	=[	$attacka12, 	demon1_atta13] {ai_charge(10);};
void()	demon1_atta13	=[	$attacka13, 	demon1_atta14] {ai_charge(16);};
void()	demon1_atta14	=[	$attacka14, 	demon1_atta15] {ai_charge(8);};
void()	demon1_atta15	=[	$attacka15, 	demon1_run1] {ai_charge(8);};

void()	demon1_pain1	=[	$pain1, 	demon1_pain2	] {};
void()	demon1_pain2	=[	$pain2, 	demon1_pain3	] {};
void()	demon1_pain3	=[	$pain3, 	demon1_pain4	] {};
void()	demon1_pain4	=[	$pain4, 	demon1_pain5	] {};
void()	demon1_pain5	=[	$pain5, 	demon1_pain6	] {};
void()	demon1_pain6	=[	$pain6, 	demon1_run1 ] {}; // was 1


//CH animation frame for demon throwing fire balls
void() demon1_fire1;
void(float side) Demon_Shoot_Fire;
void()	demon1_fire1	=[	$attacka1,		demon1_fire2	] {ai_charge(16);};
void()	demon1_fire2	=[	$attacka2,		demon1_fire3	] {ai_charge(8);};
void()	demon1_fire3	=[	$attacka3,		demon1_fire4	] {ai_charge(2);};
void()	demon1_fire4	=[	$attacka4,		demon1_fire5	] {ai_charge(4);
	MonsterAuraPower();
};
void()	demon1_fire5	=[	$attacka5,		demon1_fire6	] {ai_charge(8);};
void()	demon1_fire6	=[	$attacka6,		demon1_fire7	] {ai_charge(4); Demon_Shoot_Fire(-1);};
void()	demon1_fire7	=[	$attacka7,		demon1_fire8	] {ai_charge(24);};
void()	demon1_fire8	=[	$attacka8,		demon1_fire9	] {ai_charge(32);};
void()	demon1_fire9	=[	$attacka9,		demon1_fire10	] {ai_charge(16);};
void()	demon1_fire10	=[	$attacka10, 	demon1_fire11	] {ai_charge(8);
	MonsterAuraPower();
};
void()	demon1_fire11	=[	$attacka11, 	demon1_fire12	] {ai_charge(4); Demon_Shoot_Fire(1);};
void()	demon1_fire12	=[	$attacka12, 	demon1_fire13	] {ai_charge(20);};
void()	demon1_fire13	=[	$attacka13, 	demon1_fire14	] {ai_charge(32);};
void()	demon1_fire14	=[	$attacka14, 	demon1_fire15	] {ai_charge(16);};
void()	demon1_fire15	=[	$attacka15, 	demon1_run1 	] {ai_charge(16);};

void(entity attacker, float damage) demon1_pain =
{

	//self.real_owner.StatusRefreshTime = time + 0.2;
	//self.real_owner.StatusBarScreen = 3;
	
	if (self.touch == Demon_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	if (self.health <= 0)
		return; 	   

	//CH because its on the sbar :)

	if (random()*80 > damage)
		return; 	// didn't flinch

	AI_CheckAttacker(attacker);

	self.pain_finished = time + 0.8 + random() * 0.8;
	sound (self, #CHAN_VOICE, "demon/dpain1.wav", 1, #ATTN_NORM);
		
	demon1_pain1 ();
};

void()	demon1_die1 	=[	$death1,		demon1_die2 ] {
sound (self, #CHAN_VOICE, "demon/ddeath.wav", 1, #ATTN_MONSTERDIE);};
void()	demon1_die2 	=[	$death2,		demon1_die3 ] {};
void()	demon1_die3 	=[	$death3,		demon1_die4 ] {};
void()	demon1_die4 	=[	$death4,		demon1_die5 ] {};
void()	demon1_die5 	=[	$death5,		demon1_die6 ] {};
void()	demon1_die6 	=[	$death6,		demon1_die7 ]
{self.solid = #SOLID_NOT;};
void()	demon1_die7 	=[	$death7,		demon1_die8 ] {};
void()	demon1_die8 	=[	$death8,		demon1_die9 ] {};
void()	demon1_die9 	=[	$death9,		demon1_die9 ] 
{
	//self.nextthink = time + 40 + 40*random(); 
	//self.think = SUB_Remove;
	MonsterCorpse();
};

//void() monster_demon_respawn;

/*void() demon_die =
{
	self.oldorigin = self.origin;
// check for gib
	if (self.health < -80)
	{
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
		ThrowGib ("progs/h_demon.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
	
		self.lives = self.lives - 1;
		monster_demon_respawn();
		return;
	}

// regular death
	demon1_die1 ();
	//monster_demon_respawn();
};*/


void() Demon_MeleeAttack =
{
	demon1_atta1 ();
};


/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
/* UNUSED - OfN -
void() monster_demon1 =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	if (deathmatch)
	{
		dremove(self);
		return;
	}
	precache_model ("progs/demon.mdl");
	precache_model ("progs/h_demon.mdl");

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/sight2.wav");

	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;

	setmodel (self, "progs/demon.mdl");

	setsize (self, #VEC_HULL2_MIN, #VEC_HULL2_MAX);
	self.health = 300;
	self.has_tesla = 0; //CH Jello jump
	self.has_sentry = 0; //CH stuck jump
	self.has_camera = 0; //CH set name as 'demon'

	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = Demon_MeleeAttack;		// one of two attacks
	self.th_missile = demon1_jump1; 		// jump attack
	self.th_pain = demon1_pain;
	self.th_fireball = demon1_fire1; //CH
		
	walkmonster_start();
};*/


/*
==============================================================================

DEMON

==============================================================================
*/

/*
==============
CheckDemonMelee

Returns #TRUE if a melee attack would hit right now
==============
*/
float() CheckDemonMelee =
{
	local vector dist;
	local float d;

	if (enemy_range == #RANGE_MELEE)
	{
		dist = self.enemy.origin - self.origin;
		dist_x = dist_y = 0; //CH only need z
		d = vlen(dist);
		if (d < 100) //CH Check reach
			{
				self.attack_state = #AS_MELEE;
				return #TRUE;
			}
	}
	return #FALSE;
};

/*
==============
CheckDemonFireBall
==============
inp = 0 normal check
inp = 1 check for long range
*/
float(float inp) CheckDemonFireBall =
{
	local	vector	dist;
	local	float	d;
	local float d2;

	if (!visible2(self.enemy, self)) //If can see
		return #FALSE;
	dist = self.enemy.origin - self.origin;
	dist_z = 0; //CH only need x,y
	d2 = vlen(dist);
	dist = self.enemy.origin - self.origin;
	dist_x = dist_y = 0; //CH only need z
	d = vlen(dist);
	if (inp == 1) //Range attack
	{
		if (random() < 0.9) //CH as not to fire all the time
			return #FALSE;
		if (d2 < 600) //Min X,Y distance away before throw fireball
			return #FALSE;
		return #TRUE;
	}
	else //Normal attack
	{
		if (random() > 0.9) //CH as not to fire all the time
			return #FALSE;
		if (d2 < 200) //Min X,Y distance away before throw fireball
			return #FALSE;
		if (d < 100) //Min Z distance away before throw fireball
			return #FALSE;
		return #TRUE;
	}
};

/*
==============
CheckDemonJump
==============
*/
float() CheckDemonJump =
{
	local	vector	dist;
	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return #FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return #FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 100)
		return #FALSE;
		
	if (d > 200)
	{
		if (random() < 0.95) //WK 0.9 Make it jump less often
			return #FALSE;
	}
		
	return #TRUE;
};

float() DemonCheckAttack =
{
//	local	vector	vec;
	
// if close enough for slashing, go for it
	if (CheckDemonMelee ())
	{
		self.attack_state = #AS_MELEE;
		return #TRUE;
	}

	if (CheckDemonJump ())
	{
		self.attack_state = #AS_MISSILE;
		sound (self, #CHAN_VOICE, "demon/djump.wav", 1, #ATTN_NORM);
		return #TRUE;
	}

	if (CheckDemonFireBall(0)) //Normal
	{
		self.attack_state = #AS_FIREBALL;
		return #TRUE;
	}
	if (CheckDemonFireBall(1)) //Ranged
	{
		self.attack_state = #AS_FIREBALL;
		return #TRUE;
	}
	
	return #FALSE;
};


//===========================================================================

void(float side)	Demon_Melee =
{
	local	float	ldmg;
	local vector	delta;
	
	ai_face ();
	// WK walkmove (self.ideal_yaw, 12);	// allow a little closing
	walkmove (self.ideal_yaw, 24);	// allow a lot closing

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 120)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	deathmsg = 0; //CH
	sound (self, #CHAN_WEAPON, "demon/dhit2.wav", 1, #ATTN_NORM);
	//WK ldmg = 10 + 5*random();
	ldmg = 80 + 40*random();
	if (self.enemy.tf_items & #NIT_GEL)
		ldmg = ldmg / 2;
	if (self.enemy.cutf_items & #CUTF_DEMONLORE)
		ldmg = ldmg * 0.8;
	
	//T_Damage (self.enemy, self, self, ldmg);
	TF_T_Damage(self.enemy, self, self, ldmg,0,#TF_TD_MELEE); //WK 4/27/7

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};

//===========================================================================
//CH demon shoots fire...
void() demon_fire_touch;
void(float side) Demon_Shoot_Fire =
{
//	local	float	ldmg;
	local vector	delta;
	local	vector	offang;
	local	vector	org, dir;
	
	ai_face ();
	walkmove (self.ideal_yaw, 12);	// allow a little closing

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
	dir_z = 0 - dir_z + (random() - 0.5)*0.1; //Random Z addage
	dir_x = dir_x + (random() - 0.5)*0.05; //Random X addage
	dir_y = dir_y + (random() - 0.5)*0.05; //Random Y addage
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_FLYMISSILE;
	newmis.solid = #SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = demon_fire_touch;
	newmis.weapon = #DMSG_DEMON_FIRE;
	newmis.classname = "demon_fire";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/lavaball.mdl");
//	setsize (newmis, '-4 -8 -4', '10 8 14'); //CH actual mdl bounds
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);
	newmis.velocity = dir * 1000;
};
void() demon_fire_touch =
{
	local float fire_dmg;
	fire_dmg = 60 + random()*40;
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

void() Demon_Water_Jump =
{
	traceline(self.origin,self.origin - '0 0 2',#TL_BSP_ONLY,self);
	if (trace_inwater == #TRUE && jello)
	{
		ai_face();
		//self.touch = SUB_Null;
		self.touch = MonsterTouch; // OfN
		self.think = demon1_jump4;
		self.has_tesla = #TRUE; //Landed in water
		self.nextthink = time + 0.1;
	}
};
void()	Demon_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;
	deathmsg = 0; //CH

	//WK Jello water support
	//CH a working version.
	traceline(self.origin,self.origin - '0 0 2',#TL_BSP_ONLY,self);
	if (trace_inwater == #TL_BSP_ONLY && jello)
	{
		//self.touch = SUB_Null;
		self.touch = MonsterTouch; // OfN
		self.think = demon1_jump1;
		self.has_tesla = #TRUE; //Landed in water
		self.nextthink = time + 0.1;
		return;
	}
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 400 )
		{
			//WK ldmg = 40 + 10*random();
			ldmg = 120 + 30*random();
			if (other.cutf_items & #CUTF_DEMONLORE)
				ldmg = ldmg * 0.8;
			
			TF_T_Damage(other, self, self, ldmg,0,#TF_TD_MELEE); //WK 4/27/7
			//T_Damage (other, self, self, ldmg);	
			//WK Comment out this next line for demon-head hopping action!
			if (self.think == SUB_Remove) return; //We can die when killing owner
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & #FL_ONGROUND)
		{	// jump randomly to not get hung up
			//RPrint ("popjump\n");
			//sprint(self.real_owner,#PRINT_HIGH,"Stuck Jump flag set!\n");
			self.has_sentry = #TRUE; //CH Stuck Jump
			//self.touch = SUB_Null;
			self.touch = MonsterTouch; // OfN
			self.think = demon1_jump1;
			self.nextthink = time + 0.1;

			//self.velocity_x = (random() - 0.5) * 600;
			//self.velocity_y = (random() - 0.5) * 600;
			//self.velocity_z = 200;
			//self.flags = self.flags - #FL_ONGROUND;
		}
		return; // not on ground yet
	}

	self.has_sentry = 0; //Cancel if this far
	//self.touch = SUB_Null;
	self.touch = MonsterTouch; // OfN
	self.think = demon1_jump11;
	self.nextthink = time + 0.1;
};

/*UNUSED - OfN -
void() respawn_demon =
{
	self = self.owner;

	self.origin = self.oldorigin;
	spawn_tfog(self.origin);
	spawn_tdeath(self.origin, self);
	setorigin(self, self.origin);

	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;
	self.takedamage = #DAMAGE_AIM;

	setmodel (self, "progs/demon.mdl");

	setsize (self, #VEC_HULL2_MIN, #VEC_HULL2_MAX);
	self.health = 300;
	self.oldorigin = self.origin;

	self.target = string_null;

	HuntTarget();
	dremove(self.owner);
};*/

/*UNUSED - OfN -
void() monster_demon_respawn = 
{
	local entity resp;

	if (self.lives <= 0.5)
		return;

	self.lives = self.lives - 1;

	resp = spawn();

	self.owner = resp;
	resp.owner = self;

	resp.think = respawn_demon;
	resp.nextthink = time + 10;
};*/

/*
 * WK - Pet demon functions
*/

void () custom_demon_die = 
{
	if (self.real_owner.classname == "player")
	{
		sprint(self.real_owner,#PRINT_HIGH,"Your fiend ");
		sprint(self.real_owner,#PRINT_HIGH,self.netname);
		sprint(self.real_owner,#PRINT_HIGH," is dead.\n");
		self.real_owner.job_finished = time + 5; //Can't summon streams of demons SB can so
		ResetSlotPointer(self.real_owner, self.increase_team1);
	}
	
	if (self.health < -40) 
	{
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_MONSTERDIE);
		ThrowMonsterHead ("progs/h_demon.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health, #TRUE, 0, #GIB3_KGS, #FALSE);
		ThrowGib ("progs/gib2.mdl", self.health, #TRUE, 0, #GIB2_KGS, #FALSE);
		ThrowGib ("progs/gib3.mdl", self.health, #TRUE, 0, #GIB3_KGS, 0.5);
		SpawnBloodEx(self.origin,0.66,9);
		
		dremove(self);
		return;
	}

	// Spawn bubbles if under water/slime
	local float contres;
	contres = pointcontents(self.origin);
	if (contres == #CONTENT_WATER || contres == #CONTENT_SLIME)
		DeathBubbles(5);

	//self.classname = "monster_corpse";
	MonsterDead();
	self.think=SUB_Null;
	demon1_die1 ();
};

