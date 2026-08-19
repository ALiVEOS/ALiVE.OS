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
---------------------------------------------------------------------------- */

private ["_targets","_state"];

_targets = _this select 0;

_state = [] call ALIVE_fnc_hashCreate;
[_state,"allDestroyed",true] call ALIVE_fnc_hashSet;

private _output = [];

{
    private ["_target"];

    _target = _x;
    _output pushback _target;

    if (alive _target) then {[_state,"allDestroyed",false] call ALIVE_fnc_hashSet};

    // DIAG-STRIP #1002: a sabotage/destroy task that stays open after the target has
    // visibly come down cannot be told apart from a task nothing is re-checking at all.
    // This says, once per management cycle, what this machine sees of the target. A
    // handle that reads alive with damage 0 at its original position, while the building
    // is gone on the client that blew it up, means the destruction never reached here --
    // which is a different problem from the check itself. No line at all around the
    // moment of destruction means the manager thread is no longer running.
    if (!isNil "ALiVE_c2istar_taskDiag" && {ALiVE_c2istar_taskDiag}) then {
        ["[C2ISTAR #1002 DIAG] target %1 (%2): isNull=%3 alive=%4 damage=%5 pos=%6",
            _target,
            typeOf _target,
            isNull _target,
            alive _target,
            damage _target,
            getPosATL _target
        ] call ALIVE_fnc_dump;
    };
} forEach _targets;

[_state,"targets",_output] call ALIVE_fnc_hashSet;

_state
