#include "fobBuild_common.hpp"

// The FOB build window: opened by Build Menu within a FOB's build range. What can be built,
// grouped as fortifications or supply, what the selected item is and costs, what the FOB has
// in supply, and Place. ALiVE_fnc_buildMenu fills and drives it.

class ALiVE_FobBuildWindow {
    idd = 9280;
    movingEnable = 1;
    onUnload = "['closed'] call ALiVE_fnc_buildMenu";

    class controls {
        class FobUI_Background: FobUI_RscText {
            idc = 92800;
            x = 0.30 * safezoneW + safezoneX;
            y = 0.26 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.48 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class FobUI_Header: FobUI_RscText {
            idc = 92801;
            text = "$STR_ALIVE_FOB_UI_TITLE";
            x = 0.30 * safezoneW + safezoneX;
            y = 0.232 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class FobUI_Forts: FobUI_RscButton {
            idc = 92807;
            text = "$STR_ALIVE_FOB_UI_FORTIFICATIONS";
            action = "['category', 'FORTIFICATION'] call ALiVE_fnc_buildMenu";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.093 * safezoneW;
            h = 0.03 * safezoneH;
        };
        class FobUI_Supply: FobUI_RscButton {
            idc = 92808;
            text = "$STR_ALIVE_FOB_UI_SUPPLY";
            action = "['category', 'SUPPLY'] call ALiVE_fnc_buildMenu";
            x = 0.407 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.093 * safezoneW;
            h = 0.03 * safezoneH;
        };
        class FobUI_List: FobUI_RscListBox {
            idc = 92802;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.305 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.42 * safezoneH;
            colorBackground[] = {0,0,0,0.3};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            onLBSelChanged = "['select'] call ALiVE_fnc_buildMenu";
            onLBDblClick = "['place'] call ALiVE_fnc_buildMenu";
        };
        class FobUI_Picture: FobUI_RscText {
            idc = 92809;
            style = 48 + 2048;
            text = "";
            x = 0.51 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobUI_Details: FobUI_RscStructuredText {
            idc = 92803;
            x = 0.51 * safezoneW + safezoneX;
            y = 0.44 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobUI_Status: FobUI_RscStructuredText {
            idc = 92804;
            x = 0.51 * safezoneW + safezoneX;
            y = 0.61 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobUI_Place: FobUI_RscButton {
            idc = 92805;
            text = "$STR_ALIVE_FOB_UI_PLACE";
            action = "['place'] call ALiVE_fnc_buildMenu";
            x = 0.51 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobUI_Close: FobUI_RscButton {
            idc = 92806;
            text = "$STR_ALIVE_FOB_UI_CLOSE";
            action = "closeDialog 0";
            x = 0.605 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
