class CfgWeapons
{
	class CBA_MiscItem;
	class CBA_MiscItem_ItemInfo;
	class Throw;
	// Standalone thrower for civilian crowds (stones/cans/bottles). Deliberately NOT an
	// override of the base Throw weapon: appending muzzles to Throw changes the muzzle
	// table of a weapon EVERY unit carries, and when only some machines in an MP session
	// load ALiVE that mismatch silences remote players' weapon sounds and firing
	// animations across the modset boundary (engine behaviour, BI feedback T81181).
	// Crowd agents are given this weapon by crowdActivator.fsm instead.
	class ALiVE_Throw: Throw
	{
		scope = 1;
		muzzles[] = {"ALiVE_Handgrenade_stoneMuzzle","ALiVE_Handgrenade_canMuzzle","ALiVE_Handgrenade_bottleMuzzle"};
		class ThrowMuzzle;
		class ALiVE_Handgrenade_stoneMuzzle: ThrowMuzzle
		{
			displayName = "Stone";
			magazines[] = {"ALiVE_Handgrenade_stone"};
		};
		class ALiVE_Handgrenade_canMuzzle: ThrowMuzzle
		{
			displayName = "Can";
			magazines[] = {"ALiVE_Handgrenade_can"};
		};
		class ALiVE_Handgrenade_bottleMuzzle: ThrowMuzzle
		{
			displayName = "Bottle";
			magazines[] = {"ALiVE_Handgrenade_bottle"};
		};
	};

	class ALiVE_Waterbottle: CBA_MiscItem
	{
		author = "ALiVE Mod";
		scope = 2;
		scopeArsenal = 2;
		scopeCurator = 2;
		displayName = "ALiVE Water Bottle (Full)";
		model = "\A3\Props_F_Orange\Humanitarian\Supplies\WaterBottle_01_full_F.p3d";
		picture = "\x\alive\addons\amb_civ_population\data\ui\WaterBottle.paa";
		icon = "iconObject_circle";
		descriptionShort = "A Bottle of Water that can be given to civilians.";
		class ItemInfo: CBA_MiscItem_ItemInfo
		{
				mass = 5;
		};
	};

	class ALiVE_Humrat: CBA_MiscItem
	{
		author = "ALiVE Mod";
		scope = 2;
		scopeArsenal = 2;
		scopeCurator = 2;
		displayName = "ALiVE Rice Pack";
		model = "\A3\Structures_F_EPA\Items\Food\RiceBox_F.p3d";
		picture = "\x\alive\addons\amb_civ_population\data\ui\RicePack.paa";
		icon = "iconObject_circle";
		descriptionShort = "A Rice Pack that can be given to civilians.";
		class ItemInfo: CBA_MiscItem_ItemInfo
		{
				mass = 6;
		};
	};
};