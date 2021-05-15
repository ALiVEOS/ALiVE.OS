#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskWiretap);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskWiretap

Description:
Wiretap Task

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
Tupolov
---------------------------------------------------------------------------- */
params [
		"_taskState",
		"_taskID",
		"_task",
		"_params",
		"_debug"
	];

private _result = [];

switch (_taskState) do {
    case "init": {
		_task params [
				"_taskID",
				"_requestPlayerID",
				"_taskSide",
				"_taskFaction",
				"",
				"_taskLocationType",
				"_taskLocation",
				"_taskPlayers",
				"_taskEnemyFaction",
				"_taskCurrent",
				"_taskApplyType",
                "_targetBuilding"
			];

        private _tasksCurrent = ([ALiVE_TaskHandler, "tasks", ["", [], [], nil]] call ALiVE_fnc_HashGet) select 2;

        if (_taskID == "") exitwith {["C2ISTAR - Task Wiretap - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task Wiretap - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task Wiretap - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task Wiretap - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task Wiretap - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task Wiretap - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task Wiretap - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task Wiretap - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        if (isNil "_targetBuilding") then {_targetBuilding = objNull} else {_targetBuildings = [_targetBuilding];};

        private _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;
        private _targetBuildings = [];
        private _blacklist = ["Land_dp_smallFactory_F","Land_Garbage_square5_F","Land_vn_garbage_square5_f"];

        // establish the location for the task
        // get enemy location based on input
        if (_taskLocationType in ["Short", "Medium", "Long"] && isNull _targetBuilding) then {
            if (!isNil "OPCOM_instances") then {
                //["Selecting Task location from OPCOMs"] call ALiVE_fnc_DumpR;
                private _triggerStates = ["defend", "defending", "reserve", "reserving", "idle", "unassigned"];
                private _objectives = [];
                {
                    private _OPCOM = _x;
                    private _OPCOM_factions = [_OPCOM, "factions", ""] call ALiVE_fnc_HashGet;
                    private _OPCOM_side = [_OPCOM, "side", ""] call ALiVE_fnc_HashGet;

                    //["Looking up correct OPCOM %1 for faction %2",_OPCOM_factions,_taskEnemyFaction] call ALiVE_fnc_DumpR;
                    if ({_x == _taskEnemyFaction} count _OPCOM_factions > 0) then {
                        private _OPCOM_objectives = [_OPCOM, "objectives", []] call ALiVE_fnc_HashGet;

                        //["Looking up correct ones in %1 objectives for faction %2",count _OPCOM_objectives,_taskEnemyFaction] call ALiVE_fnc_DumpR;
                        {
                            private _OPCOM_objective = _x;
                            private _OPCOM_objective_state = [_OPCOM_objective, "opcom_state", ""] call ALiVE_fnc_HashGet;
                            private _OPCOM_objective_center = [_OPCOM_objective, "center", [0, 0, 0]] call ALiVE_fnc_HashGet;

                            //["Matching state %1 in triggerstates %2 tasks %3 faction %4!",_OPCOM_objective_state,_triggerStates,_tasksCurrent,_taskFaction] call ALiVE_fnc_DumpR;
                            if (_OPCOM_objective_state in _triggerStates &&
                                {(({(_x select 4) == _taskFaction && {(_x select 3) distance _OPCOM_objective_center < 500}} count _tasksCurrent) == 0)}
                            ) then {
                                _objectives pushback _OPCOM_objective;
                            };
                        } forEach _OPCOM_objectives;
                    };
                } forEach OPCOM_instances;

                if (count _objectives > 0) then {
					private _player = [_requestPlayerID] call ALIVE_fnc_getPlayerByUID;

					if (isNull _player) then {
						_player = selectRandom (_taskPlayers select 0);
						_player = [_player] call ALIVE_fnc_getPlayerByUID;
					};

                    private _objectives = [_objectives, [getPosATL _player], {_Input0 distance ([_x, "center"] call ALiVE_fnc_HashGet)}, "ASCEND", {
							private _id = [_x, "opcomID", ""] call ALiVE_fnc_HashGet;
							private _pos = [_x, "center"] call ALiVE_fnc_HashGet;
							private _opcom = [objNull, "getOPCOMbyid", _id] call ALiVE_fnc_OPCOM;
							private _side = [_opcom, "side", ""] call ALiVE_fnc_HashGet;

							!([_pos, _side, 500, true] call ALiVE_fnc_isEnemyNear);
						}] call ALiVE_fnc_SortBy;

                    private _totalIndexes = (count _objectives)-1;
                    private _index = 0;

                    if (count _objectives > 1) then {
						_index = switch (_taskLocationType) do {
                            case "Short": {floor (random floor (_totalIndexes/ceil (_totalIndexes*0.8)))};
                            case "Medium": {floor (_totalIndexes/ceil (_totalIndexes*0.5))};
                            case "Long": {floor (_totalIndexes/ceil (_totalIndexes*0.1))};
                        };
                    };

                    _taskLocation = [_objectives select _index, "center"] call ALiVE_fnc_HashGet;
                    private _clusterID = [_objectives select _index, "clusterID", ""] call ALiVE_fnc_HashGet;
                    private _type = [_objectives select _index, "objectiveType", ""] call ALiVE_fnc_HashGet;

                    {
                        private _clusters = _x;
                        private _clustercontent = missionNamespace getVariable _x;

                        if (!isNil "_clustercontent" && {_clusterID in (_clustercontent select 1)}) then {
                            private _cluster = [_clustercontent, _clusterID] call ALiVE_fnc_HashGet;
                            private _clusterLocation = [_cluster, "center"] call ALiVE_fnc_HashGet;

                            _clusterLocation resize 2;
                            _taskLocation resize 2;

                            if (_clusterLocation distance _taskLocation < 15) exitwith {
                                _targetBuildings = +([_cluster, "nodes", []] call ALiVE_fnc_HashGet);

								{
                                    if !(_x isKindOf "House_F") then {_targetBuildings set [_foreachIndex, objNull]};
                                } forEach _targetBuildings;

                                _targetBuildings = _targetBuildings - [objNull];
                            };
                        };

                        if (!isNil "_targetBuildings" && {count _targetBuildings > 0}) exitwith {};
                    } foreach [
                        "ALIVE_clustersCivComms"
                    ];

                    ["C2ISTAR - Task Wiretap - OPCOM index %2 selected as objective at position %1",_taskLocation,_index] call ALiVE_fnc_Dump;
                    ["C2ISTAR - Task Wiretap - Buildings in %3 cluster %2: %1",_targetBuildings,_clusterID,_type] call ALiVE_fnc_Dump;
                } else {
                    ["C2ISTAR - Task Wiretap - Currently there are no OPCOM objectives available, using map locations!"] call ALiVE_fnc_Dump;

                    _taskLocation = position (selectRandom (nearestLocations [
							getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"),
							["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "CityCenter", "Airport"],
							30000
						]));
                };
            };
        };

        if (isNil "_taskLocation") exitwith {["C2ISTAR - Task Wiretap - No location selected!"] call ALiVE_fnc_Dump};

        if (count _targetBuildings == 0) then {
            ["C2ISTAR - No buildings given for this wiretap location! Creating comms composition..."] call ALiVE_fnc_Dump;

            private ["_category","_compType"];
            _compType = "Military";
            If (_taskEnemySide == "GUER") then {
                _compType = "Guerrilla";
            };
            [_taskLocation, _compType, "Communications", _taskEnemyFaction, ["Small","Medium"], 1] call ALIVE_fnc_spawnRandomPopulatedComposition;

            // Add Tower just in case
            createVehicle ["Land_TTowerSmall_2_F" , _taskLocation, [], 15, "NONE"];

            // Get buildings from comp (or nearest)
            _targetBuildings = _taskLocation nearObjects ["House_F",50];
        };

        _targetBuildings = [_targetBuildings, [], {
			//By indoor building positions
            sizeOf (typeof _x);
        },"DESCEND",{
            private _alive = alive _x;
            private _lamp = _x isKindOf "Lamps_Base_F";

			//Edit for blacklist (placeholder) in case it is still needed (case sensitive)
            private _excluded = (typeOf _x) in _blacklist;

            _alive && {!_excluded} && {!_lamp};
        }] call ALiVE_fnc_SortBy;

		//still no suitable buildings? fuck off...
        if (_targetBuildings isEqualTo []) exitwith {["C2ISTAR - Task Wiretap - There are no buildings to wiretap at the target area!"] call ALiVE_fnc_Dump};

		//Move on
		private _targetBuilding = objNull;
        if (count _targetBuildings >= 3) then {
            _targetBuildings resize 3;
            _targetBuilding = selectRandom _targetBuildings;
        } else {
            _targetBuilding = _targetBuildings select 0;
        };

        private _targetPosition = getPosATL _targetBuilding;
        private _targetID = str (floor (_targetPosition select 0)) + str (floor (_targetPosition select 1));
        private _targetDisplayType = getText (configfile >> "CfgVehicles" >> typeOf _targetBuilding >> "displayName");

        ["C2ISTAR - Task Wiretap - Building: %1 | Type: %2 | Pos: %3!", _targetBuilding, _targetDisplayType, _targetPosition] call ALiVE_fnc_Dump;

        //["Sorting buildings by type and adding reward..."] call ALiVE_fnc_DumpR;
        private _points = 0;
        private _list = [];
		private ["_buildingType", "_reward"];
        {
            private _object = _x;
            private _model = getText(configfile >> "CfgVehicles" >> typeOf _object >> "model");

            if (!isNil "_object" && {!isNull _object}) then {
                {
                    _x params ["_type", "_typeText", "_points"];

                    if (!isNil {call compile _type} &&
                        {
                            {([toLower (_model), toLower _x] call CBA_fnc_find) > -1} count (call compile _type) > 0 ||
                            {{([toLower (typeOf _object), toLower _x] call CBA_fnc_find) > -1} count (call compile _type) > 0} //Remove when all indexes have been rebuilt with CLIT
                        }
                    ) exitwith {
                        _buildingType = _typeText;
                        _reward = _points;
                    };

                    _buildingType = "location";
                    _reward = 30;
                } foreach [
                    ["ALIVE_militaryHQBuildingTypes","HQ building",70],
                    ["ALIVE_militarySupplyBuildingTypes","military supply building",30],
                    ["ALIVE_militaryBuildingTypes","military building",40],
                    ["ALIVE_airBuildingTypes","air installation",30],
                    ["ALIVE_militaryAirBuildingTypes","military air installation",30],
                    ["ALIVE_civilianAirBuildingTypes","civilian air installation",20],
                    ["ALIVE_militaryHeliBuildingTypes","military rotary-wing installation",20],
                    ["ALIVE_civilianHeliBuildingTypes","civilian helicopter installation",20],
                    ["ALIVE_militaryParkingBuildingTypes","military logistics building",20],
                    ["ALIVE_civilianCommsBuildingTypes","communications site",100],
                    ["ALIVE_civilianHQBuildingTypes","civilian HQ building",60],
                    ["ALIVE_civilianPowerBuildingTypes","power supply building",30],
                    ["ALIVE_civilianMarineBuildingTypes","marine installation",20],
                    ["ALIVE_civilianFuelBuildingTypes","fuel supply building",30],
                    ["ALIVE_civilianPopulationBuildingTypes","civilian population building",10],
                    ["ALIVE_civilianRailBuildingTypes","rail constructions",30],
                    ["ALIVE_civilianConstructionBuildingTypes","construction site",10],
                    ["ALIVE_civilianSettlementBuildingTypes","civilian settlement building",10]
                ];
            };
        } foreach [_targetBuilding];

        //Set add action for wiretap
        [
            _targetBuilding,
            "Setup Wiretap",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
            "_this distance2D _target < 3 && !(_target getvariable ['ALiVE_Task_Wiretapped',false]) && ('Item_Toolkit' in (items _this + assignedItems _this + backpackItems _this) || 'vn_b_item_wiretap' in (items _this + assignedItems _this + backpackItems _this))",
            "_caller distance2D _target < 3",
            {},
            {},
            {
                params ["_target", "_caller", "_ID", "_arguments"];

                _target setVariable ["ALiVE_Task_Wiretapped",true,true];

                private _targetDisplayType = getText (configfile >> "CfgVehicles" >> typeOf _target >> "displayName");

                ["Task Accomplished", format ["%1 has set up a wiretap on %3 at grid %2!",name _caller, mapGridPosition _target, _targetDisplayType]] remoteExec ["BIS_fnc_showSubtitle",side _caller];
            },
            {},
            [],
            (sizeOf (typeOf _targetBuilding)) max 45
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, true];

        // select the random text
        private _dialogOptions = [ALIVE_generatedTasks, "Wiretap"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        // format the dialog options
        private _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;
        private _dialog = [_dialogOption, "Wiretap"] call ALIVE_fnc_hashGet;

        private _formatChat = [_dialog, "chat_start"] call ALIVE_fnc_hashGet;
        private _formatMessage = _formatChat select 0;
        private _formatMessageText = _formatMessage select 1;
        _formatMessageText = format [_formatMessageText, _nearestTown, _targetDisplayType, _buildingType];
        _formatMessage set [1, _formatMessageText];
        _formatChat set [0, _formatMessage];
        [_dialog, "chat_start", _formatChat] call ALIVE_fnc_hashSet;

        // create the tasks
		private _state = "Created";
        if (_taskCurrent == 'Y') then {
            _state = "Assigned";
        };

        private _tasks = [];
        private _taskIDs = [];

        // create the parent task
        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;

        private _taskTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        private _taskDescription = [_dialog, "description"] call ALIVE_fnc_hashGet;
        private _taskSource = format ["%1-Wiretap-Parent", _taskID];

        _taskTitle = format [_taskTitle, _nearestTown];
        _taskDescription = format [_taskDescription, _nearestTown, _buildingType];
        private _newTask = [_taskID, _requestPlayerID, _taskSide, _targetPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];

        _tasks pushback _newTask;
        _taskIDs pushback _taskID;

        // create the destroy task
        _dialog = [_dialogOption, "Wiretap"] call ALIVE_fnc_hashGet;

        _taskTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog, "description"] call ALIVE_fnc_hashGet;
        private _newTaskID = format ["%1_c2", _taskID];
        _taskSource = format ["%1-Wiretap-Wiretap", _taskID];

        _taskTitle = format [_taskTitle, _buildingType];
        _taskDescription = format [_taskDescription, _nearestTown, _targetDisplayType, _buildingType];

        private _newTask = [_newTaskID, _requestPlayerID, _taskSide, _targetPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, true];

        _tasks pushback _newTask;
        _taskIDs pushback _newTaskID;

        // store task data in the params for this task set
        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "targets", [_targetBuilding]] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        // return the created tasks and params
        _result = [_tasks, _taskParams];
    };
    case "Parent": {

    };
    case "WireTap": {
		_task params [
				"_taskID",
				"_requestPlayerID",
				"_taskSide",
				"_taskPosition",
				"_taskFaction",
				"_taskTitle",
				"_taskDescription",
				"_taskPlayers"
			];

        _taskPlayers = _taskPlayers select 0;
        private _lastState = [_params, "lastState"] call ALIVE_fnc_hashGet;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, _taskState] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;

        if (_lastState != "Wiretap") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Wiretap"] call ALIVE_fnc_hashSet;
        };

        // Check to see if wiretap has happened
        private _buildingWiretapped = (_targets select 0) getVariable ["ALiVE_Task_Wiretapped", false];

        if (_buildingWiretapped) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;

            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

            ["chat_success", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_currentTaskDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;

            // Increase chance of intel
            private _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
            private _currentIntelChance = missionnamespace getvariable (format["ALiVE_MIL_OPCOM_INTELCHANCE_%1",_taskEnemySide]);
            missionnamespace setvariable [format["ALiVE_MIL_OPCOM_INTELCHANCE_%1",_taskEnemySide], _currentIntelChance + 1];

        } else {
            private _taskEnemyFaction = [_params, "enemyFaction"] call ALIVE_fnc_hashGet;
            private _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
            private _targets = [_targetsState, "targets"] call ALIVE_fnc_hashGet;

            {
                private _objectType = getText (configfile >> "CfgVehicles" >> typeOf _x >> "displayName");
                [getposATL _x, _taskEnemySide, _taskPlayers, _taskID, "building", _objectType] call ALIVE_fnc_taskCreateMarkersForPlayers;
            } forEach _targets;
        };
    };
};

_result;
