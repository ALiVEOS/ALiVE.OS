#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(ledger);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOLedger
Description:
The air component's record of every airframe it owns, and the only store those
airframes have. One ledger per module instance.

A record is what the CAMPAIGN holds about an airframe. What the airframe is
doing right now is not in here, because the two have different lifetimes: a
sortie ends when the mission does, an airframe is still on the books next time
the save is loaded. Keeping them in one place is what let a destroyed aircraft
come back onto the books and a delivered replacement go missing.

The save is monotone. It may ADD a record and it may DROP one only when this
session watched that airframe die. Anything loaded that this session never
attached to is carried forward untouched, because "the profile did not come
back" and "the aircraft is gone" are not the same thing, and a session that
loaded no profiles at all would otherwise write an empty campaign over a full
one. That guarantee is not a rule applied at save time; it falls out of restore
never dropping a record and markLost refusing a tail this session never saw.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
// create a ledger and put an airframe on the books
_ledger = [nil, "create"] call ALIVE_fnc_ATOLedger;
[_ledger, "setInstance", ["BLU_F_1", "BLU_F"]] call ALIVE_fnc_ATOLedger;
_tail = [_ledger, "createRecord", ["B_Plane_CAS_01_F", "BLU_F", ["airspace_1"],
        [["CAS","Strike"], ["guided"]]]] call ALIVE_fnc_ATOLedger;

(end)

See Also:
<ALIVE_fnc_ATO>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOLedger

// Keys a persistence backend adds to anything it stores. They are not ours and
// must never reach a record, or the next save writes them back as fields and
// the count of "aircraft" grows by two every time a document round-trips.
#define HOUSEKEEPING ["_id","_rev","rev","meta"]

private ["_result"];

