#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_contracts);

/* ----------------------------------------------------------------------------
The kernel's contract with everything outside it.

The nine other pieces each have their own test and each is exercised on its own.
This is the one that asks whether the thing they add up to starts, runs, and
keeps every promise the module made to the rest of the mod before it was taken
apart: the raw variables other modules read off the logic, the events the ground
commander and logistics raise, the pause the mission maker can press, and the
names the four older scripts call.

It drives ALIVE_fnc_ATO, which is the name every other addon calls and which
is now a forwarder onto the kernel. Driving the kernel directly would prove the
kernel; driving the name proves the thing that ships, including that calling it
is what defines the seven file-scope helpers other addons reach for.

Smallest mission: a player on Stratis near the airfield with the profile system
placed, and this run from the debug console. It creates its own commander, so no
air commander may be placed in the mission or the two will both answer.

Author:
Jman
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _skips = [];
    private _fnc_check = {
        // _ok taken as Any deliberately: an assertion whose expression threw
        // arrives as nil, and `if (nil)` would throw again and print nothing,
        // so the failure would disappear instead of being reported.
        params ["_name", ["_ok", nil, [true]]];
        if (isNil "_ok") exitWith {
            _fails pushBack _name;
            diag_log format ["  FAIL  %1  (assertion threw or returned nothing)", _name];
        };
        if (_ok) then {
            diag_log format ["  pass  %1", _name];
        } else {
            _fails pushBack _name;
            diag_log format ["  FAIL  %1", _name];
        };
    };
    private _fnc_skip = {
        _skips pushBack _this;
        diag_log format ["  skip  %1", _this];
    };

    diag_log "=== ATO Contracts test ===";

    // --- both names have to exist at all ------------------------------------
    ["the commander's own name is compiled and callable",
        !isNil "ALIVE_fnc_ATO"] call _fnc_check;
    ["and so is the kernel behind it",
        !isNil "ALIVE_fnc_ATOKernel"] call _fnc_check;
    if (isNil "ALIVE_fnc_ATOKernel" || {isNil "ALIVE_fnc_ATO"}) exitWith {
        diag_log "=== ATO Contracts test: the commander is not in this build, nothing else can run ===";
    };

    // The seven helper names are defined BY CALLING the commander, which is
    // the first thing the module's own init does. Asserted in that order,
    // because the observer asks for one of them behind a guard: if calling it
    // did not define them, the air defence scan would go blind silently
    // instead of loudly, and nothing would ever say so.
    private _helpers = ["ALiVE_fnc_catapultLaunch", "ALiVE_fnc_getAirportTaxiPos",
        "ALiVE_fnc_getNearestCatapult", "ALiVE_fnc_isVTOL", "ALiVE_fnc_isAntiAir",
        "ALiVE_fnc_DrawRunwayBlacklistMarkers", "ALiVE_fnc_CheckSpawnInMarkerArea"];
    private _before = 0;
    { if !(isNil _x) then { _before = _before + 1 } } forEach _helpers;
    diag_log format ["  info  %1 of %2 helper names were already defined before anything called the commander",
        _before, count _helpers];

    // Any operation at all defines them; a read of a default is the cheapest.
    [objNull, "debug"] call ALIVE_fnc_ATO;
    private _after = 0;
    { if !(isNil _x) then { _after = _after + 1 } } forEach _helpers;
    ["calling the commander defines the seven names other addons reach for",
        _after == count _helpers] call _fnc_check;
    if (_after < count _helpers) then {
        private _lostNames = [];
        { if (isNil _x) then { _lostNames pushBack _x } } forEach _helpers;
        diag_log format ["  info  still undefined: %1", _lostNames];
    };

    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _made = [];
    private _markers = [];
    private _logics = [];

    // A commander, built the way the mission maker's module arrives: every
    // attribute a STRING, because that is what the Eden attribute gives and
    // the accessors compare against "true". A boolean is a type error there,
    // not a false, and it kills the whole start-up.
    private _fnc_logic = {
        params ["_at", "_airspace", ["_faction", "BLU_F"], ["_persistent", "false"]];
        private _g = createGroup sideLogic;
        private _m = _g createUnit ["Logic", _at, [], 0, "CAN_COLLIDE"];
        _m setVariable ["airspace", _airspace];
        {
            _m setVariable [_x select 0, _x select 1];
        } forEach [["faction", _faction], ["debug", "false"], ["createHQ", "true"],
            ["placeAir", "false"], ["resupply", "false"], ["persistent", _persistent],
            ["broadcastOnRadio", "false"], ["generateTasks", "false"],
            ["generateSEADTasks", "false"], ["placeDrones", "false"], ["useUAVs", "true"]];
        _logics pushBack _m;
        _m
    };

    private _zone = "ato_contract_zone";
    private _mk = createMarker [_zone, _anchor];
    _mk setMarkerShape "ELLIPSE";
    _mk setMarkerSize [1500, 1500];
    _mk setMarkerAlpha 0;
    _markers pushBack _zone;

    // --- start-up -----------------------------------------------------------
    private _logic = [_anchor, [_zone]] call _fnc_logic;
    private _t0 = time;
    [_logic, "init"] call ALIVE_fnc_ATO;

    // Readiness is the promise the ground commander waits on, and it is
    // supposed to be true before the heavy start-up has finished, not after.
    private _readyAfter = -1;
    private _spin = 0;
    waitUntil {
        sleep 1;
        _spin = _spin + 1;
        if (_logic getVariable ["startupComplete", false] && {_readyAfter < 0}) then { _readyAfter = time - _t0 };
        (_readyAfter >= 0) || {_spin > 40}
    };
    diag_log format ["  info  started after %1 s", _readyAfter];
    ["the commander reports itself started", _readyAfter >= 0] call _fnc_check;
    ["and inside the thirty seconds the ground commander waits",
        _readyAfter >= 0 && {_readyAfter < 30}] call _fnc_check;
    ["and the shared readiness test agrees",
        [_logic] call ALiVE_fnc_isModuleInitialised] call _fnc_check;

    // --- the variables other modules read straight off the logic ------------
    // Nine of them, read by the main addon and by the ground commander
    // without going through any operation, so they have to be there whatever
    // the module is built out of underneath.
    private _missing = [];
    {
        if (isNil { _logic getVariable _x }) then { _missing pushBack _x };
    } forEach ["class", "super", "moduleType", "startupComplete", "position",
        "faction", "runwaystartpos", "runwayendpos", "runwaywidth", "objectiveObjects"];
    ["every variable another module reads off the logic is written",
        count _missing == 0] call _fnc_check;
    if (count _missing > 0) then {
        diag_log format ["  info  missing: %1", _missing];
    };
    ["and the class names the kernel, so the pause bus and the event log reach it",
        (_logic getVariable ["class", {}]) isEqualTo ALIVE_fnc_ATOKernel] call _fnc_check;
    ["and the module type is the one the rest of the mod looks for",
        (_logic getVariable ["moduleType", ""]) isEqualTo "ALIVE_ATO"] call _fnc_check;

    // --- the accessors keep their names, shapes and defaults ---------------
    private _wrong = [];
    {
        _x params ["_op", "_want"];
        private _got = [_logic, _op] call ALIVE_fnc_ATO;
        if !(_got isEqualTo _want) then { _wrong pushBack [_op, _got, _want] };
    } forEach [
        ["faction", "BLU_F"], ["side", "WEST"], ["createHQ", true], ["placeAir", false],
        ["resupply", false], ["persistent", false], ["broadcastOnRadio", false],
        ["generateTasks", false], ["generateSEADTasks", false], ["placeDrones", false],
        ["useUAVs", true], ["debug", false]
    ];
    ["every attribute answers with the value and the type it always did",
        count _wrong == 0] call _fnc_check;
    if (count _wrong > 0) then {
        diag_log format ["  info  wrong answers: %1", _wrong];
    };

    private _types = [_logic, "types"] call ALIVE_fnc_ATO;
    ["the sortie types come back as the list they always were",
        _types isEqualType [] && {"CAP" in _types} && {"CAS" in _types}] call _fnc_check;
    private _assets = [_logic, "assets"] call ALIVE_fnc_ATO;
    ["the asset list is readable and is a hash",
        [_assets] call ALIVE_fnc_isHash] call _fnc_check;

    // And it cannot be written, which is the whole of a reported fault where a
    // commander covering two factions lost track of its aircraft after a load.
    // The sortie path used to read the campaign store's record for the faction
    // it was working with and write it back over the commander's roster, so the
    // list became whichever faction flew last and anything added or lost in
    // between was gone. The roster is worked out from the records on every read
    // now, so there is nothing to write over and a write is refused outright.
    private _forged = [] call ALIVE_fnc_hashCreate;
    [_forged, "NOT_A_REAL_TAIL", [[["vehicleClass", "B_Plane_CAS_01_F"]]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
    [_logic, "assets", _forged] call ALIVE_fnc_ATO;
    private _afterWrite = [_logic, "assets"] call ALIVE_fnc_ATO;
    ["the roster refuses to be written over",
        ([_afterWrite, "NOT_A_REAL_TAIL", []] call ALIVE_fnc_hashGet) isEqualTo []] call _fnc_check;
    ["and reading it again gives the same answer as before",
        count (_afterWrite select 1) == count (_assets select 1)] call _fnc_check;

    // A name that was dropped must fall through to the base class and be
    // logged, not throw. That is what keeps an old caller alive.
    private _dropped = [_logic, "scanAirspace"] call ALIVE_fnc_ATO;
    ["an operation that no longer exists is logged rather than thrown",
        !isNil "_dropped"] call _fnc_check;

    // --- what the commander published --------------------------------------
    // Announced at the END of the base's start-up rather than at readiness,
    // so this waits for the base to finish. Readiness is deliberately earlier
    // than that: the ground commander must not have to wait for a garrison to
    // be built before it can ask for air support.
    private _kWait = [_logic, "kernel"] call ALIVE_fnc_ATO;
    private _baseW = if ([_kWait] call ALIVE_fnc_isHash) then { [_kWait, "base", []] call ALIVE_fnc_hashGet } else { [] };
    private _waited = 0;
    waitUntil {
        sleep 3;
        _waited = _waited + 3;
        (_baseW isEqualTo []) || {([_baseW, "phase"] call ALIVE_fnc_ATOBase) in ["established","failed"]} || {_waited > 120}
    };
    private _basePhase = if (_baseW isEqualTo []) then { "no base" } else { [_baseW, "phase"] call ALIVE_fnc_ATOBase };
    diag_log format ["  info  the base finished as '%1' after %2 s", _basePhase, _waited];
    ["the base finishes building rather than hanging",
        _basePhase isEqualTo "established"] call _fnc_check;

    private _side = [_logic, "side"] call ALIVE_fnc_ATO;
    private _availName = format ["ALIVE_MIL_ATO_AVAIL_%1", _side];
    if (isNil "ALiVE_require") then {
        // The holder those flags live on belongs to the required-modules
        // addon. A bare test mission has not got one, and inventing it here
        // would be testing the fixture rather than the module.
        "the commander announces itself to whoever asks whether air support exists  (no required-modules holder in this mission)" call _fnc_skip;
    } else {
        private _avail = ALiVE_require getVariable [_availName, nil];
        diag_log format ["  info  %1 is %2", _availName, if (isNil "_avail") then {"not set"} else {str _avail}];
        ["the commander announces itself to whoever asks whether air support exists",
            !isNil "_avail"] call _fnc_check;
    };
    ["and the global registry has it on the books",
        !isNil "ALIVE_ATOGlobalRegistry"] call _fnc_check;

    // --- an aircraft handed to it by name ----------------------------------
    // registerProfile is the operation another module uses to give this one an
    // aircraft it already owns. It is also what puts something on the roster
    // here, so that the pause below has a clock to move rather than passing
    // for want of anything to test.
    private _registered = "";
    if (!isNil "ALiVE_profileHandler" && {!isNil "ALIVE_fnc_createProfilesCrewedVehicle"}) then {
        private _pair = ["B_Heli_Attack_01_F", "WEST", "BLU_F", "CAPTAIN",
            _anchor getPos [260, 200], 0, false] call ALIVE_fnc_createProfilesCrewedVehicle;
        {
            if (_x isEqualType [] && {([_x, "type", ""] call ALIVE_fnc_hashGet) isEqualTo "vehicle"}) then {
                _registered = [_x, "profileID", ""] call ALIVE_fnc_hashGet;
            };
        } forEach _pair;
        diag_log format ["  info  handing over profile '%1'", _registered];
        private _answer = [_logic, "registerProfile", [_registered, _zone]] call ALIVE_fnc_ATO;
        diag_log format ["  info  registerProfile answered %1", _answer];
        ["an aircraft can be handed to the commander by profile",
            _answer isEqualType [] && {(_answer param [0, ""]) isEqualTo "spawned"}] call _fnc_check;

        private _onBooks = false;
        private _spin2 = 0;
        waitUntil {
            sleep 2;
            _spin2 = _spin2 + 2;
            private _kk = [_logic, "kernel"] call ALIVE_fnc_ATO;
            if ([_kk] call ALIVE_fnc_isHash) then {
                private _rr = [_kk, "rows", []] call ALIVE_fnc_hashGet;
                if ([_rr] call ALIVE_fnc_isHash) then { _onBooks = count (_rr select 1) > 0 };
            };
            _onBooks || {_spin2 > 60}
        };
        diag_log format ["  info  it reached the roster after %1 s", _spin2];
        ["and it turns up on the roster", _onBooks] call _fnc_check;
        private _seenAssets = [_logic, "assets"] call ALIVE_fnc_ATO;
        ["and in the asset list other modules read",
            ([_seenAssets] call ALIVE_fnc_isHash) && {count (_seenAssets select 1) > 0}] call _fnc_check;
    } else {
        "an aircraft can be handed to the commander by profile  (no profile system)" call _fnc_skip;
    };

    // --- the seven names the older scripts still call ----------------------
    // Carried at file scope by the module's main file. They are asserted here
    // because the cutover replaces that file, and one of them is read by the
    // observer behind a guard, so losing them is silent.
    private _lost = [];
    {
        if (isNil _x) then { _lost pushBack _x };
    } forEach ["ALiVE_fnc_catapultLaunch", "ALiVE_fnc_getAirportTaxiPos",
        "ALiVE_fnc_getNearestCatapult", "ALiVE_fnc_isVTOL", "ALiVE_fnc_isAntiAir",
        "ALiVE_fnc_DrawRunwayBlacklistMarkers", "ALiVE_fnc_CheckSpawnInMarkerArea"];
    ["the seven helper names the older scripts call are all defined",
        count _lost == 0] call _fnc_check;
    if (count _lost > 0) then {
        diag_log format ["  info  undefined: %1", _lost];
    };

    // --- the events the rest of the mod raises ------------------------------
    // The ground commander's request, in the five slot shape it has always
    // sent: [faction, side, type, airspace, duration]. It goes through the
    // event system rather than being handed to the kernel, because that is
    // the path that has to work.
    // The slots are [type, side, faction, airspace, arguments], the sender is
    // named separately, and the arguments are the eight the older scripts
    // still send. Taken verbatim from tests/test_ATO_RECCE.sqf so that what is
    // asserted here is the shape those scripts actually raise.
    private _raised = false;
    if (!isNil "ALIVE_fnc_event" && {!isNil "ALIVE_eventLog"}) then {
        private _args = ["WHITE", 800, "NORMAL", 0.5, 0.5, 2000, 25, []];
        private _ev = ["ATO_REQUEST", ["CAS", "WEST", "BLU_F", _zone, _args], "OPCOM"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _ev] call ALIVE_fnc_eventLog;
        _raised = true;
        sleep 14;
    };
    if (_raised) then {
        private _task = [[_logic, "kernel"] call ALIVE_fnc_ATO, "task", []] call ALIVE_fnc_hashGet;
        private _seen = false;
        if !(_task isEqualTo []) then {
            private _sorties = [_task, "sorties", []] call ALIVE_fnc_hashGet;
            if ([_sorties] call ALIVE_fnc_isHash) then { _seen = count (_sorties select 1) > 0 };
            diag_log format ["  info  sorties on the books after the request: %1",
                if ([_sorties] call ALIVE_fnc_isHash) then { count (_sorties select 1) } else { -1 }];
        };
        ["a request in the shape the ground commander has always sent is taken in",
            _seen] call _fnc_check;
    } else {
        "a request in the shape the ground commander has always sent is taken in" call _fnc_skip;
    };

    // Logistics answers in two shapes depending on which path raised it, and
    // neither may throw.
    private _threw = false;
    {
        private _r = [_logic, "LOGISTICS_COMPLETE", _x] call ALIVE_fnc_ATO;
        if (isNil "_r") then { _threw = true };
    } forEach [
        ["LOGISTICS_COMPLETE", [], "LOGCOM", 4242, "", [["no_such_entity", "no_such_vehicle"]]],
        ["LOGISTICS_COMPLETE", [], "LOGCOM", 4243, "", ["flat_id_shape"]]
    ];
    ["a delivery in either shape logistics sends is survived", !_threw] call _fnc_check;

    // A status request and a cancel for something that does not exist have to
    // be answered rather than thrown. Handed straight to the commander: the
    // response goes back out as its own event and whether anything is
    // listening for it is the event log's business, not this module's.
    private _threwAsk = false;
    {
        private _r = [_logic, _x select 0, _x select 1] call ALIVE_fnc_ATO;
        if (isNil "_r") then { _threwAsk = true };
    } forEach [
        ["ATO_STATUS_REQUEST", ["BLU_F", "WEST", "no_such_request", "1"]],
        ["ATO_CANCEL_REQUEST", ["BLU_F", "WEST", "no_such_request", "1", "no_such_request"]]
    ];
    ["a status request and a cancel for nothing are answered rather than thrown",
        !_threwAsk] call _fnc_check;

    // --- the pause the mission maker can press ------------------------------
    // Pressed through the shared module pause, which resolves the class off
    // the logic, so this also proves the class variable is the right one.
    private _k = [_logic, "kernel"] call ALIVE_fnc_ATO;
    ["the kernel offers itself for reading",
        [_k] call ALIVE_fnc_isHash] call _fnc_check;

    private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
    private _snap = [];
    if ([_rows] call ALIVE_fnc_isHash) then {
        {
            private _row = [_rows, _x, []] call ALIVE_fnc_hashGet;
            if ([_row] call ALIVE_fnc_isHash) then {
                _snap pushBack [_x, [_row, "state", ""] call ALIVE_fnc_hashGet, [_row, "enteredAt", 0] call ALIVE_fnc_hashGet];
            };
        } forEach (_rows select 1);
    };
    diag_log format ["  info  %1 aircraft on the roster at the pause", count _snap];

    // Pressed through the commander's own pause rather than through the shared
    // one. The shared one finds modules by their placed type and this test
    // builds a plain logic, so it would skip it and prove nothing; what makes
    // the shared one reach the right code is the class variable on the logic,
    // and that is asserted above.
    if (true) then {
        [_logic, "pause", true] call ALIVE_fnc_ATO;
        sleep 1;
        ["the commander reports itself paused",
            [_k, "paused", false] call ALIVE_fnc_hashGet] call _fnc_check;

        sleep 25;
        private _drifted = [];
        {
            _x params ["_tail", "_was", "_wasAt"];
            private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
            if ([_row] call ALIVE_fnc_isHash) then {
                if !(([_row, "enteredAt", 0] call ALIVE_fnc_hashGet) isEqualTo _wasAt) then {
                    _drifted pushBack _tail;
                };
            };
        } forEach _snap;
        ["nothing moves while it is paused", count _drifted == 0] call _fnc_check;

        if (true) then {
            [_logic, "pause", false] call ALIVE_fnc_ATO;
            sleep 1;
            ["and it reports itself running again",
                !([_k, "paused", true] call ALIVE_fnc_hashGet)] call _fnc_check;

            // The clocks were moved by the length of the pause, so the first
            // tick after it finds every deadline exactly where it was. If they
            // were not, twenty five seconds of deadlines all fall due at once.
            private _jumped = [];
            {
                _x params ["_tail", "_was", "_wasAt"];
                private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
                if ([_row] call ALIVE_fnc_isHash) then {
                    if !(([_row, "state", ""] call ALIVE_fnc_hashGet) isEqualTo _was) then {
                        _jumped pushBack [_tail, _was, [_row, "state", ""] call ALIVE_fnc_hashGet];
                    };
                };
            } forEach _snap;
            ["and nothing changed state on the first tick after it",
                count _jumped == 0] call _fnc_check;
            if (count _jumped > 0) then {
                diag_log format ["  info  moved across the pause: %1", _jumped];
            };

            // And the clocks were MOVED, which is what makes the line above
            // true for the right reason. Without the shift, every deadline
            // that fell due during the pause falls due at once on the first
            // tick after it.
            private _shifted = [];
            {
                _x params ["_tail", "_was", "_wasAt"];
                private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
                if ([_row] call ALIVE_fnc_isHash) then {
                    private _nowAt = [_row, "enteredAt", 0] call ALIVE_fnc_hashGet;
                    _shifted pushBack [_tail, round (_nowAt - _wasAt)];
                };
            } forEach _snap;
            diag_log format ["  info  clocks moved by: %1", _shifted];
            ["and every clock moved by the length of the pause",
                (count _snap == 0) || {(_shifted findIf { (_x select 1) < 20 }) == -1}] call _fnc_check;
        };
    };

    // --- the air picture ----------------------------------------------------
    // What anything outside this module reads to report the enemy half of the
    // air picture to a player. Read only: this answers the question and draws
    // nothing, which is what the design for that work asks of this module.
    private _pic = [_logic, "airPicture"] call ALIVE_fnc_ATO;
    diag_log format ["  info  the air picture: %1", _pic];
    ["the air picture can be asked for", [_pic] call ALIVE_fnc_isHash] call _fnc_check;
    ["and it says whose it is",
        ([_pic, "side", ""] call ALIVE_fnc_hashGet) isEqualTo ([_logic, "side"] call ALIVE_fnc_ATO)] call _fnc_check;
    ["and how many aircraft we have and how many are up",
        (([_pic, "ours", -1] call ALIVE_fnc_hashGet) >= 0)
        && {([_pic, "oursAirborne", -1] call ALIVE_fnc_hashGet) >= 0}
        && {([_pic, "oursAirborne", 99] call ALIVE_fnc_hashGet) <= ([_pic, "ours", 0] call ALIVE_fnc_hashGet)}] call _fnc_check;
    ["and how many of theirs are over our airspaces",
        ([_pic, "theirs", -1] call ALIVE_fnc_hashGet) >= 0] call _fnc_check;
    ["and reaches one of the four states it can be in",
        ([_pic, "state", ""] call ALIVE_fnc_hashGet) in ["superiority","inferiority","contested","quiet"]] call _fnc_check;
    // An empty sky is not a victory, which is the distinction that makes the
    // report worth reading rather than noise.
    if (([_pic, "theirs", 0] call ALIVE_fnc_hashGet) == 0 && {([_pic, "oursAirborne", 0] call ALIVE_fnc_hashGet) == 0}) then {
        ["with nothing of either side up it says quiet, not superiority",
            ([_pic, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "quiet"] call _fnc_check;
    } else {
        "with nothing of either side up it says quiet, not superiority" call _fnc_skip;
    };

    // --- two commanders of one faction --------------------------------------
    // Both persistent, neither named, same faction: their campaign stores must
    // not be filed under one key or each would write over the other.
    private _zone2 = "ato_contract_zone2";
    private _mk2 = createMarker [_zone2, _anchor getPos [2200, 90]];
    _mk2 setMarkerShape "ELLIPSE";
    _mk2 setMarkerSize [1200, 1200];
    _mk2 setMarkerAlpha 0;
    _markers pushBack _zone2;

    private _logicB = [_anchor getPos [2200, 90], [_zone2], "BLU_F", "true"] call _fnc_logic;
    [_logicB, "init"] call ALIVE_fnc_ATO;
    sleep 3;
    private _kB = [_logicB, "kernel"] call ALIVE_fnc_ATO;
    private _keyA = [_k, "instanceKey", ""] call ALIVE_fnc_hashGet;
    private _keyB = if ([_kB] call ALIVE_fnc_isHash) then { [_kB, "instanceKey", ""] call ALIVE_fnc_hashGet } else { "" };
    diag_log format ["  info  the two keys are '%1' and '%2'", _keyA, _keyB];
    ["two commanders of one faction get keys of their own",
        !(_keyA isEqualTo "") && {!(_keyB isEqualTo "")} && {!(_keyA isEqualTo _keyB)}] call _fnc_check;

    // And their runway locks are separate, or one would queue behind the other
    // on an airfield it is nowhere near.
    private _sA = [_k, "surface", []] call ALIVE_fnc_hashGet;
    private _sB = if ([_kB] call ALIVE_fnc_isHash) then { [_kB, "surface", []] call ALIVE_fnc_hashGet } else { [] };
    ["and pieces of their own, so neither can hold the other's runway",
        !(_sA isEqualTo []) && {!(_sB isEqualTo [])} && {!(_sA isEqualTo _sB)}] call _fnc_check;

    // --- stopping ------------------------------------------------------------
    // A commander has to be able to stop: the drivers are spawned and would
    // otherwise outlive the test and answer the next one's events.
    {
        private _r = [_x, "destroy"] call ALIVE_fnc_ATO;
        diag_log format ["  info  destroy answered %1", _r];
    } forEach _logics;
    sleep 3;
    ["a commander can be stopped, and afterwards has nothing left to read",
        ([_logic, "kernel"] call ALIVE_fnc_ATO) isEqualTo []] call _fnc_check;

    // A stopped commander still answers, with nothing in it.
    //
    // This is where the air picture checks used to sit, and they were asking a
    // commander that had just been stopped: it answered its empty shape with
    // default values, which is right, and proved nothing about the live one.
    // Kept as its own check, because answering an empty shape rather than
    // throwing is what lets anything outside this module read it without
    // having to know whether the commander is running.
    private _picOff = [_logic, "airPicture"] call ALIVE_fnc_ATO;
    ["a stopped commander still answers for the air picture, with nothing in it",
        ([_picOff] call ALIVE_fnc_isHash)
        && {([_picOff, "ours", -1] call ALIVE_fnc_hashGet) isEqualTo 0}
        && {([_picOff, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "unknown"}] call _fnc_check;

    // --- saving and loading -------------------------------------------------
    // The save button calls this and wants a pair back on every path,
    // whatever the answer is. Nothing here is persistent, so the answer is
    // "no", and the shape is what is being asserted.
    private _saveAnswer = [] call ALiVE_fnc_ATOSaveData;
    diag_log format ["  info  the save answered %1", _saveAnswer];
    ["the save answers a pair on every path, as the save button expects",
        _saveAnswer isEqualType [] && {count _saveAnswer == 2}
        && {(_saveAnswer select 0) isEqualType false} && {(_saveAnswer select 1) isEqualType []}] call _fnc_check;

    private _loadAnswer = [] call ALiVE_fnc_ATOLoadData;
    diag_log format ["  info  the load answered %1", if (_loadAnswer isEqualType []) then {"a store"} else {str _loadAnswer}];
    ["and the load answers a store or a plain no",
        (_loadAnswer isEqualType []) || {_loadAnswer isEqualType false}] call _fnc_check;

    // --- tidy up -------------------------------------------------------------
    { deleteMarker _x } forEach _markers;
    { if (!isNull _x) then { deleteVehicle _x } } forEach (_made + _logics);

    if (count _fails == 0) then {
        diag_log format ["=== ATO Contracts test: ALL PASS (%1 skipped) ===", count _skips];
    } else {
        diag_log format ["=== ATO Contracts test: %1 FAILED ===", count _fails];
        { diag_log format ["   failed: %1", _x] } forEach _fails;
    };
};
