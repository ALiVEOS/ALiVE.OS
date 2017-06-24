#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetVehicleTurrets);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleTurrets

Description:
Get turrets data for a vehicle class

Parameters:
String - vehicle class name

Returns:
Array of turret data

Examples:
(begin example)
// get vehicle turret data
_result = "O_Heli_Attack_02_F" call ALIVE_fnc_configGetVehicleTurrets;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_findRecurse","_class"];
private _result = [];

_findRecurse = {
    private ["_class","_path","_currentPath"];
    params ["_root"];
    _path = +(_this select 1);

    for "_i" from 0 to count _root -1 do {

        _class = _root select _i;

        if (isClass _class) then {
            _currentPath = _path + [_i];

            {
                _result pushback [_x, _x call ALIVE_fnc_configGetWeaponMagazines, _currentPath, str _class];
            } count getArray (_class >> "weapons");

            _class = _class >> "turrets";

            if (isClass _class) then { [_class, _currentPath] call _findRecurse; };
        };
    };
};

_class = (configFile >> "CfgVehicles" >> _this >> "turrets");

[_class, []] call _findRecurse;

_result;