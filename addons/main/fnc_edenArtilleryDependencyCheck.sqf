#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenArtilleryDependencyCheck);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenArtilleryDependencyCheck

Description:
3DEN editor-time advisory. The Military AI Commander Artillery module controls
how artillery behaves but places no guns itself (the placement modules do, or
the editor). If a maker drops the module without any source of artillery
batteries, it silently does nothing at runtime. Warn them in the editor.

Fired from main/XEH_preInit.sqf on OnMissionPreview.

Parameters: none

Returns: nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!is3DEN) exitWith {};

private _entities = all3DENEntities;
private _objects = _entities select 0;
private _systems = _entities select 3;

// nothing to advise unless a Military AI Commander Artillery module is present
private _hasArtilleryModule = (_systems findIf { (typeOf _x) == "ALiVE_mil_artillery" }) > -1;
if !(_hasArtilleryModule) exitWith {};

private _fnc_attrTrue = {
    params ["_module", "_attr"];
    private _v = (_module get3DENAttribute _attr) param [0, false];
    if (_v isEqualType "") then { _v = (toLower _v) == "true"; };
    _v isEqualType true && {_v}
};

private _fnc_attrCount = {
    params ["_module", "_attr"];
    private _v = (_module get3DENAttribute _attr) param [0, 0];
    if (_v isEqualType "") then { _v = parseNumber _v; };
    if !(_v isEqualType 0) then { _v = 0; };
    _v
};

// a battery source exists if any placement module is set to place artillery,
// or an artillery vehicle is placed directly in the editor
private _sourceFound = false;

{
    switch (typeOf _x) do {
        case "ALiVE_mil_placement": {
            if ([_x, "ALiVE_mil_placement_placeArtillery"] call _fnc_attrTrue) then { _sourceFound = true; };
        };
        case "ALiVE_mil_placement_custom": {
            if (([_x, "ALiVE_mil_placement_custom_customArtilleryCount"] call _fnc_attrCount) > 0) then { _sourceFound = true; };
        };
    };
    if (_sourceFound) exitWith {};
} forEach _systems;

// editor-placed artillery (config check only - no ALiVE fnc needed in Eden)
if (!_sourceFound) then {
    _sourceFound = (_objects findIf {
        getNumber (configFile >> "CfgVehicles" >> (typeOf _x) >> "artilleryScanner") > 0
    }) > -1;
};

if (!_sourceFound) then {
    // severity 2 = warning (orange)
    ["ALiVE: AI Commander Artillery is placed but nothing provides it guns. Enable 'Place artillery units' on a Military Placement module (or 'Artillery Count' on a Custom Objective), or place artillery in the editor.", 2, 12] call BIS_fnc_3DENNotification;
};
