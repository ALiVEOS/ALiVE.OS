#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(resupply);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOResupply

Description:
Replacing an aircraft the campaign lost.

One record, one outstanding replacement, and the replacement goes back into the
SAME record rather than becoming a new one. That is the whole shape of it, and
it is the answer to a measured defect: the old module declared an aircraft lost
and ordered another, and then declared it lost again on the next sweep and
ordered another, because nothing on the record said an order was already out.

Two routes. Where logistics is running it asks for a delivery, which flies a
replacement in and is the better story. Where it is not, or the delivery never
arrives, it creates one at the record's own stand. Either way the airframe ends
up attached to the record that lost it, keeping its callsign and its roles,
because to a commander it is the same aircraft coming back.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_r = [nil, "create"] call ALIVE_fnc_ATOResupply;
[_r, "configure", [["ledger", _ledger], ["place", _place], ["enabled", true]]] call ALIVE_fnc_ATOResupply;
[_r, "onLost", "BLU_F_1"] call ALIVE_fnc_ATOResupply;
[_r, "sweep", time] call ALIVE_fnc_ATOResupply;

(end)

See Also:
<ALIVE_fnc_ATOLedger>, <ALIVE_fnc_ATOPlace>, <ALIVE_fnc_ATOBase>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOResupply

// How long a delivery has to arrive before it is assumed lost. Logistics gives
// an AI requester no failure callback of any kind, so the only way to find out
// that a delivery is never coming is to wait and see.
#define DELIVERY_TIMEOUT 1800

// One order, one retry, then make it here. Three goes at a record and then it
// is marked as having nowhere to go rather than being asked for forever, which
// is what the old module did.
#define MAX_TRIES 3

// A replacement must not spawn on top of the wreck of the aircraft it replaces.
#define WRECK_REACH 8

private ["_result"];

