//#define DEBUG_MODE_FULL
#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(clustersDropStrayHelipads);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_clustersDropStrayHelipads

Description:
Drops military objectives made only of invisible helipads that sit away from any
other military building. Terrain makers scatter invisible helipads as landing spots
for AI helicopters, out in fields and paddies as well as on bases, and an index can
count them as military helicopter buildings, so a few of them on their own became an
objective that helicopters were parked on (RHSPKL had 22 of its 63). One within 300 m
of a military building that isn't an invisible helipad is kept: those are a base's own
helicopter pads (Blud Vidda's sit 20 to 51 m from theirs).

Parameters:
Array - the lists of clusters to filter, as they are while a terrain is indexed (the
        main, HQ, air and helicopter lists, nodes as objects). Leave it out to filter the
        terrain's index in place once it is compiled at mission start (ALIVE_clustersMil,
        ALIVE_clustersMilHQ, ALIVE_clustersMilAir and ALIVE_clustersMilHeli, nodes as
        [object id, position] pairs).

Returns:
Array - the lists, filtered (empty when filtering the compiled index)

Examples:
(begin example)
// straight after the terrain's military index is compiled
[] call ALIVE_fnc_clustersDropStrayHelipads;

// while indexing, before the lists are written out
([[_clusters, _clustersHQ, _clustersAir, _clustersHeli]] call ALIVE_fnc_clustersDropStrayHelipads)
    params ["_clusters", "_clustersHQ", "_clustersAir", "_clustersHeli"];
(end)

See Also:
- <ALIVE_fnc_cluster>

Author:
Jman
---------------------------------------------------------------------------- */

#define STRAY_HELIPAD_RANGE 300
#define INVISIBLE_HELIPADS ["helipadempty_f.p3d", "vn_helipadempty_f.p3d"]

params [["_lists", nil, [[]]]];

// the compiled index's hashes, read in place
private _hashes = [];
if (isNil "_lists") then {
    _lists = [];
    {
        private _hash = missionNamespace getVariable [_x, []];
        if (_hash isEqualType [] && {count _hash > 2} && {(_hash select 2) isEqualType []}) then {
            _hashes pushBack _hash;
            _lists pushBack (_hash select 2);
        };
    } forEach ["ALIVE_clustersMil", "ALIVE_clustersMilHQ", "ALIVE_clustersMilAir", "ALIVE_clustersMilHeli"];
};

// [is an invisible helipad, flat position]. A node is an object while indexing and an
// [object id, position] pair in a compiled index; one whose object can't be found counts
// as a building, so its cluster is never dropped on a guess.
private _fnc_node = {
    params ["_node"];
    private _object = objNull;
    private _pos = [];
    if (_node isEqualType objNull) then {
        _object = _node;
        if !(isNull _object) then {_pos = getPosATL _object};
    } else {
        if (_node isEqualType [] && {count _node > 1}) then {
            _pos = _node select 1;
            _object = _pos nearestObject (parseNumber (_node select 0));
        };
    };
    if (isNull _object) exitWith {[false, _pos]};
    [(toLower ((getModelInfo _object) select 0)) in INVISIBLE_HELIPADS, _pos]
};

// every node that isn't an invisible helipad, and the clusters made only of them
private _buildings = [];
private _padClusters = [];
{
    {
        private _cluster = _x;
        private _nodes = [_cluster, "nodes", []] call ALIVE_fnc_hashGet;
        private _pads = [];
        {
            ([_x] call _fnc_node) params ["_isPad", "_pos"];
            if (count _pos > 1) then {
                if (_isPad) then {_pads pushBack _pos} else {_buildings pushBack _pos};
            };
        } forEach _nodes;
        if (count _pads > 0 && {count _pads == count _nodes}) then {
            _padClusters pushBack [_cluster, _pads];
        };
    } forEach _x;
} forEach _lists;

private _drop = [];
{
    _x params ["_cluster", "_pads"];
    private _base = (_pads findIf {
        private _pad = _x;
        (_buildings findIf {(_x distance2D _pad) <= STRAY_HELIPAD_RANGE}) > -1
    }) > -1;
    if !(_base) then {_drop pushBack _cluster};
} forEach _padClusters;

if (count _drop > 0) then {
    ["ALiVE - dropped %1 military objectives made only of invisible helipads, with no other military building within %2 m",
        count _drop, STRAY_HELIPAD_RANGE] call ALiVE_fnc_dump;
};

private _result = [];
if (count _hashes > 0) then {
    {
        private _hash = _x;
        private _keys = _hash select 1;
        private _gone = [];
        {
            private _cluster = _x;
            if ((_drop findIf {_x isEqualRef _cluster}) > -1) then {_gone pushBack (_keys select _forEachIndex)};
        } forEach (_hash select 2);
        {[_hash, _x] call ALIVE_fnc_hashRem} forEach _gone;
    } forEach _hashes;
} else {
    _result = _lists apply {
        _x select {
            private _cluster = _x;
            (_drop findIf {_x isEqualRef _cluster}) < 0
        }
    };
};

_result
