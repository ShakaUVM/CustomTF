/*=======================================================//
// environ.QC - CustomTF 3.2.OfN		   - 05/8/2004 - //
// by Sergio FumaÒa Grunwaldt - OfteN [cp]				 //
=========================================================//
 World environment (special FX's & daylight/brightness) 
---------------------------------------------------------//
 Brightness/daylight fade in/out's and other environment
 stuff is handled here - CREDITS: Thanks Grievre!
 Aren't the storm and earthquake awesome?! =)
_________________________________________________________//

 *** WARNINGs about Storm and Earthquake use: ***

 I don't recommend using earthquake or storm on net 
 servers as they may cause lag/FPS drops, for LAN they are
 great, no problems.
 
 The drawback of the storm is that on some 
 computer/client combos FPS may get decreased by the
 continuous brightness changes. (observed on a P3+Voodoo5
 with gl-fuhquake as client mainly specially on big maps).
 With software clients and original ID opengl client
 there should be no problem, but experiment yourself.

 These warnings doesn't apply to DayTime "emulation", as
 its brightness changes are done at a maximum rate of
 1 per-second, and it wouldn't cause much trouble if any.

 But remember, do your own tests and see if people playing
 experience any lag/FPS drops, in some circumstances like
 a server with only a few players or every player with
 good computer and connection it would even not be
 noticed at all! Enjoy!

=========================================================*/

void() RemoveFadeTimer;
string(float brightness) ReturnBrightness;
void(float brightness) SetWorldBrightness;
entity(float brightness, float fadetime, float delaytime, float factor) FadeWorld;
void() EnvironmentPrecachees;
void(float oldstorm, float oldearthquake, float olddaytime, float oldrunes) UpdateEnvironment;
void() GetEnvironmentGlobals;
void() ApplyMapFlags;

void() InitDayTime;
void() InitStorm;
void() InitEarthquake;
void(float report) CleanUpDayTime;
void(float report) CleanUpStorm;
void(float report) CleanUpEarthquake;

void(float thundernum, float vol) ThunderSound;
void(entity tstorm, float thunderdelay) StormLightning;
float(entity tstorm) GetThunderDelay;
entity(entity tstorm) StormSelectMachine;
entity(entity tstorm) StormSelectPlayer;

// External
void(vector org, float damage) SpawnBlood;
float(entity tester) IsBuilding;
void() GetRunesGlobal;
void(float oldrunes) UpdateRuneStuff;

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

For world fade in/out entity:
-----------------------------

.has_tesla		- Desired final brightness
.has_sentry 	- Original brightness when fading started
.heat			- Frame counter
.has_sensor 	- Number of steps calculated for the fading
.has_teleporter - Determines special action on fading end: 0 = nothing, 1 = set special light on 2 = set it off 3 = adjust daylight var along with fade

For storm entity:
-----------------

.has_tesla	 - Distance from battlefield of the storm (it emulates a real thing!)
.has_sentry  - Number of lightning storm events running
.has_holo	 - Last thunder sound played (will not play again till another sound is played first)
.has_sensor  - 2nd last thunder sound played (50% chances will not play consecutively)

For storm event entity:
-----------------------

.heat			- Counter for lightning animation
.has_camera 	- If TRUE lightning flash is finished for this
.has_teleporter - This is set to TRUE if thunder sound is already played
.has_fieldgen	- Type of lightning thunder to perform (random)
.demon_one		- Points to our main storm entity
.penance_time	- Time at which this effect was started
.job_finished	- Delay that should occur between lightning and thunder sound

For earthquake entity:
----------------------

.has_holo	  - It's TRUE if an earthquake is currently happenning
.heat		  - Used as a counter for eathquakes
.penance_time - Indicates time at which current earthquake was started
.job_finished - Duration of the current earthquake

For daytime entity:
-------------------

.ltime		 - Time at which daytime started
.count		 - Total number of days that will occur
.heat		 - Size in time of a day
.has_tesla	 - Flag that indicates if we are towards midnight (-1) or noon (1)

================================================================================================*/

// Environment settings

// Brightness settings
#define ENVIRO_DARKNESS 		  5
#define ENVIRO_MIDBRIGHT		  8
#define ENVIRO_ENDBRIGHT		  6
#define ENVIRO_DEFAULT_DAYLIGHT  12

// Storm settings
#define STORM_MAXCONCURRENT 	   2 // Maximum possible concurrent lightning events
#define STORM_MAXVOL			   1
#define STORM_MINVOL			   0.75
#define STORM_THUNDERSOUND_CHANCEDOUBLE 0.5 // Chance of repeating 2nd last thunder sound
#define STORM_MAXFREQUENCY		   20
#define STORM_MINFREQUENCY		   5

#define STORM_THUNDER_MINDELAY	   0
#define STORM_THUNDER_MAXDELAY	   4

#define STORM_LIGHTNINGBRIGHT_MINIMUMFACTOR  0.5 // Factor for minimum lightning bright intensity

#define STORM_DIRECTHIT_DMG  800 // Damage a direct hit of lightning does

// Earthquake settings
#define EARTHQUAKE_MAXHAPPEN	  20
#define EARTHQUAKE_MINHAPPEN	  10
#define EARTHQUAKE_DURATIONMAX	  30
#define EARTHQUAKE_DURATIONMIN	  15
#define EARTHQUAKE_PUSHINTENSITY  120
#define EARTHQUAKE_MAXRATE		  0.2
#define EARTHQUAKE_MINRATE		  0.1

// Daytime settings 
#define ENVIRO_MIDNIGHTLIGHT_DEFAULT   5
#define ENVIRO_NOONLIGHT_DEFAULT	  19
#define DAYTIME_STEPDELAY_TOBPRINT	   4

//==================================================================================
// Called once-per-map on worldspawn to initialize all the environment stuff

