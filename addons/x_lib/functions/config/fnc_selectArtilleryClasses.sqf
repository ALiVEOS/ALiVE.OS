#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(selectArtilleryClasses);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_selectArtilleryClasses

Description:
Which of a faction's artillery vehicles a placed battery may use, for the
placement modules' Artillery type setting. ANY keeps the old rule: rockets
held back on small terrains, then self-propelled guns ahead of static ones.
MORTAR, TOWED and SP keep only that kind (rockets still held back on small
terrains inside it); with none of that kind it falls back to the ANY rule and
says why in the note.

Parameters:
Array - artillery vehicle classes
String - "ANY", "MORTAR", "TOWED" or "SP" (optional, default "ANY")
Boolean - a small terrain, where rockets have nothing in range (optional, default false)

Returns:
Array - [classes, note], note "" or the reason the type wasn't met

Examples:
(begin example)
([_classes, "MORTAR", worldSize < 10240] call ALIVE_fnc_selectArtilleryClasses) params ["_classes","_note"];
(end)

See Also:
ALIVE_fnc_getArtilleryType

Author:
Jman
---------------------------------------------------------------------------- */

params ["_classes", ["_type","ANY"], ["_smallMap",false]];

private _note = "";
private _fnc_preferGuns = {
    if (!_smallMap) exitWith { _this };
    private _guns = _this select { !([_x] call ALIVE_fnc_isRocketArtillery) };
    if (count _guns > 0) then { _guns } else { _this }
};
private _fnc_anyOrder = {
    // mortars only where the faction has nothing else, or on a small map where all else is out-ranged rockets
    private _mortars = _this select { ([_x] call ALIVE_fnc_getArtilleryType) == "MORTAR" };
    private _c = _this - _mortars;
    if (count _c == 0) exitWith { _mortars };
    _c = _c call _fnc_preferGuns;
    if (_smallMap && {count _mortars > 0} && {(_c findIf { !([_x] call ALIVE_fnc_isRocketArtillery) }) < 0}) exitWith { _mortars };
    private _sp = _c select { !(_x isKindOf "StaticWeapon") };
    if (count _sp > 0) then { _sp } else { _c }
};

if (_type == "ANY") then {
    _classes = _classes call _fnc_anyOrder;
} else {
    private _wanted = _classes select { ([_x] call ALIVE_fnc_getArtilleryType) == _type };
    if (count _wanted > 0) then {
        _classes = _wanted call _fnc_preferGuns;
    } else {
        _note = format ["no %1 artillery among the vehicles", _type];
        _classes = _classes call _fnc_anyOrder;
    };
};

[_classes, _note]
