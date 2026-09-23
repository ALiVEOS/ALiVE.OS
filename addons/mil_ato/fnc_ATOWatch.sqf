#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(watch);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOWatch

Description:
The air picture. What is in the airspace that should not be, and what on the
ground can shoot at an aircraft.

It looks and it asks. It never orders an airframe anywhere: everything it wants
doing goes to the Tasker as a request with the module itself as the requester,
so the Tasker's own caps, gates and denials apply to a scramble exactly as they
apply to a commander's request. That separation is the point of this piece
existing rather than the scan raising sorties directly, which is what the old
module did and why a scan could put more aircraft up than the sortie limit
allowed.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_w = [nil, "create"] call ALIVE_fnc_ATOWatch;
[_w, "configure", [["airspaces", ["AS1"]], ["enemySides", ["EAST"]]]] call ALIVE_fnc_ATOWatch;
_raised = [_w, "tick", [time]] call ALIVE_fnc_ATOWatch;

(end)

See Also:
<ALIVE_fnc_ATOTask>, <ALIVE_fnc_ATOObserve>, <ALIVE_fnc_ATOBase>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOWatch

// How high something has to be before this counts it as flying rather than
// driving. The old module's figure, kept: below it an aircraft on a runway or a
// helicopter hopping between hangars would read as an intrusion.
#define RADAR_HEIGHT 105

// The static air defences the base game gives one side only, plus everything
// the armament test recognises. These three are checked by class because a
// crewless launcher is still a launcher, and the test below asks whether a
// vehicle is armed.
#define AA_STATICS ["AAA_System_01_base_F", "SAM_System_01_base_F", "SAM_System_02_base_F"]

// A standing patrol is staggered rather than launched on a fixed clock, so two
// airspaces do not scramble in the same second every time.
#define CAP_MIN 300
#define CAP_MAX 900

private ["_result"];

