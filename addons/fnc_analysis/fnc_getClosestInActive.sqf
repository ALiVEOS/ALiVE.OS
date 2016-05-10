#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(getClosestInActive);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getClosestInActive

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
_position = [getPos player] call ALIVE_fnc_getClosestInActive;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_radius","_result","_err", "_sector","_sectorData","_active","_roads","_road","_sectors"];
	
_position = _this select 0;
//_radius = _this select 1;

_err = format["get closest inactive requires a position array - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);
//_err = format["get closest sea requires a radius scalar - %1",_radius];
//ASSERT_TRUE(typeName _radius == "SCALAR",_err);

_sector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
_sectorData = [_sector, "data",["",[],[],nil]] call ALIVE_fnc_hashGet;

if("active" in (_sectorData select 1)) then {
    _active = [_sectorData, "active"] call ALIVE_fnc_hashGet;

    if(count _active > 0) then {

    	_sectors = [ALIVE_sectorGrid, "surroundingSectors", _position] call ALIVE_fnc_sectorGrid;
    	_sectors = [_sectors,false] call ALIVE_fnc_sectorFilterActive;

    	if(count _sectors > 0) then {
    		_sectors = [_sectors,_position] call ALIVE_fnc_sectorSortDistance;
    		_sector = _sectors select 0;
    		_position = [_sector, "center"] call ALIVE_fnc_sector;
    	}

    };
};

_result = _position;
_result