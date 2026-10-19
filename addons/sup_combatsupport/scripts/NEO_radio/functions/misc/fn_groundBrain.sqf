/*
    NEO_fnc_groundBrain
    #690: the order loop of a Combat Support ground transport (truck, armoured car, APC),
    the ground twin of transport.fsm. Server-side, one per vehicle.

    Orders arrive from the tablet as NEO_radioGroundNewTask = [task, posA, amount, player, posB]:
      PICKUP  drive to A, wait there for players to board (status CARGO) until the next order
      MOVE    drive to A, wait for orders
      PATROL  drive between A and B along the roads until the next order
      RTB     drive back to base
    A new order replaces the one under way: each order gets a run number, and the script
    driving the old one stops when the number moves on. A vehicle that can't move (shot
    tyres, a wrecked engine) waits as IMMOBILE for repair instead of being written off; it is
    only lost when it is destroyed or has no living crew left aboard.

    Params: [vehicle, group, callsign, base position, direction, class, respawn seconds, code, audio]
    Author: Jman
*/

params ["_veh", "_grp", "_callsign", "_base", "_dir", "_type", "_respawn", "_code", ["_audio", false], ["_settings", []]];
if (!isServer || {isNull _veh}) exitWith {};

_veh setVariable ["ALIVE_CombatSupport_Base", +_base, true];
_veh setVariable ["NEO_radioGroundUnitStatus", "NONE", true];
_veh setVariable ["NEO_radioGroundRun", 0, true];
// [unused, speed, roe] in the same slots the air transport keeps, so the tablet's combo code carries over
_veh setVariable ["NEO_radioGroundUnitProperties", [1, 1, 1], true];
_veh lockDriver true;
_veh allowCrewInImmobile true;
_veh setUnloadInCombat [false, false];
_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";
{ _x disableAI "FSM" } forEach (units _grp);

[_veh] spawn NEO_fnc_transportGunnerDefend;
if (_veh getVariable ["NEO_groundMineCheck", true]) then { [_veh] spawn NEO_fnc_groundMineCheck };

_veh setVariable ["NEO_groundCallsign", _callsign, true];
// a radio line from the crew, put together on each player's machine; needs _veh in scope
private _fnc_say = {
    params ["_key", ["_args", []]];
    [[_veh, [_key, _veh getVariable ["NEO_groundCallsign", ""]] + _args, "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
};
private _fnc_crewAboard = { (units _grp) select { alive _x && {vehicle _x == _veh} } };

private _run = 0;
while { alive _veh && {(call _fnc_crewAboard) isNotEqualTo []} } do {
    sleep 1;

    // can't move (wrecked wheels or engine, or an empty tank): hold for repair or fuel. A road
    // patrol carries on afterwards; any other order has stopped and waits for the next one
    if (!canMove _veh || {fuel _veh < 0.02}) then {
        private _was = _veh getVariable ["NEO_radioGroundUnitStatus", "NONE"];
        _veh setVariable ["NEO_radioGroundUnitStatus", "IMMOBILE", true];
        ["STR_ALIVE_CS_MSG_GR_IMMOBILE"] call _fnc_say;
        waitUntil { sleep 2; (canMove _veh && {fuel _veh >= 0.02}) || {!alive _veh} || {(call _fnc_crewAboard) isEqualTo []} };
        if (alive _veh && {canMove _veh}) then {
            _veh setVariable ["NEO_radioGroundUnitStatus", ["NONE", _was] select (_was in ["NONE", "CARGO", "PATROL"]), true];
            ["STR_ALIVE_CS_MSG_GR_MOBILE"] call _fnc_say;
        };
    };

    // an order given while the crew works on a device waits until they're done with it
    private _new = _veh getVariable ["NEO_radioGroundNewTask", []];
    if (_new isNotEqualTo [] && {!(_veh getVariable ["NEO_groundDisarming", false])}) then {
        _veh setVariable ["NEO_radioGroundNewTask", nil, true];
        // a supply truck is on its way to service it: it stays put until that is done
        if (_veh getVariable ["ALIVE_resupply_inProgress", false]) exitWith { ["STR_ALIVE_CS_MSG_GR_RESUPPLYING"] call _fnc_say };
        _run = _run + 1;
        _veh setVariable ["NEO_radioGroundRun", _run, true];
        _veh setVariable ["NEO_radioCurrentTask", _new, true];
        _new params ["_task", ["_posA", []], ["_amount", 0], ["_caller", objNull], ["_posB", []]];
        _task = toUpper _task;
        [_veh] call NEO_fnc_groundStop;
        switch (_task) do {
            case "MOVE";
            case "PICKUP": {
                _veh setVariable ["NEO_radioGroundUnitStatus", "MISSION", true];
                [_veh, _task, _posA, _run, _fnc_say] spawn {
                    params ["_veh", "_task", "_posA", "_run", "_fnc_say"];
                    // by road, then off it for the last stretch to the point itself, up to 150 m
                    private _arrived = [_veh, _posA, _run, true, 150] call NEO_fnc_groundDrive;
                    if (!_arrived || {(_veh getVariable ["NEO_radioGroundRun", -1]) != _run}) exitWith {};
                    if (_task == "PICKUP") then {
                        _veh setVariable ["NEO_radioGroundUnitStatus", "CARGO", true];
                        ["STR_ALIVE_CS_MSG_GR_WAITING", [mapGridPosition _veh]] call _fnc_say;
                    } else {
                        _veh setVariable ["NEO_radioGroundUnitStatus", "NONE", true];
                        ["STR_ALIVE_CS_MSG_GR_ARRIVED", [mapGridPosition _veh]] call _fnc_say;
                    };
                };
            };
            case "RTB": {
                _veh setVariable ["NEO_radioGroundUnitStatus", "RTB", true];
                [_veh, _run, _fnc_say] spawn {
                    params ["_veh", "_run", "_fnc_say"];
                    // home is where it was placed, not the nearest road
                    private _arrived = [_veh, _veh getVariable ["ALIVE_CombatSupport_Base", getPosATL _veh], _run, false] call NEO_fnc_groundDrive;
                    if (!_arrived || {(_veh getVariable ["NEO_radioGroundRun", -1]) != _run}) exitWith {};
                    _veh setVariable ["NEO_radioGroundUnitStatus", "NONE", true];
                    ["STR_ALIVE_CS_MSG_GR_HOME"] call _fnc_say;
                };
            };
            case "PATROL": {
                _veh setVariable ["NEO_radioGroundUnitStatus", "PATROL", true];
                ["STR_ALIVE_CS_MSG_GR_PATROL_START", [mapGridPosition _posA, mapGridPosition _posB]] call _fnc_say;
                [_veh, _posA, _posB, _run] spawn NEO_fnc_groundRoadPatrol;
            };
            default {
                _veh setVariable ["NEO_radioGroundUnitStatus", "NONE", true];
                ["ALiVE Combat Support - ground transport %1: unknown order %2", _callsign, _task] call ALiVE_fnc_dump;
            };
        };
    };
};

// lost: destroyed, or no living crew left aboard
_veh setVariable ["NEO_radioGroundRun", -1, true];
_veh setVariable ["NEO_radioGroundUnitStatus", "KILLED", true];
if !(_veh getVariable ["NEO_groundRemoved", false]) then {
    [_veh, _grp, _callsign, _base, _dir, _type, _respawn, _code, _audio, _settings] spawn ALIVE_fnc_RespawnGroundAsset;
};
