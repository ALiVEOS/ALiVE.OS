#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(place);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOPlace
Description:
Which aircraft in the world are ours to fly, and which are somebody else's.

This is the decision half: it looks at the profile registry and says what may be
adopted, and refuses with a reason. Taking an aircraft over is the other half,
and is not built yet, because unregistering a profile and seizing its object is
the one thing in this module that cannot be undone if it is wrong. That half
waits for a mission to run it against rather than being written blind.

Two rules give this piece its shape, both learnt the hard way by the module it
replaces.

An aircraft is only adopted after being seen twice, at least twenty seconds
apart. A profile that appears once and vanishes was mid-registration, and
adopting it raced the system that created it: the old module took airframes out
from underneath logistics while they were still being delivered, then declared
them lost and ordered replacements, without limit.

And the registry is the only place it looks. Never `vehicles`, because that
answers with everything the engine currently has spawned, including aircraft
belonging to combat support, to a mission maker, or to a player, none of which
are the air commander's to take.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_p = [nil, "create"] call ALIVE_fnc_ATOPlace;
_tails = [_p, "sweep", ["AS1", time, _claimedLegacyIds]] call ALIVE_fnc_ATOPlace;

(end)

See Also:
<ALIVE_fnc_ATOSurface>, <ALIVE_fnc_ATOLedger>, <ALIVE_fnc_ATOTask>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOPlace

// A candidate has to still be there this long after it was first seen. Twenty
// seconds is the figure the old module's delivery race needed to settle.
#define SIGHTING_GAP 20

// Set on an object by another system to say "this one is not yours". The first
// belongs to combat support; the second is the general opt-out, and the module
// stamps it on its own aircraft too, which is why a sweep must not treat it as
// an invitation.
#define FOREIGN_MARKS ["ALIVE_CombatSupport", "ALIVE_profileIgnore"]

private ["_result"];

