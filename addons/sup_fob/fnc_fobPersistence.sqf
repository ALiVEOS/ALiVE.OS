#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobPersistence);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_fobPersistence

Description:
Saves the FOBs and loads them back. The document is a CBA hash holding "data", the shape the
AI Commander saves its extras in (fnc_OPCOM.sqf), so both ALiVE Data backends take it: the
War Room one reads "_rev" off anything whose first element is text, and a bare array would
fail there. "data" is ["v2", counter, rows], each row the entry's key/value pairs.

Only what can be rebuilt is saved: the headquarters is recreated from its class and spot,
built objects from their class, world position and attitude (read off the live object at save,
skipping anything destroyed, so a demolished wall isn't rebuilt for free), and every timer as
the seconds it has left. Nothing depends on a wreck still being there.

With an ALiVE Data module the FOBs go where the rest of the mission is saved; without one they
go into the server's profile. A save happens only when something changed, and at most once per
Save Interval, unless forced (an autosave or SERVER SAVE AND EXIT forces one).

Parameters:
String - The operation
Array - Its arguments

Returns:
serialise - [] -> the "data" value
deserialise - [data] -> true when it was read
save - [force] -> true when written
load - [] -> true when something was loaded

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {false};

params [["_operation", "", [""]], ["_args", [], [[]]]];

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _set = { [_logic, "attribute", [_this]] call ALiVE_fnc_FOB };
private _debug = "fob_debug" call _set;
private _runtime = ["hub", "engineerNear", "dirty", "respawn", "garrisonNext"];
private _useData = !isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED};
// The key the FOBs are saved under: ALiVE Data's own form when the mission has ALiVE Data (its
// group id is only set then), the mission and map otherwise
private _key = if (isNil "ALIVE_sys_data_GROUP_ID") then {
    format ["ALiVE_FOB_%1:%2", [missionName, "%20", "-"] call CBA_fnc_replace, worldName]
} else {
    (["_FOB"] call ALiVE_fnc_storeKeys) select 0
};
private _result = false;

switch (_operation) do {

    case "serialise": {
        private _rows = [];
        {
            private _entry = [ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet;
            private _pairs = [];
            {
                private _k = _x;
                if !(_k in _runtime) then {
                    private _v = [_entry, _k] call ALIVE_fnc_hashGet;
                    if (_k == "objects") then {
                        // static weapons as their profile ids, place and heading; built objects as
                        // class, world position and attitude, read off the live object
                        _v = (_v select { (_x select 0) in ["static", "vehicle"] || {(_x select 0) isEqualType objNull && {!isNull (_x select 0)} && {alive (_x select 0)} && {damage (_x select 0) < 1}} })
                            apply { if ((_x select 0) in ["static", "vehicle"]) then { +_x } else { [_x select 1, getPosWorld (_x select 0), vectorDir (_x select 0), vectorUp (_x select 0), _x select 2] } };
                    };
                    _pairs pushBack [_k, _v];
                };
            } forEach (_entry select 1);
            _rows pushBack _pairs;
        } forEach (ALiVE_FOB_registry select 1);
        _result = ["v2", ALiVE_FOB_counter, _rows];
    };

    case "deserialise": {
        _args params [["_data", [], [[]]]];
        if !((_data param [0, ""]) isEqualTo "v2") exitWith {
            ["ALiVE Player FOBs - the saved FOBs aren't in a form this build reads (%1); starting without them", _data param [0, "nothing"]] call ALiVE_fnc_dumpR;
        };
        ALiVE_FOB_counter = (_data param [1, 0]) max ALiVE_FOB_counter;
        {
            private _entry = [] call ALIVE_fnc_hashCreate;
            { [_entry, _x select 0, _x select 1] call ALIVE_fnc_hashSet } forEach _x;
            [_entry, "hub", objNull] call ALIVE_fnc_hashSet;
            private _id = [_entry, "id", ""] call ALIVE_fnc_hashGet;
            if (_id != "") then { [ALiVE_FOB_registry, _id, _entry] call ALIVE_fnc_hashSet };
        } forEach (_data param [2, []]);
        _result = true;
    };

    case "save": {
        _args params [["_force", false, [false]]];
        if !("fob_persistent" call _set) exitWith {};
        private _last = missionNamespace getVariable ["ALiVE_FOB_lastSave", -1e9];
        if (!_force && {!ALiVE_FOB_dirty || {time - _last < ("fob_save_interval" call _set)}}) exitWith {};

        private _plain = ["serialise"] call ALiVE_fnc_fobPersistence;
        if (_useData) then {
            if (isNil QGVAR(DATAHANDLER)) then {
                GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                [GVAR(DATAHANDLER), "storeType", true] call ALIVE_fnc_Data;
            };
            private _doc = [[["data", _plain]]] call CBA_fnc_hashCreate;
            // The War Room backend updates a document by its revision; without it a second save
            // would be refused as a conflict
            private _prev = [GVAR(DATAHANDLER), "read", ["sup_fob", [], _key]] call ALIVE_fnc_Data;
            if (_prev isEqualType [] && {count _prev > 0}) then {
                private _rev = [_prev, "_rev"] call CBA_fnc_hashGet;
                if (!isNil "_rev") then { [_doc, "_rev", _rev] call CBA_fnc_hashSet };
            };
            _result = [GVAR(DATAHANDLER), "write", ["sup_fob", _doc, false, _key]] call ALIVE_fnc_Data;
            // The Local backend answers empty text when it has written; only an explicit false is a failure
            _result = !(!isNil "_result" && {_result isEqualTo false});
        } else {
            profileNamespace setVariable [_key, _plain];
            saveProfileNamespace;
            _result = true;
        };
        ALiVE_FOB_dirty = false;
        ALiVE_FOB_lastSave = time;
        if (_debug) then { ["ALiVE Player FOBs - saved %1 FOBs to %2 (%3): %4", count (_plain select 2), _key, ["profile", "ALiVE Data"] select _useData, _result] call ALiVE_fnc_dump };
    };

    case "load": {
        private _plain = [];
        if (_useData) then {
            if (isNil QGVAR(DATAHANDLER)) then {
                GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                [GVAR(DATAHANDLER), "storeType", true] call ALIVE_fnc_Data;
            };
            private _doc = [GVAR(DATAHANDLER), "read", ["sup_fob", [], _key]] call ALIVE_fnc_Data;
            if (_doc isEqualType [] && {count _doc > 0}) then {
                private _d = [_doc, "data"] call CBA_fnc_hashGet;
                if (!isNil "_d") then { _plain = _d };
            };
        } else {
            _plain = profileNamespace getVariable [_key, []];
        };
        if (_plain isEqualTo []) exitWith {
            if (_debug) then { ["ALiVE Player FOBs - nothing saved under %1", _key] call ALiVE_fnc_dump };
        };
        _result = ["deserialise", [_plain]] call ALiVE_fnc_fobPersistence;
        ["ALiVE Player FOBs - loaded %1 FOBs from %2", count (ALiVE_FOB_registry select 1), _key] call ALiVE_fnc_dump;
    };
};

_result
