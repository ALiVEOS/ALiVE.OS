#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(agentSelectSpeedMode);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_agentSelectSpeedMode

Description:
Set a randomish speed mode on an agent

Parameters:

Object - agent to adjust speed mode of

Returns:

Examples:
(begin example)
_light = [_agent] call ALIVE_fnc_agentSelectSpeedMode
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_agent","_probabilityNormal","_probabilityFull","_posture","_diceRoll"];

_agent = _this select 0;

_probabilityNormal = 0.1;
_probabilityFull = 0.05;

_posture = _agent getVariable ["posture", 0];

if(_posture < 10) then {_probabilityNormal = 0.1; _probabilityFull = 0.05};
if(_posture >= 10 && {_posture < 40}) then {_probabilityNormal = 0.2; _probabilityFull = 0.1};
if(_posture >= 40 && {_posture < 70}) then {_probabilityNormal = 0.3; _probabilityFull = 0.1};
if(_posture >= 70 && {_posture < 100}) then {_probabilityNormal = 0.4; _probabilityFull = 0.2};
if(_posture >= 100) then {_probabilityNormal = 0.4; _probabilityFull = 0.2};

/*
switch(_posture) do {
    case 4: {
        _probabilityNormal = 0.4;
        _probabilityFull = 0.2;
    };
    case 3: {
        _probabilityNormal = 0.3;
        _probabilityFull = 0.1;
    };
    case 2: {
        _probabilityNormal = 0.2;
        _probabilityFull = 0.1;
    };
    case 1: {
        _probabilityNormal = 0.1;
        _probabilityFull = 0.05;
    };
};
*/

_diceRoll = random 1;

_agent setSpeedMode "LIMITED";

if(_diceRoll < _probabilityNormal) then {
    _agent setSpeedMode "NORMAL";
};

if(_diceRoll < _probabilityFull) then {
    _agent setSpeedMode "FULL";
};

