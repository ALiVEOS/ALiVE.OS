#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleCanFitPassengers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleCanFitPassengers

Description:
Read-only passenger capacity check using vehicle configuration and recorded
profile assignments. Does not inspect live occupants or reserve seats.
Already assigned soldiers are excluded, regardless of their assigned vehicle.
Passenger seats include cargo and cargo turrets; crew seats are excluded.

Parameters:
Array - Entity profile
Array - Vehicle profile

Returns:
Scalar - 0 if all unassigned soldiers fit, otherwise the negative number that
cannot fit. Both arguments must be valid profiles of the specified types.

Examples:
_fit = [_entityProfile, _vehicleProfile] call ALIVE_fnc_profileVehicleCanFitPassengers;
// _fit == 0 means everyone fits.
---------------------------------------------------------------------------- */

params ["_profileEntity", "_profileVehicle"];

private _entityData = _profileEntity select 2;

// Do not use profileEntity "unitIndexes": it refreshes the cached unitCount.
private _usedIndexes = (_entityData select 7) call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
private _passengersNeedingSeats = 0;
{
    if !(_forEachIndex in _usedIndexes) then {
        _passengersNeedingSeats = _passengersNeedingSeats + 1;
    };
} forEach (_entityData select 11);

private _emptyPositions = _profileVehicle call ALIVE_fnc_profileVehicleAssignmentGetEmptyPositions;
private _availableSeats = ((_emptyPositions select 4) max 0) + ((_emptyPositions select 5) max 0);
0 min (_availableSeats - _passengersNeedingSeats)