TRACE_1("ATO Resupply - input",_this);

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

            ["ledger", []],
            ["place", []],
            ["task", []],

            ["side", ""],
            ["faction", ""],
            ["factions", []],

            // Off means an aircraft that is lost stays lost. A mission can
            // legitimately want a finite air force.
            ["enabled", false],

            // Where a delivery would be asked to come from. Empty means the
            // module never found an HQ, which rules the delivery route out.
            ["hqPos", []],

            // No delivery to a carrier. Logistics drives there.
            ["isCarrier", false],

            // Event id to [tail, orderedAt, tries, forceSelfCreate]. Keyed by
            // the event because that is all a completion tells us, and kept
            // because logistics never says a delivery failed.
            ["pending", [] call ALIVE_fnc_hashCreate],

            // Every tail ever ordered for, append only, so a mission can be
            // asked what it has replaced.
            ["ordered", []],

            ["lastSweep", -1],
            ["delivered", 0],
            ["selfCreated", 0]
        ]] call ALIVE_fnc_hashCreate;
    };

    case "configure": {
        private _pairs = _args;
        if !(_pairs isEqualType []) then { _pairs = [] };
        {
            if (_x isEqualType [] && {count _x > 1}) then {
                [_logic, _x select 0, _x select 1] call ALIVE_fnc_hashSet;
            };
        } forEach _pairs;
        _result = true;
    };

    // ---- an aircraft did not come back -------------------------------------
    // Marks the record and nothing else. Ordering happens on the sweep, one at
    // a time, so a bad minute that loses four aircraft does not put four
    // deliveries in the air at once.
    case "onLost": {
        private _tail = _args;
        if !(_tail isEqualType "") exitWith { _result = false };

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        if (count _ledger < 3) exitWith {
            ["ALIVE_fnc_ATOResupply - no ledger, cannot record %1 as lost", _tail] call ALiVE_fnc_dump;
            _result = false;
        };

        private _record = [_ledger, "get", _tail] call ALIVE_fnc_ATOLedger;
        if (_record isEqualTo []) exitWith { _result = false };

        // The wreck goes now rather than at delivery. A replacement that
        // arrives in twenty minutes should not find the old one still lying on
        // its stand, and the stand has to read as clear in the meantime or the
        // spot search will route other aircraft around a hull that is rubbish.
        private _home = [_record, "home", []] call ALIVE_fnc_hashGet;
        if (count _home > 2) then {
            {
                if (!alive _x) then { deleteVehicle _x };
            } forEach (nearestObjects [_home select 0, ["Air"], WRECK_REACH]);
        };

        if !([_logic, "enabled", false] call ALIVE_fnc_hashGet) exitWith {
            ["ALIVE_fnc_ATOResupply - %1 is lost and replacement is off, it stays lost", _tail] call ALiVE_fnc_dump;
            _result = false;
        };

        // Already has one out. This is the guard the old module did not have.
        private _out = [_record, "replacement", ""] call ALIVE_fnc_hashGet;
        if !(_out isEqualTo "") exitWith {
            _result = false;
        };

        [_ledger, "setReplacement", [_tail, "wanted"]] call ALIVE_fnc_ATOLedger;
        _result = true;
    };

    // ---- order or create, at most one per pass -----------------------------
    case "sweep": {
        private _now = _args;
        if !(_now isEqualType 0) then { _now = 0 };
        [_logic, "lastSweep", _now] call ALIVE_fnc_hashSet;
        _result = "";

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        if (count _ledger < 3) exitWith { _result = "" };
        if !([_logic, "enabled", false] call ALIVE_fnc_hashGet) exitWith { _result = "" };

        // ---- deliveries that are never coming -------------------------------
        // One retry, then it is made here. Done before dispatching so a stuck
        // order frees its record in the same pass rather than the next one.
        private _pending = [_logic, "pending", []] call ALIVE_fnc_hashGet;
        {
            private _eventId = _x;
            private _entry = [_pending, _eventId, []] call ALIVE_fnc_hashGet;
            if (count _entry > 2) then {
                _entry params ["_tail", "_orderedAt", "_tries"];
                if ((_now - _orderedAt) > DELIVERY_TIMEOUT) then {
                    ["ALIVE_fnc_ATOResupply - the delivery for %1 never arrived after %2 s, try %3",
                        _tail, DELIVERY_TIMEOUT, _tries] call ALiVE_fnc_dump;
                    [_pending, _eventId, nil] call ALIVE_fnc_hashSet;
                    if (_tries >= MAX_TRIES) then {
                        [_ledger, "markUnplaceable", [_tail, "no replacement could be delivered or built"]] call ALIVE_fnc_ATOLedger;
                        [_ledger, "setReplacement", [_tail, ""]] call ALIVE_fnc_ATOLedger;
                    } else {
                        // Wanted again, and next time it is built here rather
                        // than asked for.
                        [_ledger, "setReplacement", [_tail, "selfCreate"]] call ALIVE_fnc_ATOLedger;
                    };
                };
            };
        } forEach (+(_pending select 1));

        // ---- the one record to act on this pass -----------------------------
        private _view = [_ledger, "view"] call ALIVE_fnc_ATOLedger;
        private _pick = "";
        private _pickWants = "";
        {
            private _tail = _x;
            if (_pick isEqualTo "") then {
                private _rec = [_view, _tail, []] call ALIVE_fnc_hashGet;
                if (count _rec > 0) then {
                    private _status = [_rec, "status", ""] call ALIVE_fnc_hashGet;
                    private _wants = [_rec, "replacement", ""] call ALIVE_fnc_hashGet;
                    if (_status isEqualTo "lost" && {_wants in ["wanted", "selfCreate"]}) then {
                        _pick = _tail;
                        _pickWants = _wants;
                    };
                };
            };
        } forEach (_view select 1);

        if (_pick isEqualTo "") exitWith { _result = "" };

        private _rec = [_view, _pick, []] call ALIVE_fnc_hashGet;
        private _class = [_rec, "vehicleClass", ""] call ALIVE_fnc_hashGet;
        private _tries = [_rec, "lossCount", 1] call ALIVE_fnc_hashGet;

        // ---- which route ----------------------------------------------------
        // A delivery has to have somewhere to come from and something to drive
        // on, and it has to be wanted rather than already given up on.
        private _hqPos = [_logic, "hqPos", []] call ALIVE_fnc_hashGet;
        private _haveLogistics = ["ALiVE_mil_logistics"] call ALiVE_fnc_isModuleAvailable;
        private _canDeliver = _haveLogistics
            && {!([_logic, "isCarrier", false] call ALIVE_fnc_hashGet)}
            && {count _hqPos > 1}
            && {_pickWants isEqualTo "wanted"};

        if (_canDeliver) then {
            // The payload is unchanged from the old module, because logistics
            // reads it positionally and a third party may too. The counts are
            // plane and helicopter in the last two slots.
            private _isPlane = _class isKindOf "Plane";
            private _order = [
                _hqPos,
                [_logic, "faction", ""] call ALIVE_fnc_hashGet,
                [_logic, "side", ""] call ALIVE_fnc_hashGet,
                [0, 0, 0, 0, (if (_isPlane) then {1} else {0}), (if (_isPlane) then {0} else {1})],
                "STANDARD"
            ];

            private _event = ["LOGCOM_REQUEST", _order, "ATO"] call ALIVE_fnc_event;
            // The exact class is carried on the event rather than in the
            // payload, because the payload only counts types and a commander
            // that lost a gunship should not be sent a transport. Set BEFORE
            // the event is logged, or the copy that goes out does not have it.
            [_event, "requestVehicleClass", _class] call ALIVE_fnc_hashSet;

            // The id comes back from logging the event, not off the event
            // itself, and it is keyed as a STRING because that is the form a
            // completion reports it in.
            private _eventId = str ([ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog);
            [_pending, _eventId, [_pick, _now, _tries, false]] call ALIVE_fnc_hashSet;
            [_ledger, "setReplacement", [_pick, format ["ordered:%1", _eventId]]] call ALIVE_fnc_ATOLedger;

            private _log = [_logic, "ordered", []] call ALIVE_fnc_hashGet;
            _log pushBack _pick;
            [_logic, "ordered", _log] call ALIVE_fnc_hashSet;

            ["ALIVE_fnc_ATOResupply - asked logistics for a %1 to replace %2 (event %3)",
                _class, _pick, _eventId] call ALiVE_fnc_dump;
            _result = _pick;
        } else {
            // Built here. Placement owns creating it, because it owns every
            // other hull this module has and the home has to be re-checked
            // before anything is put on it.
            private _place = [_logic, "place", []] call ALIVE_fnc_hashGet;
            if (count _place < 3) exitWith {
                ["ALIVE_fnc_ATOResupply - no placement, cannot build a replacement for %1", _pick] call ALiVE_fnc_dump;
                _result = "";
            };

            private _made = [_place, "createReplacement", _pick] call ALIVE_fnc_ATOPlace;
            if (_made isEqualTo true) then {
                [_ledger, "setReplacement", [_pick, ""]] call ALIVE_fnc_ATOLedger;
                [_logic, "selfCreated", ([_logic, "selfCreated", 0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                ["ALIVE_fnc_ATOResupply - built a %1 at %2's own stand", _class, _pick] call ALiVE_fnc_dump;
                _result = _pick;
            } else {
                // Could not be built either. Counted, and after enough goes the
                // record says it has nowhere to go rather than being retried
                // for the rest of the mission.
                if (_tries >= MAX_TRIES) then {
                    [_ledger, "markUnplaceable", [_pick, "no replacement could be delivered or built"]] call ALIVE_fnc_ATOLedger;
                    [_ledger, "setReplacement", [_pick, ""]] call ALIVE_fnc_ATOLedger;
                    ["ALIVE_fnc_ATOResupply - giving up on %1 after %2 tries", _pick, _tries] call ALiVE_fnc_dumpR;
                };
                _result = "";
            };
        };
    };

    // ---- a delivery arrived ------------------------------------------------
    // Matched by the event id it was ordered under. An arrival nobody ordered
    // is let go rather than taken, because taking it would steal another
    // module's vehicle.
    case "onLogisticsComplete": {
        private _data = _args;
        if !(_data isEqualType []) exitWith { _result = false };

        // The event id is the fourth slot and the delivered profiles the sixth.
        // Both read with param, because completions arrive in a five and a six
        // element shape and the six element one is the newer.
        // Compared as a string, because the pending table is keyed that way
        // and a completion may report the id as a number.
        private _eventId = str (_data param [3, ""]);
        private _ids = _data param [5, []];
        if !(_ids isEqualType []) then { _ids = [] };

        private _pending = [_logic, "pending", []] call ALIVE_fnc_hashGet;
        private _entry = [_pending, _eventId, []] call ALIVE_fnc_hashGet;

        // Unknown id. Either it is somebody else's delivery or a duplicate of
        // one already consumed, and duplicates do arrive.
        if (count _entry < 3) exitWith {
            _result = false;
        };
        _entry params ["_tail", "_orderedAt", "_tries"];

        // Consumed straight away, so a duplicate completion finds nothing.
        [_pending, _eventId, nil] call ALIVE_fnc_hashSet;

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _place = [_logic, "place", []] call ALIVE_fnc_hashGet;
        private _record = if (count _ledger > 2) then { [_ledger, "get", _tail] call ALIVE_fnc_ATOLedger } else { [] };

        // Sort the delivery by what each profile IS, not by the order they
        // arrived in. The old handler read slot zero as the vehicle and slot
        // one as the crew, and logistics does not promise that.
        // The delivered list is NESTED: each entry is its own [entity, vehicle]
        // pair, not a flat list of ids. Logistics builds it as
        // `_planeProfiles + _heliProfiles` and releases it with two nested
        // forEach loops, and its own comment beside the payload says each entry
        // is a pair. Walking one level and requiring a string skipped every
        // entry, because every entry is an array, so both ids stayed empty and
        // EVERY real delivery fell through to being built here instead.
        //
        // Flattened first, and a flat list is still accepted: the other places
        // that raise this event carry different shapes and none of them is
        // worth throwing over.
        private _flat = [];
        {
            if (_x isEqualType "") then {
                _flat pushBack _x;
            } else {
                if (_x isEqualType []) then {
                    { if (_x isEqualType "") then { _flat pushBack _x } } forEach _x;
                };
            };
        } forEach _ids;

        // Sorted by what each profile IS rather than by where it sat in the
        // list. The pairs are built crew first, but that is logistics' own
        // business and not a promise worth relying on.
        private _vehId = "";
        private _entId = "";
        {
            private _id = _x;
            if (!isNil "ALiVE_profileHandler") then {
                private _got = [ALiVE_profileHandler, "getProfile", _id] call ALiVE_fnc_ProfileHandler;
                if (!isNil "_got" && {_got isEqualType []}) then {
                    switch ([_got, "type", ""] call ALIVE_fnc_hashGet) do {
                        case "vehicle": { if (_vehId isEqualTo "") then { _vehId = _id } };
                        case "entity":  { if (_entId isEqualTo "") then { _entId = _id } };
                    };
                };
            };
        } forEach _flat;
        ["ALIVE_fnc_ATOResupply - delivery %1 carried %2 id(s): vehicle '%3', crew '%4'",
            _eventId, count _flat, _vehId, _entId] call ALiVE_fnc_dump;

        // Nobody left to give it to. Let the crew go so logistics stops holding
        // them, and leave the vehicle alone.
        if (_record isEqualTo []) exitWith {
            ["ALIVE_fnc_ATOResupply - a delivery arrived for %1, which is no longer a record. Released.", _tail] call ALiVE_fnc_dump;
            if (!(_entId isEqualTo "") && {!isNil "ALiVE_profileHandler"}) then {
                private _ent = [ALiVE_profileHandler, "getProfile", _entId] call ALiVE_fnc_ProfileHandler;
                if (!isNil "_ent" && {_ent isEqualType []}) then {
                    [_ent, "busy", false] call ALIVE_fnc_hashSet;
                };
            };
            _result = false;
        };

        // The vehicle half is missing, so it was destroyed on the way. Let the
        // crew go and build one here instead.
        if (_vehId isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOResupply - the delivery for %1 arrived without a vehicle, building one instead", _tail] call ALiVE_fnc_dump;
            if (!(_entId isEqualTo "") && {!isNil "ALiVE_profileHandler"}) then {
                private _ent = [ALiVE_profileHandler, "getProfile", _entId] call ALiVE_fnc_ProfileHandler;
                if (!isNil "_ent" && {_ent isEqualType []}) then {
                    [_ent, "busy", false] call ALIVE_fnc_hashSet;
                };
            };
            [_ledger, "setReplacement", [_tail, "selfCreate"]] call ALIVE_fnc_ATOLedger;
            _result = false;
        };

        if (count _place < 3) exitWith {
            ["ALIVE_fnc_ATOResupply - no placement, cannot take the delivery for %1", _tail] call ALiVE_fnc_dump;
            _result = false;
        };

        // Two things have to be handed over before the pair can be taken on.
        //
        // The fuel watchdog is told to stand down, or it goes on managing an
        // aircraft that no longer has a profile to manage.
        //
        // And the busy flag is cleared on BOTH halves, which is ours to do and
        // nobody else's. Logistics deliberately does NOT release a delivery
        // raised by this module: it creates the profiles busy and, when the
        // requester is the air commander, skips the release outright, saying in
        // its own comment that holding them closes the window in which the
        // ground commander could claim the airframe first. So the flag is left
        // for us. Adoption refuses a busy profile, so leaving it set means
        // every single delivery is refused and a duplicate built instead, which
        // is exactly what happened. The old module cleared it on its own
        // release paths for the same reason.
        {
            if (!(_x isEqualTo "") && {!isNil "ALiVE_profileHandler"}) then {
                private _prof = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
                if (!isNil "_prof" && {_prof isEqualType []}) then {
                    [_prof, "busy", false] call ALIVE_fnc_hashSet;
                    if (_x isEqualTo _entId) then {
                        [_prof, "alive_ml_releaseWatchdog", true] call ALIVE_fnc_hashSet;
                    };
                };
            };
        } forEach [_vehId, _entId];

        // Into the SAME record. The tail, the callsign and the roles are the
        // ones the campaign already knows; only the home is re-checked, because
        // the aircraft is standing at the delivery point rather than on its
        // stand.
        //
        // The hint adoptPair takes is a bare POSITION, so the record's home is
        // unpacked here rather than handed over whole. The first version of
        // this passed the full [pos, dir, surface] and Place read it as a
        // position, which threw inside the home search on every delivery,
        // after Place had claimed the aircraft and before it could release the
        // claim; every delivered replacement was then refused as already
        // claimed for the rest of the session, and this thread died with it.
        // An empty hint is fine: Place falls back to the record's own home.
        private _home = [_record, "home", []] call ALIVE_fnc_hashGet;
        private _hint = if (count _home >= 3) then { +(_home select 0) } else { [] };
        private _taken = [_place, "adoptPair", [_vehId, _entId, _hint, _tail]] call ALIVE_fnc_ATOPlace;

        if (_taken isEqualType "" && {_taken isEqualTo _tail}) then {
            // Named, but is it actually HERE.
            //
            // Adoption answers with the tail once it has taken the profile,
            // which it has, but the hull can still be owned by another machine
            // at that moment: a delivery whose crew lives on a headless client
            // comes back remote, and placement holds it and retries the
            // takeover on its own passes.
            //
            // Booking that as delivered is a dead end. The record would be
            // cleared of its order while still marked lost, and nothing looks
            // at a lost record with no order: the sweep only picks records that
            // want one, and a restore only walks records that are present. The
            // aircraft would never come back at all.
            private _hull = [_place, "objFor", _tail] call ALIVE_fnc_ATOPlace;
            private _waiting = [_place, "deferredTails"] call ALIVE_fnc_ATOPlace;
            if !(_waiting isEqualType []) then { _waiting = [] };

            if (!isNull _hull && {!(_tail in _waiting)}) then {
                [_ledger, "setReplacement", [_tail, ""]] call ALIVE_fnc_ATOLedger;
                [_logic, "delivered", ([_logic, "delivered", 0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                ["ALIVE_fnc_ATOResupply - %1 is back, delivered", _tail] call ALiVE_fnc_dump;
                _result = true;
            } else {
                // Arrived but not ours yet. The order stays open under its own
                // key, so nothing asks for a second one, and so the clock above
                // eventually gives up and builds one if the takeover never
                // completes.
                [_pending, format ["attaching_%1", _tail], [_tail, time, _tries, true]] call ALIVE_fnc_hashSet;
                [_ledger, "setReplacement", [_tail, "delivered:attaching"]] call ALIVE_fnc_ATOLedger;
                ["ALIVE_fnc_ATOResupply - %1 arrived but is not ours yet; placement is still taking it over", _tail] call ALiVE_fnc_dump;
                _result = true;
            };
        } else {
            ["ALIVE_fnc_ATOResupply - the delivery for %1 could not be taken on (%2), building one instead",
                _tail, _taken] call ALiVE_fnc_dump;
            [_ledger, "setReplacement", [_tail, "selfCreate"]] call ALIVE_fnc_ATOLedger;
            _result = false;
        };
    };

    // Every delivery clock, moved by the same amount, for the same reason the
    // other pieces have one: mission time runs on while the module is paused,
    // and without this every outstanding delivery is declared never-arriving on
    // the first tick after un-pausing.
    case "shiftClocks": {
        private _delta = _args;
        if !(_delta isEqualType 0) exitWith { _result = 0 };
        private _pending = [_logic, "pending", []] call ALIVE_fnc_hashGet;
        private _moved = 0;
        {
            private _entry = [_pending, _x, []] call ALIVE_fnc_hashGet;
            if (count _entry > 1) then {
                private _next = +_entry;
                _next set [1, (_entry select 1) + _delta];
                [_pending, _x, _next] call ALIVE_fnc_hashSet;
                _moved = _moved + 1;
            };
        } forEach (_pending select 1);
        _result = _moved;
    };

    case "status": {
        private _pendingNow = [_logic, "pending", []] call ALIVE_fnc_hashGet;
        _result = [
            ["pending", count (_pendingNow select 1)],
            ["delivered", [_logic, "delivered", 0] call ALIVE_fnc_hashGet],
            ["selfCreated", [_logic, "selfCreated", 0] call ALIVE_fnc_hashGet],
            ["ordered", count ([_logic, "ordered", []] call ALIVE_fnc_hashGet)]
        ];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Resupply - output",_result);

_result;
