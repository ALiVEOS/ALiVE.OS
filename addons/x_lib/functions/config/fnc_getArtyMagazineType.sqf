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

// #887 - recursive turret walk + magazineWell resolution: mod artillery
// mounts guns on nested turrets and lists ordnance through wells. The
// ordnance matcher handles mod magazine names via config ancestry.
_mags = _weaponType call ALIVE_fnc_getArtyMagazines;

private _ord = "";

{
    if ([_type, _x] call ALIVE_fnc_isMagazineOfOrdnanceType) exitWith {
        _ord = _x;
    };
} forEach _mags;

// #950 - the launcher may be script-added at spawn and invisible to the config
// walk above (Spearhead Calliope, RHS BM-21). Ask the live gun's artillery
// computer before reporting nothing - otherwise the round is offered in the
// tablet and then resolves to "" when the fire mission tries to load it.
if (_ord == "" && {_class isEqualType objNull}) then {
    {
        if ([_type, _x] call ALIVE_fnc_isMagazineOfOrdnanceType) exitWith {
            _ord = _x;
        };
    } forEach (getArtilleryAmmo [vehicle _class]);
};

// "" (not nil) when the gun has nothing of this type - callers pass the
// result into the fire-mission task array and the range checks
_ord;
