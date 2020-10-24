/*======================================================
	MEDIC.QC

	SB-1 Tech			15/12/2000
========================================================
Functions for the MEDIC class and associated weaponry						   
========================================================*/

// Functions within this file:

float (entity targ, entity attacker, float prob, entity inflictor) BioInfect;
void () BioGrenadeTouch;
void () BioGrenadeExplode;

// Functions referenced from this file:

void() BioInfection_Decay;
void(entity p) TeamFortress_SetSpeed;

//=========================================================================
// Attacker attempts to infect targ.
float (entity targ, entity attacker, float prob, entity inflictor) BioInfect =
{
	local entity BioInfection;
	local float r;
	
	// If they have medikit, don't infect them.
	if (targ.weapons_carried & #WEAP_MEDIKIT)
		return #FALSE;
	
	// Only allow one infection at once.
	if (targ.tfstate & #TFSTATE_INFECTED)
		return #FALSE;
	
	if (targ.#runes & #RUNE_RESIS)
		return #FALSE;
	
	if (Teammate(targ, attacker) && targ != attacker)
		return #FALSE;
	
	if (targ.invincible_finished > time)
		return #FALSE;
	
	r = random();
	if (prob < r)
		return #FALSE;
	
	r = random();
	//Melee armour stops infection 75% of the time
	if (targ.tf_items & #NIT_GEL && r < 0.75)
		return #FALSE;

	local string desc;
	if (inflictor.netname == "special_mine")
		desc = "mine";
	else
		desc = "grenade";

	if (attacker == targ) // we infected ourselves! lol
	{
		sprint(attacker,#PRINT_HIGH,"You infect yourself!\n");
		
		teamprefixsprint(attacker.team_no,attacker);
		teamsprint6(attacker,attacker.netname,"infects himself!\n","","","","");
	}
	else
	{
		if (IsMonster(targ))
		{
			local string tmps;
			tmps = GetMonsterName(targ);
			sprint(attacker,#PRINT_HIGH,"Your ",desc," infects the ",tmps," ",targ.netname);
			sprint(attacker,#PRINT_HIGH,"!\n");
			
			// Inform owner
			sprint(targ.real_owner,#PRINT_HIGH,"Your ",tmps," ",targ.netname," has been infected!\n");

			teamprefixsprint(targ.real_owner.team_no,targ.real_owner);
			teamsprint6(targ.real_owner,"The ",tmps," ",targ.netname," has been infected!\n","");
		}
		else
		{
			sprint(attacker,#PRINT_HIGH,"Your ",desc," infects ",targ.netname,"!\n");

			sprint(targ,#PRINT_HIGH,"You have been infected by a biological ",desc,"!\n");

			teamprefixsprint(targ.team_no,targ);
			teamsprint6(targ,targ.netname," has been infected!\n","","","","");
		}
	}

	if (IsMonster(targ))
	{
		targ.tfstate = targ.tfstate | #TFSTATE_INFECTED;
	
		BioInfection = spawn ();
		BioInfection.classname = "timer";
		BioInfection.netname = "biotimer";
		BioInfection.owner = attacker;
		BioInfection.nextthink = time + 2;
		BioInfection.think = BioInfection_MonsterDecay;
		BioInfection.enemy = targ;
	
		targ.infection_team_no = attacker.team_no;
	}
	else
	{
		targ.tfstate = targ.tfstate | #TFSTATE_INFECTED;
	
		BioInfection = spawn ();
		BioInfection.classname = "timer";
		BioInfection.netname = "biotimer";
		BioInfection.owner = targ;
		BioInfection.nextthink = time + 2;
		BioInfection.think = BioInfection_Decay;
		BioInfection.enemy = attacker;
	
		targ.infection_team_no = attacker.team_no;
	}
	
	return #TRUE;
};

//=========================================================================
// Touch function for the bioinfection grenade.

void() BioGrenadeTouch =
{
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
	
	if (other == self.owner)
		return; 	// don't explode on owner

	// Thrown grenades don't detonate when hitting an enemy
	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound 
};

//=========================================================================
// Biogrenade explosion. Does not do much damage...but infects...

void() BioGrenadeExplode =
{
	// Toxic fluids do some damage on explosion
	deathmsg = #DMSG_BIOEXPLOSION;
	T_BeamDamage(self,self.owner,60);

	local entity dier; // He's the dier and he's dying
	
	dier = findradius(self.origin, #BIO_GREN_RADIUS);
	while (dier)
	{
		if (dier.classname == "player" && dier.health > 0) {
			if (CanDamage(dier,self)) {
				if (dier.takedamage) {
					BioInfect(dier, self.owner, 1, self); // was 0.7
				}
			}
		}
		else {
			if (IsMonster(dier))
					if (CanDamage(dier,self))
						BioInfect(dier, self.owner, 1, self);
		}
		dier = dier.chain;
	}
	
	sound(self,#CHAN_WEAPON,"misc/vapeur2.wav",1,#ATTN_NORM); 

	SpawnSprite(3,#SPRITE_ABLAST,self.origin,'0 0 0',#SPRITEMOVE_UP,0.1);

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

float(entity doc, entity patient, vector org) CureAdverseEffects =
{
	local entity te;
	
	// remove concussion from player
	// Try to find a concusstimer entity for this player
	te = find(world, classname, "timer");
	while (((te.owner != patient) || (te.think != ConcussionGrenadeTimer)) && (te != world))
	{
		te = find(te, classname, "timer");
	}

	if (te != world)
	{
		SpawnBlood(org, 20);
		patient.tfstate = patient.tfstate - (patient.tfstate & #TFSTATE_CONCUSSIONED);
		if (doc == patient)
			sprint(doc, #PRINT_HIGH, "The ground is behaving itself now.\n");
		else
		{
			sprint(patient, #PRINT_HIGH, doc.netname, " heals you of your concussion\n");
			sprint(doc, #PRINT_HIGH, "You heal ", patient.netname, "'s concussion\n");
		}
		// Give the medic a frag for doing it, only if it was caused by an enemy
		if (!Teammate(doc, te))
		{
			doc.real_frags = doc.real_frags + 1;
			if (!(toggleflags & #TFLAG_TEAMFRAGS))
				doc.frags = doc.real_frags;
		}
		TeamFortress_SetSpeed(patient);
		dremove(te);
	}

	// remove hallucination from player
	// Try to find a hallucination timer entity for this player
	if (patient.tfstate & #TFSTATE_HALLUCINATING)
	{
		te = find(world, classname, "timer");
		while (((te.owner != patient) || (te.think != HallucinationTimer)) && (te != world))
		{
			te = find(te, classname, "timer");
		}

		if (te != world)
		{
			patient.tfstate = patient.tfstate - (patient.tfstate & #TFSTATE_HALLUCINATING);
			SpawnBlood(org, 20);
			if (patient == doc)
				sprint(doc, #PRINT_HIGH, "The visions have stopped.\n");
			else
			{
				sprint(patient, #PRINT_HIGH, doc.netname, " heals you of your hallucinations\n");
				sprint(doc, #PRINT_HIGH, "You halt ", patient.netname, "'s hallucinations\n");
			}
			// Give the medic a frag for doing it, only if it was caused by an enemy
			if (!Teammate(doc, te))
			{
				doc.real_frags = doc.real_frags + 1;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					doc.frags = doc.real_frags;
			}

			dremove(te);
		}
		else
		{
			RPrint("Warning: Error in Hallucination Timer logic.\n");
		}
	}

	#ifndef OLD_FLASH
	if (patient.tfstate & #TFSTATE_PSIONIZED)
	{
		patient.tfstate = patient.tfstate - #TFSTATE_PSIONIZED;

		TeamFortress_SetSpeed(patient);

		te = find(world, netname, "psionictimer");
		while ((te.owner != patient || te.classname != "timer") && (te != world))
			te = find(te, netname, "psionictimer");

		if (te != world)
		{
			SpawnBlood(org, 20);
			
			if (doc == patient)
				sprint(doc, #PRINT_HIGH, "The psionic influence has stopped.\n");
			else
			{
				sprint(patient, #PRINT_HIGH, doc.netname, " restores your psionic problems!\n");
				sprint(doc, #PRINT_HIGH, "You restore ", patient.netname, "'s psionic normality\n");
			}

			// Give the medic a frag for doing it, only if it was caused by an enemy
			if (!Teammate(doc, te))
			{
				doc.real_frags = doc.real_frags + 1;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					doc.frags = doc.real_frags;
			}

			dremove(te);
		}
	}
	#endif // PSIONIC

	// remove tranquilisation from player
	// Try to find a tranquilisation timer entity for this player
	if (patient.tfstate & #TFSTATE_TRANQUILISED)
	{
		te = find(world, classname, "timer");
		while (((te.owner != patient) || (te.think != TranquiliserTimer)) && (te != world))
		{
			te = find(te, classname, "timer");
		}
		if (te != world)
		{
			patient.tfstate = patient.tfstate - (patient.tfstate & #TFSTATE_TRANQUILISED);
			TeamFortress_SetSpeed(patient);
			
			SpawnBlood(org, 20);
			if (doc == patient)
				sprint(doc, #PRINT_HIGH, "You feel more alert now.\n");
			else
			{
				sprint(patient, #PRINT_HIGH, doc.netname, " heals you of your tranquilisation!\n");
				sprint(doc, #PRINT_HIGH, "You heal ", patient.netname, "'s tranquilisation\n");
			}
			// Give the medic a frag for doing it, only if it was caused by an enemy
			if (!Teammate(doc, te))
			{
				doc.real_frags = doc.real_frags + 1;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					doc.frags = doc.real_frags;
			}

			dremove(te);
		}
		else
		{
			RPrint("Warning: Error in Tranquilisation Timer logic.\n");
		}
	}
	
	// check if the healed player is blinded
	/*if (patient.tfstate & TFSTATE_STASIS)
	{
		patient.tfstate = patient.tfstate - (patient.tfstate & TFSTATE_STASIS);
		TeamFortress_SetSpeed(patient);
		if (doc == patient)
			sprint(doc, #PRINT_HIGH, "You can move freely again!\n");
		else
		{
			sprint(patient, #PRINT_HIGH, doc.netname, " removes the effect of stasis on you!\n");
			sprint(doc, #PRINT_HIGH, "You halt the effects of stasis on ", patient.netname, "!\n");
		}
		patient.gravity = patient.stasisGravity;
		patient.effects = patient.effects - (patient.effects & #EF_BRIGHTFIELD);
		return 1;
	}*/

	// check if the healed player is infected
	if (patient.tfstate & #TFSTATE_INFECTED)
	{
		local float healam;
		local entity te;
		
		healam = rint(patient.health / 2);
		// remove the infection
		patient.tfstate = patient.tfstate - (patient.tfstate & #TFSTATE_INFECTED);
		
		te = find(world, netname, "biotimer");
		
		while (te != world)
		{
			if (te.classname == "timer")
				if (te.owner == patient)
					dremove(te);
			
			te = find(te, netname, "biotimer");
		}
		
		// some damage is caused (because of the use of leeches!)
		// remove half their remaining health
		deathmsg = #DMSG_MEDIKIT;
		TF_T_Damage(patient, doc, doc, healam, 0, #TF_TD_OTHER);

		SpawnBlood(org, 30);
		if (doc == patient)
			sprint(doc, #PRINT_HIGH, "Your sores disappear.\n");
		else
		{
			sprint(patient, #PRINT_HIGH, doc.netname, " cures your infection!\n");
			if (doc.classname == "player")
			{
				sprint(doc, #PRINT_HIGH, "You have healed ");
				sprint(doc, #PRINT_HIGH, patient.netname);
				sprint(doc, #PRINT_HIGH, " of the infection.\n");	

				teamprefixsprintbi(doc.team_no,doc,patient);
				teamsprintbi(doc,patient,doc.netname," cures ",patient.netname,"'s infection\n","","");

				// Give the medic a frag for doing it, only if it was caused by an enemy
				if (!Teammate2(doc,patient.infection_team_no))
				{
					doc.real_frags = doc.real_frags + 1;
					if (!(toggleflags & #TFLAG_TEAMFRAGS))
						doc.frags = doc.real_frags;
				}
			}
		}
	}

	// put out the fire if they are burning
	if (patient.numflames > 0)
	{
		sound(patient, #CHAN_WEAPON, "items/r_item1.wav", 1, #ATTN_NORM);
		patient.numflames = 0;
		
		if (doc == patient)
			sprint (doc, #PRINT_HIGH, "Your flames are extinguished!\n");
		else
		{
			sprint(patient, #PRINT_HIGH, doc.netname, " stops you burning!\n");
			if (doc.classname == "player")
			{		
				sprint(doc, #PRINT_MEDIUM, "You have put out ");
				sprint(doc, #PRINT_MEDIUM, patient.netname);
				sprint(doc, #PRINT_MEDIUM, "'s fire.\n");	
			}
		}
	}
};

