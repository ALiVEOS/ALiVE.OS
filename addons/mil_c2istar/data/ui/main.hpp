#include "common.hpp"

// GUI editor: configfile >> "C2Tablet"

class C2Tablet
{
    idd = 70001;
    movingEnable = true;
    onLoad = "[] call ALIVE_fnc_C2TabletOnLoad;";
    onUnload = "[] call ALIVE_fnc_C2TabletOnUnLoad;";

    class controlsBackground {

        class C2Tablet_background : RscPicture {
            idc = 70002;
            x = 0.142424 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.0632 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.73 * GUI_GRID_WAbs;
            h = 0.84 * GUI_GRID_HAbs;
            text = "x\alive\addons\main\data\ui\ALiVE_toughbook.paa";
            moving = 0;
        };

    };

    class controls
    {

        class C2Tablet_mainTitle : C2Tablet_RscText
        {
            idc = 70007;
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

        class C2Tablet_subMenuBackButton : C2Tablet_RscButton
        {
            idc = 70006;
            text = "Back";
            style = 0x02;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.7000 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
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
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.7350 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
            action = "closeDialog 0";
        };

        // #698 Terrain toggle - top-right of the header bezel (same toughbook as the other tablets),
        // toggles the tasking map (70022) between the textured satellite view and the plain schematic.
        class C2Tablet_TerrainButton : C2Tablet_RscRealButton
        {
            idc = 70003;
            x = 0.686 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.098 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0597643 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Terrain";
            periodFocus = 1e10;
            periodOver = 1e10;
            period = 1e10; // #698 freeze the focus blink too (period drives the pulse while focused; periodFocus/Over alone left it flashing until focus moved away)
            action = "[!(uinamespace getVariable ['C2TerrainMode', true])] call ALIVE_fnc_C2TabletSetTerrainMode";
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.384,0.439,0.341,1};
            colorFocused[] = {0.706,0.706,0.706,1};
            sizeEx = 0.5 * GUI_GRID_H;
        };

