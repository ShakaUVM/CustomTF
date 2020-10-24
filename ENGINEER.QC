/*======================================================
	ENGINEER.QC 		Custom TeamFortress v3.1	

	(c) TeamFortress Software Pty Ltd	2/3/97
	(c) William Kerney			4/14/00
	(c) Craig Hauser				4/14/00
========================================================
Weapons and functions for the ENGINEER class and associated weaponry
=======================================================*/
float modelindex_tesla; //CH
// Weapon Functions
void() LaserBolt_Touch;
void() LaserBolt_Think;
void() W_FireLaser;

// EMP Grenade Functions
void() EMPExplode;
void() EMPGrenadeTouch;
void() EMPGrenadeExplode;

// Building Functions
void() TeamFortress_EngineerBuild;
void(float objtobuild, float devicenum) TeamFortress_Build;
void() TeamFortress_FinishedBuilding;
void() T_Dispenser;
void() Dispenser_Die;
void(entity disp) Engineer_UseDispenser;
void(entity gun) Engineer_UseSentryGun;
void(entity cam) Engineer_UseCamera;
void() CheckDistance;
float(entity obj, entity builder) CheckArea;
//WK
void() Sentry_Touch;
float(float myteam) HasFlag;

//- OfN
void(entity fieldgen) FieldGen_Built;
float(entity player, float buildtype) EnoughToBuild;

//=========================================================================
// Laserbolt think function
void() LaserBolt_Think =
{
	if (time > self.heat) {
		dremove(self);	
		return;
	}	
	self.solid = #SOLID_TRIGGER;
	self.movetype = #MOVETYPE_FLYMISSILE;
	self.velocity = self.oldorigin;
	self.touch = LaserBolt_Touch;
	setmodel(self, "progs/e_spike2.mdl");

	self.nextthink = time + 1.0;
	self.think = SUB_Remove;
};

