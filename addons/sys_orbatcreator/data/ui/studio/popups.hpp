// ORBAT Creator studio: popups, each its own display created on display 14000
// with createDisplay. Controls are declared in the order the Tab key visits
// them; the confirm button carries default = 1.
// Every popup has a 0.5-cell margin; its button rows hold 2 or 3 equal
// buttons, 0.1 apart, spanning the same edges as the list above them.
// Author: Jman

// The 3D preview takes the mouse outside a popup through four areas around it, placed when the popup opens and whenever
// it moves (ALiVE_fnc_fsStudioCamera "popLayout"). A view drag can only start on one of them: an open combo list or a
// scrollbar that reaches past the popup takes its own mouse. None lies over the popup, because a clicked control comes
// to the front. The popup display itself follows a drag that has started and hears its release.
class ALiVE_FS_PopupMouse : ALiVE_FS_RscText {
    idc = -1;
    style = 16;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    colorBackground[] = COLOR_BLACK(0);
    onMouseButtonDown = "['down', _this] call ALiVE_fnc_fsStudioCamera";
    onMouseZChanged = "['wheel', _this] call ALiVE_fnc_fsStudioCamera";
    onMouseButtonDblClick = "if ((_this select 1) == 0) then { ['focus'] call ALiVE_fnc_fsStudioCamera }";
};
#define FS_POPUP_MOUSE \
    onLoad = "['popLayout', _this] call ALiVE_fnc_fsStudioCamera"; \
    onMouseButtonUp = "['popUp', _this] call ALiVE_fnc_fsStudioCamera"; \
    onMouseMoving = "['popMove', _this] call ALiVE_fnc_fsStudioCamera"
#define FS_POPUP_AREAS \
    class PopupMouseTop : ALiVE_FS_PopupMouse { idc = FS_IDC_POPUP_TOP; }; \
    class PopupMouseBottom : ALiVE_FS_PopupMouse { idc = FS_IDC_POPUP_BOTTOM; }; \
    class PopupMouseLeft : ALiVE_FS_PopupMouse { idc = FS_IDC_POPUP_LEFT; }; \
    class PopupMouseRight : ALiVE_FS_PopupMouse { idc = FS_IDC_POPUP_RIGHT; }

// ---------------------------------------------------------------- class browser (30 x 21.5)
#define FS_BR_W 30
#define FS_BR_H 21.5
// two equal columns across the 29-cell inside
#define FS_BR_C2_W  FS_W(14.45)
// opened at the left, over the studio panel, so the 3D preview stays in view; it can be dragged by its title
#define FS_BX(n)    (safezoneX + (0.5 + (n)) * FS_GW)

