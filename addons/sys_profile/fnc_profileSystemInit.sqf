#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileSystemInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileSystemInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module

Returns:
Nil

See Also:

Author:
ARjay
Jman
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_uid","_moduleID"];

PARAMS_1(_logic);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_profileSystem","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

// Ensure initialisation is only done once per machine
if !(isnil QMOD(SYS_PROFILE)) exitwith {[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit};

if(isServer) then {

    //waituntil {sleep 1; ["PS WAITING"] call ALIVE_fnc_dump; time > 0};

    MOD(SYS_PROFILE) = _logic;

    private _debug = (_logic getVariable ["debug","false"]) == "true";
    private _debugVirtualisedProfiles = (_logic getVariable ["debugVirtualisedProfiles","false"]) == "true";
    private _persistent = (_logic getVariable ["persistent","false"]) == "true";
    private _syncMode = _logic getVariable ["syncronised","ADD"];
    private _syncedUnits = synchronizedObjects _logic;
    private _profileActivatorSettings = _logic getVariable ["profileActivatorSettings", []];
    private _hasProfileActivatorSettings = false;
    private _profileActivatorSettingsByName = createHashMap;
    private _profileActivatorSettingNames = [
        "proximity",
        "airCombat",
        "spawnRadius",
        "spawnTypeHeliRadius",
        "spawnTypeJetRadius",
        "spawnRadiusUAV",
        "airCombatPlaneVehicleRadius",
        "airCombatHelicopterVehicleRadius"
    ];

    if (_profileActivatorSettings isEqualType []) then {
        {
            if (
                _x isEqualType [] &&
                {count _x > 1} &&
                {(_x select 0) isEqualType ""} &&
                {(_x select 0) in _profileActivatorSettingNames}
            ) then {
                _profileActivatorSettingsByName set [_x select 0,_x select 1];
                _hasProfileActivatorSettings = true;
            };
        } forEach _profileActivatorSettings;
    };

    private _spawnRadius = parseNumber (_logic getVariable ["spawnRadius","1500"]);
    private _spawnTypeHeliRadius = parseNumber (_logic getVariable ["spawnTypeHeliRadius","1500"]);
    private _spawnTypeJetRadius = parseNumber (_logic getVariable ["spawnTypeJetRadius","0"]);
    private _spawnTypeUAVRadius = parseNumber (_logic getVariable ["spawnRadiusUAV", "-1"]);
    private _proximitySpawning = true;
    private _airCombatSpawning = false;
    private _airCombatPlaneVehicleRadius = 7000;
    private _airCombatHelicopterVehicleRadius = 5000;
    private _asBool = {
        params ["_value", "_default"];
        switch (typeName _value) do {
            case "BOOL": { _value };
            case "SCALAR": { _value != 0 };
            case "STRING": {
                private _text = toLower _value;
                if (_text in ["true", "yes", "1", "on"]) then {
                    true
                } else {
                    if (_text in ["false", "no", "0", "off"]) then { false } else { _default };
                };
            };
            default { _default };
        };
    };
    private _asNumber = {
        params ["_value", "_default"];
        switch (typeName _value) do {
            case "SCALAR": { _value };
            case "STRING": { parseNumber _value };
            default { _default };
        };
    };

    if (_hasProfileActivatorSettings) then {
        _spawnRadius = 1500;
        _spawnTypeHeliRadius = 1500;
        _spawnTypeJetRadius = 0;
        _spawnTypeUAVRadius = -1;

        private _settingValue = _profileActivatorSettingsByName get "proximity";
        if (!isNil "_settingValue" && {_settingValue isEqualType false}) then {
            _proximitySpawning = _settingValue;
        };

        _settingValue = _profileActivatorSettingsByName get "airCombat";
        if (!isNil "_settingValue" && {_settingValue isEqualType false}) then {
            _airCombatSpawning = _settingValue;
        };

        _settingValue = _profileActivatorSettingsByName get "spawnRadius";
        if (!isNil "_settingValue" && {_settingValue isEqualType ""}) then {
            _spawnRadius = parseNumber _settingValue;
        };

        _settingValue = _profileActivatorSettingsByName get "spawnTypeHeliRadius";
        if (!isNil "_settingValue" && {_settingValue isEqualType ""}) then {
            _spawnTypeHeliRadius = parseNumber _settingValue;
        };

        _settingValue = _profileActivatorSettingsByName get "spawnTypeJetRadius";
        if (!isNil "_settingValue" && {_settingValue isEqualType ""}) then {
            _spawnTypeJetRadius = parseNumber _settingValue;
        };

        _settingValue = _profileActivatorSettingsByName get "spawnRadiusUAV";
        if (!isNil "_settingValue" && {_settingValue isEqualType ""}) then {
            _spawnTypeUAVRadius = parseNumber _settingValue;
        };

        _settingValue = _profileActivatorSettingsByName get "airCombatPlaneVehicleRadius";
        if (!isNil "_settingValue" && {_settingValue isEqualType ""}) then {
            _airCombatPlaneVehicleRadius = (parseNumber _settingValue) max 0;
        };

        _settingValue = _profileActivatorSettingsByName get "airCombatHelicopterVehicleRadius";
        if (!isNil "_settingValue" && {_settingValue isEqualType ""}) then {
            _airCombatHelicopterVehicleRadius = (parseNumber _settingValue) max 0;
        };
    } else {
        private _legacyAirCombatSpawning = _logic getVariable ["airCombatSpawning", "false"];
        _airCombatSpawning = switch (true) do {
            case (_legacyAirCombatSpawning isEqualType false): {_legacyAirCombatSpawning};
            case (_legacyAirCombatSpawning isEqualType ""): {toLower _legacyAirCombatSpawning == "true"};
            default {false};
        };
    };

    // Native Eden attributes take precedence over the former packed custom
    // control. The packed values above remain as a read-only compatibility
    // path for missions saved before this refactor.
    // Proximity spawning is mandatory. Retain its visible Eden setting as an
    // explicit indicator, but do not permit saved legacy values to disable it.
    _proximitySpawning = true;
    private _standardValue = _logic getVariable ["airCombatSpawning", nil];
    if (!isNil "_standardValue") then {
        _airCombatSpawning = [_standardValue, _airCombatSpawning] call _asBool;
    };
    _standardValue = _logic getVariable ["spawnRadius", nil];
    if (!isNil "_standardValue") then {
        _spawnRadius = [_standardValue, _spawnRadius] call _asNumber;
    };
    _standardValue = _logic getVariable ["spawnTypeHeliRadius", nil];
    if (!isNil "_standardValue") then {
        _spawnTypeHeliRadius = [_standardValue, _spawnTypeHeliRadius] call _asNumber;
    };
    _standardValue = _logic getVariable ["spawnTypeJetRadius", nil];
    if (!isNil "_standardValue") then {
        _spawnTypeJetRadius = [_standardValue, _spawnTypeJetRadius] call _asNumber;
    };
    _standardValue = _logic getVariable ["spawnRadiusUAV", nil];
    if (!isNil "_standardValue") then {
        _spawnTypeUAVRadius = [_standardValue, _spawnTypeUAVRadius] call _asNumber;
    };
    _standardValue = _logic getVariable ["airCombatPlaneVehicleRadius", nil];
    if (!isNil "_standardValue") then {
        _airCombatPlaneVehicleRadius = ([_standardValue, _airCombatPlaneVehicleRadius] call _asNumber) max 0;
    };
    _standardValue = _logic getVariable ["airCombatHelicopterVehicleRadius", nil];
    if (!isNil "_standardValue") then {
        _airCombatHelicopterVehicleRadius = ([_standardValue, _airCombatHelicopterVehicleRadius] call _asNumber) max 0;
    };

    private _activeLimiter = parseNumber (_logic getVariable ["activeLimiter","30"]);
    private _zeusSpawn = (_logic getvariable ["zeusSpawn", "true"]) == "true";
    private _speedModifier = (_logic getVariable ["speedModifier","1"]) call BIS_fnc_parseNumber;
    private _virtualCombatSpeedModifier = parseNumber (_logic getVariable ["virtualcombat_speedmodifier", "1"]);
    private _virtualCombatRangeModifier = parseNumber (_logic getVariable ["virtualcombat_rangemodifier", "255"]);
    private _pathfinding = (_logic getVariable ["pathfinding", "false"]) == "true";
    // Pass the configured grid setting through RAW (no parse here). It may be an
    // auto-size token ("auto"/"high"/"med"/"low"), a stringified pair "[x,y]" from
    // a saved mission, or a legacy [x,y] array - the resolver in fnc_pathfinder
    // ("create") handles all shapes and falls back to auto on anything invalid.
    // (The old code parseSimpleArray'd this unconditionally, which errored on the
    // new string tokens and on an empty/missing value.)
    private _pathfindingSize = _logic getVariable ["pathfindingSize", "auto"];
    // Debug-draw toggles (independent of the module Debug flag). Same string
    // "true"/"false" combo shape as pathfinding/seaTransport above. These MUST be
    // forwarded to the profile system or the create block can't read them back and
    // the grid/route overlay never activates from the Eden defaults.
    private _pathfindingDrawGrid  = (_logic getVariable ["pathfindingDrawGrid",  "false"]) == "true";
    private _pathfindingDrawPaths = (_logic getVariable ["pathfindingDrawPaths", "false"]) == "true";
    // Sea-transport mode: Auto / Always / Never. Legacy missions stored the old
    // Yes/No combo as "true"/"false" - map those to always/never.
    private _seaTransport = switch (toLower (_logic getVariable ["seaTransport", "auto"])) do {
        case "always": { "always" };
        case "never":  { "never" };
        case "true":   { "always" };
        case "false":  { "never" };
        default        { "auto" };
    };
    private _smoothSpawn = parseNumber (_logic getVariable ["smoothSpawn", "0.3"]);
    private _vehicleSpawnSettleSeconds = parseNumber (_logic getVariable ["vehicleSpawnSettleSeconds", "15"]);

    // Despawn Linger. These four were defined on the module and read by the despawn paths,
    // but nothing ever carried them from the module to the system, so the defaults below
    // were all anyone ever got however the module was set (#1019).
    private _playerOccupantGrace = parseNumber (_logic getVariable ["playerOccupantGrace", "300"]);
    private _postDeathGrace      = parseNumber (_logic getVariable ["postDeathGrace", "120"]);
    private _postDeathRadius     = parseNumber (_logic getVariable ["postDeathRadius", "500"]);
    private _midCombatExtension  = parseNumber (_logic getVariable ["midCombatExtension", "60"]);

    //Ensure Event Log is loaded
    if (isnil "ALIVE_eventLog") then {
        ALIVE_eventLog = [nil, "create"] call ALIVE_fnc_eventLog;
        [ALIVE_eventLog, "init"] call ALIVE_fnc_eventLog;
        [ALIVE_eventLog, "debug", false] call ALIVE_fnc_eventLog;
    };

    ALIVE_profileSystem = [nil, "create"] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "init"] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "debug", _debug] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "persistent", _persistent] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "syncMode", _syncMode] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "syncedUnits", _syncedUnits] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "spawnRadius", _spawnRadius] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "spawnTypeJetRadius", _spawnTypeJetRadius] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "spawnRadiusUAV", _spawnTypeUAVRadius] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "spawnTypeHeliRadius", _spawnTypeHeliRadius] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "proximitySpawning", _proximitySpawning] call ALIVE_fnc_profileSystem;
    if (_airCombatSpawning) then {
        [ALIVE_profileSystem, "createAirCombatActivator", [_airCombatPlaneVehicleRadius, _airCombatHelicopterVehicleRadius]] call ALIVE_fnc_profileSystem;
    };
    [ALIVE_profileSystem, "activeLimiter", _activeLimiter] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "zeusSpawn", _zeusSpawn] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "speedModifier", _speedModifier] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "combatRate", _virtualCombatSpeedModifier] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "combatRange", _virtualCombatRangeModifier] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "pathfinding", _pathfinding] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "pathfindingSize", _pathfindingSize] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "pathfindingDrawGrid",  _pathfindingDrawGrid]  call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "pathfindingDrawPaths", _pathfindingDrawPaths] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "seaTransport", _seaTransport] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "smoothSpawn", _smoothSpawn] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "vehicleSpawnSettleSeconds", _vehicleSpawnSettleSeconds] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "playerOccupantGrace", _playerOccupantGrace] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "postDeathGrace", _postDeathGrace] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "postDeathRadius", _postDeathRadius] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "midCombatExtension", _midCombatExtension] call ALIVE_fnc_profileSystem;

    _logic setVariable ["handler",ALIVE_profileSystem];
    [ALIVE_profileSystem,"handler",_logic] call ALiVE_fnc_HashSet;

    PublicVariable QMOD(SYS_PROFILE);

    // #863 - publish the admin/Zeus debug-map global from the Eden
    // attribute. Live console toggle still works:
    //   ALiVE_debugVirtualisedProfiles = true; publicVariable "ALiVE_debugVirtualisedProfiles";
    // The PFH registered in XEH_postInit reads this global each tick.
    ALiVE_debugVirtualisedProfiles = _debugVirtualisedProfiles;
    publicVariable "ALiVE_debugVirtualisedProfiles";

    [ALIVE_profileSystem,"start"] call ALIVE_fnc_profileSystem;

};

if (isDedicated || (isServer)) then {
    if (MOD(SYS_PROFILE) getvariable ["debug", "false"] == "true") then {
	    ALiVE_SYS_PROFILE_DEBUG_ON = true;
	} else {
	    ALiVE_SYS_PROFILE_DEBUG_ON = false;
	};
};

if(hasInterface) then {

    waituntil {!isnil QMOD(SYS_PROFILE)};

    player addEventHandler ["killed",
    {
        []spawn {
            _uid = getPlayerUID player;

            ["server","PS",[["KILLED",_uid,player],{call ALIVE_fnc_createProfilesFromPlayers}]] call ALiVE_fnc_BUS;
        };
    }];
    player addEventHandler ["respawn",
    {
        []spawn {
            // wait for player
            waitUntil {sleep 0.3; alive player};
            waitUntil {sleep 0.3; (getPlayerUID player) != ""};

            _uid = getPlayerUID player;

            ["server","PS",[["RESPAWN",_uid,player],{call ALIVE_fnc_createProfilesFromPlayers}]] call ALiVE_fnc_BUS;
        };
    }];
};

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
