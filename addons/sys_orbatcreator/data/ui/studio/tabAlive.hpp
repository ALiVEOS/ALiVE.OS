// ORBAT Creator studio: ALiVE tab (14500). Places are relative to the group.
// One controls group with four panels; the Section combo shows one and
// ALiVE_fnc_fsStudioTabAlive hides the controls of the other three.
// Controls are declared in the order the Tab key visits them.
// Author: Jman

class ALiVE_FS_TabAlive : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_ALIVE;
    x = FS_X(0.5);
    y = FS_Y(FS_TOP);
    w = FS_W(16);
    h = FS_TAB_H;
    show = 0;

    class controls {

        class SectionLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_A_SECTIONLABEL;
            text = "$STR_ALIVE_FS_A_SECTION";
            y = FS_H(0);
        };
        class Section : ALiVE_FS_RscCombo {
            idc = FS_IDC_A_SECTION;
            x = FS_FIELD_X;
            y = FS_H(0);
            onLBSelChanged = "['section', _this] call ALiVE_fnc_fsStudioTabAlive";
        };

        // 1. What ALiVE will see
        class Hook : ALiVE_FS_RscCheckBox {
            idc = FS_IDC_A_HOOK;
            tooltip = "$STR_ALIVE_FS_A_HOOK_TIP";
            x = FS_W(0);
            y = FS_H(1.15);
            onCheckedChanged = "['hook', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class HookLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_A_HOOKLABEL;
            text = "$STR_ALIVE_FS_A_HOOK";
            tooltip = "$STR_ALIVE_FS_A_HOOK_TIP";
            x = FS_W(0.9);
            y = FS_H(1.15);
            w = FS_W(7.1);
        };
        class Rarity : Hook {
            idc = FS_IDC_A_RARITY;
            tooltip = "$STR_ALIVE_FS_A_RARITY_TIP";
            x = FS_B2_X(1);
            onCheckedChanged = "['rarity', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class RarityLabel : HookLabel {
            idc = FS_IDC_A_RARITYLABEL;
            text = "$STR_ALIVE_FS_A_RARITY";
            tooltip = "$STR_ALIVE_FS_A_RARITY_TIP";
            x = (FS_B2_X(1) + FS_W(0.9));
        };
        class Copy : ALiVE_FS_RscButton {
            idc = FS_IDC_A_COPY;
            text = "$STR_ALIVE_FS_A_COPY";
            tooltip = "$STR_ALIVE_FS_A_COPY_TIP";
            x = FS_B2_X(0);
            y = FS_H(2.3);
            w = FS_B2_W;
            onButtonClick = "['copy', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class Live : Copy {
            idc = FS_IDC_A_LIVE;
            text = "$STR_ALIVE_FS_A_LIVE";
            tooltip = "$STR_ALIVE_FS_A_LIVE_TIP";
            x = FS_B2_X(1);
            onButtonClick = "['live', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        // grows to its text; the tab scrolls
        class Preview : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_A_PREVIEW;
            y = FS_H(3.6);
            h = FS_H(10);
        };

        // 2. Supplies and crates
        class CrateList : ALiVE_FS_RscListBox {
            idc = FS_IDC_A_CRATELIST;
            y = FS_H(1.15);
            h = (FS_H(4.6) + FS_SP_ACRATES);
        };
        class CrateEdit : ALiVE_FS_RscButton {
            idc = FS_IDC_A_CRATEEDIT;
            text = "$STR_ALIVE_FS_A_CRATE_EDIT";
            x = FS_B2_X(0);
            y = (FS_H(5.95) + FS_SP_ACRATES);
            w = FS_B2_W;
            onButtonClick = "['crateEdit', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class CrateAuto : CrateEdit {
            idc = FS_IDC_A_CRATEAUTO;
            text = "$STR_ALIVE_FS_A_AUTO_BACK";
            x = FS_B2_X(1);
            onButtonClick = "['crateAuto', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class CrateNote : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_A_CRATENOTE;
            y = (FS_H(7.1) + FS_SP_ACRATES);
            h = FS_H(3.4);
        };

        // 3. Logistics picks
        class ListPickLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_A_LISTPICKLABEL;
            text = "$STR_ALIVE_FS_A_LIST";
            y = FS_H(1.15);
        };
        class ListPick : ALiVE_FS_RscCombo {
            idc = FS_IDC_A_LISTPICK;
            x = FS_FIELD_X;
            y = FS_H(1.15);
            onLBSelChanged = "['listPick', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class List : ALiVE_FS_RscListBox {
            idc = FS_IDC_A_LIST;
            y = FS_H(2.3);
            h = (FS_H(4.6) + FS_SP_ALIST);
        };
        class ListNote : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_A_LISTNOTE;
            y = (FS_H(7.05) + FS_SP_ALIST);
            h = FS_H(1.1);
        };
        class ListSourceLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_A_LISTSOURCELABEL;
            text = "$STR_ALIVE_FS_A_SOURCE";
            y = (FS_H(8.25) + FS_SP_ALIST);
        };
        class ListSource : ALiVE_FS_RscCombo {
            idc = FS_IDC_A_LISTSOURCE;
            x = FS_FIELD_X;
            y = (FS_H(8.25) + FS_SP_ALIST);
        };
        class ListAdd : ALiVE_FS_RscButton {
            idc = FS_IDC_A_LISTADD;
            text = "$STR_ALIVE_FS_A_ADD";
            x = FS_B3_X(0);
            y = (FS_H(9.4) + FS_SP_ALIST);
            w = FS_B3_W;
            onButtonClick = "['listAdd', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class ListRemove : ListAdd {
            idc = FS_IDC_A_LISTREMOVE;
            text = "$STR_ALIVE_FS_A_REMOVE";
            x = FS_B3_X(1);
            onButtonClick = "['listRemove', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class ListAuto : ListAdd {
            idc = FS_IDC_A_LISTAUTO;
            text = "$STR_ALIVE_FS_A_AUTO_BACK";
            x = FS_B3_X(2);
            onButtonClick = "['listAuto', _this] call ALiVE_fnc_fsStudioTabAlive";
        };

        // 4. Category redirects
        class RedirFrom : ALiVE_FS_RscListBox {
            idc = FS_IDC_A_REDIRFROM;
            y = FS_H(1.15);
            h = (FS_H(4.6) + FS_SP_AREDIR);
            onLBSelChanged = "['redirFrom', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class RedirToLabel : ALiVE_FS_RscLabel {
            idc = FS_IDC_A_REDIRTOLABEL;
            text = "$STR_ALIVE_FS_A_REDIR_TO";
            y = (FS_H(5.95) + FS_SP_AREDIR);
        };
        class RedirTo : ALiVE_FS_RscCombo {
            idc = FS_IDC_A_REDIRTO;
            x = FS_FIELD_X;
            y = (FS_H(5.95) + FS_SP_AREDIR);
            onLBSelChanged = "['redirTo', _this] call ALiVE_fnc_fsStudioTabAlive";
        };
        class RedirNote : ALiVE_FS_RscStructuredText {
            idc = FS_IDC_A_REDIRNOTE;
            y = (FS_H(7.1) + FS_SP_AREDIR);
            h = FS_H(3.4);
        };
    };
};
