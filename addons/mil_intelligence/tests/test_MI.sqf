// ----------------------------------------------------------------------------

#include <\x\alive\addons\mil_intelligence\script_component.hpp>
SCRIPT(test_MP);

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo","_state","_result2"];

LOG("Testing MI");

ASSERT_DEFINED("ALIVE_fnc_MP","");

#define STAT(msg) sleep 0.5; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_MI; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_MI; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

//========================================

_amo = allMissionObjects "";

_logic = nil;

STAT("Create MI instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_MI;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};
STAT("Confirm new MI instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
ASSERT_DEFINED("_logic",_logic);
ASSERT_TRUE(typeName _logic == "OBJECT", typeName _logic);

DEBUGON

nil;
