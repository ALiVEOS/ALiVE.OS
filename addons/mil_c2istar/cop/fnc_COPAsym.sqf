#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPAsym);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPAsym

Description:
    Server-side asymmetric-layer (Layer 5) polling for COP. Reads data from
    an asymmetric OPCOM (controltype == "asymmetric") and broadcasts three
    channels to ALL sides (insurgent activity is common knowledge via news/
    radio chatter, not commander-private):

      ALiVE_COP_AsymActivityData  — [state, pos, size, locName] entries
                                     (only "terrorize" + "attack" states
                                      surface; "defend"/"reserve" too deep)
      ALiVE_COP_AsymHostilityData — [pos, size, [[side, hostility], ...]]
                                     civilian sentiment per cluster
      ALiVE_COP_AsymInfraData     — [type, pos] insurgent infrastructure
                                     (factory/HQ/depot/ied/suicide/sabotage/
                                      roadblocks). Always broadcast but
                                     client gates rendering per toggle; OFF
                                     by default to preserve COIN gameplay.

    Silent-disables with an INFO log when no asymmetric OPCOM is present —
    not a failure mode, just "mission has no insurgency".

Parameters:
    (none — called via `[] spawn ALIVE_fnc_COPAsym` from COPInit)

Returns:
    BOOL - true when the loop has been spawned; false on guard failure.

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

TRACE_1("COPAsym - input",_this);

if (!isServer) exitWith {
    ["error", "asym", "COPAsym invoked on non-server machine — aborting"] call ALIVE_fnc_COPLog;
    false
};

["info", "asym", "Starting asymmetric intel loop..."] call ALIVE_fnc_COPLog;

// ============================================================================
// WAIT FOR ALiVE
// ============================================================================
["debug", "asym", "Waiting for OPCOM_instances..."] call ALIVE_fnc_COPLog;
waitUntil { sleep 5; !isNil "OPCOM_instances" && {count OPCOM_instances > 0} };

// Asymmetric FSM takes a touch longer than conventional OPCOM analysis.
["debug", "asym", "OPCOM detected; waiting 50s for asymmetric FSM to stabilise..."] call ALIVE_fnc_COPLog;
sleep 50;

// ============================================================================
// ASYMMETRIC OPCOM DISCOVERY
// ============================================================================
missionNamespace setVariable ["ALIVE_COP_ASYM_OPCOM", nil];

{
    private _controltype = [_x, "controltype", ""] call ALiVE_fnc_HashGet;
    if (_controltype == "asymmetric") exitWith {
        ALIVE_COP_ASYM_OPCOM = _x;
        private _side = [_x, "side", ""] call ALiVE_fnc_HashGet;
        private _name = [_x, "name", ""] call ALiVE_fnc_HashGet;
        ["info", "asym", "Found asymmetric OPCOM '%1' (side: %2)", [_name, _side]] call ALIVE_fnc_COPLog;
    };
} forEach OPCOM_instances;

if (isNil "ALIVE_COP_ASYM_OPCOM") exitWith {
    // Silent-disable — many missions have no insurgency. Not an error.
    ALIVE_COP_ASYM_RUNNING = false;
    ["info", "asym", "No asymmetric OPCOM found — Layer 5 disabled for this mission."] call ALIVE_fnc_COPLog;
    false
};

// ============================================================================
// INITIALISE BROADCAST CHANNELS (empty arrays for JIP)
// Third-arg `true` makes these JIP-persistent — see fnc_COPServer.sqf for
// the same pattern. Asym channels are side-agnostic; client-side filtering
// by ALIVE_COP_playerSideKey happens in fnc_COPRender.sqf.
// ============================================================================
missionNamespace setVariable ["ALiVE_COP_AsymActivityData",  [], true];
missionNamespace setVariable ["ALiVE_COP_AsymHostilityData", [], true];
missionNamespace setVariable ["ALiVE_COP_AsymInfraData",     [], true];

