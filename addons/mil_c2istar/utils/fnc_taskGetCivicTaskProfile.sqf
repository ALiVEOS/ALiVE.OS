#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetCivicTaskProfile);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetCivicTaskProfile

Description:
Get civic-state metadata for a Hearts and Minds task family.

Parameters:
String - Task type

Returns:
Array - Hash with civic-state metadata

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    ["_taskType", "", [""]]
];

private _profile = [] call ALIVE_fnc_hashCreate;
private _primaryAxis = "trust";
private _secondaryAxis = "security";
private _preferredStatusBands = ["Hostile", "Fragile", "Recovering", "Stable"];
private _primaryWeight = 1;
private _secondaryWeight = 0.35;

switch (_taskType) do {
    case "AidDelivery": {
        _primaryAxis = "services";
        _secondaryAxis = "trust";
        _preferredStatusBands = ["Hostile", "Fragile", "Recovering"];
    };
    case "SupplyConvoy": {
        _primaryAxis = "services";
        _secondaryAxis = "security";
        _preferredStatusBands = ["Fragile", "Recovering"];
        _secondaryWeight = 0.45;
    };
    case "MeetLocalLeader": {
        _primaryAxis = "trust";
        _secondaryAxis = "security";
        _preferredStatusBands = ["Fragile", "Recovering", "Stable"];
        _secondaryWeight = 0.3;
    };
    case "VIPEscort": {
        _primaryAxis = "trust";
        _secondaryAxis = "security";
        _preferredStatusBands = ["Recovering", "Stable"];
        _secondaryWeight = 0.4;
    };
    case "SecureCommunityEvent": {
        _primaryAxis = "security";
        _secondaryAxis = "trust";
        _preferredStatusBands = ["Recovering", "Stable"];
        _secondaryWeight = 0.3;
    };
    case "RepairCriticalService": {
        _primaryAxis = "services";
        _secondaryAxis = "security";
        _preferredStatusBands = ["Fragile", "Recovering"];
        _secondaryWeight = 0.45;
    };
    case "MedicalOutreach": {
        _primaryAxis = "services";
        _secondaryAxis = "trust";
        _preferredStatusBands = ["Hostile", "Fragile", "Recovering"];
        _secondaryWeight = 0.4;
    };
    case "CheckpointPartnership": {
        _primaryAxis = "security";
        _secondaryAxis = "trust";
        _preferredStatusBands = ["Hostile", "Fragile", "Recovering"];
        _secondaryWeight = 0.3;
    };
    case "InformantExfiltration": {
        _primaryAxis = "trust";
        _secondaryAxis = "security";
        _preferredStatusBands = ["Hostile", "Fragile", "Recovering"];
        _secondaryWeight = 0.45;
    };
    case "MarketReopening": {
        _primaryAxis = "services";
        _secondaryAxis = "security";
        _preferredStatusBands = ["Recovering", "Stable"];
        _secondaryWeight = 0.45;
    };
};

[_profile, "taskType", _taskType] call ALIVE_fnc_hashSet;
[_profile, "primaryAxis", _primaryAxis] call ALIVE_fnc_hashSet;
[_profile, "secondaryAxis", _secondaryAxis] call ALIVE_fnc_hashSet;
[_profile, "preferredStatusBands", _preferredStatusBands] call ALIVE_fnc_hashSet;
[_profile, "primaryWeight", _primaryWeight] call ALIVE_fnc_hashSet;
[_profile, "secondaryWeight", _secondaryWeight] call ALIVE_fnc_hashSet;

_profile
