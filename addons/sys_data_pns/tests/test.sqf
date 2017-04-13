#include <\x\alive\addons\sys_data_pns\script_component.hpp>

#define TESTS ["convertData","parseJSON"]; //,"restoreData","readData","writeData","updateData"

SCRIPT(test-pns);

// ----------------------------------------------------------------------------

LOG("=== Testing Analysis ===");

{
    call compile preprocessFileLineNumbers format ["\x\alive\addons\sys_data_pns\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
