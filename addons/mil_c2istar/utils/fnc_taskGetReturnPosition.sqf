#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetReturnPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetReturnPosition

Description:
    Resolves the "return location" for tasks that need players to bring
    a hostage / pilot / package back to friendly territory (Rescue,
    CSAR, future similar tasks). Returns the friendly side's OPCOM
    main HQ position - i.e. wherever the mission-maker placed that
    side's ALiVE_mil_OPCOM module in Eden.

    Falls back to an empty array when no friendly OPCOM is placed,
    letting the caller use its legacy random-composition fallback.

    Side comparison normalises "RESISTANCE" -> "GUER" so the
    mil_opcom internal naming (RESISTANCE for the GUER side string)
    matches the task-side naming convention.

    It also ends the hand-over tasks (Extract Informant, VIP Escort, Aid
    Delivery, Supply Convoy) somewhere friendly instead of the next
    settlement, which can be full of hostiles (NeisAEL and A. Ares on
    Discord, 23 Oct). In order:
    1. a point the OP lead picked on the tablet map;
    2. with C2ISTAR's Delivery Destination on "fob" or "base", the
       side's nearest active Player FOB;
    3. on "base", the nearest objective the side's AI Commander holds
       (reserve, reserving or idle; not attacked or contested);
    4. the AI Commander HQ, on "fob" or "base", or when the caller
       asks for it on any setting (Rescue and CSAR, as before).
    Steps 2 to 4 skip anything closer than the given distance to the
    given position, so a FOB beside the pickup is not the hand-over
    (step 4 only on "fob" or "base").

Parameters:
    0: STRING - friendly side as "EAST" / "WEST" / "GUER" (task-side
                convention)
    1: ARRAY  - (optional) a point picked on the map, [] for none
    2: ARRAY  - (optional) position the FOB or objective is nearest to
    3: BOOL   - (optional) return [position, name] instead of the
                position; the name is the FOB's ("FOB Alpha") or ""
    4: ARRAY  - (optional) position to keep away from, [] for none
    5: NUMBER - (optional) how far from it, in metres
    6: BOOL   - (optional) fall back to the AI Commander HQ when the
                setting is "settlement" (default true)

Returns:
    ARRAY - position [x, y, z], or [] if nothing found
            ([position, name] when parameter 3 is true)

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_taskSide", "", [""]],
    ["_pick", []],
    ["_near", [], [[]]],
    ["_withName", false, [false]],
    ["_awayFrom", [], [[]]],
    ["_awayDistance", 0, [0]],
    ["_hqFallback", true, [false]]
];

private _result = [];
private _name = "";

if (_taskSide == "") exitWith { [_result, [_result, _name]] select _withName };

private _setting = missionNamespace getVariable ["ALIVE_taskDeliveryDestination", "settlement"];

// true when a candidate is far enough from the position to keep away from
private _farEnough = {
    params ["_pos"];
    _awayFrom isEqualTo [] || {(_pos distance2D _awayFrom) >= _awayDistance}
};

// 1. a picked map point is the requester's own choice and always wins
if (_pick isEqualType [] && {count _pick >= 2}) then {
    _result = +_pick;
};

// 2. the side's nearest active Player FOB, from the copy sup_fob shares with everyone
if (_result isEqualTo [] && {_setting in ["fob", "base"]}) then {
    private _rows = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select {
        (_x select 1) == _taskSide && {(_x select 4) == "active"} && {[_x select 3] call _farEnough}
    };
    if (_rows isNotEqualTo []) then {
        private _best = _rows select 0;
        if (_near isNotEqualTo []) then {
            private _bestDistance = 1e10;
            {
                private _distance = (_x select 3) distance2D _near;
                if (_distance < _bestDistance) then { _bestDistance = _distance; _best = _x };
            } forEach _rows;
        };
        _result = +(_best select 3);
        _name = _best select 2;
    };
};

// 3. the nearest objective the side's AI Commander holds, never one it is attacking or one that is contested
// (OPCOM sets defend/defending when both sides are there)
if (_result isEqualTo [] && {_setting == "base"}) then {
    private _bestDistance = 1e10;
    {
        private _opcomSide = if (_x isEqualType []) then { [_x, "side", ""] call ALiVE_fnc_HashGet } else { "" };
        if (_opcomSide == "RESISTANCE") then { _opcomSide = "GUER"; };
        if (_opcomSide == _taskSide) then {
            {
                private _center = [_x, "center", []] call ALiVE_fnc_HashGet;
                if (!([_x, "deleted", false] call ALiVE_fnc_HashGet)
                    && {([_x, "opcom_state", ""] call ALiVE_fnc_HashGet) in ["reserve", "reserving", "idle"]}
                    && {count _center >= 2}
                    && {[_center] call _farEnough}) then {
                    private _distance = if (_near isEqualTo []) then { 0 } else { _center distance2D _near };
                    if (_distance < _bestDistance) then { _bestDistance = _distance; _result = +_center };
                };
            } forEach ([_x, "objectives", []] call ALiVE_fnc_HashGet);
        };
    } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
};

// 4. the AI Commander HQ; on "settlement" the keep-away distance does not apply, so Rescue and CSAR keep
// today's behaviour
if (_result isEqualTo [] && {_setting != "settlement" || {_hqFallback}}) then {
    {
        private _handler = _x getVariable "handler";
        if (typeName _handler == "ARRAY") then {
            private _opcomSide = [_handler, "side"] call ALiVE_fnc_HashGet;
            if (typeName _opcomSide == "STRING") then {
                // Normalise the mil_opcom internal "RESISTANCE" alias to
                // the task-side "GUER" before comparing.
                if (_opcomSide == "RESISTANCE") then { _opcomSide = "GUER"; };
                if (_opcomSide == _taskSide && {_setting == "settlement" || {[getPos _x] call _farEnough}}) exitWith {
                    _result = getPos _x;
                };
            };
        };
    } forEach (allMissionObjects "ALiVE_mil_OPCOM");
};

[_result, [_result, _name]] select _withName
