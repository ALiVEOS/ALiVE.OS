#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(ZEUSinit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ZEUSinit

Description:
Inits ZEUS including backwardcompatibility (to be removed after release)
Sets a clientside loop that merges ZEUS module position globally with the local ZEUS camera position.
This way all localities know about ZEUS modules position and server can spawn ALiVE AI when the curator
moves around with the cam without the use of PVS/PV/BUS and minimising network traffic.

Notes:
dynamic helperfunctions to be removed when commands are available in public, start/end loop if EH for "Zeus called" exists
Important, enable  in Post Init during XEH_postInit.sqf!

Parameters:
none

Examples:
(begin example)
call ALIVE_fnc_ZEUSinit;
(end)

See Also:
- Main/eventhandlers.hpp
- Main/XEH_postInit.sqf
- Main/fnc_anyPlayersInRangeIncludeAir.sqf

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

//Exit if Zeus not placed with an empty default function to save perf
if !(["ModuleCurator_F"] call ALiVE_fnc_isModuleAvailable) exitwith {ALiVE_fnc_ZeusRegister = {}};

//Register dynamic helperfunction on all localities
ALiVE_fnc_ZeusRegister = {
    [_this] spawn {
        private ["_unit"];
        _unit = _this select 0;
        {_x addCuratorEditableObjects [_unit]} foreach allCurators;
    };
};

// Mark what a Zeus places, so Civilian Population leaves a Zeus-placed civilian to the Zeus:
// its check reads ALiVE_curator_placed, which nothing ever set. The event fires on the Zeus
// player's machine, so every machine hooks the curators it has, and any added later, and the
// mark is sent to all. A placed group marks each of its men, a vehicle its crew.
ALiVE_fnc_ZeusMarkPlaced = {
    params ["_curator", "_entity"];
    private _marked = [_entity] + (crew _entity);
    if (_entity isKindOf "CAManBase") then { _marked append (units group _entity) };
    { _x setVariable ["ALiVE_curator_placed", true, true] } forEach (_marked arrayIntersect _marked);
};
[] spawn {
    private _hooked = [];
    while {true} do {
        {
            if !(_x in _hooked) then {
                _x addEventHandler ["CuratorObjectPlaced", ALiVE_fnc_ZeusMarkPlaced];
                _hooked pushBack _x;
            };
        } forEach allCurators;
        sleep 10;
    };
};

//BIS give me an EH when Zeus is active so I can start and end that loop
//Run loop only on clients
if (hasInterface) then {
    [] spawn {
        private ["_curatorLogic","_curatorCamPos"];
        
        while {true} do {
            private _curatorLogic = getAssignedCuratorLogic player;

            if !(isnil "_curatorLogic") then {
                if !(isnull curatorcamera) then {
                    //["Zeus is active"] call ALiVE_fnc_DumpR;

                    _curatorCamPos = getposATL curatorcamera;
                    _curatorLogic setposATL _curatorCamPos;
                } else {
                    if (cameraOn == vehicle player) then {
                        //["Zeus is inactive and no unit is remote controlled"] call ALiVE_fnc_DumpR;

                        _curatorLogic setposATL [-5000,-5000,5000];
                    } else {
                        if !(isNull cameraOn) then {
                            //["Zeus is inactive and unit %1 is remote controlled",_controlledObject] call ALiVE_fnc_DumpR;
                            
                            _curatorCamPos = getposATL cameraOn;
                            _curatorLogic setposATL _curatorCamPos;
                        };
                    };
                };
            };
            sleep 1;
        };
    };
};