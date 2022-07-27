#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(findOffsetFromSegment);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findOffsetFromSegment

Description:
Calculates which side of a line segment a point lies

Parameters:
    Segment - Array of two positions
    Point - Position

Returns:
    offset < 0 - point lies left of line segment
    offset > 0 - point lies right of line segment
    offset == 0 - point lies on line segment


Examples:
(begin example)
private _segment = [[0,0],[1,1]];
private _point = [1,0];
private _offset = [_segment, _point] call ALiVE_fnc_findOffsetFromSegment;
(end)

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

params ["_segmentPoint1","_segmentPoint2","_point"];

_segmentPoint1 params ["_segmentPoint1X","_segmentPoint1Y"];

private _offset = (((_point select 1) - _segmentPoint1Y) * ((_segmentPoint2 select 0) - _segmentPoint1X))
-
(((_segmentPoint2 select 1) - _segmentPoint1Y) * ((_point select 0) - _segmentPoint1X));

if (_offset < 0) then {
    -1
} else {
    if (_offset > 0) then {
        1
    } else {
        0
    };
};