/*=======================================================//
// MegaTF.QC - CustomTF 3.2.OfN 		   - 21/1/2004 - //
// by Sergio Fumaña Grunwaldt - OfteN [cp]				 //
=========================================================//
 Code related to MegaTF mimetized behaviours is here.
 With the exception of map entities, that have their own
 file: 'mtfents.qc'
=========================================================*/

#define MEGATF_DEFAULT_MODE #MEGATF_MAPENTS | #MEGATF_SIGHTS

//==============================================================
// Conditionally precaches needed stuff for current megatf mode

void () MegaTF_Precaches =
{
/* WK Get rid of this, it's unused
	if (megatf & #MEGATF_STEPS)
	{
		precache_sound("player/step1l.wav");
		precache_sound("player/step1r.wav");
		precache_sound("player/step2l.wav");
		precache_sound("player/step2r.wav");
	}
*/

	if (megatf & #MEGATF_SIGHTS)
	{
		precache_model2("progs/colsight.spr");
	}
	else // Standard sights
		precache_model2("progs/sight.spr");
	
	/*if (megatf & #MEGATF_DROPS)
	{

	}*/
};

//==============================================================
// Updates MegaTF flags global

void () GetMegaTFflags =
{
	local string st;

	st = infokey(world,"megatf");
	if (st == "")
		megatf = #MEGATF_DEFAULT_MODE;
	else
		megatf = stof(st);	  
};

//===============================================================
// Called only at map startup, initializes megatf stuff

void() InitMegaTF =
{
	GetMegaTFflags();
	MegaTF_Precaches();
};