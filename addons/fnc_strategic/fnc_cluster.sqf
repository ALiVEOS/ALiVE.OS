#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(cluster);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Creates the server side object to cluster information

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of cluster
Array - nodes - Array of object nodes within cluster
Object - addNode - Add object to node array of cluster
Object - delNode - Delete object from node array of cluster
Array - center - (Read only) - Recalculate, set and return centre position of cluster
Number - size - (Read only) - Maximum distance of an object from the centre

Examples:
(begin example)
// 
(end)

See Also:
- <ALIVE_fnc_findClusters>
- <ALIVE_fnc_consolidateClusters>

Author:
Wolffy.au

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_cluster
#define MTEMPLATE "ALiVE_CLUSTER_%1_%2"

private ["_createMarkers","_deleteMarkers","_nodes","_center","_result"];

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

TRACE_2("cluster - input",_operation,_args);

_result = true;



_deleteMarkers = {
	private ["_logic"];
	_logic = _this;
	{
		deleteMarkerLocal _x;
	} forEach ([_logic, "debugMarkers", []] call ALIVE_fnc_hashGet);
};

_createMarkers = {
	private ["_logic","_markers","_m","_size","_priority","_type","_id","_nodes","_center","_random"];
	_logic = _this;
	_markers = [];
	_nodes = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
	_random = floor(random 10000);
	
	if(count _nodes > 0) then {
		// mark all nodes
		{
			_m = format[MTEMPLATE, _random, count _markers];
			if(str getMarkerPos _m == "[0,0,0]") then {
				_m = createMarker [_m, getPosATL _x];
				_m setMarkerShape "Icon";
				_m setMarkerSize [0.5,0.5];
				_m setMarkerType "mil_dot";
				_markers set [count _markers, _m];
			} else {
				_m setMarkerPos (getPosATL _x);
			};
			_m setMarkerColor ([_logic, "debugColor","ColorYellow"] call ALIVE_fnc_hashGet);
		} forEach _nodes;

		_center = [_logic, "center"] call MAINCLASS;
		_size = [_logic, "size"] call MAINCLASS;
		_priority = [_logic, "priority"] call MAINCLASS;
		_type = [_logic, "type"] call MAINCLASS;
		_id = [_logic, "clusterID", ""] call ALIVE_fnc_hashGet;
		_m = createMarker [format[MTEMPLATE, _random, count _markers], _center];
		_m setMarkerShape "Icon";
		_m setMarkerSize [0.75, 0.75];
		_m setMarkerType "mil_dot";
		_m setMarkerColor ([_logic, "debugColor","ColorYellow"] call ALIVE_fnc_hashGet);
		_m setMarkerText format["%1|%2|%3|%4",_id,_type,_priority,floor(_size)];
		_markers set [count _markers, _m];
		
		_m = createMarker [_m + "_size", _center];
		_m setMarkerShape "Ellipse";
		_m setMarkerSize [_size, _size];
		_m setMarkerColor ([_logic, "debugColor","ColorYellow"] call ALIVE_fnc_hashGet);
		_m setMarkerAlpha 0.5;
		_markers set [count _markers, _m];
		
		[_logic, "debugMarkers", _markers] call ALIVE_fnc_hashSet;
	};
};

