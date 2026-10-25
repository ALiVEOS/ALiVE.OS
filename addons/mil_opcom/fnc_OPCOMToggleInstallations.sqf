#include "\x\alive\addons\mil_OPCOM\script_component.hpp"
SCRIPT(OPCOMToggleInstallations);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMToggleInstallations
Description:
Toggles installations (not objectives) on / off

Parameters:
(all optional)
Array  - position: only installations within the radius of it
Scalar - radius
Side   - only this enemy side's installations (anything else: every side)
String - Tablet Intel Log: the side that was given this intel ("WEST", "EAST", "GUER"); none: not logged
String - Tablet Intel Log: where it came from, shown in the log ("a civilian", "captured documents")
String - Tablet Intel Log: the faction that was given it

Returns:
Nothing

Examples:
(begin example)
call ALIVE_fnc_OPCOMToggleInstallations
(end)

See Also:

Author:
Highhead
Jman

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
if (count _this > 2) then {_sideIn = _this select 2; if !(_sideIn isEqualType west) then {_sideIn = nil}};

// Tablet Intel Log (Eric on Discord, 25 Oct): each installation drawn is written to the receiving side's log, once
// per installation: a second reveal of the same one counts it again. Not for the admin's reveal-all, which has no position
private _forSide = if (count _this > 3) then {_this select 3} else {""};
private _source = if (count _this > 4) then {_this select 4} else {"intel"};
private _forFaction = if (count _this > 5) then {_this select 5} else {""};
private _logOn = !isNil "_pos" && {_forSide != ""} && {!isNil "ALIVE_fnc_intelLog"} && {missionNamespace getVariable ["ALiVE_c2istar_intelLogEnabled", false]};
private _fnc_log = {
    params ["_kind", "_obj", "_label"];
    if (_logOn) then {
        ["add", [_forSide, _forFaction, _kind, getPosATL _obj, _label,
            format ["From %1. Part of a %2 objective at grid %3", _source, _type, mapGridPosition _center], _source, format ["%1_%2", _id, _label]]] call ALIVE_fnc_intelLog;
    };
};

_enabled = false;

