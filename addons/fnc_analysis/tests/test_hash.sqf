// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_logic);

// ----------------------------------------------------------------------------

private ["_err","_logic","_amo"];

LOG("Testing Hash");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
diag_log format["Timer End %1",_timeEnd];

//========================================

_testIterations = 1000;
diag_log format["TEST ITERATIONS: %1", _testIterations];


STAT("CREATE CBA HASH");
TIMERSTART
_hash = call ALIVE_fnc_hashCreate;
TIMEREND

STAT("POPULATE HASH");
_value = ["one","two","three","four","five","six","seven","eight","nine","ten"];
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_hash, format["KEY%1",_i], _value] call ALIVE_fnc_hashSet;
};
TIMEREND

STAT("GET FROM HASH");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_hash, format["KEY%1",_i]] call ALIVE_fnc_hashGet;
};
TIMEREND

STAT("UPDATE HASH");
_value = ["one","two","three","four","five","six","seven","eight","nine","ten"];
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_hash, format["KEY%1",_i], _value] call ALIVE_fnc_hashSet;
};
TIMEREND

STAT("REMOVE FROM HASH");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_hash, format["KEY%1",_i]] call ALIVE_fnc_hashRem;
};
TIMEREND


diag_log _hash;


STAT("CREATE DICTIONARY");
TIMERSTART
_dictionary = call Dictionary_fnc_new;
TIMEREND

STAT("POPULATE DICTIONARY");
_value = ["one","two","three","four","five","six","seven","eight","nine","ten"];
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_dictionary, format["KEY%1",_i], _value] call Dictionary_fnc_set;
};
TIMEREND

STAT("GET FROM DICTIONARY");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_dictionary, format["KEY%1",_i]] call Dictionary_fnc_get;
};
TIMEREND

STAT("UPDATE DICTIONARY");
_value = ["one","two","three","four","five","six","seven","eight","nine","ten"];
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_dictionary, format["KEY%1",_i], _value] call Dictionary_fnc_set;
};
TIMEREND

STAT("REMOVE FROM DICTIONARY");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_result = [_dictionary, format["KEY%1",_i]] call Dictionary_fnc_remove;
};
TIMEREND


diag_log _dictionary;


nil;