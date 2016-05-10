class RscText;
class RscListNBox;

class RscDisplayALiVEPATROLREP
{
	idd = 90002;
	movingEnable = 1;
	onLoad = "[_this] call ALiVE_fnc_patrolrepOnLoad";
	onUnload = "";
	class controlsBackground
	{
 		class patrolrep_Background : RscPicture
        {
                idc = -1;
                x = 0.142424 * safezoneW + safezoneX;
                y = 0.0632 * safezoneH + safezoneY;
                w = 0.73 * safezoneW;
                h = 0.84 * safezoneH;
                text = "x\alive\addons\sup_combatsupport\scripts\NEO_radio\hpp\ALIVE_toughbook_2.paa";
                moving = 1;
                colorBackground[] = {0,0,0,0};
        };
    };
	class controls
	{
        class patrolrep_Map: patrolrep_RscMap
		{
			idc = 1;
			x = 0.586496 * safezoneW + safezoneX;
			y = 0.158313 * safezoneH + safezoneY;
			w = 0.159796 * safezoneW;
			h = 0.308024 * safezoneH;
		};
		class patrolrep_MainTitle: patrolrep_RscText
		{
			idc = 2;
			text = "PATROL REPORT (PATROLREP)"; //--- ToDo: Localize;
			x = 0.263812 * safezoneW + safezoneX;
			y = 0.162713 * safezoneH + safezoneY;
			w = 0.159596 * safezoneW;
		};
		class patrolrep_Abort: patrolrep_RscButton
		{
			idc = 3;
			style = 2;
			action = "deleteMarkerLocal ALIVE_SYS_patrolrep_mapStartMarker; deleteMarkerLocal ALIVE_SYS_patrolrep_mapEndMarker; closeDialog 0";
			text = "CANCEL"; //--- ToDo: Localize;
			x = 0.586496 * safezoneW + safezoneX;
			y = 0.742019 * safezoneH + safezoneY;
			w = 0.159796 * safezoneW;
			h = 0.0220017 * safezoneH;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
			sizeEx = 0.8 * GUI_GRID_H * GUI_GRID_H * GUI_GRID_H;
		};
		class patrolrep_sendButton: patrolrep_RscButton
		{
			idc = 4;
			style = 2;
			text = "SEND PATROLREP"; //--- ToDo: Localize;
			x = 0.586496 * safezoneW + safezoneX;
			y = 0.714815 * safezoneH + safezoneY;
			w = 0.159796 * safezoneW;
			h = 0.0220017 * safezoneH;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
			sizeEx = 0.8 * GUI_GRID_H * GUI_GRID_H * GUI_GRID_H;
			action = "call ALiVE_fnc_patrolrepButtonAction";
		};
		class patrolrep_DTGTEXT: patrolrep_RscText_Right
		{
			style = 1;
			idc = 1004;

			text = "DTG:"; //--- ToDo: Localize;
			x = 0.437834 * safezoneW + safezoneX;
			y = 0.162713 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_DTGVALUE: RscText
		{
			idc = 5;
			sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			style = 1;
			x = 0.5 * safezoneW + safezoneX;
			y = 0.162713 * safezoneH + safezoneY;
			w = 0.070421 * safezoneW;
		    class Attributes
		    {
		        font = "PuristaMedium";
		        color = "#627057";
		        valign = "top";
		        shadow = true;
		        shadowColor = "#000000";
		    };
		};
		class patrolrep_TextCallsign: patrolrep_RscText
		{
			idc = 6;

			text = "CALLSIGN:"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.225979 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_ValueCallsign: patrolrep_RscEdit
		{
			idc = 7;

			x = 0.345668 * safezoneW + safezoneX;
			y = 0.225979 * safezoneH + safezoneY;
			w = 0.154641 * safezoneW;
		};
		class patrolrep_SDATEText: patrolrep_RscText
		{
			idc = 8;

