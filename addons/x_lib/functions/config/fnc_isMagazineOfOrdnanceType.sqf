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

private _ordnanceType       = param [0];
private _magazineClassName  = param [1];

private _he_substrings      = ["Mo_shells", "he"];
private _smoke_substrings   = ["Mo_smoke", "wp"];
private _guided_substrings  = ["Mo_guided"];
private _cluster_substrings = ["Mo_Cluster"];
private _laser_substrings   = ["Mo_LG", "laser"];
private _mine_substrings    = ["Mo_Mine"];
private _at_mine_substrings = ["Mo_AT_mine"];
private _rocket_substrings  = ["rockets"];
private _illum_substrings   = ["illum", "flare", "lume"];

/*
unknown substrings for VN:
- ab    (air burst)
- frag  (frag)
- wp    (white phospherous)
- chem  (mustard gas)
*/

private _substrings = switch (_ordnanceType) do {
    case "HE":      { _he_substrings };
    case "SMOKE":   { _smoke_substrings };
    case "SADARM":  { _guided_substrings };
    case "CLUSTER": { _cluster_substrings };
    case "LASER":   { _laser_substrings };
    case "MINE":    { _mine_substrings };
    case "AT MINE": { _at_mine_substrings };
    case "ROCKETS": { _rocket_substrings };
    case "ILLUM":   { _illum_substrings };
    default         { [] };
};

private _found = false;

{
    if (_x in _magazineClassName) exitWith {
        _found = true;
    };
} foreach _substrings;

_found;
