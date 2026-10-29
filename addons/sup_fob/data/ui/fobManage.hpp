// The FOB window, from Manage FOB within 25 m of one of the side's FOBs: its state, tier and supply,
// its name to change, and Build Menu, Upgrade, Repair and Dismantle, with the server's answer to the
// last of them on the line underneath. One window rather than an action for each (A. Ares on
// Discord, 15 Oct). ALiVE_fnc_fobActions fills and drives it. Uses the FobUI_ base classes, so it
// is included after fobBuild.hpp.

class ALiVE_FobWindow {
    idd = 9283;
    movingEnable = 1;
    onUnload = "['manageClosed'] call ALiVE_fnc_fobActions";

    class controls {
        class FobManage_Background: FobUI_RscText {
            idc = -1;
            x = 0.37 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.435 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class FobManage_Header: FobUI_RscText {
            idc = 92840;
            text = "";
            x = 0.37 * safezoneW + safezoneX;
            y = 0.282 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class FobManage_Status: FobUI_RscStructuredText {
            idc = 92841;
            x = 0.38 * safezoneW + safezoneX;
            y = 0.32 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.10 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobManage_NameLabel: FobUI_RscText {
            idc = -1;
            text = "$STR_ALIVE_FOB_UI_NAME";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.035 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class FobManage_Name: FobUI_RscEdit {
            idc = 92842;
            maxChars = 32;
            x = 0.42 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.13 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobManage_Rename: FobUI_RscButton {
            idc = 92843;
            default = 1;
            text = "$STR_ALIVE_FOB_RENAME_OK";
            action = "['manageDo', 'RENAME'] call ALiVE_fnc_fobActions";
            x = 0.555 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobManage_Build: FobUI_RscButton {
            idc = 92844;
            text = "$STR_ALIVE_FOB_ACTION_BUILD";
            action = "['manageDo', 'BUILD'] call ALiVE_fnc_fobActions";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.48 * safezoneH + safezoneY;
            w = 0.115 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobManage_Upgrade: FobUI_RscButton {
            idc = 92845;
            text = "$STR_ALIVE_FOB_ACTION_UPGRADE";
            action = "['manageDo', 'UPGRADE'] call ALiVE_fnc_fobActions";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.48 * safezoneH + safezoneY;
            w = 0.115 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobManage_Repair: FobUI_RscButton {
            idc = 92846;
            text = "$STR_ALIVE_FOB_ACTION_REPAIR";
            action = "['manageDo', 'REPAIR'] call ALiVE_fnc_fobActions";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.115 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobManage_Dismantle: FobUI_RscButton {
            idc = 92847;
            text = "$STR_ALIVE_FOB_ACTION_DISMANTLE";
            action = "['manageDo', 'DISMANTLE'] call ALiVE_fnc_fobActions";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.115 * safezoneW;
            h = 0.035 * safezoneH;
        };
        // FOB Types: the types this FOB can become, and Change Type (shown by ALiVE_fnc_fobActions only
        // when the mission has types)
        class FobManage_TypeLabel: FobUI_RscText {
            idc = 92864;
            text = "$STR_ALIVE_FOB_UI_TYPE";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.57 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.035 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class FobManage_TypeList: FobUI_RscCombo {
            idc = 92862;
            x = 0.42 * safezoneW + safezoneX;
            y = 0.57 * safezoneH + safezoneY;
            w = 0.13 * safezoneW;
            h = 0.035 * safezoneH;
            onLBSelChanged = "['manageTypePicked'] call ALiVE_fnc_fobActions";
        };
        class FobManage_TypeChange: FobUI_RscButton {
            idc = 92863;
            text = "$STR_ALIVE_FOB_UI_CHANGE_TYPE";
            action = "['manageDo', 'RETYPE'] call ALiVE_fnc_fobActions";
            x = 0.555 * safezoneW + safezoneX;
            y = 0.57 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
        };
        // the server's answer to the last thing asked for here
        class FobManage_Feedback: FobUI_RscStructuredText {
            idc = 92848;
            x = 0.38 * safezoneW + safezoneX;
            y = 0.615 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.075 * safezoneH;
            colorBackground[] = {0,0,0,0.3};
        };
        // admins only (shown by ALiVE_fnc_fobActions): opens the Permissions window
        class FobManage_Perm: FobUI_RscButton {
            idc = 92860;
            text = "$STR_ALIVE_FOB_UI_PERMISSIONS";
            action = "['permOpen'] call ALiVE_fnc_fobActions";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.70 * safezoneH + safezoneY;
            w = 0.1 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobManage_Close: FobUI_RscButton {
            idc = 92849;
            text = "$STR_ALIVE_FOB_UI_CLOSE";
            action = "closeDialog 0";
            x = 0.555 * safezoneW + safezoneX;
            y = 0.70 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};

// The Permissions window, for admins: Who Can Dismantle and its list, for every FOB. Opened from
// the FOB window's Permissions button or from the ALiVE admin menu, wherever the admin is.
// ALiVE_fnc_fobActions fills and drives it; the server checks the sender is an admin.
class ALiVE_FobPermWindow {
    idd = 9285;
    movingEnable = 1;
    onUnload = "ALiVE_FOB_permDraft = nil";

    class controls {
        class FobPerm_Background: FobUI_RscText {
            idc = 92850;
            x = 0.4 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.39 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class FobPerm_Header: FobUI_RscText {
            idc = 92851;
            text = "$STR_ALIVE_FOB_MANAGE_WHO";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.282 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class FobPerm_Note: FobUI_RscStructuredText {
            idc = 92852;
            text = "$STR_ALIVE_FOB_UI_PERMISSIONS_NOTE";
            x = 0.41 * safezoneW + safezoneX;
            y = 0.32 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.065 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class FobPerm_Side: FobUI_RscButton {
            idc = 92853;
            action = "['permToggle', 'SIDE'] call ALiVE_fnc_fobActions";
            style = 0;
            x = 0.41 * safezoneW + safezoneX;
            y = 0.39 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobPerm_Leader: FobPerm_Side {
            idc = 92854;
            action = "['permToggle', 'LEADER'] call ALiVE_fnc_fobActions";
            y = 0.43 * safezoneH + safezoneY;
        };
        class FobPerm_Deployer: FobPerm_Side {
            idc = 92855;
            action = "['permToggle', 'DEPLOYER'] call ALiVE_fnc_fobActions";
            y = 0.47 * safezoneH + safezoneY;
        };
        class FobPerm_List: FobPerm_Side {
            idc = 92856;
            action = "['permToggle', 'LIST'] call ALiVE_fnc_fobActions";
            y = 0.51 * safezoneH + safezoneY;
        };
        class FobPerm_Names: FobUI_RscEdit {
            idc = 92857;
            maxChars = 2000;
            tooltip = "$STR_ALIVE_FOB_MANAGE_LIST_EDIT_COMMENT";
            x = 0.41 * safezoneW + safezoneX;
            y = 0.585 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobPerm_NamesLabel: FobUI_RscText {
            idc = 92858;
            text = "$STR_ALIVE_FOB_MANAGE_LIST_EDIT";
            x = 0.41 * safezoneW + safezoneX;
            y = 0.553 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class FobPerm_Apply: FobUI_RscButton {
            idc = 92859;
            text = "$STR_ALIVE_FOB_UI_APPLY";
            action = "['permApply'] call ALiVE_fnc_fobActions";
            x = 0.455 * safezoneW + safezoneX;
            y = 0.655 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class FobPerm_Close: FobUI_RscButton {
            idc = 92861;
            text = "$STR_ALIVE_FOB_UI_CLOSE";
            action = "closeDialog 0";
            x = 0.525 * safezoneW + safezoneX;
            y = 0.655 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
