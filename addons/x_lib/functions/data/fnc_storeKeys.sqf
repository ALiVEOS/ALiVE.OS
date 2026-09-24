#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(storeKeys);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_storeKeys

Description:
The name a mission's saved data is kept under on this map, and the name it was
kept under before saves were split by map.

missionName drops the map from the mission folder name, so MyMission.Stratis and
MyMission.Tanoa both report "MyMission" and used to share one save. The map now
follows a colon, which a Windows folder name cannot contain, so no mission's name can be
read as another mission's name on another map. An underscore could: mission
"Op_Altis" would look like mission "Op" on Altis.

Parameters:
String - suffix for a store kept apart from the module saves, such as "_TASK"
         or "_ATO_BLU_F_0" (optional, default "")

Returns:
Array - [name on this map, old name without the map]

Examples:
(begin example)
_key = ([""] call ALiVE_fnc_storeKeys) select 0;      // "ALiVE_MyMission:Stratis"
_key = (["_TASK"] call ALiVE_fnc_storeKeys) select 0; // "ALiVE_MyMission:Stratis_TASK"
(end)

See Also:
ALiVE_fnc_storeKeysOwned, ALiVE_fnc_storeMigrate

Author:
Jman
---------------------------------------------------------------------------- */

params [["_suffix", "", [""]]];

private _mission = [missionName, "%20", "-"] call CBA_fnc_replace;

[
    format ["%1_%2:%3%4", ALIVE_sys_data_GROUP_ID, _mission, worldName, _suffix],
    format ["%1_%2%3", ALIVE_sys_data_GROUP_ID, _mission, _suffix]
]
