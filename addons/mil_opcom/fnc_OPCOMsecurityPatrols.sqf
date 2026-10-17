#include "\x\alive\addons\mil_OPCOM\script_component.hpp"
SCRIPT(OPCOMsecurityPatrols);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMsecurityPatrols

Description:
Security Patrols (#1087). Some of the infantry groups the commander keeps in
reserve at quiet objectives walk a route through the rear objectives near them
and back home, so the ground between objectives isn't empty. Called every two
minutes by the commander's own loop while the setting is on.

A group qualifies when its objective is held and idle (its reserve order is
done), it has no order pending and no waypoints, and it isn't pinned (static
AA, a recruiter, anything stationary). An objective is rear when nothing within
2 km of it is being attacked or defended. With two or more such groups at an
objective, the setting's share of them go out and one always stays; with one,
it goes out on that share of ticks.

The commander keeps its claim: a new order (setSectionOrders) replaces the
patrol's waypoints and puts the group on its pending orders, or moves it to
another objective, and the patrol is dropped from the list the next tick
without anything of its own being touched again. A patrol is home once it has
no waypoints left and none waiting for a route (pathfinding renames waypoints,
so nothing here relies on their names). Nothing is kept on the objectives, so
saves are unchanged; after a reload a group still out finishes its route home
and is picked again from there.

Parameters:
Hash - the commander's handler

Returns:
Nil

Author:
Jman
---------------------------------------------------------------------------- */

#define PATROL_HOT_RADIUS 2000
#define PATROL_ROUTE_RADIUS 3000
#define PATROL_REST_MIN 600
#define PATROL_REST_MAX 1200
#define PATROL_TIMEOUT 5400

params ["_handler"];

private _share = [_handler, "securityPatrols", 0] call ALiVE_fnc_HashGet;
if !(_share isEqualType 0) exitWith {};
if (_share <= 0) exitWith {};

private _ledger = [_handler, "securityPatrolLedger", createHashMap] call ALiVE_fnc_HashGet;
[_handler, "securityPatrolLedger", _ledger] call ALiVE_fnc_HashSet;
private _debug = [_handler, "debug", false] call ALiVE_fnc_HashGet;
private _profilesById = [ALiVE_profileHandler, "profilesById"] call ALiVE_fnc_hashGet;
private _assignment = [_handler, "profileObjectiveAssignment", createHashMap] call ALiVE_fnc_HashGet;
private _pendingIDs = ([_handler, "pendingorders", []] call ALiVE_fnc_HashGet) apply { _x select 1 };
private _infantry = [_handler, "infantry", []] call ALiVE_fnc_HashGet;
private _objectives = ([_handler, "objectives", []] call ALiVE_fnc_HashGet) select { !([_x, "deleted", false] call ALiVE_fnc_HashGet) };
private _objectivesByID = [_handler, "objectivesByID", createHashMap] call ALiVE_fnc_HashGet;

private _hot = (_objectives select { ([_x, "opcom_state", ""] call ALiVE_fnc_HashGet) in ["attack", "attacking", "defend", "defending"] })
    apply { [_x, "center", [0,0,0]] call ALiVE_fnc_HashGet };
