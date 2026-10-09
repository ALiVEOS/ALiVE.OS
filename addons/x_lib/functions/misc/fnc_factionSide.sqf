#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(factionSide);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_factionSide

Description:
Returns side of given faction (default EAST)

Parameters:
String - faction

Returns:
Side - Side of given faction

Examples:
(begin example)
_side = "OPF_F" call ALiVE_fnc_factionSide;
(end)

See Also:
- nil

Author:
Highhead
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_side"];

private _class = _this call ALiVE_fnc_configGetFactionClass;

// A compiled faction whose name has no faction config of its own (Override mode with a made-up name) takes the side its
// custom mapping names, rather than reading as EAST (F244).
if (!isClass _class && {!isNil "ALiVE_factionCustomMappings"} && {_this isEqualType ""} && {_this in (ALiVE_factionCustomMappings select 1)}) exitWith {
    private _mapped = toUpper ([[ALiVE_factionCustomMappings, _this] call ALiVE_fnc_hashGet, "Side", ""] call ALiVE_fnc_hashGet);
    switch (_mapped) do {
        case "WEST": {WEST};
        case "GUER";
        case "INDEP";
        case "RESISTANCE": {RESISTANCE};
        case "CIV";
        case "CIVILIAN": {CIVILIAN};
        default {EAST};
    };
};

switch (getnumber(_class >> "side")) do {
    case 0 : {_side = EAST};
    case 1 : {_side = WEST};
    case 2 : {_side = RESISTANCE};
    case 3 : {_side = CIVILIAN};
    default {_side = EAST};
};
_side;