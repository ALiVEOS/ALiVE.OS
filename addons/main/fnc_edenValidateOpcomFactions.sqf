#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenValidateOpcomFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_edenValidateOpcomFactions
Description:
Editor-time validator - walks OPCOM entities in the 3DEN scene and runs
two independent checks per OPCOM:

  1. FACTION SOURCE: each OPCOM's declared factions must have at least
     one matching profile-spawning placement module SOMEWHERE in the
     mission. Surfaces the real runtime failure condition (OPCOM init
     exits with "no groups for faction %1" when zero profiles exist
     for any of its factions) before mission preview. Mirrors the
     runtime profile-count check in fnc_OPCOM.sqf:567-580 which queries
     ALIVE_profileHandler getProfilesByFaction globally and exits the
     OPCOM if the total count is zero.

  2. OPCOM-TO-OPCOM SYNC: syncing two OPCOMs together is a functional
     no-op. Verified by exhaustive walk of fnc_OPCOM.sqf + all OPCOM
     FSMs + fnc_INS_helpers.sqf - no code path treats another OPCOM
     as a peer when iterating synchronizedObjects, no shared state via
     the sync graph. Mission-makers drawing OPCOM-to-OPCOM sync lines
     typically expect intel sharing, deconfliction, or coordination
     and get nothing. The hint tells them to remove the link. Edges
     are deduplicated (A<->B and B<->A report once per validator run).

Mission-wide scope for check 1 is intentional: profile control is
faction-based, not sync-based. An OPCOM with faction X owns every
profile of faction X in the mission regardless of which placement
spawned them or whether those placements are synced to this OPCOM.
A sync graph expresses objective distribution (which OPCOM plans
around which positions), not force ownership. Mission patterns like
"multiple OPCOMs synced to one placement" or "OPFOR placement synced
to BLUFOR OPCOM for contested-objective setups" are legitimate and
working configurations - the earlier sync-mismatch heuristic false-
flagged both.

Called from 3DEN event handlers (OnEntityAttributeChanged,
OnConnectingEnd, OnMissionPreview) registered in XEH_preInit.sqf. Safe
no-op outside Eden.

Debounce: a 0.5s scheduled-script window collapses bursts (bulk paste,
multi-module sync ops, per-attribute OnEntityAttributeChanged fires
on OPCOM Save) into one validation run.

Trigger parameter (_this select 0, optional, default "attr"):
    "sync"    - fired from OnConnectingEnd; emits a green OK toast
                when no mismatches.
    "attr"    - fired from OnEntityAttributeChanged; emits a green
                OK toast when no mismatches.
    "preview" - fired from OnMissionPreview; skips green toast (user
                is about to launch the mission).
Red warning fires on any trigger when either check raises an issue:
no profile source for a declared faction, or OPCOM-to-OPCOM sync
detected. Both warnings can fire for the same OPCOM in the same run
(stacked toasts) - they describe independent problems.

Scope parameter (_this select 1, optional, default []):
    Array of OPCOM entity objects to restrict validation to. When
    non-empty, only those OPCOMs are checked (keeps sync/attr
    feedback focused on the OPCOM the user just touched, not a
    global re-audit that surfaces pre-existing misconfigs on
    unrelated OPCOMs). When empty, walks every OPCOM in the scene
    (used by the preview trigger as the last-chance safety net).

Warnings only - does NOT auto-fix. Tier-1 notify-only by design.

Author:
Jman
---------------------------------------------------------------------------- */

if !(is3DEN) exitWith {};

params [["_trigger", "attr", [""]], ["_scope", [], [[]]]];

