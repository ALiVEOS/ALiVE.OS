#include "script_component.hpp"
SCRIPT(Data);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_Data
Description:
Provides a data interface for modules to read or write to/from.

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled

Parameters:
none

Description:
Data Interface

Examples:
[_logic, "create"] call ALiVE_fnc_Data;

See Also:


Author:
Tupolov
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_Data

private ["_result", "_operation", "_args", "_logic", "_ops"];

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;

//TRACE_3("SYS_DATA",_logic, _operation, _args);

_ops = ["read","write","update","delete","load","save","convert","restore","bulkSave","bulkWrite","bulkLoad","bulkRead"];

_result = true;

if (_operation in _ops) then {
		if !(GVAR(DISABLED)) then {
			ASSERT_TRUE(typeName _args == "ARRAY", _args);
			if(typeName _args == "ARRAY") then {
				private ["_function","_script"];
				_source = [_logic, "source"] call ALIVE_fnc_hashGet;
				_script = format ["ALIVE_fnc_%1Data_%2", _operation, _source];
				_function = call compile _script;
				//TRACE_2("SYS_DATA: Operation Request - ",_source, _script);
				_result = [_logic, _args] call _function;
			} else {
				private["_err"];
                _err = format["%1 %2 operation requires an ARRAY as an argument not %3.", _logic, _operation, typeName _args];
                ERROR_WITH_TITLE(str _logic,_err);
				_result = "ERROR";
			};
		} else {
			private["_err"];
            _err = format["%1 %2 operation refused as module is disabled.", _logic, _operation];
            ERROR_WITH_TITLE(str _logic,_err);
			_result = "ERROR";
		};
} else {

	switch(_operation) do {

        case "create": {
                /*
                MODEL - no visual just reference data
                - server side object only
                */

                if (isServer) then {

                        // if server, initialise module game logic
                        _logic = [nil, "create"] call SUPERCLASS;
                        [_logic, "super", QUOTE(SUPERCLASS)] call ALIVE_fnc_hashSet;
                        [_logic, "class", QUOTE(MAINCLASS)] call ALIVE_fnc_hashSet;
                        [_logic, "databaseName", GVAR(databaseName)] call ALIVE_fnc_hashSet;
                        [_logic, "source", GVAR(source)] call ALIVE_fnc_hashSet;
                        [_logic, "storeType", true] call ALIVE_fnc_hashSet;
                        [_logic, "key", GVAR(GROUP_ID)] call ALIVE_fnc_hashSet;

						TRACE_1("After module init",_logic);

						_result = _logic;

                } else {
                        // any client side logic
                };

                /*
                VIEW - purely visual
                - initialise menu
                - frequent check to modify menu and display status (ALIVE_fnc_adminActoinsmenuDef)
                */


                /*
                CONTROLLER  - coordination
                - frequent check if player is server admin (ALIVE_fnc_statisticsmenuDef)
                */
        };

		case "databaseName": {
			ASSERT_TRUE(typeName _args == "STRING", _args);
			if(typeName _args == "STRING") then {
				_result = [_logic, _operation, _args] call ALIVE_fnc_hashSet;
			} else {
				private["_err"];
                _err = format["%1 %2 operation requires a STRING as an argument not %3.", _logic, _operation, typeName _args];
                ERROR_WITH_TITLE(str _logic,_err);
			};
		};

		case "storeType": {
			ASSERT_TRUE(typeName _args == "BOOL", _args);
			if(typeName _args == "BOOL") then {
				_result = [_logic, _operation, _args] call ALIVE_fnc_hashSet;
			} else {
				private["_err"];
                _err = format["%1 %2 operation requires a BOOL as an argument not %3.", _logic, _operation, typeName _args];
                ERROR_WITH_TITLE(str _logic,_err);
			};
		};

		case "setDataDictionary": {
			ASSERT_TRUE(typeName _args == "ARRAY", _args);
			if(typeName _args == "ARRAY") then {
				private ["_missing"];
				_missing = [ALIVE_DataDictionary, _args select 0, "MISSING"] call ALIVE_fnc_hashGet;
				if (_missing == "MISSING") then {
					_result = [ALIVE_DataDictionary, _args select 0, _args select 1] call ALIVE_fnc_hashSet;
				};
			} else {
				private["_err"];
                _err = format["%1 %2 operation requires an ARRAY as an argument not %3.", _logic, _operation, typeName _args];
                ERROR_WITH_TITLE(str _logic,_err);
				_result = false;
			};
		};

		case "getDataDictionary": {
			ASSERT_TRUE(typeName _args == "ARRAY", _args);
			if(typeName _args == "ARRAY") then {
				_result = [ALIVE_DataDictionary, _args select 0, "STRING"] call ALIVE_fnc_hashGet;
			} else {
				private["_err"];
                _err = format["%1 %2 operation requires an ARRAY as an argument not %3.", _logic, _operation, typeName _args];
                ERROR_WITH_TITLE(str _logic,_err);
				_result = false;
			};
		};

		case "source": {
			ASSERT_TRUE(typeName _args == "STRING", _args);
			if(typeName _args == "STRING") then {
				_result = [_logic, _operation, _args] call ALIVE_fnc_hashSet;
			} else {
				private["_err"];
                _err = format["%1 %2 operation requires a STRING as an argument not %3.", _logic, _operation, typeName _args];
                ERROR_WITH_TITLE(str _logic,_err);
				_result = false;
			};
		};

		case "debug": {
             ASSERT_TRUE(typeName _args == "BOOL", _args);
            if(typeName _args == "BOOL") then {
                _result = [_logic, _operation, _args] call ALIVE_fnc_hashSet;
            } else {
                private["_err"];
                 _err = format["%1 %2 operation requires a BOOL as an argument not %3.", _logic, _operation, typeName _args];
                 ERROR_WITH_TITLE(str _logic,_err);
            };
        };

        case "destroy": {
				[_logic, "debug", false] call MAINCLASS;
				if (isServer) then {
						// if server
						[_logic, "destroy"] call SUPERCLASS;
				};

				_logic = nil;
        };

        default {
			_result = [_logic, _operation, _args] call SUPERCLASS;
        };
	};
};
// TRACE_1("SYS DATA - output",_result);
_result;
