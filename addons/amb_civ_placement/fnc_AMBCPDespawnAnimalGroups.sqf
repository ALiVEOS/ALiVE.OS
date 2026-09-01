#include "\x\alive\addons\amb_civ_placement\script_component.hpp"
SCRIPT(AMBCPDespawnAnimalGroups);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AMBCPDespawnAnimalGroups
Description:
Delete the physical units for ambient animal-group registry entries.

Parameters:
Array - Animal group entries. Each entry must contain:
    [position, className, groupSize, spawnedUnits, kind, ...]
    Additional fields, such as the owning cluster ID, are preserved.

Returns:
Number - Number of animal units deleted.

Notes:
The function clears only the spawnedUnits field (index 3), leaving the group
entry available for a later cluster activation.
---------------------------------------------------------------------------- */

params [
    ["_animalGroups", [], [[]]]
];

if (!isServer) exitWith {0};

private _despawnedUnitCount = 0;

{
    private _animalGroup = _x;
    if (_animalGroup isEqualType [] && {count _animalGroup >= 4}) then {
        private _units = _animalGroup param [3, []];
        {
            deleteVehicle _x;
        } forEach _units;

        _despawnedUnitCount = _despawnedUnitCount + count _units;
        _animalGroup set [3, []];
    };
} forEach _animalGroups;

_despawnedUnitCount
