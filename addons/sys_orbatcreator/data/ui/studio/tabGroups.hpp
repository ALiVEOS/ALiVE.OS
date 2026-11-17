// ORBAT Creator studio: Groups tab (14400). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// Author: Jman

class ALiVE_FS_TabGroups : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_GROUPS;
    x = FS_X(0.5);
    y = FS_Y(3.2);
    w = FS_W(16);
    h = FS_H(19.3);
    show = 0;

    class controls {

        // the eleven ALiVE names with group counts, then any imported others
        class CategoryLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_GCATEGORY";
            y = FS_H(0);
        };
        class Category : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_CATEGORY;
            x = FS_W(5);
            y = FS_H(0);
            onLBSelChanged = "['category', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_G_LIST;
            y = FS_H(1);
            h = FS_H(2.9);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class New : ALiVE_FS_RscButton {
            idc = FS_IDC_G_NEW;
            text = "$STR_ALIVE_FS_BTN_NEW";
            x = FS_W(0);
            y = FS_H(4);
            w = FS_W(5.25);
            onButtonClick = "['new', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class Duplicate : New {
            idc = FS_IDC_G_DUPLICATE;
            text = "$STR_ALIVE_FS_BTN_DUPLICATE";
            x = FS_W(5.375);
            onButtonClick = "['duplicate', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class Delete : New {
            idc = FS_IDC_G_DELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            x = FS_W(10.75);
            onButtonClick = "['delete', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class NameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_NAME";
            y = FS_H(5);
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_G_NAME;
            x = FS_W(5);
            y = FS_H(5);
            onKillFocus = "['name', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class ClassLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CLASSNAME";
            y = FS_H(6);
        };
        class ClassName : ALiVE_FS_RscEdit {
            idc = FS_IDC_G_CLASS;
            x = FS_W(5);
            y = FS_H(6);
            w = FS_W(7);
            onKillFocus = "['class', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class ClassAuto : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_G_CLASSAUTO;
            x = FS_W(12.2);
            y = FS_H(6);
            onCheckedChanged = "['classAuto', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class ClassAutoLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_AUTO";
            x = FS_W(13.2);
            y = FS_H(6);
            w = FS_W(2.8);
        };

        // How often, 0..1, and its value
        class RarityLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_RARITY";
            tooltip = "$STR_ALIVE_FS_L_RARITY";
            y = FS_H(7);
        };
        class Rarity : ALiVE_FS_RscSlider {
            idc = FS_IDC_G_RARITY;
            x = FS_W(5);
            y = FS_H(7);
            w = FS_W(8.9);
            onSliderPosChanged = "['rarity', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class RarityValue : ALiVE_FS_RscText {
            idc = FS_IDC_G_RARITYVALUE;
            style = 1;
            x = FS_W(14);
            y = FS_H(7);
            w = FS_W(2);
        };

        class IconLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_ICON";
            y = FS_H(8);
        };
        class Icon : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_ICON;
            x = FS_W(5);
            y = FS_H(8);
            onLBSelChanged = "['icon', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        // members; selecting one previews it
        class MembersLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_MEMBERS";
            y = FS_H(9);
            w = FS_W(16);
        };
        class Members : ALiVE_FS_RscListBox {
            idc = FS_IDC_G_MEMBERS;
            y = FS_H(10);
            h = FS_H(3.9);
            onLBSelChanged = "['memberSelect', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberPick : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_MEMBERPICK;
            x = FS_W(0);
            y = FS_H(14);
            w = FS_W(10.6);
        };
        class MemberAdd : ALiVE_FS_RscButton {
            idc = FS_IDC_G_MEMBERADD;
            text = "$STR_ALIVE_FS_BTN_ADD_MEMBER";
            x = FS_W(10.75);
            y = FS_H(14);
            w = FS_W(5.25);
            onButtonClick = "['memberAdd', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberRemove : MemberAdd {
            idc = FS_IDC_G_MEMBERREMOVE;
            text = "$STR_ALIVE_FS_BTN_REMOVE";
            x = FS_W(0);
            y = FS_H(15);
            onButtonClick = "['memberRemove', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberUp : MemberRemove {
            idc = FS_IDC_G_MEMBERUP;
            text = "$STR_ALIVE_FS_BTN_UP";
            x = FS_W(5.375);
            onButtonClick = "['memberUp', _this] call ALiVE_fnc_fsStudioTabGroups";
        };
        class MemberDown : MemberRemove {
            idc = FS_IDC_G_MEMBERDOWN;
            text = "$STR_ALIVE_FS_BTN_DOWN";
            x = FS_W(10.75);
            onButtonClick = "['memberDown', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        class RankLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_RANK";
            y = FS_H(16);
        };
        class Rank : ALiVE_FS_RscCombo {
            idc = FS_IDC_G_RANK;
            x = FS_W(5);
            y = FS_H(16);
            onLBSelChanged = "['rank', _this] call ALiVE_fnc_fsStudioTabGroups";
        };

        // CAT_EMPTY, or CAT_NOT_DRAWN outside FS_ALIVE_DRAWN
        class Note : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_G_NOTE;
            y = FS_H(17);
            h = FS_H(2.3);
        };
    };
};
