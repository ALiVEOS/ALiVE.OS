#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(spawnComposition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spawnComposition

Description:
Spawn a composition
Modified version of BIS_fnc_objectMapper to suit Zeus composition configs

Parameters:
Config - group
Array - position
Scalar - direction

Returns:

Examples:
(begin example)
//
_result = [] call ALIVE_fnc_spawnComposition;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_config","_position","_azi","_objects","_positions","_azis","_item","_object","_relPos","_itemPos","_isFurniture"];

_config = _this select 0;
_position = _this select 1;
_azi = _this select 2;

private ["_posX", "_posY"];
_posX = _position select 0;
_posY = _position select 1;

//Function to multiply a [2, 2] matrix by a [2, 1] matrix
private ["_multiplyMatrixFunc"];
_multiplyMatrixFunc =
{
	private ["_array1", "_array2", "_result"];
	_array1 = _this select 0;
	_array2 = _this select 1;

	_result =
	[
		(((_array1 select 0) select 0) * (_array2 select 0)) + (((_array1 select 0) select 1) * (_array2 select 1)),
		(((_array1 select 1) select 0) * (_array2 select 0)) + (((_array1 select 1) select 1) * (_array2 select 1))
	];

	_result
};

_objects = [];
_positions = [];
_azis = [];
_isFurniture = false;

if (str(_config) find "Furniture" != -1) then {
    _isFurniture = true;
};

for "_i" from 0 to ((count _config) - 1) do
{
    private ["_item"];
    _item = _config select _i;

    if (isClass _item) then {
        _objects = _objects + [getText(_item >> "vehicle")];
        _positions = _positions + [getArray(_item >> "position")];
        _azis = _azis + [getNumber(_item >> "dir")];
    };
};

for "_i" from 0 to ((count _objects) - 1) do
{
    private ["_object", "_relPos", "_azimuth"];
    _object = _objects select _i;
    _relPos = _positions select _i;
    _azimuth = _azis select _i;

    //Rotate the relative position using a rotation matrix
    private ["_rotMatrix", "_newRelPos", "_newPos"];
    _rotMatrix =
    [
        [cos _azi, sin _azi],
        [-(sin _azi), cos _azi]
    ];
    _newRelPos = [_rotMatrix, _relPos] call _multiplyMatrixFunc;

    //Backwards compatability causes for height to be optional
    private ["_z"];
    if ((count _relPos) > 2) then {_z = _relPos select 2} else {_z = 0};

    _newPos = [_posX + (_newRelPos select 0), _posY + (_newRelPos select 1), _z];

    //Create the object and make sure it's in the correct location
    private ["_newObj"];
    _newObj = _object createVehicle _newPos;
    if (_isFurniture) then {
        _newObj enableSimulation false;
        _newPos = [_newPos select 0, _newPos select 1, (_newPos select 2) + (_position select 2)];
    };
    _newObj setDir (_azi + _azimuth);
    _newObj setPos _newPos;

};