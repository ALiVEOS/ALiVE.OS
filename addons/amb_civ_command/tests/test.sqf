#include <\x\alive\addons\amb_civ_command\script_component.hpp>

#define TESTS ["civCommandRouter"];

SCRIPT(test-commandRouter);

// ----------------------------------------------------------------------------

LOG("=== Testing Amb Civ Command Router ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\amb_civ_command\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
