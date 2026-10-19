/*
    NEO_fnc_groundDrive
    #690: drive a Combat Support ground vehicle to a point and wait until it gets there.
    The point is moved onto the nearest road, and the game's own driver follows the roads to
    it. Returns true on arrival, false when the order was replaced (the vehicle's run number
    moved on) or the vehicle was lost. A vehicle that hasn't moved 3 m in 120 s counts as
    arrived, with a radio call saying it is stuck. Time spent disarming does not count.
    Given an off-road distance, a point off the road (Eric on Discord, 18 Oct 2026) is reached
    after the road: the last leg leaves it for the point itself, up to that far, when the
    ground on the way has no water or steep slope; otherwise the vehicle stops at the road.
    Scheduled callers only.
    Params: [vehicle, target position, run number, move the target onto a road (default true),
             metres it may leave the road for the point itself (default 0, never)]
    Author: Jman
*/
params ["_veh", "_target", "_run", ["_toRoad", true], ["_offRoad", 0]];
private _mine = { alive _veh && {canMove _veh} && {fuel _veh >= 0.02} && {(_veh getVariable ["NEO_radioGroundRun", -1]) == _run} };
private _road = if (_toRoad) then { [_target, 150] call ALIVE_fnc_getClosestRoad } else { [] };
private _final = [];
if (_toRoad && {_road isEqualType []} && {count _road > 1} && {(_road distance2D _target) < 150}) then {
    // the point itself, when it's worth leaving the road for and the way there is passable
    private _gap = _road distance2D _target;
    if (_gap > 25 && {_gap <= _offRoad}) then {
        private _ok = true;
        for "_d" from 0 to _gap step 5 do {
            private _p = _road getPos [_d min _gap, _road getDir _target];
            if (surfaceIsWater _p || {((surfaceNormal _p) select 2) < 0.87}) exitWith { _ok = false };
        };
        if (_ok && {!surfaceIsWater _target} && {((surfaceNormal _target) select 2) >= 0.87}) then { _final = [_target select 0, _target select 1, 0] };
    };
    _target = _road;
};
_target = [_target select 0, _target select 1, 0];

// One leg: drive to a point until there, replaced, lost, stuck for _stuckAfter seconds (told by radio when
// _sayStuck) or out of time. Returns [ended there or stuck, stuck]
private _leg = {
    params ["_to", "_stuckAfter", "_sayStuck", ["_timeLimit", 1e9]];
    private _until = time + _timeLimit;
    private _stuck = false;
    [driver _veh, _to] call ALiVE_fnc_doMoveRemote;
    private _last = getPosATL _veh;
    private _still = 0;
    private _reissue = time + 20;
    private _there = false;
    while { call _mine } do {
        sleep 2;
        if ((_veh distance2D _to) < 25) exitWith { _there = true };
        if (_veh getVariable ["NEO_groundDisarming", false]) then {
            _still = 0;
            _reissue = time + 5;
        } else {
            if ((getPosATL _veh) distance2D _last < 3) then { _still = _still + 2 } else { _still = 0 };
            // the driver can drop a move order (after a stop for a mine, or a blocked turn): give it again
            if (time > _reissue && {_still >= 10}) then {
                [driver _veh, _to] call ALiVE_fnc_doMoveRemote;
                _reissue = time + 20;
            };
        };
        if (_still >= _stuckAfter || {time > _until}) exitWith {
            _stuck = true;
            if (_sayStuck) then {
                [[_veh, ["STR_ALIVE_CS_MSG_GR_STUCK", _veh getVariable ["NEO_groundCallsign", ""], mapGridPosition _veh], "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
            };
            _there = true;
        };
        _last = getPosATL _veh;
    };
    [_there, _stuck]
};
([_target, 120, true] call _leg) params ["_arrived", "_stuckOnRoad"];
// off the road, not after being stuck on it: a vehicle that can't get across, or takes longer than the
// distance allows (a long way round a stream the sampling missed), stops where it is
if (_arrived && {!_stuckOnRoad} && {_final isNotEqualTo []} && {call _mine}) then {
    _arrived = ([_final, 40, false, 30 + (_road distance2D _final) / 3] call _leg) select 0;
};
if (_arrived && {call _mine}) then { [_veh] call NEO_fnc_groundStop };
_arrived && {(_veh getVariable ["NEO_radioGroundRun", -1]) == _run}
