#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(virtualiseInRadius);

if (!isServer) exitWith {false};

params [
    ["_position", [], [[]], [2, 3]],
    ["_radius", 100, [0]],
    ["_requester", objNull, [objNull]]
];

if (isNull _requester || { isNull (getAssignedCuratorLogic _requester) }) exitWith {};

if (
    !(missionNamespace getVariable ["ALIVE_profileSystemInit", false])
    || {isNil "ALIVE_profileHandler"}
) exitWith {};

if (_position isEqualTo [] || {_radius <= 0}) exitWith {};

private _groups = allGroups select {
    private _units = units _x;

    (_units findIf {
        private _unit = _x;
        private _vehicle = vehicle _unit;

        isPlayer _unit
        || {
            _vehicle != _unit
            && {(crew _vehicle findIf {isPlayer _x}) >= 0}
        }
    }) == -1 && {
        (_units findIf {
            alive _x
            && {_x distance2D _position <= _radius}
        }) >= 0
    }
};

private _emptyVehicles = vehicles select {
    alive _x
    && {crew _x isEqualTo []}
    && {_x distance2D _position <= _radius}
};

private _createdProfiles = [
    false,
    _groups,
    _emptyVehicles
] call ALIVE_fnc_createProfilesFromUnitsRuntime;

_createdProfiles params [
    "_groupProfiles",
    "_vehicleProfiles"
];

[
    "STR_ALIVE_PROFILE_VIRTUALISE_COMPLETE",
    [count _groupProfiles, count _vehicleProfiles]
] remoteExecCall ["ALIVE_fnc_virtualiseInRadiusResult", _requester];
