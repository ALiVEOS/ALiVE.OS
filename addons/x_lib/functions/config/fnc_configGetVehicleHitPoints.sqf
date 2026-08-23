#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(configGetVehicleHitPoints);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleHitPoints

Description:
    Get cached hit point data for a vehicle class, with a returnChildren fallback

Parameters:
String - vehicle class name

Returns:
Array of hit point data

Examples:
(begin example)
// get vehicle hit point data
_result = "B_Heli_Light_01_armed_F" call ALIVE_fnc_configGetVehicleHitPoints;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private _type = _this;

if (isnil "ALiVE_configVehicleHitPointsCache") then {
    ALiVE_configVehicleHitPointsCache = createHashMap;
};

private _result = ALiVE_configVehicleHitPointsCache getOrDefaultCall [_type, {
    private _hitPointNames = [];
    private _hitPoints = configFile >> "CfgVehicles" >> _type >> "HitPoints";

    for "_i" from 0 to ((count _hitPoints) - 1) do {
        private _hitPoint = _hitPoints select _i;

        if (isClass _hitPoint) then {
            _hitPointNames pushBack (configName _hitPoint);
        };
    };

    if (_hitPointNames isEqualTo []) then {
        {
            _hitPointNames pushBack (configName _x);
        } forEach ([_hitPoints, 0] call BIS_fnc_returnChildren);
    };

    _hitPointNames
}, true];

+_result;
