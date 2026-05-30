#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(getCompositionRadius);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getCompositionRadius

Description:
    Returns the composition's effective DIAMETER in metres - the minimum
    clear-circle a spawn site must offer to fit the composition. Walks the
    CfgGroups>Empty>... config, finds the maximum 2D distance from origin
    to any object's `position` array, doubles it (radius -> diameter), and
    adds a small buffer for object footprint at the edge.

    Result is cached per-config-name in uiNamespace so repeat calls during
    placement runs don't re-walk the config.

    Used by callers feeding ALiVE_fnc_findCompositionSpawnPosition - small
    camps get tight envelopes (~15m) while large field HQs get bigger ones
    (~60m). The validator's road / helipad / building exclusions all scale
    automatically because they're expressed as `_envHalf + N`.

Parameters:
    0: CONFIG or STRING - composition config or its config-path string

Returns:
    NUMBER - diameter in metres. Falls back to 30 (mid-camp default) on
             unrecognised input.

Examples:
    (begin example)
    private _envelope = [_composition] call ALiVE_fnc_getCompositionRadius;
    private _result = [_pos, 500, _envelope, "field"] call ALiVE_fnc_findCompositionSpawnPosition;
    (end)

See Also:
    ALiVE_fnc_findCompositionSpawnPosition

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_config", configNull, [configNull, ""]]];

if (typeName _config == "STRING") then {
    _config = [_config, configFile] call BIS_fnc_configPath;
};

if (isNull _config) exitWith { 30 };

private _cfgName = configName _config;
if (_cfgName == "") exitWith { 30 };

// Cache lookup - keyed on full config path so two same-named compositions
// in different categories don't collide.
private _cacheKey = format ["ALiVE_compRadius_%1", configHierarchy _config joinString "/"];
private _cached = uiNamespace getVariable [_cacheKey, -1];
if (_cached >= 0) exitWith { _cached };

// Walk children, find max 2D distance from origin
private _maxDist = 0;
for "_i" from 0 to ((count _config) - 1) do {
    private _item = _config select _i;
    if (isClass _item) then {
        private _pos = getArray (_item >> "position");
        if (count _pos >= 2) then {
            private _dx = _pos select 0;
            private _dy = _pos select 1;
            private _d = sqrt ((_dx * _dx) + (_dy * _dy));
            if (_d > _maxDist) then { _maxDist = _d };
        };
    };
};

// Diameter = 2 x max-radius + 5m buffer for edge object footprint.
// Floor at 15m so trivially-small comps still get a sane minimum envelope.
private _diameter = (_maxDist * 2) + 5;
if (_diameter < 15) then { _diameter = 15 };

uiNamespace setVariable [_cacheKey, _diameter];
_diameter
