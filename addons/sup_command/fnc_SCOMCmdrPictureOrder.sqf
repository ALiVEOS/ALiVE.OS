#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMCmdrPictureOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMCmdrPictureOrder

Description:
The Commander's Picture orders (Go now, Look again, Strike) from outside the game, for example from the War
Room's live map. Server side, and only for code already running on the server: a call that arrives by
remoteExec (from any machine) is refused. The same checks as the tablet's buttons: the objective must be
one a commander of the side is finding out about (Find Out Before Attacking), Go and Look only while it
still is, Strike until it is taken and only with enemy vehicles known there and an air commander to ask.
One order a minute per objective, and one every two minutes for the side's War Room orders. The tablet's
Commander's Picture setting and its Ops limit don't apply here. Every call is logged with the name it was given.

Parameters:
String or Side - "WEST", "EAST", "GUER" / "INDEPENDENT", or a side
String or Array - an objective id, or a position [x, y]: the nearest objective being found out about,
                  within 500 m
String - "go", "look" or "strike"
String - who gave the order, for the radio and the log (optional)

Returns:
Array - [true, text] or [false, reason], or [false, reason, seconds left] for "objwait" and "callerwait".
The reasons: "refused" (remoteExec'd or not the server), "badargs", "nocommander" (no commander of the side
is finding out first), "gone" (no such objective being found out about), "attackin" (the attack has gone
in, so Go and Look no longer apply), "notattacking" (Strike: the commander has stopped attacking it),
"novehicles", "noair", "looked" (Look again already used twice there), "objwait" (an order on that
objective under a minute ago), "callerwait" (the side's last War Room order under two minutes ago),
"notready" (the commander couldn't take the order just then)

Examples:
(begin example)
private _r = ["WEST", "OPCOM_1_objective_3", "go", "War Room (Jman)"] call ALIVE_fnc_SCOMCmdrPictureOrder;
private _r = ["WEST", [3200, 5800], "look", "War Room (Jman)"] call ALIVE_fnc_SCOMCmdrPictureOrder;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith { [false, "refused"] };
if (isRemoteExecuted) exitWith {
    ["ALiVE SCOM - War Room picture order: refused a call sent by remoteExec from machine %1", remoteExecutedOwner] call ALiVE_fnc_dump;
    [false, "refused"]
};
private _say = { ["ALiVE SCOM - War Room picture order: %1", _this] call ALiVE_fnc_dump };
if !(_this isEqualType [] && {count _this in [3, 4]}) exitWith { "refused a call that is not [side, objective, action]" call _say; [false, "badargs"] };
_this params [["_side", "", ["", west]], ["_target", "", ["", []]], ["_kind", "", [""]], ["_by", "", [""]]];

private _sideText = if (_side isEqualType "") then {
    switch (toUpper _side) do {
        case "WEST": {"WEST"};
        case "EAST": {"EAST"};
        case "GUER";
        case "INDEPENDENT";
        case "RESISTANCE": {"GUER"};
        default {""};
    }
} else {
    switch (_side) do { case west: {"WEST"}; case east: {"EAST"}; case resistance: {"GUER"}; default {""} }
};
if (_sideText == "") exitWith { "refused an order without a usable side" call _say; [false, "badargs"] };
_kind = toUpper _kind;
if !(_kind in ["GO", "LOOK", "STRIKE"]) exitWith { format ["refused action %1", _kind] call _say; [false, "badargs"] };
if (_target isEqualType [] && {!(count _target in [2, 3] && {(_target findIf { !(_x isEqualType 0) || {!finite _x} }) < 0})}) exitWith {
    "refused an order without a usable grid" call _say; [false, "badargs"]
};
if (_target isEqualTo "") exitWith { "refused an order without an objective" call _say; [false, "badargs"] };
if (_by == "") then { _by = "an order from outside the game" };

private _opcoms = (missionNamespace getVariable ["OPCOM_instances", []]) select {
    ([_x, "side", ""] call ALiVE_fnc_hashGet) == _sideText && {[_x, "intelCycle", false] call ALiVE_fnc_hashGet}
};
if (_opcoms isEqualTo []) exitWith { format ["%1 asked %2 for %3: no commander of the side finds out first", _by, _sideText, _kind] call _say; [false, "nocommander"] };

// a position: the nearest objective one of them is finding out about
private _oid = _target;
if (_target isEqualType []) then {
    _oid = "";
    private _best = 500;
    {
        {
            if (!isNil { [_x, "intel"] call ALiVE_fnc_hashGet }) then {
                private _d = ([_x, "center", [0, 0, 0]] call ALiVE_fnc_hashGet) distance2D _target;
                if (_d < _best) then { _best = _d; _oid = [_x, "objectiveID", ""] call ALiVE_fnc_hashGet };
            };
        } forEach ([_x, "objectives", []] call ALiVE_fnc_hashGet);
    } forEach _opcoms;
};
private _what = if (_target isEqualType []) then { format ["grid %1", mapGridPosition _target] } else { _target };
if (_oid == "") exitWith { format ["%1 asked %2 for %3 at %4: no objective being found out about within 500 m", _by, _sideText, _kind, _what] call _say; [false, "gone"] };

private _h = missionNamespace getVariable "ALIVE_commandHandler";
// the order needs no Player Command module: without one, a handler of its own for this call
if (isNil "_h") then { _h = [nil, "create"] call ALIVE_fnc_commandHandler };
private _r = [];
isNil { _r = [_h, "intelOrderFor", [_opcoms, _kind, _oid, _by, "WARROOM_" + _sideText, objNull, _sideText]] call ALiVE_fnc_commandHandler };
if !(_r isEqualType [] && {count _r >= 3}) exitWith { format ["%1 asked %2 for %3 on %4: the commander couldn't take it", _by, _sideText, _kind, _oid] call _say; [false, "notready"] };
_r params ["_ok", "_code", "_text", ["_left", 0]];
format ["%1 asked %2 for %3 on %4: %5", _by, _sideText, _kind, _oid, _text] call _say;
if (_ok) exitWith { [true, _text] };
if (_code in ["objwait", "callerwait"]) exitWith { [false, _code, _left] };
[false, _code]
