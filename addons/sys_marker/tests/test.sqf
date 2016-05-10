#include <\x\alive\addons\mil_marker\script_component.hpp>

#define TESTS ["Marker"];

SCRIPT(test);

//execVM "\x\alive\addons\mil_marker\tests\test.sqf"

// ----------------------------------------------------------------------------

LOG("=== Testing Profile ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\sys_marker\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
