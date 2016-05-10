//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(generateParkingPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_generateParkingPosition
Description:
Set cluster values on array of clusters

Parameters:
String - Vehicle class
Array - Position
Scalar - Direction
Scalar - Min distance
Scalar - Max distance
Bool - On water

Returns:
Array - array containing good parking position and direction

Examples:
(begin example)
_result = ["B_Heli_Light_01_F", getPos player, 0] call ALIVE_fnc_generateParkingPosition;
(end)

See Also:

Author:
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_createVehicle","_vehicleClass","_position","_direction","_minDistance","_maxDistance","_onWater","_parkingPosition",
"_positionFound","_attempt","_badParkingPosition","_testPosition","_vehicle","_time","_endTime","_isBad","_damage","_vehiclePos",
"_road","_nearRoads","_roadConnectedTo","_connectedRoad","_vehiclePosIsWater"];

_vehicleClass = _this select 0;
_position = _this select 1;	
_direction = _this select 2;
_minDistance = if(count _this > 3) then {_this select 3} else {5};
_maxDistance = if(count _this > 4) then {_this select 4} else {100};
_onWater = if(count _this > 5) then {_this select 5} else {false};

_createVehicle = 
{	
	private ["_vehicleClass", "_vehicle", "_vehicleName", "_position", "_direction"];
	
	_vehicleClass = _this select 0;
	_vehicleName = _this select 1;
	_position = _this select 2;
	_direction = _this select 3;	
	_vehicle = createVehicle [_vehicleClass, _position, [], 0, "NONE"];
	_vehicle setPos _position;
	_vehicle setDir _direction;
	_vehicle setVehicleVarName _vehicleName;
	
	_vehicle
};

_parkingPosition = [];
_positionFound = false;
_attempt = 0;
_badParkingPosition = "";
				
// no valid position
while{!(_positionFound)} do
{
	_parkingPosition = [];
	
	// re attempt to find
	if(_attempt > 0) then
	{
		while{count _parkingPosition < 1} do
		{
			_minDistance = _minDistance + 1;
			_maxDistance = _maxDistance + 5;
			_testPosition = _position findEmptyPosition[_minDistance, _maxDistance, _vehicleClass];
			
			// position is different to last position and position is valid
			if(!(str _testPosition == _badParkingPosition) && count _testPosition > 1) then
			{
				_parkingPosition = _testPosition;
			};							
		};
	}
	else
	{
		while{ count _parkingPosition < 1 } do
		{
			_parkingPosition = _position findEmptyPosition[_minDistance, _maxDistance, _vehicleClass];
			_maxDistance = _maxDistance + 30;
		};
	};
	
	_vehicle = _vehicleClass createVehicle _parkingPosition;
	_vehicle setPos _parkingPosition;
	
	// get nearby road direction, align to that if found
	_nearRoads = _parkingPosition nearRoads 10;
	if(count _nearRoads > 0) then
	{
		_road = _nearRoads select 0;
		_roadConnectedTo = roadsConnectedTo _road;
		_connectedRoad = _roadConnectedTo select 0;
		if!(isNil '_connectedRoad') then {
			_direction = _road getRelDir _connectedRoad;
		};
	};
	
	_vehicle setDir _direction;
	
	_time = time;
	_endTime = _time+2;
	_isBad = false;
	
	// spawn the vehicle at the position and wait for 5 seconds, if vehicle takes damage, mark position bad
	while {_time < _endTime} do
	{
		_time = time;
		_damage = getDammage _vehicle;
		
		if(_damage > 0) then
		{
			deleteVehicle _vehicle;
			_isBad = true;
			_badParkingPosition = str _parkingPosition;
		};
	};
	
	// if on water position is required and if position is not water mark position bad
	if(_onWater) then
	{
		_vehiclePos = getPos _vehicle;
		_vehiclePosIsWater = surfaceIsWater [_vehiclePos select 0, _vehiclePos select 1];
		if!(_vehiclePosIsWater) then
		{
			deleteVehicle _vehicle;
			_isBad = true;
			_badParkingPosition = str _parkingPosition;
		}
	};

	if!(_isBad) then
	{
		_positionFound = true;
	}
	else
	{
		_attempt = _attempt + 1;
	}				
};

ALIVE_parkingVehicles set [count ALIVE_parkingVehicles, _vehicle];

[_parkingPosition, _direction]