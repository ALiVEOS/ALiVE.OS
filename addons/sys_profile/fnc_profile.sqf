#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profile);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Base class for profile objects to inherit from

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of analysis

Examples:
(begin example)
// create a profile
_logic = [nil, "create"] call ALIVE_fnc_profile;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_profile

private ["_result","_deleteMarkers","_createMarkers"];

TRACE_1("profile - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

#define MTEMPLATE "ALiVE_PROFILE_%1"

switch(_operation) do {
        case "init": {                
                /*
                MODEL - no visual just reference data
                - nodes
                - center
                - size
                */
                
                if (isServer) then {
                        // if server, initialise module game logic
						// nil these out they add a lot of code to the hash..
						[_logic,"super"] call ALIVE_fnc_hashRem;
						[_logic,"class"] call ALIVE_fnc_hashRem;
                        //TRACE_1("After module init",_logic);
						
						[_logic,"debug",false] call ALIVE_fnc_hashSet; // select 2 select 0
						[_logic,"active",false] call ALIVE_fnc_hashSet; // select 2 select 1
						[_logic,"position",[0,0]] call ALIVE_fnc_hashSet; // select 2 select 2
						[_logic,"side","EAST"] call ALIVE_fnc_hashSet; // select 2 select 3
						[_logic,"profileID",""] call ALIVE_fnc_hashSet; // select 2 select 4
						[_logic,"type","entity"] call ALIVE_fnc_hashSet; // select 2 select 5
						[_logic,"objectType","inf"] call ALIVE_fnc_hashSet; // select 2 select 6
						[_logic,"vehicleAssignments",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet; // select 2 select 7
						
                };
                
                /*
                VIEW - purely visual
                */
                
                /*
                CONTROLLER  - coordination
                */
        };
        case "destroy": {                
                [_logic, "debug", false] call MAINCLASS;
                if (isServer) then {
					[_logic, "destroy"] call SUPERCLASS;
                };                
        };
		case "state": {
				private["_state"];
                
				if(typeName _args != "ARRAY") then {
						
						// Save state
				
                        _state = [] call ALIVE_fnc_hashCreate;
						
						// BaseClassHash CHANGE 
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
						
						// BaseClassHash CHANGE 
						// loop the passed hash and set vars on the class hash
                        {
							[_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
						} forEach (_args select 1);
                };
        };
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("profile - output",_result);
_result;