#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(civilianPopulationSystem);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civilianPopulationSystem
Description:
Main class for civilian population system

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh

Examples:
(begin example)
// create the
_logic = [nil, "init"] call ALIVE_fnc_civilianPopulationSystem;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_civilianPopulationSystem

TRACE_1("civilianPopulationSystem - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = true;

#define MTEMPLATE "ALiVE_CIVILIANPOPULATIONSYSTEM_%1"

switch(_operation) do {

    case "init": {

        if (isServer) then {
                // if server, initialise module game logic
                [_logic,"super",SUPERCLASS] call ALIVE_fnc_hashSet;
                [_logic,"class",MAINCLASS] call ALIVE_fnc_hashSet;
                [_logic,"moduleType","ALIVE_civilianPopulationSystem"] call ALIVE_fnc_hashSet;
                [_logic,"startupComplete",false] call ALIVE_fnc_hashSet;
                //TRACE_1("After module init",_logic);

                [_logic,"debug",false] call ALIVE_fnc_hashSet;
                [_logic,"spawnRadius",1000] call ALIVE_fnc_hashSet;
                [_logic,"spawnTypeJetRadius",1000] call ALIVE_fnc_hashSet;
                [_logic,"spawnTypeHeliRadius",1000] call ALIVE_fnc_hashSet;
                [_logic,"activeLimiter",30] call ALIVE_fnc_hashSet;
                [_logic,"spawnCycleTime",5] call ALIVE_fnc_hashSet;
                [_logic,"despawnCycleTime",1] call ALIVE_fnc_hashSet;
                [_logic,"listenerID",""] call ALIVE_fnc_hashSet;

        };

    };

    case "start": {

        if (isServer) then {

            waituntil {!(isnil "ALIVE_profileSystemInit")};
            
            private _debug = [_logic,"debug",false] call ALIVE_fnc_hashGet;
            private _spawnRadius = [_logic,"spawnRadius"] call ALIVE_fnc_hashGet;
            private _spawnTypeJetRadius = [_logic,"spawnTypeJetRadius"] call ALIVE_fnc_hashGet;
            private _spawnTypeHeliRadius = [_logic,"spawnTypeHeliRadius"] call ALIVE_fnc_hashGet;
            private _activeLimiter = [_logic,"activeLimiter"] call ALIVE_fnc_hashGet;
            private _spawnCycleTime = [_logic,"spawnCycleTime"] call ALIVE_fnc_hashGet;
            private _despawnCycleTime = [_logic,"despawnCycleTime"] call ALIVE_fnc_hashGet;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE CivilianPopulationSystem - Startup"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // create the cluster handler
            ALIVE_clusterHandler = [nil, "create"] call ALIVE_fnc_clusterHandler;
            [ALIVE_clusterHandler, "init"] call ALIVE_fnc_clusterHandler;
            [ALIVE_clusterHandler, "debug", _debug] call ALIVE_fnc_clusterHandler;

            // create the agent handler
            ALIVE_agentHandler = [nil, "create"] call ALIVE_fnc_agentHandler;
            [ALIVE_agentHandler, "init"] call ALIVE_fnc_agentHandler;

            // create command router
            ALIVE_civCommandRouter = [nil, "create"] call ALIVE_fnc_civCommandRouter;
            [ALIVE_civCommandRouter, "init"] call ALIVE_fnc_civCommandRouter;
            [ALIVE_civCommandRouter, "debug", _debug] call ALIVE_fnc_civCommandRouter;

            // turn on debug again to see the state of the agent handler, and set debug on all a agents
            [ALIVE_agentHandler, "debug", _debug] call ALIVE_fnc_agentHandler;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE CivilianPopulationSystem - Startup completed"] call ALIVE_fnc_dump;
                ["ALIVE Cluster handler created"] call ALIVE_fnc_dump;
                ["ALIVE Agent handler created"] call ALIVE_fnc_dump;
                ["ALIVE Civ command router created"] call ALIVE_fnc_dump;
                ["ALIVE Active Limit: %1", _activeLimiter] call ALIVE_fnc_dump;
                ["ALIVE Spawn Radius: %1", _spawnRadius] call ALIVE_fnc_dump;
                ["ALIVE Spawn in Jet Radius: %1",_spawnTypeJetRadius] call ALIVE_fnc_dump;
                ["ALIVE Spawn in Heli Radius: %1",_spawnTypeHeliRadius] call ALIVE_fnc_dump;
                ["ALIVE Spawn Cycle Time: %1", _spawnCycleTime] call ALIVE_fnc_dump;
                ["ALIVE Initial civilian hostility settings:"] call ALIVE_fnc_dump;
                ALIVE_civilianHostility call ALIVE_fnc_inspectHash;

                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // set module as started
            [_logic,"startupComplete",true] call ALIVE_fnc_hashSet;

            // start the cluster activator
            private _clusterActivatorFSM = [_logic,_spawnRadius,_spawnTypeJetRadius,_spawnTypeHeliRadius,_spawnCycleTime,_activeLimiter] execFSM "\x\alive\addons\amb_civ_population\clusterActivator_v2.fsm";
            [_logic,"activator_FSM",_clusterActivatorFSM] call ALIVE_fnc_hashSet;

            // start listening for events
            [_logic,"listen"] call MAINCLASS;

        };

    };

    case "listen": {

        private _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["AGENT_KILLED"]]] call ALIVE_fnc_eventLog;
        [_logic,"listenerID", _listenerID] call ALIVE_fnc_hashSet;

    };

    case "handleEvent": {

        if(_args isEqualType []) then {

            private _debug = [_logic, "debug"] call MAINCLASS;
            private _event = _args;
            private _eventData = [_event,"data"] call ALIVE_fnc_hashGet;

            private  _position = _eventData select 0;
            private _killerSide = _eventData select 3;

            // update nearby cluster hostility levels
            // on agent killed

            private _sector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
            private _sectors = [ALIVE_sectorGrid, "surroundingSectors", _position] call ALIVE_fnc_sectorGrid;

            _sectors pushback _sector;

            {
                private _sectorData = [_x, "data",["",[],[],nil]] call ALIVE_fnc_HashGet;
                if("clustersCiv" in (_sectorData select 1)) then {
                    private _civClusters = [_sectorData,"clustersCiv"] call ALIVE_fnc_hashGet;
                    private _settlementClusters = [_civClusters,"settlement"] call ALIVE_fnc_hashGet;
                    {
                        private _clusterID = _x select 1;
                        private _cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;

                        if!(isNil "_cluster") then {

                            private _clusterHostility = [_cluster, "hostility"] call ALIVE_fnc_hashGet;
                            private _clusterCasualties = [_cluster, "casualties"] call ALIVE_fnc_hashGet;

                            _clusterCasualties = _clusterCasualties + 1;

                            // update the casualty count
                            [_cluster, "casualties", _clusterCasualties] call ALIVE_fnc_hashSet;

                            // update the hostility level
                            if(_killerSide in (_clusterHostility select 1)) then {
                                private _killerClusterHostility = [_clusterHostility, _killerSide] call ALIVE_fnc_hashGet;
                                _killerClusterHostility = _killerClusterHostility + 10;
                                [_clusterHostility,_killerSide,_killerClusterHostility] call ALIVE_fnc_hashSet;
                                [_cluster,"hostility",_clusterHostility] call ALIVE_fnc_hashSet;
                            };

                        };

                    } forEach _settlementClusters;
                };
            } forEach _sectors;

        };

    };

    case "pause": {

        if !(_args isEqualType true) then {
                _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(_args isEqualType true, str _args);

        if(_args) then {

            private _clusterActivatorFSM = [_logic, "activator_FSM"] call ALiVE_fnc_HashGet;
            _clusterActivatorFSM setFSMVariable ["_pause",true];

            [ALIVE_civCommandRouter, "pause", true] call ALIVE_fnc_civCommandRouter;

        }else{

            private _clusterActivatorFSM = [_logic, "activator_FSM"] call ALiVE_fnc_HashGet;
            _clusterActivatorFSM setFSMVariable ["_pause",false];

            [ALIVE_civCommandRouter, "pause", false] call ALIVE_fnc_civCommandRouter;

        };

        _result = _args;

    };

    case "destroy": {

        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            [_logic, "destroy"] call SUPERCLASS;

            private _clusterActivatorFSM = [_logic, "activator_FSM"] call ALiVE_fnc_HashGet;
            _clusterActivatorFSM setFSMVariable ["_destroy",true];

        };

    };

    case "debug": {

        if !(_args isEqualType true) then {
            _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(_args isEqualType true, str _args);

        _result = _args;

    };

    case "spawnRadius": {

        if(_args isEqualType 0) then {
            [_logic,"spawnRadius",_args] call ALIVE_fnc_hashSet;
            ALIVE_spawnRadiusCiv = _args;
        };

        _result = [_logic,"spawnRadius"] call ALIVE_fnc_hashGet;

    };

    case "spawnTypeJet": {

        if !(_args isEqualType true) then {
            _args = [_logic,"spawnTypeJet"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"spawnTypeJet",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(_args isEqualType true, str _args);

        _result = _args;

    };

    case "spawnTypeJetRadius": {

        if(_args isEqualType 0) then {
            [_logic,"spawnTypeJetRadius",_args] call ALIVE_fnc_hashSet;
            ALIVE_spawnRadiusCivJet = _args;
        };

        _result = [_logic,"spawnTypeJetRadius"] call ALIVE_fnc_hashGet;

    };

    case "spawnTypeHeli": {

        if !(_args isEqualType true) then {
            _args = [_logic,"spawnTypeHeli"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"spawnTypeHeli",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(_args isEqualType true, str _args);

        _result = _args;

    };

    case "spawnTypeHeliRadius": {

        if(_args isEqualType 0) then {
            [_logic,"spawnTypeHeliRadius",_args] call ALIVE_fnc_hashSet;
            ALIVE_spawnRadiusCivHeli = _args;
        };

        _result = [_logic,"spawnTypeHeliRadius"] call ALIVE_fnc_hashGet;

    };

    case "activeLimiter": {

        if(_args isEqualType 0) then {
            [_logic,"activeLimiter",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"activeLimiter"] call ALIVE_fnc_hashGet;

    };

    case "ambientCivilianRoles": {

        if(_args isEqualType []) then {
            [_logic,"ambientCivilianRoles",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"ambientCivilianRoles"] call ALIVE_fnc_hashGet;

    };

    case "state": {

        if !(_args isEqualType []) then {
            // Save state

            private _state = [] call ALIVE_fnc_hashCreate;

            // BaseClassHash CHANGE
            // loop the class hash and set vars on the state hash
            {
                if(!(_x == "super") && !(_x == "class")) then {
                    [_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                };
            } forEach (_logic select 1);

            _result = _state;
        } else {
            ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

            // Restore state

            // BaseClassHash CHANGE
            // loop the passed hash and set vars on the class hash
            {
                [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
            } forEach (_args select 1);
        };

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("civilianPopulationSystem - output",_result);

_result;