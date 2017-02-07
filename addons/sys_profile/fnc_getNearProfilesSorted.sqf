#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(getNearProfilesSorted);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getNearProfilesSorted

Description:
Returns an array of profiles within the passed radius sorted by side

Parameters:
Array - position center of search
Scalar - radius of search

Returns:
Array of profiles

Examples:
(begin example)
_nearProfilesBySide = [getpos player, [["WEST", ["entity"]], ["EAST", ["entity",["vehicle","Car"]]]]] call ALiVE_fnc_getNearProfilesSorted;
// returns [[[entities of side west]], [[entities of side east],[cars of side east]]]
(end)

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

params [
    ["_pos", [0,0,0], [[]]],
    ["_sides", [], [[]]]
];

private _result = [];

// initialize return data
{
    private _typeCount = count (_x select 1);

    private _sideProfilesByType = [];
    for "_i" from 0 to (count _typeCount - 1) do {_sideProfilesByType pushback []};

    _result pushback _sideProfilesByType;
} foreach _sides;
for "_i" from 0 to (count _sides - 1) do {_result pushback []};

if (isNil "ALIVE_profileHandler") exitwith {_result};

// sort profiles

private _profiles = [MOD(profileHandler), "profiles"] call ALiVE_fnc_hashGet;

{
    private _profile = _x;
    private _profileSide = _x select 2 select 3;

    private _sideIndex = -1;
    private _sideProfileTypes = [];

    {
        _x params ["_sideString","_profileTypes"];

        if (_profileSide == _sideString) exitwith {
            _sideIndex = _forEachIndex;
            _sideProfileTypes = _profileTypes;
        };
    } foreach _sides;

    if (_sideIndex != -1) then {
        private _profileType = _profile select 2 select 5;
        private _typeIndex = -1;

        if (_sideProfileTypes isEqualTo []) then {
            (_result select _sideIndex) pushback _profile;
        } else {
            {
                if (_x isEqualType "") then {
                    if (_profileType == _x) then {
                        _typeIndex = _forEachIndex;
                    };
                } else {
                    _x params [["_type",""],["_objectType",""]];

                    if (_profileType == _type) then {
                        private _profileObjectType = _profile select 2 select 6;

                        if (_profileObjectType == _objectType) then {
                            _typeIndex = _forEachIndex;
                        };
                    };
                };
            } foreach _sideProfileTypes;

            if (_typeIndex != -1) then {
                ((_result select _sideIndex) select _typeIndex) pushback _profile;
            };
        };
    };
} foreach (_profiles select 2);


_result