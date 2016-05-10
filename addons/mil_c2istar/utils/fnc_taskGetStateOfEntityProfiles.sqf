#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetStateOfEntityProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetStateOfEntityProfiles

Description:
Get the current state of some entity profiles

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskProfiles","_profiles","_state","_entityProfile","_active","_vehicle","_units"];

_taskProfiles = _this select 0;

_profiles = [];
_state = [] call ALIVE_fnc_hashCreate;
[_state,"allDestroyed",true] call ALIVE_fnc_hashSet;

{
    _entityProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

    if!(isNil "_entityProfile") then {

        _active = _entityProfile select 2 select 1;

        _profiles set [count _profiles, _entityProfile];

        if(_active) then {

            _units = _entityProfile select 2 select 21;

            {

                if(alive _x) then {

                    [_state,"allDestroyed",false] call ALIVE_fnc_hashSet;

                };

            } forEach _units;

        }else{

            [_state,"allDestroyed",false] call ALIVE_fnc_hashSet;

        };

    };

} forEach _taskProfiles;

[_state,"profiles",_profiles] call ALIVE_fnc_hashSet;

_state