#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(craters);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_craters

Description:
Persistent Craters. Shells, rockets and bombs leave craters that stay; the big ones dig the
ground. Every machine watches the rounds it fires (ALiVE_fnc_cratersWatch) and tells the
server where they went off. The server decides what each hit leaves (ALiVE_fnc_cratersReport),
digs and fills the ground and places the marks (ALiVE_fnc_cratersTerrain), keeps the count
under the cap and saves the lot (ALiVE_fnc_cratersPersistence).

Server state, all in missionNamespace:
ALiVE_craters        - id -> crater record (HashMap: hx, hy, ci, cj, tier, class, dir, keys, decal)
ALiVE_craters_order  - ids, oldest first; the cap fills from the front
ALiVE_craters_points - "i_j" terrain grid point -> [x, y, original height, [[id, height], ...]],
                       every crater lowering that point and the height it wants; the ground
                       sits at the lowest of them
ALiVE_craters_queue  - hits waiting for the server loop, [posASL, ammo, from, tickTime]

Parameters:
Object - The module
String - The operation
Array - Its arguments

Returns:
Any - The result of the operation

Operations:
init - start the module (every machine: the watcher; server: the stores and the loop)
attribute - [name] the module setting, parsed
tier - [ammo class] 0 none, 1 a mark only, 2 a crater, 3 a big crater, before any area rules
status - [craters, ground points, hits waiting]

See Also:
- <ALIVE_fnc_cratersInit>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_craters

// a save started from an admin's machine (SERVER SAVE AND EXIT) comes through ALiVE_fnc_cratersSaveData,
// which marks itself; anything else remote is refused
if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_cratersCaller"}) exitWith {};

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull, [], "", 0, true, false]]
];

private _result = true;

// The settings: [default, kind], kind "bool" or [min, max] for a clamped number
private _settings = createHashMapFromArray [
    ["craters_debug", [false, "bool"]],
    ["craters_min_size", [1, [0, 2]]],
    ["craters_cap", [150, [1, 2000]]],
    ["craters_dig", [true, "bool"]],
    ["craters_depth", [0.6, [0.2, 1.2]]],
    ["craters_building_distance", [25, [8, 200]]],
    ["craters_persistent", [true, "bool"]],
    ["craters_save_interval", [120, [10, 3600]]]
];

