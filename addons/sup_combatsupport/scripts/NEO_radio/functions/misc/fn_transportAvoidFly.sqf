// NEO_fnc_transportAvoidFly
// ------------------------------------------------------------------
// Flies a Combat Support helicopter through the turns NEO_fnc_transportAvoidLegs worked out
// round known enemy (A. Ares on Discord, 4 Nov 2026), then posts its order again so transport.fsm
// carries it out exactly as it would have done straight away. Spawned by transport.fsm, which
// holds the task as LEGS meanwhile. Stops when a different order comes in (the run number moves
// on) or the helicopter is lost; a turn the pilot isn't making headway to, 30 s after it is in the
// air, is let go.
//
// Server only, scheduled.
//
// Params: [_chopper, _legs, _run, _order]
//
// Author: Jman
// ------------------------------------------------------------------
params ["_chopper", "_legs", "_run", "_order"];

if (!isServer) exitWith {};

private _mine = {
    alive _chopper && {alive driver _chopper} && {canMove _chopper}
    && {(_chopper getVariable ["NEO_radioRouteRun", 0]) == _run}
};

// a hook or unhook waypoint left from an earlier order outranks a move
private _grp = group driver _chopper;
private _guard = 0;
while { count waypoints _grp > 1 && {_guard < 32} } do {
    deleteWaypoint ((waypoints _grp) select ((count waypoints _grp) - 1));
    _guard = _guard + 1;
};
_chopper flyInHeight 100;
// lift-off is judged from where it starts, so a deck or a rooftop pad counts as the ground
private _z0 = (getPosASL _chopper) select 2;

{
    if !(call _mine) exitWith {};
    private _leg = _x;
    [_chopper, _leg] call ALiVE_fnc_doMoveRemote;
    // from a standstill the clock starts once it has climbed or is under way (90 s at most)
    private _up = time + 90;
    waitUntil { sleep 0.5; !(call _mine) || {((getPosASL _chopper) select 2) > _z0 + 10} || {speed _chopper > 30} || {time > _up} };
    if !(call _mine) exitWith {};
    private _d0 = _chopper distance2D _leg;
    private _t0 = time;
    private _until = time + 30 + _d0 / 15;
    // on to the next one 400 m short of each turn, so the pilot never stops to hover at one
    waitUntil {
        sleep 0.5;
        !(call _mine) || {(_chopper distance2D _leg) < 400} || {time > _until}
        || {time - _t0 > 30 && {(_d0 - (_chopper distance2D _leg)) < 100}}
    };
} forEach _legs;

// unscheduled, so a newer order can't slip in between the check and the post
isNil {
    if (call _mine) then {
        // marks this order as flown round, so transport.fsm dispatches it this time
        _chopper setVariable ["NEO_radioRouteFor", nil];
        _chopper setVariable ["NEO_radioRouted", _order];
        _chopper setVariable ["NEO_radioTransportNewTask", _order, true];
    } else {
        // lost the pilot with no newer order: the same order sent again is worked out afresh
        if ((_chopper getVariable ["NEO_radioRouteRun", 0]) == _run) then { _chopper setVariable ["NEO_radioRouteFor", nil] };
    };
};
