#include "\x\alive\addons\mil_intelligence\script_component.hpp"
SCRIPT(G2);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_G2
Description:

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClass
#define MAINCLASS   ALiVE_fnc_G2
#define MTEMPLATE   "ALiVE_G2_%1_%2_%3"

private "_result";

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    "_args"
];

// https://docs.google.com/document/d/10fISYf_yAGgBsMOAPpzvOnSIBfteXFBsOG13JqIujcM/edit#heading=h.ik70z9iq923x

switch(_operation) do {
    case "create": {
        _args params ["_opcom"];

        _logic = [nil,"create"] call SUPERCLASS;

        _logic setvariable ["super", QUOTE(SUPERCLASS)];
        _logic setvariable ["class", QUOTE(MAINCLASS)];
        _logic setvariable ["moduleType", "ALiVE_G2"];
        _logic setvariable ["listenerID", -1];
        _logic setvariable ["startupComplete", false];

        private _side = [_opcom,"side"] call ALiVE_fnc_hashGet;
        private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

        _logic setvariable ["opcom", _opcom];
        _logic setvariable ["opcomID", [_opcom,"opcomID"] call ALiVE_fnc_hashGet];
        _logic setvariable ["side", _side];
        _logic setvariable ["sideObject", _sideObject];

        _logic setvariable ["perFrameID", -1];
        _logic setvariable ["timeBetweenConfidenceDecay", 30];

        [_logic,"setIntelDisplayStrategy", "map"] call MAINCLASS;

        _logic setvariable ["nextIntelIDNum", 0];
        _logic setvariable ["maxIntelLifetime", 3 * 60];

        _logic setvariable ["intel", createHashMap];
        _logic setvariable ["spotrepsByProfileID", createHashMap];

        _result = _logic;
    };

    case "start": {
        private _timeBetweenConfidenceDecay = _logic getvariable "timeBetweenConfidenceDecay";

        [_logic,"listen"] call MAINCLASS;

        private _perFrameID = [{
            private _logic = _this select 0;
            [_logic,"onFrame"] call ALiVE_fnc_G2;
        }, _timeBetweenConfidenceDecay, _logic] call CBA_fnc_addPerFrameHandler;

        _logic setvariable ["perFrameID", _perFrameID];

        _logic setvariable ["startupComplete", true];
    };

    case "listen": {
        private _listenerID = [ALiVE_eventLog, "addListener", [_logic, [
            "OPCOM_ORDER_CONFIRMED",
            "TACOM_ORDER_ISSUED"
        ]]] call ALiVE_fnc_eventLog;
        _logic setvariable ["listenerID", _listenerID];
    };

    case "getNextIntelID": {
        private _nextIntelIDNum = _logic getvariable "nextIntelIDNum";
        _logic setvariable ["nextIntelIDNum", _nextIntelIDNum + 1];

        _result = format ["intel_%1", _nextIntelIDNum];
    };

    case "getIntelDisplayStrategies": {
        _result = ["Map"];
    };

    case "setIntelDisplayStrategy": {
        private _strategy = _args;

        switch (tolower _strategy) do {
            case "map": {
                _logic setvariable ["intelDisplayStrategies", createHashMapFromArray [
                    ["onCreate", "onCreateMAP"],
                    ["onDecay", "onDecayMAP"],
                    ["onRemove", "onRemoveMAP"]
                ]];
            };
        };
    };

    /*
        opcom = OPCOM_INSTANCES select 0;
        g2 = [opcom,"G2"] call ALiVE_fnc_hashGet;
        [g2,"createSpotrep", [
            "EAST",
            "OPF_F",
            "",
            player getRelPos [100, getdir player],
            "Infantry",
            8,
            0,
            0,
            0
        ]] call ALiVE_fnc_G2;
    */

    case "createSpotrep": {
        _args params ["_side","_faction","_profileID","_groupPosition","_groupType","_groupCount","_groupSpeed","_groupDirection","_timeSinceSeen"];

        private _maxIntelLifetime = _logic getvariable "maxIntelLifetime";

        private _reportConfidence = 1 - ((_timeSinceSeen * 60) / _maxIntelLifetime);

        // what the fuck are you even doing?
        if (_reportConfidence <= 0) exitwith {};

        private _spotrep = createHashMapFromArray [
            ["type", "spotrep"],
            ["side", _side],
            ["faction", _faction],
            ["profileID", _profileID],
            ["position", _groupPosition],
            ["groupType", tolower _groupType],
            ["groupCount", _groupCount],
            ["speed", _groupSpeed],
            ["direction", _groupDirection],
            ["timeSinceSeen", _timeSinceSeen],
            ["confidence", _reportConfidence]
        ];

        if (_profileID != "") then {
            private _spotrepsByProfileID = _logic getvariable "spotrepsByProfileID";

            private _previousReport = _spotrepsByProfileID get _profileID;
            if (!isnil "_previousReport") then {
                [_logic,"removeIntelReports", [_previousReport]] call MAINCLASS;
            };

            _spotrepsByProfileID set [_profileID, _spotrep];
        };

        [_logic,"storeIntelReport", _spotrep] call MAINCLASS;

        _result = _spotrep;
    };

    case "storeIntelReport": {
        private _report = _args;

        private _reportID = [_logic,"getNextIntelID"] call MAINCLASS;
        _report set ["id", _reportID];

        private _intel = _logic getvariable "intel";
        _intel set [_reportID, _report];

        private _intelDisplayStrategies = _logic getvariable "intelDisplayStrategies";
        private _intelOnRemoveDisplayStrategy = _intelDisplayStrategies get "onCreate";
        [_logic,_intelOnRemoveDisplayStrategy, [_logic,_report]] call MAINCLASS;
    };

    case "updateIntelReport": {
        _args params ["_report","_changes"];

        {
            _report set [_this select 0, _this select 1];
        } foreach _changes;
    };

    case "refreshIntelReport": {
        private _reportID = _args;

        private _intel = _logic getvariable "intel";
        private _intelReport = _intel get _reportID;
        if (!isnil "_intelReport") then {
            [_logic,"updateIntelReport", [_intelReport, ["confidence", 1]]] call MAINCLASS;
        };
    };

    case "removeIntelReports": {
        private _reports = _args;

        private _intel = _logic getvariable "intel";
        private _intelDisplayStrategies = _logic getvariable "intelDisplayStrategies";
        private _intelOnRemoveDisplayStrategy = _intelDisplayStrategies get "onRemove";

        {
            private _reportID = _x get "id";

            [_logic,_intelOnRemoveDisplayStrategy, [_logic,_x]] call MAINCLASS;

            private _profileID = _x get "profileID";
            if (_profileID != "") then {
                private _spotrepsByProfileID = _logic getvariable "spotrepsByProfileID";
                _spotrepsByProfileID deleteat _profileID;
            };

            _intel deleteat _reportID;
        } foreach _reports;
    };

    case "removeProfileSpotreps": {
        private _profiles = _args;

        private _spotrepsByProfileID = _logic getvariable "spotrepsByProfileID";
        private _spotrepsToRemove = [];
        {
            private _profileSpotrep = _spotrepsByProfileID get _x;
            if (!isnil "_profileSpotrep") then {
                _spotrepsToRemove pushback _profileSpotrep;
            };
        } foreach _profiles;

        [_logic,"removeIntelReports", _spotrepsToRemove] call MAINCLASS;
    };

    case "onFrame": {
        if (isGamePaused) exitwith {};

        private _intel = _logic getvariable "intel";
        private _maxIntelLifetime = _logic getvariable "maxIntelLifetime";
        private _timeBetweenConfidenceDecay = _logic getvariable "timeBetweenConfidenceDecay";
        private _confidenceDecay = (_timeBetweenConfidenceDecay / _maxIntelLifetime) * accTime;

        private _intelDisplayStrategies = _logic getvariable "intelDisplayStrategies";
        private _intelOnRemoveDisplayStrategy = _intelDisplayStrategies get "onDecay";

        private _reportsToRemove = [];
        {
            private _confidence = _y get "confidence";
            private _newConfidence = _confidence - _confidenceDecay;

            _y set ["confidence", _newConfidence];

            [_logic,_intelOnRemoveDisplayStrategy, [_logic,_y]] call MAINCLASS;

            if (_newConfidence <= 0) then {
                _reportsToRemove pushback _y;
            };
        } foreach _intel;

        [_logic,"removeIntelReports", _reportsToRemove] call MAINCLASS;
    };

    case "buildSpotrepForProfile": {
        _args params ["_profile","_timeSinceSeen"];

        if (_profile isequaltype "") then {
            _profile = [ALiVE_profileHandler,"getProfile", _profile] call ALiVE_fnc_profileHandler;
        };

        private _profileID = _profile select 2 select 4;
        private _side = _profile select 2 select 3;
        private _position = _profile select 2 select 2;

        private _faction = [_profile,"faction"] call ALiVE_fnc_hashGet;

        private _entityType = _profile select 2 select 5;
        private ["_speed","_direction","_groupType","_groupSize"];
        if (_entityType == "entity") then {
            // calculate speed and direction
            private _waypoints = _profile select 2 select 16;
            if (_waypoints isnotequalto []) then {
                private _nextWP = _waypoints select 0;
                private _nextWPPos = _nextWP select 2 select 0;
                _direction = _position getdir _nextWPPos;
                _speed = (_profile select 2 select 22) select 1;
            } else {
                _direction = 0;
                _speed = 0;
            };

            // calculate group size
            private _vehiclesInCommandOf = _profile select 2 select 8;
            if (_vehiclesInCommandOf isequalto []) then {
                private _units = _profile select 2 select 21;
                _groupSize = count _units;
                _groupType = "infantry";
            } else {
                _groupSize = count _vehiclesInCommandOf;
                private _vehicleInCommandOf = [ALiVE_profileHandler,"getProfile", _vehiclesInCommandOf select 0] call ALiVE_fnc_profileHandler;
                _groupType = [_vehicleInCommandOf,"objectType"] call ALiVE_fnc_hashGet;
            };
        } else {
            _speed = 0;
            _direction = 0;
            _groupSize = 1;
            _groupType = [_profile,"objectType"] call ALiVE_fnc_hashGet;
        };

        _result = [
            _side,
            _faction,
            _profileID,
            _position,
            _groupType,
            _groupSize,
            _speed,
            _direction,
            _timeSinceSeen
        ];
    };

    case "handleEvent": {
        private _event = _args;

        private _opcomID = _logic getvariable "opcomID";

        private _eventData = [_event,"data"] call ALiVE_fnc_hashGet;
        private _eventOpcomID = _eventData select 0;

        if (_opcomID == _eventOpcomID) then {
            private _type = [_event,"type"] call ALiVE_fnc_hashGet;

            switch (_type) do {

            };
        };
    };

    /////////////////////////////////////////////////////////////////////

    case "getMovingSpotreps": {
        private _intel = _logic getvariable "intel";
        _result = [];
        {
            private _type = _y get "type";
            if (_type == "spotrep") then {
                private _speed = _y get "speed";
                if (_speed > 0) then {
                    _result pushback _y;
                };
            };
        } foreach _intel;
    };

    case "coolshit": {
        private _movingSpotreps = [_logic,"getMovingSpotreps"] call MAINCLASS;
        private _movingSpotrepDatapoints = _movingSpotreps apply {
            private _position = _x get "position";
            [_position, _x]
        };
        private _convexHull = _movingSpotrepDatapoints call ALiVE_fnc_findConvexHull;
        
    };

    /////////////////////////////////////////////////////////////////////

    // map display strategies
    case "onCreateMAP": {
        _args params ["_logic","_report"];

        private _sideObject = _logic getvariable "sideObject";
        private _playersToSendMarkerTo = allPlayers select { side (group _X) == _sideObject };
        systemchat format ["Sending to players of Side: %1 - count = %2", _sideObject, count _playersToSendMarkerTo];

        private _reportType = _report get "type";
        switch (_reportType) do {
            case "spotrep": {
                private _reportID = _report get "id";
                private _groupSide = _report get "side";
                private _groupFaction = _report get "faction";
                private _groupPosition = _report get "position";
                private _groupType = _report get "groupType";
                private _groupCount = _report get "count";
                private _speed = _report get "speed";
                private _direction = _report get "direction";
                private _confidence = _report get "confidence";

                ([_logic,"determineMarkerTypeandColor", [_groupSide, _groupType]] call MAINCLASS) params ["_markerType","_markerColor"];

                private _opcomID = _logic getvariable "opcomID";

                private _markerIcon = [
                    format [MTEMPLATE, _opcomID, _reportID, 1],
                    _groupPosition,
                    "ICON",
                    [1, 1],
                    _markerType,
                    _markerColor,
                    0,
                    _confidence
                ];

                // private _marker = createMarker [format [MTEMPLATE, _opcomID, _reportID, 1], _groupPosition];
                // _marker setMarkerShape "ICON";
                // _marker setMarkerSize [1, 1];
                // _marker setMarkerType _markerType;
                // _marker setMarkerColor _markerColor;

                private _markers = [_markerIcon];

                if (_speed > 0) then {
                    private _markerArrow = [
                        format [MTEMPLATE, _opcomID, _reportID, 2],
                        _groupPosition getpos [100, _direction],
                        "ICON",
                        [1, 2],
                        "hd_arrow",
                        _markerColor,
                        _direction,
                        _confidence
                    ];

                    // private _arrowMarker = createMarker [format [MTEMPLATE, _opcomID, _reportID, 2], _groupPosition getpos [100, _direction]];
                    // _arrowMarker setMarkerShape "ICON";
                    // _arrowMarker setMarkerSize [1, 2];
                    // _arrowMarker setMarkerType "hd_arrow";
                    // _arrowMarker setMarkerColor _markerColor;
                    // _arrowMarker setMarkerDir _direction;

                    _markers pushback _markerArrow;
                };

                _report set ["markers", _markers apply { _x select 0 }];

                [nil,"createMarkersLocally", _markers] remoteExecCall ["ALiVE_fnc_G2", _playersToSendMarkerTo];
            };
        };
    };

    case "onDecayMAP": {
        _args params ["_logic","_report"];

        private _reportMarkers = _report get "markers";
        private _reportConfidence = _report get "confidence";

        {
            _x setMarkerAlpha _reportConfidence;
        } foreach _reportMarkers;
    };

    case "onRemoveMAP": {
        _args params ["_logic","_report"];

        private _reportMarkers = _report get "markers";
        {
            deletemarker _x;
        } foreach _reportMarkers;
    };

    case "createMarkersLocally": {
        private _markersData = _args;

        {
            _x params ["_id","_position","_shape","_size","_type","_color","_dir","_alpha"];

            private _marker = createMarkerLocal [_id, _position];
            _marker setMarkerShapeLocal _shape;
            _marker setMarkerSizeLocal _size;
            _marker setMarkerTypeLocal _type;
            _marker setMarkerColorLocal _color;
            _marker setMarkerDirLocal _dir;
            _marker setMarkerAlphaLocal _alpha;
        } foreach _markersData;
    };

    case "determineMarkerTypeandColor": {
        _args params ["_side","_groupType"];

        private ["_typePrefix","_color"];
        switch (_side) do {
            case "EAST": {
                _typePrefix = "b";
                _color = "ColorOPFOR";
            };
            case "WEST": {
                _typePrefix = "o";
                _color = "ColorBLUFOR";
            };
            case "GUER": {
                _typePrefix = "n";
                _color = "ColorIndependent";
            };
        };

        private _markerType = switch (_groupType) do {
            case "infantry": { format ["%1_inf", _typePrefix] };
            case "specops": { format ["%1_recon", _typePrefix] };
            case "car";
            case "truck";
            case "motorized": { format ["%1_motor_inf", _typePrefix] };
            case "mechanized": { format ["%1_mech_inf", _typePrefix] };
            case "tank";
            case "armored": { format ["%1_armor", _typePrefix] };
            case "artillery": { format ["%1_art", _typePrefix] };
            case "ship";
            case "boat": { format ["%1_unknown", _typePrefix] };
            case "helicopter": { format ["%1_air", _typePrefix] };
            case "plane": { format ["%1_plane", _typePrefix] };
            case "uav": { format ["%1_uav", _typePrefix] };
            default { format ["%1_unknown", _typePrefix] };
        };

        _result = [_markerType,_color];
    };
    //

    case "debug": {
        if (!isnil "_args") then {
            _logic setvariable [_operation, _args];
        } else {
            _result = _logic getvariable _operation;
        };
    };

    case "destroy": {
        if (isServer) then {
            [_logic,"debug", false] call MAINCLASS;

            private _intel = _logic getvariable "intel";
            private _allReports = (keys _intel) apply { _intel get _x };
            [_logic,"removeIntelReports", _allReports] call MAINCLASS;

            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];

            [_logic,"destroy"] call SUPERCLASS;
        };
    };

    default {
        if (isnil "_args") then {
            _result = [_logic, _operation] call SUPERCLASS;
        } else {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
    };
};

if (!isnil "_result") then { _result } else { nil };