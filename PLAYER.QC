/*======================================================
	PLAYER.QC			Custom TeamFortress v3.1

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney			5/21/00
	(c) Craig Hauser				19/3/00
========================================================
Handles all player animations, death and etc. Most weapon
firings get shunted through here.
======================================================*/
/*
	Heavily Modified for TeamFortress V1.21
	TeamFortress Software
	Robin Walker, John Cook, Ian Caughley
*/

// Prototypes
void() bubble_bob;
void() W_FireAssaultCannon;
void() W_FireLightAssault;

void() Throw_Grapple;

// TeamFortress Prototypes
void() BioInfection_Decay;
void() TeamFortress_RemoveTimers;
void() T_Dispenser;
//void() Headless_Think;

// OfN
void(entity deadone, float corpse_tolerance) MakeCorpse;
void(vector where, float bloodtype, float bloodammount) SpawnBloodEx;

/*
==============================================================================

PLAYER

==============================================================================
*/

$cd /raid/quake/id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

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

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
==============================================================================
PLAYER
==============================================================================
*/
void() player_touch =
{
	//local entity te;
	
	// Spies and Scouts can uncloak enemy spies
	// WK Or those with Spy kits & Scanners
	if (invis_only == #FALSE && (self.cutf_items & #CUTF_SPY_KIT || other.cutf_items & #CUTF_SPY_KIT))
	{
		if (other.classname == "player")
		{
			if (self.undercover_team != 0 || self.undercover_skin != 0)
			{
				if ((other.cutf_items & #CUTF_SPY_KIT || other.tf_items & #NIT_SCANNER) && !Teammate(self, other))
				{
					sprint(other, #PRINT_HIGH, "Wait a minute... he's a Spy!\n");
					sprint(self, #PRINT_HIGH, "The enemy sees through your disguise!\n");
					Spy_RemoveDisguise(self);
				}
			}
			if (other.undercover_team != 0 || other.undercover_skin != 0)
			{
				if ((self.cutf_items & #CUTF_SPY_KIT || self.tf_items & #NIT_SCANNER) && !Teammate(other, self))
				{
					sprint(self, #PRINT_HIGH, "Wait a minute... he's a Spy!\n");
					sprint(other, #PRINT_HIGH, "The enemy sees through your disguise!\n");
					Spy_RemoveDisguise(other);
				}
			}
		}
	}

	//WK 4/27/7 Boot to the Head! Taekwondo code
	//Tae Kwon Do! Tae Kwon Do!
	//This looks a bit odd since the stationary person being run INTO is Self, so the TKD person is Other.
	if (other.job & #JOB_TKD && self.takedamage && self.health > 0 && other.health > 0) {
		local float playerspeed,player2speed;
		playerspeed = vlen(other.last_frame_velocity); //Kicker speed
		player2speed = vlen(self.last_frame_velocity); //Kickee speed
		deathmsg = #DMSG_TKD; //WK 8-15-08 Fix deathmsg bug with TKD
		if (!Teammate(self, other) && !UndercoverTeammate(self,other)) {
			//TODO Check to make sure the person is in front of us. Dotproduct origin and velocity vectors
			if (self.job & #JOB_TKD) { //TWO TKD GUYS!
				//The faster guy punches the slower (with a faster cooldown)
				if (playerspeed > player2speed && other.last_boot_to_the_head < time) { //Other is faster
					TF_T_Damage (self, other, other, playerspeed / 12, #TF_TD_NOTTEAM, #TF_TD_MELEE);
					other.last_boot_to_the_head = time + 2;
					sprint (other, #PRINT_HIGH, "You punch him in the face!\n");
					sprint (self, #PRINT_HIGH, "You get punched in the face!\n");
				} else if (player2speed > playerspeed && self.last_boot_to_the_head < time) { //Self is faster
					TF_T_Damage (other, self, self, player2speed / 12, #TF_TD_NOTTEAM, #TF_TD_MELEE);
					self.last_boot_to_the_head = time + 2;
					sprint (self, #PRINT_HIGH, "You hit him with a devestating spear hand punch!\n");
					sprint (other, #PRINT_HIGH, "He hits you with a devestating kwan soo kong kyuck!\n");
				}

				//Issue TKD Challenge (if neither side is juiced already)
				local float score;
				//WK 1-19-09 Reduced duel duration by a significant amount
				score = 2; //Seconds for duel to last
				if (!(self.items & #IT_QUAD) && !(other.items & #IT_QUAD)) {
					if (random() < 0.4) {
						bprint(#PRINT_HIGH,other.netname);
						bprint(#PRINT_HIGH," issues a Tae Kwon Do challenge to ");
						bprint(#PRINT_HIGH,self.netname);
						bprint(#PRINT_HIGH,". Let the battle begin!\n");
						sound (other, #CHAN_WEAPON, "shambler/melee2.wav", 1, #ATTN_NORM);
					} else if (random() < 0.5) {
						bprint(#PRINT_HIGH,other.netname);
						bprint(#PRINT_HIGH," yells TAE KWON DO!\n");
						bprint(#PRINT_HIGH,self.netname);
						bprint(#PRINT_HIGH," yells TAE KWON DO!\n");
						sound (other, #CHAN_WEAPON, "shambler/melee1.wav", 1, #ATTN_NORM);
						score = 3;
					} else if (random() < 0.5) {
						bprint(#PRINT_HIGH,other.netname);
						bprint(#PRINT_HIGH," and ");
						bprint(#PRINT_HIGH,self.netname);
						bprint(#PRINT_HIGH," begin the Duel of the Iron Mic! (8s)\n");
						sound (other, #CHAN_WEAPON, "shambler/melee1.wav", 1, #ATTN_NORM);
						score = 8;
					} else if (random() < 0.66) {
						bprint(#PRINT_HIGH,other.netname);
						bprint(#PRINT_HIGH," and ");
						bprint(#PRINT_HIGH,self.netname);
						bprint(#PRINT_HIGH," begin their samurai showdown! (12s)\n");
						sound (other, #CHAN_WEAPON, "shambler/melee1.wav", 1, #ATTN_NORM);
						score = 12;
					} else {
						bprint(#PRINT_HIGH,other.netname);
						bprint(#PRINT_HIGH," and ");
						bprint(#PRINT_HIGH,self.netname);
						bprint(#PRINT_HIGH," begin a duel without honor or humanity! (20s)\n");
						sound (other, #CHAN_WEAPON, "shambler/melee1.wav", 1, #ATTN_NORM);
						score = 20;
					}

					//Juiced
					//WK 1-19-09 Halved delay before duel begins
					self.items = self.items | #IT_QUAD;
					self.super_damage_finished = time + score;
					self.super_time = 1;
					if (self.attack_finished < time)
						self.attack_finished = time + 0.75;
					if (self.job_finished < time)
						self.job_finished = time + 1.5;

					//WK 8/4/7 Made both people equal //Faster recovery since we picked the fight!
					other.items = other.items | #IT_QUAD;
					other.super_damage_finished = time + score;
					other.super_time = 1;
					if (self.attack_finished < time)
						self.attack_finished = time + 0.75;
					if (self.job_finished < time)
						self.job_finished = time + 1.5;

					//WK 5-15-8 Make them each other's enemies so that we restrict their quad damage just to each other.
					self.martyr_enemy = other;
					other.martyr_enemy = self;

					//WK 5-15-7 Remove all primed grenades so they don't blow up on them accidentally
					local entity te;
					te = find(world,classname,"grenade_timer");
					while (te)
					{
						if (te.owner == self || te.owner == other)
						{
							te.nextthink = time + 0.1;
							te.think = SUB_Remove;
						}
						te = find(te,classname,"grenade_timer");
					}
					self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_GRENPRIMED);
					self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_GRENTHROWING);
					other.tfstate = other.tfstate - (other.tfstate & #TFSTATE_GRENPRIMED);
					other.tfstate = other.tfstate - (other.tfstate & #TFSTATE_GRENTHROWING);
				}			
				if (other.last_push < time) {
					//Push each self away, and up.
					//5-15-08 TKDist bounce better now
					//WK 2-2-09 Reduce upkick by a bit
					self.velocity_x = 1.2 * other.last_frame_velocity_x;
					self.velocity_y = 1.2 * other.last_frame_velocity_y;
					self.velocity_z = other.last_frame_velocity_z + 150;
					other.velocity_x = -1.2 * other.last_frame_velocity_x;
					other.velocity_y = -1.2 * other.last_frame_velocity_y;
					other.velocity_z = other.last_frame_velocity_z;
					other.last_push = time + 0.5;
				}
			} else {
				if (other.last_boot_to_the_head < time && playerspeed > 225) {
					//Damage depends on how fast we are 
					//We save the last_frame_velocity because the collision kills the speed before we get here.

					//5-15-08 Now that we know we're at least moving a little, we want to really just look at the difference in vectors
					local vector temp_vector;
					temp_vector = other.velocity - self.velocity;
					playerspeed = vlen(temp_vector);

					/* Debug Information */
					local string temp_foo;
					temp_foo = ftos(playerspeed);
					sprint(other,#PRINT_HIGH,"(Speed: ");
					sprint(other,#PRINT_HIGH,temp_foo);
					sprint(other,#PRINT_HIGH,") ");

					deathmsg = #DMSG_TKD;

					if (playerspeed < 400) { //Stationary kick
						if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "Boot to the head!\n");
						else if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You hit him with a front snap kick!\n");
						else
							sprint (other, #PRINT_HIGH, "You hit him with a quick roundhouse kick!\n");
						sprint (self, #PRINT_HIGH, "BOOT TO THE HEAD!\n");
					} else if (playerspeed < 800) { //Moving kick
						if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You deliver a sliding sidekick to his head!\n");
						else if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You deliver a sliding back kick to his stomach!\n");
						else
							sprint (other, #PRINT_HIGH, "You hit him with a sliding axe kick!\n");
						sprint (self, #PRINT_LOW, "BIG BOOT TO THE HEAD!\n");
					} else if (playerspeed < 1050) { //Flying kick
						if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You deliver a flying tornado kick to his head!\n");
						else if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You slam into him with a jumping side kick!\n");
						else if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You hit him with a double jumping front push kick!\n");
						else
							sprint (other, #PRINT_HIGH, "You strike him in a vital point!!\n");
						sprint (self, #PRINT_LOW, "MIGHTY BOOT TO YOUR HEAD!\n");
					} else {
						playerspeed = 1200; //Cap damage at 100
						if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You demolish him with a flying death kick!!\n");
						else if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You break his neck with a light speed roundhouse!!\n");
						else if (random() < 0.5)
							sprint (other, #PRINT_HIGH, "You hit him with a front-round-side combination kick within a half second!!\n");
						else
							sprint (other, #PRINT_HIGH, "You utterly devastate your opponent. Pilsung!!\n");
						sprint (self, #PRINT_HIGH, "You were critically kicked by your opponent!\n");
					}
					TF_T_Damage (self, other, other, playerspeed / 12, #TF_TD_NOTTEAM, #TF_TD_MELEE);
					other.last_boot_to_the_head = time + 4;
				}
				//Even if our boot timer is down, we can still push him around on a different timer.
				//It stops us every time we push though
				//Kick him through the air! Inelastic colision for 90% of total momentum.
				//HWGUYs can't be punted.
				if (other.last_push < time) {
					if (!(self.cutf_items & #CUTF_HWGUY) && playerspeed > 300) {
						other.velocity = '0 0 200'; //Deliver all our force into the kick! Whapow!
						self.velocity_x = other.last_frame_velocity_x * 0.9;
						self.velocity_y = other.last_frame_velocity_y * 0.9;
						if (other.last_frame_velocity_z > 0)
							self.velocity_z = other.last_frame_velocity_z + 180; //Lift him a bit
						else
							self.velocity_z = other.last_frame_velocity_z - 180; //Punting him down
						other.last_push = time + 1;
					} else if (self.cutf_items & #CUTF_HWGUY) { //Bounce off HWGUYs =)
						other.velocity_x = other.last_frame_velocity_x * -1.2;
						other.velocity_y = other.last_frame_velocity_y * -1.2;
						other.velocity_z = other.last_frame_velocity_z + 180; //Lift him a bit
						other.last_push = time + 0.5;
					}
				}
			}
		}
	}

	// Pass on infections
	if (self.tfstate & #TFSTATE_INFECTED)
	{
		local entity Bio;
	
		//WK Melee armor stops infections from spreading
		if (other.classname == "player" && !(other.invincible_finished) && !(other.armorclass & #AT_SAVEMELEE))
		{
			// may sure other player is not already infected
			if (!(other.tfstate & #TFSTATE_INFECTED))
			{
				// can't infect the medic
				if (!(other.weapons_carried & #WEAP_MEDIKIT)) //WK
				{
					// infect 'em
					Bio = spawn ();
					Bio.nextthink = 2;
					Bio.think = BioInfection_Decay;
/* WK Why doesn't this work??? Causes occasional program crashes...
					//WK The owner is the original medic if spreading to friend
					if (self.team_no == other.team_no) {
						te = find(world, netname, "biotimer");
						while ((te.owner != self) && (te != world))
							te = find(te, netname, "biotimer");
						if (te != world)
							Bio.enemy = te.enemy; //Person infecting							
						else
							RPrint("CustomTF: Odd Behavior in infection spreading");
					}
					else */
						Bio.enemy = self; //Person causing infection
					Bio.owner = other; //Person getting hurt
					Bio.classname = "timer";
					Bio.netname = "biotimer";
					
					other.tfstate = other.tfstate | #TFSTATE_INFECTED;
					other.infection_team_no = self.infection_team_no;

					sprint(other, #PRINT_MEDIUM, "You have been infected by ");
					sprint(other, #PRINT_MEDIUM, self.netname);
					sprint(other, #PRINT_MEDIUM, "!\n");
					sprint(self, #PRINT_MEDIUM, "You have infected ");
					sprint(self, #PRINT_MEDIUM, other.netname);
					sprint(self, #PRINT_MEDIUM, "!\n");
					//-OfN
					teamprefixsprintbi(other.team_no,other,self);
					teamsprintbi(other,self, other.netname," has been infected!\n","","","","");
				}				
			}
		}
		else if (IsMonster(other))
		{
			if (!(other.tfstate & #TFSTATE_INFECTED))
			{
				// Report to owner
				local string tmps;
				tmps = GetMonsterName(other);
				sprint(other.real_owner,#PRINT_HIGH,"Your ",tmps," ",other.netname," has been infected!\n");

				// Report infecter
				sprint(self,#PRINT_HIGH,"You have infected the ",tmps," ",other.netname,"!\n");

				// Report to teammates of owner
				local string tmps;
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
	}
/* WK 4/27/7 Turned this off. If you actually want to do it right, use last_frame_velocity.
#ifdef PLAYER_PUSHING

	local float v1, v2;

	if (other.classname == "player")
	{
		if (Teammate(self, other))
		{
			v1 = vlen(other.velocity);
			if (v1 < 50)
			{
				v2 = vlen(self.velocity);
				if (v2 > 55 || (self.items & (#IT_KEY1 | #IT_KEY2)))
				{
					makevectors(self.angles);
					traceline (self.origin, self.origin + v_forward*32, #TL_ANY_SOLID, self);
					if (trace_ent == other)
					{
						if (self.items & (#IT_KEY1 | #IT_KEY2))
							other.velocity = other.velocity + (normalize(self.velocity) * 120);
						else if (!(other.items & (#IT_KEY1 | #IT_KEY2)))
							other.velocity = other.velocity + (normalize(self.velocity) * 30);
					}
				}
			}
		}
	}

#endif
*/

};

void() player_run;

void()	player_stand1 =[	$axstnd1,	player_stand1	]
{
	self.weaponframe=0;
	if (self.velocity_x || self.velocity_y)
	{
		self.walkframe=0;
		player_run();
		return;
	}

	if (self.current_weapon <= #WEAP_AXE)
	{
		if (self.walkframe >= 12)
			self.walkframe = 0;
		self.frame = $axstnd1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 5)
			self.walkframe = 0;
		self.frame = $stand1 + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;	
};

void()	player_run =[	$rockrun1,	player_run	]
{
	self.weaponframe=0;
	if (!self.velocity_x && !self.velocity_y)
	{
		self.walkframe=0;
		player_stand1();
		return;
	}

	if (self.current_weapon <= #WEAP_AXE)
	{
		if (self.walkframe >= 6)
			self.walkframe = 0;
		self.frame = $axrun1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 6)
			self.walkframe = 0;
		self.frame = self.frame + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;
};


void()	player_shot1 =	[$shotatt1, player_shot2	] {self.weaponframe=1;muzzleflash();};
void()	player_shot2 =	[$shotatt2, player_shot3	] {self.weaponframe=2;};
void()	player_shot3 =	[$shotatt3, player_shot4	] {self.weaponframe=3;};
void()	player_shot4 =	[$shotatt4, player_shot5	] {self.weaponframe=4;};
void()	player_shot5 =	[$shotatt5, player_shot6	] {self.weaponframe=5;};
void()	player_shot6 =	[$shotatt6, player_run	] {self.weaponframe=6;};

void()	player_autorifle1 = [$shotatt1, player_autorifle2	] {self.weaponframe=1; muzzleflash(); };
void()	player_autorifle2 = [$shotatt2, player_autorifle3	] {self.weaponframe=2;};
void()	player_autorifle3 = [$shotatt6, player_run	] {self.weaponframe=6;};

void()	player_axe1 =	[$axatt1, player_axe2	] {self.weaponframe=1;};
void()	player_axe2 =	[$axatt2, player_axe3	] {self.weaponframe=2;};
void()	player_axe3 =	[$axatt3, player_axe4	] 
{
	self.weaponframe=3;
	if (self.current_weapon == #WEAP_AXE)
		W_FireAxe();
	else // if (self.current_weapon == #WEAP_SPANNER)
		W_FireSpanner();
};
void()	player_axe4 =	[$axatt4, player_run	] {self.weaponframe=4;};

void()	player_axeb1 =	[$axattb1, player_axeb2 ] {self.weaponframe=5;};
void()	player_axeb2 =	[$axattb2, player_axeb3 ] {self.weaponframe=6;};
void()	player_axeb3 =	[$axattb3, player_axeb4 ] 
{
	self.weaponframe=7;
	if (self.current_weapon == #WEAP_AXE)
		W_FireAxe();
	else // if (self.current_weapon == #WEAP_SPANNER)
		W_FireSpanner();
};
void()	player_axeb4 =	[$axattb4, player_run	] {self.weaponframe=8;};

void()	player_axec1 =	[$axattc1, player_axec2 ] {self.weaponframe=1;};
void()	player_axec2 =	[$axattc2, player_axec3 ] {self.weaponframe=2;};
void()	player_axec3 =	[$axattc3, player_axec4 ] 
{
	self.weaponframe=3;
	if (self.current_weapon == #WEAP_AXE)
		W_FireAxe();
	else // if (self.current_weapon == #WEAP_SPANNER)
		W_FireSpanner();
};
void()	player_axec4 =	[$axattc4, player_run	] {self.weaponframe=4;};

void()	player_axed1 =	[$axattd1, player_axed2 ] {self.weaponframe=5;};
void()	player_axed2 =	[$axattd2, player_axed3 ] {self.weaponframe=6;};
void()	player_axed3 =	[$axattd3, player_axed4 ] 
{
	self.weaponframe=7;
	if (self.current_weapon == #WEAP_AXE)
		W_FireAxe();
	else // if (self.current_weapon == #WEAP_SPANNER)
		W_FireSpanner();
};
void()	player_axed4 =	[$axattd4, player_run	] {self.weaponframe=8;};

//=========================
// QW Grappling hook frames
void()	player_chain1=	[$axattd1, player_chain1a] {self.weaponframe=1;Throw_Grapple();};
void()	player_chain1a= [$axattd1, player_chain2 ] {self.weaponframe=2;};
void()	player_chain2=	[$axattd2, player_chain2a] {self.weaponframe=3;};
void()	player_chain2a= [$axattd2, player_chain3 ] {self.weaponframe=4;};
void()	player_chain3=	[$axattd3, player_chain3 ]
{
		self.weaponframe=6;
		if (!self.hook_out)
		{
				player_chain5();
				return;
		}
		if (vlen(self.velocity) >= 750)
		{
				player_chain4();
				return;
		}
};

void() player_chain4=  [$deathc4, player_chain4 ]
{
		self.weaponframe=6;
		if (!self.hook_out)
		{
				player_chain5();
				return;
		}
		if (vlen(self.velocity) < 750)
		{
				player_chain3();
				return;
		}
};

void()	player_chain5=	[$axattd4, player_run	 ] {self.weaponframe=0;};

// newstuff

void()	player_medikit1 =	[$axatt1, player_medikit2	] {self.weaponframe=1;};
void()	player_medikit2 =	[$axatt2, player_medikit3	] {self.weaponframe=2;};
void()	player_medikit3 =	[$axatt3, player_medikit4	] {self.weaponframe=3;W_FireMedikit(#FALSE);};
void()	player_medikit4 =	[$axatt4, player_run		] {self.weaponframe=4;};

void()	player_medikitb1 =	[$axattb1, player_medikitb2 ] {self.weaponframe=5;};
void()	player_medikitb2 =	[$axattb2, player_medikitb3 ] {self.weaponframe=6;};
void()	player_medikitb3 =	[$axattb3, player_medikitb4 ] {self.weaponframe=7;W_FireMedikit(#FALSE);};
void()	player_medikitb4 =	[$axattb4, player_run		] {self.weaponframe=8;};

void()	player_medikitc1 =	[$axattc1, player_medikitc2 ] {self.weaponframe=1;};
void()	player_medikitc2 =	[$axattc2, player_medikitc3 ] {self.weaponframe=2;};
void()	player_medikitc3 =	[$axattc3, player_medikitc4 ] {self.weaponframe=3;W_FireMedikit(#FALSE);};
void()	player_medikitc4 =	[$axattc4, player_run		] {self.weaponframe=4;};

void()	player_medikitd1 =	[$axattd1, player_medikitd2 ] {self.weaponframe=5;};
void()	player_medikitd2 =	[$axattd2, player_medikitd3 ] {self.weaponframe=6;};
void()	player_medikitd3 =	[$axattd3, player_medikitd4 ] {self.weaponframe=7;W_FireMedikit(#FALSE);};
void()	player_medikitd4 =	[$axattd4, player_run		] {self.weaponframe=8;};

void()	player_bioweapon1 = [$axatt1, player_bioweapon2 ] {self.weaponframe=1;};
void()	player_bioweapon2 = [$axatt2, player_bioweapon3 ] {self.weaponframe=2;};
void()	player_bioweapon3 = [$axatt3, player_bioweapon4 ] {self.weaponframe=3;W_FireBioweapon();};
void()	player_bioweapon4 = [$axatt4, player_run		] {self.weaponframe=4;};

void()	player_bioweaponb1 =	[$axattb1, player_bioweaponb2	] {self.weaponframe=5;};
void()	player_bioweaponb2 =	[$axattb2, player_bioweaponb3	] {self.weaponframe=6;};
void()	player_bioweaponb3 =	[$axattb3, player_bioweaponb4	] {self.weaponframe=7;W_FireBioweapon();};
void()	player_bioweaponb4 =	[$axattb4, player_run	] {self.weaponframe=8;};

void()	player_bioweaponc1 =	[$axattc1, player_bioweaponc2	] {self.weaponframe=1;};
void()	player_bioweaponc2 =	[$axattc2, player_bioweaponc3	] {self.weaponframe=2;};
void()	player_bioweaponc3 =	[$axattc3, player_bioweaponc4	] {self.weaponframe=3;W_FireBioweapon();};
void()	player_bioweaponc4 =	[$axattc4, player_run	] {self.weaponframe=4;};

void()	player_bioweapond1 =	[$axattd1, player_bioweapond2	] {self.weaponframe=5;};
void()	player_bioweapond2 =	[$axattd2, player_bioweapond3	] {self.weaponframe=6;};
void()	player_bioweapond3 =	[$axattd3, player_bioweapond4	] {self.weaponframe=7;W_FireBioweapon();};
void()	player_bioweapond4 =	[$axattd4, player_run	] {self.weaponframe=8;};
 
//============================================================================

void() player_snail1   =[ $nailatt1, player_snail2	] 
{

	if (!self.button0 || intermission_running)
		{player_run ();return;}
	//WK
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;

	if (self.attack_finished > time)
		return;
	muzzleflash();

	/*self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;*/

	SuperDamageSound();
	W_FireSpikes (4);
	//Attack_Finished(0.1);
	Attack_Finished(0.2);
};
//- OfN -

void() player_snail2   =[ $nailatt2, player_snail1	]
{
	/*if (!self.button0 || intermission_running)
		{player_run ();return;}*/
	//WK
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	
	/*if (self.attack_finished > time)
		return;*/

	/*self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;*/

	//SuperDamageSound();
//	if (random() < 0.5) W_FireSpikes (4);
	//Attack_Finished(0.2);
	//Attack_Finished(0.1);
};

void() player_nail1   =[ $nailatt1, player_nail2  ] 
{

	if (!self.button0 || intermission_running)
		{player_run ();return;}
	//WK
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;

	if (self.attack_finished > time)
		return;
	muzzleflash();

	/*self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;*/

	SuperDamageSound();
	W_FireSpikes (4);
	//Attack_Finished(0.1);
	Attack_Finished(0.2);
};
//- OfN -

void() player_nail2   =[ $nailatt2, player_nail3  ]
{
	/*if (!self.button0 || intermission_running)
		{player_run ();return;}*/
	//WK
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	
	/*if (self.attack_finished > time)
		return;*/

	/*self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;*/

	//SuperDamageSound();
//	if (random() < 0.5) W_FireSpikes (4);
	//Attack_Finished(0.2);
	//Attack_Finished(0.1);
};


void() player_nail3   =[ $nailatt1, player_nail4  ]
{
	if (!self.button0 || intermission_running)
		{player_run ();return;}
	//WK
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	
	if (self.attack_finished > time)
		return;

	/*self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;*/

	muzzleflash();
	SuperDamageSound();
	W_FireSpikes (-4);
	//Attack_Finished(0.2);
	Attack_Finished(0.2);
};


void() player_nail4   =[ $nailatt2, player_nail1  ]
{
	/*if (!self.button0 || intermission_running)
		{player_run ();return;}*/
	//WK
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	
	/*if (self.attack_finished > time)
		return;*/

	/*self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;*/

	//SuperDamageSound();
//	if (random() < 0.5) W_FireSpikes (-4);
	//Attack_Finished(0.2);
	//Attack_Finished(0.1);
};


//============================================================================
// ASSAULT CANNON FRAMES
// Cannon powering up
void() player_assaultcannonup1	 =[$nailatt1, player_assaultcannonup2  ] 
{
	if ((!self.button0) || (self.ammo_shells < 1) || intermission_running)
	{
		// Let him/her walk again
		//WK 2/8/7 Ass cannons can walk now
		//self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
		TeamFortress_SetSpeed(self);
		
		self.count = 1;
		self.heat = 0;
		player_assaultcannondown1();
		return;
	}

	self.fire_held_down = #TRUE;

	if (self.heat == 1)
		sound (self, #CHAN_WEAPON, "weapons/asscan1.wav", 1, #ATTN_NORM);

	SuperDamageSound();
	Attack_Finished(0.1);

	if (self.heat != 2 && self.heat != 4)
	{
		if (self.weaponframe >= 3)
			self.weaponframe = 0;
		else
			self.weaponframe = self.weaponframe + 1;
	}

	self.heat = self.heat + 1;
	if (self.heat >= 7)
	{
		self.heat = 0;
		player_assaultcannon1();
	}
};

// Cannon powering up 2
void() player_assaultcannonup2	 =[$nailatt1, player_assaultcannonup1  ] 
{
	if ((!self.button0) || (self.ammo_shells < 1) || intermission_running)
	{
		//WK 2/8/7 Ass cannons can walk now
			//self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
			TeamFortress_SetSpeed(self);
		self.count = 1;
		self.heat = 0;
		player_assaultcannondown1();
		return;
	}

	SuperDamageSound();
	Attack_Finished(0.1);

	if (self.heat != 2 && self.heat != 4 && self.heat != 7)
	{
		if (self.weaponframe == 2 && self.heat >= 9)
			self.weaponframe = 0;
		else if (self.weaponframe >= 3)
			self.weaponframe = 0;
		else
			self.weaponframe = self.weaponframe + 1;
	}

	self.heat = self.heat + 1;
	if (self.heat >= 13)
	{
		self.heat = 0;
		player_assaultcannon1();
	}
};

// Cannon Firing 
void() player_assaultcannon1   =[$nailatt1, player_assaultcannon2  ] 
{
	local string st;

	muzzleflash();

	//WK 8/4/7 Add in idle spin sound to the ass cannon, ala normal TF
	if ((self.flags & #FL_ONGROUND) || (self.hook_out) || ((self.tf_items & #NIT_SCUBA) && self.waterlevel))
		sound (self, #CHAN_WEAPON, "weapons/asscan2.wav", 1, #ATTN_NORM);
	else
		sound (self, #CHAN_WEAPON, "weapons/asscan4.wav", 1, #ATTN_NORM);

	if ((!self.button0) || (self.ammo_shells < 1) || intermission_running)
	{
		stuffcmd(self, "v_idlescale 0\n");
		// Let him/her walk again
		//WK 2/8/7 Ass cannnons can walk now
		//self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
		TeamFortress_SetSpeed(self);
	
		self.weaponframe = 0;
		self.count = 1;
		player_assaultcannondown1();
		return;
	}

	if (self.weaponframe == 2)
		self.weaponframe = 4;
	else
		self.weaponframe = 2;
	SuperDamageSound();
	W_FireAssaultCannon();

	// Shake the screen
	stuffcmd(self, "v_idlescale ");
	if (self.heat < 5)
		st = ftos(self.heat * 4);
	else
		st = "20";
	stuffcmd(self, st);
	stuffcmd(self, "\n");
	Attack_Finished(0.1);
};

// Cannon Firing 2
void() player_assaultcannon2   =[$nailatt2, player_assaultcannon1  ]
{
	//local string st;

	if ((!self.button0) || (self.ammo_shells < 1) || intermission_running)
	{
		stuffcmd(self, "v_idlescale 0\n");
		// Let him/her walk again
		//WK 2/8/7 Ass cannons can walk again
		//self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
		TeamFortress_SetSpeed(self);
	
		self.weaponframe = 0;
		self.count = 1;
		player_assaultcannondown1();
		return;
	}

	if (self.weaponframe == 2)
		self.weaponframe = 4;
	else
		self.weaponframe = 2;
	SuperDamageSound();
	W_FireAssaultCannon();

	// increase the heat of the cannon
	self.heat = self.heat + 0.1;
	// Shake the screen
	stuffcmd(self, "v_idlescale 0\n");
	stuffcmd(self, "bf\n");

	Attack_Finished(0.1);
};

// Cannon powering down
void() player_assaultcannondown1   =[$nailatt1, player_assaultcannondown1  ] 
{
	//local entity tcool;

	if (self.count == 1)
		sound (self, #CHAN_WEAPON, "weapons/asscan3.wav", 1, #ATTN_NORM);

	if (self.count >= 15)
	{
		self.heat = 0;
		self.fire_held_down = #FALSE;

		// Let him/her walk again
		//WK self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
		TeamFortress_SetSpeed(self);
	 
		if (self.ammo_shells < 1 || self.ammo_cells < 6)
		{
			self.current_weapon = W_BestWeapon();
			W_SetCurrentAmmo();
			W_PrintWeaponMessage();
			return;
		}

		player_run ();
		return;
	}

	if (self.count != 8 && self.count != 10 && self.count != 12 && self.count != 14)  
	{
		if (self.weaponframe == 3)
			self.weaponframe = 0;
		else
			self.weaponframe = self.weaponframe + 1;
	}

	self.count = self.count + 1;
	Attack_Finished(0.1);
};

//============================================================================

void() player_light1   =[$light1, player_light2  ] 
{
	muzzleflash();

	if (!self.button0 || intermission_running)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	Attack_Finished(0.2);
};
void() player_light2   =[$light2, player_light1  ]
{
	if (!self.button0 || intermission_running)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	Attack_Finished(0.2);
};

//============================================================================
//WK Frames for the new light assault gun
//(Using the frames for the lightning gun)

void() player_light_assault1   =[$light1, player_light_assault2  ] 
{
	//muzzleflash();

	if (!self.button0 || intermission_running || self.tfstate & #TFSTATE_RELOADING)
		{player_run ();return;}

	muzzleflash(); //- oFn moved
	
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightAssault();
	Attack_Finished(0.2);
};
void() player_light_assault2   =[$light2, player_light_assault1  ]
{
	if (!self.button0 || intermission_running || self.tfstate & #TFSTATE_RELOADING)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightAssault();
	Attack_Finished(0.2);
};
//End WK


//============================================================================


void() player_rocket1	=[$rockatt1, player_rocket2  ] {self.weaponframe=1; muzzleflash();};
void() player_rocket2	=[$rockatt2, player_rocket3  ] {self.weaponframe=2;};
void() player_rocket3	=[$rockatt3, player_rocket4  ] {self.weaponframe=3;};
void() player_rocket4	=[$rockatt4, player_rocket5  ] {self.weaponframe=4;};
void() player_rocket5	=[$rockatt5, player_rocket6  ] {self.weaponframe=5;};
void() player_rocket6	=[$rockatt6, player_run  ] {self.weaponframe=6;};
void(float num_bubbles) DeathBubbles;

void() PainSound =
{
local float 	rs;

	if (self.health < 0)
		return;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, #CHAN_VOICE, "player/teledth1.wav", 1, #ATTN_NONE);
		return;
	}

	// water pain sounds
	if (self.watertype == #CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);
		if (random() > 0.5)
			sound (self, #CHAN_VOICE, "player/drown1.wav", 1, #ATTN_NORM);
		else
			sound (self, #CHAN_VOICE, "player/drown2.wav", 1, #ATTN_NORM);
		return;
	}
	
	// slime pain sounds
	if (self.watertype == #CONTENT_SLIME)
	{
		// FIX ME	put in some steam here
		if (random() > 0.5)
			sound (self, #CHAN_VOICE, "player/lburn1.wav", 1, #ATTN_NORM);
		else
			sound (self, #CHAN_VOICE, "player/lburn2.wav", 1, #ATTN_NORM);
		return;
	}

	if (self.watertype == #CONTENT_LAVA)
	{
		if (random() > 0.5)
			sound (self, #CHAN_VOICE, "player/lburn1.wav", 1, #ATTN_NORM);
		else
			sound (self, #CHAN_VOICE, "player/lburn2.wav", 1, #ATTN_NORM);
		return;
	}

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}
	self.pain_finished = time + 0.5;

// don't make multiple pain sounds right after each other

// ax pain sound
	if (self.axhitme == 1)
	{
		self.axhitme = 0;
		sound (self, #CHAN_VOICE, "player/axhit1.wav", 1, #ATTN_NORM);
		return;
	}

	rs = rint((random() * 5) + 1);

	self.noise = "";
	if (rs == 1)
		self.noise = "player/pain1.wav";
	else if (rs == 2)
		self.noise = "player/pain2.wav";
	else if (rs == 3)
		self.noise = "player/pain3.wav";
	else if (rs == 4)
		self.noise = "player/pain4.wav";
	else if (rs == 5)
		self.noise = "player/pain5.wav";
	else
		self.noise = "player/pain6.wav";

	sound (self, #CHAN_VOICE, self.noise, 1, #ATTN_NORM);
	return;
};

void()	player_pain1 =	[	$pain1, player_pain2	] {PainSound();self.weaponframe=0;};
void()	player_pain2 =	[	$pain2, player_pain3	] {};
void()	player_pain3 =	[	$pain3, player_pain4	] {};
void()	player_pain4 =	[	$pain4, player_pain5	] {};
void()	player_pain5 =	[	$pain5, player_pain6	] {};
void()	player_pain6 =	[	$pain6, player_run		] {};

void()	player_axpain1 =	[	$axpain1,	player_axpain2	] {PainSound();self.weaponframe=0;};
void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {};
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {};
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {};
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {};
void()	player_axpain6 =	[	$axpain6,	player_run		] {};

void() player_pain =
{
	if (self.weaponframe)
		return;

	// eyes don't have pain frames
	if (self.invisible_finished > time)
		return; 	

	// feigning players don't have pain frames
	if (self.is_feigning)
	{
		PainSound();
		return;
	}

	// HvyWeap Guys firing assault cannon don't have pain frames
	if (self.button0 && self.current_weapon == #WEAP_ASSAULT_CANNON)
		return;

	if (self.current_weapon <= #WEAP_AXE)
		player_axpain1 ();
	else
		player_pain1 ();
};

void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_died1;
void() player_diee1;
void() player_die_ax1;

void() DeathBubblesSpawn =
{
	if (self.owner.waterlevel != 3 && self.has_holo == 0)
	{
		dremove(self);
		return;
	}

	newmis = spawn();
	setmodel (newmis, "progs/s_bubble.spr");
	setorigin (newmis, self.owner.origin + '0 0 24');
	newmis.movetype = #MOVETYPE_NOCLIP;
	newmis.solid = #SOLID_NOT;
	newmis.velocity = '0 0 15';
	newmis.nextthink = time + 0.5;
	newmis.think = bubble_bob;
	newmis.classname = "bubble";
	newmis.frame = 0;
	newmis.cnt = 0;
	setsize (newmis, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		dremove(self);
};

void(float num_bubbles) DeathBubbles =
{
local entity	bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);

	bubble_spawner.movetype = #MOVETYPE_NONE;
	bubble_spawner.solid = #SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	
	if (IsMonster(self))
		bubble_spawner.has_holo = 1; // forced mode
	else
		bubble_spawner.has_holo = 0; // normal mode

	return;
};

void() NormalBubblesSpawn =
{
	newmis = spawn();
	setmodel (newmis, "progs/s_bubble.spr");
	setorigin (newmis, self.origin + '0 0 24');
	newmis.movetype = #MOVETYPE_NOCLIP;
	newmis.solid = #SOLID_NOT;
	newmis.velocity = '0 0 15';
	newmis.nextthink = time + 0.5;
	newmis.think = bubble_bob;
	newmis.classname = "bubble";
	newmis.frame = 0;
	newmis.cnt = 0;
	setsize (newmis, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = NormalBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		dremove(self);
};


void(float num_bubbles, vector where) SpawnBubbles =
{
local entity	bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, where);

	bubble_spawner.movetype = #MOVETYPE_NONE;
	bubble_spawner.solid = #SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = NormalBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = world;
	bubble_spawner.bubble_count = num_bubbles;
	
	return;
};


void() DeathSound =
{
	local float 	rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		if (self.is_feigning)
			DeathBubbles(2);
		else
			DeathBubbles(10);
		sound (self, #CHAN_VOICE, "player/h2odeath.wav", 1, #ATTN_NONE);
		return;
	}
	
	rs = rint ((random() * 4) + 1);
	if (rs == 1)
		self.noise = "player/death1.wav";
	if (rs == 2)
		self.noise = "player/death2.wav";
	if (rs == 3)
		self.noise = "player/death3.wav";
	if (rs == 4)
		self.noise = "player/death4.wav";
	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, #CHAN_VOICE, self.noise, 1, #ATTN_NONE);
	return;
};


void() PlayerCorpse =
{
	self.nextthink = -1;
	// allow respawn after a certain time
	self.deadflag = #DEAD_DEAD;

	#ifdef GIBABLE_CORPSES
	MakeCorpse(self,#CORPSE_HP_PLAYER);
	#endif
};

// PZ: If you use this function for anything other than gibs,
// please take into account how it will work in Neo mode.
// I don't want rocket jumps and such being changed, just
// gib velocities. Thanks.
vector(float dm) VelocityForDamage =
{
	local vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 150 + 100 * random();//v_z = 200 + 100 * random(); // <-- ORiginal code
	
	if (!neo) // for Neo mode
	{
		if (dm > -50)
		{
			//RPrint ("level 1\n");
			v = v * 0.7;
		}
		else if (dm > -200)
		{
			//RPrint ("level 3\n");
			v = v * 2;
		}
		else
			v = v * 10;
	}
	else
		v = v * (dm * -1 / 30); // end of Neo mod

	return v;
};

/*

Entity fields used on gibs:
---------------------------

.has_fieldgen - Kgs value for the gib
.message	  - When "cool" is assigned to it, it will be pushed by explosions and trace attacks (if enabled)

*/

void(entity warlock) GibPickSound;

float(entity player) GetMeat;
void(entity player, float numgibs) SetMeat;

void() gib_touch =
{
	local float removeme, bit;
	removeme = 0;

	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';

	//WK 6/27/7 Cannibals can eat gibs
	if (other.classname == "player")
	if (other.cutf2_items & #CUTF2_CANNIBAL)
	if (other.playerclass != #PC_UNDEFINED) // Skip Observers
	if (!(other.done_custom & #CUSTOM_BUILDING)) // ppl customizing
	if (other.health > 0)
	{
		//We heal up to 25 points above the max
		if (other.health < other.max_health + 25) {
			other.items = other.items | #IT_SUPERHEALTH; //WK 8/4/7 We flag them as being ok to exceed max_health. Stops 'damage on heal' bug.
			other.health = other.health + 25;
			if (other.health > other.max_health + 25)
				other.health = other.max_health + 25;
			removeme = 1;
		}
		if (other.armorvalue < other.maxarmor) {
			if (other.armorvalue <= 0) { //WK 8/4/7 Fix the 'no armor icon' bug if cannibal was at 0 armor.
				other.armorvalue = 0;
				bit = #IT_ARMOR1;
				if (other.armor_allowed == 0.6)
					bit = #IT_ARMOR2;
				else if (other.armor_allowed == 0.8)
					bit = #IT_ARMOR3;
				other.items = other.items - (other.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3)) + bit;
			}

			other.armorvalue = other.armorvalue + 15;
			if (other.armorvalue > other.maxarmor)
				other.armorvalue = other.maxarmor;
			other.armortype = other.armor_allowed;


			removeme = 1;
		}
		if (removeme)
			stuffcmd(other,"bf\n");
	}

	//WK 6/27/7 We allow both cannibal and warlock on same gibs
	if (other.classname == "player")
	#ifndef WARLOCK_TEST
		if (!Teammate(other, self)) // Only enemy gibs can be picked up
	#endif
	if (other.job & #JOB_WARLOCK)
	if (other.playerclass != #PC_UNDEFINED) // Skip Observers
	if (!(other.done_custom & #CUSTOM_BUILDING)) // ppl customizing
	if (other.health > 0)
	{
		local string kgs;
		kgs = ftos(self.has_fieldgen);
	
		local float meat;
		meat = GetMeat(other);
		SetMeat(other,meat+self.has_fieldgen);

		sprint(other,#PRINT_HIGH,"You get ");
		sprint(other,#PRINT_HIGH,kgs);

		if (self.has_fieldgen > 1)
			sprint(other,#PRINT_HIGH," kgs of fresh meat\n");
		else
			sprint(other,#PRINT_HIGH," kg of fresh meat\n");

		GibPickSound(other);
		stuffcmd(other,"bf\n");
		removeme = 1;
	}
	if (removeme) dremove(self);
};

void(string gibname, float dm, float makecool, float gibskin, float gibkgs, float randorg) ThrowGib =
{
	newmis = spawn();
	if (!randorg)
		newmis.origin = self.origin;
	else
	{
		newmis.origin_x = self.origin_x + (random()* (self.maxs_x + self.mins_x)) * randorg;
		newmis.origin_y = self.origin_y + (random()* (self.maxs_y + self.mins_y)) * randorg;
		newmis.origin_z = self.origin_z + (random()* (self.maxs_z + self.mins_z)) * randorg;		
	}
	setmodel (newmis, gibname);
	setsize (newmis, '0 0 0', '0 0 0');
	newmis.velocity = VelocityForDamage (dm);
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_NOT;
	newmis.avelocity_x = crandom()*600;
	newmis.avelocity_y = crandom()*600;
	newmis.avelocity_z = crandom()*600;
	newmis.think = SUB_Remove;
	newmis.ltime = time;
	newmis.nextthink = time + #MIN_GIB_TIME + random()*(#MAX_GIB_TIME - #MIN_GIB_TIME);
	newmis.frame = 0;
	newmis.flags = 0;

	#ifdef COOL_GIBS
	if (makecool)
	{
		newmis.#coolflag = #STRFLAG_COOL;
		newmis.classname = "gib";
	}
	#endif

	if (gibskin)
		newmis.skin = gibskin;
	
	if (gibkgs)
	{
		newmis.touch = gib_touch;
		newmis.solid = #SOLID_TRIGGER;
		newmis.has_fieldgen = gibkgs;
		newmis.team_no = self.team_no;
	}
	#ifdef COOL_GIBS
	#ifdef COOL_METAL_GIBS
	else
		newmis.solid = #SOLID_TRIGGER;
	#endif
	#endif
};

/*

Entity fields used for heads:
-----------------------------

.oldenemy	- Last person that kicked this head
.t_length	- Last time this head was kicked
.t_width	- First stop done?
.message	- When "cool" is assigned to it, it will be pushed by explosions and trace attacks (if enabled)

*/

#ifdef KICKABLE_HEADS
float kickable_heads;
#endif

float(entity player) GetHeads;
void(entity player, float numheads) SetHeads;

void() head_touch =
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
		if (!Teammate(other, self)) // Only enemy heads can be picked up
		#endif	  
		{
			self.modelindex = modelindex_null;
			self.touch = SUB_Null;
			self.solid = #SOLID_NOT;

			if (self.classname == "player")
			{
				sprint(other,#PRINT_HIGH,"You pick up ");
				sprint(other,#PRINT_HIGH,self.netname);
				sprint(other,#PRINT_HIGH,"'s head\n");

				sprint(self,#PRINT_HIGH,other.netname);
				sprint(self,#PRINT_HIGH," picks up your head!\n");
			}
			else
				sprint(other,#PRINT_HIGH,"You pick up a head\n");
			
			GibPickSound(other);
			stuffcmd(other,"bf\n");

			local float numheads;
			numheads = GetHeads(other);
			SetHeads(other,numheads+1);

			// Dont remove self because we r a player entity or a bodyque entry

			// Unless its an special head (see below)
			if (self.classname == "headout")
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
		
		self.t_length = time;
		
		// Do pain sound if a "living" head :)
		if (self.classname == "player")
		if (self.is_connected)
		{			 
			// TODO: Make the following work!
			// Put it in a pushable origin
			/*local vector oldorig;
			local float oldcont;
			oldorig = self.origin;
			oldcont = pointcontents(self.origin);
			
			if (fabs(self.origin_x - other.origin_x) > fabs(self.origin_y - other.origin_y))
			{
				if (self.origin_x < other.origin_x)
					self.origin_x = self.origin_x -( (	(other.absmax_x - other.absmin_x) - (self.absmax_x - other.absmin_x)  )+1);
				else
					self.origin_x = self.origin_x +( (	(other.absmax_x - other.absmin_x) - (self.absmax_x - other.absmin_x)  )+1);
			}
			else
			{
				if (self.origin_x < other.origin_x)
					self.origin_y = self.origin_y -( (	(other.absmax_y - other.absmin_y) - (self.absmax_y - other.absmin_y)  )+1);
				else
					self.origin_y = self.origin_y +( (	(other.absmax_y - other.absmin_y) - (self.absmax_y - other.absmin_y)  )+1);
			}

			// valid origin?
			if ((pointcontents(self.origin) != oldcont)
			  ||(pointcontents(self.absmin + '1 1 1') != oldcont)
			  ||(pointcontents(self.absmax - '1 1 1') != oldcont))
			{
				self.origin = oldorig;
				setorigin(self,self.origin);
				return;
			}*/
			
			// water pain sounds
			if (self.watertype == #CONTENT_WATER && self.waterlevel == 3)
			{
				DeathBubbles(1);
				if (random() > 0.5)
					sound (self, #CHAN_VOICE, "player/drown1.wav", 1, #ATTN_IDLE);
				else
					sound (self, #CHAN_VOICE, "player/drown2.wav", 1, #ATTN_IDLE);
			}
			else
			{
				local float 	rs;
				rs = rint((random() * 5) + 1);

				self.noise = "";
				if (rs == 1)
					self.noise = "player/pain1.wav";
				else if (rs == 2)
					self.noise = "player/pain2.wav";
				else if (rs == 3)
					self.noise = "player/pain3.wav";
				else if (rs == 4)
					self.noise = "player/pain4.wav";
				else if (rs == 5)
					self.noise = "player/pain5.wav";
				else
					self.noise = "player/pain6.wav";

				sound (self, #CHAN_VOICE, self.noise, 1, #ATTN_IDLE);
			}

			sprint(self,#PRINT_MEDIUM,other.netname);
			sprint(self,#PRINT_MEDIUM," kicks your head!\n");

			sprint(other,#PRINT_MEDIUM,self.netname);
			sprint(other,#PRINT_MEDIUM,"'s head is still alive!\n");

			self.t_length = time + #KICKHEAD_RATE_ALIVE;
		}		 

		//ok, kick it out		 
		self.oldenemy = other;
		makevectors (other.v_angle);
		self.velocity = other.velocity * 1.5 + v_forward * 128 + '0 0 260' + '0 0 300'*random();  
		self.flags = self.flags - (self.flags & #FL_ONGROUND);
		
		self.avelocity = crandom() * '0 600 0';

		sound(self,#CHAN_BODY,"zombie/z_miss.wav",0.5, #ATTN_IDLE);
		#endif
	}	 
};

void(string gibname, float dm) ThrowHead =
{
	setmodel (self, gibname);
	self.skin = 0;
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = #MOVETYPE_BOUNCE;
	self.takedamage = #DAMAGE_NO;
	//self.solid = #SOLID_NOT;
	self.solid = #SOLID_TRIGGER; // OfN
	self.view_ofs = '0 0 8';
	//setsize (self, '-16 -16 0', '16 16 56');
	setsize (self, '-16 -16 0', '16 16 8');
	self.velocity = VelocityForDamage (dm);
	//self.origin_z = self.origin_z - 24;
	self.flags = self.flags - (self.flags & #FL_ONGROUND);
	self.avelocity = crandom() * '0 600 0';

	//-OfN	  
	self.touch = head_touch;

	#ifdef COOL_GIBS
	self.#coolflag = #STRFLAG_COOL;
	#endif

	#ifdef KICKABLE_HEADS
	self.t_width = #FALSE;
	self.oldenemy = world;
	self.t_length = time;
	#endif
};

//==========================================================
// Special client head throw =) (when disconnect)

void(string gibname, float dm) ThrowHeadOut =
{
	local entity thehead;
	thehead = spawn();
	
	setmodel (thehead, gibname);
	setorigin(thehead,self.origin);
	thehead.skin = 0;
	thehead.frame = 0;
	thehead.movetype = #MOVETYPE_BOUNCE;
	thehead.takedamage = #DAMAGE_NO;
	thehead.solid = #SOLID_TRIGGER; // OfN
	thehead.view_ofs = '0 0 8';
	//setsize (thehead, '-16 -16 0', '16 16 56');
	setsize (thehead, '-16 -16 0', '16 16 8');
	thehead.velocity = VelocityForDamage (dm);
	//thehead.origin_z = thehead.origin_z - 24;
	thehead.flags = thehead.flags - (thehead.flags & #FL_ONGROUND);
	thehead.avelocity = crandom() * '0 600 0';

	//-OfN	  
	thehead.classname = "headout";
	thehead.touch = head_touch;
	thehead.think = SUB_Remove;
	thehead.nextthink = time + #MIN_HEAD_TIME + (#MAX_HEAD_TIME - #MIN_HEAD_TIME) * random();
	thehead.team_no = self.team_no;

	#ifdef COOL_GIBS
	thehead.#coolflag = #STRFLAG_COOL;
	#endif

	#ifdef KICKABLE_HEADS
	thehead.t_width = #FALSE;
	thehead.oldenemy = world;
	thehead.t_length = time;
	#endif
};

//=====================================================
// Called on client disconnect if player is "in-game"

void() GibPlayerOut =
{
	if (random() < 0.5)
		sound (self, #CHAN_VOICE, "player/gib.wav", 1, #ATTN_NONE);
	else
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NONE);
	
	ThrowHeadOut("progs/h_player.mdl",-40);
	ThrowGib("progs/gib1.mdl",-40, #TRUE, 0,#GIB1_KGS, #FALSE);
	ThrowGib("progs/gib2.mdl",-40, #TRUE, 0,#GIB2_KGS, #FALSE);
	ThrowGib("progs/gib3.mdl",-40, #TRUE, 0,#GIB3_KGS, #FALSE);   
	SpawnBloodEx(self.origin,0.75,9);
};

/*void(string gibname) HeadShotThrowHead =
{
	setmodel (self, gibname);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = #MOVETYPE_BOUNCE;
	self.takedamage = #DAMAGE_NO;
	self.solid = #SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = normalize(self.head_shot_vector) * 600;
	self.origin_z = self.origin_z + 24;
	self.flags = self.flags - (self.flags & #FL_ONGROUND);
	self.avelocity = '0 0 0';
};*/

void() KillPlayer =
{
	self.owner.deadflag = #DEAD_DEAD;
	dremove(self);
};

void() GibPlayer =
{
  //- OfN now this can be turned on/off with the headless localinfo -//
  // Decapitation ------------------------------------------------------//
  /*if (headless == 1)
  {
	if (deathmsg == #DMSG_SNIPERHEADSHOT) //- Ofn - I don't like this:	|| deathmsg == #DMSG_BACKSTAB)
	{
		//if (deathmsg == #DMSG_SNIPERHEADSHOT)
			HeadShotThrowHead("progs/h_player.mdl");
		//else
		//	ThrowHead("progs/h_player.mdl", -60);

		newmis = spawn();
		newmis.solid = #SOLID_NOT;
		newmis.movetype = #MOVETYPE_STEP;

		newmis.angles = self.angles;

		setsize(newmis, '0 0 0', '0 0 0');
		setorigin(newmis, self.origin);   

		newmis.colormap = self.colormap;
//		  newmis.color=self.color
		//newmis.skin = self.skin;
		
		setmodel(newmis, "progs/headless.mdl");
					
		newmis.think = Headless_Think;
		newmis.nextthink = time + 0.1;
		if (self.current_weapon <= #WEAP_AXE)
			newmis.frame = 0;
		else
			newmis.frame = 8;

		ThrowGib ("progs/zom_gib.mdl", self.health); //- lol, looks cool 
	}
	else
	{
		ThrowHead ("progs/h_player.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health); //-added
		//ThrowGib ("progs/zom_gib.mdl", self.health); //-added

	}
  }
  else
  {*/
	ThrowHead ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health, #TRUE, 0,#GIB1_KGS, #FALSE);
	ThrowGib ("progs/gib2.mdl", self.health, #TRUE, 0,#GIB2_KGS, #FALSE);
	ThrowGib ("progs/gib3.mdl", self.health, #TRUE, 0,#GIB3_KGS, #FALSE);
	//ThrowGib ("progs/gib3.mdl", self.health); //-added
  //}

	// Why do we need this? What are we doing that's clobbering _something_
	// within a second after a trigger_hurt kills the player?
	if (deathmsg == #DMSG_TRIGGER)
	{
		newmis = spawn();
		newmis.owner = self;
		newmis.think = KillPlayer;
		newmis.nextthink = time + 1;
	}
	else
	{
		self.deadflag = #DEAD_DEAD;
	}

	TeamFortress_SetupRespawn(#FALSE);

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, #CHAN_VOICE, "player/teledth1.wav", 1, #ATTN_NONE);

		// if telefragged, extend respawn delay to prevent chaining telefrags
		self.respawn_time = self.respawn_time + 2;

		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, #CHAN_VOICE, "player/teledth1.wav", 1, #ATTN_NONE);

		// if telefragged, extend respawn delay to prevent chaining telefrags
		self.respawn_time = self.respawn_time + 2;

		return;
	}
		
	if (random() < 0.5)
		sound (self, #CHAN_VOICE, "player/gib.wav", 1, #ATTN_NONE);
	else
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NONE);
};

void() PlayerDead =
{
	self.weaponmodel="";
	self.view_ofs = '0 0 -8';
	self.deadflag = #DEAD_DYING;
	self.solid = #SOLID_NOT;
	self.flags = self.flags - (self.flags & #FL_ONGROUND);
	self.movetype = #MOVETYPE_TOSS;
	SpawnBloodEx(self.origin,0.75,9);

	// Reset Auras and runes
	self.aura = 0;
	//self.#runes = 0; // Not needed
};

void() PlayerDie =
{
	local float i,finished;
	local entity te;
	//WK Stop orff
	//sound (self, #CHAN_MUSIC, "items/r_item1.wav", 0.1, #ATTN_NORM);
	sound (self, #CHAN_MUSIC, "misc/null.wav", 0.1, #ATTN_NORM);
	//WK Stop glows!
	self.flags = self.flags - (self.flags & (#EF_BRIGHTLIGHT | #EF_DIMLIGHT));
	  self.effects = 0;
	// make dead guy release hook (wedge)
	if (self.hook_out)
	{
		Reset_Grapple (self.hook);
		Attack_Finished(0.75);
		self.hook_out = #TRUE;	// PutClientInServer will reset this
	}

	self.items = self.items - (self.items &
	(#IT_INVISIBILITY | #IT_INVULNERABILITY | #IT_SUIT | #IT_QUAD) );
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.modelindex = modelindex_player;	// don't use eyes

	// If infected, give the medic a frag
	finished = #TRUE;
	if (self.tfstate & #TFSTATE_INFECTED && self == self.enemy)
	{
		te = find(world, classname, "timer");
		while (te)
		{
			if (te.owner == self && te.think == BioInfection_Decay)
			{
			#ifdef QUAKE_WORLD
				logfrag(te.enemy, self);
			#endif
				te.enemy.real_frags = te.enemy.real_frags + 1;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					te.enemy.frags = te.enemy.real_frags;
				finished = #TRUE;
			}

			te = find(te, classname, "timer");
			if (finished) te = world;
		}
	}

	// Remove all the timer entities for this player
	TeamFortress_RemoveTimers();

	// Drop any runes he would carry
	PlayerDropRunes(self);

	// Restore player's speed
#ifdef RESTORE_DEAD_SPEEDS

	stuffcmd(self,"cl_backspeed 1000\n");
	stuffcmd(self,"cl_forwardspeed 1000\n");
	stuffcmd(self,"cl_sidespeed 1000\n");
	stuffcmd(self,"cl_movespeedkey 2\n");

#endif

	if (deathmatch || coop)
		DropBackpack();
	
	PlayerDead();

	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;
	if (self.health < -40)
	{
		GibPlayer ();
		return;
	}

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;

	if (self.current_weapon <= #WEAP_AXE)
	{
		player_die_ax1 ();
		TeamFortress_SetupRespawn(#FALSE);
		return;
	}

	i = 1 + floor(random()*6);
	
	if (i == 1)
		player_diea1();
	else if (i == 2)
		player_dieb1();
	else if (i == 3)
		player_diec1();
	else if (i == 4)
		player_died1();
	else
		player_diee1();
	
	// get ready to spawn!
	TeamFortress_SetupRespawn(#FALSE);
};

void() set_suicide_frame =
{	// used by kill command and diconnect command (OfN suicide)
	if (self.model != "progs/player.mdl")
		return; // allready gibbed

// Was commented
	//self.frame = $deatha11;
	self.solid = #SOLID_NOT;
	self.movetype = #MOVETYPE_TOSS;
	self.deadflag = #DEAD_DEAD;
	self.nextthink = -1;
// was comented

	/* OfN <- commented by
	setmodel(self, string_null);
	setsize (self, #VEC_HULL_MIN, #VEC_HULL_MAX);*/
};

void() set_suicide_frame_disc =
{	// used by kill command and diconnect command (OfN disconnect)
	if (self.model != "progs/player.mdl")
		return; // allready gibbed

/*	
	self.frame = $deatha11;
	self.solid = #SOLID_NOT;
	self.movetype = #MOVETYPE_TOSS;
	self.deadflag = #DEAD_DEAD;
	self.nextthink = -1;
*/

	setmodel(self, string_null);
	setsize (self, #VEC_HULL_MIN, #VEC_HULL_MAX);
};



void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()	player_diea11	=	[	$deatha11,	player_diea11 ] {PlayerCorpse();};

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {};
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerCorpse();};

void()	player_diec1	=	[	$deathc1,	player_diec2	] {};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {};
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerCorpse();};

void()	player_died1	=	[	$deathd1,	player_died2	] {};
void()	player_died2	=	[	$deathd2,	player_died3	] {};
void()	player_died3	=	[	$deathd3,	player_died4	] {};
void()	player_died4	=	[	$deathd4,	player_died5	] {};
void()	player_died5	=	[	$deathd5,	player_died6	] {};
void()	player_died6	=	[	$deathd6,	player_died7	] {};
void()	player_died7	=	[	$deathd7,	player_died8	] {};
void()	player_died8	=	[	$deathd8,	player_died9	] {};
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerCorpse();};

void()	player_diee1	=	[	$deathe1,	player_diee2	] {};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {};
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerCorpse();};

void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {};
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {};
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {};
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {};
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {};
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {};
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {};
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {};
void()	player_die_ax9	=	[	$axdeth9,	player_die_ax9	] {PlayerCorpse();};

/*void() Headless_Think =
{
	self.frame = self.frame + 1;

	if (self.frame == 7 || self.frame == 18)
	{
		self.nextthink = time + 30 + random()*10;
		self.think = SUB_Remove;
		return;
	}
	
	self.nextthink = time + 0.1;
};*/

//===========================================================
// Airgun player stuff

void() player_airgun1	=[$rockatt1, player_airgun2  ] {self.weaponframe=1;};
void() player_airgun2	=[$rockatt2, player_airgun3  ] {self.weaponframe=2;};
void() player_airgun3	=[$rockatt3, player_airgun4  ] {self.weaponframe=3;};
void() player_airgun4	=[$rockatt3, player_airgun5  ] {self.weaponframe=4;};
void() player_airgun5	=[$rockatt4, player_airgun6  ] {self.weaponframe=5;};
void() player_airgun6	=[$rockatt4, player_airgun7  ] {self.weaponframe=6;};
void() player_airgun7	=[$rockatt5, player_airgun8  ] {self.weaponframe=7;};
void() player_airgun8	=[$rockatt6, player_run  ] {self.weaponframe = 8;};
void() player_failedairgun1   =[$nailatt1, player_failedairgun2  ] {self.weaponframe=6;};
void() player_failedairgun2   =[$nailatt2, player_failedairgun3  ] {self.weaponframe=7;};
void() player_failedairgun3   =[$nailatt2, player_run  ] {self.weaponframe=8;};

//================================================================0
// Laser cannon player stuff

void() player_laser1   =[$nailatt1, player_laser2  ] 
{
	if (!self.button0 || intermission_running || self.tfstate & #TFSTATE_RELOADING)
		{player_run ();return;}

	self.attack_finished = time + 0.2;
	self.weaponframe=1;
	HIP_FireLaser(0);
};
void() player_laser2   =[$nailatt2, player_laser3  ] 
{
	if (!self.button0 || intermission_running || self.tfstate & #TFSTATE_RELOADING)
		{player_run ();return;}

	self.weaponframe=2;
};
void() player_laser3   =[$nailatt2, player_laser4  ] 
{
	if (!self.button0 || intermission_running || self.tfstate & #TFSTATE_RELOADING)
		{player_run ();return;}

	self.attack_finished = time + 0.2;
	self.weaponframe=4;
	HIP_FireLaser(1);
};
void() player_laser4   =[$nailatt1, player_laser1  ] 
{
	if (!self.button0 || intermission_running || self.tfstate & #TFSTATE_RELOADING)
		{player_run ();return;}

	self.weaponframe=5;
};

//____________________________________________________//
