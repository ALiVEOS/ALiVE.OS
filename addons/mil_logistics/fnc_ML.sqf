//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_logistics\script_component.hpp"
SCRIPT(ML);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ML
Description:
Military objectives

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Initiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state
Array - faction - Faction associated with module

Examples:
[_logic, "debug", true] call ALiVE_fnc_ML;

See Also:
- <ALIVE_fnc_MLInit>

Author:
ARJay
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ML
#define MTEMPLATE "ALiVE_ML_%1"
#define DEFAULT_FACTIONS []
#define DEFAULT_OBJECTIVES []
#define DEFAULT_EVENT_QUEUE []
#define DEFAULT_REINFORCEMENT_ANALYSIS []
#define DEFAULT_SIDE "EAST"
#define DEFAULT_FORCE_POOL_TYPE "FIXED"
#define DEFAULT_FORCE_POOL "1000"
#define DEFAULT_ALLOW true
#define DEFAULT_TYPE "DYNAMIC"
#define DEFAULT_REGISTRY_ID ""
#define PARADROP_HEIGHT 500
#define DESTINATION_VARIANCE 150
#define DESTINATION_RADIUS 300
#define WAIT_TIME_AIR 10
#define WAIT_TIME_HELI 20
#define WAIT_TIME_MARINE 30
#define WAIT_TIME_DROP 40

private ["_result"];

