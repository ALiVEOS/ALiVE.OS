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

private _result = [];

//Exit if ALIVE_profileHandler is not existing for any reason (f.e. due to being called on a remote locality with fnc_isEnemyNear)
if (isnil "ALiVE_profileHandler") exitwith {_result};

private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;
private _categoryType = "entity";

if (_categorySelector isEqualTo []) then {
    private _near = [_spacialGrid,"findInRange", [_position,_radius]] call ALiVE_fnc_spacialGrid;
    _result = _near apply {_x select 1};
    _result = _result select {(_x select 2 select 5) == _categoryType};
}else{
    _categorySide = _categorySelector select 0;
    _categoryType = _categorySelector select 1;
    _categoryObjectType = _categorySelector param [2,"none"];

    private _near = [_spacialGrid,"findInRange", [_position,_radius]] call ALiVE_fnc_spacialGrid;
    _result = _near apply {_x select 1};
    _result = _result select {(_x select 2 select 5) == _categoryType && {(_x select 2 select 3) == _categorySide}};

    if (_categoryObjectType != "none") then {
        _result = _result select {(_x select 2 select 6) == _categoryObjectType};
    };
};

_result