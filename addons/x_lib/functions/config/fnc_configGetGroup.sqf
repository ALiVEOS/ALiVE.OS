#include <\x\alive\addons\x_lib\script_component.hpp>
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
_result = "OIA_InfWepTeam" call ALIVE_fnc_configGetGroup;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_groupClass","_result","_groupData","_config","_factionGroups","_faction"];

_faction = _this select 0;
_groupClass = _this select 1;

// instantiate static vehicle position data
if(isNil "ALIVE_groupConfig") then {
	[] call ALIVE_fnc_groupGenerateConfigData;
};

_groupClass = format ["%1_%2", _faction, _groupClass];

// get the class config path from the static group config data store
_groupData = [ALIVE_groupConfig, _groupClass] call ALIVE_fnc_hashGet;
_config = [];

if!(isNil "_groupData") then {
	//["CDATA: %1 %2",_groupData,_groupClass] call ALIVE_fnc_dump;
	//["CDATA COUNT: %1 %2",count _groupData,_groupClass] call ALIVE_fnc_dump;
	_config = (configFile >> "CfgGroups");

	for "_i" from 0 to count _groupData -1 do {
		_config = _config select (_groupData select _i);
	};

	//["CFG: %1 %2",_config,_groupClass] call ALIVE_fnc_dump;
};

_config