#include <\x\alive\addons\mil_OPCOM\script_component.hpp>
SCRIPT(OPCOMToggleInstallations);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMToggleInstallations
Description:
Toggles installations (not objectives) on / off

Parameters:
None

Returns:
Nothing

Examples:
(begin example)
call ALIVE_fnc_OPCOMToggleInstallations
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Execute on server if function was called on a client
if !(isServer) exitWith {_this remoteExec ["ALIVE_fnc_OPCOMToggleInstallations", 2]};

// Exit if OPCOMs are unavailable
if (isnil "OPCOM_instances" || {count OPCOM_instances == 0}) exitwith {};

private ["_enabled","_OPCOM_HANDLER","_objectives","_size","_id","_radius","_pos","_sideIn"];

if (count _this > 0) then {_pos = _this select 0};
if (count _this > 1) then {_radius = _this select 1};
if (count _this > 2) then {_sideIn = _this select 2};

_enabled = false;

_markers = [];

{
	_OPCOM_HANDLER = _x;
    _sideOPCOM = [_OPCOM_HANDLER,"side",[]] call ALiVE_fnc_HashGet;
    _sideOPCOM = [_sideOPCOM] call ALIVE_fnc_sideTextToObject;
        
    if (isnil "_sideIn" || {!isnil "_sideIn" && {_sideIn == _sideOPCOM}}) then {
        
        _objectives = [_OPCOM_HANDLER,"objectives",[]] call ALiVE_fnc_HashGet;
        
	    {
	        _objective = _x;
	        
	        _center = [_objective,"center"] call ALiVE_fnc_HashGet;
	        
	        if (isnil "_pos" || {_pos distance _center < _radius}) then {
	
		        _id = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
		        _size = [_objective,"size",150] call ALiVE_fnc_HashGet;
                _type = [_objective,"type","none"] call ALiVE_fnc_HashGet;
			
				_factory = [_OPCOM_HANDLER,"convertObject",[_objective,"factory",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_HQ = [_OPCOM_HANDLER,"convertObject",[_objective,"HQ",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_ambush = [_OPCOM_HANDLER,"convertObject",[_objective,"ambush",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_depot = [_OPCOM_HANDLER,"convertObject",[_objective,"depot",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_sabotage = [_OPCOM_HANDLER,"convertObject",[_objective,"sabotage",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_ied = [_OPCOM_HANDLER,"convertObject",[_objective,"ied",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_suicide = [_OPCOM_HANDLER,"convertObject",[_objective,"suicide",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
				_roadblocks = [_OPCOM_HANDLER,"convertObject",[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                
		        _markers append [[format["reg_%1",_id],_center,"ELLIPSE", [_size,_size],"ColorRed","IED", "n_installation", "FDiagonal",0,0.3] call ALIVE_fnc_createMarkerGlobal];
		        _markers append [[format["regI_%1",_id],_center,"ICON", [0.1,0.1],"ColorRed",format["%1 installation",_type], "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
                		
				if (alive _HQ && {!_enabled}) then {_markers append [[format["hq_%1",_id],getposATL _HQ,"ICON", [0.5,0.5],"ColorRed","Recruitment HQ", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal]} else {deleteMarker format["hq_%1",_id]};
				if (alive _depot && {!_enabled}) then {_markers append [[format["depot_%1",_id],getposATL _depot,"ICON", [0.5,0.5],"ColorRed","Weapons depot", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal]} else {deleteMarker format["depot_%1",_id]};
				if (alive _factory && {!_enabled}) then {_markers append [[format["factory_%1",_id],getposATL _factory,"ICON", [0.5,0.5],"ColorRed","IED factory", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal]} else {deleteMarker format["factory_%1",_id]};
				if (alive _ambush && {!_enabled}) then {_markers append [[format["ambush_%1",_id],getposATL _ambush,"ICON", [0.5,0.5],"ColorRed","Ambush", "hd_ambush", "FDiagonal",0,0.5 ] call ALIVE_fnc_createMarkerGlobal]} else {deleteMarker format["ambush_%1",_id]};
				if (alive _sabotage && {!_enabled}) then {_markers append [[format["sabotage_%1",_id],getposATL _sabotage,"ICON", [0.5,0.5],"ColorRed","Sabotage", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal]} else {deleteMarker format["sabotage_%1",_id]};
				if (alive _ied && {!_enabled}) then {
		            _markers append [[format["ied_%1",_id],getposATL _ied,"ELLIPSE", [_size,_size],"ColorRed","IED", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
		            _markers append [[format["iedI_%1",_id],getposATL _ied,"ICON", [0.1,0.1],"ColorRed","IED", "mil_dot", "FDiagonal",0,0.5 ] call ALIVE_fnc_createMarkerGlobal];
		        } else {
		            deleteMarker format["ied_%1",_id];
		            deleteMarker format["iedI_%1",_id];
		        };
				if (alive _suicide && {!_enabled}) then {
		            _markers append [[format["suicide_%1",_id],getposATL _suicide,"ELLIPSE", [_size,_size],"ColorRed","Suicidebomber", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
		            _markers append [[format["suicideI_%1",_id],getposATL _suicide,"ICON", [0.1,0.1],"ColorRed","Suicidebomber", "mil_dot", "FDiagonal",0,0.5 ] call ALIVE_fnc_createMarkerGlobal];
		        } else {
		            deleteMarker format["suicide_%1",_id];
		            deleteMarker format["suicideI_%1",_id];
		        };
				if (alive _roadblocks && {!_enabled}) then {
		            _markers append [[format["roadblocks_%1",_id],getposATL _roadblocks,"ELLIPSE", [_size,_size],"ColorRed","Roadblocks", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
		            _markers append [[format["roadblocksI_%1",_id],getposATL _roadblocks,"ICON", [0.1,0.1],"ColorRed","Roadblocks", "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
		        } else {
		            deleteMarker format["roadblocks_%1",_id];
		            deleteMarker format["roadblocksI_%1",_id];
		        };
	        };
		} foreach _objectives;
    };
} foreach OPCOM_instances;

if (count _markers > 0) then {
	_markers spawn {
	    
	    waituntil {
	        sleep 1;
	        
	        {_x setMarkerAlpha ((markeralpha _x)-0.01)} foreach _this;
	        
	        markeralpha (_this select 0) < 0.1
	    };
	    
	    {deletemarker _x} foreach _this;
	};
};