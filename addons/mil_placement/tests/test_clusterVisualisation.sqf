// ----------------------------------------------------------------------------

#include <\x\alive\addons\mil_placement\script_component.hpp>
SCRIPT(test_clusterVisualisation);

//execVM "\x\alive\addons\mil_placement\tests\test_clusterVisualisation.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo","_state","_result2"];

LOG("Testing Cluster Generation");

ASSERT_DEFINED("ALIVE_fnc_CP","");

#define STAT(msg) sleep 0.5; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_MP; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_MP; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

//========================================

private ["_worldName","_file","_clusters","_HQClusters","_airClusters","_heliClusters","_vehicleClusters"];

			
_worldName = toLower(worldName);			
_file = format["\x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];				
call compile preprocessFileLineNumbers _file;


waituntil {!(isnil "ALIVE_clustersMilHQ") && {!(isnil "ALIVE_clustersMilAir")} && {!(isnil "ALIVE_clustersMilHeli")}};



STAT("Debug Consolidated Mil Clusters");

_clusters = ALIVE_clustersMil select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _clusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _clusters;



STAT("Debug HQ Mil Clusters");

_HQClusters = ALIVE_clustersMilHQ select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _HQClusters;	

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _HQClusters;



STAT("Debug Air Mil Clusters");

_airClusters = ALIVE_clustersMilAir select 2;

{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _airClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _airClusters;



STAT("Debug Heli Mil Clusters");

_heliClusters = ALIVE_clustersMilHeli select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _heliClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _heliClusters;



["ALIVE MP - Count clusters %1",count _clusters] call ALIVE_fnc_dump;
["ALIVE MP - Count air clusters %1",count _airClusters] call ALIVE_fnc_dump;
["ALIVE MP - Count heli clusters %1",count _heliClusters] call ALIVE_fnc_dump;		


nil;