#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(virtualiseInRadiusResult);

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

true
