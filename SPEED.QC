//some of this by Cyto 3-27-00
//other by CH

//Used for testing tolerence, prints out various stuff
//#define SHOW_CHEAT_LEVELS

//If defined any cheat cmd results in kicking
//#define ENABLE_CHEAT_CMDS

void() Kick_My_Owner =
{
	local string ip;
	  local string oldname,nospeed;
	local float banned,off;
	banned = #FALSE;

	//Don't kick if cheats are off
	off = #FALSE;
	nospeed = infokey(world,"nospeed");
	if (nospeed != string_null) {
		off = stof(nospeed);
	}
	if (off) return;


	oldname = self.owner.netname;
	sprint(self.owner, #PRINT_HIGH,"\nYou have been кицкед for цхеатинг.\nIf you were not cheating, I apologize.\nHave a nice day.\n");

	ip = infokey(self.owner,"ip");
	if (infokey(world,"infip") == ip) { // second infraction. ban.
		localcmd("addip ");
		localcmd(ip);
		localcmd("\n");
		localcmd("localinfo infip \"\"");
		banned = #TRUE;
	} else {
		localcmd("localinfo infip ");
		localcmd(ip);
		localcmd("\n");
	}

	stuffcmd(self.owner,"disconnect\n");
	bprint(#PRINT_HIGH, oldname);
	if (banned)
		bprint(#PRINT_HIGH, " was BANNED for cheating!\n");
	else
		bprint(#PRINT_HIGH, " was kicked for cheating.\n");

	self.think = SUB_Null;
	dremove(self);
};

#define MAXPERCENT 35 //WK this looks good for wall strafing
//reasons for not checking
#define IMMUNE	1
#define GRAPPLE 2
#define FLYING	4
#define NOCLASS 	16
#define BUILDING	32
#define DEAD	64

void () TeamFortress_CheckForSpeed =
{
	local vector tempvec;
	local float max, dist, check, immune;
	//local string ip;	
	local string nospeed;
	local float off;

	off = #FALSE;
	nospeed = infokey(world,"nospeed");
	if (nospeed != string_null) {
		off = stof(nospeed);
	}
	if (off) return;

max = self.owner.maxspeed;
if ((self.owner.job & #JOB_RUNNER) && (self.owner.job & #JOB_ACTIVE))
	max = max + 200;	
//make sure ok to check
if (self.owner.immune_to_chec > time)
	immune = immune | #IMMUNE; //its ok since #IMMUNE becomes 1
if (self.owner.hook_out)
	immune = immune | #GRAPPLE;
//WK We should boot if they have no set speed and are moving
//if (self.owner.maxspeed == 0) // no set speed
if (!(self.owner.flags & #FL_ONGROUND)) //WK People in air immune
	immune = immune | #FLYING;
if (self.owner.playerclass == #PC_UNDEFINED)
	immune = immune | #NOCLASS;
if (self.owner.done_custom & #CUSTOM_BUILDING)
	immune = immune | #BUILDING;
if (self.owner.health <= 0)
	immune = immune | #DEAD;
if (!self.owner.is_connected)
	dremove(self);

if (immune)
	check = #FALSE;
else
	check = #TRUE;

	//WK Lowered percent chance of restuffing because stuffcmds() cause overflows
	if (!self.lip || !(self.has_camera) || (random() <= 0.1)){ //periodically reset ping and gotwalls.
		self.has_camera = 0;
		self.has_camera = stof(infokey(self.owner,"ping")) / 20;
#ifdef ENABLE_CHEAT_CMDS
		if (!self.lip || (random() <= 0.1)){
			stuffcmd(self.owner,"alias aa_enabled \"impulse #I_CHEAT_ONE;wait;impulse #I_CHEAT_TWO;wait;impulse #I_CHEAT_THREE\"\n");
			stuffcmd(self.owner,"alias +aa \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias -aa \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias aa_teamlock \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias aa_on \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias aa_off \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias +showradar \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias -showradar \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias cl_speed \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias cl_gotwalls \"aa_enabled\"\n");
			stuffcmd(self.owner,"alias fullbright \"aa_enabled\"\n");
			self.lip = 1;
		}
#endif
	}

	// Ignore z part of vector
	tempvec = self.oldorigin - self.owner.origin;
	tempvec_z = 0;

	dist = vlen(tempvec);

	if (check && (max == 0) && (dist > 100)) { //Definitely cheating...
		self.owner.cheat_level = self.owner.cheat_level + 700;
	}
	if (check && (dist > (max * (1 + (#MAXPERCENT / 100))))) // Maybe cheating.
		self.owner.cheat_level = self.owner.cheat_level + 200;
	if (self.owner.cheat_level >= 900 && self.has_sentry == 0 && dist > max) {
		bprint(#PRINT_HIGH, self.owner.netname);
		bprint(#PRINT_HIGH, " may be cheating. (Current:");
		bprint(#PRINT_HIGH, ftos(dist));
		bprint(#PRINT_HIGH, "/Max:");
			bprint(#PRINT_HIGH, ftos(max));
		bprint(#PRINT_HIGH, ")\n");
		self.has_sentry = 10;
	} else {
		self.has_sentry = self.has_sentry - 1;
		if (self.has_sentry <= 0)
			self.has_sentry = 0;
	}
	if (self.owner.cheat_level >= 1800) { //bye....
		self.owner.cheat_level = 0; //WK Clear so we don't boot twice
		self.think = Kick_My_Owner;
		self.nextthink = time + 0.1;
	}
#ifdef SHOW_CHEAT_LEVELS
	local string st;
	st = ftos(max);
	bprint(#PRINT_HIGH, "Max: ");
	bprint(#PRINT_HIGH, st);
	bprint(#PRINT_HIGH, " Imm: ");
	st = ftos(immune);
	bprint(#PRINT_HIGH, st);
	bprint(#PRINT_HIGH, " Cht: ");
	st = ftos(self.owner.cheat_level);
	bprint(#PRINT_HIGH, st);
	bprint(#PRINT_HIGH, " Speed: (");
	st = ftos(dist);
	bprint(#PRINT_HIGH, st);
	bprint(#PRINT_HIGH, "/");
	st = ftos(max * (1 + (#MAXPERCENT / 100))); 
	bprint(#PRINT_HIGH, st);
	bprint(#PRINT_HIGH, ")\n");
#endif
	self.oldorigin = self.owner.origin;
	self.nextthink = time + 1;
};
//This checks so that the impulse cmds were not by accident
//One, must be called before two, and two before three
void() I_DID_CHEAT_ONE =
{
//	bprint(#PRINT_HIGH, "I did the cheat 1 cmd!\n");
	if (self.has_cheated == 0)
		self.has_cheated = 1;
};
void() I_DID_CHEAT_TWO =
{
//	bprint(#PRINT_HIGH, "I did the cheat 2 cmd!\n");
	if (self.has_cheated >= 1) {
		self.has_cheated = 2;

	} else {
		self.has_cheated = 0;
	}
};
void() I_DID_CHEAT_THREE =
{
//	bprint(#PRINT_HIGH, "I did the cheat 3 cmd!\n");
	if (self.has_cheated == 2) {
		//bprint(#PRINT_HIGH, "Making kick entity!\n");
		local entity te;

		te = spawn(); //CH
		te.nextthink = time + (random() * 5) + 5; //5-10 seconds
		self.cheat_level = 0; //WK Clear so we don't boot twice
		self.has_cheated = 0;
		te.think = Kick_My_Owner;
		te.owner = self;
		te.classname = "kicktimer";
	} else {
		self.has_cheated = 0;
	}
};



