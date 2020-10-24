/*=============================
	Turrets

This file contains all information required
to handle turrets. Some changes may have
to be made in ClientObituary().
=============================*/

float TURRET_INSTANT_FIRE	= 1;
float TURRET_EXPLOSIVE_FIRE = 2;

void() turret_scanthink;
void() turret_attackthink;
void() turret_fire;
void() turret_projectiletouch;


void() turret_normal =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_NONE;

	precache_sound("enforcer/enfire.wav");

	// set the defaults
	if (!(self.model))
		self.model = "progs/v_rock2.mdl";

	if (!(self.health))
		self.health = -1;

	if (!(self.search_time))
		self.search_time = 5;

	if (!(self.speed))
		self.speed = 0.2;

	if (!(self.dmg))
		self.dmg = 5;

	self.weaponmodel = "progs/laser.mdl";

	// if no weapon model, it must be instantaneous fire
	if (!(self.weaponmodel))
		self.spawnflags = self.spawnflags | TURRET_INSTANT_FIRE;

	if (!(self.ammo_shells))
		self.ammo_shells = -1;

	if (!(self.currentammo))
		self.currentammo = self.ammo_shells;

	if (!(self.wait))
		self.wait = -1;

	if (!(self.lives))
		self.lives = -1;

	if (!(self.team_no))
		self.team_no = -1;

	if (!(self.numflames))
		self.numflames = 1;

	// projectile speed
	if (!(self.aflag))
		self.aflag = 1200;

	// this is the radius damage done	
	if (self.all_active)
		self.spawnflags = self.spawnflags | TURRET_EXPLOSIVE_FIRE;

	setmodel(self, self.model);
	setorigin(self, self.origin);
	self.nextthink = time + 5;	// don't come online for 5 seconds
	self.think = turret_scanthink;
};

// scans for enemies
// don't do it too often
void() turret_scanthink =
{
	local entity search;

	bprint("t: scanning..\n");
	
	search = checkclient();

	if (visible(search) && search.health > 1)
	{
		// locked onto target
		self.enemy = search;
		self.think = turret_attackthink;
		self.nextthink = 0.1;
		return;
	}

	self.nextthink = time + self.search_time;
};

// attacks the same enemy repeatedly
void() turret_attackthink =
{
	if (visible(self.enemy) && self.enemy.health > 1)
	{
		bprint("t: attacking..\n");
		turret_fire();
		// set angle to face the enemy
	}
	else
	{
		self.think = turret_scanthink;
	}

	self.nextthink = time + self.speed;
};

// fires the turret
void() turret_fire =
{

/*	if (self.spawnflags & TURRET_INSTANT_FIRE)
	{
		// fire instant weapon
	}
	else
*///	{
		newmis = spawn();
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);
		
		setorigin(newmis, self.origin + dir * 48);
		setmodel(newmis, self.weaponmodel);

		newmis.movetype = MOVETYPE_FLY;
		newmis.solid = SOLID_BBOX;
		newmis.effects = EF_DIMLIGHT;
		newmis.velocity =  normalize(self.enemy.origin - self.origin) * self.aflag;
		newmis.dmg = self.dmg;
		newmis.angles = vectoangles(newmis.velocity);
		newmis.touch = turret_projectiletouch;
		newmis.owner = self;
		newmis.think = SUB_Remove;
		newmis.nextthink = time + 5; // remove projectile after 5 seconds
//	}
};

void() turret_projectiletouch =
{
	if (other.takedamage)
	{
		T_Damage(other, self, self.owner, self.dmg);
	}

	remove(self);
};
