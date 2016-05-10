#include <script_component.hpp>
#include <CfgPatches.hpp>
#include "CfgFunctions.hpp"
#include "c_ui.hpp"

// ALiVE Main UI
class Extended_PreInit_EventHandlers
{
	class alive_ui
	{
		clientInit = "call compile preProcessFileLineNumbers '\x\alive\addons\ui\XEH_preClientInit.sqf'";
	};
};
class RscText;
class RscShortcutButton;
//-------------------------------------
class _flexiMenu_RscShortcutButton: RscShortcutButton
{
	class HitZone
	{
		left = 0.002;
		top = 0.003;
		right = 0.002;
		bottom = 0.003; //0.016;
	};
	class ShortcutPos
	{
		left = -0.006;
		top = -0.007;
		w = 0.0392157;
		h = 2*(safeZoneH/36); //0.0522876;
	};
	class TextPos
	{
		left = 0.01; // indent
		top = 0.002;
		right = 0.01;
		bottom = 0.002; //0.016;
	};
};
//-----------------------------------------------------------------------------
#include "flexiMenu\data\menu_popup.hpp"

class RscStandardDisplay;
class RscPicture;
class RscPictureKeepAspect;
class RscStructuredText;
class RscControlsGroup;
class RscControlsGroupNoScrollbars;
class RscButtonMenu;
class RscButtonMenuCancel;
class RscTitle;
class RscDebugConsole;
class RscScrollBar;

class cfgScriptPaths
{
	alive = "\x\alive\addons\UI\";
};

class Extended_DisplayLoad_Eventhandlers 
{
	class RscDisplayLoading 
	{
		GVAR(onload) = QUOTE([(_this select 0)] call COMPILE_FILE(fnc_rscDisplayLoadingALiVE));
	};
	class RscDisplayMPInterrupt 
	{
		GVAR(onload) = QUOTE([(_this select 0)] call COMPILE_FILE(fnc_rscDisplayMPInterruptALiVE));
	};
};

class RscDisplayLoadMission: RscStandardDisplay
{
	class controls
	{
		class ALIVE_Logo: RscPictureKeepAspect
		{
			idc = 1202;
			text = "\x\alive\addons\UI\logo_alive.paa";
			x = 0.01 * safezoneW + safezoneX;
			y = 0.8 * safezoneH + safezoneY;
			w = 0.154687 * safezoneW;
			h = 0.143 * safezoneH;
			colorText[] = {1,1,1,0.5};
		};
	};
};

class RscBackgroundLogo: RscPictureKeepAspect
{
//	text = "\x\alive\addons\UI\logo_alive.paa";
	align = "top";
	background = 1;
	x = "safezoneX + safezoneW - (9 * 			(		((safezoneW / safezoneH) min 1.2) / 32))";
	y = "safezoneY - 2 * 			(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20)";
	w = "(8 * 			(		((safezoneW / safezoneH) min 1.2) / 32))";
	h = "(8 * 			(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20))";
};

class RscDisplayMain: RscStandardDisplay
{
	class controls
	{
		class ALiVEGameLogo: RscPicture
		{
			idc = 1202;
			text = "\x\alive\addons\UI\logo_alive_white.paa";
			tooltip = "$STR_ALIVE_UI_TOOLTIP_LOGO_ABOUT";
			x = "safezoneX + safezoneW - 5.2 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			y = "21 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 			(safezoneY + safezoneH - 			(			((safezoneW / safezoneH) min 1.2) / 1.2))";
			w = "3 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";			
			h = "1.5 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";	
		};
	};
};

class RscDisplayMPInterrupt: RscStandardDisplay
{
	class controls
	{
		delete ButtonAbort;
		class ALiVETitle: RscTitle
		{
			idc = 599;
			style = 0;
			text = "ALiVE Menu";
			x = "1 * 			(((safezoneW / safezoneH) min 1.2) /40) + safezoneX + (16 * (((safezoneW / safezoneH) min 1.2) /40))";
			y = "17.5 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 			(safezoneY + safezoneH - 			(			((safezoneW / safezoneH) min 1.2) / 1.2))";
			w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			colorBackground[] = {0.69,0.75,0.5,0.8};
		};
		class ALiVEButtonServerSave: RscButtonMenu
		{
			idc = 195;
			text = "SERVER SAVE AND EXIT (Admin Only)";
			x = "1 * 			(((safezoneW / safezoneH) min 1.2) /40) + safezoneX + (16 * (((safezoneW / safezoneH) min 1.2) /40))";
			y = "18.6 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 			(safezoneY + safezoneH - 			(			((safezoneW / safezoneH) min 1.2) / 1.2))";
			w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};		
		class ALiVEButtonServerAbort: RscButtonMenu
		{
			idc = 196;
			text = "SERVER EXIT (Admin Only)";
			x = "1 * 			(((safezoneW / safezoneH) min 1.2) /40) + safezoneX + (16 * (((safezoneW / safezoneH) min 1.2) /40))";
			y = "19.7 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 			(safezoneY + safezoneH - 			(			((safezoneW / safezoneH) min 1.2) / 1.2))";
			w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};
		class ALiVEButtonSave: RscButtonMenu
		{
			idc = 198;
			text = "PLAYER EXIT";
			x = "1 * 			(((safezoneW / safezoneH) min 1.2) /40) + safezoneX + (16 * (((safezoneW / safezoneH) min 1.2) /40))";
			y = "20.8 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 			(safezoneY + safezoneH - 			(			((safezoneW / safezoneH) min 1.2) / 1.2))";
			w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			action = "['SAVE'] call alive_fnc_buttonAbort";
		};
		class ALIVEButtonAbort: RscButtonMenu
		{
			idc = 199;
			text = "$STR_DISP_INT_ABORT";
			x = "1 * 			(			((safezoneW / safezoneH) min 1.2) / 40) + 			(safezoneX)";
			y = "20.8 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 			(safezoneY + safezoneH - 			(			((safezoneW / safezoneH) min 1.2) / 1.2))";
			w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			action = "['ABORT'] call alive_fnc_buttonAbort";
		};
		class DebugConsole: RscDebugConsole
		{
			x = "33 * 			(			((safezoneW / safezoneH) min 1.2) / 40) + 			(safezoneX)";
		};
	};
};

