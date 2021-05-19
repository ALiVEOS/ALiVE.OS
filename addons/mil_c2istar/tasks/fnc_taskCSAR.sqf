#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskCSAR);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCSAR

Description:
Combat Search and Rescue Task

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
            "_taskApplyType","_tasksCurrent","_taskEnemySide","_enemyClusters","_targetPosition","_returnPosition","_aircraft","_crashsite","_category"
        ];

        _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;
        _taskFaction = _task select 3;
        _taskDesination = _task select 4;
        _taskLocationType = _task select 5;
        _taskLocation = _task select 6;
        _taskPlayers = _task select 7;
        _taskEnemyFaction = _task select 8;
        _taskCurrent = _task select 9;
        _taskApplyType = _task select 10;

        _aircraft = nil;

        private _crewID = "";

        if (count _task > 11) then {_aircraft = _task select 11};

        if (count _task > 12) then {_crewID = _task select 12};

        _tasksCurrent = ([ALiVE_TaskHandler,"tasks",["",[],[],nil]] call ALiVE_fnc_HashGet) select 2;

        if (_taskID == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        // Choose downed pilot or crashsite
        private ["_dialogOptions","_dialogOption","_choice"];

        _dialogOptions = [ALIVE_generatedTasks,"CSAR"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        _choice = round (random ((count _dialogOptions)-1));
        If (_choice == 0) then { // Downed pilot
            _crashsite = false;
        };
        if (_choice == 1) then { // Crashsite
            _crashsite = true;
        };

        // establish the location for the task
        // get enemy cluster position
		if (isNil "_taskLocation" || [_taskLocation, _taskPlayers select 0] call ALIVE_fnc_taskGetClosestPlayerDistanceToDestination < 600) then {
		    _targetPosition = [_taskLocation,_taskLocationType,_taskEnemySide] call ALIVE_fnc_taskGetSideSectorCompositionPosition;
		} else {
            _targetPosition = _taskLocation;
        };

        if(count _targetPosition == 0) then {

                _targetPosition = [
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

        _targetPosition = [_targetPosition, 250] call ALIVE_fnc_findFlatArea;

        // establish the location for the return task
        // get friendly cluster
        if (_taskLocationType == "NULL") then {_taskLocationType = "MEDIUM";};
        _returnPosition = [_taskLocation,_taskLocationType,_taskSide] call ALIVE_fnc_taskGetSideCluster;

        if(count _returnPosition == 0) then {
            // no friendly cluster found
            // try to get a position containing friendlies
            _returnPosition = [_taskLocation,_taskLocationType,_taskSide] call ALIVE_fnc_taskGetSideSectorCompositionPosition;

            if (count _returnPosition == 0) then {
                _returnPosition = [
                    _taskLocation,
                    50,
                    500,
                    1,
                    0,
                    0.25,
                    0,
                    [],
                    [_taskLocation]
                ] call BIS_fnc_findSafePos;
            };

            _returnPosition = [_returnPosition, 250] call ALIVE_fnc_findFlatArea;

            // spawn a populated composition
            private _compType = "Military";
            If (_taskFaction call ALiVE_fnc_factionSide == RESISTANCE) then {
                _compType = "Guerrilla";
                _category = ["HQ", "Outposts", "FieldHQ", "Camps","Supports","Comms"];
            } else {
                _category = ["Outposts", "FieldHQ", "Camps","Supports","Heliports","Comms"];
            };
            [_returnPosition, _compType, _category, _taskFaction, ["Medium","Small"], 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
        };

        if!(isNil "_targetPosition" || isNil "_returnPosition") then {

            // Get a faction aircraft
            if (isNil "_aircraft") then {
            	_aircraft = selectRandom ((([1,_taskFaction,"Helicopter"] call ALiVE_fnc_findVehicleType) + ([1,_taskFaction,"Plane"] call ALiVE_fnc_findVehicleType)) - ALiVE_PLACEMENT_VEHICLEBLACKLIST);
			};
            if (isNil "_aircraft") then {
                _aircraft = "C_Heli_Light_01_civil_F";
            };

            if (_crashsite) then {
                // Spawn crashsite
                private ["_site","_compType","_comp","_wreck","_pos","_dir","_vehicle","_crashsitePosition"];

                // _crashsitePosition = [_targetPosition, 1000, 60] call ALIVE_fnc_findFlatArea;

                if (surfaceIsWater _targetposition) then {
                    _targetposition = [_targetPosition] call ALiVE_fnc_getClosestLand;
                };

                // Spawn composition
                _compType = "Military";
                _site = "crashsites";

                // Get the aircraft displayname and first string before a white space and remove any dashes i.e. UH1D or F4B ugh
                private _displayName = getText(configFile >> "CfgVehicles" >> _aircraft >> "displayName");
                private _tempText = (_displayName splitString " ") select 0;
                _tempText = [_tempText, "-", ""] call CBA_fnc_replace;
                _comp = [_compType, [_site], [], _taskFaction, false, [_tempText]] call ALiVE_fnc_getCompositions;

                if (count _comp == 0) then {
                    _site = "smallAH99Crashsite1";
                    _comp = [_site, _CompType] call ALiVE_fnc_findComposition;

                    [_comp,_targetposition,random 360,_taskFaction] call ALiVE_fnc_spawnComposition;

                    // replace wreck with downed bird
                    _wreck = nearestObject [_targetposition, "Land_Wreck_Heli_Attack_01_F"];
                    _pos = getposATL _wreck;
                    _dir = getdir _wreck;
                    deleteVehicle _wreck;

                    // Spawn downed bird
                    _vehicle = createVehicle [_aircraft, _pos, [], 0, "CAN_COLLIDE"];
                    _vehicle setDir _dir;
                    _vehicle setposATL _pos;
                    _vehicle setDamage 1;
                    // ["%1 spawned at %2 with %3 damage", _aircraft, _pos, damage _vehicle] call ALiVE_fnc_dump;
                } else {
                    [_comp select 0,_targetposition,random 360,_taskFaction] call ALiVE_fnc_spawnComposition;
                };
            } else {
                // Spawn parachute on ground

            };

            // Assign or create the crew profile
            private["_units","_crewProfile1"];

            _units = _aircraft call ALIVE_fnc_configGetVehicleCrew;

            switch typeName _units do {
                case "STRING" : {_units = [_units]};
                case "ARRAY" : {};
                default {};
            };

            _crewProfile1 = [_units, _taskSide, _taskFaction, _targetPosition, random(360), _taskFaction, true] call ALIVE_fnc_createProfileEntity;
            _crewID = _crewProfile1 select 2 select 4;

            ["C2ISTAR - Task CSAR - Created profile %1 with units %2!",_crewID,_units] call ALiVE_fnc_Dump;

            _dialogOption = _dialogOptions select _choice; // Downed Pilot rescue or Crashsite recovery

            // format the dialog options

            private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText","_aircraftName","_newTaskPosition"];

            _aircraftName = getText(configFile >> "CfgVehicles" >> _aircraft >> "displayName");

            // For CSAR missions place the marker within 400m of the actual crashsite or crew, so that players have to search
            _newTaskPosition = _targetPosition getpos [200 + (random 200),random 360];

            // Rescue
            _nearestTown = [_newTaskPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Rescue"] call ALIVE_fnc_hashGet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_aircraftName,_nearestTown];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
            _formatMessage = _formatChat select 0;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText,_aircraftName,_nearestTown];
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

            private["_state","_tasks","_taskIDs","_dialog","_taskTitle","_taskDescription","_taskSource","_newTask","_newTaskID","_taskParams","_newTaskPosition"];

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
            _taskSource = format["%1-CSAR-Parent",_taskID];
            _newTask = [_taskID,_requestPlayerID,_taskSide,_newTaskPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

            _tasks pushback _newTask;
            _taskIDs pushback _taskID;

            // create the rescue task
            _dialog = [_dialogOption,"Rescue"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c1",_taskID];
            _taskSource = format["%1-CSAR-Rescue",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_newTaskPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

            _tasks pushback _newTask;
            _taskIDs pushback _taskID;

            // Create secure task
            // IF ATO or OPCOM is calling, don't create a wave of attackers.
            if (_requestPlayerID != "ATO" && _requestPlayerID != "OPCOM" ) then {
                _dialog = [_dialogOption,"DefenceWave"] call ALIVE_fnc_hashGet;
                _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
                _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
                _newTaskID = format["%1_c2",_taskID];
                _taskSource = format["%1-CSAR-DefenceWave",_taskID];
                _newTask = [_newTaskID,_requestPlayerID,_taskSide,_newTaskPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,"N",_taskID,_taskSource,true];

                _tasks pushback _newTask;
                _taskIDs pushback _newTaskID;
            };

            // create the return task
            _dialog = [_dialogOption,"Return"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c3",_taskID];
            _taskSource = format["%1-CSAR-Return",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_returnPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,"N",_taskID,_taskSource,true];

            _tasks pushback _newTask;
            _taskIDs pushback _newTaskID;

            // select the type of spawn

            private["_spawnTypes","_spawnType","_crewAnims","_unboundAnims","_boundAnims"];

            _spawnTypes = ["static"];
            _spawnType = (selectRandom _spawnTypes);

            // store task data in the params for this task set
            _taskParams = [] call ALIVE_fnc_hashCreate;
            [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
            [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
            [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
            [_taskParams,"crewID",_crewID] call ALIVE_fnc_hashSet;
            [_taskParams,"crewSpawned",false] call ALIVE_fnc_hashSet;
            [_taskParams,"crewSpawnType",_spawnType] call ALIVE_fnc_hashSet;
            [_taskParams,"currentWave",1] call ALIVE_fnc_hashSet;
            [_taskParams,"lastWave",0] call ALIVE_fnc_hashSet;
            [_taskParams,"totalWaves",1 + floor(random 2)] call ALIVE_fnc_hashSet;
            [_taskParams,"entityProfileIDs",[]] call ALIVE_fnc_hashSet;
            [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;
            [_taskParams,"returnReached",false] call ALIVE_fnc_hashSet;
            [_taskParams,"crashsite",_crashsite] call ALIVE_fnc_hashSet;
            [_taskParams,"aircraft",_aircraft] call ALIVE_fnc_hashSet;
            [_taskParams,"actualPosition",_targetposition] call ALIVE_fnc_hashSet;
            [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;

            // return the created tasks and params

            _result = [_tasks,_taskParams];

        };
    };

    case "Parent":{
    };

    case "Rescue":{

        private [
            "_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
            "_destinationReached","_taskIDs","_crewSpawned","_crewSpawnType","_lastState","_taskDialog","_currentTaskDialog","_taskApplyType",
            "_startTime","_crashsite","_vehicleClass","_targetposition","_crewFound","_irstrobe","_crewID"
        ];

        _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;
        _taskPosition = _task select 3;
        _taskFaction = _task select 4;
        _taskTitle = _task select 5;
        _taskDescription = _task select 6;
        _taskPlayers = _task select 7 select 0;

        _taskApplyType = _task select 9;

        _lastState = [_params,"lastState"] call ALIVE_fnc_hashGet;
        _taskDialog = [_params,"dialog"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;
        _crewID = [_params,"crewID"] call ALIVE_fnc_hashGet;
        _crewSpawned = [_params,"crewSpawned"] call ALIVE_fnc_hashGet;
        _crewSpawnType = [_params,"crewSpawnType"] call ALIVE_fnc_hashGet;
        _startTime = [_params,"startTime"] call ALIVE_fnc_hashGet;
        _crashsite = [_params,"crashsite",false] call ALIVE_fnc_hashGet;
        _vehicleClass = [_params,"aircraft"] call ALIVE_fnc_hashGet;
        _targetposition = [_params,"actualPosition"] call ALIVE_fnc_hashGet;
        _crewFound = [_params,"crewFound",false] call ALIVE_fnc_hashGet;
        _irstrobe = [_params,"irstrobe"] call ALIVE_fnc_hashGet;

        if(_lastState != "Rescue") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Rescue"] call ALIVE_fnc_hashSet;
        };

        if!(_crewSpawned) then {

            _destinationReached = [_targetposition,_taskPlayers,1000] call ALIVE_fnc_taskHavePlayersReachedDestination;

            if(_destinationReached) then {

                // spawn the crew

                switch(_crewSpawnType) do {
                    case "static":{ // Crashsite or pilot

                        private["_taskObjects","_tables","_chairs","_electronics","_documents","_tableClass","_electronicClass",
                        "_documentClass","_table","_electronic","_document","_anims","_crewGroup","_crew","_crew1Active"];

                        // create the profiles

                        _crewProfile1 = [ALiVE_ProfileHandler,"getProfile",_crewID] call ALiVE_fnc_ProfileHandler;
                        _crewProfile1ID = _crewID;

                        // Fail mission if there is an error and crew isnt created
                        if (isnil "_crewProfile1") exitwith {
                            [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                            // Mission Over intermediate state - if dead or timeout update the parent-task instead of the child so all children get updated
                            _parent = _task select 11;
                            _parent = if (_parent == "None") then {_taskID} else {_parent};
                            _parentTask = [ALiVE_TaskHandler,"getTask",_parent] call ALiVE_fnc_TaskHandler;

                            _parentTask set [8,"Canceled"];
                            _parentTask set [10,"N"];

                            [ALiVE_TaskHandler,"TASK_UPDATE",_parentTask] call ALiVE_fnc_TaskHandler;

                            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                            ["chat_cancelled",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                        };

                        waitUntil {
                            sleep 1;
                            _crew1Active = _crewProfile1 select 2 select 1;
                            (_crew1Active)
                        };

                        _crewGroup = _crewProfile1 select 2 select 13;

                        ["C2ISTAR - Task CSAR - Spawned CSAR crew %1 at %2!",_crewGroup, getposATL leader _crewGroup] call ALiVE_fnc_Dump;

                        {
                            _x setCaptive true;
                            removeGoggles _x;
                            removeHeadgear _x;
                            removeAllAssignedItems _x;
                            _x setRank "PRIVATE";
                            if ((random 1) > 0.5) then {
                                _x setDamage (random 0.6);
                            };
                            _x setformdir 0;

                            [_x, format ["Rescue %1",name _x], "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa","\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa","_this distance _target < 2", "_caller distance _target < 2", {}, {}, {_target setVariable ["rescued",true,true]; ["Rescue", format ["You have rescued %1!",name _target]] call BIS_fnc_showSubtitle;},{},[],8] remoteExec ["BIS_fnc_holdActionAdd",0, true];

                        } foreach units _crewGroup;

                        _crewGroup setBehaviour "STEALTH";
                        _crewGroup setCombatMode "GREEN";

                        // store the data on the params
                        [_params, "startTime", time] call ALIVE_fnc_hashSet;
                        [_params, "crewSpawned",true] call ALIVE_fnc_hashSet;
                        [_params, "entityProfileIDs",[_crewProfile1ID]] call ALIVE_fnc_hashSet;

                    };
                };

            };
        } else {

            private["_entityProfiles","_entitiesState","_dead"];

            _entityProfiles = [_params,"entityProfileIDs"] call ALIVE_fnc_hashGet;

            _entitiesState = [_entityProfiles] call ALIVE_fnc_taskGetStateOfEntityProfiles;
            _dead = [_entitiesState,"allDestroyed"] call ALIVE_fnc_hashGet;

            if (_dead || time > _startTime + 3300) then {

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
                        private "_crew";

                        _group = _profile select 2 select 13;
                        _crew = leader _group;

                        _position = getPos _crew;

                        if (!_crewFound && [_targetposition,_taskPlayers,500] call ALIVE_fnc_taskHavePlayersReachedDestination) then {
                            // Chat update
                            _formatChat = [_currentTaskDialog,"chat_update"] call ALIVE_fnc_hashGet;
                            _formatMessage = _formatChat select 0;
                            _formatMessageText = _formatMessage select 1;
                            _formatMessageText = format[_formatMessageText, mapGridPosition _position];
                            _formatMessage set [1,_formatMessageText];
                            _formatChat set [0,_formatMessage];
                            [_currentTaskDialog,"chat_update",_formatChat] call ALIVE_fnc_hashGet;

                            ["chat_update",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                            [_position,_taskSide,_taskPlayers,_taskID,"csar"] call ALIVE_fnc_taskCreateMarkersForPlayers;

                            _irstrobe = "NVG_TargetW" createVehicle getpos _crew;
                            _irstrobe attachTo [_crew,[0,0,0.2],"neck"];

                            [_params,"irstrobe",_irstrobe] call ALIVE_fnc_hashSet;
                            [_params,"crewFound",true] call ALIVE_fnc_hashSet;
                        };

                        if (_crew getVariable ["rescued",false]) then {

                            private _player = [_position,_taskPlayers] call ALIVE_fnc_taskGetClosestPlayerToPosition;

                            {
                                if (!isNil "_irstrobe") then {
                                    detach _irstrobe;
                                    deleteVehicle _irstrobe;
                                };

                                _x setCaptive false;
                                [_x] joinSilent (group _player);
                            } foreach units _group;

                            (group _player) selectLeader _player;

                            _task set [8,"Succeeded"];
                            _task set [10, "N"];
                            _task set [3, _position];

                            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                            ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                            [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

                            // Next Task
                            _taskIDs = [_params,"taskIDs"] call ALIVE_fnc_hashGet;
                            [_params,"nextTask",_taskIDs select 2] call ALIVE_fnc_hashSet;

                            _result = _task;
                        };
                    };

                } forEach _profiles;

            };
        };
    };

    case "DefenceWave":{

        private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
        "_areaClear","_lastState","_taskDialog","_missileStrikeCreated","_atmosphereCreated","_currentTaskDialog","_taskEnemyFaction",
        "_taskEnemySide","_currentWave","_lastWave","_totalWaves","_enemyFaction","_entityProfileIDs","_defend","_areaClear","_firstCheck","_dwentityProfileIDs"];

        _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;

        // Update task position
        _task set [3, [_params,"actualPosition"] call ALIVE_fnc_hashGet];

        _taskPosition = _task select 3;
        _taskFaction = _task select 4;
        _taskTitle = _task select 5;
        _taskDescription = _task select 6;
        _taskPlayers = _task select 7 select 0;

        _lastState = [_params,"lastState"] call ALIVE_fnc_hashGet;
        _taskDialog = [_params,"dialog"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;
        _currentWave = [_params,"currentWave"] call ALIVE_fnc_hashGet;
        _lastWave = [_params,"lastWave"] call ALIVE_fnc_hashGet;
        _totalWaves = [_params,"totalWaves"] call ALIVE_fnc_hashGet;
        _enemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
        _entityProfileIDs = [_params,"entityProfileIDs",[]] call ALIVE_fnc_hashGet;
        _dwentityProfileIDs = [_params,"DWentityProfileIDs",[]] call ALIVE_fnc_hashGet;
        _defend = [_params,"defend"] call ALIVE_fnc_hashGet;
        _firstCheck = [_params,"firstCheck",true] call ALIVE_fnc_hashGet;

        if(_lastState != "DefenceWave") then {

            _defend = (random 1) > 0.5;

            if (_defend) then {
                ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            } else {
                _areaClear = [_taskPosition,_taskPlayers,_taskSide, 200] call ALIVE_fnc_taskIsAreaClearOfEnemies;
                if !(_areaClear) then {
                    ["chat_clear",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                };
            };

            [_params,"lastState","DefenceWave"] call ALIVE_fnc_hashSet;
            [_params,"defend",_defend] call ALIVE_fnc_hashSet;

            _result = _task;
        };

        if(_currentWave > _lastWave && _defend) then {

            private["_groupCount","_remotePosition","_groups","_group","_remotePosition","_position","_profiles","_profileWaypoint","_diceRoll",
            "_profileIDs","_profileID"];

            ["CREATING WAVE: %1",_currentWave] call ALIVE_fnc_dump;

            _groupCount = _currentWave * floor(1 + random 2);
            _profileIDs = [];
            _groups = [];

            for "_i" from 0 to _groupCount -1 do {
                _group = ["Infantry",_enemyFaction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups pushback _group;
                }
            };

            _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

            ["INF GROUPS: %1",_groups] call ALIVE_fnc_dump;

            _remotePosition = [_taskPosition, 500, 5, true] call ALIVE_fnc_getPositionDistancePlayers;
            _remotePosition = (selectRandom _remotePosition);

            {
                _position = (_remotePosition getPos [(random 200), (random 200)]);
                _profiles = [_x, _position, random(360), true, _enemyFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
                _profileID = _profiles select 0 select 2 select 4;
                _position = (_taskPosition getPos [(random 40), (random 40)]);
                _profileWaypoint = [_position, 100, "MOVE", "FULL", 100, [], "LINE", "NO CHANGE", "CARELESS"] call ALIVE_fnc_createProfileWaypoint;
                [(_profiles select 0), "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                _profileIDs pushback _profileID;

            } forEach _groups;

            _diceRoll = random 1;

            if(_diceRoll > 0.5) then {

                private["_vehicleGroupTypes","_vehicleGroup"];

                _groups = [];

                _vehicleGroupTypes = ["Armored","Mechanized","Motorized"];
                _vehicleGroup = (selectRandom _vehicleGroupTypes);

                _group = [_vehicleGroup,_enemyFaction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                     _groups pushback _group;
                };

                _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

                ["VEH GROUPS: %1",_groups] call ALIVE_fnc_dump;

                {
                    _position = (_remotePosition getPos [(random 200), (random 200)]);
                    _profiles = [_x, _position, random(360), true, _enemyFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
                    _profileID = _profiles select 0 select 2 select 4;
                    _position = (_taskPosition getPos [(random 40), (random 40)]);
                    _profileWaypoint = [_position, 100, "MOVE", "FULL", 100, [], "LINE", "NO CHANGE", "CARELESS"] call ALIVE_fnc_createProfileWaypoint;
                    [(_profiles select 0), "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                    _profileIDs pushback _profileID;

                } forEach _groups;
            };

            //["PROFILE IDS: %1",_profileIDs] call ALIVE_fnc_dump;

            [_params,"DWentityProfileIDs",_profileIDs] call ALIVE_fnc_hashSet;
            [_params,"lastWave",(_lastWave+1)] call ALIVE_fnc_hashSet;

        }else{

            private["_dwentitiesState","_allDestroyed"];

            _dwentitiesState = [_dwentityProfileIDs] call ALIVE_fnc_taskGetStateOfEntityProfiles;

            _allDestroyed = [_dwentitiesState,"allDestroyed",false] call ALIVE_fnc_hashGet;

            ["FIGHTING WAVE : %1",_currentWave] call ALIVE_fnc_dump;

            if(_allDestroyed) then {

                if(_currentWave < _totalWaves) then {
                    [_params,"currentWave",(_currentWave+1)] call ALIVE_fnc_hashSet;
                }else{

                    _areaClear = [_taskPosition,_taskPlayers,_taskSide, 200] call ALIVE_fnc_taskIsAreaClearOfEnemies;

                    if(_areaClear) then {

                        private _taskIDs = [_params,"taskIDs"] call ALIVE_fnc_hashGet;
                        [_params,"nextTask",_taskIDs select 3] call ALIVE_fnc_hashSet;

                        _task set [8,"Succeeded"];
                        _task set [10, "N"];
                        _result = _task;

                        [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                        ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                        [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;


                    } else {

                        if (_firstCheck) then {
                            ["chat_clear",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                            [_params,"firstCheck",false] call ALIVE_fnc_hashSet;
                        };

                    };

                };
            };

            // Check to see if players and crew are still at Crash Site/recovery area
            private "_atTaskPosition";
            _atTaskPosition = [_taskPosition, _taskPlayers, 200] call ALIVE_fnc_taskHavePlayersReachedDestination;

            If !(_atTaskPosition) then {
                _taskIDs = [_params,"taskIDs"] call ALIVE_fnc_hashGet;
                [_params,"nextTask",_taskIDs select 3] call ALIVE_fnc_hashSet;

                _task set [8,"Succeeded"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                ["chat_leftArea",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;
            };

            // Check to see if Crew are still alive

            private _entitiesState = [_entityProfileIDs] call ALIVE_fnc_taskGetStateOfEntityProfiles;
            private _dead = [_entitiesState,"allDestroyed"] call ALIVE_fnc_hashGet;

            // task is completed successfully
            if (_dead) then {

                // profile is dead

                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                // Mission Over intermediate state - if dead or timeout update the parent-task instead of the child so all children get updated
                _parent = _task select 11;
                _parent = if (_parent == "None") then {_taskID} else {_parent};
                _parentTask = [ALiVE_TaskHandler,"getTask",_parent] call ALiVE_fnc_TaskHandler;

                _parentTask set [8,"Failed"];
                _parentTask set [10,"N"];

                [ALiVE_TaskHandler,"TASK_UPDATE",_parentTask] call ALiVE_fnc_TaskHandler;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

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

                _destinationReached = [_taskPosition, _taskPlayers, 10] call ALIVE_fnc_taskHavePlayersReachedDestination;

                // the players are at the return point
                if(_destinationReached) then {

                    _profiles = [_entitiesState,"profiles"] call ALIVE_fnc_hashGet;

                    // Remove crew(s) from group
                    {
                        private ["_profile","_active","_unit"];
                        _profile = _x;

                        _active = _profile select 2 select 1;
                        _unit = _profile select 2 select 10;

                        if(_active && {vehicle _unit == _unit} && {(getpos _unit) select 2 < 2} && {_unit distance _taskPosition <= 10}) then {
                            [_unit] joinSilent grpNull;
                            [_unit, _taskPosition] call ALiVE_fnc_doMoveRemote;

                            _returnReached = true;
                            [_params,"returnReached",_returnReached] call ALIVE_fnc_hashSet;
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

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            }else{


                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Succeeded"];
                _task set [10, "N"];
                _result = _task;

                ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

                if (_requestPlayerID == "ATO") then {                     // TODO
                    // return pilot to ATO

                };
            };

        };
    };
};

_result
