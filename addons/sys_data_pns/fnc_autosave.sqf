#include "script_component.hpp"
SCRIPT(AUTOSAVE_PNS);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_AUTOSAVE_PNS

Description:
Saves mission state to PNS in given interval!
!! Health Warning: This function is writing to file (freeze for about 2 seconds). Will cause desync and lag in MP !!

Parameters:
Number - Interval to save in seconds

Returns:
nothing (nil)

Examples:
(begin example)
    // Will save every 15 minutes
    900 call ALiVE_fnc_AUTOSAVE_PNS
(end)

Author:
Highhead
Peer Reviewed:

---------------------------------------------------------------------------- */

private _interval = if (isNil "_this") then {-1} else {_this};

if !(isServer && {!isNil "ALiVE_SYS_DATA_SOURCE"} && {ALiVE_SYS_DATA_SOURCE == "pns"}) exitWith {["SYS DATA PNS - Local machine is not the server or local save not available! Exiting..."] call ALiVE_fnc_dump};

if (!isNil "ALiVE_SYS_DATA_PNS_AUTOSAVE") then {terminate ALiVE_SYS_DATA_PNS_AUTOSAVE};

ALiVE_SYS_DATA_PNS_AUTOSAVE = _interval spawn {

    private _interval = _this;

    while {_interval > 0} do {

        sleep _interval;

	    sleep 5;
	    TitleText ["ALiVE IS PREPARING TO SAVE...","PLAIN"];
	    sleep 1;
        ["IS SAVING..."] call ALiVE_fnc_dumpMPH;
        sleep 1;
	    TitleText ["ALiVE IS SAVING...","PLAIN"];
	    sleep 1;

	    {
			// Save player state player in SP or hosted
			if (hasInterface) then {
			    private ["_name","_uid","_id"];

			    _id = player;
			    _name = name player;
			    _uid = getPlayerUID player;

			    if !(isNil "ALiVE_sys_player") then {
                    ["SYS DATA PNS Autosave - Save Player Data id: %1 name: %2 uid: %3",_id,_name,_uid] call ALiVE_fnc_dump;

                    ["SYS DATA PNS Autosave - Player Data OPD"] call ALiVE_fnc_dump;

			         if (ALiVE_sys_player getvariable "saveLoadout") then {
			                private ["_gearHash","_unit"];

                            ["SYS DATA PNS Autosave - Storing Player Gear"] call ALiVE_fnc_dump;

			                _gearHash = [ALiVE_sys_player, "setGear", [player]] call ALIVE_fnc_player;
			                [ALiVE_sys_player, "updateGear", [player, _gearHash]] call ALiVE_fnc_player;
			        };
			        [_id, _name, _uid] call ALIVE_fnc_player_onPlayerDisconnected;
			    };

				if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {

					["SYS DATA PNS Autosave - Player Profile Handler OPD"] call ALiVE_fnc_dump;
					[_id, _name, _uid] call ALIVE_fnc_profile_onPlayerDisconnected;
				};
	        };

            // Save mission state data

            _uid = "";
    		_id = "";

			if !(isNil "ALiVE_sys_data") then {
			    ["SYS DATA PNS Autosave - Server Data OPD"] call ALiVE_fnc_dump;
			    [_id, "__SERVER__", _uid] call ALIVE_fnc_data_onPlayerDisconnected;
			};

			if !(isNil "ALiVE_sys_player") then {
			    ["SYS DATA PNS Autosave - Server Player OPD"] call ALiVE_fnc_dump;
			    [_id, "__SERVER__", _uid] call ALIVE_fnc_player_onPlayerDisconnected;
			};

			if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save Profiles"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_profilesSaveData;
			};

			if (["ALiVE_mil_OPCOM"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save OPCOM State"] call ALiVE_fnc_dump;
			    _results = [] call ALiVE_fnc_OPCOMSaveData;
			};

			if (["ALiVE_mil_IED"] call ALiVE_fnc_isModuleAvailable) then {
				["ALiVE SYS DATA PNS Autosave - Server Save IED State"] call ALIVE_fnc_dump;
				[] call ALiVE_fnc_IEDSaveData;
			};

			if (["ALiVE_mil_cqb"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save CQB State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_CQBSaveData;
			};

			if (["ALiVE_sys_logistics"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save Logistics State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_logisticsSaveData;
			};

			if (["ALiVE_sys_marker"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save Markers State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_markerSaveData;
			};

			if (["ALiVE_sys_spotrep"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save SPOTREP State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_spotrepSaveData;
			};

			if (["ALiVE_sys_sitrep"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save SITREP State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_sitrepSaveData;
			};

			if (["ALiVE_sys_patrolrep"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save PATROLREP State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_patrolrepSaveData;
			};

			if (["ALiVE_mil_logistics"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save ML State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_MLSaveData;
			};

			if (["ALiVE_mil_C2ISTAR"] call ALiVE_fnc_isModuleAvailable) then {
			    ["SYS DATA PNS Autosave - Server Save Task State"] call ALiVE_fnc_dump;
			    [] call ALiVE_fnc_taskHandlerSaveData;
			};

		} call CBA_fnc_Directcall;

	    sleep 0.2;
        ["SAVING FINISHED!"] call ALiVE_fnc_dumpMPH;
	    sleep 2;
	    TitleText ["","PLAIN"];
    };

    ["SYS DATA PNS - AutoSave (local) process exiting... (%1)",ALiVE_SYS_DATA_PNS_AUTOSAVE] call ALiVE_fnc_dump;

	terminate ALiVE_SYS_DATA_PNS_AUTOSAVE; ALiVE_SYS_DATA_PNS_AUTOSAVE = nil;
};