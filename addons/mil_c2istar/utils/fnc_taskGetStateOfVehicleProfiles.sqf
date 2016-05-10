#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetStateOfVehicleProfiles);

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
ARJay
---------------------------------------------------------------------------- */

private ["_taskProfiles","_profiles","_state","_vehicleProfile","_active","_vehicle"];

_taskProfiles = _this select 0;

_profiles = [];
_state = [] call ALIVE_fnc_hashCreate;
[_state,"allDestroyed",true] call ALIVE_fnc_hashSet;

{
    _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

    if!(isNil "_vehicleProfile") then {

        _active = _vehicleProfile select 2 select 1;

        _profiles set [count _profiles, _vehicleProfile];

        if(_active) then {

            _vehicle = _vehicleProfile select 2 select 10;

            if(alive _vehicle) then {

                [_state,"allDestroyed",false] call ALIVE_fnc_hashSet;

            };

        }else{

            [_state,"allDestroyed",false] call ALIVE_fnc_hashSet;

        };

    };

} forEach _taskProfiles;

[_state,"profiles",_profiles] call ALIVE_fnc_hashSet;

_state