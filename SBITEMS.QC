/* SB Items. New items for use with Custom TF 3.2 (or something) */

// Internal prototypes
void() AntiGravGrenadeExplode; // antigrav goes boom
void() AntiGravGrenadeTimer; // controls antigrav decay or whatever you call it
void(entity inflictor, entity attacker, float bounce, entity ignore) T_RadiusAntiGrav; // bang

void() MotionSensorIdle; // motion sensor sitting
float() MotionSensorFindTarget; // sensor scans for target
void() MotionSensorDie; // I wonder what this does
void() MotionSensorSpawn; // let's make a sensor
void() SensorBeAlarmed; // very alarming
void() TeamFortress_C4DetpackTouch;
void() ThrowC4Det;
//void() SBInitiateInterface;
float(entity hacked, float r) ReturnHackDelay;
void() SBHackDotTimerThink;
/*void() SwitchToCamera;
void() SwitchFromCamera;
void() CameraSwitchView;*/
// External functions

void() ConcussionGrenadeTouch;
void() Security_Camera_Pain;
float(float tno, entity ignore, string st) teamsprint;
void() TeamFortress_DetpackTouch;
void() TeamFortress_DetpackCountDown;
void() TeamFortress_DetpackExplode;
void() TeamFortress_DetpackDisarm;
void() SBFireInterface;

// -- OfN --
void(float tno, entity ignore) teamprefixsprint;


//--------------------------------------------------------------
/*
void() CameraSwitchView =
{
	if (!self.has_camera)
		return;

	if (self.is_cameraviewing)
		SwitchFromCamera();
	else
		SwitchToCamera();
};

void() SwitchToCamera =
{
	local entity camera;
	local float done;
	
	if (!self.has_camera)
		return;
	if (self.is_cameraviewing)
		return;
	
	camera = find(world, classname, "building_camera");
	if (camera.real_owner == self)
		done = #TRUE;
	while (!done)
	{
		camera = find(camera, classname, "building_camera");
		if (camera.real_owner == self)
			done = #TRUE;
		if (camera == world)
			done = #TRUE;
	}
	
	if (camera == world)
		return;
		
	msg_entity = self;
	WriteByte(#MSG_ONE, #SVC_SETVIEWPORT);
	WriteEntity(#MSG_ONE, camera);
	WriteByte(#MSG_ONE, #SVC_SETANGLES);
	WriteAngle(#MSG_ONE, camera.angles_x);
	WriteAngle(#MSG_ONE, camera.angles_y);
	WriteAngle(#MSG_ONE, camera.angles_z);
	self.fixangle = #TRUE;
	self.is_cameraviewing = #TRUE;
	self.t_s_h = self.weaponmodel;
	self.weaponmodel= "";
	self.view_ofs = '0 0 0';
	sprint(self, #PRINT_HIGH, "Camera view activated.\n");
};

void() SwitchFromCamera =
{
	if (!self.has_camera)
		return;
	if (!self.is_cameraviewing)
		return;
	msg_entity = self;
	WriteByte(#MSG_ONE, #SVC_SETVIEWPORT);
	WriteEntity(#MSG_ONE, self);
	WriteByte(#MSG_ONE, #SVC_SETANGLES);
	WriteAngle(#MSG_ONE, self.angles_x);
	WriteAngle(#MSG_ONE, self.angles_y);
	WriteAngle(#MSG_ONE, self.angles_z);
	self.fixangle = #FALSE;
	self.weaponmodel = self.t_s_h;
	self.view_ofs = '0 0 22';
	
	self.is_cameraviewing = #FALSE;
};
*/


// SB Tossable Detpack!
// A 10 second detpack that can be thrown around corners

