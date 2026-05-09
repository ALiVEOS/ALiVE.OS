#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(neighbourAwareSearchCap);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_neighbourAwareSearchCap

Description:
    Computes a search-radius ceiling that respects sibling ALiVE
    placement-class module logics. Starts at _baseRadius and shrinks
    for each close neighbour (half-distance to the nearest other
    module is the limit), then clamps the result to [_floor, _ceiling].

    The function only ever shrinks - it never grows past _baseRadius.
    Callers that want an "expand up to a hard ceiling, shrink for
    neighbours" semantic should pass _baseRadius = _ceiling. Callers
    with a fixed preferred radius (already an upper bound) should
    pass that as _baseRadius and use _ceiling as a safety clamp.

    Currently consumed by:
      - fnc_spawnObjectiveObjects (#875) - base = caller's preferred
        radius (typically 150-350m), ceiling 400
      - mil_placement_custom/fnc_CMP - composition tier loop, base =
        ceiling 800 (expand-up-to semantic), floor 300
      - mil_placement/fnc_MP - FieldHQ + Random Camps, base = ceiling
        800 (expand-up-to), floors _size / 500

    Sibling classes scanned:
      ALiVE_mil_placement / ALiVE_mil_placement_custom /
      ALiVE_mil_placement_spe / ALiVE_civ_placement /
      ALiVE_civ_placement_custom / ALiVE_mil_ato

Parameters:
    _logic     : OBJECT - calling module logic (excluded from neighbour scan)
    _centerPos : ARRAY  - [x, y, z] reference centre for distance calc
    _baseRadius: SCALAR - starting radius. Function shrinks from here
                          for close neighbours but never grows past it.
                          Pass _ceiling here for expand-up-to semantic.
    _floor     : SCALAR - never return less than this
    _ceiling   : SCALAR - never return more than this

Returns:
    NUMBER - clamped search radius

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_logic", objNull, [objNull]],
    ["_centerPos", [0,0,0], [[]], [2,3]],
    ["_baseRadius", 300, [0]],
    ["_floor", 50, [0]],
    ["_ceiling", 800, [0]]
];

private _searchRadius = _baseRadius;
private _neighbours = [];
{
    _neighbours = _neighbours + (allMissionObjects _x);
} forEach ["ALiVE_mil_placement", "ALiVE_mil_placement_custom",
           "ALiVE_mil_placement_spe", "ALiVE_civ_placement",
           "ALiVE_civ_placement_custom", "ALiVE_mil_ato"];
_neighbours = _neighbours - [_logic];

{
    private _gap = (position _x) distance2D _centerPos;
    if (_gap > 0 && {_gap / 2 < _searchRadius}) then {
        _searchRadius = _gap / 2;
    };
} forEach _neighbours;

if (_searchRadius < _floor) then { _searchRadius = _floor };
if (_searchRadius > _ceiling) then { _searchRadius = _ceiling };

_searchRadius
