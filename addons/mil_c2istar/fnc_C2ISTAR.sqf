//#define DEBUG_MODE_FULL
#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(C2ISTAR);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_C2ISTAR
Description:
command and control

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance

Examples:
[_logic, "debug", true] call ALiVE_fnc_PR;

See Also:
- <ALIVE_fnc_C2ISTARInit>

Author:
ARJay

Peer Reviewed:
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_C2ISTAR
#define MTEMPLATE "ALiVE_C2_%1"
#define DEFAULT_DEBUG false
#define DEFAULT_C2_ITEM "LaserDesignator"
#define DEFAULT_STATE "INIT"
#define DEFAULT_SIDE "WEST"
#define DEFAULT_FACTION "BLU_F"
#define DEFAULT_SELECTED_INDEX 0
#define DEFAULT_SELECTED_VALUE ""
#define DEFAULT_SCALAR 0
#define DEFAULT_TASKING_STATE [] call ALIVE_fnc_hashCreate
#define DEFAULT_TASKING_MARKER []
#define DEFAULT_TASKING_DESTINATION []
#define DEFAULT_TASKING_SOURCE "PLAYER"
#define DEFAULT_TASK_EDITING_DISABLED false
#define DEFAULT_TASK_REVISION ""
#define DEFAULT_TASK_ID ""
#define DEFAULT_FACTION ""

#define DEFAULT_GM_LIMIT "SIDE"

#define DEFAULT_SCOM_LIMIT "SIDE"

#define DEFAULT_DISPLAY_INTEL false
#define DEFAULT_INTEL_CHANCE "0.1"
#define DEFAULT_FRIENDLY_INTEL false
#define DEFAULT_FRIENDLY_INTEL_RADIUS 2000
#define DEFAULT_DISPLAY_PLAYER_SECTORS false
#define DEFAULT_DISPLAY_MIL_SECTORS false
#define DEFAULT_TRACEFILL "None"
#define DEFAULT_RUN_EVERY 120

// Display components
#define C2Tablet_CTRL_MainDisplay 70001

// sub menu generic
#define C2Tablet_CTRL_SubMenuBack 70006
#define C2Tablet_CTRL_SubMenuAbort 70010
#define C2Tablet_CTRL_Title 70007

// tasking
#define C2Tablet_CTRL_TaskPlayerList 70011
#define C2Tablet_CTRL_TaskSelectedPlayerTitle 70012
#define C2Tablet_CTRL_TaskSelectedPlayerList 70013
#define C2Tablet_CTRL_TaskSelectGroupButton 70014
#define C2Tablet_CTRL_TaskSelectedPlayerListDeleteButton 70015
#define C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton 70016
#define C2Tablet_CTRL_TaskSelectedPlayersClearButton 70029
#define C2Tablet_CTRL_TaskAddTitleEditTitle 70018
#define C2Tablet_CTRL_TaskAddTitleEdit 70019
#define C2Tablet_CTRL_TaskAddDescriptionEditTitle 70020
#define C2Tablet_CTRL_TaskAddDescriptionEdit 70021
#define C2Tablet_CTRL_TaskAddStateEditTitle 70030
#define C2Tablet_CTRL_TaskAddStateEdit 70031
#define C2Tablet_CTRL_TaskAddMap 70022
#define C2Tablet_CTRL_TaskAddCreateButton 70023
#define C2Tablet_CTRL_TaskCurrentList 70025
#define C2Tablet_CTRL_TaskCurrentListEditButton 70026
#define C2Tablet_CTRL_TaskCurrentListDeleteButton 70027
#define C2Tablet_CTRL_TaskEditUpdateButton 70028
#define C2Tablet_CTRL_TaskEditManagePlayersButton 70032
#define C2Tablet_CTRL_TaskAddApplyTitle 70033
#define C2Tablet_CTRL_TaskAddApplyEdit 70034
#define C2Tablet_CTRL_TaskAddCurrentTitle 70035
#define C2Tablet_CTRL_TaskAddCurrentEdit 70036
#define C2Tablet_CTRL_TaskAddStatusText 70037
#define C2Tablet_CTRL_TaskGenerateButton 70038
#define C2Tablet_CTRL_TaskAddParentTitle 70039
#define C2Tablet_CTRL_TaskAddParentEdit 70040
#define C2Tablet_CTRL_TaskGenerateTypeTitle 70041
#define C2Tablet_CTRL_TaskGenerateTypeEdit 70042
#define C2Tablet_CTRL_TaskGenerateCreateButton 70043
#define C2Tablet_CTRL_TaskGenerateLocationTitle 70044
#define C2Tablet_CTRL_TaskGenerateLocationEdit 70045
#define C2Tablet_CTRL_TaskGenerateFactionTitle 70046
#define C2Tablet_CTRL_TaskGenerateFactionEdit 70047
#define C2Tablet_CTRL_TaskAutoGenerateButton 70048
#define C2Tablet_CTRL_TaskAutoGenerateFactionTitle 70049
#define C2Tablet_CTRL_TaskAutoGenerateFactionEdit 70050
#define C2Tablet_CTRL_TaskAutoGenerateCreateButton 70051
#define C2Tablet_CTRL_TaskGenerateApplyTitle 70052
#define C2Tablet_CTRL_TaskGenerateApplyEdit 70053
#define C2Tablet_CTRL_TaskGenerateCurrentTitle 70054
#define C2Tablet_CTRL_TaskGenerateCurrentEdit 70055


// Control Macros
#define C2_getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)
#define C2_getSelData(ctrl) (lbData[##ctrl,(lbCurSel ##ctrl)])


private ["_result"];

