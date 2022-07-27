#include "\x\alive\addons\x_lib\script_component.hpp"


/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getArtyMagazineType

Description:
Get magazinesType from config for a weapon class

Parameters:
String - weapon class name

Returns:
Array of magazine types

Examples:
(begin example)
// get weapon magazines
_result = "missiles_DAGR" call ALIVE_fnc_configGetWeaponMagazines;
(end)

See Also:

Author:
Gunny
---------------------------------------------------------------------------- */

private ["_class","_type","_weaponClass","_mags""_result"];

_class = _this select 0;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class    = "B_MBT_01_arty_F"
};
_type = _this select 1;
private _weaponType = typeof(vehicle _class);

_mags = [configfile >> "CfgVehicles" >> _weaponType >> "Turrets" >> "MainTurret" >> "magazines"] call ALiVE_fnc_getConfigValue;

private _ords=[];
private _ord="";

{
    if ([_type, _x] call ALIVE_fnc_isMagazineOfOrdnanceType) then {
        _ords = [_ords, _x] call ALIVE_fnc_push;
    };
} forEach _mags;

_ord = _ords select 0;
_ord;
