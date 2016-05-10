// ----------------------------------------------------------------------------

#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(test_agentHandler);

//execVM "\x\alive\addons\amb_civ_population\tests\test_assignAgentCommands.sqf"

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

private["_agents","_agent","_type"];

// Get any active civilian agents

STAT("Get All Agents");

["ACTIVE AGENTS:"] call ALIVE_fnc_dump;

_agents = [ALIVE_agentHandler,"getAgents"] call ALIVE_fnc_agentHandler;


STAT("Assign Command To All Agents");

{
	_type = _x select 2 select 4;

	if(_type == "agent") then {
		_x call ALIVE_fnc_inspectHash;
		//[_x, "setActiveCommand", ["ALIVE_fnc_cc_suicideTarget", "managed", [WEST]]] call ALIVE_fnc_civilianAgent;
		[_x, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [WEST]]] call ALIVE_fnc_civilianAgent;
	};
} foreach (_agents select 2);


