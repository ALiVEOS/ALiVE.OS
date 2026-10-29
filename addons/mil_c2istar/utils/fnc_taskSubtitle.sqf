#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskSubtitle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskSubtitle

Description:
Shows a task update (a task done, a "COIN Update" during a Hearts and Minds hold) on this player's
screen the way the player chose in Addon Options > ALiVE > Game (#1083): as a subtitle (the default),
a hint or a chat line. There is no "off": the hold countdown and its warnings are the only word a
player gets while holding the area. Sent to the players with remoteExec in place of
BIS_fnc_showSubtitle.

Parameters:
    _this select 0: STRING - the title ("COIN Update", "Task Accomplished")
    _this select 1: STRING - the message
    _this select 2: BOOL - leave it off the RADIO LOG page (optional, default false; the hold countdown sets it)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_title", ""], ["_text", ""], ["_noLog", false]];
if (!hasInterface) exitWith {};

// the RADIO LOG page in the map diary keeps it too
if (!_noLog) then { [_title, _text] call ALIVE_fnc_radioLog };

switch (missionNamespace getVariable ["ALiVE_prefTaskMessages", "subtitle"]) do {
    // ALiVE's own hint, with the logo and the title; the message is structured text, so a < or & in a
    // town or player name is escaped
    case "hint": { [_title, ((_text regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"]] call ALIVE_fnc_sendHint };
    case "chat": { systemChat format ["%1: %2", _title, _text] };
    default { [_title, _text] spawn BIS_fnc_showSubtitle };
};
