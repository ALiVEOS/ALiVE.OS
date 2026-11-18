// ORBAT Creator studio: Units tab (14200). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// Author: Jman

class ALiVE_FS_TabUnits : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_UNITS;
    x = FS_X(0.5);
    y = FS_Y(FS_TOP);
    w = FS_W(16);
    h = FS_TAB_H;
    show = 0;

    class controls {

        // name, class as right text, red when its base is not loaded
        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_U_LIST;
            y = FS_H(0);
            h = (FS_H(5.4) + FS_SP_ULIST);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Add : ALiVE_FS_RscButton {
            idc = FS_IDC_U_ADD;
            text = "$STR_ALIVE_FS_BTN_ADD";
            x = FS_B3_X(0);
            y = (FS_H(6.1) + FS_SP_ULIST);
            w = FS_B3_W;
            onButtonClick = "['add', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Duplicate : Add {
            idc = FS_IDC_U_DUPLICATE;
            text = "$STR_ALIVE_FS_BTN_DUPLICATE";
            x = FS_B3_X(1);
            onButtonClick = "['duplicate', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Delete : Add {
            idc = FS_IDC_U_DELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            x = FS_B3_X(2);
            onButtonClick = "['delete', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Up : Add {
            idc = FS_IDC_U_UP;
            text = "$STR_ALIVE_FS_BTN_UP";
            x = FS_B2_X(0);
            y = (FS_H(7.25) + FS_SP_ULIST);
            w = FS_B2_W;
            onButtonClick = "['up', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class Down : Add {
            idc = FS_IDC_U_DOWN;
            text = "$STR_ALIVE_FS_BTN_DOWN";
            x = FS_B2_X(1);
            y = (FS_H(7.25) + FS_SP_ULIST);
            w = FS_B2_W;
            onButtonClick = "['down', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class NameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_NAME";
            y = (FS_H(8.75) + FS_SP_ULIST);
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_U_NAME;
            x = FS_FIELD_X;
            y = (FS_H(8.75) + FS_SP_ULIST);
            onKillFocus = "['name', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class ClassLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CLASSNAME";
            y = (FS_H(9.9) + FS_SP_ULIST);
        };
        class ClassName : ALiVE_FS_RscEdit {
            idc = FS_IDC_U_CLASS;
            x = FS_FIELD_X;
            y = (FS_H(9.9) + FS_SP_ULIST);
            w = FS_NARROW_W;
            onKillFocus = "['class', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class ClassAuto : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_U_CLASSAUTO;
            tooltip = "$STR_ALIVE_FS_L_AUTO";
            x = FS_SIDE_X;
            y = (FS_H(9.9) + FS_SP_ULIST);
            onCheckedChanged = "['classAuto', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class ClassAutoLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_AUTO_SHORT";
            tooltip = "$STR_ALIVE_FS_L_AUTO";
            x = (FS_SIDE_X + FS_W(0.9));
            y = (FS_H(9.9) + FS_SP_ULIST);
            w = FS_W(2.1);
        };

        class BaseLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_BASE";
            y = (FS_H(11.05) + FS_SP_ULIST);
        };
        class Base : ALiVE_FS_RscText {
            idc = FS_IDC_U_BASE;
            x = FS_FIELD_X;
            y = (FS_H(11.05) + FS_SP_ULIST);
            w = FS_NARROW_W;
        };
        class BaseChange : ALiVE_FS_RscButton {
            idc = FS_IDC_U_BASECHANGE;
            text = "$STR_ALIVE_FS_BTN_CHANGE";
            x = FS_SIDE_X;
            y = (FS_H(11.05) + FS_SP_ULIST);
            w = FS_SIDE_W;
            onButtonClick = "['base', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class CategoryLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CATEGORY";
            y = (FS_H(12.2) + FS_SP_ULIST);
        };
        class Category : ALiVE_FS_RscCombo {
            idc = FS_IDC_U_CATEGORY;
            x = FS_FIELD_X;
            y = (FS_H(12.2) + FS_SP_ULIST);
            w = FS_NARROW_W;
            onLBSelChanged = "['category', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        // written in an optional part, which loads only with the mods it needs
        class Optional : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_U_OPTIONAL;
            tooltip = "$STR_ALIVE_FS_OPT_TIP";
            x = FS_SIDE_X;
            y = (FS_H(12.2) + FS_SP_ULIST);
            onCheckedChanged = "['optional', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class OptionalLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_U_OPTIONALLABEL;
            text = "$STR_ALIVE_FS_U_OPTIONAL";
            tooltip = "$STR_ALIVE_FS_OPT_TIP";
            x = (FS_SIDE_X + FS_W(0.9));
            y = (FS_H(12.2) + FS_SP_ULIST);
            w = FS_W(2.1);
        };

        // Arsenal round trip
        class Loadout : ALiVE_FS_RscButton {
            idc = FS_IDC_U_LOADOUT;
            text = "$STR_ALIVE_FS_BTN_LOADOUT";
            x = FS_B2_X(0);
            y = (FS_H(13.7) + FS_SP_ULIST);
            w = FS_B2_W;
            onButtonClick = "['open'] call ALiVE_fnc_fsStudioArsenal";
        };
        class Undo : Loadout {
            idc = FS_IDC_U_UNDO;
            text = "$STR_ALIVE_FS_BTN_UNDO_ARSENAL_SHORT";
            tooltip = "$STR_ALIVE_FS_BTN_UNDO_ARSENAL";
            x = FS_B2_X(1);
            onButtonClick = "['undo'] call ALiVE_fnc_fsStudioArsenal";
        };

        class ArsenalLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_ARSENAL";
            y = (FS_H(14.85) + FS_SP_ULIST);
        };
        class Arsenal : ALiVE_FS_RscCombo {
            idc = FS_IDC_U_ARSENAL;
            x = FS_FIELD_X;
            y = (FS_H(14.85) + FS_SP_ULIST);
            onLBSelChanged = "['arsenal', _this] call ALiVE_fnc_fsStudioTabUnits";
        };

        class Fixed : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_U_FIXED;
            x = FS_W(0);
            y = (FS_H(16) + FS_SP_ULIST);
            onCheckedChanged = "['fixed', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class FixedLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_FIXED_ID";
            x = FS_W(1);
            y = (FS_H(16) + FS_SP_ULIST);
            w = FS_W(15);
        };

        // ID_READOUT
        class Identity : ALiVE_FS_RscText {
            idc = FS_IDC_U_IDENTITY;
            y = (FS_H(17.15) + FS_SP_ULIST);
            w = FS_W(16);
            colorText[] = COLOR_GREY_TITLE_HARD;
        };

        // fsStudioLoadoutText
        class Summary : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_U_SUMMARY;
            y = (FS_H(18.65) + FS_SP_ULIST);
            h = FS_H(4.94);
        };

        // gear pools he wears, then Roll and Reset on the preview; placed under the summary by the tab
        class PoolsLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_U_POOLSLABEL;
            text = "$STR_ALIVE_FS_L_POOLS";
            y = (FS_H(23.94) + FS_SP_ULIST);
        };
        class Pools : ALiVE_FS_RscText {
            idc = FS_IDC_U_POOLS;
            x = FS_FIELD_X;
            y = (FS_H(23.94) + FS_SP_ULIST);
            w = FS_NARROW_W;
        };
        class PoolsEdit : ALiVE_FS_RscButton {
            idc = FS_IDC_U_POOLSEDIT;
            text = "$STR_ALIVE_FS_BTN_EDIT";
            x = FS_SIDE_X;
            y = (FS_H(23.94) + FS_SP_ULIST);
            w = FS_SIDE_W;
            onButtonClick = "['open'] call ALiVE_fnc_fsStudioPools";
        };
        class Roll : ALiVE_FS_RscButton {
            idc = FS_IDC_U_ROLL;
            text = "$STR_ALIVE_FS_PL_ROLL";
            tooltip = "$STR_ALIVE_FS_PL_ROLL_TIP";
            x = FS_B2_X(0);
            y = (FS_H(25.09) + FS_SP_ULIST);
            w = FS_B2_W;
            onButtonClick = "['roll'] call ALiVE_fnc_fsStudioPools";
        };
        class Unroll : Roll {
            idc = FS_IDC_U_UNROLL;
            text = "$STR_ALIVE_FS_PL_UNROLL";
            tooltip = "$STR_ALIVE_FS_PL_UNROLL_TIP";
            x = FS_B2_X(1);
            onButtonClick = "['unroll'] call ALiVE_fnc_fsStudioPools";
        };
        // his part in AUTO GROUPS: Automatic shows the part worked out
        class RoleLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_U_ROLELABEL;
            text = "$STR_ALIVE_FS_U_ROLE";
            y = (FS_H(26.24) + FS_SP_ULIST);
        };
        class Role : ALiVE_FS_RscCombo {
            idc = FS_IDC_U_ROLE;
            x = FS_FIELD_X;
            y = (FS_H(26.24) + FS_SP_ULIST);
            w = FS_NARROW_W;
            onLBSelChanged = "['role', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class SpecOps : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_U_SPECOPS;
            tooltip = "$STR_ALIVE_FS_U_SPECOPS_TIP";
            x = FS_SIDE_X;
            y = (FS_H(26.24) + FS_SP_ULIST);
            onCheckedChanged = "['specOps', _this] call ALiVE_fnc_fsStudioTabUnits";
        };
        class SpecOpsLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_U_SPECOPSLABEL;
            text = "$STR_ALIVE_FS_U_SPECOPS";
            tooltip = "$STR_ALIVE_FS_U_SPECOPS_TIP";
            x = (FS_SIDE_X + FS_W(0.9));
            y = (FS_H(26.24) + FS_SP_ULIST);
            w = FS_W(2.1);
        };
    };
};
