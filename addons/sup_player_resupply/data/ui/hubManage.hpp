// The Manage Hub window (Jman, 29 Oct), from Manage Hub at one of the side's Logistics Hubs: its
// state, who may collect, what it offers, its name to change, Permissions and Dismantle. Styled as
// the Manage FOB window, with its own copies of the base controls so it needs nothing from Player
// FOBs. ALiVE_fnc_hubManage fills and drives both windows. Sizes and layout follow the FOB windows
// (sup_fob/data/ui/fobManage.hpp), so keep the two in step.

class HubUI_RscText {
    access = 0;
    type = 0;
    idc = -1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0.037;
    w = 0.3;
    style = 0;
    shadow = 1;
    colorShadow[] = {0,0,0,0.5};
    font = "PuristaMedium";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    linespacing = 1;
};

class HubUI_RscEdit {
    access = 0;
    type = 2;
    style = 0;
    idc = -1;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.03;
    font = "PuristaMedium";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
    text = "";
    autocomplete = "";
    shadow = 0;
    colorBackground[] = {0,0,0,0.5};
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelection[] = {1,1,1,0.25};
    canModify = 1;
};

class HubUI_RscButton {
    access = 0;
    type = 1;
    text = "";
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelect[] = {0,0,0,1};
    colorSelect2[] = {0,0,0,1};
    colorBackground[] = {0,0,0,0.5};
    colorBackgroundDisabled[] = {0,0,0,0.5};
    // hover and focus stay dark enough for the white text, as on the FOB windows
    colorBackgroundActive[] = {0.384,0.439,0.341,1};
    colorFocused[] = {0.2,0.2,0.2,0.9};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,1};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
    textureNoShortcut = "";
    animTextureNormal = "";
    animTextureDisabled = "";
    animTextureOver = "";
    animTextureFocused = "";
    animTexturePressed = "";
    animTextureDefault = "";
    style = 2;
    x = 0;
    y = 0;
    w = 0.095589;
    h = 0.039216;
    shadow = 2;
    font = "PuristaMedium";
    sizeEx = "0.024 * safezoneH";
    offsetX = 0.003;
    offsetY = 0.003;
    offsetPressedX = 0.000;
    offsetPressedY = 0.002;
    borderSize = 0;
    class Attributes {
        font = "PuristaMedium";
        color = "#C0C0C0";
        align = "center";
        valign = "middle";
        shadow = true;
        shadowColor = "#000000";
    };
};

class HubUI_RscStructuredText {
    access = 0;
    type = 13;
    idc = -1;
    style = 0;
    colorText[] = {1,1,1,1};
    colorBackground[] = {0,0,0,0};
    class Attributes {
        font = "PuristaMedium";
        color = "#ffffff";
        align = "left";
        shadow = 1;
    };
    x = 0;
    y = 0;
    h = 0.035;
    w = 0.1;
    text = "";
    size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    shadow = 1;
};

class ALiVE_HubWindow {
    idd = 9291;
    movingEnable = 1;
    onUnload = "['closed'] call ALiVE_fnc_hubManage";

