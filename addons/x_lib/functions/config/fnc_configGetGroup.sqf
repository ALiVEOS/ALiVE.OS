#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(configGetGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetGroup

Description:
Get a group from the config files by group name

Parameters:
String - Group name

Returns:
Group data

Examples:
(begin example)
// get config group
_result = ["OPF_F","OIA_InfWepTeam"] call ALIVE_fnc_configGetGroup;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_faction","_groupClass"];

// Initialize the group config cache on demand.
if(isNil "ALIVE_groupConfig") then {
    [] call ALIVE_fnc_groupGenerateConfigData;
};

_groupClass = format ["%1_%2", _faction, _groupClass];

// Return the cached config reference, preserving [] for an unknown group.
[ALIVE_groupConfig, _groupClass, []] call ALIVE_fnc_hashGet
