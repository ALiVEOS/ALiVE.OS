#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenReadme);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenReadme

Description:
The README.txt of an exported faction: what it is, what is in the folder, how
to build, the mods it needs (with Workshop links when known), that ALiVE is not
needed, how to publish and sign, how to keep editing, and a note for other
packers.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan
    _faction - HASHMAP - the snapshot
    _batTxt  - BOOL - the rebuild file was written as rebuild.bat.txt

Returns:
    ARRAY - lines

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]], ["_batTxt", true, [true]]];

private _tag = _plan get "tag";
private _lower = _plan get "tagLower";
private _mod = _faction getOrDefault ["modName", "ALiVE_" + _tag];
private _bat = ["rebuild.bat", "rebuild.bat.txt"] select _batTxt;
systemTime params ["_year", "_month", "_day"];
private _date = format ["%1-%2%3-%4%5", _year toFixed 0, ["", "0"] select (_month < 10), _month toFixed 0, ["", "0"] select (_day < 10), _day toFixed 0];

private _opt = _plan getOrDefault ["optional", []];
private _lines = [
    format ["%1 (%2)", _faction getOrDefault ["name", _tag], _tag],
    format ["Made by %1 on %2 with ALiVE %3.", _faction getOrDefault ["author", ""], _date, getText (configFile >> "CfgPatches" >> "ALiVE_main" >> "versionStr")],
    "",
    "WHAT IS IN THIS FOLDER",
    format ["  source\alive_fs_%1\config.cpp        the faction's units, vehicles and groups", _lower],
    format ["  source\alive_fs_%1\functions\        the script that dresses each soldier in his loadout", _lower],
    format ["  source\alive_fs_%1\PboPrefix.txt     the addon prefix, alive_fs\%1", _lower]
];
{ _lines pushBack format ["  source\%1\              an optional part (OPTIONAL PARTS below)", _x select 9] } forEach _opt;
_lines append [
    "  mod.cpp                                the name and picture in the game's mod list",
    format ["  %1                        packs the mod for you", _bat],
    format ["  %1.alivefaction.txt                 the faction data, to keep editing it in ALiVE", _tag],
    "",
    "HOW TO BUILD",
    "  You need Arma 3 Tools (free on Steam). Start it once, so Windows knows where it is."
];
if (_batTxt) then { _lines pushBack "  Rename rebuild.bat.txt to rebuild.bat (ALiVE cannot write a .bat file), then double-click it." } else { _lines pushBack "  Double-click rebuild.bat." };
_lines append [
    format ["  It makes @%1\addons\alive_fs_%2.pbo beside this file%3.", _mod, _lower, ["", ", and one .pbo for each optional part"] select (count _opt > 0)],
    "  Or by hand in Addon Builder:",
    format ["    source: source\alive_fs_%1", _lower],
    format ["    destination: @%1\addons", _mod],
    "    tick nothing that binarises",
    format ["    addon prefix: alive_fs\%1", _lower]
];
if (count _opt > 0) then { _lines pushBack "    and the same for each optional part's folder, with its own prefix (its PboPrefix.txt)" };
_lines append [
    "",
    "MODS IT NEEDS (load these first)",
    "  CBA_A3: https://steamcommunity.com/sharedfiles/filedetails/?id=450814997"
];
{
    _x params ["_name", "_item", "_official"];
    if (!_official) then {
        _lines pushBack (if (_item isEqualTo "") then { "  " + _name } else { format ["  %1: https://steamcommunity.com/sharedfiles/filedetails/?id=%2", _name, _item] });
    };
} forEach ((_plan get "deps") get "mods");
if (count _opt > 0) then {
    _lines append [
        "",
        "OPTIONAL PARTS",
        "  Each part loads only when every mod it needs is loaded. Without them the game leaves the part out,",
        "  with no message, and the rest of the faction loads as usual."
    ];
    {
        _x params ["_patch", "_names", "_men", "_vehicles", "_groups"];
        private _gn = 0;
        { _gn = _gn + count _x } forEach (values _groups);
        _lines pushBack format ["  %1 (%2): needs %3; adds %4 units, %5 vehicles, %6 groups", _patch, _x select 9, _names joinString ", ", (count _men) toFixed 0, (count _vehicles) toFixed 0, _gn toFixed 0];
        {
            _x params ["_name", "_item", "_official"];
            if (!_official && {!(_item isEqualTo "")}) then { _lines pushBack format ["    %1: https://steamcommunity.com/sharedfiles/filedetails/?id=%2", _name, _item] };
        } forEach (_x select 11);
    } forEach _opt;
};
_lines append [
    "",
    "ALIVE IS NOT NEEDED",
    "  The faction works in Eden and Zeus without ALiVE. With ALiVE loaded, ALiVE can place it.",
    ""
];
if (_plan getOrDefault ["hook", false]) then {
    _lines append [
        "IN ALIVE",
        "  The mod tells ALiVE about the faction itself (class CfgALiVEFactions in config.cpp): its groups,",
        "  supply crates, supply and support vehicles, transport and air transport. A mission needs no script",
        "  and no CustomFactions entry for it, and the mod still does not need ALiVE to load."
    ];
    private _crates = (_plan getOrDefault ["crates", []]) apply { _x select 0 };
    if (count _crates > 0) then { _lines pushBack ("  Supply crates: " + (_crates joinString ", ")) };
    _lines pushBack "";
};
_lines append [
    "DRESSING A SOLDIER IN YOUR MISSION",
    "  Each soldier is put in his loadout a frame after he is made. If your mission changes his gear",
    "  before then, he keeps your gear, unless the mod was made with Always apply the loadout.",
    "  Change at least one item besides headgear and facewear: the game itself picks random",
    "  headgear and facewear, so a change to those alone is read as the game's, and is replaced.",
    "  To keep a soldier exactly as you dressed him, set ALiVE_OverrideLoadout to true on him.",
    ""
];
// ACE training, said only when a soldier has some
if ((values (_faction getOrDefault ["units", createHashMap])) findIf { (_x getOrDefault ["aceMedic", -1]) > 0 || {(_x getOrDefault ["aceEngineer", -1]) > 0} } >= 0) then {
    _lines append [
        "ACE MEDICS AND ENGINEERS",
        "  Soldiers made ACE medics, doctors or advanced engineers get that training as they are made, with ACE",
        "  loaded. A setting your mission or ACE's own Eden attributes give a soldier is kept. Without ACE it does nothing.",
        ""
    ];
};
_lines append [
    "HOW TO PUBLISH",
    format ["  Open Arma 3 Tools, Publisher, and pick the @%1 folder.", _mod],
    "",
    "HOW TO SIGN",
    "  Use DSSignFile from Arma 3 Tools on the .pbo, or Addon Builder's -sign= option, and ship the .bikey.",
    "",
    "HOW TO KEEP EDITING",
    format ["  Put %1.alivefaction.txt in Documents\Arma 3\ALiVE\orbat\import\ and use Load from file", _tag],
    "  in ALiVE's ORBAT Creator, or keep the faction in your saved factions there.",
    "",
    "OTHER PACKERS",
    format ["  Make a file named $PBOPREFIX$ in the source folder holding alive_fs\%1.", _lower]
];
_lines
