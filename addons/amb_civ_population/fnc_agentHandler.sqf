#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(agentHandler);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
The main agent handler / repository

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state
Hash - registerAgent - Agent hash to register on the handler
Hash - unregisterAgent - Agent hash to unregister on the handler
String - getAgent - Agent object id to get agent by
None - getAgents
String - getAgentsByCluster - String profile type to get filtered array of agents by

Examples:
(begin example)
// create a agent handler
_logic = [nil, "create"] call ALIVE_fnc_agentHandler;

// init agent handler
_result = [_logic, "init"] call ALIVE_fnc_agentHandler;

// register a agent
_result = [_logic, "registerAgent", _agent] call ALIVE_fnc_agentHandler;

// unregister a agent
_result = [_logic, "unregisterAgent", _agent] call ALIVE_fnc_agentHandler;

// get a agent by id
_result = [_logic, "getAgent", "agent_01"] call ALIVE_fnc_agentHandler;

// get hash of all agents
_result = [_logic, "getAgents"] call ALIVE_fnc_agentHandler;

// get agents by cluster
_result = [_logic, "getProfilesByCluster", "C_0"] call ALIVE_fnc_agentHandler;

// get object state
_state = [_logic, "state"] call ALIVE_fnc_agentHandler;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_agentHandler

private ["_logic","_operation","_args","_result"];

TRACE_1("agentHandler - input",_this);

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
//_result = true;

