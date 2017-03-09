//#define DEBUG_MODE_FULL
#include <\x\alive\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOMObjective);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMObjective

Description:
Main handler for OPCOM Objectives

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

See Also:


Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_OPCOMObjective

private "_result";

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch(_operation) do {

    case "create": {

        if (_args isEqualtype objNull) then {

            _result = _this call SUPERCLASS;

        } else {

            switch (typename _args) do {

                case "ARRAY": {

                    _args params [
                        ["_objectiveID", ""],
                        ["_center", [0,0,0]],
                        ["_size", 50],
                        ["_type", "CIV"],
                        ["_priority", 50],
                        ["_opcomState", "idle"],
                        ["_clusterID", ""],
                        ["_opcomOrderPriority", 0],
                        ["_rev", ""]
                    ];

                    _result = [
                        [
                            ["objectiveID", _objectiveID],
                            ["center", _center],
                            ["size", _size],
                            ["type", _type],
                            ["priority", _priority],
                            ["opcomState", _opcomState],
                            ["clusterID", _clusterID],
                            ["opcomTypePriority", _opcomOrderPriority],
                            ["_rev", _rev],
                            ["timeLastRecon", -1]
                        ]
                    ] call ALiVE_fnc_hashCreate;

                };

            };

        };

    };

    case "init": {

        [_logic,"super"] call ALiVE_fnc_hashRem;
        [_logic,"class"] call ALiVE_fnc_hashRem;

        [_logic,"objectiveID", ""] call ALiVE_fnc_hashSet;
        [_logic,"center", [0,0,0]] call ALiVE_fnc_hashSet;
        [_logic,"size", 50] call ALiVE_fnc_hashSet;
        [_logic,"type", "CIV"] call ALiVE_fnc_hashSet;
        [_logic,"priority", 50] call ALiVE_fnc_hashSet;
        [_logic,"opcomState", "idle"] call ALiVE_fnc_hashSet;
        [_logic,"clusterID", ""] call ALiVE_fnc_hashSet;
        [_logic,"opcomOrderPriority", 0] call ALiVE_fnc_hashSet;
        [_logic,"_rev", ""] call ALiVE_fnc_hashSet;
        [_logic,"timeLastRecon", -1] call ALiVE_fnc_hashSet;

    };

    case "objectiveID": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "center": {

        if (_args isEqualType []) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "size": {

        if (_args isEqualType 0) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "type": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "priority": {

        if (_args isEqualType 0) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "opcomState": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "clusterID": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "opcomOrderPriority": {

        if (_args isEqualType 0) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "_rev": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    default {
        _result = _this call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};