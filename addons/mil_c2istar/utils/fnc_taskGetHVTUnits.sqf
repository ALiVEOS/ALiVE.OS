#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskGetHVTUnits);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_taskGetHVTUnits

Description:
Returns an array of N "Man"-kindOf class names from the supplied faction(s),
preferring units whose classname contains an HVT-grade substring (officer,
commander, leader, captain). Falls back to ALiVE_fnc_chooseRandomUnits if
no candidate matches the HVT keywords - so the caller always gets a class
even on factions that lack named officer variants.

Used by HVT / Assassination tasks (#867) to spawn targets that are visually
distinguishable on sight (officer dress, command insignia) rather than
indistinguishable riflemen the player has to identify by map marker.

Parameters:
ARRAY  - factions (one will be picked at random)
NUMBER - count of class names to return (default 1)
ARRAY  - blacklist of class names to exclude (default [])

Returns:
ARRAY - list of class names, length _count

Examples:
(begin example)
private _hvtClasses = [["OPF_F"], 1, ALiVE_MIL_CQB_UNITBLACKLIST] call ALiVE_fnc_taskGetHVTUnits;
private _hvtClass = _hvtClasses select 0;
(end)

See Also:
- ALiVE_fnc_chooseRandomUnits

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_factions", [], [[]]],
    ["_count", 1, [0]],
    ["_blacklist", [], [[]]]
];

if (_factions isEqualTo []) exitWith { [] };

private _faction = selectRandom _factions;
private _allClasses = [0, _faction, "Man", true] call ALiVE_fnc_findVehicleType;
_allClasses = _allClasses - _blacklist;

// HVT-grade substrings. Matched case-insensitively against the classname.
// "officer" / "commander" / "leader" / "captain" cover the common A3 +
// RHS / CUP / LOP / CDLC naming conventions for command-grade infantry.
// Excluded "general" / "colonel" / "major" - rare in faction CfgVehicles
// and easy to false-positive on classes containing those substrings for
// unrelated reasons.
private _hvtKeywords = ["officer", "commander", "leader", "captain"];

private _candidates = [];
{
    private _classStr = toLower _x;
    {
        if (_classStr find _y >= 0) exitWith {
            _candidates pushBack _x;
        };
    } forEach _hvtKeywords;
} forEach _allClasses;

if (count _candidates == 0) exitWith {
    // No HVT-grade candidates in this faction - fall back to the generic
    // random selection so the task still spawns SOMETHING, just without
    // the visual-priority benefit. Matches pre-#867 behaviour.
    [_factions, _count, _blacklist, true] call ALiVE_fnc_chooseRandomUnits
};

private _result = [];
for "_i" from 1 to _count do {
    _result pushBack (selectRandom _candidates);
};
_result
