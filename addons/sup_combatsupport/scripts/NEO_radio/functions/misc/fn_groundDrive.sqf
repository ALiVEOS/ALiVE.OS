/*
    NEO_fnc_groundDrive
    #690: drive a Combat Support ground vehicle to a point and wait until it gets there.
    The point is moved onto the nearest road, and the game's own driver follows the roads to
    it. Returns true on arrival, false when the order was replaced (the vehicle's run number
    moved on) or the vehicle was lost. A vehicle that hasn't moved 3 m in 120 s counts as
    arrived, with a radio call saying it is stuck. Time spent disarming does not count.
    Scheduled callers only.
    Params: [vehicle, target position, run number, move the target onto a road (default true)]
    Author: Jman
*/
params ["_veh", "_target", "_run", ["_toRoad", true]];
private _mine = { alive _veh && {canMove _veh} && {fuel _veh >= 0.02} && {(_veh getVariable ["NEO_radioGroundRun", -1]) == _run} };
private _road = if (_toRoad) then { [_target, 150] call ALIVE_fnc_getClosestRoad } else { [] };
if (_toRoad && {_road isEqualType []} && {count _road > 1} && {(_road distance2D _target) < 150}) then { _target = _road };
_target = [_target select 0, _target select 1, 0];
[driver _veh, _target] call ALiVE_fnc_doMoveRemote;
private _last = getPosATL _veh;
private _still = 0;
private _reissue = time + 20;
private _arrived = false;
while { call _mine } do {
    sleep 2;
    if ((_veh distance2D _target) < 25) exitWith { _arrived = true };
    if (_veh getVariable ["NEO_groundDisarming", false]) then {
        _still = 0;
        _reissue = time + 5;
    } else {
        if ((getPosATL _veh) distance2D _last < 3) then { _still = _still + 2 } else { _still = 0 };
        // the driver can drop a move order (after a stop for a mine, or a blocked turn): give it again
        if (time > _reissue && {_still >= 10}) then {
            [driver _veh, _target] call ALiVE_fnc_doMoveRemote;
            _reissue = time + 20;
        };
    };
    if (_still >= 120) exitWith {
        [[_veh, ["STR_ALIVE_CS_MSG_GR_STUCK", _veh getVariable ["NEO_groundCallsign", ""], mapGridPosition _veh], "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
        _arrived = true;
    };
    _last = getPosATL _veh;
};
if (_arrived && {call _mine}) then { [_veh] call NEO_fnc_groundStop };
_arrived && {(_veh getVariable ["NEO_radioGroundRun", -1]) == _run}
