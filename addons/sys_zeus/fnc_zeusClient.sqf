#include "\x\alive\addons\sys_zeus\script_component.hpp"
SCRIPT(zeusClient);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zeusClient

Description:
The Zeus's side of each ALiVE Zeus module. With Zeus Enhanced it asks for the module's options
in a dialog first; a plain Zeus module uses the defaults. Then it sends the request to the
server, which checks the Zeus and does the work (ALiVE_fnc_zeusRequest).

Parameters:
String - the module: "save", "debug", "spotReport", "handGroup", "bomber", "convertBomber",
    "carBomb", "ied", "iedAmbush", "spawnGroup", "removeGroup", "objective", "reveal", "createTask",
    "closeTask", "airStrike" or "resupply"
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

    case "convertBomber": {
        if (isNull _attached || {!(_attached isKindOf "CAManBase")} || {!alive _attached} || {isPlayer _attached}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PERSON"] call ALiVE_fnc_zeusFeedback;
        };
        ["convertBomber", [_attached]] call _send;
    };

    // Placed on a car: that car is rigged. Placed on the ground: a car bomb sets off from a road
    // near there after the nearest player. An empty faction is the IED module's bomber faction
    case "carBomb": {
        if (!isNull _attached && {_attached isKindOf "LandVehicle"}) exitWith {
            ["carBomb", [_position, _attached, ""]] call _send;
        };
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_CARBOMB",
                [
                    ["EDIT", [localize "STR_ALIVE_ZEUS_FACTION", localize "STR_ALIVE_ZEUS_FACTION_TIP"], [""]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    ["carBomb", [_position, objNull, _values select 0]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["carBomb", [_position, objNull, ""]] call _send;
        };
    };

    // One IED exactly where it's placed, or with Zeus Enhanced several spread round it
    case "ied": {
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_IED",
                [
                    ["SLIDER", localize "STR_ALIVE_ZEUS_IED_COUNT", [1, 10, 1, 0]],
                    ["SLIDER:RADIUS", [localize "STR_ALIVE_ZEUS_IED_RADIUS", localize "STR_ALIVE_ZEUS_IED_RADIUS_TIP"], [20, 500, 100, 0, _position]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    _values params ["_count", "_radius"];
                    ["ied", [_position, round _count, round _radius]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["ied", [_position, 1, 0]] call _send;
        };
    };

    case "iedAmbush": {
        ["iedAmbush", [_position]] call _send;
    };

    // Two steps with Zeus Enhanced: the faction, then one of its groups. Plain Zeus has no way to
    // choose, so it says so
    case "spawnGroup": {
        if (!_zen) exitWith {
            ["STR_ALIVE_ZEUS_NEED_ZEN"] call ALiVE_fnc_zeusFeedback;
        };
        // The game's groups and the mission's own, as ALiVE reads them (groupGenerateConfigData).
        // A side class with no faction behind it (Empty: compositions) is left out
        private _factions = [];
        private _names = [];
        {
            private _root = _x;
            {
                private _sideCfg = _x;
                {
                    private _f = configName _x;
                    private _fc = [configFile >> "CfgFactionClasses" >> _f, missionConfigFile >> "CfgFactionClasses" >> _f] select (isClass (missionConfigFile >> "CfgFactionClasses" >> _f));
                    if (isClass _fc && {!(_f in _factions)}) then {
                        _factions pushBack _f;
                        _names pushBack format ["%1 (%2)", getText (_fc >> "displayName"), _f];
                    };
                } forEach ("true" configClasses _sideCfg);
            } forEach ("true" configClasses (_root >> "CfgGroups"));
        } forEach [configFile, missionConfigFile];
        if (_factions isEqualTo []) exitWith {};
        [
            localize "STR_ALIVE_ZEUS_SPAWNGROUP",
            [
                ["LIST", localize "STR_ALIVE_ZEUS_FACTION", [_factions, _names, 0, 12]]
            ],
            {
                params ["_values", "_args"];
                _args params ["_position", "_send"];
                private _faction = _values select 0;
                private _groups = [];
                private _names = [];
                // A group is any class here with men under it, whatever they're called
                {
                    private _root = _x;
                    {
                        private _fCfg = _x >> _faction;
                        if (isClass _fCfg) then {
                            {
                                private _cat = _x;
                                {
                                    private _key = format ["%1>%2", configName _cat, configName _x];
                                    if !(_key in _groups) then {
                                        _groups pushBack _key;
                                        _names pushBack format ["%1: %2", getText (_cat >> "name"), getText (_x >> "name")];
                                    };
                                } forEach ("count (""true"" configClasses _x) > 0" configClasses _cat);
                            } forEach ("true" configClasses _fCfg);
                        };
                    } forEach ("true" configClasses (_root >> "CfgGroups"));
                } forEach [configFile, missionConfigFile];
                if (_groups isEqualTo []) exitWith {
                    ["STR_ALIVE_ZEUS_NO_GROUPS", [_faction]] call ALiVE_fnc_zeusFeedback;
                };
                [
                    localize "STR_ALIVE_ZEUS_SPAWNGROUP",
                    [
                        ["LIST", localize "STR_ALIVE_ZEUS_GROUP", [_groups, _names, 0, 12]]
                    ],
                    {
                        params ["_values", "_args"];
                        _args params ["_position", "_send", "_faction"];
                        ["spawnGroup", [_position, _faction, _values select 0]] call _send;
                    },
                    {},
                    [_position, _send, _faction]
                ] call zen_dialog_fnc_create;
            },
            {},
            [_position, _send]
        ] call zen_dialog_fnc_create;
    };

    // Placed on a man of an ALiVE group: despawn it (it comes back when someone is near), or with
    // Zeus Enhanced take it out of the mission for good
    case "removeGroup": {
        if (isNull _attached || {!(_attached isKindOf "CAManBase")}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_UNIT"] call ALiVE_fnc_zeusFeedback;
        };
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_REMOVEGROUP",
                [
                    ["TOOLBOX", localize "STR_ALIVE_ZEUS_REMOVE_HOW", [0, 1, 2, [localize "STR_ALIVE_ZEUS_REMOVE_DESPAWN", localize "STR_ALIVE_ZEUS_REMOVE_DELETE"]]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_attached", "_send"];
                    ["removeGroup", [_attached, ["despawn", "delete"] select (_values select 0)]] call _send;
                },
                {},
                [_attached, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["removeGroup", [_attached, "despawn"]] call _send;
        };
    };

    // The side's AI Commanders attack the spot, or with Zeus Enhanced hold it, for the side chosen
    case "objective": {
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_OBJECTIVE",
                [
                    ["COMBO", localize "STR_ALIVE_ZEUS_FOR_SIDE", [["", "WEST", "EAST", "GUER"], [localize "STR_ALIVE_ZEUS_SIDE_NEAREST", localize "STR_ALIVE_ZEUS_SIDE_WEST", localize "STR_ALIVE_ZEUS_SIDE_EAST", localize "STR_ALIVE_ZEUS_SIDE_GUER"], 0]],
                    ["TOOLBOX", localize "STR_ALIVE_ZEUS_OBJECTIVE_HOW", [0, 1, 2, [localize "STR_ALIVE_ZEUS_OBJECTIVE_TAKE_LABEL", localize "STR_ALIVE_ZEUS_OBJECTIVE_HOLD_LABEL"]]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    ["objective", [_position, _values select 0, ["take", "hold"] select (_values select 1)]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["objective", [_position, "", "take"]] call _send;
        };
    };

    // Installations within 1 km, or with Zeus Enhanced a radius chosen and a side whose Intel Log
    // records them
    case "reveal": {
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_REVEAL",
                [
                    ["SLIDER:RADIUS", localize "STR_ALIVE_ZEUS_RADIUS", [100, 5000, 1000, 0, _position]],
                    ["COMBO", localize "STR_ALIVE_ZEUS_INTEL_SIDE", [["", "WEST", "EAST", "GUER"], [localize "STR_ALIVE_ZEUS_INTEL_NONE", localize "STR_ALIVE_ZEUS_SIDE_WEST", localize "STR_ALIVE_ZEUS_SIDE_EAST", localize "STR_ALIVE_ZEUS_SIDE_GUER"], 0]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    ["reveal", [_position, round (_values select 0), _values select 1]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["reveal", [_position, 1000, ""]] call _send;
        };
    };

    // A task to go to the spot, for the side of the nearest player, or with Zeus Enhanced a side,
    // title and description of the Zeus's own
    case "createTask": {
        private _title = format [localize "STR_ALIVE_ZEUS_TASK_TITLE", mapGridPosition _position];
        private _description = format [localize "STR_ALIVE_ZEUS_TASK_DESCRIPTION", mapGridPosition _position];
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_CREATETASK",
                [
                    ["COMBO", localize "STR_ALIVE_ZEUS_FOR_SIDE", [["", "WEST", "EAST", "GUER"], [localize "STR_ALIVE_ZEUS_SIDE_NEAREST", localize "STR_ALIVE_ZEUS_SIDE_WEST", localize "STR_ALIVE_ZEUS_SIDE_EAST", localize "STR_ALIVE_ZEUS_SIDE_GUER"], 0]],
                    ["EDIT", localize "STR_ALIVE_ZEUS_TASK_TITLE_LABEL", [_title]],
                    ["EDIT:MULTI", localize "STR_ALIVE_ZEUS_TASK_DESCRIPTION_LABEL", [_description, {_this}, 5]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    _values params ["_side", "_title", "_description"];
                    ["createTask", [_position, _side, _title, _description]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["createTask", [_position, "", _title, _description]] call _send;
        };
    };

    // Placed on a player: their task. On the ground: the nearest open task. It succeeds, or with
    // Zeus Enhanced fails or is cancelled
    case "closeTask": {
        // Placed on a vehicle: the player commanding it, or any player aboard
        if (!isNull _attached && {!(_attached isKindOf "CAManBase")}) then {
            private _crew = (crew _attached) select { isPlayer _x };
            _attached = if (isPlayer (effectiveCommander _attached)) then { effectiveCommander _attached } else { _crew param [0, objNull] };
        };
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_CLOSETASK",
                [
                    ["TOOLBOX", localize "STR_ALIVE_ZEUS_TASK_OUTCOME", [0, 1, 3, [localize "STR_ALIVE_ZEUS_TASK_OUTCOME_SUCCEEDED", localize "STR_ALIVE_ZEUS_TASK_OUTCOME_FAILED", localize "STR_ALIVE_ZEUS_TASK_OUTCOME_CANCELED"]]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_attached", "_send"];
                    ["closeTask", [_position, _attached, ["Succeeded", "Failed", "Canceled"] select (_values select 0)]] call _send;
                },
                {},
                [_position, _attached, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["closeTask", [_position, _attached, "Succeeded"]] call _send;
        };
    };

    // Close air support from the nearest player's side, or with Zeus Enhanced a side and kind of
    // sortie chosen
    case "airStrike": {
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_AIRSTRIKE",
                [
                    ["COMBO", localize "STR_ALIVE_ZEUS_FOR_SIDE", [["", "WEST", "EAST", "GUER"], [localize "STR_ALIVE_ZEUS_SIDE_NEAREST", localize "STR_ALIVE_ZEUS_SIDE_WEST", localize "STR_ALIVE_ZEUS_SIDE_EAST", localize "STR_ALIVE_ZEUS_SIDE_GUER"], 0]],
                    ["COMBO", localize "STR_ALIVE_ZEUS_AIRSTRIKE_TYPE", [["CAS", "Strike", "SEAD", "Recce"], [localize "STR_ALIVE_ZEUS_AIRSTRIKE_CAS", localize "STR_ALIVE_ZEUS_AIRSTRIKE_STRIKE", localize "STR_ALIVE_ZEUS_AIRSTRIKE_SEAD", localize "STR_ALIVE_ZEUS_AIRSTRIKE_RECCE"], 0]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    ["airStrike", [_position, _values select 0, _values select 1]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["airStrike", [_position, "", "CAS"]] call _send;
        };
    };

    // Two infantry groups by road from the nearest player's side, or with Zeus Enhanced the side,
    // the groups and how they come
    case "resupply": {
        if (_zen) then {
            [
                localize "STR_ALIVE_ZEUS_RESUPPLY",
                [
                    ["COMBO", localize "STR_ALIVE_ZEUS_FOR_SIDE", [["", "WEST", "EAST", "GUER"], [localize "STR_ALIVE_ZEUS_SIDE_NEAREST", localize "STR_ALIVE_ZEUS_SIDE_WEST", localize "STR_ALIVE_ZEUS_SIDE_EAST", localize "STR_ALIVE_ZEUS_SIDE_GUER"], 0]],
                    ["SLIDER", localize "STR_ALIVE_ZEUS_RESUPPLY_INF", [0, 5, 2, 0]],
                    ["SLIDER", localize "STR_ALIVE_ZEUS_RESUPPLY_MOT", [0, 5, 0, 0]],
                    ["SLIDER", localize "STR_ALIVE_ZEUS_RESUPPLY_MECH", [0, 5, 0, 0]],
                    ["SLIDER", localize "STR_ALIVE_ZEUS_RESUPPLY_ARMOUR", [0, 5, 0, 0]],
                    ["COMBO", localize "STR_ALIVE_ZEUS_RESUPPLY_HOW", [["STANDARD", "AIRDROP", "HELI_INSERT"], [localize "STR_ALIVE_ZEUS_RESUPPLY_ROAD", localize "STR_ALIVE_ZEUS_RESUPPLY_AIRDROP", localize "STR_ALIVE_ZEUS_RESUPPLY_HELI"], 0]]
                ],
                {
                    params ["_values", "_args"];
                    _args params ["_position", "_send"];
                    _values params ["_side", "_inf", "_mot", "_mech", "_armour", "_delivery"];
                    ["resupply", [_position, _side, [round _inf, round _mot, round _mech, round _armour, 0, 0], _delivery]] call _send;
                },
                {},
                [_position, _send]
            ] call zen_dialog_fnc_create;
        } else {
            ["resupply", [_position, "", [2, 0, 0, 0, 0, 0], "STANDARD"]] call _send;
        };
    };
};

true
