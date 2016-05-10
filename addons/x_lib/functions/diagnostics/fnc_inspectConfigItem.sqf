#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectConfigItem);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectConfigItem

Description:
Inspect a config item to the RPT

Parameters:
Config - config file
Boolean - detailed inspection

Returns:

Examples:
(begin example)
// inspect config class
["LMG_M200"] call ALIVE_fnc_inspectConfigItem;

// inspect config class with extra details
["LMG_M200", true] call ALIVE_fnc_inspectConfigItem;
(end)

See Also:
ALIVE_inspectConfig

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_item","_detailed","_class","_type","_scope","_picture"];

_item = _this select 0;
_detailed = if(count _this > 1) then {_this select 1} else {false};

if(isClass _item) then {
	_class = configName _item;
	_type = getNumber(_item >> "type");
	_scope = getNumber(_item >> "scope");
	_picture = getText(_item >> "picture");
	if(_detailed) then {
		["class: %1 type: %2 scope: %3 picture: %4 path: %5",_class,_type,_scope,_picture,_item] call ALIVE_fnc_dump;
	} else {
		["%1",_class] call ALIVE_fnc_dump;
	};	
};