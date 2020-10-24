void () BadTinker = {
	local float prob;
	prob = random();
		if (prob <= 0.6){ // Zilch
		sprint(self,#PRINT_HIGH,"Nothing happened.\n");
	}
		else if (prob <= 0.8){ // Zowie!
		TF_T_Damage(self.building, world, world, self.building.health+1, 0, 0);
		sprint(self,#PRINT_HIGH,"The tesla blew up.\n");
	}
		else { // ZAP!
		self.building.tf_items = self.building.tf_items | #NIT_SECURITY_CAMERA; //Turns tesla against team.
		self.building.health = 100; //WK Make it easy to kill
		self.building.max_health = 100;
		sprint(self,#PRINT_HIGH,"You cut the wrong wire!\n");
	}
};

void () DoTinker = {
		local float prob, thresh, enough;
		//local entity te;

		if (self.building.has_sentry > 0) {
			sprint(self,#PRINT_HIGH,"You have to fully upgrade before tinkering\n");
			return;
		}

		if (self.ammo_cells < 100) {//not enough cells
			sprint(self,#PRINT_HIGH,"You need more cells to tinker on the tesla\n");
		}
		else {
			self.ammo_cells = self.ammo_cells - 100;

		self.building.lip = self.building.lip + 1; // Increment Tinker Count

		// Decide probability of bad tinker
		// 1st time 25%
		// 2nd and 3rd time 50%
		// 4th up 75%

		if (self.building.lip == 1)
						thresh = 0.25;
		else if (self.building.lip <= 3)
						thresh = 0.5;
		else
						thresh = 0.75;

		if (random() <= thresh){ // Uh Oh!
			BadTinker();
			return;
		}

		if ((self.building.ammo_shells + self.building.ammo_nails + self.building.ammo_rockets) >= 7)
			enough = #TRUE;
		// Ok, good tinker.
		prob = random();
		if (prob <= 0.2){ // Zilch, yet again.
			sprint(self,#PRINT_HIGH,"Nothing happened.\n");
		}
		else if (prob <= 0.35){
						if (!(self.building.tf_items & #NIT_SCANNER)){
				self.building.tf_items = (self.building.tf_items | #NIT_SCANNER);
				sprint(self,#PRINT_HIGH,"The tesla gets a free improved targeter!\n");
						}
			else{
				Tesla_Add_Rand_Upgrade(self.building, self);
			}
		}
		else if (prob <= 0.4){
			if (!(self.building.tf_items & #NIT_AUTOID)){
				self.building.tf_items = (self.building.tf_items | #NIT_AUTOID);
				sprint(self,#PRINT_HIGH,"The tesla got a free spy detector!\n");
			}
			else{
				Tesla_Add_Rand_Upgrade(self.building, self);
			}
		}
		else if (prob <= 0.7 && !enough){
			Tesla_Add_Rand_Upgrade(self.building, self);
		}
		else if (prob <= 0.9){
			self.building.max_health = self.building.max_health + 100;	
			self.building.health = self.building.health + 100;
			sprint(self,#PRINT_HIGH,"The tesla got more health.\n");
		}
		else if (prob <= 1){
			self.building.maxammo_cells = self.building.maxammo_cells + 100;	
			self.building.ammo_cells = self.building.ammo_cells + 100;
			sprint(self,#PRINT_HIGH,"The tesla got more cells.\n");
		}
		}
};
