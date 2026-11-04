#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(radioLog);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_radioLog

Description:
Keeps an ALiVE radio message on this player's Radio Log page in the map diary: one entry, newest
message first, each line with the in-game time and who sent it. Called on the machine that shows the message: by
ALIVE_fnc_radioBroadcast, by Combat Support's message broadcast and by ALIVE_fnc_taskSubtitle.
The entry holds the last 100 messages. The same line twice within 3 seconds is kept once.

A message the whole side hears is also kept by the server (ALIVE_fnc_radioLogStore), so a player who
joins later, or comes back after a restart of a persistent mission, gets the side's log back.

Parameters:
    _this select 0: STRING - who it is from ("HQ", a callsign, a task title)
    _this select 1: STRING - the message
    _this select 2: STRING - who heard it: "side" for the whole side, kept by the server; anything else
        (the default, for a group, a vehicle or this player alone) stays on this machine

Returns:
Nothing

Examples:
(begin example)
["HQ", "RODEO TWO on station.", "side"] call ALIVE_fnc_radioLog;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_from", ""], ["_text", ""], ["_heard", "", [""]]];
if (!hasInterface || {isNull player} || {!(_text isEqualType "")} || {_text == ""}) exitWith {};
if !(_from isEqualType "") then { _from = str _from };

// the same line can arrive by two routes a moment apart (a side message sent to every friendly side)
private _last = missionNamespace getVariable ["ALiVE_radioLog_last", ["", -10]];
if ((_last select 0) == _text && {time - (_last select 1) < 3}) exitWith {};
ALiVE_radioLog_last = [_text, time];

// The last 100 messages are kept, newest first, and written to the page as one entry (see "draw").
private _line = ["line", [[daytime, "HH:MM"] call BIS_fnc_timeToString, _from, _text]] call ALIVE_fnc_radioLogStore;
if (isNil "ALiVE_radioLog_lines") then { ALiVE_radioLog_lines = [] };
ALiVE_radioLog_lines = ([_line] + ALiVE_radioLog_lines) select [0, 100];
["draw"] call ALIVE_fnc_radioLogStore;

// the server keeps what the whole side heard, once however many of its players tell it
if (_heard == "side") then {
    private _args = ["report", [str side group player, _from, _text]];
    if (isServer) then { _args call ALIVE_fnc_radioLogStore } else { _args remoteExecCall ["ALIVE_fnc_radioLogStore", 2] };
};
