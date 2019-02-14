#include "\x\alive\addons\x_lib\script_component.hpp"
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
String - Faction

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

params ["_config","_position","_azi","_faction"];

["Spawning Composition: %1", _this] call ALiVE_fnc_dump;

private ["_posX", "_posY"];
_posX = _position select 0;
_posY = _position select 1;

// Workaround until LSD fixes ZEC compositions
private _brokenCheckpoints = [
    "CheckpointWatchtower",
    "CheckpointBunker",
    "CheckpointSandbags2",
    "CheckpointTower",
    "CheckpointBunkers",
    "CheckpointHBarrier"
];

if (typename _config == "ARRAY") then {
    _config = [_config, configFile] call BIS_fnc_configPath;
};

/*
if (configName _config in _brokenCheckpoints) then {
    _azi = [_azi + 90] call ALiVE_fnc_modDegrees;
};
*/

//Function to multiply a [2, 2] matrix by a [2, 1] matrix
private _multiplyMatrixFunc =
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

private _objects = [];
private _positions = [];
private _azis = [];
private _created = [];
private _isFurniture = false;

if (str(_config) find "Furniture" != -1) then {
    _isFurniture = true;
};

for "_i" from 0 to ((count _config) - 1) do {
    private _item = _config select _i;

    if (isClass _item) then {
        _objects pushback (getText(_item >> "vehicle"));
        _positions pushback (getArray(_item >> "position"));
        _azis pushback (getNumber(_item >> "dir"));
    };
};

private _startPos = [0,0,0];
for "_i" from 0 to ((count _objects) - 1) do {
    private _object = _objects select _i;
    private _relPos = _positions select _i;
    private _azimuth = _azis select _i;

    //Rotate the relative position using a rotation matrix
    private _rotMatrix =
    [
        [cos _azi, sin _azi],
        [-(sin _azi), cos _azi]
    ];
    private _newRelPos = [_rotMatrix, _relPos] call _multiplyMatrixFunc;

    //Backwards compatability causes for height to be optional
    private _z = if ((count _relPos) > 2) then {_relPos select 2} else {0};

    private _newPos = [_posX + (_newRelPos select 0), _posY + (_newRelPos select 1), _z];

    //Create the object and make sure it's in the correct location
    private _newObj = _object createVehicle _startPos; // TODO: simpleObject
    if (_isFurniture) then {
        _newObj enableSimulation false;
        _newPos = [_newPos select 0, _newPos select 1, (_newPos select 2) + (_position select 2)];
    };

    // if object is faction-specific
    // and doesn't belong to passed faction
    // delete it
    if (faction _newObj != _faction && {_newObj iskindof "LandVehicle" || {_newObj iskindof "FlagCarrier"}}) then {
        deleteVehicle _newObj;
    } else {
        _newObj setDir (_azi + _azimuth);
        _newObj setPos _newPos;

        _created pushBack _newObj;
    };
};

if (isNil QMOD(PCOMPOSITIONS)) then {
    MOD(PCOMPOSITIONS) = [] call ALiVE_fnc_hashCreate;
};

// Save Compositions to a hash
private _comp = [MOD(PCOMPOSITIONS), "compositions",[[],[]]] call ALiVE_fnc_hashGet;
if !(_position in (_comp select 0)) then {
    (_comp select 0) pushBack _position;

    // Switch back original azi if broken checkpoint
    if (configName _config in _brokenCheckpoints) then {
        _azi = [_azi - 90] call ALiVE_fnc_modDegrees;
    };

    _config = [_config,[]] call BIS_fnc_configPath;

    (_comp select 1) pushBack [_config,_azi,_faction];
    [MOD(PCOMPOSITIONS), "compositions",_comp] call ALiVE_fnc_hashSet;
};

// Save created objects for removal during runtime
_charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo",_position, [], 0, "CAN_COLLIDE"];
_charge setvariable [QGVAR(COMPOSITION_OBJECTS),_created];
_charge enableSimulation false;
_charge hideObject true;



