#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(findFilteredSafePos);

/*
Author: 
	Joris-Jan van 't Land, optimised by Killzone_Kid, extended by Kiskadee

Description:
	Function to generate position in the world according to several parameters.

Parameters:
	0: (Optional) ARRAY - center position
			Note: passing [] (empty Array), the world's "safePositionAnchor" entry will be used.
			
	1: (Optional) NUMBER - minimum distance from the center position
	2: (Optional) NUMBER - maximum distance from the center position
			Note: passing -1, the world's "safePositionRadius" entry will be used.
			
	3: (Optional) NUMBER - minimum distance from the nearest object
	4: (Optional) NUMBER - water mode
			0 - cannot be in water
			1 - can either be in water or not
			2 - must be in water
					
	5: (Optional) NUMBER - maximum terrain gradient (hill steepness)
	6: (Optional) NUMBER - shore mode:
			0 - does not have to be at a shore
			1 - must be at a shore
					
	7: (Optional) ARRAY - black listed areas in format [area1, area2, area3, ...areaN], where area is: 
			ARRAY - array in format [topLeftCorner, bottomRightCorner]
			or
			OBJECT - trigger area
			STRING - marker area
			LOCATION - location area
			ARRAY - array in format [center, distance] or [center, a, b, angle, rect] or [center, a, b, angle, rect, height]
					
	8: (Optional) ARRAY - array in format [landPosition, seaPosition], where:
			landPosition: ARRAY - in format [x,y] or [x,y,z] - default position on land
			seaPosition: ARRAY - in format [x,y] or [x,y,z] - default position on water
	
	9: (Optional) STRING - string that defines the type of the vehicle: car, truck, armored or tank

Returns:
	ARRAY - position solution
	
*/



#define MAX_TRIES 3000

scopeName "main";

params [
	["_checkPos",[]], 
	["_minDistance",0], 
	["_maxDistance",-1], 
	["_objectProximity",0],
	["_waterMode",0], 
	["_maxGradient",0], 
	["_shoreMode",0], 
	["_posBlacklist",[]],
	["_defaultPos",[]],
	["_vehicleType", ""]
];

private [
	"_fn_debugMessage",
	"_fn_vehicleTypeIsCar",
	"_fn_checkForStatic",
	"_fn_checkForOtherVehiclesNear",
	"_fn_checkIfIsBridge"
];

private _debugging = false;
//minimum message log level, used to filter the debugMessages: ["message", logLevel] call fn_debugMessage;
private _logLevel = 0; 

//debugMessage will only print when _debugging is on, will also filter the logs by level
_fn_debugMessage = {
	params [["_message", ""], ["_messageLevel", 0]];
	if !(_debugging) exitWith { false };
	if (_logLevel > _messageLevel) exitWith { false };
	if (isNil "_message") exitWith { false };
	systemChat _message;
	true
};

_fn_vehicleTypeIsCar = {
	_inCar = false;
	switch tolower(_vehicleType) do {
		case "car" : {_inCar = true};
		case "truck" : {_inCar = true};
		case "armored" : {_inCar = true};
		case "tank" : {_inCar = true};
	};
	_inCar
};

// false = the area is clear
_fn_checkForStatic = {
	params [
		["_position", [0,0,0]],
		["_avoidanceDistance", _objectProximity],
		["_staticIgnore", []]
	];

	_staticObjectsToCheck = [
			"BUILDING", 
			"BUNKER", 
			"BUSH", //<--- problematic, invisible bushes exist for some reason, should exclude from road check, no bushes in roads, right? 
			"BUSSTOP", 
			"CHAPEL", 
			"CHURCH", 
			"CROSS", 
			"FENCE", 
			"FOREST BORDER", 
			"FOREST SQUARE", 
			"FOREST TRIANGLE", 
			"FOREST", 
			"FORTRESS", 
			"FOUNTAIN", 
			"FUELSTATION", 
			"HIDE",
			"HOSPITAL", 
			"HOUSE", 
			"LIGHTHOUSE", 
			"POWER LINES", 
			"POWERSOLAR", 
			"POWERWAVE", 
			"POWERWIND", 
			"QUAY", 
			"RAILWAY", 
			"ROCK", 
			"ROCKS", 
			"RUIN", 
			"SHIPWRECK",
			"SMALL TREE",
			"STACK", 
			"TOURISM", 
			"TRANSMITTER", 
			"TREE",
			"VIEW-TOWER", 
			"WALL", 
			"WATERTOWER", 
			"Wreck_Base"
	];
	 if !(nearestTerrainObjects [_position, _staticObjectsToCheck - _staticIgnore, _avoidanceDistance, false, true] isEqualTo []) exitWith {["[CFS] Too close from a static object", 0] call _fn_debugMessage; true};

	if(_debugging) then {
		if !(_position nearObjects ["house", _avoidanceDistance] isEqualTo []) exitWith {["[CFS] Too close from a house", 0] call _fn_debugMessage; true};
		if !(_position nearObjects ["Ruins", _avoidanceDistance] isEqualTo []) exitWith {["[CFS] Too close from a ruin", 0] call _fn_debugMessage; true};
		if !(_position nearObjects ["Wreck_Base", _avoidanceDistance] isEqualTo []) exitWith {["[CFS] Too close from a wreck", 0] call _fn_debugMessage; true};
	} else {
		if !(nearestObjects [_position, ["house", "Ruins", "Wreck_Base"], _avoidanceDistance] isEqualTo []) exitWith {true};
	};
	false
};