void() InitEnvironment =
{
	// Precache the sounds
	EnvironmentPrecachees();
	
	current_brightness = -1; // To make sure its able to be updated by SetWorldBrightness, see below

	// First, apply flags set on the map for environment
	ApplyMapFlags();

	// Then get the global environment vars (infokeys) which may override map flags
	GetEnvironmentGlobals();
	
	// Set initial world brightness 
	if (no_bright)
		lightstyle(0,"m");
	else
		SetWorldBrightness(#ENVIRO_DARKNESS); //(dark because no clients yet)

	// Impide brightness to be altered as we start dark
	specialstate = #TRUE;
	
	// Initialize our environment sub-sections as needed
	UpdateEnvironment(0,0,0,0);
};

//=================================================================
// These return TRUE if server has the file for current map

float() validatelit =
{
	local string st;

	st = strcat("maps/",mapname);
	st = strcat(st,".lit");

	return validatefile(st);
};

float() validatesky =
{
	local string st;

	st = strcat("maps/",mapname);
	st = strcat(st,".sky");

	return validatefile(st);
};

float() validatehrt =
{
	local string st;

	st = strcat("maps/",mapname);
	st = strcat(st,".hrt");

	return validatefile(st);
};

//=======================================================================
// Gets and applies any environment flags that may be on the map

void() ApplyMapFlags =
{
	// Turn on watervis if this map is flagged as watervised and server has autoset_watervis set
	if (infokey(world,"autoset_watervis") == "1") // autoset_watervis is enabled?
	{
		if (world.#mapflags & #MAPFLAG_WATERVISED)
		{
			bprint(#PRINT_HIGH, "Map Infoç This map supports transparent liquids.\n");

			if (cvar("watervis")!= 1)
			{
				RPrint("Turning ON watervis... (map flagged as watervised)\n");
				//localcmd("watervis 1\n"); 
				cvar_set("watervis","1");
			}
		}
		else
		{
			if (cvar("watervis")!= 0)
			{
				RPrint("Turning OFF watervis... (map not flagged as watervised)\n");
				//localcmd("watervis 0\n");
				cvar_set("watervis","0");
			}
		}
	}

	// Inform clients about any existing special extra files for this map...
	dprint("Looking for any map extra files...\n");
	// Does the server have a coloured lighting file for this map?
	if (validatelit())
		bprint(#PRINT_HIGH,"Map Infoç Coloured lighting for this map is avaliable. Type ¢cmd special getlit¢ to download it.\n");
	// Does the server have a paked skybox file for this map?
	if (validatesky())
		bprint(#PRINT_HIGH,"Map Infoç Packed skybox for this map is avaliable. Type ¢cmd special getsky¢ to download it.\n");
	// Does the server have a hi-res textures file for this map? 
	if (validatehrt())
		bprint(#PRINT_HIGH,"Map Infoç Hi-Res texture file for this map is avaliable. Type ¢cmd special gethrt¢ to download it.\n");
	
	// Get standard environment flags "hard-coded" into the map file (worldspawn field)
	if (world.#mapflags & #MAPFLAG_STORM)
		storm = 1;
	if (world.#mapflags & #MAPFLAG_EARTHQUAKE)
		earthquake = 1;
	if (world.#mapflags & #MAPFLAG_DAYTIME)
		daytime = 10;
	if (world.#mapflags & #MAPFLAG_RUNES)
		runes = 1;

	// Disable custom/stock classes if needed
	if (world.#mapflags & #MAPFLAG_NOCUSTOM)
		custom_mode = 2;
	if (world.#mapflags & #MAPFLAG_NOSTOCK)
		stock_mode = 2;
	
	// Make sure 1 of them is enabled at least
	if (custom_mode == 2 && stock_mode == 2)
		custom_mode = 0;

	// Apply hard-coded custom money
	if (world.money != 0)
		custom_money = world.money;
	
	// Get the teammate's masks
	friends1_mask = stof(world.noise1);
	friends2_mask = stof(world.noise2);
	friends3_mask = stof(world.noise3);
	friends4_mask = stof(world.noise4);

	// Get disabled/free stuff masks, if map stuff not disabled
	if (infokey(world,"no_mapstuff") != "1")
	{
		disabledstuff1 = world.#disabledstuff1;
		disabledstuff2 = world.#disabledstuff2;
		disabledstuff3 = world.#disabledstuff3;
		disabledstuff4 = world.#disabledstuff4;
		disabledstuff5 = world.#disabledstuff5;

		givenstuff1 = world.#givenstuff1;
		givenstuff2 = world.#givenstuff2;
		givenstuff3 = world.#givenstuff3;
		givenstuff4 = world.#givenstuff4;
		givenstuff5 = world.#givenstuff5;
	}
};

//===================================================================
// Gets all the environment globals from the localinfo's

void() GetEnvironmentGlobals =
{
	local string st;

	// Get custom daylight setting, if any
	st = infokey(world,"daylight");

	if (st == "") // we should use a default then..
		daylight = #ENVIRO_DEFAULT_DAYLIGHT;
	else
	{
		daylight = stof(st); // we use the custom setting..

		if (daylight < 0 || daylight > 25) // but only if a valid value
			daylight = #ENVIRO_DEFAULT_DAYLIGHT;
	}
	
	// Get the storm setting, if any
	st = infokey(world,"storm");

	if (st != "") 
	{
		storm = stof(st); // we use the custom setting..

		if (storm < 0 || storm > 1) // but only if a valid value
			storm = 0;
	}

	// Get the earthquake setting, if any
	st = infokey(world,"earthquake");

	if (st != "")
	{
		earthquake = stof(st); // we use the custom setting..

		if (earthquake < 0 || earthquake > 1) // but only if a valid value
			earthquake = 0;
	}

	// Get the daytime setting, if any
	st = infokey(world,"daytime");

	if (st != "")
	{
		daytime = stof(st); // we use the custom setting..

		if (daytime < 0) // but only if a valid value
			daytime = 0;
		else if (daytime > 100)
			daytime = 100;
	}

	// Get custom noon/midnight brightness settings, if any
	st = infokey(world,"noon_light");

	if (st == "") // we should use a default then..
		noon_light = #ENVIRO_NOONLIGHT_DEFAULT;
	else
	{
		noon_light = stof(st); // we use the custom setting..

		if (noon_light < 0 || noon_light > 25) // but only if a valid value
			noon_light = #ENVIRO_NOONLIGHT_DEFAULT;
	}

	st = infokey(world,"midnight_light");

	if (st == "") // we should use a default then..
		midnight_light = #ENVIRO_MIDNIGHTLIGHT_DEFAULT;
	else
	{
		midnight_light = stof(st); // we use the custom setting..

		if (midnight_light < 0 || midnight_light > 25) // but only if a valid value
			midnight_light = #ENVIRO_MIDNIGHTLIGHT_DEFAULT;

		// If midnight < noonlight just make them the same
		if (midnight_light > noon_light)
			midnight_light = noon_light;
	}

	st = infokey(world,"no_bright");

	if (st == "") // we should use a default then..
		no_bright = #FALSE;
	else
	{
		if (st == "1")
			no_bright = #TRUE;
		else
			no_bright = #FALSE;
	}	 

	// Get runes global
	GetRunesGlobal();

	// Get the disabled/free stuff masks settings on server, if any
	st = infokey(world,"dstuff1");
	if (st != "") 
		disabledstuff1 = stof(st); 
	st = infokey(world,"dstuff2");
	if (st != "") 
		disabledstuff2 = stof(st);
	st = infokey(world,"dstuff3");
	if (st != "") 
		disabledstuff3 = stof(st);
	st = infokey(world,"dstuff4");
	if (st != "") 
		disabledstuff4 = stof(st);
	st = infokey(world,"dstuff5");
	if (st != "") 
		disabledstuff5 = stof(st);

	st = infokey(world,"gstuff1");
	if (st != "") 
		givenstuff1 = stof(st); 
	st = infokey(world,"gstuff2");
	if (st != "")
		givenstuff2 = stof(st);
	st = infokey(world,"gstuff3");
	if (st != "") 
		givenstuff3 = stof(st);
	st = infokey(world,"gstuff4");
	if (st != "") 
		givenstuff4 = stof(st);
	st = infokey(world,"gstuff5");
	if (st != "") 
		givenstuff5 = stof(st);
};

//===============================================================
// Sounds for the environment stuff

void() EnvironmentPrecachees =
{
	// Storm thunder sounds
	precache_sound("ambience/thunder1.wav");
	precache_sound("environ/thunder2.wav");
	precache_sound("environ/thunder3.wav");
	precache_sound("environ/thunder4.wav");
	precache_sound("environ/thundrk.wav");

	// Earthquake sounds
	precache_sound("environ/rumble.wav");
	precache_sound("environ/rumblend.wav");
};

//====================================================================================
// Called when environment needs an update (admins change enviro variables etc..)

void(float oldstorm, float oldearthquake, float olddaytime, float oldrunes) UpdateEnvironment =
{
	// Initialize needed environment stuff
	if (oldstorm == 0 && storm != 0)
		InitStorm();
	if (oldearthquake == 0 && earthquake != 0)
		InitEarthquake();
	if (olddaytime == 0 && daytime != 0)
		InitDayTime();
	
	// Shutdown environment stuff if needed
	if (oldstorm != 0 && storm == 0)
		CleanUpStorm(#TRUE);
	if (oldearthquake != 0 && earthquake == 0)
		CleanUpEarthquake(#TRUE);
	if (olddaytime != 0 && daytime == 0)
		CleanUpDayTime(#TRUE);

	// Handled on runes.qc
	UpdateRuneStuff(oldrunes);
};

//==============================================================
// Functions to trigger level fade in and out's

void(float delaytime, float fadetime, float factor) World_FadeIn =
{
	local entity fadetimer;

	specialstate = #TRUE;
	
	fadetimer = FadeWorld(daylight, fadetime, delaytime, factor);

	if (fadetimer)
		fadetimer.has_teleporter = 2;
	else
		specialstate = #FALSE;
};

void(float delaytime, float fadetime, float factor) World_FadeOut =
{
	specialstate = #TRUE;

	FadeWorld(#ENVIRO_DARKNESS, fadetime, delaytime, factor);	 
};

// Used when observers only in-game brightness and for ceasefire
void(float delaytime, float fadetime, float factor) World_FadeMid =
{
	specialstate = #TRUE;
	
	FadeWorld(#ENVIRO_MIDBRIGHT, fadetime, delaytime, factor);
};

// Fade used when intermission runs
void(float delaytime, float fadetime, float factor) World_FadeEnd =
{
	local entity fadetimer;

	fadetimer = FadeWorld(#ENVIRO_ENDBRIGHT, fadetime, delaytime, factor);

	if (fadetimer)
		fadetimer.has_teleporter = 3; // Adjust daylight along with fade out
};

//======================================================================================
// Returns the string to be used on a lightstyle call for the given bright intensity

string(float brightness) ReturnBrightness =
{
	brightness = rint(brightness);
	
	if (brightness > 25)
		return "z";

	if (brightness == 0)
		return "a";
	if (brightness == 1)
		return "b";
	if (brightness == 2)
		return "c";
	if (brightness == 3)
		return "d";
	if (brightness == 4)
		return "e";
	if (brightness == 5)
		return "f";
	if (brightness == 6)
		return "g";
	if (brightness == 7)
		return "h";
	if (brightness == 8)
		return "i";
	if (brightness == 9)
		return "j";
	if (brightness == 10)
		return "k";
	if (brightness == 11)
		return "l";
	if (brightness == 12)
		return "m";
	if (brightness == 13)
		return "n";
	if (brightness == 14)
		return "o";
	if (brightness == 15)
		return "p";
	if (brightness == 16)
		return "q";
	if (brightness == 17)
		return "r";
	if (brightness == 18)
		return "s";
	if (brightness == 19)
		return "t";
	if (brightness == 20)
		return "u";
	if (brightness == 21)
		return "v";
	if (brightness == 22)
		return "w";
	if (brightness == 23)
		return "x";
	if (brightness == 24)
		return "y";
	if (brightness == 25)
		return "z";    

	if (brightness < 0)
		return "a";
	
	return "m";
};

//==============================================================================================
// Global function to set overall brightness
// Must be called always, and not directly call lightstyle() ever!

void(float brightness) SetWorldBrightness =
{
	if (no_bright) return;
	
	local string st;
	
	brightness = rint(brightness);
	
	if (brightness == current_brightness) return;

	st = ReturnBrightness(brightness);

	lightstyle(0,st);

	current_brightness = brightness;
};

void() FadeWorld_think;

//========================================================================
// Fades the world brightness to the specified one

entity(float brightness, float fadetime, float delaytime, float factor) FadeWorld =
{
	if (factor == 0)
		factor = 1;

	local entity fadetimer;

	RemoveFadeTimer();

	if (current_brightness == brightness) return world;
	
	fadetimer = spawn();
	fadetimer.classname = "fade";
	fadetimer.think = FadeWorld_think;
	fadetimer.nextthink = time + delaytime;    
	fadetimer.heat = 0;    

	fadetimer.has_sentry = current_brightness;
	fadetimer.has_tesla = brightness;
	
	fadetimer.has_sensor = current_brightness - brightness; // steps

	if (fadetime == 0) // use default rate
		fadetimer.has_camera = fabs(fadetimer.has_sensor) * factor;
	else
		fadetimer.has_camera = fadetime * 10 * factor; // total steps

	fadetimer.has_teleporter = 0; // do nothing when fading ends, default

	return fadetimer;
};

void() FadeWorld_think =
{
	local float bright, current_fraction, current_step;
	
	current_fraction = self.heat / self.has_camera;
	current_step = current_fraction * self.has_sensor; 
	bright = self.has_sentry - current_step;
	
	SetWorldBrightness(bright);

	if (self.has_teleporter == 3)
		daylight = bright;

	self.heat = self.heat + 1;	  
	
	if (current_brightness == self.has_tesla)
	{
		if (self.has_teleporter == 1)
			specialstate = #TRUE;
		else if (self.has_teleporter == 2)
			specialstate = #FALSE;
	   
		dremove(self);
	}
	else
		self.nextthink = time + 0.1;
};

//=========================================================================
// removes current fade timer

void() RemoveFadeTimer =
{
	local entity te;

	te = find(world,classname,"fade");

	if (te) dremove(te);
};

//-------------------------//
// * Storm *			   //
// Thunders and lightning  //
//-------------------------//

void() Storm_think;

//========================================================================
// Initializes storm stuff and starts it

void() InitStorm =
{	 
	local entity tstorm;

	CleanUpStorm(#FALSE);

	if (!storm) return;

	// Create storm entity
	tstorm = spawn();
	tstorm.classname = "storm";
	tstorm.think = Storm_think;
	tstorm.nextthink = time + 1;

	// Set starting settings
	tstorm.has_holo = -1; // last thunder sound
	tstorm.has_sensor = -1; // 2nd last thunder sound
	tstorm.has_tesla = 1; // Storm always start far away

	bprint(#PRINT_HIGH,"Environmentç Lightning storm near the battlefield!\n");
};

//=======================================================
// Main think for storm entity

void() Storm_think =
{
	local float thunderdelay;

	if (self.has_sentry < #STORM_MAXCONCURRENT)
	{
		thunderdelay = GetThunderDelay(self);

		StormLightning(self, thunderdelay);
	}
	else
	{
		self.nextthink = time + 1 + random() * 2;
		return;
	}
	
	self.nextthink = time + #STORM_MINFREQUENCY + (#STORM_MAXFREQUENCY - #STORM_MINFREQUENCY) * (1- self.has_tesla) + random()*random()*10;
};

//===========================================================================
// Gets the delay for a thunder in the storm

float(entity tstorm) GetThunderDelay =
{
	return #STORM_THUNDER_MINDELAY + (#STORM_THUNDER_MAXDELAY - #STORM_THUNDER_MINDELAY) * (1- tstorm.has_tesla);
};

//====================================================================
// Cleans up everything related to the storm and ends it

void(float report) CleanUpStorm =
{
	local entity tstorm, te;
	
	// remove any storm events out there
	te = find(world, classname, "stormevent");

	while (te)
	{
		// remove this one..
		dremove(te);

		// ..and find the next one (if there is one)
		te = find(world, classname, "stormevent");
	}

	// find main storm entity..
	tstorm = find(world, classname, "storm");

	// ..and remove it
	if (tstorm) dremove(tstorm);

	// Reset world brighness to current daylight if needed after any storm lightning
	if (!ceasefire && !specialstate)
		SetWorldBrightness(daylight);

	if (report)
		bprint(#PRINT_HIGH,"Environmentç The lighning storm has gone far away.\n");
};

//==============================================================
// Select and play an appropiate thunder sound from the storm

void(entity tstorm) StormThunder =
{
	if (ceasefire)
		return;
	
	local float thundernum;
	local float th1, th2, th3, counter, done, hs_sensor;

	if (tstorm.has_holo == -1 && tstorm.has_sensor == -1)
	{
		thundernum = rint(random()*3);
	}
	else 
	{
		th1 = 40;
		th2 = 40;
		th3 = 40;

		if (random() < #STORM_THUNDERSOUND_CHANCEDOUBLE || tstorm.has_sensor < 0)
			hs_sensor = tstorm.has_sensor;
		else
			hs_sensor = 40;

		counter = 0;
		done = #FALSE;

		while (counter < 4 && done == #FALSE)
		{
			if (counter != tstorm.has_holo && counter != hs_sensor)
			{
				done = #TRUE;
				th1 = counter;
			}

			counter = counter + 1;
		}

		counter = 0;
		done = #FALSE;

		while (counter < 4 && done == #FALSE)
		{
			if (counter != tstorm.has_holo && counter != hs_sensor && counter != th1)
			{
				done = #TRUE;
				th2 = counter;
			}

			counter = counter + 1;
		}

		// third loop if we double use the 2nd last sound
		if (hs_sensor == 40)
		{
			counter = 0;
			done = #FALSE;

			while (counter < 4 && done == #FALSE)
			{
				if (counter != tstorm.has_holo && counter != hs_sensor && counter != th1 && counter != th2)
				{
					done = #TRUE;
					th3 = counter;
				}

				counter = counter + 1;
			}

			counter = rint(random()*2);

			if (counter == 0)
				thundernum = th1;
			else if (counter == 1)
				thundernum = th2;
			else if (counter == 2)
				thundernum = th3;
		}
		else
		{
			counter = rint(random());

			if (counter == 0)
				thundernum = th1;
			else if (counter == 1)
				thundernum = th2;			 
		}
	}
	
	// Get volume of thunder based on storm distance to battle field :)
	counter = #STORM_MINVOL + (#STORM_MAXVOL - #STORM_MINVOL) * tstorm.has_tesla;

	// Make thunder sound!
	ThunderSound(thundernum,counter);

	// Update last used thunder sounds
	tstorm.has_sensor = tstorm.has_holo;
	tstorm.has_holo = thundernum;
};

//===========================================================================================
// After lightning this is used by a storm event entity to play thunder and do clean up

void() Thunder_think =
{
	StormThunder(self.demon_one);

	if (self.has_teleporter || self.has_fieldgen != 6) // If not a double thing or 1 thunder of 2 already done..
	{
		self.demon_one.has_sentry = self.demon_one.has_sentry - 1;
		dremove(self);
	}
	else // this always get executed by a "double type" storm event
	{
		self.has_fieldgen = 1; // in next think, do the thing above
		self.nextthink = time + GetThunderDelay(self.demon_one);
	}
};

//=======================================================================
// Subroutine used for any lightning bright adjustments

void(float bright, entity stormevent) SetLightningBrightness =
{
	if (ceasefire)
		return;

	bright = bright - (bright*#STORM_LIGHTNINGBRIGHT_MINIMUMFACTOR)*(1-stormevent.demon_one.has_tesla);

	SetWorldBrightness(daylight + bright);
};

//========================================================================================
// Think for storm event entity, does lightning and passes to thunder_think when ended

void() StormEvent_think =
{	 
	if (self.has_camera)
	{
		SetLightningBrightness(0,self);

		if (self.has_teleporter && self.has_fieldgen != 6) // Sound thunder played? then just do cleanup
		{
			self.demon_one.has_sentry = self.demon_one.has_sentry - 1;
			dremove(self);
			return;
		}
		else // we must play the thunder still
		{			 
			self.think = Thunder_think;

			if (self.has_fieldgen == 6 && self.has_teleporter) // Double lightning/thunder event type
				self.nextthink = time + GetThunderDelay(self.demon_one);
			else
				self.nextthink = self.penance_time + self.job_finished;

			return;
		}
	}
	
	if (self.has_fieldgen == 0) // first type of lightning
	{
		if (self.heat == 0)
			SetLightningBrightness(15,self);
		else if (self.heat == 1)
			SetLightningBrightness(0,self);
		else if (self.heat == 2)
		{
			SetLightningBrightness(8,self);
			self.has_camera = #TRUE;
		}
	}

	else if (self.has_fieldgen == 1) // second type of lightning
	{
		if (self.heat == 0)
			SetLightningBrightness(15,self);
		else if (self.heat == 1)
			SetLightningBrightness(10,self);
		else if (self.heat == 2)
		{
			SetLightningBrightness(3,self);
			self.has_camera = #TRUE;
		}
	}	 

	else if (self.has_fieldgen == 2) // third type of lightning
	{
		if (self.heat == 0)
			SetLightningBrightness(8,self);
		else if (self.heat == 1)
		{
			SetLightningBrightness(15,self);
			self.has_camera = #TRUE;
		}
	}	 

	else if (self.has_fieldgen == 3) // 4th Only sound
	{
		self.has_camera = #TRUE;
		self.nextthink = time;
	}

	else if (self.has_fieldgen == 4) // 5th type of thunder
	{
		if (self.heat == 0)
			SetLightningBrightness(5,self);
		if (self.heat == 1)
		{
			SetLightningBrightness(4,self);
			self.has_camera = #TRUE;		
		}
	}

	else if (self.has_fieldgen == 5) // 6th Only lightning
	{
		if (self.heat == 0)
			SetLightningBrightness(3,self);
		else if (self.heat == 1)
		{
			SetLightningBrightness(0,self);
			self.demon_one.has_sentry = self.demon_one.has_sentry - 1;
			dremove(self);
			return;
		}
	}

	else if (self.has_fieldgen == 6) // 7th double lightning/thunder
	{
		if (self.heat == 0)
			SetLightningBrightness(10,self);
		else if (self.heat == 1)
			SetLightningBrightness(4,self);
		else if (self.heat == 2)
			SetLightningBrightness(0,self);
		else if (self.heat == 11)
			SetLightningBrightness(15,self);
		else if (self.heat == 12)
			SetLightningBrightness(8,self);
		else if (self.heat == 13)
		{
			SetLightningBrightness(12,self);
			self.has_camera = #TRUE;
		}		 
	}

	if (!self.has_teleporter)
	if (self.has_fieldgen != 5)
	if (time > self.penance_time + self.job_finished)
	{
		StormThunder(self.demon_one);
		self.has_teleporter = #TRUE; // Sound job done		  
	}

	self.heat = self.heat + 1;

	if (self.heat >= 40) // for safety, shouldnt happen
	{
		self.demon_one.has_sentry = self.demon_one.has_sentry - 1;
		dremove(self);
		return;
	}

	self.nextthink = time + 0.1;
};

//==============================================================
// Spawn storm lightning event, which will become a thunder also

void(entity tstorm, float thunderdelay) StormLightning =
{
	if (ceasefire)
		return;

	local entity sevent;

	// Increase our counter
	tstorm.has_sentry = tstorm.has_sentry + 1;

	// Create storm event
	sevent = spawn();
	sevent.classname = "stormevent";
	sevent.think = StormEvent_think;
	sevent.nextthink = time + 0.1;
	sevent.demon_one = tstorm;
	sevent.heat = 0;
	sevent.penance_time = time;
	sevent.job_finished = thunderdelay;

	sevent.has_camera = #FALSE;
	sevent.has_teleporter = #FALSE;

	sevent.has_fieldgen = rint(random()*6); // random type of event
};

//=========================================================
// Starts the specified thunder sound on all clients

void(float thundernum, float vol) ThunderSound =
{
	local string st, st2;
	local entity te;

	st = "playvol ";

	if (thundernum == 0)
		st = strcat(st,"ambience/thunder1.wav ");
	else if (thundernum == 1)
		st = strcat(st,"environ/thunder2.wav ");
	else if (thundernum == 2)
		st = strcat(st,"environ/thunder3.wav ");
	else if (thundernum == 3)
		st = strcat(st,"environ/thunder4.wav ");
	else if (thundernum == 4) // Special sound of killing lightning
		st = strcat(st,"environ/thundrk.wav ");
	else
	{
		RPrint("BUG: Wrong thunder number on ThunderSound()!\n");
		return;
	}

	st2 = ftos(vol);
	st = strcat(st,st2);
	st = strcat(st,"\n");
	
	// find clients and stuffcmd the playvol command
	te = find(world, classname, "player");

	while (te)
	{
		if (te.is_connected)
			stuffcmd(te,st);
		
		te = find(te, classname,"player");
	}

	// spectators too..
	te = find(world, classname, "spec");

	while (te)
	{
		if (te.is_connected)
			stuffcmd(te,st);
		
		te = find(te, classname,"spec");
	}
};

//=====================================================================
// Returns TRUE if the thing has sky above it

float(entity thing) IsKillableByStorm =
{
	if (!thing) return #FALSE;

	if (!IsBuilding(thing) && thing.classname != "player")
		return #FALSE;

	traceline(thing.origin,thing.origin + '0 0 4096',#TL_BSP_ONLY,thing);

	if (pointcontents(trace_endpos) == #CONTENT_SKY)
		return #TRUE;
  
	return #FALSE;
};

//=====================================================================
// Sets/Updates vulnerabilities on given machine 

void(entity thing) UpdateVulnerability =
{
	if (!thing) return;

	if (!IsBuilding(thing)) return;
	
	if (IsKillableByStorm(thing))
		thing.#stormflag = #STRFLAG_STORM_TARGET;
	else
		thing.#stormflag = "";

	thing.#earthquakeflag = #STRFLAG_EARTHQUAKE_TARGET;

	thing.is_connected = #TRUE;
};

//======================================================================
// Happening of a special storm event (aka killer lightning)

void() StormSpecial_think =
{	 
	if (self.heat == 0)
	{
		SetLightningBrightness(8,self);
	} 
	else if (self.heat == 1)
	{
		SetLightningBrightness(15,self);
	}
	else if (self.heat == 2)
	{
		SetLightningBrightness(12,self);
	}
	else if (self.heat == 3)
	{
		SetLightningBrightness(8,self);
	}
	else if (self.heat == 4)
	{
		SetLightningBrightness(4,self);
	}
	else if (self.heat == 5)
	{
		SetLightningBrightness(0,self);
		dremove(self);
		return;
	}

	if (self.heat >= 6)
	{
		SetLightningBrightness(0,self);
		dremove(self);
		return;
	}

	self.heat = self.heat + 1;
	self.nextthink = time + 0.1;
};

float(entity tstorm) StormSpecialEvent =
{
	if (ceasefire || intermission_running)
		return #FALSE;
	
	local entity thetarget;

	if (random() > 0.75) // sometimes players have priority over machines for getting crushed
	{
		thetarget = StormSelectPlayer(tstorm);

		if (!thetarget) 
			thetarget = StormSelectMachine(tstorm);
	}
	else // usual thing
	{
		thetarget = StormSelectMachine(tstorm);

		if (!thetarget) 
			thetarget = StormSelectPlayer(tstorm);
	}

	// if no target is avaliable just return with failure
	if (!thetarget)
		return #FALSE; 

	// Do the lightning ray effect
	traceline(thetarget.origin,thetarget.origin + '0 0 8192',#TL_BSP_ONLY,thetarget);
	
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_LIGHTNING3);
	WriteEntity (#MSG_BROADCAST, thetarget);
	WriteCoord (#MSG_BROADCAST, thetarget.origin_x);
	WriteCoord (#MSG_BROADCAST, thetarget.origin_y);
	WriteCoord (#MSG_BROADCAST, thetarget.origin_z);
	WriteCoord (#MSG_BROADCAST, trace_endpos_x);
	WriteCoord (#MSG_BROADCAST, trace_endpos_y);
	WriteCoord (#MSG_BROADCAST, trace_endpos_z);
	#ifdef QUAKE_WORLD
	multicast (thetarget.origin, #MULTICAST_PHS);
	#endif

	// Make our special louder thunder sound instantly..
	ThunderSound(4,1);
	
	// Electric sound
	sound (thetarget, #CHAN_WEAPON, "weapons/lhit.wav", 1, #ATTN_NORM);
	
	// Damage it
	deathmsg = #DMSG_STORM;
	TF_T_Damage(thetarget,thetarget,thetarget,#STORM_DIRECTHIT_DMG,0,#TF_TD_ELECTRICITY);

	// TODO: Blast lightning damage on nearby stuff

	// Create an entity to handle the lightning brightness changes
	thetarget = spawn();
	thetarget.classname = "stormevent";
	thetarget.think = StormSpecial_think;
	thetarget.nextthink = time + 0.1;
	thetarget.heat = 0;
	thetarget.demon_one = tstorm;
	// lit start of lightning effect:
	SetLightningBrightness(25,thetarget);

	// we did it, return success..
	return #TRUE;
};

//=====================================================================================
// The following functions select a machine/player as a special storm event target

entity(entity tstorm) StormSelectMachine =
{
	local entity te;
	local float done;

	done = #FALSE;

	// Find any machine flagged as storm target
	te = find(world,#stormflag,#STRFLAG_STORM_TARGET);

	while (done != #TRUE && te != world)
	{
		if (te.health > 0)
		if (IsBuilding(te))
		if (IsKillableByStorm(te))
		{
			done = #TRUE;
		}

		if (!done)
			te = find(te,#stormflag,#STRFLAG_STORM_TARGET);
	}

	if (te != world && done == #TRUE) // we have a machine to be crushed by the storm
		return te;
	else
		return world;
};

entity(entity tstorm) StormSelectPlayer =
{
	if (num_players < 1) return world;

	local entity te;
	local float done;
	local float counter, toskip;

	toskip = 0;

	// Find player able to be killed by the storm

	te = find(world,classname,"player");

	if (num_players > 1) // if more than 1 player, skip random number of players first..
	{		 
		toskip = floor(random()*num_players);
		counter = 0;

		while (counter < toskip)
		{
			counter = counter + 1;
			te = find(te,classname,"player");
		}
	}

	done = #FALSE;
	counter = 0;

	while (done != #TRUE && counter < (num_players+1))// && te != world)
	{
		if (te.is_connected)
		if (te.playerclass != #PC_UNDEFINED) // skip observers
		if (te.health > 0)
		if (IsKillableByStorm(te))
		{
			done = #TRUE;
		}

		if (!done)
		{
			counter = counter + 1;
			te = find(te,classname,"player");
		}
	}

	if (te != world && done == #TRUE) // we have a player to be crushed by the storm
		return te;
	else
		return world;
};


//---------------------------//
// * Earthquake *			 //
// Random trembling ground	 //
//---------------------------//

void() Earthquake_think;
float(entity eqent) GetNextEarthquakeTime;
void(entity eqent) EarthquakeStart;
void(entity eqent) EarthquakeEnd;
void() EarthquakeApply_think;

//========================================================================
// Initializes eathquake and starts earthquake stuff

void() InitEarthquake =
{
	local entity teq;

	CleanUpEarthquake(#FALSE);

	if (!earthquake) return;

	// Create earthquake entity
	teq = spawn();
	teq.classname = "eq";
	teq.think = Earthquake_think;
	teq.nextthink = time + GetNextEarthquakeTime(teq);
	teq.has_holo = #FALSE;

	bprint(#PRINT_HIGH,"Environmentç The sismology in this zone seems unstable!\n");
};

//===============================================
// Main think of earthquake entity

void() Earthquake_think =
{
	EarthquakeStart(self);
};

//=================================================================
// Starts the earthquake

void(entity eqent) EarthquakeStart =
{
	if (ceasefire || specialstate)
	{
		eqent.think = Earthquake_think;
		eqent.nextthink = time + GetNextEarthquakeTime(eqent);	  
	}
	
	local entity te;

	eqent.think = EarthquakeApply_think;
	eqent.nextthink = time + 0.1;
	eqent.has_holo = #TRUE;

	// Start earthquake sound on players
	te = find(world,classname,"player");

	while (te)
	{
		if (te.is_connected)
			clientsound(te,#CHAN_EARTHQUAKE,"environ/rumble.wav",0.75,#ATTN_STATIC);
		
		te = find(te,classname,"player");
	}

	// Start earthquake sound on spectators
	te = find(world,classname,"spec");

	while (te)
	{
		if (te.is_connected)
			clientsound(te,#CHAN_EARTHQUAKE,"environ/rumble.wav",0.75,#ATTN_STATIC);
		
		te = find(te,classname,"spec");
	}

	// Initialize counter and time flag
	eqent.heat = 0;
	eqent.penance_time = time;
	eqent.job_finished = #EARTHQUAKE_DURATIONMIN + (#EARTHQUAKE_DURATIONMAX - #EARTHQUAKE_DURATIONMIN) * random();
};

//================================================================
// Does the player movement stuff during an earthquake

void() EarthquakeApply_think =
{
	if (ceasefire || specialstate)
	{
		EarthquakeEnd(self);
		return;
	}
	
	local entity te;
	local vector movevec;

	// shake all players in same direction
	movevec_x = crandom()* #EARTHQUAKE_PUSHINTENSITY;
	movevec_y = crandom()* #EARTHQUAKE_PUSHINTENSITY;
	
	te = find(world,classname,"player");

	while (te)
	{
		if (te.is_connected)
		if (te.health > 0) // Skip heads and corpses (not respawned)?
		if (!(te.done_custom & #CUSTOM_BUILDING)) // skip ppl customizing
		if (te.playerclass != #PC_UNDEFINED) // skip observers
		{
			if (te.flags & #FL_ONGROUND) // player on ground, time for moving!
			{
				te.velocity_x = te.velocity_x + movevec_x;
				te.velocity_y = te.velocity_y + movevec_y;				  
			}
			else if (te.waterlevel > 1) // player on water, move but slightly less
			{
				te.velocity_x = te.velocity_x + movevec_x * 0.5;
				te.velocity_y = te.velocity_y + movevec_y * 0.5;				
			}
		}

		te = find(te,classname,"player");
	}

	// Damage susceptible machines accordingly
	local float damage;

	damage = rint(random()*10);

	if (damage > 5)
	{
		deathmsg = #DMSG_EARTHQUAKE;

		te = find(world,#earthquakeflag,#STRFLAG_EARTHQUAKE_TARGET);

		while (te)
		{
			if (te.health > 0)
			if (random()< 0.4)
			{
				//if (te.flags & #FL_ONGROUND) // machine on ground
					TF_T_Damage(te,te,te,damage,0,0);

				if (random()< 0.1)
					SpawnBlood(te.origin,20);
			}

			te = find(te,#earthquakeflag,#STRFLAG_EARTHQUAKE_TARGET);
		}
	}

	// Bprint warning message
	if (self.heat == 5)
		bprint(#PRINT_HIGH,"ú ‘ËÂ ÁÚÔıÓ‰ ÚıÌ‚ÏÂÛ° ≈·ÚÙËÒı·ÎÂ°° ú\n");

	// Increase counter
	self.heat = self.heat + 1;

	// Set nextthink time randomly or end earthquake if needed
	if (time > self.penance_time + self.job_finished)
		EarthquakeEnd(self);
	else	
		self.nextthink = time + #EARTHQUAKE_MINRATE + (#EARTHQUAKE_MAXRATE - #EARTHQUAKE_MINRATE)*random();
};

//=================================================================
// Ends current earthquake

void(entity eqent) EarthquakeEnd =
{
	local entity te;

	if (eqent.has_holo != #TRUE) return;

	eqent.think = Earthquake_think;
	eqent.nextthink = time + GetNextEarthquakeTime(eqent);	  

	// Shut down earthquake sound on players
	te = find(world,classname,"player");

	while (te)
	{
		if (te.is_connected)
			clientsound(te,#CHAN_EARTHQUAKE,"environ/rumblend.wav",0.75,#ATTN_STATIC);
		
		te = find(te,classname,"player");
	}	 

	// Shut down earthquake sound on spectators
	te = find(world,classname,"spec");

	while (te)
	{
		if (te.is_connected)
			clientsound(te,#CHAN_EARTHQUAKE,"environ/rumblend.wav",0.75,#ATTN_STATIC);
		
		te = find(te,classname,"spec");
	}	 

	eqent.has_holo = #FALSE;
};

//================================================================
// Returns next earthquake time

float(entity eqent) GetNextEarthquakeTime =
{
	return #EARTHQUAKE_MINHAPPEN + (#EARTHQUAKE_MAXHAPPEN - #EARTHQUAKE_MINHAPPEN) * random();
};

//====================================================================
// Cleans up everything related to the earthquakes and ends them

void(float report) CleanUpEarthquake =
{
	local entity teq;

	teq = find(world, classname, "eq");

	if (teq)
	{
		EarthquakeEnd(teq); // (checks if needed itself)
		dremove(teq);
	}

	if (report)
		bprint(#PRINT_HIGH,"Environmentç The earthquakes have ceased.\n");
};

//--------------------------------//
// * DayTime *					  //
// Emulates real dinamic daylight //
//--------------------------------//

void() DayTime_think;

//========================================================================
// Initializes daytime stuff and starts "real" day time emulation

void() InitDayTime =
{
	local entity daytimer;

	CleanUpDayTime(#FALSE);

	if (!daytime) return;

	// Create daytime entity
	daytimer = spawn();
	daytimer.classname = "daytimer";
	daytimer.think = DayTime_think;
	daytimer.nextthink = time + 1;
	daytimer.ltime = time; // Time at which days started
	daytimer.count = daytime; // Number of days
	daytimer.heat = timelimit / daytime; // single day size
	daytimer.has_tesla = 0; // first think will initialize this

	local string st;
	st = ftos(rint(daytime));

	bprint(#PRINT_HIGH,"Environmentç This battle will last for ",st," days...\n");
};

//===================================================================
// Main think for day time emulation entity

void() DayTime_think =
{
	local float currentpos;

	if (specialstate || ceasefire || intermission_running)
	{
		self.nextthink = time + 1;
		return;
	}

	currentpos = (time - self.ltime)/ self.heat;

	daylight = getwave(currentpos,#GWAVE_USEMINMAX|#GWAVE_USESHAPE,midnight_light,noon_light,0,0,0.6);

	daylight = rint(daylight);	  
	
	SetWorldBrightness(daylight);

	if (daylight == noon_light)
	{
		if (self.has_tesla == #DAYTIME_STEPDELAY_TOBPRINT)
			bprint(#PRINT_HIGH,"ã Noon ã 13∫00 ã\n");
		
		self.has_tesla = self.has_tesla + 1;
	}
	else if (daylight == midnight_light)
	{
		if (self.has_tesla == #DAYTIME_STEPDELAY_TOBPRINT)
			bprint(#PRINT_HIGH," ÕÈ‰ÓÈÁËÙ  24∫00 \n");
		
		self.has_tesla = self.has_tesla + 1;
	}
	else 
		self.has_tesla = 0;
	
	self.nextthink = time + 1;
};

//====================================================================
// Cleans up everything related to the daytime emulation

void(float report) CleanUpDayTime =
{
	local entity daytimer;

	daytimer = find(world, classname, "daytimer");

	if (daytimer) dremove(daytimer);

	if (report)
		bprint(#PRINT_HIGH,"Environmentç Day light is now static.\n");
};
