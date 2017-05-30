/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_nearShip

Description:
    Checks to see if a unit is near a ship (within 700m)

Parameters:
    ARRAY - Position

Returns:
    BOOL - True or False

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Tupolov
---------------------------------------------------------------------------- */


params [
    ["_position", [], [[]]]
];

if (count _position == 2) then {_position set [2,0];};

private _result = count ((AGLtoASL _position) nearObjects ["StaticShip",700]) != 0;

_result