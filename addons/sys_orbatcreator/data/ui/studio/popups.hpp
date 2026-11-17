// ORBAT Creator studio: popups, each its own display created on display 14000
// with createDisplay. Controls are declared in the order the Tab key visits
// them; the confirm button carries default = 1.
// Author: Jman

// ---------------------------------------------------------------- class browser (30 x 22)
#define FS_BR_W 30
#define FS_BR_H 22

class ALiVE_FS_Browser {
    idd = FS_IDD_BROWSER;
    movingEnable = 0;
    enableSimulation = 1;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_BR_W);
            y = FS_PY(0,FS_BR_H);
            w = FS_W(FS_BR_W);
            h = FS_H(FS_BR_H);
        };
        class Title : ALiVE_FS_RscTitle {
            text = "$STR_ALIVE_FS_BR_TITLE";
            x = FS_PX(0,FS_BR_W);
            y = FS_PY(0,FS_BR_H);
            w = FS_W(FS_BR_W);
            h = FS_H(1);
        };
    };

    class controls {
        class SearchLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_BR_SEARCH";
            x = FS_PX(0.5,FS_BR_W);
            y = FS_PY(1.3,FS_BR_H);
            w = FS_W(4);
        };
        class Search : ALiVE_FS_RscEdit {
            idc = FS_IDC_BR_SEARCH;
            x = FS_PX(4.6,FS_BR_W);
            y = FS_PY(1.3,FS_BR_H);
            w = FS_W(10.3);
            onKeyUp = "['search', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // All factions, then each with its count
        class Faction : ALiVE_FS_RscCombo {
            idc = FS_IDC_BR_FACTION;
            x = FS_PX(15.1,FS_BR_W);
            y = FS_PY(1.3,FS_BR_H);
            w = FS_W(14.4);
            onLBSelChanged = "['faction', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // Soldiers, Vehicles, Everything
        class Kind : ALiVE_FS_RscCombo {
            idc = FS_IDC_BR_KIND;
            x = FS_PX(0.5,FS_BR_W);
            y = FS_PY(2.4,FS_BR_H);
            w = FS_W(14.4);
            onLBSelChanged = "['kind', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class Side : ALiVE_FS_RscCombo {
            idc = FS_IDC_BR_SIDE;
            x = FS_PX(15.1,FS_BR_W);
            y = FS_PY(2.4,FS_BR_H);
            w = FS_W(14.4);
            onLBSelChanged = "['side', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class List : ALiVE_FS_RscListBoxMulti {
            idc = FS_IDC_BR_LIST;
            x = FS_PX(0.5,FS_BR_W);
            y = FS_PY(3.5,FS_BR_H);
            w = FS_W(29);
            h = FS_H(13.4);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // BR_COUNT
        class Count : ALiVE_FS_RscText {
            idc = FS_IDC_BR_COUNT;
            x = FS_PX(0.5,FS_BR_W);
            y = FS_PY(17.1,FS_BR_H);
            w = FS_W(29);
            colorText[] = COLOR_GREY_TITLE_HARD;
        };
        class Parent : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_BR_PARENT;
            x = FS_PX(0.5,FS_BR_W);
            y = FS_PY(18.2,FS_BR_H);
        };
        class ParentLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_BR_PARENT";
            x = FS_PX(1.5,FS_BR_W);
            y = FS_PY(18.2,FS_BR_H);
            w = FS_W(28);
        };
        class AddSelected : ALiVE_FS_RscButton {
            idc = FS_IDC_BR_ADD;
            text = "$STR_ALIVE_FS_BR_ADD";
            default = 1;
            x = FS_PX(0.5,FS_BR_W);
            y = FS_PY(19.5,FS_BR_H);
            w = FS_W(9.5);
            onButtonClick = "['add', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        // single mode only
        class Keep : ALiVE_FS_RscButton {
            idc = FS_IDC_BR_KEEP;
            text = "$STR_ALIVE_FS_BR_KEEP";
            x = FS_PX(10.25,FS_BR_W);
            y = FS_PY(19.5,FS_BR_H);
            w = FS_W(9.5);
            onButtonClick = "['keep', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class Take : Keep {
            idc = FS_IDC_BR_TAKE;
            text = "$STR_ALIVE_FS_BR_TAKE";
            x = FS_PX(20,FS_BR_W);
            onButtonClick = "['take', _this] call ALiVE_fnc_fsStudioBrowser";
        };
        class Close : Keep {
            idc = FS_IDC_BR_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_PX(20,FS_BR_W);
            y = FS_PY(20.7,FS_BR_H);
            onButtonClick = "['close', _this] call ALiVE_fnc_fsStudioBrowser";
        };
    };
};

