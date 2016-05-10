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
            idc = -1;
            x = 0.142424 * safezoneW + safezoneX;
            y = 0.0632 * safezoneH + safezoneY;
            w = 0.73 * safezoneW;
            h = 0.84 * safezoneH;
            text = "x\alive\addons\sup_player_resupply\data\ui\ALIVE_toughbook_2.paa";
            moving = 0;
            colorBackground[] = {0,0,0,0};
        };
    };

    class controls
    {

        class PRTablet_map : PRTablet_RscMap
        {
            idc = 60002;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.1584 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.4 * safezoneH;
        };

        class PRTablet_status : PRTablet_RscButton
        {
            idc = 60025;
            text = "Show Status";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.7000 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.384,0.439,0.341,1};
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class PRTablet_request : PRTablet_RscButton
        {
            idc = 60003;
            text = "Send Request";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6650 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.384,0.439,0.341,1};
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class PRTablet_abort : PRTablet_RscButton
        {
            idc = 60004;
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


        class PRTablet_payloadWeight : PRTablet_RscText
        {
            text = "";
            idc = 60012;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.5700 * safezoneH + safezoneY;
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

        class PRTablet_payloadSize : PRTablet_RscText
        {
            text = "";
            idc = 60023;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.5850 * safezoneH + safezoneY;
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

        class PRTablet_payloadGroups : PRTablet_RscText
        {
            text = "";
            idc = 60013;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6000 * safezoneH + safezoneY;
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

        class PRTablet_payloadVehicles : PRTablet_RscText
        {
            text = "";
            idc = 60014;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6150 * safezoneH + safezoneY;
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

        class PRTablet_payloadIndividuals : PRTablet_RscText
        {
            text = "";
            idc = 60015;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6300 * safezoneH + safezoneY;
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

        class PRTablet_payloadStatus : PRTablet_RscText
        {
            text = "";
            idc = 60016;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6450 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.025 * safezoneH;
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
            text = "Delivery Type";
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

        class PRTablet_deliveryList : PRTablet_RscGUIListBox
        {
            idc = 60005;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class PRTablet_supplyTitle : PRTablet_RscText
        {
            idc = 60018;
            text = "Supply List";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.2230 * safezoneH + safezoneY;
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

        class PRTablet_supplyList : PRTablet_RscGUIListBox
        {
            idc = 60006;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.2400 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.13 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class PRTablet_reinforceTitle : PRTablet_RscText
        {
            idc = 60019;
            text = "Reinforce List";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.3730 * safezoneH + safezoneY;
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

        class PRTablet_reinforceList : PRTablet_RscGUIListBox
        {
            idc = 60007;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.3892 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.13 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class PRTablet_selectedTitle : PRTablet_RscText
        {
            idc = 60020;
            text = "Payload";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.5230 * safezoneH + safezoneY;
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

        class PRTablet_selectedList : PRTablet_RscGUIListBox
        {
            idc = 60008;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.5400 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.1 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class PRTablet_selectedInfo : PRTablet_RscText
        {
            text = "";
            idc = 60009;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.6730 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
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

        class PRTablet_selectedDelete : PRTablet_RscButton
        {
            idc = 60010;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.6400 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Delete";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class PRTablet_selectedOptionList : PRTablet_RscGUIListBox
        {
            idc = 60011;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.6900 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class PRTablet_requestedStatusTitle : PRTablet_RscText
        {
            text = "";
            idc = 60021;
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

        class PRTablet_requestedStatus : PRTablet_RscText
        {
            text = "";
            idc = 60022;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.2200 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.2 * safezoneH;
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
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.45 * safezoneH;
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

        class PRTablet_1ButtonL : PRTablet_RscButton
        {
            idc = 60026;
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

        class PRTablet_1ButtonR : PRTablet_RscButton
        {
            idc = 60027;
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

        class PRTablet_status_map : PRTablet_RscMap
        {
            idc = 60028;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.45 * safezoneH;
        };

    };
};