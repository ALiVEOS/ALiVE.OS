// ----------------------------------------------------------------------------

#include <\x\alive\addons\mil_ato\script_component.hpp>
SCRIPT(test_ATO_HELI_INSERT);

//execVM "\x\alive\addons\mil_ato\tests\test_ATO_SEAD_STRIKE_CAS.sqf"

#define DEFAULT_OP_HEIGHT 750
#define DEFAULT_OP_DURATION 25
#define DEFAULT_SPEED "NORMAL"
#define DEFAULT_MIN_WEAP_STATE 0.5
#define DEFAULT_MIN_FUEL_STATE 0.5
#define DEFAULT_RADAR_HEIGHT 100

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

STAT("Create ATO events: CAS, SEAD, Strike, Recce");

private _side = WEST;
private _faction = "BLU_F";

_type = "CAS";
_range = 2000;
_args = [
    "RED",                // ROE
    500,
    "FULL",
    DEFAULT_MIN_WEAP_STATE,
    DEFAULT_MIN_FUEL_STATE,
    _range,       // RADIUS
    DEFAULT_OP_DURATION,
    ["OPF_F-vehicle_36"]                      // TARGETS
];
_event = ['ATO_REQUEST', [_type, _side, _faction, "", _args],"ATO"] call ALIVE_fnc_event;
_eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

sleep 15;

/*
_type = "SEAD";
_range = 2000;
_args = [
    "RED",                // ROE
    100,
    "FULL",
    DEFAULT_MIN_WEAP_STATE,
    DEFAULT_MIN_FUEL_STATE,
    _range,       // RADIUS
    DEFAULT_OP_DURATION,
    ["BLU_F-entity_74"]                      // TARGETS
];
_event = ['ATO_REQUEST', [_type, _side, _faction, "", _args],"ATO"] call ALIVE_fnc_event;
_eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

sleep 60;
*/

// Request in opposite priority order to test queue ordering
private _type = "Strike";
private _range = 2000;
private _args = [
    "RED",                // ROE
    DEFAULT_OP_HEIGHT,
    "FULL",
    DEFAULT_MIN_WEAP_STATE,
    DEFAULT_MIN_FUEL_STATE,
    _range,       // RADIUS
    DEFAULT_OP_DURATION,
    ["OPF_F-vehicle_36"]                      // TARGETS
];
private _event = ['ATO_REQUEST', [_type, _side, _faction, "", _args],"OPCOM"] call ALIVE_fnc_event;
private _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

sleep 15;

private _type = "Recce";
private _range = 2000;
private _args = [
    "WHITE",                // ROE
    DEFAULT_OP_HEIGHT,
    DEFAULT_SPEED,
    DEFAULT_MIN_WEAP_STATE,
    DEFAULT_MIN_FUEL_STATE,
    _range,       // RADIUS
    DEFAULT_OP_DURATION,
    ["OPF_F-vehicle_36"]                      // TARGETS
];
private _event = ['ATO_REQUEST', [_type, _side, _faction, "", _args],"OPCOM"] call ALIVE_fnc_event;
private _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

nil;

