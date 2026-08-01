#include "common.hpp"

// GUI editor: configfile >> "MainTablet"

class MainTablet
{
    idd = 10001;
    movingEnable = true;
    enableSimulation = false;
    onLoad = "['load'] call ALIVE_fnc_mainTablet;";
    onUnload = "['unload'] call ALIVE_fnc_mainTablet;";

    class controls
    {

        class MainTablet_background : RscPicture
        {
            idc = -1;
            x = 0.142424 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.0632 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.73 * GUI_GRID_WAbs;
            h = 0.84 * GUI_GRID_HAbs;
            text = "x\alive\addons\main\data\ui\ALiVE_toughbook.paa";
            moving = 0;
            colorBackground[] = {0,0,0,0};
        };

        class MainTablet_mainTitle : MainTablet_RscText
        {
            idc = 10002;
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

        class MainTablet_statusList : MainTablet_RscGUIListBox
        {
            idc = 10003;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.58 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };


    };
};