        class C2Tablet_currentTaskList : C2Tablet_RscGUIListBox
        {
            idc = 70025;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.35 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_createTaskButton : C2Tablet_RscButton
        {
            idc = 70016;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5150 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Create task";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_generateTaskButton : C2Tablet_RscButton
        {
            idc = 70038;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5480 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Generate a task";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_autoGenerateTaskButton : C2Tablet_RscButton
        {
            idc = 70048;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5820 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Auto generate tasks for my side";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingCurrentTaskListEditButton : C2Tablet_RscButton
        {
            idc = 70026;
            text = "Edit Task";
            style = 0x02;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6160 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingCurrentTaskListDeleteButton : C2Tablet_RscButton
        {
            idc = 70027;
            text = "Delete Task";
            style = 0x02;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6500 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskPlayerList : C2Tablet_RscGUIListBox
        {
            idc = 70011;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.13 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskSelectGroupButton : C2Tablet_RscButton
        {
            idc = 70014;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2900 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Select all group members";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskSelectedPlayerTitle : C2Tablet_RscText
        {
            idc = 70012;
            text = "Selected Players";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.3290 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskSelectedPlayerList : C2Tablet_RscGUIListBox
        {
            idc = 70013;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.3460 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.13 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskSelectedPlayerListDeleteButton : C2Tablet_RscButton
        {
            idc = 70015;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.4770 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Delete";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskSelectedPlayersClearButton : C2Tablet_RscButton
        {
            idc = 70029;
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5100 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.465 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Clear selected players";
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingAddTaskTitleEditTitle : C2Tablet_RscText
        {
            idc = 70018;
            text = "Task Title";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingAddTaskTitleEdit : C2Tablet_RscEdit
        {
            idc = 70019;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1770 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
        };

        class C2Tablet_taskingAddTaskDescriptionEditTitle : C2Tablet_RscText
        {
            idc = 70020;
            text = "Task Description";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2100 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingAddTaskDescriptionEdit : C2Tablet_RscEdit
        {
            idc = 70021;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2270 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.13 * GUI_GRID_HAbs;
            style = 16;
        };

        class C2Tablet_taskingAddTaskStateEditTitle : C2Tablet_RscText
        {
            idc = 70030;
            text = "Task State";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.3600 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingAddTaskStateEditList : C2Tablet_RscGUIListBox
        {
            idc = 70031;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.3770 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.1 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingMap : C2Tablet_RscMap
        {
            idc = 70022;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1584 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.4 * GUI_GRID_HAbs;
        };

        class C2Tablet_taskingAddTaskCreateButton : C2Tablet_RscButton
        {
            idc = 70023;
            text = "Create Task";
            style = 0x02;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6650 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingEditTaskUpdateButton : C2Tablet_RscButton
        {
            idc = 70028;
            text = "Update Task";
            style = 0x02;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6650 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingEditTaskManagePlayersButton : C2Tablet_RscButton
        {
            idc = 70032;
            text = "Assign Players";
            style = 0x02;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6300 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingAddTaskApplyEditTitle : C2Tablet_RscText
        {
            idc = 70033;
            text = "Applied to players";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.4800 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingAddTaskApplyEditList : C2Tablet_RscGUIListBox
        {
            idc = 70034;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.4970 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.06 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingAddTaskSetCurrent : C2Tablet_RscText
        {
            idc = 70035;
            text = "Set Current";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5600 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingAddTaskSetCurrentList : C2Tablet_RscGUIListBox
        {
            idc = 70036;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5770 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.04 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingAddTaskStatus : C2Tablet_RscText
        {
            idc = 70037;
            text = "STATUS";
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5800 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
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

        class C2Tablet_taskingAddTaskSelectParent : C2Tablet_RscText
        {
            idc = 70039;
            text = "Select Parent Task";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6250 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingCurrentParentTaskList : C2Tablet_RscGUIListBox
        {
            idc = 70040;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6420 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.11 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingGenerateTaskTypeEditTitle : C2Tablet_RscText
        {
            idc = 70041;
            text = "Task Type";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingGenerateTaskTypeEdit : C2Tablet_RscGUIListBox
        {
            idc = 70042;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1770 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.11 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingGenerateTaskCreateButton : C2Tablet_RscButton
        {
            idc = 70043;
            text = "Generate Task";
            style = 0x02;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6650 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.216525 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingGenerateTaskLocationEditTitle : C2Tablet_RscText
        {
            idc = 70044;
            text = "Task Location";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.2900 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingGenerateTaskLocationEdit : C2Tablet_RscGUIListBox
        {
            idc = 70045;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.3070 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.08 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingGenerateTaskFactionEditTitle : C2Tablet_RscText
        {
            idc = 70046;
            text = "Task Enemy Faction";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.3900 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingGenerateTaskFactionEdit : C2Tablet_RscGUIListBox
        {
            idc = 70047;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.4070 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.12 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingAutoGenerateTaskFactionEditTitle : C2Tablet_RscText
        {
            idc = 70049;
            text = "Task Enemy Faction";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1600 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingAutoGenerateTaskFactionEdit : C2Tablet_RscGUIListBox
        {
            idc = 70050;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.1770 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.2 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingAutoGenerateTaskCreateButton : C2Tablet_RscButton
        {
            idc = 70051;
            text = "Enable Tactical Tasks";
            style = 0x02;
            x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6650 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.105 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingAutoGenerateTaskStrategicCreateButton : C2Tablet_RscButton
        {
            idc = 70056;
            text = "Enable Strategic Tasks";
            style = 0x02;
            x = 0.631321 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6650 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.105 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            sizeEx = 0.5 * GUI_GRID_H;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class C2Tablet_taskingGenerateApplyEditTitle : C2Tablet_RscText
        {
            idc = 70052;
            text = "Applied to players";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5300 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingGenerateApplyEditList : C2Tablet_RscGUIListBox
        {
            idc = 70053;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.5470 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.06 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

        class C2Tablet_taskingGenerateSetCurrent : C2Tablet_RscText
        {
            idc = 70054;
            text = "Set Current";
            x = 0.271203 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6100 * GUI_GRID_HAbs + GUI_GRID_Y;
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

        class C2Tablet_taskingGenerateSetCurrentList : C2Tablet_RscGUIListBox
        {
            idc = 70055;
            x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6270 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.241271 * GUI_GRID_WAbs;
            h = 0.04 * GUI_GRID_HAbs;
            colorBackground[] = {0.173,0.173,0.173,1};
            colorActive[] = {0.384,0.439,0.341,1};
            sizeEx = 0.5 * GUI_GRID_H;
            rowHeight = 0.55 * GUI_GRID_H;
        };

    };
};
