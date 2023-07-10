#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isMagazineOfOrdnanceType

Description:
Check if magazine is of ordnance type

Parameters:
String - Ordnance type
String - Magazine classname

Returns:
Boolean

Examples:
(begin example)
private _result = ["HE", _magazineClassName] call ALIVE_fnc_isMagazineOfOrdnanceType;
(end)

See Also:

Author:
marceldev89
---------------------------------------------------------------------------- */

#define HE_SUBSTRINGS      ["Mo_shells", "he", "HE"];
#define SMOKE_SUBSTRINGS   ["Mo_smoke", "smoke", "Smoke","smokeshell","SmokeShell"];
#define PHOS_SUBSTRINGS    ["wp", "WP"];
#define GUIDED_SUBSTRINGS  ["Mo_guided"];
#define CLUSTER_SUBSTRINGS ["Mo_Cluster"];
#define LASER_SUBSTRINGS   ["Mo_LG", "laser"];
#define MINE_SUBSTRINGS    ["Mo_Mine"];
#define AT_MINE_SUBSTRINGS ["Mo_AT_mine"];
#define ROCKET_SUBSTRINGS  ["rockets"];
#define ILLUM_SUBSTRINGS   ["illum", "flare", "lume"];
/*
unknown substrings for VN:
- ab    (air burst)
- frag  (frag)
- wp    (white phospherous)
- chem  (mustard gas)
*/

private _ordnanceType      = param [0];
private _magazineClassName = param [1];

private _substrings = switch (_ordnanceType) do {
    case "HE":      { HE_SUBSTRINGS };
    case "SMOKE":   { SMOKE_SUBSTRINGS };
    case "WP":      { PHOS_SUBSTRINGS };
    case "SADARM":  { GUIDED_SUBSTRINGS };
    case "CLUSTER": { CLUSTER_SUBSTRINGS };
    case "LASER":   { LASER_SUBSTRINGS };
    case "MINE":    { MINE_SUBSTRINGS };
    case "AT MINE": { AT_MINE_SUBSTRINGS };
    case "ROCKETS": { ROCKET_SUBSTRINGS };
    case "ILLUM":   { ILLUM_SUBSTRINGS };
    default         { [] };
};

private _found = false;

{
    if (_x in _magazineClassName) exitWith {
        _found = true;
    };
} foreach _substrings;

_found;
