// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_vehicleSpawnDespawnBug);

//execVM "\x\alive\addons\sys_profile\tests\test_vehicleSpawnDespawnBug.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2","_unitProfile","_groupProfile","_profileVehicle"];

LOG("Testing Profile Handler Object");

ASSERT_DEFINED("ALIVE_profileHandler","");

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


STAT("Create Entity Profile 1");
_profileEntity1 = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "unitClasses", ["B_Crew_F","B_Crew_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity1, "positions", [getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "damages", [0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "ranks", ["CAPTAIN","LIEUTENANT"]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "side", "WEST"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "faction", "BLU_F"] call ALIVE_fnc_profileEntity;


STAT("Create Entity Profile 2");
_profileEntity2 = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity2, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity2, "profileID", "group_02"] call ALIVE_fnc_profileEntity;
[_profileEntity2, "unitClasses", ["B_Crew_F","B_Crew_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity2, "positions", [getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "damages", [0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "ranks", ["CAPTAIN","LIEUTENANT"]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "side", "WEST"] call ALIVE_fnc_profileEntity;
[_profileEntity2, "faction", "BLU_F"] call ALIVE_fnc_profileEntity;


STAT("Create Entity Profile 3");
_profileEntity3 = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity3, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity3, "profileID", "group_03"] call ALIVE_fnc_profileEntity;
[_profileEntity3, "unitClasses", ["B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity3, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity3, "positions", [getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity3, "damages", [0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity3, "ranks", ["CAPTAIN","LIEUTENANT","PRIVATE","PRIVATE"]] call ALIVE_fnc_profileEntity;
[_profileEntity3, "side", "WEST"] call ALIVE_fnc_profileEntity;
[_profileEntity3, "faction", "BLU_F"] call ALIVE_fnc_profileEntity;


STAT("Create Vehicle Profile 1");
_profileVehicle1 = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "profileID", "vehicle_01"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "vehicleClass", "B_MRAP_01_gmg_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "side", "WEST"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "faction", "BLU_F"] call ALIVE_fnc_profileEntity;


STAT("Create Vehicle Profile 2");
_profileVehicle2 = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "profileID", "vehicle_02"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "vehicleClass", "B_MRAP_01_gmg_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "side", "WEST"] call ALIVE_fnc_profileVehicle;
[_profileVehicle2, "faction", "BLU_F"] call ALIVE_fnc_profileEntity;


STAT("Register Profiles");
[ALIVE_profileHandler, "registerProfile", _profileEntity1] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileEntity2] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileEntity3] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle1] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle2] call ALIVE_fnc_profileHandler;


DEBUGON


STAT("Assign entity 1 to vehicle 1");
[_profileEntity1,_profileVehicle1] call ALIVE_fnc_createProfileVehicleAssignment;


STAT("Wait for group to board vehicle");
SLEEP 20;


STAT("Assign entity 2 to vehicle 2");
[_profileEntity2,_profileVehicle2] call ALIVE_fnc_createProfileVehicleAssignment;


STAT("Wait for group to board vehicle");
SLEEP 20;


STAT("Assign entity 3 to vehicle 1");
[_profileEntity3,_profileVehicle1] call ALIVE_fnc_createProfileVehicleAssignment;


STAT("Assign entity 3 to vehicle 2");
[_profileEntity3,_profileVehicle2] call ALIVE_fnc_createProfileVehicleAssignment;


STAT("Wait for group to board vehicles");
SLEEP 20;

_profileVehicle1 call ALIVE_fnc_inspectHash;

STAT("Move Vehicle 1 3000 meters direction 0");
_vehicle1 = [_profileVehicle1, "vehicle"] call ALIVE_fnc_hashGet;
["V: %1", _vehicle1] call ALIVE_fnc_dump;
["P: %1", getPos _vehicle1] call ALIVE_fnc_dump;
_newPosition = [getPos _vehicle1, 3000, 0] call BIS_fnc_relPos;
["NP: %1", _newPosition] call ALIVE_fnc_dump;
_vehicle1 setPos _newPosition;

