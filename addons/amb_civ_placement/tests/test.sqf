#include <\x\alive\addons\amb_civ_placement\script_component.hpp>

#define TESTS ["AMB_CP"]

SCRIPT(test-strategic);

// ----------------------------------------------------------------------------

LOG("=== Testing Ambient Civ ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\civ_placement\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
