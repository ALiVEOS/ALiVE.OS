#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(FOB);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_FOB

Description:
Player FOBs (#882, #693). The module, its settings and the FOB registry. The registry lives
on the server only, as one ALiVE hash keyed by FOB id (FOB_WEST_3); players' machines get a
plain copy of the parts they need (ALiVE_FOB_registryMirror). Every change to a FOB goes
through the server: a player's machine asks with ALiVE_fnc_fobRequest, never by calling
this directly.

Parameters:
Object - The module
String - The operation
Array - Its arguments

Returns:
Any - The result of the operation

Operations:
init - start the module (server: registry, start-up, watchdog; players: the copy)
destroy - stop it
handleEvent - [event] a Military Logistics supply truck arrived (LOGCOM_FOB_RESUPPLY_ARRIVED)
pause - get or set (BOOL) the pause state; the watchdog does nothing while paused
debug - get or set (BOOL) debug output
attribute - [name] the module setting, parsed (numbers as numbers, clamped where it matters)
nextID - [side string] a new FOB id for that side, FOB_WEST_1 upwards, never reused
newEntry - [id, side, faction, pos, dir] a fresh registry entry, not yet stored
registryGet - [id] the entry, or nil
registrySet - [id, entry] store or replace an entry, marks the registry changed
registryRemove - [id] remove an entry
registryIDs - [side string or ""] the ids, for one side or all
markDirty - flag that the FOBs need saving
broadcastMirror - send every player the plain copy

Examples:
(begin example)
private _id = [ALiVE_sup_fob, "nextID", ["WEST"]] call ALiVE_fnc_FOB;
(end)

See Also:
- <ALIVE_fnc_FOBInit>
- <ALIVE_fnc_fobRequest>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_FOB

// A player's machine reaches the server only through ALiVE_fnc_fobRequest, which checks who is
// asking and then calls in with _ALiVE_fobCaller set. Called straight from a client with
// remoteExec, this refuses: no CfgRemoteExec ships, so without it anyone could edit the
// registry. The same two lines head every server function of this module.
if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull, [], "", 0, true, false]]
];

private _result = true;

// The settings: [default, kind], kind "bool", "text", "number" or [min, max] for a clamped number
private _settings = createHashMapFromArray [
    ["fob_debug", [false, "bool"]],
    ["fob_persistent", [true, "bool"]],
    ["fob_build_range", [150, [25, 1000]]],
    ["fob_min_distance", [500, [0, 10000]]],
    ["fob_hub_west", ["Land_Cargo_HQ_V1_F", "text"]],
    ["fob_hub_east", ["Land_Cargo_HQ_V3_F", "text"]],
    ["fob_hub_guer", ["Land_Cargo_HQ_V2_F", "text"]],
    ["fob_cap_type", ["DYNAMIC", "text"]],
    ["fob_cap", [3, "number"]],
    ["fob_cap_base", [1, [0, 12]]],
    ["fob_cap_per", [3, [1, 100]]],
    ["fob_cap_max", [6, [1, 12]]],
    ["fob_supply_source", ["FOBPOOL", "text"]],
    ["fob_supply_initial", [1000, [0, 1000000]]],
    ["fob_supply_trickle", [0, [0, 100000]]],
    ["fob_supply_cap_t1", [2500, [0, 1000000]]],
    ["fob_supply_cap_t2", [4000, [0, 1000000]]],
    ["fob_supply_cap_t3", [5000, [0, 1000000]]],
    ["fob_cost_scale", [1, [0, 100]]],
    ["fob_save_interval", [60, [5, 3600]]],
    ["fob_alert_radius", [400, [50, 3000]]],
    ["fob_enemy_targeting", ["CONTACT", "text"]],
    ["fob_discovery_radius", [500, [50, 5000]]],
    ["fob_capture_radius", [100, [20, 1000]]],
    ["fob_capture_time", [180, [10, 3600]]],
    ["fob_repair_time", [900, [30, 7200]]],
    ["fob_repair_cost", [1000, [0, 1000000]]],
    ["fob_crate_amount", [1000, [1, 1000000]]],
    ["fob_resupply_threshold", [25, [0, 100]]],
    ["fob_kit_cost", [500, [0, 1000000]]],
    ["fob_tier2_cost", [1500, [0, 1000000]]],
    ["fob_tier3_cost", [3000, [0, 1000000]]],
    ["fob_respawn", [true, "bool"]],
    ["fob_garrison_cost", [500, [0, 1000000]]],
    ["fob_garrison_group", ["", "text"]]
];

