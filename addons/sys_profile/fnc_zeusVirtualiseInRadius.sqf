#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(zeusVirtualiseInRadius);

/*
 * Handles the client-local Zeus module and sends an authoritative
 * virtualisation request to the server.
 */

params [
    ["_logic", objNull, [objNull]],
    ["_synced", [], [[]]],
    ["_activated", true, [true]]
];

if (isNull _logic || {!_activated}) exitWith {false};
if (!hasInterface) exitWith {
    deleteVehicle _logic;
    false
};

if (isNil QMOD(SYS_PROFILE)) exitWith {
    deleteVehicle _logic;
    [] call ALIVE_fnc_showVirtualiseUnavailable;
    false
};

private _position = getPosATL _logic;

uiNamespace setVariable ["ALiVE_virtualiseRadiusResult", nil];

disableSerialization;

private _parentDisplay = findDisplay 312;
if (isNull _parentDisplay) then {
    _parentDisplay = findDisplay 46;
};

if (isNull _parentDisplay) exitWith {
    deleteVehicle _logic;
    false
};

private _radiusDisplay = _parentDisplay createDisplay "ALiVE_RscVirtualiseRadius";
if (isNull _radiusDisplay) exitWith {
    deleteVehicle _logic;
    false
};

waitUntil { isNull _radiusDisplay };

private _radiusText = uiNamespace getVariable ["ALiVE_virtualiseRadiusResult",""];
uiNamespace setVariable ["ALiVE_virtualiseRadiusResult", nil];
deleteVehicle _logic;

if (_radiusText isEqualTo "") exitWith {false};

private _radius = parseNumber _radiusText;
if (_radius <= 0) exitWith {
    ["STR_ALIVE_PROFILE_VIRTUALISE_INVALID_RADIUS"] call ALIVE_fnc_showVirtualiseUnavailable;
    false
};

[
    _position,
    _radius,
    player
] remoteExecCall ["ALIVE_fnc_virtualiseInRadius", 2];

true
