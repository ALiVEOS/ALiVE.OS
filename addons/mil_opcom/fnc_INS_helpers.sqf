//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(INS_helpers);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_INS_helpers
Description:
Helper Function to keep transferred and stored code small

Base class for OPCOM objects to inherit from

Parameters:
Several
_timeTaken = _this select 0; //number
_pos = _this select 1; //array
_id = _this select 2; //string
_size = _this select 3; //number
_faction = _this select 4; //string
_factory = _this select 5; //array of [_pos,_class]
_target = _this select 6; //array of [_pos,_class]
_sides = _this select 7; //array of side as strings
_agents = _this select 8; //array of strings

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
none

Examples:
(begin example)
// no example
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

ALiVE_fnc_INS_assault = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _sides = _this select 5;
                _agents = _this select 6;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_suicideTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_CAPTURE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos,_allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_ambush = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_road","_roadObject","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _road = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _roadObject = [[],"convertObject",_road] call ALiVE_fnc_OPCOM;

                // Establish ambush position
                if (alive _roadObject) then {[_objective,"ambush",_road] call ALiVE_fnc_HashSet};

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Place ambient IED trigger
                if (!isnil "ALiVE_mil_IED") then {
                    _trg = createTrigger ["EmptyDetector",getposATL _roadObject];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",true];
                    _trg setTriggerStatements [
                        "this && {(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0",
                            format["null = [getpos thisTrigger,%1,%2,%3] call ALIVE_fnc_createIED",100,text _id,ceil(random 2)],
                            format["null = [getpos thisTrigger,%1] call ALIVE_fnc_removeIED",text _id]
                    ];
                };

                _event = ['OPCOM_RECON',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos,_allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;

                // Wait 15 minutes for any enemy vehicles to pass before reassigning
                _timeTaken = time; waituntil {time - _timeTaken > 900};

                // Remove ambush marker
                if (alive _roadObject) then {deletemarker format["Ambush_%1",getposATL _roadObject]; [_objective,"ambush"] call ALiVE_fnc_HashRem};
};

