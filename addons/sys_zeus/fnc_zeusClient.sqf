#include "\x\alive\addons\sys_zeus\script_component.hpp"
SCRIPT(zeusClient);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zeusClient

Description:
The Zeus's side of each ALiVE Zeus module. With Zeus Enhanced it asks for the module's options
in a dialog first; a plain Zeus module uses the defaults. Then it sends the request to the
server, which checks the Zeus and does the work (ALiVE_fnc_zeusRequest).

Parameters:
String - the module: "save", "debug", "spotReport", "handGroup" or "bomber"
Array - position (ATL)
Object - the unit the module was placed on, or objNull
Bool - true when Zeus Enhanced is loaded, so its option dialogs can be used

Returns:
Bool

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {false};

params [
    ["_action", "", [""]],
    ["_position", [0,0,0], [[]]],
    ["_attached", objNull, [objNull]],
    ["_zen", false, [true]]
];

private _send = {
    params ["_action", "_args"];
    [_action, _args] remoteExecCall ["ALiVE_fnc_zeusRequest", 2];
};

switch (_action) do {

    case "save";
    case "debug": {
        [_action, []] call _send;
    };

    // The enemy near the spot become known to the AI Commanders of the side chosen, or of every
    // side with one: each only learns of its own enemies there
    case "spotReport": {
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_SPOTREPORT",
                [
                    ["COMBO", localize "STR_ALIVE_ZEUS_TELL_SIDE", [["", "WEST", "EAST", "GUER"], [localize "STR_ALIVE_ZEUS_ALL_COMMANDERS", localize "STR_ALIVE_ZEUS_SIDE_WEST", localize "STR_ALIVE_ZEUS_SIDE_EAST", localize "STR_ALIVE_ZEUS_SIDE_GUER"], 0]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    ["spotReport", [_position, _values select 0]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["spotReport", [_position, ""]] call _send;
        };
    };

    case "handGroup": {
        if (isNull _attached || {!(_attached isKindOf "CAManBase")} || {isNull group _attached}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_UNIT"] call ALiVE_fnc_zeusFeedback;
        };
        ["handGroup", [group _attached]] call _send;
    };

    // An empty faction is the IED module's own bomber faction
    case "bomber": {
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_BOMBER",
                [
                    ["EDIT", [localize "STR_ALIVE_ZEUS_FACTION", localize "STR_ALIVE_ZEUS_FACTION_TIP"], [""]],
                    ["SLIDER:RADIUS", localize "STR_ALIVE_ZEUS_START_RADIUS", [20, 200, 50, 0, _position]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    _values params ["_faction", "_radius"];
                    ["bomber", [_position, _faction, round _radius]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["bomber", [_position, "", 50]] call _send;
        };
    };
};

true
