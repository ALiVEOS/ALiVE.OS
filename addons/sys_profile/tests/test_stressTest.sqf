// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_getNearProfiles);

//execVM "\x\alive\addons\sys_profile\tests\test_stressTest.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2","_unitProfile","_groupProfile","_profileVehicle","_markers"];

LOG("Testing Get Near Profiles Function");

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


TIMERSTART
STAT("Creating profile system components");
// create sector grid
ALIVE_sectorGrid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[ALIVE_sectorGrid, "init"] call ALIVE_fnc_sectorGrid;
[ALIVE_sectorGrid, "createGrid"] call ALIVE_fnc_sectorGrid;

// create sector plotter
ALIVE_sectorPlotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[ALIVE_sectorPlotter, "init"] call ALIVE_fnc_plotSectors;

// import static map analysis to the grid
[ALIVE_sectorGrid] call ALIVE_fnc_gridImportStaticMapAnalysis;

// create the profile handler
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;

// turn on debug again to see the state of the profile handler, and set debug on all a profiles
[ALIVE_profileHandler, "debug", false] call ALIVE_fnc_profileHandler;

// create array block stepper
ALIVE_arrayBlockHandler = [nil, "create"] call ALIVE_fnc_arrayBlockHandler;
[ALIVE_arrayBlockHandler, "init"] call ALIVE_fnc_arrayBlockHandler;
TIMEREND


TIMERSTART
STAT("Getting sectors in radius");
_sectors = [ALIVE_sectorGrid, "sectorsInRadius", [getPos player, 500]] call ALIVE_fnc_sectorGrid;
TIMEREND


TIMERSTART
STAT("Merging Sector Data");
_mergedData = _sectors call ALIVE_fnc_sectorDataMerge;
TIMEREND


TIMERSTART
STAT("Get Flat Empty Positions");
_flatEmptyPositions = [_mergedData, "flatEmpty"] call ALIVE_fnc_hashGet;
TIMEREND


TIMERSTART
STAT("Generating random groups for flat empty positions");
private ["_testFactions","_testTypes","_type","_faction","_group"];

_testFactions  = ["BLU_F"];
//_testTypes = ["Infantry","Motorized","Mechanized","Air"];
_testTypes = ["Infantry"];
_maxEntities = 200;

{
	if(_forEachIndex < _maxEntities) then {
		_position = _x;
		_type = _testTypes call BIS_fnc_selectRandom; 
		_faction = _testFactions call BIS_fnc_selectRandom;
		_group = [_type,_faction] call ALIVE_fnc_configGetRandomGroup;
		if!(_group == "FALSE") then {
			[_group, _position] call ALIVE_fnc_createProfilesFromGroupConfig;
		};
	};
} forEach _flatEmptyPositions;
TIMEREND


DEBUGON


_profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
_maxWaypoints = 200;
_waypointDestination = getPos player;

{
	_profileType = _x select 2 select 5; //[_x,"type"] call ALIVE_fnc_hashGet;
	
	if(_profileType == "entity") then {
		if(_forEachIndex < _maxWaypoints) then {
			_profileWaypoint = [_waypointDestination, 0] call ALIVE_fnc_createProfileWaypoint;
			[_x, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
		};
	};
} forEach (_profiles select 2);


_fakeLogic = [] call ALIVE_fnc_hashCreate;
[_fakeLogic,"debug",true] call ALIVE_fnc_hashSet;
// start the profile controller FSM
//[_fakeLogic,50] execFSM "\x\alive\addons\sys_profile\profileController.fsm";

_handle = [_fakeLogic] execFSM "\x\alive\addons\sys_profile\profileSimulator.fsm";						
_handle = [_fakeLogic,100] execFSM "\x\alive\addons\sys_profile\profileSpawner.fsm";

