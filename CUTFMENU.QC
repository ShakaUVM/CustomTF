/*=======================================================//
// CuTFMenu.QC - CustomTF 3.2.OfN		  - 30/10/2004 - //
// by Sergio FumaÒa Grunwaldt - OfteN [cp]				 //
// Rewritten by Shaka[UVM] on 6/1/7
=========================================================//
 All the stuff related to the customizing menu is here
 Moved to its own file for organization purposes
 Here now single price definitions also.. finally! =)
=========================================================*/

string(float itemnum, string itemdesc,float cost,float field, float bit) ConstructMenuItemStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuTeslaStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuSentryStr;
string(float itemnum, string itemdesc,float jobid,float cost, float extra1cost, float extra2cost, string extra1st, string extra2st) ConstructMenuJobStr;
string(float itemnum, string itemdesc,float cost,float grentype) ConstructMenuGrenStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuSpeedStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuHPStr;
void (string help_str) HelpString;
float() SpentOnJob;
float() SpentOnGrens;
float() SpentOnLegs;
float() SpentOnHP;
void(entity player) UpdateArmorItem;
void(float cost, float type) BuyCuTF2;

//WK 6/1/7 Complete Revamp of this entire file
//Put costs with the menu strings, redid all the menus

// Menu Item Strings
// PAGE 1 - Sniper Weapon
#define STR_SNIPERRIFLE 	   "Sniper Rifle    "
#define STR_SHINIGAMI		   "Shinigami Rifle "
#define STR_OTR 			   "´OTR Bullets    "
#define STR_CRIPPLER		   "´Crippling Shots"
#define STR_OVERCHARGE		   "´Max Charge     "
#define STR_CHARGER 		   "´Charge Speed   "
#define STR_INITIALIZER 	   "´Initial Damage "

#define COST_SNIPERRIFLE	4500 //WK 1/7/7 Was 5000 // 4000
#define COST_SHINIGAMI		2250
#define COST_OTR			1850
#define COST_CRIPPLER		1550
#define COST_OVERCHARGE 	2400
#define COST_CHARGER		1700
#define COST_INITIALIZER	1100

// PAGE 2 - Rocket Weapons
#define STR_ROCKETLAUNCHER	   "Rocket Launcher "
#define STR_PYROTOYS		   "Pyro Toys       "
#define STR_DAEDALUS		   "Impulse Rifle   "
#define STR_RLASERGUIDED	   "´Laser Guided   "
#define STR_RLASERGUIDED2	   "´Improved Turns "
#define STR_CLUSTER 		   "´Cluster Shots  "
#define STR_FASTER_ROX		   "´Faster Rockets "
#define STR_HEAT_SEEKING	   "´Heat Seeking   "

#define COST_ROCKETLAUNCHER 		3000
#define COST_PYROTOYS			3000
#define COST_DAEDALUS			1500
#define COST_RLASERGUIDED		1000
#define COST_RLASERGUIDED2		1000
#define COST_CLUSTER			3275
#define COST_FASTER_ROX 		1650
#define COST_HEAT_SEEKING		4225

// PAGE 3 - Shotgun Weapons
#define STR_ASSAULTCANNON	   "Assault Cannon  "	
#define STR_LIGHTASSAULT	   "Light Assault   "
#define STR_SUPERSHOTGUN	   "Double Barrel   "
#define STR_SHOTGUN 		   "Single Barrel   "
#define STR_LONG_BARREL 	   "´Long Barrel    "
#define STR_EXPLOSIVE_SHOT	   "´Explosive Shots"

#define COST_ASSAULTCANNON		3000   
#define COST_LIGHTASSAULT		1800
#define COST_SUPERSHOTGUN		 575
#define COST_SHOTGUN			  50
#define COST_LONG_BARREL		 975
#define COST_EXPLOSIVE_SHOT 		1925

//Page 4 - Other Weapons
#define STR_GRENADELAUNCHER 	"Grenade Set     "
#define STR_LIGHTNING			"Thunderbolt     "
#define STR_LASERCANNON 		"Laser Cannon    "
#define STR_MAUSER			"Mauser          "
#define STR_SNG 				"Super Nailgun   "
#define STR_RAILGUN 			"Rail Gun        "
#define STR_NAILGUN 			"Nail Gun        "

#define COST_GRENADELAUNCHER		2200
#define COST_LIGHTNING			2200
#define COST_LASERCANNON		1100
#define COST_MAUSER 			2400
#define COST_SNG				 600
#define COST_RAILGUN			 500
#define COST_NAILGUN			 225

//Page 5 - Tools
#define STR_TRANQ			   "Tranquilizer    "
#define STR_MEDIKIT 		   "Medikit         "
#define STR_KNIFE			   "Knife           "
#define STR_SCUBA			   "Scuba Gear      "
#define STR_AIRF			   "Air-Fist        "
#define STR_AIRFISTUPGRADE	   "´Airfist Upgrade"
#define STR_HOOK			   "Grappling Hook  "

#define COST_TRANQ			 350
#define COST_MEDIKIT			1550
#define COST_KNIFE			 650
#define COST_SCUBA			1000
#define COST_AIRF				2500 //WK 2/26/7 Was 2000
#define COST_AIRFISTUPGRADE 		1250 //WK 8/4/7 Was 2500 //WK 2/26/7 Was 1850
#define COST_HOOK				3000

// PAGE 6 - Leg Enhancements
#define STR_SPEED1			   "Cheetah         "
#define STR_SPEED2			   "Cougar          "
#define STR_SPEED3			   "White Rhino     "
#define STR_SPEED4			   "Scrub Jay       "
#define STR_SPEED5			   "KGB Officer     "
#define STR_SPEED6			   "Black Mamba     "
#define STR_SPEED7			   "Imperial Penguin"

#define COST_SPEED1 			7200 //WK 6/1/7 9000
#define COST_SPEED2 			4900 //WK 6/1/7 6000
#define COST_SPEED3 			3250
#define COST_SPEED4 			2500
#define COST_SPEED5 			1250
#define COST_SPEED6 			 500

// PAGE 7 - Health/Armor
#define STR_HP1 			   "50Ø75 Green     "
#define STR_HP2 			   "50Ø90 Green     "
#define STR_HP3 			   "100Ø80 Yellow   "
#define STR_HP4 			   "120Ø90 Yellow   "
#define STR_HP5 			   "150Ø100 Yellow  "
#define STR_HP6 			   "200Ø100 Red     "
#define STR_HP7 			   "300Ø100 Red     "

#define COST_HP1				 125
#define COST_HP2				 325 
#define COST_HP3				 650
#define COST_HP4				1100
#define COST_HP5				1800
#define COST_HP6				3000
#define COST_HP7				4500

// PAGE 8 - Special Armors & Ammo
#define STR_CERAMIC 		   "Ceramic Armor   "
#define STR_GEL 			   "Impact Armor    "
#define STR_ASBESTOS		   "Asbestos Armor  "
#define STR_KEVLAR		   "Kevlar Armor    "
#define STR_BLAST			   "Blast Armor     "
#define STR_FULLARMOUR		   "Full Armour     "
#define STR_ARMOR_PIERCING	   "´Armor Piercing "

#define COST_CERAMIC			 975
#define COST_GEL			 625 //WK 4-8-7 It's "GEL", not GET. =)
#define COST_ASBESTOS			 750
#define COST_KEVLAR 			1200
#define COST_BLAST			1500
#define COST_FULLARMOUR 		 250
#define COST_ARMOR_PIERCING 		2000

// PAGE 9 - Special Items
#define STR_DETPACK 		   "Detpack         "
#define STR_TOSSABLEDET 	   "C4 Tossable Det "
#define STR_HOLO			"Holo Device     "
#define STR_CYBERAUG		   "CyberAug Unit   "
#define STR_SPYKIT		   "Spy Kit         "
#define STR_CLIPEXTEND		   "Clip Extender   "

#define COST_DETPACK			 800
#define COST_TOSSABLEDET		1200
#define COST_HOLO				500 //WK 6/1/7 1200
#define COST_CYBERAUG			 500
#define COST_SPYKIT 			2000
#define COST_CLIPEXTEND 		 600

// PAGE 10 - Engineering
#define STR_SPANNER 		   "Spanner         "
#define STR_SENTRYGUN		   "Sentry Gun      "
#define STR_SENTRYUPGRADE	   "´Sentry Upgrade "
#define STR_TESLACOIL		   "Tesla Coil      "
#define STR_TESLAUPGRADE	   "´Tesla Upgrade  "
#define STR_SENSOR		   "Motion Sensor   "
#define STR_TELEPORTER		   "Teleporter Pads "

#define COST_SPANNER			1200
#define COST_SENTRYGUN			1500
#define COST_SENTRYUPGRADE		 700
#define COST_TESLACOIL			1350
#define COST_TESLAUPGRADE		1650
#define COST_SENSOR 			 750
#define COST_TELEPORTER 		1100

// PAGE 11 - Engineering 2
#define STR_SCANNER 		   "Scanner         "
#define STR_AUTOSCANNER 	   "´Auto-Scanner   "
#define STR_JAMMER		   "Scanner Jammer  "
#define STR_DISPENSER		   "Dispenser       "
#define STR_SECURITYCAMERA	   "Security Camera "
#define STR_FIELDGEN		   "Field Generator "

#define COST_SCANNER			 650
#define COST_AUTOSCANNER		 250
#define COST_JAMMER 			1000
#define COST_DISPENSER			 600
#define COST_SECURITYCAMERA 		 350
#define COST_FIELDGEN			1400

// PAGE 12 - Combat Grenades
#define STR_GR_NORMAL		   "Normal          "
#define STR_GR_NAPALM		   "Napalm          "
#define STR_GR_GAS		   "Gas             "
#define STR_GR_EMP		   "EMP             "
#define STR_GR_FRAG 		   "Frag            "
#define STR_GR_NAIL 		   "Nail            "
#define STR_GR_MIRV 		   "MIRV            "

#define COST_GR_NORMAL			 750
#define COST_GR_NAPALM			1000
#define COST_GR_GAS 			1600
#define COST_GR_EMP 			1200
#define COST_GR_FRAG			1850
#define COST_GR_NAIL			1600
#define COST_GR_MIRV			1600

// PAGE 13 - Utility Grenades
#define STR_GR_FLARE		   "Flare           "
#define STR_GR_CALTROP		   "Caltrop         "
#define STR_GR_CONCUSSION	   "Concussion      "
#define STR_GR_PSIONIC		   "Psionic         "
#define STR_GR_ANTIGRAV 	   "AntiGrav        "
#define STR_GR_BIOLOGICAL	   "Biological      "
#define STR_GR_KRAC 		   "Krac            "

#define COST_GR_FLARE			 300
#define COST_GR_CALTROP 		 500
#define COST_GR_CONCUSSION		1000
#define COST_GR_PSIONIC 		1200
#define COST_GR_ANTIGRAV		700
#define COST_GR_BIOLOGICAL		1100
#define COST_GR_KRAC			1450

// PAGE 14 - Professions
#define STR_THIEF			   "Thief     ®Hide©"
  #define STR_THIEF_EXTRA1		 "´Shadowstep    "
  #define STR_THIEF_EXTRA2		 "´Shadowsprint  "
#define STR_RUNNER		   "Runner  ®Sprint©"
#define STR_WARLOCK 		   "Warlock ®Summon©"
  #define STR_WARLOCK_EXTRA1	 "2nd Extra Soul  "
  #define STR_WARLOCK_EXTRA2	 "3rd Extra Soul  "
#define STR_CHAPLAN 		   "Chaplan®Inspire©"
#define STR_BERSERKER		   "Berserker ®Fury©"
#define STR_GUERILLA		   "Guerilla ®Mines©"
  #define STR_GUERILLA_EXTRA1  "Mine Technician "
  #define STR_GUERILLA_EXTRA2  "Mine Specialist "
#define STR_JUDOKA		   "Judoka  ®Disarm©"

#define COST_THIEF			 800
  #define COST_THIEF_EXTRA1 		 700
  #define COST_THIEF_EXTRA2 	 500
#define COST_RUNNER 			 400
#define COST_WARLOCK			1150
  #define COST_WARLOCK_EXTRA1		 750
  #define COST_WARLOCK_EXTRA2		 650
#define COST_CHAPLAN			1200
#define COST_BERSERKER			1200
#define COST_GUERILLA			1500
  #define COST_GUERILLA_EXTRA1	 750
  #define COST_GUERILLA_EXTRA2	 750
#define COST_JUDOKA 			1250

// PAGE 15 - More Professions
#define STR_ARMY			   "Army  ®Soldiers©"
  #define STR_ARMY_EXTRA1	   "Extra Reserve 2 "
  #define STR_ARMY_EXTRA2	   "Extra Reserve 3 "
#define STR_HACKER		   "CyberNet  ®Hack©"
#define STR_MARTYR		   "Martyr ®Suicide©"
#define STR_CRUSADER		   "Crusader ®Auras©"
#define STR_TKD 			   "Taekwondo ®Kick©"
#define STR_PSION			   "Psion®Mindblast©"
  #define STR_PSION_EXTRA1	   "´Telekinesis  "
  #define STR_PSION_EXTRA2	   "´Telekinesis II"

#define COST_ARMY				1250
  #define COST_ARMY_EXTRA1		 700
  #define COST_ARMY_EXTRA2		 950
#define COST_HACKER 			1200
#define COST_MARTYR 			1100 
#define COST_CRUSADER			1600
#define COST_TKD				1250
#define COST_PSION		1050
  #define COST_PSION_EXTRA1 	 750
  #define COST_PSION_EXTRA2 	1500

// PAGE 16 - Proficiencies
#define STR_STEALTH 		   "Stealth         "
#define STR_HIGHJUMP		   "Highjump        "
#define STR_EXPBODY 		   "Exp. Body       "
#define STR_DEMONLORE		   "Demon Lore      "
#define STR_CLOSECOMBAT 	   "Close Combat    "
#define STR_CANNIBAL		   "Cannibal        "

