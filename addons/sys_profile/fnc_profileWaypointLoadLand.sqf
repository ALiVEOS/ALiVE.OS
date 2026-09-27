#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointLoadLand);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointLoadLand

Description:
Dispatches a LOAD helicopter order to its current owner, retrying every two seconds
until acknowledged. GET IN requires the current visit; NONE releases only its
matching landing and survives waypoint completion or route cancellation. A newer
command supersedes earlier retries, and sequence numbers reject delayed commands.

Parameters:
Object - Helicopter
String - GET IN or NONE
Group - Crew group
Array - LOAD visit [waypoint tag, counter]
Number - Internal command sequence, assigned by the server when omitted

Returns:
Boolean - True when acknowledged, superseded, or no longer applicable; false while
pending. Acknowledgement confirms the order was issued, not that landing finished.
---------------------------------------------------------------------------- */

params ["_vehicle", "_mode", "_group", "_visit", ["_sequence", -1]];
if (!alive _vehicle || {!(_vehicle isKindOf "Helicopter")}) exitWith {true};
if (_sequence < 0) exitWith {
    if (!isServer) exitWith {true};
    _sequence = (_vehicle getVariable ["ALIVE_profileLoadLandSequence", 0]) + 1;
    _vehicle setVariable ["ALIVE_profileLoadLandSequence", _sequence];
    private _args = [_vehicle, _mode, _group, _visit, _sequence];
    private _complete = _args call ALIVE_fnc_profileWaypointLoadLand;
    if (!_complete) then {
        [{
            params ["_args", "_handle"];
            if (_args call ALIVE_fnc_profileWaypointLoadLand) then {
                [_handle] call CBA_fnc_removePerFrameHandler;
            };
        }, 2, _args] call CBA_fnc_addPerFrameHandler;
    };
    _complete
};

if (isServer && {(_vehicle getVariable ["ALIVE_profileLoadLandSequence", 0]) != _sequence}) exitWith {true};
private _owner = if (isServer) then {owner _vehicle} else {clientOwner};
private _command = [_sequence, _group, _visit, _mode, _owner];
private _lastCommand = _vehicle getVariable ["ALIVE_profileLoadLandCommand", [-1]];
if (_sequence < (_lastCommand select 0) || {_lastCommand isEqualTo _command}) exitWith {true};
private _loading = _mode == "GET IN";
if (_loading && {!((_group getVariable ["ALIVE_profileLoadVisit", []]) isEqualTo _visit)}) exitWith {true};
if (!local _vehicle) exitWith {
    _this remoteExecCall ["ALIVE_fnc_profileWaypointLoadLand", _vehicle];
    false
};

private _context = [_group, _visit];
if (_loading || {(_vehicle getVariable ["ALIVE_profileLoadLanding", []]) isEqualTo _context}) then {
    _vehicle land _mode;
    _vehicle setVariable ["ALIVE_profileLoadLanding", if (_loading) then {_context} else {nil}, true];
};
// A cancellation also supersedes a GET IN command that has not arrived yet.
_command set [4, clientOwner];
_vehicle setVariable ["ALIVE_profileLoadLandCommand", _command, true];
local _vehicle
