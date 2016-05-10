// ----------------------------------------------------------------------------

#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(test_agentHandler);

//execVM "\x\alive\addons\amb_civ_population\tests\test_agentHandler.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

LOG("Testing Agent Handler Object");

ASSERT_DEFINED("ALIVE_fnc_agentHandler","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [ALIVE_agentHandler, "debug", true] call ALIVE_fnc_agentHandler; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [ALIVE_agentHandler, "debug", true] call ALIVE_fnc_agentHandler; \
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

STAT("Create Agent Handler instance");
if(isServer) then {
	ALIVE_agentHandler = [nil, "create"] call ALIVE_fnc_agentHandler;
	TEST_LOGIC = ALIVE_agentHandler;
	publicVariable "TEST_LOGIC";
};


STAT("Init Agent Handler");
_result = [ALIVE_agentHandler, "init"] call ALIVE_fnc_agentHandler;
_err = "set init";


STAT("Confirm new Agent Handler instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "ARRAY", _err);


STAT("Create Agent");
_agent1 = [nil, "create"] call ALIVE_fnc_civilianAgent;
[_agent1, "init"] call ALIVE_fnc_civilianAgent;
[_agent1, "agentID", "agent_01"] call ALIVE_fnc_civilianAgent;
[_agent1, "agentClass", "C_man_p_fugitive_F_afro"] call ALIVE_fnc_civilianAgent;
[_agent1, "position", getPos player] call ALIVE_fnc_civilianAgent;
[_agent1, "side", "CIV"] call ALIVE_fnc_civilianAgent;
[_agent1, "faction", "CIV_F"] call ALIVE_fnc_civilianAgent;
[_agent1, "homeCluster", "C_0"] call ALIVE_fnc_civilianAgent;


STAT("Register Agent");
_result = [_logic, "registerAgent", _agent1] call ALIVE_fnc_agentHandler;
_err = "register agent";


DEBUGON;


STAT("Get Agent");
_agent1 = [_logic, "getAgent", "agent_01"] call ALIVE_fnc_agentHandler;
_err = "get agent";
ASSERT_TRUE(typeName _agent1 == "ARRAY", _err);


diag_log _result;


STAT("Get Agents by cluster");
_result = [_logic, "getAgentsByCluster", "C_0"] call ALIVE_fnc_agentHandler;
_err = "get Agents by cluster";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


diag_log _result;



STAT("Spawn Agent 1");
[_agent1, "spawn"] call ALIVE_fnc_civilianAgent;


DEBUGON;


STAT("Despawn Agent 1");
[_agent1, "despawn"] call ALIVE_fnc_civilianAgent;


DEBUGON;


STAT("Un-Register Agent 1");
_result = [_logic, "unregisterAgent", _agent1] call ALIVE_fnc_agentHandler;
_err = "unregister agent";
ASSERT_TRUE(typeName _result == "BOOL", _err);


DEBUGON;


STAT("Destroy old Profile Handler instance");
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_agentHandler;
	TEST_LOGIC = nil;
	publicVariable "TEST_LOGIC";
} else {
	waitUntil{isNull TEST_LOGIC};
};

nil;