TRACE_1("C2ISTAR - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

switch(_operation) do {
	default {
		_result = [_logic, _operation, _args] call SUPERCLASS;
	};
	case "destroy": {
		if (isServer) then {
			// if server
			_logic setVariable ["super", nil];
			_logic setVariable ["class", nil];

			[_logic, "destroy"] call SUPERCLASS;
		};
	};

    case "debug": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["debug", _args];
        } else {
            _args = _logic getVariable ["debug", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["debug", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "persistent": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["persistent", _args];
        } else {
            _args = _logic getVariable ["persistent", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["persistent", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
	case "c2_item": {
        _result = [_logic,_operation,_args,DEFAULT_C2_ITEM] call ALIVE_fnc_OOsimpleOperation;
    };
    case "autoGenerateBlufor": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["autoGenerateBlufor", _args];
        } else {
            _args = _logic getVariable ["autoGenerateBlufor", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["autoGenerateBlufor", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "autoGenerateBluforFaction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "autoGenerateBluforEnemyFaction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "autoGenerateIndfor": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["autoGenerateIndfor", _args];
        } else {
            _args = _logic getVariable ["autoGenerateIndfor", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["autoGenerateIndfor", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "autoGenerateIndforFaction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "autoGenerateIndforEnemyFaction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "autoGenerateOpfor": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["autoGenerateOpfor", _args];
        } else {
            _args = _logic getVariable ["autoGenerateOpfor", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["autoGenerateOpfor", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "autoGenerateOpforFaction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "autoGenerateOpforEnemyFaction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "gmLimit": {
        _result = [_logic,_operation,_args,DEFAULT_GM_LIMIT,["SIDE","FACTION"]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "scomOpsLimit": {
        _result = [_logic,_operation,_args,DEFAULT_SCOM_LIMIT,["SIDE","FACTION","ALL"]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "scomOpsAllowSpectate": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["scomOpsAllowSpectate", _args];
        } else {
            _args = _logic getVariable ["scomOpsAllowSpectate", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["scomOpsAllowSpectate", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "scomOpsAllowInstantJoin": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["scomOpsAllowInstantJoin", _args];
        } else {
            _args = _logic getVariable ["scomOpsAllowInstantJoin", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["scomOpsAllowInstantJoin", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "scomIntelLimit": {
        _result = [_logic,_operation,_args,DEFAULT_SCOM_LIMIT,["SIDE","FACTION","ALL"]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "displayIntel": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["displayIntel", _args];
        } else {
            _args = _logic getVariable ["displayIntel", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["displayIntel", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "intelChance": {
        _result = [_logic,_operation,_args,DEFAULT_INTEL_CHANCE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "friendlyIntel": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["friendlyIntel", _args];
        } else {
            _args = _logic getVariable ["friendlyIntel", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["friendlyIntel", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "friendlyIntelRadius": {
        if (typeName _args == "SCALAR") then {
            _logic setVariable ["friendlyIntelRadius", DEFAULT_FRIENDLY_INTEL_RADIUS];
        } else {
            _args = _logic getVariable ["friendlyIntelRadius", DEFAULT_FRIENDLY_INTEL_RADIUS];
        };
        if (typeName _args == "STRING") then {
            _logic setVariable ["friendlyIntelRadius", parseNumber _args];
        };

        _result = _args;
    };
    case "displayPlayerSectors": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["displayPlayerSectors", _args];
        } else {
            _args = _logic getVariable ["displayPlayerSectors", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["displayPlayerSectors", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "displayMilitarySectors": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["displayMilitarySectors", _args];
        } else {
            _args = _logic getVariable ["displayMilitarySectors", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["displayMilitarySectors", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    case "displayTraceGrid": {
        _result = [_logic,_operation,_args,DEFAULT_TRACEFILL] call ALIVE_fnc_OOsimpleOperation;
    };    

    case "runEvery": {
        if(typeName _args == "STRING") then {
            _args = parseNumber(_args);
        };
        if(typeName _args == "SCALAR") then {
            _args = floor(_args * 60);
            _logic setVariable ["runEvery", _args];
        };
        _result = _logic getVariable ["runEvery", DEFAULT_RUN_EVERY];
        if(_result < 10) then {
            _result = floor(_result * 60);
        };
    };


	case "state": {
        _result = [_logic,_operation,_args,DEFAULT_STATE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "side": {
        _result = [_logic,_operation,_args,DEFAULT_SIDE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };

    case "taskingState": {
        _result = [_logic,_operation,_args,DEFAULT_TASKING_STATE] call ALIVE_fnc_OOsimpleOperation;
    };

    case "taskMarker": {
        _result = [_logic,_operation,_args,DEFAULT_TASKING_MARKER] call ALIVE_fnc_OOsimpleOperation;
    };
    case "taskDestination": {
        _result = [_logic,_operation,_args,DEFAULT_TASKING_DESTINATION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "taskSource": {
        _result = [_logic,_operation,_args,DEFAULT_TASKING_SOURCE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "taskEditingDisabled": {
        _result = [_logic,_operation,_args,DEFAULT_TASK_EDITING_DISABLED] call ALIVE_fnc_OOsimpleOperation;
    };
    case "taskRevision": {
        _result = [_logic,_operation,_args,DEFAULT_TASK_REVISION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "taskID": {
        _result = [_logic,_operation,_args,DEFAULT_TASK_ID] call ALIVE_fnc_OOsimpleOperation;
    };


	case "init": {

        //Only one init per instance is allowed
    	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE MIL C2ISTAR - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

    	//Start init
        _logic setVariable ["initGlobal", false];

        private["_debug"];

        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];
        _logic setVariable ["moduleType", "ALIVE_C2ISTAR"];
        _logic setVariable ["startupComplete", false];

        _debug = [_logic, "debug"] call MAINCLASS;

        ALIVE_MIL_C2ISTAR = _logic;

        // Call SITREP and PATROLREP
        [] spawn ALIVE_fnc_sitrepInit;
        [] spawn ALIVE_fnc_patrolrepInit;

        private["_gmLimit","_gm"];

        _gmLimit = [_logic, "gmLimit"] call MAINCLASS;

        _gm = [nil, "create"] call ALIVE_fnc_GM;
        [_gm, "limit", _gmLimit] call ALIVE_fnc_GM;
        [_gm, "debug", _debug] call ALIVE_fnc_GM;
        [_gm, "init",[]] call ALIVE_fnc_GM;

        private["_scomOpsLimit","_scomIntelLimit","_scom"];

        _scomOpsLimit = [_logic, "scomOpsLimit"] call MAINCLASS;
        _scomIntelLimit = [_logic, "scomIntelLimit"] call MAINCLASS;
        _scomOpsAllowSpectate = [_logic, "scomOpsAllowSpectate"] call MAINCLASS;
        _scomOpsAllowJoin = [_logic, "scomOpsAllowInstantJoin"] call MAINCLASS;

        _scom = [nil, "create"] call ALIVE_fnc_SCOM;
        [_scom, "opsLimit", _scomOpsLimit] call ALIVE_fnc_SCOM;
        [_scom, "intelLimit", _scomIntelLimit] call ALIVE_fnc_SCOM;
        [_scom, "scomOpsAllowSpectate", _scomOpsAllowSpectate] call ALIVE_fnc_SCOM;
        [_scom, "scomOpsAllowInstantJoin", _scomOpsAllowJoin] call ALIVE_fnc_SCOM;
        [_scom, "debug", _debug] call ALIVE_fnc_SCOM;
        [_scom, "init",[]] call ALIVE_fnc_SCOM;

        if (isServer) then {

            private["_persistent"];

            _persistent = [_logic,"persistent"] call MAINCLASS;

            // create the task handler
            ALIVE_taskHandler = [] call ALiVE_fnc_HashCreate;
            [ALIVE_taskHandler, "init"] call ALIVE_fnc_taskHandler;
            [ALIVE_taskHandler, "debug", _debug] call ALIVE_fnc_taskHandler;

            if(_persistent) then {
                [ALIVE_taskHandler, "loadTaskData", _persistent] call ALIVE_fnc_taskHandler;
            };

            [_logic] spawn {

                private["_logic","_autoGenerateBLUFOR","_autoGenerateBLUFORFaction","_autoGenerateBLUFOREnemyFaction",
                "_autoGenerateOPFOR","_autoGenerateOPFORFaction","_autoGenerateOPFOREnemyFaction",
                "_autoGenerateINDFOR","_autoGenerateINDFORFaction","_autoGenerateINDFOREnemyFaction"];

                _logic = _this select 0;

                _autoGenerateBLUFOR = [_logic, "autoGenerateBlufor"] call MAINCLASS;
                _autoGenerateBLUFORFaction = [_logic, "autoGenerateBluforFaction"] call MAINCLASS;
                _autoGenerateBLUFOREnemyFaction = [_logic, "autoGenerateBluforEnemyFaction"] call MAINCLASS;

                _autoGenerateOPFOR = [_logic, "autoGenerateOpfor"] call MAINCLASS;
                _autoGenerateOPFORFaction = [_logic, "autoGenerateOpforFaction"] call MAINCLASS;
                _autoGenerateOPFOREnemyFaction = [_logic, "autoGenerateOpforEnemyFaction"] call MAINCLASS;

                _autoGenerateINDFOR = [_logic, "autoGenerateIndfor"] call MAINCLASS;
                _autoGenerateINDFORFaction = [_logic, "autoGenerateIndforFaction"] call MAINCLASS;
                _autoGenerateINDFOREnemyFaction = [_logic, "autoGenerateIndforEnemyFaction"] call MAINCLASS;

                sleep 120;

                if(_autoGenerateBLUFOR) then {

                    _taskData = [];
                    _taskData set [0,"BLUFOR_TASK1"];
                    _taskData set [1,"1"];
                    _taskData set [2,"WEST"];
                    _taskData set [3,_autoGenerateBLUFORFaction];
                    _taskData set [4,_autoGenerateBLUFOREnemyFaction];
                    _taskData set [5,true];

                    [ALIVE_taskHandler, "autoGenerateTasks", _taskData] call ALIVE_fnc_taskHandler;
                };

                if(_autoGenerateOPFOR) then {

                    _taskData = [];
                    _taskData set [0,"OPFOR_TASK1"];
                    _taskData set [1,"1"];
                    _taskData set [2,"EAST"];
                    _taskData set [3,_autoGenerateOPFORFaction];
                    _taskData set [4,_autoGenerateOPFOREnemyFaction];
                    _taskData set [5,true];

                    [ALIVE_taskHandler, "autoGenerateTasks", _taskData] call ALIVE_fnc_taskHandler;
                };

                if(_autoGenerateINDFOR) then {

                    _taskData = [];
                    _taskData set [0,"INDFOR_TASK1"];
                    _taskData set [1,"1"];
                    _taskData set [2,"GUER"];
                    _taskData set [3,_autoGenerateINDFORFaction];
                    _taskData set [4,_autoGenerateINDFOREnemyFaction];
                    _taskData set [5,true];

                    [ALIVE_taskHandler, "autoGenerateTasks", _taskData] call ALIVE_fnc_taskHandler;
                };
            };

            private["_displayIntel","_intelChance","_friendlyIntel","_friendlyIntelRadius","_displayMilitarySectors","_displayPlayerSectors","_displayIntel","_runEvery","_intel"];

            _displayIntel = [_logic, "displayIntel"] call MAINCLASS;
            _intelChance = [_logic, "intelChance"] call MAINCLASS;
            _friendlyIntel = [_logic, "friendlyIntel"] call MAINCLASS;
            _friendlyIntelRadius = [_logic, "friendlyIntelRadius"] call MAINCLASS;
            _displayMilitarySectors = [_logic, "displayMilitarySectors"] call MAINCLASS;
            _displayPlayerSectors = [_logic, "displayPlayerSectors"] call MAINCLASS;
            _runEvery = [_logic, "runEvery"] call MAINCLASS;

            if(typeName _friendlyIntelRadius == "STRING") then {
                _friendlyIntelRadius = parseNumber _friendlyIntelRadius;
            };

            if(_displayIntel || _displayPlayerSectors || _displayMilitarySectors || _friendlyIntel) then {

                _intel = [nil, "create"] call ALIVE_fnc_militaryIntel;
                [_intel, "displayIntel",_displayIntel] call ALIVE_fnc_militaryIntel;
                [_intel, "intelChance",_intelChance] call ALIVE_fnc_militaryIntel;
                [_intel, "friendlyIntel",_friendlyIntel] call ALIVE_fnc_militaryIntel;
                [_intel, "friendlyIntelRadius",_friendlyIntelRadius] call ALIVE_fnc_militaryIntel;
                [_intel, "displayMilitarySectors",_displayMilitarySectors] call ALIVE_fnc_militaryIntel;
                [_intel, "displayPlayerSectors",_displayPlayerSectors] call ALIVE_fnc_militaryIntel;
                [_intel, "runEvery",_runEvery] call ALIVE_fnc_militaryIntel;
                [_intel, "init"] call ALIVE_fnc_militaryIntel;

            };
            
            // T.R.A.C.E. System
            private ["_grid","_markerType","_displayTraceGrid"];
            
            _displayTraceGrid = [_logic, "displayTraceGrid"] call MAINCLASS;
            
            if !(_displayTraceGrid == "None") then {

                _grid = _logic getvariable "grid";

	            if (isnil "_grid") then {
	                _grid = [getposATL _logic, 30000, _displayTraceGrid] call ALiVE_fnc_createTraceGrid;
	                _logic setvariable ["grid",_grid];

	                [_grid,_displayTraceGrid] spawn {

	                    waituntil {
	                        sleep 30;
	                        [_this select 0,_this select 1] call ALiVE_fnc_updateTraceGrid;

	                    	isnil {MOD(MIL_C2ISTAR) getvariable "grid"};
	                 	};
	                 };
	            };
            } else {
                _grid = _logic getvariable ["grid",[]];

                {deleteMarker _x} foreach _grid;

                _logic setvariable ["grid",nil];
            };            
        };


        if (hasInterface) then {

            _logic setVariable ["startupComplete", true];

            private ["_file"];

            // create the client task handler
            ALIVE_taskHandlerClient = [] call ALiVE_fnc_HashCreate;
            [ALIVE_taskHandlerClient, "init"] call ALIVE_fnc_taskHandlerClient;

            // load static data
            if(isNil "ALiVE_STATIC_DATA_LOADED") then {
                _file = "\x\alive\addons\main\static\staticData.sqf";
                call compile preprocessFileLineNumbers _file;
            };

            // set the player side

            private ["_playerSide","_sideNumber","_sideText","_playerFaction"];

            waitUntil {
                sleep 1;
                ((str side player) != "UNKNOWN")
            };

            _playerSide = side player;
            _sideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
            _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;

            if(_sideText == "CIV") then {
                _playerFaction = faction player;
                _playerSide = _playerFaction call ALiVE_fnc_factionSide;
                _sideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
                _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;
            };

            [_logic,"side",_sideText] call MAINCLASS;


            // set the player faction

            _playerFaction = faction player;

            [_logic,"faction",_playerFaction] call MAINCLASS;


            // set the tasking state

             private ["_generateOptions","_generateValues","_task"];

            _generateOptions = [];
            _generateValues = [];
            {
                _task = [ALIVE_generatedTasks,_x] call ALIVE_fnc_hashGet;
                _generateOptions set [count _generateOptions,_task select 0];
                _generateValues set [count _generateValues,_x];
            } forEach (ALIVE_generatedTasks select 1);

            private ["_taskingState","_playerListOptions","_playerListValues","_factionsDataSource"];

            _taskingState = [_logic,"taskingState"] call MAINCLASS;

            [_taskingState,"playerListOptions",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"playerListValues",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"playerListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"playerListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"selectedPlayerListOptions",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"selectedPlayerListValues",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"selectedPlayerListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"selectedPlayerListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"currentTaskListOptions",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskListValues",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"currentTaskParentOptions",["None"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskParentValues",["None"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskParentSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskParentSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"currentTaskStateOptions",["Created","Assigned","Succeeded","Failed","Canceled"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskStateValues",["Created","Assigned","Succeeded","Failed","Canceled"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskStateSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskStateSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"currentTaskApplyOptions",["Apply only to the assigned individuals","Apply to all current and JIP members of assigned groups","Apply to all players on my side"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskApplyValues",["Individual","Group","Side"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskApplySelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskApplySelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"currentTaskCurrentOptions",["Yes","No"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskCurrentValues",["Y","N"]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskCurrentSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskCurrentSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"currentTaskPlayerListOptions",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskPlayerListValues",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskPlayerListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskPlayerListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"currentTaskSelectedPlayerListOptions",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskSelectedPlayerListValues",[]] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskSelectedPlayerListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"currentTaskSelectedPlayerListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"generateTypeOptions",_generateOptions] call ALIVE_fnc_hashSet;
            [_taskingState,"generateTypeValues",_generateValues] call ALIVE_fnc_hashSet;
            [_taskingState,"generateTypeListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"generateTypeListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"generateLocationOptions",["From Map Selection","Short Distance","Medium Distance","Long Distance"]] call ALIVE_fnc_hashSet;
            [_taskingState,"generateLocationValues",["Map","Short","Medium","Long"]] call ALIVE_fnc_hashSet;
            [_taskingState,"generateLocationListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"generateLocationListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            _factionsDataSource = [] call ALiVE_fnc_getFactionsDataSource;
            [_taskingState,"generateFactionOptions",_factionsDataSource select 0] call ALIVE_fnc_hashSet;
            [_taskingState,"generateFactionValues",_factionsDataSource select 1] call ALIVE_fnc_hashSet;
            [_taskingState,"generateFactionListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
            [_taskingState,"generateFactionListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

            [_taskingState,"autoGenerateTasks",false] call ALIVE_fnc_hashSet;
            [_taskingState,"autoGenerateTasksFactionValue",""] call ALIVE_fnc_hashSet;

            [_logic,"taskingState",_taskingState] call MAINCLASS;


            // Initialise interaction key if undefined
            TRACE_2("Menu pre-req",SELF_INTERACTION_KEY,ALIVE_fnc_logisticsMenuDef);

            // Initialise main menu
            [
                    "player",
                    [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                    -9500,
                    [
                            "call ALIVE_fnc_C2MenuDef",
                            "main"
                    ]
            ] call ALiVE_fnc_flexiMenu_Add;
        };

        [_logic, "start"] call MAINCLASS;

	};
	case "start": {

        // set module as startup complete
        _logic setVariable ["startupComplete", true];

        if(isServer) then {

            // start listening for events
            [_logic,"listen"] call MAINCLASS;

        };

	};
	case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["TASKS_UPDATED"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };
    case "handleEvent": {

        private["_event","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;

            // a response event from task handler has been received.
            // if the we are a dedicated server,
            // dispatch the event to the player who requested it
            if((isServer && isMultiplayer) || isDedicated) then {

                private ["_eventData","_playerID","_player"];

                _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

                _playerID = _eventData select 0;

                _player = [_playerID] call ALIVE_fnc_getPlayerByUID;

                if !(isNull _player) then {
                    _event remoteExec ["ALIVE_fnc_C2TabletEventToClient", _player];
                };

            }else{

                // the player is the server

                [_logic, "handleServerResponse", _event] call MAINCLASS;

            };

        };
    };
    case "handleServerResponse": {

        // event handler for response from server
        // events

        private["_event","_eventData","_type"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            switch(_type) do {
                case "TASKS_UPDATED": {

                    private["_taskState"];

                    _taskState = _eventData select 1;

                    [_logic,"updateCurrentTaskList",_taskState] call MAINCLASS;

                };
            };
        };

    };
	case "tabletOnLoad": {

        // on load of the tablet
        // restore state

        if (hasInterface) then {

            [_logic] spawn {

                private ["_logic","_state"];

                _logic = _this select 0;

                disableSerialization;

                [_logic,"disableAll"] call MAINCLASS;

                sleep 0.5;

                _state = [_logic,"state"] call MAINCLASS;

                switch(_state) do {

                    case "INIT":{

                        // the interface is opened
                        // for the first time

                        [_logic,"enableTasking"] call MAINCLASS;

                        [_logic,"loadInitialData"] call MAINCLASS;

                    };

                };

                // Hide GPS
                showGPS false;

            };

        };

    };
    case "tabletOnUnLoad": {

        // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
        if (hasInterface) then {

            private ["_markers"];

            // Show GPS
            showGPS true;

            _markers = [_logic,"taskMarker"] call MAINCLASS;

            if(count _markers > 0) then {
                deleteMarkerLocal (_markers select 0);
            };

        };

    };
	case "tabletOnAction": {

	    // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
        if (hasInterface) then {

            if (isnil "_args") exitwith {};

            private ["_action"];

            _action = _args select 0;
            _args = _args select 1;

            switch(_action) do {

                case "OPEN": {

                    createDialog "C2Tablet";

                };

                case "TASK_ADD_BUTTON_CLICK": {

                    [_logic,"disableTasking"] call MAINCLASS;
                    [_logic,"enableAddTask"] call MAINCLASS;

                };

                case "TASK_ADD_BACK_BUTTON_CLICK": {

                    [_logic,"disableAddTask"] call MAINCLASS;
                    [_logic,"enableTasking"] call MAINCLASS;
                };

                case "TASK_ADD_STATE_LIST_SELECT": {

                    private ["_taskingState","_stateList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _stateList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"currentTaskStateOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskStateValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"currentTaskStateSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskStateSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;
                };

                case "TASK_ADD_APPLY_LIST_SELECT": {

                    private ["_taskingState","_stateList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _stateList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"currentTaskApplyOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskApplyValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"currentTaskApplySelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskApplySelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;
                };

                case "TASK_ADD_CURRENT_LIST_SELECT": {

                    private ["_taskingState","_currentList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _currentList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"currentTaskCurrentOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskCurrentValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"currentTaskCurrentSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskCurrentSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;
                };

                case "TASK_ADD_PARENT_LIST_SELECT": {

                    private ["_taskingState","_currentList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _currentList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"currentTaskParentOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskParentValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"currentTaskParentSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskParentSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;
                };

                case "TASK_ADD_CREATE_BUTTON_CLICK": {

                    private ["_taskingState","_titleEdit","_descriptionEdit","_title","_description","_marker","_destination",
                    "_side","_faction","_selectedPlayers","_selectedPlayersValues","_selectedPlayersOptions","_event","_requestID",
                    "_playerID","_state","_apply","_current","_parent","_statusText","_errors","_errorMessage","_source","_editingDisabled",
                    "_rev","_id","_newSelectedPlayerValues","_newSelectedPlayerOptions"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _titleEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEdit);
                    _descriptionEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEdit);

                    _title = ctrlText _titleEdit;
                    _description = ctrlText _descriptionEdit;

                    _side = [_logic,"side"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;
                    _marker = [_logic,"taskMarker"] call MAINCLASS;
                    _destination = [_logic,"taskDestination"] call MAINCLASS;
                    _source = "PLAYER";
                    _editingDisabled = false;

                    _state = [_taskingState,"currentTaskStateSelectedValue"] call ALIVE_fnc_hashGet;
                    _apply = [_taskingState,"currentTaskApplySelectedValue"] call ALIVE_fnc_hashGet;
                    _current = [_taskingState,"currentTaskCurrentSelectedValue"] call ALIVE_fnc_hashGet;
                    _parent = [_taskingState,"currentTaskParentSelectedValue"] call ALIVE_fnc_hashGet;

                    _rev = "";
                    _id = "";

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _selectedPlayers = [];
                    _selectedPlayersValues = [_taskingState,"selectedPlayerListValues"] call ALIVE_fnc_hashGet;
                    _selectedPlayersOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;

                    _newSelectedPlayerValues = [];
                    _newSelectedPlayerOptions = [];

                    _newSelectedPlayerValues = _newSelectedPlayerValues + _selectedPlayersValues;
                    _newSelectedPlayerOptions = _newSelectedPlayerOptions + _selectedPlayersOptions;

                    _selectedPlayers set [0, _newSelectedPlayerValues];
                    _selectedPlayers set [1, _newSelectedPlayerOptions];

                    _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);

                    _errors = false;

                    if(count _newSelectedPlayerOptions == 0) then {
                        _errors = true;
                        _errorMessage = "You need to select some players";
                    };

                    if(count _destination == 0) then {
                        _errors = true;
                        _errorMessage = "You need to select a destination";
                    };

                    if(_state == "") then {
                        _errors = true;
                        _errorMessage = "You need to select a task state";
                    };

                    if(_apply == "") then {
                        _errors = true;
                        _errorMessage = "You need to select task application";
                    };

                    if(_current == "") then {
                        _errors = true;
                        _errorMessage = "You need to select if task is current";
                    };

                    if(_parent == "") then {
                        _errors = true;
                        _errorMessage = "You need to select if task has a parent";
                    };

                    if(_errors) then {

                        _statusText ctrlSetText _errorMessage;
                        _statusText ctrlSetTextColor [0.729,0.216,0.235,1];

                    }else{

                        _event = ['TASK_CREATE', [_requestID,_playerID,_side,_destination,_faction,_title,_description,_selectedPlayers,_state,_apply,_current,_parent,_source,_editingDisabled,_rev,_id], "C2ISTAR"] call ALIVE_fnc_event;

                        if(isServer) then {
                            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                        }else{
                            [_event] remoteExec ["ALIVE_fnc_addEventToServer", 2];
                            //["server","ALIVE_ADD_EVENT",[[_event],"ALIVE_fnc_addEventToServer"]] call ALiVE_fnc_BUS;
                        };

                        [_logic,"disableAddTask"] call MAINCLASS;
                        [_logic,"enableTasking"] call MAINCLASS;

                    };
                };

                case "TASK_ADD_MAP_CLICK": {

                    private ["_button","_posX","_posY","_map","_position","_markers","_marker","_markerLabel","_selectedDeliveryValue"];

                    _button = _args select 0 select 1;
                    _posX = _args select 0 select 2;
                    _posY = _args select 0 select 3;

                    if(_button == 0) then {

                        _markers = [_logic,"taskMarker"] call MAINCLASS;

                        if(count _markers > 0) then {
                            deleteMarkerLocal (_markers select 0);
                        };

                        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);

                        _position = _map ctrlMapScreenToWorld [_posX, _posY];

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _position];
                        ctrlMapAnimCommit _map;

                        _marker = createMarkerLocal [format["%1%2",MTEMPLATE,"marker"],_position];
                        _marker setMarkerAlphaLocal 1;
                        _marker setMarkerTextLocal "Destination";
                        _marker setMarkerTypeLocal "hd_Objective";

                        [_logic,"taskMarker",[_marker]] call MAINCLASS;
                        [_logic,"taskDestination",_position] call MAINCLASS;
                    };

                };

                case "TASK_ADD_MAP_CLICK_NULL": {


                };

                case "TASK_ADD_MANAGE_PLAYERS_BUTTON_CLICK": {

                    [_logic,"disableAddTask"] call MAINCLASS;
                    [_logic,"enableAddTaskManagePlayers"] call MAINCLASS;

                };

                case "TASK_ADD_MANAGE_PLAYERS_BACK_BUTTON_CLICK": {

                    [_logic,"disableAddTaskManagePlayers"] call MAINCLASS;
                    [_logic,"enableAddTask"] call MAINCLASS;

                };

                case "TASK_PLAYER_LIST_SELECT": {

                    private ["_taskingState","_playerList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _playerList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"playerListOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"playerListValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"playerListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"playerListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;

                    _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
                    _selectedPlayersClearButton ctrlShow true;

                    _selectedPlayersClearButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_SELECTED_PLAYER_LIST_CLEAR_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

                    private ["_selectedPlayerListOptions","_selectedPlayerListValues","_selectedPlayerList"];

                    _selectedPlayerListOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _selectedPlayerListValues = [_taskingState,"selectedPlayerListValues"] call ALIVE_fnc_hashGet;

                    if!(_selectedOption in _selectedPlayerListOptions) then {

                        _selectedPlayerListOptions set [count _selectedPlayerListOptions,_selectedOption];
                        _selectedPlayerListValues set [count _selectedPlayerListValues,_selectedValue];

                        [_taskingState,"selectedPlayerListOptions",_selectedPlayerListOptions] call ALIVE_fnc_hashSet;
                        [_taskingState,"selectedPlayerListValues",_selectedPlayerListValues] call ALIVE_fnc_hashSet;

                        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);

                        _selectedPlayerList lbAdd format["%1", _selectedOption];

                        private ["_selectGroupButton"];

                        _selectGroupButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectGroupButton);
                        _selectGroupButton ctrlShow true;

                        _selectGroupButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_SELECT_GROUP_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

                        [_logic,"taskingState",_taskingState] call MAINCLASS;
                    };

                };

                case "TASK_SELECT_GROUP_BUTTON_CLICK": {

                    private ["_taskingState","_selectedIndex","_listValues","_selectedPlayerUID","_playersInGroup"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedIndex = [_taskingState,"playerListSelectedIndex"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"playerListValues"] call ALIVE_fnc_hashGet;

                    _selectedPlayerUID = _listValues select _selectedIndex;

                    _playersInGroup = [_selectedPlayerUID] call ALiVE_fnc_getPlayersInGroupDataSource;

                    if(count (_playersInGroup select 0) > 0) then {

                        private ["_selectedPlayerListOptions","_selectedPlayerListValues","_selectedPlayerList","_currentGroupPlayers","_currentGroupPlayerOptions","_currentGroupPlayerValues"];

                        _selectedPlayerListOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                        _selectedPlayerListValues = [_taskingState,"selectedPlayerListValues"] call ALIVE_fnc_hashGet;

                        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);

                        _currentGroupPlayerOptions = _playersInGroup select 0;
                        _currentGroupPlayerValues = _playersInGroup select 1;

                        {
                            if!(_x in _selectedPlayerListOptions) then {
                                _selectedPlayerListOptions set [count _selectedPlayerListOptions,_x];
                                _selectedPlayerList lbAdd format["%1", _x];
                            };
                        } forEach _currentGroupPlayerOptions;

                        {
                            if!(_x in _selectedPlayerListValues) then {
                                _selectedPlayerListValues set [count _selectedPlayerListValues,_x];
                            };
                        } forEach _currentGroupPlayerValues;

                        [_taskingState,"selectedPlayerListOptions",_selectedPlayerListOptions] call ALIVE_fnc_hashSet;
                        [_taskingState,"selectedPlayerListValues",_selectedPlayerListValues] call ALIVE_fnc_hashSet;
                    };

                };

                case "TASK_SELECTED_PLAYER_LIST_SELECT": {

                    private ["_taskingState","_selectedPlayerList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedPlayerList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"selectedPlayerListValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"selectedPlayerListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"selectedPlayerListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;

                    private ["_selectedPlayerListDeleteButton","_selectedPlayersClearButton"];

                    _selectedPlayerListDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerListDeleteButton);
                    _selectedPlayerListDeleteButton ctrlShow true;

                    _selectedPlayerListDeleteButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_SELECTED_PLAYER_LIST_DELETE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

                };

                case "TASK_SELECTED_PLAYER_LIST_DELETE_BUTTON_CLICK": {

                    private ["_taskingState","_deleteButton","_selectedPlayerList","_selectedIndex","_listOptions","_listValues","_delete","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

                     _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _deleteButton = _args select 0 select 0;
                    _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
                    _selectedIndex = lbCurSel _selectedPlayerList;
                    _listOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"selectedPlayerListValues"] call ALIVE_fnc_hashGet;

                    _listOptions set [_selectedIndex,"del"];
                    _listValues set [_selectedIndex,"del"];

                    _delete = ["del"];

                    _listOptions = _listOptions - _delete;
                    _listValues = _listValues - _delete;

                    [_taskingState,"selectedPlayerListOptions",_listOptions] call ALIVE_fnc_hashSet;
                    [_taskingState,"selectedPlayerListValues",_listValues] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    _selectedPlayerList lbDelete _selectedIndex;

                    _deleteButton ctrlShow false;

                    if(count _listOptions == 0) then {

                        _selectedPlayersAddTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton);
                        _selectedPlayersAddTaskButton ctrlShow false;

                        _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
                        _selectedPlayersClearButton ctrlShow false;

                    };

                };

                case "TASK_SELECTED_PLAYER_LIST_CLEAR_BUTTON_CLICK": {

                    private ["_taskingState","_selectedPlayerList","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);

                    [_taskingState,"selectedPlayerListOptions",[]] call ALIVE_fnc_hashSet;
                    [_taskingState,"selectedPlayerListValues",[]] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    lbClear _selectedPlayerList;

                    _selectedPlayersAddTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton);
                    _selectedPlayersAddTaskButton ctrlShow false;

                    _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
                    _selectedPlayersClearButton ctrlShow false;
                };

                case "TASK_CURRENT_TASK_LIST_SELECT": {

                    private ["_taskingState","_currentTaskList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _currentTaskList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"currentTaskListOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskListValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"currentTaskListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;

                    private ["_taskCurrentEditButton","_taskCurrentDeleteButton"];

                    _taskCurrentEditButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListEditButton);
                    _taskCurrentEditButton ctrlShow true;
                    _taskCurrentEditButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_CURRENT_EDIT_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

                    _taskCurrentDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListDeleteButton);
                    _taskCurrentDeleteButton ctrlShow true;
                    _taskCurrentDeleteButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_CURRENT_DELETE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

                };

                case "TASK_CURRENT_EDIT_BUTTON_CLICK": {

                    [_logic,"disableTasking"] call MAINCLASS;
                    [_logic,"enableEditTask"] call MAINCLASS;

                };

                case "TASK_CURRENT_DELETE_BUTTON_CLICK": {

                    private ["_taskingState","_currentTask","_taskID","_side","_playerID","_event"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _currentTask = [_taskingState,"currentTaskListSelectedValue"] call ALIVE_fnc_hashGet;

                    _side = [_logic,"side"] call MAINCLASS;
                    _playerID = getPlayerUID player;
                    _taskID = _currentTask select 0;

                    _event = ['TASK_DELETE', [_taskID,_playerID,_side], "C2ISTAR"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [_event] remoteExec ["ALIVE_fnc_addEventToServer", 2];
                        //["server","ALIVE_ADD_EVENT",[[_event],"ALIVE_fnc_addEventToServer"]] call ALiVE_fnc_BUS;
                    };

                    private ["_taskCurrentEditButton","_taskCurrentDeleteButton"];

                    _taskCurrentEditButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListEditButton);
                    _taskCurrentEditButton ctrlShow false;

                    _taskCurrentDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListDeleteButton);
                    _taskCurrentDeleteButton ctrlShow false;

                };

                case "TASK_EDIT_BACK_BUTTON_CLICK": {
                    [_logic,"disableEditTask"] call MAINCLASS;
                    [_logic,"enableTasking"] call MAINCLASS;
                };

                case "TASK_EDIT_BUTTON_CLICK": {

                    private ["_taskingState","_currentTask","_titleEdit","_descriptionEdit","_title","_description",
                    "_side","_faction","_marker","_destination","_selectedPlayers","_event","_taskID","_playerID","_state",
                    "_selectedPlayerListOptions","_selectedPlayerListValues","_apply","_current","_parent","_newSelectedPlayerListOptions",
                    "_newSelectedPlayerListValues","_statusText","_errors","_errorMessage","_source","_rev","_id","_editingDisabled"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _currentTask = [_taskingState,"currentTaskListSelectedValue"] call ALIVE_fnc_hashGet;

                    _titleEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEdit);
                    _descriptionEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEdit);

                    _title = ctrlText _titleEdit;
                    _description = ctrlText _descriptionEdit;

                    _side = [_logic,"side"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;
                    _marker = [_logic,"taskMarker"] call MAINCLASS;
                    _destination = [_logic,"taskDestination"] call MAINCLASS;
                    _source = [_logic,"taskSource"] call MAINCLASS;
                    _editingDisabled = [_logic,"taskEditingDisabled"] call MAINCLASS;
                    _rev = [_logic,"taskRevision"] call MAINCLASS;
                    _id = [_logic,"taskID"] call MAINCLASS;

                    _state = [_taskingState,"currentTaskStateSelectedValue"] call ALIVE_fnc_hashGet;
                    _apply = [_taskingState,"currentTaskApplySelectedValue"] call ALIVE_fnc_hashGet;
                    _current = [_taskingState,"currentTaskCurrentSelectedValue"] call ALIVE_fnc_hashGet;
                    _parent = [_taskingState,"currentTaskParentSelectedValue"] call ALIVE_fnc_hashGet;

                    _playerID = getPlayerUID player;
                    _taskID = _currentTask select 0;

                    _selectedPlayersValues = [_taskingState,"currentTaskSelectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _selectedPlayersOptions = [_taskingState,"currentTaskSelectedPlayerListValues"] call ALIVE_fnc_hashGet;

                    /*
                    _selectedPlayerListOptions = _currentTask select 7 select 1;
                    _selectedPlayerListValues = _currentTask select 7 select 0;
                    */

                    _newSelectedPlayerListOptions = [];
                    _newSelectedPlayerListOptions = _newSelectedPlayerListOptions + _selectedPlayersValues;

                    _newSelectedPlayerListValues = [];
                    _newSelectedPlayerListValues = _newSelectedPlayerListValues + _selectedPlayersOptions;

                    _selectedPlayers = [];
                    _selectedPlayers set [0, _newSelectedPlayerListValues];
                    _selectedPlayers set [1, _newSelectedPlayerListOptions];

                    _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);

                    _errors = false;
                    _errorMessage = "";

                    if(count _newSelectedPlayerOptions == 0) then {
                        _errors = true;
                        _errorMessage = "You need to select some players";
                    };

                    if(count _destination == 0) then {
                        _errors = true;
                        _errorMessage = "You need to select a destination";
                    };

                    if(_state == "") then {
                        _errors = true;
                        _errorMessage = "You need to select a task state";
                    };

                    if(_apply == "") then {
                        _errors = true;
                        _errorMessage = "You need to select task application";
                    };

                    if(_current == "") then {
                        _errors = true;
                        _errorMessage = "You need to select if task is current";
                    };

                    if(_parent == "") then {
                        _errors = true;
                        _errorMessage = "You need to select if task has a parent";
                    };

                    if(_errors) then {

                        _statusText ctrlSetText _errorMessage;
                        _statusText ctrlSetTextColor [0.729,0.216,0.235,1];

                    }else{

                        _event = ['TASK_UPDATE', [_taskID,_playerID,_side,_destination,_faction,_title,_description,_selectedPlayers,_state,_apply,_current,_parent,_source,_editingDisabled,_rev,_id], "C2ISTAR"] call ALIVE_fnc_event;

                        if(isServer) then {
                            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                        }else{
                            [_event] remoteExec ["ALIVE_fnc_addEventToServer", 2];
                            //["server","ALIVE_ADD_EVENT",[[_event],"ALIVE_fnc_addEventToServer"]] call ALiVE_fnc_BUS;
                        };

                        [_logic,"disableEditTask"] call MAINCLASS;
                        [_logic,"enableTasking"] call MAINCLASS;

                    };
                };

                case "TASK_EDIT_MANAGE_PLAYERS_BUTTON_CLICK": {

                    [_logic,"disableEditTask"] call MAINCLASS;
                    [_logic,"enableEditTaskManagePlayers"] call MAINCLASS;

                };

                case "TASK_EDIT_MANAGE_PLAYERS_BACK_BUTTON_CLICK": {

                    [_logic,"disableEditTaskManagePlayers"] call MAINCLASS;
                    [_logic,"enableEditTask"] call MAINCLASS;

                };

                case "TASK_EDIT_MANAGE_PLAYER_LIST_SELECT": {

                    private ["_taskingState","_playerList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _playerList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"currentTaskPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskPlayerListValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"currentTaskPlayerListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskPlayerListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;

                    private ["_selectedPlayerListOptions","_selectedPlayerListValues","_selectedPlayerList"];

                    _selectedPlayerListOptions = [_taskingState,"currentTaskSelectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _selectedPlayerListValues = [_taskingState,"currentTaskSelectedPlayerListValues"] call ALIVE_fnc_hashGet;

                    if!(_selectedOption in _selectedPlayerListOptions) then {

                        _selectedPlayerListOptions set [count _selectedPlayerListOptions,_selectedOption];
                        _selectedPlayerListValues set [count _selectedPlayerListValues,_selectedValue];

                        [_taskingState,"currentTaskSelectedPlayerListOptions",_selectedPlayerListOptions] call ALIVE_fnc_hashSet;
                        [_taskingState,"currentTaskSelectedPlayerListValues",_selectedPlayerListValues] call ALIVE_fnc_hashSet;

                        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);

                        _selectedPlayerList lbAdd format["%1", _selectedOption];

                        private ["_selectGroupButton"];

                        _selectGroupButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectGroupButton);
                        _selectGroupButton ctrlShow true;

                        _selectGroupButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_EDIT_MANAGER_SELECT_GROUP_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];
                    };
                };

                case "TASK_EDIT_MANAGER_SELECT_GROUP_BUTTON_CLICK": {

                    private ["_taskingState","_selectedIndex","_listValues","_selectedPlayerUID","_playersInGroup"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedIndex = [_taskingState,"currentTaskPlayerListSelectedIndex"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskPlayerListValues"] call ALIVE_fnc_hashGet;

                    _selectedPlayerUID = _listValues select _selectedIndex;

                    _playersInGroup = [_selectedPlayerUID] call ALiVE_fnc_getPlayersInGroupDataSource;

                    if(count (_playersInGroup select 0) > 0) then {

                        private ["_selectedPlayerListOptions","_selectedPlayerListValues","_selectedPlayerList","_currentGroupPlayers","_currentGroupPlayerOptions","_currentGroupPlayerValues"];

                        _selectedPlayerListOptions = [_taskingState,"currentTaskSelectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                        _selectedPlayerListValues = [_taskingState,"currentTaskSelectedPlayerListValues"] call ALIVE_fnc_hashGet;

                        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);

                        _currentGroupPlayerOptions = _playersInGroup select 0;
                        _currentGroupPlayerValues = _playersInGroup select 1;

                        {
                            if!(_x in _selectedPlayerListOptions) then {
                                _selectedPlayerListOptions set [count _selectedPlayerListOptions,_x];
                                _selectedPlayerList lbAdd format["%1", _x];
                            };
                        } forEach _currentGroupPlayerOptions;

                        {
                            if!(_x in _selectedPlayerListValues) then {
                                _selectedPlayerListValues set [count _selectedPlayerListValues,_x];
                            };
                        } forEach _currentGroupPlayerValues;

                        [_taskingState,"currentTaskSelectedPlayerListOptions",_selectedPlayerListOptions] call ALIVE_fnc_hashSet;
                        [_taskingState,"currentTaskSelectedPlayerListValues",_selectedPlayerListValues] call ALIVE_fnc_hashSet;
                    };

                };

                case "TASK_EDIT_MANAGE_SELECTED_PLAYER_LIST_SELECT": {

                    private ["_taskingState","_selectedPlayerList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedPlayerList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"currentTaskSelectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskSelectedPlayerListValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"currentTaskSelectedPlayerListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskSelectedPlayerListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;

                    private ["_selectedPlayerListDeleteButton","_selectedPlayersClearButton"];

                    _selectedPlayerListDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerListDeleteButton);
                    _selectedPlayerListDeleteButton ctrlShow true;

                    _selectedPlayerListDeleteButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_EDIT_MANAGE_PLAYERS_SELECTED_PLAYER_LIST_DELETE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];
                };

                case "TASK_EDIT_MANAGE_PLAYERS_SELECTED_PLAYER_LIST_DELETE_BUTTON_CLICK": {

                    private ["_taskingState","_currentTask","_currentTaskPlayers","_currentTaskPlayersOptions","_currentTaskPlayersValues","_deleteButton",
                    "_selectedPlayerList","_selectedIndex","_listOptions","_listValues","_delete","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _currentTask = [_taskingState,"currentTaskListSelectedValue"] call ALIVE_fnc_hashGet;
                    _currentTaskPlayers = _currentTask select 7;
                    _currentTaskPlayersOptions = _currentTaskPlayers select 1;
                    _currentTaskPlayersValues = _currentTaskPlayers select 0;

                    _deleteButton = _args select 0 select 0;
                    _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
                    _selectedIndex = lbCurSel _selectedPlayerList;
                    _listOptions = [_taskingState,"currentTaskSelectedPlayerListOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"currentTaskSelectedPlayerListValues"] call ALIVE_fnc_hashGet;

                    _listOptions set [_selectedIndex,"del"];
                    _listValues set [_selectedIndex,"del"];

                    _delete = ["del"];

                    _listOptions = _listOptions - _delete;
                    _listValues = _listValues - _delete;

                    [_taskingState,"currentTaskSelectedPlayerListOptions",_listOptions] call ALIVE_fnc_hashSet;
                    [_taskingState,"currentTaskSelectedPlayerListValues",_listValues] call ALIVE_fnc_hashSet;

                    _currentTaskPlayersValues = _currentTaskPlayersValues - _delete;
                    _currentTaskPlayersOptions = _currentTaskPlayersOptions - _delete;

                    _currentTaskPlayers set [0,_currentTaskPlayersValues];
                    _currentTaskPlayers set [1,_currentTaskPlayersOptions];

                    _currentTask set [7,_currentTaskPlayers];

                    [_taskingState,"currentTaskListSelectedValue",_currentTask] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    _selectedPlayerList lbDelete _selectedIndex;

                    _deleteButton ctrlShow false;
                };

                case "TASK_GENERATE_BUTTON_CLICK": {

                    [_logic,"disableTasking"] call MAINCLASS;
                    [_logic,"enableGenerateTask"] call MAINCLASS;

                };

                case "TASK_GENERATE_BACK_BUTTON_CLICK": {

                    [_logic,"disableGenerateTask"] call MAINCLASS;
                    [_logic,"enableTasking"] call MAINCLASS;
                };

                case "TASK_GENERATE_TYPE_LIST_SELECT": {

                    private ["_taskingState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"generateTypeOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"generateTypeValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"generateTypeListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"generateTypeListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;

                };

                case "TASK_GENERATE_LOCATION_LIST_SELECT": {

                    private ["_taskingState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"generateLocationOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"generateLocationValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"generateLocationListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"generateLocationListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;

                };

                case "TASK_GENERATE_FACTION_LIST_SELECT": {

                    private ["_taskingState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"generateFactionOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"generateFactionValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"generateFactionListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"generateFactionListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;
                };

                case "TASK_GENERATE_MAP_CLICK": {

                    private ["_button","_posX","_posY","_map","_position","_markers","_marker","_markerLabel","_selectedDeliveryValue"];

                    _button = _args select 0 select 1;
                    _posX = _args select 0 select 2;
                    _posY = _args select 0 select 3;

                    if(_button == 0) then {

                        _markers = [_logic,"taskMarker"] call MAINCLASS;

                        if(count _markers > 0) then {
                            deleteMarkerLocal (_markers select 0);
                        };

                        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);

                        _position = _map ctrlMapScreenToWorld [_posX, _posY];

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _position];
                        ctrlMapAnimCommit _map;

                        _marker = createMarkerLocal [format["%1%2",MTEMPLATE,"marker"],_position];
                        _marker setMarkerAlphaLocal 1;
                        _marker setMarkerTextLocal "Area of Operation";
                        _marker setMarkerTypeLocal "hd_Objective";

                        [_logic,"taskMarker",[_marker]] call MAINCLASS;
                        [_logic,"taskDestination",_position] call MAINCLASS;

                    };

                };

                case "TASK_GENERATE_MANAGE_PLAYERS_BUTTON_CLICK": {

                    [_logic,"disableGenerateTask"] call MAINCLASS;
                    [_logic,"enableGenerateTaskManagePlayers"] call MAINCLASS;

                };

                case "TASK_GENERATE_MANAGE_PLAYERS_BACK_BUTTON_CLICK": {

                    [_logic,"disableGenerateTaskManagePlayers"] call MAINCLASS;
                    [_logic,"enableGenerateTask"] call MAINCLASS;

                };

                case "TASK_GENERATE_CREATE_BUTTON_CLICK": {

                    private ["_taskingState","_side","_faction","_marker","_destination","_type","_location","_enemyFaction","_current","_apply","_selectedPlayers",
                    "_event","_taskID","_playerID","_requestID","_selectedPlayerListOptions","_selectedPlayerListValues",
                    "_newSelectedPlayerListOptions","_newSelectedPlayerListValues","_statusText","_errors","_errorMessage","_newSelectedPlayerValues","_newSelectedPlayerOptions"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _side = [_logic,"side"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;
                    _marker = [_logic,"taskMarker"] call MAINCLASS;
                    _destination = [_logic,"taskDestination"] call MAINCLASS;

                    _type = [_taskingState,"generateTypeListSelectedValue"] call ALIVE_fnc_hashGet;
                    _location = [_taskingState,"generateLocationListSelectedValue"] call ALIVE_fnc_hashGet;
                    _enemyFaction = [_taskingState,"generateFactionListSelectedValue"] call ALIVE_fnc_hashGet;
                    _apply = [_taskingState,"currentTaskApplySelectedValue"] call ALIVE_fnc_hashGet;
                    _current = [_taskingState,"currentTaskCurrentSelectedValue"] call ALIVE_fnc_hashGet;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _selectedPlayers = [];
                    _selectedPlayersValues = [_taskingState,"selectedPlayerListValues"] call ALIVE_fnc_hashGet;
                    _selectedPlayersOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;

                    _newSelectedPlayerValues = [];
                    _newSelectedPlayerOptions = [];

                    _newSelectedPlayerValues = _newSelectedPlayerValues + _selectedPlayersValues;
                    _newSelectedPlayerOptions = _newSelectedPlayerOptions + _selectedPlayersOptions;

                    _selectedPlayers set [0, _newSelectedPlayerValues];
                    _selectedPlayers set [1, _newSelectedPlayerOptions];

                    _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);

                    _errors = false;

                    if(count _newSelectedPlayerOptions == 0) then {
                        _errors = true;
                        _errorMessage = "You need to select some players";
                    };

                    if(_type == "") then {
                        _errors = true;
                        _errorMessage = "You need to select a task type";
                    };

                    if(_location == "") then {
                        _errors = true;
                        _errorMessage = "You need to select a location";
                    };

                    if(_enemyFaction == "") then {
                        _errors = true;
                        _errorMessage = "You need to select a faction";
                    };

                    if(_apply == "") then {
                        _errors = true;
                        _errorMessage = "You need to select task application";
                    };

                    if(_current == "") then {
                        _errors = true;
                        _errorMessage = "You need to select if task is current";
                    };

                    if(_errors) then {

                        _statusText ctrlSetText _errorMessage;
                        _statusText ctrlSetTextColor [0.729,0.216,0.235,1];

                    }else{

                        _event = ['TASK_GENERATE', [_requestID,_playerID,_side,_faction,_type,_location,_destination,_selectedPlayers,_enemyFaction,_current,_apply], "C2ISTAR"] call ALIVE_fnc_event;

                        if(isServer) then {
                            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                        }else{
                            [_event] remoteExec ["ALIVE_fnc_addEventToServer", 2];
                            //["server","ALIVE_ADD_EVENT",[[_event],"ALIVE_fnc_addEventToServer"]] call ALiVE_fnc_BUS;
                        };

                        [_logic,"disableGenerateTask"] call MAINCLASS;
                        [_logic,"enableTasking"] call MAINCLASS;

                    };

                };

                case "TASK_AUTO_GENERATE_BUTTON_CLICK": {

                    [_logic,"disableTasking"] call MAINCLASS;
                    [_logic,"enableAutoGenerateTasks"] call MAINCLASS;

                };

                case "TASK_AUTO_GENERATE_BACK_BUTTON_CLICK": {

                    [_logic,"disableAutoGenerateTasks"] call MAINCLASS;
                    [_logic,"enableTasking"] call MAINCLASS;
                };

                case "TASK_AUTO_GENERATE_FACTION_LIST_SELECT": {

                    private ["_taskingState","_selectedList","_selectedIndex","_listOptions","_listValues","_selectedOption","_selectedValue"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _selectedList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _listOptions = [_taskingState,"generateFactionOptions"] call ALIVE_fnc_hashGet;
                    _listValues = [_taskingState,"generateFactionValues"] call ALIVE_fnc_hashGet;
                    _selectedOption = _listOptions select _selectedIndex;
                    _selectedValue = _listValues select _selectedIndex;

                    [_taskingState,"generateFactionListSelectedIndex",_selectedIndex] call ALIVE_fnc_hashSet;
                    [_taskingState,"generateFactionListSelectedValue",_selectedValue] call ALIVE_fnc_hashSet;

                    [_logic,"taskingState",_taskingState] call MAINCLASS;

                    //_taskingState call ALIVE_fnc_inspectHash;
                };

                case "TASK_AUTO_GENERATE_CREATE_BUTTON_CLICK": {

                    private ["_taskingState","_side","_faction","_enemyFaction","_autoGenerate",
                    "_event","_taskID","_playerID","_requestID","_statusText","_errors","_errorMessage"];

                    _taskingState = [_logic,"taskingState"] call MAINCLASS;

                    _autoGenerate = [_taskingState,"autoGenerateTasks"] call ALIVE_fnc_hashGet;

                    if(_autoGenerate) then {
                        [_taskingState,"autoGenerateTasks",false] call ALIVE_fnc_hashSet;
                    }else{
                        [_taskingState,"autoGenerateTasks",true] call ALIVE_fnc_hashSet;
                    };

                    _autoGenerate = [_taskingState,"autoGenerateTasks"] call ALIVE_fnc_hashGet;

                    _side = [_logic,"side"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;

                    _enemyFaction = [_taskingState,"generateFactionListSelectedValue"] call ALIVE_fnc_hashGet;

                    _playerID = getPlayerUID player;
                    _requestID = format["%1_%2",_faction,floor(time)];

                    _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);

                    _errors = false;

                    if(_enemyFaction == "") then {
                        _errors = true;
                        _errorMessage = "You need to select a faction";
                    };

                    if(_errors) then {

                        _statusText ctrlSetText _errorMessage;
                        _statusText ctrlSetTextColor [0.729,0.216,0.235,1];

                    }else{

                        _event = ['TASKS_AUTO_GENERATE', [_requestID,_playerID,_side,_faction,_enemyFaction,_autoGenerate], "C2ISTAR"] call ALIVE_fnc_event;

                        [_taskingState,"autoGenerateTasksFactionValue",_enemyFaction] call ALIVE_fnc_hashSet;

                        if(isServer) then {
                            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                        }else{
                            [_event] remoteExec ["ALIVE_fnc_addEventToServer", 2];
                            //["server","ALIVE_ADD_EVENT",[[_event],"ALIVE_fnc_addEventToServer"]] call ALiVE_fnc_BUS;
                        };

                        [_logic,"disableAutoGenerateTasks"] call MAINCLASS;
                        [_logic,"enableTasking"] call MAINCLASS;

                    };

                };

            };

        };

    };
    case "loadInitialData": {

        private ["_side","_playerID","_event"];

        _side = [_logic,"side"] call MAINCLASS;
        _playerID = getPlayerUID player;

        ["C2 LOAD INIT DATA FOR SIDE: %1 PLAYER: %2",_side,_playerID] call ALIVE_fnc_dump;

        _event = ['TASKS_UPDATE', ["",_playerID,_side], "C2ISTAR"] call ALIVE_fnc_event;

        if(isServer) then {
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
        }else{
            //["server","ALIVE_ADD_EVENT",[[_event],"ALIVE_fnc_addEventToServer"]] call ALiVE_fnc_BUS;
            [_event] remoteExec ["ALIVE_fnc_addEventToServer", 2];
        };
    };
    case "updateCurrentTaskList": {

        private["_taskState","_autoGenerateState","_taskingState","_task","_newTask","_newPlayers","_newPlayerIDs","_newPlayerNames","_players",
        "_playerIDs","_playerNames","_title","_listOptions","_listValues","_parentListOptions","_parentListValues","_taskCurrentList",
        "_parent","_current","_currentText"];

        disableSerialization;

        _taskState = _args select 0;
        _autoGenerateState = _args select 1;

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        [_taskingState,"autoGenerateTasks",_autoGenerateState select 0] call ALIVE_fnc_hashSet;
        [_taskingState,"autoGenerateTasksFactionValue",_autoGenerateState select 1] call ALIVE_fnc_hashSet;

        _listOptions = [];
        _listValues = [];
        _parentListOptions = ["None"];
        _parentListValues = ["None"];

        {
            /*
            _taskID = _task select 0;
            _requestPlayerID = _task select 1;
            _side = _task select 2;
            _position = _task select 3;
            _faction = _task select 4;
            _title = _task select 5;
            _description = _task select 6;
            _players = _task select 7;
            _state = _task select 8;
            _applyType = _task select 9;
            _current = _task select 10;
            _parent = _task select 11;
            _source = _task select 12;
            _allowMapEditing = _task select 13;
            */

            _task = _x;
            _newTask = [];

            _newTask set [0,_task select 0];
            _newTask set [1,_task select 1];
            _newTask set [2,_task select 2];
            _newTask set [3,_task select 3];
            _newTask set [4,_task select 4];
            _newTask set [5,_task select 5];
            _newTask set [6,_task select 6];

            _newPlayers = [];
            _newPlayerIDs = [];
            _newPlayerNames = [];

            _players = _task select 7;
            _playerIDs = _players select 0;
            _playerNames = _players select 1;

            {
                _newPlayerIDs set [count _newPlayerIDs, _x];
            } forEach _playerIDs;

            {
                _newPlayerNames set [count _newPlayerNames, _x];
            } forEach _playerNames;

            _newPlayers set [0,_newPlayerIDs];
            _newPlayers set [1,_newPlayerNames];

            _newTask set [7,_newPlayers];
            _newTask set [8,_task select 8];
            _newTask set [9,_task select 9];
            _newTask set [10,_task select 10];
            _newTask set [11,_task select 11];
            _newTask set [12,_task select 12];
            _newTask set [13,_task select 13];

            if(count _task > 14) then {
                _newTask set [14,_task select 14];
                _newTask set [15,_task select 15];
            };

            _parent = _newTask select 11;
            _current = _newTask select 10;

            if(_current == "Y") then {
                _currentText = "- Active";
            }else{
                _currentText = "";
            };

            if(_parent == "NONE") then {
                _title = format["%1 - %2 %3",_newTask select 5,_newTask select 8,_currentText];
            }else{
                _title = format["-- %1 - %2 %3",_newTask select 5,_newTask select 8,_currentText];
            };

            _listOptions set [count _listOptions, _title];
            _listValues set [count _listValues, _newTask];

            _parentListOptions set [count _parentListOptions, _title];
            _parentListValues set [count _parentListValues, _newTask select 0];

        } foreach _taskState;

        [_taskingState,"currentTaskListOptions",_listOptions] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskListValues",_listValues] call ALIVE_fnc_hashSet;

        [_taskingState,"currentTaskParentOptions",_parentListOptions] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskParentValues",_parentListValues] call ALIVE_fnc_hashSet;

        _taskCurrentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentList);

        lbClear _taskCurrentList;

        {
            _taskCurrentList lbAdd format["%1", _x];
        } forEach _listOptions;

        _taskCurrentList ctrlSetEventHandler ["LBSelChanged", "['TASK_CURRENT_TASK_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

    };
    case "disableAll": {

        [_logic,"disableMainMenu"] call MAINCLASS;
        [_logic,"disableTasking"] call MAINCLASS;
        [_logic,"disableAAR"] call MAINCLASS;
        [_logic,"disableISTAR"] call MAINCLASS;
        [_logic,"disableAddTask"] call MAINCLASS;
        [_logic,"disableEditTask"] call MAINCLASS;
        [_logic,"disableAddTaskManagePlayers"] call MAINCLASS;
        [_logic,"disableEditTaskManagePlayers"] call MAINCLASS;
        [_logic,"disableGenerateTask"] call MAINCLASS;
        [_logic,"disableGenerateTaskManagePlayers"] call MAINCLASS;
        [_logic,"disableAutoGenerateTasks"] call MAINCLASS;

    };
    case "enableTasking": {

        private ["_taskingState","_autoGenerate","_title","_backButton","_abortButton","_addTaskButton","_generateTaskButton","_autoGenerateTaskButton"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        _autoGenerate = [_taskingState,"autoGenerateTasks"] call ALIVE_fnc_hashGet;

        //_taskingState call ALIVE_fnc_inspectHash;

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Current Tasks";

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        _addTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton);
        _addTaskButton ctrlShow true;

        _addTaskButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_ADD_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _generateTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateButton);
        _generateTaskButton ctrlShow true;

        _generateTaskButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_GENERATE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _autoGenerateTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateButton);
        _autoGenerateTaskButton ctrlShow true;

        if(_autoGenerate) then {
            _autoGenerateTaskButton ctrlSetText "Disable auto generated tasks for my side";
        }else{
            _autoGenerateTaskButton ctrlSetText "Auto generate tasks for my side";
        };

        _autoGenerateTaskButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_AUTO_GENERATE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_taskCurrentList","_currentTaskListOptions"];

        _taskCurrentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentList);
        _taskCurrentList ctrlShow true;

        private ["_taskCurrentEditButton","_taskCurrentDeleteButton"];

        _taskCurrentEditButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListEditButton);
        _taskCurrentEditButton ctrlShow false;

        _taskCurrentDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListDeleteButton);
        _taskCurrentDeleteButton ctrlShow false;

    };
    case "disableTasking": {

        private ["_title","_backButton","_abortButton","_playerList","_addTaskButton","_generateTaskButton","_autoGenerateTaskButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        _addTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton);
        _addTaskButton ctrlShow false;

        _generateTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateButton);
        _generateTaskButton ctrlShow false;

        _autoGenerateTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateButton);
        _autoGenerateTaskButton ctrlShow false;

        private ["_taskCurrentList"];

        _taskCurrentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentList);
        _taskCurrentList ctrlShow false;

        private ["_taskCurrentEditButton","_taskCurrentDeleteButton"];

        _taskCurrentEditButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListEditButton);
        _taskCurrentEditButton ctrlShow false;

        _taskCurrentDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskCurrentListDeleteButton);
        _taskCurrentDeleteButton ctrlShow false;

    };
    case "enableAutoGenerateTasks": {

        private ["_taskingState","_autoGenerate","_autoGenerateFaction"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        _autoGenerate = [_taskingState,"autoGenerateTasks"] call ALIVE_fnc_hashGet;
        _autoGenerateFaction = [_taskingState,"autoGenerateTasksFactionValue"] call ALIVE_fnc_hashGet;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Setup Auto Task Generation";

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow true;
        _backButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_AUTO_GENERATE_BACK_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        private ["_factionTitle","_factionList","_factionIndex","_factionListOptions","_factionListValues"];

        _factionTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateFactionTitle);
        _factionTitle ctrlShow true;

        _factionList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateFactionEdit);
        _factionList ctrlShow true;

        _factionListOptions = [_taskingState,"generateFactionOptions"] call ALIVE_fnc_hashGet;
        _factionListValues = [_taskingState,"generateFactionValues"] call ALIVE_fnc_hashGet;

        lbClear _factionList;

        {
            _factionList lbAdd format["%1", _x];
        } forEach _factionListOptions;

        _factionIndex = _factionListValues find _autoGenerateFaction;
        _factionList lbSetCurSel _factionIndex;

        [_taskingState,"generateFactionSelectedIndex",_factionIndex] call ALIVE_fnc_hashSet;
        [_taskingState,"generateFactionSelectedValue",_autoGenerateFaction] call ALIVE_fnc_hashSet;

        _factionList ctrlSetEventHandler ["LBSelChanged", "['TASK_AUTO_GENERATE_FACTION_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_statusText"];

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow true;

        _statusText ctrlSetText "";

        private ["_createButton"];

        _createButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateCreateButton);

        if(_autoGenerate) then {
            _createButton ctrlSetText "Disable Auto Generated Tasks";
            _statusText ctrlSetText "Auto generated tasks are enabled";
            _statusText ctrlSetTextColor [0.384,0.439,0.341,1];

        }else{
            _createButton ctrlSetText "Enable Auto Generated Tasks";
            _statusText ctrlSetText "Auto generated tasks are disabled";
            _statusText ctrlSetTextColor [0.729,0.216,0.235,1];
        };

        _createButton ctrlShow true;
        _createButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_AUTO_GENERATE_CREATE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];



    };
    case "disableAutoGenerateTasks": {

        private ["_taskingState"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        private ["_factionTitle","_factionList"];

        _factionTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateFactionTitle);
        _factionTitle ctrlShow false;

        _factionList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateFactionEdit);
        _factionList ctrlShow false;

        private ["_createButton"];

        _createButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAutoGenerateCreateButton);
        _createButton ctrlShow false;

        private ["_statusText"];

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow false;

    };
    case "enableGenerateTask": {

        private ["_taskingState"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Generate Task";

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow true;
        _backButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_GENERATE_BACK_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        private ["_typeTitle","_typeList","_typeListOptions"];

        _typeTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateTypeTitle);
        _typeTitle ctrlShow true;

        _typeList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateTypeEdit);
        _typeList ctrlShow true;

        _typeListOptions = [_taskingState,"generateTypeOptions"] call ALIVE_fnc_hashGet;

        lbClear _typeList;

        {
            _typeList lbAdd format["%1", _x];
        } forEach _typeListOptions;

        _typeList ctrlSetEventHandler ["LBSelChanged", "['TASK_GENERATE_TYPE_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_locationTitle","_locationList","_locationListOptions"];

        _locationTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateLocationTitle);
        _locationTitle ctrlShow true;

        _locationList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateLocationEdit);
        _locationList ctrlShow true;

        _locationListOptions = [_taskingState,"generateLocationOptions"] call ALIVE_fnc_hashGet;

        lbClear _locationList;

        {
            _locationList lbAdd format["%1", _x];
        } forEach _locationListOptions;

        _locationList ctrlSetEventHandler ["LBSelChanged", "['TASK_GENERATE_LOCATION_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_factionTitle","_factionList","_factionListOptions"];

        _factionTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateFactionTitle);
        _factionTitle ctrlShow true;

        _factionList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateFactionEdit);
        _factionList ctrlShow true;

        _factionListOptions = [_taskingState,"generateFactionOptions"] call ALIVE_fnc_hashGet;

        lbClear _factionList;

        {
            _factionList lbAdd format["%1", _x];
        } forEach _factionListOptions;

        _factionList ctrlSetEventHandler ["LBSelChanged", "['TASK_GENERATE_FACTION_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_applyTitle","_applyList","_applyListOptions"];

        _applyTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateApplyTitle);
        _applyTitle ctrlShow true;

        _applyList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateApplyEdit);
        _applyList ctrlShow true;

        _applyListOptions = [_taskingState,"currentTaskApplyOptions"] call ALIVE_fnc_hashGet;

        lbClear _applyList;

        {
            _applyList lbAdd format["%1", _x];
        } forEach _applyListOptions;

        _applyList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_APPLY_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_currentTitle","_currentList","_currentIndex","_currentListOptions"];

        _currentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateCurrentTitle);
        _currentTitle ctrlShow true;

        _currentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateCurrentEdit);
        _currentList ctrlShow true;

        _currentListOptions = [_taskingState,"currentTaskCurrentOptions"] call ALIVE_fnc_hashGet;

        lbClear _currentList;

        {
            _currentList lbAdd format["%1", _x];
        } forEach _currentListOptions;

        _currentList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_CURRENT_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_map"];

        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);
        _map ctrlShow true;
        _map ctrlSetEventHandler ["MouseButtonDown", "['TASK_GENERATE_MAP_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_createButton"];

        _createButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateCreateButton);
        _createButton ctrlShow true;
        _createButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_GENERATE_CREATE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_managePlayersButton"];

        _managePlayersButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditManagePlayersButton);
        _managePlayersButton ctrlShow true;
        _managePlayersButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_GENERATE_MANAGE_PLAYERS_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_statusText"];

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow true;

        _statusText ctrlSetText "";

    };
    case "disableGenerateTask": {

        private ["_taskingState"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        private ["_typeTitle","_typeList"];

        _typeTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateTypeTitle);
        _typeTitle ctrlShow false;

        _typeList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateTypeEdit);
        _typeList ctrlShow false;

        private ["_locationTitle","_locationList"];

        _locationTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateLocationTitle);
        _locationTitle ctrlShow false;

        _locationList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateLocationEdit);
        _locationList ctrlShow false;

        private ["_factionTitle","_factionList"];

        _factionTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateFactionTitle);
        _factionTitle ctrlShow false;

        _factionList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateFactionEdit);
        _factionList ctrlShow false;

        private ["_applyTitle","_applyList"];

        _applyTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateApplyTitle);
        _applyTitle ctrlShow false;

        _applyList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateApplyEdit);
        _applyList ctrlShow false;

        private ["_currentTitle","_currentList"];

        _currentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateCurrentTitle);
        _currentTitle ctrlShow false;

        _currentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateCurrentEdit);
        _currentList ctrlShow false;

        private ["_createButton"];

        _createButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskGenerateCreateButton);
        _createButton ctrlShow false;

        private ["_managePlayersButton"];

        _managePlayersButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditManagePlayersButton);
        _managePlayersButton ctrlShow false;

        private ["_statusText"];

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow false;

        private ["_map"];

        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);
        _map ctrlShow false;


    };
    case "enableGenerateTaskManagePlayers": {

        private ["_taskingState","_side"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;
        _side = [_logic,"side"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Assign players to this task";

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow true;
        _backButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_GENERATE_MANAGE_PLAYERS_BACK_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        private ["_playerList","_playerListOptions","_playerDataSource"];

        _playerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskPlayerList);
        _playerList ctrlShow true;

        _playerDataSource = [_side] call ALiVE_fnc_getPlayersDataSource;
        [_taskingState,"playerListOptions",_playerDataSource select 0] call ALIVE_fnc_hashSet;
        [_taskingState,"playerListValues",_playerDataSource select 1] call ALIVE_fnc_hashSet;

        [_logic,"taskingState",_taskingState] call MAINCLASS;

        _playerListOptions = [_taskingState,"playerListOptions"] call ALIVE_fnc_hashGet;

        lbClear _playerList;

        {
            _playerList lbAdd format["%1", _x];
        } forEach _playerListOptions;

        _playerList ctrlSetEventHandler ["LBSelChanged", "['TASK_PLAYER_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_selectedPlayerTitle","_selectedPlayerList","_selectedPlayerListOptions"];

        _selectedPlayerTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerTitle);
        _selectedPlayerTitle ctrlShow true;

        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
        _selectedPlayerList ctrlShow true;

        _selectedPlayerListOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;

        lbClear _selectedPlayerList;

        {
            _selectedPlayerList lbAdd format["%1", _x];
        } forEach _selectedPlayerListOptions;

        _selectedPlayerList ctrlSetEventHandler ["LBSelChanged", "['TASK_SELECTED_PLAYER_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

        if(count _selectedPlayerListOptions > 0) then {

            _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
            _selectedPlayersClearButton ctrlShow true;

            _selectedPlayersClearButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_SELECTED_PLAYER_LIST_CLEAR_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        };
    };
    case "disableGenerateTaskManagePlayers": {

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        private ["_playerList"];

        _playerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskPlayerList);
        _playerList ctrlShow false;

        private ["_selectedPlayerTitle","_selectedPlayerList"];

        _selectedPlayerTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerTitle);
        _selectedPlayerTitle ctrlShow false;

        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
        _selectedPlayerList ctrlShow false;

        private ["_selectGroupButton","_selectedPlayerListDeleteButton","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

        _selectGroupButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectGroupButton);
        _selectGroupButton ctrlShow false;

        _selectedPlayerListDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerListDeleteButton);
        _selectedPlayerListDeleteButton ctrlShow false;

        _selectedPlayersAddTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton);
        _selectedPlayersAddTaskButton ctrlShow false;

        _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
        _selectedPlayersClearButton ctrlShow false;

    };
    case "enableAddTask": {

        private ["_taskingState"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Add Task";

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow true;
        _backButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_ADD_BACK_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        private ["_editTitle","_titleEdit","_editDescription","_descriptionEdit","_map","_createButton","_stateTitle",
        "_stateList","_stateListOptions","_managePlayersButton","_applyTitle","_applyList","_applyListOptions","_statusText"];

        _editTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEditTitle);
        _editTitle ctrlShow true;

        _titleEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEdit);
        _titleEdit ctrlShow true;

        _editDescription = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEditTitle);
        _editDescription ctrlShow true;

        _descriptionEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEdit);
        _descriptionEdit ctrlShow true;

        _stateTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEditTitle);
        _stateTitle ctrlShow true;

        _stateList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEdit);
        _stateList ctrlShow true;

        _stateListOptions = [_taskingState,"currentTaskStateOptions"] call ALIVE_fnc_hashGet;

        lbClear _stateList;

        {
            _stateList lbAdd format["%1", _x];
        } forEach _stateListOptions;

        _stateList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_STATE_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _applyTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyTitle);
        _applyTitle ctrlShow true;

        _applyList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyEdit);
        _applyList ctrlShow true;

        _applyListOptions = [_taskingState,"currentTaskApplyOptions"] call ALIVE_fnc_hashGet;

        lbClear _applyList;

        {
            _applyList lbAdd format["%1", _x];
        } forEach _applyListOptions;

        _applyList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_APPLY_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_currentTitle","_currentList","_currentIndex","_currentListOptions"];

        _currentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentTitle);
        _currentTitle ctrlShow true;

        _currentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentEdit);
        _currentList ctrlShow true;

        _currentListOptions = [_taskingState,"currentTaskCurrentOptions"] call ALIVE_fnc_hashGet;

        lbClear _currentList;

        {
            _currentList lbAdd format["%1", _x];
        } forEach _currentListOptions;

        _currentList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_CURRENT_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_parentTitle","_parentList","_parentListOptions"];

        _parentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentTitle);
        _parentTitle ctrlShow true;

        _parentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentEdit);
        _parentList ctrlShow true;

        _parentListOptions = [_taskingState,"currentTaskParentOptions"] call ALIVE_fnc_hashGet;

        lbClear _parentList;

        {
            _parentList lbAdd format["%1", _x];
        } forEach _parentListOptions;

        _parentList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_PARENT_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);
        _map ctrlShow true;
        _map ctrlSetEventHandler ["MouseButtonDown", "['TASK_ADD_MAP_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow true;

        _statusText ctrlSetText "";

        _managePlayersButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditManagePlayersButton);
        _managePlayersButton ctrlShow true;
        _managePlayersButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_ADD_MANAGE_PLAYERS_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _createButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCreateButton);
        _createButton ctrlShow true;
        _createButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_ADD_CREATE_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

    };
    case "disableAddTask": {

        private ["_taskingState"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        private ["_editTitle","_titleEdit","_editDescription","_descriptionEdit","_map","_createButton","_stateTitle",
        "_stateList","_managePlayersButton","_applyTitle","_applyList","_currentTitle","_currentList","_statusText","_parentTitle","_parentList"];

        _editTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEditTitle);
        _editTitle ctrlShow false;

        _titleEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEdit);
        _titleEdit ctrlShow false;

        _editDescription = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEditTitle);
        _editDescription ctrlShow false;

        _descriptionEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEdit);
        _descriptionEdit ctrlShow false;

        _stateTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEditTitle);
        _stateTitle ctrlShow false;

        _stateList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEdit);
        _stateList ctrlShow false;

        _applyTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyTitle);
        _applyTitle ctrlShow false;

        _applyList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyEdit);
        _applyList ctrlShow false;

        _currentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentTitle);
        _currentTitle ctrlShow false;

        _currentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentEdit);
        _currentList ctrlShow false;

        _parentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentTitle);
        _parentTitle ctrlShow false;

        _parentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentEdit);
        _parentList ctrlShow false;

        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);
        _map ctrlShow false;

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow false;

        _managePlayersButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditManagePlayersButton);
        _managePlayersButton ctrlShow false;

        _createButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCreateButton);
        _createButton ctrlShow false;

    };
    case "enableAddTaskManagePlayers": {

        private ["_taskingState","_side"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;
        _side = [_logic,"side"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Assign players to this task";

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow true;
        _backButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_ADD_MANAGE_PLAYERS_BACK_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        private ["_playerList","_playerListOptions","_playerDataSource"];

        _playerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskPlayerList);
        _playerList ctrlShow true;

        _playerDataSource = [_side] call ALiVE_fnc_getPlayersDataSource;
        [_taskingState,"playerListOptions",_playerDataSource select 0] call ALIVE_fnc_hashSet;
        [_taskingState,"playerListValues",_playerDataSource select 1] call ALIVE_fnc_hashSet;

        [_logic,"taskingState",_taskingState] call MAINCLASS;

        _playerListOptions = [_taskingState,"playerListOptions"] call ALIVE_fnc_hashGet;

        lbClear _playerList;

        {
            _playerList lbAdd format["%1", _x];
        } forEach _playerListOptions;

        _playerList ctrlSetEventHandler ["LBSelChanged", "['TASK_PLAYER_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_selectedPlayerTitle","_selectedPlayerList","_selectedPlayerListOptions"];

        _selectedPlayerTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerTitle);
        _selectedPlayerTitle ctrlShow true;

        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
        _selectedPlayerList ctrlShow true;

        _selectedPlayerListOptions = [_taskingState,"selectedPlayerListOptions"] call ALIVE_fnc_hashGet;

        lbClear _selectedPlayerList;

        {
            _selectedPlayerList lbAdd format["%1", _x];
        } forEach _selectedPlayerListOptions;

        _selectedPlayerList ctrlSetEventHandler ["LBSelChanged", "['TASK_SELECTED_PLAYER_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

        if(count _selectedPlayerListOptions > 0) then {

            _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
            _selectedPlayersClearButton ctrlShow true;

            _selectedPlayersClearButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_SELECTED_PLAYER_LIST_CLEAR_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        };
    };
    case "disableAddTaskManagePlayers": {

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        private ["_playerList"];

        _playerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskPlayerList);
        _playerList ctrlShow false;

        private ["_selectedPlayerTitle","_selectedPlayerList"];

        _selectedPlayerTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerTitle);
        _selectedPlayerTitle ctrlShow false;

        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
        _selectedPlayerList ctrlShow false;

        private ["_selectGroupButton","_selectedPlayerListDeleteButton","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

        _selectGroupButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectGroupButton);
        _selectGroupButton ctrlShow false;

        _selectedPlayerListDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerListDeleteButton);
        _selectedPlayerListDeleteButton ctrlShow false;

        _selectedPlayersAddTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton);
        _selectedPlayersAddTaskButton ctrlShow false;

        _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
        _selectedPlayersClearButton ctrlShow false;

    };
    case "enableEditTask": {

        private ["_taskingState","_currentTask","_selectedPlayerListOptions","_selectedPlayerListValues"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;
        _currentTask = [_taskingState,"currentTaskListSelectedValue"] call ALIVE_fnc_hashGet;
        
        [_logic,"taskSource",_currentTask select 12] call MAINCLASS;
        [_logic,"taskEditingDisabled",_currentTask select 13] call MAINCLASS;

		if (count _currentTask > 14) then {
	        [_logic,"taskRevision",_currentTask select 14] call MAINCLASS;
	        [_logic,"taskID",_currentTask select 15] call MAINCLASS;
        };

        _selectedPlayerListOptions = _currentTask select 7 select 1;
        _selectedPlayerListValues = _currentTask select 7 select 0;

        [_taskingState,"currentTaskSelectedPlayerListOptions",_selectedPlayerListOptions] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskSelectedPlayerListValues",_selectedPlayerListValues] call ALIVE_fnc_hashSet;

        //_currentTask call ALIVE_fnc_inspectArray;
        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Edit Task";

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow true;
        _backButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_EDIT_BACK_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        private ["_editTitle","_titleEdit","_editDescription","_descriptionEdit","_taskEditingDisabled","_map","_createButton","_editButton"];

        _editTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEditTitle);
        _editTitle ctrlShow true;

        _titleEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEdit);
        _titleEdit ctrlShow true;

        _titleEdit ctrlSetText (_currentTask select 5);

        _editDescription = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEditTitle);
        _editDescription ctrlShow true;

        _descriptionEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEdit);
        _descriptionEdit ctrlShow true;

        _descriptionEdit ctrlSetText (_currentTask select 6);

        private ["_stateTitle","_stateList","_stateListOptions","_stateListValues","_stateIndex"];

        _stateTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEditTitle);
        _stateTitle ctrlShow true;

        _stateList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEdit);
        _stateList ctrlShow true;

        _stateListOptions = [_taskingState,"currentTaskStateOptions"] call ALIVE_fnc_hashGet;
        _stateListValues = [_taskingState,"currentTaskStateValues"] call ALIVE_fnc_hashGet;

        lbClear _stateList;

        {
            _stateList lbAdd format["%1", _x];
        } forEach _stateListOptions;

        _stateIndex = _stateListOptions find (_currentTask select 8);
        _stateList lbSetCurSel _stateIndex;

        [_taskingState,"currentTaskStateSelectedIndex",_stateIndex] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskStateSelectedValue",_stateListValues select _stateIndex] call ALIVE_fnc_hashSet;

        _stateList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_STATE_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_applyTitle","_applyList","_applyIndex","_applyListOptions","_applyListValues"];

        _applyTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyTitle);
        _applyTitle ctrlShow true;

        _applyList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyEdit);
        _applyList ctrlShow true;

        _applyListOptions = [_taskingState,"currentTaskApplyOptions"] call ALIVE_fnc_hashGet;
        _applyListValues = [_taskingState,"currentTaskApplyValues"] call ALIVE_fnc_hashGet;

        lbClear _applyList;

        {
            _applyList lbAdd format["%1", _x];
        } forEach _applyListOptions;

        _applyIndex = _applyListValues find (_currentTask select 9);
        _applyList lbSetCurSel _applyIndex;

        [_taskingState,"currentTaskApplySelectedIndex",_applyIndex] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskApplySelectedValue",_applyListValues select _applyIndex] call ALIVE_fnc_hashSet;

        _applyList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_APPLY_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_currentTitle","_currentList","_currentIndex","_currentListOptions","_currentListValues","_statusText"];

        _currentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentTitle);
        _currentTitle ctrlShow true;

        _currentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentEdit);
        _currentList ctrlShow true;

        _currentListOptions = [_taskingState,"currentTaskCurrentOptions"] call ALIVE_fnc_hashGet;
        _currentListValues = [_taskingState,"currentTaskCurrentValues"] call ALIVE_fnc_hashGet;

        lbClear _currentList;

        {
            _currentList lbAdd format["%1", _x];
        } forEach _currentListOptions;

        _currentIndex = _currentListValues find (_currentTask select 10);
        _currentList lbSetCurSel _currentIndex;

        [_taskingState,"currentTaskCurrentSelectedIndex",_currentIndex] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskCurrentSelectedValue",_currentListValues select _currentIndex] call ALIVE_fnc_hashSet;

        _currentList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_CURRENT_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_parentTitle","_parentList","_parentListOptions","_parentListValues","_parentIndex","_managePlayersButton"];

        _parentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentTitle);
        _parentTitle ctrlShow true;

        _parentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentEdit);
        _parentList ctrlShow true;

        _parentListOptions = [_taskingState,"currentTaskParentOptions"] call ALIVE_fnc_hashGet;
        _parentListValues = [_taskingState,"currentTaskParentValues"] call ALIVE_fnc_hashGet;

        lbClear _parentList;

        {
            _parentList lbAdd format["%1", _x];
        } forEach _parentListOptions;

        _parentIndex = _parentListValues find (_currentTask select 11);
        _parentList lbSetCurSel _parentIndex;

        [_taskingState,"currentTaskParentSelectedIndex",_parentIndex] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskParentSelectedValue",_parentListValues select _parentIndex] call ALIVE_fnc_hashSet;

        _parentList ctrlSetEventHandler ["LBSelChanged", "['TASK_ADD_PARENT_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _taskEditingDisabled = [_logic,"taskEditingDisabled"] call MAINCLASS;

        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);
        _map ctrlShow true;

        if!(_taskEditingDisabled) then {
            _map ctrlSetEventHandler ["MouseButtonDown", "['TASK_ADD_MAP_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];
        }else{
            _map ctrlSetEventHandler ["MouseButtonDown", "['TASK_ADD_MAP_CLICK_NULL',[_this]] call ALIVE_fnc_C2TabletOnAction"];
        };

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow true;

        _statusText ctrlSetText "";

        _managePlayersButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditManagePlayersButton);
        _managePlayersButton ctrlShow true;
        _managePlayersButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_EDIT_MANAGE_PLAYERS_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _editButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditUpdateButton);
        _editButton ctrlShow true;
        _editButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_EDIT_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        [_logic,"taskingState",_taskingState] call MAINCLASS;

        private ["_posX","_posY","_markers","_position","_marker"];

        _position = _currentTask select 3;

        if(count _position > 0) then {

            _markers = [_logic,"taskMarker"] call MAINCLASS;

            if(count _markers > 0) then {
                deleteMarkerLocal (_markers select 0);
            };

            ctrlMapAnimClear _map;
            _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _position];
            ctrlMapAnimCommit _map;

            _marker = createMarkerLocal [format["%1%2",MTEMPLATE,"marker"],_position];
            _marker setMarkerAlphaLocal 1;
            _marker setMarkerTextLocal "Destination";
            _marker setMarkerTypeLocal "hd_Objective";

            [_logic,"taskMarker",[_marker]] call MAINCLASS;
            [_logic,"taskDestination",_position] call MAINCLASS;

        };

    };
    case "disableEditTask": {

        private ["_taskingState"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        private ["_editTitle","_titleEdit","_editDescription","_descriptionEdit","_map","_editButton","_stateTitle",
        "_stateList","_managePlayersButton","_applyTitle","_applyList","_currentTitle","_currentList","_statusText","_parentTitle","_parentList"];

        _editTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEditTitle);
        _editTitle ctrlShow false;

        _titleEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddTitleEdit);
        _titleEdit ctrlShow false;

        _editDescription = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEditTitle);
        _editDescription ctrlShow false;

        _descriptionEdit = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddDescriptionEdit);
        _descriptionEdit ctrlShow false;

        _stateTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEditTitle);
        _stateTitle ctrlShow false;

        _stateList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStateEdit);
        _stateList ctrlShow false;

        _applyTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyTitle);
        _applyTitle ctrlShow false;

        _applyList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddApplyEdit);
        _applyList ctrlShow false;

        _currentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentTitle);
        _currentTitle ctrlShow false;

        _currentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddCurrentEdit);
        _currentList ctrlShow false;

        _parentTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentTitle);
        _parentTitle ctrlShow false;

        _parentList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddParentEdit);
        _parentList ctrlShow false;

        _map = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddMap);
        _map ctrlShow false;

        _statusText = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskAddStatusText);
        _statusText ctrlShow false;

        _managePlayersButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditManagePlayersButton);
        _managePlayersButton ctrlShow false;

        _editButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskEditUpdateButton);
        _editButton ctrlShow false;

    };
    case "enableEditTaskManagePlayers": {

        private ["_taskingState","_side","_currentTask"];

        _taskingState = [_logic,"taskingState"] call MAINCLASS;
        _side = [_logic,"side"] call MAINCLASS;

        _currentTask = [_taskingState,"currentTaskListSelectedValue"] call ALIVE_fnc_hashGet;

        //_taskingState call ALIVE_fnc_inspectHash;

        private ["_title","_backButton","_abortButton"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText "Update assigned players for this task";

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow true;
        _backButton ctrlSetEventHandler ["MouseButtonClick", "['TASK_EDIT_MANAGE_PLAYERS_BACK_BUTTON_CLICK',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow true;

        private ["_playerList","_playerListOptions","_playerDataSource"];

        _playerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskPlayerList);
        _playerList ctrlShow true;

        _playerDataSource = [_side] call ALiVE_fnc_getPlayersDataSource;
        [_taskingState,"currentTaskPlayerListOptions",_playerDataSource select 0] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskPlayerListValues",_playerDataSource select 1] call ALIVE_fnc_hashSet;

        [_logic,"taskingState",_taskingState] call MAINCLASS;

        _playerListOptions = [_taskingState,"currentTaskPlayerListOptions"] call ALIVE_fnc_hashGet;

        lbClear _playerList;

        {
            _playerList lbAdd format["%1", _x];
        } forEach _playerListOptions;

        _playerList ctrlSetEventHandler ["LBSelChanged", "['TASK_EDIT_MANAGE_PLAYER_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        private ["_selectedPlayerTitle","_selectedPlayerList","_selectedPlayerListOptions","_selectedPlayerListValues"];

        _selectedPlayerTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerTitle);
        _selectedPlayerTitle ctrlShow true;

        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
        _selectedPlayerList ctrlShow true;

        _selectedPlayerListOptions = _currentTask select 7 select 1;
        _selectedPlayerListValues = _currentTask select 7 select 0;

        [_taskingState,"currentTaskSelectedPlayerListOptions",_selectedPlayerListOptions] call ALIVE_fnc_hashSet;
        [_taskingState,"currentTaskSelectedPlayerListValues",_selectedPlayerListValues] call ALIVE_fnc_hashSet;

        lbClear _selectedPlayerList;

        {
            _selectedPlayerList lbAdd format["%1", _x];
        } forEach _selectedPlayerListOptions;

        _selectedPlayerList ctrlSetEventHandler ["LBSelChanged", "['TASK_EDIT_MANAGE_SELECTED_PLAYER_LIST_SELECT',[_this]] call ALIVE_fnc_C2TabletOnAction"];

        [_taskingState,"selectedPlayerListOptions",[]] call ALIVE_fnc_hashSet;
        [_taskingState,"selectedPlayerListValues",[]] call ALIVE_fnc_hashSet;
        [_taskingState,"selectedPlayerListSelectedIndex",DEFAULT_SELECTED_INDEX] call ALIVE_fnc_hashSet;
        [_taskingState,"selectedPlayerListSelectedValue",DEFAULT_SELECTED_VALUE] call ALIVE_fnc_hashSet;

    };
    case "disableEditTaskManagePlayers": {

        private ["_title","_backButton","_abortButton","_playerList"];

        _title = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_Title);
        _title ctrlShow false;

        _backButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuBack);
        _backButton ctrlShow false;

        _abortButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_SubMenuAbort);
        _abortButton ctrlShow false;

        _playerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskPlayerList);
        _playerList ctrlShow false;

        private ["_selectedPlayerTitle","_selectedPlayerList"];

        _selectedPlayerTitle = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerTitle);
        _selectedPlayerTitle ctrlShow false;

        _selectedPlayerList = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerList);
        _selectedPlayerList ctrlShow false;

        private ["_selectGroupButton","_selectedPlayerListDeleteButton","_selectedPlayersAddTaskButton","_selectedPlayersClearButton"];

        _selectGroupButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectGroupButton);
        _selectGroupButton ctrlShow false;

        _selectedPlayerListDeleteButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayerListDeleteButton);
        _selectedPlayerListDeleteButton ctrlShow false;

        _selectedPlayersAddTaskButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersAddTaskButton);
        _selectedPlayersAddTaskButton ctrlShow false;

        _selectedPlayersClearButton = C2_getControl(C2Tablet_CTRL_MainDisplay,C2Tablet_CTRL_TaskSelectedPlayersClearButton);
        _selectedPlayersClearButton ctrlShow false;

    };
};

TRACE_1("C2 - output",_result);
_result;
