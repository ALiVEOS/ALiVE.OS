#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
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

_output = [];

{
    private ["_target"];
    
    _target = _x;
    _output set [count _output, _target];

    if (alive _target) then {[_state,"allDestroyed",false] call ALIVE_fnc_hashSet};
} forEach _targets;

[_state,"targets",_output] call ALIVE_fnc_hashSet;

_state