#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(BUS);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_BUS

Description:
ALiVE Service Bus for MP execution handling (optimized for the usage of PVS and PVC).

Parameters:
Dataset full: [
	_id (auto),
	[
		[
			_from (auto),
			_to (player object),
			_subject (string),
			_body (array: [params,{code}],
			_status
		]
	]
]
- Parameters (Array)
- Code ({Code})

Examples:
[playableunits select 1,"Subject",[[],{hint "test";true;}]] call ALIVE_fnc_BUS;
[playableunits select 0,"Subject",[[_logic, "spawnGroup", _house],{call ALiVE_fnc_CQB}]] call ALIVE_fnc_BUS;

//Testcase (run on all localities, runs in scheduled environment to return values (waituntil not working in unscheduled))
call compile preprocessfilelinenumbers "\x\alive\addons\main\tests\test_bus.sqf";

Author:
Highhead

Peer Reviewed:
Wolffy 20131117
---------------------------------------------------------------------------- */
//Initialise an Eventhandler the first time this function is run
if (isnil "ALiVE_BUSEH") then {
	ALiVE_BUSEH = true;
	BUS_pending = [];
	BUS_finished = [];
	BUS_archived = [];
	BUFFER = 15; //items in finished queue until archiving
	ARCHIVELIMIT = 100; //Limit items of archive
	
	"BUSE" addPublicVariableEventHandler {
		private ["_from","_to","_subject","_body","_id","_data","_datastack","_status","_params","_code","_entry","_ret","_exec","_typeName"];
		
		_dataStack = _this select 1;
		_id = _dataStack select 0;
		_dataTmp = _dataStack select 1;
		_data = _dataTmp select 0;
		_status = _dataTmp select 1;
		if ((count _dataTmp) > 2) then {_ret = _dataTmp select 2};
		
		_from = _data select 0;
		_to = _data select 1;
		_subject = _data select 2;
		_body = _data select 3;
		
		_params = _body select 0;
		_code = _body select 1;
		
		switch (_status) do {
			case "new" : {
				//Execute if local or "server";
				if ((typeName _to == "STRING") && {_to == "server"}) then {_exec = isServer} else {_exec = local _to};
				if (_exec) then {
                    
                    //["BUS TRACE INPUT %1 %2",_params,_code] call ALiVE_fnc_DumpR;
                    if (!(isnil "_code") && {typeName _code == "STRING"}) then {_code = call compile _code};
					if (isnil "_params") then {_ret = call _code} else {_ret = _params call _code};
					if (isnil "_ret") then {_ret = "nothing"};
                    //["BUS TRACE EXECUTED %1 %2 RETURN: %3",_params,_code,_ret] call ALiVE_fnc_DumpR;
                    
					//Set and send execution status (if on server then the PVS is executed only on server and not other machines)
					_status = "executed";
					_entry = [_id,[_data,_status,_ret]];
					BUSE = _entry;
					PublicVariableServer "BUSE";
					
					//Setting local queue
					if !(isDedicated) then {
						_status = "finished";
						_entry = [_id,[_data,_status,_ret]];
					};
				} else {
					//transfer to receiver (to-adress)
					_entry = [_id,[_data,_status]];
					BUSE = _entry;
					(owner _to) PublicvariableClient "BUSE";
				};
			};
			
			case "executed" : {
				//Inform the sender (from-address) of executed item
				_status = "finished";
				_entry = [_id,[_data,_status,_ret]];
				BUSE = _entry;
				
				if ((typename _from == "STRING") && {_from == "server"}) then {
					PublicVariableServer "BUSE";
				} else {
					(owner _from) PublicvariableClient "BUSE";
				};
			};
			
			case "finished" : {
				//inform sender and prepare data for local queue-set
				_entry = [_id,[_data,_status,_ret]];
				//diag_log format["BUS End: %1, Id: %2, Value returned: %3",time,_id,_ret];
			};
		};
		
		//Always set Queue
		if (_status == "finished") then {
			BUS_pending = [BUS_pending,_id,"remove"] call ALiVE_fnc_BUS_UpdateQueue;
			BUS_finished = [BUS_finished,_id,"update",_entry] call ALiVE_fnc_BUS_UpdateQueue;
		} else {
			BUS_pending = [BUS_pending,_id,"update",_entry] call ALiVE_fnc_BUS_UpdateQueue;
		};
		
		//Delete archived- and finished-queue after 100/40 entries to increase performance
		if ((count BUS_finished >= (BUFFER * 2)) || {(count BUS_archived >= ARCHIVELIMIT)}) then {
			for "_i" from 0 to BUFFER do {
				BUS_archived pushback (BUS_finished select _i);
				BUS_finished set [_i,"X"];
				
				if (count BUS_archived >= ARCHIVELIMIT) then {
					//dump to log disabled
					//diag_log BUS_archived;
					BUS_archived = [];
				};
			};
			BUS_finished = BUS_finished - ["X"];
		};
	};
};

//Update Queue function (subfunction)
if (isnil "ALiVE_fnc_BUS_UpdateQueue") then {
	ALiVE_fnc_BUS_UpdateQueue = {
		private ["_queue","_id","_idx","_action","_data"];
		
		_queue = _this select 0;
		_id = _this select 1;
		_action = _this select 2;
		if (count _this > 3) then {_data = _this select 3};
		
		//Get/Set index
		if !(count _queue == 0) then {
			_idx = ([_queue,_id] call BIS_fnc_findNestedElement) select 0; 
			if (isnil "_idx") then {_idx = (count _queue)};
		} else {
			_idx = 0
		};
		
		switch (_action) do {
			case "remove" : {
				_queue set [_idx,"X"];
				_queue = _queue - ["X"];
			};
			case "update" : {
				_queue set [_idx,_data];
			};
		};
		_queue;
	};	
};

// Return values over network even with call
if (isnil "ALiVE_fnc_BUS_RetVal") then {
	ALiVE_fnc_BUS_RetVal = {
		private ["_idxv","_idtmp","_retV","_timeOut"];
        
		_idtmp = _this call ALIVE_fnc_BUS;
		_timeOut = time;
        
		while {_idxv = nil;_idxv = ([BUS_finished,_idtmp] call BIS_fnc_findNestedElement) select 0; (isnil "_idxv") && {(time - _timeOut) < 5}} do {};
        
        if (isNil "_idxv") exitwith {};
        
		while {_retV = nil;_retV = ((BUS_finished select _idxv) select 1) select 2; (isnil "_retV") && {(time - _timeOut) < 5}} do {};
		
		BUS_archived pushback (BUS_finished select _idxv);
		BUS_finished set [_idxv,"X"];
		BUS_finished = BUS_finished - ["X"];
		
		_retV;
	};
};

//Call the Send Function
private ["_this","_from","_to","_subject","_body","_id","_data","_status","_entry","_ret","_params","_code","_localExec"];

//Exit if no params are given
if (isnil {_this select 0}) exitwith {diag_log "No params given for ALIVE_fnc_BUS - exiting..."; if (isnil "ALiVE_BUSEH") then {false} else {true}};

_from = if !(isDedicated) then {player} else {"server"};
_to = _this select 0;
_subject = _this select 1;
_body = _this select 2;
_data = [_from,_to,_subject,_body];
_id = (str(floor time) + str(floor(random 100)) + str(floor(time / random 3)));
_id = call compile _id;

if ((typeName _to == "STRING") && {_to == "server"}) then {_localExec = isServer} else {_localExec = local _to};
if (_localExec) then {
	//Execute if to-adress is already local and do not transfer via net in this case
	_params = _body select 0;
	_code = _body select 1;
	
	if (!(isnil "_code") && {typeName _code == "STRING"}) then {_code = compile _code};
	if (isnil "_params") then {_ret = call _code} else {_ret = _params call _code};
	if (isnil "_ret") then {_ret = "nothing"};
	
	_status = "finished";
	_entry = [_id,[_data,_status,_ret]];
} else {
	//Send message to net
	_status = "new";
	_entry = [_id,[_data,_status]];
	BUSE = _entry;
	PublicVariableServer "BUSE";
};

//Always set Queue
if (_status == "finished") then {
	BUS_pending = [BUS_pending,_id,"remove"] call ALiVE_fnc_BUS_UpdateQueue;
	BUS_finished = [BUS_finished,_id,"update",_entry] call ALiVE_fnc_BUS_UpdateQueue;
} else {
	BUS_pending = [BUS_pending,_id,"update",_entry] call ALiVE_fnc_BUS_UpdateQueue;
};

_id;