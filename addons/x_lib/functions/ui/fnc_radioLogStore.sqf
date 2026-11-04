#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(radioLogStore);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_radioLogStore

Description:
The server's copy of each side's Radio Log, so the page survives a reconnect and, with ALiVE Data, a
restart. A player's machine shows a message on its own Radio Log page (ALIVE_fnc_radioLog) and, for a
message the whole side hears, tells the server, which keeps it once however many players report it.
Messages to a group or a vehicle stay on the machines that heard them and are not kept here.

A player who joins asks for their side's log and gets it back on the page. ALiVE Data saves the
server's copy with the mission and hands it back here when the mission loads.

Each side keeps its last 100 messages, newest first, each as [number, "HH:MM", from, text, time]: the
number counts up across the mission and the saves, so the War Room can tell which lines it has
already had. Every new line also raises the server event "ALiVE_radioLogged" with [side, line].

A mission that limits remoteExec with CfgRemoteExec must allow ALIVE_fnc_radioLogStore.

Parameters:
    _this select 0: STRING - what to do
        "report"  (server, from a player's machine) [side, from, text]: a line the side heard; the player's own side only
        "record"  (server) [side, from, text]: keep a line the side heard
        "sync"    (server) []: send the asking player their side's log
        "save"    (server) []: the store as [[side, lines], ...], for ALiVE Data
        "restore" (server) [[side, lines], ...]: put a saved store back, behind any lines since
        "apply"   (player) [lines]: put the side's log on this player's page
        "line"    (any) [time, from, text]: the line as it reads on the page
        "draw"    (player) []: write the page from this machine's lines
    _this select 1: ARRAY - its arguments

Returns:
"save": ARRAY, "line": STRING, otherwise nothing

Examples:
(begin example)
["record", ["WEST", "HQ", "RODEO TWO on station."]] call ALIVE_fnc_radioLogStore;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_args", []]];

// A player's machine reports and asks ("report", "sync"); putting a saved log back, or a log on a page, is only
// taken from the server. (isRemoteExecuted holds for everything a remote call goes on to call, so it's only asked here,
// of the steps nothing on a player's machine calls on its own.)
if (isRemoteExecuted && {remoteExecutedOwner > 2} && {_op in ["restore", "apply"]}) exitWith {};

private _result = nil;

#define RADIOLOG_KEEP 100
#define RADIOLOG_SIDES ["WEST", "EAST", "GUER", "CIV"]

// the page text is structured text, so a < or & in a name is escaped
private _esc = { ((_this regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] };

switch (_op) do {

    case "report": {
        // from a player's machine: a player can only add to their own side's log
        if (!isServer) exitWith {};
        _args params [["_side", "", [""]], ["_from", "", [""]], ["_text", "", [""]]];
        private _caller = [remoteExecutedOwner, clientOwner] select (!isRemoteExecuted);
        private _unit = allPlayers select { owner _x == _caller } param [0, objNull];
        if (isNull _unit && {hasInterface}) then { _unit = player };
        if (isNull _unit || {str side group _unit != _side}) exitWith {};
        ["record", [_side, _from, _text]] call ALIVE_fnc_radioLogStore;
    };

    case "record": {
        if (!isServer) exitWith {};
        _args params [["_side", "", [""]], ["_from", "", [""]], ["_text", "", [""]]];
        if !(_side in RADIOLOG_SIDES) exitWith {};
        if (_text == "") exitWith {};
        _from = _from select [0, 64];
        _text = _text select [0, 512];

        if (isNil "ALiVE_radioLog_store") then { ALiVE_radioLog_store = createHashMap };
        if (isNil "ALiVE_radioLog_seq") then { ALiVE_radioLog_seq = 0 };
        private _lines = ALiVE_radioLog_store getOrDefault [_side, []];

        // every player on the side reports the line, a moment apart: it's kept once
        // (newest first, so the look stops at the first line older than 10 seconds)
        private _dup = false;
        {
            if (time - (_x select 4) >= 10) exitWith {};
            if ((_x select 2) == _from && {(_x select 3) == _text}) exitWith { _dup = true };
        } forEach _lines;
        if (_dup) exitWith {};

        ALiVE_radioLog_seq = ALiVE_radioLog_seq + 1;
        private _line = [ALiVE_radioLog_seq, [daytime, "HH:MM"] call BIS_fnc_timeToString, _from, _text, time];
        _lines insert [0, [_line]];
        if (count _lines > RADIOLOG_KEEP) then { _lines resize RADIOLOG_KEEP };
        ALiVE_radioLog_store set [_side, _lines];

        ["ALiVE_radioLogged", [_side, _line]] call CBA_fnc_localEvent;
    };

    case "sync": {
        if (!isServer) exitWith {};
        private _caller = [remoteExecutedOwner, clientOwner] select (!isRemoteExecuted);
        private _unit = allPlayers select { owner _x == _caller } param [0, objNull];
        if (isNull _unit && {hasInterface}) then { _unit = player };
        if (isNull _unit) exitWith {};
        // asked before ALiVE Data has put the saved log back: answered by "restore" as well
        if (isNil "ALiVE_radioLog_restored") then {
            if (isNil "ALiVE_radioLog_waiting") then { ALiVE_radioLog_waiting = [] };
            ALiVE_radioLog_waiting pushBackUnique _caller;
        };
        if (isNil "ALiVE_radioLog_store") exitWith {};
        private _lines = ALiVE_radioLog_store getOrDefault [str side group _unit, []];
        if (_lines isEqualTo []) exitWith {};
        if (local _unit) then { ["apply", [_lines]] call ALIVE_fnc_radioLogStore } else { ["apply", [_lines]] remoteExecCall ["ALIVE_fnc_radioLogStore", _caller] };
    };

    case "save": {
        // the time each line came in means nothing after a restart, so it isn't kept
        _result = [];
        if (isNil "ALiVE_radioLog_store") exitWith {};
        {
            private _lines = ALiVE_radioLog_store getOrDefault [_x, []];
            if (_lines isNotEqualTo []) then { _result pushBack [_x, _lines apply { _x select [0, 4] }] };
        } forEach RADIOLOG_SIDES;
    };

    case "restore": {
        if (!isServer || {!(_args isEqualType [])}) exitWith {};
        if (isNil "ALiVE_radioLog_store") then { ALiVE_radioLog_store = createHashMap };
        if (isNil "ALiVE_radioLog_seq") then { ALiVE_radioLog_seq = 0 };
        private _saved = [];
        private _top = 0;
        {
            _x params [["_side", "", [""]], ["_lines", [], [[]]]];
            if (_side in RADIOLOG_SIDES) then {
                private _ok = (_lines select { _x isEqualTypeParams [0, "", "", ""] }) apply { (_x select [0, 4]) + [-1e6] };
                { _top = _top max (_x select 0) } forEach _ok;
                _saved pushBack [_side, _ok];
            };
        } forEach _args;
        // anything said since the mission started stays on top, numbered after the saved lines so no number is used twice
        {
            { _x set [0, (_x select 0) + _top] } forEach _y;
        } forEach ALiVE_radioLog_store;
        ALiVE_radioLog_seq = ALiVE_radioLog_seq + _top;
        {
            _x params ["_side", "_ok"];
            private _lines = (ALiVE_radioLog_store getOrDefault [_side, []]) + _ok;
            if (count _lines > RADIOLOG_KEEP) then { _lines resize RADIOLOG_KEEP };
            ALiVE_radioLog_store set [_side, _lines];
        } forEach _saved;
        ALiVE_radioLog_restored = true;
        ["ALiVE Radio Log - restored %1", (RADIOLOG_SIDES apply { [_x, count (ALiVE_radioLog_store getOrDefault [_x, []])] }) select { (_x select 1) > 0 }] call ALiVE_fnc_dump;

        // the players already in the mission get their side's log, and so does anyone who asked before now
        private _owners = (allPlayers apply { owner _x }) + (missionNamespace getVariable ["ALiVE_radioLog_waiting", []]);
        ALiVE_radioLog_waiting = nil;
        {
            private _owner = _x;
            private _unit = allPlayers select { owner _x == _owner } param [0, objNull];
            if (isNull _unit && {hasInterface} && {_owner == clientOwner}) then { _unit = player };
            private _lines = if (isNull _unit) then { [] } else { ALiVE_radioLog_store getOrDefault [str side group _unit, []] };
            if (_lines isNotEqualTo []) then {
                if (local _unit) then { ["apply", [_lines]] call ALIVE_fnc_radioLogStore } else { ["apply", [_lines]] remoteExecCall ["ALIVE_fnc_radioLogStore", _owner] };
            };
        } forEach (_owners arrayIntersect _owners);
    };

    case "apply": {
        if (!hasInterface || {isNull player}) exitWith {};
        _args params [["_lines", [], [[]]]];
        private _from = (_lines select { _x isEqualTypeParams [0, "", "", ""] }) apply { ["line", [_x select 1, _x select 2, _x select 3]] call ALIVE_fnc_radioLogStore };
        if (_from isEqualTo []) exitWith {};
        if (isNil "ALiVE_radioLog_lines") then { ALiVE_radioLog_lines = [] };
        // what this machine already shows stays on top, with the side's lines it hasn't got after it
        private _have = ALiVE_radioLog_lines;
        ALiVE_radioLog_lines = (_have + (_from select { !(_x in _have) })) select [0, RADIOLOG_KEEP];
        ["draw"] call ALIVE_fnc_radioLogStore;
    };

    case "line": {
        _args params [["_time", "", [""]], ["_from", "", [""]], ["_text", "", [""]]];
        _result = if (_from == "") then {
            format ["<font color='#B4B4B4'>%1</font> %2", _time, _text call _esc]
        } else {
            format ["<font color='#B4B4B4'>%1</font> <font color='#E0C060'>%2:</font> %3", _time, _from call _esc, _text call _esc]
        }
    };

    case "draw": {
        if (!hasInterface || {isNull player}) exitWith {};
        if (isNil "ALiVE_radioLog_lines") exitWith {};
        if !(player diarySubjectExists "ALiVE_RadioLog") then {
            player createDiarySubject ["ALiVE_RadioLog", localize "STR_ALIVE_RADIO_LOG"];
        };
        // One entry holding the whole log, newest first, rather than an entry per message: the diary's list of entries is a
        // narrow column that cut every message short and ran off the bottom of the map screen, while an entry's own text has
        // a scroll bar.
        private _title = localize "STR_ALIVE_RADIO_LOG";
        private _body = ALiVE_radioLog_lines joinString "<br/>";
        // the entry belongs to the body that made it, so a respawned player gets a new one with the same lines
        private _record = missionNamespace getVariable ["ALiVE_radioLog_record", diaryRecordNull];
        if (isNull _record || {!(missionNamespace getVariable ["ALiVE_radioLog_owner", objNull] isEqualTo player)}) then {
            ALiVE_radioLog_record = player createDiaryRecord ["ALiVE_RadioLog", [_title, _body]];
            ALiVE_radioLog_owner = player;
        } else {
            player setDiaryRecordText [["ALiVE_RadioLog", _record], [_title, _body]];
        };
    };
};

// "save" and "line" answer; the others have nothing to hand back
if (isNil "_result") exitWith {};
_result
