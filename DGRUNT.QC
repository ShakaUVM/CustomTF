//Extern
//float(entity obj, entity builder) CheckArea; //For demon summons
void (entity targ) GetRank;
void() Grunty_Check_Frags;

/*
==============================================================================

GRUNT

==============================================================================
*/

$cd /raid/quake/id1/models/soldier3
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11

$frame load1 load2 load3 load4 load5 load6 load7 load8 load9 load10 load11

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10
$frame painc11 painc12 painc13

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9

$frame prowl_1 prowl_2 prowl_3 prowl_4 prowl_5 prowl_6 prowl_7 prowl_8
$frame prowl_9 prowl_10 prowl_11 prowl_12 prowl_13 prowl_14 prowl_15 prowl_16
$frame prowl_17 prowl_18 prowl_19 prowl_20 prowl_21 prowl_22 prowl_23 prowl_24

//============================================================================
void() army_fire;

void()	army_stand1 =[	$stand1,	army_stand2 ] {ai_stand();Grunty_Check_Frags();};
void()	army_stand2 =[	$stand2,	army_stand3 ] {ai_stand();};
void()	army_stand3 =[	$stand3,	army_stand4 ] {ai_stand();};
void()	army_stand4 =[	$stand4,	army_stand5 ] {ai_stand();};
void()	army_stand5 =[	$stand5,	army_stand6 ] {ai_stand();};
void()	army_stand6 =[	$stand6,	army_stand7 ] {ai_stand();};
void()	army_stand7 =[	$stand7,	army_stand8 ] {ai_stand();};
void()	army_stand8 =[	$stand8,	army_stand1 ] {ai_stand();};

