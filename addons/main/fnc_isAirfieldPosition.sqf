#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(isAirfieldPosition);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_isAirfieldPosition

Description:
    True when a position is somewhere an aircraft can sensibly be based: on or
    beside a runway, or on a helipad when the airframe is one that uses them.

    The question this answers is "does this aircraft belong here", not "can it
    physically be put down here". A plane sitting in a field has not found a new
    home no matter how flat the field is, because it has nothing to take off
    from. So the runway is the test for anything fixed wing, and proximity to it
    is what makes an apron or a taxiway count as well.

    Runway detection is delegated to ALiVE_fnc_getRunwayCentreline, which
    already prefers mission-authored runway segments and falls back to fitting a
    line through the terrain's runway objects. That means this inherits the same
    coverage, and the same gap: a terrain whose runway is painted ground texture
    with no objects and no authored segments yields nothing, and this correctly
    reports false rather than guessing.

Parameters:
    _position     : ARRAY  - position to test [x,y] or [x,y,z]
    _vehicleClass : STRING - airframe asking. Helicopters and VTOLs also accept
                             a helipad; anything else needs the runway.
                             Defaults to "" which requires the runway.
    _tolerance    : NUMBER - how far from the runway centreline still counts as
                             being at the airfield, in metres. Default 400,
                             which covers aprons, taxiways and dispersals
                             without reaching the next field along.

Returns:
    BOOL - true when the position is a recognised airfield for this airframe.

Examples:
    (begin example)
    private _atBase = [getPosATL _plane, typeOf _plane] call ALiVE_fnc_isAirfieldPosition;
    (end)

See Also:
    ALiVE_fnc_getRunwayCentreline, ALiVE_fnc_getAirfieldGeometry,
    ALiVE_fnc_findAirSpawnPosition

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_position", [], [[]], [2,3]],
    ["_vehicleClass", "", [""]],
    ["_tolerance", 400, [0]]
];

if (count _position < 2) exitWith { false };

// Search wider than the tolerance on purpose. The centreline is fitted from
// whatever runway evidence is nearby, and anchoring that search too tightly
// around an aircraft parked out on a dispersal would clip the far end of the
// runway out of the fit and shorten it below the 200 m span the fitter needs.
private _centreline = [_position, 1500] call ALiVE_fnc_getRunwayCentreline;

if (count _centreline > 1) then {
    _centreline params ["_a", "_b"];

    // Distance to the runway as a line segment, not to its midpoint. A long
    // runway measured from its centre would report an aircraft parked level
    // with the threshold as being a kilometre away from its own airfield.
    private _ax = _a select 0;  private _ay = _a select 1;
    private _bx = _b select 0;  private _by = _b select 1;
    private _px = _position select 0;
    private _py = _position select 1;

    private _dx = _bx - _ax;
    private _dy = _by - _ay;
    private _lenSq = (_dx * _dx) + (_dy * _dy);

    private _dist = if (_lenSq <= 0) then {
        _position distance2D _a
    } else {
        // Projection parameter clamped to the segment, so a position off the
        // end of the runway measures to the threshold rather than to an
        // imaginary extension of the centreline.
        private _t = (((_px - _ax) * _dx) + ((_py - _ay) * _dy)) / _lenSq;
        _t = (_t max 0) min 1;
        _position distance2D [_ax + (_t * _dx), _ay + (_t * _dy)]
    };

    if (_dist <= _tolerance) exitWith { true };
};

// No runway within reach. A helicopter or a VTOL can still be properly based on
// a helipad, so give those airframes the second test. Class list kept identical
// to the air validator's helipad tier so the two agree about what a pad is.
private _usesPads = _vehicleClass != ""
                 && {(_vehicleClass isKindOf "Helicopter")
                     || {(_vehicleClass isKindOf "VTOL_01_base_F")
                         || {_vehicleClass isKindOf "VTOL_02_base_F"}}};

if (_usesPads) exitWith {
    private _padClasses = ["HeliH", "HelipadCircle_F", "HelipadSquare_F", "Land_HelipadEmpty_F", "Land_HelipadSquare_F", "Land_HelipadCircle_F"];
    count (nearestObjects [_position, _padClasses, 60]) > 0
};

false
