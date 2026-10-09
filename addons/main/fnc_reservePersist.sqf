#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(reservePersist);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_reservePersist

Description:
    Keeps the placement modules' unwoken reserves across a persistent save.

    The reserve pools are built only while a module places its forces, and a
    persistent load skips placement, so every reserve not yet woken was lost
    on a reload. A vehicle reserve's parked vehicle came back (it is a
    profile) but its crew, held in the pool, did not, so it stayed parked,
    empty and locked for good.

    "save" lists each module's objectives that still hold reserves, for the
    mission store the Data module writes. "restore" rebuilds a module's
    objectives from that list on a persistent load and starts their watcher.

    A module is matched by its class and its position, rounded to the metre:
    the same module in the same mission. Buildings an objective had locked
    after players were near them are not kept: they are only marked again.

Parameters:
    _this select 0: STRING - "save" or "restore"
    _this select 1: OBJECT - the placement module logic ("restore")
    _this select 2: CODE   - the module's MAINCLASS function ("restore")

Returns:
    "save": ARRAY - [[module key, [[centre, size, pool, activeAtSpawn, activeProfileIDs], ...]], ...]
    "restore": NUMBER - reserve entries brought back

Examples:
    (begin example)
    private _saved = ["save"] call ALIVE_fnc_reservePersist;
    ["restore", _logic, MAINCLASS] call ALIVE_fnc_reservePersist;
    (end)

See Also:
    ALIVE_fnc_reserveWatch, ALIVE_fnc_activateReserve

Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_op", "", [""]],
    ["_logic", objNull, [objNull]],
    ["_modClass", {}, [{}]]
];

private _fnc_key = {
    params ["_m"];
    format ["%1|%2", typeOf _m, (getPosATL _m) apply { round _x }]
};

switch (_op) do {

    case "save": {
        private _out = [];
        {
            private _m = _x;
            if (!isNull _m) then {
                private _rows = [];
                {
                    private _pool = [_x, "reservePool", []] call ALiVE_fnc_hashGet;
                    if (count _pool > 0) then {
                        _rows pushBack [
                            [_x, "center"] call ALiVE_fnc_hashGet,
                            [_x, "size", 200] call ALiVE_fnc_hashGet,
                            +_pool,
                            [_x, "reserveActiveAtSpawn", 0] call ALiVE_fnc_hashGet,
                            +([_x, "activeProfileIDs", []] call ALiVE_fnc_hashGet)
                        ];
                    };
                } forEach (_m getVariable ["ALiVE_reserveClusters", []]);
                if (count _rows > 0) then { _out pushBack [[_m] call _fnc_key, _rows] };
            };
        } forEach (missionNamespace getVariable ["ALiVE_reserveModules", []]);
        _out
    };

    case "restore": {
        if (isNull _logic || {isNil "ALiVE_fnc_getData"} || {isNil "ALiVE_sys_data_mission_data"}) exitWith { 0 };
        private _saved = ["ALiVE_reservePools"] call ALiVE_fnc_getData;
        if (isNil "_saved" || {!(_saved isEqualType [])}) exitWith { 0 };
        private _key = [_logic] call _fnc_key;
        private _i = _saved findIf { _x isEqualType [] && {(_x param [0, ""]) isEqualTo _key} };
        if (_i < 0) exitWith { 0 };

        private _hasProfile = { !isNil {[ALIVE_profileHandler, "getProfile", _this] call ALIVE_fnc_profileHandler} };
        private _clusters = [];
        private _count = 0;
        {
            _x params [["_center", [0,0,0]], ["_size", 200], ["_pool", []], ["_activeAtSpawn", 0], ["_activeIDs", []]];
            // A vehicle reserve needs its parked vehicle and the empty group its crew joins. With the
            // vehicle gone its people come on foot, as when the vehicle is destroyed before it wakes;
            // with the group gone there is nothing for the crew to join, so they come on foot too.
            private _keep = [];
            {
                if ((_x param [0, ""]) isEqualTo "VEHICLE") then {
                    _x params ["", "_group", "_vehID", "_entID", "_faction", "_onSpawn", "_onSpawnOnce"];
                    if (_entID call _hasProfile || {!(_vehID call _hasProfile)}) then {
                        _keep pushBack _x;
                    } else {
                        _keep pushBack ["INFANTRY", _group, _faction, _onSpawn, _onSpawnOnce];
                    };
                } else {
                    _keep pushBack _x;
                };
            } forEach _pool;
            if (count _keep > 0) then {
                private _c = [] call ALiVE_fnc_hashCreate;
                [_c, "center", _center] call ALiVE_fnc_hashSet;
                [_c, "size", _size] call ALiVE_fnc_hashSet;
                [_c, "reservePool", _keep] call ALiVE_fnc_hashSet;
                [_c, "reserveActiveAtSpawn", _activeAtSpawn] call ALiVE_fnc_hashSet;
                [_c, "activeProfileIDs", _activeIDs] call ALiVE_fnc_hashSet;
                [_c, "lastReserveWake", -999] call ALiVE_fnc_hashSet;
                [_c, "reserveModule", _logic] call ALiVE_fnc_hashSet;
                [_c, "reserveModuleClass", _modClass] call ALiVE_fnc_hashSet;
                _clusters pushBack _c;
                _count = _count + count _keep;
            };
        } forEach ((_saved select _i) param [1, []]);

        if (_clusters isNotEqualTo []) then {
            [_clusters, _logic] call ALIVE_fnc_reserveWatch;
            ["%1 - %2 reserves waiting at %3 objectives brought back from the save", typeOf _logic, _count, count _clusters] call ALiVE_fnc_dump;
        };
        _count
    };

    default { [] };
};
