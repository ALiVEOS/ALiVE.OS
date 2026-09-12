#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(task);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOTask
Description:
Who flies what. Turns a request into a sortie, or says why not.

It decides and it records; it does not touch the world. Choosing an airframe
reads the campaign records and the state rows it is handed, never a profile, a
distance to home, or a despawn flag. That was deliberate: the old module picked
aircraft by asking the world questions whose answers changed under it mid-pick,
and a selection that cannot be replayed cannot be tested.

The planner is pure. Hand it the same request, records, rows and exclusions and
it returns the same plan, which is why its test needs no mission at all.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_t = [nil, "create"] call ALIVE_fnc_ATOTask;
_id = [_t, "submit", [_request]] call ALIVE_fnc_ATOTask;
_plan = [_t, "plan", [_request, _records, _rows, _obs, []]] call ALIVE_fnc_ATOTask;

(end)

See Also:
<ALIVE_fnc_ATOLedger>, <ALIVE_fnc_ATOMachine>, <ALIVE_fnc_ATOSurface>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOTask

// The seven types a commander can ask for, plus the one the module raises for
// itself when an airframe has to be moved rather than used.
#define ATO_TYPES ["CAP","DCA","SEAD","CAS","Strike","Recce","OCA","FERRY"]

// Only these count against the sortie cap and only these lease targets. A
// standing patrol is not an operation against anything, so capping it would
// mean a busy airfield stops defending itself.
#define OFFENSIVE_TYPES ["SEAD","CAS","Strike","Recce","OCA"]

// How long a request waits for a better airframe before taking what it has.
// The old table had a malformed `case default` that never matched, so OCA and
// anything unrecognised silently kept the initialiser instead of the intended
// default. Written as a hash lookup with a real default.
#define WAIT_TIMES [["CAS",10],["DCA",30],["CAP",60],["SEAD",60],["Strike",90],["Recce",90]]
#define WAIT_DEFAULT 60

// A denial that repeats every tick is noise that hides the one that matters.
#define DENIAL_QUIET 300

// Three goes at finding an airframe, then the request is refused. Each failure
// excludes the tail that failed, so three attempts means three different
// aircraft rather than the same one three times.
#define MAX_ATTEMPTS 3

private ["_result"];

