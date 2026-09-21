#include "script_component.hpp"
SCRIPT(presetAddons);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetAddons

Description:
What a preset needs loaded, worked out from what is in the preset rather than
from the scenario it came from.

That distinction is the whole point. The editor writes a mission's addons[] list
when the mission is SAVED, so an unsaved scenario has no list and one saved
before the last module went in has a stale one. A preset pasted in from Discord
has no mission behind it at all. Reading the preset's own contents works for
every preset in the window, including the ones somebody else wrote, and it can
say WHICH module or faction wants each one rather than only naming it.

What it looks at, for every module the preset carries:

  - the module class itself, nearly always ALiVE's own and so dropped, but it
    costs nothing to check and catches a module from somewhere else.
  - every setting value that is text, split into words, each word tried against
    CfgFactionClasses and CfgVehicles. A faction from a mod is the usual answer.
    A unit or vehicle class named in a blacklist or a custom objective list is
    the other.

Arma's own and ALiVE's own are dropped, because telling somebody they need Arma
is not information. That filter is also what makes it safe to try every word
rather than guessing which ones are class names: a word in a description that
happens to match a vanilla class contributes nothing.

Two ways of reporting the answer, and the difference matters:

  "addons" gives the addon names, which is what goes in the preset, because that
  is what activatedAddons can be checked against when the preset is read back.

  "mods" gives what somebody actually downloads. RHS USAF ships as a dozen
  addons and ACE as more, so counting addons told somebody a preset needed
  sixteen mods when it needed six. Grouping them by configSourceMod fixes the
  count as well as the names, and carries a Steam id so the row can be linked.

