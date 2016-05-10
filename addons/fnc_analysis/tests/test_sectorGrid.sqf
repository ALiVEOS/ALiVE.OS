// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_sectorGrid);

//execVM "\x\alive\addons\fnc_analysis\tests\test_sectorGrid.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_bounds","_grid","_sector"];

LOG("Testing Sector Grid Object");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_sectorGrid; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_sectorGrid; \
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


if(isNil "ALIVE_civilianHQBuildingTypes") then {
	_file = "\x\alive\addons\main\static\staticData.sqf";
	call compile preprocessFileLineNumbers _file;
};

_logic = nil;

STAT("Create SectorGrid instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_sectorGrid;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};


STAT("Init Grid");
_result = [_logic, "init"] call ALIVE_fnc_sectorGrid;
_err = "set initGrid";
ASSERT_TRUE(typeName _result == "BOOL", _err);


STAT("Confirm new SectorGrid instance");
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "ARRAY", _err);


STAT("Create Grid");
_grid = [_logic, "createGrid"] call ALIVE_fnc_sectorGrid;
_err = "set createGrid";
ASSERT_TRUE(typeName _grid == "ARRAY", _err);





DEBUGON


STAT("Position To Grid Index");
_result = [_logic, "positionToGridIndex", getPos player] call ALIVE_fnc_sectorGrid;
_err = "set positionToGridIndex";
ASSERT_TRUE(typeName _result == "ARRAY", _err);

diag_log format["Player position to sector: %1",_result];


STAT("Grid Index To Sector");
_result = [_logic, "gridIndexToSector", _result] call ALIVE_fnc_sectorGrid;
_err = "set gridIndexToSector";
ASSERT_TRUE(typeName _result == "ARRAY", _err);

_result = [_result, "debug", false] call ALIVE_fnc_sector;


STAT("Position To Sector");
_result = [_logic, "positionToSector", getPos player] call ALIVE_fnc_sectorGrid;
_err = "set positionToSector";
ASSERT_TRUE(typeName _result == "ARRAY", _err);

_result = [_result, "debug", true] call ALIVE_fnc_sector;


STAT("Surrounding Sectors");
_result = [_logic, "surroundingSectors", getPos player] call ALIVE_fnc_sectorGrid;
_err = "set surroundingSectors";
ASSERT_TRUE(typeName _result == "ARRAY", _err);

{
	if!(count _x == 0) then
	{
		_nil = [_x, "debug", false] call ALIVE_fnc_sector;
	}
	
} forEach _result;

sleep 5;

{
	if!(count _x == 0) then
	{
		_nil = [_x, "debug", true] call ALIVE_fnc_sector;
	}
} forEach _result;


STAT("Sectors in Radius");
_result = [_logic, "sectorsInRadius", [getPos player, 500]] call ALIVE_fnc_sectorGrid;
_err = "set sectorsInRadius";
ASSERT_TRUE(typeName _result == "ARRAY", _err);

{
	if!(count _x == 0) then
	{
		_nil = [_x, "debug", false] call ALIVE_fnc_sector;
	}
	
} forEach _result;

sleep 5;

{
	if!(count _x == 0) then
	{
		_nil = [_x, "debug", true] call ALIVE_fnc_sector;
	}
} forEach _result;


STAT("Sectors in Radius");
_result = [_logic, "sectorsInRadius", [getPos player, 1000]] call ALIVE_fnc_sectorGrid;
_err = "set sectorsInRadius";
ASSERT_TRUE(typeName _result == "ARRAY", _err);

{
	if!(count _x == 0) then
	{
		_nil = [_x, "debug", false] call ALIVE_fnc_sector;
	}
	
} forEach _result;

sleep 5;

{
	if!(count _x == 0) then
	{
		_nil = [_x, "debug", true] call ALIVE_fnc_sector;
	}
} forEach _result;


STAT("Save state");
_result = [_logic, "state"] call ALIVE_fnc_sectorGrid;
_err = "check state";
ASSERT_TRUE(typeName _result == "ARRAY", _err);
ASSERT_TRUE(count _result > 0, _err);
_state = _result;


STAT("Sleeping before destroy");
sleep 10;


DEBUGOFF


STAT("Destroy old instance");
if(isServer) then {
	[_logic, "destroy"] call ALIVE_fnc_sectorGrid;
	TEST_LOGIC = nil;
	publicVariable "TEST_LOGIC";
} else {
	waitUntil{isNull TEST_LOGIC};
};


STAT("Create SectorGrid instance");
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_sectorGrid;
	TEST_LOGIC2 = _logic;
	publicVariable "TEST_LOGIC2";
};


STAT("Confirm new SectorGrid instance 2");
waitUntil{!isNil "TEST_LOGIC2"};
_logic = TEST_LOGIC2;
_err = "instantiate object";
ASSERT_DEFINED("_logic",_err);
ASSERT_TRUE(typeName _logic == "ARRAY", _err);


STAT("Restore state on new instance");
if(isServer) then {
	_result = [_logic, "state", _state] call ALIVE_fnc_sectorGrid;
};


STAT("Confirm restored state is still the same");
_result = [_logic, "state"] call ALIVE_fnc_sectorGrid;
_err = "confirming restored state";
ASSERT_TRUE(typeName _result == "ARRAY", _err);
ASSERT_TRUE(count _result > 0, _err);
_result2 = [_state, _result] call BIS_fnc_areEqual;
ASSERT_TRUE(_result2,_err);


STAT("Set gridPosition");
_result = [_logic, "gridPosition", [getPos player select 0, getPos player select 1]] call ALIVE_fnc_sectorGrid;
_err = "set gridPosition";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


STAT("Set gridSize");
_result = [_logic, "gridSize", 1000] call ALIVE_fnc_sectorGrid;
_err = "set gridSize";
ASSERT_TRUE(typeName _result == "SCALAR", _err);


STAT("Set sectorDimensions");
_result = [_logic, "sectorDimensions", [100,100]] call ALIVE_fnc_sectorGrid;
_err = "set sectorDimensions";
ASSERT_TRUE(typeName _result == "ARRAY", _err);
waitUntil{count ([_logic, "sectorDimensions"] call ALIVE_fnc_sectorGrid) == 2};


STAT("Create Grid");
_result = [_logic, "createGrid"] call ALIVE_fnc_sectorGrid;
_err = "set createGrid";
ASSERT_TRUE(typeName _result == "ARRAY", _err);


DEBUGON


STAT("Sleeping before destroy");
sleep 10;


DEBUGOFF


if(isServer) then {
	STAT("Destroy old instance");
	[_logic, "destroy"] call ALIVE_fnc_sectorGrid;
	TEST_LOGIC2 = nil;
	publicVariable "TEST_LOGIC2";
} else {
	STAT("Confirm destroy instance 2");
	waitUntil{isNull TEST_LOGIC2};
};

sleep 5;

nil;