#define COST_STEALTH			400
#define COST_HIGHJUMP			500 
#define COST_EXPBODY			1200
#define COST_DEMONLORE			300
#define COST_CLOSECOMBAT		650
#define COST_CANNIBAL			 500

// PAGE 17 - Optional Equipment
#define STR_AUTOID		   "Auto-ID         "
#define STR_RESPAWNGUARD	   "Respawn Guard   "
#define STR_HOVERBOOTS		   "Hover Boots     "
#define STR_BOOTUPGRADE 	   "´Boot Upgrade   "
#define STR_AMMOBACKPACK	   "Ammo Backpack   "
#define STR_AMMOBANDOLIER	   "Ammo Bandolier  "

#define COST_AUTOID 			  25
#define COST_RESPAWNGUARD		  25
#define COST_HOVERBOOTS 		 850
#define COST_BOOTUPGRADE		 350
#define COST_AMMOBACKPACK		 300
#define COST_AMMOBANDOLIER		 200

//PAGE 18 - Knocktation Menu
#define STR_HWGUY			"Aspect of HWGuy "
#define STR_GYMNAST 			"Gymnast         "
#define STR_VOID_BODY			"Void Body       "
#define STR_RECOILLESS		   	"Recoilless Shots"
#define STR_MASSIVE_ATTACK	 	"Massive Attacks "
#define STR_BLACK_HOLE_GUN	 	"Black Hole Guns "

#define COST_HWGUY			450
#define COST_GYMNAST			750
#define COST_VOID_BODY			500
#define COST_RECOILLESS 		650
#define COST_MASSIVE_ATTACK		750
#define COST_BLACK_HOLE_GUN		1750

#define STR_SELLEXTRAS		   "Sell stuff back "


// Leg settings (Speeds)
#define CUSTOM_SPEED1	430 //WK 6/1/7 410 // Cheetah (shaka original = 650)
#define CUSTOM_SPEED2	380 //WK 6/1/7 370 // Cougar (shaka original = 420)
#define CUSTOM_SPEED3	330 // White Rhino
#define CUSTOM_SPEED4	310 // Scrub Jay
#define CUSTOM_SPEED5	290 // KGB Officer
#define CUSTOM_SPEED6	270 // Black Mamba
#define CUSTOM_SPEED7	250 // Imperial Penguin

// Char used to visually indicate a purchased item (DO NOT USE QUOTES!)
#define CHAR_BOUGHT * // <-- Classic "*" char
//#define CHAR_BOUGHT 
// // <-- White Square on original and most charsets

