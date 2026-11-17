// ORBAT Creator studio: Vehicles tab (14300). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// Every change redraws the preview.
// Author: Jman

class ALiVE_FS_TabVehicles : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_VEHICLES;
    x = FS_X(0.5);
    y = FS_Y(3.2);
    w = FS_W(16);
    h = FS_H(19.3);
    show = 0;

    class controls {

        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_V_LIST;
            y = FS_H(0);
            h = FS_H(4.9);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Add : ALiVE_FS_RscButton {
            idc = FS_IDC_V_ADD;
            text = "$STR_ALIVE_FS_BTN_ADD";
            x = FS_W(0);
            y = FS_H(5);
            w = FS_W(3.12);
            onButtonClick = "['add', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Duplicate : Add {
            idc = FS_IDC_V_DUPLICATE;
            text = "$STR_ALIVE_FS_BTN_DUPLICATE";
            x = FS_W(3.22);
            onButtonClick = "['duplicate', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Delete : Add {
            idc = FS_IDC_V_DELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            x = FS_W(6.44);
            onButtonClick = "['delete', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Up : Add {
            idc = FS_IDC_V_UP;
            text = "$STR_ALIVE_FS_BTN_UP";
            x = FS_W(9.66);
            onButtonClick = "['up', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Down : Add {
            idc = FS_IDC_V_DOWN;
            text = "$STR_ALIVE_FS_BTN_DOWN";
            x = FS_W(12.88);
            onButtonClick = "['down', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class NameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_NAME";
            y = FS_H(6);
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_V_NAME;
            x = FS_W(5);
            y = FS_H(6);
            onKillFocus = "['name', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class ClassLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CLASSNAME";
            y = FS_H(7);
        };
        class ClassName : ALiVE_FS_RscEdit {
            idc = FS_IDC_V_CLASS;
            x = FS_W(5);
            y = FS_H(7);
            w = FS_W(7);
            onKillFocus = "['class', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class ClassAuto : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_V_CLASSAUTO;
            x = FS_W(12.2);
            y = FS_H(7);
            onCheckedChanged = "['classAuto', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class ClassAutoLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_AUTO";
            x = FS_W(13.2);
            y = FS_H(7);
            w = FS_W(2.8);
        };

        class BaseLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_BASE";
            y = FS_H(8);
        };
        class Base : ALiVE_FS_RscText {
            idc = FS_IDC_V_BASE;
            x = FS_W(5);
            y = FS_H(8);
            w = FS_W(8);
        };
        class BaseChange : ALiVE_FS_RscButton {
            idc = FS_IDC_V_BASECHANGE;
            text = "$STR_ALIVE_FS_BTN_CHANGE";
            x = FS_W(13.2);
            y = FS_H(8);
            w = FS_W(2.8);
            onButtonClick = "['base', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class CategoryLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CATEGORY";
            y = FS_H(9);
        };
        class Category : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_CATEGORY;
            x = FS_W(5);
            y = FS_H(9);
            onLBSelChanged = "['category', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // As the base vehicle, then the faction's units
        class CrewLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CREW";
            y = FS_H(10);
        };
        class Crew : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_CREW;
            x = FS_W(5);
            y = FS_H(10);
            onLBSelChanged = "['crew', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // seat name and gunner
        class SeatsLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_SEATS";
            y = FS_H(11);
            w = FS_W(16);
        };
        class Seats : ALiVE_FS_RscListBox {
            idc = FS_IDC_V_SEATS;
            y = FS_H(12);
            h = FS_H(2.9);
            onLBSelChanged = "['seat', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class GunnerLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_GUNNER";
            y = FS_H(15);
        };
        class Gunner : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_GUNNER;
            x = FS_W(5);
            y = FS_H(15);
            onLBSelChanged = "['gunner', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // Default, then the base's TextureSources
        class TextureLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_TEXTURE";
            y = FS_H(16);
        };
        class Texture : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_TEXTURE;
            x = FS_W(5);
            y = FS_H(16);
            onLBSelChanged = "['texture', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // W_ALIVE_CREW, shown by the tab when it applies
        class Note : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_V_NOTE;
            y = FS_H(17);
            h = FS_H(2.3);
        };
    };
};
