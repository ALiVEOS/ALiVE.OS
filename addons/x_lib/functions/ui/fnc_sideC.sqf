#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sideC);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpMP

Description:
Only for use with BIS_fnc_MP

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable 
["String"] call ALIVE_fnc_sideC;
(end)

See Also:

Author:
ARJay, Highhead
---------------------------------------------------------------------------- */
player sidechat (_this select 0);