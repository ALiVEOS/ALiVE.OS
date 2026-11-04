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
    With the order's Route set to avoid known enemy (the Route box on each request, A. Ares on Discord,
    4 Nov; it starts on the module's Ground Transport Avoids Known Enemy, Jman, from AshTray), the way there
    is planned first by ALiVE's pathfinder, on the roads, around the places the side's AI Commander
    has seen the enemy in the last 30 minutes, and driven in stages; with no such place near, no
    pathfinder or no route back within 30 s, the game's driver picks the way as before.
    Scheduled callers only.
    Params: [vehicle, target position, run number, move the target onto a road (default true),
             metres it may leave the road for the point itself (default 0, never),
             round known enemy (default: the module setting)]
    Author: Jman
*/
params ["_veh", "_target", "_run", ["_toRoad", true], ["_offRoad", 0], ["_roundEnemy", NEO_radioLogic getVariable ["combatsupport_groundavoid", false]]];
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
// Around known enemy: stops along a road route that keeps clear of them, each driven to in turn
if (_roundEnemy isEqualTo true && {!isNil "ALiVE_Pathfinder"} && {call _mine}) then {
    private _side = str side group driver _veh;
    private _from = getPosATL _veh;
    private _far = (_from distance2D _target) / 2 + 1000;
    private _mid = [((_from select 0) + (_target select 0)) / 2, ((_from select 1) + (_target select 1)) / 2, 0];
    // [[place, radius], ...]: one for each place within 200 m of none already taken
    private _avoid = [];
    {
        if (([_x, "side", ""] call ALiVE_fnc_hashGet) == _side) then {
            ([_x, "knownEnemy"] call ALiVE_fnc_OPCOM) params [["_ids", []], ["_poss", []]];
            {
                private _p = _poss param [_forEachIndex, []];
                // a report with no position comes through as 0,0
                if (_p isEqualType [] && {count _p > 1} && {(_p select 0) != 0 || {(_p select 1) != 0}} && {(_p distance2D _mid) < _far} && {(_avoid findIf { ((_x select 0) distance2D _p) < 200 }) < 0}) then {
                    _avoid pushBack [[_p select 0, _p select 1, 0], 400];
                };
            } forEach _ids;
        };
    } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
    if (_avoid isEqualTo []) exitWith {};
    private _proc = [ALiVE_Pathfinder, "getPathfindingProcedure", ["LandRoad", "default"]] call ALiVE_fnc_pathfinder;
    if (isNil "_proc") exitWith {};
    private _wp = [] call ALiVE_fnc_hashCreate;
    [_wp, "position", _target] call ALiVE_fnc_hashSet;
    // asked in the crew's name, so the pathfinder knows a vehicle's size and an earlier ask still waiting is called off;
    // each ask has its own token, so a patrol's next leg can't take the answer to the last one; the side
    // goes third, where the pathfinder looks for it to colour a drawn route
    private _grp = group driver _veh;
    private _token = diag_tickTime;
    [ALiVE_Pathfinder, "cancelProfilePaths", _grp] call ALiVE_fnc_pathfinder;
    _veh setVariable ["NEO_groundRoute", nil];
    [ALiVE_Pathfinder, "findPath", [_from, _proc, _wp, nil, [_grp, _veh, _side, _token], {
        params ["_cbArgs", "_path"];
        _cbArgs params ["", "_v", "", "_tk"];
        if (!isNull _v) then { _v setVariable ["NEO_groundRoute", [_tk, _path]] };
    }, _side, _avoid]] call ALiVE_fnc_pathfinder;
    private _until = time + 30;
    waitUntil { sleep 1; !(call _mine) || {time > _until} || {((_veh getVariable ["NEO_groundRoute", []]) param [0, -1]) isEqualTo _token} };
    private _path = (_veh getVariable ["NEO_groundRoute", []]) param [1, []];
    _veh setVariable ["NEO_groundRoute", nil];
    if !(_path isEqualType [] && {count _path > 1} && {call _mine}) exitWith {
        if (call _mine) then {
            ["ALiVE Combat Support - %1 found no way round known enemy to %2 in time: drives the usual way", _veh getVariable ["NEO_groundCallsign", typeOf _veh], mapGridPosition _target] call ALiVE_fnc_dump;
        };
    };
    // a stop every 500 m or so along it, on a road, none in the last 300 m
    private _stops = [];
    private _last = _from;
    {
        if (_x isEqualType [] && {count _x > 1} && {(_x distance2D _last) >= 500} && {(_x distance2D _target) > 300}) then {
            private _r = [[_x select 0, _x select 1, 0], 100] call ALIVE_fnc_getClosestRoad;
            if (isOnRoad _r) then { _stops pushBack [_r select 0, _r select 1, 0]; _last = _x };
        };
    } forEach _path;
    ["ALiVE Combat Support - %1 drives round %2 known enemy place(s) to %3, by %4 stop(s)", _veh getVariable ["NEO_groundCallsign", typeOf _veh], count _avoid, mapGridPosition _target, count _stops] call ALiVE_fnc_dump;
    {
        if !(call _mine) exitWith {};
        [_x, 40, false, 60 + (_veh distance2D _x) / 3] call _leg;
    } forEach _stops;
};
([_target, 120, true] call _leg) params ["_arrived", "_stuckOnRoad"];
// off the road, not after being stuck on it: a vehicle that can't get across, or takes longer than the
// distance allows (a long way round a stream the sampling missed), stops where it is
if (_arrived && {!_stuckOnRoad} && {_final isNotEqualTo []} && {call _mine}) then {
    _arrived = ([_final, 40, false, 30 + (_road distance2D _final) / 3] call _leg) select 0;
};
if (_arrived && {call _mine}) then { [_veh] call NEO_fnc_groundStop };
_arrived && {(_veh getVariable ["NEO_radioGroundRun", -1]) == _run}
