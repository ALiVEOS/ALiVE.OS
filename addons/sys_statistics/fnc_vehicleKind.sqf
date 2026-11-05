#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ALIVE_sys_statistics_fnc_vehicleKind
Description:
The kind of vehicle something is, for the War Room's pictures: one word from a fixed list. The editor
category is read first (vanilla, the CDLCs, RHS and CUP all name theirs plainly), then the base classes.

Parameters:
Object or String - a unit or vehicle, or a CfgVehicles class

Returns:
String - man, car, truck, apc, tank, artillery, aa, heli, plane, uav, boat, static or other

Examples:
(begin example)
(vehicle player) call ALIVE_sys_statistics_fnc_vehicleKind;
(end)

Author:
Jman
---------------------------------------------------------------------------- */
private _class = if (_this isEqualType objNull) then { if (isNull _this) then {""} else {typeOf _this} } else { _this };
if !(_class isEqualType "") exitWith {"other"};
private _cfg = configFile >> "CfgVehicles" >> _class;
if (_class == "" || {!isClass _cfg}) exitWith {"other"};
private _is = { _class isKindOf _this };

if ("CAManBase" call _is) exitWith {"man"};
if ("StaticWeapon" call _is) exitWith {"static"};
if (getNumber (_cfg >> "isUav") == 1) exitWith {"uav"};
if ("ParachuteBase" call _is) exitWith {"other"};
if ("Ship" call _is) exitWith {"boat"};
if ("Helicopter" call _is) exitWith {"heli"};
if ("Plane" call _is) exitWith {"plane"};
if !("LandVehicle" call _is) exitWith {"other"};

// the editor's category, as each mod names it (EdSubcat_APCs, rhs_EdSubcat_ifv, CUP_EdSubcat_Tanks ...)
private _sub = toLower getText (_cfg >> "editorSubcategory");
private _has = { (_sub find _this) >= 0 };
private _bySub = switch (true) do {
    case ("artillery" call _has || {"mlrs" call _has} || {"spg" call _has}): {"artillery"};
    case ("antiair" call _has || {"_aa" call _has} || {"spaa" call _has}): {"aa"};
    case ("apc" call _has || {"ifv" call _has}): {"apc"};
    case ("tank" call _has): {"tank"};
    case ("truck" call _has): {"truck"};
    case ("drone" call _has || {"uav" call _has} || {"ugv" call _has}): {"uav"};
    case ("car" call _has || {"mrap" call _has}): {"car"};
    default {""};
};
private _truck = "Truck_F" call _is || {"truck" in toLower getText (_cfg >> "textSingular")};
if (_bySub == "car" && {_truck}) exitWith {"truck"};
if (_bySub != "") exitWith {_bySub};

// otherwise its build: artillery computers, trucks and wheeled APCs by base class, tracked by seats
if (getNumber (_cfg >> "artilleryScanner") == 1) exitWith {"artillery"};
if (_truck) exitWith {"truck"};
if ("Wheeled_APC_F" call _is) exitWith {"apc"};
if ("Tank" call _is) exitWith { if (getNumber (_cfg >> "transportSoldier") >= 4) then {"apc"} else {"tank"} };
if ("Car" call _is) exitWith {"car"};
"other"
