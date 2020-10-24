/*======================================================
	COMBAT.QC			Custom TeamFortress v3.2	

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney			5/19/00
========================================================
All the functions pertaining to killing people
======================================================*/


//void(string gibname, float dm) ThrowGib;
void(string gibname, float dm, float makecool, float gibskin, float gibkgs, float randorg) ThrowGib;
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

// TeamFortress Prototypes
void(entity Goal, entity AP, float addb) DoResults;
float(entity Goal, entity AP) Activated;
void() monster_death_use;
float (entity targ, entity attacker, float damage) TeamEqualiseDamage;
void(entity bastard,float threshold) createBastard;
void (entity targ,float pain) RevealThief;

//WK
void() GuerillaExplode;
float(entity tester) IsBuilding;
//float(entity happyboy,float newtime) makeImmune;

//- OfN -
float(entity thing) IsMonster;
void(entity body) ExpBody;
string(entity thebuilding) GetBuildingName;
string(entity thething) GetEnemyName;
void() Napalm_touch;

void(entity tfield, vector where, entity thing) FieldEvent;

float(entity player) GetDamageInFactor; //For calculating resists
float(entity attacker,entity targ) GetDamageOutFactor; //For calculating quad, berserk, chap, etc., stacking

void(entity corpse, float damage, vector where, entity attacker, float directdmg) DamageCorpse;

//void(entity tfield, vector where, entity thing) FieldExplosion;
//void(entity field) PutFieldWork;

#ifndef COOP_MODE