//false = the area is clear
_fn_checkForOtherVehiclesNear = {
	params [["_position", []], ["_distance", 0]];

	if (_debugging) then {
		if !(_position nearObjects ["Car", _distance] isEqualTo []) exitWith {["[CFOVN] Too close from another car", 0] call _fn_debugMessage; true};
		if !(_position nearObjects ["Truck", _distance] isEqualTo []) exitWith {["[CFOVN] Too close from another Truck", 0] call _fn_debugMessage; true};
		if !(_position nearObjects ["Tank", _distance] isEqualTo []) exitWith {["[CFOVN] Too close from another Tank", 0] call _fn_debugMessage; true};
		if !(_position nearObjects ["Plane", _distance] isEqualTo []) exitWith {["[CFOVN] Too close from another Plane", 0] call _fn_debugMessage; true};
		if !(_position nearObjects ["Helicopter", _distance] isEqualTo []) exitWith {["[CFOVN] Too close from another Helicopter", 0] call _fn_debugMessage; true};
		false
	} else {
		if !(nearestObjects [_position, ["Car", "Truck", "Tank", "Plane", "Helicopter"], _distance] isEqualTo []) exitWith {true};
	};
};

//false = it's not a bridge
_fn_checkIfIsBridge = {
	params [["_position", []]];

	_road = roadAt _position;
	if (isNil "_road") exitWith { false };
	_info = getRoadInfo _road;
	if (_info select 8) exitWith {["[BRIDGE] This segment is a bridge", 1] call _fn_debugMessage; true}; //isBridge
	false
};

// support object for center pos as well
if (_checkPos isEqualType objNull) then {_checkPos = getPos _checkPos};

private _defaultMaxDistance = worldSize / 2;
private _defaultCenterPos = [_defaultMaxDistance, _defaultMaxDistance, 0];

private _fnc_defaultPos = 
{
	_defaultPos = _defaultPos param [parseNumber _this, []];
	if !(_defaultPos isEqualTo []) exitWith {_defaultPos};
	
	_defaultPos = getArray (configFile >> "CfgWorlds" >> worldName >> "Armory" >> ["positionStart", "positionStartWater"] select _this);
	if !(_defaultPos isEqualTo []) exitWith {_defaultPos};
		
	_defaultPos = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");
	if !(_defaultPos isEqualTo []) exitWith {_defaultPos};
		
	_defaultCenterPos
};

//Do not handle vehicles that aren't supposed to spawn on roads, like static weapons and planes!
if !(call _fn_vehicleTypeIsCar) exitWith {["[Vehicle type] Do not handle non cars", 2] call _fn_debugMessage; _checkPos};


if (_checkPos isEqualTo []) then
{
	_checkPos = getArray (configFile >> "CfgWorlds" >> worldName >> "safePositionAnchor");
	if (_checkPos isEqualTo []) then {_checkPos = _defaultCenterPos};
};

if (_maxDistance < 0) then 
{
	_maxDistance = getNumber (configFile >> "CfgWorlds" >> worldName >> "safePositionRadius");
	if (_maxDistance <= 0) then {_maxDistance = _defaultMaxDistance};
};

