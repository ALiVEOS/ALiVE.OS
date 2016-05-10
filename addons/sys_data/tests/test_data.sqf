
//#squint filter Unknown variable ALIVE_fnc_convertData
//#squint filter Unknown variable ALIVE_fnc_restoreData
//#squint filter Unknown variable ALIVE_fnc_getEnterableHouses
// ----------------------------------------------------------------------------

#include <script_macros_core.hpp>
SCRIPT(test_data);

// ----------------------------------------------------------------------------

private ["_testConvert","_testRestore","_processData","_type","_original","_converted","_restored","_err","_result"];

LOG("Testing data conversion to string");

ASSERT_DEFINED("ALIVE_fnc_convertData","Function not defined");
ASSERT_DEFINED("ALIVE_fnc_restoreData","Function not defined");

#define STAT(msg) sleep 1; \
["TEST("+str player+": "+msg] call ALIVE_fnc_logger; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
["TEST("+str player+": "+msg] call ALIVE_fnc_logger; \
titleText [msg,"PLAIN"]

#define MISSIONOBJECTCOUNT _err = format["Mission objects: %1", count allMissionObjects ""]; \
STAT(_err);

_testConvert = {
		private ["_err","_result"];
		PARAMS_2(_type,_input);
		_err = format["%1 conversion", _type];
		
		ASSERT_DEFINED("_type",_err);
		ASSERT_TRUE(typeName _type == "STRING",_err);
		
		ASSERT_DEFINED("_input",_err);
		ASSERT_TRUE(typeName _input == _type,typeName _input + " == " + _type);
		
		_result = _input call ALIVE_fnc_convertData;
		ASSERT_DEFINED("_result",_err);
		ASSERT_TRUE(typeName _result == "STRING",_err);
		_result;
};

_testRestore = {
		private ["_type","_err","_result","_test"];
		PARAMS_2(_type,_test);
		_err = format["%1 restore", _type];
		
		ASSERT_DEFINED("_type",_err);
		ASSERT_TRUE(typeName _type == "STRING",_err);
		
		ASSERT_DEFINED("_test",_err);
		ASSERT_TRUE(typeName _test == "STRING",_err);        
		
		_result = _test call ALIVE_fnc_restoreData;
		ASSERT_DEFINED("_result",_err);
		ASSERT_TRUE(typeName _result == _type,typeName _result + " == " + _type);
		_result;
};

_processData = {
		private["_result"];
		PARAMS_1(_data);
		copyToClipboard _data;
		sleep 1;
		_result = copyFromClipboard;
		ASSERT_TRUE(typeName _result == "STRING","Process Data error");
		_result;
};

sleep 5;

MISSIONOBJECTCOUNT

_type = "STRING";
STAT("Test STRING");
_original = "test string";
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,_original + " == " + _restored);

_type = "TEXT";
STAT("Test TEXT");
_original = text "test text string";
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

_type = "BOOL";
STAT("Test BOOL (false)");
_original = false;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
ASSERT_FALSE(_restored,str _restored);

STAT("Test BOOL (true)");
_original = true;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
ASSERT_TRUE(_restored,str _restored);

_type = "SCALAR";
STAT("Test SCALAR (large)");
//_original = 12376898761.123546798; // this doesn't work atm
_original = 12376900000;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

STAT("Test SCALAR (small)");
//_original = 12376898761.123546798; // this doesn't work atm
_original = 0.123547;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

_type = "NIL";
STAT("Test NIL");
_converted = call ALIVE_fnc_convertData;
_converted = _converted call _processData;
_restored = _converted call ALIVE_fnc_restoreData;
ASSERT_TRUE(isNil "_restored","Not is Nil");

_type = "SIDE";
STAT("Test SIDE (west)");
_original = west;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

STAT("Test SIDE (east)");
_original = east;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

STAT("Test SIDE (resistance)");
_original = resistance;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

STAT("Test SIDE (civilian)");
_original = civilian;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

STAT("Test SIDE (sideLogic)");
_original = sideLogic;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

_type = "ARRAY";
STAT("Test ARRAY");
_original = ["string", text "text", true, 123.456, resistance];
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

_type = "ARRAY";
STAT("Test ARRAY (nested)");
_original = [["string","string1"], [true, 123.456, resistance],[false, 456.123, west]];
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

_type = "OBJECT";
STAT("Test OBJECT (map object)");
// loc is for Utes Strelka
_original = ([[4395.0229,3171.7737], 10] call ALIVE_fnc_getEnterableHouses) select 0;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);

