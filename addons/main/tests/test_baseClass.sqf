// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_baseClass);

// ----------------------------------------------------------------------------

private ["_err","_logic","_amo"];

LOG("Testing BaseClass");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_baseClass","ALIVE_fnc_baseClass is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

_amo = allMissionObjects "";

private ["_expected","_returned","_result"];
STAT("Test No Params");
_expected = objNull;
_returned = call ALIVE_fnc_baseClass;
_result = [typeName _expected, typeName _returned] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,typeOf _expected + " != " + typeOf _returned);

STAT("Destroy old instance");
[_returned, "destroy"] call ALIVE_fnc_baseClass;

STAT("Test non-OBJECT");
_expected = objNull;
_returned = 1234 call ALIVE_fnc_baseClass;
_result = [typeName _expected, typeName _returned] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,typeOf _expected + " != " + typeOf _returned);

STAT("Destroy old instance");
[_returned, "destroy"] call ALIVE_fnc_baseClass;

STAT("Test Empty Array");
_expected = objNull;
_returned = [] call ALIVE_fnc_baseClass;
_result = [typeName _expected, typeName _returned] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,typeOf _expected + " != " + typeOf _returned);

STAT("Destroy old instance");
[_returned, "destroy"] call ALIVE_fnc_baseClass;

_logic = nil;

STAT("Create instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_baseClass;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};
STAT("Confirm new instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "OBJECT", _err);

STAT("Sleeping before destroy");
sleep 5;

STAT("Destroy old instance");
if(isServer) then {
	[TEST_LOGIC, "destroy"] call ALIVE_fnc_baseClass;
	missionNamespace setVariable ["TEST_LOGIC",nil];
} else {
	waitUntil{isNull TEST_LOGIC};
};

diag_log ((allMissionObjects "") - _amo);

STAT("Create  instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_baseClass;
	TEST_LOGIC2 = _logic;
	publicVariable "TEST_LOGIC2";
};

STAT("Confirm second new  instance");
waitUntil{!isNil "TEST_LOGIC2"};
_logic = TEST_LOGIC2;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "OBJECT", _err);

STAT("Sleeping before destroy");
sleep 5;

if(isServer) then {
	STAT("Destroy old instance");
	[TEST_LOGIC2, "destroy"] call ALIVE_fnc_baseClass;
	missionNamespace setVariable ["TEST_LOGIC2",nil];
} else {
	STAT("Confirm destroy instance 2");
	waitUntil{isNull TEST_LOGIC2};
};

diag_log (allMissionObjects "") - _amo;

nil;
