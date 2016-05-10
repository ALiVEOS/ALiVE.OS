#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectVehicle

Description:
Inspect a vehicle config file recursively to the RPT

Parameters:
Config - config file

Returns:

Examples:
(begin example)
// inspect config class
["B_Mortar_01_F"] call ALIVE_fnc_inspectVehicle;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_cfg","_detailed","_item","_text","_class","_cargoSpec","_commanderOptics","_library"];

_cfg = _this select 0;

[""] call ALIVE_fnc_dump;
_text = " ----------- "+_cfg+" ----------- ";
[_text] call ALIVE_fnc_dump;

[""] call ALIVE_fnc_dump;
["ALIVE functions -------"] call ALIVE_fnc_dump;


["Class: %1", _cfg call ALIVE_fnc_configGetVehicleClass] call ALIVE_fnc_dump;
["Crew: %1", _cfg call ALIVE_fnc_configGetVehicleCrew] call ALIVE_fnc_dump;
["EmptyPositions: %1", [_cfg] call ALIVE_fnc_configGetVehicleEmptyPositions] call ALIVE_fnc_dump;
["HitPoints: %1", _cfg call ALIVE_fnc_configGetVehicleHitPoints] call ALIVE_fnc_dump;
["MaxSpeed: %1", _cfg call ALIVE_fnc_configGetVehicleMaxSpeed] call ALIVE_fnc_dump;
["TurretPositions: %1", [_cfg] call ALIVE_fnc_configGetVehicleTurretPositions] call ALIVE_fnc_dump;
["Turrets: %1", _cfg call ALIVE_fnc_configGetVehicleTurrets] call ALIVE_fnc_dump;

[""] call ALIVE_fnc_dump;
["Main class -------"] call ALIVE_fnc_dump;

_class = (configFile >> "CfgVehicles" >> _cfg);

["hasDriver: %1", getNumber(_class >> "hasDriver")] call ALIVE_fnc_dump;
["hasGunner: %1", getNumber(_class >> "hasGunner")] call ALIVE_fnc_dump;
["primaryGunner: %1", getNumber(_class >> "primaryGunner")] call ALIVE_fnc_dump;
["primaryObserver: %1", getNumber(_class >> "primaryObserver")] call ALIVE_fnc_dump;
["armor: %1", getNumber(_class >> "armor")] call ALIVE_fnc_dump;
["commanderCanSee: %1", getNumber(_class >> "commanderCanSee")] call ALIVE_fnc_dump;
["cost: %1", getNumber(_class >> "cost")] call ALIVE_fnc_dump;
["crewCrashProtection: %1", getNumber(_class >> "crewCrashProtection")] call ALIVE_fnc_dump;
["crewVulnerable: %1", getNumber(_class >> "crewVulnerable")] call ALIVE_fnc_dump;
["driverCanEject: %1", getNumber(_class >> "driverCanEject")] call ALIVE_fnc_dump;
["driverCompartments: %1", getText(_class >> "driverCompartments")] call ALIVE_fnc_dump;
["faction: %1", getText(_class >> "faction")] call ALIVE_fnc_dump;
["hasTerminal: %1", getNumber(_class >> "hasTerminal")] call ALIVE_fnc_dump;
["model: %1", getText(_class >> "model")] call ALIVE_fnc_dump;
["nameSound: %1", getText(_class >> "nameSound")] call ALIVE_fnc_dump;
["picture: %1", getText(_class >> "picture")] call ALIVE_fnc_dump;
["scope: %1", getNumber(_class >> "scope")] call ALIVE_fnc_dump;
["side: %1", getNumber(_class >> "side")] call ALIVE_fnc_dump;
["supplyRadius: %1", getNumber(_class >> "supplyRadius")] call ALIVE_fnc_dump;
["textPlural: %1", getText(_class >> "textPlural")] call ALIVE_fnc_dump;
["textSingular: %1", getText(_class >> "textSingular")] call ALIVE_fnc_dump;
["type: %1", getNumber(_class >> "type")] call ALIVE_fnc_dump;

[""] call ALIVE_fnc_dump;
["Cargo spec -------"] call ALIVE_fnc_dump;

_cargoSpec = (configFile >> "CfgVehicles" >> _cfg >> "CargoSpec");
["Cargo Spec: %1", count _cargoSpec] call ALIVE_fnc_dump;

[""] call ALIVE_fnc_dump;
["Commander optics -------"] call ALIVE_fnc_dump;

_commanderOptics = (configFile >> "CfgVehicles" >> _cfg >> "CommanderOptics");
["canEject: %1", getNumber(_commanderOptics >> "canEject")] call ALIVE_fnc_dump;
["canHideGunner: %1", getNumber(_commanderOptics >> "canHideGunner")] call ALIVE_fnc_dump;
["commanding: %1", getNumber(_commanderOptics >> "commanding")] call ALIVE_fnc_dump;
["gunnerName: %1", getText(_commanderOptics >> "gunnerName")] call ALIVE_fnc_dump;
["gunnerOpticsModel: %1", getText(_commanderOptics >> "gunnerOpticsModel")] call ALIVE_fnc_dump;
["hasGunner: %1", getNumber(_commanderOptics >> "hasGunner")] call ALIVE_fnc_dump;
["hideWeaponsGunner: %1", getNumber(_commanderOptics >> "hideWeaponsGunner")] call ALIVE_fnc_dump;
["isCopilot: %1", getNumber(_commanderOptics >> "isCopilot")] call ALIVE_fnc_dump;
["primary: %1", getNumber(_commanderOptics >> "primary")] call ALIVE_fnc_dump;
["primaryGunner: %1", getNumber(_commanderOptics >> "primaryGunner")] call ALIVE_fnc_dump;
["primaryObserver: %1", getNumber(_commanderOptics >> "primaryObserver")] call ALIVE_fnc_dump;
["turretCanSee: %1", getNumber(_commanderOptics >> "turretCanSee")] call ALIVE_fnc_dump;
["viewGunnerInExterna: %1", getNumber(_commanderOptics >> "viewGunnerInExterna")] call ALIVE_fnc_dump;

[""] call ALIVE_fnc_dump;
["Description -------"] call ALIVE_fnc_dump;

_library = (configFile >> "CfgVehicles" >> _cfg >> "Library");
["libTextDesc: %1", getText(_library >> "libTextDesc")] call ALIVE_fnc_dump;