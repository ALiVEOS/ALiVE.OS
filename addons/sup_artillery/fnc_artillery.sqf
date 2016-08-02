#include <\x\alive\addons\sup_artillery\script_component.hpp>
SCRIPT(Artillery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_artillery
Description:
Artillery module.

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled
Boolean - enabled - Enabled or disable module

Parameters:
none

Examples:

See Also:

Author:
marceldev89
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_artillery

private _logic = param [0, objNull, [objNull, []]];
private _operation = param [1, "", [""]];
private _args = param [2, objNull, [objNull, [], "", 0, true, false]];

private _result = true;

switch (_operation) do {
    case "init": {
        [] call ALIVE_fnc_artillery_init;
    };

    /****************
     ** PROPERTIES **
     ****************/
    case "fireMission": {
        if (isNull _args) then {
            _result = [_logic, "fireMission"] call ALIVE_fnc_hashGet;
        } else {
            private _position = _args param [0, [0,0,0], [[]], 3];
            private _roundType = _args param [1, "", [""]];
            private _roundCount = _args param [2, 1, [1]];
            private _delay = _args param [3, 5, [1]];
            private _dispersion = _args param [4, 50, [1]];

            private _fireMission = [] call ALIVE_fnc_hashCreate;
            [_fireMission, "position", _position] call ALIVE_fnc_hashSet;
            [_fireMission, "roundType", _roundType] call ALIVE_fnc_hashSet;
            [_fireMission, "roundCount", _roundCount] call ALIVE_fnc_hashSet;
            [_fireMission, "delay", _delay] call ALIVE_fnc_hashSet;
            [_fireMission, "dispersion", _dispersion] call ALIVE_fnc_hashSet;
            // Defaults
            [_fireMission, "units", []] call ALIVE_fnc_hashSet;
            [_fireMission, "unitIndex", -1] call ALIVE_fnc_hashSet;
            [_fireMission, "roundsShot", -1] call ALIVE_fnc_hashSet;
            [_fireMission, "nextRoundTime", -1] call ALIVE_fnc_hashSet;

            [_logic, "fireMission", _fireMission] call ALIVE_fnc_hashSet;
        };
    };
    case "position": {
        private _group = [_logic, "group"] call ALIVE_fnc_hashGet;
        _result = position (leader _group);
    };

    /*************
     ** METHODS **
     *************/
    case "execute": {
        private _group = [_logic, "group"] call ALIVE_fnc_hashGet;
        private _units = (units _group) select {vehicle _x != _x && {gunner _x == _x}};
        private _fireMission = [_logic, "fireMission"] call ALIVE_fnc_hashGet;
        [_fireMission, "units", _units] call ALIVE_fnc_hashSet;
        [_fireMission, "unitIndex", 0] call ALIVE_fnc_hashSet;
        [_fireMission, "roundsShot", 0] call ALIVE_fnc_hashSet;
        [_logic, "fireMission", _fireMission] call ALIVE_fnc_hashSet; // TODO: Is this needed?
    };
    case "fire": {
        private _fireMission = [_logic, "fireMission"] call ALIVE_fnc_hashGet;
        private _roundsShot = [_fireMission, "roundsShot"] call ALIVE_fnc_hashGet;
        private _units = [_fireMission, "units"] call ALIVE_fnc_hashGet;
        private _unitIndex = [_fireMission, "unitIndex"] call ALIVE_fnc_hashGet;
        private _unit = _units select _unitIndex;
        private _position = [_fireMission, "position"] call ALIVE_fnc_hashGet;
        private _roundType = [_fireMission, "roundType"] call ALIVE_fnc_hashGet;
        private _delay = [_fireMission, "delay"] call ALIVE_fnc_hashGet;

        _unit doArtilleryFire [
            _position,
            _roundType,
            1
        ];

        if ((_unitIndex + 1) > ((count _units) - 1)) then {
            _unitIndex = 0;
        } else {
            _unitIndex = _unitIndex + 1;
        };

        [_fireMission, "nextRoundTime", time + _delay] call ALIVE_fnc_hashSet;
        [_fireMission, "unitIndex", _unitIndex] call ALIVE_fnc_hashSet;
        [_fireMission, "roundsShot", _roundsShot + 1] call ALIVE_fnc_hashSet;
        [_logic, "fireMission", _fireMission] call ALIVE_fnc_hashSet; // TODO: Is this needed?
    };
    case "fireNextRound": {
        private _fireMission = [_logic, "fireMission"] call ALIVE_fnc_hashGet;
        private _nextRoundTime = [_fireMission, "nextRoundTime"] call ALIVE_fnc_hashGet;
        _result = (time >= _nextRoundTime);
    };
    case "hasFireMission": {
        private _fireMission = [_logic, "fireMission"] call ALIVE_fnc_hashGet;
        _result = (count _fireMission == 3);
    };
    case "isFireMissionComplete": {
        private _fireMission = [_logic, "fireMission"] call ALIVE_fnc_hashGet;
        private _roundCount = [_fireMission, "roundCount"] call ALIVE_fnc_hashGet;
        private _roundsShot = [_fireMission, "roundsShot"] call ALIVE_fnc_hashGet;
        _result = (_roundsShot >= _roundCount);
    };
    case "inPosition": {
        private _group = [_logic, "group"] call ALIVE_fnc_hashGet;
        _result = _group getVariable ["sup_artillery_inPosition", false];
    };
    case "inRange": {
        private _fireMission = [_logic, "fireMission"] call ALIVE_fnc_hashGet;
        private _group = [_logic, "group"] call ALIVE_fnc_hashGet;
        private _units = (units _group) select {vehicle _x != _x && {gunner _x == _x}};
        _result = _position inRangeOfArtillery [_units, _fireMission select 1];
    };
    case "move": {
        private _group = [_logic, "group"] call ALIVE_fnc_hashGet;
        private _position = [];

        if (!isNull _args && {count _args == 3}) then {
            [_logic, "moveToPos", _args] call ALIVE_fnc_hashSet;
            _position = _args;
        } else {
            _position = [_logic, "moveToPos"] call ALIVE_fnc_hashGet;
        };

        private _waypoint = _group addWaypoint [_position, 0];
        _waypoint setWaypointType "MOVE";
        _waypoint setWaypointBehaviour "SAFE";
        _waypoint setWaypointSpeed "NORMAL";
        _waypoint setWaypointStatements [
            "true",
            "(group _this) setVariable ['sup_artillery_inPosition', true]"
        ];

        _group setVariable ["sup_artillery_inPosition", false];
    };

    /******************
     ** STATEMACHINE **
     ******************/
    case "onIdle": {
        private _group = [_logic, "group"] call ALIVE_fnc_hashGet;
        _group setVariable ["sup_artillery_inPosition", true];
        [_logic, "moveToPos", objNull] call ALIVE_fnc_hashSet;

    };
    case "onActive": {
        if (!([_logic, "inRange"] call MAINCLASS)) then {
            [_logic, "moveToPos", [0,0,0]] call ALIVE_fnc_hashSet; // TODO: Figure out best firing position
        };
    };
    case "onFire": {
        [_logic, "fire"] call MAINCLASS;
    };
    case "onMove": {
        [_logic, "move"] call MAINCLASS;
    };
    case "onExecute": {
        [_logic, "execute"] call MAINCLASS;
    };
    case "onReturnToBase": {
        [_logic, "move", [0,0,0]] call MAINCLASS; // TODO: Find (best) RTB position
    };
};

// TODO: Give this legacy stuff a place
ALIVE_coreLogic = _logic;
_position = getposATL ALIVE_coreLogic;
_callsign = _logic getvariable ["artillery_callsign","EAGLE ONE"];
_type = _logic getvariable ["artillery_type","B_Heli_Attack_01_F"];
_ordnace = _logic getvariable ["artillery_ordnace",["HE", 30]];
 ARTYPOS = _position; PublicVariable "ARTYPOS";

 _result;
