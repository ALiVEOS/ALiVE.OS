#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(getNearProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getNearProfiles

Description:
Returns an array of profiles within the passed radius

Parameters:
Array - position center of search
Scalar - radius of search

Returns:
Array of profiles

Examples:
(begin example)
// get profiles within the radius
_profiles = [getPos player, 500, ["WEST","vehicle","Car"]] call ALIVE_fnc_getNearProfiles;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private _position = _this select 0;
private _radius = _this select 1;
private _categorySelector = param [2, []];

private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;
private _near = ([_spacialGrid,"findInRange", [_position,_radius]] call ALiVE_fnc_spacialGrid) apply {_x select 1};

if (_categorySelector isEqualTo []) then {
   _near select {(_x select 2 select 5) == "entity"};
} else {
    private _categorySide = _categorySelector param [0, "all"];
    private _categoryType = _categorySelector param [1, "all"];
    private _categoryObjectType = _categorySelector param [2, "none"];

    private _query = "true";

    if (_categorySide != "all") then {
        _query = _query + " && ((_x select 2 select 3) == _categorySide)";
    };

    if (_categoryType != "all") then {
        _query = _query + " && {(_x select 2 select 5) == _categoryType}";
    };

    if (_categoryObjectType != "none") then {
        _query = _query + " && {(_x select 2 select 6) == _categoryObjectType}";
    };

    _near select (compile _query);
};