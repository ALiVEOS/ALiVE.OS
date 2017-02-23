#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findNearestShore);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findNearestShore
Description:
Finds nearest shore on given path

Parameters:
Array - position
Array - destination

Returns:
Array - shore-position, [0,0,0] if no shore was found

Examples:
(begin example)
_shorePos = [
        getpos player,
        player getpos [2000,0],
        1000
] call ALIVE_fnc_findNearestShore;
(end)

See Also:


Author:
Highhead
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_position","_destination","_dummyPosSource","_dummyPosDestination"];

params [
    ["_position", [0,0,0], [[]]],
    ["_destination", [0,0,0], [[]]]
];

private _onWater = [];
private _distanceToCheck = 250;
private _radius = 1500;

if !(_destination isEqualTo [0,0,0]) then {

	if (surfaceIsWater _destination) then {
	    _dummyPosSource = _position;
	    _dummyPosDestination = _destination;
	} else {
	    _dummyPosSource = _destination;
	    _dummyPosDestination = _position;
	};
	
	private _dirTo = [_dummyPosSource,_dummyPosDestination] call BIS_fnc_dirTo;            
	
	while {
	    private _checkPos = _dummyPosSource getpos [_distanceToCheck,_dirTo];
	    
	    if (surfaceIsWater _checkPos) then {_onWater pushBack _checkPos} else {_onWater = []};
	    
	    count _onWater < 2 && {_distanceToCheck < 10000} 
	} do {
	    _distanceToCheck = _distanceToCheck + 250;
	};
    
} else {
	_dummyPosSource = _position;
};

private _searchPosition = if (count _onWater >= 2) then {_radius = 250; _onwater select 0} else {_dummyPosSource};
private _shore = [_searchPosition,0,_radius,3,0,0.5,1,[],[[0,0,0]]] call BIS_fnc_findSafePos;

_shore;