//WK 6/1/7 New Help System
//If you don't like being spammed when you buy stuff, do a "setinfo h off"
//It puts a newline at the end of the string, so don't put it in the helpstring.
void (string help_str) HelpString =
{
	if (self.classname != "player") return;
	if (infokey(self,"h") == "off") return;
	if (infokey(self,"h") == "0") return;
	sprint(self,#PRINT_HIGH,help_str);
	sprint(self,#PRINT_HIGH,"\n");
};

//==============================================================================
// The following "ancient" functions have been there doing the work for years
// I feel sad removing them, so they r still here :P

//----------------------------------------------------------------------
// Rod May	kk@rod.net
// mstr and mstr2 and eqstr only exist to cut down on a crap load of code.
//
/*string(float v,float m1,float m2,string s1,string s2,string s3,string s4) mstr =
{
	// return string for matching masks (m1 and m2) on value v.
	// neither match: s1, first only: s2, second only: s3, both: s4

	if ((v & m1) && (v & m2)) return s4;
	if (v & m1) return s2;
	if (v & m2) return s3;
	return s1;
};
string(float v1,float v2,float m1,float m2,string s1,string s2,string s3,string s4) mstr2 =
{
	// same func as above but with a value for each mask.
	// return string for matching mask m1 on value v1, and m2 on v2.

	if ((v1 & m1) && (v2 & m2)) return s4;
	if (v1 & m1) return s2;
	if (v2 & m2) return s3;
	return s1;
};*/
/*string(float v,float v1,float v2,string s1,string s2,string s3) eqstr =
{
	// return string based on v equals values v1 OR v2
	// neither equal: s1, first only: s2, second only: s3

	if (v == v1) return s2;
	if (v == v2) return s3;
	return s1;
};*/
//----------------------------------------------------------------------
//----------------------------------------------------------------------

//WK =====================================================================
//	Prints Menu for all our Sniper Needs
//	 =====================================================================
void() Menu_SniperWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	MenuResetCount();
	
	local string msg_custom;
	local string l1,l2,l3,l4, str;

	l1 = ConstructMenuItemStr(1,#STR_SNIPERRIFLE,#COST_SNIPERRIFLE,self.weapons_carried,#WEAP_AUTO_RIFLE);
	str = ConstructMenuItemStr(2,#STR_SHINIGAMI,#COST_SHINIGAMI,self.cutf2_items,#CUTF2_SHINIGAMI);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_OTR,#COST_OTR,self.cutf_items,#CUTF_OTR);
	str = ConstructMenuItemStr(4,#STR_CRIPPLER,#COST_CRIPPLER,self.cutf2_items,#CUTF2_CRIPPLER);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_OVERCHARGE,#COST_OVERCHARGE,self.cutf2_items,#CUTF2_OVERCHARGE);
	str = ConstructMenuItemStr(6,#STR_CHARGER,#COST_CHARGER,self.cutf2_items,#CUTF2_CHARGER);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_INITIALIZER,#COST_INITIALIZER,self.cutf2_items,#CUTF2_INITIALIZER);
	l4 = strcat(l4,"..         \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	if (self.done_custom & #CUSTOM_SELLING)
		msg_custom	= " dollars left\n\n*CURRENTLY SELLING FRAGS*\nTyping √’”‘œÕ again will waste your cash\n";
	else
		msg_custom =  " dollars left\n\nUse the √’”‘œÕ command to start over\nUse the ’–«“¡ƒ≈ command to sell frags\n";

// WK 6/1/7 These say:
//		msg_custom = strcat(msg_custom,"Type 'setinfo h on' to re-enable help\n");
//		msg_custom = strcat(msg_custom,"Type 'setinfo h off' to disable help\n");

	if (infokey(self,"h") == "off" || infokey(self,"h") == "0")
		msg_custom = strcat(msg_custom,"Type '”ÂÙÈÓÊÔ Ë œÓ' to re-enable help\n");
	else
		msg_custom = strcat(msg_custom,"Type '”ÂÙÈÓÊÔ Ë œÊÊ' to disable help\n");

	centerprint(self,"úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Sniper Weapon Menu úã\n\n",l1,l2,l3,l4,temp,msg_custom);
};													   

void(float inp) Menu_SniperWeapon_Input =
{
	if (inp <= 10 && inp >= 1)
	{
		if (inp == 1) {
			if (self.cutf2_items & #CUTF2_SHINIGAMI) {
				sprint(self, #PRINT_HIGH, "Sorry, you cannot buy both sniper rifles.\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse=0;
				return;
			}

			if (self.weapons_carried & #WEAP_SNIPER_RIFLE) //Already have it
			{
				PrintRefund(#COST_SNIPERRIFLE);
				self.weapons_carried = self.weapons_carried - #WEAP_SNIPER_RIFLE;
				self.weapons_carried = self.weapons_carried - #WEAP_AUTO_RIFLE;
				self.maxammo_shells = self.maxammo_shells - 75;
				Menu_SniperWeapon();
			}
			else if (self.money >= #COST_SNIPERRIFLE) {
				self.money = self.money - #COST_SNIPERRIFLE;
				self.weapons_carried = self.weapons_carried | #WEAP_SNIPER_RIFLE | #WEAP_AUTO_RIFLE;
				self.maxammo_shells = self.maxammo_shells + 75;
				PrintMoney();
				HelpString("The standard Sniper Rifle. Starts at #WEAP_SNIPER_RIFLE_MIN_DAMG damage and charges up to #WEAP_SNIPER_RIFLE_MAX_DAMG damage over #WEAP_SNIPER_RIFLE_MAX_TIME seconds.");
				Menu_SniperWeapon();
			}
			else
				PrintNotEnoughMoney(#COST_SNIPERRIFLE);
		}
		if (inp == 2)
		{
			//We check AUTO_RIFLE to see if they bought the normal sniper rifle.
			if (self.weapons_carried & #WEAP_AUTO_RIFLE) {
				sprint(self, #PRINT_HIGH, "Sorry, you cannot buy both sniper rifles.\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse=0;
				return;
			}

			BuyCuTF2(#COST_SHINIGAMI,#CUTF2_SHINIGAMI);

			//The Shinigami is indicated by giving the Sniper Rifle, and setting the Shinigami flag in the cutf2_items field.
			//So we clean it up here.
			if (self.cutf2_items & #CUTF2_SHINIGAMI)
				self.weapons_carried = self.weapons_carried | #WEAP_SNIPER_RIFLE;
			else
				self.weapons_carried = self.weapons_carried - (self.weapons_carried & #WEAP_SNIPER_RIFLE);

			HelpString("The Shinigami functions like the normal sniper rifle, but fires a slower projectile. It cannot perform leg or head shots. It has no autorifle mode. You cannot be disarmed while wielding it.");
			Menu_SniperWeapon();
			UpdateWeaponItems();
		}
		if (inp == 3)
		{
			BuyCuTF(#COST_OTR,#CUTF_OTR);
			HelpString("OTR Bullets for shotguns and sniper rifles cost #OTR_AMMO_COST times the bullets in ammo, but inflict ´#OTR_DMG_FACTOR times normal damage and increase leg damage slowdown.");
			Menu_SniperWeapon();
		}
		if (inp == 4)
		{
			BuyCuTF2(#COST_CRIPPLER,#CUTF2_CRIPPLER);
			HelpString("Cripplers increase leg shot damage by ´10% and increase leg damage slowdown. Additionally, they drastically improve caltrop grenades.");
			Menu_SniperWeapon();
		}
		if (inp == 5)
		{
			BuyCuTF2(#COST_OVERCHARGE,#CUTF2_OVERCHARGE);
			HelpString("The Overcharge Augment allows you to charge a sniper rifle for ´#CUTF2_OVERCHARGE_FACTOR times longer, increasing your maximum damage by a proportional amount.");
			Menu_SniperWeapon();
		}
		if (inp == 6)
		{
			BuyCuTF2(#COST_CHARGER,#CUTF2_CHARGER);
			HelpString("The Charger Augment allows you to fully charge to max damage a sniper rifle in #CUTF2_CHARGER_FACTOR the normal time.");
			Menu_SniperWeapon();
		}
		if (inp == 7)
		{
			BuyCuTF2(#COST_INITIALIZER,#CUTF2_INITIALIZER);
			HelpString("The Initializer Augment increases initial sniper rifle damage by ´#CUTF2_INITIALIZER_FACTOR times, but doesn't change the fully charged damage at all.");
			Menu_SniperWeapon();
		}
		if (inp == 9)
		{
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_ROCKET_WEAPON;
			Menu_RocketWeapon();			
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}

		self.impulse = 0;
	}
	// Otherwise, the impulse is passed on
};

// ====================================================================
//	Prints Menu of Rocket Options Available
// ====================================================================
void() Menu_RocketWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
		
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_ROCKETLAUNCHER,#COST_ROCKETLAUNCHER,self.weapons_carried,#WEAP_ROCKET_LAUNCHER);
	str = ConstructMenuItemStr(2,#STR_PYROTOYS,#COST_PYROTOYS,self.weapons_carried,#WEAP_INCENDIARY);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_DAEDALUS,#COST_DAEDALUS,self.weapons_carried,#WEAP_DAEDALUS);
	str = ConstructMenuItemStr(4,#STR_RLASERGUIDED,#COST_RLASERGUIDED,self.tf_items,#NIT_RL_LASER_SIGHT);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_CLUSTER,#COST_CLUSTER,self.tf_items,#NIT_CLUSTER_ROCKETS);
	str = ConstructMenuItemStr(6,#STR_FASTER_ROX,#COST_FASTER_ROX,self.cutf2_items,#CUTF2_FASTER_ROX);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_HEAT_SEEKING,#COST_HEAT_SEEKING,self.cutf2_items,#CUTF2_HEAT_SEEKING);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê   Rocket Weapons   úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};

void(float inp) Menu_RocketWeapon_Input =
{ 
  if (inp <= 10 && inp >= 1)
  {
	if (inp == 1) {
		BuyWeapon(#COST_ROCKETLAUNCHER,#WEAP_ROCKET_LAUNCHER);
		HelpString("The standard Quake rocket launcher. Deals a small amount of impact damage and a large amount of radius blast damage.");
		Menu_RocketWeapon();
		UpdateWeaponItems();
	}

	if (inp == 2) {
			if (self.weapons_carried & #WEAP_INCENDIARY) //Already have it
			{
			//Clean up asbestos armor
			if (!(self.tf_items & #NIT_ASBESTOS))
				self.money = self.money - #COST_ASBESTOS; //Sync this with asbestos
			self.tf_items = self.tf_items - (self.tf_items & #NIT_ASBESTOS);

			PrintRefund(#COST_PYROTOYS);
			self.weapons_carried = self.weapons_carried - #WEAP_INCENDIARY;
			self.weapons_carried = self.weapons_carried - #WEAP_FLAMETHROWER;
			self.maxammo_cells = self.maxammo_cells - 200;
			self.maxammo_rockets = self.maxammo_rockets - 60;
			Menu_RocketWeapon();
			}
			else if (self.money >= #COST_PYROTOYS)
			{
			self.money = self.money - #COST_PYROTOYS;
			self.weapons_carried = self.weapons_carried | #WEAP_INCENDIARY | #WEAP_FLAMETHROWER;
			//Give em asbestos armor, and a refund if they have it
			if (self.tf_items & #NIT_ASBESTOS)
				self.money = self.money + #COST_ASBESTOS;
			self.tf_items = self.tf_items | #NIT_ASBESTOS;
				
			self.maxammo_cells = self.maxammo_cells + 200;
			self.maxammo_rockets = self.maxammo_rockets + 60;
			PrintMoney();
			HelpString("The Pyro Toys include the Incendiary Cannon rocket launcher, the Flamethrower, and Asbestos Armor.");
			Menu_RocketWeapon();
			}
			else
				PrintNotEnoughMoney(#COST_PYROTOYS);

			UpdateWeaponItems();
		Menu_RocketWeapon();
	}
	if (inp == 3) {
		BuyWeapon(#COST_DAEDALUS,#WEAP_DAEDALUS);
		HelpString("The Daedalus Impulse Rifle is a combination concussion grenade, krac grenade and rocket launcher. Its slow, fire-based projectiles deal high damage against armor and buildings.");
		Menu_RocketWeapon();
		UpdateWeaponItems();
	}
	if (inp == 4) {
		BuyItem(#COST_RLASERGUIDED, #NIT_RL_LASER_SIGHT);
		HelpString("The Laser Guided Sight for the rocket weapons allows you to guide a projectile onto its target by holding down the attack button after firing.");
		Menu_RocketWeapon();
		UpdateWeaponItems();
	}
	if (inp == 5) {
		BuyItem(#COST_CLUSTER, #NIT_CLUSTER_ROCKETS);
		HelpString("Cluster Rockets are a separate weapon mode for all rocket weapons. It fires a large cluster of shots all at once, which deals massive damage, but has a long reload time.");
		Menu_RocketWeapon();
		UpdateWeaponItems();
	}
	if (inp == 6) {
		BuyCuTF2(#COST_FASTER_ROX,#CUTF2_FASTER_ROX);
		HelpString("The Faster Rockets Augment increases your Rocket Launcher, Incendiary Cannon, Daedalus Impulse Rifle and Grenade Launcher projectile speed by ´20%.");
		Menu_RocketWeapon();
	}
	if (inp == 7) {
		BuyCuTF2(#COST_HEAT_SEEKING,#CUTF2_HEAT_SEEKING);
		HelpString("The Heat Seeking Augment allows your rocket weapon projectiles to automatically hunt down enemy targets (including hidden thieves) in a 45 degree cone ahead of it.");
		Menu_RocketWeapon();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SNIPER_WEAPON;
		Menu_SniperWeapon();
		
	}
	if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SHOTGUN_WEAPON;
		Menu_ShotgunWeapon();		 
	}
	if (inp == 10)
	{
		DropFromCustomClassGen();
	}

	 self.impulse = 0;
  }
};


// ====================================================================
//	Prints Menu of Shotgun Oriented Weapons Available
// ====================================================================
void() Menu_ShotgunWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_ASSAULTCANNON,#COST_ASSAULTCANNON,self.weapons_carried,#WEAP_ASSAULT_CANNON);
	str = ConstructMenuItemStr(2,#STR_LIGHTASSAULT,#COST_LIGHTASSAULT,self.weapons_carried,#WEAP_LIGHT_ASSAULT);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_SUPERSHOTGUN,#COST_SUPERSHOTGUN,self.weapons_carried,#WEAP_SUPER_SHOTGUN);
	str = ConstructMenuItemStr(4,#STR_SHOTGUN,#COST_SHOTGUN,self.weapons_carried,#WEAP_SHOTGUN);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_LONG_BARREL,#COST_LONG_BARREL,self.cutf2_items,#CUTF2_LONG_BARREL);
	str = ConstructMenuItemStr(6,#STR_EXPLOSIVE_SHOT,#COST_EXPLOSIVE_SHOT,self.cutf2_items,#CUTF2_EXPLOSIVE_SHOT);
	l3 = strcat(l3,str);

	l4 = "\n";
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê  Shotgun Weapons   úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};

void(float inp) Menu_ShotgunWeapon_Input =
{ 
	if (inp <= 10 && inp >= 1)
	{

		if (inp == 1) {
			BuyWeapon(#COST_ASSAULTCANNON,#WEAP_ASSAULT_CANNON);
			HelpString("The Assault Cannon delivers high damage at short to medium range. You can fire it while moving, slowly. You need to be on the ground, or other stable place, to fire it.");
			UpdateWeaponItems();
			Menu_ShotgunWeapon();
		}
		if (inp == 2) {
			BuyWeapon(#COST_LIGHTASSAULT,#WEAP_LIGHT_ASSAULT);
			HelpString("The Light Assault Cannon is a high speed automatic shotgun with moderate spread that is deadly at short range. It fires in clips of #RE_LIGHT_ASSAULT nails, or #RE_LIGHT_ASSAULT_EX with a clip extender.");
			UpdateWeaponItems();
			Menu_ShotgunWeapon();
		}
		if (inp == 3) {
			BuyWeapon(#COST_SUPERSHOTGUN,#WEAP_SUPER_SHOTGUN);
			UpdateWeaponItems();
			Menu_ShotgunWeapon();
		}
		if (inp == 4) {
			BuyWeapon(#COST_SHOTGUN,#WEAP_SHOTGUN);
			UpdateWeaponItems();
			Menu_ShotgunWeapon();
		}
		if (inp == 5) {
			BuyCuTF2(#COST_LONG_BARREL,#CUTF2_LONG_BARREL);
			HelpString("Long Barrels narrow the spread of all shotgun weapons by a factor of #CUTF2_LONG_BARREL_SPREAD_FACTOR, and increase the range of all shotgun weapons and sniper rifles by ´#CUTF2_LONG_BARREL_RANGE_FACTOR times.");
			Menu_ShotgunWeapon();
		}
		if (inp == 6) {
			BuyCuTF2(#COST_EXPLOSIVE_SHOT,#CUTF2_EXPLOSIVE_SHOT);
			HelpString("Once per 3 seconds, your shotgun will launch an explosive shell, which deals 30 fire damage in a radius on contact. All rocket upgrades apply to this shell.");
			Menu_ShotgunWeapon();
		}
		if (inp == 8) {
			CuTFMenuSound(#MENUSOUND_BROWSE);
				self.current_menu = #MENU_ROCKET_WEAPON;
				Menu_RocketWeapon();
		}
		if (inp == 9)
		{
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_OTHER_WEAPON;
			Menu_OtherWeapon(); 		
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}
		
	 self.impulse = 0;
  }
};

// ====================================================================
//	Prints Menu of Other Weapons (that don't fit into a category above)
// ====================================================================
void() Menu_OtherWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_GRENADELAUNCHER,#COST_GRENADELAUNCHER,self.weapons_carried,#WEAP_GRENADE_LAUNCHER);
	str = ConstructMenuItemStr(2,#STR_LIGHTNING,#COST_LIGHTNING,self.weapons_carried,#WEAP_LIGHTNING);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_LASERCANNON,#COST_LASERCANNON,self.weapons_carried,#WEAP_LASERCANNON);
	str = ConstructMenuItemStr(4,#STR_MAUSER,#COST_MAUSER,self.weapons_carried,#WEAP_MAUSER);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_SNG,#COST_SNG,self.weapons_carried,#WEAP_SNG);
	str = ConstructMenuItemStr(6,#STR_RAILGUN,#COST_RAILGUN,self.weapons_carried,#WEAP_RAILGUN);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_NAILGUN,#COST_NAILGUN,self.weapons_carried,#WEAP_NAILGUN);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê    More Weapons    úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};

void(float inp) Menu_OtherWeapon_Input =
{ 
	if (inp <= 10 && inp >= 1)
	{

		if (inp == 1) {
			BuyWeapon(#COST_GRENADELAUNCHER,#WEAP_GRENADE_LAUNCHER);
			UpdateWeaponItems();
			Menu_OtherWeapon();
		}
		if (inp == 2) {
			BuyWeapon(#COST_LIGHTNING,#WEAP_LIGHTNING);
			HelpString("The Thunderbolt Lightning Gun will discharge all cells above 100 into one mighty bolt, and then function normally between 100 and 0 cells.");
			UpdateWeaponItems();
			Menu_OtherWeapon();
		}
		if (inp == 3) {
			BuyWeapon(#COST_LASERCANNON,#WEAP_LASERCANNON);
			HelpString("The Laser Cannon shoots high speed projectiles that reflect off of walls and ceilings 50% of the time.");
			UpdateWeaponItems();
				Menu_OtherWeapon();
		}
		if (inp == 4) {
			BuyWeapon(#COST_MAUSER, #WEAP_MAUSER);
			HelpString("The WK-77 Mauser deals extreme nail damage at point blank range. It does not uncover you if you are a spy currently in disguise.");
			UpdateWeaponItems();
			Menu_OtherWeapon();
		}
		if (inp == 5) {
			BuyWeapon(#COST_SNG,#WEAP_SNG);
			HelpString("The standard Super Nailgun.");
			UpdateWeaponItems();
			Menu_OtherWeapon();
		}
		if (inp == 6) {
			BuyWeapon(#COST_RAILGUN,#WEAP_RAILGUN);
			HelpString("The Railgun fires a projectile that penetrates everything, even walls. Inflicts lightning damage, though it costs nail ammo.");
			UpdateWeaponItems();
			Menu_OtherWeapon();
		}
		if (inp == 7) {
			BuyWeapon(#COST_NAILGUN,#WEAP_NAILGUN);
			HelpString("The standard Nailgun. Honestly, there's no real reason to buy this.");
			UpdateWeaponItems();
			Menu_OtherWeapon();
		}
		if (inp == 8) {
			CuTFMenuSound(#MENUSOUND_BROWSE);
				self.current_menu = #MENU_SHOTGUN_WEAPON;
				Menu_ShotgunWeapon();
		}
		if (inp == 9)
		{
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_TOOLS;
			Menu_Tools();			
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}
		
	 self.impulse = 0;
  }
};

// ====================================================================
//	Prints Menu of Tools
// ====================================================================
void() Menu_Tools =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_TRANQ,#COST_TRANQ,self.weapons_carried,#WEAP_TRANQ);
	str = ConstructMenuItemStr(2,#STR_MEDIKIT,#COST_MEDIKIT,self.weapons_carried,#WEAP_MEDIKIT);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_KNIFE,#COST_KNIFE,self.cutf_items,#CUTF_KNIFE);
	str = ConstructMenuItemStr(4,#STR_SCUBA,#COST_SCUBA,self.tf_items,#NIT_SCUBA);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_AIRF,#COST_AIRF,self.weapons_carried,#WEAP_AIRF);
	str = ConstructMenuItemStr(6,#STR_AIRFISTUPGRADE,#COST_AIRFISTUPGRADE,self.cutf_items,#CUTF_AIRFISTUPGRADE);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_HOOK,#COST_HOOK,self.weapons_carried,#WEAP_HOOK);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê Tools and Mobility úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};

void(float inp) Menu_Tools_Input =
{ 
	if (inp <= 10 && inp >= 1)
	{

		if (inp == 1) {
			BuyWeapon(#COST_TRANQ,#WEAP_TRANQ);
			HelpString("The tranquilizer fires darts that are faster than in normal TF. They do a small amount of damage that ignore armor, cause the target to stop breathing, and slow the target.");
			UpdateWeaponItems();
			Menu_Tools();
		}
		if (inp == 2) {
			if (self.weapons_carried & #WEAP_MEDIKIT)
			{
				PrintRefund(#COST_MEDIKIT);
				self.weapons_carried = self.weapons_carried - #WEAP_MEDIKIT;
				self.maxammo_medikit = self.maxammo_medikit - 80;
			}
			else if (self.money >= #COST_MEDIKIT) {
				self.money = self.money - #COST_MEDIKIT;
				self.weapons_carried = self.weapons_carried | #WEAP_MEDIKIT;
				self.maxammo_medikit = self.maxammo_medikit + 80;
				UpdateWeaponItems();
				PrintMoney();
				HelpString("This weapon regenerates your health, and heals teammates and friendly summons. Cures most ailments, including disease, concussion, and being set on fire. Infects enemies with disease.");
			}
			else
				PrintNotEnoughMoney(#COST_MEDIKIT); 		 
			Menu_Tools();
		}
		if (inp == 3) {
			if (self.cutf_items & #CUTF_KNIFE) //Already have it
			{
				//Clean up knife-less warlocks (sync this with Custom.qc)
				if (self.job & #JOB_WARLOCK) { // OfN Fix getting extra money with demon lore
					sprint(self, #PRINT_HIGH, "You will need this knife being a warlock!\n");
					CuTFMenuSound(#MENUSOUND_WRONG);
					self.impulse=0;
					return;
				}
				PrintRefund(#COST_KNIFE);
				self.cutf_items = self.cutf_items - #CUTF_KNIFE;
			}
			else if (self.money >= #COST_KNIFE) {
				self.money = self.money - #COST_KNIFE;
				self.cutf_items = self.cutf_items | #CUTF_KNIFE;
				PrintMoney();
				HelpString("The knife upgrades your axe into a deadly melee weapon. While normal attacks with it do more damage, backstabs are incredibly deadly and bypass armor.");
			}
			else
				PrintNotEnoughMoney(#COST_KNIFE);
			Menu_Tools();
		}
		if (inp == 4) {
			BuyItem(#COST_SCUBA,#NIT_SCUBA);
			HelpString("This Self-Contained Underwater Breathing Apparatus allows you to breathe indefinitely under water, makes you immune to tranquilizer shots, slows down your land walking speed slightly, greatly improves your underwater speed, and lets you shoot the sniper rifle and assault cannon in water.");
			Menu_Tools();
		}
		if (inp == 5) {
			BuyWeapon(#COST_AIRF,#WEAP_AIRF);  
			HelpString("This allows you to push objects in the world, even enemy players. If you fire at the ground, you will fly high. No lie. You know this. If you move too fast with it, it will discharge.");
			UpdateWeaponItems();
			Menu_Tools();
		}
		if (inp == 6) {
			if (!(self.weapons_carried & #WEAP_AIRF) && !(self.cutf_items & #CUTF_AIRFISTUPGRADE))
			{
				sprint(self,#PRINT_HIGH,"You need to buy an airfist to use the upgrade!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
			}
			else
			{
				BuyCuTF(#COST_AIRFISTUPGRADE,#CUTF_AIRFISTUPGRADE);
				HelpString("The airfist upgrade removes the discharge malfunction, and increases the damage and push of the airfist.");
			}
			Menu_Tools();
		}
		if (inp == 7) {
			if (no_grapple == 1) //If admin disable it
			{
				sprint(self,#PRINT_HIGH,"The admin has disabled the grapple on this map.\n");
				self.impulse = 0;
				return;
			}
			else if (allow_hook) //If map allows it...
			{
				sprint(self,#PRINT_HIGH,"You can't sell your grapple on this map!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
			}
			else
			{
				BuyWeapon(#COST_HOOK,#WEAP_HOOK);
				HelpString("By holding down fire you can attach a hook to any solid surface and fly to that point. You can fire other weapons while grappling. Try holding down jump while flying.");
				UpdateWeaponItems();
			}
			Menu_Tools();
		}
		if (inp == 8) {
			CuTFMenuSound(#MENUSOUND_BROWSE);
				self.current_menu = #MENU_OTHER_WEAPON;
				Menu_OtherWeapon();
		}
		if (inp == 9)
		{
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_LEGS;
			Menu_Legs();			
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}
		self.impulse = 0;
	}
};

// =============================
//	Prints Menu of Legs for Sale
// =============================
void() Menu_Legs =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4,str;

	MenuResetCount();

/*
650  9000
420  6000
330  3250
310  2500
290  1250
270  500
250  0
*/

	l1 = ConstructMenuSpeedStr(1,#STR_SPEED1,#COST_SPEED1);
	str = ConstructMenuSpeedStr(2,#STR_SPEED2,#COST_SPEED2);
	l1 = strcat(l1,str);

	l2 = ConstructMenuSpeedStr(3,#STR_SPEED3,#COST_SPEED3);
	str = ConstructMenuSpeedStr(4,#STR_SPEED4,#COST_SPEED4);
	l2 = strcat(l2,str);

	l3 = ConstructMenuSpeedStr(5,#STR_SPEED5,#COST_SPEED5);
	str = ConstructMenuSpeedStr(6,#STR_SPEED6,#COST_SPEED6);
	l3 = strcat(l3,str);

	l4 = ConstructMenuSpeedStr(7,#STR_SPEED7,0);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê Leg Enhancements   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};							  

void(float inp) Menu_Legs_Input =
{

	//First, prevent them from getting high speed while upgraded
	if (inp < 3 && self.done_custom & #CUSTOM_SELLING)
	{
		sprint(self,#PRINT_HIGH,"The upgraded CustomTF soldier is a fighting machine. He doesn't have access to fast legs\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		self.impulse = 0;
		return;
	}

	//Second, sell off our current legs
	if (inp < 8) {
	if (self.custom_speed == #CUSTOM_SPEED1) { //400 Original 650
		PrintRefund(#COST_SPEED1);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 1) {self.impulse = 0; Menu_Legs(); return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED2) { //360 Original 420
		PrintRefund(#COST_SPEED2);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 2) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED3) { // Original 330
		PrintRefund(#COST_SPEED3);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 3) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED4) { // Original 310
		PrintRefund(#COST_SPEED4);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 4) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED5) {
		PrintRefund(#COST_SPEED5);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 5) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED6) {
		PrintRefund(#COST_SPEED6);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 6) {self.impulse = 0; Menu_Legs();	return;}
	}
	}
	
	if (inp == 1) {
		if (self.money >= #COST_SPEED1) {
			self.money = self.money - #COST_SPEED1;
			self.custom_speed = #CUSTOM_SPEED1; // Original 650
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED1);
	}
	if (inp == 2) {
		if (self.money >= #COST_SPEED2) {
			self.money = self.money - #COST_SPEED2;
			self.custom_speed = #CUSTOM_SPEED2; // Original 420
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED2);
	}
	if (inp == 3) {
		if (self.money >= #COST_SPEED3) {
			self.money = self.money - #COST_SPEED3;
			self.custom_speed = #CUSTOM_SPEED3;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED3);
	}
	if (inp == 4) {
		if (self.money >= #COST_SPEED4) {
			self.money = self.money - #COST_SPEED4;
			self.custom_speed = #CUSTOM_SPEED4;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED4);
	}
	if (inp == 5) {
		if (self.money >= #COST_SPEED5) {
			self.money = self.money - #COST_SPEED5;
			self.custom_speed = #CUSTOM_SPEED5;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED5);
	}
	if (inp == 6) {
		if (self.money >= #COST_SPEED6) {
			self.money = self.money - #COST_SPEED6;
			self.custom_speed = #CUSTOM_SPEED6;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED6);
	}	
	
	if (inp == 7) {
		/*if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;*/
			self.custom_speed = #CUSTOM_SPEED7;
			PrintMoney();
			Menu_Legs();
		/*}
		else
			PrintNotEnoughMoney(#PRICE);*/
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_TOOLS;
		Menu_Tools();		 
	}
	if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_HEALTH;
		Menu_Health();		  
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ==========================================
//	Prints Menu of Armor and Health Available
// ==========================================

#ifdef OLD_HP_SYSTEM
void() Menu_Health =
{
	local string temp;
	temp = ftos(self.money);
	#ifdef MONEY_RED_ONCUSTOMIZE
	temp = colstr(temp,#COLSTR_RED);
	#endif
	local string l1,l2,l3,l4;

	MenuResetCount();

l1 = eqstr(self.maxarmor, 75, 100,
	"  .. 75 Green armor  ≠  200\n  .. 100 Yellow      ≠  700\n",
	"* .. 75 Green armor  ≠  200\n  .. 100 Yellow      ≠  700\n",
	"  .. 75 Green armor  ≠  200\n* .. 100 Yellow      ≠  700\n");

l2 = eqstr(self.maxarmor, 150, 200,
	"  .. 150 Red         ≠ 1400\n  .. 200 Red         ≠ 2400\n", // original 2200
	"* .. 150 Red         ≠ 1400\n  .. 200 Red         ≠ 2400\n",
	"  .. 150 Red         ≠ 1400\n* .. 200 Red         ≠ 2400\n");

l3 =	"  .. 300 Red         ≠ 4600\n"; // 4200 Original 3600

if (self.maxarmor == 300 )
l3 =	"* .. 300 Red         ≠ 4600\n";

l4 =	"  .. +50 Health      ≠ 1000\n  .. +5 Health       ≠  100\n.. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Armor and Health   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Health_Input =
{
	//Fix multiple armor buy bug
	//WW: Modded to allow to sell armor back
	if (inp >= 1 && inp <= 5 && self.maxarmor > 0) {
		if (self.maxarmor == 75)
		{
			if (inp == 1) {
				inp = 0;
				PrintRefund(200);
				Menu_Health();
			}
			else
				self.money = self.money + 200;
		}
		else if (self.maxarmor == 100)
		{
			if (inp == 2) {
				inp = 0;
				PrintRefund(700);
				Menu_Health();
			}
			else
				self.money = self.money + 700;
		}
		else if (self.maxarmor == 150)
		{
			if (inp == 3) {
				inp = 0;
				PrintRefund(1400);
				Menu_Health();
			}
			else
				self.money = self.money + 1400;
		}
		else if (self.maxarmor == 200)
		{
			if (inp == 4) {
				inp = 0;
				PrintRefund(2400); // Original 2200
				Menu_Health();
			}
			else
				self.money = self.money + 2400;
		}
		else if (self.maxarmor == 300)
		{
			if (inp == 5) {
				inp = 0;
				PrintRefund(4600); //4200 Original 3600
				Menu_Health();
			}
			else
				self.money = self.money + 4600;
			 
		}
		self.armor_allowed = self.armorvalue = self.maxarmor = 0;
		Menu_Health(); // FIXME: optimize (its actually sent twice)
	}
#define PRICE 200	
	if (inp == 1) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 75;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.3;	// Green
			self.armor_allowed = 0.3; //Green max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 700
	if (inp == 2) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 100;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.6;	// Yellow
			self.armor_allowed = 0.6; //Yellow max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 1400
	if (inp == 3) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 150;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.8; //Red armor
			self.armor_allowed = 0.8; //Max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 2400 // Original 2200
	if (inp == 4) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 200;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.8; //Red armor
			self.armor_allowed = 0.8; //Red max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 4600 //4200 Original 3600
	if (inp == 5) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 300;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.8; //Red armor (used to be 0.9)
			self.armor_allowed = 0.8; //Red max
			PrintMoney();
			W_SetCurrentAmmo ();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 1000
	if (inp == 6) {
		if (self.money >= #PRICE) {
			if (self.max_health + 50 > #MAX_PLAYER_HP)
			{
				sprint(self,#PRINT_HIGH,"You reached maximum health allowed!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);

				self.money = self.money + ((self.max_health - 50) / 5) * 100;
				self.max_health = 50;
				self.health = self.max_health;

				self.impulse = 0;
				return;
			}

			self.money = self.money - #PRICE;
			self.max_health = self.max_health + 50;
			self.health = self.max_health;
			PrintMoney();
			//Menu_Health();
		}
		else
		{
			// WW: Modded to allow to sell health back
			//	   Buying #6 with <#7 money resets hp
			if (self.money < 100)
			{
				self.money = self.money + ((self.max_health - 50) / 5) * 100;
				self.max_health = 50;
				self.health = self.max_health;
				PrintMoney();
				//Menu_Health();
			}
			else
				PrintNotEnoughMoney(#PRICE);
		}
	}
#define PRICE 100
	if (inp == 7) {
		if (self.money >= #PRICE) {
			
			if (self.max_health + 5 > #MAX_PLAYER_HP)
			{
				sprint(self,#PRINT_HIGH,"You reached maximum health allowed!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse = 0;
				return;
			}
			
			self.money = self.money - #PRICE;
			self.max_health = self.max_health + 5;
			self.health = self.max_health;
			PrintMoney();
			//Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_LEGS;
		Menu_Legs();		
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ARMOR;
		Menu_Armor();		 
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

#else

void() Menu_Health =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
		
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuHPStr(1,#STR_HP1,#COST_HP1);
	str = ConstructMenuHPStr(2,#STR_HP2,#COST_HP2);
	l1 = strcat(l1,str);

	l2 = ConstructMenuHPStr(3,#STR_HP3,#COST_HP3);
	str = ConstructMenuHPStr(4,#STR_HP4,#COST_HP4);
	l2 = strcat(l2,str);

	l3 = ConstructMenuHPStr(5,#STR_HP5,#COST_HP5);
	str = ConstructMenuHPStr(6,#STR_HP6,#COST_HP6);
	l3 = strcat(l3,str);

	l4 = ConstructMenuHPStr(7,#STR_HP7,#COST_HP7);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Armor and Health   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

float(float numitem) GetHPCost =
{
	if (numitem == 1)
		return #COST_HP1;
	else if (numitem == 2)
		return #COST_HP2;
	else if (numitem == 3)
		return #COST_HP3;
	else if (numitem == 4)
		return #COST_HP4;
	else if (numitem == 5)
		return #COST_HP5;
	else if (numitem == 6)
		return #COST_HP6;
	else if (numitem == 7)
		return #COST_HP7;

	return 0;
};

void(float inp) Menu_Health_Input =
{
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_LEGS;
		Menu_Legs();
		self.impulse = 0;
		return;
	}
	else if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ARMOR;
		Menu_Armor();
		self.impulse = 0;
		return;
	}
	else if (inp == 10) {
		DropFromCustomClassGen();
		self.impulse = 0;
		return;
	}

	//WK 4/27/7 Don't allow special armors with 300 armor
	if (inp == 7 && (self.tf_items & #NIT_GEL || self.tf_items & #NIT_CERAMIC || self.tf_items & #NIT_KEVLAR || self.tf_items & #NIT_BLAST || (self.tf_items & #NIT_ASBESTOS && !(self.weapons_carried & #WEAP_FLAMETHROWER)))) {
		sprint(self, #PRINT_HIGH, "Sorry, you cannot buy special armors with 300 armor\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		self.impulse=0;
		return;
	}

	local float current;
	local float tosell, tobuy;
	current = 0;

	if (self.maxarmor == 50)
	{
	  if (self.health == 50) //WK 4/27/7 Made $0 armor 50/50 green, but handled in DropFrom...() in Custom.qc
		current = 0;
		if (self.health == 75)
			current = 1;
		else
			current = 2;		
	}
	else if (self.maxarmor == 100)
		current = 3;
	else if (self.maxarmor == 120)
		current = 4;
	else if (self.maxarmor == 150)
		current = 5;
	else if (self.maxarmor == 200)
		current = 6;
	else if (self.maxarmor == 300)
		current = 7;

	tosell = GetHPCost(current);
	tobuy = GetHPCost(inp);
	if (self.money < tobuy - tosell)
	{
		PrintNotEnoughMoney(tobuy - tosell);
		self.impulse = 0;
		return;
	}
	
	if (current == inp || current != 0) // sell back?
	{
		self.max_health = 50;
		self.health = self.max_health;
		self.maxarmor = 0;
		self.armorvalue = 0;
		self.armortype = 0;
		self.armor_allowed = 0;

		PrintRefund(tosell);
		UpdateArmorItem(self);

		if (current == inp)
		{
			Menu_Health();
			self.impulse = 0;
			return;
		}
	}

	if (inp == 1)
	{
		self.max_health = 75;
		self.health = self.max_health;
		self.maxarmor = 50;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.3;	// Green
		self.armor_allowed = 0.3; //Green max
		UpdateArmorItem(self);
	}
	else if (inp == 2)
	{
		self.max_health = 90;
		self.health = self.max_health;
		self.maxarmor = 50;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.3;	// Green
		self.armor_allowed = 0.3; //Green max
		UpdateArmorItem(self);
	}
	else if (inp == 3)
	{
		self.max_health = 80;
		self.health = self.max_health;
		self.maxarmor = 100;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (inp == 4)
	{
		self.max_health = 90;
		self.health = self.max_health;
		self.maxarmor = 120;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (inp == 5)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 150;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;	
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (inp == 6)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 200;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.8;	
		self.armor_allowed = 0.8;
		UpdateArmorItem(self);
	}
	else if (inp == 7)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 300;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.8;	
		self.armor_allowed = 0.8;
		UpdateArmorItem(self);
	}

	self.money = self.money - tobuy;

	PrintMoney();
	Menu_Health();
		
	self.impulse = 0;
};
#endif

// ==========================================
//	Prints Menu of Special Armor and Ammo
// ==========================================
void() Menu_Armor  =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_CERAMIC,#COST_CERAMIC,self.tf_items,#NIT_CERAMIC);
	str = ConstructMenuItemStr(2,#STR_GEL,#COST_GEL,self.tf_items,#NIT_GEL);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_ASBESTOS,#COST_ASBESTOS,self.tf_items,#NIT_ASBESTOS);
	str = ConstructMenuItemStr(4,#STR_KEVLAR,#COST_KEVLAR,self.tf_items,#NIT_KEVLAR);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_BLAST,#COST_BLAST,self.tf_items,#NIT_BLAST);
	str = ConstructMenuItemStr(6,#STR_FULLARMOUR,#COST_FULLARMOUR,self.cutf_items,#CUTF_FULLARMOUR);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_ARMOR_PIERCING,#COST_ARMOR_PIERCING,self.cutf2_items,#CUTF2_ARMOR_PIERCING);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Special Armor Menu úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Armor_Input =
{
	//WK 4/27/7 Don't allow special armors with 300 armor
	if (inp >= 1 && inp <= 5 && self.maxarmor == 300 && !(self.weapons_carried & #WEAP_FLAMETHROWER && inp == 3)) {
		sprint(self, #PRINT_HIGH, "Sorry, you cannot buy special armors with 300 armor\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		self.impulse=0;
		return;
	}

	if (inp == 1) {
		BuyItem(#COST_CERAMIC,#NIT_CERAMIC);
		HelpString("Ceramic Armor halves damage from lightning and nail attacks, including damage from tesla sentries, the laser cannon, the railgun, the light assault cannon, shamblers, and field generators.");
		Menu_Armor();
	}
	if (inp == 2) {
		BuyItem(#COST_GEL, #NIT_GEL);
		HelpString("Gel Impact Armor halves damage from melee attacks and krac grenades. Knife backstabs do not bypass Impact Armor. While you are moving, it provides a high miss chance against melee attacks.");
		Menu_Armor();
	}
	if (inp == 3) {
		BuyItem(#COST_ASBESTOS,#NIT_ASBESTOS);
		HelpString("Asbestos armor halves damage from fire attacks, including the Flamethrower, Incediary Cannon, Napalm Grenades, and the Daedalus Impulse Rifle. Additionally, you cannot be set on fire.");
		Menu_Armor();
	   }
	if (inp == 4) {
		BuyItem(#COST_KEVLAR,#NIT_KEVLAR);
		HelpString("Kevlar Armor reduces damage from all bullet attacks by 50%. Kevlar Armor does not cover the legs. Bullet attacks include the assault cannon, the shotguns, normal sentrygun fire, and both sniper rifles.");
		Menu_Armor();
	}
	if (inp == 5) {
		BuyItem(#COST_BLAST,#NIT_BLAST);
		HelpString("Blast Armor reduces damage from all non-fire based blast and area of effect attacks by 50%, including the rocket laucher, most grenades (including the EMP grenade), and a sentrygun's rocket attack.");
		Menu_Armor();
	}
	if (inp == 6) {
		BuyCuTF(#COST_FULLARMOUR,#CUTF_FULLARMOUR);
		HelpString("You spawn with full armor. Useful on maps without armor resupplies.");
		Menu_Armor();
	}
	if (inp == 7) {
		BuyCuTF2(#COST_ARMOR_PIERCING,#CUTF2_ARMOR_PIERCING);
		HelpString("Armor Piercing shots reduce the protection of special armors (like Kevlar) on enemies from 50% protection to 25% protection.");
		Menu_Armor();
	}
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_HEALTH;
		Menu_Health();		  
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL;
		Menu_Special(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}
	self.impulse = 0;
};

// ==================================
//	Prints Menu of Specials Available
// ==================================
void() Menu_Special =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_DETPACK,#COST_DETPACK,self.cutf_items,#CUTF_DETPACK);
	str = ConstructMenuItemStr(2,#STR_TOSSABLEDET,#COST_TOSSABLEDET,self.cutf_items,#CUTF_TOSSABLEDET);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_HOLO,#COST_HOLO,self.cutf_items,#CUTF_HOLO);
	str = ConstructMenuItemStr(4,#STR_CYBERAUG,#COST_CYBERAUG,self.cutf_items,#CUTF_CYBERAUG);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_SPYKIT,#COST_SPYKIT,self.cutf_items,#CUTF_SPY_KIT);
	str = ConstructMenuItemStr(6,#STR_CLIPEXTEND,#COST_CLIPEXTEND,self.cutf_items,#CUTF_CLIPEXTEND);
	l3 = strcat(l3,str);

	l4 = "\n";
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Special Items      úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Special_Input =
{
	local string st2;
	st2 = infokey(world, "no_spam");
	if (inp == 1) {
		if (st2 == "on") {//If admin disable it
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
			return;
		}
		if (self.cutf_items & #CUTF_DETPACK) //Already have it
		{
			PrintRefund(#COST_DETPACK);
			self.cutf_items = self.cutf_items - #CUTF_DETPACK;
			self.maxammo_detpack = self.maxammo_detpack - 1;
		}
		else if (self.money >= #COST_DETPACK) {
			self.money = self.money - #COST_DETPACK;
			self.cutf_items = self.cutf_items | #CUTF_DETPACK;
			self.maxammo_detpack = self.maxammo_detpack + 1;
			PrintMoney();
			HelpString("A powerful C-4 explosive with a large radius. Must stand still for a few seconds while planting. Can be set with the '´ƒÂÙµ', '´ƒÂÙ≤∞', or '´ƒÂÙµ∞' commands.");
		}
		else
			PrintNotEnoughMoney(#COST_DETPACK);
		Menu_Special();
	}
	if (inp == 2) {
		BuyCuTF(#COST_TOSSABLEDET,#CUTF_TOSSABLEDET);
		HelpString("Like a standard detpack, but is thrown while moving slowly. Bind a key to '‘ËÚÔ˜‰ÂÙ' to use. Automatically timed for 10 seconds.\n");		 
		Menu_Special();
	}
	if (inp == 3) {
		BuyCuTF(#COST_HOLO,#CUTF_HOLO);
		HelpString("Type '»ÔÏÔ' to activate or deactivate the hologram, which consumes cells. It can be used to fake out enemy players and sentry guns into thinking it's you.");
		Menu_Special();
	}
	if (inp == 4) {
		if (self.cutf_items & #CUTF_CYBERAUG)
		{
			self.maxammo_medikit = self.maxammo_medikit - 80;
			self.maxammo_cells = self.maxammo_cells - 80;
		}
		else
		{
			self.maxammo_medikit = self.maxammo_medikit + 80;
			self.maxammo_cells = self.maxammo_cells + 80;
		}
		BuyCuTF(#COST_CYBERAUG,#CUTF_CYBERAUG); 
		HelpString("The Cyberaug unit will automatically repair you while you stand stationary. This consumes cells (armor) and medikit ammo (health). It also increases your maxammo for cells and medikit ammo.");
		Menu_Special();
	}
	if (inp == 5) {
		BuyCuTF(#COST_SPYKIT,#CUTF_SPY_KIT);
		HelpString("The Spy Kit allows you to change your skin and color, using the 'ƒÈÛÁıÈÛÂ' command. You can also '∆ÂÈÁÓ' or '”∆ÂÈÁÓ' (silent feign) to play dead.");
		Menu_Special();
	}
	if (inp == 6) {
		BuyCuTF(#COST_CLIPEXTEND,#CUTF_CLIPEXTEND);
		HelpString("The clip extender increases the clip size on all clipped weapons (such as shotguns, the rocket launcher, the light assault cannon, etc.) between ´20% and ´50%, depending on the weapon. Reload time is increased as well.");
		Menu_Special();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ARMOR;
		Menu_Armor();		 
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ENGINEERING;
		Menu_Engineering(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}
	self.impulse = 0;
};

// ====================================
//	Prints Menu of Optional Items Here
// ====================================
void() Menu_Engineering =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_SPANNER,#COST_SPANNER,self.weapons_carried,#WEAP_SPANNER);
	str = ConstructMenuSentryStr(2,#STR_SENTRYGUN,#COST_SENTRYGUN);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_SENTRYUPGRADE,#COST_SENTRYUPGRADE,self.tf_items,#NIT_TURRET);
	str = ConstructMenuTeslaStr(4,#STR_TESLACOIL,#COST_TESLACOIL);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_TESLAUPGRADE,#COST_TESLAUPGRADE,self.tf_items,#NIT_TESLA_UPGRADE);
	str = ConstructMenuItemStr(6,#STR_SENSOR,#COST_SENSOR,self.cutf_items,#CUTF_SENSOR);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_TELEPORTER,#COST_TELEPORTER,self.tf_items,#NIT_TELEPORTER);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Engineering Items  úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Engineering_Input =
{
	if (inp == 1) {
		BuyWeapon(#COST_SPANNER,#WEAP_SPANNER);
		HelpString("The spanner lets you repair and upgrade friendly buildings, dismantle enemy buildings, and heal the armor of teammates at the cost of cells. If you don't have one, all build times are 50% slower.");
		UpdateWeaponItems();
		Menu_Engineering();
	}
	if (inp == 2) {
		if (self.cutf_items & #CUTF_SENTRYGUN)
		{
			if (self.cutf_items & #CUTF_DOUBLESENTRY)
			{
				BuyCuTF(#COST_SENTRYGUN*2,#CUTF_SENTRYGUN | #CUTF_DOUBLESENTRY); // will sell both
			}
			else
			{
				if (self.money < #COST_SENTRYGUN)
					BuyCuTF(#COST_SENTRYGUN,#CUTF_SENTRYGUN); // will sell it
				else
				{
					if (self.tf_items & #NIT_TESLA)
						BuyCuTF(#COST_SENTRYGUN,#CUTF_SENTRYGUN); // will sell it
					else
						BuyCuTF(#COST_SENTRYGUN,#CUTF_DOUBLESENTRY);
				}
			}
		}
		else
		{
			if (self.tf_items & #NIT_DOUBLETESLA)
			{
				sprint(self,#PRINT_HIGH,"You can only carry equipment for 2 offensive machines!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse = 0;
				return;
			}
			BuyCuTF(#COST_SENTRYGUN,#CUTF_SENTRYGUN);
			HelpString("Build sentryguns using the '¬ıÈÏ‰' command. Upgrade them using the Spanner. Type '”ÂÙÈÓÊÔ –ÛÈ œÓ' to let friendly psions move your buildings.");
		}
		Menu_Engineering();
	}
	if (inp == 3) {
		BuyItem(#COST_SENTRYUPGRADE,#NIT_TURRET);
		HelpString("The Sentry Upgrade allows you to convert any friendly sentry into a turret, which attaches to the ceiling to rain death on opponents safely out of the reach of most grenades.");
		Menu_Engineering();
	}
	if (inp == 4) {
		if (self.tf_items & #NIT_TESLA)
		{
			if (self.tf_items & #NIT_DOUBLETESLA)
			{
				BuyItem(#COST_TESLACOIL*2,#NIT_TESLA | #NIT_DOUBLETESLA); // will sell both
			}
			else
			{
				if (self.money < #COST_TESLACOIL)
					BuyItem(#COST_TESLACOIL,#NIT_TESLA); // will sell it
				else
				{
					if (self.cutf_items & #CUTF_SENTRYGUN)
						BuyItem(#COST_TESLACOIL,#NIT_TESLA); // will sell it			
					else					
						BuyItem(#COST_TESLACOIL,#NIT_DOUBLETESLA);
				}
			}
		}
		else
		{
			if (self.cutf_items & #CUTF_DOUBLESENTRY)
			{
				sprint(self,#PRINT_HIGH,"You can only carry equipment for 2 offensive machines!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse = 0;
				return;
			}		  
			BuyItem(#COST_TESLACOIL,#NIT_TESLA);
			HelpString("The Tesla Sentry is a CustomTF-only defense building that can be customized to meet your need. Choose between four levels of voltage (range), amplitude (damage), and power supply (health and ammo supply).");
		}
		Menu_Engineering();
	}
	if (inp == 5) {
		BuyItem(#COST_TESLAUPGRADE,#NIT_TESLA_UPGRADE);
		HelpString("The Tesla Upgrade gives you 6 normal upgrades and 2 misc upgrades (as opposed to the normal 4 and 1). If you don't have a spanner you build a default 2/2/2 tesla with an improved targeter, instead of a 1/2/1 tesla with no misc upgrades.");
		Menu_Engineering();
	}
	if (inp == 6) {
		BuyCuTF(#COST_SENSOR,#CUTF_SENSOR);
		HelpString("The Motion Sensor plays a loud alarm when an enemy comes near. It's main use is that, when hacked, it uncovers enemy spies and thieves.");
		Menu_Engineering();
	}
	if (inp == 7) {
		BuyItem(#COST_TELEPORTER,#NIT_TELEPORTER);
		HelpString("Build a pair of teleporters to allow your teammates to instantly travel between the two points. Limited in range, but can be hacked to increase this limit.");
		Menu_Engineering();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL;
		Menu_Special(); 	   
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL2;
		Menu_Special2();		
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}
	self.impulse = 0;
};

// ============================================//
// Prints 2nd Menu of Engineering Items 	   //
// ============================================//
void() Menu_Special2 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_SCANNER,#COST_SCANNER,self.tf_items,#NIT_SCANNER);
	str = ConstructMenuItemStr(2,#STR_AUTOSCANNER,#COST_AUTOSCANNER,self.tf_items,#NIT_AUTOSCANNER);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_JAMMER,#COST_JAMMER,self.cutf_items,#CUTF_JAMMER);
	str = ConstructMenuItemStr(4,#STR_DISPENSER,#COST_DISPENSER,self.cutf_items,#CUTF_DISPENSER);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_SECURITYCAMERA,#COST_SECURITYCAMERA,self.tf_items,#NIT_SECURITY_CAMERA);
	str = ConstructMenuItemStr(6,#STR_FIELDGEN,#COST_FIELDGEN,self.cutf_items,#CUTF_FIELDGEN);
	l3 = strcat(l3,str);

	l4 = "\n.. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Engineering Items2 úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Special2_Input =
{
	if (inp == 1)
	{
		if (self.tf_items & #NIT_SCANNER)
		{
			//Clean up auto-scanner (sync this with Custom.qc)
			if (self.tf_items & #NIT_AUTOSCANNER)
				self.money = self.money + #COST_AUTOSCANNER; //Sync this with price below
			self.tf_items = self.tf_items - (self.tf_items & #NIT_AUTOSCANNER);

			PrintRefund(#COST_SCANNER);
			self.tf_items = self.tf_items - #NIT_SCANNER;
			self.tf_items_flags = self.tf_items_flags - (self.tf_items & #NIT_SCANNER_ENEMY);
		}
		else if (self.money >= #COST_SCANNER) {
			self.money = self.money - #COST_SCANNER;
			self.tf_items = self.tf_items | #NIT_SCANNER;
			self.tf_items_flags = self.tf_items_flags | #NIT_SCANNER_ENEMY;
			PrintMoney();
			HelpString("The scanner allows you to detect enemies at a distance using the '”„·Óìí', '”„·Óïí', and '”„·Óìíí' commands. You can also disarm detpacks by walking over them, and uncover spies by touching them.");
		}
		else
			PrintNotEnoughMoney(#COST_SCANNER);
		Menu_Special2();
	}
	else if (inp == 2)
	{
		BuyItem(#COST_AUTOSCANNER,#NIT_AUTOSCANNER);
		HelpString("The autoscanner does a power 15 scan every second, letting you track enemies without explicitly having to use one of the scan commands.");
		Menu_Special2();
	}
	else if (inp == 3)
	{
		BuyCuTF(#COST_JAMMER, #CUTF_JAMMER);
		HelpString("The Scanner Jammer prevents you from being detected by other people's Scanners. Additionally, enemy teslas will take an extra half second to target you.");
		Menu_Special2();
	}
	else if (inp == 4)
	{
		BuyCuTF(#COST_DISPENSER,#CUTF_DISPENSER);
		HelpString("The dispenser is a vending machine for ammo and armor, which it generates on its own. When destroyed, it explodes with the force of all the ammo inside. You can issue the 'ƒÂÙ‰ÈÛÂÓÛÂÚ' command to do this manually. It can be hacked to vend health as well.");
		Menu_Special2();

	}
	else if (inp == 5)
	{
		BuyItem(#COST_SECURITYCAMERA,#NIT_SECURITY_CAMERA);
		HelpString("The Security Camera sends you a message every time it sees an enemy.");
		Menu_Special2();
	}
	else if (inp == 6)
	{
		BuyCuTF(#COST_FIELDGEN,#CUTF_FIELDGEN);
		HelpString("The field generator creates an impassible, invisible barrier that zaps enemies that try to walk through it. Teammates and Tae Kwon Do Black Belts can walk through it without being hurt.");
		Menu_Special2();
	}
	else if (inp == 7)
	{
		Menu_Special2();
	}
	else if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ENGINEERING;
		Menu_Engineering(); 	
	}
	else if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN1;
		Menu_Gren1();		
	}
	else if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;	
};

// ====================================
//	Prints Menu of Grenade-1s Available
// ====================================

void() Menu_Gren1 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuGrenStr(1,#STR_GR_NORMAL,#COST_GR_NORMAL,#GR_TYPE_NORMAL);
	str = ConstructMenuGrenStr(2,#STR_GR_NAPALM,#COST_GR_NAPALM,#GR_TYPE_NAPALM);
	l1 = strcat(l1,str);

	l2 = ConstructMenuGrenStr(3,#STR_GR_GAS,#COST_GR_GAS,#GR_TYPE_GAS);
	str = ConstructMenuGrenStr(4,#STR_GR_EMP,#COST_GR_EMP,#GR_TYPE_EMP);
	l2 = strcat(l2,str);
	
	l3 = ConstructMenuGrenStr(5,#STR_GR_FRAG,#COST_GR_FRAG,#GR_TYPE_FRAG);
	str = ConstructMenuGrenStr(6,#STR_GR_NAIL,#COST_GR_NAIL,#GR_TYPE_NAIL);
	l3 = strcat(l3,str);
	
	l4 = ConstructMenuGrenStr(7,#STR_GR_MIRV,#COST_GR_MIRV,#GR_TYPE_MIRV);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");
	
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades ≠ Combat  úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Gren1_Input =
{	
	local string st, st2;
	st = infokey(world, "no_gasgren");
	st2 = infokey (world, "no_spam");

	if (inp == 1)
	{
		BuyGren(#COST_GR_NORMAL,#GR_TYPE_NORMAL);
		HelpString("Deals 180 radius damage.");
		Menu_Gren1();
	}
	else if (inp == 2)
	{
		BuyGren(#COST_GR_NAPALM,#GR_TYPE_FLAME); // Flame was 750
		HelpString("Burns 8 times for 40 to 100 damage each time, with a delay of .1s to .4s between burns.");
		Menu_Gren1();
	}
	else if (inp == 3)
	{
		if (st == "on")
		{
			sprint(self, #PRINT_HIGH, "The admin has disabled gas grens on this map.\n");
			return;
		}
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
			return;
		}
		BuyGren(#COST_GR_GAS,#GR_TYPE_GAS);
		HelpString("Covers an area in poison gas for a short while, dealing massive damage to people staying within it.");
		Menu_Gren1();
	}
	else if (inp == 4)
	{
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
			return;
		}
		BuyGren(#COST_GR_EMP,#GR_TYPE_EMP);
		HelpString("Detonates 50% of the targets ammo, dealing 1 to 2 damage per ammo destroyed. Deals 120 damage to buildings. Also scrambles the timers on detpacks, and destroys backpacks and ammo boxes.");
		Menu_Gren1();
	}
	else if (inp == 5)
	{
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
			return;
		}
		BuyGren(#COST_GR_FRAG,#GR_TYPE_FRAG);
		HelpString("Shoots out lethal fragments of lead, which randomly bounce around the map, inflicting large damage on anything they touch.");
		Menu_Gren1();
	}
	else if (inp == 6)
	{
		BuyGren(#COST_GR_NAIL,#GR_TYPE_NAIL);
		HelpString("Hovers in place, shooting nails around it in a circle.");
		Menu_Gren1();
	}
	if (inp == 7)
	{
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
				return;
		}
		BuyGren(#COST_GR_MIRV,#GR_TYPE_MIRV);
		HelpString("Explodes into several smaller grenades, which then explode themselves, dealing massive damage.");
		Menu_Gren1();
	}
	
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL2;
		Menu_Special2();		
	}
	if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN2;
		Menu_Gren2();		 
	}
	else if (inp == 10)
		DropFromCustomClassGen();

	self.impulse = 0;
};

// ====================================
//	Prints Menu of Grenade-2s Available
// ====================================
void() Menu_Gren2 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuGrenStr(1,#STR_GR_FLARE,#COST_GR_FLARE,#GR_TYPE_FLARE);
	str = ConstructMenuGrenStr(2,#STR_GR_CALTROP,#COST_GR_CALTROP,#GR_TYPE_CALTROP);
	l1 = strcat(l1,str);

	l2 = ConstructMenuGrenStr(3,#STR_GR_CONCUSSION,#COST_GR_CONCUSSION,#GR_TYPE_CONCUSSION);
	str = ConstructMenuGrenStr(4,#STR_GR_PSIONIC,#COST_GR_PSIONIC,#GR_TYPE_PSIONIC);
	l2 = strcat(l2,str);	

	l3 = ConstructMenuGrenStr(5,#STR_GR_ANTIGRAV,#COST_GR_ANTIGRAV,#GR_TYPE_ANTIGRAV);
	str = ConstructMenuGrenStr(6,#STR_GR_BIOLOGICAL,#COST_GR_BIOLOGICAL,#GR_TYPE_BIO);
	l3 = strcat(l3,str);
	
	l4 = ConstructMenuGrenStr(7,#STR_GR_KRAC,#COST_GR_KRAC,#GR_TYPE_KRAC);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades ≠ Utility úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Gren2_Input =
{
	local string st, st2;
	st = infokey(world, "no_antigrav");
	st2 = infokey(world, "no_spam");

	//WK I should have done all the buy menus like this
	//SB I reckon - this one actually looks nice and makes sense
	if (inp == 1)
	{
		BuyGren(#COST_GR_FLARE, #GR_TYPE_FLARE);
		HelpString("Unlike other grenades, this one flies independently of gravity. Lights up the area where it hits. Also attracts heat seeking missiles, who will follow them in preference to everything else.");
		Menu_Gren2();
	}
	if (inp == 2)
	{
		if (st2 == "on")
			sprint(self, #PRINT_HIGH, "The admin has disabled spam devices on this map.\n");
		else
		{
			BuyGren(#COST_GR_CALTROP, #GR_TYPE_CALTROP);
			HelpString("Leaves painful caltrops on the ground, which lower the speed of anyone walking over them.");
			Menu_Gren2();
		}
	}
	if (inp == 3)
	{
		BuyGren(#COST_GR_CONCUSSION, #GR_TYPE_CONCUSSION);
		HelpString("Pushes away targets from the blast point, but inflicting no real damage. Also dazes people, making it hard for them to aim.");
		Menu_Gren2();
	}
	if (inp == 4)
	{
		#ifdef OLD_FLASH
		BuyGren(1000,#GR_TYPE_FLASH);
		HelpString("Blinds any targets within its radius.");
		#else
		BuyGren(#COST_GR_PSIONIC,#GR_TYPE_PSIONIC);
		HelpString("Paralyzes the target's mind, allowing him to move, but perform no other actions for a short time.");
		#endif
		Menu_Gren2();
	}
	if (inp == 5)
	{	
		if (st == "on")
			sprint(self, #PRINT_HIGH, "The admin has disabled anti-grav grens on this map.\n");
		else	
		{
			BuyGren(#COST_GR_ANTIGRAV, #GR_TYPE_ANTIGRAV);
			HelpString("Sets the target's gravity to a very low number, allowing the person to fly. Sort of.");
			Menu_Gren2();
		}
	}
	if (inp == 6)
	{
		BuyGren(#COST_GR_BIOLOGICAL, #GR_TYPE_BIO);
		HelpString("Infects all targets within the radius with a lethal biological weapon, which causes their health to decay over time.");
		Menu_Gren2();
	}
	if (inp == 7)
	{
		BuyGren(#COST_GR_KRAC, #GR_TYPE_KRAC);
		HelpString("Explodes on contact. Inflicts 200 damage to armor and buildings within its radius, tapering down to 75 damage to targets further away. Destroys detpacks, and ammo and armor respawns.");
		Menu_Gren2();
	}
	else if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN1;
		Menu_Gren1();		 
	}
	else if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		if (custom_mode!=1)
		{
			self.current_menu = #MENU_PROFESSION;
			Menu_Profession();			  
		}
		else
		{
			self.current_menu = #MENU_PROFICIENCY;
			Menu_Proficiency(); 	   
		}	   
	}
	if (inp == 10)
	{
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// =====================================
//	Prints Menu of Professions Available
// =====================================
void() Menu_Profession =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuJobStr(1,#STR_THIEF,#JOB_THIEF,#COST_THIEF,#COST_THIEF_EXTRA1,#COST_THIEF_EXTRA2,#STR_THIEF_EXTRA1,#STR_THIEF_EXTRA2);
	str = ConstructMenuJobStr(2,#STR_RUNNER,#JOB_RUNNER,#COST_RUNNER,0,0,"","");
	l1 = strcat(l1,str);

	l2 = ConstructMenuJobStr(3,#STR_WARLOCK,#JOB_WARLOCK,#COST_WARLOCK,#COST_WARLOCK_EXTRA1,#COST_WARLOCK_EXTRA2,#STR_WARLOCK_EXTRA1,#STR_WARLOCK_EXTRA2);
	str = ConstructMenuJobStr(4,#STR_CHAPLAN,#JOB_CHAPLAN,#COST_CHAPLAN,0,0,"","");
	l2 = strcat(l2,str);

	l3 = ConstructMenuJobStr(5,#STR_BERSERKER,#JOB_BERSERKER,#COST_BERSERKER,0,0,"","");
	str = ConstructMenuJobStr(6,#STR_GUERILLA,#JOB_GUERILLA,#COST_GUERILLA,#COST_GUERILLA_EXTRA1,#COST_GUERILLA_EXTRA2,#STR_GUERILLA_EXTRA1,#STR_GUERILLA_EXTRA2);
	l3 = strcat(l3,str);

	l4 = ConstructMenuJobStr(7,#STR_JUDOKA,#JOB_JUDOKA,#COST_JUDOKA,0,0,"","");
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");
	
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Skilled Profession úã\n\n", l1,l2,l3,l4, temp," dollars left\n\nUse ”À…ÃÃ to trigger ability\n");

};
void(float inp) Menu_Profession_Input =
{
	if (inp == 1) {
		if (extras_mode == 0)
		{
			if (self.job & #JOB_THIEF)
				BuyExtra(#COST_THIEF_EXTRA1,#COST_THIEF_EXTRA2);
			else {
				BuyJob(#COST_THIEF,#JOB_THIEF);
				HelpString("You become 'eyes-invisible' when walking, and fully invisible when standing still. With Shadowstep, you can walk briefly while fully invis. With Shadowsprint you move faster while hiding.");
			}
		}
		else {
			BuyJob(#COST_THIEF,#JOB_THIEF);
		}
		Menu_Profession();
	}
	if (inp == 2) {
		BuyJob(#COST_RUNNER,#JOB_RUNNER);
		HelpString("When you activate this job, your speed increases dramatically for #PHASE1 seconds, but you move at slow speed for #PHASE2 seconds afterwards.");
		Menu_Profession();
	}
	if (inp == 3) { //Sync this with price in knife
		if (extras_mode == 0)
		{
			if (self.job & #JOB_WARLOCK)
				BuyExtra(#COST_WARLOCK_EXTRA1,#COST_WARLOCK_EXTRA2);
			else {
				BuyJob(#COST_WARLOCK,#JOB_WARLOCK); 		   
				HelpString("Warlocks must kill people with their knife to collect hearts. Then they can use the hearts to summon creatures. Collecting gibs gives a summon more health; heads increase its damage.");
			}
		}
		else {
			BuyJob(#COST_WARLOCK,#JOB_WARLOCK);
		}
		Menu_Profession();
	}
	if (inp == 4) {
		BuyJob(#COST_CHAPLAN,#JOB_CHAPLAN);
		HelpString("When you activate this job, you become unable to do anything but throw grenades. However, all teammates nearby turn invisible, inflict extra damage, and take less damage.");
		Menu_Profession();
	}
	if (inp == 5) {
		BuyJob(#COST_BERSERKER,#JOB_BERSERKER);
		HelpString("When you activate this job, you inflict #BERSERKER_HP_COST damage on yourself, but deal #BERSERKER_DMGFACTOR times damage for #BERSERK_TIME seconds.");
		Menu_Profession();
	}
	if (inp == 6) {
		if (extras_mode == 0)
		{
			if (self.job & #JOB_GUERILLA)
				BuyExtra(#COST_GUERILLA_EXTRA1,#COST_GUERILLA_EXTRA2);
			else {
				BuyJob(#COST_GUERILLA,#JOB_GUERILLA);
				HelpString("Guerillas can lay explosive mines on the ground. Buying higher levels of the profession opens up more powerful mines. Hand grenades can be converted into mines.");
			}
		}
		else {
			BuyJob(#COST_GUERILLA,#JOB_GUERILLA);
		}
		Menu_Profession();
	}
	if (inp == 7) {
		BuyJob(#COST_JUDOKA,#JOB_JUDOKA); 
		HelpString("When you activate this ability, you disarm an opponent in front of you, taking his weapon as your own for #DISARM_TIME seconds. You also inflict damage to the target, and leave him unable to attack for #CANT_ATTACK_TIME seconds.");
		Menu_Profession();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN2;
		Menu_Gren2();		 
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFESSION2;
		Menu_Profession2(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ==================================
//	Prints Second page of Professions
// ==================================
void() Menu_Profession2 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuJobStr(1,#STR_ARMY,#JOB_ARMY,#COST_ARMY,#COST_ARMY_EXTRA1,#COST_ARMY_EXTRA2,#STR_ARMY_EXTRA1,#STR_ARMY_EXTRA2);
	str = ConstructMenuJobStr(2,#STR_HACKER,#JOB_HACKER,#COST_HACKER,0,0,"","");
	l1 = strcat(l1,str);


	l2 = ConstructMenuJobStr(3,#STR_MARTYR,#JOB_MARTYR,#COST_MARTYR,0,0,"","");
	str = ConstructMenuJobStr(4,#STR_CRUSADER,#JOB_CRUSADER,#COST_CRUSADER,0,0,"","");
	l2 = strcat(l2,str);

	//WK 4/27/7 Add Psion and TKD Jobs!
	l3 = ConstructMenuJobStr(5,#STR_TKD,#JOB_TKD,#COST_TKD,0,0,"","");
	str = ConstructMenuJobStr(6,#STR_PSION,#JOB_PSION,#COST_PSION,#COST_PSION_EXTRA1,#COST_PSION_EXTRA2,#STR_PSION_EXTRA1,#STR_PSION_EXTRA2);
	l3 = strcat(l3,str);

	l4 = "\n.. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú More Professions   úã\n\n", l1,l2,l3,l4, temp," dollars left\n\nUse ”À…ÃÃ to trigger ability\n");
};

void(float inp) Menu_Profession2_Input =
{
	if (inp == 1) {
		if (extras_mode == 0)
		{
			if (self.job & #JOB_ARMY)
				BuyExtra(#COST_ARMY_EXTRA1,#COST_ARMY_EXTRA2);
			else {
				BuyJob(#COST_ARMY,#JOB_ARMY);
				HelpString("With this skill, you can summon a bot to help out your team every few minutes. With higher ranks, you can have multiple bots out at once. Bots become more powerful over time.");
			}
		}
		else {
			BuyJob(#COST_ARMY,#JOB_ARMY);
		}
		Menu_Profession2();
	}
	if (inp == 2) {
		BuyJob(#COST_HACKER,#JOB_HACKER);
		HelpString("Target a building within 10 meters and hit skill. If it is an enemy building, you can sabotage it, or even take it over. If it is a friendly building, you can improve it. You can even hack enemies with Cyberaug.");
		Menu_Profession2();
	}
	if (inp == 3) { 
		BuyJob(#COST_MARTYR,#JOB_MARTYR);
		HelpString("When you activate this ability, you turn invincible for #MARTYR_TIME seconds, and then die, losing a frag.");
		Menu_Profession2();
	}
	if (inp == 4) {
		BuyJob(#COST_CRUSADER,#JOB_CRUSADER);
		HelpString("Crusaders use mana to grant powerful abilities to their teammates. They regenerate mana at a constant rate.");
		Menu_Profession2();
	}
	if (inp == 5) { 
		BuyJob(#COST_TKD,#JOB_TKD);
		HelpString("You can make mighty leaps through the air. If not moving, you jump/double jump straight up. If moving, you do a fast long jump. If you touch enemies or enemy buildings while moving, you deliver a mightly kick.");
		Menu_Profession2();
	}
	if (inp == 6) {
		if (extras_mode == 0)
		{
			if (self.job & #JOB_PSION)
				BuyExtra(#COST_PSION_EXTRA1,#COST_PSION_EXTRA2);
			else {
				BuyJob(#COST_PSION,#JOB_PSION);
				HelpString("The Psion has the ability to mind blast enemies and move things through the air. They automatically uncover enemy spies and thieves nearby. Spy/Psions are immune to this effect, and are also immune to hacked motion sensors.");
			}
		}
		else {
			BuyJob(#COST_PSION,#JOB_PSION);
		}
		Menu_Profession2();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFESSION;
		Menu_Profession();		  
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFICIENCY;
		Menu_Proficiency(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// =====================================
//	Prints Menu of Proficiencies Available
// =====================================
void() Menu_Proficiency =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_STEALTH,#COST_STEALTH,self.cutf_items,#CUTF_STEALTH);
	str = ConstructMenuItemStr(2,#STR_HIGHJUMP,#COST_HIGHJUMP,self.cutf_items,#CUTF_HIGHJUMP);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_CANNIBAL,#COST_CANNIBAL,self.cutf2_items,#CUTF2_CANNIBAL);
	str = ConstructMenuItemStr(4,#STR_EXPBODY,#COST_EXPBODY,self.cutf_items,#CUTF_EXPBODY);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_CLOSECOMBAT,#COST_CLOSECOMBAT,self.cutf_items,#CUTF_CLOSECOMBAT);
	str = ConstructMenuItemStr(6,#STR_DEMONLORE,#COST_DEMONLORE,self.cutf_items,#CUTF_DEMONLORE);
	l3 = strcat(l3,str);

	l4 = "\n";
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Proficiencies      úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
}; 

void(float inp) Menu_Proficiency_Input =
{
	if (inp == 1) {
		BuyCuTF(#COST_STEALTH,#CUTF_STEALTH);
		HelpString("With this proficiency, you don't make any noise while falling, jumping, walking, or swimming.");
		Menu_Proficiency();
	}
	if (inp == 2) {
		BuyCuTF(#COST_HIGHJUMP,#CUTF_HIGHJUMP);
		HelpString("With this proficiency, you jump twice as high.");
		Menu_Proficiency();
	}
	if (inp == 3) {
		BuyCuTF2(#COST_CANNIBAL,#CUTF2_CANNIBAL);
		HelpString("As a cannibal, you can eat gibs in order to heal yourself (up to 25 points above your maximum) and even repair your armor.");
		Menu_Proficiency();
	}
	if (inp == 4) {
		BuyCuTF(#COST_EXPBODY,#CUTF_EXPBODY);
		HelpString("When you die you explode like a grenade for #EXPBODY_DMG damage.");
		Menu_Proficiency();
	}
	if (inp == 5) {
		BuyCuTF(#COST_CLOSECOMBAT,#CUTF_CLOSECOMBAT);
		HelpString("Your melee attacks have 50% more reach, and you deal +50% more damage and take -20% less damage from melee attacks. You also leap 20% faster with TKD.");
		Menu_Proficiency();
	}
	if (inp == 6) {
		BuyCuTF(#COST_DEMONLORE,#CUTF_DEMONLORE);
		HelpString("You take between 50% and 80% of damage from demons, depending on the attack. Additionally, you can '…ƒ' demons and summoned Army grunts to see their health.");
		Menu_Proficiency();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		if (custom_mode!=1)
		{
			self.current_menu = #MENU_PROFESSION2;
			Menu_Profession2(); 		   
		}
		else
		{
			self.current_menu = #MENU_GREN2;
			Menu_Gren2();			 
		}			  
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_OPTION;
		Menu_Option();		  
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ====================================
//	Prints Menu of Optional Items Here
// ====================================
void() Menu_Option =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_AUTOID,#COST_AUTOID,self.tf_items,#NIT_AUTOID);
	str = ConstructMenuItemStr(2,#STR_RESPAWNGUARD,#COST_RESPAWNGUARD,self.tf_items,#NIT_RESPAWN_GUARD);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_HOVERBOOTS,#COST_HOVERBOOTS,self.tf_items,#NIT_HOVER_BOOTS);
	str = ConstructMenuItemStr(4,#STR_BOOTUPGRADE,#COST_BOOTUPGRADE,self.tf_items,#NIT_HOVER_BOOTS_UPGRADE);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_AMMOBACKPACK,#COST_AMMOBACKPACK,self.tf_items,#NIT_AMMO_BACKPACK);
	str = ConstructMenuItemStr(6,#STR_AMMOBANDOLIER,#COST_AMMOBANDOLIER,self.tf_items,#NIT_AMMO_BANDOLIER);
	l3 = strcat(l3,str);

	l4 = "\n";
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Optional Equipment úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Option_Input =
{
	if (inp == 1) {
		BuyItem(#COST_AUTOID,#NIT_AUTOID);
		HelpString("Executes the '…ƒ' command for you automatically every second.");
		Menu_Option();
	}
	if (inp == 2) { 
		BuyItem(#COST_RESPAWNGUARD,#NIT_RESPAWN_GUARD);
		HelpString("When you respawn, you are invulnerable for #RESPAWN_GUARD_TIME seconds.");
		Menu_Option();
	}
	if (inp == 3) {
		BuyItem(#COST_HOVERBOOTS,#NIT_HOVER_BOOTS);
		HelpString("When you are in the air, if you hold down jump, you will hover in place, allowing you to cross chasms or dodge attacks. Has limited fuel (enough for #MAX_HOVER_FUEL seconds) which recharges over time.");
		Menu_Option();
	}
	if (inp == 4) {
		BuyItem(#COST_BOOTUPGRADE, #NIT_HOVER_BOOTS_UPGRADE);
		HelpString("Doubles the maximum fuel for your hover boots.");
		Menu_Option();
	}
	if (inp == 5) {
		BuyItem(#COST_AMMOBACKPACK,#NIT_AMMO_BACKPACK);
		HelpString("Greatly increases your ammo carrying capacity. If you buy both the backpack and bandolier, you get an extra detpack of each type you own.");
		Menu_Option();
	}
	if (inp == 6) {
		BuyItem(#COST_AMMOBANDOLIER,#NIT_AMMO_BANDOLIER);
		HelpString("Slightly increass your ammo carrying capacity, but greatly increases your starting ammo. Also gives you one extra grenade of each type you carry.");
		Menu_Option();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFICIENCY;
		Menu_Proficiency(); 	   
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_KNOCKTATION;
		Menu_Knocktation();		  
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ====================================
//	Prints Menu of Knocktation Here
// ====================================
void() Menu_Knocktation =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_HWGUY,#COST_HWGUY,self.cutf_items,#CUTF_HWGUY);
	str = ConstructMenuItemStr(2,#STR_GYMNAST,#COST_GYMNAST,self.cutf_items,#CUTF_GYMNAST);
	l1 = strcat(l1,str);


	l2 = ConstructMenuItemStr(3,#STR_VOID_BODY,#COST_VOID_BODY,self.cutf2_items,#CUTF2_VOID_BODY);
	str = ConstructMenuItemStr(4,#STR_RECOILLESS,#COST_RECOILLESS,self.cutf2_items,#CUTF2_RECOILLESS_RIFLE);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_MASSIVE_ATTACK,#COST_MASSIVE_ATTACK,self.cutf2_items,#CUTF2_MASSIVE_ATTACK);
	str = ConstructMenuItemStr(6,#STR_BLACK_HOLE_GUN,#COST_BLACK_HOLE_GUN,self.cutf2_items,#CUTF2_BLACK_HOLE_GUN);
	l3 = strcat(l3,str);


	l4 = "\n";
	l4 = strcat(l4,".. –ÚÂˆ    \n..         \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Knocktation Optionsúã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Knocktation_Input =
{
	if (inp == 1) {
		if (self.cutf_items & #CUTF_GYMNAST)
		{
			sprint(self, #PRINT_HIGH, "Having Gymnast and Aspect of HWGuy is illogical.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else if (self.cutf2_items & #CUTF2_VOID_BODY)
		{
			sprint(self, #PRINT_HIGH, "Having Void Body and Aspect of HWGuy is not only illogical, it's stupid as well...\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF(#COST_HWGUY,#CUTF_HWGUY);
			HelpString("With this proficiency, you are not knocked around by attacks.");
			Menu_Knocktation();
		}
	}
	if (inp == 2) {
		if (self.cutf_items & #CUTF_HWGUY)
		{
			sprint(self, #PRINT_HIGH, "Trust me, you don't want Aspect of HWGuy AND Gymnast.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF(#COST_GYMNAST,#CUTF_GYMNAST);
			HelpString("You get knocked around twice as much by attacks. This makes things like rocket jumping easier, and helps you leave the area of hostile attacks.");
			Menu_Knocktation();
		}
	}
	if (inp == 3) {
		if (self.cutf_items & #CUTF_HWGUY)
		{
			sprint(self, #PRINT_HIGH, "Having Aspect and Void Body together would violate the space-time continuum.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF2(#COST_VOID_BODY,#CUTF2_VOID_BODY);
			HelpString("You give your body negative mass, which makes you recoil *towards* attacks, instead of away from them.");
			Menu_Knocktation();
		}
	}
	if (inp == 4) {
		if (self.cutf2_items & #CUTF2_MASSIVE_ATTACK)
		{
			sprint(self, #PRINT_HIGH, "You can't both eliminate all knockback, and double it. Well, you could, but that would be rather pointless.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else if (self.cutf2_items & #CUTF2_BLACK_HOLE_GUN)
		{
			sprint(self, #PRINT_HIGH, "We will not allow you to both eliminate your recoil, and reverse it. Sorry, but that's just stupid.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF2(#COST_RECOILLESS,#CUTF2_RECOILLESS_RIFLE);
			HelpString("The Recoilless augment makes all of your weapon attacks not knock back the enemy in the slightest.");
			Menu_Knocktation();
		}
	}
	if (inp == 5) {
		if (self.cutf2_items & #CUTF2_RECOILLESS_RIFLE)
		{
			sprint(self, #PRINT_HIGH, "Trying to double your knockback and set it to zero, is really just like setting it to zero, so try again.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF2(#COST_MASSIVE_ATTACK,#CUTF2_MASSIVE_ATTACK);
			HelpString("The Massive Attacks upgrade doubles the knockback of all of your weapons.");
			Menu_Knocktation();
		}
	}
	if (inp == 6) {
		if (self.cutf2_items & #CUTF2_RECOILLESS_RIFLE)
		{
			sprint(self, #PRINT_HIGH, "Black hole guns reverse knockback and recoilless eliminates knockback. Pick which one you actually want.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF2(#COST_BLACK_HOLE_GUN,#CUTF2_BLACK_HOLE_GUN);
			HelpString("The Black Hole Gun upgrade makes your weapons suck people in to you with knockback, instead of pushing them away.");
			Menu_Knocktation();
		}
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_OPTION;
		Menu_Option(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

//___________________________________________________________________________________
//===================================================================================
// Item string constructors for menu displayers  
string(float itemnum, string itemdesc,float cost,float field, float bit) ConstructMenuItemStr =
{
	local string result;
	
	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (field & bit)
		result = strcat("#CHAR_BOUGHT ",result);
	else
		result = strcat("  ",result);	 

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");
		if (cost > self.money && !(field & bit))
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (field & bit)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuSentryStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (!self.cutf_items & #CUTF_SENTRYGUN)
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if (self.cutf_items & #CUTF_DOUBLESENTRY)
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			result = strcat("1 ",result);	 
			numbought = 1;
		}
	}

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");
		if (cost > self.money && !numbought)
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (numbought)
	{
		if (numbought == 2)
			itemdesc = ftos(cost*2);

		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	}
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuTeslaStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (!self.tf_items & #NIT_TESLA)
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if (self.tf_items & #NIT_DOUBLETESLA)
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			result = strcat("1 ",result);	 
			numbought = 1;
		}
	}

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");
		if (cost > self.money && !numbought)
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (numbought)
	{
		if (numbought == 2)
			itemdesc = ftos(cost*2);

		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	}
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

string(float itemnum, string itemdesc,float jobid,float cost, float extra1cost, float extra2cost, string extra1st, string extra2st) ConstructMenuJobStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (!self.job & jobid)
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if (self.job & #JOB_EXTRA2)
		{
			result = strcat("3 ",result);	 
			numbought = 3;
		}
		else if (self.job & #JOB_EXTRA1)
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			if (!extra1cost || extras_mode)
				result = strcat("#CHAR_BOUGHT ",result);	
			else
				result = strcat("1 ",result);	 
			
			numbought = 1;
		}
	}

	if (numbought)
	if (!extras_mode)
	if (extra1cost)
	{
		if (numbought == 1)
			itemdesc = extra1st;
		else if (numbought == 2)
			itemdesc = extra2st;
		else if (numbought == 3)
			itemdesc = #STR_SELLEXTRAS;
	}

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!numbought)
		if (cost > self.money + SpentOnJob())
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠  ");
	else if (cost < 1000)
		result = strcat(result,"≠ ");
	else if (cost < 10000)
		result = strcat(result,"≠");
	else
		result = strcat(result,"");

	if (numbought && extra1cost && numbought != 3 && !extras_mode)
		result = strcat(result," +");
	else
		result = strcat(result," ");
	
	itemdesc = ftos(cost);

	if (numbought)
	{
		if (numbought == 3)
			itemdesc = ftos(cost+extra1cost+extra2cost);
		else if (numbought == 2)
			itemdesc = ftos(extra2cost);
		else if (extra1cost && !extras_mode)
			itemdesc = ftos(extra1cost);

		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	}
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

float() SpentOnJob =
{
	if (self.job & #JOB_THIEF)
		return #COST_THIEF;
	if (self.job & #JOB_RUNNER)
		return #COST_RUNNER;
	if (self.job & #JOB_WARLOCK)
	{
		if (self.job & #JOB_EXTRA2)
			return #COST_WARLOCK + #COST_WARLOCK_EXTRA1 + #COST_WARLOCK_EXTRA2;
		if (self.job & #JOB_EXTRA1)
			return #COST_WARLOCK + #COST_WARLOCK_EXTRA1;
		return #COST_WARLOCK;
	}
	if (self.job & #JOB_CHAPLAN)
		return #COST_CHAPLAN;
	if (self.job & #JOB_BERSERKER)
		return #COST_BERSERKER;
	if (self.job & #JOB_GUERILLA)
	{
		if (self.job & #JOB_EXTRA2)
			return #COST_GUERILLA + #COST_GUERILLA_EXTRA1 + #COST_GUERILLA_EXTRA2;
		if (self.job & #JOB_EXTRA1)
			return #COST_GUERILLA + #COST_GUERILLA_EXTRA1;
		return #COST_GUERILLA;
	}
	if (self.job & #JOB_JUDOKA)
		return #COST_JUDOKA;
	if (self.job & #JOB_ARMY)
	{
		if (self.job & #JOB_EXTRA2)
			return #COST_ARMY + #COST_ARMY_EXTRA1 + #COST_ARMY_EXTRA2;
		if (self.job & #JOB_EXTRA1)
			return #COST_ARMY + #COST_ARMY_EXTRA1;
		return #COST_ARMY;
	}
	if (self.job & #JOB_HACKER)
		return #COST_HACKER;
	if (self.job & #JOB_MARTYR)
		return #COST_MARTYR;
	if (self.job & #JOB_CRUSADER)
		return #COST_CRUSADER;
	if (self.job & #JOB_TKD)
		return #COST_TKD;
	if (self.job & #JOB_PSION)
	{
		if (self.job & #JOB_EXTRA1)
			return #COST_PSION + #COST_PSION_EXTRA1;
		return #COST_PSION;
	}
};

string(float itemnum, string itemdesc,float cost,float grentype) ConstructMenuGrenStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if ((self.tp_grenades_1 != grentype) && (self.tp_grenades_2 != grentype))
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if ((self.tp_grenades_1 == grentype) && (self.tp_grenades_2 == grentype))
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			result = strcat("1 ",result);	 
			numbought = 1;
		}		 
	}
	
	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!numbought)
		if (cost > self.money + SpentOnGrens())
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}

	result = strcat(result,itemdesc);

	if (numbought == 2)
		cost = cost * 2;

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	 
	itemdesc = ftos(cost);

	if (numbought)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

float(float grentype) GetGrenCost =
{
	if (grentype == 0)
		return 0;
	if (grentype == #GR_TYPE_NORMAL)
		return #COST_GR_NORMAL;
	if (grentype == #GR_TYPE_CONCUSSION)
		return #COST_GR_CONCUSSION;
	if (grentype == #GR_TYPE_NAIL)
		return #COST_GR_NAIL;
	if (grentype == #GR_TYPE_MIRV)
		return #COST_GR_MIRV;
	if (grentype == #GR_TYPE_NAPALM)
		return #COST_GR_NAPALM;
	if (grentype == #GR_TYPE_FLARE)
		return #COST_GR_FLARE;
	if (grentype == #GR_TYPE_GAS)
		return #COST_GR_GAS;
	if (grentype == #GR_TYPE_EMP)
		return #COST_GR_EMP;
	if (grentype == #GR_TYPE_PSIONIC)
		return #COST_GR_PSIONIC;
	if (grentype == #GR_TYPE_FRAG)
		return #COST_GR_FRAG;
	if (grentype == #GR_TYPE_KRAC)
		return #COST_GR_KRAC;
	if (grentype == #GR_TYPE_ANTIGRAV)
		return #COST_GR_ANTIGRAV;
	if (grentype == #GR_TYPE_BIO)
		return #COST_GR_BIOLOGICAL;
	if (grentype == #GR_TYPE_CALTROP)
		return #COST_GR_CALTROP;

	return 0;
};

float() SpentOnGrens =
{
	local float result;

	result = GetGrenCost(self.tp_grenades_1);
	result = result + GetGrenCost(self.tp_grenades_2);

	return result;
};

float() SpentOnLegs =
{
	if (self.custom_speed == #CUSTOM_SPEED1)
		return #COST_SPEED1;
	if (self.custom_speed == #CUSTOM_SPEED2)
		return #COST_SPEED2;
	if (self.custom_speed == #CUSTOM_SPEED3)
		return #COST_SPEED3;
	if (self.custom_speed == #CUSTOM_SPEED4)
		return #COST_SPEED4;
	if (self.custom_speed == #CUSTOM_SPEED5)
		return #COST_SPEED5;
	if (self.custom_speed == #CUSTOM_SPEED6)
		return #COST_SPEED6;
	
	return 0;
};

float() GetCurrentLegs =
{
	if (self.custom_speed == #CUSTOM_SPEED1)
		return 1;
	if (self.custom_speed == #CUSTOM_SPEED2)
		return 2;
	if (self.custom_speed == #CUSTOM_SPEED3)
		return 3;
	if (self.custom_speed == #CUSTOM_SPEED4)
		return 4;
	if (self.custom_speed == #CUSTOM_SPEED5)
		return 5;
	if (self.custom_speed == #CUSTOM_SPEED6)
		return 6;
	
	return 7;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuSpeedStr =
{
	local string result;
	local float bought;
	
	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	bought = #FALSE;

	if (GetCurrentLegs() == itemnum)
	{
		result = strcat("#CHAR_BOUGHT ",result);
		bought = #TRUE;
	}
	else
		result = strcat("  ",result);	 

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!bought)
		if (cost > self.money + SpentOnLegs())
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 10)
		result = strcat(result,"≠    ");
	else if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (bought && cost)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

float() SpentOnHP =
{
	//WK 1/7/7 This needs to be aligned with the constants
	if (self.maxarmor == 300)
		return #COST_HP7;
	if (self.maxarmor == 200)
		return #COST_HP6;
	if (self.maxarmor == 150)
		return #COST_HP5;
	if (self.maxarmor == 120)
		return #COST_HP4;
	if (self.maxarmor == 100)
		return #COST_HP3;
	if (self.health == 90)
		return #COST_HP2;
	if (self.health == 75)
		return #COST_HP1;
	
	return 0;
};

float() GetCurrentHPItem =
{
	//WK 1/7/7 This needs to be aligned with the constants
	if (self.maxarmor == 300)
		return 7;
	if (self.maxarmor == 200)
		return 6;
	if (self.maxarmor == 150)
		return 5;
	if (self.maxarmor == 120)
		return 4;
	if (self.maxarmor == 100)
		return 3;
	if (self.health == 90)
		return 2;
	if (self.health == 75)
		return 1;
	
	return 0;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuHPStr =
{
	local string result;
	local float bought;
	
	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	bought = #FALSE;

	if (GetCurrentHPItem() == itemnum)
	{
		result = strcat("#CHAR_BOUGHT ",result);
		bought = #TRUE;
	}
	else
		result = strcat("  ",result);	 

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!bought)
		if (cost > self.money + SpentOnHP())
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 10)
		result = strcat(result,"≠    ");
	else if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (bought && cost)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc); 
	
	result = strcat(result,"\n");

	return result;
};

void(entity player) UpdateArmorItem =
{
	player.items = player.items - (player.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));	
	if (player.armortype >= 0.8)
		player.items = player.items | #IT_ARMOR3;
	else if (player.armortype >= 0.6)
		player.items = player.items | #IT_ARMOR2;
	else if (player.armortype >= 0.3)
		player.items = player.items | #IT_ARMOR1;
};
