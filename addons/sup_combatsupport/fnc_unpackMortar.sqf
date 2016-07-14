#include <\x\alive\addons\sup_combatSupport\script_component.hpp>
SCRIPT(unpackMortar);

/*
    File: fn_unpackStaticWeapon.sqf
    Author: Dean "Rocket" Hall, updated by Tupolov

    Description:
    Function which uses a weapon team to pack a static weapon such
    as the HMG or Mortar. Requires three personnel in the team as
    a minimum (leader, gunner, assistant).

    Parameter(s):
    _this select 0: the support team group (group)
    _this select 1: location to place gun (position)
    _this select 2: location of target (position)
*/
private _group = _this param [0, grpNull];
private _position = _this param [1, grpNull];
private _targetPos = _this param [2, grpNull];

// TODO: Perhaps leader could pick up an other role if needed?
if (count (units _group) < 3) exitWith {
    // TODO: is supportWeaponCount needed?
    _sptCount = _grp getVariable ["supportWeaponCount",3];
    _grp setVariable ["supportWeaponCount", _sptCount - 1];

    diag_log "unpackMortar: cannot assemble, requires 3 units"
};

private _assembleTo = "";
private _disassembleTo = [];
private _backpacks = [];

// TODO: Extract to seperate script?
{
    private _backpack = unitBackpack _x;

    if (!isNull _backpack) then {
        private _assembleToCfg = (configFile >> "CfgVehicles" >> typeOf _backpack >> "assembleInfo" >> "assembleTo");
        private _assembleToValue = _assembleToCfg call BIS_fnc_getCfgData;

        if (!isNil "_assembleToValue" && {count _assembleToValue > 0}) then {
            private _disassembleToCfg = (configFile >> "CfgVehicles" >> _assembleToValue >> "assembleInfo" >> "dissasembleTo");
            private _disassembleToValue = _disassembleToCfg call BIS_fnc_getCfgData;

            if (!isNil "_disassembleToValue" && {count _disassembleToValue > 0}) then {
                _disassembleTo = _disassembleToValue;
            };
        };

        _backpacks pushBack (typeOf _backpack);
    };
} forEach (units _group);

private _canAssemble = true;

{
    if (!(_x in _backpacks)) exitWith {
        _canAssemble = false;
    };
} forEach _disassembleTo;

if (!_canAssemble) exitWith { diag_log format ["unpackMortar: cannot assemble %1! NEED: %2 HAS: %3", _assembleTo, _disassembleTo, _backpacks] };

private _weapon = objNull;
private _leader = leader _group;
private _units = (units _group) - [_leader];
private _gunner = _units select 0;
private _assistant = _units select 1;
private _timeout = -1;

{_x doMove ([_position, 0, 5, 0, 0, 20, 0] call BIS_fnc_findSafePos)} forEach (_units + [_leader]);

private _unitsReady = false;
_timeout = time + 60;
while {!_unitsReady} do {
    if (time >= _timeout) exitWith {
        {
            doStop _x;
            _x setPos ([_position, 0, 5, 0, 0, 20, 0] call BIS_fnc_findSafePos);
        } forEach (_units + [_leader]);
    };

    {
        // Break out of forEach as soon as unit is not "ready"
        if (!(_x call ALiVE_fnc_unitReadyRemote)) exitWith {
            _unitsReady = false;
        };

        _unitsReady = true;
    } forEach (_units + [_leader]);

    sleep 0.1;
};

// TODO: change MOVE to PATH post A3 1.62 release?
_gunner disableAI "MOVE";
_assistant disableAI "MOVE";

private _assistantBackpack = unitBackpack _assistant;
_assistant action ["PutBag"];

_timeout = time + 5;
while {!isNull (unitBackpack _assistant)} do {
    if (time >= _timeout) exitWith {
        _assistantBackpack = createVehicle [typeOf _assistantBackpack, position _assistant, [], 0, "NONE"];
        removeBackpackGlobal _assistant;
    };
    sleep 0.1;
};

private _assembledEH = _gunner addEventHandler ["WeaponAssembled", {
    private _unit = _this param [0, objNull];
    private _weapon = _this param [1, objNull];

    _unit setVariable ["assembledWeapon", _weapon];
}];

_gunner action ["Assemble", _assistantBackpack];

_timeout = time + 5;
while {isNull _weapon} do {
    if (time >= _timeout) exitWith {
        _weapon = createVehicle [_assembleTo, position _gunner, [], 0, "NONE"];
        removeBackpackGlobal _gunner;
    };

    _weapon = _gunner getVariable ["assembledWeapon", objNull];
    sleep 0.1;
};

_gunner removeEventHandler ["WeaponAssembled", _assembledEH];

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

private _dirTo = [position _weapon, _targetPos] call BIS_fnc_dirTo;
_weapon setDir _dirTo;

_gunner assignAsGunner _weapon;
_gunner moveInGunner _weapon;
_gunner commandWatch _targetPos;

_assistant setUnitPos "Middle";
_assistant setDir _dirTo;
_assistant commandWatch _targetPos;

_leader selectWeapon "Binocular";
_leader setUnitPos "Middle";
_leader setDir _dirTo;
_leader commandWatch _targetPos;

_gunner;