class ALiVE_FS_Browser {
    idd = FS_IDD_BROWSER;
    movingEnable = 1;
    enableSimulation = 1;
    FS_POPUP_MOUSE;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_BX(0);
            y = FS_PY(0,FS_BR_H);
            w = FS_W(FS_BR_W);
            h = FS_H(FS_BR_H);
        };
    };

    class controls {
        FS_POPUP_AREAS;
        // the title bar drags the whole window (movingEnable above)
        class Title : ALiVE_FS_RscTitle {
            idc = FS_IDC_BR_TITLE;
            text = "$STR_ALIVE_FS_BR_TITLE";
            moving = 1;
            x = FS_BX(0);
            y = FS_PY(0,FS_BR_H);
            w = FS_W(FS_BR_W);
            h = FS_H(1);
        };
        class SearchLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_BR_SEARCH";
            x = FS_BX(0.5);
            y = FS_PY(1.3,FS_BR_H);
            w = FS_W(4);
        };
        class Search : ALiVE_FS_RscEdit {
            idc = FS_IDC_BR_SEARCH;
            x = FS_BX(4.6);
            y = FS_PY(1.3,FS_BR_H);
            w = FS_W(10.35);
            onKeyUp = "['search', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // All factions, then each with its count
        class Faction : ALiVE_FS_RscCombo {
            idc = FS_IDC_BR_FACTION;
            x = FS_BX(15.05);
            y = FS_PY(1.3,FS_BR_H);
            w = FS_BR_C2_W;
            onLBSelChanged = "['faction', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // Soldiers, Vehicles, Everything
        class Kind : ALiVE_FS_RscCombo {
            idc = FS_IDC_BR_KIND;
            x = FS_BX(0.5);
            y = FS_PY(2.4,FS_BR_H);
            w = FS_BR_C2_W;
            onLBSelChanged = "['kind', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class Side : ALiVE_FS_RscCombo {
            idc = FS_IDC_BR_SIDE;
            x = FS_BX(15.05);
            y = FS_PY(2.4,FS_BR_H);
            w = FS_BR_C2_W;
            onLBSelChanged = "['side', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class List : ALiVE_FS_RscListBoxMulti {
            idc = FS_IDC_BR_LIST;
            x = FS_BX(0.5);
            y = FS_PY(3.5,FS_BR_H);
            w = FS_W(29);
            // 15 whole rows of FS_ROW_H (0.9), so no row is cut at the bottom
            h = FS_H(13.5);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // BR_COUNT
        class Count : ALiVE_FS_RscText {
            idc = FS_IDC_BR_COUNT;
            x = FS_BX(0.5);
            y = FS_PY(17,FS_BR_H);
            w = FS_W(29);
            colorText[] = COLOR_GREY_TITLE_HARD;
        };
        class Parent : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_BR_PARENT;
            tooltip = "$STR_ALIVE_FS_BR_PARENT";
            x = FS_BX(0.5);
            y = FS_PY(18,FS_BR_H);
        };
        class ParentLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_BR_PARENT_LABEL;
            text = "$STR_ALIVE_FS_BR_PARENT";
            x = FS_BX(1.5);
            y = FS_PY(18,FS_BR_H);
            w = FS_W(28);
        };
        // single mode only: first button row
        class Keep : ALiVE_FS_RscButton {
            idc = FS_IDC_BR_KEEP;
            text = "$STR_ALIVE_FS_BR_KEEP";
            x = FS_BX(0.5);
            y = FS_PY(19.1,FS_BR_H);
            w = FS_BR_C2_W;
            onButtonClick = "['keep', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class Take : Keep {
            idc = FS_IDC_BR_TAKE;
            text = "$STR_ALIVE_FS_BR_TAKE";
            x = FS_BX(15.05);
            onButtonClick = "['take', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // second button row
        class AddSelected : ALiVE_FS_RscButton {
            idc = FS_IDC_BR_ADD;
            text = "$STR_ALIVE_FS_BR_ADD";
            default = 1;
            x = FS_BX(0.5);
            y = FS_PY(20.1,FS_BR_H);
            w = FS_BR_C2_W;
            onButtonClick = "['add', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class Close : Keep {
            idc = FS_IDC_BR_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_BX(15.05);
            y = FS_PY(20.1,FS_BR_H);
            onButtonClick = "['close', _this] call ALiVE_fnc_fsStudioBrowser";
        };
    };
};

// ---------------------------------------------------------------- faction picker (30 x 18.8)
#define FS_PK_W 30
#define FS_PK_H 18.8
// three equal buttons across the 29-cell inside
#define FS_PK_C3_W  FS_W(28.8 / 3)

