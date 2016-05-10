if !(isServer) exitWith {};

clearMagazineCargoGlobal _this;
clearWeaponCargoGlobal _this;
clearItemCargoGlobal _this;

{_this addItemcargoGlobal [_x,10]} foreach  ["U_B_Wetsuit","V_RebreatherB"];
_this addBackpackCargoGlobal ["B_FieldPack_blk_DiverExp",10];

{
	_backpack = _x;
	if (typeof _backpack == "B_FieldPack_blk_DiverExp") then {
		clearMagazineCargoGlobal _backpack;
		clearItemCargoGlobal _backpack;

		_backpack additemCargoGlobal ["U_B_CombatUniform_mcam_vest",1];
		_backpack additemCargoGlobal ["V_PlateCarrier2_rgr",1];
		_backpack additemCargoGlobal ["H_Booniehat_mcamo",1];
		_backpack additemCargoGlobal ["LaserDesignator",1];
		_backpack additemCargoGlobal ["NVgoggles",1];
		_backpack addItemcargoGlobal ["G_B_Diving",1];
	
		_backpack addweaponCargoGlobal ["srifle_EBR_DMS_pointer_snds_F",1];
		_backpack addweaponCargoGlobal ["hgun_P07_snds_F",1];
	
		_backpack addmagazineCargoGlobal ["20Rnd_762x51_Mag",6];
		_backpack addmagazineCargoGlobal ["30rnd_9x21_mag",2];
		_backpack addmagazineCargoGlobal ["Laserbatteries",1];
		_backpack addmagazineCargoGlobal ["SatchelCharge_Remote_Mag",1];
	};
} foreach (everyBackpack _this);