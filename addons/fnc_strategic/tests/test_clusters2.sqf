// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(test_clusters2);

// ----------------------------------------------------------------------------

private ["_err","_obj_array","_center","_clusters","_m","_amo","_result"];


LOG("Testing Clusters 2");

ASSERT_DEFINED("ALIVE_fnc_getObjectsByType","");
ASSERT_DEFINED("ALIVE_fnc_findClusterCenter","");
ASSERT_DEFINED("ALIVE_fnc_findClusters","");
ASSERT_DEFINED("ALIVE_fnc_consolidateClusters","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

_amo = allMissionObjects "";

STAT("Get array of id's and positions from object index");
/*
	"cargo",
	"_tower",
	"runway_end",
	"runway_poj",
	"runway_dirt",
	"runway_main",
	"runway_beton",
	"runwayold",
	"helipad",
	"radar",
	"hangar",
	"shed_small_f"
*/
/*
	"dp_transformer_F",
	"HighVoltageTower",
	"PowerCable",
	"PowerPole",
	"PowerWire",
	"PowLines_Transformer_F",
	"spp_transformer_F"
*/
_obj_array = [
	"hbarrier",
	"razorwire",
	"mil_wired",
	"mil_wall",
	"barrack",
	"miloffices",
	"bunker"
] call ALIVE_fnc_getObjectsByType;
_err = "getObjectsByType";
ASSERT_DEFINED("_obj_array",_err);
ASSERT_TRUE(typeName _obj_array == "ARRAY", _err);
ASSERT_TRUE(count _obj_array > 0,_err);
{
	LOG(_x);
        _m = createMarker [str _x, getPosATL _x];
	_m setMarkerShape "Icon";
	_m setMarkerSize [1, 1];
	_m setMarkerType "mil_dot";
	_m setMarkerColor "ColorGreen";
} forEach _obj_array;

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

STAT("Test using the findClusters function");
_clusters = [_obj_array] call ALIVE_fnc_findClusters;
_err = "finding clusters";
ASSERT_TRUE(typeName _clusters == "ARRAY", _err);
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _clusters;

STAT("ConsolidateClusters function");
_result = [_clusters] call ALIVE_fnc_consolidateClusters;
_clusters = _result;
_err = "consolidating clusters";
ASSERT_TRUE(typeName _clusters == "ARRAY", _err);

STAT("ConsolidateClusters completed");
sleep 15;

{
	[_x, "destroy"] call ALIVE_fnc_cluster;
} forEach _clusters;

STAT("Clean up markers");
deleteMarker str _center;
{
	deleteMarker str _x;
	deleteVehicle _x;
} forEach _obj_array;

diag_log (allMissionObjects "") - _amo;

nil;
