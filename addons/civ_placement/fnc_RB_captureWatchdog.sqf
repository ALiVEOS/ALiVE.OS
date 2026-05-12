#include "\x\alive\addons\civ_placement\script_component.hpp"
SCRIPT(RB_captureWatchdog);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_RB_captureWatchdog

Description:
    Registers a CBA per-frame handler that watches a roadblock's
    composition envelope for opposing-side combatants and re-garrisons
    by the dominant attacker faction once the original defenders die
    and the attackers have held the area for 30 seconds.

    State stored on an invisible `Logic` anchor object placed at the
    spawn position. The anchor's setVariable namespace holds:

        ALiVE_RB_anchorPos       - centre position used for proximity scan
        ALiVE_RB_radius          - capture radius (envelope * 1.5, min 30m)
        ALiVE_RB_originalFaction - faction string at spawn
        ALiVE_RB_originalSide    - side at spawn (for back-flip detection)
        ALiVE_RB_currentFaction  - faction that currently controls the
                                   roadblock (mutates on capture)
        ALiVE_RB_currentSide     - tracked owner side
        ALiVE_RB_state           - "defended" | "contested" | "captured"
        ALiVE_RB_lastFlap        - diag_tickTime of last state transition,
                                   used as the contest-hold timer
        ALiVE_RB_compClass       - composition class for marker / diag
        ALiVE_RB_debug           - mirror of caller's debug flag
        ALiVE_RB_pfh             - PFH handle for cleanup

    State machine:

        defended  --(def==0 && att>0)-->  contested (lastFlap=now)
        contested --(att==0)-->           defended  (clears the timer)
        contested --(30s elapsed)-->      captured  (recapture fires;
                                                    state flips to new
                                                    side; lastFlap=now)
        captured  --(def==0 && att>0 &&
                     60s elapsed)-->      contested (allows back-flip
                                                    by original side)

    "Defenders" excludes player-driven units so a friendly player driving
    through doesn't suppress capture by an opposing AI assault.
    "Attackers" INCLUDES players so a player-led assault registers.
    Empty vehicles don't count for either side - crew presence required
    so abandoned wrecks and parked transport don't skew the head count.

    Profile-virtualised defenders are NOT currently queried - the watchdog
    relies on real `nearEntities` results. Most attacks happen near
    players, which spawns the profile, so the gap is rarely hit. Adding
    `getNearProfiles` as a fallback is a queued follow-up.

Parameters:
    _pos              : ARRAY  - composition spawn position (ATL)
    _originalFaction  : STRING - faction that spawned the garrison
    _compClass        : STRING - composition class (for diag / marker)
    _envelope         : NUMBER - composition radius from getCompositionRadius
    _debug            : BOOL   - enable diag_log + debug-marker updates

Returns:
    OBJECT - the anchor logic. Caller can stash for cleanup or ignore.

Examples:
    (begin example)
    [_spawnedSafePos, _fac, _spawnedClass, _envelope, _debug]
        call ALIVE_fnc_RB_captureWatchdog;
    (end)

See Also:
    ALIVE_fnc_RB_recapture
    ALIVE_fnc_createRoadblock

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_pos", [0,0,0], [[]]],
    ["_originalFaction", "", [""]],
    ["_compClass", "", [""]],
    ["_envelope", 30, [0]],
    ["_debug", false, [true]]
];

if (count _pos < 2) exitWith {
    diag_log "ALIVE_fnc_RB_captureWatchdog: invalid position";
    objNull
};
if (_originalFaction == "") exitWith {
    diag_log "ALIVE_fnc_RB_captureWatchdog: empty faction";
    objNull
};

// Capture radius: composition envelope expanded a bit so units fighting
// just inside still count. Min 30m so tiny barricade comps still get a
// useful detection ring.
private _radius = (_envelope * 1.5) max 30;

private _origSide = _originalFaction call ALiVE_fnc_factionSide;

// Anchor = invisible game logic. Logic units must be spawned via
// `createGroup sideLogic` + `createUnit`, not createVehicle - the
// latter returns objNull for the Logic class on server-local locality
// without raising an error. Caught after the first capture-watchdog
// test run produced registration logs but zero per-tick output: the
// PFH's `isNull _anchor` exit fired on the first tick and the handler
// self-removed silently. The group survives mission-scope cleanup
// alongside the unit, no manual deletion needed.
private _logicGrp = createGroup sideLogic;
private _anchor   = _logicGrp createUnit ["Logic", _pos, [], 0, "NONE"];
_anchor setPosATL _pos;

_anchor setVariable ["ALiVE_RB_anchorPos", _pos];
_anchor setVariable ["ALiVE_RB_radius", _radius];
_anchor setVariable ["ALiVE_RB_originalFaction", _originalFaction];
_anchor setVariable ["ALiVE_RB_originalSide", _origSide];
_anchor setVariable ["ALiVE_RB_currentFaction", _originalFaction];
_anchor setVariable ["ALiVE_RB_currentSide", _origSide];
_anchor setVariable ["ALiVE_RB_state", "defended"];
_anchor setVariable ["ALiVE_RB_compClass", _compClass];
_anchor setVariable ["ALiVE_RB_lastFlap", diag_tickTime];
_anchor setVariable ["ALiVE_RB_debug", _debug];

