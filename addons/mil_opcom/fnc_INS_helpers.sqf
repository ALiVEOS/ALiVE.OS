//#define DEBUG_MODE_FULL
#include <\x\alive\addons\mil_opcom\script_component.hpp>
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
   						 format["null = [getpos thisTrigger,%1,%2,%3] call ALIVE_fnc_createIED",100,str(_id),ceil(random 2)],
   						 format["null = [getpos thisTrigger,%1] call ALIVE_fnc_removeIED",str(_id)]
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
				    _pos = if (count _positions > 0) then {_positions call BIS_fnc_SelectRandom} else {_pos};

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
				private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_section","_objective"];

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

				// Place ambient IED trigger
				if (!isnil "ALiVE_mil_IED") then {
					_trg = createTrigger ["EmptyDetector",_pos];
					_trg setTriggerArea [_size + 250, _size + 250,0,false];
					_trg setTriggerActivation ["ANY","PRESENT",true];
					_trg setTriggerStatements [
						"this && {(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0",
   						 format["null = [getpos thisTrigger,%1,%2,%3] call ALIVE_fnc_createIED",_size,str(_id),ceil(_size/100)],
   						 format["null = [getpos thisTrigger,%1] call ALIVE_fnc_removeIED",str(_id)]
					];
                    
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
						format ["null = [[getpos thisTrigger,%1,'%2'],thisList] call ALIVE_fnc_createBomber", _size, _civFactions call BIS_fnc_SelectRandom],
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
				[_pos,_size,_CQB] spawn ALiVE_fnc_addCQBpositions;
				
				// Spawn roadblock
                [_pos, _size, ceil(_size/200), false] call ALiVE_fnc_createRoadblock;
				[_objective,"roadblocks",[[],"convertObject",_pos nearestObject ""] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;

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
				[_pos,_size,_CQB] spawn ALiVE_fnc_addCQBpositions;

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
				    _pos = if (count _positions > 0) then {_positions call BIS_fnc_SelectRandom} else {_pos};
                    
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
				[_pos,_size,_CQB] spawn ALiVE_fnc_addCQBpositions;

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
                        
                        // Only recruit if there is an HQ existing and up to 5 groups at max to not spam the map
                        if (!alive _HQ || {_created >= 5}) exitwith {};
                        
						_group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
						_recruits = [_group, [_pos,_size] call CBA_fnc_RandPos, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;
						{[_x, "setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",[_size + 200,"SAFE",[0,0,0]]]] call ALIVE_fnc_profileEntity} foreach _recruits;

						[_pos,_sides, 10] call ALiVE_fnc_updateSectorHostility;
						[_pos,_allSides - _sides, -10] call ALiVE_fnc_updateSectorHostility;	
                        
                        _created = _created + 1;
					
						sleep (900 + random 600);
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
    
    if (!(alive _building) || {_building getvariable [QGVAR(furnitured),false]}) exitwith {[]};
    
    _furnitures = ["Land_RattanTable_01_F"];
    _bombs = ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo"];
    _objects = ["Fridge_01_open_F","Land_MapBoard_F","Land_WaterCooler_01_new_F"];
    _boxes = ["Box_East_AmmoOrd_F"];
    _created = [];
    
    _pos = getposATL _building;
    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;
    
    if (count _positions == 0) exitwith {[]};
    
    _building setvariable [QGVAR(furnitured),true];
    
    {
        private ["_pos"];
        
        _pos = _x;
        
        if ({(_pos select 2) - (_x select 2) < 0.5} count _positions > 1) then {
            if (random 1 < 0.3) then {
				_furniture = createVehicle [_furnitures call BIS_fnc_SelectRandom, _pos, [], 0, "CAN_COLLIDE"];
				_furniture setdir getdir _building;
	            
	            _created pushback _furniture;
	            
	            if (_ieds) then {
	                _bomb = createVehicle [_bombs call BIS_fnc_SelectRandom, getposATL _furniture, [], 0, "CAN_COLLIDE"];
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
	            };
            } else {
                if (_add && {random 1 < 0.5}) then {
                    _object = createVehicle [_objects call BIS_fnc_SelectRandom, _pos, [], 0, "CAN_COLLIDE"];
                    _object setdir ([_building,_object] call BIS_fnc_DirTo);
                    
                    _created pushback _object;
                } else {
                	if (_ammo && {random 1 < 0.5}) then {
	                    _box = createVehicle [_boxes call BIS_fnc_SelectRandom, _pos, [], 0, "CAN_COLLIDE"];
	                    _box setdir ([_building,_box] call BIS_fnc_DirTo);
	                    
	                    _created pushback _box;                        
                    };
                };
            };
        };
    } foreach _positions;
    
	_created
};

ALiVE_fnc_INS_spawnIEDfactory = {
    private ["_building","_id"];
    
    _building = _this select 0;
    _id = _this select 1;
    
    if !(alive _building) exitwith {};
    
    _building setvariable [QGVAR(factory),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];  

	[_building,true,false,false] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_INS_spawnHQ = {
    private ["_building","_id"];
    
    _building = _this select 0;
    _id = _this select 1;
    
    if !(alive _building) exitwith {};
    
    _building setvariable [QGVAR(HQ),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];  

	[_building,true,true,false] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_INS_spawnDepot = {
    private ["_building","_id"];
    
    _building = _this select 0;
    _id = _this select 1;
    
    if !(alive _building) exitwith {};
    
    _building setvariable [QGVAR(depot),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];  

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
    
    _factory = _building getvariable QGVAR(factory);
    _depot = _building getvariable QGVAR(depot);
    _HQ = _building getvariable QGVAR(HQ);
    
	if !(isnil "_factory") then {_id = _factory};
    if !(isnil "_depot") then {_id = _depot};
    if !(isnil "_HQ") then {_id = _HQ};

    if (isnil "_id") exitwith {};
    
    _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
    _opcomID = [_objective,"opcomID",""] call ALiVE_fnc_HashGet;
    _pos = [_objective,"center",_pos] call ALiVE_fnc_HashGet;
    
    if !(isnil "_factory") then {[_objective,"factory"] call ALiVE_fnc_HashRem; [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["factory"]] call ALiVE_fnc_HashSet};
    if !(isnil "_depot") then {[_objective,"depot"] call ALiVE_fnc_HashRem; [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["depot"]] call ALiVE_fnc_HashSet};
    if !(isnil "_HQ") then {[_objective,"HQ"] call ALiVE_fnc_HashRem; [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["recruit"]] call ALiVE_fnc_HashSet};
    
    {if (([_x,"opcomID"," "] call ALiVE_fnc_HashGet) == _opcomID) then {_opcom = _x}} foreach OPCOM_instances;
    
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