#include <\x\alive\addons\sup_combatSupport\script_component.hpp>
SCRIPT(packMortar);

/*
    File: fn_packStaticWeapon.sqf
    Author: Dean "Rocket" Hall - Updated by Tupolov for Mortars

    Description:
    Function which uses a weapon team to pack a static weapon such
    as the HMG or Mortar. Requires three personnel in the team as
    a minimum (leader, gunner, assistant).

    Parameter(s):
    _this select 0: the support team group (group)
    _this select 1: the weapon (option if weapon registered as "supportWeaponSetup" variable)
*/
private _group = _this param [0, grpNull];
private _weapon = _this param [1, objNull];

if (isNull _group || isNull _weapon) exitWith {};

private _disassembleToCfg = (configFile >> "CfgVehicles" >> typeOf _weapon >> "assembleInfo" >> "dissasembleTo");
private _disassembleTo = _disassembleToCfg call BIS_fnc_getCfgData;

if (isNil "_disassembleTo" || {count _disassembleTo == 0}) exitWith {};

private _leader = leader _group;
private _gunner = gunner _weapon;
private _units = (units _group) - [_leader] - [_gunner];
private _assistant = _unit select 0;

private _primaryBag = objNull;
private _secondaryBag = objNull;

private _timeout = -1;

_gunner leaveVehicle _weapon;

private _disassembledEH = _gunner addEventHandler ["WeaponDisassembled", {
    private _unit = _this param [0, objNull];
    private _primaryBag = _this param [1, objNull];
    private _secondaryBag = _this param [2, objNull];

    _unit setVariable ["primaryBag", _primaryBag];
    _unit setVariable ["secondaryBag", _secondaryBag];
}];

_gunner action ["Disassemble", _weapon];

_timeout = time + 5;
while {isNull _primaryBag || isNull _secondaryBag} do {
    if (time >= _timeout) exitWith {
        _primaryBag = createVehicle [_disassembleTo select 0, position _weapon, [], 0, "NONE"];
        _secondaryBag = createVehicle [_disassembleTo select 1, position _weapon, [], 0, "NONE"];

        deleteVehicle _weapon;
    };

    _primaryBag = _gunner getVariable ["primaryBag", objNull];
    _secondaryBag = _gunner getVariable ["secondaryBag", objNull];
    sleep 0.1;
};

{
    _x enableAI "MOVE";
    _x setUnitPos "AUTO";
} forEach [_gunner, _assistant];

_gunner action ["takeBag", _primaryBag];
_assistant action ["takeBag", _secondaryBag];

_timeout = time + 5;
while {unitBackpack _gunner != _primaryBag || unitBackpack _assistant != _secondaryBag} do {
    if (time >= _timeout) exitWith {
        _gunner addBackpackGlobal (typeOf _primaryBag);
        _assistant addBackpackGlobal (typeOf _secondaryBag);
    };
    sleep 0.1;
};

// Cleanup possible remaining backpacks
private _weaponHolders = nearestObjects [position _gunner, ["GroundWeaponHolder"], 25];

{
    private _weaponHolder = _x param [0, objNull];
    private _weaponHolderBackpacks = backpackCargo _weaponHolder;

    {
        private _backpack = _x param [0, objNull];

        if (_backpack in _weaponHolderBackpacks) exitWith {
            deleteVehicle _weaponHolder;
        };
    } forEach _disassembleTo;
} forEach _weaponHolders;
