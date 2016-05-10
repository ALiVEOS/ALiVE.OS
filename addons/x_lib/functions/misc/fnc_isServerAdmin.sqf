#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(isServerAdmin);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isServerAdmin
Description:
Checks if a player is currently logged in as server admin.

Parameters:
Nil

Returns:
Bool - Returns true if server admin or in editor/single player

Examples:
(begin example)
// Create instance
_isAdmin = call ALIVE_fnc_isServerAdmin;
(end)

See Also:
- nil

Author:
Wolffy.au

Peer reviewed:
nil
---------------------------------------------------------------------------- */

serverCommandAvailable "#kick" || !isMultiplayer;