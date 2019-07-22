#include "\x\ALiVE\addons\x_lib\script_component.hpp"
SCRIPT(sideTextToColor);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_sideTextToColor

Description:
Returns a color string based based on the passed side string

Parameters:
Side - string

Returns:
String - color string

Examples:
(begin example)
//
_result = ["WEST"] call ALiVE_fnc_sideTextToColor;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private _side = _this;

switch (tolower _side) do {
    case "east" :   { "ColorEAST" };
    case "west" :   { "ColorWEST" };
    case "guer" :   { "ColorGUER" };
    case "civilian";
    case "civ":     { "ColorCIV" };

    default         { "ColorCIV" };
};