#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectClasses);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectClasses

Description:
Inspect a group of defined classes to the RPT

Parameters:
Boolean - detailed inspection

Returns:

Examples:
(begin example)
// inspect config class
[] call ALIVE_fnc_inspectClasses;
(end)

See Also:
ALIVE_inspectConfig

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_detailed","_text","_cfg","_item"];
	
_detailed = if(count _this > 0) then {_this select 0} else {false};

_text = " ------------------ Inspecting Classes -------------------- ";
[_text] call ALIVE_fnc_dump;

["CfgWeapons", _detailed] call ALIVE_fnc_inspectConfig;	
["CfgMagazines", _detailed] call ALIVE_fnc_inspectConfig;	
["CfgAmmo", _detailed] call ALIVE_fnc_inspectConfig;
["CfgGlasses", _detailed] call ALIVE_fnc_inspectConfig;	
["CfgVehicles", _detailed] call ALIVE_fnc_inspectConfig;
["CfgMarkers", _detailed] call ALIVE_fnc_inspectConfig;

_text = " ------------------ Inspection Complete -------------------- ";
[_text] call ALIVE_fnc_dump;