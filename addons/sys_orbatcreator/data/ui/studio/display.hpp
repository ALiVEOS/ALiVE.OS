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

        // the preview's mouse controls, bottom left of the view beside the panel (ACE's status icons cover the bottom
        // right); under the mouse area, so it never takes a click
        class PreviewHint : ALiVE_FS_RscText {
            idc = -1;
            style = 0;
            text = "$STR_ALIVE_FS_PREVIEW_HINT";
            x = FS_X(17.5);
            y = (safezoneY + safezoneH - FS_H(1.5));
            w = FS_W(22.5);
            h = FS_ROW_H;
            colorText[] = {0.85, 0.85, 0.85, 0.8};
            colorBackground[] = COLOR_BLACK(0);
        };

        // the only control with mouse-button handlers: left drag moves, right drag turns, wheel zooms
        class MouseArea : ALiVE_FS_RscText {
            idc = FS_IDC_MOUSE;
            style = 16;
            x = FS_X(17);
            y = safezoneY;
            w = (safezoneW - FS_PANEL_W);
            h = safezoneH;
            colorBackground[] = COLOR_BLACK(0);
            onMouseButtonDown = "['down', _this] call ALiVE_fnc_fsStudioCamera";
            onMouseButtonUp = "['dragEnd'] call ALiVE_fnc_fsStudioHelp; ['up', _this] call ALiVE_fnc_fsStudioCamera";
            onMouseMoving = "['move', _this] call ALiVE_fnc_fsStudioCamera";
            onMouseZChanged = "['wheel', _this] call ALiVE_fnc_fsStudioCamera";
            onMouseButtonDblClick = "if ((_this select 1) == 0) then { ['focus'] call ALiVE_fnc_fsStudioCamera }";
        };

        class Panel : ALiVE_FS_RscBackground {
            idc = FS_IDC_PANEL;
            x = FS_X(0);
            y = safezoneY;
            w = FS_PANEL_W;
            h = safezoneH;
        };

        // the header: one picture made from the website's own header (its metallic ALiVE wordmark and the orange
        // ORBAT CREATOR capsule), 8:1 with the artwork at the left. fsStudioOpen sizes it to its own shape
        class Logo : ALiVE_FS_RscText {
            idc = FS_IDC_LOGO;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\fs_header64_ca.paa";
            // as tall as FS_HEAD_H: the tag's capitals are 0.304 of the picture, so they match the tab labels;
            // w is the most it may take, short of the ? and Exit buttons
            x = FS_X(0.4);
            y = FS_Y(0.1);
            w = FS_W(13.2);
            h = FS_H(FS_HEAD_H);
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = COLOR_BLACK(0);
        };

        // "Faction: <tag>", and the unsaved mark in the accent colour, filled by fsStudioStatus
        class FactionName : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_FACTION;
            x = FS_X(0.5);
            y = FS_Y(FS_FACTION_Y);
            w = FS_W(16);
            h = FS_H(FS_FACTION_H);
            colorBackground[] = COLOR_BLACK(0);
        };

        // help for the tab on show (ALiVE_fnc_fsStudioHelp)
        class Help : ALiVE_FS_RscButton {
            idc = FS_IDC_HELP;
            text = "$STR_ALIVE_FS_HELP_BTN";
            tooltip = "$STR_ALIVE_FS_HELP_BTN_TIP";
            x = FS_X(13.7);
            y = FS_Y(0.1 + (FS_HEAD_H - 0.9) / 2);
            w = FS_W(1.0);
            onButtonClick = "['toggle'] call ALiVE_fnc_fsStudioHelp";
        };
        class Exit : ALiVE_FS_RscButton {
            idc = FS_IDC_EXIT;
            text = "$STR_ALIVE_FS_BTN_EXIT";
            x = FS_X(14.8);
            y = FS_Y(0.1 + (FS_HEAD_H - 0.9) / 2);
            w = FS_W(1.7);
            onButtonClick = "['exit'] call ALiVE_fnc_fsStudioClose";
        };

        // tab buttons: these places are a fallback; fsStudioOpen lays the six out again from the width of
        // each word on screen, so they always fit the 16-cell row
        class TabFaction : ALiVE_FS_RscButton {
            idc = FS_IDC_TAB_FACTION;
            text = "$STR_ALIVE_FS_TAB_FACTION";
            x = FS_X(0.5);
            y = FS_Y(FS_TABS_Y);
            w = FS_W(2.8);
            h = FS_H(FS_TABS_H);
            size = FS_TEXT;
            sizeEx = FS_TEXT;
            // centred in its own height (see ALiVE_FS_RscButton)
            class TextPos {
                left = 0;
                top = ((FS_H(FS_TABS_H)) - (FS_TEXT)) / 2;
                right = 0;
                bottom = 0;
            };
            // PuristaLight's I is a hairline that can vanish at this size ("UNTS"); the medium weight keeps it
            class Attributes {
                font = "PuristaMedium";
                color = "#E5E5E5";
                align = "center";
                shadow = "false";
            };
            onButtonClick = "['faction'] call ALiVE_fnc_fsStudioTab";
        };
        class TabUnits : TabFaction {
            idc = FS_IDC_TAB_UNITS;
            text = "$STR_ALIVE_FS_TAB_UNITS";
            x = FS_X(3.4);
            w = FS_W(2.2);
            onButtonClick = "['units'] call ALiVE_fnc_fsStudioTab";
        };
        class TabVehicles : TabFaction {
            idc = FS_IDC_TAB_VEHICLES;
            text = "$STR_ALIVE_FS_TAB_VEHICLES";
            x = FS_X(5.7);
            w = FS_W(3.25);
            onButtonClick = "['vehicles'] call ALiVE_fnc_fsStudioTab";
        };
        class TabGroups : TabFaction {
            idc = FS_IDC_TAB_GROUPS;
            text = "$STR_ALIVE_FS_TAB_GROUPS";
            x = FS_X(9.05);
            w = FS_W(2.5);
            onButtonClick = "['groups'] call ALiVE_fnc_fsStudioTab";
        };
        class TabAlive : TabFaction {
            idc = FS_IDC_TAB_ALIVE;
            text = "$STR_ALIVE_FS_TAB_ALIVE";
            x = FS_X(11.65);
            w = FS_W(2.25);
            onButtonClick = "['alive'] call ALiVE_fnc_fsStudioTab";
        };
        class TabExport : TabFaction {
            idc = FS_IDC_TAB_EXPORT;
            text = "$STR_ALIVE_FS_TAB_EXPORT";
            x = FS_X(14.0);
            w = FS_W(2.5);
            onButtonClick = "['export'] call ALiVE_fnc_fsStudioTab";
        };

        // one controls group per tab; fsStudioTab shows one and hides the rest
        class GroupFaction : ALiVE_FS_TabFaction {};
        class GroupUnits : ALiVE_FS_TabUnits {};
        class GroupVehicles : ALiVE_FS_TabVehicles {};
        class GroupGroups : ALiVE_FS_TabGroups {};
        class GroupAlive : ALiVE_FS_TabAlive {};
        class GroupExport : ALiVE_FS_TabExport {};

        // status line, two lines, coloured by fsStudioStatus
        class Status : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_STATUS;
            x = FS_X(0.5);
            // at the bottom of the screen, under the tab (FS_TAB_H)
            y = (safezoneY + safezoneH - FS_GH * (FS_STATUS_H + 0.2));
            w = FS_W(16);
            h = FS_H(FS_STATUS_H);
            colorBackground[] = COLOR_BLACK(0.4);
        };

        // class and name of what is on the stage
        class Caption : ALiVE_FS_RscText {
            idc = FS_IDC_CAPTION;
            // top left of the view, beside the panel: the top right is the weapon HUD's
            style = 0;
            x = FS_X(17.5);
            y = FS_Y(0.2);
            w = FS_W(15);
            h = FS_H(0.9);
            shadow = 1;
        };
    };
};