private _handle = [{
    params ["_args", "_h"];
    _args params ["_anchor", "_debug"];

    if (isNull _anchor) exitWith {
        [_h] call CBA_fnc_removePerFrameHandler;
    };

    private _radius       = _anchor getVariable ["ALiVE_RB_radius", 30];
    private _currentSide  = _anchor getVariable ["ALiVE_RB_currentSide", civilian];
    private _state        = _anchor getVariable ["ALiVE_RB_state", "defended"];
    private _lastFlap     = _anchor getVariable ["ALiVE_RB_lastFlap", 0];

    private _allUnits = (getPosATL _anchor) nearEntities [
        ["CAManBase","Car","Tank","Truck_F"], _radius
    ];

    // Live combatants: infantry just need alive; vehicles need at least
    // one alive crew member (filters parked vehicles + abandoned wrecks
    // from the head count).
    private _liveCombatants = _allUnits select {
        if (_x isKindOf "CAManBase") then {
            alive _x
        } else {
            ({alive _x} count (crew _x)) > 0
        }
    };

    // Defenders: same side as current owner, NOT player-driven (so a
    // friendly player passing through doesn't suppress capture).
    private _defenders = _liveCombatants select {
        ((side _x) == _currentSide) && {!isPlayer (effectiveCommander _x)}
    };
    // Attackers: opposing side, NOT civilian. Players INCLUDED.
    private _attackers = _liveCombatants select {
        ((side _x) != _currentSide) && {(side _x) != civilian}
    };

    private _defenderCount = count _defenders;
    private _attackerCount = count _attackers;

    if (_debug) then {
        diag_log format [
            "ALIVE_RB watchdog: pos=%1 state=%2 def=%3 att=%4 currSide=%5 radius=%6",
            getPosATL _anchor, _state, _defenderCount, _attackerCount, _currentSide, _radius
        ];
    };

    switch (_state) do {
        case "defended": {
            if (_defenderCount == 0 && {_attackerCount > 0}) then {
                _anchor setVariable ["ALiVE_RB_state", "contested"];
                _anchor setVariable ["ALiVE_RB_lastFlap", diag_tickTime];
                if (_debug) then {
                    diag_log format ["ALIVE_RB watchdog: -> contested (def=0 att=%1)", _attackerCount];
                };
            };
        };
        case "contested": {
            if (_attackerCount == 0) then {
                // Attackers cleared - revert. If defenders also gone, the
                // next defender or attacker arrival re-triggers the
                // appropriate transition.
                _anchor setVariable ["ALiVE_RB_state", "defended"];
                if (_debug) then {
                    diag_log "ALIVE_RB watchdog: contested -> defended (attackers cleared)";
                };
            } else {
                if ((diag_tickTime - _lastFlap) > 30) then {
                    // Pick dominant attacker faction. Tie-break: first
                    // hit wins by virtue of insertion order in the hash.
                    private _factionCounts = createHashMap;
                    {
                        private _f = faction _x;
                        _factionCounts set [
                            _f,
                            (_factionCounts getOrDefault [_f, 0]) + 1
                        ];
                    } forEach _attackers;
                    private _topFaction = "";
                    private _topCount = 0;
                    {
                        if (_y > _topCount) then {
                            _topFaction = _x;
                            _topCount = _y;
                        };
                    } forEach _factionCounts;

                    if (_topFaction != "") then {
                        [_anchor, _topFaction] call ALIVE_fnc_RB_recapture;
                    };
                };
            };
        };
        case "captured": {
            // Mirror "defended" state for the new owners. Allow back-flip
            // when original side returns AND post-capture hold has expired
            // - prevents flip-flop in mixed-faction firefights.
            if (
                _defenderCount == 0 &&
                {_attackerCount > 0} &&
                {(diag_tickTime - _lastFlap) > 60}
            ) then {
                _anchor setVariable ["ALiVE_RB_state", "contested"];
                _anchor setVariable ["ALiVE_RB_lastFlap", diag_tickTime];
                if (_debug) then {
                    diag_log "ALIVE_RB watchdog: captured -> contested (back-flip pressure)";
                };
            };
        };
    };
}, 5, [_anchor, _debug]] call CBA_fnc_addPerFrameHandler;

_anchor setVariable ["ALiVE_RB_pfh", _handle];

if (_debug) then {
    diag_log format [
        "ALIVE_RB captureWatchdog registered: pos=%1 faction=%2 side=%3 radius=%4 PFH=%5 comp=%6",
        _pos, _originalFaction, _origSide, _radius, _handle, _compClass
    ];
};

_anchor
