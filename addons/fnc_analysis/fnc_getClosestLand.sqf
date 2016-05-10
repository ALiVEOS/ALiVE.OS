#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(getClosestLand);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getClosestLand

Description:
Gets the closest position that is land

Parameters:
Array - Position center point for search
Scalar - Max Radius of search

Returns:
Array - position

Examples:
(begin example)
// get closest land
_position = [getPos player, 500] call ALIVE_fnc_getClosestLand;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_getClosestLandFromSectors","_position","_radius","_result","_err", "_sector","_sectorData","_sectorTerrain","_sectorTerrainSamples","_samples","_sectors","_landPosition"];

_getClosestLandFromSectors = {

    private ["_sectors","_position","_sector","_sectorData","_sectorTerrainSamples","_samples"];

    _sectors = _this select 0;
    _position = _this select 1;

    _sectors = [_sectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;

    _result = [];

    if(count _sectors > 0) then {

        _sectors = [_sectors,_position] call ALIVE_fnc_sectorSortDistance;

        {
            _sector = _x;
            _sectorData = [_sector, "data",["",[],[],nil]] call ALIVE_fnc_hashGet;

            //_sectorData call ALIVE_fnc_inspectHash;

            _sectorTerrainSamples = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
			_samples = +([_sectorTerrainSamples, "land"] call ALIVE_fnc_hashGet);
			
			if(count _samples > 0) exitwith {
				//["GCL got land samples: %1",_samples] call ALIVE_fnc_dump;
		        
		        _samples = [_samples,[_position],{
					_x distance _Input0
		    	},"ASCEND"] call ALiVE_fnc_SortBy;
		        
		        if (count _samples > 10) then {_samples resize 10};
		        
				_result = _samples select (floor(random((count _samples)-1)));
			};
        } forEach _sectors;
    };
    
    _result
};
	
_position = _this select 0;
//_radius = _this select 1;

_err = format["get closest land requires a position array - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);
//_err = format["get closest land requires a radius scalar - %1",_radius];
//ASSERT_TRUE(typeName _radius == "SCALAR",_err);

_sector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
_sectorData = [_sector, "data"] call ALIVE_fnc_hashGet;

if (isnil "_sectorData") exitwith {_position};

_sectorTerrain = [_sectorData, "terrain"] call ALIVE_fnc_hashGet;

// the positions sector is terrain shore
// we can get a land position there
if(_sectorTerrain == "SHORE") then {

	//["GCL - sector terrain is shore"] call ALIVE_fnc_dump;
    
    //Worse results with BIS_fnc_Safepos when looking for a shore
    //_landPosition = [_position, 0, 500, 1, 0, 100, 1, [], [_position]] call BIS_fnc_findSafePos;
    
    _sectorTerrainSamples = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
	_samples = +([_sectorTerrainSamples, "land"] call ALIVE_fnc_hashGet);
    
    //Some shores dont have land terrain samples, fallback to shore samples
    if!(count _samples > 0) then {_samples = +([_sectorTerrainSamples, "shore"] call ALIVE_fnc_hashGet)};
	
	if(count _samples > 0) then {
		//["GCL got land samples: %1",_samples] call ALIVE_fnc_dump;
        
        _samples = [_samples,[_position],{
			_x distance _Input0
    	},"ASCEND"] call ALiVE_fnc_SortBy;
        
        if (count _samples > 10) then {_samples resize 10};
        
		_landPosition = _samples select (floor(random((count _samples)-1)));
	};
};

// the positions sector is terrain sea
// get the surrounding sectors to check if there are any shore positions
// if so spawn on a random land position
if(_sectorTerrain == "SEA") then {

    _sectors = [ALIVE_sectorGrid, "surroundingSectors", _position] call ALIVE_fnc_sectorGrid;

    _landPosition = [_sectors,_position] call _getClosestLandFromSectors;

    if(count _landPosition == 0) then {

        //["GCL - no land found in surrounding sectors, expanding search"] call ALIVE_fnc_dump;

        _sectors = [ALIVE_sectorGrid, "sectorsInRadius", [_position, 3000]] call ALIVE_fnc_sectorGrid;

        _landPosition = [_sectors,_position] call _getClosestLandFromSectors;

        if(count _landPosition == 0) then {

            //["GCL - no land found within 3000m, expanding search"] call ALIVE_fnc_dump;

            _sectors = [ALIVE_sectorGrid, "sectorsInRadius", [_position, 5000]] call ALIVE_fnc_sectorGrid;

            _landPosition = [_sectors,_position] call _getClosestLandFromSectors;

            if(count _landPosition == 0) then {

                //["GCL - no land found within 5000m, expanding search"] call ALIVE_fnc_dump;

                _sectors = [ALIVE_sectorGrid, "sectorsInRadius", [_position, 10000]] call ALIVE_fnc_sectorGrid;

                _landPosition = [_sectors,_position] call _getClosestLandFromSectors;

            };
        };
    };
};			

if !(isnil "_landPosition") then {_landPosition set [2,0]; _landPosition} else {_position};