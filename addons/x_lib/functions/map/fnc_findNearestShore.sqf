#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(findNearestShore);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findNearestShore
Description:
Finds the destination-side shoreline on a path from water to land

Parameters:
Array - position
Array - land destination

Returns:
Array - shore-position, [0,0,0] if no shore was found

Examples:
(begin example)
_shorePos = [
        getpos player,
        player getpos [2000,0]
] call ALIVE_fnc_findNearestShore;
(end)

See Also:


Author:
Highhead
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [
    ["_position", [0,0,0], [[]]],
    ["_destination", [0,0,0], [[]]]
];

if (_destination isEqualTo [0,0,0] || {surfaceIsWater _destination}) exitWith {[0,0,0]};
if !(surfaceIsWater _position) exitWith {[0,0,0]};

// Walk from the land destination toward the water position. The first sampled
// water point brackets the destination-side shoreline with the previous land
// point, avoiding a broad random BIS_fnc_findSafePos search.
private _distance = _destination distance2D _position;
if (_distance <= 0) exitWith {[0,0,0]};

private _direction = _destination getDir _position;
private _sampleDistance = 0;
private _sampleStep = 50;
private _landPosition = _destination;
private _waterPosition = [];

while {_sampleDistance < _distance && {_waterPosition isEqualTo []}} do {
    _sampleDistance = (_sampleDistance + _sampleStep) min _distance;
    private _samplePosition = _destination getPos [_sampleDistance, _direction];

    if (surfaceIsWater _samplePosition) then {
        _waterPosition = _samplePosition;
    } else {
        _landPosition = _samplePosition;
    };
};

if (_waterPosition isEqualTo []) exitWith {[0,0,0]};

// Refine the transition to within one metre for a 50 m initial bracket.
for "_i" from 1 to 6 do {
    private _refineDistance = (_landPosition distance2D _waterPosition) / 2;
    private _refineDirection = _landPosition getDir _waterPosition;
    private _samplePosition = _landPosition getPos [_refineDistance, _refineDirection];

    if (surfaceIsWater _samplePosition) then {
        _waterPosition = _samplePosition;
    } else {
        _landPosition = _samplePosition;
    };
};

_landPosition;
