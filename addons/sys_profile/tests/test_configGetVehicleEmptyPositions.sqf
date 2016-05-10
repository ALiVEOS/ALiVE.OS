// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_configGetVehicleEmptyPositions);

//execVM "\x\alive\addons\sys_profile\tests\test_configGetVehicleEmptyPositions.sqf"

// ----------------------------------------------------------------------------

LOG("Testing empty positions from config data");

#define STAT(msg) sleep 1; \
["TEST("+str player+": "+msg] call ALIVE_fnc_logger; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
["TEST("+str player+": "+msg] call ALIVE_fnc_logger; \
titleText [msg,"PLAIN"]

_type = "B_Mortar_01_F";
_test = [0,1,0,0,0];
STAT("Test Mortar");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

_type = "B_MRAP_01_gmg_F";
_test = [1,1,0,0,2];
STAT("Test MRAP");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

_type = "B_Truck_01_transport_F";
_test = [1,0,0,0,17];
STAT("Test Truck");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

_type = "B_Heli_Transport_01_camo_F";
_test = [1,1,0,2,8];
STAT("Test Transport Heli");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

_type = "B_Heli_Light_01_armed_F";
_test = [1,0,0,1,0];
STAT("Test Attack Heli");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

_type = "O_APC_Tracked_02_cannon_F";
_test = [1,1,1,0,8];
STAT("Test APC Cannon");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

_type = "O_MBT_02_cannon_F";
_test = [1,1,1,0,0];
STAT("Test MBT Cannon");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

_type = "O_MBT_02_cannon_F";
_test = [1,1,1,0,0];
STAT("Test MBT Cannon");
_data = [_type] call ALIVE_fnc_configGetVehicleEmptyPositions;
_result = [_data, _test] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,str _data + " == " + str _test);

nil;
