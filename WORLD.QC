//================================================================//
//- CustomTF Worldspawn and related stuff			   OfteN	  //
//- 30-01-2001----------------------------------------------------//
//-- OFTEN --//
void() Wiz_Precache;
void() Fish_Precache;
void() Gremlin_Precache;
void() Field_Precache;
void() MenuPrecache;
void (float startup) UpdateInfos;
void() ResetVoteEnt;
void() PrecacheRuneModels;
void() ReteamTimer;
//==============//

void() InitBodyQue;
entity() GetQueEntry;


void() main =
{
	dprint ("main function\n");
	
// these are just commands the the prog compiler to copy these files

	precache_file ("progs.dat");
	precache_file ("gfx.wad");
	precache_file ("quake.rc");
	precache_file ("default.cfg");

	precache_file ("end1.bin");
	precache_file2 ("end2.bin");

	precache_file ("demo1.dem");
	precache_file ("demo2.dem");
	precache_file ("demo3.dem");

//
// these are all of the lumps from the cached.ls files
//
	precache_file ("gfx/palette.lmp");
	precache_file ("gfx/colormap.lmp");

	precache_file2 ("gfx/pop.lmp");

	precache_file ("gfx/complete.lmp");
	precache_file ("gfx/inter.lmp");

	precache_file ("gfx/ranking.lmp");
	precache_file ("gfx/vidmodes.lmp");
	precache_file ("gfx/finale.lmp");
	precache_file ("gfx/conback.lmp");
	precache_file ("gfx/qplaque.lmp");

	precache_file ("gfx/menudot1.lmp");
	precache_file ("gfx/menudot2.lmp");
	precache_file ("gfx/menudot3.lmp");
	precache_file ("gfx/menudot4.lmp");
	precache_file ("gfx/menudot5.lmp");
	precache_file ("gfx/menudot6.lmp");

	precache_file ("gfx/menuplyr.lmp");
	precache_file ("gfx/bigbox.lmp");
	precache_file ("gfx/dim_modm.lmp");
	precache_file ("gfx/dim_drct.lmp");
	precache_file ("gfx/dim_ipx.lmp");
	precache_file ("gfx/dim_tcp.lmp");
	precache_file ("gfx/dim_mult.lmp");
	precache_file ("gfx/mainmenu.lmp");
	
	precache_file ("gfx/box_tl.lmp");
	precache_file ("gfx/box_tm.lmp");
	precache_file ("gfx/box_tr.lmp");
	
	precache_file ("gfx/box_ml.lmp");
	precache_file ("gfx/box_mm.lmp");
	precache_file ("gfx/box_mm2.lmp");
	precache_file ("gfx/box_mr.lmp");
	
	precache_file ("gfx/box_bl.lmp");
	precache_file ("gfx/box_bm.lmp");
	precache_file ("gfx/box_br.lmp");
	
	precache_file ("gfx/sp_menu.lmp");
	precache_file ("gfx/ttl_sgl.lmp");
	precache_file ("gfx/ttl_main.lmp");
	precache_file ("gfx/ttl_cstm.lmp");
	
	precache_file ("gfx/mp_menu.lmp");
	
	precache_file ("gfx/netmen1.lmp");
	precache_file ("gfx/netmen2.lmp");
	precache_file ("gfx/netmen3.lmp");
	precache_file ("gfx/netmen4.lmp");
	precache_file ("gfx/netmen5.lmp");
	
	precache_file ("gfx/sell.lmp");
	
	precache_file ("gfx/help0.lmp");
	precache_file ("gfx/help1.lmp");
	precache_file ("gfx/help2.lmp");
	precache_file ("gfx/help3.lmp");
	precache_file ("gfx/help4.lmp");
	precache_file ("gfx/help5.lmp");

	precache_file ("gfx/pause.lmp");
	precache_file ("gfx/loading.lmp");

	precache_file ("gfx/p_option.lmp");
	precache_file ("gfx/p_load.lmp");
	precache_file ("gfx/p_save.lmp");
	precache_file ("gfx/p_multi.lmp");

// sounds loaded by C code
	precache_sound ("misc/menu1.wav");
	precache_sound ("misc/menu2.wav");
	precache_sound ("misc/menu3.wav");

	precache_sound ("ambience/water1.wav");
	precache_sound ("ambience/wind2.wav");

// shareware
	precache_file ("maps/start.bsp");

	precache_file ("maps/e1m1.bsp");
	precache_file ("maps/e1m2.bsp");
	precache_file ("maps/e1m3.bsp");
	precache_file ("maps/e1m4.bsp");
	precache_file ("maps/e1m5.bsp");
	precache_file ("maps/e1m6.bsp");
	precache_file ("maps/e1m7.bsp");
	precache_file ("maps/e1m8.bsp");

// registered
	precache_file2 ("gfx/pop.lmp");

	precache_file2 ("maps/e2m1.bsp");
	precache_file2 ("maps/e2m2.bsp");
	precache_file2 ("maps/e2m3.bsp");
	precache_file2 ("maps/e2m4.bsp");
	precache_file2 ("maps/e2m5.bsp");
	precache_file2 ("maps/e2m6.bsp");
	precache_file2 ("maps/e2m7.bsp");

	precache_file2 ("maps/e3m1.bsp");
	precache_file2 ("maps/e3m2.bsp");
	precache_file2 ("maps/e3m3.bsp");
	precache_file2 ("maps/e3m4.bsp");
	precache_file2 ("maps/e3m5.bsp");
	precache_file2 ("maps/e3m6.bsp");
	precache_file2 ("maps/e3m7.bsp");

	precache_file2 ("maps/e4m1.bsp");
	precache_file2 ("maps/e4m2.bsp");
	precache_file2 ("maps/e4m3.bsp");
	precache_file2 ("maps/e4m4.bsp");
	precache_file2 ("maps/e4m5.bsp");
	precache_file2 ("maps/e4m6.bsp");
	precache_file2 ("maps/e4m7.bsp");
	precache_file2 ("maps/e4m8.bsp");

	precache_file2 ("maps/end.bsp");

	precache_file2 ("maps/dm1.bsp");
	precache_file2 ("maps/dm2.bsp");
	precache_file2 ("maps/dm3.bsp");
	precache_file2 ("maps/dm4.bsp");
	precache_file2 ("maps/dm5.bsp");
	precache_file2 ("maps/dm6.bsp");
};


