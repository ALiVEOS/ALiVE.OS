//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(setTargets);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setTargets
Description:
Set cluster values on array of clusters

Parameters:
Array - Array of clusters
String - Type of clusters to set
Scalar - Priority of clusters to set
String - Debug color of clusters to set

Returns:
Array - array of clusters with parameters set

Examples:
(begin example)
_main_object = ["MIL", 50, "ColorRed"] call ALIVE_fnc_setTargets;
(end)

See Also:

Author:
Wolffy
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [
    ["_clusters", [], [[]]],
    ["_type", "", [""]],
    ["_priority", 0, [0]],
    ["_debugColour", "ColorRed", ["String"]]
];

["Setting targets"] call ALIVE_fnc_dump;

{
	[_x, "type", _type] call ALIVE_fnc_cluster;
	[_x, "priority", _priority] call ALIVE_fnc_cluster;
	[_x, "debugColor", _debugColour] call ALIVE_fnc_hashSet;
} forEach _clusters;

["Targets Set"] call ALIVE_fnc_dump;

_clusters