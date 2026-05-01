#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(anyPlayerCanSee);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_anyPlayerCanSee

Description:
True if any alive player is within range AND can actually see the target
(view-cone + line-of-sight via ALIVE_fnc_canSee). Used as a deferral gate
ahead of any visible-state change (despawn, delete, switchMove, etc.) so
that the player never sees a pop-out.

A nearby player who is looking the other way returns false - the gate is
about visual perception, not raw proximity.

Parameters:
OBJECT  - target object (unit / vehicle)
SCALAR  - max range in metres (default 150)

Returns:
BOOL - true if any alive player within range can see the target

Examples:
(begin example)
// Defer despawn while a player is watching
if ([_unit, 100] call ALiVE_fnc_anyPlayerCanSee) exitWith {};
deleteVehicle _unit;
(end)

See Also:
ALIVE_fnc_canSee

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_target", objNull, [objNull]],
    ["_range", 150, [0]]
];

if (isNull _target) exitWith { false };

private _result = false;
{
    if (alive _x && {(_x distance _target) < _range}) then {
        if ([_x, _target] call ALIVE_fnc_canSee) exitWith {
            _result = true;
        };
    };
    if (_result) exitWith {};
} forEach allPlayers;

_result
