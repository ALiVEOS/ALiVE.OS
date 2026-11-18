// ORBAT Creator studio: Export tab (14700). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// While an export is being written, Check, Export mod, Copy config and
// Advanced answer S_BUSY_EXPORT and do nothing.
// Author: Jman

class ALiVE_FS_TabExport : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_EXPORT;
    x = FS_X(0.5);
    y = FS_Y(FS_TOP);
    w = FS_W(16);
    h = FS_TAB_H;
    show = 0;

    class controls {

        // mod folder and full path; the placeholder shows until the tab fills it
        class PathLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_MODFOLDER";
            y = FS_H(0);
            w = FS_W(16);
        };
        class Path : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_E_PATH;
            text = "$STR_ALIVE_FS_EX_PATH_NONE";
            y = FS_H(1.15);
            h = FS_H(2.18);
            colorBackground[] = COLOR_BLACK(0.5);
        };

        class NoRandom : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_E_NORANDOM;
            tooltip = "$STR_ALIVE_FS_EX_NORANDOM";
            x = FS_W(0);
            y = FS_H(3.8);
            onCheckedChanged = "['norandom', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class NoRandomLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_EX_NORANDOM_SHORT";
            tooltip = "$STR_ALIVE_FS_EX_NORANDOM";
            x = FS_W(1);
            y = FS_H(3.8);
            w = FS_W(15);
        };
        class Force : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_E_FORCE;
            tooltip = "$STR_ALIVE_FS_EX_FORCE";
            x = FS_W(0);
            y = FS_H(4.95);
            onCheckedChanged = "['force', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class ForceLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_EX_FORCE_SHORT";
            tooltip = "$STR_ALIVE_FS_EX_FORCE";
            x = FS_W(1);
            y = FS_H(4.95);
            w = FS_W(15);
        };

        class Check : ALiVE_FS_RscButton {
            idc = FS_IDC_E_CHECK;
            text = "$STR_ALIVE_FS_EX_CHECK";
            x = FS_B2_X(0);
            y = FS_H(6.45);
            w = FS_B2_W;
            onButtonClick = "['check', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class Export : Check {
            idc = FS_IDC_E_EXPORT;
            text = "$STR_ALIVE_FS_EX_EXPORT";
            x = FS_B2_X(1);
            onButtonClick = "['export', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class CopyConfig : Check {
            idc = FS_IDC_E_COPY;
            text = "$STR_ALIVE_FS_EX_COPY";
            x = FS_B2_X(0);
            y = FS_H(7.6);
            onButtonClick = "['copy', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class CopyPath : Check {
            idc = FS_IDC_E_COPYPATH;
            text = "$STR_ALIVE_FS_EX_PATH_SHORT";
            tooltip = "$STR_ALIVE_FS_EX_PATH";
            x = FS_B2_X(1);
            y = FS_H(7.6);
            onButtonClick = "['copyPath', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        // a row of its own, full width
        class Advanced : Check {
            idc = FS_IDC_E_ADVANCED;
            text = "$STR_ALIVE_FS_EX_ADVANCED";
            x = FS_W(0);
            y = FS_H(8.75);
            w = FS_W(16);
            onButtonClick = "['advanced', _this] call ALiVE_fnc_fsStudioTabExport";
        };

        // the results: a box with one structured-text row per message, made by fsStudioTabExport "refresh",
        // so every heading starts at one margin, the file names at one indent, and a long message wraps
        // under its own first line
        class ResultsBack : ALiVE_FS_RscText {
            idc = -1;
            x = 0;
            y = FS_H(10.25);
            w = FS_W(16);
            h = (FS_H(9.9) + FS_SP_ERESULTS);
            colorBackground[] = COLOR_BLACK(0.5);
        };
        class Results : ALiVE_FS_RscGroup {
            idc = FS_IDC_E_RESULTS;
            y = FS_H(10.25);
            h = (FS_H(9.9) + FS_SP_ERESULTS);
        };

        // EX_DEPS
        class Deps : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_E_DEPS;
            y = (FS_H(20.95) + FS_SP_ERESULTS);
            h = FS_H(2.64);
        };
    };
};
