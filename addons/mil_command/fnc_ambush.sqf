#include <\x\alive\addons\mil_command\script_component.hpp>
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

    waituntil {sleep 2; {alive _x && _x distance _destination < 50} count _units > 0 || count _units == 0};

    private _roads = _destination nearRoads 50;

    if (count _roads > 0) then {
        {
            private _agent = _x;

            [_agent, getposATL (selectRandom _roads)] call ALiVE_fnc_doMoveRemote;

            sleep 5;

            _agent playActionNow "PutDown";
            private _bomb = "DemoCharge_Remote_Ammo_Scripted" createVehicle (getposATL _agent);
            _bomb setposATL (getposATL _agent);

            _bombs pushBack _bomb;
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

        [_group,_newPosition] call ALiVE_fnc_MoveRemote;
        _group setbehaviour "AWARE";
        _group setSpeedmode "NORMAL";

        [_bombs,_destination] spawn {
            private _time = time; waituntil {sleep 2; {_x distance (_this select 1) < 20} count vehicles > 0 || {time - _time > 1800}};

            // timeout
            if (time - _time >= 1800) then {
                {deletevehicle _x} foreach (_this select 0);
            // detonate
            } else {
                {_x setdamage 1} foreach (_this select 0);
            };
        };
    };
};
