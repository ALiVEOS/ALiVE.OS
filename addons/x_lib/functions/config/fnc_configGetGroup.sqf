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
Jman
---------------------------------------------------------------------------- */

params ["_faction","_groupClass"];

// Initialize the group config cache on demand.
if(isNil "ALIVE_groupConfig") then {
    [] call ALIVE_fnc_groupGenerateConfigData;
};

// A name a faction uses in two categories arrives as category>name (#79) and is kept under
// that key; a plain name reads as before. A qualified name the faction doesn't have under that
// category (a remapped faction, say) falls back to the plain name.
private _plain = if (_groupClass isEqualType "") then { _groupClass select [(_groupClass find ">") + 1] } else { str _groupClass };
_groupClass = format ["%1_%2", _faction, _groupClass];

// Return the cached config reference, preserving [] for an unknown group.
private _result = [ALIVE_groupConfig, _groupClass, []] call ALIVE_fnc_hashGet;
if (_result isEqualTo [] && {_plain != (_groupClass select [count _faction + 1])}) then {
    _result = [ALIVE_groupConfig, format ["%1_%2", _faction, _plain], []] call ALIVE_fnc_hashGet;
};
_result
