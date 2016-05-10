#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(C2TabletOnAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_C2TabletOnAction
Description:

Sets current tablet action

Parameters:

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(MIL_C2ISTAR),"tabletOnAction",[_this select 0,_this select 1]] call ALIVE_fnc_C2ISTAR;
