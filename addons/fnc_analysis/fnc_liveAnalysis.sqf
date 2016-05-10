#include <\x\alive\addons\fnc_analysis\script_component.hpp>
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

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_liveAnalysis

private ["_result"];

TRACE_1("liveAnalysis - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

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
                    ["ALiVE Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_DumpR;
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
					["ALIVE Live Analysis - register job"] call ALIVE_fnc_dump;
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
					["ALIVE Live Analysis - cancel job: %1",_jobID] call ALIVE_fnc_dump;
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

                            //["ALIVE Live Analysis - job: %1 lastRun: %2 runEvery: %3 timer: %4 runTimes: %5 of %6",_jobID,_lastRun,_runEvery,(time - _lastRun),_runCount,_maxRunCount] call ALIVE_fnc_dump;

                            // run count maxed cancel the job
                            if(_runCount > _maxRunCount && !(_maxRunCount == 0)) then {
                                _jobsToCancel set [count _jobsToCancel, _jobID];
                            }else{
                                if((time - _lastRun) > _runEvery) then {


                                    // DEBUG -------------------------------------------------------------------------------------
                                    if(_debug) then {
                                        ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                                        ["ALIVE Live Analysis - job: %1 lastRun: %2 runEvery: %3 runTimes: %4 of %5",_jobID,_lastRun,_runEvery,_runCount,_maxRunCount] call ALIVE_fnc_dump;
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
					["ALIVE Live Analysis - grid entity profile positions"] call ALIVE_fnc_dump;
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
					["ALIVE Live Analysis - cleanup grid entity profile positions"] call ALIVE_fnc_dump;
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
                    ["ALIVE Live Analysis - active sector analysis"] call ALIVE_fnc_dump;
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
                    ["ALIVE Live Analysis - cleanup active sector positions"] call ALIVE_fnc_dump;
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
					["ALIVE Live Analysis - intelligence item id: %1", _jobID] call ALIVE_fnc_dump;
				};
				// DEBUG -------------------------------------------------------------------------------------
				
				
				_intelItem = _jobArgs select 0;
				
				_side = _intelItem select 0;
				_objective = _intelItem select 1;

				_center = [_objective,"center"] call ALIVE_fnc_hashGet;
				_size = [_objective,"size"] call ALIVE_fnc_hashGet;
				_priority = [_objective,"priority"] call ALIVE_fnc_hashGet;
				_type = [_objective,"type"] call ALIVE_fnc_hashGet;
				_state = [_objective,"tacom_state","none"] call ALIVE_fnc_hashGet;
				_objectiveID = [_objective,"objectiveID"] call ALIVE_fnc_hashGet;
                _section = [_objective,"section",[]] call ALIVE_fnc_hashGet;
                
                // Installations
                _factory = [[],"convertObject",[_objective,"factory",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_HQ = [[],"convertObject",[_objective,"HQ",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_ambush = [[],"convertObject",[_objective,"ambush",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_depot = [[],"convertObject",[_objective,"depot",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_sabotage = [[],"convertObject",[_objective,"sabotage",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_ied = [[],"convertObject",[_objective,"ied",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_suicide = [[],"convertObject",[_objective,"suicide",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_roadblocks = [[],"convertObject",[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                
                _installations = [_factory,_HQ,_ambush,_depot,_sabotage,_ied,_suicide,_roadblocks];
				
				private ["_profiles","_markers","_profileID","_profile","_alpha","_marker","_color","_dir","_position","_icon","_text","_m"];
				
				// on the first run create all the markers
				if(_runCount == 0) then {

					_profiles = [];
					_markers = [];
					_alpha = 1;
					
					// create the profile marker
					{
						_profileID = _x;
						_profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
						if !(isnil "_profile") then {
						    _position = _profile select 2 select 2;

						    if!(surfaceIsWater _position) then {
						        _marker = [_profile, "createMarker", [_alpha]] call ALIVE_fnc_profileEntity;
                                _markers = _markers + _marker;
                                _profiles set [count _profiles, _profileID];
						    };

							_dir = _position getDir _center;
						};			
					} forEach _section;

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
					
					// create the objective area marker					
					_m = createMarker [format[MTEMPLATE, _objectiveID], _center];
					_m setMarkerShape "Ellipse";
					_m setMarkerBrush "FDiagonal";
					_m setMarkerSize [_size, _size];
					_m setMarkerColor _color;
					_m setMarkerAlpha _alpha;
					
					_markers = _markers + [_m];			
				
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
							_m = createMarker [format[MTEMPLATE, format["%1_dir", _objectiveID]], _position getPos [100, _dir]];
							_m setMarkerShape "ICON";
							_m setMarkerSize [0.5,0.5];
							_m setMarkerType "mil_arrow";
							_m setMarkerColor _color;
							_m setMarkerAlpha _alpha;
							_m setMarkerDir _dir;							
							
							_markers = _markers + [_m];
						
							_icon = "mil_unknown";
							_text = " sighting";
						};
						case "capture":{
						
							// create direction marker
							_m = createMarker [format[MTEMPLATE, format["%1_dir", _objectiveID]], _position getPos [100, _dir]];
							_m setMarkerShape "ICON";
							_m setMarkerSize [0.5,0.5];
							_m setMarkerType "mil_arrow2";
							_m setMarkerColor _color;
							_m setMarkerAlpha _alpha;
							_m setMarkerDir _dir;							
							
							_markers = _markers + [_m];
						
							_icon = "mil_warning";
							_text = " captured";
						};
                        case "terrorize":{
                            _icon = "mil_marker";
                            _text = " terrorize";
                        };
					};
					
					// create type marker
					_m = createMarker [format[MTEMPLATE, format["%1_type", _objectiveID]], _center];
					_m setMarkerShape "ICON";
					_m setMarkerSize [0.5, 0.5];
					_m setMarkerType _icon;
					_m setMarkerColor _color;
					_m setMarkerAlpha _alpha;
                    _m setMarkerText _text;
                    
                    _markers = _markers + [_m];
                    
                    // Show installations
                    {
                        if (alive _x) then {
                            _m = [format[MTEMPLATE,format["%1%2_inst", _objectiveID,_foreachIndex]],getposATL _x,"ICON", [1,1],"ColorRed","Installation", "n_installation", "FDiagonal",0,0.5 ] call ALIVE_fnc_createMarkerGlobal;
                        	_markers append [_m];
                        };
                    } foreach _installations;

					_jobArgs set [count _jobArgs, [_markers, _profiles]];
					
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
					["ALIVE Live Analysis - intelligence item id: %1", _jobID] call ALIVE_fnc_dump;
				};
				// DEBUG -------------------------------------------------------------------------------------
				
				
				private ["_profiles","_markers","_profileID","_profile","_alpha","_marker"];
				
				_markers = _jobArgs select 1 select 0;
				_profiles = _jobArgs select 1 select 1;
				
				{
					_profileID = _x;
					_profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
					if !(isnil "_profile") then {
						[_profile, "deleteMarker"] call ALIVE_fnc_profileEntity;
					};					
				} forEach _profiles;
				
				{
					deleteMarker _x;
				} forEach _markers;
			
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
                    ["ALIVE Live Analysis - KIA intelligence item id: %1", _jobID] call ALIVE_fnc_dump;
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

                    _markers = _markers + [_m];

                    _jobArgs set [count _jobArgs, [_markers]];

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
                    ["ALIVE Live Analysis - KIA intelligence item id: %1", _jobID] call ALIVE_fnc_dump;
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
                    ["ALIVE Live Analysis - Agent KIA intelligence item id: %1", _jobID] call ALIVE_fnc_dump;
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

                    _markers = _markers + [_m];

                    _jobArgs set [count _jobArgs, [_markers]];

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
                    ["ALIVE Live Analysis - Agent KIA intelligence item id: %1", _jobID] call ALIVE_fnc_dump;
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
                    ["ALIVE Live Analysis - Logistics insertion item id: %1", _jobID] call ALIVE_fnc_dump;
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

                    _markers = _markers + [_m];

                    _jobArgs set [count _jobArgs, [_markers]];

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
                    ["ALIVE Live Analysis - Logistics insertion item id: %1", _jobID] call ALIVE_fnc_dump;
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
                    ["ALIVE Live Analysis - Logistics destination item id: %1", _jobID] call ALIVE_fnc_dump;
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

                    _markers = _markers + [_m];

                    _jobArgs set [count _jobArgs, [_markers]];

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
                    ["ALIVE Live Analysis - Logistics destination item id: %1", _jobID] call ALIVE_fnc_dump;
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
                    ["ALIVE Live Analysis - show friendlies"] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                if(count _jobArgs > 1) then {
                    if((count (_jobArgs select 1)) > 0) then {
                        _markers = _jobArgs select 1 select 0;
                        _profiles = _jobArgs select 1 select 1;

                        {
                            _profile = _x;
                            if !(isnil "_profile") then {
                                [_profile, "deleteMarker"] call ALIVE_fnc_profileEntity;
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
                                if!((side _player) in _sides) then {
                                    _sides set [count _sides, side _player];
                                };

                            } forEach _active;

                            {
                                _nearProfiles = [_centerPosition, _radius, [str(_x),"entity"]] call ALIVE_fnc_getNearProfiles;

                                {
                                    _profile = _x;
                                    if !(isnil "_profile") then {
                                        _position = _profile select 2 select 2;

                                        if!(surfaceIsWater _position) then {
                                            _marker = [_profile, "createMarker", [1]] call ALIVE_fnc_profileEntity;
                                            _markers = _markers + _marker;
                                            _profiles set [count _profiles, _profile];
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
                    ["ALIVE Live Analysis - intelligence item id: %1", _jobID] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private ["_profiles","_markers","_profileID","_profile","_alpha","_marker"];

                _markers = _jobArgs select 1 select 0;
                _profiles = _jobArgs select 1 select 1;

                {
                    _profileID = _x;
                    _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                    if !(isnil "_profile") then {
                        [_profile, "deleteMarker"] call ALIVE_fnc_profileEntity;
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