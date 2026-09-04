#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupGenerateConfigData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGenerateConfigData

Description:
Generates a config group hash to store path to config by group name and faction

Parameters:

Returns:


Examples:
(begin example)
[] call ALIVE_fnc_groupGenerateConfigData;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

// Six modules call this, all of them from a scheduled context, and each decides to call
// it by testing ALIVE_groupConfig for nil. That variable is only assigned on the line
// below, several statement boundaries after the caller's test, so a walk that takes the
// better part of a minute let every one of them start its own and hand back a hash the
// others were half way through rebuilding. Claiming the work here covers all six callers
// with one guard, the same way fnc_staticDataHandler claims the static data load.
//
// The claim gets its own variable rather than reusing the finished flag, because five
// waiters test that flag for nil alone. Setting it to false to mean in flight would let
// every one of them through on a config that is not built yet.
if (!isNil "ALiVE_GROUP_CONFIG_BUILDING") exitWith {
    waitUntil {!isNil "ALiVE_GROUP_CONFIG_DATA_GENERATED"};
};
ALiVE_GROUP_CONFIG_BUILDING = true;

ALIVE_groupConfig = [] call ALIVE_fnc_hashCreate;

private _findRecurse = {
    private _root = (_this select 0);
    private _path = +(_this select 1);

    for "_i" from 0 to count _root -1 do {

        private _class = _root select _i;

        if (isClass _class) then {
            private _currentPath = _path + [_i];
            private _className = configName _class;

            if(count _currentPath == 4) then {
                // Hack to add support for factions
                private _configHierarchy = configHierarchy _class;
                private _faction = configname (_configHierarchy select 3);
                _className = format ["%1_%2", _faction, _className];
                [ALIVE_groupConfig, _className, [_configHierarchy select 0,_currentPath]] call ALIVE_fnc_hashSet;
            } else {
                // CfgGroups nests side, faction, category, group, and a path of four is the
                // group itself. Below it sit the group's own unit entries, which the walk used
                // to descend into and then discard one at a time, since only a path of four is
                // ever stored. A squad carries four to sixteen of those, so most of the walk was
                // spent visiting classes that could never be kept.
                [_class, _currentPath] call _findRecurse;
            };
        };
    };
};

[missionConfigFile >> "CfgGroups", []] call _findRecurse;
[configFile >> "CfgGroups", []] call _findRecurse;

ALiVE_GROUP_CONFIG_DATA_GENERATED = true;