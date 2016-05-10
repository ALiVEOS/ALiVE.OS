// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(test_clusters);

// ----------------------------------------------------------------------------

private ["_result","_expected","_err","_obj_array","_point","_center","_clusters","_m","_amo"];

LOG("Testing Clusters");

ASSERT_DEFINED("ALIVE_fnc_getObjectsByType","");
ASSERT_DEFINED("ALIVE_fnc_getNearestObjectInArray","");
ASSERT_DEFINED("ALIVE_fnc_findClusterCenter","");
ASSERT_DEFINED("ALIVE_fnc_findClusters","");
ASSERT_DEFINED("ALIVE_fnc_consolidateClusters","");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

_amo = allMissionObjects "";

STAT("Create mock objects");
_obj_array = [];
createCenter sideLogic;
{
	_obj_array set [count _obj_array, (createGroup sideLogic) createUnit ["LOGIC", (player modelToWorld _x), [], 0, "NONE"]];
} forEach [
	[-1200,-900],
	[-900,-600],
	[-600,-900],
	[300,0],
	[300,1200],
	[600,900],
	[900,600],
	[900,400],
	[400,1100],
	[500,800],
	[800,500],
	[1000,400]
];
_err = "create mock objects";
ASSERT_DEFINED("_obj_array",_err);
ASSERT_TRUE(typeName _obj_array == "ARRAY", _err);
ASSERT_TRUE(count _obj_array == 12,_err);
{
        _m = createMarker [str _x, getPosATL _x];
        _m setMarkerShape "Icon";
        _m setMarkerSize [1, 1];
        _m setMarkerType "mil_dot";
} forEach _obj_array;

STAT("Test finding nearest object from cluster");
_point = _obj_array select 0;
_result = [_point, _obj_array] call ALIVE_fnc_getNearestObjectInArray;
_expected = _obj_array select 1;
_err = "getNearestObjectInArray #1";
ASSERT_TRUE(_result == _expected, _err);
(str _point) setMarkerColor "ColorBlue";
(str _result) setMarkerColor "ColorBlue";
[_result, _point] call ALIVE_fnc_createLink;

STAT("Finding nearest object #2 from cluster");
_point = _obj_array select 6;
_result = [_point, _obj_array] call ALIVE_fnc_getNearestObjectInArray;
_expected = _obj_array select 10;
_err = "getNearestObjectInArray #2";
ASSERT_TRUE(_result == _expected, _err);
(str _point) setMarkerColor "ColorBlue";
(str _result) setMarkerColor "ColorBlue";
[_result, _point] call ALIVE_fnc_createLink;

STAT("Reject nearest object #3 as too far awy");
_point = _obj_array select 8;
_result = [_point, _obj_array, 50] call ALIVE_fnc_getNearestObjectInArray;
_expected = _obj_array select 8;
_err = "getNearestObjectInArray #3";
ASSERT_TRUE(_result == _expected, _err);
(str _point) setMarkerColor "ColorBlue";

STAT("Test finding centre of cluster of objects");
_center = [_obj_array] call ALIVE_fnc_findClusterCenter;
_err = "cluster center";
ASSERT_DEFINED("_center",_err);
ASSERT_TRUE(typeName _center == "ARRAY", _err);
ASSERT_TRUE(count _center == 2,_err);
_m = createMarker [str _center, _center];
_m setMarkerShape "Icon";
_m setMarkerSize [1, 1];
_m setMarkerType "mil_dot";
_m setMarkerColor "ColorOrange";
_m setMarkerText "Cluster Center";

STAT("FindClusters function");
_clusters = [_obj_array] call ALIVE_fnc_findClusters;
_err = "finding clusters";
ASSERT_TRUE(typeName _clusters == "ARRAY", _err);
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _clusters;
STAT("FindClusters completed");
sleep 5;

STAT("ConsolidateClusters function");
[_clusters select 3, "addNode", _obj_array select 8] call ALIVE_fnc_cluster;
_result = [_clusters] call ALIVE_fnc_consolidateClusters;
_clusters = _result;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _clusters == "ARRAY", _err);
STAT("ConsolidateClusters completed");
sleep 5;

{
	[_x, "destroy"] call ALIVE_fnc_cluster;
} forEach _clusters;

STAT("Clean up markers");
[_obj_array select 1, _obj_array select 0] call ALIVE_fnc_deleteLink;
[_obj_array select 10, _obj_array select 6] call ALIVE_fnc_deleteLink;
deleteMarker str _center;
{
	deleteMarker str _x;
	deleteVehicle _x;
} forEach _obj_array;

diag_log (allMissionObjects "") - _amo;

nil;
