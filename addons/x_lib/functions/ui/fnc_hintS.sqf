#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(hintS);

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
["String"] call ALIVE_fnc_hintS;
(end)

See Also:

Author:
ARJay, Highhead
---------------------------------------------------------------------------- */
hintSilent (_this select 0);