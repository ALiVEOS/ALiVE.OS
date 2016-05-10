#include <\x\alive\addons\mil_placement\script_component.hpp>

#define TESTS ["MP","clusterGeneration","clusterVisualisation"]

SCRIPT(test-placement);

// ----------------------------------------------------------------------------

LOG("=== Testing Mil Placement ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\mil_placement\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
