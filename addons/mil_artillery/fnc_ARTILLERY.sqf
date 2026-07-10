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

private ["_logic","_operation","_args","_result"];

TRACE_1("ARTILLERY - input",_this);

_logic = param [0, objNull];
_operation = param [1, ""];
_args = param [2, objNull];
_result = nil;

switch(_operation) do {

    case "init": {

        if (isServer) then {

            // module is a server-side singleton
            if (!isNil "ALIVE_MilArtillery") exitWith {
                ["ALiVE MIL_ARTILLERY - duplicate module ignored, one module serves every AI commander"] call ALiVE_fnc_dump;
            };
            ALIVE_MilArtillery = _logic;

            // event log dispatch resolves the handler through these
            _logic setVariable ["super", QUOTE(SUPERCLASS)];
            _logic setVariable ["class", QUOTE(MAINCLASS)];

            private _debug = [_logic, "debug"] call MAINCLASS;
            private _intensity = [_logic, "intensity"] call MAINCLASS;

            // single dial scaling every throttle:
            // [cooldown base, cooldown jitter, dispersion m, rounds per mission, min contacts, max concurrent, rounds ledger]
            private _profile = switch (_intensity) do {
                case "LOW":  { [600, 120, 100, 4, 4, 1, 60] };
                case "HIGH": { [300, 120, 50, 8, 2, 2, 120] };
                default      { [420, 120, 75, 6, 3, 1, 90] };
            };
            _logic setVariable ["intensityProfile", _profile];
            _logic setVariable ["batteryRegistry", []];
            _logic setVariable ["requestQueue", []];
            _logic setVariable ["activeMissions", 0];

            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - init, intensity %1 -> cooldown %2+%3s dispersion %4m rounds %5 minContacts %6 concurrent %7 ledger %8",
                    _intensity, _profile select 0, _profile select 1, _profile select 2, _profile select 3, _profile select 4, _profile select 5, _profile select 6] call ALiVE_fnc_dump;
            };

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

    // battery registry ---------------------------------------------------------

    case "buildRegistry": {

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _registry = _logic getVariable ["batteryRegistry", []];
        private _ledgerSize = (_logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]]) select 6;

        private _knownEntityIDs = [];
        {
            _knownEntityIDs pushBack ([_x,"entityID"] call ALiVE_fnc_hashGet);
        } forEach _registry;

        // drop records whose crew profile no longer exists
        private _live = [];
        {
            private _entityID = [_x,"entityID"] call ALiVE_fnc_hashGet;
            private _entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
            if (!isNil "_entityProfile") then {
                _live pushBack _x;
            } else {
                if (_debug) then {
                    ["ALiVE MIL_ARTILLERY - battery %1 lost (crew profile gone), removed from registry", _entityID] call ALiVE_fnc_dump;
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

                    if (count _entities > 0) then {
                        private _entityID = _entities select 0;

                        if !(_entityID in _knownEntityIDs) then {
                            // new battery - collect every artillery vehicle this crew commands
                            private _entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;

                            if (!isNil "_entityProfile") then {
                                private _vehicleIDs = [];
                                {
                                    private _vp = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                    if (!isNil "_vp") then {
                                        private _vc = [_vp,"vehicleClass",""] call ALiVE_fnc_hashGet;
                                        if (_vc != "" && {[_vc] call ALIVE_fnc_isArtillery}) then {
                                            _vehicleIDs pushBack _x;
                                        };
                                    };
                                } forEach ([_entityProfile,"vehiclesInCommandOf",[]] call ALiVE_fnc_hashGet);

                                if (count _vehicleIDs > 0) then {
                                    private _kind = "gun";
                                    private _range = DEFAULT_RANGE_GUN;
                                    if (_class isKindOf "StaticMortar") then {
                                        _kind = "mortar";
                                        _range = DEFAULT_RANGE_MORTAR;
                                    } else {
                                        private _ordnance = _class call ALiVE_fnc_GetArtyRounds;
                                        if ("ROCKETS" in _ordnance && {!("HE" in _ordnance)}) then {
                                            _kind = "rocket";
                                            _range = DEFAULT_RANGE_ROCKET;
                                        };
                                    };

                                    private _record = [] call ALIVE_fnc_hashCreate;
                                    [_record,"entityID",_entityID] call ALiVE_fnc_hashSet;
                                    [_record,"vehicleIDs",_vehicleIDs] call ALiVE_fnc_hashSet;
                                    [_record,"side",[_entityProfile,"side",""] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;
                                    [_record,"faction",[_entityProfile,"faction",""] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;
                                    [_record,"kind",_kind] call ALiVE_fnc_hashSet;
                                    [_record,"maxRange",_range] call ALiVE_fnc_hashSet;
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
            if (_count == 0) then {
                ["ALiVE MIL_ARTILLERY - no artillery batteries found. Enable 'Place artillery units' on a placement module (or place profiled artillery in the editor) and give the faction artillery groups. Still watching for late placements."] call ALiVE_fnc_dump;
            } else {
                ["ALiVE MIL_ARTILLERY - %1 artillery batteries available:", _count] call ALiVE_fnc_dump;
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
                    // request into the module's own queue immediately
                    private _queue = _logic getVariable ["requestQueue", []];
                    if (count _queue < 12) then {
                        _queue pushBack ([_event, "data"] call ALIVE_fnc_hashGet);
                        _logic setVariable ["requestQueue", _queue];
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

                ["ALiVE MIL_ARTILLERY - monitor started, scanning for artillery batteries"] call ALiVE_fnc_dump;

                private _tick = 0;
                while {!isNull _logic} do {
                    // rebuild on the first pass and periodically after, so late
                    // placements and editor batteries are picked up
                    if (_tick mod 8 == 0) then {
                        [_logic,"buildRegistry"] call ALIVE_fnc_MilArtillery;
                    };

                    private _queue = _logic getVariable ["requestQueue", []];
                    if (count _queue > 0) then {
                        private _request = _queue deleteAt 0;
                        _logic setVariable ["requestQueue", _queue];
                        [_logic,"processRequest",_request] call ALIVE_fnc_MilArtillery;
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

        private _ledgerSize = (_logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]]) select 6;
        [_record,"rounds",_ledgerSize] call ALiVE_fnc_hashSet;
        [_record,"cooldownUntil",0] call ALiVE_fnc_hashSet;
        [_record,"state","IDLE"] call ALiVE_fnc_hashSet;

        if ([_logic, "debug"] call MAINCLASS) then {
            ["ALiVE MIL_ARTILLERY - battery %1 resupplied, %2 rounds back in the ledger", _entityID, _ledgerSize] call ALiVE_fnc_dump;
        };
    };

    // Debug/test: force an idle battery dry so the resupply path fires without
    // shooting it empty. Console: [ALIVE_MilArtillery,"debugDry"] call ALIVE_fnc_MilArtillery;
    case "debugDry": {
        private _registry = _logic getVariable ["batteryRegistry", []];
        private _idx = _registry findIf { ([_x,"state"] call ALiVE_fnc_hashGet) == "IDLE" };
        if (_idx < 0) exitWith {
            ["ALiVE MIL_ARTILLERY - debugDry: no idle battery to dry out"] call ALiVE_fnc_dump;
        };
        private _record = _registry select _idx;
        [_record,"rounds",0] call ALiVE_fnc_hashSet;
        [_record,"state","DRY"] call ALiVE_fnc_hashSet;
        ["ALiVE MIL_ARTILLERY - debugDry: battery %1 forced dry - resupply dispatches on the next monitor tick", [_record,"entityID"] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump;
    };

    // Debug / test: force the nearest ammo'd battery to fire at a position,
    // skipping the cooldown + minimum-contact gates but keeping range and the
    // friendly-fire abort so the strike still behaves realistically. Console:
    //   [ALIVE_MilArtillery, "debugStrike", screenToWorld [0.5,0.5]] call ALIVE_fnc_MilArtillery;
    //   [ALIVE_MilArtillery, "debugStrike", getMarkerPos "strike"]   call ALIVE_fnc_MilArtillery;
    case "debugStrike": {

        private _pos = _args;

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
        {
            private _rec = _x;
            if ((([_rec,"state"] call ALiVE_fnc_hashGet) in ["IDLE","DRY"])
                && {([_rec,"rounds"] call ALiVE_fnc_hashGet) > 0}) then {
                private _ep = [ALIVE_profileHandler, "getProfile", [_rec,"entityID"] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
                if (!isNil "_ep") then {
                    private _d = ([_ep,"position"] call ALiVE_fnc_hashGet) distance2D _pos;
                    if (_d < (([_rec,"maxRange"] call ALiVE_fnc_hashGet) * 0.95) && {_d < _bestDist}) then {
                        _best = _rec; _bestDist = _d;
                    };
                };
            };
        } forEach (_logic getVariable ["batteryRegistry", []]);

        if (_best isEqualTo []) exitWith {
            ["ALiVE MIL_ARTILLERY - debugStrike: no battery with ammo in range of %1 (registry has %2)", _pos, count (_logic getVariable ["batteryRegistry", []])] call ALiVE_fnc_dump;
        };

        ["ALiVE MIL_ARTILLERY - debugStrike: forcing battery %1 to fire at %2 (%3m)",
            [_best,"entityID"] call ALiVE_fnc_hashGet, _pos, round _bestDist] call ALiVE_fnc_dump;

        [_best,"state","FIRING"] call ALiVE_fnc_hashSet;
        _logic setVariable ["activeMissions", (_logic getVariable ["activeMissions", 0]) + 1];
        [_logic, _best, "", _pos, true] spawn ALIVE_fnc_MilArtilleryFireMission;
    };

    case "processRequest": {

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _request = _args;
        _request params ["_targetID","_targetPos","_contacts","_reqSide","_reqFaction","_asym"];

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
                && {!_asym || {([_record,"kind"] call ALiVE_fnc_hashGet) == "mortar"}}) then {

                private _entityProfile = [ALIVE_profileHandler, "getProfile", [_record,"entityID"] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
                if (!isNil "_entityProfile") then {
                    private _batteryPos = [_entityProfile,"position"] call ALiVE_fnc_hashGet;
                    private _dist = _batteryPos distance2D _targetPos;
                    if (_dist < (([_record,"maxRange"] call ALiVE_fnc_hashGet) * 0.95) && {_dist > 300} && {_dist < _bestDist}) then {
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
        // Virtual resolution is a later addition - skip the mission but stamp a
        // half cooldown so unwitnessed request spam cannot wedge the battery.
        private _entityProfile = [ALIVE_profileHandler, "getProfile", [_best,"entityID"] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
        private _batteryPos = [_entityProfile,"position"] call ALiVE_fnc_hashGet;
        private _humanPlayers = allPlayers - entities "HeadlessClient_F";
        if (((_humanPlayers findIf { _x distance2D _targetPos < 3000 }) == -1)
            && {(_humanPlayers findIf { _x distance2D _batteryPos < 3000 }) == -1}) exitWith {
            [_best,"cooldownUntil", time + (_cooldownBase / 2)] call ALiVE_fnc_hashSet;
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - fire mission skipped, no players near battery or target (virtual resolution not available)"] call ALiVE_fnc_dump;
            };
        };

        [_best,"state","FIRING"] call ALiVE_fnc_hashSet;
        _logic setVariable ["activeMissions", (_logic getVariable ["activeMissions", 0]) + 1];

        [_logic, _best, _targetID, _targetPos] spawn ALIVE_fnc_MilArtilleryFireMission;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ARTILLERY - output",_result);

if (isNil "_result") then { nil } else { _result };
