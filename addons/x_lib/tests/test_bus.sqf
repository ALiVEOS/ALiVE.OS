// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_bus);

// ----------------------------------------------------------------------------

private ["_expected","_returned","_result"];

LOG("Testing ALiVE Service Bus");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_BUS","ALIVE_fnc_BUS is not defined!");

#define STAT(msg) sleep 1; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

private ["_expected","_returned","_result"];
STAT("Test No Params (Create/Check Eventhandler");
_expected = true;
_returned = [] call ALIVE_fnc_BUS;
_result = [typeName _expected, typeName _returned] call BIS_fnc_areEqual;
ASSERT_TRUE(_result,typeOf _expected + " != " + typeOf _returned);

[] spawn {
    private ["_tmTmp","_ret","_message","_timewait"];
    
    Hint "Starting ALiVE Service Bus Test in 20 seconds! Test needs to be run on dedicated server!";
    waituntil {({!(isnull _x)} count playableunits > 0)};
    sleep 20;
    
    RESULTSET_SERVER = [];
    RESULTSET_CLIENT = [];
    ERROR_SERVER = nil;
	ERROR_CLIENT = nil;
    TIMESTART = time;
    
	STAT("Test Transfer client to server");
	if !(isDedicated) then {
        if (player == playableunits select 0) then {
		    hint "Starting ALiVE Servicebus Test (expected duration: 20 secs)!";
            
            for "_i" from 1 to 100 do {
            	["server","Subject",[_i,{["ALiVE automated test BUS #%1",_this] call ALiVE_fnc_DumpR; RESULTSET_SERVER set [count RESULTSET_SERVER,_this]}]] call ALiVE_fnc_BUS;
            };
            
            ERROR_CLIENT = false;
            PublicVariable "ERROR_CLIENT";
    	};
	} else {
        	Waituntil {!isnil "ERROR_CLIENT" || time - TIMESTART > 60};
            
	        if (count RESULTSET_SERVER != 100) then {ERROR_CLIENT = true} else {ERROR_CLIENT = false};
	        Publicvariable "ERROR_CLIENT";
            Publicvariable "RESULTSET_SERVER";
    };

	STAT("Test Transfer server to client");
	if (isDedicated) then {
		    hint "Starting ALiVE Servicebus Test (expected duration: 20 secs)!";
            
            for "_i" from 1 to 100 do {
            	[playableUnits select 0,"Subject",[_i,{["ALiVE automated test BUS #%1",_this] call ALiVE_fnc_DumpR; RESULTSET_CLIENT set [count RESULTSET_CLIENT,_this]}]] call ALiVE_fnc_BUS;
            };
            
            ERROR_SERVER = false;
            PublicVariable "ERROR_SERVER";
	} else {
        	Waituntil {!isnil "ERROR_SERVER" || time - TIMESTART > 60};
            
	        if (count RESULTSET_CLIENT != 100) then {ERROR_SERVER = true} else {ERROR_SERVER = false};
	        Publicvariable "ERROR_SERVER";
            Publicvariable "RESULTSET_CLIENT";
    };

    if (isnil "ERROR_SERVER") then {ERROR_SERVER = true};
    if (isnil "ERROR_CLIENT") then {ERROR_CLIENT = true};
    
	if (ERROR_SERVER || ERROR_CLIENT) then {
	    ["ALiVE BUS Automated Test Client > Server! OK: %1 Quality: %2/100!",!ERROR_CLIENT,count RESULTSET_SERVER] call ALiVE_fnc_DumpR;
		["ALiVE BUS Automated Test Server > Client! OK: %1 Quality: %2/100!",!ERROR_SERVER,count RESULTSET_CLIENT] call ALiVE_fnc_DumpR;
	} else {
		["ALiVE BUS Automated Tests! Quality %1 | %2",count RESULTSET_SERVER,count RESULTSET_CLIENT] call ALiVE_fnc_DumpR;
	};
    nil;
};
