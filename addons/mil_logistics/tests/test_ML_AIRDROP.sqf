// ----------------------------------------------------------------------------

#include <\x\alive\addons\mil_logistics\script_component.hpp>
SCRIPT(test_ML_AIRDROP);

//execVM "\x\alive\addons\mil_logistics\tests\test_ML_AIRDROP.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo","_position","_faction","_side","_forceMakeup","_event","_eventID"];

LOG("Testing ML");

ASSERT_DEFINED("ALIVE_fnc_ML","");

#define STAT(msg) sleep 0.5; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_ML; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_ML; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

//========================================

STAT("Create OPCOM reinforcement event");

_position = [getPos player, 20, 180] call BIS_fnc_relPos;

_faction = "BLU_F";
_side = "WEST";

/*
_forceMakeup = [
    floor(random(5)), // infantry
    floor(random(5)), // motorised
    floor(random(5)), // mechanised
    floor(random(5)), // armour
    floor(random(2)), // plane
    floor(random(2))  // heli
];
*/

_forceMakeup = [
    3, // infantry
    0, // motorised
    0, // mechanised
    0, // armour
    0, // plane
    0  // heli
];

/*
_forceMakeup = [
    3, // infantry
    3, // motorised
    4, // mechanised
    2, // armour
    2, // plane
    2  // heli
];
*/

_event = ['LOGCOM_REQUEST', [_position,_faction,_side,_forceMakeup,"AIRDROP"],"OPCOM"] call ALIVE_fnc_event;
_eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

nil;