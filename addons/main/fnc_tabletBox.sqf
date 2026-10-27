#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(tabletBox);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_tabletBox
Description:
    Returns the content box every ALiVE tablet's controls are laid out in, as
    [x, y, width, height]. The tablet artwork itself uses ALiVE_fnc_tabletFrameBox.

    The tablet screens themselves are laid out by the GUI_GRID macros in each
    module's data/ui/common.hpp. Anything that positions artwork from script
    has to arrive at the same box, or the artwork and the controls drawn on it
    drift apart. That is exactly what happened to the Mapbag backdrop: the
    macros were changed and the seventeen hand-written copies in script were
    not, so the backdrop ended up sized a different way from the controls, and
    the gap widened the further a player moved the interface size setting from
    its default.

    Use this rather than restating the numbers.

    IMPORTANT: the same values are also defined as preprocessor macros in
    addons/main/data/ui/gui_grid.hpp, because config layout is resolved when
    the addon is built and cannot call a function. The two must be kept in
    step; each carries a note pointing at the other.

Parameters:
    None.

Returns:
    ARRAY - [x, y, width, height] in screen coordinates.

Examples:
    (begin example)
    ([] call ALiVE_fnc_tabletBox) params ["_uiX","_uiY","_uiW","_uiH"];
    _ctrl ctrlSetPosition [0.30 * _uiW + _uiX, 0.20 * _uiH + _uiY, 0.10 * _uiW, 0.028 * _uiH];
    (end)

See Also:
    addons/main/data/ui/gui_grid.hpp, ALiVE_fnc_tabletFrameBox
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

// Content box (gui_grid.hpp GUI_GRID_*): the controls' fractions 0.2638..0.7463 x
// 0.1068..0.7800 mapped onto the frame's screen window. On the wide Modern frame
// (ALiVE_fnc_tabletOpen sets uiNamespace "ALiVE_tabletWide") it is stretched
// sideways about the screen centre by the wide screen's extra width, 1148 / 940.
([] call ALiVE_fnc_tabletFrameBox) params ["_fx", "_fy", "_fw", "_fh"];
private _wide = uiNamespace getVariable ["ALiVE_tabletWide", false];

// the 1160-wide frame this layout is drawn for, whichever frame is showing
private _fw43 = 0.99864 * safezoneH;
private _fx43 = safezoneX + (safezoneW - _fw43) / 2;
private _w = 1.679471 * _fw43;
private _h = 1.271710 * _fh;
private _x = _fx43 + 0.094828 * _fw43 - 0.2638 * _w;
private _y = _fy + 0.076739 * _fh - 0.1068 * _h;

if (_wide) then {
    private _c = safezoneX + safezoneW / 2;
    private _k = 1148 / 940;
    _x = _c + (_x - _c) * _k;
    _w = _w * _k;
};

[_x, _y, _w, _h]
