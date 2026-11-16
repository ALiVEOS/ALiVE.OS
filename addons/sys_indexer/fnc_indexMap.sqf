#include "\x\alive\addons\sys_indexer\script_component.hpp"
SCRIPT(indexMap);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_indexMap

Description:
Manages the indexing of a map for ALiVE. Writes its files through the alive_tools extension, under
Documents\Arma 3\ALiVE\indexing\<map>\ (a dedicated server needs allow_server.txt in that ALiVE folder)

Parameters:
String - Addon path (no longer used: the objects are now listed in game)
boolean -  Enables custom object categorization

Returns:
String - Result

Examples:
(begin example)
_success = ["Addons\map_Stratis.pbo",false] call ALiVE_fnc_indexMap;
(end)

See Also:
- nil

Author:
Tupolov
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_path","_custom"];

_path = _this select 0;
_custom = _this select 1;
private _launch = _this select 2;

[_path,_custom, _Launch] spawn {
    private ["_path","_file","_objects","_result","_handle","_custom"];
    _path = _this select 0;
    _custom = _this select 1;
    private _launch = _this select 2;
    private _known = _this param [3, true];

    // On a dedicated server, as the web indexer runs it, there is no player to wait for and nobody
    // to press a key. The object categories then have to be in the static data file already,
    // written outside the game, and the two pauses for a key press are skipped.
    private _headless = !hasInterface;
    ALiVE_indexMap_finished = false;

    // Every way out of a failed run: a player's map and key handlers are taken off again, and anything waiting on
    // the run (the web indexer, a test) is told it is over
    private _fnc_stop = {
        params ["_why"];
        [">>>>>>>>>>>>>>>>>> There was a problem, exiting indexing: %1", _why] call ALiVE_fnc_dump;
        ["ALiVE Map Indexer","There was a problem, exiting indexing, check RPT"] call ALiVE_fnc_sendHint;
        if !(_headless) then {
            forceMap false;
            if (!isNil "ALiVE_keypress_id_map") then { (findDisplay 12) displayRemoveEventHandler ["KeyDown", ALiVE_keypress_id_map]; ALiVE_keypress_id_map = nil };
            if (!isNil "ALiVE_keypress_id") then { (findDisplay 46) displayRemoveEventHandler ["KeyDown", ALiVE_keypress_id]; ALiVE_keypress_id = nil };
        };
        ALiVE_indexMap_finished = true;
    };

    if !(_headless) then {
        waitUntil{!isNull player};

        ALiVE_keypress_id = (findDisplay 46) displayAddEventHandler ["KeyDown", "ALiVE_keypress = true;"];
    };

    ["ALiVE Map Indexer","Starting Map Index"] call ALiVE_fnc_sendHint;

    [">>>>>>>>>>>>>>>>>> Starting indexing for %1 map", worldName] call ALiVE_fnc_dump;

    // List the terrain's objects (excluding the blacklist). The old ALiVEClient extension read them out of the
    // map's WRP file with DeWrp; they are now listed in game and kept in wrp_objects as before
    [">>>>>>>>>>>>>>>>>> Creating a list of objects (excluding blacklist)"] call ALiVE_fnc_dump;
    // The web indexer makes the objects file with DeWrp before the game starts, and builds the static data from
    // that list: a run without a player keeps the file it finds, so the two always match
    private _objectsPath = format ["indexing/%1/x/alive/addons/fnc_strategic/indexes/objects.%1.sqf", toLower worldName];
    // DeWrp's file is full of comments, which preprocessFile used to remove: toolsRead takes them out
    private _objectsText = if (_headless) then { [_objectsPath, true] call ALiVE_fnc_toolsRead } else { nil };
    if (!isNil "_objectsText") then {
        [">>>>>>>>>>>>>>>>>> Using the objects file already there (%1 characters)", count _objectsText] call ALiVE_fnc_dump;
        call compile _objectsText;
    };
    if (isNil "_objectsText" && {!([] call ALiVE_fnc_indexTerrainObjects)}) exitwith {
        ["the objects file could not be written (see the [ALiVE tools] line above)"] call _fnc_stop;
    };
    // A new indexing run must resolve its new terrain placements afresh.
    missionNamespace setVariable ["ALIVE_objectLookupCache", nil];

    // Check for static data
    [">>>>>>>>>>>>>>>>>> Checking for existing static data..."] call ALiVE_fnc_dump;
    private _staticPath = format ["indexing/%1/x/alive/addons/main/static/%1_staticData.sqf", toLower worldName];
    _result = if ((("alive_tools" callExtension ["exists", [_staticPath]]) param [0, ""]) == "true") then {"SUCCESS"} else {"NO FILE"};

    if (_headless && {_result != "SUCCESS"}) exitwith {
        [format ["no static data file for %1, and objects can only be categorised by a player", worldName]] call _fnc_stop;
    };

    private _staticWritten = true;
    If (_result != "SUCCESS") then {
        [">>>>>>>>>>>>>>>>>> No static data found"] call ALiVE_fnc_dump;
        ["ALiVE Map Indexer","Starting Object Categorization"] call ALiVE_fnc_sendHint;
        [">>>>>>>>>>>>>>>>>> Starting Object Categorization"] call ALiVE_fnc_dump;

        _staticWritten = [_custom, _known] call ALiVE_fnc_auto_staticObjects;

    };
    // a half-written static data file would be compiled below and leave the building lists short
    if (!_staticWritten) exitWith {
        ["the static data file could not be written (see the [ALiVE tools] line above)"] call _fnc_stop;
    };

    if !(_headless) then {
        forceMap true;

        ALiVE_keypress_id_map = (findDisplay 12) displayAddEventHandler ["KeyDown", "ALiVE_keypress = true;"];

        ALiVE_keypress = false;
        cutText [format["HEY! %1, STATIC DATA GENERATED. PRESS ANY KEY TO CONTINUE", toUpper(name player)],"PLAIN", 1, true];
        sleep 0.7;
        waitUntil {sleep 0.3; cutText [format["HEY! %1, PRESS ANY KEY TO CONTINUE", toUpper(name player)],"PLAIN", 1, true]; ALiVE_keypress};
        ALiVE_keypress = false;
        cutText ["","PLAIN", 1, true];
    };

    // Generate Map Clusters

    ["ALiVE Map Indexer","Generating Sector Data"] call ALiVE_fnc_sendHint;
    [">>>>>>>>>>>>>>>>>> Generating Sector Data"] call ALiVE_fnc_dump;

    // start the sector and cluster files afresh: everything below adds to them
    {
        [format [_x, toLower worldName], "new", ""] call ALiVE_fnc_toolsWrite;
    } forEach [
        "indexing/%1/x/alive/addons/fnc_analysis/data/data.%1.sqf",
        "indexing/%1/x/alive/addons/mil_placement/clusters/clusters.%1_mil.sqf",
        "indexing/%1/x/alive/addons/civ_placement/clusters/clusters.%1_civ.sqf"
    ];

    // The steps below run here, in the indexer's own script, one after another. They used to be started as new
    // scripts (execVM) and FSMs: on a dedicated server running a busy mission a new script could wait for its
    // first turn indefinitely (NUC, 16 Nov: the analysis script never ran a line in 8 minutes), while this
    // script is already running and keeps getting its turn.
    private _staticText = [_staticPath, true] call ALiVE_fnc_toolsRead;
    if (!isNil "_staticText") then { call compile _staticText };

    private _grid = [nil, "create"] call ALIVE_fnc_sectorGrid;
    [_grid, "init"] call ALIVE_fnc_sectorGrid;
    [_grid, "createGrid"] call ALIVE_fnc_sectorGrid;
    ["Sectors created: %1", count ([_grid, "sectors"] call ALIVE_fnc_sectorGrid)] call ALiVE_fnc_dump;
    // Each step below throws when one of its files can't be written; caught here, so the run stops cleanly
    private _failed = "";
    try {
        [_grid, [], true, missionNamespace getVariable ["ALIVE_indexing_debug", false]] call ALIVE_fnc_auto_gridMapAnalysis;

        ["ALiVE Map Indexer","Generating Clusters: Military Objectives."] call ALiVE_fnc_sendHint;
        [">>>>>>>>>>>>>>>>>> Generating Clusters:  Military Objectives."] call ALiVE_fnc_dump;

        [] call ALIVE_fnc_auto_milClusterGeneration;

        ["ALiVE Map Indexer","Generating Clusters: Civilian Objectives."] call ALiVE_fnc_sendHint;
        [">>>>>>>>>>>>>>>>>> Generating Clusters: Civilian Objectives."] call ALiVE_fnc_dump;

        [] call ALIVE_fnc_auto_civClusterGeneration;

        // Merge sector/cluster data

        ["ALiVE Map Indexer","Generating Clusters: Merging Military Sector/Cluster Data."] call ALiVE_fnc_sendHint;
        [">>>>>>>>>>>>>>>>>> Generating Clusters: Merging Military Sector/Cluster Data."] call ALiVE_fnc_dump;

        [] call compile preprocessFileLineNumbers "\x\alive\addons\fnc_analysis\tests\auto_appendClustersMil.sqf";

        ["ALiVE Map Indexer","Generating Clusters: Merging Civilian Sector/Cluster Data."] call ALiVE_fnc_sendHint;
        [">>>>>>>>>>>>>>>>>> Generating Clusters: Merging Civilian Sector/Cluster Data."] call ALiVE_fnc_dump;

        [] call compile preprocessFileLineNumbers "\x\alive\addons\fnc_analysis\tests\auto_appendClustersCiv.sqf";
    } catch {
        _failed = str _exception;
    };
    if (_failed != "") exitWith {
        [format ["a sector or cluster file could not be written (%1)", _failed]] call _fnc_stop;
    };


    if !(_headless) then {
        ALiVE_keypress = false;
        cutText [format["HEY! %1, MAP INDEXING COMPLETE. PRESS ANY KEY TO CONTINUE", toUpper(name player)],"PLAIN", 1, true];
        sleep 0.7;
        waitUntil {sleep 0.3; cutText [format["HEY! %1, PRESS ANY KEY TO CONTINUE", toUpper(name player)],"PLAIN", 1, true]; ALiVE_keypress};
        ALiVE_keypress = false;
        cutText ["","PLAIN", 1, true];

        (findDisplay 12) displayRemoveEventHandler ["keyDown",ALiVE_keypress_id_map];
    };

    ["ALiVE Map Indexer","Map Indexing Completed!"] call ALiVE_fnc_sendHint;
    [">>>>>>>>>>>>>>>>>> Map Indexing Completed!"] call ALiVE_fnc_dump;

    // For a script that started the indexer and waits on it, such as the web indexer's job.
    ALiVE_indexMap_finished = true;

    if !(_headless) then {
        forceMap false;

        (findDisplay 46) displayRemoveEventHandler ["keyDown",ALiVE_keypress_id];
    };
};