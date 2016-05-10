#include "common.hpp"

// GUI editor: configfile >> "C2Tablet"

class C2Tablet
{
    idd = 70001;
    movingEnable = true;
    onLoad = "[] call ALIVE_fnc_C2TabletOnLoad;";
    onUnload = "[] call ALIVE_fnc_C2TabletOnUnLoad;";

    class controls
    {

        class C2Tablet_background : RscPicture
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

        class C2Tablet_mainTitle : C2Tablet_RscText
        {
            idc = 70007;
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

        class C2Tablet_subMenuBackButton : C2Tablet_RscButton
        {
            idc = 70006;
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

        class C2Tablet_subMenuAbortButton : C2Tablet_RscButton
        {
            idc = 70010;
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

        class C2Tablet_currentTaskList : C2Tablet_RscGUIListBox
        {
            idc = 70025;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.35 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_createTaskButton : C2Tablet_RscButton
        {
            idc = 70016;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.5150 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Create task";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_generateTaskButton : C2Tablet_RscButton
        {
            idc = 70038;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.5480 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Generate a task";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_autoGenerateTaskButton : C2Tablet_RscButton
        {
            idc = 70048;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.5820 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Auto generate tasks for my side";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingCurrentTaskListEditButton : C2Tablet_RscButton
        {
            idc = 70026;
            text = "Edit Task";
            style = 0x02;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.6160 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingCurrentTaskListDeleteButton : C2Tablet_RscButton
        {
            idc = 70027;
            text = "Delete Task";
            style = 0x02;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.6500 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskPlayerList : C2Tablet_RscGUIListBox
        {
            idc = 70011;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.13 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskSelectGroupButton : C2Tablet_RscButton
        {
            idc = 70014;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.2900 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Select all group members";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskSelectedPlayerTitle : C2Tablet_RscText
        {
            idc = 70012;
            text = "Selected Players";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.3290 * safezoneH + safezoneY;
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

        class C2Tablet_taskSelectedPlayerList : C2Tablet_RscGUIListBox
        {
            idc = 70013;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.3460 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.13 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskSelectedPlayerListDeleteButton : C2Tablet_RscButton
        {
            idc = 70015;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.4770 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Delete";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskSelectedPlayersClearButton : C2Tablet_RscButton
        {
            idc = 70029;
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.5100 * safezoneH + safezoneY;
            w = 0.465 * safezoneW;
            h = 0.028 * safezoneH;
            text = "Clear selected players";
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingAddTaskTitleEditTitle : C2Tablet_RscText
        {
            idc = 70018;
            text = "Task Title";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
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

        class C2Tablet_taskingAddTaskTitleEdit : C2Tablet_RscEdit
        {
            idc = 70019;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1770 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.028 * safezoneH;
        };

        class C2Tablet_taskingAddTaskDescriptionEditTitle : C2Tablet_RscText
        {
            idc = 70020;
            text = "Task Description";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.2100 * safezoneH + safezoneY;
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

        class C2Tablet_taskingAddTaskDescriptionEdit : C2Tablet_RscEdit
        {
            idc = 70021;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.2270 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.13 * safezoneH;
            style = 16;
        };

        class C2Tablet_taskingAddTaskStateEditTitle : C2Tablet_RscText
        {
            idc = 70030;
            text = "Task State";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.3600 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.0208 * safezoneH;
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

        class C2Tablet_taskingAddTaskStateEditList : C2Tablet_RscGUIListBox
        {
            idc = 70031;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.3770 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.1 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingMap : C2Tablet_RscMap
        {
            idc = 70022;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.1584 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.4 * safezoneH;
        };

        class C2Tablet_taskingAddTaskCreateButton : C2Tablet_RscButton
        {
            idc = 70023;
            text = "Create Task";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6650 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingEditTaskUpdateButton : C2Tablet_RscButton
        {
            idc = 70028;
            text = "Update Task";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6650 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingEditTaskManagePlayersButton : C2Tablet_RscButton
        {
            idc = 70032;
            text = "Assign Players";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6300 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingAddTaskApplyEditTitle : C2Tablet_RscText
        {
            idc = 70033;
            text = "Applied to players";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.4800 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.0208 * safezoneH;
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

        class C2Tablet_taskingAddTaskApplyEditList : C2Tablet_RscGUIListBox
        {
            idc = 70034;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.4970 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingAddTaskSetCurrent : C2Tablet_RscText
        {
            idc = 70035;
            text = "Set Current";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.5600 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.0208 * safezoneH;
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

        class C2Tablet_taskingAddTaskSetCurrentList : C2Tablet_RscGUIListBox
        {
            idc = 70036;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.5770 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingAddTaskStatus : C2Tablet_RscText
        {
            idc = 70037;
            text = "STATUS";
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.5800 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.0208 * safezoneH;
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

        class C2Tablet_taskingAddTaskSelectParent : C2Tablet_RscText
        {
            idc = 70039;
            text = "Select Parent Task";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.6250 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.0208 * safezoneH;
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

        class C2Tablet_taskingCurrentParentTaskList : C2Tablet_RscGUIListBox
        {
            idc = 70040;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.6420 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.11 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingGenerateTaskTypeEditTitle : C2Tablet_RscText
        {
            idc = 70041;
            text = "Task Type";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
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

        class C2Tablet_taskingGenerateTaskTypeEdit : C2Tablet_RscGUIListBox
        {
            idc = 70042;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1770 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.11 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingGenerateTaskCreateButton : C2Tablet_RscButton
        {
            idc = 70043;
            text = "Generate Task";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6650 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingGenerateTaskLocationEditTitle : C2Tablet_RscText
        {
            idc = 70044;
            text = "Task Location";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.2900 * safezoneH + safezoneY;
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

        class C2Tablet_taskingGenerateTaskLocationEdit : C2Tablet_RscGUIListBox
        {
            idc = 70045;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.3070 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.08 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingGenerateTaskFactionEditTitle : C2Tablet_RscText
        {
            idc = 70046;
            text = "Task Enemy Faction";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.3900 * safezoneH + safezoneY;
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

        class C2Tablet_taskingGenerateTaskFactionEdit : C2Tablet_RscGUIListBox
        {
            idc = 70047;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.4070 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.12 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingAutoGenerateTaskFactionEditTitle : C2Tablet_RscText
        {
            idc = 70049;
            text = "Task Enemy Faction";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.1600 * safezoneH + safezoneY;
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

        class C2Tablet_taskingAutoGenerateTaskFactionEdit : C2Tablet_RscGUIListBox
        {
            idc = 70050;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.1770 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.2 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingAutoGenerateTaskCreateButton : C2Tablet_RscButton
        {
            idc = 70051;
            text = "Enable Auto Generated Tasks";
            style = 0x02;
            x = 0.519796 * safezoneW + safezoneX;
            y = 0.6650 * safezoneH + safezoneY;
            w = 0.216525 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = 0.8 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingGenerateApplyEditTitle : C2Tablet_RscText
        {
            idc = 70052;
            text = "Applied to players";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.5300 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.0208 * safezoneH;
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

        class C2Tablet_taskingGenerateApplyEditList : C2Tablet_RscGUIListBox
        {
            idc = 70053;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.5470 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

        class C2Tablet_taskingGenerateSetCurrent : C2Tablet_RscText
        {
            idc = 70054;
            text = "Set Current";
            x = 0.271203 * safezoneW + safezoneX;
            y = 0.6100 * safezoneH + safezoneY;
            w = 0.159596 * safezoneW;
            h = 0.0208 * safezoneH;
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

        class C2Tablet_taskingGenerateSetCurrentList : C2Tablet_RscGUIListBox
        {
            idc = 70055;
            x = 0.271102 * safezoneW + safezoneX;
            y = 0.6270 * safezoneH + safezoneY;
            w = 0.241271 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = (safeZoneW / 75) + (safeZoneH / 275);
            rowHeight = (safeZoneW / 75) + (safeZoneH / 275);
        };

    };
};