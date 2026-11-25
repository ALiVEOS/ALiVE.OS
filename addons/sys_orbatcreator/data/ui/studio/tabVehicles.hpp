// ORBAT Creator studio: Vehicles tab (14300). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// Every change redraws the preview.
// Author: Jman

class ALiVE_FS_TabVehicles : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_VEHICLES;
    x = FS_X(0.5);
    y = FS_Y(FS_TOP);
    w = FS_W(16);
    h = FS_TAB_H;
    show = 0;

    class controls {

        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_V_LIST;
            y = FS_H(0);
            h = (FS_H(4.5) + FS_SP_VLIST);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Add : ALiVE_FS_RscButton {
            idc = FS_IDC_V_ADD;
            text = "$STR_ALIVE_FS_BTN_ADD";
            x = FS_B3_X(0);
            y = (FS_H(4.95) + FS_SP_VLIST);
            w = FS_B3_W;
            onButtonClick = "['add', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Duplicate : Add {
            idc = FS_IDC_V_DUPLICATE;
            text = "$STR_ALIVE_FS_BTN_DUPLICATE";
            x = FS_B3_X(1);
            onButtonClick = "['duplicate', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Delete : Add {
            idc = FS_IDC_V_DELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            x = FS_B3_X(2);
            onButtonClick = "['delete', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Up : Add {
            idc = FS_IDC_V_UP;
            text = "$STR_ALIVE_FS_BTN_UP";
            x = FS_B2_X(0);
            y = (FS_H(6.1) + FS_SP_VLIST);
            w = FS_B2_W;
            onButtonClick = "['up', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class Down : Add {
            idc = FS_IDC_V_DOWN;
            text = "$STR_ALIVE_FS_BTN_DOWN";
            x = FS_B2_X(1);
            y = (FS_H(6.1) + FS_SP_VLIST);
            w = FS_B2_W;
            onButtonClick = "['down', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class NameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_NAME";
            y = (FS_H(7.6) + FS_SP_VLIST);
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_V_NAME;
            x = FS_FIELD_X;
            y = (FS_H(7.6) + FS_SP_VLIST);
            onKillFocus = "['name', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class ClassLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CLASSNAME";
            y = (FS_H(8.75) + FS_SP_VLIST);
        };
        class ClassName : ALiVE_FS_RscEdit {
            idc = FS_IDC_V_CLASS;
            x = FS_FIELD_X;
            y = (FS_H(8.75) + FS_SP_VLIST);
            w = FS_NARROW_W;
            onKillFocus = "['class', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class ClassAuto : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_V_CLASSAUTO;
            tooltip = "$STR_ALIVE_FS_L_AUTO";
            x = FS_SIDE_X;
            y = (FS_H(8.75) + FS_SP_VLIST);
            onCheckedChanged = "['classAuto', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class ClassAutoLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_AUTO_SHORT";
            tooltip = "$STR_ALIVE_FS_L_AUTO";
            x = (FS_SIDE_X + FS_W(0.9));
            y = (FS_H(8.75) + FS_SP_VLIST);
            w = FS_W(2.1);
        };

        class BaseLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_BASE";
            y = (FS_H(9.9) + FS_SP_VLIST);
        };
        class Base : ALiVE_FS_RscText {
            idc = FS_IDC_V_BASE;
            x = FS_FIELD_X;
            y = (FS_H(9.9) + FS_SP_VLIST);
            w = FS_NARROW_W;
        };
        class BaseChange : ALiVE_FS_RscButton {
            idc = FS_IDC_V_BASECHANGE;
            text = "$STR_ALIVE_FS_BTN_CHANGE";
            x = FS_SIDE_X;
            y = (FS_H(9.9) + FS_SP_VLIST);
            w = FS_SIDE_W;
            onButtonClick = "['base', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class CategoryLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CATEGORY";
            y = (FS_H(11.05) + FS_SP_VLIST);
        };
        class Category : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_CATEGORY;
            x = FS_FIELD_X;
            y = (FS_H(11.05) + FS_SP_VLIST);
            w = FS_NARROW_W;
            onLBSelChanged = "['category', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        // written in an optional part, which loads only with the mods it needs
        class Optional : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_V_OPTIONAL;
            tooltip = "$STR_ALIVE_FS_OPT_TIP";
            x = FS_SIDE_X;
            y = (FS_H(11.05) + FS_SP_VLIST);
            onCheckedChanged = "['optional', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };
        class OptionalLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_V_OPTIONALLABEL;
            text = "$STR_ALIVE_FS_U_OPTIONAL";
            tooltip = "$STR_ALIVE_FS_OPT_TIP";
            x = (FS_SIDE_X + FS_W(0.9));
            y = (FS_H(11.05) + FS_SP_VLIST);
            w = FS_W(2.1);
        };

        // As the base vehicle, then the faction's units
        class CrewLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CREW";
            y = (FS_H(12.2) + FS_SP_VLIST);
        };
        class Crew : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_CREW;
            x = FS_FIELD_X;
            y = (FS_H(12.2) + FS_SP_VLIST);
            onLBSelChanged = "['crew', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // seat name and gunner
        class SeatsLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_SEATS";
            y = (FS_H(13.7) + FS_SP_VLIST);
            w = FS_W(16);
        };
        class Seats : ALiVE_FS_RscListBox {
            idc = FS_IDC_V_SEATS;
            y = (FS_H(14.85) + FS_SP_VLIST);
            h = (FS_H(3.6) + FS_SP_VSEATS);
            onLBSelChanged = "['seat', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        class GunnerLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_GUNNER";
            y = (FS_H(18.57) + FS_SP_VLIST + FS_SP_VSEATS);
        };
        class Gunner : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_GUNNER;
            x = FS_FIELD_X;
            y = (FS_H(18.57) + FS_SP_VLIST + FS_SP_VSEATS);
            onLBSelChanged = "['gunner', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // Default, then the base's TextureSources
        class TextureLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_TEXTURE";
            y = (FS_H(20.07) + FS_SP_VLIST + FS_SP_VSEATS);
        };
        class Texture : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_TEXTURE;
            x = FS_FIELD_X;
            y = (FS_H(20.07) + FS_SP_VLIST + FS_SP_VSEATS);
            onLBSelChanged = "['texture', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // As the base vehicle, then the base's pylon presets (off when it has no pylons)
        class PylonsLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_PYLONS";
            y = (FS_H(21.22) + FS_SP_VLIST + FS_SP_VSEATS);
        };
        class Pylons : ALiVE_FS_RscCombo {
            idc = FS_IDC_V_PYLONS;
            x = FS_FIELD_X;
            y = (FS_H(21.22) + FS_SP_VLIST + FS_SP_VSEATS);
            onLBSelChanged = "['pylons', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // the base's parts (animationSources Eden shows), a click turns one on or off
        class PartsLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_PARTS";
            y = (FS_H(22.37) + FS_SP_VLIST + FS_SP_VSEATS);
        };
        class Parts : ALiVE_FS_RscListBox {
            idc = FS_IDC_V_PARTS;
            x = FS_FIELD_X;
            y = (FS_H(22.37) + FS_SP_VLIST + FS_SP_VSEATS);
            w = FS_W(16) - FS_FIELD_X;
            h = FS_H(5.4);
            onLBSelChanged = "['part', _this] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // what the vehicle carries: a summary and the cargo popup; the tab puts the row under the parts list
        class CargoLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_V_CARGOLABEL;
            text = "$STR_ALIVE_FS_L_CARGO";
            y = (FS_H(26.92) + FS_SP_VLIST + FS_SP_VSEATS);
        };
        class Cargo : ALiVE_FS_RscText {
            idc = FS_IDC_V_CARGO;
            x = FS_FIELD_X;
            y = (FS_H(26.92) + FS_SP_VLIST + FS_SP_VSEATS);
            w = FS_NARROW_W;
        };
        class CargoEdit : ALiVE_FS_RscButton {
            idc = FS_IDC_V_CARGOEDIT;
            text = "$STR_ALIVE_FS_BTN_EDIT";
            x = FS_SIDE_X;
            y = (FS_H(26.92) + FS_SP_VLIST + FS_SP_VSEATS);
            w = FS_SIDE_W;
            onButtonClick = "['open'] call ALiVE_fnc_fsStudioCargo";
        };

        // the Init Code: a short view of it and the popup; the tab puts the row under the cargo row
        class InitLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_V_INITLABEL;
            text = "$STR_ALIVE_FS_L_INITCODE";
            tooltip = "$STR_ALIVE_FS_INITCODE_TIP_V";
            y = (FS_H(28.07) + FS_SP_VLIST + FS_SP_VSEATS);
        };
        class Init : ALiVE_FS_RscText {
            idc = FS_IDC_V_INIT;
            tooltip = "$STR_ALIVE_FS_INITCODE_TIP_V";
            x = FS_FIELD_X;
            y = (FS_H(28.07) + FS_SP_VLIST + FS_SP_VSEATS);
            w = FS_NARROW_W;
        };
        class InitEdit : ALiVE_FS_RscButton {
            idc = FS_IDC_V_INITEDIT;
            text = "$STR_ALIVE_FS_BTN_EDIT";
            tooltip = "$STR_ALIVE_FS_INITCODE_TIP_V";
            x = FS_SIDE_X;
            y = (FS_H(28.07) + FS_SP_VLIST + FS_SP_VSEATS);
            w = FS_SIDE_W;
            onButtonClick = "['initCode', []] call ALiVE_fnc_fsStudioTabVehicles";
        };

        // W_ALIVE_CREW, shown by the tab when it applies
        class Note : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_V_NOTE;
            y = (FS_H(29.22) + FS_SP_VLIST + FS_SP_VSEATS);
            h = FS_H(1.49);
        };
    };
};
