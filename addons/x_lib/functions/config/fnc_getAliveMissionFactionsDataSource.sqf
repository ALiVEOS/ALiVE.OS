#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getAliveMissionFactionsDataSource);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getAliveMissionFactionsDataSource

Description:
    Returns a faction datasource (options/values pair) filtered to only those
    factions registered by OPCOM instances that are ENEMY to the calling player's
    side in the current mission.

    Walks all entries in OPCOM_instances. For each OPCOM hash, checks whether
    the local player's side text appears in that OPCOM's "sidesenemy" array. Only
    factions from hostile OPCOMs are collected. The full CfgFactionClasses
    datasource is then filtered to only include those faction classes.

    Side text comparison uses the same "EAST"/"WEST"/"GUER" normalisation that
    OPCOM uses internally (RESISTANCE is stored as GUER).

    If OPCOM_instances is undefined or empty (e.g. called before OPCOM init),
    returns empty options/values arrays so callers can fall back to the
    unfiltered ALiVE_fnc_getFactionsDataSource.

Parameters:
    None — uses 'player' to determine calling side

Returns:
    Array - [[options,...],[values,...]]
        options - display strings in the form "Faction Name - SIDE"
        values  - faction classname strings

Examples:
(begin example)
_datasource = [] call ALiVE_fnc_getAliveMissionFactionsDataSource;
_options = _datasource select 0;
_values  = _datasource select 1;
(end)

See Also:
    ALiVE_fnc_getFactionsDataSource

Author:
    Jman

Peer reviewed:
    nil
---------------------------------------------------------------------------- */

private _data    = [];
private _options = [];
private _values  = [];

// --- 1. Determine the calling player's side as the same text format OPCOM uses ---
// OPCOM stores sides as "EAST", "WEST", "GUER" (RESISTANCE normalised to GUER)
private _playerSideObj  = side group player;
private _playerSideText = [_playerSideObj] call ALIVE_fnc_sideObjectToNumber;
_playerSideText         = [_playerSideText] call ALIVE_fnc_sideNumberToText;
// ALIVE_fnc_sideNumberToText returns "GUER" for resistance — matches OPCOM storage

// --- 2. Collect faction classnames from OPCOM instances that are enemy to the player ---
private _missionFactions = [];

{
    if (_x isEqualType []) then {
        // "sidesenemy" is populated by OPCOM init using getFriend < 0.6 against all sides
        private _sidesEnemy = [_x, "sidesenemy", []] call ALIVE_fnc_hashGet;

        if (_playerSideText in _sidesEnemy) then {
            private _factions = [_x, "factions", []] call ALIVE_fnc_hashGet;
            {
                if ((_x isEqualType "") && {!(_x isEqualTo "")} && {!(_x in _missionFactions)}) then {
                    _missionFactions pushBack _x;
                };
            } forEach _factions;
        };
    };
} forEach (missionNamespace getVariable ["OPCOM_instances", []]);
// a player's machine on a dedicated server has no commanders of its own: the server publishes what each one fights
// as [sides enemy, factions] (NeisAEL on Discord, 23 Oct: the filter listed every faction there)
if ((missionNamespace getVariable ["OPCOM_instances", []]) isEqualTo []) then {
    {
        _x params [["_sidesEnemy", []], ["_factions", []]];
        if (_playerSideText in _sidesEnemy) then {
            { if ((_x isEqualType "") && {!(_x isEqualTo "")} && {!(_x in _missionFactions)}) then { _missionFactions pushBack _x } } forEach _factions;
        };
    } forEach (missionNamespace getVariable ["ALiVE_OPCOM_factionsPublic", []]);
};

// Debug logging
if (missionNamespace getVariable ["ALIVE_c2istar_filterEnemyFactions_debug", false]) then {
    ["ALiVE_fnc_getAliveMissionFactionsDataSource - player side: %1 | enemy factions collected from OPCOM_instances: %2", _playerSideText, _missionFactions] call ALiVE_fnc_dump;
};

// If no enemy factions found return empty arrays — caller handles fallback
if (_missionFactions isEqualTo []) exitWith {
    _data set [0, _options];
    _data set [1, _values];
    _data
};

// --- 3. Walk CfgFactionClasses and include only the enemy mission factions ---
private _factionConfig = configfile >> "CfgFactionClasses";

for "_i" from 0 to (count _factionConfig - 1) do {
    private _class = _factionConfig select _i;

    if (isClass _class) then {
        private _factionClass = configName _class;

        if (_factionClass in _missionFactions) then {
            private _classSide     = getNumber (_class >> "side");
            private _classSideText = [_classSide] call ALIVE_fnc_sideNumberToText;
            _classSideText         = [_classSideText] call ALIVE_fnc_sideTextToLong;
            private _factionName   = getText (_class >> "displayName");

            _options pushBack (format ["%1 - %2", _factionName, _classSideText]);
            _values  pushBack _factionClass;
        };
    };
};

_data set [0, _options];
_data set [1, _values];

_data
