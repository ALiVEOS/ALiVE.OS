// ORBAT Creator studio: Export tab (14700). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// While an export is being written, Check, Export mod, Copy config and
// Advanced answer S_BUSY_EXPORT and do nothing.
// Author: Jman

class ALiVE_FS_TabExport : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_EXPORT;
    x = FS_X(0.5);
    y = FS_Y(3.2);
    w = FS_W(16);
    h = FS_H(19.3);
    show = 0;

    class controls {

        // mod folder and full path
        class Path : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_E_PATH;
            y = FS_H(0);
            h = FS_H(1.9);
        };

        class NoRandom : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_E_NORANDOM;
            x = FS_W(0);
            y = FS_H(2);
            onCheckedChanged = "['norandom', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class NoRandomLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_EX_NORANDOM";
            tooltip = "$STR_ALIVE_FS_EX_NORANDOM";
            x = FS_W(1);
            y = FS_H(2);
            w = FS_W(15);
        };
        class Force : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_E_FORCE;
            x = FS_W(0);
            y = FS_H(3);
            onCheckedChanged = "['force', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class ForceLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_EX_FORCE_SHORT";
            tooltip = "$STR_ALIVE_FS_EX_FORCE";
            x = FS_W(1);
            y = FS_H(3);
            w = FS_W(15);
        };

        class Check : ALiVE_FS_RscButton {
            idc = FS_IDC_E_CHECK;
            text = "$STR_ALIVE_FS_EX_CHECK";
            x = FS_W(0);
            y = FS_H(4);
            w = FS_W(7.95);
            onButtonClick = "['check', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class Export : Check {
            idc = FS_IDC_E_EXPORT;
            text = "$STR_ALIVE_FS_EX_EXPORT";
            x = FS_W(8.05);
            onButtonClick = "['export', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class CopyConfig : Check {
            idc = FS_IDC_E_COPY;
            text = "$STR_ALIVE_FS_EX_COPY";
            x = FS_W(0);
            y = FS_H(5);
            onButtonClick = "['copy', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class CopyPath : Check {
            idc = FS_IDC_E_COPYPATH;
            text = "$STR_ALIVE_FS_EX_PATH";
            x = FS_W(8.05);
            y = FS_H(5);
            onButtonClick = "['copyPath', _this] call ALiVE_fnc_fsStudioTabExport";
        };
        class Advanced : Check {
            idc = FS_IDC_E_ADVANCED;
            text = "$STR_ALIVE_FS_EX_ADVANCED";
            x = FS_W(0);
            y = FS_H(6);
            onButtonClick = "['advanced', _this] call ALiVE_fnc_fsStudioTabExport";
        };

        // level picture and sentence
        class Results : ALiVE_FS_RscListBox {
            idc = FS_IDC_E_RESULTS;
            y = FS_H(7);
            h = FS_H(9.9);
        };

        // EX_DEPS
        class Deps : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_E_DEPS;
            y = FS_H(17);
            h = FS_H(2.3);
        };
    };
};
