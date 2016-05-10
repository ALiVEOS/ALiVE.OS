#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectObject);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectObject

Description:
Inspect an object to the RPT

Parameters:

Returns:

Examples:
(begin example)
// inspect config class
[_object] call ALIVE_fnc_inspectObject;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_target","_text","_pos","_tX","_tY","_tZ","_grid"];
	
_target = _this select 0;

_text = " ------------------ Inspecting Target -------------------- ";
[_text] call ALIVE_fnc_dump;

[" name: %1", name _target] call ALIVE_fnc_dump;
[" instanceName: %1", vehicleVarName _target] call ALIVE_fnc_dump;
[" model: %1", getText(configFile >> "CfgVehicles" >> (typeOf _target) >> "model")] call ALIVE_fnc_dump;
[" data type: %1", typeName _target] call ALIVE_fnc_dump;
[" class name: %1", typeOf _target] call ALIVE_fnc_dump;
[" is alive: %1", alive _target] call ALIVE_fnc_dump;
[" is player: %1", isPlayer _target] call ALIVE_fnc_dump;
[" is leader: %1", isFormationLeader _target] call ALIVE_fnc_dump;
[" group: %1", group _target] call ALIVE_fnc_dump;
[" unit ready: %1", unitReady _target] call ALIVE_fnc_dump;
[" waypoints: %1", waypoints group _target] call ALIVE_fnc_dump;
[" current waypoint: %1", currentWaypoint group _target] call ALIVE_fnc_dump;
[" side: %1", side _target] call ALIVE_fnc_dump;
[" rank: %1", rank _target] call ALIVE_fnc_dump;
[" rating: %1", rating _target] call ALIVE_fnc_dump;
[" can stand: %1", canStand _target] call ALIVE_fnc_dump;
[" can move: %1", canMove _target] call ALIVE_fnc_dump;
[" can fire: %1", canFire _target] call ALIVE_fnc_dump;
[" need reload: %1", needReload _target] call ALIVE_fnc_dump;
[" able to breathe: %1", isAbleToBreathe _target] call ALIVE_fnc_dump;
[" oxygen remaining: %1", getOxygenRemaining _target] call ALIVE_fnc_dump;
[" on road: %1", isOnRoad getPos _target] call ALIVE_fnc_dump;
[" is engine on: %1", isEngineOn _target] call ALIVE_fnc_dump;
[" is mine active: %1", mineActive _target] call ALIVE_fnc_dump;
[" damage: %1", damage _target] call ALIVE_fnc_dump;
[" morale: %1", morale _target] call ALIVE_fnc_dump;
[" is burning: %1", isBurning _target] call ALIVE_fnc_dump;
[" bleeding: %1", isBleeding _target] call ALIVE_fnc_dump;
[" bleeding remaining: %1", getBleedingRemaining _target] call ALIVE_fnc_dump;
[" is touching ground: %1", isTouchingGround _target] call ALIVE_fnc_dump;
[" is under water: %1", underwater _target] call ALIVE_fnc_dump;
[" weapon lowered: %1", weaponLowered _target] call ALIVE_fnc_dump;
[" knows about: %1", _target knowsAbout player] call ALIVE_fnc_dump;
[" current stance: %1", stance _target] call ALIVE_fnc_dump;
[" current behaviour: %1", behaviour _target] call ALIVE_fnc_dump;
[" position: %1", getPos _target] call ALIVE_fnc_dump;
[" position ASL: %1", getPosASL _target] call ALIVE_fnc_dump;
[" position ATL: %1", getPosATL _target] call ALIVE_fnc_dump;
[" direction: %1", direction _target] call ALIVE_fnc_dump;
[" eye direction: %1", eyeDirection _target] call ALIVE_fnc_dump;
_pos = position _target;
_tX = _pos select 0;
_tY = _pos select 1;
_tZ = _pos select 2;
_grid = mapGridPosition _pos;
[" x:%1 y:%2 z:%3 grid:%4", _tX, _tY, _tZ, _grid] call ALIVE_fnc_dump;
[" bounding box real: %1", boundingBoxReal _target] call ALIVE_fnc_dump;
[" nearest building: %1", nearestBuilding _target] call ALIVE_fnc_dump;
[" headgear: %1", headgear _target] call ALIVE_fnc_dump;
[" goggles: %1", goggles _target] call ALIVE_fnc_dump;
[" primary weapon: %1", primaryWeapon _target] call ALIVE_fnc_dump;
[" primary weapon items: %1", primaryWeaponItems _target] call ALIVE_fnc_dump;
[" secondary weapon: %1", secondaryWeapon _target] call ALIVE_fnc_dump;
[" secondary weapon items: %1", secondaryWeaponItems _target] call ALIVE_fnc_dump;
[" handgun: %1", handgunWeapon _target] call ALIVE_fnc_dump;
[" handgun items: %1", handgunItems _target] call ALIVE_fnc_dump;
[" assignedItems: %1", assignedItems _target] call ALIVE_fnc_dump;
[" uniform: %1", uniform _target] call ALIVE_fnc_dump;
[" uniformItems: %1", uniformItems _target] call ALIVE_fnc_dump;
[" vest: %1", vest _target] call ALIVE_fnc_dump;
[" vest items: %1", vestItems _target] call ALIVE_fnc_dump;
[" backpack: %1", backpack _target] call ALIVE_fnc_dump;
[" backpack items: %1", backpackItems _target] call ALIVE_fnc_dump;
[" weapons: %1", weapons _target] call ALIVE_fnc_dump;
[" magazines: %1", magazines _target] call ALIVE_fnc_dump;
[" vehicle ammo: %1", _target call ALIVE_fnc_vehicleGetAmmo] call ALIVE_fnc_dump;
[" vehicle damage: %1", _target call ALIVE_fnc_vehicleGetDamage] call ALIVE_fnc_dump;
[" vehicle turrets: %1", typeOf _target call ALIVE_fnc_configGetVehicleTurrets] call ALIVE_fnc_dump;
[" vehicle turret positions: %1", [typeOf _target] call ALIVE_fnc_configGetVehicleTurretPositions] call ALIVE_fnc_dump;
//[" vehicle turret positions: %1", [typeOf _target, true, true] call ALIVE_fnc_configGetVehicleTurretPositions] call ALIVE_fnc_dump;
[" vehicle empty positions: %1", [_target] call ALIVE_fnc_vehicleGetEmptyPositions] call ALIVE_fnc_dump;
[" vehicle empty position count: %1", [_target] call ALIVE_fnc_vehicleCountEmptyPositions] call ALIVE_fnc_dump;
[" vehicle speeds per second: %1", typeOf _target call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_dump;
[" ammo cargo: %1", getAmmoCargo _target] call ALIVE_fnc_dump;
[" weapon cargo: %1", getWeaponCargo _target] call ALIVE_fnc_dump;
[" fuel cargo: %1", getFuelCargo _target] call ALIVE_fnc_dump;
[" backpack cargo: %1", getBackpackCargo _target] call ALIVE_fnc_dump;
[" item cargo: %1", getItemCargo _target] call ALIVE_fnc_dump;
[" repair cargo: %1", getRepairCargo _target] call ALIVE_fnc_dump;

/* NOT IN ALPHA?
[" is pip enabled: %1", isPipEnabled _target] call ALIVE_fnc_dump;
*/
/* NOT IN ALPHA?
[" is tutorial hints enabled: %1", isTutHintsEnabled _target] call ALIVE_fnc_dump;
*/
/*
[" fatigue: %1", getFatigue _target] call ALIVE_fnc_dump;
*/
/* NOT IN ALPHA?
[" burning: %1", getBuringValue _target] call ALIVE_fnc_dump;
*/
/* NOT IN ALPHA?
[" is flashlight on: %1", isFlashlightOn _target] call ALIVE_fnc_dump;
*/
/* NOT IN ALPHA?
[" is laser on: %1", isIRLaserOn _target] call ALIVE_fnc_dump;
*/

_text = " ------------------ Inspection Complete -------------------- ";
[_text] call ALIVE_fnc_dump;