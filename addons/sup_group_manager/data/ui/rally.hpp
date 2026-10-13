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
