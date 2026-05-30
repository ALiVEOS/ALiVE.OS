#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPClient);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPClient

Description:
    Client-side COP init. Runs once per player on mission start (and after
    each respawn side cache refresh).

    Responsibilities:
      1. Cache player side key (ALIVE_COP_playerSideKey) — used by
         COPDrawAll and COPDrawSentimentHeat to filter side-specific data.
      2. Pre-format publicVariable channel names so the Draw EH doesn't call
         format per frame.
      3. Register a Respawn handler on the player so the side cache stays
         fresh after side switches (which can happen on certain missions).
      4. Register a `Map` mission event handler. When the player opens the
         map for the first time, attach a Draw EH to the main map control
         (findDisplay 12 displayCtrl 51) calling ALIVE_fnc_COPDrawAll each
         frame.

    Re-invocation safety: guarded by ALIVE_COP_DrawEHAttached (flag) so the
    Draw EH is only attached once per mission session, even if COPClient is
    called multiple times.

Parameters:
    0: STRING - Player's resolved side text ("WEST"/"EAST"/"GUER").

Returns:
    BOOL - true when init has completed.

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

TRACE_1("COPClient - input",_this);

if (!hasInterface) exitWith {
    ["warn", "client", "COPClient invoked on non-interface machine"] call ALIVE_fnc_COPLog;
    false
};

params [["_sideText", "", [""]]];

["info", "client", "Initialising COP client..."] call ALIVE_fnc_COPLog;

// ============================================================================
// CACHE PLAYER SIDE KEY
// ============================================================================
waitUntil { !isNull player };
waitUntil { player == player };  // Forces resolve when Virtual Player is swapped in.

// Prefer the side string supplied by fnc_C2ISTAR.sqf if valid; otherwise
// derive from the player's group side. fnc_C2ISTAR already handles the
// CIV-player edge case (resolves civilian-faction players to a side).
private _resolved = if (_sideText in ["WEST", "EAST", "GUER"]) then {
    _sideText
} else {
    [side group player] call ALIVE_fnc_COPGetSideKey
};

ALIVE_COP_playerSideKey = _resolved;

// Pre-format the publicVariable channel names — Draw EH reads these each
// frame, so resolving the format string once at init is a real saving.
// Single-side var names kept for back-compat (used by the respawn EH and
// any callers reading these directly).
ALIVE_COP_intelVar_intel = format ["ALiVE_COP_IntelData_%1", ALIVE_COP_playerSideKey];
ALIVE_COP_intelVar_bft   = format ["ALiVE_COP_BftData_%1",   ALIVE_COP_playerSideKey];
ALIVE_COP_intelVar_obj   = format ["ALiVE_COP_ObjectivesData_%1", ALIVE_COP_playerSideKey];

// Mission-maker side filter: CSV from `copDisplaySides` Eden attribute
// (e.g. "WEST,EAST"). Empty = default to player's own side only. Parse to
// a list of side keys and pre-build the per-side var-name lists the Draw
// EH iterates and concatenates — same one-format-per-init optimisation as
// the single-side vars above, but extended for the multi-side case.
private _displaySidesCsv = missionNamespace getVariable ["ALIVE_COP_DISPLAY_SIDES_CSV", ""];
private _displaySides = if (_displaySidesCsv != "") then {
    private _parsed = _displaySidesCsv call ALiVE_fnc_stringListToArray;
    _parsed = _parsed apply { toUpper _x };
    _parsed select { _x in ["WEST", "EAST", "GUER", "CIV"] }
} else {
    [ALIVE_COP_playerSideKey]
};
// Final defence: if parsing somehow produced an empty list, fall back to
// the player's own side so the COP overlay always renders something.
if (count _displaySides == 0) then { _displaySides = [ALIVE_COP_playerSideKey] };

ALIVE_COP_displaySideKeys = _displaySides;
ALIVE_COP_intelVars_intelList = _displaySides apply { format ["ALiVE_COP_IntelData_%1",      _x] };
ALIVE_COP_intelVars_bftList   = _displaySides apply { format ["ALiVE_COP_BftData_%1",        _x] };
ALIVE_COP_intelVars_objList   = _displaySides apply { format ["ALiVE_COP_ObjectivesData_%1", _x] };

// Command View toggle state — per-client, defaults to mirror the Eden
// gate (`ALIVE_COP_CommandViewEnabled`) so a mission-maker setting
// "Yes" gives players the wide view straight away rather than asking
// them to flip a toggle on every spawn. Players can still turn it OFF
// locally via the ALiVE menu if they want a tighter view; the toggle
// state persists across respawn (the isNil guard preserves whatever
// the player last chose) but resets on a fresh mission load. c2_item
// eligibility and the Eden gate are re-checked at menu-render time
// upstream of this flag.
if (isNil "ALIVE_COP_CommandViewOn") then {
    ALIVE_COP_CommandViewOn = missionNamespace getVariable ["ALIVE_COP_CommandViewEnabled", false];
};

