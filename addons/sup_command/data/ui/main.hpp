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
            x = 0.142424 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.0632 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.73 * GUI_GRID_WAbs;
            h = 0.84 * GUI_GRID_HAbs;
            text = "x\alive\addons\main\data\ui\ALiVE_toughbook.paa";
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
            text = "Back";
            style = 0x02;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.7350 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class SCOMTablet_subMenuAbortButton : SCOMTablet_RscButton
        {
            idc = 12010;
            text = "Close";
            style = 0x02;
            x = 0.507 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.7350 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.2325 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
            action = "closeDialog 0";
        };

        // #698 Terrain toggle - top-right of the header bezel (same toughbook as the other tablets),
        // toggles every map used by the current view between satellite and schematic terrain.
        class SCOMTablet_TerrainButton : SCOMTablet_RscRealButton
        {
            idc = 12050;
            x = 0.686 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.098 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0597643 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Terrain";
            periodFocus = 1e10;
            periodOver = 1e10;
            period = 1e10; // #698 freeze the focus blink too (period drives the pulse while focused; periodFocus/Over alone left it flashing until focus moved away)
            action = "[!(uinamespace getVariable ['SCOMTerrainMode', true])] call ALIVE_fnc_SCOMSetTerrainMode";
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.384,0.439,0.341,1};
            colorFocused[] = {0.706,0.706,0.706,1};
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
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
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
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
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
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
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
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
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
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
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
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
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
            text = "Intel Type";
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
            h = 0.082 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
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
