#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(clusterTerrainScore);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_clusterTerrainScore

Description:
How much a place is worth for its ground, from the map index alone (0 to 1).
Six tenths is high ground: the height of the place above the mean height of the
land 300-1000 m around it, full marks at 60 m or more. Four tenths is roads:
the road junctions within 300 m, full marks at 3 or more.

Reads the index sample lists (elevationSamplesLand, roads > crossroad) of the
sector the place is in and the sectors around it. A map with no index, or an
index without those lists, scores 0, so an old or third-party index changes
nothing. Results are cached by position for the rest of the mission.

Needs ALIVE_sectorGrid with the static map analysis imported (the profile
system does this at start).

Parameters:
Array - position

Returns:
Number - score, 0 to 1

Examples:
(begin example)
_score = [getPos player] call ALIVE_fnc_clusterTerrainScore;
(end)

See Also:
ALIVE_fnc_sectorGrid

Author:
Jman
---------------------------------------------------------------------------- */

params [["_position", [], [[]]]];

if (count _position < 2 || {isNil "ALIVE_sectorGrid"}) exitWith { 0 };

if (isNil "ALIVE_clusterTerrainScoreCache") then { ALIVE_clusterTerrainScoreCache = createHashMap };

private _key = [round (_position select 0), round (_position select 1)];
private _cached = ALIVE_clusterTerrainScoreCache get _key;
if (!isNil "_cached") exitWith { _cached };

private _sectors = [[ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid];
_sectors append ([ALIVE_sectorGrid, "surroundingSectors", _position] call ALIVE_fnc_sectorGrid);

private _ringSum = 0;
private _ringCount = 0;
private _junctions = 0;

{
    private _sectorData = if (isNil "_x") then { nil } else { [_x, "data"] call ALIVE_fnc_hashGet };

    if (!isNil "_sectorData" && {_sectorData isEqualType []}) then {
        private _elevation = [_sectorData, "elevationSamplesLand", []] call ALIVE_fnc_hashGet;
        if (_elevation isEqualType []) then {
            {
                if (_x isEqualType [] && {count _x > 1}) then {
                    private _d = (_x select 0) distance2D _position;
                    if (_d >= 300 && {_d <= 1000}) then {
                        _ringSum = _ringSum + (_x select 1);
                        _ringCount = _ringCount + 1;
                    };
                };
            } forEach _elevation;
        };

        private _roads = [_sectorData, "roads", []] call ALIVE_fnc_hashGet;
        if (_roads isEqualType [] && {_roads isNotEqualTo []}) then {
            private _crossroads = [_roads, "crossroad", []] call ALIVE_fnc_hashGet;
            if (_crossroads isEqualType []) then {
                _junctions = _junctions + ({ _x isEqualType [] && {((_x select 0) distance2D _position) <= 300} } count _crossroads);
            };
        };
    };
} forEach _sectors;

private _highGround = 0;
if (_ringCount > 0) then {
    private _height = getTerrainHeightASL [_position select 0, _position select 1];
    _highGround = 0 max (((_height - (_ringSum / _ringCount)) / 60) min 1);
};

private _score = (0.6 * _highGround) + (0.4 * ((_junctions / 3) min 1));

ALIVE_clusterTerrainScoreCache set [_key, _score];

_score
