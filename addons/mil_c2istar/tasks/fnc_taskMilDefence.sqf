#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskMilDefence);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskMilDefence

Description:
Defence Task

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

	    private["_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskEnemyFaction","_taskCurrent",
	    "_taskApplyType","_taskEnemySide","_enemyClusters","_targetPosition","_taskPlayers"];

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

        if (_taskID == "") exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task Mil Defence - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        // establish the location for the task
        // get friendly occupied cluster position

        _targetPosition = [_taskLocation,_taskLocationType,_taskSide,"MIL"] call ALIVE_fnc_taskGetSideCluster;

        if(count _targetPosition == 0 || {_taskLocationType == "Map" && {_targetPosition distance _taskLocation > 1000}}) then {
            // no friendly occupied cluster found
            // try to get a position containing friendlies
            _targetPosition = [_taskLocation,_taskLocationType,_taskSide] call ALIVE_fnc_taskGetSideSectorCompositionPosition;
            
			// use selected map location or default player position
            if (count _targetPosition == 0) then {            
		        _targetPosition = [
					_targetPosition, 
					500, 
					1500,
					1, 
					0, 
					100,
					0, 
					[], 
					[_targetPosition]
				] call BIS_fnc_findSafePos;
            };

            // spawn a populated composition
            _targetPosition = [_targetPosition, 250] call ALIVE_fnc_findFlatArea;
            [_targetPosition, "objectives", _taskFaction, 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
        };

        if!(isNil "_targetPosition") then {

            private["_stagingPosition","_dialogOptions","_dialogOption"];

            // select the random text

            _dialogOptions = [ALIVE_generatedTasks,"MilDefence"] call ALIVE_fnc_hashGet;
            _dialogOptions = _dialogOptions select 1;
            _dialogOption = _dialogOptions call BIS_fnc_selectRandom;

            // format the dialog options

            private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

            _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Travel"] call ALIVE_fnc_hashGet;

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

            private["_state","_tasks","_taskIDs","_dialog","_taskTitle","_taskDescription","_newTask","_newTaskID","_taskParams","_taskSource"];

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
            _taskSource = format["%1-MilDefence-Parent",_taskID];
            _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_taskID];

            // create the travel task

            _dialog = [_dialogOption,"Travel"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c1",_taskID];
            _taskSource = format["%1-MilDefence-Travel",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,false];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_newTaskID];

            // create the defend task

            _dialog = [_dialogOption,"DefenceWave"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c2",_taskID];
            _taskSource = format["%1-MilDefence-DefenceWave",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,"N",_taskID,_taskSource,true];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_newTaskID];

            // store task data in the params for this task set

            _taskParams = [] call ALIVE_fnc_hashCreate;
            [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
            [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
            [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
            [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
            [_taskParams,"missileStrikeCreated",false] call ALIVE_fnc_hashSet;
            [_taskParams,"atmosphereCreated",false] call ALIVE_fnc_hashSet;
            [_taskParams,"currentWave",1] call ALIVE_fnc_hashSet;
            [_taskParams,"lastWave",0] call ALIVE_fnc_hashSet;
            [_taskParams,"totalWaves",1 + floor(random 5)] call ALIVE_fnc_hashSet;
            [_taskParams,"entityProfileIDs",[]] call ALIVE_fnc_hashSet;
            [_taskParams,"cleanupObjects",[]] call ALIVE_fnc_hashSet;
            [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;

            // return the created tasks and params

            _result = [_tasks,_taskParams];

        };

	};
	case "Parent":{

    };
	case "Travel":{

	    private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
	    "_destinationReached","_taskIDs","_lastState","_taskDialog","_currentTaskDialog"];

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

        if(_lastState != "Travel") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Travel"] call ALIVE_fnc_hashSet;
        };

        _destinationReached = [_taskPosition,_taskPlayers,50] call ALIVE_fnc_taskHavePlayersReachedDestination;

        if(_destinationReached) then {

            _taskIDs = [_params,"taskIDs"] call ALIVE_fnc_hashGet;
            [_params,"nextTask",_taskIDs select 2] call ALIVE_fnc_hashSet;

            _task set [8,"Succeeded"];
            _task set [10, "N"];
            _result = _task;

        };

    };
    case "DefenceWave":{

        private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
        "_areaClear","_lastState","_taskDialog","_missileStrikeCreated","_atmosphereCreated","_currentTaskDialog","_taskEnemyFaction",
        "_taskEnemySide","_currentWave","_lastWave","_totalWaves","_enemyFaction","_entityProfileIDs","_cleanupObjects"];

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
        _missileStrikeCreated = [_params,"missileStrikeCreated"] call ALIVE_fnc_hashGet;
        _atmosphereCreated = [_params,"atmosphereCreated"] call ALIVE_fnc_hashGet;
        _currentWave = [_params,"currentWave"] call ALIVE_fnc_hashGet;
        _lastWave = [_params,"lastWave"] call ALIVE_fnc_hashGet;
        _totalWaves = [_params,"totalWaves"] call ALIVE_fnc_hashGet;
        _enemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
        _entityProfileIDs = [_params,"entityProfileIDs"] call ALIVE_fnc_hashGet;
        _cleanupObjects = [_params,"cleanupObjects"] call ALIVE_fnc_hashGet;

        if(_lastState != "DefenceWave") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","DefenceWave"] call ALIVE_fnc_hashSet;
        };

        if(_currentWave > _lastWave) then {

            private["_groupCount","_remotePosition","_groups","_group","_remotePosition","_position","_profiles","_profileWaypoint","_diceRoll",
            "_profileIDs","_profileID"];

            //["CREATING WAVE: %1",_currentWave] call ALIVE_fnc_dump;

            _groupCount = _currentWave * floor(1 + random 2);
            _profileIDs = [];
            _groups = [];

            for "_i" from 0 to _groupCount -1 do {
                _group = ["Infantry",_enemyFaction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups set [count _groups, _group];
                }
            };

            _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

            //["INF GROUPS: %1",_groups] call ALIVE_fnc_dump;

            _remotePosition = [_taskPosition, 500, 5, true] call ALIVE_fnc_getPositionDistancePlayers;
            _remotePosition = _remotePosition call BIS_fnc_selectRandom;

            {
                _position = [_remotePosition, (random(200)), random(200)] call BIS_fnc_relPos;
                _profiles = [_x, _position, random(360), true, _enemyFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
                _profileID = _profiles select 0 select 2 select 4;
                _position = [_taskPosition, (random(40)), random(40)] call BIS_fnc_relPos;
                _profileWaypoint = [_position, 100, "MOVE", "FULL", 100, [], "LINE", "NO CHANGE", "CARELESS"] call ALIVE_fnc_createProfileWaypoint;
                [(_profiles select 0), "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                _profileIDs set [count _profileIDs, _profileID];

            } forEach _groups;

            _diceRoll = random 1;

            if(_diceRoll > 0.5) then {

                private["_vehicleGroupTypes","_vehicleGroup"];

                _groups = [];

                _vehicleGroupTypes = ["Armored","Mechanized","Motorized"];
                _vehicleGroup = _vehicleGroupTypes call BIS_fnc_selectRandom;

                _group = [_vehicleGroup,_enemyFaction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                     _groups set [count _groups, _group];
                };

                _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

                //["VEH GROUPS: %1",_groups] call ALIVE_fnc_dump;

                {
                    _position = [_remotePosition, (random(200)), random(200)] call BIS_fnc_relPos;
                    _profiles = [_x, _position, random(360), true, _enemyFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
                    _profileID = _profiles select 0 select 2 select 4;
                    _position = [_taskPosition, (random(40)), random(40)] call BIS_fnc_relPos;
                    _profileWaypoint = [_position, 100, "MOVE", "FULL", 100, [], "LINE", "NO CHANGE", "CARELESS"] call ALIVE_fnc_createProfileWaypoint;
                    [(_profiles select 0), "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                    _profileIDs set [count _profileIDs, _profileID];

                } forEach _groups;
            };

            //["PROFILE IDS: %1",_profileIDs] call ALIVE_fnc_dump;

            [_params,"entityProfileIDs",_profileIDs] call ALIVE_fnc_hashSet;
            [_params,"lastWave",(_lastWave+1)] call ALIVE_fnc_hashSet;

        }else{

            private["_entitiesState","_allDestroyed","_areaClear"];

            _entitiesState = [_entityProfileIDs] call ALIVE_fnc_taskGetStateOfEntityProfiles;
            _allDestroyed = [_entitiesState,"allDestroyed"] call ALIVE_fnc_hashGet;

            //["FIGHTING WAVE : %1",_currentWave] call ALIVE_fnc_dump;

            if(_allDestroyed) then {

                if(_currentWave < _totalWaves) then {
                    [_params,"currentWave",(_currentWave+1)] call ALIVE_fnc_hashSet;
                }else{

                    _areaClear = [_taskPosition,_taskPlayers,_taskSide,200] call ALIVE_fnc_taskIsAreaClearOfEnemies;

                    if(_areaClear) then {

                        {
                            deleteVehicle _x;
                        } forEach _cleanupObjects;

                        [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                        _task set [8,"Succeeded"];
                        _task set [10, "N"];
                        _result = _task;

                        [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                        ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                        [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

                    };

                };

            }else{

                private["_entities","_entityCount","_totalDistance","_position","_distance","_averageDistance","_diceRoll","_object","_env","_dayState"];

                _entities = [_entitiesState,"profiles"] call ALIVE_fnc_hashGet;
                _entityCount = count _entities;
                _totalDistance = 0;

                {
                    _position = _x select 2 select 2;
                    _distance = _position distance _taskPosition;
                    _totalDistance = _totalDistance + _distance;
                } forEach _entities;

                _averageDistance = floor(_totalDistance / _entityCount);

                if(_averageDistance > 500) then {

                    if!(_missileStrikeCreated) then {

                        _diceRoll = random 1;

                        if(_diceRoll > 0.95) then {

                            ["chat_missile_strike",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                            sleep 10;

                            [_params,"missileStrikeCreated",true] call ALIVE_fnc_hashSet;

                            _position = [_taskPosition, (random(300)), random(300)] call BIS_fnc_relPos;

                            _object = "Sign_Sphere100cm_F" createVehicle _position;
                            _object setPos _position;
                            _object hideObjectGlobal true;

                            _cleanupObjects = _cleanupObjects + [_object];
                            [_params,"cleanupObjects",_cleanupObjects] call ALIVE_fnc_hashSet;

                            [_object,"MISSILE_STRIKE_SMALL",floor(2+(random 10)),floor(30+(random 50)),true,10] call ALIVE_fnc_taskCreateBombardment;

                        };

                    };

                }else{

                    if!(_atmosphereCreated) then {

                        _diceRoll = random 1;

                        if(_diceRoll > 0.9) then {

                            [_params,"atmosphereCreated",true] call ALIVE_fnc_hashSet;

                            _object = "Sign_Sphere100cm_F" createVehicle _position;
                            _object setPos _taskPosition;
                            _object hideObjectGlobal true;

                            _cleanupObjects = _cleanupObjects + [_object];
                            [_params,"cleanupObjects",_cleanupObjects] call ALIVE_fnc_hashSet;

                            _env = call ALIVE_fnc_getEnvironment;
                            _dayState = _env select 0;

                            switch(_dayState) do {
                                case "DAY":{
                                    [_object,"SMOKE_SMALL",floor(2+(random 10)),floor(30+(random 50)),true,30] call ALIVE_fnc_taskCreateBombardment;
                                };
                                case "EVENING":{
                                    [_object,"FLARE_LARGE",floor(2+(random 10)),floor(30+(random 50)),true,30] call ALIVE_fnc_taskCreateBombardment;
                                };
                                case "NIGHT":{
                                    [_object,"FLARE_LARGE",floor(2+(random 10)),floor(30+(random 50)),true,30] call ALIVE_fnc_taskCreateBombardment;
                                };
                            };

                        };

                    };

                };

            };

        };

    };
};

_result