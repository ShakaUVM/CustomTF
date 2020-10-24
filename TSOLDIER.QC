/*======================================================
	TSOLDIER.QC

	TeamFortress v2.5	 29/2/97
========================================================
Functions for the SOLDIER class and associated weaponry 						 
========================================================*/
// Functions outside this file

// Functions inside this file
// Nail Grenade Functions
void() NailGrenadeTouch;
void() NailGrenadeExplode;
void() NailGrenadeNailEm;
void() NailGrenadeLaunchNail;

//=========================================================================
// Touch Function for Nail Grenade
void() NailGrenadeTouch =
{
	if (other == self.owner)
		return; 	// don't explode on owner

	// If the Nail Grenade hits a player, it just bounces off

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//=========================================================================
// Explode Function for Nail Grenade
void() NailGrenadeExplode =
{
	// Raise into the air
	self.movetype = #MOVETYPE_FLY;

	setorigin(self, self.origin + '0 0 32');
	self.avelocity = '0 500 0';

	self.nextthink = time + 0.7;
	self.think = NailGrenadeNailEm;
};

//=========================================================================
// Nail function for Nail Grenade
void() NailGrenadeNailEm =
{
	// Rotate and spew Nails
	self.velocity = '0 0 0';

	self.nextthink = time + 0.1;
	self.think = NailGrenadeLaunchNail;
	self.playerclass = 0;
};

//=========================================================================
// Nail function for Nail Grenade
void() NailGrenadeLaunchNail =
{
	local float i,j;
	local float current_yaw;

	i = 0;
#ifdef QUAKEWORLD
	while (i < 1)	// Only throw one nail in QW... a big one :)
#else
	while (i < 3)
#endif
	{
		j = (random() + 2) * 5;
		current_yaw = anglemod(self.angles_y + j);
		self.angles_y = current_yaw;
		self.angles_x = 0;
		self.angles_z = 0;
		makevectors(self.angles);
	
		#ifdef OLD_NAILGREN
		deathmsg = #DMSG_GREN_NAIL;
		launch_spike(self.origin, v_forward);
		newmis.touch = spike_touch;
		newmis.weapon = #DMSG_GREN_NAIL;
		#else
		if (random() < 0.33)
			MuzzleFlash(self);
		launch_directspike(self.origin, v_forward);
		#endif

		i = i + 1;
	}

	self.playerclass = self.playerclass + 1;
	self.nextthink = time + 0.1;

	// Explode 
	if (self.playerclass > 50)
	{
		self.weapon = #DMSG_GREN_NAIL;
		self.think = GrenadeExplode;
	}
};