			text = "START TIME:"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.258982 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_SDATEVALUE: patrolrep_RscEdit
		{
			idc = 9;

			x = 0.345668 * safezoneW + safezoneX;
			y = 0.258982 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_SLOCTEXT: patrolrep_RscText_Right
		{
			idc = 10;
			style = 1;

			text = "START GRID:"; //--- ToDo: Localize;
			x = 0.427834 * safezoneW + safezoneX;
			y = 0.258982 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_SLOCVALUE: patrolrep_RscEdit
		{
			idc = 11;

			x = 0.50 * safezoneW + safezoneX;
			y = 0.258982 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_EDATEText: patrolrep_RscText
		{
			idc = 40;

			text = "END TIME:"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.291984 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_EDATEVALUE: patrolrep_RscEdit
		{
			idc = 41;

			x = 0.345668 * safezoneW + safezoneX;
			y = 0.291984 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_ELOCTEXT: patrolrep_RscText_Right
		{
			idc = 12;
			text = "END GRID:"; //--- ToDo: Localize;
			x = 0.427834 * safezoneW + safezoneX;
			y = 0.291984 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
		};
		class patrolrep_ELOCVALUE: patrolrep_RscEdit
		{
			idc = 13;

			x = 0.50 * safezoneW + safezoneX;
			y = 0.291984 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
			h = 0.0176014 * safezoneH;
		};
		class PATCOMP_TEXT: patrolrep_RscText
		{
			idc = 14;

			text = "PATROL COMPOSITION:"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.35799 * safezoneH + safezoneY;
			w = 0.2 * safezoneW;
		};

		class TASK_TEXT: patrolrep_RscText
		{
			idc = 18;
			text = "TASK SUMMARY:"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.324987 * safezoneH + safezoneY;
			w = 0.088 * safezoneW;
		};
		class SPOT_TEXT: patrolrep_RscText
		{
			idc = 20;

			text = "SPOTREPS:"; //--- ToDo: Localize;
			x = 0.49 * safezoneW + safezoneX;
			y = 0.467998 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;

		};
		class SIT_TEXT: patrolrep_RscText
		{
			idc = 22;

			text = "SITREPS:"; //--- ToDo: Localize;
			x = 0.49 * safezoneW + safezoneX;
			y = 0.35799 * safezoneH + safezoneY;
			w = 0.0780421 * safezoneW;

		};
		class ENBDA_TEXT: patrolrep_RscText
		{
			idc = 24;

			text = "ENEMY/BDA:"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.467998 * safezoneH + safezoneY;
			w = 0.138318 * safezoneW;
		};
		class SIT_VALUE: patrolrep_RscGUIListBox_multi
		{
			idc = 23;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
			x = 0.49 * safezoneW + safezoneX;
			y = 0.38 * safezoneH + safezoneY;
			w = 0.0780421 * safezoneW;
			h = 0.087829 * safezoneH;
		};
		class SPOT_VALUE: patrolrep_RscGUIListBox_multi
		{
			idc = 21;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
			x = 0.49 * safezoneW + safezoneX;
			y = 0.49 * safezoneH + safezoneY;
			w = 0.0780421 * safezoneW;
			h = 0.087829 * safezoneH;
		};
		class patrolrep_PATCOMPVALUE: patrolrep_RscEdit
		{
			idc = 15;

			x = 0.283812 * safezoneW + safezoneX;
			y = 0.38 * safezoneH + safezoneY;
			w = 0.2 * safezoneW;
			h = 0.087829 * safezoneH;
		};
		class patrolrep_ENBDAVALUE: patrolrep_RscEdit
		{
			idc = 27;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.49 * safezoneH + safezoneY;
			w = 0.2* safezoneW;
			h = 0.087829 * safezoneH;
		};
		class patrolrep_RESULTSTEXT: patrolrep_RscText
		{
			idc = 32;
			text = "RESULTS:"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.578007 * safezoneH + safezoneY;
			w = 0.270421 * safezoneW;
			h = 0.0176014 * safezoneH;
		};
		class patrolrep_TASKVALUE: patrolrep_RscEdit
		{
			idc = 19;

			x = 0.365668 * safezoneW + safezoneX;
			y = 0.324987 * safezoneH + safezoneY;
			w = 0.2 * safezoneW;
			h = 0.0176014 * safezoneH;
		};
		class patrolrep_RESULTSVALUE: patrolrep_RscEdit
		{
			idc = 33;

			text = "DO NOT USE QUOTE MARKS IN TEXT BOXES"; //--- ToDo: Localize;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.6 * safezoneH + safezoneY;
			w = 0.28826 * safezoneW;
			h = 0.127829 * safezoneH;
		};
		class patrolrep_AMMOTEXT: patrolrep_RscText_Right
		{
			idc = 30;
			style = 1;

			text = "AMMO:"; //--- ToDo: Localize;
			x = 0.583011 * safezoneW + safezoneX;
			y = 0.477998 * safezoneH + safezoneY;
			w = 0.0637606 * safezoneW;

		};
		class patrolrep_CASTEXT: patrolrep_RscText_Right
		{
			idc = 28;
			style = 1;

			text = "CASUALTIES:"; //--- ToDo: Localize;
			x = 0.583011 * safezoneW + safezoneX;
			y = 0.511001 * safezoneH + safezoneY;
			w = 0.0637606 * safezoneW;

		};
		class patrolrep_AMMOLIST: patrolrep_RscComboBox
		{
			idc = 31;
			x = 0.644022 * safezoneW + safezoneX;
			y = 0.477998 * safezoneH + safezoneY;
			w = 0.10002 * safezoneW;
			h = 0.0203195 * safezoneH;
		};
		class patrolrep_CASLIST: patrolrep_RscComboBox
		{
			idc = 29;
			x = 0.644022 * safezoneW + safezoneX;
			y = 0.511001 * safezoneH + safezoneY;
			w = 0.10002 * safezoneW;
			h = 0.0203195 * safezoneH;
		};
		class patrolrep_VEHTEXT: patrolrep_RscText_Right
		{
			idc = 36;
			style = 1;

			text = "VEHICLES:"; //--- ToDo: Localize;
			x = 0.563011 * safezoneW + safezoneX;
			y = 0.544004 * safezoneH + safezoneY;
			w = 0.0837606 * safezoneW;

		};
		class patrolrep_VEHLIST: patrolrep_RscComboBox
		{
			idc = 37;
			x = 0.644022 * safezoneW + safezoneX;
			y = 0.544004 * safezoneH + safezoneY;
			w = 0.10002 * safezoneW;
			h = 0.0203195 * safezoneH;
		};
		class patrolrep_CSTEXT: patrolrep_RscText_Right
		{
			idc = 38;
			style = 1;

			text = "COMBAT SPT:"; //--- ToDo: Localize;
			x = 0.563011 * safezoneW + safezoneX;
			y = 0.577007 * safezoneH + safezoneY;
			w = 0.0837606 * safezoneW;

		};
		class patrolrep_CSLIST: patrolrep_RscComboBox
		{
			idc = 39;
			x = 0.644022 * safezoneW + safezoneX;
			y = 0.577007 * safezoneH + safezoneY;
			w = 0.10002 * safezoneW;
			h = 0.0203195 * safezoneH;
		};
		class ALIVE_EYESTEXT: patrolrep_RscText_Right
		{
			idc = 34;
			text = "EYES ONLY:"; //--- ToDo: Localize;
			style = 1;
			x = 0.283812 * safezoneW + safezoneX;
			y = 0.742019 * safezoneH + safezoneY;
			w = 0.0680421 * safezoneW;
			h = 0.0176014 * safezoneH;
		};
		class ALIVE_EYESVALUE: patrolrep_RscComboBox
		{
			idc = 35;
			x = 0.353812 * safezoneW + safezoneX;
			y = 0.742019 * safezoneH + safezoneY;
			w = 0.184641 * safezoneW;
			h = 0.0203195 * safezoneH;
		};
	};
};


