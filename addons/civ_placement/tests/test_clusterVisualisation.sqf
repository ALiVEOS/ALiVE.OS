// ----------------------------------------------------------------------------

#include <\x\alive\addons\civ_placement\script_component.hpp>
SCRIPT(test_clusterVisualisation);

//execVM "\x\alive\addons\civ_placement\tests\test_clusterVisualisation.sqf"

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

private ["_worldName","_file","_clusters","_HQClusters","_powerClusters","_commsClusters","_marineClusters","_railClusters","_fuelClusters","_constructionClusters"];
			
_worldName = toLower(worldName);			
_file = format["\x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];				
call compile preprocessFileLineNumbers _file;

waituntil {!(isnil "ALIVE_clustersCivHQ") && {!(isnil "ALIVE_clustersCivComms")}};



STAT("Debug Consolidated Civ Clusters");

_clusters = ALIVE_clustersCiv select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _clusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _clusters;



STAT("Debug HQ Civ Clusters");

_HQClusters = ALIVE_clustersCivHQ select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _HQClusters;	

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _HQClusters;



STAT("Debug Power Civ Clusters");

_powerClusters = ALIVE_clustersCivPower select 2;

{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _powerClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _powerClusters;



STAT("Debug Comms Civ Clusters");

_commsClusters = ALIVE_clustersCivComms select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _commsClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _commsClusters;



STAT("Debug Marine Civ Clusters");

_marineClusters = ALIVE_clustersCivMarine select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _marineClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _marineClusters;



STAT("Debug Rail Civ Clusters");

_railClusters = ALIVE_clustersCivRail select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _railClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _railClusters;



STAT("Debug Fuel Civ Clusters");

_fuelClusters = ALIVE_clustersCivFuel select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _fuelClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _fuelClusters;



STAT("Debug Construction Civ Clusters");

_constructionClusters = ALIVE_clustersCivConstruction select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _constructionClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _constructionClusters;



STAT("Debug Settlement Civ Clusters");

_settlementClusters = ALIVE_clustersCivSettlement select 2;
{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _settlementClusters;

STAT("Sleeping before destroy");
SLEEP 30;

{
	[_x, "debug", false] call ALIVE_fnc_cluster;
} forEach _settlementClusters;



["ALIVE CP - Count clusters %1",count _clusters] call ALIVE_fnc_dump;
["ALIVE CP - Count power clusters %1",count _powerClusters] call ALIVE_fnc_dump;
["ALIVE CP - Count comms clusters %1",count _commsClusters] call ALIVE_fnc_dump;
["ALIVE CP - Count marine clusters %1",count _marineClusters] call ALIVE_fnc_dump;		
["ALIVE CP - Count rail clusters %1",count _railClusters] call ALIVE_fnc_dump;		
["ALIVE CP - Count fuel clusters %1",count _fuelClusters] call ALIVE_fnc_dump;		
["ALIVE CP - Count construction clusters %1",count _constructionClusters] call ALIVE_fnc_dump;		
["ALIVE CP - Count settlement clusters %1",count _settlementClusters] call ALIVE_fnc_dump;


nil;