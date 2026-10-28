#include "fobBuild_common.hpp"

// The FOB build window: opened by Build Menu within a FOB's build range. What can be built,
// grouped as fortifications, supply, static weapons or vehicles, what the selected item is and costs,
// what the FOB has in supply, and Place. ALiVE_fnc_buildMenu fills and drives it.

// Taller than it was so the item list shows about 25 rows before scrolling (NeisAEL on Discord, 24 Oct)
class ALiVE_FobBuildWindow {
    idd = 9280;
    movingEnable = 1;
    onUnload = "['closed'] call ALiVE_fnc_buildMenu";

    class controls {
        class FobUI_Background: FobUI_RscText {
            idc = 92800;
            x = 0.30 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.70 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class FobUI_Header: FobUI_RscText {
            idc = 92801;
            text = "$STR_ALIVE_FOB_UI_TITLE";
            x = 0.30 * safezoneW + safezoneX;
            y = 0.122 * safezoneH + safezoneY;
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
            y = 0.16 * safezoneH + safezoneY;
            w = 0.05 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
        };
        class FobUI_Supply: FobUI_RscButton {
            idc = 92808;
            text = "$STR_ALIVE_FOB_UI_SUPPLY";
            action = "['category', 'SUPPLY'] call ALiVE_fnc_buildMenu";
            x = 0.362 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.032 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
        };
        class FobUI_Statics: FobUI_RscButton {
            idc = 92810;
            text = "$STR_ALIVE_FOB_UI_STATICS";
            action = "['category', 'STATIC'] call ALiVE_fnc_buildMenu";
            x = 0.396 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.034 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
        };
        class FobUI_Vehicles: FobUI_RscButton {
            idc = 92811;
            text = "$STR_ALIVE_FOB_UI_VEHICLES";
            action = "['category', 'VEHICLE'] call ALiVE_fnc_buildMenu";
            x = 0.432 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.036 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
        };
        class FobUI_Troops: FobUI_RscButton {
            idc = 92815;
            text = "$STR_ALIVE_FOB_UI_TROOPS";
            action = "['category', 'TROOPS'] call ALiVE_fnc_buildMenu";
            x = 0.47 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.03 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
        };
        // Search (#1085): typing narrows the list to the items whose name or class has the text in it
        class FobUI_SearchLabel: FobUI_RscText {
            idc = 92813;
            text = "$STR_ALIVE_FOB_UI_SEARCH";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.195 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class FobUI_Search: FobUI_RscEdit {
            idc = 92812;
            tooltip = "$STR_ALIVE_FOB_UI_SEARCH_TIP";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.195 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.03 * safezoneH;
            onKeyUp = "['filter'] call ALiVE_fnc_buildMenu";
        };
        // Tier filter: what this FOB can build now (the default), one tier's items, or every tier.
        // Items the FOB's tier is too low for are listed greyed, and Place stays off for them.
        class FobUI_Tier: FobUI_RscCombo {
            idc = 92814;
            tooltip = "$STR_ALIVE_FOB_UI_TIER_TIP";
            x = 0.44 * safezoneW + safezoneX;
            y = 0.195 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.03 * safezoneH;
            onLBSelChanged = "['filter'] call ALiVE_fnc_buildMenu";
        };
        class FobUI_List: FobUI_RscListBox {
            idc = 92802;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.605 * safezoneH;
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
            y = 0.16 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobUI_Details: FobUI_RscStructuredText {
            idc = 92803;
            x = 0.51 * safezoneW + safezoneX;
            y = 0.33 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.38 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobUI_Status: FobUI_RscStructuredText {
            idc = 92804;
            x = 0.51 * safezoneW + safezoneX;
            y = 0.72 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobUI_Place: FobUI_RscButton {
            idc = 92805;
            text = "$STR_ALIVE_FOB_UI_PLACE";
            action = "['place'] call ALiVE_fnc_buildMenu";
            x = 0.51 * safezoneW + safezoneX;
            y = 0.80 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobUI_Close: FobUI_RscButton {
            idc = 92806;
            text = "$STR_ALIVE_FOB_UI_CLOSE";
            action = "closeDialog 0";
            x = 0.605 * safezoneW + safezoneX;
            y = 0.80 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
