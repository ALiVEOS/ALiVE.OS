#include "script_component.hpp"
/*
 * Filename:
 * fnc_stats_onPlayerConnected.sqf
 *
 * Description:
 * handled onPlayerConnected event for sys_statistics, reading player stats profile
 *
 * Created by Tupolov
 * Creation date: 06/07/2013
 * Jman
 *
 * */

// ====================================================================================
// MAIN

if (GVAR(ENABLED) && isDedicated) then {

    private _unit = objNull;
    private _module = "players";

    TRACE_1("STATS PLAYER CONNECT", _this);

    private _id = _this select 0;
    private _name = _this select 1;
    private _uid = _this select 2;

    if (_name == "__SERVER__" || _uid == "") exitWith {};

    [_uid, _module] spawn {

        private _uid = _this select 0;
        private _module = _this select 1;
        private _unit = [_uid] call ALIVE_fnc_getPlayerByUIDOnConnect;
        private _owner = owner _unit;

        if (isNull _unit) then {
            diag_log["SYS_STATS: PLAYER UNIT NOT FOUND IN PLAYABLEUNITS"];

            /// Hmmmm connecting player isn't found...
        } else {

            // Set player startTime
            [GVAR(PlayerStartTime), getPlayerUID _unit, diag_tickTime] call ALIVE_fnc_hashSet;

            // A player joining again gets a fresh PlayerFinish record when they next leave
            if (!isNil QGVAR(playerFinished)) then { [GVAR(playerFinished), getPlayerUID _unit, false] call ALIVE_fnc_hashSet };

            // Add an EH for your player object on everyone's locality - (Thanks BIS!)
            // Call is persistent so that all players are synced to any JIPs
            [[_unit], "ALIVE_fnc_addHandleHeal", true, true, true] spawn BIS_fnc_MP;
        };
    };

};

// ====================================================================================

