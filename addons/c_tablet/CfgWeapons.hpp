class CfgWeapons {
	class ItemCore;
	class InventoryItem_Base_F;
	class TabletItem: InventoryItem_Base_F
	{
		type = 620;
	};
	class ALIVE_Tablet: ItemCore
	{
		scope = 2;
		scopeArsenal=2;
		displayName = "$STR_ALIVE_Tablet";
		picture = "\x\alive\addons\m_tablet\data\UI\gear_tablet_CA.paa";
		model = "\x\alive\addons\m_tablet\Tablet";
		descriptionShort = "$STR_ALIVE_Tablet1";
		class ItemInfo: TabletItem
		{
			mass = 8;
		};
	};
};