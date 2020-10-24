#pragma DONT_COMPILE_THIS_FILE

// This contains non-option defines that are needed in the options.qc file.

#define FALSE 0 
#define TRUE  1
#define OFF   0
#define ON    1

// Some of the toggleflags aren't used anymore, but the bits are still
// there to provide compatability with old maps
#define TFLAG_CLASS_PERSIST	1  		// Persistent Classes Bit
#define TFLAG_CHEATCHECK	2 		// Cheatchecking Bit
#define TFLAG_RESPAWNDELAY	4 		// RespawnDelay bit
//#define TFLAG_UN			8		// NOT USED ANYMORE
//#define TFLAG_UN2			16		// NOT USED ANYMORE
//#define TFLAG_UN3			32		// NOT USED ANYMORE
#define TFLAG_AUTOTEAM		64		// sets whether players are automatically placed in teams
#define TFLAG_TEAMFRAGS		128		// Individual Frags, or Frags = TeamScore
#define TFLAG_FIRSTENTRY	256		// Used to determine the first time toggleflags is set
									// In a map. Cannot be toggled by players.
#define TFLAG_SPYINVIS		512		// Spy invisible only
#define TFLAG_GRAPPLE		1024	// Grapple on/off
