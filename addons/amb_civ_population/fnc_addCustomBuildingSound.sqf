#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(addCustomBuildingSound);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addCustomBuildingSound

Description:
Add ambient room msuic

Parameters:

Object - building to add music to.

Returns:

Examples:
(begin example)
_light = [_buildingType, _building] call ALIVE_fnc_addCustomBuildingSound
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

params ["_buildingType","_building"];
private _source = objNull;
private _customBuildingData = [ALiVE_CivPop_customBuildings,_buildingType, []] call ALiVE_fnc_hashGet;
if (count _customBuildingData > 0) then {

    // Check to see if any other special buildings within 50m
    private _nearCheck = false;
    private _nearObjects = _building nearObjects ["RoadCone_L_F", 50];
    {
        if (_x getVariable ["ALiVE_CivPop_customBuildings_type",""] == _buildingType) then {
            _nearCheck = true;
        };
    } foreach _nearObjects;

    if !(_nearCheck) then {
        private _source = "RoadCone_L_F" createVehicle position _building;
        _source attachTo [_building,[1,1,1]];
        hideObjectGlobal _source;
        _source setVariable ["ALiVE_CivPop_customBuildings_type", _buildingType, false];

        [_building, _source,_customBuildingData] spawn {
            params ["_building","_source","_customBuildingData"];
            private _sounds =  [_customBuildingData,"sounds"] call ALiVE_fnc_hashGet;
            private _times =  [_customBuildingData,"times"] call ALiVE_fnc_hashGet;
            private _tracksPlayed = 1;

            private _totalTracks = count _sounds;


            while { (alive _source) } do {
                while { _tracksPlayed < _totalTracks } do {
                    private _track = (selectRandom _sounds);
                    private _trackName =  _track select 0;
                    private _trackDuration = _track select 1;

                    {
                        private _start = _x select 0;
                        private _stop = _x select 1;
                        if (daytime >= _start AND daytime < _stop) then {
                            if(isMultiplayer) then {
                                [_building, _source, _trackName] remoteExec ["ALIVE_fnc_clientAddAmbientRoomMusic"];

                            }else{
                                _source say3d _trackName;
                            };

                            sleep _trackDuration;

                            _tracksPlayed = _tracksPlayed + 1;

                        };
                    } foreach _times;

                    if not (alive _source) exitWith {};
                };

                sleep (random 10);
            };
        };
    };
};
_source



