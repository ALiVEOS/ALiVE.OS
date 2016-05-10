#include <\x\alive\addons\mil_CQB\script_component.hpp>

#define TESTS ["CQB"];

SCRIPT(test);

//execVM "\x\alive\addons\mil_CQB\tests\test.sqf"

// ----------------------------------------------------------------------------

LOG("=== Testing CQB ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\mil_CQB\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
