// ----------------------------------------------------------------------------

#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(test_civilianAgent);

//execVM "\x\alive\addons\amb_civ_population\tests\test_civilianAgent.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

LOG("Testing Civilian Agent Object");

ASSERT_DEFINED("ALIVE_fnc_civilianAgent","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_civilianAgent; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_civilianAgent; \
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

_logic = nil;

STAT("Create Agent instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_civilianAgent;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};


STAT("Init Agent");
_result = [_logic, "init"] call ALIVE_fnc_civilianAgent;
_err = "set init";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Confirm new Agent instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "ARRAY", _err);


STAT("Set agent id");
_result = [_logic, "agentID", "agent_01"] call ALIVE_fnc_civilianAgent;
_err = "set profile id";
ASSERT_TRUE(typeName _result == "STRING", _err);


STAT("Set agent class");
_result = [_logic, "agentClass", "C_man_p_fugitive_F_afro"] call ALIVE_fnc_civilianAgent;
_err = "set vehicle classes";
ASSERT_TRUE(typeName _result == "STRING", _err);


STAT("Set position");
_result = [_logic, "position", getPos player] call ALIVE_fnc_civilianAgent;
_err = "set position";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Get state");
_state = [_logic, "state"] call ALIVE_fnc_civilianAgent;
_err = "get state";
ASSERT_TRUE(typeName _state == "ARRAY", _err);


_state call ALIVE_fnc_inspectHash;


STAT("Spawn");
_result = [_logic, "spawn"] call ALIVE_fnc_civilianAgent;
_err = "spawn";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Sleeping before despawn");
sleep 40;


STAT("De-Spawn");
_result = [_logic, "despawn"] call ALIVE_fnc_civilianAgent;
_err = "despawn";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Get state");
_state = [_logic, "state"] call ALIVE_fnc_civilianAgent;
_err = "get state";
ASSERT_TRUE(typeName _state == "ARRAY", _err);


_state call ALIVE_fnc_inspectHash;


STAT("Sleeping before respawn");
sleep 10;


STAT("Spawn");
_result = [_logic, "spawn"] call ALIVE_fnc_civilianAgent;
_err = "spawn";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Sleeping before despawn");
sleep 40;


STAT("De-Spawn");
_result = [_logic, "despawn"] call ALIVE_fnc_civilianAgent;
_err = "despawn";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Sleeping before destroy");
sleep 40;


STAT("Destroy old Profile instance");
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_civilianAgent;
	TEST_LOGIC = nil;
	publicVariable "TEST_LOGIC";
} else {
	waitUntil{isNull TEST_LOGIC};
};

nil;