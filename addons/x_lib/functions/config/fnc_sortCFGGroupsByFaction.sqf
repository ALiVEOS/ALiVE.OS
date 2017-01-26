#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sortCFGGroupsByFaction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sortCFGGroupsByFaction

Description:
Sorts CFGGroups into a hash by faction

Parameters:

STRING - side to filter by

Returns:
Array - hash of groups

Examples:
(begin example)
//
_result = ["WEST","BLU_F"] call ALIVE_fnc_sortCFGGroupsByFaction;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_configPath","_sortedGroups","_factionClass","_factionName","_factionConfigName","_factionConfig",
"_categories","_categoryClass","_categoryName","_categoryConfigName","_categoryConfig","_groups","_groupClass","_groupName",
"_groupConfigName"];

params ["_side","_faction"];

if(_side == "GUER") then {
    _side = "INDEP";
};

_configPath = _faction call ALiVE_fnc_configGetFactionGroups;

_sortedGroups = [] call ALIVE_fnc_hashCreate;
_categories = [] call ALIVE_fnc_hashCreate;

for "_i" from 0 to ((count _configPath) - 1) do
{

    _categoryClass = _configPath select _i;

    if (isClass _categoryClass) then {

        _categoryName = getText(_categoryClass >> "name");
        _categoryConfigName = configName _categoryClass;
        _categoryConfig = (_configPath >> _categoryConfigName);

        _groups = [] call ALIVE_fnc_hashCreate;

        for "_i" from 0 to ((count _categoryConfig) - 1) do
        {

            _groupClass = _categoryConfig select _i;

            if (isClass _groupClass) then {

                _groupConfigName = configName _groupClass;

                if!(_groupConfigName in ALiVE_PLACEMENT_GROUPBLACKLIST) then {

                    _groupName = getText(_groupClass >> "name");

                    [_groups,_groupConfigName,_groupName] call ALIVE_fnc_hashSet;

                };

            };
        };

        [_categories,_categoryConfigName,_groups] call ALIVE_fnc_hashSet;
    };
};

[_sortedGroups,_faction,_categories] call ALIVE_fnc_hashSet;

//_sortedGroups call ALIVE_fnc_inspectHash;

_sortedGroups