switch(_operation) do {
	case "create": {                
		/*
		MODEL - no visual just reference data
		- nodes
		- center
		- size
		*/
		
		if (isServer) then {
			// if server, initialise module game logic
			_logic = [nil, "create"] call SUPERCLASS;
			[_logic,"super"] call ALIVE_fnc_hashRem;
			[_logic,"class"] call ALIVE_fnc_hashRem;
			
			TRACE_1("After module init",_logic);
			_result = _logic;
		};
		
		
		/*
		VIEW - purely visual
		*/
		
		/*
		CONTROLLER  - coordination
		*/
	};
	case "destroy": {
		[_logic, "debug", false] call MAINCLASS;
		if (isServer) then {
			// if server
			[_logic, "destroy"] call SUPERCLASS;
		};
		
		_logic = nil;
	};
	case "debug": {
		if(typeName _args != "BOOL") then {
			_args = [_logic, "debug", false] call ALIVE_fnc_hashGet;
		} else {
			[_logic, "debug", _args] call ALIVE_fnc_hashSet;
		};                
		ASSERT_TRUE(typeName _args == "BOOL",str _args);
		_logic call _deleteMarkers;
		
		if(_args) then {
			_logic call _createMarkers;
		};
		_result = _args;
	};        
	case "state": {
		private["_state","_data","_nodes","_objID"];
		
		if(typeName _args != "ARRAY") then {
			_state = [] call ALIVE_fnc_hashCreate;
			// Save state
			
			// nodes
			_data = [];
			{
				if!(isNil "_x") then {
					_data set [count _data, [
						_x call ALIVE_fnc_findObjectIDString,
						position _x
					]];
				};
			} forEach ([_logic, "nodes",[]] call ALIVE_fnc_hashGet);
			
			_result = [_state, "nodes", _data] call ALIVE_fnc_hashSet;
		} else {
			ASSERT_TRUE([_args] call ALIVE_fnc_isHash,str _args);
			
			// Restore state
			
			// nodes
			_data = [];
			_nodes = [_args, "nodes"] call ALIVE_fnc_hashGet;
			{
				private["_node"];
				_objID = parseNumber(_x select 0);
				if(_objID > 0) then {
					_node = (_x select 1) nearestObject (parseNumber(_x select 0));
					_data set [count _data, _node];
				}
			} forEach _nodes;
			[_logic, "nodes", _data] call MAINCLASS;
		};		
	};
	case "center": {
		// Read Only - return centre of clustered nodes
		_args = [_logic, _operation, []] call ALIVE_fnc_hashGet;
		if(count _args == 0) then {
			_result = [[_logic, "nodes",[]] call ALIVE_fnc_hashGet] call ALIVE_fnc_findClusterCenter;
			[_logic, _operation, _result] call ALIVE_fnc_hashSet;
		} else {
			_result = _args;
		};
	};	
	case "size": {
		// Read Only - return distance from centre to furthest node
		_args = [_logic, _operation, 0] call ALIVE_fnc_hashGet;
		if(_args == 0) then {
			private ["_max"];
			_nodes = [_logic, "nodes",[]] call ALIVE_fnc_hashGet;
			_result = MIN_CLUSTER_SIZE;
			_center = [_logic, "center"] call MAINCLASS;
			if(count _center > 0) then {
				{
					if(_x distance _center > _result) then {_result = _x distance _center;};
				} forEach _nodes;
			};
			[_logic, _operation, _result] call ALIVE_fnc_hashSet;
		} else {
			_result = _args;
		};
	};
	case "nodes": {
		if(typeName _args == "ARRAY") then {
			[_logic, "nodes", _args] call ALIVE_fnc_hashSet;
		};
		
		if ([_logic, "debug", false] call ALIVE_fnc_hashGet) then {
			[_logic, "debug"] call MAINCLASS;
		};
		[_logic, "center", []] call ALIVE_fnc_hashSet;
		[_logic, "size", 0] call ALIVE_fnc_hashSet;
		_result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
	};
	case "addNode": {
		if(typeName _args == "OBJECT") then {
			_result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
			[_logic, "nodes", _result + [_args]] call ALIVE_fnc_hashSet;
			
			if ([_logic, "debug", false] call ALIVE_fnc_hashGet) then {
				[_logic, "debug"] call MAINCLASS;
			};
		};
		[_logic, "center", []] call ALIVE_fnc_hashSet;
		[_logic, "size", 0] call ALIVE_fnc_hashSet;
		_result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
	};
	case "delNode": {
		if(typeName _args == "OBJECT") then {
			_result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
			[_logic, "nodes", _result - [_args]] call ALIVE_fnc_hashSet;
			
			if ([_logic, "debug", false] call ALIVE_fnc_hashGet) then {
				[_logic, "debug"] call MAINCLASS;
			};
		};
		[_logic, "center", []] call ALIVE_fnc_hashSet;
		[_logic, "size", 0] call ALIVE_fnc_hashSet;
		_result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
	};        
	// Determine cluster type - valid values are: military, infrastructure and civilian
	case "type": {
		_result = [
			_logic,_operation,_args,
			"CIV",
			["MIL","INF","CIV"]
		] call ALIVE_fnc_OOsimpleOperation;
	};        
	// Determine cluster priority - valid values are any integer, higher numbers higher priority
	case "priority": {
		_result = [
			_logic,_operation,_args,
			0
		] call ALIVE_fnc_OOsimpleOperation;
	};
	// Determine cluster priority - valid values are any integer, higher numbers higher priority
	case "clusterID": {
		_result = [
			_logic,_operation,_args,
			0
		] call ALIVE_fnc_OOsimpleOperation;
	};   
	default {
		_result = [_logic, _operation, _args] call SUPERCLASS;
	};
};
TRACE_1("cluster - output",_result);
_result;