#include <\x\alive\addons\amb_civ_population\script_component.hpp>
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

private ["_logic","_debug","_spawnRadius","_spawnTypeJetRadius","_spawnTypeHeliRadius","_activeLimiter","_hostilityWest","_hostilityEast","_hostilityIndep","_moduleID","_ambientCivilianRoles"];

PARAMS_1(_logic);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_civilianPopulationSystem","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

if(isServer) then {
    
    MOD(amb_civ_population) = _logic;
	
	_debug = call compile (_logic getVariable ["debug","false"]);
	_spawnRadius = parseNumber (_logic getVariable ["spawnRadius","1500"]);
    _spawnTypeHeliRadius = parseNumber (_logic getVariable ["spawnTypeHeliRadius","1500"]);
	_spawnTypeJetRadius = parseNumber (_logic getVariable ["spawnTypeJetRadius","0"]);
	_activeLimiter = parseNumber (_logic getVariable ["activeLimiter","30"]);
	_hostilityWest = parseNumber (_logic getVariable ["hostilityWest","0"]);
	_hostilityEast = parseNumber (_logic getVariable ["hostilityEast","0"]);
	_hostilityIndep = parseNumber (_logic getVariable ["hostilityIndep","0"]);
    _ambientCivilianRoles = call compile (_logic getVariable ["ambientCivilianRoles","[]"]);
   
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

	if (count _ambientCivilianRoles == 0) then {GVAR(ROLES_DISABLED) = true} else {GVAR(ROLES_DISABLED) = false};
    PublicVariable QGVAR(ROLES_DISABLED);

	_logic setVariable ["handler",ALIVE_civilianPopulationSystem];
    
    PublicVariable QMOD(amb_civ_population);

	[ALIVE_civilianPopulationSystem,"start"] call ALIVE_fnc_civilianPopulationSystem;
};

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;