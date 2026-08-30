#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(IEDLocationSource);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_IEDLocationSource

Description:
Return the population centres this module should consider placing IEDs around,
as [position, size, label] tuples.

Three sources are tried in order, cheapest first, and the first one that yields
anything wins:

  1. The settlement clusters ALiVE already ships pre-built for the terrain.
     Every other consumer of this data reads them; only this module used to
     rebuild them at mission start. Rebuilding took eighty five seconds of a
     two minute startup on a dense terrain, against a fraction of a second to
     read the file, and on any mission that also runs civilian placement the
     file is in memory already and the cost is nothing at all.

  2. Building up the clusters at runtime, exactly as this module did before.
     Kept for terrains ALiVE has never indexed, where there is nothing to read.

  3. The engine's own named locations, unchanged. Last because it is what the
     module used before, and what it was moved away from: on a terrain whose
     author never tagged the towns, it finds almost nothing.

Whichever source answers, the result is the same shape, so nothing downstream
of the caller can tell the difference.

Parameters:
    0: ARRAY  - map centre, for the engine location search
    1: NUMBER - map radius, for the engine location search
    2: BOOL   - debug

Returns:
    ARRAY - [[position, size, label], ...]

Examples:
(begin example)
private _locations = [_center, _radius, _debug] call ALIVE_fnc_IEDLocationSource;
(end)

See Also:
- <ALIVE_fnc_IED>

Author:
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [
    ["_center", [0,0,0], [[]]],
    ["_radius", 0, [0]],
    ["_debug", false, [false]]
];

private _locations = [];
private _source = "none";

// Build the tuples the rest of the module expects. Centre and size are read
// through the cluster accessor rather than straight out of the hash, and that
// matters more than it looks: a cluster is stored with its centre and size
// deliberately blanked, and the accessor is what works them out from the
// buildings on first read. Reading the raw values instead would hand back the
// blanks as though they were real, and on a few terrains whose entire
// settlement list is a single cluster stored that way, the module would place
// no IEDs at all and report success while doing it.
private _fnc_toTuples = {
    params ["_clusters"];

    private _out = [];

    {
        private _pos = [_x, "center"] call ALIVE_fnc_cluster;

        if (count _pos > 1) then {
            private _size = [_x, "size"] call ALIVE_fnc_cluster;
            if (_size < 250) then { _size = 250 };

            private _nearLoc = (nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","Strategic"], 200]) select 0;
            private _label = if (!isNil "_nearLoc" && {!(_nearLoc isEqualTo locationNull)}) then {
                text _nearLoc
            } else {
                format ["Area_%1", mapGridPosition _pos]
            };

            _out pushBack [_pos, _size, _label];
        };
    } forEach _clusters;

    _out
};

// ---------------------------------------------------------------------------
// 1. The settlement clusters that ship with the terrain.
// ---------------------------------------------------------------------------
// Loading is the same handshake civilian placement uses, copied deliberately
// rather than improved on. Whoever gets here first loads the file and raises
// the flag; everyone else waits for it. Because the flag is raised whether or
// not the file turned out to exist, the wait always ends, and because this
// module raises it too when nobody else has, waiting here cannot strand the
// mission. Reading the settlements without that wait is the real hazard: the
// file is large enough to be interrupted part way through, and the settlement
// list exists long before it is finished being filled, so an unsynchronised
// read gets a fraction of the towns and no indication anything is missing.
private _worldName = toLower worldName;
private _clusterFile = format ["x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];

if (isNil "ALIVE_clustersCiv" && isNil "ALIVE_loadedCIVClusters") then {
    if (_debug) then {
        ["ALIVE IED - no other module has loaded the terrain's clusters, loading them here"] call ALiVE_fnc_dump;
    };
    // Claimed before the compile, not after. The compile yields to the scheduler all the way
    // through, so a flag raised only at the end let every concurrent instance pass the test
    // above and compile the same file over again. The wait below demands true, not merely set.
    ALIVE_loadedCIVClusters = false;
    call compile preprocessFileLineNumbers _clusterFile;
    ALIVE_loadedCIVClusters = true;
};

waitUntil {!(isNil "ALIVE_loadedCIVClusters") && {ALIVE_loadedCIVClusters}};

if (!isNil "ALIVE_clustersCivSettlement") then {
    private _baked = (ALIVE_clustersCivSettlement select 2) select {!isNil "_x" && {_x isEqualType []}};
    _locations = [_baked] call _fnc_toTuples;
    if (count _locations > 0) then { _source = "shipped clusters" };
};

// ---------------------------------------------------------------------------
// 2. Build them here, as this module used to.
// ---------------------------------------------------------------------------
// Only reached when the terrain has nothing to read. The index guard is here
// because without it the loader quietly compiles a file that isn't there and
// carries on with an empty answer.
if (count _locations == 0) then {
    call ALiVE_fnc_staticDataHandler;

    private _indexFile = format ["x\alive\addons\fnc_strategic\indexes\objects.%1.sqf", _worldName];
    private _haveIndex = [_indexFile] call ALiVE_fnc_fileExists;

    if (_haveIndex && {!isNil "ALIVE_civilianSettlementBuildingTypes"} && {count ALIVE_civilianSettlementBuildingTypes > 0}) then {
        if (_debug) then {
            ["ALIVE IED - nothing pre-built for this terrain, working the settlements out here instead"] call ALiVE_fnc_dump;
        };

        private _clusters = [ALIVE_civilianSettlementBuildingTypes] call ALIVE_fnc_findTargets;
        _clusters = [_clusters] call ALIVE_fnc_consolidateClusters;

        _locations = [_clusters] call _fnc_toTuples;
        if (count _locations > 0) then { _source = "built here" };
    };
};

// ---------------------------------------------------------------------------
// 3. Whatever the terrain author tagged.
// ---------------------------------------------------------------------------
// The original source, kept as the last resort. On a terrain where the towns
// were never tagged this finds a handful of entries for a whole map, which is
// the reason the module stopped relying on it.
if (count _locations == 0) then {
    if (_debug) then {
        ["ALIVE IED - falling back to the terrain's own named locations"] call ALiVE_fnc_dump;
    };

    private _engineLocs = nearestLocations [_center, ["NameCityCapital","NameCity","NameVillage","Strategic"], _radius];

    _locations = _engineLocs apply {
        private _pos = position _x;
        private _size = (size _x) select 0;
        if (_size < 250) then { _size = 250 };
        [_pos, _size, text _x]
    };

    if (count _locations > 0) then { _source = "terrain named locations" };
};

["ALIVE IED - population centres from %1: %2", _source, count _locations] call ALiVE_fnc_dump;

_locations
