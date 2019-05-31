//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(orbatCreatorUnit);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreatorUnit
Description:
Main handler for custom units for the orbat creator

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
_faction = [nil,"create"] call ALiVE_fnc_orbatCreatorUnit;

See Also:
- <ALiVE_fnc_orbatCreator>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClass
#define MAINCLASS   ALiVE_fnc_orbatCreatorUnit

private "_result";
params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch (_operation) do {

    default {
        _result = _this call SUPERCLASS;
    };

    case "create": {

		_args params [
			"_parent",
			"_sideNum",
			"_faction",
			"_classname",
			"_displayName",
			["_identityTypes", []],
			["_crew", ""],
			["_turrets", [] call ALiVE_fnc_hashCreate],
			["_texture", ""]
		];

		_logic = [nil,"create"] call SUPERCLASS;

		_logic setvariable ["super", QUOTE(SUPERCLASS)];
		_logic setvariable ["class", QUOTE(MAINCLASS)];

		_logic setvariable ["inheritsFrom", _parent];
		_logic setvariable ["side", _sideNum];
		_logic setvariable ["faction", _faction];

		_logic setvariable ["configName", _classname];
		_logic setvariable ["displayName", _displayName];

        // man properties

		_logic setvariable ["loadout", []];

		if (_identityTypes isequalto []) then {
			_identityTypes = [[
				["face", ""],
				["voice", ""],
				["insignia", ""],
				["misc", []]
			]] call ALiVE_fnc_hashCreate;
		};

        _logic setvariable ["identityTypes", _identityTypes];

        // vehicle properties

		_logic setvariable ["crew", _crew];
		_logic setvariable ["turrets", _turrets];
		_logic setvariable ["texture", _texture];

		_result = _logic;

    };

    case "inheritsFrom": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "side": {

        if (_args isequaltype 0) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "faction": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "configName": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "displayName": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "loadout": {

        if (_args isequaltype []) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "crew": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "turrets": {

        if (_args isequaltype []) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "texture": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "identityTypes": {

        if (_args isequaltype []) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

};

if (!isnil "_result") then {_result} else {nil};