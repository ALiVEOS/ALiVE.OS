#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(iedSpotters);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_iedSpotters
Description:
The insurgent groups that have spotted a player: groups of the given sides, led by a live AI, between the two
distances from him, whose leader knows about him (knowsAbout 1.5 or more). Read on the server; it reads a group a
headless client owns the same as that client does (measured). Used by the bomber and FPV drone dispatcher, once per
player per poll.

Parameters:
0: OBJECT - the player, or the vehicle he is in
1: NUMBER - nearest distance in metres
2: NUMBER - furthest distance in metres
3: ARRAY - the insurgent sides

Returns:
ARRAY - [[group, distance], ...]

Author:
Jman
---------------------------------------------------------------------------- */

params [["_target", objNull, [objNull]], ["_min", 0, [0]], ["_max", 0, [0]], ["_sides", [], [[]]]];

if (isNull _target || {_sides isEqualTo []} || {_max <= _min}) exitWith { [] };

private _found = [];
{
    private _l = leader _x;
    // a drone's own crew is a group of its side too: left out, or a drone could launch another drone
    if ((side _x) in _sides && {alive _l} && {!isPlayer _l} && {!unitIsUAV _l} && {!((vehicle _l) isKindOf "Air")}) then {
        private _dist = _l distance _target;
        if (_dist > _min && {_dist < _max} && {(_l knowsAbout _target) >= 1.5}) then { _found pushBack [_x, _dist] };
    };
} forEach allGroups;
_found
