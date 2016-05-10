#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(removeLiveFeedCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeLiveFeedCamera

Description:
Create Live Feed

Parameters:

Returns:


Examples:
(begin example)
_camera = [] call ALIVE_fnc_removeLiveFeedCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

[] call BIS_fnc_liveFeedTerminate;