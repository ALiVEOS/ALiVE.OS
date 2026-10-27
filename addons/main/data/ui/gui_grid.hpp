// The boxes every ALiVE tablet is laid out in.
//
// This was copy-pasted identically into eight separate interface headers, and
// separately restated in seventeen places in script. When the box changed, the
// script copies were missed, so the Mapbag backdrop ended up sized a different
// way from the controls drawn on top of it and the two visibly drifted apart.
// Both sides are now single-sourced: this file for anything laid out in config,
// and ALiVE_fnc_tabletBox / ALiVE_fnc_tabletFrameBox for anything positioned
// from script.
//
// KEEP THEM IN STEP. Config layout is resolved when the addon is built and
// cannot call a function, which is why the values exist in both places at all.
// If you change anything here, change addons/main/fnc_tabletBox.sqf and
// addons/main/fnc_tabletFrameBox.sqf to match.
//
// Two boxes (Jman, era tablets):
// - TABLET_FRAME_* is the tablet artwork (ALiVE_tablet_<era>_ca.paa), drawn
//   from a 1160 x 834 design. Its screen window is design px 100..1060 x
//   56..786 and its eight keys sit at x 26..86 / 1074..1134, y 260 + 86 * i.
// - GUI_GRID_* is the content box every existing control is laid out in. The
//   controls' own fractions run from x 0.2638 to 0.7463 and y 0.1068 to 0.7800
//   (measured across all eight tablets, runtime positions included), so the box
//   is sized to map exactly that range onto the screen window, 10 px inside it.
// Everything scales with safezoneH, so it follows resolution, aspect ratio and
// the interface size setting (b1bc5cda).
// The wide Modern frame (1368 x 834) is applied from script at open time by
// ALiVE_fnc_tabletOpen; config always describes the 1160-wide frame.

#define TABLET_FRAME_HAbs    (0.9576 * safezoneH)
#define TABLET_FRAME_WAbs    (0.99864 * safezoneH)
#define TABLET_FRAME_X       (safezoneX + (safezoneW - TABLET_FRAME_WAbs) / 2)
#define TABLET_FRAME_Y       (safezoneY + (safezoneH - TABLET_FRAME_HAbs) / 2)

// the frame picture: the frame plus the 40 px shadow margin its artwork carries all round
#define TABLET_ART_X         (TABLET_FRAME_X - 0.034483 * TABLET_FRAME_WAbs)
#define TABLET_ART_Y         (TABLET_FRAME_Y - 0.047962 * TABLET_FRAME_HAbs)
#define TABLET_ART_WAbs      (1.068966 * TABLET_FRAME_WAbs)
#define TABLET_ART_HAbs      (1.095923 * TABLET_FRAME_HAbs)

#define GUI_GRID_WAbs        (1.679471 * TABLET_FRAME_WAbs)
#define GUI_GRID_HAbs        (1.271710 * TABLET_FRAME_HAbs)
#define GUI_GRID_W           (GUI_GRID_WAbs / 40)
#define GUI_GRID_H           (GUI_GRID_HAbs / 25)
#define GUI_GRID_X           (TABLET_FRAME_X + 0.094828 * TABLET_FRAME_WAbs - 0.2638 * GUI_GRID_WAbs)
#define GUI_GRID_Y           (TABLET_FRAME_Y + 0.076739 * TABLET_FRAME_HAbs - 0.1068 * GUI_GRID_HAbs)

// The painted keys: L1..L4 down the left, R1..R4 down the right (R3 Back, R4 Close).
// Used as TABLET_KEY(TABLET_KEY_RX, row) in a button class.
#define TABLET_KEY_W         (0.051724 * TABLET_FRAME_WAbs)
#define TABLET_KEY_H         (0.076739 * TABLET_FRAME_HAbs)
#define TABLET_KEY_LX        (TABLET_FRAME_X + 0.022414 * TABLET_FRAME_WAbs)
#define TABLET_KEY_RX        (TABLET_FRAME_X + 0.925862 * TABLET_FRAME_WAbs)
#define TABLET_KEY_Y(ROW)    (TABLET_FRAME_Y + (0.311751 + 0.103118 * ROW) * TABLET_FRAME_HAbs)
#define TABLET_KEY_FONT      (0.28 * GUI_GRID_H)

// A button laid on a painted key: the artwork is the button. Every key is a plain CT_BUTTON
// (type 1) whatever its dialog's buttons are, because a CT_SHORTCUTBUTTON keeps separate text
// colours for focus and hover that a script cannot set, and its label vanished on a key that kept
// focus after a click. Action, idc and event handlers carry over unchanged.
// The text colour, font and short label follow the era and are set by ALiVE_fnc_tabletOpen.
#define TABLET_KEY(KEYX,ROW) \
    type = 1; \
    x = KEYX; \
    y = TABLET_KEY_Y(ROW); \
    w = TABLET_KEY_W; \
    h = TABLET_KEY_H; \
    style = 0x02; \
    shadow = 0; \
    sizeEx = TABLET_KEY_FONT; \
    colorText[] = {0.86,0.88,0.84,1}; \
    colorDisabled[] = {0.5,0.5,0.48,0.75}; \
    colorBackground[] = {0,0,0,0}; \
    colorBackgroundActive[] = {1,1,1,0.12}; \
    colorBackgroundDisabled[] = {0,0,0,0}; \
    colorFocused[] = {1,1,1,0.06}; \
    colorShadow[] = {0,0,0,0}; \
    colorBorder[] = {0,0,0,0}; \
    borderSize = 0; \
    offsetX = 0; \
    offsetY = 0; \
    offsetPressedX = 0; \
    offsetPressedY = 0
