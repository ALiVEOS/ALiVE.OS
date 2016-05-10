#include <\x\alive\addons\amb_civ_population\script_component.hpp>

#define TESTS ["civilianAgent"];

SCRIPT(test-civ-population);

//execVM "\x\alive\addons\amb_civ_population\tests\test.sqf"

// ----------------------------------------------------------------------------

LOG("=== Testing Ambient Civilian Population ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\amb_civ_population\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
