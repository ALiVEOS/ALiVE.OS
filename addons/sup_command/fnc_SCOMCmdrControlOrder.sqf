#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMCmdrControlOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMCmdrControlOrder

Description:
The AI Commander's controls from outside the game, for example from the War Room: Go for a mission held
until Go, a change of stance, and pause or resume. Server side, and only for code already running on the
server: a call that arrives by remoteExec (from any machine) is refused. They act as the tablet's Commander
settings do (intelControl) on every commander of the side; the tablet's Commander's Picture, Ops limit and
Commander Controls settings don't apply here, but a stance change still needs the mission maker's Player
OPCOM Stance Control. One order every 2 s per side. Every call is logged with the name it was given.

Parameters:
String or Side - "WEST", "EAST", "GUER" / "INDEPENDENT", or a side
String - "go", "stance" or "pause"
Any - the value: nothing for "go" (Go starts every commander holding, whatever its side, as in game);
      "invasion", "occupation", "asymmetric", "dugin" or "assault" for "stance"; true to pause or
      false to resume for "pause"
String - who gave the order, for the radio and the log (optional)

Returns:
Array - [true, text, commanders changed] or [false, reason]. The reasons: "refused" (remoteExec'd or not
the server), "badargs", "busy" (the side's last order under 2 s ago), "nocommander", "notholding" (Go
with no commander holding), "holding" (pause or stance while the commander is held until Go),
"nostance" (the mission maker hasn't allowed stance changes), "starting" (the commander is still
starting), "changing" (a stance change is already going on), "already" (every commander is already so)

Examples:
(begin example)
private _r = ["WEST", "go", nil, "War Room (Jman)"] call ALIVE_fnc_SCOMCmdrControlOrder;
private _r = ["EAST", "stance", "dugin", "War Room (Jman)"] call ALIVE_fnc_SCOMCmdrControlOrder;
private _r = ["EAST", "pause", true, "War Room (Jman)"] call ALIVE_fnc_SCOMCmdrControlOrder;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith { [false, "refused"] };
if (isRemoteExecuted) exitWith {
    ["ALiVE SCOM - War Room commander control: refused a call sent by remoteExec from machine %1", remoteExecutedOwner] call ALiVE_fnc_dump;
    [false, "refused"]
};
private _say = { ["ALiVE SCOM - War Room commander control: %1", _this] call ALiVE_fnc_dump };
if !(_this isEqualType [] && {count _this in [2, 3, 4]}) exitWith { "refused a call that is not [side, operation, value]" call _say; [false, "badargs"] };
_this params [["_side", "", ["", west]], ["_op", "", [""]], "_value", ["_by", "", [""]]];

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
_op = toLower _op;
if !(_op in ["go", "stance", "pause"]) exitWith { format ["refused operation %1", _op] call _say; [false, "badargs"] };
if (_op == "stance" && {!(!isNil "_value" && {_value isEqualType ""} && {(toLower _value) in ["invasion", "occupation", "asymmetric", "dugin", "assault"]})}) exitWith {
    format ["refused stance %1", if (isNil "_value") then {"none"} else {_value}] call _say; [false, "badargs"]
};
if (_op == "pause" && {isNil "_value" || {!(_value isEqualType true)}}) exitWith { "refused pause without true or false" call _say; [false, "badargs"] };
if (_by == "") then { _by = "an order from outside the game" };

// one order every 2 s per side, as the tablet allows a player
if (isNil "ALiVE_SCOM_cmdrControlLast") then { ALiVE_SCOM_cmdrControlLast = createHashMap };
if (time - (ALiVE_SCOM_cmdrControlLast getOrDefault [_sideText, -100]) < 2) exitWith { format ["refused %1: the side's last order was under 2 s ago", _by] call _say; [false, "busy"] };
ALiVE_SCOM_cmdrControlLast set [_sideText, time];

private _opcoms = (missionNamespace getVariable ["OPCOM_instances", []]) select { ([_x, "side", ""] call ALiVE_fnc_hashGet) == _sideText };

if (_op == "go") exitWith {
    if (((missionNamespace getVariable ["OPCOM_instances", []]) findIf { [_x, "startPaused", false] call ALiVE_fnc_hashGet }) < 0) exitWith {
        format ["%1 gave Go: no commander is holding", _by] call _say; [false, "notholding"]
    };
    private _n = [nil, "go", _by] call ALiVE_fnc_OPCOM;
    format ["%1 gave Go: %2 commanders start", _by, _n] call _say;
    [true, format ["The war has started. Go given by %1.", _by], _n]
};

if (_opcoms isEqualTo []) exitWith { format ["%1 asked %2 to %3: the side has no commander", _by, _sideText, _op] call _say; [false, "nocommander"] };
if ((_opcoms findIf { [_x, "startPaused", false] call ALiVE_fnc_hashGet }) >= 0) exitWith {
    format ["%1 asked %2 to %3: held until Go", _by, _sideText, _op] call _say; [false, "holding"]
};
if ((_opcoms findIf { [_x, "stanceChangeInProgress", false] call ALiVE_fnc_hashGet }) >= 0) exitWith {
    format ["%1 asked %2 to %3: a stance change is going on", _by, _sideText, _op] call _say; [false, "changing"]
};

if (_op == "pause") exitWith {
    private _todo = _opcoms select { !(([_x, "pause", false] call ALiVE_fnc_hashGet) isEqualTo _value) };
    if (_todo isEqualTo []) exitWith { format ["%1 asked %2 to %3: already so", _by, _sideText, ["resume", "pause"] select _value] call _say; [false, "already"] };
    {
        // the pause waits for the commander to finish starting, so it runs scheduled
        [_x, _value] spawn { params ["_o", "_v"]; [_o, "pause", _v] call ALiVE_fnc_OPCOM };
    } forEach _todo;
    private _text = ["Commander resumed.", "Commander paused. Groups already moving carry on."] select _value;
    format ["%1 %2 %3 %4 commanders", _by, ["resumed", "paused"] select _value, count _todo, _sideText] call _say;
    [true, _text, count _todo]
};

// stance
if !(missionNamespace getVariable ["ALIVE_OPCOM_StanceControlEnabled", false]) exitWith {
    format ["%1 asked %2 for stance %3: the mission maker hasn't allowed stance changes", _by, _sideText, _value] call _say; [false, "nostance"]
};
_value = toLower _value;
if ((_opcoms findIf { !([_x, "startupComplete", false] call ALiVE_fnc_hashGet) }) >= 0) exitWith {
    format ["%1 asked %2 for stance %3: still starting", _by, _sideText, _value] call _say; [false, "starting"]
};
private _todo = _opcoms select { ([_x, "controltype", ""] call ALiVE_fnc_hashGet) != _value };
if (_todo isEqualTo []) exitWith { format ["%1 asked %2 for stance %3: already so", _by, _sideText, _value] call _say; [false, "already"] };
{
    // the same latch the C2ISTAR menu's stance change and the tablet use
    [_x, "stanceChangeInProgress", true] call ALiVE_fnc_hashSet;
    [_x, _value] spawn {
        params ["_o", "_v"];
        private _ALiVE_stanceCaller = true;
        [_o, "changeControlType", [_v]] call ALiVE_fnc_OPCOM;
        [_o, "stanceChangeInProgress", false] call ALiVE_fnc_hashSet;
    };
} forEach _todo;
format ["%1 set %2 %3 commanders to %4", _by, count _todo, _sideText, _value] call _say;
[true, "Changing stance. It takes about a minute.", count _todo]
