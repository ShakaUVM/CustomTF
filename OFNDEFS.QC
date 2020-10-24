/*=======================================================//
// ofndefs.QC - CustomTF 3.2.OfN           - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN [cp]               //
=========================================================//
 Debug flags and other *IMPORTANT* settings and flags
 --------------------------------------------------------
 Special number chars reference:  (why here? dunno..)

 0123456789  --> Normally white
 °±²³´µ¶·¸¹  --> Normally red
   --> Normally gold
 ’“”•–—˜™š›  --> Normally gold (2nd variation)
  
 The actual color depends on the gfx.wad the client uses
 or the charset loaded into fuhquake.
=========================================================*/

// This file does not have any QuakeC, only preprocessor stuff, so..
#pragma DONT_COMPILE_THIS_FILE 

//================================================================================//
// MAIN BUILD CONFIGURATION  (un/comment any of the following lines to change it) //
//________________________________________________________________________________//

#define _RELEASE_BUILD_   // <-- ENABLE THIS FOR ANY BUILDS TO BE PLAYED!!
#define _FANCY_STUFF_     // <-- Turns on all fancy stuff, like cool gibs etc..

//================================================================================//

//==============================//
// Debug/Test flags & enablers  //
//==============================//

//------------------------------------------//
#ifndef _RELEASE_BUILD_                     //
//------------------------------------------//
//#define VERBOSE_GRUNTY
#define WARLOCK_TEST // free summon
//#define ARMY_TEST // only 5 seconds for tele the soldier
//#define CRUSADER_TEST
//#define ALIASES_TEST
//#define GRENADES_TEST // Infinite grenades
//#define HOLO_TEST //Sentries, monsters and teslas attack friendly holos?
//#define FIELD_TEST
//#define VOTING_TEST
//#define XMAS_TEST
//#define CRASH_TEST
//#define STORM_TEST // Enables special admin cmnd "thunder"

//#define TESTRANGE_EXTRA
//#define SNIPERSIGHT_SHOWPOS
//#define MINE_DEBUG // to debug guerilla

//#define MONSTERS_AURA 2 // for testing 1 = power 2 = resis 5 = Regen
//#define MONSTERS_STATE #TFSTATE_INFECTED

//#define GRUNTY_EXTRA_WEAPONS #WEAP_ROCKET_LAUNCHER | #WEAP_SUPER_SHOTGUN // 0

// Attack owner for testing purposes?
//#define MAD_GRUNTY
#define MAD_MONSTERS
//#define MAD_TESLA
//#define MAD_SENTRY

//------------------------------------------//
#endif // _RELEASE_BUILD_                   //
//------------------------------------------//

//===================================================//
// UNIMPLEMENTED STUFF DISABLERS                     //
//#define GREMLIN_NOTDONE // <-- Disables gremlin
//#define FISH_NOTDONE // <-- Disables piranha

//===================================================//
// Dispensable visual/sound/gameplay stuff enablers  //
//===================================================//

//------------------------------------------//
#ifdef _FANCY_STUFF_                        //
//------------------------------------------//
#define KICKABLE_HEADS           // <-- Allows heads to be kickable
#define GIBABLE_CORPSES          // <-- Makes corpses gibable
#define COOL_GIBS                // <-- Makes gibs pushable by explosions
#define COOL_GIBS_TRACE          // <-- Makes gibs pushable by trace attacks
#define COOL_METAL_GIBS          // <-- Enables the same for machine gibs
#define MENU_SOUNDS              // <-- Enables all menu sounds
#define SHAMBLER_SHOCK_SOUND     // <-- Electric sound for shambler lightning
#define EXTRA_DETPACK_EXPLOSIONS // <-- Makes extra explosions for detpacks
#define TEAMITEMS_COLOURED       // <-- Gives color to team-specific tf items
#define IDABLE_CORPSES           // <-- Allows corpses to be ID'ed
#define IDABLE_TFITEMS           // <-- Allows tf items to be ID'ed
#define IDABLE_RUNES             // <-- Allows runes to be ID'ed
//------------------------------------------//
#endif // _FANCY_STUFF_                     //
//------------------------------------------//

//==================================//
// Tweakable settings from here...  //
//==================================//

#define MOTD_REFRESHRATE        1

#define GRUNTY_HP             600 // initial HP for soldier
#define GRUNT_MAX_HP         1200 // OfN - Max health for the damn soldier, no 5000 hp grunts anymore! =)

/* moved to warlock.qc due to new hp system for monsters - Remains here as a reference to old values
#define SHAMBLER_MAX_HP          2600 // 2000 - 3000 - 2600
#define DEMON_MAX_HP             1800 // 1200 - 2000 - 1400
#define SCRAG_MAX_HP             1000 // 800
#define FISH_MAX_HP              1000 // was 850
#define GREMLIN_MAX_HP           2000*/

