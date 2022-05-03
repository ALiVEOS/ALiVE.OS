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
        _logic setvariable ["intelByObjectiveID", createHashMap];

        _result = _logic;
    };

    case "start": {
        private _timeBetweenConfidenceDecay = _logic getvariable "timeBetweenConfidenceDecay";

        private _perFrameID = [{
            private _logic = _this select 0;
            [_logic,"onFrame"] call ALiVE_fnc_G2;
        }, _timeBetweenConfidenceDecay, _logic] call CBA_fnc_addPerFrameHandler;

        _logic setvariable ["perFrameID", _perFrameID];

        [_logic,"listen"] call MAINCLASS;

        _logic setvariable ["startupComplete", true];
    };

    case "listen": {
        private _listenerID = [ALiVE_eventLog, "addListener", [_logic, [
            "OPCOM_ORDER_CONFIRMED",
            "TACOM_ORDER_ISSUED",
            "TACOM_ORDER_COMPLETE"
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

        _result = _reportID;
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
            private _report = _x;
            if (_report isequaltype "") then {
                _report = _intel get _x;
            };
            private _reportID = _report get "id";

            [_logic,_intelOnRemoveDisplayStrategy, [_logic,_report]] call MAINCLASS;

            private _profileID = _report get "profileID";
            if (!isnil "_profileID" && { _profileID != "" }) then {
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
            if (!isnil "_confidence") then {
                private _newConfidence = _confidence - _confidenceDecay;

                _y set ["confidence", _newConfidence];

                [_logic,_intelOnRemoveDisplayStrategy, [_logic,_y]] call MAINCLASS;

                if (_newConfidence <= 0) then {
                    _reportsToRemove pushback _y;
                };
            };
        } foreach _intel;

        [_logic,"removeIntelReports", _reportsToRemove] call MAINCLASS;
    };

    case "buildSpotrepForProfile": {
        _args params ["_profile","_timeSinceSeen"];
        
        if (_profile isequaltype "") then {
            _profile = [ALiVE_profileHandler,"getProfile", _profile] call ALiVE_fnc_profileHandler;
        };

        //Sanitize _profile, it may be dead and unregistered, thus returning null.
        if (isnil "_profile") exitWith {};

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
                case "OPCOM_ORDER_CONFIRMED": {
                    _eventData params ["_opcomID","_target","_operation","_side","_factions"];

                    // ["attack","defend"]
                    if (_operation in ["attack"]) then {
                        [_logic,"createFriendlyOPCOMOrder", [_opcomID,_target,_operation]] call MAINCLASS;
                    };
                };
                case "TACOM_ORDER_ISSUED": {
                    _eventData params ["_opcomID","_target","_operation","_side","_factions","_orderArguments"];

                    if (_operation in ["recon","capture"]) then {
                        [_logic,"createFriendlyTACOMOrder", [_opcomID,_target,_operation]] call MAINCLASS;
                    };
                };
                case "TACOM_ORDER_COMPLETE": {
                    _eventData params ["_opcomID","_target","_operation","_side","_factions","_success","_orderArguments"];

                    // ["defend","recon","capture"]
                    if (_operation in ["recon","capture"]) then {
                        [_logic,"removeFriendlyTACOMOrder", [_opcomID,_target,_operation]] call MAINCLASS;

                        if (!_success) then {
                            [_logic,"removeFriendlyOPCOMOrder", [_opcomID, _target]] call MAINCLASS;
                        };
                    };
                };
            };
        };
    };

    case "createFriendlyOPCOMOrder": {
        _args params ["_opcomID","_target","_operation"];

        private _objectiveID = [_target,"objectiveID"] call ALiVE_fnc_hashGet;
        private _objectiveIntelKey = [_opcomID, _objectiveID];

        private _intelByObjectiveID = _logic getvariable "intelByObjectiveID";
        private _existingObjectiveIntel = _intelByObjectiveID get _objectiveIntelKey;
        if (isnil "_existingObjectiveIntel") then {
            _existingObjectiveIntel = createHashMap;
            _intelByObjectiveID set [_objectiveIntelKey, _existingObjectiveIntel];
        };

        if ("base" in _existingObjectiveIntel) then {
            // dafuq you doing opcom?
            private _baseIntel = _existingObjectiveIntel get "base";
            [_logic,"removeIntelReports", [_baseIntel]] call MAINCLASS;
        };

        private _opcomOrderIntel = createHashMapFromArray [
            ["type", "friendlyOPCOMOrder"],
            ["opcomID", _opcomID],
            ["objective", _target],
            ["order", _operation]
        ];

        private _reportID = [_logic,"storeIntelReport", _opcomOrderIntel] call MAINCLASS;

        _existingObjectiveIntel set ["base", _reportID];
    };

    case "removeFriendlyOPCOMOrder": {
        _args params ["_opcomID","_target"];

        private _objectiveID = [_target,"objectiveID"] call ALiVE_fnc_hashGet;
        private _objectiveIntelKey = [_opcomID, _objectiveID];

        private _intelByObjectiveID = _logic getvariable "intelByObjectiveID";
        private _existingObjectiveIntel = _intelByObjectiveID get _objectiveIntelKey;

        if (!isnil "_existingObjectiveIntel") then {
            private _outstandingOrderIntel = keys _existingObjectiveIntel;
            private _outstandingReports = _outstandingOrderIntel apply { _existingObjectiveIntel get _x };

            [_logic,"removeIntelReports", _outstandingReports] call MAINCLASS;

            _intelByObjectiveID deleteat _objectiveIntelKey;
        };
    };

    case "createFriendlyTACOMOrder": {
        _args params ["_opcomID","_target","_operation"];

        private _intelType = switch (_operation) do {
            case "recon":   { "friendlyTACOMRecon" };
            case "capture": { "friendlyTACOMCapture" };
        };

        private _tacomOrderIntel = createHashMapFromArray [
            ["type", _intelType],
            ["opcomID", _opcomID],
            ["objective", _target],
            ["order", _operation]
        ];

        private _objectiveID = [_target,"objectiveID"] call ALiVE_fnc_hashGet;

        private _intelByObjectiveID = _logic getvariable "intelByObjectiveID";
        private _existingObjectiveIntel = _intelByObjectiveID get [_opcomID, _objectiveID];
        if (isnil "_existingObjectiveIntel") then {
            _existingObjectiveIntel = createHashMap;
            _intelByObjectiveID set [[_opcomID, _objectiveID], _existingObjectiveIntel];
        };

        private _reportID = [_logic,"storeIntelReport", _tacomOrderIntel] call MAINCLASS;
        _existingObjectiveIntel set [_operation, _reportID];
    };

    case "removeFriendlyTACOMOrder": {
        _args params ["_opcomID","_target","_operation"];

        private _objectiveID = [_target,"objectiveID"] call ALiVE_fnc_hashGet;

        private _intelByObjectiveID = _logic getvariable "intelByObjectiveID";
        private _objectiveIntelKey = [_opcomID, _objectiveID];
        private _existingObjectiveIntel = _intelByObjectiveID get _objectiveIntelKey;
        if (!isnil "_existingObjectiveIntel") then {
            private _operationIntel = _existingObjectiveIntel get _operation;
            if (!isnil "_operationIntel") then {
                [_logic,"removeIntelReports", [_operationIntel]] call MAINCLASS;
                _existingObjectiveIntel deleteat _operation;
            };

            //["capture","defend"]
            if (_operation in ["capture"]) then {
                [_logic,"removeFriendlyOPCOMOrder", [_opcomID, _target]] call MAINCLASS;
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

                private _markerIcon = createHashMapFromArray [
                    ["id", format [MTEMPLATE, _opcomID, _reportID, 1]],
                    ["position", _groupPosition],
                    ["shape", "ICON"],
                    ["size", [1,1]],
                    ["type", _markerType],
                    ["color", _markerColor],
                    ["alpha", _confidence]
                ];

                private _markers = [_markerIcon];

                if (_speed > 0) then {
                    private _startPoint = _groupPosition getpos [30, _direction];
                    private _endPoint = _startPoint getpos [60, _direction];
                    private _linePath = [_logic,"createPolylinePath", [
                        _startPoint,
                        _endPoint,
                        _endPoint getpos [15, _direction - 150],
                        _endPoint,
                        _endPoint getpos [15, _direction + 150]
                    ]] call MAINCLASS;

                    private _markerArrow = createHashMapFromArray [
                        ["id", format [MTEMPLATE, _opcomID, _reportID, 2]],
                        ["position", _groupPosition getpos [100, _direction]],
                        ["shape", "POLYLINE"],
                        ["path", _linePath],
                        ["color", _markerColor],
                        ["alpha", _confidence]
                    ];

                    _markers pushback _markerArrow;
                };

                _report set ["markers", _markers apply { _x get "id" }];

                [nil,"createMarkersLocally", _markers] remoteExecCall ["ALiVE_fnc_G2", _playersToSendMarkerTo];
            };

            case "friendlyOPCOMOrder": {
                private _reportID = _report get "id";
                private _opcomID = _report get "opcomID";
                private _objective = _report get "objective";
                private _order = _report get "order";

                private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
                private _objectiveSize = [_objective,"size"] call ALiVE_fnc_hashGet;

                private ["_markerColor","_markerText"];
                switch (_order) do {
                    case "attack": {
                        _markerColor = "ColorRed";
                        _markerText = "Attacking";
                    };
                    case "defend": {
                        _markerColor = "ColorBlue";
                        _markerText = "Defending";
                    };
                    default {
                        _markerColor = "ColorBlack";
                        _markerText = "Unknown";
                    };
                };

                private _circleMarker = createHashMapFromArray [
                    ["id", format [MTEMPLATE, _opcomID, _reportID, 1]],
                    ["position", _objectivePosition],
                    ["shape", "ELLIPSE"],
                    ["size", [_objectiveSize,_objectiveSize]],
                    ["type", "EmptyIcon"],
                    ["color", _markerColor],
                    ["alpha",  0.4]
                ];

                private _textMarker = createHashMapFromArray [
                    ["id", format [MTEMPLATE, _opcomID, _reportID, 2]],
                    ["position", _objectivePosition],
                    ["shape", "ICON"],
                    ["size", [0.6,0.6]],
                    ["type", "EmptyIcon"],
                    ["color", "ColorBlack"],
                    ["alpha",  0.7],
                    ["text", _markerText]
                ];

                _report set ["markers", [_circleMarker get "id", _textMarker get "id"]];

                [nil,"createMarkersLocally", [_circleMarker, _textMarker]] remoteExecCall ["ALiVE_fnc_G2", _playersToSendMarkerTo];
            };

            case "friendlyTACOMRecon": {
                private _reportID = _report get "id";
                private _opcomID = _report get "opcomID";
                private _objective = _report get "objective";
                private _order = _report get "order";

                private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
                private _objectiveSize = [_objective,"size"] call ALiVE_fnc_hashGet;
                private _objectiveSection = [_objective,"section"] call ALiVE_fnc_hashGet;

                private _assignedProfiles = _objectiveSection apply { [ALiVE_profileHandler,"getProfile", _x] call ALiVE_fnc_profileHandler };
                private _profilePositions = _assignedProfiles apply { _x select 2 select 2 };
                private _profilePositionsMidpoint = _profilePositions call ALiVE_fnc_findMidpoint;
                if (_assignedProfiles isequalto []) then {
                    systemchat format ["Assigned Profiles is Empty"];
                };
                if (isnil "_objectivePosition") then {
                    systemchat format ["Objective Position is null"];
                };
                private _dirToAttackers = _objectivePosition getdir _profilePositionsMidpoint;
                private _dirToObjective = _dirToAttackers - 180;

                private _lineCenter = _objectivePosition getpos [350, _dirToAttackers];

                private _lineMarker = createHashMapFromArray [
                    ["id", format [MTEMPLATE, _opcomID, _reportID, 1]],
                    ["position", _lineCenter],
                    ["shape", "RECTANGLE"],
                    ["size", [25, (_objectiveSize * 1.5) min 350]],
                    ["direction", _dirToAttackers - 90],
                    ["color", "ColorBlufor"],
                    ["brush", "FDiagonal"]
                ];

                private _arrowStart = _objectivePosition getpos [550, _dirToAttackers];
                private _arrowEnd = _arrowStart getpos [100, _dirToObjective];
                private _turn1 = _arrowEnd getpos [15, _dirToObjective + 90];
                private _turn2 = _turn1 getpos [45, _dirToObjective - 30];
                private _turn3 = _turn2 getpos [45, _dirToAttackers + 30];
                private _turn4 = _turn3 getpos [15, _dirToObjective + 90];
                private _turn5 = _turn4 getpos [100, _dirToAttackers];
                private _path = [_logic,"createPolylinePath", [_arrowStart,_arrowEnd, _turn1, _turn2, _turn3, _turn4, _turn5]] call MAINCLASS;

                private _arrowMarker = createHashMapFromArray [
                    ["id", format [MTEMPLATE, _opcomID, _reportID, 2]],
                    ["position", _arrowStart],
                    ["shape", "POLYLINE"],
                    ["path", _path],
                    ["color", "ColorBlufor"]
                ];

                _report set ["markers", [_lineMarker get "id", _arrowMarker get "id"]];

                [nil,"createMarkersLocally", [_lineMarker, _arrowMarker]] remoteExecCall ["ALiVE_fnc_G2", _playersToSendMarkerTo];
            };

            case "friendlyTACOMCapture": {
                private _reportID = _report get "id";
                private _opcomID = _report get "opcomID";
                private _objective = _report get "objective";
                private _order = _report get "order";

                private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
                private _objectiveSize = [_objective,"size"] call ALiVE_fnc_hashGet;
                private _objectiveSection = [_objective,"section"] call ALiVE_fnc_hashGet;

                private _assignedProfiles = (_objectiveSection apply { [ALiVE_profileHandler,"getProfile", _x] call ALiVE_fnc_profileHandler }) select { !isnil "_x" };
                private _profilePositions = _assignedProfiles apply { _x select 2 select 2 };
                private _profilePositionsMidpoint = _profilePositions call ALiVE_fnc_findMidpoint;
                private _dirToAttackers = _objectivePosition getdir _profilePositionsMidpoint;
                private _dirToObjective = _dirToAttackers - 180;

                private _lineCenter = _objectivePosition getpos [350, _dirToAttackers];

                private _lineMarker = createHashMapFromArray [
                    ["id", format [MTEMPLATE, _opcomID, _reportID, 1]],
                    ["position", _lineCenter],
                    ["shape", "RECTANGLE"],
                    ["size", [25, (_objectiveSize * 1.5) min 350]],
                    ["direction", _dirToAttackers - 90],
                    ["color", "ColorBlufor"],
                    ["brush", "FDiagonal"]
                ];

                private _arrowStart = _objectivePosition getpos [400, _dirToAttackers];
                private _arrowEnd = _arrowStart getpos [100, _dirToObjective];
                private _turn1 = _arrowEnd getpos [15, _dirToObjective + 90];
                private _turn2 = _turn1 getpos [45, _dirToObjective - 30];
                private _turn3 = _turn2 getpos [45, _dirToAttackers + 30];
                private _turn4 = _turn3 getpos [15, _dirToObjective + 90];
                private _turn5 = _turn4 getpos [100, _dirToAttackers];
                private _path = [_logic,"createPolylinePath", [_arrowStart,_arrowEnd, _turn1, _turn2, _turn3, _turn4, _turn5]] call MAINCLASS;

                private _arrowMarker = createHashMapFromArray [
                    ["id", format [MTEMPLATE, _opcomID, _reportID, 2]],
                    ["position", _arrowStart],
                    ["shape", "POLYLINE"],
                    ["path", _path],
                    ["color", "ColorBlufor"]
                ];

                _report set ["markers", [_lineMarker get "id", _arrowMarker get "id"]];

                [nil,"createMarkersLocally", [_lineMarker, _arrowMarker]] remoteExecCall ["ALiVE_fnc_G2", _playersToSendMarkerTo];
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

        private _sideObject = _logic getvariable "sideObject";
        private _playersToSendMarkerTo = allPlayers select { side (group _X) == _sideObject };

        private _reportMarkers = _report get "markers";
        [nil,"deleteMarkersLocally", _reportMarkers] remoteExecCall ["ALiVE_fnc_G2", _playersToSendMarkerTo];
    };

    case "createPolylinePath": {
        _result = [];

        {
            _result pushback (_x select 0);
            _result pushback (_x select 1);
        } foreach _args;
    };

    case "createMarkersLocally": {
        private _markersData = _args;

        {
            private _id = _x get "id";
            private _position = _x get "position";
            private _shape = _x get "shape";
            private _color = _x get "color";
            private _alpha = _x get "alpha";

            private _marker = createMarkerLocal [_id, _position];
            _marker setMarkerShapeLocal _shape;

            if (!isnil "_color") then {
                _marker setMarkerColorLocal _color;
            };
            if (!isnil "_alpha") then {
                _marker setMarkerAlphaLocal _alpha;
            };

            switch (_shape) do {
                case "ELLIPSE";
                case "RECTANGLE";
                case "ICON": {
                    private _type = _x get "type";
                    private _size = _x get "size";
                    private _dir = _x get "direction";
                    private _text = _x get "text";
                    private _brush = _x get "brush";

                    _marker setMarkerTypeLocal _type;
                    _marker setMarkerSizeLocal _size;
                    _marker setMarkerDirLocal _dir;
                    _marker setMarkerTextLocal _text;

                    if (!isnil "_brush") then {
                        _marker setMarkerBrushLocal _brush;
                    }
                };
                case "POLYLINE": {
                    private _path = _x get "path";

                    _marker setMarkerPolylineLocal _path;
                    _marker setMarkerShadowLocal false;
                };
            };
        } foreach _markersData;
    };

    case "deleteMarkersLocally": {
        private _markers = _args;

        {
            deleteMarkerLocal _x;
        } foreach _markers;
    };

    case "determineMarkerTypeandColor": {
        _args params ["_side","_groupType"];

        private ["_typePrefix","_color"];
        private _friendlySide = _logic getvariable "side";

        if (_side == _friendlySide) then {
            _typePrefix = "b";
            _color = "ColorBLUFOR";
        } else {
            _typePrefix = "o";
            _color = "ColorOPFOR";
        };

        // switch (_side) do {
        //     case "EAST": {
        //         _typePrefix = "o";
        //         _color = "ColorOPFOR";
        //     };
        //     case "WEST": {
        //         _typePrefix = "b";
        //         _color = "ColorBLUFOR";
        //     };
        //     case "GUER": {
        //         _typePrefix = "n";
        //         _color = "ColorIndependent";
        //     };
        // };

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