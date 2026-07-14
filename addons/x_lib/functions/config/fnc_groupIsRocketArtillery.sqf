#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupIsRocketArtillery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupIsRocketArtillery

Description:
Checks whether a CfgGroups group's artillery consists ONLY of rocket
artillery (MLRS-class). Placement uses this to defer rocket groups on small
terrains where their minimum range leaves them nothing to shoot at. A group
with no artillery vehicles, or a group that cannot be resolved, returns
false (fail-open: never blocks placement by mistake).

Parameters:
String - faction classname
String - group classname

Returns:
Boolean

Examples:
(begin example)
_defer = ["rhs_faction_msv", "RHS_SPGSection_msv_bm21"] call ALIVE_fnc_groupIsRocketArtillery;
(end)

See Also:
ALIVE_fnc_isRocketArtillery

Author:
Jman
---------------------------------------------------------------------------- */

params ["_faction","_groupName"];

private _cfg = [_faction, _groupName] call ALIVE_fnc_configGetGroup;
if (!(_cfg isEqualType (configFile >> "CfgVehicles")) || {!isClass _cfg}) exitWith { false };

private _hasArtillery = false;
private _allRocket = true;

{
    private _v = getText (_x >> "vehicle");
    if (_v != "" && {[_v] call ALIVE_fnc_isArtillery}) then {
        _hasArtillery = true;
        if !([_v] call ALIVE_fnc_isRocketArtillery) then { _allRocket = false; };
    };
} forEach ("isClass _x" configClasses _cfg);

_hasArtillery && _allRocket
