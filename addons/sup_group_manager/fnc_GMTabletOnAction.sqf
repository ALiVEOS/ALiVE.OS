#include <\x\alive\addons\sup_group_manager\script_component.hpp>
SCRIPT(GMTabletOnAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_GMTabletOnAction
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

[MOD(SUP_GROUP_MANAGER),"tabletOnAction",[_this select 0,_this select 1]] call ALIVE_fnc_GM;
