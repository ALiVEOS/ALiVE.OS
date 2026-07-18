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

// with a live gun, only a magazine its artillery computer actually carries can
// be fired. The config walk over-collects: a vehicle's smoke-screen dischargers
// (rhs_mag_smokegen) name-match SMOKE and would shadow the real smoke shell,
// then fail inRangeOfArtillery at every range and read as out-of-range. Filter
// the config picks to what the gun can fire; a class-only call (no live gun,
// e.g. capability stocking) keeps the full config list.
private _liveMags = if (_class isEqualType objNull) then { getArtilleryAmmo [vehicle _class] } else { [] };

private _ord = "";

{
    if (
        ([_type, _x] call ALIVE_fnc_isMagazineOfOrdnanceType)
        && {_liveMags isEqualTo [] || {_x in _liveMags}}
    ) exitWith {
        _ord = _x;
    };
} forEach _mags;

// #950 - the config walk can still miss what the gun carries (pylon-mounted
// launchers went unseen until it learned to read them, and other blind spots
// may remain). Fall back to the live artillery computer before reporting
// nothing - otherwise the round resolves to "" when the fire mission loads it.
if (_ord == "" && {_class isEqualType objNull}) then {
    {
        if ([_type, _x] call ALIVE_fnc_isMagazineOfOrdnanceType) exitWith {
            _ord = _x;
        };
    } forEach _liveMags;
};

// "" (not nil) when the gun has nothing of this type - callers pass the
// result into the fire-mission task array and the range checks
_ord;
