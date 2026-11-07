#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(reportsForWarRoom);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_reportsForWarRoom

Description:
Every SPOTREP, SITREP and PATROLREP the players have filed, read from the server's
own copy of each store, as plain rows for the War Room's live map. The stores are
ALiVE hashes whose keys carry each module's prefix; this keeps that layout out of
the War Room's code. Player IDs are left out.

Row:
  [kind, name, scope, scopeValue, positions, dtg, callsign, fields]
  kind       - "SPOTREP", "SITREP" or "PATROLREP"
  name       - the report's own key, steady while it exists
  scope      - who sees it in game: "SIDE", "GROUP", "FACTION", "GLOBAL" or "LOCAL"
  scopeValue - the side ("WEST"), group or faction it was sent to, "" when global
  positions  - [[x, y]] for a SPOTREP (its marker) or a SITREP; [[x, y], [x, y]] start
               and end for a PATROLREP; [] when none was given
  dtg        - the date-time group the player's report shows
  callsign   - as typed
  fields     - [[key, value], ...] the rest, keys without the module prefix
               (e.g. ["type", "Armour"], ["remarks", "..."], ["ekia", "3"])

Parameters:
None

Returns:
Array - rows as above; [] on a client or with none of the modules placed

Examples:
(begin example)
if (!isNil "ALiVE_fnc_reportsForWarRoom") then { _rows = [] call ALiVE_fnc_reportsForWarRoom };
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith { [] };

// fields the row carries in its own columns, or that a player's ID or the editing UI keeps
private _skip = ["player", "locality", "localityvalue", "dtg", "callsign", "pos", "spos", "epos", "markername",
    "localityindex", "factionindex", "sizeindex", "typeindex", "activityindex", "factivityindex", "factioncfg", "typecfg"];

private _rows = [];
{
    _x params ["_kind", "_store", "_prefix"];
    private _hash = missionNamespace getVariable [_store, nil];
    if (!isNil "_hash" && {_hash isEqualType []} && {count _hash > 2}) then {
        private _plen = count _prefix;
        {
            private _name = _x;
            private _report = (_hash select 2) select _forEachIndex;
            if (_report isEqualType [] && {count _report > 2}) then {
                private _keys = _report select 1;
                private _values = _report select 2;
                private _get = {
                    private _i = _keys findIf { _x == (_prefix + _this) };
                    if (_i < 0) then { nil } else { _values select _i }
                };
                private _xy = {
                    if (isNil "_this" || {!(_this isEqualType [])} || {count _this < 2}) exitWith { [] };
                    [round (_this select 0), round (_this select 1)]
                };
                private _positions = switch (_kind) do {
                    case "SITREP": { [("pos" call _get) call _xy] };
                    case "PATROLREP": { [("spos" call _get) call _xy, ("epos" call _get) call _xy] };
                    default {
                        // a SPOTREP sits on the player's map marker
                        private _marker = "markername" call _get;
                        private _markers = missionNamespace getVariable ["ALiVE_sys_marker_STORE", nil];
                        private _pos = nil;
                        if (!isNil "_marker" && {!isNil "_markers"}) then {
                            // keys compared with == so their case doesn't matter (hashGet's find is case-sensitive)
                            private _mi = (_markers select 1) findIf { _x == _marker };
                            if (_mi >= 0) then {
                                private _m = (_markers select 2) select _mi;
                                private _pi = (_m select 1) findIf { _x == "ALiVE_SYS_marker_pos" };
                                if (_pi >= 0) then { _pos = (_m select 2) select _pi };
                            };
                        };
                        [_pos call _xy]
                    };
                };
                _positions = _positions select { _x isNotEqualTo [] };
                private _fields = [];
                {
                    private _k = toLower _x;
                    if ((_k find (toLower _prefix)) == 0) then {
                        private _short = _k select [_plen];
                        if !(_short in _skip) then {
                            private _v = _values select _forEachIndex;
                            if (_v isEqualType "" || {_v isEqualType 0} || {_v isEqualType true}) then { _fields pushBack [_short, _v] };
                        };
                    };
                } forEach _keys;
                private _scope = "locality" call _get;
                private _scopeValue = "localityValue" call _get;
                private _dtg = "DTG" call _get;
                private _callsign = "callsign" call _get;
                _rows pushBack [
                    _kind, _name,
                    if (isNil "_scope") then { "SIDE" } else { _scope },
                    if (isNil "_scopeValue") then { "" } else { if (_scopeValue isEqualType "") then { _scopeValue } else { str _scopeValue } },
                    _positions,
                    if (isNil "_dtg") then { "" } else { _dtg },
                    if (isNil "_callsign") then { "" } else { _callsign },
                    _fields
                ];
            };
        } forEach (_hash select 1);
    };
} forEach [
    ["SPOTREP", "ALiVE_sys_spotrep_STORE", "ALiVE_sys_spotrep_"],
    ["SITREP", "ALiVE_sys_sitrep_STORE", "ALiVE_sys_sitrep_"],
    ["PATROLREP", "ALiVE_sys_patrolrep_STORE", "ALiVE_sys_patrolrep_"]
];
_rows
