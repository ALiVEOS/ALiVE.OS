#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleAssignmentsGetSpeedPerSecond);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsGetSpeedPerSecond

Description:
Takes vehicle assignments and calculates the max speed for the controlling group

Parameters:
Array - Vehicle assignments
Hash - Entity profile

Returns:

Examples:
(begin example)
// set all entities within vehicle to position
_result = [_vehicleAssignments, _entityProfile] call ALIVE_fnc_profileVehicleAssignmentsGetSpeedPerSecond;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_assignments","_profile"];

private _manSpeedArray = "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond;

private _vehiclesInCommandOf = _profile select 2 select 8;
if (_vehiclesInCommandOf isequalto []) exitwith {
    _manSpeedArray
};

private _unitCount = _profile select 2 select 12;
private _countAssignedUnits = _assignments call ALIVE_fnc_profileVehicleAssignmentsGetCount;

// if there are some non mounted units return walking speed
if (_countAssignedUnits < _unitCount) then {
    _manSpeedArray;
} else {
    private _profilesById = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;

    _result = [];
    {
        private _vehicleProfile = _profilesById get _x;

        if !(isnil "_vehicleProfile") then {
            private _vehicleClass = _vehicleProfile select 2 select 11; //[_vehicleProfile,"vehicleClass"] call ALIVE_fnc_hashGet;
            private _speedArray = _vehicleClass call ALIVE_fnc_vehicleGetSpeedPerSecond;

            if (_result isEqualTo [] || {(_speedArray select 0) < (_result select 0)}) then {
                _result = _speedArray;
            };
        };
    } forEach _vehiclesInCommandOf;

    _result
}
