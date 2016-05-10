// ----------------------------------------------------------------------------

#include "script_component.hpp"	
SCRIPT(test_restoreData_couchdb);

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_timeStart","_timeEnd","_testData","_response"];

LOG("Testing Data Restore - Couchdb");

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
waitUntil{!isNil "TEST_LOGIC"};
_logic = TEST_LOGIC;
ASSERT_DEFINED("_logic",_logic);
ASSERT_TRUE(typeName _logic == "ARRAY", typeName _logic);

//DEBUGON
STAT("Load Data Dictionary");
TIMERSTART
// Setup Data Dictionary
ALIVE_DataDictionary = [] call CBA_fnc_hashCreate;
// Try loading dictionary from db
_response = [_logic, "read", ["sys_data", [], "dictionary"]] call ALIVE_fnc_Data;
if ( typeName _response != "STRING") then {
	ALIVE_DataDictionary = _response;
} else {
	TRACE_1("NO DICTIONARY AVAILABLE" _response);
};
TIMEREND
ASSERT_DEFINED("ALIVE_DataDictionary",ALIVE_DataDictionary);
ASSERT_TRUE(typeName ALIVE_DataDictionary == "ARRAY", typeName ALIVE_DataDictionary);
TRACE_2("DATA DICTIONARY", ALIVE_DataDictionary, _response);
	
STAT("TEST DATA RESTORE FROM JSON STRING");

_testData = [ 
	"{""_id"": ""2c8182f7ae935e655d52f3cdc80070fa"", ""_rev"": ""1-efe34647c04a77464d1bac47af08bbd5"", ""realTime"": ""12/07/2013 21:52:09"",""Server"": ""86.158.100.190"",""Operation"": ""MedicTest"",""Map"": ""Stratis"",""gameTime"": ""1415"",""Event"": ""OperationStart""}",
	"{""_id"": ""2c8182f7ae935e655d52f3cdc8008382"",""_rev"": ""1-685d3dc1ef673a05b9365c46f364f247"",""realTime"": ""12/07/2013 21:52:24"",""Server"": ""86.158.100.190"",""Operation"": ""MedicTest"",""Map"": ""Stratis"",""gameTime"": ""1415"",""Event"": ""Kill"",""KilledSide"": ""WEST"",""Killedfaction"": ""NATO"",""KilledType"": ""Combat Life Saver"",""KilledClass"": ""Infantry"",""KilledPos"": ""017057"",""KillerSide"": ""WEST"",""Killerfaction"": ""NATO"",""KillerType"": ""Combat Life Saver"",""KillerClass"": ""Infantry"",""KillerPos"": ""017057"",
		""Weapon"": ""MX 6.5Â mm"",
		""Distance"": 25,
		""Killed"": ""B Alpha 1-1:3"",
		""Killer"": ""B Alpha 1-1:2 (Matt) REMOTE"",
		""Player"": ""76561197982137286"",
		""PlayerName"": ""Matt""
	}",
	"{
		""_id"": ""2c8182f7ae935e655d52f3cdc80062c1"",
		""_rev"": ""1-bb8d403becd9349e30c93c00f7072235"",
		""realTime"": ""12/07/2013 21:50:30"",
		""Server"": ""86.158.100.190"",
		""Operation"": ""TupolovRevenge"",
		""Map"": ""Stratis"",
		""gameTime"": ""0817"",
		""Event"": ""PlayerFinish"",
		""PlayerSide"": ""WEST"",
		""PlayerFaction"": ""BLU_F"",
		""PlayerName"": ""Matt"",
		""PlayerType"": ""B_Soldier_F"",
		""PlayerClass"": ""Rifleman"",
		""Player"": ""76561197982137286"",
		""shotsFired"": [
		   {
			   ""weaponMuzzle"": ""arifle_MX_ACO_pointer_F"",
			   ""count"": 0,
			   ""weaponType"": ""arifle_MX_ACO_pointer_F"",
			   ""weaponName"": ""MX 6.5Â mm""
		   },
		   {
			   ""weaponMuzzle"": ""gatling_20mm"",
			   ""count"": 10,
			   ""weaponType"": ""gatling_20mm"",
			   ""weaponName"": ""Gatling Cannon 20Â mm""
		   }
		],
		""timePlayed"": 2,
		""score"": 0,
		""rating"": 0
	}"
];

{
	private ["_type","_msg"];
	_type = typeName _x;
	_msg = format["Test %1 - %2",_type, _x];
	STAT(_msg);
	TIMERSTART
	_restored =  [_logic, "restore", [_x]] call ALIVE_fnc_Data;
	TIMEREND
	_msg = format["Test %1 - %2", typeName _restored, _restored];
	STAT(_msg);
} foreach _testData;


STAT("Sleeping before destroy");
sleep 10;

STAT("Destroy Data Handler instance");
[_logic, "destroy"] call ALIVE_fnc_Data;

nil;