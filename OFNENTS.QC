/*=======================================================//
// ofnents.QC - CustomTF 3.2.OfN		   - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN [cp]				 //
=========================================================//
 Additional map entities along with their spawn functions
=========================================================*/

void() model_solid =
{
	if (self.mdl != "")
		precache_model(self.mdl);
	
	self.movetype = #MOVETYPE_NONE;
	self.solid = #SOLID_BBOX;
	
	setmodel (self, self.mdl);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);
};

void() model_nonsolid =
{
	if (self.mdl != "")
		precache_model(self.mdl);
	
	self.movetype = #MOVETYPE_NONE;
	self.solid = #SOLID_NOT;
	
	setmodel (self, self.mdl);
	setorigin(self, self.origin);

	if (self.option != 0) return;

	makestatic (self); //CRASH This used to have no args. Possible?
};

void(void() touch_function) InitOfNTrigger =
{
	InitTrigger();

	self.touch = touch_function;
	
	if (self.noise != "")
	{
		precache_sound(self.noise);

		if (!self.volume)
			self.volume = 1;
	}
};

void(entity targetplayer) TriggerNotifyAndEffects =
{
	if (self.message != "")
		sprint(targetplayer,#PRINT_HIGH,self.message);

	if (self.noise != "")
		sound(targetplayer,#CHAN_AUTO,self.noise,self.volume,#ATTN_NORM);
};

float(entity ent, float bastards) PlayerCanTrigger =
{
	if (ent.classname != "player") 
		return #FALSE;
	if (!ent.is_connected)
		return #FALSE;
	if (ent.health <= 0) // alive?
		return #FALSE;
	if (ent.done_custom & #CUSTOM_BUILDING) // ppl customizing
		return #FALSE;
	if (ent.playerclass == #PC_UNDEFINED) // observers
		return #FALSE;

	if (!bastards)
	if (other.penance_time > time)
		return #FALSE;

	return #TRUE;
};

void() trigger_gravity_touch =
{
	if (!PlayerCanTrigger(other,#TRUE)) return;

	if (other.gravity != self.gravity)
	{
		TriggerNotifyAndEffects(other);
		other.gravity = self.gravity;
	}
};

void() trigger_gravity =
{
	InitOfNTrigger(trigger_gravity_touch);
};

void() trigger_alter_equip_touch =
{
	if (!PlayerCanTrigger(other,#FALSE)) return;

	local float itemid, counter, all;
	local entity oself;
	
	all = 0;
	counter = 0;

	if (self.#givenstuff1 | self.#givenstuff2 | self.#givenstuff3 | self.#givenstuff4 | self.#givenstuff5)
	{	
		if (self.#givenstuff1 && ((self.#givenstuff1 & other.#givenstuff1)!=self.#givenstuff1))
		{
			itemid = 1;

			while (itemid < 22)
			{
				if (self.#givenstuff1 & itob(itemid))
				if (GiveSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}		 

		if (self.#givenstuff2 && ((self.#givenstuff2 & other.#givenstuff2)!=self.#givenstuff2))
		{
			itemid = 25;

			while (itemid < 22 + 24)
			{
				if (self.#givenstuff2 & itob(itemid - 24))
				if (GiveSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (self.#givenstuff3 && ((self.#givenstuff3 & other.#givenstuff3)!=self.#givenstuff3))
		{
			itemid = 25+24;

			while (itemid < 22 + 24 + 24)
			{
				if (self.#givenstuff3 & itob(itemid - (24+24)))
				if (GiveSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (self.#givenstuff4 && ((self.#givenstuff4 & other.#givenstuff4)!=self.#givenstuff4))
		{
			itemid = 25+24+24;
			
			while (itemid < 22 + 24 + 24 + 24)
			{
				if (self.#givenstuff4 & itob(itemid - (24+24+24)))
				if (GiveSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (self.#givenstuff5 && ((self.#givenstuff5 & other.#givenstuff5)!=self.#givenstuff5))
		{
			itemid = 25+24+24+24;
			
			while (itemid < 22 + 24 + 24 + 24 + 24)
			{
				if (self.#givenstuff5 & itob(itemid - (24+24+24+24)))
				if (GiveSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (counter)
		{
			oself = self;
			self = other;
			UpdateWeaponItems();
			self = oself;
		}
	}
	
	if (self.#disabledstuff1 | self.#disabledstuff2 | self.#disabledstuff3 | self.#disabledstuff4 | self.#disabledstuff5)
	{
		all = counter;		  
		counter = 0;
		
		if (self.#disabledstuff1 && ((self.#disabledstuff1 & other.#disabledstuff1)!=self.#disabledstuff1))
		{
			itemid = 1;

			while (itemid < 22)
			{
				if (self.#disabledstuff1 & itob(itemid))
				if (StripSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (self.#disabledstuff2 && ((self.#disabledstuff2 & other.#disabledstuff2)!=self.#disabledstuff2))
		{
			itemid = 25;
			
			while (itemid < 22 + 24)
			{
				if (self.#disabledstuff2 & itob(itemid - 24))
				if (StripSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (self.#disabledstuff3 && ((self.#disabledstuff3 & other.#disabledstuff3)!=self.#disabledstuff3))
		{
			itemid = 25+24;
			
			while (itemid < 22 + 24 + 24)
			{
				if (self.#disabledstuff3 & itob(itemid - (24+24)))
				if (StripSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}
		
		if (self.#disabledstuff4 && ((self.#disabledstuff4 & other.#disabledstuff4)!=self.#disabledstuff4))
		{
			itemid = 25+24+24;
			
			while (itemid < 22 + 24 + 24 + 24)
			{
				if (self.#disabledstuff4 & itob(itemid - (24+24+24)))
				if (StripSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (self.#disabledstuff5 && ((self.#disabledstuff5 & other.#disabledstuff5)!=self.#disabledstuff5))
		{
			itemid = 25+24+24+24;

			while (itemid < 22 + 24 + 24 + 24 + 24)
			{
				if (self.#disabledstuff5 & itob(itemid - (24+24+24+24)))
				if (StripSpecificItem(other,itemid,#TRUE,#FALSE))
					counter = counter + 1;
				
				itemid = itemid + 1;
			}
		}

		if (counter)
		{
			oself = self;
			self = other;
			self.current_weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
			UpdateWeaponItems();
			self = oself;
		}
	}

	if ((counter + all) > 0)
		TriggerNotifyAndEffects(other);
};

void() trigger_alter_equip =
{	 
	InitOfNTrigger(trigger_alter_equip_touch);
};

void() trigger_restore_equip_touch =
{
	if (!PlayerCanTrigger(other,#FALSE)) return;

	if (RestoreOriginalItems(other))
		TriggerNotifyAndEffects(other);
};

void() trigger_restore_equip =
{
	InitOfNTrigger(trigger_restore_equip_touch);
};

// Spawnflags: 1 NO_BUILDS 2 NO_MONSTERS

void() trigger_special_zone =
{

};