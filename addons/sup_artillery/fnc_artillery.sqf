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
#define TYPE_ARTILLERY 0
#define TYPE_MORTAR 1

private _logic = param [0, objNull, [objNull, []]];
private _operation = param [1, "", [""]];
private _args = param [2, [], [objNull, [], "", 0, true, false]];

private _result = true;

/* diag_log format ["###### %1: _logic: %2, _operation: %3, _args: %4", "ALIVE_fnc_artillery", _logic, _operation, _args]; */

switch (_operation) do {
    case "init": {
        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];

        // Defaults
        _logic setVariable ["group", grpNull];
        _logic setVariable ["moveToPos", objNull];
        _logic setVariable ["fireMission", []];

        // Spawn and initialize artillery units
        [_logic] call ALIVE_fnc_artillerySpawn;

        // Start state machine if it hasn't already
        if (isNil "ALIVE_sup_artillery_stateMachine") then {
            ALIVE_sup_artillery_stateMachine_list = [];
            ALIVE_sup_artillery_stateMachine = [
                configFile >> "ArtilleryStateMachine"
            ] call CBA_statemachine_fnc_createFromConfig;
        };

        // Add artillery module to state machine
        ALIVE_sup_artillery_stateMachine_list pushBack _logic;
    };
    // get available rounds
    case "rounds": {
        private _rounds = [
            ["HE", parseNumber (_logic getVariable ["artillery_he", "30"])],
            ["ILLUM", parseNumber (_logic getVariable ["artillery_illum", "30"])],
            ["SMOKE", parseNumber (_logic getVariable ["artillery_smoke", "30"])],
            ["SADARM", parseNumber (_logic getVariable ["artillery_guided", "30"])],
            ["CLUSTER", parseNumber (_logic getVariable ["artillery_cluster", "30"])],
            ["LASER", parseNumber (_logic getVariable ["artillery_lg", "30"])],
            ["MINE", parseNumber (_logic getVariable ["artillery_mine", "30"])],
            ["AT MINE", parseNumber (_logic getVariable ["artillery_atmine", "30"])],
            ["ROCKETS", parseNumber (_logic getVariable ["artillery_rockets", "16"])]
        ];

        private _roundsAvailable = [];
        private _roundsUnit = (typeOf (_vehicles select 0)) call ALIVE_fnc_getArtyRounds;

        {
            if ((_x select 0) in _roundsUnit) then {
                _roundsAvailable pushBack _x;
            };
        } forEach _rounds;

        _result = _roundsAvailable;
    };
    // get/set fire mission
    case "fireMission": {
        if (count _args == 0) then {
            _result = _logic getVariable ["fireMission", []];
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
            // Fire mission state
            [_fireMission, "units", []] call ALIVE_fnc_hashSet;
            [_fireMission, "unitIndex", -1] call ALIVE_fnc_hashSet;
            [_fireMission, "roundsShot", -1] call ALIVE_fnc_hashSet;
            [_fireMission, "nextRoundTime", -1] call ALIVE_fnc_hashSet;

            _logic setVariable ["fireMission", _fireMission];
        };
    };
    // get position
    case "position": {
        private _group = _logic getVariable ["group", grpNull];
        _result = position (leader _group);
    };
    case "hasFireMission": {
        private _fireMission = _logic getVariable ["fireMission", []];
        _result = (count _fireMission > 0);
    };
    case "activate": {
        if (!([_logic, "inRange"] call MAINCLASS)) then {
            _logic setVariable ["moveToPos", [3744.56,4757.54,0]]; // TODO: Figure out best firing position
        };
    };
    case "inRange": {
        private _fireMission = _logic getVariable ["fireMission", []];
        private _position = [_fireMission, "position"] call ALIVE_fnc_hashGet;
        private _roundType = [_fireMission, "roundType"] call ALIVE_fnc_hashGet;
        private _group = _logic getVariable ["group", grpNull];
        private _units = (units _group) select {vehicle _x != _x && {gunner (vehicle _x) == _x}};
        _result = _position inRangeOfArtillery [_units, _roundType];
    };
    case "pack": {
        private _group = _logic getVariable ["group", grpNull];
        private _deployed = _group getVariable ["sup_artillery_deployed", true];

        if (_deployed) then {
            private _weapon = objNull;

            {
                if (vehicle _x != _x) exitWith { _weapon = vehicle _x };
            } forEach (units _group);

            private _handle = [_group, _weapon] spawn ALIVE_fnc_packMortar;

            [_group, _handle] spawn {
                private _group = _this select 0;
                private _handle = _this select 1;

                waitUntil { scriptDone _handle };
                _group setVariable ["sup_artillery_deployed", false];
            };
        };
    };
    case "hasPacked": {
        private _type = _logic getvariable ["type", TYPE_ARTILLERY];

        if (_type == TYPE_MORTAR) then {
            private _group = _logic getVariable ["group", grpNull];
            _result = !(_group getVariable ["sup_artillery_deployed", true]);
        } else {
            _result = true
        };
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
    };
    case "inPosition": {
        private _group = _logic getVariable ["group", grpNull];
        _result = _group getVariable ["sup_artillery_inPosition", false];
    };
    case "unpack": {
        private _group = _logic getVariable ["group", grpNull];
        private _fireMission = _logic getVariable ["fireMission", []];
        private _position = [_fireMission, "position"] call ALIVE_fnc_hashGet;

        private _handle = [_group, position (leader _group), _position] spawn ALIVE_fnc_unpackMortar;

        [_group, _handle] spawn {
            private _group = _this select 0;
            private _handle = _this select 1;

            waitUntil { scriptDone _handle };
            _group setVariable ["sup_artillery_deployed", true];
        };
    };
    case "hasUnpacked": {
        private _type = _logic getvariable ["type", TYPE_ARTILLERY];

        if (_type == TYPE_MORTAR) then {
            private _group = _logic getVariable ["group", grpNull];
            _result = _group getVariable ["sup_artillery_deployed", true];
        } else {
            _result = true
        };
    };
    case "execute": {
        private _group = _logic getVariable ["group", grpNull];
        private _units = (units _group) select {vehicle _x != _x && {gunner (vehicle _x) == _x}};
        private _fireMission = _logic getVariable ["fireMission", []];
        private _fireMissionPos = [_fireMission, "position"] call ALIVE_fnc_hashGet;
        [_fireMission, "units", _units] call ALIVE_fnc_hashSet;
        [_fireMission, "unitIndex", 0] call ALIVE_fnc_hashSet;
        [_fireMission, "roundsShot", 0] call ALIVE_fnc_hashSet;
        [_fireMission, "nextRoundTime", time] call ALIVE_fnc_hashSet;
        _units doWatch _fireMissionPos;

        _logic setVariable ["fireMission", _fireMission];

        // Attach Fired EH to all vehicles in group
        {
            private _vehicle = vehicle _x;
            private _firedEH = _vehicle addEventHandler ["Fired", ALIVE_fnc_artilleryFiredEH];
            _vehicle setVariable ["sup_artillery_firedEH", _firedEH];
        } forEach _units;
    };
    case "canFireRound": {
        private _fireMission = _logic getVariable ["fireMission", []];
        private _nextRoundTime = [_fireMission, "nextRoundTime"] call ALIVE_fnc_hashGet;
        _result = (_nextRoundTime != -1 && {time >= _nextRoundTime});
    };
    // TODO: Check if unit is alive, otherwise skip
    case "fire": {
        private _fireMission = _logic getVariable ["fireMission", []];
        private _delay = [_fireMission, "delay"] call ALIVE_fnc_hashGet;
        private _units = [_fireMission, "units"] call ALIVE_fnc_hashGet;
        private _position = [_fireMission, "position"] call ALIVE_fnc_hashGet;
        private _roundType = [_fireMission, "roundType"] call ALIVE_fnc_hashGet;

        if (_delay > 0) then {
            private _unitIndex = [_fireMission, "unitIndex"] call ALIVE_fnc_hashGet;
            private _unit = _units select _unitIndex;

            _unit doArtilleryFire [
                _position,
                _roundType,
                1
            ];
        } else {
            {
                private _roundCount = [_fireMission, "roundCount"] call ALIVE_fnc_hashGet;

                _x doArtilleryFire [
                    _position,
                    _roundType,
                    floor (_roundCount / (count _units)) // TODO: Better distribution
                ];
            } forEach _units;
        };

        [_fireMission, "nextRoundTime", -1] call ALIVE_fnc_hashSet;
        _logic setVariable ["fireMission", _fireMission];
    };
    case "isFireMissionComplete": {
        private _fireMission = _logic getVariable ["fireMission", []];
        private _roundCount = [_fireMission, "roundCount"] call ALIVE_fnc_hashGet;
        private _roundsShot = [_fireMission, "roundsShot"] call ALIVE_fnc_hashGet;
        _result = (_roundsShot >= _roundCount);
    };
    case "isFireMissionDelayed": {
        private _fireMission = _logic getVariable ["fireMission", []];
        private _delay = [_fireMission, "delay"] call ALIVE_fnc_hashGet;
        _result = (_delay > 0);
    };
    case "returnToBase": {
        private _group = _logic getVariable ["group", grpNull];
        private _units = (units _group) select {vehicle _x != _x && {gunner (vehicle _x) == _x}};
        _units doWatch objNull;

        // Cleanup event handlers
        {
            private _vehicle = vehicle _x;
            private _firedEH = _vehicle getVariable ["sup_artillery_firedEH", nil];

            if (!isNil "_firedEH") then {
                _vehicle removeEventHandler ["Fired", _firedEH];
                _vehicle setVariable ["sup_artillery_firedEH", nil];
            };
        } forEach _units;

        _logic setVariable ["fireMission", []];
        [_logic, "move", [position _logic]] call MAINCLASS;
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
