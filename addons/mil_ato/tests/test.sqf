#include "\x\alive\addons\mil_ato\script_component.hpp"

#define TESTS ["ATO_OCA","ATO_RECCE","ATO_SEAD_STRIKE_CAS"]

SCRIPT(test);

// ----------------------------------------------------------------------------

LOG("=== Testing Mil air tasking orders ===");

{
    call compile preprocessFileLineNumbers format ["\x\alive\addons\mil_ato\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
