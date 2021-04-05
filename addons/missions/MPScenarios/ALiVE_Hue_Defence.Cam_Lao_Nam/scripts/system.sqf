/*
 * Filename:
 * system.sqf
 *
 * Description:
 * function scripts
 * Runs on server and client
 
 * Created by [KH]Jman
 * Creation date: 05/04/2021
 * Email: jman@kellys-heroes.eu
 * Web: http://www.kellys-heroes.eu
 *
 * */
 
// ====================================================================================
//  SYSTEM HANDLERS
// ====================================================================================
 
#define INC(var) var = (var) + 1
 
// ====================================================================================
  
  // SETUP	
  if (count playableUnits == 0) then {SP = true} else {SP = false};
  gameOver = false;
  
// ====================================================================================


        "GlobalHint" addPublicVariableEventHandler {
            private ["_GHint"];
            _GHint = _this select 1;
            if (PARAMS_Debug == 1) then { diag_log format["%3: scripts\system.sqf -> GlobalHint - _this: %1, _GHint: %2", _this, _GHint, missionName];};
            hint parseText format["%1", _GHint];
        };
 
 
        "GlobalSideChat" addPublicVariableEventHandler {
            private ["_GSChat"];
            _GSChat = _this select 1;
            if (PARAMS_Debug == 1) then { diag_log format["%3: scripts\system.sqf -> GlobalSideChat - _this: %1, _GSChat: %2", _this, _GSChat, missionName];};
            player sideChat _GSChat;
        };
       
// ====================================================================================
   
   // remove tasks
   
				if (isServer) then { 
				    //[targets, taskid] call LARs_fnc_removeTask; 
				    LARs_fnc_removeTask = { 
				        _targets = [_this,0,true,[true,sideunknown,grpnull,objnull,[]]] call BIS_fnc_param; 
				        _taskID = [_this,1,"",[""]] call BIS_fnc_param; 

				        { 
				            _target = _x; 
				            switch (typeName _target) do { 
				                //case (typeName objNull || typeName sideUnknown || typeName [] || typeName true): { 
				                //    [[_taskID],"LARs_fnc_removeTaskLocal",_target,true] call BIS_fnc_MP; 
				                //}; 
				                case (typeName grpNull): { 
				                    [[_taskID],"LARs_fnc_removeTaskLocal",units _target,true] call BIS_fnc_MP; 
				                }; 
				                default { 
				                    [[_taskID],"LARs_fnc_removeTaskLocal",_target,true] call BIS_fnc_MP; 
				                }; 
				            }; 
				        } foreach [_targets]; 
				    }; 
				}; 


				if (!(isDedicated)) then { 
				    //preprocess on clients 
				    LARs_fnc_removeTaskLocal = { 
				        _taskID = [_this,0,"",[""]] call BIS_fnc_param; 
				        _taskVar = [_taskID] call BIS_fnc_taskVar; 
				        missionNamespace setVariable [_taskVar,nil]; 
				        player removeSimpleTask ([_taskID,player] call BIS_fnc_taskReal); 
				        _playerTasks = player getVariable ["BIS_fnc_setTaskLocal_tasks",[]]; 
				        _playerTasks = _playerTasks - [_taskID]; 
				        player setVariable ["BIS_fnc_setTaskLocal_tasks", _playerTasks]; 
				        _playerTaskVar = "BIS_fnc_taskvar_" + _taskID; 
				        player setVariable [_playerTaskVar,nil]; 
				    }; 
				};  

// ====================================================================================



  FNC_SERVER_TO_VEHICLECLIENT_MSG = {
                _player  = _this select 0;
                _vehicle = _this select 1;
                    _serverData = _this select 2;
               if (player != _player) exitWith { };
             _vehicle vehicleChat _serverData;
              if (PARAMS_Debug == 1) then { diag_log format ["%4: scripts\system.sqf -> FNC_SERVER_TO_VEHICLECLIENT_MSG:  _player: %1, _serverData: %2, _vehicle: %3", _player, _serverData, _vehicle, missionName];};
     };
 
// ====================================================================================
 
    FNC_FIND = {
        private ["_haystackCount", "_needleCount", "_foundPos","_needleIndex", "_doexit", "_notfound"];
   
            _haystack =  _this select 0;
             _needle =  _this select 1;
             _initialIndex = _this select 2;
       
            if (typeName _haystack == "STRING") then {
                _haystack = toArray _haystack;
            };
           
            if (typeName _needle == "STRING") then {
                _needle = toArray _needle;
            };
           
            _haystackCount = count _haystack;
            _needleCount = count _needle;
            _foundPos = -1;
           
            if ((_haystackCount - _initialIndex) < _needleCount) exitWith {_foundPos};
           
            _needleIndex = 0;
            _doexit = false;
            for "_i" from _initialIndex to (_haystackCount - 1) do {
                if (_haystack select _i == _needle select _needleIndex) then {
                    if (_needleCount == 1) exitWith {
                        _foundPos = _i;
                        _doexit = true;
                    };
                    if (_haystackCount - _i < _needleCount) exitWith {_doexit = true};
                    INC(_needleIndex);
                    _notfound = false;
                    for "_j" from (_i + 1) to (_i + _needleCount - 1) do {
                        if (_haystack select _j != _needle select _needleIndex) exitWith {
                            _notfound = true;
                        };
                        INC(_needleIndex);
                    };
                    if (_notfound) then {
                        _needleIndex = 0;
                    } else {
                        _foundPos = _i;
                        _doexit = true;
                    };
                };
                if (_doexit) exitWith {};
            };
           
            _foundPos
        };
       
// ====================================================================================
   
   "SERVER_TO_VEHICLECLIENT_MSG" addPublicVariableEventHandler {
    (_this select 1) call FNC_SERVER_TO_VEHICLECLIENT_MSG
    };
   
// ====================================================================================
 

 
            searchMultiDimensionalArray = {
                // usage:  _key = [ARRAY, 0, 1, "Jman"] call searchMultiDimensionalArray;
                // if not found returns -1
                private ["_array","_element","_lstsize","_i","_entry","_nestedvalue","_index","_locinarray","_start","_JayArma2lib_log"];
                _array      = _this select 0;  // the multi-d
                _start      = _this select 1;  // key number of the multi-d to start searching from
                _locinarray = _this select 2;  // element location in array to look
                _element    = _this select 3;  // value to search for
       
                _index    = -1;
                _lstsize  = count _array;
                _i        = _start;
       
                while {(_i < _lstsize)} do {
                  _entry = _array Select _i;
                   _nestedvalue = _entry Select _locinarray;
                   
                  if (_nestedvalue == _element) then {
                    _index=_i;
                    _i = _lstsize;
                  };
                  _i=_i+1;
                };
                _index;
            };
           
// ====================================================================================


/* ----------------------------------------------------------------------------
    Function: fnc_isModuleAvailable
    Description:
    Returns true if all target modules (array) are available
   
    Parameters:
    Nil
   
    Returns:
    Bool
---------------------------------------------------------------------------- */
 
    fnc_isModuleAvailable = {
        private ["_targets","_result"];
       
       
        _targets = _this;
        _result = false;
       
        for "_i" from 0 to ((count _targets)-1) do {
            private ["_mod"];
            if (count _targets == 0) exitwith {};
           
            _mod = _targets select 0;
           
            if !(isnil "_mod") then {
                if ((({(typeof _x) == _mod} count (entities "Module_F") > 0))) then {
                    _targets = _targets - [_mod];
                };
            };
        };
       
        if ({!(isnil "_x")} count _targets > 0) then {false} else {true};
    };