#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(unitsInArea);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_unitsInArea

Description:
Returns a bool if there are units of a given side in the passed trigger- or markerarea.

Parameters:
ARRAY - ["marker or trigger name", "side"]

Returns:
BOOL - true or false

Examples:
(begin example)
// are there troops alive?
_occupied = ["AO","EAST"] call ALiVE_fnc_unitsInArea;
(end)

See Also:


Author:
highhead
---------------------------------------------------------------------------- */

params ["_trigger", "_side"];

scopeName "#Main";

private _markerSizeMax = selectMax (getmarkersize _trigger); 
private _nearProfiles = [markerpos _trigger, _markerSizeMax, [_side,"entity"]] call ALIVE_fnc_getNearProfiles;
private _found = false;
{
    _profile = _x;

    if !(isnil "_profile") then {
        private _position = _profile select 2 select 2;

        if (_position inArea _trigger) then {

            _found = true;

            breakTo "#Main";
        };
    };
} forEach _nearProfiles;

if (!_found) then {
    private _units = (markerpos _trigger) nearEntities [["Man"], _markerSizeMax];

    {
        private _unit = _x;

        if (alive _unit && {([side _x] call ALiVE_fnc_sideToSideText) == _side} && {(getposATL _unit) inArea _trigger}) then {

            _found = true;

            breakTo "#Main";
        };
    } foreach _units;
};

_found;