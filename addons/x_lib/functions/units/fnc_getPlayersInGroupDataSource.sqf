#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getPlayersInGroupDataSource);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getPlayersInGroupDataSource

Description:
Get players in the passed players group info formatted for a UI datasource

Parameters:
STRING - player UID


Returns:
Array - Multi dimensional array of values and options

Examples:
(begin example)
_datasource = [_playerUID] call ALiVE_fnc_getPlayersInGroupDataSource
(end)

Author:
ARJay
 
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_playerUID","_data","_options","_values","_group"];

_playerUID = _this select 0;

_data = [];
_options = [];
_values = [];

scopeName "main";

{
    if(_playerUID == getPlayerUID _x) then {
        _group = group _x;
        breakTo "main";
    };
} foreach allPlayers;

if!(isNil "_group") then {
    {
        if(isPlayer _x) then {
            _options pushback (format["%1 - %2",name _x, group _x]);
            _values pushback (getPlayerUID _x);
        };
    } foreach (units _group);
};

_data set [0,_options];
_data set [1,_values];

_data