#define OTR_DMG_FACTOR        1.15 // Damage an otr bullet does respect a normal one
#define OTR_SHOTGUN_DMG_FACTOR 1.15 // Shotguns can do different amount with OTR
#define OTR_AMMO_COST         2 // Shells an OTR bullet takes when used

#define SCRAG_DMG              42 // damage the scrag does // was 29
#define WAYPOINT_LIFE         240 // 120 after this amount of seconds any unused waypoint will be removed
#define MAXAMMO_CELLS         300 //WK Was 275 // was 320 // Engineer max is set on defs.qc PC_ENGINNER_XX
#define SENTRY_UNLOCKTIME       2.5 // (must be greater than 1.1) time for the sentries to begin to rotate after they have no target (+/- 1 second)
#define HAX_UNSTABLEDIST      300 // distance at which enemy hacks take longer cause of "unstable connection"
#define WAYPOINT_AI_LIFE       10 // life for grunty ai created waypoints - last seen enemy mark
#define ATTN_MONSTERDIE         #ATTN_NONE // #ATTN_NORM
#define MINE_SCANRATE           0.1 //WK 5-15-08 0.2 WK 8/4/7 0.6 // mines look again for nearby enemy after this time - it was 1 which caused high ping players to not trigger mines sometimes walking around them fast
#define EXPBODY_DMG           160 // damage exp. body does /was 140

#define BERSERKER_HP_COST      33 //WK 8/4/7 40 // was 30 (i think 50 originally)

//----- Damage factor settings --------//
#define BERSERKER_DMGFACTOR        1.5 //WK 8/4/7 2.1 //2.4 //-was 2.65 was 2 then 2.2
#define CHAPLAN_DMGFACTOR          1.5 //WK 8/4/7 1.8 // Original was 1.5??
#define POWERAURA_DMGFACTOR        1.3 //WK 8/4/7 2

#define RESISAURA_DMGFACTOR        0.6
#define RESISRUNE_DMGFACTOR        0.5
#define CHAPLAN_DEFENSE_DMGFACTOR  0.66

#define MAX_OUT_DMGFACTOR          4 //WK 8/4/7 5
#define MIN_IN_DMGFACTOR           0.4 //WK 8/4/7 0.25
//-------------------------------------//

#define LASER_CANNON_DMG       36//26 // was 28

#define GRUNTY_SEEKTIME         8

#define BIO_GREN_RADIUS       200 // was 150

// Field generator
#define FIELDGEN_NUMCELLS    150 // Was 120

// Holograph 
#define HOLO_POWER_COST     10   //
#define HOLO_CYCLE_COST     0.2   //WK 2
#define HOLO_CYCLE_TIME     0.15 //WK 1.5

#define FLARE_DURATION      60   //

//#define TEAM_MINE_REPORTS

// field generator ranges
#define FIELDGEN_RANGE          285 // 275 - max distance between the two generators to work
#define FIELDGEN_HACKEDRANGE    475 // 450 - hacked generator distance
#define FIELDGEN_HACKEDRANGE2   600 // Range for both gens hacked

//#define FIELD_FORCEMODE    // coment to get rid of the mode switch of the force field
#define NO_FIELDGEN_INTERFERENCE

#define BUILD_DISPENSER_MAX_DETS         2

#define DISPENSER_MEDIKIT_MINIMUM        5 //15- Minimum medikit on dispenser to cure/heal player

#define TELEPORTER_TURRETIZE_CELLS_COST  80 // was 125

#define AURA_MONSTER_REGEN_FACTOR 2.5

// detpack fx
#ifdef EXTRA_DETPACK_EXPLOSIONS
    #define EXTRA_DETEXPLOSIONS       4 // 5 // was 6
#endif

#define DETPACK_EARTHQUAKE // <-- Shakes players near detpacks explosion

#ifdef DETPACK_EARTHQUAKE
    #define DETPACK_EARTHQUAKE_RANGE  1200
#endif

#define ADMIN_CMND_ALLOWED

#define CEASEFIRE_ALLOWS_TO_MOVE
#define CEASEFIRE_CPRINT_RATE   0.5

#define AIRFIST_DONT_PUSH_TEAMMATES
#define AIRFIST_DONT_HURT_TEAMMATES

#define AIRFIST_DMG_REDUCTION    0.7 // was 0.65
#define AIRFIST_RECOIL_REDUCTION 0.6
#define AIRFIST_PUSH_REDUCTION   0.5 // Only applies to players pushed

#define DONT_SET_AURA_TO_ENEMIES // unless they r spies, of course..
#define ALLOW_AURAS_ON_CRUSADERS

#define PUSHABLE_SCRAG // scrag pushable by the airfist?
#define PUSHABLE_ARMY
#define PUSHABLE_FIEND

