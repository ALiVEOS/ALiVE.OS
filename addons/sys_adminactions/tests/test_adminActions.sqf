// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(test_adminActions);

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo"];

LOG("Testing AdminActions");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_adminActions","ALIVE_fnc_adminActions is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

_amo = allMissionObjects "";

_logic = nil;

STAT("Create instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_adminActions;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};
STAT("Confirm new instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "OBJECT", _err);

// Only do the check if not in Editor
if(isMultiplayer) then {

STAT("Check not server admin");
_result = [_logic, "active"] call ALIVE_fnc_adminActions;
ASSERT_FALSE(_result, "Player is already server admin");

STAT("Login as server admin");
serverCommand "#login";

STAT("Check is server admin");
_result = [_logic, "active"] call ALIVE_fnc_adminActions;
ASSERT_TRUE(_result, "Player is not server admin");
};

STAT("Sleeping before destroy");
sleep 5;

STAT("Destroy old instance");
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_adminActions;
	missionNamespace setVariable ["TEST_LOGIC",nil];
} else {
	waitUntil{isNull TEST_LOGIC};
};

diag_log (allMissionObjects "") - _amo;

nil;
