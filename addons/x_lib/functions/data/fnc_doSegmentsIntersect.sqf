#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(doSegmentsIntersect);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_doSegmentsIntersect

Description:
Determines if two line segments intersect eachother

Parameters:
    Segment 1 - Array of two positions
    Segment 2 - Array of two positions

Returns:
    Boolean

Examples:
(begin example)
private _segment1 = [[0,0],[1,1]];
private _segment2 = [[0,1],[2,1]];
[_segment1, _segment2] call ALiVE_fnc_findMidpoints;
(end)

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

params ["_segment1","_segment2"];

_segment1 params ["_segment1X","_segment1Y"];
_segment2 params ["_segment2X","_segment2Y"];

private _dir1 = [_segment1X, _segment1Y, _segment2X] call ALiVE_fnc_findOffsetFromSegment;
private _dir2 = [_segment1X, _segment1Y, _segment2Y] call ALiVE_fnc_findOffsetFromSegment;
private _dir3 = [_segment2X, _segment2Y, _segment1X] call ALiVE_fnc_findOffsetFromSegment;
private _dir4 = [_segment2X, _segment2Y, _segment1Y] call ALiVE_fnc_findOffsetFromSegment;

if (_dir1 != _dir2 && _dir3 != _dir4) exitwith { true };

if (_dir1 == 0 && { ([_segment1X, _segment2X, _segment1Y] call ALiVE_fnc_findOffsetFromSegment) == 0 }) exitwith { true };
if (_dir2 == 0 && { ([_segment1X, _segment2Y, _segment1Y] call ALiVE_fnc_findOffsetFromSegment) == 0 }) exitwith { true };
if (_dir3 == 0 && { ([_segment2X, _segment2X, _segment2Y] call ALiVE_fnc_findOffsetFromSegment) == 0 }) exitwith { true };
if (_dir4 == 0 && { ([_segment2X, _segment1Y, _segment2Y] call ALiVE_fnc_findOffsetFromSegment) == 0 }) exitwith { true };

false