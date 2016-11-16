#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sector);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Creates the server side object to create a sector

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of analysis
String - gridID - Id of grid
Array - dimensions - Array of width, height dimensions for sector creation
Array - position - Array of width, height dimensions for sector creation
center - Returns the center point of the sector
bounds - Returns Array of corner postions BL, TL, TR, BR
Array - within - Returns if the passed position is within the sector
String - id - Id of sector
Array - data - Array of key values for storage in the sectors data hash

Examples:
(begin example)
// create a sector
_logic = [nil, "create"] call ALIVE_fnc_sector;

// set sector parent grid id
_result = [_logic, "gridID", "Grid Id"] call ALIVE_fnc_sector;

// set sector dimension
_result = [_logic, "dimensions", _dimension_array] call ALIVE_fnc_sector;

// set sector position
_result = [_logic, "position", _position_array] call ALIVE_fnc_sector;

// set sector id
_result = [_logic, "id", "Sector Id"] call ALIVE_fnc_sector;

// get sector center
_result = [_logic, "center"] call ALIVE_fnc_sector;

// get sector bounds
_result = [_logic, "bounds"] call ALIVE_fnc_sector;

// get position within sector
_result = [_logic, "within", getPos player] call ALIVE_fnc_sector;

// set arbitrary data on the sectors data hash
_result = [_logic, "data", ["key" ["values"]]] call ALIVE_fnc_sector;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_sector

TRACE_1("sector - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = true;

#define MTEMPLATE "ALiVE_SECTOR_%1"

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
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;
            TRACE_1("After module init",_logic);

            // set defaults
            [_logic,"data",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"gridID","grid"] call ALIVE_fnc_hashSet;
            [_logic,"debugColor","ColorBlack"] call ALIVE_fnc_hashSet;
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
            // if server
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;

            [_logic, "destroy"] call SUPERCLASS;
        };

    };

    case "debug": {

        if !(_args isEqualType true) then {
                _args = [_logic,"debug", false] call ALIVE_fnc_hashGet;
        } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(_args isEqualType true, str _args);

        [_logic,"deleteDebugMarkers"] call MAINCLASS;

        if(_args) then {
            [_logic,"createDebugMarkers"] call MAINCLASS;
        };

        _result = _args;
    };

    case "state": {

        if !(_args isEqualType []) then {

            // Save state

            private _state = [] call ALIVE_fnc_hashCreate;

            {
                if(!(_x == "super") && !(_x == "class")) then {
                    [_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                };
            } forEach (_logic select 1);

            _result = _state;

        } else {

            ASSERT_TRUE(_args isEqualType [], str typeName _args);

            // Restore state
            {
                [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
            } forEach (_args select 1);

        };

    };

    case "gridID": {

        if(_args isEqualType "") then {
            [_logic,"gridID",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"gridID"] call ALIVE_fnc_hashGet;

    };

    case "dimensions": {

        if(_args isEqualType []) then {
            [_logic,"dimensions",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"dimensions"] call ALIVE_fnc_hashGet;

    };

    case "position": {

        if(_args isEqualType []) then {
            [_logic,"position",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"position"] call ALIVE_fnc_hashGet;

    };

    case "id": {

        if(_args isEqualType "") then {
            [_logic,"id",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"id"] call ALIVE_fnc_hashGet;

    };

    case "data": {

        if(_args isEqualType []) then {
            _args params ["_key","_value"];

            private _data = [_logic,"data"] call ALIVE_fnc_hashGet;

            _result = [_data, _key, _value] call ALIVE_fnc_hashSet;
            [_logic,"data",_result] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"data"] call ALIVE_fnc_hashGet;

    };

    case "center": {

        _result = [_logic,"position"] call ALIVE_fnc_hashGet;

    };

    case "bounds": {

        private _position = [_logic,"position"] call ALIVE_fnc_hashGet;
        private _dimensions = [_logic,"dimensions"] call ALIVE_fnc_hashGet;

        _position params ["_positionX","_positionY"];

        _dimensions params ["_sectorWidth","_sectorHeight"];

        private _positionBL = [(_positionX - _sectorWidth), (_positionY - _sectorHeight)];
        private _positionTL = [(_positionX - _sectorWidth), (_positionY + _sectorHeight)];
        private _positionTR = [(_positionX + _sectorWidth), (_positionY + _sectorHeight)];
        private _positionBR = [(_positionX + _sectorWidth), (_positionY - _sectorHeight)];

        _result = [_positionBL, _positionTL, _positionTR, _positionBR]

    };

    case "within": {

        ASSERT_TRUE(_args isEqualType [], str typeName _args);

        private _position = _args;

        _position params ["_positionX","_positionY"];

        private _bounds = [_logic, "bounds"] call MAINCLASS;

        private _positionBL = _bounds select 0;
        _positionBL params ["_positionBLX","_positionBLY"];

        private _positionTR = _bounds select 2;
        _positionTR params ["_positionTRX","_positionTRY"];

        _result = false;

        if(
            (_positionX > _positionBLX) &&
            (_positionY > _positionBLY) &&
            (_positionX < _positionTRX) &&
            (_positionY < _positionTRY)
        ) then {
            _result = true;
        };

    };

    case "createDebugMarkers": {

        private _markers = [];

        private _position = [_logic,"position"] call ALIVE_fnc_hashGet;
        private _dimensions = [_logic,"dimensions"] call ALIVE_fnc_hashGet;
        private _debugColor = [_logic,"debugColor"] call ALIVE_fnc_hashGet;
        private _gridID = [_logic,"gridID"] call ALIVE_fnc_hashGet;
        private _id = [_logic,"id"] call ALIVE_fnc_hashGet;

        if((count _position > 0) && (count _dimensions > 0)) then {

            private _m = createMarker [format[MTEMPLATE, format["b%1_%2",_gridID,_id]], _position];
            _m setMarkerShape "RECTANGLE";
            _m setMarkerSize _dimensions;
            _m setMarkerBrush "Border";
            _m setMarkerColor _debugColor;

            _markers pushback _m;

            _m = createMarker [format[MTEMPLATE, format["g%1_%2",_gridID,_id]], _position];
            _m setMarkerShape "RECTANGLE";
            _m setMarkerSize _dimensions;
            _m setMarkerAlpha 0.2;
            _m setMarkerBrush "Solid";
            _m setMarkerColor "ColorGreen";

            _markers pushback _m;

            _m = createMarker [format[MTEMPLATE, format["l%1_%2",_gridID,_id]], _position];
            _m setMarkerShape "ICON";
            _m setMarkerSize [0.5, 0.5];
            _m setMarkerType "mil_dot";
            _m setMarkerColor _debugColor;
            _m setMarkerText _id;

            _markers pushback _m;

            [_logic,"debugMarkers",_markers] call ALIVE_fnc_hashSet;

        };

    };

    case "deleteDebugMarkers": {

        {
                deleteMarker _x;
        } forEach ([_logic,"debugMarkers", []] call ALIVE_fnc_hashGet);

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("sector - output",_result);

if (isnil "_result") then {nil} else {_result};