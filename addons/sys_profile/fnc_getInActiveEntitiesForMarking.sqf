#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(getInActiveEntitiesForMarking);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getInActiveEntitiesForMarking

Description:
Get an array of entities for marking

Parameters:
Vehicle - The vehicle

Returns:
Array - Hash of profiles linked via vehicle assignments

Examples:
(begin example)
// return an array of entities for marking
_result = [] call ALIVE_fnc_getInActiveEntitiesForMarking;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private["_result"];

_result = [];

if!(isNil "ALIVE_profileHandler") then {
    _result = [ALIVE_profileHandler, "getInActiveEntitiesForMarking"] call ALIVE_fnc_profileHandler;
};

_result
