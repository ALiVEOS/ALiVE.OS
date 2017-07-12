#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_sideToSideText

Description:
    Converts a side to ARMA 3 side text.

Parameters:
    0 - Side [side]

Returns:
    Side name [string]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Naught
---------------------------------------------------------------------------- */

switch (_this select 0) do {
    case WEST: {'WEST'};
    case EAST: {'EAST'};
    case RESISTANCE: {'GUER'};
    case CIVILIAN: {'CIV'};
    case default {'NULL'};
};