void() PrimeC4Det =
{
	local entity te;
	
	if (!(self.cutf_items & #CUTF_TOSSABLEDET))
	{
		sprint (self, #PRINT_HIGH, "You do not have the C4 tossable detpack.\n");
		return;
	}
	if (self.ammo_c4det < 1)
	{
		sprint (self, #PRINT_HIGH, "Looks like you're out of C4.\n");
		return;
	}
	if (self.is_detpacking || self.is_toffingadet)
	{
		sprint (self, #PRINT_HIGH, "You can only set one detpack at once, throwable or otherwise!\n");
		return;
	}
	if (self.is_haxxxoring)
	{
		sprint (self, #PRINT_HIGH, "You can't set a detpack while hacking.\n");
		return;
	}	
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self,#PRINT_HIGH,"You can't prime C4's while psionized!\n");
		return;
	}

	te = spawn();
	te.owner = self;
	te.nextthink = time + #WEAP_DETPACK_SETTIME;
	te.think = ThrowC4Det;
	te.classname = "timer";
	te.netname = "C4detpack_timer";
	self.is_toffingadet = 1;
	self.tfstate = self.tfstate | #TFSTATE_C4THROW;
	TeamFortress_SetSpeed(self);
	sprint(self, #PRINT_HIGH, "Arming detpack...\n");
};

void() TeamFortress_C4DetpackTouch = 
{
	local entity disarm;

	if (other.classname != "player")
		return;

	//WK if (other.playerclass != #PC_SCOUT)
	if (!(other.tf_items & #NIT_SCANNER))
		return;
	
	if (self.weaponmode == 1)
		return;

	if (Teammate(self.owner, other))
		return;

	makeImmune(other,time + 2);
	//other.immune_to_check = time + 2;
	other.tfstate = other.tfstate | #TFSTATE_CANT_MOVE;

	sprint(other, #PRINT_HIGH, "Disarming detpack...\n");
#ifdef QUAKE_WORLD
	TeamFortress_SetSpeed(other);
#else
	other.pausetime = time + #WEAP_DETPACK_DISARMTIME;
#endif

	// Spawn disarming entity
	disarm = spawn();
	disarm.movetype = #MOVETYPE_NONE; //WK M3 Bug Hunt
	disarm.owner = other;		// the scout
	disarm.enemy = self;		// the detpack
	disarm.classname = "timer";
	disarm.nextthink = time + #WEAP_DETPACK_DISARMTIME;
	disarm.think = TeamFortress_DetpackDisarm;
	
	self.weaponmode = 1;  // indicates disarming
	self.enemy = other;   // points to scout
	self.observer_list = disarm;
};

void(entity ignore, string st, string st2, string st3, string st4, string st5, string st6) teamsprint6;

void() ThrowC4Det =
{
	local entity user;
	local entity oldself;
	
	self.owner.is_toffingadet = 0;

	self.owner.ammo_c4det = self.owner.ammo_c4det - 1;

	user = self.owner;

	sound (user, #CHAN_WEAPON, "weapons/grenade.wav", 1, #ATTN_NORM);
	KickPlayer(-1, user);
	
	newmis = spawn ();
	newmis.owner = user;
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_BBOX;
	newmis.solid = #SOLID_TRIGGER;
	newmis.classname = "detpack";

	// set grenade speed
	makevectors (user.v_angle);

	if (user.deadflag)
	{
		// if user is dead, throw grenade directly up
		newmis.velocity = '0 0 200';
	}
	else
	{
		if (user.v_angle_x)
		{
			newmis.velocity = v_forward*600 + v_up * 200 + random()*v_right*10 + random()*v_up*10;

			if (user.tfstate & #TFSTATE_PSIONIZED) // Weak toss when psionized
				newmis.velocity = newmis.velocity * 0.3;
		}
		else
		{
			newmis.velocity = aim(user, 10000);
			newmis.velocity = newmis.velocity * 600;
			newmis.velocity_z = 200;

			if (user.tfstate & #TFSTATE_PSIONIZED) // Weak toss when psionized
				newmis.velocity = newmis.velocity * 0.3;
		}
	}

	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = TeamFortress_C4DetpackTouch;
	newmis.think = TeamFortress_DetpackExplode;
	newmis.nextthink = time + 10;
	
	newmis.avelocity = '300 300 300';
	setmodel (newmis, "progs/detpack.mdl");

	setsize (newmis, '-16 -16 -8', '16 16 8');
	setorigin (newmis, user.origin);

	oldself = self;
	self = user;

	local entity countd;

	newmis.weaponmode = 0;	// Detpack weaponmode = 1 when disarming

	sound (newmis, #CHAN_WEAPON, "doors/medtry.wav", 1, #ATTN_NORM);  //CH play set detpack sound
	

	// Create the CountDown entity
	countd = spawn();
	newmis.linked_list = countd;	// attach count to its detpack
	countd.think = TeamFortress_DetpackCountDown;
	countd.health = 9;
	countd.nextthink = time + 1;
	countd.owner = newmis.owner;
	countd.movetype = #MOVETYPE_BOUNCE; 
	countd.classname = "countdown_timer"; // Don't call it timer, because we
							  // don't want it removed if player dies
	countd.enemy = newmis;
	newmis.oldenemy = countd;

	sprint(self, #PRINT_HIGH, "Detpack armed!\n");

	teamprefixsprint(self.team_no,self);
	teamsprint6(self,self.netname," throws a C4!\n","","","","");
	
	self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_C4THROW);
	TeamFortress_SetSpeed(self); // let's roll
};

// SB Motion Sensor
// Sits in shadows and lights up and makes noise when player goes near

void() SBBuildSensor =
{	 
	// Extra checks only required for cmnd "build" use
	if (self.health <= 0 || self.done_custom & #CUSTOM_BUILDING)
		return;    
	if (!(self.cutf_items & #CUTF_SENSOR))
	{
		sprint(self,#PRINT_HIGH,"You can not build a motion sensor!\n");
		return;
	} 

	// OfN - Psionized guys can't throw any sensors
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self,#PRINT_HIGH,"You can't deploy anything while psionized!\n");
		return;
	}		
	
	if (self.ammo_cells >= #BUILD_COST_SENSOR && self.has_sensor == 0)
	{
		self.ammo_cells = self.ammo_cells - #BUILD_COST_SENSOR;
		MotionSensorSpawn();
		self.has_sensor = 1;
		sprint(self, #PRINT_HIGH, "You place the motion sensor.\n");
		self.option = time + 2;
	}
	else if (self.ammo_cells < #BUILD_COST_SENSOR && self.has_sensor == 0)
		sprint(self, #PRINT_HIGH, "You do not have enough metal to build a motion sensor.\n");
	else
	{
		if (self.option < time) // avoids ppl overflowing by destroying/building it repeatedly
		{
			Find_And_Dmg("building_sensor", self, 1,0);
			sprint(self, #PRINT_HIGH, "You detonate your motion sensor.\n");
			self.has_sensor = 0;
		}
	}
};

void() MotionSensorTossTouch = 
{
	if (other != world || other == self.real_owner)
		return;
	if (pointcontents(self.origin) == #CONTENT_SKY || pointcontents(self.origin + '0 0 2') == #CONTENT_SKY || pointcontents(self.origin) == #CONTENT_SOLID)
	{
		MotionSensorDie();
		return;
	}
	//CH sees where landed and adjusts to proper things
	if (pointcontents(self.origin + '0 0 1') == #CONTENT_SOLID)
		self.origin = self.origin - '0 0 12';
	if (pointcontents(self.origin - '0 0 1') == #CONTENT_SOLID)
		self.origin = self.origin + '0 0 4';
	if (pointcontents(self.origin + '0 1 0') == #CONTENT_SOLID)
		self.origin = self.origin - '0 16 0';
	if (pointcontents(self.origin - '0 1 0') == #CONTENT_SOLID)
		self.origin = self.origin + '0 16 0';
	if (pointcontents(self.origin + '1 0 0') == #CONTENT_SOLID)
		self.origin = self.origin - '16 0 0';
	if (pointcontents(self.origin + '1 0 0') == #CONTENT_SOLID)
		self.origin = self.origin + '16 0 0';
	setorigin (self, self.origin);
	if (pointcontents(self.origin) == #CONTENT_SKY || pointcontents(self.origin + '0 0 2') == #CONTENT_SKY || pointcontents(self.origin) == #CONTENT_SOLID)
	{
		MotionSensorDie();
		return;
	}

	teamprefixsprint(self.real_owner.team_no,self.real_owner); //- OfN
	teamsprint(self.real_owner.team_no, self.real_owner, self.real_owner.netname);
	teamsprint(self.real_owner.team_no, self.real_owner, " has built a Motion Sensor.\n");

	self.movetype = #MOVETYPE_NONE;
	setsize (self, '-16 -16 -6', '16 16 10');
	self.solid = #SOLID_BBOX;
	self.takedamage = #DAMAGE_AIM;
	sound (self, #CHAN_WEAPON, "weapons/guerset.wav", 1, #ATTN_NORM);
	self.think = MotionSensorIdle;
	self.nextthink = time + 1;
};

void() MotionSensorIdle =
{
	if (MotionSensorFindTarget())
		self.nextthink = time + 2.4; //if found wait 2.5 sec before do another check
	else
		self.nextthink = time + 0.05; // lots per sec
	self.think = MotionSensorIdle;
};

float() MotionSensorFindTarget =
{
	local entity client;
	local float r, gotone, loopc;

	// Try a few checks to make it react faster
	r = 0;
	loopc = 0;
	gotone = #FALSE;
	
	if (self.is_malfunctioning & #SCREWUP_THREE)
		return #FALSE;
	
	local float trange; //- OfN - Hack
	trange=300; // was 250

	if (self.all_active & #IMPROVED_ONE)
		trange=500; // was 400

	//CH Theortetically this will check every client on the server now
	while (loopc < 32 && gotone == #FALSE)
	{
		client = checkclient();
		gotone = #TRUE;

		if (!client)
			gotone = #FALSE;
		else if (!Pharse_Client(client, self, 1, trange, 0, 1))
			gotone = #FALSE;
		if (client.job & #JOB_PSION) //WK 6/1/7 Psions immune to this
			gotone = #FALSE;

		loopc = loopc + 1;
		if (gotone) loopc = 1000;
	}

	if (!gotone)
	{
		self.effects = 0;
		self.skin=1;
		return #FALSE;
	}
	
	// Found a Target
	self.enemy = client;
	
	/*if (self.enemy.classname != "player") // OfN - wtf does this?
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return #FALSE;
		}
	}*/ // OfN - wtf does this?

	// SPIES, only returned by pharseclient if sensor is able to uncover them -changed
	//WK Odd, this will only uncover spies disguised as your team...
	if (UndercoverTeammate(self.enemy, self) && self.all_active & #IMPROVED_FOUR)
	{
		/*if (!(self.enemy.cutf_items & #CUTF_JAMMER)) // if they dont have a scanner jammer remove their disguise
		{*/
			Spy_RemoveDisguise(self.enemy);
			sprint(self.real_owner, #PRINT_HIGH, "Your motion sensor detects a spy!\n");
			sprint(self.enemy, #PRINT_HIGH, "That motion sensor knows you are a spy!\n");
		//}
		//else 
		//	  return #FALSE; // removed cause sensors alarm is activated anyway, even if they will not uncover them
	}

	// THIEVES, ALWAYS DETECTED BUT SENSOR ONLY UNCOVERS THEM IF HACKED TO DO- changed
	if (self.enemy.classname=="player")
	{
		if (self.enemy.job & #JOB_THIEF && (self.enemy.job & #JOB_ACTIVE || self.enemy.job & #JOB_FULL_HIDE))
		{
			if (self.all_active & #IMPROVED_SEVEN)
			{
				sprint(self.real_owner, #PRINT_HIGH, "Your motion sensor detects a thief!\n");
				sprint(self.enemy, #PRINT_HIGH, "That motion sensor detected you!\n");
				RevealThief(self.enemy,#TRUE);
			}
		}
	}
	
	if (!(self.is_malfunctioning & #SCREWUP_ONE))
		sound(self, #CHAN_WEAPON, "misc/enemy.wav", 1, #ATTN_NORM);
	
	if (!(self.is_malfunctioning & #SCREWUP_TWO))
	{	self.effects = #EF_BRIGHTLIGHT; self.skin=0;}


	sprint(self.real_owner,#PRINT_HIGH,"Ωους νοτιοξ σεξσος ςεποςτσ εξενω πςεσεξγε!\n");

	self.think = SensorBeAlarmed;
	return #TRUE;
};

void() SensorBeAlarmed =
{
	if (MotionSensorFindTarget())
	{
		if (!(self.is_malfunctioning & #SCREWUP_ONE))
			sound(self, #CHAN_WEAPON, "misc/enemy.wav", 1, #ATTN_NORM);

		self.nextthink = 2.4;
	}
	else
	{
		self.think = MotionSensorIdle;
		self.effects = 0;
		self.nextthink = 1;
		///
		self.skin=1;
	}
};

void() MotionSensorSpawn =
{
	self.has_sensor = #TRUE;
	newmis = spawn();
	newmis.movetype = #MOVETYPE_BOUNCE;
	setsize (newmis, '0 0 0', '0 0 0');
//	setsize (newmis, '-8 -8 -8', '8 8 8');
	newmis.solid = #SOLID_BBOX;
	newmis.takedamage = #DAMAGE_AIM;
	newmis.classname = "building_sensor";
	newmis.netname = "motion_sensor";
	newmis.flags = newmis.flags | #FL_MACHINE;
	setorigin (newmis, self.origin);
	newmis.owner = world;
	newmis.real_owner = self;
	makevectors (self.v_angle);
	newmis.avelocity = '0 0 0';
	newmis.velocity = v_forward*800 + v_up * 200 + v_right*10 + v_up*10;
	newmis.angles = '0 0 0';
	newmis.angles_y = anglemod(self.angles_y + 180);
//	newmis.skin = 1;
	newmis.th_die = MotionSensorDie;		// Death function
	newmis.th_pain = Security_Camera_Pain; // may as well use this eh
	//newmis.mdl = "progs/s_light.spr"; //CH temp model
	
	newmis.mdl = "progs/sencer.mdl";
	newmis.skin=1;

	setmodel (newmis, newmis.mdl);
	newmis.team_no = self.team_no;
	newmis.colormap = self.colormap;
	newmis.heat = 0; //Beeps

	newmis.health = newmis.max_health = #BUILD_HEALTH_SENSOR;
	newmis.touch = MotionSensorTossTouch;

	newmis.all_active=0; // OfN - reset HACKER improvements

	W_SetCurrentAmmo();
};

void() MotionSensorDie =
{
	sprint(self.real_owner, #PRINT_HIGH, "Your motion sensor was destroyed.\n");
	self.real_owner.has_sensor = #FALSE;

//	ThrowGib("progs/tgib1.mdl", -70);
//	ThrowGib("progs/tgib2.mdl", -70);
//	ThrowGib("progs/tgib3.mdl", -70);

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


// SB AntiGrav Grenade(tm)
// Screws over a player's gravity for a short time
//
// Uses the conc gren's touch function - why repeat it with an identical one?

void() AntiGravGrenadeExplode =
{	
	T_RadiusAntiGrav (self, self.owner, 100, world);

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

// Bounces the enemy a bit and screws over their gravity :)

void(entity inflictor, entity attacker, float bounce, entity ignore) T_RadiusAntiGrav =
{
	local	float	points;
	local	entity	head, te;
	local	vector	org;
	//local string	st;
	
	head = findradius(inflictor.origin, bounce+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage && head.health > 0)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (org - inflictor.origin);
				if (points < 0)
					points = 0;
				points = bounce - points;
				if (self.cutf_items & #CUTF_GYMNAST)
					points = points * 2;

				if (!IsBuilding(head) && points > 0)
				{
					// Bounce!!
					head.velocity = org - inflictor.origin;
					head.velocity = head.velocity * (points / 20);

					if (head.classname != "player")
					{
						if(head.flags & #FL_ONGROUND)
							head.flags = head.flags - #FL_ONGROUND;
					}
					else
					{
						//WK Add cheat immunity since they fly
						makeImmune(head,time+3);

						// Turn on antigrav
						// If it's already on, restore it to full time
						// Try to find a concusstimer entity for this player
						te = find(world, classname, "timer");
						while (((te.owner != head) || (te.think != AntiGravGrenadeTimer)) && (te != world))
							te = find(te, classname, "timer");
						if (te != world)
						{
							head.gravity = 0.3 * random();
							te.health = 100;
							te.nextthink = time + #GR_CONCUSS_TIME;
						}
						else
						{
							head.gravity = 0.3 * random();
							stuffcmd(head,"bf\n");
							// Create a timer entity
							te = spawn();
							te.nextthink = time + #GR_CONCUSS_TIME;
							te.think = AntiGravGrenadeTimer;
							te.team_no = attacker.team_no;
							te.classname = "timer";
							te.owner = head;
							te.health = 100;
						}
					}
				}
			}
		}
		head = head.chain;
	}
};

// Timer used to control antigrav effects

void() AntiGravGrenadeTimer =
{
	//local string st;

	if (self.owner.invincible_finished > time)
	{
		self.owner.gravity = 1;
		dremove(self);
		return;
	}

	self.health = self.health - #GR_CONCUSS_DEC * 2;
	
	// hwguy recovers twice as fast - heh heh
	if (self.owner.cutf_items & #CUTF_HWGUY)
		self.health = self.health - #GR_CONCUSS_DEC * 2;

	if (self.health < 0)
		self.health = 0;
	self.nextthink = time + #GR_CONCUSS_TIME;

	if (self.health <= 0)
	{
		self.owner.gravity = 1;
		sprint(self.owner, #PRINT_HIGH, "Your weight feels normal again.\n");
		dremove(self);
	}
};
