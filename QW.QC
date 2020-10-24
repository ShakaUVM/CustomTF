// QW CenterPrinting hack
// these functions are only used if in normal quake

#ifndef QUAKE_WORLD

void(float level, string s) bprint =
{
	nqw_bprint(s);
};

void(entity client, float level, string s) sprint =
{
	nqw_sprint(client, s);
};

void(float level, string s1, string s2) bprint2 =
{				
	nqw_bprint(s1, s2);
};

void(entity client, float level, string s1, string s2) sprint2 =
{
	nqw_sprint(client, s1, s2);
};


void(float level, string s1, string s2, string s3) bprint3 =
{
	nqw_bprint(s1, s2, s3);
};

void(entity client, float level, string s1, string s2, string s3) sprint3 =
{
	nqw_sprint(client, s1, s2, s3);
};


void(float level, string s1, string s2, string s3, string s4) bprint4 =
{
	nqw_bprint(s1, s2, s3, s4);
};

void(entity client, float level, string s1, string s2, string s3, string s4) sprint4 =
{
	nqw_sprint(client, s1, s2, s3, s4);
};


void(float level, string s1, string s2, string s3, string s4, string s5) bprint5 =
{
	nqw_bprint(s1, s2, s3, s4, s5);
};

void(entity client, float level, string s1, string s2, string s3, string s4, string s5) sprint5 =
{
	nqw_sprint(client, s1, s2, s3, s4, s5);
};


void(float level, string s1, string s2, string s3, string s4, string s5, string s6) bprint6 =
{
	nqw_bprint(s1, s2, s3, s4, s5, s6);
};

void(entity client, float level, string s1, string s2, string s3, string s4, string s5, string s6) sprint6 =
{
	nqw_sprint(client, s1, s2, s3, s4, s5, s6);
};


void(float level, string s1, string s2, string s3, string s4, string s5, string s6, string s7) bprint7 =
{
	nqw_bprint(s1, s2, s3, s4, s5, s6, s7);
};

// these functions won't compile
/*
void(entity client, float level, string s1, string s2, string s3, string s4, string s5, string s6, string s7) sprint7 =
{
	nqw_sprint(client, s1, s2, s3, s4, s5, s6, s7);
};

void(float level, string s1, string s2, string s3, string s4, string s5, string s6, string s7, string s8) bprint8 =
{
	nqw_bprint(s1, s2, s3, s4, s5, s6, s7, s8);
};
*/
#endif

// replaces punchangle in QW
void(float psize, entity p) KickPlayer =
{
#ifndef QUAKE_WORLD
	self.punchangle_x = psize;
#else
	msg_entity = p;
	if (psize > -3)
		WriteByte (#MSG_ONE, #SVC_SMALLKICK);
	else // (size < -3)
		WriteByte (#MSG_ONE, #SVC_BIGKICK);
#endif
};

void() muzzleflash =
{
#ifdef QUAKE_WORLD
	WriteByte (#MSG_MULTICAST, #SVC_MUZZLEFLASH);
	WriteEntity (#MSG_MULTICAST, self);
	multicast (self.origin, #MULTICAST_PVS);
#else
	self.effects = self.effects | #EF_MUZZLEFLASH;
#endif
};
