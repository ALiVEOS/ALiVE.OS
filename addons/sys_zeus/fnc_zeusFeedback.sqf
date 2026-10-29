#include "\x\alive\addons\sys_zeus\script_component.hpp"
SCRIPT(zeusFeedback);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zeusFeedback

Description:
Shows the Zeus the outcome of an ALiVE Zeus module: in the chat, and as the Zeus feedback
line when the Zeus interface is open.

Parameters:
String - stringtable key
Array - format arguments

Returns:
Bool

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {false};

params [
    ["_messageKey", "", [""]],
    ["_arguments", [], [[]]]
];

private _message = localize _messageKey;
if !(_arguments isEqualTo []) then {
    _message = format ([_message] + _arguments);
};

systemChat _message;
// the game's popup takes the Zeus's curator logic first, then the text (Jman, 29 Oct: passing
// the text alone threw a script error on every reply)
private _curator = getAssignedCuratorLogic player;
if (!isNull (findDisplay 312) && {!isNull _curator}) then {
    [_curator, _message] call BIS_fnc_showCuratorFeedbackMessage;
};

true
