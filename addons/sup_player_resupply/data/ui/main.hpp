#include "common.hpp"

// GUI editor: configfile >> "PRTablet"

class PRTablet
{
    idd = 60001;
    movingEnable = true;
    onLoad = "[] call ALIVE_fnc_PRTabletOnLoad;";
    onUnload = "[] call ALIVE_fnc_PRTabletOnUnLoad;";

    class controlsBackground {
        class GMTablet_background : RscPicture
        {
            idc = 60000;
            x = TABLET_ART_X;
            y = TABLET_ART_Y;
            w = TABLET_ART_WAbs;
            h = TABLET_ART_HAbs;
            text = "\x\alive\addons\main\data\ui\ALiVE_tablet_modern43_ca.paa"; // ALiVE_fnc_tabletOpen sets the era's artwork
            moving = 0;
            colorBackground[] = {0,0,0,0};
        };
    };

    class controls
    {

        class PRTablet_map : PRTablet_RscMap
        {
            idc = 60002;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1584 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.4 * GUI_GRID_HAbs;
        };

        class PRTablet_status : PRTablet_RscButton
        {
            idc = 60025;
            text = "$STR_ALIVE_PR_UI_SHOW_STATUS";
            TABLET_KEY(TABLET_KEY_RX,1); // the painted key R2 (gui_grid.hpp)
        };

        class PRTablet_request : PRTablet_RscButton
        {
            idc = 60003;
            text = "$STR_ALIVE_PR_UI_SEND_REQUEST";
            TABLET_KEY(TABLET_KEY_RX,0); // the painted key R1 (gui_grid.hpp)
        };

        // Back, like the other C2ISTAR tablets (Jman 19 Oct): it shares Close's old slot, so nothing else moves
        class PRTablet_back : PRTablet_RscButton
        {
            idc = 60029;
            text = "$STR_ALIVE_PR_UI_BACK";
            TABLET_KEY(TABLET_KEY_RX,2); // the painted key R3 (gui_grid.hpp)
        };

        class PRTablet_abort : PRTablet_RscButton
        {
            idc = 60004;
            text = "$STR_ALIVE_PR_UI_CLOSE";
            action = "closeDialog 0";
            TABLET_KEY(TABLET_KEY_RX,3); // the painted key R4 (gui_grid.hpp)
        };

        // #698 Terrain toggle - top-right of the header bezel (same toughbook as the other tablets),
        // clear of the map. Swaps the map between the textured satellite view and the plain schematic.
        class PRTablet_TerrainButton : PRTablet_RscRealButton
        {
            idc = 60050;
            x = 0.676557 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1148 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0597643 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "$STR_ALIVE_PR_UI_TERRAIN";
            periodFocus = 1e10; // never blink
            periodOver = 1e10;
            period = 1e10; // #698 freeze the focus blink too (period drives the pulse while focused; periodFocus/Over alone left it flashing until focus moved away)
            action = "[!(uinamespace getVariable ['PRTerrainMode', true])] call ALIVE_fnc_PRSetTerrainMode";
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.384,0.439,0.341,1};
            colorFocused[] = {0.706,0.706,0.706,1};
            sizeEx = 0.5 * GUI_GRID_H;
        };

        // the editor picture of the item last added to the payload or picked in it
        class PRTablet_preview : RscPicture
        {
            idc = 60051;
            style = 2096; // ST_PICTURE + ST_KEEP_ASPECT_RATIO
            text = "";
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6800 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.0850 * GUI_GRID_HAbs;
        };