#define MTEMPLATE "ALiVE_AGENTHANDLER_%1"

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
            [_logic,"agents",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"agentsByCluster",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"agentsActive",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"agentsInActive",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"activeAgents",[]] call ALIVE_fnc_hashSet;
            [_logic,"agentCount",0] call ALIVE_fnc_hashSet;

            [_logic,"agentsByCluster",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

        };
    };
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
                [_logic, "destroy"] call SUPERCLASS;
        };
    };
    case "debug": {
        private["_agents"];

        if(typeName _args != "BOOL") then {
                _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _agents = [_logic, "agents"] call ALIVE_fnc_hashGet;

        if(count _agents > 0) then {
            {
                _result = [_x, "debug", false] call ALIVE_fnc_civilianAgent;
            } forEach (_agents select 2);

            if(_args) then {
                {
                    _result = [_x, "debug", true] call ALIVE_fnc_civilianAgent;
                } forEach (_agents select 2);

                // DEBUG -------------------------------------------------------------------------------------
                if(_args) then {
                    //["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    //["ALIVE Agent Handler State"] call ALIVE_fnc_dump;
                    //_state = [_logic, "state"] call MAINCLASS;
                    //_state call ALIVE_fnc_inspectHash;
                };
                // DEBUG -------------------------------------------------------------------------------------
            };
        };

        _result = _args;
    };
    case "state": {
        private["_state"];

        if(typeName _args != "ARRAY") then {

                // Save state

                _state = [] call ALIVE_fnc_hashCreate;

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

                // loop the passed hash and set vars on the class hash
                {
                    [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                } forEach (_args select 1);
        };
    };
    case "registerAgent": {
        private["_agent","_agentID","_agents","_agentsByCluster","_agentsActive","_activeAgents","_agentsInActive","_agentSide","_agentType","_agentID","_agentCluster","_agentPosition","_agentActive","_agentsCluster"];

        if(typeName _args == "ARRAY") then {
            _agent = _args;

            _agents = [_logic, "agents"] call ALIVE_fnc_hashGet;
            _agentsByCluster = [_logic, "agentsByCluster"] call ALIVE_fnc_hashGet;
            _agentsActive = [_logic, "agentsActive"] call ALIVE_fnc_hashGet;
            _agentsInActive = [_logic, "agentsInActive"] call ALIVE_fnc_hashGet;
            _activeAgents = [_logic, "activeAgents"] call ALIVE_fnc_hashGet;

            _agentSide = [_agent, "side"] call ALIVE_fnc_hashGet;
            _agentType = [_agent, "type"] call ALIVE_fnc_hashGet;
            _agentID = [_agent, "agentID"] call ALIVE_fnc_hashGet;
            _agentCluster = [_agent, "homeCluster"] call ALIVE_fnc_hashGet;
            _agentPosition = [_agent, "position"] call ALIVE_fnc_hashGet;
            _agentActive = [_agent, "active"] call ALIVE_fnc_hashGet;

            // store on main agent hash
            [_agents, _agentID, _agent] call ALIVE_fnc_hashSet;

            // DEBUG -------------------------------------------------------------------------------------
            if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                [_agent, "debug", true] call ALIVE_fnc_civilianAgent;
                ["ALIVE Agent Handler"] call ALIVE_fnc_dump;
                ["Register Agent [%1]",_agentID] call ALIVE_fnc_dump;
                _agent call ALIVE_fnc_inspectHash;
            };
            // DEBUG -------------------------------------------------------------------------------------

            private["_profilesFaction","_profilesFactionType","_profilesFactionVehicleType"];

            // store reference to main agent on by cluster hash
            if(_agentCluster in (_agentsByCluster select 1)) then {
                _agentsCluster = [_agentsByCluster, _agentCluster] call ALIVE_fnc_hashGet;
            }else{
                [_agentsByCluster, _agentCluster, [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                _agentsCluster = [_agentsByCluster, _agentCluster] call ALIVE_fnc_hashGet;
            };

            [_agentsCluster, _agentID, _agent] call ALIVE_fnc_hashSet;

            if(_agentActive) then {
                if(_agentType == "agent") then {
                    _activeAgents set [count _activeAgents, _agentID];
                };
                [_agentsActive, _agentID, _agent] call ALIVE_fnc_hashSet;
            }else{
                [_agentsInActive, _agentID, _agent] call ALIVE_fnc_hashSet;
            };
        };
    };
    case "unregisterAgent": {
        private["_agent","_agentID","_agents","_agentsByCluster","_agentsActive","_agentsInActive","_activeAgents","_agentSide","_agentType","_agentID","_agentCluster","_agentPosition","_agentActive","_agentsCluster"];

        if(typeName _args == "ARRAY") then {
            _agent = _args;

            _agents = [_logic, "agents"] call ALIVE_fnc_hashGet;
            _agentsByCluster = [_logic, "agentsByCluster"] call ALIVE_fnc_hashGet;
            _agentsActive = [_logic, "agentsActive"] call ALIVE_fnc_hashGet;
            _agentsInActive = [_logic, "agentsInActive"] call ALIVE_fnc_hashGet;
            _activeAgents = [_logic, "activeAgents"] call ALIVE_fnc_hashGet;

            _agentSide = [_agent, "side"] call ALIVE_fnc_hashGet;
            _agentType = [_agent, "type"] call ALIVE_fnc_hashGet;
            _agentID = [_agent, "agentID"] call ALIVE_fnc_hashGet;
            _agentCluster = [_agent, "homeCluster"] call ALIVE_fnc_hashGet;
            _agentPosition = [_agent, "position"] call ALIVE_fnc_hashGet;
            _agentActive = [_agent, "active"] call ALIVE_fnc_hashGet;

            // remove on main profiles hash
            [_agents, _agentID] call ALIVE_fnc_hashRem;

            // DEBUG -------------------------------------------------------------------------------------
            if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                ["ALIVE Agent Handler"] call ALIVE_fnc_dump;
                ["Un-Register Agent [%1]",_agentID] call ALIVE_fnc_dump;
                _agent call ALIVE_fnc_inspectHash;
            };
            // DEBUG -------------------------------------------------------------------------------------

            _agentsCluster = [_agentsByCluster, _agentCluster] call ALIVE_fnc_hashGet;
            [_agentsCluster, _agentID] call ALIVE_fnc_hashRem;
            [_agentsByCluster, _agentCluster, _agentsCluster] call ALIVE_fnc_hashSet;

            if(_agentActive) then {
                if(_agentType == "agent") then {
                    _activeAgents = _activeAgents - [_agentID];
                    [_logic, "activeAgents", _activeAgents] call ALIVE_fnc_hashSet;
                };
                [_agentsActive, _agentID] call ALIVE_fnc_hashRem;
            }else{
                [_agentsInActive, _agentID] call ALIVE_fnc_hashRem;
            };
        };
    };
    case "setActive": {
        private["_agentID","_agent","_agentsActive","_agentsInActive","_activeAgents","_agentType"];

        _agentID = _args select 0;
        _agent = _args select 1;

        _agentsActive = [_logic, "agentsActive"] call ALIVE_fnc_hashGet;
        _agentsInActive = [_logic, "agentsInActive"] call ALIVE_fnc_hashGet;
        _activeAgents = [_logic, "activeAgents"] call ALIVE_fnc_hashGet;

        _agentType = [_agent, "type"] call ALIVE_fnc_hashGet;

        if(_agentID in (_agentsInActive select 1)) then {
            [_agentsInActive, _agentID] call ALIVE_fnc_hashRem;
        };

        if(_agentType == "agent") then {
            _activeAgents set [count _activeAgents, _agentID];
        };

        [_agentsActive, _agentID, _agent] call ALIVE_fnc_hashSet;
    };
    case "setInActive": {
        private["_agentID","_agent","_agentsActive","_agentsInActive","_activeAgents","_agentType"];

        _agentID = _args select 0;
        _agent = _args select 1;

        _agentsActive = [_logic, "agentsActive"] call ALIVE_fnc_hashGet;
        _agentsInActive = [_logic, "agentsInActive"] call ALIVE_fnc_hashGet;
        _activeAgents = [_logic, "activeAgents"] call ALIVE_fnc_hashGet;

         _agentType = [_agent, "type"] call ALIVE_fnc_hashGet;

        if(_agentID in (_agentsActive select 1)) then {
            [_agentsActive, _agentID] call ALIVE_fnc_hashRem;
        };

        if(_agentType == "agent") then {
            _activeAgents = _activeAgents - [_agentID];
            [_logic, "activeAgents", _activeAgents] call ALIVE_fnc_hashSet;
        };

        [_agentsInActive, _agentID, _agent] call ALIVE_fnc_hashSet;
    };
    case "getActive": {
        _result = [_logic, "agentsActive"] call ALIVE_fnc_hashGet;
    };
    case "getInActive": {
        _result = [_logic, "agentsInActive"] call ALIVE_fnc_hashGet;
    };
    case "getActiveAgents": {
        _result = [_logic, "activeAgents"] call ALIVE_fnc_hashGet;
    };
    case "getAgent": {
        private["_agentID","_agents","_agentIndex"];

        if(typeName _args == "STRING") then {
            _agentID = _args;
            _agents = [_logic, "agents"] call ALIVE_fnc_hashGet;
            _agentIndex = _agents select 1;

            if(_agentID in _agentIndex) then {
                _result = [_agents, _agentID] call ALIVE_fnc_hashGet;
            }else{
                _result = nil;
            };
        };
    };
    case "getAgents": {
        _result = [_logic, "agents"] call ALIVE_fnc_hashGet;
    };
    case "getAgentsByCluster": {
        private["_type","_clusterID","_agentsByCluster"];

        if(typeName _args == "STRING") then {
            _clusterID = _args;

            _agentsByCluster = [_logic, "agentsByCluster"] call ALIVE_fnc_hashGet;

            _result = [_agentsByCluster, _clusterID] call ALIVE_fnc_hashGet;
        };
    };
    case "getNextInsertID": {
        private["_agentCount"];

        _agentCount = [_logic, "agentCount"] call ALIVE_fnc_hashGet;
        _result = _agentCount;

        _agentCount = _agentCount + 1;
        [_logic, "agentCount", _agentCount] call ALIVE_fnc_hashSet;
    };
    default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("agentHandler - output",_result);

if !(isnil "_result") then {_result} else {nil};