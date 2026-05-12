/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_findHouse
Description:
    Searches for the best nearby building for a civilian to shelter in during
    a panic state. Scores candidate buildings within ALiVE_advciv_fleeRadius
    based on proximity to the unit, distance from the danger source, number
    of available interior positions, proximity to the unit's home position,
    and current civilian occupancy. Returns the highest-scoring building and
    its ground-floor safe positions.
Parameters:
    _this select 0: OBJECT - The civilian unit seeking shelter
Returns:
    ARRAY - [building OBJECT, positions ARRAY]
            building: the selected shelter building, or objNull if none found
            positions: array of safe interior positions (AGL) within that building
See Also:
    ALIVE_fnc_advciv_getSafePositions, ALIVE_fnc_advciv_brainTick
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_radius", -1, [0]]];

if (isNull _unit) exitWith {[objNull, []]};

// Default radius is the module-configured fleeRadius. Callers (notably
// fnc_advciv_findHouseProgressive) override this to do a wider sweep when
// the default radius has nothing usable - e.g. civs stranded mid-bridge or
// on open runways where the nearest building is genuinely beyond fleeRadius.
if (_radius < 0) then { _radius = ALiVE_advciv_fleeRadius; };

private _panicSource   = _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
private _homePos       = _unit getVariable ["ALiVE_advciv_homePos", getPos _unit];
private _buildings     = nearestObjects [_unit, ["House", "Building"], _radius];
private _bestBuilding  = objNull;
private _bestPositions = [];
private _bestScore     = -999;

{
    private _bld = _x;
    // Only consider buildings that have usable interior positions at ground level
    private _positions = [_bld, 3.5, _unit] call ALiVE_fnc_advciv_getSafePositions;

    if (count _positions > 0) then {
        private _distToUnit     = _unit distance _bld;
        private _distFromDanger = 0;
        if !(_panicSource isEqualTo [0,0,0]) then {
            _distFromDanger = _bld distance _panicSource;
        };

        // Score formula balances proximity to the unit against distance from
        // danger, interior capacity, and proximity to home.
        // More positions = higher score (more room = better shelter)
        // Closer to home = preferred to prevent civilians straying too far
        private _score = (100 - _distToUnit)
                       + (_distFromDanger * 0.5)
                       + (count _positions) * 5
                       - ((_bld distance _homePos) * 0.3);

        // Penalise buildings that already have civilians inside to spread sheltering
        private _civInside = {
            alive _x && {side _x == civilian} && {!isPlayer _x} && {_x != _unit}
        } count (_bld nearEntities ["CAManBase", 15]);

        _score = _score - (_civInside * 15);

        if (_score > _bestScore) then {
            _bestScore     = _score;
            _bestBuilding  = _bld;
            _bestPositions = _positions;
        };
    };
} forEach _buildings;

[_bestBuilding, _bestPositions]
