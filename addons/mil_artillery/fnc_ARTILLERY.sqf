#include "\x\alive\addons\mil_artillery\script_component.hpp"
SCRIPT(ARTILLERY);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MilArtillery

Description:
Military AI Artillery module. Lets AI commanders run real fire missions with
profiled artillery batteries. OPCOM raises ARTY_REQUEST events from its
artillery engagement branch; this module owns the battery registry and every
throttle: per-battery cooldowns, limited ammunition, extra dispersion,
minimum-contact targeting and a friendly-fire check on the impact area.
Batteries and targets are force-spawned for the duration of a mission using
the same preventDespawn pattern the air component uses for CAS targets.

Parameters:
Object - module logic
String - operation
Any - arguments

Returns:
Any

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_MilArtillery

// coarse per-kind range defaults until a battery's first activation
// confirms real capability (engine range checks need a crewed gun)
#define DEFAULT_RANGE_MORTAR 4000
#define DEFAULT_RANGE_GUN 12000
#define DEFAULT_RANGE_ROCKET 15000
#define DEFAULT_MINRANGE_MORTAR 100
#define DEFAULT_MINRANGE_GUN 500
#define DEFAULT_MINRANGE_ROCKET 6000

private ["_logic","_operation","_args","_result"];

TRACE_1("ARTILLERY - input",_this);

_logic = param [0, objNull];
_operation = param [1, ""];
_args = param [2, objNull];
_result = nil;

