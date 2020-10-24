/*======================================================
	SENTRY.QC			Custom TeamFortress v2.1	

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney			21/10/99
	(c) Craig Hauser				19/3/00
========================================================
Weapons and functions for the Sentry Guns
======================================================*/
// This is a temporary hack... they'll be replaced with real bots when
// the bot code is in (should that be if? :)
// WK If is right. :)
// SentryGun AI Functions
void() Sentry_Rotate;
float() Sentry_FindTarget;
void() Sentry_FoundTarget;
void() Sentry_HuntTarget;
void() Sentry_Pain;
void() Sentry_Die;
float() Sentry_Fire;
//WK - Will kill enemies on touch, and adds support for flying.
void() Sentry_Touch;

// OfN
//float(entity gun) IsInValidLocation;

/* WK==============================================
#ifndef #COOP_MODE
void() ai_face =
{
	local vector temp_vect,temp_ang;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = anglemod(self.ideal_yaw);
	//WK Turrets swivel instanter
	if (self.tf_items & #NIT_TURRET) { //Auto-swivel
		self.angles_y = self.ideal_yaw;
	}
	else
		ChangeYaw ();
};
#endif
*/
//==============================================
$cd /quake/fortress/progs/turrgun
$origin 0 -6 24
$base base		
$skin skin

$frame lvl1_stand1
$frame lvl1_shoot1 lvl1_shoot2 
$frame lvl2_stand1
$frame lvl2_shoot1 lvl2_shoot2 
$frame lvl3_stand1
$frame lvl3_shoot1 lvl3_shoot2 

/*	  WK -- This is how you unhack the turret's position :Þ
	if (self.tf_items & #NIT_TURRET) self.origin_z = self.origin_z + 40;
*/