    class controls {
        class HubManage_Background: HubUI_RscText {
            x = 0.37 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.465 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class HubManage_Header: HubUI_RscText {
            idc = 92910;
            x = 0.37 * safezoneW + safezoneX;
            y = 0.282 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        // side, state, who may collect, what it offers, whether the AI Commanders supply from it
        class HubManage_Status: HubUI_RscStructuredText {
            idc = 92911;
            x = 0.38 * safezoneW + safezoneX;
            y = 0.32 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.22 * safezoneH;
        };
        class HubManage_NameLabel: HubUI_RscText {
            text = "$STR_ALIVE_HUB_UI_NAME";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.55 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.035 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class HubManage_Name: HubUI_RscEdit {
            idc = 92912;
            maxChars = 32;
            tooltip = "$STR_ALIVE_HUB_UI_NAME_TIP";
            x = 0.42 * safezoneW + safezoneX;
            y = 0.55 * safezoneH + safezoneY;
            w = 0.13 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class HubManage_Rename: HubUI_RscButton {
            idc = 92913;
            default = 1;
            text = "$STR_ALIVE_HUB_UI_RENAME";
            action = "['do', 'RENAME'] call ALiVE_fnc_hubManage";
            x = 0.555 * safezoneW + safezoneX;
            y = 0.55 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class HubManage_Perm: HubUI_RscButton {
            idc = 92914;
            text = "$STR_ALIVE_HUB_UI_PERMISSIONS";
            action = "['permOpen'] call ALiVE_fnc_hubManage";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.73 * safezoneH + safezoneY;
            w = 0.1 * safezoneW;
            h = 0.035 * safezoneH;
        };
        // the Player Logistics tablet with Collect at a Hub picked, where Build Menu sits on the FOB window
        class HubManage_Collect: HubUI_RscButton {
            idc = 92918;
            text = "$STR_ALIVE_HUB_UI_COLLECT";
            action = "['collect'] call ALiVE_fnc_hubManage";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.60 * safezoneH + safezoneY;
            w = 0.115 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class HubManage_Dismantle: HubUI_RscButton {
            idc = 92915;
            text = "$STR_ALIVE_HUB_UI_DISMANTLE";
            action = "['do', 'DISMANTLE'] call ALiVE_fnc_hubManage";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.60 * safezoneH + safezoneY;
            w = 0.115 * safezoneW;
            h = 0.035 * safezoneH;
        };
        // the server's answer to the last thing asked for here
        class HubManage_Feedback: HubUI_RscStructuredText {
            idc = 92916;
            x = 0.38 * safezoneW + safezoneX;
            y = 0.645 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.075 * safezoneH;
            colorBackground[] = {0,0,0,0.3};
        };
        class HubManage_Close: HubUI_RscButton {
            idc = 92917;
            text = "$STR_ALIVE_HUB_UI_CLOSE";
            action = "closeDialog 0";
            x = 0.555 * safezoneW + safezoneX;
            y = 0.73 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};

// Permissions for one hub's module: Who Can Collect and Who Can Dismantle side by side, each with
// its list of players, sent with Apply. Admins, and players Who Can Dismantle lets in, may change them.
class ALiVE_HubPermWindow {
    idd = 9292;
    movingEnable = 1;
    onUnload = "ALiVE_hub_permDraft = nil";

    class controls {
        class HubPerm_Background: HubUI_RscText {
            x = 0.35 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.395 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class HubPerm_Header: HubUI_RscText {
            idc = 92921;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.282 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class HubPerm_Note: HubUI_RscStructuredText {
            idc = 92922;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.318 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.055 * safezoneH;
        };
        class HubPerm_CollectTitle: HubUI_RscText {
            text = "$STR_ALIVE_HUB_COLLECT_WHO";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.375 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0.788,0.443,0.157,1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class HubPerm_DismantleTitle: HubPerm_CollectTitle {
            text = "$STR_ALIVE_HUB_DISMANTLE_WHO";
            x = 0.505 * safezoneW + safezoneX;
        };
        class HubPerm_C1: HubUI_RscButton {
            idc = 92925;
            style = 0;
            action = "['permToggle', [0, 'SIDE']] call ALiVE_fnc_hubManage";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.41 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class HubPerm_C2: HubPerm_C1 { idc = 92926; action = "['permToggle', [0, 'LEADER']] call ALiVE_fnc_hubManage"; y = 0.45 * safezoneH + safezoneY; };
        class HubPerm_C3: HubPerm_C1 { idc = 92927; action = "['permToggle', [0, 'ITEM']] call ALiVE_fnc_hubManage"; y = 0.49 * safezoneH + safezoneY; };
        class HubPerm_C4: HubPerm_C1 { idc = 92928; action = "['permToggle', [0, 'LIST']] call ALiVE_fnc_hubManage"; y = 0.53 * safezoneH + safezoneY; };
        class HubPerm_D1: HubPerm_C1 { idc = 92929; action = "['permToggle', [1, 'SIDE']] call ALiVE_fnc_hubManage"; x = 0.505 * safezoneW + safezoneX; };
        class HubPerm_D2: HubPerm_D1 { idc = 92930; action = "['permToggle', [1, 'LEADER']] call ALiVE_fnc_hubManage"; y = 0.45 * safezoneH + safezoneY; };
        class HubPerm_D3: HubPerm_D1 { idc = 92931; action = "['permToggle', [1, 'ITEM']] call ALiVE_fnc_hubManage"; y = 0.49 * safezoneH + safezoneY; };
        class HubPerm_D4: HubPerm_D1 { idc = 92932; action = "['permToggle', [1, 'LIST']] call ALiVE_fnc_hubManage"; y = 0.53 * safezoneH + safezoneY; };
        class HubPerm_CNamesLabel: HubUI_RscText {
            text = "$STR_ALIVE_HUB_COLLECT_LIST";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.57 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class HubPerm_DNamesLabel: HubPerm_CNamesLabel {
            text = "$STR_ALIVE_HUB_DISMANTLE_LIST";
            x = 0.505 * safezoneW + safezoneX;
        };
        class HubPerm_CNames: HubUI_RscEdit {
            idc = 92935;
            maxChars = 2000;
            tooltip = "$STR_ALIVE_HUB_COLLECT_LIST_COMMENT";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.60 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class HubPerm_DNames: HubPerm_CNames {
            idc = 92936;
            tooltip = "$STR_ALIVE_HUB_DISMANTLE_LIST_COMMENT";
            x = 0.505 * safezoneW + safezoneX;
        };
        class HubPerm_Apply: HubUI_RscButton {
            idc = 92937;
            text = "$STR_ALIVE_HUB_UI_APPLY";
            action = "['permApply'] call ALiVE_fnc_hubManage";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.655 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class HubPerm_Close: HubUI_RscButton {
            idc = 92938;
            text = "$STR_ALIVE_HUB_UI_CLOSE";
            action = "closeDialog 0";
            x = 0.575 * safezoneW + safezoneX;
            y = 0.655 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
