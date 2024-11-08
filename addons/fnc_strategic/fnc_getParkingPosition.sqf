//#define DEBUG_MODE_FULL
#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(getParkingPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getParkingPosition
Description:
Get a parking position for a parsed vehicle class and building object

Parameters:
String - Vehicle class name
Object - Building object
Array - Blacklist object classes

Returns:
Array - array containing parking position and direction or [] if no parking position was found

Examples:
(begin example)
_result = ["B_Heli_Light_01_F", _building, ["Land_BarGate_F","Land_CncBarrier_F"]] call ALIVE_fnc_getParkingPosition;
(end)

See Also:

Author:
Arjay, Highhead, Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */


private ["_vehicleClass","_building","_debug","_direction","_bbr","_bboxA","_p1","_p2","_maxWidth","_maxLength","_longest","_buildingPosition","_position","_safePos","_center","_vehicleMapSize","_excludedObject","_nearbyObjects","_blacklist","_road_seg_list_raw","_road_seg_list_filtered","_road_seg_list","_P1","_P2","_x0","_x1","_x2","_y0","_y1","_y2","_distanceFromCenterLineOfRoad","_minDistanceFromCenterLineOfRoad","_maxDistanceFromCenterLineOfRoad","_connected_road","_current_road","_veh_type","_pos_flat_empty","_pos_flat_empty_attempts","_road_seg_width","_road_seg_length","_min_distance_nearby_objects","_tmp_pos","_car_length_allowed","_car_extra_space","_num_cars_in_road_segment","_distance_between_cars","_pos_middle_right","_pos_back_right","_last_pos","_pos_veh","_dir_slightly_randomized","_pos_veh_slightly_randomized","_nearbyObjectdistance"];

_vehicleClass = _this select 0;
_building = _this select 1;
_blacklist = _this select 2;
_debug = if(count _this > 3) then {_this select 3} else {false};


_nearbyObjectdistance = 15;
_minDistanceFromCenterLineOfRoad = 0.75;
_maxDistanceFromCenterLineOfRoad = 5;
_car_length_allowed = 5.25;
_car_extra_space = 0.75;

if !(!isnil "_vehicleClass" && {!isnil "_building"}) exitwith {
    ["getParkingPosition didn't receive fitting input: %1! Exiting...",_this] call ALiVE_fnc_dump;
};

_position = getpos _building;
_nearRoads = _position nearRoads 50;
_direction = ((direction _building)-90);

_road_seg_list_raw = _nearRoads;
_road_seg_list_filtered = _road_seg_list_raw select {
 _x isNotEqualTo [] && { !((getRoadInfo _x) select 2) && { !((getRoadInfo _x) select 8) }}
};
_road_seg_list = _road_seg_list_filtered select { 
	count (roadsConnectedTo _x) == 2 && { count (_x nearroads 15) < 2 && { ((nearestBuilding _x) distance2D _x) > 10 && { ((getRoadInfo _x) select 6) distance2D ((getRoadInfo _x) select 7) > 5 }}}
};
_road_seg_list = _road_seg_list call BIS_fnc_arrayShuffle;
_vehicleMapSize = getNumber(configFile >> "CfgVehicles" >> _vehicleClass >> "mapSize"); if (_vehicleMapSize < 5) then {_vehicleMapSize = 5};
_bbr = boundingBoxReal _building;
_p1 = _bbr select 0;
_p2 = _bbr select 1;
_maxWidth = abs ((_p2 select 0) - (_p1 select 0));
_maxLength = abs ((_p2 select 1) - (_p1 select 1));
_longest = _maxWidth max _maxLength;

if(_debug) then {
    [_position] call ALIVE_fnc_spawnDebugMarker;
    [_position] call ALIVE_fnc_placeDebugMarker;
};

_excludedObject = true;
_nearbyObjects = [];

