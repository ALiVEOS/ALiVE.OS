#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskRescue);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskRescue

Description:
Hostage Rescue Task

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
Tupolov
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

        private [
            "_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskPlayers","_taskEnemyFaction","_taskCurrent",
            "_taskApplyType","_tasksCurrent","_taskEnemySide","_enemyClusters","_targetPosition","_returnPosition"
        ];

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

        if (_taskID == "") exitwith {["C2ISTAR - Task Rescue - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task Rescue - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task Rescue - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task Rescue - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task Rescue - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task Rescue - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task Rescue - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task Rescue - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        // establish the location for the task
        // get enemy occupied cluster position

        if (_taskLocationType in ["Short","Medium","Long"]) then {

            if (!isnil "OPCOM_instances") then {

                //["Selecting Task location from OPCOMs"] call ALiVE_fnc_DumpR;
                private _triggerStates = ["defend","defending","reserve","reserving","idle","unassigned"];
                private _objectives = [];
                {
                    private _OPCOM = _x;
                    private _OPCOM_factions = [_OPCOM,"factions",""] call ALiVE_fnc_HashGet;
                    private _OPCOM_side = [_OPCOM,"side",""] call ALiVE_fnc_HashGet;

                    //["Looking up correct OPCOM %1 for faction %2",_OPCOM_factions,_taskEnemyFaction] call ALiVE_fnc_DumpR;
                    if ({_x == _taskEnemyFaction} count _OPCOM_factions > 0) then {
                        private _OPCOM_objectives = [_OPCOM,"objectives",[]] call ALiVE_fnc_HashGet;

                        //["Looking up correct ones in %1 objectives for faction %2",count _OPCOM_objectives,_taskEnemyFaction] call ALiVE_fnc_DumpR;
                        {
                            private _OPCOM_objective = _x;
                            private _OPCOM_objective_state = [_OPCOM_objective,"opcom_state",""] call ALiVE_fnc_HashGet;
                            private _OPCOM_objective_center = [_OPCOM_objective,"center",[0,0,0]] call ALiVE_fnc_HashGet;

                            //["Matching state %1 in triggerstates %2 tasks %3 faction %4!",_OPCOM_objective_state,_triggerStates,_tasksCurrent,_taskFaction] call ALiVE_fnc_DumpR;
                                if (
                                    _OPCOM_objective_state in _triggerStates &&
                                    {(({(_x select 4) == _taskFaction && {(_x select 3) distance _OPCOM_objective_center < 500}} count _tasksCurrent) == 0)}
                            ) then {
                                    _objectives pushback _OPCOM_objective;
                            };
                        } foreach _OPCOM_objectives;
                    };
                } foreach OPCOM_instances;

                if (count _objectives > 0) then {
                    private _objectives = [_objectives,[_taskLocation],{_Input0 distance ([_x,"center"] call ALiVE_fnc_HashGet)},"ASCEND",{

                        private _id = [_x,"opcomID",""] call ALiVE_fnc_HashGet;
                        private _pos = [_x,"center"] call ALiVE_fnc_HashGet;
                        private _opcom = [objNull,"getOPCOMbyid",_id] call ALiVE_fnc_OPCOM;
                        private _side = [_opcom,"side",""] call ALiVE_fnc_HashGet;

                        !([_pos,_side,500,true] call ALiVE_fnc_isEnemyNear) && {_pos distance _Input0 > 1200};
                    }] call ALiVE_fnc_SortBy;

                    _targetPosition = [_objectives select 0,"center"] call ALiVE_fnc_HashGet;

                    _targetPosition = [_targetPosition,500] call ALiVE_fnc_findFlatArea;

                    //[_targetPosition, "camps", _taskEnemyFaction, 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
                    private ["_category","_compType"];
                    _compType = "Military";
                    If (_taskEnemySide == "GUER") then {
                        _compType = "Guerrilla";
                        _category = ["HQ", "Outposts", "FieldHQ", "Camps","Supports","Communications"];
                    } else {
                        _category = ["Outposts", "FieldHQ", "Camps","Supports","Heliports","Communications"];
                    };
                    [_targetPosition, _compType, _category, _taskEnemyFaction, ["Medium","Small"], 2] call ALIVE_fnc_spawnRandomPopulatedComposition;

                };
            } else {
                _targetPosition = [_taskLocation,500] call ALiVE_fnc_findFlatArea;
            };
        } else {
            _targetPosition = _taskLocation;

            private ["_category","_compType"];
            _compType = "Military";
            If (_taskEnemySide == "GUER") then {
                _compType = "Guerrilla";
                _category = ["HQ", "Outposts", "FieldHQ", "Camps","Supports","Communications"];
            } else {
                _category = ["Outposts", "FieldHQ", "Camps","Supports","Heliports","Communications"];
            };
            [_targetPosition, _compType, _category, _taskEnemyFaction, ["Medium","Small"], 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
        };

        // establish the location for the return task
        // get friendly cluster
        _returnPosition = [_taskLocation,_taskLocationType,_taskSide] call ALIVE_fnc_taskGetSideCluster;

        if(count _returnPosition == 0) then {
            private ["_category","_compType"];
            // no enemy occupied cluster found
            // try to get a position containing enemy
            _returnPosition = [_taskLocation,_taskLocationType,_taskSide] call ALIVE_fnc_taskGetSideSectorCompositionPosition;

            // spawn a populated composition
            if (count _returnPosition == 0) then {
                _returnPosition = [
                    _taskLocation,
                    50,
                    1500,
                    1,
                    0,
                    0.25,
                    0,
                    [],
                    [_taskLocation]
                ] call BIS_fnc_findSafePos;
            };

            _returnPosition = [_returnPosition, 250] call ALIVE_fnc_findFlatArea;

            _compType = "Military";
            If (_taskFaction call ALiVE_fnc_factionSide == RESISTANCE) then {
                _compType = "Guerrilla";
                _category = ["HQ", "Outposts", "FieldHQ", "Camps","Supports","Communications"];
            } else {
                _category = ["Outposts", "FieldHQ", "Camps","Supports","Heliports","Communications"];
            };
            [_returnPosition, _compType, _category, _taskFaction, ["Medium","Small"], 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
        };

        if!(isNil "_targetPosition" || isNil "_returnPosition") then {

            private["_dialogOptions","_dialogOption"];

            // select the random text

            _dialogOptions = [ALIVE_generatedTasks,"Rescue"] call ALIVE_fnc_hashGet;
            _dialogOptions = _dialogOptions select 1;
            _dialogOption = +(selectRandom _dialogOptions);

            // format the dialog options

            private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

            // Rescue
            _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Rescue"] call ALIVE_fnc_hashGet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_nearestTown];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
            _formatMessage = _formatChat select 0;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText,_nearestTown];
            _formatMessage set [1,_formatMessageText];
            _formatChat set [0,_formatMessage];
            [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashSet;


            // Return
            _nearestTown = [_returnPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Return"] call ALIVE_fnc_hashGet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_nearestTown];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
            _formatMessage = _formatChat select 0;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText,_nearestTown];
            _formatMessage set [1,_formatMessageText];
            _formatChat set [0,_formatMessage];
            [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashSet;

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
            _taskSource = format["%1-Rescue-Parent",_taskID];
            _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

            _tasks pushback _newTask;
            _taskIDs pushback _taskID;

            // create the rescue task
            _dialog = [_dialogOption,"Rescue"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c1",_taskID];
            _taskSource = format["%1-Rescue-Rescue",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

            _tasks pushback _newTask;
            _taskIDs pushback _newTaskID;

            // create the return task
            _dialog = [_dialogOption,"Return"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c2",_taskID];
            _taskSource = format["%1-Rescue-Return",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_returnPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,"N",_taskID,_taskSource,true];

            _tasks pushback _newTask;
            _taskIDs pushback _newTaskID;

            // select the type of hostage spawn

            private["_spawnTypes","_spawnType","_hostageAnims","_unboundAnims","_boundAnims"];

            _spawnTypes = ["static"];
            _spawnType = (selectRandom _spawnTypes);

            _boundAnims = [
                [
                    "Acts_AidlPsitMstpSsurWnonDnon01",
                    "Acts_AidlPsitMstpSsurWnonDnon02",
                    "Acts_AidlPsitMstpSsurWnonDnon03",
                    "Acts_AidlPsitMstpSsurWnonDnon04",
                    "Acts_AidlPsitMstpSsurWnonDnon05"
                ],
                [
                    "Acts_CivilShocked_1",
                    "Acts_CivilShocked_2"
                ],
                [
                    "Acts_ExecutionVictim_Loop"
                ]
            ];
            _unboundAnims = [
                [
                    "Acts_AidlPsitMstpSsurWnonDnon_out"
                ],
                [
                    ""
                ],
                [
                    "Acts_ExecutionVictim_Unbow"
                ]
            ];

            _hostageAnims = [] call ALIVE_fnc_hashCreate;
            [_hostageAnims, "boundAnims", _boundAnims] call ALiVE_fnc_hashSet;
            [_hostageAnims, "unboundAnims", _unboundAnims] call ALiVE_fnc_hashSet;
            [_hostageAnims, "index", ceil (random (count _boundAnims) -1)] call ALiVE_fnc_hashSet;

            // store task data in the params for this task set

            _taskParams = [] call ALIVE_fnc_hashCreate;
            [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
            [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
            [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
            [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;
            [_taskParams,"hostageSpawned",false] call ALIVE_fnc_hashSet;
            [_taskParams,"hostageSpawnType",_spawnType] call ALIVE_fnc_hashSet;
            [_taskParams,"returnReached",false] call ALIVE_fnc_hashSet;
            [_taskParams,"hostageAnims",_hostageAnims] call ALIVE_fnc_hashSet;
            [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
            [_taskParams,"targetPosition",_targetPosition] call ALIVE_fnc_hashSet;
            // return the created tasks and params

            _result = [_tasks,_taskParams];

        };

    };
    case "Parent":{

    };
    case "Rescue":{

        private [
            "_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
            "_destinationReached","_taskIDs","_hostageSpawned","_hostageSpawnType","_lastState","_taskDialog","_currentTaskDialog",
            "_hostageAnims","_startTime","_activeFirst","_anims","_targetPosition"
        ];

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
        _hostageSpawned = [_params,"hostageSpawned"] call ALIVE_fnc_hashGet;
        _hostageSpawnType = [_params,"hostageSpawnType"] call ALIVE_fnc_hashGet;
        _hostageAnims = [_taskParams,"hostageAnims"] call ALIVE_fnc_hashGet;
        _startTime = [_params,"startTime"] call ALIVE_fnc_hashGet;
        _activeFirst = [_params,"activeFirst",false] call ALIVE_fnc_hashGet;
        _targetPosition = [_params,"targetPosition"] call ALIVE_fnc_hashGet;

        if(_lastState != "Rescue") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Rescue"] call ALIVE_fnc_hashSet;
        };

        if!(_hostageSpawned) then {

            _destinationReached = [_taskPosition,_taskPlayers,1000] call ALIVE_fnc_taskHavePlayersReachedDestination;

            if(_destinationReached) then {

                // spawn the hostage

                switch(_hostageSpawnType) do {
                    case "static":{

                        private["_taskObjects","_tables","_chairs","_electronics","_documents","_tableClass","_electronicClass",
                        "_documentClass","_table","_electronic","_document","_anims","_tablePosition"];


                        // spawn some objects

                        _taskObjects = ALIVE_taskObjects;
                        _tables = [_taskObjects,"tables"] call ALIVE_fnc_hashGet;
                        _chairs = [_taskObjects,"chairs"] call ALIVE_fnc_hashGet;
                        _electronics = [_taskObjects,"electronics"] call ALIVE_fnc_hashGet;
                        _documents = [_taskObjects,"documents"] call ALIVE_fnc_hashGet;

                        _tableClass = (selectRandom _tables);
                        private _chairClass = (selectRandom _chairs);
                        _electronicClass = (selectRandom _electronics);
                        _documentClass = (selectRandom _documents);

                        // see if a building is nearby, if so change the targetposition
                        private _bldgPos = [_targetPosition, 50] call ALiVE_fnc_findIndoorHousePositions;
                        if (count _bldgPos > 0) then {
                            _targetPosition = (selectRandom _bldgPos);
                            _tablePosition = (selectRandom _bldgPos);
                            _table = createVehicle [_tableClass,_tablePosition,[],0.5,"NONE"];
                        } else {
                            _table = createVehicle [_tableClass,_targetPosition,[],4,"NONE"];
                        };


                        _table setdir 0;
                        private _chair = createVehicle [_chairClass,position _table,[],3,"NONE"];

                        _electronic = [_table,_electronicClass] call ALIVE_fnc_taskSpawnOnTopOf;
                        _document = [_table,_documentClass] call ALIVE_fnc_taskSpawnOnTopOf;

                        // create the profiles

                        private["_units","_hostageProfile1","_hostageProfile1ID","_hostageGroup","_hostage","_hostage1Active"];

                        _units = [[_taskFaction],1,ALiVE_MIL_CQB_UNITBLACKLIST,true] call ALiVE_fnc_chooseRandomUnits;

                        _hostageProfile1 = [_units,_taskSide,_taskFaction, _targetPosition,random(360),_taskFaction,true] call ALIVE_fnc_createProfileEntity;
                        _hostageProfile1ID = _hostageProfile1 select 2 select 4;

                        waitUntil {
                            sleep 1;
                            _hostage1Active = _hostageProfile1 select 2 select 1;
                            (_hostage1Active)
                        };

                        _hostageGroup = _hostageProfile1 select 2 select 13;
                        _hostage = leader _hostageGroup;
                        _hostage setCaptive true;
                        removeAllWeapons _hostage;
                        removeAllItems _hostage;
                        removeBackpack _hostage;
                        removeGoggles _hostage;
                        removeHeadgear _hostage;
                        removeVest _hostage;
                        removeAllAssignedItems _hostage;
                        if ((random 1) > 0.6) then {
                            _hostage setDamage (random 0.4);
                        };
                        _hostage setformdir 0;
                        _hostage setpos [getpos _table select 0,(getpos _table select 1)-2,0];
                        _hostage disableAI "MOVE";

                        // Hostage Anim
                        _anims = ([_hostageAnims, "boundAnims"] call ALIVE_fnc_hashGet) select ([_hostageAnims, "index"] call ALiVE_fnc_hashGet);
                        _hostage switchMove (selectRandom _anims);

                        [_hostage, format ["Rescue %1",name _hostage], "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa","\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa","_this distance _target < 2", "_caller distance _target < 2", {}, {}, {_target setVariable ["rescued",true,true]; ["Rescue", format ["You have rescued %1!",name _target]] call BIS_fnc_showSubtitle;},{},[],8] remoteExec ["BIS_fnc_holdActionAdd",0, true];

                        // Chat update
                        private _formatChat = [_currentTaskDialog,"chat_update"] call ALIVE_fnc_hashGet;
                        private _formatMessage = _formatChat select 0;
                        private _formatMessageText = _formatMessage select 1;
                        _formatMessageText = format[_formatMessageText, name _hostage, mapGridPosition _hostage];
                        _formatMessage set [1,_formatMessageText];
                        _formatChat set [0,_formatMessage];
                        [_currentTaskDialog,"chat_update",_formatChat] call ALIVE_fnc_hashGet;

                        ["chat_update",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                        [position _hostage,_taskSide,_taskPlayers,_taskID,"hostage"] call ALIVE_fnc_taskCreateMarkersForPlayers;

                        // store the data on the params
                        [_params, "startTime", time] call ALIVE_fnc_hashSet;
                        [_params, "hostageSpawned",true] call ALIVE_fnc_hashSet;
                        [_params, "entityProfileIDs",[_hostageProfile1ID]] call ALIVE_fnc_hashSet;

                    };
                };

            };
        } else {

            private["_entityProfiles","_entitiesState","_dead"];

            _entityProfiles = [_params,"entityProfileIDs"] call ALIVE_fnc_hashGet;

            _entitiesState = [_entityProfiles] call ALIVE_fnc_taskGetStateOfEntityProfiles;
            _dead = [_entitiesState,"allDestroyed"] call ALIVE_fnc_hashGet;

            if (_dead || time > _startTime + 3300) then {

                // Next Task will be empty so a new one gets created
                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                // Mission Over in first state - if dead or timeout update the parent-task instead of the child so all children get updated
                _parent = _task select 11;
                _parent = if (_parent == "None") then {_taskID} else {_parent};
                _parentTask = [ALiVE_TaskHandler,"getTask",_parent] call ALiVE_fnc_TaskHandler;

                _parentTask set [8,"Failed"];
                _parentTask set [10,"N"];

                [ALiVE_TaskHandler,"TASK_UPDATE",_parentTask] call ALiVE_fnc_TaskHandler;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            }else{

                private["_profiles","_position","_profile","_active","_group","_distance","_formatChat","_formatMessage","_formatMessageText"];

                _profiles = [_entitiesState,"profiles"] call ALIVE_fnc_hashGet;

                {
                    _profile = _x;

                    _active = _profile select 2 select 1;

                    if(_active) then {
                        private "_hostage";

                        _group = _profile select 2 select 13;

                        _hostage = leader _group;
                        _position = getPos _hostage;

                        // [position _hostage,_taskSide,_taskPlayers,_taskID,"hostage"] call ALIVE_fnc_taskCreateMarkersForPlayers;
                        // _distance = [_position,_taskPlayers] call ALIVE_fnc_taskGetClosestPlayerDistanceToDestination;

                        if (_hostage getVariable ["rescued",false]) then {

							// Get closest player
							private _saverGroup = group ([_position,_taskPlayers] call ALIVE_fnc_taskGetClosestPlayerToPosition);

                            // End Hostage Anim
                            _anims = ([_hostageAnims, "unboundAnims"] call ALIVE_fnc_hashGet) select ([_hostageAnims, "index"] call ALiVE_fnc_hashGet);
                            _hostage playMove (selectRandom _anims);
                            sleep 5;

							// Reset
                            _hostage enableAI "MOVE";
                            _hostage setCaptive false;
                            _hostage switchmove "";

                            sleep 1;

                            // Join player group
							private _prevLeader = leader _saverGroup;
                            [_hostage] joinSilent _saverGroup;
							[_saverGroup, _prevLeader] remoteExecCall ["selectLeader", groupOwner _saverGroup];

                            _taskIDs = [_params,"taskIDs"] call ALIVE_fnc_hashGet;
                            [_params,"nextTask",_taskIDs select 2] call ALIVE_fnc_hashSet;

                            _task set [8,"Succeeded"];
                            _task set [10, "N"];
                            _result = _task;

                            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                            ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                            [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;
                        };
                    };

                } forEach _profiles;

            };

        };
    };

    case "Return":{

        private [
            "_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
            "_areaClear","_lastState","_taskDialog","_destinationReached","_currentTaskDialog","_startTime","_returnReached"
        ];

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
        _returnReached = [_params,"returnReached"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;
        _startTime = [_params,"startTime"] call ALIVE_fnc_hashGet;

        // first run of this task
        if(_lastState != "Return") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Return"] call ALIVE_fnc_hashSet;
        };

        // the players have not yet reached the
        // insertion location
        if!(_returnReached) then {

            private["_entityProfiles","_entitiesState","_dead","_profiles","_destinationReached"];

            _entityProfiles = [_params,"entityProfileIDs"] call ALIVE_fnc_hashGet;

            _entitiesState = [_entityProfiles] call ALIVE_fnc_taskGetStateOfEntityProfiles;
            _dead = [_entitiesState,"allDestroyed"] call ALIVE_fnc_hashGet;

            if (_dead) then {

                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Failed"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            }else{

                _destinationReached = [_taskPosition, _taskPlayers, 40] call ALIVE_fnc_taskHavePlayersReachedDestination;

                // the players are at the return point
                if(_destinationReached) then {

                    _profiles = [_entitiesState,"profiles"] call ALIVE_fnc_hashGet;

                    // Remove hostage(s) from group
                    {
                        private ["_profile","_active","_unit"];
                        _profile = _x;

                        _active = _profile select 2 select 1;
                        _unit = _profile select 2 select 10;

                        if(_active && {vehicle _unit == _unit && _unit distance _taskPosition < 40}) then {
                            [_unit] joinSilent grpNull;
                            [_unit, _taskPosition] call ALiVE_fnc_doMoveRemote;
                            _returnReached = true;
                            [_params,"returnReached",true] call ALIVE_fnc_hashSet;
                        };
                    } foreach _profiles;

                };

            };

        }else{

            // the players have reached the return location

            private["_entityProfiles","_entitiesState","_dead"];

            _entityProfiles = [_params,"entityProfileIDs"] call ALIVE_fnc_hashGet;

            _entitiesState = [_entityProfiles] call ALIVE_fnc_taskGetStateOfEntityProfiles;
            _dead = [_entitiesState,"allDestroyed"] call ALIVE_fnc_hashGet;

            // task is completed successfully
            if (_dead) then {

                // profile is dead

                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Failed"];
                _task set [10, "N"];
                _result = _task;

                ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            }else{


                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Succeeded"];
                _task set [10, "N"];
                _result = _task;

                ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;
            };

        };
    };
};

_result
