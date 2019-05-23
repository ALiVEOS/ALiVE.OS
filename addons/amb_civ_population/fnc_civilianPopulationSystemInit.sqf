#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civilianPopulationSystemInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civilianPopulationSystemInit
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

params ["_logic"];

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_civilianPopulationSystem","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

if(isServer) then {

    MOD(amb_civ_population) = _logic;

    private _debug = (_logic getVariable ["debug","false"]) == "true";
    private _spawnRadius = parseNumber (_logic getVariable ["spawnRadius","1500"]);
    private _spawnTypeHeliRadius = parseNumber (_logic getVariable ["spawnTypeHeliRadius","1500"]);
    private _spawnTypeJetRadius = parseNumber (_logic getVariable ["spawnTypeJetRadius","0"]);
    private _activeLimiter = parseNumber (_logic getVariable ["activeLimiter","30"]);
    private _hostilityWest = parseNumber (_logic getVariable ["hostilityWest","0"]);
    private _hostilityEast = parseNumber (_logic getVariable ["hostilityEast","0"]);
    private _hostilityIndep = parseNumber (_logic getVariable ["hostilityIndep","0"]);
    private _ambientCivilianRoles = call compile (_logic getVariable ["ambientCivilianRoles","[]"]);
    private _ambientCrowdSpawn = parseNumber (_logic getVariable ["ambientCrowdSpawn","0"]);
    private _ambientCrowdDensity = parseNumber (_logic getVariable ["ambientCrowdDensity","4"]);
    private _ambientCrowdLimit = parseNumber (_logic getVariable ["ambientCrowdLimit","50"]);
    private _ambientCrowdFaction = (_logic getVariable ["ambientCrowdFaction",""]);

//Check if a SYS Profile Module is available
    private _errorMessage = "No Virtual AI system module was found! Please use this module in your mission! %1 %2";
    private _error1 = "";
    private _error2 = ""; //defaults

    if !([QMOD(sys_profile)] call ALiVE_fnc_isModuleAvailable) exitwith {
        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpMPH;
    };

    if !([QMOD(amb_civ_population)] call ALiVE_fnc_isModuleAvailable) then {
        ["WARNING: Civilian Placement module not placed!"] call ALiVE_fnc_DumpR;
    };

    ALIVE_civilianHostility = [] call ALIVE_fnc_hashCreate;
    [ALIVE_civilianHostility, "WEST", _hostilityWest] call ALIVE_fnc_hashSet;
    [ALIVE_civilianHostility, "EAST", _hostilityEast] call ALIVE_fnc_hashSet;
    [ALIVE_civilianHostility, "GUER", _hostilityIndep] call ALIVE_fnc_hashSet;

    ALIVE_civilianPopulationSystem = [nil, "create"] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "init"] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "debug", _debug] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "spawnRadius", _spawnRadius] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "spawnTypeJetRadius", _spawnTypeJetRadius] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "spawnTypeHeliRadius", _spawnTypeHeliRadius] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "activeLimiter", _activeLimiter] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCivilianRoles", _ambientCivilianRoles] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdSpawn", _ambientCrowdSpawn] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdDensity", _ambientCrowdDensity] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdLimit", _ambientCrowdLimit] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdFaction", _ambientCrowdFaction] call ALIVE_fnc_civilianPopulationSystem;

    if (count _ambientCivilianRoles == 0) then {GVAR(ROLES_DISABLED) = true} else {GVAR(ROLES_DISABLED) = false};
    PublicVariable QGVAR(ROLES_DISABLED);

    _logic setVariable ["handler",ALIVE_civilianPopulationSystem];

    PublicVariable QMOD(amb_civ_population);

    [ALIVE_civilianPopulationSystem,"start"] call ALIVE_fnc_civilianPopulationSystem;

};

[_logic] call ALiVE_fnc_civInteractInit;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
