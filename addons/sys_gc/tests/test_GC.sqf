// ----------------------------------------------------------------------------
#include "\x\alive\addons\sys_GC\script_component.hpp"
SCRIPT(test_GC);
// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo"];

LOG("Testing Garbage Collector");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_GC","ALIVE_fnc_GC is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

STAT("Test GC 1 starting...");

_amo = +(allMissionObjects "");

STAT("Create Garbage Collector instance");
_err = "Creating instance failed";
if(isServer) then {
    TEST_LOGIC = [nil, "create"] call ALIVE_fnc_GC;
    ASSERT_DEFINED("TEST_LOGIC",_err);

    publicVariable "TEST_LOGIC";
};

_logic = TEST_LOGIC;

STAT("Confirm new instance on all localities");
_err = "Instantiating object failed";
waitUntil {!(isNil "TEST_LOGIC")};

STAT("Sleeping before destroy");
sleep 10;

STAT("Destroy Garbage Collector instance");
_err = "Destruction of old instance failed...";
if(isServer) then {
    [_logic, "destroy"] call ALIVE_fnc_GC;
    TEST_LOGIC = nil;
} else {
    waitUntil {isNull TEST_LOGIC};
};
ASSERT_TRUE(isnil "TEST_LOGIC", _err);

diag_log (count ((allMissionObjects "") - _amo));

STAT("Test GC 1 finished...");

// ---------------------------------------------------------------------------
// Test GC 2: queue drain round trip through the unscheduled tick.
// The tick is invoked manually, so the test is deterministic and does not
// depend on frame timing or the collection interval.
// ---------------------------------------------------------------------------

STAT("Test GC 2 starting...");

STAT("Create Garbage Collector instance for drain test");
if(isServer) then {
    TEST_LOGIC2 = [nil, "create"] call ALIVE_fnc_GC;
    publicVariable "TEST_LOGIC2";
};
waitUntil {!(isNil "TEST_LOGIC2")};
_logic = TEST_LOGIC2;

STAT("Spawning dead objects away from player");
_bodies = [];
for "_i" from 0 to 9 do {
    _body = "C_man_1" createVehicle ((position player) getPos [2500, _i * 36]);
    _body setDamage 1;
    _bodies pushBack _body;
};
sleep 1;

STAT("Queueing dead objects via trashIt");
{ [_logic,"trashIt",_x] call ALIVE_fnc_GC; } forEach _bodies;

_queued = count (_logic getVariable ["queue",[]]);
ASSERT_TRUE(_queued >= 10, "trashIt failed to enqueue objects");

STAT("Expiring entries and driving the tick manually");
{ _x setVariable ["timeToDie", 0]; } forEach _bodies;
for "_i" from 0 to 19 do { [_logic, "tick"] call ALIVE_fnc_GC; };

_remaining = { !(isNull _x) } count _bodies;
ASSERT_TRUE(_remaining == 0, format ["GC tick failed to delete bodies, %1 remain", _remaining]);
ASSERT_TRUE((count (_logic getVariable ["queue",[]])) == 0, "GC tick left stale entries in the queue");

STAT("Instant mode deletes unexpired objects near player");
_logic setVariable ["gcThreshold", 0];
_nearBody = "C_man_1" createVehicle (position player);
_nearBody setDamage 1;
[_logic,"trashIt",_nearBody] call ALIVE_fnc_GC;
[_logic, "tick"] call ALIVE_fnc_GC;

ASSERT_TRUE(isNull _nearBody, "Instant mode failed to delete object near player");

STAT("Destroy drain test instance");
if(isServer) then {
    [_logic, "destroy"] call ALIVE_fnc_GC;
    TEST_LOGIC2 = nil;
};

STAT("Test GC 2 finished...");