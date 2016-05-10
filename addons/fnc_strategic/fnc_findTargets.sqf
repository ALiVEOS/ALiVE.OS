//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(findTargets);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findTargets
Description:
Identify targets within the TAOR

Parameters:
Array - A list of objects to identify locations
Array - Position identifying Centre of Mass
Scalar - Max Radius from CoM (optional)

Returns:
Object - A random object from the list within the radius of the position

Examples:
(begin example)
_main_object = [
        ["miloffices"] call ALIVE_fnc_getObjectsByType
] call ALIVE_fnc_findTargets;
(end)

See Also:
- <ALIVE_fnc_getObjectsByType>

Author:
Wolffy.au
Peer Reviewed:
nil
---------------------------------------------------------------------------- */


private ["_logic","_types","_obj_array","_clusters"];

_types = _this param [0, [], [[]]];

["Finding targets"] call ALIVE_fnc_dump;

_obj_array = _types call ALIVE_fnc_getObjectsByType;
_clusters = [_obj_array] call ALIVE_fnc_findClusters;

["Targets found"] call ALIVE_fnc_dump;

_clusters;