#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(tabletBox);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_tabletBox
Description:
    Returns the screen box every ALiVE tablet is drawn in, as
    [x, y, width, height].

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
    _ctrlBackground ctrlSetPosition [
        0.15 * _uiW + _uiX,
        -0.242 * _uiH + _uiY,
        0.72 * _uiW,
        1.372 * _uiH
    ];
    (end)

See Also:
    addons/main/data/ui/gui_grid.hpp
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

private _h = 1.14 * safezoneH;
private _w = 1.2 * _h;

[
    safezoneX + (safezoneW - _w) / 2,
    safezoneY + (safezoneH - _h) / 2,
    _w,
    _h
]
