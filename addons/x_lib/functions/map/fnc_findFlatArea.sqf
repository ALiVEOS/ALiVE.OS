#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findFlatArea);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findFlatArea
Description: Finds an empty flat area within given radius

Parameters:
0: position to search from
1: radius to search
2: flat size
3: gradient (allowed height difference of flatarea in mtrs)

Returns:
guess what

Examples:
(begin example)
//finds an empty flat area within 200mtrs from the player
_flatpos = [getpos player, 200] call ALIVE_fnc_findFlatArea;
(end)

See Also:
- nil

Author:
BON INF

Peer reviewed:
HighHead
---------------------------------------------------------------------------- */
private ["_position","_radius","_pos","_maxgradient","_gradientarea","_debug"];
_position = _this select 0;
if(count _this > 1) then {_radius = _this select 1;} else {_radius = 2;};
if(count _this > 2) then {_gradientarea = _this select 2} else {_gradientarea = 5};   // in metres
if(count _this > 3) then {_maxgradient = _this select 3} else {_maxgradient = 0.1};   // in [0,1]

_debug = false;
_pos = [];

for "_i" from 1 to 3000 do {
        _pos = [(_position select 0) + _radius - random (2*_radius),(_position select 1) + _radius - random (2*_radius),0];
        _pos = 	_pos isflatempty [
                10,				//--- Minimal distance from another object
                1,				//--- If 0, just check position. If >0, select new one
                _maxgradient,			//--- Max gradient
                _gradientarea,			//--- Gradient area
                0,				//--- 0 for restricted water, 2 for required water,
                false,				//--- True if some water can be in 25m radius
                ObjNull				//--- Ignored object
        ];
        if (count _pos > 0) then {
                _pos set [2,0];
                if (count (_pos nearRoads 20) != 0) then {
                        _pos = [];
                };
        };
        if (count _pos > 0) exitWith {
                if (_debug) then {diag_log format["ALiVE-%1 Attempts to find flat area: %3 - found pos: %2", time, _pos, _i];};
                _pos;
        };
};

if(count _pos == 0) then {
        _pos = _position;
        if (_debug) then {diag_log format["ALiVE-%1 RMM GETFLATAREA defaulting to original pos after 3000 trys: %2", time, _pos];};
};
_pos;
