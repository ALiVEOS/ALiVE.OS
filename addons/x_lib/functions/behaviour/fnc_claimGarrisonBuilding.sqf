#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(claimGarrisonBuilding);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_claimGarrisonBuilding

Description:
Claims a building for a group in the server-authoritative central garrison
occupancy index.
Object keys are stored in collision-safe hashValue buckets because Objects
cannot be used directly as HashMap keys.
The index is local to the server; callers on other machines are rejected.

Parameters:
Object - Building to claim
Group - Claiming group

Returns:
Boolean - Whether the building is owned by the requesting group

Examples:
(begin example)
private _claimed = [_building, _group] call ALiVE_fnc_claimGarrisonBuilding;
(end)

Author:
ALiVE Dev Team
---------------------------------------------------------------------------- */

params [
    ["_building", objNull, [objNull]],
    ["_group", grpNull, [grpNull]]
];

if (!isServer) exitWith {false};
if (isNull _building || {isNull _group}) exitWith {false};

if (isNil "ALiVE_garrisonBuildingOccupancyIndex") then {
    ALiVE_garrisonBuildingOccupancyIndex = createHashMap;
};

private _hash = hashValue _building;
private _bucket = ALiVE_garrisonBuildingOccupancyIndex getOrDefault [_hash, [], true];
private _buildingIndex = _bucket findIf {(_x select 0) isEqualTo _building};
private _claimed = false;

if (_buildingIndex < 0) then {
    _bucket pushBack [_building, _group];
    _claimed = true;
} else {
    private _owner = (_bucket select _buildingIndex) select 1;

    if (_owner isEqualTo _group) then {
        _bucket set [_buildingIndex, [_building, _group]];
        _claimed = true;
    };
};

if (_claimed) then {
    private _claimHashes = _group getVariable "alive_garrison_building_claim_hashes";
    if (isNil "_claimHashes") then {
        _claimHashes = createHashMap;
        _group setVariable ["alive_garrison_building_claim_hashes", _claimHashes];
    };
    _claimHashes set [_hash, true];
};

_claimed;
