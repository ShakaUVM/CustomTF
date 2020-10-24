/*======================================================
	JOBS.QC 		Custom TeamFortress v3.2SB1 

	(c) William Kerney			2/9/00
	(c) SB-1 Tech				25/10/00
========================================================
Functions for handling the custom class professions
======================================================*/

//WK - all of this

void() DropToCustomClassGen; //Called when starting class generation
void() DropFromCustomClassGen; //Called when finished class generation
void() PrintMoney;
void(float in) PrintRefund;
void(float in) PrintNotEnoughMoney;
void(float cost, float type) BuyItem;
void(float cost, float type) BuyJob;
/*void(float cost, float type) BuyGren1;
void(float cost, float type) BuyGren2;*/
void() FragGrenadeTouch;
void() FragGrenadeExplode;
void() KracGrenadeTouch;
void() KracGrenadeExplode; 
void(entity bastard,float threshold) createBastard;
void() UseJobSkill; //Function for handling professions
void (entity targ,float pain) RevealThief;
float (entity thing) canairpush;
void() PsionicTimer;
void() player_run;

//Extern
void (vector org, entity death_owner) spawn_tdeath;
//void (string gib, float health) ThrowGib;
void(string gibname, float dm, float makecool, float gibskin, float gibkgs, float randorg) ThrowGib;
float() W_BestWeapon;
void() W_SetCurrentAmmo;
void(entity p) TeamFortress_SetSpeed;
void(entity p) TeamFortress_SetSkin;
void () BecomeExplosion;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void() SUB_regen;
float modelindex_eyes, modelindex_player, modelindex_null;
void(float inAuto) W_FireMedikit;
void(float inAuto) TeamFortress_ID;
void(float range,float inAuto) TeamFortress_Scan;
void(float points, float type) custom_demon_create;
void() kill_my_demons;
void() player_assaultcannondown1;
void (entity rhook) Reset_Grapple;
/*void (string temp) DebugSprint;
void (float temp)  DebugSprintFloat;*/
void() TeamFortress_RegenerateCells; // for thief

//- OfN Cyber Interface is now a job itself
//---- OfN
void(entity mine_owner) DetonateMines;
float(entity thing) IsMonsterNonArmy;
float(entity thing) IsMonster; // for mines
void() JobArmy;
void() JobHacker;

void(entity player) ArmyInit;

//==================================================================
// Functions to handle extras on army and warlock jobs (by now)

