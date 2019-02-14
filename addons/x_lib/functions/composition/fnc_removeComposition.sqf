#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(removeComposition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeComposition

Description:
Removes a spawned composition

Parameters:
Array - position
Number - radius

Returns: nothing

Examples:
(begin example)
//
_result = [getpos player,50] call ALIVE_fnc_removeComposition;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

params ["_position","_radius"];

//["ALiVE - Removing  Composition: %1", _this] call ALiVE_fnc_dump;

private _compositions = [MOD(PCOMPOSITIONS),"compositions",[]] call ALiVE_fnc_HashGet;
private _positions = _compositions select 0;
private _data = _compositions select 1;
private _indexes = [];

{
    private _compositionPosition = _x;

    if (_compositionPosition distance _position < _radius) then {
        _indexes pushBack _foreachIndex;

        private _dataHandler = _compositionPosition nearestObject "ALIVE_DemoCharge_Remote_Ammo";
        private _objects = _dataHandler getvariable [QGVAR(COMPOSITION_OBJECTS),[]];

        {deleteVehicle _x} foreach _objects;
        deleteVehicle _dataHandler;
    };
} foreach _positions;

{
    _positions set [_x,objNull];
    _positions = _positions - [objNull];

    _data set [_x,objNull];
    _data = _data - [objNull];
} foreach _indexes;

_compositions set [0,_positions];
_compositions set [1,_data];

if (!isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS") then {
    {
        if (_x distance _position < _radius) then {
            ALiVE_CIV_PLACEMENT_ROADBLOCKS set [_foreachIndex,objNull];
        };
    } foreach ALiVE_CIV_PLACEMENT_ROADBLOCKS;

    ALiVE_CIV_PLACEMENT_ROADBLOCKS = ALiVE_CIV_PLACEMENT_ROADBLOCKS - [objNull];
};

