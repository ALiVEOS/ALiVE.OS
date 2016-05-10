#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(markUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markUnits

Description:
Mark units for admins, displays active units and profiled ones.

Parameters:
String - vehicle class name

Returns:
String vehicle type

Examples:
(begin example)
// get vehicle type 
_result = [] call ALIVE_fnc_markUnits;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_m","_markers","_delay"];

[] spawn {

	_markers = [];
	_delay = 30;
	
	{
		_m = createMarkerLocal [str _x, position _x];
		_m setMarkerSizeLocal [.6,.6];
		_markers set [count _markers, _m];
        
		switch (side _x) do {
			case west: {
				_m setMarkerTypeLocal "b_unknown";
				_m setMarkerColorLocal "ColorBLUFOR";
			};
			case east: {
				_m setMarkerTypeLocal "o_unknown";
				_m setMarkerColorLocal "ColorOPFOR";
			};
			case resistance: {
				_m setMarkerTypeLocal "n_unknown";
				_m setMarkerColorLocal "ColorIndependent";
			};
			case civilian: {
				_m setMarkerTypeLocal "c_unknown";
				_m setMarkerColorLocal "ColorCivilian";
			};
		};
        
        if (isPlayer _x) then {
			_m setMarkerColorLocal "ColorBlack";
        };
	} forEach allUnits;

	// not spawned
	private["_inactiveEntities","_position","_side","_i"];

	if (isServer) then {
		_inactiveEntities = [] call ALIVE_fnc_getInActiveEntitiesForMarking;
	} else {
		_inactiveEntities = ["server","Subject",[[1],{[] call ALIVE_fnc_getInActiveEntitiesForMarking}]] call ALiVE_fnc_BUS;
	};
    
    if !(!isnil "_inactiveEntities" && {typename _inactiveEntities == "ARRAY"}) then {_inactiveEntities = []};

	{
		_position = _x select 0;
		_side = _x select 1;

		_m = createMarkerLocal [format["inactive_%1",_forEachIndex], _position];
		_m setMarkerSizeLocal [.45,.45];
		_m setMarkerAlphaLocal 0.5;
		_markers set [count _markers, _m];

		switch (_side) do {
			case "WEST":{
				_m setMarkerTypeLocal "b_unknown";
				_m setMarkerColorLocal "ColorBLUFOR";
			};
			case "EAST":{
				_m setMarkerTypeLocal "o_unknown";
				_m setMarkerColorLocal "ColorOPFOR";
			};
			case "GUER":{
				_m setMarkerTypeLocal "n_unknown";
				_m setMarkerColorLocal "ColorIndependent";
			};
		};

	} forEach _inactiveEntities;
	

	_i = 1;
	waitUntil {
		sleep .75;
		_i = _i - .025;
		if (_i > 0) then {
			{
				_x setMarkerAlphaLocal _i;
			} forEach _markers;
		} else {
			{
				deleteMarkerLocal _x;
			} forEach _markers;
			true;
		};
	};
};