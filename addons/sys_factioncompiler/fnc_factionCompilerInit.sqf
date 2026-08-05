#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerInit);

params [
    ["_logic", objNull, [objNull]],
    ["_syncedObjects", [], [[]]]
];

// Module callbacks do not consistently provide non-unit sync peers in the second
// argument, so resolve the live sync graph from the module itself.
_syncedObjects = synchronizedObjects _logic;

if (!isServer) exitWith {true};
if (isNull _logic) exitWith {false};

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

private _parseBool = {
    params [["_value", false]];

    if (_value isEqualType true) exitWith {_value};
    if (_value isEqualType "") exitWith {(toLower _value) isEqualTo "true"};

    false
};

call ALiVE_fnc_staticDataHandler;

if (isNil "ALIVE_compiledFactions") then {
    ALIVE_compiledFactions = [] call ALIVE_fnc_hashCreate;
};

// Overridden categories live in their own table, keyed by faction id and by the
// plain ALiVE category name. Kept apart from ALIVE_factionCustomMappings on
// purpose: that table means "this faction redirects somewhere else", and putting
// an ordinary faction in it would drag every reader of it onto a path it has
// never taken for that faction. A mission with no compiler never creates this.
if (isNil "ALIVE_factionGroupOverrides") then {
    ALIVE_factionGroupOverrides = [] call ALIVE_fnc_hashCreate;
};

private _debug = [(_logic getVariable ["debug", false])] call _parseBool;
private _deleteTemplates = [(_logic getVariable ["deleteTemplates", true])] call _parseBool;
private _overrideMode = _logic getVariable ["overrideMode", "NewFaction"];
if !(_overrideMode isEqualType "") then { _overrideMode = "NewFaction" };
if !(_overrideMode in ["NewFaction", "OverrideCategories"]) then { _overrideMode = "NewFaction" };
private _isOverride = _overrideMode isEqualTo "OverrideCategories";
private _requestedFactionId = _logic getVariable ["factionId", "ALIVE_CUSTOM_FACTION"];
if !(_requestedFactionId isEqualType "") then {
    _requestedFactionId = str _requestedFactionId;
};
private _factionId = _requestedFactionId;
private _normalizedFactionId = [];
private _lastWasUnderscore = false;
private _hasIdentifierChar = false;
{
    private _charCode = _x;
    private _isAlphaNumeric = (_charCode >= 48 && _charCode <= 57) || {(_charCode >= 65 && _charCode <= 90) || (_charCode >= 97 && _charCode <= 122)};

    if (_isAlphaNumeric) then {
        _normalizedFactionId pushBack _charCode;
        _lastWasUnderscore = false;
        _hasIdentifierChar = true;
    } else {
        if !(_lastWasUnderscore) then {
            _normalizedFactionId pushBack 95;
            _lastWasUnderscore = true;
        };
    };
} forEach (toArray _factionId);

_factionId = toString _normalizedFactionId;
if (!_hasIdentifierChar || {_factionId isEqualTo ""}) then {
    _factionId = "ALIVE_CUSTOM_FACTION";
};

private _displayName = _logic getVariable ["displayName", _factionId];
if !(_displayName isEqualType "") then {
    _displayName = str _displayName;
};
if (_displayName isEqualTo "") then {
    _displayName = _factionId;
};

// Read from "faction" key (set by attribute expression) with
// "proxyFaction" as a legacy fallback for missions saved against
// the earlier internal-key name.
private _proxyFaction = _logic getVariable ["faction", _logic getVariable ["proxyFaction", "OPF_F"]];
if !(_proxyFaction isEqualType "") then {
    _proxyFaction = str _proxyFaction;
};
if (_proxyFaction isEqualTo "") then {
    _proxyFaction = "OPF_F";
};

