#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(sectorAnalysisElevation);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisElevation

Description:
Sample sector-center elevation. LAND and SHORE reuse one hidden pointer per
call, preserving marker placement on terrain whose direct height query differs. SEA
samples retain the original pointer lifecycle to preserve wave-dependent depth. The
pointer preserves the original water/surface placement semantics of setPos:
SEA stores negative ATL, other terrain types store ASL. Input sample positions,
ordering and sector data fields are preserved. Near-zero ASL samples use a
fresh marker to preserve their sign partition.

Parameters:
Array - Sectors
HashMap - Optional output metrics

Returns:
Nothing

Author:
ARJay
---------------------------------------------------------------------------- */

params [["_sectors", [], [[]]], ["_metrics", createHashMap]];
private _instrument = count _this > 1;
private _started = diag_tickTime;
private _marker = objNull;
private _directSamples = 0;
private _pointerSamples = 0;
private _created = 0;
PROFILE_SCOPE(ELEVATION, "ALiVE_fnc_sectorAnalysisElevation: sample")
{
    private _center = [_x, "center"] call ALIVE_fnc_sector;
    private _data = [_x, "data"] call ALIVE_fnc_sector;
    private _terrain = [_data, "terrain"] call ALIVE_fnc_hashGet;
    private _elevation = 0;
    if (_terrain == "SEA") then {
        private _seaMarker = [_center] call ALIVE_fnc_spawnDebugMarker;
        hideObjectGlobal _seaMarker;
        _elevation = (getPosATL _seaMarker) select 2;
        _elevation = _elevation - (_elevation * 2);
        deleteVehicle _seaMarker;
        if (_instrument) then {_created = _created + 1; _pointerSamples = _pointerSamples + 1;};
    } else {
        if (isNull _marker) then {
            _marker = [_center] call ALIVE_fnc_spawnDebugMarker;
            hideObjectGlobal _marker;
            if (_instrument) then {_created = _created + 1;};
        } else {
            _marker setPos _center;
        };
        _elevation = (getPosASL _marker) select 2;
        // Preserve the original sign partition at the water/zero boundary.
        // Reusing a pointer can differ by a few float units near zero.
        if (abs _elevation <= 0.0001) then {
            private _zeroMarker = [_center] call ALIVE_fnc_spawnDebugMarker;
            hideObjectGlobal _zeroMarker;
            _elevation = (getPosASL _zeroMarker) select 2;
            deleteVehicle _zeroMarker;
            if (_instrument) then {_created = _created + 1;};
        };
        if (_instrument) then {_pointerSamples = _pointerSamples + 1;};
    };
    [_x, "data", ["elevationSamples", [[_center, _elevation]]]] call ALIVE_fnc_sector;
    [_x, "data", ["elevation", _elevation]] call ALIVE_fnc_sector;
} forEach _sectors;
if (!isNull _marker) then {deleteVehicle _marker;};
if (_instrument) then {
    _metrics set ["samples", count _sectors];
    _metrics set ["directSamples", _directSamples];
    _metrics set ["pointerSamples", _pointerSamples];
    _metrics set ["objectsCreated", _created];
    _metrics set ["objectsDeleted", _created];
    _metrics set ["totalSeconds", diag_tickTime - _started];
};
PROFILE_SCOPE_END(ELEVATION)
