#include <\x\alive\addons\mil_command\script_component.hpp>

#define TESTS ["commandRouter"];

SCRIPT(test-commandRouter);

// ----------------------------------------------------------------------------

LOG("=== Testing Mil Command Router ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\mil_command\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