TRACE_1("ATO Watch - input",_this);

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

            // Which airspaces this commander answers for, as marker names.
            ["airspaces", []],

            // Who counts as hostile. Factions decide what is an intruder,
            // because an aircraft carries one; sides decide what is an air
            // defence, because the old scan asked that of a vehicle's side and
            // a captured launcher should still be treated by who holds it.
            ["enemyFactions", []],
            ["enemySides", []],

            // The sortie types this commander is allowed to raise at all. A
            // type absent from here is never asked for, however threatening the
            // picture looks.
            ["types", []],

            ["generateTasks", false],
            ["generateSEADTasks", false],

            // Zone to the time its last patrol went up. Kept per instance and
            // mirrored to the public name, so two commanders over one map do
            // not read each other's cadence.
            ["lastCAP", [] call ALIVE_fnc_hashCreate],

            // Threats somebody else told us about, zone to a list of objects or
            // profile ids. Separate from the scan because a threat reported by
            // a player or by another module is not necessarily visible to a
            // sweep of live vehicles.
            ["threats", [] call ALIVE_fnc_hashCreate],

            // The name this instance's threats are published under, so the
            // public registry can hold more than one commander's.
            ["key", "default"],

            ["task", []],

            ["running", false],
            ["paused", false],
            ["lastTick", -1],
            ["ticks", 0]
        ]] call ALIVE_fnc_hashCreate;
    };

    // Settings as pairs, the same idiom the Tasker uses, so the Kernel can push
    // whatever the module's attributes gave it without this piece needing to
    // know which attributes exist.
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

    case "start":  { [_logic, "running", true] call ALIVE_fnc_hashSet; _result = true };
    case "stop":   { [_logic, "running", false] call ALIVE_fnc_hashSet; _result = true };
    case "pause":  {
        private _on = _args;
        if !(_on isEqualType true) then { _on = true };
        [_logic, "paused", _on] call ALIVE_fnc_hashSet;
        _result = true;
    };

    // ---- somebody else saw something ---------------------------------------
    // A threat reported from outside the scan: a player lazing a launcher, or
    // another module handing over what it found.
    //
    // Takes an object or a profile id, because a threat that has despawned is
    // still a threat and only its profile remains. The old version read
    // profileID off whatever it was handed, which throws when handed an id, and
    // it keyed the whole registry by the string form of the module's own hash.
    case "registerThreat": {
        _args params [["_threat", objNull, [objNull, ""]], ["_zone", "", [""]]];

        private _id = _threat;
        // An object that still carries a profile id is remembered by the id, so
        // the same launcher reported twice, once live and once virtual, is one
        // entry rather than two.
        if (_threat isEqualType objNull) then {
            if (isNull _threat) exitWith {};
            private _pid = _threat getVariable ["profileID", ""];
            if !(_pid isEqualTo "") then { _id = _pid };
        };
        if (_id isEqualType objNull && {isNull _id}) exitWith {
            _result = false;
        };

        // No zone given: file it under the airspace it is actually in, or the
        // first one this commander holds, so it is not lost.
        private _spaces = [_logic, "airspaces", []] call ALIVE_fnc_hashGet;
        if (_zone isEqualTo "") then {
            _zone = [_logic, "zoneFor", _id] call MAINCLASS;
        };
        if (_zone isEqualTo "" && {count _spaces > 0}) then { _zone = _spaces select 0 };
        if (_zone isEqualTo "") exitWith { _result = false };

        private _threats = [_logic, "threats", []] call ALIVE_fnc_hashGet;
        private _inZone = [_threats, _zone, []] call ALIVE_fnc_hashGet;
        _inZone pushBackUnique _id;
        [_threats, _zone, _inZone] call ALIVE_fnc_hashSet;

        // Published under the public name as well, because a third party may
        // read it and the old module offered it.
        if (isNil QGVAR(threats)) then { GVAR(threats) = [] call ALIVE_fnc_hashCreate };
        [GVAR(threats), [_logic, "key", "default"] call ALIVE_fnc_hashGet, _threats] call ALIVE_fnc_hashSet;

        _result = true;
    };

    // ---- where something is, whatever it is --------------------------------
    // A threat is an object or a profile id, and only one of those answers to
    // position. Answers [] when it cannot be placed, which the callers treat as
    // "skip this one" rather than as [0,0,0], because [0,0,0] is a real corner
    // of every map and the old code sorted threats against it.
    case "positionOf": {
        private _what = _args;
        _result = [];
        if (_what isEqualType objNull) then {
            if (!isNull _what) then { _result = getPosATL _what };
        } else {
            if (_what isEqualType "" && {!isNil "ALiVE_profileHandler"}) then {
                private _got = [ALiVE_profileHandler, "getProfile", _what] call ALiVE_fnc_ProfileHandler;
                if (!isNil "_got" && {_got isEqualType []}) then {
                    _result = [_got, "position", []] call ALIVE_fnc_hashGet;
                };
            };
        };
        if !(_result isEqualType []) then { _result = [] };
    };

    // ---- which airspace something belongs to -------------------------------
    // Inside one, that one. Outside all of them, the nearest, because an air
    // defence two hundred metres outside a marker still shoots at anything
    // flying inside it. Answers "" only when there are no airspaces at all.
    case "zoneFor": {
        private _what = _args;
        private _spaces = [_logic, "airspaces", []] call ALIVE_fnc_hashGet;
        _result = "";
        if (count _spaces == 0) exitWith {};

        private _at = [_logic, "positionOf", _what] call MAINCLASS;
        if (count _at < 2) exitWith {};

        private _inside = "";
        {
            if (_inside isEqualTo "" && {_at inArea _x}) then { _inside = _x };
        } forEach _spaces;
        if !(_inside isEqualTo "") exitWith { _result = _inside };

        private _best = "";
        private _bestDist = 1e10;
        {
            private _d = _at distance2D (getMarkerPos _x);
            if (_d < _bestDist) then { _bestDist = _d; _best = _x };
        } forEach _spaces;
        _result = _best;
    };

    // ---- what is up there that should not be -------------------------------
    // Enemy aircraft above radar height, per airspace.
    case "scanBogeys": {
        private _spaces = [_logic, "airspaces", []] call ALIVE_fnc_hashGet;
        private _factions = [_logic, "enemyFactions", []] call ALIVE_fnc_hashGet;
        private _found = [] call ALIVE_fnc_hashCreate;

        if (count _spaces > 0 && {count _factions > 0}) then {
            {
                private _bogey = _x;
                // Airborne first: it is the cheapest test and it throws out
                // almost everything, and faction on a wreck is not worth asking.
                if (alive _bogey
                    && {_bogey isKindOf "Air"}
                    && {((getPosATL _bogey) select 2) > RADAR_HEIGHT}
                    && {(faction _bogey) in _factions}) then {
                    private _at = getPosATL _bogey;
                    {
                        if (_at inArea _x) then {
                            private _inZone = [_found, _x, []] call ALIVE_fnc_hashGet;
                            _inZone pushBackUnique _bogey;
                            [_found, _x, _inZone] call ALIVE_fnc_hashSet;
                        };
                    } forEach _spaces;
                };
            } forEach vehicles;
        };
        _result = _found;
    };

    // ---- what on the ground can reach them ---------------------------------
    // The three statics the base game gives one side only, plus anything the
    // armament test calls air defence, plus whatever was reported from outside.
    case "scanThreats": {
        private _spaces = [_logic, "airspaces", []] call ALIVE_fnc_hashGet;
        private _sides = [_logic, "enemySides", []] call ALIVE_fnc_hashGet;
        private _factions = [_logic, "enemyFactions", []] call ALIVE_fnc_hashGet;
        private _found = [] call ALIVE_fnc_hashCreate;

        if (count _spaces > 0) then {
            {
                private _veh = _x;
                // Whose it is, by FACTION first and side only as a fallback.
                //
                // This is the fix for a scan that found almost nothing.
                // Measured: an EMPTY vehicle reports its side as CIV whatever it
                // is, so an unmanned launcher sitting in a field was never
                // hostile to a side test, and most air defence in a profiled
                // mission is unmanned most of the time. Worse, two of the
                // classes report CIV even with a crew, because the crew the
                // engine gives them is UAV AI: O_SAM_System_01_F and the tracked
                // AA both did. Faction answered correctly in every case, manned
                // or not.
                //
                // The old module asked side alone and had a commented-out block
                // beside it that crewed every air defence it found, which was an
                // attempt to work around this by changing the world rather than
                // the question.
                private _hostile = false;
                if (count _factions > 0) then { _hostile = (faction _veh) in _factions };
                if (!_hostile && {count _sides > 0}) then {
                    _hostile = (str (side _veh)) in _sides;
                };

                if (alive _veh && {_hostile}) then {
                    private _isAA = (AA_STATICS findIf { _veh isKindOf _x }) > -1;
                    // The elevation-only test is deliberately not used. It asks
                    // whether a turret elevates past sixty-five degrees and the
                    // hull is not artillery, which any high-elevation remote
                    // mount satisfies whether or not it is armed, and that was
                    // one of the two sources of the wrongly reported targets in
                    // the SEAD complaint. This one requires armament.
                    //
                    // Called directly rather than through the old module's
                    // one-line wrapper, which is defined inside that module's
                    // own body and so does not exist until it has run.
                    if (!_isAA && {!isNil "ALiVE_fnc_isAntiAirCapable"}) then {
                        _isAA = [_veh] call ALiVE_fnc_isAntiAirCapable;
                    };
                    if (_isAA) then {
                        private _zone = [_logic, "zoneFor", _veh] call MAINCLASS;
                        if !(_zone isEqualTo "") then {
                            private _inZone = [_found, _zone, []] call ALIVE_fnc_hashGet;
                            _inZone pushBackUnique _veh;
                            [_found, _zone, _inZone] call ALIVE_fnc_hashSet;
                        };
                    };
                };
            } forEach vehicles;
        };

        // And the reported ones. A threat that cannot be placed is SKIPPED, not
        // abandoned: the old loop used exitWith here, which leaves the whole
        // forEach, so one unresolvable threat threw away every threat after it.
        private _reported = [_logic, "threats", []] call ALIVE_fnc_hashGet;
        {
            private _zone = _x;
            {
                private _at = [_logic, "positionOf", _x] call MAINCLASS;
                if (count _at >= 2) then {
                    private _inZone = [_found, _zone, []] call ALIVE_fnc_hashGet;
                    _inZone pushBackUnique _x;
                    [_found, _zone, _inZone] call ALIVE_fnc_hashSet;
                };
            } forEach ([_reported, _zone, []] call ALIVE_fnc_hashGet);
        } forEach (_reported select 1);

        _result = _found;
    };

    // ---- one pass of the air picture ---------------------------------------
    // Look, then ask. Returns what it asked for, so a caller can log a pass
    // without this piece deciding what is worth saying.
    //
    // The records and rows are optional and are only used to answer one
    // question: is there a SEAD-capable aircraft actually sitting on the ground
    // ready to go. Without them the answer is taken to be no, which is the
    // conservative reading: it offers the job to players instead of ordering a
    // sortie it may not be able to fly.
    case "tick": {
        _args params [["_now", 0, [0]], ["_records", [], [[]]], ["_rows", [], [[]]]];

        _result = [];

        if !([_logic, "running", false] call ALIVE_fnc_hashGet) exitWith {};
        if ([_logic, "paused", false] call ALIVE_fnc_hashGet) exitWith {};

        private _task = [_logic, "task", []] call ALIVE_fnc_hashGet;
        if !(_task isEqualType []) exitWith { _result = [] };
        if (count _task < 3) exitWith {
            ["ALIVE_fnc_ATOWatch - no tasker to ask, nothing raised"] call ALiVE_fnc_dump;
            _result = [];
        };

        private _types = [_logic, "types", []] call ALIVE_fnc_hashGet;
        private _spaces = [_logic, "airspaces", []] call ALIVE_fnc_hashGet;
        private _raised = [];

        // Asked again on every pass, not once at start-up. A mission can load
        // the task system late, and the old module decided this before its
        // first scan and was then wrong for the rest of the mission, which is
        // why no air-defence task ever appeared in a mission that loaded
        // C2ISTAR after the commander.
        private _c2 = ["ALiVE_mil_c2istar"] call ALiVE_fnc_isModuleAvailable;
        private _mayTask = _c2 && {[_logic, "generateTasks", false] call ALIVE_fnc_hashGet};

        private _bogeys = [_logic, "scanBogeys"] call MAINCLASS;
        private _threats = [_logic, "scanThreats"] call MAINCLASS;

        // ---- intruders: scramble the interceptors ---------------------------
        if ("DCA" in _types) then {
            {
                private _zone = _x;
                private _seen = [_bogeys, _zone, []] call ALIVE_fnc_hashGet;
                if (count _seen > 0) then {
                    private _busy = [_task, "activeInZone", [_zone, ["DCA"]]] call ALIVE_fnc_ATOTask;
                    if (count _busy == 0) then {
                        private _answer = [_task, "scrambleDCA", [_zone, _seen, _now]] call ALIVE_fnc_ATOTask;
                        _raised pushBack ["DCA", _zone, count _seen, _answer];
                    };
                    // More than one and the interceptors cannot be everywhere,
                    // so the rest is offered to whoever is flying.
                    if (count _seen > 1 && {_mayTask}) then {
                        [_task, "playerTask", ["DCA", _seen]] call ALIVE_fnc_ATOTask;
                    };
                };
            } forEach _spaces;
        };

        // ---- standing patrol ------------------------------------------------
        if ("CAP" in _types) then {
            private _last = [_logic, "lastCAP", []] call ALIVE_fnc_hashGet;
            {
                private _zone = _x;
                private _when = [_last, _zone, -1] call ALIVE_fnc_hashGet;

                // The first patrol over an airspace goes up straight away, so a
                // mission does not open with nothing overhead. After that they
                // are spaced out, and STAGGERED per airspace so two of them do
                // not scramble in the same second every time.
                //
                // The stagger is worked out from the airspace name rather than
                // rolled, and this matters: a roll inside the test is re-rolled
                // on every pass, so over many passes the shortest roll always
                // wins and the interval collapses to its minimum. It also makes
                // the cadence untestable. The old module rolled it.
                private _spread = CAP_MAX - CAP_MIN;
                private _stagger = CAP_MIN;
                if (_spread > 0) then {
                    private _letters = toArray (_zone + " ");
                    private _seed = (count _letters) * 37 + (_letters select 0);
                    _stagger = CAP_MIN + (_seed % _spread);
                };
                private _due = _when < 0 || {(_now - _when) > _stagger};
                if (_due) then {
                    private _busy = [_task, "activeInZone", [_zone, ["CAP"]]] call ALIVE_fnc_ATOTask;
                    if (count _busy == 0) then {
                        private _answer = [_task, "scheduleCAP", [_zone, [getMarkerPos _zone], _now]] call ALIVE_fnc_ATOTask;
                        // The clock is set whether or not it was accepted.
                        // Otherwise a refusal is retried on every pass, which
                        // turns a denied patrol into a denial every minute for
                        // the rest of the mission.
                        [_last, _zone, _now] call ALIVE_fnc_hashSet;
                        _raised pushBack ["CAP", _zone, 0, _answer];
                    };
                };
            } forEach _spaces;
            if (isNil QGVAR(lastCAP)) then { GVAR(lastCAP) = [] call ALIVE_fnc_hashCreate };
            [GVAR(lastCAP), [_logic, "key", "default"] call ALIVE_fnc_hashGet, _last] call ALIVE_fnc_hashSet;
        };

        // ---- air defences: suppress them, or ask somebody who can -----------
        // A sortie is only raised when there is an aircraft that can actually
        // do it sitting ready. Otherwise the job goes to players, which is the
        // whole reason the old module had this raise commented out with the
        // note that aircraft get killed by air defences: sending an unsuitable
        // airframe at a launcher is worse than sending nobody.
        if ("SEAD" in _types) then {
            {
                private _zone = _x;
                private _seen = [_threats, _zone, []] call ALIVE_fnc_hashGet;
                if (count _seen > 0) then {
                    private _ready = false;
                    {
                        private _rec = [_records, _x, []] call ALIVE_fnc_hashGet;
                        private _row = [_rows, _x, []] call ALIVE_fnc_hashGet;
                        if (!_ready && {count _rec > 0} && {count _row > 0}) then {
                            private _state = [_row, "state", ""] call ALIVE_fnc_hashGet;
                            private _caps = [_rec, "capabilities", []] call ALIVE_fnc_hashGet;
                            // #1029: the capability is called antiRadiation and no role is ever
                            // called SEAD, so asking for "SEAD" here meant this never passed and
                            // no suppression sortie was ever raised.
                            if (_state isEqualTo "PARKED"
                                && {_caps isEqualType []} && {"antiRadiation" in _caps}) then {
                                _ready = true;
                            };
                        };
                    } forEach (if (count _records > 2) then {_records select 1} else {[]});

                    if (_ready) then {
                        private _busy = [_task, "activeInZone", [_zone, ["SEAD"]]] call ALIVE_fnc_ATOTask;
                        if (count _busy == 0) then {
                            // Positions rather than the things themselves, so a
                            // threat known only as a profile is still somewhere
                            // the sortie can be aimed.
                            private _at = [];
                            {
                                private _p = [_logic, "positionOf", _x] call MAINCLASS;
                                if (count _p >= 2) then { _at pushBack _p };
                            } forEach _seen;
                            if (count _at > 0) then {
                                private _answer = [_task, "raiseSEAD", [_zone, _at, _now]] call ALIVE_fnc_ATOTask;
                                _raised pushBack ["SEAD", _zone, count _at, _answer];
                            };
                        };
                    } else {
                        if (_mayTask && {[_logic, "generateSEADTasks", false] call ALIVE_fnc_hashGet}) then {
                            [_task, "playerTask", ["SEAD", _seen]] call ALIVE_fnc_ATOTask;
                            _raised pushBack ["SEAD", _zone, count _seen, ["handed to players"]];
                        };
                    };
                };
            } forEach _spaces;
        };

        [_logic, "lastTick", _now] call ALIVE_fnc_hashSet;
        [_logic, "ticks", ([_logic, "ticks", 0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
        _result = _raised;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Watch - output",_result);

_result;
