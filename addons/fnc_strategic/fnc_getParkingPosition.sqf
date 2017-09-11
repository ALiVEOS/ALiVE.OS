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
Array - array containing parking position and direction or [] if no parking position was found

Examples:
(begin example)
_result = ["B_Heli_Light_01_F", _building] call ALIVE_fnc_getParkingPosition;
(end)

See Also:

Author:
Arjay, Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */


private ["_vehicleClass","_building","_debug","_isEmpty","_isFlatEmpty","_direction","_bbr","_bboxA","_p1","_p2","_maxWidth","_maxLength","_longest","_buildingPosition","_position","_safePos","_center","_vehicleMapSize"];

_vehicleClass = _this select 0;
_building = _this select 1;
_debug = if(count _this > 2) then {_this select 2} else {false};

if !(!isnil "_vehicleClass" && {!isnil "_building"}) exitwith {
    ["ALiVE getParkingPosition didn't receive fitting input: %1! Exiting...",_this] call ALiVE_fnc_DumpR;
};

_position = getpos _building;
_nearRoads = _position nearRoads 50;
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

private _isEmpty = false;

for "_i" from 1 to 4 do {
    
	if(count _nearRoads > 0) then {
	    _road = _nearRoads select 0;
        _isEmpty = false;
        _isFlatEmpty = false;
        
	    _roadConnectedTo = roadsConnectedTo _road;
	    _connectedRoad = _roadConnectedTo select 0;
        
	    if!(isNil "_connectedRoad") then {
	        _direction = _road getDir _connectedRoad;
	    } else {
            _direction = (getDir _road)-90;
        };
        
        _position = _road getpos [1.5,_direction-90];
        
	} else {
        _direction = ((direction _building)-90) + ((floor _i)*90);
        _position = (getpos _building) getpos [_longest + 5, _direction];

        _position = _position findEmptyPosition [_longest, 50, _vehicleClass];
         
        _direction = _direction - 90;
    };

    if (count _position >= 2) then {
        private _list = (nearestObjects [_position, ["House","Wall"], 15]) + (nearestTerrainObjects [_position, ["TREE","SMALL TREE","ROCK","ROCKS","FENCE", "WALL","HIDE"],_vehicleMapSize + 1]);    
        _list = [_list,[_position],{_Input0 distance _x},"ASCENDING"] call ALiVE_fnc_SortBy;
        _list = if (count _list > 0) then {[_list select 0]} else {[]};
        
        _isEmpty = {_position_1 = getpos _x; _position_2 = +_position; _position_1 set [2,1]; _position_2 set [2,1]; lineIntersects [_position_1, _position_2]} count _list == 0;     
    };

    if (_isEmpty) exitwith {
        if(_debug) then {
            ["ALiVE getParkingPosition found empty parking position at %1 in direction %2",_position,_direction] call ALiVE_fnc_DumpR;
        };
    };
};

if (!_isEmpty || {isNil "_position"} || {count _position < 2}) exitwith {
        if(_debug) then {
            ["ALiVE getParkingPosition didn't find any suiting parking position!",_position,_direction] call ALiVE_fnc_DumpR;
        };

    [];
};

if (!_isEmpty) then {
    _position = (_building getpos [_longest + 2, getdir _building]) findEmptyPosition [5,50,_vehicleClass];
    
    if (count _position == 0) then {
        _position = [getpos _building,_longest + 5,100,15,0,0.5,0,[],[_building getpos [_longest + 2, getdir _building]]] call BIS_fnc_findSafePos;
    };

    if(_debug) then {
        ["ALiVE getParkingPosition Failed! Assigned failsafe pos at %1 in direction %2",_position,_direction] call ALiVE_fnc_DumpR;
        
	    [_position, 2] call ALIVE_fnc_spawnDebugMarker;
	    [_position, 2] call ALIVE_fnc_placeDebugMarker;
	};    
};

//set a little above ground to avoid bouncing
_position set [2,1];

if(_debug) then {
    ["ALiVE getParkingPosition result is _pos %1 | _dir %2",_position,_direction] call ALiVE_fnc_DumpR;
    
    [_position, 1] call ALIVE_fnc_spawnDebugMarker;
    [_position, 1] call ALIVE_fnc_placeDebugMarker;
    
    
};

[_position,_direction];