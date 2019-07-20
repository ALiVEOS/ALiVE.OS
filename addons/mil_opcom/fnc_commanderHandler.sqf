//#define DEBUG_MODE_FULL
#include "\x\ALiVE\addons\mil_opcom\script_component.hpp"
SCRIPT(commanderHandler);

/* ----------------------------------------------------------------------------
We don't know shit yet
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_commanderHandler

private ["_result"];

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch (_operation) do {

    case "create": {

        _logic = [
            [
                ["nextCommanderID", 0],
                ["commanders", [] call ALiVE_fnc_hashCreate]
            ]
        ] call ALiVE_fnc_hashCreate;

        _result = _logic;

    };

    case "init": {



    };

    case "getCommanderByID": {

        private _id = _args;

        private _commanders = [_logic,"commanders"] call ALiVE_fnc_hashGet;

        _result = [_commanders,_id] call ALiVE_fnc_hashGet;

    };

    case "getAllCommanders": {

        _result = ([_logic,"commanders"] call ALiVE_fnc_hashGet) select 2;

    };

    case "getNextCommanderID": {

        private _nextIDNumber = [_logic,"nextCommanderID"] call ALiVE_fnc_hashGet;
        private _nextID = format ["alive_commander_%1", _nextIDNumber];

        [_logic,"nextCommanderID", _nextIDNumber + 1] call ALiVE_fnc_hashSet;

        _result = _nextID;

    };

    case "registerCommander": {

        private _commander = _args;

        private _commanderID = [_logic,"getNextCommanderID"] call MAINCLASS;
        [_commander,"id", _commanderID] call ALiVE_fnc_hashSet;

        private _commanders = [_logic,"commanders"] call ALiVE_fnc_hashGet;
        [_commanders,_commanderID, _commander] call ALiVE_fnc_hashSet;

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

if !(isnil "_result") then {_result} else {nil};
