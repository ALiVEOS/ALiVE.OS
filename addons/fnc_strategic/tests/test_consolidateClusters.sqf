// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(test_consolidateClusters);

// ----------------------------------------------------------------------------

private ["_result","_err","_obj_array","_m","_amo","_logic","_master","_redundant","_nodes"];

LOG("Testing Consolidate Clusters");

ASSERT_DEFINED("ALIVE_fnc_cluster","");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define CREATE_TEST_LOGIC if(isServer) then { \
	_logic = [nil, "create"] call ALIVE_fnc_cluster; \
	TEST_LOGIC = _logic; \
	publicVariable "TEST_LOGIC"; \
}; \
waitUntil{!isNil "TEST_LOGIC"}; \
[TEST_LOGIC, "debug", true] call ALIVE_fnc_cluster;

#define CREATE_TEST_LOGIC2 if(isServer) then { \
	_logic = [nil, "create"] call ALIVE_fnc_cluster; \
	TEST_LOGIC2 = _logic; \
	publicVariable "TEST_LOGIC2"; \
}; \
waitUntil{!isNil "TEST_LOGIC2"}; \
[TEST_LOGIC2, "debug", true] call ALIVE_fnc_cluster;

#define CREATE_TEST_LOGIC3 if(isServer) then { \
	_logic = [nil, "create"] call ALIVE_fnc_cluster; \
	TEST_LOGIC3 = _logic; \
	publicVariable "TEST_LOGIC3"; \
}; \
waitUntil{!isNil "TEST_LOGIC3"}; \
[TEST_LOGIC3, "debug", true] call ALIVE_fnc_cluster;

#define DELETE_TEST_LOGIC if(isServer) then { \
	[TEST_LOGIC, "destroy"] call ALIVE_fnc_cluster; \
	TEST_LOGIC = nil; \
	publicVariable "TEST_LOGIC"; \
} else { \
	STAT("Confirm destroy instance"); \
	waitUntil{isNull TEST_LOGIC}; \
};

#define DELETE_TEST_LOGIC2 if(isServer) then { \
	[TEST_LOGIC2, "destroy"] call ALIVE_fnc_cluster; \
	TEST_LOGIC2 = nil; \
	publicVariable "TEST_LOGIC2"; \
} else { \
	STAT("Confirm destroy instance"); \
	waitUntil{isNull TEST_LOGIC2}; \
};

#define DELETE_TEST_LOGIC3 if(isServer) then { \
	[TEST_LOGIC3, "destroy"] call ALIVE_fnc_cluster; \
	TEST_LOGIC3 = nil; \
	publicVariable "TEST_LOGIC3"; \
} else { \
	STAT("Confirm destroy instance"); \
	waitUntil{isNull TEST_LOGIC3}; \
};

_amo = allMissionObjects "";

STAT("Create mock objects");
_obj_array = [];
createCenter sideLogic;
{
	_obj_array set [count _obj_array, (createGroup sideLogic) createUnit ["LOGIC", (player modelToWorld _x), [], 0, "NONE"]];
} forEach [
	[-300,100],
	[-200,300],
	[-100,400],
	[0,500],
	[100,700],
	[200,500]
];
_err = "create mock objects";
ASSERT_DEFINED("_obj_array",_err);
ASSERT_TRUE(typeName _obj_array == "ARRAY", _err);
ASSERT_TRUE(count _obj_array == 6,_err);
{
        _m = createMarker [str _x, getPosATL _x];
        _m setMarkerShape "Icon";
        _m setMarkerSize [1, 1];
        _m setMarkerType "mil_dot";
} forEach _obj_array;

STAT("Create Seperated Clusters");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 2
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 3,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC],[TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 3,_err);
_redundant = TEST_LOGIC2;
ASSERT_TRUE(typeName _redundant == "ARRAY", typeName _redundant);
_nodes = [_redundant,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 3,_err);
STAT("Deleting logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Create Seperated Clusters 2");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 2
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 3,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC,TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 2,str _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 3,str _nodes);
_master = _result select 1;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 3,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Create Seperated Clusters 3");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
CREATE_TEST_LOGIC3
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 2
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 2,
	_obj_array select 3,
	_obj_array select 4
]] call ALIVE_fnc_cluster;
[TEST_LOGIC3, "nodes", [
	_obj_array select 3,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC,TEST_LOGIC2],[TEST_LOGIC3]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 1,str _result);
_master = _result select 0;
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2
DELETE_TEST_LOGIC3

STAT("Create Seperated Clusters 3");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
CREATE_TEST_LOGIC3
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 2
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 2,
	_obj_array select 3,
	_obj_array select 4
]] call ALIVE_fnc_cluster;
[TEST_LOGIC3, "nodes", [
	_obj_array select 3,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC,TEST_LOGIC2],[TEST_LOGIC3]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2
DELETE_TEST_LOGIC3

STAT("Create Engulfed Clusters");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 1,
	_obj_array select 2,
	_obj_array select 3
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC],[TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 1,str _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
_nodes = [TEST_LOGIC2,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 0,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Create Engulfed Clusters 2");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 1,
	_obj_array select 2,
	_obj_array select 3
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC,TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 1,str _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
_nodes = [TEST_LOGIC2,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 0,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Create Partial Overlapped Clusters");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 3
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 2,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC],[TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 1,str _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
_nodes = [TEST_LOGIC2,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 0,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Create Partial Overlapped Clusters 2");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 3
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 2,
	_obj_array select 4,
	_obj_array select 5
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC,TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 1,str _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
_nodes = [TEST_LOGIC2,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 0,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Create Majority Overlapped Clusters");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 5
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 2,
	_obj_array select 3,
	_obj_array select 4
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC],[TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 1,str _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
_nodes = [TEST_LOGIC2,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 0,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Create Majority Overlapped Clusters 2");
CREATE_TEST_LOGIC
CREATE_TEST_LOGIC2
[TEST_LOGIC, "nodes", [
	_obj_array select 0,
	_obj_array select 1,
	_obj_array select 5
]] call ALIVE_fnc_cluster;
[TEST_LOGIC2, "nodes", [
	_obj_array select 2,
	_obj_array select 3,
	_obj_array select 4
]] call ALIVE_fnc_cluster;

STAT("ConsolidateClusters function");
_result = [[TEST_LOGIC,TEST_LOGIC2]] call ALIVE_fnc_consolidateClusters;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _result == "ARRAY", typeName _result);
ASSERT_TRUE(count _result == 1,str _result);
_master = _result select 0;
ASSERT_TRUE(typeName _master == "ARRAY", typeName _master);
_nodes = [_master,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 6,str _nodes);
_nodes = [TEST_LOGIC2,"nodes"] call ALIVE_fnc_cluster;
ASSERT_TRUE(count _nodes == 0,str _nodes);
STAT("Deleting Logics");
DELETE_TEST_LOGIC
DELETE_TEST_LOGIC2

STAT("Clean up markers");
{
	deleteMarker str _x;
	deleteVehicle _x;
} forEach _obj_array;

diag_log (allMissionObjects "") - _amo;

nil;
