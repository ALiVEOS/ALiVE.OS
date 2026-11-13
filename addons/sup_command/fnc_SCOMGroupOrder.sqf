#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMGroupOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMGroupOrder

Description:
Orders for one AI group from outside the game, for example from the War Room's live map. Server side, and
only for code already running on the server: a call that arrives by remoteExec (from any machine) is
refused. They act as the tablet's Operations tab does (Apply waypoints, Clear and Lock): a group given an
order is taken from its AI Commander until it is unlocked or handed back. An order is refused for a
locked group, which is one locked from the tablet or here, or one something else in ALiVE is holding (an
HVT's guards, for one), but a group already ordered from here can be ordered again. A player's group is
never ordered. Every call is logged with the name it was given.

A move, attack, static, patrol, follow, retreat, defend or get in replaces the group's orders, or, sent
with append, is added to the end of its list (8 steps at most), which ALIVE_fnc_SCOMGroupOrderRun works
through. Which of the newer
operations this build takes is in ALIVE_SCOMGroupOrderOps.

Parameters:
String - the group's profile id
String - the operation:
    "move", "stop", "lock", "unlock"
    "attack" - search and destroy, following the target; extra [target profile id]
    "static" - its nearest men crew a static gun; extra [the gun's netId]
    "patrol" - a loop around a point; extra [radius in m] (150 if not given)
    "follow" - keeps with a friendly group (a player's too); extra [its profile id]
    "retreat" - falls back to a point at full speed, holding fire, then holds there
    "defend" - holds a point, its men in cover around it, until the next order; extra [radius in m] (100)
    "getin" - boards a vehicle within 500 m and keeps it for the next moves (a spawned group only); extra [its profile id]
    "qpos" - extra [step, x, y]: a step of a move, patrol, retreat or defend to a new place
    "clear" - the steps after the one it is on dropped and its stance its own again; still held
    "stance" - extra [rules of engagement, behaviour, speed], "" to keep one
    "handback" - off its gun, its orders and stance cleared, back to its commander
    "qdel" - extra [step], "qmove" - extra [from, to] (steps from 0), "qclear", "loop" - extra [true or false]
Array - [x, y] for move, attack, static, patrol, retreat and defend (nil or [] otherwise)
String - who gave the order, for the log (optional)
Array - extra, as above (optional)
Boolean - append: add a move, attack, static or patrol to the group's list (optional, default false)

Returns:
Array - [true, text] or [false, reason]. The reasons: "refused" (remoteExec'd or not the server),
"badargs", "gone" (no such profile, or no such target), "notgroup" (a vehicle profile, not a group),
"player" (a player's group), "locked" (an order to a locked group), "notheld" (stance, list or hand
back for a group the War Room doesn't hold), "friendly" (an attack on a friendly group), "playertarget"
(an attack on a player's group), "nostatic" (no such gun), "manned" (a gun already crewed), "noloop" (a
loop with steps other than moves and patrols), "queuefull" (8 steps already), "badindex" (no such step),
"self" (a group told to follow itself), "notfriendly" (following a group not friendly to it), "notspawned"
(get in for a group or a vehicle that isn't spawned), "novehicle" (no such vehicle, a destroyed one or a static gun),
"full" (no free seat), "hostile" (a vehicle crewed by another side), "far" (a vehicle over 500 m away),
"fixed" (a new place for a step whose place is its target's)

Examples:
(begin example)
private _r = ["agent_42", "move", [3200, 5800], "War Room (Jman)"] call ALIVE_fnc_SCOMGroupOrder;
private _r = ["agent_42", "attack", [3400, 6100], "War Room (Jman)", ["agent_77"], true] call ALIVE_fnc_SCOMGroupOrder;
private _r = ["agent_42", "unlock", nil, "War Room (Jman)"] call ALIVE_fnc_SCOMGroupOrder;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith { [false, "refused"] };
if (isRemoteExecuted) exitWith {
    ["ALiVE SCOM - War Room group order: refused a call sent by remoteExec from machine %1", remoteExecutedOwner] call ALiVE_fnc_dump;
    [false, "refused"]
};
private _say = { ["ALiVE SCOM - War Room group order: %1", _this] call ALiVE_fnc_dump };
if !(_this isEqualType [] && {count _this in [2, 3, 4, 5, 6]}) exitWith { "refused a call that is not [profile id, operation, position]" call _say; [false, "badargs"] };
_this params [["_profileID", "", [""]], ["_op", "", [""]], ["_pos", [], [[]]], ["_by", "", [""]], ["_extra", [], [[]]], ["_append", false, [false]]];
_op = toLower _op;
if (_profileID == "" || {!(_op in ["move", "stop", "lock", "unlock", "attack", "static", "patrol", "stance", "handback", "qdel", "qmove", "qclear", "loop", "follow", "retreat", "defend", "getin", "qpos", "clear"])}) exitWith { format ["refused %1 for %2", _op, _profileID] call _say; [false, "badargs"] };
if (_op in ["move", "attack", "static", "patrol", "retreat", "defend"] && {!(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0})}) exitWith {
    format ["refused %1 for %2 without a usable grid", _op, _profileID] call _say; [false, "badargs"]
};
if (_by == "") then { _by = "an order from outside the game" };
if (isNil "ALiVE_profileHandler") exitWith { format ["%1 asked to %2 %3: no profiles in this mission", _by, _op, _profileID] call _say; [false, "gone"] };

private _profile = [ALiVE_profileHandler, "getProfile", _profileID] call ALiVE_fnc_profileHandler;
if (isNil "_profile") exitWith { format ["%1 asked to %2 %3: no such group", _by, _op, _profileID] call _say; [false, "gone"] };
if (((_profile select 2) param [5, ""]) != "entity") exitWith { format ["%1 asked to %2 %3: not a group", _by, _op, _profileID] call _say; [false, "notgroup"] };
if ((_profile select 2) param [30, false]) exitWith { format ["%1 asked to %2 %3: a player's group", _by, _op, _profileID] call _say; [false, "player"] };

private _busy = [_profile, "busy", false] call ALiVE_fnc_hashGet;
private _ours = [_profile, "warRoomOrdered", false] call ALiVE_fnc_hashGet;
private _text = "";
private _code = "locked";
private _queue = +([_profile, "warRoomQueue", []] call ALiVE_fnc_hashGet);
private _idx = [_profile, "warRoomQueueIdx", 0] call ALiVE_fnc_hashGet;

// held from the commander, as the tablet's Apply waypoints and Clear
private _fnc_take = {
    [_profile, "busy", true] call ALiVE_fnc_profileEntity;
    [_profile, "warRoomOrdered", true] call ALiVE_fnc_hashSet;
    // The commander lets go too. A group still in an objective's section was given that objective's
    // orders again at the next cycle, which overwrote the War Room's move.
    {
        if (_x isEqualType []) then { [_x, "resetProfileOrders", _profileID] call ALiVE_fnc_OPCOM };
    } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
    // and the commands the commander gave it go too: a garrison holds a spawned group's men on their posts,
    // so a moved group never left, and the reset above sets a group with no commands wandering. A stop
    // keeps a garrison, whose men are already staying put.
    private _commands = [_profile, "activeCommands", []] call ALiVE_fnc_hashGet;
    if (_commands isNotEqualTo [] && {_op != "stop" || {(_commands findIf { toLower (_x param [0, ""]) != "alive_fnc_garrison" }) != -1}}) then {
        [_profile, "clearActiveCommands"] call ALiVE_fnc_profileEntity;
    };
};
// the list as it now is, and the step the group is on started (ALIVE_fnc_SCOMGroupOrderRun)
private _fnc_run = {
    [_profile, "warRoomQueue", _queue] call ALiVE_fnc_hashSet;
    [_profile, "warRoomQueueIdx", _idx] call ALiVE_fnc_hashSet;
    if (_queue isEqualTo [] || {(_queue findIf { !((_x select 0) in ["move", "patrol"]) }) != -1}) then { [_profile, "warRoomLoop", false] call ALiVE_fnc_hashSet };
    ["apply", _profile] call ALIVE_fnc_SCOMGroupOrderRun;
};
private _grid = if (count _pos >= 2) then { mapGridPosition _pos } else { "" };

switch (_op) do {
    case "lock": {
        [_profile, "busy", true] call ALiVE_fnc_hashSet;
        [_profile, "warRoomOrdered", false] call ALiVE_fnc_hashSet;
        [_profile, "warRoomLocked", true] call ALiVE_fnc_hashSet;
        _text = "Group locked: the commander won't give it orders.";
    };
    case "unlock": {
        [_profile, "busy", false] call ALiVE_fnc_hashSet;
        [_profile, "warRoomOrdered", false] call ALiVE_fnc_hashSet;
        [_profile, "warRoomLocked", false] call ALiVE_fnc_hashSet;
        _text = "Group unlocked: the commander can give it orders again.";
    };
    // off its gun, its list and stance gone, and back to its commander
    case "handback": {
        if (!_ours && {!([_profile, "warRoomLocked", false] call ALiVE_fnc_hashGet)}) exitWith { _code = "notheld" };
        ["dismount", _profile] call ALIVE_fnc_SCOMGroupOrderRun;
        ["release", _profileID] call ALIVE_fnc_SCOMGroupOrderRun;
        {
            [_profile, _x select 0, _x select 1] call ALiVE_fnc_hashSet;
        } forEach [["warRoomQueue", []], ["warRoomQueueIdx", 0], ["warRoomLoop", false], ["warRoomStance", ["", "", ""]],
            ["busy", false], ["warRoomOrdered", false], ["warRoomLocked", false]];
        _text = "Group handed back to its commander.";
    };
    case "stance": {
        if (!_ours) exitWith { _code = "notheld" };
        private _now = ([_profile, "warRoomStance", []] call ALiVE_fnc_hashGet) + ["", "", ""];
        private _stance = [0, 1, 2] apply {
            private _v = _extra param [_x, ""];
            if (_v isEqualType "" && {_v != ""}) then { toUpper _v } else { _now select _x }
        };
        [_profile, "warRoomStance", _stance] call ALiVE_fnc_hashSet;
        // a spawned group takes it now; the step it is on is given again with it in its waypoints
        private _g = [_profile, "group", grpNull] call ALiVE_fnc_hashGet;
        if ([_profile, "active", false] call ALiVE_fnc_hashGet && {_g isEqualType grpNull} && {!isNull _g}) then {
            [[_g, _stance], {
                params ["_g", "_stance"];
                _stance params ["_roe", "_beh", "_speed"];
                if (_roe != "") then { _g setCombatMode _roe };
                if (_beh != "") then { _g setBehaviour _beh };
                if (_speed != "") then { _g setSpeedMode _speed };
            }] remoteExecCall ["call", leader _g];
        };
        if (_idx < count _queue) then { call _fnc_run };
        _text = format ["Group's stance set: %1.", (_stance select { _x != "" }) joinString ", "];
    };
    case "qclear": {
        if (!_ours) exitWith { _code = "notheld" };
        _queue = [];
        _idx = 0;
        call _fnc_run;
        _text = "Group's orders cleared: it holds where it is.";
    };
    case "qdel": {
        if (!_ours) exitWith { _code = "notheld" };
        private _i = _extra param [0, -1];
        if !(_i isEqualType 0 && {_i >= 0} && {_i < count _queue}) exitWith { _code = "badindex" };
        _queue deleteAt _i;
        if (_i < _idx) then { _idx = _idx - 1 };
        // taking off the step it is on starts the next one
        if (_i == _idx) then { call _fnc_run } else {
            [_profile, "warRoomQueue", _queue] call ALiVE_fnc_hashSet;
            [_profile, "warRoomQueueIdx", _idx] call ALiVE_fnc_hashSet;
        };
        _text = format ["Step %1 taken off the group's orders.", _i + 1];
    };
    case "qmove": {
        if (!_ours) exitWith { _code = "notheld" };
        _extra params [["_from", -1], ["_to", -1]];
        if !(_from isEqualType 0 && {_to isEqualType 0} && {_from >= 0} && {_to >= 0} && {_from < count _queue} && {_to < count _queue}) exitWith { _code = "badindex" };
        private _current = if (_idx < count _queue) then { _queue select _idx } else { [] };
        private _moved = _queue deleteAt _from;
        _queue insert [_to, [_moved]];
        // the group carries on with the step it is on, wherever that is now in the list
        if (_current isNotEqualTo []) then { _idx = _queue find _current };
        [_profile, "warRoomQueue", _queue] call ALiVE_fnc_hashSet;
        [_profile, "warRoomQueueIdx", _idx] call ALiVE_fnc_hashSet;
        _text = format ["Step %1 moved to %2.", _from + 1, _to + 1];
    };
    // a step with a place of its own to a new place (dragged on the map); the step it is on goes there now
    case "qpos": {
        if (!_ours) exitWith { _code = "notheld" };
        _extra params [["_i", -1], ["_nx", nil], ["_ny", nil]];
        if !(_i isEqualType 0 && {_i >= 0} && {_i < count _queue}) exitWith { _code = "badindex" };
        if !(!isNil "_nx" && {!isNil "_ny"} && {_nx isEqualType 0} && {_ny isEqualType 0} && {finite _nx} && {finite _ny}) exitWith { _code = "badargs" };
        private _step = _queue select _i;
        if !((_step select 0) in ["move", "patrol", "retreat", "defend"]) exitWith { _code = "fixed" };
        _step set [1, _nx];
        _step set [2, _ny];
        if (_i == _idx) then { call _fnc_run } else { [_profile, "warRoomQueue", _queue] call ALiVE_fnc_hashSet };
        _text = format ["Step %1 moved to grid %2.", _i + 1, mapGridPosition [_nx, _ny]];
    };
    // the Clear button: what comes after the step it is on goes, and its stance is its own again
    case "clear": {
        if (!_ours) exitWith { _code = "notheld" };
        _queue = if (_idx < count _queue) then { _queue select [0, _idx + 1] } else { [] };
        [_profile, "warRoomStance", ["", "", ""]] call ALiVE_fnc_hashSet;
        [_profile, "warRoomQueue", _queue] call ALiVE_fnc_hashSet;
        if (_idx < count _queue) then { call _fnc_run };
        _text = "Group's later orders and stance cleared. The commander still leaves it alone until it is unlocked.";
    };
    case "loop": {
        if (!_ours) exitWith { _code = "notheld" };
        private _on = _extra param [0, false];
        if !(_on isEqualType true) exitWith { _code = "badargs" };
        if (_on && {_queue isEqualTo [] || {(_queue findIf { !((_x select 0) in ["move", "patrol"]) }) != -1}}) exitWith { _code = "noloop" };
        [_profile, "warRoomLoop", _on] call ALiVE_fnc_hashSet;
        // a list already done starts again from the top
        if (_on && {_idx >= count _queue}) then { _idx = 0; call _fnc_run };
        _text = if (_on) then { "Group's orders loop." } else { "Group's orders stop after the last step." };
    };
    default {
        if (_busy && {!_ours}) exitWith {};
        // the step, checked before anything changes
        private _step = [];
        switch (_op) do {
            case "move": { _step = ["move", _pos select 0, _pos select 1, ""] };
            case "patrol": {
                private _r = _extra param [0, 150];
                if !(_r isEqualType 0 && {finite _r} && {_r > 0}) then { _r = 150 };
                _step = ["patrol", _pos select 0, _pos select 1, (_r max 25) min 2000];
            };
            case "attack": {
                private _tid = _extra param [0, ""];
                private _target = if (_tid isEqualType "" && {_tid != ""}) then { [ALiVE_profileHandler, "getProfile", _tid] call ALiVE_fnc_profileHandler } else { nil };
                if (isNil "_target") exitWith { _code = "gone" };
                if ((_target select 2) param [30, false]) exitWith { _code = "playertarget" };
                private _sides = [_profile, _target] apply { [(_x select 2) param [3, "CIV"]] call ALiVE_fnc_sideTextToObject };
                if (((_sides select 0) getFriend (_sides select 1)) >= 0.6) exitWith { _code = "friendly" };
                private _at = [_target, "position", _pos] call ALiVE_fnc_hashGet;
                _step = ["attack", _at select 0, _at select 1, _tid];
            };
            case "static": {
                private _gun = objectFromNetId (_extra param [0, ""]);
                if (isNull _gun || {!alive _gun} || {!(_gun isKindOf "StaticWeapon")}) exitWith { _code = "nostatic" };
                if (((crew _gun) select { alive _x }) isNotEqualTo []) exitWith { _code = "manned" };
                _step = ["static", (getPosATL _gun) select 0, (getPosATL _gun) select 1, netId _gun];
            };
            case "follow": {
                private _tid = _extra param [0, ""];
                if (_tid isEqualType "" && {_tid == _profileID}) exitWith { _code = "self" };
                private _friend = if (_tid isEqualType "" && {_tid != ""}) then { [ALiVE_profileHandler, "getProfile", _tid] call ALiVE_fnc_profileHandler } else { nil };
                if (isNil "_friend" || {((_friend select 2) param [5, ""]) != "entity"}) exitWith { _code = "gone" };
                private _sides = [_profile, _friend] apply { [(_x select 2) param [3, "CIV"]] call ALiVE_fnc_sideTextToObject };
                if (((_sides select 0) getFriend (_sides select 1)) < 0.6) exitWith { _code = "notfriendly" };
                private _at = [_friend, "position", [0, 0, 0]] call ALiVE_fnc_hashGet;
                _step = ["follow", _at select 0, _at select 1, _tid];
            };
            case "retreat": { _step = ["retreat", _pos select 0, _pos select 1, ""] };
            case "defend": {
                private _r = _extra param [0, 100];
                if !(_r isEqualType 0 && {finite _r} && {_r > 0}) then { _r = 100 };
                _step = ["defend", _pos select 0, _pos select 1, (_r max 25) min 500];
            };
            case "getin": {
                private _g = [_profile, "group", grpNull] call ALiVE_fnc_hashGet;
                if !([_profile, "active", false] call ALiVE_fnc_hashGet && {_g isEqualType grpNull} && {!isNull _g}) exitWith { _code = "notspawned" };
                private _vid = _extra param [0, ""];
                private _vp = if (_vid isEqualType "" && {_vid != ""}) then { [ALiVE_profileHandler, "getProfile", _vid] call ALiVE_fnc_profileHandler } else { nil };
                if (isNil "_vp" || {((_vp select 2) param [5, ""]) != "vehicle"}) exitWith { _code = "novehicle" };
                private _veh = [_vp, "vehicle", objNull] call ALiVE_fnc_hashGet;
                if !([_vp, "active", false] call ALiVE_fnc_hashGet && {_veh isEqualType objNull} && {!isNull _veh}) exitWith { _code = "notspawned" };
                if (isNull _veh || {!alive _veh} || {_veh isKindOf "StaticWeapon"} || {_veh isKindOf "Man"} || {!(_veh isKindOf "AllVehicles")}) exitWith { _code = "novehicle" };
                private _crew = (crew _veh) select { alive _x && {!(_x in units _g)} };
                if (_crew isNotEqualTo [] && {((side group (_crew select 0)) getFriend (side _g)) < 0.6}) exitWith { _code = "hostile" };
                if ((_veh distance2D (leader _g)) > 500) exitWith { _code = "far" };
                if (((fullCrew [_veh, "", true]) findIf { isNull (_x select 0) }) < 0) exitWith { _code = "full" };
                _step = ["getin", (getPosATL _veh) select 0, (getPosATL _veh) select 1, _vid];
            };
        };
        if (_op != "stop" && {_step isEqualTo []}) exitWith {};

        // added to the list of a group already the War Room's
        if (_append && {_ours} && {_op != "stop"}) exitWith {
            if (count _queue >= 8) exitWith { _code = "queuefull" };
            _queue pushBack _step;
            [_profile, "warRoomQueue", _queue] call ALiVE_fnc_hashSet;
            // a list already done goes on with the new step
            if (_idx >= count _queue - 1) then { _idx = count _queue - 1; call _fnc_run };
            _text = format ["Step %1 added to the group's orders.", count _queue];
        };

        call _fnc_take;
        _queue = if (_op == "stop") then { [] } else { [_step] };
        _idx = 0;
        call _fnc_run;
        _text = switch (_op) do {
            case "move": { format ["Group moving to grid %1. The commander leaves it alone until it is unlocked.", _grid] };
            case "stop": { "Group stopped. The commander leaves it alone until it is unlocked." };
            case "attack": { format ["Group attacking the group at grid %1. The commander leaves it alone until it is unlocked.", mapGridPosition [_step select 1, _step select 2]] };
            case "static": { format ["Group manning the gun at grid %1. The commander leaves it alone until it is unlocked.", _grid] };
            case "patrol": { format ["Group patrolling %1 m around grid %2. The commander leaves it alone until it is unlocked.", _step select 3, _grid] };
            case "follow": { "Group following the group chosen. The commander leaves it alone until it is unlocked." };
            case "retreat": { format ["Group falling back to grid %1. The commander leaves it alone until it is unlocked.", _grid] };
            case "defend": { format ["Group defending grid %1. The commander leaves it alone until it is unlocked.", _grid] };
            case "getin": { format ["Group boarding the vehicle at grid %1. The commander leaves it alone until it is unlocked.", mapGridPosition [_step select 1, _step select 2]] };
        };
    };
};
if (_text == "") exitWith { format ["%1 asked to %2 %3: refused (%4)", _by, _op, _profileID, _code] call _say; [false, _code] };
format ["%1 asked to %2 %3: %4", _by, _op, _profileID, _text] call _say;
[true, _text]
