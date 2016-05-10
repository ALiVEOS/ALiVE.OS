class RscText;
class RscEdit;
class RscFrame;
class RscButtonMenuOK;	
class RscButtonMenuCancel;	

class ALIVE_ui_sys_player_setautoSaveTime {
	idd = 80601;
	movingEnable = 1;
	enableSimulation = 1;

	class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Matt, v1.063, #Jypymu)
		////////////////////////////////////////////////////////

		class autoSaveTime_EditBox: RscEdit
		{
			idc = 1400;
			text = "0"; //--- ToDo: Localize;
			x = 0.448421 * safezoneW + safezoneX;
			y = 0.456003 * safezoneH + safezoneY;
			w = 0.118631 * safezoneW;
			h = 0.0329974 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			tooltip = "Enter a number in seconds. Enter 0 to only save on mission end. Ensure you enter a valid number!"; //--- ToDo: Localize;
		};

		class autoSaveTime_Frame: RscFrame
		{
			idc = 1800;
			x = 0.442737 * safezoneW + safezoneX;
			y = 0.423966 * safezoneH + safezoneY;
			w = 0.128947 * safezoneW;
			h = 0.0989922 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
		};
		
		class autoSaveTime_RscButtonMenuOK_2600: RscButtonMenuOK
		{
			x = 0.535579 * safezoneW + safezoneX;
			y = 0.493799 * safezoneH + safezoneY;
			w = 0.0309473 * safezoneW;
			h = 0.0219983 * safezoneH;
			action = "ALIVE_sys_player setVariable ['autoSaveTime', parseNumber (ctrlText 1400), true];";
		};
		
		class autoSaveTime_RscButtonMenuCancel_2700: RscButtonMenuCancel
		{
			x = 0.449999 * safezoneW + safezoneX;
			y = 0.493799 * safezoneH + safezoneY;
			w = 0.0412631 * safezoneW;
			h = 0.0219983 * safezoneH;
			action = "closeDialog 0;";
		};

		class autoSaveTime_Header: RscText
		{
			idc = 1000;
			text = "Set Auto Save Interval (DB)"; //--- ToDo: Localize;
			x = 0.457159 * safezoneW + safezoneX;
			y = 0.431126 * safezoneH + safezoneY;
			w = 0.0979999 * safezoneW;
			h = 0.0219983 * safezoneH;
			colorText[] = {1,1,1,0.8};
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////

	};
};