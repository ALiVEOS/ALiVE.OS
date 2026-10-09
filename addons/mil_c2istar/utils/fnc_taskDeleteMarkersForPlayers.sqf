#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskDeleteMarkersForPlayers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskDeleteMarkersForPlayers

Description:
Mark a position for players

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_taskPosition","_taskSide","_taskType","_colour","_markerDefinition","_player"];

params [
    ["_taskPlayers", []],
    ["_taskID", "", [""]]
];

{
    _player = [_x] call ALIVE_fnc_getPlayerByUID;

    if !(isNull _player) then {
        // the player's own machine removes them: on a hosted game the host is not every player
        if !(local _player) then {
            [[_taskID],"ALIVE_fnc_taskDeleteMarkers",_player,false,false] spawn BIS_fnc_MP;
        }else{
            [_taskID] call ALIVE_fnc_taskDeleteMarkers;
        };
    };

} forEach _taskPlayers;