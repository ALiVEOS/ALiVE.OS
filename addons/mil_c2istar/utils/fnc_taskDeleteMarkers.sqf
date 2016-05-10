#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskDeleteMarkers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskDeleteMarkers

Description:
Delet a local marker

Parameters:

Returns:

Examples:
(begin example)
// delete marker
[_taskID] call ALIVE_fnc_taskDeleteMakers;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_taskID","_markerColour","_markerText","_markerType","_markerDimensions",
"_markerAlpha","_markerShape","_markerBrush","_taskMarkers","_m"];

_taskID = _this select 0;

// if the clients task markers hash exists
if!(isNil "ALIVE_taskMarkers") then {

    // get the markers array for this task
    // on this client, delete any already existing markers

    if(_taskID in (ALIVE_taskMarkers select 1)) then {

        _taskMarkers = [ALIVE_taskMarkers,_taskID] call ALIVE_fnc_hashGet;

        {
            deleteMarkerLocal _x;
        } forEach _taskMarkers;

        [ALIVE_taskMarkers,_taskID] call ALIVE_fnc_hashRem;

    };


};