ALiVE_fnc_INS_retreat = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _sides = _this select 5;
                _agents = _this select 6;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_allSides - _sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                //remove installations if existing
                {
                    _object = [[],"convertObject",[_objective,_x,[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

                    if (alive _object && {_x in ["ied","suicide"]}) then {deletevehicle _object};
                    if (alive _object) then {_object setdamage 1; deleteMarker format["%1_%2",_x,_id]};

                    [_objective,_x] call ALiVE_fnc_HashRem;
                } foreach ["factory","hq","ambush","depot","sabotage","ied","suicide"];

                // Reset all actions done on that objective so they can be performed again
                [_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashSet;

                // Reduce hostility level after retreat
                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos, _allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;

                _event = ['OPCOM_DEFEND',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
};

ALiVE_fnc_INS_factory = {
                private ["_timeTaken","_pos","_center","_id","_size","_faction","_sides","_agents","_building","_objective","_CQB","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Store center position
                _center = _pos;

                // Establish factory
                if (alive _factory) then {
                    // Get indoor Housepos
                    _pos = getposATL _factory;
                    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;
                    _pos = if (count _positions > 0) then {(selectRandom _positions)} else {_pos};

                    // Create factory
                    [_factory,_id] call ALiVE_fnc_INS_spawnIEDfactory;

                    // Create virtual guards
                    {[_x,"addHouse",_factory] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set factory
                    [_objective,"factory",[[],"convertObject",_factory] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Reset to center position
                _pos = _center;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos, _allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_ied = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_section","_objective", "_num"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // If IED module is used add IEDs and VBIEDs according to IED module settings
                if (!isnil "ALiVE_MIL_IED") then {
                    _trg = createTrigger ["EmptyDetector",_pos];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",true];
                    _num = ceil(_size/100);
                    _trg setTriggerStatements [
                        "this && {(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0",
                            format["null = [getpos thisTrigger,%1,'%2',%3] call ALIVE_fnc_createIED",_size,text _id,_num],
                            format["null = [getpos thisTrigger,'%1'] call ALIVE_fnc_removeIED",text _id]
                    ];

                    [MOD(MIL_IED), "storeTrigger", [_size,format["%1",_id],_pos,true,"IED",_num]] call ALiVE_fnc_IED;

                    [_pos,_size,1] call ALiVE_fnc_placeVBIED;

                    _placeholders = ((nearestobjects [_pos,["Static"],150]) + (_pos nearRoads 150));
                    if (!isnil "_placeholders" && {count _placeholders > 0}) then {_trg = _placeholders select 0};

                    [_objective,"ied",[[],"convertObject",_trg] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM rogue command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos, _allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_suicide = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_objective","_civFactions"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _civFactions = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Place ambient suiciders trigger
                if (!isnil "ALiVE_mil_IED") then {
                    _trg = createTrigger ["EmptyDetector",_pos];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",false];
                    _trg setTriggerStatements [
                        "this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)",
                        format ["null = [[getpos thisTrigger,%1,'%2'],thisList] call ALIVE_fnc_createBomber", _size, (selectRandom _civFactions)],
                         ""
                    ];

                    _placeholders = ((nearestobjects [_pos,["Static"],150]) + (_pos nearRoads 150));
                    if (!isnil "_placeholders" && {count _placeholders > 0}) then {_trg = _placeholders select 0};

                    [_objective,"suicide",[[],"convertObject",_trg] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_suicideTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos, _allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_sabotage = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_target","_profileID","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _target = _this select 6;
                _sides = _this select 7;
                _agents = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;
                _target = [[],"convertObject",_target] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Assign sabotage target
                if (alive _target) then {[_objective,"sabotage",[[],"convertObject",_target] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet};

                // Add TACOM Sabotage command on all selected agents
                {
                    private ["_agent"];
                     _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_sabotage", "managed", [getposATL _target]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos, _allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;

                // Wait 15 minutes for Sabotage to happen
                _timeTaken = time; waituntil {time - _timeTaken > 900};
};

ALiVE_fnc_INS_roadblocks = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_CQB","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _handle = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Spawn CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                // Spawn roadblock only until a max amount of roadblocks per objective is reached (size 600 will allow for 3 roadblocks)
                if (isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS" || {{_pos distance _x < _size} count ALiVE_CIV_PLACEMENT_ROADBLOCKS < ceil(_size/200)}) then {
                    private _roads = [_pos, _size, ceil(_size/200), false] call ALiVE_fnc_createRoadblock;

                    // Create disable action on newly created roadblocks
                    {
                        private ["_charge","_actionObjects","_actionObject","_nearRoads","_road","_roadConnectedTo","_connectedRoad","_direction","_roadSidePos"];
                        _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo", position _x, [], 0, "CAN_COLLIDE"];
                        _charge hideObjectGlobal true;
                        _charge allowDamage false;

                        // Check if bargate is withing spawned composition
                        _actionObjects = nearestObjects [_x, ["Land_BarGate_F"], 10];

                        // Check if bargate was found. If not we'll spawn a crate.
                        if (count _actionObjects > 0) then {
                            
                            // Select the bargate.
                            _actionObject = _actionObjects select 0;
                        } else {
                            // Check for roads near composition creation position
                           _nearRoads = position _x nearRoads 10;

                            // Check if near roads were found. If they were, we get direction.
                            if(count _nearRoads > 0) then {
                                _road = _nearRoads select 0;
                                _roadConnectedTo = roadsConnectedTo _road;
                                _connectedRoad = _roadConnectedTo select 0;
                                if!(isNil '_connectedRoad') then {
                                    _direction = _road getRelDir _connectedRoad;
                                };
                            };

                            // Create the crate and set its position and move it sideways to be on the roadside. (Works Okay for now)
                            _actionObject = createVehicle ["Box_FIA_Wps_F", position _road, [], 0, "CAN_COLLIDE"];
                            _actionObject allowDamage false;
                            _actionObject setDir _direction;
                            _objectLocation = getPos _actionObject;
                            _roadSidePos = [(_objectLocation select 0) - 6, (_objectLocation select 1) + 6];
                            _actionObject setPos _roadSidePos;
                            _actionObject setVectorUp [0,0,1];
                        };

                        [
                            _actionObject,
                            "disable the roadblock!",
                            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                            "_this distance2D _target < 3",
                            "_caller distance2D _target < 3",
                            {},
                            {},
                            {
                                params ["_target", "_caller", "_ID", "_arguments"];

                                private _charge = _arguments select 0;

                                [getpos _charge,30] remoteExec  ["ALiVE_fnc_RemoveComposition",2];

                                ["Nice Job", format ["%1 disabled the roadblock at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side (group _caller)];

                                deletevehicle _charge;
                            },
                            {},
                            [_charge],
                            15
                        ] remoteExec ["BIS_fnc_holdActionAdd", 0,true];
                    } foreach _roads;
                };

                // Identify location
                [_objective,"roadblocks",[[],"convertObject",_pos nearestObject "building"] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos, _sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos, _allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_depot = {
                private ["_timeTaken","_center","_id","_size","_faction","_sides","_agents","_depot","_CQB","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _depot = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Store center position
                _center = _pos;

                // Convert to data that can be persistet
                _depot = [[],"convertObject",_depot] call ALiVE_fnc_OPCOM;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Establish Depot
                if (alive _depot) then {
                    [_depot,_id] call ALiVE_fnc_INS_spawnDepot;

                    // Create virtual guards
                    {[_x,"addHouse",_depot] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set depot
                    [_objective,"depot",[[],"convertObject",_depot] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM get weapons command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;
                    if (!isnil "_agent" && {_foreachIndex < 3}) then {[_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent};
                } foreach _agents;

                // Restore center position
                _pos = _center;

                // Spawn CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_pos,_sides, 20] call ALiVE_fnc_updateSectorHostility;
                [_pos,_allSides - _sides, -20] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_recruit = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_HQ","_CQB","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _HQ = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Store center position
                _center = _pos;

                // Convert to data that can be persistet
                _HQ = [[],"convertObject",_HQ] call ALiVE_fnc_OPCOM;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Establish HQ
                if (alive _HQ) then {
                    // Create HQ
                    [_HQ,_id] call ALiVE_fnc_INS_spawnHQ;

                    // Get indoor Housepos
                    _pos = getposATL _HQ;
                    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;
                    _pos = if (count _positions > 0) then {(selectRandom _positions)} else {_pos};

                    // Create virtual guards
                    {[_x,"addHouse",_HQ] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set HQ
                    [_objective,"HQ",[[],"convertObject",_HQ] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;
                    if (!isnil "_agent" && {_foreachIndex < 3}) then {[_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent};
                } foreach _agents;

                // Restore center position
                _pos = _center;

                // Add CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                // Recruit 5 times
                [_pos,_size,_id,_faction,_HQ,_sides,_agents] spawn {
                    private ["_pos","_size","_id","_faction","_targetBuilding","_sides","_agents","_created"];

                    _pos = _this select 0;
                    _size = _this select 1;
                    _id = _this select 2;
                    _faction = _this select 3;
                    _HQ = _this select 4;
                    _sides = _this select 5;
                    _agents = _this select 6;
                    _allSides = ["EAST","WEST","GUER"];

                    _created = 0;

                    for "_i" from 1 to (count _agents) do {

                        // Delay 30-60 mins before a recruitment takes place.
                        sleep (1800 + random 1800);

                        // Only recruit if there is an HQ existing and up to 5 groups at max to not spam the map
                        if (!alive _HQ || {_created >= 5}) exitwith {};

                        // 50/50 chance the agent turns into insurgents
                        if (random 1 < 0.5) then {
	                        _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
	                        _recruits = [_group, [_pos,10,_size,1,0,0,0,[],[_pos]] call BIS_fnc_findSafePos, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;
	                        {[_x, "setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",[_size + 200,"SAFE",[0,0,0]]]] call ALIVE_fnc_profileEntity} foreach _recruits;

	                        [_pos,_sides, 10] call ALiVE_fnc_updateSectorHostility;
	                        [_pos,_allSides - _sides, -10] call ALiVE_fnc_updateSectorHostility;

	                        _created = _created + 1;
                         };
                    };
                };

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
};

ALiVE_fnc_INS_idle = {
    private ["_time"];

    _time = time;

    waituntil {time - _time > _this};
};

ALiVE_fnc_spawnFurniture = {

    private ["_pos","_furniture","_bomb","_box","_created"];

    _building = _this select 0;
    _ieds = _this select 1;
    _add = _this select 2;
    _ammo = _this select 3;

    if (!(alive _building) || {count (_building getvariable [QGVAR(furnitured),[]]) > 0}) exitwith {[]};

    _furnitures = ["Land_RattanTable_01_F"];
    _bombs = ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo"];
    _objects = ["Land_Canteen_F","Land_TinContainer_F"];
    _boxes = ["VirtualReammoBox_small_F"];
    _created = [];

    _pos = getposATL _building;
    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;

    if (count _positions == 0) exitwith {
        ["ALiVE MIL OPCOM Insurgency has not found indoor Houspositions to place IED Factory/HQ/depot objects for building %1 at %2",_building, getposATL _building] call ALiVE_fnc_Dump;
        [];
    };

    {
        private ["_pos"];

        _pos = _x;

        if ({(_pos select 2) - (_x select 2) < 0.5} count _positions > 1) then {
            if (random 1 < 0.3) then {
                _furniture = createVehicle [(selectRandom _furnitures), _pos, [], 0, "CAN_COLLIDE"];
                _furniture setposATL _pos;
                _furniture setdir getdir _building;

                // Disable sim to avoid flipping furniture. Bombs are not affected and still exploding.
                // Once building is destroyed or site is disabled, the furniture gets deleted.
                _furniture enableSimulation false;

                _created pushback _furniture;

                if (_ieds) then {
                    _bomb = createVehicle [(selectRandom _bombs), getposATL _furniture, [], 0, "CAN_COLLIDE"];
                    _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo",getposATL _bomb, [], 0, "CAN_COLLIDE"];

                    _bomb attachTo [_furniture, [0,0,_furniture call ALiVE_fnc_getRelativeTop]];
                    _charge attachTo [_bomb, [0,0,0]];

                    // Add damage handler
                    _ehID = _charge addeventhandler ["HandleDamage",{
                        private ["_trgr","_IED"];

                        if (isPlayer (_this select 3)) then {
                            _bomb = attachedTo (_this select 0);
                            _ehID = _bomb getVariable "ehID";

                            "M_Mo_120mm_AT" createVehicle [(getpos (_this select 0)) select 0, (getpos (_this select 0)) select 1,0];

                            _bomb removeEventhandler ["HandleDamage",_ehID];

                            deletevehicle (_this select 0);
                            deleteVehicle _bomb;
                        };
                    }];

                    _bomb setVariable ["ehID",_ehID, true];
                    _bomb setvariable ["charge", _charge, true];

                    _created pushback _bomb;
                    _created pushback _charge;
                };
            } else {
                if (_add && {random 1 < 0.5}) then {
                    _furniture = createVehicle [(selectRandom _furnitures), _pos, [], 0, "CAN_COLLIDE"];
                    _furniture setdir getdir _building;

                    _object = createVehicle [(selectRandom _objects), _pos, [], 0, "CAN_COLLIDE"];
                    _object attachTo [_furniture, [0,0,(_furniture call ALiVE_fnc_getRelativeTop) + 0.15]];
 
                    _created pushback _furniture;
                    _created pushback _object;
                } else {
                    if (_ammo && {random 1 < 0.5}) then {
                        _box = createVehicle [(selectRandom _boxes), _pos, [], 0, "CAN_COLLIDE"];
                        _box setdir (_building getDir _box);

                        _created pushback _box;
                    };
                };
            };
        };
    } foreach _positions;

    _building setvariable [QGVAR(furnitured),_created];

    _created
};

ALiVE_fnc_INS_spawnIEDfactory = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;

    if !(alive _building) exitwith {};

    _building setvariable [QGVAR(factory),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];

    [
        _building,
        "disable the IED factory!",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "_this distance2D _target < 3 && {isnil {_this getvariable 'ALiVE_MIL_OPCOM_FACTORY_DISABLED'}}",
        "_caller distance2D _target < 3",
        {},
        {},
        {
            params ["_target", "_caller", "_ID", "_arguments"];

            _target setVariable [QGVAR(FACTORY_DISABLED),true,true];

            [_target, _caller] remoteExec ["ALIVE_fnc_INS_buildingKilledEH",2];

            ["Nice Job", format ["%1 disabled the IED factory at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side (group _caller)];
        },
        {},
        [],
        10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4)
    ] remoteExec ["BIS_fnc_holdActionAdd", 0, true];

    [_building,true,false,false] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_INS_spawnHQ = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;

    if !(alive _building) exitwith {};

    _building setvariable [QGVAR(HQ),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];

    [
        _building,
        "disable the Recruitment HQ!",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "_this distance2D _target < 3 && {isnil {_this getvariable 'ALiVE_MIL_OPCOM_HQ_DISABLED'}}",
        "_caller distance2D _target < 3",
        {},
        {},
        {
            params ["_target", "_caller", "_ID", "_arguments"];

            _target setVariable [QGVAR(HQ_DISABLED),true,true];
            [_target, _caller] remoteExec ["ALIVE_fnc_INS_buildingKilledEH",2];

            ["Congratulations", format ["%1 disabled the Recruitment HQ at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side (group _caller)];
        },
        {},
        [],
        10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4)
    ] remoteExec ["BIS_fnc_holdActionAdd", 0,true];

    [_building,true,false,false] call ALiVE_fnc_spawnFurniture;
    [_building,true,true,false] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_INS_spawnDepot = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;

    if !(alive _building) exitwith {};

    _building setvariable [QGVAR(depot),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];

    [
        _building,
        "disable the weapons depot!",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "_this distance2D _target < 3 && {isnil {_this getvariable 'ALiVE_MIL_OPCOM_DEPOT_DISABLED'}}",
        "_caller distance2D _target < 3",
        {},
        {},
        {
            params ["_target", "_caller", "_ID", "_arguments"];

            _target setVariable [QGVAR(DEPOT_DISABLED),true,true];
            [_target, _caller] remoteExec ["ALIVE_fnc_INS_buildingKilledEH",2];

            ["Good work", format ["%1 disabled the weapons depot at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side (group _caller)];
        },
        {},
        [],
        10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4)
    ] remoteExec ["BIS_fnc_holdActionAdd", 0,true];

    [_building,true,false,true] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_getRelativeTop = {

    _object = _this;

    _bbr = boundingBoxReal _object;
    _p1 = _bbr select 0; _p2 = _bbr select 1;
    _height = abs((_p2 select 2)-(_p1 select 2));
    _height/2;
};

ALIVE_fnc_INS_buildingKilledEH = {

    private ["_building","_killer","_id","_opcom","_pos"];

    _building = _this select 0;
    _killer = _this select 1;
    _pos = getposATL _building;

    private _factory = _building getvariable QGVAR(factory);
    private _depot = _building getvariable QGVAR(depot);
    private _HQ = _building getvariable QGVAR(HQ);
    private _furniture = _building getvariable [QGVAR(furnitured),[]];

    private _installationType = "";
    if !(isnil "_factory") then {
        _id = _factory;
        _installationType = "factory";
    };
    if !(isnil "_depot") then {
        _id = _depot;
        _installationType = "depot";
    };
    if !(isnil "_HQ") then {
        _id = _HQ;
        _installationType = "hq";
    };

    if (isnil "_id") exitwith {};

    // fire event
    // TODO: cba events should be fired from core event loop, not here

    ["ASYMM_INSTALLATION_DESTROYED", [_installationType,_building,_killer]] call CBA_fnc_globalEvent;

    private _event = ['ASYMM_INSTALLATION_DESTROYED', [_installationType,_building,_killer],"OPCOM"] call ALIVE_fnc_event;
    [ALiVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;

    private _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
    private _opcomID = [_objective,"opcomID",""] call ALiVE_fnc_HashGet;
    _pos = [_objective,"center",_pos] call ALiVE_fnc_HashGet;

    if !(isnil "_factory") then {
        [_objective,"factory"] call ALiVE_fnc_HashRem;
        [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["factory"]] call ALiVE_fnc_HashSet;
    };
    if !(isnil "_depot") then {
        [_objective,"depot"] call ALiVE_fnc_HashRem;
        [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["depot"]] call ALiVE_fnc_HashSet;
    };
    if !(isnil "_HQ") then {
        [_objective,"HQ"] call ALiVE_fnc_HashRem;
        [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["recruit"]] call ALiVE_fnc_HashSet;
    };

    {deleteVehicle _x} foreach _furniture;
    _building setvariable [QGVAR(furnitured),[]];

    {
        if (([_x,"opcomID"," "] call ALiVE_fnc_HashGet) == _opcomID) exitwith {
            _opcom = _x
        }
    } foreach OPCOM_instances;

    if !(isnil "_opcom") then {
        _enemy = [_opcom,"sidesenemy",[]] call ALiVE_fnc_HashGet;
        _friendly = [_opcom,"sidesfriendly",[]] call ALiVE_fnc_HashGet;

        [_pos,_friendly, 50] call ALiVE_fnc_updateSectorHostility;
        [_pos,_enemy, -50] call ALiVE_fnc_updateSectorHostility;
    };
};

ALiVE_fnc_INS_compileList = {
            private ["_list"];

            _list = str(_this);
            _list = [_list, "[", ""] call CBA_fnc_replace;
            _list = [_list, "]", ""] call CBA_fnc_replace;
            _list = [_list, "'", ""] call CBA_fnc_replace;
            _list = [_list, """", ""] call CBA_fnc_replace;
            _list = [_list, ",", ", "] call CBA_fnc_replace;
            _list;
};

ALiVE_fnc_INS_filterObjectiveBuildings = {

    params ["_center","_size"];

    private _buildings = [_center, _size] call ALiVE_fnc_getEnterableHouses;

    //["Enterable buildings total: %1",_buildings] call ALiVE_fnc_DumpR;

    {
        private _h = _x;
        private _type = typeOf _h;
        private _index = _foreachIndex;
        private _blacklist = ["tower","cage","platform","trench","bridge"];

        //["Building selected: %1 | %2",typeOf _h, _h] call ALiVE_fnc_DumpR;

        private _buildingPositions = [getposATL _h,5] call ALIVE_fnc_findIndoorHousePositions;
        
        if (count _buildingPositions == 0) then {
            //["Deleted buildingtype %1! No indoor houseposition!",typeof _h] call ALiVE_fnc_DumpR;
            _buildings set [_index,objNull];
        } else {          
            private _dimensions = _h call BIS_fnc_boundingBoxDimensions;

            // too small
            if (((_dimensions select 0) + (_dimensions select 1)) < 10) then {
                //["Deleted buildingtype %1! Building is too small!",typeof _h] call ALiVE_fnc_DumpR;

                _buildings set [_index,objNull];
            } else {
                if (
                    //Building is double as high as broad and is very likely a tower, or contains a blacklisted class
                    (((_dimensions select 2)/2) > (_dimensions select 0) && {((_dimensions select 2)/2) > (_dimensions select 1)})
                    ||
                    {{[_type , _x] call CBA_fnc_find != -1} count _blacklist > 0}
                ) then {
                    //["Deleted buildingtype %1! Building is a tower or blacklisted!",typeof _h] call ALiVE_fnc_DumpR;
                    _buildings set [_index,objNull];
                };
            };
        };
    } foreach _buildings;

    _buildings = _buildings - [objNull];

    //["Enterable buildings filtered: %1",_buildings] call ALiVE_fnc_DumpR;

    _buildings;
};

