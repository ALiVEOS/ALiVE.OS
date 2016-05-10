#include <\x\alive\addons\mil_logistics\script_component.hpp>

#define TESTS ["ML"]

SCRIPT(test-placement);

// ----------------------------------------------------------------------------

LOG("=== Testing Mil Logistics ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\mil_logistics\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
