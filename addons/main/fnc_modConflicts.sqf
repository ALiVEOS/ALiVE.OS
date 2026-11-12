#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(modConflicts);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_modConflicts

Description:
Mods known to interfere with ALiVE (CfgALiVEModConflicts): found at mission start, reported, and, under
Guard, kept off the groups and units ALiVE makes through each mod's own opt-out variables.

Parameters:
String - operation
Array - arguments

Operations:
"init"  [module]  - every machine: read the setting, find the mods, log them, notify, get ready to guard
"detect"          - the CfgALiVEModConflicts classes loaded on this machine
"guard" [group]   - the opt-outs on a group ALiVE made and every unit in it
"unit"  [unit]    - the opt-outs on one unit ALiVE made (for units added to a guarded group later)

The setting, on the ALiVE (Required) module, is ALiVE_MODCONFLICTS: "GUARD" (the default), "WARN" or "OFF".

Examples:
(begin example)
["guard", [_group]] call ALiVE_fnc_modConflicts;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", ""], ["_args", []]];
private _result = nil;

switch (_operation) do {

    case "detect": {
        _result = [];
        {
            private _cfg = _x;
            private _patches = getArray (_cfg >> "patches");
            private _missionVar = getText (_cfg >> "missionVar");
            if ((_patches findIf { isClass (configFile >> "CfgPatches" >> _x) }) >= 0
                || {_missionVar != "" && {!isNil {missionNamespace getVariable _missionVar}}}) then {
                _result pushBack configName _cfg;
            };
        } forEach ("true" configClasses (configFile >> "CfgALiVEModConflicts"));
    };

    case "init": {
        _args params [["_module", objNull]];
        private _mode = toUpper (_module getVariable [QMOD(MODCONFLICTS), "GUARD"]);
        if !(_mode in ["GUARD", "WARN", "OFF"]) then { _mode = "GUARD" };
        MOD(MODCONFLICTS_MODE) = _mode;

        private _cfgRoot = configFile >> "CfgALiVEModConflicts";
        private _where = if (isServer) then { "server" } else { if (hasInterface) then { "this client" } else { "this headless client" } };
        private _fnc_log = {
            {
                private _cfg = _cfgRoot >> _x;
                private _handling = getText (_cfg >> "handling");
                ["ALiVE mod conflicts: %1 is loaded on %2: %3. %4", getText (_cfg >> "name"), _where, getText (_cfg >> "effect"),
                    switch (true) do {
                        case (_mode == "OFF"): { "The ALiVE (Required) module's mod setting is Off, so nothing is done about it." };
                        case (_mode == "WARN"): { "The setting is Warn, so ALiVE's AI is left to it." };
                        case (_handling == ""): { "The mod gives no way to leave ALiVE's AI out, so this is a warning only." };
                        default { "Guard: " + _handling + "." };
                    }] call ALiVE_fnc_dump;
            } forEach _this;
        };
        // what Guard sets: from this machine's mods and the server's, since a group can move to a headless client
        private _fnc_guardLists = {
            params ["_mods"];
            private _lists = [[], [], []];
            if (_mode == "GUARD") then {
                {
                    (_lists select 0) append getArray (_cfgRoot >> _x >> "groupVars");
                    (_lists select 1) append getArray (_cfgRoot >> _x >> "unitVars");
                    (_lists select 2) append getArray (_cfgRoot >> _x >> "unitVarsWithBehaviour");
                } forEach _mods;
            };
            MOD(MODCONFLICTS_GUARD) = _lists;
        };

        // The server is ready to guard before the first group is made
        private _found = ["detect"] call ALiVE_fnc_modConflicts;
        if (isServer) then {
            [_found] call _fnc_guardLists;
            MOD(MODCONFLICTS_SERVER) = _found;
            publicVariable QMOD(MODCONFLICTS_SERVER);
        };
        // a mission-script VCOM sets its variable from the mission's own init, so look again once that has run
        sleep 10;
        private _late = (["detect"] call ALiVE_fnc_modConflicts) - _found;
        _found append _late;
        if (isServer) then {
            if (_late isNotEqualTo []) then {
                [_found] call _fnc_guardLists;
                MOD(MODCONFLICTS_SERVER) = _found;
                publicVariable QMOD(MODCONFLICTS_SERVER);
            };
        } else {
            private _t = diag_tickTime;
            waitUntil { sleep 1; !isNil QMOD(MODCONFLICTS_SERVER) || {diag_tickTime - _t > 120} };
        };
        _found call _fnc_log;
        private _serverFound = missionNamespace getVariable [QMOD(MODCONFLICTS_SERVER), []];
        if (!isServer) then { [_found + (_serverFound - _found)] call _fnc_guardLists };

        // Notifications. Admins (and a single-player or hosted game) hear about the server's mods once; a player
        // whose own machine loads a listed mod the server doesn't hears about that one, as it acts on AI local to him.
        if (hasInterface && {_mode != "OFF"}) then {
            private _fnc_line = {
                private _cfg = _cfgRoot >> _this;
                format ["<br/>%1: %2.", getText (_cfg >> "name"), getText (_cfg >> "effect")]
            };
            waitUntil { sleep 1; !isNull player };
            sleep 20;
            private _isAdmin = isServer || {serverCommandAvailable "#kick"};
            if (_isAdmin && {_serverFound isNotEqualTo []}) then {
                private _text = "Mods on the server that change ALiVE's AI:" + ((_serverFound apply { _x call _fnc_line }) joinString "")
                    + (if (_mode == "GUARD") then { "<br/>The mission's mod setting is Guard: ALiVE keeps its own AI out of them where the mod allows it." } else { "<br/>The mission's mod setting is Warn: ALiVE's AI is left to them." });
                ["ALiVE", _text] call ALIVE_fnc_sendHint;
            };
            private _ownOnly = _found - _serverFound;
            if (!isServer && {_ownOnly isNotEqualTo []}) then {
                private _text = "Your game loads mods the server doesn't, which can change the AI your machine runs:" + ((_ownOnly apply { _x call _fnc_line }) joinString "")
                    + "<br/>Unload them for this mission to play it as it was made.";
                ["ALiVE", _text] call ALIVE_fnc_sendHint;
            };
        };
    };

    case "guard": {
        _args params [["_group", grpNull]];
        if (isNull _group || {(missionNamespace getVariable [QMOD(MODCONFLICTS_MODE), "GUARD"]) != "GUARD"}) exitWith {};
        private _guard = missionNamespace getVariable [QMOD(MODCONFLICTS_GUARD), [[], [], []]];
        if (_guard isEqualTo [[], [], []]) exitWith {};
        // a group a player leads is his, not ALiVE's
        if (isPlayer leader _group) exitWith {};
        { _group setVariable [_x, true, true] } forEach (_guard select 0);
        { ["unit", [_x]] call ALiVE_fnc_modConflicts } forEach units _group;
    };

    case "unit": {
        _args params [["_unit", objNull]];
        if (isNull _unit || {isPlayer _unit} || {(missionNamespace getVariable [QMOD(MODCONFLICTS_MODE), "GUARD"]) != "GUARD"}) exitWith {};
        private _guard = missionNamespace getVariable [QMOD(MODCONFLICTS_GUARD), [[], [], []]];
        { _unit setVariable [_x, true, true] } forEach (_guard select 1);
        if ((_guard select 2) isNotEqualTo [] && {!isNil "ALiVE_fnc_AIBehaviour"} && {["setting", ["behaviourEnabled", false]] call ALiVE_fnc_AIBehaviour}) then {
            { _unit setVariable [_x, true, true] } forEach (_guard select 2);
        };
    };
};

if (isNil "_result") then { nil } else { _result };