class ALiVE_FS_FactionPicker {
    idd = FS_IDD_PICKER;
    movingEnable = 0;
    enableSimulation = 1;
    FS_POPUP_MOUSE;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_PK_W);
            y = FS_PY(0,FS_PK_H);
            w = FS_W(FS_PK_W);
            h = FS_H(FS_PK_H);
        };
        class Title : ALiVE_FS_RscTitle {
            text = "$STR_ALIVE_FS_PK_TITLE";
            x = FS_PX(0,FS_PK_W);
            y = FS_PY(0,FS_PK_H);
            w = FS_W(FS_PK_W);
            h = FS_H(1);
        };
    };

    class controls {
        FS_POPUP_AREAS;
        // PK_ROW per faction
        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_PK_LIST;
            x = FS_PX(0.5,FS_PK_W);
            y = FS_PY(1.3,FS_PK_H);
            w = FS_W(29);
            h = FS_H(15.3);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
        // disabled by the picker until the index and static data are both there
        class StartNew : ALiVE_FS_RscButton {
            idc = FS_IDC_PK_NEW;
            text = "$STR_ALIVE_FS_PK_NEW_SHORT";
            tooltip = "$STR_ALIVE_FS_PK_NEW";
            x = FS_PX(0.5,FS_PK_W);
            y = FS_PY(17.4,FS_PK_H);
            w = FS_PK_C3_W;
            onButtonClick = "['new', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
        class Merge : StartNew {
            idc = FS_IDC_PK_MERGE;
            text = "$STR_ALIVE_FS_PK_MERGE_SHORT";
            tooltip = "$STR_ALIVE_FS_PK_MERGE";
            x = FS_PX(0.5 + 28.8 / 3 + 0.1,FS_PK_W);
            onButtonClick = "['merge', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
        class Close : StartNew {
            idc = FS_IDC_PK_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            tooltip = "";
            x = FS_PX(0.5 + 2 * (28.8 / 3 + 0.1),FS_PK_W);
            onButtonClick = "['close', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
    };
};

// ---------------------------------------------------------------- cargo (30 x 18.8)
#define FS_CG_W 30
#define FS_CG_H 18.8

class ALiVE_FS_Cargo {
    idd = FS_IDD_CARGO;
    movingEnable = 0;
    enableSimulation = 1;
    FS_POPUP_MOUSE;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_CG_W);
            y = FS_PY(0,FS_CG_H);
            w = FS_W(FS_CG_W);
            h = FS_H(FS_CG_H);
        };
        class ModeLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_CG_L_MODE";
            x = FS_PX(0.5,FS_CG_W);
            y = FS_PY(1.3,FS_CG_H);
            w = FS_W(8.3);
        };
        class CountLabel : ModeLabel {
            text = "$STR_ALIVE_FS_CG_L_COUNT";
            y = FS_PY(13.45,FS_CG_H);
        };
        class UnitLabel : ModeLabel {
            text = "$STR_ALIVE_FS_CG_L_UNIT";
            y = FS_PY(14.6,FS_CG_H);
        };
    };

    class controls {
        FS_POPUP_AREAS;
        class Title : ALiVE_FS_RscTitle {
            idc = FS_IDC_CG_TITLE;
            x = FS_PX(0,FS_CG_W);
            y = FS_PY(0,FS_CG_H);
            w = FS_W(FS_CG_W);
            h = FS_H(1);
        };
        // As the base vehicle, Empty, This list
        class Mode : ALiVE_FS_RscCombo {
            idc = FS_IDC_CG_MODE;
            x = FS_PX(9,FS_CG_W);
            y = FS_PY(1.3,FS_CG_H);
            w = FS_W(20.5);
            onLBSelChanged = "['mode', _this] call ALiVE_fnc_fsStudioCargo";
        };
        // the item, its kind and count on the right
        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_CG_LIST;
            x = FS_PX(0.5,FS_CG_W);
            y = FS_PY(2.45,FS_CG_H);
            w = FS_W(29);
            h = FS_H(10.8);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioCargo";
        };
        class Count : ALiVE_FS_RscEdit {
            idc = FS_IDC_CG_COUNT;
            x = FS_PX(9,FS_CG_W);
            y = FS_PY(13.45,FS_CG_H);
            w = FS_W(5.8);
            maxChars = 3;
        };
        class SetCount : ALiVE_FS_RscButton {
            idc = FS_IDC_CG_SETCOUNT;
            text = "$STR_ALIVE_FS_BTN_SET";
            x = FS_PX(15,FS_CG_W);
            y = FS_PY(13.45,FS_CG_H);
            w = FS_W(4.6);
            onButtonClick = "['count', _this] call ALiVE_fnc_fsStudioCargo";
        };
        class Remove : SetCount {
            idc = FS_IDC_CG_REMOVE;
            text = "$STR_ALIVE_FS_BTN_REMOVE";
            x = FS_PX(19.8,FS_CG_W);
            onButtonClick = "['remove', _this] call ALiVE_fnc_fsStudioCargo";
        };
        class Clear : SetCount {
            idc = FS_IDC_CG_CLEAR;
            text = "$STR_ALIVE_FS_BTN_CLEAR";
            x = FS_PX(24.6,FS_CG_W);
            w = FS_W(4.9);
            onButtonClick = "['clear', _this] call ALiVE_fnc_fsStudioCargo";
        };
        // a faction unit, whose gear is added
        class Unit : ALiVE_FS_RscCombo {
            idc = FS_IDC_CG_UNIT;
            x = FS_PX(9,FS_CG_W);
            y = FS_PY(14.6,FS_CG_H);
            w = FS_W(15.4);
        };
        class AddUnit : SetCount {
            idc = FS_IDC_CG_ADDUNIT;
            text = "$STR_ALIVE_FS_CG_ADDUNIT";
            tooltip = "$STR_ALIVE_FS_CG_ADDUNIT_TIP";
            x = FS_PX(24.6,FS_CG_W);
            y = FS_PY(14.6,FS_CG_H);
            w = FS_W(4.9);
            onButtonClick = "['unit', _this] call ALiVE_fnc_fsStudioCargo";
        };
        class Base : SetCount {
            idc = FS_IDC_CG_BASE;
            text = "$STR_ALIVE_FS_CG_BASE";
            x = FS_PX(0.5,FS_CG_W);
            y = FS_PY(15.85,FS_CG_H);
            w = FS_W(29);
            onButtonClick = "['base', _this] call ALiVE_fnc_fsStudioCargo";
        };
        class Close : SetCount {
            idc = FS_IDC_CG_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_PX(0.5,FS_CG_W);
            y = FS_PY(17.4,FS_CG_H);
            w = FS_W(29);
            onButtonClick = "['close', _this] call ALiVE_fnc_fsStudioCargo";
        };
    };
};

