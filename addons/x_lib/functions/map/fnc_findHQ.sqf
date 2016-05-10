#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findHQ);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findHQ
Description:
Identify potential HQ locations within a radius

Parameters:
Array - A list of HQ objects to identify locations
Array - Position identifying Centre of Mass
Scalar - Max Radius from CoM (optional)

Returns:
Object - A random object from the list within the radius of the position

Examples:
(begin example)
_main_object = [
        ["miloffices"] call ALIVE_fnc_getObjectsByType,
        position player,
        2500
] call ALIVE_fnc_findHQ;
(end)

See Also:
- <ALIVE_fnc_getObjectsByType>

Author:
Wolffy.au
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_obj_array","_pos","_dist","_result"];

// Get array of id's and positions from object index
PARAMS_2(_obj_array,_pos);
DEFAULT_PARAM(2,_dist,2500);

// Exclude objects outside of range
_result = [];
{
        if(_x distance _pos <= _dist) then {
                _result pushback _x;
        };
} forEach _obj_array;

// TODO: If no objects are left, randomly pick a loc and place a camp
if(count _result == 0) then {};

// Randomly pick an object
_result = selectRandom _result;

// Return main building
_result;
