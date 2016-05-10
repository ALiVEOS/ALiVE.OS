#include <\x\alive\addons\main\script_component.hpp>

#define TESTS ["baseClass","OOsimpleOperation","RequireALiVE"]

SCRIPT(test-main);

// ----------------------------------------------------------------------------

LOG("=== Testing BaseClass ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\main\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
