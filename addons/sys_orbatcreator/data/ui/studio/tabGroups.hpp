// ORBAT Creator studio: Groups tab (14400). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// Author: Jman

class ALiVE_FS_TabGroups : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_GROUPS;
    x = FS_X(0.5);
    y = FS_Y(FS_TOP);
    w = FS_W(16);
    h = FS_TAB_H;
    show = 0;

    class controls {

        // the eleven ALiVE names with group counts, then any imported others
        class CategoryLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_GCATEGORY";
            y = FS_H(0);
        };
        class Category : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_CATEGORY;
            x = FS_FIELD_X;
            y = FS_H(0);
            onLBSelChanged = "['category', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_G_LIST;
            y = FS_H(1.15);
            h = (FS_H(2.45) + FS_SP_GLIST);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class New : ALiVE_FS_RscButton {
            idc = FS_IDC_G_NEW;
            text = "$STR_ALIVE_FS_BTN_NEW";
            x = FS_B3_X(0);
            y = (FS_H(3.8) + FS_SP_GLIST);
            w = FS_B3_W;
            onButtonClick = "['new', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class Duplicate : New {
            idc = FS_IDC_G_DUPLICATE;
            text = "$STR_ALIVE_FS_BTN_DUPLICATE";
            x = FS_B3_X(1);
            onButtonClick = "['duplicate', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class Delete : New {
            idc = FS_IDC_G_DELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            x = FS_B3_X(2);
            onButtonClick = "['delete', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        // the groups ALiVE draws from, made from the faction's own men and vehicles
        class Auto : ALiVE_FS_RscButton {
            idc = FS_IDC_G_AUTO;
            text = "$STR_ALIVE_FS_G_AUTO";
            tooltip = "$STR_ALIVE_FS_G_AUTO_TIP";
            x = FS_B2_X(0);
            y = (FS_H(4.95) + FS_SP_GLIST);
            w = FS_B2_W;
            onButtonClick = "['auto', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class AutoRebuild : Auto {
            idc = FS_IDC_G_AUTOREBUILD;
            text = "$STR_ALIVE_FS_G_REBUILD";
            tooltip = "$STR_ALIVE_FS_G_REBUILD_TIP";
            x = FS_B2_X(1);
            onButtonClick = "['rebuild', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class NameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_NAME";
            y = (FS_H(6.45) + FS_SP_GLIST);
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_G_NAME;
            x = FS_FIELD_X;
            y = (FS_H(6.45) + FS_SP_GLIST);
            onKillFocus = "['name', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class ClassLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CLASSNAME";
            y = (FS_H(7.6) + FS_SP_GLIST);
        };
        class ClassName : ALiVE_FS_RscEdit {
            idc = FS_IDC_G_CLASS;
            x = FS_FIELD_X;
            y = (FS_H(7.6) + FS_SP_GLIST);
            w = FS_NARROW_W;
            onKillFocus = "['class', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class ClassAuto : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_G_CLASSAUTO;
            tooltip = "$STR_ALIVE_FS_L_AUTO";
            x = FS_SIDE_X;
            y = (FS_H(7.6) + FS_SP_GLIST);
            onCheckedChanged = "['classAuto', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class ClassAutoLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_AUTO_SHORT";
            tooltip = "$STR_ALIVE_FS_L_AUTO";
            x = (FS_SIDE_X + FS_W(0.9));
            y = (FS_H(7.6) + FS_SP_GLIST);
            w = FS_W(2.1);
        };

        // How often, 0..1, and its value
        class RarityLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_RARITY_SHORT";
            tooltip = "$STR_ALIVE_FS_L_RARITY";
            y = (FS_H(8.75) + FS_SP_GLIST);
        };
        class Rarity : ALiVE_FS_RscSlider {
            idc = FS_IDC_G_RARITY;
            x = FS_FIELD_X;
            y = (FS_H(8.75) + FS_SP_GLIST);
            w = FS_NARROW_W;
            onSliderPosChanged = "['rarity', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class RarityValue : ALiVE_FS_RscText {
            idc = FS_IDC_G_RARITYVALUE;
            style = 1;
            x = FS_SIDE_X;
            y = (FS_H(8.75) + FS_SP_GLIST);
            w = FS_SIDE_W;
        };

        class IconLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_ICON";
            y = (FS_H(9.9) + FS_SP_GLIST);
        };
        class Icon : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_ICON;
            x = FS_FIELD_X;
            y = (FS_H(9.9) + FS_SP_GLIST);
            onLBSelChanged = "['icon', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        // members; selecting one previews it
        class MembersLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_MEMBERS";
            y = (FS_H(11.4) + FS_SP_GLIST);
            w = FS_W(16);
        };
        class Members : ALiVE_FS_RscListBox {
            idc = FS_IDC_G_MEMBERS;
            y = (FS_H(12.55) + FS_SP_GLIST);
            h = (FS_H(4.5) + FS_SP_GMEMBERS);
            onLBSelChanged = "['memberSelect', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberPick : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_MEMBERPICK;
            x = FS_B2_X(0);
            y = (FS_H(17.15) + FS_SP_GLIST + FS_SP_GMEMBERS);
            w = FS_B2_W;
        };
        class MemberAdd : ALiVE_FS_RscButton {
            idc = FS_IDC_G_MEMBERADD;
            text = "$STR_ALIVE_FS_BTN_ADD_MEMBER";
            x = FS_B2_X(1);
            y = (FS_H(17.15) + FS_SP_GLIST + FS_SP_GMEMBERS);
            w = FS_B2_W;
            onButtonClick = "['memberAdd', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberRemove : MemberAdd {
            idc = FS_IDC_G_MEMBERREMOVE;
            text = "$STR_ALIVE_FS_BTN_REMOVE";
            x = FS_B3_X(0);
            y = (FS_H(18.3) + FS_SP_GLIST + FS_SP_GMEMBERS);
            w = FS_B3_W;
            onButtonClick = "['memberRemove', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberUp : MemberRemove {
            idc = FS_IDC_G_MEMBERUP;
            text = "$STR_ALIVE_FS_BTN_UP";
            x = FS_B3_X(1);
            onButtonClick = "['memberUp', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberDown : MemberRemove {
            idc = FS_IDC_G_MEMBERDOWN;
            text = "$STR_ALIVE_FS_BTN_DOWN";
            x = FS_B3_X(2);
            onButtonClick = "['memberDown', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class RankLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_RANK";
            y = (FS_H(19.45) + FS_SP_GLIST + FS_SP_GMEMBERS);
        };
        class Rank : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_RANK;
            x = FS_FIELD_X;
            y = (FS_H(19.45) + FS_SP_GLIST + FS_SP_GMEMBERS);
            onLBSelChanged = "['rank', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        // CAT_EMPTY, or CAT_NOT_DRAWN outside FS_ALIVE_DRAWN
        class Note : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_G_NOTE;
            y = (FS_H(20.95) + FS_SP_GLIST + FS_SP_GMEMBERS);
            h = FS_H(2.64);
        };
    };
};
