#include "\x\alive\addons\amb_civ_placement\script_component.hpp"
SCRIPT(AMBCPSpawnAnimalGroups);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AMBCPSpawnAnimalGroups
Description:
Spawn the physical units for ambient animal-group registry entries.

Parameters:
Array - Animal group entries. Each entry must contain:
    [position, className, groupSize, spawnedUnits, kind, ...]
    Additional fields, such as the owning cluster ID, are preserved.

Returns:
Number - Number of animal units created.

Notes:
The function only updates the spawnedUnits field (index 3). It is deliberately
independent of player distance and cluster state so the civilian cluster
activator can own those policy decisions.
---------------------------------------------------------------------------- */

params [
    ["_animalGroups", [], [[]]]
];

if (!isServer) exitWith {0};

private _spawnedUnitCount = 0;

{
    private _animalGroup = _x;
    if (_animalGroup isEqualType [] && {count _animalGroup >= 5}) then {
        _animalGroup params ["_position", "_class", "_groupSize", "_units", "_kind"];

        // A group must remain idempotent while its cluster is active.
        if (_units isEqualTo [] && {_groupSize > 0} && {_class != ""}) then {
            private _spread = if (_kind == "herd") then {12} else {4};
            private _halfSpread = _spread / 2;
            private _newUnits = [];

            for "_i" from 1 to _groupSize do {
                private _offset = _position vectorAdd [
                    (random _spread) - _halfSpread,
                    (random _spread) - _halfSpread,
                    0
                ];
                _newUnits pushBack (createAgent [_class, _offset, [], 0, "CAN_COLLIDE"]);
            };

            _animalGroup set [3, _newUnits];
            _spawnedUnitCount = _spawnedUnitCount + count _newUnits;
        };
    };
} forEach _animalGroups;

_spawnedUnitCount
