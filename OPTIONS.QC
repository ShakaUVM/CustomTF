/*======================================================
	OPTIONS.QC			TeamFortress v2.5	

	(c) TeamFortress Software Pty Ltd	29/2/97
========================================================
Defines for the compilable options within TF.
========================================================*/
#pragma DONT_COMPILE_THIS_FILE

//#define COOP_MODE
#define NET_SERVER
//#define BOTS			// doesn't do anything yet
#define STATUSBAR
#define QUAKE_WORLD

#ifdef QUAKE_WORLD
//	#pragma PROGS_DAT "../qwprogs.dat"

	#undef COOP_MODE
	#define NET_SERVER
#endif

#ifdef NET_SERVER
	#define SPY_INVIS_ONLY		 #OFF	// Spy becomes invisible instead of changing skin/color
	#define DEFAULT_AUTOZOOM	 #OFF
//	#define WEINER_SNIPER				// autoaiming for sniper rifle
	#define FLAME_MAXWORLDNUM	 20 	// maximum number of flames in the world. DO NOT PUT BELOW 20.
	#define MAX_WORLD_PIPEBOMBS  20 	// This is divided between teams - this is the most you should have on a net server
	#define MAX_WORLD_AMMOBOXES  6		// This is divided between teams - this is the most you should have on a net server
	#define GR_TYPE_MIRV_NO 	 4		// Number of Mirvs a Mirv Grenade breaks into
//	#define GR_TYPE_NAPALM_NO	 8		// Number of flames napalm grenade breaks into (unused if net server)
	#define MEDIKIT_IS_BIOWEAPON		// WK THIS MUST BE DEFINED OR SHIT BREAKS NOW
//	#define RESTORE_DEAD_SPEEDS 		// If defined, we restore the cl_speeds 
#else	
	// LAN options
	#define SPY_INVIS_ONLY		 #OFF	// Spy changes skin/color instead of becoming invisible
	#define DEFAULT_AUTOZOOM	 #OFF
	#define FLAME_MAXWORLDNUM	 60 	// maximum number of flames in the world. DO NOT PUT BELOW 20.	
	#define MAX_WORLD_PIPEBOMBS  30 	// This is divided between teams
	#define MAX_WORLD_AMMOBOXES  6	// This is divided between teams
	#define GR_TYPE_MIRV_NO 	 12 	// Number of Mirvs a Mirv Grenade breaks into
	#define GR_TYPE_NAPALM_NO	 12 	// Number of flames napalm grenade breaks into
#endif

// these defines are ignored if quakeworld is on
#define GRAPPLING_HOOK		// Allow players to use the Hook on any map

#define TEAM_HELP_RATE	 60 // used only if teamplay bit 64 (help team with lower score) is set.  
							// 60 is a mild setting, and won't make too much difference
							// increasing it _decreases_ the amount of help the losing team gets
							// Minimum setting is 1, which would really help the losing team

#define PLAYER_PUSHING		// You can push your team mates around!

#define DISPLAY_CLASS_HELP	#ON 	// Change this to #OFF if you don't want the class help to 
									// appear whenever a player connects
//WK Removed the below, as they should just be set by the server admin, not hardcoded
//#define NEVER_TEAMFRAGS		#ON 	// teamfrags options always off (i didn't realise people wouldn't like it)
//#define ALWAYS_TEAMFRAGS	#OFF	// teamfrags options always on 
//#define CHECK_SPEEDS		#ON 	// makes sure players aren't moving too fast
#define CHECK_SPEEDS		#OFF	// OfN Disabled due to buggy behaviour
#define SNIPER_RIFLE_RELOAD_TIME	1.5 // seconds
#define STOP_MOUSE_MOVEMENT #ON 	// stops players from moving forward/back with the mouse, and cheating with it.
#define RESPAWN_DELAY_TIME	5		// this is the respawn delay, if the RESPAWN_DELAY option is
									// turned on with temp1.  QuakeWorld servers can use
									// serverinfo respawn_delay to set their own time.
									// see qw.txt for more info.

//#define SPEECH					// Don't enable this, ever.
#define MEDIKIT_IS_BIOWEAPON		// WK THIS MUST BE DEFINED OR SHIT BREAKS NOW

#ifdef QUAKE_WORLD
	#undef COOP_MODE
//	#undef NET_SERVER
	#undef PLAYER_PUSHING

	#define NET_SERVER
#endif

// Message Options
//#define CHEAT_WARNINGS	// If defined, the server will be told when players 
							// were caught with different skins/colors.

// Debug Options
//#define MAP_DEBUG 		// Debug for Map code. I suggest running in a hi-res
							// mode and/or piping the output from the server to a file.
//#define VERBOSE			// Verbose Debugging on/off

//#define PRINT_DMG 	//CH prints out dmg from TF_T_Damage