// ---------------------------------------------------------------- gear pools (30 x 15.25)
#define FS_PL_W 30
#define FS_PL_H 15.25

class ALiVE_FS_Pools {
    idd = FS_IDD_POOLS;
    movingEnable = 0;
    enableSimulation = 1;
    FS_POPUP_MOUSE;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_PL_W);
            y = FS_PY(0,FS_PL_H);
            w = FS_W(FS_PL_W);
            h = FS_H(FS_PL_H);
        };
        class SlotLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_PL_L_SLOT";
            x = FS_PX(0.5,FS_PL_W);
            y = FS_PY(11.4,FS_PL_H);
            w = FS_W(4);
        };
    };

    class controls {
        FS_POPUP_AREAS;
        class Title : ALiVE_FS_RscTitle {
            idc = FS_IDC_PL_TITLE;
            x = FS_PX(0,FS_PL_W);
            y = FS_PY(0,FS_PL_H);
            w = FS_W(FS_PL_W);
            h = FS_H(1);
        };
        // the faction's pools: green when the unit wears it, the slot and users on the right
        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_PL_LIST;
            x = FS_PX(0.5,FS_PL_W);
            y = FS_PY(1.3,FS_PL_H);
            w = FS_W(14.2);
            h = FS_H(7.6);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_PL_NAME;
            x = FS_PX(0.5,FS_PL_W);
            y = FS_PY(9.1,FS_PL_H);
            w = FS_W(9.4);
            maxChars = 60;
        };
        class Rename : ALiVE_FS_RscButton {
            idc = FS_IDC_PL_RENAME;
            text = "$STR_ALIVE_FS_PL_RENAME";
            x = FS_PX(10,FS_PL_W);
            y = FS_PY(9.1,FS_PL_H);
            w = FS_W(4.7);
            onButtonClick = "['rename', _this] call ALiVE_fnc_fsStudioPools";
        };
        class New : Rename {
            idc = FS_IDC_PL_NEW;
            text = "$STR_ALIVE_FS_PL_NEW";
            tooltip = "$STR_ALIVE_FS_PL_NEW_TIP";
            x = FS_PX(0.5,FS_PL_W);
            y = FS_PY(10.25,FS_PL_H);
            w = FS_W(4.66);
            onButtonClick = "['new', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Delete : New {
            idc = FS_IDC_PL_DELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            tooltip = "";
            x = FS_PX(5.26,FS_PL_W);
            onButtonClick = "['delete', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Use : New {
            idc = FS_IDC_PL_USE;
            text = "$STR_ALIVE_FS_PL_USE";
            tooltip = "$STR_ALIVE_FS_PL_USE_TIP";
            x = FS_PX(10.02,FS_PL_W);
            w = FS_W(4.68);
            onButtonClick = "['use', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Slot : ALiVE_FS_RscCombo {
            idc = FS_IDC_PL_SLOT;
            x = FS_PX(4.6,FS_PL_W);
            y = FS_PY(11.4,FS_PL_H);
            w = FS_W(10.1);
            onLBSelChanged = "['slot', _this] call ALiVE_fnc_fsStudioPools";
        };
        // the picked pool's items, the weight and chance on the right
        class Entries : ALiVE_FS_RscListBox {
            idc = FS_IDC_PL_ENTRIES;
            x = FS_PX(15.3,FS_PL_W);
            y = FS_PY(1.3,FS_PL_H);
            w = FS_W(14.2);
            h = FS_H(7.6);
            onLBSelChanged = "['entry', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Weight : ALiVE_FS_RscEdit {
            idc = FS_IDC_PL_WEIGHT;
            tooltip = "$STR_ALIVE_FS_PL_WEIGHT_TIP";
            x = FS_PX(15.3,FS_PL_W);
            y = FS_PY(9.1,FS_PL_H);
            w = FS_W(4.6);
            maxChars = 3;
        };
        class SetWeight : Rename {
            idc = FS_IDC_PL_SETWEIGHT;
            text = "$STR_ALIVE_FS_BTN_SET";
            x = FS_PX(20,FS_PL_W);
            w = FS_W(4.6);
            onButtonClick = "['weight', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Remove : Rename {
            idc = FS_IDC_PL_REMOVE;
            text = "$STR_ALIVE_FS_BTN_REMOVE";
            x = FS_PX(24.7,FS_PL_W);
            w = FS_W(4.8);
            onButtonClick = "['remove', _this] call ALiVE_fnc_fsStudioPools";
        };
        // a faction unit whose item in the pool's slot is added
        class Unit : ALiVE_FS_RscCombo {
            idc = FS_IDC_PL_UNIT;
            x = FS_PX(15.3,FS_PL_W);
            y = FS_PY(10.25,FS_PL_H);
            w = FS_W(9.3);
        };
        class AddUnit : Rename {
            idc = FS_IDC_PL_ADDUNIT;
            text = "$STR_ALIVE_FS_PL_ADD";
            tooltip = "$STR_ALIVE_FS_PL_ADD_TIP";
            x = FS_PX(24.7,FS_PL_W);
            y = FS_PY(10.25,FS_PL_H);
            w = FS_W(4.8);
            onButtonClick = "['add', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Roll : Rename {
            idc = FS_IDC_PL_ROLL;
            text = "$STR_ALIVE_FS_PL_ROLL";
            tooltip = "$STR_ALIVE_FS_PL_ROLL_TIP";
            x = FS_PX(15.3,FS_PL_W);
            y = FS_PY(11.4,FS_PL_H);
            w = FS_W(14.2);
            onButtonClick = "['roll', _this] call ALiVE_fnc_fsStudioPools";
        };
        class Users : ALiVE_FS_RscText {
            idc = FS_IDC_PL_USERS;
            x = FS_PX(0.5,FS_PL_W);
            y = FS_PY(12.55,FS_PL_H);
            w = FS_W(29);
            colorText[] = COLOR_GREY_TITLE_HARD;
        };
        class Close : Rename {
            idc = FS_IDC_PL_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_PX(0.5,FS_PL_W);
            y = FS_PY(13.9,FS_PL_H);
            w = FS_W(29);
            onButtonClick = "['close', _this] call ALiVE_fnc_fsStudioPools";
        };
    };
};

