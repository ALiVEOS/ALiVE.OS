#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(arrayBlockHandler);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Handles arrays by returning a block, internally stores the current pointer for the block.

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
_logic = [nil, "create"] call ALIVE_fnc_arrayBlockHandler;

// get the next block of 1 item from the source things array
_block = [_logic,"getNextBlock", ["thingCounter",_things,1]] call ALIVE_fnc_arrayBlockHandler;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_arrayBlockHandler

TRACE_1("arrayBlockHandler - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = true;

#define MTEMPLATE "ALiVE_ARRAY_BLOCK_%1"

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

                        [_logic,"pointers",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet; // select 2 select 0

                };

                /*
                VIEW - purely visual
                */

                /*
                CONTROLLER  - coordination
                */
        };
        case "getNextBlock": {
                private ["_currentPointer"];
                _args params ["_blockkey","_sourceArray","_blockLimit"];
                private _pointers = [_logic,"pointers"] call ALIVE_fnc_hashGet;

                //_pointers call ALIVE_fnc_inspectHash;
                if(_blockKey in (_pointers select 1)) then {
                    _currentPointer = [_pointers,_blockKey] call ALIVE_fnc_hashGet;
                }else{
                    _currentPointer = 0;
                    [_pointers,_blockKey,_currentPointer] call ALIVE_fnc_hashSet;
                };

                private _limit = count _sourceArray;

                if((_currentPointer + _blockLimit) >= _limit) then {
                    [_pointers,_blockKey,0] call ALIVE_fnc_hashSet;
                }else{
                    _limit = _currentPointer + _blockLimit;
                    [_pointers,_blockKey,_limit] call ALIVE_fnc_hashSet;
                };
                private _block = [];
                for "_i" from _currentPointer to (_limit)-1 do {
                    _block pushback (_sourceArray select _i);
                };

                _result = _block;
        };
        case "state": {

                if !(_args isEqualType []) then {

                        // Save state

                        private _state = [] call ALIVE_fnc_hashCreate;

                        // BaseClassHash CHANGE
                        // loop the class hash and set vars on the state hash
                        {
                          if(!(_x == "super") && !(_x == "class")) then {
                            [_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                          };
                          false
                        } count (_logic select 1);

                        _result = _state;

                } else {
                        ASSERT_TRUE((_args isEqualType []),str typeName _args);

                        // Restore state

                        // BaseClassHash CHANGE
                        // loop the passed hash and set vars on the class hash
                        {
                          [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                          false
                        } count (_args select 1);
                };
        };
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("arrayBlockHandler - output",_result);
_result
