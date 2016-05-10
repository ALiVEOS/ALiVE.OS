#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskSabotageBuilding);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskDestroyInfantry

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

	    private["_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskEnemyFaction","_taskCurrent",
	    "_taskApplyType","_taskEnemySide","_targetSector","_targetEntity","_taskPlayers","_targetBuilding","_targetBuildings","_targetTypes"];

        _taskID = [_task, 0, "", [""]] call BIS_fnc_param;
        _requestPlayerID = [_task, 1, "", [""]] call BIS_fnc_param;
        _taskSide = [_task, 2, "", [""]] call BIS_fnc_param;
        _taskFaction = [_task, 3, "", [""]] call BIS_fnc_param;
        _taskLocationType = [_task, 5, "", [""]] call BIS_fnc_param;
        _taskLocation = [_task, 6, [], [[]]] call BIS_fnc_param;
        _taskPlayers = [_task, 7, [], [[]]] call BIS_fnc_param;
        _taskEnemyFaction = [_task, 8, "", [""]] call BIS_fnc_param;
        _taskCurrent = [_taskData, 9, "", [""]] call BIS_fnc_param;
        _taskApplyType = [_taskData, 10, "", [""]] call BIS_fnc_param;
        
        _tasksCurrent = ([ALiVE_TaskHandler,"tasks",["",[],[],nil]] call ALiVE_fnc_HashGet) select 2;
        
        /*
        //Inputs
        ["%1 | %2 | %3 | %4 | %5 | %6 | %7 | %8 | %9 | %10",
	        _taskID,
			_requestPlayerID,
			_taskSide,
			_taskFaction,
			_taskLocationType,
			_taskLocation,
			_taskPlayers,
			_taskEnemyFaction,
			_taskCurrent,
			_taskApplyType
        ] call ALiVE_fnc_Dump;
        */
        
        if (_taskID == "") exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task SabotageBuilding - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};
        
        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;
        _targetBuildings = [];

        // establish the location for the task
        // get enemy location based on input
        
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
	            	_objectives = [_objectives,[getposATL _player],{_Input0 distance ([_x,"center"] call ALiVE_fnc_HashGet)},"ASCEND",{
                        
                        _id = [_x,"opcomID",""] call ALiVE_fnc_HashGet;
                        _pos = [_x,"center"] call ALiVE_fnc_HashGet;
                        _opcom = [objNull,"getOPCOMbyid",_id] call ALiVE_fnc_OPCOM;
                        _side = [_opcom,"side",""] call ALiVE_fnc_HashGet;
                        
                        !([_pos,_side,500,true] call ALiVE_fnc_isEnemyNear);
                    }] call ALiVE_fnc_SortBy;
	                
                    _totalIndexes = (count _objectives)-1;
	                _index = 0;
                    
                    if (count _objectives > 1) then {
		                switch (_taskLocationType) do {
		                    case ("Short") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.8)); _index = floor(random _index)};
		                    case ("Medium") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.5))};
		                    case ("Long") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.1))};
		                };
					};
                    
	                _taskLocation = [_objectives select _index,"center"] call ALiVE_fnc_HashGet;
                    _clusterID = [_objectives select _index,"clusterID",""] call ALiVE_fnc_HashGet;
                    _type = [_objectives select _index,"type",""] call ALiVE_fnc_HashGet;
                    
                    _targetTypes = [];
                    
                    switch _type do {
                        case ("CIV") : {
                            _targetTypes =  [
                        		"ALIVE_clustersCiv",
								"ALIVE_clustersCivConstruction",
								"ALIVE_clustersCivFuel",
								"ALIVE_clustersCivHQ",
								"ALIVE_clustersCivMarine",
								"ALIVE_clustersCivPower",
								"ALIVE_clustersCivRail",
								"ALIVE_clustersCivSettlement",
                                "ALIVE_clustersCivComms"
                        	];
                        };
                        default {
                            _targetTypes = [
                            	"ALIVE_clustersMil",
								"ALIVE_clustersMilAir",
								"ALIVE_clustersMilHeli",
								"ALIVE_clustersMilHQ"
                            ];
                        };
                    };

			        {
			            _clusters = _x;
			            
			            if (!(isnil {call compile _clusters}) && {_clusterID in ((call compile _clusters) select 1)}) then {
                            
                            _cluster = [call compile _clusters,_clusterID] call ALiVE_fnc_HashGet;
                            _clusterLocation = [_cluster,"center"] call ALiVE_fnc_HashGet;
                            
                            _clusterLocation resize 2;
                            _taskLocation resize 2;
                            
                            if (str(_clusterLocation) == str(_taskLocation)) exitwith {
                                
								_targetBuildings = [_cluster,"nodes",[]] call ALiVE_fnc_HashGet;
                            };
			            };
                        
                        if (!isnil "_targetBuildings") exitwith {};
			        } foreach _targetTypes;
                                        
	                ["C2ISTAR - Task SabotageBuilding - OPCOM index %2 selected as objective at position %1",_taskLocation,_index] call ALiVE_fnc_Dump;
                    ["C2ISTAR - Task SabotageBuilding - Buildings in %3 cluster %2: %1",_targetBuildings,_clusterID,_type] call ALiVE_fnc_Dump;
	            } else {
                    ["C2ISTAR - Task SabotageBuilding - Currently there are no OPCOM objectives available, using map locations!"] call ALiVE_fnc_Dump;
                    
                    _taskLocation = position ((nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["NameVillage","NameCity","NameCityCapital","NameLocal","CityCenter","Airport"], 30000]) call BIS_fnc_SelectRandom);
                };
	        };
        };
   
        if (isnil "_taskLocation") exitwith {["C2ISTAR - Task SabotageBuilding - No location selected!"] call ALiVE_fnc_Dump};

        //["Sorting buildings by height..."] call ALiVE_fnc_DumpR;
        //Led to Lampposts being selected, now going for buildings with most buildingpos and fallback to random building within 500m
        /*
        _targetBuildings = [_targetBuildings,[],{
            
            _maxHeight = -999;
			if (alive _x && {!((typeOf _x) isKindOf "House_Small_F")}) then {
                
                if !((getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "destrType")) == "DestructNo") then {
	                _bbr = boundingBoxReal _x;
			        _p1 = _bbr select 0; _p2 = _bbr select 1;
	                _maxHeight = abs ((_p2 select 2) - (_p1 select 2));
                };
            };
	        _maxHeight
            
        },"DESCEND"] call ALiVE_fnc_SortBy;

		//Filter broken 
        _targetBuildings = [_targetBuildings,[],{
            _bbr = boundingBoxReal _x;
	        _p1 = _bbr select 0; _p2 = _bbr select 1;
			abs ((_p2 select 2) - (_p1 select 2));
        },"DESCEND", {
            alive _x &&
            {_x isKindOf "House_Small_F"} &&
            {!((getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "destrType")) == "DestructNo")}
        }] call ALiVE_fnc_SortBy;
		
        _targetBuildings = [_targetBuildings,[],{
            
			count ([getPosATL _x, 10] call ALIVE_fnc_findIndoorHousePositions);

        },"DESCEND", {
            _alive = alive _x;
            _house = _x isKindOf "House_Small_F";
            _destructable = !((getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "destrType")) == "DestructNo");
            _hasBuildingPos = count ([getPosATL _x, 10] call ALIVE_fnc_findIndoorHousePositions) > 0;
            
            _result = _alive && _house && _destructable && _hasBuildingPos;
            _result;
            
        }] call ALiVE_fnc_SortBy;
        */
        
        //Pre-filter Array since ALiVE_fnc_SortBy is broken atm.
        {
            private ["_alive", "_house", "_destructable", "_hasBuildingPos"];
            
	        _alive = alive _x;
	        _house = _x isKindOf "House_F";
	        _destructable = !((getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "destrType")) == "DestructNo");
	        _hasBuildingPos = count ([getPosATL _x, 10] call ALIVE_fnc_findIndoorHousePositions) > 0;

            if !(_alive && {_house} && {_destructable} && {_hasBuildingPos}) then {_targetBuildings set [_foreachindex,objNull]};
        } foreach _targetBuildings;
        _targetBuildings = _targetBuildings - [objNull];

		//Sort by housepositions
        _targetBuildings = [_targetBuildings,[],{
            
			count ([getPosATL _x, 10] call ALIVE_fnc_findIndoorHousePositions);

        },"DESCEND"] call ALiVE_fnc_SortBy;
  
        
        //Move on                        
        if (count _targetBuildings < 1) then {
            ["C2ISTAR - No enterable buildings found for sabotage task! Defaulting to random house within 500m"] call ALiVE_fnc_Dump;

            _targetBuildings = _taskLocation nearObjects ["House_F",500];
            _lamps = _taskLocation nearObjects ["Lamps_base_F",500];
            
            _targetBuildings = _targetBuildings - _lamps;
            
	        _targetBuildings call BIS_fnc_arrayShuffle;            
        };

        if (count _targetBuildings == 0) exitwith {["C2ISTAR - Task SabotageBuilding - There are no buildings to attack at the target area!"] call ALiVE_fnc_Dump};

        _targetBuilding = _targetBuildings select 0;

        private["_targetPosition","_targetID","_targetDisplayType"];
        
        _targetPosition = getposATL _targetBuilding;
        _targetID = str(floor(_targetPosition select 0)) + str(floor(_targetPosition select 1)); 
		_targetDisplayType = getText(configfile >> "CfgVehicles" >> (typeOf _targetBuilding) >> "displayName");
        
        ["C2ISTAR - Task SabotageBuilding - Building: %1 | Type: %2 | Pos: %3!",_targetBuilding,_targetDisplayType,_targetPosition] call ALiVE_fnc_Dump;

        private["_stagingPosition","_dialogOptions","_dialogOption","_buildingType","_reward"];

		//["Sorting buildings by type and adding reward..."] call ALiVE_fnc_DumpR;
	    _points = 0;
	    _list = [];
	    {
	        private ["_object","_model"];
	        
            _object = _x;
            _model = getText(configfile >> "CfgVehicles" >> typeOf _object >> "model");
	        
	        if (!(isnil "_object") && {!isNull _object}) then {
                
				{
				    _type = _x select 0;
				    _typeText = _x select 1;
                    _points = _x select 2;
				    
				    if (
                    	!(isnil {call compile _type}) &&
                    	{
                            {([toLower (_model), toLower _x] call CBA_fnc_find) > -1} count (call compile _type) > 0 || 
                            {{([toLower (typeOf _object), toLower _x] call CBA_fnc_find) > -1} count (call compile _type) > 0} //Remove when all indexes have been rebuilt with CLIT
                        }
                    ) exitwith {
                        _buildingType = _typeText;
                        _reward = _points;
                    };
                    
                    _buildingType = "location";
                    _reward = 10;
				    
				} foreach [
					["ALIVE_militaryHQBuildingTypes","HQ building",50],
                    ["ALIVE_militarySupplyBuildingTypes","military supply building",30],
                    ["ALIVE_militaryBuildingTypes","military building",20],
                    ["ALIVE_airBuildingTypes","air installation",30],
					["ALIVE_militaryAirBuildingTypes","military air installation",30],
					["ALIVE_civilianAirBuildingTypes","civilian air installation",20],
					["ALIVE_militaryHeliBuildingTypes","military rotary-wing installation",20],
					["ALIVE_civilianHeliBuildingTypes","civilian helicopter installation",20],
                    ["ALIVE_militaryParkingBuildingTypes","military logistics building",20],
                    ["ALIVE_civilianCommsBuildingTypes","communications site",30],
					["ALIVE_civilianHQBuildingTypes","civilian HQ building",50],
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

        // select the random text
        _dialogOptions = [ALIVE_generatedTasks,"SabotageBuilding"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        _dialogOption = _dialogOptions call BIS_fnc_selectRandom;

        // format the dialog options
        private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

        _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

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
        _taskSource = format["%1-SabotageBuilding-Parent",_taskID];

		_taskTitle = format[_taskTitle,_nearestTown];
        _taskDescription = format[_taskDescription,_nearestTown,_buildingType];
        _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

        _tasks set [count _tasks,_newTask];
        _taskIDs set [count _taskIDs,_taskID];

        // create the destroy task
        _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;
        
        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _newTaskID = format["%1_c2",_taskID];
        _taskSource = format["%1-SabotageBuilding-Destroy",_taskID];
        
        _taskTitle = format[_taskTitle,_buildingType];
        _taskDescription = format[_taskDescription,_nearestTown,_targetDisplayType,_buildingType];
        
        _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

        _tasks set [count _tasks,_newTask];
        _taskIDs set [count _taskIDs,_newTaskID];




        // store task data in the params for this task set
        _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams,"targets",[_targetBuilding]] call ALIVE_fnc_hashSet;
        [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;

        // return the created tasks and params
        _result = [_tasks,_taskParams];
	};
	case "Parent":{

    };
    case "Destroy":{

        private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
        "_entityProfiles","_entitiesState","_allDestroyed","_lastState","_taskDialog","_vehicles","_currentTaskDialog","_taskEnemyFaction","_taskEnemySide"];

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
        _targets = [_params,"targets"] call ALIVE_fnc_hashGet;

        if(_lastState != "Destroy") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Destroy"] call ALIVE_fnc_hashSet;
        };

        _targetsState = [_targets] call ALIVE_fnc_taskGetStateOfObjects;
        _allDestroyed = [_targetsState,"allDestroyed"] call ALIVE_fnc_hashGet;

        if(_allDestroyed) then {

            [_params,"nextTask",""] call ALIVE_fnc_hashSet;

            _task set [8,"Succeeded"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

            ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

        } else {

            private["_taskEnemyFaction","_taskEnemySide","_profiles","_position","_objectType"];

            _taskEnemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
            _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;

            _targets = [_targetsState,"targets"] call ALIVE_fnc_hashGet;

            {
                _position = getposATL _x;
                _objectType = getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName");
                [_position,_taskEnemySide,_taskPlayers,_taskID,"building",_objectType] call ALIVE_fnc_taskCreateMarkersForPlayers;

            } forEach _targets;
        };

    };
};

_result