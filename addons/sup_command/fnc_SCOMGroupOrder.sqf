#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMGroupOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMGroupOrder

Description:
Orders for one AI group from outside the game, for example from the War Room's live map: move it, stop
it, or lock and unlock it. Server side, and only for code already running on the server: a call that
arrives by remoteExec (from any machine) is refused. They act as the tablet's Operations tab does
(Apply waypoints, Clear and Lock): a group moved or stopped is taken from its AI Commander until it is
unlocked. A move or stop is refused for a locked group, which is one locked from the tablet or here,
or one something else in ALiVE is holding (an HVT's guards, for one), but a group already moved from
here can be moved again. A player's group is never ordered. Every call is logged with the name it was
given.

Parameters:
String - the group's profile id
String - "move", "stop", "lock" or "unlock"
Array - [x, y] for "move" (nil or [] otherwise)
String - who gave the order, for the log (optional)

Returns:
Array - [true, text] or [false, reason]. The reasons: "refused" (remoteExec'd or not the server),
"badargs", "gone" (no such profile), "notgroup" (a vehicle profile, not a group), "player" (a player's
group), "locked" (move or stop on a locked group)

Examples:
(begin example)
private _r = ["agent_42", "move", [3200, 5800], "War Room (Jman)"] call ALIVE_fnc_SCOMGroupOrder;
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
if !(_this isEqualType [] && {count _this in [2, 3, 4]}) exitWith { "refused a call that is not [profile id, operation, position]" call _say; [false, "badargs"] };
_this params [["_profileID", "", [""]], ["_op", "", [""]], ["_pos", [], [[]]], ["_by", "", [""]]];
_op = toLower _op;
if (_profileID == "" || {!(_op in ["move", "stop", "lock", "unlock"])}) exitWith { format ["refused %1 for %2", _op, _profileID] call _say; [false, "badargs"] };
if (_op == "move" && {!(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0})}) exitWith {
    format ["refused a move for %1 without a usable grid", _profileID] call _say; [false, "badargs"]
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

switch (_op) do {
    case "lock": {
        [_profile, "busy", true] call ALiVE_fnc_hashSet;
        [_profile, "warRoomOrdered", false] call ALiVE_fnc_hashSet;
        _text = "Group locked: the commander won't give it orders.";
    };
    case "unlock": {
        [_profile, "busy", false] call ALiVE_fnc_hashSet;
        [_profile, "warRoomOrdered", false] call ALiVE_fnc_hashSet;
        _text = "Group unlocked: the commander can give it orders again.";
    };
    default {
        if (_busy && {!_ours}) exitWith {};
        // as the tablet's Apply waypoints and Clear: held from the commander, then its waypoints replaced
        [_profile, "busy", true] call ALiVE_fnc_profileEntity;
        [_profile, "warRoomOrdered", true] call ALiVE_fnc_hashSet;
        [_profile, "clearWaypoints"] call ALiVE_fnc_profileEntity;
        if (_op == "move") then {
            [_profile, "addWaypoint", [[_pos select 0, _pos select 1, 0]] call ALiVE_fnc_createProfileWaypoint] call ALiVE_fnc_profileEntity;
            _text = format ["Group moving to grid %1. The commander leaves it alone until it is unlocked.", mapGridPosition _pos];
        } else {
            _text = "Group stopped. The commander leaves it alone until it is unlocked.";
        };
    };
};
if (_text == "") exitWith { format ["%1 asked to %2 %3: the group is locked", _by, _op, _profileID] call _say; [false, "locked"] };
format ["%1 asked to %2 %3: %4", _by, _op, _profileID, _text] call _say;
[true, _text]
