#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMGroupOrderRun);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMGroupOrderRun

Description:
Carries out the War Room's orders for the groups it holds (ALIVE_fnc_SCOMGroupOrder): the step of a
group's order list it is on, and a check every 30 s of how each step is going. Server only.

A group's list is on its profile, so it is saved and loaded with it:
    warRoomQueue - [[op, x, y, extra], ...], at most 8 steps: "move" (extra ""), "attack" (the target's
                   profile id), "static" (the gun's netId), "patrol" (the radius in m)
    warRoomQueueIdx - the step it is on, from 0; past the end, it holds where it is
    warRoomLoop - back to the first step after the last (only for a list of moves and patrols)
    warRoomStance - [rules of engagement, behaviour, speed], "" for the group's own; put into every waypoint

A move is done once the group is within 50 m of its point. An attack follows its target, giving the
group a new search-and-destroy point when the target has moved more than 150 m, and is done when the
target is dead or gone, or after 20 minutes. A static is crewed once the group is spawned, by its
nearest men, and holds until the gun is destroyed. A patrol walks its loop until the next order.

Parameters:
String - "apply" (start the step the group is on), "tick" (the 30 s check), "register" (watch a
         profile id, as after a load), "dismount" (crew leaves its gun), "release" (stop watching)
Array - the profile, or String - the profile id for "register" and "release"

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_arg", []]];

// at mission start (CfgFunctions preInit): the War Room's group orders this build takes beyond
// move, stop, lock and unlock (ALIVE_fnc_SCOMGroupOrder)
if (_op == "preInit") exitWith {
    ALIVE_SCOMGroupOrderOps = ["attack", "static", "handback", "stance", "patrol", "qdel", "qmove", "qclear", "loop"];
};
if (!isServer) exitWith {};

#define RETARGET 150
#define ATTACK_TIME 1200
#define REACHED 50

// the gun of a static step. A netId means nothing after a restart, so when it no longer names a live
// static gun at the step's point, the nearest one within 5 m is taken and the step is given its netId.
private _fnc_gun = {
    params ["_profile", "_pos", "_netId"];
    private _gun = objectFromNetId _netId;
    if (isNull _gun || {!alive _gun} || {!(_gun isKindOf "StaticWeapon")} || {(_gun distance2D _pos) > 5}) then {
        _gun = (nearestObjects [_pos, ["StaticWeapon"], 5]) param [0, objNull];
        if (!isNull _gun && {alive _gun}) then {
            private _queue = [_profile, "warRoomQueue", []] call ALiVE_fnc_hashGet;
            private _step = _queue select ([_profile, "warRoomQueueIdx", 0] call ALiVE_fnc_hashGet);
            _step set [3, netId _gun];
        };
    };
    _gun
};

private _fnc_group = {
    params ["_profile"];
    if !([_profile, "active", false] call ALiVE_fnc_hashGet) exitWith { grpNull };
    private _g = [_profile, "group", grpNull] call ALiVE_fnc_hashGet;
    if (_g isEqualType grpNull) then { _g } else { grpNull }
};

// a profile waypoint carrying the group's stance
private _fnc_waypoint = {
    params ["_profile", "_pos", ["_type", "MOVE"], ["_radius", 0]];
    (([_profile, "warRoomStance", []] call ALiVE_fnc_hashGet) + ["", "", ""]) params ["_roe", "_beh", "_speed"];
    [[_pos select 0, _pos select 1, 0], _radius, _type,
        if (_speed == "") then {"UNCHANGED"} else {_speed}, -1, [], "NO CHANGE",
        if (_roe == "") then {"NO CHANGE"} else {_roe},
        if (_beh == "") then {"UNCHANGED"} else {_beh}] call ALiVE_fnc_createProfileWaypoint
};

switch (_op) do {

    case "register": {
        private _held = missionNamespace getVariable ["ALiVE_SCOM_held", createHashMap];
        _held set [_arg, createHashMap];
        ALiVE_SCOM_held = _held;
        if (isNil "ALiVE_SCOM_loop") then {
            ALiVE_SCOM_loop = [] spawn {
                while {true} do {
                    sleep 30;
                    { isNil { ["tick", _x] call ALIVE_fnc_SCOMGroupOrderRun } } forEach (keys (missionNamespace getVariable ["ALiVE_SCOM_held", createHashMap]));
                };
            };
        };
    };

    case "release": {
        (missionNamespace getVariable ["ALiVE_SCOM_held", createHashMap]) deleteAt _arg;
    };

    case "dismount": {
        private _g = [_arg] call _fnc_group;
        if (isNull _g) exitWith {};
        private _crew = (units _g) select { alive _x && {vehicle _x != _x} && {(vehicle _x) isKindOf "StaticWeapon"} };
        if (_crew isEqualTo []) exitWith {};
        [_crew, {
            { unassignVehicle _x; [_x] orderGetIn false; moveOut _x } forEach _this;
        }] remoteExecCall ["call", leader _g];
    };

    case "apply": {
        private _profile = _arg;
        private _id = _profile select 2 select 4;
        private _queue = [_profile, "warRoomQueue", []] call ALiVE_fnc_hashGet;
        private _idx = [_profile, "warRoomQueueIdx", 0] call ALiVE_fnc_hashGet;
        ["register", _id] call ALIVE_fnc_SCOMGroupOrderRun;
        private _state = ALiVE_SCOM_held get _id;

        ["dismount", _profile] call ALIVE_fnc_SCOMGroupOrderRun;
        [_profile, "clearWaypoints"] call ALiVE_fnc_profileEntity;
        if (_idx >= count _queue) exitWith {};   // the list is done: it holds where it is

        (_queue select _idx) params ["_step", "_px", "_py", ["_extra", ""]];
        private _pos = [_px, _py];
        _state set ["started", time];
        switch (_step) do {
            case "move": {
                [_profile, "addWaypoint", [_profile, _pos] call _fnc_waypoint] call ALiVE_fnc_profileEntity;
            };
            case "attack": {
                private _target = [ALiVE_profileHandler, "getProfile", _extra] call ALiVE_fnc_profileHandler;
                if (!isNil "_target") then { _pos = ([_target, "position", _pos] call ALiVE_fnc_hashGet) select [0, 2] };
                _state set ["targetAt", _pos];
                [_profile, "addWaypoint", [_profile, _pos, "SAD", 50] call _fnc_waypoint] call ALiVE_fnc_profileEntity;
            };
            case "static": {
                // to the gun first; once spawned, the tick puts its nearest men on it
                [_profile, "addWaypoint", [_profile, _pos] call _fnc_waypoint] call ALiVE_fnc_profileEntity;
            };
            case "patrol": {
                private _radius = if (_extra isEqualType 0 && {_extra > 0}) then {_extra} else {150};
                private _first = random 360;
                for "_k" from 0 to 4 do {
                    [_profile, "addWaypoint", [_profile, _pos getPos [_radius, _first + _k * 72]] call _fnc_waypoint] call ALiVE_fnc_profileEntity;
                };
                [_profile, "addWaypoint", [_profile, _pos getPos [_radius, _first], "CYCLE"] call _fnc_waypoint] call ALiVE_fnc_profileEntity;
            };
        };
    };

    case "tick": {
        private _id = _arg;
        private _held = missionNamespace getVariable ["ALiVE_SCOM_held", createHashMap];
        private _state = _held getOrDefault [_id, createHashMap];
        private _profile = [ALiVE_profileHandler, "getProfile", _id] call ALiVE_fnc_profileHandler;
        // gone, or no longer the War Room's: nothing more to do for it
        if (isNil "_profile" || {!([_profile, "warRoomOrdered", false] call ALiVE_fnc_hashGet)}) exitWith { _held deleteAt _id };

        private _queue = [_profile, "warRoomQueue", []] call ALiVE_fnc_hashGet;
        private _idx = [_profile, "warRoomQueueIdx", 0] call ALiVE_fnc_hashGet;
        if (_idx >= count _queue) exitWith {};
        // after a load, the step it was on starts again
        if !("started" in _state) exitWith { ["apply", _profile] call ALIVE_fnc_SCOMGroupOrderRun };

        (_queue select _idx) params ["_step", "_px", "_py", ["_extra", ""]];
        private _pos = [_px, _py];
        private _here = [_profile, "position", [0, 0, 0]] call ALiVE_fnc_hashGet;
        private _done = false;
        switch (_step) do {
            case "move": { _done = (_here distance2D _pos) < REACHED };
            case "attack": {
                private _target = [ALiVE_profileHandler, "getProfile", _extra] call ALiVE_fnc_profileHandler;
                if (isNil "_target" || {time - (_state getOrDefault ["started", time]) > ATTACK_TIME}) exitWith { _done = true };
                private _at = ([_target, "position", _pos] call ALiVE_fnc_hashGet) select [0, 2];
                if ((_at distance2D (_state getOrDefault ["targetAt", _at])) > RETARGET) then {
                    _state set ["targetAt", _at];
                    [_profile, "clearWaypoints"] call ALiVE_fnc_profileEntity;
                    [_profile, "addWaypoint", [_profile, _at, "SAD", 50] call _fnc_waypoint] call ALiVE_fnc_profileEntity;
                };
                // a spawned group is told where the target is
                private _g = [_profile] call _fnc_group;
                if (!isNull _g && {[_target, "active", false] call ALiVE_fnc_hashGet}) then {
                    private _tg = [_target, "group", grpNull] call ALiVE_fnc_hashGet;
                    private _who = if (_tg isEqualType grpNull && {!isNull _tg}) then { leader _tg } else { objNull };
                    if (!isNull _who) then { [_g, [_who, 2]] remoteExecCall ["reveal", leader _g] };
                };
            };
            case "static": {
                private _gun = [_profile, _pos, _extra] call _fnc_gun;
                if (isNull _gun || {!alive _gun}) exitWith { _done = true };
                private _g = [_profile] call _fnc_group;
                if (isNull _g) exitWith { _state deleteAt "crewed" };
                if ((_state getOrDefault ["crewed", grpNull]) isEqualTo _g) exitWith {};
                _state set ["crewed", _g];
                // its empty gun seats, gunner first, each to the nearest man still on foot
                private _seats = (fullCrew [_gun, "", true]) select { isNull (_x select 0) && {(_x select 1) in ["gunner", "commander", "turret"]} };
                _seats = [_seats, [], { [1, 0] select ((_x select 1) == "gunner") }, "ASCEND"] call BIS_fnc_sortBy;
                private _men = (units _g) select { alive _x && {vehicle _x == _x} };
                _men = [_men, [], { _x distance _gun }, "ASCEND"] call BIS_fnc_sortBy;
                private _orders = [];
                { if (_forEachIndex < count _men) then { _orders pushBack [_men select _forEachIndex, _x select 1, _x select 3] } } forEach _seats;
                [[_gun, _orders], {
                    params ["_gun", "_orders"];
                    {
                        _x params ["_man", "_role", "_path"];
                        switch (_role) do {
                            case "gunner": { _man assignAsGunner _gun };
                            case "commander": { _man assignAsCommander _gun };
                            default { _man assignAsTurret [_gun, _path] };
                        };
                        [_man] orderGetIn true;
                    } forEach _orders;
                }] remoteExecCall ["call", leader _g];
            };
            case "patrol": {};
        };
        if (!_done) exitWith {};

        // the next step, or round again, or hold
        _idx = _idx + 1;
        if (_idx >= count _queue && {[_profile, "warRoomLoop", false] call ALiVE_fnc_hashGet} && {count _queue > 1}) then { _idx = 0 };
        [_profile, "warRoomQueueIdx", _idx] call ALiVE_fnc_hashSet;
        ["apply", _profile] call ALIVE_fnc_SCOMGroupOrderRun;
    };
};
