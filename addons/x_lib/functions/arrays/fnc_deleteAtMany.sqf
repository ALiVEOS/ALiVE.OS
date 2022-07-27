#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_deleteAtMany

Description:
    Deletes multiple indexes from an array

Parameters:
    0 - Array [array]
    1 - Indexes to remove [array]

Returns:
    none

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    SpyderBlack723
---------------------------------------------------------------------------- */

params ["_array","_indexes"];

_indexes sort false;

{
    _array deleteat _x;
} foreach _indexes;