#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(intelLog);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_intelLog

Description:
Tablet Intel Log on the C2ISTAR module (Eric on Discord, 25 Oct): a record of the intel each side's players were
shown or told, listed on the tablet's Intel page with its time and grid after the map marker has gone. Only what
players already saw is written, at the place they were shown it, so a civilian's ellipse or a decoy is logged as
the ellipse or the decoy and the log never gives a lie away. The store lives on the server. With the setting off
nothing is written.

Parameters:
    STRING - "add", "list", "state" or "restore"
    ARRAY  - "add": [side text, faction, kind, position, title, detail, source, key]
                 key (optional): a report with the same side and key replaces the older one and counts it
                 ("reported 3 times") instead of adding a row; used for installation reveals
             "list": [side text, faction, limit ("SIDE", "FACTION" or "ALL")]
             "restore": [saved state]

Returns:
    "list": rows, newest first: [dtg, grid, kind, position, title, detail, times reported]
    "state": the store as an ALiVE hash, for the save

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_args", []]];

private _norm = { if (_this in ["RESISTANCE", "INDEPENDENT"]) then { "GUER" } else { _this } };
private _cap = 150;

// rows: [seq, dtg, side, faction, kind, pos, grid, title, detail, source, key, count]
if (isNil "ALiVE_c2istar_intelLog") then { ALiVE_c2istar_intelLog = [0, []] };

switch (_op) do {
    case "add": {
        if (!isServer) exitWith { ["add", _args] remoteExecCall ["ALIVE_fnc_intelLog", 2] };
        if !(missionNamespace getVariable ["ALiVE_c2istar_intelLogEnabled", false]) exitWith {};
        _args params [["_side", "", [""]], ["_faction", "", [""]], ["_kind", "", [""]], ["_pos", [], [[]]],
            ["_title", "", [""]], ["_detail", "", [""]], ["_source", "", [""]], ["_key", "", [""]]];
        // no side given, nobody to show it to
        if (count _pos < 2 || {_side == ""}) exitWith {};
        _side = toUpper _side call _norm;
        _pos = [_pos select 0, _pos select 1, 0];
        ALiVE_c2istar_intelLog params ["_seq", "_rows"];
        _seq = _seq + 1;
        ALiVE_c2istar_intelLog set [0, _seq];
        private _count = 1;
        if (_key != "") then {
            private _i = _rows findIf { (_x select 2) == _side && {(_x select 10) == _key} };
            if (_i > -1) then { _count = ((_rows select _i) select 11) + 1; _rows deleteAt _i };
        };
        _rows pushBack [_seq, [date] call ALIVE_fnc_dateToDTG, _side, _faction, _kind, _pos, mapGridPosition _pos,
            _title, _detail, _source, _key, _count];
        // a cap per side, so a busy side never pushes another side's reports out; rows are kept oldest first
        private _mine = _rows select { (_x select 2) == _side };
        if (count _mine > _cap) then {
            private _drop = (_mine select [0, count _mine - _cap]) apply { _x select 0 };
            ALiVE_c2istar_intelLog set [1, _rows select { !((_x select 0) in _drop) }];
        };
        ["C2ISTAR - intel log: %1 %2 %3 %4 (%5)", _side, _kind, mapGridPosition _pos, _title, _count] call ALiVE_fnc_Dump;
    };
    case "list": {
        _args params [["_side", "", [""]], ["_faction", "", [""]], ["_limit", "SIDE", [""]]];
        _side = toUpper _side call _norm;
        private _rows = (ALiVE_c2istar_intelLog select 1) select {
            private _s = _x select 2;
            private _f = _x select 3;
            switch (toUpper _limit) do {
                case "ALL": { true };
                // a report made on the server has no faction: it goes by side
                case "FACTION": { _s == "ALL" || {_s == _side && {_f == "" || {_f == _faction}}} };
                default { _s == "ALL" || {_s == _side} };
            };
        };
        reverse _rows;
        _rows apply { [_x select 1, _x select 6, _x select 4, _x select 5, _x select 7, _x select 8, _x select 11] }
    };
    case "state": {
        [[["seq", ALiVE_c2istar_intelLog select 0], ["rows", ALiVE_c2istar_intelLog select 1]]] call ALIVE_fnc_hashCreate
    };
    case "restore": {
        _args params [["_state", []]];
        if !([_state] call ALIVE_fnc_isHash) exitWith {};
        private _seq = [_state, "seq", 0] call ALIVE_fnc_hashGet;
        private _saved = +([_state, "rows", []] call ALIVE_fnc_hashGet);
        if !(_seq isEqualType 0 && {_saved isEqualType []}) exitWith {};
        // reports made since the mission started go after the saved ones
        private _since = (ALiVE_c2istar_intelLog select 1) apply { private _r = +_x; _r set [0, (_r select 0) + _seq]; _r };
        ALiVE_c2istar_intelLog = [_seq + (ALiVE_c2istar_intelLog select 0), _saved + _since];
        ["C2ISTAR - intel log: %1 saved reports loaded, %2 since start kept", count _saved, count _since] call ALiVE_fnc_Dump;
    };
};