MEASURED 2026-09-21. configSourceMod gives the mod folder for a config entry
("@RHSUSAF", "@ace", "" for anything of Arma's own) and tells the RHS packs
apart. modParams gives the display name, including its version, which is what
the launcher shows. CfgMods is NOT usable for this and following CBA's help
module here would have been wrong: RHS declares an empty class, Pook declares
none at all, and ACE's is keyed without its "@". Element 7 of a
getLoadedModsInfo row is the Steam published file id, checked against ids that
are already known (CBA 450814997, ACE 463939057, RHS AFRF 843425103). A mod
outside the Workshop reports "0". Elements 2 and 3 are both true for an official
Creator DLC, whose id is a store AppID rather than a Workshop item.

A mod that is NOT loaded cannot be derived at all, because none of its classes
are in config to be found. All that is known about one is the addon name the
preset recorded when it was made, so those come through as rows of their own,
named by the addon and with nothing to link to.

Parameters:
    _modules - ARRAY - the modules part of a preset, [[class, settings], ...]
    _declared - ARRAY - optional, addons the preset already states
    _mode - STRING - "addons" for names, "mods" for what somebody downloads

Returns:
    ARRAY. For "addons", addon names, lowercase, sorted, no duplicates.
    For "mods", one row per mod: [name, [reasons], loaded, link, dir], sorted
    with anything not loaded first. link is "" when there is nothing to link to.

Examples:
    (begin example)
    private _needs = [_preset select 3, _preset select 5] call ALIVE_fnc_presetAddons;
    private _rows = [_preset select 3, _preset select 5, "mods"] call ALIVE_fnc_presetAddons;
    (end)

See Also:
    ALIVE_fnc_presetCollect, ALIVE_fnc_presetNeeds, ALIVE_fnc_presetLoad

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_modules", [], [[]]], ["_declared", [], [[]]], ["_mode", "addons", [""]]];

// Three arrays kept in step rather than one array of rows, so an addon can be
// found by name in one operation while it is being filled in.
private _names = [];
private _why = [];
private _dirs = [];

private _fnc_keep = {
    // Arma's own and ALiVE's own are not worth reporting. The same test the
    // faction scan here has always used.
    params ["_src"];
    private _low = toLower _src;
    !(_low isEqualTo "")
        && {!(_low select [0, 3] isEqualTo "a3_")}
        && {!(_low select [0, 6] isEqualTo "alive_")}
};

private _fnc_note = {
    params ["_cfg", "_reason"];   // _reason is [kind, subject, where], see the header
    if (!isClass _cfg) exitWith {};
    private _mod = configSourceMod _cfg;
    {
        private _src = toLower _x;
        if ([_src] call _fnc_keep) then {
            private _at = _names find _src;
            if (_at < 0) then {
                _names pushBack _src;
                _why pushBack [_reason];
                _dirs pushBack _mod;
            } else {
                (_why select _at) pushBackUnique _reason;
                // A mod folder found later wins over none found earlier, which
                // can happen when the same addon is reached through a class that
                // does not declare a source.
                if ((_dirs select _at) isEqualTo "" && {!(_mod isEqualTo "")}) then {
                    _dirs set [_at, _mod];
                };
            };
        };
    } forEach (configSourceAddonList _cfg);
};

{
    if (_x isEqualType [] && {count _x > 1}) then {
        private _class = _x select 0;
        private _settings = _x select 1;

        private _shown = _class;
        if (_class isEqualType "") then {
            private _display = getText (configFile >> "CfgVehicles" >> _class >> "displayName");
            if !(_display isEqualTo "") then { _shown = _display };
            [configFile >> "CfgVehicles" >> _class, ["module", _shown, ""]] call _fnc_note;
        };

        if (_settings isEqualType []) then {
            {
                if (_x isEqualType [] && {count _x > 1} && {(_x select 1) isEqualType ""}) then {
                    // The same separators the faction scan has always used, so a
                    // list written as [""a"",""b""] comes apart the same way.
                    {
                        // Two characters is shorter than any class name worth
                        // looking up and skips the punctuation left by the split.
                        if (count _x > 2) then {
                            [configFile >> "CfgFactionClasses" >> _x,
                                ["faction", _x, ""]] call _fnc_note;
                            [configFile >> "CfgVehicles" >> _x,
                                ["class", _x, _shown]] call _fnc_note;
                        };
                    } forEach ((_x select 1) splitString "[]""', |");
                };
            } forEach _settings;
        };
    };
} forEach _modules;

// Anything the preset already states is kept whether it can be derived or not.
// Somebody who added a terrain or a composition pack knows something this
// cannot work out, and throwing that away would be worse than missing it. It is
// also the only trace of a mod that is not loaded, because nothing of an absent
// mod is in config to be found.
{
    if (_x isEqualType "" && {[_x] call _fnc_keep}) then {
        private _src = toLower _x;
        if ((_names find _src) < 0) then {
            _names pushBack _src;
            _why pushBack [["stated", "", ""]];
            _dirs pushBack (configSourceMod (configFile >> "CfgPatches" >> _x));
        };
    };
} forEach _declared;

if !((toLower _mode) isEqualTo "mods") exitWith {
    private _sorted = +_names;
    _sorted sort true;
    _sorted
};

// ---- grouped by what somebody downloads ----

private _loaded = getLoadedModsInfo;
private _running = activatedAddons apply { toLower _x };

private _fnc_modRow = {
    // A loaded mod's row, by folder. Element 1 is the folder, which is what
    // configSourceMod returns, so the two join directly.
    params ["_dir"];
    private _low = toLower _dir;
    private _at = _loaded findIf { (toLower (_x param [1, ""])) isEqualTo _low };
    if (_at < 0) then { [] } else { _loaded select _at }
};

private _keys = [];      // one entry per mod, or per undebuggable addon
private _rowNames = [];
private _rowWhy = [];
private _rowOn = [];
private _rowLink = [];
private _rowDirs = [];

{
    private _addon = _x;
    private _dir = _dirs select _forEachIndex;
    private _reasons = _why select _forEachIndex;
    private _on = _addon in _running;

    // Grouped under the mod when there is one. An addon with no mod folder is
    // either not loaded or came from somewhere that declares no source, and
    // either way its own name is the most that can honestly be shown.
    private _key = if (_dir isEqualTo "") then { "addon:" + _addon } else { "mod:" + (toLower _dir) };
    private _at = _keys find _key;
    if (_at < 0) then {
        private _name = _addon;
        private _link = "";
        if !(_dir isEqualTo "") then {
            private _pretty = (modParams [_dir, ["name"]]) param [0, ""];
            if !(_pretty isEqualTo "") then { _name = _pretty };

            private _row = [_dir] call _fnc_modRow;
            if (count _row > 0) then {
                private _id = _row param [7, "0"];
                private _isDLC = (_row param [2, false]) || {_row param [3, false]};
                if (!(_id isEqualTo "0") && {!(_id isEqualTo "")}) then {
                    // A Creator DLC's id is a store AppID, not a Workshop item,
                    // so it takes the store address instead.
                    _link = if (_isDLC) then {
                        format ["https://store.steampowered.com/app/%1/", _id]
                    } else {
                        format ["https://steamcommunity.com/sharedfiles/filedetails/?id=%1", _id]
                    };
                };
            };
        };
        _keys pushBack _key;
        _rowNames pushBack _name;
        _rowWhy pushBack (+_reasons);
        _rowOn pushBack _on;
        _rowLink pushBack _link;
        _rowDirs pushBack _dir;
    } else {
        { (_rowWhy select _at) pushBackUnique _x } forEach _reasons;
        // One addon of a mod being absent is enough to call the mod absent,
        // because the preset wanted that addon.
        if (!_on) then { _rowOn set [_at, false] };
    };
} forEach _names;

private _out = [];
{
    _out pushBack [_rowNames select _forEachIndex, _rowWhy select _forEachIndex,
        _rowOn select _forEachIndex, _rowLink select _forEachIndex, _x];
} forEach _rowDirs;

// Alphabetical, by sorting the names and reading the rows back in that order.
// sort is the only thing here that orders strings, and it works on a flat array
// rather than on rows, hence the detour. Duplicate names are taken one at a
// time so two mods sharing a display name cannot lose a row.
private _order = _rowNames apply { toLower _x };
private _sortedNames = +_order;
_sortedNames sort true;
private _taken = [];
private _sorted = [];
{
    // Held in its own name because the loop below rebinds _x, and comparing _x
    // with itself would match the first untaken row every time.
    private _want = _x;
    private _at = -1;
    {
        if (_x isEqualTo _want && {!(_forEachIndex in _taken)}) exitWith { _at = _forEachIndex };
    } forEach _order;
    if (_at >= 0) then {
        _taken pushBack _at;
        _sorted pushBack (_out select _at);
    };
} forEach _sortedNames;

// Not loaded first, so the rows worth acting on are at the top of the window.
(_sorted select { !(_x select 2) }) + (_sorted select { _x select 2 })
