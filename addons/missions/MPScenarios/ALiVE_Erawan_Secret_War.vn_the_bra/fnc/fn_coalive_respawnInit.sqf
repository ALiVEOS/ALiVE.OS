/*
    Original Author: Wyqer, veteran29
    Date: 2019-07-21

    Description:
        Server side respawn initialization.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

[] call vn_ms_fnc_persistentPlayerGroups;

if (isServer) then {

    // Add playable groups to respawn
    [vn_alivegrp_alpha_1] call vn_ms_fnc_respawn_addGroup;


    // Throw out bodies of disconnecting pilots and gunners to prevent respawn issues
    addMissionEventHandler ["HandleDisconnect", {
        params ["_unit"];

        if (_unit distance2d (markerPos "respawn_west") < 500) exitWith {
            deleteVehicle _unit;
        };

        private _vehicle = vehicle _unit;
        if !(_vehicle in vn_ms_respawnVehicles) exitWith {};
        if ((_vehicle getCargoIndex _unit) != -1) exitWith {};

        moveOut _unit;
    }];

    [] spawn {
        scriptName "vn_ms_respawnMarkerHideLoop";
        // Some better way?
        while {true} do {
            [] call vn_ms_fnc_hideRespawnMarkers;
            uiSleep 30;
        };
    };
};

// Save custom loadout without showing a hint
[player, false] call vn_ms_fnc_respawn_saveLoadout;

true
