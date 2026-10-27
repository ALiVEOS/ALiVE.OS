#include "common.hpp"

// GUI editor: configfile >> "SCOMTablet"

class SCOMTablet
{
    idd = 12001;
    movingEnable = true;
    onLoad = "[] call ALIVE_fnc_SCOMTabletOnLoad;";
    onUnload = "[] call ALIVE_fnc_SCOMTabletOnUnLoad;";

    class controlsBackground {
        class SCOMTablet_background : SCOMTablet_RscPicture
        {
            idc = 12002;
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

        class SCOMTablet_mainTitle : SCOMTablet_RscText
        {
            idc = 12007;
            text = "";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1430 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
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

        class SCOMTablet_subMenuBackButton : SCOMTablet_RscButton
        {
            idc = 12006;
            text = "$STR_ALIVE_SCOM_UI_BACK";
            TABLET_KEY(TABLET_KEY_RX,2); // the painted key R3 (gui_grid.hpp)
        };

        class SCOMTablet_subMenuAbortButton : SCOMTablet_RscButton
        {
            idc = 12010;
            text = "$STR_ALIVE_SCOM_UI_CLOSE";
            action = "closeDialog 0";
            TABLET_KEY(TABLET_KEY_RX,3); // the painted key R4 (gui_grid.hpp)
        };

        // #698 Terrain toggle - top-right of the header bezel (same toughbook as the other tablets),
        // toggles every map used by the current view between satellite and schematic terrain.
        class SCOMTablet_TerrainButton : SCOMTablet_RscRealButton
        {
            idc = 12050;
            x = 0.686338 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1148 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0497643 * GUI_GRID_WAbs; // wide enough for TERRAIN in the typewriter faces
            style = 0x02;
            h = 0.028 * GUI_GRID_HAbs;
            text = "$STR_ALIVE_SCOM_UI_TERRAIN";
            periodFocus = 1e10;
            periodOver = 1e10;
            period = 1e10; // #698 freeze the focus blink too (period drives the pulse while focused; periodFocus/Over alone left it flashing until focus moved away)
            action = "[!(uinamespace getVariable ['SCOMTerrainMode', true])] call ALIVE_fnc_SCOMSetTerrainMode";
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

        class SCOMTablet_1ButtonL : SCOMTablet_RscButton
        {
            idc = 12014;
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

        class SCOMTablet_2ButtonL : SCOMTablet_RscButton
        {
            idc = 12015;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6480 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button2";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class SCOMTablet_3ButtonL : SCOMTablet_RscButton
        {
            idc = 12016;
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

        class SCOMTablet_1ButtonR : SCOMTablet_RscButton
        {
            idc = 12017;
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

        class SCOMTablet_2ButtonR : SCOMTablet_RscButton
        {
            idc = 12018;
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6480 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Button2";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {1,1,1,0.07};
            colorBackgroundFocused[] = {1,1,1,0.14};
            colorFocused[] = {1,1,1,1};
        };

        class SCOMTablet_3ButtonR : SCOMTablet_RscButton
        {
            idc = 12019;
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

        class SCOMTablet_right_map : SCOMTablet_RscMap
        {
            idc = 12021;
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
        };

        class SCOMTablet_main_map : SCOMTablet_RscMap
        {
            idc = 12022;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.5 * GUI_GRID_HAbs;
        };

        class SCOMTablet_renderTarget : SCOMTablet_RscPicture
        {
            idc = 12033;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.5 * GUI_GRID_HAbs;
        };

        class SCOMTablet_editList : SCOMTablet_RscListBox
        {
            idc = 12027;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.17 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.6,0.6,0.6,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class SCOMTablet_waypointList : SCOMTablet_RscListBox
        {
            idc = 12028;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.17 * GUI_GRID_WAbs;
            h = 0.13 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.6,0.6,0.6,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class SCOMTablet_waypointTypeList : SCOMTablet_RscListBox
        {
            idc = 12029;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.296 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.17 * GUI_GRID_WAbs;
            h = 0.103 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.6,0.6,0.6,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class SCOMTablet_waypointSpeedList : SCOMTablet_RscListBox
        {
            idc = 12030;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.405 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.17 * GUI_GRID_WAbs;
            h = 0.1 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.6,0.6,0.6,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class SCOMTablet_waypointFormationList : SCOMTablet_RscListBox
        {
            idc = 12031;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.51 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.17 * GUI_GRID_WAbs;
            h = 0.1 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.6,0.6,0.6,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class SCOMTablet_waypointBehavourList : SCOMTablet_RscListBox
        {
            idc = 12032;
            text = "";
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.616 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.17 * GUI_GRID_WAbs;
            h = 0.1 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.6,0.6,0.6,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class SCOMTablet_edit_map : SCOMTablet_RscMap
        {
            idc = 12026;
            x = 0.445 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.293 * GUI_GRID_WAbs;
            h = 0.45 * GUI_GRID_HAbs;
        };

        class SCOMTablet_intelTypeTitle : SCOMTablet_RscText
        {
            idc = 12023;
            text = "$STR_ALIVE_SCOM_UI_INTEL_TYPE";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6596 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0208 * GUI_GRID_HAbs;
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

        class SCOMTablet_intelTypeList : SCOMTablet_RscGUIListBox
        {
            idc = 12024;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6810 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            // ends above the Back button (y 0.735), which shows on the Intel tablet's first page since #1089:
            // three rows of 0.41 fit, so Commander Objectives, Unit Marking and Imagery are all clear of it
            h = 0.050 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.4 * GUI_GRID_H;
            rowHeight = 0.41 * GUI_GRID_H;
        };

        class SCOMTablet_intelStatus : SCOMTablet_RscText
        {
            idc = 12025;
            text = "";
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6596 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
            h = 0.0208 * GUI_GRID_HAbs;
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

    };
};
