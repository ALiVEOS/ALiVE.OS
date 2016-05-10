// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_groupConfigBestPlacesSpawn);

//execVM "\x\alive\addons\sys_profile\tests\test_groupConfigBestPlacesSpawn.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2","_unitProfile","_groupProfile","_profileVehicle"];

LOG("Testing Profile Handler Object");

ASSERT_DEFINED("ALIVE_fnc_profileHandler","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
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


player setCaptive true;

// debug info on cursor target
//[] call ALIVE_fnc_cursorTargetInfo;

STAT("Create SectorGrid instance");
TIMERSTART
ALIVE_sectorGrid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[ALIVE_sectorGrid, "init"] call ALIVE_fnc_sectorGrid;
TIMEREND


STAT("Create Grid");
TIMERSTART
_result = [ALIVE_sectorGrid, "createGrid"] call ALIVE_fnc_sectorGrid;
TIMEREND


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


DEBUGON


_fakeLogic = [] call ALIVE_fnc_hashCreate;
[_fakeLogic,"debug",true] call ALIVE_fnc_hashSet;
// start the profile controller FSM
//[_fakeLogic,50] execFSM "\x\alive\addons\sys_profile\profileController.fsm";

_handle = [_fakeLogic] execFSM "\x\alive\addons\sys_profile\profileSimulator.fsm";						
_handle = [_fakeLogic,1000] execFSM "\x\alive\addons\sys_profile\profileSpawner.fsm";