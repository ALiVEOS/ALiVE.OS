// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_profileWaypoint);

//execVM "\x\alive\addons\sys_profile\tests\test_profileWaypoint.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2","_profileEntity","_position","_profileWaypoint"];

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
_result = [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler; \
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

// CREATE PROFILE HANDLER
STAT("Create Profile Handler");
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;


STAT("Create Entity Profile");
_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", "group_01"] call ALIVE_fnc_profileEntity;
[_profileEntity, "unitClasses", ["B_Soldier_TL_F","B_Soldier_SL_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", getPos player] call ALIVE_fnc_profileEntity;
[_profileEntity, "positions", [getPos player,getPos player,getPos player]] call ALIVE_fnc_profileEntity;
[_profileEntity, "damages", [0,0,0]] call ALIVE_fnc_profileEntity;
[_profileEntity, "ranks", ["CAPTAIN","LIEUTENANT","PRIVATE"]] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", "WEST"] call ALIVE_fnc_profileEntity;


STAT("Register Profile");
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;


STAT("Delete local profile references");
_profileEntity = nil;


STAT("Get the unit profile from the profile handler");
_profileEntity = [ALIVE_profileHandler, "getProfile", "group_01"] call ALIVE_fnc_profileHandler;


STAT("Set debug on profile handler");
[ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler;


STAT("Spawn the unit via the profile");
_unit = [_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


//_unit setDammage 1;


STAT("Sleep for 10");
SLEEP 10;


STAT("Profile state");
_profileEntity = [ALIVE_profileHandler, "getProfile", "group_01"] call ALIVE_fnc_profileHandler;
_profileEntity call ALIVE_fnc_inspectHash;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;


STAT("Add waypoint");
_position = [getPos player, 200, random 360] call BIS_fnc_relPos;
_profileWaypoint = [_position, 0] call ALIVE_fnc_createProfileWaypoint;
[_profileEntity, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

/*
_m = createMarkerLocal ["destinationMarker1", _position];
_m setMarkerShapeLocal "ICON";
_m setMarkerSizeLocal [1, 1];
_m setMarkerTypeLocal "hd_dot";
_m setMarkerColorLocal "ColorRed";
_m setMarkerTextLocal "destination";
*/

STAT("Add waypoint");
_position = [_position, 200, random 360] call BIS_fnc_relPos;
_profileWaypoint = [_position, 0] call ALIVE_fnc_createProfileWaypoint;
[_profileEntity, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

/*
_m = createMarkerLocal ["destinationMarker2", _position];
_m setMarkerShapeLocal "ICON";
_m setMarkerSizeLocal [1, 1];
_m setMarkerTypeLocal "hd_dot";
_m setMarkerColorLocal "ColorRed";
_m setMarkerTextLocal "destination";
*/


_fakeLogic = [] call ALIVE_fnc_hashCreate;
[_fakeLogic,"debug",true] call ALIVE_fnc_hashSet;
// start the profile controller FSM
//[_fakeLogic,50] execFSM "\x\alive\addons\sys_profile\profileController.fsm";

_handle = [_fakeLogic] execFSM "\x\alive\addons\sys_profile\profileSimulator.fsm";						


STAT("Sleep for 10");
SLEEP 20;


STAT("Spawn the unit via the profile");
_unit = [_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


STAT("Sleep for 10");
SLEEP 20;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;

STAT("Sleep for 10");
SLEEP 20;


STAT("Spawn the unit via the profile");
_unit = [_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


STAT("Sleep for 10");
SLEEP 20;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;


STAT("Sleep for 10");
SLEEP 20;


STAT("Spawn the unit via the profile");
_unit = [_profileEntity, "spawn"] call ALIVE_fnc_profileEntity;


STAT("Sleep for 10");
SLEEP 20;


terminate _handle;


STAT("De-Spawn the unit via the profile");
[_profileEntity, "despawn"] call ALIVE_fnc_profileEntity;


STAT("Un-Register Profile");
_result = [ALIVE_profileHandler, "unregisterProfile", _profileEntity] call ALIVE_fnc_profileHandler;
_err = "unregister profile";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Destroy old Profile instance");
if(isServer) then {
	[_profileEntity, "destroy"] call ALIVE_fnc_profileEntity;
	TEST_LOGIC = nil;
	publicVariable "TEST_LOGIC";
} else {
	waitUntil{isNull TEST_LOGIC};
};


STAT("Destroy old Profile Handler instance");
if(isServer) then {
	[ALIVE_profileHandler, "destroy"] call ALIVE_fnc_profileHandler;
	TEST_LOGIC = nil;
	publicVariable "TEST_LOGIC";
} else {
	waitUntil{isNull TEST_LOGIC};
};