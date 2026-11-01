// The Permissions window every player site shares (FOBs, Logistics hubs): who may act on it, one
// or two sets of rules side by side, each with its names list. ALiVE_fnc_siteWhoDialog fills and
// drives it; the site that opens it says what the columns are and sends Apply on to its server.
// Styled as the Manage FOB and Manage Hub windows, with its own copies of their base controls so
// main needs nothing from them. One column is laid out narrower by the script.

class SiteUI_RscText {
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

class SiteUI_RscEdit {
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

class SiteUI_RscButton {
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

class SiteUI_RscStructuredText {
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

class ALiVE_SiteWhoWindow {
    idd = 9295;
    movingEnable = 1;
    onUnload = "['closed'] call ALiVE_fnc_siteWhoDialog";

    class controls {
        class SiteWho_Background: SiteUI_RscText {
            idc = 92950;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.395 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class SiteWho_Header: SiteUI_RscText {
            idc = 92951;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.282 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class SiteWho_Note: SiteUI_RscStructuredText {
            idc = 92952;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.318 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.055 * safezoneH;
        };
        class SiteWho_Title0: SiteUI_RscText {
            idc = 92953;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.375 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0.788,0.443,0.157,1};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class SiteWho_Title1: SiteWho_Title0 { idc = 92954; x = 0.505 * safezoneW + safezoneX; };
        class SiteWho_A0: SiteUI_RscButton {
            idc = 92955;
            style = 0;
            action = "['toggle', [0, 0]] call ALiVE_fnc_siteWhoDialog";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.41 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SiteWho_A1: SiteWho_A0 { idc = 92956; action = "['toggle', [0, 1]] call ALiVE_fnc_siteWhoDialog"; y = 0.45 * safezoneH + safezoneY; };
        class SiteWho_A2: SiteWho_A0 { idc = 92957; action = "['toggle', [0, 2]] call ALiVE_fnc_siteWhoDialog"; y = 0.49 * safezoneH + safezoneY; };
        class SiteWho_A3: SiteWho_A0 { idc = 92958; action = "['toggle', [0, 3]] call ALiVE_fnc_siteWhoDialog"; y = 0.53 * safezoneH + safezoneY; };
        class SiteWho_B0: SiteWho_A0 { idc = 92960; action = "['toggle', [1, 0]] call ALiVE_fnc_siteWhoDialog"; x = 0.505 * safezoneW + safezoneX; };
        class SiteWho_B1: SiteWho_B0 { idc = 92961; action = "['toggle', [1, 1]] call ALiVE_fnc_siteWhoDialog"; y = 0.45 * safezoneH + safezoneY; };
        class SiteWho_B2: SiteWho_B0 { idc = 92962; action = "['toggle', [1, 2]] call ALiVE_fnc_siteWhoDialog"; y = 0.49 * safezoneH + safezoneY; };
        class SiteWho_B3: SiteWho_B0 { idc = 92963; action = "['toggle', [1, 3]] call ALiVE_fnc_siteWhoDialog"; y = 0.53 * safezoneH + safezoneY; };
        class SiteWho_NamesLabel0: SiteUI_RscText {
            idc = 92965;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.57 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
        };
        class SiteWho_NamesLabel1: SiteWho_NamesLabel0 { idc = 92966; x = 0.505 * safezoneW + safezoneX; };
        class SiteWho_Names0: SiteUI_RscEdit {
            idc = 92967;
            maxChars = 2000;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.60 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SiteWho_Names1: SiteWho_Names0 { idc = 92968; x = 0.505 * safezoneW + safezoneX; };
        class SiteWho_Apply: SiteUI_RscButton {
            idc = 92969;
            text = "$STR_ALIVE_SITE_WHO_APPLY";
            action = "['apply'] call ALiVE_fnc_siteWhoDialog";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.655 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SiteWho_Close: SiteUI_RscButton {
            idc = 92970;
            text = "$STR_ALIVE_SITE_WHO_CLOSE";
            action = "closeDialog 0";
            x = 0.575 * safezoneW + safezoneX;
            y = 0.655 * safezoneH + safezoneY;
            w = 0.065 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
