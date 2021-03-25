#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(addAmbientRoomMusic);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addAmbientRoomMusic

Description:
Add ambient room msuic

Parameters:

Object - building to add music to.

Returns:

Examples:
(begin example)
_light = [_building, _faction] call ALIVE_fnc_addAmbientRoomMusic
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_building",["_faction","CIV"]];

private _musicSource = "RoadCone_L_F" createVehicle position _building;
_musicSource attachTo [_building,[1,1,1]];
hideObjectGlobal _musicSource;

[_building, _musicSource,_faction] spawn {
    params ["_building","_musicSource","_faction"];
    private _tracksPlayed = 1;
    private _source = [ALIVE_civilianFactionHouseTracks, _faction, []] call ALIVE_fnc_hashGet;
    if (count _source == 0) then {
        _source = ALIVE_civilianHouseTracks;
    };
    private _totalTracks = count (_source select 1);

    while { (alive _musicSource) } do {
        while { _tracksPlayed < _totalTracks } do {
            private _trackName = selectRandom (_source select 1);

            // Don't play night sounds during the day
            if (_trackName in ALiVE_CivPop_NightSounds && daytime < 21 && dayTime > 3) then {
                _trackName = "ALiVE_Civpop_Audio_18";
            };

            private _trackDuration = [_source, _trackName, 30] call ALIVE_fnc_hashGet;

            if(isMultiplayer) then {
                [_building, _musicSource, _trackName] remoteExec ["ALIVE_fnc_clientAddAmbientRoomMusic"];

            }else{
                _musicSource say3d _trackName;
            };

            sleep _trackDuration;

            _tracksPlayed = _tracksPlayed + 1;

            if not (alive _musicSource) exitWith {};
        };

        sleep (random 10);
    };
};

_musicSource