#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerCreateProfilesFromGroup);

params [
    "_groupClass",
    "_position",
    ["_direction", 0],
    ["_spawnGoodPosition", true],
    ["_factionId", ""],
    ["_busy", false],
    ["_isSPE", false],
    ["_aiBehaviour", "STEALTH"],
    ["_onEachSpawn", ""],
    ["_onEachSpawnOnce", true]
];

private _groupProfiles = [];
if (_factionId isEqualTo "") exitWith {_groupProfiles};
if (count _position == 2) then {
    _position pushBack 0;
};

private _factionData = [_factionId] call ALIVE_fnc_factionCompilerGetFactionData;
if (isNil "_factionData") exitWith {_groupProfiles};

private _compiledGroups = [_factionData, "compiledGroups"] call ALIVE_fnc_hashGet;
private _groupData = [_compiledGroups, _groupClass] call ALIVE_fnc_hashGet;
if (isNil "_groupData") exitWith {_groupProfiles};

private _side = [_groupData, "side", [_factionData, "side", "EAST"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashGet;
private _unitEntries = [_groupData, "units", []] call ALIVE_fnc_hashGet;
private _vehicleEntries = [_groupData, "vehicles", []] call ALIVE_fnc_hashGet;

private _entityID = [ALIVE_profileHandler, "getNextInsertEntityID"] call ALIVE_fnc_profileHandler;
private _profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
private _entityProfileID = format ["%1-%2", _factionId, _entityID];
[_profileEntity, "profileID", _entityProfileID] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
[_profileEntity, "faction", _factionId] call ALIVE_fnc_profileEntity;
[_profileEntity, "objectType", _groupClass] call ALIVE_fnc_profileEntity;
[_profileEntity, "busy", _busy] call ALIVE_fnc_profileEntity;
[_profileEntity, "isSPE", _isSPE] call ALIVE_fnc_profileEntity;
[_profileEntity, "aiBehaviour", _aiBehaviour] call ALIVE_fnc_profileEntity;

private _spawnHook = format ["[_this select 0, %1, %2] call ALiVE_fnc_factionCompilerApplyLoadout;", str _factionId, str _groupClass];
if !(_onEachSpawn isEqualTo "") then {
    _spawnHook = format ["%1 %2", _spawnHook, _onEachSpawn];
};
[_profileEntity, "onEachSpawn", _spawnHook] call ALIVE_fnc_profileEntity;
[_profileEntity, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;

if !_spawnGoodPosition then {
    [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
};

_groupProfiles pushBack _profileEntity;
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

{
    private _unitData = _x;
    private _unitDistance = [_unitData, "offsetDistance", 0] call ALIVE_fnc_hashGet;
    private _unitBearing = [_unitData, "offsetBearing", 0] call ALIVE_fnc_hashGet;
    private _unitHeight = [_unitData, "offsetHeight", 0] call ALIVE_fnc_hashGet;
    private _unitPosition = +_position;

    if (_unitDistance > 0) then {
        _unitPosition = _position getPos [_unitDistance, _direction + _unitBearing];
    };
    _unitPosition set [2, (_position select 2) + _unitHeight];

    [_profileEntity, "addUnit", [
        [_unitData, "class", ""] call ALIVE_fnc_hashGet,
        _unitPosition,
        [_unitData, "damage", 0] call ALIVE_fnc_hashGet,
        [_unitData, "rank", "PRIVATE"] call ALIVE_fnc_hashGet
    ]] call ALIVE_fnc_profileEntity;
} forEach _unitEntries;

{
    private _vehicleData = _x;
    private _vehicleDistance = [_vehicleData, "offsetDistance", 0] call ALIVE_fnc_hashGet;
    private _vehicleBearing = [_vehicleData, "offsetBearing", 0] call ALIVE_fnc_hashGet;
    private _vehicleHeight = [_vehicleData, "offsetHeight", 0] call ALIVE_fnc_hashGet;
    private _vehicleDirectionOffset = [_vehicleData, "directionOffset", 0] call ALIVE_fnc_hashGet;
    private _vehiclePosition = +_position;

    if (_vehicleDistance > 0) then {
        _vehiclePosition = _position getPos [_vehicleDistance, _direction + _vehicleBearing];
    };
    _vehiclePosition set [2, (_position select 2) + _vehicleHeight];

    private _vehicleID = [ALIVE_profileHandler, "getNextInsertVehicleID"] call ALIVE_fnc_profileHandler;
    private _profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
    private _vehicleProfileID = format ["%1-%2", _factionId, _vehicleID];
    [_profileVehicle, "profileID", _vehicleProfileID] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "vehicleClass", [_vehicleData, "class", ""] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "position", _vehiclePosition] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "direction", _direction + _vehicleDirectionOffset] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "side", _side] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "faction", _factionId] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "damage", [_vehicleData, "damage", []] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "fuel", [_vehicleData, "fuel", 1] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "ammo", [_vehicleData, "ammo", []] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "busy", _busy] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "canFire", [_vehicleData, "canFire", true] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "canMove", [_vehicleData, "canMove", true] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
    [_profileVehicle, "needReload", [_vehicleData, "needReload", 0] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;

    if ([_vehicleData, "engineOn", false] call ALIVE_fnc_hashGet) then {
        [_profileVehicle, "engineOn", true] call ALIVE_fnc_profileVehicle;
    };

    if !_spawnGoodPosition then {
        [_profileVehicle, "despawnPosition", _vehiclePosition] call ALIVE_fnc_profileVehicle;
    };

    _groupProfiles pushBack _profileVehicle;
    [ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;

    private _assignment = [_vehicleData, "assignment", []] call ALIVE_fnc_hashGet;
    private _hasAssignment = false;
    {
        if (count _x > 0) exitWith {
            _hasAssignment = true;
        };
    } forEach _assignment;

    if (_hasAssignment) then {
        private _vehicleAssignment = [_vehicleProfileID, _entityProfileID, _assignment];
        [_profileEntity, "addVehicleAssignment", _vehicleAssignment] call ALIVE_fnc_profileEntity;
        [_profileVehicle, "addVehicleAssignment", _vehicleAssignment] call ALIVE_fnc_profileVehicle;
    };
} forEach _vehicleEntries;

_groupProfiles

