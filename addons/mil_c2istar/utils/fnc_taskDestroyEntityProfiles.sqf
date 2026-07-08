#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskDestroyEntityProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskDestroyEntityProfiles

Description:
Destroy task-owned entity profiles and any linked vehicle profiles.

Parameters:
Array - Profile IDs

Returns:
Array - Destroyed profile IDs

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    ["_profileIDs", [], [[]]]
];

private _profilesToDestroy = [];

{
    private _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

    if !(isNil "_profile") then {
        _profilesToDestroy pushBackUnique (_profile select 2 select 4);

        if ((_profile select 2 select 5) == "entity") then {
            {
                if (_x isEqualType "") then {
                    _profilesToDestroy pushBackUnique _x;
                };
            } forEach ((_profile select 2 select 8) + (_profile select 2 select 9));
        };
    };
} forEach _profileIDs;

{
    private _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

    if !(isNil "_profile") then {
        switch (_profile select 2 select 5) do {
            case "entity": {
                [_profile, "destroy"] call ALIVE_fnc_profileEntity;
            };
            case "vehicle": {
                [_profile, "destroy"] call ALIVE_fnc_profileVehicle;
            };
        };
    };
} forEach _profilesToDestroy;

_profilesToDestroy