#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(cratersReport);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_cratersReport

Description:
Takes a hit on the server and decides what it leaves. Another machine reaches this with
remoteExecCall and the hit alone, [posASL, ammo, from, tickTime]; it is only queued here, and
the server loop in ALiVE_fnc_craters works through the queue.

What a hit leaves, cheapest checks first:
- nothing for a round too small, in water, high in the air, on a runway or road, within 8 m of
  a building, inside a FOB or an AI Commander's military objective;
- a mark but no digging beside a road, near a building, in a town or civilian objective,
  across a trench, or where the ground is near sea level;
- otherwise the crater its blast deserves.

A player's machine can send at most 30 hits in 10 seconds and the server takes at most 8 a
second: a cluster bomb or a cheat can't flood it. The server and headless clients are trusted.

Parameters:
Array - a hit from another machine, [posASL, ammo, from, tickTime]
or
String - The operation
Array - Its arguments

Returns:
Nothing

Operations:
queue - [hit] put a hit in the queue
hit - [posASL, ammo, from, tickTime] decide and make the crater (server loop only)

A mission that limits remoteExec must allow ALiVE_fnc_cratersReport, or players' hits never
reach the server.

Author:
Jman
---------------------------------------------------------------------------- */

params [["_a", "", ["", []]], ["_b", [], [[]]]];

if (!isServer) exitWith {};

// a hit sent from another machine: check its shape, note who sent it, queue it
if (_a isEqualType []) exitWith {
    _a params [["_pos", [], [[]], 3], ["_ammo", "", [""]], ["_from", 0, [0]], ["_tick", 0, [0]]];
    if (count _pos != 3 || {_ammo == ""} || {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) > -1}) exitWith {};
    private _sender = if (isRemoteExecuted) then { remoteExecutedOwner } else { 2 };
    // queued here, not through "queue": isRemoteExecuted stays true in anything this calls,
    // and the operations below refuse a remote caller
    if (isNil "ALiVE_craters_queue") exitWith {};
    if (count ALiVE_craters_queue < 200) then {
        ALiVE_craters_queue pushBack [_pos, _ammo, _sender, _tick];
    } else {
        ALiVE_craters_lost = (missionNamespace getVariable ["ALiVE_craters_lost", 0]) + 1;
    };
};

// the operations are the server's own
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {};

