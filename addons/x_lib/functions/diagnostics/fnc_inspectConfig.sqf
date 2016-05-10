#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectConfig);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectConfig

Description:
Inspect a config file to the RPT

Parameters:
Config - config file
Boolean - detailed inspection

Returns:

Examples:
(begin example)
// inspect config class
["CfgWeapons"] call ALIVE_fnc_inspectConfig;

// inspect config class with extra details
["CfgWeapons", true] call ALIVE_fnc_inspectConfig;
(end)

See Also:
ALIVE_inspectClasses
ALIVE_inspectConfigItem

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_cfg","_detailed","_item","_text"];

_cfg = _this select 0;
_detailed = if(count _this > 1) then {_this select 1} else {false};

_text = " ----------- "+_cfg+" ----------- ";
[_text] call ALIVE_fnc_dump;

_cfg = configFile >> _cfg;

for "_i" from 0 to (count _cfg)-1 do {
	_item = _cfg select _i;
	[_item, _detailed] call ALIVE_fnc_inspectConfigItem;
};