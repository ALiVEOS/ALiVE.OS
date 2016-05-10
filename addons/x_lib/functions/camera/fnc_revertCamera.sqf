#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(revertCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_revertCamera

Description:
Reverts camera to original object
To be called after switch camera shot completed

Parameters:
Boolean - enable player movement

Returns:


Examples:
(begin example)
[true] call ALIVE_fnc_revertCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_enablePlayer"];

_enablePlayer = _this select 0;

if(_enablePlayer) then
{
    disableUserInput false;
};

ALIVE_cameraTakenFrom switchCamera ALIVE_cameraTakenFromView;