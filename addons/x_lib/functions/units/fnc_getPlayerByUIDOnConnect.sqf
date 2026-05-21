#include "\x\alive\addons\x_lib\script_component.hpp"
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
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_playerUID","_unit","_time"];

_playerUID = _this select 0;
_unit = objNull;

if (_playerUID == "") exitWith {["Null playerUID sent to getPlayerByUIDOnConnect"] call ALiVE_fnc_dump; _unit};

//Is there a special need for a delayed execution (why not only use foreach)?
//Causes script to hang and never finish under some circumstances (like HC usage).
//Workaround, to not potentially impact current func. -> timeout of 5 seconds
_time = time;
waitUntil {
    sleep 0.3;

    private ["_found","_player","_currentUID"];

    _found = false;
    private _timeout = time - _time > 5;

    {
        _player = _x;
        _currentUID = getPlayerUID _player;

        if (_currentUID == _playerUID) exitwith {
            _unit = _player;
            _found = true;
        };
    } foreach (playableunits + switchableUnits);

    _found || {_timeout};
};

// Inferno #894: if the primary playableUnits + switchableUnits search
// timed out, fall back to allPlayers (network-wide player object list)
// before returning objNull. On busy server boots the connecting player
// can be in allPlayers before their slot has settled into playableUnits;
// the original code logged "NOT FOUND" and gave up here, leaving the
// player at default spawn with no save applied. Single forEach is fine
// once the timeout is reached -- we're past the polling phase.
if (isNull _unit) then {
    {
        if (getPlayerUID _x == _playerUID) exitWith {
            _unit = _x;
        };
    } foreach allPlayers;
};

_unit