#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(anyAutonomousInRange);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_anyAutonomousInRange

Description:
Return the number of UAV/UGV units within range of a position

Parameters:
Array - Position measuring from
Number - Distance being measured (optional)

Returns:
Number - Returns number of UAV/UGV units within range

Examples:
(begin example)
// No players in range
([_pos, 2500] call fnc_anyAutonomousInRange == 0)
(end)

Author:
Raptor

Peer Reviewed:
Wolffy 20131117
---------------------------------------------------------------------------- */

private ["_pos","_dist"];
PARAMS_1(_pos);
DEFAULT_PARAM(1,_dist,2500);

// checks to see if there are any autonomous units (UAVs/UGVs) near pos and distance
({_pos distance _x < (_dist + 800) && isUavConnected _x} count allUnitsUav);
