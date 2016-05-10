// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_hashIndex);

//execVM "\x\alive\addons\sys_profile\tests\test_hashIndex.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_profile"];

LOG("Testing Profile Object");

ASSERT_DEFINED("ALIVE_fnc_profile","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_profile; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_profile; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
diag_log format["Timer End %1",_timeEnd];

//========================================

_hashSize = 10000;
_testCount = 1000;


_testHashString = [] call ALIVE_fnc_hashCreate;

for "_i" from 0 to _hashSize do {
    _testValue = [_i,"a",2,"c",3];
    [_testHashString, format["string%1",_i], _testValue] call ALIVE_fnc_hashSet;
};


_testHashNumeric = [] call ALIVE_fnc_hashCreate;

for "_i" from 0 to _hashSize do {
    _testValue = [_i,"a",2,"c",3];
    [_testHashNumeric, _i, _testValue] call ALIVE_fnc_hashSet;
};


["Format offset"] call ALIVE_fnc_dump;
[true] call ALIVE_fnc_timer;
for "_i" from 0 to _testCount do {
    _value = format["string%1",_i];
};
[] call ALIVE_fnc_timer;


["Get by string index"] call ALIVE_fnc_dump;
[true] call ALIVE_fnc_timer;
for "_i" from 0 to _testCount do {
    _value = [_testHashString, format["string%1",_i]] call ALIVE_fnc_hashGet;
};
[] call ALIVE_fnc_timer;


["Get by number index"] call ALIVE_fnc_dump;
[true] call ALIVE_fnc_timer;
for "_i" from 0 to _testCount do {
    _value = [_testHashNumeric, _i] call ALIVE_fnc_hashGet;
};
[] call ALIVE_fnc_timer;


nil;