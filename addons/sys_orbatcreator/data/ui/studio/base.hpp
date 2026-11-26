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

// columns of a tab (16 cells wide, relative to the tab group); every tab uses
// the same label column and field x, so fields line up across the tabs
#define FS_LABEL_W          FS_W(5.9)
#define FS_FIELD_X          FS_W(6)
#define FS_FIELD_W          FS_W(10)
// a field that shares its row with the side column (checkbox, Pick, value)
#define FS_NARROW_W         FS_W(6.9)
#define FS_SIDE_X           FS_W(13)
#define FS_SIDE_W           FS_W(3)

// button rows: 2 or 3 equal buttons across the tab's 16 cells, 0.3 apart
#define FS_B2_W             FS_W(7.85)
#define FS_B2_X(i)          FS_W((i) * 8.15)
#define FS_B3_W             FS_W(15.4 / 3)
#define FS_B3_X(i)          FS_W((i) * (15.4 / 3 + 0.3))

// Tab spacing (Jman 17 Nov, "a little too compact"): rows sit 1.15 cells apart (a quarter-row gap under
// a 0.9 row) and each group of controls starts 0.35 further down. A tab uses the whole height between
// the tab buttons and the status box, which sits at the bottom of the screen; on a short screen the tab
// scrolls.
#define FS_STATUS_H         2.1
// the header picture is FS_HEAD_H tall; under it the faction line at FS_FACTION_Y, the tab buttons at FS_TABS_Y
// and the tabs at FS_TOP, with clear space between the three (Jman 18 Nov)
#define FS_HEAD_H           2.0
#define FS_FACTION_Y        2.45
#define FS_FACTION_H        0.95
#define FS_TABS_Y           3.7
#define FS_TABS_H           1.3
#define FS_TOP              5.45
#define FS_TAB_H            (safezoneH - FS_GH * (FS_TOP + FS_STATUS_H + 0.4))

// Height the tab has left once its rows are laid out at their smallest (used = the cells those rows take). The
// tab's lists share it, so the rows reach the status box at every UI size; on a short screen it is 0 and the tab
// scrolls as before.
#define FS_SPARE(used)      ((FS_TAB_H - FS_H(used)) max 0)
#define FS_SP_FLIB          FS_SPARE(22.8)
#define FS_SP_GLIST         (FS_SPARE(23.7) * 0.6)
#define FS_SP_GMEMBERS      (FS_SPARE(23.7) * 0.4)
// the Units rows allow for an 8-cell loadout summary, the Vehicles rows for a full six-row parts list
#define FS_SP_ULIST         FS_SPARE(31.35)
#define FS_SP_VLIST         (FS_SPARE(30.9) * 0.6)
#define FS_SP_VSEATS        (FS_SPARE(30.9) * 0.4)
#define FS_SP_ACRATES       FS_SPARE(12.9)
#define FS_SP_ALIST         FS_SPARE(10.4)
#define FS_SP_AREDIR        FS_SPARE(10.6)
#define FS_SP_ERESULTS      FS_SPARE(23.7)

// RscText, RscEdit and RscListBox are already declared by common.hpp;
// declaring them twice makes the config packer warn
class RscCombo;
class RscButtonMenu;
class RscCheckBox;
class RscSlider;
class RscStructuredText;
class RscControlsGroupNoScrollbars;
class RscControlsGroupNoHScrollbars;

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
    w = FS_FIELD_W;
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
    w = FS_FIELD_W;
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
    // the stock RscButtonMenu puts its text at the top left (TextPos top works out at 0); studio buttons
    // centre it both ways: top is half the space left over by the text. A button of another height
    // overrides TextPos with its own h. No left margin, so a short tab label is not clipped.
    class TextPos {
        left = 0;
        top = ((FS_ROW_H) - (FS_TEXT)) / 2;
        right = 0;
        bottom = 0;
    };
    // the stock RscButtonMenu puts its text on the left; studio buttons centre it
    class Attributes {
        font = "PuristaLight";
        color = "#E5E5E5";
        align = "center";
        shadow = "false";
    };
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

// a vertical scrollbar shows only when a tab is taller than the screen leaves room for
class ALiVE_FS_RscGroup : RscControlsGroupNoHScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = FS_W(16);
    h = FS_TAB_H;
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
    w = FS_LABEL_W;
    colorText[] = COLOR_GREY_TITLE_HARD;
};
