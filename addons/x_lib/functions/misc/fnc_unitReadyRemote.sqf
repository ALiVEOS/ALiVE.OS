#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(unitReadyRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_unitReadyRemote

Description:
Checks if a unit is ready after a move or domove command

Parameters:
Object - Given unit
Array - position

Returns:
Nothing

Examples:
_ready = _unit/_group call ALiVE_fnc_unitReadyRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_input","_unitReady","_radius","_lastCheck"];

_input = _this;

_currentPos = getposATL _input;
_destination = _input getvariable [QGVAR(MOVEDESTINATION),_currentPos];
_lastCheck = _input getVariable QGVAR(LASTCHECK);
_unitReady = if (local _input) then {unitReady _input};
_moving = true;

if (isnil "_lastCheck") then {
    _lastCheck = [_currentPos,time]; _input setVariable [QGVAR(LASTCHECK),_lastCheck];
} else {
    //Reset last data
	if (time - (_lastCheck select 1) > 30) then {
	    
	    if ((_lastCheck select 0) distance _currentPos < 2) then {_moving = false};
	    
	    _input setVariable [QGVAR(LASTCHECK),[_currentPos,time]];
	};
};

_radius = 10;
if (_input isKindOf "Man") then {_radius = 2} else {
    if (_input isKindOf "LandVehicle") then {_radius = 20} else {
        if (_input isKindOf "Air") then {_radius = 100};
    };
};

if ((!isnil "_unitReady" && {!_unitReady}) || {isnil "_unitReady" && {_currentPos distance2D _destination > _radius} && {_moving}}) then {
	_unitReady = false;
} else {
    _input setvariable [QGVAR(MOVEDESTINATION),nil];
    _input setVariable [QGVAR(LASTCHECK),nil];
    
    _unitReady = true;
};

//["_currentPos %1 _destination %2 _radius %3 _unitReady %4",_currentPos,_destination,_radius,_unitReady] call ALiVE_fnc_DumpR;

_unitReady;