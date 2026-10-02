#include "\x\alive\addons\sup_combatSupport\script_component.hpp"
SCRIPT(packMortar);

/*
    File: fn_packStaticWeapon.sqf
    Author: Dean "Rocket" Hall - Updated by Tupolov for Mortars
    Jman

    Description:
    Function which uses a weapon team to pack a static weapon such
    as the HMG or Mortar. Requires three personnel in the team as
    a minimum (leader, gunner, assistant).

    Parameter(s):
    _this select 0: the support team group (group)
    _this select 1: the weapon (option if weapon registered as "supportWeaponSetup" variable)
*/
private["_group","_weapon","_position","_leader","_units","_gunner","_assistant","_type","_wait"];

_group =     [_this, 0, grpNull] call bis_fnc_param;
_weapon =     [_this, 1, grpNull] call bis_fnc_param;
_type =     typeOf _weapon;
_position = position _weapon;
_leader =     leader _group;
_gunner =     gunner _weapon;
_units =     (units _group) - [_leader];
_units =    _units - [_gunner];

// == never matches a null object (objNull == objNull is false), so this let a missing tube or team through
if (isNull _weapon || {isNull _group} || {isNull _leader}) exitWith {};

{
    // find a group member that is not in a vehicle or staticweapon and is free
    if !(_x getVariable ["packAssistant",false] || (vehicle _x != _x)) exitWith {
        _assistant = _x;
        _assistant setVariable ["packAssistant",true];
    };
} foreach _units;

// ["%1, %2, %3, %4, %5, %6, %7", _group, _weapon, _position, _leader, _gunner, _assistant, _type] call ALiVE_fnc_dump;

// Taking the tube apart deletes it, so everything the unpack needs is written down now, while it still exists:
// [id, type, gunner, assistant, packed, the tube's own markings]. The record goes on the group, whose state
// machine sends the team off once every record reads packed, and the unpack works from it. The crew used to
// be given the tube itself, read after it was gone, so the unpack never found them.
private _id = netId _weapon;
if (_id in ["", "0:0"]) then { _id = str _weapon };
private _record = [_id, _type, _gunner, if (isNil "_assistant") then {objNull} else {_assistant}, false, [
    _weapon getVariable ["ALIVE_CombatSupport", false],
    _weapon getVariable ["ALIVE_profileIgnore", false],
    _weapon getVariable ["NEO_radioArtyModule", []],
    _weapon getVariable ["ALIVE_resupply_lastDispatch", 0],
    _weapon getVariable ["ALIVE_resupply_inProgress", false],
    _weapon isEqualTo (_leader getVariable ["ALIVE_resupply_primaryVehicle", objNull])
]];
private _records = _group getVariable ["ALiVE_CS_packedTubes", []];
_records pushBack _record;
_group setVariable ["ALiVE_CS_packedTubes", _records];

// nobody free to carry the second half: the tube stays where it is, and the unpack writes it off
if (isNil "_assistant") exitWith { _record set [4, true] };

_gunner setVariable ["supportWeaponGunner", _id];
_assistant setVariable ["supportWeaponAsst", _id];

_gunner leaveVehicle _weapon;

_gunner addEventHandler ["WeaponDisassembled", {
    _this spawn {
        private ["_unit","_bag1","_bag2"];
        _unit = _this select 0;
        _bag1 = _this select 1;
        _bag2 = _this select 2;

        _unit setVariable ["supportWeaponBag1", _bag1];
        _unit setVariable ["supportWeaponBag2", _bag2];
    };
}];

_gunner action ["Disassemble",_weapon];

{
    _x enableAI "MOVE";
    _x enableAI "ANIM";
    _x setUnitPos "AUTO";
} forEach [_gunner, _assistant];

{
    [_x,position _weapon] call ALiVE_fnc_doMoveRemote;
} foreach [_gunner, _assistant];

[_weapon, _gunner, _assistant, _type, _record] spawn {
    private ["_weapon","_gunner","_assistant","_position","_wait","_bag2","_bag1","_timeout","_packs"];
    _weapon = _this select 0;
    _gunner = _this select 1;
    _assistant = _this select 2;
    private _type = _this select 3;
    private _record = _this select 4;
    _position = position _weapon;

    _timer = time;
    waitUntil {sleep 0.3; _gunner call ALiVE_fnc_unitReadyRemote || (time-_timer > 30)};

    _gunner action ["Disassemble",_weapon];

    _wait = true;
    _timeout = false;
    _timer = time;
    while {_wait} do {
        _packs = nearestObjects [_position, ["GroundWeaponHolder"], 3];
        if (count _packs > 1) then {_wait = false};
        if ((time-_timer) > 30) exitWith {_timeout = true;};
        sleep 1;
    };

    if (_timeout) then {
        // the bags are named from the tube's type (O_, B_ or I_), which is text; the tube itself is not
        private _prefix = _type select [0,1];
        _bag1 = format ["%1_Mortar_01_weapon_F", _prefix];
        _bag2 = format ["%1_Mortar_01_support_F", _prefix];
        deleteVehicle _weapon;
        _gunner addBackpackGlobal _bag1;
        _assistant addBackpackGlobal _bag2;
    } else {
        _bag1 = _gunner getVariable ["supportWeaponBag1", objNull];
        _bag2 = _gunner getVariable ["supportWeaponBag2", objNull];
        _gunner action ["takeBag", _bag1];
        _assistant action ["takeBag", _bag2];

        // only here are the bags objects to compare backpacks with; after a timeout they're class names
        _timer = time;
        waitUntil {sleep 1; (unitBackpack _gunner == _bag1 && unitBackpack _assistant == _bag2) || (time-_timer) > 30};

        if (unitBackpack _gunner != _bag1) then {
            _gunner addBackpackGlobal (typeOf _bag1);
        };

        if (unitBackpack _assistant != _bag2) then {
            _assistant addBackpackGlobal (typeOf _bag2);
            {
                deleteVehicle _x;
            }foreach _packs;
        };
    };

    _record set [4, true];


//    ["%1 packed up!",_weapon] call ALiVE_fnc_dump;
};