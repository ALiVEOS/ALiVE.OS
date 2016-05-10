#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(civilianAgent);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Civilian agent class

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state
Array - agentClass - Set the agent class name
Array - position - Set the agent position
Boolean - active - Flag for if the agents are spawned
Object - unit - Reference to the spawned unit
None - spawn - Spawn the agent from the agent data
None - despawn - De-Spawn the agent from the agent data

Examples:
(begin example)
// create a agent
_logic = [nil, "create"] call ALIVE_fnc_civilianAgent;

// init the agent
_result = [_logic, "init"] call ALIVE_fnc_civilianAgent;

// set the agent agent id
_result = [_logic, "agentID", "agent_01"] call ALIVE_fnc_civilianAgent;

// set the agent class of the agent
_result = [_logic, "agentClass", "B_MRAP_01_hmg_F"] call ALIVE_fnc_civilianAgent;

// set the unit position of the agent
_result = [_logic, "position", getPos player] call ALIVE_fnc_civilianAgent;

// set the agent is active
_result = [_logic, "active", true] call ALIVE_fnc_civilianAgent;

// set the agent unit object reference
_result = [_logic, "unit", _unit] call ALIVE_fnc_civilianAgent;

// spawn a unit from the agent
_result = [_logic, "spawn"] call ALIVE_fnc_civilianAgent;

// despawn a unit from the agent
_result = [_logic, "despawn"] call ALIVE_fnc_civilianAgent;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_civilianAgent

private ["_logic","_operation","_args","_result","_deleteMarkers","_createMarkers"];

TRACE_1("civilianAgent - input",_this);

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

#define MTEMPLATE "ALiVE_CIVILIANAGENT_%1"

_deleteMarkers = {
    private ["_logic"];
    _logic = _this;
    {
            deleteMarker _x;
    } forEach ([_logic,"debugMarkers", []] call ALIVE_fnc_hashGet);
};

_createMarkers = {
    private ["_logic","_markers","_m","_position","_agentID","_debugColor","_insurgentCommands","_text","_debugIcon","_debugAlpha","_agentSide","_vehicleType","_agentActive","_agentPosture"];
    _logic = _this;
    _markers = [];

    _position = [_logic,"position"] call ALIVE_fnc_hashGet;
    _agentID = [_logic,"agentID"] call ALIVE_fnc_hashGet;
    _agentSide = [_logic,"side"] call ALIVE_fnc_hashGet;
    _agentActive = [_logic,"active"] call ALIVE_fnc_hashGet;
    _agentPosture = [_logic,"posture",0] call ALIVE_fnc_hashGet;
    _activeCommands = [_logic,"activeCommands",[]] call ALIVE_fnc_hashGet;
    _debugColor = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
    _insurgentCommands = ["alive_fnc_cc_suicide","alive_fnc_cc_suicidetarget","alive_fnc_cc_rogue","alive_fnc_cc_roguetarget","alive_fnc_cc_sabotage","alive_fnc_cc_getweapons"];
	
    _insurgentCommandActive = ({toLower(_x select 0) in _insurgentCommands} count _activeCommands > 0);

    if(_agentPosture < 10) then {_debugColor = "ColorGreen"};
	if(_agentPosture >= 10 && {_agentPosture < 40}) then {_debugColor = "ColorGreen"};
    if(_agentPosture >= 40 && {_agentPosture < 70}) then {_debugColor = "ColorYellow"};
    if(_agentPosture >= 70 && {_agentPosture < 100}) then {_debugColor = "ColorOrange"};
    if(_agentPosture >= 100) then {_debugColor = "ColorRed"};
    
    _text = if (_insurgentCommandActive) then {_debugColor = "ColorWhite"; _activeCommands select 0 select 0} else {""};
    
    _debugIcon = "n_unknown";

    _debugAlpha = 0.5;
    if(_agentActive) then {
        _debugAlpha = 1;
    };

    if(count _position > 0) then {
        _m = createMarker [format[MTEMPLATE, format["%1_debug",_agentID]], _position];
        _m setMarkerShape "ICON";
        _m setMarkerSize [0.4, 0.4];
        _m setMarkerType _debugIcon;
        _m setMarkerColor _debugColor;
        _m setMarkerAlpha _debugAlpha;
		_m setMarkerText _text;

        _markers pushback _m;

        [_logic,"debugMarkers",_markers] call ALIVE_fnc_hashSet;
    };
};