switch (_a) do {

    case "queue": {
        if (isNil "ALiVE_craters_queue") exitWith {};
        if (count ALiVE_craters_queue < 200) then {
            ALiVE_craters_queue pushBack (_b select 0);
        } else {
            ALiVE_craters_lost = (missionNamespace getVariable ["ALiVE_craters_lost", 0]) + 1;
        };
    };

    case "hit": {
        _b params ["_pos", "_ammo", "_from", "_tick"];
        private _logic = missionNamespace getVariable ["ALiVE_sys_craters", objNull];
        if (isNull _logic) exitWith {};
        private _set = { [_logic, "attribute", [_this]] call ALiVE_fnc_craters };
        private _debug = "craters_debug" call _set;
        private _cell = getTerrainInfo select 2;
        private _tier = 0;
        private _note = [];

        private _out = call {
            // 1. a player's machine sends at most 30 hits in 10 seconds
            if (_from != 2 && {!(_from in ((entities "HeadlessClient_F") apply { owner _x }))}) then {
                private _bucket = ALiVE_craters_rate getOrDefault [_from, [0, time]];
                if (time - (_bucket select 1) > 10) then { _bucket = [0, time] };
                _bucket set [0, (_bucket select 0) + 1];
                ALiVE_craters_rate set [_from, _bucket];
            };
            if (((ALiVE_craters_rate getOrDefault [_from, [0, 0]]) select 0) > 30 && {_from != 2}) exitWith { "too many from one player" };
            // 2. at most 8 a second in all
            private _sec = floor time;
            if ((ALiVE_craters_intake select 1) != _sec) then { ALiVE_craters_intake = [0, _sec] };
            ALiVE_craters_intake set [0, (ALiVE_craters_intake select 0) + 1];
            if ((ALiVE_craters_intake select 0) > 8) exitWith { "more than 8 a second" };
            // 3. the round itself
            _tier = [_logic, "tier", [_ammo]] call ALiVE_fnc_craters;
            if (_tier == 0) exitWith { "too small" };
            // 4. on the map and on land
            _pos params ["_px", "_py", "_pz"];
            if (_px < 0 || {_py < 0} || {_px > worldSize} || {_py > worldSize}) exitWith { "off the map" };
            if (surfaceIsWater [_px, _py]) exitWith { "water" };
            // 5. high in the air: an air burst digs nothing
            private _ground = getTerrainHeightASL [_px, _py];
            if (_pz - _ground > 2.5) exitWith { "air burst" };
            // 6. a crater already here: refreshed, and dug again if this hit is bigger
            private _ci = round (_px / _cell);
            private _cj = round (_py / _cell);
            private _same = "";
            {
                private _c = ALiVE_craters get _x;
                if (_tier >= 2 && {(_c get "tier") >= 2} && {(_c get "ci") == _ci} && {(_c get "cj") == _cj}) exitWith { _same = _x };
                if (_tier == 1 && {(_c get "tier") == 1} && {([_c get "hx", _c get "hy"] distance2D [_px, _py]) < 1.5}) exitWith { _same = _x };
            } forEach ALiVE_craters_order;
            private _smaller = _same != "" && {_tier <= ((ALiVE_craters get _same) get "tier")};
            if (_smaller) exitWith {
                // it stays, and counts as new for the cap
                ALiVE_craters_order deleteAt (ALiVE_craters_order find _same);
                ALiVE_craters_order pushBack _same;
                ALiVE_craters_dirty = true;
                "a crater is already here"
            };
            // a bigger hit goes through every check below; the old one fills in only once the
            // new one is certain to be dug bigger
            // 7. how far the crater reaches
            private _reach = ([0, 1, 2] select (_tier - 1)) * _cell + 2;
            // 8. runways, taxiways and parking
            if (!isNil "ALiVE_fnc_isAirside" && {[[_px, _py], _reach + 3, [1, 2, 3]] call ALiVE_fnc_isAirside}) exitWith { "airfield" };
            // 9. roads: none on one, a mark only beside one
            if (isOnRoad [_px, _py, 0] || {([_px, _py] nearRoads 10) isNotEqualTo []}) exitWith { "road" };
            if (_tier >= 2 && {([_px, _py] nearRoads (_reach + 4)) isNotEqualTo []}) then { _tier = 1; _note pushBack "beside a road" };
            // 10. buildings: none within 8 m, a mark only within the set distance
            private _types = ["BUILDING", "HOUSE", "CHURCH", "CHAPEL", "FUELSTATION", "HOSPITAL", "BUNKER", "FORTRESS", "VIEW-TOWER", "LIGHTHOUSE", "TRANSMITTER", "WATERTOWER"];
            if ((nearestTerrainObjects [[_px, _py], _types, 8, false, true]) isNotEqualTo []) exitWith { "on a building" };
            // placed and built ones too (the editor's, a FOB's)
            // a structure, not a lamp post or a wire fence: over 2.5 m tall and 3 m across both ways
            private _placed = (nearestObjects [[_px, _py], ["House"], 12, true]) select {
                private _bb = boundingBoxReal _x;
                private _d = (_bb select 1) vectorDiff (_bb select 0);
                (_d select 2) > 2.5 && {(_d select 0) > 3} && {(_d select 1) > 3} && {((_x distance2D [_px, _py]) < 8) || {(_x buildingPos -1) isNotEqualTo []}}
            };
            if (_placed isNotEqualTo []) exitWith { "on a placed building" };
            if (_tier >= 2 && {(nearestTerrainObjects [[_px, _py], _types, "craters_building_distance" call _set, false, true]) isNotEqualTo []}) then { _tier = 1; _note pushBack "near a building" };
            // 11. FOBs
            if (!isNil "ALiVE_FOB_registry" && {!isNil "ALiVE_sup_fob"} && {!isNull ALiVE_sup_fob}) then {
                private _range = [ALiVE_sup_fob, "attribute", ["fob_build_range"]] call ALiVE_fnc_FOB;
                {
                    private _fp = [[ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet, "pos", [0, 0, 0]] call ALIVE_fnc_hashGet;
                    if ((_fp distance2D [_px, _py]) < _range) exitWith { _tier = -1 };
                } forEach (ALiVE_FOB_registry select 1);
            };
            if (_tier < 0) exitWith { "inside a FOB" };
            // 12. AI Commander objectives: none in a military base, a mark only in a civilian one
            if (time - ALiVE_craters_zonesAt > 60) then {
                ALiVE_craters_zonesAt = time;
                private _zones = [];
                {
                    private _opcom = _x;
                    // a commander still starting up: look again in ten seconds, not sixty
                    if !([_opcom, "startupComplete", false] call ALiVE_fnc_hashGet) then { ALiVE_craters_zonesAt = time - 50 };
                    if ([_opcom, "startupComplete", false] call ALiVE_fnc_hashGet) then {
                        {
                            _zones pushBack [
                                [_x, "center", [0, 0, 0]] call ALiVE_fnc_HashGet,
                                ([_x, "size", 150] call ALiVE_fnc_HashGet) max 100,
                                [_x, "objectiveType", "MIL"] call ALiVE_fnc_HashGet
                            ];
                        } forEach ([_opcom, "objectives", []] call ALiVE_fnc_hashGet);
                    };
                } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
                ALiVE_craters_zones = _zones;
            };
            private _inBase = false;
            {
                _x params ["_zc", "_zs", "_zt"];
                if ((_zc distance2D [_px, _py]) < _zs) then {
                    // anything not civilian counts as military, editor-placed objectives included
                    if !(_zt in ["CIV", "CCU"]) then { _inBase = true } else { if (_tier >= 2) then { _tier = 1; _note pushBack "civilian objective" } };
                };
                if (_inBase) exitWith {};
            } forEach ALiVE_craters_zones;
            if (_inBase) exitWith { "military objective" };
            // 13. towns and villages: a mark only
            if (_tier >= 2) then {
                {
                    private _r = ((size _x) select 0) max ((size _x) select 1);
                    if (((locationPosition _x) distance2D [_px, _py]) < (_r + 50)) exitWith { _tier = 1; _note pushBack ("in " + text _x) };
                } forEach (nearestLocations [[_px, _py], ["NameCity", "NameCityCapital", "NameVillage"], 600]);
            };
            // 14. trenches and 15. sea level: a mark only
            if (_tier >= 2) then {
                private _cells = missionNamespace getVariable ["ALiVE_OPCOM_trenchCells", createHashMap];
                private _sea = (getTerrainInfo select 4) + 0.5;
                private _depth = "craters_depth" call _set;
                {
                    _x params ["_k", "_x2", "_y2", "_drop"];
                    private _owner = _cells getOrDefault [_k, ""];
                    if (_owner != "" && {(_owner select [0, 7]) != "crater:"}) exitWith { _tier = 1; _note pushBack "across a trench" };
                    // from the ground as it was, not as a crater already here has dug it
                    private _rec = ALiVE_craters_points getOrDefault [_k, []];
                    private _h = if (_rec isEqualTo []) then { getTerrainHeightASL [_x2, _y2] } else { _rec select 2 };
                    if (_h - _drop < _sea) exitWith { _tier = 1; _note pushBack "near sea level" };
                } forEach (["points", [_tier, _ci, _cj, _depth]] call ALiVE_fnc_cratersTerrain);
            };
            // the old crater here stays when this hit came out no bigger after the rules above
            if (_same != "" && {_tier <= ((ALiVE_craters get _same) get "tier")}) exitWith {
                ALiVE_craters_order deleteAt (ALiVE_craters_order find _same);
                ALiVE_craters_order pushBack _same;
                ALiVE_craters_dirty = true;
                "a crater is already here"
            };
            if (_same != "") then { ["fill", [_same]] call ALiVE_fnc_cratersTerrain };
            ["make", ""]
        };

        if (_out isEqualType "") exitWith {
            if (_debug) then { ["ALiVE Persistent Craters - %1 at %2: no crater, %3", _ammo, [round (_pos select 0), round (_pos select 1)], _out] call ALiVE_fnc_dump };
        };

        private _id = ["make", [_tier, round ((_pos select 0) / _cell), round ((_pos select 1) / _cell), _pos]] call ALiVE_fnc_cratersTerrain;

        // the cap: the oldest fill back in
        private _cap = "craters_cap" call _set;
        while { count ALiVE_craters_order > _cap } do {
            ["fill", [ALiVE_craters_order select 0]] call ALiVE_fnc_cratersTerrain;
        };
        ALiVE_craters_dirty = true;

        if (_debug) then {
            ["ALiVE Persistent Craters - %1 at %2: crater %3, size %4%5 (%6, %7 kept)", _ammo, [round (_pos select 0), round (_pos select 1)], _id, _tier,
                ["", format [" (%1)", _note joinString ", "]] select (_note isNotEqualTo []),
                if (_from == 2) then { format ["%1 s after it went off", (diag_tickTime - _tick) toFixed 2] } else { format ["from machine %1", _from] }, count ALiVE_craters_order] call ALiVE_fnc_dump;
        };
    };
};