#define HUNTED_YELLOWTEAM_FACTOR 0.5 // this multiplied to current red players is max for yellow team on huntedr
#define BORDER_FACTOR 0.5

#define SENTRY_ROCKETSND "weapons/spike2.wav"
//#define SENTRY_ROCKETSND "weapons/rocket1i.wav"

#define MAPCYCLE_SPEED 0.3 // Seconds, rate of map cycle advance (see client.qc)
#define CYCLE_TIMEOUT 1 // Amount of seconds to delay the check for error on map cycle (see client.qc)

#define GAS_GREN_CYCLES  9 // Original value = 3

#define MINHP_TOKILL_MONSTERS   300 // Minimum hp monsters/soldiers must have to be able to unsummon/detonate them
// Obsolete --> #define MAX_PLAYER_HP    150 // Maximum player hp allowed

// Gibs/Heads/Monster corpses duration settings (in seconds)
#define MIN_GIB_TIME    20
#define MAX_GIB_TIME    40
#define MIN_HEAD_TIME   30
#define MAX_HEAD_TIME   60
#define MIN_CORPSE_TIME 40 // Monster corpses only
#define MAX_CORPSE_TIME 80 // Monster corpses only

// Corpses damage tolerance (strength until they get gibbed)
#ifdef GIBABLE_CORPSES
#define CORPSE_HP_PLAYER   180//270//360//180
#define CORPSE_HP_SCRAG    140//210//280//140
#define CORPSE_HP_FISH     120//180//240//120
#define CORPSE_HP_DEMON    200//300//400//200
#define CORPSE_HP_GREMLIN  220//330//440//220
#define CORPSE_HP_SHAMBLER 340//510//680//340
#define CORPSE_HP_ARMY     #CORPSE_HP_PLAYER
#endif

#define MAX_CORPSE_BLOOD   15

// Kickable heads settings
#ifdef KICKABLE_HEADS
#define KICKHEAD_RATE           1
#define KICKHEAD_RATE_PERUSER   1.5
#define KICKHEAD_RATE_ALIVE     3
#endif

#define DEFAULT_BODYQUE_SIZE    10 // Maximum player corpses/heads present in que (original was 4)

//#define CUSTOM_PC_USES_ITEMS
//#define CUSTOM_PC_ITEMS_PLAYING

// Old stuff enablers (should be commented out normally)
//#define OLD_HP_SYSTEM
//#define OLD_FLASH // Warning: If this one is ever defined it should be in defs.qc or earlier, not here
//#define OLD_CONCS
//#define OLD_NAILGREN
//#define OLD_TEAM_ANNOUNCEMENTS
//#define OLD_SBARLOOK

#define AIRFIST_CELLS_COST    5

#define PSIONICS_TIME 4.5 // Seconds for the psionic gren effects to last
#define PSIONIC_MOVEFACTOR 0.5
#define PSIONIC_EXPLOSIONRANGE 250

#define SENTRIES_MINIMUMHP_TODETONATE_FACTOR 0.5

#define MINES_IGNORE_TEAMMATETOUCH
#define MINE_MIRV_NUM 6
#define MINE_NAPALM_BURNTIMES 12
#define MINE_PSIONICS_TIME 6.5

#define NAILGREN_DMG  12 //WK 6/1/7 reset to original value //20

#define HACKER_ATTEMPTRATE 1

#define SENTRY_SMOOTHROTATION
#define SENTRY_ROTATIONSTEPS  36
#define SENTRY_ROTATIONWIDTH  50

#define INTERMISSION_LENFORCED  10 // Minimum seconds an intermission will last, Original was 5

#define SPEEDAURA_FACTOR 1.3

// Rune settings
#define SPEEDRUNE_FACTOR 1.35
#define SPEEDRUNE_RELOADMULT 0.8

#define FINALIZED_RATE_TEAMFLASH 1
#define FINALIZED_DELAY_TOACTION 40

#define MIN_MINUTES_TOVOTEMAP 1 // Minimum minutes to allow a map change using voting

#define TFITEM_SAFEDROP_TIME 2 // seconds for tfitems to not be pickeable by same player after tossing them

// Items/players color glowing settings
#ifdef TEAMITEMS_COLOURED
#define TEAMITEMS_COLORGLOW   // If defined, tf items only able to be picked by blue or red teams (like flags), will glow accordingly (only if 2 teams)
#define TEAMITEMS_PLAYERCOLOR // If defined, players will glow with corresponding color if picked a team restricted tf item (like flags) (only if 2 teams)
#define TEAMITEMS_FORCEDGLOW  // If TEAMITEMS_COLORGLOW and this are defined, team restricted items will always glow when droped, even if the contrary was specified
#endif

//#define FIXES_FOR_FLOATINGBUILDS

#define SUICIDE_RESPAWN_DELAY 10 // If ppl complain, set it to 8 :P Original was 5