// Intel read from the commander's men can also mark where its high value target was last seen (#625)
if (!isNil "_sideIn") then { ["reveal", [_sideIn, _forSide, _forFaction, _source]] call ALiVE_fnc_OPCOMHVT };
// and narrows the search for an HVT of that side hiding near where it was read (HVT Manhunt Chance on C2ISTAR)
if (!isNil "_sideIn" && {!isNil "_pos"} && {!isNil "ALiVE_c2istar_manhunts"} && {count ALiVE_c2istar_manhunts > 0}) then {
    ["clue", ["", [_pos], str _sideIn, if (isNil "_radius") then {1500} else {_radius}]] call ALIVE_fnc_taskManhunt;
};

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
                _type = [_objective,"objectiveType","none"] call ALiVE_fnc_HashGet;

                _factory = [_OPCOM_HANDLER,"convertObject",[_objective,"factory",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _HQ = [_OPCOM_HANDLER,"convertObject",[_objective,"HQ",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _ambush = [_OPCOM_HANDLER,"convertObject",[_objective,"ambush",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _depot = [_OPCOM_HANDLER,"convertObject",[_objective,"depot",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _sabotage = [_OPCOM_HANDLER,"convertObject",[_objective,"sabotage",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _ied = [_OPCOM_HANDLER,"convertObject",[_objective,"ied",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _suicide = [_OPCOM_HANDLER,"convertObject",[_objective,"suicide",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _roadblocks = [_OPCOM_HANDLER,"convertObject",[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

                _markers append [[format["reg_%1",_id],_center,"ELLIPSE", [_size,_size],"ColorRed","IED", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
                _markers append [[format["regI_%1",_id],_center,"ICON", [0.1,0.1],"ColorRed",format["%1",_type], "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];

                if (alive _HQ && {!_enabled}) then {_markers append [[format["hq_%1",_id],getposATL _HQ,"ICON", [0.5,0.5],"ColorRed","Recruitment HQ", "n_installation", "FDiagonal",0,0.5, "installation", _sideOPCOM] call ALIVE_fnc_createMarkerGlobal]; ["installation", _HQ, "Recruitment HQ"] call _fnc_log} else {deleteMarker format["hq_%1",_id]};
                if (alive _depot && {!_enabled}) then {_markers append [[format["depot_%1",_id],getposATL _depot,"ICON", [0.5,0.5],"ColorRed","Weapons depot", "n_installation", "FDiagonal",0,0.5, "installation", _sideOPCOM] call ALIVE_fnc_createMarkerGlobal]; ["installation", _depot, "Weapons depot"] call _fnc_log} else {deleteMarker format["depot_%1",_id]};
                if (alive _factory && {!_enabled}) then {_markers append [[format["factory_%1",_id],getposATL _factory,"ICON", [0.5,0.5],"ColorRed",([_OPCOM_HANDLER] call ALiVE_fnc_INS_factoryName), "n_installation", "FDiagonal",0,0.5, "installation", _sideOPCOM] call ALIVE_fnc_createMarkerGlobal]; ["installation", _factory, [_OPCOM_HANDLER] call ALiVE_fnc_INS_factoryName] call _fnc_log} else {deleteMarker format["factory_%1",_id]};
                if (alive _ambush && {!_enabled}) then {_markers append [[format["ambush_%1",_id],getposATL _ambush,"ICON", [0.5,0.5],"ColorRed","Ambush", "hd_ambush", "FDiagonal",0,0.5, "ambush", _sideOPCOM] call ALIVE_fnc_createMarkerGlobal]; ["ambush", _ambush, "Ambush"] call _fnc_log} else {deleteMarker format["ambush_%1",_id]};
                if (alive _sabotage && {!_enabled}) then {_markers append [[format["sabotage_%1",_id],getposATL _sabotage,"ICON", [0.5,0.5],"ColorRed","Sabotage", "n_installation", "FDiagonal",0,0.5, "installation", _sideOPCOM] call ALIVE_fnc_createMarkerGlobal]; ["installation", _sabotage, "Sabotage"] call _fnc_log} else {deleteMarker format["sabotage_%1",_id]};
                if (alive _ied && {!_enabled}) then {
                    _markers append [[format["ied_%1",_id],getposATL _ied,"ELLIPSE", [_size,_size],"ColorRed","IED", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
                    _markers append [[format["iedI_%1",_id],getposATL _ied,"ICON", [0.1,0.1],"ColorRed","IED", "mil_dot", "FDiagonal",0,0.5 ] call ALIVE_fnc_createMarkerGlobal];
                    ["ied", _ied, "IED"] call _fnc_log;
                } else {
                    deleteMarker format["ied_%1",_id];
                    deleteMarker format["iedI_%1",_id];
                };
                if (alive _suicide && {!_enabled}) then {
                    _markers append [[format["suicide_%1",_id],getposATL _suicide,"ELLIPSE", [_size,_size],"ColorRed","Suicide bomber", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
                    _markers append [[format["suicideI_%1",_id],getposATL _suicide,"ICON", [0.1,0.1],"ColorRed","Suicide bomber", "mil_dot", "FDiagonal",0,0.5 ] call ALIVE_fnc_createMarkerGlobal];
                    ["ied", _suicide, "Suicide bomber"] call _fnc_log;
                } else {
                    deleteMarker format["suicide_%1",_id];
                    deleteMarker format["suicideI_%1",_id];
                };
                if (alive _roadblocks && {!_enabled}) then {
                    _markers append [[format["roadblocks_%1",_id],getposATL _roadblocks,"ELLIPSE", [_size,_size],"ColorRed","Roadblocks", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
                    _markers append [[format["roadblocksI_%1",_id],getposATL _roadblocks,"ICON", [0.1,0.1],"ColorRed","Roadblocks", "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal];
                    ["installation", _roadblocks, "Roadblocks"] call _fnc_log;
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