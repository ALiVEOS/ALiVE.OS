#include "\x\alive\addons\sys_profile\script_component.hpp"
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
private _filter2D = param [3, false];

private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;
private _near = ([_spacialGrid,"findInRange", [_position,_radius,_filter2D]] call ALiVE_fnc_spacialGrid) apply {_x select 1};

if (_categorySelector isEqualTo []) then {
   _near select {(_x select 2 select 5) == "entity"};
} else {
    _categorySelector params [
        ["_categorySide", "all"],
        ["_categoryType", "all"],
        ["_categoryObjectType", "none"],
        ["_customFilter", {}]
    ];

    private _query = "true";

    if !(_categorySide isEqualTo "all") then {
        if (_categorySide isEqualType []) then {
            _query = _query + " && ((_x select 2 select 3) in _categorySide)";
        } else {
            _query = _query + " && ((_x select 2 select 3) == _categorySide)";
        };
    };

    if (_categoryType != "all") then {
        _query = _query + " && {(_x select 2 select 5) == _categoryType}";
    };

    if !(_categoryObjectType isEqualTo "none") then {
        if (_categoryObjectType isEqualType "") then {
            _query = _query + " && {(_x select 2 select 6) == _categoryObjectType}";
        } else {
            _query = _query + " && {(_x select 2 select 6) in _categoryObjectType}";
        };
    };

    if !(_customFilter isEqualTo {}) then {
        _query = _query + (format [" && %1", _customFilter]);
    };

    _near select (compile _query);
};