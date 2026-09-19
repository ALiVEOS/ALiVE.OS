#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_effect);

/* ----------------------------------------------------------------------------
Effector test.

Smallest mission: a player standing anywhere with clear ground in front, no
ALiVE modules, no aircraft. The test creates the hulls it needs and removes
them afterwards.

The point of this piece is that it can be told to do the same thing twice and
the world does not move the second time, and that it refuses out loud when it
must not act at all. So most of what follows is: apply, apply again, and check
nothing changed and it said so.
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

    // Some checks here need a real player to sit in the aircraft, and a
    // dedicated server has none. Those are skipped rather than failed, and the
    // skip is printed and counted so the run says what it did not cover.
    private _skipped = [];
    private _fnc_skip = {
        _skipped pushBack _this;
        diag_log format ["  skip  %1  (needs a player at a keyboard)", _this];
    };

    diag_log "=== ATO Effector test ===";

    private _e = [nil, "create"] call ALIVE_fnc_ATOEffect;
    private _s = [nil, "create"] call ALIVE_fnc_ATOSurface;

    // Anchored on the player when there is one and on the Agia Marina strip
    // when there is not, so this runs on the headless rig as well as in front
    // of somebody. A dedicated server has no player at all.
    private _from = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _bearing = if (isNull player) then {0} else {getDir player};
    private _spot = _from getPos [45, _bearing];
    private _home = [[_spot select 0, _spot select 1, 0], 0, "terrain"];
    private _veh = createVehicle ["B_Heli_Transport_01_F", _spot, [], 0, "CAN_COLLIDE"];
    _veh setPosATL [_spot select 0, _spot select 1, 0];
    sleep 2;

    private _fnc_apply = {
        params ["_effect", ["_extra", []]];
        [_e, "apply", [_effect, _veh, _home, _extra]] call ALIVE_fnc_ATOEffect
    };

    // --- the engine, twice ---------------------------------------------------
    (["engineOn"] call _fnc_apply) params ["_st1", "_m1", "_d1"];
    ["the engine starts", _st1 isEqualTo "ok" && {!_m1}] call _fnc_check;
    (["engineOn"] call _fnc_apply) params ["_st2", "_m2", "_d2"];
    ["starting it again changes nothing and says so", _st2 isEqualTo "ok" && {_m2}] call _fnc_check;

    (["engineOff"] call _fnc_apply) params ["_st3", "_m3"];
    ["the engine stops", _st3 isEqualTo "ok" && {!_m3}] call _fnc_check;
    (["engineOff"] call _fnc_apply) params ["_st4", "_m4"];
    ["stopping it again changes nothing and says so", _st4 isEqualTo "ok" && {_m4}] call _fnc_check;

    // --- crew ----------------------------------------------------------------
    (["mintCrew"] call _fnc_apply) params ["_st5", "_m5", "_d5"];
    sleep 1;
    ["a crew is created", _st5 isEqualTo "ok" && {!_m5} && {count (crew _veh) > 0}] call _fnc_check;
    private _crewCount = count (crew _veh);
    (["mintCrew"] call _fnc_apply) params ["_st6", "_m6"];
    ["asking again does not create a second crew",
        _m6 && {count (crew _veh) == _crewCount}] call _fnc_check;

    // --- orders --------------------------------------------------------------
    // On the ground, so a chain without a hold is allowed.
    private _chain = [["MOVE", _spot getPos [300, 0]], ["LOITER", _spot getPos [400, 0]]];
    (["issueOrders", [_chain]] call _fnc_apply) params ["_st7", "_m7", "_d7"];
    ["orders are issued", _st7 isEqualTo "ok" && {!_m7}] call _fnc_check;
    (["issueOrders", [_chain]] call _fnc_apply) params ["_st8", "_m8"];
    ["issuing the same orders again leaves them alone", _st8 isEqualTo "ok" && {_m8}] call _fnc_check;

    (["issueOrders", [[]]] call _fnc_apply) params ["_st9", "_m9", "_d9"];
    ["an empty order list is refused", _st9 isEqualTo "refused"] call _fnc_check;

    (["clearOrders"] call _fnc_apply) params ["_st10", "_m10"];
    ["orders are cleared", _st10 isEqualTo "ok"] call _fnc_check;
    (["clearOrders"] call _fnc_apply) params ["_st11", "_m11"];
    ["clearing again changes nothing and says so", _m11] call _fnc_check;

    // --- an order chain that runs out, in the air ----------------------------
    // This is the one that killed an aircraft: orders that simply end.
    private _flyer = createVehicle ["B_Heli_Transport_01_F", _spot getPos [200, 90], [], 0, "FLY"];
    _flyer setPosATL [(getPosATL _flyer) select 0, (getPosATL _flyer) select 1, 200];
    createVehicleCrew _flyer;
    sleep 2;
    private _bad = [["MOVE", _spot getPos [500, 0]]];
    private _r = [_e, "apply", ["issueOrders", _flyer, _home, [_bad]]] call ALIVE_fnc_ATOEffect;
    _r params ["_st12", "_m12", "_d12"];
    ["orders that run out are refused for an aircraft in the air",
        _st12 isEqualTo "refused" && {_d12 isEqualTo "no terminal hold"}] call _fnc_check;

    private _good = [["MOVE", _spot getPos [500, 0]], ["LOITER", _spot getPos [600, 0]]];
    (([_e, "apply", ["issueOrders", _flyer, _home, [_good]]] call ALIVE_fnc_ATOEffect)) params ["_st13"];
    ["the same orders ending in a hold are accepted", _st13 isEqualTo "ok"] call _fnc_check;

    // --- nothing takes the crew or the engine of an aircraft in the air ---------
    // Whoever asks. A gunship that lifted off while it waited for the runway was
    // parked at 199 m, and parking took its crew and stopped its engine there.
    { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (crew _flyer);
    diag_log format ["  info  the flyer is %1 m up with %2 aboard, engine %3",
        round ((getPosATL _flyer) select 2), count (crew _flyer), isEngineOn _flyer];
    (([_e, "apply", ["standDownCrew", _flyer, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_stA1", "_mA1", "_dA1"];
    ["an aircraft in the air keeps its crew",
        _stA1 isEqualTo "refused" && {_dA1 isEqualTo "in the air"} && {({alive _x} count (crew _flyer)) > 0}] call _fnc_check;
    (([_e, "apply", ["engineOff", _flyer, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_stA2", "_mA2", "_dA2"];
    ["and keeps its engine",
        _stA2 isEqualTo "refused" && {_dA2 isEqualTo "in the air"} && {isEngineOn _flyer}] call _fnc_check;
    (([_e, "apply", ["holdOnStand", _flyer, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_stA3", "_mA3", "_dA3"];
    ["and its fuel",
        _stA3 isEqualTo "refused" && {_dA3 isEqualTo "in the air"} && {(fuel _flyer) > 0}] call _fnc_check;

    { deleteVehicle _x } forEach (crew _flyer);
    deleteVehicle _flyer;

    // --- refusals with a player aboard ---------------------------------------
    // Nothing may move the aircraft, and nothing may take its crew, while
    // somebody is sitting in it.
    if (isNull player) then {
        {
            format ["%1 is refused with a player aboard", _x] call _fnc_skip;
        } forEach ["placeOnSlot", "forceLanded", "airborneStart", "forceLaunch", "taxiOut", "standDownCrew"];
    } else {
        player moveInCargo _veh;
        sleep 2;
        {
            private _eff = _x;
            (([_e, "apply", [_eff, _veh, _home, [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stx", "_mx", "_dx"];
            [format ["%1 is refused with a player aboard", _eff],
                _stx isEqualTo "refused" && {_dx isEqualTo "player aboard"}] call _fnc_check;
        } forEach ["placeOnSlot", "forceLanded", "airborneStart", "forceLaunch", "taxiOut", "standDownCrew"];
        moveOut player;
        sleep 1;
    };

    // --- putting it on its slot ----------------------------------------------
    _veh setPosATL [(_spot select 0) + 60, (_spot select 1) + 60, 0];
    sleep 1;
    (["placeOnSlot", [_s]] call _fnc_apply) params ["_st14", "_m14", "_d14"];
    sleep 1;
    ["an aircraft away from its stand is put back", _st14 isEqualTo "ok" && {!_m14}] call _fnc_check;
    (["placeOnSlot", [_s]] call _fnc_apply) params ["_st15", "_m15"];
    ["asking again while it is already there changes nothing", _m15] call _fnc_check;

    // --- protection -----------------------------------------------------------
    _veh setVariable ["profileID", "LEFTOVER_STAMP", true];
    (["shield", ["BLU_F_0"]] call _fnc_apply) params ["_st16", "_m16"];
    ["shielding clears a leftover stamp",
        _st16 isEqualTo "ok" && {(_veh getVariable ["profileID", ""]) isEqualTo ""}] call _fnc_check;
    ["and marks the aircraft as ours",
        (_veh getVariable ["ALiVE_mil_ato_tail", ""]) isEqualTo "BLU_F_0"] call _fnc_check;
    (["shield", ["BLU_F_0"]] call _fnc_apply) params ["_st17", "_m17"];
    ["shielding again changes nothing and says so", _m17] call _fnc_check;

    // --- who counts as watching -------------------------------------------------
    // Bodies, and Zeus cameras through the curator logics main's Zeus loop moves
    // to them. A Zeus module nobody is assigned to stays where it was placed, so
    // it must not count, or an airfield with one on it would be watched forever.
    private _bodiesHere = count ((allPlayers - (entities "HeadlessClient_F")) select { alive _x && {(_x distance2D _spot) < 300} });
    ["the watcher count agrees with the players standing near",
        ([nil, "playersNear", [_spot, 300]] call ALIVE_fnc_ATOObserve) == _bodiesHere] call _fnc_check;
    private _curGroup = createGroup sideLogic;
    private _curator = _curGroup createUnit ["ModuleCurator_F", _spot, [], 0, "NONE"];
    sleep 1;
    diag_log format ["  info  an unowned Zeus module placed at the spot: in allCurators %1, owner %2",
        _curator in allCurators, getAssignedCuratorUnit _curator];
    ["a Zeus module nobody is assigned to is not a watcher",
        (_curator in allCurators) && {([nil, "playersNear", [_spot, 300]] call ALIVE_fnc_ATOObserve) == _bodiesHere}] call _fnc_check;
    deleteVehicle _curator;
    deleteGroup _curGroup;

    // --- standing the crew down ------------------------------------------------
    // Deleted from the aircraft, with the tester in view when there is one: a
    // crew let out to walk off was ordered back in and flew, and the timer that
    // came back for them deleted a pilot in the air. Their empty group goes too.
    private _men18 = +(crew _veh);
    private _grp18 = group (driver _veh);
    ["FIXTURE: the aircraft has a crew and a group to stand down", count _men18 > 0 && {!isNull _grp18}] call _fnc_check;
    (["standDownCrew"] call _fnc_apply) params ["_st18", "_m18", "_d18"];
    // Read a few seconds later: a deleted man can still read as there in the
    // frame he is deleted in.
    sleep 3;
    ["the crew is deleted from the aircraft, whoever is watching",
        _st18 isEqualTo "ok" && {_d18 isEqualTo "deleted"}
        && {({!isNull _x} count _men18) == 0} && {count (crew _veh) == 0}] call _fnc_check;
    diag_log format ["  info  the crew's group 3 s after the stand-down: %1", _grp18];
    ["and its empty group is deleted with it", isNull _grp18] call _fnc_check;

    // --- a crew kept aboard while its aircraft is held down -------------------
    // Not let out beside a hull put down from the air that is still being held:
    // on LAN four crew let out beside a Blackfish died with it ten seconds later.
    // The same men are stood down once the hold ends.
    if (count (crew _veh) == 0) then { ["mintCrew"] call _fnc_apply; sleep 1 };
    { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (crew _veh);
    private _heldMen = +(crew _veh);
    // Counted apart from being gone: with nobody watching the men are deleted,
    // which is gone and not dead, and a death must not pass as a stand-down.
    ALIVE_test_heldKilled = 0;
    { _x addEventHandler ["Killed", { ALIVE_test_heldKilled = ALIVE_test_heldKilled + 1 }] } forEach _heldMen;
    _veh setVariable ["ALiVE_mil_ato_settlingUntil", time + 30, false];
    (["standDownCrew"] call _fnc_apply) params ["_stH", "_mH", "_dH"];
    ["a crew is kept aboard while its aircraft is held down",
        _stH isEqualTo "ok" && {_dH isEqualTo "deferred until the hull has settled"}
        && {count _heldMen > 0} && {({_x in (crew _veh)} count _heldMen) == count _heldMen}] call _fnc_check;
    sleep 2;
    _veh setVariable ["ALiVE_mil_ato_settlingUntil", nil, false];
    sleep 3;
    ["and those men are stood down once the hold ends, none of them killed",
        (({alive _x && {_x in (crew _veh)}} count _heldMen) == 0) && {ALIVE_test_heldKilled == 0}] call _fnc_check;
    // Unless the aircraft is given a new sortie first: the men aboard become its
    // crew, and are left there.
    ["mintCrew"] call _fnc_apply;
    sleep 1;
    private _nextMen = +(crew _veh);
    _veh setVariable ["ALiVE_mil_ato_settlingUntil", time + 30, false];
    (["standDownCrew"] call _fnc_apply) params ["", "", "_dH2"];
    ["mintCrew"] call _fnc_apply;
    _veh setVariable ["ALiVE_mil_ato_settlingUntil", nil, false];
    sleep 3;
    ["but a crew claimed for a new sortie meanwhile stays aboard",
        _dH2 isEqualTo "deferred until the hull has settled" && {count _nextMen > 0}
        && {({alive _x && {_x in (crew _veh)}} count _nextMen) == count _nextMen}] call _fnc_check;
    // And is ready to fight again: a landing crew is calmed on the way in, and
    // the same men flying the next sortie must be able to shoot.
    (group (driver _veh)) setBehaviour "CARELESS";
    (group (driver _veh)) setCombatMode "BLUE";
    { _x disableAI "AUTOTARGET"; _x disableAI "TARGET" } forEach (crew _veh);
    ["mintCrew"] call _fnc_apply;
    ["and a crew kept for a new sortie has its targeting back",
        !((behaviour (driver _veh)) isEqualTo "CARELESS") && {!((combatMode (group (driver _veh))) isEqualTo "BLUE")}
        && {(driver _veh) checkAIFeature "AUTOTARGET"} && {(driver _veh) checkAIFeature "TARGET"}] call _fnc_check;
    // A held hull can be thrown well up while it settles. Its crew is kept
    // aboard then too, not refused as in the air and forgotten, and let go once
    // it is down and the hold is over.
    private _upMen = +(crew _veh);
    ALIVE_test_upKilled = 0;
    { _x addEventHandler ["Killed", { ALIVE_test_upKilled = ALIVE_test_upKilled + 1 }] } forEach _upMen;
    private _was = getPosATL _veh;
    _veh allowDamage false;
    _veh setVariable ["ALiVE_mil_ato_settlingUntil", time + 30, false];
    _veh setPosATL [_was select 0, _was select 1, 12];
    (["standDownCrew"] call _fnc_apply) params ["_stU", "", "_dU"];
    ["a crew is kept aboard a held hull that is up in the air",
        _stU isEqualTo "ok" && {_dU isEqualTo "deferred until the hull has settled"}] call _fnc_check;
    _veh setPosATL [_was select 0, _was select 1, 0];
    _veh setVelocity [0,0,0];
    _veh setVariable ["ALiVE_mil_ato_settlingUntil", nil, false];
    sleep 8;
    ["and let go once it is down, none of them killed",
        (({alive _x && {_x in (crew _veh)}} count _upMen) == 0) && {ALIVE_test_upKilled == 0}] call _fnc_check;
    _veh allowDamage true;

    // --- re-crewing an aircraft whose crew was killed ---------------------------
    // Bodies stay in their seats, and crew creation only fills empty ones, so
    // this only works if the dead are taken out first.
    private _dead = createVehicle ["B_Heli_Transport_01_F", _spot getPos [120, 180], [], 0, "CAN_COLLIDE"];
    _dead setPosATL [(getPosATL _dead) select 0, (getPosATL _dead) select 1, 0];
    createVehicleCrew _dead;
    sleep 2;
    { _x setDamage 1 } forEach (crew _dead);
    sleep 2;
    ["the crew really are dead", ({alive _x} count (crew _dead)) == 0] call _fnc_check;
    (([_e, "apply", ["recrewInPlace", _dead, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_stR", "_mR", "_dR"];
    sleep 2;
    ["an aircraft with a dead crew is crewed again",
        _stR isEqualTo "ok" && {({alive _x} count (crew _dead)) > 0}] call _fnc_check;
    { deleteVehicle _x } forEach (crew _dead);
    deleteVehicle _dead;

    // --- kept off another air commander -----------------------------------------
    // Drongo's Air Operations takes every crewed aircraft it sees unless the hull
    // or its group is on its daoIgnore list. That list is faked here so the rig
    // can check it without the mod; without the mod nothing may be made.
    private _hadList = !isNil "daoIgnore";
    if (!_hadList) then { daoIgnore = [] };
    private _keptOff = createVehicle ["B_Heli_Transport_01_F", _spot getPos [90, 0], [], 0, "CAN_COLLIDE"];
    sleep 1;
    [_e, "apply", ["mintCrew", _keptOff, _home, []]] call ALIVE_fnc_ATOEffect;
    sleep 1;
    ["a crew the ATO makes goes on Drongo's ignore list, hull and group",
        (_keptOff in daoIgnore) && {(group (driver _keptOff)) in daoIgnore}
        && {_keptOff getVariable ["daoExclude", false]} && {(group (driver _keptOff)) getVariable ["daoExclude", false]}] call _fnc_check;
    { deleteVehicle _x } forEach (crew _keptOff);
    deleteVehicle _keptOff;
    if (!_hadList) then {
        daoIgnore = nil;
        private _plain = createVehicle ["B_Heli_Transport_01_F", _spot getPos [90, 0], [], 0, "CAN_COLLIDE"];
        sleep 1;
        [_e, "apply", ["mintCrew", _plain, _home, []]] call ALIVE_fnc_ATOEffect;
        ["and without the mod no list is made and nothing is marked",
            isNil "daoIgnore" && {!(_plain getVariable ["daoExclude", false])}] call _fnc_check;
        { deleteVehicle _x } forEach (crew _plain);
        deleteVehicle _plain;
    };

    // --- never thrown into the air when it cannot fly ---------------------------
    // An Apache with its rotors broken off against a hangar was forced six
    // hundred metres up and fell. A destroyed rotor reads damage 0.
    private _broken = createVehicle ["B_Heli_Transport_01_F", _spot getPos [120, 90], [], 0, "CAN_COLLIDE"];
    _broken setPosATL [((_spot getPos [120, 90]) select 0), ((_spot getPos [120, 90]) select 1), 0];
    createVehicleCrew _broken;
    sleep 1;
    _broken setHitPointDamage ["HitHRotor", 1];
    sleep 1;
    (([_e, "apply", ["forceLaunch", _broken, [getPosATL _broken, 0, "terrain"], []]] call ALIVE_fnc_ATOEffect)) params ["_stF", "_mF", "_dF"];
    sleep 1;
    diag_log format ["  info  forceLaunch on a helicopter with no rotor said %1 %2, it stands %3 m up", _stF, _dF, round ((getPosATL _broken) select 2)];
    ["a helicopter with its rotor gone is not forced into the air",
        _stF isEqualTo "refused" && {((getPosATL _broken) select 2) < 5}] call _fnc_check;

    // --- repaired after a break, however recently it was serviced ---------------
    // The launch call-off asks for a service. Two things stopped it repairing a
    // hull broken inside a minute of its last service: the "already serviced"
    // answer, and a truck's old "complete" still written on the hull, which the
    // wait reads as the truck having done the job. Both are put here on purpose.
    // With a logistics commander placed the effect waits for a truck instead,
    // three minutes, so the steps are skipped rather than failed.
    private _brokenLabels = ["a helicopter with its rotor gone is repaired where it stands",
        "broken again inside the minute, with a truck's old answer still on it, it is repaired again",
        "a sound aircraft serviced a moment ago is not serviced twice"];
    if ((count (allMissionObjects "ALiVE_mil_logistics")) > 0) then {
        {
            _skipped pushBack _x;
            diag_log format ["  skip  %1  (a logistics commander is placed, so this would wait for a truck)", _x];
        } forEach _brokenLabels;
    } else {
        private _brokenHome = [getPosATL _broken, 0, "terrain"];
        (([_e, "apply", ["turnaround", _broken, _brokenHome, ["TEST_BROKEN"]]] call ALIVE_fnc_ATOEffect)) params ["_stT1", "_mT1", "_dT1"];
        sleep 7;
        diag_log format ["  info  first service said %1 %2; the rotor reads %3, canMove %4",
            _stT1, _dT1, _broken getHitPointDamage "HitHRotor", canMove _broken];
        [_brokenLabels select 0, _stT1 isEqualTo "ok" && {!_mT1} && {canMove _broken}
            && {(_broken getHitPointDamage "HitHRotor") == 0}] call _fnc_check;
        _broken setHitPointDamage ["HitHRotor", 1];
        _broken setVariable ["ALIVE_resupply_state", "complete", true];
        sleep 1;
        diag_log format ["  info  broken again %1 s after that service, canMove %2",
            round (time - (_broken getVariable ["ALiVE_mil_ato_servicedAt", time])), canMove _broken];
        (([_e, "apply", ["turnaround", _broken, _brokenHome, ["TEST_BROKEN"]]] call ALIVE_fnc_ATOEffect)) params ["_stT2", "_mT2", "_dT2"];
        sleep 7;
        diag_log format ["  info  second service said %1 %2; the rotor reads %3, canMove %4",
            _stT2, _dT2, _broken getHitPointDamage "HitHRotor", canMove _broken];
        [_brokenLabels select 1, _stT2 isEqualTo "ok" && {!_mT2} && {canMove _broken}] call _fnc_check;
        (([_e, "apply", ["turnaround", _broken, _brokenHome, ["TEST_BROKEN"]]] call ALIVE_fnc_ATOEffect)) params ["_stT3", "_mT3", "_dT3"];
        [_brokenLabels select 2, _stT3 isEqualTo "ok" && {_mT3} && {_dT3 isEqualTo "already serviced"}] call _fnc_check;
    };
    { deleteVehicle _x } forEach (crew _broken);
    deleteVehicle _broken;

    // --- a truck's service leaves the tank full ----------------------------------
    // The truck only ever raises fuel to half a tank, so an aircraft landing with
    // more got nothing: on LAN an Apache was serviced by a truck at 0.61, 0.54 and
    // 0.50. The truck is played here by writing its "complete" on the hull while
    // the service waits, which is what the logistics side does when it is done.
    if ((count (allMissionObjects "ALiVE_mil_logistics")) > 0) then {
        _skipped pushBack "a truck's service leaves the tank full";
        diag_log "  skip  a truck's service leaves the tank full  (a logistics commander is placed, so this would wait for a real truck)";
    } else {
        private _tanked = createVehicle ["B_Plane_CAS_01_F", _spot getPos [60, 200], [], 0, "CAN_COLLIDE"];
        _tanked setPosATL [((_spot getPos [60, 200]) select 0), ((_spot getPos [60, 200]) select 1), 0];
        sleep 1;
        _tanked setFuel 0.61;
        // Damaged as well, which tells the two ways out apart: serviced where it
        // stands it is repaired, and after a truck the module leaves the repair to
        // the truck and only fills the tank.
        _tanked setDamage 0.3;
        private _tankWas = fuel _tanked;
        private _tankedHome = [getPosATL _tanked, 0, "terrain"];
        private _rF1 = [];
        // Asked and answered in one unscheduled block, so the service's own thread
        // cannot look before the truck's answer is written.
        isNil {
            _rF1 = [_e, "apply", ["turnaround", _tanked, _tankedHome, ["TEST_TANKED"]]] call ALIVE_fnc_ATOEffect;
            _tanked setVariable ["ALIVE_resupply_state", "complete", true];
        };
        _rF1 params ["_stF1", "_mF1", "_dF1"];
        sleep 7;
        diag_log format ["  info  turnaround said %1 %2; the tank read %3 before and %4 after the truck's answer, damage %5",
            _stF1, _dF1, _tankWas, fuel _tanked, damage _tanked];
        ["FIXTURE: the aircraft came in with more than half a tank and a service was asked for",
            _tankWas > 0.5 && {_tankWas < 0.7} && {_stF1 isEqualTo "ok"} && {!_mF1}] call _fnc_check;
        ["a truck's service leaves the tank full", (fuel _tanked) > 0.99 && {(damage _tanked) > 0.2}] call _fnc_check;
        deleteVehicle _tanked;
    };

    // --- held on the stand -------------------------------------------------------
    // An empty tank while it waits, and exactly what it had given back after.
    private _held = createVehicle ["B_Plane_CAS_01_F", _spot getPos [60, 270], [], 0, "CAN_COLLIDE"];
    _held setPosATL [((_spot getPos [60, 270]) select 0), ((_spot getPos [60, 270]) select 1), 0];
    _held setFuel 0.7;
    sleep 1;
    private _heldHome = [getPosATL _held, 0, "terrain"];
    (([_e, "apply", ["holdOnStand", _held, _heldHome, []]] call ALIVE_fnc_ATOEffect)) params ["_stH1", "_mH1", "_dH1"];
    diag_log format ["  info  hold said %1 %2, the tank reads %3", _stH1, _dH1, fuel _held];
    ["a plane held on its stand has an empty tank", _stH1 isEqualTo "ok" && {!_mH1} && {(fuel _held) == 0}] call _fnc_check;
    (([_e, "apply", ["holdOnStand", _held, _heldHome, []]] call ALIVE_fnc_ATOEffect)) params ["_stH2", "_mH2"];
    ["holding it again changes nothing and says so", _stH2 isEqualTo "ok" && {_mH2} && {(fuel _held) == 0}] call _fnc_check;
    (([_e, "apply", ["releaseHold", _held, _heldHome, []]] call ALIVE_fnc_ATOEffect)) params ["_stH3", "_mH3", "_dH3"];
    diag_log format ["  info  release said %1 %2, the tank reads %3", _stH3, _dH3, fuel _held];
    ["let go, it has exactly the fuel it had", _stH3 isEqualTo "ok" && {!_mH3} && {abs ((fuel _held) - 0.7) < 0.01}] call _fnc_check;
    (([_e, "apply", ["releaseHold", _held, _heldHome, []]] call ALIVE_fnc_ATOEffect)) params ["_stH4", "_mH4"];
    ["letting go again changes nothing and says so", _stH4 isEqualTo "ok" && {_mH4} && {abs ((fuel _held) - 0.7) < 0.01}] call _fnc_check;
    deleteVehicle _held;

    // --- the taxi out ------------------------------------------------------------
    // A plane is stood on its airport's taxi route, pointing along it, and a
    // helicopter is left where it is. The route is read from this terrain's own
    // config, so the expected spot is worked out here rather than written in.
    // A stand just BEHIND the head of the route has its nearest point on the
    // first leg at the head itself, which is the case the old module handled.
    private _w = configFile >> "CfgWorlds" >> worldName;
    private _in = getArray (_w >> "ilsTaxiIn");
    private _ils = getArray (_w >> "ilsPosition");
    if (count _in < 4 || {count _ils < 2} || {(count (_w >> "SecondaryAirports")) > 0}) then {
        diag_log format ["  info  taxi out not checked: %1 has no single airport with a taxi route", worldName];
    } else {
        (["taxiOut", [_s]] call _fnc_apply) params ["_stT0", "_mT0", "_dT0"];
        ["a helicopter is not put on a taxi route", _stT0 isEqualTo "ok" && {_mT0}] call _fnc_check;
        // On the rig that helicopter's stand is on the first leg of the route,
        // 36 m down it. Moved well clear, so the cases below are the scenes
        // they describe and nothing else is in the way.
        private _vehWas = getPosATL _veh;
        _veh setPosATL [(_vehWas select 0) - 300, _vehWas select 1, 0];
        sleep 1;

        if (isClass (configFile >> "CfgVehicles" >> "B_T_VTOL_01_infantry_F")) then {
            private _vtol = createVehicle ["B_T_VTOL_01_infantry_F", [1000, 5500, 500], [], 0, "FLY"];
            (([_e, "apply", ["taxiOut", _vtol, [[1000, 5500, 0], 0, "terrain"], [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stV", "_mV", "_dV"];
            ["a VTOL is not put on a taxi route", _stV isEqualTo "ok" && {_mV} && {(_dV find "VTOL") > -1}] call _fnc_check;
            deleteVehicle _vtol;
        } else {
            diag_log "  info  no V-44 on this install, the VTOL check was not run";
        };

        private _headT = [_in select 0, _in select 1, 0];
        private _nextT = [_in select 2, _in select 3, 0];
        private _hdgT = _headT getDir _nextT;
        private _standT = _headT getPos [40, _hdgT + 180];
        _standT set [2, 0];
        private _homeT = [_standT, _hdgT, "terrain"];

        // How far apart two headings are, either way round.
        private _fnc_turn = { params ["_h1", "_h2"]; abs ((((_h1 - _h2) + 540) % 360) - 180) };

        private _jet = createVehicle ["B_Plane_CAS_01_F", _standT, [], 0, "CAN_COLLIDE"];
        _jet setPosATL _standT;
        sleep 2;
        (([_e, "apply", ["taxiOut", _jet, _homeT, [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stT1", "_mT1", "_dT1"];
        sleep 1;
        diag_log format ["  info  taxi out said %1, %2; the plane is %3 m from the head, heading %4 against %5",
            _stT1, _dT1, round (_jet distance2D _headT), round (getDir _jet), round _hdgT];
        ["a plane is stood at the head of its taxi route", _stT1 isEqualTo "ok" && {!_mT1} && {(_jet distance2D _headT) < 3}] call _fnc_check;
        ["pointing along it", ([getDir _jet, _hdgT] call _fnc_turn) < 5] call _fnc_check;
        (([_e, "apply", ["taxiOut", _jet, _homeT, [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stT2", "_mT2"];
        ["asking again while it stands there changes nothing", _stT2 isEqualTo "ok" && {_mT2} && {(_jet distance2D _headT) < 3}] call _fnc_check;

        // A second one while the first is still on the head goes further down
        // the leg, ahead of it and clear of it, never on top of it. Clear
        // means further apart than their two half spans put together.
        private _stand2 = _standT getPos [30, _hdgT + 90];
        _stand2 set [2, 0];
        private _jet2 = createVehicle ["B_Plane_CAS_01_F", _stand2, [], 0, "CAN_COLLIDE"];
        _jet2 setPosATL _stand2;
        sleep 2;
        (([_e, "apply", ["taxiOut", _jet2, _homeT, [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stT3", "_mT3", "_dT3"];
        sleep 1;
        private _fnc_halfT = {
            (boundingBoxReal _this) params ["_lo", "_hi"];
            ((abs ((_hi select 0) - (_lo select 0))) max (abs ((_hi select 1) - (_lo select 1)))) / 2
        };
        private _needT = (_jet call _fnc_halfT) + (_jet2 call _fnc_halfT);
        private _gapT = _jet2 distance2D _jet;
        private _p2 = getPosATL _jet2;
        private _offLineT = abs ((((_p2 select 0) - (_headT select 0)) * (cos _hdgT)) - (((_p2 select 1) - (_headT select 1)) * (sin _hdgT)));
        diag_log format ["  info  second plane: %1, %2; %3 m from the first (needs %4), %5 m down the leg, %6 m off its line",
            _stT3, _dT3, round _gapT, round _needT, round (_jet2 distance2D _headT), round _offLineT];
        ["a second plane is not stood on top of the first", _stT3 isEqualTo "ok" && {_gapT > _needT}] call _fnc_check;
        ["it goes AHEAD of it, down the leg", ([_headT getDir _jet2, _hdgT] call _fnc_turn) < 5] call _fnc_check;
        ["and on the route, not beside it", _offLineT < 3] call _fnc_check;

        // A deck or a held aircraft has its own launch and is never moved here.
        (([_e, "apply", ["taxiOut", _jet2, [_standT, 0, "deck"], [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stT4", "_mT4"];
        ["a plane living on a deck is left for the catapult", _stT4 isEqualTo "ok" && {_mT4}] call _fnc_check;
        (([_e, "apply", ["taxiOut", _jet2, [_standT, 0, "virtual"], [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stT5", "_mT5"];
        ["and so is a held one", _stT5 isEqualTo "ok" && {_mT5}] call _fnc_check;

        deleteVehicle _jet;
        deleteVehicle _jet2;
        sleep 1;

        // Traffic coming down the leg is never stood in front of. A crewed jet
        // is set taxiing from the head, and a second one whose stand is beside
        // the leg 300 m further down is asked to launch into its path.
        private _destM = _headT getPos [1200, 60];
        private _mover = createVehicle ["B_Plane_CAS_01_F", _headT, [], 0, "CAN_COLLIDE"];
        _mover setDir _hdgT;
        _mover setPosATL _headT;
        createVehicleCrew _mover;
        _mover engineOn true;
        private _grpM = group (driver _mover);
        (_grpM addWaypoint [_destM, 0]) setWaypointType "MOVE";
        _grpM setCurrentWaypoint [_grpM, 0];
        _mover doMove _destM;
        (driver _mover) doMove _destM;
        private _byM = time + 25;
        waitUntil { sleep 0.5; (speed _mover) > 20 || {time > _byM} };
        diag_log format ["  info  the taxiing jet is doing %1 km/h, %2 m down the leg",
            round (speed _mover), round (_mover distance2D _headT)];
        ["FIXTURE: a jet is taxiing down the leg", (speed _mover) > 5] call _fnc_check;

        private _standAhead = (_headT getPos [300, _hdgT]) getPos [60, _hdgT + 90];
        _standAhead set [2, 0];
        private _jet3 = createVehicle ["B_Plane_CAS_01_F", _standAhead, [], 0, "CAN_COLLIDE"];
        _jet3 setPosATL _standAhead;
        sleep 1;
        private _jet3Was = getPosATL _jet3;
        (([_e, "apply", ["taxiOut", _jet3, [_standAhead, _hdgT, "terrain"], [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stT6", "_mT6", "_dT6"];
        diag_log format ["  info  with a jet taxiing towards its spot: %1, %2", _stT6, _dT6];
        ["a plane is not stood in front of one taxiing towards it",
            _stT6 isEqualTo "refused" && {(_dT6 find "moving") > -1} && {(_jet3 distance2D _jet3Was) < 3}] call _fnc_check;

        { deleteVehicle _x } forEach (crew _mover);
        deleteVehicle _mover;
        deleteVehicle _jet3;
    };

    // --- things this pass does not do ------------------------------------------
    // catapult and tailhook used to be here; they are built now and have their
    // own test on a carrier scene, so the names that stay unbuilt stand in.
    {
        (([_e, "apply", [_x, _veh, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_sty", "_my", "_dy"];
        [format ["%1 refuses rather than doing nothing quietly", _x],
            _sty isEqualTo "refused" && {_dy isEqualTo "not built"}] call _fnc_check;
    } forEach ["deckLaunch", "siren", "holdTargets"];

    (([_e, "apply", ["somethingNobodyWrote", _veh, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_st19", "_m19", "_d19"];
    ["an effect it has never heard of is refused",
        _st19 isEqualTo "refused" && {_d19 isEqualTo "unknown effect"}] call _fnc_check;

    (([_e, "apply", ["engineOn", objNull, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_st20", "_m20", "_d20"];
    ["an effect on a missing aircraft is refused", _st20 isEqualTo "refused"] call _fnc_check;

    // --- tidy -------------------------------------------------------------------
    { deleteVehicle _x } forEach (crew _veh);
    deleteVehicle _veh;

    diag_log format ["  info  %1 assertions", _checked];
    // The skips are named in the verdict, not just counted. A run that says
    // ALL PASS while quietly leaving five checks out is worse than one that
    // fails, because nobody goes looking.
    if (count _skipped > 0) then {
        diag_log format ["  info  %1 check(s) skipped for want of a player: %2",
            count _skipped, _skipped];
    };
    if (count _fails == 0) then {
        if (count _skipped == 0) then {
            diag_log "=== ATO Effector test: ALL PASS ===";
        } else {
            diag_log format ["=== ATO Effector test: ALL PASS, %1 SKIPPED ===", count _skipped];
        };
    } else {
        diag_log format ["=== ATO Effector test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Effector test started, results follow in the log"