if (isNil "ALIVE_COP_LAST_HASH_ASYM") then {
    ALIVE_COP_LAST_HASH_ASYM = createHashMap;
};

// ============================================================================
// LOOP — ASYMMETRIC INTEL (slow cycle, 60 s default)
// ============================================================================
[] spawn {
    ["info", "asym", "Loop starting (interval: %1s)", [ALIVE_COP_INTERVAL_SLOW]] call ALIVE_fnc_COPLog;

    private _infraFields = ["factory", "HQ", "depot", "ied", "suicide", "sabotage", "roadblocks"];
    private _cycleCount = 0;

    while {ALIVE_COP_ASYM_RUNNING} do {

        private _tStart = diag_tickTime;
        _cycleCount = _cycleCount + 1;

        private _activityArr  = [];
        private _hostilityArr = [];
        private _infraArr     = [];
        private _totalObjScanned = 0;
        private _stateBreakdown = createHashMap;
        // Dedup cluster lookups within this cycle (multiple objectives can share clusterID).
        private _seenClusters = createHashMap;

        if (ALIVE_COP_LAYER_ASYMMETRIC && {!isNil "ALIVE_COP_ASYM_OPCOM"}) then {

            // Skip the 7-field-per-objective infrastructure work entirely
            // when all client toggles are OFF (the default state). This
            // preserves COIN gameplay with zero server cost.
            private _anyInfraEnabled = ALIVE_COP_ASYM_SHOW_IED
                || ALIVE_COP_ASYM_SHOW_FACTORY
                || ALIVE_COP_ASYM_SHOW_DEPOT
                || ALIVE_COP_ASYM_SHOW_HQ
                || ALIVE_COP_ASYM_SHOW_SUICIDE
                || ALIVE_COP_ASYM_SHOW_SABOTAGE
                || ALIVE_COP_ASYM_SHOW_ROADBLOCK;

            private _objectives = [ALIVE_COP_ASYM_OPCOM, "objectives", []] call ALiVE_fnc_HashGet;
            _totalObjScanned = count _objectives;

            {
                private _obj = _x;

                // ----- Activity (terrorize + attack only surface; track all for debug) -----
                private _state = [_obj, "tacom_state", ""] call ALiVE_fnc_HashGet;
                if (_state != "") then {
                    private _curCount = _stateBreakdown getOrDefault [_state, 0];
                    _stateBreakdown set [_state, _curCount + 1];
                };

                if (ALIVE_COP_ASYM_SHOW_ACTIVITY) then {
                    if (_state in ALIVE_COP_ASYM_STATES) then {
                        private _center = [_obj, "center", [0,0,0]] call ALiVE_fnc_HashGet;
                        if ((_center distance2D [0,0,0]) > 100) then {
                            private _size = [_obj, "size", 200] call ALiVE_fnc_HashGet;
                            if (_size < ALIVE_COP_OBJ_MIN_RADIUS) then { _size = ALIVE_COP_OBJ_MIN_RADIUS };
                            private _locName = [_center] call ALIVE_fnc_COPGetLocationName;
                            _activityArr pushBack [_state, _center, _size, _locName];
                        };
                    };
                };

                // ----- Civilian sentiment via cluster hostility -----
                if (ALIVE_COP_ASYM_SHOW_HOSTILITY) then {
                    private _clusterID = [_obj, "clusterID", ""] call ALiVE_fnc_HashGet;
                    if (_clusterID != "" && {!isNil "ALIVE_clusterHandler"} && {!(_clusterID in _seenClusters)}) then {
                        _seenClusters set [_clusterID, true];
                        private _cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALiVE_fnc_clusterHandler;
                        if (!isNil "_cluster") then {
                            private _hostility = [_cluster, "hostility", []] call ALiVE_fnc_HashGet;
                            if (!isNil "_hostility") then {
                                // ALiVE hashes are NOT vanilla hashmaps — can't iterate directly.
                                // Read each known side's value explicitly.
                                private _hostArr = [];
                                {
                                    private _val = [_hostility, _x, 0] call ALiVE_fnc_HashGet;
                                    if (_val isEqualType 0 && {_val != 0}) then {
                                        _hostArr pushBack [_x, _val];
                                    };
                                } forEach ["WEST", "EAST", "GUER"];

                                if (count _hostArr > 0) then {
                                    private _center = [_obj, "center", [0,0,0]] call ALiVE_fnc_HashGet;
                                    if ((_center distance2D [0,0,0]) > 100) then {
                                        _hostilityArr pushBack [_center, ALIVE_COP_ASYM_HOSTILITY_RADIUS, _hostArr];
                                    };
                                };
                            };
                        };
                    };
                };

                // ----- Infrastructure (only when any client toggle is enabled) -----
                if (_anyInfraEnabled) then {
                    {
                        private _field = _x;
                        private _val = [_obj, _field, ""] call ALiVE_fnc_HashGet;
                        private _validPos = false;
                        private _pos = [0, 0, 0];

                        if (_val isEqualType []) then {
                            if (count _val >= 2) then {
                                _pos = _val;
                                _validPos = ((_pos distance2D [0,0,0]) > 100);
                            };
                        } else {
                            if (_val isEqualType objNull && {!isNull _val}) then {
                                _pos = getPosATL _val;
                                _validPos = ((_pos distance2D [0,0,0]) > 100);
                            };
                        };

                        if (_validPos) then {
                            _infraArr pushBack [_field, _pos];
                        };
                    } forEach _infraFields;
                };

            } forEach _objectives;

            sleep 0.01;
        };

        // ----- Hash diff and broadcast -----
        private _broadcastCount = 0;
        {
            _x params ["_varName", "_data"];
            if ([_varName, _data, ALIVE_COP_LAST_HASH_ASYM] call ALIVE_fnc_COPBroadcastIfChanged) then {
                _broadcastCount = _broadcastCount + 1;
            };
        } forEach [
            ["ALiVE_COP_AsymActivityData",  _activityArr],
            ["ALiVE_COP_AsymHostilityData", _hostilityArr],
            ["ALiVE_COP_AsymInfraData",     _infraArr]
        ];

        // ----- Cycle summary -----
        private _cycleMs = round ((diag_tickTime - _tStart) * 1000);

        // State breakdown for debug visibility (all states, not just surfaced ones).
        private _stateStr = "";
        {
            _stateStr = _stateStr + format ["%1=%2 ", _x, _y];
        } forEach _stateBreakdown;

        ["info", "asym",
            "[Cycle %1] objs: %2 | states: %3| activity: %4 | hostility: %5 | infra: %6 | broadcasts: %7/3 | %8ms",
            [_cycleCount, _totalObjScanned, _stateStr,
             count _activityArr, count _hostilityArr, count _infraArr,
             _broadcastCount, _cycleMs]
        ] call ALIVE_fnc_COPLog;

        // Cycle 1 cold-start exemption (same rationale as Loop A).
        private _warnThreshold = if (_cycleCount == 1) then { ALIVE_COP_DEBUG_PERF_WARN_CYCLE1_MS } else { ALIVE_COP_DEBUG_PERF_WARN_MS };
        if (_cycleMs > _warnThreshold) then {
            // ["warn", "perf", "Asym cycle %1 took %2ms (threshold: %3ms)", [_cycleCount, _cycleMs, _warnThreshold]] call ALIVE_fnc_COPLog;
        };

        sleep ALIVE_COP_INTERVAL_SLOW;
    };

    ["info", "asym", "Loop stopped (ALIVE_COP_ASYM_RUNNING cleared)."] call ALIVE_fnc_COPLog;
};

["info", "asym", "Asymmetric loop spawned. Init complete."] call ALIVE_fnc_COPLog;

private _result = true;
TRACE_1("COPAsym - output",_result);
_result