private _fnc_rear = {
    params ["_pos"];
    (_hot findIf { (_x distance2D _pos) < PATROL_HOT_RADIUS }) < 0
};
// waypoints left, counting any still waiting for a route
private _fnc_wpsLeft = {
    params ["_profile"];
    count (_profile select 2 select 16) + count ([_profile, "pendingWaypointPaths", []] call ALiVE_fnc_hashGet)
};
private _fnc_sendHome = {
    params ["_profile", "_homePos"];
    private _wp = [_homePos, 30, "MOVE", "NORMAL", 50, [], "NO CHANGE", "NO CHANGE", "SAFE"] call ALIVE_fnc_createProfileWaypoint;
    [_profile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
    [_profile, "addWaypoint", _wp] call ALIVE_fnc_profileEntity;
};

// the patrols already out: dropped, sent home, or rested and sent out again
{
    private _id = _x;
    _y params ["_homeID", "_since", "_phase", "_nextAt"];
    private _p = _profilesById get _id;
    private _home = _objectivesByID get _homeID;
    call {
        if (isNil "_p" || {isNil "_home"} || {[_home, "deleted", false] call ALiVE_fnc_HashGet}) exitWith { _ledger deleteAt _id };
        // taken for an order, or moved to another objective: the commander's now
        if ((_assignment getOrDefault [_id, ""]) != _homeID || {_id in _pendingIDs}) exitWith { _ledger deleteAt _id };
        private _homePos = [_home, "center", [0,0,0]] call ALiVE_fnc_HashGet;
        if (_phase in ["out", "recalled"]) then {
            private _back = (time - _since) > 60 && {([_p] call _fnc_wpsLeft) == 0 || {(time - _since) > 300 && {(([_p, "position", [0,0,0]] call ALIVE_fnc_hashGet) distance2D _homePos) < 100}}};
            if (_back) exitWith {
                [_p, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                [_p, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [200, "true", _homePos]]] call ALIVE_fnc_profileEntity;
                _ledger set [_id, [_homeID, time, "rest", time + PATROL_REST_MIN + random (PATROL_REST_MAX - PATROL_REST_MIN)]];
            };
            // out too long, or the area turned hot: straight back, once
            if (_phase == "out" && {(time - _since) > PATROL_TIMEOUT || {!([_homePos] call _fnc_rear)}}) then {
                [_p, _homePos] call _fnc_sendHome;
                _ledger set [_id, [_homeID, time, "recalled", 0]];
            };
        } else {
            // resting at home: the next tick out picks it again once the rest is over
            if (time > _nextAt) then { _ledger deleteAt _id };
        };
    };
} forEach +_ledger;

// new patrols from each rear, held objective
private _rearHeld = _objectives select {
    ([_x, "opcom_state", ""] call ALiVE_fnc_HashGet) == "idle" && {[[_x, "center", [0,0,0]] call ALiVE_fnc_HashGet] call _fnc_rear}
};
{
    private _home = _x;
    private _homeID = [_home, "objectiveID", ""] call ALiVE_fnc_HashGet;
    private _homePos = [_home, "center", [0,0,0]] call ALiVE_fnc_HashGet;
    private _section = ([_home, "section", []] call ALiVE_fnc_HashGet) select { _x isEqualType "" };
    private _resting = _section select { private _e = _ledger getOrDefault [_x, []]; _e isNotEqualTo [] && {(_e select 2) == "rest"} && {time <= (_e select 3)} };
    private _out = _section select { private _e = _ledger getOrDefault [_x, []]; _e isNotEqualTo [] && {(_e select 2) in ["out", "recalled"]} };
    private _free = _section select {
        private _p = _profilesById get _x;
        !isNil "_p"
        && {_x in _infantry}
        && {!(_x in _pendingIDs)}
        && {!(_x in _resting)} && {!(_x in _out)}
        && {(_assignment getOrDefault [_x, ""]) == _homeID}
        && {([_p] call _fnc_wpsLeft) == 0}
        && {!([_p, "busy", false] call ALIVE_fnc_hashGet)}
        && {isNil "ALIVE_profileStationary" || {!([ALIVE_profileStationary, _x, false] call ALIVE_fnc_hashGet)}}
        && {isNil "ALIVE_aaProfileBehaviour" || {([ALIVE_aaProfileBehaviour, _x, ""] call ALIVE_fnc_hashGet) != "static"}}
    };
    private _groups = count _section;
    private _want = if (_groups >= 2) then { (ceil (_groups * _share) min (_groups - 1)) - count _out } else { [0, 1] select (random 1 < _share) };
    if (_want > 0 && {_free isNotEqualTo []}) then {
        // the stops: the nearest two or three other rear objectives the commander holds within 3 km, over land,
        // in a shuffled order (an unassigned one can be the enemy's)
        private _stops = (_rearHeld + (_objectives select { ([_x, "opcom_state", ""] call ALiVE_fnc_HashGet) in ["reserve", "reserving"] }))
            select { _x isNotEqualTo _home }
            apply { [[_x, "center", [0,0,0]] call ALiVE_fnc_HashGet, [_x, "size", 100] call ALiVE_fnc_HashGet] }
            select { ((_x select 0) distance2D _homePos) < PATROL_ROUTE_RADIUS && {[_x select 0] call _fnc_rear} && {!([_homePos, _x select 0] call ALiVE_fnc_crossesSea)} };
        _stops = [_stops, [], { (_x select 0) distance2D _homePos }, "ASCEND"] call BIS_fnc_sortBy;
        _stops = (_stops select [0, 2 + floor random 2]) call BIS_fnc_arrayShuffle;
        // every leg over land, back home included: a stop that would cross water from the last one is left out
        private _route = [];
        private _from = _homePos;
        {
            if !([_from, _x select 0] call ALiVE_fnc_crossesSea) then { _route pushBack _x; _from = _x select 0; };
        } forEach _stops;
        if (_route isNotEqualTo [] && {[_from, _homePos] call ALiVE_fnc_crossesSea}) then { _route deleteAt (count _route - 1); };
        _stops = _route;
        if (_stops isNotEqualTo []) then {
            {
                if (_forEachIndex >= _want) exitWith {};
                private _p = _profilesById get _x;
                [_p, "clearActiveCommands"] call ALIVE_fnc_profileEntity;
                [_p, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                {
                    _x params ["_at", "_size"];
                    private _wp = [_at, (_size min 150), "MOVE", "LIMITED", 50, [60, 120, 240], "NO CHANGE", "NO CHANGE", "SAFE"] call ALIVE_fnc_createProfileWaypoint;
                    [_p, "addWaypoint", _wp] call ALIVE_fnc_profileEntity;
                } forEach _stops;
                private _wpHome = [_homePos, 30, "MOVE", "LIMITED", 50, [], "NO CHANGE", "NO CHANGE", "SAFE"] call ALIVE_fnc_createProfileWaypoint;
                [_p, "addWaypoint", _wpHome] call ALIVE_fnc_profileEntity;
                _ledger set [_x, [_homeID, time, "out", 0]];
                if (_debug) then {
                    ["ALiVE OPCOM SECURITY PATROL: %1 from %2 through %3 stop(s)", _x, _homeID, count _stops] call ALiVE_fnc_dump;
                };
            } forEach _free;
        };
    };
} forEach _rearHeld;
