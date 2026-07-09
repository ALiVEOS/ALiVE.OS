#include "\x\alive\addons\x_lib\script_component.hpp"


/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getArtyMagazineType

Description:
Resolve the magazine classname a battery should fire for an ordnance type

Parameters:
Object or String - battery vehicle (or vehicle classname)
String - ordnance type ("HE", "SMOKE", ...)

Returns:
String - magazine classname, "" when the gun carries nothing of that type

Examples:
(begin example)
_mag = [_battery, "HE"] call ALIVE_fnc_getArtyMagazineType;
(end)

See Also:

Author:
Gunny
Jman
---------------------------------------------------------------------------- */

private ["_class","_type","_mags"];

_class = _this select 0;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class    = "B_MBT_01_arty_F"
};
_type = _this select 1;

private _weaponType = if (_class isEqualType objNull) then { typeof (vehicle _class) } else { _class };

// #887 - walk EVERY turret (mod artillery often mounts the gun outside
// MainTurret), with a vehicle-level fallback for statics. The ordnance
// matcher handles mod magazine names via config ancestry.
_mags = [];
{
    _mags append (getArray (_x >> "magazines"));
} forEach ("isClass _x" configClasses (configfile >> "CfgVehicles" >> _weaponType >> "Turrets"));

if (_mags isEqualTo []) then {
    _mags = getArray (configfile >> "CfgVehicles" >> _weaponType >> "magazines");
};

private _ord = "";

{
    if ([_type, _x] call ALIVE_fnc_isMagazineOfOrdnanceType) exitWith {
        _ord = _x;
    };
} forEach _mags;

// "" (not nil) when the gun has nothing of this type - callers pass the
// result into the fire-mission task array and the range checks
_ord;
