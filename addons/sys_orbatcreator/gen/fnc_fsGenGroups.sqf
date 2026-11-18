#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenGroups);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenGroups

Description:
The CfgGroups block: Side >> Faction >> Category >> Group >> UnitN, with the
stock side names (East, West, Indep). Only categories that have groups are
written, and a faction with no groups gets no block at all: ALiVE treats a
faction class with anything in it as having its own groups and then stops
borrowing the stock groups of its side.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan
    _faction - HASHMAP - the snapshot
    _groups  - HASHMAP - (optional) category to groups, as the plan's groups; an
               optional part's groups (default: the plan's)

Returns:
    ARRAY - config lines (empty when there is nothing to write)

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]], ["_groups", 0, [0, createHashMap]]];

if (_groups isEqualType 0) then { _groups = _plan get "groups" };
if (count _groups == 0) exitWith { [] };

private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _side = _faction getOrDefault ["side", 1];
private _sideClass = ["East", "West", "Indep"] param [_side, "West"];
private _names = createHashMapFromArray [
    ["Infantry", "Infantry"], ["SpecOps", "Special Forces"], ["Motorized", "Motorized Infantry"],
    ["Motorized_MTP", "Motorized Infantry (MTP)"], ["Mechanized", "Mechanized Infantry"],
    ["Mechanized_MTP", "Mechanized Infantry (MTP)"], ["Armored", "Armor"], ["Artillery", "Artillery"],
    ["Air", "Air"], ["Naval", "Naval"], ["Support", "Support"]
];
private _factionName = (_faction getOrDefault ["name", ""]) call _q;

private _lines = [
    "class CfgGroups {",
    format ["    class %1 {", _sideClass],
    format ["        class %1 {", _faction getOrDefault ["class", _plan get "tag"]],
    "            name = " + _factionName + ";"
];
// ALiVE's order first, then any category kept from an import
private _order = FS_ALIVE_CATEGORIES select { _x in _groups };
{ if !(_x in _order) then { _order pushBack _x } } forEach (keys _groups);
{
    private _cat = _x;
    _lines pushBack format ["            class %1 {", _cat];
    _lines pushBack ("                name = " + ((_names getOrDefault [_cat, _cat]) call _q) + ";");
    {
        _x params ["_class", "_name", "_icon", "_rarity", "_members"];
        _lines pushBack format ["                class %1 {", _class];
        _lines pushBack ("                    name = " + (_name call _q) + ";");
        _lines pushBack ("                    side = " + (_side toFixed 0) + ";");
        _lines pushBack ("                    faction = " + ((_faction getOrDefault ["class", _plan get "tag"]) call _q) + ";");
        if !(_icon isEqualTo "") then { _lines pushBack ("                    icon = " + (_icon call _q) + ";") };
        _lines pushBack ("                    rarityGroup = " + (_rarity toFixed 2) + ";");
        {
            _x params ["_vehicle", "_rank", "_pos", "_mside"];
            _lines pushBack format [
                "                    class Unit%1 { side = %2; vehicle = %3; rank = %4; position[] = {%5,%6,%7}; };",
                _forEachIndex toFixed 0, _mside toFixed 0, _vehicle call _q, _rank call _q,
                (_pos select 0) toFixed 1, (_pos select 1) toFixed 1, (_pos select 2) toFixed 1
            ];
        } forEach _members;
        _lines pushBack "                };";
    } forEach (_groups get _cat);
    _lines pushBack "            };";
} forEach _order;
_lines append ["        };", "    };", "};"];
_lines
