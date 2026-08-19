#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetStateOfObjects);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetStateOfVehicleProfiles

Description:
Get the current state of some vehicle profiles

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

// How far below its own terrain surface an object has to sit before we treat it as
// hidden rather than standing. A static building's origin sits at terrain level by
// construction, so anything this far under is the engine having put it away. The
// reporter's logs on #1002 show intact huts at -0.19 and +0.03, and the destroyed one
// at -95.001, so there is a very wide margin either side of this figure.
#define SUNK_BELOW_TERRAIN -20

private ["_targets","_state"];

_targets = _this select 0;

_state = [] call ALIVE_fnc_hashCreate;
[_state,"allDestroyed",true] call ALIVE_fnc_hashSet;

private _output = [];

{
    private ["_target"];

    _target = _x;
    _output pushback _target;

    // Whether a building has been brought down cannot be read from any single property,
    // which is what #1002 turned out to be. On the reporter's Khe Sanh runs the hut he
    // destroyed reported alive true and damage 0.268 for the rest of the mission, while
    // the engine had quietly dropped it to 95 m below the terrain and put rubble in its
    // place. It was gone on screen and standing as far as this check was concerned, so
    // the task never closed. The same shape of fault was reported once before as #905,
    // where a disabled installation stayed alive; that one was worked around inside a
    // single task rather than here, so the next task to meet it got no benefit.
    //
    // Four readings, any of which means the target is no longer there:
    private _pos = getPosATL _target;
    private _destroyed = isNull _target
        || {!alive _target}
        || {damage _target >= 1}
        || {(_pos select 2) < SUNK_BELOW_TERRAIN};

    if !(_destroyed) then {[_state,"allDestroyed",false] call ALIVE_fnc_hashSet};

    // DIAG-STRIP #1002: kept because it is what identified the fault above and it is the
    // only way to tell three lookalike failures apart. A target reading intact at its
    // original position while the building is visibly gone means the destruction never
    // reached this machine. No line at all around the moment of destruction means nothing
    // is re-checking the task. And the verdict below says what this code concluded, so a
    // future report of the same shape does not need the reasoning done again from raw
    // properties.
    if (!isNil "ALiVE_c2istar_taskDiag" && {ALiVE_c2istar_taskDiag}) then {
        ["[C2ISTAR #1002 DIAG] target %1 (%2): isNull=%3 alive=%4 damage=%5 pos=%6 -> destroyed=%7",
            _target,
            typeOf _target,
            isNull _target,
            alive _target,
            damage _target,
            _pos,
            _destroyed
        ] call ALIVE_fnc_dump;
    };
} forEach _targets;

[_state,"targets",_output] call ALIVE_fnc_hashSet;

_state