switch (_operation) do {

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

    case "init": {
        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALiVE_SUP_FOB"];
            _logic setVariable ["startupComplete", false];
            _logic setVariable ["pause", false];

            // One module serves every side: a second one is told so and does nothing
            if (!isNil "ALiVE_sup_fob" && {!isNull ALiVE_sup_fob} && {ALiVE_sup_fob != _logic}) exitWith {
                ["ALiVE Player FOBs - a second Player FOBs module was placed; only the first is used"] call ALiVE_fnc_dumpR;
            };
            ALiVE_sup_fob = _logic;
            publicVariable "ALiVE_sup_fob";

            // Objects synced to the module are Field HQs: players get FOB kits and supply crates there
            {
                if !(_x isKindOf "Logic") then { _x setVariable ["ALiVE_FOB_fieldHQ", true, true] };
            } forEach (synchronizedObjects _logic);

            if (isNil "ALiVE_FOB_registry") then { ALiVE_FOB_registry = [] call ALIVE_fnc_hashCreate };
            if (isNil "ALiVE_FOB_counter") then { ALiVE_FOB_counter = 0 };
            ALiVE_FOB_dirty = false;
            ALiVE_FOB_registryMirror = [];
            publicVariable "ALiVE_FOB_registryMirror";

            // Settings are read once and kept parsed, so a typo is reported here, at start
            {
                [_logic, "attribute", [_x]] call MAINCLASS;
            } forEach (keys _settings);

            if ([_logic, "attribute", ["fob_debug"]] call MAINCLASS) then {
                ["ALiVE Player FOBs - settings: %1", (keys _settings) apply { [_x, _logic getVariable ["ALiVE_FOB_set_" + _x, "?"]] }] call ALiVE_fnc_dump;
            };

            // The rest waits for what it reads: the Virtual AI System, the AI Commanders and
            // Military Logistics all finish starting after their own init returns. A commander
            // that never finishes is waited for 300 s, then the FOBs start without it.
            [_logic] spawn {
                params ["_logic"];
                private _t0 = diag_tickTime;
                if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {
                    waitUntil { sleep 1; (!isNil "ALiVE_ProfileHandler" && {[ALiVE_ProfileSystem, "startupComplete", false] call ALIVE_fnc_hashGet}) || {diag_tickTime - _t0 > 300} };
                };
                waitUntil {
                    sleep 1;
                    private _opcoms = missionNamespace getVariable ["OPCOM_instances", []];
                    ((_opcoms findIf { !([_x, "startupComplete", false] call ALiVE_fnc_hashGet) }) < 0) || {diag_tickTime - _t0 > 300}
                };
                waitUntil {
                    sleep 1;
                    ((allMissionObjects "ALiVE_mil_logistics") findIf { !(_x getVariable ["startupComplete", false]) } < 0) || {diag_tickTime - _t0 > 300}
                };
                if (diag_tickTime - _t0 > 300) then {
                    ["ALiVE Player FOBs - gave up waiting for the AI Commanders or Military Logistics to finish starting after 300 s; starting without them"] call ALiVE_fnc_dumpR;
                };

                // What can be built and its price, before anything is loaded or requested
                [] call ALiVE_fnc_fobBuildScan;

                if ([_logic, "attribute", ["fob_persistent"]] call ALIVE_fnc_FOB) then {
                    [] call ALiVE_fnc_fobLoadData;
                };
                // Saved FOBs get their headquarters and their commanders' objectives back
                isNil { ["restore"] call ALiVE_fnc_fobOps };

                [_logic, "broadcastMirror"] call ALIVE_fnc_FOB;
                // Military Logistics answers a FOB's supply request with this when its truck arrives
                if (!isNil "ALIVE_eventLog") then {
                    _logic setVariable ["listenerID", [ALIVE_eventLog, "addListener", [_logic, ["LOGCOM_FOB_RESUPPLY_ARRIVED"]]] call ALIVE_fnc_eventLog];
                };
                _logic setVariable ["startupComplete", true];
                [_logic] call ALiVE_fnc_fobWatchdog;

                ["ALiVE Player FOBs - ready after %1 s: %2 FOBs", round (diag_tickTime - _t0), count (ALiVE_FOB_registry select 1)] call ALiVE_fnc_dump;
            };
        };

        if (hasInterface) then {
            ["init"] call ALiVE_fnc_fobClient;
        };
    };

    case "destroy": {
        if (isServer) then {
            _logic setVariable ["pause", true];
            if (!isNil "ALiVE_FOB_watchdog") then { terminate ALiVE_FOB_watchdog; ALiVE_FOB_watchdog = nil };
            private _lid = _logic getVariable ["listenerID", ""];
            if (_lid != "" && {!isNil "ALIVE_eventLog"}) then { [ALIVE_eventLog, "removeListener", _lid] call ALIVE_fnc_eventLog };
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];
            [_logic, "destroy"] call SUPERCLASS;
        };
    };

    // Get, or set with a BOOL, as fnc_pauseModule and fnc_unPauseModule call it
    case "pause": {
        if (_args isEqualType true) then {
            _logic setVariable ["pause", _args];
            ["ALiVE Player FOBs - paused: %1", _args] call ALiVE_fnc_dumpR;
        };
        _result = _logic getVariable ["pause", false];
    };

    // A Military Logistics supply truck reached a FOB: the FOB gets a crate's worth, if it is
    // still the side's that asked (a FOB taken while the truck was on the road gets nothing).
    // The event log calls this from a scheduled worker, so the credit runs in one piece.
    case "handleEvent": {
        if !(_args isEqualType []) exitWith {};
        if (([_args, "type", ""] call ALIVE_fnc_hashGet) != "LOGCOM_FOB_RESUPPLY_ARRIVED") exitWith {};
        ([_args, "data", []] call ALIVE_fnc_hashGet) params [["_id", "", [""]], ["_side", "", [""]]];
        isNil {
            private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
            if (isNil "_entry") exitWith {};
            if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != _side) exitWith {
                ["ALiVE Player FOBs - %1: a supply truck for %2 arrived but the FOB now belongs to %3; nothing unloaded", _id, _side, [_entry, "side", ""] call ALIVE_fnc_hashGet] call ALiVE_fnc_dump;
            };
            private _amount = [_logic, "attribute", ["fob_crate_amount"]] call MAINCLASS;
            ["credit", [_id, _amount, "logistics"]] call ALiVE_fnc_fobSupply;
            [_entry, "resupplyCooldown", 0] call ALIVE_fnc_hashSet;
            [_logic, "broadcastMirror"] call MAINCLASS;
            private _text = format ["Supplies delivered to %1.", [_entry, "name", ""] call ALIVE_fnc_hashGet];
            [_side, [_logic, _text, "side", [_side] call ALiVE_fnc_sideTextToObject, false, true, false, true, "HQ"]] call ALIVE_fnc_radioBroadcastToSide;
        };
    };

    case "debug": {
        if (_args isEqualType true) then { _logic setVariable ["ALiVE_FOB_set_fob_debug", _args] };
        _result = _logic getVariable ["ALiVE_FOB_set_fob_debug", false];
    };

    // A module setting, parsed once and kept: a Combo arrives as a value or as text, an Edit as
    // text (or a number from an older mission), so each is read the way its kind needs.
    case "attribute": {
        _args params [["_name", "", [""]]];
        private _have = _logic getVariable ["ALiVE_FOB_set_" + _name, nil];
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
                if (_name in ["fob_cap_type", "fob_supply_source", "fob_enemy_targeting"]) then { _value = toUpper _value };
            };
            default {
                private _n = if (_raw isEqualType "") then { parseNumber _raw } else { _raw };
                if !(_n isEqualType 0) then { _n = _default };
                if (_kind isEqualType []) then { _n = (_n max (_kind select 0)) min (_kind select 1) };
                _value = _n;
            };
        };
        _logic setVariable ["ALiVE_FOB_set_" + _name, _value];
        _result = _value;
    };

    case "nextID": {
        _args params [["_side", "WEST", [""]]];
        ALiVE_FOB_counter = ALiVE_FOB_counter + 1;
        _result = format ["FOB_%1_%2", toUpper _side, ALiVE_FOB_counter];
    };

    // A new entry, every key present so readers never meet a missing field
    case "newEntry": {
        _args params [["_id", "", [""]], ["_side", "WEST", [""]], ["_faction", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]]];
        private _names = ["Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike",
            "November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu"];
        private _n = parseNumber ((_id splitString "_") param [2, "0"]);
        private _hubKey = switch (_side) do { case "EAST": {"fob_hub_east"}; case "GUER": {"fob_hub_guer"}; default {"fob_hub_west"} };
        _result = [] call ALIVE_fnc_hashCreate;
        {
            [_result, _x select 0, _x select 1] call ALIVE_fnc_hashSet;
        } forEach [
            ["id", _id], ["side", _side], ["faction", _faction],
            ["name", "FOB " + (_names select ((_n - 1) max 0) % 26)],
            ["pos", _pos], ["dir", _dir], ["status", "active"], ["tier", 1],
            ["supply", [_logic, "attribute", ["fob_supply_initial"]] call MAINCLASS],
            ["hubClass", [_logic, "attribute", [_hubKey]] call MAINCLASS], ["hub", objNull],
            ["objects", []],
            ["repairRemaining", 0], ["captureRemaining", 0], ["alertCooldown", 0], ["resupplyCooldown", 0], ["trickleAccumulator", 0],
            ["captureSide", ""], ["discoveredBy", []], ["objectiveIDs", []], ["garrison", []], ["respawn", []]
        ];
    };

    case "registryGet": {
        _args params [["_id", "", [""]]];
        _result = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
    };

    case "registrySet": {
        _args params [["_id", "", [""]], ["_entry", [], [[]]]];
        [ALiVE_FOB_registry, _id, _entry] call ALIVE_fnc_hashSet;
        ALiVE_FOB_dirty = true;
        _result = true;
    };

    case "registryRemove": {
        _args params [["_id", "", [""]]];
        [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashRem;
        ALiVE_FOB_dirty = true;
        _result = true;
    };

    case "registryIDs": {
        _args params [["_side", "", [""]]];
        _result = (ALiVE_FOB_registry select 1) select {
            _side == "" || {([[ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet, "side", ""] call ALIVE_fnc_hashGet) == _side}
        };
    };

    case "markDirty": {
        ALiVE_FOB_dirty = true;
    };

    // What players' machines see: [id, side, name, pos, status, tier, supply, supplyCap, buildRange]
    case "broadcastMirror": {
        private _range = [_logic, "attribute", ["fob_build_range"]] call MAINCLASS;
        ALiVE_FOB_registryMirror = (ALiVE_FOB_registry select 1) apply {
            private _e = [ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet;
            [_x, [_e, "side"] call ALIVE_fnc_hashGet, [_e, "name"] call ALIVE_fnc_hashGet, [_e, "pos"] call ALIVE_fnc_hashGet,
             [_e, "status"] call ALIVE_fnc_hashGet, [_e, "tier"] call ALIVE_fnc_hashGet,
             ["balance", [_x]] call ALiVE_fnc_fobSupply, ["cap", [_x]] call ALiVE_fnc_fobSupply, _range]
        };
        publicVariable "ALiVE_FOB_registryMirror";
        // A hosted server's own player gets no public variable event for its own send
        if (hasInterface) then { [] call ALiVE_fnc_fobMarkers };
        _result = count ALiVE_FOB_registryMirror;
    };
};

_result
