#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_processTerrain

Description:
    Generates a height map based on a rectangular section of terrain.

Parameters:
    0 - Bounding box [array] (optional)
    1 - Meter precision [number] (optional)
    2 - Enable multi-processing [bool] (optional)
    3 - Output decimal places [number] (optional)

Returns:
    Terrain Map [array]
        0 - Bounding box [array]
        1 - Meter precision [number]
        2 - Height map [array]

Attributes:
    N/A

Examples:
    N/A

See Also:

Notes:
    1. Bounding box is in rectangular format [X1, Y1, X2, Y2], as shown below.
                +---------------+ (X2, Y2)
                |                |
                |                |
                |                |
       (X1, Y1)    +---------------+
    2. Function is O(n^2), so spawn it if you need to.
    3. Multiprocessing utilizes a more efficient method for processing large data sets in a round-robin scheduled environment.
    This will increase performance when processing terrain data in very small precisions or very large areas.

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

// Initialize benchmark code
#ifdef BENCHMARK
    private ["_startTime", "_startText"];
    _startTime = diag_tickTime;
    _startText = format["[ALiVE_fnc_processTerrain] Starting Benchmark [TickTime: %1 sec]", _startTime];
    player globalChat _startText;
    diag_log text _startText;
#endif

// Process passed parameters
params [["_boundingBox", [], [[]]], ["_precision", 30, [0]],
        ["_multiProcess", true, [true]], ["_decPrecision", 1, [0]]];

// Retrieve map information
private ["_mapEdge"];
_mapEdge = (call ALiVE_fnc_getMapInfo) select 1;

// Formulate bounding area
_boundingBox params [["_bbX1", 0, [0]], ["_bbY1", 0, [0]], ["_bbX2", nil, [0]], ["_bbY2", nil, [0]]];

if (_bbX2 == nil) then { _bbX2 = _mapEdge select 0 };
if (_bbY2 == nil) then { _bbY2 = _mapEdge select 1 };

// Initialize process
private ["_scripts", "_heightMap", "_fnc_processColumn"];
_scripts = [];
_heightMap = [];

_fnc_processColumn = {

    // Record thread statistics
    #ifdef BENCHMARK
        private ["_startTime"];
        _startTime = diag_tickTime;
    #endif

    // Load local (passed) variables
    private ["_column", "_x", "_bbY"];

    _column = (_this select 0) select (_this select 1);
    _x = _this select 2;
    _bbY = _this select 3;

    // Process terrain in bounds (y)
    for "_y" from (_bbY select 0) to (_bbY select 1) step (_this select 4) do
    {
        _column pushback ([getTerrainHeightASL[_x,_y], _decPrecision] call ALiVE_fnc_roundDecimal);
    };

    // Report thread statistics
    #ifdef BENCHMARK
        diag_log text format["[ALiVE_fnc_processTerrain] Thread execution finished. [BenchTime: %1 ms]", ((diag_tickTime - _startTime) * 1000)];
    #endif
};

// Process terrain in bounds (x)
for "_x" from _bbX1 to _bbX2 step _precision do
{
    private ["_index", "_args"];
    _index = count _heightMap;
    _args = [_heightMap, _index, _x, [_bbY1, _bbY2], _precision];
    _heightMap set [_index, []];

    // Load multi-process mechanism
    if (_multiProcess) then
    {
        _scripts pushBack (_args spawn _fnc_processColumn);
    }
    else
    {
        _args call _fnc_processColumn;
    };
};

// Wait until all columns have finished processing
waitUntil {
    private ["_count"];
    _count = {!(scriptDone _x)} count _scripts;

    #ifdef BENCHMARK
        hintSilent format["[ALiVE_fnc_processTerrain]\nMP Threads Processing:\n%1 / %2", _count, (count _scripts)];
    #endif

    _count <= 0; // Return wait condition
};

// Run benchmark code
#ifdef BENCHMARK
    private ["_text"];
    _text = format["[ALiVE_fnc_processTerrain] Finished Benchmark. [TickTime: %1 s | BenchTime: %2 sec | Size: %3 MB]",
        diag_tickTime,
        (diag_tickTime - _startTime),
        [([_heightMap] call ALiVE_fnc_estimateMemoryUsage) / 1048576, 3] call ALiVE_fnc_roundDecimal
    ];

    player globalChat _text;
    diag_log text _text;
#endif

// Return resulting array
[[_bbX1, _bbY1, _bbX2, _bbY2], _precision, _heightMap]
