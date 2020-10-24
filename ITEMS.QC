void() W_SetCurrentAmmo;
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */

// TeamFortress Prototypes
float(entity Retriever, float AmmoType) TeamFortress_GetMaxAmmo;
float(entity Retriever, float WeaponType) TeamFortress_CanGetWeapon;
float(entity Retriever, entity Items) TeamFortress_AddBackpackItems;
void(entity p) TeamFortress_SetSpeed;

// TeamFortress Goal Prototypes
void() tfgoal_touch;

//- OfN
void(entity sld, entity player, string msg, float priority) PrintFromSoldier;
void(entity sld) grunty_boundammo;
void(entity player) HealLegs;

void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = #SOLID_TRIGGER;	// allow it to be touched again
	sound (self, #CHAN_VOICE, "items/itembk2.wav", 1, #ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};



/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	RPrint ("noclass spawned at");
	RPrint (vtos(self.origin));
	RPrint ("\n");
	remove (self);
};

/*
============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
	local float oldz;

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = #FL_ITEM;		// make extra wide
	self.solid = #SOLID_TRIGGER;
	self.movetype = #MOVETYPE_TOSS; 
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;
	if (!droptofloor())
	{
		RPrint ("Bonus item fell out of level at ");
		RPrint (vtos(self.origin));
		RPrint ("\n");
		dremove(self);
		return;
	}
};

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
	if (e.health <= 0)
		return 0;
	if ((!ignore) && (e.health >= e.max_health))
		return 0;
	healamount = ceil(healamount);

	e.health = e.health + healamount;
	if ((!ignore) && (e.health >= e.max_health))
		e.health = e.max_health;
		
	if (e.health > e.max_health + 150) //WK 250
		e.health = e.max_health + 150; //WK 250

	if (e.leg_damage)
	{
		HealLegs(e);
			//e.leg_damage = 0;
		//TeamFortress_SetSpeed(e);
	}

	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

#define H_ROTTEN	1 
#define H_MEGA	2 
.float	healamount, healtype;
void() health_touch;
void() item_megahealth_rot;

void() item_health =
{	
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = health_touch;

	if (self.spawnflags & #H_ROTTEN)
	{
		precache_model("maps/b_bh10.bsp");

		precache_sound("items/r_item1.wav");
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}
	else
	if (self.spawnflags & #H_MEGA)
	{
		precache_model("maps/b_bh100.bsp");
		precache_sound("items/r_item2.wav");
		setmodel(self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}
	else
	{
		precache_model("maps/b_bh25.bsp");
		precache_sound("items/health1.wav");
		setmodel(self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


void() health_touch =
{
	local	float medi; //amount,
	local	string	s;
	
	if (other.classname != "player")
		return;

	if (other.is_feigning)
		return;
	if (prematch >= time)
		return;
	if (other.tfstate & #TFSTATE_CANT_MOVE)
		return;
	
	//- OfN team_no is now used for items!
	if (self.team_no>0)
	{
		if (!Teammate(other, self))
			return;
	}
	//-----------------------------------//

	medi = 0;
	
	if (self.healtype == 2) // Megahealth?	Ignore max_health...
	{
		// only heal the player if they are not infected
		if (!(other.tfstate & #TFSTATE_INFECTED))
		{
			if (other.health >= other.max_health + 150) //WK 250
				return;
			if (!T_Heal(other, self.healamount, 1))
				return;
		}
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0))
		{
			if (other.weapons_carried & #WEAP_MEDIKIT)
			{
				if (other.ammo_medikit < other.maxammo_medikit)
				{
					other.ammo_medikit = other.ammo_medikit + self.healamount;
					if (other.ammo_medikit > other.maxammo_medikit)
						other.ammo_medikit = other.maxammo_medikit;

					s = ftos(self.healamount);
				
					sprint(other, #PRINT_LOW, "You gather ");
					sprint(other, #PRINT_LOW, s);
					sprint(other, #PRINT_LOW, " medikit ammo\n");
					
					// health touch sound
					sound(other, #CHAN_ITEM, self.noise, 1, #ATTN_NORM);

					stuffcmd (other, "bf\n");
					
					self.model = string_null;
					self.solid = #SOLID_NOT;

					if (deathmatch != 2)		// deathmatch 2 is the silly old rules
					{
						if (deathmatch)
							self.nextthink = time + 20;
						self.think = SUB_regen;
					}

					activator = other;
					SUB_UseTargets();				// fire all targets / killtargets
				}
			}
			return;
		}
	}

	if ((other.tfstate & #TFSTATE_INFECTED) && (self.healamount > 80))
	{
		sprint(other, #PRINT_MEDIUM, "You have been healed of your infection!");

		other.tfstate = other.tfstate - (other.tfstate & #TFSTATE_INFECTED);
	}
	else
	{
		s = ftos(self.healamount);
		
		sprint(other, #PRINT_LOW, "You receive ");
		sprint(other, #PRINT_LOW, s);
		sprint(other, #PRINT_LOW, " health\n");
	}
	
// health touch sound
	sound(other, #CHAN_ITEM, self.noise, 1, #ATTN_NORM);

	stuffcmd (other, "bf\n");
	
	self.model = string_null;
	self.solid = #SOLID_NOT;

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
		other.items = other.items | #IT_SUPERHEALTH;
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		self.owner = other;
	}
	else
	{
		if (deathmatch != 2)		// deathmatch 2 is the silly old rules
		{
			if (deathmatch)
				self.nextthink = time + 20;
			self.think = SUB_regen;
		}
	}
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};	

void() item_megahealth_rot =
{
	other = self.owner;
	
	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;
		return;
	}

	// it is possible for a player to die and respawn between rots, so don't
	// just blindly subtract the flag off
	other.items = other.items - (other.items & #IT_SUPERHEALTH);
	
	if (self.classname == "medikit_rot")
	{
		dremove(self);
		return;
	}

	if (deathmatch != 2)	// deathmatch 2 is silly old rules
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
};

/*
===============================================================================

ARMOR

===============================================================================
*/

