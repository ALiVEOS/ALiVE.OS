//#define DEBUG_MPDE_FULL
#include <\x\alive\addons\mil_intelligence\script_component.hpp>
SCRIPT(MI);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MI
Description:
Military objectives 

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state
Array - faction - Faction associated with module

Examples:
[_logic, "debug", true] call ALiVE_fnc_MI;

See Also:
- <ALIVE_fnc_MIInit>

Author:
ARJay
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_MI
#define MTEMPLATE "ALiVE_MI_%1"
#define DEFAULT_INTEL_CHANCE "0.1"
#define DEFAULT_FRIENDLY_INTEL true
#define DEFAULT_FRIENDLY_INTEL_RADIUS 2000

private ["_result"];

TRACE_1("MI - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

switch(_operation) do {
	default {
		_result = [_logic, _operation, _args] call SUPERCLASS;
	};
	case "destroy": {
		[_logic, "debug", false] call MAINCLASS;
		if (isServer) then {
			// if server
			_logic setVariable ["super", nil];
			_logic setVariable ["class", nil];
			
			[_logic, "destroy"] call SUPERCLASS;
		};
		
	};
	case "debug": {
		if (typeName _args == "BOOL") then {
			_logic setVariable ["debug", _args];
		} else {
			_args = _logic getVariable ["debug", false];
		};
		if (typeName _args == "STRING") then {
				if(_args == "true") then {_args = true;} else {_args = false;};
				_logic setVariable ["debug", _args];
		};
		ASSERT_TRUE(typeName _args == "BOOL",str _args);

		_result = _args;
	};
	// Return the Intel Chance
	case "intelChance": {
		_result = [_logic,_operation,_args,DEFAULT_INTEL_CHANCE] call ALIVE_fnc_OOsimpleOperation;
	};
	// Return the Friendly Intel
    case "friendlyIntel": {
        _result = [_logic,_operation,_args,DEFAULT_FRIENDLY_INTEL] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Friendly Intel
    case "friendlyIntelRadius": {
        if (typeName _args == "SCALAR") then {
            _logic setVariable ["friendlyIntelRadius", DEFAULT_FRIENDLY_INTEL_RADIUS];
        } else {
            _args = _logic getVariable ["friendlyIntelRadius", DEFAULT_FRIENDLY_INTEL_RADIUS];
        };
        if (typeName _args == "STRING") then {
            _logic setVariable ["friendlyIntelRadius", parseNumber _args];
        };

        _result = _args;
    };
	// Main process
	case "init": {

        if (isServer) then {
			// if server, initialise module game logic
			_logic setVariable ["super", SUPERCLASS];
			_logic setVariable ["class", MAINCLASS];
			_logic setVariable ["moduleType", "ALIVE_MI"];
			_logic setVariable ["startupComplete", false];
			_logic setVariable ["listenerID", ""];

			[_logic,"start"] call MAINCLASS;
        };
	};
    case "start": {
        private["_friendlyIntel"];

        if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
            ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
        };
        
        waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

        _friendlyIntel = [_logic, "friendlyIntel"] call MAINCLASS;

        if(_friendlyIntel) then {
            [_logic,"showFriendlies"] call MAINCLASS;
        };

        [_logic,"listen"] call MAINCLASS;

        _logic setVariable ["startupComplete", true];
    };
	case "showFriendlies": {
        private["_friendlyIntelRadius"];

	    _friendlyIntelRadius = [_logic, "friendlyIntelRadius"] call MAINCLASS;

	    _friendlyIntelRadius = parseNumber _friendlyIntelRadius;

        [ALIVE_liveAnalysis, "registerAnalysisJob", [10, 0, "showFriendlies", "showFriendlies", [_friendlyIntelRadius]]] call ALIVE_fnc_liveAnalysis;
    };
    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["LOGISTICS_INSERTION","LOGISTICS_DESTINATION","PROFILE_KILLED","AGENT_KILLED","OPCOM_RECON","OPCOM_CAPTURE","OPCOM_DEFEND","OPCOM_RESERVE","OPCOM_TERRORIZE"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };
    case "handleEvent": {
        private["_intelligenceChance","_event","_type"];

        if(typeName _args == "ARRAY") then {

            _intelligenceChance = parseNumber([_logic, "intelChance"] call MAINCLASS);

            _event = _args;

            _type = [_event, "type"] call ALIVE_fnc_hashGet;

            //["EVENT RECEIVED: %1 %2",_event, _type] call ALIVE_fnc_dump;

            if(_intelligenceChance >= random 1) then {

                //["EVENT ROLL OK"] call ALIVE_fnc_dump;

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
};

TRACE_1("MI - output",_result);
_result;