#define DEFAULT_CYCLEDIR cpcycle // Default was "qwmcycle"
#define UNABLE_TOVOTE_FORSAME_MAP

//#define XMAS_STUFF
//#define LIGHTNING_PUSHES

//__________________________________________________________//
//                                                          //
// Stuff from here are NOT settings and they are ESSENTIAL  //
//__________________________________________________________//

// String flags (used for fast find() searches)
#define STRFLAG_COOL               "cool"
#define STRFLAG_MONSTER            "XX"
#define STRFLAG_CORPSE             "corpse"
#define STRFLAG_STORM_TARGET       "strmtrgt"
#define STRFLAG_EARTHQUAKE_TARGET  "eqtarget"

//------------------------------------------------------------------//
// DEFINED FIELDS - Method to easily change them using preprocessor //
//------------------------------------------------------------------//

#define runes     runes_owned 
#define mapflags  has_holo

#define monster_type  increase_team3
#define monster_level increase_team4

#define sname1 t_s_h
#define sname2 t_s_m
#define sname3 t_s_c

#define stormflag       n_s_m
#define earthquakeflag  n_s_h
#define coolflag        message
#define monsterflag     message
#define corpseflag      message

#define corpse_HP      if_group_is_removed

#define disabledstuff1 display_item_status1
#define disabledstuff2 display_item_status2
#define disabledstuff3 display_item_status3
#define disabledstuff4 display_item_status4
#define disabledstuff5 restore_group_no
#define givenstuff1    if_goal_is_active
#define givenstuff2    if_goal_is_inactive
#define givenstuff3    if_goal_is_removed
#define givenstuff4    if_group_is_active
#define givenstuff5    if_group_is_inactive

#define cprint_fx endtime

//==========================================//
// Flag values and important type values    //
//==========================================//

// OfN - Possible map bit flags on world.#mapflags field
#define MAPFLAG_WATERVISED  1
#define MAPFLAG_SHOULDRAIN  2
#define MAPFLAG_SHOULDSNOW  4
#define MAPFLAG_FOG         8
#define MAPFLAG_STORM       16
#define MAPFLAG_EARTHQUAKE  32
#define MAPFLAG_DAYTIME     64
#define MAPFLAG_RUNES       128
#define MAPFLAG_NOCUSTOM    256
#define MAPFLAG_NOSTOCK     512
#define MAPFLAG_NOEXTRAS    1024
#define MAPFLAG_STOCKFREE   2048
#define MAPFLAG_OBSERVER    4096
#define MAPFLAG_NOTEAMSCORE 8192

// Client types - Mirror any changes with cpqwsv source code!!
#define CLTYPE_DEFAULT    1
#define CLTYPE_PROZACQW   2
#define CLTYPE_FUHQUAKE   3
#define CLTYPE_AMFQUAKE   4
#define CLTYPE_ZQUAKE     5
#define CLTYPE_QUAKEFORGE 6
#define CLTYPE_FTEQUAKE   7
#define CLTYPE_EZQUAKE    8

// Rune bit flags - DO NOT MODIFY
#define RUNE_TRIAD  1
#define RUNE_RESIS  2
#define RUNE_SPEED  4
#define RUNE_REGEN  8

// Aura types - DO NOT MODIFY
#define AURA_POWER	1
#define AURA_RESIS  2
#define AURA_HASTE	3
#define AURA_INVIS	4
#define AURA_REGEN  5
#define AURA_SPEED  6

// Gib Kilograms <-> gib models (they *MUST* be integer values)
#define GIB1_KGS 1 // this corresponds to the model: "progs/gib1.mdl" (the smallest one)
#define GIB2_KGS 3 // this corresponds to the model: "progs/gib2.mdl" (the biggest one)
#define GIB3_KGS 2 // this corresponds to the model: "progs/gib3.mdl" (the medium one)

// MegaTF mode flags
#define MEGATF_MAPENTS  1
#define MEGATF_STEPS    2
#define MEGATF_SIGHTS   4
//#define MEGATF_DROPS    8

// Server state flags
/*#define SVSTATE_RAIN     1
#define SVSTATE_SNOW     2
#define SVSTATE_FOG      4
#define SVSTATE_HASLIT   8
#define SVSTATE_HASHRT   16
#define SVSTATE_HASSKY   32
#define SVSTATE_TEAM1POP 64
#define SVSTATE_TEAM2POP 64
#define SVSTATE_TEAM3POP 64
#define SVSTATE_TEAM4POP 64
*/

//====================================//
// Composed definitions               //
//====================================//

#ifdef GIBABLE_CORPSES
    #define USE_CORPSE_CODE
#endif

#ifdef IDABLE_CORPSES
    #ifndef USE_CORPSE_CODE
        #define USE_CORPSE_CODE
    #endif
#endif