_type = "ARRAY";
STAT("Test ARRAY (map objects)");
// loc is for Utes Strelka
_original = [[4345.0229,3232.7737], 50] call ALIVE_fnc_getEnterableHouses;
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);
/*
_type = "OBJECT";
STAT("Test OBJECT (vehicle)");
// loc is for Utes Strelka
_original = createVehicle ["HMMWV_Armored", [4345.0229,3232.7737], [], 50, "NONE"];
_original setDir (random 360);
//vectorDir object / vectorUp object / object setVectorDirAndUp [[x, z, y],[x, y, z]]
_original setVehicleVarName "X123";
//addWeaponCargo / addWeaponCargoGlobal
//addMagazineCargo / addMagazineCargoGlobal
_original setAmmoCargo (random 1);
_original setFuelCargo (random 1);
_original setRepairCargo (random 1);

_original setFuel (random 1);
_original setDamage (random 1);
//object setHit [part, damage]
_original setVehicleInit "hint str this;";
//vehicle setVehicleLock state
//object setVehicleAmmo value
//object setVehicleArmor value
//object setVehicleId id
*/
/*
vehiclevarname object / object setVehicleVarName name
typeOf  object
getPosATL object / object setPosATL [x,y,z]
position object
getDamage object
vectorDir object / vectorUp object / object setVectorDirAndUp [[x, z, y],[x, y, z]]
getWeaponCargo object / addWeaponCargo / addWeaponCargoGlobal
getMagazineCargo object / addMagazineCargo / addMagazineCargoGlobal
vehicle setAmmoCargo ammoCargo
vehicle setFuel amount
vehicle setFuelCargo amount
object setHit [part, damage]
vehicle setRepairCargo amount
vehicle setVehicleInit statement
vehicle setVehicleLock state
object setVehicleAmmo value
object setVehicleArmor value
object setVehicleId id
obj setDir heading
*/
/*
_converted = [_type, _original] call _testConvert;
_converted = _converted call _processData;
_restored = [_type, _converted] call _testRestore;
_result = [_original, _restored] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _original + " == " + str _restored);
*/
/*
// Create empty vehicles
_original = [
		createVehicle ["MTVR", [4345.0229,3232.7737], [], 50, "NONE"],
		createVehicle ["M1A1", [4345.0229,3232.7737], [], 50, "NONE"],
		createVehicle ["MH60S", [4345.0229,3232.7737], [], 50, "NONE"]
]
*/

/*
person setCaptive captive
unit setUnconscious set

group setBehaviour behaviour
group setCombatMode mode
group setFormation formation
group setGroupIcon properties
group setGroupIconParams properties
setGroupIconsSelectable bool
setGroupIconsVisible array
group setGroupid [nameFomat, nameParam1, ..]

score  (_this select 0);
{ (_this select 0) getVariable "head_hit";},
{ (_this select 0) getVariable "body";},
{ (_this select 0) getVariable "hands";},
{ (_this select 0) getVariable "legs";},
_animState = animationState _player;
{ lifestate  (_this select 0);},
// crouch or kneel
if (vehicle (_this select 0) != (_this select 0)) then { 
		_result = [str(vehicle (_this select 0)), "REMOTE", 0] call CBA_fnc_find;  // http://dev-heaven.net/docs/cba/files/strings/fnc_find-sqf.html
		if ( _result == -1 ) then {
				if (driver (vehicle (_this select 0)) == (_this select 0)) then { _pseat = "driver"; };
				if (gunner (vehicle (_this select 0)) == (_this select 0)) then { _pseat = "gunner"; };
				if (commander (vehicle (_this select 0)) == (_this select 0)) then { _pseat = "commander"; };
		};
};

{rating  (_this select 0);},
unit setRank rank
unit setUnitRank rank
unit setUnconscious set
unit setUnitPos mode

{ (_this select 0) getvariable "pviewdistance";},
{ (_this select 0) getvariable "pterraindetail";},
{ (_this select 0) getvariable "prank";},
{ (_this select 0) getVariable "pshotsfired";},
{ (_this select 0) getVariable "penemykills";},
{ (_this select 0) getVariable "pcivkills";},
{ (_this select 0) getVariable "pfriendlykills";},
{ (_this select 0) getVariable "psuicides";},
{ (_this select 0) getVariable "pdeaths";},
{ ((_this select 0) getVariable "TimePlayed") + ( time - ((_this select 0) getVariable "connectTime") );},
{ (_this select 0) getVariable "LastConnected";},
{ (_this select 0) getVariable "LastDisconnected";}
//    {[group  (_this select 0), (leader  (_this select 0) ==  (_this select 0))];}
*/

// test "LOCATION"
/*
createLocation [type, position, sizeX, sizeZ]
location setImportance importance / importance location
location setDirection direction / direction location
location setName name / name location
location setPosition position / getPos location / locationPosition location / position location
location setRectangular rectangular / rectangular location
location setSide side / side location
location setSize [sizeX, sizeZ] / size location
location setText text / text location
location setType type / type location
location setVariable [name, value] / location getVariable name
attachedObject location / location attachObject object
deleteLocation location / isNull location
position in location
nearestLocation [position, type]
nearestLocations [position, [types], distance, <position to sort from>]
nearestLocationWithDubbing position
*/

// test "CONFIG"

// test "GROUP"
// test "CODE"
// test "SCRIPT"

// test "CONTROL"
// test "DISPLAY"

MISSIONOBJECTCOUNT

nil;
