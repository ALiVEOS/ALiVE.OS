#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(findBuildingsInClusterNodes);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findBuildingsInClusterNodes

Description:
Search a clusters nodes for a set of building names

Parameters:
Array - A list of building names

Returns:
Array - List of buildings

Examples:
(begin example)
// search cluster nodes for buildings types
_center = [_nodes, _types] call ALIVE_fnc_findBuildingsInClusterNodes;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_err","_err1","_err2","_buildings","_node","_model","_isBuilding","_result"];

params [
    ["_nodes", [], [[]]],
    ["_types", [], [[]]]
];
_err1 = format["cluster nodes array not valid - %1",_nodes];
_err2 = format["building types array not valid - %1",_nodes];
ASSERT_DEFINED("_nodes",_err);
ASSERT_TRUE(typeName _nodes == "ARRAY",_err);
ASSERT_DEFINED("_types",_err2);
ASSERT_TRUE(typeName _types == "ARRAY",_err2);

_buildings = [];
						
{
	_node = _x;
	_model = toLower(getText(configFile >> "CfgVehicles" >> (typeOf _node) >> "model"));
	_isBuilding = false;
	
	{
		if([_model, _x] call CBA_fnc_find != -1) then {
			_isBuilding = true;
		};
	} forEach _types;
	
	if(_isBuilding) then {
		_buildings set [count _buildings, _x];
	};
} forEach _nodes;

_buildings