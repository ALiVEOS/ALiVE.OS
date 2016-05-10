#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sortCFGGroupsBySide);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sortCFGGroupsBySide

Description:
Sorts CFGGroups into a hash by side

Parameters:

STRING - side to filter by

Returns:
Array - hash of groups

Examples:
(begin example)
//
_result = [] call ALIVE_fnc_sortCFGGroupsBySide;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_side","_configPath","_sortedGroups","_factionClass","_factionName","_factionConfigName","_factionConfig",
"_categories","_categoryClass","_categoryName","_categoryConfigName","_categoryConfig","_groups","_groupClass","_groupName",
"_groupConfigName"];

_side = _this select 0;

_configPath = configFile >> "CFGGroups" >> _side;
_sortedGroups = [] call ALIVE_fnc_hashCreate;

for "_i" from 0 to ((count _configPath) - 1) do
{

    private ["_item","_configName","_name"];

    _factionClass = _configPath select _i;

    if (isClass _factionClass) then {

        _factionName = getText(_factionClass >> "name");
        _factionConfigName = configName _factionClass;
        _factionConfig = (_configPath >> _factionConfigName);

        _categories = [] call ALIVE_fnc_hashCreate;

        for "_i" from 0 to ((count _factionConfig) - 1) do
        {

            _categoryClass = _factionConfig select _i;

            if (isClass _categoryClass) then {

                _categoryName = getText(_categoryClass >> "name");
                _categoryConfigName = configName _categoryClass;
                _categoryConfig = (_factionConfig >> _categoryConfigName);

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

        [_sortedGroups,_factionConfigName,_categories] call ALIVE_fnc_hashSet;

    };
};

//_sortedGroups call ALIVE_fnc_inspectHash;

_sortedGroups
