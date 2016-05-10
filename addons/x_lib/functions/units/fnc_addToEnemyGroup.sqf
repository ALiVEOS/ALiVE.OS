#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(addToEnemyGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addToEnemyGroup

Description:
Assigns a unit to an enemy group of a target

Parameters:
Object - unit
Object - target

Returns:

Examples:
(begin example)
//
_result = [_unit, _target] call ALIVE_fnc_addToEnemyGroup;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_unit","_target","_unitSide","_targetSide","_group","_currentGroup"];

_unit = _this select 0;
_target = _this select 1;

_unitSide = side _unit;
_targetSide = side _target;

if!((_unitSide) getFriend (_targetSide) < 0.6) then {
    switch (_targetSide) do {
        case west:{
            _group = createGroup east;
        };
        case east:{
            _group = createGroup west;
        };
        case resistance:{
            if((west getFriend resistance) < 0.6) then {
                _group = createGroup west;
            }else{
                _group = createGroup east;
            };
        };
        case civilian:{
            if((west getFriend civilian) < 0.6) then {
                _group = createGroup west;
            }else{
                _group = createGroup east;
            };
        };
    };

    _currentGroup = group _unit;
    [_unit] joinSilent _group;
    _currentGroup call ALiVE_fnc_DeleteGroupRemote;
};