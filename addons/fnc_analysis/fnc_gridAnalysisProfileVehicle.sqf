#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(gridAnalysisProfileVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_gridAnalysisProfileVehicle

Description:
Perform analysis of profile positions on passed grid

Parameters:
None

Returns:
...

Examples:
(begin example)
// add profile units to sector data
_result = [_grid] call ALIVE_fnc_gridAnalysisProfileVehicle;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private _grid = _this select 0;


// reset existing analysis data

//["RESET SECTORS"] call ALIVE_fnc_dump;
//[true] call ALIVE_fnc_timer;

private _sectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
private _updatedSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data", ["",[],[],nil]] call ALIVE_fnc_HashGet;
    //private _sectorData = _sector select 2 select 0;  //[_sector, "data"] call ALIVE_fnc_sector;

    //_sectorData call ALIVE_fnc_inspectHash;

    if (count (_sectorData select 1) > 0) then {
        if("entitiesBySide" in (_sectorData select 1)) then {
            private _sideProfiles = [_sectorData, "entitiesBySide"] call ALIVE_fnc_hashGet;
            [_sideProfiles, "EAST", []] call ALIVE_fnc_hashSet;
            [_sideProfiles, "WEST", []] call ALIVE_fnc_hashSet;
            [_sideProfiles, "CIV", []] call ALIVE_fnc_hashSet;
            [_sideProfiles, "GUER", []] call ALIVE_fnc_hashSet;

            [_sector, "data", ["entitiesBySide",_sideProfiles]] call ALIVE_fnc_sector;
        };
    };
} forEach _sectors;

//[] call ALIVE_fnc_timer;

// run analysis on all profiles

//["ANALYSE PROFILES"] call ALIVE_fnc_dump;
//[true] call ALIVE_fnc_timer;

private _profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;

{
    private _profile = _x;

    private _profileID = _profile select 2 select 4;        //[_profile,"profileID"] call ALIVE_fnc_hashGet;
    private _profileType = _profile select 2 select 5;      //[_profile,"type"] call ALIVE_fnc_hashGet;
    private _profileActive = _profile select 2 select 1;    //[_profile, "active"] call ALIVE_fnc_hashGet;
    private _side = _profile select 2 select 3;             //[_profile, "active"] call ALIVE_fnc_hashGet;

    if(_profileType == "vehicle") then {
        private ["_position"];

        if(_profileActive) then {
            private _vehicle = _profile select 2 select 10; //[_profile,"leader"] call ALIVE_fnc_hashGet;
            _position = getPosATL _vehicle;
        } else {
            _position = _profile select 2 select 2; //[_profile, "position"] call ALIVE_fnc_hashGet;
        };

        private _sector = [_grid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
        private _sectorData = [_sector, "data", ["",[],[],nil]] call ALIVE_fnc_HashGet;
        //private _sectorData = _sector select 2 select 0;  //[_sector, "data"] call ALIVE_fnc_sector;

        //_sectorData call ALIVE_fnc_inspectHash;

        if (count (_sectorData select 1) > 0) then {
            private ["_sideProfiles","_sideProfile"];

            if("vehiclesBySide" in (_sectorData select 1)) then {
                _sideProfiles = [_sectorData, "vehiclesBySide"] call ALIVE_fnc_hashGet;
                _sideProfile = [_sideProfiles, _side] call ALIVE_fnc_hashGet;
            }else{
                _sideProfiles = [] call ALIVE_fnc_hashCreate;
                [_sideProfiles, "EAST", []] call ALIVE_fnc_hashSet;
                [_sideProfiles, "WEST", []] call ALIVE_fnc_hashSet;
                [_sideProfiles, "CIV", []] call ALIVE_fnc_hashSet;
                [_sideProfiles, "GUER", []] call ALIVE_fnc_hashSet;

                [_sector, "data", ["vehiclesBySide",_sideProfiles]] call ALIVE_fnc_sector;

                _sideProfile = [_sideProfiles, _side] call ALIVE_fnc_hashGet;
            };

            _sideProfile pushback [_profileID,_position];

            // store the result of the analysis on the sector instance
            [_sector, "data", ["vehiclesBySide",_sideProfiles]] call ALIVE_fnc_sector;

            _updatedSectors pushbackunique _sector;
        };
    };

} forEach (_profiles select 2);

//[] call ALIVE_fnc_timer;

_updatedSectors