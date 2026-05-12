#include "\x\alive\addons\mil_OPCOM\script_component.hpp"
SCRIPT(INS_disableBuildingInstallations);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_INS_disableBuildingInstallations
Description:
Server-authoritative teardown for asymmetric installations registered on a
building.

Parameters:
_this select 0: building object
_this select 1: caller object
_this select 2: optional subtitle title
_this select 3: optional subtitle text format

Returns:
Nothing

Author:
Javen
---------------------------------------------------------------------------- */

params [
    ["_building", objNull, [objNull]],
    ["_caller", objNull, [objNull]],
    ["_subtitleTitle", "", [""]],
    ["_subtitleText", "", [""]]
];

if !(isServer) exitWith {
    _this remoteExec ["ALiVE_fnc_INS_disableBuildingInstallations", 2];
};

if (isNull _building) exitWith {};

if (isNil "ALiVE_fnc_INS_getBuildingInstallations" || {isNil "ALIVE_fnc_INS_buildingKilledEH"}) then {
    call ALiVE_fnc_INS_helpers;
};

private _installations = [_building] call ALiVE_fnc_INS_getBuildingInstallations;
if (_installations isEqualTo []) exitWith {};

{
    _x params ["_objectiveKey", "_installationVar", "_disabledVar"];
    _building setVariable [_disabledVar, true, true];
} forEach _installations;

[_building, _caller] call ALIVE_fnc_INS_buildingKilledEH;

if (_subtitleTitle != "" && {_subtitleText != ""} && {!isNull _caller}) then {
    [_subtitleTitle, format [_subtitleText, name _caller, mapGridPosition _building]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];
};
