// ORBAT Creator studio: Faction tab (14100). Places are relative to the group.
// Controls are declared in the order the Tab key visits them.
// Author: Jman

class ALiVE_FS_TabFaction : ALiVE_FS_RscGroup {
    idc = FS_IDC_GRP_FACTION;
    x = FS_X(0.5);
    y = FS_Y(FS_TOP);
    w = FS_W(16);
    h = FS_TAB_H;

    class controls {

        class NameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_NAME";
            y = FS_H(0);
        };
        class Name : ALiVE_FS_RscEdit {
            idc = FS_IDC_F_NAME;
            x = FS_FIELD_X;
            y = FS_H(0);
            onKillFocus = "['name', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        class TagLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_TAG";
            tooltip = "$STR_ALIVE_FS_L_TAG_TIP";
            y = FS_H(1.15);
        };
        class Tag : ALiVE_FS_RscEdit {
            idc = FS_IDC_F_TAG;
            tooltip = "$STR_ALIVE_FS_L_TAG_TIP";
            maxChars = 8;
            x = FS_FIELD_X;
            y = FS_H(1.15);
            onKillFocus = "['tag', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        class ClassLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_CLASS";
            y = FS_H(2.3);
        };
        class FactionClass : ALiVE_FS_RscEdit {
            idc = FS_IDC_F_CLASS;
            x = FS_FIELD_X;
            y = FS_H(2.3);
            onKillFocus = "['class', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        class SideLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_SIDE";
            y = FS_H(3.45);
        };
        class Side : ALiVE_FS_RscCombo {
            idc = FS_IDC_F_SIDE;
            x = FS_FIELD_X;
            y = FS_H(3.45);
            onLBSelChanged = "['side', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        class FlagLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_FLAG";
            y = FS_H(4.6);
        };
        class Flag : ALiVE_FS_RscCombo {
            idc = FS_IDC_F_FLAG;
            x = FS_FIELD_X;
            y = FS_H(4.6);
            onLBSelChanged = "['flag', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        class FlagPathLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_FLAG_CUSTOM";
            y = FS_H(5.75);
        };
        class FlagPath : ALiVE_FS_RscEdit {
            idc = FS_IDC_F_FLAGPATH;
            x = FS_FIELD_X;
            y = FS_H(5.75);
            onKillFocus = "['flagPath', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        class AuthorLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_AUTHOR";
            y = FS_H(6.9);
        };
        class Author : ALiVE_FS_RscEdit {
            idc = FS_IDC_F_AUTHOR;
            x = FS_FIELD_X;
            y = FS_H(6.9);
            onKillFocus = "['author', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        class ModNameLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_MODFOLDER";
            y = FS_H(8.05);
        };
        class ModName : ALiVE_FS_RscEdit {
            idc = FS_IDC_F_MODNAME;
            x = FS_FIELD_X;
            y = FS_H(8.05);
            onKillFocus = "['modName', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        // COUNTS and SIZE, filled by the tab
        class Counts : ALiVE_FS_RscText {
            idc = FS_IDC_F_COUNTS;
            y = FS_H(9.55);
            w = FS_W(16);
            colorText[] = COLOR_GREY_TITLE_HARD;
        };

        // library
        class LibTitle : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_LIB_TITLE";
            y = FS_H(11.05);
            w = FS_W(16);
        };
        class LibList : ALiVE_FS_RscListBox {
            idc = FS_IDC_F_LIBLIST;
            y = FS_H(12.2);
            h = (FS_H(4.5) + FS_SP_FLIB);
        };
        class LibSave : ALiVE_FS_RscButton {
            idc = FS_IDC_F_LIBSAVE;
            text = "$STR_ALIVE_FS_LIB_SAVE";
            x = FS_B3_X(0);
            y = (FS_H(16.8) + FS_SP_FLIB);
            w = FS_B3_W;
            onButtonClick = "['libSave', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
        class LibLoad : LibSave {
            idc = FS_IDC_F_LIBLOAD;
            text = "$STR_ALIVE_FS_LIB_LOAD";
            x = FS_B3_X(1);
            onButtonClick = "['libLoad', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
        class LibDelete : LibSave {
            idc = FS_IDC_F_LIBDELETE;
            text = "$STR_ALIVE_FS_BTN_DELETE";
            x = FS_B3_X(2);
            onButtonClick = "['libDelete', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
        class NewFaction : LibSave {
            idc = FS_IDC_F_NEW;
            text = "$STR_ALIVE_FS_LIB_NEW";
            x = FS_B2_X(0);
            y = (FS_H(17.95) + FS_SP_FLIB);
            w = FS_B2_W;
            onButtonClick = "['new', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
        class Restore : NewFaction {
            idc = FS_IDC_F_RESTORE;
            text = "$STR_ALIVE_FS_LIB_RESTORE_SHORT";
            tooltip = "$STR_ALIVE_FS_LIB_RESTORE";
            x = FS_B2_X(1);
            onButtonClick = "['restore', _this] call ALiVE_fnc_fsStudioTabFaction";
        };

        // file in Documents\Arma 3\ALiVE\orbat\import
        class FileLabel : ALiVE_FS_RscLabel {
            text = "$STR_ALIVE_FS_L_IMPORT_FILE";
            tooltip = "$STR_ALIVE_FS_L_IMPORT_FILE_TIP";
            y = (FS_H(19.45) + FS_SP_FLIB);
        };
        class FileName : ALiVE_FS_RscEdit {
            idc = FS_IDC_F_FILENAME;
            tooltip = "$STR_ALIVE_FS_L_IMPORT_FILE_TIP";
            x = FS_FIELD_X;
            y = (FS_H(19.45) + FS_SP_FLIB);
        };

        // import and share text
        class Import : NewFaction {
            idc = FS_IDC_F_IMPORT;
            text = "$STR_ALIVE_FS_IMPORT_BTN";
            x = FS_B2_X(0);
            y = (FS_H(20.6) + FS_SP_FLIB);
            onButtonClick = "['import', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
        class FileLoad : Import {
            idc = FS_IDC_F_FILELOAD;
            text = "$STR_ALIVE_FS_FILE_LOAD";
            x = FS_B2_X(1);
            onButtonClick = "['file', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
        class ShareCopy : Import {
            idc = FS_IDC_F_COPY;
            text = "$STR_ALIVE_FS_SHARE_COPY_SHORT";
            tooltip = "$STR_ALIVE_FS_SHARE_COPY";
            x = FS_B2_X(0);
            y = (FS_H(21.75) + FS_SP_FLIB);
            onButtonClick = "['copy', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
        class SharePaste : ShareCopy {
            idc = FS_IDC_F_PASTE;
            text = "$STR_ALIVE_FS_SHARE_PASTE_SHORT";
            tooltip = "$STR_ALIVE_FS_SHARE_PASTE";
            x = FS_B2_X(1);
            onButtonClick = "['paste', _this] call ALiVE_fnc_fsStudioTabFaction";
        };
    };
};
