#include <\x\alive\addons\mil_intelligence\script_component.hpp>

#define TESTS ["MI"]

SCRIPT(test-placement);

// ----------------------------------------------------------------------------

LOG("=== Testing Mil Intelligence ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\mil_intelligence\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
