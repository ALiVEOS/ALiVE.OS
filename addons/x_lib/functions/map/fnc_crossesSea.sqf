#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(crossesSea);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_crossesSea
Description:
Checks if direct line to a destination is blocked by sea

Parameters:
Array - position
Array - destination
Scalar - Max Radius to check (optional)

Returns:
Bool - true if crosses sea

Examples:
(begin example)
_crosses_sea = [
        getpos player,
        player getpos [2000,0],
        1000
] call ALIVE_fnc_crossesSea;
(end)

See Also:


Author:
Highhead
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [
    ["_position", [0,0,0], [[]]],
    ["_destination", [0,0,0], [[]]],
    ["_maxDistance", 500, [0]]
];

private _dirTo = _position getDir _destination;
private _onWater = [];
private _distanceToCheck = 250;
private _iteration = 250;

_maxDistance = if (_position distance _destination > _maxDistance) then {(_position distance _destination) + 250} else {_maxDistance};

while {
    private _checkPos = _position getpos [_distanceToCheck,_dirTo];
    
    if (surfaceIsWater _checkPos) then {_onWater pushBack _checkPos} else {_onWater = []};
    
    count _onWater < 2 && {_checkPos distance _destination > 250} && {_distanceToCheck < _maxDistance}
} do {
    _distanceToCheck = _distanceToCheck + _iteration;
};

private _crossesSea = if (count _onWater >= 2) then {true} else {false};

_crossesSea;