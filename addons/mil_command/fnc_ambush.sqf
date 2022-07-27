#include "\x\alive\addons\mil_command\script_component.hpp"
SCRIPT(ambush);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ambush

Description:
Garrison command for active units, run on spawn of profiles for guarding of objectives via placement modules

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
[_profile, "setActiveCommand", ["ALIVE_fnc_ambush","spawn",[_destinationPos]]] call ALIVE_fnc_profileEntity;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_profile", ["",[],[],nil], [[]]],
    ["_params", [], [[]]]
];

//["Params %1",_params] call AliVE_fnc_DumpH; getRelDir

private _destination = [_params, 2, [0,0,0], [[]]] call BIS_fnc_param;

if (isnil "_profile") exitwith {};

private _profileID = [_profile,"profileID"] call ALiVE_fnc_HashGet;
private _type = [_profile,"type",""] call ALiVE_fnc_HashGet;
private _assignments = [_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_HashGet;
private _pos = [_profile,"position"] call ALiVE_fnc_HashGet;
private _bombs = [];

if (isnil "_pos") exitwith {};

waituntil {sleep 0.5; [_profile,"active"] call ALiVE_fnc_HashGet};
waituntil {sleep 0.5; !isnil {(_profile select 2 select 13)} && {!isnull (_profile select 2 select 13)}};

if (_type == "entity") then {
    private ["_driver","_gunner","_inVehicle"];

    private _group = _profile select 2 select 13;
    private _units = +(units _group);

    //["Waiting for Entity to arrive!"] call AliVE_fnc_DumpH;
    waituntil {sleep 2; {alive _x && _x distance _destination < 50} count _units > 0 || count _units == 0};

    private _roads = _destination nearRoads 50;

    if (count _roads > 0) then {

        //["Entity arrived and Roads found!"] call AliVE_fnc_DumpH;
        {
            private _agent = _x;
            private _road = selectRandom _roads;

            [_agent, _road, _bombs] spawn {

                private _agent = _this select 0;
                private _road = _this select 1;
                private _bombs = _this select 2;

                private _bombTypes = ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo"];
                private _roadPos = _road getRelPos [4,90];

                private _time = time;
                private _timeout = 30;

                [_agent, _roadPos] call ALiVE_fnc_doMoveRemote;

                waituntil {_agent call ALiVE_fnc_UnitReadyRemote || {time - _time >= _timeout}};

                private _bombPos = getposATL _agent; 
                
                //set pos a little below ground to not make IED object clip
                _bombPos set [2,-0.1];

                //["Creating IED at %1!",_bombPos] call AliVE_fnc_DumpH;
                private _bombObject = createVehicle [selectRandom _bombTypes, _bombPos, [], 0, "CAN_COLLIDE"];

                //place real mine a little above IED or they won't explode
                _bombPos set [2,0.1];

                //Create real mine
                private _bomb = createMine [selectRandom ["ATMine","APERSMine"], _bombPos, [], 0];

                //disableSim to not make them explode on placement (esp. happening for APERS)
                _bomb enableSimulationGlobal false;
                _bomb hideObjectGlobal true;

                _agent playActionNow "PutDown";

                _bombs pushBack _bomb;
                _bombs pushBack _bombObject;
            };
        } foreach _units;

        private _newPosition = [
            _destination,
            100,
            250,
            1,
            0,
            100,
            0,
            [],
            [_destination]
        ] call BIS_fnc_findSafePos;

        //["Entity moves off site!"] call AliVE_fnc_DumpH;
        [_group,_newPosition] call ALiVE_fnc_MoveRemote;
        _group setbehaviour "AWARE";
        _group setSpeedmode "NORMAL";

        [_bombs,_destination] spawn {
            private _time = time;
            private _timeout = 1800;

            sleep 30;

            //["Enabling bombs!"] call AliVE_fnc_DumpH;
            {_x enableSimulationGlobal true} foreach (_this select 0);
            
            waituntil {sleep 10; time - _timeout > 1800};

            //["Cleaning up whats left"] call AliVE_fnc_DumpH;
            {deletevehicle _x} foreach (_this select 0);
        };
    };
};
