// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_sectorDataSort);

//execVM "\x\alive\addons\fnc_analysis\tests\test_sectorDataSort.sqf"

// ----------------------------------------------------------------------------

private ["_createMarker","_result","_err","_grid","_timeStart","_timeEnd","_plotter","_allSectors","_playerSector","_playerSectorID","_playerSectorData"];

LOG("Testing Sector Data Sorting");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define G_DEBUGON STAT("Setup debug parameters"); \
_result = [ALIVE_sectorGrid, "debug", true] call ALIVE_fnc_sectorGrid; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define G_DEBUGOFF STAT("Disable debug"); \
_result = [ALIVE_sectorGrid, "debug", false] call ALIVE_fnc_sectorGrid; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

#define P_DEBUGON STAT("Setup debug parameters"); \
_result = [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define P_DEBUGOFF STAT("Disable debug"); \
_result = [ALIVE_profileHandler, "debug", false] call ALIVE_fnc_profileHandler; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
diag_log format["Timer End %1",_timeEnd];

//========================================

_createMarker = {
        private ["_markerID","_position","_dimensions","_alpha","_color","_shape","_m"];
				
		_markerID = _this select 0;
		_position = _this select 1;
		_dimensions = _this select 2;
		_color = _this select 3;
		
		_m = createMarkerLocal [_markerID, _position];
		_m setMarkerShapeLocal "ICON";
		_m setMarkerSizeLocal _dimensions;
		_m setMarkerTypeLocal "mil_dot";
		_m setMarkerColorLocal _color;
		_m setMarkerTextLocal _markerID;
		_m
};


// Setup Grid ------------------------------------------------------------------------------


STAT("Create SectorGrid instance");
TIMERSTART
ALIVE_sectorGrid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[ALIVE_sectorGrid, "init"] call ALIVE_fnc_sectorGrid;
TIMEREND


STAT("Create Grid");
TIMERSTART
_result = [ALIVE_sectorGrid, "createGrid"] call ALIVE_fnc_sectorGrid;
TIMEREND


STAT("Create Sector Plotter");
TIMERSTART
_plotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[_plotter, "init"] call ALIVE_fnc_plotSectors;
TIMEREND


G_DEBUGON


_allSectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
diag_log format["Sectors created: %1",count _allSectors];


TIMERSTART
STAT("Start import static terrain analysis");
[ALIVE_sectorGrid, "Stratis"] call ALIVE_fnc_gridImportStaticMapAnalysis;
TIMEREND


// Player position to sector and sector data -----------------------------------------------


STAT("Get player sector");
TIMERSTART
_playerSector = [ALIVE_sectorGrid, "positionToSector", getPos player] call ALIVE_fnc_sectorGrid;
TIMEREND

STAT("Get the player sector id");
_playerSectorID = [_playerSector, "id"] call ALIVE_fnc_hashGet;
["Sector ID: %1",_playerSectorID] call ALIVE_fnc_dump;


STAT("Get the player sector data hash");
_playerSectorData = [_playerSector, "data"] call ALIVE_fnc_hashGet;
["Sector Data:"] call ALIVE_fnc_dump;
_playerSectorData call ALIVE_fnc_inspectHash;



// Elevation -------------------------------------------------------------------------------

private ["_sortedElevationData","_lowestElevationInSector","_highestElevationInSector","_m1","_m2"];

STAT("Sort elevation data lowest to highest");
_sortedElevationData = [_playerSectorData, "elevation", []] call ALIVE_fnc_sectorDataSort;
["Sorted elevation data: %1",_sortedElevationData] call ALIVE_fnc_dump;

_lowestElevationInSector = _sortedElevationData select 0;
_m1 = ["Lowest Elevation",(_lowestElevationInSector select 0),[1,1],"ColorGreen"] call _createMarker;

_highestElevationInSector = _sortedElevationData select count(_sortedElevationData)-1;
_m2 = ["Highest Elevation",(_highestElevationInSector select 0),[1,1],"ColorRed"] call _createMarker;

STAT("Sleeping before clear");
sleep 30;

deleteMarkerLocal _m1;
deleteMarkerLocal _m2;


// -------------------------------------------------------------------------------



// Terrain -------------------------------------------------------------------------------

private ["_sortedLandPositions","_nearestLandPosition","_sortedShorePositions","_nearestShorePosition","_sortedSeaPositions","_nearestSeaPosition","_m1","_m2","_m3"];

STAT("Plot terrain data on player sector");
[_plotter, "plot", [[_playerSector], "terrainSamples"]] call ALIVE_fnc_plotSectors;


STAT("Sort land by distance to player");
_sortedLandPositions = [_playerSectorData, "terrain", [getPos player,"land"]] call ALIVE_fnc_sectorDataSort;
["Sorted land positions: %1",_sortedLandPositions] call ALIVE_fnc_dump;

if(count _sortedLandPositions > 0) then {
	_nearestLandPosition = _sortedLandPositions select 0;
	_m1 = ["Nearest Land",_nearestLandPosition,[1,1],"ColorBrown"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m1;
};


STAT("Sort shore by distance to player");
_sortedShorePositions = [_playerSectorData, "terrain", [getPos player,"shore"]] call ALIVE_fnc_sectorDataSort;
["Sorted land positions: %1",_sortedShorePositions] call ALIVE_fnc_dump;

if(count _sortedShorePositions > 0) then {
	_nearestShorePosition = _sortedShorePositions select 0;
	_m2 = ["Nearest Shore",_nearestShorePosition,[1,1],"ColorKhaki"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m2;
};



STAT("Sort sea by distance to player");
_sortedSeaPositions = [_playerSectorData, "terrain", [getPos player,"sea"]] call ALIVE_fnc_sectorDataSort;
["Sorted sea positions: %1",_sortedSeaPositions] call ALIVE_fnc_dump;

if(count _sortedSeaPositions > 0) then {
	_nearestSeaPosition = _sortedSeaPositions select 0;
	_m3 = ["Nearest Sea",_nearestSeaPosition,[1,1],"ColorBlue"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m3;
};

STAT("Sleeping before clear");
sleep 30;

[_plotter, "clear"] call ALIVE_fnc_plotSectors;



// -------------------------------------------------------------------------------



// Best Places -------------------------------------------------------------------------------

private ["_sortedForestPositions","_nearestForestPosition","_sortedTreePositions","_nearestTreePosition","_sortedHillPositions","_nearestHillPosition",
"_sortedMeadowPositions","_nearestMeadowPosition","_sortedHousePositions","_nearestHousePosition","_sortedSeaPositions","_nearestSeaPosition","_m1","_m2","_m3","_m4","_m5","_m6"];

STAT("Plot best places data on player sector");
[_plotter, "plot", [[_playerSector], "bestPlaces"]] call ALIVE_fnc_plotSectors;


STAT("Sort forest by distance to player");
_sortedForestPositions = [_playerSectorData, "bestPlaces", [getPos player,"forest"]] call ALIVE_fnc_sectorDataSort;
["Sorted forest positions: %1",_sortedForestPositions] call ALIVE_fnc_dump;

if(count _sortedForestPositions > 0) then {
	_nearestForestPosition = _sortedForestPositions select 0;
	_m1 = ["Nearest Forest",_nearestForestPosition,[1,1],"ColorGreen"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m1;
};

/*
STAT("Sort exposed trees by distance to player");
_sortedTreePositions = [_playerSectorData, "bestPlaces", [getPos player,"exposedTrees"]] call ALIVE_fnc_sectorDataSort;
["Sorted exposed trees positions: %1",_sortedTreePositions] call ALIVE_fnc_dump;

if(count _sortedTreePositions > 0) then {
	_nearestTreePosition = _sortedTreePositions select 0;
	_m2 = ["Nearest Exposed Tree",_nearestTreePosition,[1,1],"ColorRed"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m2;
};
*/

STAT("Sort exposed hills by distance to player");
_sortedHillPositions = [_playerSectorData, "bestPlaces", [getPos player,"exposedHills"]] call ALIVE_fnc_sectorDataSort;
["Sorted exposed hills positions: %1",_sortedHillPositions] call ALIVE_fnc_dump;

if(count _sortedHillPositions > 0) then {
	_nearestHillPosition = _sortedHillPositions select 0;
	_m3 = ["Nearest Exposed Hill",_nearestHillPosition,[1,1],"ColorOrange"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m3;
};

/*
STAT("Sort meadow by distance to player");
_sortedMeadowPositions = [_playerSectorData, "bestPlaces", [getPos player,"meadow"]] call ALIVE_fnc_sectorDataSort;
["Sorted meadow positions: %1",_sortedHillPositions] call ALIVE_fnc_dump;

if(count _sortedMeadowPositions > 0) then {
	_nearestMeadowPosition = _sortedMeadowPositions select 0;
	_m4 = ["Nearest Meadow",_nearestMeadowPosition,[1,1],"ColorWhite"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m4;
};


STAT("Sort house by distance to player");
_sortedHousePositions = [_playerSectorData, "bestPlaces", [getPos player,"houses"]] call ALIVE_fnc_sectorDataSort;
["Sorted house positions: %1",_sortedHousePositions] call ALIVE_fnc_dump;

if(count _sortedHousePositions > 0) then {
	_nearestHousePosition = _sortedHousePositions select 0;
	_m5 = ["Nearest House",_nearestHousePosition,[1,1],"ColorYellow"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m5;
};


STAT("Sort sea by distance to player");
_sortedSeaPositions = [_playerSectorData, "bestPlaces", [getPos player,"sea"]] call ALIVE_fnc_sectorDataSort;
["Sorted sea positions: %1",_sortedSeaPositions] call ALIVE_fnc_dump;

if(count _sortedSeaPositions > 0) then {
	_nearestSeaPosition = _sortedSeaPositions select 0;
	_m6 = ["Nearest Sea",_nearestSeaPosition,[1,1],"ColorBlue"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m6;
};
*/


STAT("Sleeping before clear");
sleep 30;

[_plotter, "clear"] call ALIVE_fnc_plotSectors;


// -------------------------------------------------------------------------------



// Flat Empty -------------------------------------------------------------------------------

private ["_sortedFlatEmptyPositions","_nearestFlatEmptyPosition","_m"];

STAT("Plot flat empty data on player sector");
[_plotter, "plot", [[_playerSector], "flatEmpty"]] call ALIVE_fnc_plotSectors;


STAT("Sort flat empty data by distance to player");
_sortedFlatEmptyPositions = [_playerSectorData, "flatEmpty", [getPos player]] call ALIVE_fnc_sectorDataSort;
["Sorted flat empty positions: %1",_sortedFlatEmptyPositions] call ALIVE_fnc_dump;

if(count _sortedFlatEmptyPositions > 0) then {
	_nearestFlatEmptyPosition = _sortedFlatEmptyPositions select 0;
	_m = ["Nearest Flat Empty",_nearestFlatEmptyPosition,[1,1],"ColorRed"] call _createMarker;
};

STAT("Sleeping before clear");
sleep 30;

[_plotter, "clear"] call ALIVE_fnc_plotSectors;
deleteMarkerLocal _m;


// -------------------------------------------------------------------------------



// Roads -------------------------------------------------------------------------------

private ["_sortedRoadPositions","_nearestRoadPosition","_sortedCrossroadPositions","_nearestCrossroadPosition","_sortedTerminusPositions","_nearestTerminusPosition","_m"];

STAT("Plot road data on player sector");
[_plotter, "plot", [[_playerSector], "roads"]] call ALIVE_fnc_plotSectors;


STAT("Sort road data by distance to player");
_sortedRoadPositions = [_playerSectorData, "roads", [getPos player, "road"]] call ALIVE_fnc_sectorDataSort;
["Sorted road positions: %1",_sortedRoadPositions] call ALIVE_fnc_dump;

if(count _sortedRoadPositions > 0) then {
	_nearestRoadPosition = _sortedRoadPositions select 0;
	_m = ["Nearest Road",(_nearestRoadPosition select 0),[1,1],"ColorGreen"] call _createMarker;
	sleep 10;
	deleteMarkerLocal _m;
};


STAT("Sort crossroad data by distance to player");
_sortedCrossroadPositions = [_playerSectorData, "roads", [getPos player, "crossroad"]] call ALIVE_fnc_sectorDataSort;
["Sorted road positions: %1",_sortedRoadPositions] call ALIVE_fnc_dump;

if(count _sortedCrossroadPositions > 0) then {
	_nearestCrossroadPosition = _sortedCrossroadPositions select 0;
	_m = ["Nearest Crossroad",(_nearestCrossroadPosition select 0),[1,1],"ColorOrange"] call _createMarker;
	sleep 10;
	deleteMarkerLocal _m;
};


STAT("Sort road terminus data by distance to player");
_sortedTerminusPositions = [_playerSectorData, "roads", [getPos player, "terminus"]] call ALIVE_fnc_sectorDataSort;
["Sorted road positions: %1",_sortedTerminusPositions] call ALIVE_fnc_dump;

if(count _sortedTerminusPositions > 0) then {
	_nearestTerminusPosition = _sortedTerminusPositions select 0;
	_m = ["Nearest Terminus",(_nearestTerminusPosition select 0),[1,1],"ColorRed"] call _createMarker;
	sleep 10;
	deleteMarkerLocal _m;
};

STAT("Sleeping before clear");
[_plotter, "clear"] call ALIVE_fnc_plotSectors;


// -------------------------------------------------------------------------------



// Setup Test Profiles ----------------------------------------------------------------------


_sortedFlatEmptyPositions = [_playerSectorData, "flatEmpty", [getPos player]] call ALIVE_fnc_sectorDataSort;
_sortedMeadowPositions = [_playerSectorData, "bestPlaces", [getPos player,"meadow"]] call ALIVE_fnc_sectorDataSort;

private ["_testFactions","_testTypes","_type","_faction","_group","_positions","_position","_testProfle","_sortedProfilePositions","_nearestProfilePosition","_m"];

_testFactions  = ["BLU_F"];
_testTypes = ["Infantry","Motorized","Mechanized","Air"];


STAT("Create Profile Handler");
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;

if(count _sortedFlatEmptyPositions > 0) then {
	_positions = _sortedFlatEmptyPositions;
}else{
	_positions = _sortedMeadowPositions;
};

{
	_position = _x;
	_type = _testTypes call BIS_fnc_selectRandom; 
	_faction = _testFactions call BIS_fnc_selectRandom;
	_group = [_type,_faction] call ALIVE_fnc_configGetRandomGroup;
	if!(_group == "FALSE") then {
		[_group, _position] call ALIVE_fnc_createProfilesFromGroupConfig;
	};
} forEach _positions;


P_DEBUGON


//STAT("Run profile spawner");
//[] spawn {[1000,true] call ALIVE_fnc_profileSpawner};


STAT("Run profile analysis");
[ALIVE_sectorGrid] call ALIVE_fnc_gridAnalysisProfiles;


STAT("Get the player sector data hash");
_playerSectorData = [_playerSector, "data"] call ALIVE_fnc_hashGet;
["Sector Data:"] call ALIVE_fnc_dump;
_playerSectorData call ALIVE_fnc_inspectHash;


STAT("Sort profiles by distance to player");
_sortedProfilePositions = [_playerSectorData, "entitiesBySide", [getPos player,"WEST"]] call ALIVE_fnc_sectorDataSort;
["Sorted west profile positions: %1",_sortedProfilePositions] call ALIVE_fnc_dump;

if(count _sortedProfilePositions > 0) then {
	_nearestProfilePosition = _sortedProfilePositions select 0;
	_m = ["Nearest West Profile",(_nearestProfilePosition select 1),[1,1],"ColorOrange"] call _createMarker;
	sleep 20;
	deleteMarkerLocal _m;
};


STAT("Sleeping before clear");
sleep 30;


STAT("Destroy plotter instance");
[ALIVE_profileHandler, "destroy"] call ALIVE_fnc_profileHandler;



// Cleanup --------------------------------------------------------------------------------


STAT("Sleeping before destroy");
sleep 30;


STAT("Destroy plotter instance");
[_plotter, "destroy"] call ALIVE_fnc_plotSectors;


STAT("Destroy grid instance");
[ALIVE_sectorGrid, "destroy"] call ALIVE_fnc_sectorGrid;

nil;