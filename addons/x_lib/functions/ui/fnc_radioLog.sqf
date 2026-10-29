#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(radioLog);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_radioLog

Description:
Keeps an ALiVE radio message on this player's RADIO LOG page in the map diary, newest first, with
the in-game time and who sent it. Called on the machine that shows the message: by
ALIVE_fnc_radioBroadcast, by Combat Support's message broadcast and by ALIVE_fnc_taskSubtitle.
The page holds the last 100 messages. The same line twice within 3 seconds is kept once.

Parameters:
    _this select 0: STRING - who it is from ("HQ", a callsign, a task title)
    _this select 1: STRING - the message

Returns:
Nothing

Examples:
(begin example)
["HQ", "RODEO TWO on station."] call ALIVE_fnc_radioLog;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_from", ""], ["_text", ""]];
if (!hasInterface || {isNull player} || {!(_text isEqualType "")} || {_text == ""}) exitWith {};
if !(_from isEqualType "") then { _from = str _from };

// the same line can arrive by two routes a moment apart (a side message sent to every friendly side)
private _last = missionNamespace getVariable ["ALiVE_radioLog_last", ["", -10]];
if ((_last select 0) == _text && {time - (_last select 1) < 3}) exitWith {};
ALiVE_radioLog_last = [_text, time];

if !(player diarySubjectExists "ALiVE_RadioLog") then {
    player createDiarySubject ["ALiVE_RadioLog", localize "STR_ALIVE_RADIO_LOG"];
};

private _time = [daytime, "HH:MM"] call BIS_fnc_timeToString;
// the page text is structured text, so a < or & in a name is escaped; the line in the list just leaves them out
private _esc = { ((_this regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] };
private _plain = { (_this splitString "<>&") joinString "" };
private _short = if (count _text > 48) then { (_text select [0, 45]) + "..." } else { _text };
private _line = if (_from == "") then { format ["%1 %2", _time, _short call _plain] } else { format ["%1 %2: %3", _time, _from call _plain, _short call _plain] };
private _body = if (_from == "") then { format ["%1: %2", _time, _text call _esc] } else { format ["%1, %2: %3", _time, _from call _esc, _text call _esc] };
private _record = player createDiaryRecord ["ALiVE_RadioLog", [_line, _body]];

// oldest out past 100
// the handles belong to the body that made them, so a respawned player starts a new count
if (isNil "ALiVE_radioLog_records" || {!(missionNamespace getVariable ["ALiVE_radioLog_owner", objNull] isEqualTo player)}) then {
    ALiVE_radioLog_records = [];
    ALiVE_radioLog_owner = player;
};
ALiVE_radioLog_records pushBack _record;
while { count ALiVE_radioLog_records > 100 } do {
    player removeDiaryRecord ["ALiVE_RadioLog", ALiVE_radioLog_records deleteAt 0];
};
