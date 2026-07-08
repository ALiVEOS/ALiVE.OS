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

Returns:
BOOL - true when the player carries at least one matching item

Examples:
(begin example)
_hasAccess = ["LaserDesignators,Radios", "MyMod_Tablet", ["ALIVE_Tablet"]] call ALIVE_fnc_playerHasAccessItems;
(end)

Author: Jman
---------------------------------------------------------------------------- */

params [["_itemsCsv", "", [""]], ["_customCsv", "", [""]], ["_extraTokens", [], [[]]]];

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
private _pool = ((assignedItems player) + (items player) + ([backpack player])) apply {toLower _x};
private _poolString = _pool joinString ",";

private _result = false;
{
    if (_poolString find _x != -1) exitWith { _result = true; };
} forEach _expanded;

_result
