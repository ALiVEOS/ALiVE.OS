#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(iedUnitQualifies);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_iedUnitQualifies
Description:
Single source of truth for "does this unit count as an IED-capable
engineer / EOD specialist". Used in two places that must stay in sync:

  - fnc_armIED.sqf trip-pressure model: a qualifying dismounted unit
    accumulates trip pressure instead of detonating instantly.
  - fnc_addActionIED.sqf + sys_acemenu disarm action: only qualifying
    units are offered the "Disarm IED" interaction.

Qualification (any of, while on foot):
  - configured detection device (default "MineDetector") in items
  - CfgVehicles displayName == "Explosive Specialist"
  - vehicleVarName matches CBA "EOD" trait
  - vanilla A3 getUnitTrait "explosivesSpecialist"
  - ACE_isEngineer > 0 (ACE engineer level 1 or 2)
  - ACE_isEOD (ACE explosives-specialist role)

Vehicle-borne units never qualify - a vehicle isn't "carefully
approaching" and you can't reach a buried charge from a seat.

Parameters:
0: OBJECT - unit to test
1: STRING - detection device classname (optional, default "MineDetector")

Returns:
BOOL - true if the unit qualifies

Author:
Jman
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_device", "MineDetector", [""]]];

if (isNull _unit) exitWith { false };

// Dismounted only.
if ((vehicle _unit) != _unit) exitWith { false };

(
    (_device in (items _unit)) ||
    (getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName") == "Explosive Specialist") ||
    ([vehicleVarName _unit, "EOD"] call CBA_fnc_find != -1) ||
    (_unit getUnitTrait "explosivesSpecialist") ||
    ((_unit getVariable ["ACE_isEngineer", 0]) > 0) ||
    (_unit getVariable ["ACE_isEOD", false])
)