entity	lastspawn;

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void() worldspawn =
{	
	lastspawn = world;
	
// custom map attributes
#ifndef QUAKE_WORLD
	if (self.model == "maps/e1m8.bsp")
		cvar_set ("sv_gravity", "100");
	else
		cvar_set ("sv_gravity", "800");
#endif

#ifdef QUAKE_WORLD
	if (infokey(world, "*gamedir") != "fortress")
		objerror("Custom Team Fortress must be run with a gamedir of \"fortress\".\n");
#endif
	
	//- OfteN globals -//
	// OfN - Init global vars
	num_players = 0;
	num_specs = 0;	

	temp_e = spawn(); //WK 12-4-08 Our universal temp entity 
	temp_e.classname = "temp_e";
	temp_e.team_no = 0;

	// Retrieve prozac main localinfos
	UpdateInfos(#TRUE);

	// Init the body queue for corpses and heads of players
	InitBodyQue ();

	//WK 5-15-08
	//Setting infokey "at" to "off" or "0" disables reteaming
	if (infokey(world, "at") != "off" && infokey(world, "at") != "0") {
		//Neo is set in UpdateInfos above
		if (!neo) { //WK 12-4-08 Doublchecked disable autoteam in Neo mode
			local entity newmis;
			newmis = spawn();
			newmis.classname = "timer";
			newmis.netname = "reteamtimer";
			newmis.owner = world;
			newmis.think = ReteamTimer;
			newmis.nextthink = time + 180; //Start reteaming at 3 minutes
			newmis.heat = 0;
		}
	}

	// Clear this local used for map cycle error reporting (see client.qc)
	localcmd("localinfo tmap \"\"\n");
	localcmd("localinfo specialmap \"\"\n");

	current_voteent = world;
	votesleeping = #FALSE;

	debug_target=world;
	already_chosen_map = #FALSE;
	triggered_cycle = #FALSE;

	ceasefire = #FALSE;
	////////////////////

	// We set up Chris' Teamplay Plus Mode here cos that's fun
	/*st = infokey(world, "chris");
	if (st == "on")
		chris = #TRUE;
	else
		chris = stof(st);
		
	st = infokey(world, "roundtime");
	roundtime = stof(st);
	if (!roundtime)
		roundtime = 300;
	
	roundstowin = 5;*/
	
	////////////////////////////////

	team_with_flag = 0; 	//KK initial global sets

	// PZ - I'll stick my global initializers here too, I guess
	playersOnTeam1 = 0; playersOnTeam2 = 0;
	playersOnTeam3 = 0; playersOnTeam4 = 0;
	agrTimerRunning = 0; agrTimeOfLastSound = 0;

	//friends1_mask = stof(infokey(world,"friends1_mask"));
	//friends2_mask = stof(infokey(world,"friends2_mask"));
	//friends3_mask = stof(infokey(world,"friends3_mask"));
	//friends4_mask = stof(infokey(world,"friends4_mask"));
	


// the area based ambient sounds MUST be the first precache_sounds

// player precaches 
	W_Precache ();			// get weapon precaches

// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

// setup precaches allways needed
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav"); 	// player jump
	precache_sound ("player/land.wav"); 		// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav"); 	// drowning death

	precache_sound ("misc/talk.wav");			// talk
	precache_sound ("player/teledth1.wav"); 	// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
	precache_sound ("items/damage3.wav");

	precache_sound ("misc/power.wav");			//lightning for boss

// player gib sounds
	precache_sound ("player/gib.wav");			// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav"); 	// gib sound

// player pain sounds

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");

// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

// ax sounds	
	precache_sound ("weapons/ax1.wav"); 		// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav"); 	// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav"); 		// swimming
	precache_sound ("misc/water2.wav"); 		// swimming

	precache_model ("progs/player.mdl");
	precache_model ("progs/eyes.mdl");
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_model ("progs/s_bubble.spr");	// drowning bubbles
	precache_model ("progs/s_explod.spr");	// sprite explosion
	precache_model ("progs/s_light.spr");

	precache_model ("progs/v_axe.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");
	//UNUSED_TEST precache_model ("progs/grenade.mdl");

	//precache_model ("progs/v_chain.mdl"); // OfN - Light assault

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl"); 	// for lightning gun
	precache_model ("progs/bolt3.mdl"); 	// for boss shock
	precache_model ("progs/lavaball.mdl");	// for testing
	
	precache_model ("progs/missile.mdl");
	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");

	precache_model ("progs/backpack.mdl");

	precache_model ("progs/zom_gib.mdl");
	precache_model ("progs/v_light.mdl");

	precache_model2 ("progs/laser.mdl");
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("hknight/attack1.wav");

	//- OfN - Flare exp sound
	precache_sound2 ("items/flare1.wav");

	// Team Fortress Weapon MDLs
	//precache_model2("progs/sight.spr"); // OfN Moved to megatf source
//	precache_model2("progs/cross1.mdl");
	precache_model2("progs/v_medi.mdl");
	//precache_model2("progs/v_bio.mdl");
	precache_model2("progs/hgren2.mdl");
	precache_model2("progs/biggren.mdl");

	//precache_model2("progs/lndmine.mdl"); 
	precache_model2("progs/flare.mdl");
	
	precache_model2("progs/v_srifle.mdl");
	precache_model2("progs/v_asscan.mdl");
	precache_model2("progs/detpack.mdl");
	precache_model2("progs/ammobox.mdl");
	precache_model2("progs/v_knife.mdl");	  // Spy's Knife
	precache_model2("progs/v_knife2.mdl");	  // Spy's Knife with Blood on it
	precache_model2("progs/v_span.mdl");	  // Engineer's Spanner
	precache_model2("progs/e_spike1.mdl");	  // Engineer's RailGun
	precache_model2("progs/e_spike2.mdl");	  // Engineer's RailGun
	precache_model2("progs/v_rail.mdl");	  // Engineer's RailGun
	
	//precache_model2("progs/turrgun.mdl");   // Sentry Gun
	
	//////////////////////////////////////////////////////
	precache_model2("progs/trrgn2.mdl");
	precache_sound2 ("weapons/sntr666.wav");
	precache_sound2 ("weapons/trr2lost.wav");

	//precache_model2("progs/turrbase.mdl");	  // Sentry Gun
	precache_model2("progs/trrbs2.mdl");	  // Sentry Gun

	//air-fist models and sounds--------//
	precache_model2("progs/v_airgun.mdl");
	precache_sound2("weapons/agfail.wav");
	precache_sound2("weapons/agwfail.wav");
	precache_sound2("weapons/agwater.wav");
	precache_sound2("weapons/agfire.wav");
	precache_model2("progs/s_ablast.spr");
	//----------------------------------//

	//laser cannon models and sounds---//
	precache_model2("progs/v_laserg.mdl");
	precache_model2("progs/lasrspik.mdl");	  
	precache_sound2("weapons/laserric.wav");
	precache_sound2("weapons/laserg.wav");
	//-----------------------------------//

	//field gen precaches-------------//
	Field_Precache();
	//---------------------------------//

	precache_sound("gibs/gibpick.wav");
	/*precache_sound("gibs/gibpick2.wav");
	precache_sound("gibs/gibpick3.wav");*/
	//precache_sound2("blob/hit1.wav"); // For psionic grens
	
	#ifdef KICKABLE_HEADS
	precache_sound("zombie/z_miss.wav");
	#endif

	MenuPrecache();

	PrecacheRuneModels();

	//- OfN -
	precache_model2("progs/flarefly.mdl");
	precache_model2("progs/tesgib4.mdl");
	precache_model ("progs/caltrop.mdl");		// A big, bad, caltrop

	precache_sound2("weapons/gren_emp.wav");	

	precache_model2("progs/t2gib1.mdl");		  // Sentry Gun Gib
	precache_model2("progs/t2gib2.mdl");		  // Sentry Gun Gib
	precache_model2("progs/t2gib3.mdl");		  // Sentry Gun Gib
	
	//- extra gib
	precache_model2("progs/t2gib4.mdl");		  // Sentry Gun Gib
///////////////////////////////////////

	precache_model2("progs/disp.mdl");		  // Tmp dispenser mdl
	precache_model2("progs/dgib1.mdl"); 	  // Dispenser Gib
	precache_model2("progs/dgib2.mdl"); 	  // Dispenser Gib
	precache_model2("progs/dgib3.mdl"); 	  // Dispenser Gib

	precache_model2("progs/grenade2.mdl");	  // New grenade
	precache_model2("progs/v_grap.mdl");	  // Grapple gun
	precache_model2("progs/hook.mdl");		  // Grapple hook
//#ifndef QUAKE_WORLD
	/*if (headless==1)
	   precache_model2("progs/headless.mdl");	  // Player with no head*/
//#endif hehe why??

	precache_model2("progs/sencer.mdl");

	precache_model2("progs/grunty.mdl");

	//- OfN
	Wiz_Precache();
	Fish_Precache();
	#ifndef GREMLIN_NOTDONE // PZ - let's not let these occupy resources if grem is disabled
		Gremlin_Precache();
	#endif

	precache_sound2("weapons/detpack.wav");

	precache_sound2("speech/saveme1.wav");	  // Saveme Sound
	precache_sound2("speech/saveme2.wav");	  // Saveme Sound

	//- OfN sounds for flares and holo
	//precache_sound2("effects/bodyhit1.wav");	  
	//precache_sound2("effects/bodyhit2.wav");
	
	//- OfN - Aura sounds
	precache_sound2("auras/aura1b.wav");
	precache_sound2("auras/aura2b.wav");
	precache_sound2("auras/aura3b.wav");
	precache_sound2("auras/aura4b.wav");
	
	//precache_sound2("weapons/pinpull.wav");
	//precache_sound2("weapons/throw.wav");

#ifdef SPEECH
	precache_sound2("speech/scout.wav");
	precache_sound2("speech/sniper.wav");
	precache_sound2("speech/soldier.wav");
	precache_sound2("speech/demoman.wav");
	precache_sound2("speech/medic.wav");
	precache_sound2("speech/hvyweap.wav");
	precache_sound2("speech/pyro.wav");
	precache_sound2("speech/spy.wav");
	precache_sound2("speech/engineer.wav");

	precache_sound2("speech/demo_dp.wav");
#endif

	// PZ - AGR sounds
	if (agr) AGR_precacheSounds();
	
//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	// 0 normal
	//lightstyle(0, "f"); // default starting settin was "m" (half bright)
	//SetWorldBrightness(#ENVIRO_DARKNESS); // Done on InitEnvironment()
	
	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	
	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");
	
	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");
	
	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");				   
	
	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");
	
	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	
	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");
	
	// Init environment stuff, in environ.qc
	InitEnvironment();
};

void(float tno, float scoretoadd) TeamFortress_TeamIncreaseScore;

void() StartFrame =
{
	teamplay = cvar("teamplay");
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	deathmatch = cvar("deathmatch");

	// Attackers Go Red mode -PZ
	if (agr) AGR_think();

	// Neo Mode
	if (neo) 
	{
		Neo_calcNeoFactors();
		Neo_errorCheck();
	}

	framecount = framecount + 1;
};

/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void() bodyque =
{	// just here so spawn functions don't complain after the world
	// creates bodyques
};

void() InitBodyQue =
{
	//local entity	e; UNUSED
	
/*	OfN - Original code
	bodyque_head = spawn();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;*/

	// OfN - Now the serious "pro" code :)
	local entity te;

	local float counter;
	counter = 1;

	te = spawn();
	te.ltime = 0;
	te.classname = "bodyque";
	te.modelindex = modelindex_null;
	bodyque_head = te;

	while (counter < bodyque_size) // i wouldnt recommend more than 16
	{
		te.owner = spawn();
		te.owner.ltime = 0;
		te.owner.classname = "bodyque";
		te.owner.modelindex = modelindex_null;
		
		te = te.owner;

		counter = counter + 1;
	}

	te.owner = bodyque_head;
};

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void(entity ent) CopyToBodyQue =
{
	local entity que_item;
	
	if (ent.modelindex == modelindex_null)
		return; // OfN Dont let invisible stuff on bodyque

	// Get an appropiate item on que
	que_item = GetQueEntry();

	que_item.angles = ent.angles;
	que_item.model = ent.model;
	que_item.skin = ent.skin;
	que_item.modelindex = ent.modelindex;
	que_item.frame = ent.frame;
	que_item.colormap = ent.colormap;
	que_item.movetype = ent.movetype;
	que_item.velocity = ent.velocity;
	
	// OfN
	que_item.takedamage = ent.takedamage;
	que_item.avelocity = ent.avelocity; 
	if (ent.modelindex == modelindex_player) // stop any spin movement if a corpse
		que_item.avelocity = '0 0 0';

	if (ent.flags & #FL_FINDABLE_NONSOLID)
		que_item.flags = #FL_FINDABLE_NONSOLID;
	else
		que_item.flags = 0; // <-- original was always this

	que_item.ltime = time;
	// OfN end

	setorigin (que_item, ent.origin);
	setsize (que_item, ent.mins, ent.maxs);
	
	// OfN
	que_item.touch = ent.touch;
	que_item.solid = ent.solid;
	que_item.team_no = ent.team_no;
	que_item.message = ent.message;

	#ifdef KICKABLE_HEADS
	que_item.t_length = ent.t_length;
	que_item.t_width = ent.t_width;
	que_item.oldenemy = ent.oldenemy;
	#endif

	que_item.#corpse_HP = ent.#corpse_HP;
	// OfN end

	// Cycle-advance que pointer if current was used
	/*if (que_item == bodyque_head)
		bodyque_head = bodyque_head.owner;*/
};

entity() GetQueEntry =
{
	local float counter;
	local entity te, oldest;
	counter = 0;
	te = oldest = bodyque_head;
	
	// Check all items in que
	while (counter < bodyque_size)
	{
		// Empty one?
		if (te.modelindex == modelindex_null)
			return te; // Ok, return it for use..
		
		// Check how old is this one
		if (te.ltime < oldest.ltime)
			oldest = te; // set it as the oldest found

		// Cycle-advance to continue checks
		te = te.owner;
		counter = counter + 1;
	}

	// No empty que items found, so return oldest one..
	return oldest;
};
