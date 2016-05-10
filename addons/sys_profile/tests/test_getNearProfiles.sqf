// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_getNearProfiles);

//execVM "\x\alive\addons\sys_profile\tests\test_getNearProfiles.sqf"

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

_sectors = [ALIVE_sectorGrid, "sectorsInRadius", [getPos player, 100]] call ALIVE_fnc_sectorGrid;
_mergedData = _sectors call ALIVE_fnc_sectorDataMerge;

_sortedFlatEmptyPositions = [_mergedData, "flatEmpty", [getPos player]] call ALIVE_fnc_sectorDataSort;

private ["_testFactions","_testTypes","_type","_faction","_group","_positions","_position","_testProfle","_sortedProfilePositions","_nearestProfilePosition","_m"];

_testFactions  = ["BLU_F"];
_testTypes = ["Infantry","Motorized","Mechanized","Air"];


STAT("Create Profile Handler");
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;

{
	_position = _x;
	_type = _testTypes call BIS_fnc_selectRandom; 
	_faction = _testFactions call BIS_fnc_selectRandom;
	_group = [_type,_faction] call ALIVE_fnc_configGetRandomGroup;
	if!(_group == "FALSE") then {
		[_group, _position] call ALIVE_fnc_createProfilesFromGroupConfig;
	};
} forEach _sortedFlatEmptyPositions;

DEBUGON

STAT("Get Near Profiles");
TIMERSTART
_profiles = [getPos player, 500, ["WEST","entity"]] call ALIVE_fnc_getNearProfiles;
TIMEREND

_markers = [];

{
	//_x call ALIVE_fnc_inspectHash;
	_position = _x select 2 select 2;		
	_position = [_position, 5, random 360] call BIS_fnc_relPos;

	if(count _position > 0) then {
		_m = createMarkerLocal [format["M1_%1", _forEachIndex], _position];
		_m setMarkerShapeLocal "ICON";
		_m setMarkerSizeLocal [1, 1];
		_m setMarkerTypeLocal "hd_dot";
		_m setMarkerColorLocal "ColorBlue";

		_markers set [count _markers, _m];			
	};
} forEach _profiles;


STAT("Get Near Profiles");
TIMERSTART
_profiles = [getPos player, 500, ["WEST","vehicle","Car"]] call ALIVE_fnc_getNearProfiles;
TIMEREND

{
	_position = _x select 2 select 2;		
	_position = [_position, 5, random 360] call BIS_fnc_relPos;

	if(count _position > 0) then {
		_m = createMarkerLocal [format["M2_%1", _forEachIndex], _position];
		_m setMarkerShapeLocal "ICON";
		_m setMarkerSizeLocal [1, 1];
		_m setMarkerTypeLocal "hd_dot";
		_m setMarkerColorLocal "ColorGreen";

		_markers set [count _markers, _m];			
	};
} forEach _profiles;

sleep 60;

{
	 deleteMarkerLocal _x;
} forEach _markers;