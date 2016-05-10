//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sup_command\script_component.hpp>
SCRIPT(SCOM);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOM
Description:
command and control

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance

Examples:
[_logic, "debug", true] call ALiVE_fnc_SCOM;

See Also:
- <ALIVE_fnc_SCOMInit>

Author:
SpyderBlack / ARJay

Peer Reviewed:
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_SCOM
#define MTEMPLATE "ALiVE_SCOM_%1"
#define DEFAULT_DEBUG false
#define DEFAULT_STATE "INIT"
#define DEFAULT_SIDE "WEST"
#define DEFAULT_FACTION "BLU_F"
#define DEFAULT_MARKER []
#define DEFAULT_SELECTED_INDEX 0
#define DEFAULT_SELECTED_VALUE ""
#define DEFAULT_SCALAR 0
#define DEFAULT_COMMAND_STATE [] call ALIVE_fnc_hashCreate
#define DEFAULT_SCOM_LIMIT "SIDE"

// Display components
#define SCOMTablet_CTRL_MainDisplay 12001

// sub menu generic
#define SCOMTablet_CTRL_SubMenuBack 12006
#define SCOMTablet_CTRL_SubMenuAbort 12010
#define SCOMTablet_CTRL_Title 12007

// command interface elements
#define SCOMTablet_CTRL_BL1 12014
#define SCOMTablet_CTRL_BL2 12015
#define SCOMTablet_CTRL_BL3 12016
#define SCOMTablet_CTRL_BR1 12017
#define SCOMTablet_CTRL_BR2 12018
#define SCOMTablet_CTRL_BR3 12019
#define SCOMTablet_CTRL_MapRight 12021
#define SCOMTablet_CTRL_MainMap 12022
#define SCOMTablet_CTRL_IntelTypeTitle 12023
#define SCOMTablet_CTRL_IntelTypeList 12024
#define SCOMTablet_CTRL_IntelStatus 12025
#define SCOMTablet_CTRL_EditMap 12026
#define SCOMTablet_CTRL_EditList 12027
#define SCOMTablet_CTRL_WaypointList 12028
#define SCOMTablet_CTRL_WaypointTypeList 12029
#define SCOMTablet_CTRL_WaypointSpeedList 12030
#define SCOMTablet_CTRL_WaypointFormationList 12031
#define SCOMTablet_CTRL_WaypointBehavourList 12032
#define SCOMTablet_CTRL_IntelRenderTarget 12033

// Control Macros
#define SCOM_getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)
#define SCOM_getSelData(ctrl) (lbData[##ctrl,(lbCurSel ##ctrl)])


private ["_result"];

