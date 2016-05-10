#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(addAmbientRoomMusic);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addAmbientRoomMusic

Description:
Add ambient room msuic

Parameters:

Object - building to add light to

Returns:

Examples:
(begin example)
_light = [_building] call ALIVE_fnc_addAmbientRoomMusic
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_building","_musicSource","_colour","_brightness","_light"];

_building = _this select 0;

_musicSource = "RoadCone_L_F" createVehicle position _building;
_musicSource attachTo [_building,[1,1,1]];
hideObject _musicSource;

[_building, _musicSource] spawn {
    private ["_building", "_musicSource", "_tracksPlayed", "_totalTracks", "_trackName", "_trackDuration"];

    _building = _this select 0;
    _musicSource = _this select 1;
    _tracksPlayed = 1;
    _totalTracks = count (ALIVE_civilianHouseTracks select 1);

    while { (alive _musicSource) } do {
        while { _tracksPlayed < _totalTracks } do {
            _trackName = format["Track%1", floor (1 + (random _totalTracks))];
            _trackDuration = [ALIVE_civilianHouseTracks, _trackName] call ALIVE_fnc_hashGet;

            if(isMultiplayer) then {
                [[_building, _musicSource, _trackName],"ALIVE_fnc_clientAddAmbientRoomMusic"] call BIS_fnc_MP;
            }else{
                _musicSource say3d _trackName;
            };

            sleep _trackDuration;

            _tracksPlayed = _tracksPlayed + 1;

            if not (alive _musicSource) exitWith {};
        };

        sleep 1;
    };
};

_musicSource