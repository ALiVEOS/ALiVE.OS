#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(createMarkerGlobal);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createMarkerGlobal
Description:
Creates a marker all at once

Parameters:
array - marker values

Returns:
bool

Examples:
(begin example)
            [
                _markerName,
                [_markerHash, QGVAR(pos)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(shape)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(size)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(color)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(text)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(type)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(brush)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(dir)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(alpha)] call ALiVE_fnc_hashGet
            ] call ALIVE_fnc_createMarker;
(end)

See Also:
- <ALIVE_fnc_marker>

Author:
Tupolov

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private "_marker";

deleteMarker (_this select 0);

_marker = createMarker [(_this select 0), (_this select 1)];
_marker setMarkerShape (_this select 2);
_marker setMarkerSize (_this select 3);
_marker setMarkerColor (_this select 4);
_marker setMarkerText (_this select 5);
if (count _this > 6) then {
    if ((_this select 6) != "") then {
        _marker setMarkerType (_this select 6);
    };
};
if (count _this > 7) then {
    if ((_this select 7) != "") then {
        _marker setMarkerBrush (_this select 7);
    };
};
if (count _this > 8) then {
    _marker setMarkerDir (_this select 8);
} else {
    _marker setMarkerDir 0;
};
if (count _this > 9) then {
    _marker setMarkerAlpha (_this select 9);
} else {
    _marker setMarkerAlpha 1;
};

_marker