private _checkProximity = _objectProximity > 0;
private _checkBlacklist = !(_posBlacklist isEqualTo []);

_shoreMode = _shoreMode != 0;

if (_checkBlacklist) then
{
	_posBlacklist = _posBlacklist apply 
	{
		// top-left, bottom-right coordinates 
		if (_x isEqualTypeParams [[],[]]) then 
		{
			_x select 0 params [["_x0", 0], ["_y0", 0]];
			_x select 1 params [["_x1", 0], ["_y1", 0]];
			private _a = (_x1 - _x0) / 2;
			private _b = (_y0 - _y1) / 2;
			[[_x0 + _a, _y0 - _b], abs _a, abs _b, 0, true]
		}
		else
		{
			// other area compatible formats
			_x call BIS_fnc_getArea
		};
	};
};

private _off = (_minDistance / _maxDistance) ^ 2;
private _rem = 1 - _off;
private _gradientRadius = 1 max _objectProximity * 0.1;



private _spawnPosition = [_position] call ALIVE_fnc_getClosestRoad;

/*
30 is the number of segments returned from the function, can reduce this number,
but it also represents the number of vehicles that can be stacked like a convoy
when they attempt to spawn at the exact same position
*/

private _sortedPositionSeries = [_spawnPosition, _maxDistance, 30] call ALIVE_fnc_getSortedSeriesRoadPositions;

private _positionsPossible = count _sortedPositionSeries;
private _found = false;

//if there are one or more canditates for spawn
if (_positionsPossible > 0) then {
	for "_i" from 0 to _positionsPossible-1 do
	{
		//When the perfect road candidate is found, break out of this loop and return _spawnPosition 
		if (_found) exitWith {_spawnPosition};
		_spawnPosition = _sortedPositionSeries select _i;
		if ([_spawnPosition, _objectProximity] call _fn_checkForOtherVehiclesNear) then {["[Road finder] There's another vehicle in this road", 0] call _fn_debugMessage; continue;};
		if ([_spawnPosition, 2, ["BUSH", "HIDE"]] call _fn_checkForStatic) then {["[Road finder] There's a small obstacle in this road", 0] call _fn_debugMessage; continue;};
		if ([_spawnPosition] call _fn_checkIfIsBridge) then {["[Road finder] Spawn on bridge not implemented, skip "+str(_spawnPosition), 1] call _fn_debugMessage; continue;};
		_found = true;
	};
	if (_found) exitWith {_spawnPosition};
};
if (_found) exitWith {_spawnPosition};

//Tried every road near and they either doesn't exist or are too busy
["[Road finder] Exhausted tries! going for heuristic search", 2] call _fn_debugMessage;


for "_i" from 1 to MAX_TRIES do
{
	_checkPos getPos [_maxDistance * sqrt (_off + random _rem), random 360] call
	{
		// position is roughly suitable
		if (_this isFlatEmpty [-1, -1, _maxGradient, _gradientRadius, _waterMode, _shoreMode] isEqualTo []) then {continue;};
		
		// Vehicle is dangerously close to static things
		/*
		Note: Building distance is measured from the center, due to this, the below function isn't perfect
		for avoiding gigantic or colossal structures.

		Increasing the avoidance distance a lot will result in being unable to spawn inside cities

		Another possible way to handle the gigantic structures is calculating intersections with the nearest buildings using
		the bounding box, should be quick and may be worth a try
		*/
		if ([_this, _objectProximity + 5, ["HIDE"]] call _fn_checkForStatic) then {continue};
				
		// not inside something
		if !(lineIntersectsSurfaces [AGLtoASL _this, AGLtoASL _this vectorAdd [0, 0, 50], objNull, objNull, false, 1, "GEOM", "NONE"] isEqualTo []) then {continue;};
		
		// not in blacklist
		if (_checkBlacklist && {{if (_this inArea _x) exitWith {true}; false} forEach _posBlacklist}) then {continue};
		

		// Vehicle is dangerously close to another vehicle
		if ([_this, _objectProximity] call _fn_checkForOtherVehiclesNear) then {continue};

		_this select [0, 2] breakOut "main";
	};
};


// Search failed, will spawn in the default position from the profile, not checking anything and will probably explode
["[Heuristic] Heuristic search failed, area isn't safe, default pos", 2] call _fn_debugMessage;

(_waterMode != 0) call _fnc_defaultPos 