// ---------------------------------------------------------------- text box (30 x 21.5)
#define FS_TB_W 30
#define FS_TB_H 21.5

class ALiVE_FS_TextBox {
    idd = FS_IDD_TEXTBOX;
    movingEnable = 0;
    enableSimulation = 1;
    FS_POPUP_MOUSE;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_TB_W);
            y = FS_PY(0,FS_TB_H);
            w = FS_W(FS_TB_W);
            h = FS_H(FS_TB_H);
        };
    };

    class controls {
        FS_POPUP_AREAS;
        class Title : ALiVE_FS_RscTitle {
            idc = FS_IDC_TB_TITLE;
            x = FS_PX(0,FS_TB_W);
            y = FS_PY(0,FS_TB_H);
            w = FS_W(FS_TB_W);
            h = FS_H(1);
        };
        // multi-line, read-only: the text can be selected but not changed
        class Text : ALiVE_FS_RscEdit {
            idc = FS_IDC_TB_TEXT;
            maxChars = 2000100;
            style = 16;
            canModify = 0;
            x = FS_PX(0.5,FS_TB_W);
            y = FS_PY(1.3,FS_TB_H);
            w = FS_W(29);
            h = FS_H(18.6);
        };
        class Copy : ALiVE_FS_RscButton {
            idc = FS_IDC_TB_COPY;
            text = "$STR_ALIVE_FS_BTN_COPY";
            x = FS_PX(0.5,FS_TB_W);
            y = FS_PY(20.1,FS_TB_H);
            w = FS_W(14.45);
            onButtonClick = "['copy', _this] call ALiVE_fnc_fsStudioTextBox";
        };
        class Close : Copy {
            idc = FS_IDC_TB_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_PX(15.05,FS_TB_W);
            onButtonClick = "['close', _this] call ALiVE_fnc_fsStudioTextBox";
        };
    };
};

