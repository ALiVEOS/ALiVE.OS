#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(anyPlayersInRange);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_anyPlayersInRange

Description:
Return the number of players within range of a position

Parameters:
Array - Position measuring from
Number - Distance being measured (optional)

Returns:
Number - Returns number of players within range

Examples:
(begin example)
// No players in range
([_pos, 2500] call ALiVE_fnc_anyPlayersInRange == 0)
(end)

Author:
Wolffy.au
 
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_pos","_dist"];
PARAMS_1(_pos);
DEFAULT_PARAM(1,_dist,2500);

// That code that checks if any players are in range
({_pos distance _x < _dist} count allPlayers);
