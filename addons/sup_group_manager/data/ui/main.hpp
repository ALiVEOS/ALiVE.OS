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
            idc = -1;
            x = 0.142424 * safezoneW + safezoneX;
            y = 0.0632 * safezoneH + safezoneY;
            w = 0.73 * safezoneW;
            h = 0.84 * safezoneH;
            text = "x\alive\addons\sup_group_manager\data\ui\ALIVE_toughbook_2.paa";
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
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.1430 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.0308 * safezoneH;
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
            text = "Back";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.7000 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class GMTablet_subMenuAbortButton : GMTablet_RscButton
        {
            idc = 11010;
            text = "Close";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.7350 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
            action = "closeDialog 0";
        };

        class GMTablet_mainList : GMTablet_RscListNBox
        {
            idc = 11011;
            text = "";
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.5 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.6,0.6,0.6,1};
            color[] = {0.8,0.8,0.8,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
            columns[] = {0,0.07,0.6,0.8};
            drawSideArrows = false;
            idcLeft = -1;
            idcRight = -1;
        };

        class GMTablet_leftList : GMTablet_RscListNBox
        {
            idc = 11012;
            text = "";
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.45 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.5,0.5,0.5,1};
            color[] = {0.5,0.5,0.5,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
            columns[] = {0,0.2,0.6,0.8};
            drawSideArrows = false;
            idcLeft = -1;
            idcRight = -1;
        };

        class GMTablet_rightList : GMTablet_RscListNBox
        {
            idc = 11013;
            text = "";
            x = 0.507 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.45 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorSelectBackground[] = {0.3,0.3,0.3,1};
            colorSelectBackground2[] = {0.3,0.3,0.3,1};
            colorText[] = {0.5,0.5,0.5,1};
            color[] = {0.5,0.5,0.5,1};
            colorActive[] = {0.3,0.3,0.3,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
            columns[] = {0,0.2,0.5,0.7};
            drawSideArrows = false;
            idcLeft = -1;
            idcRight = -1;
        };

        class GMTablet_1ButtonL : GMTablet_RscButton
        {
            idc = 11014;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.6150 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Button1";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class GMTablet_2ButtonL : GMTablet_RscButton
        {
            idc = 11015;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.6480 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Button2";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class GMTablet_3ButtonL : GMTablet_RscButton
        {
            idc = 11016;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.6810 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Button3";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class GMTablet_1ButtonR : GMTablet_RscButton
        {
            idc = 11017;
            x = 0.507 * safezoneW + safezoneX;
            y = 0.6150 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Button1";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class GMTablet_2ButtonR : GMTablet_RscButton
        {
            idc = 11018;
            x = 0.507 * safezoneW + safezoneX;
            y = 0.6480 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Button2";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class GMTablet_3ButtonR : GMTablet_RscButton
        {
            idc = 11019;
            x = 0.507 * safezoneW + safezoneX;
            y = 0.6810 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Button3";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class GMTablet_left_map : GMTablet_RscMap
        {
            idc = 11020;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.45 * safezoneH;
        };

        class GMTablet_right_map : GMTablet_RscMap
        {
            idc = 11021;
            x = 0.507 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.2325 * safezoneW;
            h = 0.45 * safezoneH;
        };

    };
};