switch(_operation) do {

    case "init": {

        if (isServer) then {

            // one module per AI commander (sync it to the OPCOM), or a single
            // unsynced module to serve every commander. First module also goes
            // into ALIVE_MilArtillery for console convenience.
            private _instances = missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []];
            _instances pushBack _logic;
            missionNamespace setVariable ["ALIVE_MilArtilleryInstances", _instances];
            if (isNil "ALIVE_MilArtillery") then { ALIVE_MilArtillery = _logic; };

            // event log dispatch resolves the handler through these
            _logic setVariable ["super", QUOTE(SUPERCLASS)];
            _logic setVariable ["class", QUOTE(MAINCLASS)];

            private _debug = [_logic, "debug"] call MAINCLASS;
            private _intensity = [_logic, "intensity"] call MAINCLASS;

            // single dial scaling every throttle:
            // [cooldown base, cooldown jitter, dispersion m, rounds per mission, min contacts, max concurrent, rounds ledger, cb acquisition per shell]
            private _profile = switch (_intensity) do {
                case "LOW":  { [600, 120, 100, 4, 4, 1, 60, 0.05] };
                case "HIGH": { [300, 120, 50, 8, 2, 2, 120, 0.18] };
                default      { [420, 120, 75, 6, 3, 1, 90, 0.10] };
            };

            // per-parameter fine tuning: each override replaces just its slice
            // of the preset when set to something other than "Use preset"
            private _cadence = [_logic, "cadenceLevel"] call MAINCLASS;
            if (_cadence != "PRESET") then {
                _profile set [0, switch (_cadence) do { case "LOW": {600}; case "HIGH": {300}; default {420} }];
            };
            private _spread = [_logic, "spreadLevel"] call MAINCLASS;
            if (_spread != "PRESET") then {
                _profile set [2, switch (_spread) do { case "LOW": {100}; case "HIGH": {50}; default {75} }];
            };
            private _rounds = [_logic, "roundsLevel"] call MAINCLASS;
            if (_rounds != "PRESET") then {
                _profile set [3, switch (_rounds) do { case "LOW": {4}; case "HIGH": {8}; default {6} }];
            };
            private _ammo = [_logic, "ammoLevel"] call MAINCLASS;
            if (_ammo != "PRESET") then {
                _profile set [6, switch (_ammo) do { case "LOW": {60}; case "HIGH": {120}; default {90} }];
            };
            private _selectivity = [_logic, "selectivityLevel"] call MAINCLASS;
            if (_selectivity != "PRESET") then {
                _profile set [4, switch (_selectivity) do { case "LOOSE": {1}; case "STRICT": {3}; default {2} }];
            };
            private _cb = [_logic, "counterBatteryLevel"] call MAINCLASS;
            if (_cb != "PRESET") then {
                _profile set [7, switch (_cb) do { case "OFF": {0}; case "LOW": {0.05}; case "HIGH": {0.18}; default {0.10} }];
            };

            _logic setVariable ["intensityProfile", _profile];
            _logic setVariable ["batteryRegistry", []];
            _logic setVariable ["requestQueue", []];
            _logic setVariable ["activeMissions", 0];
            _logic setVariable ["cbContacts", []];
            _logic setVariable ["cbLastScan", 0];
            _logic setVariable ["cbRolled", []];

            // settings are logged from the monitor once sides are resolved, so
            // the line can say WHICH commander this module serves

            [_logic,"listen"] call MAINCLASS;
            [_logic,"monitor"] call MAINCLASS;
        };

        _result = _logic;
    };

    // module attributes ------------------------------------------------------

    case "debug": {
        if (_args isEqualType true) then {
            _logic setVariable ["debug", _args];
        } else {
            // read the short name first, then the 3DEN property name (which the
            // editor writes directly), so the attribute works with or without a
            // framework copy to the short name
            _args = _logic getVariable ["debug", _logic getVariable ["ALiVE_mil_artillery_debug", false]];
        };
        if (_args isEqualType "") then {
            _args = (toLower _args) == "true";
        };
        if !(_args isEqualType true) then { _args = false; };
        _logic setVariable ["debug", _args];
        _result = _args;
    };

    case "intensity": {
        if (_args isEqualType "" && {_args != ""}) then {
            _args = toUpper _args;
        } else {
            _args = _logic getVariable ["intensity", _logic getVariable ["ALiVE_mil_artillery_intensity", "MEDIUM"]];
        };
        if !(_args isEqualType "") then { _args = "MEDIUM"; };
        _args = toUpper _args;
        _logic setVariable ["intensity", _args];
        _result = _args;
    };

    case "generateTasks": {
        if (_args isEqualType true) then {
            _logic setVariable ["generateTasks", _args];
        } else {
            _args = _logic getVariable ["generateTasks", _logic getVariable ["ALiVE_mil_artillery_generateTasks", true]];
        };
        if (_args isEqualType "") then {
            _args = (toLower _args) == "true";
        };
        if !(_args isEqualType true) then { _args = true; };
        _logic setVariable ["generateTasks", _args];
        _result = _args;
    };

    // fine-tuning overrides - "PRESET" defers to the intensity dial
    case "cadenceLevel";
    case "spreadLevel";
    case "roundsLevel";
    case "selectivityLevel";
    case "counterBatteryLevel";
    case "ammoLevel": {
        private _attr = _operation;
        if (_args isEqualType "" && {_args != ""}) then {
            _args = toUpper _args;
        } else {
            _args = _logic getVariable [_attr, _logic getVariable [format ["ALiVE_mil_artillery_%1", _attr], "PRESET"]];
        };
        if !(_args isEqualType "") then { _args = "PRESET"; };
        _args = toUpper _args;
        _logic setVariable [_attr, _args];
        _result = _args;
    };

    // side ownership -------------------------------------------------------------

    // Derive which sides this module serves from the OPCOM modules synced to it.
    // A module with nothing synced serves every side not claimed by a synced one.
    // First module to claim a side wins; a competing claim is logged once.
    case "resolveSides": {

        private _handled = [];
        private _asymBySide = [];
        {
            if ((typeOf _x) == "ALiVE_mil_OPCOM") then {
                private _handler = _x getVariable "handler";
                if (!isNil "_handler" && {_handler isEqualType []}) then {
                    private _oSide = toUpper ([_handler,"side",""] call ALiVE_fnc_hashGet);
                    if (_oSide != "") then {
                        _handled pushBackUnique _oSide;
                        if (([_handler,"controltype",""] call ALiVE_fnc_hashGet) == "asymmetric") then {
                            _asymBySide pushBackUnique _oSide;
                        };
                    };
                };
            };
        } forEach (synchronizedObjects _logic);

        private _claims = missionNamespace getVariable ["ALIVE_MilArtillerySideClaims", []];
        // release orphaned claims: module logics that no longer exist, and
        // this module's own claims for sides it no longer handles (re-sync)
        _claims = _claims select {
            !isNull (_x select 1)
            && {!((_x select 1) isEqualTo _logic) || {(_x select 0) in _handled}}
        };
        private _final = [];
        {
            private _side = _x;
            private _idx = _claims findIf { (_x select 0) == _side };
            if (_idx == -1) then {
                _claims pushBack [_side, _logic];
                _final pushBack _side;
            } else {
                if (((_claims select _idx) select 1) isEqualTo _logic) then {
                    _final pushBack _side;
                } else {
                    private _warned = _logic getVariable ["sideClaimWarned", []];
                    if !(_side in _warned) then {
                        _warned pushBack _side;
                        _logic setVariable ["sideClaimWarned", _warned];
                        ["ALiVE MIL_ARTILLERY - side %1 is already served by another Military AI Commander Artillery module; this module ignores it", _side] call ALiVE_fnc_dump;
                    };
                };
            };
        } forEach _handled;
        missionNamespace setVariable ["ALIVE_MilArtillerySideClaims", _claims];

        _logic setVariable ["handledSides", _final];
        // counter-battery requests inherit the commander's control type -
        // asymmetric commanders answer with mortars only (processRequest gate).
        // Built from the arbitrated set so a lost side can't linger here
        _logic setVariable ["asymSides", _asymBySide select { _x in _final }];

        // two unsynced modules would silently double-serve every side; warn
        // once so the mission maker splits them by syncing to commanders.
        // "Unsynced" is judged by the actual sync links, not handledSides -
        // a synced module resolves empty sides until its commander finishes
        // initialising and must not trip this
        if (count _final == 0
            && {!(_logic getVariable ["unsyncedWarned", false])}
            && {((synchronizedObjects _logic) findIf { (typeOf _x) == "ALiVE_mil_OPCOM" }) == -1}) then {
            private _otherIdx = (missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]) findIf {
                !(_x isEqualTo _logic) && {!isNull _x}
                && {((synchronizedObjects _x) findIf { (typeOf _x) == "ALiVE_mil_OPCOM" }) == -1}
            };
            if (_otherIdx >= 0) then {
                _logic setVariable ["unsyncedWarned", true];
                ["ALiVE MIL_ARTILLERY - more than one module has no synced AI commander; each will serve every unclaimed side and fire twice - sync the modules to commanders to split them"] call ALiVE_fnc_dump;
            };
        };
        _result = _final;
    };

    case "sideInScope": {
        private _sideText = toUpper _args;
        private _handled = _logic getVariable ["handledSides", []];
        if (count _handled > 0) exitWith { _result = _sideText in _handled; };
        // unsynced module: cover any side no synced module has claimed
        private _claims = missionNamespace getVariable ["ALIVE_MilArtillerySideClaims", []];
        _result = (_claims findIf { (_x select 0) == _sideText && {!((_x select 1) isEqualTo _logic)} }) == -1;
    };

    // battery registry ---------------------------------------------------------

    case "buildRegistry": {

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _registry = _logic getVariable ["batteryRegistry", []];
        private _ledgerSize = (_logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]]) select 6;

        private _knownEntityIDs = [];
        {
            _knownEntityIDs pushBack ([_x,"entityID"] call ALiVE_fnc_hashGet);
        } forEach _registry;

        // drop records whose crew profile no longer exists or whose guns are
        // all destroyed - a dead battery must not keep winning "nearest" picks
        // and burning the concurrency slot on 90s crewed-gun timeouts
        private _live = [];
        {
            private _record = _x;
            private _entityID = [_record,"entityID"] call ALiVE_fnc_hashGet;
            private _entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
            private _gunsAlive = ([_record,"vehicleIDs",[]] call ALiVE_fnc_hashGet) select {
                !isNil { [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler }
            };
            private _recSide = [_record,"side"] call ALiVE_fnc_hashGet;
            private _recSideText = if (_recSide isEqualType west) then { toUpper str _recSide } else { toUpper _recSide };
            if (!isNil "_entityProfile" && {count _gunsAlive > 0} && {[_logic,"sideInScope",_recSideText] call MAINCLASS}) then {
                [_record,"vehicleIDs",_gunsAlive] call ALiVE_fnc_hashSet;
                _live pushBack _record;
            } else {
                if (_debug) then {
                    private _why = if (isNil "_entityProfile") then {"crew profile gone"} else {
                        if (count _gunsAlive == 0) then {"all guns destroyed"} else {"side no longer served"}
                    };
                    ["ALiVE MIL_ARTILLERY - battery %1 lost (%2), removed from registry", _entityID, _why] call ALiVE_fnc_dump;
                };
            };
        } forEach _registry;
        _registry = _live;

        // sweep vehicle profiles for artillery pieces and group them into
        // batteries by their commanding crew entity
        private _profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
        {
            private _profile = _x;
            if (([_profile,"type",""] call ALiVE_fnc_hashGet) == "vehicle") then {
                private _class = [_profile,"vehicleClass",""] call ALiVE_fnc_hashGet;

                if (_class != "" && {[_class] call ALIVE_fnc_isArtillery}) then {
                    private _entities = [_profile,"entitiesInCommandOf",[]] call ALiVE_fnc_hashGet;

                    // static weapons (towed guns, mortars) have no driver seat,
                    // so their crew never counts as "commanding" - derive the
                    // crew entity from the vehicle's assignment keys instead
                    if (count _entities == 0) then {
                        private _assignments = [_profile,"vehicleAssignments",[[],[],[]]] call ALiVE_fnc_hashGet;
                        if (_assignments isEqualType [] && {count _assignments > 1} && {count (_assignments select 1) > 0}) then {
                            _entities = +(_assignments select 1);
                        };
                    };

                    if (count _entities > 0) then {
                        private _entityID = _entities select 0;

                        if !(_entityID in _knownEntityIDs) then {
                            // new battery - collect every artillery vehicle this crew commands
                            private _entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;

                            // only batteries of the sides this module serves
                            if (!isNil "_entityProfile" && {
                                [_logic,"sideInScope", [_entityProfile,"side",""] call ALiVE_fnc_hashGet] call MAINCLASS
                            }) then {
                                // same static-weapon caveat as above: fall back
                                // to the entity's assignment keys (vehicle IDs)
                                private _candidateVehicles = [_entityProfile,"vehiclesInCommandOf",[]] call ALiVE_fnc_hashGet;
                                if (count _candidateVehicles == 0) then {
                                    private _eAssignments = [_entityProfile,"vehicleAssignments",[[],[],[]]] call ALiVE_fnc_hashGet;
                                    if (_eAssignments isEqualType [] && {count _eAssignments > 1}) then {
                                        _candidateVehicles = +(_eAssignments select 1);
                                    };
                                };
                                private _vehicleIDs = [];
                                {
                                    private _vp = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                    if (!isNil "_vp") then {
                                        private _vc = [_vp,"vehicleClass",""] call ALiVE_fnc_hashGet;
                                        if (_vc != "" && {[_vc] call ALIVE_fnc_isArtillery}) then {
                                            _vehicleIDs pushBack _x;
                                        };
                                    };
                                } forEach _candidateVehicles;

                                if (count _vehicleIDs > 0) then {
                                    private _kind = "gun";
                                    private _range = DEFAULT_RANGE_GUN;
                                    private _minRange = DEFAULT_MINRANGE_GUN;
                                    if (_class isKindOf "StaticMortar") then {
                                        _kind = "mortar";
                                        _range = DEFAULT_RANGE_MORTAR;
                                        _minRange = DEFAULT_MINRANGE_MORTAR;
                                    } else {
                                        private _ordnance = _class call ALiVE_fnc_GetArtyRounds;
                                        if ("ROCKETS" in _ordnance && {!("HE" in _ordnance)}) then {
                                            _kind = "rocket";
                                            _range = DEFAULT_RANGE_ROCKET;
                                            _minRange = DEFAULT_MINRANGE_ROCKET;
                                        };
                                    };

                                    private _record = [] call ALIVE_fnc_hashCreate;
                                    [_record,"entityID",_entityID] call ALiVE_fnc_hashSet;
                                    [_record,"vehicleIDs",_vehicleIDs] call ALiVE_fnc_hashSet;
                                    [_record,"side",[_entityProfile,"side",""] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;
                                    [_record,"faction",[_entityProfile,"faction",""] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;
                                    [_record,"kind",_kind] call ALiVE_fnc_hashSet;
                                    [_record,"maxRange",_range] call ALiVE_fnc_hashSet;
                                    [_record,"minRange",_minRange] call ALiVE_fnc_hashSet;
                                    [_record,"rounds",_ledgerSize] call ALiVE_fnc_hashSet;
                                    [_record,"cooldownUntil",0] call ALiVE_fnc_hashSet;
                                    [_record,"state","IDLE"] call ALiVE_fnc_hashSet;

                                    // crew the profile is carrying across all its guns - a
                                    // battery with crew < guns is short a gunner somewhere
                                    private _crewCount = [_entityProfile,"unitCount",0] call ALiVE_fnc_hashGet;
                                    if !(_crewCount isEqualType 0) then {
                                        _crewCount = count ([_entityProfile,"units",[]] call ALiVE_fnc_hashGet);
                                    };
                                    [_record,"crewCount",_crewCount] call ALiVE_fnc_hashSet;

                                    _registry pushBack _record;
                                    _knownEntityIDs pushBack _entityID;

                                    if (_debug) then {
                                        ["ALiVE MIL_ARTILLERY - battery registered: %1 side %2 faction %3 kind %4 guns %5 crew %6 class %7",
                                            _entityID,
                                            [_record,"side"] call ALiVE_fnc_hashGet,
                                            [_record,"faction"] call ALiVE_fnc_hashGet,
                                            _kind, count _vehicleIDs, _crewCount, _class] call ALiVE_fnc_dump;
                                    };
                                };
                            };
                        };
                    };
                };
            };
        } forEach (_profiles select 2);

        _logic setVariable ["batteryRegistry", _registry];

        // report what the module has to work with. Always on (not gated on
        // debug) and only when the count changes, so late placements show up
        // without repeating the list on every refresh.
        private _count = count _registry;
        if (_count != (_logic getVariable ["lastRegistryCount", -1])) then {
            _logic setVariable ["lastRegistryCount", _count];
            private _handled = _logic getVariable ["handledSides", []];
            private _scopeText = if (count _handled > 0) then { str _handled } else { "every unclaimed side (nothing synced)" };
            if (_count == 0) then {
                ["ALiVE MIL_ARTILLERY - no artillery batteries found for %1. Enable 'Place artillery units' on a placement module (or place profiled artillery in the editor) and give the faction artillery groups. Still watching for late placements.", _scopeText] call ALiVE_fnc_dump;
            } else {
                ["ALiVE MIL_ARTILLERY - %1 artillery batteries available (serving %2):", _count, _scopeText] call ALiVE_fnc_dump;
                {
                    private _ep = [ALIVE_profileHandler, "getProfile", [_x,"entityID"] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
                    private _bpos = if (!isNil "_ep") then { [_ep,"position"] call ALiVE_fnc_hashGet } else { [0,0,0] };
                    ["  - battery %1: side %2 faction %3 kind %4 guns %5 crew %6 grid %7",
                        [_x,"entityID"] call ALiVE_fnc_hashGet,
                        [_x,"side"] call ALiVE_fnc_hashGet,
                        [_x,"faction"] call ALiVE_fnc_hashGet,
                        [_x,"kind"] call ALiVE_fnc_hashGet,
                        count ([_x,"vehicleIDs"] call ALiVE_fnc_hashGet),
                        [_x,"crewCount",0] call ALiVE_fnc_hashGet,
                        mapGridPosition _bpos] call ALiVE_fnc_dump;
                } forEach _registry;
            };
        };

        _result = _registry;
    };

    // events -------------------------------------------------------------------

    case "listen": {
        private _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["ARTY_REQUEST","ARTY_RESUPPLY_ARRIVED"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };

    case "handleEvent": {
        if (_args isEqualType []) then {
            private _event = _args;
            private _type = [_event, "type"] call ALIVE_fnc_hashGet;
            switch (_type) do {
                case "ARTY_REQUEST": {
                    // the event log only holds a handful of events - copy the
                    // request into the module's own queue immediately, but only
                    // when the requesting side is one this module serves
                    private _data = [_event, "data"] call ALIVE_fnc_hashGet;
                    if ([_logic,"sideInScope", str (_data select 3)] call MAINCLASS) then {
                        private _queue = _logic getVariable ["requestQueue", []];
                        if (count _queue < 12) then {
                            _queue pushBack _data;
                            _logic setVariable ["requestQueue", _queue];
                        };
                    };
                };
                // a LOGCOM convoy reached a dry battery - refill it
                case "ARTY_RESUPPLY_ARRIVED": {
                    private _data = [_event, "data"] call ALIVE_fnc_hashGet;
                    [_logic,"refillBattery", _data select 0] call MAINCLASS;
                };
            };
        };
    };

    // main loop ------------------------------------------------------------------

    case "monitor": {

        ["ALiVE MIL_ARTILLERY - monitor case reached (isServer %1)", isServer] call ALiVE_fnc_dump;

        if (isServer) then {
            [_logic] spawn {
                params ["_logic"];

                ["ALiVE MIL_ARTILLERY - monitor thread live, waiting for the profile system"] call ALiVE_fnc_dump;

                // wait for the profile system, then let placement finish so the
                // first registry scan sees the guns the placement modules spawn.
                // (No sleep inside waitUntil - it has no effect there and can
                // abort the thread.)
                waitUntil { !isNil "ALIVE_profileHandler" };
                sleep 20;

                // heal despawn-holds frozen by a war-state save made while a
                // fire mission was in flight: the mission thread is gone after
                // load, so any marked hold is stale by definition. The war-state
                // import runs inside profile-system init - wait for it so the
                // loaded profiles exist before the one-shot sweep runs
                waitUntil { missionNamespace getVariable ["ALIVE_profileSystemInit", false] };
                if (isNil "ALIVE_artyHoldSweepDone") then {
                    ALIVE_artyHoldSweepDone = true;
                    private _healed = 0;
                    {
                        if (_x isEqualType [] && {[_x,"ALiVE_artyHold",false] call ALiVE_fnc_hashGet}) then {
                            [_x,"ALiVE_artyHold",false] call ALiVE_fnc_hashSet;
                            if (([_x,"type",""] call ALiVE_fnc_hashGet) == "vehicle") then {
                                [_x,"spawnType",[]] call ALiVE_fnc_profileVehicle;
                            } else {
                                [_x,"spawnType",[]] call ALiVE_fnc_profileEntity;
                            };
                            _healed = _healed + 1;
                        };
                    } forEach (([ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet) select 2);
                    if (_healed > 0) then {
                        ["ALiVE MIL_ARTILLERY - cleared %1 stale despawn-hold(s) left by a mid-mission save", _healed] call ALiVE_fnc_dump;
                    };
                };

                // counter-battery watch: one global shell detector shared by all
                // instances; the guard is set FIRST so two monitors racing in the
                // scheduler can't both install. Records one event per firer per
                // volley (60s coalescing window), pruned at 120s, capped at 30
                if (isNil "ALIVE_artyShellWatchInstalled") then {
                    ALIVE_artyShellWatchInstalled = true;
                    // single shared buffer, created once and only ever mutated
                    // IN PLACE - writing back a filtered copy would let the
                    // unscheduled handler and scheduled threads overwrite each
                    // other's updates
                    if (isNil "ALIVE_artyShellEvents") then { ALIVE_artyShellEvents = []; };
                    private _handle = addMissionEventHandler ["ArtilleryShellFired", {
                        params ["_vehicle","_weapon","_ammo","_gunner"];
                        private _pid = _vehicle getVariable ["profileID", ""];
                        if (_pid == "") exitWith {};
                        private _events = ALIVE_artyShellEvents;
                        private _idx = _events findIf { (_x select 0) == _pid && {time - (_x select 3) < 60} };
                        if (_idx >= 0) then {
                            private _e = _events select _idx;
                            _e set [1, getPosATL _vehicle];
                            _e set [3, time];
                            _e set [4, (_e select 4) + 1];
                        } else {
                            private _side = if (!isNull _gunner) then { side group _gunner } else { side _vehicle };
                            // [profileID, firing pos, side, last shell time, shells, volley id]
                            _events pushBack [_pid, getPosATL _vehicle, toUpper str _side, time, 1, time];
                        };
                        for "_i" from (count _events - 1) to 0 step -1 do {
                            if (time - ((_events select _i) select 3) >= 120) then { _events deleteAt _i; };
                        };
                        while {count _events > 30} do { _events deleteAt 0; };
                    }];
                    ["ALiVE MIL_ARTILLERY - counter-battery watch installed (ArtilleryShellFired handle %1)", _handle] call ALiVE_fnc_dump;
                };

                ["ALiVE MIL_ARTILLERY - monitor started, scanning for artillery batteries"] call ALiVE_fnc_dump;

                private _tick = 0;
                while {!isNull _logic} do {
                    // rebuild on the first pass and periodically after, so late
                    // placements and editor batteries are picked up. Sides are
                    // re-resolved first so late-inited or re-synced commanders
                    // are honoured.
                    if (_tick mod 8 == 0) then {
                        [_logic,"resolveSides"] call ALIVE_fnc_MilArtillery;
                        [_logic,"buildRegistry"] call ALIVE_fnc_MilArtillery;
                    };

                    // one settings line per module, once the served sides are known
                    if (_tick == 0 && {[_logic, "debug"] call ALIVE_fnc_MilArtillery}) then {
                        private _handled = _logic getVariable ["handledSides", []];
                        private _scopeText = if (count _handled > 0) then { str _handled } else { "every unclaimed side (nothing synced)" };
                        private _p = _logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]];
                        ["ALiVE MIL_ARTILLERY - module serving %1: intensity %2 -> cooldown %3+%4s dispersion %5m rounds %6 minContacts %7 concurrent %8 ledger %9 cbAcquire %10",
                            _scopeText, [_logic,"intensity"] call ALIVE_fnc_MilArtillery,
                            _p select 0, _p select 1, _p select 2, _p select 3, _p select 4, _p select 5, _p select 6, _p param [7, 0.10]] call ALiVE_fnc_dump;
                    };

                    private _queue = _logic getVariable ["requestQueue", []];
                    if (count _queue > 0) then {
                        private _request = _queue deleteAt 0;
                        _logic setVariable ["requestQueue", _queue];
                        [_logic,"processRequest",_request] call ALIVE_fnc_MilArtillery;
                    };

                    // counter-battery: age tracks and roll acquisition against
                    // fresh enemy fire every tick; convert surviving tracks into
                    // fire requests on a slower beat (~60-100s)
                    [_logic,"cbScan"] call ALIVE_fnc_MilArtillery;
                    if (_tick mod 4 == 0) then {
                        [_logic,"cbConvert"] call ALIVE_fnc_MilArtillery;
                    };

                    // dry batteries request resupply, capped so they don't all
                    // dispatch at once (reuses the concurrency dial)
                    private _resupplyCap = (_logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]]) select 5;
                    private _registry = _logic getVariable ["batteryRegistry", []];
                    private _resupplying = { ([_x,"state"] call ALiVE_fnc_hashGet) == "RESUPPLYING" } count _registry;
                    {
                        if (_resupplying >= _resupplyCap) exitWith {};
                        if (([_x,"state"] call ALiVE_fnc_hashGet) == "DRY") then {
                            [_logic,"requestResupply",_x] call ALIVE_fnc_MilArtillery;
                            _resupplying = _resupplying + 1;
                        };
                    } forEach _registry;

                    _tick = _tick + 1;
                    uiSleep (15 + random 10);
                };
            };
        };
    };

    // resupply -------------------------------------------------------------------

    // A battery has shot dry. Ask any LOGCOM module for a supply convoy (visible
    // immersion) AND arm a guaranteed fallback timer so the ledger always
    // refills even with no logistics module in the mission. The battery holds
    // in "RESUPPLYING" until refillBattery flips it back to IDLE - that state
    // keeps the DRY scan from re-raising it and processRequest from re-firing it.
    case "requestResupply": {

        private _record = _args;
        private _entityID = [_record,"entityID"] call ALiVE_fnc_hashGet;
        private _entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
        if (isNil "_entityProfile") exitWith {};

        private _pos = [_entityProfile,"position"] call ALiVE_fnc_hashGet;
        private _recSide = [_record,"side"] call ALiVE_fnc_hashGet;
        private _sideText = if (_recSide isEqualType west) then { str _recSide } else { toUpper _recSide };

        [_record,"state","RESUPPLYING"] call ALiVE_fnc_hashSet;

        private _profileSettings = _logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]];

        if ([_logic, "debug"] call MAINCLASS) then {
            ["ALiVE MIL_ARTILLERY - battery %1 is dry, requesting resupply to %2", _entityID, mapGridPosition _pos] call ALiVE_fnc_dump;
        };

        // ask for a convoy (a LOGCOM module answers with ARTY_RESUPPLY_ARRIVED)
        private _event = ['ARTY_RESUPPLY_REQUEST', [_pos, _sideText, "ARTY", format ["ARTY-%1", _entityID], _entityID], "MilArtillery"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;

        // guaranteed fallback: refill after a convoy-travel-scale delay whether
        // or not a truck ever arrives. refillBattery is idempotent, so if the
        // convoy arrives first this timer just no-ops.
        private _delay = (_profileSettings select 0) * 1.5 + random (_profileSettings select 1);
        [_logic, _entityID, _delay] spawn {
            params ["_logic","_entityID","_delay"];
            sleep _delay;
            [_logic,"refillBattery",_entityID] call ALIVE_fnc_MilArtillery;
        };
    };

    // Single owner of the RESUPPLYING -> IDLE transition. Idempotent: only the
    // FIRST caller (convoy arrival OR fallback timer) refills; the other no-ops.
    case "refillBattery": {

        private _entityID = _args;
        private _registry = _logic getVariable ["batteryRegistry", []];
        private _idx = _registry findIf { ([_x,"entityID"] call ALiVE_fnc_hashGet) == _entityID };
        if (_idx < 0) exitWith {};

        private _record = _registry select _idx;
        if (([_record,"state"] call ALiVE_fnc_hashGet) != "RESUPPLYING") exitWith {};

        private _profileSettings = _logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]];
        [_record,"rounds",_profileSettings select 6] call ALiVE_fnc_hashSet;
        [_record,"cooldownUntil",0] call ALiVE_fnc_hashSet;
        // deaf to counter-battery for one cooldown cycle: without this a
        // resupplied battery rejoins a counter-battery duel immediately and
        // two in-range batteries exchange fire forever on the resupply loop.
        // Organic contact requests are unaffected
        [_record,"cbDeafUntil", time + (_profileSettings select 0) + (_profileSettings select 1)] call ALiVE_fnc_hashSet;
        [_record,"state","IDLE"] call ALiVE_fnc_hashSet;

        if ([_logic, "debug"] call MAINCLASS) then {
            ["ALiVE MIL_ARTILLERY - battery %1 resupplied, %2 rounds back in the ledger", _entityID, _profileSettings select 6] call ALiVE_fnc_dump;
        };
    };

    // Debug/test: force an idle battery dry so the resupply path fires without
    // shooting it empty. Console: [ALIVE_MilArtillery,"debugDry"] call ALIVE_fnc_MilArtillery;
    case "debugDry": {
        private _record = [];
        {
            private _registry = _x getVariable ["batteryRegistry", []];
            private _idx = _registry findIf { ([_x,"state"] call ALiVE_fnc_hashGet) == "IDLE" };
            if (_idx >= 0) exitWith { _record = _registry select _idx; };
        } forEach (missionNamespace getVariable ["ALIVE_MilArtilleryInstances", [_logic]]);
        if (_record isEqualTo []) exitWith {
            ["ALiVE MIL_ARTILLERY - debugDry: no idle battery to dry out"] call ALiVE_fnc_dump;
        };
        [_record,"rounds",0] call ALiVE_fnc_hashSet;
        [_record,"state","DRY"] call ALiVE_fnc_hashSet;
        ["ALiVE MIL_ARTILLERY - debugDry: battery %1 forced dry - resupply dispatches on the next monitor tick", [_record,"entityID"] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump;
    };

    // Debug / test: force the nearest ammo'd battery to fire at a position.
    // Console:
    //   [ALIVE_MilArtillery, "debugStrike", screenToWorld [0.5,0.5]] call ALIVE_fnc_MilArtillery;
    //   [ALIVE_MilArtillery, "debugStrike", "strike"] call ALIVE_fnc_MilArtillery;          (marker name or label)
    //   [ALIVE_MilArtillery, "debugStrike", ["strike", east]] call ALIVE_fnc_MilArtillery;  (restrict to a side's batteries)
    case "debugStrike": {

        private _pos = _args;
        private _sideFilter = "";

        // optional [target, side] form - restrict the battery pick to one side
        if (_pos isEqualType [] && {count _pos == 2} && {(_pos select 1) isEqualType west}) then {
            _sideFilter = str (_pos select 1);
            _pos = _pos select 0;
        };

        // accept a marker string: resolve by marker variable-name first, then
        // fall back to matching the marker's text / description field (Eden
        // markers are often labelled but not named)
        if (_pos isEqualType "") then {
            private _mName = _pos;
            _pos = getMarkerPos _mName;
            if (_pos distance2D [0,0,0] < 10) then {
                private _hit = allMapMarkers select { markerText _x == _mName };
                _pos = if (count _hit > 0) then { getMarkerPos (_hit select 0) } else { [0,0,0] };
            };
            if (_pos distance2D [0,0,0] < 10) exitWith {
                ["ALiVE MIL_ARTILLERY - debugStrike: no marker named or labelled '%1' found. Check the marker, or aim and use screenToWorld [0.5,0.5]", _mName] call ALiVE_fnc_dump;
            };
        };

        if (!(_pos isEqualType []) || {count _pos < 2}) exitWith {
            ["ALiVE MIL_ARTILLERY - debugStrike: pass a position or marker name, e.g. [ALIVE_MilArtillery,'debugStrike',screenToWorld [0.5,0.5]] or [ALIVE_MilArtillery,'debugStrike','strike']"] call ALiVE_fnc_dump;
        };
        _pos set [2, 0];
        if (_pos distance2D [0,0,0] < 10) exitWith {
            ["ALiVE MIL_ARTILLERY - debugStrike: position is [0,0,0] - a named marker probably wasn't found. Pass a marker name/label string, or aim and use screenToWorld [0.5,0.5]"] call ALiVE_fnc_dump;
        };

        // nearest battery with rounds that isn't already mid-mission, in range
        private _best = [];
        private _bestDist = 1e9;
        // search every module instance so the console command works no matter
        // which module owns the side; the mission runs under the owning module
        private _bestLogic = _logic;
        private _searched = 0;
        {
            private _instLogic = _x;
            {
                private _rec = _x;
                _searched = _searched + 1;
                private _recSide = [_rec,"side",""] call ALiVE_fnc_hashGet;
                private _recSideText = if (_recSide isEqualType west) then { str _recSide } else { toUpper _recSide };
                if ((([_rec,"state"] call ALiVE_fnc_hashGet) in ["IDLE","DRY"])
                    && {([_rec,"rounds"] call ALiVE_fnc_hashGet) > 0}
                    && {_sideFilter == "" || {_recSideText == _sideFilter}}) then {
                    private _ep = [ALIVE_profileHandler, "getProfile", [_rec,"entityID"] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
                    if (!isNil "_ep") then {
                        private _d = ([_ep,"position"] call ALiVE_fnc_hashGet) distance2D _pos;
                        if (_d < (([_rec,"maxRange"] call ALiVE_fnc_hashGet) * 0.95)
                            && {_d > ([_rec,"minRange",300] call ALiVE_fnc_hashGet)}
                            && {_d < _bestDist}) then {
                            _best = _rec; _bestDist = _d; _bestLogic = _instLogic;
                        };
                    };
                };
            } forEach (_instLogic getVariable ["batteryRegistry", []]);
        } forEach (missionNamespace getVariable ["ALIVE_MilArtilleryInstances", [_logic]]);

        if (_best isEqualTo []) exitWith {
            ["ALiVE MIL_ARTILLERY - debugStrike: no battery with ammo in range of %1 (side filter '%3', %2 batteries searched)", _pos, _searched, _sideFilter] call ALiVE_fnc_dump;
        };

        ["ALiVE MIL_ARTILLERY - debugStrike: forcing battery %1 to fire at %2 (%3m)",
            [_best,"entityID"] call ALiVE_fnc_hashGet, _pos, round _bestDist] call ALiVE_fnc_dump;

        [_best,"state","FIRING"] call ALiVE_fnc_hashSet;
        _bestLogic setVariable ["activeMissions", (_bestLogic getVariable ["activeMissions", 0]) + 1];
        [_bestLogic, _best, "", _pos, true] spawn ALIVE_fnc_MilArtilleryFireMission;
    };

    case "processRequest": {

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _request = _args;
        _request params ["_targetID","_targetPos","_contacts","_reqSide","_reqFaction","_asym",["_cbRequest",false,[false]]];

        private _profileSettings = _logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]];
        _profileSettings params ["_cooldownBase","_cooldownJitter","_dispersion","_roundsPerMission","_minContacts","_maxConcurrent","_ledgerSize"];

        // targeting rules: no shells on lone scouts
        if (_contacts < _minContacts) exitWith {
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - request denied: %1 contact(s) near target, %2 required", _contacts, _minContacts] call ALiVE_fnc_dump;
            };
        };

        if ((_logic getVariable ["activeMissions", 0]) >= _maxConcurrent) exitWith {
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - request denied: %1 mission(s) already active", _logic getVariable ["activeMissions", 0]] call ALiVE_fnc_dump;
            };
        };

        // target must still exist; fire at its position as known at request time
        private _targetProfile = [ALIVE_profileHandler, "getProfile", _targetID] call ALIVE_fnc_profileHandler;
        if (isNil "_targetProfile") exitWith {
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - request denied: target profile %1 gone", _targetID] call ALiVE_fnc_dump;
            };
        };

        // pick the nearest eligible battery of the requesting side
        private _reqSideText = str _reqSide;
        private _best = [];
        private _bestDist = 1e9;
        {
            private _record = _x;
            private _state = [_record,"state"] call ALiVE_fnc_hashGet;
            private _recSide = [_record,"side"] call ALiVE_fnc_hashGet;
            private _sideMatches = if (_recSide isEqualType west) then { str _recSide == _reqSideText } else { toUpper _recSide == toUpper _reqSideText };

            if (_state == "IDLE"
                && {_sideMatches}
                && {time > ([_record,"cooldownUntil"] call ALiVE_fnc_hashGet)}
                && {([_record,"rounds"] call ALiVE_fnc_hashGet) > 0}
                && {!_asym || {([_record,"kind"] call ALiVE_fnc_hashGet) == "mortar"}}
                && {!_cbRequest || {time > ([_record,"cbDeafUntil",0] call ALiVE_fnc_hashGet)}}) then {

                private _entityProfile = [ALIVE_profileHandler, "getProfile", [_record,"entityID"] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
                if (!isNil "_entityProfile") then {
                    private _batteryPos = [_entityProfile,"position"] call ALiVE_fnc_hashGet;
                    private _dist = _batteryPos distance2D _targetPos;
                    if (_dist < (([_record,"maxRange"] call ALiVE_fnc_hashGet) * 0.95)
                        && {_dist > (([_record,"minRange",300] call ALiVE_fnc_hashGet) max 300)}
                        && {_dist < _bestDist}) then {
                        _best = _record;
                        _bestDist = _dist;
                    };
                };
            };
        } forEach (_logic getVariable ["batteryRegistry", []]);

        if (_best isEqualTo []) exitWith {
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - request denied: no eligible battery in range of %1 (side %2, asym %3)", _targetPos, _reqSideText, _asym] call ALiVE_fnc_dump;
            };
        };

        // no players anywhere near either end: nothing would be seen or heard.
        // Resolve the mission virtually - casualties on the ledger, ammunition
        // spent, full cooldown, counter-battery event - with no spawning at all
        private _entityProfile = [ALIVE_profileHandler, "getProfile", [_best,"entityID"] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
        if (isNil "_entityProfile") exitWith {
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - request denied: battery %1 crew profile gone", [_best,"entityID"] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump;
            };
        };
        private _batteryPos = [_entityProfile,"position"] call ALiVE_fnc_hashGet;
        private _humanPlayers = allPlayers - entities "HeadlessClient_F";
        if (((_humanPlayers findIf { _x distance2D _targetPos < 3000 }) == -1)
            && {(_humanPlayers findIf { _x distance2D _batteryPos < 3000 }) == -1}) exitWith {
            [_logic,"virtualFireMission",[_best, _targetID, _targetProfile, _targetPos, _batteryPos, _profileSettings, _entityProfile, _cbRequest]] call MAINCLASS;
        };

        [_best,"state","FIRING"] call ALiVE_fnc_hashSet;
        _logic setVariable ["activeMissions", (_logic getVariable ["activeMissions", 0]) + 1];

        [_logic, _best, _targetID, _targetPos] spawn ALIVE_fnc_MilArtilleryFireMission;
    };

    // virtual resolution -------------------------------------------------------

    // No player can see or hear this mission, so it resolves on the ledgers
    // instead of in the engine: calibrated casualties on the target profile,
    // ammunition and a full cooldown spent, and the enemy counter-battery watch
    // fed exactly as a real volley would. No spawning, no sleeps, no warnings -
    // there is nobody to warn
    case "virtualFireMission": {

        _args params ["_record","_targetID","_targetProfile","_targetPos","_batteryPos","_settings","_batteryEntityProfile","_cbRequest"];
        _settings params ["_cooldownBase","_cooldownJitter","_dispersion","_roundsPerMission"];

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _entityID = [_record,"entityID"] call ALiVE_fnc_hashGet;
        private _kind = [_record,"kind","gun"] call ALiVE_fnc_hashGet;
        private _vehicleIDs = [_record,"vehicleIDs",[]] call ALiVE_fnc_hashGet;
        private _recSide = [_record,"side"] call ALiVE_fnc_hashGet;
        private _sideText = if (_recSide isEqualType west) then { toUpper str _recSide } else { toUpper _recSide };

        // authored volley model, calibrated so an unobserved mission matches
        // what a real one typically achieves: prune 1-3 of a squad, rarely
        // wipe; soft vehicles sometimes die, armor is nearly immune
        private _n = _roundsPerMission + 1;
        private _kindF = switch (_kind) do { case "mortar": {0.75}; case "rocket": {1.25}; default {1.0} };
        private _pRound = 0.04 * ((75 / (_dispersion max 1)) ^ 2) * _kindF;
        private _pKill = (1 - (1 - _pRound) ^ _n) min 0.5;

        // real missions abort when friendlies sit inside the beaten zone -
        // mirror that over virtual positions before any casualties are rolled
        private _ffRadius = (_dispersion max 50) + 150;
        private _sideObj = [_sideText] call ALIVE_fnc_sideTextToObject;
        private _ffBlocked = false;
        {
            if (!_ffBlocked && {_x isEqualType []}) then {
                private _pPos = [_x,"position",[0,0,0]] call ALiVE_fnc_hashGet;
                if (_pPos distance2D _targetPos < _ffRadius) then {
                    private _pSide = [_x,"side",""] call ALiVE_fnc_hashGet;
                    private _pSideObj = if (_pSide isEqualType west) then { _pSide } else { [_pSide] call ALIVE_fnc_sideTextToObject };
                    if ([_pSideObj, _sideObj] call BIS_fnc_sideIsFriendly) then { _ffBlocked = true; };
                };
            };
        } forEach (([ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet) select 2);
        if (_ffBlocked) exitWith {
            [_record,"cooldownUntil", time + (_cooldownBase / 2)] call ALiVE_fnc_hashSet;
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - virtual mission aborted: friendlies inside the impact area at %1", _targetPos] call ALiVE_fnc_dump;
            };
        };

        private _fnc_vehKillChance = {
            private _hard = (toLower _this) in ["tank","armored"];
            private _p = (if (_hard) then {0.03} else {0.18}) * ((75 / (_dispersion max 1)) ^ 2) * _kindF * (_n / 7);
            _p min (if (_hard) then {0.10} else {0.40})
        };

        // destroying a vehicle profile takes its crew with it and, when it was
        // the commanding entity's last vehicle (or crew and vehicles are both
        // gone), the entity too. Returns true when an entity was lost
        private _fnc_killVehicleProfile = {
            params ["_vehProfile","_vehID"];
            private _entityLost = false;
            // static weapons have no driver seat, so no "in command" links -
            // the crew entity is the assignment key on the vehicle instead
            private _cmdEntities = +([_vehProfile,"entitiesInCommandOf",[]] call ALiVE_fnc_hashGet);
            if (count _cmdEntities == 0) then {
                private _vAssignments = [_vehProfile,"vehicleAssignments",[[],[],[]]] call ALiVE_fnc_hashGet;
                if (_vAssignments isEqualType [] && {count _vAssignments > 1}) then {
                    _cmdEntities = +(_vAssignments select 1);
                };
            };
            {
                private _cmdEID = _x;
                private _cmdE = [ALIVE_profileHandler, "getProfile", _cmdEID] call ALIVE_fnc_profileHandler;
                if (!isNil "_cmdE") then {
                    private _lastVeh = ([_cmdE,"vehiclesInCommandOf",[]] call ALiVE_fnc_hashGet) isEqualTo [_vehID];
                    private _assignment = [([_cmdE,"vehicleAssignments"] call ALiVE_fnc_hashGet), _vehID] call ALiVE_fnc_hashGet;
                    private _crewIdx = [];
                    if (!isNil "_assignment") then {
                        // the crew dies with its vehicle. Assignment position
                        // groups hold ascending unit indexes - flatten and
                        // remove in DESCENDING order so every queued index
                        // stays valid as the profile arrays shrink
                        { _crewIdx append _x } forEach (_assignment param [2, [], [[]]]);
                        _crewIdx sort false;
                        { [_cmdE,"removeUnit",_x] call ALIVE_fnc_profileEntity } forEach _crewIdx;
                    };
                    [_cmdE, _vehProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                    if (count _crewIdx > 0) then {
                        // removeUnit shifted the entity's unit arrays down -
                        // re-base the surviving guns' crew indexes or a later
                        // kill on the same battery removes the wrong soldiers
                        private _assignments = [_cmdE,"vehicleAssignments"] call ALiVE_fnc_hashGet;
                        if (!isNil "_assignments" && {_assignments isEqualType []} && {count _assignments > 1}) then {
                            {
                                private _otherAssign = [_assignments, _x] call ALiVE_fnc_hashGet;
                                if (!isNil "_otherAssign") then {
                                    {
                                        private _group = _x;
                                        {
                                            private _old = _x;
                                            _group set [_forEachIndex, _old - ({ _x < _old } count _crewIdx)];
                                        } forEach _group;
                                    } forEach (_otherAssign param [2, [], [[]]]);
                                };
                            } forEach +(_assignments select 1);
                        };
                    };
                    private _vehsLeft = [_cmdE,"vehiclesInCommandOf",[]] call ALiVE_fnc_hashGet;
                    if (_lastVeh || {(count ([_cmdE,"unitClasses",[]] call ALiVE_fnc_hashGet)) == 0 && {_vehsLeft isEqualTo []}}) then {
                        // same payload the profile simulator pushes for its
                        // own virtual kills
                        private _event = ['PROFILE_KILLED', [
                            [_cmdE,"position"] call ALiVE_fnc_hashGet,
                            [_cmdE,"faction"] call ALiVE_fnc_hashGet,
                            [_cmdE,"side"] call ALiVE_fnc_hashGet,
                            _sideText,
                            _cmdE,
                            _batteryEntityProfile,
                            _cmdEID,
                            [_cmdE,"objectType"] call ALiVE_fnc_hashGet
                        ], "MilArtillery"] call ALIVE_fnc_event;
                        [ALIVE_eventLog,"addEvent",_event] call ALIVE_fnc_eventLog;
                        [ALIVE_profileHandler,"unregisterProfile",_cmdE] call ALIVE_fnc_profileHandler;
                        _entityLost = true;
                    };
                };
            } forEach _cmdEntities;
            [ALIVE_profileHandler,"unregisterProfile",_vehProfile] call ALIVE_fnc_profileHandler;
            _entityLost
        };

        private _tType = [_targetProfile,"type",""] call ALiVE_fnc_hashGet;
        private _tActive = [_targetProfile,"active",false] call ALiVE_fnc_hashGet;
        private _resultText = "no casualties";
        private _gunKills = 0;

        if (_tType == "vehicle") then {

            private _ot = toLower ([_targetProfile,"objectType",""] call ALiVE_fnc_hashGet);
            if (random 1 < (_ot call _fnc_vehKillChance)) then {
                if (_tActive) then {
                    // live vehicle: the engine and the profile killed handlers
                    // do the bookkeeping
                    private _veh = [_targetProfile,"vehicle"] call ALiVE_fnc_hashGet;
                    if (!isNil "_veh" && {!isNull _veh} && {alive _veh}) then {
                        [_veh, 1] remoteExec ["setDamage", _veh];
                    };
                } else {
                    if ([_targetProfile, _targetID] call _fnc_killVehicleProfile) then {
                        _resultText = format ["%1 destroyed, crew entity lost with it", _ot];
                    };
                };
                if (_resultText == "no casualties") then { _resultText = format ["%1 destroyed", _ot]; };
            } else {
                _resultText = format ["%1 survived the volley", _ot];
            };

        } else {

            // counter-battery missions roll the enemy GUNS before the crew -
            // gun attrition is what actually silences a battery, and killing
            // guns first keeps the crew-unassignment bookkeeping correct
            if (_cbRequest) then {
                // static-weapon batteries (towed guns, mortars) have no driver
                // seat, so nothing is "in command of" them - fall back to the
                // assignment keys, the same derivation buildRegistry uses
                private _targetGuns = +([_targetProfile,"vehiclesInCommandOf",[]] call ALiVE_fnc_hashGet);
                if (count _targetGuns == 0) then {
                    private _tAssignments = [_targetProfile,"vehicleAssignments",[[],[],[]]] call ALiVE_fnc_hashGet;
                    if (_tAssignments isEqualType [] && {count _tAssignments > 1}) then {
                        _targetGuns = +(_tAssignments select 1);
                    };
                };
                {
                    private _gunID = _x;
                    private _gunProfile = [ALIVE_profileHandler, "getProfile", _gunID] call ALIVE_fnc_profileHandler;
                    if (!isNil "_gunProfile") then {
                        private _got = toLower ([_gunProfile,"objectType",""] call ALiVE_fnc_hashGet);
                        if (random 1 < (_got call _fnc_vehKillChance)) then {
                            if ([_gunProfile,"active",false] call ALiVE_fnc_hashGet) then {
                                private _gVeh = [_gunProfile,"vehicle"] call ALiVE_fnc_hashGet;
                                if (!isNil "_gVeh" && {!isNull _gVeh} && {alive _gVeh}) then {
                                    [_gVeh, 1] remoteExec ["setDamage", _gVeh];
                                    _gunKills = _gunKills + 1;
                                };
                            } else {
                                [_gunProfile, _gunID] call _fnc_killVehicleProfile;
                                _gunKills = _gunKills + 1;
                            };
                        };
                    };
                } forEach _targetGuns;
            };

            // the last-gun rule may have taken the crew entity with it
            if (isNil { [ALIVE_profileHandler, "getProfile", _targetID] call ALIVE_fnc_profileHandler }) then {
                _resultText = "crew entity lost with its guns";
            } else {

                private _unitClasses = [_targetProfile,"unitClasses",[]] call ALiVE_fnc_hashGet;
                if (count _unitClasses == 0) then {
                    // a zero-unit profile would soak fire missions forever -
                    // the profile simulator treats these as killed on contact
                    [ALIVE_profileHandler,"unregisterProfile",_targetProfile] call ALIVE_fnc_profileHandler;
                    if (_debug) then {
                        ["ALiVE MIL_ARTILLERY - virtual mission: empty target profile %1 removed", _targetID] call ALiVE_fnc_dump;
                    };
                } else {

                    private _squadSize = count _unitClasses;
                    private _kills = [];
                    private _wounds = [];
                    {
                        private _roll = random 1;
                        if (_roll < _pKill) then {
                            _kills pushBack _forEachIndex;
                        } else {
                            if (_roll < _pKill * 2) then { _wounds pushBack _forEachIndex; };
                        };
                    } forEach _unitClasses;

                    if (_tActive) then {
                        // live squad: resolve every victim object BEFORE the
                        // first kill - the profile killed handlers delete from
                        // the same live units array mid-loop
                        private _units = [_targetProfile,"units",[]] call ALiVE_fnc_hashGet;
                        private _kVictims = _kills apply { _units param [_x, objNull] };
                        private _wVictims = _wounds apply { _units param [_x, objNull] };
                        { if (!isNull _x && {alive _x}) then { [_x, 1] remoteExec ["setDamage", _x]; }; } forEach _kVictims;
                        { if (!isNull _x && {alive _x}) then { [_x, (damage _x + random 0.5) min 0.95] remoteExec ["setDamage", _x]; }; } forEach _wVictims;
                        if (count _kills > 0) then { _resultText = format ["%1 of %2 infantry killed", count _kills, _squadSize]; };
                    } else {
                        private _damages = +([_targetProfile,"damages",[]] call ALiVE_fnc_hashGet);
                        if (count _damages != _squadSize) then {
                            _damages = [];
                            for "_i" from 1 to _squadSize do { _damages pushBack 0; };
                        };
                        { _damages set [_x, ((_damages select _x) + random 0.5) min 0.95] } forEach _wounds;

                        private _wiped = false;
                        reverse _kills;   // descending: every index stays valid
                        {
                            _damages deleteAt _x;
                            _wiped = !([_targetProfile,"removeUnit",_x] call ALIVE_fnc_profileEntity);
                        } forEach _kills;

                        if (_wiped) then {
                            private _event = ['PROFILE_KILLED', [
                                [_targetProfile,"position"] call ALiVE_fnc_hashGet,
                                [_targetProfile,"faction"] call ALiVE_fnc_hashGet,
                                [_targetProfile,"side"] call ALiVE_fnc_hashGet,
                                _sideText,
                                _targetProfile,
                                _batteryEntityProfile,
                                _targetID,
                                [_targetProfile,"objectType"] call ALiVE_fnc_hashGet
                            ], "MilArtillery"] call ALIVE_fnc_event;
                            [ALIVE_eventLog,"addEvent",_event] call ALIVE_fnc_eventLog;
                            [ALIVE_profileHandler,"unregisterProfile",_targetProfile] call ALIVE_fnc_profileHandler;
                            _resultText = format ["squad of %1 wiped out", _squadSize];
                        } else {
                            [_targetProfile,"damages",_damages] call ALiVE_fnc_hashSet;
                            if (count _kills > 0) then {
                                _resultText = format ["%1 of %2 infantry killed", count _kills, _squadSize];
                            };
                        };
                    };
                };
            };

            if (_gunKills > 0) then {
                _resultText = format ["%1, %2 gun(s) destroyed", _resultText, _gunKills];
            };
        };

        // the virtual volley is still a firing battery - feed the counter-
        // battery watch the same tuple a real volley's fallback would push
        if (isNil "ALIVE_artyShellEvents") then { ALIVE_artyShellEvents = []; };
        private _events = ALIVE_artyShellEvents;
        _events pushBack [_vehicleIDs param [0, ""], _batteryPos, _sideText, time, _n, time];
        while {count _events > 30} do { _events deleteAt 0; };
        if (_debug) then {
            ["ALiVE MIL_ARTILLERY - counter-battery: virtual fire event recorded for battery %1 (%2 shell(s))", _entityID, _n] call ALiVE_fnc_dump;
        };

        // parity bookkeeping: ammunition, state, full cooldown plus a nominal
        // mission duration (a real mission runs 2-4 minutes before its cooldown
        // stamp - without the extra term virtual batteries would fire faster)
        private _roundsLeft = (([_record,"rounds"] call ALiVE_fnc_hashGet) - _n) max 0;
        [_record,"rounds",_roundsLeft] call ALiVE_fnc_hashSet;
        if (_roundsLeft <= 0) then {
            [_record,"state","DRY"] call ALiVE_fnc_hashSet;
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - battery %1 is out of ammunition and falls silent", _entityID] call ALiVE_fnc_dump;
            };
        };
        [_record,"cooldownUntil", time + _cooldownBase + random _cooldownJitter + 120 + random 120] call ALiVE_fnc_hashSet;

        if (_debug) then {
            if (_tType == "vehicle") then {
                ["ALiVE MIL_ARTILLERY - virtual mission detail: %1 shell(s), dispersion %2m, kind %3 -> vehicle kill chance %4", _n, _dispersion, _kind,
                    (toLower ([_targetProfile,"objectType",""] call ALiVE_fnc_hashGet)) call _fnc_vehKillChance] call ALiVE_fnc_dump;
            } else {
                ["ALiVE MIL_ARTILLERY - virtual mission detail: %1 shell(s), dispersion %2m, kind %3 -> per-unit kill chance %4", _n, _dispersion, _kind, _pKill] call ALiVE_fnc_dump;
            };
        };
        ["ALiVE MIL_ARTILLERY - virtual fire mission: battery %1 (%2) -> %3 at grid %4: %5. %6 round(s) left in the ledger",
            _entityID, _kind, _targetID, mapGridPosition _targetPos, _resultText, _roundsLeft] call ALiVE_fnc_dump;
    };

    // counter-battery --------------------------------------------------------

    // Roll preset-scaled acquisition against fresh enemy fire events and keep
    // a short ledger of located enemy batteries (hot tracks). Tracks age out
    // after 180s unless refreshed by more fire. Detection is per commander:
    // every side this module fields guns for rolls its own dice against every
    // enemy volley - two hostile sides may both locate the same battery
    case "cbScan": {

        private _profile = _logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]];
        private _pAcquire = _profile param [7, 0.10];
        private _contactsList = _logic getVariable ["cbContacts", []];
        // stamp is taken BEFORE the events read: shells recorded while this
        // pass is suspended must still satisfy _evtAt > _lastScan next tick
        private _scanStamp = time;
        private _events = missionNamespace getVariable ["ALIVE_artyShellEvents", []];
        private _lastScan = _logic getVariable ["cbLastScan", 0];
        private _rolled = _logic getVariable ["cbRolled", []];
        private _debug = [_logic, "debug"] call MAINCLASS;

        // sides this module can actually answer for: the sides of its own
        // registered batteries (a side with no guns cannot counter-fire),
        // scope-filtered so arbitration between modules is honoured
        private _detSides = [];
        {
            private _s = [_x,"side"] call ALiVE_fnc_hashGet;
            private _sText = if (_s isEqualType west) then { toUpper str _s } else { toUpper _s };
            if (!(_sText in _detSides) && {[_logic,"sideInScope",_sText] call MAINCLASS}) then {
                _detSides pushBack _sText;
            };
        } forEach (_logic getVariable ["batteryRegistry", []]);

        if (_pAcquire > 0 && {count _detSides > 0} && {count _events > 0}) then {
            {
                _x params ["_evtPid","_evtPos","_evtSide","_evtAt","_evtShots","_evtBorn"];
                if (_evtAt > _lastScan) then {
                    // the watch refreshes a volley's event per shell, so this
                    // event may come around several times while it grows. Roll
                    // only the shells not rolled before - re-rolling the
                    // cumulative count would inflate acquisition well past the
                    // designed 1-(1-p)^shells curve. Ledger is per volley
                    // (profileID + volley id) so a battery's NEXT volley is
                    // not masked by the last one's ledger entry
                    private _rKey = format ["%1#%2", _evtPid, _evtBorn];
                    private _rIdx = _rolled findIf { (_x select 0) == _rKey };
                    private _newShots = _evtShots - (if (_rIdx >= 0) then { (_rolled select _rIdx) select 1 } else { 0 });
                    if (_newShots > 0) then {
                    if (_rIdx >= 0) then {
                        (_rolled select _rIdx) set [1, _evtShots];
                    } else {
                        _rolled pushBack [_rKey, _evtShots];
                    };
                    private _evtSideObj = [_evtSide] call ALIVE_fnc_sideTextToObject;
                    {
                        private _detSide = _x;
                        // cumulative chance over the fresh shells: 1-(1-p)^n
                        if (!([[_detSide] call ALIVE_fnc_sideTextToObject, _evtSideObj] call BIS_fnc_sideIsFriendly)
                            && {random 1 < (1 - (1 - _pAcquire) ^ _newShots)}) then {

                            // resolve the shooter to something processRequest can
                            // target: its battery entity when any module registers
                            // it, else the firing vehicle's own profile
                            private _targetID = _evtPid;
                            {
                                private _reg = _x getVariable ["batteryRegistry", []];
                                private _rIdx = _reg findIf { _evtPid in ([_x,"vehicleIDs",[]] call ALiVE_fnc_hashGet) };
                                if (_rIdx >= 0) exitWith { _targetID = [(_reg select _rIdx),"entityID"] call ALiVE_fnc_hashGet; };
                            } forEach (missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]);

                            // counter-battery intel, not psychic - same fuzz as
                            // the player-facing reveal
                            private _fuzzedPos = _evtPos getPos [50 + random 150, random 360];
                            private _hits = 1;
                            private _cIdx = _contactsList findIf { (_x select 0) == _targetID && {(_x select 2) == _detSide} };
                            if (_cIdx >= 0) then {
                                private _c = _contactsList select _cIdx;
                                _c set [1, _fuzzedPos];
                                _c set [3, time];
                                _c set [4, (_c select 4) + 1];
                                _hits = _c select 4;
                            } else {
                                if (count _contactsList < 10) then {
                                    _contactsList pushBack [_targetID, _fuzzedPos, _detSide, time, 1];
                                } else {
                                    _hits = 0;
                                };
                            };
                            if (_debug && {_hits > 0}) then {
                                ["ALiVE MIL_ARTILLERY - counter-battery: %1 acquired enemy battery %2 at grid %3 (hits %4)", _detSide, _targetID, mapGridPosition _fuzzedPos, _hits] call ALiVE_fnc_dump;
                            };
                        };
                    } forEach _detSides;
                    };
                };
            } forEach _events;
            _logic setVariable ["cbLastScan", _scanStamp];
        };

        // forget roll ledgers whose event has pruned away
        _rolled = _rolled select {
            private _k = _x select 0;
            (_events findIf { format ["%1#%2", _x select 0, _x param [5, 0]] == _k }) >= 0
        };
        _logic setVariable ["cbRolled", _rolled];

        // age out cold tracks; drop tracks whose target no longer exists
        {
            private _gone = isNil { [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler };
            if ((time - (_x select 3) > 180) || _gone) then {
                if (_debug) then {
                    ["ALiVE MIL_ARTILLERY - counter-battery: track on %1 went cold", _x select 0] call ALiVE_fnc_dump;
                };
                _contactsList set [_forEachIndex, "x"];
            };
        } forEach _contactsList;
        _contactsList = _contactsList - ["x"];
        _logic setVariable ["cbContacts", _contactsList];
    };

    // Turn hot tracks into fire requests through the normal throttled pipeline.
    // A track is deleted only when its request is actually queued; a track that
    // loses the queue cap or the concurrency race stays hot and retries until
    // it ages out - located batteries keep being answered while they keep firing
    case "cbConvert": {

        private _contactsList = _logic getVariable ["cbContacts", []];
        if (count _contactsList > 0) then {

            private _profile = _logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]];
            private _minContacts = _profile select 4;
            private _maxConcurrent = _profile select 5;
            private _queue = _logic getVariable ["requestQueue", []];
            private _asymSides = _logic getVariable ["asymSides", []];
            private _keep = [];
            // count this pass's own pushes: activeMissions only moves when the
            // monitor drains the queue, so without this a single pass would
            // batch-queue past the concurrency cap and the surplus would be
            // denied downstream AFTER the tracks were already deleted
            private _pending = 0;
            // synced modules learn asymmetric sides from their commanders; an
            // unsynced module looks the commander up directly so insurgent
            // counter-battery still gets the mortars-only rule
            private _fnc_detSideIsAsym = {
                private _side = _this;
                if (_side in _asymSides) exitWith { true };
                ((missionNamespace getVariable ["OPCOM_instances", []]) findIf {
                    _x isEqualType []
                    && {toUpper ([_x,"side",""] call ALiVE_fnc_hashGet) == _side}
                    && {([_x,"controltype",""] call ALiVE_fnc_hashGet) == "asymmetric"}
                }) >= 0
            };

            {
                _x params ["_targetID","_fuzzedPos","_detSide"];
                private _targetProfile = [ALIVE_profileHandler, "getProfile", _targetID] call ALIVE_fnc_profileHandler;
                if (!isNil "_targetProfile") then {
                    private _queued = (_queue findIf { (_x select 0) == _targetID && {(toUpper str (_x select 3)) == _detSide} }) >= 0;
                    if (_queued || {count _queue >= 12} || {((_logic getVariable ["activeMissions", 0]) + _pending) >= _maxConcurrent}) then {
                        _keep pushBack _x;
                    } else {
                        // own faction is cosmetic (processRequest never reads it)
                        private _ownFaction = "";
                        {
                            private _s = [_x,"side"] call ALiVE_fnc_hashGet;
                            private _sText = if (_s isEqualType west) then { toUpper str _s } else { toUpper _s };
                            if (_sText == _detSide) exitWith { _ownFaction = [_x,"faction",""] call ALiVE_fnc_hashGet; };
                        } forEach (_logic getVariable ["batteryRegistry", []]);

                        // a located firing battery is never a lone scout - pass
                        // the selectivity floor so the lone-target rule doesn't
                        // veto counter-battery; frequency is governed by the
                        // acquisition roll, not the contact count
                        // trailing true marks a counter-battery request - freshly
                        // resupplied batteries refuse those for one cooldown cycle
                        _queue pushBack [_targetID, _fuzzedPos, _minContacts, [_detSide] call ALIVE_fnc_sideTextToObject, _ownFaction, _detSide call _fnc_detSideIsAsym, true];
                        _pending = _pending + 1;
                        ["ALiVE MIL_ARTILLERY - counter-battery target queued: %1 answering enemy battery %2 at grid %3", _detSide, _targetID, mapGridPosition _fuzzedPos] call ALiVE_fnc_dump;
                    };
                };
            } forEach _contactsList;

            _logic setVariable ["cbContacts", _keep];
            _logic setVariable ["requestQueue", _queue];
        };
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ARTILLERY - output",_result);

if (isNil "_result") then { nil } else { _result };
