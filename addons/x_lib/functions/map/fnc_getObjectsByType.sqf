#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getObjectsByType);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectsByType

Description:
Returns objects matching partial P3D names, in the original model/placement order.
Caches model lookup, pattern expansion and resolved terrain objects across calls.
Overlapping/repeated patterns retain their original output multiplicity.

Parameters:
Array - Partial P3D names (existing calling convention)
Or [Array of partial names, HashMap of optional output metrics]

Returns:
Array - Matching objects; the returned array is fresh on every call

Cache lifetime:
Automatically rebuild on world, raw-array reference or raw-array count changes.
Clear ALIVE_objectLookupCache after same-length in-place edits of wrp_objects.
The indexer clears it whenever loading a new raw index. Null/deleted objects are
retried rather than reused. Terrain placement IDs/positions are otherwise static.

Example:
["barrack", "mil_"] call ALIVE_fnc_getObjectsByType;
[["barrack"], createHashMap] call ALIVE_fnc_getObjectsByType;

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private _types = _this;
private _metrics = createHashMap;
private _instrument = count _this > 0 && {(_this select 0) isEqualType []};
if (_instrument) then {_types = _this select 0; _metrics = _this select 1;};
private _started = diag_tickTime;
PROFILE_SCOPE(OBJECTS, "ALiVE_fnc_getObjectsByType: cached")
private _err = "types provided not valid";
ASSERT_DEFINED("_types",_err);
ASSERT_TRUE(typeName _types == "ARRAY",_err);

if (isNil "wrp_objects") then {
    private _file = format ["x\alive\addons\fnc_strategic\indexes\objects.%1.sqf", toLower worldName];
    call compile preprocessFileLineNumbers _file;
    ["Reading raw object data from file - %1 objects", count wrp_objects] call ALIVE_fnc_dump;
};
private _raw = wrp_objects;
_err = "raw object information not read correctly from file";
ASSERT_DEFINED("_raw",_err);
ASSERT_TRUE(typeName _raw == "ARRAY",_err);
["  objectsByType - index ready, %1 raw objects", count _raw] call ALIVE_fnc_dump;

private _cache = missionNamespace getVariable ["ALIVE_objectLookupCache", []];
private _rebuild = count _cache == 0;
if (!_rebuild) then {
    _rebuild = !((_cache select 0) isEqualRef _raw) || {(_cache select 1) != count _raw} || {(_cache select 2) != worldName};
};
private _indexStarted = diag_tickTime;
PROFILE_SCOPE(LOOKUP, "ALiVE_fnc_getObjectsByType: lookup")
if (_rebuild) then {
    // Preserve CBA's key order and duplicate-name semantics, then use constant
    // time native lookup for placements instead of repeatedly scanning keys.
    private _legacy = [_raw] call ALIVE_fnc_hashCreate;
    private _models = createHashMap;
    { if !(_x in _models) then {_models set [_x, (_legacy select 2) select _forEachIndex];}; } forEach (_legacy select 1);
    _cache = [_raw, count _raw, worldName, _legacy select 1, _models, createHashMap, createHashMap];
    missionNamespace setVariable ["ALIVE_objectLookupCache", _cache];
};
PROFILE_SCOPE_END(LOOKUP)
private _indexSeconds = diag_tickTime - _indexStarted;
private _names = _cache select 3;
private _models = _cache select 4;
private _matches = _cache select 5;
private _resolvedModels = _cache select 6;
["  objectsByType - lookup ready, %1 distinct names (rebuilt=%2)", count _names, _rebuild] call ALIVE_fnc_dump;

private _matchStarted = diag_tickTime;
PROFILE_SCOPE(MATCH, "ALiVE_fnc_getObjectsByType: patterns")
// str snapshots the definition: editing the caller's category array cannot
// accidentally reuse a match result for its previous contents.
private _matchKey = str _types;
private _matchHit = _matchKey in _matches;
private _expanded = _matches getOrDefault [_matchKey, []];
private _patternChecks = 0;
if (!_matchHit) then {
    {
        private _name = _x;
        {
            if (_instrument) then {_patternChecks = _patternChecks + 1;};
            if ([_name, _x] call CBA_fnc_find != -1) then {_expanded pushBack _name;};
        } forEach _types;
    } forEach _names;
    _matches set [_matchKey, _expanded];
};
PROFILE_SCOPE_END(MATCH)
private _matchSeconds = diag_tickTime - _matchStarted;
["  objectsByType - names matched, %1 wanted (cached=%2)", count _expanded, _matchHit] call ALIVE_fnc_dump;

private _gatherStarted = diag_tickTime;
private _data = [];
{_data append (_models get _x);} forEach _expanded;
private _gatherSeconds = diag_tickTime - _gatherStarted;
["  objectsByType - instances gathered, %1 entries", count _data] call ALIVE_fnc_dump;

private _resolveStarted = diag_tickTime;
PROFILE_SCOPE(RESOLVE, "ALiVE_fnc_getObjectsByType: resolution")
private _objects = [];
private _resolutions = 0;
private _resolutionHits = 0;
{
    private _name = _x;
    private _placements = _models get _name;
    private _modelObjects = _resolvedModels getOrDefault [_name, []];
    private _modelHit = count _modelObjects == count _placements && {_modelObjects findIf {isNull _x} == -1};
    if (_modelHit) then {
        if (_instrument) then {_resolutionHits = _resolutionHits + count _modelObjects;};
    } else {
        if (_name in _resolvedModels) then {
            // Only retry missing/deleted placements. Array ordinals are exact
            // keys, including colocated objects with adjacent large IDs.
            private _previousObjects = _modelObjects;
            _modelObjects = [];
            {
                private _object = _previousObjects param [_forEachIndex, objNull];
                if (isNull _object) then {
                    if (_instrument) then {_resolutions = _resolutions + 1;};
                    _object = (_x select 1) nearestObject (_x select 0);
                } else {
                    if (_instrument) then {_resolutionHits = _resolutionHits + 1;};
                };
                _modelObjects pushBack _object;
            } forEach _placements;
        } else {
            _modelObjects = _placements apply {(_x select 1) nearestObject (_x select 0)};
            if (_instrument) then {_resolutions = _resolutions + count _placements;};
        };
        _resolvedModels set [_name, _modelObjects];
    };
    _objects append _modelObjects;
} forEach _expanded;
PROFILE_SCOPE_END(RESOLVE)
private _resolveSeconds = diag_tickTime - _resolveStarted;
if (_instrument) then {
    _metrics set ["lookupBuilt", _rebuild];
    _metrics set ["matchCacheHit", _matchHit];
    _metrics set ["patternChecks", _patternChecks];
    _metrics set ["nearestObjectCalls", _resolutions];
    _metrics set ["resolutionHits", _resolutionHits];
    _metrics set ["modelCount", count _names];
    _metrics set ["matchedNames", count _expanded];
    _metrics set ["outputObjects", count _objects];
    _metrics set ["indexSeconds", _indexSeconds];
    _metrics set ["matchSeconds", _matchSeconds];
    _metrics set ["gatherSeconds", _gatherSeconds];
    _metrics set ["resolveSeconds", _resolveSeconds];
    _metrics set ["totalSeconds", diag_tickTime - _started];
};
PROFILE_SCOPE_END(OBJECTS)
_objects
