#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(getObjectCargo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectCargo
Description:

Gets an cargo-array of the given object.

Parameters:
_this: ARRAY of OBJECTs

Returns:
ARRAY - select 0: Logistics Cargo (Array)
ARRAY - select 1: Towed vehicles (Array)
ARRAY - select 2: Lifted vehicles (Array)
ARRAY - select 3: Weapons/Magazines/Items (Array)
ARRAY - select 4: Current Ammo (Array)

See Also:
- <ALIVE_fnc_setObjectCargo>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_object","_cargo","_weapons","_magazines","_items","_ammo"];

_object = [_this, 0, objNull, [objNull]] call BIS_fnc_param;

_weapons = [[getWeaponCargo _object], 0, [], [[]]] call BIS_fnc_param;
_magazines = [[getMagazineCargo _object], 0, [], [[]]] call BIS_fnc_param;
_items = [[getItemCargo _object], 0, [], [[]]] call BIS_fnc_param;
_ammo = [[if ({_object isKindOf _x} count ["ReammoBox","ReammoBox_F"] == 0) then {magazinesAmmo _object} else {[]}], 0, [], [[]]] call BIS_fnc_param; // Thank you BIS, magazinesAmmo _box returns different resultset than magazinesAmmo _car. Applause!

_cargo = [];
{
    private ["_cargoIDs"];
    _cargoIDs = [];
    
    {_cargoIDs set [count _cargoIDs,[MOD(SYS_LOGISTICS),"id",_x] call ALiVE_fnc_logistics]} foreach (_object getvariable [_x,[]]);
    
    _cargo set [_foreachIndex,_cargoIDs];
} foreach [QGVAR(CARGO),QGVAR(CARGO_TOW),QGVAR(CARGO_LIFT)];

_cargo set [3,[_weapons,_magazines,_items]];
_cargo set [4,_ammo];

_cargo;