// ---------------------------------------------------------------- prompt (20 x 5.6)
#define FS_PR_W 20
#define FS_PR_H 5.6

class ALiVE_FS_Prompt {
    idd = FS_IDD_PROMPT;
    movingEnable = 0;
    enableSimulation = 1;
    FS_POPUP_MOUSE;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_PR_W);
            y = FS_PY(0,FS_PR_H);
            w = FS_W(FS_PR_W);
            h = FS_H(FS_PR_H);
        };
    };

    class controls {
        FS_POPUP_AREAS;
        class Question : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_PR_QUESTION;
            x = FS_PX(0.5,FS_PR_W);
            y = FS_PY(0.3,FS_PR_H);
            w = FS_W(19);
            h = FS_H(2.6);
        };
        // hidden by the prompt for a yes/no question
        class Edit : ALiVE_FS_RscEdit {
            idc = FS_IDC_PR_EDIT;
            // a pasted share text can be up to FS_SIZE_MAX characters
            maxChars = 2000100;
            x = FS_PX(0.5,FS_PR_W);
            y = FS_PY(3.1,FS_PR_H);
            w = FS_W(19);
        };
        class Ok : ALiVE_FS_RscButton {
            idc = FS_IDC_PR_OK;
            text = "$STR_ALIVE_FS_BTN_OK";
            default = 1;
            x = FS_PX(0.5,FS_PR_W);
            y = FS_PY(4.2,FS_PR_H);
            w = FS_W(9.45);
            onButtonClick = "['ok', _this] call ALiVE_fnc_fsStudioPrompt";
        };
        class Cancel : ALiVE_FS_RscButton {
            idc = FS_IDC_PR_CANCEL;
            text = "$STR_ALIVE_FS_BTN_CANCEL";
            x = FS_PX(10.05,FS_PR_W);
            y = FS_PY(4.2,FS_PR_H);
            w = FS_W(9.45);
            onButtonClick = "['cancel', _this] call ALiVE_fnc_fsStudioPrompt";
        };
    };
};

// ---------------------------------------------------------------- code prompt (24 x 14)
// The prompt with a tall box of several lines, for a unit's or vehicle's Init Code. Same idd and idcs as the
// prompt, so ALiVE_fnc_fsStudioPrompt runs it; OK is not the default button, so Enter starts a new line.
#define FS_CP_W 24
#define FS_CP_H 14

