#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getPlayerByUIDOnConnect);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getPlayerByUIDOnConnect

Description:
Get a player object by UID, specifically for on player connect

Parameters:
STRING - UID

Returns:
Object - Player object

Examples:
(begin example)
_player = ["234234"] call ALiVE_fnc_getPlayerByUIDOnConnect
(end)

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_playerUID","_unit","_time"];

_playerUID = _this select 0;
_unit = objNull;

if (_playerUID == "") exitWith {diag_log "Null playerUID sent to getPlayerByUIDOnConnect"; _unit};

//Is there a special need for a delayed execution (why not only use foreach)?
//Causes script to hang and never finish under some circumstances (like HC usage).
//Workaround, to not potentially impact current func. -> timeout of 5 seconds
_time = time;
waitUntil {
    sleep 0.3;

    private ["_found","_player","_playerGUID","_currentUID"];

    _found = false;
    _timeout = time - _time > 5;

    {
        _player = _x;
        _currentUID = getPlayerUID _player;

        if (_currentUID == _playerUID) exitwith {
            _unit = _player;
            _found = true;
        };
    } foreach playableUnits;

    _found || {_timeout};
};

_unit