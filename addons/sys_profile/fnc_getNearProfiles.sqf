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

params [
    "_position",
    "_radius",
    ["_categorySelector", []],
    ["_filter2D", false]
];

private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;
private _near = [_spacialGrid,"findInRange", [_position,_radius,_filter2D,true]] call ALiVE_fnc_spacialGrid;

if (_categorySelector isEqualTo []) then {
    _near select {(_x select 2 select 5) == "entity"};
} else {
    _categorySelector params [
        ["_categorySide", "all"],
        ["_categoryType", "all"],
        ["_categoryObjectType", "none"],
        ["_customFilter", {}]
    ];

    private _hasSideFilter = !(_categorySide isEqualTo "all");
    private _hasTypeFilter = _categoryType != "all";
    private _hasObjectTypeFilter = !(_categoryObjectType isEqualTo "none");
    private _hasCustomFilter = !(_customFilter isEqualTo {});

    if (
        !_hasSideFilter
        && {!_hasTypeFilter}
        && {!_hasObjectTypeFilter}
        && {!_hasCustomFilter}
    ) exitWith {
        _near
    };

    private _filtered = _near;

    if (_hasSideFilter || {_hasTypeFilter} || {_hasObjectTypeFilter}) then {
        _filtered = _near select {
            private _sideMatches = if (!_hasSideFilter) then {
                true
            } else {
                if (_categorySide isEqualType []) then {
                    (_x select 2 select 3) in _categorySide
                } else {
                    (_x select 2 select 3) == _categorySide
                }
            };

            private _typeMatches = !_hasTypeFilter || {(_x select 2 select 5) == _categoryType};

            private _objectTypeMatches = if (!_hasObjectTypeFilter) then {
                true
            } else {
                if (_categoryObjectType isEqualType []) then {
                    (_x select 2 select 6) in _categoryObjectType
                } else {
                    (_x select 2 select 6) == _categoryObjectType
                }
            };

            _sideMatches && {_typeMatches} && {_objectTypeMatches}
        };
    };

    if (_hasCustomFilter) then {
        _filtered select _customFilter
    } else {
        _filtered
    };
};