switch (_operation) do {

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

    case "init": {
        // every machine fires rounds: the player's own, a headless client's AI, the server's AI
        [] call ALiVE_fnc_cratersWatch;

        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALiVE_SYS_CRATERS"];
            _logic setVariable ["startupComplete", false];

            if (!isNil "ALiVE_sys_craters" && {!isNull ALiVE_sys_craters} && {ALiVE_sys_craters != _logic}) exitWith {
                ["ALiVE Persistent Craters - a second Persistent Craters module was placed; only the first is used"] call ALiVE_fnc_dumpR;
            };
            ALiVE_sys_craters = _logic;

            { [_logic, "attribute", [_x]] call MAINCLASS } forEach (keys _settings);
            private _debug = [_logic, "attribute", ["craters_debug"]] call MAINCLASS;

            // the game's own crater objects, small to large; a mod or an old build without one
            // falls back to the next that exists
            private _pick = {
                private _found = _this findIf { isClass (configFile >> "CfgVehicles" >> _x) };
                if (_found < 0) then { "" } else { _this select _found }
            };
            ALiVE_craters_classes = [
                ["Land_ShellCrater_01_F", "CraterLong_small", "CraterLong"] call _pick,
                ["Land_ShellCrater_02_large_F", "Land_ShellCrater_01_F", "CraterLong"] call _pick,
                ["Land_ShellCrater_02_extralarge_F", "Land_ShellCrater_02_large_F", "Land_ShellCrater_01_F", "CraterLong"] call _pick
            ];

            ALiVE_craters = createHashMap;
            ALiVE_craters_order = [];
            ALiVE_craters_points = createHashMap;
            ALiVE_craters_queue = [];
            ALiVE_craters_counter = 0;
            ALiVE_craters_dirty = false;
            ALiVE_craters_rate = createHashMap;
            ALiVE_craters_intake = [0, -1];
            ALiVE_craters_zones = [];
            ALiVE_craters_zonesAt = -1e9;
            ALiVE_craters_t0 = diag_tickTime;
            if (isNil "ALiVE_craters_block") then { ALiVE_craters_block = 8 };

            ["ALiVE Persistent Craters - started; crater marks %1; settings %2", ALiVE_craters_classes,
                (keys _settings) apply { [_x, _logic getVariable ["ALiVE_CRATERS_set_" + _x, "?"]] }] call ALiVE_fnc_dump;

            // The one server loop: load what was saved once ALiVE Data is up, then take the
            // hits two at a time. Digging waits between blocks, so it runs here, scheduled,
            // never inside an event handler.
            [_logic] spawn {
                params ["_logic"];
                private _t0 = diag_tickTime;
                if (!isNil "ALIVE_sys_data") then {
                    waitUntil {
                        sleep 1;
                        (ALIVE_sys_data getVariable ["startupComplete", false])
                        || {missionNamespace getVariable ["ALIVE_sys_data_DISABLED", false]}
                        || {diag_tickTime - _t0 > 120}
                    };
                };
                // ALiVE Data never came up: nothing could be read, so nothing is written over it
                if (!isNil "ALIVE_sys_data" && {!(ALIVE_sys_data getVariable ["startupComplete", false])} && {!(missionNamespace getVariable ["ALIVE_sys_data_DISABLED", false])}) then {
                    ALiVE_craters_readOnly = true;
                    ["ALiVE Persistent Craters - ALiVE Data wasn't ready after two minutes; craters are made but not saved this session"] call ALiVE_fnc_dumpR;
                } else {
                    [] call ALiVE_fnc_cratersLoadData;
                };
                _logic setVariable ["startupComplete", true];

                private _saveCheck = time;
                private _airsideWaitLogged = false;
                while { !isNull _logic } do {
                    private _taken = 0;
                    while { _taken < 2 && {ALiVE_craters_queue isNotEqualTo []} } do {
                        // the runway check needs the airfield map, built at start; a hit waits
                        // for it, up to two minutes
                        private _ready = (missionNamespace getVariable ["ALiVE_airsideCacheReady", false]) || {diag_tickTime - ALiVE_craters_t0 > 120};
                        if (!_ready) exitWith { _taken = 2 };
                        // 8 a second at most: the rest wait in the queue for the next second
                        if ((ALiVE_craters_intake select 1) == floor time && {(ALiVE_craters_intake select 0) >= 8}) exitWith { _taken = 2 };
                        if (!_airsideWaitLogged && {!(missionNamespace getVariable ["ALiVE_airsideCacheReady", false])}) then {
                            _airsideWaitLogged = true;
                            ["ALiVE Persistent Craters - the airfield map wasn't ready after two minutes; craters go ahead without the runway check"] call ALiVE_fnc_dump;
                        };
                        private _r = ALiVE_craters_queue deleteAt 0;
                        ["hit", _r] call ALiVE_fnc_cratersReport;
                        _taken = _taken + 1;
                    };
                    if (time - _saveCheck > 5) then {
                        _saveCheck = time;
                        ["save", [false]] call ALiVE_fnc_cratersPersistence;
                    };
                    sleep ([1, 0.1] select (ALiVE_craters_queue isNotEqualTo []));
                };
                // the module was deleted: stop taking hits
                ALiVE_craters_queue = nil;
            };
        };
    };

    case "attribute": {
        _args params [["_name", "", [""]]];
        private _have = _logic getVariable ["ALiVE_CRATERS_set_" + _name, nil];
        if (!isNil "_have") exitWith { _result = _have };
        private _spec = _settings getOrDefault [_name, [nil, "text"]];
        _spec params ["_default", "_kind"];
        private _raw = _logic getVariable [_name, _default];
        private _value = _default;
        switch (true) do {
            case (_kind isEqualTo "bool"): {
                _value = if (_raw isEqualType "") then { toLower _raw == "true" } else { _raw isEqualTo true };
            };
            case (_kind isEqualTo "text"): {
                _value = if (_raw isEqualType "") then { _raw } else { str _raw };
            };
            default {
                private _n = if (_raw isEqualType "") then { parseNumber _raw } else { _raw };
                if !(_n isEqualType 0) then { _n = _default };
                if (_kind isEqualType []) then { _n = (_n max (_kind select 0)) min (_kind select 1) };
                _value = _n;
            };
        };
        _logic setVariable ["ALiVE_CRATERS_set_" + _name, _value];
        _result = _value;
    };

    // How big a crater this round leaves, from its blast alone: 0 none, 1 a mark only, 2 a
    // crater, 3 a big crater. The area rules in ALiVE_fnc_cratersReport can lower it.
    case "tier": {
        _args params [["_ammo", "", [""]]];
        private _score = ["score", [_ammo]] call ALiVE_fnc_cratersWatch;
        private _floor = [40, 150, 1500] select ([_logic, "attribute", ["craters_min_size"]] call MAINCLASS);
        _result = switch (true) do {
            case (_score < _floor): { 0 };
            case (_score < 1500): { 1 };
            case (_score <= 8000): { 2 };
            default { 3 };
        };
        if (_result >= 2 && {!([_logic, "attribute", ["craters_dig"]] call MAINCLASS)}) then { _result = 1 };
    };

    case "status": {
        _result = [count ALiVE_craters_order, count ALiVE_craters_points, count ALiVE_craters_queue];
    };
};

_result