// ---------------------------------------------------------------- faction picker (22 x 19)
#define FS_PK_W 22
#define FS_PK_H 19

class ALiVE_FS_FactionPicker {
    idd = FS_IDD_PICKER;
    movingEnable = 0;
    enableSimulation = 1;

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
        // PK_ROW per faction
        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_PK_LIST;
            x = FS_PX(0.5,FS_PK_W);
            y = FS_PY(1.3,FS_PK_H);
            w = FS_W(21);
            h = FS_H(14.9);
            onLBSelChanged = "['select', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
        // disabled by the picker until the index and static data are both there
        class StartNew : ALiVE_FS_RscButton {
            idc = FS_IDC_PK_NEW;
            text = "$STR_ALIVE_FS_PK_NEW";
            x = FS_PX(0.5,FS_PK_W);
            y = FS_PY(16.5,FS_PK_H);
            w = FS_W(10.4);
            onButtonClick = "['new', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
        class Merge : StartNew {
            idc = FS_IDC_PK_MERGE;
            text = "$STR_ALIVE_FS_PK_MERGE";
            x = FS_PX(11.1,FS_PK_W);
            onButtonClick = "['merge', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
        class Close : StartNew {
            idc = FS_IDC_PK_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_PX(11.1,FS_PK_W);
            y = FS_PY(17.7,FS_PK_H);
            onButtonClick = "['close', _this] call ALiVE_fnc_fsStudioFactionPicker";
        };
    };
};

// ---------------------------------------------------------------- text box (30 x 21.4)
#define FS_TB_W 30
#define FS_TB_H 21.4

class ALiVE_FS_TextBox {
    idd = FS_IDD_TEXTBOX;
    movingEnable = 0;
    enableSimulation = 1;

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_TB_W);
            y = FS_PY(0,FS_TB_H);
            w = FS_W(FS_TB_W);
            h = FS_H(FS_TB_H);
        };
    };

    class controls {
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
            x = FS_PX(14,FS_TB_W);
            y = FS_PY(20.2,FS_TB_H);
            w = FS_W(7.5);
            onButtonClick = "['copy', _this] call ALiVE_fnc_fsStudioTextBox";
        };
        class Close : Copy {
            idc = FS_IDC_TB_CLOSE;
            text = "$STR_ALIVE_FS_BTN_CLOSE";
            x = FS_PX(22,FS_TB_W);
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

    class controlsBackground {
        class Background : ALiVE_FS_RscBackground {
            x = FS_PX(0,FS_PR_W);
            y = FS_PY(0,FS_PR_H);
            w = FS_W(FS_PR_W);
            h = FS_H(FS_PR_H);
        };
    };

    class controls {
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
            x = FS_PX(0.5,FS_PR_W);
            y = FS_PY(3.1,FS_PR_H);
            w = FS_W(19);
        };
        class Ok : ALiVE_FS_RscButton {
            idc = FS_IDC_PR_OK;
            text = "$STR_ALIVE_FS_BTN_OK";
            default = 1;
            x = FS_PX(6,FS_PR_W);
            y = FS_PY(4.4,FS_PR_H);
            w = FS_W(6.5);
            onButtonClick = "['ok', _this] call ALiVE_fnc_fsStudioPrompt";
        };
        class Cancel : ALiVE_FS_RscButton {
            idc = FS_IDC_PR_CANCEL;
            text = "$STR_ALIVE_FS_BTN_CANCEL";
            x = FS_PX(13,FS_PR_W);
            y = FS_PY(4.4,FS_PR_H);
            w = FS_W(6.5);
            onButtonClick = "['cancel', _this] call ALiVE_fnc_fsStudioPrompt";
        };
    };
};
