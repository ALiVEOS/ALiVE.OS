/*
 * Filename:
 * fnc_stats_onPlayerDisconnected.sqf
 *
 * Description:
 * handled onPlayerDisconnected event for sys_statistics, saving player data when they disconnect
 *
 * Created by Tupolov
 * Jman
 * Creation date: 06/07/2013
 *
 * */

// ====================================================================================
// MAIN

#include "script_component.hpp"

if (GVAR(ENABLED)) then {
    private ["_class","_puid","_PlayerSide","_PlayerFaction","_startTime","_endTime","_minutesPlayed","_data","_shotsFired","_shotsFiredData","_unit","_playerType","_score","_rating","_id","_uid","_name","_rank"];

    _unit = objNull;

    TRACE_1("STATS PLAYER DISCONNECT", _this);

    _id = _this select 0;
    _name = _this select 1;
    _uid = _this select 2;

    // diag_log [str(_id), _name, _uid];

    if (_name == "__SERVER__") exitWith {

        // _minutesPlayed = floor(( (dateToNumber date) - ( dateToNumber GVAR(timeStarted)) ) * 525600);
        _minutesPlayed = round(( diag_tickTime - GVAR(timeStarted))/60);


            // Format Data
            _data = [ ["Event","OperationFinish"] , ["timePlayed", _minutesPlayed] ];

            // Send Data
            GVAR(UPDATE_EVENTS) = _data;
            publicVariableServer QGVAR(UPDATE_EVENTS);

    };

    // Cater for non player situations
    if (_uid == "" || isHC) exitWith {
        diag_log["SYS_STATS: PLAYER DOES NOT HAVE UID OR IS HEADLESS, EXITING."];
    };

    // One PlayerFinish per player per session. The Abort button sends it, and the server's own disconnect
    // handler sends it for a player who left any other way (crash, time-out, kick), so the second caller
    // finds it already claimed. Joining again clears the claim (fnc_stats_onPlayerConnected).
    if (!isNil QGVAR(playerFinished)) then {
        if ([GVAR(playerFinished), _uid, false] call ALIVE_fnc_hashGet) exitWith { _uid = "" };
        [GVAR(playerFinished), _uid, true] call ALIVE_fnc_hashSet;
    };
    if (_uid == "") exitWith {};

    {
        if (getPlayerUID _x == _uid) exitwith {
            diag_log[format["SYS_STATS: PLAYER UNIT FOUND IN PLAYABLEUNITS (%1)",_x]];
            _unit = _x;
        };
    } foreach playableUnits;

    // Minutes from when this player joined, whichever way they left
    private _playertime = [GVAR(PlayerStartTime), _uid, GVAR(timeStarted)] call ALIVE_fnc_hashGet;
    _minutesPlayed = round((diag_tickTime - _playertime)/60);

    private _group = "";
    if (isNull _unit) then {
        diag_log["SYS_STATS: PLAYER UNIT NOT FOUND IN PLAYABLEUNITS"];

        // Gone already (they crashed, timed out or were kicked): use what the server last saw of them,
        // refreshed every minute by fnc_statisticsInit
        private _seen = if (isNil QGVAR(playerSeen)) then {[]} else {[GVAR(playerSeen), _uid, []] call ALIVE_fnc_hashGet};
        _class = _seen param [0, "Unknown"];
        _PlayerSide = _seen param [1, "Unknown"];
        _PlayerFaction = _seen param [2, "Unknown"];
        _playerType = _seen param [3, "Unknown"];
        _score = _seen param [4, 0];
        _rating = _seen param [5, 0];
        _rank = _seen param [6, "PRIVATE"];
        _group = _seen param [7, ""];

    } else {

        _class = getText (configFile >> "cfgVehicles" >> (typeof _unit) >> "displayName");
        _PlayerSide = side (group _unit); // group side is more reliable
        _PlayerFaction = faction _unit;
        _playerType = typeof _unit;

        // Get score, rating and rank
        _score = score _unit;
        _rating = rating _unit;
        _rank = rank _unit;
    };
    if (_group isEqualTo "") then { _group = [_unit] call ALiVE_fnc_getPlayerGroup };

    // Shots fired. The Abort button sends the player's counts just before this runs, so wait briefly for
    // them; a player who left any other way has the counts their machine sent every minute.
    _waitTime = diag_tickTime + ([0, 30] select (!isNull _unit));
    waitUntil {_shotsfired = [GVAR(shotsFired), _uid, []] call ALiVE_fnc_hashGet; count _shotsfired > 0 || {diag_tickTime >= _waitTime} || {sleep 1; false}};

    _shotsFiredData = [];
    if (count _shotsfired > 0) then {
        ["Saving shots fired: %1", _shotsfired] call ALiVE_fnc_dump;
        {
            private ["_shotsFiredHash"];
            if (typename _x == "ARRAY") then {
                _shotsFiredHash = [] call CBA_fnc_hashCreate;
                [_shotsFiredHash, "weaponMuzzle", _x select 0] call CBA_fnc_hashSet;
                [_shotsFiredHash, "count", _x select 1] call CBA_fnc_hashSet;
                [_shotsFiredHash, "weaponType", _x select 2] call CBA_fnc_hashSet;
                [_shotsFiredHash, "weaponName", _x select 3] call CBA_fnc_hashSet;
                _shotsFiredData pushback _shotsFiredHash ;
            };
        } foreach _shotsFired;
    };

    // Format Data
    _data = [ ["Event","PlayerFinish"] , ["PlayerSide",_PlayerSide] , ["PlayerFaction",_PlayerFaction] , ["PlayerName",_name] , ["PlayerType",_PlayerType] , ["PlayerClass",_class] , ["RoleKind", _PlayerType call GVAR(fnc_roleKind)] , ["Player", _uid] , ["shotsFired", _shotsFiredData] , ["timePlayed",_minutesPlayed], ["score",_score], ["rating",_rating], ["PlayerRank",_rank], ["playerGroup", _group] ];

    // Send Data
    GVAR(UPDATE_EVENTS) = _data;
    publicVariableServer QGVAR(UPDATE_EVENTS);

};

// ====================================================================================