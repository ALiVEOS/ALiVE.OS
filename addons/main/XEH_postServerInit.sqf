#include "script_component.hpp"

// Handles all OnXXX calls that can't be stacked
/*
onBriefingGroup
onBriefingNotes
onBriefingPlan
onBriefingTeamSwitch
onCommandModeChanged
onDoubleClick
onEachFrame
onGroupIconClick
onGroupIconOverEnter
onGroupIconOverLeave
onHCGroupSelectionChanged
onMapSingleClick
onPlayerConnected
onPlayerDisconnected
onPreloadFinished
onPreloadStarted
onShowNewObject
onTeamSwitch
*/

// Setup player disconnection eventhandler

// Deprecated due to new BIS_fnc_addStackedEventHandler

// FIXME - what are these here and not in their respective modules?
// Is think you may have misunderstood me when I said we should only have
// one OPD and OPC for all of ALIVE.

// ALIVE_player_count is used to measure how many players are connected and when all players have disconnected - used in the fnc_abortButton.
MOD(player_count) = 0;

onPlayerDisconnected {

	TRACE_1("OPD DATA",_this);

	if (_name != "__SERVER__") then {
    	MOD(player_count) = MOD(player_count) - 1;
    };

};


ALiVE_fnc_onPlayerConnected = {

	TRACE_1("OPC DATA",_this);
//    ["OPC DATA",_this] call ALiVE_fnc_dump;

	if !(isNil QMOD(sys_statistics)) then {
		// Stats module onPlayerConnected call
		[_id, _name, _uid, _owner, _jip] call ALIVE_fnc_stats_onPlayerConnected;
	};

	if !(isNil QMOD(sys_player)) then {
		// sys_player module onPlayerConnected call
		[_id, _name, _uid, _owner, _jip] call ALIVE_fnc_player_onPlayerConnected;
	};

	if !(isNil 'ALIVE_profileHandler') then {
        // Profiles module onPlayerDisconnected call
        [_id, _name, _uid, _owner, _jip] call ALIVE_fnc_profile_onPlayerConnected;
    };

    if !(isNil QMOD(MIL_C2ISTAR)) then {
        // C2ISTAR module onPlayerConnected call
        [_id, _name, _uid, _owner, _jip] call ALIVE_fnc_C2OnPlayerConnected;
    };

    if !(isNil QMOD(SYS_marker)) then {
        // Marker module onPlayerConnected call
        [_id, _name, _uid, _owner, _jip] call ALIVE_fnc_markerOnPlayerConnected;
    };

    if !(isNil QMOD(SYS_spotrep)) then {
        // spotrep module onPlayerConnected call
        [_id, _name, _uid, _owner, _jip] call ALIVE_fnc_spotrepOnPlayerConnected;
    };

    if !(isNil QMOD(SYS_sitrep)) then {
        // sitrep module onPlayerConnected call
        [_id, _name, _uid, _owner, _jip] call ALIVE_fnc_sitrepOnPlayerConnected;
    };

    if !(isNil QMOD(SYS_patrolrep)) then {
        // patrolrep module onPlayerConnected call
        [_id, _name, _uid, _owner, _jip] call ALIVE_fnc_patrolrepOnPlayerConnected;
    };

	if (_name != "__SERVER__") then {
    	MOD(player_count) = MOD(player_count) + 1;
    };
};

[QGVAR(OPC),"onPlayerConnected","ALiVE_fnc_OnPlayerConnected"] call BIS_fnc_addStackedEventHandler;