TRACE_1("SCOM - input",_this);

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
    case "opsLimit": {
        _result = [_logic,_operation,_args,DEFAULT_SCOM_LIMIT,["SIDE","FACTION","ALL"]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "scomOpsAllowSpectate": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["scomOpsAllowSpectate", _args];
        } else {
            _args = _logic getVariable ["scomOpsAllowSpectate", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["scomOpsAllowSpectate", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "scomOpsAllowInstantJoin": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["scomOpsAllowInstantJoin", _args];
        } else {
            _args = _logic getVariable ["scomOpsAllowInstantJoin", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["scomOpsAllowInstantJoin", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "intelLimit": {
        _result = [_logic,_operation,_args,DEFAULT_SCOM_LIMIT,["SIDE","FACTION","ALL"]] call ALIVE_fnc_OOsimpleOperation;
    };
	case "state": {
        _result = [_logic,_operation,_args,DEFAULT_STATE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "side": {
        _result = [_logic,_operation,_args,DEFAULT_SIDE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "commandState": {
        _result = [_logic,_operation,_args,DEFAULT_COMMAND_STATE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "marker": {
        _result = [_logic,_operation,_args,DEFAULT_MARKER] call ALIVE_fnc_OOsimpleOperation;
    };

	case "init": {

        //Only one init per instance is allowed
    	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SUP Command - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

    	//Start init
        _logic setVariable ["initGlobal", false];

	    private["_debug"];

        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];
        _logic setVariable ["moduleType", "ALIVE_SCOM"];
        _logic setVariable ["startupComplete", false];

        _debug = [_logic, "debug"] call MAINCLASS;

        ALIVE_SUP_COMMAND = _logic;

        if (isServer) then {

            // create the command handler
            ALIVE_commandHandler = [nil, "create"] call ALIVE_fnc_commandHandler;
            [ALIVE_commandHandler, "init"] call ALIVE_fnc_commandHandler;
            [ALIVE_commandHandler, "debug", _debug] call ALIVE_fnc_commandHandler;

        };

        if (hasInterface) then {

            _logic setVariable ["startupComplete", true];

            // set the player side

            private ["_playerSide","_sideNumber","_sideText","_playerFaction"];

            waitUntil {
                sleep 1;
                ((str side player) != "UNKNOWN")
            };

            _playerSide = side player;
            _sideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
            _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;

            if(_sideText == "CIV") then {
                _playerFaction = faction player;
                _playerSide = _playerFaction call ALiVE_fnc_factionSide;
                _sideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
                _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;
            };

            [_logic,"side",_sideText] call MAINCLASS;


            // set the player faction

            _playerFaction = faction player;

            [_logic,"faction",_playerFaction] call MAINCLASS;

            // set the command state

            private ["_commandState"];

            _commandState = [_logic,"commandState"] call MAINCLASS;

            [_commandState,"commandInterface",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            // intel state

            [_commandState,"intelTypeOptions",["Commander Objectives","Unit Marking","Imagery"]] call ALIVE_fnc_hashSet;
            [_commandState,"intelTypeValues",["Objectives","Marking","IMINT"]] call ALIVE_fnc_hashSet;
            [_commandState,"intelTypeSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"intelTypeSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            //[_commandState,"intelListOptions",[]] call ALIVE_fnc_hashSet;
            [_commandState,"intelListValues",[]] call ALIVE_fnc_hashSet;

            [_commandState,"intelSelectedIMINTSource",objNull] call ALIVE_fnc_hashSet;
            [_commandState,"intelIMINTCamera",objNull] call ALIVE_fnc_hashSet;
            [_commandState,"intelIMINTZoomLevel", 0.1] call ALIVE_fnc_hashSet;

            [_commandState,"intelOPCOMOptions",[]] call ALIVE_fnc_hashSet;
            [_commandState,"intelOPCOMValues",[]] call ALIVE_fnc_hashSet;
            [_commandState,"intelOPCOMSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"intelOPCOMSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            // ops state

            [_commandState,"opsGroupInstantJoin",false] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupInstantJoinPlayerPosition",position player] call ALIVE_fnc_hashSet;

            [_commandState,"opsGroupSpectate",false] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupSpectatePlayerPosition",position player] call ALIVE_fnc_hashSet;

            [_commandState,"opsOPCOMOptions",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsOPCOMValues",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsOPCOMSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"opsOPCOMSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_commandState,"opsGroups",[]] call ALIVE_fnc_hashSet;

            [_commandState,"opsGroupsOptions",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupsValues",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupsSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupsSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_commandState,"opsGroupSelectedProfile",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupWaypoints",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupPlannedWaypoints",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupWaypointsPlanned",false] call ALIVE_fnc_hashSet;

            [_commandState,"opsGroupWaypointsSelectedOptions",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupWaypointsSelectedValues",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupWaypointsSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupWaypointsSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_commandState,"opsWPProfiledTypeOptions",["Move","Cycle"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPProfiledTypeValues",["MOVE","CYCLE"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPNonProfiledTypeOptions",["Move","SAD","Cycle","Load","Land - Engines Off","Land - Engines On","TR Unload"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPNonProfiledTypeValues",["MOVE","SAD","CYCLE","LOAD","LAND OFF","LAND HOVER","TR UNLOAD"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPTypeOptions",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPTypeValues",[]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPTypeSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPTypeSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_commandState,"opsWPSpeedOptions",["Unchanged","Limited","Normal","Full"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPSpeedValues",["UNCHANGED","LIMITED","NORMAL","FULL"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPSpeedSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPSpeedSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_commandState,"opsWPFormationOptions",["File","Column","Staggered Column","Wedge","Echelon Left","Echelon Right","Vee","Line","Diamond"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPFormationValues",["FILE","COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","DIAMOND"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPFormationSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPFormationSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_commandState,"opsWPBehaviourOptions",["Careless","Safe","Aware","Combat","Stealth"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPBehaviourValues",["CARELESS","SAFE","AWARE","COMBAT","STEALTH"]] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPBehaviourSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_commandState,"opsWPBehaviourSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_logic,"commandState",_commandState] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------

            private ["_opsLimit","_intelLimit"];

            _opsLimit = [_logic,"opsLimit"] call MAINCLASS;
            _intelLimit = [_logic,"intelLimit"] call MAINCLASS;

            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE Command State"] call ALIVE_fnc_dump;
                ["ALIVE Command Side: %1, Faction: %2, OPS Limit: %3 Intel Limit: %4",_sideText,_playerFaction,_opsLimit,_intelLimit] call ALIVE_fnc_dump;
                _commandState call ALIVE_fnc_inspectHash;
            };

            // DEBUG -------------------------------------------------------------------------------------


        };

        [_logic, "start"] call MAINCLASS;

	};
	case "start": {

        // set module as startup complete
        _logic setVariable ["startupComplete", true];

        if(isServer) then {

            // start listening for events
            [_logic,"listen"] call MAINCLASS;

        };

	};
	case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["SCOM_UPDATED"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };
    case "handleEvent": {

        private["_event","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;

            // a response event from command handler has been received.
            // if we are a dedicated server,
            // dispatch the event to the player who requested it
            if((isServer && {isMultiplayer}) || {isDedicated}) then {

                private ["_eventData","_playerID","_player"];

                _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

                _playerID = _eventData select 0;

                _player = [_playerID] call ALIVE_fnc_getPlayerByUID;

                if !(isNull _player) then {
                    _event remoteExecCall ["ALIVE_fnc_SCOMTabletEventToClient",_player];
                };

            }else{

                // the player is the server

                [_logic, "handleServerResponse", _event] call MAINCLASS;

            };

        };
    };
    case "handleServerResponse": {

        // event handler for response from server command handler

        private["_event","_eventData","_type","_message","_debug"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
            _message = [_event, "message"] call ALIVE_fnc_hashGet;

            _debug = [_logic, "debug"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALiVE SCOM - Handle server response event received"] call ALIVE_fnc_dump;
                _event call ALIVE_fnc_inspectHash;
            };
            // DEBUG -------------------------------------------------------------------------------------

            disableSerialization;

            switch(_message) do {
                case "OPCOM_SIDES_AVAILABLE": {

                    [_logic,"enableIntelOPCOMSelect",_eventData] call MAINCLASS;

                };
                case "OPCOM_OBJECTIVES": {

                    [_logic,"enableIntelOPCOMObjectives",_eventData] call MAINCLASS;

                };
                case "UNIT_MARKING": {

                    [_logic,"enableIntelUnitMarking",_eventData] call MAINCLASS;

                };
                case "IMINT_SOURCES_AVAILABLE": {

                    [_logic,"enableIntelIMINT",_eventData] call MAINCLASS;

                };
                case "OPS_SIDES_AVAILABLE": {

                    [_logic,"enableOpsOPCOMSelect",_eventData] call MAINCLASS;

                };
                case "OPS_GROUPS": {

                    [_logic,"enableOpsHighCommand",_eventData] call MAINCLASS;

                };
                case "OPS_PROFILE": {

                    [_logic,"enableOpsProfile",_eventData] call MAINCLASS;

                };
                case "OPS_RESET": {

                    [_logic,"enableOpsInterface",_eventData] call MAINCLASS;

                };
                case "OPS_PROFILE_WAYPOINTS": {

                    [_logic,"enableGroupWaypointEdit",_eventData] call MAINCLASS;

                };
                case "OPS_PROFILE_WAYPOINTS_CLEARED": {

                    [_logic,"enableGroupWaypointEdit",_eventData] call MAINCLASS;

                };
                case "OPS_PROFILE_WAYPOINTS_UPDATED": {

                    [_logic,"enableGroupWaypointEdit",_eventData] call MAINCLASS;

                };
                case "OPS_GROUP_JOIN_READY": {

                    [_logic,"enableOpsJoinGroup",_eventData] call MAINCLASS;

                };
                case "OPS_GROUP_SPECTATE_READY": {

                    [_logic,"enableOpsSpectateGroup",_eventData] call MAINCLASS;

                };
            };
        };

    };
	case "tabletOnLoad": {

        // on load of the tablet
        // restore state

        if (hasInterface) then {

            [_logic] spawn {

                private ["_logic","_state"];

                _logic = _this select 0;

                disableSerialization;

                //[_logic,"disableAll"] call MAINCLASS; what is this?

                //sleep 0.5; Seems to work fine/better without sleeping

                _state = [_logic,"state"] call MAINCLASS;

                switch(_state) do {

                    case "INIT":{

                        // the interface is opened
                        // for the first time

                        private ["_commandState","_interfaceType"];

                        // get the current interface type

                        _commandState = [_logic,"commandState"] call MAINCLASS;

                        _interfaceType = [_commandState,"commandInterface"] call ALIVE_fnc_hashGet;

                        switch(_interfaceType) do {

                            case "INTEL":{
                                [_logic,"enableIntelInterface"] call MAINCLASS;
                            };
                            case "OPS":{
                                [_logic,"enableOpsInterface"] call MAINCLASS;
                            };
                        };

                    };

                };

                // Hide GPS
                showGPS false;

            };

        };

    };
    case "tabletOnUnLoad": {

        // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
        if (hasInterface) then {

            private ["_commandState","_IMINTcam","_markers","_groupWaypoints","_plannedWaypoints"];

            _commandState = [_logic,"commandState"] call MAINCLASS;
            
            // reset IMINT
            
            [_commandState,"intelListValues",[]] call ALiVE_fnc_hashSet;

            _IMINTcam = [_commandState,"intelIMINTCamera"] call ALIVE_fnc_hashGet;
            _IMINTcam cameraEffect ["Terminate", "BACK"];
            camDestroy _IMINTcam;

            // Show GPS
            showGPS true;

            // Clear markers
            _markers = [_logic,"marker"] call MAINCLASS;

            {
                deleteMarkerLocal _x;
            } foreach _markers;

            [_commandState,"opsGroupWaypoints", []] call ALIVE_fnc_hashSet;
            [_commandState,"opsGroupPlannedWaypoints", []] call ALIVE_fnc_hashSet;

        };

    };
	case "tabletOnAction": {

	    // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
        if (hasInterface) then {

            if (isnil "_args") exitwith {};

            private ["_action","_debug"];

            _action = _args select 0;
            _args = _args select 1;
            _debug = [_logic, "debug"] call MAINCLASS;

            switch(_action) do {

                case "OPEN_INTEL": {

                    private ["_commandState"];

                    // open the intel interface, set the interface type on the local module state

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    [_commandState,"commandInterface","INTEL"] call ALIVE_fnc_hashSet;

                    [_logic,"commandState",_commandState] call MAINCLASS;

                    createDialog "SCOMTablet";

                };

                case "OPEN_OPS": {

                    // open the ops interface, set the interface type on the local module state

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    [_commandState,"commandInterface","OPS"] call ALIVE_fnc_hashSet;

                    [_logic,"commandState",_commandState] call MAINCLASS;

                    createDialog "SCOMTablet";

                };

                // INTEL ------------------------------------------------------------------------------------------------------------------------------

                case "INTEL_TYPE_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue","_playerID","_requestID",
                    "_intelLimit","_side","_faction","_event"];

                    // on click of the intel analysis type list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"intelTypeOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"intelTypeValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"intelTypeSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"intelTypeSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        // send the event to get further data from the command handler

                        _playerID = getPlayerUID player;
                        _requestID = format["%1_%2",_faction,floor(time)];

                        _intelLimit = [_logic,"intelLimit"] call MAINCLASS;
                        _side = [_logic,"side"] call MAINCLASS;
                        _faction = [_logic,"faction"] call MAINCLASS;

                        _event = ['INTEL_TYPE_SELECT', [_requestID,_playerID,_selectedValue,_intelLimit,_side,_faction], "SCOM"] call ALIVE_fnc_event;

                        if(isServer) then {
                            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                        }else{
                            [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                        };

                        // show waiting until response comes back

                        [_logic, "enableIntelWaiting", true] call MAINCLASS;

                    };
                };

                case "INTEL_IMINT_SOURCE_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_intelTypeTitle","_listValues","_source","_map","_back"];

                    // IMINT source selected from list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // enable map click for pip focus location

                        _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
                        _intelTypeTitle ctrlShow true;

                        _intelTypeTitle ctrlSetText "Click on map to select center of image focus";

                        _listValues = [_commandState,"intelListValues"] call ALIVE_fnc_hashGet;
                        _source = _listValues select _selectedIndex;
                        [_commandState,"intelSelectedIMINTSource", _source] call ALIVE_fnc_hashSet;

                        _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MainMap);
                        _map ctrlShow true;

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, (getPos _source)];
                        ctrlMapAnimCommit _map;

                        _map ctrlSetEventHandler ["MouseButtonDown", "['INTEL_IMINT_FOCUS_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                        _back ctrlShow true;

                        _back ctrlSetText "Back";

                        _back ctrlSetEventHandler ["MouseButtonClick", "['INTEL_RESET',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    };

                };

                case "INTEL_IMINT_CANCEL_IMAGE_VIEWING": {

                    // reset to IMINT source selection

                    private ["_commandState","_map","_renderTarget","_back","_playerID","_requestID","_intelLimit","_side","_faction","_event","_IMINTcam"];

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    // destroy camera

                    _IMINTcam = [_commandState,"intelIMINTCamera"] call ALIVE_fnc_hashGet;
                    _IMINTcam cameraEffect ["Terminate", "BACK"];
                    camDestroy _IMINTcam;

                    // enable / disable controls

                    _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MainMap);
                    _map ctrlShow true;

                    _map ctrlSetEventHandler ["MouseButtonDown", ""];

                    _renderTarget = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelRenderTarget);
                    _renderTarget ctrlShow false;

                    // open IMINT source selection screen

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _intelLimit = [_logic,"intelLimit"] call MAINCLASS;
                    _side = [_logic,"side"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;

                    _event = ['INTEL_TYPE_SELECT', [_requestID,_playerID,"IMINT",_intelLimit,_side,_faction], "SCOM"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                    };

                    _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                    _back ctrlShow true;

                    _back ctrlSetEventHandler ["MouseButtonClick", "['INTEL_RESET',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    // show waiting until response comes back

                    [_logic, "enableIntelWaiting", true] call MAINCLASS;

                };

                case "INTEL_IMINT_FOCUS_SELECT": {

                    private ["_commandState","_position","_listValues","_source"];

                    // IMINT image focus location selected

                    (_args select 0) params ["_map","_button","_posX","_posY"];

                    if (_button == 0) then {
                        _commandState = [_logic,"commandState"] call MAINCLASS;

                        _position = _map ctrlMapScreenToWorld [_posX, _posY];
                        _map ctrlShow false;

                        _listValues = [_commandState,"intelListValues"] call ALIVE_fnc_hashGet;
                        _source = [_commandState,"intelSelectedIMINTSource"] call ALIVE_fnc_hashGet;

                        [_logic,"intelRenderSourceToTarget", [_source,_position]] call MAINCLASS;
                    };

                };

                case "INTEL_IMINT_DISPLAY_CAMERA_OPTION_CATEGORIES": {

                    private ["_intelTypeTitle","_intelTypeList","_index","_back"];

                    _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
                    _intelTypeTitle ctrlShow true;

                    _intelTypeTitle ctrlSetText "Select camera option category";

                    _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
                    _intelTypeList ctrlShow true;

                    lbClear _intelTypeList;
                    _intelTypeList lbSetCurSel -1;

                    // add camera effect options to list

                    _index = _intelTypeList lbAdd "Zoom";
                    _intelTypeList lbSetData [_index,"zoom"];

                    _index = _intelTypeList lbAdd "Effects";
                    _intelTypeList lbSetData [_index,"effects"];

                    _intelTypeList ctrlSetEventHandler ["LBSelChanged", "['INTEL_IMINT_CAMERA_OPTION_CATEGORY_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                    _back ctrlShow true;

                    _back ctrlSetText "Back";

                    _back ctrlSetEventHandler ["MouseButtonClick", "['INTEL_IMINT_CANCEL_IMAGE_VIEWING',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                };

                case "INTEL_IMINT_CAMERA_OPTION_CATEGORY_SELECT": {

                    private ["_category","_intelTypeTitle","_intelTypeList"];

                    (_args select 0) params ["_control","_index","_intelTypeList","_back"];

                    _category = _control lbData _index;

                    _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
                    _intelTypeTitle ctrlShow true;

                    _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
                    _intelTypeList ctrlShow true;

                    switch (_category) do {

                        case "zoom": {

                            _intelTypeTitle ctrlSetText "Select zoom option";

                            lbClear _intelTypeList;
                            _intelTypeList lbSetCurSel -1;

                            _index = _intelTypeList lbAdd "Zoom in";
                            _intelTypeList lbSetData [_index,"zoom_in"];

                            _index = _intelTypeList lbAdd "Zoom Out";
                            _intelTypeList lbSetData [_index,"zoom_out"];

                            _intelTypeList ctrlSetEventHandler ["LBSelChanged", "['INTEL_IMINT_CAMERA_ZOOM_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        };

                        case "effects": {

                            _intelTypeTitle ctrlSetText "Select camera effect";

                            lbClear _intelTypeList;
                            _intelTypeList lbSetCurSel -1;

                            _index = _intelTypeList lbAdd "Normal";
                            _intelTypeList lbSetData [_index,"normal"];

                            _index = _intelTypeList lbAdd "Night Vision";
                            _intelTypeList lbSetData [_index,"nvg"];

                            _index = _intelTypeList lbAdd "Thermal";
                            _intelTypeList lbSetData [_index,"thermal"];

                            _intelTypeList ctrlSetEventHandler ["LBSelChanged", "['INTEL_IMINT_CAMERA_EFFECT_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        };

                    };

                    _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                    _back ctrlShow true;
                    _back ctrlSetText "Back";
                    _back ctrlSetEventHandler ["MouseButtonClick", "['INTEL_IMINT_DISPLAY_CAMERA_OPTION_CATEGORIES',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                };

                case "INTEL_IMINT_CAMERA_ZOOM_SELECT": {

                    private ["_commandState","_zoomType","_cam","_currentZoom"];

                    (_args select 0) params ["_control","_index"];

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _zoomType = _control lbData _index;
                    _cam = [_commandState,"intelIMINTCamera"] call ALIVE_fnc_hashGet;
                    _currentZoom = [_commandState,"intelIMINTZoomLevel"] call ALIVE_fnc_hashGet;

                    switch (_zoomType) do {

                        case "zoom_in": {

                            _cam camSetFov (_currentZoom - 0.1);
                            _currentZoom = _currentZoom - 0.1;

                        };

                        case "zoom_out": {

                            if (_currentZoom < 1) then {
                                _cam camSetFov (_currentZoom + 0.1);
                                _currentZoom = _currentZoom + 0.1;
                            };

                        };

                    };

                    _cam camCommit 0;

                    [_commandState,"intelIMINTZoomLevel", _currentZoom] call ALIVE_fnc_hashSet;

                };

                case "INTEL_IMINT_CAMERA_EFFECT_SELECT": {

                    private ["_effect"];

                    (_args select 0) params ["_control","_index"];

                    _effect = _control lbData _index;

                    switch (_effect) do {

                        case "normal": {

                            "ALiVE_C2ISTAR_IMINT_CAM" setPiPEffect [0];

                        };
                        case "nvg": {

                            "ALiVE_C2ISTAR_IMINT_CAM" setPiPEffect [1];

                        };
                        case "thermal": {

                            "ALiVE_C2ISTAR_IMINT_CAM" setPiPEffect [2];

                        };

                    };

                };

                case "INTEL_OPCOM_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue","_playerID","_requestID",
                    "_intelLimit","_side","_faction","_event"];

                    // on click of the intel opcom side list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"intelOPCOMOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"intelOPCOMValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"intelOPCOMSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"intelOPCOMSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        // send the event to get further data from the command handler

                        _faction = [_logic,"faction"] call MAINCLASS;

                        _playerID = getPlayerUID player;
                        _requestID = format["%1_%2",_faction,floor(time)];

                        _event = ['INTEL_OPCOM_SELECT', [_requestID,_playerID,_selectedValue], "SCOM"] call ALIVE_fnc_event;

                        if(isServer) then {
                            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                        }else{
                            [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                        };

                        // show waiting until response comes back

                        [_logic, "enableIntelWaiting", true] call MAINCLASS;

                    };
                };

                case "INTEL_RESET": {

                    [_logic,"enableIntelInterface"] call MAINCLASS;
                };


                // OPS ------------------------------------------------------------------------------------------------------------------------------


                case "OPS_OPCOM_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue","_playerID","_requestID",
                    "_intelLimit","_side","_faction","_event"];

                    // on click of the ops opcom side list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"opsOPCOMOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsOPCOMValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"opsOPCOMSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"opsOPCOMSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        // send the event to get further data from the command handler

                        _faction = [_logic,"faction"] call MAINCLASS;

                        _playerID = getPlayerUID player;
                        _requestID = format["%1_%2",_faction,floor(time)];

						[nil,"opsOPCOMSelected", [_requestID,_playerID,_selectedValue]] remoteExecCall [QUOTE(ALIVE_fnc_commandHandler),2]; // need the raw speed
						
						/*
                        _event = ['OPS_OPCOM_SELECT', [_requestID,_playerID,_selectedValue], "SCOM"] call ALIVE_fnc_event;
                        if(isServer) then {
                            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                        }else{
                            [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                        };
						*/

                        // show waiting until response comes back

                        [_logic, "enableOpsWaiting", true] call MAINCLASS;

                    };
                };

                case "OPS_GROUP_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue","_map"];

                    // on click of the ops group list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"opsGroupsOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsGroupsValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"opsGroupsSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"opsGroupsSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        // move the map to the selected profile

                        _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _selectedValue select 1];
                        ctrlMapAnimCommit _map;

                        [_logic, "enableGroupSelected"] call MAINCLASS;

                    };
                };

                case "OP_EDIT_MAP_CLICK": {

                    // on right map click

                    private ["_button","_posX","_posY","_commandState","_map","_cursorPosition","_listOptions","_listValues","_position",
                    "_selectedIndex","_selectedOption","_selectedValue","_editList","_dist"];

                    _button = _args select 0 select 1;
                    _posX = _args select 0 select 2;
                    _posY = _args select 0 select 3;

                    if(_button == 0) then {

                        _commandState = [_logic,"commandState"] call MAINCLASS;

                        _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);

                        // move the map

                        _cursorPosition = _map ctrlMapScreenToWorld [_posX, _posY];

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _cursorPosition];
                        ctrlMapAnimCommit _map;

                        // find a profile near where the map was clicked

                        _editList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditList);

                        _listOptions = [_commandState,"opsGroupsOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsGroupsValues"] call ALIVE_fnc_hashGet;

                        _selectedIndex = -1;
						_dist = ((ctrlMapScale _map) * worldSize) / 100;

                        {
                            _position = _x select 1;
                            if(_cursorPosition distance2D _position < _dist) exitWith {
                                _selectedIndex = _forEachIndex;
                            };
                        } foreach _listValues;

                        // if profile found set the list to the selected profile

                        if(_selectedIndex > 0) then {

                            _editList lbSetCurSel _selectedIndex;

                            _selectedOption = _listOptions select _selectedIndex;
                            _selectedValue = _listValues select _selectedIndex;

                            [_commandState,"opsGroupsSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                            [_commandState,"opsGroupsSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        };

                    };

                };

                case "OPS_JOIN_GROUP": {

                    private ["_commandState","_selectedProfile","_profileID","_playerID","_requestID","_event","_faction","_buttonL1"];

                    // a group has been selected for instant join

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;

                    [_commandState,"opsGroupInstantJoin",true] call ALIVE_fnc_hashSet;
                    [_commandState,"opsGroupInstantJoinPlayerPosition",position player] call ALIVE_fnc_hashSet;

                    [_logic,"commandState",_commandState] call MAINCLASS;

                    _profileID = _selectedProfile select 0;

                    _faction = [_logic,"faction"] call MAINCLASS;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

                    ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                    ["setSplashText",_line1] call ALIVE_fnc_displayMenu;
					
                    player allowDamage false; // must be locally executed, protect player from explosives, invisibility is done serverside

                    // send the event to get further data from the command handler

                    _event = ['OPS_JOIN_GROUP', [_requestID,_playerID,_profileID], "SCOM"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                    };

                    // close the tablet

                    closeDialog 0;

                };

                case "OPS_CANCEL_JOIN_GROUP": {

                    private ["_commandState","_initialPosition","_line1","_playerID","_requestID","_event","_faction","_buttonL1"];

                    // close the tablet

                    closeDialog 0;

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    [_commandState,"opsGroupInstantJoin",false] call ALIVE_fnc_hashSet;

                    [_logic,"commandState",_commandState] call MAINCLASS;

                };

                case "OPS_SPECTATE_GROUP": {

                    private ["_commandState","_selectedProfile","_profileID","_playerID","_requestID","_event","_faction","_buttonL1"];

                    // a group has been selected for instant join

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;

                    [_commandState,"opsGroupSpectate",true] call ALIVE_fnc_hashSet;
                    [_commandState,"opsGroupSpectatePlayerPosition",position player] call ALIVE_fnc_hashSet;

                    [_logic,"commandState",_commandState] call MAINCLASS;

                    _profileID = _selectedProfile select 0;

                    _faction = [_logic,"faction"] call MAINCLASS;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _line1 = "<t size='1.5' color='#68a7b7' align='center'>Please Wait...</t><br/><br/>";

                    ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                    ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                    // send the event to get further data from the command handler

                    _event = ['OPS_SPECTATE_GROUP', [_requestID,_playerID,_profileID], "SCOM"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                    };

                    // close the tablet

                    closeDialog 0;

                };

                case "OPS_CANCEL_SPECTATE_GROUP": {

                    private ["_commandState","_initialPosition","_line1","_playerID","_requestID","_event","_faction","_buttonL1"];

                    // close the tablet

                    closeDialog 0;

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    [_commandState,"opsGroupSpectate",false] call ALIVE_fnc_hashSet;

                    [_logic,"commandState",_commandState] call MAINCLASS;

                };

                case "OPS_EDIT_WAYPOINTS": {

                    private ["_commandState","_selectedProfile","_profileID","_playerID","_requestID","_event","_faction","_buttonL1"];

                    // a group has been selected for waypoint editing

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;

                    _profileID = _selectedProfile select 0;

                    _faction = [_logic,"faction"] call MAINCLASS;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _buttonL1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL1);
                    _buttonL1 ctrlShow false;

                    _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                    _back ctrlShow true;
                    _back ctrlSetText "Back";
                    _back ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_EDIT_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    // send the event to get further data from the command handler

                    _event = ['OPS_GET_PROFILE_WAYPOINTS', [_requestID,_playerID,_profileID], "SCOM"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                    };

                    // show waiting until response comes back

                    [_logic, "enableOpsWaiting", true] call MAINCLASS;

                };

                case "OPS_CANCEL_EDIT_WAYPOINTS": {

                    _commandState = [_logic,"commandState"] call MAINCLASS;
                    _groups = [_commandState,"opsGroups", []] call ALiVE_fnc_hashGet;
                    _side = [_commandState,"opsOPCOMSelectedValue"] call ALiVE_fnc_hashGet;

                    // enable/disable interface controls

                    _waypointList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointList);
                    _waypointList ctrlShow false;

                    _waypointTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointTypeList);
                    _waypointTypeList ctrlShow false;

                    _waypointSpeedList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointSpeedList);
                    _waypointSpeedList ctrlShow false;

                    _waypointFormationList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointFormationList);
                    _waypointFormationList ctrlShow false;

                    _waypointBehaviourList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointBehavourList);
                    _waypointBehaviourList ctrlShow false;

                    _buttonR1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR1);
                    _buttonR1 ctrlShow false;

                    _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                    _back ctrlShow true;
                    _back ctrlSetEventHandler ["MouseButtonClick", "['OPS_RESET',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];
                    
                    // reset selected profile data
                    
                    [_commandState,"opsGroupSelectedProfile",[]] call ALIVE_fnc_hashSet;
                    [_commandState,"opsGroupWaypoints",[]] call ALIVE_fnc_hashSet;
                    [_commandState,"opsGroupPlannedWaypoints",[]] call ALIVE_fnc_hashSet;
                    [_commandState,"opsGroupWaypointsPlanned",false] call ALIVE_fnc_hashSet;

                    [_commandState,"opsGroupsSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
                    [_commandState,"opsGroupsSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;
                    
                    // delete profile markers, they are created again once list is reshown
                    
                    _markers = [_logic,"marker"] call MAINCLASS;
                    {
                        deleteMarkerLocal _x;
                    } foreach _markers;

                    _playerID = getPlayerUID player;
                    _event = ['SCOM_UPDATED', [_playerID,_side,_groups], "COMMAND_HANDLER", "OPS_GROUPS"] call ALIVE_fnc_event;
                    _event call ALIVE_fnc_SCOMTabletEventToClient;

                };

                case "OP_EDIT_WAYPOINT_MAP_CLICK": {

                    // on click of edit map draw planned waypoint

                    private ["_commandState","_button","_posX","_posY","_map","_position","_groupWaypoints","_plannedWaypoints",
                    "_selectedProfile","_markerPos","_m","_waypointOptions","_waypoints","_newWaypointOption","_newWaypointValue",
                    "_waypointList"];

                    _button = _args select 0 select 1;
                    _posX = _args select 0 select 2;
                    _posY = _args select 0 select 3;

                    if(_button == 0) then {

                        _commandState = [_logic,"commandState"] call MAINCLASS;

                        _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);

                        _position = _map ctrlMapScreenToWorld [_posX, _posY];

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _position];
                        ctrlMapAnimCommit _map;

                        _plannedWaypoints = [_commandState,"opsGroupPlannedWaypoints"] call ALIVE_fnc_hashGet;
                        _selectedProfile = [_commandState,"opsGroupSelectedProfile"] call ALIVE_fnc_hashGet;
						
						// store position
						
						_plannedWaypoints pushback _position;

                        // add to the waypoints array

                        _waypointOptions = [_commandState,"opsGroupWaypointsSelectedOptions"] call ALIVE_fnc_hashGet;
                        _waypoints = [_commandState,"opsGroupWaypointsSelectedValues"] call ALIVE_fnc_hashGet;

                        _newWaypointOption = format["Waypoint %1 [%2]",count(_waypoints),"MOVE"];
                        _newWaypointValue = [_position, 100] call ALIVE_fnc_createProfileWaypoint;

                        //_newWaypointValue call ALIVE_fnc_inspectHash;

                        _waypointOptions pushBack _newWaypointOption;
                        _waypoints pushBack (_newWaypointValue select 2);

                        _waypointList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointList);

                        _waypointList lbAdd _newWaypointOption;

                        // store updates in state

                        [_commandState,"opsGroupWaypointsSelectedOptions",_waypointOptions] call ALIVE_fnc_hashSet;
                        [_commandState,"opsGroupWaypointsSelectedValues",_waypoints] call ALIVE_fnc_hashSet;
                        [_commandState,"opsGroupPlannedWaypoints",_plannedWaypoints] call ALIVE_fnc_hashSet;
                        [_commandState,"opsGroupWaypointsPlanned",true] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        private["_backButton","_buttonR2","_buttonR3"];

                        _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                        _backButton ctrlShow false;

                        _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
                        _buttonR2 ctrlShow true;
                        _buttonR2 ctrlSetText "Clear Waypoint Changes";
                        _buttonR2 ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
                        _buttonR3 ctrlShow true;
                        _buttonR3 ctrlSetText "Apply Waypoint Changes";
                        _buttonR3 ctrlSetEventHandler ["MouseButtonClick", "['OPS_APPLY_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    };

                };

                case "OP_MAP_CLICK_NULL": {

                    // map click on reset
                    // do nothing

                };

                case "OPS_WAYPOINT_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue","_map"];

                    // on click of the ops group list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"opsGroupWaypointsSelectedOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsGroupWaypointsSelectedValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"opsGroupWaypointsSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"opsGroupWaypointsSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        // move the map to the selected profile

                        _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditRight);

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _selectedValue select 0];
                        ctrlMapAnimCommit _map;

                        [_logic, "enableWaypointSelected"] call MAINCLASS;

                    };
                };

                case "OPS_WP_TYPE_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue",
                    "_waypointSelectedIndex","_waypoints","_waypointSelected","_buttonR2","_buttonR3","_backButton"];

                    // on click of the ops group list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"opsWPTypeOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsWPTypeValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"opsWPTypeSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"opsWPTypeSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        _waypointSelectedIndex = [_commandState,"opsGroupWaypointsSelectedIndex"] call ALIVE_fnc_hashGet;
                        _waypoints = [_commandState,"opsGroupWaypointsSelectedValues"] call ALIVE_fnc_hashGet;
                        _waypointSelected = _waypoints select _waypointSelectedIndex;

                        _waypointSelected set [2,_selectedValue];
                        _waypoints set [_waypointSelectedIndex,_waypointSelected];
                        [_commandState,"opsGroupWaypointsSelectedValues",_waypoints] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                        _backButton ctrlShow false;

                        _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
                        _buttonR2 ctrlShow true;
                        _buttonR2 ctrlSetText "Clear Waypoint Changes";
                        _buttonR2 ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
                        _buttonR3 ctrlShow true;
                        _buttonR3 ctrlSetText "Apply Waypoint Changes";
                        _buttonR3 ctrlSetEventHandler ["MouseButtonClick", "['OPS_APPLY_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    };
                };

                case "OPS_WP_SPEED_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue",
                    "_waypointSelectedIndex","_waypoints","_waypointSelected","_buttonR2","_buttonR3","_backButton"];

                    // on click of the ops group list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"opsWPSpeedOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsWPSpeedValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"opsWPSpeedSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"opsWPSpeedSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        _waypointSelectedIndex = [_commandState,"opsGroupWaypointsSelectedIndex"] call ALIVE_fnc_hashGet;
                        _waypoints = [_commandState,"opsGroupWaypointsSelectedValues"] call ALIVE_fnc_hashGet;
                        _waypointSelected = _waypoints select _waypointSelectedIndex;

                        _waypointSelected set [3,_selectedValue];
                        _waypoints set [_waypointSelectedIndex,_waypointSelected];
                        [_commandState,"opsGroupWaypointsSelectedValues",_waypoints] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                        _backButton ctrlShow false;

                        _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
                        _buttonR2 ctrlShow true;
                        _buttonR2 ctrlSetText "Clear Waypoint Changes";
                        _buttonR2 ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
                        _buttonR3 ctrlShow true;
                        _buttonR3 ctrlSetText "Apply Waypoint Changes";
                        _buttonR3 ctrlSetEventHandler ["MouseButtonClick", "['OPS_APPLY_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    };
                };

                case "OPS_WP_FORMATION_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue",
                    "_waypointSelectedIndex","_waypoints","_waypointSelected","_buttonR2","_buttonR3","_backButton"];

                    // on click of the ops group list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"opsWPFormationOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsWPFormationValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"opsWPFormationSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"opsWPFormationSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        _waypointSelectedIndex = [_commandState,"opsGroupWaypointsSelectedIndex"] call ALIVE_fnc_hashGet;
                        _waypoints = [_commandState,"opsGroupWaypointsSelectedValues"] call ALIVE_fnc_hashGet;
                        _waypointSelected = _waypoints select _waypointSelectedIndex;

                        _waypointSelected set [6,_selectedValue];
                        _waypoints set [_waypointSelectedIndex,_waypointSelected];
                        [_commandState,"opsGroupWaypointsSelectedValues",_waypoints] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                        _backButton ctrlShow false;

                        _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
                        _buttonR2 ctrlShow true;
                        _buttonR2 ctrlSetText "Clear Waypoint Changes";
                        _buttonR2 ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
                        _buttonR3 ctrlShow true;
                        _buttonR3 ctrlSetText "Apply Waypoint Changes";
                        _buttonR3 ctrlSetEventHandler ["MouseButtonClick", "['OPS_APPLY_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    };
                };

                case "OPS_WP_BEHAVIOUR_LIST_SELECT": {

                    private ["_commandState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue",
                    "_waypointSelectedIndex","_waypoints","_waypointSelected","_buttonR2","_buttonR3","_backButton"];

                    // on click of the ops group list

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;

                    if(_selectedIndex >= 0) then {

                        // store the selected item in the state

                        _listOptions = [_commandState,"opsWPBehaviourOptions"] call ALIVE_fnc_hashGet;
                        _listValues = [_commandState,"opsWPBehaviourValues"] call ALIVE_fnc_hashGet;
                        _selectedOption = _listOptions select _selectedIndex;
                        _selectedValue = _listValues select _selectedIndex;

                        [_commandState,"opsWPBehaviourSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                        [_commandState,"opsWPBehaviourSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                        _waypointSelectedIndex = [_commandState,"opsGroupWaypointsSelectedIndex"] call ALIVE_fnc_hashGet;
                        _waypoints = [_commandState,"opsGroupWaypointsSelectedValues"] call ALIVE_fnc_hashGet;
                        _waypointSelected = _waypoints select _waypointSelectedIndex;

                        _waypointSelected set [8,_selectedValue];
                        _waypoints set [_waypointSelectedIndex,_waypointSelected];
                        [_commandState,"opsGroupWaypointsSelectedValues",_waypoints] call ALIVE_fnc_hashSet;

                        [_logic,"commandState",_commandState] call MAINCLASS;

                        _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                        _backButton ctrlShow false;

                        _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
                        _buttonR2 ctrlShow true;
                        _buttonR2 ctrlSetText "Clear Waypoint Changes";
                        _buttonR2 ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                        _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
                        _buttonR3 ctrlShow true;
                        _buttonR3 ctrlSetText "Apply Waypoint Changes";
                        _buttonR3 ctrlSetEventHandler ["MouseButtonClick", "['OPS_APPLY_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                    };
                };

                case "OPS_CLEAR_WAYPOINTS": {

                    private ["_commandState","_selectedProfile","_profileID","_playerID","_requestID","_event","_faction"];

                    // a group has been selected for waypoint editing

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;

                    _profileID = _selectedProfile select 0;

                    _faction = [_logic,"faction"] call MAINCLASS;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    // send the event to get further data from the command handler

                    _event = ['OPS_CLEAR_PROFILE_WAYPOINTS', [_requestID,_playerID,_profileID], "SCOM"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                    };
					
					// clear planned waypoints
					
					[_commandState,"opsGroupPlannedWaypoints", []] call ALiVE_fnc_hashSet;

                    // show waiting until response comes back

                    [_logic, "enableOpsWaiting", true] call MAINCLASS;

                };

                case "OPS_CANCEL_WAYPOINTS": {

                    private ["_commandState","_plannedWaypoints","_selectedProfile","_profileID","_event","_requestID","_playerID"];

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    // store updates in state

                    [_commandState,"opsGroupPlannedWaypoints",[]] call ALIVE_fnc_hashSet;

                    // send the event to get further data from the command handler\

                    _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;

                    _profileID = _selectedProfile select 0;

                    _faction = [_logic,"faction"] call MAINCLASS;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _event = ['OPS_GET_PROFILE_WAYPOINTS', [_requestID,_playerID,_profileID], "SCOM"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                    };

                    // show waiting until response comes back

                    [_logic, "enableOpsWaiting", true] call MAINCLASS;

                };

                case "OPS_APPLY_WAYPOINTS": {

                    private ["_commandState","_selectedProfile","_waypoints",
                    "_profileID","_playerID","_requestID","_event","_faction","_buttonL2","_buttonR1","_backButton"];

                    // a group has been selected for waypoint editing

                    _commandState = [_logic,"commandState"] call MAINCLASS;

                    _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;
                    _waypoints = [_commandState,"opsGroupWaypointsSelectedValues"] call ALIVE_fnc_hashGet;

                    _profileID = _selectedProfile select 0;

                    _faction = [_logic,"faction"] call MAINCLASS;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    // send the event to get further data from the command handler

                    _event = ['OPS_APPLY_PROFILE_WAYPOINTS', [_requestID,_playerID,_profileID,_waypoints], "SCOM"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
                    };
					
                    // reset planned waypoints
					
                    [_commandState,"opsGroupPlannedWaypoints", []] call ALiVE_fnc_hashSet;

                    // hide editing buttons

                    _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                    _backButton ctrlShow true;

                    _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
                    _buttonR2 ctrlShow false;

                    _buttonR1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR1);
                    _buttonR1 ctrlShow false;


                    // show waiting until response comes back

                    [_logic, "enableOpsWaiting", true] call MAINCLASS;

                };

                case "OPS_RESET": {

                    [_logic,"enableOpsInterface"] call MAINCLASS;

                };


            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                private ["_commandState"];
                _commandState = [_logic,"commandState"] call MAINCLASS;
                ["SCOM Action: %1",_action] call ALIVE_fnc_dump;
                _commandState call ALIVE_fnc_inspectHash;
            };
            // DEBUG -------------------------------------------------------------------------------------

        };
    };

    // INTEL ------------------------------------------------------------------------------------------------------------------------------

    case "enableIntelWaiting": {

        private ["_status","_intelTypeList"];

        _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);

        // show waiting text and disable selection lists for ops

        if (typename _args == "BOOL") then {

            if (_args) then {

                _status ctrlShow true;
                _status ctrlSetText "Waiting...";

                _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
                _intelTypeList ctrlShow false;

            } else {

                _status ctrlShow false;
                _status ctrlSetText "";

            };

        };

    };

    case "enableIntelInterface": {

        private ["_title","_backButton","_abortButton","_mainMap","_mainList","_intelTypeTitle","_intelTypeList","_editList",
        "_editMap","_rightMap","_buttonL1","_buttonL2","_buttonL3","_buttonR1","_buttonR2","_buttonR3","_markers","_waypointList",
        "_waypointTypeList","_waypointSpeedList","_waypointFormationList"];

        // prepare the interface elements for the intel interface

        _title = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Intel";

        _abortButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        _mainMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MainMap);
        _mainMap ctrlShow true;

        _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
        _intelTypeTitle ctrlShow true;

        _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
        _intelTypeList ctrlShow true;


        _editMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);
        _editMap ctrlShow false;

        _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _editList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditList);
        _editList ctrlShow false;

        _waypointList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointList);
        _waypointList ctrlShow false;

        _waypointTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointTypeList);
        _waypointTypeList ctrlShow false;

        _waypointSpeedList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointSpeedList);
        _waypointSpeedList ctrlShow false;

        _waypointFormationList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointFormationList);
        _waypointFormationList ctrlShow false;

        _waypointBehaviourList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointBehavourList);
        _waypointBehaviourList ctrlShow false;

        _rightMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MapRight);
        _rightMap ctrlShow false;

        _buttonL1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL1);
        _buttonL1 ctrlShow false;

        _buttonL2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL2);
        _buttonL2 ctrlShow false;

        _buttonL3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL3);
        _buttonL3 ctrlShow false;

        _buttonR1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR1);
        _buttonR1 ctrlShow false;

        _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
        _buttonR2 ctrlShow false;

        _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
        _buttonR3 ctrlShow false;

        // clear markers

        _markers = [_logic,"marker"] call MAINCLASS;

        {
            deleteMarkerLocal _x;
        } foreach _markers;

        // call reset

        [_logic,"resetIntel"] call MAINCLASS;

    };

    case "resetIntel": {

        private ["_commandState","_status","_intelTypeTitle","_intelTypeList","_intelTypeListOptions"];

        // display the intel type selection list to begin with

        _commandState = [_logic,"commandState"] call MAINCLASS;

        // hide the loading status text

        _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
        _status ctrlShow false;

        _status ctrlSetText "";

        _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
        _intelTypeTitle ctrlShow true;

        _intelTypeTitle ctrlSetText "Intel Type";

        _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);

        _intelTypeListOptions = [_commandState,"intelTypeOptions"] call ALIVE_fnc_hashGet;

        lbClear _intelTypeList;
        _intelTypeList lbSetCurSel -1;

        {
            _intelTypeList lbAdd format["%1", _x];
        } forEach _intelTypeListOptions;

        // set the event handler for the list selection event

        _intelTypeList ctrlSetEventHandler ["LBSelChanged", "['INTEL_TYPE_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

    };

    case "enableIntelOPCOMSelect": {

        private["_back","_commandState","_status","_opcomData","_status","_intelTypeTitle","_intelTypeList","_intelTypeListOptions"];

        // once the user has selected the OPCOM state analysis
        // display the available OPCOM sides

        // display the reset button so the user can restart

        _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
        _back ctrlShow true;

        _back ctrlSetText "Back";

        _back ctrlSetEventHandler ["MouseButtonClick", "['INTEL_RESET',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

        if(typeName _args == "ARRAY") then {

            _commandState = [_logic,"commandState"] call MAINCLASS;

            // hide the loading status text

            _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
            _status ctrlShow false;

            _status ctrlSetText "";

            _opcomData = _args select 1;

            if(count(_opcomData) > 0) then {

                // display the opcom type selection list

                _opcomOptions = [];

                {
                    _sideDisplay = [_x] call ALIVE_fnc_sideTextToLong;
                    _opcomOptions pushBack format["%1 Commander",_sideDisplay];
                } foreach _opcomData;

                [_commandState,"intelOPCOMOptions",_opcomOptions] call ALIVE_fnc_hashSet;
                [_commandState,"intelOPCOMValues",_opcomData] call ALIVE_fnc_hashSet;

                [_logic,"commandState",_commandState] call MAINCLASS;

                _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
                _intelTypeTitle ctrlShow true;

                _intelTypeTitle ctrlSetText "Select Commander to display";

                _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
                _intelTypeList ctrlShow true;

                lbClear _intelTypeList;
                _intelTypeList lbSetCurSel -1;

                {
                    _intelTypeList lbAdd format["%1", _x];
                } forEach _opcomOptions;

                // set the event handler for the list selection event

                _intelTypeList ctrlSetEventHandler ["LBSelChanged", "['INTEL_OPCOM_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

            }else{

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow true;

                _status ctrlSetText "No OPCOM instances found";

            };

        };

    };

    case "enableIntelUnitMarking": {

        private["_back","_commandState","_profileBySide","_profileCount","_markers","_m","_intelTypeTitle","_status","_intelLimit","_side","_faction","_leaderSide","_leaderFaction","_display"];

        // perform unit marking display

        // display the reset button so the user can restart

        _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
        _back ctrlShow true;

        _back ctrlSetText "Back";

        _back ctrlSetEventHandler ["MouseButtonClick", "['INTEL_RESET',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

        if(typeName _args == "ARRAY") then {

            // hide the selection list title

            _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
            _intelTypeTitle ctrlShow false;

            // hide the loading status text

            _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
            _status ctrlShow false;

            _commandState = [_logic,"commandState"] call MAINCLASS;

            _intelLimit = [_logic,"intelLimit"] call MAINCLASS;
            _side = [_logic,"side"] call MAINCLASS;
            _faction = [_logic,"faction"] call MAINCLASS;

            _profileBySide = _args select 1;
            _knownEnemiesBySide = _args select 2;
            _profileCount = 0;
            _markers = [];

            // display the markers for inactive profiles

            {
                private ["_typePrefix","_color"];
                private _sideGroupsByType = _x;

                switch (_forEachIndex) do {
                    case 0: {
                        _typePrefix = "o";
                        _color = "ColorOPFOR";
                    };
                    case 1: {
                        _typePrefix = "b";
                        _color = "ColorBLUFOR";
                    };
                    case 2: {
                         _color = "ColorIndependent";
                         _typePrefix = "n";
                    };
                };

                {
                    _x params ["_infantry","_motorised","_mechanized","_armor","_air","_sea","_artillery","_AAA"];

                    // create markers for each profile type

                    {
                        _position = _x;
                        _profileMarker = format["%1_inf",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE,_profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _infantry;

                    {
                        _position = _x;
                        _profileMarker = format["%1_motor_inf",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _motorised;

                    {
                        _position = _x;
                        _profileMarker = format["%1_mech_inf",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _mechanized;

                    {
                        _position = _x;
                        _profileMarker = format["%1_armor",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _armor;

                    {
                        _position = _x;
                        _profileMarker = format["%1_air",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _air;

                    {
                        _position = _x;
                        _profileMarker = format["%1_unknown",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _sea;

                    {
                        _position = _x;
                        _profileMarker = format["%1_art",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _artillery;

                    {
                        _position = _x;
                        _profileMarker = format["%1_mech_inf",_typePrefix];

                        _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;

                        _markers pushback _m;
                        _profileCount = _profileCount + 1;

                        false
                    } count _AAA;
                    false
                } count _sideGroupsByType;
            } foreach _profileBySide;

            {
                private ["_color","_type"];
                private _sideProfiles = _x;

                switch (_forEachIndex) do {
                    case 0: {
                        _color = "ColorOPFOR";
                        _type = "o_unknown";
                    };
                    case 1: {
                        _color = "ColorBLUFOR";
                        _type = "b_unknown";
                    };
                    case 2: {
                         _color = "ColorIndependent";
                         _type = "n_unknown";
                    };
                };

                {
                    private _position = _x;

                    _m = createMarkerLocal [format[MTEMPLATE, _profileCount], _position];
                    _m setMarkerTypeLocal _type;
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [.5, .5];
                    _m setMarkerColorLocal _color;
                    
                    _markers pushback _m;
                    _profileCount = _profileCount + 1;

                    false
                } count _sideProfiles;
            } foreach _knownEnemiesBySide;
/*
            // display the markers for spawned groups

            {
                _leaderSide = str(side (leader _x));
                _leaderFaction = faction (leader _x);
                _display = false;

                switch(_intelLimit) do {
                    case "SIDE": {
                        if(_side == _leaderSide) then {
                            _display = true;
                        };
                    };
                    case "FACTION": {
                        if(_faction == _leaderFaction) then {
                            _display = true;
                        };
                    };
                    case "ALL": {
                        _display = true;
                    };
                };

            	if (_display) then {

            		_m = createMarkerLocal [format[MTEMPLATE, format["%1_active", _forEachIndex]], position (leader _x)];
            		_m setMarkerSizeLocal [.7,.7];

            		switch (_leaderSide) do {
            			case "EAST": {
            				_m setMarkerTypeLocal "o_unknown";
            				_m setMarkerColorLocal "ColorOPFOR";
            			};
            			case "WEST": {
            				_m setMarkerTypeLocal "b_unknown";
            				_m setMarkerColorLocal "ColorBLUFOR";
            			};
            			case "GUER": {
            				_m setMarkerTypeLocal "x_unknown";
            				_m setMarkerColorLocal "ColorIndependent";
            			};
            		};

            		_markers pushback _m;
            	};

            } forEach allGroups;
*/
            // store the marker state for clearing later

            [_logic,"marker",_markers] call MAINCLASS;

        };

    };

    case "enableIntelIMINT": {

        private["_commandState","_status","_back","_sources","_intelTypeTitle","_intelTypeList","_listValues"];

        // displays list of IMINT sources

        _commandState = [_logic,"commandState"] call MAINCLASS;

        _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
        _status ctrlShow false;

        if(typeName _args == "ARRAY") then {

            _listValues = [];
            _sources = _args select 1;
            

            _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
            _intelTypeTitle ctrlShow true;

            _intelTypeTitle ctrlSetText "Select IMINT source to display";

            _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
            _intelTypeList ctrlShow true;

            lbClear _intelTypeList;
            _intelTypeList lbSetCurSel -1;

            if (count _sources > 0) then {
                {
                    _x params ["_obj","_name"];

                    if (isnil "_name") then {
                        _intelTypeList lbAdd (name _obj);
                    } else {
                        _intelTypeList lbAdd _name;
                    };

                    _listValues pushback _obj;
                } foreach _sources;

            } else {
                _intelTypeTitle ctrlSetText "No IMINT sources found";
            };

            [_commandState,"intelListValues", _listValues] call ALIVE_fnc_hashSet;
            _intelTypeList ctrlSetEventHandler ["LBSelChanged", "['INTEL_IMINT_SOURCE_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];
        };

        // display the reset button so the user can restart

        _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
        _back ctrlShow true;

        _back ctrlSetText "Back";

        _back ctrlSetEventHandler ["MouseButtonClick", "['INTEL_RESET',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

    };

    case "enableIntelOPCOMObjectives": {

        private["_commandState","_opcomData","_status","_intelTypeTitle","_intelTypeList","_intelTypeListOptions"];

        // preform OPCOM objective display

        if(typeName _args == "ARRAY") then {

            _commandState = [_logic,"commandState"] call MAINCLASS;

            _opcomData = _args select 1;

            if(count(_opcomData) > 0) then {

                // hide the selection list title

                _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
                _intelTypeTitle ctrlShow false;

                // hide the loading status text

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow false;


                _opcomSide = [_commandState,"intelOPCOMSelectedValue"] call ALIVE_fnc_hashGet;

                private ["_center","_size","_tacom_state","_opcom_state","_sections","_objectiveID","_alpha","_markers","_marker","_color","_dir","_position","_icon","_text","_m","_profileMarker","_opcomColor"];

                _color = "ColorYellow";
                _profileMarker = "b_unknown";

                _markers = [];

                // set the side color
                switch(_opcomSide) do {
                    case "EAST":{
                        _color = "ColorOPFOR";
                        _profileMarker = "o_unknown";
                    };
                    case "WEST":{
                        _color = "ColorBLUFOR";
                        _profileMarker = "b_unknown";
                    };
                    case "CIV":{
                        _color = "ColorYellow";
                        _profileMarker = "b_unknown";
                    };
                    case "GUER":{
                        _color = "ColorIndependent";
                        _profileMarker = "n_unknown";
                    };
                    default {
                        _color = "ColorYellow";
                    };
                };

                {
                    _size = _x select 0;
                    _center = _x select 1;
                    _tacom_state = _x select 2;
                    _opcom_state = _x select 3;
                    _sections = _x select 4;

                    _opcomColor = "ColorWhite";

                    //-- Orders
                    switch (_opcom_state) do {
                        case "unassigned": {
                            _opcomColor = "ColorWhite"
                        };
                        case "idle": {
                            _opcomColor = "ColorYellow"
                        };
                        case "reserve": {
                            _opcomColor = "ColorGreen"
                        };
                        case "defend": {
                            _opcomColor = "ColorBlue"
                        };
                        case "attack": {
                            _opcomColor = "ColorRed"
                        };
                        default {
                            _opcomColor = "ColorWhite"
                        };
                    };

                    _alpha = 1;

                    // create the objective area marker
                    _m = createMarkerLocal [format[MTEMPLATE, _forEachIndex], _center];
                    _m setMarkerShapeLocal "Ellipse";
                    _m setMarkerBrushLocal "FDiagonal";
                    _m setMarkerSizeLocal [_size, _size];
                    _m setMarkerColorLocal _opcomColor;
                    _m setMarkerAlphaLocal _alpha;

                    _markers pushback _m;

                    _icon = "EMPTY";
                    _text = "";

                    _objectiveID = _forEachIndex;

                    // create the profile marker
                    {
                        _position = _x select 0;
                        _dir = _x select 1;

                        // create section marker
                        _m = createMarkerLocal [format[MTEMPLATE, format["%1%2_profile", _objectiveID, _forEachIndex]], _position];
                        _m setMarkerShapeLocal "ICON";
                        _m setMarkerSizeLocal [0.5,0.5];
                        _m setMarkerTypeLocal _profileMarker;
                        _m setMarkerColorLocal _color;
                        _m setMarkerAlphaLocal _alpha;

                        _markers pushback _m;

                        if!(isNil "_tacom_state") then {
                            switch(_tacom_state) do {
                                case "recon":{

                                    // create direction marker
                                    _m = createMarkerLocal [format[MTEMPLATE, format["%1%2_dir", _objectiveID, _forEachIndex]], _position getpos [100, _dir]];
                                    _m setMarkerShapeLocal "ICON";
                                    _m setMarkerSizeLocal [0.5,0.5];
                                    _m setMarkerTypeLocal "mil_arrow";
                                    _m setMarkerColorLocal _color;
                                    _m setMarkerAlphaLocal _alpha;
                                    _m setMarkerDirLocal _dir;

                                    _markers pushback _m;

                                };
                                case "capture":{

                                    // create direction marker
                                    _m = createMarkerLocal [format[MTEMPLATE, format["%1%2_dir", _objectiveID, _forEachIndex]], _position getpos [100, _dir]];
                                    _m setMarkerShapeLocal "ICON";
                                    _m setMarkerSizeLocal [0.5,0.5];
                                    _m setMarkerTypeLocal "mil_arrow2";
                                    _m setMarkerColorLocal _color;
                                    _m setMarkerAlphaLocal _alpha;
                                    _m setMarkerDirLocal _dir;

                                    _markers pushback _m;

                                };
                            };
                        };

                    } forEach _sections;

                    if!(isNil "_tacom_state") then {
                        switch(_tacom_state) do {
                            case "reserve":{
                                _icon = "mil_marker";
                                _text = " occupied";
                            };
                            case "defend":{
                                _icon = "mil_marker";
                                _text = " occupied";
                            };
                            case "recon":{
                                _icon = "EMPTY";
                                _text = " sighting";
                            };
                            case "capture":{
                                _icon = "mil_warning";
                                _text = " captured";
                            };
                        };
                    };

                    // create type marker
                    _m = createMarkerLocal [format[MTEMPLATE, format["%1_type", _objectiveID]], _center];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5, 0.5];
                    _m setMarkerTypeLocal _icon;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal _text;

                    _markers pushback _m;

                } forEach _opcomData;

                // store the marker state for clearing later

                [_logic,"marker",_markers] call MAINCLASS;


            }else{

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow true;

                _status ctrlSetText "No OPCOM instances found";

            };
        };
    };


    // OPS ------------------------------------------------------------------------------------------------------------------------------


    case "enableOpsWaiting": {

        private ["_status"];

        _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);

        // show waiting text and disable selection lists for ops

        if (typename _args == "BOOL") then {

            if (_args) then {

                _status ctrlShow true;
                _status ctrlSetText "Waiting...";

            } else {

                _status ctrlShow false;
                _status ctrlSetText "";

            };

        };

    };

    case "enableOpsInterface": {

        private ["_commandState","_isInstantJoinMode","_isSpectateMode","_title","_backButton","_abortButton","_mainList","_editMap","_mainMap","_leftMap",
        "_intelTypeTitle","_intelTypeList","_buttonL1","_buttonL2","_buttonL3","_buttonR1","_buttonR2","_buttonR3",
        "_editList","_editMap","_waypointList","_waypointTypeList","_waypointSpeedList","_waypointFormationList","_waypointBehaviourList"];

        // prepare the interface elements for the ops interface

        _title = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Operations";

        _abortButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        // check instant join mode

        _commandState = [_logic,"commandState"] call MAINCLASS;

        _isInstantJoinMode = [_commandState,"opsGroupInstantJoin"] call ALIVE_fnc_hashGet;
        _isSpectateMode = [_commandState,"opsGroupSpectate"] call ALIVE_fnc_hashGet;

        if(_isInstantJoinMode || _isSpectateMode) then {

            _editList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditList);
            _editList ctrlShow false;

            _editMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);
            _editMap ctrlShow false;

            _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
            _back ctrlShow true;

            if(_isInstantJoinMode) then {

                _back ctrlSetText "Cancel Instant Join";

                _back ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_JOIN_GROUP',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

            };

            if(_isSpectateMode) then {

                _back ctrlSetText "Cancel Spectate";

                _back ctrlSetEventHandler ["MouseButtonClick", "['OPS_CANCEL_SPECTATE_GROUP',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

            };

        }else{

            _editList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditList);
            _editList ctrlShow true;

            _editMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);
            _editMap ctrlShow true;

            _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
            _backButton ctrlShow false;

            _editMap ctrlSetEventHandler ["MouseButtonDown", "['OP_MAP_CLICK_NULL',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

        };

        _rightMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MapRight);
        _rightMap ctrlShow false;

        _waypointList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointList);
        _waypointList ctrlShow false;

        _waypointTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointTypeList);
        _waypointTypeList ctrlShow false;

        _waypointSpeedList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointSpeedList);
        _waypointSpeedList ctrlShow false;

        _waypointFormationList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointFormationList);
        _waypointFormationList ctrlShow false;

        _waypointBehaviourList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointBehavourList);
        _waypointBehaviourList ctrlShow false;

        _mainMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MainMap);
        _mainMap ctrlShow false;

        _intelTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
        _intelTypeTitle ctrlShow false;

        _intelTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
        _intelTypeList ctrlShow false;

        _buttonL1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL1);
        _buttonL1 ctrlShow false;

        _buttonL2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL2);
        _buttonL2 ctrlShow false;

        _buttonL3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL3);
        _buttonL3 ctrlShow false;

        _buttonR1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR1);
        _buttonR1 ctrlShow false;

        _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
        _buttonR2 ctrlShow false;

        _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
        _buttonR3 ctrlShow false;

        // clear markers

        _markers = [_logic,"marker"] call MAINCLASS;

        {
            deleteMarkerLocal _x;
        } foreach _markers;

        // call reset

        if!(_isInstantJoinMode || _isSpectateMode) then {

            [_logic,"resetOps"] call MAINCLASS;

        };

        // add map draw eh

        _editMap ctrlAddEventHandler ["Draw",{
            [ALIVE_SUP_COMMAND,"opsDrawWaypoints", _this] call ALiVE_fnc_SCOM;
        }];
    };

    case "resetOps": {

        private ["_commandState","_playerID","_requestID","_opsLimit","_side","_faction","_event","_editList",
        "_groupWaypoints","_plannedWaypoints"];

        // display the ops opcom side selection list to begin with

        _commandState = [_logic,"commandState"] call MAINCLASS;
        _opsLimit = [_logic,"opsLimit"] call MAINCLASS;
        _side = [_logic,"side"] call MAINCLASS;
        _faction = [_logic,"faction"] call MAINCLASS;

        _playerID = getPlayerUID player;
        _requestID = format["%1_%2",_faction,floor(time)];

        // reset the waypoint data

        [_commandState,"opsGroupSelectedProfile",[]] call ALIVE_fnc_hashSet;
        [_commandState,"opsGroupWaypoints",[]] call ALIVE_fnc_hashSet;
        [_commandState,"opsGroupPlannedWaypoints",[]] call ALIVE_fnc_hashSet;
        [_commandState,"opsGroupWaypointsPlanned",false] call ALIVE_fnc_hashSet;


        //[_logic,"commandState",_commandState] call MAINCLASS;

        // clear the group list

        _editList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditList);

        lbClear _editList;

        _editList lbSetCurSel 0;

        // send the event to get further data from the command handler

        _event = ['OPS_DATA_PREPARE', [_requestID,_playerID,_opsLimit,_side,_faction], "SCOM"] call ALIVE_fnc_event;

        if(isServer) then {
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
        }else{
            [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
        };

        // show waiting until response comes back

        [_logic, "enableOpsWaiting", true] call MAINCLASS;

    };

    case "enableOpsOPCOMSelect": {

        private["_back","_commandState","_status","_opcomData","_status","_opsTypeTitle","_opsTypeList","_opcomOptions","_sideDisplay"];

        // once the list of opcom instances has been loaded
        // display the available OPCOM sides

        // display the reset button so the user can restart

        _back = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
        _back ctrlShow true;

        _back ctrlSetText "Back";

        _back ctrlSetEventHandler ["MouseButtonClick", "['OPS_RESET',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

        if(typeName _args == "ARRAY") then {

            _commandState = [_logic,"commandState"] call MAINCLASS;

            // hide the loading status text

            _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
            _status ctrlShow false;

            _status ctrlSetText "";

            _opcomData = _args select 1;

            if(count(_opcomData) > 0) then {

                // display the opcom type selection list

                _opcomOptions = [];

                {
                    _sideDisplay = [_x] call ALIVE_fnc_sideTextToLong;
                    _opcomOptions pushBack format["%1 Commander",_sideDisplay];
                } foreach _opcomData;

                [_commandState,"opsOPCOMOptions",_opcomOptions] call ALIVE_fnc_hashSet;
                [_commandState,"opsOPCOMValues",_opcomData] call ALIVE_fnc_hashSet;

                [_logic,"commandState",_commandState] call MAINCLASS;

                _opsTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
                _opsTypeTitle ctrlShow true;

                _opsTypeTitle ctrlSetText "Select Commander to use";

                _opsTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
                _opsTypeList ctrlShow true;

                lbClear _opsTypeList;
                _opsTypeList lbSetCurSel -1;

                {
                    _opsTypeList lbAdd format["%1", _x];
                } forEach _opcomOptions;

                // set the event handler for the list selection event

                _opsTypeList ctrlSetEventHandler ["LBSelChanged", "['OPS_OPCOM_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

            }else{

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow true;

                _status ctrlSetText "No OPCOM instances found";

            };

        };

    };

    case "enableOpsHighCommand": {

        private ["_commandState","_status","_selectedSide","_groupData","_editList","_options","_values",
        "_opsTypeTitle","_opsTypeList","_rightMap","_mainMap","_profileID","_position","_label","_typePrefix"];

        // populate group list and map markers

        if(typeName _args == "ARRAY") then {

            _commandState = [_logic,"commandState"] call MAINCLASS;

            _selectedSide = _args select 1;
            _groupData = _args select 2;

            if(count(_groupData) > 0) then {

                // clear the ops type selection list and title

                _opsTypeTitle = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeTitle);
                _opsTypeTitle ctrlShow false;

                _opsTypeTitle ctrlSetText "";

                _opsTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelTypeList);
                _opsTypeList ctrlShow false;

                lbClear _opsTypeList;
                _opsTypeList lbSetCurSel -1;

                // store profiles to state

                [_commandState,"opsGroups", _groupData] call ALIVE_fnc_hashSet;

                // set list items by category type

                _groupData params ["_infantry","_motorised","_mechanized","_armor","_air","_sea","_artillery","_AAA"];

                _editList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditList);
                _editList ctrlShow true;

                lbClear _editList;
                _editList lbSetCurSel 0;

                _options = [];
                _values = [];

                _color = "ColorYellow";
                _typePrefix = "n";
                _alpha = 0.7;

                _markers = [];

                // set the side color
                switch(_selectedSide) do {
                    case "EAST":{
                        _color = "ColorOPFOR";
                        _typePrefix = "o";
                    };
                    case "WEST":{
                        _color = "ColorBLUFOR";
                        _typePrefix = "b";
                    };
                    case "CIV":{
                        _color = "ColorYellow";
                        _typePrefix = "n";
                    };
                    case "GUER":{
                        _color = "ColorIndependent";
                        _typePrefix = "n";
                    };
                    default {
                        _color = "ColorYellow";
                    };
                };

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Infantry Group %1", _label];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_inf",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE,_label], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _infantry;

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Motorised Group %1", _label];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_motor_inf",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE, format["%1", _label]], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _motorised;

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Mechanized Group %1", _label];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_mech_inf",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE, format["%1", _label]], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _mechanized;

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Armor Group %1", _label];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_armor",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE, format["%1", _label]], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _armor;

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Air Group %1", _label];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_air",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE, format["%1", _label]], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _air;

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Naval Group %1", _label];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_unknown",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE, format["%1", _label]], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _sea;

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Artillery Group %1", _label];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_art",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE, format["%1", _label]], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _artillery;

                {
                    _profileID = _x select 0;
                    _position = _x select 1;
                    _label = _profileID splitString "_";
                    _label = _label select ((count _label) - 1);

                    _option = format ["Anti-Air Group %1", _forEachIndex + 1];
                    _options pushBack (_option);
                    _values pushBack (_x);

                    _editList lbAdd _option;

                    _profileMarker = format["%1_mech_inf",_typePrefix];

                    _m = createMarkerLocal [format[MTEMPLATE, format["%1", _label]], _position];
                    _m setMarkerShapeLocal "ICON";
                    _m setMarkerSizeLocal [0.5,0.5];
                    _m setMarkerTypeLocal _profileMarker;
                    _m setMarkerColorLocal _color;
                    _m setMarkerAlphaLocal _alpha;
                    _m setMarkerTextLocal format["e%1",_label];

                    _markers pushback _m;

                } forEach _AAA;


                // store the marker state for clearing later

                [_logic,"marker",_markers] call MAINCLASS;

                // store the current values and options to state

                [_commandState,"opsGroupsOptions",_options] call ALIVE_fnc_hashSet;
                [_commandState,"opsGroupsValues",_values] call ALIVE_fnc_hashSet;

                // set the event handler for the list selection event

                _editList ctrlSetEventHandler ["LBSelChanged", "['OPS_GROUP_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                // set the event handler for the map selection event

                _editMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);

                _editMap ctrlSetEventHandler ["MouseButtonDown", "['OP_EDIT_MAP_CLICK',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow true;

                _status ctrlSetText "";

            }else{

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow true;

                _status ctrlSetText "No OPCOM instances found";

            };

        };

    };

    case "enableGroupSelected": {

        private ["_commandState","_selectedProfile","_profileID","_playerID","_requestID","_event","_faction"];

        // a group has been selected

        _commandState = [_logic,"commandState"] call MAINCLASS;

        _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;

        _profileID = _selectedProfile select 0;

        _faction = [_logic,"faction"] call MAINCLASS;

        _playerID = getPlayerUID player;
        _requestID = format["%1_%2",_faction,floor(time)];

        // send the event to get further data from the command handler

        _event = ['OPS_GET_PROFILE', [_requestID,_playerID,_profileID], "SCOM"] call ALIVE_fnc_event;

        if(isServer) then {
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
        }else{
		    [_event] remoteExecCall ["ALIVE_fnc_addEventToServer",2];
        };

        // show waiting until response comes back

        [_logic, "enableOpsWaiting", true] call MAINCLASS;

    };

    case "enableOpsProfile": {

        private["_buttonR3","_commandState","_status","_profile","_waypoints","_groupWaypoints",
        "_position","_markerPos","_profilePosition"];

        // once the profile data has returned from the command handler
        // display the profiles waypoints

        if(typeName _args == "ARRAY") then {

            _commandState = [_logic,"commandState"] call MAINCLASS;

            // hide the loading status text

            _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
            _status ctrlShow false;

            _status ctrlSetText "";

            _profile = _args select 1;

            /*
            _profileData pushBack (_profile select 2 select 1); // active
            _profileData pushBack (_profile select 2 select 3); // side
            _profileData pushBack (_profile select 2 select 2); // position
            _profileData pushBack (_profile select 2 select 13); // group
            _profileData pushBack (_profile select 2 select 16); // waypoints
            */

            if(count(_profile) > 0) then {

                // plot the waypoints on the map

                _waypoints = _profile select 4;
                _profilePosition = _profile select 2;

                _groupWaypoints = [];

                {
                    _position = _x;
					_groupWaypoints pushback _position;
                } forEach _waypoints;

                [_commandState,"opsGroupSelectedProfile",_profile] call ALIVE_fnc_hashSet;
                [_commandState,"opsGroupWaypoints",_groupWaypoints] call ALIVE_fnc_hashSet;

                // enable interface elements for interacting with profile

                private["_allowSpectate","_allowJoin","_buttonL1","_buttonR1","_buttonL2"];

                _buttonL1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL1);
                _buttonL1 ctrlShow true;
                _buttonL1 ctrlSetText "Edit Group Waypoints";
                _buttonL1 ctrlSetEventHandler ["MouseButtonClick", "['OPS_EDIT_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                _allowSpectate = [_logic,"scomOpsAllowSpectate"] call MAINCLASS;
                _allowJoin = [_logic,"scomOpsAllowInstantJoin"] call MAINCLASS;

                if(_allowJoin) then {

                    _buttonR1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR1);
                    _buttonR1 ctrlShow true;
                    _buttonR1 ctrlSetText "Instant Join Group";
                    _buttonR1 ctrlSetEventHandler ["MouseButtonClick", "['OPS_JOIN_GROUP',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                };

                if(_allowSpectate) then {

                    _buttonL2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL2);
                    _buttonL2 ctrlShow true;
                    _buttonL2 ctrlSetText "Spectate Group";
                    _buttonL2 ctrlSetEventHandler ["MouseButtonClick", "['OPS_SPECTATE_GROUP',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                };

                [_logic,"commandState",_commandState] call MAINCLASS;


            }else{

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow true;

                _status ctrlSetText "No group found";

            };

        };

    };

    case "enableGroupWaypointEdit": {

        private["_buttonR3","_commandState","_status","_profile","_waypoints","_groupWaypoints","_position",
        "_markerPos","_rightMap","_editMap","_profilePosition","_waypointsOptions","_waypointsValues","_option","_waypointList",
        "_profileActive","_opsWPTypeOptions","_opsWPTypeValues","_selectedProfile","_profileID","_label","_marker"];

        // once the profile data has returned from the command handler
        // display the profiles waypoints

        if(typeName _args == "ARRAY") then {

            _commandState = [_logic,"commandState"] call MAINCLASS;

            // hide the loading status text

            _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
            _status ctrlShow false;

            _status ctrlSetText "";

            _profile = _args select 1;

            /*
            _profileData pushBack (_profile select 2 select 1); // active
            _profileData pushBack (_profile select 2 select 3); // side
            _profileData pushBack (_profile select 2 select 2); // position
            _profileData pushBack (_profile select 2 select 13); // group
            _profileData pushBack (_profile select 2 select 16); // waypoints
            */

            if(count(_profile) > 0) then {

                _editList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditList);
                _editList ctrlShow false;

                _waypointList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointList);
                _waypointList ctrlShow true;

                lbClear _waypointList;
                _waypointList lbSetCurSel -1;

                _rightMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MapRight);
                _rightMap ctrlShow false;

                _editMap = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);
                _editMap ctrlShow true;

                _editMap ctrlSetEventHandler ["MouseButtonDown", "['OP_EDIT_WAYPOINT_MAP_CLICK',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                _profilePosition = _profile select 2;

                ctrlMapAnimClear _editMap;
                _editMap ctrlMapAnimAdd [0.5, ctrlMapScale _editMap, _profilePosition];
                ctrlMapAnimCommit _editMap;

                // plot the waypoints on the map

                _waypoints = _profile select 4;

                _groupWaypoints = [];

                _waypointsOptions = [];
                _waypointsValues = [];

                {
                    _option = format["Waypoint %1 [%2]",_forEachIndex,_x select 2];

                    _waypointsOptions pushBack _option;
                    _waypointsValues pushBack _x;

                    _waypointList lbAdd _option;

                    _position = _x select 0;

					_groupWaypoints pushback _position;

                } forEach _waypoints;


                // set the event handler for the list selection event

                _waypointList ctrlSetEventHandler ["LBSelChanged", "['OPS_WAYPOINT_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                // store the current values and options to state

                _profileActive = _profile select 0;

                if(_profileActive) then {

                    _opsWPTypeOptions = [_commandState,"opsWPNonProfiledTypeOptions"] call ALIVE_fnc_hashGet;
                    _opsWPTypeValues = [_commandState,"opsWPNonProfiledTypeValues"] call ALIVE_fnc_hashGet;

                }else{

                    _opsWPTypeOptions = [_commandState,"opsWPProfiledTypeOptions"] call ALIVE_fnc_hashGet;
                    _opsWPTypeValues = [_commandState,"opsWPProfiledTypeValues"] call ALIVE_fnc_hashGet;

                };

                [_commandState,"opsWPTypeOptions",_opsWPTypeOptions] call ALIVE_fnc_hashSet;
                [_commandState,"opsWPTypeValues",_opsWPTypeValues] call ALIVE_fnc_hashSet;

                [_commandState,"opsGroupWaypointsSelectedOptions",_waypointsOptions] call ALIVE_fnc_hashSet;
                [_commandState,"opsGroupWaypointsSelectedValues",_waypointsValues] call ALIVE_fnc_hashSet;

                [_commandState,"opsGroupSelectedProfile",_profile] call ALIVE_fnc_hashSet;
                [_commandState,"opsGroupWaypoints",_groupWaypoints] call ALIVE_fnc_hashSet;
                
/*
                // move profile marker to refreshed position
                _selectedIndex = [_commandState,"opsGroupsSelectedIndex"] call ALIVE_fnc_hashGet;
                _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;
                _profileID = _selectedProfile select 0;
                _opsGroupsValues = [_commandState,"opsGroupsValues"] call ALIVE_fnc_hashGet;
                _opsGroupsValues set [_selectedIndex,[_profileID,_profilePosition]];
                _label = _profileID splitString "_";
                _label = _label select ((count _label) - 1);

                _marker = format [MTEMPLATE,_label];
                _marker setMarkerPos _profilePosition;
*/

                //[_logic,"commandState",_commandState] call MAINCLASS;


                // enable interface elements for interacting with profile

                private["_buttonR1","_buttonL2","_buttonR2","_buttonR3","_waypointTypeList","_waypointSpeedList","_waypointFormationList","_waypointBehaviourList"];

                _buttonR1 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR1);
                _buttonR1 ctrlShow true;
                _buttonR1 ctrlSetText "Clear All Waypoints";
                _buttonR1 ctrlSetEventHandler ["MouseButtonClick", "['OPS_CLEAR_WAYPOINTS',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

                _backButton = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_SubMenuBack);
                _backButton ctrlShow true;

                // disable interface elements for interacting with profile

                _buttonL2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BL2);
                _buttonL2 ctrlShow false;

                _buttonR2 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR2);
                _buttonR2 ctrlShow false;

                _buttonR3 = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_BR3);
                _buttonR3 ctrlShow false;

                _waypointTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointTypeList);
                _waypointTypeList ctrlShow false;

                lbClear _waypointTypeList;
                _waypointTypeList lbSetCurSel -1;
                _waypointTypeList ctrlSetEventHandler ["LBSelChanged", ""];

                _waypointSpeedList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointSpeedList);
                _waypointSpeedList ctrlShow false;

                lbClear _waypointSpeedList;
                _waypointSpeedList lbSetCurSel -1;
                _waypointSpeedList ctrlSetEventHandler ["LBSelChanged", ""];

                _waypointFormationList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointFormationList);
                _waypointFormationList ctrlShow false;

                lbClear _waypointFormationList;
                _waypointFormationList lbSetCurSel -1;
                _waypointFormationList ctrlSetEventHandler ["LBSelChanged", ""];

                _waypointBehaviourList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointBehavourList);
                _waypointBehaviourList ctrlShow false;

                lbClear _waypointBehaviourList;
                _waypointBehaviourList lbSetCurSel -1;
                _waypointBehaviourList ctrlSetEventHandler ["LBSelChanged", ""];


            }else{

                _status = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelStatus);
                _status ctrlShow true;

                _status ctrlSetText "No group found";

            };

        };

    };
	
	case "opsDrawWaypoints": {
        private ["_map","_commandState","_selectedProfile","_profilePos","_waypoint","_waypointPos",
        "_waypoints","_plannedWaypoints"];
		
		disableSerialization;
		
        _map = _args select 0;

        // Get selected profile
		
        _commandState = [_logic,"commandState"] call MAINCLASS;
        _selectedProfile = [_commandState,"opsGroupsSelectedValue"] call ALIVE_fnc_hashGet;

        if (count _selectedProfile > 0) then {
            _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_EditMap);
            _profilePos = _selectedProfile select 1;
			
            // Draw active waypoints in blue

            _waypoints = [_commandState,"opsGroupWaypoints", []] call ALiVE_fnc_hashGet;
			
            {
                if (_forEachIndex > 0) then {
                    // Draw line from waypoint to waypoint
                    _map drawLine [
                        _waypoints select (_forEachIndex - 1),
                        _x,
                        [0.427,0.463,0.988,1]
                    ];
                } else {
                    // Draw line from profile to waypoint
                    _map drawLine [
                        _profilePos,
                        _x,
                        [0.427,0.463,0.988,1]
                    ];
                };
            } foreach _waypoints;
		
            // Draw planned waypoints in green
			
            _plannedWaypoints = [_commandState,"opsGroupPlannedWaypoints", []] call ALiVE_fnc_hashGet;
			
            {
                if (_forEachIndex > 0) then {
                    // Draw line from planned waypoint to planned waypoint
                    _map drawLine [
                        _plannedWaypoints select (_forEachIndex - 1),
                        _x,
                        [0.502,1,0.635,1]
                    ];
                } else {
                    if (count _waypoints > 0) then {
                        // Draw line from last waypoint to planned waypoint
                        _map drawLine [
                            _waypoints select (count _waypoints - 1),
                            _x,
                            [0.502,1,0.635,1]
                        ];
                    } else {
                        _map drawLine [
                            _profilePos,
                            _x,
                            [0.502,1,0.635,1]
                        ];
					};
                };
            } foreach _plannedWaypoints;
        };
	};

    case "enableWaypointSelected": {

        private ["_commandState","_selectedWaypoint","_profileID","_playerID","_requestID","_event","_faction","_opsWPTypeOptions","_opsWPSpeedOptions",
        "_opsWPFormationOptions","_opsWPBehaviourOptions","_waypointTypeList","_waypointSpeedList","_waypointFormationList","_waypointBehaviourList",
        "_selectedWaypointType","_selectedWaypointSpeed","_selectedWaypointFormation","_selectedWaypointBehaviour","_opsWPTypeValues",
        "_opsWPSpeedValues","_opsWPFormationValues","_opsWPBehaviourValues","_selectedWaypointTypeIndex","_selectedWaypointSpeedIndex",
        "_selectedWaypointFormationIndex","_selectedWaypointBehaviourIndex"];

        // a waypoint has been selected

        _commandState = [_logic,"commandState"] call MAINCLASS;

        _selectedWaypoint = [_commandState,"opsGroupWaypointsSelectedValue"] call ALIVE_fnc_hashGet;

        _selectedWaypointType = _selectedWaypoint select 2;
        _selectedWaypointSpeed = _selectedWaypoint select 3;
        _selectedWaypointFormation = _selectedWaypoint select 6;
        _selectedWaypointBehaviour = _selectedWaypoint select 8;

        _selectedWaypointTypeIndex = 0;
        _selectedWaypointSpeedIndex = 0;
        _selectedWaypointFormationIndex = 0;
        _selectedWaypointBehaviourIndex = 0;

        _opsWPTypeOptions = [_commandState,"opsWPTypeOptions"] call ALIVE_fnc_hashGet;
        _opsWPTypeValues = [_commandState,"opsWPTypeValues"] call ALIVE_fnc_hashGet;
        _opsWPSpeedOptions = [_commandState,"opsWPSpeedOptions"] call ALIVE_fnc_hashGet;
        _opsWPSpeedValues = [_commandState,"opsWPSpeedValues"] call ALIVE_fnc_hashGet;
        _opsWPFormationOptions = [_commandState,"opsWPFormationOptions"] call ALIVE_fnc_hashGet;
        _opsWPFormationValues = [_commandState,"opsWPFormationValues"] call ALIVE_fnc_hashGet;
        _opsWPBehaviourOptions = [_commandState,"opsWPBehaviourOptions"] call ALIVE_fnc_hashGet;
        _opsWPBehaviourValues = [_commandState,"opsWPBehaviourValues"] call ALIVE_fnc_hashGet;

        _waypointTypeList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointTypeList);
        _waypointTypeList ctrlShow true;

        lbClear _waypointTypeList;

        {
            if(_selectedWaypointType == _x) then {
                _selectedWaypointTypeIndex = _forEachIndex;
            };
            _waypointTypeList lbAdd format["%1", _opsWPTypeOptions select _forEachIndex];
        } forEach _opsWPTypeValues;

        _waypointTypeList lbSetCurSel _selectedWaypointTypeIndex;

        // set the event handler for the list selection event

        _waypointTypeList ctrlSetEventHandler ["LBSelChanged", "['OPS_WP_TYPE_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];


        _waypointSpeedList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointSpeedList);
        _waypointSpeedList ctrlShow true;

        lbClear _waypointSpeedList;

        {
            if(_selectedWaypointSpeed == _x) then {
                _selectedWaypointSpeedIndex = _forEachIndex;
            };
            _waypointSpeedList lbAdd format["%1", _opsWPSpeedOptions select _forEachIndex];
        } forEach _opsWPSpeedValues;

        _waypointSpeedList lbSetCurSel _selectedWaypointSpeedIndex;

        // set the event handler for the list selection event

        _waypointSpeedList ctrlSetEventHandler ["LBSelChanged", "['OPS_WP_SPEED_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];


        _waypointFormationList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointFormationList);
        _waypointFormationList ctrlShow true;

        lbClear _waypointFormationList;

        {
            if(_selectedWaypointFormation == _x) then {
                _selectedWaypointFormationIndex = _forEachIndex;
            };
            _waypointFormationList lbAdd format["%1", _opsWPFormationOptions select _forEachIndex];
        } forEach _opsWPFormationValues;

        _waypointFormationList lbSetCurSel _selectedWaypointFormationIndex;

        // set the event handler for the list selection event

        _waypointFormationList ctrlSetEventHandler ["LBSelChanged", "['OPS_WP_FORMATION_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];


        _waypointBehaviourList = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_WaypointBehavourList);
        _waypointBehaviourList ctrlShow true;

        lbClear _waypointBehaviourList;

        {
            if(_selectedWaypointBehaviour == _x) then {
                _selectedWaypointBehaviourIndex = _forEachIndex;
            };
            _waypointBehaviourList lbAdd format["%1", _opsWPBehaviourOptions select _forEachIndex];
        } forEach _opsWPBehaviourValues;

        _waypointBehaviourList lbSetCurSel _selectedWaypointBehaviourIndex;

        // set the event handler for the list selection event

        _waypointBehaviourList ctrlSetEventHandler ["LBSelChanged", "['OPS_WP_BEHAVIOUR_LIST_SELECT',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];

    };

    case "enableOpsJoinGroup": {

        private["_commandState","_unit","_faction","_nearestTown","_factionName","_title","_text","_line1","_group","_initialPosition",
        "_instantJoinState"];

        _commandState = [_logic,"commandState"] call MAINCLASS;

        // once the data has returned from the command handler
        // enable remote controlled join of the group

        if(typeName _args == "ARRAY") then {

            _unit = _args select 1 select 0;

            //_unit = call compile format["%1",_unit];

            _group = group _unit;

            //_duration = 1000;

            if!(isNil "_unit") then {

                //[_logic,"commandState",_commandState] call MAINCLASS;

                _faction = faction _unit;
                _nearestTown = [position _unit] call ALIVE_fnc_taskGetNearestLocationName;
                _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                _title = "<t size='1.5' color='#68a7b7' shadow='1'>Joining Group</t><br/>";
                _text = format["%1<t>%2 group %3 near %4</t>",_title,_factionName,_group,_nearestTown];

                ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                player remoteControl _unit;
                //_unit enableFatigue false;

                [_unit,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;

                //player hideObjectGlobal true; // done serverside

                ["closeSplash"] call ALIVE_fnc_displayMenu;

                waitUntil{
                    sleep 1;
                    if((player distance _unit) > 100) then {
                        //_newPosition = (getpos _unit) getpos [10, random 360];
                        player setPos (position _unit);
                    };
                    !(alive player) || {!(alive _unit)} || {!([_commandState,"opsGroupInstantJoin"] call ALIVE_fnc_hashGet)}
                };

                if(alive player) then {

                    // player is alive, move them back to initial position and notify them of what's happening

                    _initialPosition = [_commandState,"opsGroupInstantJoinPlayerPosition"] call ALIVE_fnc_hashGet;
                    _instantJoinState = [_commandState,"opsGroupInstantJoin"] call ALIVE_fnc_hashGet;

                    if(_instantJoinState) then {
                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>You have been killed...</t><br/><br/>";
                    }else{
                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>Reverting...</t><br/><br/>";
                    };

                    ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                    ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                    player setPos _initialPosition;

                };
				
				sleep 2;

                // revert camera and control back to player unit

                ["closeSplash"] call ALIVE_fnc_displayMenu;

                [player,false] call ALIVE_fnc_adminGhost;
                player allowDamage true;

                objNull remoteControl _unit;

                [true] call ALIVE_fnc_revertCamera;

                // store state

                [_commandState,"opsGroupInstantJoin",false] call ALIVE_fnc_hashSet;

            };

        };

    };

    case "enableOpsSpectateGroup": {

        private["_commandState","_unit","_faction","_nearestTown","_factionName","_title","_text","_line1","_group",
        "_initialPosition","_spectateState","_target","_timer","_position"];

        _commandState = [_logic,"commandState"] call MAINCLASS;

        // once the data has returned from the command handler
        // enable remote controlled join of the group

        if(typeName _args == "ARRAY") then {

            _unit = _args select 1 select 0;

            //_unit = call compile format["%1",_unit];

            _group = group _unit;

            _duration = 90;

            if!(isNil "_unit") then {

                player allowDamage false;

                _position = (position _unit) getpos [50, random 360];

                _target = "Land_HelipadEmpty_F" createVehicle _position;

                [_logic, "createDynamicCamera", [_duration,player,_unit,_target]] call MAINCLASS;

                ["closeSplash"] call ALIVE_fnc_displayMenu;

                _faction = faction _unit;
                _nearestTown = [position _unit] call ALIVE_fnc_taskGetNearestLocationName;
                _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                _title = "<t size='1.5' color='#68a7b7' shadow='1'>Group</t><br/>";
                _text = format["%1<t>%2 group %3 near %4</t>",_title,_factionName,_group,_nearestTown];

                ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                _timer = 0;

                waitUntil{
                    sleep 1;
                    _timer = _timer + 1;
                    if((player distance _unit) > 100) then {
                        _newPosition = (getpos _unit) getpos [10, random 360];
                        player setPos _newPosition;
                    };
                    (_timer == _duration) || {!(alive player)} || {!(alive _unit)} || {!([_commandState,"opsGroupSpectate"] call ALIVE_fnc_hashGet)}
                };

                if (alive player) then {

                    _initialPosition = [_commandState,"opsGroupSpectatePlayerPosition"] call ALIVE_fnc_hashGet;
                    _spectateState = [_commandState,"opsGroupSpectate"] call ALIVE_fnc_hashGet;

                    if(_spectateState) then {
                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>Reverting...</t><br/><br/>";
                    }else{
                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>Reverting...</t><br/><br/>";
                    };

                    ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                    ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                    player setPos _initialPosition;

                    ["closeSplash"] call ALIVE_fnc_displayMenu;

                    ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;

                };

                [player,false] call ALIVE_fnc_adminGhost;
                player allowDamage true;

                [_logic, "deleteDynamicCamera"] call MAINCLASS;

                deleteVehicle _target;

                [_commandState,"opsGroupSpectate",false] call ALIVE_fnc_hashSet;

            };

        };

    };

    case "createDynamicCamera": {

        private ["_source","_target1","_target2","_duration","_sourceIsPlayer","_targetIsPlayer","_targetIsMan","_targetInVehicle","_cameraAngles",
        "_initialAngle","_diceRoll","_cameraShots","_shot","_target2","_randomPosition"];

        _duration = _args select 0;
        _source = _args select 1;
        _target1 = _args select 2;
        _target2 = if(count _this > 3) then {_this select 3} else {nil};

        _sourceIsPlayer = false;
        if(isPlayer _source) then {
            _sourceIsPlayer = true;
        };

        _targetIsMan = false;
        _targetInVehicle = false;
        if(_target1 isKindOf "Man" && alive _target1) then {
            _targetIsMan = true;
            if(vehicle _target1 != _target1) then {
                _targetInVehicle = true;
                _target1 = vehicle _target1;
            };
        };

        //_cameraAngles = ["DEFAULT","LOW","EYE","HIGH","BIRDS_EYE","UAV","SATELITE"];
        _cameraAngles = ["EYE","HIGH","BIRDS_EYE","UAV"];
        _initialAngle = selectRandom _cameraAngles;

        /*
        ["CINEMATIC DURATION: %1",_duration] call ALIVE_fnc_dump;
        ["SOURCE IS PLAYER: %1",_sourceIsPlayer] call ALIVE_fnc_dump;
        ["TARGET IS MAN: %1",_targetIsMan] call ALIVE_fnc_dump;
        ["TARGET IS IN VEHICLE: %1",_targetInVehicle] call ALIVE_fnc_dump;
        */

        ALIVE_cameraType = "CAMERA";

        if(_targetIsMan && !(_targetInVehicle)) then {
            _diceRoll = random 1;
            if(_diceRoll > 0.4) then {
                ALIVE_cameraType = "SWITCH";
            };
        };

        //["CAMERA TYPE IS: %1",ALIVE_cameraType] call ALIVE_fnc_dump;

        //_cameraShots = ["FLY_IN","PAN","ZOOM"];

        _cameraShots = ["FLY_IN"];

        if(_targetIsMan || _targetInVehicle) then {
            _cameraShots append ["CHASE","CHASE_SIDE","CHASE_ANGLE"];
        };

        _shot = selectRandom _cameraShots;

        /*
        ["CAMERA SHOT IS: %1",_shot] call ALIVE_fnc_dump;
        ["CAMERA ANGLE IS: %1",_initialAngle] call ALIVE_fnc_dump;
        */

        if(ALIVE_cameraType == "CAMERA") then {

            if!(_shot == "PAN") then {
                ALIVE_tourCamera = [_source,false,_initialAngle] call ALIVE_fnc_addCamera;
                [ALIVE_tourCamera,true] call ALIVE_fnc_startCinematic;
            };

            switch(_shot) do {
                case "FLY_IN":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_flyInShot;
                };
                case "ZOOM":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_zoomShot;
                };
                case "PAN":{

                    if(isNil "_target2") then {
                        _randomPosition = (position _source) getpos [random 50, random 360];
                        _target2 = "Land_HelipadEmpty_F" createVehicle _randomPosition;
                    };

                    ALIVE_tourCamera = [_source,false,_initialAngle] call ALIVE_fnc_addCamera;
                    [ALIVE_tourCamera,true] call ALIVE_fnc_startCinematic;
                    [ALIVE_tourCamera,_target2,_target1,_duration] spawn ALIVE_fnc_panShot;
                };
                case "STATIC":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_staticShot;
                };
                case "CHASE":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseShot;
                };
                case "CHASE_SIDE":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseSideShot;
                };
                case "CHASE_WHEEL":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseWheelShot;
                };
                case "CHASE_ANGLE":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseAngleShot;
                };
            };

        }else{

            [_target1,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;

        };

    };

    case "deleteDynamicCamera": {

        if(ALIVE_cameraType == "CAMERA") then {

            [ALIVE_tourCamera,true] call ALIVE_fnc_stopCinematic;
            [ALIVE_tourCamera] call ALIVE_fnc_removeCamera;

        }else{

            [true] call ALIVE_fnc_revertCamera;

        };

        //player hideObjectGlobal false;

    };

    case "intelRenderSourceToTarget": {

        private ["_commandState","_renderTarget","_cam","_boundingBoxReal","_height"];

        _commandState = [_logic,"commandState"] call MAINCLASS;

        // render pip picture starting from source object to ground position

        _args params ["_source","_target"];

        if (typename _target == "ARRAY") then {
            _target = [_target select 0,_target select 1,0];
        } else {
            _target = getPosATL _target;
        };

        _renderTarget = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_IntelRenderTarget);
        _renderTarget ctrlShow true;

        // create and orient cam

        _cam = "camera" camCreate [0,0,0];
        _cam camSetFov 0.1;
        _cam camSetTarget _target;
        _cam cameraEffect ["Internal", "Back", "ALiVE_C2ISTAR_IMINT_CAM"];

        _boundingBoxReal = boundingBoxReal _source;
        _height = abs (((_boundingBoxReal select 1) select 2) - ((_boundingBoxReal select 0) select 2));
        
        _cam attachTo [_source, [0,0,- (_height * 0.75)]];
        _cam camCommit 0;

        [_commandState,"intelIMINTCamera", _cam] call ALIVE_fnc_hashSet;
        [_commandState,"intelIMINTZoomLevel", 0.1] call ALIVE_fnc_hashSet;

        // render cam image to tablet

        _renderTarget ctrlSetText "#(argb,512,512,1)r2t(ALiVE_C2ISTAR_IMINT_CAM,1.0)";

        // clear ui controls

        _map = SCOM_getControl(SCOMTablet_CTRL_MainDisplay,SCOMTablet_CTRL_MainMap);
        _map ctrlShow false;

        ["INTEL_IMINT_DISPLAY_CAMERA_OPTION_CATEGORIES",[]] call ALIVE_fnc_SCOMTabletOnAction;

    };

};

TRACE_1("SCOM - output",_result);
_result;