void() armor_touch =
{
	local float type, value, bit;
	local string s;
	local entity oldself;
	
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;
	if (prematch >= time)
		return;
	
	if (other.is_feigning)
		return;
	if (other.tfstate & #TFSTATE_CANT_MOVE)
		return;

	//- OfN team_no is now used for items!
	if (self.team_no>0)
	{
		if (!Teammate(other,self))
			return;
	}
	//-----------------------------------//

	if (self.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
		bit = #IT_ARMOR1;
	}
	else if (self.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
		bit = #IT_ARMOR2;
	}
	else if (self.classname == "item_armorInv")
	{
		type = 0.8;
		value = 300; //CH was 200, 300 allows for high armor
		bit = #IT_ARMOR3;
	}

	if (other.armortype * other.armorvalue >= type*value)
	{
		// Engineers can still grab the metal
		//WK - My 'Engineers' can too
		if (other.weapons_carried & #WEAP_SPANNER || other.tf_items & #NIT_TESLA || other.cutf_items & #CUTF_SENTRYGUN)
		{
			if (other.ammo_cells >= other.maxammo_cells)
				return;
		}
		else
		{
			return;
		}
	}

	if (other.armor_allowed * other.maxarmor <= type*value)
	{
		if (other.armor_allowed == other.armortype) 
		{
			if (other.maxarmor == other.armorvalue)
			{
				if (other.weapons_carried & #WEAP_SPANNER || other.tf_items & #NIT_TESLA || other.cutf_items & #CUTF_SENTRYGUN)
				{
					if (other.ammo_cells >= other.maxammo_cells)
						return;
				}
				else
				{
					return;
				}
			}
		}
	}

	// reduce armor to fit player
	if (type > other.armor_allowed)
	{
		type = other.armor_allowed;

		// recalculate bit
		if (type == 0.3)
			bit = #IT_ARMOR1;
		else if (type == 0.6)
			bit = #IT_ARMOR2;
		else if (type == 0.8)
			bit = #IT_ARMOR3;
	}

	sprint(other, #PRINT_LOW, "You got armor\n");

	// ENGINEER can use extra armor for metal
	// WK, this used to be within the if block below
	if ((other.weapons_carried & #WEAP_SPANNER || other.tf_items & #NIT_TESLA || other.cutf_items & #CUTF_SENTRYGUN) && other.ammo_cells < other.maxammo_cells)
	{
		//WK Used to be other.maxarmor. This makes it possible to build with large armorvalues
		s = ftos(value - 50); 

		sprint (other, #PRINT_LOW, s);
		sprint (other, #PRINT_LOW, " metal\n");

		other.ammo_cells = other.ammo_cells + (value - 50); //WK other.maxarmor
		if (other.ammo_cells > other.maxammo_cells)
			other.ammo_cells = other.maxammo_cells;

		oldself = self;
		self = other;
		W_SetCurrentAmmo();
		self = oldself;
	}

	if (value > other.maxarmor)
	{
		//WK, block above used to be here
		value = other.maxarmor;
	}
	  
	if (other.armortype * other.armorvalue < type*value)
	{
		other.armortype = type;
		other.armorvalue = value;

		other.items = other.items - (other.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3)) + bit;
	}

	self.solid = #SOLID_NOT;
	self.model = string_null;
	if (deathmatch != 2)
		self.nextthink = time + 20;
	if (coop)
		self.nextthink = time + 40;

	self.think = SUB_regen;

	// armor touch sound
	sound(other, #CHAN_ITEM, "items/armor1.wav", 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor1 =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 0;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor2 =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 1;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armorInv =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 2;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void(entity p) bound_other_ammo =
{
	if (p.ammo_shells > TeamFortress_GetMaxAmmo(p,#IT_SHELLS))
		p.ammo_shells = TeamFortress_GetMaxAmmo(p,#IT_SHELLS);
	if (p.ammo_nails > TeamFortress_GetMaxAmmo(p,#IT_NAILS))
		p.ammo_nails = TeamFortress_GetMaxAmmo(p,#IT_NAILS);
	if (p.ammo_rockets > TeamFortress_GetMaxAmmo(p,#IT_ROCKETS))
		p.ammo_rockets = TeamFortress_GetMaxAmmo(p,#IT_ROCKETS);		
	if (p.ammo_cells > TeamFortress_GetMaxAmmo(p,#IT_CELLS))
		p.ammo_cells = TeamFortress_GetMaxAmmo(p,#IT_CELLS);		
	if (p.ammo_medikit > p.maxammo_medikit)
		p.ammo_medikit = p.maxammo_medikit;
	if (p.armorvalue > p.maxarmor)
		p.armorvalue = p.maxarmor;	
	
	if (p.no_grenades_1 > GetMaxGrens(p,1))
		p.no_grenades_1 = GetMaxGrens(p,1);
	if (p.no_grenades_2 > GetMaxGrens(p,2))
		p.no_grenades_2 = GetMaxGrens(p,2);
	
	/*if (p.tf_items & #NIT_AMMO_BANDOLIER) {
		if (p.no_grenades_1 > 5)
			p.no_grenades_1 = 5;
		if (p.tp_grenades_1 == #GR_TYPE_NAIL && p.no_grenades_1 > 3)
			p.no_grenades_1 = 3;
		if (p.no_grenades_2 > 5)
			p.no_grenades_2 = 5;
		if (p.tp_grenades_2 == #GR_TYPE_NAIL && p.no_grenades_2 > 3)
			p.no_grenades_2 = 3;
	}
	else {
		if (p.no_grenades_1 > 4)
			p.no_grenades_1 = 4;
		if (p.tp_grenades_1 == #GR_TYPE_NAIL && p.no_grenades_1 > 2)
			p.no_grenades_1 = 2;
		if (p.no_grenades_2 > 4)
			p.no_grenades_2 = 4;
		if (p.tp_grenades_2 == #GR_TYPE_NAIL && p.no_grenades_2 > 2)
			p.no_grenades_2 = 2;
	}*/
};

/* OfN UNUSED
float(float w) RankForWeapon =
{
	if (w == #WEAP_LIGHTNING)
		return 1;
	if (w == #WEAP_ROCKET_LAUNCHER)
		return 2;
	if (w == #WEAP_LIGHT_ASSAULT)
		return 3;
	if (w == #WEAP_GRENADE_LAUNCHER)
		return 4;
	if (w == #WEAP_SUPER_SHOTGUN)
		return 5;
	if (w == #WEAP_NAILGUN)
		return 6;
	return 7;
};*/

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
void(float old, float new) Deathmatch_Weapon =
{
// commented out so that weapons _don't_ change

/*
	local float or, nr;


// change self.weapon if desired
	or = RankForWeapon (self.weapon);
	nr = RankForWeapon (new);
	if ( nr < or )
		self.weapon = new;
*/ 

};

void() ammo_touch;
// Set a weapon/ammo entity up for respawn
void(entity ritem, entity act) Respawn_Item =
{
	local entity oldself;
	
	oldself = self;
	self = ritem;

	// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = #SOLID_NOT;
	if (deathmatch != 2)
		self.nextthink = time + 30;
	else if (coop && ritem.touch == ammo_touch)
		self.nextthink = time + 45;

	self.think = SUB_regen;

	activator = act;
	SUB_UseTargets();				// fire all targets / killtargets

	self = oldself;
};

/*
=============
weapon_touch
=============
*/
float() W_BestWeapon;

void() weapon_touch =
{
	local	float	hadammo, best, new, old;
	local	entity	stemp;
	local	float	leave;

	if (!(other.flags & #FL_CLIENT))
		return;

	if (other.is_feigning)
		return;

	if (other.tfstate & #TFSTATE_CANT_MOVE)
		return;
		
	if (prematch >= time)
		return;

	// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	if (deathmatch == 2 || coop)
		leave = 1;
	else
		leave = 0;
	
	if (self.classname == "weapon_nailgun")
	{
		if (leave && (other.weapons_carried & #WEAP_NAILGUN) )
			return;
		if (!TeamFortress_CanGetWeapon(other,#WEAP_NAILGUN))
			return;
		hadammo = other.ammo_nails; 		
		new = #WEAP_NAILGUN;
		other.ammo_nails = other.ammo_nails + 30;
	}
	else if (self.classname == "weapon_supernailgun")
	{
		if (leave && (other.weapons_carried & #WEAP_LIGHT_ASSAULT) )
			return;
		if (!TeamFortress_CanGetWeapon(other,#WEAP_LIGHT_ASSAULT))
			return;
		hadammo = other.ammo_rockets;			
		new = #WEAP_LIGHT_ASSAULT;
		other.ammo_nails = other.ammo_nails + 90;
	}
	else if (self.classname == "weapon_supershotgun")
	{
		if (leave && (other.weapons_carried & #WEAP_SUPER_SHOTGUN) )
			return;
		if (!TeamFortress_CanGetWeapon(other,#WEAP_SUPER_SHOTGUN))
			return;
		hadammo = other.ammo_rockets;
		new = #WEAP_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + 5;
	}
	else if (self.classname == "weapon_rocketlauncher")
	{
		if (leave && (other.weapons_carried & #WEAP_ROCKET_LAUNCHER) )
			return;
		if (!TeamFortress_CanGetWeapon(other,#WEAP_ROCKET_LAUNCHER))
			return;
		hadammo = other.ammo_rockets;			
		new = #WEAP_ROCKET_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 5;
	}
	else if (self.classname == "weapon_grenadelauncher")
	{
		if (leave && (other.weapons_carried & #WEAP_GRENADE_LAUNCHER) )
			return;
		if (!TeamFortress_CanGetWeapon(other,#WEAP_GRENADE_LAUNCHER))
			return;
		hadammo = other.ammo_rockets;			
		new = #WEAP_GRENADE_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 5;
	}
	else if (self.classname == "weapon_lightning")
	{
		if (leave && (other.weapons_carried & #WEAP_LIGHTNING) )
			return;
		if (!TeamFortress_CanGetWeapon(other,#WEAP_LIGHTNING))
			return;
		hadammo = other.ammo_rockets;			
		new = #WEAP_LIGHTNING;
		other.ammo_cells = other.ammo_cells + 15;
	}
	else
		objerror ("weapon_touch: unknown classname");

	sprint (other, #PRINT_LOW, "You got the ");
	sprint (other, #PRINT_LOW, self.netname);
	sprint (other, #PRINT_LOW, "\n");

// weapon touch sound
	sound (other, #CHAN_ITEM, "weapons/pkup.wav", 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");

	bound_other_ammo (other);

// change to the weapon
	old = other.weapons_carried;
	other.weapons_carried = other.weapons_carried | new;
	
	stemp = self;
	self = other;

	Deathmatch_Weapon (old, new);

	W_SetCurrentAmmo();

	self = stemp;

	if (leave)
		return;

	// respawn
	Respawn_Item(self, other);
};


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supershotgun =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	precache_model ("progs/g_shot.mdl");
	setmodel (self, "progs/g_shot.mdl");
	self.weapon = #WEAP_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	precache_model ("progs/g_nail.mdl");
	setmodel (self, "progs/g_nail.mdl");
	self.weapon = #WEAP_NAILGUN;
	self.netname = "nailgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supernailgun =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	precache_model ("progs/g_nail2.mdl");
	setmodel (self, "progs/g_nail2.mdl");
	self.weapon = #WEAP_LIGHT_ASSAULT;
	self.netname = "Super Nailgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_grenadelauncher =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	precache_model ("progs/g_rock.mdl");
	setmodel (self, "progs/g_rock.mdl");
	self.weapon = 3;
	self.netname = "Grenade Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_rocketlauncher =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	precache_model ("progs/g_rock2.mdl");
	setmodel (self, "progs/g_rock2.mdl");
	self.weapon = 3;
	self.netname = "Rocket Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*
	QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_lightning =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	precache_model ("progs/g_light.mdl");
	setmodel (self, "progs/g_light.mdl");
	self.weapon = 3;
	self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*
===============================================================================

AMMO

===============================================================================
*/
void(entity pl, float typ) PrintGrenadeType =
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
	else st = "(BUG)";
	

	sprint(pl, #PRINT_HIGH, st);
};

float() GetGrenadePossibility =
{
	// there is only a chance of getting a grenade
	if (random() < 0.5)
		return #FALSE;

	// determine grenade type to get
	// FIXME: need maximum number of grenades for each player
	// current default is 4
	if (random() < 0.5) 	// get normal grenade (type 1)
	{
		if (GetMaxGrens(other,1) > floor(other.no_grenades_1)) //- OfN FIXME: use floor()?
		{			
			other.no_grenades_1 = other.no_grenades_1 + 1;

			sprint(other, #PRINT_HIGH, "You found a ");
			PrintGrenadeType(other, other.tp_grenades_1);
			sprint(other, #PRINT_HIGH, " grenade\n");

			return #TRUE;
		}
		
		/*if ((other.tp_grenades_1 != 0) && (other.no_grenades_1 < 5))
		{
			//WK Bandolier gives an extra grenade
			if (other.no_grenades_1 < 4 || other.tf_items & #NIT_AMMO_BANDOLIER)
			if (!(other.tp_grenades_1 == #GR_TYPE_NAIL && other.no_grenades_1 >= 2)) {
				other.no_grenades_1 = other.no_grenades_1 + 1;

				sprint(other, #PRINT_HIGH, "You found a ");
				PrintGrenadeType(other, other.tp_grenades_1);
				sprint(other, #PRINT_HIGH, " grenade\n");

				return #TRUE;
			}
		}*/
	}
	else	// get special grenade (type 2)
	{
		if (GetMaxGrens(other,2) > floor(other.no_grenades_2)) //- OfN FIXME: use floor()?
		{			
			other.no_grenades_2 = other.no_grenades_2 + 1;

			sprint(other, #PRINT_HIGH, "You found a ");
			PrintGrenadeType(other, other.tp_grenades_2);
			sprint(other, #PRINT_HIGH, " grenade\n");
			return #TRUE;
		}
		/*if ((other.tp_grenades_2 != 0) && (other.no_grenades_2 < 5))
		{
			if (other.no_grenades_2 < 4 || other.tf_items & #NIT_AMMO_BANDOLIER)
			if (!(other.tp_grenades_2 == #GR_TYPE_NAIL && other.no_grenades_2 >= 2)) {
				other.no_grenades_2 = other.no_grenades_2 + 1;

				sprint(other, #PRINT_HIGH, "You found a ");
				PrintGrenadeType(other, other.tp_grenades_2);
				sprint(other, #PRINT_HIGH, " grenade\n");
				return #TRUE;
			}
		}*/
	}

	return #FALSE;
};

void() ammo_touch =
{
	local entity	stemp;
	local float 	best;
	local float 	gotgren;
	local float 	gotbox;

	gotgren = #FALSE;
	gotbox = #FALSE;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (prematch >= time)
		return;

	if (other.is_feigning)
		return;
	if (other.tfstate & #TFSTATE_CANT_MOVE)
		return;

	//- OfN team_no is now used for items!
	if (self.team_no>0)
	{
		if (!Teammate(other, self))
			return;
	}
	//-----------------------------------//

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;


// shotgun
	if (self.weapon == 1)
	{
		if (other.ammo_shells >= TeamFortress_GetMaxAmmo(other,#IT_SHELLS))
			return;
		other.ammo_shells = other.ammo_shells + self.aflag;
		gotbox = #TRUE;
	}

// spikes
	if (self.weapon == 2)
	{
		if (other.ammo_nails >= TeamFortress_GetMaxAmmo(other, #IT_NAILS))
			return;
		other.ammo_nails = other.ammo_nails + self.aflag;
		gotbox = #TRUE;
	}

//	rockets
	else if (self.weapon == 3)
	{
		gotgren = GetGrenadePossibility();

		if (other.ammo_rockets >= TeamFortress_GetMaxAmmo(other, #IT_ROCKETS ))
		{
			gotbox = #FALSE;
		}
		else
		{
			gotbox = #TRUE;
			other.ammo_rockets = other.ammo_rockets + self.aflag;
		}
	}

//	cells
	else if (self.weapon == 4)
	{
		if (other.ammo_cells >= TeamFortress_GetMaxAmmo(other,#IT_CELLS))
			return;
		other.ammo_cells = other.ammo_cells + self.aflag;
		gotbox = #TRUE;
	}

	if (!gotbox && !gotgren)
		return;
	
	sound (other, #CHAN_ITEM, "weapons/lock4.wav", 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");

	if (gotbox)
	{
		bound_other_ammo (other);
		
		sprint (other, #PRINT_LOW, "You got the ");
		sprint (other, #PRINT_LOW, self.netname);
		sprint (other, #PRINT_LOW, "\n");
	// ammo touch sound

	// change to a better weapon if appropriate
/*
		if ( other.weapon == best )
		{
			stemp = self;
			self = other;
			self.weapon = W_BestWeapon();
			W_SetCurrentAmmo ();
			self = stemp;
		}
*/
	// if changed current ammo, update it
		stemp = self;
		self = other;
		W_SetCurrentAmmo();
		self = stemp;

	}

	Respawn_Item(self, other);
};




#define WEAPON_BIG2 1 

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_shells =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = ammo_touch;

	if (self.spawnflags & #WEAPON_BIG2)
	{
		precache_model ("maps/b_shell1.bsp");
		setmodel (self, "maps/b_shell1.bsp");
		self.aflag = 40;
	}
	else
	{
		precache_model ("maps/b_shell0.bsp");
		setmodel (self, "maps/b_shell0.bsp");
		self.aflag = 20;
	}
	self.weapon = 1;
	self.netname = "shells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_spikes =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = ammo_touch;

	if (self.spawnflags & #WEAPON_BIG2)
	{
		precache_model ("maps/b_nail1.bsp");
		setmodel (self, "maps/b_nail1.bsp");
		self.aflag = 50;
	}
	else
	{
		precache_model ("maps/b_nail0.bsp");
		setmodel (self, "maps/b_nail0.bsp");
		self.aflag = 25;
	}
	self.weapon = 2;
	self.netname = "nails";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_rockets =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = ammo_touch;

	if (self.spawnflags & #WEAPON_BIG2)
	{
		precache_model ("maps/b_rock1.bsp");
		setmodel (self, "maps/b_rock1.bsp");
		self.aflag = 10;
	}
	else
	{
		precache_model ("maps/b_rock0.bsp");
		setmodel (self, "maps/b_rock0.bsp");
		self.aflag = 5;
	}
	self.weapon = 3;
	self.netname = "rockets";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_cells =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = ammo_touch;

	if (self.spawnflags & #WEAPON_BIG2)
	{
		precache_model ("maps/b_batt1.bsp");
		setmodel (self, "maps/b_batt1.bsp");
		self.aflag = 12;
	}
	else
	{
		precache_model ("maps/b_batt0.bsp");
		setmodel (self, "maps/b_batt0.bsp");
		self.aflag = 6;
	}
	self.weapon = 4;
	self.netname = "cells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/

#define WEAPON_SHOTGUN	1 
#define WEAPON_ROCKET	2 
#define WEAPON_SPIKES	4 
#define WEAPON_BIG	8 
void() item_weapon =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = ammo_touch;

	if (self.spawnflags & #WEAPON_SHOTGUN)
	{
		if (self.spawnflags & #WEAPON_BIG)
		{
			precache_model ("maps/b_shell1.bsp");
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_shell0.bsp");
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}
		self.weapon = 1;
		self.netname = "shells";
	}

	if (self.spawnflags & #WEAPON_SPIKES)
	{
		if (self.spawnflags & #WEAPON_BIG)
		{
			precache_model ("maps/b_nail1.bsp");
			setmodel (self, "maps/b_nail1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_nail0.bsp");
			setmodel (self, "maps/b_nail0.bsp");
			self.aflag = 20;
		}
		self.weapon = 2;
		self.netname = "spikes";
	}

	if (self.spawnflags & #WEAPON_ROCKET)
	{
		if (self.spawnflags & #WEAPON_BIG)
		{
			precache_model ("maps/b_rock1.bsp");
			setmodel (self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else
		{
			precache_model ("maps/b_rock0.bsp");
			setmodel (self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}
		self.weapon = 3;
		self.netname = "rockets";
	}
	
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*
===============================================================================

KEYS

===============================================================================
*/

void() key_touch =
{
	/*local entity	stemp;
	local float 	best;*/

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.items & self.items)
		return;
	if (prematch >= time)
		return;

	sprint (other, #PRINT_LOW, "You got the ");
	sprint (other, #PRINT_LOW, self.netname);
	sprint (other, #PRINT_LOW, "\n");

	sound (other, #CHAN_ITEM, self.noise, 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	if (!coop)
	{	
		self.solid = #SOLID_NOT;
		self.model = string_null;
	}
	else if (coop && self.deadflag)
	{
		dremove(self);
		return;
	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};

void() key_setsounds =
{
	if (world.worldtype == 0)
	{
		precache_sound ("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}
	if (world.worldtype == 1)
	{
		precache_sound ("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}
	if (world.worldtype == 2)
	{
		precache_sound2 ("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key1 =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	if (world.worldtype == 0)
	{
		precache_model ("progs/w_s_key.mdl");
		setmodel (self, "progs/w_s_key.mdl");
		self.netname = "silver key";
	}
	else if (world.worldtype == 1)
	{
		precache_model ("progs/m_s_key.mdl");
		setmodel (self, "progs/m_s_key.mdl");
		self.netname = "silver runekey";
	}
	else if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
		self.netname = "silver keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = #IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key2 =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	if (world.worldtype == 0)
	{
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}
	if (world.worldtype == 1)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}
	if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = #IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{
/*local entity	stemp;
local float 	best;*/

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (prematch >= time)
		return;

#ifndef NET_SERVER
	CenterPrint (other, "You got the rune!");
#endif

	sound (other, #CHAN_ITEM, self.noise, 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = #SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = "";		// so rune doors won't find it
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}

	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{
/*local entity	stemp;
local float 	best;*/

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (prematch >= time)
		return;

	//- OfN team_no is now used for items!
	if (self.team_no>0)
	{
		if (!Teammate(other, self))
			return;
	}
	//-----------------------------------//

	sprint (other, #PRINT_LOW, "You got the ");
	sprint (other, #PRINT_LOW, self.netname);
	sprint (other, #PRINT_LOW, "\n");

	if (deathmatch)
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_invulnerability") ||
			(self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
		
		self.think = SUB_regen;
	}	
	else if (coop)
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_invulnerability") ||
			(self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 120*5;
		else
			self.nextthink = time + 120;
		
		self.think = SUB_regen;
	}	

	sound (other, #CHAN_VOICE, self.noise, 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = #SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
		other.invincible_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
		other.invisible_finished = time + 30;
	}

	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
		//WK Remove Inspiration when we get the real thing
		other.tfstate = other.tfstate - (other.tfstate & #TFSTATE_INSPIRED);
	}	

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/
void() item_artifact_invulnerability =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = powerup_touch;

	precache_model ("progs/invulner.mdl");
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = #IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = powerup_touch;

	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = #IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = powerup_touch;

	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = #IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void() item_artifact_super_damage =
{
	if (CheckExistence() == #FALSE)
	{
		dremove(self);
		return;
	}

	self.touch = powerup_touch;

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = #IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() BackpackTouch =
{
	local string	s;
	/*local float		best;
	local entity	stemp;*/
	
	if (other.health <= 0)
		return;

	if (other.classname != "player")
	{
		if (other.classname != "monster_army") 
			return;

		other.ammo_shells = other.ammo_shells + self.ammo_shells;
		other.ammo_nails = other.ammo_nails + self.ammo_nails;
		other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
		other.ammo_cells = other.ammo_cells + self.ammo_cells;

		grunty_boundammo(other);
		
		PrintFromSoldier(other,other.real_owner,"i picked up some ammo.\n",#PRINT_MEDIUM);

		sound (other, #CHAN_ITEM, "weapons/lock4.wav", 1, #ATTN_NORM);
	  
		dremove(self);
		self = other;
		return;
	}

	// You can't pick up Backpacks while firing.
	if (other.button0)
		return;

	// change munitions
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	// Add only the weapons this playerclass can use
	// don't pick up backpack weapons in TF
	//	TeamFortress_AddBackpackItems(other,self);
		
	bound_other_ammo (other);

	sprint (other, #PRINT_LOW, "You get ");

	if (self.ammo_shells)
	{
		s = ftos(self.ammo_shells);
		sprint (other, #PRINT_LOW, s);
		sprint (other, #PRINT_LOW, " shells  ");
	}
	if (self.ammo_nails)
	{
		s = ftos(self.ammo_nails);
		sprint (other, #PRINT_LOW, s);
		sprint (other, #PRINT_LOW, " nails ");
	}
	if (self.ammo_rockets)
	{
		s = ftos(self.ammo_rockets);
		sprint (other, #PRINT_LOW, s);
		sprint (other, #PRINT_LOW, " rockets  ");
	}
	if (self.ammo_cells)
	{
		s = ftos(self.ammo_cells);
		sprint (other, #PRINT_LOW, s);
		sprint (other, #PRINT_LOW, " cells  ");
	}
	// ENGINEER's can get armor from backpacks and use it for metal
	if (self.armorvalue && (other.weapons_carried & #WEAP_SPANNER || other.tf_items & #NIT_TESLA || other.cutf_items & #CUTF_SENTRYGUN) && other.ammo_cells < other.maxammo_cells)
	{
		s = ftos(self.armorvalue);
		sprint (other, #PRINT_LOW, s);
		sprint (other, #PRINT_LOW, " metal  ");
		other.ammo_cells = other.ammo_cells + self.armorvalue;
		if (other.ammo_cells > other.maxammo_cells)
			other.ammo_cells = other.maxammo_cells;
	}
	
	sprint (other, #PRINT_LOW, "\n");
	// backpack touch sound
	sound (other, #CHAN_ITEM, "weapons/lock4.wav", 1, #ATTN_NORM);
	stuffcmd (other, "bf\n");

	// change to a better weapon if appropriate
/*	if ( (!(other.tfstate & #TFSTATE_RELOADING)) && (other.weapon == best))
	{
		stemp = self;
		self = other;
		self.weapon = W_BestWeapon();
		self = stemp;
	}
*/
	dremove(self);
	
	self = other;
	if (!(other.current_weapon == #WEAP_ASSAULT_CANNON))
		W_SetCurrentAmmo ();
};

/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return; // nothing in it

	newmis = spawn();
	newmis.origin = self.origin - '0 0 24';

// don't drop weapons in backpacks	
//	newmis.items = self.current_weapon;

	newmis.ammo_shells = self.ammo_shells;
	newmis.ammo_nails = self.ammo_nails;
	newmis.ammo_rockets = self.ammo_rockets;
	newmis.ammo_cells = self.ammo_cells;

	// Drop armor in the backpack now, although only Engineer's can get it for metal
	newmis.armorvalue = self.armorvalue;

	newmis.velocity_z = 300;
	newmis.velocity_x = -100 + (random() * 200);
	newmis.velocity_y = -100 + (random() * 200);
	
	newmis.flags = #FL_ITEM;
	newmis.solid = #SOLID_TRIGGER;
	newmis.movetype = #MOVETYPE_TOSS;
	setmodel (newmis, "progs/backpack.mdl");
	setsize (newmis, '-16 -16 0', '16 16 56');
	newmis.touch = BackpackTouch;
	
	newmis.nextthink = time + 20;	// remove after 2 minutes
	newmis.think = SUB_Remove;
};



