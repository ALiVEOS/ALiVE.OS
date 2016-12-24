// ----------------------------------------------------------------------------

#include <\x\alive\addons\mil_ato\script_component.hpp>
SCRIPT(test_ATO);

//execVM "\x\alive\addons\mil_ato\tests\test_ATO.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo","_position","_faction","_side","_forceMakeup","_event","_eventID"];

LOG("Testing ATO");

ASSERT_DEFINED("ALIVE_fnc_ATO","");

#define STAT(msg) sleep 0.5; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_ATO; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_ATO; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

//========================================

STAT("Create ATO event");

// Pick OPCOM objective to recce

// Create enemy aircraft in airspace
private _type = "RECCE";
private _range = distance _position;
private _args = [
    "WHITE",                // ROE
    DEFAULT_OP_HEIGHT,
    DEFAULT_SPEED,
    DEFAULT_MIN_WEAP_STATE,
    DEFAULT_MIN_FUEL_STATE,
    _range,       // RADIUS
    DEFAULT_OP_DURATION,
    []                      // TARGETS
];
private _event = ['ATO_REQUEST', [_type, _side, _faction, _x, _args],"ATO"] call ALIVE_fnc_event;
private _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;





nil;