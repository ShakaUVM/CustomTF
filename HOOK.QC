/*
	TeamFortress 1.38	-	29/11/96

	TeamFortress Software
	Robin Walker, John Cook, Ian Caughley.

	Original Code by "Mike" <amichael@asu.alasu.edu>
	QuakeWorld version by Wedge
*/

/*
	Modified for CustomTF 2.3 3/28/00
	William Kerney
	Removed the ability to hook onto or damage teammates
	Stopped some crashing bugs with it
*/

// QuakeWorld version

/*
===========================================================================
Quakeworld-friendly grapple hook code by Wedge (Steve Bond)
		   visit Quake Command http://www.nuc.net/quake 


Original 'Morning Star' (Grapple Hook) by "Mike" <amichael@asu.alasu.edu> 
I took care to preserve the speed and damage values of the original
Morning Star. Depending on latency, performance should be near exact.
===========================================================================
*/

// prototypes for WEAPONS.QC functions
float() crandom;

//
// Reset_Grapple - Removes the hook and resets its owner's state.
//				   expects a pointer to the hook
//
void (entity rhook) Reset_Grapple =
{
	if (!rhook.owner) // OfN - Fixes crash?
	{
		dremove(rhook);
		return;
	}

	sound (rhook.owner, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NONE);
	rhook.owner.on_hook = #FALSE;
	rhook.owner.hook_out = #FALSE;
	rhook.owner.fire_held_down = #FALSE;
	rhook.owner.weaponframe = 0;

	rhook.think = SUB_Remove;
	rhook.nextthink = time;
};

//
// Grapple_Track - Constantly updates the hook's position relative to
//				   what it's hooked to. Inflicts damage if attached to
//				   a player that is not on the same team as the hook's
//				   owner.
//
void () Grapple_Track =
{
		//local   vector  spray;

		// drop the hook if owner is dead or has released the button
		if (!self.owner.on_hook || self.owner.health <= 0)
		{
				Reset_Grapple (self);
				return;
		}
	if (self.owner.health <= 0 || !self.owner.is_connected) //CH does a real check if dead
		{
		self.think = SUB_Remove;
		self.nextthink = time;
		if (self.goalentity)
		{
			  self.goalentity.think = SUB_Remove;
				self.goalentity.nextthink = time;
				if (self.goalentity.goalentity)
				{
					self.goalentity.goalentity.think = SUB_Remove;
					self.goalentity.goalentity.nextthink = time;
			  }
		}
		Reset_Grapple (self);
			return;
		}

	//WK
	  if (self.enemy.classname == "player" && Teammate(self.enemy, self.owner)) {
		Reset_Grapple (self);
		return;
	  }

	  deathmsg = #DMSG_HOOK;
	  if (self.enemy.classname == "player") {
				T_Damage (self.enemy, self, self.owner, 2);
			if (self.enemy.health <= 0) {
			Reset_Grapple (self);
			return;
			}
	  }
	  // If the hook is not attached to the player, constantly
		// copy the target's velocity. Velocity copying DOES NOT work properly
		// for a hooked client. 
		if (self.enemy.classname != "player")
				self.velocity = self.enemy.velocity;
		//WK 2-2-09
		//We now can do this, since we record .last_velocity on players
		if (self.enemy.classname == "player")
			self.velocity = self.enemy.last_frame_velocity;

		self.nextthink = time + 0.1;
};

//
// MakeLink - spawns the chain link entities
//
entity () MakeLink =
{
		newmis = spawn ();

		newmis.movetype = #MOVETYPE_FLYMISSILE;
		newmis.solid = #SOLID_NOT;
		newmis.owner = self;// SELF is the hook!

		newmis.avelocity = '200 200 200';

		setmodel (newmis, "progs/s_spike.mdl");
		setorigin (newmis, self.origin);
		setsize (newmis, '0 0 0' , '0 0 0');

		return	newmis;
};

//
// Remove_Chain - Removes all chain link entities; this is a separate
//				  function because CLIENT also needs to be able
//				  to remove the chain. Only one function required to
//				  remove all links.
//
void () Remove_Chain =
{
	self.think = SUB_Remove;
	self.nextthink = time;

	if (self.goalentity)
	{
		self.goalentity.think = SUB_Remove;
		self.goalentity.nextthink = time;

		if (self.goalentity.goalentity)
		{
				self.goalentity.goalentity.think = SUB_Remove;
				self.goalentity.goalentity.nextthink = time;
		}
	}
};

