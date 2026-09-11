#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupGenerateConfigData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGenerateConfigData

Description:
Generates a hash of group config references keyed by faction and group name

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
    if (isnil "ALiVE_GROUP_CONFIG_DATA_GENERATED") then {
        waitUntil {!isNil "ALiVE_GROUP_CONFIG_DATA_GENERATED"};
    };
};
ALiVE_GROUP_CONFIG_BUILDING = true;

ALIVE_groupConfig = [] call ALIVE_fnc_hashCreate;

// Preserve traversal order: engine groups overwrite duplicate mission keys.
// Visit only side/faction/category/group classes and retain the config directly.
{
    private _root = _x;
    {
        private _sideConfig = _x;
        {
            private _factionConfig = _x;
            private _faction = configName _factionConfig;
            {
                private _categoryConfig = _x;
                {
                    private _key = format ["%1_%2", _faction, configName _x];
                    [ALIVE_groupConfig, _key, _x] call ALIVE_fnc_hashSet;
                } forEach ("true" configClasses _categoryConfig);
            } forEach ("true" configClasses _factionConfig);
        } forEach ("true" configClasses _sideConfig);
    } forEach ("true" configClasses (_root >> "CfgGroups"));
} forEach [missionConfigFile, configFile];

ALiVE_GROUP_CONFIG_DATA_GENERATED = true;