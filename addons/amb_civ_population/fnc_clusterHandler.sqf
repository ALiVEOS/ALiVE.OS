#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(clusterHandler);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
The main cluster handler / repository

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:

Examples:
(begin example)
// create a profile handler
_logic = [nil, "create"] call ALIVE_fnc_clusterHandler;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_clusterHandler

private ["_result"];

TRACE_1("clusterHandler - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
//_result = true;

#define MTEMPLATE "ALiVE_CLUSTERHANDLER_%1"

switch(_operation) do {

    case "init": {

        if (isServer) then {
            private["_profilesByType","_profilesBySide"];

            // if server, initialise module game logic
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;
            TRACE_1("After module init",_logic);

            // set defaults
            [_logic,"debug",false] call ALIVE_fnc_hashSet;
            [_logic,"clusters",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"clustersActive",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"clustersInActive",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
        };

    };

    case "destroy": {

        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            [_logic, "destroy"] call SUPERCLASS;
        };

    };

    case "debug": {

        if !(_args isEqualType []) then {
            _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        private _clusters = [_logic, "clusters"] call ALIVE_fnc_hashGet;

        if(count _clusters > 0) then {

            if(_args) then {
                // DEBUG -------------------------------------------------------------------------------------
                if(_args) then {
                    //["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Cluster Handler State"] call ALiVE_fnc_dump;
                    private _state = [_logic, "state"] call MAINCLASS;
                    _state call ALIVE_fnc_inspectHash;
                };
                // DEBUG -------------------------------------------------------------------------------------
            };
        };

        _result = _args;

    };

    case "state": {

        if !(_args isEqualType []) then {

            // Save state

            private _state = [] call ALIVE_fnc_hashCreate;

            // loop the class hash and set vars on the state hash
            {
                if(!(_x == "super") && !(_x == "class")) then {
                    [_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                };
            } forEach (_logic select 1);

            _result = _state;

        } else {
            ASSERT_TRUE(_args isEqualType [], str typeName _args);

            // Restore state

            // loop the passed hash and set vars on the class hash
            {
                [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
            } forEach (_args select 1);
        };

    };

    case "registerCluster": {

        if(_args isEqualType []) then {
            private _cluster = _args;

            private _clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
            private _center = [_cluster, "center"] call ALIVE_fnc_hashGet;
            private _size = [_cluster, "size"] call ALIVE_fnc_hashGet;

            // get the global hostility levels
            private _eastHostility = [ALIVE_civilianHostility,"EAST"] call ALIVE_fnc_hashGet;
            private _westHostility = [ALIVE_civilianHostility,"WEST"] call ALIVE_fnc_hashGet;
            private _indepHostility = [ALIVE_civilianHostility,"GUER"] call ALIVE_fnc_hashGet;

            // set the local hostility levels
            private _localHostility = [] call ALIVE_fnc_hashCreate;
            [_localHostility,"EAST",_eastHostility] call ALIVE_fnc_hashSet;
            [_localHostility,"WEST",_westHostility] call ALIVE_fnc_hashSet;
            [_localHostility,"GUER",_indepHostility] call ALIVE_fnc_hashSet;

            [_cluster, "hostility", _localHostility] call ALIVE_fnc_hashSet;

            // set the casualty count
            [_cluster, "casualties", 0] call ALIVE_fnc_hashSet;

            // determine which sectors the cluster is within
            private _sectors = [ALIVE_sectorGrid, "sectorsInRadius", [_center, _size]] call ALIVE_fnc_sectorGrid;
            private _sectorIDs = [];

            {
                private _sectorID = [_x, "id"] call ALIVE_fnc_sector;

                if !(isnil "_sectorID") then {_sectorIDs pushback _sectorID};
            } forEach _sectors;

            [_cluster, "sectors", _sectorIDs] call ALIVE_fnc_hashSet;

            // set as in active
            private _clustersInActive = [_logic, "clustersInActive"] call ALIVE_fnc_hashGet;
            [_clustersInActive, _clusterID, _cluster] call ALIVE_fnc_hashSet;

            private _clusters = [_logic, "clusters"] call ALIVE_fnc_hashGet;

            // store on main clusters hash
            [_clusters, _clusterID, _cluster] call ALIVE_fnc_hashSet;
        };

    };

    case "unregisterCluster": {



    };

    case "setActive": {

        _args params ["_clusterID","_cluster"];

        private _clustersInActive = [_logic, "clustersInActive"] call ALIVE_fnc_hashGet;
        private _clustersActive = [_logic, "clustersActive"] call ALIVE_fnc_hashGet;

        if(_clusterID in (_clustersInActive select 1)) then {
            [_clustersInActive, _clusterID] call ALIVE_fnc_hashRem;
        };

        [_clustersActive, _clusterID, _cluster] call ALIVE_fnc_hashSet;

    };

    case "setInActive": {

        _args params ["_clusterID","_cluster"];

        private _clustersInActive = [_logic, "clustersInActive"] call ALIVE_fnc_hashGet;
        private _clustersActive = [_logic, "clustersActive"] call ALIVE_fnc_hashGet;

        if(_clusterID in (_clustersActive select 1)) then {
            [_clustersActive, _clusterID] call ALIVE_fnc_hashRem;
        };

        [_clustersInActive, _clusterID, _cluster] call ALIVE_fnc_hashSet;

    };

    case "getCluster": {

        if(_args isEqualType "") then {
            private _clusterID = _args;
            private _clusters = [_logic, "clusters"] call ALIVE_fnc_hashGet;
            private _clusterIndex = _clusters select 1;

            if(_clusterID in _clusterIndex) then {
                _result = [_clusters, _clusterID] call ALIVE_fnc_hashGet;
            }else{
                _result = nil;
            };
        };

    };

    case "getClusters": {

        _result = [_logic, "clusters"] call ALIVE_fnc_hashGet;

    };

    case "getActive": {

        _result = [_logic, "clustersActive"] call ALIVE_fnc_hashGet;

    };

    case "getInActive": {

        _result = [_logic, "clustersInActive"] call ALIVE_fnc_hashGet;

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("clusterHandler - output",_result);

if !(isnil "_result") then {_result} else {nil};