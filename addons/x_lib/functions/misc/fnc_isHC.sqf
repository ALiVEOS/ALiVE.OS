#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(isHC);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isHC
Description:
Initialises isHC to indicate a player is a headless client. Designed to run
once during initialisation and all further checks to use the isHC global variable.

Parameters:
Nil

Returns:
Bool - Returns true if player is a headless client

Examples:
(begin example)
// Create instance
call ALIVE_fnc_isHC;

if(isHC) then {hint "I am a headless client";};
(end)

See Also:
- nil

Author:
Wolffy.au

Peer reviewed:
nil
---------------------------------------------------------------------------- */

isHC = !isDedicated && {!hasInterface};

if (isNil "headlessClients" && isServer) then {
	headlessClients = [];
	publicVariable "headlessClients";
};

if (isHC) then {
    [] spawn {
        waituntil {!isnil "headlessClients" && {!isNull player}};
        
        headlessClients pushback player;
		publicVariable "headlessClients";
    };
};

isHC;