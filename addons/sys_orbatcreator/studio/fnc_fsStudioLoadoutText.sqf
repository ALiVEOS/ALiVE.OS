#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioLoadoutText);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioLoadoutText

Description:
A loadout array (getUnitLoadout form) as a short structured-text summary: the
three weapons with their pictures, then the uniform, vest, backpack and
headgear. Reads config only.

Parameters:
    _loadout - ARRAY - the loadout

Returns:
    STRING - structured text, for parseText

Examples:
    (begin example)
    _ctrl ctrlSetStructuredText parseText ([_loadout] call ALiVE_fnc_fsStudioLoadoutText);
    (end)

See Also:
    ALiVE_fnc_fsStudioTabUnits

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_loadout", [], [[]]]];

private _safe = { ((_this regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] };
private _name = {
    params ["_class", "_root"];
    private _n = getText (configFile >> _root >> _class >> "displayName");
    if (_n isEqualTo "") then { _class } else { _n }
};

private _lines = [];
{
    _x params ["_slot"];
    private _class = (_loadout param [_slot, []]) param [0, ""];
    if (_class isEqualType "" && {!(_class isEqualTo "")}) then {
        private _pic = getText (configFile >> "CfgWeapons" >> _class >> "picture");
        // the picture gets room of its own: the name sits beside it, centred on it, after a gap
        _lines pushBack format ["<img image='%1' size='1.6'/><t valign='middle'>   %2</t>", _pic call _safe, ([_class, "CfgWeapons"] call _name) call _safe];
    };
} forEach [[0], [1], [2]];
// a small gap between the weapons and the clothing
if (count _lines > 0) then { _lines pushBack "<t size='0.4'> </t>" };
{
    _x params ["_slot", "_root"];
    private _v = _loadout param [_slot, []];
    private _class = if (_v isEqualType "") then { _v } else { _v param [0, ""] };
    if (_class isEqualType "" && {!(_class isEqualTo "")}) then {
        _lines pushBack (([_class, _root] call _name) call _safe);
    };
} forEach [[3, "CfgWeapons"], [4, "CfgWeapons"], [5, "CfgVehicles"], [6, "CfgWeapons"]];

format ["<t size='1'>%1</t>", _lines joinString "<br/>"]