        class PRTablet_currentForcePool : PRTablet_RscText
        {
            text = "";
            idc = 60099;
            x = 0.6462 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6450 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.1001 * GUI_GRID_WAbs; // ends at the screen's right edge (0.7463)
            h = 0.0308 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_payloadWeight : PRTablet_RscText
        {
            text = "";
            idc = 60012;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5700 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0308 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_payloadSize : PRTablet_RscText
        {
            text = "";
            idc = 60023;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5850 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0308 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_payloadGroups : PRTablet_RscText
        {
            text = "";
            idc = 60013;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6000 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0308 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_payloadVehicles : PRTablet_RscText
        {
            text = "";
            idc = 60014;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0308 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_payloadIndividuals : PRTablet_RscText
        {
            text = "";
            idc = 60015;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6300 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0308 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_payloadStatus : PRTablet_RscText
        {
            text = "";
            idc = 60016;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6450 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.025 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_deliveryTitle : PRTablet_RscText
        {
            idc = 60017;
            text = "$STR_ALIVE_PR_UI_DELIVERY_HDR";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1430 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.024 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_deliveryList : PRTablet_RscGUIListBox
        {
            idc = 60005;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1670 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.081 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class PRTablet_supplyTitle : PRTablet_RscText
        {
            idc = 60018;
            text = "$STR_ALIVE_PR_UI_SUPPLY_HDR";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2580 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.024 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        // the supply list's search box (Jman, 30 Oct), on the right of its title, as in the FOB build menu
        class PRTablet_supplySearch
        {
            idc = 60052;
            type = 2;
            style = 0;
            access = 0;
            x = 0.4075 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.1050 * GUI_GRID_WAbs;
            h = 0.020 * GUI_GRID_HAbs;
            font = "PuristaMedium";
            sizeEx = 0.5 * GUI_GRID_H;
            text = "";
            autocomplete = "";
            shadow = 0;
            canModify = 1;
            tooltip = "$STR_ALIVE_PR_UI_SEARCH_TIP";
            colorBackground[] = {0.173,0.173,0.173,1};
            colorText[] = {1,1,1,1};
            colorDisabled[] = {1,1,1,0.25};
            colorSelection[] = {0.384,0.439,0.341,1};
            onKeyUp = "['SUPPLY_SEARCH', _this] call ALIVE_fnc_PRTabletOnAction";
        };

        class PRTablet_supplyList : PRTablet_RscGUIListBox
        {
            idc = 60006;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2820 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.110 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class PRTablet_reinforceTitle : PRTablet_RscText
        {
            idc = 60019;
            text = "$STR_ALIVE_PR_UI_REINFORCE_HDR";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.4020 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.024 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_reinforceList : PRTablet_RscGUIListBox
        {
            idc = 60007;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.4260 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.110 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class PRTablet_selectedTitle : PRTablet_RscText
        {
            idc = 60020;
            text = "$STR_ALIVE_PR_UI_PAYLOAD_HDR";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5460 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.024 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_selectedList : PRTablet_RscGUIListBox
        {
            idc = 60008;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5700 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.066 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class PRTablet_selectedInfo : PRTablet_RscText
        {
            text = "";
            idc = 60009;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6700 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        // Add and Remove on the payload's heading: a click in a list only picks a row out (Jman, 30 Oct)
        class PRTablet_selectedAdd : PRTablet_RscButton
        {
            idc = 60053;
            x = 0.4075 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5460 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0500 * GUI_GRID_WAbs;
            h = 0.024 * GUI_GRID_HAbs;
            class TextPos
            {
                // the heading row is shorter than the tablet's other buttons, so the text sits higher
                left = 0;
                top = 0.05 * GUI_GRID_H;
                right = 0;
                bottom = 0;
            };
            text = "$STR_ALIVE_PR_UI_ADD";
            tooltip = "$STR_ALIVE_PR_UI_ADD_TIP";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
            onButtonClick = "['ADD_CLICK', []] call ALIVE_fnc_PRTabletOnAction";
        };

        class PRTablet_selectedDelete : PRTablet_RscButton
        {
            idc = 60010;
            x = 0.4625 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5460 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0500 * GUI_GRID_WAbs;
            h = 0.024 * GUI_GRID_HAbs;
            class TextPos
            {
                // the heading row is shorter than the tablet's other buttons, so the text sits higher
                left = 0;
                top = 0.05 * GUI_GRID_H;
                right = 0;
                bottom = 0;
            };
            text = "$STR_ALIVE_PR_UI_REMOVE";
            tooltip = "$STR_ALIVE_PR_UI_REMOVE_TIP";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class PRTablet_selectedOptionList : PRTablet_RscGUIListBox
        {
            idc = 60011;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.7000 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.066 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class PRTablet_requestedStatusTitle : PRTablet_RscText
        {
            text = "";
            idc = 60021;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1430 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0308 * GUI_GRID_HAbs;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_requestedStatus : PRTablet_RscText
        {
            text = "";
            idc = 60022;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2200 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.2 * GUI_GRID_HAbs;
            style = 528;
            colorBackground[] = {0,0,0,0};
            class Attributes
            {
                font = "PuristaMedium";
                color = "#a6a6a6";
                align = "left";
                valign = "middle";
                shadow = true;
                shadowColor = "#000000";
                size = 0.8;
            };
        };

        class PRTablet_mainList : PRTablet_RscListNBox
        {
            idc = 60024;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.8,0.8,0.8,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
            columns[] = {0,0.07,0.6,0.8};
            drawSideArrows = false;
            idcLeft = -1;
            idcRight = -1;
        };

        class PRTablet_1ButtonL : PRTablet_RscButton
        {
            idc = 60026;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button1";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class PRTablet_1ButtonR : PRTablet_RscButton
        {
            idc = 60027;
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button1";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class PRTablet_status_map : PRTablet_RscMap
        {
            idc = 60028;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
        };

    };
};
