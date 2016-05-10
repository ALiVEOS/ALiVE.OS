#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(isEnemyNear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isEnemyNear

Description:
Returns if there are any nearby enemy

Parameters:
Array - position
String - side text
Scalar - radius

Returns:

Examples:
(begin example)
// are there any enemies of WEST side within 1000 meters (including virtual?
_result = [_position, "WEST", 1000,true] call ALIVE_fnc_isEnemyNear;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_side","_radius","_found","_enemySides","_entities","_entitySide","_withProfiles"];

_position = _this select 0;
_side = _this select 1;
_radius = if(count _this > 2) then {_this select 2} else {500};
_withProfiles = if(count _this > 3) then {_this select 3} else {false};

_side = [_side] call ALIVE_fnc_sideTextToObject;
_found = false;
_enemySides = [];

if(_side getFriend east < 0.6) then {
    _enemySides pushback east;
};

if(_side getFriend west < 0.6) then {
    _enemySides pushback west;
};

if(_side getFriend resistance < 0.6) then {
    _enemySides pushback resistance;
};

if(_side getFriend civilian < 0.6) then {
    _enemySides pushback civilian;
};

_entities = _position nearEntities ["CAManBase", _radius];

if(count _entities > 0) then {
    {
        _entitySide = side _x;
        if(_entitySide in _enemySides) exitWith {
            _found = true;
        };
    } forEach _entities;
};

if (!_found && {_withProfiles}) then {
        {
            _side = [_x] call ALIVE_fnc_sideObjectToNumber;
            _side = [_side] call ALIVE_fnc_sideNumberToText;
    
    		if (count ([_position, _radius, [_side,"entity"]] call ALIVE_fnc_getNearProfiles) > 0) exitwith {_found = true};
        } foreach _enemySides;
        
        _found
    } else {
        _found
};