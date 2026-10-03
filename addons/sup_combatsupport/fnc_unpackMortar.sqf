#include "\x\alive\addons\sup_combatSupport\script_component.hpp"
SCRIPT(unpackMortar);

/*
    File: fn_unpackStaticWeapon.sqf
    Author: Dean "Rocket" Hall, updated by Tupolov
    Jman

    Description:
    Function which uses a weapon team to pack a static weapon such
    as the HMG or Mortar. Requires three personnel in the team as
    a minimum (leader, gunner, assistant).

    Parameter(s):
    _this select 0: the support team group (group)
    _this select 1: location to place gun (position)
    _this select 2: location of target (position)
    _this select 3: the pack record [id, type, gunner, assistant, packed, markings] (array), or the tube (object)
*/
private ["_group","_position","_targetPos","_leader","_units","_gunner","_assistant","_weapon"];

//diag_log str(_this);

_group =         [_this, 0, grpNull] call bis_fnc_param;
_position =        [_this, 1, grpNull] call bis_fnc_param;
_targetPos =     [_this, 2, grpNull] call bis_fnc_param;
_weapon =         [_this, 3, grpNull] call bis_fnc_param;
_units =         (units _group);

// The battery's state machine passes the record the pack wrote, because the tube it describes no longer
// exists; a tube object is still taken, matched to its crew as before.
private _weapont = "";
private _marks = [];
if (_weapon isEqualType []) then {
    _weapon params ["_id", "_type", "_g", "_a", "_packed", ["_m", []]];
    _weapont = _type;
    _marks = _m;
    if (!isNull _g && {alive _g} && {_g in _units}) then { _gunner = _g };
    if (!isNull _a && {alive _a} && {_a in _units}) then { _assistant = _a };
} else {
    _weapont = typeOf _weapon;
};

{
    if (vehicle _x != _x) then {
        doGetOut _x;
    };
    // the pack marks the crew with the tube's id (text), as the tube itself is gone by the time anyone asks
    if !(_weapon isEqualType []) then {
        if (_x getVariable ["supportWeaponGunner",""] isEqualTo (netId _weapon)) then {
            _gunner = _x;
        };
        if (_x getVariable ["supportWeaponAsst",""] isEqualTo (netId _weapon)) then {
            _assistant = _x;
        };
    };
} foreach _units;

if (isNil "_gunner" || isNil "_assistant") exitWith {
    ["Someone from the mortar team died"] call ALiVE_fnc_dump;
    // reduce mortar count (the group is _group here: _grp was never set, so this threw instead)
    private _sptCount = _group getVariable ["supportWeaponCount",3];
    _group setVariable ["supportWeaponCount", _sptCount - 1];
    // a carrier left without his tube is free to carry another on the next move
    if (!isNil "_assistant") then { _assistant setVariable ["packAssistant", false] };
};

[_gunner, _assistant, _targetPos, _weapont, _group, _marks] spawn {

    private ["_gunner","_assistant","_pos","_tPos","_wait","_dirTo","_sptarr","_weapont", "_weapon","_grp","_timein","_timer","_sptCount"];

    _gunner = _this select 0;
    _assistant = _this select 1;
    _tPos = _this select 2;
    _weapont = _this select 3;
    _grp = _this select 4;
    private _marks = _this select 5;

    // a carrier killed on the way, or a gunner who never stops, writes the tube off: the battery's state
    // machine waits for the count it was given, and would otherwise wait for this tube for good
    private _tw = time;
    waitUntil {sleep 0.1; !alive _gunner || {!alive _assistant} || {_gunner call ALiVE_fnc_unitReadyRemote} || {time - _tw > 60}};
    if (!alive _gunner || {!alive _assistant}) exitWith {
        ["Someone from the mortar team died"] call ALiVE_fnc_dump;
        _grp setVariable ["supportWeaponCount", (_grp getVariable ["supportWeaponCount", 1]) - 1];
        _assistant setVariable ["packAssistant", false];
    };

    _gunner disableAI "move";

    _assistant disableAI "move";

    _assistant setpos (position _gunner);

    _assistant setUnitPos "Middle";

    // Assemble is aimed at the other half of the weapon, the base bag lying on the ground (BIKI's own example
    // is _unit action ["Assemble", nearestObject [_unit, "Tripod_Bag"]]). It was given the gunner's own bag,
    // so it never did anything and every set-up sat out the 60 s below before the tube was made by script. The
    // assistant puts the base bag down, and once it's on the ground the gunner assembles onto it.
    private _baseBag = unitBackpack _assistant;
    private _baseBagType = backpack _assistant;
    _assistant action ["PutBag",_assistant];
    private _tb = time;
    waitUntil {sleep 0.5; backpack _assistant == "" || {time - _tb > 10}};
    sleep 1;
    if (isNull _baseBag && {_baseBagType != ""}) then {_baseBag = nearestObject [_gunner, _baseBagType]};
    _gunner action ["Assemble",_baseBag];

    _wait = true;
    _timein = true;
    _timer = time;
    while {_wait && _timein} do {
        _weapon = (nearestObjects [position _gunner, [_weapont], 3]) select 0;
        if (!isNil "_weapon") then {
            if (alive _weapon) then {_wait = false};
        };
        if (time-_timer > 60) then {_timein = false};
        sleep 1;
    };

    if (!_timein && _wait) then {
        ["unpack timedout %1",(nearestObjects [position _gunner, [], 3])] call ALiVE_fnc_dump;
        removeBackpackGlobal _gunner;
        removeBackpackGlobal _assistant;
        _weapon = createVehicle [_weapont, position _gunner, [], 3, "NONE"];
    };

    // the new tube carries the old one's markings: without the Combat Support flag the AI Distributor
    // hands the battery to a headless client, the profile system takes the gun over, and the resupply
    // watch reads its last dispatch from the tube. A resupply on its way to the old tube can't find it, and
    // only that delivery clears the in-progress flag, so that flag isn't carried: the dispatch time is
    // stamped instead, and the watch waits out its usual gap before asking again.
    _marks params [["_cs", false], ["_ignore", false], ["_module", []], ["_lastDispatch", 0], ["_inProgress", false], ["_wasPrimary", false]];
    if (_cs) then { _weapon setVariable ["ALIVE_CombatSupport", true] };
    if (_ignore) then { _weapon setVariable ["ALIVE_profileIgnore", true] };
    if (_module isNotEqualTo []) then { _weapon setVariable ["NEO_radioArtyModule", _module, true] };
    if (_inProgress) then { _lastDispatch = serverTime };
    if (_lastDispatch > 0) then { _weapon setVariable ["ALIVE_resupply_lastDispatch", _lastDispatch, true] };
    if (_wasPrimary) then { _weapon setVariable ["ALiVE_CS_wasPrimary", true] };
    _weapon lock true;

    _sptarr = _grp getVariable ["supportWeaponArray",[]];
    _sptarr pushback _weapon;
    _grp setvariable ["supportWeaponArray", _sptarr];

    _dirTo = ((position _weapon) getDir _tPos);

    sleep 5;
    _gunner assignAsGunner _weapon;
    _gunner moveInGunner _weapon;
    sleep 5;

    _gunner commandWatch _tPos;

    _assistant selectWeapon "Binocular";
    sleep 6;
    _assistant commandWatch _tPos;
    _assistant setDir _dirTo;

    _gunner setVariable ["unpacked", true];
    _assistant setVariable ["packAssistant", false];

//    diag_log str(_grp getVariable ["supportWeaponArray",[]]);
};

_gunner
