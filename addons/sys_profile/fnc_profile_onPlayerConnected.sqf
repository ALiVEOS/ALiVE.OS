#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profile_onPlayerConnected);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profile_onPlayerConnected

Description:
Profile system on player connected event handler

Parameters:

Returns:

Examples:
(begin example)
// on player connected event handler
[] call ALIVE_fnc_profile_onPlayerConnected;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_id","_name","_uid"];

_id = _this select 0;
_name = _this select 1;
_uid = _this select 2;

if (_name == "__SERVER__" || _uid == "") exitWith {};

if(isServer) then {

    [_uid] spawn {

        private ["_uid","_unit","_player","_playerGUID"];

        _uid = _this select 0;

        _unit = [_uid] call ALIVE_fnc_getPlayerByUIDOnConnect;

        if !(isNull _unit) then {
            //["ALIVE CONNECT: uid:%1",_uid] call ALIVE_fnc_dump;
            ["CONNECT",_uid,_unit] call ALIVE_fnc_createProfilesFromPlayers;
        };
    };
};