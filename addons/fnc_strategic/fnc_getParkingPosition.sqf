//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(getParkingPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getParkingPosition
Description:
Get a parking position for a passed vehicle class and building object

Parameters:
String - Vehicle class name
Object - Building object

Returns:
Array - array containing parking position and direction

Examples:
(begin example)
_result = ["B_Heli_Light_01_F", _building] call ALIVE_fnc_getParkingPosition;
(end)

See Also:

Author:
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_vehicleClass","_building","_debug","_result"];

_vehicleClass = _this select 0;
_building = _this select 1;
_debug = if(count _this > 2) then {_this select 2} else {false};

_result = [];

private ["_direction","_bbr","_bboxA","_p1","_p2","_maxWidth","_maxLength","_longest","_buildingPosition","_position","_safePos","_center","_vehicleMapSize"];

_position = position _building;
_direction = direction _building + (floor random 4)*90;

_bbr = boundingBoxReal _building;
_p1 = _bbr select 0;
_p2 = _bbr select 1;
_maxWidth = abs ((_p2 select 0) - (_p1 select 0));
_maxLength = abs ((_p2 select 1) - (_p1 select 1));

_longest = _maxWidth max _maxLength;

_position = _position getPos [(_longest+1), _direction];


// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	//["POS1: %1",_position] call ALIVE_fnc_dump;
	[_position] call ALIVE_fnc_spawnDebugMarker;
	[_position] call ALIVE_fnc_placeDebugMarker;
};
// DEBUG -------------------------------------------------------------------------------------

_vehicleMapSize = getNumber(configFile >> "CfgVehicles" >> _vehicleClass >> "mapSize");
_vehicleMapSize = (_vehicleMapSize/4);
if(_vehicleMapSize < 1) then {
    _vehicleMapSize = 1;
};

//["VEHICLE MAP SIZE - Class: %1 VMS: %2",_vehicleClass, _vehicleMapSize] call ALIVE_fnc_dump;

// pos min max nearest water gradient shore
_safePos = [_position,0,20,_vehicleMapSize,0,10,0,[],[_position]] call BIS_fnc_findSafePos;

//["SAFE POS: %1",_safePos] call ALIVE_fnc_dump;

_center = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");

//if(((_safePos select 0) == 10801.9) && ((_safePos select 1) == 10589.6)) then {
if(((_safePos select 0) == (_center select 0)) && ((_safePos select 1) == (_center select 1))) then {
    _position = [_position,0,20,_vehicleMapSize,0,20,0,[],[_position]] call BIS_fnc_findSafePos;
}else{
	_position = _safePos;
};

//["SAFE POS: %1",_position] call ALIVE_fnc_dump;


private ["_nearRoads","_road","_roadConnectedTo","_connectedRoad"];

_nearRoads = _position nearRoads 10;
if(count _nearRoads > 0) then
{
	_road = _nearRoads select 0;
	_roadConnectedTo = roadsConnectedTo _road;
	_connectedRoad = _roadConnectedTo select 0;
	if!(isNil '_connectedRoad') then {
		_direction = _road getRelDir _connectedRoad;
	};
};

_nearRoads = _position nearRoads 3;
if(count _nearRoads > 0) then
{
    _road = _nearRoads select 0;
    _roadConnectedTo = roadsConnectedTo _road;
    _connectedRoad = _roadConnectedTo select 0;
    if!(isNil '_connectedRoad') then {
        _direction = _road getRelDir _connectedRoad;
    };

    _position = position _road;

    _position = _position getPos [2, _direction-90];
};


// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	//["POS2: %1",_position] call ALIVE_fnc_dump;
	[_position, 1] call ALIVE_fnc_spawnDebugMarker;
	[_position, 1] call ALIVE_fnc_placeDebugMarker;
};
// DEBUG -------------------------------------------------------------------------------------


_result = [_position, _direction];

_result