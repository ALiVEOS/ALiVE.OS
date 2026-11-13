#include "script_component.hpp"
SCRIPT(AUTOSAVE_PNS);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_AUTOSAVE_PNS

Description:
Saves mission state to PNS in given interval!
!! Health Warning: This function is writing to file (freeze for about 2 seconds). Will cause desync and lag in MP !!

Parameters:
Number - Interval to save in seconds, or "now" to save once straight away (server only, Local source)

Returns:
nothing (nil)

Examples:
(begin example)
    // Will save every 15 minutes
    900 call ALiVE_fnc_AUTOSAVE_PNS

    // Saves once now, leaving any timed autosave as it is (for example from a trigger before a restart)
    "now" call ALiVE_fnc_AUTOSAVE_PNS
(end)

Author:
Highhead
Jman
Peer Reviewed:

---------------------------------------------------------------------------- */

// "now" saves once, straight away, and leaves a timed autosave running as it was. It's for a
// mission's own scripts and triggers, to save before a planned restart for example. Asked for on
// Discord: there was no way to save from a script, and a number here starts or replaces the timer.
private _once = (!isNil "_this") && {_this isEqualTo "now"};
private _interval = if (isNil "_this" || {_once}) then {-1} else {_this};

if !(isServer && {!isNil "ALiVE_SYS_DATA_SOURCE"} && {ALiVE_SYS_DATA_SOURCE == "pns"}) exitWith {["SYS DATA PNS - Local machine is not the server or local save not available! Exiting..."] call ALiVE_fnc_dump};

if (!_once && {!isNil "ALiVE_SYS_DATA_PNS_AUTOSAVE"}) then {terminate ALiVE_SYS_DATA_PNS_AUTOSAVE};