float(entity player) GetJobExtras =
{
	if (player.job & #JOB_EXTRA1)
	{
		if (player.job & #JOB_EXTRA2)
			return 3; // For future extra item
		
		return 1;
	}

	if (player.job & #JOB_EXTRA2)
		return 2;

	return 0;
};

void(entity player, float extras) SetJobExtras =
{
	if (!extras)
	{
		player.job = player.job - (player.job & (#JOB_EXTRA1 | #JOB_EXTRA2));
		return;
	}

	if (extras == 1)
	{
		player.job = player.job - (player.job & #JOB_EXTRA2);
		player.job = player.job | #JOB_EXTRA1;
		return;
	}

	if (extras == 2)
	{
		player.job = player.job - (player.job & #JOB_EXTRA1);
		player.job = player.job | #JOB_EXTRA2;
		return;    
	}

	if (extras == 3) // Unused by now
	{
		player.job = player.job | #JOB_EXTRA2 | #JOB_EXTRA1;
		return;    
	}
};

//
//	Functions for handling our "professions"
//	which add some class-like behavior to this 
//	unclassy version of TF
//

/*
** Thief Profession -
** Hides in shadows, can become fully hidden, leaves shadows if attacks or attacked
*/
void() JobThief =
{
	//local float vel;
	local entity te;
	//local string st;

	//PZ don't hide if we are looking down our scope.
	// (lol.. I'm pretty sure I didn't make this comment. -PZ)
	local entity sniperdot;
	sniperdot = find(world, classname, "timer");

	while(sniperdot) {
		if(sniperdot.netname == "sniperdot" && sniperdot.owner == self) {
			sprint(self,#PRINT_HIGH,"No more thief sniping, sorry!\n");
			return;
		}

		sniperdot = find(sniperdot, classname, "timer");
	}

	// Neo mode: don't allow Neo to use thief skill
	if (neo && self == neoLives)
	{
		sprint(self, #PRINT_HIGH, "Neo can't hide! You...you homosapien!\n");
		return;
	}

	if (self.job & #JOB_ACTIVE) { //We are hiding
		//If we hit "skill" again and we are moving, we leave shadows
		//vel = vlen(self.velocity);
		/*if (vel > 100) { //Leave shadows
		//	sprint(self,#PRINT_HIGH,"Leaving shadows...\n");
		//}
		else { //Become fully hidden
			//RJM - Can't hide while carrying flags.
			if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT)) { 
				sprint(self,#PRINT_HIGH,"Not while glowing, idiot.\n");
				return;
			}
			sprint(self,#PRINT_HIGH,"You are fully hidden\n");
			self.frame = 0;
			self.weaponframe = 0;
			self.modelindex = modelindex_null;
			self.job = self.job | #JOB_FULL_HIDE;
		} */
		sprint(self, #PRINT_HIGH, "Μεαφιξη σθαδοχσ...\n");
		self.modelindex = modelindex_player;
		self.job = self.job - #JOB_ACTIVE;
		self.job = self.job - (self.job & #JOB_FULL_HIDE);
		self.job_finished = time + 2;
		TeamFortress_SetSpeed(self);
	}
	/*else if (self.job & #JOB_FULL_HIDE) {
		RevealThief(self,#FALSE);
	} */
	else { //Start hiding
		//RJM - Can't hide while carrying flags.
		//WK  - Allow them to go eyes invisible but not full hide
		/*
		if (self.effects & (#EF_DIMLIGHT | #EF_BRIGHTLIGHT)) { 
			sprint(self, #PRINT_HIGH, "Not while glowing, gimp.\n");
			return;
		}
		*/
		sprint(self,#PRINT_HIGH,"Εξτεςιξη σθαδοχσ...\n");
		self.frame = 0;
		self.weaponframe = 0;
		self.modelindex = modelindex_eyes;
		self.job = self.job | #JOB_ACTIVE;
		self.job_finished = time + 2;
		TeamFortress_SetSpeed(self);

		te = spawn();
		te.nextthink = time + #PC_SPY_CELL_REGEN_TIME;
		te.think = TeamFortress_RegenerateCells;
		te.owner = self;
		te.classname = "timer";
	}
};



/*
** Runner Profession -
** Sprints at +200 speed for a while, then has to rest (half speed)
*/
#define PHASE1 5
#define PHASE2 3
#define PHASE3 5
void() RunnerThink =
{
	self.heat = self.heat + 1;
	if (self.heat == 1) { //Initial Phase
		sprint(self.owner,#PRINT_HIGH,"Sprinting...\n");
		TeamFortress_SetSpeed(self.owner);
		self.nextthink = time + #PHASE1;
	}
	else if (self.heat == 2) {
		sprint(self.owner,#PRINT_HIGH,"Recovering...\n");
		self.owner.job = self.owner.job | #JOB_TIRED;
		TeamFortress_SetSpeed(self.owner);
		self.nextthink = time + #PHASE2;
	}	
	else if (self.heat == 3) {
		self.owner.job = self.owner.job - (self.owner.job & #JOB_ACTIVE);
		self.owner.job = self.owner.job - (self.owner.job & #JOB_TIRED);
		TeamFortress_SetSpeed(self.owner);
		self.nextthink = time + #PHASE3;
	}
	else {
		dremove(self);
	}	
};
void() JobRunner =
{
	local entity RunnerTimer;

	self.job = self.job | #JOB_ACTIVE; //Timer will remove this

	RunnerTimer = spawn ();
	RunnerTimer.classname = "timer";
	RunnerTimer.owner = self;
	RunnerTimer.nextthink = time + 0.5; //Small delays are cool
	RunnerTimer.think = RunnerThink;
	RunnerTimer.heat = 0;
	self.job_finished = time + #PHASE1 + #PHASE2 + #PHASE3 + 0.6;
};





void() JobWarlock =
{
	if (self.attack_finished > time)
	{
		sprint(self,#PRINT_HIGH,"You can't shoot and summon at the same time\n");
		self.job_finished = time + 2;
		return;
	}
	
	if (self.current_menu == #MENU_DEMON)
	{
		Menu_Demon_Input(7);
		return;
	}

	self.current_menu = #MENU_DEMON;
	self.menu_count = #MENU_REFRESH_RATE;
};

/*
** Chaplan Profession -
** Dispels demons, inspires teammates to do x2 damage, but can't attack himself
** Timer triggers every so often, checking to see if you want to resume inspire
*/
#define GUIDE_TIME 1 //Period of how often lightning guides are shown. Must be less than...
#define CHAPLAN_TIME 1 //Period of seconds how often it fires
#define INSPIRE_TIME 6 //How long someone stays inspired
#define CHAPLAN_RADIUS 320 //About the radius of brightglow
#define CHAPLAN_HEAL 50    //If you have a medikit you'll heal friends this much
#define CHAPLAN_HEAL_DELAY 3 //You can't have been shot in last three seconds to be healed

//Hunt for all friendlies and power them up
//Take special care to coexist with Quad damage
void() ChaplanInspire = {
	local entity head;
	local float take;
	head = findradius(self.origin, #CHAPLAN_RADIUS);
	
	while (head)
	{
		//Dispel enemy demons
		//- OfN - if (head.classname == "monster_demon1" || head.classname == "monster_shambler")
		if (IsMonsterNonArmy(head))
		{ //No short circuit evaluation, so...
			  if (!Teammate(head.real_owner, self))
			  { //...to avoid a crash from deref
				/*
				if ((head.health <= 200 && head.classname == "monster_demon1") || head.health < 500 && head.classname == "monster_shambler") {
					sprint(self,#PRINT_HIGH,"You dispel a demon\n");
					self.real_frags = self.real_frags + 1;
					if (!(toggleflags & #TFLAG_TEAMFRAGS))
						self.frags = self.real_frags;
				}
				if (head.classname == "monster_shambler")
					TF_T_Damage(head, self, self, 500, 0, 0);
				else if (head.classname == "monster_demon1")
					TF_T_Damage(head, self, self, 200, 0, 0);
				*/
						TF_T_Damage(head, self, self, 220, 0, 0); // OfN
			}
		}
		else if (head.classname == "player" &&	//Person who is...
			   head.health > 0 && // OfN Alive
			   Teammate(head, self) && //Same Team
			   head != self &&			//Not me
			   !(head.is_undercover)  &&		//Not a spy
			   !(head.job & #JOB_CHAPLAN)  &&	//Not a chaplan
			   head.playerclass != #PC_CIVILIAN &&	//KK
			   //... and not Quadded
			   !(head.items & #IT_QUAD && !(head.tfstate & #TFSTATE_INSPIRED))
			)
		{
			head.items = head.items | #IT_QUAD;
			head.inspirator = self; //We are their designated preacherman
			head.super_time = 1;
			if (head.super_damage_finished < time + #INSPIRE_TIME)
				head.super_damage_finished = time + #INSPIRE_TIME;
			head.tfstate = head.tfstate | #TFSTATE_INSPIRED;
			//Heal them if we have automedic too
			//SB amended to medikit since there is no automedic now
			if ((self.weapons_carried & #WEAP_MEDIKIT) && (self.last_attacked_time < time + #CHAPLAN_HEAL_DELAY)) {
				take = head.max_health - head.health;
				if (take > #CHAPLAN_HEAL) take = #CHAPLAN_HEAL;
				if (take < 0) take = 0;
				head.health = head.health + take;
			}
		}
		head = head.chain;
	}

};


//Draws lightning bolts towards all the friendlies we're inspiring
void() ChaplanGuides = {
	local entity head;
	head = find(world,classname,"player");
	while (head) {
		if (head.inspirator == self) {
			// Create the Lightning 
			msg_entity = self;
			WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
			WriteByte (#MSG_ONE, #TE_LIGHTNING1);
			WriteEntity (#MSG_ONE, self);
			WriteCoord (#MSG_ONE, self.origin_x);
			WriteCoord (#MSG_ONE, self.origin_y);
			WriteCoord (#MSG_ONE, self.origin_z + 8);
			WriteCoord (#MSG_ONE, head.origin_x);
			WriteCoord (#MSG_ONE, head.origin_y);
			WriteCoord (#MSG_ONE, head.origin_z + 8);
			head = world;
		}
		else //We can only draw one lightning. :p
			head = find(head,classname,"player");
	}
};

void() ChaplanThink = {
	local entity oself;
	//local string temp; //REMOVEME
	oself = self;
	self = self.owner;

	ChaplanGuides();
	oself.nextthink = time + #GUIDE_TIME;
	oself.frags = oself.frags + #GUIDE_TIME;
	if (oself.frags >= #CHAPLAN_TIME) { //Do the full thing every second
		oself.frags = 0;
		if (self.heat == #TRUE) { //Inspire everyone again
			//sprint(self,#PRINT_HIGH,"Chaplan: Still Preaching\n");
			ChaplanInspire();
		}
		else { //We stopped preaching
			sprint(self,#PRINT_HIGH,"You finish your sermon\n");
			//Sync CHAN_MUSIC with disconnect and sound below
			self.job = self.job - (self.job & #JOB_ACTIVE);
			//sound (self, #CHAN_MUSIC, "items/r_item1.wav", 0.1, #ATTN_NORM);
			//sound (self, #CHAN_MUSIC, "misc/null.wav", 0.1, #ATTN_NORM);
			//WK 1/7/7 Better music stopping
			sound (self, #CHAN_MUSIC, "misc/null.wav", 0.1, 0);
			self.effects = self.effects - (self.effects & #EF_BRIGHTLIGHT);
			//self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_RELOADING);
			self.current_weapon = self.weapon;
			W_SetCurrentAmmo();
			oself.nextthink = time + 0.1;
			oself.think = SUB_Remove;
		}
	}
	self = oself;
};

void() JobChaplan =
{
	local entity tWeapon;
	if (self.job & #JOB_ACTIVE) {
		//self.job = self.job - #JOB_ACTIVE;
		if (self.heat == #TRUE) //Only print this once
			sprint(self,#PRINT_HIGH,"You gradually stop preaching...\n");
		self.heat = #FALSE; //Bad to turn off active, since technically job is still on.
		self.job_finished = time + 0.7; //Don't allow them to trigger too often
		return;
	}
	if (self.tfstate & #TFSTATE_RELOADING || self.is_feigning || self.heat) {
		sprint(self,#PRINT_HIGH,"You can't preach while doing other stuff\n");
		self.job_finished = time + 0.5; //Don't allow them to trigger too often
		return;
	}

	sprint(self,#PRINT_HIGH,"You begin preaching. Hit skill again to stop.\n");
	tWeapon = spawn();
	tWeapon.frags = 0; //Clear guides counter
	tWeapon.owner = self;
	tWeapon.classname = "timer";
	tWeapon.nextthink = time + #GUIDE_TIME;
	tWeapon.think = ChaplanThink;
	self.job = self.job | #JOB_ACTIVE;
	self.job_finished = time + 0.3; //Don't allow them to trigger too often

	//Hide our weapon. Can't shoot while preaching.
	self.weapon = self.current_weapon;
	self.current_weapon = 0;
	self.weaponmodel = "";
	self.weaponframe = 0;
	self.heat = #TRUE; //We're actively preaching.
	//self.tfstate = self.tfstate | #TFSTATE_RELOADING;

	//Start playing preacher music, glow and inspire!
	//sound (self, #CHAN_VOICE, "ambience/orff.wav", 0.75, #ATTN_NORM);
	sound (self, #CHAN_MUSIC, "ambience/orff.wav", 0.75, #ATTN_NORM);
	self.effects = self.effects | #EF_BRIGHTLIGHT;
	ChaplanInspire();
};



/*
** Martyr Proficiency -
** Becomes invincible, but dies after a few seconds
*/
void() MartyrThink =
{
	//Self.owner is the guy who became a martyr
	//local entity oself;

	//Clean these up so we can kill him
	//self.job = self.job - (self.job & #JOB_ACTIVE);
	self.owner.items = self.items - (self.items & #IT_INVULNERABILITY);
	self.owner.invincible_time = 0;
	self.owner.invincible_finished = 0;
	self.owner.effects = self.owner.effects - (self.owner.effects & #EF_DIMLIGHT);

	deathmsg = #DMSG_MARTYR;
	TF_T_Damage(self.owner, self.owner.martyr_enemy, self.owner.martyr_enemy, self.owner.health + 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
};

// SB I'll leave this here since it's still close to a job
// WK Of course it's a job...
#define MARTYR_TIME 3.5
void() JobMartyr =
{
	local entity tWeapon;
	local float martyr_time;
	
	if (self.is_abouttodie)
		return;
	
	martyr_time = #MARTYR_TIME;
	//WK 5-15-08 Adjust martyr time based on amount of life left
	if (self.health < 10) {
		martyr_time = martyr_time - 1.5; //2s
	} else if (self.health < 33) {
		martyr_time = martyr_time - 1; //2.5s
	} else if (self.health < 50) {
		martyr_time = martyr_time - 0.5; //2s
	} else if (self.health > 140) {
		martyr_time = martyr_time + 1; //4.5s
	} else if (self.health > 100) {
		martyr_time = martyr_time + 0.5; //4s
	}

	sprint(self,#PRINT_HIGH,"Beginning your suicide run...\n");
	self.items = self.items | #IT_INVULNERABILITY;
	self.invincible_time = 1;
	self.invincible_finished = time + martyr_time + 1; //Overlap so we can't die till end
	sound (self, #CHAN_VOICE, "shaka/martyr.wav", 1, #ATTN_NORM); //WK 5-15-08 Ieeeee!

	self.job = self.job | #JOB_ACTIVE;
	self.job_finished = time + martyr_time + 10; //Once it's triggered, that's it
	
	tWeapon = spawn();
	tWeapon.owner = self;
	tWeapon.classname = "timer";
	tWeapon.nextthink = time + martyr_time;
	tWeapon.think = MartyrThink;
};

/* Berserker Profession -
** A simple soul that just likes killing things
** Takes 50 self inflicted damage and gets Quad for 5 seconds
** If he can't pay up with the 50 health he gets reduced to 1 and dies after his 5 seconds
*/

// now takes #BERSERKER_HP_COST hp

#define BERSERK_TIME 4

void() BerserkerKillTimer =
{
	if (!self.tfstate & #TFSTATE_CONCUSSIONED)
		stuffcmd(self.owner, "v_idlescale 0\n");
	
	if (self.has_sensor)
	{
		deathmsg = #DMSG_BERSERK;
		TF_T_Damage(self.owner, self.owner, self.owner, self.owner.health, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);	
	}


	self.job = self.job - (self.job & #JOB_ACTIVE); //- OfN
	self.owner.is_abouttodie = #FALSE;
	dremove(self);
};

void() JobBerserker =
{
	if (self.super_damage_finished > 0)
		return;
	if (self.is_abouttodie)
		return;
	
	newmis = spawn();
	newmis.classname = "timer";
	newmis.nextthink = time + #BERSERK_TIME + 1;
	newmis.think = BerserkerKillTimer;
	newmis.owner = self;
	
	if (self.health > #BERSERKER_HP_COST)
		TF_T_Damage(self, self, self, #BERSERKER_HP_COST, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
	else
	{
		self.health = 1;
		newmis.has_sensor = 1;
	}
	self.super_time = 1;
	self.super_damage_finished = time + #BERSERK_TIME + 1;
	self.items = self.items | #IT_QUAD;
	self.is_abouttodie = #TRUE;
	self.job = self.job | #JOB_ACTIVE; //- OfN
	self.job_finished = time + #BERSERK_TIME * 3;
	
	stuffcmd(self, "v_idlescale 20\n"); //WK 30
};


/*
** Judoka Profession -
** Disarms opponents so they cannot attack
*/
//This is guaranteed to be removed if either target or owner dies or disconnects
//So we don't have to do error checking on those situations
//Four special cases, Sniper Rifle, Medikit, AC and Grapple, have side effects
// when you remove them. Need special cases to handle their theft
//WK 6/1/7 CANT_ATTACK_TIME lowered from 5s, since it was kind of lame, since you have no weapon anyway.
#define DISARM_TIME 10
#define CANT_ATTACK_TIME 2
#define HIT_DELAY 8
#define MISS_DELAY 1
void() JudokaRearm =
{
	//Self.owner is the guy who had his weapon taken away
	//Self.enemy is the guy who took it away
	local entity oself,te;

	self.enemy.job = self.enemy.job - (self.enemy.job & #JOB_ACTIVE);
	if (self.heat == 1) { //We have their weapon
		////Fix feign while stolen
		self.enemy.weapon = 0;
		////Fix reloading
		te = find(world, netname, "reloadtimer");
		while (te != world)
		{
			if (te.classname == "timer" && te.owner == self.enemy) {
				oself = self;
				self = te;
				self.think();
				self = oself;
				te.think = SUB_Remove;
				te.nextthink = time + 0.1;
			}
			te = find(te, netname, "reloadtimer");
		}
		////Fix double weapons
		if (self.current_weapon == #WEAP_SNIPER_RIFLE) {
			self.owner.weapons_carried = self.owner.weapons_carried | #WEAP_AUTO_RIFLE; 			
			self.enemy.weapons_carried = self.enemy.weapons_carried - (self.enemy.weapons_carried & #WEAP_AUTO_RIFLE);
		}
		////Fix weird weapons
		if (self.current_weapon == #WEAP_ASSAULT_CANNON && self.enemy.current_weapon == #WEAP_ASSAULT_CANNON) {
			oself = self;
			self = self.enemy;
			stuffcmd(self, "v_idlescale 0\n");
			//WK 4-8-7 Not Applicable Any More 
			//self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
			TeamFortress_SetSpeed(self);
			self.weaponframe = 0;
			self.count = 1;
			self.heat = 0;
			self.button0 = 0;
			self.fire_held_down = #FALSE;
			player_assaultcannondown1();
			self = oself;
		}
		if (self.current_weapon == #WEAP_HOOK && self.enemy.hook_out) {
			oself = self;
			self = self.enemy;
			Reset_Grapple (self.hook);
			self.weaponframe = 0;
			self = oself;
		}

		sprint(self.owner,#PRINT_HIGH,"You get your weapon back\n");
		self.owner.weapons_carried = self.owner.weapons_carried | self.current_weapon;
		TeamFortress_SetSpeed(self.owner);	//WK 3/2/7 Judo Speed fix

		sprint(self.enemy,#PRINT_HIGH,"You lose your stolen weapon\n");
		self.enemy.weapons_carried = self.enemy.weapons_carried - (self.enemy.weapons_carried & self.current_weapon);
		TeamFortress_SetSpeed(self.enemy);	//WK 3/2/7 Judo Speed fix

		//Fix for a bug that would let someone keep their weapon if they switched to autorifle before
		//the weapon returned.
		if (self.enemy.current_weapon == self.current_weapon || self.current_weapon == #WEAP_SNIPER_RIFLE || self.current_weapon == #WEAP_MEDIKIT) {	
			oself = self;
			self = self.enemy;
			self.weaponframe = 0;
			self.current_weapon = W_BestWeapon ();
			W_SetCurrentAmmo();
			self = oself;
		}
		//TODO: Is this really a Fix for diving?
		//Should we even do this? Might cause firing skip. Evaluate
		self.enemy.weaponframe = 0;
	}

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
};
void() JobJudoka =
{
	//Take the weapon of any person in front of you and force a reload
	self.job_finished = time + #MISS_DELAY; //Delay if we don't hit
	local vector	source;
	local entity tWeapon,oself;
	local entity te;
	
	makevectors(self.v_angle);
	source = self.origin + '0 0 16';
	if (!self.cutf_items & #CUTF_CLOSECOMBAT) 
		traceline (source, source + v_forward*63, #TL_ANY_SOLID, self);
	else
		traceline (source, source + v_forward*96, #TL_ANY_SOLID, self);
	if (trace_fraction == 1.0) {
		sprint (self, #PRINT_HIGH, "You miss.\n");
		return;
	}

	
	if (trace_ent)
	if (trace_ent.classname == "player") {
		if (trace_ent.#runes & #RUNE_RESIS)
		{
			sprint (self, #PRINT_HIGH, "He is protected by a mysterious power!\n"); //WK Typo
			return;
		}
		//WK 5-15-08 Don't judo people who are reloading and thus don't have a weapon out
		if (trace_ent.tfstate & #TFSTATE_RELOADING) {
			sprint (self, #PRINT_HIGH, "He is reloading, and doesn't have a weapon to take!\n"); 
			return;
		}
	}

	if (trace_ent.classname == "player" && !Teammate(trace_ent, self) && trace_ent.playerclass != #PC_UNDEFINED)
	{
		if (trace_ent.current_weapon == #WEAP_SNIPER_RIFLE && trace_ent.cutf2_items & #CUTF2_SHINIGAMI) {
			sprint(self,#PRINT_HIGH,"He is wielding the Shinigami, and cannot be disarmed!\n");
			sprint (trace_ent, #PRINT_HIGH, self.netname);
			sprint (trace_ent, #PRINT_HIGH, " attempted to disarm you, but the power of the Shinigami protected you!\n");
			return;
		}
		if ((trace_ent.current_weapon == #WEAP_SNIPER_RIFLE || trace_ent.current_weapon == #WEAP_AUTO_RIFLE) && self.cutf2_items & #CUTF2_SHINIGAMI) {
			sprint(self,#PRINT_HIGH,"The Shinigami prevent you from stealing a second rifle!\n");
			sprint (trace_ent, #PRINT_HIGH, self.netname);
			sprint (trace_ent, #PRINT_HIGH, " attempted to disarm you, but the power of the Shinigami protected you!\n");
			return;
		}

		if (self.is_undercover) //Taking someone's weapon should give you away
			Spy_RemoveDisguise(self);

		sprint (trace_ent, #PRINT_HIGH, "You have been disarmed by ");
		sprint (trace_ent, #PRINT_HIGH, self.netname);
		sprint (trace_ent, #PRINT_HIGH, "\n");

		self.job = self.job | #JOB_ACTIVE;
		//Simplify the dual-weapon problem
		if (trace_ent.current_weapon == #WEAP_AUTO_RIFLE)
			trace_ent.current_weapon = #WEAP_SNIPER_RIFLE;

		//WK 5-15-08 We should not reach this code since we block disarming people who are TFSTATE_RELOADING above, but doesn't hurt to double check
		// to remove a reload timer if TFSTATE_RELOADING wasn't properly set.
		//If already reloading, remove that timer
		te = find(world, netname, "reloadtimer");
		while (te != world)
		{
			if (te.classname == "timer" && te.owner == trace_ent) {
				oself = self;
				self = te;
				self.think();
				self = oself;
				te.think = SUB_Remove;
				te.nextthink = time + 0.1;
			}
			te = find(te, netname, "reloadtimer");
		}

		tWeapon = spawn();
		tWeapon.owner = trace_ent;
		tWeapon.enemy = self;
		tWeapon.current_weapon = trace_ent.current_weapon;
		tWeapon.classname = "timer";
		tWeapon.netname = "judokatimer";
		tWeapon.nextthink = time + #DISARM_TIME;
		tWeapon.think = JudokaRearm;

		//Remove the weapon
		trace_ent.attack_finished = time + #CANT_ATTACK_TIME;
		trace_ent.weaponmodel = string_null;
		trace_ent.weaponframe = 0;
		trace_ent.currentammo = 0;

		TeamFortress_SetSpeed(self);  //WK 3/2/7 Judo Speed fix
		TeamFortress_SetSpeed(trace_ent); //WK 3/2/7 Judo Speed fix

		if ((trace_ent.job & #JOB_JUDOKA && trace_ent.job_finished > time) || trace_ent.current_weapon == 0) {
			//Hit fellow judoka or chaplan
			sprint (self, #PRINT_HIGH, "You throw him with a mighty Seoi Otoshi\n");
			deathmsg = #DMSG_JUDOKA;
			TF_T_Damage (trace_ent, self, self, 120, #TF_TD_NOTTEAM, #TF_TD_MELEE); //WK 150
		}
		else if (self.weapons_carried & trace_ent.current_weapon) {
			sprint (self, #PRINT_HIGH, "You knock his weapon out of his hands\n");
			tWeapon.heat = 0; //I.e., we didn't take a weapon
			trace_ent.attack_finished = time + #DISARM_TIME;			
			deathmsg = #DMSG_JUDOKA;
			TF_T_Damage (trace_ent, self, self, 80, #TF_TD_NOTTEAM, #TF_TD_MELEE); //WK 100
		}
		else if (trace_ent.current_weapon != 0 && trace_ent.current_weapon != #WEAP_AXE){
			//Steal their weapon if they have one
			sprint (self, #PRINT_HIGH, "You rip his weapon from his hands!\n");
			tWeapon.heat = 1;

			//Fix double weapons
			if (trace_ent.current_weapon == #WEAP_SNIPER_RIFLE) {
				self.weapons_carried = self.weapons_carried | #WEAP_AUTO_RIFLE; 			
				trace_ent.weapons_carried = trace_ent.weapons_carried - (trace_ent.weapons_carried & #WEAP_AUTO_RIFLE);
			}
			if (trace_ent.current_weapon == #WEAP_MEDIKIT) {
				self.health = self.max_health; //You heal yourself. :)
			}
			////Fix weird weapons
			if (trace_ent.current_weapon == #WEAP_ASSAULT_CANNON) {
				oself = self;
				self = trace_ent;
				stuffcmd(self, "-attack;v_idlescale 0\n");
				self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
				TeamFortress_SetSpeed(self);
				self.weaponframe = 0;
				self.count = 1;
				self.heat = 0;
				self.button0 = 0;
				self.fire_held_down = #FALSE;
				player_assaultcannondown1();
				self = oself;
			}
			if (trace_ent.current_weapon == #WEAP_HOOK && trace_ent.hook_out) {
				oself = self;
				self = trace_ent;
				Reset_Grapple (self.hook);
				self = oself;
			}

			self.weapons_carried = self.weapons_carried | trace_ent.current_weapon;
			self.current_weapon = trace_ent.current_weapon;
			W_SetCurrentAmmo();

			trace_ent.weapons_carried = trace_ent.weapons_carried - (trace_ent.weapons_carried & trace_ent.current_weapon);
			trace_ent.current_weapon = 0;

			//WK 5-15-08 Switch them to their best remaining weapon
			oself = self;
			self = trace_ent;
			self.current_weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
			self = oself;

			deathmsg = #DMSG_JUDOKA;
			TF_T_Damage (trace_ent, self, self, 40, #TF_TD_NOTTEAM, #TF_TD_MELEE); //WK 65
		}

		self.job_finished = time + #HIT_DELAY;
	}
	else
		sprint (self, #PRINT_HIGH, "You miss.\n");
};

void() JobCrusader;
void() JobGuerilla;

//WK 4/27/7 TAE KWON DO! TAE KWON DO!
//Combination sprinter, antigrav and melee guy
//If stopped, jumps straight up, which takes you up to a balcony.
//If running, does a longjump in that direction
//If he rams someone, inflicts a BOOT TO THE HEAD!

//WK 4/27/7 Brakes for the TKD Leap
//This is called two seconds or so after TKD skill, to break speed and reset gravity.
void () JobTKDThink = 
{
	local float playerspeed;
	playerspeed = vlen(self.owner.velocity);

/* Debugging Info
	local string temp_foo;
	temp_foo = ftos(playerspeed);
	bprint(#PRINT_HIGH,"Final Speed :");
	bprint(#PRINT_HIGH,temp_foo);
	bprint(#PRINT_HIGH,"\n");
*/

	//Normalize speed back down to max allowed
	if (playerspeed > self.owner.maxspeed) playerspeed = self.owner.maxspeed / playerspeed;
	else playerspeed = 1;
	self.owner.velocity = self.owner.velocity * playerspeed;
	self.owner.gravity = 1;

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
};

#define TKDHIGHJUMPTIME 0.6
#define TKDHIGHJUMPRESET 0.5
#define TKDLONGJUMPTIME 1.33
#define TKDLONGJUMPRESET 4.5 //WK 1-19-09 Was 5
void() JobTKD =
{
	local float playerspeed;
	local entity TKD_Brake;
	local vector temp_velocity;

	if (self.job & #JOB_ACTIVE) //WK 5-15-7 Don't allow further jumps after a double jump
		return;

	TKD_Brake = spawn();
	TKD_Brake.owner = self;
	//TKD_Brake.gravity = self.gravity;
	TKD_Brake.classname = "timer";
	TKD_Brake.netname = "tkdtimer";
	TKD_Brake.think = JobTKDThink;

	//Kiai!
	if (self.cutf_items & #CUTF_STEALTH) //WK 1-19-09 Kiai Quietly with Stealth
		sound (self, #CHAN_VOICE, "demon/djump.wav", 0.2, #ATTN_NORM);
	else
		sound (self, #CHAN_VOICE, "demon/djump.wav", 1, #ATTN_NORM);

	temp_velocity = self.velocity;
	temp_velocity_z = 0;
	playerspeed = vlen(temp_velocity);

	if (playerspeed < 180) { //High jump
		TKD_Brake.nextthink = time + #TKDHIGHJUMPTIME;
		self.job_finished = time + #TKDHIGHJUMPRESET; //High jumps are less tiring

		//We allow ninja-style double jumps, but only once.
		if (!(self.flags & #FL_ONGROUND) && !(self.waterlevel > 0)) {
			self.job_finished = self.job_finished + 1;
			self.velocity_z = 0;
			//The following flag gets cleared in player_think when we land on the ground...
			self.job = self.job | #JOB_ACTIVE; //WK 5-15-7 Set ACTIVE flag indicating we've done a double jump
		}

		self.gravity = 0.5;
		self.velocity_z = self.velocity_z + 600;

	} else { //Long jump
		self.gravity = 0.5;
		makevectors(self.angles);
		//WK 5-15-08 Allow people to TKD Backwards and normalize TKD Boost at +320
		//	Before, it was doubling the forward speed of the player which looked funny at low speeds
		if (v_forward * self.velocity > 0) playerspeed = 320; //Running forward
		else playerspeed = -320;
		//WK 1-19-09 20% faster jumps with Closecombat
		if (self.cutf_items & #CUTF_CLOSECOMBAT) playerspeed = playerspeed * 1.2;

		self.velocity = self.velocity + playerspeed*v_forward;
		if (self.velocity_z < 20)
			self.velocity_z = 200;
		else
			self.velocity_z = self.velocity_z + 180;

		TKD_Brake.nextthink = time + #TKDLONGJUMPTIME;
		self.job_finished = time + #TKDLONGJUMPRESET; //Long jumps are tiring
	}

/*
	sprint(self,#PRINT_HIGH,"Velocity: \n");
	local string stemp;
	stemp = vtos(self.velocity);
	sprint(self,#PRINT_HIGH,stemp);
	sprint(self,#PRINT_HIGH,"\n");
*/

	self.attack_finished = TKD_Brake.nextthink;
	self.flags = self.flags - (self.flags & #FL_ONGROUND);	
};

/*
==The Psion==
The Psion job has three levels, of increasing power.

Level 1:
Passive Ability: Mind Probe. Psions automatically uncover all enemy spies and thieves within 15 feet. Passive Ability: Mind Shield. Spy/Psions, on the other hand, are immune to being automatically uncovered, even by motion sensors. Active ability: Mind Blast. Once per 10 seconds you can mind blast an opponent ahead of you, psionizing them for 1 second (+.5s per  additional level of the job), making them unable to attack or perform any	actions.

Level 2: Passive Ability: Uncovering radius increases to 30 feet. Active Ability: Telekinetic Wave. When you hit skill, on top of the mind blast, you emit a telekinetic explosion, flinging away all objects near you (similar to using the airfist). If you face a rocket or similar projectile head-on, it will be reflected perfectly back at its owner. Active Ability: Telekinesis (triggers at the same time as the Telekinetic Wave). If you target a detpack, you can pick it up and move slowly with it. You take double damage while using telekinesis, and if you die while carrying it, the detpack explodes harmlessly. Both picking up and dropping a detpack damage its sensitive circuits, increasing the time before detonation.

Level 3: Passive Ability: Uncovering radius increases to 45 feet. Active Ability: Telekinetic Wave II. The radius of your Telekinetic Wave improves by 50%. Active Ability: Telekinesis II. You can pick up buildings and slowly walk with them. You take double damage while hauling buildings, and if you die, they explode (if they are friendly). If the buildings are killed while you are carrying them, your head may explode from the backlash.

*By default, you can only move your own buildings and enemy buildings.* To allow friendly psions to move your buildings, type 'setinfo psi on' at the console. Type 'setinfo psi off' to disable this. You cannot move turrets, as they are rooted into the ceiling.
*/

//.owner = self
//.oldenemy = hauling target
//BUG: This isn't working perfectly for sentryguns right now, especially when you manually det a sentrygun
//	 the psion doesn't die from it.
//The code which handles people dying and destroying the other pair is buggy, but the psion is functional.
//It works except in weird dying situations like suicide or detdispenser
#define HAULING_THINK_RATE 0.01
void() HaulingTimer = 
{
	local float dropit,boom,dist,af_det_delay,owner_speed;
	local vector target_loc,target_vel;

	deathmsg = #DMSG_PSION;

	//There's only two ways to drop it without killing both, by manually cancelling, or leaving range
	dropit = 0; //Setting this flag means we will drop the object this round.
	boom = 1; //Setting this flag means that we will blow up both of us.

	//Figure out if we have to drop it
	if (!self.owner) dropit = 1;
	else {
		if (!(self.owner.job & #JOB_ACTIVE)) {
			dropit = 1;
			boom = 0;
		}
		if (self.owner.health <= 0) dropit = 1;
	}
	if (!self.oldenemy) dropit = 1;
	else {
		if (self.oldenemy.takedamage && self.oldenemy.health <= 0) dropit = 1;
		if (IsBuilding(self.oldenemy) && self.oldenemy.tf_items & #NIT_TURRET) dropit = 1; //Blow up if they turret what we're carrying
		dist = vlen(self.owner.origin - self.oldenemy.origin);
		if (dist > 600) { 
			dropit = 1; //Max range of 600 for TK
			boom = 0; //Don't allow cheap build killing
		}
	}

	if (self.owner.job & #JOB_TIRED) { //Set only when we die, during RemoveTimers, to force a drop
		self.owner.job = self.owner.job - #JOB_TIRED; //Clear flag
		dropit = 1;
		boom = 1;
	}

	if (dropit) {
		//Lower the carried thing back to ground.
		if (self.oldenemy) {
			self.oldenemy.movetype = #MOVETYPE_FLY;
			self.oldenemy.velocity = '0 0 -150'; //So we let it fall

			//Handle 2-part sentryguns
			if (self.oldenemy.classname == "building_sentrygun") {
				if (self.oldenemy.trigger_field) {
					self.oldenemy.trigger_field.velocity = self.oldenemy.velocity; //Parallel velocity
					if (pointcontents(self.oldenemy.origin - '0 0 8') == #CONTENT_EMPTY)
							setorigin(self.oldenemy.trigger_field,self.oldenemy.origin - '0 0 8');
				}
			} else if (self.oldenemy.classname == "detpack") {
				//10/10/7 Remove the purple glow from stasis
				self.oldenemy.effects = self.oldenemy.effects - (self.oldenemy.effects & (#EF_PURPLE));

				//Dropping a det messes up its circuits
				af_det_delay = 10 + floor(10*random()); //WK 10/10/7 Was 2+rand(5)
				self.oldenemy.nextthink = self.oldenemy.nextthink + af_det_delay; //WK Scramble the detpack's timer. :)
				self.oldenemy.oldenemy.health = self.oldenemy.oldenemy.health + af_det_delay;
				sprint(self.owner,#PRINT_HIGH,"You damage the detpack's circuits\n");
				if (self.owner != self.oldenemy.owner) 
					sprint(self.oldenemy.owner,#PRINT_HIGH,"Your detpack circuits have been damaged!\n");
				self.oldenemy.avelocity = '0 0 0';
				self.oldenemy.angles = '90 0 0';
				self.oldenemy.movetype = #MOVETYPE_BOUNCE;
			}
		}

		if (boom) { //If one person dies, both die
			if (self.owner) {
				if (self.owner.health > 0 && self.owner.takedamage) { //Explode our brain
					TF_T_Damage(self.owner, self.owner, self.owner, self.owner.health + 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
				}
			}
			if (self.oldenemy) {
				if (IsBuilding(self.oldenemy)) //Blow up only friendly buildings we're carrying
				{
					//bprint(#PRINT_HIGH,"Blow the build!\n");
					if (self.oldenemy.health > 0 && self.oldenemy.takedamage && Teammate(self.oldenemy.real_owner, self.owner))
							TF_T_Damage(self.oldenemy, self.oldenemy, self.oldenemy, self.oldenemy.health + 20, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
				}
				else if (self.oldenemy.classname == "detpack") {
					//bprint(#PRINT_HIGH,"Blow the detpack!\n");
					// This code handles disarming a detpack
					if (self.oldenemy.weaponmode == 1)	// Detpack was being disarmed
					{
						self.oldenemy.enemy.tfstate = self.oldenemy.enemy.tfstate - (self.oldenemy.enemy.tfstate & #TFSTATE_CANT_MOVE);
						#ifdef QUAKE_WORLD
							TeamFortress_SetSpeed(self.oldenemy.enemy);
						#else
							self.oldenemy.enemy.pausetime = time;		
						#endif	
						dremove(self.oldenemy.oldenemy);	 // CountDown
						dremove(self.oldenemy.observer_list); //	Disarm timer
					}
					else { //Not being disarmed
						dremove(self.oldenemy.oldenemy);	 // CountDown
					}
					self.oldenemy.think = BecomeExplosion;
					self.oldenemy.nextthink = time + 0.1;
				}
				//else
				//	bprint(#PRINT_HIGH,"Psion: Unknown entity being carried.\n");
			}
		}


		if (self.owner) { //Clean up job flags and speed
			self.owner.job = self.owner.job - (self.owner.job & #JOB_ACTIVE);
			TeamFortress_SetSpeed(self.owner);
		}
		self.oldenemy = self.owner = world; //Clean up
		self.think = SUB_Remove; //Kill the timer
	}
	//No drop, so haul it around
	else {
		self.oldenemy.movetype = #MOVETYPE_FLY;

		makevectors(self.owner.v_angle);
		//WK 10/10/7 Correct for different centers of mass between the different builds
		target_loc = self.owner.origin + v_forward*60 + v_up*(self.oldenemy.maxs_z/2); //Goal is up ahead of us
		dist = vlen(target_loc - self.oldenemy.origin);
		owner_speed = vlen(self.owner.velocity); //WK 10/10/7 Have it match our speed
		target_vel = normalize (target_loc - self.oldenemy.origin); //Move it toward target location

		//WK 10/10/7 We used to move slower in short distances, but this made pushing into it too tedious a process
		// which caused doors to slam shut on us it took so long, blowing the fully upgrades tes and killing us.
		if (dist < self.owner.maxspeed && owner_speed < 20) {
			//Slow precision moving
			target_vel = target_vel * dist;
			self.oldenemy.velocity = target_vel;
		}
		else {
			//Running while hauling a building
			target_vel = target_vel * self.owner.maxspeed; //Match its speed to ours
			self.oldenemy.velocity = self.oldenemy.velocity * 0.90 + target_vel * 0.10; //Smooth velocity wobbling out			
		}

		if (self.oldenemy.classname == "building_sentrygun") { //Handle two-part sentries	
//.trigger_field is the base
//.oldenemy is the turret
			if (self.oldenemy.trigger_field) {
				//The top is always at base.origin + '0 0 8';
				self.oldenemy.trigger_field.velocity = self.oldenemy.velocity; //Parallel velocity

				//Try to repair connection if it gets broken
				dist = vlen(self.oldenemy.origin - self.oldenemy.trigger_field.origin);
				if (dist > 10) {
					if (pointcontents(self.oldenemy.origin - '0 0 8') == #CONTENT_EMPTY)
						setorigin(self.oldenemy.trigger_field,self.oldenemy.origin - '0 0 8');
				}
			}
		}
		//WK 10/10/7 TKII has been weak, and hauling dets doesn't work right since they tend to blow while moving them
		//	so now TK will place detpacks into statis while moving them
		if (self.oldenemy.classname == "detpack") {
			self.oldenemy.nextthink = self.oldenemy.nextthink + #HAULING_THINK_RATE; //No time progresses while carried
			self.oldenemy.oldenemy.nextthink = time + 1 + #HAULING_THINK_RATE; //No countdown
			self.oldenemy.effects = self.oldenemy.effects | #EF_PURPLE; //Make it glow in stasis
		}
	}
	self.nextthink = time + #HAULING_THINK_RATE; 
};

void() JobPsion =
{
	local entity head,haul_target,oself;
	local vector dir,dir2;
	local float radius,dist,dotproduct,grabbed,ever_grabbed;

	radius = 200; //Level 1 Psion has smallest range
	if (self.job & #JOB_EXTRA1) radius = 300; //Level 2 Psion increases range
	else if (self.job & #JOB_EXTRA2) radius = 400; //Level 3 Psion increases range
		
	deathmsg = #DMSG_PSION;
	ever_grabbed = 0; //We can only pick up one object. Set this when we have.

	//We burst and see what we get
	head = findradius(self.origin, radius);
	while (head) {
		dist = vlen(self.origin-head.origin);
		traceline (self.origin, head.origin, #TL_BSP_ONLY, self);
		if (trace_fraction == 1.0) { //Need full line of sight to target
			if (head.classname != "player" || (!Teammate(self, head) && head.takedamage && head.health > 0 && head.playerclass != #PC_UNDEFINED))
			{
				makevectors(self.v_angle);
				dir = normalize(v_forward);
				dir2 = normalize(head.origin - self.origin);
				dotproduct = dir * dir2;

				grabbed = 0; //Set this true if we pick up something so we don't push it away
				if (dotproduct > 0.90) { //10/10/7 We hit things in a 25 degree cone, but people in a 18 degree cone
					//Mind Blast
					if (head.classname == "player" && dotproduct > 0.95) { //Enemy player
						//Zot them!! 20,30,40 damage depending on job rank
						TF_T_Damage (head, self, self, radius/10, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY); 
						WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
						WriteByte (#MSG_BROADCAST, #TE_LIGHTNING2);
						WriteEntity (#MSG_BROADCAST, self);
						WriteCoord (#MSG_BROADCAST, self.origin_x);
						WriteCoord (#MSG_BROADCAST, self.origin_y);
						WriteCoord (#MSG_BROADCAST, self.absmax_z - 10); //From my head
						WriteCoord (#MSG_BROADCAST, head.origin_x);
						WriteCoord (#MSG_BROADCAST, head.origin_y);
						WriteCoord (#MSG_BROADCAST, head.absmax_z - 10); //Shoot their head
						#ifdef QUAKE_WORLD
							multicast (self.origin, #MULTICAST_PHS);
						#endif
						sound (self, #CHAN_WEAPON, "weapons/lhit.wav", 1, #ATTN_NORM);
						if (!(head.job & #JOB_PSION) && head.health > 0) { //Can't psionize a psion
							// create psionic timer
							newmis = spawn();
							newmis.classname = "timer";
							newmis.netname = "psionictimer";
							newmis.team_no = self.team_no;
							newmis.owner = head;
							newmis.think = PsionicTimer;
							newmis.nextthink = time + 0.75; //WK 10/10/7 Was 1,1.5,2s
							if (self.job & #JOB_EXTRA1) newmis.nextthink = time + 1; //Level 2
							else if (self.job & #JOB_EXTRA2) newmis.nextthink = time + 1.5; //Level 3
							head.tfstate = head.tfstate | #TFSTATE_PSIONIZED;
							head.button0 = 0;
							head.button1 = 0;
							head.button2 = 0;
							head.fire_held_down = #FALSE;
							head.heat = 0;
							oself = self;
							self = head;
							if (self.current_weapon == #WEAP_ASSAULT_CANNON && self.fire_held_down) 
							{
								stuffcmd(self, "-attack;v_idlescale 0\n");
								self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
								self.weaponframe = 0;
								self.count = 1;
								player_assaultcannondown1();						
							}
							else
								player_run();
							self = oself;
							sprint(head,#PRINT_HIGH,"Your body accepts a psionic discharge!\n");
							TeamFortress_SetSpeed(head);
						}


					}
					//Telekinesis works at half normal range
					else if (ever_grabbed == 0) { //Can only grab one thing
						haul_target = head;
						local float allowed;
						allowed = 0;
						if (!Teammate(head.real_owner, self)) allowed = 1; //Moving enemy builds ok
						if (infokey(head.real_owner,"psi") == "on") allowed = 1; //Moving allowed builds ok
						if (self == head.real_owner) allowed = 1; //We can always move our own builds

						if (head.classname == "detpack" && (self.job & (#JOB_EXTRA1 | #JOB_EXTRA2))) {
							sprint(self,#PRINT_HIGH,"Placing a detpack in statis...\n");
							grabbed = ever_grabbed = 1;
						}
						//.trigger_field is the sentry's base
						else if (head.classname == "building_sentrygun" && !(head.tf_items & #NIT_TURRET) && (self.job & #JOB_EXTRA2) && allowed) {
							//if (head.trigger_field)
							//	haul_target = head.trigger_field; //Grab it by the base instead
							sprint(self,#PRINT_HIGH,"Grabbed a sentry\n");
							grabbed = ever_grabbed = 1;
						}
						else if (head.classname == "building_sentrygun_base" && !(head.tf_items & #NIT_TURRET) && (self.job & #JOB_EXTRA2) && allowed) {
							sprint(self,#PRINT_HIGH,"Grabbed a sentry base\n");
							if (head.oldenemy)
								haul_target = head.oldenemy; //Switch target to the sentry's head.
							grabbed = ever_grabbed = 1;
						}
						else if (head.classname == "building_tesla" && !(head.tf_items & #NIT_TURRET) &&(self.job & #JOB_EXTRA2) && allowed) {
							sprint(self,#PRINT_HIGH,"Grabbed a tesla\n");
							grabbed = ever_grabbed = 1;
						}
						else if (head.classname == "building_dispenser" && (self.job & #JOB_EXTRA2) && allowed) {
							sprint(self,#PRINT_HIGH,"Grabbed a dispenser\n");
							grabbed = ever_grabbed = 1;
						}
						//Ok, if we're grabbing it, let's do it
						if (grabbed) {
							self.job = self.job | #JOB_ACTIVE; //Indicate we're hauling
							TeamFortress_SetSpeed(self);

							//Create hauling timer
							newmis = spawn();
							newmis.classname = "timer";
							newmis.netname = "haulingtimer";
							newmis.team_no = self.team_no;
							newmis.owner = self; //We're the hauler
							newmis.oldenemy = haul_target; //It's the haulee
							newmis.think = HaulingTimer;
							newmis.nextthink = time + 0.01;
						}
					}
				} //End dotproduct > 0.95
				//Burst airfist effect
				if (self.job & (#JOB_EXTRA1 | #JOB_EXTRA2)) {
					if (grabbed != 1 && canairpush(head)) {
						//Take em off the ground and fling them away
						head.flags = head.flags - (head.flags & #FL_ONGROUND);
						if (head.classname == "rocket" || head.classname == "grenade" || head.classname == "spike")
						{
							//Reflect moving shots coming at us
							dotproduct = head.velocity * (self.origin - head.origin);
							if (dotproduct > 0.5 && vlen(head.velocity) > 200) {
								head.velocity = head.velocity * -1; //Reflect
							} else {
								head.velocity = dir2 * 600; //Else just knock em away
								if (head.velocity_z < 200) head.velocity_z = 200;
							}

							//Reown it to get credit for the kill
							head.owner = self;

							//WK 10/10/7 Fix to let heat seeking rockets get reflected
							if (head.classname == "rocket") {
								head.nextthink = time + 5;
								head.think = SUB_Remove;
							}
						} else
						{
							head.velocity = dir2 * 600;
							if (head.velocity_z < 250) head.velocity_z = 250;
						}		
					}
				}
			}
		}
		head = head.chain;
	}
	//Special effects
	if (self.job & (#JOB_EXTRA1 | #JOB_EXTRA2)) {
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
		WriteCoord (#MSG_BROADCAST, self.origin_x);
		WriteCoord (#MSG_BROADCAST, self.origin_y);
		WriteCoord (#MSG_BROADCAST, self.absmax_z); //Explosion comes out of the head
		#ifdef QUAKE_WORLD
			multicast (self.origin, #MULTICAST_PHS);
		#endif
	}
	self.job_finished = time + 10;
};

void() UseJobSkill =
{
	local float myjob;
	//local string sx,sy,sz;

	//Make sure they can do it
	if (self.done_custom & #CUSTOM_BUILDING) return;

	// OfN - Psionized guys can't use skill
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self,#PRINT_HIGH,"You hardly can do anything psionized!\n");
		self.job_finished = time + 1;
		return;
	}


	//We can drop things as a psion before our job_finished is up
	if (self.job & #JOB_PSION && self.job & #JOB_ACTIVE) {
		self.job = self.job - (self.job & #JOB_ACTIVE);
		if (self.job_finished < time) self.job_finished = time + 1; //Don't double trigger
		return;
	}

	if (self.job_finished > time) return;

	myjob = self.job;
	if (myjob & #JOB_THIEF)
		JobThief();
	else if (myjob & #JOB_RUNNER)
		JobRunner();
	else if (myjob & #JOB_WARLOCK)
	{
		if (HasFlag(self.team_no) == #FALSE)
		{
			CenterPrint(self, "No demons until your team has the flag!\n");
			return; 	
		}
		JobWarlock();
	}
	else if (myjob & #JOB_CHAPLAN)
		JobChaplan();
	else if (myjob & #JOB_BERSERKER)
		JobBerserker();
	else if (myjob & #JOB_GUERILLA)
		JobGuerilla();
	else if (myjob & #JOB_JUDOKA)
		JobJudoka();
	else if (myjob & #JOB_HACKER)
		JobHacker();
	else if (myjob & #JOB_MARTYR)
		JobMartyr();
	else if (myjob & #JOB_ARMY)
		JobArmy();
	else if (myjob & #JOB_CRUSADER)
		JobCrusader();
	else if (myjob & #JOB_TKD)
		JobTKD();
	else if (myjob & #JOB_PSION)
		JobPsion();
	else {
		sprint(self,#PRINT_HIGH,"You don't have a job. Go get employed.\n");
		self.job_finished = time + 5; //Don't let them print this message that often
	}
};

#define NOHIDE_TIME 6
#define EXPOSURE_NOHIDE_TIME 10
#define EXPOSURE_NORELOAD_TIME 3.5
#define FULLH_NORELOAD_TIME 1.5
void (entity targ, float pain) RevealThief =
{
	if (targ.classname != "player") return;
	targ.modelindex = modelindex_player;
	if (pain) {
		sprint(targ,#PRINT_HIGH,"You have been uncovered!\n");
		targ.attack_finished = time + #EXPOSURE_NORELOAD_TIME;
		targ.job_finished = time + #EXPOSURE_NOHIDE_TIME;
	}
	else {
		sprint(targ,#PRINT_HIGH,"Μεαφιξη σθαδοχσ...\n");
		targ.job_finished = time + #NOHIDE_TIME;
		if (targ.job & #JOB_FULL_HIDE)
			targ.attack_finished = time + #FULLH_NORELOAD_TIME;
	}
	targ.job = targ.job - (targ.job & #JOB_FULL_HIDE);
	targ.job = targ.job - (targ.job & #JOB_ACTIVE);
	//WK 10/10/7 Added in shadowstep support
	targ.items = targ.items - (targ.items & #IT_INVISIBILITY);
	if (targ.shadowstep_time > 0) targ.shadowstep_time = 0;
	targ.shadowstep_active = 0;
	TeamFortress_SetSpeed(targ);
};

//===============================================================================
// Initializes any needed job stuff

void() InitJobStuff =
{
	// Abort if already initialized
	if (self.goal_activation) return;

	// Initialize respective jobs
	if (self.job & #JOB_ARMY)
		ArmyInit(self);
	else if (self.job & #JOB_GUERILLA)
		GuerillaInit(self);
	else if (self.job & #JOB_THIEF) {
		self.shadowstep_time = 0;
		self.shadowstep_active = 0;
	}
	else
		return; // If nothing done just return
	
	// Set our "initialization done" flag to true
	self.goal_activation = #TRUE;
};

