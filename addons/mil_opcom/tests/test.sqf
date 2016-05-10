#include <\x\alive\addons\mil_OPCOM\script_component.hpp>

#define TESTS ["OPCOM"];

SCRIPT(test);

//execVM "\x\alive\addons\mil_OPCOM\tests\test.sqf"

// ----------------------------------------------------------------------------

LOG("=== Testing Profile ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\mil_OPCOM\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
