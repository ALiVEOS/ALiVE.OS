#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(findBatterySpawnPosition);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findBatterySpawnPosition

Description:
Finds one clear spot for a gun in a battery, spread away from the guns already
placed around the same centre.

Every placement module wanted the same thing and each had grown its own copy of
the search: walk out from the cluster centre in rings, six angles at each of
fifty, eighty, a hundred and ten, a hundred and forty, a hundred and seventy and
two hundred metres, asking the validator about every one of those thirty six
points until something stuck.

That fights the validator instead of using it. The validator already searches a
whole disc, and it already spreads its samples evenly across the area rather
than bunching them near the middle. Its own note says the outer part of the disc
is where open ground usually is, which is exactly what the rings were groping
towards one at a time.

The cost of doing it the old way was severe. The validator's effort is set from
the radius it is given, but never drops below two hundred tries, so each of the
thirty six ring points spent a full two hundred tries searching a circle only
twenty five metres across. Up to seven thousand two hundred tries for one gun,
in thirty six disconnected patches, and thirty six separate airfield lookups on
top. Asked once across the full two hundred metres instead, the same ground
costs two hundred and sixty seven tries and one airfield lookup.

Guns come out spread across the area rather than sitting on rings, which reads
better as a gun line and is a fairer spread of the ground.

Parameters:
_this select 0: ARRAY  - centre to search around
_this select 1: NUMBER - how far out to look, in metres. Default 200
_this select 2: NUMBER - envelope, the room the gun needs. Default 10
_this select 3: ARRAY  - spots already taken, to stay clear of. Default []
_this select 4: NUMBER - how far to stay from those, in metres. Default 25
_this select 5: BOOL   - debug. Default false
_this select 6: STRING - validator mode. Default "field"

Returns:
ARRAY - [position, direction], or [] when there is nowhere clear

Examples:
(begin example)
private _spot = [_clusterCentre, 200, 10, _usedPositions, 25, _debug] call ALiVE_fnc_findBatterySpawnPosition;
if !(_spot isEqualTo []) then {
    _usedPositions pushBack (_spot select 0);
};
(end)

See Also:
- <ALiVE_fnc_findCompositionSpawnPosition>

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_centre",        [],      [[]]],
    ["_radius",        200,     [0]],
    ["_envelope",      10,      [0]],
    ["_used",          [],      [[]]],
    ["_minSeparation", 25,      [0]],
    ["_debug",         false,   [false]],
    ["_mode",          "field", [""]]
];

if (count _centre < 2) exitWith {[]};

// Counted here rather than by each caller. Only civ_placement ever starts this off,
// and the other placement modules would otherwise be adding to something that does not
// exist yet, which stops the gun being placed at all.
if (isNil "ALiVE_DIAG_artyCalls") then { ALiVE_DIAG_artyCalls = 0 };
ALiVE_DIAG_artyCalls = ALiVE_DIAG_artyCalls + 1;

private _result = [];

// The validator picks its spot at random within the disc, so a spot too close to
// a gun already placed is bad luck rather than a dead end, and asking again is
// worth doing. Six goes is plenty: each one searches the whole area, so needing
// more than a couple means the ground is crowded and further tries will not help.
//
// Coming back with nothing is different. That means the validator found nowhere
// clear at all in the whole disc, and asking again would only repeat the same
// search, so give up at once rather than paying for it six times over.
for "_attempt" from 1 to 6 do {
    private _found = [_centre, _radius, _envelope, _mode, random 360, _debug, 0.6] call ALiVE_fnc_findCompositionSpawnPosition;

    if (count _found < 2) exitWith {
        if (_debug) then {
            ["[ALiVE Battery] nowhere clear within %1m of %2", _radius, _centre] call ALiVE_fnc_dump;
        };
    };

    private _candidate = _found select 0;

    if ((_used findIf {_candidate distance2D _x < _minSeparation}) < 0) exitWith {
        _result = _found;
    };
};

_result
