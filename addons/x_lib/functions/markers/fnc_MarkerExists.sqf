#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(markerExists);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerExists
Description:
Checks if the marker given exists on map

Parameters:
Markername

Returns:
Bool - Returns true if marker exists

Examples:
(begin example)
_Exists = ["respawn_west"] call ALIVE_fnc_markerExists;
(end)

See Also:
- nil

Author:
Highhead
Wolffy

Peer reviewed:
Wolffy 20130602
---------------------------------------------------------------------------- */
private ["_markername"];

PARAMS_1(_markername);

!(str markerPos _markername == "[0,0,0]");