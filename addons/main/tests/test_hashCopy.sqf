// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_hashCopy);

//execVM "\x\alive\addons\main\tests\test_hashCopy.sqf"

// ----------------------------------------------------------------------------

LOG("Testing Hash Copy");

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

private ["_testSubHash","_testSubSubHash","_testArray","_testHash","_copyHash"];

// test recursive hash copy function
_testSubHash = [] call ALIVE_fnc_hashCreate;
[_testSubHash, "ARJay", "ANDY"] call ALIVE_fnc_hashSet;
[_testSubHash, "Highhead", "DAVE"] call ALIVE_fnc_hashSet;
[_testSubHash, "Friz", "ALEX"] call ALIVE_fnc_hashSet;

_testSubSubHash = [] call ALIVE_fnc_hashCreate;
[_testSubSubHash, "Cheese", "Edam"] call ALIVE_fnc_hashSet;
[_testSubSubHash, "Wine", "Merlot"] call ALIVE_fnc_hashSet;

[_testSubHash, "Foods", _testSubSubHash] call ALIVE_fnc_hashSet;

_testArray = [];
_testArray set [count _testArray, 1];
_testArray set [count _testArray, 2];
_testArray set [count _testArray, 3];
_testArray set [count _testArray, 4];

_testHash = [] call ALIVE_fnc_hashCreate;
[_testHash, "one", "apple"] call ALIVE_fnc_hashSet;
[_testHash, "two", 2] call ALIVE_fnc_hashSet;
[_testHash, "three", _testArray] call ALIVE_fnc_hashSet;
[_testHash, "four", _testSubHash] call ALIVE_fnc_hashSet;
[_testHash, "five", _testSubSubHash] call ALIVE_fnc_hashSet;

_testHash call ALIVE_fnc_inspectHash;

_copyHash = [_testHash] call ALiVE_fnc_hashCopy;

[_testHash, "one", "orange"] call ALIVE_fnc_hashSet;
[_testSubHash, "ARJay", "ANDREW"] call ALIVE_fnc_hashSet;
[_testSubSubHash, "Cheese", "Gouda"] call ALIVE_fnc_hashSet;
_testArray set [0, 1000];

_testHash call ALIVE_fnc_inspectHash;

_copyHash call ALIVE_fnc_inspectHash;

nil;