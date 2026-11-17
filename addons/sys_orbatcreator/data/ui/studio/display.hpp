// ORBAT Creator studio: the main display (idd 14000).
// A 17-wide panel on the left, the preview on the right.
// Controls are declared in the order the Tab key visits them; the preview
// mouse area is first so it lies under everything.
// Author: Jman

class ALiVE_FS_Studio {
    idd = FS_IDD_STUDIO;
    movingEnable = 0;
    enableSimulation = 1;
    onUnload = "['unload', _this] call ALiVE_fnc_fsStudioClose";
    onKeyDown = "_this call ALiVE_fnc_fsStudioKeys";

    class controlsBackground {};

    class controls {

        // the only control with mouse-button handlers: drag turns, wheel zooms
        class MouseArea : ALiVE_FS_RscText {
            idc = FS_IDC_MOUSE;
            style = 16;
            x = FS_X(17);
            y = safezoneY;
            w = (safezoneW - FS_PANEL_W);
            h = safezoneH;
            colorBackground[] = COLOR_BLACK(0);
            onMouseButtonDown = "['down', _this] call ALiVE_fnc_fsStudioCamera";
            onMouseButtonUp = "['up', _this] call ALiVE_fnc_fsStudioCamera";
            onMouseMoving = "['move', _this] call ALiVE_fnc_fsStudioCamera";
            onMouseZChanged = "['wheel', _this] call ALiVE_fnc_fsStudioCamera";
        };

        class Panel : ALiVE_FS_RscBackground {
            idc = FS_IDC_PANEL;
            x = FS_X(0);
            y = safezoneY;
            w = FS_PANEL_W;
            h = safezoneH;
        };

        class Title : ALiVE_FS_RscText {
            idc = FS_IDC_TITLE;
            text = "$STR_ALIVE_FS_NAME";
            x = FS_X(0.5);
            y = FS_Y(0.2);
            w = FS_W(10);
            h = FS_H(0.8);
            sizeEx = (FS_GH * 1.0);
            colorText[] = COLOR_GREEN_HARD;
        };

        // faction name and unsaved mark, filled by the studio
        class FactionName : ALiVE_FS_RscText {
            idc = FS_IDC_FACTION;
            x = FS_X(0.5);
            y = FS_Y(1.0);
            w = FS_W(12);
            h = FS_H(0.8);
            colorText[] = COLOR_GREY_TITLE_HARD;
        };

        class Exit : ALiVE_FS_RscButton {
            idc = FS_IDC_EXIT;
            text = "$STR_ALIVE_FS_BTN_EXIT";
            x = FS_X(13.5);
            y = FS_Y(0.2);
            w = FS_W(3);
            onButtonClick = "['exit'] call ALiVE_fnc_fsStudioClose";
        };

        // tab buttons
        class TabFaction : ALiVE_FS_RscButton {
            idc = FS_IDC_TAB_FACTION;
            text = "$STR_ALIVE_FS_TAB_FACTION";
            x = FS_X(0.5);
            y = FS_Y(2.0);
            w = FS_W(3.1);
            h = FS_H(1);
            onButtonClick = "['faction'] call ALiVE_fnc_fsStudioTab";
        };
        class TabUnits : TabFaction {
            idc = FS_IDC_TAB_UNITS;
            text = "$STR_ALIVE_FS_TAB_UNITS";
            x = FS_X(3.7);
            onButtonClick = "['units'] call ALiVE_fnc_fsStudioTab";
        };
        class TabVehicles : TabFaction {
            idc = FS_IDC_TAB_VEHICLES;
            text = "$STR_ALIVE_FS_TAB_VEHICLES";
            x = FS_X(6.9);
            onButtonClick = "['vehicles'] call ALiVE_fnc_fsStudioTab";
        };
        class TabGroups : TabFaction {
            idc = FS_IDC_TAB_GROUPS;
            text = "$STR_ALIVE_FS_TAB_GROUPS";
            x = FS_X(10.1);
            onButtonClick = "['groups'] call ALiVE_fnc_fsStudioTab";
        };
        class TabExport : TabFaction {
            idc = FS_IDC_TAB_EXPORT;
            text = "$STR_ALIVE_FS_TAB_EXPORT";
            x = FS_X(13.3);
            onButtonClick = "['export'] call ALiVE_fnc_fsStudioTab";
        };

        // one controls group per tab; fsStudioTab shows one and hides the rest
        class GroupFaction : ALiVE_FS_TabFaction {};
        class GroupUnits : ALiVE_FS_TabUnits {};
        class GroupVehicles : ALiVE_FS_TabVehicles {};
        class GroupGroups : ALiVE_FS_TabGroups {};
        class GroupExport : ALiVE_FS_TabExport {};

        // status line, two lines, coloured by fsStudioStatus
        class Status : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_STATUS;
            x = FS_X(0.5);
            y = FS_Y(22.7);
            w = FS_W(16);
            h = FS_H(2.1);
            colorBackground[] = COLOR_BLACK(0.4);
        };

        // class and name of what is on the stage
        class Caption : ALiVE_FS_RscText {
            idc = FS_IDC_CAPTION;
            style = 1;
            x = (safezoneX + safezoneW - FS_W(15.5));
            y = FS_Y(0.2);
            w = FS_W(15);
            h = FS_H(0.9);
            shadow = 1;
        };
    };
};
