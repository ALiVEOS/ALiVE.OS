/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playerHasAccessItems

Description:
Shared access-item gate for the player-facing tablet/menu modules (C2ISTAR,
Combat Support, Player Combat Logistics). Answers "does the player carry any
of the configured access items?" with one pool and one matcher, so every
entry point (CBA flexiMenu, C2ISTAR tablet menu, ACE self-interaction) agrees.

The first parameter is a CSV mixing CATEGORY KEYS from the shared equipment
registry CfgALiVEC2ISTARAccessItems (e.g. "LaserDesignators,Radios") and/or
raw item classnames (legacy single-classname saves keep working). Category
keys expand to their classnames[]; unmatched tokens pass through as literal
classnames. The second parameter is the module's free-text "Custom ... Items
(classnames)" CSV. Matching is case-insensitive substring over the player's
assigned items, uniform/vest/backpack contents and the backpack classname
itself - partial classnames match by design (back-compat).

Parameters:
0: STRING - CSV of category keys and/or item classnames
1: STRING - CSV of additional raw classnames (custom field), "" for none
2: ARRAY  - extra tokens always accepted (e.g. ["ALIVE_Tablet"]), [] for none
3: OBJECT - the unit to ask about (default player); any machine can ask about any unit
4: BOOL   - whether a command post counts (default true); false asks about carried items only

Returns:
BOOL - true when the player carries at least one matching item, or stands at a command post
(an object with ALiVE_accessPoint set: true for 10 m, or a radius in metres; or an object of one
of C2ISTAR's Command Point Classes, within its Command Point Radius)

Examples:
(begin example)
_hasAccess = ["LaserDesignators,Radios", "MyMod_Tablet", ["ALIVE_Tablet"]] call ALIVE_fnc_playerHasAccessItems;
(end)

Author: Jman
---------------------------------------------------------------------------- */

params [["_itemsCsv", "", [""]], ["_customCsv", "", [""]], ["_extraTokens", [], [[]]], ["_unit", objNull, [objNull]], ["_posts", true, [true]]];
if (isNull _unit) then { _unit = player };
if (isNull _unit) exitWith { false };

// A command post: standing near an object the mission marked as one counts as carrying the items, so
// commanding can be done from an HQ map board rather than a carried tablet (AshTray on Discord, 16 Oct).
// Mark it in its init with  this setVariable ["ALiVE_accessPoint", true, true];  for 10 m, or a number
// for that many metres. For HQ-only commanding, set the access items to something players don't carry.
// C2ISTAR's Command Point Classes make every object of those classes (or a class inheriting from one) a
// command post within Command Point Radius, however it got there: Eden, Zeus, a script or a FOB (A. Ares
// on Discord, 17 Oct). An object's own ALiVE_accessPoint still wins, so a script can widen or switch one off.
// The engine finds the objects of each class (and its children) within the radius, so the ACE menus, which
// ask every frame they're open, never loop over a town's worth of objects. The player's own unit is never one.
// A Logistics Hub asks with _posts false: its Players Carrying an Access Item rule is about what's carried.
private _atPost = _posts && {
    private _post = (_unit nearObjects 50) findIf {
        private _r = _x getVariable ["ALiVE_accessPoint", false];
        if (_r isEqualType true) then { _r = [0, 10] select _r };
        _r isEqualType 0 && {_r > 0} && {(_unit distance _x) <= _r}
    };
    _post > -1 || {
        private _classes = missionNamespace getVariable ["ALiVE_accessPointClasses", []];
        private _classRadius = missionNamespace getVariable ["ALiVE_accessPointRadius", 10];
        _classes findIf {
            ((_unit nearObjects [_x, _classRadius]) findIf { _x != _unit && {isNil {_x getVariable "ALiVE_accessPoint"}} }) > -1
        } > -1
    }
};
if (_atPost) exitWith { true };

private _tokens = _itemsCsv call ALiVE_fnc_stringListToArray;
{ _tokens pushBack _x } forEach _extraTokens;

if (_customCsv isEqualType "" && {_customCsv != ""}) then {
    {
        // stringListToArray already strips spaces, but defensive-trim in case
        // the value arrived via a path that preserves them ("A, B, C")
        private _trimmed = _x;
        while {_trimmed select [0,1] == " "} do { _trimmed = _trimmed select [1] };
        while {count _trimmed > 0 && {_trimmed select [count _trimmed - 1, 1] == " "}} do {
            _trimmed = _trimmed select [0, count _trimmed - 1];
        };
        if (_trimmed != "") then { _tokens pushBack _trimmed };
    } forEach (_customCsv call ALiVE_fnc_stringListToArray);
};

_tokens = _tokens apply {toLower _x};
_tokens = _tokens select { _x != "" };   // an empty token would substring-match everything

// expand category keys to their classnames[]; unmatched tokens stay as-is so
// a legacy raw-classname value (e.g. "LaserDesignator" from an old mission
// save) still gates correctly
private _expanded = [];
{
    private _tok = _x;
    private _cfg = configFile >> "CfgALiVEC2ISTARAccessItems" >> _tok;
    if (isClass _cfg) then {
        { _expanded pushBack (toLower _x); } forEach (getArray (_cfg >> "classnames"));
    } else {
        private _matched = false;
        {
            if ((toLower (configName _x)) == _tok) exitWith {
                { _expanded pushBack (toLower _x); } forEach (getArray (_x >> "classnames"));
                _matched = true;
            };
        } forEach ("true" configClasses (configFile >> "CfgALiVEC2ISTARAccessItems"));
        if (!_matched) then { _expanded pushBack _tok; };
    };
} forEach _tokens;

// one pool for every entry point: assigned items (map/GPS/radio/binocular
// slots) + uniform/vest/backpack contents + the backpack classname itself
private _pool = ((assignedItems _unit) + (items _unit) + ([backpack _unit])) apply {toLower _x};
private _poolString = _pool joinString ",";

private _result = false;
{
    if (_poolString find _x != -1) exitWith { _result = true; };
} forEach _expanded;

_result
