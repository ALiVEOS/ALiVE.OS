#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(logistics);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_logistics
Description:
Creates the server side object to store settings

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance!
String - The selected function
Array,String,Number,Boolean - The selected parameters

Returns:
Array, String, Number, Any - The expected return value

Examples:
(begin example)
// Create instance by placing editor module
[_logic,"init"] call ALiVE_fnc_logistics;
(end)

See Also:
- <ALIVE_fnc_logisticsInit>

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_logistics
#define DEFAULT_BLACKLIST []

private ["_result", "_operation", "_args", "_logic"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);

//Listener for special purposes
if (!isnil QMOD(SYS_LOGISTICS) && {MOD(SYS_LOGISTICS) getvariable [QGVAR(LISTENER),false]}) then {
    _blackOps = ["id"];

    if !(_operation in _blackOps) then {
        _check = "nothing"; if !(isnil "_args") then {_check = _args};

        ["op: %1 | args: %2",_operation,_check] call ALiVE_fnc_DumpR;
    };
};

TRACE_3("SYS_LOGISTICS",_logic, _operation, _args);

switch (_operation) do {

        case "create": {
            if (isServer) then {

                // Ensure only one module is used
                if !(isNil QMOD(SYS_LOGISTICS)) then {
                    _logic = MOD(SYS_LOGISTICS);
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_LOGISTICS_ERROR1");
                } else {
                    _logic = (createGroup sideLogic) createUnit ["ALiVE_SYS_LOGISTICS", [0,0], [], 0, "NONE"];
                    MOD(SYS_LOGISTICS) = _logic;
                };

                //Push to clients
                PublicVariable QMOD(SYS_LOGISTICS);
            };

            TRACE_1("Waiting for object to be ready",true);

            waituntil {!isnil QMOD(SYS_LOGISTICS)};

            TRACE_1("Creating class on all localities",true);

            // initialise module game logic on all localities
            MOD(SYS_LOGISTICS) setVariable ["super", QUOTE(SUPERCLASS)];
            MOD(SYS_LOGISTICS) setVariable ["class", QUOTE(MAINCLASS)];

            _result = MOD(SYS_LOGISTICS);
        };

        case "init": {

            private ["_exit"];

            //Only one init per instance is allowed
            if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS LOGISTICS - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

            //Start init
            _logic setVariable ["initGlobal", false];

            //["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

            /*
            MODEL - no visual just reference data
            - module object datastorage parameters
            - Establish data handler on server
            - Establish data model on server and client
            */

            TRACE_1("Getting Module Parameters",true);

            // Wait for disable log module to set module parameters before moving on
            if (["AliVE_SYS_LOGISTICSDISABLE"] call ALiVE_fnc_isModuleAvailable) then {waituntil {!isnil {_logic getvariable "DEBUG"}}};

            // Exit if disabled
            if (_logic getvariable ["DISABLELOG",false]) exitwith {["ALiVE SYS LOGISTICS DISABLED! Exiting..."] call ALiVE_fnc_Dump};

            TRACE_1("Creating data store",true);

            // Create logistics data storage in memory on all localities
            GVAR(STORE) = [] call ALIVE_fnc_hashCreate;

            // load static data
            call ALiVE_fnc_staticDataHandler;

            // Get all containers
            private "_containers";
            _aliveContainers = [];
            {
                private "_containers";
                _containers = _x;
                TRACE_1(">>>>",_containers);
                {
                    private "_container";
                    _container = _x;
                    TRACE_1(">>>>",_container);
                    if !(_container in _aliveContainers) then {
                        _aliveContainers pushback _x;
                    };
                } foreach _containers;
            } foreach (ALIVE_factionDefaultContainers select 2);

            // Define logistics properties on all localities (containers: select 0 / objects: select 1 / exclude: select 2)
            GVAR(CARRYABLE) = [["Man"],["Reammobox_F","Static","StaticWeapon","ThingX","NonStrategic"] + (_logic getvariable ["WHITELIST",[]]),["House"] + (_logic getvariable ["BLACKLIST",[]])];
            GVAR(TOWABLE) = [["Truck_F"],["Car","Ship"],[] + (_logic getvariable ["BLACKLIST",[]])];
            GVAR(STOWABLE) = [
                ["Car","Truck_F","Helicopter","Ship"] + _aliveContainers,
                (GVAR(CARRYABLE) select 1),
                [] + (_logic getvariable ["BLACKLIST",[]])
            ];
            GVAR(LIFTABLE) = [["Helicopter"],["Car","Ship","Truck_F"],[] + (_logic getvariable ["BLACKLIST",[]])];

            //Define actions on all localities (just in case)
            GVAR(ACTIONS) = {
                private ["_logic"];

                _logic = MOD(SYS_LOGISTICS);

                if !(_logic getvariable ["DISABLECARRY",false]) then {[_logic,"addAction",[player,"carryObject"]] call ALiVE_fnc_logistics};
                if !(_logic getvariable ["DISABLECARRY",false]) then {[_logic,"addAction",[player,"dropObject"]] call ALiVE_fnc_logistics};
                if !(_logic getvariable ["DISABLELOAD",false]) then {[_logic,"addAction",[player,"stowObjects"]] call ALiVE_fnc_logistics};
                if !(_logic getvariable ["DISABLELOAD",false]) then {[_logic,"addAction",[player,"unloadObjects"]] call ALiVE_fnc_logistics};
                if !(_logic getvariable ["DISABLETOW",false]) then {[_logic,"addAction",[player,"towObject"]] call ALiVE_fnc_logistics};
                if !(_logic getvariable ["DISABLETOW",false]) then {[_logic,"addAction",[player,"untowObject"]] call ALiVE_fnc_logistics};
                if !(_logic getvariable ["DISABLELIFT",false]) then {[_logic,"addAction",[player,"liftObject"]] call ALiVE_fnc_logistics};
                if !(_logic getvariable ["DISABLELIFT",false]) then {[_logic,"addAction",[player,"releaseObject"]] call ALiVE_fnc_logistics};

                player setvariable [QGVAR(ACTIONS),true];
                true;
            };

            // Define module basics on server
            if (isServer) then {

                // Reset states with provided data;
                if !(_logic getvariable ["DISABLEPERSISTENCE",false]) then {
                    if (isServer && {[QMOD(SYS_DATA)] call ALiVE_fnc_isModuleAvailable}) then {
                        
                        waituntil {!isnil QMOD(SYS_DATA) && {MOD(SYS_DATA) getvariable ["startupComplete",false]}};
                    };

					_state = call ALiVE_fnc_logisticsLoadData;
                    
                    if !(typeName _state == "BOOL") then {
                        GVAR(STORE) = _state;
                    };
                };

                GVAR(STORE) call ALIVE_fnc_inspectHash;

                [_logic,"state",GVAR(STORE)] call ALiVE_fnc_logistics;

                _logic setVariable ["init", true, true];
            };

            /*
            CONTROLLER  - coordination
            - check if an object is currently moved (= nearObjects attached to player)
            */

            // Wait until server init is finished
            waituntil {_logic getvariable ["init",false]};

            TRACE_1("Spawning Server processes",isServer);

            if (isServer) then {
                // Set eventhandlers for logistics objects
                //[_logic,"setEH",[_logic,"allObjects"] call ALiVE_fnc_logistics] call ALiVE_fnc_logistics;

                [_logic,"setEH",QGVAR(BUILDINGCHANGED)] call ALiVE_fnc_logistics;
            };

            TRACE_1("Spawning clientside processes",hasInterface);

            if (hasInterface) then {
                // Set eventhandlers for player

                [_logic,"setEH",[player]] call ALiVE_fnc_logistics;
            };

            /*
            VIEW - purely visual
            - initialise menu
            - frequent check to modify menu and display status (ALIVE_fnc_logisticsmenuDef)
            */

            TRACE_1("Adding menu on clients",hasInterface);

            // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
            if (hasInterface) then {

                // Initialise interaction key if undefined
                if (isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};

                TRACE_2("Menu pre-req",SELF_INTERACTION_KEY,ALIVE_fnc_logisticsMenuDef);

                // Check to see if player options is available, if not give the user this menu otherwise player options menu will have it
                if !([QMOD(sys_playeroptions)] call ALiVE_fnc_isModuleAvailable) then {
                    // Initialise main menu
                    [
                            "player",
                            [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                            -9500,
                            [
                                    "call ALIVE_fnc_logisticsMenuDef",
                                    ["main", "alive_flexiMenu_rscPopup"]
                            ]
                    ] call CBA_fnc_flexiMenu_Add;
                };
            };

            TRACE_1("After module init",_logic);

            // Indicate Init is finished on server
            if (isServer) then {
                _logic setVariable ["startupComplete", true, true];
            };

            //["%1 - Initialisation Completed...",MOD(SYS_LOGISTICS)] call ALiVE_fnc_Dump;
            _logic setVariable ["bis_fnc_initModules_activate",true];
            _result = MOD(SYS_LOGISTICS);
        };

        case "updateObject": {
            if (isnil "_args") exitwith {};

            if !(isServer) exitwith {
                [[_logic, _operation, _args],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;
            };

            private ["_objects"];

            switch (typeName _args) do {
                case ("ARRAY") : {_objects = _args};
                case ("OBJECT") : {_objects = [_args]};
                default {_objects = []};
            };

            {
                private ["_args","_id","_cont"];

                //Ensure object is existing and not profiled
                if (!(isnil "_x") && {!(isNull _x)} && {!(_x getVariable [QGVAR(DISABLE),false])} && {isnil {_x getVariable "profileID"}}) then {
                    _id = [_logic,"id",_x] call ALiVE_fnc_logistics;
                    _args = [GVAR(STORE),_id] call ALiVE_fnc_HashGet;

                    //Create objecthash and add to store if not existing yet
                    if (isnil "_args") then {
                        _args = [] call ALIVE_fnc_hashCreate;
                        [GVAR(STORE),_id,_args] call ALiVE_fnc_HashSet;
                    };

                    //Set static data
                    [_args,QGVAR(ID),_id] call ALiVE_fnc_HashSet;
                    [_args,QGVAR(TYPE),typeof _x] call ALiVE_fnc_HashSet;
                    [_args,QGVAR(POSITION),getposATL _x] call ALiVE_fnc_HashSet;
                    [_args,QGVAR(VECDIRANDUP),[vectorDir _x,vectorUp _x]] call ALiVE_fnc_HashSet;
                    [_args,QGVAR(CARGO),[_x] call ALiVE_fnc_getObjectCargo] call ALiVE_fnc_HashSet;
                    [_args,QGVAR(FUEL),[_x] call ALiVE_fnc_getObjectFuel] call ALiVE_fnc_HashSet;
                    [_args,QGVAR(DAMAGE),[_x] call ALiVE_fnc_getObjectDamage] call ALiVE_fnc_HashSet;
                    [_args,QGVAR(POINTDAMAGE),[_x] call ALiVE_fnc_getObjectPointDamage] call ALiVE_fnc_HashSet;

                    //Set dynamic data (to fight errors on loading back existing data from DB)
                    if (!isnil {_x getvariable QGVAR(CONTAINER)} && {!isnull (_x getvariable QGVAR(CONTAINER))}) then {
                        [_args,QGVAR(CONTAINER),(_x getvariable QGVAR(CONTAINER)) getvariable QGVAR(ID)] call ALiVE_fnc_HashSet;
                    } else {
                        [_args,QGVAR(CONTAINER)] call ALiVE_fnc_HashRem;
                    };

                    //_args call ALiVE_fnc_InspectHash;
                };
            } foreach _objects;

            _result = _args;
        };

        case "removeObject": {
            if (isnil "_args") exitwith {};

            if !(isServer) exitwith {
                [[_logic, _operation, _args],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;
            };

            private ["_object","_id"];

            _object = [_args, 0, objNull, [objNull,""]] call BIS_fnc_param;

            switch (typeName _object) do {
                case ("OBJECT") : {_id = _object getvariable QGVAR(ID)};
                case ("STRING") : {[GVAR(STORE),_object] call ALiVE_fnc_HashRem};
            };

            if (isnil "_id") exitwith {_result = _object};

            _object setvariable [QGVAR(CONTAINER),nil,true];
            _object setvariable [QGVAR(CARGO),nil,true];

            [GVAR(STORE),_id] call ALiVE_fnc_HashRem;
            _object setvariable [QGVAR(ID),nil,true];

            //GVAR(STORE) call ALiVE_fnc_InspectHash;

            _result = GVAR(STORE) select 1;
        };

        case "id" : {
            if (isnil "_args") exitwith {};

            private ["_object","_id"];

            _object = [_args, 0, objNull, [objNull,""]] call BIS_fnc_param;
            _id = _object getvariable QGVAR(ID);

            if (isnil "_id") then {
                _id = format["%1_%2%3",typeof _object, floor(getposATL _object select 0),floor(getposATL _object select 1)];
                _object setvariable [QGVAR(ID),_id,true];
            };

            _result = _id;
        };

        case "carryObject": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            if !([_object,_container] call ALiVE_fnc_canCarry) exitwith {};

            _object setvariable [QGVAR(CONTAINER),_container,true];
            _container setvariable [QGVAR(CARGO),(_container getvariable [QGVAR(CARGO),[]]) + [_object],true];

            _object attachTo [_container, [
                0,
                1 - (boundingBox _container select 0 select 1) - (boundingBox _object select 0 select 1),
                (boundingBox _container select 0 select 2) - (boundingBox _object select 0 select 2) + 0.4
            ]];

            [[_logic,"updateObject",[_container,_object]],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;

            _result =_container;
        };

        case "dropObject": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            _object setvariable [QGVAR(CONTAINER),nil,true];
            _container setvariable [QGVAR(CARGO),(_container getvariable [QGVAR(CARGO),[]]) - [_object],true];

            // Detach and reposition for a save placement
            detach _object;
            // Reposition to fit surface gradient
            _object setpos getpos _object;
            // Set height correctly
            _object setposATL [getposATL _object select 0, getposATL _object select 1, if !(isNull _container) then {getposATL _container select 2} else {getposATL _object select 2}];

            [[_logic,"updateObject",[_container,_object]],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;

            _result = _object;
        };

        case "stowObject": {
            if (isnil "_args") exitwith {};

            //Do it globally so all clients are updated correctly all the time
            if !(isServer) exitwith {
                [[_logic, _operation, _args],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;
            };

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            if !([_object,_container] call ALiVE_fnc_canStow) exitwith {};

            [_logic,"dropObject",[_object,player]] call ALiVE_fnc_logistics;

            _object setvariable [QGVAR(CONTAINER),_container,true];
            _container setvariable [QGVAR(CARGO),(_container getvariable [QGVAR(CARGO),[]]) + [_object],true];

            if (isMultiplayer && isServer) then {_object hideObjectGlobal true; _object enableSimulationGlobal false} else {_object hideObjectGlobal true; _object enableSimulation false};

            [_logic,"updateObject",[_container,_object]] call ALIVE_fnc_logistics;

            _result = _container;
        };

        case "stowObjects": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            {[_logic,"stowObject",[_x,_container]] call ALiVE_fnc_logistics} foreach (nearestObjects [_container, GVAR(STOWABLE) select 1, 15]);

            _result = _container;
        };

        case "unloadObject": {
            if (isnil "_args") exitwith {};

            //Do it globally so all clients are updated correctly all the time
            if !(isServer) exitwith {
                [[_logic, _operation, _args],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;
            };

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            if ([_object,_container] call ALiVE_fnc_canStow) exitwith {};

            _object setvariable [QGVAR(CONTAINER),nil,true];
            _container setvariable [QGVAR(CARGO),(_container getvariable [QGVAR(CARGO),[]]) - [_object],true];

            if (isMultiplayer && isServer) then {_object hideObjectGlobal false; _object enableSimulationGlobal true} else {_object hideObjectGlobal false; _object enableSimulation true};

            _object setpos (
            [
                getpos _container, // center position
                (sizeOf typeOf _container) + (sizeOf typeOf _object), // minimum distance
                (sizeOf typeOf _container) + (sizeOf typeOf _object * 4), // maximum distance
                sizeOf typeOf _object, // minimum to nearest object
                0, // water mode
                1, // gradient
                0, // shore mode
                [], // blacklist
                [
                    _container getpos [(sizeOf typeOf _container) + (sizeOf typeOf _object * 4), random(360)], // default position on land
                    _container getpos [(sizeOf typeOf _container) + (sizeOf typeOf _object * 4), random(360)] // default position on water
                ]
            ] call BIS_fnc_findSafePos);

            [_logic,"updateObject",[_container,_object]] call ALIVE_fnc_logistics;

            _result = _container;
        };

        case "unloadObjects": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            // if (isNull _container) then {_container = _object};

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            {[_logic,"unloadObject",[_x,_container]] call ALiVE_fnc_logistics} foreach (_container getvariable [QGVAR(CARGO),[]]);

            _result = _container;
        };

        case "towObject": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            if !([_object,_container] call ALiVE_fnc_canTow) exitwith {};

            _object attachTo [_container, [
                0,
                (boundingBox _container select 0 select 1) + (boundingBox _container select 0 select 1) + 2,
                (boundingBox _container select 0 select 2) - (boundingBox _container select 0 select 2) + 0.4
            ]];

            _object setvariable [QGVAR(CONTAINER),_container,true];
            _container setvariable [QGVAR(CARGO_TOW),(_container getvariable [QGVAR(CARGO_TOW),[]]) + [_object],true];

            [[_logic,"updateObject",[_container,_object]],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;

            _result = _container;
        };

        case "untowObject": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            if ([_object,_container] call ALiVE_fnc_canTow) exitwith {};

            _object setvariable [QGVAR(CONTAINER),nil,true];
            _container setvariable [QGVAR(CARGO_TOW),(_container getvariable [QGVAR(CARGO_TOW),[]]) - [_object],true];

            detach _object;
            _object setposATL [getposATL _object select 0, getposATL _object select 1,0];

            [[_logic,"updateObject",[_container,_object]],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;

            _result = _container;
        };

        case "liftObject": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            if !([_object,_container] call ALiVE_fnc_canLift) exitwith {};

            _object attachTo [
                _container,
                [0,0,(boundingBox _container select 0 select 2) - (boundingBox _object select 0 select 2) - (getPos _container select 2) + 0.5]
            ];

            _object setvariable [QGVAR(CONTAINER),_container,true];
            _container setvariable [QGVAR(CARGO_LIFT),(_container getvariable [QGVAR(CARGO_LIFT),[]]) + [_object],true];

            [[_logic,"updateObject",[_container,_object]],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;

            _result = _container;
        };

        case "releaseObject": {
            if (isnil "_args") exitwith {};

            private ["_object","_container","_objectID","_containerID"];

            _object = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _container = [_args, 1, objNull, [objNull]] call BIS_fnc_param;

            _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            if ([_object,_container] call ALiVE_fnc_canLift) exitwith {};

            _object setvariable [QGVAR(CONTAINER),nil,true];
            _container setvariable [QGVAR(CARGO_LIFT),(_container getvariable [QGVAR(CARGO_LIFT),[]]) - [_object],true];

            detach _object;
            _object setposATL [getposATL _object select 0, getposATL _object select 1,0];

            [[_logic,"updateObject",[_container,_object]],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;

            _result = _container;
        };

        case "fillContainer": {
            if (isnil "_args") exitwith {};

            //Do it globally so all clients are updated correctly all the time
            if !(isServer) exitwith {
                [[_logic, _operation, _args],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;
            };

            private ["_container","_containerID","_list"];

            _container = [_args, 0, objNull, [objNull]] call BIS_fnc_param;
            _list = [_args, 1, [], [[]]] call BIS_fnc_param;

            if (count _list == 0) exitwith {};

            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            {
                private ["_object","_objectID"];

                _object = _x createVehicle ([getposATL _container,50] call CBA_fnc_RandPos);
                _objectID = [_logic,"id",_object] call ALiVE_fnc_logistics;

                _object setvariable [QGVAR(CONTAINER),_container,true];
                _container setvariable [QGVAR(CARGO),(_container getvariable [QGVAR(CARGO),[]]) + [_object],true];

                if (isMultiplayer && isServer) then {_object hideObjectGlobal true; _object enableSimulationGlobal false} else {_object hideObjectGlobal true; _object enableSimulation false};

                _list set [_foreachIndex,_object];
            } foreach _list;

            [_logic,"updateObject",[_container] + _list] call ALIVE_fnc_logistics;

            _result = _list;
        };

        case "clearContainer": {
            if (isnil "_args") exitwith {};

            //Do it globally so all clients are updated correctly all the time
            if !(isServer) exitwith {
                [[_logic, _operation, _args],"ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;
            };

            private ["_container","_containerID"];

            _container = [[_args], 0, objNull, [objNull]] call BIS_fnc_param;
            _containerID = [_logic,"id",_container] call ALiVE_fnc_logistics;

            _list = _container getvariable [QGVAR(CARGO),[]];

            if (count _list == 0) exitwith {};

            {[_logic,"removeObject",_x] call ALIVE_fnc_logistics; deleteVehicle _x} foreach _list;

            _container setvariable [QGVAR(CARGO),[],true];

            [_logic,"updateObject",[_container]] call ALIVE_fnc_logistics;

            _result = _list;
        };

        case "addAction": {
            private ["_object","_operation","_id","_condition","_text","_input","_container","_die"];

            _object = [_args, 0, objNull, [objNull,[]]] call BIS_fnc_param;
            _operation = [_args, 1, "", [""]] call BIS_fnc_param;

            switch (typename _object) do {
                case ("ARRAY") : {_object = _object select 0};
                default {};
            };

            switch (_operation) do {
                case ("carryObject") : {
                    _text = "Carry object";
                    _input = {(nearestObjects [_this select 1, ALiVE_SYS_LOGISTICS_CARRYABLE select 1, 5]) select 0};
                    _container = {_this select 1};
                    _condition = "private _nearestObject = (nearestObjects [_target, ALiVE_SYS_LOGISTICS_CARRYABLE select 1, 10]) select 0; alive _target && {_nearestObject distance _target < 5} && {isnil {_nearestObject getvariable 'ALiVE_SYS_LOGISTICS_CONTAINER'}} && {[_nearestObject,_target] call ALiVE_fnc_canCarry}";
                };
                case ("dropObject") : {
                    _text = "Drop object";
                    _input = {
                        private _player = _this select 1;
                        private _objs = attachedObjects _player;
                        private _result = objNull;

                        {
                            if (!isNull _x) exitWith {
                                _result = _x;
                            };
                        } forEach _objs;

                        if (isNull _result) then {
                            _result = (_player getVariable ["ALiVE_SYS_LOGISTICS_CARGO",[]]) select 0;
                        };

                        _result;
                    };
                    _container = {_this select 1};
                    _condition = "alive _target && {vehicle _target == _originalTarget} && {{!isnull _x} count (attachedObjects _target) > 0 || {count (_target getvariable ['ALiVE_SYS_LOGISTICS_CARGO',[]]) > 0}}";
                };
                case ("unloadObjects") : {
                    _text = "Load out cargo";
                    _input = {cursortarget};
                    _container = {((nearestObjects [_this select 1, ALiVE_SYS_LOGISTICS_STOWABLE select 0, 8]) select 0)};
                    _condition = "alive _target && {cursortarget distance _target < 5} && {count (cursortarget getvariable ['ALiVE_SYS_LOGISTICS_CARGO',[]]) > 0}";
                };
                case ("stowObjects") : {
                    _text  = "Stow in cargo";
                    _input = {objNull};
                    _container = {cursortarget};
                    _condition = "alive _target && {cursortarget distance _target < 5} && {[((nearestObjects [cursortarget, ALiVE_SYS_LOGISTICS_STOWABLE select 1, 8]) select 0),cursortarget] call ALiVE_fnc_canStow}";
                };
                case ("towObject") : {
                    _text  = "Tow object";
                    _input = {cursortarget};
                    _container = {((nearestObjects [_this select 1, ALiVE_SYS_LOGISTICS_TOWABLE select 0, 15]) select 0)};
                    _condition = "alive _target && {cursortarget distance player < 5} && {[cursortarget,(nearestObjects [cursortarget, ALiVE_SYS_LOGISTICS_TOWABLE select 0, 15]) select 0] call ALiVE_fnc_canTow}";
                };
                case ("untowObject") : {
                    _text  = "Untow object";
                    _input = {cursortarget};
                    _container = {attachedTo cursortarget};
                    _condition = "alive _target && {cursortarget distance _target < 5} && {{_x == cursortarget} count ((attachedTo cursortarget) getvariable ['ALiVE_SYS_LOGISTICS_CARGO_TOW',[]]) > 0}";
                };
                case ("liftObject") : {
                    _text  = "Lift object";
                    _input = {((nearestObjects [vehicle (_this select 1), ALiVE_SYS_LOGISTICS_LIFTABLE select 1, 15]) select 0)};
                    _container = {vehicle (_this select 1)};
                    _condition = "alive _target && {(getposATL (vehicle _target) select 2) > 10} && {(getposATL (vehicle _target) select 2) < 20} && {[(nearestObjects [vehicle (_target), ALiVE_SYS_LOGISTICS_LIFTABLE select 1, 20]) select 0, vehicle _target] call ALiVE_fnc_canLift}";
                };
                case ("releaseObject") : {
                    _text  = "Release object";
                    _input = {attachedObjects (vehicle (_this select 1)) select 0};
                    _container = {vehicle (_this select 1)};
                    _condition = "alive _target && {(getposATL (vehicle _target) select 2) > 10} && {(getposATL (vehicle _target) select 2) < 20} && {count ((vehicle _target) getvariable ['ALiVE_SYS_LOGISTICS_CARGO_LIFT',[]]) > 0}";
                };
                default {_die = true};
            };

            if !(isnil "_die") exitwith {_result = -1};

            _id = _object addAction [
                _text,
                {[MOD(SYS_LOGISTICS), (_this select 3 select 0), [_this call (_this select 3 select 1),
                    _this call (_this select 3 select 2)]] call ALiVE_fnc_logistics},
                [_operation,_input,_container],
                1,
                false,
                true,
                "",
                _condition
            ];

            _object setvariable [format["ALiVE_SYS_LOGISTICS_%1",_operation],_id];

            _result = _id;
        };

        case "removeAction": {
            if (isnil "_args") exitwith {};

            private ["_object","_operation","_id"];

            _object = [_args, 0, objNull, [objNull,[]]] call BIS_fnc_param;
            _operation = [_args, 1, "", [""]] call BIS_fnc_param;

            _id = _object getvariable [format["ALiVE_SYS_LOGISTICS_%1",_operation],-1];
            _object setvariable [format["ALiVE_SYS_LOGISTICS_%1",_operation],nil];
            _object removeAction _id;

            _result = _id;
        };

        case "addActions": {
            if !(hasInterface) exitwith {};

            _result = call GVAR(ACTIONS);
        };

        case "removeActions": {

            _args = [_this, 2, player, [objNull]] call BIS_fnc_param;

            if !(hasInterface) exitwith {
                [[_logic, _operation, _args],"ALIVE_fnc_logistics", owner _args, false] call BIS_fnc_MP;
            };

            [_logic,"removeAction",[_args,"carryObject"]] call ALiVE_fnc_logistics;
            [_logic,"removeAction",[_args,"dropObject"]] call ALiVE_fnc_logistics;
            [_logic,"removeAction",[_args,"stowObjects"]] call ALiVE_fnc_logistics;
            [_logic,"removeAction",[_args,"unloadObjects"]] call ALiVE_fnc_logistics;
            [_logic,"removeAction",[_args,"towObject"]] call ALiVE_fnc_logistics;
            [_logic,"removeAction",[_args,"untowObject"]] call ALiVE_fnc_logistics;
            [_logic,"removeAction",[_args,"liftObject"]] call ALiVE_fnc_logistics;
            [_logic,"removeAction",[_args,"releaseObject"]] call ALiVE_fnc_logistics;

            _args setvariable [QGVAR(ACTIONS),nil];

            _result = false;
        };

        case "setEH" : {
            if (isnil "_args") exitwith {};

            private ["_objects"];

            switch (typeName _args) do {
                case ("OBJECT") : {_objects = [_args]};
                case ("ARRAY") : {_objects = _args};
                case ("STRING") : {_objects = []};
                default {_objects = _args};
            };

            if (typeName _args == "STRING") exitWith {
                switch _args do {
                    case (QGVAR(BUILDINGCHANGED)) : {

                        _result = addMissionEventHandler ["BuildingChanged", 
                        {
                            params ["_from", "_to", "_isRuins"];

                            if (damage _from >= 1) then {
                                [ALiVE_SYS_LOGISTICS,"updateObject",[_from]] call ALIVE_fnc_logistics;
                            };

                            if (!isnil QMOD(SYS_LOGISTICS) && {MOD(SYS_LOGISTICS) getvariable [QGVAR(LISTENER),false]}) then {
                                ["ALiVE SYS LOGISTICS EH BUILDINGCHANGED firing"] call ALiVE_fnc_DumpR;
                            };
                        }];
                    };
                };

                _result;
            };

            {
                private ["_object"];

                _object = _x;

                //All Localities
                _object setvariable [QGVAR(EH_KILLED), _object getvariable [QGVAR(EH_KILLED), _object addEventHandler ["Killed", {

                        _object = _this select 0;

                        if (isPlayer _object) then {
                            if (vehicle _object == _object) then {
	                            //Drop object if player is carrying while beeing killed
	                            {[MOD(SYS_LOGISTICS),"dropObject",[_x,_object]] call ALIVE_fnc_logistics} foreach (_object getvariable [QGVAR(CARGO),[]]);
                            } else {
                                //Update vehicle if player is in a vehicle
		                        [MOD(SYS_LOGISTICS),"updateObject",[vehicle _object]] call ALIVE_fnc_logistics;
                            };
                            
                            //Deactivate actions
                            [MOD(SYS_LOGISTICS),"removeActions",_object] call ALIVE_fnc_logistics;                   
                        };

                        //Update object to persist the destroyed state
                        [MOD(SYS_LOGISTICS),"updateObject",[_object]] call ALIVE_fnc_logistics;

                        if (!isnil QMOD(SYS_LOGISTICS) && {MOD(SYS_LOGISTICS) getvariable [QGVAR(LISTENER),false]}) then {
                            ["ALiVE SYS LOGISTICS EH Killed firing"] call ALiVE_fnc_DumpR;
                        };
                }]]];

                //Clientside only section
                if (hasInterface) then {
                    //apply these EHs on players
                    _object setvariable [QGVAR(EH_INVENTORYCLOSED),_object getvariable [QGVAR(EH_INVENTORYCLOSED),
                        
                        _object addEventHandler ["InventoryClosed", {
                            if !((_this select 1) isKindOf "Man") then {[ALiVE_SYS_LOGISTICS,"updateObject",[_this select 1, _this select 0]] call ALIVE_fnc_logistics};
                            if (!isnil QMOD(SYS_LOGISTICS) && {MOD(SYS_LOGISTICS) getvariable [QGVAR(LISTENER),false]}) then {["ALiVE SYS LOGISTICS EH InventoryClosed firing"] call ALiVE_fnc_DumpR};
                        }]
                    ]];
                };

                //Serverside only section
                if (isServer) then {
                    //apply these EHs on vehicles
                    if ({_object isKindOf _x} count ["LandVehicle","Air","Ship"] > 0) then {

                        _object setvariable [QGVAR(EH_GETOUT), _object getvariable [QGVAR(EH_GETOUT), _object addEventHandler ["GetOut",
                            {
                                if (isPlayer (_this select 2) && {!((_this select 1) == "cargo")}) then {
                                    private _blacklist = if !(isNil QMOD(SYS_LOGISTICS)) then {MOD(SYS_LOGISTICS) getVariable ["blacklist", DEFAULT_BLACKLIST]} else {[]};
                                    if !(typeof (_this select 0) in _blacklist) then {
                                        [ALiVE_SYS_LOGISTICS,"updateObject",[_this select 0]] call ALIVE_fnc_logistics;
                                        if (!isnil QMOD(SYS_LOGISTICS) && {MOD(SYS_LOGISTICS) getvariable [QGVAR(LISTENER),false]}) then {
                                            ["ALiVE SYS LOGISTICS EH Getout firing"] call ALiVE_fnc_DumpR
                                        };
                                    };
                                };
                            }
                        ]]];
                    };
                };
            } foreach _objects;

            _result = _objects;
        };

        case "allObjects" : {
            if (isnil "_args" || {isnull _args}) then {_args = []};

            private ["_position","_radius","_list","_objects"];

            _position = [_args, 0, getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition")] call BIS_fnc_param;
            _radius = [_args, 1, 30000] call BIS_fnc_param;
            _list = [_args, 2, ["Reammobox_F","Static","ThingX","LandVehicle","Air"]] call BIS_fnc_param;

            _objects = [];
            {
                private ["_object"];

                _object = _x;
                if ((_x distance _position <= _radius) && {({_object iskindOf _x} count _list) > 0}) then {
                    _objects pushback _object;
                };
            } foreach (allMissionObjects "");

            _result = _objects;
        };

        case "destroy": {
            [[_logic, "destroyGlobal"],"ALIVE_fnc_logistics",true, false] call BIS_fnc_MP;
        };

        case "destroyGlobal": {

            MOD(SYS_LOGISTICS) = _logic;

            //Remove Actions on clients
            if (hasInterface) then {
                    {[_logic,"removeAction",[player,_x]] call ALiVE_fnc_logistics} foreach ["carryObject","dropObject","stowObjects","unloadObjects","towObject","untowObject","liftObject","releaseObject"];

                    // remove main menu
                    [
                            "player",
                            [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                            -9500,
                            [
                                    "call ALIVE_fnc_logisticsMenuDef",
                                    ["main", "alive_flexiMenu_rscPopup"]
                            ]
                    ] call CBA_fnc_flexiMenu_Remove;
            };

            //delay
            sleep 1;

            //Delete class
            if (isServer) then {

                    _logic setVariable ["super", nil];
                    _logic setVariable ["class", nil];
                    _logic setVariable ["init", nil];

                    [_logic,"destroy"] call SUPERCLASS;
            };
        };

        case "state" : {
            if ((isnil "_args") || {!isServer}) exitwith {_result = GVAR(STORE)};

            private ["_startObjects"];

            //Get all logistics objects
            TRACE_1("ALiVE SYS LOGISTICS Finding SYS_LOGISTICS objects!",_logic);

            _startObjects = [_logic,"allObjects"] call ALiVE_fnc_logistics;

            //Set ID on all startobjects
            TRACE_1("ALiVE SYS LOGISTICS Setting IDs and EHs on existing objects!",_logic);

            {
                [_logic,"id",_x] call ALiVE_fnc_logistics;
                [_logic,"setEH",[_x]] call ALiVE_fnc_logistics
            } foreach _startObjects;

            //Check if provided data is valid
            if (count (_args select 1) == 0) exitwith {};

            private ["_collection"];

            //Reset store with provided data
            GVAR(STORE) set [1,_args select 1];
            GVAR(STORE) set [2,_args select 2];

            //defaults
            _createdObjects = [];
            _existing = [];
            _blacklist = ["Man"];

            //if objectID is existing in store then reapply object state (_pos,_vecDirUp,_damage,_fuel)
            {
                private ["_id","_args"];

                _id = [MOD(SYS_LOGISTICS),"id",_x] call ALiVE_fnc_logistics;
                _args = [GVAR(STORE),_id] call ALiVE_fnc_HashGet;

                if !(isnil "_args") then {
                    private ["_pos","_vDirUp","_container","_cargo"];

                    TRACE_1("ALiVE SYS LOGISTICS Resetting state of editor placed object!",_x);

                    //apply values
                    _x setposATL ([_args,QGVAR(POSITION)] call ALiVE_fnc_HashGet);
                    _x setVectorDirAndUp ([_args,QGVAR(VECDIRANDUP)] call ALiVE_fnc_HashGet);

                    //remove in next step
                    _existing pushback _id;
                };
            } foreach _startObjects;

            //creating and remapping non existing vehicles
            {
                private ["_args","_object"];

                _args = [GVAR(STORE),_x] call ALiVE_fnc_HashGet;
                _type = [_args,QGVAR(TYPE)] call ALiVE_fnc_hashGet;

                if (({_type iskindOf _x} count _blacklist) == 0) then {

                    //Get 2D position without altering original data
                    private _position = +([_args,QGVAR(POSITION)] call ALiVE_fnc_hashGet); _position resize 2;
                    
                    //Filter existing objects of same type in a 1m² radius
                    private _near = nearestObjects [_position,[_type],20];
                    private _exists = [];
                    {
                        if (_position distance2D _x < 1) then {
                            _exists pushback _x;
                        };
                    } foreach _near;

                    if (count _exists == 0) then {
                        TRACE_1("ALiVE SYS LOGISTICS Creating non existing object from store!",_x);

                        _object = _type createVehicle ([_args,QGVAR(POSITION)] call ALiVE_fnc_hashGet);
                        _object setvariable [QGVAR(ID),_x,true];
                        _object setposATL ([_args,QGVAR(POSITION)] call ALiVE_fnc_HashGet);
                        _object setVectorDirAndUp ([_args,QGVAR(VECDIRANDUP)] call ALiVE_fnc_HashGet);

                        ["ALiVE SYS LOGISTICS - recreated non existing object %1 of type %2",_object,_type] call ALiVE_fnc_Dump;

                    } else {
                        TRACE_1("ALiVE SYS LOGISTICS Remapping existing map object!",_x);

                        _object = _exists select 0;

                        [_args,QGVAR(ID),[MOD(SYS_LOGISTICS),"id",_object] call ALiVE_fnc_logistics] call ALiVE_fnc_HashSet;
                        [_args,QGVAR(POSITION),getposATL _object] call ALiVE_fnc_hashSet;

                        ["ALiVE SYS LOGISTICS - remapped existing object %1 of type %2",_object,_type] call ALiVE_fnc_Dump;
                    };

                    _createdObjects pushback _object;
                } else {
                    TRACE_1("ALiVE SYS LOGISTICS Removing blacklisted object from store!",_x);

                    [_logic,"removeObject",_x] call ALiVE_fnc_logistics;
                };
             } foreach ((GVAR(STORE) select 1) - _existing);

             private _buildings = [];

             //reset object state or delete if destroyed
             {
                _args = [GVAR(STORE),_x getvariable QGVAR(ID)] call ALiVE_fnc_HashGet;

                if !(isnil "_args") then {
                
                	private _damage = [_args,QGVAR(DAMAGE),0] call ALiVE_fnc_HashGet;
                
                	if !(_damage == 1) then {
                	
                    	TRACE_1("ALiVE SYS LOGISTICS Resetting state for object!",_x);
                    	[_x,_args] call ALiVE_fnc_setObjectState;
	
                   	} else {

                        if (_x isKindOf "House") then {
                            TRACE_1("ALiVE SYS LOGISTICS Destroying building which has been destroyed in a previous session!",_x);

                            ["ALiVE SYS LOGISTICS - Destroying building %1 which has been destroyed in a previous session!",_x] call ALiVE_fnc_Dump;

                            // Do not setdamage or delete directly here but destroy the buildings when mission has started
                            _buildings pushback _x;
                        } else {
                   		    TRACE_1("ALiVE SYS LOGISTICS Deleting object which has been destroyed in a previous session!",_x);

                            ["ALiVE SYS LOGISTICS - Deleting object %1 which has been destroyed in a previous session!",_x] call ALiVE_fnc_Dump;

                   		    deleteVehicle _x;
                        };
                   	};
                };
             } foreach (_startObjects + _createdObjects);

            // Delay building destruction to start of mission or clients and dedicated server will be out of sync
            _buildings spawn {
                waituntil {time > 0};
                {_x setDamage [1,false]} foreach _this;
            };

            _result = GVAR(STORE);
        };

        case "convertData": {
            if (isnil "_args") exitwith {};

            private ["_data","_convertedData","_selection_1","_selection_2"];

            _data = _args;

            if !(typeName _data == "ARRAY" && {count _data > 2} && {count (_data select 2) > 0}) exitwith {_result = _data};

            _dataSet = [
                [QGVAR(ID),"ASL_ID"],
                [QGVAR(TYPE),"ASL_TY"],
                [QGVAR(POSITION),"ASL_PO"],
                [QGVAR(VECDIRANDUP),"ASL_VD"],
                [QGVAR(CARGO),"ASL_CA"],
                [QGVAR(FUEL),"ASL_FU"],
                [QGVAR(DAMAGE),"ASL_DA"],
                [QGVAR(POINTDAMAGE),"ASL_HP"],
                [QGVAR(CONTAINER),"ASL_CO"],
                ["_rev","_rev"]
            ];

            _convertedData = [] call ALIVE_fnc_hashCreate;

            if (isnil {[(_data select 2 select 0),"ASL_ID"] call ALiVE_fnc_HashGet}) then {
                _selection_1 = {_x select 1};
                _selection_2 = {_x select 0};
            } else {
                _selection_1 = {_x select 0};
                _selection_2 = {_x select 1};
            };

            {
                private ["_convertedObject","_args"];

                _convertedObject = [] call ALIVE_fnc_hashCreate;
                _args = [_data,_x] call ALiVE_fnc_HashGet;

                {[_convertedObject,call _selection_1,[_args,call _selection_2] call ALiVE_fnc_HashGet] call ALiVE_fnc_HashSet} foreach _dataSet;
                [_convertedData,_x,_convertedObject] call ALiVE_fnc_HashSet;
            } foreach (_data select 1);

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                _convertedData call ALiVE_fnc_InspectHash;
            };

            _result = _convertedData;
        };

        case "blacklist": {
            if !(isnil "_args") then {
                if(typeName _args == "STRING") then {
                    if !(_args == "") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, "[", ""] call CBA_fnc_replace;
                        _args = [_args, "]", ""] call CBA_fnc_replace;
                        _args = [_args, "'", ""] call CBA_fnc_replace;
                        _args = [_args, """", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;

                        if(count _args > 0) then {
                            _logic setVariable [_operation, _args];
                        };
                    } else {
                        _logic setVariable [_operation, DEFAULT_BLACKLIST];
                    };
                } else {
                    if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                    };
                };
            } else {
                _logic setVariable [_operation, DEFAULT_BLACKLIST];
            };

            _result = _logic getVariable [_operation, DEFAULT_BLACKLIST];
        };

        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};

TRACE_1("ALiVE SYS LOGISTICS - output",_result);

if !(isnil "_result") then {
    _result;
};