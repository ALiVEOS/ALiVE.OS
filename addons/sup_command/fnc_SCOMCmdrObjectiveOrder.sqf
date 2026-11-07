#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMCmdrObjectiveOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMCmdrObjectiveOrder

Description:
Objectives for a side's AI commander from outside the game, for example from the War Room's live map.
Server side, and only for code already running on the server: a call that arrives by remoteExec (from
any machine) is refused, so a client can't use it to direct a commander. The order goes to the side's
first commander with the same checks as the tablet's Operations tab (Player Objectives enabled, the
Maximum Player Objectives cap shared with the players, Dug In and asymmetric commanders, two recon /
search and destroy / ambush orders at a time, a free group). The cooldown is the tablet's, counted
for the side rather than for one player. Every call is logged with the name it was given.

Parameters:
String - the operation, then its own arguments:
    "add",    side, [x, y], intent ("take", "hold", "recon", "sad" or "ambush"), by (optional)
    "cancel", side, objective id, by (optional) - an objective set by a player or the War Room
    "raise",  side, objective id, by (optional) - moves it one place up the commander's list
    "list",   side
Side is "WEST", "EAST", "GUER" / "INDEPENDENT", or a side.

Returns:
"add":    [true, text, objective id] ("" for recon, sad and ambush, which are orders, not objectives)
"cancel": [true, text]
"raise":  [true, text]
"list":   [true, [[objective id, [x, y], intent, commander's state], ...]], the side's objectives set
          by players or the War Room, in the commander's order; intent is "" when none was given
On refusal: [false, reason] or, for a cooldown, [false, "cooldown", seconds left]. The reasons:
"refused" (remoteExec'd or not the server), "badargs", "disabled" (no Player Command module or
Player Objectives off), "nocommander", "quota", "cooldown", "dugin", "asym", "busy" (two orders
already out), "nogroup", "notready" (the commander couldn't take the order just then), "gone" (no
such objective), "notplayer" (an objective the commander set itself)

Examples:
(begin example)
private _r = ["add", "WEST", [3200, 5800], "take", "War Room (Jman)"] call ALIVE_fnc_SCOMCmdrObjectiveOrder;
private _list = ["list", "WEST"] call ALIVE_fnc_SCOMCmdrObjectiveOrder;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith { [false, "refused"] };
if (isRemoteExecuted) exitWith {
    ["ALiVE SCOM - War Room objective order: refused a call sent by remoteExec from machine %1", remoteExecutedOwner] call ALiVE_fnc_dump;
    [false, "refused"]
};
private _say = { ["ALiVE SCOM - War Room objective order: %1", _this] call ALiVE_fnc_dump };
if !(_this isEqualType [] && {count _this >= 2}) exitWith { "refused a call that is not [operation, side, ...]" call _say; [false, "badargs"] };
_this params [["_op", "", [""]], ["_side", "", ["", west]]];
_op = toLower _op;
if !(_op in ["add", "cancel", "raise", "list"]) exitWith { format ["refused an unknown operation %1", _op] call _say; [false, "badargs"] };

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

// the side's commanders, in the order the tablet and the map markers find them
private _opcoms = (missionNamespace getVariable ["OPCOM_instances", []]) select { ([_x, "side", ""] call ALiVE_fnc_hashGet) == _sideText };

if (_op == "list") exitWith {
    private _rows = [];
    {
        {
            if ([_x, "playerCreated", false] call ALiVE_fnc_hashGet) then {
                private _c = [_x, "center", [0, 0, 0]] call ALiVE_fnc_hashGet;
                _rows pushBack [
                    [_x, "objectiveID", ""] call ALiVE_fnc_hashGet,
                    [_c select 0, _c select 1],
                    [_x, "playerIntent", ""] call ALiVE_fnc_hashGet,
                    [_x, "opcom_state", ""] call ALiVE_fnc_hashGet
                ];
            };
        } forEach ([_x, "objectives", []] call ALiVE_fnc_hashGet);
    } forEach _opcoms;
    [true, _rows]
};

private _h = missionNamespace getVariable "ALIVE_commandHandler";
if (isNil "_h" || {!([_h, "playerObjectivesEnabled", false] call ALiVE_fnc_hashGet)}) exitWith {
    format ["refused %1 for %2: Player Objectives are off or there is no Player Command module", _op, _sideText] call _say;
    [false, "disabled"]
};

if (_op == "add") exitWith {
    _this params ["", "", ["_pos", [], [[]]], ["_intent", "", [""]], ["_by", "", [""]]];
    if (_by == "") then { _by = "an order from outside the game" };
    _intent = toLower _intent;
    if !(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0}) exitWith { format ["refused %1: no usable grid", _by] call _say; [false, "badargs"] };
    if !(_intent in ["take", "hold", "recon", "sad", "ambush"]) exitWith { format ["refused %1: intent %2 isn't take, hold, recon, sad or ambush", _by, _intent] call _say; [false, "badargs"] };
    _pos = [_pos select 0, _pos select 1, 0];
    private _grid = mapGridPosition _pos;
    if (_opcoms isEqualTo []) exitWith { format ["%1 asked %2 to %3 %4: the side has no commander", _by, _sideText, _intent, _grid] call _say; [false, "nocommander"] };

    // in one go, as the map markers do, so two orders at once can't both pass the cooldown and the cap
    private _r = [];
    isNil { _r = [_h, "opsAddObjectiveFor", [_opcoms select 0, _pos, _intent, "WARROOM_" + _sideText]] call ALiVE_fnc_commandHandler };
    _r params ["_ok", "_code", "_text", ["_extra", ""]];
    format ["%1 asked %2 to %3 %4: %5", _by, _sideText, _intent, _grid, _text] call _say;
    if (!_ok) exitWith { if (_code == "cooldown") then { [false, _code, _extra] } else { [false, _code] } };
    [true, _text, _extra]
};

// cancel and raise: an objective of this side's, set by a player or the War Room
_this params ["", "", ["_objectiveID", "", [""]], ["_by", "", [""]]];
if (_by == "") then { _by = "an order from outside the game" };
if (_objectiveID == "") exitWith { format ["refused %1: no objective id", _by] call _say; [false, "badargs"] };
if (_opcoms isEqualTo []) exitWith { format ["%1 asked %2 to %3 %4: the side has no commander", _by, _sideText, _op, _objectiveID] call _say; [false, "nocommander"] };

private _i = _opcoms findIf { !isNil { [_x, "getObjectiveByID", _objectiveID] call ALiVE_fnc_OPCOM } };
if (_i < 0) exitWith { format ["%1 asked %2 to %3 %4: no such objective", _by, _sideText, _op, _objectiveID] call _say; [false, "gone"] };
private _opcom = _opcoms select _i;
private _objective = [_opcom, "getObjectiveByID", _objectiveID] call ALiVE_fnc_OPCOM;
if !([_objective, "playerCreated", false] call ALiVE_fnc_hashGet) exitWith {
    format ["%1 asked %2 to %3 %4: the commander set that one itself", _by, _sideText, _op, _objectiveID] call _say;
    [false, "notplayer"]
};

private _text = "";
isNil {
    if (_op == "cancel") then {
        [_opcom, "removeObjective", _objectiveID] call ALiVE_fnc_OPCOM;
        _text = "Objective cancelled";
    } else {
        // the index read here, as the tablet does: the commander reorders the list as it works
        private _objectives = [_opcom, "objectives", []] call ALiVE_fnc_hashGet;
        private _index = _objectives findIf { ([_x, "objectiveID", ""] call ALiVE_fnc_hashGet) == _objectiveID };
        [_opcom, "reorderObjective", [_objectiveID, (_index - 1) max 0]] call ALiVE_fnc_OPCOM;
        _text = format ["Objective raised to place %1", ((_index - 1) max 0) + 1];
    };
};
format ["%1 asked %2 to %3 %4: %5", _by, _sideText, _op, _objectiveID, _text] call _say;
[true, _text]
