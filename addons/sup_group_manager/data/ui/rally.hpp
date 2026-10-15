// The Rally Points window: the other rally points the player may use, and Travel.
// ALiVE_fnc_rallyWindow fills and drives it. Uses the recruitment window's controls (recruit_common.hpp),
// and the game's map control for the map of the picked rally point.

class RscMapControl;

class ALiVE_RallyWindow {
    idd = 9280;
    movingEnable = 1;
    onUnload = "['closed'] call ALiVE_fnc_rallyWindow";

    class controls {
        class RallyUI_Background: RecruitUI_RscText {
            idc = 92800;
            x = 0.32 * safezoneW + safezoneX;
            y = 0.30 * safezoneH + safezoneY;
            w = 0.36 * safezoneW;
            h = 0.36 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class RallyUI_Header: RecruitUI_RscText {
            idc = 92801;
            text = "$STR_ALIVE_RALLY";
            x = 0.32 * safezoneW + safezoneX;
            y = 0.272 * safezoneH + safezoneY;
            w = 0.36 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class RallyUI_List: RecruitUI_RscListBox {
            idc = 92802;
            x = 0.33 * safezoneW + safezoneX;
            y = 0.315 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.33 * safezoneH;
            colorBackground[] = {0,0,0,0.3};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            onLBSelChanged = "['select'] call ALiVE_fnc_rallyWindow";
            onLBDblClick = "['travel'] call ALiVE_fnc_rallyWindow";
        };
        class RallyUI_Details: RecruitUI_RscStructuredText {
            idc = 92803;
            x = 0.53 * safezoneW + safezoneX;
            y = 0.315 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.075 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        // the map, centred on the rally point picked in the list
        class RallyUI_Map: RscMapControl {
            idc = 92807;
            x = 0.53 * safezoneW + safezoneX;
            y = 0.395 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.205 * safezoneH;
            showCountourInterval = 0;
        };
        class RallyUI_Travel: RecruitUI_RscButton {
            idc = 92805;
            text = "$STR_ALIVE_RALLY_UI_BUTTON_TRAVEL";
            action = "['travel'] call ALiVE_fnc_rallyWindow";
            x = 0.53 * safezoneW + safezoneX;
            y = 0.61 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class RallyUI_Close: RecruitUI_RscButton {
            idc = 92806;
            text = "$STR_ALIVE_RECRUIT_UI_BUTTON_CLOSE";
            action = "closeDialog 0";
            x = 0.605 * safezoneW + safezoneX;
            y = 0.61 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};

// A text box for the rename window; the recruitment window's controls have none
class RallyUI_RscEdit
{
	access = 0;
	type = 2;
	style = 0;
	idc = -1;
	x = 0;
	y = 0;
	w = 0.2;
	h = 0.03;
	font = "PuristaMedium";
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
	text = "";
	autocomplete = "";
	shadow = 0;
	colorBackground[] = {0, 0, 0, 0.5};
	colorText[] = {1, 1, 1, 1};
	colorDisabled[] = {1, 1, 1, 0.25};
	colorSelection[] = {1, 1, 1, 0.25};
	canModify = 1;
};

// Rename Rally Point: a squad leader's name for the squad's own rally point. Rename (or Enter) sends
// it, Cancel (or Escape) closes. ALiVE_fnc_rallyWindow fills it and sends the name.
class ALiVE_RallyRenameWindow {
    idd = 9282;
    movingEnable = 1;

    class controls {
        class RallyRename_Background: RecruitUI_RscText {
            idc = -1;
            x = 0.38 * safezoneW + safezoneX;
            y = 0.42 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.12 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class RallyRename_Header: RecruitUI_RscText {
            idc = 92830;
            text = "$STR_ALIVE_RALLY_RENAME";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.392 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class RallyRename_Edit: RallyUI_RscEdit {
            idc = 92831;
            maxChars = 32;
            x = 0.39 * safezoneW + safezoneX;
            y = 0.435 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class RallyRename_OK: RecruitUI_RscButton {
            idc = 92832;
            default = 1;
            text = "$STR_ALIVE_RALLY_UI_BUTTON_RENAME";
            action = "['renameSend'] call ALiVE_fnc_rallyWindow";
            x = 0.39 * safezoneW + safezoneX;
            y = 0.49 * safezoneH + safezoneY;
            w = 0.105 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class RallyRename_Cancel: RecruitUI_RscButton {
            idc = 92833;
            text = "$STR_ALIVE_RALLY_UI_BUTTON_CANCEL";
            action = "closeDialog 2";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.49 * safezoneH + safezoneY;
            w = 0.105 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
