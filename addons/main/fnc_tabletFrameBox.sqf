#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(tabletFrameBox);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_tabletFrameBox
Description:
    Returns the box the tablet artwork is drawn in, as [x, y, width, height]:
    the 1160 x 834 design, or the 1368 x 834 wide Modern design when
    ALiVE_fnc_tabletOpen chose it (uiNamespace "ALiVE_tabletWide").

    IMPORTANT: the 1160-wide box is also defined as TABLET_FRAME_* macros in
    addons/main/data/ui/gui_grid.hpp. Keep the two in step.

Parameters:
    0: BOOL (optional) - wide frame; defaults to the one last opened

Returns:
    ARRAY - [x, y, width, height] in screen coordinates.

Examples:
    (begin example)
    ([] call ALiVE_fnc_tabletFrameBox) params ["_fx","_fy","_fw","_fh"];
    (end)

See Also:
    ALiVE_fnc_tabletBox, ALiVE_fnc_tabletOpen
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_wide", uiNamespace getVariable ["ALiVE_tabletWide", false], [false]]];

private _h = 0.9576 * safezoneH;
private _w = 0.99864 * safezoneH * ([1, 1368 / 1160] select _wide);

[
    safezoneX + (safezoneW - _w) / 2,
    safezoneY + (safezoneH - _h) / 2,
    _w,
    _h
]
