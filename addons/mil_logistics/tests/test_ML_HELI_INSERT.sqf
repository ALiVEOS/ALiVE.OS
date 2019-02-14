// ----------------------------------------------------------------------------

#include "\x\alive\addons\mil_logistics\script_component.hpp"
SCRIPT(test_ML_HELI_INSERT);

//execVM "\x\alive\addons\mil_logistics\tests\test_ML_HELI_INSERT.sqf"

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

if (!isNil "_this") then {
    _position = _this select 0;
    _faction = _this select 1;
    _side = _this select 2;
    _forceMakeup = _this select 3;

} else {;

    _position = ((getPos player) getPos [20, 180]);

    _faction = "OPF_F";
    _side = "EAST";

    _forceMakeup = [
        1, // infantry
        1, // motorised
        0, // mechanised
        0, // armour
        0, // plane
        1  // heli
    ];

};
_event = ['LOGCOM_REQUEST', [_position,_faction,_side,_forceMakeup,"STANDARD"],"OPCOM"] call ALIVE_fnc_event;
_eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

nil;
