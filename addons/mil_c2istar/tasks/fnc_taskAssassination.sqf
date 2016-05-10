#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskAssassination);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskAssassination

Description:
Assault Task

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskState","_taskID","_task","_params","_debug","_result","_nextState"];

_taskState = _this select 0;
_taskID = _this select 1;
_task = _this select 2;
_params = _this select 3;
_debug = _this select 4;
_result = [];

switch (_taskState) do {
	case "init":{

	    private["_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskPlayers","_taskEnemyFaction","_taskCurrent",
	    "_taskApplyType","_taskEnemySide","_enemyClusters","_targetPosition"];

        _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;
        _taskFaction = _task select 3;
        _taskLocationType = _task select 5;
        _taskLocation = _task select 6;
        _taskPlayers = _task select 7;
        _taskEnemyFaction = _task select 8;
        _taskCurrent = _taskData select 9;
        _taskApplyType = _taskData select 10;
        
        _tasksCurrent = ([ALiVE_TaskHandler,"tasks",["",[],[],nil]] call ALiVE_fnc_HashGet) select 2;
        
        if (_taskID == "") exitwith {["C2ISTAR - Task Assasination - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task Assasination - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task Assasination - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task Assasination - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task Assasination - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task Assasination - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task Assasination - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task Assasination - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        // establish the location for the task
        // get enemy occupied cluster position

/*

        _targetPosition = [_taskLocation,_taskLocationType,_taskEnemySide] call ALIVE_fnc_taskGetSideCluster;

        if(count _targetPosition == 0) then {

            // no enemy occupied cluster found
            // try to get a position containing enemy

            _targetPosition = [_taskLocation,_taskLocationType,_taskEnemySide] call ALIVE_fnc_taskGetSideSectorCompositionPosition;

            // spawn a populated composition

            [_targetPosition, "objectives", _taskEnemyFaction, 2] call ALIVE_fnc_spawnRandomPopulatedComposition;

        };

        _targetPosition = position (nearestBuilding _targetPosition);
        _targetPosition = _targetPosition findEmptyPosition [0,200];

*/

		if (_taskLocationType in ["Short","Medium","Long"]) then {
            
			if (!isnil "OPCOM_instances") then {
	                
				//["Selecting Task location from OPCOMs"] call ALiVE_fnc_DumpR;
				_triggerStates = ["defend","defending","reserve","reserving","idle","unassigned"];
				_objectives = [];
				{
				    _OPCOM = _x;
					_OPCOM_factions = [_OPCOM,"factions",""] call ALiVE_fnc_HashGet;
				    _OPCOM_side = [_OPCOM,"side",""] call ALiVE_fnc_HashGet;
				    
				    //["Looking up correct OPCOM %1 for faction %2",_OPCOM_factions,_taskEnemyFaction] call ALiVE_fnc_DumpR;
					if ({_x == _taskEnemyFaction} count _OPCOM_factions > 0) then {
						_OPCOM_objectives = [_OPCOM,"objectives",[]] call ALiVE_fnc_HashGet;
					  	
				        //["Looking up correct ones in %1 objectives for faction %2",count _OPCOM_objectives,_taskEnemyFaction] call ALiVE_fnc_DumpR;
						{
							_OPCOM_objective = _x;
							_OPCOM_objective_state = [_OPCOM_objective,"opcom_state",""] call ALiVE_fnc_HashGet;
				            _OPCOM_objective_center = [_OPCOM_objective,"center",[0,0,0]] call ALiVE_fnc_HashGet;
				
				            //["Matching state %1 in triggerstates %2 tasks %3 faction %4!",_OPCOM_objective_state,_triggerStates,_tasksCurrent,_taskFaction] call ALiVE_fnc_DumpR;
								if (
				                	_OPCOM_objective_state in _triggerStates && 
				                	{(({(_x select 4) == _taskFaction && {(_x select 3) distance _OPCOM_objective_center < 500}} count _tasksCurrent) == 0)}
				            ) then {
				                	_objectives set [count _objectives,_OPCOM_objective];
				            };
						} foreach _OPCOM_objectives;
					};
				} foreach OPCOM_instances;
				
				if (count _objectives > 0) then {
					_objectives = [_objectives,[_taskLocation],{_Input0 distance ([_x,"center"] call ALiVE_fnc_HashGet)},"ASCEND",{
				        
				        _id = [_x,"opcomID",""] call ALiVE_fnc_HashGet;
				        _pos = [_x,"center"] call ALiVE_fnc_HashGet;
				        _opcom = [objNull,"getOPCOMbyid",_id] call ALiVE_fnc_OPCOM;
				        _side = [_opcom,"side",""] call ALiVE_fnc_HashGet;
				        
				        !([_pos,_side,500,true] call ALiVE_fnc_isEnemyNear) && {_pos distance _Input0 > 1200};
				    }] call ALiVE_fnc_SortBy;
	            
	            	_targetPosition = [_objectives select 0,"center"] call ALiVE_fnc_HashGet;
	            
	            	_targetPosition = [_targetPosition,500] call ALiVE_fnc_findFlatArea;
	
	            	[_targetPosition, "camps", _taskEnemyFaction, 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
				};
			} else {
	            _targetPosition = [_taskLocation,500] call ALiVE_fnc_findFlatArea;
	        };
        } else {
            _targetPosition = _taskLocation;
            
            [_targetPosition, "camps", _taskEnemyFaction, 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
        };
        
        if!(isNil "_targetPosition") then {

            private["_dialogOptions","_dialogOption"];

            // select the random text

            _dialogOptions = [ALIVE_generatedTasks,"Assassination"] call ALIVE_fnc_hashGet;
            _dialogOptions = _dialogOptions select 1;
            _dialogOption = _dialogOptions call BIS_fnc_selectRandom;

            // format the dialog options

            private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

            _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_nearestTown];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
            _formatMessage = _formatChat select 0;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText,_nearestTown];
            _formatMessage set [1,_formatMessageText];
            _formatChat set [0,_formatMessage];
            [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashGet;

            // create the tasks

            private["_state","_tasks","_taskIDs","_dialog","_taskTitle","_taskDescription","_taskSource","_newTask","_newTaskID","_taskParams"];

            if(_taskCurrent == 'Y')then {
                _state = "Assigned";
            }else{
                _state = "Created";
            };

            _tasks = [];
            _taskIDs = [];

            // create the parent task

            _dialog = [_dialogOption,"Parent"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _taskSource = format["%1-Assassination-Parent",_taskID];
            _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_taskID];

            // create the destroy task

            _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c1",_taskID];
            _taskSource = format["%1-Assassination-Destroy",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_newTaskID];

            // select the type of HVT spawn

            private["_spawnTypes","_spawnType"];

            _spawnTypes = ["static","insertion","extraction"];
            _spawnType = _spawnTypes call BIS_fnc_selectRandom;

            // store task data in the params for this task set

            _taskParams = [] call ALIVE_fnc_hashCreate;
            [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
            [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
            [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
            [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
            [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;
            [_taskParams,"HVTSpawned",false] call ALIVE_fnc_hashSet;
            [_taskParams,"HVTSpawnType",_spawnType] call ALIVE_fnc_hashSet;

            // return the created tasks and params

            _result = [_tasks,_taskParams];

        };

	};
	case "Parent":{

	};
	case "Destroy":{

	    private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
	    "_destinationReached","_taskIDs","_HVTSpawned","_HVTSpawnType","_lastState","_taskDialog","_currentTaskDialog"];

	    _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;
        _taskPosition = _task select 3;
        _taskFaction = _task select 4;
        _taskTitle = _task select 5;
        _taskDescription = _task select 6;
        _taskPlayers = _task select 7 select 0;

        _lastState = [_params,"lastState"] call ALIVE_fnc_hashGet;
        _taskDialog = [_params,"dialog"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;
        _HVTSpawned = [_params,"HVTSpawned"] call ALIVE_fnc_hashGet;
        _HVTSpawnType = [_taskParams,"HVTSpawnType"] call ALIVE_fnc_hashGet;

        if(_lastState != "Destroy") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Destroy"] call ALIVE_fnc_hashSet;
        };

        if!(_HVTSpawned) then {

            _destinationReached = [_taskPosition,_taskPlayers,1000] call ALIVE_fnc_taskHavePlayersReachedDestination;

            if(_destinationReached) then {

                private["_taskEnemyFaction","_taskEnemySide"];

                _taskEnemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
                _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
                _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
                _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

                // spawn the HVT

                switch(_HVTSpawnType) do {
                    case "static":{

                        private["_taskObjects","_tables","_chairs","_electronics","_documents","_tableClass","_electronicClass",
                        "_documentClass","_table","_electronic","_document"];

                        // spawn some objects

                        _taskObjects = ALIVE_taskObjects;
                        _tables = [_taskObjects,"tables"] call ALIVE_fnc_hashGet;
                        _chairs = [_taskObjects,"chairs"] call ALIVE_fnc_hashGet;
                        _electronics = [_taskObjects,"electronics"] call ALIVE_fnc_hashGet;
                        _documents = [_taskObjects,"documents"] call ALIVE_fnc_hashGet;

                        _tableClass = _tables call BIS_fnc_selectRandom;
                        _electronicClass = _electronics call BIS_fnc_selectRandom;
                        _documentClass = _documents call BIS_fnc_selectRandom;

                        _table = _tableClass createVehicle _taskPosition;
                        _table setdir 0;

                        _electronic = [_table,_electronicClass] call ALIVE_fnc_taskSpawnOnTopOf;
                        _document = [_table,_documentClass] call ALIVE_fnc_taskSpawnOnTopOf;

                        // create the profiles

                        private["_units","_HVTProfile1","_HVTProfile1ID","_HVTProfile2","_HVTProfile1ID","_HVTProfile2ID","_HVTGroup","_HVT","_HVTGroup2","_HVT2","_HVT1Active","_HVT2Active"];

                        _units = [[_taskEnemyFaction],1,ALiVE_MIL_CQB_UNITBLACKLIST,true] call ALiVE_fnc_chooseRandomUnits;

                        _HVTProfile1 = [_units,_taskEnemySide,_taskEnemyFaction,_taskPosition,random(360),_taskEnemyFaction,true] call ALIVE_fnc_createProfileEntity;
                        _HVTProfile1ID = _HVTProfile1 select 2 select 4;

                        _units = [[_taskEnemyFaction],1,ALiVE_MIL_CQB_UNITBLACKLIST,true] call ALiVE_fnc_chooseRandomUnits;

                        _HVTProfile2 = [_units,_taskEnemySide,_taskEnemyFaction,_taskPosition,random(360),_taskEnemyFaction,true] call ALIVE_fnc_createProfileEntity;
                        _HVTProfile2ID = _HVTProfile2 select 2 select 4;

                        waitUntil {
                            sleep 1;
                            _HVT1Active = _HVTProfile1 select 2 select 1;
                            _HVT2Active = _HVTProfile2 select 2 select 1;

                            (_HVT1Active && _HVT2Active)
                        };

                        _HVTGroup = _HVTProfile1 select 2 select 13;
                        _HVT = leader _HVTGroup;
                        _HVT setformdir 0;
                        _HVT setpos [getpos _table select 0,(getpos _table select 1)-2,0];

                        _HVTGroup2 = _HVTProfile2 select 2 select 13;
                        _HVT2 = leader _HVTGroup2;
                        _HVT2 setformdir 180;
                        _HVT2 setpos [getpos _table select 0,(getpos _table select 1)+2,0];

                        // store the data on the params

                        [_params,"HVTSpawned",true] call ALIVE_fnc_hashSet;
                        [_params,"entityProfileIDs",[_HVTProfile1ID,_HVTProfile2ID]] call ALIVE_fnc_hashSet;

                    };
                    case "insertion":{

                        private["_units","_HVTProfile1","_HVTProfile1ID","_remotePosition"];

                        _units = [[_taskEnemyFaction],1,ALiVE_MIL_CQB_UNITBLACKLIST,true] call ALiVE_fnc_chooseRandomUnits;

                        _remotePosition = [_taskPosition, 2000, 1, true] call ALIVE_fnc_getPositionDistancePlayers;

                        _HVTProfile1 = [_units,_taskEnemySide,_taskEnemyFaction,_remotePosition,random(360),_taskEnemyFaction,true] call ALIVE_fnc_createProfileEntity;
                        _HVTProfile1ID = _HVTProfile1 select 2 select 4;

                        [_remotePosition,_taskPosition,_taskEnemySide,_taskEnemyFaction,_HVTProfile1] call ALIVE_fnc_taskCreateVehicleInsertionForUnits;

                        [_params,"HVTSpawned",true] call ALIVE_fnc_hashSet;
                        [_params,"entityProfileIDs",[_HVTProfile1ID]] call ALIVE_fnc_hashSet;

                    };
                    case "extraction":{

                        private["_units","_HVTProfile1","_HVTProfile1ID","_remotePosition","_extractionPosition"];

                        _units = [[_taskEnemyFaction],1,ALiVE_MIL_CQB_UNITBLACKLIST,true] call ALiVE_fnc_chooseRandomUnits;

                        _remotePosition = [_taskPosition, 2000, 1, true] call ALIVE_fnc_getPositionDistancePlayers;
                        _extractionPosition = [_taskPosition, 4000, 1, true] call ALIVE_fnc_getPositionDistancePlayers;

                        _HVTProfile1 = [_units,_taskEnemySide,_taskEnemyFaction,_taskPosition,random(360),_taskEnemyFaction,true] call ALIVE_fnc_createProfileEntity;
                        _HVTProfile1ID = _HVTProfile1 select 2 select 4;

                        [_remotePosition,_taskPosition,_extractionPosition,_taskEnemySide,_taskEnemyFaction,_HVTProfile1] call ALIVE_fnc_taskCreateVehicleExtractionForUnits;

                        [_params,"HVTSpawned",true] call ALIVE_fnc_hashSet;
                        [_params,"entityProfileIDs",[_HVTProfile1ID]] call ALIVE_fnc_hashSet;

                    };
                };

            };
        }else{

            private["_entityProfiles","_entitiesState","_allDestroyed"];

            _entityProfiles = [_params,"entityProfileIDs"] call ALIVE_fnc_hashGet;

            _entitiesState = [_entityProfiles] call ALIVE_fnc_taskGetStateOfEntityProfiles;
            _allDestroyed = [_entitiesState,"allDestroyed"] call ALIVE_fnc_hashGet;

            if(_allDestroyed) then {

                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Succeeded"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

            }else{

                private["_taskEnemyFaction","_taskEnemySide","_profiles","_position","_profile","_active","_inCargo","_group","_cargoProfileID","_cargoProfile","_position","_distance"];

                _taskEnemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
                _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;

                _profiles = [_entitiesState,"profiles"] call ALIVE_fnc_hashGet;

                {

                    _profile = _x;

                    _active = _profile select 2 select 1;
                    _inCargo = _profile select 2 select 9;

                    if(_active) then {

                        _group = _profile select 2 select 13;
                        _position = getPos leader _group;
                        [_position,_taskEnemySide,_taskPlayers,_taskID,"HVT"] call ALIVE_fnc_taskCreateMarkersForPlayers;

                    }else{

                        if(count _inCargo > 0) then {
                            {
                                _cargoProfileID = _x;
                                _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                                if!(isNil "_cargoProfile") then {
                                    _position = _cargoProfile select 2 select 2;
                                    [_position,_taskEnemySide,_taskPlayers,_taskID,"HVT"] call ALIVE_fnc_taskCreateMarkersForPlayers;

                                    if(_HVTSpawnType == "extraction") then {
                                        _distance = [_position,_taskPlayers] call ALIVE_fnc_taskGetClosestPlayerDistanceToDestination;

                                        if(_distance > 2000) then {

                                            [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                                            _task set [8,"Failed"];
                                            _task set [10, "N"];
                                            _result = _task;

                                            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                                            ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                                        };
                                    };
                                };

                            } forEach _inCargo;
                        }else{

                            _position = _x select 2 select 2;
                            [_position,_taskEnemySide,_taskPlayers,_taskID,"HVT"] call ALIVE_fnc_taskCreateMarkersForPlayers;

                            if(_HVTSpawnType == "extraction") then {
                                _distance = [_position,_taskPlayers] call ALIVE_fnc_taskGetClosestPlayerDistanceToDestination;

                                if(_distance > 2000) then {

                                    [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                                    _task set [8,"Failed"];
                                    _task set [10, "N"];
                                    _result = _task;

                                    [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                                    ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                                };
                            };

                        };
                    };

                } forEach _profiles;

            }

        };

    };
};

_result