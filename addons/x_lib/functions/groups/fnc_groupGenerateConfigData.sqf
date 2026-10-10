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
Jman
---------------------------------------------------------------------------- */

// Keep the readiness check, config traversal and completion flag in one
// unscheduled call so every caller returns with the complete shared cache.
[{
    if (!isNil "ALiVE_GROUP_CONFIG_DATA_GENERATED") exitWith {};

    ALIVE_groupConfig = [] call ALIVE_fnc_hashCreate;

    // A faction can use one group name in two categories (Global Mobilization's 1980s and
    // 1990s infantry, Spearhead's late-war support, the vanilla diver teams). Those names are
    // listed and each copy is also kept under faction_category>name, so a group drawn from one
    // category can't come back as its namesake (#79).
    ALiVE_groupConfigDuplicates = createHashMap;

    // Preserve traversal order: engine groups overwrite duplicate mission keys.
    // Visit only side/faction/category/group classes and retain the config directly.
    {
        private _root = _x;
        {
            private _sideConfig = _x;
            {
                private _factionConfig = _x;
                private _faction = configName _factionConfig;
                private _seen = createHashMap;
                {
                    private _categoryConfig = _x;
                    private _category = configName _categoryConfig;
                    {
                        private _name = configName _x;
                        [ALIVE_groupConfig, format ["%1_%2", _faction, _name], _x] call ALIVE_fnc_hashSet;
                        private _found = _seen getOrDefault [_name, []];
                        _found pushBack [_category, _x];
                        _seen set [_name, _found];
                    } forEach ("true" configClasses _categoryConfig);
                } forEach ("true" configClasses _factionConfig);
                // Qualified keys only for the names used twice, so the table stays its old size.
                {
                    if (count _y > 1) then {
                        ALiVE_groupConfigDuplicates set [format ["%1_%2", _faction, _x], true];
                        private _name = _x;
                        { [ALIVE_groupConfig, format ["%1_%2>%3", _faction, _x select 0, _name], _x select 1] call ALIVE_fnc_hashSet } forEach _y;
                    };
                } forEach _seen;
            } forEach ("true" configClasses _sideConfig);
        } forEach ("true" configClasses (_root >> "CfgGroups"));
    } forEach [missionConfigFile, configFile];

    ALiVE_GROUP_CONFIG_DATA_GENERATED = true;
}] call CBA_fnc_directCall;
