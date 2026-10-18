// NEO_fnc_transportParadrop
// ------------------------------------------------------------------
// The PARADROP transport task. The helicopter flies to the point marked on the tablet at the
// height the player chose and, over it, puts its passengers out one after another on static
// lines: each goes straight into an open steerable parachute (NEO_fnc_transportParadropUnit, run
// where the jumper is local) and keeps everything they carry, backpack included. The helicopter
// then holds over the drop zone for its next order, as after a Move.
//
// Started by transport.fsm's PARADROP link, which then waits in the Pickup holding state:
// any new tablet order still takes over, and this script notices and stops.
//
// Params: [_chopper, _callsign, _pos, _alt, _run]
//
// Author: Jman
// ------------------------------------------------------------------
params ["_chopper", "_callsign", "_pos", ["_alt", 250], ["_run", 0]];

if (!isServer) exitWith {};

_alt = ((round _alt) max 150) min 500;

// A radio call as a stringtable key and its details, put together on each player's machine in
// that player's language; the callsign is always the first detail.
private _say = {
    params ["_key", ["_args", []]];
    [[_chopper, [_key, _callsign] + _args, "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
};
// Still this run's to fly: any new order changes the current task, a second PARADROP the run number.
private _task0 = _chopper getVariable ["NEO_radioCurrentTask", []];
private _mine = {
    alive _chopper && {alive driver _chopper}
    && {(_chopper getVariable ["NEO_radioParadropRun", 0]) == _run}
    && {(_chopper getVariable ["NEO_radioCurrentTask", []]) isEqualTo _task0}
    && {isNil {_chopper getVariable "NEO_radioTransportNewTask"}}
};
// The passengers by seat, as Medevac does (#530): the cargo seats and the seats passengers fire
// from. Grouping by crew group put door gunners in a group of their own out. Anyone unconscious
// stays aboard, as they couldn't land a canopy.
private _jumpers = {
    ((fullCrew [_chopper, "cargo"]) + ((fullCrew [_chopper, "turret"]) select { _x select 4 }))
        apply { _x select 0 }
        select { alive _x && {lifeState _x != "INCAPACITATED"} && {!(_x getVariable ["ACE_isUnconscious", false])} }
};
// above the ground, or the sea surface over water
private _height = { (getPos _chopper) select 2 };

// A helicopter that has stopped won't climb to a new height or take a fresh order to a spot it
// thinks it has reached (see NEO_fnc_transportInsertionHold). So the height is asked for on the
// way in, and one starting close to the drop zone first flies out to make a proper run.
_chopper flyInHeight _alt;
if ((_chopper distance2D _pos) < 1500) then {
    private _runIn = _pos getPos [1500, _pos getDir _chopper];
    [_chopper, _runIn] call ALiVE_fnc_doMoveRemote;
    private _t = time;
    waitUntil { sleep 1; !(call _mine) || {(_chopper distance2D _runIn) < 300} || {time - _t > 240} };
};
if !(call _mine) exitWith {};
[_chopper, _pos] call ALiVE_fnc_doMoveRemote;

// Over the drop zone at the height asked for. A pilot can also stop short and call that arrived;
// within 400 m and high enough, that's near enough to drop from rather than hang there.
private _high = (_alt * 0.8) max 140;
private _t = time;
waitUntil {
    sleep 0.5;
    !(call _mine)
    || {(_chopper distance2D _pos) < 120 && {(call _height) >= _high}}
    || {time - _t > 10 && {speed _chopper < 10} && {(_chopper distance2D _pos) < 400} && {(call _height) >= 140} && {_chopper call ALiVE_fnc_unitReadyRemote}}
    || {time - _t > 900}
};
if !(call _mine) exitWith {};
// never put anyone out far from where they asked to go, or too low for a canopy
if ((_chopper distance2D _pos) > 400 || {(call _height) < 140}) exitWith { ["STR_ALIVE_CS_MSG_PARADROP_ABORT"] call _say };

private _out = call _jumpers;
if (_out isEqualTo []) exitWith { ["STR_ALIVE_CS_MSG_PARADROP_EMPTY"] call _say };

["STR_ALIVE_CS_MSG_PARADROP_GO"] call _say;
{
    if !(call _mine) exitWith {};
    if (alive _x && {vehicle _x == _chopper}) then {
        [_x, _chopper] remoteExecCall ["NEO_fnc_transportParadropUnit", _x];
        // a second between jumpers keeps their canopies apart
        sleep 1;
    };
} forEach _out;

if (call _mine) then {
    // back to the cruise height every other order flies at
    _chopper flyInHeight 100;
    ["STR_ALIVE_CS_MSG_06"] call _say;
};
