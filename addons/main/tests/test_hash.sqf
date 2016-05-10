// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_hash);

// ----------------------------------------------------------------------------

LOG("Testing Hash");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_hashCreate","ALIVE_fnc_hashCreate is not defined!");
ASSERT_DEFINED("ALIVE_fnc_hashGet","ALIVE_fnc_hashGet is not defined!");
ASSERT_DEFINED("ALIVE_fnc_hashSet","ALIVE_fnc_hashSet is not defined!");
ASSERT_DEFINED("ALIVE_fnc_hashRem","ALIVE_fnc_hashRemove is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

private ["_expected","_returned","_hash","_value"];

STAT("Test Create Hash");
_expected = [];
_hash = call ALIVE_fnc_hashCreate;
_returned = [typeName _expected, typeName _hash] call BIS_fnc_areEqual;
ASSERT_TRUE(_returned,typeOf _expected + " != " + typeOf _hash);


STAT("Test Set Hash Key");
_expected = [];
_hash = [_hash,"key","value"] call ALIVE_fnc_hashSet;
_returned = [typeName _expected, typeName _hash] call BIS_fnc_areEqual;
ASSERT_TRUE(_returned,typeOf _expected + " != " + typeOf _hash);


STAT("Test Get Hash Key");
_expected = "";
_value = [_hash,"key"] call ALIVE_fnc_hashGet;
_returned = [typeName _expected, typeName _value] call BIS_fnc_areEqual;
ASSERT_TRUE(_returned,typeOf _expected + " != " + typeOf _value);


STAT("Test Get Hash Key with Default Value");
_expected = "";
_value = [_hash,"key1","value1"] call ALIVE_fnc_hashGet;
_returned = [typeName _expected, typeName _value] call BIS_fnc_areEqual;
ASSERT_TRUE(_returned,typeOf _expected + " != " + typeOf _value);


STAT("Test Remove Hash Key");
_expected = [];
_hash = [_hash,"key"] call ALIVE_fnc_hashRem;
_returned = [typeName _expected, typeName _hash] call BIS_fnc_areEqual;
ASSERT_TRUE(_returned,typeOf _expected + " != " + typeOf _hash);

nil;