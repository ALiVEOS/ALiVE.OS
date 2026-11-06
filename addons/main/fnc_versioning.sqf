#include "\x\alive\addons\main\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */
private ["_version","_build"];

//Only clients
if !(hasInterface) exitwith {};

//If "Requires ALiVE"-module option is set to kick then kick - ignore devs
if (MAJOR != 0) then {
    [] spawn {
        waituntil {!(isnull player)};
        sleep 30;
        // the version as the start-up line gives it, read from the packed config: BUILD on its own is a number
        // past 1e6, which format prints as 2.60413e+06
        private _version = getText (configFile >> "CfgPatches" >> QUOTE(ADDON) >> "versionStr");
        if (_version isEqualTo "") then { _version = format ["%1.%2.%3.%4", MAJOR, MINOR, PATCHLVL, (BUILD) toFixed 0] };
        ["ALiVE", format["Warning: Your ALiVE version %1 doesn't match the server's version!", _version]] call ALIVE_fnc_sendHint;
        sleep 10;

        if (!isnil QMOD(VERSIONINGTYPE) && {MOD(VERSIONINGTYPE) == "kick"}) then {["LOSER",false,true] call BIS_fnc_endMission};
    };
};