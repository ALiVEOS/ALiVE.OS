// ----------------------------------------------------------------------------

#include "script_component.hpp"	
SCRIPT(test_convertData_couchdb);

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_timeStart","_timeEnd"];

LOG("Testing Data Conversion - Couchdb");

ASSERT_DEFINED("ALIVE_fnc_data","Class not defined");

//========================================
// Defines
#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"];

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"];

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_Data; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_Data; \
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
// Functions

//========================================
// Main
_logic = nil;

STAT("Create CouchDB Data Handler instance");
TIMERSTART
if(isServer) then {
	_logic = [nil, "create"] call ALIVE_fnc_Data;
	[_logic,"source","couchdb"] call ALIVE_fnc_Data; 
	[_logic,"databaseName","arma3live"] call ALIVE_fnc_Data; 
	_result = _logic;
	TEST_LOGIC = _logic;
	publicVariable "TEST_LOGIC";
};
TIMEREND
STAT("Confirm new Data Handler instance");

_logic = TEST_LOGIC;
ASSERT_DEFINED("_logic",_logic);
ASSERT_TRUE(typeName _logic == "ARRAY", typeName _logic);

//DEBUGON
STAT("Load Data Dictionary");
TIMERSTART
// Setup Data Dictionary
ALIVE_DataDictionary = [] call CBA_fnc_hashCreate;

TIMEREND
ASSERT_DEFINED("ALIVE_DataDictionary",ALIVE_DataDictionary);
ASSERT_TRUE(typeName ALIVE_DataDictionary == "ARRAY", typeName ALIVE_DataDictionary);
TRACE_2("DATA DICTIONARY", ALIVE_DataDictionary, _response);

STAT("TEST DATA CONVERSION TO JSON STRING");

// Test is to send several different CBA Hashes with varying types of data 
private ["_test1","_test2","_test3","_test4","_keys1","_keys2","_keys3","_keys4","_values1","_values2","_values3","_values4","_i","_array","_testData"];
_array = [];
_test1 = [] call CBA_fnc_hashCreate;
_test2 = [] call CBA_fnc_hashCreate;
_test3 = [] call CBA_fnc_hashCreate;
_test4 = [] call CBA_fnc_hashCreate;

// create test 1 - basic numbers plus empty array
_keys1 = ["realTime","Server","Operation","Map","gameTime","Event","PlayerSide","PlayerFaction","PlayerName","PlayerType","PlayerClass","Player","shotsFired","timePlayed","score","rating"];
_values1 = ["16/07/2013 07:29:13","86.158.100.190","TupolovRevenge","Stratis","0816","PlayerFinish",WEST,"BLU_F","Matt","B_Soldier_F","Rifleman","76561197982137286",_array,1,0.5,123.456];
_i=0;
{
	[_test1, _x, _values1 select _i] call CBA_fnc_hashSet; 
	_i =_i + 1;
} foreach _keys1;

// create test 2 - different basic values plus empty array
_keys2 = ["realTime","Server","Operation","Map","gameTime","Event","PlayerSide","PlayerFaction","PlayerName","PlayerType","PlayerClass","Player","shotsFired","timePlayed","score","rating"];
_values2 = ["16/07/2013 07:29:13","86.158.100.190","TupolovRevenge","Stratis","0816","PlayerFinish",EAST,"OPF_F","Matt","B_Soldier_F","Rifleman","76561197982137286",_array,123456.123456,0.000000000005,99999999999999999];
_i=0;
{
	[_test2, _x, _values2 select _i] call CBA_fnc_hashSet; 
	_i =_i + 1;
} foreach _keys2;

// create test 3 - basic values (all) plus nested array, text, bool etc
_text = text "this is text";
_keys3 = ["realTime","Server","Operation","Map","gameTime","Event","PlayerSide","PlayerFaction","PlayerName","PlayerType","PlayerClass","Player","shotsFired","timePlayed","score","rating","testArray"];
_values3 = ["16/07/2013 07:39:13","86.158.100.190","TupolovRevenge","Stratis","0816","PlayerFinish",resistance,"OPF_F","Matt","B_Soldier_F","Rifleman","76561197983137386",_array,1,99999999999999,0.0000005,["test string",0.5,1,12345.12345,[_text,"string1",0.5,1,12345,civilian,true,false,player]]];
_i=0;
{
	[_test3, _x, _values3 select _i] call CBA_fnc_hashSet; 
	_i =_i + 1;
} foreach _keys3;


// create test 4 - as above plus nested hash
private ["_hash4","_hash4keys","_hash4values"];
_hash4 = [] call CBA_fnc_hashCreate;
_hash4keys = ["weaponMuzzle","count","weaponType","weaponName"];
_hash4values = ["arifle_MX_ACO_pointer_F",567,"arifle_MX_ACO_pointer_F","MX 6.5Â mm"];
_i=0;
{
	[_hash4, _x, _hash4values select _i] call CBA_fnc_hashSet; 
	_i =_i + 1;
} foreach _hash4keys;

_keys4 = ["realTime","Server","Operation","Map","gameTime","Event","PlayerSide","PlayerFaction","PlayerName","PlayerType","PlayerClass","Player","shotsFired","timePlayed","score","rating","testArray"];
_values4 = ["16/07/2013 07:49:14","86.158.100.190","TupolovRevenge","Stratis","0816","PlayerFinish",WEST,"BLU_F","Matt","B_Soldier_F","Rifleman","76561197984147486",_hash4,9999999999999,99999999999999,0.0000005,["test string",0.5,1,12345.12345,[_text,"text",0.000000005,234.567,12345,civilian,true,false]]];
_i=0;
{
	[_test4, _x, _values4 select _i] call CBA_fnc_hashSet; 
	_i =_i + 1;
} foreach _keys4;

_testData = [_test1, _test2, _test3, _test4];
{
	private ["_type","_msg","_converted"];
	_type = typeName _x;
	_msg = format["Test %1 - %2",_type, _x];
	STAT(_msg);
	sleep 1;
	TIMERSTART
		_converted = [_logic, "convert", [_x]] call ALIVE_fnc_Data;
	TIMEREND
	ASSERT_TRUE(typeName _converted == "STRING", typeName _converted);
	STAT(_converted);
	sleep 1;
} foreach _testData;

STAT("Saving Data Dictionary");
// Save Data Dictionary for purposes of restore test
TIMERSTART
_result = [_logic, "write", ["sys_data", ALIVE_DataDictionary, false, "dictionary"] ] call ALIVE_fnc_Data;
TIMEREND
STAT(_result);
sleep 5;

STAT("Sleeping before destroy");
sleep 10;

STAT("Destroy Data Handler instance");
[_logic, "destroy"] call ALIVE_fnc_Data;

nil;