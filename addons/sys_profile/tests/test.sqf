#include <\x\alive\addons\sys_profile\script_component.hpp>

#define TESTS ["profile","profileEntity","profileVehicle","profileHandler","getNearProfiles","profileWaypoint","vehicleAssignment","createUnitsFromMap","vehicleAssignmentsReal","profileVehicleAssignments","configGroupToProfile","groupConfigBestPlacesSpawn","UAVProfiles"];

SCRIPT(test-profile);

//execVM "\x\alive\addons\sys_profile\tests\test.sqf"

// ----------------------------------------------------------------------------

LOG("=== Testing Profile ===");

{
	call compile preprocessFileLineNumbers format ["\x\alive\addons\sys_profile\tests\test_%1.sqf", _x];
} forEach TESTS;

nil;