/*================
monster_death_use (from monsters.qc)

When a monster dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
	//local entity	ent, otemp, stemp;

	// fall to ground
	if (self.flags & #FL_FLY)
		self.flags = self.flags - #FL_FLY;
	if (self.flags & #FL_SWIM)
		self.flags = self.flags - #FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};
#endif


//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
	// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == #MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), #TL_BSP_ONLY, self);
		if (trace_fraction == 1)
			return #TRUE;
		if (trace_ent == targ)
			return #TRUE;
		return #FALSE;
	}

	local vector soffset; // - OfN - hackish fix for turretized sentry guns
	soffset='0 0 0';

	if (targ.classname == "building_sentrygun" && (targ.tf_items & #NIT_TURRET))
		soffset='0 0 -20';

	// OfN - Force field
	traceline(inflictor.origin, targ.origin + soffset, #TL_ANY_SOLID, self);
	if (trace_ent.classname == "force_field")
	{
		//FieldExplosion(trace_ent,trace_endpos,trace_ent);
		//PutFieldWork(trace_ent);
		FieldEvent(trace_ent,trace_endpos,trace_ent);
		return #FALSE;
	}

	traceline(inflictor.origin, targ.origin + soffset, #TL_BSP_ONLY, self);
	if (trace_fraction == 1)
		return #TRUE;
	/*traceline(inflictor.origin, targ.origin + '15 15 0' + soffset, #TL_BSP_ONLY, self);
	if (trace_fraction == 1)
		return #TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0' + soffset, #TL_BSP_ONLY, self);
	if (trace_fraction == 1)
		return #TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0' + soffset, #TL_BSP_ONLY, self);
	if (trace_fraction == 1)
		return #TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0' + soffset, #TL_BSP_ONLY, self);
	if (trace_fraction == 1)
		return #TRUE;*/ // OfN - Fixes dets thru wall?

	return #FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
	// SOLVES BUG ???? // Stack overflow?
	if (targ.is_killed == #TRUE)
	{
		if (IsBuilding(targ))
		{
			local string st;
			RPrint("(OfN WARNING:) Building: '");
			st=GetBuildingName(targ);
			RPrint(st);
			RPrint("' was going to be Killed() again!\n");
			RPrint("Attacker: '");
			st=GetEnemyName(attacker);
			RPrint(st);
			RPrint("\n");
			return;
		}

		if (targ.classname == "player")
		{
			local string st;
			RPrint("(OfN WARNING:) Player: '");
			RPrint(targ.netname);

			if (targ.cutf_items & #CUTF_EXPBODY)
			{
				RPrint(" (with expbody) ");
			}
			else
			{
				RPrint(" (without expbody) ");
			}
			

			RPrint("' is Killed() again!\n");
			RPrint("Attacker: '");
			st=GetEnemyName(attacker);
			RPrint(st);

			if (attacker.classname == "player" && attacker.cutf_items & #CUTF_EXPBODY)
			{
				RPrint(" (with expbody) ");
			}
			else
			{
				RPrint(" (without expbody) ");
			}
			RPrint("\n");		   
		}
		else
		{
			// NOT BUGS, HAPPEN OFTEN WITH BUTTONS ETC..
			
			/*RPrint("(OfN WARNING:) Object: '");
			RPrint(targ.classname);
			RPrint("' is Killed() again!\n");
			RPrint("Attacker: '");
			st=GetEnemyName(attacker);
			RPrint(st);
			if (attacker.classname == "player" && attacker.cutf_items & #CUTF_EXPBODY)
			{
				RPrint(" (with expbody) ");
			}
			else
			{
				RPrint(" (without expbody) ");
			}
			RPrint("\n");			 */
		}
	}		 

	targ.is_killed = #TRUE;
	/////////////////////////////////////
	
	local entity oself;
	//local string db;

//WK Have cursed person respawn immediately
	if (targ.classname == "player") {
		if (targ.penance_time > time) {
			targ.real_frags = targ.real_frags - 1;
			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				targ.frags = targ.real_frags;
			targ.health = 50; //Give em a little so they can die again
			targ.is_killed = #FALSE;
			return; 
		}
	}

	oself = self;
	self = targ;
	
	// don't let sbar look bad if a player
	// modified for Neo mode: I don't want players limited to -99 health
	// for really cool gib explosions.
	if (self.health < -99 && !neo)
		self.health = -99;		

	// doors, triggers, etc // - ofn added sensor, it now calls clientobituary when dead
	if ((self.movetype == #MOVETYPE_PUSH || self.movetype == #MOVETYPE_NONE) && self.classname != "building_camera" && self.classname!="building_sensor") //CH stop bug.
	{	
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

	// bump the monster counter
	if (self.flags & #FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (#MSG_ALL, #SVC_KILLEDMONSTER);
	}

	ClientObituary(self, attacker);
	
	self.takedamage = #DAMAGE_NO;
	self.touch = SUB_Null;

	monster_death_use();
	self.th_die ();

	self = oself;
};


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	//WK Just call TF_T_Damage instead, so no updating two functions
	//WK that do exactly the same thing.
	TF_T_Damage(targ,inflictor,attacker,damage,0,0);
};

 /*
 ============
 TF_T_Damage
 same thing as T_Damage (see above), just with some more details

 T_Flags:
	#TF_TD_IGNOREARMOUR: bypasses the armour of the target
	#TF_TD_NOTTEAM: doesn't damage a team member
	#TF_TD_NOTSELF: doesn't damage self
	#TF_TD_NOKNOCK: Impedes knockation on players (OfN)
	#TF_TD_DONTGIB: Impedes the damage to result in a health of target below -1
	#TF_TD_NOPAIN : Don't do pain frames

 The following is used to determine whether this attack is affected 
 the type of armor the defender is wearing.
 T_AttackType:		
	#TF_TD_OTHER		: type ignored
	#TF_TD_SHOT 		: bullet damage
	#TF_TD_NAIL 		: nailgun damage
	#TF_TD_EXPLOSION		: explosion damage
	#TF_TD_ELECTRICITY	: electricity damage
	#TF_TD_FIRE 		: fire damage
	#TF_TD_MELEE:		: melee damage (WK New Type for CuTF)

	#TF_TD_NOSOUND		: Special Value. Health is adjusted without
					any sound, painframe, etc
					Health is _set_ to damage, not altered.
============
*/

void(entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage =
{
	local	vector	dir;
	local	entity	te; //<-- oldself,
	//local float	save; --> knockem
	local	float	take; 
	//local float mirror; --> knockem
	//local float dist; --> knockem
	//local string output; (?)
	local float knockem;

	//WK -- For LPB calculation
	local string st;

#ifdef QUAKE_WORLD // culled by KK. was QUAKE_WORLD
	if (ceasefire)
		return;
#endif
				   
	if (targ == world)
		return;

	if (!targ.takedamage)
		return;

	//WK Set off land mines
	if (targ.classname == "grenade" && targ.netname == "land_mine")
	{
		targ.think = GuerillaExplode;
		targ.nextthink = time + 0.1;
		return;
	}  

	//BOOKKEEPING
	//WK Store last person who shot martyr into .martyr_enemy so we can give him a frag when we die
	//WK 5-15-08 Fixed old Often bug that search-and-replaced converted all Martyr code into Explosive Body
	if (targ.job & #JOB_MARTYR && deathmsg != #DMSG_MARTYR)
	{
		if (targ.classname == "player" && attacker.classname == "player" && !Teammate(targ, attacker)) {
			targ.martyr_enemy = attacker;
			targ.stored_deathmsg = deathmsg;
		}
	}
	if (targ.classname == "player") //WK Time holding the last time we've been shot
		targ.last_attacked_time = time; //WK For chaplan healing purposes

	//BUTTON TRIGGERING
	if (attacker.classname == "player")
	{
		if (targ.classname != "player" && !IsBuilding(targ) && !IsMonster(targ) && targ.#corpseflag != #STRFLAG_CORPSE)
		{
			if (!Activated(targ,attacker))
			{
				// If an else goal should be activated, activate it
				if (targ.else_goal != 0)
				{
					te = Findgoal(targ.else_goal);
					if (te)
						DoResults(te, attacker, (targ.goal_result & #TFGR_ADD_BONUSES));
				}

				return;
			}
		}
	}

	// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

	// INVINCIBILITY
	// Handled in cpstuff.qc now
	
	if (targ.invincible_finished >= time)
	{
		if (targ.invincible_sound < time)
		{
			sound (targ, #CHAN_ITEM, "items/protect3.wav", 1, #ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
		return;
	}

	//CHAPLAIN CALCULATIONS
	// WK See if they're close enough to chap to get protection
	if (attacker.classname == "player" && attacker.tfstate & #TFSTATE_INSPIRED) {
		knockem = vlen(attacker.origin - attacker.inspirator.origin);
		if (knockem > #CHAPLAN_RADIUS) { //We've strayed from the flock
			sprint(attacker,#PRINT_HIGH,"You have strayed from the flock\n");
			attacker.tfstate = attacker.tfstate - #TFSTATE_INSPIRED;
			attacker.super_damage_finished = 0;
			attacker.items = attacker.items - (attacker.items & #IT_QUAD);
			attacker.effects = attacker.effects - (attacker.effects & #EF_DIMLIGHT);
		}
	}
	if (targ.classname == "player" && targ.tfstate & #TFSTATE_INSPIRED) {
		knockem = vlen(targ.origin - targ.inspirator.origin);
		if (knockem > #CHAPLAN_RADIUS) { //We've strayed from the flock
			sprint(targ,#PRINT_HIGH,"You have strayed from the flock\n");
			targ.tfstate = targ.tfstate - #TFSTATE_INSPIRED;
			targ.super_damage_finished = 0;
			targ.items = targ.items - (targ.items & #IT_QUAD);
			targ.effects = targ.effects - (targ.effects & #EF_DIMLIGHT);
		}
	}

	// OfN - Apply damage factors of attacker and target if any
	// WK 5-15-08 Fixed bug with runes and other sources reducing damage from martyr
	if (deathmsg != #DMSG_MARTYR) {
		damage = damage * GetDamageOutFactor(attacker, targ);
		if (!(T_flags & #TF_TD_IGNORERESIST))
			damage = damage * GetDamageInFactor(targ);
	}

	//WK 1-19-09 Close combat now increases all Melee damage by +50% and reduces all melee damage taken by 20%.
	if (T_AttackType == #TF_TD_MELEE) {
 		if (attacker.cutf_items & #CUTF_CLOSECOMBAT)
			damage = damage * 1.5;
		if (targ.cutf_items & #CUTF_CLOSECOMBAT) 
			damage = damage * 0.8;
	}

	// OfN - Corpses are handled in their own routine
	if (targ.#corpseflag == #STRFLAG_CORPSE)
	{
		DamageCorpse(targ,damage,targ.origin,attacker,#TRUE);
		return;
	}

	// QUAD DAMAGE
	// Handled in cpstuff.qc now
	
	//Play invincible sound when we're immune and taking damage
	if (targ.aura == #AURA_RESIS || targ.#runes & #RUNE_RESIS)
	{
		if (targ.invincible_sound < time) {
			sound (targ, #CHAN_ITEM, "auras/aura1b.wav", 1, #ATTN_NORM);
			targ.invincible_sound = time + 1.5;
		}
	}

	//DAMAGE ADJUSTMENT
	if (deathmsg != #DMSG_MARTYR && !IsMonster(targ))
	{
		//WK 6/1/7 Ping Equalization must be turned on now, since high speed internet is common.
		st = infokey(world,"lpb");
		if (st == "on") {
			//WK Ping fairness code. LPB is < 200 ping
			if (attacker.classname == "player" && targ.classname == "player" && attacker != targ)
			{
				st = infokey(attacker,"ping");
				knockem = 200;
				if (st != string_null)
					knockem = stof(st);
				knockem = (knockem + 1000) / 1200;
				if (knockem < 0.8) knockem = 0.8;
				if (knockem > 1.2) knockem = 1.2;
				damage = damage * knockem;
			}
		}
		if (teamplay & (#TEAMPLAY_LESSSCOREHELP | #TEAMPLAY_LESSPLAYERSHELP))
			damage = TeamEqualiseDamage(targ, attacker, damage);
	}

	//PSIONS carrying objects take 50% more damage
	if (targ.job & #JOB_PSION && targ.job & #JOB_ACTIVE)
		damage = damage * 1.5;

	//MIRROR DAMAGE
	knockem = 0;
	//WK - Check to see if we hit a friend
	if (Teammate(targ, attacker) && (targ != attacker) && attacker.classname == "player" && targ.classname == "player")  {
		//We just hit someone on our team!
		if (T_flags & #TF_TD_NOTTEAM)
		{
			//Direct damage
			if (teamplay & #TEAMPLAY_FULLMIRRORDIRECT)
				knockem = knockem + damage;
			if (teamplay & #TEAMPLAY_HALFMIRRORDIRECT)
				knockem = knockem + damage / 2;
		}
		else
		{
			//Explosive damage
			if (teamplay & #TEAMPLAY_FULLMIRROREXPLOSIVE)
				knockem = knockem + damage;
			if (teamplay & #TEAMPLAY_HALFMIRROREXPLOSIVE)
				knockem = knockem + damage / 2;
		}
		//Don't inflict damage on a (teamkiller or spy)-hitter
		if (knockem > 0)
			if (!(targ.is_feigning || targ.is_undercover) && !(targ.penance_time > time)) //Hurt the jerk!
				TF_T_Damage (attacker, attacker, attacker, knockem, 0, #TF_TD_OTHER);
	}
	//WK Slight demon protection - damage teamkilling attackers
	//WK 4/27/7 We want reflected damage ALWAYS on, not just during mirror teamplay settings
	if (IsMonster(targ) && targ.real_owner != world) {
		targ.armorvalue = 1;
		if (Teammate(targ.real_owner, attacker) && (targ.real_owner != attacker) && attacker.classname == "player")
			TF_T_Damage (attacker, attacker, attacker, 10, 0, #TF_TD_OTHER);
	}

	//WK Friendly Sentrygun protection - you can't hurt friendly sentries
	if (IsBuilding(targ)) {
		if (Teammate(targ, attacker) && (targ != attacker) && (!targ.tf_items & #NIT_SECURITY_CAMERA)) {
			return;
		}
		targ.armorvalue = 1; //CH so that the armors are counted
	}

	// SPECIAL ARMOR CALCULATIONS
	// Special armor reduces damage by 50%, or only 25% vs special armor piercing shots.
	// WK 5-15-08 You no longer lose your special armor when reduced to 0 armor, it just doesn't "work" when at 0 armor
#define NORMAL_SAVE 0.5
#define ARMOR_PIERCING_SAVE 0.75
	if ((targ.armorclass != 0) && (T_AttackType != 0) && targ.armorvalue >= 1)
	{
		local float save_factor;
		save_factor = #NORMAL_SAVE;
		if (attacker.cutf2_items & #CUTF2_ARMOR_PIERCING) save_factor = #ARMOR_PIERCING_SAVE;

		if ((targ.armorclass & #AT_SAVESHOT) && (T_AttackType == #TF_TD_SHOT)) {
			damage = floor(damage * save_factor);
			//WK 1/7/7 Removed damage caps now that sniper damage is not buggily high.
			//Print message when people strike kevlar
			if(targ.classname == "player" && attacker.classname == "player" && (deathmsg == #DMSG_SNIPERRIFLE || deathmsg == #DMSG_SNIPERHEADSHOT || deathmsg == #DMSG_SNIPERLEGSHOT))
			{
					sprint(attacker,#PRINT_HIGH,"You hit kevlar\n");
			}
		}
		else if ((targ.armorclass & #AT_SAVEMELEE) && T_AttackType == #TF_TD_MELEE)
		{
			damage = floor(damage * save_factor);

			//Melee armor gives 40% chance to negate damage
			if ((targ.velocity_x > 0 || targ.velocity_y > 0 || targ.velocity_z > 0) && random() > 0.6)
				return;
			//And cannot be penetrated by a backstab
			T_flags = T_flags - (T_flags & #TF_TD_IGNOREARMOUR);
		}
		else if ((targ.armorclass & #AT_SAVEEXPLOSION) && (T_AttackType == #TF_TD_EXPLOSION))
			damage = floor(damage * save_factor);
		else if ((targ.armorclass & #AT_SAVEELECTRICITY) && (T_AttackType == #TF_TD_ELECTRICITY || T_AttackType == #TF_TD_NAIL))
			damage = floor(damage * save_factor);
		else if ((targ.armorclass & #AT_SAVEFIRE) && (T_AttackType == #TF_TD_FIRE))
			damage = floor(damage * save_factor);
	}

	//ARMOR PROTECTION CALCULATION
	// save damage based on the target's armor level
	if (T_flags & #TF_TD_IGNOREARMOUR)
	{
		take = damage;
		knockem = 0;
	}
	else
	{
		knockem = ceil(targ.armortype*damage);
		if (knockem >= targ.armorvalue)
		{
			knockem = targ.armorvalue;
			if (!neo || targ != neoLives) // modded for Neo mode
			{
				targ.armortype = 0; // lost all armor
				//WK 5-15-08 No longer strip special armors targ.armorclass = 0; // lost special armor
				targ.items = targ.items - (targ.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));
			}
		}
		//WK Flags prevent armor damage too
		if (T_flags & #TF_TD_NOTTEAM)
		{
			if (Teammate(targ, attacker) && (targ != attacker)) 
			{
				if (teamplay & #TEAMPLAY_NOARMORDIRECT)
					targ.armorvalue = targ.armorvalue;
				else if (teamplay & #TEAMPLAY_HALFARMORDIRECT)
					targ.armorvalue = targ.armorvalue - knockem / 2;
				else 
					targ.armorvalue = targ.armorvalue - knockem;	
			}
			else
					targ.armorvalue = targ.armorvalue - knockem;
		}
		else
		{
			if (Teammate(targ, attacker) && (targ != attacker))
			{
				if (teamplay & #TEAMPLAY_NOARMOREXPLOSIVE)
					targ.armorvalue = targ.armorvalue;
				else if (teamplay & #TEAMPLAY_HALFARMOREXPLOSIVE)
					targ.armorvalue = targ.armorvalue - knockem / 2;
				else
					targ.armorvalue = targ.armorvalue - knockem;
			}
			else
					targ.armorvalue = targ.armorvalue - knockem;
		}
		//		targ.armorvalue = targ.armorvalue - knockem;
		take = ceil(damage-knockem);
	}
	// add to the damage total for clients, which will be sent as a single
	// message at the end of the frame
	// FIXME: remove after combining shotgun blasts?
	if (targ.flags & #FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + knockem;
		targ.dmg_inflictor = inflictor;
	}

	//Recoilless Rifles sets the NOKNOCK flag
	if (attacker.cutf2_items & #CUTF2_RECOILLESS_RIFLE) T_flags = T_flags | #TF_TD_NOKNOCK;

	// KNOCKATION CALCULATION (I.e., Recoil from being shot)
	// Aspect of HWGUY and Recoilles Rifles eliminates knockation, Gymnast doubles it, Black Hole Guns invert it
	//WK 1-19-09 Added full knocktation support
	if (!(T_flags & #TF_TD_NOKNOCK)) // OfN - No knockation if the appropiate flag is set
		if ((inflictor != world) && (targ.movetype == #MOVETYPE_WALK))
		{
			knockem = 1;
			//WK People with Aspect of HWGUY are immune to knockation
			//WK 5-15-08 ...only if they are on the ground now!
			if (targ.cutf_items & #CUTF_HWGUY && targ.flags & #FL_ONGROUND) knockem = 0;
			//WK 5-15-08 Martyrs now lose Aspect of HWGUY when active
			if (targ.job & #JOB_MARTYR && targ.job & #JOB_ACTIVE && T_AttackType != #TF_TD_SHOT) knockem = 1;
			// Nail Gren doesn't knock ppl
			if (deathmsg == #DMSG_GREN_NAIL) knockem = 0;
			if (deathmsg == #DMSG_CLUSTER_ROCKET) knockem = 0; //WK 1/7/7 Clusters are ineffective since they push people away
			if (knockem)
			{
				// give them some immunity to cheat check
				//targ.immune_to_check = time + (damage / 20);
				makeImmune(targ,time+(damage/20));

				dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
				dir = normalize(dir);

				//Black Hole Guns and Void Body reverse direction - if they have both, then they cancel out
				if ((attacker.cutf2_items & #CUTF2_BLACK_HOLE_GUN || targ.cutf2_items & #CUTF2_VOID_BODY) && !(attacker.cutf2_items & #CUTF2_BLACK_HOLE_GUN && targ.cutf2_items & #CUTF2_VOID_BODY)) { 
					dir = dir * -1; //Negative knockation
					if (targ.flags & #FL_ONGROUND) dir_z = 0; //Don't pull people off the ground
				}

				// Increase kickback for smaller weapons
				if ( (damage < 60) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname != targ.netname)) 
					targ.velocity = targ.velocity + dir * damage * 11;
				else						
					targ.velocity = targ.velocity + dir*damage*8;
				if ( (rj > 1) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname == targ.netname)) 
					targ.velocity = targ.velocity + dir * damage * rj;

				//Double Knockback buyable options
				if (attacker.cutf2_items & #CUTF2_MASSIVE_ATTACK)
					targ.velocity = targ.velocity + dir * damage * 2;
				if (targ.classname == "player" && targ.cutf_items & #CUTF_GYMNAST)
					targ.velocity = targ.velocity + dir * damage * 2; //WK 1/7/7 Was x8
		}
	}

	// TEAMPLAY FLAGS
	if (attacker.classname == "player" && targ.classname == "player")	{
		if (T_flags & #TF_TD_NOTTEAM)	{
			if (Teammate(targ, attacker) && (targ != attacker)) {
				if (teamplay & #TEAMPLAY_NODIRECT) return;
				else if (teamplay & #TEAMPLAY_HALFDIRECT) take = take / 2;
			}
		}
		else	{
			if (Teammate(targ, attacker) && (targ != attacker)) {
				if (teamplay & #TEAMPLAY_NOEXPLOSIVE) return;
				else if (teamplay & #TEAMPLAY_HALFEXPLOSIVE) take = take / 2;	
			}
		}
	}

	if (T_flags & #TF_TD_NOTSELF) {
		if (targ == attacker) return;
	}

	// You take a minimum of one damage per hit
	if (take < 1) take = 1;

	//Make thief visible when he's shot
	if (take > 1 && targ != attacker && (targ.job & #JOB_THIEF && (targ.job & #JOB_ACTIVE || targ.job & #JOB_FULL_HIDE)))
		if (!Teammate(targ, attacker))
			RevealThief(targ,#TRUE);

	targ.health = targ.health - take; //Do the damage!

	if (targ.armorvalue < 1) 
	{
		// WK 5-15-08 Changed armor so that nobody gets stripped of special armors, but they just don't work at 0 armor.
		// This change for neo mode would be a half-bug anyway, since it would work for everyone, not just Neo
		//if (!neo) targ.armorclass = 0; // lost special armor
		targ.armorvalue = 0;
	}

	if (targ.health < 1 && targ.health > 0) //WK Stop the scoreboard coming up
		targ.health = 1;
		
	if (targ.health <= 0) {

		//WK 5-15-08 Martyr auto-triggers now... except if we shoot ourselves
		if (targ.job & #JOB_MARTYR && !(targ.job & #JOB_ACTIVE) && attacker != targ) {
			te = self;
			self = targ;
			self.health = 1;
			JobMartyr();
			self.job = self.job | #JOB_TIRED; //Set that we are in automartyr_mode
			sound (self, #CHAN_VOICE, "shaka/martyr.wav", 1, #ATTN_NORM);
			self = te;
			return;
		}

		// If we dont have to gib the target, just set its HP to -1
		if (T_flags & #TF_TD_DONTGIB)
			targ.health = -1;

		if (inflictor.classname == "detpack" && inflictor.weaponmode == 1 && inflictor.enemy == targ)
			deathmsg = #DMSG_DETPACK_DIS;

		//WK Autotrigger martyr - OfN - Now exp.body
		//WK 5-15-08 Let's autotrigger Martyr again (above)
		if ((targ.cutf_items & #CUTF_EXPBODY) && attacker != world && targ.is_abouttodie == #FALSE)
		{
			targ.health = 1;
			targ.martyr_enemy=attacker;
			ExpBody(targ);
			targ.is_abouttodie = #TRUE;
			return;
		}

		//WK Make sure the world doesn't have a bastard level (<- OfN this is funny)
		if (attacker.classname != "player" || targ.classname != "player") {
			//bprint(#PRINT_MEDIUM,"Non player death or kill\n");
			Killed(targ, attacker);
			return;
		}

#ifdef QUAKE_WORLD
		//WK Handle Total Bastard Checking
		//If they kill more than a certain number of friends in a certain period, they are booted
		// Neo mode: don't count as teamkill when there's no Neo in the game
		// WK Fixed bug with this always being off in Neo mode (it was !neo && !neoLives). Looks funny, though
		if (!(neo && neoLives != world) && Teammate(targ, attacker) && targ != attacker && !(targ.penance_time > time) && !(targ.is_undercover) && prematch < time)
		{
			//A teamkill
			local string st;
			local float threshold;
			threshold = 10; //WK 5-15-08 Default to 10 kills now
			st = infokey(world, "curse");
			if (st != string_null)
				threshold = stof(st);

			attacker.ff_count = attacker.ff_count + 1; //Increase their bastard rating
			if (threshold >= 1) {
				if (attacker.ff_count >= threshold) createBastard(attacker,threshold);
				if ((attacker.ff_count == threshold - 1) || (attacker.ff_count == threshold - 0.5)) {
					sprint (attacker, #PRINT_MEDIUM, "One more teamkill and you will be cursed.\n");
				}
			}
		}
		if (!Teammate(targ, attacker) || targ.penance_time > time) {
			attacker.ff_count = attacker.ff_count - 0.5;
			if (attacker.ff_count < 0) attacker.ff_count = 0;
		}
#endif

		if (targ.penance_time > time) //A penitent loses frags
			Killed(targ, targ);
		else
			Killed(targ, attacker);
		return;

	}		 

	//Should we do any pain stuff?
	if (T_flags & #TF_TD_NOPAIN)
		return; // Just end

	//React to the damage by calling the pain function on the target, if any
	te = self;
	self = targ;
	if (self.th_pain) self.th_pain (attacker, take);
	self = te;
};

#ifdef COOL_GIBS
void(entity inflictor, float radius, float extent) CoolExplosion;
float cool_gibs;
#endif

/* OfN - Same as radius damage but with fire, used for napalm grens TODO: Mindmg, maxdmg
WK 5-15-08 Added a radius parameter so you can have low damage high radius attacks or vice versa
Although this only seems to be used with napalm grenades right now
============
T_RadiusFireDamage
============
*/
void(vector place, entity inflictor, entity attacker, float damage, float fireprob, float radius) T_RadiusFireDamage =
{
	local entity head;
	local float finaldmg;

	//WK 5-15-08 Added explicit radius parameter (was a radius of damage+50)
	if (radius == 0) radius = damage+50;
	head = findradius(place, radius);
	while (head)
	{
		//WK Set off all land mines in blast radius
		if (head.classname == "grenade" && head.netname == "land_mine")
		{
			head.think = GuerillaExplode;
			head.nextthink = time + 0.1;
		}
		else if (head.takedamage)// && head.health > 0)
		{
			finaldmg = 1 - vlen(place - head.origin)/radius; //Percentage of range
			finaldmg = damage * finaldmg;

			if (finaldmg > 0)
			{				 
				TF_T_Damage(head, inflictor, attacker, finaldmg, #TF_TD_NOKNOCK | #TF_TD_DONTGIB, #TF_TD_FIRE);

				if (random() <= fireprob)
				{
					// set 'em on fire
					other = head; 
					Napalm_touch();
					if (other.classname == "player")
						stuffcmd(other, "bf\nbf\n");
				}
			}
		}

		head = head.chain;
	}

	// Push gibs and heads if enabled 
	// (you may think this could be optimized by pushing the stuff in the loop above
	// and its true, but doing the scan again lets the gibs/heads that just appeared to be
	// pushed by its first explosion and thats cool) 
	#ifdef COOL_GIBS	
	CoolExplosion(inflictor, damage,20);
	#endif
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float	points;
	local	entity	head, te; 
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			//WK Set off all land mines in blast radius
			if (head.classname == "grenade" && head.netname == "land_mine")
			{
				if (deathmsg != #DMSG_LAND_MINE) { 
					//head.has_tesla = 2; //- ofn - ur mine explodes better than is destroyed
					head.think = GuerillaExplode;
					head.nextthink = time + 0.1;
				}
			}
			// Check for TeamFortress Goals that can be triggered by Detpacks
			else if (head.classname == "info_tfgoal")
			{
				if (inflictor.classname == "detpack")
				{
					// Don't activate timer goals
					if ((head.goal_activation & #TFGA_TOUCH_DETPACK) && (head.search_time == 0))
					{
						traceline (inflictor.origin, head.origin, #TL_BSP_ONLY, inflictor);

						if (trace_fraction == 1)
						{
							// Does the AP match the AP Criteria?
							if (Activated(head,attacker))
							{
								DoResults(head, attacker, #TRUE);
							}
							else
							{
								// If an else goal should be activated, activate it
								if (head.else_goal != 0)
								{
									te = Findgoal(head.else_goal);
									if (te)
										DoResults(te, attacker, (head.goal_result & #TFGR_ADD_BONUSES));
								}

								return;
							}
						}
					}
				}
			}
			else if (head.takedamage)// && head.health > 0)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = rint(points * 0.75);
				//WK 5-15-08 Remove lame invincible blocking cameras (that only take 10 damage per rocket), replaced with damage reduction
				if (head.classname == "building_camera")
					points = points / 2;

				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{
						TF_T_Damage (head, inflictor, attacker, points, #TF_TD_NOTTEAM, #TF_TD_EXPLOSION);						  
					}
					//Turrets have fucked up bounding boxes due to their natures
					//So we have to make them susceptible to blast damage here
					//But only 50% damage, since they are turrets...
					else if ((head.classname == "building_sentrygun" || head.classname == "building_tesla") && head.tf_items & #NIT_TURRET) {
							points = rint(points / 2);
							TF_T_Damage (head, inflictor, attacker, points, #TF_TD_NOTTEAM, #TF_TD_EXPLOSION);						
					}					 
				}
			}			 
		}
		head = head.chain;
	}

	// Push gibs and heads if enabled 
	// (you may think this could be optimized by pushing the stuff in the loop above
	// and its true, but doing the scan again lets the gibs/heads that just appeared to be
	// pushed by its first explosion and thats cool) 
	#ifdef COOL_GIBS	
	CoolExplosion(inflictor, damage,50);
	#endif
};

#ifdef COOL_GIBS
float() crandom;

void(entity inflictor, float radius, float extent) CoolExplosion =
{
	// If this is disabled, go away..
	if (!cool_gibs)
		return;

	local entity head;
	local vector dir;
	local float dist, intensity;

	head = findradius(inflictor.origin, radius+extent);

	while (head)
	{
		if (head.#coolflag == #STRFLAG_COOL)
		if (CanDamage(head,inflictor))
		{
			// Get distance between the explosion and this thing
			dist = vlen(head.origin - inflictor.origin);

			// Calculate the intensity based on proximity of explosion (1 = same place, 0 = as far away it shouldnt push this)
			intensity = 1 - ((radius+extent) - ((radius+extent) - dist)) / (radius+extent);
			
			// Calculate the direction the thing will be pushed to			  
			dir = head.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
			dir = normalize(dir);

			// Wheeeeeee, throw it away!
			head.velocity = head.velocity + dir*radius*intensity*4; 		   

			// Special: if this is set onground use a randomized*intensity positive velocity_z instead
			if (head.flags & #FL_ONGROUND)
			{
				head.flags = head.flags - #FL_ONGROUND;
				head.velocity_z = 140*intensity + radius*2*intensity + random()*230 + intensity*random()*120;
			}			 

			// Do an appropiate spin movement if we arent spinning currently and sometimes even if we are
			if (head.avelocity == '0 0 0' || random() < 0.2)
			{
				// is this a head?
				if (head.classname != "gib")
					head.avelocity = crandom() * '0 600 0';
				else // should be a gib then
				{
					head.avelocity_x = crandom()*600;
					head.avelocity_y = crandom()*600;
					head.avelocity_z = crandom()*600;
				}
			}
		}		 

		head = head.chain;
	}
};
#endif

/*
============
T_BeamDamage // OfN - Used by bio grens
============
*/

void(entity inflictor, entity attacker, float damage) T_BeamDamage =
{
	local	float	points;
	local	entity	head;
	
	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage && head.health > 0)
		{
			points = 0.5*vlen (inflictor.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			/*if (head == attacker)
				points = points * 0.5;*/
			if (points > 0)
			{
				if (CanDamage (head, inflictor))
				{
				
					//if (head.classname == "monster_shambler") 					
					//	T_Damage (head, attacker, attacker, points*0.5);
					//else

						TF_T_Damage (head, inflictor, attacker, points,#TF_TD_NOKNOCK,0);
					  
				}
			}
		}
		head = head.chain;
	}
};
