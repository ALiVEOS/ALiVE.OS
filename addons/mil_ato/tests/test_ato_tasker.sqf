#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_tasker);

/* ----------------------------------------------------------------------------
Tasker test.

Smallest mission: none at all. This piece decides who flies what by reading
records and state rows it is handed, so the whole fleet below is fabricated and
nothing is spawned. That is the point of it being pure: a selection you cannot
replay is a selection you cannot test, and the old module's picks changed under
it mid-decision because it asked the world questions instead.

Five aircraft, chosen to make the interesting cases reachable:
  tail 1  attack helicopter, PARKED, near the target
  tail 2  attack helicopter, PARKED, far from the target
  tail 3  attack helicopter, PARKED but still in its turnaround
  tail 4  fighter, already up on a patrol
  tail 5  attack helicopter, flown by a player

Runs spawned to match the other tests, though nothing here needs a tick.
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _checked = 0;
    private _fnc_check = {
        params ["_name", ["_ok", nil, [true]]];
        _checked = _checked + 1;
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

    diag_log "=== ATO Tasker test ===";

    private _t = [nil, "create"] call ALIVE_fnc_ATOTask;

    // --- the fabricated fleet ------------------------------------------------
    private _now = 1000;
    private _target = [5000, 5000, 0];

    private _fnc_record = {
        params ["_class", "_homePos", ["_readyAt", 0]];
        [[["class", _class], ["home", [_homePos, 0, "terrain"]],
          ["faction", "BLU_F"], ["readyAt", _readyAt]]] call ALIVE_fnc_hashCreate
    };
    private _fnc_row = {
        params ["_state", ["_sortieType", ""]];
        [[["state", _state], ["sortieType", _sortieType]]] call ALIVE_fnc_hashCreate
    };
    private _fnc_obs = {
        params [["_fuel", 1], ["_ammo", 1], ["_damage", 0]];
        [[["fuel", _fuel], ["ordnance", _ammo], ["damage", _damage]]] call ALIVE_fnc_hashCreate
    };

    private _records = [] call ALIVE_fnc_hashCreate;
    private _rows    = [] call ALIVE_fnc_hashCreate;
    private _obs     = [] call ALIVE_fnc_hashCreate;

    // near, far, not-ready, the patrol, the player's
    [_records, "t1", ["B_Heli_Attack_01_F", [4900, 4900, 0]] call _fnc_record] call ALIVE_fnc_hashSet;
    [_records, "t2", ["B_Heli_Attack_01_F", [1000, 1000, 0]] call _fnc_record] call ALIVE_fnc_hashSet;
    [_records, "t3", ["B_Heli_Attack_01_F", [4950, 4950, 0], 99999] call _fnc_record] call ALIVE_fnc_hashSet;
    [_records, "t4", ["B_Plane_Fighter_01_F", [2000, 2000, 0]] call _fnc_record] call ALIVE_fnc_hashSet;
    [_records, "t5", ["B_Heli_Attack_01_F", [4910, 4910, 0]] call _fnc_record] call ALIVE_fnc_hashSet;

    [_rows, "t1", ["PARKED"] call _fnc_row] call ALIVE_fnc_hashSet;
    [_rows, "t2", ["PARKED"] call _fnc_row] call ALIVE_fnc_hashSet;
    [_rows, "t3", ["PARKED"] call _fnc_row] call ALIVE_fnc_hashSet;
    [_rows, "t4", ["ON_STATION", "CAP"] call _fnc_row] call ALIVE_fnc_hashSet;
    [_rows, "t5", ["PLAYER_FLOWN"] call _fnc_row] call ALIVE_fnc_hashSet;

    // Nearer to the target than anything else, parked, out of its turnaround,
    // and nearly dry. It exists so the fuel minimum is tested against an
    // aircraft that would otherwise win, rather than against a threshold no
    // aircraft could meet, which is what the first version of this test did and
    // why it proved nothing.
    [_records, "t6", ["B_Heli_Attack_01_F", [4995, 4995, 0]] call _fnc_record] call ALIVE_fnc_hashSet;
    [_rows, "t6", ["PARKED"] call _fnc_row] call ALIVE_fnc_hashSet;

    { [_obs, _x, [] call _fnc_obs] call ALIVE_fnc_hashSet } forEach ["t1","t2","t3","t4","t5"];
    [_obs, "t6", [0.1] call _fnc_obs] call ALIVE_fnc_hashSet;

    private _fnc_request = {
        params ["_type", ["_zone", "AS1"], ["_minFuel", 0.5]];
        [[["id", format ["r_%1", _type]], ["type", _type], ["faction", "BLU_F"],
          ["airspace", _zone], ["targetPos", [5000,5000,0]],
          ["minFuel", _minFuel], ["receivedAt", 1000], ["duration", 900]]] call ALIVE_fnc_hashCreate
    };

    // --- selection -----------------------------------------------------------
    private _plan = [_t, "plan", [["CAS"] call _fnc_request, _records, _rows, _obs, []]] call ALIVE_fnc_ATOTask;
    ["a close air support sortie is planned", (_plan param [0, []]) isEqualType []] call _fnc_check;
    private _tails = _plan param [0, []];
    ["and it takes the nearest aircraft that is ready",
        (_tails param [0, ""]) isEqualTo "t1"] call _fnc_check;
    ["and never one a player is flying", !("t5" in _tails)] call _fnc_check;
    ["and never one still in its turnaround", !("t3" in _tails)] call _fnc_check;

    // A patrol can be turned onto something more urgent, but it costs the
    // patrol, so it should rank behind a parked aircraft for ground work.
    ["a parked aircraft is preferred to breaking off a patrol",
        !((_tails param [0, ""]) isEqualTo "t4")] call _fnc_check;

    // Role fit is a filter, so everything below it depends on roles being
    // readable at all. Probe that rather than letting the assertions fail
    // confusingly in an environment where they are not, and say out loud when
    // they are skipped: a skipped check that reads as a pass is worse than a
    // failure.
    private _rolesWork = false;
    if (!isNil "ALiVE_fnc_getAircraftRoles") then {
        private _r = ["B_Plane_Fighter_01_F"] call ALiVE_fnc_getAircraftRoles;
        _rolesWork = _r isEqualType [] && {"Fighter" in _r};
    };
    diag_log format ["  info  aircraft roles resolve: %1", _rolesWork];

    private _dca = [_t, "plan", [["DCA"] call _fnc_request, _records, _rows, _obs, []]] call ALIVE_fnc_ATOTask;
    private _dcaTails = _dca param [0, []];
    ["and sends one aircraft, not a pair", count _dcaTails == 1] call _fnc_check;
    if (_rolesWork) then {
        ["an interception takes the fighter and not a nearer helicopter",
            (_dcaTails param [0, ""]) isEqualTo "t4"] call _fnc_check;
    } else {
        diag_log "  SKIP  an interception takes the fighter (roles do not resolve here)";
    };

    // Two aircraft against a defended site, where two exist.
    private _sead = [_t, "plan", [["SEAD"] call _fnc_request, _records, _rows, _obs, []]] call ALIVE_fnc_ATOTask;
    ["a suppression sortie goes as a pair", count (_sead param [0, []]) == 2] call _fnc_check;

    // The nearly dry aircraft is nearer than anything else, so the only reason
    // it can lose is the fuel minimum.
    ["an aircraft too low on fuel is passed over even though it is the nearest",
        !("t6" in _tails)] call _fnc_check;

    // And with a minimum no aircraft on the field can meet, the whole fleet is
    // filtered and the request is refused rather than answered with nothing.
    private _thirsty = [_t, "plan", [["CAS", "AS1", 1.01] call _fnc_request, _records, _rows, _obs, []]] call ALIVE_fnc_ATOTask;
    ["a minimum no aircraft can meet is refused, with a reason",
        (_thirsty param [0, ""]) isEqualTo "denied" && {!((_thirsty param [1, ""]) isEqualTo "")}] call _fnc_check;

    // Exclusions are how a retry reaches a different aircraft.
    private _excl = [_t, "plan", [["CAS"] call _fnc_request, _records, _rows, _obs, ["t1"]]] call ALIVE_fnc_ATOTask;
    ["excluding the first choice moves to the next one",
        ((_excl param [0, []]) param [0, ""]) isEqualTo "t2"] call _fnc_check;

    // --- the orders table ----------------------------------------------------
    private _states = ["PARKED","ASSIGNED","LAUNCHING","ENROUTE","ON_STATION","RTB","LANDING","RECOVERING","PLAYER_FLOWN","LOST"];
    private _types  = ["CAP","DCA","SEAD","CAS","Strike","Recce","OCA","FERRY"];
    private _airborne = ["LAUNCHING","ENROUTE","ON_STATION","RTB","LANDING"];
    private _holes = [];
    private _cells = 0;
    {
        private _type = _x;
        {
            _cells = _cells + 1;
            private _o = [_t, "ordersFor", [_type, _x]] call ALIVE_fnc_ATOTask;
            if (!(_o isEqualType [])) then { _holes pushBack format ["%1/%2 not an array", _type, _x] };
            if (_x in _airborne && {count _o == 0}) then { _holes pushBack format ["%1/%2 empty", _type, _x] };
        } forEach _states;
    } forEach _types;
    [format ["every one of the %1 type and state pairs answers", _cells], count _holes == 0] call _fnc_check;
    if (count _holes > 0) then { diag_log format ["  info  holes: %1", _holes] };

    ["a stationary state is told to stay put",
        ([_t, "ordersFor", ["CAS","RECOVERING"]] call ALIVE_fnc_ATOTask) isEqualTo ["HOLD"]] call _fnc_check;
    ["a parked aircraft is given nothing",
        ([_t, "ordersFor", ["CAS","PARKED"]] call ALIVE_fnc_ATOTask) isEqualTo []] call _fnc_check;
    ["an aircraft a player is flying is given nothing",
        ([_t, "ordersFor", ["CAS","PLAYER_FLOWN"]] call ALIVE_fnc_ATOTask) isEqualTo []] call _fnc_check;

    // The wait table had a malformed default that never matched.
    ["an unrecognised type gets the real default wait, not the initialiser",
        ([_t, "waitFor", "OCA"] call ALIVE_fnc_ATOTask) == 60] call _fnc_check;
    ["and a type with its own wait keeps it",
        ([_t, "waitFor", "CAS"] call ALIVE_fnc_ATOTask) == 10] call _fnc_check;

    // --- admission -----------------------------------------------------------
    private _t2 = [nil, "create"] call ALIVE_fnc_ATOTask;

    // Before placement has looked, a request waits rather than being refused.
    private _early = [_t2, "submit", ["CAS"] call _fnc_request] call ALIVE_fnc_ATOTask;
    ["a request that arrives before the first placement pass is held",
        _early isEqualType ""] call _fnc_check;
    private _earlyState = [_t2, "status", "r_CAS"] call ALIVE_fnc_ATOTask;
    ["and held means queued, not denied",
        (_earlyState param [1, ""]) isEqualTo "queued"] call _fnc_check;

    [_t2, "firstPassDone"] call ALIVE_fnc_ATOTask;

    ["an unsupported type is refused",
        (([_t2, "submit", ["Bombardment"] call _fnc_request] call ALIVE_fnc_ATOTask) param [0, ""]) isEqualTo "denied"] call _fnc_check;

    // Not enough aircraft for an operation, but a patrol is still allowed.
    private _t3 = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t3, "firstPassDone"] call ALIVE_fnc_ATOTask;
    [_t3, "assetCount", 2] call ALIVE_fnc_ATOTask;
    [_t3, "minAssetsForOffensive", 4] call ALIVE_fnc_hashSet;
    ["a thin fleet refuses an operation",
        (([_t3, "submit", ["Strike"] call _fnc_request] call ALIVE_fnc_ATOTask) param [0, ""]) isEqualTo "denied"] call _fnc_check;
    ["but still flies a patrol",
        ([_t3, "submit", ["CAP"] call _fnc_request] call ALIVE_fnc_ATOTask) isEqualType ""] call _fnc_check;

    // The cap counts operations, never patrols.
    private _t4 = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t4, "firstPassDone"] call ALIVE_fnc_ATOTask;
    [_t4, "maxConcurrentSorties", 1] call ALIVE_fnc_hashSet;
    private _first = [_t4, "submit", ["CAS"] call _fnc_request] call ALIVE_fnc_ATOTask;
    ["the first operation is admitted", _first isEqualType ""] call _fnc_check;
    private _second = [_t4, "submit", ["Strike"] call _fnc_request] call ALIVE_fnc_ATOTask;
    ["the second is refused at the cap, with the reason",
        (_second param [0, ""]) isEqualTo "denied" && {(_second param [1, ""]) isEqualTo "sortie cap reached"}] call _fnc_check;
    ["and the cap does not stop a patrol",
        ([_t4, "submit", ["CAP"] call _fnc_request] call ALIVE_fnc_ATOTask) isEqualType ""] call _fnc_check;

    // No airbase to fly from.
    private _t5 = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t5, "firstPassDone"] call ALIVE_fnc_ATOTask;
    [_t5, "baseFailed", [true, "no runway on this terrain"]] call ALIVE_fnc_ATOTask;
    private _noBase = [_t5, "submit", ["CAS"] call _fnc_request] call ALIVE_fnc_ATOTask;
    ["with no airbase every request is refused and says why",
        (_noBase param [0, ""]) isEqualTo "denied"
        && {(_noBase param [1, ""]) isEqualTo "no runway on this terrain"}] call _fnc_check;

    // --- a dispatch that fails ----------------------------------------------
    private _t6 = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t6, "firstPassDone"] call ALIVE_fnc_ATOTask;
    private _sid = [_t6, "submit", ["CAS"] call _fnc_request] call ALIVE_fnc_ATOTask;
    private _after1 = [_t6, "onRowEvent", [_sid, "t1", "assignFailed", 1010]] call ALIVE_fnc_ATOTask;
    ["an aircraft that refuses the job sends the sortie back to planning",
        _after1 isEqualTo "planning"] call _fnc_check;
    [_t6, "onRowEvent", [_sid, "t2", "assignFailed", 1020]] call ALIVE_fnc_ATOTask;
    private _after3 = [_t6, "onRowEvent", [_sid, "t4", "assignFailed", 1030]] call ALIVE_fnc_ATOTask;
    ["three different aircraft refusing it denies the sortie",
        _after3 isEqualTo "denied"] call _fnc_check;

    // Every failure excludes the tail that failed, so a retry cannot loop on
    // the same aircraft.
    private _sorties = [_t6, "sorties", []] call ALIVE_fnc_hashGet;
    private _rec = [_sorties, _sid, []] call ALIVE_fnc_hashGet;
    private _excluded = [_rec, "excluded", []] call ALIVE_fnc_hashGet;
    ["and each refusal rules that aircraft out of the next attempt",
        count _excluded == 3] call _fnc_check;

    // --- a pair that loses one aircraft -------------------------------------
    // A suppression sortie flies as a pair. One of them failing to launch used
    // to clear both and send the sortie back to be planned while the other was
    // still flying it, and the first one home closed it under the other.
    private _fnc_pair = {
        private _tp = [nil, "create"] call ALIVE_fnc_ATOTask;
        [_tp, "firstPassDone"] call ALIVE_fnc_ATOTask;
        private _id = [_tp, "submit", ["SEAD"] call _fnc_request] call ALIVE_fnc_ATOTask;
        [_tp, "dispatch", [_id, ["p1","p2"]]] call ALIVE_fnc_ATOTask;
        [_tp, _id]
    };
    private _fnc_field = {
        params ["_tp", "_id", "_key", "_default"];
        private _rec = [_tp, "sortie", _id] call ALIVE_fnc_ATOTask;
        if ([_rec] call ALIVE_fnc_isHash) then { [_rec, _key, _default] call ALIVE_fnc_hashGet } else { _default }
    };

    (call _fnc_pair) params ["_pa", "_paId"];
    private _pa1 = [_pa, "onRowEvent", [_paId, "p2", "assignFailed", 1010]] call ALIVE_fnc_ATOTask;
    ["one of a pair failing to launch leaves the sortie with the other",
        _pa1 isEqualTo "assigned" && {([_pa, _paId, "tails", []] call _fnc_field) isEqualTo ["p1"]}
        && {"p2" in ([_pa, _paId, "excluded", []] call _fnc_field)} && {([_pa, _paId, "attempts", 0] call _fnc_field) == 0}] call _fnc_check;
    private _pa2 = [_pa, "onRowEvent", [_paId, "p1", "assignFailed", 1020]] call ALIVE_fnc_ATOTask;
    ["and only the second failure hands it back to be planned, as one attempt",
        _pa2 isEqualTo "planning" && {([_pa, _paId, "tails", ["x"]] call _fnc_field) isEqualTo []}
        && {([_pa, _paId, "attempts", 0] call _fnc_field) == 1}] call _fnc_check;

    (call _fnc_pair) params ["_pb", "_pbId"];
    [_pb, "onRowEvent", [_pbId, "", "sortieArrived", 1010]] call ALIVE_fnc_ATOTask;
    private _pb1 = [_pb, "onRowEvent", [_pbId, "p1", "tailLanded", 1020]] call ALIVE_fnc_ATOTask;
    ["the first of a pair home does not close the sortie under the other",
        _pb1 isEqualTo "onStation" && {([_pb, _pbId, "tails", []] call _fnc_field) isEqualTo ["p2"]}] call _fnc_check;
    private _pb2 = [_pb, "onRowEvent", [_pbId, "p2", "tailLanded", 1030]] call ALIVE_fnc_ATOTask;
    ["the last one home does",
        _pb2 isEqualTo "complete" && {([_pb, _pbId, "reason", ""] call _fnc_field) isEqualTo "landed"}] call _fnc_check;

    (call _fnc_pair) params ["_pc", "_pcId"];
    [_pc, "onRowEvent", [_pcId, "", "sortieArrived", 1010]] call ALIVE_fnc_ATOTask;
    [_pc, "onRowEvent", [_pcId, "p1", "tailLanded", 1020]] call ALIVE_fnc_ATOTask;
    private _pc2 = [_pc, "onRowEvent", [_pcId, "p2", "assignFailed", 1300]] call ALIVE_fnc_ATOTask;
    ["one that fails to launch after its wingman flew the job and came home closes it, not a new pair",
        _pc2 isEqualTo "complete" && {([_pc, _pcId, "reason", ""] call _fnc_field) isEqualTo "landed"}
        && {([_pc, _pcId, "attempts", 0] call _fnc_field) == 0} && {([_pc, _pcId, "landedBy", ""] call _fnc_field) isEqualTo "p1"}] call _fnc_check;

    (call _fnc_pair) params ["_pd", "_pdId"];
    [_pd, "onRowEvent", [_pdId, "", "sortieArrived", 1010]] call ALIVE_fnc_ATOTask;
    [_pd, "onRowEvent", [_pdId, "p1", "onLost", 1020]] call ALIVE_fnc_ATOTask;
    private _pd2 = [_pd, "onRowEvent", [_pdId, "p2", "assignFailed", 1300]] call ALIVE_fnc_ATOTask;
    ["but after its wingman was lost on the job, it is planned again",
        _pd2 isEqualTo "planning"] call _fnc_check;

    (call _fnc_pair) params ["_pe", "_peId"];
    [_pe, "onRowEvent", [_peId, "", "sortieArrived", 1010]] call ALIVE_fnc_ATOTask;
    private _pe1 = [_pe, "onRowEvent", [_peId, "p1", "tailRetired", 1020]] call ALIVE_fnc_ATOTask;
    private _pe2 = [_pe, "onRowEvent", [_peId, "p2", "tailRetired", 1030]] call ALIVE_fnc_ATOTask;
    ["retiring one of a pair leaves the sortie with the other, and retiring both closes it",
        _pe1 isEqualTo "onStation" && {_pe2 isEqualTo "complete"} && {([_pe, _peId, "reason", ""] call _fnc_field) isEqualTo "retired"}] call _fnc_check;

    // --- an airspace that is already covered --------------------------------
    private _t7 = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t7, "firstPassDone"] call ALIVE_fnc_ATOTask;
    private _dcaId = [_t7, "scrambleDCA", ["AS1", [[4000,4000,0]], 1000]] call ALIVE_fnc_ATOTask;
    ["an interception is raised over an empty airspace", _dcaId isEqualType ""] call _fnc_check;
    ["and the airspace then reports it active",
        count ([_t7, "activeInZone", ["AS1", ["DCA"]]] call ALIVE_fnc_ATOTask) == 1] call _fnc_check;
    private _again = [_t7, "scrambleDCA", ["AS1", [[4000,4000,0]], 1005]] call ALIVE_fnc_ATOTask;
    ["a second interception over the same airspace is refused",
        (_again param [0, ""]) isEqualTo "denied"] call _fnc_check;
    ["but a patrol over it is a different kind of sortie and is allowed",
        ([_t7, "scheduleCAP", ["AS1", [], 1006]] call ALIVE_fnc_ATOTask) isEqualType ""] call _fnc_check;
    ["and an airspace nobody is over reports nothing active",
        ([_t7, "activeInZone", ["AS2", []]] call ALIVE_fnc_ATOTask) isEqualTo []] call _fnc_check;

    // --- handing work to players --------------------------------------------
    // These raise C2ISTAR tasks, and every gate is a refusal with a reason
    // rather than a silent no-op, so what follows checks the reasons.
    //
    // The positive paths cannot run here and are skipped by name. Raising a
    // task needs somebody on the side to raise it TO, and this test has no
    // mission and no players; the last gate before the raise is exactly that
    // list, so on a dedicated server every one of them stops there. What IS
    // reachable is every gate in front of it, which is where the logic lives.
    private _tp = [nil, "create"] call ALIVE_fnc_ATOTask;

    // Off by default, deliberately: a mission should be able to run air support
    // without generating anybody a task.
    ["task generation is off until it is asked for",
        ([_tp, "csar", ["t1", "B_Heli_Attack_01_F", [100,100,0]]] call ALIVE_fnc_ATOTask)
            isEqualTo ["denied", "task generation off"]] call _fnc_check;
    ["and a player task is refused for the same reason",
        ([_tp, "playerTask", ["SEAD", ["someProfileId"]]] call ALIVE_fnc_ATOTask)
            isEqualTo ["denied", "task generation off"]] call _fnc_check;

    [_tp, "configure", [["generateTasks", true], ["side", "WEST"], ["faction", "BLU_F"]]] call ALIVE_fnc_ATOTask;
    ["settings can be pushed in as pairs",
        ([_tp, "generateTasks", false] call ALIVE_fnc_hashGet)
        && {([_tp, "faction", ""] call ALIVE_fnc_hashGet) isEqualTo "BLU_F"}] call _fnc_check;

    // A rescue with no rescuers is not a rescue. C2ISTAR owns the task system,
    // so without it there is nowhere for one to go, and this is re-asked on
    // every call because a mission can load it late.
    private _csarNoC2 = [_tp, "csar", ["t1", "B_Heli_Attack_01_F", [100,100,0]]] call ALIVE_fnc_ATOTask;
    ["a rescue is refused when there is no task system to carry it",
        (_csarNoC2 param [1, ""]) in ["no c2istar", "nobody on the side is taking orders"]] call _fnc_check;
    diag_log format ["  info  rescue without c2istar refused: %1", _csarNoC2];

    ["a rescue with no position is refused rather than pointing at nowhere",
        (([_tp, "csar", ["t1", "B_Heli_Attack_01_F", []]] call ALIVE_fnc_ATOTask) param [1, ""])
            in ["no position", "no c2istar"]] call _fnc_check;

    ["a player task with no type is refused",
        ([_tp, "playerTask", ["", ["x"]]] call ALIVE_fnc_ATOTask)
            isEqualTo ["denied", "no type"]] call _fnc_check;

    // The primary target is the module's own business; players are offered the
    // rest. One target and a type that hands over its leftovers means there is
    // nothing left to hand over.
    ["a CAS task with only the primary target leaves players nothing",
        ([_tp, "playerTask", ["CAS", ["theOneTheModuleIsTaking"]]] call ALIVE_fnc_ATOTask)
            isEqualTo ["denied", "no target left for players"]] call _fnc_check;

    // SEAD, DefendHQ and Laze are the three where nothing of ours is going
    // after the target, so the primary is kept and the request gets as far as
    // resolving where the target is.
    private _seadOne = [_tp, "playerTask", ["SEAD", ["anUnknownProfileId"]]] call ALIVE_fnc_ATOTask;
    ["a SEAD task keeps its primary target and gets past the hand-over rule",
        !((_seadOne param [1, ""]) isEqualTo "no target left for players")] call _fnc_check;
    diag_log format ["  info  SEAD with one target answered: %1", _seadOne];

    ["an unresolvable target is refused rather than becoming a task pointing at nothing",
        (_seadOne param [1, ""]) in ["target has no position", "nobody on the side is taking orders"]] call _fnc_check;

    diag_log "  skip  a raised task carries the 13-field payload  (needs a player on the side to raise it to)";
    diag_log "  skip  the same target is never offered twice  (the registry is only written on a successful raise)";

    // --- moving an airframe for its own sake --------------------------------
    private _tf = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_tf, "configure", [["side", "WEST"], ["faction", "BLU_F"], ["factions", ["BLU_F"]]]] call ALIVE_fnc_ATOTask;
    [_tf, "firstPassDone"] call ALIVE_fnc_ATOTask;

    ["a ferry with no airframe named is refused",
        ([_tf, "openFerry", []] call ALIVE_fnc_ATOTask) isEqualTo ["denied", "no tail"]] call _fnc_check;

    private _ferry = [_tf, "openFerry", ["t2", [200,200,0]]] call ALIVE_fnc_ATOTask;
    ["a ferry is accepted as a sortie", _ferry isEqualType ""] call _fnc_check;
    diag_log format ["  info  ferry answered: %1", _ferry];

    // A ferry is the module moving its own aircraft, not an operation against
    // anything, so it must not eat the sortie cap that limits real missions.
    private _tc = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_tc, "configure", [["side", "WEST"], ["faction", "BLU_F"], ["maxConcurrentSorties", 1]]] call ALIVE_fnc_ATOTask;
    [_tc, "firstPassDone"] call ALIVE_fnc_ATOTask;
    [_tc, "openFerry", ["t2", [200,200,0]]] call ALIVE_fnc_ATOTask;
    private _afterFerry = [_tc, "submit", [[
        ["id", "r_cap"], ["type", "CAS"], ["faction", "BLU_F"],
        ["targetPos", [500,500,0]], ["receivedAt", 2000]
    ]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_ATOTask;
    ["a ferry does not use up the sortie cap",
        !((_afterFerry param [0, ""]) isEqualTo "denied")
        || {!((_afterFerry param [1, ""]) isEqualTo "sortie cap reached")}] call _fnc_check;
    diag_log format ["  info  an operation after a ferry answered: %1", _afterFerry];

    // The planner is told to bring ONE named hull home, so the nearest
    // available aircraft is not a better answer, it is the wrong answer.
    private _ferryReq = [[
        ["id", "r_ferry"], ["type", "FERRY"], ["faction", "BLU_F"],
        ["targetPos", _target], ["receivedAt", _now], ["onlyTail", "t2"]
    ]] call ALIVE_fnc_hashCreate;
    private _ferryPlan = [_t, "plan", [_ferryReq, _records, _rows, _obs, []]] call ALIVE_fnc_ATOTask;
    ["a ferry plans onto the airframe it names and no other",
        (_ferryPlan param [0, []]) isEqualTo ["t2"]] call _fnc_check;
    diag_log format ["  info  ferry plan: %1", _ferryPlan];

    // And naming one that cannot fly is refused outright rather than quietly
    // substituting another. A ferry for a hull a player has taken is not a
    // ferry for the next aircraft along.
    private _ferryBadReq = [[
        ["id", "r_ferry2"], ["type", "FERRY"], ["faction", "BLU_F"],
        ["targetPos", _target], ["receivedAt", _now], ["onlyTail", "t5"]
    ]] call ALIVE_fnc_hashCreate;
    private _ferryBadPlan = [_t, "plan", [_ferryBadReq, _records, _rows, _obs, []]] call ALIVE_fnc_ATOTask;
    diag_log format ["  info  ferry plan naming a player-flown airframe: %1", _ferryBadPlan];
    ["naming an airframe a player is flying is refused, not substituted",
        _ferryBadPlan isEqualTo ["denied", "no candidate airframe"]] call _fnc_check;

    diag_log format ["  info  %1 assertions", _checked];
    if (count _fails == 0) then {
        diag_log "=== ATO Tasker test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Tasker test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Tasker test started, results follow in the log"
