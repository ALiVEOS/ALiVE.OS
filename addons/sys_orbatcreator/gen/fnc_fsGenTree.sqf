#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenTree);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenTree

Description:
Writes a tree of nested config classes (a vehicle's turrets and pylons) as config
text, for the stub chain and for the vehicles built on it.

The tree is a list of paths ("Turrets/MainTurret/Turrets/CommanderOptics"), each
parent listed before its children. Writing to depth k (a stub, sk) writes every
class above depth k again ("class X : X { ... };") and declares those at depth k
("class X;"), so the next stub or the vehicle can write them. Writing with no
depth limit (a vehicle) writes every class again, with its values from the map
(lowercase path to the text inside the braces). A declared class a vehicle does
not write again is no class at all to the game (a turret with no seat, a pylon
with no weapon), so a vehicle on a stub writes the whole tree.

Parameters:
    _paths  - ARRAY  - the paths, parents first
    _depth  - NUMBER - the depth declared (a stub), or 99 (a vehicle)
    _values - HASHMAP - lowercase path: the text inside its braces
    _pad    - STRING - the indent of the top level

Returns:
    ARRAY - the lines

Examples:
    (begin example)
    [["Turrets", "Turrets/MainTurret"], 2, createHashMap, "        "] call ALiVE_fnc_fsGenTree;
    (end)

See Also:
    ALiVE_fnc_fsGenPlan, ALiVE_fnc_fsGenConfig, ALiVE_fnc_fsGenVehicle

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_paths", [], [[]]], ["_depth", 99, [0]], ["_values", createHashMap, [createHashMap]], ["_pad", "        ", [""]]];

// the children of each class, in order
private _kids = createHashMap;
{
    private _parts = _x splitString "/";
    private _parent = toLower ((_parts select [0, count _parts - 1]) joinString "/");
    private _list = _kids getOrDefault [_parent, []];
    private _name = _parts select (count _parts - 1);
    if ((_list findIf { _x == _name }) < 0) then { _list pushBack _name; _kids set [_parent, _list] };
} forEach _paths;

private _lines = [];
private _emit = {
    params ["_parent", "_level", "_indent"];
    {
        private _path = if (_parent isEqualTo "") then { toLower _x } else { _parent + "/" + toLower _x };
        if (_level >= _depth) then {
            _lines pushBack format ["%1class %2;", _indent, _x];
        } else {
            private _body = _values getOrDefault [_path, ""];
            private _children = _kids getOrDefault [_path, []];
            if (_children isEqualTo []) then {
                _lines pushBack format ["%1class %2 : %2 {%3};", _indent, _x, ["", " " + _body + " "] select !(_body isEqualTo "")];
            } else {
                _lines pushBack format ["%1class %2 : %2 {", _indent, _x];
                if !(_body isEqualTo "") then { _lines pushBack (_indent + "    " + _body) };
                [_path, _level + 1, _indent + "    "] call _emit;
                _lines pushBack (_indent + "};");
            };
        };
    } forEach (_kids getOrDefault [_parent, []]);
};
["", 1, _pad] call _emit;
_lines
