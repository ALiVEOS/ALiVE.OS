#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(debugMarkerOffset);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_debugMarkerOffset
Description:
Returns a stable compass-point offset position for a debug text marker,
keyed on the emitter's registered identifier. Multiple modules stacking
debug markers at the same cluster / objective / sector centre overlap
into unreadable text soup (mil_opcom, fnc_strategic, fnc_analysis all
default to _center). This helper reserves each known emitter a compass
slot on a 75m radius around the anchor so labels fan out instead of
colliding.

Emitters not in the registry fall back to the anchor unchanged, so a
new debug marker call site is opt-in: add a case below and start
using it.

Parameters:
_this select 0: STRING - emitter identifier (see registry below)
_this select 1: ARRAY  - anchor position [x,y] or [x,y,z]

Returns:
ARRAY - offset position [x,y,z]

Examples:
(begin example)
_labelPos = ["opcom", _center] call ALiVE_fnc_debugMarkerOffset;
_m = createMarker [_markerName, _labelPos];
_m setMarkerText "EAST #3";
(end)

Registered emitters (2026-05-04):
    Outer ring (75m):
    "strategic"        cluster label (fnc_strategic/fnc_cluster.sqf)     anchor
    "opcom"            OPCOM objectives (mil_opcom/fnc_OPCOM.sqf)        N +75m
    "analysis.live"    live-analysis type marker (fnc_analysis)          E +75m
    "analysis.sector"  sector ID label (fnc_analysis/fnc_sector.sqf)     S -75m
    "placement.mp"      mil_placement HQ / Field HQ / Camp                W -75m
    "placement.cmp"     mil_placement_custom HQ Building                  NE +75/+75
    "placement.cmp.comp" mil_placement_custom Custom Composition / FieldHQ Fallback  SW -75/-75
    "placement.ato"     mil_ato HQ / Field ATO                            NW -75/+75
    "placement.parking" fnc_strategic getParkingPosition                  SE +75/-75

    Inner ring (40m) - for emitters that may co-exist with the outer
    ring at the same cluster centre. Tighter offsets keep labels close
    enough that the cluster context stays readable while still
    separating the text:
    "placement.cp.roadblock_q" civ_placement / civ_placement_custom
                              roadblock-queue marker                     NNW -40/+40
    "placement.mp.aa"          mil_placement AA unit                     NNE +40/+40
    "placement.cmp.aa"         mil_placement_custom AA unit              SSE +40/-40

Reserved slots for future emitters:
    Inner ring still has ENE / ESE / SSW / WSW / WNW free

Author:
Jman
---------------------------------------------------------------------------- */

params ["_emitterId", "_center"];

private _offset = switch (_emitterId) do {
    case "strategic":                {[  0,   0]};
    case "opcom":                    {[  0,  75]};
    case "analysis.live":            {[ 75,   0]};
    case "analysis.sector":          {[  0, -75]};
    case "placement.mp":             {[-75,   0]};
    case "placement.cmp":            {[ 75,  75]};
    case "placement.cmp.comp":       {[-75, -75]};
    case "placement.ato":            {[-75,  75]};
    case "placement.parking":        {[ 75, -75]};
    case "placement.cp.roadblock_q": {[-40,  40]};
    case "placement.mp.aa":          {[ 40,  40]};
    case "placement.cmp.aa":         {[ 40, -40]};
    default                          {[  0,   0]};
};

[
    (_center select 0) + (_offset select 0),
    (_center select 1) + (_offset select 1),
    _center param [2, 0]
]