for "_i" from 1 to 4 do {

  if (count _road_seg_list > 0) then {
 	
 	 if(_debug) then {
 		 ["count _road_seg_list: %1", count _road_seg_list] call ALiVE_fnc_dump;
 	 };
 	
   _road = _road_seg_list select 0;
   _roadConnectedTo = roadsConnectedTo _road;
   _connectedRoad = _roadConnectedTo select 0;
  
   if !(isNil "_connectedRoad") then {
 	  _direction = _road getDir _connectedRoad;
   } else {
 	  _direction = (getDir _road)-90;
   };
  
   _position = _road getpos [4.5,_direction-90];
   _P1 = (getRoadInfo _road) select 6;
   _P2 = (getRoadInfo _road) select 7;
   _x1 = _P1 select 0;
   _y1 = _P1 select 1;
   _x2 = _P2 select 0;
   _y2 = _P2 select 1;
   _x0 = (_position) select 0;
   _y0 = (_position) select 1;
   _distanceFromCenterLineOfRoad = abs((_y2 - _y1) * _x0 - (_x2 - _x1) * _y0 + (_x2 * _y1) - (_y2 * _x1)) / (_P1 distance2D _P2);
	 _nearbyObjects = (nearestObjects [_position, ["house","Wreck_Base","Ruins","Building","land_vn_cave_base","Car", "Truck", "Tank", "Plane", "Helicopter"], _nearbyObjectdistance]) + (nearestTerrainObjects [_position, ["BUILDING","BUNKER", "BUSH","BUSSTOP","CHAPEL","CHURCH","CROSS","FENCE","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","FOREST","FORTRESS","FOUNTAIN","FUELSTATION","HIDE","HOSPITAL","HOUSE","LIGHTHOUSE","POWER LINES","POWERSOLAR","POWERWAVE","POWERWIND","QUAY","RAILWAY","ROCK","ROCKS","RUIN","SHIPWRECK","SMALL TREE","STACK", "TOURISM", "TRANSMITTER", "TREE","VIEW-TOWER", "WALL", "WATERTOWER","Wreck_Base"],_vehicleMapSize + _nearbyObjectdistance]);
	 if (count _blacklist == 0) then {_blacklist = ["Land_BarGate_F"];};
	 { 
		 _excludedObject = (typeOf _x) in _blacklist;
		 if (_excludedObject) exitWith {
			 if(_debug) then {
				 ["Too close to a blacklist object, exiting _excludedObject: %1, %2", _excludedObject, _x] call ALiVE_fnc_dump;
			 };
			 [];
		 };
	 } forEach _nearbyObjects;
	 
	 if (count _nearbyObjects > 0 || _excludedObject) exitWith {
		 if(_debug) then {
			 ["Too close to an object, exiting. _excludedObject: %1, count _nearbyObjects: %2", _excludedObject, count _nearbyObjects] call ALiVE_fnc_dump;
		 };
		 [];
	 };
	
	 if (_distanceFromCenterLineOfRoad < _minDistanceFromCenterLineOfRoad) exitWith {
		 if(_debug) then {
			 ["Too close to the center line, exiting"] call ALiVE_fnc_dump;
		 };
		 [];
	 };
	
	 if (_distanceFromCenterLineOfRoad > _maxDistanceFromCenterLineOfRoad) exitWith {
		 if(_debug) then {
			 ["Too close to the center line, exiting"] call ALiVE_fnc_dump;    
		 };
		 [];
	 };
	 
	 _connected_road = _connectedRoad;
	 _current_road = _road;
	 _veh_type = _vehicleClass;
	 _direction = ([_current_road, _connected_road] call BIS_fnc_DirTo) + random [-7, 0, 7];
	 _pos_flat_empty = [];
	 _pos_flat_empty_attempts = 0;
	 _road_seg_width = ((getRoadInfo _current_road) select 1);
	 _road_seg_length = ((getRoadInfo _current_road) select 6) distance2D ((getRoadInfo _current_road) select 7);
	 _min_distance_nearby_objects = 1;
	 _tmp_pos = getPosASL _current_road;
	
	 while {
		 _pos_flat_empty isEqualTo [] && {_pos_flat_empty_attempts < 99 }
	 } do {
		 _pos_flat_empty_attempts = _pos_flat_empty_attempts + 1;
		
		 if (_tmp_pos findEmptyPosition [1.25, 2.5, _veh_type] isEqualTo []) then {
			 if(_debug) then {
				 ["findEmptyPosition failed"] call ALiVE_fnc_dump;
			 };
		 };
		
		 if (_tmp_pos isFlatEmpty [0.5, -1] isEqualTo []) then {
			 if(_debug) then {
			  	["isFlatEmpty failed"] call ALiVE_fnc_dump;
			 };
		 };
		
		 if (_tmp_pos findEmptyPosition [1.25, 2.5, _veh_type] isNotEqualTo []) then {
		  	_pos_flat_empty = _tmp_pos;
		 };
		
		 if (_pos_flat_empty isEqualTo []) then {
		  	_tmp_pos = [[[_tmp_pos, 3]],[]] call BIS_fnc_randomPos;
		 };
	 };
	
	 if (_pos_flat_empty isEqualTo []) then {
		 if(_debug) then {
		 	["Could not find a flat and empty spot after 99 attempts, giving up %1", _veh_type] call ALiVE_fnc_dump;
	 	};
	 } else {
		
		 if(_debug) then {
		 	["Found a good position for %1 after %2 attempts", _veh_type, _pos_flat_empty_attempts] call ALiVE_fnc_dump;
		 };
		
	  _num_cars_in_road_segment = (floor ((_road_seg_length * 0.75) / _car_length_allowed)) min 5;
	  _distance_between_cars = (_road_seg_length / _num_cars_in_road_segment) + _car_extra_space;
	
	  if (_num_cars_in_road_segment > 0) then {
		  _pos_middle_right = [(_pos_flat_empty # 0), (_pos_flat_empty # 1), (_pos_flat_empty # 2 - getTerrainHeightASL _pos_flat_empty)] getPos [_road_seg_width * 0.35, (_direction + 90)];
		  _pos_back_right = _pos_middle_right getPos [(_road_seg_length / 2), (_direction - 180)];
		  _last_pos = _pos_back_right;
		
		  for "_i" from 1 to _num_cars_in_road_segment do {
			  _pos_veh = _last_pos getPos [_distance_between_cars, _direction];
			  _dir_slightly_randomized = _direction + random [-7,0,7];
			  _distance_slightly_randomized = random [0, 0.05, 0.1];
			  _pos_veh_slightly_randomized = _pos_veh getPos [_distance_slightly_randomized, _dir_slightly_randomized];
			  _position = _pos_veh_slightly_randomized;
			  _direction = _dir_slightly_randomized;
			  _last_pos = _pos_veh;
		  };
		 
	  };
	 };
	 // set a little above ground to avoid bouncing
	 _position set [2,1];
	
	 if(_debug) then {
		 ["getParkingPosition result is _pos %1 | _dir %2", _position, _direction] call ALiVE_fnc_dump;
		 [_position, 1] call ALIVE_fnc_spawnDebugMarker;
		 [_position, 1] call ALIVE_fnc_placeDebugMarker;
	 };

  } else {
 	 if (count _position == 0) exitWith {
 		 ["_road_seg_list 0"] call ALiVE_fnc_dump;
 		 [];
 	 };
  };
};
	
if (_excludedObject) exitWith {
	if(_debug) then {
		["_excludedObject: %1, exiting", _excludedObject] call ALiVE_fnc_dump;
	};
	[];
};
	
 if(_debug) then {
 	["_vehicleClass: %1, _excludedObject: %2, _position: %3, _direction: %4, typeOf _building: %5, count _nearbyObjects: %6", _vehicleClass, _excludedObject, _position, _direction, typeOf _building, count _nearbyObjects] call ALiVE_fnc_dump;      
 };
 
[_position,_direction];