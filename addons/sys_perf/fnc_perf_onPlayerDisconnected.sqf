/*
 * Filename:
 * fnc_perf_onPlayerDisconnected.sqf
 *
 * Description:
 * handled onPlayerDisconnected event for sys_perf

 * Created by Tupolov
 * Creation date: 06/07/2013
 *
 * */

// ====================================================================================
// MAIN

#include "script_component.hpp"

if (GVAR(ENABLED)) then {
	private ["_id","_uid","_name"];

	TRACE_1("",_this);

	_id = _this select 0;
	_name = _this select 1;
	_uid = _this select 2;

	if (_name == "__SERVER__") exitWith {

		// Format Data
		_data = [ ["Type", "MissionFinish"] ];

		diag_log[format["SYS_PERF: SHUTTING DOWN PERF DATA"]];

		// Send Data
		GVAR(UPDATE_PERF) = _data;
		publicVariableServer QGVAR(UPDATE_PERF);

		GVAR(fsmHandle) setFSMVariable ["_abort", true];
	};

};

// ====================================================================================