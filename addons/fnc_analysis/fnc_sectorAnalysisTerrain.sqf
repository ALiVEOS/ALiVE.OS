#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(sectorAnalysisTerrain);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisTerrain

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add terrain type data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisTerrain;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_sector","_result","_centerPosition","_bounds","_dimensions","_quadrantWidth","_terrain","_terrainData","_countIsWater","_direction","_position","_positionX","_positionY","_sectorWidth","_sectorHeight","_sectorData"];

_sectors = _this select 0;
_err = format["sector analysis terrain requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

{
    _sector = _x;

    // Read geometry once. Keep the sector bounds arithmetic and BL/TL/TR/BR
    // order unchanged: water classification is sensitive to probe positions.
    _centerPosition = [_sector, "position"] call ALIVE_fnc_hashGet;
    _dimensions = [_sector, "dimensions"] call ALIVE_fnc_hashGet;
    _positionX = _centerPosition select 0;
    _positionY = _centerPosition select 1;
    _sectorWidth = _dimensions select 0;
    _sectorHeight = _dimensions select 1;
    _bounds = [
        [(_positionX - _sectorWidth), (_positionY - _sectorHeight)],
        [(_positionX - _sectorWidth), (_positionY + _sectorHeight)],
        [(_positionX + _sectorWidth), (_positionY + _sectorHeight)],
        [(_positionX + _sectorWidth), (_positionY - _sectorHeight)]
    ];

    _quadrantWidth = (_dimensions select 0) / 2;

    _countIsWater = 0;

    _terrain = "";
    if(surfaceIsWater _centerPosition) then {
        _countIsWater = _countIsWater + 1;
    };

    {
        _direction = _x getDir _centerPosition;
        _position = _x getPos [_quadrantWidth, _direction];
        if(surfaceIsWater _position) then {
            _countIsWater = _countIsWater + 1;
        };
    } forEach _bounds;

    if(_countIsWater == 5) then {
        _terrain = "SEA";
    };

    if(_countIsWater == 0) then {
        _terrain = "LAND";
    };

    if(_countIsWater > 0 && _countIsWater < 5) then {
        _terrain = "SHORE";
    };

    // Preserve sample key order, fresh arrays and the center position reference.
    _terrainData = [[
        ["sea", if (_terrain == "SEA") then {[_centerPosition]} else {[]}],
        ["land", if (_terrain == "LAND") then {[_centerPosition]} else {[]}],
        ["shore", if (_terrain == "SHORE") then {[_centerPosition]} else {[]}]
    ]] call ALIVE_fnc_hashCreate;

    // Mutate the existing data hash, as the sector data setter does. The hash
    // helpers preserve custom defaults and existing key/value ordering.
    _sectorData = [_sector, "data"] call ALIVE_fnc_hashGet;
    [_sectorData, [
        ["terrainSamples", _terrainData],
        ["terrain", _terrain]
    ]] call ALIVE_fnc_hashSetMany;

} forEach _sectors;
