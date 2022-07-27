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
    private _persistent = (_logic getVariable ["persistent","false"]) == "true";
    private _syncMode = _logic getVariable ["syncronised","ADD"];
    private _syncedUnits = synchronizedObjects _logic;
    private _spawnRadius = parseNumber (_logic getVariable ["spawnRadius","1500"]);
    private _spawnTypeHeliRadius = parseNumber (_logic getVariable ["spawnTypeHeliRadius","1500"]);
    private _spawnTypeJetRadius = parseNumber (_logic getVariable ["spawnTypeJetRadius","0"]);
	private _spawnTypeUAVRadius = parseNumber (_logic getVariable ["spawnRadiusUAV", "-1"]);
    private _activeLimiter = parseNumber (_logic getVariable ["activeLimiter","30"]);
    private _zeusSpawn = (_logic getvariable ["zeusSpawn", "true"]) == "true";
    private _speedModifier = (_logic getVariable ["speedModifier","1"]) call BIS_fnc_parseNumber;
    private _virtualCombatSpeedModifier = parsenumber (_logic getVariable ["virtualcombat_speedmodifier", "1"]);
    private _pathfinding = (_logic getVariable ["pathfinding", "false"]) == "true";
    private _seaTransport = (_logic getVariable ["seaTransport", "false"]) == "true";
    private _smoothSpawn = parseNumber (_logic getVariable ["smoothSpawn", "0.3"]);

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
    [ALIVE_profileSystem, "activeLimiter", _activeLimiter] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "zeusSpawn", _zeusSpawn] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "speedModifier", _speedModifier] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "combatRate", _virtualCombatSpeedModifier] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "pathfinding", _pathfinding] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "seaTransport", _seaTransport] call ALIVE_fnc_profileSystem;
    [ALIVE_profileSystem, "smoothSpawn", _smoothSpawn] call ALIVE_fnc_profileSystem;

    _logic setVariable ["handler",ALIVE_profileSystem];
    [ALIVE_profileSystem,"handler",_logic] call ALiVE_fnc_HashSet;

    PublicVariable QMOD(SYS_PROFILE);

    [ALIVE_profileSystem,"start"] call ALIVE_fnc_profileSystem;
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
