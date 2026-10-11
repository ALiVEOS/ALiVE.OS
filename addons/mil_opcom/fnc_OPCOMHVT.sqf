#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOMHVT);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMHVT

Description:
The AI Commander's high value target (#625). With the commander's High Value
Target setting on, a named officer of its faction, with a guard group, is placed
at its most important objective and kept out of its orders. Intel read from the
bodies of the commander's men sometimes marks where he was last seen. Killing him
pauses the commander's new attacks for the time the setting gives, and his
enemies are told. Server only.

Parameters:
String - operation: "place", "reveal", "notify"
Array - arguments
    place:  [handler]
    reveal: [side object of the dead man whose intel was read]
    notify: [stringtable key, officer's name] (run on clients, so each reads it in its own language)

Returns:
Nothing

Examples:
(begin example)
["place", [_handler]] call ALiVE_fnc_OPCOMHVT;
["reveal", [east]] call ALiVE_fnc_OPCOMHVT;
(end)

See Also:
ALiVE_fnc_OPCOM, ALiVE_fnc_OPCOMToggleInstallations

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", []]];

if (_operation == "notify") exitWith {
    if (!hasInterface) exitWith {};
    _args params [["_key", "", [""]], ["_name", "", [""]]];
    [["TaskSucceeded", "TaskFailed"] select (_key == "STR_ALIVE_OPCOM_HVT_KILLED_OWN"), ["", format [localize _key, _name]]] call BIS_fnc_showNotification;
};

if (!isServer) exitWith {};

// The record kept on the commander: [name, profile ID, "alive"|"dead", seconds of the attack pause
// left when the mission was saved, guard profile IDs]
private _fnc_record = { params ["_h"]; [_h, "hvtRecord", []] call ALiVE_fnc_HashGet };

// Watch him: a profile that's gone, or whose men are all dead, is a dead HVT. The position is
// kept public for the reveal while he lives.
private _fnc_watch = {
    params ["_h"];
    [_h] spawn {
        params ["_h"];
        private _module = [_h, "module"] call ALiVE_fnc_HashGet;
        private _sideText = [_h, "side", "EAST"] call ALiVE_fnc_HashGet;
        private _strikes = 0;
        while { ((([_h, "hvtRecord", []] call ALiVE_fnc_HashGet) param [2, ""]) == "alive") } do {
            sleep 15;
            private _rec = [_h, "hvtRecord", []] call ALiVE_fnc_HashGet;
            private _prof = [ALIVE_profileHandler, "getProfile", _rec select 1] call ALIVE_fnc_profileHandler;
            private _dead = isNil "_prof";
            if (!_dead && {[_prof, "active", false] call ALiVE_fnc_HashGet}) then {
                private _units = [_prof, "units", []] call ALiVE_fnc_HashGet;
                // a profile despawning between these reads has its men deleted, not killed: still
                // spawned afterwards is what makes all-dead men a death
                _dead = (_units isNotEqualTo []) && {(_units findIf { alive _x }) < 0} && {[_prof, "active", false] call ALiVE_fnc_HashGet};
            };
            // two readings in a row, 15 s apart, before he counts as killed
            _strikes = [0, _strikes + 1] select _dead;
            if (_strikes >= 2) then {
                _rec set [2, "dead"];
                [_h, "hvtRecord", _rec] call ALiVE_fnc_HashSet;
                private _hold = [_h, "hvt", 0] call ALiVE_fnc_HashGet;
                _module setVariable ["ALiVE_HVT_holdUntil", time + _hold];
                deleteMarker format ["ALiVE_HVT_%1", [_h, "opcomID", ""] call ALiVE_fnc_HashGet];
                ["OPCOM %1: high value target %2 killed; new attacks held for %3 s", _sideText, _rec select 0, _hold] call ALiVE_fnc_dump;
                private _side = [_sideText] call ALiVE_fnc_sideTextToObject;
                {
                    private _key = ["STR_ALIVE_OPCOM_HVT_KILLED_ENEMY", "STR_ALIVE_OPCOM_HVT_KILLED_OWN"] select ((_side getFriend _x) >= 0.6);
                    ["notify", [_key, _rec select 0]] remoteExec ["ALiVE_fnc_OPCOMHVT", _x];
                } forEach [west, east, resistance];
            };
        };
    };
};

switch (_operation) do {

    case "place": {
        _args params [["_h", []]];
        if !([_h] call ALiVE_fnc_isHash) exitWith {};
        if (([_h, "hvt", 0] call ALiVE_fnc_HashGet) <= 0) exitWith {};

        // A record loaded with the commander (a saved mission): he isn't placed again. A dead one
        // stays dead, with what was left of the pause; a live one is watched again, unless his
        // profile didn't come back with the mission (profiles not saved), when a new one is placed.
        private _rec = [_h] call _fnc_record;
        private _done = false;
        if (_rec isNotEqualTo []) then {
            if ((_rec param [2, ""]) == "dead") exitWith {
                _done = true;
                private _left = _rec param [3, 0];
                if (_left > 0) then { ([_h, "module"] call ALiVE_fnc_HashGet) setVariable ["ALiVE_HVT_holdUntil", time + _left] };
            };
            if !(isNil {[ALIVE_profileHandler, "getProfile", _rec select 1] call ALIVE_fnc_profileHandler}) exitWith {
                _done = true;
                // a reload brings his pin back but not his post: garrisoned again, guards too
                {
                    private _p = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if (!isNil "_p") then {
                        [_p, "busy", true] call ALiVE_fnc_HashSet;
                        [_p, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [_x select 1, "false", [0,0,0], "", 1, _x select 2, "SAFE", "LIMITED", [], true]]] call ALIVE_fnc_profileEntity;
                    };
                } forEach ([[_rec select 1, 30, 0]] + ((_rec param [4, []]) apply { [_x, 40, 0.3] }));
                [_h] call _fnc_watch;
            };
            [_h, "hvtRecord", []] call ALiVE_fnc_HashSet;
        };
        if (_done) exitWith {};

        private _faction = ([_h, "factions", []] call ALiVE_fnc_HashGet) param [0, ""];
        private _sideText = [_h, "side", "EAST"] call ALiVE_fnc_HashGet;
        private _objectives = [_h, "objectives", []] call ALiVE_fnc_HashGet;
        if (_faction == "" || {_objectives isEqualTo []}) exitWith {};

        // His post: the most important objective the commander holds (Military Placement's HQ is
        // 1000). Objectives carry no side, and an invading commander lists the enemy's HQ among
        // its own, so only those it's defending or keeping in reserve count; failing those, the
        // one nearest the commander's own module.
        private _held = _objectives select { ([_x, "opcom_state", ""] call ALiVE_fnc_HashGet) in ["defend","defending","reserve","reserving","idle"] };
        private _best = [];
        if (_held isNotEqualTo []) then {
            _best = _held select 0;
            { if (([_x, "priority", 0] call ALiVE_fnc_HashGet) > ([_best, "priority", 0] call ALiVE_fnc_HashGet)) then { _best = _x } } forEach _held;
        } else {
            private _home = [_h, "position", [0,0,0]] call ALiVE_fnc_HashGet;
            _best = _objectives select 0;
            { if ((([_x, "center", [0,0,0]] call ALiVE_fnc_HashGet) distance2D _home) < (([_best, "center", [0,0,0]] call ALiVE_fnc_HashGet) distance2D _home)) then { _best = _x } } forEach _objectives;
        };
        private _pos = +([_best, "center", [0,0,0]] call ALiVE_fnc_HashGet);

        // An officer of the faction: a class named as one, else any soldier who isn't crew or a
        // pilot. Picked here rather than by the Assassination task's helper, whose fallback, for a
        // faction with no class so named, never returns.
        private _classes = [];
        {
            private _men = ([0, _x, "Man", true] call ALiVE_fnc_findVehicleType) - (missionNamespace getVariable ["ALiVE_MIL_CQB_UNITBLACKLIST", []]);
            private _pick = _men select { private _c = toLower _x; (["officer", "commander", "leader", "captain"] findIf { _c find _x >= 0 }) >= 0 };
            if (_pick isEqualTo []) then { _pick = _men select { private _c = toLower _x; (["crew", "pilot", "diver", "survivor", "unarmed"] findIf { _c find _x >= 0 }) < 0 } };
            if (_pick isNotEqualTo []) exitWith { _faction = _x; _classes = [selectRandom _pick] };
        } forEach ([_h, "factions", []] call ALiVE_fnc_HashGet);
        if (_classes isEqualTo []) exitWith { ["OPCOM %1: no officer class for %2, no high value target", _sideText, _faction] call ALiVE_fnc_dump };

        // A name from the officer's own name list (text, or an array on some mod units), as
        // Civilian Placement names its people
        private _cls = _classes select 0;
        private _gn = configFile >> "CfgVehicles" >> _cls >> "genericNames";
        private _list = if (isArray _gn) then { (getArray _gn) param [0, ""] } else { getText _gn };
        private _names = configFile >> "CfgWorlds" >> "GenericNames" >> _list;
        private _name = getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
        if (isClass _names && {count (_names >> "FirstNames") > 0} && {count (_names >> "LastNames") > 0}) then {
            private _first = _names >> "FirstNames";
            private _last = _names >> "LastNames";
            _name = format ["%1 %2", getText (_first select floor random count _first), getText (_last select floor random count _last)];
        };

        // Pinned (stationary) as roadblock guards are, so a saved mission brings them back held
        // out of the commander's orders; busy from creation so no order reaches them first.
        if (isNil "ALIVE_profileStationary") then { ALIVE_profileStationary = [] call ALIVE_fnc_hashCreate };
        private _hvt = [_classes, _sideText, _faction, _pos, random 360, _faction, true] call ALIVE_fnc_createProfileEntity;
        private _hvtID = [_hvt, "profileID", ""] call ALiVE_fnc_HashGet;
        [ALIVE_profileStationary, _hvtID, true] call ALIVE_fnc_hashSet;
        [_hvt, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [30, "false", [0,0,0], "", 1, 0, "SAFE", "LIMITED", [], true]]] call ALIVE_fnc_profileEntity;

        // His guard: one infantry group, held as he is
        private _guardIDs = [];
        private _grp = ["Infantry", _faction] call ALIVE_fnc_configGetRandomGroup;
        if (_grp != "FALSE") then {
            private _guards = [_grp, _pos getPos [10, random 360], random 360, true, _faction, true, false, "STEALTH"] call ALIVE_fnc_createProfilesFromGroupConfig;
            {
                if (([_x, "type", ""] call ALiVE_fnc_HashGet) == "entity") then {
                    private _gid = [_x, "profileID", ""] call ALiVE_fnc_HashGet;
                    _guardIDs pushBack _gid;
                    [ALIVE_profileStationary, _gid, true] call ALIVE_fnc_hashSet;
                    [_x, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [40, "false", [0,0,0], "", 1, 0.3, "SAFE", "LIMITED", [], true]]] call ALIVE_fnc_profileEntity;
                };
            } forEach _guards;
        };

        [_h, "hvtRecord", [_name, _hvtID, "alive", 0, _guardIDs]] call ALiVE_fnc_HashSet;
        ["OPCOM %1: high value target %2 (%3) placed at %4", _sideText, _name, _cls, mapGridPosition _pos] call ALiVE_fnc_dump;
        [_h] call _fnc_watch;
    };

    case "reveal": {
        // A third of the intel read from the commander's men marks where he was last seen,
        // within a couple of hundred metres, for ten minutes.
        _args params [["_side", sideUnknown, [sideUnknown]]];
        if (isNil "OPCOM_instances") exitWith {};
        {
            private _h = _x;
            private _rec = [_h] call _fnc_record;
            if (
                (_rec param [2, ""]) == "alive"
                && {([[_h, "side", ""] call ALiVE_fnc_HashGet] call ALiVE_fnc_sideTextToObject) == _side}
                && {random 1 < 0.33}
            ) then {
                private _prof = [ALIVE_profileHandler, "getProfile", _rec select 1] call ALIVE_fnc_profileHandler;
                if (!isNil "_prof") then {
                    private _at = ([_prof, "position", [0,0,0]] call ALiVE_fnc_HashGet) getPos [random 200, random 360];
                    private _mk = format ["ALiVE_HVT_%1", [_h, "opcomID", ""] call ALiVE_fnc_HashGet];
                    deleteMarker _mk;
                    createMarker [_mk, _at];
                    _mk setMarkerShape "ICON";
                    _mk setMarkerType "hd_unknown";
                    _mk setMarkerColor "ColorRed";
                    _mk setMarkerText format ["%1 ?", _rec select 0];
                    private _stamp = diag_tickTime;
                    missionNamespace setVariable [_mk, _stamp];
                    [_mk, _stamp] spawn {
                        params ["_mk", "_stamp"];
                        sleep 600;
                        if ((missionNamespace getVariable [_mk, -1]) == _stamp) then { deleteMarker _mk };
                    };
                };
            };
        } forEach OPCOM_instances;
    };
};
