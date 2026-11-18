#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenModCpp);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenModCpp

Description:
The mod.cpp of an exported faction: name, author and the faction flag by its
in-game path (a .paa cannot be copied by the extension), shown in the game's
own mod list.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan
    _faction - HASHMAP - the snapshot

Returns:
    ARRAY - lines

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]]];

private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _name = _faction getOrDefault ["name", _plan get "tag"];
private _flag = (_faction getOrDefault ["flag", ""]) call _q;
[
    "name = " + (_name call _q) + ";",
    "author = " + ((_faction getOrDefault ["author", ""]) call _q) + ";",
    "picture = " + _flag + ";",
    "logo = " + _flag + ";",
    "logoOver = " + _flag + ";",
    "tooltip = " + (_name call _q) + ";",
    "overview = " + ((_name + ": a faction for Arma 3. Needs CBA_A3.") call _q) + ";",
    "hideName = 0;",
    "hidePicture = 0;"
]
