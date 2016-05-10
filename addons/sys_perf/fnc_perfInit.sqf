#include <\x\alive\addons\sys_perf\script_component.hpp>
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

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic"];

PARAMS_1(_logic);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_data","Main function missing");

LOG(MSG_INIT);

ADDON = false;

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

	// Setup OPC and OPD events
	//[QGVAR(OPD), "OnPlayerDisconnected","ALIVE_fnc_perf_OnPlayerDisconnected"] call BIS_fnc_addStackedEventHandler;

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
						_result = [GVAR(datahandler), "write", [_module, _data, _async] ] call ALIVE_fnc_Data;
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
	_customCode = call compile _customCode;

	// Start FSM now
	GVAR(fsmHandle) = [_customCode] execFSM "\x\alive\addons\sys_perf\fnc_perfMonitor.fsm";

	TRACE_1("PerfMonitor Launched",_handle);

};


TRACE_4("Adding menu",isDedicated,isHC,GVAR(ENABLED),GVAR(DISABLED));

if(!isDedicated && !isHC && GVAR(ENABLED)) then {
		// Initialise interaction key if undefined
		if(isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};

		// if ACE spectator enabled, seto to allow exit
		if(!isNil "ace_fnc_startSpectator") then {ace_sys_spectator_can_exit_spectator = true;};

		// Initialise default map click command if undefined
		ISNILS(DEFAULT_MAPCLICK,"");

		TRACE_3("Menu pre-req",SELF_INTERACTION_KEY,ace_fnc_startSpectator,DEFAULT_MAPCLICK);

		// initialise main menu
		[
				"player",
				[((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
				-9500,
				[
						"call ALIVE_fnc_perfMenuDef",
						"main"
				]
		] call ALiVE_fnc_flexiMenu_Add;
};

ADDON = true;