TRACE_1("ATO Place - input",_this);

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
            // profile id -> when it was first seen by a sweep
            ["sightings", [] call ALIVE_fnc_hashCreate],
            // profile id -> why it was refused, most recently
            ["refusals", [] call ALIVE_fnc_hashCreate],
            ["factions", []],
            ["firstPassDone", false]
        ]] call ALIVE_fnc_hashCreate;
    };

    // ---- may we have this one? --------------------------------------------
    // Answers [true] or [false, reason]. Reads the world but changes nothing,
    // so it can be asked as often as a caller likes.
    case "admissible": {
        _args params [["_vehId", "", [""]], ["_claimed", [], [[]]]];

        if (_vehId isEqualTo "") exitWith { _result = [false, "no profile id"] };

        // A record already names this profile as the one it came from. Adopting
        // it again is how one airframe becomes two.
        if (_vehId in _claimed) exitWith { _result = [false, "already claimed by a record"] };

        // getProfile answers with the profile HASH, which is an ARRAY, or with
        // nothing at all when the id is unknown. isNull has no array form, so
        // the line that was meant to catch a missing profile instead threw on
        // every lookup that SUCCEEDED. Nothing had executed this path yet,
        // because the placement test does not exist, which is how it survived
        // being committed.
        //
        // The handler itself is a global that only exists once profiles have
        // started, so reading it is guarded too.
        private _profile = [];
        if (!isNil "ALIVE_profileHandler") then {
            private _got = [ALIVE_profileHandler, "getProfile", _vehId] call ALIVE_fnc_profileHandler;
            if (!isNil "_got" && {_got isEqualType []}) then { _profile = _got };
        };
        if (_profile isEqualTo []) exitWith { _result = [false, "no such profile"] };

        private _type = [_profile, "type", ""] call ALIVE_fnc_hashGet;
        if !(_type isEqualTo "vehicle") exitWith { _result = [false, "not a vehicle profile"] };

        private _objectType = [_profile, "objectType", ""] call ALIVE_fnc_hashGet;
        if !((toLower _objectType) in ["helicopter", "plane"]) exitWith {
            _result = [false, format ["not an aircraft (%1)", _objectType]];
        };

        // The backstop. If the profile is spawned, the object itself may carry a
        // mark from another system saying it is not available. Checked on the
        // object rather than the profile because that is where the other systems
        // write it.
        // Read into a plain flag and test it afterwards. Setting the answer
        // from inside a nested block and then working out whether it was set
        // is the shape that has already produced a refusal reported as success
        // and a position computed and discarded, both in this module.
        private _obj = [_profile, "vehicle", objNull] call ALIVE_fnc_hashGet;
        private _mark = "";
        if (_obj isEqualType objNull && {!isNull _obj}) then {
            { if (_obj getVariable [_x, false]) exitWith { _mark = _x } } forEach FOREIGN_MARKS;
        };
        if !(_mark isEqualTo "") exitWith {
            _result = [false, format ["object is marked %1", _mark]];
        };

        _result = [true];
    };

    // ---- the sweep ---------------------------------------------------------
    // sweep(airspace, now, claimedLegacyIds) -> the profile ids that are ready
    // to be taken over.
    //
    // Called twice or more; returns nothing the first time it sees a candidate
    // and only offers it once it has survived the gap.
    case "sweep": {
        _args params [["_airspace", "", [""]], ["_now", 0, [0]], ["_claimed", [], [[]]]];

        private _factions = [_logic, "factions", []] call ALIVE_fnc_hashGet;
        private _sightings = [_logic, "sightings", []] call ALIVE_fnc_hashGet;
        private _refusals = [_logic, "refusals", []] call ALIVE_fnc_hashGet;

        // Gather from the registry, per faction.
        //
        // getProfilesByFaction is used rather than the type-filtered sibling on
        // purpose. That one reads its inner key with a two-argument hashGet,
        // which answers nil for a key that is absent, and a nil assignment
        // deletes the variable rather than emptying it, so asking about a
        // vehicle type a faction has never registered takes the getter down on
        // its own trailing read. This one passes a default and cannot.
        private _ids = [];
        {
            private _got = [ALIVE_profileHandler, "getProfilesByFaction", _x] call ALIVE_fnc_profileHandler;
            if (!isNil "_got" && {_got isEqualType []}) then {
                { _ids pushBackUnique _x } forEach _got;
            };
        } forEach _factions;

        // Judge each one, and remember when we first saw the ones we would take.
        private _ready = [];
        private _seen = [];
        {
            private _id = _x;
            private _verdict = [_logic, "admissible", [_id, _claimed]] call MAINCLASS;

            if (_verdict param [0, false]) then {
                _seen pushBack _id;
                private _first = [_sightings, _id, -1] call ALIVE_fnc_hashGet;
                if (_first < 0) then {
                    [_sightings, _id, _now] call ALIVE_fnc_hashSet;
                } else {
                    if (_now - _first >= SIGHTING_GAP) then { _ready pushBack _id };
                };
            } else {
                // Remember the reason, but only say it once per profile. A
                // refusal that repeats every sweep buries everything else.
                private _reason = _verdict param [1, ""];
                private _last = [_refusals, _id, ""] call ALIVE_fnc_hashGet;
                if !(_last isEqualTo _reason) then {
                    [_refusals, _id, _reason] call ALIVE_fnc_hashSet;
                    ["ALIVE_fnc_ATOPlace - %1 not adopted: %2", _id, _reason] call ALiVE_fnc_dump;
                };
            };
        } forEach _ids;

        // A candidate that has gone away loses its sighting, so an aircraft
        // that appears, vanishes and appears again has to serve the gap afresh
        // rather than inheriting credit for a profile that no longer exists.
        {
            if !(_x in _seen) then { [_sightings, _x, nil] call ALIVE_fnc_hashSet };
        } forEach (+(_sightings select 1));

        [_logic, "firstPassDone", true] call ALIVE_fnc_hashSet;
        _result = _ready;
    };

    case "firstPassDone": { _result = [_logic, "firstPassDone", false] call ALIVE_fnc_hashGet };

    // How many candidates a sweep is currently holding, whether or not they
    // have served their gap. The Tasker gates "not enough aircraft for an
    // operation" on a count like this, and needs to be told rather than to
    // reach in here for it.
    case "candidateCount": {
        // Parenthesised deliberately: call and select are both binary, so
        // leaving it to precedence is a coin toss about which one binds first.
        private _s = [_logic, "sightings", []] call ALIVE_fnc_hashGet;
        _result = count (_s select 1);
    };

    // ---- the half that takes the aircraft over -----------------------------
    // Deliberately not built. consume unregisters a profile and seizes its
    // object; attach stamps and shields it; rehome moves a home that is already
    // in use. Each one changes mission state in a way that cannot be put back,
    // and none of them can be checked without a running mission, so they are
    // not being written blind. Named so a caller reaching one is told.
    case "consume";
    case "attach";
    case "rehome";
    case "adoptPair";
    case "placeInitial";
    case "createReplacement";
    case "restoreAll": {
        ["ALIVE_fnc_ATOPlace - %1 is not built yet", _operation] call ALiVE_fnc_dump;
        _result = ["refused", "not built"];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Place - output",_result);

_result;
