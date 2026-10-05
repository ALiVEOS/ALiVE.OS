#include "\x\alive\addons\sys_pathfinding\script_component.hpp"

// Submerged surface rays detect banks and shoals between the endpoints.
// terrainIntersectASL can reject rays below the sea surface. Surface queries
// work underwater and ignore that surface; NONE LODs restrict them to terrain.
// Three parallel rays reserve room for the hull; endpoint probes cover turns.
// Geometry callbacks let the regression suite use synthetic river beds.
params ["_from", "_to", "_settings", ["_geometry", []], ["_pointCache", nil]];
if (isNil "_pointCache") then {_pointCache = createHashMap};
_settings params ["_seaLevel", "_depth", "_clearance"];
private _height = _geometry param [0, {getTerrainHeightASL _this}];
private _intersects = _geometry param [1, {
    params ["_rayStart", "_rayEnd"];
    count (lineIntersectsSurfaces [_rayStart, _rayEnd, objNull, objNull, false, 1, "NONE", "NONE"]) > 0
}];
private _z = _seaLevel - _depth;
private _valid = true;
{
    private _point = _x;
    private _key = _point select [0,2];
    private _pointValid = false;
    if (_key in _pointCache) then {
        _pointValid = _pointCache get _key;
    } else {
        // Reject dry centres before paying for their eight clearance probes.
        _pointValid = (_point call _height) < _z;
        if (_pointValid && {_clearance > 0}) then {
            {
                private _probe = [(_point select 0) + _clearance * sin _x, (_point select 1) + _clearance * cos _x];
                if ((_probe call _height) >= _z) exitWith {_pointValid = false};
            } forEach [0,45,90,135,180,225,270,315];
        };
        _pointCache set [_key, _pointValid];
    };
    if (!_pointValid) exitWith {_valid = false};
} forEach [_from, _to];
if (!_valid) exitWith {false};
private _length = _from distance2D _to;
if (_length < 0.01) exitWith {true};
private _nx = -((_to select 1) - (_from select 1)) / _length;
private _ny = ((_to select 0) - (_from select 0)) / _length;
{
    private _a = [(_from select 0) + _nx * _x, (_from select 1) + _ny * _x, _z];
    private _b = [(_to select 0) + _nx * _x, (_to select 1) + _ny * _x, _z];
    if ([_a, _b] call _intersects) exitWith {_valid = false};
} forEach [-_clearance, 0, _clearance];
_valid
