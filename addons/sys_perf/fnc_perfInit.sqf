#include "\x\alive\addons\sys_perf\script_component.hpp"
SCRIPT(perfInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_perfInit
Description:
Initiates the data system

Parameters:
_this select 0: OBJECT - Reference to module

Returns:
Nil

See Also:
- <ALIVE_fnc_perf>

Author:
Tupolov
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic"];

PARAMS_1(_logic);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_data","Main function missing");

LOG(MSG_INIT);

ADDON = false;

// #1031: the War Room recorder below (perf data sent to the ALiVE web service) has never
// run in ALiVE.OS, and it is kept on purpose for whenever War Room is recoded rather than
// deleted. GVAR(ENABLED) is never set true: fnc_DataInit.sqf sets it false in three places
// and the one branch that would enable it, when the cloud reports PerfData allowed, is
// commented out at DataInit :224-225 (it arrived commented out in 988cd3c6, 10 May 2016).
//
// The admin Perf menu no longer lives here. It is set up for every machine by
// ALIVE_fnc_perfMenuInit, spawned from main/fnc_aliveInit.sqf, and drives the War Room-free
// monitor in ALIVE_fnc_perfServer, which writes "ALiVE PERF" lines to the RPT.
TRACE_2("SYS_PERF",isDedicated,GVAR(ENABLED));

if (isDedicated && GVAR(ENABLED)) then {

    private ["_data","_handle"];

    // Setup data handler
    GVAR(datahandler) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(datahandler),"storeType",false] call ALIVE_fnc_Data;

    // Grab Server IP
    GVAR(serverIP) = [] call ALIVE_fnc_getServerIP;
    GVAR(serverName) = [] call ALIVE_fnc_getServerName;

    // If the host IP web service is down, just use the serverName
    if (GVAR(serverIP) == "ERROR") then {
        GVAR(serverIP) = GVAR(serverName);
    };

    // Try getting the actual MP hostname of server
    //GVAR(serverhostname) = ["ServerHostName"] call ALIVE_fnc_sendToPlugIn;
    //diag_log GVAR(serverhostname);

    // Setup Module Data Listener
    // Server side handler to write data to DB
    QGVAR(UPDATE_PERF) addPublicVariableEventHandler {

                    private ["_data", "_post", "_gameTime", "_realTime","_hours","_minutes","_currenttime","_async"];
                    if (GVAR(ENABLED)) then {
                        _data = _this select 1;
                        _module = "sys_perf";

                        // Check data passed is an array
                        ASSERT_TRUE(typeName _data == "ARRAY", _data);

                        // Get server/date/time/operation/map specific information to prefix to event data

                        // Get local time and format please.
                        _currenttime = date;

                        // Work out time in 4 digits
                        if ((_currenttime select 4) < 10) then {
                            _minutes = "0" + str(_currenttime select 4);
                        } else {
                            _minutes = str(_currenttime select 4);
                            };
                        if ((_currenttime select 3) < 10) then {
                            _hours = "0" + str(_currenttime select 3);
                        } else {
                            _hours = str(_currenttime select 3);
                        };

                        _gametime = format["%1%2", _hours, _minutes];
                        _realtime = [] call ALIVE_fnc_getServerTime;

                        // _data should be an array of key/value
                        _data = [ ["realTime",_realtime],["Server",GVAR(serverIP)],["Operation",missionName],["Map",worldName],["gameTime",_gametime] ] + _data;

                        // Write event data to DB
                        if ((_data select 5) select 1 == "MissionFinish") then {
                            _async = false;
                        } else {
                            _async = true;
                        };
                        _result = [GVAR(datahandler), "write", [_module, _data, _async], "CouchDB" ] call ALIVE_fnc_Data;
                        if (_result == "ERROR") then {
                            ERROR("SYS PERF FAILED TO WRITE TO DATABASE");
                        };
                        TRACE_2("UPDATE PERF",_data,_result);
                        _result;

                    };
    };

    // Format Data
    _data = [ ["Type","ServerStart"] ];

    // Send Data
    GVAR(UPDATE_PERF) = _data;
    publicVariableServer QGVAR(UPDATE_PERF);

    TRACE_1("UPDATE PERF",_data);

    // Get custom perf code
    private "_customCode";
    _customCode = _logic getVariable ["customPerfMonCode","[['entities',150],['vehicles',300],['agents',450],['allDead',600],['objects',750],['triggers',900]]"];
    _customCode = parseSimpleArray _customCode;

    // Start FSM now
    GVAR(fsmHandle) = [_customCode] execFSM "\x\alive\addons\sys_perf\fnc_perfMonitor.fsm";

    TRACE_1("PerfMonitor Launched",_handle);

};


ADDON = true;
