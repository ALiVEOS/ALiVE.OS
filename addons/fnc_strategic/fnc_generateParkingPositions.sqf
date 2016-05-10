//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(generateParkingPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_generateParkingPositions
Description:
Set cluster values on array of clusters

Parameters:
Array - Array of clusters
Array - Array of building names to generate parking positions for

Returns:
Array - array of arrays containing positions and directions

Examples:
(begin example)
_result = [_clusters, _types] call ALIVE_fnc_generateParkingPositions;
(end)

See Also:

Author:
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_clusters","_buildingTypeWhitelist","_nodes","_positions","_node","_model","_isBuilding","_position","_direction","_vehicleClass","_parkingPosition"];

_clusters = _this select 0;
_buildingTypeWhitelist = _this select 1;

{
	ALIVE_parkingVehicles = [];
	_nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;
	_positions = [];
	//[_x, "debug", true] call ALIVE_fnc_cluster;
	{
		_node = _x;
		_model = toLower(getText(configFile >> "CfgVehicles" >> (typeOf _x) >> "model"));
		_isBuilding = false;
		
		{
			if([_model, _x] call CBA_fnc_find != -1) then {
				_isBuilding = true;
			};
		} forEach _buildingTypeWhitelist;
		
		if(_isBuilding) then {
			_position = position _x;
			_direction = (direction _x) + 180;
			_vehicleClass = "B_Truck_01_mover_F";
			_parkingPosition = [_vehicleClass,_position,_direction] call ALIVE_fnc_generateParkingPosition;
			_positions set [count _positions, _parkingPosition];
		};
	} forEach _nodes;
	
	if(count _positions > 0) then {
		[_x,"parkingPositions",_positions] call ALIVE_fnc_cluster;
	};
	
	/*
	{
		deleteVehicle _x;
	} forEach ALIVE_parkingVehicles;
	*/
	
} forEach _clusters;