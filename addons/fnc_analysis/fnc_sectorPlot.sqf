#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorPlot);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Creates visual representations of sector data

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Array - plot - Array of sector and key to plot data

Examples:
(begin example)
// create a sector plot
_logic = [nil, "create"] call ALIVE_fnc_sectorPlot;

// set sector plot parent plotter id
_result = [_logic, "plotterID", "Plotter Id"] call ALIVE_fnc_sectorPlot;

// plot a sector
_result = [_logic, "plot", [_sector, "key"]] call ALIVE_fnc_sectorPlot;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_sectorPlot

TRACE_1("sectorPlot - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = true;

#define MTEMPLATE "ALiVE_SECTORPLOT_%1"

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

            [_logic,"plotterID","plotterID"] call ALIVE_fnc_hashSet;
        };

        /*
        VIEW - purely visual
        */

        /*
        CONTROLLER  - coordination
        */
    };

    case "destroy": {

        if (isServer) then {

            // clear plot
            [_logic, "clear"] call MAINCLASS;

            // if server
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;

            [_logic, "destroy"] call SUPERCLASS;

        };

    };

    case "plotterID": {

        if(_args isEqualType "") then {
            [_logic,"plotterID",_args] call ALIVE_fnc_hashSet;
        };

        _result = [_logic,"plotterID"] call ALIVE_fnc_hashGet;

    };

    case "plot": {

        private _createMarker = {
            params [
                "_markerID",
                "_position",
                "_dimensions",
                "_alpha",
                "_color",
                ["_shape", "RECTANGLE"],
                ["_brush", "SOLID"]
            ];

            private _m = createMarker [_markerID, _position];
            _m setMarkerSize _dimensions;
            _m setMarkerAlpha _alpha;
            _m setMarkerColor _color;
            _m setMarkerShape _shape;
            _m setMarkerBrush _brush;

            _m
        };

        _args params ["_sector","_key"];

        private _plotterID = [_logic, "plotterID"] call ALIVE_fnc_hashGet;
        private _markers = [_logic, "markers", []] call ALIVE_fnc_hashGet;

        private _centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
        private _id = [_sector, "id"] call ALIVE_fnc_sector;
        private _bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
        private _dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
        private _sectorData = _sector select 2 select 0;    //[_sector, "data"] call ALIVE_fnc_sector;

        switch(_key) do {

            case "units": {

                if(_key in (_sectorData select 1)) then {

                    private ["_alpha"];

                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _eastUnits = [_plotData, "EAST"] call ALIVE_fnc_hashGet;
                    private _westUnits = [_plotData, "WEST"] call ALIVE_fnc_hashGet;
                    private _civUnits = [_plotData, "CIV"] call ALIVE_fnc_hashGet;
                    private _guerUnits = [_plotData, "GUER"] call ALIVE_fnc_hashGet;

                    private _eastCount = count _eastUnits;
                    private _westCount = count _westUnits;
                    private _civCount = count _civUnits;
                    private _guerCount = count _guerUnits;

                    if(_eastCount > 0) then {
                        if(_eastCount > 0) then { _alpha = 0.2; };
                        if(_eastCount > 10) then { _alpha = 0.3; };
                        if(_eastCount > 20) then { _alpha = 0.4; };
                        if(_eastCount > 30) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ue%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorRed"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_westCount > 0) then {
                        if(_westCount > 0) then { _alpha = 0.2; };
                        if(_westCount > 10) then { _alpha = 0.3; };
                        if(_westCount > 20) then { _alpha = 0.4; };
                        if(_westCount > 30) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1uw%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorBlue"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_civCount > 0) then {
                        if(_civCount > 0) then { _alpha = 0.2; };
                        if(_civCount > 10) then { _alpha = 0.3; };
                        if(_civCount > 20) then { _alpha = 0.4; };
                        if(_civCount > 30) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1uc%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorGreen"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_guerCount > 0) then {
                        if(_guerCount > 0) then { _alpha = 0.2; };
                        if(_guerCount > 10) then { _alpha = 0.3; };
                        if(_guerCount > 20) then { _alpha = 0.4; };
                        if(_guerCount > 30) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ug%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorYellow"] call _createMarker;
                        _markers pushback _m;
                    };
                };

            };

            case "entitiesBySide": {

                if(_key in (_sectorData select 1)) then {

                    private ["_alpha"];

                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _eastProfiles = [_plotData, "EAST"] call ALIVE_fnc_hashGet;
                    private _westProfiles = [_plotData, "WEST"] call ALIVE_fnc_hashGet;
                    private _civProfiles = [_plotData, "CIV"] call ALIVE_fnc_hashGet;
                    private _guerProfiles = [_plotData, "GUER"] call ALIVE_fnc_hashGet;

                    private _eastCount = count _eastProfiles;
                    private _westCount = count _westProfiles;
                    private _civCount = count _civProfiles;
                    private _guerCount = count _guerProfiles;

                    if(_eastCount > 0) then {

                        if(_eastCount > 0) then { _alpha = 0.2; };
                        if(_eastCount > 2) then { _alpha = 0.3; };
                        if(_eastCount > 4) then { _alpha = 0.4; };
                        if(_eastCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ee%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorRed"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_westCount > 0) then {
                        if(_westCount > 0) then { _alpha = 0.2; };
                        if(_westCount > 2) then { _alpha = 0.3; };
                        if(_westCount > 4) then { _alpha = 0.4; };
                        if(_westCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ew%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorBlue"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_civCount > 0) then {
                        if(_civCount > 0) then { _alpha = 0.2; };
                        if(_civCount > 2) then { _alpha = 0.3; };
                        if(_civCount > 4) then { _alpha = 0.4; };
                        if(_civCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ec%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorGreen"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_guerCount > 0) then {
                        if(_guerCount > 0) then { _alpha = 0.2; };
                        if(_guerCount > 2) then { _alpha = 0.3; };
                        if(_guerCount > 4) then { _alpha = 0.4; };
                        if(_guerCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1eg%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorYellow"] call _createMarker;
                        _markers pushback _m;
                    };
                };

            };

            case "vehiclesBySide": {

                if(_key in (_sectorData select 1)) then {

                    private ["_alpha"];

                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _eastProfiles = [_plotData, "EAST"] call ALIVE_fnc_hashGet;
                    private _westProfiles = [_plotData, "WEST"] call ALIVE_fnc_hashGet;
                    private _civProfiles = [_plotData, "CIV"] call ALIVE_fnc_hashGet;
                    private _guerProfiles = [_plotData, "GUER"] call ALIVE_fnc_hashGet;

                    private _eastCount = count _eastProfiles;
                    private _westCount = count _westProfiles;
                    private _civCount = count _civProfiles;
                    private _guerCount = count _guerProfiles;

                    if(_eastCount > 0) then {
                        if(_eastCount > 0) then { _alpha = 0.2; };
                        if(_eastCount > 10) then { _alpha = 0.3; };
                        if(_eastCount > 20) then { _alpha = 0.4; };
                        if(_eastCount > 30) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ve%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorRed"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_westCount > 0) then {
                        if(_westCount > 0) then { _alpha = 0.2; };
                        if(_westCount > 10) then { _alpha = 0.3; };
                        if(_westCount > 20) then { _alpha = 0.4; };
                        if(_westCount > 30) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1vw%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorBlue"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_civCount > 0) then {
                        if(_civCount > 0) then { _alpha = 0.2; };
                        if(_civCount > 10) then { _alpha = 0.3; };
                        if(_civCount > 20) then { _alpha = 0.4; };
                        if(_civCount > 30) then { _alpha = 0.5; };

                        _markerID = format[MTEMPLATE, format["%1vc%2",_plotterID,_id]];
                        _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorGreen"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_guerCount > 0) then {
                        if(_guerCount > 0) then { _alpha = 0.2; };
                        if(_guerCount > 10) then { _alpha = 0.3; };
                        if(_guerCount > 20) then { _alpha = 0.4; };
                        if(_guerCount > 30) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1vg%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorYellow"] call _createMarker;
                        _markers pushback _m;
                    };
                };

            };

            case "active": {

                if(_key in (_sectorData select 1)) then {

                    private ["_alpha"];

                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _activeCount = count _plotData;

                    if(_activeCount > 0) then {
                        if(_activeCount > 0) then { _alpha = 0.2; };
                        if(_activeCount > 2) then { _alpha = 0.3; };
                        if(_activeCount > 4) then { _alpha = 0.4; };
                        if(_activeCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1act%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorGreen"] call _createMarker;
                        _markers pushback _m;
                    };
                };

            };

            case "terrain": {

                if(_key in (_sectorData select 1)) then {

                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _alpha = 0.5;

                    switch (_plotData) do {
                        case "LAND": {
                            private _markerID = format[MTEMPLATE, format["%1t%2",_plotterID,_id]];
                            private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorBrown"] call _createMarker;
                            _markers pushback _m;
                        };
                        case "SHORE": {
                            private _markerID = format[MTEMPLATE, format["%1t%2",_plotterID,_id]];
                            private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorKhaki"] call _createMarker;
                            _markers pushback _m;
                        };
                        case "SEA": {
                            private _markerID = format[MTEMPLATE, format["%1t%2",_plotterID,_id]];
                            private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorBlue"] call _createMarker;
                            _markers pushback _m;
                        };
                    };
                };

            };

            case "terrainSamples": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _landPositions = [_plotData,"land"] call ALIVE_fnc_hashGet;
                    private _shorePositions = [_plotData,"shore"] call ALIVE_fnc_hashGet;
                    private _seaPositions = [_plotData,"sea"] call ALIVE_fnc_hashGet;

                    private _dimensions = [15,15];
                    private _alpha = 1;

                    {
                        private _position = _x;
                        private _markerID = format["TLA_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorBrown"] call _createMarker;
                        _markers pushback _m;
                    } forEach _landPositions;

                    {
                        private _position = _x;
                        private _markerID = format["TSH_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorKhaki"] call _createMarker;
                        _markers pushback _m;
                    } forEach _shorePositions;

                    {
                        private _position = _x;
                        private _markerID = format["TSE_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorBlue"] call _createMarker;
                        _markers pushback _m;
                    } forEach _seaPositions;
                };

            };

            case "elevation": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _alpha = 0;

                    private _colour = "ColorRed";
                    private _value = _plotData;

                    if(_value < 0) then {
                        _colour = "ColorBlue";
                        _value = _plotData - (_plotData * 2);
                    }else {
                        _value = _plotData;
                    };

                    if(_value > 0) then { _alpha = 0.1; };
                    if(_value > 20) then { _alpha = 0.2; };
                    if(_value > 40) then { _alpha = 0.3; };
                    if(_value > 60) then { _alpha = 0.4; };
                    if(_value > 80) then { _alpha = 0.5; };
                    if(_value > 100) then { _alpha = 0.6; };
                    if(_value > 120) then { _alpha = 0.7; };
                    if(_value > 140) then { _alpha = 0.8; };

                    private _markerID = format[MTEMPLATE, format["%1e%2",_plotterID,_id]];
                    private _m = [_markerID,_centerPosition,_dimensions,_alpha,_colour] call _createMarker;
                    _markers pushback _m;
                };

            };

            case "bestPlaces": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _forestPositions = [_plotData,"forest"] call ALIVE_fnc_hashGet;
                    private _hillsPositions = [_plotData,"exposedHills"] call ALIVE_fnc_hashGet;

                    /*
                    private _meadowsPositions = [_plotData,"meadow"] call ALIVE_fnc_hashGet;
                    private _treesPositions = [_plotData,"exposedTrees"] call ALIVE_fnc_hashGet;
                    private _housesPositions = [_plotData,"houses"] call ALIVE_fnc_hashGet;
                    private _seaPositions = [_plotData,"sea"] call ALIVE_fnc_hashGet;
                    */

                    private _dimensions = [20,20];
                    private _alpha = 1;

                    {
                        private _position = _x;
                        private _markerID = format["BPF_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorGreen"] call _createMarker;
                        _markers pushback _m;
                    } forEach _forestPositions;

                    {
                        private _position = _x;
                        private _markerID = format["BPH_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorOrange"] call _createMarker;
                        _markers pushback _m;
                    } forEach _hillsPositions;

                    /*
                    {
                        private _position = _x;
                        private _markerID = format["BPM_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorWhite"] call _createMarker;
                       _markers pushback _m;
                    } forEach _meadowsPositions;

                    {
                        private _position = _x;
                        private _markerID = format["BPT_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorRed"] call _createMarker;
                        _markers pushback _m;
                    } forEach _treesPositions;

                    {
                        private _position = _x;
                        private _markerID = format["BPB_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorYellow"] call _createMarker;
                        _markers pushback _m;
                    } forEach _housesPositions;

                    {
                        private _position = _x;
                        private _markerID = format["BPS_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorBlue"] call _createMarker;
                        _markers pushback _m;
                    } forEach _seaPositions;
                    */
                };

            };

            case "flatEmpty": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _dimensions = [20,20];
                    private _alpha = 1;

                    {
                        private _position = _x;

                        if(count _position > 0) then {
                            private _markerID = format["FE_%1_%2",_id,_forEachIndex];
                            private _m = [_markerID,_position,_dimensions,_alpha,"ColorRed","ELLIPSE"] call _createMarker;
                            _markers pushback _m;
                        };
                    } forEach _plotData;

                };

            };

            case "roads": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _roadPositions = [_plotData,"road"] call ALIVE_fnc_hashGet;
                    private _crossroadPositions = [_plotData,"crossroad"] call ALIVE_fnc_hashGet;
                    private _terminusPositions = [_plotData,"terminus"] call ALIVE_fnc_hashGet;

                    private _dimensions = [8,8];
                    private _alpha = 1;

                    {
                        private _position = _x select 0;
                        private _markerID = format["RO_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorBrown"] call _createMarker;
                        _markers pushback _m;
                    } forEach _roadPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["ROC_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorOrange"] call _createMarker;
                        _markers pushback _m;
                    } forEach _crossroadPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["ROT_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorRed"] call _createMarker;
                        _markers pushback _m;
                    } forEach _terminusPositions;
                };

            };

            case "clustersMil": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _consolidatedPositions = [_plotData,"consolidated"] call ALIVE_fnc_hashGet;
                    private _airPositions = [_plotData,"air"] call ALIVE_fnc_hashGet;
                    private _heliPositions = [_plotData,"heli"] call ALIVE_fnc_hashGet;

                    private _dimensions = [100,100];
                    private _alpha = 1;

                    {
                        private _position = _x select 0;
                        private _markerID = format["MCC_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorGreen","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _consolidatedPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["MCA_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorBlue","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _airPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["MCH_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorOrange","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _heliPositions;
                };

            };

            case "clustersCiv": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _consolidatedPositions = [_plotData,"consolidated"] call ALIVE_fnc_hashGet;
                    private _powerPositions = [_plotData,"power"] call ALIVE_fnc_hashGet;
                    private _commsPositions = [_plotData,"comms"] call ALIVE_fnc_hashGet;
                    private _marinePositions = [_plotData,"marine"] call ALIVE_fnc_hashGet;
                    private _fuelPositions = [_plotData,"fuel"] call ALIVE_fnc_hashGet;
                    private _railPositions = [_plotData,"rail"] call ALIVE_fnc_hashGet;
                    private _constructionPositions = [_plotData,"construction"] call ALIVE_fnc_hashGet;
                    private _settlementPositions = [_plotData,"settlement"] call ALIVE_fnc_hashGet;

                    private _dimensions = [100,100];
                    private _alpha = 1;

                    {
                        private _position = _x select 0;
                        private _markerID = format["CCC_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorBlack","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _consolidatedPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["CCP_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorYellow","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _powerPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["CCC_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorWhite","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _commsPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["CCM_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorBlue","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _marinePositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["CCF_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorOrange","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _fuelPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["CCCO_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorPink","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _constructionPositions;

                    {
                        private _position = _x select 0;
                        private _markerID = format["CCS_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,"ColorGreen","ELLIPSE"] call _createMarker;
                        _markers pushback _m;
                    } forEach _settlementPositions;
                };

            };

            case "activeClusters": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    {
                        private _cluster = _x;

                        private _position = [_cluster,"position"] call ALIVE_fnc_hashGet;
                        private _owner = [_cluster,"owner"] call ALIVE_fnc_hashGet;
                        private _dimensions = [100,100];
                        private _alpha = 1;

                        private _color = "ColorGreen";
                        switch(_owner) do {
                            case "EAST":{
                                _color = "ColorRed";
                            };
                            case "WEST":{
                                _color = "ColorBlue";
                            };
                            case "CIV":{
                                _color = "ColorYellow";
                            };
                            case "GUER":{
                                _color = "ColorGreen";
                            };
                        };

                        private _markerID = format["ACC_%1_%2",_id,_forEachIndex];
                        private _m = [_markerID,_position,_dimensions,_alpha,_color,"ELLIPSE"] call _createMarker;
                        _markers pushback _m;

                    } forEach (_plotData select 2);

                };

            };

            case "casualties": {

                if(_key in (_sectorData select 1)) then {
                    private _plotData = [_sectorData, _key] call ALIVE_fnc_hashGet;

                    private _sideCasualties = [_plotData,"side"] call ALIVE_fnc_hashGet;

                    private _eastCount = 0;
                    private _westCount = 0;
                    private _civCount = 0;
                    private _guerCount = 0;

                    if("EAST" in (_sideCasualties select 1)) then {
                        _eastCount = [_sideCasualties,"EAST"] call ALIVE_fnc_hashGet;
                    };

                    if("WEST" in (_sideCasualties select 1)) then {
                        _westCount = [_sideCasualties,"WEST"] call ALIVE_fnc_hashGet;
                    };

                    if("CIV" in (_sideCasualties select 1)) then {
                        _civCount = [_sideCasualties,"CIV"] call ALIVE_fnc_hashGet;
                    };

                    if("GUER" in (_sideCasualties select 1)) then {
                        _guerCount = [_sideCasualties,"GUER"] call ALIVE_fnc_hashGet;
                    };

                    private ["_alpha"];

                    if(_eastCount > 0) then {
                        if(_eastCount > 0) then { _alpha = 0.2; };
                        if(_eastCount > 2) then { _alpha = 0.3; };
                        if(_eastCount > 4) then { _alpha = 0.4; };
                        if(_eastCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ee%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorRed"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_westCount > 0) then {
                        if(_westCount > 0) then { _alpha = 0.2; };
                        if(_westCount > 2) then { _alpha = 0.3; };
                        if(_westCount > 4) then { _alpha = 0.4; };
                        if(_westCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ew%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorBlue"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_civCount > 0) then {
                        if(_civCount > 0) then { _alpha = 0.2; };
                        if(_civCount > 2) then { _alpha = 0.3; };
                        if(_civCount > 4) then { _alpha = 0.4; };
                        if(_civCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1ec%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorGreen"] call _createMarker;
                        _markers pushback _m;
                    };

                    if(_guerCount > 0) then {
                        if(_guerCount > 0) then { _alpha = 0.2; };
                        if(_guerCount > 2) then { _alpha = 0.3; };
                        if(_guerCount > 4) then { _alpha = 0.4; };
                        if(_guerCount > 6) then { _alpha = 0.5; };

                        private _markerID = format[MTEMPLATE, format["%1eg%2",_plotterID,_id]];
                        private _m = [_markerID,_centerPosition,_dimensions,_alpha,"ColorYellow"] call _createMarker;
                        _markers pushback _m;
                    };
                };
            };
        };

        [_logic,"markers",_markers] call ALIVE_fnc_hashSet;

    };

    case "clear": {

        private _markers = [_logic,"markers",[]] call ALIVE_fnc_hashGet;

        {
            deleteMarker _x;
        } forEach _markers;

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("sectorPlot - output",_result);

_result;