TRACE_1("ML - input",_this);

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
            _logic setVariable ["markers", []];

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
    case "persistent": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["persistent", _args];
        } else {
            _args = _logic getVariable ["persistent", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["persistent", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "pause": {
        if(typeName _args != "BOOL") then {
            // if no new value was provided return current setting
            _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
        } else {
                // if a new value was provided set groups list
                ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                private ["_state"];
                _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                if (_state && _args) exitwith {};

                //Set value
                _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;
                ["ALiVE Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_DumpR;
        };
        _result = _args;
    };
    case "createMarker": {
        private["_position","_faction","_text","_markers","_debugColor","_markerID","_m"];

        _position = _args select 0;
        _faction = _args select 1;
        _text = _args select 2;

        _markers = _logic getVariable ["markers", []];

        if(count _markers > 10) then {
            {
                deleteMarker _x;
            } forEach _markers;
            _markers = [];
        };

        _debugColor = "ColorPink";

        switch(_faction) do {
            case "OPF_F":{
                _debugColor = "ColorRed";
            };
            case "BLU_F":{
                _debugColor = "ColorBlue";
            };
            case "IND_F":{
                _debugColor = "ColorGreen";
            };
            case "BLU_G_F":{
                _debugColor = "ColorBrown";
            };
            default {
                _debugColor = "ColorGreen";
            };
        };

        _markerID = time;

        if(count _position > 0) then {
            _m = createMarker [format["%1_%2",MTEMPLATE,_markerID], _position];
            _m setMarkerShape "ICON";
            _m setMarkerSize [0.5, 0.5];
            _m setMarkerType "mil_join";
            _m setMarkerColor _debugColor;
            _m setMarkerText _text;

            _markers pushback _m;
        };

        _logic setVariable ["markers", _markers];
    };
    case "side": {
        _result = [_logic,_operation,_args,DEFAULT_SIDE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "factions": {
        _result = [_logic,_operation,_args,DEFAULT_FACTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectives": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "eventQueue": {
        _result = [_logic,_operation,_args,DEFAULT_EVENT_QUEUE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reinforcementAnalysis": {
        _result = [_logic,_operation,_args,DEFAULT_REINFORCEMENT_ANALYSIS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "forcePoolType": {
        _result = [_logic,_operation,_args,DEFAULT_FORCE_POOL_TYPE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "registryID": {
        _result = [_logic,_operation,_args,DEFAULT_REGISTRY_ID] call ALIVE_fnc_OOsimpleOperation;
    };
    case "allowInfantryReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowInfantryReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowInfantryReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowInfantryReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowMechanisedReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowMechanisedReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowMechanisedReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowMechanisedReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowMotorisedReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowMotorisedReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowMotorisedReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowMotorisedReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowArmourReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowArmourReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowArmourReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowArmourReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowHeliReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowHeliReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowHeliReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowHeliReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowPlaneReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowPlaneReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowPlaneReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowPlaneReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "enableAirTransport": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["enableAirTransport", _args];
        } else {
            _args = _logic getVariable ["enableAirTransport", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["enableAirTransport", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "limitTransportToFaction": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["limitTransportToFaction", _args];
        } else {
            _args = _logic getVariable ["limitTransportToFaction", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["limitTransportToFaction", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "type": {
        if(typeName _args == "STRING") then {
            _logic setVariable [_operation, parseNumber _args];
        };

        _result = _logic getVariable [_operation, DEFAULT_TYPE];
    };
    case "forcePool": {
        if(typeName _args == "STRING") then {
            _logic setVariable [_operation, parseNumber _args];
        };

        if(typeName _args == "SCALAR") then {
            _logic setVariable [_operation, _args];
        };

        _result = _logic getVariable [_operation, DEFAULT_FORCE_POOL];
    };

    // Main process
    case "init": {
        if (isServer) then {

            private ["_debug","_forcePool","_type","_allowInfantry","_allowMechanised","_allowMotorised","_allowArmour","_allowHeli","_allowPlane"];

            // if server, initialise module game logic
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_ML"];
            _logic setVariable ["startupComplete", false];
            _logic setVariable ["listenerID", ""];
            _logic setVariable ["registryID", ""];
            _logic setVariable ["initialAnalysisComplete", false];
            _logic setVariable ["analysisInProgress", false];
            _logic setVariable ["eventQueue", [] call ALIVE_fnc_hashCreate];

            _debug = [_logic, "debug"] call MAINCLASS;
            _forcePool = [_logic, "forcePool"] call MAINCLASS;
            _type = [_logic, "type"] call MAINCLASS;

            if(typeName _forcePool == "STRING") then {
                _forcePool = parseNumber _forcePool;
            };

            if(_forcePool == 10) then {
                [_logic, "forcePool", 1000] call MAINCLASS;
                [_logic, "forcePoolType", "DYNAMIC"] call MAINCLASS;
            };

            _allowInfantry = [_logic, "allowInfantryReinforcement"] call MAINCLASS;
            _allowMechanised = [_logic, "allowMechanisedReinforcement"] call MAINCLASS;
            _allowMotorised = [_logic, "allowMotorisedReinforcement"] call MAINCLASS;
            _allowArmour = [_logic, "allowArmourReinforcement"] call MAINCLASS;
            _allowHeli = [_logic, "allowHeliReinforcement"] call MAINCLASS;
            _allowPlane = [_logic, "allowPlaneReinforcement"] call MAINCLASS;

            _enableAirTransport = [_logic, "enableAirTransport"] call MAINCLASS;
            _limitTransportToFaction = [_logic, "limitTransportToFaction"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE ML - Init"] call ALIVE_fnc_dump;
                ["ALIVE ML - Type: %1",_type] call ALIVE_fnc_dump;
                ["ALIVE ML - Force pool type: %1 limit: %2",[_logic, "forcePool"] call MAINCLASS,[_logic, "forcePoolType"] call MAINCLASS] call ALIVE_fnc_dump;
                ["ALIVE ML - Allow infantry requests: %1",_allowInfantry] call ALIVE_fnc_dump;
                ["ALIVE ML - Allow mechanised requests: %1",_allowMechanised] call ALIVE_fnc_dump;
                ["ALIVE ML - Allow motorised requests: %1",_allowMotorised] call ALIVE_fnc_dump;
                ["ALIVE ML - Allow armour requests: %1",_allowArmour] call ALIVE_fnc_dump;
                ["ALIVE ML - Allow heli requests: %1",_allowHeli] call ALIVE_fnc_dump;
                ["ALIVE ML - Allow plane requests: %1",_allowPlane] call ALIVE_fnc_dump;
                ["ALIVE ML - Enable air transport: %1",_enableAirTransport] call ALIVE_fnc_dump;
                ["ALIVE ML - Limit air assets to faction only: %1",_limitTransportToFaction] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // create the global registry
            if(isNil "ALIVE_MLGlobalRegistry") then {
                ALIVE_MLGlobalRegistry = [nil, "create"] call ALIVE_fnc_MLGlobalRegistry;
                [ALIVE_MLGlobalRegistry, "init"] call ALIVE_fnc_MLGlobalRegistry;
                [ALIVE_MLGlobalRegistry, "debug", _debug] call ALIVE_fnc_MLGlobalRegistry;
            };

            TRACE_1("After module init",_logic);

            [_logic,"start"] call MAINCLASS;
        };
    };

    case "start": {
        if (isServer) then {

            private ["_debug","_modules","_module","_worldName","_file","_moduleObject"];

            _debug = [_logic, "debug"] call MAINCLASS;


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE ML - Startup"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // check modules are available
            if !(["ALiVE_sys_profile","ALiVE_mil_opcom"] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Military Logistics reports that Virtual AI module or OPCOM module not placed! Exiting..."] call ALiVE_fnc_DumpR;
            };
            waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

            // if civ cluster data not loaded, load it
            if(isNil "ALIVE_clustersCiv" && isNil "ALIVE_loadedCivClusters") then {
                _worldName = toLower(worldName);
                _file = format["x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedCIVClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedCIVClusters") && {ALIVE_loadedCIVClusters}};

            // if mil cluster data not loaded, load it
            if(isNil "ALIVE_clustersMil" && isNil "ALIVE_loadedMilClusters") then {
                _worldName = toLower(worldName);
                _file = format["x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedMilClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedMilClusters") && {ALIVE_loadedMilClusters}};

            // get all synced modules
            _modules = [];

            for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {
                _moduleObject = (synchronizedObjects _logic) select _i;

                waituntil {_module = _moduleObject getVariable "handler"; !(isnil "_module")};
                _module = _moduleObject getVariable "handler";
                _modules pushback _module;
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE ML - Startup completed"] call ALIVE_fnc_dump;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            _logic setVariable ["startupComplete", true];

            if(count _modules > 0) then {

                // start listening for logcom events
                [_logic,"listen"] call MAINCLASS;

                // start initial analysis
                [_logic, "initialAnalysis", _modules] call MAINCLASS;
            }else{
                ["ALIVE ML - Warning no OPCOM modules synced to Military Logistics module, nothing to do.."] call ALIVE_fnc_dumpR;

            };
        };
    };

    case "initialAnalysis": {
        if (isServer) then {

            private ["_debug","_modules","_module","_modulesFactions","_moduleSide","_moduleFactions","_modulesObjectives","_moduleFactionBreakdowns",
            "_faction","_factionBreakdown","_objectives"];

            _modules = _args;

            _debug = [_logic, "debug"] call MAINCLASS;
            _modulesFactions = [];
            _modulesObjectives = [];

            // get objectives and modules settings from syncronised OPCOM instances
            // should only be 1...
            {
                _module = _x;
                _moduleSide = [_module,"side"] call ALiVE_fnc_HashGet;

                // Register side with clients
                MOD(Require) setVariable [format["ALIVE_MIL_LOG_AVAIL_%1", _moduleSide], true, true];

                _moduleFactions = [_module,"factions"] call ALiVE_fnc_HashGet;

                // store side
                [_logic, "side", _moduleSide] call MAINCLASS;

                // get the objectives from the module
                _objectives = [];

                waituntil {
                    sleep 10;
                    _objectives = nil;
                    _objectives = [_module,"objectives"] call ALIVE_fnc_hashGet;
                    (!(isnil "_objectives") && {count _objectives > 0})
                };

                _modulesFactions pushback [_moduleSide,_moduleFactions];
                _modulesObjectives pushback _objectives;

                // set the faction force pools
                {
                    [ALIVE_globalForcePool,_x,0] call ALIVE_fnc_hashSet;
                } forEach _moduleFactions;

            } forEach _modules;

            [_logic, "factions", _modulesFactions] call MAINCLASS;
            [_logic, "objectives", _modulesObjectives] call MAINCLASS;

            // register the module
            [ALIVE_MLGlobalRegistry,"register",_logic] call ALIVE_fnc_MLGlobalRegistry;

            // set as initial analysis complete
            _logic setVariable ["initialAnalysisComplete", true];

            // trigger main processing loop
            [_logic, "monitor"] call MAINCLASS;
        };
    };

    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["LOGCOM_REQUEST","LOGCOM_STATUS_REQUEST","LOGCOM_CANCEL_REQUEST"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };

    case "handleEvent": {
        private["_event","_type","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;

            [_logic, _type, _event] call MAINCLASS;

        };
    };

    case "LOGCOM_STATUS_REQUEST": {

        private["_debug","_event","_eventData","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound",
        "_moduleFactions","_eventPlayerID","_eventRequestID"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 0;
            _eventSide = _eventData select 1;
            _eventRequestID = _eventData select 2;
            _eventPlayerID = _eventData select 3;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // faction not handled by this mil logistics module
            if!(_factionFound) then {

                private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                _sideOPCOMModules = [];
                _factionOPCOMModules = [];

                // loop through OPCOM modules with mil logistics synced and find any matching the events side and faction
                {

                    _checkModule = _x;
                    _moduleType = _x getVariable "moduleType";

                    if!(isNil "_moduleType") then {

                        if(_moduleType == "ALIVE_OPCOM") then {

                            _handler = _checkModule getVariable "handler";
                            _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                            _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                            _OPCOMHasLogistics = false;

                            for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                _mod = (synchronizedObjects _checkModule) select _i;

                                if ((typeof _mod) == "ALiVE_mil_logistics") then {
                                    _OPCOMHasLogistics = true;
                                };
                            };

                            if(_OPCOMHasLogistics) then {

                                if(_OPCOMSide == _eventSide) then {
                                    _sideOPCOMModules pushback _checkModule;
                                };

                                {
                                    if(_x == _eventFaction) then {
                                        _factionOPCOMModules pushback _checkModule;
                                    };

                                } forEach _OPCOMFactions;

                            };
                        };
                    };
                } forEach (entities "Module_F");

                // if no mil logistics handles this faction, and there is more than one mil
                // logistics for this side return an error
                if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                    _factionFound = false;
                };

                // if no mil logistics handles this faction, and there is one mil
                // logistics for this side and this module handles that side
                if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {
                    _factionFound = true;
                };

            };

            if!(_factionFound) exitWith {};

            if(_factionFound) then {

                private ["_eventQueue","_response","_responseItem","_playerRequested","_eventData","_logEvent","_playerID",
                "_eventState","_eventType","_eventForceMakeup","_requestID","_transportProfiles","_position","_playerRequestProfileID","_profile"];

                // get the event data for this player

                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                _response = [];

                if((count (_eventQueue select 2)) > 0) then {

                    {
                        _playerRequested = [_x, "playerRequested"] call ALIVE_fnc_hashGet;

                        if(_playerRequested) then {
                            _eventData = [_x, "data"] call ALIVE_fnc_hashGet;
                            _playerID = _eventData select 5;
                            _eventType = _eventData select 4;
                            _eventForceMakeup = _eventData select 3;

                            if(_eventPlayerID == _playerID) then {

                                _responseItem = [];

                                _requestID = _eventForceMakeup select 0;
                                _eventState = [_x, "state"] call ALIVE_fnc_hashGet;
                                _transportProfiles = [_x, "transportProfiles"] call ALIVE_fnc_hashGet;

                                _positions = [];

                                if(count _transportProfiles > 0) then {

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                                        if!(isNil "_profile") then {
                                            _position = _profile select 2 select 2;
                                            _positions pushBack _position;
                                        };

                                    } forEach _transportProfiles;

                                };

                                _responseItem pushBack _eventType;
                                _responseItem pushBack _requestID;
                                _responseItem pushBack _eventState;
                                _responseItem pushBack _positions;

                                _response pushBack _responseItem;
                            };
                        };

                    } forEach (_eventQueue select 2);

                };

                // respond to player request
                _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"Logistics","STATUS"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

            };
        };
    };

    case "LOGCOM_CANCEL_REQUEST": {

        private["_debug","_event","_eventData","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound",
        "_moduleFactions","_eventPlayerID","_eventRequestID","_eventCancelRequestID"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 0;
            _eventSide = _eventData select 1;
            _eventRequestID = _eventData select 2;
            _eventPlayerID = _eventData select 3;
            _eventCancelRequestID = _eventData select 4;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // faction not handled by this mil logistics module
            if!(_factionFound) then {

                private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                _sideOPCOMModules = [];
                _factionOPCOMModules = [];

                // loop through OPCOM modules with mil logistics synced and find any matching the events side and faction
                {

                    _checkModule = _x;
                    _moduleType = _x getVariable "moduleType";

                    if!(isNil "_moduleType") then {

                        if(_moduleType == "ALIVE_OPCOM") then {

                            _handler = _checkModule getVariable "handler";
                            _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                            _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                            _OPCOMHasLogistics = false;

                            for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                _mod = (synchronizedObjects _checkModule) select _i;

                                if ((typeof _mod) == "ALiVE_mil_logistics") then {
                                    _OPCOMHasLogistics = true;
                                };
                            };

                            if(_OPCOMHasLogistics) then {

                                if(_OPCOMSide == _eventSide) then {
                                    _sideOPCOMModules pushback _checkModule;
                                };

                                {
                                    if(_x == _eventFaction) then {
                                        _factionOPCOMModules pushback _checkModule;
                                    };

                                } forEach _OPCOMFactions;

                            };
                        };
                    };
                } forEach (entities "Module_F");

                // if no mil logistics handles this faction, and there is more than one mil
                // logistics for this side return an error
                if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                    _factionFound = false;
                };

                // if no mil logistics handles this faction, and there is one mil
                // logistics for this side and this module handles that side
                if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {
                    _factionFound = true;
                };

            };

            if!(_factionFound) exitWith {};

            if(_factionFound) then {

                private ["_eventQueue","_response","_responseItem","_playerRequested","_eventID","_eventData","_logEvent","_playerID",
                "_eventState","_eventType","_eventForceMakeup","_responseItem","_eventCargoProfiles","_infantryProfiles","_armourProfiles",
                "_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles","_eventAssets","_allRequestedProfiles","_anyActive",
                "_transportProfiles","_transportVehiclesProfiles","_requestID","_position","_playerRequestProfileID","_profile","_active","_profileType"];

                // get the event data for this player

                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                _response = [];

                if((count (_eventQueue select 2)) > 0) then {

                    {
                        _playerRequested = [_x, "playerRequested"] call ALIVE_fnc_hashGet;

                        if(_playerRequested) then {
                            _eventID = [_x, "id"] call ALIVE_fnc_hashGet;
                            _eventData = [_x, "data"] call ALIVE_fnc_hashGet;
                            _playerID = _eventData select 5;
                            _eventType = _eventData select 4;
                            _eventForceMakeup = _eventData select 3;

                            if(_eventPlayerID == _playerID) then {

                                _responseItem = [];

                                _requestID = _eventForceMakeup select 0;

                                if(_requestID == _eventCancelRequestID) then {

                                    //_x call ALIVE_fnc_inspectHash;

                                    _eventCargoProfiles = [_x, "cargoProfiles"] call ALIVE_fnc_hashGet;

                                    _transportProfiles = [_x, "transportProfiles"] call ALIVE_fnc_hashGet;
                                    _transportVehiclesProfiles = [_x, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;

                                    _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                                    _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
                                    _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
                                    _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
                                    _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                                    _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                                    _allRequestedProfiles = [];
                                    _anyActive = false;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _transportProfiles;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _transportVehiclesProfiles;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _infantryProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _armourProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _mechanisedProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _motorisedProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _planeProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _heliProfiles;

                                    if(_anyActive) then {

                                        // respond to player request
                                        _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"Logistics","CANCEL_FAILED"] call ALIVE_fnc_event;
                                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                    }else{

                                        // delete all profiles

                                        {
                                            _profileType = _x select 2 select 5;
                                            if(_profileType == 'entity') then {
                                                [_x, "destroy"] call ALIVE_fnc_profileEntity;
                                            }else{
                                                [_x, "destroy"] call ALIVE_fnc_profileVehicle;
                                            };

                                        } forEach _allRequestedProfiles;

                                        _eventAssets = [_x, "eventAssets"] call ALIVE_fnc_hashGet;

                                        {
                                            deleteVehicle _x;
                                        } forEach _eventAssets;

                                        // set state to event complete
                                        [_x, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                                        [_eventQueue, _eventID, _x] call ALIVE_fnc_hashSet;

                                        // respond to player request
                                        _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"Logistics","CANCEL_OK"] call ALIVE_fnc_event;
                                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                    };
                                };
                            };
                        };

                    } forEach (_eventQueue select 2);

                };
            };
        };
    };

    case "LOGCOM_REQUEST": {

        private["_debug","_event","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound","_moduleFactions","_forcePool","_type","_eventID",
        "_eventData","_eventType","_eventForceMakeup","_eventForceInfantry","_eventForceMotorised","_eventForceMechanised","_eventForceArmour",
        "_eventForcePlane","_eventForceHeli","_forceMakeupTotal","_allowInfantry","_allowMechanised","_allowMotorised",
        "_allowArmour","_allowHeli","_allowPlane","_playerID","_requestID","_logEvent","_initComplete"];

        if(typeName _args == "ARRAY") then {

            _debug = [_logic, "debug"] call MAINCLASS;
            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
            _eventType = _eventData select 4;

            _initComplete = true;

            if(_eventType == "PR_STANDARD" || _eventType == "PR_AIRDROP" || _eventType == "PR_HELI_INSERT") then {
                _initComplete = _logic getVariable "initialAnalysisComplete";
                if!(_initComplete) then {
                    _eventForceMakeup = _eventData select 3;
                    _playerID = _eventData select 5;
                    _requestID = _eventForceMakeup select 0;
                    // respond to player request
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_WAITING_INIT"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                };
            };

            if!(_initComplete) exitWith {};

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 1;
            _eventSide = _eventData select 2;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // check if any other mil logistics modules can handle this event

            if(_eventType == "PR_STANDARD" || _eventType == "PR_AIRDROP" || _eventType == "PR_HELI_INSERT") then {

                // faction not handled by this mil logistics module
                if!(_factionFound) then {

                    private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                    _sideOPCOMModules = [];
                    _factionOPCOMModules = [];

                    // loop through OPCOM modules with mil logistics synced and find any matching the events side and faction
                    {

                        _checkModule = _x;
                        _moduleType = _x getVariable "moduleType";

                        if!(isNil "_moduleType") then {

                            if(_moduleType == "ALIVE_OPCOM") then {

                                _handler = _checkModule getVariable "handler";
                                _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                                _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                                _OPCOMHasLogistics = false;

                                for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                    _mod = (synchronizedObjects _checkModule) select _i;

                                    if ((typeof _mod) == "ALiVE_mil_logistics") then {
                                        _OPCOMHasLogistics = true;
                                    };
                                };

                                if(_OPCOMHasLogistics) then {

                                    if(_OPCOMSide == _eventSide) then {
                                        _sideOPCOMModules pushback _checkModule;
                                    };

                                    {
                                        if(_x == _eventFaction) then {
                                            _factionOPCOMModules pushback _checkModule;
                                        };

                                    } forEach _OPCOMFactions;

                                };
                            };
                        };
                    } forEach (entities "Module_F");

                    // if no mil logistics handles this faction, and there is more than one mil
                    // logistics for this side return an error
                    if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                        _eventForceMakeup = _eventData select 3;
                        _playerID = _eventData select 5;
                        _requestID = _eventForceMakeup select 0;
                        // respond to player request
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_FACTION_HANDLER_NOT_FOUND"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };

                    // if no mil logistics handles this faction, and there is one mil
                    // logistics for this side and this module handles that side
                    if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {

                        _factionFound = true;

                        _eventData set [1,_factions select 0 select 1 select 0];
                        [_event, "data", _eventData] call ALIVE_fnc_hashSet;
                        _eventFaction = _factions select 0 select 1 select 0;
                    };

                };
            };

            if!(_factionFound) exitWith {};


            if(_factionFound) then {

                _type = [_logic, "type"] call MAINCLASS;

                _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALIVE ML - Global force pool:"] call ALIVE_fnc_dump;
                    ALIVE_globalForcePool call ALIVE_fnc_inspectHash;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // if there are still forces available
                if(_forcePool > 0) then {

                    _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
                    _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
                    _eventForceMakeup = _eventData select 3;
                    _eventType = _eventData select 4;

                    _forceMakeupTotal = 0;

                    if(_eventType == "STANDARD" || _eventType == "AIRDROP" || _eventType == "HELI_INSERT") then {

                        _allowInfantry = [_logic, "allowInfantryReinforcement"] call MAINCLASS;
                        _allowMechanised = [_logic, "allowMechanisedReinforcement"] call MAINCLASS;
                        _allowMotorised = [_logic, "allowMotorisedReinforcement"] call MAINCLASS;
                        _allowArmour = [_logic, "allowArmourReinforcement"] call MAINCLASS;
                        _allowHeli = [_logic, "allowHeliReinforcement"] call MAINCLASS;
                        _allowPlane = [_logic, "allowPlaneReinforcement"] call MAINCLASS;

                        _eventForceInfantry = _eventForceMakeup select 0;
                        _eventForceMotorised = _eventForceMakeup select 1;
                        _eventForceMechanised = _eventForceMakeup select 2;
                        _eventForceArmour = _eventForceMakeup select 3;
                        _eventForcePlane = _eventForceMakeup select 4;
                        _eventForceHeli = _eventForceMakeup select 5;

                        _forceMakeupTotal = _eventForceInfantry + _eventForceMotorised + _eventForceMechanised + _eventForceArmour + _eventForcePlane + _eventForceHeli;

                        //["CHECK AI: %1 AM: %2 AM: %3 AA: %4 AH: %5 AP: %6",_allowInfantry,_allowMechanised,_allowMotorised,_allowArmour,_allowHeli,_allowPlane] call ALIVE_fnc_dump;
                        //["FORCE MAKEUP BEFORE: %1", _eventForceMakeup] call ALIVE_fnc_dump;

                        if!(_allowInfantry) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceInfantry;
                            _eventForceMakeup set [0,0];
                        };

                        if!(_allowMotorised) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceMotorised;
                            _eventForceMakeup set [1,0];
                        };

                        if!(_allowMechanised) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceMechanised;
                            _eventForceMakeup set [2,0];
                        };

                        if!(_allowArmour) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceArmour;
                            _eventForceMakeup set [3,0];
                        };

                        if!(_allowPlane) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForcePlane;
                            _eventForceMakeup set [4,0];
                        };

                        if!(_allowHeli) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceHeli;
                            _eventForceMakeup set [5,0];
                        };

                        _eventData set [3, _eventForceMakeup];
                        [_event, "data", _eventData] call ALIVE_fnc_hashSet;

                        // set the state of the event
                        [_event, "state", "requested"] call ALIVE_fnc_hashSet;

                        // set the player requested flag on the event
                        [_event, "playerRequested", false] call ALIVE_fnc_hashSet;

                    }else{

                        _playerID = _eventData select 5;
                        _requestID = _eventForceMakeup select 0;

                        // if it's a player request
                        // accept automatically

                        _forceMakeupTotal = 1;

                        // set the state of the event
                        [_event, "state", "playerRequested"] call ALIVE_fnc_hashSet;

                        // set the player requested flag on the event
                        [_event, "playerRequested", true] call ALIVE_fnc_hashSet;

                        // respond to player request
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","ACKNOWLEDGED"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    };


                    //["FORCE MAKEUP AFTER: %1 FORCE MAKEUP TOTAL: %2", _eventForceMakeup, _forceMakeupTotal] call ALIVE_fnc_dump;
                    //_event call ALIVE_fnc_inspectHash;

                    if(_forceMakeupTotal > 0) then {

                        // set the time the event was received
                        [_event, "time", time] call ALIVE_fnc_hashSet;

                        // set the state data array of the event
                        [_event, "stateData", []] call ALIVE_fnc_hashSet;

                        // set the profiles array of the event
                        [_event, "cargoProfiles", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                        [_event, "transportProfiles", []] call ALIVE_fnc_hashSet;
                        [_event, "transportVehiclesProfiles", []] call ALIVE_fnc_hashSet;
                        [_event, "playerRequestProfiles", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

                        [_event, "finalDestination", []] call ALIVE_fnc_hashSet;

                        [_event, "eventAssets", []] call ALIVE_fnc_hashSet;

                        // store the event on the event queue
                        _eventQueue = [_logic, "eventQueue"] call MAINCLASS;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ALIVE ML - Reinforce event received"] call ALIVE_fnc_dump;
                            ["ALIVE ML - Current force pool for side: %2 available: %3", _side, _forcePool] call ALIVE_fnc_dump;
                            _event call ALIVE_fnc_inspectHash;
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        // trigger analysis
                        [_logic,"onDemandAnalysis"] call MAINCLASS;


                    }else{

                        // nothing left after non allowed types ruled out

                    };

                }else{


                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ALIVE ML - Reinforce event denied, force pool for side: %1 exhausted : %2", _side, _forcePool] call ALIVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------


                    _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
                    _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
                    _eventForceMakeup = _eventData select 3;
                    _eventType = _eventData select 4;

                    if(_eventType == "PR_STANDARD" || _eventType == "PR_AIRDROP" || _eventType == "PR_HELI_INSERT") then {

                        _playerID = _eventData select 5;
                        _requestID = _eventForceMakeup select 0;

                        // respond to player request
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_FORCEPOOL"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    };


                };

            }else{

                // faction not handled by this module, ignored..

            };

        };
    };

    case "onDemandAnalysis": {
        private["_debug","_analysisInProgress","_type","_forcePoolType","_registryID","_forcePool","_objectives"];

        if (isServer) then {

            _debug = [_logic, "debug"] call MAINCLASS;
            _analysisInProgress = _logic getVariable ["analysisInProgress", false];

            // if analysis not already underway
            if!(_analysisInProgress) then {

                _logic setVariable ["analysisInProgress", true];

                _type = [_logic, "type"] call MAINCLASS;
                _forcePoolType = [_logic, "forcePoolType"] call MAINCLASS;
                _registryID = [_logic, "registryID"] call MAINCLASS;
                _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;
                if(typeName _forcePool == "STRING") then {
                    _forcePool = parseNumber _forcePool;
                };

                _objectives = [_logic, "objectives"] call MAINCLASS;
                _objectives = _objectives select 0;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALIVE ML - On demand dynamic analysis started"] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private["_reserve","_tacom_state","_priorityTotal","_priority"];

                _reserve = [];
                _priorityTotal = 0;

                // sort OPCOM objective states to find
                // reserved objectives
                {
                    _tacom_state = '';
                    if("tacom_state" in (_x select 1)) then {
                        _tacom_state = [_x,"tacom_state","none"] call ALIVE_fnc_hashGet;
                    };

                    switch(_tacom_state) do {
                        case "reserve":{

                            // increase the priority count by adding
                            // all held objective priorities
                            _priority = [_x,"priority"] call ALIVE_fnc_hashGet;
                            _priorityTotal = _priorityTotal + _priority;

                            // store the objective
                            _reserve pushback _x;
                        };
                    };

                } forEach _objectives;

                private["_previousReinforcementAnalysis","_previousReinforcementAnalysisPriorityTotal"];

                _previousReinforcementAnalysis = [_logic, "reinforcementAnalysis"] call MAINCLASS;

                // if the force pool type is dynamic
                // calculate the new pool
                if(_forcePoolType == "DYNAMIC") then {

                    //["DYNAMIC FORCE POOL"] call ALIVE_fnc_dump;
                    //["CURRENT FORCE POOL: %1",_forcePool] call ALIVE_fnc_dump;

                    // if there is a previous analysis
                    if(count _previousReinforcementAnalysis > 0) then {

                        //["PREVIOUS ANALYSIS FOUND"] call ALIVE_fnc_dump;

                        _previousReinforcementAnalysisPriorityTotal = [_previousReinforcementAnalysis, "priorityTotal"] call ALIVE_fnc_hashGet;

                        // if the current priority total is greater
                        // than the previous priority total
                        // objectives have been captured
                        // increase the available pool
                        if(_priorityTotal > _previousReinforcementAnalysisPriorityTotal) then {

                            //["CURRENT PRIORITY TOTAL IS GREATER THAN PREVIOUS"] call ALIVE_fnc_dump;

                            _forcePool = _forcePool + (_priorityTotal - _previousReinforcementAnalysisPriorityTotal);

                        }else{

                            if(_priorityTotal < _previousReinforcementAnalysisPriorityTotal) then {

                                // objectives have been lost
                                // reduce the force pool

                                if(_forcePool > 0) then {

                                    //["CURRENT PRIORITY TOTAL IS LESS THAN PREVIOUS"] call ALIVE_fnc_dump;

                                    _forcePool = _forcePool - (_previousReinforcementAnalysisPriorityTotal - _priorityTotal);

                                };

                            };

                        };

                    }else{

                        //["NO PREVIOUS ANALYSIS"] call ALIVE_fnc_dump;

                        // set the force pool as the
                        // current total
                        _forcePool = _priorityTotal;

                    };

                    // update the global force pool
                    [ALIVE_MLGlobalRegistry,"updateGlobalForcePool",[_registryID,_forcePool]] call ALIVE_fnc_MLGlobalRegistry;

                };


                private["_primaryReinforcementObjective","_reinforcementType","_sortedClusters",
                "_sortedObjectives","_primaryReinforcementObjectivePriority","_reinforcementAnalysis",
                "_previousPrimaryObjective","_available"];

                _primaryReinforcementObjective = [] call ALIVE_fnc_hashCreate;
                _reinforcementType = "";
                _available = false;

                if(_type == "STATIC") then {

                    // Static analysis, only one insertion point
                    // may be held. This point is dictated
                    // by the placement location
                    // once lost the insertion point is
                    // deactivated until recaptured

                    // if there is no previous analysis
                    if(count _previousReinforcementAnalysis == 0) then {

                        if(count _objectives > 0) then {

                            // sort objectives by distance to module
                            _sortedObjectives = [_objectives,[],{(position _logic) distance (_x select 2 select 1)},"DESCEND"] call ALiVE_fnc_SortBy;

                            // get the highest priority objective
                            _primaryReinforcementObjective = _sortedObjectives select ((count _sortedObjectives)-1);

                            // determine the type of reinforcement according to priority
                            _primaryReinforcementObjectivePriority = [_primaryReinforcementObjective,"priority"] call ALIVE_fnc_hashGet;

                            // if the state of the objective is reserved
                            // objective is available for use
                            _tacom_state = '';
                            if("tacom_state" in (_primaryReinforcementObjective select 1)) then {
                                _tacom_state = [_primaryReinforcementObjective,"tacom_state","none"] call ALIVE_fnc_hashGet;
                            };

                            if(_tacom_state == "reserve") then {
                                _available = true;
                            };

                            _reinforcementType = "DROP";

                            if(_primaryReinforcementObjectivePriority > 50) then {
                                _reinforcementType = "AIR";
                            };

                            if(_primaryReinforcementObjectivePriority > 40 && _primaryReinforcementObjectivePriority < 51) then {
                                _reinforcementType = "HELI";
                            };

                        }else{

                            // no objectives nothing available
                            _available = false;
                        }

                    }else{

                        // there is previous analysis

                        _primaryReinforcementObjective = [_previousReinforcementAnalysis, "primary"] call ALIVE_fnc_hashGet;
                        _reinforcementType = [_previousReinforcementAnalysis, "type"] call ALIVE_fnc_hashGet;

                        // if the state of the objective is reserved
                        // objective is available for use
                        _tacom_state = '';
                        if("tacom_state" in (_primaryReinforcementObjective select 1)) then {
                            _tacom_state = [_primaryReinforcementObjective,"tacom_state","none"] call ALIVE_fnc_hashGet;
                        };

                        if(_tacom_state == "reserve") then {
                            _available = true;
                        };

                    };

                }else{

                    _available = true;

                    // Dynamic analysis, primary insertion objective
                    // will fall back to held objectives, finally
                    // falling back to non held marine or bases

                    if(count _reserve > 0) then {

                        // OPCOM controls some objectives
                        // reinforcements can be delivered
                        // directly assuming heli pads or
                        // airstrips are available


                        // sort reserved objectives by priority
                        _sortedObjectives = [_reserve,[],{([_x, "priority"] call ALIVE_fnc_hashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

                        // get the highest priority objective
                        _primaryReinforcementObjective = _sortedObjectives select ((count _sortedObjectives)-1);

                        // determine the type of reinforcement according to priority
                        _primaryReinforcementObjectivePriority = [_primaryReinforcementObjective,"priority"] call ALIVE_fnc_hashGet;

                        _reinforcementType = "DROP";

                        if(_primaryReinforcementObjectivePriority > 50) then {
                            _reinforcementType = "AIR";
                        };

                        if(_primaryReinforcementObjectivePriority > 40 && _primaryReinforcementObjectivePriority < 51) then {
                            _reinforcementType = "HELI";
                        };


                    }else{

                        // OPCOM controls no objectives
                        // reinforcements must be delivered
                        // via paradrops and or marine landings
                        // near to location of any existing troops

                        // randomly pick between marine and mil location for start position
                        if(random 1 > 0.5) then {

                            if(count(ALIVE_clustersCivMarine select 2) > 0) then {

                                // there are marine objectives available

                                // pick a primary one
                                _primaryReinforcementObjective = selectRandom (ALIVE_clustersCivMarine select 2);

                                _reinforcementType = "MARINE";

                            }else{

                                // no marine objectives available
                                // pick a low priority location for airdrops

                                if(count(ALIVE_clustersMil select 2) > 0) then {

                                    _sortedClusters = [ALIVE_clustersMil select 2,[],{([_x, "priority"] call ALIVE_fnc_hashGet)},"DESCEND"] call ALiVE_fnc_SortBy;

                                    // get the highest priority objective
                                    _primaryReinforcementObjective = _sortedClusters select ((count _sortedClusters)-1);

                                    _reinforcementType = "AIR";

                                };

                            };

                        }else{

                            // pick a low priority location for airdrops

                            if(count(ALIVE_clustersMil select 2) > 0) then {

                                _sortedClusters = [ALIVE_clustersMil select 2,[],{([_x, "priority"] call ALIVE_fnc_hashGet)},"DESCEND"] call ALiVE_fnc_SortBy;

                                // get the highest priority objective
                                _primaryReinforcementObjective = _sortedClusters select ((count _sortedClusters)-1);

                                _reinforcementType = "AIR";

                            };

                        };

                    };
                };

                // store the analysis results
                _reinforcementAnalysis = [] call ALIVE_fnc_hashCreate;
                [_reinforcementAnalysis, "priorityTotal", _priorityTotal] call ALIVE_fnc_hashSet;
                [_reinforcementAnalysis, "type", _reinforcementType] call ALIVE_fnc_hashSet;
                [_reinforcementAnalysis, "available", _available] call ALIVE_fnc_hashSet;
                [_reinforcementAnalysis, "primary", _primaryReinforcementObjective] call ALIVE_fnc_hashSet;

                [_logic, "reinforcementAnalysis", _reinforcementAnalysis] call MAINCLASS;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALIVE ML - On demand analysis complete"] call ALIVE_fnc_dump;
                    ["ALIVE ML - Priority total: %1",_priorityTotal] call ALIVE_fnc_dump;
                    ["ALIVE ML - Reinforcement type: %1",_reinforcementType] call ALIVE_fnc_dump;
                    ["ALIVE ML - Primary reinforcement objective available: %1",_available] call ALIVE_fnc_dump;
                    ["ALIVE ML - Primary reinforcement objective:"] call ALIVE_fnc_dump;
                    _primaryReinforcementObjective call ALIVE_fnc_inspectHash;
                };
                // DEBUG -------------------------------------------------------------------------------------


                _logic setVariable ["analysisInProgress", false];
            };
        };
    };

    case "monitor": {
        if (isServer) then {

            // spawn monitoring loop

            [_logic] spawn {

                private ["_logic","_debug"];

                _logic = _this select 0;
                _debug = [_logic, "debug"] call MAINCLASS;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALIVE ML - Monitoring loop started"] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                waituntil {

                    sleep (10);

                    if!([_logic, "pause"] call MAINCLASS) then {

                        private ["_reinforcementAnalysis","_analysisInProgress","_eventQueue"];

                        _reinforcementAnalysis = [_logic, "reinforcementAnalysis"] call MAINCLASS;

                        // analysis has run
                        if(count _reinforcementAnalysis > 0) then {

                            _analysisInProgress = _logic getVariable ["analysisInProgress", false];

                            // if analysis not processing
                            if!(_analysisInProgress) then {

                                // loop the event queue
                                // and manage each event
                                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                                if((count (_eventQueue select 2)) > 0) then {

                                    {
                                        [_logic,"monitorEvent",[_x, _reinforcementAnalysis]] call MAINCLASS;
                                    } forEach (_eventQueue select 2);

                                };

                            };

                        };

                    };

                    false
                };

            };

        };
    };

    case "monitorEvent": {

         private ["_debug","_registryID","_event","_reinforcementAnalysis","_side","_eventID","_eventData","_eventPosition","_eventSide","_eventFaction",
         "_eventForceMakeup","_eventType","_eventForceInfantry","_eventForceMotorised","_eventForceMechanised","_eventForceArmour",
         "_eventForcePlane","_eventForceHeli","_eventForceSpecOps","_eventTime","_eventState","_eventStateData","_eventCargoProfiles",
         "_eventTransportProfiles","_eventTransportVehiclesProfiles","_playerRequested","_playerRequestProfiles","_reinforcementPriorityTotal"
         ,"_reinforcementType","_reinforcementAvailable","_reinforcementPrimaryObjective","_event",
         "_eventID","_eventQueue","_forcePool","_logEvent","_playerID","_requestID","_payload","_emptyVehicles",
         "_staticIndividuals","_joinIndividuals","_reinforceIndividuals","_staticGroups","_joinGroups","_reinforceGroups","_enableAirTransport","_limitTransportToFaction"];

        _debug = [_logic, "debug"] call MAINCLASS;
        _registryID = [_logic, "registryID"] call MAINCLASS;
        _event = _args select 0;
        _reinforcementAnalysis = _args select 1;

        _side = [_logic, "side"] call MAINCLASS;
        _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

        _enableAirTransport = [_logic, "enableAirTransport"] call MAINCLASS;
        _limitTransportToFaction = [_logic, "limitTransportToFaction"] call MAINCLASS;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        _eventTime = [_event, "time"] call ALIVE_fnc_hashGet;
        _eventState = [_event, "state"] call ALIVE_fnc_hashGet;
        _eventStateData = [_event, "stateData"] call ALIVE_fnc_hashGet;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        _reinforcementPriorityTotal = [_reinforcementAnalysis, "priorityTotal"] call ALIVE_fnc_hashGet;
        _reinforcementType = [_reinforcementAnalysis, "type"] call ALIVE_fnc_hashGet;
        _reinforcementAvailable = [_reinforcementAnalysis, "available"] call ALIVE_fnc_hashGet;
        _reinforcementPrimaryObjective = [_reinforcementAnalysis, "primary"] call ALIVE_fnc_hashGet;

        _eventPosition = _eventData select 0;
        _eventFaction = _eventData select 1;
        _eventSide = _eventData select 2;
        _eventForceMakeup = _eventData select 3;
        _eventType = _eventData select 4;

        _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;


        if(_playerRequested) then {

            _playerID = _eventData select 5;
            _requestID = _eventForceMakeup select 0;
            _payload = _eventForceMakeup select 1;
            _emptyVehicles = _eventForceMakeup select 2;
            _staticIndividuals = _eventForceMakeup select 3;
            _joinIndividuals = _eventForceMakeup select 4;
            _reinforceIndividuals = _eventForceMakeup select 5;
            _staticGroups = _eventForceMakeup select 6;
            _joinGroups = _eventForceMakeup select 7;
            _reinforceGroups = _eventForceMakeup select 8;


        }else{

            _eventForceInfantry = _eventForceMakeup select 0;
            _eventForceMotorised = _eventForceMakeup select 1;
            _eventForceMechanised = _eventForceMakeup select 2;
            _eventForceArmour = _eventForceMakeup select 3;
            _eventForcePlane = _eventForceMakeup select 4;
            _eventForceHeli = _eventForceMakeup select 5;

        };

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALIVE ML - Monitoring Event"] call ALIVE_fnc_dump;
            _event call ALIVE_fnc_inspectHash;
            //_reinforcementAnalysis call ALIVE_fnc_inspectHash;
        };
        // DEBUG -------------------------------------------------------------------------------------


        // react according to current event state
        switch(_eventState) do {

            // AI REQUEST ---------------------------------------------------------------------------------------------------------------------------------

            // the units have been requested
            // spawn the units at the insertion point
            case "requested": {

                private ["_waitTime"];

                // according to the type of reinforcement
                // adjust wait time for creation of profiles

                switch(_reinforcementType) do {
                    case "AIR": {
                        _waitTime = WAIT_TIME_AIR;
                        _eventType = "AIRDROP";
                    };
                    case "HELI": {
                        _waitTime = WAIT_TIME_HELI;
                        _eventType = "HELI_INSERT";
                    };
                    case "MARINE": {
                        _waitTime = WAIT_TIME_MARINE;
                        _eventType = "HELI_INSERT";
                    };
                    case "DROP": {
                        _waitTime = WAIT_TIME_DROP;
                        _eventType = "STANDARD";
                    };
                };


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALIVE ML - Event state: %1 event timer: %2 wait time on event: %3 ",_eventState, (time - _eventTime), _waitTime] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // if the reinforcement objective is
                // not available, cancel the event

                if(_reinforcementAvailable) then {

                    if((time - _eventTime) > _waitTime) then {

                        private ["_reinforcementPosition","_playersInRange","_paraDrop","_remotePosition","_airTrans","_noHeavy","_slingAvailable","_water","_AA","_newPos","_routeDistance","_routeDirection"];

                        // Override delivery mechanism if there is water or AA or armored vehicles required
                        _noHeavy = _eventForceMechanised == 0 && _eventForceArmour == 0;

                        _water = false; // water is in the way

                        // Check route
                        _routeDistance = _eventPosition distance ([_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet);
                        _routeDirection = (_eventPosition getDir ([_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet));
                        _newPos = _eventPosition;
                        for "_i" from 0 to _routeDistance step 20 do {
                            _newPos = _newPos getpos [20, _routeDirection];
                            if (surfaceIsWater _newPos) exitWith {_water = true;};
                        };

                        _slingAvailable = false; // slingloading is available as a service
                        _airTrans = [];

                        if (_enableAirTransport) then {
                            _airTrans = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            if(count _airTrans == 0 && !_limitTransportToFaction) then {
                                 _airTrans = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };
                            // Check helicopters can slingload
                            {
                                _slingAvailable = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass"), 0] call ALiVE_fnc_getConfigValue > 1000;
                                if (_slingAvailable) exitWith {};
                            } foreach  _airTrans;
                        };

                        // TBD: WHAT THE FUCK IS THIS PILE OF SHIT BELOW?! THIS NEEDS TO BE REDONE PROPERLY!

                        // If OPCOM request airdrop of tanks, change to convoy
                        if (_eventType == "AIRDROP" && !_noHeavy) then {_eventType = "STANDARD";};

                        // If its air drop and nothing heavy and sling available then switch to Heli Insert
                        if (_eventType == "AIRDROP" && _noHeavy && _slingAvailable) then {_eventType = "HELI_INSERT";};

                        // If OPCOM requested convoy but there's water - then heli insert
                        if (_eventType == "STANDARD" && _water && _noHeavy && count _airTrans > 0) then {_eventType = "HELI_INSERT";};

                        // If sling is not available then its an AIRDROP
                        If (_eventType == "HELI_INSERT" && _eventForceMotorised > 0 && !_slingAvailable && _noHeavy) then {_eventType = "AIRDROP";};

                        // If still Heli Insert is chosen after all and armoured vehicles are requested override to convoy
                        If (_eventType == "HELI_INSERT" && {!_noHeavy}) then {_eventType = "STANDARD"};

                        if (_water && !_noHeavy) then {_eventType = "STANDARD"}; // COULD DELIVER TO NEAREST BEACH?

                        if (count _airTrans == 0) then {_eventType = "STANDARD"};

                        // Choose start position
                        if(_eventType == "STANDARD" || _eventType == "HELI_INSERT") then {

                            _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;

                        }else{
                            _reinforcementPosition = _eventPosition;
                        };

                        ["AI LOGCOM Side: %9 Type: %6 From: %8 To: %7, Dist: %1, Dir: %2, Water: %3, Sling: %4, Heavy: %5", _routeDistance, _routeDirection, _water, _slingAvailable, !_noheavy, _eventType, _eventPosition, _reinforcementPosition, _side] call ALiVE_fnc_dump;

                        // if heli insert allow only air and
                        // infantry groups & Motorized
                        if(_eventType == "HELI_INSERT") then {
                            _eventForceMechanised = 0;
                            _eventForceArmour = 0;
                        };

                        // players near check

                        _playersInRange = [_reinforcementPosition, 500] call ALiVE_fnc_anyPlayersInRange;

                        // if players are in visible range
                        // para drop groups instead of
                        // spawning on the ground

                        _paraDrop = false;
                        if(_playersInRange > 0) then {
                            _paraDrop = true;

                            _remotePosition = [_reinforcementPosition, 2000] call ALIVE_fnc_getPositionDistancePlayers;
                        }else{
                            _remotePosition = _reinforcementPosition;
                        };


                        // wait time complete create profiles
                        // get groups according to requested force makeup

                        private ["_infantryGroups","_infantryProfiles","_transportGroups","_transportProfiles",
                        "_transportVehicleProfiles","_group","_groupCount","_totalCount","_vehicleClass",
                        "_profiles","_profileIDs","_profileID","_position"];

                        _groupCount = 0;
                        _totalCount = 0;

                        // motorised

                        private ["_motorisedGroups","_motorisedProfiles"];

                        _motorisedGroups = [];
                        _motorisedProfiles = [];

                        for "_i" from 0 to _eventForceMotorised -1 do {
                            private ["_group","_tempGroups"];
                            _tempGroups = [];
                            _group = ["Motorized",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _tempGroups pushback _group;
                            };
                            _group = ["Motorized_MTP",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _tempGroups pushback _group;
                            };
                            if (count _tempGroups > 0) then {
                                _group = selectRandom _tempGroups;
                                _motorisedGroups pushback _group;
                            };
                        };

                        _motorisedGroups = _motorisedGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _motorisedGroups;
                        _totalCount = _totalCount + _groupCount;

                        // create profiles
                        for "_i" from 0 to _groupCount -1 do {

                            _group = _motorisedGroups select _i;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop && _eventType != "HELI_INSERT") then {
                                _position set [2,PARADROP_HEIGHT];
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _motorisedProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                            };
                        };

                        [_eventCargoProfiles, "motorised", _motorisedProfiles] call ALIVE_fnc_hashSet;

                        if(_debug) then {
                            ["ALIVE ML - Profiles: %1 %2 %3 ", _eventForceMotorised, _motorisedGroups, _motorisedProfiles] call ALIVE_fnc_dump;
                        };

                        TRACE_1("ML HELI INSERT", _motorisedProfiles);

                        if(_eventType == "HELI_INSERT" && (count _motorisedProfiles > 0)) then {

                            // create heli transport vehicles for groups with vehicles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            _payloadGroupProfiles = [];

                            if(count _transportGroups == 0 || !_limitTransportToFaction) then {
                                _transportGroups append ([ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet);
                            };

                            if(count _transportGroups > 0) then {

                                // If any of the vehicles cannot be airlifted, will need to switch to a standard delivery for vehicles
                                private _requiresStandardDelivery = false;

                                {
                                    _groupProfile = _x;

                                    {
                                        private ["_currentDiff","_vehicleClass","_position","_payloadWeight","_slingLoadProfile"];

                                        // Check to see if profile is a vehicle
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {

                                            // Get the profile
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                                            // _slingloadProfile call ALIVE_fnc_inspectHash;

                                            _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;

                                            // Select helicopter that can slingload the vehicle
                                            _vehicleClass = "";
                                            _currentDiff = 15000;
                                            {
                                                private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                                _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;

												if (!isnil "_slingloadmax") then {
                                                	_slingDiff = _slingloadmax - _payloadWeight;

                                                	if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x;};
												};
                                            } foreach _transportGroups;

                                            // Cannot find vehicle big enough to slingload...
                                            if (_vehicleClass == "") exitWith {_requiresStandardDelivery = true};

                                            //save vehicle class to group profile
                                            [_slingloadProfile, "vehicleClassSling", _vehicleClass] call ALiVE_fnc_hashSet;
                                        };

                                    } foreach _groupProfile;

                                } foreach _motorisedProfiles;

                                // If we can't helo a vehicle then just send it by land
                                if (_requiresStandardDelivery) exitWith {_eventType = "STANDARD";};

                                // For each group - create helis to carry their vehicles
                                {
                                    _groupProfile = _x;

                                    {

                                        private ["_vehicleClass","_position","_slingLoadProfile"];

                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {

                                            // Get the profile
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            _vehicleClass = [_slingloadProfile, "vehicleClassSling"] call ALiVE_fnc_hashGet;
                                            [_slingloadProfile, "vehicleClassSling"] call ALiVE_fnc_hashRem;

                                            // setup slingloading
                                            _position = _reinforcementPosition getPos [random(200), random(360)];
                                            _position set [2,PARADROP_HEIGHT];

                                            // Create slingloading heli (slingloading another profile!)
                                            _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [[_x], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                            // Set slingload state on profile
                                            [_slingloadProfile,"slung",[[_profiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                            if(_debug) then {
                                                ["ALIVE ML - Slingloading: %1", _vehicleClass] call ALIVE_fnc_dump;
                                                _slingloadProfile call ALIVE_fnc_inspectHash;
                                            };

                                            _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                            _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                            _profileIDs = [];
                                            {
                                                _profileID = _x select 2 select 4;
                                                _profileIDs pushback _profileID;
                                            } forEach _profiles;

                                            _payloadGroupProfiles pushback _profileIDs;

                                            _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                            _profile = _profiles select 0;
                                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                            _totalCount = _totalCount + 1;
                                        };

                                    } foreach _groupProfile;

                                } foreach _motorisedProfiles;

                            };
                            _eventTransportProfiles = _transportProfiles;
                            _eventTransportVehiclesProfiles = _transportVehicleProfiles;

                            [_eventCargoProfiles,"payloadGroups",_payloadGroupProfiles] call ALIVE_fnc_hashSet;

                        };

                        // infantry
                        _infantryGroups = [];
                        _infantryProfiles = [];

                        for "_i" from 0 to _eventForceInfantry -1 do {
                            _group = ["Infantry",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _infantryGroups pushback _group;
                            }
                        };

                        _infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _infantryGroups;
                        _totalCount = _totalCount + _groupCount;

                        // create profiles

                        for "_i" from 0 to _groupCount -1 do {

                            _group = _infantryGroups select _i;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {

                                if(_eventType == "HELI_INSERT") then {
                                    _position = _remotePosition;
                                }else{
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _infantryProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                            };
                        };

                        [_eventCargoProfiles, "infantry", _infantryProfiles] call ALIVE_fnc_hashSet;

                        if(_eventType == "HELI_INSERT") then {

                            private ["_infantryProfileID","_infantryProfile","_profileWaypoint","_profile"];

                            // create air transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                for "_i" from 0 to _groupCount -1 do {

                                    _position = _remotePosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if(count _transportGroups > 0) then {

                                        _vehicleClass = selectRandom _transportGroups;

                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                        if(count _infantryProfiles >= _i) then {
                                            if(count (_infantryProfiles select _i) > 0) then {
                                                _infantryProfileID = _infantryProfiles select _i select 0;
                                                if!(isNil "_infantryProfileID") then {
                                                    _infantryProfile = [ALIVE_profileHandler, "getProfile", _infantryProfileID] call ALIVE_fnc_profileHandler;
                                                    if!(isNil "_infantryProfile") then {
                                                        [_infantryProfile,_profiles select 1] call ALIVE_fnc_createProfileVehicleAssignment;
                                                    };
                                                };
                                            };
                                        };

                                        _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        _profile = _profiles select 0;
                                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                    };

                                };

                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;
                        };

                        if(_eventType == "STANDARD") then {

                            // create ground transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {
                                for "_i" from 0 to _groupCount -1 do {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if(count _transportGroups > 0) then {

                                        _vehicleClass = selectRandom _transportGroups;

                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,false,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    };

                                };
                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;
                        };

                        // armour
                        private ["_armourGroups","_armourProfiles"];

                        _armourGroups = [];
                        _armourProfiles = [];

                        for "_i" from 0 to _eventForceArmour -1 do {
                            _group = ["Armored",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _armourGroups pushback _group;
                            };
                        };

                        _armourGroups = _armourGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _armourGroups;
                        _totalCount = _totalCount + _groupCount;

                        // create profiles
                        for "_i" from 0 to _groupCount -1 do {

                            _group = _armourGroups select _i;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                _position set [2,PARADROP_HEIGHT];
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _armourProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                            };
                        };

                        [_eventCargoProfiles, "armour", _armourProfiles] call ALIVE_fnc_hashSet;


                        // mechanised

                        private ["_mechanisedGroups","_mechanisedProfiles"];

                        _mechanisedGroups = [];
                        _mechanisedProfiles = [];

                        for "_i" from 0 to _eventForceMechanised -1 do {
                            _group = ["Mechanized",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _mechanisedGroups pushback _group;
                            }
                        };

                        _mechanisedGroups = _mechanisedGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _mechanisedGroups;
                        _totalCount = _totalCount + _groupCount;

                        // create profiles
                        for "_i" from 0 to _groupCount -1 do {

                            _group = _mechanisedGroups select _i;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                _position set [2,PARADROP_HEIGHT];
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _mechanisedProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                            };
                        };

                        [_eventCargoProfiles, "mechanised", _mechanisedProfiles] call ALIVE_fnc_hashSet;

                        // plane

                        private ["_planeProfiles","_planeClasses","_motorisedProfiles","_vehicleClass"];

                        _planeProfiles = [];

                        if(_eventType == "STANDARD" || _eventType == "HELI_INSERT") then {

                            _planeClasses = [0,_eventFaction,"Plane"] call ALiVE_fnc_findVehicleType;
                            _planeClasses = _planeClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                            for "_i" from 0 to _eventForcePlane -1 do {

                                _position = _remotePosition getPos [random(200), random(360)];
                                _position set [2,1000];

                                if(count _planeClasses > 0) then {

                                    _vehicleClass = selectRandom _planeClasses;

                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _planeProfiles pushback _profileIDs;

                                    _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    _profile = _profiles select 0;
                                    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                }
                            };

                            _groupCount = count _planeProfiles;
                            _totalCount = _totalCount + _groupCount;

                        };

                        [_eventCargoProfiles, "plane", _planeProfiles] call ALIVE_fnc_hashSet;


                        // heli

                        private ["_heliProfiles","_heliClasses","_motorisedProfiles","_vehicleClass"];

                        _heliProfiles = [];

                        if(_eventType == "STANDARD" || _eventType == "HELI_INSERT") then {

                            _heliClasses = [0,_eventFaction,"Helicopter"] call ALiVE_fnc_findVehicleType;
                            _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                            for "_i" from 0 to _eventForceHeli -1 do {

                                _position = _remotePosition getPos [random(200), random(360)];
                                _position set [2,1000];

                                if(count _heliClasses > 0) then {

                                    _vehicleClass = selectRandom _heliClasses;

                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _heliProfiles pushback _profileIDs;

                                    _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    _profile = _profiles select 0;
                                    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                }
                            };

                            _groupCount = count _heliProfiles;
                            _totalCount = _totalCount + _groupCount;

                        };

                        [_eventCargoProfiles, "heli", _heliProfiles] call ALIVE_fnc_hashSet;


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ALIVE ML - Profiles created: %1 ",_totalCount] call ALIVE_fnc_dump;
                            switch(_eventType) do {
                                case "STANDARD": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"ML INSERTION"]] call MAINCLASS;
                                };
                                case "HELI_INSERT": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"ML INSERTION"]] call MAINCLASS;
                                };
                                case "AIRDROP": {
                                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML AIRDROP"]] call MAINCLASS;
                                };
                            };
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        if(_totalCount > 0) then {

                            // remove the created group count
                            // from the force pool
                            _forcePool = _forcePool - _totalCount;
                            // update the global force pool
                            [ALIVE_MLGlobalRegistry,"updateGlobalForcePool",[_registryID,_forcePool]] call ALIVE_fnc_MLGlobalRegistry;

                            switch(_eventType) do {
                                case "STANDARD": {

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "transportLoad"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "HELI_INSERT": {

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "heliTransportStart"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "AIRDROP": {

                                    // update the state of the event
                                    // next state is aridrop wait
                                    [_event, "state", "airdropWait"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                            };

                            [_event, "cargoProfiles", _eventCargoProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportProfiles", _eventTransportProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportVehiclesProfiles", _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;

                            [_logic, "prepareUnitCounts", _event] call MAINCLASS;

                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                        }else{

                            // no profiles were created
                            // nothing to do so cancel...

                            if(_debug) then {
                                ["ALIVE ML - No reinforcements have been created! Cancelling event: %1", _eventID] call ALIVE_fnc_dump;
                            };                            

                            [_logic, "removeEvent", _eventID] call MAINCLASS;
                        };
                    };
                }else{
                    // no insertion point available
                    // nothing to do so cancel...

                    if(_debug) then {
                        ["ALIVE ML - No insertion point available! Cancelling event: %1", _eventID] call ALIVE_fnc_dump;
                    };

                    [_logic, "removeEvent", _eventID] call MAINCLASS;

                };
            };

            // HELI INSERT ------------------------------------------------------------------------------------------------------------------------------

            case "heliTransportStart": {

                // assign waypoints to all
                // vehicle commanders

                private ["_transportProfiles","_infantryProfiles","_planeProfiles","_heliProfiles","_position","_profileWaypoint","_profile","_count","_slingLoadProfiles"];

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                [_event, "finalDestination", _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)]] call ALIVE_fnc_hashSet;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 100, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _transportProfiles;

                {
                    _profileWaypoint = [_eventPosition, 100, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;

                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _infantryProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 100, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _planeProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 100, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _heliProfiles;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML DESTINATION"]] call MAINCLASS;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // dispatch event
                _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                // respond to player request
                if(_playerRequested) then {
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ENROUTE"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                };


                [_event, "state", "heliTransport"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

            };

            case "heliTransport": {

                // waypoint complete check stage

                private ["_waitTotalIterations","_waitIterations","_waitDifference","_transportProfiles","_infantryProfiles","_completed",
                "_planeProfiles","_heliProfiles","_waypointsCompleted","_waypointsNotCompleted","_profile","_position","_distance","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units haven't reached objective
                _waitTotalIterations = 200;
                _waitIterations = 0;
                if(count _eventStateData > 0) then {
                    _waitIterations = _eventStateData select 0;
                };

                // check waypoints
                // if all waypoints are complete
                // trigger end of logistics control

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _waypointsCompleted = 0;
                _waypointsNotCompleted = 0;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {

                            [_logic,"setHelicopterTravel",_profile] call MAINCLASS;

                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransportHelicopter",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _transportProfiles;

                // if some waypoints are completed
                // can assume most units are close to
                // destination, adjust timeout
                if(_waypointsCompleted > 0) then {
                    _waitDifference = _waitTotalIterations - _waitIterations;
                    if(_waitDifference > 30) then {
                        _waitIterations = _waitTotalIterations - 10;
                    };
                };

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;
                        };

                    };

                } forEach _planeProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {

                            [_logic,"setHelicopterTravel",_profile] call MAINCLASS;

                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransportHelicopter",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _heliProfiles;


                // all waypoints completed

                if(_waypointsNotCompleted == 0) then {

                    if(_waypointsCompleted > 0) then {
                        [_event, "state", "heliTransportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    }else{
                        // set state to event complete
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    };

                    // respond to player request
                    if(_playerRequested) then {
                        if(_waypointsCompleted > 0) then {
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ARRIVED"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        }else{
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_LOST"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        };
                    };

                }else{

                    // not all waypoints have been completed
                    // to ensure control passes to OPCOM eventually
                    // limited number of iterations in this
                    // state are used.

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if(_waitIterations > _waitTotalIterations) then {

                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                        //["TRANSPORT TRAVEL WAIT - ITERATIONS COMPLETE"] call ALIVE_fnc_dump;
                        [_event, "state", "heliTransportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    };
                };

            };

            case "heliTransportUnloadWait": {

                // wait until all vehicles
                // have unloaded their cargo

                private ["_waitTotalIterations","_waitIterations","_infantryProfile","_active","_units",
                "_unloadedUnits","_loadedUnits","_waypointsCompleted","_waypointsNotCompleted","_profile","_position","_distance","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units haven't reached objective
                _waitTotalIterations = 30;
                _waitIterations = 0;
                if(count _eventStateData > 0) then {
                    _waitIterations = _eventStateData select 0;
                };


                // Check to see if Infantry profiles are unloaded
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _unloadedUnits = [];
                _loadedUnits = [];
                _units = [];

                {

                    _infantryProfile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_infantryProfile") then {

                        _active = _infantryProfile select 2 select 1;

                        // only need to worry about this is there are
                        // players nearby

                        if(_active) then {

                            _units = _infantryProfile select 2 select 21;

                            // catagorise units into loaded and not
                            // loaded arrays
                            {
                                if(alive _x) then {
                                    if(vehicle _x == _x) then {
                                        _unloadedUnits pushback _x;
                                    }else{
                                        _loadedUnits pushback _x;
                                    };
                                };
                            } forEach _units;

                        }else{

                            // profiles are not active, can skip this wait
                            // continue on to travel

                            _unloadedUnits = [];

                        };

                    };

                } forEach _infantryProfiles;


                // Check to see if payload profiles are ready to return
                // Slingloaders can return once done.
                // If vehicle no longer has cargo it can return
                private ["_payloadUnloaded","_payloadProfiles"];
                _payloadUnloaded = true;

                _payloadProfiles = if (_playerRequested) then {_playerRequestProfiles select 2 select 7};

                if (!isnil "_payloadProfiles") then {
                    _payloadProfiles append ([_eventCargoProfiles, "payloadGroups"] call ALIVE_fnc_hashGet);
                } else {
                    _payloadProfiles = [_eventCargoProfiles, "payloadGroups"] call ALIVE_fnc_hashGet;
                };

                if (!isNil "_payloadProfiles") then {

                    {
                        private ["_vehicleProfile"];

                        if (count _x > 1) then {

                            _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x select 1] call ALIVE_fnc_profileHandler;

                            if!(isNil "_vehicleProfile") then {

                                private ["_active","_slingLoading","_slingload","_noCargo","_vehicle"];

                                if (_debug) then {
                                    _vehicleProfile call ALIVE_fnc_inspectHash;
                                };

                                _active = _vehicleProfile select 2 select 1;

                                _slingLoading = [_vehicleProfile,"slingloading",false] call ALiVE_fnc_hashGet;

                                _vehicle = _vehicleProfile select 2 select 10;
                                _noCargo = count (_vehicle getvariable ["ALiVE_SYS_LOGISTICS_CARGO",[]]) == 0;

                                // If payload vehicle is not slingloading and its cargo is empty - its done.
                                TRACE_2("PR UNLOADED", !_slingLoading, _noCargo);
                                if( _active && _noCargo && !_slingloading ) then {

                                    _payloadUnloaded = true;

                                } else {

                                    _payloadUnloaded = false;

                                };

                                // If we've run out of time, dump cargo
                                if(_waitIterations == _waitTotalIterations) then {
                                    if (_active && !_noCargo) then {
                                        [MOD(SYS_LOGISTICS),"unloadObjects",[_vehicle,_vehicle]] call ALiVE_fnc_logistics;
                                    };
                                };
                            };
                        };
                    } foreach _payloadProfiles;
                };

                TRACE_2("PR UNLOADED", _loadedUnits, _payloadUnloaded);

                // If all inf units are unloaded and all payloads are unloaded, then complete
                if(count _loadedUnits == 0 && _payloadUnloaded) then {

                    // all unloaded
                    // continue on to travel
                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    [_event, "state", "heliTransportComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

                _waitIterations = _waitIterations + 1;
                _eventStateData set [0, _waitIterations];
                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                if(_waitIterations > _waitTotalIterations) then {

                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    [_event, "state", "heliTransportComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            case "heliTransportReturn": {

                private ["_position","_profileWaypoint","_profile","_reinforcementPosition","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if(count _eventTransportProfiles > 0) then {

                    // send transport vehicles back to insertion point and beyond 1500m to ensure it
                    {
                        _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;
                        _position = _reinforcementPosition getPos [1500, (([_event, "finalDestination"] call ALIVE_fnc_hashGet) getDir _reinforcementPosition)];
                        _profileWaypoint = [_position, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                        };

                    } forEach _eventTransportProfiles;

                    // set state to wait for return of transports
                    [_event, "state", "heliTransportReturnWait"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                }else{

                    // no transport vehicles
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            // AIR DROP ------------------------------------------------------------------------------------------------------------------------------

            case "airdropWait": {

                private ["_waitIterations","_waitTotalIterations"];

                _waitTotalIterations = 15;
                _waitIterations = 0;
                if(count _eventStateData > 0) then {
                    _waitIterations = _eventStateData select 0;
                };

                _waitIterations = _waitIterations + 1;
                _eventStateData set [0, _waitIterations];
                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                if(_waitIterations > _waitTotalIterations) then {

                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            // CONVOY ---------------------------------------------------------------------------------------------------------------------------------

            case "transportLoad": {

                // for any infantry groups order
                // them to load onto the transport vehicles

                private ["_infantryProfiles","_processedProfiles","_infantryProfile","_transportProfileID","_transportProfile"];

                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _processedProfiles = 0;

                if(count _eventTransportVehiclesProfiles > 0) then {

                    {
                        _infantryProfile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                        if!(isNil "_infantryProfile") then {

                            _transportProfileID = _eventTransportVehiclesProfiles select _processedProfiles;
                            _transportProfile = [ALIVE_profileHandler, "getProfile", _transportProfileID] call ALIVE_fnc_profileHandler;
                            if!(isNil "_transportProfile") then {

                                [_infantryProfile,_transportProfile] call ALIVE_fnc_createProfileVehicleAssignment;

                                _processedProfiles = _processedProfiles + 1;
                            };
                        };

                    } forEach _infantryProfiles;

                };

                [_event, "state", "transportLoadWait"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

            };

            case "transportLoadWait": {

                private ["_infantryProfiles","_waitIterations","_waitTotalIterations","_loadedUnits","_notLoadedUnits",
                "_infantryProfile","_active","_units","_vehicle","_vehicleClass"];

                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units havent loaded up
                _waitTotalIterations = 35;
                _waitIterations = 0;
                if(count _eventStateData > 0) then {
                    _waitIterations = _eventStateData select 0;
                };

                // if there are transport vehicles available

                if(count _eventTransportVehiclesProfiles > 0) then {

                    _loadedUnits = [];
                    _notLoadedUnits = [];

                    {
                        _infantryProfile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                        if!(isNil "_infantryProfile") then {
                            _active = _infantryProfile select 2 select 1;

                            // only need to worry about this is there are
                            // players nearby

                            if(_active) then {

                                _units = _infantryProfile select 2 select 21;

                                // catagorise units into loaded and not
                                // loaded arrays
                                {
                                    _vehicle = vehicle _x;
                                    _vehicleClass = typeOf _vehicle;
                                    if(_vehicleClass != "Steerable_Parachute_F") then {
                                        if(vehicle _x == _x) then {
                                            _notLoadedUnits pushback _x;
                                        }else{
                                            _loadedUnits pushback _x;
                                        };
                                    }else{
                                        _notLoadedUnits pushback _x;
                                    };

                                } forEach _units;

                            }else{

                                // profiles are not active, can skip this wait
                                // continue on to travel

                                [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                            };

                        };

                    } forEach _infantryProfiles;

                    // if there are units left to be loaded
                    // wait for x iterations for loading to occur
                    // once time is up delete all not loaded units

                    if(count _notLoadedUnits > 0) then {

                        _waitIterations = _waitIterations + 1;
                        _eventStateData set [0, _waitIterations];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                        if(_waitIterations > _waitTotalIterations) then {

                            {
                                deleteVehicle _x;
                            } forEach _notLoadedUnits;

                            _eventStateData set [0, 0];
                            [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                            [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                        };

                    }else{

                        // all units have loaded
                        // continue on to travel

                        [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    };


                }else{

                    // no transport vehicles available
                    // continue on to travel

                    [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

            };

            case "transportStart": {

                // assign waypoints to all
                // vehicle commanders

                private ["_transportProfiles","_infantryProfiles","_armourProfiles","_mechanisedProfiles","_motorisedProfiles",
                "_planeProfiles","_heliProfiles","_profileWaypoint","_profile","_position","_countProfiles","_positionSeries","_seriesIndex","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
                _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
                _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _countProfiles = (count(_transportProfiles)) + (count(_armourProfiles)) + (count(_mechanisedProfiles)) + (count(_motorisedProfiles));

                _position = [_eventPosition] call ALIVE_fnc_getClosestRoad;

                _positionSeries = [_position,300,_countProfiles,false] call ALIVE_fnc_getSeriesRoadPositions;

                if((count _positionSeries) < _countProfiles) then {
                    for "_i" from 0 to _countProfiles -1 do {
                        _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                        _positionSeries set [_i, _position];
                    };
                };

                _seriesIndex = 0;

                [_event, "finalDestination", _positionSeries select 0] call ALIVE_fnc_hashSet;

                {

                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _transportProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _infantryProfiles;

                {
                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "NORMAL", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _armourProfiles;

                {
                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _mechanisedProfiles;

                {
                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _motorisedProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _planeProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _heliProfiles;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML DESTINATION"]] call MAINCLASS;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // dispatch event
                _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;


                if(_playerRequested) then {
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ENROUTE"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                };


                [_event, "state", "transportTravel"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
            };

            case "transportTravel": {

                // waypoint complete check stage

                private ["_waitTotalIterations","_waitIterations","_waitDifference","_transportProfiles","_infantryProfiles",
                "_armourProfiles","_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles",
                "_waypointsCompleted","_waypointsNotCompleted","_profile","_position","_distance","_count","_completed"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units haven't reached objective
                _waitTotalIterations = 400;
                _waitIterations = 0;
                if(count _eventStateData > 0) then {
                    _waitIterations = _eventStateData select 0;
                };

                // check waypoints
                // if all waypoints are complete
                // trigger end of logistics control

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
                _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
                _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _waypointsCompleted = 0;
                _waypointsNotCompleted = 0;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };
                } forEach _transportProfiles;

                // if some waypoints are completed
                // can assume most units are close to
                // destination, adjust timeout
                if(_waypointsCompleted > 0) then {
                    _waitDifference = _waitTotalIterations - _waitIterations;
                    if(_waitDifference > 50) then {
                        _waitIterations = _waitTotalIterations - 15;
                    };
                };

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _armourProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _mechanisedProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _motorisedProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                        };

                    };

                } forEach _planeProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;
                        };

                    };

                } forEach _heliProfiles;


                // all waypoints completed

                if(_waypointsNotCompleted == 0) then {

                    if(_waypointsCompleted > 0) then {
                        [_event, "state", "transportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    }else{
                        // set state to event complete
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    };

                    // respond to player request
                    if(_playerRequested) then {
                        if(_waypointsCompleted > 0) then {
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ARRIVED"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        }else{
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_LOST"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        };
                    };

                }else{

                    // not all waypoints have been completed
                    // to ensure control passes to OPCOM eventually
                    // limited number of iterations in this
                    // state are used.

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if(_waitIterations > _waitTotalIterations) then {

                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                        [_event, "state", "transportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;


                    };
                };

            };

            case "transportUnloadWait": {

                // wait until all vehicles
                // have unloaded their cargo

                private ["_waitTotalIterations","_waitIterations","_infantryProfile","_active","_units",
                "_unloadedUnits","_loadedUnits","_waypointsCompleted","_waypointsNotCompleted","_profile","_position","_distance","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units haven't reached objective
                _waitTotalIterations = 40;
                _waitIterations = 0;
                if(count _eventStateData > 0) then {
                    _waitIterations = _eventStateData select 0;
                };

                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _unloadedUnits = [];
                _loadedUnits = [];

                {

                    _infantryProfile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_infantryProfile") then {

                        _active = _infantryProfile select 2 select 1;

                        // only need to worry about this is there are
                        // players nearby

                        if(_active) then {

                            _units = _infantryProfile select 2 select 21;

                            // catagorise units into loaded and not
                            // loaded arrays
                            {
                                if(alive _x) then {
                                    if(vehicle _x == _x) then {
                                        _unloadedUnits pushback _x;
                                    }else{
                                        _loadedUnits pushback _x;
                                    };
                                };
                            } forEach _units;

                        }else{

                            // profiles are not active, can skip this wait

                            [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                        };

                    };

                } forEach _infantryProfiles;

                // Check to see if payload profiles are ready to return
                // If vehicle no longer has cargo it can return
                private ["_payloadUnloaded","_payloadProfiles"];
                _payloadUnloaded = true;
                _payloadProfiles = if (_playerRequested) then {_playerRequestProfiles select 2 select 7};

                if (!isnil "_payloadProfiles") then {
                    _payloadProfiles append ([_eventCargoProfiles, "payloadGroups"] call ALIVE_fnc_hashGet);
                } else {
                    _payloadProfiles = [_eventCargoProfiles, "payloadGroups"] call ALIVE_fnc_hashGet;
                };
                if (!isNil "_payloadProfiles") then {
                    {
                        private ["_vehicleProfile"];

                        _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x select 1] call ALIVE_fnc_profileHandler;

                        if!(isNil "_vehicleProfile") then {

                            private ["_active","_noCargo","_vehicle"];

                            if (_debug) then {
                                _vehicleProfile call ALIVE_fnc_inspectHash;
                            };

                            _active = _vehicleProfile select 2 select 1;

                            _vehicle = _vehicleProfile select 2 select 10;
                            _noCargo = count (_vehicle getvariable ["ALiVE_SYS_LOGISTICS_CARGO",[]]) == 0;

                            // If payload vehicle is not slingloading and its cargo is empty - its done.
                            TRACE_1("PR UNLOADED", _noCargo);
                            if( _active && _noCargo) then {

                                _payloadUnloaded = true;

                            } else {

                                _payloadUnloaded = false;

                            };

                            // If we've run out of time, dump cargo
                            if(_waitIterations == _waitTotalIterations) then {
                                if (_active && !_noCargo) then {
                                    [MOD(SYS_LOGISTICS),"unloadObjects",[_vehicle,_vehicle]] call ALiVE_fnc_logistics;
                                };
                            };
                        };
                    } foreach _payloadProfiles;
                };

                TRACE_2("PR UNLOADED", _loadedUnits, _payloadUnloaded);

                // If all inf units are unloaded and all payloads are unloaded, then complete
                if(count _loadedUnits == 0 && _payloadUnloaded) then {

                    // all unloaded
                    // continue on to travel
                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    [_event, "state", "transportComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

                _waitIterations = _waitIterations + 1;
                _eventStateData set [0, _waitIterations];
                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                if(_waitIterations > _waitTotalIterations) then {

                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    [_event, "state", "transportComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            case "transportComplete";
            case "heliTransportComplete": {
                // unloading complete
                // if profiles are active move on
                // to return to insertion point
                // if not active destroy transport profiles
                private ["_transportProfile","_inCargo","_cargoProfileID","_cargoProfile","_active","_inCommand","_commandProfileID","_commandProfile","_anyActive","_count"];
                _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if (_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if (count _eventTransportVehiclesProfiles > 0) then {
                    _anyActive = 0;

                    {
                        _transportProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if !(isNil "_transportProfile") then {
                            _active = _transportProfile select 2 select 1;

                            if (_active) then {
                                _anyActive = _anyActive + 1;
                            } else {
                                // if not active dispose of transport profiles
                                _inCommand = _transportProfile select 2 select 8;

                                if (count _inCommand > 0) then {
                                    _commandProfileID = _inCommand select 0;
                                    _commandProfile = [ALIVE_profileHandler, "getProfile", _commandProfileID] call ALIVE_fnc_profileHandler;

                                    if !(isNil "_commandProfile") then {
                                        [_commandProfile, "destroy"] call ALIVE_fnc_profileEntity;
                                        //[ALIVE_profileHandler, "unregisterProfile", _commandProfile] call ALIVE_fnc_profileHandler;
                                    };
                                };

                                [_transportProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                                //[ALIVE_profileHandler, "unregisterProfile", _transportProfile] call ALIVE_fnc_profileHandler;

                                [_logic, "setEventProfilesAvailable", _event] call MAINCLASS;

                                // set state to event complete
                                [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                            };
                        };
                    } forEach _eventTransportVehiclesProfiles;

                    if (_anyActive > 0) then {
                        [_logic, "setEventProfilesAvailable", _event] call MAINCLASS;

                        // there are active transport vehicles
                        // send them back to insertion point
                        if (_eventState == "transportComplete") then {
                            [_event, "state", "transportReturn"] call ALIVE_fnc_hashSet;
                        } else {
                            [_event, "state", "heliTransportReturn"] call ALIVE_fnc_hashSet;
                        };

                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    };
                } else {
                    // no transport vehicles
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };
            };

            case "transportReturn": {

                private ["_position","_profileWaypoint","_reinforcementPosition","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if(count _eventTransportProfiles > 0) then {

                    // send transport vehicles back to insertion point
                    {
                        _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;
                        _position = _reinforcementPosition getPos [random(300), random(360)];
                        _position = [_position] call ALIVE_fnc_getClosestRoad;
                        _profileWaypoint = [_position, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                        _transportProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_transportProfile") then {
                            [_transportProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                        };


                    } forEach _eventTransportProfiles;

                    // set state to wait for return of transports
                    [_event, "state", "transportReturnWait"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                }else{

                    // no transport vehicles
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            case "transportReturnWait";
            case "heliTransportReturnWait": {
                // unloading complete
                // if profiles are active move on
                // to return to insertion point
                // if not active destroy transport profiles
                private ["_anyActive","_anyAlive","_transportProfile","_active","_inCommand","_commandProfileID","_commandProfile","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if (_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if (count _eventTransportProfiles > 0) then {
                    _anyActive = 0;
                    _anyAlive = 0;

                    // mechanism for aborting this state
                    // once set time limit has passed
                    // if all units haven't reached objective
                    _waitTotalIterations = 40;
                    _waitIterations = 0;

                    if (count _eventStateData > 0) then {
                        _waitIterations = _eventStateData select 0;
                    };

                    // once transport vehicles are inactive
                    // dispose of the profiles
                    {
                        _transportProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if !(isNil "_transportProfile") then {
                            _active = _transportProfile select 2 select 1;
                            _vehicle = _transportProfile select 2 select 10;

                            if (_eventState == "heliTransportReturnWait") then {
                                if ([position _vehicle, 1000] call ALiVE_fnc_anyPlayersInRange == 0 || _waitIterations > _waitTotalIterations) then {
                                    _active = false;
                                };
                            };

                            if (_active) then {
                                if (canMove _vehicle) then {
                                    _anyAlive = _anyAlive + 1;
                                };

                                _anyActive = _anyActive + 1;
                            } else {
                                // if not active dispose of transport profiles
                                _inCommand = _transportProfile select 2 select 8;

                                if (count _inCommand > 0) then {
                                    _commandProfileID = _inCommand select 0;
                                    _commandProfile = [ALIVE_profileHandler, "getProfile", _commandProfileID] call ALIVE_fnc_profileHandler;

                                    if !(isNil "_commandProfile") then {
                                        [_commandProfile, "destroy"] call ALIVE_fnc_profileEntity;
                                    };
                                };

                                [_transportProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                            };
                        };
                    } forEach _eventTransportVehiclesProfiles;

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if (_anyActive == 0 || _anyAlive == 0 || _waitIterations > _waitTotalIterations) then {
                        // no transport vehicles
                        // set state to event complete
                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    };
                } else {
                    // no transport vehicles
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };
            };

            case "eventComplete": {

                private["_sideObject","_factionName","_forcePool","_message","_radioBroadcast","_debug"];

                _debug = [_logic, "debug"] call MAINCLASS;

                [_logic, "setEventProfilesAvailable", _event] call MAINCLASS;

				// Moved behind debug per request #348
				if (_debug) then {

	                // send radio broadcast
	                _sideObject = [_eventSide] call ALIVE_fnc_sideTextToObject;
	                _factionName = getText((_eventFaction call ALiVE_fnc_configGetFactionClass) >> "displayName");
	                _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;

                    private _HQ = switch (_sideObject) do {
                        case WEST: {
                            "BLU"
                        };
                        case EAST: {
                            "OPF"
                        };
                        case RESISTANCE: {
                            "IND"
                        };
                        default {
                            "HQ"
                        };
                    };
	                // send a message to all side players from HQ
	                _message = format["%1 reinforcements have arrived. Available reinforcement level: %2",_factionName,_forcePool];
	                _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_HQ];
	                [_eventSide,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                };

                // remove the event
                [_logic, "removeEvent", _eventID] call MAINCLASS;

            };

            // PLAYER REQUEST ---------------------------------------------------------------------------------------------------------------------------------

            // the units have been requested by a player
            // spawn the units at the insertion point
            case "playerRequested": {

                private ["_waitTime"];

                // according to the type of reinforcement
                // adjust wait time for creation of profiles

                switch(_reinforcementType) do {
                    case "AIR": {
                        _waitTime = WAIT_TIME_AIR;
                    };
                    case "HELI": {
                        _waitTime = WAIT_TIME_HELI;
                    };
                    case "MARINE": {
                        _waitTime = WAIT_TIME_MARINE;
                    };
                    case "DROP": {
                        _waitTime = WAIT_TIME_DROP;
                    };
                };


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALIVE ML - Event state: %1 event timer: %2 wait time on event: %3 ",_eventState, (time - _eventTime), _waitTime] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // if the reinforcement objective is
                // not available, cancel the event
                if(_reinforcementAvailable) then {

                    if((time - _eventTime) > _waitTime) then {

                        private ["_reinforcementPosition","_playersInRange","_paraDrop","_remotePosition","_totalCount"];

                        if(_eventType == "PR_STANDARD" || _eventType == "PR_HELI_INSERT") then {

                            _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;

                        }else{
                            _reinforcementPosition = _eventPosition;
                        };

                        // players near check

                        _playersInRange = [_reinforcementPosition, 350] call ALiVE_fnc_anyPlayersInRange;

                        // if players are in visible range
                        // para drop groups instead of
                        // spawning on the ground

                        _paraDrop = false;
                        if(_playersInRange > 0) then {
                            _paraDrop = true;
                            // remote position should probably be spawn range - risk of heli getting shot down though too...
                            _remotePosition = [_reinforcementPosition, 1600] call ALIVE_fnc_getPositionDistancePlayers;
                        }else{
                            _remotePosition = _reinforcementPosition;
                        };

                        // wait time complete create profiles
                        // get groups according to requested force makeup

                        _totalCount = 0;


                        private ["_position","_profiles","_profileID","_profileIDs","_emptyVehicleProfiles","_itemCategory","_infantryProfiles","_armourProfiles",
                        "_mechanisedProfiles","_motorisedProfiles","_heliProfiles","_planeProfiles","_itemClass"];

                        _infantryProfiles = [];
                        _mechanisedProfiles = [];
                        _motorisedProfiles = [];
                        _armourProfiles = [];
                        _heliProfiles = [];
                        _planeProfiles = [];
                        _marineProfiles = [];
                        _specOpsProfiles = [];

                        _payloadGroupProfiles = [];

                        // empty vehicles

                        _emptyVehicleProfiles = [];

                        {
                            _itemClass = _x select 0;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if!(surfaceIsWater _position) then {

                                _itemCategory = _x select 1 select 1;

                                switch(_itemCategory) do {
                                    case "Car":{
                                        if(_paraDrop) then {
                                            _position set [2,PARADROP_HEIGHT];
                                        };
                                    };
                                    case "Armored":{
                                        if(_paraDrop) then {
                                            _position set [2,PARADROP_HEIGHT];
                                        };
                                    };
                                    case "Ship":{
                                        if(_paraDrop) then {
                                            _position set [2,PARADROP_HEIGHT];
                                        } else {
                                            // Find the nearest bit of water
                                            _position = [_position, true] call ALIVE_fnc_getClosestSea;
                                        };
                                    };
                                    case "Air":{
                                        _position = _remotePosition getPos [random(200), random(360)];
                                        _position set [2,1000];
                                    };
                                };

                                if(_eventType == "PR_AIRDROP" || (_eventType == "PR_HELI_INSERT" && _itemCategory != "Air")) then {

                                    if (_paraDrop && _eventType == "PR_HELI_INSERT") then {
                                        _position = _remotePosition getPos [random(200), random(360)];
                                        _position set [2,0]; // position might be in water :(
                                    } else {
                                        _position = _reinforcementPosition getPos [random(200), random(360)];
                                    };

                                    TRACE_2(">>>>>>>>>>>>>>>>>>>>>>>>",_itemClass, _position);

                                    _profiles = [_itemClass,_side,_eventFaction,_position] call ALIVE_fnc_createProfileVehicle;
                                    _profiles = [_profiles];
                                    // Once spawned, prevent despawn while being slung
                                    _profile = _profiles select 0;
                                    [_profile, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;

                                }else{
                                    _profiles = [_itemClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;
                                };

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _emptyVehicleProfiles pushback _profileIDs;

                                switch(_itemCategory) do {
                                    case "Car":{
                                        _motorisedProfiles pushback _profileIDs;
                                    };
                                    case "Armored":{
                                        _armourProfiles pushback _profileIDs;
                                    };
                                    case "Ship":{
                                        _marineProfiles pushback _profileIDs;
                                    };
                                    case "Air":{
                                        _heliProfiles pushback _profileIDs;

                                        _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        _profile = _profiles select 0;
                                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                    };
                                };

                                _totalCount = _totalCount + 1;

                            };

                        } forEach _emptyVehicles;

                        // set up slingload for empty vehicles
                        if(_eventType == "PR_HELI_INSERT" && {_x select 1 select 1 != "Air"} count _emptyVehicles > 0) then {

                            // create heli transport vehicles for the empty vehicles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                // For each empty vehicle - create a heli to carry it
                                {
                                    private ["_currentDiff","_vehicleClass","_position","_payloadWeight","_slingLoadProfile"];

                                    if (_paraDrop) then {
                                        _position = _remotePosition getPos [random(200), random(360)];
                                    } else {
                                        _position = _reinforcementPosition getPos [random(200), random(360)];
                                    };

                                    // Get the profile
                                    _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", (_x select 0)] call ALIVE_fnc_profileHandler;

                                    // _slingloadProfile call ALIVE_fnc_inspectHash;

                                    _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;

                                    // Select helicopter that can slingload the vehicle
                                    _vehicleClass = "";
                                    _currentDiff = 15000;
                                    {
                                        private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                        _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;

                                        if!(isNil "_slingloadmax") then {
                                        	_slingDiff = _slingloadmax - _payloadWeight;

                                        	if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x;};
                                        };
                                    } foreach _transportGroups;

                                    // Cannot find vehicle big enough to slingload...
                                    if (_vehicleClass == "") exitWith {_totalCount = _totalCount - 1;};

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    // Create slingloading heli (slingloading another profile!)
                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [[_x select 0], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    // Set slingloaded profile
                                    [_slingloadProfile,"slung",[[_profiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                    _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                    _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _payloadGroupProfiles pushback _profileIDs;

                                    _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    _profile = _profiles select 0;
                                    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                    _totalCount = _totalCount + 1;

                                } foreach _emptyVehicleProfiles;

                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };


                        // static individuals

                        private ["_staticIndividualProfiles","_unitClasses"];

                        _staticIndividualProfiles = [];

                        if(count _staticIndividuals > 0) then {

                            _staticIndividualProfiles = [];

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                if(_eventType == "PR_HELI_INSERT") then {
                                    _position = _remotePosition;
                                }else{
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            _unitClasses = [];
                            {
                                _unitClasses pushback (_x select 0);
                            } forEach _staticIndividuals;

                            _profile = [_unitClasses,_side,_eventFaction,_position,0,_side,true] call ALIVE_fnc_createProfileEntity;
                            _profileID = _profile select 2 select 4;
                            _staticIndividualProfiles pushback [_profileID];
                            _infantryProfiles pushback [_profileID];

                            _totalCount = _totalCount + 1;

                        };


                        // join individuals

                        private ["_joinIndividualProfiles"];

                        _joinIndividualProfiles = [];

                        if(count _joinIndividuals > 0) then {

                            _joinIndividualProfiles = [];

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                if(_eventType == "PR_HELI_INSERT") then {
                                    _position = _remotePosition;
                                }else{
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            _unitClasses = [];
                            {
                                _unitClasses pushback (_x select 0);
                            } forEach _joinIndividuals;

                            _profile = [_unitClasses,_side,_eventFaction,_position,0,_side,true] call ALIVE_fnc_createProfileEntity;
                            _profileID = _profile select 2 select 4;
                            _joinIndividualProfiles pushback [_profileID];
                            _infantryProfiles pushback [_profileID];

                            _totalCount = _totalCount + 1;

                        };

                        // reinforce individuals

                        private ["_reinforceIndividualProfiles"];

                        _reinforceIndividualProfiles = [];

                        if(count _reinforceIndividuals > 0) then {

                            _reinforceIndividualProfiles = [];

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                if(_eventType == "PR_HELI_INSERT") then {
                                    _position = _remotePosition;
                                }else{
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            _unitClasses = [];
                            {
                                _unitClasses pushback (_x select 0);
                            } forEach _reinforceIndividuals;

                            _profile = [_unitClasses,_side,_eventFaction,_position,0,_side,true] call ALIVE_fnc_createProfileEntity;
                            _profileID = _profile select 2 select 4;
                            _reinforceIndividualProfiles pushback [_profileID];
                            _infantryProfiles pushback [_profileID];

                            _totalCount = _totalCount + 1;

                        };

                        // Handle Groups - spawn inf and vehicles, slingload/paradrop vehicles if necessary

                        private _staticGroupProfiles = [];
                        private _joinGroupProfiles = [];
                        private _reinforceGroupProfiles = [];

                        {
                            private _profileList = _x select 0;
                            private _groupList = _x select 1;

                            {
                                private _group = _x select 0;
                                private _position = _reinforcementPosition getPos [random(200), random(360)];

                                if !(surfaceIsWater _position) then {
                                    private _groupFaction = (_x select 1) select 1;
                                    private _itemCategory = (_x select 1) select 2;

                                    // Handle other infantry groups such as Infantry_WDL
                                    if ([_itemCategory, "Infantry"] call CBA_fnc_find != -1) then {
                                        _itemCategory = "Infantry";
                                    };

                                    // Handle other Motorized groups such as Motorized_WDL
                                    if ([_itemCategory, "Motorized"] call CBA_fnc_find != -1) then {
                                        _itemCategory = "Motorized";
                                    };

                                    // RHS hacky stuff :(
                                    if !(_itemCategory in ["Infantry", "Support", "SpecOps", "Naval", "Armored", "Mechanized", "Motorized", "Air"]) then {
                                        private _key = format ["%1_%2", _groupFaction, _group];
                                        private _value = [ALIVE_groupConfig, _key] call CBA_fnc_hashGet;
                                        private _side = (_value select 1) select 0;
                                        private _faction = (_value select 1) select 1;
                                        private _category = (_value select 1) select 2;
                                        private _configPath = ((((configFile >> "CfgGroups") select _side) select _faction) select _category) >> "aliveCategory";

                                        if (isText _configPath) then {
                                            _itemCategory = getText _configPath;
                                        };
                                    };

                                    switch (_itemCategory) do {
                                        case "Naval": {
                                            if (_paraDrop) then {
                                                _position set [2, PARADROP_HEIGHT];
                                            } else {
                                                // Find the nearest bit of water
                                                _position = [_position, true] call ALIVE_fnc_getClosestSea;
                                            };
                                        };
                                        case "Air": {
                                            _position = _remotePosition getPos [random(200), random(360)];
                                            _position set [2,1000];
                                        };
                                        default {
                                            if (_eventType == "PR_HELI_INSERT") then {
                                                _position = _remotePosition;
                                            } else {
                                                if (_paraDrop) then {
                                                    _position set [2, PARADROP_HEIGHT];
                                                };
                                            };
                                        };
                                    };

                                    private _profiles = [_group, _position, random(360), false, _groupFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
                                    private _profileIDs = [];

                                    {
                                        private _profileID = (_x select 2) select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _profileList pushBack _profileIDs;

                                    switch(_itemCategory) do {
                                        case "Infantry":{
                                            _infantryProfiles pushback _profileIDs;
                                        };
                                        case "Support":{
                                            _infantryProfiles pushback _profileIDs;
                                        };
                                        case "SpecOps":{
                                            _specOpsProfiles pushback _profileIDs;
                                        };
                                        case "Naval":{
                                            _marineProfiles pushback _profileIDs;
                                        };
                                        case "Armored":{
                                            _armourProfiles pushback _profileIDs;
                                        };
                                        case "Mechanized":{
                                             _mechanisedProfiles pushback _profileIDs;
                                        };
                                        case "Motorized":{
                                             _motorisedProfiles pushback _profileIDs;
                                        };
                                        case "Air":{
                                            _heliProfiles pushback _profileIDs;

                                            _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                            _profile = _profiles select 0;
                                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                        };
                                    };

                                    _totalCount = _totalCount + 1;
                                };
                            } forEach _groupList;
                        } forEach [
                            [_staticGroupProfiles, _staticGroups],
                            [_joinGroupProfiles, _joinGroups],
                            [_reinforceGroupProfiles, _reinforceGroups]
                        ];

                        // Handle infantry

                        if(_eventType == "PR_STANDARD") then {

                            // create ground transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {
                                for "_i" from 0 to (count _infantryProfiles) -1 do {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if(count _transportGroups > 0) then {

                                        _vehicleClass = selectRandom _transportGroups;

                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,false,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    }

                                };
                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };

                        if(_eventType == "PR_HELI_INSERT") then {

                            private ["_infantryProfileID","_infantryProfile","_profileWaypoint","_profile"];

                            // create air transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                for "_i" from 0 to (count _infantryProfiles) -1 do {

                                    if (_paraDrop) then {
                                        _position = _remotePosition getPos [random(200), random(360)];
                                    } else {
                                        _position = _reinforcementPosition getPos [random(200), random(360)];
                                    };

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if(count _transportGroups > 0) then {

                                        // Select helicopter that can carry most troops
                                        private "_heliTransport";
                                        _heliTransport = 2;
                                        _vehicleClass = _transportGroups select 0;
                                        {
                                            private ["_transport"];
                                            _transport = [(configFile >> "CfgVehicles" >> _x >> "transportSoldier")] call ALiVE_fnc_getConfigValue;
                                            if (_transport > _heliTransport) then {_vehicleClass = _x};
                                        } foreach _transportGroups;

                                        // Create profiles
                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                        _infantryProfileID = _infantryProfiles select _i select 0;
                                        if!(isNil "_infantryProfileID") then {
                                            _infantryProfile = [ALIVE_profileHandler, "getProfile", _infantryProfileID] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_infantryProfile") then {
                                                [_infantryProfile,_profiles select 1] call ALIVE_fnc_createProfileVehicleAssignment;
                                            };
                                        };

                                        _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        _profile = _profiles select 0;
                                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                    };

                                };

                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };

                        // Handle Groups
                        // set up slingload for groups with vehicles

                        _groupProfiles = _joinGroupProfiles + _reinforceGroupProfiles + _staticGroupProfiles;

                        if(_eventType == "PR_HELI_INSERT" && (count _groupProfiles > 0)) then {

                            // create heli transport vehicles for groups with vehicles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                // For each group - create helis to carry their vehicles

                                {
                                    _groupProfile = _x;

                                    {
                                        private ["_currentDiff","_vehicleClass","_position","_payloadWeight","_slingLoadProfile"];

                                        // Check to see if profile is a vehicle
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {

                                            if (_paraDrop) then {
                                                _position = _remotePosition getPos [random(200), random(360)];
                                            } else {
                                                _position = _reinforcementPosition getPos [random(200), random(360)];
                                            };

                                            // Get the profile
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                                            // _slingloadProfile call ALIVE_fnc_inspectHash;

                                            _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;

                                            // Select helicopter that can slingload the vehicle
                                            _vehicleClass = "";
                                            _currentDiff = 15000;
                                            {
                                                private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                                _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;

												if (!isnil "_slingloadmax") then {
                                                	_slingDiff = _slingloadmax - _payloadWeight;

                                                	if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x;};
												};
                                            } foreach _transportGroups;

                                            // Cannot find vehicle big enough to slingload...
                                            if (_vehicleClass == "") exitWith {_totalCount = _totalCount - 1;};

                                            _position set [2,PARADROP_HEIGHT];

                                            // Create slingloading heli (slingloading another profile!)
                                            _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [[_x], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                            ["HELI PROFILE FOR SLINGLOADING: %1",_profiles select 1 select 2 select 4] call ALiVE_fnc_dump;
                                            // Set slingloaded profile
                                            [_slingloadProfile,"slung",[[_profiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                            _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                            _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                            _profileIDs = [];
                                            {
                                                _profileID = _x select 2 select 4;
                                                _profileIDs pushback _profileID;
                                            } forEach _profiles;

                                            _payloadGroupProfiles pushback _profileIDs;

                                            _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                            _profile = _profiles select 0;
                                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                            _totalCount = _totalCount + 1;
                                        };

                                    } foreach _groupProfile;

                                } foreach _groupProfiles;

                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };

                        // Handle payload

                        // spawn vehicles to fit the requested
                        // payload items in

                        private ["_payloadGroupProfiles","_transportGroups","_transportProfiles","_transportVehicleProfiles","_vehicleClass","_vehicle","_itemClass",
                        "_itemWeight","_payloadWeight","_payloadcount","_payloadSize","_payloadMaxSize"];

                        if(count _payload > 0) then {

                            _payloadWeight = 0;
                            _payloadSize = 0;
                            _payloadMaxSize = 0;
                            {
                                _itemWeight = [_x] call ALIVE_fnc_getObjectWeight;
                                _payloadWeight = _payloadWeight + _itemWeight;
                                _itemSize = [_x] call ALIVE_fnc_getObjectSize;
                                _payloadSize = _payloadSize + _itemSize;
                                if (_itemSize > _payloadMaxSize) then {_payloadMaxSize = _itemSize;};
                            } forEach _payload;

                            _payloadcount = floor(_payloadWeight / 2000);
                            if(_payloadcount <= 0) then {
                                _payloadcount = 1;
                            };
                            _totalCount = _totalCount + _payloadcount;

                            if(_eventType == "PR_STANDARD") then {

                                // create ground transport vehicles for the payload

                                _transportGroups = [ALIVE_factionDefaultTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                                _transportProfiles = [];
                                _transportVehicleProfiles = [];

                                if(count _transportGroups == 0) then {
                                    _transportGroups = [ALIVE_sideDefaultTransport,_side] call ALIVE_fnc_hashGet;
                                };

                                if(count _transportGroups > 0) then {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    _vehicleClass = selectRandom _transportGroups;

                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,false,true,_payload] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                    _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _payloadGroupProfiles pushback _profileIDs;

                                };

                                _totalCount = _totalCount + 1;

                                _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                            };

                            if(_eventType == "PR_HELI_INSERT") then {

                                // If payload weight is greater than maximumLoad, then items are put in a container and slingloaded.

                                // create heli transport vehicles for the payload

                                _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                                _transportProfiles = [];
                                _transportVehicleProfiles = [];

                                if(count _transportGroups == 0) then {
                                    _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                                };

                                if(count _transportGroups > 0) then {
                                    private ["_slingload","_currentDiff"];

                                    if (_paraDrop) then {
                                        _position = _remotePosition getPos [random(200), random(360)];
                                    } else {
                                        _position = _reinforcementPosition getPos [random(200), random(360)];
                                    };

                                    // Select helicopter that can carry enough for payload
                                    _vehicleClass = _transportGroups select 0;
                                    _slingload = false;
                                    _currentDiff = 15000;
                                    {
                                        private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                        _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;
                                        _maxLoad = [(configFile >> "CfgVehicles" >> _x >> "maximumLoad")] call ALiVE_fnc_getConfigValue;

                                        if (!isNil "_slingloadmax" && {!isNil "_maxLoad"}) then {
	                                        _slingDiff = _slingloadmax - _payloadWeight;
	                                        _loadDiff = _maxLoad - _payloadWeight;

	                                        if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x; _slingload = true;};
	                                        if ((_loadDiff <= _currentDiff) && (_loadDiff > 0)) then {_currentDiff = _loadDiff; _vehicleClass = _x; _slingload = false;};
                                        };
                                    } foreach _transportGroups;

                                    // If total size > vehicle size then force slingload if available
                                    if ( (_payloadSize > [(configFile >> "CfgVehicles" >> _vehicleClass >> "mapSize")] call ALiVE_fnc_getConfigValue) && ([(configFile >> "CfgVehicles" >> _vehicleClass >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue > 0)) then {
                                        _slingload = true;
                                    };


                                    _position set [2,PARADROP_HEIGHT];


                                    if (!_slingload) then {
                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,_payload] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    } else {

                                        // Do slingloading
                                        private ["_containers","_containerClass","_container"];

                                        LOG("RESUPPLY WILL BE SLINGLOADING");

                                        // Get a suitable container
                                        _containers = [ALIVE_factionDefaultContainers,_eventFaction,[]] call ALIVE_fnc_hashGet;

                                        if(count _containers == 0) then {
                                            _containers = [ALIVE_sideDefaultContainers,_side] call ALIVE_fnc_hashGet;
                                        };

                                        if(count _containers > 0) then {
                                            private ["_tempContainer","_tempContainerSize"];
                                            if (_paraDrop) then {
                                                _position = _remotePosition getPos [random(200), random(360)];
                                            } else {
                                                _position = _reinforcementPosition getPos [random(200), random(360)];
                                            };

                                            // Choose a good sized container
                                            _containerClass = _containers select 0;

                                            // Find a container big enough and the helicopter can slingload
                                            _tempContainer = _containerClass;
                                            _tempContainerSize = [(configFile >> "CfgVehicles" >> _containerClass >> "mapSize")] call ALiVE_fnc_getConfigValue;
                                            {
                                                private ["_containerSize","_heliCanSling"];
                                                _containerSize = [(configFile >> "CfgVehicles" >> _x >> "mapSize")] call ALiVE_fnc_getConfigValue;

                                                // Work around for cargo container that is 7500kg
                                                _heliCanSling = if ([(configFile >> "CfgVehicles" >> _vehicleClass >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue < 7500 && _x == "B_Slingload_01_Cargo_F") then {false;}else{true;};

                                                if (_containerSize > _tempContainerSize && _heliCanSling) then {_tempContainer = _x; _tempContainerSize = _containerSize;};

                                                TRACE_3("RESUPPLY", _payloadMaxSize, _containerSize, _x);

                                                if ((_containerSize * 2) > _payloadMaxSize && _heliCanSling) exitWith {_containerClass = _x;};
                                            } foreach _containers;

                                            // If no container is big enough, then just use biggest
                                            if (_tempContainerSize > [(configFile >> "CfgVehicles" >> _containerClass >> "mapSize")] call ALiVE_fnc_getConfigValue) then {
                                                _containerClass = _tempContainer;
                                            };

                                            // Create slingloading heli
                                            _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [_containerClass, _payload]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        };
                                    };

                                    _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                    _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _payloadGroupProfiles pushback _profileIDs;

                                    _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    _profile = _profiles select 0;
                                    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                };

                                _totalCount = _totalCount + 1;

                                _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                            };

                            private ["_containers","_vehicle","_parachute","_soundFlyover"];

                            if(_eventType == "PR_AIRDROP") then {

                                _containers = [ALIVE_factionDefaultContainers,_eventFaction,[]] call ALIVE_fnc_hashGet;

                                if(count _containers == 0) then {
                                    _containers = [ALIVE_sideDefaultContainers,_side] call ALIVE_fnc_hashGet;
                                };

                                if(count _containers > 0) then {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    _vehicleClass = selectRandom _containers;

                                    //_profile = [_vehicleClass,_side,_eventFaction,_position,random(360),false,_eventFaction,_payload] call ALIVE_fnc_createProfileVehicle;

                                    _vehicle = createVehicle [_vehicleClass, _position, [], 0, "NONE"];

                                    clearItemCargoGlobal _vehicle;
                                    clearMagazineCargoGlobal _vehicle;
                                    clearWeaponCargoGlobal _vehicle;

                                    [ALiVE_SYS_LOGISTICS,"fillContainer",[_vehicle,_payload]] call ALiVE_fnc_Logistics;

                                    if(_paraDrop) then {
                                        _parachute = createvehicle ["B_Parachute_02_F",position _vehicle ,[],0,"none"];
                                        _vehicle attachto [_parachute,[0,0,(abs ((boundingbox _vehicle select 0) select 2))]];

                                        _parachute setpos position _vehicle;
                                        _parachute setdir direction _vehicle;
                                        _parachute setvelocity [0,0,-1];

                                        if (time - (missionnamespace getvariable ["bis_fnc_curatorobjectedited_paraSoundTime",0]) > 0) then {
                                            _soundFlyover = selectRandom ["BattlefieldJet1","BattlefieldJet2"];
                                            [_parachute,_soundFlyover,"say3d"] remoteExec ["bis_fnc_sayMessage"];
                                            missionnamespace setvariable ["bis_fnc_curatorobjectedited_paraSoundTime",time + 10]
                                        };

                                        [_vehicle,_parachute] spawn {
                                            _vehicle = _this select 0;
                                            _parachute = _this select 1;

                                            waituntil {isnull _parachute || isnull _vehicle};
                                            _vehicle setdir direction _vehicle;
                                            deletevehicle _parachute;

                                            [_vehicle] call ALIVE_fnc_MLAttachSmokeOrStrobe;
                                        };
                                    };

                                };

                                _totalCount = _totalCount + 1;
                            };

                        };


                        [_playerRequestProfiles,"empty",_emptyVehicleProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"joinIndividuals",_joinIndividualProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"staticIndividuals",_staticIndividualProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"reinforceIndividuals",_reinforceIndividualProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"joinGroups",_joinGroupProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"staticGroups",_staticGroupProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"reinforceGroups",_reinforceGroupProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"payloadGroups",_payloadGroupProfiles] call ALIVE_fnc_hashSet;
                        [_event, "playerRequestProfiles", _playerRequestProfiles] call ALIVE_fnc_hashSet;


                        [_eventCargoProfiles, "armour", _armourProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "infantry", _infantryProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "mechanised", _mechanisedProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "motorised", _motorisedProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "heli", _heliProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "plane", _planeProfiles] call ALIVE_fnc_hashSet;


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ALIVE ML - Profiles created: %1 ",_totalCount] call ALIVE_fnc_dump;
                            switch(_eventType) do {
                                case "PR_STANDARD": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"PR CONVOY START"]] call MAINCLASS;
                                };
                                case "PR_HELI_INSERT": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"PR AIR INSERTION"]] call MAINCLASS;
                                };
                                case "PR_AIRDROP": {
                                    [_logic, "createMarker", [_eventPosition,_eventFaction,"PR AIRDROP"]] call MAINCLASS;
                                };
                            };
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        if(_totalCount > 0) then {

                            // remove the created group count
                            // from the force pool
                            _forcePool = _forcePool - _totalCount;
                            // update the global force pool
                            [ALIVE_MLGlobalRegistry,"updateGlobalForcePool",[_registryID,_forcePool]] call ALIVE_fnc_MLGlobalRegistry;

                            switch(_eventType) do {
                                case "PR_STANDARD": {

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "transportLoad"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "PR_HELI_INSERT": {

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "heliTransportStart"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "PR_AIRDROP": {

                                    // update the state of the event
                                    // next state is aridrop wait
                                    [_event, "state", "airdropWait"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                            };

                            [_event, "cargoProfiles", _eventCargoProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportProfiles", _eventTransportProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportVehiclesProfiles", _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;

                            [_logic, "prepareUnitCounts", _event] call MAINCLASS;

                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                            // respond to player request
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_INSERTION"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                        }else{

                            // respond to player request
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_FORCE_CREATION"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                            // no profiles were created
                            // nothing to do so cancel..
                            [_logic, "removeEvent", _eventID] call MAINCLASS;
                        };

                    };
                }else{

                    // no insertion point available
                    // nothing to do so cancel..
                    [_logic, "removeEvent", _eventID] call MAINCLASS;

                    // respond to player request
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_NOT_AVAILABLE"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                };
            };
        };
    };

    case "prepareUnitCounts": {

        private ["_event","_debug","_eventID","_eventData","_eventCargoProfiles",
        "_eventTransportProfiles","_eventTransportVehiclesProfiles","_playerRequested","_playerRequestProfiles","_eventForceMakeup",
        "_infantryProfiles","_armourProfiles","_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles",
        "_playerID","_requestID","_emptyProfiles","_joinIndividualProfiles","_staticIndividualProfiles","_reinforceIndividualProfiles",
        "_joinGroupProfiles","_staticGroupProfiles","_reinforceGroupProfiles","_payloadGroupProfiles","_profiles","_profile","_unitCounts"];

        _event = _args;

        _debug = [_logic, "debug"] call MAINCLASS;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        _unitCounts = [] call ALIVE_fnc_hashCreate;


        _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        [_unitCounts,"transport",count _eventTransportProfiles] call ALIVE_fnc_hashSet;

        _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        [_unitCounts,"transportVehicle",count _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;


        _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
        [_unitCounts,"infantry",count _infantryProfiles] call ALIVE_fnc_hashSet;


        _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
        [_unitCounts,"armour",count _armourProfiles] call ALIVE_fnc_hashSet;


        _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
        [_unitCounts,"mechanised",count _mechanisedProfiles] call ALIVE_fnc_hashSet;


        _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
        [_unitCounts,"motorised",count _motorisedProfiles] call ALIVE_fnc_hashSet;


        _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
        [_unitCounts,"plane",count _planeProfiles] call ALIVE_fnc_hashSet;


        _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;
        [_unitCounts,"heli",count _heliProfiles] call ALIVE_fnc_hashSet;


        if(_playerRequested) then {

            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            [_unitCounts,"empty",count _emptyProfiles] call ALIVE_fnc_hashSet;


            _joinIndividualProfiles = [_playerRequestProfiles,"joinIndividuals"] call ALIVE_fnc_hashGet;
            [_unitCounts,"joinIndividuals",count _joinIndividualProfiles] call ALIVE_fnc_hashSet;


            _staticIndividualProfiles = [_playerRequestProfiles,"staticIndividuals"] call ALIVE_fnc_hashGet;
            [_unitCounts,"staticIndividuals",count _staticIndividualProfiles] call ALIVE_fnc_hashSet;


            _reinforceIndividualProfiles = [_playerRequestProfiles,"reinforceIndividuals"] call ALIVE_fnc_hashGet;
            [_unitCounts,"reinforceIndividuals",count _reinforceIndividualProfiles] call ALIVE_fnc_hashSet;


            _joinGroupProfiles = [_playerRequestProfiles,"joinGroups"] call ALIVE_fnc_hashGet;
            [_unitCounts,"joinGroups",count _joinGroupProfiles] call ALIVE_fnc_hashSet;


            _staticGroupProfiles = [_playerRequestProfiles,"staticGroups"] call ALIVE_fnc_hashGet;
            [_unitCounts,"staticGroups",count _staticGroupProfiles] call ALIVE_fnc_hashSet;


            _reinforceGroupProfiles = [_playerRequestProfiles,"reinforceGroups"] call ALIVE_fnc_hashGet;
            [_unitCounts,"reinforceGroups",count _reinforceGroupProfiles] call ALIVE_fnc_hashSet;


            _payloadGroupProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;
            [_unitCounts,"payloadGroups",count _payloadGroupProfiles] call ALIVE_fnc_hashSet;

        };

        [_event, "initialUnitCounts", _unitCounts] call ALIVE_fnc_hashSet;
    };

    case "checkEvent": {

        private ["_event","_debug","_eventID","_eventData","_eventCargoProfiles",
        "_eventTransportProfiles","_eventTransportVehiclesProfiles","_playerRequested","_playerRequestProfiles","_eventForceMakeup",
        "_infantryProfiles","_armourProfiles","_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles",
        "_playerID","_requestID","_emptyProfiles","_joinIndividualProfiles","_staticIndividualProfiles","_reinforceIndividualProfiles",
        "_joinGroupProfiles","_staticGroupProfiles","_reinforceGroupProfiles","_payloadGroupProfiles","_profiles","_profile","_totalCount","_unitCounts"];

        _event = _args;

        _debug = [_logic, "debug"] call MAINCLASS;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;
        _eventForceMakeup = _eventData select 3;
        _totalCount = 0;

        _unitCounts = [] call ALIVE_fnc_hashCreate;


        _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportProfiles = [_logic, "removeUnregisteredProfiles", _eventTransportProfiles] call MAINCLASS;
        [_unitCounts,"transport",count _eventTransportProfiles] call ALIVE_fnc_hashSet;
        [_event, "transportProfiles", _eventTransportProfiles] call ALIVE_fnc_hashSet;

        _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportVehiclesProfiles = [_logic, "removeUnregisteredProfiles", _eventTransportVehiclesProfiles] call MAINCLASS;
        [_unitCounts,"transportVehicle",count _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;
        [_event, "transportVehiclesProfiles", _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;


        _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
        {
            _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
            _infantryProfiles set [_forEachIndex,_x];
        } forEach _infantryProfiles;
        _totalCount = _totalCount + (count _infantryProfiles);
        [_unitCounts,"infantry",count _infantryProfiles] call ALIVE_fnc_hashSet;
        [_eventCargoProfiles, 'infantry', _infantryProfiles] call ALIVE_fnc_hashSet;


        _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
        {
            _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
            _armourProfiles set [_forEachIndex,_x];
        } forEach _armourProfiles;
        _totalCount = _totalCount + (count _armourProfiles);
        [_unitCounts,"armour",count _armourProfiles] call ALIVE_fnc_hashSet;
        [_eventCargoProfiles, 'armour', _armourProfiles] call ALIVE_fnc_hashSet;


        _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
        {
            _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
            _mechanisedProfiles set [_forEachIndex,_x];
        } forEach _mechanisedProfiles;
        _totalCount = _totalCount + (count _mechanisedProfiles);
        [_unitCounts,"mechanised",count _mechanisedProfiles] call ALIVE_fnc_hashSet;
        [_eventCargoProfiles, 'mechanised', _mechanisedProfiles] call ALIVE_fnc_hashSet;


        _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
        {
            _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
            _motorisedProfiles set [_forEachIndex,_x];
        } forEach _motorisedProfiles;
        _totalCount = _totalCount + (count _motorisedProfiles);
        [_unitCounts,"motorised",count _motorisedProfiles] call ALIVE_fnc_hashSet;
        [_eventCargoProfiles, 'motorised', _motorisedProfiles] call ALIVE_fnc_hashSet;


        _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
        {
            _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
            _planeProfiles set [_forEachIndex,_x];
        } forEach _planeProfiles;
        _totalCount = _totalCount + (count _planeProfiles);
        [_unitCounts,"plane",count _planeProfiles] call ALIVE_fnc_hashSet;
        [_eventCargoProfiles, 'plane', _planeProfiles] call ALIVE_fnc_hashSet;


        _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;
        {
            _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
            _heliProfiles set [_forEachIndex,_x];
        } forEach _heliProfiles;
        _totalCount = _totalCount + (count _heliProfiles);
        [_unitCounts,"heli",count _heliProfiles] call ALIVE_fnc_hashSet;
        [_eventCargoProfiles, 'heli', _heliProfiles] call ALIVE_fnc_hashSet;


        if(_playerRequested) then {
            _playerID = _eventData select 5;
            _requestID = _eventForceMakeup select 0;

            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _emptyProfiles set [_forEachIndex,_x];
            } forEach _emptyProfiles;
            _totalCount = _totalCount + (count _emptyProfiles);
            [_unitCounts,"empty",count _emptyProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'empty', _emptyProfiles] call ALIVE_fnc_hashSet;


            _joinIndividualProfiles = [_playerRequestProfiles,"joinIndividuals"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _joinIndividualProfiles set [_forEachIndex,_x];
            } forEach _joinIndividualProfiles;
            _totalCount = _totalCount + (count _joinIndividualProfiles);
            [_unitCounts,"joinIndividuals",count _joinIndividualProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'joinIndividuals', _joinIndividualProfiles] call ALIVE_fnc_hashSet;


            _staticIndividualProfiles = [_playerRequestProfiles,"staticIndividuals"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _staticIndividualProfiles set [_forEachIndex,_x];
            } forEach _staticIndividualProfiles;
            _totalCount = _totalCount + (count _staticIndividualProfiles);
            [_unitCounts,"staticIndividuals",count _staticIndividualProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'staticIndividuals', _staticIndividualProfiles] call ALIVE_fnc_hashSet;


            _reinforceIndividualProfiles = [_playerRequestProfiles,"reinforceIndividuals"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _reinforceIndividualProfiles set [_forEachIndex,_x];
            } forEach _reinforceIndividualProfiles;
            _totalCount = _totalCount + (count _reinforceIndividualProfiles);
            [_unitCounts,"reinforceIndividuals",count _reinforceIndividualProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'reinforceIndividuals', _reinforceIndividualProfiles] call ALIVE_fnc_hashSet;


            _joinGroupProfiles = [_playerRequestProfiles,"joinGroups"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _joinGroupProfiles set [_forEachIndex,_x];
            } forEach _joinGroupProfiles;
            _totalCount = _totalCount + (count _joinGroupProfiles);
            [_unitCounts,"joinGroups",count _joinGroupProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'joinGroups', _joinGroupProfiles] call ALIVE_fnc_hashSet;


            _staticGroupProfiles = [_playerRequestProfiles,"staticGroups"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _staticGroupProfiles set [_forEachIndex,_x];
            } forEach _staticGroupProfiles;
            _totalCount = _totalCount + (count _staticGroupProfiles);
            [_unitCounts,"staticGroups",count _staticGroupProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'staticGroups', _staticGroupProfiles] call ALIVE_fnc_hashSet;


            _reinforceGroupProfiles = [_playerRequestProfiles,"reinforceGroups"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _reinforceGroupProfiles set [_forEachIndex,_x];
            } forEach _reinforceGroupProfiles;
            _totalCount = _totalCount + (count _reinforceGroupProfiles);
            [_unitCounts,"reinforceGroups",count _reinforceGroupProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'reinforceGroups', _reinforceGroupProfiles] call ALIVE_fnc_hashSet;


            _payloadGroupProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;
            {
                _x = [_logic, "removeUnregisteredProfiles", _x] call MAINCLASS;
                _payloadGroupProfiles set [_forEachIndex,_x];
            } forEach _payloadGroupProfiles;
            _totalCount = _totalCount + (count _payloadGroupProfiles);
            [_unitCounts,"payloadGroups",count _payloadGroupProfiles] call ALIVE_fnc_hashSet;
            [_playerRequestProfiles, 'payloadGroups', _payloadGroupProfiles] call ALIVE_fnc_hashSet;

        };

        [_event, "currentUnitCounts", _unitCounts] call ALIVE_fnc_hashSet;

        _result = _totalCount;

    };

    case "removeUnregisteredProfiles": {

        private ["_profiles","_profile"];

        _profiles = _args;

        {
            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
            if(isNil "_profile") then {
                _profiles set [_forEachIndex,"DELETE"];
            };

        } forEach _profiles;

        _profiles = _profiles - ["DELETE"];

        _result = _profiles;

    };

    case "checkWaypointCompleted": {

        private ["_entityProfile","_debug","_active","_profileID","_waypointCompleted"];

        _entityProfile = _args;

        _debug = [_logic, "debug"] call MAINCLASS;

        _active = _entityProfile select 2 select 1;
        _profileID = _entityProfile select 2 select 4;

        _waypointCompleted = false;

        if(_active) then {
            private ["_group","_leader","_currentPosition","_currentWaypoint","_waypoints","_waypointCount",
            "_destination","_completionRadius","_distance"];

            _group = _entityProfile select 2 select 13;

            if !(!isnil "_group" && {typeName _group == "GROUP"}) exitwith {_waypointCompleted = true};

            _leader = leader _group;
            _currentPosition = position _leader;
            _currentWaypoint = currentWaypoint _group;
            _waypoints = waypoints _group;

            if (count _waypoints == 0) exitWith {_waypointCompleted = true};

            _currentWaypoint = _waypoints select ((count _waypoints)-1);

            if!(isNil "_currentWaypoint") then {

                _destination = waypointPosition _currentWaypoint;
                _completionRadius = waypointCompletionRadius _currentWaypoint;

                _completionRadius = (_completionRadius * 2) + 20;

                _distance = _currentPosition distance _destination;

                if(_distance < _completionRadius) then {
                    _waypointCompleted = true;
                };

            }else{
                _waypointCompleted = true;
            }

        } else {
            private ["_waypoints"];

            _waypoints = [_entityProfile,"waypoints"] call ALIVE_fnc_hashGet;

            if!(isNil "_waypoints") then {
                if(count _waypoints == 0) then {
                    _waypointCompleted = true;
                };
            }else{
                _waypointCompleted = true;
            }
        };

        _result = _waypointCompleted;

    };

    case "setHelicopterTravel": {

        private ["_entityProfile","_debug","_active","_profileID","_waypointCompleted"];

        _entityProfile = _args;

        _debug = [_logic, "debug"] call MAINCLASS;

        _active = _entityProfile select 2 select 1;
        _profileID = _entityProfile select 2 select 4;

        if(_active) then {
            private ["_group","_units"];

            _group = _entityProfile select 2 select 13;

            _group setBehaviour "CARELESS";
            _group allowFleeing 0;
            _group setCombatMode "BLUE";

            {
                _x disableAI "AUTOTARGET";
                _x disableAI "TARGET";
                //_x disableAI "THREAT_PATH"; this does not exist and path would make the units not move at all
            } forEach (units _group);

        }else{
            [_entityProfile,"spawn"] call ALIVE_fnc_profileEntity;
        }

    };

    case "unloadTransport": {

        private ["_event","_entityProfile","_active","_profileID","_vehiclesInCommandOf","_debug","_eventID","_eventData","_eventCargoProfiles",
        "_eventTransportProfiles","_eventTransportVehiclesProfiles","_playerRequested","_playerRequestProfiles","_eventPosition",
        "_eventType","_playerID","_requestID","_type","_emptyProfiles","_payloadProfiles","_vehicleProfileID","_vehicleProfile","_eventForceMakeup"];

        _event = _args select 0;
        _entityProfile = _args select 1;

        _active = _entityProfile select 2 select 1;
        _profileID = _entityProfile select 2 select 4;
        _vehiclesInCommandOf = _entityProfile select 2 select 8;

        if(count _vehiclesInCommandOf == 0) exitWith { _result = false; };

        _vehicleProfileID = _vehiclesInCommandOf select 0;

        _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;

        if(isNil "_vehicleProfile") exitWith { _result = false; };

        _debug = [_logic, "debug"] call MAINCLASS;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        _eventForceMakeup = _eventData select 3;
        _eventPosition = _eventData select 0;
        _eventType = _eventData select 4;
        _type = "STANDARD";

        if(_playerRequested) then {
            _playerID = _eventData select 5;
            _requestID = _eventForceMakeup select 0;
            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            _payloadProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            {
                if(_profileID in _x) then {
                    _type = "EMPTY";
                };
            } forEach _emptyProfiles;

            {
                if(_profileID in _x) then {
                    _type = "PAYLOAD";
                };
            } forEach _payloadProfiles;

        };

        switch(_type) do {
            case "STANDARD":{

                if(_active) then {

                    private ["_group","_position","_heliPad","_inCargo","_cargoProfileID","_cargoProfile"];

                    _inCargo = _vehicleProfile select 2 select 9;

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            if!(isNil "_cargoProfile") then {
                                [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                            };

                        } forEach _inCargo;
                    };

                }else{

                    private ["_inCargo","_cargoProfileID","_cargoProfile","_position"];

                    _inCargo = _vehicleProfile select 2 select 9;

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            _position = _vehicleProfile select 2 select 2;
                            _position set [2,0];

                            if!(isNil "_cargoProfile") then {
                             [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                             [_cargoProfile,"position",_position] call ALIVE_fnc_profileEntity;
                            };

                        } forEach _inCargo;
                    };

                 };

            };
            case "EMPTY":{

                if!(_active) then {

                    private ["_group","_position","_heliPad"];

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                    _position = _vehicleProfile select 2 select 2;
                    _position set [2,0];
                    [_vehicleProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"hasSimulated",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"engineOn",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;

                    [_entityProfile, "destroy"] call ALIVE_fnc_profileEntity;
                    //[ALIVE_profileHandler, "unregisterProfile", _entityProfile] call ALIVE_fnc_profileHandler;


                }else{

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                };

            };
            case "PAYLOAD":{

                private ["_index","_heliPad"];

              /*  _index = _eventTransportProfiles find _profileID;
                _eventTransportProfiles set [_index,objNull];
                _eventTransportProfiles = _eventTransportProfiles - [objNull];
                [_event, "transportProfiles",_eventTransportProfiles] call ALIVE_fnc_hashSet;


                _index = _eventTransportVehiclesProfiles find _vehicleProfileID;
                _eventTransportVehiclesProfiles set [_index,objNull];
                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles - [objNull];
                [_event, "transportVehiclesProfiles",_eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet; */

            };
        };

    };

    case "unloadTransportHelicopter": {

        private ["_event","_entityProfile","_active","_profileID","_vehiclesInCommandOf","_debug","_eventID","_eventData","_eventCargoProfiles",
        "_eventTransportProfiles","_eventTransportVehiclesProfiles","_playerRequested","_playerRequestProfiles","_eventPosition",
        "_eventType","_playerID","_requestID","_type","_emptyProfiles","_payloadProfiles","_vehicleProfileID","_vehicleProfile","_eventForceMakeup","_eventAssets","_slingloading"];

        _event = _args select 0;
        _entityProfile = _args select 1;

        _active = _entityProfile select 2 select 1;
        _profileID = _entityProfile select 2 select 4;
        _vehiclesInCommandOf = _entityProfile select 2 select 8;

        if(count _vehiclesInCommandOf == 0) exitWith { _result = false; };

        _vehicleProfileID = _vehiclesInCommandOf select 0;

        _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;

        if(isNil "_vehicleProfile") exitWith { _result = false; };

        _debug = [_logic, "debug"] call MAINCLASS;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        _eventAssets = [_event, "eventAssets"] call ALIVE_fnc_hashGet;

        _eventForceMakeup = _eventData select 3;
        _eventPosition = _eventData select 0;
        _eventType = _eventData select 4;
        _type = "STANDARD";

        _slingloading = [_vehicleProfile, "slingloading", false] call ALiVE_fnc_hashGet;

        if(_playerRequested) then {
            _playerID = _eventData select 5;
            _requestID = _eventForceMakeup select 0;
            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            _payloadProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            {
                if(_profileID in _x) then {
                    _type = "EMPTY";
                };
            } forEach _emptyProfiles;

            {
                if(_profileID in _x) then {
                    _type = "PAYLOAD";
                };
            } forEach _payloadProfiles;

        };

        if(!_playerRequested && _slingLoading) then {
            _payloadProfiles = [_eventCargoProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            {
                if(_profileID in _x) then {
                    _type = "PAYLOAD";
                };
            } forEach _payloadProfiles;

        };

        switch(_type) do {
            case "STANDARD":{

                if(_active) then {

                    private ["_group","_position","_heliPad","_inCargo","_cargoProfileID","_cargoProfile"];

                    _group = _entityProfile select 2 select 13;
                    _group setBehaviour "CARELESS";

                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _position = _position findEmptyPosition [10,200];

                    if(count _position == 0) then {
                        _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    };
                    _heliPad = "Land_HelipadEmpty_F" createVehicle _position;

                    _eventAssets pushback _heliPad;
                    [_event, "eventAssets",_eventAssets] call ALIVE_fnc_hashSet;

                    _inCargo = _vehicleProfile select 2 select 9;

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            if!(isNil "_cargoProfile") then {
                                [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                            };

                        } forEach _inCargo;
                    };

                }else{

                    private ["_position","_inCargo","_cargoProfileID","_cargoProfile"];

                    _inCargo = _vehicleProfile select 2 select 9;
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            if!(isNil "_cargoProfile") then {
                                [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                                [_cargoProfile,"position",_position] call ALIVE_fnc_profileEntity;
                            };

                        } forEach _inCargo;
                    };

                };

            };
            case "EMPTY":{

                if(_active) then {

                    private ["_group","_position","_heliPad"];

                    _group = _entityProfile select 2 select 13;
                    _group setBehaviour "CARELESS";

                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _position = _position findEmptyPosition [10,200];

                    if(count _position == 0) then {
                        _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    };
                    _heliPad = "Land_HelipadEmpty_F" createVehicle _position;

                    _eventAssets pushback _heliPad;
                    [_event, "eventAssets",_eventAssets] call ALIVE_fnc_hashSet;

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                }else{

                    private ["_position"];

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                    _position = _vehicleProfile select 2 select 2;
                    _position set [2,0];
                    [_vehicleProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"hasSimulated",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"engineOn",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;

                    [_entityProfile, "destroy"] call ALIVE_fnc_profileEntity;
                    //[ALIVE_profileHandler, "unregisterProfile", _entityProfile] call ALIVE_fnc_profileHandler;

                };

            };
            case "PAYLOAD":{

                private ["_index","_heliPad"];

               /* _index = _eventTransportProfiles find _profileID;
                _eventTransportProfiles set [_index,objNull];
                _eventTransportProfiles = _eventTransportProfiles - [objNull];
                [_event, "transportProfiles",_eventTransportProfiles] call ALIVE_fnc_hashSet;


                _index = _eventTransportVehiclesProfiles find _vehicleProfileID;
                _eventTransportVehiclesProfiles set [_index,objNull];
                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles - [objNull];
                [_event, "transportVehiclesProfiles",_eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet; */


                if(_active) then {

                    private ["_vehicle","_group","_position","_heliPad"];

                    _vehicle = _vehicleProfile select 2 select 10;
                    _group = _entityProfile select 2 select 13;
                    _group setBehaviour "CARELESS";

                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _position = _position findEmptyPosition [10,200];

                    if(count _position == 0) then {
                        _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    };
                    _heliPad = "Land_HelipadEmpty_F" createVehicle _position;

                    _eventAssets pushback _heliPad;
                    [_event, "eventAssets",_eventAssets] call ALIVE_fnc_hashSet;

                    if!(isNil "_vehicle") then {

                        [_vehicle, _slingloading, _position, _eventPosition] spawn {

                            _vehicle = _this select 0;
                            _slingloading = _this select 1;
                            _position = _this select 2;
                            _eventPosition = _this select 3;

                            sleep 3;

                            while { ( (alive _vehicle) && !(unitReady _vehicle) ) } do
                            {
                                   sleep 2;
                            };

                            if (alive _vehicle) then
                            {
                                if (_slingLoading) then {

                                    _slingloadVehicle = getSlingLoad _vehicle;

                                    // If slingloading a boat, find the nearest patch of water
                                    If (_slingloadVehicle isKindOf "Ship") then {
                                        _position = [
                                            _eventPosition, // center position
                                            0, // minimum distance
                                            100, // maximum distance
                                            (sizeOf typeOf _slingloadVehicle) / 2, // minimum to nearest object
                                            2, // water mode
                                            0, // gradient
                                            0, // shore mode
                                            [], // blacklist
                                            [
                                                _eventPosition, // default position on land
                                                _eventPosition // default position on water
                                            ]
                                        ] call bis_fnc_findSafePos;
                                    };

                                    _vehicle setVariable ["alive_ml_slingload_object", _slingloadVehicle];

                                    _wp = group _vehicle addWaypoint [_position, 0];
                                    _wp setWaypointType "UNHOOK";
                                    _wp setWaypointStatements ["true",
                                        "_ID = (vehicle this) getVariable ['profileID',''];
                                        _profile = [ALIVE_profileHandler,'getProfile',_ID] call ALIVE_fnc_profileHandler;
                                        _slingload = [_profile, 'slingload'] call ALIVE_fnc_profileVehicle;
                                        _slungID = _slingload select 0;
                                        if (typeName _slungID == 'ARRAY') then {
                                            _slungprofile = [ALIVE_profileHandler,'getProfile',_slungID select 0] call ALIVE_fnc_profileHandler;
                                            [_slungprofile, 'slung', []] call ALIVE_fnc_hashSet;
                                            [_slungProfile,'spawnType',[]] call ALIVE_fnc_profileVehicle;
                                        } else {
                                            [(vehicle this) getVariable [""alive_ml_slingload_object"", objNull]] spawn ALIVE_fnc_MLAttachSmokeOrStrobe;
                                        };
                                        [_profile, 'slingload', []] call ALIVE_fnc_profileVehicle;
                                        [_profile, 'slingloading', false] call ALIVE_fnc_hashSet;"
                                    ];
                                    // [_vehicle] call ALiVE_fnc_unhookRemote;
                                } else {
                                   [_vehicle,"LAND"] call ALiVE_fnc_landRemote;
                                };
                            };

                        };

                    };

                }else{

                    private ["_position"];

                    _position = _vehicleProfile select 2 select 2;
                    _position set [2,0];
                    [_vehicleProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"hasSimulated",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"engineOn",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;

                    // Update any slingload
                    _slungID = ([_vehicleProfile, "slingload"] call ALIVE_fnc_profileVehicle) select 0;
                    if (typeName _slungID == "ARRAY") then {
                        _slungprofile = [ALIVE_profileHandler,'getProfile',_slungID] call ALIVE_fnc_profileHandler;
                        [_slungprofile, "slung", []] call ALIVE_fnc_hashSet;
                        [_slungProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                        [_slungProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;
                        [_slungProfile,"spawnType",[]] call ALIVE_fnc_profileVehicle;
                    };
                    [_vehicleProfile,"spawnType",[]] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"slingload",[]] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile, 'slingloading', false] call ALIVE_fnc_hashSet;

                };

            };
        };

    };

    case "setEventProfilesAvailable": {

        // logistics event complete
        // release profiles to OPCOM
        // control if AI requested
        // if player requested, it's more
        // complicated

        private ["_debug","_event","_eventData","_eventID","_eventFaction","_side","_eventPosition","_eventCargoProfiles","_infantryProfiles","_armourProfiles",
        "_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles","_profile","_eventAssets","_finalDestination","_logEvent"];

        _debug = [_logic, "debug"] call MAINCLASS;
        _event = _args;

        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventFaction = _eventData select 1;
        _side = _eventData select 2;

        _eventPosition = _eventData select 0;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;

        _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
        _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
        _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
        _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
        _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
        _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

        _eventAssets = [_event, "eventAssets"] call ALIVE_fnc_hashGet;

        {
            deleteVehicle _x;
        } forEach _eventAssets;

        if!(_playerRequested) then {

            // AI requested
            // set all cargo profiles as not busy

            {
                _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                if!(isNil "_profile") then {
                    [_profile,"busy",false] call ALIVE_fnc_hashSet;
                };

            } forEach _infantryProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _armourProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _mechanisedProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _motorisedProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _planeProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _heliProfiles;


            // dispatch event
            _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
            _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;


        }else{

            // Player requested

            private ["_emptyProfiles","_joinIndividualProfiles","_staticIndividualProfiles","_reinforceIndividualProfiles",
            "_joinGroupProfiles","_staticGroupProfiles","_reinforceGroupProfiles","_payloadGroupProfiles","_player","_logEvent","_finalDestination"];

            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            _joinIndividualProfiles = [_playerRequestProfiles,"joinIndividuals"] call ALIVE_fnc_hashGet;
            _staticIndividualProfiles = [_playerRequestProfiles,"staticIndividuals"] call ALIVE_fnc_hashGet;
            _reinforceIndividualProfiles = [_playerRequestProfiles,"reinforceIndividuals"] call ALIVE_fnc_hashGet;
            _joinGroupProfiles = [_playerRequestProfiles,"joinGroups"] call ALIVE_fnc_hashGet;
            _staticGroupProfiles = [_playerRequestProfiles,"staticGroups"] call ALIVE_fnc_hashGet;
            _reinforceGroupProfiles = [_playerRequestProfiles,"reinforceGroups"] call ALIVE_fnc_hashGet;
            _payloadGroupProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            // reinforce profiles get released
            // to OPCOM control

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _reinforceIndividualProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _reinforceGroupProfiles;


            // find the player object

            if((isServer && isMultiplayer) || isDedicated) then {

                _player = objNull;
                {
                    if (getPlayerUID _x == _playerID) exitWith {
                        _player = _x;
                    };
                } forEach playableUnits;
            }else{

                 _player = player;
            };

            // player found

            if (!(isNull _player)) then {

                private ["_active","_type","_units"];

                // join player profiles, if active
                // join the player group

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {

                                    _units = _profile select 2 select 21;

                                    _units joinSilent (group _player);

                                    [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };
                    } forEach _x;

                } forEach _joinIndividualProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {

                                    _units = _profile select 2 select 21;

                                    _units joinSilent (group _player);

                                    [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };
                    } forEach _x;

                } forEach _joinGroupProfiles;

                // static defence profiles
                // if active set to garrison
                // nearby structures

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {

                                    [_profile, "setActiveCommand", ["ALIVE_fnc_managedGarrison","managed",[200,"false",_eventPosition]]] call ALIVE_fnc_profileEntity;

                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };
                    } forEach _x;

                } forEach _staticIndividualProfiles;

                {
                    if(count _x < 2) then {

                        _profile = [ALIVE_profileHandler, "getProfile", (_x select 0)] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {

                                    [_profile, "setActiveCommand", ["ALIVE_fnc_managedGarrison","managed",[200,"false",_eventPosition]]] call ALIVE_fnc_profileEntity;

                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };

                    };

                } forEach _staticGroupProfiles;

                // If payload profiles are still carrying their load, wait a while then dump them
                private ["_payloadProfiles","_payloadProfileID","_payloadVehicleID","_payloadProfile","_payloadVehicle","_payloadCount",
                "_reinforcementPosition","_position","_vehicle"];

                _payloadProfiles = [];

                {
                    if(count _x > 1) then {
                        _payloadProfileID = _x select 0;
                        _payloadVehicleID = _x select 1;

                        _payloadProfile = [ALIVE_profileHandler, "getProfile", _payloadProfileID] call ALIVE_fnc_profileHandler;
                        _payloadVehicle = [ALIVE_profileHandler, "getProfile", _payloadVehicleID] call ALIVE_fnc_profileHandler;

                        if(!(isNil "_payloadProfile") && !(isNil "_payloadVehicle")) then {
                            _payloadProfiles pushback _payloadProfileID;

                            _vehicle = _payloadVehicle select 2 select 10;

                            [_event, "finalDestination", position _vehicle] call ALIVE_fnc_hashSet;
                        };
                    };

                } forEach _payloadGroupProfiles;

                if(count _payloadProfiles > 0) then {

                    _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;
                    _position = _reinforcementPosition getPos [1500, (([_event, "finalDestination"] call ALIVE_fnc_hashGet) getDir _reinforcementPosition)];

                    [_payloadGroupProfiles,_position] spawn {

                        private ["_payloadProfiles","_returnPosition","_currentTime","_waitTime","_profileWaypoint","_anyActive","_active",
                        "_profileCount","_vehicle"];

                        _payloadProfiles = _this select 0;
                        _returnPosition = _this select 1;

                        // Check to see if payload profiles are ready to return
                        // Slingloaders can return once done.
                        // If vehicle no longer has cargo it can return

                        private ["_payloadUnloaded"];

                        _payloadUnloaded = true;

                        {
                            private ["_Profile","_vehicleProfile"];

                            _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x select 1] call ALIVE_fnc_profileHandler;

                            if!(isNil "_vehicleProfile") then {

                                private ["_active","_slingLoading","_slingload","_noCargo","_vehicle"];

                                _active = _vehicleProfile select 2 select 1;

                                _slingLoading = [_vehicleProfile,"slingloading",false] call ALiVE_fnc_hashGet;

                                _vehicle = _vehicleProfile select 2 select 10;
                                _noCargo = count (_vehicle getvariable ["ALiVE_SYS_LOGISTICS_CARGO",[]]) == 0;

                                // If payload vehicle is not slingloading and its cargo is empty - its done.
                                TRACE_2("PR UNLOADED", !_slingLoading, _noCargo);

                                if( _active && _noCargo && !_slingloading ) then {
                                    _payloadUnloaded = true;

                                } else {

                                    _payloadUnloaded = false;

                                };

                                // If we've run out of time, dump cargo
                                if (_active && !_noCargo) then {
                                    [MOD(SYS_LOGISTICS),"unloadObjects",[_vehicle,_vehicle]] call ALiVE_fnc_logistics;
                                };

                                // Drop slingload
                                if (_active && _slingloading) then {
                                    private ["_slungID"];
                                    _slungID = ([_vehicleProfile, 'slingload'] call ALIVE_fnc_profileVehicle) select 0;
                                    if (typeName _slungID == 'ARRAY') then {
                                        private ["_slungprofile"];
                                        _slungprofile = [ALIVE_profileHandler,'getProfile',_slungID select 0] call ALIVE_fnc_profileHandler;
                                        [_slungprofile, 'slung', []] call ALIVE_fnc_hashSet;
                                        [_slungProfile,'spawnType',[]] call ALIVE_fnc_profileVehicle;
                                    };
                                    [_vehicleProfile, 'slingload', []] call ALIVE_fnc_profileVehicle;
                                    [_vehicleProfile, 'slingloading', false] call ALIVE_fnc_hashSet;
                                    _vehicle setSlingLoad objNull;
                                    // Delete current unhook waypoint
                                    deleteWaypoint [group _vehicle, (currentWaypoint (group _vehicle))];
                                };

                            };
                        } foreach _payloadProfiles;

                        _waitTime = 12; // 2 minutes = 12 x 10 secs
                        _currentTime = 0;

                        if (!_payloadUnloaded) then {
                            waituntil {
                                sleep 10;
                                _currentTime = _currentTime + 1;
                                (_currentTime > _waitTime)
                            };
                        };

                        _profileWaypoint = [_returnPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                        _profileCount = 0;

                        {
                            private ["_payloadProfile"];
                            _payloadProfile = _x;
                            {
                                private ["_payloadProfileID","_payloadProfile","_isEntity"];
                                _payloadProfileID = _x;

                                _payloadProfile = [ALIVE_profileHandler, "getProfile", _payloadProfileID] call ALIVE_fnc_profileHandler;

                                _isEntity = [_payloadProfile,"type"] call ALiVE_fnc_hashGet != "vehicle";

                                if(!(isNil "_payloadProfile") && _isEntity) then {
                                    [_payloadProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                    _profileCount = _profileCount + 1;
                                };
                            } foreach _payloadProfile;

                        } forEach _payloadProfiles;

                        if(_profileCount > 0) then {

                            waituntil {
                                sleep (10);

                                _anyActive = 0;

                                // once transport vehicles are inactive
                                // dispose of the profiles
                                {

                                    if (count _x > 0) then {
                                        private ["_ID","_profile","_pVehicle"];
                                        _ID = _x select 0;
                                        _profile = [ALIVE_profileHandler, "getProfile", _ID] call ALIVE_fnc_profileHandler;

                                        if (count _x > 1) then {
                                            _ID = _x select 1;
                                            _pVehicle = [ALIVE_profileHandler, "getProfile", _ID] call ALIVE_fnc_profileHandler;
                                        };

                                        if(!(isNil "_profile") && !(isNil "_pVehicle")) then {

                                            _vehicle = _pVehicle select 2 select 10;

                                            if([position _vehicle, 1500] call ALiVE_fnc_anyPlayersInRange == 0) then {

                                                [_profile, "destroy"] call ALIVE_fnc_profileEntity;
                                                [_pVehicle, "destroy"] call ALIVE_fnc_profileVehicle;

                                                //[ALIVE_profileHandler, "unregisterProfile", _payloadProfile] call ALIVE_fnc_profileHandler;
                                                //[ALIVE_profileHandler, "unregisterProfile", _payloadVehicle] call ALIVE_fnc_profileHandler;

                                            }else{

                                                _anyActive = _anyActive + 1;

                                            };

                                        };
                                    };

                                } forEach _payloadProfiles;

                                (_anyActive == 0)
                            };

                            //["PAYLOAD RTB COMPLETE!!!!"] call ALIVE_fnc_dump;

                        };

                    };

                    // dispatch event
                    _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                    _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    // respond to player request
                    if(_playerRequested) then {
                        _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID,_finalDestination,true],"Logistics","REQUEST_DELIVERED"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };



                }else{

                    // dispatch event
                    _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                    _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    // respond to player request
                    if(_playerRequested) then {
                        _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID,_finalDestination,false],"Logistics","REQUEST_DELIVERED"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };

                };

            }else{

                // player not found just set
                // the requested groups as
                // reinforcements

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _reinforceIndividualProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _reinforceGroupProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _staticIndividualProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _staticGroupProfiles;


                // dispatch event
                _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

            };

        };
    };

    case "removeEvent": {
        private["_debug","_eventID","_eventQueue"];

        // remove the event from the queue

        _eventID = _args;
        _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

        [_eventQueue,_eventID] call ALIVE_fnc_hashRem;

        [_logic, "eventQueue", _eventQueue] call MAINCLASS;

    };
};

TRACE_1("ML - output",_result);
_result ;