void()	army_walk1	=[	$prowl_1,	army_walk2	] {
if (random() < 0.2)
	sound (self, #CHAN_VOICE, "soldier/idle.wav", 1, #ATTN_IDLE);
ai_walk(1);};
void()	army_walk2	=[	$prowl_2,	army_walk3	] {ai_walk(1);Grunty_Check_Frags();};
void()	army_walk3	=[	$prowl_3,	army_walk4	] {ai_walk(1);};
void()	army_walk4	=[	$prowl_4,	army_walk5	] {ai_walk(1);};
void()	army_walk5	=[	$prowl_5,	army_walk6	] {ai_walk(2);};
void()	army_walk6	=[	$prowl_6,	army_walk7	] {ai_walk(3);};
void()	army_walk7	=[	$prowl_7,	army_walk8	] {ai_walk(4);};
void()	army_walk8	=[	$prowl_8,	army_walk9	] {ai_walk(4);};
void()	army_walk9	=[	$prowl_9,	army_walk10 ] {ai_walk(2);};
void()	army_walk10 =[	$prowl_10,	army_walk11 ] {ai_walk(2);};
void()	army_walk11 =[	$prowl_11,	army_walk12 ] {ai_walk(2);};
void()	army_walk12 =[	$prowl_12,	army_walk13 ] {ai_walk(1);};
void()	army_walk13 =[	$prowl_13,	army_walk14 ] {ai_walk(0);};
void()	army_walk14 =[	$prowl_14,	army_walk15 ] {ai_walk(1);};
void()	army_walk15 =[	$prowl_15,	army_walk16 ] {ai_walk(1);};
void()	army_walk16 =[	$prowl_16,	army_walk17 ] {ai_walk(1);};
void()	army_walk17 =[	$prowl_17,	army_walk18 ] {ai_walk(3);};
void()	army_walk18 =[	$prowl_18,	army_walk19 ] {ai_walk(3);};
void()	army_walk19 =[	$prowl_19,	army_walk20 ] {ai_walk(3);};
void()	army_walk20 =[	$prowl_20,	army_walk21 ] {ai_walk(3);};
void()	army_walk21 =[	$prowl_21,	army_walk22 ] {ai_walk(2);};
void()	army_walk22 =[	$prowl_22,	army_walk23 ] {ai_walk(1);};
void()	army_walk23 =[	$prowl_23,	army_walk24 ] {ai_walk(1);};
void()	army_walk24 =[	$prowl_24,	army_walk1	] {ai_walk(1);};

void()	army_run1	=[	$run1,		army_run2	] {
if (random() < 0.2)
	sound (self, #CHAN_VOICE, "soldier/idle.wav", 1, #ATTN_IDLE);
ai_run(11);};
void()	army_run2	=[	$run2,		army_run3	] {ai_run(15);Grunty_Check_Frags();};
void()	army_run3	=[	$run3,		army_run4	] {ai_run(10);};
void()	army_run4	=[	$run4,		army_run5	] {ai_run(10);};
void()	army_run5	=[	$run5,		army_run6	] {ai_run(8);};
void()	army_run6	=[	$run6,		army_run7	] {ai_run(15);};
void()	army_run7	=[	$run7,		army_run8	] {ai_run(10);};
void()	army_run8	=[	$run8,		army_run1	] {ai_run(8);};

void()	army_atk1	=[	$shoot1,	army_atk2	] {ai_face();};
void()	army_atk2	=[	$shoot2,	army_atk3	] {ai_face();};
void()	army_atk3	=[	$shoot3,	army_atk4	] {ai_face();};
void()	army_atk4	=[	$shoot4,	army_atk5	] {ai_face();};
void()	army_atk5	=[	$shoot5,	army_atk6	] {ai_face();army_fire();
self.effects = self.effects | #EF_DIMLIGHT;};
void()	army_atk6	=[	$shoot6,	army_atk7	] {ai_face(); self.effects = 0;};
void()	army_atk7	=[	$shoot7,	army_atk8	] {ai_face();SUB_CheckRefire (army_atk1);};
void()	army_atk8	=[	$shoot8,	army_atk9	] {ai_face();};
void()	army_atk9	=[	$shoot9,	army_run1	] {ai_face();};

void()	army_pain1	=[	$pain1, 	army_pain2	] {};
void()	army_pain2	=[	$pain2, 	army_pain3	] {};
void()	army_pain3	=[	$pain3, 	army_pain4	] {};
void()	army_pain4	=[	$pain4, 	army_pain5	] {};
void()	army_pain5	=[	$pain5, 	army_pain6	] {};
void()	army_pain6	=[	$pain6, 	army_run1	] {ai_pain(1);};

void()	army_painb1 =[	$painb1,	army_painb2 ] {};
void()	army_painb2 =[	$painb2,	army_painb3 ] {ai_painforward(13);};
void()	army_painb3 =[	$painb3,	army_painb4 ] {ai_painforward(9);};
void()	army_painb4 =[	$painb4,	army_painb5 ] {};
void()	army_painb5 =[	$painb5,	army_painb6 ] {};
void()	army_painb6 =[	$painb6,	army_painb7 ] {};
void()	army_painb7 =[	$painb7,	army_painb8 ] {};
void()	army_painb8 =[	$painb8,	army_painb9 ] {};
void()	army_painb9 =[	$painb9,	army_painb10] {};
void()	army_painb10=[	$painb10,	army_painb11] {};
void()	army_painb11=[	$painb11,	army_painb12] {};
void()	army_painb12=[	$painb12,	army_painb13] {ai_pain(2);};
void()	army_painb13=[	$painb13,	army_painb14] {};
void()	army_painb14=[	$painb14,	army_run1	] {};

void()	army_painc1 =[	$painc1,	army_painc2 ] {};
void()	army_painc2 =[	$painc2,	army_painc3 ] {ai_pain(1);};
void()	army_painc3 =[	$painc3,	army_painc4 ] {};
void()	army_painc4 =[	$painc4,	army_painc5 ] {};
void()	army_painc5 =[	$painc5,	army_painc6 ] {ai_painforward(1);};
void()	army_painc6 =[	$painc6,	army_painc7 ] {ai_painforward(1);};
void()	army_painc7 =[	$painc7,	army_painc8 ] {};
void()	army_painc8 =[	$painc8,	army_painc9 ] {ai_pain(1);};
void()	army_painc9 =[	$painc9,	army_painc10] {ai_painforward(4);};
void()	army_painc10=[	$painc10,	army_painc11] {ai_painforward(3);};
void()	army_painc11=[	$painc11,	army_painc12] {ai_painforward(6);};
void()	army_painc12=[	$painc12,	army_painc13] {ai_painforward(8);};
void()	army_painc13=[	$painc13,	army_run1] {};

void(entity attacker, float damage) army_pain =
{
	local float r;
	
	if (self.pain_finished > time)
		return;
		
	self.real_owner.StatusRefreshTime = time + 0.2;
	self.real_owner.StatusBarScreen = 3;

	r = random();

	if ( r < 0.99 )
		return;

	r = random();
	
	if (r < 0.2)
	{
		self.pain_finished = time + 0.6;
		army_pain1 ();
		sound (self, #CHAN_VOICE, "soldier/pain1.wav", 1, #ATTN_NORM);
	}
	else if (r < 0.6)
	{
		self.pain_finished = time + 1.1;
		army_painb1 ();
		sound (self, #CHAN_VOICE, "soldier/pain2.wav", 1, #ATTN_NORM);
	}
	else
	{
		self.pain_finished = time + 1.1;
		army_painc1 ();
		sound (self, #CHAN_VOICE, "soldier/pain2.wav", 1, #ATTN_NORM);
	}
};

void() army_fire =
{
	local	vector	dir;
	local	entity	en;
	
	ai_face();
	
	sound (self, #CHAN_WEAPON, "soldier/sattck1.wav", 1, #ATTN_NORM);	

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;
	
	dir = en.origin - en.velocity*0.1;
	dir = normalize (dir - self.origin);
	
	FireBullets (30 * self.has_tesla, dir, '0.1 0.1 0');
};

void() custom_grunt_die = 
{
	sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
	ThrowGib ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health); //- was gib1
	ThrowGib ("progs/gib3.mdl", self.health); //- was gib1

	if (self.real_owner.classname == "player")
	{
		sprint(self.real_owner,#PRINT_HIGH,"Your soldier has been killed\n");
		//self.real_owner.job = self.real_owner.job - (self.real_owner.job & #JOB_DEMON_OUT);
		self.real_owner.demon_points = self.real_owner.demon_points + 2;
		self.real_owner.job_finished = time + 10; //Can't summon streams of demons
	}
	dremove(self);
};

float () SoldierCheckAttack =
{
	if (visible(self.enemy))
	{
		self.attack_state = #AS_MISSILE;
		return #TRUE;
	}
	return #FALSE;
};

void (entity targ) GetRank =
{
	if (targ.has_sensor == 1)
		targ.undercover_name = "Private Class III ";
	else if (targ.has_sensor == 2)
		targ.undercover_name = "Private Class II ";
	else if (targ.has_sensor == 3)
		targ.undercover_name = "Private Class I ";
	else if (targ.has_sensor == 4)
		targ.undercover_name = "Lance Corporal ";
	else if (targ.has_sensor == 5)
		targ.undercover_name = "Corporal ";
	else if (targ.has_sensor == 6)
		targ.undercover_name = "Sergeant ";
	else if (targ.has_sensor == 7)
		targ.undercover_name = "Staff Sergeant ";
	else if (targ.has_sensor == 8)
		targ.undercover_name = "Warrant Officer II ";
	else if (targ.has_sensor == 9)
		targ.undercover_name = "Warrant Officer I ";
	else if (targ.has_sensor == 10)
		targ.undercover_name = "Lieutenant Class II ";
	else if (targ.has_sensor == 11)
		targ.undercover_name = "Lieutenant Class I ";
	else if (targ.has_sensor == 12)
		targ.undercover_name = "Captain ";
	else if (targ.has_sensor == 13)
		targ.undercover_name = "Major ";
	else if (targ.has_sensor == 14)
		targ.undercover_name = "Colonel ";
	else if (targ.has_sensor == 15)
		targ.undercover_name = "Brigadier ";
	else if (targ.has_sensor == 16)
		targ.undercover_name = "General ";
	else if (targ.has_sensor == 17)
		targ.undercover_name = "Field Marshal ";
	else
		targ.undercover_name = "Error producer ";
};

void() Grunty_Check_Frags =
{
	if (self.frags >= self.has_sentry && self.has_sensor < 17)
	{
		self.has_tesla = 0.9 + 0.2;
		self.has_sensor = self.has_sensor + 1;
		self.has_sentry = self.has_sentry + 2;
		self.health = self.health + self.has_sensor * 25;
		self.max_health = self.max_health + self.has_sensor * 25;
		if (self.health > self.max_health)
			self.health = self.max_health;
		//custom_demon_name(self);
		GetRank(self);
		sprint(self.real_owner, #PRINT_HIGH, "Your soldier, ");
		sprint(self.real_owner, #PRINT_HIGH, self.netname);
		sprint(self.real_owner, #PRINT_HIGH, ", has reached the rank of ");
		sprint(self.real_owner, #PRINT_HIGH, self.undercover_name);
		sprint(self.real_owner, #PRINT_HIGH, "\n");
	}
};