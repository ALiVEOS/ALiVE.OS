// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_profileEntity);

//execVM "\x\alive\addons\sys_profile\tests\test_profileEntity.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_profileWaypoint"];

LOG("Testing Agent Profile Object");

ASSERT_DEFINED("ALIVE_fnc_profileEntity","");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_profileEntity; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_profileEntity; \
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
[ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler;


_logic = nil;

STAT("Create Profile instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_profileEntity;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};


STAT("Init Profile");
_result = [_logic, "init"] call ALIVE_fnc_profileEntity;
_err = "set init";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Confirm new Profile instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "ARRAY", _err);


STAT("Set profile id");
_result = [_logic, "profileID", "agent_01"] call ALIVE_fnc_profileEntity;
_err = "set profile id";
ASSERT_TRUE(typeName _result == "STRING", _err);


STAT("Set company ID");
_result = [_logic, "companyID", "company_01"] call ALIVE_fnc_profileEntity;
_err = "set companyID";
ASSERT_TRUE(typeName _result == "STRING", _err);


STAT("Set unit classes");
_result = [_logic, "unitClasses", ["B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;
_err = "set unit classes";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Set position");
_result = [_logic, "position", getPos player] call ALIVE_fnc_profileEntity;
_err = "set position";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Set unit positions");
_result = [_logic, "positions", [getPos player,getPos player]] call ALIVE_fnc_profileEntity;
_err = "set unit positions";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Set unit damages");
_result = [_logic, "damages", [0,0]] call ALIVE_fnc_profileEntity;
_err = "set unit damages";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Set unit ranks");
_result = [_logic, "ranks", ["PRIVATE","CORPORAL"]] call ALIVE_fnc_profileEntity;
_err = "set unit ranks";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Set side");
_result = [_logic, "side", "WEST"] call ALIVE_fnc_profileEntity;
_err = "set side";
ASSERT_TRUE(typeName _result == "STRING", _err);


STAT("Set active");
_result = [_logic, "active", false] call ALIVE_fnc_profileEntity;
_err = "set active";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Get unit count");
_result = [_logic, "unitCount"] call ALIVE_fnc_profileEntity;
_err = "get unit count";
ASSERT_TRUE(typeName _result == "SCALAR", _err);


STAT("Merge positions");
_result = [_logic, "mergePositions", getPos player] call ALIVE_fnc_profileEntity;
_err = "merge positions";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Add unit");
_result = [_logic, "addUnit", ["B_Soldier_F",getPos player,0]] call ALIVE_fnc_profileEntity;
_err = "merge positions";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Get state");
_state = [_logic, "state"] call ALIVE_fnc_profileEntity;
_err = "get state";
ASSERT_TRUE(typeName _state == "ARRAY", _err);

_state call ALIVE_fnc_inspectHash;


STAT("Register the profile on the handler");
[ALIVE_profileHandler, "registerProfile", _logic] call ALIVE_fnc_profileHandler;


STAT("Remove unit");
_result = [_logic, "removeUnit", 1] call ALIVE_fnc_profileEntity;
_err = "merge positions";
ASSERT_TRUE(typeName _result == "BOOL", _err);


_profileWaypoint = [getPos player, 100] call ALIVE_fnc_createProfileWaypoint;
_profileWaypoint call ALIVE_fnc_inspectHash;


STAT("Add waypoint");
_result = [_logic, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
_err = "add waypoint";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


_profileWaypoint = [getPos player, 100] call ALIVE_fnc_createProfileWaypoint;
_profileWaypoint call ALIVE_fnc_inspectHash;


STAT("Add waypoint");
_result = [_logic, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
_err = "add waypoint";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Clear waypoints");
_result = [_logic, "clearWaypoints"] call ALIVE_fnc_profileEntity;
_err = "clear waypoints";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Get state");
_state = [_logic, "state"] call ALIVE_fnc_profileEntity;
_err = "get state";
ASSERT_TRUE(typeName _state == "ARRAY", _err);


DEBUGON
_state call ALIVE_fnc_inspectHash;

_ai_count = count allUnits;

STAT("Spawn");
_result = [_logic, "spawn"] call ALIVE_fnc_profileEntity;
_err = "spawn";
ASSERT_TRUE(typeName _result == "BOOL", _err);
ASSERT_TRUE(count allUnits == _ai_count + 2, _err);  


STAT("Sleeping before despawn");
sleep 5;


STAT("De-Spawn");
_result = [_logic, "despawn"] call ALIVE_fnc_profileEntity;
_err = "despawn";
ASSERT_TRUE(typeName _result == "BOOL", _err);
ASSERT_TRUE(count allUnits == _ai_count, _err);


STAT("Dead unit Spawn");
_result = [_logic, "damages"] call ALIVE_fnc_profileEntity;
_err = "dead unit spawn";
_result set [1, 1];
[_logic, "damages", _result] call ALIVE_fnc_profileEntity;
_result = [_logic, "spawn"] call ALIVE_fnc_profileEntity;
ASSERT_TRUE(typeName _result == "BOOL", _err);
ASSERT_TRUE(count allUnits == _ai_count + 1, _err);


STAT("Sleeping before despawn");
sleep 5;


STAT("Dead unit De-Spawn");
_result = [_logic, "despawn"] call ALIVE_fnc_profileEntity;
_err = "dead unit despawn";
ASSERT_TRUE(typeName _result == "BOOL", _err);
ASSERT_TRUE(count allUnits == _ai_count, _err);


STAT("Sleeping before destroy");
sleep 10;


STAT("Destroy old Profile instance");
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_profileEntity;
	TEST_LOGIC = nil;
	publicVariable "TEST_LOGIC";
} else {
	waitUntil{isNull TEST_LOGIC};
};

nil;