// The screen box every ALiVE tablet is laid out in.
//
// This was copy-pasted identically into eight separate interface headers, and
// separately restated in seventeen places in script. When the box changed, the
// script copies were missed, so the Mapbag backdrop ended up sized a different
// way from the controls drawn on top of it and the two visibly drifted apart.
// Both sides are now single-sourced: this file for anything laid out in config,
// and ALiVE_fnc_tabletBox for anything positioned from script.
//
// KEEP THE TWO IN STEP. Config layout is resolved when the addon is built and
// cannot call a function, which is why the values exist in both places at all.
// If you change anything here, change addons/main/fnc_tabletBox.sqf to match.
//
// Note the box is deliberately taller than the safe zone (1.14) so the tablet
// artwork bleeds past the screen edge rather than floating inside it.

#define GUI_GRID_HAbs        (1.14 * safezoneH)
#define GUI_GRID_WAbs        (1.2 * GUI_GRID_HAbs)
#define GUI_GRID_W           (GUI_GRID_WAbs / 40)
#define GUI_GRID_H           (GUI_GRID_HAbs / 25)
#define GUI_GRID_X           (safezoneX + (safezoneW - GUI_GRID_WAbs) / 2)
#define GUI_GRID_Y           (safezoneY + (safezoneH - GUI_GRID_HAbs) / 2)