// Debounce: cancel any pending run and schedule a fresh one. Bulk sync
// / paste ops (and Eden's per-attribute OnEntityAttributeChanged bursts
// - one event per attribute means ~16 fires from a single OPCOM Save)
// would otherwise run the validator N times. Only the LAST scheduled
// run actually executes.
if (!isNil "ALIVE_edenFactionValidatorPending") then {
    terminate ALIVE_edenFactionValidatorPending;
};
ALIVE_edenFactionValidatorPending = [_trigger, _scope] spawn {
    params ["_trigger", "_scope"];
    sleep 0.5;
    ["ALiVE 3DEN faction-source check: running (trigger=%1 scope=%2)", _trigger, count _scope] call ALiVE_fnc_dump;

    private _OPCOM_CLASSES = ["ALiVE_mil_OPCOM"];
    private _PLACEMENT_CLASSES = [
        "ALiVE_mil_placement",
        "ALiVE_civ_placement",
        "ALiVE_civ_placement_custom",
        "ALiVE_mil_placement_custom",
        "ALiVE_mil_placement_spe"
    ];
    private _CUSTOM_PLACEMENT_CLASSES = ["ALiVE_civ_placement_custom", "ALiVE_mil_placement_custom"];
    // Placement classes that expose a withPlacement toggle (Yes/No:
    // "Place Units" vs "Objectives Only"). When set to "false", the
    // placement registers objectives only - no profiles spawn, so the
    // placement is not a profile source for its configured faction.
    // The other two placement classes (mil_placement_custom,
    // mil_placement_spe) have no such toggle and always spawn forces.
    private _GATED_PLACEMENT_CLASSES = [
        "ALiVE_mil_placement",
        "ALiVE_civ_placement",
        "ALiVE_civ_placement_custom"
    ];

    // Parse a stored multi-select faction value into a list of classnames.
    // Accepts the three round-trip shapes the multi-select Load/Save
    // handler supports: SQF array literal "[\"a\",\"b\"]", CSV "a,b",
    // or single classname "a". Empty string / nil -> [].
    private _parseFactions = {
        params ["_str"];
        private _parsed = [];
        if (_str isEqualType []) exitWith {
            {
                if (_x isEqualType "" && {_x != ""} && {_x != "NONE"} && {!(_x in _parsed)}) then {
                    _parsed pushBack _x;
                };
            } forEach _str;
            _parsed
        };
        if !(_str isEqualType "") exitWith { [] };
        if (_str == "") exitWith { [] };
        private _s = _str;
        _s = [_s, " ", ""] call CBA_fnc_replace;
        _s = [_s, "[", ""] call CBA_fnc_replace;
        _s = [_s, "]", ""] call CBA_fnc_replace;
        _s = [_s, """", ""] call CBA_fnc_replace;
        {
            if (_x != "" && {_x != "NONE"} && {!(_x in _parsed)}) then {
                _parsed pushBack _x;
            };
        } forEach ([_s, ","] call CBA_fnc_split);
        _parsed
    };

    private _resolveOpcomFactions = {
        params ["_opcom"];
        private _primary = ([_opcom getVariable ["factions", ""]] call _parseFactions) + ([_opcom getVariable ["factionsManual", ""]] call _parseFactions);
        private _primaryNonEmpty = (count _primary) > 0;
        private _sources = if (_primaryNonEmpty) then {
            _primary
        } else {
            [
                _opcom getVariable ["faction1", ""],
                _opcom getVariable ["faction2", ""],
                _opcom getVariable ["faction3", ""],
                _opcom getVariable ["faction4", ""]
            ]
        };
        private _factions = [];
        {
            if (_x isEqualType "" && {_x != ""} && {_x != "NONE"} && {!(_x in _factions)}) then {
                _factions pushBack _x;
            };
        } forEach _sources;
        if (count _factions == 0) then { _factions = ["BLU_F"] };
        _factions
    };

    // Resolve a placement module's faction sources. Custom objectives may
    // explicitly set multiple factions, or leave the list empty to inherit
    // factions from synced OPCOMs. Legacy single-faction values and config
    // defaults are retained for older missions and non-custom placements.
    private _resolvePlacementFactions = {
        params ["_mod"];
        private _type = typeOf _mod;
        private _factions = [_mod getVariable ["factions", ""]] call _parseFactions;
        private _legacyFactions = [_mod getVariable ["faction", ""]] call _parseFactions;

        if (count _factions == 0) then {
            _factions = +_legacyFactions;
        };

        if ((count _factions == 0) && {_type in _CUSTOM_PLACEMENT_CLASSES}) then {
            private _syncPeers = (get3DENConnections _mod select {(_x select 0) == "Sync"}) apply {_x select 1};
            {
                private _peer = _x;
                if (!isNil "_peer" && {_peer isEqualType objNull} && {!isNull _peer} && {(typeOf _peer) in _OPCOM_CLASSES}) then {
                    {
                        if (!(_x in _factions)) then {
                            _factions pushBack _x;
                        };
                    } forEach ([_peer] call _resolveOpcomFactions);
                };
            } forEach _syncPeers;
        };

        if (count _factions > 0) exitWith { _factions };

        // defaultValue in CfgVehicles is stored as a quoted-string literal
        // e.g. """OPF_F""" -> strip surrounding quotes to get the bare
        // classname.
        private _cfgDefault = getText (configFile >> "CfgVehicles" >> (typeOf _mod) >> "Attributes" >> "faction" >> "defaultValue");
        _cfgDefault = [_cfgDefault, """", ""] call CBA_fnc_replace;
        private _defaultFactions = [_cfgDefault] call _parseFactions;
        if ((count _defaultFactions == 0) && {_type in _CUSTOM_PLACEMENT_CLASSES}) exitWith { ["BLU_F"] };
        _defaultFactions
    };

    // Determine whether a placement module will actually spawn forces
    // at runtime. Returns true if the module has no withPlacement gate
    // (mil_placement_custom / mil_placement_spe always spawn) or if
    // the gate is true / "true".
    private _placementSpawns = {
        params ["_mod"];
        private _type = typeOf _mod;
        if !(_type in _GATED_PLACEMENT_CLASSES) exitWith { true };
        private _wp = _mod getVariable ["withPlacement", "true"];
        (_wp isEqualTo "true") || {_wp isEqualTo true}
    };

    // Global scan: walk every entity in the 3DEN scene ONCE and build
    // two things at the same time:
    //   _opcomsAll - every OPCOM in the scene (used to fall back to
    //                global scope when _scope is empty)
    //   _globalSourceFactions - every faction that has at least one
    //                spawning placement module anywhere in the scene.
    //                This is the authoritative "which factions will
    //                have profiles at runtime" set, matching the
    //                runtime getProfilesByFaction check that OPCOM
    //                init uses to decide whether it can run.
    //   _totalPlacements - count of placement modules (any mode)
    //                used as a "mission is still being built" gate:
    //                if nobody has placed any placements yet, don't
    //                warn about missing profile sources - the mission-
    //                maker is clearly still setting up.
    //
    // all3DENEntities returns mixed-type buckets per current A3 docs:
    //   [_objects, _groups, _triggers, _systems, _markers, _layers,
    //    _comments, _connections]
    // Only some buckets hold Objects (objects/triggers/systems/comments);
    // others hold Strings (markers), Numbers (layers), Arrays
    // (connections). Filter per-element to pick only Object-typed
    // entries - modules (systems) are what we actually care about.
    private _opcomsAll = [];
    private _globalSourceFactions = [];
    private _totalPlacements = 0;
    {
        {
            if (_x isEqualType objNull && {!isNull _x}) then {
                private _t = typeOf _x;
                if (_t in _OPCOM_CLASSES) then {
                    _opcomsAll pushBack _x;
                };
                if (_t in _PLACEMENT_CLASSES) then {
                    _totalPlacements = _totalPlacements + 1;
                    if ([_x] call _placementSpawns) then {
                        {
                            if (!(_x in _globalSourceFactions)) then {
                                _globalSourceFactions pushBack _x;
                            };
                        } forEach ([_x] call _resolvePlacementFactions);
                    };
                };
            };
        } forEach _x;
    } forEach all3DENEntities;

    // Per-trigger scoping: when the caller passes a non-empty _scope
    // list (OPCOM entities), only those OPCOMs are validated. Keeps
    // sync/attr feedback focused on the OPCOM the user just touched,
    // instead of surfacing pre-existing misconfigs on unrelated OPCOMs
    // in the scene every time anything changes.
    //
    // Empty _scope (preview trigger, or legacy callers) falls back to
    // every OPCOM collected during the global scan.
    private _opcomsToValidate = if (count _scope > 0) then { _scope } else { _opcomsAll };

    private _warnings = 0;
    // Count OPCOMs that actually got past the mission-has-placements
    // gate. Needed so we don't emit a green "all OK" in a scene that
    // has no placements yet (mission-maker still setting up).
    private _opcomsChecked = 0;
    // Collected for the green OK toast so mission-makers see WHICH
    // factions resolved.
    private _resolvedFactions = [];
    // OPCOM-to-OPCOM edge dedup: when _scope contains multiple OPCOMs
    // (preview trigger / multi-entity scope) the same A<->B edge would
    // be reported twice, once from each endpoint's perspective. Each
    // edge is canonicalised as a sorted id pair string and only the
    // first occurrence within this validator run emits a toast.
    private _emittedOpcomEdges = [];

    {
        private _opcom = _x;

        private _name = _opcom getVariable ["customName", ""];
        // Parentheses not angle brackets - BIS_fnc_3DENNotification
        // parses message content as XML and breaks on bare < >.
        if (_name == "") then { _name = format ["(unnamed %1)", typeOf _opcom] };

        // CHECK 2: OPCOM-to-OPCOM no-op sync detection. Runs
        // unconditionally (not gated on _totalPlacements) - two
        // OPCOMs synced together is worth flagging regardless of
        // whether placements exist in the scene yet.
        private _opcomSyncPeers = (get3DENConnections _opcom select {(_x select 0) == "Sync"}) apply {_x select 1};
        _opcomSyncPeers = _opcomSyncPeers select {
            !isNil "_x" && {_x isEqualType objNull} && {!isNull _x} && {(typeOf _x) in _OPCOM_CLASSES} && {!(_x isEqualTo _opcom)}
        };
        if (count _opcomSyncPeers > 0) then {
            private _thisID = str _opcom;
            private _peersToReport = [];
            {
                private _peerID = str _x;
                // Dedup via both orderings of the id pair - SQF has
                // no string comparison operator so we can't build a
                // single canonical sorted key. Check both "A|B" and
                // "B|A" against the emitted set; store whichever was
                // tried first.
                //
                // Condition extracted to a local because SQF's if
                // keyword is greedy - it consumes the first !(expr)
                // returning IF_TYPE, then && can't combine with that
                // type. `if (cond) then {...}` requires cond to be
                // a single fully-parenthesised boolean; going via
                // _alreadySeen avoids the trap entirely.
                private _forwardKey = format ["%1|%2", _thisID, _peerID];
                private _reverseKey = format ["%1|%2", _peerID, _thisID];
                private _alreadySeen = (_forwardKey in _emittedOpcomEdges) || (_reverseKey in _emittedOpcomEdges);
                if (!_alreadySeen) then {
                    _emittedOpcomEdges pushBack _forwardKey;
                    _peersToReport pushBack _x;
                };
            } forEach _opcomSyncPeers;

            if (count _peersToReport > 0) then {
                private _peerNames = _peersToReport apply {
                    private _pn = _x getVariable ["customName", ""];
                    if (_pn == "") then { format ["(unnamed %1)", typeOf _x] } else { _pn }
                };
                // Truncate long lists in the toast; full list still
                // goes to diag_log.
                private _truncatedNames = if (count _peerNames > 5) then {
                    (_peerNames select [0, 5]) + [format ["... (+%1 more)", (count _peerNames) - 5]]
                } else {
                    _peerNames
                };
                private _peerList = (_truncatedNames apply {format ["'%1'", _x]}) joinString ", ";
                private _countLabel = if (count _peersToReport == 1) then {"another AI Commander"} else {"other AI Commanders"};
                private _msg = format [
                    "ALiVE: AI Commander '%1' is synced to %2 %3. OPCOM-to-OPCOM sync has no effect - no intel sharing, deconfliction, or coordination between Commanders is wired up. Remove the sync link(s).",
                    _name,
                    _countLabel,
                    _peerList
                ];
                // type 1 = Red warning, duration 60 seconds.
                [_msg, 1, 60] call BIS_fnc_3DENNotification;
                [
                    "ALiVE 3DEN faction-source check: AI Commander '%1' has OPCOM-to-OPCOM sync peer(s)=[%2]",
                    _name,
                    _peerNames joinString ", "
                ] call ALiVE_fnc_dump;
                _warnings = _warnings + 1;
            };
        };

        private _opcomFactions = [_opcom] call _resolveOpcomFactions;

        // Mission-building gate: if there are zero placement modules
        // in the entire scene, the mission-maker is still setting up
        // - no point warning about missing profile sources for a
        // mission that has no placements at all. This also prevents
        // false-positive green "all OK" in a scene that hasn't been
        // populated yet.
        if (_totalPlacements == 0) exitWith {};

        _opcomsChecked = _opcomsChecked + 1;

        // CHECK 1: Global profile-source check. Does each of this
        // OPCOM's factions have at least one spawning placement
        // somewhere in the mission? This matches the runtime
        // getProfilesByFaction query at fnc_OPCOM.sqf:567-580.
        //
        // Only the "unmatched" direction is checked - there's no
        // "orphaned" concept under profile-source semantics. A
        // placement providing a faction that no OPCOM declares is a
        // legitimate mission pattern (editor-placed units for ambient
        // purposes, sys_profile-virtualized groups, or reserved for a
        // future OPCOM) and is not a misconfiguration.
        private _unmatched = _opcomFactions select { !(_x in _globalSourceFactions) };

        // Track which OPCOM factions DID have a source (for the
        // green OK toast listing).
        {
            if ((_x in _globalSourceFactions) && {!(_x in _resolvedFactions)}) then {
                _resolvedFactions pushBack _x;
            };
        } forEach _opcomFactions;

        if (count _unmatched > 0) then {
            // Truncate to first 5 entries in the toast so a wildly-
            // misconfigured module doesn't spam a wall of text. Full
            // list still goes to diag_log.
            private _truncated = if (count _unmatched > 5) then {
                (_unmatched select [0, 5]) + [format ["... (+%1 more)", (count _unmatched) - 5]]
            } else {
                _unmatched
            };
            private _msg = format [
                "ALiVE: AI Commander '%1' has faction(s) [%2] with no matching profile-spawning placement in the mission. At runtime this Commander will fail with 'no groups for faction' and refuse to run. Fix by placing a Mil Placement (or similar) module with a matching faction in Place Units mode, selecting matching Force Factions on a custom objective, or leaving a synced custom objective's Force Factions empty to inherit this Commander.",
                _name,
                _truncated joinString ", "
            ];
            // BIS_fnc_3DENNotification - 3DEN-native toast top-middle.
            // systemChat is NOT used - silently discarded in 3DEN
            // (chat overlay inactive).
            //
            // 60-second duration: message is long (lists factions plus
            // two-part fix guidance) and the mission-maker needs time
            // to read and act before the toast fades.
            // type 1 = Red warning, duration 60 seconds.
            [_msg, 1, 60] call BIS_fnc_3DENNotification;
            [
                "ALiVE 3DEN faction-source check: AI Commander '%1' unmatched=[%2] globalSources=[%3]",
                _name,
                _unmatched joinString ", ",
                _globalSourceFactions joinString ", "
            ] call ALiVE_fnc_dump;
            _warnings = _warnings + 1;
        };
    } forEach _opcomsToValidate;

    // One-line "all clear" log so mission-makers + debug builds see
    // the validator actually ran.
    if (_warnings == 0) then {
        ["ALiVE 3DEN faction-source check: OK (checked=%1 totalPlacements=%2)", _opcomsChecked, _totalPlacements] call ALiVE_fnc_dump;

        // Positive confirmation toast only on sync/attr triggers AND
        // only if at least one OPCOM actually got past the mission-
        // has-placements gate. preview trigger skips green because
        // the user is about to see the mission run anyway. 0.5s
        // debounce collapses per-attribute event bursts into one
        // toast.
        //
        // MESSAGE TEXT: no `<` or `>` anywhere - BIS_fnc_3DENNotification
        // interprets message content as XML and truncates at the first
        // `<`. Use "to" not `<->`, parentheses not angle brackets.
        if ((_trigger in ["sync", "attr"]) && {_opcomsChecked > 0}) then {
            private _factionList = if (count _resolvedFactions > 0) then {
                _resolvedFactions joinString ", "
            } else {
                "(none resolved)"
            };
            private _okMsg = format [
                "ALiVE: AI Commander setup OK. %1 Commander(s) have profile sources for their configured faction(s) [%2].",
                _opcomsChecked,
                _factionList
            ];
            // type 0 = Green notification, duration 15 seconds.
            [_okMsg, 0, 15] call BIS_fnc_3DENNotification;
        };
    };
};
