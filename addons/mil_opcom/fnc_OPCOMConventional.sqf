//#define DEBUG_MODE_FULL
#include <\x\ALiVE\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOMConventional);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMConventional
Description:
Virtual AI Controller

Base class for OPCOM Convobjects to inherit from

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:

Examples:

Author:
SpyderBlack / Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_OPCOM
#define MAINCLASS   ALiVE_fnc_OPCOMConventional

#define MTEMPLATE "ALiVE_OPCOM_%1"

TRACE_1("OPCOM Conventional - input", _this);

private "_result";

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch(_operation) do {

    case "postStart": {

        [_logic,"listen"] call MAINCLASS;

    };

    case "listen": {

        private _listenerID = [MOD(eventLog),"addListener", [_logic, []]] call ALIVE_fnc_eventLog;

        _logic setvariable ["listenerID", _listenerID];

        _result = _listenerID;

    };

    case "handleEvent": {

        private _event = _args;

        private _type = [_event, "type"] call ALIVE_fnc_hashGet;
        private _data = [_event, "data"] call ALIVE_fnc_hashGet;

        switch (_type) do {



        };

    };

    case "cycle": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        while {!isnil "_logic" && {!(_logic getvariable ["stopped", false])}} do {

            private _paused = _logic getvariable ["paused", false];

            if (!_paused) then {

                // fire cycle start event here

                // scan battlefield and update info


                private _friendlyTroops = [_logic,"scanTroops"] call MAINCLASS;

                // update visible units

                private _visibleEnemies = [_logic,"getVisibleEnemies"] call MAINCLASS;

                [_handler,"knownEnemies", _visibleEnemies] call ALiVE_fnc_hashSet;

                // get cluster occupation

                private _objectiveOccupationData = [_logic,"getObjectiveOccupation", [_friendlyTroops,_visibleEnemies]] call MAINCLASS;

                private _objectiveStateData = [_logic,"assignObjectiveStates", _objectiveOccupationData] call MAINCLASS;

            };

        };

    };

};

TRACE_1("OPCOM Conventional - output", _result);

if !(isnil "_result") then {_result} else {nil};