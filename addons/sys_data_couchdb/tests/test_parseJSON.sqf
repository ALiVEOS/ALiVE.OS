// ----------------------------------------------------------------------------

#include "script_component.hpp"
SCRIPT(test_parseJSON_couchdb);

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_timeStart","_timeEnd","_testData"];

LOG("Testing Data parseJSON - Couchdb");

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

//DEBUGON

STAT("TEST JSON STRING CONVERSION TO CBA HASH");

// Convert JSON string to CBA Hash
_testData = [
	// Basic key : value
	"{""key"":""value""}",
	// Multiple key/value pairs
	"{""alpha"":""Avalue"",""bravo"":""Bvalue""}",
	// Multiple key/value pairs x 4
	"{""alpha"":""Avalue"",""bravo"":""Bvalue"",""alpha1"":""Avalue1"",""bravo1"":""Bvalue1""}",
	// Key with array value
	"{""arraykey"":[""arrayvalue0"",""arrayvalue1""]}",
	// key with basic and array
	"{""key"":""value"",""arraykey"":[""arrayvalue0"",""arrayvalue1""]}",
	// multiple keys and arrays
	"{""key"":""value"",""arraykey"":[""arrayvalue0"",""arrayvalue1"",""arrayv2"",""arrayvalue3""]}",
	// multiple keys and arrays
	"{""key"":""value"",""arraykey"":[""arrayvalue0"",""arrayvalue1"",""arrayv2"",""arrayvalue3""],""key1"":""value1""}",
	// Nested arrays
	"{""key"":""value"",""arraykey"":[[""arrayvalue0"",""arrayvalue1""],[""arrayv2"",""arrayvalue3""]]}",
	// array with nested object
	"{""key"":[{""key1"":""value1"",""key2"":""value2""},{""key10"":""value10"",""key20"":""value20""}]}",
	// nested object basic
	"{""key"":{""key1"":""value1"",""key2"":""value2""}}",
	// nested object with a bit more
	"{""key"":{""key1"":""value1"",""key2"":""value2""},""anotherkey"":""anothervalue""}",
	// Just key : Value pairs - string only
	"{""_id"": ""2c8182f7ae935e655d52f3cdc80070fa"",""_rev"": ""1-efe34647c04a77464d1bac47af08bbd5"",""realTime"": ""12/07/2013 21:52:09"",""Server"": ""86.158.100.190"",""Operation"": ""MedicTest"",""Map"": ""Stratis"",""gameTime"": ""1415"",""Event"": ""OperationStart""}",
	// String, Integer, Array values (in last key)
	"{""_id"": ""2c8182f7ae935e655d52f3cdc8008382"",""_rev"": ""1-685d3dc1ef673a05b9365c46f364f247"",""realTime"": ""12/07/2013 21:52:24"",""Server"": ""86.158.100.190"",""Operation"": ""MedicTest"",""Map"": ""Stratis"",""gameTime"": ""1415"",""Event"": ""Kill"",""KilledSide"": ""WEST"",""Killedfaction"": ""NATO"",""KilledType"": ""Combat Life Saver"",""KilledClass"": ""Infantry"",""KilledPos"": ""017057"",""KillerSide"": ""WEST"",""Killerfaction"": ""NATO"",""KillerType"": ""Combat Life Saver"",""KillerClass"": ""Infantry"",""KillerPos"": ""017057"",""Weapon"": ""MX 6.5Â mm"",""Distance"": 25,""Killed"": ""B Alpha 1-1:3"",""Killer"":""B Alpha 1-1:2 (Matt) REMOTE"",""Player"": ""76561197982137286"",""PlayerName"":""Matt"",""testArray"":[""string1"",""2"",""true""]}",
	//String, integer, Array with Nested JSON object
	"{""_id"": ""2c8182f7ae935e655d52f3cdc80062c1"",""_rev"": ""1-bb8d403becd9349e30c93c00f7072235"",""realTime"": ""12/07/2013 21:50:30"",""Server"": ""86.158.100.190"",""Operation"": ""TupolovRevenge"",""Map"": ""Stratis"",""gameTime"": ""0817"",""Event"": ""PlayerFinish"",""PlayerSide"": ""WEST"",""PlayerFaction"": ""BLU_F"",""PlayerName"": ""Matt"",""PlayerType"": ""B_Soldier_F"",""PlayerClass"": ""Rifleman"",""Player"": ""76561197982137286"",""shotsFired"": [{""weaponMuzzle"": ""arifle_MX_ACO_pointer_F"",""count"": 0,""weaponType"": ""arifle_MX_ACO_pointer_F"",""weaponName"": ""MX 6.5Â mm""},{""weaponMuzzle"": ""gatling_20mm"",""count"": 10,""weaponType"": ""gatling_20mm"",""weaponName"": ""Gatling Cannon 20Â mm""}],""timePlayed"": 2,""score"": 0,""rating"": 0}",
	// String, integer, array, nested array, Nested JSON
	"{""_id"": ""2c8182f7ae935e655d52f3cdc80062c2"",""_rev"": ""1-bb8d403becd9349e30c93c00f7072235"",""realTime"": ""16/07/2013 07:49:14"",""Server"":""86.158.100.190"",""Operation"":""TupolovRevenge"",""Map"":""Stratis"",""gameTime"":""0816"",""Event"":""PlayerFinish"",""PlayerSide"":""WEST"",""PlayerFaction"":""BLU_F"",""PlayerName"":""Matt"",""PlayerType"":""B_Soldier_F"",""PlayerClass"":""Rifleman"",""Player"":""76561197984147486"",""shotsFired"":{""weaponMuzzle"":""arifle_MX_ACO_pointer_F"",""count"":567,""weaponType"":""arifle_MX_ACO_pointer_F"",""weaponName"":""MX 6.5Ã‚Â mm""},""timePlayed"":1e+013,""score"":1e+014,""rating"":5e-007,""testArray"":[""test string"",0.5,1,12345.1,[""this is text"",""text"",5e-009,234.567,12345,""CIV"",""true"",""false""]]}",
	"{
   ""_id"": ""tupolovtest-76561197982137286"",
   ""_rev"": ""1-5a973cf046d5427dcf8a9751fcfe7d60"",
   ""lastSaveTime"": 13.089,
   ""puid"": ""76561197982137286"",
   ""name"": ""Matt"",
   ""speaker"": ""Male03ENG"",
   ""nameSound"": """",
   ""pitch"": 1.01128,
   ""face"": ""GreekHead_A3_06"",
   ""class"": ""B_recon_TL_F"",
   ""rating"": 1500,
   ""rank"": ""SERGEANT"",
   ""group"": ""<NULL-group>"",
   ""leader"": ""true"",
   ""position"": [
       16146.9,
       16987.5,
       0.00143528
   ],
   ""dir"": 85.4781,
   ""anim"": ""Lying"",
   ""side"": ""WEST"",
   ""vehicle"": ""NONE"",
   ""seat"": ""NONE"",
   ""damage"": 0,
   ""lifestate"": ""HEALTHY"",
   ""head_hit"": 0,
   ""body"": 0,
   ""hands"": 0,
   ""legs"": 0,
   ""fatigue"": 0.0862524,
   ""bleeding"": 0,
   ""oxygen"": 1,
   ""assignedItemMagazines"": [
   ],
   ""primaryWeaponMagazine"": [
       ""30Rnd_65x39_caseless_mag"",
       30
   ],
   ""primaryweapon"": ""arifle_MX_RCO_pointer_snds_F"",
   ""primaryWeaponItems"": [
       ""muzzle_snds_H"",
       ""acc_pointer_IR"",
       ""optic_Arco""
   ],
   ""handgunWeaponMagazine"": [
       ""16Rnd_9x21_Mag"",
       16
   ],
   ""handgunWeapon"": ""hgun_P07_snds_F"",
   ""handgunItems"": [
       ""muzzle_snds_L"",
       """",
       """"
   ],
   ""secondaryWeaponMagazine"": [
       ""30Rnd_65x39_caseless_mag"",
       30
   ],
   ""secondaryWeapon"": """",
   ""secondaryWeaponItems"": [
   ],
   ""uniform"": ""U_B_CombatUniform_mcam_vest"",
   ""uniformItems"": [
       [
           ""30Rnd_65x39_caseless_mag"",
           30
       ],
       [
           ""30Rnd_65x39_caseless_mag"",
           30
       ],
       [
           ""30Rnd_65x39_caseless_mag"",
           30
       ],
       ""FirstAidKit""
   ],
   ""vest"": ""V_Chestrig_rgr"",
   ""vestItems"": [
       [
           ""30Rnd_65x39_caseless_mag"",
           30
       ],
       [
           ""30Rnd_65x39_caseless_mag"",
           30
       ],
       [
           ""30Rnd_65x39_caseless_mag_Tracer"",
           30
       ],
       [
           ""30Rnd_65x39_caseless_mag_Tracer"",
           30
       ],
       [
           ""16Rnd_9x21_Mag"",
           16
       ],
       ""HandGrenade"",
       ""HandGrenade"",
       ""SmokeShell"",
       ""SmokeShellGreen"",
       ""SmokeShellBlue"",
       ""SmokeShellOrange"",
       ""Chemlight_green"",
       ""Chemlight_green""
   ],
   ""backpack"": """",
   ""backpackitems"": [
   ],
   ""assigneditems"": [
       ""ItemMap"",
       ""ItemCompass"",
       ""ItemWatch"",
       ""ItemRadio"",
       ""ItemGPS"",
       ""NVGoggles"",
       ""Rangefinder"",
       ""H_MilCap_mcamo"",
       ""G_Shades_Black""
   ],
   ""weaponstate"": [
       ""arifle_MX_RCO_pointer_snds_F"",
       ""Single"",
       ""false"",
       ""false"",
       0,
       ""false""
   ],
   ""score"": 0
}"
];

{
	private ["_type","_msg","_converted"];
	_type = typeName _x;
	_msg = format["Test %1 - %2",_type, _x];
	STAT(_msg);
	sleep 1;
	TIMERSTART
	_converted = [_x] call ALIVE_fnc_parseJSON;
	TIMEREND
	ASSERT_TRUE(typeName _converted == "ARRAY", "FAILED!");
	if (typeName _converted == "ARRAY") then {
		STAT(str(_converted));
	};
	sleep 1;
} foreach _testData;


STAT("Sleeping before destroy");
sleep 10;

nil;