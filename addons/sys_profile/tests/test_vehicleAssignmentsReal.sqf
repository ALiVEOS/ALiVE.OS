// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_vehicleAssignmentsReal);

//execVM "\x\alive\addons\sys_profile\tests\test_vehicleAssignmentsReal.sqf"

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

player setCaptive true;

// debug info on cursor target
//[] call ALIVE_fnc_cursorTargetInfo;

// CREATE PROFILE HANDLER
STAT("Create Profile Handler");
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;


STAT("Create Entity Profile");
_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity, "unitClasses", ["B_Crew_F","B_Crew_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity, "positions", [getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity, "damages", [0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity, "ranks", ["CAPTAIN","LIEUTENANT"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Create Entity Profile");
_profileEntity1 = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "profileID", "group_02"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "unitClasses", ["B_Crew_F","B_Crew_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity1, "positions", [getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "damages", [0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "ranks", ["CAPTAIN","LIEUTENANT"]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Create Entity Profile");
_profileEntity2 = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity2, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity2, "profileID", "group_03"] call ALIVE_fnc_profileEntity;
[_profileEntity2, "unitClasses", ["B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity2, "positions", [getPos player,getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "damages", [0,0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "ranks", ["CAPTAIN","LIEUTENANT","PRIVATE","PRIVATE"]] call ALIVE_fnc_profileEntity;
[_profileEntity2, "side", "WEST"] call ALIVE_fnc_profileEntity;


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
_profileVehicle1 = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "profileID", "vehicle_02"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "vehicleClass", "B_MRAP_01_gmg_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "side", "WEST"] call ALIVE_fnc_profileVehicle;


STAT("Register Profile");
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileEntity1] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileEntity2] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle1] call ALIVE_fnc_profileHandler;


DEBUGON


STAT("Spawn the unit via the profile");
[_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;

STAT("Spawn the unit via the profile");
[_profileEntity1, "spawn"] call ALIVE_fnc_profileEntity;

STAT("Spawn the unit via the profile");
[_profileEntity2, "spawn"] call ALIVE_fnc_profileEntity;

STAT("Spawn the vehicle via the profile");
[_profileVehicle, "spawn"] call ALIVE_fnc_profileVehicle;

STAT("Spawn the vehicle via the profile");
[_profileVehicle1, "spawn"] call ALIVE_fnc_profileVehicle;


STAT("Get refernces to real objects");
_units1 = [_profileEntity, "units"] call ALIVE_fnc_hashGet;
_group1 = group (_units1 select 0);
_vehicle1 = [_profileVehicle, "vehicle"] call ALIVE_fnc_hashGet;


STAT("Assign the real group to the vehicle");
_result = [_group1, _vehicle1, true] call ALIVE_fnc_vehicleAssignGroup;


STAT("Wait for group to board vehicle");
SLEEP 30;


STAT("Get refernces to real objects");
_units2 = [_profileEntity1, "units"] call ALIVE_fnc_hashGet;
_group2 = group (_units2 select 0);
_vehicle2 = [_profileVehicle1, "vehicle"] call ALIVE_fnc_hashGet;


STAT("Assign the real group to the vehicle");
_result = [_group2, _vehicle2, true] call ALIVE_fnc_vehicleAssignGroup;


STAT("Wait for group to board vehicle");
SLEEP 30;


STAT("Get refernces to real objects");
_units3 = [_profileEntity2, "units"] call ALIVE_fnc_hashGet;
_unit1 = _units3 select 0;
_unit2 = _units3 select 1;
_unit3 = _units3 select 2;
_unit4 = _units3 select 3;

_unit1 assignAsCargo _vehicle1;
_unit2 assignAsCargo _vehicle1;
_unit3 assignAsCargo _vehicle2;
_unit4 assignAsCargo _vehicle2;

[_unit1] orderGetIn true;
[_unit2] orderGetIn true;
[_unit3] orderGetIn true;
[_unit4] orderGetIn true;


STAT("Wait for group to board vehicles");
SLEEP 30;


STAT("De-Spawn the vehicle via the profile");
[_profileVehicle, "despawn"] call ALIVE_fnc_profileVehicle;


DEBUGON