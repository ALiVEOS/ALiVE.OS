// ----------------------------------------------------------------------------
#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(test_logistics);
// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo"];

LOG("Testing logistics");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_logistics","ALIVE_fnc_logistics is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

STAT("Test Logistics 1 starting...");

_amo = +(allMissionObjects "");

STAT("Create instance");
_err = "Creating instance failed";
if(isServer) then {
	TEST_LOGIC = [nil, "create"] call ALIVE_fnc_logistics;
    ASSERT_DEFINED("TEST_LOGIC",_err);
    
    publicVariable "TEST_LOGIC";
};

_logic = TEST_LOGIC;

STAT("Confirm new instance on all localities");
_err = "Instantiating object failed";
waitUntil {!(isNil "TEST_LOGIC")};

STAT("Sleeping before destroy");
sleep 10;

STAT("Destroy created instance");
_err = "Destruction of old instance failed...";
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_logistics;
	TEST_LOGIC = nil;
} else {
	waitUntil {isNull TEST_LOGIC};
};


ASSERT_TRUE(isnil "TEST_LOGIC", _err);

diag_log (count ((allMissionObjects "") - _amo));

STAT("Test Logistics 1 finished...");