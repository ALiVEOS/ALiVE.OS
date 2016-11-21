#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(militaryIntel);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Military Intel

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:
(begin example)
// create the military intel
_logic = [nil, "create"] call ALIVE_fnc_militaryIntel;

// init military intel
_result = [_logic, "init"] call ALIVE_fnc_militaryIntel;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_militaryIntel

#define DEFAULT_DISPLAY_INTEL false
#define DEFAULT_INTEL_CHANCE "0.1"
#define DEFAULT_FRIENDLY_INTEL false
#define DEFAULT_FRIENDLY_INTEL_RADIUS 2000
#define DEFAULT_DISPLAY_PLAYER_SECTORS false
#define DEFAULT_DISPLAY_MIL_SECTORS false
#define DEFAULT_RUN_EVERY 120

private ["_result"];

TRACE_1("militaryIntel - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
//_result = true;

#define MTEMPLATE "ALiVE_MILITARYINTEL_%1"

switch(_operation) do {
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
                [_logic, "destroy"] call SUPERCLASS;
        };
    };
    case "debug": {
        private["_tasks"];

        if(typeName _args != "BOOL") then {
                _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "displayIntel": {
        _result = [_logic,_operation,_args,DEFAULT_DISPLAY_INTEL] call ALIVE_fnc_OOsimpleOperation;
    };
    case "intelChance": {
        _result = [_logic,_operation,_args,DEFAULT_INTEL_CHANCE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "friendlyIntel": {
        _result = [_logic,_operation,_args,DEFAULT_FRIENDLY_INTEL] call ALIVE_fnc_OOsimpleOperation;
    };
    case "friendlyIntelRadius": {
        _result = [_logic,_operation,_args,DEFAULT_FRIENDLY_INTEL_RADIUS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "displayPlayerSectors": {
        _result = [_logic,_operation,_args,DEFAULT_DISPLAY_PLAYER_SECTORS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "displayMilitarySectors": {
        _result = [_logic,_operation,_args,DEFAULT_DISPLAY_MIL_SECTORS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runEvery": {
        _result = [_logic,_operation,_args,DEFAULT_RUN_EVERY] call ALIVE_fnc_OOsimpleOperation;
    };
    case "init": {
        if (isServer) then {

            // if server, initialise module game logic
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class",MAINCLASS] call ALIVE_fnc_hashSet;
            TRACE_1("After module init",_logic);

            // set defaults
            [_logic,"debug",false] call ALIVE_fnc_hashSet;
            [_logic,"listenerID",""] call ALIVE_fnc_hashSet;

            [_logic,"start"] call MAINCLASS;

        };
    };
    case "start": {
        private["_friendlyIntel","_displayMilitarySectors","_displayPlayerSectors","_displayIntel"];

        if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
            ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
        };

        waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

        _friendlyIntel = [_logic, "friendlyIntel"] call MAINCLASS;

        if(_friendlyIntel) then {
            [_logic,"showFriendlies"] call MAINCLASS;
        };

        _displayMilitarySectors = [_logic, "displayMilitarySectors"] call MAINCLASS;

        if(_displayMilitarySectors) then {
            [_logic,"showMilitarySectors"] call MAINCLASS;
        };

        _displayPlayerSectors = [_logic, "displayPlayerSectors"] call MAINCLASS;

        if(_displayPlayerSectors) then {
            [_logic,"showPlayerSectors"] call MAINCLASS;
        };

        _displayIntel = [_logic, "displayIntel"] call MAINCLASS;

        if(_displayIntel) then {
            [_logic,"listen"] call MAINCLASS;
        };

    };
    case "showFriendlies": {
        private["_friendlyIntelRadius"];

        _friendlyIntelRadius = [_logic, "friendlyIntelRadius"] call MAINCLASS;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [10, 0, "showFriendlies", "showFriendlies", [_friendlyIntelRadius]]] call ALIVE_fnc_liveAnalysis;
    };
    case "showPlayerSectors": {

        private ["_debug","_runEvery","_modules","_module","_activeAnalysisJobs","_activeAnalysis","_args"];

        _debug = [_logic, "debug"] call MAINCLASS;
        _runEvery = [_logic, "runEvery"] call MAINCLASS;

        if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
            ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
        };

        waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

        _activeAnalysisJobs = [ALIVE_liveAnalysis, "getAnalysisJobs"] call ALIVE_fnc_liveAnalysis;

        if("activeSectors" in (_activeAnalysisJobs select 1)) then {
            _activeAnalysis = [_activeAnalysisJobs, "activeSectors"] call ALIVE_fnc_hashGet;
            _args = [_activeAnalysis, "args"] call ALIVE_fnc_hashGet;
            _args set [0, _runEvery];
            _args set [4, [true]];
        };

    };
    case "showMilitarySectors": {

        private ["_debug","_runEvery","_modules","_module","_activeAnalysisJobs","_gridProfileAnalysis","_args"];

        _debug = [_logic, "debug"] call MAINCLASS;
        _runEvery = [_logic, "runEvery"] call MAINCLASS;

        if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
            ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
        };

        waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

        _activeAnalysisJobs = [ALIVE_liveAnalysis, "getAnalysisJobs"] call ALIVE_fnc_liveAnalysis;

        if("gridProfileEntity" in (_activeAnalysisJobs select 1)) then {
            _gridProfileAnalysis = [_activeAnalysisJobs, "gridProfileEntity"] call ALIVE_fnc_hashGet;
            _args = [_gridProfileAnalysis, "args"] call ALIVE_fnc_hashGet;
            _args set [0, _runEvery];
            _args set [4, [true]];
        };

    };
    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["LOGISTICS_INSERTION","LOGISTICS_DESTINATION","PROFILE_KILLED","AGENT_KILLED","OPCOM_RECON","OPCOM_CAPTURE","OPCOM_DEFEND","OPCOM_RESERVE","OPCOM_TERRORIZE"]]] call ALIVE_fnc_eventLog;
        [_logic,"listenerID",_listenerID] call ALIVE_fnc_hashSet;
    };
    case "handleEvent": {
        private["_intelligenceChance","_event","_type"];

        if(typeName _args == "ARRAY") then {

            _intelligenceChance = parseNumber([_logic, "intelChance"] call MAINCLASS);

            _event = _args;

            _type = [_event, "type"] call ALIVE_fnc_hashGet;

            if(_intelligenceChance >= random 1) then {

                switch(_type) do {
                    case 'PROFILE_KILLED': {
                        [_logic,"notifyKIAIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'AGENT_KILLED': {
                        [_logic,"notifyAgentKIAIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'LOGISTICS_INSERTION': {
                        [_logic,"notifyLogisticsInsertionIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'LOGISTICS_DESTINATION': {
                        [_logic,"notifyLogisticsDestinationIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'OPCOM_RECON': {
                        [_logic,"notifyReconIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'OPCOM_CAPTURE': {
                        [_logic,"notifyCaptureIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'OPCOM_DEFEND': {
                        [_logic,"notifyDefendIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'OPCOM_RESERVE': {
                        [_logic,"notifyReserveIntelligenceItem",_event] call MAINCLASS;
                    };
                    case 'OPCOM_TERRORIZE': {
                        [_logic,"notifyTerrorizeIntelligenceItem",_event] call MAINCLASS;
                    };
                };

            };
        };
    };
    case "notifyKIAIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "KIAIntelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;

    };
    case "notifyAgentKIAIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "AgentKIAIntelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;

    };
    case "notifyLogisticsInsertionIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "logisticsInsertionIntelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;

    };
    case "notifyLogisticsDestinationIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "logisticsDestinationIntelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;

    };
    case "notifyReconIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "intelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;
    };
    case "notifyCaptureIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "intelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;
    };
    case "notifyDefendIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "intelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;
    };
    case "notifyReserveIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "intelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;
    };
    
    case "notifyTerrorizeIntelligenceItem": {
        private["_event","_id","_data","_from"];

        _event = _args;
        _id = [_event, "id"] call ALIVE_fnc_hashGet;
        _data = [_event, "data"] call ALIVE_fnc_hashGet;
        _from = [_event, "from"] call ALIVE_fnc_hashGet;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [25, 5, "intelligenceItem", _id, [_data]]] call ALIVE_fnc_liveAnalysis;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("militaryIntel - output",_result);

if !(isnil "_result") then {_result} else {nil};