switch(_operation) do {
    case "init": {
        if (isServer) then {
            // if server, initialise module game logic
            // nil these out they add a lot of code to the hash..
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;
            //TRACE_1("After module init",_logic);

            // set defaults
            [_logic,"debug",false] call ALIVE_fnc_hashSet; // select 2 select 0
            [_logic,"active",false] call ALIVE_fnc_hashSet; // select 2 select 1
            [_logic,"position",[0,0]] call ALIVE_fnc_hashSet; // select 2 select 2
            [_logic,"agentID",""] call ALIVE_fnc_hashSet; // select 2 select 3
            [_logic,"type","agent"] call ALIVE_fnc_hashSet; // select 2 select 4
            [_logic,"unit",objNull] call ALIVE_fnc_hashSet; // select 2 select 5
            [_logic,"agentClass",""] call ALIVE_fnc_hashSet; // select 2 select 6
            [_logic,"faction",""] call ALIVE_fnc_hashSet; // select 2 select 7
            [_logic,"side",""] call ALIVE_fnc_hashSet; // select 2 select 8
            [_logic,"homeCluster",""] call ALIVE_fnc_hashSet; // select 2 select 9
            [_logic,"homePosition",[0,0]] call ALIVE_fnc_hashSet; // select 2 select 10
            [_logic,"activeCommands",[]] call ALIVE_fnc_hashSet; // select 2 select 11
            [_logic,"posture",0] call ALIVE_fnc_hashSet; // select 2 select 12
        };
    };
    case "state": {
        private["_state"];

        if(typeName _args != "ARRAY") then {
            _state = [] call ALIVE_fnc_hashCreate;
            {
                if(!(_x == "super") && !(_x == "class")) then {
                    [_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                };
            } forEach (_logic select 1);

            _result = _state;

        } else {
            ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
            {
                [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
            } forEach (_args select 1);
        };
    };
    case "debug": {
        if(typeName _args != "BOOL") then {
            _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

         _logic call _deleteMarkers;

        if(_args) then {
            _logic call _createMarkers;
        };

        _result = _args;
    };
    case "active": {
        if(typeName _args == "BOOL") then {
            [_logic,"active",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"active"] call ALIVE_fnc_hashGet;
    };
    case "agentID": {
        if(typeName _args == "STRING") then {
            [_logic,"agentID",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"agentID"] call ALIVE_fnc_hashGet;
    };
    case "side": {
        if(typeName _args == "STRING") then {
                [_logic,"side",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"side"] call ALIVE_fnc_hashGet;
    };
    case "faction": {
        if(typeName _args == "STRING") then {
            [_logic,"faction",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"faction"] call ALIVE_fnc_hashGet;
    };
    case "type": {
        if(typeName _args == "STRING") then {
            [_logic,"type",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"type"] call ALIVE_fnc_hashGet;
    };
    case "agentClass": {
        if(typeName _args == "STRING") then {
            [_logic,"agentClass",_args] call ALIVE_fnc_hashSet;
        };
        _result = _logic select 2 select 6; //[_logic,"agentClass"] call ALIVE_fnc_hashGet;
    };
    case "position": {
        if(typeName _args == "ARRAY") then {

            if(count _args == 2) then  {
                _args set [count _args, 0];
            };

            [_logic,"position",_args] call ALIVE_fnc_hashSet;

            if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                [_logic,"debug",true] call MAINCLASS;
            };
        };
        _result = [_logic,"position"] call ALIVE_fnc_hashGet;
    };
    case "unit": {
        if(typeName _args == "OBJECT") then {
            [_logic,"unit",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"unit"] call ALIVE_fnc_hashGet;
    };
    case "homeCluster": {
        if(typeName _args == "STRING") then {
            [_logic,"homeCluster",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"homeCluster"] call ALIVE_fnc_hashGet;
    };
    case "homePosition": {
        if(typeName _args == "ARRAY") then {

            if(count _args == 2) then  {
                _args set [count _args, 0];
            };

            [_logic,"homePosition",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"homePosition"] call ALIVE_fnc_hashGet;
    };
    case "setActiveCommand": {
        private ["_activeCommands","_type","_active"];

        if(typeName _args == "ARRAY") then {

            [_logic, "clearActiveCommands"] call MAINCLASS;

            [_logic, "addActiveCommand", _args] call MAINCLASS;

            _active = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;

            if(_active) then {
                _activeCommands = [_logic,"activeCommands",[]] call ALIVE_fnc_hashGet;
                
                if (count _activeCommands > 0) then {
               		[ALIVE_civCommandRouter, "activate", [_logic, _activeCommands]] call ALIVE_fnc_civCommandRouter;
                };
            };
        };
    };
    case "addActiveCommand": {
        private ["_activeCommands","_type","_debug"];

        _debug = _logic select 2 select 0;

        if(typeName _args == "ARRAY") then {

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                _agentID = _logic select 2 select 3;
                ["ALIVE Agent [%1] Add Active Command - %2", _agentID, _args select 0] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            _activeCommands = [_logic,"activeCommands",[]] call ALIVE_fnc_hashGet;
            _activeCommands pushback _args;
            
            [_logic,"activeCommands",_activeCommands] call ALIVE_fnc_hashSet;
        };
    };
    case "clearActiveCommands": {
        private ["_activeCommands","_type"];

        _activeCommands = [_logic,"activeCommands",[]] call ALIVE_fnc_hashGet; //[_logic,"activeCommands"] call ALIVE_fnc_hashGet;

        if(count _activeCommands > 0) then {
            [ALIVE_civCommandRouter, "deactivate", _logic] call ALIVE_fnc_civCommandRouter;
            [_logic,"activeCommands",[]] call ALIVE_fnc_hashSet;
        };
    };
    case "spawn": {
        private ["_debug","_active","_position","_agentID","_agentClass","_side","_homePosition","_activeCommands","_sideObject","_group","_unit","_eventID"];

        _debug = _logic select 2 select 0; //[_logic,"debug"] call ALIVE_fnc_hashGet;
        _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet;
        _position = _logic select 2 select 2; //[_logic,"position"] call ALIVE_fnc_hashGet;
        _agentID = _logic select 2 select 3; //[_logic,"agentID"] call ALIVE_fnc_hashGet;
        _agentClass = _logic select 2 select 6; //[_logic,"agentClass"] call ALIVE_fnc_hashGet;
        _side = _logic select 2 select 8; //[_logic,"side"] call ALIVE_fnc_hashGet;
        _homePosition = _logic select 2 select 10; //[_logic,"activeCommands"] call ALIVE_fnc_hashGet;
        _activeCommands = _logic select 2 select 11; //[_logic,"activeCommands"] call ALIVE_fnc_hashGet;
        
        _townelder = [_logic,"townelder",false] call ALiVE_fnc_HashGet;
        _major = [_logic,"major",false] call ALiVE_fnc_HashGet;
        _priest = [_logic,"priest",false] call ALiVE_fnc_HashGet;
        _muezzin = [_logic,"muezzin",false] call ALiVE_fnc_HashGet;
		_politician = [_logic,"politician",false] call ALiVE_fnc_HashGet;

        _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

        // not already active
        if!(_active) then {

            _group = createGroup _sideObject;
            _unit = _group createUnit [_agentClass, _homePosition, [], 0, "CAN_COLLIDE"];
            
            //set low skill to save performance
            _unit setSkill 0.1;

            // set agent id on the unit
            _unit setVariable ["agentID", _agentID];
            
            // set specials on the unit (public if true);
            _unit setVariable ["townElder", _townelder,_townelder];
            _unit setVariable ["major", _major,_major];
            _unit setVariable ["muezzin", _muezzin,_muezzin];
            _unit setVariable ["priest", _priest,_priest];
            _unit setVariable ["politician", _politician,_politician];

            // killed event handler
            _eventID = _unit addMPEventHandler["MPKilled", ALIVE_fnc_agentKilledEventHandler];

            // set agent as active and store a reference to the unit on the agent
            [_logic,"unit",_unit] call ALIVE_fnc_hashSet;
            [_logic,"active",true] call ALIVE_fnc_hashSet;

            // store the agent id on the active agents index
            [ALIVE_agentHandler,"setActive",[_agentID,_logic]] call ALIVE_fnc_agentHandler;

            // process commands
            if(count _activeCommands > 0) then {
                [ALIVE_civCommandRouter, "activate", [_logic, _activeCommands]] call ALIVE_fnc_civCommandRouter;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                //["Agent [%1] Spawn - class: %2 pos: %3",_agentID,_agentClass,_position] call ALIVE_fnc_dump;
                [_logic,"debug",true] call MAINCLASS;
            };
            // DEBUG -------------------------------------------------------------------------------------
        };
    };
    case "despawn": {
        private ["_debug","_active","_side","_unit","_agentID","_activeCommands","_position","_group","_music","_light"];

        _debug = _logic select 2 select 0; //[_logic,"debug"] call ALIVE_fnc_hashGet;
        _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet;
        _side = _logic select 2 select 8; //[_logic,"side"] call ALIVE_fnc_hashGet;
        _unit = _logic select 2 select 5; //[_logic,"unit"] call ALIVE_fnc_hashGet;
        _agentID = _logic select 2 select 3; //[_logic,"agentID"] call ALIVE_fnc_hashGet;
        _activeCommands = _logic select 2 select 11; //[_logic,"activeCommands"] call ALIVE_fnc_hashGet;

        // not already inactive
        if(_active) then {

            [_logic,"active",false] call ALIVE_fnc_hashSet;

            _position = getPosATL _unit;
            _group = group _unit;

            // update agent before despawn
            [_logic,"position", _position] call ALIVE_fnc_hashSet;
            [_logic,"unit",objNull] call ALIVE_fnc_hashSet;

            // remove music
            if(_unit getVariable ["ALIVE_agentHouseMusicOn",false]) then {
                _music = _unit getVariable "ALIVE_agentHouseMusic";
                deleteVehicle _music;
                _unit setVariable ["ALIVE_agentHouseMusic", objNull, false];
                _unit setVariable ["ALIVE_agentHouseMusicOn", true, false];
            };

            // remove lights
            if(_unit getVariable ["ALIVE_agentHouseLightOn",false]) then {
                _light = _unit getVariable "ALIVE_agentHouseLight";
                deleteVehicle _light;
                _unit setVariable ["ALIVE_agentHouseLight", objNull, false];
                _unit setVariable ["ALIVE_agentHouseLightOn", false, false];
            };

            // delete
            deleteVehicle _unit;
           _group call ALiVE_fnc_DeleteGroupRemote;

            // store the agent id on the in active agents index
            [ALIVE_agentHandler,"setInActive",[_agentID,_logic]] call ALIVE_fnc_agentHandler;

            // process commands
            if(count _activeCommands > 0) then {
                [ALIVE_civCommandRouter, "deactivate", _logic] call ALIVE_fnc_civCommandRouter;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                //["Agent [%1] Despawn - pos: %2",_agentID,_position] call ALIVE_fnc_dump;
                [_logic,"debug",true] call MAINCLASS;
            };
            // DEBUG -------------------------------------------------------------------------------------

        };
    };
    case "handleDeath": {
        
        _marker = format[MTEMPLATE, format["%1_debug",[_logic,"agentID",""] call ALiVE_fnc_HashGet]];
        
        deletemarker _marker;
        
        [_logic,"markers",([_logic,"markers",[]] call ALIVE_fnc_hashGet) - [_marker]] call ALIVE_fnc_hashSet;
        [_logic,"debugMarkers",([_logic,"debugMarkers",[]] call ALIVE_fnc_hashGet) - [_marker]] call ALIVE_fnc_hashSet;

        [ALIVE_civCommandRouter, "deactivate", _logic] call ALIVE_fnc_civCommandRouter;
    };
    case "createMarker": {

        private ["_markers","_m","_position","_agentID","_debugColor","_icon","_text","_alpha","_side","_active","_agentPosture","_activeCommands"];

        _alpha = [_args, 0, 0.5, [1]] call BIS_fnc_param;

        _markers = [];

        _position = [_logic,"position"] call ALIVE_fnc_hashGet;
        _agentID = [_logic,"agentID"] call ALIVE_fnc_hashGet;
        _side = [_logic,"side"] call ALIVE_fnc_hashGet;
        _active = [_logic,"active"] call ALIVE_fnc_hashGet;
        _agentPosture = [_logic,"posture",0] call ALIVE_fnc_hashGet;
        _activeCommands = [_logic,"activeCommands",[]] call ALIVE_fnc_hashGet;
	    _debugColor = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
	    _insurgentCommands = ["alive_fnc_cc_suicide","alive_fnc_cc_suicidetarget","alive_fnc_cc_rogue","alive_fnc_cc_roguetarget","alive_fnc_cc_sabotage","alive_fnc_cc_getweapons"];
		
	    _insurgentCommandActive = ({toLower(_x select 0) in _insurgentCommands} count _activeCommands > 0);

		/*
        switch(_side) do {
            case "EAST":{
                _debugColor = "ColorRed";
            };
            case "WEST":{
                _debugColor = "ColorBlue";
            };
            case "CIV":{
                _debugColor = "ColorYellow";
            };
            case "GUER":{
                _debugColor = "ColorGreen";
            };
            default {
                _debugColor = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
            };
        };
        */

	    if(_agentPosture < 10) then {_debugColor = "ColorGreen"};
		if(_agentPosture >= 10 && {_agentPosture < 40}) then {_debugColor = "ColorGreen"};
	    if(_agentPosture >= 40 && {_agentPosture < 70}) then {_debugColor = "ColorYellow"};
	    if(_agentPosture >= 70 && {_agentPosture < 100}) then {_debugColor = "ColorOrange"};
	    if(_agentPosture >= 100) then {_debugColor = "ColorRed"};
        
        _text = if (_insurgentCommandActive) then {_debugColor = "ColorWhite"; _activeCommands select 0 select 0} else {""};

        _icon = "n_unknown";

        if(count _position > 0) then {
            _m = createMarker [format[MTEMPLATE, format["%1_debug",_agentID]], _position];
            _m setMarkerShape "ICON";
            _m setMarkerSize [0.4, 0.4];
            _m setMarkerType _icon;
            _m setMarkerColor _debugColor;
            _m setMarkerAlpha _alpha;
            _m setMarkerText _text;

            _markers pushback _m;

            [_logic,"markers",_markers] call ALIVE_fnc_hashSet;
        };

        _result = _markers;
    };
    case "deleteMarker": {
        {
            deleteMarker _x;
        } forEach ([_logic,"markers", []] call ALIVE_fnc_hashGet);
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("civilianAgent - output",_result);
_result;