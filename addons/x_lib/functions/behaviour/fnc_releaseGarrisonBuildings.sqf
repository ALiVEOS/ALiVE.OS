#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(releaseGarrisonBuildings);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_releaseGarrisonBuildings

Description:
Releases every building claimed by a group from the server-authoritative
central garrison occupancy index.
The index is local to the server; callers on other machines are rejected.

Parameters:
Group - Group whose claims should be released

Returns:
Boolean - Whether the release request was valid

Examples:
(begin example)
[_group] call ALiVE_fnc_releaseGarrisonBuildings;
(end)

Author:
ALiVE Dev Team
---------------------------------------------------------------------------- */

params [["_group", grpNull, [grpNull]]];

if (!isServer) exitWith {false};
if (isNull _group) exitWith {false};

private _claimHashes = _group getVariable "alive_garrison_building_claim_hashes";
if (isNil "_claimHashes") exitWith {true};

if (isNil "ALiVE_garrisonBuildingOccupancyIndex") then {
    ALiVE_garrisonBuildingOccupancyIndex = createHashMap;
};

{
    private _hash = _x;
    private _bucket = ALiVE_garrisonBuildingOccupancyIndex getOrDefault [_hash, []];

    if !(_bucket isEqualTo []) then {
        {
            if ((_x select 1) isEqualTo _group) then {
                _bucket deleteAt _forEachIndex;
            };
        } forEachReversed _bucket;

        if (_bucket isEqualTo []) then {
            ALiVE_garrisonBuildingOccupancyIndex deleteAt _hash;
        };
    };
} forEach _claimHashes;

_group setVariable ["alive_garrison_building_claim_hashes", nil];
true;
