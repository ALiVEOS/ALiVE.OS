// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_baseClass);

//execVM "\x\alive\addons\main\tests\test_anyPlayersInRangeExcludeAir.sqf"

// ----------------------------------------------------------------------------

private ["_result"];

LOG("Testing BaseClass");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_anyPlayersInRangeExcludeAir","ALIVE_fnc_anyPlayersInRangeExcludeAir is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]


_result = [getPos player, 1000] call ALiVE_fnc_anyPlayersInRange;

["Any in range: %1",_result] call ALIVE_fnc_dump;

_result = [getPos player, 1000] call ALiVE_fnc_anyPlayersInRangeExcludeAir;

["Any in range ex air: %1",_result] call ALIVE_fnc_dump;

nil;
