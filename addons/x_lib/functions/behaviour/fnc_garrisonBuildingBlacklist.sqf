#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(garrisonBuildingBlacklist);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_garrisonBuildingBlacklist

Description:
The building classes no garrison may seat men in, for the whole mission, folded to
lower case.

Two sources are merged. Every placement module carries a Garrison Building Blacklist
setting, and the mission may also set ALIVE_Building_Blacklist from its init.sqf, which
is how this was done before there was a setting and which fnc_isHouseEnterable has
always read. Both keep working, and a class named in either is refused everywhere
rather than only in the house sweep it used to reach.

The answer cannot change after mission start, so it is worked out once and kept. Every
garrison would otherwise sweep the entity list again.

Classnames are case insensitive everywhere else in Arma, and "in" on an array of strings
is not, so everything is folded on the way in and every caller folds the name it tests.

Parameters:
    None.

Returns:
    ARRAY - lower-cased classnames. Empty when nothing anywhere excluded a class, which
    is the ordinary case and costs callers nothing.

Examples:
(begin example)
private _blacklist = call ALIVE_fnc_garrisonBuildingBlacklist;
if !(_blacklist isEqualTo []) then {
    _buildings = _buildings select { !((toLower typeOf _x) in _blacklist) };
};
(end)

See Also:
- <ALIVE_fnc_resolvePreferredGarrisonPositions>

Author:
Jman
---------------------------------------------------------------------------- */

if !(isNil "ALiVE_garrisonBuildingBlacklistCache") exitWith { ALiVE_garrisonBuildingBlacklistCache };

private _classes = [];

private _fnc_add = {
    params ["_raw"];
    if (!(_raw isEqualType "") || {_raw isEqualTo ""}) exitWith {};

    // The setting is a multi-line Eden field, so a line break is as likely a separator
    // as the documented semicolon, and pasted text can carry tabs and carriage returns.
    // A comma is accepted too, because the class picker renders a comma separated list
    // and pasting it unchanged is the obvious thing to try.
    private _text = (_raw splitString toString [9]) joinString " ";
    _text = (_text splitString toString [13,10]) joinString ";";
    _text = (_text splitString ",") joinString ";";

    {
        private _entry = _x;
        // Square brackets and quotes so a copied SQF array pastes unchanged.
        { _entry = (_entry splitString _x) joinString ""; } forEach ["[", "]", """", "'"];
        while {count _entry > 0 && {(_entry select [0, 1]) == " "}} do { _entry = _entry select [1] };
        while {count _entry > 0 && {(_entry select [count _entry - 1, 1]) == " "}} do { _entry = _entry select [0, count _entry - 1] };
        if (_entry != "") then { _classes pushBackUnique (toLower _entry) };
    } forEach ([_text, ";"] call CBA_fnc_split);
};

// Eden writes each module's setting onto the module logic at mission load, so the
// modules are read directly rather than made to announce themselves. That also picks
// up any module that gains the attribute later without this needing to know about it.
{
    [_x getVariable ["garrisonBuildingBlacklist", ""]] call _fnc_add;
} forEach (entities "Module_F");

// The older init.sqf variable. It was only ever consulted by the house test, so a
// mission already using it now gets the curated props and the listed tier as well.
private _legacy = missionNamespace getVariable ["ALIVE_Building_Blacklist", []];
if (_legacy isEqualType []) then {
    { [_x] call _fnc_add; } forEach _legacy;
};

// Reported once, because a class that exists nowhere in the mission's mods excludes
// nothing and reads to the author as a setting that did not work.
if !(_classes isEqualTo []) then {
    private _unknown = _classes select { !(isClass (configFile >> "CfgVehicles" >> _x)) };
    ["ALiVE garrisonBuildingBlacklist - %1 class(es) excluded from every garrison: %2", count _classes, _classes] call ALiVE_fnc_dump;
    if !(_unknown isEqualTo []) then {
        ["ALiVE garrisonBuildingBlacklist - %1 of them do not exist in CfgVehicles and will exclude nothing: %2", count _unknown, _unknown] call ALiVE_fnc_dump;
    };
};

ALiVE_garrisonBuildingBlacklistCache = _classes;
_classes
