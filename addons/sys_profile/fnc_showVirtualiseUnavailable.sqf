#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(showVirtualiseUnavailable);

if (!hasInterface) exitWith {false};
disableSerialization;

params [
    ["_messageKey", "STR_ALIVE_PROFILE_VIRTUALISE_NO_PROFILE_SYSTEM", [""]]
];

if !(isNull (findDisplay 9100411)) exitWith {true};

private _parentDisplay = findDisplay 312; //zeus interace
if (isNull _parentDisplay) then {
    _parentDisplay = findDisplay 46;
};

if (isNull _parentDisplay) exitWith {false};

private _display = _parentDisplay createDisplay
    "ALiVE_RscVirtualiseUnavailable";

if (!isNull _display) then {
    (_display displayCtrl 1100) ctrlSetText (localize _messageKey);
};

!isNull _display
