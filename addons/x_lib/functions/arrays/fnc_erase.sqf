#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_erase

Description:
    Erases a value from an array (preserves order).

Parameters:
    0 - Array [array]
    1 - Index to erase [number]

Returns:
    Array copy [array]

Attributes:
    N/A

Examples:
    N/A

See Also:
    - <ALiVE_fnc_uErase>
    - <ALiVE_fnc_oErase>

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

params [["_arr", [], [[]]], ["_idx", -1, [0]]];
WARNING("ALiVE_fnc_erase - This function has been deprecated. Please use the deleteAt command instead.");
_arr deleteAt _idx;
_arr
