#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(versioning);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_versioning

Description:
CBA additional versioning function.
Kicks / or warns players with wrong ALiVE versions.

Parameters:
none

Examples:
(begin example)
call ALIVE_fnc_versioning;
(end)

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */
private ["_version","_build"];

//Only clients
if !(hasInterface) exitwith {};

//If "Requires ALiVE"-module option is set to kick then kick - ignore devs
if (MAJOR != 0) then {
	[] spawn {
	    waituntil {!(isnull player)};
	    sleep 30;
	    hint format["Warning: Your ALiVE version %1.%2.%3.%4 doesnt match the servers version!",MAJOR,MINOR,PATCHLVL,BUILD];
	    sleep 10;

	    if (!isnil QMOD(VERSIONINGTYPE) && {MOD(VERSIONINGTYPE) == "kick"}) then {["LOSER",false,true] call BIS_fnc_endMission};
	};
};