#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(garrisonAreaBlacklist);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_garrisonAreaBlacklist

Description:
The area markers no garrison may seat men in, for the whole mission.

Every placement module carries a Garrison Area Blacklist setting: marker names, as
the Garrison Building Blacklist takes class names. A building standing in one of the
areas is never used, a static weapon in one is never manned, and a single position in
one is skipped, so a building on the edge of an area keeps the places outside it.
It is for the spots a class blacklist can't reach: the ground under stilt huts, or one
compound where modded buildings trap men, without banning that class across the map.

The names are matched to the mission's markers in any capitalisation, and the answer
is worked out once and kept, as the class blacklist is.

Parameters:
    None.

Returns:
    ARRAY - marker names, as the mission spells them. Empty when no module names an
    area, which is the ordinary case and costs callers nothing.

Examples:
(begin example)
private _areas = call ALIVE_fnc_garrisonAreaBlacklist;
if !(_areas isEqualTo []) then {
    _buildings = _buildings select { private _b = _x; (_areas findIf { _b inArea _x }) < 0 };
};
(end)

See Also:
- <ALIVE_fnc_garrisonBuildingBlacklist>

Author:
Jman
---------------------------------------------------------------------------- */

if !(isNil "ALiVE_garrisonAreaBlacklistCache") exitWith { ALiVE_garrisonAreaBlacklistCache };

private _names = [];
{
    private _raw = _x getVariable ["garrisonAreaBlacklist", ""];
    if (_raw isEqualType "" && {_raw != ""}) then {
        // Commas, semicolons and line breaks separate names, and quotes and brackets are
        // dropped so a copied SQF array pastes unchanged. Spaces are only trimmed, since a
        // marker name may hold one.
        private _text = _raw;
        { _text = (_text splitString _x) joinString ""; } forEach ["[", "]", """", "'"];
        {
            private _n = _x;
            while {count _n > 0 && {(_n select [0, 1]) == " "}} do { _n = _n select [1] };
            while {count _n > 0 && {(_n select [count _n - 1, 1]) == " "}} do { _n = _n select [0, count _n - 1] };
            if (_n != "") then { _names pushBackUnique (toLower _n) };
        } forEach (_text splitString (",;" + toString [9, 10, 13]));
    };
} forEach (entities "Module_F");

private _areas = [];
if !(_names isEqualTo []) then {
    private _byName = createHashMapFromArray (allMapMarkers apply { [toLower _x, _x] });
    private _unknown = [];
    {
        private _m = _byName getOrDefault [_x, ""];
        if (_m == "") then { _unknown pushBack _x } else { _areas pushBackUnique _m };
    } forEach _names;
    ["ALiVE garrisonAreaBlacklist - %1 area(s) no garrison will use: %2", count _areas, _areas] call ALiVE_fnc_dump;
    // Reported once, because a name with no marker behind it excludes nothing and
    // reads to the author as a setting that did not work.
    if !(_unknown isEqualTo []) then {
        ["ALiVE garrisonAreaBlacklist - no marker is called %1, so nothing is kept out there", _unknown] call ALiVE_fnc_dump;
    };
    private _points = _areas select { !((markerShape _x) in ["RECTANGLE", "ELLIPSE"]) };
    if !(_points isEqualTo []) then {
        ["ALiVE garrisonAreaBlacklist - %1 are not area markers (rectangle or ellipse), so they cover no ground", _points] call ALiVE_fnc_dump;
    };
};

ALiVE_garrisonAreaBlacklistCache = _areas;
_areas