class ALiVE_FS_CodePrompt {
    idd = FS_IDD_PROMPT;
    movingEnable = 0;
    enableSimulation = 1;
    FS_POPUP_MOUSE;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_CP_W);
            y = FS_PY(0,FS_CP_H);
            w = FS_W(FS_CP_W);
            h = FS_H(FS_CP_H);
        };
    };

    class controls {
        FS_POPUP_AREAS;
        class Question : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_PR_QUESTION;
            x = FS_PX(0.5,FS_CP_W);
            y = FS_PY(0.3,FS_CP_H);
            w = FS_W(23);
            h = FS_H(2.6);
        };
        class Edit : ALiVE_FS_RscEdit {
            idc = FS_IDC_PR_EDIT;
            style = 16; // ST_MULTI
            autocomplete = "scripting";
            maxChars = 20000;
            x = FS_PX(0.5,FS_CP_W);
            y = FS_PY(3.1,FS_CP_H);
            w = FS_W(23);
            h = FS_H(9.5);
        };
        class Ok : ALiVE_FS_RscButton {
            idc = FS_IDC_PR_OK;
            text = "$STR_ALIVE_FS_BTN_OK";
            x = FS_PX(0.5,FS_CP_W);
            y = FS_PY(12.9,FS_CP_H);
            w = FS_W(11.45);
            onButtonClick = "['ok', _this] call ALiVE_fnc_fsStudioPrompt";
        };
        class Cancel : ALiVE_FS_RscButton {
            idc = FS_IDC_PR_CANCEL;
            text = "$STR_ALIVE_FS_BTN_CANCEL";
            x = FS_PX(12.05,FS_CP_W);
            y = FS_PY(12.9,FS_CP_H);
            w = FS_W(11.45);
            onButtonClick = "['cancel', _this] call ALiVE_fnc_fsStudioPrompt";
        };
    };
};

// ---------------------------------------------------------------- help (24 x 20)
// Help for the tab on show. Opens at the right of the screen, so the panel it
// talks about stays in view, and drags by its title like the class browser.
#define FS_HL_W 24
#define FS_HL_H 20
#define FS_HX(n)    (safezoneX + safezoneW - (FS_HL_W + 0.5 - (n)) * FS_GW)

// the help panel: made inside the studio display by ALiVE_fnc_fsStudioHelp (ctrlCreate), not a display of its
// own, because the engine stops drawing the studio under any display on top of it and the help is read beside
// the tab it explains. It drags by its title (the function moves the group).
class ALiVE_FS_HelpPanel : RscControlsGroupNoScrollbars {
    idc = FS_IDD_HELP;
    x = FS_HX(0);
    y = FS_PY(0,FS_HL_H);
    w = FS_W(FS_HL_W);
    h = FS_H(FS_HL_H);
    class controls {
        class Background : ALiVE_FS_RscBackground {
            idc = FS_IDC_HL_BACK;
            x = 0;
            y = 0;
            w = FS_W(FS_HL_W);
            h = FS_H(FS_HL_H);
        };
        class Title : ALiVE_FS_RscTitle {
            idc = FS_IDC_HL_TITLE;
            style = 0;
            x = 0;
            y = 0;
            w = FS_W(FS_HL_W);
            h = FS_H(1);
        };
        // over the title and invisible: plain text takes no mouse events, style 16 does (as the preview's MouseArea)
        class TitleDrag : ALiVE_FS_RscText {
            idc = FS_IDC_HL_DRAG;
            style = 16;
            x = 0;
            y = 0;
            w = FS_W(FS_HL_W);
            h = FS_H(1);
            onMouseButtonDown = "['dragStart', _this] call ALiVE_fnc_fsStudioHelp";
            onMouseMoving = "['drag'] call ALiVE_fnc_fsStudioHelp";
            onMouseButtonUp = "['dragEnd'] call ALiVE_fnc_fsStudioHelp";
        };
        // fsStudioHelp sizes this to the text; it scrolls only when the text is taller than the screen
        class Body : ALiVE_FS_RscGroup {
            idc = FS_IDC_HL_GROUP;
            x = FS_W(0.5);
            y = FS_H(1.3);
            w = FS_W(23);
            h = FS_H(16.4);
            class controls {
                class Text : ALiVE_FS_RscStructuredText {
                    idc = FS_IDC_HL_TEXT;
                    x = 0;
                    y = 0;
                    w = FS_W(22.4);
                    h = FS_H(16.4);
                };
            };
        };
        class NoShow : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_HL_NOSHOW;
            x = FS_W(0.5);
            y = FS_H(17.9);
            onCheckedChanged = "['noshow', _this] call ALiVE_fnc_fsStudioHelp";
        };
        class NoShowLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_HL_LABEL;
            text = "$STR_ALIVE_FS_HELP_NOSHOW";
            x = FS_W(1.5);
            y = FS_H(17.9);
            w = FS_W(22);
        };
        class Close : ALiVE_FS_RscButton {
            idc = FS_IDC_HL_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_W(0.5);
            y = FS_H(18.9);
            w = FS_W(23);
            onButtonClick = "['close'] call ALiVE_fnc_fsStudioHelp";
        };
    };
};