//=========================================================================
// Laserbolt touch function. Just moves through the player and comes out
// the other side.
void() LaserBolt_Touch =
{
	local vector org;
	
	if (time > self.heat) {
		dremove(self);	
		return;
	}

	if (other == self.owner)
		return; 	

	if (other == self.enemy && self.enemy != world)
		return; 	// don't explode on same person twice

	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		dremove(self);
		return;
	}

	//WK Sweep mines at point of impact
	GuerillaMineSweep(self.origin);

	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood (org, 15);
		deathmsg = #DMSG_LASERBOLT;
		TF_T_Damage (other, self, self.enemy, 25, 0, #TF_TD_ELECTRICITY);
		self.velocity = self.oldorigin;
		self.owner = other;

		setmodel (self, string_null);
		self.touch = SUB_Null;
//		self.solid = #SOLID_NOT;
//		self.movetype = #MOVETYPE_NOCLIP;

		self.nextthink = time + 0.1;
		self.think = LaserBolt_Think;
		return;
	}
	else
	{
		//WK Fly through walls!
		setmodel (self, string_null);
		self.touch = SUB_Null;
		self.solid = #SOLID_NOT;
		self.movetype = #MOVETYPE_NOCLIP;

		self.nextthink = time + 0.1;
		self.think = LaserBolt_Think;
		return;
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_SPIKE);
		WriteCoord (#MSG_BROADCAST, self.origin_x);
		WriteCoord (#MSG_BROADCAST, self.origin_y);
		WriteCoord (#MSG_BROADCAST, self.origin_z);
	#ifdef QUAKE_WORLD
		multicast (self.origin, #MULTICAST_PHS);
	#endif
	}
	
	dremove(self);	
};

//=========================================================================
// Fire a laserbolt
//WK 1/7/7 Note: This is the railgun, not the thunderbolt, nor the lasercannon
void() W_FireLaser =
{
	local	vector	vec, org;

	self.currentammo = self.ammo_nails = self.ammo_nails - 1;

	makevectors(self.v_angle);
	org = self.origin + (v_forward * 8);
	vec = aim(self, 10000);
	vec = normalize(vec);
		
	newmis = spawn();
	newmis.owner = self;
	newmis.enemy = self;	// The real owner
	newmis.movetype = #MOVETYPE_FLYMISSILE;
	newmis.solid = #SOLID_TRIGGER;

	setmodel (newmis, "progs/e_spike1.mdl");
	setsize (newmis, '0 0 0', '0 0 0'); 	

	setorigin (newmis, org + '0 0 16');

	newmis.velocity = vec * 1500;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.oldorigin = newmis.velocity;

	newmis.nextthink = time + 1.5;
	newmis.heat = time + 1.5;

	newmis.think = SUB_Remove;
	newmis.touch = LaserBolt_Touch;
};

//=========================================================================
// Ammo/Weapon exploded by the EMP grenade
void() EMPExplode =
{
	local float expsize;

	expsize = 10;
	// Weapon?
	if (self.touch == weapon_touch)
		expsize = 60;
	else if (self.classname == "item_shells")
		expsize = 50 + self.aflag;
	else if (self.classname == "item_spikes")
		expsize = 40;
	else if (self.classname == "item_rockets")
		expsize = 100 + (self.aflag * 4);
	else if (self.classname == "item_cells")
		expsize = 100 + (self.aflag * 3);
	else if (self.classname == "item_weapon")
		expsize = 60;
	else
	{
		RPrint("EMPExplode: Attempting to explode a ");
		RPrint(self.classname);
		RPrint("\n");
		return;
	}

	deathmsg = #DMSG_GREN_EMP_AMMO;
	T_RadiusDamage (self, self.enemy, expsize, world);

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
#endif

	// Respawn
	Respawn_Item(self, self.enemy);
};

//=========================================================================
// Touch Function for EMP Grenade
void() EMPGrenadeTouch =
{
	// If the EMP Grenade hits a player, it just bounces off
	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// EMP Grenade explode function, for when the PRIMETIME runs out
void() EMPGrenadeExplode =
{
	local float expsize;
	local entity te, oldself;
	local float total_exp;
//CH Slice gave idea of an emp gren getting rated based on blast so i added..
	total_exp = 0;

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_TAREXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
#endif

	local string desc;
	desc = "grenade";

	if (self.netname == "special_mine")
		desc = "mine";

	// Find all ammo in the area
	te = findradius(self.origin, 240);
	while (te)
	{	
		if (!CanDamage(te,self)) // OfN
		{
			SUB_Null();
		}
		else if (te.touch == ammo_touch || te.touch == weapon_touch) // Ammo/Weapon?
		{
			// Make sure it isn't picked up in the next second
			te.solid = #SOLID_NOT;
			te.enemy = self.owner;
			te.nextthink = time + 1 + (random() * 2);
			te.think = EMPExplode;
		}
		// Detpack?
		else if (te.think == TeamFortress_DetpackExplode)
		{
			//te.solid = #SOLID_NOT;
			te.nextthink = time + 225 * random() + 30; //WK Scramble the detpack's timer. :)
			dremove(te.oldenemy); // Countdown ent

			sprint(self.owner,#PRINT_HIGH,"Your EMP ",desc," damages the detpack circuits\n");
			sprint(te.owner,#PRINT_HIGH,"Your detpack circuits have been damaged!\n");
		}
		// Pipebomb?
		else if (te.classname == "pipebomb")
		{
			te.nextthink = time + 0.1 + random();
		}
		// Mine?
		else if (te.classname == "grenade" && te.netname == "land_mine")
		{
			te.think = GuerillaExplode;
			te.nextthink = time + 0.1;
		}
		// Building?
		else if (IsBuilding(te)) {
			total_exp = total_exp + 120;
			TF_T_Damage(te,self,self.owner, 120, 0, #TF_TD_EXPLOSION);
		}
		// Ammobox?
		else if (te.classname == "ammobox")
		{
			expsize = 0;
			expsize = expsize + (te.ammo_shells * 0.5); //WK .75
			expsize = expsize + ((te.ammo_rockets * 0.5) * 2); //WK .75
			expsize = expsize + ((te.ammo_cells * 0.5) * 2); //WK .75

			if (expsize > 0)
			{
				te.solid = #SOLID_NOT;
				
				// Damage player and explode
				deathmsg = #DMSG_GREN_EMP;
				total_exp = total_exp + expsize;
				if (expsize > 300) //CH so they are not too powerfull //WK was 500
					expsize = 300;
				T_RadiusDamage (te, self.owner, expsize, te);

				te.think = SUB_Remove;
				te.nextthink = time + 0.1;

				WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
				WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
				WriteCoord (#MSG_BROADCAST, te.origin_x);
				WriteCoord (#MSG_BROADCAST, te.origin_y);
				WriteCoord (#MSG_BROADCAST, te.origin_z);
			#ifdef QUAKE_WORLD
				multicast (te.origin, #MULTICAST_PHS);
			#endif
			}
		}
		// Backpack/Player?
		else if ((te.classname == "player" && te.health > 0) || (te.classname=="monster_army") || (te.classname=="monster_gremlin") || (te.touch == BackpackTouch))
		{
			expsize = 0;
			// calculate explosion size
			// //WK 6/1/7 Reduced EMP damage from 75% ammo to 50% ammo, it was doing way too much damage
			expsize = expsize + (te.ammo_shells * 0.5); //WK .75
			expsize = expsize + ((te.ammo_rockets * 0.5) * 2); //WK .75
			if (!(te.cutf_items & #CUTF_SENTRYGUN || te.tf_items & #NIT_TESLA || te.weapons_carried & #WEAP_SPANNER || te.touch == BackpackTouch)) //WK 6/1/7 Added in sentrygun and tesla to match the below
				expsize = expsize + (te.ammo_cells * 0.5); //WK .75

			if (expsize > 0)
			{
				// Damage player and explode
				deathmsg = #DMSG_GREN_EMP;
				total_exp = total_exp + expsize;
				//WK Make players not explode radially!
				if (te.touch == BackpackTouch) 
					T_RadiusDamage (te, self.owner, expsize / 2, te); //WK Dampen backpack damage
				if (te.touch != BackpackTouch)
				{
					TF_T_Damage (te, self, self.owner, expsize, 0, #TF_TD_EXPLOSION);

					// Remove ammo
					te.ammo_shells = ceil(te.ammo_shells * 0.5); //WK .25
					te.ammo_rockets = ceil(te.ammo_rockets * 0.5); //WK .25
					if (!(te.cutf_items & #CUTF_SENTRYGUN || te.tf_items & #NIT_TESLA || te.weapons_carried & #WEAP_SPANNER)) //WK 6/1/7 EMP Bugfix -- Added in spanner to match above
						te.ammo_cells = ceil(te.ammo_cells * 0.5); //WK .25

					if (te.classname=="player")
					{
						// Update console
						oldself = self;
						self = te;
						W_SetCurrentAmmo();
						self = oldself;
						
						WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
						WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
						WriteCoord (#MSG_BROADCAST, te.origin_x);
						WriteCoord (#MSG_BROADCAST, te.origin_y);
						WriteCoord (#MSG_BROADCAST, te.origin_z);
					#ifdef QUAKE_WORLD
						multicast (te.origin, #MULTICAST_PHS);
					#endif
					}
				}
				else
				{
					te.think = SUB_Remove;
					te.nextthink = time + 0.1;
				}

				WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
				WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
				WriteCoord (#MSG_BROADCAST, te.origin_x);
				WriteCoord (#MSG_BROADCAST, te.origin_y);
				WriteCoord (#MSG_BROADCAST, te.origin_z);
			#ifdef QUAKE_WORLD
				multicast (te.origin, #MULTICAST_PHS);
			#endif
			}
		}

		te = te.chain;
	}

	sound (self, #CHAN_WEAPON, "weapons/gren_emp.wav", 1, #ATTN_NORM); //- OfN - cool sound! :)

if (total_exp > 0) {//CH Thanks Slice for the idea :)

	sprint(self.owner,#PRINT_HIGH, "Your EMP ",desc," inflicted ");
	local string st;
	st = ftos(total_exp);
	sprint(self.owner,#PRINT_HIGH, st);
	sprint(self.owner,#PRINT_HIGH, " damage\n");
}

#ifdef QUAKE_WORLD
	dremove(self);
#else
	BecomeExplosion();
#endif
};


//=========================================================================
// Tests whether a team is allowed to build or not

float(float myteam) HasFlag =
{
	
	if ( mapname != "steal4d" )
		return #TRUE;
	
	if (myteam == team_with_flag) { 
		return #TRUE;
	}
	return #FALSE;	
};

//=========================================================================
// Function handling the Engineer's build impulse
void() TeamFortress_EngineerBuild =
{
	local entity te;
	
	// Can't build in the air
	// WK Yes you can, why not? You can do it by pulling up this menu anyway
	/*
	if (!(self.flags & #FL_ONGROUND))
	{
		CenterPrint(self, "You can't build in the air!\n\n");
		return;
	}
	*/
	


	if (self.is_detpacking == 1) {
		CenterPrint(self, "You can't build while detpacking\n");
		return; 	
	}

	if (self.is_feigning == 1) {
		CenterPrint(self, "You can't build while feigning\n");
		return; 	
	}

	// Pop up the menu
	if (self.is_building == 0)
	{
		// Check to see if they've got enuf metal to build anything
		if (self.ammo_cells < #BUILD_COST_CAMERA && self.has_dispenser == #FALSE && self.has_sentry == #FALSE && self.has_tesla == #FALSE && self.has_camera == #FALSE && self.has_teleporter == #FALSE && self.has_sensor == #FALSE && self.has_fieldgen == #FALSE)
		{
			CenterPrint(self, "You don't have enough metal to \nbuild anything.\n\n");
			return;
		}

		self.current_menu = #MENU_ENGINEER;
		self.menu_count = #MENU_REFRESH_RATE;
	}
	else if (self.is_building == 1) 
	{
		sprint(self, #PRINT_HIGH, "You stop building.\n");

		self.is_building = 0;
		self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);

#ifdef QUAKE_WORLD
		TeamFortress_SetSpeed(self);
#else
		self.pausetime = time;
#endif

		// Remove the timer
		te = find(world, netname, "build_timer");
		while (te)
		{
			if (te.owner == self)
			{
				dremove(te);
				te = world;
			}
			else
			{
				te = find(te, netname, "build_timer");
			}
		}

		self.current_weapon = self.weapon;
		W_SetCurrentAmmo();
	}
};


// Gizmo - make sure the size of the entity to be checked is set _before_ this is called
// in normal TF they set the size afterwords
float(entity obj, entity builder) CheckArea =
{
	if ( InSolid( obj ) )
		return #FALSE;

	// Trace a line from the player to the object too
	traceline(builder.origin, obj.origin, #TL_BSP_ONLY, builder);

	if (trace_fraction != 1)
		return #FALSE;

	return #TRUE;
};

//////////////////////////////////////////////////////////////////////////
// rehashed version of TF_Build 
void(float objtobuild, float devicenum) TeamFortress_Build =
{
	// OfN - the following is needed because we can build via menus or by cmnd
	if (self.is_building == 1)
	{
		sprint(self, #PRINT_HIGH, "You are already building something!\n");
		return;
	}
	if (intermission_running || ceasefire)
		return;
	if (self.flags & #FL_FINALIZED)
		return;
	if (self.health <= 0 || self.deadflag != #DEAD_NO)
		return;
	if (prematch >= time)
		return;
	if (self.done_custom & #CUSTOM_BUILDING) // no ppl customizing
		return;
	if (self.playerclass == #PC_UNDEFINED) // no observers
		return;
	if (self.penance_time >= time) // Don't let lame teamkillers build anything
		return;

	if (!EnoughToBuild(self,objtobuild))
	{
		sprint(self, #PRINT_HIGH, "You don't have enough metal to build that!\n");
		return;
	}

	// OfN - Psionized guys can't build
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self, #PRINT_HIGH, "You are not able to build while psionized!\n");
		return;
	}

	//WK Cheat Fix 
	if (self.is_feigning) {
			sprint(self, #PRINT_HIGH, "Try standing up first!\n");
			return;
	}

	//OfN - Cheat Fix, heh
	if (self.is_haxxxoring) {
			sprint(self, #PRINT_HIGH, "You can't build while hacking!\n");
			return;
	}

	if (self.is_detpacking || self.is_toffingadet)
	{
		sprint (self, #PRINT_HIGH, "You can't build while manipulating a detpack!\n");
		return;
	}

	local float btime;
	//local entity te;
	local vector tmp1, tmp2;

	newmis = spawn();

	// get an origin
	makevectors(self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward) * 64;
	
	if (objtobuild == #BUILD_FIELDGEN) //- OfN - Field generators must be lined up to work
		newmis.origin = WhereGen(self.origin + v_forward);
	else
		newmis.origin = self.origin + v_forward;

	if (objtobuild == #BUILD_DISPENSER)
	{
		if (self.has_dispenser)
		{
			sprint(self, #PRINT_HIGH, "You can only have one dispenser.\nTry dismantling your old one.\n");
			dremove(newmis);
			return;
		}
		if (!(self.cutf_items & #CUTF_DISPENSER))
		{
			sprint(self, #PRINT_HIGH, "You must buy the dispenser before you can build it.\n");
			dremove(newmis);
			return;
		}
		tmp1 = '-16 -16 0';
		tmp2 = '16 16 48';

		newmis.mdl = "progs/disp.mdl";		  
		
		newmis.netname = "dispenser";

		btime = time + #BUILD_TIME_DISPENSER;
	}
	else if (objtobuild == #BUILD_SENTRYGUN)
	{
		if (!(self.cutf_items & #CUTF_SENTRYGUN))
		{
			sprint(self, #PRINT_HIGH, "You must buy a sentry gun before you can build one.\n");
			dremove(newmis);
			return;
		}
		
		if (self.cutf_items & #CUTF_DOUBLESENTRY)
		{
			if (self.has_sentry & devicenum)
			{
				sprint(self, #PRINT_HIGH, "You already have that sentry gun up!\n");
				dremove(newmis);
				return; 			   
			}
		}
		else
		{
			if (self.has_sentry)
			{
				sprint(self, #PRINT_HIGH, "You can only have one sentry gun.\nTry dismantling your old one.\n");
				dremove(newmis);
				return;
			}
		}			 

		newmis.dont_do_triggerwork = devicenum;

		tmp1 = '-16 -16 0';
		tmp2 = '16 16 48';
		//newmis.mdl = "progs/turrbase.mdl"; 
		newmis.mdl = "progs/trrbs2.mdl";
		newmis.netname = "sentrygun";
	
		btime = time + #BUILD_TIME_SENTRYGUN;
	}
	else if (objtobuild == #BUILD_TESLA)
	{
		if (!(self.tf_items & #NIT_TESLA))
		{
			sprint(self, #PRINT_HIGH, "You must buy a tesla sentry before you can build one.\n");
			dremove(newmis);
			return;
		}
		
		if (self.tf_items & #NIT_DOUBLETESLA)
		{
			if (self.has_tesla & devicenum)
			{
				sprint(self, #PRINT_HIGH, "You already have that tesla coil up!\n");
				dremove(newmis);
				return;
			}
		}
		else
		{
			if (self.has_tesla)
			{
				sprint(self, #PRINT_HIGH, "You can only have one tesla gun.\nTry dismantling your old one.\n");
				dremove(newmis);
				return;
			}
		}

		newmis.dont_do_triggerwork = devicenum;
		
		//tmp1 = '-16 -16 0'; //- OfN commented by
		tmp1 = '-16 -16 -25';
		//tmp2 = '16 16 48'; //WK 62 is better, but crashes?
		tmp2 = '16 16 23';
		//newmis.mdl = "progs/newtesla.mdl";
		newmis.mdl = "progs/coil.mdl";
		newmis.netname = "tesla";
		newmis.origin = newmis.origin + '0 0 25';
	
		btime = time + #BUILD_TIME_TESLA;
	}
	else if (objtobuild == #BUILD_SECURITY_CAMERA)
	{
		dremove(newmis);

		if (self.has_camera)
		{
			sprint(self, #PRINT_HIGH, "You can only have one security camera.\nTry dismantling your old one.\n");
			return;
		}
		if (!(self.tf_items & #NIT_SECURITY_CAMERA))
		{
			sprint(self, #PRINT_HIGH, "You must buy a security camera before you can build one.\n");
			return;
		}
		
		Security_Camera_Spawn();
		return;
	}
	else if (objtobuild == #BUILD_TELEPORTER)
	{
		if (self.has_teleporter >= 2)
		{
			sprint(self, #PRINT_HIGH, "You can only have 2 teleporters.\nTry dismantling an old one.\n");
			dremove(newmis);
			return;
		}
		if (!(self.tf_items & #NIT_TELEPORTER))
		{
			sprint(self, #PRINT_HIGH, "You must buy a teleporter before you can build one.\n");
			dremove(newmis);
			return;
		}

		tmp1 = '-16 -16 0';
		tmp2 = '16 16 4';
		newmis.mdl = "progs/telepad.mdl";
		newmis.netname = "teleporter";
	
		btime = time + #BUILD_TIME_TELEPORTER;
	}
	else if (objtobuild == #BUILD_FIELDGEN)
	{
		if (self.has_fieldgen >= 2)
		{
			sprint(self, #PRINT_HIGH, "You already have 2 field generators.\nTry dismantling an old one.\n");
			dremove(newmis);
			return;
		}
		if (!(self.cutf_items & #CUTF_FIELDGEN))
		{
			sprint(self, #PRINT_HIGH, "You must buy a field generator before you can build one.\n");
			dremove(newmis);
			return;
		}

		tmp1 = '-6 -6 0';
		tmp2 = '6 6 54';
		newmis.mdl = "progs/ffgen2.mdl";
		newmis.netname = "field generator";
	
		btime = time + #BUILD_TIME_FIELDGEN;
	}
	
	// before we start building it, check it out
	// check for validity of point
	// Gizmo - moved these up here
	setmodel (newmis, newmis.mdl);
	setsize (newmis, tmp1, tmp2);
	setorigin (newmis, newmis.origin);
	if (CheckArea(newmis, self) == #FALSE)
	{
		sprint(self, #PRINT_HIGH, "Not enough room to build here\n");
		dremove(newmis);
		return;
	}

	//WK 8/4/7 If we don't have spanner, build times are increased by 50%
	if (!(self.weapons_carried & #WEAP_SPANNER)) btime = time + ((btime-time) * 1.5);

	self.is_building = 1;
	makeImmune(self,time + 2);
	//self.immune_to_check = time + 2;
	self.tfstate = self.tfstate | #TFSTATE_CANT_MOVE;

	// Save the current weapon and remove it
	self.weapon = self.current_weapon;
	self.current_weapon = 0;
	self.weaponmodel = "";
	self.weaponframe = 0;

#ifdef QUAKE_WORLD
	TeamFortress_SetSpeed(self);
#else
	self.pausetime = btime;
#endif

	newmis.owner = self;
	newmis.classname = "timer";
	newmis.netname = "build_timer";
	newmis.nextthink = btime;
	newmis.think = TeamFortress_FinishedBuilding;
	newmis.colormap = self.colormap;
	newmis.weapon = objtobuild;
	newmis.angles_y = anglemod(self.angles_y + 180);

	newmis.velocity = '0 0 8';
	newmis.movetype = #MOVETYPE_TOSS;	 

	newmis.solid = #SOLID_BBOX;

	if (objtobuild==#BUILD_TESLA)
	{
		if (neo) // for Neo mode
		{
			if (neoLives != newmis.owner)
				newmis.skin = 3;
			else
				newmis.skin = 1;
		}
		else
		{
			newmis.skin = self.team_no;
			if (self.team_no==3) newmis.skin=0;
			else if (self.team_no==4) newmis.skin=3;
		}
	}

	newmis.flags = newmis.flags - (newmis.flags & #FL_ONGROUND);
};

void() DispenserThink =
{
	local float iI; // is Improved?

	iI=1;
	
	if (self.all_active & #IMPROVED_ONE)
		iI=2;


	// dispenser refilling itself 5%
	if (!(self.is_malfunctioning & #SCREWUP_THREE)) // SB
	{
		self.ammo_shells = self.ammo_shells + rint((#BUILD_DISPENSER_MAX_SHELLS*iI) / 10);
		self.ammo_cells = self.ammo_cells + rint((#BUILD_DISPENSER_MAX_CELLS*iI) / 10);
		self.ammo_nails = self.ammo_nails + rint((#BUILD_DISPENSER_MAX_NAILS*iI) / 10);
		self.ammo_rockets = self.ammo_rockets + rint((#BUILD_DISPENSER_MAX_ROCKETS*iI) / 10);
		self.armorvalue = self.armorvalue + rint((#BUILD_DISPENSER_MAX_ARMOR*iI) / 10); 

		if (self.ammo_shells > #BUILD_DISPENSER_MAX_SHELLS*iI)
			self.ammo_shells = #BUILD_DISPENSER_MAX_SHELLS*iI;	
		if (self.ammo_nails > #BUILD_DISPENSER_MAX_NAILS*iI)
			self.ammo_nails = #BUILD_DISPENSER_MAX_NAILS*iI;	
		if (self.ammo_rockets > #BUILD_DISPENSER_MAX_ROCKETS*iI)
			self.ammo_rockets = #BUILD_DISPENSER_MAX_ROCKETS*iI;	
		if (self.ammo_cells > #BUILD_DISPENSER_MAX_CELLS*iI)
			self.ammo_cells = #BUILD_DISPENSER_MAX_CELLS*iI;	
		if (self.armorvalue > #BUILD_DISPENSER_MAX_ARMOR*iI)
			self.armorvalue = #BUILD_DISPENSER_MAX_ARMOR*iI;
			
		if (self.all_active & #IMPROVED_FOUR) // Upgraded dispenser
		{
			self.ammo_detpack = self.ammo_detpack + (#BUILD_DISPENSER_MAX_DETS*iI) /10;
			self.ammo_c4det = self.ammo_c4det + (#BUILD_DISPENSER_MAX_DETS*iI) /10;
			self.ammo_medikit = self.ammo_medikit + rint((#BUILD_DISPENSER_MAX_MEDIKIT*iI) /10);

			if (self.ammo_detpack > #BUILD_DISPENSER_MAX_DETS*iI)
				self.ammo_detpack = #BUILD_DISPENSER_MAX_DETS*iI;	
			if (self.ammo_c4det > #BUILD_DISPENSER_MAX_DETS*iI)
				self.ammo_c4det = #BUILD_DISPENSER_MAX_DETS*iI;
			if (self.ammo_medikit > #BUILD_DISPENSER_MAX_MEDIKIT*iI)
				self.ammo_medikit = #BUILD_DISPENSER_MAX_MEDIKIT*iI;
		}
	}
	self.nextthink = time + 10;
};

void() TeamFortress_FinishedBuilding =
{
	local entity oldself;
	local float current_yaw;
	//local vector source;

	if (self.owner.is_building != 1)
		return;

	oldself = self;
	self = self.owner;
	oldself.owner = world;
	oldself.real_owner = self;

	self.is_building = 0;
	self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
	self.current_weapon = self.weapon;
	self.StatusRefreshTime = time + 0.1;

	TeamFortress_SetSpeed(self);

	oldself.flags = oldself.flags | #FL_MACHINE; // PZ

	if (oldself.weapon == #BUILD_DISPENSER)
	{
		self.has_dispenser = #TRUE;
		sprint (self, #PRINT_HIGH, "You finish building the dispenser.\n");

		teamprefixsprint(self.team_no,self); //- OfN

		teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Dispenser.\n");

		self.ammo_cells = self.ammo_cells - #BUILD_COST_DISPENSER;
		
		// Create the dispenser
		oldself.classname = "building_dispenser";
		oldself.netname = "dispenser";
		oldself.blocked = T_Dispenser;		// Actual touch function
		oldself.touch = T_Dispenser;
		oldself.max_health = #BUILD_HEALTH_DISPENSER;
		oldself.health = #BUILD_HEALTH_DISPENSER;
		oldself.think = DispenserThink;
		oldself.nextthink = time + 5;
		oldself.th_die = Dispenser_Die; 	// Death function
		
		oldself.mdl = "progs/disp.mdl"; 	// Actual mdl
		
		oldself.team_no = self.team_no;

		oldself.all_active=0; // OfN - reset HACKER improvements
		oldself.is_malfunctioning = 0;

		oldself.real_owner = self;			// The Engineer owns this item
		oldself.colormap = self.colormap;	// Set the Color
		oldself.takedamage = #DAMAGE_AIM;
		oldself.owner = world;
		oldself.movetype = #MOVETYPE_TOSS;
		oldself.velocity = '0 0 8';
		oldself.flags = oldself.flags - (oldself.flags & #FL_ONGROUND);

		// Put some ammo in the Dispenser
		oldself.ammo_shells = ceil(self.ammo_shells * 0.25);
		oldself.ammo_nails = ceil(self.ammo_nails * 0.25);
		oldself.ammo_rockets = ceil(self.ammo_rockets * 0.25);
		oldself.ammo_cells = ceil(self.ammo_cells * 0.25);
		oldself.armorvalue = ceil(self.armorvalue * 0.25);
		
		oldself.ammo_medikit = ceil(self.ammo_medikit * 0.25);

		oldself.ammo_detpack = ceil(self.ammo_detpack * 0.25);
		oldself.ammo_c4det = ceil(self.ammo_c4det * 0.25);
		
		// Remove ours
		self.ammo_shells = ceil(self.ammo_shells * 0.75);
		self.ammo_nails = ceil(self.ammo_nails * 0.75);
		self.ammo_rockets = ceil(self.ammo_rockets * 0.75);
		self.ammo_cells = ceil(self.ammo_cells * 0.75);
		self.armorvalue = ceil(self.armorvalue * 0.75);

		self.ammo_detpack = ceil(self.ammo_detpack * 0.75);
		self.ammo_c4det = ceil(self.ammo_c4det * 0.75);
		
		self.ammo_medikit = ceil(self.ammo_medikit * 0.75);

		oldself.solid = #SOLID_BBOX;
		setmodel(oldself, oldself.mdl);
		setsize (oldself, '-8 -8 0', '8 8 24');
		setorigin(oldself, oldself.origin + '0 0 16'); //CH disp does jump
	}
	else if (oldself.weapon == #BUILD_SENTRYGUN)
	{
		//CH special sbar for eng.
		self.StatusBarScreen = 1;
		//self.has_sentry = #TRUE;
		self.has_sentry = self.has_sentry | oldself.dont_do_triggerwork;
		sprint (self, #PRINT_HIGH, "You finish building the sentry gun.\n");

		teamprefixsprint(self.team_no,self); //- OfN

		teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Sentry Gun.\n");
			
		oldself.classname = "building_sentrygun_base";
		oldself.netname = "sentry gun";
		oldself.takedamage = 0;
		oldself.th_die = Sentry_Die;		// Death function
		self.ammo_cells = self.ammo_cells - #BUILD_COST_SENTRYGUN;

		setsize (oldself, '-16 -16 0', '16 16 4'); // '-16 -16 0' '16 16 4'
		newmis = spawn();
		newmis.dont_do_triggerwork = oldself.dont_do_triggerwork;
		newmis.classname = "building_sentrygun";
		newmis.flags = newmis.flags | #FL_MACHINE; // PZ
		newmis.health = #BUILD_HEALTH_SENTRYGUN;
		newmis.max_health = newmis.health;
		newmis.tf_items = #NIT_KEVLAR; //Start with kevlar armor
		newmis.armorclass = #AT_SAVESHOT; //kevlar armor
		newmis.weapon = 1;					// Level 1 Turret
		newmis.th_die = Sentry_Die; 		// Death function
		newmis.th_pain = Sentry_Pain;
		//newmis.mdl = "progs/turrgun.mdl";
		newmis.mdl = "progs/trrgn2.mdl";
		sound (oldself, #CHAN_ITEM, "weapons/turrset.wav", 1, #ATTN_NORM);
		newmis.solid = #SOLID_BBOX;
		setmodel(newmis, newmis.mdl);
		setsize (newmis, '-16 -16 0', '16 16 48'); 
		setorigin(newmis, oldself.origin + '0 0 8'); 
		newmis.real_owner = oldself.real_owner; // The Engineer owns this item
		newmis.trigger_field = oldself;
		oldself.oldenemy = newmis;
		newmis.movetype = #MOVETYPE_STEP;
		oldself.colormap = self.colormap;	// Set the Base Color
		newmis.colormap = self.colormap;	// Set the Color

		if (neo) // for Neo mode
		{	
			if (neoLives != newmis.real_owner)
				newmis.skin = 3;
			else
				newmis.skin = 0;
		}
		else newmis.skin = self.team_no - 1;

		newmis.takedamage = #DAMAGE_AIM;
		newmis.velocity = '0 0 -8';
		newmis.flags = newmis.flags - (newmis.flags & #FL_ONGROUND);
		oldself.flags = oldself.flags - (oldself.flags & #FL_ONGROUND);

		newmis.frags = 0; //CH how many people has your sent killed?
		newmis.money = 0; //WK How many frags have been spent?
		newmis.demon_blood = 0; //WK Holds our bitfield for new building upgrades

		newmis.team_no = self.team_no;
		newmis.think = lvl1_sentry_stand;
		newmis.nextthink = time + 0.5;
		newmis.touch = Sentry_Touch;
		// Rotate Details
		newmis.yaw_speed = 10;	//Turn rate
		newmis.heat = 0;	// Turn Right
		newmis.angles_x = 0;
		newmis.angles_y = ceil(oldself.angles_y); //CH remove decimal
		newmis.angles_z = 0;

		newmis.angles_y = ((ceil(newmis.angles_y / 10)) * 10); //CH set last int to 0
		
		#ifdef SENTRY_SMOOTHROTATION
		newmis.waitmin = newmis.angles_y - #SENTRY_ROTATIONWIDTH; // removed anglemod
		newmis.waitmax = newmis.angles_y + #SENTRY_ROTATIONWIDTH;
		#else
		newmis.waitmin = anglemod(newmis.angles_y - #SENTRY_ROTATIONWIDTH); 
		newmis.waitmax = anglemod(newmis.angles_y + #SENTRY_ROTATIONWIDTH); 	   
		#endif

		// Give the Gun some ammo
		newmis.ammo_shells = 75; //WK
		newmis.maxammo_shells = 100;
		newmis.maxammo_rockets = 20;

		newmis.all_active=0; // OfN - reset HACKER improvements
		newmis.is_malfunctioning = 0;
		newmis.attack_finished=time; //- controls time after loosing track of enemy to not be rotating
		newmis.has_holo=0;

		newmis.has_fieldgen = time; // resets invulnerability of attacking holos 'sindrome'

	}
	else if (oldself.weapon == #BUILD_TESLA)
	{
		//CH special sbar for eng.
		self.StatusBarScreen = 4;
		//self.has_tesla = #TRUE;
		self.has_tesla = self.has_tesla | oldself.dont_do_triggerwork;
		sprint (self, #PRINT_HIGH, "You finish building the tesla.\n");

		teamprefixsprint(self.team_no,self); //- OfN
		
		teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a tesla.\n");
		sound (oldself, #CHAN_ITEM, "weapons/guerset.wav", 1, #ATTN_NORM);
			
		oldself.classname = "building_tesla";
		oldself.netname = "tesla";
		oldself.takedamage = #DAMAGE_AIM;
		oldself.solid = #SOLID_BBOX;
		oldself.th_die = Tesla_Die; 		// Death function
		oldself.th_pain = Tesla_Pain;
		self.ammo_cells = self.ammo_cells - #BUILD_COST_TESLA;

		oldself.health = #BUILD_HEALTH_TESLA;
		oldself.movetype = #MOVETYPE_TOSS;
		oldself.colormap = self.colormap;	// Set the Base Color
		oldself.velocity = '0 0 -8';
		oldself.avelocity = '0 0 0';
		oldself.flags = oldself.flags - (oldself.flags & #FL_ONGROUND);
		oldself.team_no = self.team_no;
		
		//- OfN -
		//oldself.think = Tesla_Idle;
		oldself.think = tsla_on1;
		//oldself.nextthink = time + 2;
		oldself.nextthink = time + 0.1;
		oldself.has_holo = time + 2; // next Tesla_Idle run
		oldself.job = 0; // this flag will determine which frame animation is currently on
		//oldself.job_finished = time; // change for frame animation purposes, instead of increasing its nextthing during charging
		oldself.no_grenades_1 = #FALSE; // first think reset
		oldself.no_grenades_2 = 0; // cloak touch delay reset

		oldself.touch = Tesla_Touch;
		oldself.enemy = world;
		oldself.oldenemy = world; //CH for sbar

		//Set all initial tesla values here
		oldself.maxammo_shells = 0; //Voltage == 0
		oldself.maxammo_nails = 0; //Amps == 0
		oldself.maxammo_rockets = 0; //Battery == 0
		oldself.max_health = 150;
		oldself.ammo_cells = #MAXCELLS0; //Initial ammo allocation
		oldself.maxammo_cells = #MAXCELLS0; //Initial maxammo
		oldself.tf_items = #NIT_CERAMIC; //Start with shock armor
		oldself.armorclass = #AT_SAVEELECTRICITY; //Shock armor
		if (self.tf_items & #NIT_TESLA_UPGRADE) {
			oldself.has_sentry = 6; //Normal Upgrades
			oldself.has_tesla = 2; //Misc Upgrade
		}
		else
		{
			oldself.has_sentry = 4; //Normal Upgrades
			oldself.has_tesla = 1; //Misc Upgrade
		}
		oldself.has_teleporter = 0; //CH for frag related upgrades
		if (!(self.weapons_carried & #WEAP_SPANNER)) { //No spanner
			//WK 6/1/7 Make people that buy the tesla upgrade but no spanner get a better default tes
			if (self.tf_items & #NIT_TESLA_UPGRADE) {
				oldself.ammo_shells = 2;
				oldself.ammo_nails = 2;
				oldself.ammo_rockets = 2;
				oldself.max_health = 350; //Power Supply Level 2
				oldself.ammo_cells = #MAXCELLS2; //Initial ammo allocation
				oldself.maxammo_cells = #MAXCELLS2;
				oldself.tf_items = oldself.tf_items | #NIT_SCANNER; //Improved Targeter
				oldself.has_tesla = 1; //Misc Upgrades Left
			}
			else {
				oldself.ammo_shells = 1;
				oldself.ammo_nails = 2;
				oldself.ammo_rockets = 1;
				oldself.max_health = 200;
				oldself.ammo_cells = #MAXCELLS1; //Initial ammo allocation
				oldself.maxammo_cells = #MAXCELLS1;
			}
			oldself.has_sentry = 0; //WK
		}
		oldself.health = oldself.max_health;
		oldself.waitmin = (oldself.ammo_shells + 2) * (oldself.ammo_nails + 2);
		oldself.waitmax = #FALSE; //No target yet

		oldself.frags = 0; //CH how many people has your sent killed?
		oldself.money = 0; //WK How many building frags have you spent?
		oldself.demon_blood = 0; //WK Holds our bitfield for new building upgrades

		oldself.lip   = 0; //WK How many tinkers have been done
		modelindex_tesla = oldself.modelindex; //CH

		oldself.all_active=0; // OfN - reset HACKER improvements
		oldself.is_malfunctioning = 0;
		oldself.has_fieldgen = time;
		oldself.is_haxxxoring=0; // isnt flying
	}
	else if (oldself.weapon == #BUILD_TELEPORTER)
	{
		self.has_teleporter = (self.has_teleporter + 1);
		sprint (self, #PRINT_HIGH, "You finish building the Teleporter Pad.\n");

		teamprefixsprint(self.team_no,self); //- OfN

		teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Teleporter Pad.\n");
		sound (oldself, #CHAN_ITEM, "weapons/guerset.wav", 1, #ATTN_NORM);

		self.ammo_cells = self.ammo_cells - #BUILD_COST_TELEPORTER;

		// Create the teleporter
		oldself.classname = "building_teleporter";
		oldself.netname = "teleporter";
//		oldself.blocked = Teleporter_touch; 	// Actual touch function
		oldself.touch = Teleporter_touch;
		oldself.max_health = #BUILD_HEALTH_TELEPORTER;
		oldself.health = #BUILD_HEALTH_TELEPORTER;
		oldself.th_die = Teleporter_Die;		// Death function
		oldself.mdl = "progs/telepad.mdl";		// Actual mdl
		oldself.team_no = self.team_no;
		oldself.maxammo_cells = 200;	//CH Max of 20 teleports
		oldself.ammo_cells = 100;	//CH start not at full

		oldself.real_owner = self;			// The Engineer owns this item
		oldself.colormap = self.colormap;	// Set the Color
		oldself.takedamage = #DAMAGE_AIM;
		oldself.owner = world;
		oldself.movetype = #MOVETYPE_TOSS;
		oldself.velocity = '0 0 8';
		oldself.flags = oldself.flags - (oldself.flags & #FL_ONGROUND);

		oldself.solid = #SOLID_BBOX;
		setmodel(oldself, oldself.mdl);
		setsize (oldself, '-16 -16 0', '16 16 4');
		setorigin(oldself, oldself.origin + '0 0 8'); //CH does jump

		oldself.heat = 4; //dont come on for 4 seconds
		oldself.think = Teleporter_heat_think;
		oldself.nextthink = time + 1;
		oldself.spawnflags = 4; //CH cause extensive checks for height

		oldself.is_malfunctioning = 0;
		oldself.all_active=0; // OfN - reset HACKER improvements
	}
	else if (oldself.weapon == #BUILD_FIELDGEN)
	{
		self.has_fieldgen = (self.has_fieldgen + 1);
		sprint (self, #PRINT_HIGH, "You finish building the Field Generator.\n");

		teamprefixsprint(self.team_no,self); //- OfN

		teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Field Generator.\n");
		sound (oldself, #CHAN_ITEM, "weapons/guerset.wav", 1, #ATTN_NORM);

		self.ammo_cells = self.ammo_cells - #BUILD_COST_FIELDGEN;

		// Create the field generator
		oldself.classname = "building_fieldgen";
		oldself.netname = "field generator";
//		oldself.blocked = Teleporter_touch; 	// Actual touch function
		//oldself.touch = Teleporter_touch;
		oldself.max_health = #BUILD_HEALTH_FIELDGEN;
		oldself.health = #BUILD_HEALTH_FIELDGEN;
		oldself.th_die = FieldGen_Die;		// Death function
		oldself.mdl = "progs/ffgen2.mdl";		// Actual mdl
		oldself.team_no = self.team_no;
		
		oldself.maxammo_cells = #FIELDGEN_NUMCELLS; //CH Max of 20 field recharges
		oldself.ammo_cells = #FIELDGEN_NUMCELLS / 2;	//CH start not at full*/

		oldself.real_owner = self;			// The Engineer owns this item
		oldself.colormap = self.colormap;	// Set the Color
		oldself.takedamage = #DAMAGE_AIM;
		oldself.owner = world;
		oldself.movetype = #MOVETYPE_TOSS;
		oldself.velocity = '0 0 8';
		oldself.flags = oldself.flags - (oldself.flags & #FL_ONGROUND);

		oldself.solid = #SOLID_BBOX;

		oldself.angles = '0 0 0';

		setmodel(oldself, oldself.mdl);
		setsize (oldself, '-6 -6 0', '6 6 54');
		setorigin(oldself, oldself.origin + '0 0 8'); //CH does jump



		//oldself.heat = 4; //dont come on for 4 seconds
		/*oldself.think = Teleporter_heat_think;
		oldself.nextthink = time + 1;*/

		oldself.spawnflags = 4; //CH cause extensive checks for height

		oldself.is_malfunctioning = 0;
		oldself.all_active=0; // OfN - reset HACKER improvements

		FieldGen_Built(oldself);
	}

	// Add string flags used for earthquake and storm find()'s
	if (oldself.weapon == #BUILD_SENTRYGUN)
		UpdateVulnerability(newmis);
	else
		UpdateVulnerability(oldself);		 
	
	if (self.ammo_cells < 0)
		self.ammo_cells = 0;

	W_SetCurrentAmmo();
};

//=========================================================================
// Dispenser Touch function. Allows players to get stuff from the Dispenser.

void() T_Dispenser =
{
	local entity dist_checker;

	if (other.classname != "player")
		return;
		
	if (self.is_malfunctioning & #SCREWUP_ONE)
		return;
		
	if (self.is_malfunctioning & #SCREWUP_TWO)
		TF_T_Damage(self, self, self, 200, 0, #TF_TD_OTHER);

	// Ignore any engineer working on this dispenser
	if (other.building == world && other.building_wait < time)
	{
		// Pop up the menu
		other.current_menu = #MENU_DISPENSER;
		other.menu_count = #MENU_REFRESH_RATE;

		other.building = self;

		// Start a Distance checker, which removes the menu if the player
		// gets too far away from the Dispenser.
		dist_checker = spawn();
		dist_checker.classname = "timer";
		dist_checker.owner = other;
		dist_checker.enemy = self;
		dist_checker.think = CheckDistance;
		dist_checker.nextthink = time + 0.3;
	}
};

//============================================================
// this is needed to avoid stack overflow

void() Dispenser_Explode =
{	 
	T_RadiusDamage(self.demon_one, self.demon_one, self.has_holo, world);

	local entity sprite;

	sprite = SpawnSprite(1,#SPRITE_AIRBURST,self.demon_one.origin,'0 0 0',#SPRITEMOVE_UPSLOW,0.1);

	if (sprite)
	{
		sprite.effects = #EF_DIMLIGHT;

		if (self.demon_one.real_owner.team_no == 1)
			sprite.effects = #EF_DIMLIGHT | #EF_BLUE;
		else if (self.demon_one.real_owner.team_no == 2)
			sprite.effects = #EF_DIMLIGHT | #EF_RED;
	}

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.demon_one.origin_x);
	WriteCoord (#MSG_BROADCAST, self.demon_one.origin_y);
	WriteCoord (#MSG_BROADCAST, self.demon_one.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.demon_one.origin, #MULTICAST_PHS);
	dremove(self.demon_one);
#else
	BecomeExplosion ();
#endif

	dremove(self); // remove explosion timer for this dispenser
};

void() Dispenser_Die =
{
	local float damg;
	self.real_owner.has_dispenser = #FALSE;
	
	damg = self.ammo_cells * 0.25;
	damg = damg + self.ammo_nails * 0.1;
	damg = damg + self.ammo_shells * 0.2;
	damg = damg + self.ammo_rockets / 2;
	
	//- OfN causes overflow so we need a timer for dispenser explosion
	newmis = spawn();
	newmis.has_holo = damg;
	newmis.demon_one = self;
	newmis.nextthink = time + 0.1;
	newmis.think = Dispenser_Explode;
	/*T_RadiusDamage(self, self, damg, world); // OfN - Fixme, stack overflow??*/


	sprint(self.real_owner, #PRINT_HIGH, "Your dispenser was destroyed.\n");

	ThrowGib("progs/dgib1.mdl", -30, #TRUE, 0, 0, #FALSE);
	ThrowGib("progs/dgib2.mdl", -50, #TRUE, 0, 0, #FALSE);
	ThrowGib("progs/dgib3.mdl", -50, #TRUE, 0, 0, #FALSE);
};

//=========================================================================
// Engineer has used a Spanner on the Dispenser
void(entity disp) Engineer_UseDispenser =
{
	local entity dist_checker;
	local string st;

	// Print the dispenser's details
	sprint (self, #PRINT_HIGH, "Dispenser has ");
	st = ftos(disp.health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(disp.max_health);
	sprint(self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, " èåáìôè\n");
	st = ftos(disp.ammo_shells);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, " óèåììó, ");
	st = ftos(disp.ammo_nails);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, " îáéìó, ");
	st = ftos(disp.ammo_rockets);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, " òïãëåôó\n");
	st = ftos(disp.ammo_cells);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, " ãåììó, and ");
	st = ftos(disp.armorvalue);
	sprint (self, #PRINT_HIGH, st);
	sprint (self, #PRINT_HIGH, " áòíïò\n");

	if (disp.all_active & #IMPROVED_FOUR)
	{
		st = ftos(disp.ammo_medikit);
		sprint (self, #PRINT_HIGH, st);
		

		local float f;
		f = 1;

		if (disp.all_active & #IMPROVED_ONE)
			f = 2;
		
		sprint (self, #PRINT_HIGH, "¯");

		st = ftos(#BUILD_DISPENSER_MAX_MEDIKIT * f);
		sprint (self, #PRINT_HIGH, st);
		sprint (self, #PRINT_HIGH, " Íåäéëéô\n");
				
		st = ftos(floor(disp.ammo_detpack));
		sprint (self, #PRINT_HIGH, st);
		sprint (self, #PRINT_HIGH, " Äåôðáãëó ");

		st = ftos(floor(disp.ammo_c4det));
		sprint (self, #PRINT_HIGH, st);
		sprint (self, #PRINT_HIGH, " Ã– Äåôðáãëó\n");
	}

	// Pop up the menu
	self.current_menu = #MENU_ENGINEER_FIX_DISPENSER;
	self.menu_count = #MENU_REFRESH_RATE;

	self.building = disp;

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the Dispenser.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = disp;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};

//WK 1/15/8 Moved here from Menu.qc since whacks now autorepair/rearm guns
//Returns true if it put any ammo in at all
float() Engineer_RearmSentryGun = 
{
	local float am, healed;

	if (self.classname != "player" || self.building == world)
		return;

	healed = 0;

	// shells
	am = (#DROP_SHELLS * 2);
	if (am > self.ammo_shells)
		am = self.ammo_shells;
	if (am > (self.building.maxammo_shells - self.building.ammo_shells))
		am = (self.building.maxammo_shells - self.building.ammo_shells);
	self.ammo_shells = self.ammo_shells - am;
	self.building.ammo_shells = self.building.ammo_shells + am;

	if (am >= 1) healed = 1;

	// If it's level 3, put some rockets in too
	if (self.building.weapon >= 3)
	{
		am = (#DROP_ROCKETS * 2);
		if (am > self.ammo_rockets)
			am = self.ammo_rockets;
		if (am > (self.building.maxammo_rockets - self.building.ammo_rockets))
			am = (self.building.maxammo_rockets - self.building.ammo_rockets);
		self.ammo_rockets = self.ammo_rockets - am;
		self.building.ammo_rockets = self.building.ammo_rockets + am;
		if (am > 1) healed = 1;
	}
	return healed;
};

float() Engineer_RepairSentryGun = 
{
	local float metalcost, healed;

	if (self.classname != "player" || self.building == world)
		return;

	healed = 0;
	metalcost = (self.building.max_health - self.building.health) / 5;

	if (metalcost > self.ammo_cells)
		metalcost = self.ammo_cells;

	self.ammo_cells = self.ammo_cells - metalcost;
	self.building.health = self.building.health + (metalcost * 5);

	if (metalcost >= 1) healed = 1;
	return healed;
};

float() Engineer_RepairTesla =
{
	local float cost, totalcost;
	local float maxcells;
	cost = 0;
	if (self.building.health < self.building.max_health) //CH allow repair with limited cells
	{
		cost = (self.building.max_health - self.building.health) / 2;
		if (cost > self.ammo_cells)
			cost = self.ammo_cells;

		self.ammo_cells = self.ammo_cells - cost;
		self.building.health = self.building.health + (cost * 2);
		if (self.building.health >= self.building.max_health)
			self.building.health = self.building.max_health;
	}

	totalcost = cost;

	maxcells = self.building.maxammo_cells;

	cost = maxcells - self.building.ammo_cells;
	if (cost > self.ammo_cells) cost = self.ammo_cells;
	self.ammo_cells = self.ammo_cells - cost;
	self.building.ammo_cells = self.building.ammo_cells + cost;
	if (self.building.ammo_cells >= maxcells)
		self.building.ammo_cells = maxcells;

	totalcost = totalcost + cost;
	return totalcost;
};

//=========================================================================
// Engineer has used a Spanner on the SentryGun
void(entity gun) Engineer_UseSentryGun =
{
	local entity dist_checker;
	local float healed;
	local string st;

	self.building = gun; //Set the building we're currently operating on

	// Print the gun's details
	sprint(self, #PRINT_HIGH, "Ìåöåì ");
	st = Return_Colored_Num(gun.weapon);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " Sentry Gun has ");
	st = ftos(gun.health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(gun.max_health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " èåáìôè, ");
	st = ftos(gun.ammo_shells);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " óèåììó");
	if (gun.weapon >= 3)
	{
		st = ftos(gun.ammo_rockets);
		sprint(self, #PRINT_HIGH, ", ");
		sprint(self, #PRINT_HIGH, st);
		sprint(self, #PRINT_HIGH, " òïãëåôó");
	}
	sprint(self, #PRINT_HIGH, "\n");

	sprint(self, #PRINT_HIGH, "Sentry Gun ÆÒÁÇÓ: "); //CH Displays kills of sent
		st = ftos(gun.frags);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " ÆÒÁÇÓ spent: "); //WK We can spend gun frags now
		st = ftos(gun.money);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "\n");

	//TODO: Add in pretty print of frag upgrades we have.

	//WK 1/15/08 Auto-repair builds
	if (Teammate(self.building.real_owner, self)) {
		healed = Engineer_RearmSentryGun();
		healed = healed + Engineer_RepairSentryGun();

		//Auto-repair and auto-recharge sentries, and make sound if successful
		if (healed) { //Only make healing sound if recharged
			sprint(self, #PRINT_HIGH, "Rearmed and Repaired!\n");
			sound(self, #CHAN_ITEM, "items/r_item1.wav", 1, #ATTN_NORM);
		}
	}

	// Pop up the menu
	self.current_menu = #MENU_ENGINEER_FIX_SENTRYGUN;
	self.menu_count = #MENU_REFRESH_RATE;

	//dodgy
	if (teamplay != 0 && !Teammate(self.building.real_owner, self)) {
		Menu_EngineerFix_SentryGun_Input(5);
		return;
	}

	// - OfN - Adds 4-6 seconds of smart sentry gun targetting (no holos)
	gun.has_fieldgen = time + 4 + 2*random();
	
	if (gun.enemy.classname=="holo" && gun.enemy.has_holo == 1)
		sprint(self, #PRINT_HIGH,"You adjust the sentry gun to ignore the holo\n");
	
	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the sentry.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = gun;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};

////////////////////////////////////////////////
// Engineer has used a Spanner on the Tesla
void(entity gun) Engineer_UseTesla =
{
	local entity dist_checker;
	local string st;
	local float healed;

	self.building = gun;


	// Print the gun's details
	sprint(self, #PRINT_HIGH, "Èåáìôè:");
	st = ftos(gun.health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(gun.max_health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " Ãåììó:");
	st = ftos(gun.ammo_cells);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(gun.maxammo_cells);
	sprint(self, #PRINT_HIGH, st);
	st = ftos(gun.has_sentry);
	sprint(self, #PRINT_HIGH, " Îïòíáì Ups Left:");
	sprint(self, #PRINT_HIGH, st);
	st = ftos(gun.has_tesla);
	sprint(self, #PRINT_HIGH, " Íéóã Ups Left:");
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "\n");

	sprint(self, #PRINT_HIGH, "Öïìôáçå:");
	st = ftos(gun.ammo_shells);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " Áíðåòáçå:");
	st = ftos(gun.ammo_nails);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " Ðï÷åò Óõððìù:");
	st = ftos(gun.ammo_rockets);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "\n");
	if (gun.tf_items) {
		local float num;
		num = 0;
		if (gun.tf_items & #NIT_TURRET) {
			sprint(self, #PRINT_HIGH, "TeslaTurret(tm). ");
			num = num + 1;
		}
		if (gun.tf_items & #NIT_SCANNER) {
			sprint(self, #PRINT_HIGH, "Improved Targeter. ");
			num = num + 1;
		}
		if (gun.tf_items & #NIT_AUTOID) {
			sprint(self, #PRINT_HIGH, "Spy Detector. ");
			num = num + 1;
		}
		if (gun.tf_items & #NIT_KEVLAR) {
			sprint(self, #PRINT_HIGH, "Kevlar Armor. ");
			num = num + 1;
		}
		if (gun.tf_items & #NIT_BLAST) {
			sprint(self, #PRINT_HIGH, "Blast Armor. ");
			num = num + 1;
		}
		if (gun.tf_items & #NIT_ASBESTOS) {
			sprint(self, #PRINT_HIGH, "Asbestos Armor. ");
			num = num + 1;
		}
		if (gun.tf_items & #NIT_TELEPORTER) {
			sprint(self, #PRINT_HIGH, "Upgrades from frags. ");
			num = num + 1;
		}
		if (gun.tf_items & #NIT_TESLA_CLOAKING) {
			sprint(self, #PRINT_HIGH, "Cloaking Device. ");
			num = num + 1;
		}
		if (num != 0)
			sprint(self, #PRINT_HIGH, "\n");
	}

	sprint(self, #PRINT_HIGH, "Tesla Sentry ÆÒÁÇÓ: "); //CH Displays kills of tesla
		st = ftos(gun.frags);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " ÆÒÁÇÓ Spent: "); //WK We can spend frags now
		st = ftos(gun.money);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "\n");

	//WK 1/15/08 Auto-repair builds
	if (Teammate(self.building.real_owner, self)) {
		healed = Engineer_RepairTesla();

		//Auto-repair and auto-recharge teslas, and make sound if successful
		if (healed) { //Only make healing sound if recharged
			sprint(self, #PRINT_HIGH, "Recharged and Repaired!\n");
			sound(self, #CHAN_ITEM, "items/r_item1.wav", 1, #ATTN_NORM);
		}
	}

	// Pop up the menu
	self.current_menu = #MENU_ENGINEER_FIX_TESLA;
	self.menu_count = #MENU_REFRESH_RATE;

	// dodgy
	if (teamplay != 0 && !Teammate(self.building.real_owner, self)) {
		Menu_EngineerFix_Tesla_Input(8);
		return;
	}

	// - OfN - Adds 6-9 seconds of smart tesla targetting (no holos)
	gun.has_fieldgen = time + 6 + 3*random();
		
	if (gun.enemy.classname == "holo" && gun.enemy.has_holo == 1)
	{		 
		sprint(self, #PRINT_HIGH,"You adjust the tesla sentry to ignore the holo\n");
	}

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the tesla.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = gun;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;
};
//=================
void(entity cam) Engineer_UseSensor =
{
	local entity dist_checker;
	local string st;

	sprint(self, #PRINT_HIGH, "Motion Sensor has ");
	st = ftos(cam.health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(ceil(cam.max_health));
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " èåáìôè\n");

	// Pop up the menu
	self.current_menu = #MENU_ENGINEER_FIX_SENSOR;
	self.menu_count = #MENU_REFRESH_RATE;

	self.building = cam;

	if (teamplay != 0 && !Teammate(self.building.real_owner, self)) {
		Menu_EngineerFix_Sensor_Input(3);
		return;
	}

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the camera.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = cam;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;

};
//=================
void(entity cam) Engineer_UseCamera =
{
	local entity dist_checker;
	local string st;

	sprint(self, #PRINT_HIGH, "Security Camera has ");
	st = ftos(cam.health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(ceil(cam.max_health));
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " èåáìôè\n");

	// Pop up the menu
	self.current_menu = #MENU_ENGINEER_FIX_CAMERA;
	self.menu_count = #MENU_REFRESH_RATE;

	self.building = cam;

	if (teamplay != 0 && !Teammate(self.building.real_owner, self)) {
		Menu_EngineerFix_Camera_Input(3);
		return;
	}

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the camera.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = cam;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;

};
//=================
void(entity tele) Engineer_UseTeleporter =
{
	local entity dist_checker;
	local string st;

	sprint(self, #PRINT_HIGH, "Teleporter Pad has ");
	st = ftos(tele.health);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(ceil(tele.max_health));
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " èåáìôè  ");
	st = ftos(tele.ammo_cells);
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, "¯");
	st = ftos(ceil(tele.maxammo_cells));
	sprint(self, #PRINT_HIGH, st);
	sprint(self, #PRINT_HIGH, " ãåììó\n");


	// Pop up the menu
	self.current_menu = #MENU_ENGINEER_FIX_TELEPORTER;
	self.menu_count = #MENU_REFRESH_RATE;

	self.building = tele;

	if (teamplay != 0 && !Teammate(self.building.real_owner, self)) {
		Menu_EngineerFix_Teleporter_Input(4);
		return;
	}

	// Start a Distance checker, which removes the menu if the player
	// gets too far away from the teleporter.
	dist_checker = spawn();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = tele;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = time + 0.3;

};
//=========================================================================
// Think function for the timer which checks the distance between the 
// Engineer and the building he's using
void() CheckDistance =
{
	local vector dist;
	
	// Check to see if the Engineer's spanner'ed a different building 
	// without leaving the area of this one.
	if (self.owner.building != self.enemy)
	{
		dremove(self);
		return;
	}

	dist = self.enemy.origin - self.owner.origin;
//WK	if (vlen(dist) > 64)
	if (vlen(dist) > 98)
	{
		CenterPrint(self.owner, "\n");
		self.owner.menu_count = #MENU_REFRESH_RATE;
		self.owner.current_menu = #MENU_DEFAULT;
		self.owner.building = world;
		dremove(self);
		return;
	}

	self.nextthink = time + 0.3;
};

