/*======================================================
	ACTIONS.QC			Custom TeamFortress v3.2	

	(c) TeamFortress Software Pty Ltd	13/5/97
	(c) William Kerney			2/9/00
	(c) Craig Hauser				19/3/00
========================================================
Non Class-Specific Impulse Commands
=======================================================*/
// Prototypes
void() TeamFortress_Discard;
void() TeamFortress_SaveMe;
void(float inAuto) TeamFortress_ID;
void() TeamFortress_ReloadCurrentWeapon;

//CH dropitems
float() TeamFortress_DropItems;
void(entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;

//=========================================================================
// Discard Command. Drops all ammo useless to the player's class.
void() TeamFortress_Discard =
{ 
	// Create a backpack
	newmis = spawn();
//CH to save space. Dont do class specific checks
//
//CH new setup, checks if you have weapon that uses that ammo
//and if you dont, throws it away
	 if (self.playerclass != #PC_UNDEFINED)
	{
		if (!(self.weapons_carried & #WEAP_SNIPER_RIFLE || self.weapons_carried & #WEAP_AUTO_RIFLE || self.weapons_carried & #WEAP_SHOTGUN || self.weapons_carried & #WEAP_SUPER_SHOTGUN || self.weapons_carried & #WEAP_ASSAULT_CANNON || (self.cutf_items & #CUTF_SENTRYGUN && self.weapons_carried & #WEAP_SPANNER)))
			newmis.ammo_shells = self.ammo_shells;
		if (!(self.weapons_carried & #WEAP_NAILGUN || self.weapons_carried & #WEAP_SNG || self.weapons_carried & #WEAP_LIGHT_ASSAULT || self.weapons_carried & #WEAP_RAILGUN || self.weapons_carried & #WEAP_TRANQ || self.weapons_carried & #WEAP_MAUSER)) //CH is it just me or are there not many nail weapons? //WK It's just you
			newmis.ammo_nails = self.ammo_nails;
		if (!(self.weapons_carried & #WEAP_ROCKET_LAUNCHER || self.cutf2_items & #CUTF2_EXPLOSIVE_SHOT || self.weapons_carried & #WEAP_INCENDIARY || self.weapons_carried & #WEAP_GRENADE_LAUNCHER || (self.cutf_items & #CUTF_SENTRYGUN && self.weapons_carried & #WEAP_SPANNER) || self.job & #JOB_GUERILLA))
			newmis.ammo_rockets = self.ammo_rockets;
		//OfN old bug, WEAP_SUPERSHOTGUN if (!(self.cutf_items & #CUTF_CYBERAUG || self.cutf_items & #CUTF_HOLO || self.weapons_carried & #WEAP_LASERCANNON || self.weapons_carried & #WEAP_INCENDIARY || self.weapons_carried & #WEAP_LIGHTNING || self.weapons_carried & #WEAP_SUPER_SHOTGUN || self.weapons_carried & #WEAP_ASSAULT_CANNON || self.weapons_carried & #WEAP_DAEDALUS || (self.cutf_items & #CUTF_SENTRYGUN && self.weapons_carried & #WEAP_SPANNER) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TESLA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_SECURITY_CAMERA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TELEPORTER)))
		//done -  FIXME: Add fieldgens
		//if (!(self.cutf_items & #CUTF_CYBERAUG || self.cutf_items & #CUTF_HOLO || self.weapons_carried & #WEAP_LASERCANNON || self.weapons_carried & #WEAP_INCENDIARY || self.weapons_carried & #WEAP_LIGHTNING || self.weapons_carried & #WEAP_AIRF || self.weapons_carried & #WEAP_ASSAULT_CANNON || self.weapons_carried & #WEAP_DAEDALUS || (self.cutf_items & #CUTF_SENTRYGUN && self.weapons_carried & #WEAP_SPANNER) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TESLA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_SECURITY_CAMERA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TELEPORTER) || (self.weapons_carried & #WEAP_SPANNER && self.cutf_items & #CUTF_FIELDGEN)))
		//if (!(self.cutf_items & #CUTF_CYBERAUG || self.cutf_items & #CUTF_HOLO || self.weapons_carried & #WEAP_LASERCANNON || self.weapons_carried & #WEAP_INCENDIARY || self.weapons_carried & #WEAP_LIGHTNING || self.weapons_carried & #WEAP_AIRF || self.weapons_carried & #WEAP_ASSAULT_CANNON || self.weapons_carried & #WEAP_DAEDALUS || (self.cutf_items & #CUTF_SENTRYGUN && self.weapons_carried & #WEAP_SPANNER) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TESLA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_SECURITY_CAMERA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TELEPORTER) || (self.weapons_carried & #WEAP_SPANNER && self.cutf_items & #CUTF_FIELDGEN) || (self.weapons_carried & #WEAP_SPANNER && self.cutf_items & #CUTF_SENSOR)))
		if (!(self.cutf_items & (#CUTF_CYBERAUG | #CUTF_HOLO) || self.weapons_carried & (#WEAP_LASERCANNON | #WEAP_INCENDIARY | #WEAP_LIGHTNING | #WEAP_ASSAULT_CANNON | #WEAP_DAEDALUS | #WEAP_AIRF) || (self.cutf_items & #CUTF_SENTRYGUN && self.weapons_carried & #WEAP_SPANNER) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TESLA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_SECURITY_CAMERA) || (self.weapons_carried & #WEAP_SPANNER && self.tf_items & #NIT_TELEPORTER) || (self.weapons_carried & #WEAP_SPANNER && self.cutf_items & #CUTF_FIELDGEN) || (self.weapons_carried & #WEAP_SPANNER && self.cutf_items & #CUTF_SENSOR)))
		//if (!(self.weapons_carried & #WEAP_SPANER && (self.cutf_items & (CUTF_SENTRYGUN |   )  )))
			newmis.ammo_cells = self.ammo_cells;
	}

	// If there's nothing in the backpack, remove it and return
	if (!(newmis.ammo_shells + newmis.ammo_nails + newmis.ammo_rockets + newmis.ammo_cells))
	{
		dremove(newmis);
		return;
	}

	// Remove the ammo from the player
	if (newmis.ammo_shells)
		self.ammo_shells = 0;
	if (newmis.ammo_nails)
		self.ammo_nails = 0;
	if (newmis.ammo_rockets)
		self.ammo_rockets = 0;
	if (newmis.ammo_cells)
		self.ammo_cells = 0;
	W_SetCurrentAmmo();

	sound(self, #CHAN_ITEM, "weapons/lock4.wav", 1, #ATTN_NORM);

	// The backpack is treated as an ammobox, so people can't crash svrs
	// by making too many of them.
	if (self.team_no != 0)
	{
		increment_team_ammoboxes(self.team_no);
		if (num_team_ammoboxes(self.team_no) > (#MAX_WORLD_AMMOBOXES / number_of_teams))
			RemoveOldAmmobox(self.team_no);
	}
	else 
	{
		num_world_ammoboxes = num_world_ammoboxes + 1;
		if (num_world_ammoboxes > #MAX_WORLD_AMMOBOXES)
			RemoveOldAmmobox(0);
	}

	// Throw the backpack
	newmis.enemy = self;
	newmis.health = time;
	newmis.weapon = 0;
	newmis.movetype = #MOVETYPE_TOSS;
	newmis.solid = #SOLID_TRIGGER;
	newmis.classname = "ammobox";
	newmis.team_no = self.team_no;
	makevectors (self.v_angle);
	if (self.v_angle_x)
	{
		newmis.velocity = v_forward*400 + v_up * 200;
	}
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 400;
		newmis.velocity_z = 200;
	}
	newmis.avelocity = '0 300 0';
	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, self.origin);
	newmis.nextthink = time + 30;	// remove after 30 seconds
	newmis.think = SUB_Remove;
	newmis.touch = TeamFortress_AmmoboxTouch;
	setmodel (newmis, "progs/backpack.mdl");	
};

//=========================================================================
// Shows any medics/engineers on your team that you need help.
// Spies see all requests.
void() TeamFortress_SaveMe =
{
	local entity te, tl;

	//WK 5-15-08 Stop spectators and observers from making noise
	if (self.classname == "spec") return;
	if (self.playerclass == #PC_UNDEFINED) return;

	if (self.last_saveme_sound < time)
	{
		if (random() < 0.8)
			sound(self, #CHAN_WEAPON, "speech/saveme1.wav", 1, #ATTN_NORM); // MEDIC!
		else
			sound(self, #CHAN_WEAPON, "speech/saveme2.wav", 1, #ATTN_NORM); // Excuse me...
		self.last_saveme_sound = time + 4;
	}

	te = find(world, classname, "player");
	while (te)
	{	
		//if (self.weapons_carried & #WEAP_MEDIKIT) OfN WTF?
		  // Was ==, wtf?
		if (self != te || te.weapons_carried & #WEAP_MEDIKIT || te.weapons_carried & #WEAP_SPANNER || te.cutf_items & #CUTF_SPY_KIT) //WK Custom class friendly
		{
			if (Teammate(self, te) || (te.cutf_items & #CUTF_SPY_KIT))
			{
				// If the other teammate is visible, show them I need help
				if (visible(te))
				{
					msg_entity = te;
					tl = spawn();
					tl.origin = self.origin;
					tl.origin_z = tl.origin_z + 32;
					WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
					WriteByte (#MSG_ONE, #TE_LIGHTNING3);
					WriteEntity (#MSG_ONE, tl);
					WriteCoord (#MSG_ONE, tl.origin_x);
					WriteCoord (#MSG_ONE, tl.origin_y);
					WriteCoord (#MSG_ONE, tl.origin_z + 24);
					WriteCoord (#MSG_ONE, self.origin_x);
					WriteCoord (#MSG_ONE, self.origin_y);
					WriteCoord (#MSG_ONE, self.origin_z);
					dremove(tl);
				}
			}
		}

		te = find(te, classname, "player");
	}
};

//=========================================================================
// ID's the player in your sights, and if you're a medic or engineer,
// reports their health and armor.
void(float inAuto) TeamFortress_ID =
{
	//WK All the inAuto and spacer stuff I added
	local vector src;
	local string st, cls;
	local string spacer;
	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;
	if (!inAuto) //WK I.e. just someone is doing it normally
		traceline (src, src + v_forward*2048, #TL_EVERYTHING, self); //#TL_ANY_SOLID
	else		//WK I.e. it is an autoscan
		traceline (src, src + v_forward*1024, #TL_ANY_SOLID, self); //#TL_ANY_SOLID

	if (!Teammate(self, trace_ent)) {
		if (trace_ent.classname == "player" && trace_ent.job & (#JOB_THIEF)) //WK 1-19-09 Can't id enemy thieves
			return;
	}

	if (inAuto)
	{
		// Auto ID shouldn't pertubate menus
		if (self.current_menu != 0)
			return; 
	}

	//if (!inAuto)
		//spacer = "\n\n\n\n\n";
		spacer = "\n";
	//else
	//	spacer = "\n\n\n\n\n\n\n";

	if (trace_ent != world && trace_ent.origin != world.origin )
	{
		#ifdef IDABLE_CORPSES
		if (trace_ent.#corpseflag == #STRFLAG_CORPSE)
		{
			self.StatusRefreshTime = time + 1.5;
			if (trace_ent.classname == "player")
			{
				if (trace_ent.playerclass == #PC_CUSTOM)
					cls = TeamFortress_GetJobName(trace_ent.job);
				else
					cls = TeamFortress_GetClassName(trace_ent.playerclass);

				if (Teammate(self, trace_ent))
					centerprint(self, spacer, trace_ent.netname, "'s corpse!\n\nNo ",cls," deserves this..");
				else
					centerprint(self, spacer, "This enemy ",cls," looks like\n\n",trace_ent.netname,"'s corpse!");
			
				return;
			}
			else if (trace_ent.classname == "monster_corpse")
			{
				if (trace_ent.#monster_type == #MONSTER_ARMY)
				{
					if (Teammate(self, trace_ent))
						centerprint(self, spacer, "Dead army comrade");
					else
						centerprint(self, spacer, "Dead enemy army guy");
				}
				else
				{
					if (Teammate(self, trace_ent))
						centerprint(self, spacer, "This good beast was helping");
					else
						centerprint(self, spacer, "This thing isn't alive\n\nIt smells badly though");
				}

				return;
			}
			
			// Player corpse on bodyque (unsafe to get name)
			if (Teammate(self, trace_ent))
				centerprint(self, spacer,"\nFallen teammate");
			else
				centerprint(self, spacer,"\nAn enemy rotten corpse");

			return;
		}
		else 
		#endif
		#ifdef IDABLE_TFITEMS
		if (trace_ent.classname == "item_tfgoal")
		{
			if (trace_ent.netname)
			{
				self.StatusRefreshTime = time + 1.5;
				centerprint(self,trace_ent.netname);
			}

			return;
		}
		else
		#endif
		#ifdef IDABLE_RUNES
		if (trace_ent.classname == "rune")
		{
			self.StatusRefreshTime = time + 1.5;
			centerprint(self,trace_ent.netname);

			return;
		}
		else
		#endif
		/*if (trace_ent.classname == "grenade" && trace_ent.netname == "land_mine")
		{
			self.StatusRefreshTime = time + 1.5;
			if (Teammate(self, trace_ent.owner))
				centerprint(self,"Friendly Mine");
			else
				centerprint(self,"Εξενω Mine");
			return;
		}*/
		if (trace_ent.classname == "player" && trace_ent.health > 0)
		{
			self.StatusRefreshTime = time + 1.5;

			if (Teammate(trace_ent, self))
			{
				if (trace_ent.playerclass == #PC_CUSTOM)
					cls = TeamFortress_GetJobName(trace_ent.job);
				else
					cls = TeamFortress_GetClassName(trace_ent.playerclass);

				if (self.weapons_carried & #WEAP_MEDIKIT) //WK
				{
					st = ftos(trace_ent.health);
					centerprint(self, spacer, trace_ent.netname, "\n\nFriendly ", cls, "\n\n", st, " health\n");
//centerprint(self, "\n\n\n\n", trace_ent.netname, "\nFriendly ", cls, "\n", st, //" health\n");
					return;
				}
				else if (self.weapons_carried & #WEAP_SPANNER) //WK
				{
					st = ftos(trace_ent.armorvalue);
					centerprint(self, spacer, trace_ent.netname, "\n\nFriendly ", cls, "\n\n", st, " armor\n");
					return;
				}
				else
					centerprint(self, spacer, trace_ent.netname, "\n\nFriendly ", cls,"\n");
				return;
			}

			if (trace_ent.is_feigning) //WK Can't id enemy spies feigning
				return;

			if (trace_ent.cutf_items & #CUTF_SPY_KIT)
			{
				cls = TeamFortress_GetClassName(trace_ent.undercover_skin);
				// Report a false name
				if (self.team_no != 0 && (self.team_no == trace_ent.undercover_team))
				{
					if (self.weapons_carried & #WEAP_MEDIKIT)
					{
						st = ftos(trace_ent.health);
						if (trace_ent.undercover_skin != 0)
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly ", cls, "\n\n", st, " health\n");
						else
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly Spy\n\n", st, " health\n");
						return;
					}
					else if (self.weapons_carried & #WEAP_SPANNER)
					{
						st = ftos(trace_ent.armorvalue);
						if (trace_ent.undercover_skin != 0)
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly ", cls, "\n\n", st, " armor\n");
						else
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly Spy\n\n", st, " armor\n");
						return;
					}
					else
					{
						st = ftos(trace_ent.armorvalue);
						if (trace_ent.undercover_skin != 0)
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly ", cls, "\n");
						else
							centerprint(self, spacer, trace_ent.undercover_name, "\n\nFriendly Spy\n");
						return;
					}
				}

				if (trace_ent.undercover_name != string_null)
				{
					if (trace_ent.undercover_skin != 0)
						centerprint(self, spacer, trace_ent.undercover_name, "\n\nΕξενω ", cls, "\n");
					else
						centerprint(self, spacer, trace_ent.undercover_name, "\n\nΕξενω Spy");
				}
				else
				{
					if (trace_ent.undercover_skin != 0)
						centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω ", cls, "\n");
					else
						centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω Spy");
				}
			}
			else 
			{
				if (trace_ent.playerclass == #PC_CUSTOM) {
					cls = TeamFortress_GetJobName(trace_ent.job);
					centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω ", cls, "\n");
				}
				else {
					cls = TeamFortress_GetClassName(trace_ent.playerclass);
					centerprint(self, spacer, trace_ent.netname, "\n\nΕξενω ", cls, "\n");
				}
			}
		}
		else if (trace_ent.classname == "building_dispenser")
		{
			self.StatusRefreshTime = time + 1.5;
			
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Dispenser\n");
			else if (!teamplay)
				centerprint(self, spacer,"Dispenser made by\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent, self))
				centerprint(self, spacer,"Friendly Dispenser made by\n\n", trace_ent.real_owner.netname, "\n");
			else 
				centerprint(self, spacer,"Εξενω Dispenser made by\n\n", trace_ent.real_owner.netname, "\n");
	
		}
		else if (trace_ent.classname == "building_fieldgen")
		{
			self.StatusRefreshTime = time + 1.5;
			
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Field Generator.\n");
			else if (!teamplay)
				centerprint(self, spacer,"Field Generator made by\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent, self))
				centerprint(self, spacer,"Friendly Field Generator made by\n\n", trace_ent.real_owner.netname, "\n");
			else 
				centerprint(self, spacer,"Εξενω Field Generator made by\n\n", trace_ent.real_owner.netname, "\n");
	
		}

		else if (trace_ent.classname == "building_sentrygun" || trace_ent.classname == "building_sentrygun_base")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
			{
				if (self.cutf_items & #CUTF_DOUBLESENTRY)
				{
					if (trace_ent.dont_do_triggerwork == 1)
						centerprint(self, spacer,"Your Sentry Gun #1\n");
					else if (trace_ent.dont_do_triggerwork == 2)
						centerprint(self, spacer,"Your Sentry Gun #2\n");
					else
						centerprint(self, spacer,"Your Sentry Gun\n");
				}
				else
					centerprint(self, spacer,"Your Sentry Gun\n");
			}
			else if (!teamplay)
				centerprint(self, spacer,"Sentry Gun made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent, self))
				centerprint(self, spacer,"Friendly Sentry Gun made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Sentry Gun made by\n\n", trace_ent.real_owner.netname,"\n");
		}	
		else if (trace_ent.classname == "building_tesla")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
			{
				if (self.tf_items & #NIT_DOUBLETESLA)
				{
					if (trace_ent.dont_do_triggerwork == 1)
						centerprint(self, spacer,"Your Tesla Coil #1\n");
					else if (trace_ent.dont_do_triggerwork == 2)
						centerprint(self, spacer,"Your Tesla Coil #2\n");
					else
						centerprint(self, spacer,"Your Tesla Coil\n");
				}
				else
					centerprint(self, spacer,"Your Tesla Coil\n");				
			}
			else if (!teamplay)
				centerprint(self, spacer,"Tesla Coil made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent, self))
				centerprint(self, spacer,"Friendly Tesla made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Tesla made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_camera")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your favorite Security Camera\n");
			else if (!teamplay)
				centerprint(self, spacer,"Security Camera made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent, self))
				centerprint(self, spacer,"Friendly Security Camera made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Security Camera made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_sensor")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your favorite Motion Sensor\n");
			else if (!teamplay)
				centerprint(self, spacer,"Motion Sensor made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent, self))
				centerprint(self, spacer,"Friendly Motion Sensor made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Motion Sensor made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "building_teleporter")
		{
			self.StatusRefreshTime = time + 1.5;
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"One of your favorite Teleporter Pads\n"); //CH b/c you have 2
			else if (!teamplay)
				centerprint(self, spacer,"Teleporter Pad made by\n\n", trace_ent.real_owner.netname,"\n");
			else if (Teammate(trace_ent, self))
				centerprint(self, spacer,"Friendly Teleporter Pad made by\n\n", trace_ent.real_owner.netname,"\n");
			else 
				centerprint(self, spacer,"Εξενω Teleporter Pad made by\n\n", trace_ent.real_owner.netname,"\n");
		}
		else if (trace_ent.classname == "monster_demon1")
		{
			//custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Pet Demon ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Demon summoned by\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner, self))
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly demon summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly demon summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω demon summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω demon summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
			}
		}
		else if (trace_ent.classname == "monster_army")
		{
			//custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your mercenary soldier ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Soldier in the pay of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner, self))
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly soldier owned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly soldier owned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω soldier owned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω soldier owned by\n\n", trace_ent.real_owner.netname);
			}
		}
		else if (trace_ent.classname == "monster_shambler")
		{
			//custom_demon_name(trace_ent); //CH
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your Pet Shambler ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Shambler under control of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner, self))
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly shambler summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly shambler summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω shambler summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω shambler summoned by\n\n ", trace_ent.real_owner.netname);
			}
		}
		else if (trace_ent.classname == "monster_fish") //- OfN
		{
			//custom_demon_name(trace_ent); 
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your swimming Piranha ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Piranha under control of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner, self))
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Piranha summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Piranha summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Piranha summoned by\n\n ", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Piranha summoned by\n\n", trace_ent.real_owner.netname);
			}
		}
		else if (trace_ent.classname == "monster_gremlin") //- OfN
		{
			//custom_demon_name(trace_ent); 
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your dirty gremlin ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Gremlin under control of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner, self))
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Gremlin summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Gremlin summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Gremlin summoned by\n\n ", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Gremlin summoned by\n\n", trace_ent.real_owner.netname);
			}
		}
		else if (trace_ent.classname == "monster_wizard") //- OfN
		{
			//custom_demon_name(trace_ent); 
			self.StatusRefreshTime = time + 1.5;
			st = ftos(trace_ent.health);
			if (self == trace_ent.real_owner)
				centerprint(self, spacer,"Your flying Scrag ",trace_ent.netname, "\n\n", st, " health");
			else if (!teamplay)
				centerprint(self, spacer,"Scrag under control of\n\n", trace_ent.real_owner.netname);
			else if (Teammate(trace_ent.real_owner, self))
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Scrag summoned by\n\n", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nfriendly Scrag summoned by\n\n", trace_ent.real_owner.netname);
			}
			else
			{
				if (self.cutf_items & #CUTF_DEMONLORE)
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Scrag summoned by\n\n ", trace_ent.real_owner.netname, "\n\n", st, " health");
				else
					centerprint(self, spacer,trace_ent.netname,"\n\nεξενω Scrag summoned by\n\n", trace_ent.real_owner.netname);
			}
		}		  
	}
};

//=========================================================================
// Reloads the current weapon
void() TeamFortress_ReloadCurrentWeapon =
{
	// OfN - Psionized guys can't reload
	if (self.tfstate & #TFSTATE_PSIONIZED)
	{
		sprint(self,#PRINT_HIGH,"You can't reload right now!\n");
		return;
	}

	//---------------- CLIP EXTENDER (same as below but with _EX values -------------//
	if (self.cutf_items & #CUTF_CLIPEXTEND)
	{
		local float rt;
		local entity tWeapon;

		if (self.current_weapon == #WEAP_SHOTGUN)
		{
			if (self.reload_shotgun == 0)
			{
				sprint(self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if ( self.reload_shotgun < self.ammo_shells)
			{
				Attack_Finished(0.4);

				// Calculate the reload time needed
				rt = (#RE_SHOTGUN_EX - self.reload_shotgun) / #RE_SHOTGUN_EX;
				rt = #RE_SHOTGUN_TIME_EX - (#RE_SHOTGUN_TIME_EX * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_shotgun = 0;
				if (self.ammo_shells < #RE_SHOTGUN_EX)
					self.reload_shotgun = #RE_SHOTGUN_EX - self.ammo_shells;
			   
				sprint(self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_shotgun;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint(self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
		{
			if (self.reload_super_shotgun == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if ( self.reload_super_shotgun < self.ammo_shells)
			{
				Attack_Finished(0.7);

				// Calculate the reload time needed
				rt = (#RE_SUPER_SHOTGUN_EX - self.reload_super_shotgun) / #RE_SUPER_SHOTGUN_EX;
				rt = #RE_SUPER_SHOTGUN_TIME_EX - (#RE_SUPER_SHOTGUN_TIME_EX * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_super_shotgun = 0;
				if (self.ammo_shells < #RE_SUPER_SHOTGUN_EX)
					self.reload_super_shotgun = #RE_SUPER_SHOTGUN_EX - self.ammo_shells;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_super_shotgun;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint (self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_LASERCANNON)
		{
			if (self.reload_laser_cannon == 0)
			{
				sprint (self, #PRINT_HIGH, "Cannon already in full charge.\n");
				return;
			}

			if ( self.reload_laser_cannon < self.ammo_cells)
			{
				Attack_Finished(2);

				// Calculate the reload time needed
				rt = (#RE_LASER_CANNON_EX - self.reload_laser_cannon) / #RE_LASER_CANNON_EX;
				rt = #RE_LASER_CANNON_TIME_EX - (#RE_LASER_CANNON_TIME_EX * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_laser_cannon = 0;
				if (self.ammo_cells < #RE_LASER_CANNON_EX)
					self.reload_laser_cannon = #RE_LASER_CANNON_EX - self.ammo_cells;

				sprint (self, #PRINT_HIGH, "Charging cannon...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_laser_cannon;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint (self, #PRINT_HIGH, "not enough cells to recharge\n");
			}
		}
		else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
		{
			if (self.reload_light_assault == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if ( self.reload_light_assault < self.ammo_nails)
			{
				Attack_Finished(2);

				// Calculate the reload time needed
				rt = (#RE_LIGHT_ASSAULT_EX - self.reload_light_assault) / #RE_LIGHT_ASSAULT_EX;
				rt = #RE_LIGHT_ASSAULT_TIME_EX - (#RE_LIGHT_ASSAULT_TIME_EX * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_light_assault = 0;
				if (self.ammo_nails < #RE_LIGHT_ASSAULT_EX)
					self.reload_light_assault = #RE_LIGHT_ASSAULT_EX - self.ammo_nails;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_light_assault;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint (self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER)
		{
			if (self.reload_grenade_launcher == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}
			
			if (self.reload_grenade_launcher < self.ammo_rockets)
			{
				Attack_Finished(0.6);

				// Calculate the reload time needed
				rt = (#RE_GRENADE_LAUNCHER_EX - self.reload_grenade_launcher) / #RE_GRENADE_LAUNCHER_EX;
				rt = #RE_GRENADE_LAUNCHER_TIME_EX - (#RE_GRENADE_LAUNCHER_TIME_EX * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_grenade_launcher = 0;
				if (self.ammo_rockets < #RE_GRENADE_LAUNCHER_EX)
					self.reload_grenade_launcher = #RE_GRENADE_LAUNCHER_EX - self.ammo_rockets;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_grenade_launcher;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else 
			{
				sprint (self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER)
		{
			if (self.reload_rocket_launcher == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if (self.reload_rocket_launcher < self.ammo_rockets)
			{
				Attack_Finished(0.8);

				// Calculate the reload time needed
				rt = (#RE_ROCKET_LAUNCHER_EX - self.reload_rocket_launcher) / #RE_ROCKET_LAUNCHER_EX;
				rt = #RE_ROCKET_LAUNCHER_TIME_EX - (#RE_ROCKET_LAUNCHER_TIME_EX * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_rocket_launcher = 0;

				if (self.ammo_rockets < #RE_ROCKET_LAUNCHER_EX)
					self.reload_rocket_launcher = #RE_ROCKET_LAUNCHER_EX - self.ammo_rockets;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_rocket_launcher;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
		}
	else if (self.current_weapon == #WEAP_DAEDALUS) //WK 8/4/7 Added clips to daed
		{
			if (self.reload_daedalus == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if (self.reload_daedalus < self.ammo_cells)
			{
				Attack_Finished(0.8);

				// Calculate the reload time needed
				rt = (#RE_DAEDALUS_EX - self.reload_daedalus) / #RE_DAEDALUS_EX;
				rt = #RE_DAEDALUS_TIME_EX - (#RE_DAEDALUS_TIME_EX * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_daedalus = 0;

				if (self.ammo_cells < #RE_DAEDALUS_EX)
					self.reload_daedalus = #RE_DAEDALUS_EX - self.ammo_cells;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_daedalus;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
		}
	} // END CLIP EXTENDER
	else
	{

		local float rt;
		local entity tWeapon;

		if (self.current_weapon == #WEAP_SHOTGUN)
		{
			if (self.reload_shotgun == 0)
			{
				sprint(self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if ( self.reload_shotgun < self.ammo_shells)
			{
				Attack_Finished(0.4);

				// Calculate the reload time needed
				rt = (#RE_SHOTGUN - self.reload_shotgun) / #RE_SHOTGUN;
				rt = #RE_SHOTGUN_TIME - (#RE_SHOTGUN_TIME * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_shotgun = 0;
				if (self.ammo_shells < #RE_SHOTGUN)
					self.reload_shotgun = #RE_SHOTGUN - self.ammo_shells;
			   
				sprint(self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_shotgun;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint(self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
		{
			if (self.reload_super_shotgun == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if ( self.reload_super_shotgun < self.ammo_shells)
			{
				Attack_Finished(0.7);

				// Calculate the reload time needed
				rt = (#RE_SUPER_SHOTGUN - self.reload_super_shotgun) / #RE_SUPER_SHOTGUN;
				rt = #RE_SUPER_SHOTGUN_TIME - (#RE_SUPER_SHOTGUN_TIME * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_super_shotgun = 0;
				if (self.ammo_shells < #RE_SUPER_SHOTGUN)
					self.reload_super_shotgun = #RE_SUPER_SHOTGUN - self.ammo_shells;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_super_shotgun;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint (self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_LASERCANNON)
		{
			if (self.reload_laser_cannon == 0)
			{
				sprint (self, #PRINT_HIGH, "Cannon already in full charge.\n");
				return;
			}

			if ( self.reload_laser_cannon < self.ammo_cells)
			{
				Attack_Finished(2);

				// Calculate the reload time needed
				rt = (#RE_LASER_CANNON - self.reload_laser_cannon) / #RE_LASER_CANNON;
				rt = #RE_LASER_CANNON_TIME - (#RE_LASER_CANNON_TIME * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_laser_cannon = 0;
				if (self.ammo_cells < #RE_LASER_CANNON)
					self.reload_laser_cannon = #RE_LASER_CANNON - self.ammo_cells;

				sprint (self, #PRINT_HIGH, "Charging cannon...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_laser_cannon;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint (self, #PRINT_HIGH, "not enough cells to recharge\n");
			}
		}
		else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
		{
			if (self.reload_light_assault == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if ( self.reload_light_assault < self.ammo_nails)
			{
				Attack_Finished(2);

				// Calculate the reload time needed
				rt = (#RE_LIGHT_ASSAULT - self.reload_light_assault) / #RE_LIGHT_ASSAULT;
				rt = #RE_LIGHT_ASSAULT_TIME - (#RE_LIGHT_ASSAULT_TIME * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_light_assault = 0;
				if (self.ammo_nails < #RE_LIGHT_ASSAULT)
					self.reload_light_assault = #RE_LIGHT_ASSAULT - self.ammo_nails;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_light_assault;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else
			{
				sprint (self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER)
		{
			if (self.reload_grenade_launcher == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}
			
			if (self.reload_grenade_launcher < self.ammo_rockets)
			{
				Attack_Finished(0.6);

				// Calculate the reload time needed
				rt = (#RE_GRENADE_LAUNCHER - self.reload_grenade_launcher) / #RE_GRENADE_LAUNCHER;
				rt = #RE_GRENADE_LAUNCHER_TIME - (#RE_GRENADE_LAUNCHER_TIME * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_grenade_launcher = 0;
				if (self.ammo_rockets < #RE_GRENADE_LAUNCHER)
					self.reload_grenade_launcher = #RE_GRENADE_LAUNCHER - self.ammo_rockets;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_grenade_launcher;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
			else 
			{
				sprint (self, #PRINT_HIGH, "not enough ammo to reload\n");
			}
		}
		else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER)
		{
			if (self.reload_rocket_launcher == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if (self.reload_rocket_launcher < self.ammo_rockets)
			{
				Attack_Finished(0.8);

				// Calculate the reload time needed
				rt = (#RE_ROCKET_LAUNCHER - self.reload_rocket_launcher) / #RE_ROCKET_LAUNCHER;
				rt = #RE_ROCKET_LAUNCHER_TIME - (#RE_ROCKET_LAUNCHER_TIME * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_rocket_launcher = 0;

				if (self.ammo_rockets < #RE_ROCKET_LAUNCHER)
					self.reload_rocket_launcher = #RE_ROCKET_LAUNCHER - self.ammo_rockets;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_rocket_launcher;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
		}
	else if (self.current_weapon == #WEAP_DAEDALUS) //WK 8/4/7 Added clips to daed
		{
			if (self.reload_daedalus == 0)
			{
				sprint (self, #PRINT_HIGH, "Clip full.\n");
				return;
			}

			if (self.reload_daedalus < self.ammo_cells)
			{
				Attack_Finished(0.8);

				// Calculate the reload time needed
				rt = (#RE_DAEDALUS - self.reload_daedalus) / #RE_DAEDALUS;
				rt = #RE_DAEDALUS_TIME - (#RE_DAEDALUS_TIME * rt);

				if (self.#runes & #RUNE_SPEED)
					rt = rt * #SPEEDRUNE_RELOADMULT;

				self.reload_daedalus = 0;

				if (self.ammo_cells < #RE_DAEDALUS)
					self.reload_daedalus = #RE_DAEDALUS - self.ammo_cells;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.netname = "reloadtimer"; //WK For Judoka code
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + rt;
				tWeapon.think = W_Reload_daedalus;

				self.weaponmodel = "";
				self.weaponframe = 0;
			}
		}
	}
};

//CH drops an item TF goal if the bits are set to allow it.
float() TeamFortress_DropItems =
{
	local entity tg;
	local float counter;

	counter = 0;
	//local string temp;

	tg = find (world, classname, "item_tfgoal");
	while (tg)
	{
		if (tg.owner == self && tg != world && tg.classname == "item_tfgoal")
		{
			if (tg.goal_activation & #TFGR_DROPITEMS) // Grievre fix: was goal_result
			{
				if (tg.netname)
					sprint (self, #PRINT_HIGH, "Dropping item: ", tg.netname, "\n");
				
				counter = counter + 1;

				if (counter > 1)
					tfgoalitem_RemoveFromPlayer(tg, self, 0);
				else
					tfgoalitem_RemoveFromPlayer(tg, self, 2); // last param was 0, OfN added 2, which tosses item in player dir, see tfortmap.qc
//CH it treats it as though you died.  And if bits are set, you throw it, or it gets removed etc.
			}
		}

		tg = find(tg, classname, "item_tfgoal");
	}

	return counter;
};