TRACE_1("ATO Ledger - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

switch(_operation) do {

    case "create": {
        _result = [[
            ["class", MAINCLASS],
            ["instanceKey", ""],
            ["faction", ""],
            ["nextIndex", 0],
            ["records", [] call ALIVE_fnc_hashCreate]
        ]] call ALIVE_fnc_hashCreate;
    };

    // Which module instance this ledger belongs to. The key is what the save is
    // filed under, so two instances of one faction cannot write over each other.
    case "setInstance": {
        _args params [["_key","",[""]], ["_faction","",[""]]];
        [_logic,"instanceKey",_key] call ALIVE_fnc_hashSet;
        [_logic,"faction",_faction] call ALIVE_fnc_hashSet;
    };

    case "createRecord": {
        _args params [
            ["_class","",[""]],
            ["_faction","",[""]],
            ["_airspace",[],[[]]],
            ["_admission",[],[[]]]
        ];
        _admission params [["_roles",[],[[]]], ["_capabilities",[],[[]]]];

        private _index = [_logic,"nextIndex",0] call ALIVE_fnc_hashGet;
        private _tail = format ["%1_%2", _faction, _index];
        [_logic,"nextIndex",_index + 1] call ALIVE_fnc_hashSet;

        // The callsign is what a person hears on the radio, so it is minted from
        // the faction's display name rather than its classname.
        private _display = getText (configFile >> "CfgFactionClasses" >> _faction >> "displayName");
        if (_display isEqualTo "") then { _display = _faction };

        private _record = [[
            ["tail", _tail],
            ["vehicleClass", _class],
            ["faction", _faction],
            ["airspace", + _airspace],
            ["callsign", format ["%1 %2", _display, _index + 1]],
            ["roles", + _roles],
            ["capabilities", + _capabilities],
            ["home", []],
            ["status", "present"],
            ["lossCount", 0],
            ["replacement", ""],
            ["legacyProfileID", ""],
            // Session-only. Never saved. This is the whole of the monotone
            // guarantee: a tail this session never attached to cannot be
            // declared lost, so it cannot be dropped from the campaign.
            ["attachedThisSession", false]
        ]] call ALIVE_fnc_hashCreate;

        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        [_records,_tail,_record] call ALIVE_fnc_hashSet;
        _result = _tail;
    };

    // Returns a COPY. A caller that wants to change a record calls a setter;
    // handing out the live record is how one store ends up with several owners.
    case "get": {
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _record = [_records,_args,[]] call ALIVE_fnc_hashGet;
        if (_record isEqualTo []) then {
            _result = [];
        } else {
            _result = [_record] call ALIVE_fnc_hashCopy;
        };
    };

    case "view": {
        _result = [[_logic,"records"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashCopy;
    };

    case "setHome": {
        _args params [["_tail","",[""]], ["_home",[],[[]]]];
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _record = [_records,_tail,[]] call ALIVE_fnc_hashGet;
        if (_record isEqualTo []) exitWith { _result = false };
        [_record,"home", + _home] call ALIVE_fnc_hashSet;
        _result = true;
    };

    case "setAdmission": {
        _args params [["_tail","",[""]], ["_roles",[],[[]]], ["_capabilities",[],[[]]]];
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _record = [_records,_tail,[]] call ALIVE_fnc_hashGet;
        if (_record isEqualTo []) exitWith { _result = false };
        [_record,"roles", + _roles] call ALIVE_fnc_hashSet;
        [_record,"capabilities", + _capabilities] call ALIVE_fnc_hashSet;
        _result = true;
    };

    // Attaching is the session saying "I have this airframe in front of me".
    // Only an attached tail may later be declared lost.
    case "markPresent": {
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _record = [_records,_args,[]] call ALIVE_fnc_hashGet;
        if (_record isEqualTo []) exitWith { _result = false };
        [_record,"status","present"] call ALIVE_fnc_hashSet;
        [_record,"attachedThisSession",true] call ALIVE_fnc_hashSet;
        _result = true;
    };

    case "markLost": {
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _record = [_records,_args,[]] call ALIVE_fnc_hashGet;
        if (_record isEqualTo []) exitWith { _result = false };

        // Refused, deliberately. A record this session never attached to has not
        // been observed dying; it simply did not come back, which happens when
        // profile persistence is off, when a load fails, and when a backend read
        // returns a partial result while still reporting success. Dropping it
        // here would delete an airframe from the campaign for good.
        if !([_record,"attachedThisSession",false] call ALIVE_fnc_hashGet) exitWith {
            ["ALIVE_fnc_ATOLedger - markLost refused for %1: never attached this session", _args] call ALiVE_fnc_dump;
            _result = false;
        };

        [_record,"status","lost"] call ALIVE_fnc_hashSet;
        [_record,"lossCount",([_record,"lossCount",0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
        _result = true;
    };

    case "setReplacement": {
        _args params [["_tail","",[""]], ["_replacement","",[""]]];
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _record = [_records,_tail,[]] call ALIVE_fnc_hashGet;
        if (_record isEqualTo []) exitWith { _result = false };
        [_record,"replacement",_replacement] call ALIVE_fnc_hashSet;
        _result = true;
    };

    case "retire": {
        _args params [["_tail","",[""]], ["_reason","",[""]]];
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _record = [_records,_tail,[]] call ALIVE_fnc_hashGet;
        if (_record isEqualTo []) exitWith { _result = false };
        [_record,"status","retired"] call ALIVE_fnc_hashSet;
        [_record,"retiredReason",_reason] call ALIVE_fnc_hashSet;
        _result = true;
    };

    // One hash per record plus a meta document, every value deep copied. The
    // shape matters: a backend walks the payload pair by pair, so a plain array
    // of records would not survive the trip.
    case "snapshot": {
        private _snapshot = [] call ALIVE_fnc_hashCreate;

        private _meta = [[
            ["instanceKey", [_logic,"instanceKey",""] call ALIVE_fnc_hashGet],
            ["faction", [_logic,"faction",""] call ALIVE_fnc_hashGet],
            ["nextIndex", [_logic,"nextIndex",0] call ALIVE_fnc_hashGet],
            ["format", 2]
        ]] call ALIVE_fnc_hashCreate;
        [_snapshot,"meta",_meta] call ALIVE_fnc_hashSet;

        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        // An ALiVE hash is ["", keys, values]: select 1 is the KEYS, select 2 the
        // values. Walking select 1 alone gives keys with no values at all.
        private _values = _records select 2;
        {
            private _copy = [_values select _forEachIndex] call ALIVE_fnc_hashCopy;
            // Session state is not campaign state.
            [_copy,"attachedThisSession"] call ALIVE_fnc_hashRem;
            [_snapshot,_x,_copy] call ALIVE_fnc_hashSet;
        } forEach (_records select 1);

        _result = _snapshot;
    };

    // Never drops a record. Anything without a vehicleClass is not one of ours
    // and is reported rather than discarded silently.
    case "restore": {
        private _incoming = _args;
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _kept = 0;
        private _unplaceable = [];
        private _unknown = [];

        if !([_incoming] call ALIVE_fnc_isHash) exitWith {
            _result = [0,[],[]];
        };

        private _inValues = _incoming select 2;
        {
            private _key = _x;
            private _value = _inValues select _forEachIndex;

            if (_key in HOUSEKEEPING) then {
                if (_key isEqualTo "meta" && {[_value] call ALIVE_fnc_isHash}) then {
                    private _next = [_value,"nextIndex",0] call ALIVE_fnc_hashGet;
                    if (_next > ([_logic,"nextIndex",0] call ALIVE_fnc_hashGet)) then {
                        [_logic,"nextIndex",_next] call ALIVE_fnc_hashSet;
                    };
                };
            } else {
                if !([_value] call ALIVE_fnc_isHash) then {
                    _unknown pushBack _key;
                } else {
                    private _class = [_value,"vehicleClass",""] call ALIVE_fnc_hashGet;
                    if (_class isEqualTo "") then {
                        _unknown pushBack _key;
                    } else {
                        private _record = [_value] call ALIVE_fnc_hashCopy;
                        // Strip whatever the backend stamped inside the record.
                        { [_record,_x] call ALIVE_fnc_hashRem } forEach HOUSEKEEPING;
                        [_record,"tail",_key] call ALIVE_fnc_hashSet;
                        // Loaded, not attached. Until this session sees it, it
                        // cannot be declared lost.
                        [_record,"attachedThisSession",false] call ALIVE_fnc_hashSet;
                        [_records,_key,_record] call ALIVE_fnc_hashSet;
                        _kept = _kept + 1;
                        if (([_record,"home",[]] call ALIVE_fnc_hashGet) isEqualTo []) then {
                            _unplaceable pushBack _key;
                        };
                    };
                };
            };
        } forEach (_incoming select 1);

        _result = [_kept,_unplaceable,_unknown];
    };

    case "projection": {
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _projValues = _records select 2;
        private _out = [];
        {
            private _y = _projValues select _forEachIndex;
            private _home = [_y,"home",[]] call ALIVE_fnc_hashGet;
            _out pushBack [
                _x,
                [_y,"vehicleClass",""] call ALIVE_fnc_hashGet,
                [_y,"airspace",[]] call ALIVE_fnc_hashGet,
                if (count _home > 0) then {_home select 0} else {[0,0,0]},
                if (count _home > 1) then {_home select 1} else {0},
                [_y,"roles",[]] call ALIVE_fnc_hashGet,
                [_y,"capabilities",[]] call ALIVE_fnc_hashGet,
                [_y,"status","present"] call ALIVE_fnc_hashGet
            ];
        } forEach (_records select 1);
        _result = _out;
    };

    // The store is a parameter so the ledger can be tested without a backend.
    // Pass a hash to exercise it offline; pass "sys_data" for the real one.
    case "save": {
        _args params [["_store",[],[[],""]], ["_key","",[""]]];
        if (_key isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOLedger - save refused: no instance key"] call ALiVE_fnc_dump;
            _result = false;
        };
        private _snapshot = [_logic,"snapshot"] call MAINCLASS;
        if ([_store] call ALIVE_fnc_isHash) then {
            // Injected store, for exercising this without a backend.
            [_store,_key,_snapshot] call ALIVE_fnc_hashSet;
            _result = true;
        } else {
            // A sys_data handler, created and configured by the caller.
            _result = [_store, "bulkSave", ["mil_ato", _snapshot, _key, false]] call ALIVE_fnc_Data;
        };
    };

    // Reads this instance's own key. Only when that is empty does it look at the
    // one shared key the old module wrote, and it never deletes it: a campaign
    // that gets loaded by an older build must still find its aircraft.
    case "load": {
        _args params [["_store",[],[[],""]], ["_key","",[""]], ["_legacyKey","",[""]]];
        private _loaded = [];

        if ([_store] call ALIVE_fnc_isHash) then {
            _loaded = [_store,_key,[]] call ALIVE_fnc_hashGet;
        } else {
            _loaded = [_store, "bulkLoad", ["mil_ato", _key, false]] call ALIVE_fnc_Data;
        };

        if ([_loaded] call ALIVE_fnc_isHash && {count (_loaded select 0) > 0}) exitWith {
            _result = [_logic,"restore",_loaded] call MAINCLASS;
        };

        if (_legacyKey isEqualTo "") exitWith { _result = [0,[],[]] };

        private _legacy = [];
        if ([_store] call ALIVE_fnc_isHash) then {
            _legacy = [_store,_legacyKey,[]] call ALIVE_fnc_hashGet;
        } else {
            _legacy = [_store, "bulkLoad", ["mil_ato", _legacyKey, false]] call ALIVE_fnc_Data;
        };
        if !([_legacy] call ALIVE_fnc_isHash) exitWith { _result = [0,[],[]] };
        _result = [_logic,"importLegacy",_legacy] call MAINCLASS;
    };

    // The old store was keyed by faction, each holding a hash of assets. Only an
    // entry carrying a vehicleClass is an aircraft; the rest is housekeeping the
    // backend added. The old profile id is kept so the first session after the
    // change can recognise an aircraft it already has rather than build a second.
    case "importLegacy": {
        private _old = _args;
        private _records = [_logic,"records"] call ALIVE_fnc_hashGet;
        private _kept = 0;
        private _unplaceable = [];
        private _unknown = [];

        if !([_old] call ALIVE_fnc_isHash) exitWith { _result = [0,[],[]] };

        private _oldValues = _old select 2;
        {
            private _factionKey = _x;
            private _assets = _oldValues select _forEachIndex;
            if (!(_factionKey in HOUSEKEEPING) && {[_assets] call ALIVE_fnc_isHash}) then {
                private _assetValues = _assets select 2;
                {
                    private _assetKey = _x;
                    private _asset = _assetValues select _forEachIndex;
                    if (!(_assetKey in HOUSEKEEPING) && {[_asset] call ALIVE_fnc_isHash}) then {
                        private _class = [_asset,"vehicleClass",""] call ALIVE_fnc_hashGet;
                        if (_class isEqualTo "") then {
                            _unknown pushBack _assetKey;
                        } else {
                            private _index = [_logic,"nextIndex",0] call ALIVE_fnc_hashGet;
                            private _tail = format ["%1_%2", _factionKey, _index];
                            [_logic,"nextIndex",_index + 1] call ALIVE_fnc_hashSet;

                            private _startPos = [_asset,"startPos",[]] call ALIVE_fnc_hashGet;
                            private _startDir = [_asset,"startDir",0] call ALIVE_fnc_hashGet;
                            private _onCarrier = [_asset,"isOnCarrier",false] call ALIVE_fnc_hashGet;

                            private _record = [[
                                ["tail", _tail],
                                ["vehicleClass", _class],
                                ["faction", _factionKey],
                                ["airspace", [_asset,"airspace",[]] call ALIVE_fnc_hashGet],
                                ["callsign", format ["%1 %2", _factionKey, _index + 1]],
                                ["roles", [_asset,"roles",[]] call ALIVE_fnc_hashGet],
                                ["capabilities", [_asset,"capabilities",[]] call ALIVE_fnc_hashGet],
                                // airportID and helipad are deliberately dropped:
                                // both are derived from the position, and keeping
                                // them is how one home came to live in six places.
                                ["home", if (_startPos isEqualTo []) then {[]} else {[_startPos, _startDir, if (_onCarrier) then {"deck"} else {"terrain"}]}],
                                ["status", "present"],
                                ["lossCount", 0],
                                ["replacement", ""],
                                ["legacyProfileID", [_asset,"profileID",""] call ALIVE_fnc_hashGet],
                                ["attachedThisSession", false]
                            ]] call ALIVE_fnc_hashCreate;

                            [_records,_tail,_record] call ALIVE_fnc_hashSet;
                            _kept = _kept + 1;
                            if (_startPos isEqualTo []) then { _unplaceable pushBack _tail };
                        };
                    };
                } forEach (_assets select 1);
            };
        } forEach (_old select 1);

        _result = [_kept,_unplaceable,_unknown];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Ledger - output",_result);

_result;
