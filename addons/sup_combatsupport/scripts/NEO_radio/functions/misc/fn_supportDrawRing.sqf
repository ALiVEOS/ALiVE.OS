/*
    NEO_fnc_supportDrawRing

    Draws / resizes the target-centred "area of influence" ring on the Combat
    Support tablet map: the CAS engagement radius, or the artillery dispersion
    (beaten zone). One shared local UI marker (NEO_supportMarkerRing) that follows
    the strike/target marker. A radius of 0 or less hides it - a pinpoint strike
    has no area, so the ring simply disappears.

    Params:
        0: _center <ARRAY>  - world position to centre the ring on (unused when hiding)
        1: _radius <NUMBER> - ring radius in metres; <= 0 hides the ring
        2: _color  <STRING> - marker colour (default "ColorOrange")

    Returns: nothing

    Author: Jman
*/

params [["_center", []], ["_radius", 0], ["_color", "ColorOrange"]];

private _ring = NEO_radioLogic getVariable ["NEO_supportMarkerRing", ""];
if (_ring isEqualTo "") exitWith {};

// no meaningful area (e.g. dispersion 0) - hide rather than draw a zero circle
if (_radius <= 0 || {_center isEqualTo []}) exitWith { _ring setMarkerAlphaLocal 0; };

_ring setMarkerShapeLocal "ELLIPSE";
_ring setMarkerBrushLocal "Border";
_ring setMarkerPosLocal _center;
_ring setMarkerSizeLocal [_radius, _radius];
_ring setMarkerColorLocal _color;
_ring setMarkerAlphaLocal 0.8;
