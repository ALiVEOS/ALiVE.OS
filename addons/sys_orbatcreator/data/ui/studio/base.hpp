// ORBAT Creator studio: grid macros and base control classes.
// The 40 x 25 GUI grid always fits inside the safe zone at every interface size.
// Bases inherit the stock Rsc* classes (sizes from the grid), not the classic
// orbatCreator_Rsc* ones, whose sizes are absolute. Colours reuse the COLOR_*
// macros of data\ui\common.hpp, which main.hpp includes first.
// Author: Jman

#define FS_GW               (((safezoneW / safezoneH) min 1.2) / 40)
#define FS_GH               ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
#define FS_X(n)             (safezoneX + (n) * FS_GW)
#define FS_Y(n)             (safezoneY + (n) * FS_GH)
#define FS_PANEL_W          (17 * FS_GW)
#define FS_TEXT             (FS_GH * 0.85)

// sizes and places inside a controls group (relative to the group)
#define FS_W(n)             ((n) * FS_GW)
#define FS_H(n)             ((n) * FS_GH)

// a popup of popW x popH grid cells, centred in the safe zone
#define FS_PX(n,popW)       (safezoneX + (safezoneW - (popW) * FS_GW) / 2 + (n) * FS_GW)
#define FS_PY(n,popH)       (safezoneY + (safezoneH - (popH) * FS_GH) / 2 + (n) * FS_GH)

// one row of the panel
#define FS_ROW_H            (0.9 * FS_GH)

// RscText, RscEdit and RscListBox are already declared by common.hpp;
// declaring them twice makes the config packer warn
class RscCombo;
class RscButtonMenu;
class RscCheckBox;
class RscSlider;
class RscStructuredText;
class RscControlsGroupNoScrollbars;

class ALiVE_FS_RscText : RscText {
    idc = -1;
    style = 0;
    text = "";
    x = 0;
    y = 0;
    w = FS_W(5);
    h = FS_ROW_H;
    sizeEx = FS_TEXT;
    colorText[] = COLOR_WHITE_HARD;
    colorBackground[] = COLOR_BLACK(0);
    shadow = 0;
};

class ALiVE_FS_RscEdit : RscEdit {
    idc = -1;
    text = "";
    x = 0;
    y = 0;
    w = FS_W(11);
    h = FS_ROW_H;
    sizeEx = FS_TEXT;
    colorBackground[] = COLOR_BLACK(0.5);
    colorText[] = {0.95,0.95,0.95,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelection[] = COLOR_ARMA_BG;
    autocomplete = "";
    canModify = 1;
};

class ALiVE_FS_RscCombo : RscCombo {
    idc = -1;
    x = 0;
    y = 0;
    w = FS_W(11);
    h = FS_ROW_H;
    sizeEx = FS_TEXT;
    colorBackground[] = COLOR_GREY_DARK_HARD;
    colorSelectBackground[] = COLOR_ARMA_BG;
    wholeHeight = FS_H(10);
};

class ALiVE_FS_RscListBox : RscListBox {
    idc = -1;
    x = 0;
    y = 0;
    w = FS_W(16);
    h = FS_H(4);
    sizeEx = FS_TEXT;
    rowHeight = FS_ROW_H;
    colorBackground[] = COLOR_BLACK(0.5);
    colorSelectBackground[] = COLOR_ARMA_BG;
    colorSelectBackground2[] = COLOR_ARMA_BG;
};

// LB_MULTI: several rows at once, read with lbSelection
class ALiVE_FS_RscListBoxMulti : ALiVE_FS_RscListBox {
    style = 32;
};

// every button uses onButtonClick, so Tab, Space and Enter work
class ALiVE_FS_RscButton : RscButtonMenu {
    idc = -1;
    text = "";
    x = 0;
    y = 0;
    w = FS_W(5);
    h = FS_ROW_H;
    size = FS_TEXT;
    sizeEx = FS_TEXT;
    colorBackground[] = COLOR_GREY_HARD;
    colorBackgroundFocused[] = COLOR_GREY_LIGHT(1);
    colorBackground2[] = COLOR_GREY_LIGHT(1);
};

class ALiVE_FS_RscCheckBox : RscCheckBox {
    idc = -1;
    x = 0;
    y = 0;
    w = FS_W(0.9);
    h = FS_ROW_H;
};

class ALiVE_FS_RscSlider : RscSlider {
    idc = -1;
    x = 0;
    y = 0;
    w = FS_W(9);
    h = FS_ROW_H;
};

class ALiVE_FS_RscStructuredText : RscStructuredText {
    idc = -1;
    text = "";
    x = 0;
    y = 0;
    w = FS_W(16);
    h = FS_H(2);
    size = FS_TEXT;
    colorBackground[] = COLOR_BLACK(0);
    class Attributes {
        font = "RobotoCondensed";
        color = "#ffffff";
        align = "left";
        valign = "top";
        shadow = 0;
        size = 1;
    };
};

class ALiVE_FS_RscGroup : RscControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = FS_W(16);
    h = FS_H(19.3);
    class controls {};
};

// panel and popup furniture
class ALiVE_FS_RscBackground : ALiVE_FS_RscText {
    colorBackground[] = COLOR_GREY_DARK(0.92);
};

class ALiVE_FS_RscTitle : ALiVE_FS_RscText {
    sizeEx = (FS_GH * 1.1);
    colorBackground[] = COLOR_ARMA_BG;
};

class ALiVE_FS_RscLabel : ALiVE_FS_RscText {
    colorText[] = COLOR_GREY_TITLE_HARD;
};
