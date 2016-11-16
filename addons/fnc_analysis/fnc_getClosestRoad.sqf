#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(getClosestRoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getClosestRoad

Description:
Gets the closest position that is road

Parameters:
Array - Position center point for search
Scalar - Max Radius of search

Returns:
Array - position

Examples:
(begin example)
// get closest road
_position = [getPos player, 500] call ALIVE_fnc_getClosestRoad;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private _position = _this select 0;
//private _radius = _this select 1;

private _err = format["get closest road requires a position array - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);
//_err = format["get closest sea requires a radius scalar - %1",_radius];
//ASSERT_TRUE(typeName _radius == "SCALAR",_err);

private _sector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
private _sectorData = [_sector, "data"] call ALIVE_fnc_hashGet;

if (isnil "_sectorData") exitwith {_position};

private _sectorRoads = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
private _roads = [_sectorRoads, "road"] call ALIVE_fnc_hashGet;

if(count _roads > 0) then {
    _roads = [_sectorData, "roads", [_position, "road"]] call ALIVE_fnc_sectorDataSort;
    private _road = _roads select 0;
    _position = _road select 0;
}else{
    private _sectors = [ALIVE_sectorGrid, "surroundingSectors", _position] call ALIVE_fnc_sectorGrid;
    _sectors = [_sectors] call ALIVE_fnc_sectorFilterRoads;

    if(count _sectors > 0) then {
        _sectors = [_sectors,_position] call ALIVE_fnc_sectorSortDistance;
        _sector = _sectors select 0;
        _sectorData = [_sector, "data"] call ALIVE_fnc_hashGet;
        _sectorRoads = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
        _roads = [_sectorData, "roads", [_position, "road"]] call ALIVE_fnc_sectorDataSort;

        private ["_road"];

        if(count _roads > 10) then {
            _road = _roads select (floor(random((count _roads)-1 / 10)));
        }else{
            _road = _roads select (floor(random((count _roads)-1)));
        };

        _position = _road select 0;
    };
};

_position