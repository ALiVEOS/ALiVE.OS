#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getArtilleryType);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getArtilleryType

Description:
What kind of artillery a vehicle class is: "MORTAR", "TOWED" (a static gun),
"SP" (anything that drives: tracked and wheeled guns, rocket trucks, mortar
carriers), "NAVAL" (a ship's gun or launcher) or "" when it is not artillery. Placement's Artillery type setting,
the artillery module's mortar booking and the insurgent mortar pick use it, so
they agree on what a mortar is.

Parameters:
String or Object - the vehicle class or vehicle

Returns:
String

Examples:
(begin example)
_type = ["B_Mortar_01_F"] call ALIVE_fnc_getArtilleryType; // "MORTAR"
(end)

See Also:
ALIVE_fnc_isArtillery, ALIVE_fnc_groupArtilleryType

Author:
Jman
---------------------------------------------------------------------------- */

private _class = _this select 0;
if (_class isEqualType objNull) then { _class = typeOf _class };

if (isNil "ALIVE_artilleryTypeCache") then { ALIVE_artilleryTypeCache = [] call ALIVE_fnc_hashCreate };
private _cached = [ALIVE_artilleryTypeCache, _class] call ALIVE_fnc_hashGet;
if (!isNil "_cached") exitWith { _cached };

private _result = "";
if ([_class] call ALIVE_fnc_isArtillery) then {
    if (_class isKindOf "StaticWeapon") then {
        // a static piece: a mortar or a towed gun. StaticMortar is the vanilla root and RHS, CUP and
        // 3CB hang their tubes off it; a mod that files a tube under StaticCannon or StaticWeapon is
        // caught by name, then by the barrel: a tube can't depress below about 45 degrees, a howitzer
        // can fire flat
        private _sig = toLower format ["%1 %2", _class, getText (configFile >> "CfgVehicles" >> _class >> "model")];
        private _mortarNames = ["mortar","m252","2b14","podnos","l16","m224","m29","type63","type_63","type53","mk6","60mm","81mm","82mm","120mm"];
        private _gunNames = ["d30","d-30","2a18","m119","m101","m777","l118","m198","fh70","howitz","105mm","155mm","122mm","152mm"];
        _result = switch (true) do {
            // a ship's gun or launcher (the Hammer, the VLS) is artillery but no placed battery should use it
            case ("ship_gun" in _sig || {"ship_missile" in _sig}): { "NAVAL" };
            case (_class isKindOf "StaticMortar"): { "MORTAR" };
            case ((_mortarNames findIf { _x in _sig }) > -1): { "MORTAR" };
            case ((_gunNames findIf { _x in _sig }) > -1): { "TOWED" };
            default {
                private _highOnly = false;
                { if (getNumber (_x >> "maxElev") > 45 && {getNumber (_x >> "minElev") >= 20}) exitWith { _highOnly = true } }
                    forEach ("isClass _x" configClasses (configFile >> "CfgVehicles" >> _class >> "Turrets"));
                if (_highOnly) then { "MORTAR" } else { "TOWED" }
            };
        };
    } else {
        _result = "SP";
    };
};

[ALIVE_artilleryTypeCache, _class, _result] call ALIVE_fnc_hashSet;
_result
