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

// Keep the readiness check, config traversal and completion flag in one
// unscheduled call so every caller returns with the complete shared cache.
[{
    if (!isNil "ALiVE_GROUP_CONFIG_DATA_GENERATED") exitWith {};

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
}] call CBA_fnc_directCall;
