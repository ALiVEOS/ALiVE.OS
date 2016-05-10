#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskHaveUnitsUnloadedFromVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskHaveUnitsUnloadedFromVehicle

Description:
Have all the units unloaded from the vehicle

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskUnits","_unloaded"];

_taskUnits = _this select 0;

_unloaded = true;

{
    if(alive _x) then {

        //["UNLOADED?: %1 %2 %3",_x,vehicle _x,vehicle _x == _x] call ALIVE_fnc_dump;

        if(vehicle _x != _x) then {
            _unloaded = false;
        };
    };

} forEach _taskUnits;

_unloaded