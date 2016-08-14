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
private _args = param [2, [], [objNull, [], "", 0, true, false]];

private _result = true;

diag_log format ["###### %1: _logic: %2, _operation: %3, _args: %4", "ALIVE_fnc_artillery", _logic, _operation, _args];

switch (_operation) do {
    case "init": {
        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];

        // Defaults
        /* _logic setVariable ["group", grpNull]; */
        _logic setVariable ["moveToPos", objNull];
        _logic setVariable ["fireMission", []];
    };

    /****************
     ** PROPERTIES **
     ****************/
    case "fireMission": {
        if (count _args == 0) then {
            _result = _logic getVariable ["fireMission", objNull];
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

            _logic setVariable ["fireMission", _fireMission];
        };
    };
    case "position": {
        private _group = _logic getVariable ["group", grpNull];
        _result = position (leader _group);
    };

    /*************
     ** METHODS **
     *************/
    case "execute": {
        private _group = _logic getVariable ["group", grpNull];
        private _units = (units _group) select {vehicle _x != _x && {gunner (vehicle _x) == _x}};
        private _fireMission = _logic getVariable ["fireMission", objNull];
        private _fireMissionPos = [_fireMission, "position"] call ALIVE_fnc_hashGet;
        [_fireMission, "units", _units] call ALIVE_fnc_hashSet;
        [_fireMission, "unitIndex", 0] call ALIVE_fnc_hashSet;
        [_fireMission, "roundsShot", 0] call ALIVE_fnc_hashSet;
        _units doWatch _fireMissionPos;

        _logic setVariable ["fireMission", _fireMission];
    };
    case "fire": {
        private _fireMission = _logic getVariable ["fireMission", objNull];
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

        _logic setVariable ["fireMission", _fireMission];
    };
    case "fireNextRound": {
        private _fireMission = _logic getVariable ["fireMission", objNull];
        private _nextRoundTime = [_fireMission, "nextRoundTime"] call ALIVE_fnc_hashGet;
        _result = (time >= _nextRoundTime);
    };
    case "hasFireMission": {
        private _fireMission = _logic getVariable ["fireMission", objNull];
        _result = (count _fireMission > 0);
    };
    case "isFireMissionComplete": {
        private _fireMission = _logic getVariable ["fireMission", objNull];
        private _roundCount = [_fireMission, "roundCount"] call ALIVE_fnc_hashGet;
        private _roundsShot = [_fireMission, "roundsShot"] call ALIVE_fnc_hashGet;
        _result = (_roundsShot >= _roundCount);
    };
    case "inPosition": {
        private _group = _logic getVariable ["group", grpNull];
        _result = _group getVariable ["sup_artillery_inPosition", false];
    };
    case "inRange": {
        private _fireMission = _logic getVariable ["fireMission", objNull];
        private _position = [_fireMission, "position"] call ALIVE_fnc_hashGet;
        private _roundType = [_fireMission, "roundType"] call ALIVE_fnc_hashGet;
        private _group = _logic getVariable ["group", grpNull];
        private _units = (units _group) select {vehicle _x != _x && {gunner (vehicle _x) == _x}};
        _result = _position inRangeOfArtillery [_units, _roundType];
    };
    case "move": {
        private _group = _logic getVariable ["group", grpNull];
        private _position = [];

        if (count _args == 0) then {
            _position = _logic getVariable ["moveToPos", objNull];
        } else {
            _position = _args param [0, [0,0,0], [[]], 3];
            _logic setVariable ["moveToPos", _position];
        };

        _group setVariable ["sup_artillery_inPosition", false];

        private _waypoint = _group addWaypoint [_position, 0];
        _waypoint setWaypointType "MOVE";
        _waypoint setWaypointBehaviour "SAFE";
        _waypoint setWaypointForceBehaviour true;
        _waypoint setWaypointSpeed "NORMAL";
        _waypoint setWaypointFormation "COLUMN";
        _waypoint setWaypointStatements [
            "true",
            "(group this) setVariable ['sup_artillery_inPosition', true]"
        ];
        diag_log format["_group: %1, _position: %2, _waypoint: %3", _group, _position, _waypoint];
    };
    case "spawn": {
        private _position = position _logic;
        private _type = _logic getVariable ["artillery_type", ""];
        private _callsign = _logic getVariable ["artillery_callsign", ""];
        private _code = _logic getVariable ["artillery_code", ""];

        private _side = _type call ALIVE_fnc_classSide;
        private _group = createGroup _side;

        for "_i" from 0 to 2 do {
            // TODO: Spawn vehicles in proper fancy formation (see CfgFormations)
            private _vehiclePosition = _position getPos [15 * _i, (getDir _logic) * _i];
            private _vehicle = createVehicle [_type, _vehiclePosition, [], 0, "NONE"];
            _vehicle setDir (getDir _logic);
            _vehicle lock true;
            [_vehicle, _group] call BIS_fnc_spawnCrew;
        };

        _group setVariable ["logic", _logic];
        _logic setVariable ["group", _group];

        if (isNil "ALIVE_sup_artillery_stateMachine") then {
            ALIVE_sup_artillery_stateMachine_list = [];
            ALIVE_sup_artillery_stateMachine = [
                configFile >> "ArtilleryStateMachine"
            ] call CBA_statemachine_fnc_createFromConfig;
        };

        ALIVE_sup_artillery_stateMachine_list pushBack _logic;

        _result = _group;
    };

    /******************
     ** STATEMACHINE **
     ******************/
    case "onIdle": {
        private _group = _logic getVariable ["group", grpNull];
        _group setVariable ["sup_artillery_inPosition", true];
        _logic setVariable ["moveToPos", objNull];
    };
    case "onActive": {
        if (!([_logic, "inRange"] call MAINCLASS)) then {
            _logic setVariable ["moveToPos", [3451.45,5379.89,0]]; // TODO: Figure out best firing position
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
        private _group = _logic getVariable ["group", grpNull];
        private _units = (units _group) select {vehicle _x != _x && {gunner (vehicle _x) == _x}};
        _units doWatch objNull;

        _logic setVariable ["fireMission", []];
        [_logic, "move", [position _logic]] call MAINCLASS; // TODO: Find (best) RTB position
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
