// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_UAVProfiles);

//execVM "\x\alive\addons\sys_profile\tests\test_UAVProfiles.sqf"

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
[] call ALIVE_fnc_cursorTargetInfo;

// CREATE PROFILE HANDLER
STAT("Create Profile Handler");
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;


STAT("Create Entity Profile 1");
_profileEntity1 = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity1, "unitClasses", ["B_UAV_AI"]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity1, "positions", [getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "damages", [0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "ranks", ["CAPTAIN"]] call ALIVE_fnc_profileEntity;
[_profileEntity1, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Create Vehicle Profile 1");
_profileVehicle1 = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "profileID", "vehicle_01"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "vehicleClass", "B_UAV_01_F"] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "position", [getPos player, 20, 180] call BIS_fnc_relPos] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "direction", 180] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle1, "side", "WEST"] call ALIVE_fnc_profileVehicle;


STAT("Register Profiles");
[ALIVE_profileHandler, "registerProfile", _profileEntity1] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "registerProfile", _profileVehicle1] call ALIVE_fnc_profileHandler;


STAT("Assign group 1 to vehicle 1");
[_profileEntity1,_profileVehicle1] call ALIVE_fnc_createProfileVehicleAssignment;


STAT("Add waypoint");
_position = [getPos player, 200, random 360] call BIS_fnc_relPos;
_profileWaypoint = [_position, 0] call ALIVE_fnc_createProfileWaypoint;
[_profileEntity1, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;


STAT("Spawn the unit via the profile");
[_profileEntity1, "spawn"] call ALIVE_fnc_profileEntity;


DEBUGON


sleep 30;


STAT("De-Spawn the unit via the profile");
[_profileEntity1, "despawn"] call ALIVE_fnc_profileEntity;


sleep 30;


STAT("Spawn the unit via the profile");
[_profileEntity1, "spawn"] call ALIVE_fnc_profileEntity;


sleep 30;


STAT("De-Spawn the unit via the profile");
[_profileEntity1, "despawn"] call ALIVE_fnc_profileEntity;


sleep 30;


STAT("Un-Register Profile");
[ALIVE_profileHandler, "unregisterProfile", _profileEntity1] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "unregisterProfile", _profileVehicle1] call ALIVE_fnc_profileHandler;


_profileEntity1 = nil;
_profileVehicle1 = nil;


DEBUGON