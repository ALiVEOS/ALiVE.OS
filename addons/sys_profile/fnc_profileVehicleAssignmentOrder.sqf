#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleAssignmentOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentOrder

Description:
Orders boarding or dismounting on the entity group's owner. Each entity/vehicle
pair has a revision, so cancellation supersedes queued boarding. The server
retries the current order until its current owner acknowledges execution.

Parameters:
Group - Entity group
Array - Assignment units, in the six vehicle-role arrays
Object - Vehicle
String - Vehicle profile ID
Boolean - True to board, false to dismount
Number - Internal revision, assigned by the server when omitted

Returns:
Boolean - True when acknowledged, superseded, or no longer applicable; false while
pending. Acknowledgement confirms the order was issued, not that boarding finished.
---------------------------------------------------------------------------- */

params ["_group", "_assignments", "_vehicle", "_vehicleID", "_mount", ["_revision", -1]];
if (isNull _group || {isNull _vehicle} || {_mount && {!alive _vehicle}}) exitWith {true};
private _key = "ALIVE_profileVehicleOrder_" + _vehicleID;
private _ackKey = _key + "_ack";

if (_revision < 0) exitWith {
    if (!isServer) exitWith {true};
    _revision = ((_group getVariable [_key, [0]]) select 0) + 1;
    _group setVariable [_key, [_revision, _mount], true];
    private _args = [_group, _assignments, _vehicle, _vehicleID, _mount, _revision];
    private _complete = _args call ALIVE_fnc_profileVehicleAssignmentOrder;
    if (!_complete) then {
        [{
            params ["_args", "_handle"];
            if (_args call ALIVE_fnc_profileVehicleAssignmentOrder) then {
                [_handle] call CBA_fnc_removePerFrameHandler;
            };
        }, 2, _args] call CBA_fnc_addPerFrameHandler;
    };
    _complete
};

// A request may arrive before its published revision. Only the server tracks retries.
if !((_group getVariable [_key, []]) isEqualTo [_revision, _mount]) exitWith {true};
private _owner = if (isServer) then {groupOwner _group} else {clientOwner};
if ((_group getVariable [_ackKey, []]) isEqualTo [_revision, _owner]) exitWith {true};
if (!local _group) exitWith {
    if (isServer && {_owner > 0}) then {
        _this remoteExecCall ["ALIVE_fnc_profileVehicleAssignmentOrder", _owner];
    };
    false
};

if (_mount) then {
    [_assignments, _vehicle] call ALIVE_fnc_vehicleMount;
} else {
    // A delayed cancellation must not dismount units now assigned to another vehicle.
    private _currentAssignments = _assignments apply {_x select {assignedVehicle _x == _vehicle}};
    [_currentAssignments, _vehicle] call ALIVE_fnc_vehicleDismount;
    // Also remove a vehicle from the group pool when nobody has boarded yet.
    _group leaveVehicle _vehicle;
};
_group setVariable [_ackKey, [_revision, clientOwner], true];
local _group
