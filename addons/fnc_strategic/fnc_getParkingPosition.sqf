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


// Run in one go. Called from a scheduled script, each check waited its turn behind every other running
// script: on a busy server parking a town's cars took minutes for well under a millisecond of work a call.
if (canSuspend) exitWith {
    private _result = [];
    isNil { _result = _this call ALIVE_fnc_getParkingPosition };
    if (isNil "_result") then { _result = [] };
    _result
};


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
    [_position, 0, format ["Parking - search start (%1)", _vehicleClass], "ColorGrey", "placement.parking"] call ALIVE_fnc_placeDebugMarker;
};

_excludedObject = true;
_nearbyObjects = [];

// Up to three roads near the building, in shuffled order, stopping at the first with a spot that passes
// every check below. (Four passes over the same first road used to repeat its answer at four times the cost.)
for "_i" from 0 to (((count _road_seg_list) min 3) - 1) max 0 do {
  if !(_excludedObject) exitWith {};

  if (count _road_seg_list > 0) then {
 	
 	 if(_debug) then {
 		 ["count _road_seg_list: %1", count _road_seg_list] call ALiVE_fnc_dump;
 	 };
 	
   _road = _road_seg_list select _i;
   _roadConnectedTo = roadsConnectedTo _road;
   _connectedRoad = if (count _roadConnectedTo > 0) then {_roadConnectedTo select 0} else {objNull};
  
   if !(isNull _connectedRoad) then {
 	  _direction = _road getDir _connectedRoad;
   } else {
 	  _direction = (getDir _road)-90;
   };
  
   // Just off the edge of the road: half its width, plus half a car. A flat 4.5 m from the centre put
   // most cars on the road itself; the roadside slots worked out further down were never reached, and
   // put cars over twice the road's width out.
   _road_seg_width = (getRoadInfo _road) select 1;
   private _side = ((_road_seg_width / 2) + 1.3) max 3.5 min 7;
   _position = _road getpos [_side, _direction - 90];
	 // Only a blacklisted object near the spot rules this road out, so only those are searched for (the
	 // search radius grows with the vehicle's mapSize, for long trucks). That anything at all was near used
	 // to stop the search before any check below ran, so cars went down unchecked.
	 if (count _blacklist == 0) then {_blacklist = ["Land_BarGate_F"];};
	 _nearbyObjects = nearestObjects [_position, _blacklist, _vehicleMapSize + _nearbyObjectdistance];
	 private _blacklisted = _nearbyObjects findIf {(typeOf _x) in _blacklist};
	 if (_blacklisted >= 0) exitWith {
		 if(_debug) then {
			 ["Too close to a blacklist object, exiting: %1", _nearbyObjects select _blacklisted] call ALiVE_fnc_dump;
		 };
	 };

	 // The vehicle's size from the size cache when it has the class, else from its mapSize, so no test
	 // vehicle is spawned here.
	 private _vehBox = (missionNamespace getVariable ["ALiVE_vehicleBBoxCache", createHashMap]) getOrDefault [toLower _vehicleClass, [_vehicleMapSize, 2, 3]];
	 private _reach = ((_vehBox param [0, 4]) / 2) + 0.5;
	 private _vehHeight = (_vehBox param [2, 2.5]) max 1.5;
	 // Blocked: a map wall, fence, bush, tree, rock or building within half the vehicle's length (+0.5 m),
	 // or a roof over the spot (sheds, fuel-station canopies, awnings; a vehicle put down inside one
	 // explodes). The engine's room check below passes over these map objects.
	 private _fnc_blocked = {
		 params ["_p"];
		 (count (nearestTerrainObjects [[_p#0, _p#1], ["TREE","SMALL TREE","BUSH","WALL","FENCE","HIDE","ROCK","ROCKS","RUIN","BUILDING","HOUSE"], _reach, false, true]) > 0)
		 || {count (lineIntersectsObjs [AGLToASL [_p#0, _p#1, 0.5], AGLToASL [_p#0, _p#1, _vehHeight + 0.5], objNull, objNull, true, 1, "GEOM"]) > 0}
	 };
	 // the cheap checks first; the room check costs thirty times as much
	 if ([_position] call _fnc_blocked) exitWith {
		 if(_debug) then {
			 ["Spot blocked by a map object or a roof, exiting"] call ALiVE_fnc_dump;
		 };
	 };
	 // Room for this vehicle within 1.5 m, so it stays at the roadside: the engine's own check, so a car is
	 // not put down inside another vehicle or a placed object. If it moved the spot, the new one is checked again.
	 // With no vehicle or object of any kind within 5 m of the car the spot is clear as it is, and the check
	 // (thirty times the cost of the others) is skipped.
	 private _clear = if ((nearestObjects [[_position#0, _position#1], ["AllVehicles","Static","Building","Thing"], _reach + 5]) isEqualTo []) then {
		 [_position#0, _position#1, 0]
	 } else {
		 [_position#0, _position#1, 0] findEmptyPosition [0, 1.5, _vehicleClass]
	 };
	 if (_clear isEqualTo [] || {(_clear distance2D _position) > 0.2 && {[_clear] call _fnc_blocked}}) exitWith {
		 if(_debug) then {
			 ["No room for %1 beside the road, exiting", _vehicleClass] call ALiVE_fnc_dump;
		 };
	 };
	 _position = _clear;

	 // parked along the road, a little off straight; only a spot that passed every check is used
	 _direction = _direction + random [-7, 0, 7];
	 _excludedObject = false;
	 // set a little above ground to avoid bouncing
	 _position set [2,1];

	 if(_debug) then {
		 ["getParkingPosition result is _pos %1 | _dir %2", _position, _direction] call ALiVE_fnc_dump;
		 [_position, 1] call ALIVE_fnc_spawnDebugMarker;
		 [_position, 1, format ["Parking - picked (%1)", _vehicleClass], "ColorGrey", "placement.parking"] call ALIVE_fnc_placeDebugMarker;
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
