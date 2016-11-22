#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(civilianVehicle);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Civilian vehicle class

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
_logic = [nil, "create"] call ALIVE_fnc_civilianVehicle;

// init the agent
_result = [_logic, "init"] call ALIVE_fnc_civilianVehicle;

// set the agent agent id
_result = [_logic, "agentID", "agent_01"] call ALIVE_fnc_civilianVehicle;

// set the agent class of the agent
_result = [_logic, "agentClass", "B_MRAP_01_hmg_F"] call ALIVE_fnc_civilianVehicle;

// set the unit position of the agent
_result = [_logic, "position", getPos player] call ALIVE_fnc_civilianVehicle;

// set the agent is active
_result = [_logic, "active", true] call ALIVE_fnc_civilianVehicle;

// set the agent unit object reference
_result = [_logic, "unit", _unit] call ALIVE_fnc_civilianVehicle;

// spawn a unit from the agent
_result = [_logic, "spawn"] call ALIVE_fnc_civilianVehicle;

// despawn a unit from the agent
_result = [_logic, "despawn"] call ALIVE_fnc_civilianVehicle;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_civilianVehicle

TRACE_1("civilianVehicle - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = true;

#define MTEMPLATE "ALiVE_CIVILIANVEHICLE_%1"

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
            [_logic,"type","vehicle"] call ALIVE_fnc_hashSet; // select 2 select 4
            [_logic,"unit",objNull] call ALIVE_fnc_hashSet; // select 2 select 5
            [_logic,"agentClass",""] call ALIVE_fnc_hashSet; // select 2 select 6
            [_logic,"faction",""] call ALIVE_fnc_hashSet; // select 2 select 7
            [_logic,"side",""] call ALIVE_fnc_hashSet; // select 2 select 8
            [_logic,"homeCluster",""] call ALIVE_fnc_hashSet; // select 2 select 9
            [_logic,"homePosition",[0,0]] call ALIVE_fnc_hashSet; // select 2 select 10
            [_logic,"direction",""] call ALIVE_fnc_hashSet; // select 2 select 11
            [_logic,"fuel",1] call ALIVE_fnc_hashSet; // select 2 select 12
            [_logic,"damage",[]] call ALIVE_fnc_hashSet; // select 2 select 13
        };

    };

    case "state": {

        if !(_args isEqualType []) then {
            private _state = [] call ALIVE_fnc_hashCreate;
            {
                if(!(_x == "super") && !(_x == "class")) then {
                    [_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                };
            } forEach (_logic select 1);

            _result = _state;
        } else {
            ASSERT_TRUE(_args isEqualType [], str typeName _args);
            {
                [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
            } forEach (_args select 1);
        };

    };

    case "debug": {

        if !(_args isEqualType true) then {
            _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(_args isEqualType true, str _args);

        [_logic,"deleteDebugMarkers"] call MAINCLASS;

        if(_args) then {
            [_logic,"createDebugMarkers"] call MAINCLASS;
        };

        _result = _args;

    };

    case "active": {

        if(_args isEqualType "") then {
            [_logic,"active",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"active"] call ALIVE_fnc_hashGet;

    };

    case "agentID": {

        if(_args isEqualType "") then {
            [_logic,"agentID",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"agentID"] call ALIVE_fnc_hashGet;

    };

    case "side": {

        if(_args isEqualType "") then {
                [_logic,"side",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"side"] call ALIVE_fnc_hashGet;

    };

    case "faction": {

        if(_args isEqualType "") then {
            [_logic,"faction",_args] call ALIVE_fnc_hashSet;
        };
        _result = [_logic,"faction"] call ALIVE_fnc_hashGet;

    };

    case "type": {

        if(_args isEqualType "") then {
            [_logic,"type",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"type"] call ALIVE_fnc_hashGet;

    };

    case "agentClass": {

        if(_args isEqualType "") then {
            [_logic,"agentClass",_args] call ALIVE_fnc_hashSet;
        };

        _result = _logic select 2 select 6; //[_logic,"agentClass"] call ALIVE_fnc_hashGet;

    };

    case "position": {

        if(_args isEqualType []) then {

            if(count _args == 2) then  {
                _args pushback 0;
            };

            [_logic,"position",_args] call ALIVE_fnc_hashSet;

            if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                [_logic,"debug",true] call MAINCLASS;
            };
        };

        _result = [_logic,"position"] call ALIVE_fnc_hashGet;

    };

    case "unit": {

        if(_args isEqualType objNull) then {
            [_logic,"unit",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"unit"] call ALIVE_fnc_hashGet;

    };

    case "homeCluster": {

        if(_args isEqualType "") then {
            [_logic,"homeCluster",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"homeCluster"] call ALIVE_fnc_hashGet;

    };

    case "homePosition": {

        if(_args isEqualType []) then {

            if(count _args == 2) then  {
                _args pushback 0;
            };

            [_logic,"homePosition",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"homePosition"] call ALIVE_fnc_hashGet;

    };

    case "direction": {

        if(_args isEqualType 0) then {
                [_logic,"direction",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"direction"] call ALIVE_fnc_hashGet;

    };

    case "damage": {

        if(_args isEqualType []) then {
                [_logic,"damage",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"damage"] call ALIVE_fnc_hashGet;

    };

    case "fuel": {

        if(_args isEqualType 0) then {
                [_logic,"fuel",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"fuel"] call ALIVE_fnc_hashGet;

    };

    case "spawn": {

        private _debug = _logic select 2 select 0;  //[_logic,"debug"] call ALIVE_fnc_hashGet;
        private _active = _logic select 2 select 1;         //[_logic,"active"] call ALIVE_fnc_hashGet;
        private _position = _logic select 2 select 2;       //[_logic,"position"] call ALIVE_fnc_hashGet;
        private _agentID = _logic select 2 select 3;        //[_logic,"agentID"] call ALIVE_fnc_hashGet;
        private _agentClass = _logic select 2 select 6;     //[_logic,"agentClass"] call ALIVE_fnc_hashGet;
        private _side = _logic select 2 select 8;           //[_logic,"side"] call ALIVE_fnc_hashGet;
        private _homePosition = _logic select 2 select 10;  //[_logic,"homePosition"] call ALIVE_fnc_hashGet;
        private _direction = _logic select 2 select 11;     //[_logic,"direction"] call ALIVE_fnc_hashGet;
        private _fuel = _logic select 2 select 12;          //[_logic,"fuel"] call ALIVE_fnc_hashGet;
        private _damage = _logic select 2 select 13;        //[_logic,"damage"] call ALIVE_fnc_hashGet;

        private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

        // not already active
        if!(_active) then {

            private _unit = createVehicle [_agentClass, _homePosition, [], 0, "CAN_COLLIDE"];
            _unit setDir _direction;
            _unit setFuel _fuel;

            if(count _damage > 0) then {
                [_unit, _damage] call ALIVE_fnc_vehicleSetDamage;
            };

            // set profile id on the unit
            _unit setVariable ["agentID", _agentID];

            // killed event handler
            private _eventID = _unit addMPEventHandler["MPKilled", ALIVE_fnc_agentKilledEventHandler];

            // getin event handler
            _eventID = _unit addEventHandler["getIn", ALIVE_fnc_agentGetInEventHandler];

            // set profile as active and store a reference to the unit on the profile
            [_logic,"unit",_unit] call ALIVE_fnc_hashSet;
            [_logic,"active",true] call ALIVE_fnc_hashSet;

            // store the profile id on the active profiles index
            [ALIVE_agentHandler,"setActive",[_agentID,_logic]] call ALIVE_fnc_agentHandler;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                //["Agent [%1] Spawn - class: %2 pos: %3",_agentID,_agentClass,_position] call ALIVE_fnc_dump;
                [_logic,"debug",true] call MAINCLASS;
            };
            // DEBUG -------------------------------------------------------------------------------------
        };

    };

    case "despawn": {

        private _debug = _logic select 2 select 0;      //[_logic,"debug"] call ALIVE_fnc_hashGet;
        private _active = _logic select 2 select 1;     //[_logic,"active"] call ALIVE_fnc_hashGet;
        private _side = _logic select 2 select 8;       //[_logic,"side"] call ALIVE_fnc_hashGet;
        private _unit = _logic select 2 select 5;       //[_logic,"unit"] call ALIVE_fnc_hashGet;
        private _agentID = _logic select 2 select 3;    //[_logic,"agentID"] call ALIVE_fnc_hashGet;

        // not already inactive
        if(_active) then {

            [_logic,"active",false] call ALIVE_fnc_hashSet;

            private _position = getPosATL _unit;

            // update profile before despawn
            [_logic,"position", _position] call ALIVE_fnc_hashSet;
            [_logic,"unit",objNull] call ALIVE_fnc_hashSet;
            [_logic,"direction", getDir _unit] call ALIVE_fnc_hashSet;
            [_logic,"damage", _unit call ALIVE_fnc_vehicleGetDamage] call ALIVE_fnc_hashSet;
            [_logic,"fuel", fuel _unit] call ALIVE_fnc_hashSet;

            // delete
            deleteVehicle _unit;

            // store the profile id on the in active profiles index
            [ALIVE_agentHandler,"setInActive",[_agentID,_logic]] call ALIVE_fnc_agentHandler;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                //["Agent [%1] Despawn - pos: %2",_agentID,_position] call ALIVE_fnc_dump;
                [_logic,"debug",true] call MAINCLASS;
            };
            // DEBUG -------------------------------------------------------------------------------------

        };

    };

    case "handleDeath": {

        [_logic,"damage",1] call ALIVE_fnc_hashSet;

    };

    case "createMarker": {

        private ["_color"];

        private _alpha = _args param [0, 0.5, [1]];

        private _markers = [];

        private _position = [_logic,"position"] call ALIVE_fnc_hashGet;
        private _agentID = [_logic,"agentID"] call ALIVE_fnc_hashGet;
        private _side = [_logic,"side"] call ALIVE_fnc_hashGet;
        private _active = [_logic,"active"] call ALIVE_fnc_hashGet;

        switch(_side) do {
            case "EAST":{
                _color = "ColorRed";
            };
            case "WEST":{
                _color = "ColorBlue";
            };
            case "CIV":{
                _color = "ColorYellow";
            };
            case "GUER":{
                _color = "ColorGreen";
            };
            default {
                _color = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
            };
        };

        private _icon = "n_inf";

        if(count _position > 0) then {
            private _m = createMarker [format[MTEMPLATE, format["%1_debug",_agentID]], _position];
            _m setMarkerShape "ICON";
            _m setMarkerSize [0.4, 0.4];
            _m setMarkerType _icon;
            _m setMarkerColor _color;
            _m setMarkerAlpha _alpha;

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

    case "createDebugMarkers": {

        private ["_debugColor"];

        private _markers = [];

        private _position = [_logic,"position"] call ALIVE_fnc_hashGet;
        private _agentID = [_logic,"agentID"] call ALIVE_fnc_hashGet;
        private _agentSide = [_logic,"side"] call ALIVE_fnc_hashGet;
        private _agentActive = [_logic,"active"] call ALIVE_fnc_hashGet;

        switch(_agentSide) do {
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

        private _debugIcon = "n_inf";

        private _debugAlpha = 0.5;
        if(_agentActive) then {
            _debugAlpha = 1;
        };

        if(count _position > 0) then {
            private _m = createMarker [format[MTEMPLATE, _agentID], _position];
            _m setMarkerShape "ICON";
            _m setMarkerSize [0.4, 0.4];
            _m setMarkerType _debugIcon;
            _m setMarkerColor _debugColor;
            _m setMarkerAlpha _debugAlpha;

            _markers pushback _m;

            [_logic,"debugMarkers",_markers] call ALIVE_fnc_hashSet;
        };

    };

    case "deleteDebugMarkers": {

        {
                deleteMarker _x;
        } forEach ([_logic,"debugMarkers", []] call ALIVE_fnc_hashGet);

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("civilianAgent - output",_result);

_result;
