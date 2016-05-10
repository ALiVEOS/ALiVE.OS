#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profile_onPlayerDisconnected);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profile_onPlayerDisconnected

Description:
Profile system on player disconnected event handler

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

//["ALIVE DISCONNECT: uid:%1",_uid] call ALIVE_fnc_dump;
["DISCONNECT",_uid] call ALIVE_fnc_createProfilesFromPlayers;