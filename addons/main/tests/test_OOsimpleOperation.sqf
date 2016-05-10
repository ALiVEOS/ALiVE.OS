// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_OOsimpleOperation);

// ----------------------------------------------------------------------------

private ["_result","_err","_logic"];

LOG("Testing OO Simple Operation");

ASSERT_DEFINED("ALIVE_fnc_OOsimpleOperation","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

//========================================

_logic = nil;

STAT("Create Object instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_baseClass;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};
STAT("Confirm new Cluster instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "OBJECT", _err);

STAT("Test STRING default");
_result = [_logic, "type", objNull, "x123", ["x123","x456"]] call ALIVE_fnc_OOsimpleOperation;
ASSERT_TRUE(typeName _result == "STRING", typeName _result);
ASSERT_TRUE(_result == "x123", _result);

STAT("Test bad STRING value");
_result = [_logic, "type", "xxx", "x123", ["x123","x456"]] call ALIVE_fnc_OOsimpleOperation;
ASSERT_TRUE(typeName _result == "STRING", typeName _result);
ASSERT_TRUE(_result == "x123", _result);

STAT("Test good STRING value");
_result = [_logic, "type", "military", "x456", ["x123","x456"]] call ALIVE_fnc_OOsimpleOperation;
ASSERT_TRUE(typeName _result == "STRING", typeName _result);
ASSERT_TRUE(_result == "x456", _result);

STAT("Test SCALAR default");
_result = [_logic, "priority", objNull, 0] call ALIVE_fnc_OOsimpleOperation;
ASSERT_TRUE(typeName _result == "SCALAR", typeName _result);
ASSERT_TRUE(_result == 0, _result);

STAT("Test bad SCALAR value");
_result = [_logic, "priority", "xxx", 0] call ALIVE_fnc_OOsimpleOperation;
ASSERT_TRUE(typeName _result == "SCALAR", typeName _result);
ASSERT_TRUE(_result == 0, _result);

STAT("Test good SCALAR value");
_result = [_logic, "priority", 99, 0] call ALIVE_fnc_OOsimpleOperation;
ASSERT_TRUE(typeName _result == "SCALAR", typeName _result);
ASSERT_TRUE(_result == 99, _result);

STAT("Sleeping before destroy");
sleep 3;

if(isServer) then {
	STAT("Destroy old instance");
	[_logic, "destroy"] call ALIVE_fnc_baseClass;
	TEST_LOGIC2 = nil;
	publicVariable "TEST_LOGIC2";
} else {
	STAT("Confirm destroy instance 2");
	waitUntil{isNull TEST_LOGIC2};
};

nil;