// Override categories only means anything against a faction that exists. Refuse
// here rather than further down, so a mistyped id leaves the template groups
// exactly where they were placed instead of stranding them on the map after the
// capture loop has already taken them.
if (_isOverride && {!(isClass (configFile >> "CfgFactionClasses" >> _factionId)) && {!(isClass (missionConfigFile >> "CfgFactionClasses" >> _factionId))}}) exitWith {
    _logic setVariable ["factionId", _requestedFactionId, true];
    _logic setVariable ["compiledFactionId", "", true];
    _logic setVariable ["compiledProxyFaction", "", true];
    _logic setVariable ["compiledFactionSide", "", true];
    _logic setVariable ["compiledFactionDisplayName", _displayName, true];
    _logic setVariable ["compiledFactionGroupCount", 0, true];
    _logic setVariable ["compiledFactionError", format ["Override categories: no faction %1", _factionId], true];
    ["Warning Faction compiler [%1] cannot override categories of %2 because no such faction is loaded - check the Faction ID, nothing was compiled", _displayName, _factionId] call ALIVE_fnc_dump;
    [_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
    false
};

private _moduleSourceId = netId _logic;
if (_moduleSourceId isEqualTo "") then {
    _moduleSourceId = str _logic;
};

private _ownsExistingId = (_logic getVariable ["compiledFactionId", ""]) isEqualTo _factionId;
private _collisionReason = "";
private _collisionOwner = "";
private _collisionSourceId = "";

if (_factionId in (ALIVE_compiledFactions select 1)) then {
    private _existingFactionData = [ALIVE_compiledFactions, _factionId] call ALIVE_fnc_hashGet;
    private _existingSourceModule = [_existingFactionData, "sourceModule", objNull] call ALIVE_fnc_hashGet;
    private _existingSourceModuleId = [_existingFactionData, "sourceModuleId", ""] call ALIVE_fnc_hashGet;

    if ((isNull _existingSourceModule && {!_ownsExistingId && {_existingSourceModuleId != _moduleSourceId}}) || {!isNull _existingSourceModule && {!(_existingSourceModule isEqualTo _logic)}}) then {
        _collisionReason = "compiled faction";
        _collisionOwner = [_existingFactionData, "displayName", _factionId] call ALIVE_fnc_hashGet;
        _collisionSourceId = _existingSourceModuleId;
    };
};

if (_collisionReason isEqualTo "" && {!isNil "ALIVE_factionCustomMappings"} && {_factionId in (ALIVE_factionCustomMappings select 1)}) then {
    private _existingMapping = [ALIVE_factionCustomMappings, _factionId] call ALIVE_fnc_hashGet;
    private _mappingIsCompiled = [_existingMapping, "CompiledFaction", false] call ALIVE_fnc_hashGet;
    private _existingSourceModule = [_existingMapping, "SourceModule", objNull] call ALIVE_fnc_hashGet;
    private _existingSourceModuleId = [_existingMapping, "SourceModuleId", ""] call ALIVE_fnc_hashGet;
    private _mappingOwnedByCurrentModule = _mappingIsCompiled && {(!isNull _existingSourceModule && {_existingSourceModule isEqualTo _logic}) || {(isNull _existingSourceModule) && {_ownsExistingId || {_existingSourceModuleId isEqualTo _moduleSourceId}}}};

    if (!_mappingOwnedByCurrentModule) then {
        // OverrideCategories mode is the explicit "stack on top of an
        // existing curated/inferred faction" path - allow it through.
        // Still reject if a DIFFERENT compiler already overrode the
        // same id (ambiguous ownership).
        private _allowOverride = _isOverride && {!_mappingIsCompiled};
        if (!_allowOverride) then {
            _collisionReason = if (_mappingIsCompiled) then {"compiled faction mapping"} else {"custom faction mapping"};
            _collisionOwner = [_existingMapping, "DisplayName", [_existingMapping, "FactionName", _factionId] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashGet;
            _collisionSourceId = _existingSourceModuleId;
        };
    };
};

if !(_collisionReason isEqualTo "") exitWith {
    private _collisionSourceText = if (_collisionSourceId isEqualTo "") then {""} else {format [" (module %1)", _collisionSourceId]};
    _logic setVariable ["factionId", _requestedFactionId, true];
    _logic setVariable ["compiledFactionId", "", true];
    _logic setVariable ["compiledProxyFaction", "", true];
    _logic setVariable ["compiledFactionSide", "", true];
    _logic setVariable ["compiledFactionDisplayName", _displayName, true];
    _logic setVariable ["compiledFactionGroupCount", 0, true];
    _logic setVariable ["compiledFactionError", format ["Duplicate compiled faction id %1", _factionId], true];
    ["Warning Faction compiler [%1] rejected normalized id %2 (requested %3) because it collides with existing %4 %5%6", _displayName, _factionId, _requestedFactionId, _collisionReason, _collisionOwner, _collisionSourceText] call ALIVE_fnc_dump;
    [_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
    false
};
private _groupsByCategory = [] call ALIVE_fnc_hashCreate;
private _compiledGroups = [] call ALIVE_fnc_hashCreate;
private _unitClasses = [];
private _vehicleClasses = [];
private _templateGroups = [];
private _templateVehicles = [];
private _sideText = "";
private _groupIndex = 0;
private _standardCategories = ["Infantry", "SpecOps", "Motorized", "Motorized_MTP", "Mechanized", "Mechanized_MTP", "Armored", "Air", "Naval", "Support", "Artillery"];
{
    [_groupsByCategory, _x, []] call ALIVE_fnc_hashSet;
} forEach _standardCategories;

{
    if ((typeOf _x) isEqualTo "ALiVE_sys_factioncompiler_category") then {
        private _categoryModule = _x;
        private _category = _categoryModule getVariable ["category", "Infantry"];
        if (_category isEqualTo "") then {
            _category = "Infantry";
        };

        private _categoryGroups = [_groupsByCategory, _category, []] call ALIVE_fnc_hashGet;

        {
            private _unit = _x;
            if (_unit isKindOf "CAManBase" && {side _unit != sideLogic}) then {
                private _group = group _unit;
                if !(isNull _group) then {
                    if !(_group in _templateGroups) then {
                        private _leader = leader _group;
                        if !(isNull _leader) then {
                            private _groupSideNumber = [side _group] call ALIVE_fnc_sideObjectToNumber;
                            private _groupSideText = [_groupSideNumber] call ALIVE_fnc_sideNumberToText;

                            if (_sideText isEqualTo "") then {
                                _sideText = _groupSideText;
                            };

                            if (_sideText isEqualTo _groupSideText) then {
                                private _leaderPos = getPosATL _leader;
                                private _leaderDir = getDir _leader;
                                private _unitEntries = [];
                                private _groupVehicles = [];
                                private _vehicleEntries = [];

                                {
                                    private _member = _x;
                                    private _memberPos = getPosATL _member;
                                    private _unitData = [] call ALIVE_fnc_hashCreate;
                                    private _memberClass = typeOf _member;

                                    [_unitData, "class", _memberClass] call ALIVE_fnc_hashSet;
                                    [_unitData, "rank", rank _member] call ALIVE_fnc_hashSet;
                                    [_unitData, "damage", damage _member] call ALIVE_fnc_hashSet;
                                    [_unitData, "loadout", getUnitLoadout _member] call ALIVE_fnc_hashSet;
                                    [_unitData, "offsetDistance", _leader distance2D _member] call ALIVE_fnc_hashSet;
                                    [_unitData, "offsetBearing", (_leader getDir _member) - _leaderDir] call ALIVE_fnc_hashSet;
                                    [_unitData, "offsetHeight", (_memberPos select 2) - (_leaderPos select 2)] call ALIVE_fnc_hashSet;

                                    _unitEntries pushBack _unitData;
                                    _unitClasses pushBackUnique _memberClass;

                                    private _vehicle = vehicle _member;
                                    if !(_vehicle isEqualTo _member) then {
                                        _groupVehicles pushBackUnique _vehicle;
                                        _templateVehicles pushBackUnique _vehicle;
                                    };
                                } forEach (units _group);

                                {
                                    private _vehicle = _x;
                                    private _vehiclePos = getPosATL _vehicle;
                                    private _vehicleClass = typeOf _vehicle;
                                    private _vehicleData = [] call ALIVE_fnc_hashCreate;

                                    [_vehicleData, "class", _vehicleClass] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "directionOffset", (getDir _vehicle) - _leaderDir] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "damage", _vehicle call ALIVE_fnc_vehicleGetDamage] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "fuel", fuel _vehicle] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "ammo", _vehicle call ALIVE_fnc_vehicleGetAmmo] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "engineOn", isEngineOn _vehicle] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "canFire", canFire _vehicle] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "canMove", canMove _vehicle] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "needReload", needReload _vehicle] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "offsetDistance", _leader distance2D _vehicle] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "offsetBearing", (_leader getDir _vehicle) - _leaderDir] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "offsetHeight", (_vehiclePos select 2) - (_leaderPos select 2)] call ALIVE_fnc_hashSet;
                                    [_vehicleData, "assignment", [_vehicle, _group] call ALIVE_fnc_vehicleAssignmentToProfileVehicleAssignment] call ALIVE_fnc_hashSet;

                                    _vehicleEntries pushBack _vehicleData;
                                    _vehicleClasses pushBackUnique _vehicleClass;
                                } forEach _groupVehicles;

                                _groupIndex = _groupIndex + 1;
                                private _groupId = format ["%1_GROUP_%2", _factionId, _groupIndex];
                                private _groupName = groupId _group;
                                if (_groupName isEqualTo "") then {
                                    _groupName = format ["%1 %2", _category, _groupIndex];
                                };

                                private _groupData = [] call ALIVE_fnc_hashCreate;
                                [_groupData, "groupId", _groupId] call ALIVE_fnc_hashSet;
                                [_groupData, "name", _groupName] call ALIVE_fnc_hashSet;
                                [_groupData, "category", _category] call ALIVE_fnc_hashSet;
                                [_groupData, "side", _groupSideText] call ALIVE_fnc_hashSet;
                                [_groupData, "units", _unitEntries] call ALIVE_fnc_hashSet;
                                [_groupData, "vehicles", _vehicleEntries] call ALIVE_fnc_hashSet;

                                [ _compiledGroups, _groupId, _groupData ] call ALIVE_fnc_hashSet;
                                _categoryGroups pushBack _groupId;
                                _templateGroups pushBack _group;

                                if (_debug) then {
                                    ["Faction compiler [%1] captured group %2 in %3", _factionId, _groupId, _category] call ALIVE_fnc_dump;
                                };
                            } else {
                                if (_debug) then {
                                    ["Faction compiler [%1] skipped group with mismatched side %2", _factionId, _groupSideText] call ALIVE_fnc_dump;
                                };
                            };
                        };
                    };
                };
            };
        } forEach (synchronizedObjects _categoryModule);

        [ _groupsByCategory, _category, _categoryGroups ] call ALIVE_fnc_hashSet;
    };
} forEach _syncedObjects;

