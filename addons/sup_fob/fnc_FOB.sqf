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
radio - [side, stringtable key, args] a radio message to that side's players, in their language
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
typesParse / typesReload - read the synced FOB Types module's list into ALiVE_FOB_types
typeSpec - [type id] that type's row ("" the plain FOB, [] none such)
types - the types a kit can become
hubChoicesFor - [side, type id] the headquarters buildings for that type
typeAllows - [type id, class] whether a FOB of that type may build it
mayDeployType - [unit, type id] whether that player may deploy that type

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
    ["fob_hubs", ["Land_Cargo_HQ_V1_F|Land_Cargo_HQ_V3_F|Land_Cargo_HQ_V2_F", "text"]],
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
    ["fob_only", ["", "text"]],
    ["fob_blacklist", ["", "text"]],
    ["fob_kit_class", ["", "text"]],
    ["fob_crate_class", ["", "text"]],
    ["fob_whitelist", ["", "text"]],
    ["fob_manage_who", ["SIDE", "text"]],
    ["fob_manage_list", ["", "text"]],
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
    ["fob_respawn", [3, [0, 3]]],
    ["fob_garrison_cost", [500, [0, 1000000]]],
    ["fob_garrison_groups", ["||", "text"]]
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
                if !(_x isKindOf "Logic") then { ["tag", [_x, "HQ", true]] call ALiVE_fnc_fobOps };
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

            // FOB types (NeisAEL on Discord, 20 Oct): a FOB Types module synced to this one. None
            // synced and every FOB is the plain FOB it always was.
            private _typeMods = (synchronizedObjects _logic) select { (typeOf _x) == "ALiVE_sup_fob_types" };
            if (count _typeMods > 1) then { ["ALiVE Player FOBs - %1 FOB Types modules are synced to Player FOBs; only the first is used", count _typeMods] call ALiVE_fnc_dumpR };
            {
                if !(_x in _typeMods) then { ["ALiVE Player FOBs - a FOB Types module isn't synced to Player FOBs, so it does nothing"] call ALiVE_fnc_dumpR };
            } forEach (allMissionObjects "ALiVE_sup_fob_types");
            _logic setVariable ["ALiVE_FOB_typesModule", _typeMods param [0, objNull]];
            [_logic, "typesParse"] call MAINCLASS;

            // The rest waits for what it reads: the Virtual AI System, the AI Commanders and
            // Military Logistics all finish starting after their own init returns. A large mission
            // takes many minutes to place its forces (16 on a full Altis), and FOBs restored before their
            // commanders are ready would miss their objectives, so this waits as long as that takes;
            // only a commander that never finishes is given up on, after 30 minutes.
            [_logic] spawn {
                params ["_logic"];
                private _t0 = diag_tickTime;
                if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {
                    waitUntil { sleep 1; (!isNil "ALiVE_ProfileHandler" && {[ALiVE_ProfileSystem, "startupComplete", false] call ALIVE_fnc_hashGet}) || {diag_tickTime - _t0 > 1800} };
                };
                waitUntil {
                    sleep 1;
                    private _opcoms = missionNamespace getVariable ["OPCOM_instances", []];
                    ((_opcoms findIf { !([_x, "startupComplete", false] call ALiVE_fnc_hashGet) }) < 0) || {diag_tickTime - _t0 > 1800}
                };
                waitUntil {
                    sleep 1;
                    ((allMissionObjects "ALiVE_mil_logistics") findIf { !(_x getVariable ["startupComplete", false]) } < 0) || {diag_tickTime - _t0 > 1800}
                };
                if (diag_tickTime - _t0 > 1800) then {
                    ["ALiVE Player FOBs - the AI Commanders or Military Logistics still hadn't finished starting after 30 minutes; FOBs start without them"] call ALiVE_fnc_dump;
                };

                if ([_logic, "attribute", ["fob_persistent"]] call ALIVE_fnc_FOB) then {
                    [] call ALiVE_fnc_fobLoadData;
                };
                // Saved FOBs get their headquarters and their commanders' objectives back
                isNil { ["restore"] call ALiVE_fnc_fobOps };

                [_logic, "broadcastMirror"] call ALIVE_fnc_FOB;
                // What can be built and its price. Restoring saved FOBs doesn't need it and the scan
                // can take half a minute with a large mod set loaded, so it runs after them; the
                // build menu says so if a player opens it before the scan is done.
                [] call ALiVE_fnc_fobBuildScan;
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
            private _before = ["balance", [_id]] call ALiVE_fnc_fobSupply;
            private _now = ["credit", [_id, _amount, "logistics"]] call ALiVE_fnc_fobSupply;
            [_entry, "resupplyCooldown", 0] call ALIVE_fnc_hashSet;
            [_entry, "lowTold", false] call ALIVE_fnc_hashSet;
            [_logic, "broadcastMirror"] call MAINCLASS;
            [_logic, "radio", [_side, "STR_ALIVE_FOB_RADIO_DELIVERED", [[_entry, "name", ""] call ALIVE_fnc_hashGet, round (_now - _before), round _now]]] call MAINCLASS;
        };
    };

    // A radio message to every player of a side, worded on each player's machine: [side, key, args]
    case "radio": {
        _args params [["_side", "", [""]], ["_key", "", [""]], ["_fmt", [], [[]]]];
        if !(_side in ["WEST", "EAST", "GUER"]) exitWith {};
        ["ALiVE Player FOBs - radio to %1: %2", _side, format ([localize _key] + _fmt)] call ALiVE_fnc_dump;
        ["radio", [_key, _fmt]] remoteExecCall ["ALiVE_fnc_fobClient", [_side] call ALiVE_fnc_sideTextToObject];
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
        // Respawn Point was Yes or No before it took a tier: a mission saved then reads as tier 3 or off
        if (_name == "fob_respawn") then { _raw = switch (toLower str _raw) do { case "true"; case """true""": { 3 }; case "false"; case """false""": { 0 }; default { _raw } } };
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

    // A logged-in or voted admin, or anyone in single player. Works on any machine for the
    // player there, and on the server for anyone.
    case "isAdmin": {
        _args params [["_unit", objNull, [objNull]]];
        _result = !isNull _unit && {if (hasInterface && {_unit isEqualTo player}) then { call ALiVE_fnc_isServerAdmin } else { !isMultiplayer || {isServer && {(admin owner _unit) > 0}} }};
    };

    // Who Can Dismantle and its list, as [rules, list]: what an admin set in game ("permissions" in
    // ALiVE_fnc_fobOps) or else the module's settings. Works on any machine.
    case "manageRules": {
        _result = _logic getVariable ["ALiVE_FOB_perm", []];
        if !(_result isEqualTypeArray ["", ""]) then {
            _result = [[_logic, "attribute", ["fob_manage_who"]] call MAINCLASS, [_logic, "attribute", ["fob_manage_list"]] call MAINCLASS];
        };
    };

    // Whether a player may dismantle a FOB, recycle what was built there or rename it (Who Can
    // Dismantle): an admin always may; otherwise any ticked rule lets them in. A FOB saved before
    // FOBs recorded who deployed them has no deployer, and The Player Who Deployed It then lets in
    // group leaders. The server's answer is the one that counts; players' machines ask the same
    // question only to grey out what would be refused.
    case "mayManage": {
        _args params [["_unit", objNull, [objNull]], ["_deployer", "", [""]]];
        _result = false;
        if (isNull _unit) exitWith {};
        if ([_logic, "isAdmin", [_unit]] call MAINCLASS) exitWith { _result = true };
        ([_logic, "manageRules"] call MAINCLASS) params ["_rules", "_names"];
        _result = [_logic, "mayWho", [_unit, _rules, _names, _deployer]] call MAINCLASS;
    };

    // Whether rules in the Who Can Dismantle form (SIDE, LEADER, DEPLOYER, LIST and a names list)
    // let a player in. No admin test: the callers make that.
    case "mayWho": {
        _args params [["_unit", objNull, [objNull]], ["_rules", "", [""]], ["_names", "", [""]], ["_deployer", "", [""]]];
        _result = false;
        if (isNull _unit) exitWith {};
        private _who = (toUpper _rules) splitString "[]""', ";
        // leading a group with another player in it: anyone alone in a group of their own leads it
        private _leads = leader group _unit isEqualTo _unit && {(units group _unit) findIf { isPlayer _x && {_x != _unit} } > -1};
        _result = "SIDE" in _who
            || {"LEADER" in _who && {_leads}}
            || {"DEPLOYER" in _who && {if (_deployer == "") then { _leads } else { getPlayerUID _unit == _deployer }}}
            || {"LIST" in _who && {
                private _list = (toLower _names) splitString (",; " + toString [9, 10, 13]);
                // a player ID, a unit class, or the slot's variable name from Eden (P1, jtac...)
                (getPlayerUID _unit) in _list || {(toLower typeOf _unit) in _list} || {(toLower vehicleVarName _unit) in _list}
            }};
    };

    // One side's pick from a per-side setting stored BLUFOR|OPFOR|Independent (Headquarters
    // Buildings, Garrison Groups): "" when that side has none. Works on any machine.
    case "perSide": {
        _args params [["_name", "", [""]], ["_side", "WEST", [""]]];
        private _raw = _logic getVariable [_name, (_settings getOrDefault [_name, [""]]) select 0];
        if !(_raw isEqualType "") then { _raw = "" };
        private _parts = [];
        private _at = _raw find "|";
        while {_at >= 0} do { _parts pushBack (_raw select [0, _at]); _raw = _raw select [_at + 1]; _at = _raw find "|" };
        _parts pushBack _raw;
        _result = _parts param [["WEST", "EAST", "GUER"] find _side, ""];
        if (_name == "fob_hubs" && {_result == ""}) then {
            _result = ["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V3_F", "Land_Cargo_HQ_V2_F"] param [["WEST", "EAST", "GUER"] find _side, "Land_Cargo_HQ_V1_F"];
        };
    };

    // The headquarters buildings a side may deploy (Lenahan on Discord, 20 Oct: patrol bases all looked the same): the
    // side's pick from Headquarters Buildings, which can name several classes separated by commas. Only classes the
    // game has; the side's default when none is usable.
    case "hubChoices": {
        _args params [["_side", "WEST", [""]]];
        private _raw = [_logic, "perSide", ["fob_hubs", _side]] call MAINCLASS;
        _result = (_raw splitString ", ;") select { isClass (configFile >> "CfgVehicles" >> _x) };
        if (_result isEqualTo []) then {
            _result = [["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V3_F", "Land_Cargo_HQ_V2_F"] param [["WEST", "EAST", "GUER"] find _side, "Land_Cargo_HQ_V1_F"]];
        };
    };

    // The FOB Types module's list, read once at start (and by typesReload): one type per line, or
    // types separated by |, each a set of key=value pairs separated by ; in any order. Published
    // as ALiVE_FOB_types, one row per type:
    // [id, name, prefix, marker, hubs, extras, removals, role, who, names, cost, cap]
    case "typesParse": {
        private _tm = _logic getVariable ["ALiVE_FOB_typesModule", objNull];
        private _raw = if (isNull _tm) then { "" } else { _tm getVariable ["fob_types", ""] };
        if !(_raw isEqualType "") then { _raw = "" };
        private _general = if (isNull _tm) then { true } else { _tm getVariable ["fob_types_general", true] };
        if (_general isEqualType "") then { _general = toLower _general != "false" };
        if !(_general isEqualType true) then { _general = true };
        private _okChars = "abcdefghijklmnopqrstuvwxyz0123456789_";
        private _rows = [];
        {
            private _line = trim _x;
            if (_line != "" && {(_line select [0, 2]) != "//"}) then {
                private _h = createHashMap;
                {
                    private _at = _x find "=";
                    if (_at > 0) then { _h set [toLower trim (_x select [0, _at]), trim (_x select [_at + 1])] };
                } forEach (_line splitString ";");
                private _name = (_h getOrDefault ["name", ""]) select [0, 24];
                private _id = toLower (_h getOrDefault ["id", _name]);
                _id = (_id splitString "") apply { [_x, "_"] select ((_okChars find _x) < 0) } joinString "";
                if (_name == "") then { _name = _id };
                switch (true) do {
                    case (_id == "" || {_id == "general"}): {
                        ["ALiVE Player FOBs - FOB Types: the type '%1' has no usable id (general is kept for the plain FOB); left out", _line] call ALiVE_fnc_dumpR;
                    };
                    case ((_rows findIf { (_x select 0) == _id }) >= 0): {
                        ["ALiVE Player FOBs - FOB Types: two types have the id %1; only the first is used", _id] call ALiVE_fnc_dumpR;
                    };
                    default {
                        private _prefix = (_h getOrDefault ["prefix", "FOB"]) select [0, 8];
                        if (_prefix == "") then { _prefix = "FOB" };
                        private _marker = _h getOrDefault ["marker", ""];
                        if (_marker == "" || {!isClass (configFile >> "CfgMarkers" >> _marker)}) then {
                            if (_marker != "") then { ["ALiVE Player FOBs - FOB Types: %1's marker %2 isn't a map marker in this game; using a flag", _id, _marker] call ALiVE_fnc_dumpR };
                            _marker = "mil_flag";
                        };
                        private _hubs = (_h getOrDefault ["hubs", ""]) splitString ", ";
                        {
                            ["ALiVE Player FOBs - FOB Types: %1's headquarters %2 isn't in this game; left out", _id, _x] call ALiVE_fnc_dumpR;
                        } forEach (_hubs select { !isClass (configFile >> "CfgVehicles" >> _x) });
                        _hubs = _hubs select { isClass (configFile >> "CfgVehicles" >> _x) };
                        private _plus = [];
                        private _minus = [];
                        {
                            switch (_x select [0, 1]) do {
                                case "-": { _minus pushBackUnique toLower (_x select [1]) };
                                case "+": { _plus pushBackUnique toLower (_x select [1]) };
                                default { _plus pushBackUnique toLower _x };
                            };
                        } forEach ((_h getOrDefault ["build", ""]) splitString ", ");
                        _plus = _plus - [""]; _minus = _minus - [""];
                        private _role = toLower (_h getOrDefault ["role", "none"]);
                        if !(_role in ["none", "fire_base", "logistics", "medical", "patrol_base"]) then { _role = "none" };
                        // who: SIDE, LEADER or LIST; anything else is said, and none left means SIDE,
                        // so a typo never hides a type from everyone
                        private _words = (toUpper (_h getOrDefault ["who", "SIDE"])) splitString "[]""', ";
                        {
                            ["ALiVE Player FOBs - FOB Types: %1's who has %2, which isn't SIDE, LEADER or LIST; left out", _id, _x] call ALiVE_fnc_dumpR;
                        } forEach (_words - ["SIDE", "LEADER", "LIST"]);
                        _words = _words arrayIntersect ["SIDE", "LEADER", "LIST"];
                        if (_words isEqualTo []) then {
                            if ((_h getOrDefault ["who", ""]) != "") then { ["ALiVE Player FOBs - FOB Types: %1 names nobody who may deploy it; anyone on the side may", _id] call ALiVE_fnc_dumpR };
                            _words = ["SIDE"];
                        };
                        private _who = _words joinString ",";
                        private _cost = (parseNumber (_h getOrDefault ["cost", "0"])) max 0;
                        private _cap = ((round parseNumber (_h getOrDefault ["cap", "0"])) max 0) min 12;
                        // A type's own Player FOBs settings, in place of the module's (A. Ares on Discord, 23 Oct):
                        // respawn (the tier its respawn point comes at, 0 or off for none), supply (what a new one
                        // starts with) and trickle (supply per minute). Left out, the module's setting.
                        private _own = [];
                        {
                            _x params ["_key", "_attr"];
                            private _v = trim (_h getOrDefault [_key, ""]);
                            if (_key == "respawn" && {(toLower _v) in ["off", "none", "no"]}) then { _v = "0" };
                            if (_v != "") then {
                                if (_v regexMatch "\d+(\.\d+)?") then {
                                    private _range = (_settings get _attr) select 1;
                                    private _n = ((parseNumber _v) max (_range select 0)) min (_range select 1);
                                    if (_key == "respawn") then { _n = round _n };
                                    if (_n != parseNumber _v) then {
                                        ["ALiVE Player FOBs - FOB Types: %1's %2 of %3 is out of range, so %4 is used", _id, _key, _v, _n] call ALiVE_fnc_dumpR;
                                    };
                                    _own pushBack [_attr, _n];
                                } else {
                                    ["ALiVE Player FOBs - FOB Types: %1's %2 is %3, which isn't 0 or more; the Player FOBs setting is used", _id, _key, _v] call ALiVE_fnc_dumpR;
                                };
                            };
                        } forEach [["respawn", "fob_respawn"], ["supply", "fob_supply_initial"], ["trickle", "fob_supply_trickle"]];
                        _rows pushBack [_id, _name, _prefix, _marker, _hubs, _plus, _minus, _role, _who, _h getOrDefault ["list", ""], _cost, _cap, _own];
                    };
                };
            };
        } forEach (_raw splitString (toString [10, 13] + "|"));
        if (!isNull _tm && {_rows isEqualTo []}) then {
            ["ALiVE Player FOBs - FOB Types is synced but lists no usable type; every FOB is a plain FOB"] call ALiVE_fnc_dumpR;
        };
        // in the FOB's own supply a type cost more than a new FOB starts with can never be paid
        if (([_logic, "attribute", ["fob_supply_source"]] call MAINCLASS) != "FORCEPOOL") then {
            private _start = [_logic, "attribute", ["fob_supply_initial"]] call MAINCLASS;
            {
                private _own = _x select 12;
                private _i = _own findIf { (_x select 0) == "fob_supply_initial" };
                private _from = if (_i < 0) then { _start } else { (_own select _i) select 1 };
                private _cap1 = [_logic, "attribute", ["fob_supply_cap_t1"]] call MAINCLASS;
                if (_i >= 0 && {_from > _cap1}) then {
                    ["ALiVE Player FOBs - FOB Types: %1 starts with %2 supply, above the Tier 1 supply limit of %3, so it gains none until it spends below it", _x select 0, _from, _cap1] call ALiVE_fnc_dumpR;
                };
                if ((_x select 10) > _from) then {
                    ["ALiVE Player FOBs - FOB Types: %1 costs %2 but a new FOB starts with %3 supply, so it can never be deployed", _x select 0, _x select 10, _from] call ALiVE_fnc_dumpR;
                };
            } forEach _rows;
        };
        ALiVE_FOB_types = _rows;
        ALiVE_FOB_typesGeneral = _general || {_rows isEqualTo []};
        publicVariable "ALiVE_FOB_types";
        publicVariable "ALiVE_FOB_typesGeneral";
        if (_rows isNotEqualTo []) then {
            ["ALiVE Player FOBs - FOB types: %1%2", _rows apply { _x select 0 }, ["", " and the plain FOB"] select ALiVE_FOB_typesGeneral] call ALiVE_fnc_dump;
        };
        _result = count _rows;
    };

    // The FOB Types module's list read again, for a probe. Only the list: an extra it adds isn't in
    // the build catalog until the next start, and FOBs keep the type they have until then.
    case "typesReload": {
        _result = [_logic, "typesParse"] call MAINCLASS;
    };

    // A type's row: "" is the plain FOB; [] for a type the mission doesn't have. Works on any machine.
    case "typeSpec": {
        _args params [["_id", "", [""]]];
        _result = if (_id == "") then {
            ["", localize "STR_ALIVE_FOB_TYPE_GENERAL", "FOB", "mil_flag", [], [], [], "none", "SIDE", "", 0, 0, []]
        } else {
            private _types = missionNamespace getVariable ["ALiVE_FOB_types", []];
            _types param [_types findIf { (_x select 0) == _id }, []]
        };
    };

    // A Player FOBs setting for a FOB of this type: the type's own when it sets one (typesParse), else the module's
    case "typeAttribute": {
        _args params [["_type", "", [""]], ["_name", "", [""]]];
        private _own = ([_logic, "typeSpec", [_type]] call MAINCLASS) param [12, []];
        private _at = _own findIf { (_x select 0) == _name };
        _result = if (_at < 0) then { [_logic, "attribute", [_name]] call MAINCLASS } else { (_own select _at) select 1 };
    };

    // The types a FOB kit can become, plain FOB first when it's offered. Works on any machine.
    case "types": {
        private _types = missionNamespace getVariable ["ALiVE_FOB_types", []];
        _result = +_types;
        if (_types isEqualTo [] || {missionNamespace getVariable ["ALiVE_FOB_typesGeneral", true]}) then {
            _result = [[_logic, "typeSpec", [""]] call MAINCLASS] + _result;
        };
    };

    // The headquarters buildings for a type: its own, else the side's (hubChoices)
    case "hubChoicesFor": {
        _args params [["_side", "WEST", [""]], ["_type", "", [""]]];
        private _spec = [_logic, "typeSpec", [_type]] call MAINCLASS;
        _result = (_spec param [4, []]) select { isClass (configFile >> "CfgVehicles" >> _x) };
        if (_result isEqualTo []) then { _result = [_logic, "hubChoices", [_side]] call MAINCLASS };
    };

    // Whether a FOB of a type may build a class: a type's removals never, its extras always, and an
    // extra only a type brings (one the catalog didn't have anyway, ALiVE_FOB_typeOnly) only at the
    // types that list it. With no types, everything. Works on any machine.
    case "typeAllows": {
        _args params [["_type", "", [""]], ["_class", "", [""]]];
        private _types = missionNamespace getVariable ["ALiVE_FOB_types", []];
        _result = true;
        if (_types isEqualTo []) exitWith {};
        private _c = toLower _class;
        private _spec = [_logic, "typeSpec", [_type]] call MAINCLASS;
        if (_spec isEqualTo []) then { _spec = [_logic, "typeSpec", [""]] call MAINCLASS };
        if (_c in (_spec select 6)) exitWith { _result = false };
        if (_c in (_spec select 5)) exitWith {};
        // before the build scan has run every extra counts as a type's own
        private _typeOnly = missionNamespace getVariable ["ALiVE_FOB_typeOnly", nil];
        _result = if (isNil "_typeOnly") then { (_types findIf { _c in (_x select 5) }) < 0 } else { !(_c in _typeOnly) };
    };

    // Whether a player may deploy a type: an admin always, the plain FOB anyone, a type by its own
    // who and names (The Player Who Deployed It means nothing before there is a FOB)
    case "mayDeployType": {
        _args params [["_unit", objNull, [objNull]], ["_type", "", [""]]];
        _result = false;
        if (isNull _unit) exitWith {};
        if (_type == "" || {[_logic, "isAdmin", [_unit]] call MAINCLASS}) exitWith { _result = true };
        private _spec = [_logic, "typeSpec", [_type]] call MAINCLASS;
        if (_spec isEqualTo []) exitWith {};
        private _rules = (((_spec select 8) splitString "[]""', ") - ["DEPLOYER"]) joinString ",";
        _result = [_logic, "mayWho", [_unit, _rules, _spec select 9, "~"]] call MAINCLASS;
    };

    case "nextID": {
        _args params [["_side", "WEST", [""]]];
        ALiVE_FOB_counter = ALiVE_FOB_counter + 1;
        _result = format ["FOB_%1_%2", toUpper _side, ALiVE_FOB_counter];
    };

    // A new entry, every key present so readers never meet a missing field
    case "newEntry": {
        _args params [["_id", "", [""]], ["_side", "WEST", [""]], ["_faction", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_hub", "", [""]], ["_type", "", [""]]];
        private _spec = [_logic, "typeSpec", [_type]] call MAINCLASS;
        if (_spec isEqualTo []) then { _type = ""; _spec = [_logic, "typeSpec", [""]] call MAINCLASS };
        // the building the player chose, if it's one this side (or this type) may deploy; else the first
        private _hubs = [_logic, "hubChoicesFor", [_side, _type]] call MAINCLASS;
        if !(_hub in _hubs) then { _hub = _hubs select 0 };
        private _names = ["Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike",
            "November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu"];
        private _n = parseNumber ((_id splitString "_") param [2, "0"]);
        _result = [] call ALIVE_fnc_hashCreate;
        {
            [_result, _x select 0, _x select 1] call ALIVE_fnc_hashSet;
        } forEach [
            ["id", _id], ["side", _side], ["faction", _faction],
            ["name", (_spec select 2) + " " + (_names select ((_n - 1) max 0) % 26)], ["type", _type],
            ["pos", _pos], ["dir", _dir], ["status", "active"], ["tier", 1],
            ["supply", [_logic, "typeAttribute", [_type, "fob_supply_initial"]] call MAINCLASS],
            ["hubClass", _hub], ["hub", objNull],
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

    // What players' machines see: [id, side, name, pos, status, tier, supply, supplyCap, buildRange, deployedBy, type]
    // Each side's FOBs and its FOB limit, [[side, FOBs, limit], ...], for players' deploy
    // previews; sent only when it changed
    case "broadcastRoom": {
        private _room = ["WEST", "EAST", "GUER"] apply { [_x, ["countForSide", [_x]] call ALiVE_fnc_fobCap, ["capForSide", [_x]] call ALiVE_fnc_fobCap] };
        if !(_room isEqualTo (missionNamespace getVariable ["ALiVE_FOB_sideRoom", []])) then {
            ALiVE_FOB_sideRoom = _room;
            publicVariable "ALiVE_FOB_sideRoom";
        };
        _result = _room;
    };

    case "broadcastMirror": {
        private _range = [_logic, "attribute", ["fob_build_range"]] call MAINCLASS;
        ALiVE_FOB_registryMirror = (ALiVE_FOB_registry select 1) apply {
            private _e = [ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet;
            [_x, [_e, "side"] call ALIVE_fnc_hashGet, [_e, "name"] call ALIVE_fnc_hashGet, [_e, "pos"] call ALIVE_fnc_hashGet,
             [_e, "status"] call ALIVE_fnc_hashGet, [_e, "tier"] call ALIVE_fnc_hashGet,
             ["balance", [_x]] call ALiVE_fnc_fobSupply, ["cap", [_x]] call ALiVE_fnc_fobSupply, _range,
             [_e, "deployedBy", ""] call ALIVE_fnc_hashGet, [_e, "type", ""] call ALIVE_fnc_hashGet]
        };
        publicVariable "ALiVE_FOB_registryMirror";
        [_logic, "broadcastRoom"] call MAINCLASS;
        // A hosted server's own player gets no public variable event for its own send
        if (hasInterface) then { [] call ALiVE_fnc_fobMarkers; ["manageRefresh"] call ALiVE_fnc_fobActions };
        _result = count ALiVE_FOB_registryMirror;
    };
};

_result
