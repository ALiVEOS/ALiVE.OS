#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskHaveUnitsLoadedInVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskHaveUnitsLoadedInVehicle

Description:
Have all the units loaded into the vehicle

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskUnits","_loaded"];

_taskUnits = _this select 0;

_loaded = true;

{
    if(alive _x) then {

        //["LOADED?: %1 %2 %3",_x,vehicle _x,vehicle _x != _x] call ALIVE_fnc_dump;

        if(vehicle _x == _x) then {
            _loaded = false;
        };
    };

} forEach _taskUnits;

_loaded