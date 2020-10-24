/*======================================================
	TELEPORT.QC 		Custom TeamFortress v2.2

	(c) Craig Hauser			23/3/00
========================================================
Functions for the teleporters
======================================================*/

void() Teleporter_touch;
void() Teleporter_Die;
void() Teleporter_heat_think;
float(entity targ) Teleporter_check_person;

//- OfN
float(entity player) IsOutWorld;

#define TELEPORTER_CELLS	8 //How many cells to use on teleport
#define TELEPORTER_WAIT 	2  //How long to wait after teleport (whole number)

//====================
void() Teleporter_touch =
{
	local entity te;

	if (self.heat == 0)
	{
		if (Teleporter_check_person(other))
		{
			te = find(world, classname, "building_teleporter");
			while (!(te.real_owner == self.real_owner && te != self) && te != world)
			{
				te = find(te, classname, "building_teleporter");
			}
			if (te != world)
			{
				local vector vec;
				vec = '0 0 32';

				if (te.tf_items & #NIT_TURRET) //- OfN turretized teleporters
					vec = '0 0 -40';
				
				if (te.heat == 0 && te.ammo_cells >= #TELEPORTER_CELLS)
				{
					self.heat = #TELEPORTER_WAIT;
					te.heat = #TELEPORTER_WAIT;
					if (self.is_malfunctioning & #SCREWUP_FOUR || te.is_malfunctioning & #SCREWUP_FOUR)
					{
						CenterPrint(other, "The other teleporter is out of power.\n");
						return;
					}
					
					self.ammo_cells = self.ammo_cells - #TELEPORTER_CELLS;
					te.ammo_cells = te.ammo_cells - #TELEPORTER_CELLS;

					local entity ote;
					ote = te;
					if (self.is_malfunctioning & #SCREWUP_THREE || te.is_malfunctioning & #SCREWUP_THREE) //sb
					{
						te = self.real_owner;
						spawn_tdeath(te.origin + vec, te);
					}
					spawn_tfog (other.origin);
					spawn_tdeath(te.origin + vec, other);
					makeImmune(other,time + 2);
					setorigin(other, te.origin + vec);
					//- OfN
					if (IsOutWorld(other))
					{
						deathmsg = #DMSG_TELEOUTWORLD;
						TF_T_Damage(other, other, other,1000,0,#TF_TD_OTHER);
						return;
					}
					
					if (self.is_malfunctioning & #SCREWUP_ONE || te.is_malfunctioning & #SCREWUP_ONE) // SB
					{
						other.ammo_cells = 0;
						other.ammo_shells = 0;
						other.ammo_nails = 0;
						other.ammo_rockets = 0;
						other.armorvalue = 0;
						other.ammo_detpack = 0;
						other.ammo_c4det = 0;
						other.ammo_medikit = 0;
					}
					if (self.is_malfunctioning & #SCREWUP_TWO || te.is_malfunctioning & #SCREWUP_TWO) // SB
					{
						if (self.is_malfunctioning & #SCREWUP_TWO)
							te.martyr_enemy = self.martyr_enemy;
						else if (te.is_malfunctioning & #SCREWUP_TWO)
							self.martyr_enemy = te.martyr_enemy;
						TF_T_Damage(other, self, self, 500, 0, #TF_TD_OTHER);
					}
					spawn_tfog (te.origin + vec);
					if (self.is_malfunctioning & #SCREWUP_THREE || ote.is_malfunctioning & #SCREWUP_THREE)
						te = ote;
					if ((te.ammo_cells >= #TELEPORTER_CELLS && te.ammo_cells <= #TELEPORTER_CELLS * 2) || (self.ammo_cells >= #TELEPORTER_CELLS && self.ammo_cells <= #TELEPORTER_CELLS * 2))
						sprint (self.real_owner, #PRINT_HIGH, "A teleporter is getting low on power.\n");
				}
				else if (te.ammo_cells < #TELEPORTER_CELLS)
					CenterPrint(other, "The other teleporter is out of power.\n");
			}
		}
	}

	if (other == world && self.tf_items & #NIT_TURRET && !(self.flags & #FL_ONGROUND)) 
	{ //The tele has landed! //- needed?
		sprint(self.real_owner, #PRINT_HIGH, "Teleporter turretized succesfully!\n");
		self.solid = #SOLID_BBOX; //#SOLID_BBOX;//SOLID_SLIDEBOX// SOLID_TRIGGER
		self.flags = self.flags | #FL_ONGROUND;
	   // setsize(self, self.mins, self.maxs);
		//self.movetype = #MOVETYPE_STEP;
		self.origin_z = self.origin_z + 46;//32; // was 40, old custom bug? fixed
		setorigin(self,self.origin);

		self.velocity = '0 0 0';
		//setsize (self.building, '-16 -16 -48', '16 16 -52');
		//setsize (self.building, '-16 -16 0', '16 16 1');
		//return;
	}

	/*if (other.solid == #SOLID_BSP && self.tf_items & #NIT_TURRET && !(self.flags & #FL_ONGROUND))
	{
		sprint(self.real_owner, #PRINT_HIGH, "Teleporter turretized succesfully!\n");
		self.solid = #SOLID_TRIGGER; //#SOLID_BBOX;//SOLID_SLIDEBOX// SOLID_TRIGGER
		self.flags = self.flags | #FL_ONGROUND; //MOVETYPE_NONE
		self.movetype = #MOVETYPE_NONE;
		self.origin_z = self.origin_z + 8;//32; // was 40, old custom bug? fixed
		//setsize (self.building, '-16 -16 -48', '16 16 -52');
		//setsize (self.building, '-16 -16 -0', '16 16 -4');
		//return;
	}*/


};
//===============
float(entity targ) Teleporter_check_person =
{
	if (self.ammo_cells < #TELEPORTER_CELLS) {
		if (Teammate(targ, self)) //only to team member
			CenterPrint(other, "This teleporter is out of power.\n");
		return #FALSE;
	}
	if (self.real_owner.has_teleporter == 1) {
		if (Teammate(targ, self)) //only to team member
			CenterPrint(other, "There is no other teleporter!\n");
		return #FALSE;
	}
#ifdef QUAKE_WORLD // culled by KK. was QUAKE_WORLD
	/*if (infokey(world,"ceasefire")=="on") //To not cause loops
		return #FALSE;*/
	if (ceasefire)
		return #FALSE;
#endif
	if (targ == world)//that would be bad.
		return #FALSE;
	if (targ.done_custom & #CUSTOM_BUILDING)
		return #FALSE;
	if (targ.classname != "player")
		return #FALSE;
	if (targ.velocity != '0 0 0')
		return #FALSE;
	if (targ.health <= 0)
		return #FALSE;
	if (!targ.is_connected)
		return #FALSE;
	if (targ.playerclass == #PC_UNDEFINED)
		return #FALSE;
	if (targ.is_feigning)
		return #FALSE;
	if (targ.is_building)
		return #FALSE;
	if (targ.is_detpacking)
		return #FALSE;
	if (targ.playerclass == #PC_CIVILIAN) {
		CenterPrint(targ, "Civilian + Teleporter = No, NFC!\n");
		return #FALSE;
	}
	if (targ.effects & (#EF_BRIGHTLIGHT | #EF_DIMLIGHT | #EF_BRIGHTFIELD)) {//no flag for you!
		CenterPrint(targ, "Can't use teleporter while glowing!\n");
		return #FALSE;
	}

//ALL NEW CHECKS _MUST_ BE ABOVE THIS LINE

	if (teamplay)
	{
		if (Teammate(targ, self))
			return #TRUE;

		temp_e.team_no = targ.undercover_team; // for Neo mode (modified Teammate())
		if (Teammate(temp_e, self))
		{
			return #TRUE;
		}
	}
	else
		return #TRUE;

	return #FALSE;
};
//===============
void() Teleporter_heat_think =
{
	//- OfN turretizing and stoped?
	if (self.tf_items & #NIT_TURRET && !(self.flags & #FL_ONGROUND))
		self.velocity_z = 200;

//CH used to reduce the heat and check pos
	local float pos, num;
	local vector loc;

	if (self.heat <= 0)
		self.heat = 0;
	else
		self.heat = self.heat - 1;

	self.think = Teleporter_heat_think; //keep in loop
	self.nextthink = time + 1;

//CH if spawnflags is >0 do extensive height checks b/c the pad just spawned.
	if (self.spawnflags > 0) {
		self.spawnflags = self.spawnflags - 1;
		num = 0; //16 checks
	}
	else
		num = 15; //1 check
	while (num < 16)
	{
		//sprint (self.real_owner, #PRINT_HIGH, "Checking space!\n");
		loc = self.origin;
		loc_z = loc_z + (rint(random() * 8 + 1) * 8); //1-8 * 8  x+8 -> x+64
		loc_x = loc_x + ((rint(random() * 3 + 1) * 16) - 32);
		loc_y = loc_y + ((rint(random() * 3 + 1) * 16) - 32);

		pos = pointcontents(loc);					   //-
		if ( ( (pos == #CONTENT_SOLID || pos == #CONTENT_SKY) && !self.tf_items & #NIT_TURRET) || (self.tf_items & #NIT_TURRET && pos == #CONTENT_SKY) )
		{
			TF_T_Damage(self, world, world, self.health+1, 0, 0);
			
			if (self.tf_items & #NIT_TURRET) //- ofn
				sprint (self.real_owner, #PRINT_HIGH, "Your teleporter flies away.\n");
			else
				sprint (self.real_owner, #PRINT_HIGH, "Not enough space for teleportation.\n");
			
			num = 100; //Get out of loop
		}
		num = num + 1;
	}
	
};
//================
void() Teleporter_Die =
{
	sprint(self.real_owner, #PRINT_HIGH, "Your Teleporter Pad was destroyed.\n");
	self.real_owner.has_teleporter = (self.real_owner.has_teleporter - 1);

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