["info", "client", "Player side cached: %1 (player: %2) | display sides: %3",
    [ALIVE_COP_playerSideKey, name player, _displaySides]] call ALIVE_fnc_COPLog;

// ============================================================================
// RESPAWN HANDLER — refresh the side cache
// ============================================================================
// Per-unit "Respawn" event attached to the player object. Arma 3 reuses the
// player unit handle across respawn (the body resurrects rather than spawning
// a new handle), so the EH stays attached and fires on every subsequent
// respawn. Params: [respawnedUnit, oldCorpse]. The codebase uses this same
// pattern in MPScenarios for stamina / aimCoef / chemLight init.
if (isNil "ALIVE_COP_RespawnEHIndex") then {
    ALIVE_COP_RespawnEHIndex = player addEventHandler ["Respawn", {
        params ["_newUnit", "_oldUnit"];
        ALIVE_COP_playerSideKey = [side group _newUnit] call ALIVE_fnc_COPGetSideKey;
        ALIVE_COP_intelVar_intel = format ["ALiVE_COP_IntelData_%1", ALIVE_COP_playerSideKey];
        ALIVE_COP_intelVar_bft   = format ["ALiVE_COP_BftData_%1",   ALIVE_COP_playerSideKey];
        ALIVE_COP_intelVar_obj   = format ["ALiVE_COP_ObjectivesData_%1", ALIVE_COP_playerSideKey];
        ["info", "client", "Side cache refreshed on respawn: %1", [ALIVE_COP_playerSideKey]] call ALIVE_fnc_COPLog;
    }];
    ["debug", "client", "Respawn EH registered on player (index %1)", [ALIVE_COP_RespawnEHIndex]] call ALIVE_fnc_COPLog;
};

// ============================================================================
// MAP MISSION EVENT HANDLER — attach the Draw EH on first map open
// ============================================================================
// Event-driven (no 1 Hz polling). Fires whenever the player opens or closes
// the map. Arma 3 behaviour: display 12 (the map dialog container) may be
// recreated on each map-open, but the underlying map CONTROL at idc 51
// persists within the session — Draw EHs attached to it survive close/open
// cycles. So we attach once on the first open and use ALIVE_COP_DrawEHAttached
// to prevent duplicate EH registration on subsequent opens.
if (isNil "ALIVE_COP_DrawEHAttached") then {
    ALIVE_COP_DrawEHAttached = false;
};

if (isNil "ALIVE_COP_MapMEHIndex") then {
    ALIVE_COP_MapMEHIndex = addMissionEventHandler ["Map", {
        params ["_mapIsOpened", "_mapIsForced"];

        if (!_mapIsOpened) exitWith {};
        if (ALIVE_COP_DrawEHAttached) exitWith {};

        private _mapDisplay = findDisplay 12;
        if (isNull _mapDisplay) exitWith {
            ["warn", "client", "Map open event fired but findDisplay 12 is null — cannot attach"] call ALIVE_fnc_COPLog;
        };

        private _mapCtrl = _mapDisplay displayCtrl 51;
        if (isNull _mapCtrl) exitWith {
            ["warn", "client", "Map display exists but ctrl 51 is null — cannot attach"] call ALIVE_fnc_COPLog;
        };

        _mapCtrl ctrlAddEventHandler ["Draw", {
            params ["_mapCtrl"];
            [_mapCtrl] call ALIVE_fnc_COPDrawAll;
        }];

        ALIVE_COP_DrawEHAttached = true;

        // Snapshot data counts on attach for diagnostic visibility.
        private _intelW = missionNamespace getVariable ["ALiVE_COP_IntelData_WEST", []];
        private _intelE = missionNamespace getVariable ["ALiVE_COP_IntelData_EAST", []];
        private _bftMy  = missionNamespace getVariable [ALIVE_COP_intelVar_bft, []];
        private _objMy  = missionNamespace getVariable [ALIVE_COP_intelVar_obj, []];
        private _asymA  = missionNamespace getVariable ["ALiVE_COP_AsymActivityData", []];

        ["info", "client", "Draw EH attached on first map open — anchor %1m | data: intelW=%2 intelE=%3 myBFT=%4 myObj=%5 asymA=%6",
            [missionNamespace getVariable ["ALIVE_COP_ANCHOR_DISTANCE", 1000],
             count _intelW, count _intelE, count _bftMy, count _objMy, count _asymA]
        ] call ALIVE_fnc_COPLog;
    }];
    ["debug", "client", "Map mission event handler registered (index %1)", [ALIVE_COP_MapMEHIndex]] call ALIVE_fnc_COPLog;
};

["info", "client", "Init complete."] call ALIVE_fnc_COPLog;

private _result = true;
TRACE_1("COPClient - output",_result);
_result