class CfgDebriefing
{  
	class Saved
	{
		title = "Player Progress Saved";
		subtitle = "";
		description = "You have saved your mission progress.";
		pictureBackground = "";
		picture = "b_inf";
		pictureColor[] = {0.0,0.3,0.6,1};
	};
	class Abort
	{
		title = "Mission Exit";
		subtitle = "";
		description = "You have quit from the current running mission";
		pictureBackground = "";
		picture = "b_inf";
		pictureColor[] = {0.0,0.3,0.6,1};
	};
	class ServerSaved
	{
		title = "Mission Progress Saved";
		subtitle = "";
		description = "You have saved the mission, mission will now exit.";
		pictureBackground = "";
		picture = "b_hq";
		pictureColor[] = {0.0,0.3,0.6,1};
	};
	class ServerAbort
	{
		title = "Mission Exit";
		subtitle = "";
		description = "The Mission will now exit.";
		pictureBackground = "";
		picture = "b_hq";
		pictureColor[] = {0.0,0.3,0.6,1};
	};
};

#include <\x\alive\addons\ui\menu\data\menu_common.hpp>
#include <\x\alive\addons\ui\menu\data\menu_full.hpp>
#include <\x\alive\addons\ui\menu\data\menu_full_image.hpp>
#include <\x\alive\addons\ui\menu\data\menu_full_map.hpp>
#include <\x\alive\addons\ui\menu\data\menu_modal.hpp>
#include <\x\alive\addons\ui\menu\data\menu_wide.hpp>

class RscTitles {
    #include <\x\alive\addons\ui\menu\data\splash.hpp>
    #include <\x\alive\addons\ui\menu\data\menu_side.hpp>
    #include <\x\alive\addons\ui\menu\data\menu_side_small.hpp>
    #include <\x\alive\addons\ui\menu\data\menu_side_top.hpp>
    #include <\x\alive\addons\ui\menu\data\menu_side_top_small.hpp>
    #include <\x\alive\addons\ui\menu\data\menu_side_full.hpp>
    #include <\x\alive\addons\ui\menu\data\subtitle_side_small.hpp>
};

class RscEdit;
class RscFrame;
class RscButtonMenuOK;	

class ALIVE_ui_setNumberValue {
	idd = 80602;
	movingEnable = true;
	enableSimulation = true; 
	onLoad = "((_this select 0) displayCtrl 1000) ctrlSetText ((uiNamespace getVariable 'ALIVE_UI_SETVALUE_PARAMS') select 2); ((_this select 0) displayCtrl 1400) ctrlSetText (str(((uiNamespace getVariable 'ALIVE_UI_SETVALUE_PARAMS') select 0) getVariable ((uiNamespace getVariable 'ALIVE_UI_SETVALUE_PARAMS') select 1))); ((_this select 0) displayCtrl 1400) ctrlSetTooltip ((uiNamespace getVariable 'ALIVE_UI_SETVALUE_PARAMS') select 3)";

	class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Matt, v1.063, #Jypymu)
		////////////////////////////////////////////////////////

		class setValue_EditBox: RscEdit
		{
			idc = 1400;
			text = "0"; //--- ToDo: Localize;
			x = 0.448421 * safezoneW + safezoneX;
			y = 0.456003 * safezoneH + safezoneY;
			w = 0.118631 * safezoneW;
			h = 0.0329974 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorText[] = {0.9,0.7,0.1,0.8};			
			tooltip = "Enter a numerical value."; //--- ToDo: Localize;
		};

		class setValue_Frame: RscFrame
		{
			idc = 1800;
			x = 0.442737 * safezoneW + safezoneX;
			y = 0.423966 * safezoneH + safezoneY;
			w = 0.128947 * safezoneW;
			h = 0.0989922 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
		};
		
		class setValue_RscButtonMenuOK_2600: RscButtonMenuOK
		{
			idc = 1401;
			x = 0.535579 * safezoneW + safezoneX;
			y = 0.493799 * safezoneH + safezoneY;
			w = 0.0309473 * safezoneW;
			h = 0.0219983 * safezoneH;
			action = "((uiNamespace getVariable 'ALIVE_UI_SETVALUE_PARAMS') select 0) setvariable [((uiNamespace getVariable 'ALIVE_UI_SETVALUE_PARAMS') select 1), parseNumber (ctrlText 1400), true]; closeDialog 0";
		};
		
		class setValue_RscButtonMenuCancel_2700: RscButtonMenuCancel
		{
			x = 0.449999 * safezoneW + safezoneX;
			y = 0.493799 * safezoneH + safezoneY;
			w = 0.0412631 * safezoneW;
			h = 0.0219983 * safezoneH;
			action = "closeDialog 0;";
		};

		class setValue_Header: RscText
		{
			idc = 1000;
			text = "Set Value";
			x = 0.448421 * safezoneW + safezoneX;
			y = 0.431126 * safezoneH + safezoneY;
			w = 0.118631 * safezoneW;
			h = 0.0219983 * safezoneH;
			colorText[] = {0.9,0.7,0.1,0.8};
			colorBackground[] = {0.1,0.1,0.1,0.9};
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////

	};
};