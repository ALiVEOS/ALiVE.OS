// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_vehicleAssignment);

//execVM "\x\alive\addons\sys_profile\tests\test_vehicleAssignment.sqf"

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


//[] call ALIVE_fnc_vehicleGenerateEmptyPositionData;


// debug info on cursor target
//[] call ALIVE_fnc_cursorTargetInfo;

// CREATE PROFILE HANDLER
STAT("Create Profile Handler");
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;

// create sector grid
ALIVE_sectorGrid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[ALIVE_sectorGrid, "init"] call ALIVE_fnc_sectorGrid;
[ALIVE_sectorGrid, "createGrid"] call ALIVE_fnc_sectorGrid;

// create sector plotter
ALIVE_sectorPlotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[ALIVE_sectorPlotter, "init"] call ALIVE_fnc_plotSectors;

// import static map analysis to the grid
[ALIVE_sectorGrid] call ALIVE_fnc_gridImportStaticMapAnalysis;

// create live analysis
ALIVE_liveAnalysis = [nil, "create"] call ALIVE_fnc_liveAnalysis;
[ALIVE_liveAnalysis, "init"] call ALIVE_fnc_liveAnalysis;
[ALIVE_liveAnalysis, "debug", false] call ALIVE_fnc_liveAnalysis;

// create battlefield analysis
ALIVE_battlefieldAnalysis = [nil, "create"] call ALIVE_fnc_battlefieldAnalysis;
[ALIVE_battlefieldAnalysis, "init"] call ALIVE_fnc_battlefieldAnalysis;
[ALIVE_battlefieldAnalysis, "debug", false] call ALIVE_fnc_battlefieldAnalysis;


/*

STAT("Create Entity Profile");
_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity, "unitClasses", ["B_Soldier_TL_F","B_Soldier_SL_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity, "positions", [getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity, "damages", [0,0,0,0,0,0,0,0,0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity, "ranks", ["CAPTAIN","LIEUTENANT","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Create Vehicle Profile");
_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "profileID", "vehicle_01"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "vehicleClass", "B_Heli_Transport_01_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "side", "WEST"] call ALIVE_fnc_profileVehicle;


STAT("Register Profile");
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;


DEBUGON


STAT("Assign group 1 to vehicle 1");
[_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;


DEBUGON


STAT("Spawn the unit via the profile");
[_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


sleep 30;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;

STAT("De-Spawn the unit via the profile");
[_profileVehicle, "despawn"] call ALIVE_fnc_profileVehicle;


sleep 10;


STAT("Un-Register Profile");
[ALIVE_profileHandler, "unregisterProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "unregisterProfile", _profileVehicle] call ALIVE_fnc_profileHandler;


_profileEntity = nil;
_profileVehicle = nil;
*/

DEBUGON



STAT("Create Entity Profile");
_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity, "unitClasses", ["B_Soldier_TL_F","B_Soldier_SL_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity, "positions", [getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity, "damages", [0,0,0,0,0,0,0,0,0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity, "ranks", ["CAPTAIN","LIEUTENANT","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Create Vehicle Profile");
_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "profileID", "vehicle_01"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "vehicleClass", "B_APC_Wheeled_01_cannon_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "side", "WEST"] call ALIVE_fnc_profileVehicle;


STAT("Register Profile");
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;


STAT("Assign group 1 to vehicle 1");
[_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;


DEBUGON


STAT("Spawn the unit via the profile");
[_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


sleep 30;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;

STAT("De-Spawn the unit via the profile");
[_profileVehicle, "despawn"] call ALIVE_fnc_profileVehicle;


STAT("Un-Register Profile");
[ALIVE_profileHandler, "unregisterProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "unregisterProfile", _profileVehicle] call ALIVE_fnc_profileHandler;


_profileEntity = nil;
_profileVehicle = nil;


DEBUGON

/*

STAT("Create Entity Profile");
_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity, "unitClasses", ["B_Soldier_TL_F","B_Soldier_SL_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity, "positions", [getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity, "damages", [0,0,0,0,0,0,0,0,0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity, "ranks", ["CAPTAIN","LIEUTENANT","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Create Vehicle Profile");
_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "profileID", "vehicle_01"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "vehicleClass", "B_Truck_01_covered_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "side", "WEST"] call ALIVE_fnc_profileVehicle;


STAT("Register Profile");
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;


STAT("Assign group 1 to vehicle 1");
[_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;


DEBUGON


STAT("Spawn the unit via the profile");
[_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


sleep 30;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;

STAT("De-Spawn the unit via the profile");
[_profileVehicle, "despawn"] call ALIVE_fnc_profileVehicle;


STAT("Un-Register Profile");
[ALIVE_profileHandler, "unregisterProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "unregisterProfile", _profileVehicle] call ALIVE_fnc_profileHandler;


_profileEntity = nil;
_profileVehicle = nil;

*/


DEBUGON

/*

STAT("Create Entity Profile");
_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity, "unitClasses", ["B_Soldier_TL_F","B_Soldier_SL_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity, "positions", [getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity, "damages", [0,0,0,0,0,0,0,0,0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity, "ranks", ["CAPTAIN","LIEUTENANT","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE","PRIVATE"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Create Vehicle Profile");
_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "profileID", "vehicle_01"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "vehicleClass", "B_MRAP_01_gmg_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "side", "WEST"] call ALIVE_fnc_profileVehicle;


STAT("Create Vehicle Profile");
_profileVehicle2 = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "profileID", "vehicle_02"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "vehicleClass", "B_Heli_Light_01_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "position", [getPos player, 40, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "side", "WEST"] call ALIVE_fnc_profileVehicle;


STAT("Register Profile");
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle2] call ALIVE_fnc_profileHandler;


STAT("Assign group 1 to vehicle 2");
[_profileEntity,_profileVehicle2] call ALIVE_fnc_createProfileVehicleAssignment;


STAT("Assign group 1 to vehicle 1");
[_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;


DEBUGON


STAT("Spawn the unit via the profile");
[_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


sleep 30;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;

STAT("De-Spawn the unit via the profile");
[_profileVehicle, "despawn"] call ALIVE_fnc_profileVehicle;

STAT("De-Spawn the unit via the profile");
[_profileVehicle2, "despawn"] call ALIVE_fnc_profileVehicle;


STAT("Un-Register Profile");
[ALIVE_profileHandler, "unregisterProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "unregisterProfile", _profileVehicle] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "unregisterProfile", _profileVehicle2] call ALIVE_fnc_profileHandler;


DEBUGON


_profileEntity = nil;
_profileVehicle = nil;

*/