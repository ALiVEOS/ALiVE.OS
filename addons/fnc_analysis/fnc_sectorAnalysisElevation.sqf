#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(sectorAnalysisElevation);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisElevation

Description:
Sample sector-center elevation. LAND and SHORE reuse one hidden local pointer per
call, preserving marker placement on terrain whose direct height query differs. SEA
samples retain a fresh pointer lifecycle to preserve wave-dependent depth. Local
pointers avoid publishing temporary sampling objects over the network. The
pointer preserves the original water/surface placement semantics of setPos:
SEA stores negative ATL, other terrain types store ASL. Input sample positions,
ordering and sector data fields are preserved. Near-zero ASL samples use a
fresh marker to preserve their sign partition.

Parameters:
Array - Sectors

Returns:
Nothing

Author:
ARJay
---------------------------------------------------------------------------- */

params [["_sectors", [], [[]]]];
// Keep the original pointer class, binary creation placement and subsequent
// setPos. A new local pointer is still created for every SEA/near-zero sample.
private _spawnPointer = {
    private _position = _this select 0;
    private _pointer = "Sign_Pointer_Green_F" createVehicleLocal _position;
    _pointer setPos _position;
    _pointer
};
private _marker = objNull;
PROFILE_SCOPE(ELEVATION, "ALiVE_fnc_sectorAnalysisElevation: sample")
{
    private _center = [_x, "position"] call ALIVE_fnc_hashGet;
    private _data = [_x, "data"] call ALIVE_fnc_hashGet;
    private _terrain = [_data, "terrain"] call ALIVE_fnc_hashGet;
    private _elevation = 0;
    if (_terrain == "SEA") then {
        private _seaMarker = [_center] call _spawnPointer;
        hideObject _seaMarker;
        _elevation = (getPosATL _seaMarker) select 2;
        _elevation = _elevation - (_elevation * 2);
        deleteVehicle _seaMarker;
    } else {
        if (isNull _marker) then {
            _marker = [_center] call _spawnPointer;
            hideObject _marker;
        } else {
            _marker setPos _center;
        };
        _elevation = (getPosASL _marker) select 2;
        // Preserve the original sign partition at the water/zero boundary.
        // Reusing a pointer can differ by a few float units near zero.
        if (abs _elevation <= 0.0001) then {
            private _zeroMarker = [_center] call _spawnPointer;
            hideObject _zeroMarker;
            _elevation = (getPosASL _zeroMarker) select 2;
            deleteVehicle _zeroMarker;
        };
    };
    // Preserve the existing data hash, key ordering and center reference.
    [_data, "elevationSamples", [[_center, _elevation]]] call ALIVE_fnc_hashSet;
    [_data, "elevation", _elevation] call ALIVE_fnc_hashSet;
} forEach _sectors;
if (!isNull _marker) then {deleteVehicle _marker;};
PROFILE_SCOPE_END(ELEVATION)
