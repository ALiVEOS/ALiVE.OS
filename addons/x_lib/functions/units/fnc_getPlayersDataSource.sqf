#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getPlayersDataSource);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getPlayersDataSource

Description:
Get current players info formatted for a UI datasource

Parameters:


Returns:
Array - Multi dimensional array of values and options

Examples:
(begin example)
_datasource = call ALiVE_fnc_getPlayersDataSource
(end)

Author:
ARJay
 
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_side","_sideNumber","_playerSide","_playerSideNumber","_data","_options","_values"];

_side = _this select 0;

_sideNumber = [_side] call ALIVE_fnc_sideTextToNumber;
_data = [];
_options = [];
_values = [];

{
    if !(isnull _x) then {
	    _playerSide = (faction _x) call ALiVE_fnc_FactionSide;
	    _playerSideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
	    if(_sideNumber == _playerSideNumber) then {
	        _options pushback (format["%1 - %2",name _x, group _x]);
	        _values pushback (getPlayerUID _x);
	    };
    };
} foreach allPlayers;

_data set [0,_options];
_data set [1,_values];

_data