if (_groupIndex == 0) exitWith {
    _logic setVariable ["factionId", _requestedFactionId, true];
    _logic setVariable ["compiledFactionId", "", true];
    _logic setVariable ["compiledProxyFaction", "", true];
    _logic setVariable ["compiledFactionSide", "", true];
    _logic setVariable ["compiledFactionDisplayName", _displayName, true];
    _logic setVariable ["compiledFactionGroupCount", 0, true];
    _logic setVariable ["compiledFactionError", "No template groups captured", true];
    // Not behind the debug setting. A compiler with nothing synced to it is the
    // most likely first-time mistake, and it used to fail in complete silence.
    ["Warning Faction compiler [%1] found no template groups - sync a category helper to this module, and one unit from each template group to that helper", _displayName] call ALIVE_fnc_dump;
    [_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
    false
};

// Warn, do not refuse, when the templates are the wrong side for the faction
// being overridden. Refusing this late would strand the captured units on the
// map, and a mission maker may have a reason for the mismatch.
if (_isOverride) then {
    private _factionConfig = configFile >> "CfgFactionClasses" >> _factionId;
    if (isNumber (_factionConfig >> "side")) then {
        private _targetSide = [getNumber (_factionConfig >> "side")] call ALIVE_fnc_sideNumberToText;
        if !(_targetSide isEqualTo _sideText) then {
            ["Warning Faction compiler [%1] template groups are %2 but faction %3 is %4 - the groups were still compiled, but they will fight for %3", _displayName, _sideText, _factionId, _targetSide] call ALIVE_fnc_dump;
        };
    };
};

// In override mode nothing is written to ALIVE_factionCustomMappings at all.
// The faction keeps its own name and its own config groups, and only the
// categories captured here are diverted, through ALIVE_factionGroupOverrides.
// NewFaction mode is untouched and still writes a mapping as it always has.
private _mapping = nil;
if (_isOverride) then {
    private _overrideGroups = [] call ALIVE_fnc_hashCreate;
    private _overriddenNames = [];
    {
        private _category = _x;
        private _categoryGroups = [_groupsByCategory, _category, []] call ALIVE_fnc_hashGet;
        // Only categories that actually captured something. A category present
        // but empty would shadow the faction's own groups with nothing.
        if (count _categoryGroups > 0) then {
            [_overrideGroups, _category, _categoryGroups] call ALIVE_fnc_hashSet;
            _overriddenNames pushBack _category;
        };
    } forEach _standardCategories;
    [ALIVE_factionGroupOverrides, _factionId, _overrideGroups] call ALIVE_fnc_hashSet;
    _logic setVariable ["compiledOverrideCategories", _overriddenNames, true];
} else {
    private _typeMappings = [] call ALIVE_fnc_hashCreate;
    {
        [_typeMappings, _x, _x] call ALIVE_fnc_hashSet;
    } forEach _standardCategories;

    private _newMapping = [] call ALIVE_fnc_hashCreate;
    [_newMapping, "Side", _sideText] call ALIVE_fnc_hashSet;
    [_newMapping, "GroupSideName", _sideText] call ALIVE_fnc_hashSet;
    [_newMapping, "FactionName", _factionId] call ALIVE_fnc_hashSet;
    [_newMapping, "ConfigFactionName", _proxyFaction] call ALIVE_fnc_hashSet;
    [_newMapping, "GroupFactionName", _proxyFaction] call ALIVE_fnc_hashSet;
    [_newMapping, "GroupFactionTypes", _typeMappings] call ALIVE_fnc_hashSet;
    [_newMapping, "Groups", _groupsByCategory] call ALIVE_fnc_hashSet;
    [_newMapping, "CompiledFaction", true] call ALIVE_fnc_hashSet;
    [_newMapping, "DisplayName", _displayName] call ALIVE_fnc_hashSet;
    [_newMapping, "SourceModule", _logic] call ALIVE_fnc_hashSet;
    [_newMapping, "SourceModuleId", _moduleSourceId] call ALIVE_fnc_hashSet;
    _mapping = _newMapping;
};

private _factionData = [] call ALIVE_fnc_hashCreate;
[_factionData, "factionId", _factionId] call ALIVE_fnc_hashSet;
[_factionData, "displayName", _displayName] call ALIVE_fnc_hashSet;
[_factionData, "proxyFaction", _proxyFaction] call ALIVE_fnc_hashSet;
[_factionData, "side", _sideText] call ALIVE_fnc_hashSet;
[_factionData, "groupsByCategory", _groupsByCategory] call ALIVE_fnc_hashSet;
[_factionData, "compiledGroups", _compiledGroups] call ALIVE_fnc_hashSet;
// Override mode publishes no vehicle inventory. These two lists are read at one
// place only, and a non-empty pair there makes the captured classes the faction's
// ONLY vehicles for every transport, logistics and ambient query. Overriding a
// category should change which groups the faction fields in it, not empty out the
// faction's motor pool.
if (_isOverride) then {
    [_factionData, "unitClasses", []] call ALIVE_fnc_hashSet;
    [_factionData, "vehicleClasses", []] call ALIVE_fnc_hashSet;
} else {
    [_factionData, "unitClasses", _unitClasses] call ALIVE_fnc_hashSet;
    [_factionData, "vehicleClasses", _vehicleClasses] call ALIVE_fnc_hashSet;
};
[_factionData, "sourceModule", _logic] call ALIVE_fnc_hashSet;
[_factionData, "sourceModuleId", _moduleSourceId] call ALIVE_fnc_hashSet;
[ALIVE_compiledFactions, _factionId, _factionData] call ALIVE_fnc_hashSet;
// Only NewFaction mode registers a mapping. Override mode deliberately leaves
// the redirect table alone.
if (!isNil "_mapping") then {
    [ALIVE_factionCustomMappings, _factionId, _mapping] call ALIVE_fnc_hashSet;
};

_logic setVariable ["factionId", _factionId, true];
_logic setVariable ["compiledFactionId", _factionId, true];
_logic setVariable ["compiledProxyFaction", _proxyFaction, true];
_logic setVariable ["compiledFactionSide", _sideText, true];
_logic setVariable ["compiledFactionDisplayName", _displayName, true];
_logic setVariable ["compiledFactionGroupCount", _groupIndex, true];
_logic setVariable ["compiledFactionError", "", true];

if (_deleteTemplates) then {
    {
        if !(isNull _x) then {
            {
                if !(isNull _x) then {
                    deleteVehicle _x;
                };
            } forEach (units _x);

            _x call ALiVE_fnc_DeleteGroupRemote;
        };
    } forEach _templateGroups;

    {
        if !(isNull _x) then {
            deleteVehicle _x;
        };
    } forEach _templateVehicles;
};

// Not behind the debug setting. This one line is what tells anyone reading a log
// which of the two modes actually ran, and its absence is what made the original
// report impossible to diagnose from the outside.
private _modeLabel = if (_isOverride) then {
    format ["override-categories (%1)", (_logic getVariable ["compiledOverrideCategories", []]) joinString ", "]
} else {
    format ["new-faction (proxy %1)", _proxyFaction]
};
["Faction compiler [%1] registered %2 groups for side %3 - mode: %4", _factionId, _groupIndex, _sideText, _modeLabel] call ALIVE_fnc_dump;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
true

