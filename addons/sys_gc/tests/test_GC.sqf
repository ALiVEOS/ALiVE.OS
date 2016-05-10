// ----------------------------------------------------------------------------
#include <\x\alive\addons\sys_GC\script_component.hpp>
SCRIPT(test_GC);
// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo"];

LOG("Testing Garbage Collector");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_GC","ALIVE_fnc_GC is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

STAT("Test GC 1 starting...");

_amo = +(allMissionObjects "");

STAT("Create Garbage Collector instance");
_err = "Creating instance failed";
if(isServer) then {
	TEST_LOGIC = [nil, "create"] call ALIVE_fnc_GC;
    ASSERT_DEFINED("TEST_LOGIC",_err);
    
    publicVariable "TEST_LOGIC";
};

_logic = TEST_LOGIC;

STAT("Confirm new instance on all localities");
_err = "Instantiating object failed";
waitUntil {!(isNil "TEST_LOGIC")};

STAT("Sleeping before destroy");
sleep 10;

STAT("Destroy Garbage Collector instance");
_err = "Destruction of old instance failed...";
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_GC;
	TEST_LOGIC = nil;
} else {
	waitUntil {isNull TEST_LOGIC};
};
ASSERT_TRUE(isnil "TEST_LOGIC", _err);

diag_log (count ((allMissionObjects "") - _amo));

STAT("Test GC 1 finished...");