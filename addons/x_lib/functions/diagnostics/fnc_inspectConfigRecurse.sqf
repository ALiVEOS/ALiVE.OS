#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectConfigRecurse);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectConfigRecurse

Description:
Inspect a config file recursively to the RPT

Parameters:
Config - config file

Returns:

Examples:
(begin example)
// inspect config class
["CfgVehicles"] call ALIVE_fnc_inspectConfigRecurse;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_cfg","_detailed","_item","_text","_result","_findRecurse","_className"];

_cfg = _this select 0;

_text = " ----------- "+_cfg+" ----------- ";
[_text] call ALIVE_fnc_dump;

_result = [];

_findRecurse = {
	private ["_root","_class","_path","_currentPath"];
	
	_root = (_this select 0);
	_path = +(_this select 1);
	
	["R: %1",_root] call ALIVE_fnc_dump;
	
	for "_i" from 0 to count _root -1 do {
	
		_class = _root select _i;
		
		if (isClass _class) then {
			_currentPath = _path + [_i];
			
			_className = configName _class;
			
			_class = _root >> _className;
			
			[_class, _currentPath] call _findRecurse;
		};
	};
};

_class = (configFile >> _cfg);

[_class, []] call _findRecurse;

_result