#include "common.hpp"

// GUI editor: configfile >> "GMTablet"

class GMTablet
{
    idd = 11001;
    movingEnable = true;
    onLoad = "[] call ALIVE_fnc_GMTabletOnLoad;";
    onUnload = "[] call ALIVE_fnc_GMTabletOnUnLoad;";

    class controlsBackground {
        class GMTablet_background : RscPicture
        {
            idc = 11002;
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

        class GMTablet_mainTitle : GMTablet_RscText
        {
            idc = 11007;
            text = "";
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

        class GMTablet_subMenuBackButton : GMTablet_RscButton
        {
            idc = 11006;
            text = "$STR_ALIVE_GM_UI_BACK";
            TABLET_KEY(TABLET_KEY_RX,2); // the painted key R3 (gui_grid.hpp)
        };

        class GMTablet_subMenuAbortButton : GMTablet_RscButton
        {
            idc = 11010;
            text = "$STR_ALIVE_GM_UI_CLOSE";
            action = "closeDialog 0";
            TABLET_KEY(TABLET_KEY_RX,3); // the painted key R4 (gui_grid.hpp)
        };

        // #698 Terrain toggle - top-right of the header bezel (same toughbook as the other tablets),
        // toggles both group-view maps (left 11020 + right 11021) between satellite and schematic.
        class GMTablet_TerrainButton : GMTablet_RscRealButton
        {
            idc = 11050;
            x = 0.689736 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1148 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0497643 * GUI_GRID_WAbs; // wide enough for TERRAIN in the typewriter faces
            h = 0.028 * GUI_GRID_HAbs;
            style = 0x02;
            text = "$STR_ALIVE_GM_UI_TERRAIN";
            periodFocus = 1e10;
            periodOver = 1e10;
            period = 1e10; // #698 freeze the focus blink too (period drives the pulse while focused; periodFocus/Over alone left it flashing until focus moved away)
            action = "[!(uinamespace getVariable ['GMTerrainMode', true])] call ALIVE_fnc_GMSetTerrainMode";
            // white text straight on the screen, no backdrop in any state (Jman 27 Oct)
            colorText[] = {1,1,1,1};
            colorBackground[] = {0,0,0,0};
            colorBackgroundActive[] = {1,1,1,0.08};
            colorBackgroundFocused[] = {0,0,0,0};
            colorFocused[] = {0,0,0,0};
            colorBorder[] = {0,0,0,0};
            colorShadow[] = {0,0,0,0};
            shadow = 0;
            borderSize = 0;
            sizeEx = 0.5 * GUI_GRID_H;
        };

        class GMTablet_mainList : GMTablet_RscListNBox
        {
            idc = 11011;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.5 * GUI_GRID_HAbs;
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

        class GMTablet_leftList : GMTablet_RscListNBox
        {
            idc = 11012;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.5,0.5,0.5,1};
            color[] = {0.5,0.5,0.5,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
            columns[] = {0,0.2,0.6,0.8};
            drawSideArrows = false;
            idcLeft = -1;
            idcRight = -1;
        };

        class GMTablet_rightList : GMTablet_RscListNBox
        {
            idc = 11013;
            text = "";
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.5,0.5,0.5,1};
            color[] = {0.5,0.5,0.5,1};
            colorActive[] = {0.3,0.3,0.3,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
            columns[] = {0,0.2,0.5,0.7};
            drawSideArrows = false;
            idcLeft = -1;
            idcRight = -1;
        };

        class GMTablet_1ButtonL : GMTablet_RscButton
        {
            idc = 11014;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.1145 * GUI_GRID_WAbs; // slots 1 and 2 side by side, a pair (Jman 27 Oct)
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button1";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class GMTablet_2ButtonL : GMTablet_RscButton
        {
            idc = 11015;
            x = 0.389703 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.1145 * GUI_GRID_WAbs; // slots 1 and 2 side by side, a pair (Jman 27 Oct)
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button2";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class GMTablet_3ButtonL : GMTablet_RscButton
        {
            idc = 11016;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6810 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button3";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class GMTablet_1ButtonR : GMTablet_RscButton
        {
            idc = 11017;
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.1145 * GUI_GRID_WAbs; // slots 1 and 2 side by side, a pair (Jman 27 Oct)
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button1";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class GMTablet_2ButtonR : GMTablet_RscButton
        {
            idc = 11018;
            x = 0.625500 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.1145 * GUI_GRID_WAbs; // slots 1 and 2 side by side, a pair (Jman 27 Oct)
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button2";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class GMTablet_3ButtonR : GMTablet_RscButton
        {
            idc = 11019;
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6810 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button3";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class GMTablet_left_map : GMTablet_RscMap
        {
            idc = 11020;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
        };

        class GMTablet_right_map : GMTablet_RscMap
        {
            idc = 11021;
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
        };

    };
};
