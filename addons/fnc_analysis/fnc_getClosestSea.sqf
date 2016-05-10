#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(getClosestSea);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getClosestSea

Description:
Gets the closest position that is sea

Parameters:
Array - Position center point for search
Boolean - Option to be closest sector or nearby sector

Returns:
Array - position

Examples:
(begin example)
// get closest land
_position = [getPos player, 500] call ALIVE_fnc_getClosestSea;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_radius","_result","_err", "_sector","_sectorData","_sectorTerrain","_sectorTerrainSamples","_samples","_sectors","_closest"];

_position = _this select 0;
//_radius = _this select 1;
if (count _this > 1) then {_closest = _this select 1;} else { _closest = true;};

_result = _position;

_err = format["get closest sea requires a position array - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);
//_err = format["get closest sea requires a radius scalar - %1",_radius];
//ASSERT_TRUE(typeName _radius == "SCALAR",_err);

_sector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
_sectorData = [_sector, "data"] call ALIVE_fnc_hashGet;

if (isnil "_sectorData") exitwith {_position};

_sectorTerrain = [_sectorData, "terrain"] call ALIVE_fnc_hashGet;

// the positions sector is terrain shore
// we can get a sea position there
if(_sectorTerrain == "SHORE" && _closest) then {

	//["GCS - sector terrain is shore"] call ALIVE_fnc_dump;
	_sectorTerrainSamples = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
	_samples = [_sectorTerrainSamples, "sea"] call ALIVE_fnc_hashGet;

	if(count _samples > 0) then {
		//["GCS got sea samples: %1",_samples] call ALIVE_fnc_dump;
		if (count _samples == 1) then {
			_result = _samples select 0;
		} else {
			_result = _samples select (ceil(random (count _samples))-1);
		};
		_result set [2,0];
	};
};

// the positions sector is terrain land
// get the surrounding sectors to check if there are any shore positions
// if so spawn on a random sea position
if(_sectorTerrain == "LAND" || !_closest) then {

	//["GCS - sector terrain is land"] call ALIVE_fnc_dump;
	_sectors = [ALIVE_sectorGrid, "surroundingSectors", _position] call ALIVE_fnc_sectorGrid;

	_sectors = [_sectors, "sea"] call ALIVE_fnc_sectorFilterTerrain;
	//["GCS - sea sectors %1", _sectors] call ALIVE_fnc_dump;

	if(count _sectors > 0) then {
		_sectors = [_sectors,_position] call ALIVE_fnc_sectorSortDistance;
		if (_closest || count _sectors == 1) then {
			_sector = _sectors select 0;
		} else {
			//["GCS got sea sectors: %1",_sectors] call ALIVE_fnc_dump;
			_sector = _sectors select (ceil(random (count _sectors/2))-1);
		};
		_sectorData = [_sector, "data"] call ALIVE_fnc_hashGet;

        if (isnil "_sectorData") exitwith {_position};

		_sectorTerrainSamples = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
		_samples = [_sectorTerrainSamples, "sea"] call ALIVE_fnc_hashGet;

		if(count _samples > 0) then {
			//["GCS got sea samples: %1",_samples] call ALIVE_fnc_dump;
			if (count _samples == 1) then {
				_result = _samples select 0;
			} else {
				_result = _samples select (ceil(random (count _samples))-1);
			};
			_result set [2,0];
			//[str(random 1000), _result, "ICON",[1,1],"COLOR:","ColorRed","TYPE:","mil_dot"] call CBA_fnc_createMarker;
		};
	}else{
		// not sure what to do here, they are out to sea...
	};
};

_result