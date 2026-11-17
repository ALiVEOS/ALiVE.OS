// ORBAT Creator studio: Units tab (14200). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// Author: Jman

class ALiVE_FS_TabUnits : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_UNITS;
    x = FS_X(0.5);
    y = FS_Y(3.2);
    w = FS_W(16);
    h = FS_H(19.3);
    show = 0;

    class controls {

        // name, class as right text, red when its base is not loaded
        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_U_LIST;
            y = FS_H(0);
            h = FS_H(5.9);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Add : ALiVE_FS_RscButton {
            idc = FS_IDC_U_ADD;
            text = "$STR_ALIVE_FS_BTN_ADD";
            x = FS_W(0);
            y = FS_H(6);
            w = FS_W(3.12);
            onButtonClick = "['add', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Duplicate : Add {
            idc = FS_IDC_U_DUPLICATE;
            text = "$STR_ALIVE_FS_BTN_DUPLICATE";
            x = FS_W(3.22);
            onButtonClick = "['duplicate', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Delete : Add {
            idc = FS_IDC_U_DELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            x = FS_W(6.44);
            onButtonClick = "['delete', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Up : Add {
            idc = FS_IDC_U_UP;
            text = "$STR_ALIVE_FS_BTN_UP";
            x = FS_W(9.66);
            onButtonClick = "['up', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Down : Add {
            idc = FS_IDC_U_DOWN;
            text = "$STR_ALIVE_FS_BTN_DOWN";
            x = FS_W(12.88);
            onButtonClick = "['down', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class NameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_NAME";
            y = FS_H(7);
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_U_NAME;
            x = FS_W(5);
            y = FS_H(7);
            onKillFocus = "['name', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class ClassLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CLASSNAME";
            y = FS_H(8);
        };
        class ClassName : ALiVE_FS_RscEdit {
            idc = FS_IDC_U_CLASS;
            x = FS_W(5);
            y = FS_H(8);
            w = FS_W(7);
            onKillFocus = "['class', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class ClassAuto : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_U_CLASSAUTO;
            x = FS_W(12.2);
            y = FS_H(8);
            onCheckedChanged = "['classAuto', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class ClassAutoLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_AUTO";
            x = FS_W(13.2);
            y = FS_H(8);
            w = FS_W(2.8);
        };

        class BaseLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_BASE";
            y = FS_H(9);
        };
        class Base : ALiVE_FS_RscText {
            idc = FS_IDC_U_BASE;
            x = FS_W(5);
            y = FS_H(9);
            w = FS_W(8);
        };
        class BaseChange : ALiVE_FS_RscButton {
            idc = FS_IDC_U_BASECHANGE;
            text = "$STR_ALIVE_FS_BTN_CHANGE";
            x = FS_W(13.2);
            y = FS_H(9);
            w = FS_W(2.8);
            onButtonClick = "['base', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class CategoryLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CATEGORY";
            y = FS_H(10);
        };
        class Category : ALiVE_FS_RscCombo {
            idc = FS_IDC_U_CATEGORY;
            x = FS_W(5);
            y = FS_H(10);
            onLBSelChanged = "['category', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        // Arsenal round trip
        class Loadout : ALiVE_FS_RscButton {
            idc = FS_IDC_U_LOADOUT;
            text = "$STR_ALIVE_FS_BTN_LOADOUT";
            x = FS_W(0);
            y = FS_H(11);
            w = FS_W(7.95);
            onButtonClick = "['open'] call ALiVE_fnc_fsStudioArsenal";
        };
        class Undo : Loadout {
            idc = FS_IDC_U_UNDO;
            text = "$STR_ALIVE_FS_BTN_UNDO_ARSENAL";
            x = FS_W(8.05);
            onButtonClick = "['undo'] call ALiVE_fnc_fsStudioArsenal";
        };

        class ArsenalLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_ARSENAL";
            y = FS_H(12);
        };
        class Arsenal : ALiVE_FS_RscCombo {
            idc = FS_IDC_U_ARSENAL;
            x = FS_W(5);
            y = FS_H(12);
            onLBSelChanged = "['arsenal', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class Fixed : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_U_FIXED;
            x = FS_W(0);
            y = FS_H(13);
            onCheckedChanged = "['fixed', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class FixedLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_FIXED_ID";
            x = FS_W(1);
            y = FS_H(13);
            w = FS_W(15);
        };

        // ID_READOUT
        class Identity : ALiVE_FS_RscText {
            idc = FS_IDC_U_IDENTITY;
            y = FS_H(14);
            w = FS_W(16);
            colorText[] = COLOR_GREY_TITLE_HARD;
        };

        // fsStudioLoadoutText
        class Summary : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_U_SUMMARY;
            y = FS_H(15);
            h = FS_H(4.3);
        };
    };
};
