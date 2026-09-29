#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenValidateOpcomFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_edenValidateOpcomFactions
Description:
Editor-time validator - walks OPCOM entities in the 3DEN scene and runs
two independent checks per OPCOM:

  1. FACTION SOURCE: each OPCOM's declared factions must have forces
     SOMEWHERE in the mission: a placement module that places units
     for the faction, or editor-placed units of the faction that the
     Virtual AI System turns into profiles at start (the ones synced
     to it on its default "Only virtualize synced units", the ones not
     synced on "Virtualize all editor placed units except synced
     units"). Mirrors the no-groups check in fnc_OPCOM.sqf, which
     counts ALIVE_profileHandler getProfilesByFaction for each faction:
     it logs every faction with no profiles, and stops the OPCOM only
     when the total over all its factions is zero. The warning says
     which of the two will happen.

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

    // Editor-placed units the Virtual AI System turns into profiles at start count
    // for a commander like placed ones: an aircraft synced to it is enough for a
    // commander whose faction nothing else places. These mirror the filters in
    // sys_profile/fnc_createProfilesFromUnits.sqf, which leaves out UAV crews, the
    // UAVs themselves, whatever the Combat Support module has taken over, and any
    // empty object that isn't one of these kinds of vehicle.
    private _VIRTUAL_AI_CLASS = "ALiVE_sys_profile";
    private _COMBAT_SUPPORT_CLASS = "ALiVE_sup_combatsupport";
    private _UNIT_BLACKLIST = ["O_UAV_AI", "B_UAV_AI"];
    private _VEHICLE_BLACKLIST = ["O_UAV_02_F","O_UAV_02_CAS_F","O_UAV_01_F","O_UGV_01_F","O_UGV_01_rcws_F","B_UAV_01_F","B_UAV_02_F","B_UAV_02_CAS_F","B_UGV_01_F","B_UGV_01_rcws_F"];
    private _PROFILED_KINDS = ["Car", "Tank", "Armored", "Truck", "Truck_F", "Ship", "Helicopter", "Plane", "StaticWeapon"];

    // Read an attribute as the editor holds it. A module's attributes only become
    // variables on its logic when the mission starts, so while it is being built
    // getVariable finds nothing, except where a faction picker's save handler has
    // copied its value across, and that only happens once its window has been OK'd
    // in this editor session. get3DENAttribute takes the full property name and
    // gives [value], or [] for a property the entity doesn't have; the variable is
    // kept as the fallback.
    private _attr = {
        params ["_entity", "_property", "_varName", "_default"];
        private _held = _entity get3DENAttribute _property;
        if (_held isEqualType [] && {count _held > 0} && {!isNil {_held select 0}}) exitWith { _held select 0 };
        _entity getVariable [_varName, _default]
    };

    // A player's own group never becomes an AI profile: the Virtual AI System leaves
    // alone any group a player leads, and the commander doesn't count player
    // profiles. There are no players in the editor, so a unit marked Player or
    // Playable stands in for one, and a group with any such unit is left out. That
    // errs towards warning, which is deliberate: in a multiplayer game those slots
    // are players or, with AI switched off in the lobby, aren't there at all.
    private _isPlayerSlot = {
        params ["_unit"];
        (((_unit get3DENAttribute "ControlSP") param [0, false]) isEqualTo true)
            || {((_unit get3DENAttribute "ControlMP") param [0, false]) isEqualTo true}
    };

    // A group or vehicle carrying ALIVE_profileIgnore is left as live AI by the Virtual AI
    // System. The editor can't run init fields, so one that mentions the flag counts as
    // setting it (on the group, for a unit's), which errs towards warning.
    private _ignoredInInit = {
        params ["_entity"];
        private _init = (_entity get3DENAttribute "Init") param [0, ""];
        (_init isEqualType "") && {((toLower _init) find "alive_profileignore") >= 0}
    };

    // BIS_fnc_3DENNotification parses its text as XML, so a < > or & in something a
    // mission maker typed (a commander called "Red > Blue") cuts the notification short.
    private _xmlSafe = {
        params ["_text"];
        _text = [_text, "&", "and"] call CBA_fnc_replace;
        _text = [_text, "<", "("] call CBA_fnc_replace;
        [_text, ">", ")"] call CBA_fnc_replace
    };

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
        private _primary = ([[_opcom, "ALiVE_mil_opcom_factions", "factions", ""] call _attr] call _parseFactions) + ([[_opcom, "ALiVE_mil_opcom_factionsManual", "factionsManual", ""] call _attr] call _parseFactions);
        private _primaryNonEmpty = (count _primary) > 0;
        private _sources = if (_primaryNonEmpty) then {
            _primary
        } else {
            [
                [_opcom, "ALiVE_mil_opcom_faction1", "faction1", ""] call _attr,
                [_opcom, "ALiVE_mil_opcom_faction2", "faction2", ""] call _attr,
                [_opcom, "ALiVE_mil_opcom_faction3", "faction3", ""] call _attr,
                [_opcom, "ALiVE_mil_opcom_faction4", "faction4", ""] call _attr
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

        // A Custom Faction Compiler synced to the placement module decides the faction it
        // places, ahead of its Force Factions, as it does when the mission runs. Its Faction ID
        // is tidied the way the compiler tidies it, as that is the name the faction goes by:
        // each run of anything but letters and digits becomes one underscore, and with no
        // letter or digit at all it is ALIVE_CUSTOM_FACTION. Only one compiler may be synced;
        // with more, the mission falls back to the Force Factions, and so does this check.
        private _compilers = ((get3DENConnections _mod) select {
            (_x select 0) == "Sync" && {(_x select 1) isEqualType objNull} && {(typeOf (_x select 1)) isEqualTo "ALiVE_sys_factioncompiler"}
        }) apply {_x select 1};
        if (count _compilers == 1) exitWith {
            private _raw = ((_compilers select 0) get3DENAttribute "ALiVE_sys_factioncompiler_factionId") param [0, ""];
            if !(_raw isEqualType "") then { _raw = str _raw };
            private _codes = [];
            private _lastWasUnderscore = false;
            private _hasIdentifierChar = false;
            {
                if ((_x >= 48 && _x <= 57) || {(_x >= 65 && _x <= 90) || (_x >= 97 && _x <= 122)}) then {
                    _codes pushBack _x;
                    _lastWasUnderscore = false;
                    _hasIdentifierChar = true;
                } else {
                    if !(_lastWasUnderscore) then {
                        _codes pushBack 95;
                        _lastWasUnderscore = true;
                    };
                };
            } forEach (toArray _raw);
            [if (_hasIdentifierChar) then {toString _codes} else {"ALIVE_CUSTOM_FACTION"}]
        };

        private _factions = [[_mod, _type + "_factions", "factions", ""] call _attr] call _parseFactions;
        private _legacyFactions = [[_mod, _type + "_faction", "faction", ""] call _attr] call _parseFactions;
        private _legacyIsDefault = (count _legacyFactions == 1) && {(_legacyFactions select 0) == "BLU_F"};
        private _legacyBlocksInheritance = (_type in _CUSTOM_PLACEMENT_CLASSES) && {_legacyIsDefault};

        if ((count _factions == 0) && {count _legacyFactions > 0} && {!_legacyBlocksInheritance}) then {
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

        if ((count _factions == 0) && {count _legacyFactions > 0}) then {
            _factions = +_legacyFactions;
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
        private _wp = [_mod, _type + "_withPlacement", "withPlacement", "true"] call _attr;
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
    // all3DENEntities returns mixed-type buckets:
    //   [_objects, _groups, _triggers, _systems, _waypoints, _markers,
    //    _layers, _comments]
    // Measured in the editor 2026-09-20 on a scenario with two area markers
    // drawn: bucket 5 held exactly those two, and they read back as Strings.
    // An earlier version of this comment left _waypoints out, which put markers
    // at 4 and comments at 6, and a later reader took it at face value.
    // Only some buckets hold Objects (objects/triggers/systems); others hold
    // Strings (markers), Numbers (layers). Filter per-element to pick only
    // Object-typed entries - modules (systems) are what we actually care about.
    private _opcomsAll = [];
    private _globalSourceFactions = [];
    private _totalPlacements = 0;
    private _virtualAIModules = [];
    private _combatSupportModules = [];
    private _editorGroups = [];
    private _editorVehicles = [];
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
                if (_t == _VIRTUAL_AI_CLASS) then {
                    _virtualAIModules pushBack _x;
                };
                if (_t == _COMBAT_SUPPORT_CLASS) then {
                    _combatSupportModules pushBack _x;
                };
                // Soldiers by their group, everything else that can be a vehicle on its
                // own. Props, boxes and logics aren't AllVehicles.
                if (_x isKindOf "AllVehicles") then {
                    if (_x isKindOf "CAManBase") then {
                        private _group = group _x;
                        if (!isNull _group && {!(_group in _editorGroups)}) then {
                            _editorGroups pushBack _group;
                        };
                    } else {
                        _editorVehicles pushBack _x;
                    };
                };
            };
        } forEach _x;
    } forEach all3DENEntities;

    // Which editor-placed units the Virtual AI System will turn into profiles, and
    // the factions they give. With no Virtual AI System in the mission it takes none.
    //   _editorSourceFactions - factions with at least one such profile to come
    //   _editorSourceCount    - how many groups and empty vehicles that is, which
    //                           the mission-building gate below reads alongside
    //                           _totalPlacements
    //   _virtualAIMode        - the modules' Synchronisation Options when they all
    //                           agree, for the fix the warning suggests
    private _editorSourceFactions = [];
    private _editorSourceCount = 0;
    private _virtualAIMode = "";
    if (count _virtualAIModules > 0) then {
        // The Combat Support module takes over the vehicles synced to it, and the
        // Virtual AI System leaves those alone.
        private _combatSupportAssets = [];
        {
            {
                if (_x isEqualType [] && {count _x >= 2} && {(_x select 0) isEqualTo "Sync"}) then {
                    private _peer = _x select 1;
                    if (_peer isEqualType objNull && {!isNull _peer}) then {
                        _combatSupportAssets pushBackUnique (vehicle _peer);
                    };
                };
            } forEach (get3DENConnections _x);
        } forEach _combatSupportModules;

        // What each module takes, as createProfilesFromUnits works it out from what
        // is synced to it: a synced unit brings its whole group and the vehicles
        // that group is in, and a synced object with no group is an empty vehicle.
        // "Only virtualize synced units" (ADD) takes those; "Virtualize all editor
        // placed units except synced units" (IGNORE) takes everything else; any
        // other value takes everything, as the runtime does.
        //
        // Only one Virtual AI System runs: fnc_profileSystemInit.sqf sets itself up
        // once per machine and every later module stops there, and which one comes
        // first isn't fixed. With several, a unit counts only if all of them would
        // take it, and the mode is only named in the fix when they all agree.
        private _takenGroups = [];
        private _takenVehicles = [];
        private _modes = [];
        {
            private _module = _x;
            private _mode = [_module, _VIRTUAL_AI_CLASS + "_syncronised", "syncronised", "ADD"] call _attr;
            if !(_mode isEqualType "") then { _mode = "ADD" };
            _modes pushBackUnique (toUpper _mode);

            private _syncedGroups = [];
            private _syncedVehicles = [];
            {
                if (_x isEqualType [] && {count _x >= 2} && {(_x select 0) isEqualTo "Sync"}) then {
                    private _peer = _x select 1;
                    if (_peer isEqualType objNull && {!isNull _peer} && {_peer isKindOf "AllVehicles"}) then {
                        private _group = group _peer;
                        if (!isNull _group) then {
                            _syncedGroups pushBackUnique _group;
                            {
                                if !((vehicle _x) isEqualTo _x) then {
                                    _syncedVehicles pushBackUnique (vehicle _x);
                                };
                            } forEach (units _group);
                        } else {
                            _syncedVehicles pushBackUnique _peer;
                        };
                    };
                };
            } forEach (get3DENConnections _module);

            private _moduleGroups = _editorGroups;
            private _moduleVehicles = _editorVehicles;
            if (_mode == "ADD") then {
                _moduleGroups = _syncedGroups;
                _moduleVehicles = _syncedVehicles;
            } else {
                if (_mode == "IGNORE") then {
                    _moduleGroups = _editorGroups - _syncedGroups;
                    _moduleVehicles = _editorVehicles - _syncedVehicles;
                };
            };
            if (_forEachIndex == 0) then {
                _takenGroups = _moduleGroups arrayIntersect _moduleGroups;
                _takenVehicles = _moduleVehicles arrayIntersect _moduleVehicles;
            } else {
                _takenGroups = _takenGroups arrayIntersect _moduleGroups;
                _takenVehicles = _takenVehicles arrayIntersect _moduleVehicles;
            };
        } forEach _virtualAIModules;
        if (count _modes == 1) then { _virtualAIMode = _modes select 0 };

        // A group becomes an entity profile of its leader's faction, and each vehicle
        // it is in becomes a vehicle profile of the vehicle's faction.
        private _profiledVehicles = [];
        {
            private _group = _x;
            private _leader = leader _group;
            private _units = units _group;
            private _leaderVehicle = vehicle _leader;
            if (!isNull _leader
                && {side _group != sideLogic}
                && {(_units findIf {[_x] call _isPlayerSlot}) < 0}
                && {(_units findIf {(typeOf _x) in _UNIT_BLACKLIST}) < 0}
                && {(_units findIf {[_x] call _ignoredInInit}) < 0}
                && {(_leaderVehicle isEqualTo _leader) || {!(_leaderVehicle in _combatSupportAssets)}}) then {
                _editorSourceFactions pushBackUnique (faction _leader);
                _editorSourceCount = _editorSourceCount + 1;
                {
                    private _vehicle = vehicle _x;
                    if !(_vehicle isEqualTo _x) then {
                        _editorSourceFactions pushBackUnique (faction _vehicle);
                        _profiledVehicles pushBackUnique _vehicle;
                    };
                } forEach _units;
            };
        } forEach _takenGroups;

        // An empty vehicle becomes a vehicle profile of its own faction. One with a
        // crew whose group was left out (a player's, say) isn't counted. At runtime a
        // vehicle players start in does get a vehicle profile when the Virtual AI
        // System takes it, but it gives the commander nothing to command, so a
        // commander whose faction has only that is still warned about.
        {
            private _vehicle = _x;
            if (!(_vehicle in _profiledVehicles)
                && {(crew _vehicle) isEqualTo []}
                && {!((typeOf _vehicle) in _VEHICLE_BLACKLIST)}
                && {!(_vehicle in _combatSupportAssets)}
                && {!([_vehicle] call _ignoredInInit)}
                && {(_PROFILED_KINDS findIf {_vehicle isKindOf _x}) >= 0}) then {
                _editorSourceFactions pushBackUnique (faction _vehicle);
                _editorSourceCount = _editorSourceCount + 1;
            };
        } forEach _takenVehicles;
    };

    // Per-trigger scoping: when the caller passes a non-empty _scope
    // list (OPCOM entities), only those OPCOMs are validated. Keeps
    // sync/attr feedback focused on the OPCOM the user just touched,
    // instead of surfacing pre-existing misconfigs on unrelated OPCOMs
    // in the scene every time anything changes.
    //
    // Empty _scope (preview trigger, or legacy callers) falls back to
    // every OPCOM collected during the global scan.
    private _opcomsToValidate = if (count _scope > 0) then { _scope } else { _opcomsAll };

    // Mission-building gate: if there are zero placement modules
    // in the entire scene and the Virtual AI System takes over no
    // editor units, the mission-maker is still setting up - no
    // point warning about missing profile sources for a mission
    // that has no forces at all. This also prevents false-positive
    // green "all OK" in a scene that hasn't been populated yet.
    // It skips check 1 for every OPCOM and leaves check 2 running.
    private _gated = _totalPlacements == 0 && {_editorSourceCount == 0};

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

        private _name = [_opcom, "ALiVE_mil_opcom_customName", "customName", ""] call _attr;
        if !(_name isEqualType "") then { _name = str _name };
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
                    private _pn = [_x, "ALiVE_mil_opcom_customName", "customName", ""] call _attr;
                    if !(_pn isEqualType "") then { _pn = str _pn };
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
                [[_msg] call _xmlSafe, 1, 60] call BIS_fnc_3DENNotification;
                [
                    "ALiVE 3DEN faction-source check: AI Commander '%1' has OPCOM-to-OPCOM sync peer(s)=[%2]",
                    _name,
                    _peerNames joinString ", "
                ] call ALiVE_fnc_dump;
                _warnings = _warnings + 1;
            };
        };

        private _opcomFactions = [_opcom] call _resolveOpcomFactions;

        // The mission-building gate above. continue, not exitWith: an
        // exitWith here ended the whole loop, so check 2 never ran for
        // the OPCOMs after the first.
        if (_gated) then { continue };

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
        private _unmatched = _opcomFactions select { !(_x in _globalSourceFactions) && {!(_x in _editorSourceFactions)} };
        private _matched = _opcomFactions - _unmatched;

        // Track which OPCOM factions DID have a source (for the
        // green OK toast listing).
        {
            if !(_x in _resolvedFactions) then {
                _resolvedFactions pushBack _x;
            };
        } forEach _matched;

        if (count _unmatched > 0) then {
            // Truncate to first 5 entries in the toast so a wildly-
            // misconfigured module doesn't spam a wall of text. Full
            // list still goes to diag_log.
            private _truncate = {
                params ["_list"];
                if (count _list > 5) then {
                    (_list select [0, 5]) + [format ["... (+%1 more)", (count _list) - 5]]
                } else {
                    _list
                }
            };
            private _truncated = [_unmatched] call _truncate;
            // The last way to give a faction forces depends on how the
            // Virtual AI System is set up: syncing a unit to it adds that
            // unit on its default, and leaves it out on IGNORE.
            private _unitsFix = if (_virtualAIMode == "IGNORE") then {
                "or placing units of that faction in the editor without syncing them to the Virtual AI System"
            } else {
                "or syncing editor-placed units of that faction to the Virtual AI System"
            };
            private _fix = format [
                "Fix by placing a Mil Placement (or similar) module with a matching faction in Place Units mode, selecting matching Force Factions on a custom objective, leaving a synced custom objective's Force Factions empty to inherit this Commander, %1.",
                _unitsFix
            ];
            // The commander only refuses to run when none of its factions
            // has anything. With some it runs and commands those alone.
            private _msg = if (count _matched == 0) then {
                format [
                    "ALiVE: AI Commander '%1' has no forces, so at runtime it will find no groups and refuse to run. Nothing in the mission gives its faction(s) [%2] any: no placement module places them in Place Units mode, and the Virtual AI System takes over no editor-placed units of theirs. %3",
                    _name,
                    _truncated joinString ", ",
                    _fix
                ]
            } else {
                format [
                    "ALiVE: AI Commander '%1' has no forces of faction(s) [%2]. It will still run, with [%3] only. No placement module places them in Place Units mode, and the Virtual AI System takes over no editor-placed units of theirs. %4",
                    _name,
                    _truncated joinString ", ",
                    ([_matched] call _truncate) joinString ", ",
                    _fix
                ]
            };
            // BIS_fnc_3DENNotification - 3DEN-native toast top-middle.
            // systemChat is NOT used - silently discarded in 3DEN
            // (chat overlay inactive).
            //
            // 60-second duration: message is long (lists factions plus
            // two-part fix guidance) and the mission-maker needs time
            // to read and act before the toast fades.
            // type 1 = Red warning, duration 60 seconds.
            [[_msg] call _xmlSafe, 1, 60] call BIS_fnc_3DENNotification;
            [
                "ALiVE 3DEN faction-source check: AI Commander '%1' unmatched=[%2] globalSources=[%3] editorUnitSources=[%4] virtualAIMode=%5",
                _name,
                _unmatched joinString ", ",
                _globalSourceFactions joinString ", ",
                _editorSourceFactions joinString ", ",
                _virtualAIMode
            ] call ALiVE_fnc_dump;
            _warnings = _warnings + 1;
        };
    } forEach _opcomsToValidate;

    // One-line "all clear" log so mission-makers + debug builds see
    // the validator actually ran.
    if (_warnings == 0) then {
        ["ALiVE 3DEN faction-source check: OK (checked=%1 totalPlacements=%2 editorUnitSources=%3)", _opcomsChecked, _totalPlacements, _editorSourceCount] call ALiVE_fnc_dump;

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
            [[_okMsg] call _xmlSafe, 0, 15] call BIS_fnc_3DENNotification;
        };
    };
};