//
// Update_Chain - Repositions the chain links each frame. This single function
//				  maintains the positions of all of the links. Only one link
//				  is thinking every frame. 
//
void () Update_Chain =
{
	local vector temp;

	if (!self.owner.hook_out)
	{
		self.think = Remove_Chain;
		self.nextthink = time;
		return;
	}

	if (vlen(self.origin - self.owner.origin) >= 3000)
	{
		Reset_Grapple (self);
		return;
	}
	//CH Using a show grapple loc thing,  it was updating while dead.
	if (self.owner.health <= 0 || !self.owner.is_connected)
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		if (self.goalentity)
		{
			self.goalentity.think = SUB_Remove;
			self.goalentity.nextthink = time;
			if (self.goalentity.goalentity)
			{
				self.goalentity.goalentity.think = SUB_Remove;
				self.goalentity.goalentity.nextthink = time;
			}
		}
		Reset_Grapple (self);
		return;
	}

	temp = (self.owner.hook.origin - self.owner.origin);

	// These numbers are correct assuming 3 links.
	// 4 links would be *20 *40 *60 and *80
	setorigin (self, self.owner.origin + temp * 0.25);
	setorigin (self.goalentity, self.owner.origin + temp * 0.5);
	setorigin (self.goalentity.goalentity, self.owner.origin + temp * 0.75);

	self.nextthink = time + 0.1;
};

//
// Build_Chain - Builds the chain (linked list)
//
void () Build_Chain =
{
		self.goalentity = MakeLink();
		self.goalentity.think = Update_Chain;
		self.goalentity.nextthink = time + 0.1;
		self.goalentity.owner = self.owner;

		self.goalentity.goalentity = MakeLink();
		self.goalentity.goalentity.goalentity = MakeLink();
};

