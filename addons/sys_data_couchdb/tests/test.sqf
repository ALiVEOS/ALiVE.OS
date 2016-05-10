#include <\x\alive\addons\sys_data_couchdb\script_component.hpp>

#define TESTS ["convertData","parseJSON"]; //,"restoreData","readData","writeData","updateData"

SCRIPT(test-couchdb);

// ----------------------------------------------------------------------------

LOG("=== Testing Analysis ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\sys_data_couchdb\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