void() RemoveGlow = {
	self.effects = self.effects - (self.effects & #EF_DIMLIGHT);
};

//===========================
// Level 1 Sentry Gun Frames
void()	lvl1_sentry_atk3;
void()	lvl1_sentry_stand =[ $lvl1_stand1,	lvl1_sentry_stand ] {RemoveGlow(); Sentry_Rotate();};
void()	lvl1_sentry_atk1 =[ $lvl1_shoot1,	lvl1_sentry_atk3 ] 
{
	ai_face();
	if (self.enemy == world || (self.has_fieldgen > time && self.enemy.classname == "holo") || ((self.enemy.health <= 0 && self.enemy.classname!="holo") || (self.enemy.has_holo == 0 && self.enemy.classname == "holo")) || /* !visible(self.enemy) || */ self.enemy.is_connected == #FALSE) //CH
		lvl1_sentry_stand();
	else if (self.ammo_shells <= 0)
		lvl1_sentry_stand();
	else if (Sentry_Fire() == #FALSE)
		//WK lvl1_sentry_atk3();
		lvl1_sentry_stand();
};
void()	lvl1_sentry_atk2 =[ $lvl1_shoot2,	lvl1_sentry_atk3 ]
{
	ai_face();
	Sentry_Fire();
};
void()	lvl1_sentry_atk3 =[ $lvl1_stand1,	lvl1_sentry_atk1 ]	{ai_face();};

//===========================
// Level 2 Sentry Gun Frames
void()	lvl2_sentry_atk3;
void()	lvl2_sentry_stand=	[  $lvl2_stand1,	lvl2_sentry_stand ] {RemoveGlow(); Sentry_Rotate();};
void()	lvl2_sentry_atk1 =	[	$lvl2_shoot1,	lvl2_sentry_atk2	] 
{
	ai_face();
	if (self.enemy == world || (self.has_fieldgen > time && self.enemy.classname == "holo") || ((self.enemy.health <= 0 && self.enemy.classname!="holo") || (self.enemy.has_holo == 0 && self.enemy.classname == "holo")) || /* !visible(self.enemy) || */ self.enemy.is_connected == #FALSE) //CH
		lvl2_sentry_stand();
	else if (self.ammo_shells <= 0)
		lvl2_sentry_stand();
	else if (Sentry_Fire() == #FALSE)
		//WK lvl2_sentry_atk3();
		lvl2_sentry_stand();
};
void()	lvl2_sentry_atk2	=[	$lvl2_shoot2,	lvl2_sentry_atk3	] 
{
	ai_face();
	Sentry_Fire();
};
void()	lvl2_sentry_atk3 =[ $lvl2_stand1,	lvl2_sentry_atk1 ]
{
	ai_face(); 
	Sentry_Fire();
};

//===========================
// Level 3 Sentry Gun Frames
void()	lvl3_sentry_atk3;
void()	lvl3_sentry_atk4;
void()	lvl3_sentry_stand=	[	$lvl3_stand1,	lvl3_sentry_stand ] {RemoveGlow(); Sentry_Rotate();};
void()	lvl3_sentry_atk1 =	[	$lvl3_shoot1,	lvl3_sentry_atk2  ] 
{
	ai_face();
	if (self.enemy == world || (self.has_fieldgen > time && self.enemy.classname == "holo") || ((self.enemy.health <= 0 && self.enemy.classname!="holo") || (self.enemy.has_holo == 0 && self.enemy.classname == "holo")) || /* !visible(self.enemy) || */ self.enemy.is_connected == #FALSE) //CH
		lvl3_sentry_stand();
	else if (self.ammo_shells <= 0 && self.ammo_rockets <= 0)
		lvl3_sentry_stand();
	else if (self.ammo_shells <= 0 && self.ammo_rockets > 0) //CH rocket check
	{
		RemoveGlow();
		lvl3_sentry_atk4();
	}
	else if (Sentry_Fire() == #FALSE)
		//WK lvl3_sentry_atk3();
		lvl3_sentry_stand();
};
void()	lvl3_sentry_atk2 =[ $lvl3_shoot2,	lvl3_sentry_atk3	] 
{
	ai_face();
	Sentry_Fire();
};
void()	lvl3_sentry_atk3 =[ $lvl3_stand1,	lvl3_sentry_atk1	] 
{
	ai_face(); 
	Sentry_Fire();
};
void()	lvl3_sentry_atk4 =	[	$lvl3_stand1,	lvl3_sentry_atk5  ] 
{
	ai_face();
	if (self.enemy == world || (self.has_fieldgen > time && self.enemy.classname == "holo") || ((self.enemy.health <= 0 && self.enemy.classname!="holo") || (self.enemy.has_holo == 0 && self.enemy.classname == "holo")) || /* !visible(self.enemy) || */ self.enemy.is_connected == #FALSE) //CH
		lvl3_sentry_stand();
	else if (self.ammo_shells <= 0 && self.ammo_rockets <= 0)
		lvl3_sentry_stand();
	else if (Sentry_Fire() == #FALSE)
		//WK lvl3_sentry_atk3();
		lvl3_sentry_stand();
};
void()	lvl3_sentry_atk5 =[ $lvl3_stand1,	lvl3_sentry_atk4	] 
{
	ai_face(); 
	Sentry_Fire();
};

//=============
void() Sentry_Rotate =
{
/*	local string st;
	local float blah;*/

	#ifdef FIXES_FOR_FLOATINGBUILDS
	/* TODO:
	
	if (!(self.tf_items & #NIT_TURRET))
	//if (!(self.flags & #FL_ONGROUND))
	{
		self.flags = self.flags - (self.flags & #FL_ONGROUND);
		self.velocity_z = -80;
	}*/
	#endif

	if (self.is_malfunctioning & #SCREWUP_ONE)
	{
		self.ideal_yaw = self.ideal_yaw + 10;
		ChangeYaw();
		return;
	}

	/*if (!IsInValidLocation(self))
		Sentry_Die();*/

	if (Sentry_FindTarget())
		return;

	//- OfN this does the sentry to not return to rotate status after enemy becomes not visible or died
	// it doesn't alter the real behaviour only the look
	if (self.attack_finished > time)
	{
		self.has_holo=1;
		return;
	}

	if (self.has_holo==1)
	{
		self.has_holo=0;
		sound (self, #CHAN_ITEM, "weapons/trr2lost.wav", 0.25, #ATTN_NORM); 	   
	}
	
	#ifdef SENTRY_SMOOTHROTATION
	
	if (self.heat > #SENTRY_ROTATIONSTEPS - 1)
		self.heat = 0;

	local float f3;

	// Standard sine
	f3 = getwave(self.heat/#SENTRY_ROTATIONSTEPS,#GWAVE_USEMINMAX,self.waitmin,self.waitmax,0,0,0);
	
	// Alternative (more circular wave instead of a pure sine)
	//f3 = getwave(self.heat/#SENTRY_ROTATIONSTEPS,#GWAVE_USEMINMAX | #GWAVE_USESHAPE,self.waitmin,self.waitmax,0,0,0.4);
	
	self.angles_y = anglemod(f3);
	
	if (self.heat == #SENTRY_ROTATIONSTEPS - 1)
	if (random() < 0.1)
		sound (self, #CHAN_ITEM, "weapons/turridle.wav", 1, #ATTN_NORM);

	self.heat = self.heat + 1;

	#else // SENTRY_SMOOTHROTATION

	if (self.heat == 0)
	{
		self.ideal_yaw = anglemod(self.waitmin);
		ChangeYaw();
		
		if ((anglemod(self.angles_y) <= (self.waitmin + 1)) && (anglemod(self.angles_y) >= (self.waitmin - 2)))  //CH after the && fixed spaz sent!!
		{
			self.heat = 1;
			if (random() < 0.1)
				sound (self, #CHAN_ITEM, "weapons/turridle.wav", 1, #ATTN_NORM);
		}
	}
	else
	{
		self.ideal_yaw = anglemod(self.waitmax);
		ChangeYaw();

		if ((anglemod(self.angles_y) >= (self.waitmax - 1 )) && (anglemod(self.angles_y) <= (self.waitmax + 2)))  //CH after the && fixed spaz sent!!
			self.heat = 0;
	}
	#endif // SENTRY_SMOOTHROTATION
};

//====================================================================
// new RANGE_VERYFAR hacked sentries can shot at RANGE_FAR

float(entity targ) rangesentry =
{
	local vector	spot1, spot2;
	local float 	r;	

	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	
	r = vlen (spot1 - spot2);
	if (r < 120)
		return #RANGE_MELEE;
	if (r < 500)
		return #RANGE_NEAR;
	if (r < 1000)
		return #RANGE_MID;
	if (r < 2000)
		return #RANGE_FAR;
	return #RANGE_VERYFAR;
};


float() Sentry_FindTarget =
{
	#ifdef MAD_SENTRY

	self.enemy = world; 

	if (!(self.tf_items & #NIT_TURRET))
	{
		if (!visible2x(self,self.real_owner))
			return #FALSE;
	}
	else
	{
		if (!visible2(self,self.real_owner))
			return #FALSE;
	}

	self.enemy = self.real_owner;

	
		Sentry_FoundTarget ();
   

	return #TRUE;
	#endif	  
	
	self.enemy = world; //CH for sbar

#ifdef QUAKE_WORLD // culled by KK. was QUAKE_WORLD
	/*if (infokey(world,"ceasefire")=="on")
		return #FALSE;*/
	if (ceasefire)
		return #FALSE;
#endif
	
	local entity client;
	local float r, gotone, loopc;

	//WK Hack to get floating sentry working
	if (self.tf_items & #NIT_TURRET) {
		self.origin_z = self.origin_z - 40;
	}

	// Try a few checks to make it react faster
	r = 0;
	loopc = 0;
	gotone = #FALSE;
	//WK Theortetically this will check every client on the server now
	while (loopc < 32 && gotone == #FALSE) //WK 3
	{
		client = checkclient();

		gotone = #TRUE;

		if (!client)
			gotone = #FALSE;

		if (!Pharse_Client(client, self, 1, 0, 0, 1))
			gotone = #FALSE;

		r = rangesentry (client);

		//- ofn
		//if (r == #RANGE_FAR)
		//	gotone = #FALSE;			
	
		//WK Hack, turret should be able to see in all directions...
		if (!(self.tf_items & #NIT_TURRET)) {

			if (r == #RANGE_NEAR)
			{
				if (client.show_hostile < time && !infront (client))
					gotone = #FALSE;
			}
			else if (r == #RANGE_MID)
			{
				if (!infront (client))
					gotone = #FALSE;
			}
			else if (r == #RANGE_FAR) //- OfN - Sentries with enhanced circuits can shot at far range
			{
				if (!(self.all_active & #IMPROVED_FOUR) || !infront (client))
					gotone = #FALSE;
			}
		}
		else //- OfN - a turretized sentry gun... 
		{
			if (r == #RANGE_FAR && !(self.all_active & #IMPROVED_FOUR))
				gotone = #FALSE;
		}

		//- OfN ----------------//
		if (r == #RANGE_VERYFAR)
			gotone = #FALSE;
		//----------------------//

		loopc = loopc + 1;
		//WK Solve a bug in sentry targetting?
		if (gotone) loopc = 1000;
	}

	if (!gotone && (self.all_active & #IMPROVED_FOUR)) //if no player target found lets scan for monsters and army..
	{
		local entity te;

		te = find(world, #monsterflag,#STRFLAG_MONSTER);

		while (te != world && gotone == #FALSE)
		{
			gotone = #TRUE;

			if (Teammate(self.real_owner, te.real_owner))
				gotone = #FALSE;
			else if (!IsMonster(te))
				gotone = #FALSE;
			else if (te.health <= 0)
				gotone = #FALSE;
			else if ( (!(self.tf_items & #NIT_TURRET) && !visible2x(self,te)) || ((self.tf_items & #NIT_TURRET) && !visible2(self,te)))
				gotone = #FALSE;		   
			else			
			{
				r = rangesentry(te);

				//WK Hack, turret should be able to see in all directions...
				if (!(self.tf_items & #NIT_TURRET)) {

					if (r == #RANGE_NEAR)
					{
						if (!infront (te))
							gotone = #FALSE;
					}
					else if (r == #RANGE_MID)
					{
						if (!infront (te))
							gotone = #FALSE;
					}
					else if (r == #RANGE_FAR) //- OfN - Sentries with enhanced circuits can shot at far range
					{
						if (!(self.all_active & #IMPROVED_FOUR) || !infront (te))
							gotone = #FALSE;
					}
				}
				else //- OfN - a turretized sentry gun... 
				{
					if (r == #RANGE_FAR && !(self.all_active & #IMPROVED_FOUR))
						gotone = #FALSE;
				}

				//- OfN ----------------//
				if (r == #RANGE_VERYFAR)
					gotone = #FALSE;
				//----------------------//

			} 

			if (gotone)
				client=te;
		   
			te = find(te, #monsterflag, #STRFLAG_MONSTER);

		} // while

	} //monster scanning

	//if no player or monsters found lets scan for possible holo fakes.. (if has improved circuits no scan for holos)
	if (!gotone && !(self.all_active & #IMPROVED_FOUR)) 
	{
		local entity te;

		te = find(world, classname,"holo");

		while (te != world && gotone == #FALSE)
		{
			gotone = #TRUE;
			
			#ifndef HOLO_TEST

			if (Teammate(self.real_owner, te.real_owner))
				gotone = #FALSE;
			else 
			
			#endif

			if (self.has_fieldgen > time) // engineers add some seconds of ignore-holo status to sentries when spannered
				gotone = #FALSE;
			else if (te.has_holo == 0)
				gotone = #FALSE;
			else if ( (!(self.tf_items & #NIT_TURRET) && !visible2x(self,te)) || ((self.tf_items & #NIT_TURRET) && !visible2(self,te)))
				gotone = #FALSE;		   
			else			
			{
				r = rangesentry(te);

				//WK Hack, turret should be able to see in all directions...
				if (!(self.tf_items & #NIT_TURRET)) {

					if (r == #RANGE_NEAR)
					{
						if (!infront (te))
							gotone = #FALSE;
					}
					else if (r == #RANGE_MID)
					{
						if (!infront (te))
							gotone = #FALSE;
					}
					else if (r == #RANGE_FAR) //- OfN - Sentries with enhanced circuits can shot at far range
					{
						if (!(self.all_active & #IMPROVED_FOUR) || !infront (te))
							gotone = #FALSE;
					}
				}
				else //- OfN - a turretized sentry gun... 
				{
					if (r == #RANGE_FAR && !(self.all_active & #IMPROVED_FOUR))
						gotone = #FALSE;
				}

				//- OfN ----------------//
				if (r == #RANGE_VERYFAR)
					gotone = #FALSE;
				//----------------------//

			} 

			if (gotone)
				client=te;
		   
			te = find(te, classname, "holo");

		} // while

	} //holo scanning


	//WK Unhack our hack
	if (self.tf_items & #NIT_TURRET) {
		self.origin_z = self.origin_z + 40;
	}

	if (!gotone)
		return #FALSE;

	// Found a Target
	self.enemy = client;
	
	//- OfN - what was this for??
	/*if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return #FALSE;
		}
	}*/
	
	Sentry_FoundTarget ();

	return #TRUE;
};

void() Sentry_FoundTarget =
{
	// Cannon Powerup Sound?
	if (self.ammo_shells > 0 || (self.ammo_rockets > 0 && self.weapon == 3))
	{
		if (self.attack_finished < time) //- OfN -
			sound (self, #CHAN_VOICE, "weapons/turrspot.wav", 1, #ATTN_NORM);
	}

	Sentry_HuntTarget ();
	if (self.super_damage_finished < time)
	{
		self.super_damage_finished = time + 1.0; //WK Was at .5, which was too fast
		
		if (self.all_active & #IMPROVED_FOUR)
			self.super_damage_finished = time + 0.65; //- OfN - improved circuits! heh
	}
};

void() Sentry_HuntTarget =
{
	self.goalentity = self.enemy;
	if (self.weapon == 1)
		self.think = lvl1_sentry_atk1;
	else if (self.weapon == 2)
		self.think = lvl2_sentry_atk1;
	else // if (self.weapon == 3)
	{
		if (self.ammo_shells <= 0 && self.ammo_rockets > 0) //CH has rockets but no shells
			self.think = lvl3_sentry_atk4;
		else
			self.think = lvl3_sentry_atk1;
	}
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	
	//SUB_AttackFinished (0.5); // WK Does this do anything?
								// - OfN - Nope lol it didnt
	local float tfactor;
	tfactor=1;

	//- OfN - Does this sentry has enhanced circuits? if so.. cut down lock time
	if (self.all_active & #IMPROVED_FOUR) tfactor=0.5;

	//WK --- Invisible people take longer for sentries to lock onto
	// because they have to use their heat sensors
	if (self.enemy.modelindex == modelindex_null)
		self.nextthink = time + (2*tfactor);	// Must acquire a heat signal
	else if (self.enemy.modelindex == modelindex_eyes)
		self.nextthink = time + (1.5*tfactor);	// Some visual, so its a little easier
	else
		self.nextthink = time + (0.5*tfactor);	// Some visual, so its a little easier
};

void() Sentry_Pain =
{
	// Update the owner's status bar
	self.real_owner.StatusRefreshTime = time + 0.2;
//CH special sbar  for eng.
	self.real_owner.StatusBarScreen = 1;
};

void() Sentry_Die =
{
	//RemoveMyTimers(self); // psionic clean-up
	
	if (self.real_owner.cutf_items & #CUTF_DOUBLESENTRY && self.dont_do_triggerwork)
	{
		if (self.dont_do_triggerwork == 1)
			sprint(self.real_owner, #PRINT_HIGH, "Your sentry gun #1 was destroyed.\n");
		else if (self.dont_do_triggerwork == 2)
			sprint(self.real_owner, #PRINT_HIGH, "Your sentry gun #2 was destroyed.\n");
		else
			sprint(self.real_owner, #PRINT_HIGH, "Your sentry gun was destroyed.\n");
	}
	else
		sprint(self.real_owner, #PRINT_HIGH, "Your sentry gun was destroyed.\n");

	self.real_owner.has_sentry = self.real_owner.has_sentry - (self.real_owner.has_sentry & self.dont_do_triggerwork);
	if (self.real_owner.has_sentry < 0)
		self.real_owner.has_sentry = 0;
	
	local entity sprite;

	sprite = SpawnSprite(1,#SPRITE_AIRBURST,self.origin,'0 0 0',#SPRITEMOVE_UPSLOW,0.1);

	if (sprite)
	{
		sprite.effects = #EF_DIMLIGHT;

		if (self.real_owner.team_no == 1)
			sprite.effects = #EF_DIMLIGHT | #EF_BLUE;
		else if (self.real_owner.team_no == 2)
			sprite.effects = #EF_DIMLIGHT | #EF_RED;
	}

	ThrowGib("progs/t2gib1.mdl", -70, #TRUE, 0,0, #FALSE);
	ThrowGib("progs/t2gib2.mdl", -70, #TRUE, 0,0, #FALSE);
	ThrowGib("progs/t2gib3.mdl", -70, #TRUE, 0,0, #FALSE);
	ThrowGib("progs/t2gib4.mdl", -70, #TRUE, self.skin,0, #FALSE);

	if (self.classname == "building_sentrygun_base")
	{
		if (self.oldenemy)
			dremove(self.oldenemy);
	}
	else
	{
		if (self.trigger_field)
			dremove(self.trigger_field);
	}

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

float() Sentry_Fire =
{
	local vector dir;
	local vector miss_factor;

	//- OfN -
	local vector soffset;
	soffset = '0 0 0';
	
	if (!(self.tf_items & #NIT_TURRET))
		soffset = '0 0 20';

	// this on the end..
	//self.attack_finished = time + #SENTRY_UNLOCKTIME; // don't rotate immediately after target invisible or dead

#ifdef QUAKE_WORLD // culled by KK. was QUAKE_WORLD
	/*if (infokey(world,"ceasefire")=="on") //Cyto
			return #FALSE;*/
	if (ceasefire)
		return #FALSE;
#endif

	// OfN - Psionized sentries don't shot
	/*if (self.tfstate & #TFSTATE_PSIONIZED)
		return #FALSE;*/
	
	//WK Stop gun from shooting at dead spies
	if (self.enemy.is_feigning)
		return #FALSE;

	//WK Hack to get floating sentry working - reset before all the returns
	if (self.tf_items & #NIT_TURRET) self.origin_z = self.origin_z - 40;
	
	// Only fire if they're within sight
	dir = self.enemy.origin - self.origin;
	if (vlen(dir) > 2048) //WK Don't fire if they're too far away
	{
		if (self.tf_items & #NIT_TURRET) self.origin_z = self.origin_z + 40;
		return #FALSE;
	}
	dir = normalize(dir);

	//WK Turret can shoot in any direction
	if (!(self.tf_items & #NIT_TURRET)) {
		if ((self.ideal_yaw - anglemod(self.angles_y)) < -10 || (self.ideal_yaw - anglemod(self.angles_y)) > 10) {
			return #FALSE;
		}
	}
	#ifndef MAD_SENTRY
	if (self.ammo_shells >= 1)
		self.ammo_shells = self.ammo_shells - 1;
	#endif
	if (self.ammo_shells < 1) //WK Disallow half-shells
		self.ammo_shells = 0;
	if ((self.ammo_shells <= 0 && self.weapon != 3) || (self.ammo_shells <= 0 && self.ammo_rockets <= 0 && self.weapon == 3)) //CH stay on target if have rockets
	{
		if (self.tf_items & #NIT_TURRET) self.origin_z = self.origin_z + 40;
		return #FALSE;
	}
	//CH this further checks while firing
	traceline (self.origin + soffset, self.enemy.origin, #TL_BSP_ONLY, self);
	if (trace_fraction != 1 || trace_endpos != self.enemy.origin)
	{
		if (self.tf_items & #NIT_TURRET) self.origin_z = self.origin_z + 40;
		return #FALSE;
	}

	if (self.ammo_shells > 0)
	{
		//WK muzzleflash();
		self.effects = self.effects | #EF_DIMLIGHT;
	/*	if (self.tf_items & #NIT_TURRET) 
			sound (self ,#CHAN_WEAPON, "weapons/asscan2.wav", 1, #ATTN_NORM);
		else */
		//sound (self ,#CHAN_WEAPON, "weapons/sniper.wav", 1, #ATTN_NORM);
		sound (self ,#CHAN_WEAPON, "weapons/sntr666.wav", 1, #ATTN_NORM);
		deathmsg = #DMSG_SENTRYGUN_BULLET;
	}



////////////
//WK Our hacked attempt to make sentries shoot right
	//Make base not shootable //CH if its not floating it needs this
	if (!(self.tf_items & #NIT_TURRET))
	{
		if (self.trigger_field) self.trigger_field.solid = #SOLID_NOT;
		//soffset = '0 0 20'; // non-turretized sentries correction
	}

	if (self.is_malfunctioning & #SCREWUP_TWO)
	{
		miss_factor_z = random() * 200 - 100;
		miss_factor_y = random() * 200 - 100;
		miss_factor_x = random() * 200 - 100;
		traceline (self.origin + soffset, self.enemy.origin + miss_factor, #TL_ANY_SOLID, self);
	}
	else
		traceline (self.origin + soffset, self.enemy.origin, #TL_ANY_SOLID, self);

	if (trace_fraction != 1.0 && trace_ent.takedamage && self.ammo_shells > 0) //Hit something and has shells
	{
		SpawnBlood (trace_endpos, 50);
		
		local float thedmg;
		local float therange;

		therange = rangesentry(trace_ent);
		thedmg = 6;

		// OfN - damage now depends on distance to target
		if (therange == #RANGE_MELEE)
			thedmg = 12;
		else if (therange == #RANGE_NEAR)
			thedmg = 6;
		else if (therange == #RANGE_MID)
			thedmg = 4;
		else if (therange == #RANGE_FAR) // only circuit hacked sentries shot at this range
			thedmg = 3;
		else thedmg = 2; // this shouldnt happen ever (RANGE_VERYFAR)

		// OfN - hacked sentries do more damage (improved circuits)
		if (self.all_active & #IMPROVED_FOUR)
			thedmg = thedmg * 1.25; // 1.25 too high?

		#ifndef MAD_SENTRY
		TF_T_Damage (trace_ent, self, self, thedmg, #TF_TD_NOTTEAM, #TF_TD_SHOT);
		#endif
	}
	else if (trace_fraction != 1.0 && trace_ent.classname == "force_field")
	{
	   FieldEvent(trace_ent,trace_endpos,trace_ent);
	   //FieldExplosion(trace_ent,trace_endpos,trace_ent);
	   //PutFieldWork(trace_ent);
	} // Holo fake as target...
	/*else if (trace_fraction != 1.0 && trace_ent.classname == "holo" && self.ammo_shells > 0)
	{
		   
	} */   

	//FireBullets (1, dir, '0.1 0.1 0');
	//CH if its not floating it needs this
	if (!(self.tf_items & #NIT_TURRET))
	{
		if (self.trigger_field) self.trigger_field.solid = #SOLID_BBOX;
	}
/////////////

	// Level 3 Turrets fire rockets every 3 seconds
	if (self.weapon == 3 && self.ammo_rockets > 0 && self.super_damage_finished < time)
	{
		sound (self, #CHAN_VOICE, #SENTRY_ROCKETSND, 1, #ATTN_NORM); //UGLY AND STOPS COOL SOUND
		// wtf happens here, why is this the supernailgun sound?
		if (self.is_malfunctioning & #SCREWUP_THREE)
		{
			local float damg;
			damg = random() * 50 + 120;
			T_RadiusDamage(self, self, damg, world);
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
			WriteCoord (#MSG_BROADCAST, self.origin_x);
			WriteCoord (#MSG_BROADCAST, self.origin_y);
			WriteCoord (#MSG_BROADCAST, self.origin_z);
			if (self.tf_items & #NIT_TURRET)
				self.origin_z = self.origin_z + 40;
			return;
		}

		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = #MOVETYPE_FLYMISSILE;
		newmis.solid = #SOLID_BBOX;
			
		// set newmis speed
		if (self.is_malfunctioning & #SCREWUP_TWO) // SB - oh no we've been hax0red
		{
			miss_factor_z = random() * 200 - 100;
			miss_factor_y = random() * 200 - 100;
			miss_factor_x = random() * 200 - 100;
		}
		else
		{	
			miss_factor_z = 0;
			miss_factor_y = 0;
			miss_factor_x = 0;
		}

		if (self.tf_items & #NIT_TURRET) 
			newmis.velocity = normalize(self.enemy.origin + miss_factor - (self.origin - '0 0 16')) * 800;
		else
			newmis.velocity = normalize(self.enemy.origin + miss_factor - (self.origin + '0 0 16')) * 800;
		newmis.angles = vectoangles(newmis.velocity);
		newmis.weapon = #DMSG_SENTRYGUN_ROCKET;
		newmis.touch = T_MissileTouch;

		// set newmis duration
		newmis.nextthink = time + 5;
		newmis.think = SUB_Remove;

		setmodel (newmis, "progs/missile.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
		if (self.tf_items & #NIT_TURRET) //Determines if rocket should spawn above or below sent		
			setorigin (newmis, self.origin + v_forward*8 - '0 0 16'); //CH make rocket 16 below
		else
			setorigin (newmis, self.origin + v_forward*8 + '0 0 16'); //CH make rocket 16 above

		self.super_damage_finished = time + 3;

		// - OfN - if this sentry has enhanced circuits then delay between rockets firing is cut half
		if (self.all_active & #IMPROVED_FOUR) self.super_damage_finished = time + 1.5;

		self.ammo_rockets = self.ammo_rockets - 1;

		if (self.ammo_rockets == 5) //CH 10 was too high
			sprint(self.real_owner, #PRINT_HIGH, "Sentry Gun is low on rockets.\n");
	}
	// Warn owner that it's low on ammo
	//WK if (self.ammo_shells == 0 && (random() < 0.1))
	if ((self.ammo_shells == 0 && self.weapon != 3) || (self.ammo_shells == 0 && self.weapon == 3 && self.ammo_rockets > 0 && (random() < 0.05))) //CH .05 seems to be good.
		sprint(self.real_owner, #PRINT_HIGH, "Sentry Gun is out of shells.\n");
	else if (self.ammo_shells == 20)
		sprint(self.real_owner, #PRINT_HIGH, "Sentry Gun is low on shells.\n");

	//WK < 0.1
	if (self.ammo_rockets == 0 && self.weapon == 3 && (random() <= 0.1))
		sprint(self.real_owner, #PRINT_HIGH, "Sentry Gun is out of rockets.\n");
	
	if (self.tf_items & #NIT_TURRET) self.origin_z = self.origin_z + 40;

	self.attack_finished = time + #SENTRY_UNLOCKTIME + 2 * random() - 1; // don't rotate immediately after target invisible or dead
	
	return #TRUE;
};

//WK Returns #TRUE if the vector is not a spot a turret can attach to
float(vector vec) BadSpot =
{
	/*
	if (pointcontents(vec) == #CONTENT_SOLID)
		sprint(self.real_owner,#PRINT_HIGH,"SOLID Point\n");
	else if (pointcontents(vec) == #CONTENT_EMPTY)
		sprint(self.real_owner,#PRINT_HIGH,"EMPTY Point\n");
	else if (pointcontents(vec) == #CONTENT_SKY)
		sprint(self.real_owner,#PRINT_HIGH,"SKY Point\n");
	else if (pointcontents(vec) == #CONTENT_WATER)
		sprint(self.real_owner,#PRINT_HIGH,"WATER Point\n");
	else
		sprint(self.real_owner,#PRINT_HIGH,"BUG: Other Point\n");
	*/
	if (pointcontents(vec) == #CONTENT_SKY)
		return #TRUE;
	return #FALSE;
};

//WK Sentry Touch function
//Will kill bad guy 
void() Sentry_Touch =
{
	//WK Check for blockage
	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		sprint(self.real_owner, #PRINT_HIGH, "Your sentry gun flew away.\n");
		Sentry_Die();
		return;
	}

	if (other.takedamage && !(self.tf_items & #NIT_TURRET)) // OfN - fixme: doesn't check for enemy disguised spies
	{
		deathmsg = #DMSG_BUG_ZAPPER;

		if (IsMonster(other))
		{
			if (!Teammate(other.real_owner, self.real_owner))
			{
				TF_T_Damage (other, self, self, 400, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
				return;
				}
			return;
		}

		if (other.job & #JOB_TKD) { //4/27/7 TKD people are so tough they can defeat point defense systems
			//If it is an enemy building, we destroy it with a mighty karate chop!!
			if (!Teammate(self.real_owner, other) && other.last_boot_to_the_head < time)
			{
				sprint(other,#PRINT_HIGH,"You deliver a mighty karate chop to the sentry gun!\n");
				sprint(self.real_owner,#PRINT_HIGH,"Your sentry gun just got karate chopped!\n");
				TF_T_Damage (self, other, other, 100, #TF_TD_NOTTEAM, #TF_TD_MELEE);
				other.last_boot_to_the_head = time + 5; //Delay after such a mighty blow
				Spy_RemoveDisguise(other);
			}
			return;
		}
		//TF_T_Damage (other, self, self.real_owner, 400, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
		if (!Teammate(other, self.real_owner) && (other.is_undercover != 1)) // <== FIXME
			TF_T_Damage (other, self, self, 400, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
		return;
	}
	//I'm in midflight and hit something
	if (self.tf_items & #NIT_TURRET && self.movetype == #MOVETYPE_FLY) 
	{
		//WK Check to see if we are blocked
		//WK These numbers seem to be about right
		if ( BadSpot(self.origin + '0 0 20') || BadSpot(self.origin + '0 0 22'))
		{
			sprint(self.real_owner, #PRINT_HIGH, "Your sentry gun flew away.\n");
			Sentry_Die();
			return;
		}
		if (other == world) { //The eagle has landed!
		//	sprint(self.real_owner, #PRINT_HIGH, "The eagle has landed!\n");
			self.flags = self.flags | #FL_ONGROUND;
			self.movetype = #MOVETYPE_STEP;
			self.origin_z = self.origin_z + 32;//32; // was 40, old custom bug? fixed
			return;
		}
		else if (other.classname == "player")
		{
			deathmsg = #DMSG_BUG_ZAPPER;
			//TF_T_Damage (other, self, self.real_owner, 400, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
			TF_T_Damage (other, self, self, 400, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);

			self.velocity_z = 200; //- OfN reset velocity, not stop
		}
		else
		{
			deathmsg = #DMSG_BUG_ZAPPER;
			//TF_T_Damage (other, self, self.real_owner, 400, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
			if (!Teammate(other.real_owner, self.real_owner))
				TF_T_Damage (other, self, self, 400, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
			Sentry_Die();
		}
		//sprint(self.real_owner, #PRINT_HIGH, "The eagle has died.\n");
	}
};
