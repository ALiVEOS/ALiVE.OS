#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(liveAnalysis);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Performs analysis task while in game

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters
String - id - ID name of the grid

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:

Examples:
(begin example)
// create a live analysis
_logic = [nil, "create"] call ALIVE_fnc_liveAnalysis;

// start analysis
_result = [_logic, "start"] call ALIVE_fnc_liveAnalysis;

See Also:

Author:
ARJay
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_liveAnalysis

TRACE_1("liveAnalysis - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = true;

#define MTEMPLATE "ALiVE_LIVEANALYSIS_%1"

switch(_operation) do {
        case "init": {

            if (isServer) then {
                    // if server, initialise module game logic
                    [_logic,"super"] call ALIVE_fnc_hashRem;
                    [_logic,"class"] call ALIVE_fnc_hashRem;
                    TRACE_1("After module init",_logic);

                    [_logic,"debug", false] call ALIVE_fnc_hashSet;
                    [_logic,"analysisJobs", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

                    ALIVE_sectorPlotterEntities = [nil, "create"] call ALIVE_fnc_plotSectors;
                    [ALIVE_sectorPlotterEntities, "init"] call ALIVE_fnc_plotSectors;

                    ALIVE_sectorPlotterActive = [nil, "create"] call ALIVE_fnc_plotSectors;
                    [ALIVE_sectorPlotterActive, "init"] call ALIVE_fnc_plotSectors;
            };

        };
        case "destroy": {

            if (isServer) then {
                    // clear plots
                    [_logic, "clear"] call MAINCLASS;

                    // if server
                    [_logic,"super"] call ALIVE_fnc_hashRem;
                    [_logic,"class"] call ALIVE_fnc_hashRem;

                    [_logic, "destroy"] call SUPERCLASS;
            };

        };
        case "debug": {
            if(typeName _args != "BOOL") then {
                    _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
            } else {
                    [_logic,"debug",_args] call ALIVE_fnc_hashSet;
            };
            ASSERT_TRUE(typeName _args == "BOOL",str _args);

            _result = _args;
        };
        case "createMarkersLocally": {
            if !(hasInterface) exitWith {};

            {
                private _id = _x get "id";
                private _position = _x get "position";
                private _shape = _x get "shape";
                private _color = _x get "color";
                private _alpha = _x get "alpha";
                private _type = _x get "type";
                private _size = _x get "size";
                private _dir = _x get "direction";
                private _text = _x get "text";
                private _brush = _x get "brush";
                private _path = _x get "path";

                if (!(isnil "_id") && {!(isnil "_position")} && {!(isnil "_shape")} && {_position isEqualType []} && {count _position >= 2}) then {
                    deleteMarkerLocal _id;
                    private _marker = createMarkerLocal [_id, _position];
                    _marker setMarkerShapeLocal _shape;

                    if !(isnil "_color") then {
                        _marker setMarkerColorLocal _color;
                    };
                    if !(isnil "_alpha") then {
                        _marker setMarkerAlphaLocal _alpha;
                    };
                    if !(isnil "_type") then {
                        _marker setMarkerTypeLocal _type;
                    };
                    if !(isnil "_size") then {
                        _marker setMarkerSizeLocal _size;
                    };
                    if !(isnil "_dir") then {
                        _marker setMarkerDirLocal _dir;
                    };
                    if !(isnil "_text") then {
                        _marker setMarkerTextLocal _text;
                    };
                    if !(isnil "_brush") then {
                        _marker setMarkerBrushLocal _brush;
                    };
                    if !(isnil "_path") then {
                        _marker setMarkerPolylineLocal _path;
                        _marker setMarkerShadowLocal false;
                    };
                };
            } foreach _args;
        };
        case "deleteMarkersLocally": {
            if !(hasInterface) exitWith {};

            {deleteMarkerLocal _x} forEach _args;
        };
        case "pause": {
            if(typeName _args != "BOOL") then {
                    // if no new value was provided return current setting
                    _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
            } else {
                    // if a new value was provided set groups list
                    ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                    private ["_state"];
                    _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                    if (_state && _args) exitwith {};

                    //Set value
                    _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;
                    ["Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_dumpR;
            };
            _result = _args;
        };
        case "registerAnalysisJob": {
            private ["_analysisJobs","_job","_jobID","_debug"];

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

            if(typeName _args == "ARRAY") then {
                _job = [] call ALIVE_fnc_hashCreate;
                [_job, "args", _args] call ALIVE_fnc_hashSet;
                [_job, "lastRun", time] call ALIVE_fnc_hashSet;
                [_job, "runCount", 0] call ALIVE_fnc_hashSet;
                _analysisJobs = [_logic,"analysisJobs"] call ALIVE_fnc_hashGet;
                _jobID = _args select 3;
                [_analysisJobs,_jobID,_job] call ALIVE_fnc_hashSet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - register job"] call ALiVE_fnc_dump;
                    _job call ALIVE_fnc_inspectHash;
                };
                // DEBUG -------------------------------------------------------------------------------------

            };

        };
        case "cancelAnalysisJob": {
            private ["_analysisJobs","_job","_jobID","_jobMethod","_jobArgs","_debug"];

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

            if(typeName _args == "STRING") then {

                _jobID = _args;
                _analysisJobs = [_logic,"analysisJobs"] call ALIVE_fnc_hashGet;
                _job = [_analysisJobs,_jobID] call ALIVE_fnc_hashGet;
                _args = [_job, "args"] call ALIVE_fnc_hashGet;
                _jobMethod = _args select 2;
                _jobArgs = _args select 4;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - cancel job: %1",_jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                switch(_jobMethod) do {
                    case "gridProfileEntity":{
                        [_logic, "cleanupGridProfileEntityAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                    case "activeSectors":{
                        [_logic, "cleanupActiveSectorAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                    case "intelligenceItem":{
                        [_logic, "cleanupIntelligenceItemAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                    case "KIAIntelligenceItem":{
                        [_logic, "cleanupKIAIntelligenceItemAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                    case "AgentKIAIntelligenceItem":{
                        [_logic, "cleanupAgentKIAIntelligenceItemAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                    case "logisticsInsertionIntelligenceItem":{
                        [_logic, "cleanupLogisticsInsertionIntelligenceItemAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                    case "logisticsDestinationIntelligenceItem":{
                        [_logic, "cleanupLogisticsDestinationIntelligenceItemAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                    case "showFriendlies":{
                        [_logic, "cleanupShowFriendliesAnalysis", [_jobID,_jobArgs]] call MAINCLASS;
                    };
                };

                [_analysisJobs,_jobID] call ALIVE_fnc_hashRem;
            };

        };
        case "getAnalysisJobs": {
            _result = [_logic, "analysisJobs"] call ALIVE_fnc_hashGet;
        };
        case "start": {
            private ["_analysisJobs","_debug"];

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;
            _analysisJobs = [_logic,"analysisJobs"] call ALIVE_fnc_hashGet;

            [_logic, _analysisJobs, _debug] spawn {

                private ["_analysisJobs","_debug","_job","_args","_lastRun","_runEvery","_jobID","_jobMethod","_jobArgs",
                "_jobsToCancel","_runCount","_maxRunCount"];

                _logic = _this select 0;
                _analysisJobs = _this select 1;
                _debug = _this select 2;

                waituntil {
                    sleep 5;

                    _jobsToCancel = [];

                    if !([_logic, "pause",false] call ALiVE_fnc_HashGet) then {

                        {
                            _job = _x;
                            _args = [_job, "args"] call ALIVE_fnc_hashGet;
                            _lastRun = [_job, "lastRun"] call ALIVE_fnc_hashGet;
                            _runCount = [_job, "runCount"] call ALIVE_fnc_hashGet;
                            _runEvery = _args select 0;
                            _maxRunCount = _args select 1;
                            _jobMethod = _args select 2;
                            _jobID = _args select 3;
                            _jobArgs = _args select 4;

                            //["Live Analysis - job: %1 lastRun: %2 runEvery: %3 timer: %4 runTimes: %5 of %6",_jobID,_lastRun,_runEvery,(time - _lastRun),_runCount,_maxRunCount] call ALiVE_fnc_dump;

                            // run count maxed cancel the job
                            if(_runCount > _maxRunCount && !(_maxRunCount == 0)) then {
                                _jobsToCancel pushback _jobID;
                            }else{
                                if((time - _lastRun) > _runEvery) then {


                                    // DEBUG -------------------------------------------------------------------------------------
                                    if(_debug) then {
                                        ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                                        ["Live Analysis - job: %1 lastRun: %2 runEvery: %3 runTimes: %4 of %5",_jobID,_lastRun,_runEvery,_runCount,_maxRunCount] call ALiVE_fnc_dump;
                                    };
                                    // DEBUG -------------------------------------------------------------------------------------


                                    switch(_jobMethod) do {
                                        case "gridProfileEntity":{
                                            [_logic, "runGridProfileEntityAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                        case "activeSectors":{
                                            [_logic, "runActiveSectorAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                        case "intelligenceItem":{
                                            [_logic, "runIntelligenceItemAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                        case "KIAIntelligenceItem":{
                                            [_logic, "runKIAIntelligenceItemAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                        case "AgentKIAIntelligenceItem":{
                                            [_logic, "runAgentKIAIntelligenceItemAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                        case "logisticsInsertionIntelligenceItem":{
                                            [_logic, "runLogisticsInsertionIntelligenceItemAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                        case "logisticsDestinationIntelligenceItem":{
                                            [_logic, "runLogisticsDestinationIntelligenceItemAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                        case "showFriendlies":{
                                            [_logic, "runShowFriendliesAnalysis", [_jobID,_jobArgs,_runCount]] call MAINCLASS;
                                        };
                                    };

                                    [_job, "lastRun", time] call ALIVE_fnc_hashSet;
                                    [_job, "runCount", (_runCount + 1)] call ALIVE_fnc_hashSet;

                                };
                            };

                        } forEach (_analysisJobs select 2);

                    };

                    {
                        [_logic, "cancelAnalysisJob", _x] call MAINCLASS;
                    } forEach _jobsToCancel;

                    //Exit if Logic has been destroyed
                    isnil "_logic" || {count (_logic select 1) == 0};
                };
            };
        };
        case "runGridProfileEntityAnalysis": {

            private ["_jobID","_jobArgs","_sectors","_plotSectors","_debug"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _plotSectors = _jobArgs select 0;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - grid entity profile positions"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // run profile analysis on all sectors
                _sectors = [ALIVE_sectorGrid] call ALIVE_fnc_gridAnalysisProfileEntity;

                if(_plotSectors) then {
                    // clear the sector data plot
                    [ALIVE_sectorPlotterEntities, "clear"] call ALIVE_fnc_plotSectors;

                    // plot the sector data
                    [ALIVE_sectorPlotterEntities, "plot", [_sectors, "entitiesBySide"]] call ALIVE_fnc_plotSectors;
                };

            };
        };
        case "cleanupGridProfileEntityAnalysis": {

            private ["_jobID","_jobArgs","_sectors","_plotSectors","_debug"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _plotSectors = _jobArgs select 0;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - cleanup grid entity profile positions"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // clear the sector data plot
                [ALIVE_sectorPlotterEntities, "clear"] call ALIVE_fnc_plotSectors;

            };
        };
        case "runActiveSectorAnalysis": {

            private ["_jobID","_jobArgs","_sectors","_plotSectors","_debug"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _plotSectors = _jobArgs select 0;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - active sector analysis"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // run profile analysis on all sectors
                ALIVE_activeSectors = [ALIVE_sectorGrid] call ALIVE_fnc_gridAnalysisActive;

                if(_plotSectors) then {
                    // clear the sector data plot
                    [ALIVE_sectorPlotterActive, "clear"] call ALIVE_fnc_plotSectors;

                    // plot the sector data
                    [ALIVE_sectorPlotterActive, "plot", [ALIVE_activeSectors, "active"]] call ALIVE_fnc_plotSectors;
                };

            };
        };
        case "cleanupActiveSectorAnalysis": {

            private ["_jobID","_jobArgs","_sectors","_plotSectors","_debug"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _plotSectors = _jobArgs select 0;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - cleanup active sector positions"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // clear the sector data plot
                [ALIVE_sectorPlotterActive, "clear"] call ALIVE_fnc_plotSectors;

            };
        };
        case "runIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_side","_sides","_objective",
            "_sector","_priority","_size","_center","_type","_state","_section","_objectiveID"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _runCount = _args select 2;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - intelligence item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                _intelItem = _jobArgs select 0;

                _side = _intelItem select 0;
                _objective = _intelItem select 1;

                _center = [_objective,"center"] call ALIVE_fnc_hashGet;
                _size = [_objective,"size"] call ALIVE_fnc_hashGet;
                _priority = [_objective,"priority"] call ALIVE_fnc_hashGet;
                _type = [_objective,"objectiveType"] call ALIVE_fnc_hashGet;
                _state = [_objective,"tacom_state","none"] call ALIVE_fnc_hashGet;
                _objectiveID = [_objective,"objectiveID"] call ALIVE_fnc_hashGet;
                _section = [_objective,"section",[]] call ALIVE_fnc_hashGet;

                private _mapIntelVisibility = toUpper (missionNamespace getVariable ["ALIVE_militaryIntelVisibility", "SIDE"]);
                private _revealInstallations = missionNamespace getVariable ["ALIVE_militaryIntelRevealInstallations", false];
                if (_revealInstallations isEqualType "") then {
                    _revealInstallations = (_revealInstallations == "true");
                };

                private _sourceSide = civilian;
                private _sourceSideText = "CIV";
                if (_side isEqualType west) then {
                    _sourceSide = _side;
                    _sourceSideText = [[_sourceSide] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText;
                } else {
                    _sourceSideText = if (_side isEqualType "") then {toUpper _side} else {toUpper str _side};
                    if (_sourceSideText in ["INDEP","INDEPENDENT","RESISTANCE"]) then {
                        _sourceSideText = "GUER";
                    };
                    _sourceSide = [_sourceSideText] call ALIVE_fnc_sideTextToObject;
                };

                private _sourceFactions = [];
                private _opcomID = [_objective,"opcomID",""] call ALIVE_fnc_hashGet;

                {
                    if (_x isEqualType [] && {([_x,"opcomID",""] call ALIVE_fnc_hashGet) == _opcomID}) exitWith {
                        _sourceFactions = [_x,"factions",[]] call ALIVE_fnc_hashGet;
                    };
                } forEach (missionNamespace getVariable ["OPCOM_instances", []]);

                private _intelRecipients = switch (_mapIntelVisibility) do {
                    case "ALL": {+allPlayers};
                    case "FRIENDLY": {allPlayers select {(_sourceSide getFriend (side (group _x))) >= 0.6}};
                    case "FACTION": {
                        if (_sourceFactions isEqualTo []) then {
                            allPlayers select {side (group _x) == _sourceSide}
                        } else {
                            allPlayers select {(faction _x) in _sourceFactions}
                        };
                    };
                    default {allPlayers select {side (group _x) == _sourceSide}};
                };
                private _intelNonRecipients = allPlayers - _intelRecipients;

                // Installations
                private _factory = [[],"convertObject",[_objective,"factory",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                private _HQ = [[],"convertObject",[_objective,"HQ",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                private _ambush = [[],"convertObject",[_objective,"ambush",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                private _depot = [[],"convertObject",[_objective,"depot",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                private _sabotage = [[],"convertObject",[_objective,"sabotage",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                private _ied = [[],"convertObject",[_objective,"ied",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                private _suicide = [[],"convertObject",[_objective,"suicide",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                private _roadblocks = [[],"convertObject",[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

                private _installations = [_factory,_HQ,_ambush,_depot,_sabotage,_ied,_suicide,_roadblocks];

                private ["_profiles","_markers","_markerData","_profileID","_profile","_alpha","_marker","_color","_dir","_position","_icon","_text","_m"];

                // on the first run create all the markers
                if(_runCount == 0) then {

                    private _profiles = [];
                    private _markers = [];
                    private _markerData = [];
                    private _alpha = 1;

                    // create the profile marker
                    {
                        private _profileID = _x;
                        private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                        if !(isnil "_profile") then {
                            _position = _profile select 2 select 2;

                            if!(surfaceIsWater _position) then {
                                _profiles pushback _profileID;
                            };

                            _dir = _position getDir _center;
                        };
                    } forEach _section;

                    if (isnil "_position") then {
                        _position = _center;
                        _dir = 0;
                    };

                    // set the side color
                    switch(_sourceSideText) do {
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
                        default {
                            _color = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
                        };
                    };

                    // create the objective area marker
                    private _m = format[MTEMPLATE, _objectiveID];
                    _markers pushback _m;
                    _markerData pushback (createHashMapFromArray [
                        ["id", _m],
                        ["position", _center],
                        ["shape", "ELLIPSE"],
                        ["brush", "FDiagonal"],
                        ["size", [_size, _size]],
                        ["color", _color],
                        ["alpha", _alpha]
                    ]);

                    _icon = "mil_unknown";
                    _text = "";
                    switch(_state) do {
                        case "reserve":{
                            _icon = "mil_marker";
                            _text = " occupied";
                        };
                        case "defend":{
                            _icon = "mil_marker";
                            _text = " occupied";
                        };
                        case "recon":{

                            // create direction marker
                            _m = format[MTEMPLATE, format["%1_dir", _objectiveID]];

                            _markers pushback _m;

                            _markerData pushback (createHashMapFromArray [
                                ["id", _m],
                                ["position", _position getPos [100, _dir]],
                                ["shape", "ICON"],
                                ["size", [0.5,0.5]],
                                ["type", "mil_arrow"],
                                ["color", _color],
                                ["alpha", _alpha],
                                ["direction", _dir]
                            ]);

                            _icon = "mil_unknown";
                            _text = " sighting";
                        };
                        case "capture":{

                            // create direction marker
                            _m = format[MTEMPLATE, format["%1_dir", _objectiveID]];

                            _markers pushback _m;

                            _markerData pushback (createHashMapFromArray [
                                ["id", _m],
                                ["position", _position getPos [100, _dir]],
                                ["shape", "ICON"],
                                ["size", [0.5,0.5]],
                                ["type", "mil_arrow2"],
                                ["color", _color],
                                ["alpha", _alpha],
                                ["direction", _dir]
                            ]);

                            _icon = "mil_warning";
                            _text = " captured";
                        };
                        case "terrorize":{
                            _icon = "mil_marker";
                            _text = " terrorize";
                        };
                    };

                    // create type marker - offset east so its text label
                    // doesn't overlap the strategic cluster / opcom labels
                    // that also render at _center (see ALiVE_fnc_debugMarkerOffset).
                    _m = format[MTEMPLATE, format["%1_type", _objectiveID]];
                    private _typeMarkerPosition = if (isNil "ALiVE_fnc_debugMarkerOffset") then {
                        _center getPos [25, 90]
                    } else {
                        ["analysis.live", _center] call ALiVE_fnc_debugMarkerOffset
                    };
                    _markers pushback _m;
                    _markerData pushback (createHashMapFromArray [
                        ["id", _m],
                        ["position", _typeMarkerPosition],
                        ["shape", "ICON"],
                        ["size", [0.5, 0.5]],
                        ["type", _icon],
                        ["color", _color],
                        ["alpha", _alpha],
                        ["text", _text]
                    ]);

                    if (_revealInstallations) then {
                        {
                            if (alive _x) then {
                                _m = format[MTEMPLATE,format["%1%2_inst", _objectiveID,_foreachIndex]];
                                _markers pushback _m;
                                _markerData pushback (createHashMapFromArray [
                                    ["id", _m],
                                    ["position", getposATL _x],
                                    ["shape", "ICON"],
                                    ["size", [1,1]],
                                    ["type", "n_installation"],
                                    ["color", "ColorRed"],
                                    ["alpha", 0.5],
                                    ["text", "Installation"]
                                ]);
                            };
                        } foreach _installations;
                    };

                    if (count _intelRecipients > 0 && {count _markerData > 0}) then {
                        [objNull,"createMarkersLocally", _markerData] remoteExecCall ["ALiVE_fnc_liveAnalysis", _intelRecipients];
                    };
                    if (count _intelNonRecipients > 0 && {count _markers > 0}) then {
                        [objNull,"deleteMarkersLocally", _markers] remoteExecCall ["ALiVE_fnc_liveAnalysis", _intelNonRecipients];
                    };

                    _jobArgs pushback ([_markers, _profiles, _markerData]);

                // on subsequent runs lower marker alpha
                } else {

                    _markers = _jobArgs select 1 select 0;
                    _profiles = _jobArgs select 1 select 1;
                    _markerData = (_jobArgs select 1) param [2, []];

                    // set alpha based on age of intel item
                    if(_runCount <= 1) then {
                        _alpha = 1;
                    };
                    if(_runCount == 2) then {
                        _alpha = 0.75;
                    };
                    if(_runCount == 3) then {
                        _alpha = 0.5;
                    };
                    if(_runCount > 3) then {
                        _alpha = 0.2;
                    };

                    {
                        _x set ["alpha", _alpha];
                    } forEach _markerData;

                    if (count _intelRecipients > 0 && {count _markerData > 0}) then {
                        [objNull,"createMarkersLocally", _markerData] remoteExecCall ["ALiVE_fnc_liveAnalysis", _intelRecipients];
                    };
                    if (count _intelNonRecipients > 0 && {count _markers > 0}) then {
                        [objNull,"deleteMarkersLocally", _markers] remoteExecCall ["ALiVE_fnc_liveAnalysis", _intelNonRecipients];
                    };

                };
            };
        };
        case "cleanupIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_side","_sides","_objective","_sector","_center","_type","_state"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                _intelItem = _jobArgs select 0;

                // set item as completed
                _intelItem set [5, true];


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - intelligence item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private ["_profiles","_markers","_profileID","_profile","_alpha","_marker"];

                _markers = _jobArgs select 1 select 0;
                _profiles = _jobArgs select 1 select 1;

                {
                    _profileID = _x;
                    _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                    if !(isnil "_profile") then {
                        [_profile, "deleteDebugMarkers"] call ALIVE_fnc_profileEntity;
                    };
                } forEach _profiles;

                if (count _markers > 0) then {
                    [objNull,"deleteMarkersLocally", _markers] remoteExecCall ["ALiVE_fnc_liveAnalysis", allPlayers];
                };

            };
        };
        case "runKIAIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_position","_faction","_side"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _runCount = _args select 2;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - KIA intelligence item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                _intelItem = _jobArgs select 0;

                _position = _intelItem select 0;
                _faction = _intelItem select 1;
                _side = _intelItem select 2;

                private ["_markers","_alpha","_marker","_color","_dir","_icon","_profiles","_m"];

                // on the first run create all the markers
                if(_runCount == 0) then {

                    _markers = [];
                    _alpha = 1;

                    // set the side color
                    switch(_side) do {
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
                        default {
                            _color = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
                        };
                    };

                    // create type marker
                    _m = createMarker [format[MTEMPLATE, format["%1_type", _jobID]], _position];
                    _m setMarkerShape "ICON";
                    _m setMarkerSize [0.3, 0.3];
                    _m setMarkerType "mil_warning";
                    _m setMarkerColor _color;
                    _m setMarkerAlpha _alpha;
                    _m setMarkerText " KIA";

                    _markers pushback _m;

                    _jobArgs pushback [_markers];

                // on subsequent runs lower marker alpha
                } else {

                    _markers = _jobArgs select 1 select 0;
                    _profiles = _jobArgs select 1 select 1;

                    // set alpha based on age of intel item
                    if(_runCount <= 1) then {
                        _alpha = 1;
                    };
                    if(_runCount == 2) then {
                        _alpha = 0.75;
                    };
                    if(_runCount == 3) then {
                        _alpha = 0.5;
                    };
                    if(_runCount > 3) then {
                        _alpha = 0.2;
                    };

                    {
                        _x setMarkerAlpha _alpha;
                    } forEach _markers;

                };
            };
        };
        case "cleanupKIAIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_side","_sides","_objective","_sector","_center","_type","_state"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                _intelItem = _jobArgs select 0;

                // set item as completed
                _intelItem set [5, true];


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - KIA intelligence item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private ["_markers"];

                _markers = _jobArgs select 1 select 0;

                {
                    deleteMarker _x;
                } forEach _markers;

            };
        };
        case "runAgentKIAIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_position","_faction","_m","_profiles"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _runCount = _args select 2;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - Agent KIA intelligence item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                _intelItem = _jobArgs select 0;

                _position = _intelItem select 0;
                _faction = _intelItem select 1;

                private ["_markers","_alpha","_marker","_color","_dir","_icon"];

                // on the first run create all the markers
                if(_runCount == 0) then {

                    _markers = [];
                    _alpha = 1;
                    _color = "ColorYellow";

                    // create type marker
                    _m = createMarker [format[MTEMPLATE, format["%1_type", _jobID]], _position];
                    _m setMarkerShape "ICON";
                    _m setMarkerSize [0.3, 0.3];
                    _m setMarkerType "mil_warning";
                    _m setMarkerColor _color;
                    _m setMarkerAlpha _alpha;
                    _m setMarkerText " KIA";

                    _markers pushback _m;

                    _jobArgs pushback [_markers];

                // on subsequent runs lower marker alpha
                } else {

                    _markers = _jobArgs select 1 select 0;
                    _profiles = _jobArgs select 1 select 1;

                    // set alpha based on age of intel item
                    if(_runCount <= 1) then {
                        _alpha = 1;
                    };
                    if(_runCount == 2) then {
                        _alpha = 0.75;
                    };
                    if(_runCount == 3) then {
                        _alpha = 0.5;
                    };
                    if(_runCount > 3) then {
                        _alpha = 0.2;
                    };

                    {
                        _x setMarkerAlpha _alpha;
                    } forEach _markers;

                };
            };
        };
        case "cleanupAgentKIAIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_side","_sides","_objective","_sector","_center","_type","_state"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                _intelItem = _jobArgs select 0;

                // set item as completed
                _intelItem set [5, true];


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - Agent KIA intelligence item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private ["_markers"];

                _markers = _jobArgs select 1 select 0;

                {
                    deleteMarker _x;
                } forEach _markers;

            };
        };
        case "runLogisticsInsertionIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_position","_faction","_side","_m","_profiles"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _runCount = _args select 2;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - Logistics insertion item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                _intelItem = _jobArgs select 0;

                _position = _intelItem select 0;
                _faction = _intelItem select 1;
                _side = _intelItem select 2;

                private ["_markers","_alpha","_marker","_color","_dir","_icon"];

                // on the first run create all the markers
                if(_runCount == 0) then {

                    _markers = [];
                    _alpha = 1;

                    // set the side color
                    switch(_side) do {
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
                        default {
                            _color = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
                        };
                    };

                    // create type marker
                    _m = createMarker [format[MTEMPLATE, format["%1_type", _jobID]], _position];
                    _m setMarkerShape "ICON";
                    _m setMarkerSize [0.3, 0.3];
                    _m setMarkerType "mil_start";
                    _m setMarkerColor _color;
                    _m setMarkerAlpha _alpha;
                    _m setMarkerText " insertion";

                    _markers pushback _m;

                    _jobArgs pushback [_markers];

                // on subsequent runs lower marker alpha
                } else {

                    _markers = _jobArgs select 1 select 0;
                    _profiles = _jobArgs select 1 select 1;

                    // set alpha based on age of intel item
                    if(_runCount <= 1) then {
                        _alpha = 1;
                    };
                    if(_runCount == 2) then {
                        _alpha = 0.75;
                    };
                    if(_runCount == 3) then {
                        _alpha = 0.5;
                    };
                    if(_runCount > 3) then {
                        _alpha = 0.2;
                    };

                    {
                        _x setMarkerAlpha _alpha;
                    } forEach _markers;

                };
            };
        };
        case "cleanupLogisticsInsertionIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_side","_sides","_objective","_sector","_center","_type","_state"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                _intelItem = _jobArgs select 0;

                // set item as completed
                _intelItem set [5, true];


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - Logistics insertion item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private ["_markers"];

                _markers = _jobArgs select 1 select 0;

                {
                    deleteMarker _x;
                } forEach _markers;

            };
        };
        case "runLogisticsDestinationIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_position","_faction","_side","_m"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _runCount = _args select 2;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - Logistics destination item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                _intelItem = _jobArgs select 0;

                _position = _intelItem select 0;
                _faction = _intelItem select 1;
                _side = _intelItem select 2;

                private ["_markers","_alpha","_marker","_color","_dir","_icon","_profiles"];

                // on the first run create all the markers
                if(_runCount == 0) then {

                    _markers = [];
                    _alpha = 1;

                    // set the side color
                    switch(_side) do {
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
                        default {
                            _color = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
                        };
                    };

                    // create type marker
                    _m = createMarker [format[MTEMPLATE, format["%1_type", _jobID]], _position];
                    _m setMarkerShape "ICON";
                    _m setMarkerSize [0.3, 0.3];
                    _m setMarkerType "mil_end";
                    _m setMarkerColor _color;
                    _m setMarkerAlpha _alpha;
                    _m setMarkerText " destination";

                    _markers pushback _m;

                    _jobArgs pushback [_markers];

                // on subsequent runs lower marker alpha
                } else {

                    _markers = _jobArgs select 1 select 0;
                    _profiles = _jobArgs select 1 select 1;

                    // set alpha based on age of intel item
                    if(_runCount <= 1) then {
                        _alpha = 1;
                    };
                    if(_runCount == 2) then {
                        _alpha = 0.75;
                    };
                    if(_runCount == 3) then {
                        _alpha = 0.5;
                    };
                    if(_runCount > 3) then {
                        _alpha = 0.2;
                    };

                    {
                        _x setMarkerAlpha _alpha;
                    } forEach _markers;

                };
            };
        };
        case "cleanupLogisticsDestinationIntelligenceItemAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_side","_sides","_objective","_sector","_center","_type","_state"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                _intelItem = _jobArgs select 0;

                // set item as completed
                _intelItem set [5, true];


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - Logistics destination item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private ["_markers"];

                _markers = _jobArgs select 1 select 0;

                {
                    deleteMarker _x;
                } forEach _markers;

            };
        };
        case "runShowFriendliesAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_radius","_debug","_sector","_side","_centerPosition","_sectorData","_profiles","_markers",
            "_active","_sides","_player","_nearProfiles","_profile","_position","_centerPosition","_sectorData","_marker"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;
                _runCount = _args select 2;

                _radius = _jobArgs select 0;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - show friendlies"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                if(count _jobArgs > 1) then {
                    if((count (_jobArgs select 1)) > 0) then {
                        _markers = _jobArgs select 1 select 0;
                        _profiles = _jobArgs select 1 select 1;

                        {
                            _profile = _x;
                            if !(isnil "_profile") then {
                                [_profile, "deleteDebugMarkers"] call ALIVE_fnc_profileEntity;
                            };
                        } forEach _profiles;

                        {
                            deleteMarker _x;
                        } forEach _markers;
                    };
                };

                _jobArgs set [1, []];

                _profiles = [];
                _markers = [];

                if(!isNil "ALIVE_activeSectors") then {

                    {
                        _sector = _x;
                        _centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
                        _sectorData = _sector select 2 select 0;
                        if("active" in (_sectorData select 1)) then {
                            _active = [_sectorData, "active"] call ALIVE_fnc_hashGet;

                            _sides = [];
                            {
                                _player = _x select 0;
                                if!((side group _player) in _sides) then {
                                    _sides pushback (side group _player);
                                };

                            } forEach _active;

                            {
                                _nearProfiles = [_centerPosition, _radius, [str(_x),"entity"]] call ALIVE_fnc_getNearProfiles;

                                {
                                    _profile = _x;
                                    if !(isnil "_profile") then {
                                        _position = _profile select 2 select 2;

                                        if!(surfaceIsWater _position) then {
                                            // Pass [true] to force-render so the server-side analysis pump
                                            // creates markers regardless of the server's visibleMap state
                                            // (issue #606 — friendly-intel was silently no-op on dedicated
                                            // server because the server never has a map open). See the
                                            // matching comment in sys_profile/fnc_profileEntity.sqf
                                            // case "createDebugMarkers".
                                            _marker = [_profile, "createDebugMarkers", [true]] call ALIVE_fnc_profileEntity;
                                            _markers = _markers + _marker;
                                            _profiles pushback _profile;
                                        };

                                    };
                                } forEach _nearProfiles;

                            } forEach _sides;
                        };

                    } forEach ALIVE_activeSectors;

                };

                _jobArgs set [1, [_markers, _profiles]];
            };
        };
        case "cleanupShowFriendliesAnalysis": {

            private ["_jobID","_jobArgs","_runCount","_debug","_intelItem","_side","_sides","_objective","_sector","_center","_type","_state"];

            if(typeName _args == "ARRAY") then {

                _jobID = _args select 0;
                _jobArgs = _args select 1;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                _intelItem = _jobArgs select 0;

                // set item as completed
                _intelItem set [5, true];


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Live Analysis - intelligence item id: %1", _jobID] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private ["_profiles","_markers","_profileID","_profile","_alpha","_marker"];

                _markers = _jobArgs select 1 select 0;
                _profiles = _jobArgs select 1 select 1;

                {
                    _profileID = _x;
                    _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                    if !(isnil "_profile") then {
                        [_profile, "deleteDebugMarkers"] call ALIVE_fnc_profileEntity;
                    };
                } forEach _profiles;

                {
                    deleteMarker _x;
                } forEach _markers;

            };
        };
        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("liveAnalysis - output",_result);
_result;
