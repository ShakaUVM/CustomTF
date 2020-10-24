/*======================================================
	SNIPER.QC

	TeamFortress v2.5	 29/2/97
========================================================
Functions for the SNIPER class and associated weaponry							
========================================================*/
// Functions outside this file

// Functions inside this file
void() TeamFortress_SniperWeapon;
// Autozoom functions
void(float zoom_level) TF_zoom;
void() SniperSight_Update;
void() SniperSight_Update2;
void(float type) SniperSight_Create;
void(entity targ, float pain) RevealThief;

//=========================================================================
// Sniper/Auto Rifle selection function
void() TeamFortress_SniperWeapon =
{
	//local float	it;
	
	self.impulse = 0;

	if (self.tfstate & #TFSTATE_RELOADING)
		return;

	if (!((self.weapons_carried & #WEAP_SNIPER_RIFLE) && (self.weapons_carried & #WEAP_AUTO_RIFLE)))
		return;

	if (self.ammo_shells < 1)
	{	// don't have the ammo
		sprint (self, #PRINT_HIGH, "Not enough ammo.\n");
		return;
	}

	if (self.current_weapon == #WEAP_SNIPER_RIFLE)
	{
		self.current_weapon = #WEAP_AUTO_RIFLE;
	}
	else
	{
		self.current_weapon = #WEAP_SNIPER_RIFLE;
	}

	W_SetCurrentAmmo ();
};

//=========================================================================
// Do the autozoom of the sniper rifle
void(float zoom_level) TF_zoom =
{
	local string zl;
	
	if (self.tfstate & #TFSTATE_ZOOMOFF)
		return;

	zl = ftos(zoom_level);

	stuffcmd(self, "fov ");
	stuffcmd(self, zl);
	stuffcmd(self, "\n");
};


//=========================================================================
// Move the sight to the point the rifle's aiming at
void() SniperSight_Update =
{
	local vector org;
	local float dist;

	if (!(self.owner.tfstate & #TFSTATE_AIMING) || (self.owner.current_weapon != #WEAP_SNIPER_RIFLE) || !(self.owner.button0))
	{
		self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_AIMING);
		TeamFortress_SetSpeed(self.owner);
		self.owner.heat = 0;
		dremove(self);
		return;
	}

	makevectors(self.owner.v_angle);

	org = self.owner.origin + v_forward*10;
	org_z = self.owner.absmin_z + self.owner.size_z * 0.7;

	//WK 6/1/7 Have laser dot now accurately show max range for sniper shots
	//Was 9192, now is 8092, or 8092 * 1.3 if having long barrel.
	dist = #WEAP_SNIPER_MAX_RANGE;
	if (self.owner.cutf2_items & #CUTF2_LONG_BARREL)
		dist = dist * #CUTF2_LONG_BARREL_RANGE_FACTOR;

	traceline(org, org + v_forward*dist, #TL_ANY_SOLID, self);

	if (trace_fraction == 1.0)
	{
		setorigin(self, self.owner.origin );
		return;
	}

	self.angles = vectoangles(v_forward);
	setorigin(self, trace_endpos);

	#ifdef SNIPERSIGHT_SHOWPOS
	local string st;
	st = vtos(trace_endpos);
	sprint(self.owner,#PRINT_HIGH,"Sniper dot pos: ",st,"\n");
	#endif

	self.nextthink = time + 0.1;
};
//CH used for the rl
void() SniperSight_Update2 =
{
	//bprint(#PRINT_HIGH, "Sight Think..\n");
	local vector org;
	local float dist;

	if (!(self.owner.tfstate & #TFSTATE_RL_LASER) || !(self.owner.current_weapon & (#WEAP_ROCKET_LAUNCHER | #WEAP_INCENDIARY | #WEAP_DAEDALUS)) || !(self.owner.button0))
	{
		self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_RL_LASER);
		TeamFortress_SetSpeed(self.owner);
		self.owner.heat = 0;
		dremove(self);
		return;
	}

	makevectors(self.owner.v_angle);

	org = self.owner.origin + v_forward*10;
	org_z = self.owner.absmin_z + self.owner.size_z * 0.7;

	//WK 6/1/7 Make laser guideds match max sniper range
	//Was 9192, now is 8092, or 8092 * 1.3 if having long barrel.
	//In this case, long_barrel means you have a better scope on your RL. =)
	dist = #WEAP_SNIPER_MAX_RANGE;
	if (self.owner.cutf2_items & #CUTF2_LONG_BARREL)
		dist = dist * #CUTF2_LONG_BARREL_RANGE_FACTOR;

	traceline(org, org + v_forward*dist, #TL_ANY_SOLID, self);

	if (trace_fraction == 1.0)
	{
		setorigin(self, self.owner.origin );
		return;
	}

	self.angles = vectoangles(v_forward);
	setorigin(self, trace_endpos);

	self.nextthink = time + 0.1;
};

//=========================================================================
// Create the sight
//CH type 1 = rl
void(float type) SniperSight_Create =
{
	local entity sight;
	if (type == 1)
		self.tfstate = self.tfstate | #TFSTATE_RL_LASER;
	else
		self.tfstate = self.tfstate | #TFSTATE_AIMING;

	sight = spawn ();
	sight.owner = self;
	sight.movetype = #MOVETYPE_NOCLIP;
	sight.solid = #SOLID_NOT;

	if (megatf & #MEGATF_SIGHTS)
	{
		setmodel (sight, "progs/colsight.spr");
		sight.frame = self.team_no - 1;
	}
	else
		setmodel (sight, "progs/sight.spr");

	sight.classname = "timer";
	sight.netname = "sniperdot"; // OfN

	setorigin(sight, self.origin);
	if (type == 1)
		sight.think = SniperSight_Update2;
	else
		sight.think = SniperSight_Update;
	sight.nextthink = time + 0.05;

	// Prevent theif snipers.
	if (self.job & #JOB_THIEF && (self.job & #JOB_ACTIVE || self.job & #JOB_FULL_HIDE))
		RevealThief(self,#FALSE);
};

// this toggles the snipers autozoom on/off
void() TeamFortress_AutoZoomToggle =
{
	if (self.tfstate & #TFSTATE_ZOOMOFF)
	{
		self.tfstate = self.tfstate - #TFSTATE_ZOOMOFF;
		sprint(self, #PRINT_HIGH, "autozoom ON\n");
	}
	else
	{
		self.tfstate = self.tfstate | #TFSTATE_ZOOMOFF;
		sprint(self, #PRINT_HIGH, "autozoom OFF\n");
	}

};



//=========================================================================
