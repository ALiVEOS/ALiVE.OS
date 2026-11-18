#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenCargo);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenCargo

Description:
The four Transport classes of a vehicle or crate holding exactly the given rows.
A kind with nothing in it is written empty, so none of the base's own cargo
comes through. Shared by vehicles (cargo list) and supply crates.

Parameters:
    _rows   - ARRAY - cargo maps (class, kind 0 weapon / 1 magazine / 2 item / 3 backpack, count)
    _indent - STRING - the indent of the class body

Returns:
    ARRAY - lines

Examples:
    (begin example)
    _lines append ([_e get "cargo", "        "] call ALiVE_fnc_fsGenCargo);
    (end)

See Also:
    ALiVE_fnc_fsGenVehicle, ALiVE_fnc_fsGenConfig

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_rows", [], [[]]], ["_indent", "        ", [""]]];

private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _lines = [];
{
    _x params ["_box", "_key", "_kind"];
    private _these = _rows select { (_x getOrDefault ["kind", 2]) == _kind && {!((_x getOrDefault ["class", ""]) isEqualTo "")} };
    if (_these isEqualTo []) then {
        _lines pushBack format ["%1class %2 {};", _indent, _box];
    } else {
        _lines pushBack format ["%1class %2 {", _indent, _box];
        {
            private _c = _x get "class";
            _lines pushBack format ["%1    class _xx_%2 { %3 = %4; count = %5; };", _indent, _c, _key, _c call _q, (_x getOrDefault ["count", 1]) toFixed 0];
        } forEach _these;
        _lines pushBack (_indent + "};");
    };
} forEach [["TransportWeapons", "weapon", 0], ["TransportMagazines", "magazine", 1], ["TransportItems", "name", 2], ["TransportBackpacks", "backpack", 3]];
_lines
