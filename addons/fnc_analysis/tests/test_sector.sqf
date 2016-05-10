// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_sector);

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2","_m","_markers","_worldMarkers"];

LOG("Testing Sector Object");

ASSERT_DEFINED("ALIVE_fnc_sector","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_sector; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_sector; \
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

_logic = nil;

STAT("Create Sector instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_sector;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};


STAT("Init Sector");
_result = [_logic, "init"] call ALIVE_fnc_sector;
_err = "set init";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Confirm new Sector instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "ARRAY", _err);


STAT("Set dimensions");
_result = [_logic, "dimensions", [50,50]] call ALIVE_fnc_sector;
_err = "set dimensions";
ASSERT_TRUE(typeName _result == "ARRAY", _err);
waitUntil{count ([_logic, "dimensions"] call ALIVE_fnc_sector) == 2};


STAT("Set position");
_result = [_logic, "position", getPos player] call ALIVE_fnc_sector;
_err = "set position";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Set id");
_result = [_logic, "id", "Sector Id"] call ALIVE_fnc_sector;
_err = "set id";
ASSERT_TRUE(typeName _result == "STRING", _err);


DEBUGON


STAT("Get Sector Center");
_result = [_logic, "center"] call ALIVE_fnc_sector;
_err = "Get center";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Get Sector Bounds");
_result = [_logic, "bounds"] call ALIVE_fnc_sector;
_err = "Get bounds";
ASSERT_TRUE(typeName _result == "ARRAY", _err);

_markers = [];
_worldMarkers = [];

STAT("Spawn debug markers");
{
	_m = [_x] call ALIVE_fnc_spawnDebugMarker;
	_worldMarkers set [count _worldMarkers, _m];
} forEach _result;

_count = 0;
{
	_m = createMarkerLocal [format["FOO%1", _count], _x];
	_m setMarkerShapeLocal "ICON";
	_m setMarkerSizeLocal [1, 1];
	_m setMarkerTypeLocal "mil_dot";
	_m setMarkerColorLocal ([_logic,"debugColor"] call ALIVE_fnc_hashGet);
	_count = _count + 1;
	
	_markers set [count _markers, _m];
} forEach _result;



STAT("Get Within Sector");
_result = [_logic, "within", getPos player] call ALIVE_fnc_sector;
ASSERT_TRUE(typeName _result == "BOOL", _err);
diag_log format["Player within sector: %1",_result];


STAT("Save state");
_result = [_logic, "state"] call ALIVE_fnc_sector;
_err = "check state";
ASSERT_TRUE(typeName _result == "ARRAY", _err);
ASSERT_TRUE(count _result > 0, _err);
_state = _result;


STAT("Reset debug");

{
	deleteMarkerLocal _x;
} forEach _markers;

{
	deleteVehicle _x;
} forEach _worldMarkers;


DEBUGOFF
sleep 5;
DEBUGON


STAT("Sleeping before destroy");
sleep 10;


STAT("Destroy old Sector instance");
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_sector;
	TEST_LOGIC = nil;
	publicVariable "TEST_LOGIC";
} else {
	waitUntil{isNull TEST_LOGIC};
};


STAT("Create Sector instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_sector;
	TEST_LOGIC2 = _logic;
	publicVariable "TEST_LOGIC2";
};


STAT("Confirm new Sector instance 2");
waitUntil{!isNil "TEST_LOGIC2"};
_logic = TEST_LOGIC2;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "ARRAY", _err);


STAT("Restore state on new instance");
if(isServer) then {
	_result = [_logic, "state", _state] call ALIVE_fnc_sector;
};


STAT("Confirm restored state is still the same");
_result = [_logic, "state"] call ALIVE_fnc_sector;
_err = "confirming restored state";
ASSERT_TRUE(typeName _result == "ARRAY", _err);
ASSERT_TRUE(count _result > 0, _err);
_result2 = [_state, _result] call BIS_fnc_areEqual;
ASSERT_TRUE(_result2,_err);


DEBUGON


STAT("Sleeping before destroy");
sleep 10;


if(isServer) then {
	STAT("Destroy old instance");
	[_logic, "destroy"] call ALIVE_fnc_sector;
	TEST_LOGIC2 = nil;
	publicVariable "TEST_LOGIC2";
} else {
	STAT("Confirm destroy instance 2");
	waitUntil{isNull TEST_LOGIC2};
};

sleep 5;

nil;