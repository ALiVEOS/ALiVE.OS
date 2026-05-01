#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenValidateFactionCompilerSync);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_edenValidateFactionCompilerSync
Description:
Editor-time validator for sys_factioncompiler category modules. Walks each
ALiVE_sys_factioncompiler_category module's synced peers and flags any
non-Logic non-CAManBase entries (i.e. vehicles synced directly to the
category instead of the crew inside the vehicle).

The compiler's runtime captures groups via group _unit only when _unit
isKindOf "CAManBase" - vehicles get skipped silently, leaving a "no
template groups" outcome with no surface-level diagnostic. Mission-makers
who first encounter the compiler often sync vehicles thinking the vehicle
icon represents the unit (it doesn't - it represents the vehicle entity,
the crew is a separate unit inside it). This validator catches that
specific shape mismatch at editor time, before mission preview, with a
fix-guidance toast.

Trigger parameter (_this select 0, optional, default "attr"):
    "sync"    - fired from OnConnectingEnd; emits a green OK toast
                when no mismatches.
    "attr"    - fired from OnEntityAttributeChanged; emits a green
                OK toast when no mismatches.
    "preview" - fired from OnMissionPreview; skips green toast (user
                is about to launch the mission).

Scope parameter (_this select 1, optional, default []):
    Array of category module entities to restrict validation to. When
    non-empty, only those categories are checked. When empty, walks
    every category module in the scene.

Author:
Jman
---------------------------------------------------------------------------- */

if !(is3DEN) exitWith {};

params [["_trigger", "attr", [""]], ["_scope", [], [[]]]];

// Debounce: cancel any pending run and schedule a fresh one. Bulk
// connection ops fire OnConnectingEnd once per peer; a single Ctrl+G
// group on N units produces N events. Only the LAST scheduled run
// actually executes.
if (!isNil "ALIVE_edenCompilerSyncValidatorPending") then {
    terminate ALIVE_edenCompilerSyncValidatorPending;
};

ALIVE_edenCompilerSyncValidatorPending = [_trigger, _scope] spawn {
    params ["_trigger", "_scope"];
    sleep 0.5;

    private _CATEGORY_CLASS = "ALiVE_sys_factioncompiler_category";

    // Global scan for category modules. all3DENEntities returns mixed-
    // type buckets per current A3 docs - filter per-element to pick
    // only Object-typed entries.
    private _allCategories = [];
    {
        {
            if (_x isEqualType objNull && {!isNull _x} && {(typeOf _x) isEqualTo _CATEGORY_CLASS}) then {
                _allCategories pushBack _x;
            };
        } forEach _x;
    } forEach all3DENEntities;

    // Per-trigger scoping: when _scope is non-empty, restrict to those
    // categories. When empty (preview trigger or global re-audit), walk
    // every category in the scene.
    private _toCheck = if (count _scope > 0) then {
        _scope select { _x isEqualType objNull && {!isNull _x} && {(typeOf _x) isEqualTo _CATEGORY_CLASS} }
    } else {
        _allCategories
    };

    if (count _toCheck == 0) exitWith {};

    private _warnings = 0;
    private _checked = 0;

    {
        private _category = _x;
        private _categoryAttr = _category getVariable ["category", "Infantry"];

        // Use get3DENConnections to read editor-time syncs - the
        // synchronizedObjects engine command reads runtime-synced peers
        // and returns [] in pure-Eden context. Each connection entry
        // is shaped [type, peerObject].
        private _syncEntries = (get3DENConnections _category) select {
            _x isEqualType [] && {count _x >= 2} && {(_x select 0) == "Sync"}
        };
        private _peers = _syncEntries apply { _x select 1 };

        // Filter peers:
        //   - Logic-derived peers (the compiler module that owns this
        //     category) are EXPECTED, skip silently.
        //   - CAManBase peers (pilots, drivers, soldiers) are the
        //     valid template entries, skip silently.
        //   - Anything else (vehicles, statics, decorations) is the
        //     misuse pattern; collect for the warning.
        private _badPeers = _peers select {
            _x isEqualType objNull
            && {!isNull _x}
            && {!(_x isKindOf "Logic")}
            && {!(_x isKindOf "CAManBase")}
        };

        _checked = _checked + 1;

        if (count _badPeers > 0) then {
            private _types = _badPeers apply { typeOf _x };
            private _truncated = if (count _types > 5) then {
                (_types select [0, 5]) + [format ["... (+%1 more)", (count _types) - 5]]
            } else {
                _types
            };
            // Parentheses not angle brackets - BIS_fnc_3DENNotification
            // parses content as XML and truncates at the first `<`.
            private _msg = format [
                "ALiVE: Faction Compiler Category '%1' has %2 vehicle(s) synced directly: [%3]. Sync the CREW unit (e.g. pilot, driver, gunner) INSIDE each vehicle, not the vehicle itself. Group the crew first, then sync ONE crew member per group to this category module.",
                _categoryAttr,
                count _badPeers,
                _truncated joinString ", "
            ];
            // type 1 = Red warning, duration 60 seconds.
            [_msg, 1, 60] call BIS_fnc_3DENNotification;
            diag_log format [
                "ALiVE 3DEN compiler-sync check: category '%1' has non-CAManBase peers=[%2]",
                _categoryAttr,
                _types joinString ", "
            ];
            _warnings = _warnings + 1;
        };
    } forEach _toCheck;

    if (_warnings == 0) then {
        diag_log format ["ALiVE 3DEN compiler-sync check: OK (checked=%1)", _checked];

        // Positive confirmation toast on sync/attr triggers. Preview
        // skips the green toast - user is about to launch the mission
        // and gets the warnings (if any) loud.
        if ((_trigger in ["sync", "attr"]) && {_checked > 0}) then {
            private _okMsg = format [
                "ALiVE: Faction Compiler Category sync OK. %1 categor(ies) have valid CAManBase template units synced.",
                _checked
            ];
            // type 0 = Green notification, duration 15 seconds.
            [_okMsg, 0, 15] call BIS_fnc_3DENNotification;
        };
    };
};