private _handle = [_interval, _once] spawn {

    params ["_interval", "_once"];

    while {_interval > 0 || {_once}} do {

        if (!_once) then { sleep _interval };

	    sleep 5;
	    TitleText ["ALiVE IS PREPARING TO SAVE...","PLAIN"];
	    sleep 1;
        ["IS SAVING..."] call ALiVE_fnc_dumpMPH;
        sleep 1;
	    TitleText ["ALiVE IS SAVING...","PLAIN"];
	    sleep 1;

	    // Export the profiles that aren't spawned a few at a time first, so the one-frame save below only
	    // has to export the ones spawned or changed since
	    private _prepStart = diag_tickTime;
	    private _prepared = 0;
	    // (only when this pass saves the profiles: the profile save skips itself within five minutes of the last one)
	    if ((missionNamespace getVariable ["ALIVE_saveProfilesPersistent", false]) && {!isNil "ALIVE_profileHandler"}
	        && {isNil "ALiVE_sysProfileLastSaveTime" || {time - ALiVE_sysProfileLastSaveTime > 300}}) then {
	        _prepared = [ALIVE_profileHandler, "prepareExportProfileData"] call ALIVE_fnc_profileHandler;
	    };
	    private _prepTime = diag_tickTime - _prepStart;
	    private _saveStart = diag_tickTime;
	    ALiVE_diag_profileSaveSplit = nil;
	    // the time each part of the save took, for the AUTOSAVE event: a stage runs from its label to the next one
	    private _stages = [];
	    private _stageName = "start";
	    private _stageAt = _saveStart;
	    private _fnc_stage = {
	        private _ms = round ((diag_tickTime - _stageAt) * 1000);
	        if (_stageName != "" && {_ms >= 5}) then { _stages pushBack format ["%1 %2", _stageName, _ms] };
	        _stageName = _this; _stageAt = diag_tickTime;
	    };
	    {
			// Every module saved in this frame waits, and the file is written once at the end
			MOD(PNS_HOLD_FRAME) = diag_frameNo;
			MOD(PNS_HOLD_DIRTY) = false;

			// Save player state player in SP or hosted
			if (hasInterface) then {
			    private ["_name","_uid","_id"];

			    _id = player;
			    _name = name player;
			    _uid = getPlayerUID player;

			    if !(isNil "ALiVE_sys_player") then {
                    ["SYS DATA PNS Autosave - Save Player Data id: %1 name: %2 uid: %3",_id,_name,_uid] call ALiVE_fnc_dump;

                    "Player Data OPD" call _fnc_stage;
                    ["SYS DATA PNS Autosave - Player Data OPD"] call ALiVE_fnc_dump;

			         if (ALiVE_sys_player getvariable "saveLoadout") then {
			                private ["_gearHash","_unit"];

                            "Storing Player Gear" call _fnc_stage;
                            ["SYS DATA PNS Autosave - Storing Player Gear"] call ALiVE_fnc_dump;

			                _gearHash = [ALiVE_sys_player, "setGear", [player]] call ALIVE_fnc_player;
			                [ALiVE_sys_player, "updateGear", [player, _gearHash]] call ALiVE_fnc_player;
			        };
			        [_id, _name, _uid] call ALIVE_fnc_player_onPlayerDisconnected;
			    };

				if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {

					"Player Profile Handler OPD" call _fnc_stage;
					["SYS DATA PNS Autosave - Player Profile Handler OPD"] call ALiVE_fnc_dump;
					[_id, _name, _uid] call ALIVE_fnc_profile_onPlayerDisconnected;
				};
	        };

            // Save mission state data

            _uid = "";
    		_id = "";

			if !(isNil "ALiVE_sys_data") then {
			    "Server Data OPD" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Data OPD"] call ALiVE_fnc_dump;
			    [_id, "__SERVER__", _uid] call ALIVE_fnc_data_onPlayerDisconnected;
			};

			if !(isNil "ALiVE_sys_player") then {
			    "Server Player OPD" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Player OPD"] call ALiVE_fnc_dump;
			    [_id, "__SERVER__", _uid] call ALIVE_fnc_player_onPlayerDisconnected;
			};

			private _lastProfileSave = missionNamespace getVariable ["ALiVE_sysProfileLastSaveTime", -1];
			if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {
			    "Profiles" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save Profiles"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_profilesSaveData;
			};
			// Whether the profiles were saved on this pass, or aren't kept at all. The profile save skips
			// itself within five minutes of the last one.
			private _profilesSaved = !(missionNamespace getVariable ["ALIVE_saveProfilesPersistent", false])
			    || {(missionNamespace getVariable ["ALiVE_sysProfileLastSaveTime", -1]) != _lastProfileSave};

			if (["ALiVE_mil_OPCOM"] call ALiVE_fnc_isModuleAvailable) then {
			    "OPCOM" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save OPCOM State"] call ALiVE_fnc_dump;
			    _results = [] call ALiVE_fnc_OPCOMSaveData;
			};

			if (["ALiVE_mil_IED"] call ALiVE_fnc_isModuleAvailable) then {
				"IED" call _fnc_stage;
				["ALiVE SYS DATA PNS Autosave - Server Save IED State"] call ALIVE_fnc_dump;
				[] call ALiVE_fnc_IEDSaveData;
			};

			if (["ALiVE_mil_cqb"] call ALiVE_fnc_isModuleAvailable) then {
			    "CQB" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save CQB State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_CQBSaveData;
			};

			if (["ALiVE_sys_logistics"] call ALiVE_fnc_isModuleAvailable) then {
			    "Logistics" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save Logistics State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_logisticsSaveData;
			};

			if (["ALiVE_sys_marker"] call ALiVE_fnc_isModuleAvailable) then {
			    "Markers" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save Markers State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_markerSaveData;
			};

			if (["ALiVE_sys_spotrep"] call ALiVE_fnc_isModuleAvailable) then {
			    "SPOTREP" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save SPOTREP State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_spotrepSaveData;
			};

			if (["ALiVE_sys_sitrep"] call ALiVE_fnc_isModuleAvailable) then {
			    "SITREP" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save SITREP State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_sitrepSaveData;
			};

			if (["ALiVE_sys_patrolrep"] call ALiVE_fnc_isModuleAvailable) then {
			    "PATROLREP" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save PATROLREP State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_patrolrepSaveData;
			};

			if (["ALiVE_mil_logistics"] call ALiVE_fnc_isModuleAvailable) then {
			    "ML" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save ML State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_MLSaveData;
			};

			if (["ALiVE_SUP_FOB"] call ALiVE_fnc_isModuleAvailable) then {
			    "Player FOBs" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save Player FOBs"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_fobSaveData;
			};

			if (["ALiVE_SYS_CRATERS"] call ALiVE_fnc_isModuleAvailable) then {
			    "Persistent Craters" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save Persistent Craters"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_cratersSaveData;
			};

			if (["ALiVE_mil_c2istar"] call ALiVE_fnc_isModuleAvailable) then {
			    "Task" call _fnc_stage;
			    ["SYS DATA PNS Autosave - Server Save Task State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_taskHandlerSaveData;
			};

			// The air commander used to be saved only by Save and Exit, so a mission kept by the
			// autosave alone lost every change to its aircraft since the last one. Its save never
			// suspends, so it can run in this block. Only one set to Persistent is saved, and only on
			// a pass that saved the profiles too: the two are loaded together, and an air commander
			// saved after the profiles can bring back twice an aircraft it took over in between, once
			// from its own record and once from the profile the older profile save still holds.
			if (((entities "Module_F") findIf {typeOf _x == "ALiVE_mil_ato" && {[_x, "persistent"] call ALIVE_fnc_ATOKernel}}) > -1) then {
			    if (_profilesSaved) then {
			        "ATO" call _fnc_stage;
			        ["SYS DATA PNS Autosave - Server Save ATO State"] call ALiVE_fnc_dump;
			        // A refused save says why, as Save and Exit shows it on the admin's tablet.
			        {
			            if ((_x find "refused") > -1) then { [_x] call ALiVE_fnc_dump };
			        } forEach (([] call ALiVE_fnc_ATOSaveData) param [1, []]);
			    } else {
			        "ATO skipped" call _fnc_stage;
			        ["SYS DATA PNS Autosave - ATO State not saved on this pass: it's saved with the profiles, and the profile save waits five minutes between saves"] call ALiVE_fnc_dump;
			    };
			};

			"write" call _fnc_stage;
			MOD(PNS_HOLD_FRAME) = -1;
			if (MOD(PNS_HOLD_DIRTY)) then { saveProfileNamespace };
			"" call _fnc_stage;

		} call CBA_fnc_Directcall;
	    ALiVE_profileExportCache = nil;
	    // how long the one-frame save held the server, the file write included, for the RPT and the War Room's Diagnostics
	    private _heldFor = (round ((diag_tickTime - _saveStart) * 100)) / 100;
	    if (isServer && {!isNil "ALiVE_fnc_diagEvent"}) then {
	        ["SYS_DATA", "AUTOSAVE", format ["Saved in %1 s, ms: %2%3%4", _heldFor, _stages joinString ", ", missionNamespace getVariable ["ALiVE_diag_profileSaveSplit", ""], if (_prepared isEqualType 0 && {_prepared > 0}) then { format ["; %1 profiles prepared over %2 s before it", _prepared, (round (_prepTime * 10)) / 10] } else {""}], [0,0]] call ALiVE_fnc_diagEvent;
	    };

	    sleep 0.2;
        ["SAVING FINISHED!"] call ALiVE_fnc_dumpMPH;
        ["SYS DATA PNS Autosave - the save held the server for %1 s, the file write included", _heldFor] call ALiVE_fnc_dump;
	    sleep 2;
	    TitleText ["","PLAIN"];

        if (_once) exitWith {};
    };

    if (_once) exitWith {};

    ["SYS DATA PNS - AutoSave (local) process exiting... (%1)",ALiVE_SYS_DATA_PNS_AUTOSAVE] call ALiVE_fnc_dump;

	terminate ALiVE_SYS_DATA_PNS_AUTOSAVE; ALiVE_SYS_DATA_PNS_AUTOSAVE = nil;
};

if (!_once) then { ALiVE_SYS_DATA_PNS_AUTOSAVE = _handle };