TRACE_1("ATO Task - input",_this);

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
            // requestId -> the typed request record
            ["requests", [] call ALIVE_fnc_hashCreate],
            // sortieId -> {requestId, type, zone, tails[], state, attempts, excluded[]}
            ["sorties", [] call ALIVE_fnc_hashCreate],
            // type -> the last time a denial of that kind was written down
            ["lastDenial", [] call ALIVE_fnc_hashCreate],
            ["nextId", 1],
            // Nothing is denied for want of aircraft until placement has had
            // its first look round. Before that "no assets" means "not yet",
            // and refusing then taught the commander there was no air support
            // for the whole mission.
            ["firstPassDone", false],
            // How many airframes the module currently holds. Pushed in by
            // Placement rather than fetched, so nothing in here reaches into
            // another piece to make a decision. -1 means nobody has said yet,
            // and an unknown count never denies anything.
            ["assetCount", -1],
            // Set by Base when there is no airbase to fly from. Every request
            // is refused with that reason rather than silently queued.
            ["baseFailed", false],
            ["baseFailedReason", ""],
            ["maxConcurrentSorties", 0],
            ["minAssetsForOffensive", 0],
            ["sortieDuration", 0],
            ["factions", []],
            ["airspaces", []],
            // Who this module is. Needed by the player-task payloads, and
            // pushed in rather than read off a logic so the planner and the
            // task builders stay testable with no mission at all.
            ["side", ""],
            ["faction", ""],
            ["enemySides", []],
            // Whether the module may hand work to players at all. Off means no
            // task is raised by any route, which is how a mission runs air
            // support without generating anybody a task.
            ["generateTasks", false],
            // The chance a downed crew is offered as a rescue rather than
            // written off.
            ["chanceOfRescue", 0.5]
        ]] call ALIVE_fnc_hashCreate;
    };

    // ---- the standing table, pure -----------------------------------------
    // What a sortie of this type flies in this state, as order NAMES. The
    // kernel turns a name into a place; this never sees a coordinate.
    //
    // Every name here is one the resolver already handles. That is a rule, not
    // an accident: an order name nobody resolves produces an empty chain and
    // the aircraft is left with no orders at all, which is how one sat on a
    // runway with its engine running. Richer patterns per type (a racetrack for
    // a patrol, a vector for an intercept) each need a new verb and a resolver
    // to match, so they are a later change and not smuggled in here.
    case "ordersFor": {
        _args params [["_type","",[""]], ["_state","",[""]]];

        private _station = switch (true) do {
            // Something to attack, then hold over it.
            case (_type in ["CAS","Strike","SEAD","OCA"]): { ["EXECUTE","LOITER"] };
            // A reconnaissance aircraft does its job by being there and looking.
            case (_type isEqualTo "Recce"): { ["MOVE_STATION","LOITER"] };
            // A patrol and an interception are both a hold over the airspace
            // until something enters it.
            case (_type in ["CAP","DCA"]): { ["LOITER"] };
            // A ferry has no station. It is in the air to be somewhere else.
            default { ["LOITER"] };
        };

        _result = switch (_state) do {
            case "LAUNCHING":    { ["TAKEOFF"] };
            case "ENROUTE":      { ["MOVE_STATION","LOITER"] };
            case "ON_STATION":   { _station };
            case "RTB":          { ["MOVE_APPROACH","LOITER"] };
            case "LANDING":      { ["LAND"] };
            // Stay exactly where you are. Both of these are stationary states
            // and both of them used to hand back nothing.
            case "ASSIGNED":     { ["HOLD"] };
            case "RECOVERING":   { ["HOLD"] };
            // Parked, flown by somebody else, or gone. Not ours to order.
            case "PARKED":       { [] };
            case "PLAYER_FLOWN": { [] };
            case "LOST":         { [] };
            default              { ["HOLD"] };
        };
    };

    case "waitFor": {
        private _type = _args;
        private _found = WAIT_TIMES findIf { (_x select 0) isEqualTo _type };
        _result = if (_found > -1) then { (WAIT_TIMES select _found) select 1 } else { WAIT_DEFAULT };
    };

    // ---- choosing an airframe, pure ----------------------------------------
    // plan(request, records, rowStates, obsMap, excludedTails)
    //
    // records  : tail -> campaign record (class, home, side, faction, readyAt)
    // rowStates: tail -> the state table's row for it (state, sortieId)
    // obsMap   : tail -> what the observer last said (fuel, ammo, damage)
    //
    // Everything it needs arrives as an argument, so the same inputs always
    // give the same plan and the test can fabricate all three.
    case "plan": {
        _args params [
            ["_request", [], [[]]],
            ["_records", [], [[]]],
            ["_rows", [], [[]]],
            ["_obs", [], [[]]],
            ["_excluded", [], [[]]]
        ];

        private _type    = [_request, "type", ""] call ALIVE_fnc_hashGet;
        private _faction = [_request, "faction", ""] call ALIVE_fnc_hashGet;
        private _target  = [_request, "targetPos", [0,0,0]] call ALIVE_fnc_hashGet;
        private _now     = [_request, "receivedAt", 0] call ALIVE_fnc_hashGet;
        private _minFuel = [_request, "minFuel", 0.5] call ALIVE_fnc_hashGet;

        // A request about ONE named airframe rather than about the best one
        // available. A ferry is the only thing that asks this way: it exists to
        // bring a particular hull home, so the second-best aircraft on the
        // field is not a worse answer, it is the wrong answer.
        private _onlyTail = [_request, "onlyTail", ""] call ALIVE_fnc_hashGet;

        // Roles this type will accept, widest last. x_lib names them Recon,
        // Attack, Fighter and CAS.
        private _wantRoles = switch (true) do {
            case (_type in ["CAP","DCA"]): { ["Fighter"] };
            case (_type isEqualTo "Recce"): { ["Recon"] };
            default { ["Attack","CAS"] };
        };

        // A candidate is a tail we could send right now. Two shapes qualify:
        // parked and out of its turnaround, or already up on a patrol that can
        // be turned onto something more urgent.
        private _reroutable = _type in ["DCA","CAS","SEAD"];
        private _candidates = [];

        {
            private _tail = _x;
            private _rec  = [_records, _tail, []] call ALIVE_fnc_hashGet;
            private _row  = [_rows, _tail, []] call ALIVE_fnc_hashGet;

            if (count _rec > 0
                && {count _row > 0}
                && {!(_tail in _excluded)}
                && {_onlyTail isEqualTo "" || {_tail isEqualTo _onlyTail}}) then {
                private _state   = [_row, "state", ""] call ALIVE_fnc_hashGet;
                private _readyAt = [_rec, "readyAt", 0] call ALIVE_fnc_hashGet;
                private _recFac  = [_rec, "faction", ""] call ALIVE_fnc_hashGet;
                private _class   = [_rec, "class", ""] call ALIVE_fnc_hashGet;
                private _rowType = [_row, "sortieType", ""] call ALIVE_fnc_hashGet;

                private _available = switch (true) do {
                    case (_state isEqualTo "PARKED"): { _now >= _readyAt };
                    case (_reroutable && {_state isEqualTo "ON_STATION"} && {_rowType isEqualTo "CAP"}): { true };
                    default { false };
                };

                // A faction the module does not own is somebody else's aircraft.
                if (_available && {_faction isEqualTo "" || {_recFac isEqualTo _faction}}) then {
                    private _o = [_obs, _tail, []] call ALIVE_fnc_hashGet;
                    private _fuel   = [_o, "fuel", 1] call ALIVE_fnc_hashGet;
                    private _ammo   = [_o, "ammo", 1] call ALIVE_fnc_hashGet;
                    private _damage = [_o, "damage", 0] call ALIVE_fnc_hashGet;

                    // A ferry is a reposition, so it needs neither ammunition
                    // nor a healthy airframe, only enough fuel to get there.
                    private _needsTeeth = !(_type isEqualTo "FERRY");

                    if (_fuel >= _minFuel
                        && {_damage < 0.6}
                        && {!_needsTeeth || {_ammo > 0}}) then {
                        _candidates pushBack [_tail, _class, _rec, _state];
                    };
                };
            };
        } forEach (_records select 1);

        if (count _candidates == 0) exitWith {
            _result = ["denied", "no candidate airframe"];
        };

        // Role is a FILTER, not a preference. A transport helicopter is not a
        // near-miss for an interception, it simply cannot do it, and as a
        // preference it would be chosen anyway whenever it happened to be the
        // closest thing to the target.
        //
        // The fallback exists for aircraft whose roles cannot be read at all,
        // which is the normal case for a modded faction: if nothing has a role
        // that fits, everything flyable is admitted rather than the commander
        // being told it has no aircraft. So an unroled fleet still flies, and a
        // roled one is never mismatched.
        private _withRoles = _candidates apply {
            _x params ["_tail", "_class", "_rec", "_state"];
            private _roles = [];
            if (!isNil "ALiVE_fnc_getAircraftRoles") then {
                _roles = [_class] call ALiVE_fnc_getAircraftRoles;
            };
            if !(_roles isEqualType []) then { _roles = [] };
            [_tail, _class, _rec, _state, _roles]
        };

        private _fit = _withRoles select { !((_wantRoles arrayIntersect (_x select 4)) isEqualTo []) };
        if (count _fit == 0) then { _fit = _withRoles };

        // Score, then rank. Penalty dominates distance by a margin no real
        // distance can close, so a better-suited aircraft far away still beats
        // a worse one on the doorstep.
        private _scored = [];
        {
            _x params ["_tail", "_class", "_rec", "_state", "_roles"];

            private _penalty = 0;
            // A fighter sent to hit a ground target is a fighter not defending
            // the airspace, and it is usually carrying the wrong stores for it.
            if (_type in ["CAS","Strike","OCA"] && {"Fighter" in _roles}) then {
                _penalty = _penalty + 2;
            };
            // Turning a patrol onto a new job costs the patrol. Worth it for an
            // interception, which is what the patrol was there for; grudging
            // for anything else.
            if (_state isEqualTo "ON_STATION" && {!(_type isEqualTo "DCA")}) then {
                _penalty = _penalty + 1;
            };

            private _home = [_rec, "home", []] call ALIVE_fnc_hashGet;
            private _from = if (count _home > 0) then { _home select 0 } else { [0,0,0] };
            _scored pushBack [(_penalty * 1e6) + (_from distance2D _target), _tail];
        } forEach _fit;

        _scored sort true;

        // A suppression sortie goes as a pair when a pair is available, because
        // one aircraft against a defended site is a loss rather than a sortie.
        private _wanted = if (_type isEqualTo "SEAD") then { 2 } else { 1 };
        private _tails = [];
        {
            if (count _tails < _wanted) then { _tails pushBack (_x select 1) };
        } forEach _scored;

        _result = [_tails, _type, [_request, "airspace", ""] call ALIVE_fnc_hashGet];
    };

    // ---- what is already flying over a zone --------------------------------
    case "activeInZone": {
        _args params [["_zone","",[""]], ["_types",[],[[]]]];
        private _sorties = [_logic, "sorties", []] call ALIVE_fnc_hashGet;
        private _out = [];
        {
            private _s = [_sorties, _x, []] call ALIVE_fnc_hashGet;
            if (count _s > 0) then {
                private _state = [_s, "state", ""] call ALIVE_fnc_hashGet;
                private _type  = [_s, "type", ""] call ALIVE_fnc_hashGet;
                private _z     = [_s, "zone", ""] call ALIVE_fnc_hashGet;
                if (!(_state in ["complete","denied"])
                    && {_z isEqualTo _zone}
                    && {count _types == 0 || {_type in _types}}) then {
                    _out pushBack _x;
                };
            };
        } forEach (_sorties select 1);
        _result = _out;
    };

    // ---- admission ---------------------------------------------------------
    // Every gate below is a flat guard at this level on purpose. A guard nested
    // one block deeper exits only that block, and that has already cost this
    // module two bugs: a refusal that reported success, and an airfield
    // position that was computed and then silently thrown away.
    case "submit": {
        private _request = _args;
        if !(_request isEqualType []) then { _request = [] };

        private _type    = [_request, "type", ""] call ALIVE_fnc_hashGet;
        private _faction = [_request, "faction", ""] call ALIVE_fnc_hashGet;
        private _now     = [_request, "receivedAt", 0] call ALIVE_fnc_hashGet;
        private _reqId   = [_request, "id", ""] call ALIVE_fnc_hashGet;

        private _fnc_deny = {
            params ["_reason"];
            // Rate limited per reason. A denial repeated every tick buries the
            // one that mattered, and the cap reason fires as often as the
            // commander asks for another sortie.
            private _quiet = [_logic, "lastDenial", []] call ALIVE_fnc_hashGet;
            private _last = [_quiet, _reason, -99999] call ALIVE_fnc_hashGet;
            if (_now - _last > DENIAL_QUIET) then {
                [_quiet, _reason, _now] call ALIVE_fnc_hashSet;
                ["ALIVE_fnc_ATOTask - request %1 (%2) denied: %3", _reqId, _type, _reason] call ALiVE_fnc_dump;
            };
            ["denied", _reason]
        };

        if !(_type in ATO_TYPES) exitWith { _result = ["unsupported type"] call _fnc_deny };

        // No airbase to fly from. Refused with the reason rather than queueing
        // requests that can never be met.
        if ([_logic, "baseFailed", false] call ALIVE_fnc_hashGet) exitWith {
            _result = [[_logic, "baseFailedReason", "no airbase"] call ALIVE_fnc_hashGet] call _fnc_deny;
        };

        private _factions = [_logic, "factions", []] call ALIVE_fnc_hashGet;
        if (count _factions > 0 && {!(_faction isEqualTo "")} && {!(_faction in _factions)}) exitWith {
            _result = ["faction not ours"] call _fnc_deny;
        };

        // The cap counts operations against something. A standing patrol is not
        // one of those, so counting it would stop an airfield defending itself.
        private _cap = [_logic, "maxConcurrentSorties", 0] call ALIVE_fnc_hashGet;
        private _live = 0;
        if (_cap > 0 && {_type in OFFENSIVE_TYPES}) then {
            private _sorties = [_logic, "sorties", []] call ALIVE_fnc_hashGet;
            {
                private _s = [_sorties, _x, []] call ALIVE_fnc_hashGet;
                private _st = [_s, "state", ""] call ALIVE_fnc_hashGet;
                private _ty = [_s, "type", ""] call ALIVE_fnc_hashGet;
                if (_ty in OFFENSIVE_TYPES && {!(_st in ["complete","denied"])}) then { _live = _live + 1 };
            } forEach (_sorties select 1);
        };
        if (_cap > 0 && {_type in OFFENSIVE_TYPES} && {_live >= _cap}) exitWith {
            _result = ["sortie cap reached"] call _fnc_deny;
        };

        // Not enough aircraft to mount an operation, but only once placement has
        // actually looked. Before the first pass "none" means "not yet", and
        // denying then told the commander there was no air support at all for
        // the rest of the mission.
        private _minAssets = [_logic, "minAssetsForOffensive", 0] call ALIVE_fnc_hashGet;
        private _have = [_logic, "assetCount", -1] call ALIVE_fnc_hashGet;
        private _firstPass = [_logic, "firstPassDone", false] call ALIVE_fnc_hashGet;
        if (_firstPass
            && {_have > -1}
            && {_minAssets > 0}
            && {_type in OFFENSIVE_TYPES}
            && {_have < _minAssets}) exitWith {
            _result = ["not enough aircraft for an operation"] call _fnc_deny;
        };

        // A duration set on the module overrides whatever was asked for.
        private _override = [_logic, "sortieDuration", 0] call ALIVE_fnc_hashGet;
        if (_override > 0) then { [_request, "duration", _override] call ALIVE_fnc_hashSet };

        private _next = [_logic, "nextId", 1] call ALIVE_fnc_hashGet;
        [_logic, "nextId", _next + 1] call ALIVE_fnc_hashSet;
        private _sortieId = format ["ato_%1", _next];

        private _sortie = [[
            ["sortieId", _sortieId],
            ["requestId", _reqId],
            ["type", _type],
            ["zone", [_request, "airspace", ""] call ALIVE_fnc_hashGet],
            ["tails", []],
            // Held, not refused, until placement has finished its first pass.
            ["state", if (_firstPass) then {"planning"} else {"queued"}],
            ["attempts", 0],
            ["excluded", []],
            ["receivedAt", _now]
        ]] call ALIVE_fnc_hashCreate;

        [([_logic, "sorties", []] call ALIVE_fnc_hashGet), _sortieId, _sortie] call ALIVE_fnc_hashSet;
        [([_logic, "requests", []] call ALIVE_fnc_hashGet), _reqId, _request] call ALIVE_fnc_hashSet;

        _result = _sortieId;
    };

    // ---- a dispatch came back ----------------------------------------------
    case "onRowEvent": {
        _args params [["_sortieId","",[""]], ["_tail","",[""]], ["_event","",[""]], ["_now",0,[0]]];
        private _sorties = [_logic, "sorties", []] call ALIVE_fnc_hashGet;
        private _s = [_sorties, _sortieId, []] call ALIVE_fnc_hashGet;

        if (count _s == 0) exitWith {
            ["ALIVE_fnc_ATOTask - event %1 for unknown sortie %2", _event, _sortieId] call ALiVE_fnc_dump;
            _result = false;
        };

        switch (_event) do {
            // The airframe could not take the job. Put the request back with
            // that tail excluded, so the next attempt reaches a different
            // aircraft rather than the same one three times.
            case "assignFailed": {
                private _attempts = ([_s, "attempts", 0] call ALIVE_fnc_hashGet) + 1;
                private _excluded = [_s, "excluded", []] call ALIVE_fnc_hashGet;
                if !(_tail isEqualTo "") then { _excluded pushBackUnique _tail };
                [_s, "attempts", _attempts] call ALIVE_fnc_hashSet;
                [_s, "excluded", _excluded] call ALIVE_fnc_hashSet;
                [_s, "tails", []] call ALIVE_fnc_hashSet;
                if (_attempts >= MAX_ATTEMPTS) then {
                    [_s, "state", "denied"] call ALIVE_fnc_hashSet;
                    [_s, "reason", "no airframe took the job"] call ALIVE_fnc_hashSet;
                } else {
                    [_s, "state", "planning"] call ALIVE_fnc_hashSet;
                };
                _result = [_s, "state", ""] call ALIVE_fnc_hashGet;
            };

            // A sortie whose every aircraft is gone, or has been taken over by
            // a player, is finished whatever it was sent to do. Recorded with
            // the reason so the record explains itself later.
            case "onLost";
            case "sortiePlayerControl": {
                private _tails = [_s, "tails", []] call ALIVE_fnc_hashGet;
                _tails = _tails - [_tail];
                [_s, "tails", _tails] call ALIVE_fnc_hashSet;
                if (count _tails == 0) then {
                    [_s, "state", "complete"] call ALIVE_fnc_hashSet;
                    private _why = if (_event isEqualTo "onLost") then {"every aircraft lost"} else {"taken over by a player"};
                    [_s, "reason", _why] call ALIVE_fnc_hashSet;
                };
                _result = [_s, "state", ""] call ALIVE_fnc_hashGet;
            };

            case "sortieArrived":   { [_s, "state", "onStation"] call ALIVE_fnc_hashSet; _result = "onStation" };
            case "sortieReturning": { [_s, "state", "returning"] call ALIVE_fnc_hashSet; _result = "returning" };

            default {
                ["ALIVE_fnc_ATOTask - sortie %1 ignored unknown event %2", _sortieId, _event] call ALiVE_fnc_dump;
                _result = false;
            };
        };
    };

    // ---- the three the air picture raises ----------------------------------
    // Each is refused while something of its own kind is already up over that
    // airspace, so a repeated call does not stack sorties on one zone.
    case "scheduleCAP";
    case "scrambleDCA";
    case "raiseSEAD": {
        _args params [["_zone","",[""]], ["_detail",[],[[]]], ["_now",0,[0]]];
        private _type = switch (_operation) do {
            case "scheduleCAP": { "CAP" };
            case "scrambleDCA": { "DCA" };
            default { "SEAD" };
        };

        private _busy = [_logic, "activeInZone", [_zone, [_type]]] call MAINCLASS;
        if (count _busy > 0) exitWith {
            _result = ["denied", format ["a %1 is already up over %2", _type, _zone]];
        };

        private _request = [[
            ["id", format ["%1_%2_%3", _type, _zone, _now]],
            ["type", _type],
            ["airspace", _zone],
            ["targetPos", _detail param [0, [0,0,0]]],
            ["targets", _detail],
            ["requester", [[["kind","ATO"]]] call ALIVE_fnc_hashCreate],
            ["receivedAt", _now],
            ["duration", [_logic, "waitFor", _type] call MAINCLASS]
        ]] call ALIVE_fnc_hashCreate;

        _result = [_logic, "submit", _request] call MAINCLASS;
    };

    case "status": {
        private _reqId = _args;
        private _sorties = [_logic, "sorties", []] call ALIVE_fnc_hashGet;
        private _out = [];
        {
            private _s = [_sorties, _x, []] call ALIVE_fnc_hashGet;
            if (([_s, "requestId", ""] call ALIVE_fnc_hashGet) isEqualTo _reqId) then {
                _out = [_x,
                        [_s, "state", ""] call ALIVE_fnc_hashGet,
                        [_s, "tails", []] call ALIVE_fnc_hashGet];
            };
        } forEach (_sorties select 1);
        _result = _out;
    };

    case "cancel": {
        private _reqId = _args;
        private _sorties = [_logic, "sorties", []] call ALIVE_fnc_hashGet;
        private _hit = false;
        {
            private _s = [_sorties, _x, []] call ALIVE_fnc_hashGet;
            private _st = [_s, "state", ""] call ALIVE_fnc_hashGet;
            if (([_s, "requestId", ""] call ALIVE_fnc_hashGet) isEqualTo _reqId
                && {!(_st in ["complete","denied"])}) then {
                [_s, "state", "complete"] call ALIVE_fnc_hashSet;
                [_s, "reason", "cancelled"] call ALIVE_fnc_hashSet;
                _hit = true;
            };
        } forEach (_sorties select 1);
        _result = _hit;
    };

    // Placement and Base push their state in rather than being asked for it.
    case "firstPassDone": { [_logic, "firstPassDone", true] call ALIVE_fnc_hashSet; _result = true };
    case "assetCount":    { [_logic, "assetCount", _args] call ALIVE_fnc_hashSet; _result = true };
    case "baseFailed": {
        _args params [["_failed",true,[true]], ["_reason","no airbase",[""]]];
        [_logic, "baseFailed", _failed] call ALIVE_fnc_hashSet;
        [_logic, "baseFailedReason", _reason] call ALIVE_fnc_hashSet;
        _result = true;
    };

    // Settings arrive as pairs rather than as a fixed argument list, so the
    // Kernel can push whatever the module's attributes gave it without this
    // piece having to know which attributes exist.
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

    // ---- who a task can be offered to (M3) ---------------------------------
    // Everyone on the side who is still taking orders they did not ask for.
    //
    // A group that has opted out of automatic orders was still being handed air
    // tasks, because these are raised here rather than through the commander and
    // the opt-out was only ever read on the commander's own routes. Opting out is
    // meant to stop tasks arriving unasked, whichever part of ALiVE raises them.
    //
    // Falls back to the plain side list when C2ISTAR is absent, because the
    // opt-out cannot exist without it and the work should still be offered. The
    // shape is [names, ids] and the fallback source answers in the other order,
    // which is why it is swapped.
    case "sidePlayers": {
        private _side = [_logic, "side", ""] call ALIVE_fnc_hashGet;
        private _players = [];
        if (["ALiVE_mil_c2istar"] call ALiVE_fnc_isModuleAvailable) then {
            _players = ["getAutoOrderSidePlayers", [_side]] call ALiVE_fnc_playerOrders;
        };
        if (isNil "_players" || {!(_players isEqualType [])} || {count _players < 2}) then {
            private _src = [_side] call ALiVE_fnc_getPlayersDataSource;
            if (_src isEqualType [] && {count _src > 1}) then {
                _players = [_src select 1, _src select 0];
            } else {
                _players = [[],[]];
            };
        };
        _result = _players;
    };

    // ---- handing an opportunity to players (M1) ----------------------------
    // The module has found something it cannot or should not deal with itself,
    // so it offers it to whoever is on the side.
    //
    // Deduped per type against the public registry, because the same air
    // defence is spotted on every scan and each sighting would otherwise become
    // another identical task.
    case "playerTask": {
        _args params [["_type","",[""]], ["_targets",[],[[]]], ["_extra",""]];

        if !([_logic, "generateTasks", false] call ALIVE_fnc_hashGet) exitWith {
            _result = ["denied", "task generation off"];
        };
        if (_type isEqualTo "") exitWith { _result = ["denied", "no type"] };

        private _wanted = +_targets;

        // The first target is the one the module is dealing with itself, so
        // players are offered the rest. The three types below are different:
        // nothing of ours is going after them, so the primary stays.
        if !(_type in ["SEAD","DefendHQ","Laze"]) then {
            _wanted = _wanted select [1, (count _wanted) max 0];
        };

        // Laze pairs to the sortie's PRIMARY target only. Letting the dedupe
        // below fall through to a secondary slot could hand out a null one,
        // resolved from a dead profile, and the task would succeed the instant
        // it was created.
        if (_type isEqualTo "Laze") then {
            _wanted = (_wanted select [0,1]) select { !isNull _x && {alive _x} };
        };

        if (count _wanted == 0) exitWith { _result = ["denied", "no target left for players"] };

        if (isNil QGVAR(playerRequests)) then {
            GVAR(playerRequests) = [] call ALiVE_fnc_hashCreate;
        };
        private _already = [GVAR(playerRequests), _type, []] call ALiVE_fnc_hashGet;
        private _target = nil;
        { if !(_x in _already) exitWith { _target = _x } } forEach _wanted;
        if (isNil "_target") exitWith { _result = ["denied", "already offered"] };

        // Where the task points, and whose it is. A target is either a profile
        // id or a live object, and only one of those answers to position.
        private _destination = [];
        private _enemyFaction = "OPF_F";
        if (_target isEqualType "") then {
            // Guarded, because the handler is a global that only exists once
            // sys_profile has started. Reading it without this throws rather
            // than answering, and a target that cannot be resolved should be
            // refused politely below instead.
            private _profile = nil;
            if (!isNil "ALiVE_profileHandler") then {
                _profile = [ALiVE_profileHandler, "getProfile", _target] call ALiVE_fnc_ProfileHandler;
            };
            if !(isNil "_profile") then {
                _destination = [_profile, "position", []] call ALiVE_fnc_hashGet;
                _enemyFaction = [_profile, "faction", "OPF_F"] call ALiVE_fnc_hashGet;
            };
        } else {
            if !(isNull _target) then {
                _destination = position _target;
                _enemyFaction = faction _target;
            };
        };

        // A building carries no usable faction, so fall back to whoever holds
        // the ground, and only when they are actually hostile: a friendly or
        // civilian dominant faction would mis-colour the task and, under
        // constant auto-tasking, poison the side's enemy-faction config.
        if (_type isEqualTo "Laze" && {_enemyFaction in ["","Default"]}) then {
            _enemyFaction = "OPF_F";
            private _dom = [_destination, 3000] call ALiVE_fnc_getDominantFaction;
            if (!isNil "_dom" && {!(_dom isEqualTo "")}) then {
                private _sideObj = [[_logic, "side", ""] call ALIVE_fnc_hashGet] call ALIVE_fnc_sideTextToObject;
                private _domSide = _dom call ALiVE_fnc_factionSide;
                if (!(_domSide isEqualTo civilian) && {(_sideObj getFriend _domSide) < 0.6}) then {
                    _enemyFaction = _dom;
                };
            };
        };

        if (count _destination == 0) exitWith { _result = ["denied", "target has no position"] };

        private _players = [_logic, "sidePlayers"] call MAINCLASS;
        if ((_players param [0, []]) isEqualTo []) exitWith {
            _result = ["denied", "nobody on the side is taking orders"];
        };

        private _side = [_logic, "side", ""] call ALIVE_fnc_hashGet;
        private _faction = [_logic, "faction", ""] call ALIVE_fnc_hashGet;

        // C2ISTAR's vocabulary differs from the commander's for two of these.
        private _taskType = switch (_type) do {
            case "DefendHQ": { "MilDefence" };
            case "Strike":   { "DestroyBuilding" };
            default          { _type };
        };

        // OCA hands over every target it was given, because the point of it is
        // the whole airfield rather than one aircraft standing on it.
        private _targetArray = if (_type isEqualTo "OCA") then { _wanted } else { [_target] };

        private _taskData = [
            format ["%1_%2", _faction, floor time],
            "ATO", _side, _faction, _taskType, "NULL",
            _destination, _players, _enemyFaction, "Y", "Side", _targetArray
        ];

        // Index 12, and only these two types carry one. CAS names the friendly
        // the strike is supporting; Laze carries this sortie's own decoy lasers,
        // which the player scan must ignore, and the strike window in seconds.
        if (_type isEqualTo "CAS") then { _taskData pushBack _extra };
        if (_type isEqualTo "Laze") then {
            _taskData pushBack (if (_extra isEqualType []) then {_extra} else {[[], 900]});
        };

        private _event = ["TASK_GENERATE", _taskData, "ATO"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;

        _already pushBack _target;
        [GVAR(playerRequests), _type, _already] call ALiVE_fnc_hashSet;
        _result = ["raised", _taskData select 0, _taskType];
    };

    // ---- offering a downed crew as a rescue (M2) ---------------------------
    // Every gate here is a refusal with a reason rather than a silent no-op, so
    // a mission that never sees a rescue can be told which gate closed.
    //
    // There is no crew profile to find any more. An adopted airframe is not a
    // sys_profile profile (decision 6), so the old module's branch that read the
    // crew's profile, pinned it with a waypoint and skipped the chance roll on
    // the grounds they were demonstrably alive has nothing left to read. Every
    // rescue now goes through the chance roll.
    case "csar": {
        _args params [["_tail","",[""]], ["_class","",[""]], ["_pos",[],[[]]]];

        if !([_logic, "generateTasks", false] call ALIVE_fnc_hashGet) exitWith {
            _result = ["denied", "task generation off"];
        };
        // Re-checked per call rather than cached at start-up: a mission can
        // load C2ISTAR late, and the old module decided this once and was then
        // wrong for the rest of the mission.
        if !(["ALiVE_mil_c2istar"] call ALiVE_fnc_isModuleAvailable) exitWith {
            _result = ["denied", "no c2istar"];
        };
        if (count _pos < 2) exitWith { _result = ["denied", "no position"] };

        private _players = [_logic, "sidePlayers"] call MAINCLASS;
        if ((_players param [0, []]) isEqualTo []) exitWith {
            _result = ["denied", "nobody on the side is taking orders"];
        };

        private _side = [_logic, "side", ""] call ALIVE_fnc_hashGet;
        private _faction = [_logic, "faction", ""] call ALIVE_fnc_hashGet;

        // Rescue where the wreck is, if the wreck is somewhere anybody can
        // reach. A hull that went into the sea leaves its last known position
        // as the only thing worth pointing at.
        private _destination = +_pos;
        _destination set [2, 0];
        if !(_class isEqualTo "") then {
            private _wrecks = (entities _class) select { !alive _x };
            if (count _wrecks > 0) then {
                private _sorted = [_wrecks, [_destination], {_input0 distance _x}, "ASCEND"] call ALiVE_fnc_SortBy;
                private _wreck = _sorted select 0;
                if !(surfaceIsWater (position _wreck)) then {
                    _destination = position _wreck;
                    _destination set [2, 0];
                };
                deleteVehicle _wreck;
            };
        };

        // Nothing to be rescued FROM is not a rescue. Kept from the old module:
        // a crash on friendly ground with nobody near it is a recovery the side
        // can manage without being asked.
        private _enemyNear = [_destination, _side, 3000, true] call ALiVE_fnc_isEnemyNear;
        private _enemyFaction = [_destination, 3000] call ALiVE_fnc_getDominantFaction;
        private _enemyGround = false;
        if (!isNil "_enemyFaction" && {!(_enemyFaction isEqualTo "")}) then {
            _enemyGround = (([_side] call ALIVE_fnc_sideTextToObject) getFriend (_enemyFaction call ALIVE_fnc_factionSide)) < 0.6;
        } else {
            _enemyFaction = "OPF_F";
        };
        if (!_enemyNear && {!_enemyGround}) exitWith {
            _result = ["denied", "crew is not in danger"];
        };

        if (random 1 >= ([_logic, "chanceOfRescue", 0.5] call ALIVE_fnc_hashGet)) exitWith {
            _result = ["denied", "no rescue this time"];
        };

        // Class at index 11, where another task carries its targets, and nothing
        // at 12. The old module appended the crew's profile id there; an adopted
        // airframe has no profile, so there is no id to append and anything
        // reading index 12 would be reading a stale value.
        private _taskData = [
            format ["%1_%2", _faction, floor time],
            "ATO", _side, _faction, "CSAR", "NULL",
            _destination, _players, _enemyFaction, "Y", "Side", _class
        ];

        private _event = ["TASK_GENERATE", _taskData, "ATO"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;
        ["ALIVE_fnc_ATOTask - rescue offered for %1 (%2) at %3", _tail, _class, _destination] call ALiVE_fnc_dump;
        _result = ["raised", _taskData select 0, "CSAR"];
    };

    // ---- moving an airframe for its own sake -------------------------------
    // A FERRY is the module flying one of its own aircraft somewhere rather
    // than flying it AT something. That is why it is the one type a commander
    // cannot ask for and the one that never counts against the sortie cap: it
    // is how a hull that came down away from home gets back without being
    // teleported in front of somebody.
    case "openFerry": {
        _args params [["_tail","",[""]], ["_to",[],[[]]]];
        if (_tail isEqualTo "") exitWith { _result = ["denied", "no tail"] };

        private _request = [[
            ["id", format ["ferry_%1_%2", _tail, floor time]],
            ["type", "FERRY"],
            ["side", [_logic, "side", ""] call ALIVE_fnc_hashGet],
            ["faction", [_logic, "faction", ""] call ALIVE_fnc_hashGet],
            ["airspace", ""],
            ["targetPos", _to],
            ["targets", []],
            ["roe", "NEVER"],
            ["requester", [[["kind","ATO"]]] call ALIVE_fnc_hashCreate],
            ["receivedAt", time],
            ["duration", [_logic, "waitFor", "FERRY"] call MAINCLASS],
            // The one airframe this is about. Nothing else will do, so the
            // planner is told not to look further.
            ["onlyTail", _tail]
        ]] call ALIVE_fnc_hashCreate;

        _result = [_logic, "submit", _request] call MAINCLASS;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Task - output",_result);

_result;
