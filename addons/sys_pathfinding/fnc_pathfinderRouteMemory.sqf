#include "\x\alive\addons\sys_pathfinding\script_component.hpp"
SCRIPT(pathfinderRouteMemory);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_pathfinderRouteMemory

Description:
Route memory (#1086, proposed by Goldwep). Ground routes remember where a side
has been hurt and, on top of that, vary a little from one request to the next,
so two groups sent the same way don't walk the identical line and a road that
keeps costing a side lives is avoided for a while.

Danger: a group wiped out (PROFILE_KILLED) or a land vehicle destroyed adds 1
to the coarse sector it happened in and 0.5 to the eight round it; each man
lost adds 0.25, and each attack on one of a side's groups 0.1 where the group
stands. Losses in aircraft and boats add nothing. Danger halves every two hours
of simulation time and is not saved, so a reload starts with none. A sector's cost for that side is multiplied by
1 + (ceiling - 1) * (1 - e^-danger), so it rises quickly at first and never
passes the ceiling.

Variation: each request draws its own random field over a 2 km lattice,
smoothly interpolated, and multiplies sector costs by 1 +/- the amplitude.

Both are computed once per coarse sector per request and shared by the coarse
and fine searches, so the fine search refines a route built with the same
costs. Off (the default) builds nothing and routes exactly as before.

Parameters:
Any - logic (unused) or the event listener
String - operation: "init", "handleEvent", "deposit", "jobContext", "factor"
Any - arguments

Returns:
Any - see each operation

Author:
Jman
---------------------------------------------------------------------------- */

#define RM_LATTICE 2000
#define RM_KILL_WEIGHT 1
#define RM_ATTACK_WEIGHT 0.1

params ["_logic", ["_operation", ""], ["_args", []]];

private _result = nil;

switch (_operation) do {

    // Read the setting, start the danger table and listen for deaths and attacks. Server only.
    case "init": {
        private _mode = toLower (if (_args isEqualType "") then { _args } else { "off" });
        if !(_mode in ["off", "low", "high"]) then { _mode = "off" };
        ALiVE_pathfinding_routeMemory = _mode;
        // amplitude of the variation and danger ceiling per level; isNil-guarded so a console override survives
        if (isNil "ALiVE_pathfinding_routeMemoryLevels") then {
            ALiVE_pathfinding_routeMemoryLevels = createHashMapFromArray [["low", [0.14, 3]], ["high", [0.28, 5]]];
        };
        if (isNil "ALiVE_pathfinding_routeMemoryHalfLife") then { ALiVE_pathfinding_routeMemoryHalfLife = 7200 };
        if (_mode == "off") exitWith {};
        if (isNil "ALiVE_routeMemory_danger") then { ALiVE_routeMemory_danger = createHashMap };
        if (isNil "ALiVE_routeMemory_listenerID" && {!isNil "ALiVE_eventLog"}) then {
            private _listener = [] call ALiVE_fnc_hashCreate;
            [_listener, "class", "ALiVE_fnc_pathfinderRouteMemory"] call ALiVE_fnc_hashSet;
            ALiVE_routeMemory_listenerID = [ALiVE_eventLog, "addListener", [_listener, ["PROFILE_KILLED", "PROFILE_ATTACK_START"]]] call ALiVE_fnc_eventLog;
        };
    };

    case "handleEvent": {
        private _type = [_args, "type"] call ALiVE_fnc_hashGet;
        private _data = [_args, "data"] call ALiVE_fnc_hashGet;
        switch (_type) do {
            case "PROFILE_KILLED": {
                _data params ["_position", "_faction", "_side", "_killerSide", ["_victim", []]];
                // a group lost with its aircraft or boat says nothing about the ground below
                private _byAirOrSea = false;
                if (_victim isEqualType [] && {count _victim > 2}) then {
                    private _victimData = _victim select 2;
                    {
                        private _vehicle = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_profileHandler;
                        if (!isNil "_vehicle") then {
                            private _type = _vehicle select 2 select 6;
                            if (_type isEqualType "" && {_type isKindOf "Air" || {_type isKindOf "Ship"}}) then { _byAirOrSea = true };
                        };
                    } forEach ((_victimData param [8, []]) + (_victimData param [9, []]));
                };
                if (!_byAirOrSea) then {
                    [nil, "deposit", [_position, _side, RM_KILL_WEIGHT]] call ALiVE_fnc_pathfinderRouteMemory;
                };
            };
            case "PROFILE_ATTACK_START": {
                // where the targets stand: the attack's own position is the attacker's
                _data params ["_attackID", "_attackerID", "_targets"];
                {
                    private _profile = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_profileHandler;
                    if (!isNil "_profile") then {
                        [nil, "deposit", [_profile select 2 select 2, _profile select 2 select 3, RM_ATTACK_WEIGHT]] call ALiVE_fnc_pathfinderRouteMemory;
                    };
                } forEach (if (_targets isEqualType []) then { _targets } else { [] });
            };
        };
    };

    // [position, side, weight]: add danger for that side at the position's sector, half as much around it
    case "deposit": {
        _args params [["_pos", []], ["_side", ""], ["_weight", 0]];
        if (isNil "ALiVE_routeMemory_danger" || {isNil "ALiVE_pathfinder"}) exitWith {};
        if (_side isEqualType west) then { _side = str _side };
        if !(_side isEqualType "" && {_pos isEqualType []} && {count _pos > 1}) exitWith {};
        private _size = (ALiVE_pathfinder get "terrainGrid") get "sectorSize";
        private _now = missionNamespace getVariable ["ALiVE_simulationTime", time];
        private _halfLife = ALiVE_pathfinding_routeMemoryHalfLife;
        private _table = ALiVE_routeMemory_danger getOrDefault [_side, createHashMap, true];
        private _ix = floor ((_pos select 0) / _size);
        private _iy = floor ((_pos select 1) / _size);
        for "_dx" from -1 to 1 do {
            for "_dy" from -1 to 1 do {
                private _key = [_ix + _dx, _iy + _dy];
                private _add = if (_dx == 0 && {_dy == 0}) then { _weight } else { _weight / 2 };
                (_table getOrDefault [_key, [0, _now]]) params ["_v", "_stamp"];
                // a fresh pair each time: the pathfinder reads the table unscheduled while this runs scheduled
                _table set [_key, [_v * (0.5 ^ ((_now - _stamp) / _halfLife)) + _add, _now]];
            };
        };
    };

    // [procedure capabilities, side]: the per-request state, or [] when route memory doesn't apply to this
    // request. Ground routes only: men on foot and land vehicles, never anything that flies.
    case "jobContext": {
        _args params [["_capabilities", []], ["_side", ""]];
        private _mode = missionNamespace getVariable ["ALiVE_pathfinding_routeMemory", "off"];
        _result = [];
        if (_mode == "off" || {!(_capabilities param [0, false])} || {_capabilities param [4, true]}) exitWith {};
        (ALiVE_pathfinding_routeMemoryLevels getOrDefault [_mode, [0, 1]]) params ["_amp", "_ceiling"];
        private _danger = if (_side isEqualType "" && {!isNil "ALiVE_routeMemory_danger"}) then {
            ALiVE_routeMemory_danger getOrDefault [_side, createHashMap]
        } else { createHashMap };
        private _size = (ALiVE_pathfinder get "terrainGrid") get "sectorSize";
        // [amplitude, ceiling, danger table, time now, lattice corners, factor per sector, sector size]
        _result = [_amp, _ceiling, _danger, missionNamespace getVariable ["ALiVE_simulationTime", time], createHashMap, createHashMap, _size];
    };

    // [context, sector index]: the cost factor for that coarse sector, computed once per request
    case "factor": {
        _args params ["_ctx", "_key"];
        _ctx params ["_amp", "_ceiling", "_danger", "_now", "_lattice", "_cache", "_size"];
        _result = _cache get _key;
        if (isNil "_result") then {
            private _u = ((_key select 0) + 0.5) * _size / RM_LATTICE;
            private _w = ((_key select 1) + 0.5) * _size / RM_LATTICE;
            private _i = floor _u;
            private _j = floor _w;
            private _fu = _u - _i;
            private _fw = _w - _j;
            _fu = _fu * _fu * (3 - 2 * _fu);
            _fw = _fw * _fw * (3 - 2 * _fw);
            private _c = [[_i, _j], [_i + 1, _j], [_i, _j + 1], [_i + 1, _j + 1]] apply {
                private _n = _lattice get _x;
                if (isNil "_n") then { _n = random 2 - 1; _lattice set [_x, _n] };
                _n
            };
            private _noise = ((_c select 0) * (1 - _fu) + (_c select 1) * _fu) * (1 - _fw)
                + ((_c select 2) * (1 - _fu) + (_c select 3) * _fu) * _fw;
            _result = 1 + _amp * _noise;
            private _cell = _danger get _key;
            if (!isNil "_cell") then {
                _cell params ["_v", "_stamp"];
                private _d = _v * (0.5 ^ ((_now - _stamp) / ALiVE_pathfinding_routeMemoryHalfLife));
                _result = _result * (1 + (_ceiling - 1) * (1 - exp (-_d)));
            };
            _cache set [_key, _result];
        };
    };
};

if (isNil "_result") then { nil } else { _result };
