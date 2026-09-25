#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(radioBroadcastToSide);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_radioBroadcastToSide

Description:
Broadcast radio messages including to all friendly sides, with HQ is desired
Each player on the side is told once, on their own machine, from whichever machine this runs on.
Off the server that means remote execution from a client, so a mission that limits remoteExec
with CfgRemoteExec must allow ALIVE_fnc_radioBroadcast.

Parameters:
String - side
Array - the message in format for ALIVE_fnc_radioBroadcast

Returns:

Examples:
(begin example)

// send a message to all BLUFOR players from HQ
_radioBroadcast = [player,"Hello World","side",WEST,false,false,false,true,"HQ"];
["WEST",_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;

(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */
private ["_side","_radioBroadcast","_sideNumber","_playerSide","_playerSideNumber"];

_side = _this select 0;
_radioBroadcast = _this select 1;

_sideNumber = [_side] call ALIVE_fnc_sideTextToNumber;

{
    _playerSide = side group _x;
    _playerSideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
    if(_sideNumber == _playerSideNumber) then {
        // Each player is told once, on their own machine, wherever this runs. Testing for a
        // dedicated server instead showed a host, a headless client or a player's own machine
        // the message once per friendly player and sent it to nobody else.
        if(local _x) then {
            _radioBroadcast call ALIVE_fnc_radioBroadcast;
        }else{
            _radioBroadcast remoteExec ["ALIVE_fnc_radioBroadcast",_x];
        };
    };
} foreach allPlayers;