//
// Check_Overhead - Makes sure there is sufficient headroom above the player
//					so that setorigin doesn't stick them into a wall. I tried
//					to compare pointcontents, but that was too flaky.
//
float () Check_Overhead =
{
		local	vector	src;
		local	vector	end;

		makevectors (self.owner.angles);

		// The following comparisons could be optimized by doing away with
		// SRC and END, and plugging the values directly into the traceline
		// function calls. Using SRC and END made debugging easier. You
		// decide if it's worth it.

		// quick check right above head
		src = self.owner.origin - '0 0 24';
		end = self.owner.origin - '0 0 24';
		traceline (src, end, #TL_ANY_SOLID, self.owner);
		if (trace_fraction != 1.0)
				return #FALSE;

		src = self.owner.origin - '0 0 24' - v_forward * 16;
		end = self.owner.origin - '0 0 24' - v_forward * 16 + '0 0 58';
		traceline (src, end, #TL_ANY_SOLID, self.owner);
		if (trace_fraction != 1.0)
				return #FALSE;

		src = self.owner.origin - '0 0 24' + v_forward * 16;
		end = self.owner.origin - '0 0 24' + v_forward * 16 + '0 0 58';
		traceline (src, end, #TL_ANY_SOLID, self.owner);
		if (trace_fraction != 1.0)
				return #FALSE;

		src = self.owner.origin - '0 0 24' - v_right * 16;
		end = self.owner.origin - '0 0 24' - v_right * 16 + '0 0 58';
		traceline (src, end, #TL_ANY_SOLID, self.owner);
		if (trace_fraction != 1.0)
				return #FALSE;

		src = self.owner.origin - '0 0 24' + v_right * 16;
		end = self.owner.origin - '0 0 24' + v_right * 16 + '0 0 58';
		traceline (src, end, #TL_ANY_SOLID, self.owner);
		if (trace_fraction != 1.0)
				return #FALSE;

		return #TRUE;
};


//
// Anchor_Grapple - Tries to anchor the grapple to whatever it touches
//
void () Anchor_Grapple =
{
	local float test;

	if (other == self.owner)
		return;

	// DO NOT allow the grapple to hook to any projectiles, no matter WHAT!
	// if you create new types of projectiles, make sure you use one of the
	// classnames below or write code to exclude your new classname so
	// grapples will not stick to them. OfN "rocket" was "missile"
	if (other.classname == "rocket" || other.classname == "grenade" || other.classname == "spike" || other.classname == "hook" || other.classname == "pipebomb") //CH maybe fix crash?
			return;

	//if (isBuilding(other)) //WK don't hook onto buildings?
	//	return;

	// Don't stick the the sky.
	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		Reset_Grapple (self);
		return;
	}

	sound (self, #CHAN_WEAPON, "player/axhit2.wav", 1, #ATTN_NORM);
	//WK Only deal the initial damage to buttons so we can open stuff
	if (other.takedamage)
		if (other.classname == "func_button")
			T_Damage (other, self, self.owner, 1);

	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';

	// conveniently clears the sound channel of the CHAIN1 sound,
	// which is a looping sample and would continue to play. Tink1 is
	// the least offensive choice, as NULL.WAV loops and clogs the
	// channel with silence
	sound (self.owner, #CHAN_WEAPON, "weapons/tink1.wav", 1, #ATTN_NORM);

	if (!self.owner.button0)
	{
		Reset_Grapple (self);
		return;
	}

	// our last chance to avoid being picked up off of the ground.
	// check over the client's head to make sure there is one unit
	// clearance so we can lift him off of the ground.
	test = Check_Overhead ();
	if (!test)
	{
		Reset_Grapple (self);
		return;
	}

	self.owner.on_hook = #TRUE;

	if (self.owner.flags & #FL_ONGROUND)
	{
		self.owner.flags = self.owner.flags - #FL_ONGROUND;
		setorigin(self.owner,self.owner.origin + '0 0 1');
	}

	// CHAIN2 is a looping sample. Use LEFTY as a flag so that client.qc
	// will know to only play the tink sound ONCE to clear the weapons
	// sound channel. (Lefty is a leftover from AI.QC, so I reused it to
	// avoid adding a field)
	self.owner.lefty = #TRUE;

	self.enemy = other;// remember this guy!
	self.think = Grapple_Track;
	self.nextthink = time;
	self.solid = #SOLID_NOT;
	self.touch = SUB_Null;
};


//
// Throw_Grapple - called from WEAPONS.QC, 'fires' the grapple
//
void () Throw_Grapple =
{
		if (self.hook_out)// reject subsequent calls from player.qc
				return;

		KickPlayer(-1, self);

		// chain out sound (loops)

		newmis = spawn();
		newmis.movetype = #MOVETYPE_FLYMISSILE;
		newmis.solid = #SOLID_BBOX;
		newmis.owner = self;// newmis belongs to me
		self.hook = newmis;// This is my newmis
		newmis.classname = "hook";

		makevectors (self.v_angle);
		newmis.velocity = v_forward * 800;
//		newmis.avelocity = '0 0 -500';

		// set the facing of the grapple
		newmis.angles = vectoangles(newmis.velocity);

		newmis.touch = Anchor_Grapple;
		newmis.think = Build_Chain;
		newmis.nextthink = time + 0.1;// don't jam newmis and links into same packet

		setmodel (newmis,"progs/hook.mdl");
		setorigin (newmis, self.origin + v_forward * 16 + '0 0 16');
		setsize(newmis, '0 0 0' , '0 0 0 ');

		self.hook_out = #TRUE;
		self.fire_held_down = #TRUE;
};

//
// Service_Grapple - called each frame by CLIENT.QC if client is ON_HOOK
//
void () Service_Grapple =
{
		local	vector	hook_dir;

		// drop the hook if player lets go of button
		if (!self.button0)
		{
				self.fire_held_down = #FALSE;
				
				if (self.current_weapon == #WEAP_HOOK)
					Reset_Grapple (self.hook);
		}
		// If hooked to a player, track them directly!
		if (self.hook.enemy.classname == "player")
				hook_dir = (self.hook.enemy.origin - self.origin);
		// else, track to hook
		else if (self.hook.enemy.classname != "player")
				hook_dir = (self.hook.origin - self.origin);

		// set the facing of the grapple
//		self.hook.angles = vectoangles(self.hook.velocity);

		self.velocity = normalize(hook_dir) * self.maxspeed * 1.5;
		if ( vlen(hook_dir) <= 100 && self.lefty)	// cancel chain sound
		{
				// If there is a chain, ditch it now. We're
				// close enough. Having extra entities lying around
				// is never a good idea.
				if (self.hook.goalentity)
				{ 
						self.hook.goalentity.think = Remove_Chain;
						self.hook.goalentity.nextthink = time;
				}

				self.lefty = #FALSE;	// we've reset the sound channel.
		}
};
