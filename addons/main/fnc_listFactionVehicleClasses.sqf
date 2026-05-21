#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(listFactionVehicleClasses);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_listFactionVehicleClasses

Description:
Feeder for the ALiVE_FactionStaticDataChoice multi-select listbox. Given
a list of faction class names and a kind token, returns a deduped per-
faction list of CfgVehicles classes that fit that kind.

Walks CfgVehicles directly (no dependency on cfgFunctions-registered
helpers) so it works in 3DEN editor context where addon-fn registration
isn't reliably propagated. Filters by:
    - scope >= 1
    - getText "faction" == _faction
    - isKindOf one of the kind-gate parent classes
    - TransportSoldier >= minCargo (vehicle kinds only)

Kind tokens:
    "land"      -> isKindOf "Truck",       TransportSoldier >= 2
    "air"       -> isKindOf "Helicopter",  TransportSoldier >= 2
    "support"   -> isKindOf "Truck",       TransportSoldier >= 0
    "container" -> isKindOf "ReammoBox_F" / "Slingload_01_Base_F" /
                   "CargoNet_01_base_F"
    "supply"    -> isKindOf "ReammoBox_F"

Parameters:
    [_kind, _factions]
    _kind       : STRING - kind token (see above)
    _factions   : ARRAY of STRING - faction class names

Returns:
    Array of [_factionClass, [_classNames...]] pairs. One pair per input
    faction. Inner array is sorted alphabetically and deduped.

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_kind", "land", [""]],
    ["_factions", [], [[]]],
    ["_consumingLogic", objNull, [objNull]]
];

if (_factions isEqualTo []) exitWith { [] };

// Map kind to isKindOf gate(s), minimum cargo slot count, and the
// matching ALIVE_factionDefault* registry hash. Many mod faction
// classes assign vehicles to a faction tag that differs from the
// OPCOM-selected faction string (RHS for example splits some classes
// across rhs_faction_usaf / rhs_faction_usarmy_d / rhsusf_*) -
// merging the registry's existing entries in catches those.
private _kindGates = [];
private _minCargo = 0;
private _registryName = "";
switch (_kind) do {
    case "land":      { _kindGates = ["Truck_F", "Truck", "Wheeled_APC_F"];                        _minCargo = 2; _registryName = "ALIVE_factionDefaultTransport"; };
    case "air":       { _kindGates = ["Helicopter"];                                               _minCargo = 2; _registryName = "ALIVE_factionDefaultAirTransport"; };
    case "support":   { _kindGates = ["Truck_F", "Truck"];                                         _minCargo = 0; _registryName = "ALIVE_factionDefaultSupports"; };
    case "container": { _kindGates = ["ReammoBox_F", "Slingload_01_Base_F", "CargoNet_01_base_F"]; _minCargo = 0; _registryName = "ALIVE_factionDefaultContainers"; };
    case "supply":    { _kindGates = ["ReammoBox_F"];                                              _minCargo = 0; _registryName = "ALIVE_factionDefaultSupplies"; };
    default           { _kindGates = ["Truck_F", "Truck"];                                         _minCargo = 2; _registryName = ""; };
};

private _isVehicleKind = (_kind in ["land", "air", "support"]);

// Index factions for O(1) lookup during the single CfgVehicles walk.
// Seed each faction's bucket with the registry's existing classes for
// that faction (if the registry exists and is populated). The bucket is
// then augmented by the CfgVehicles scan below.
// Static-data registries (ALIVE_factionDefault*) are populated by
// staticDataHandler at mission init, not at 3DEN editor start. Force-
// load Logistics.hpp + Placement.hpp once so the registry seed below
// works inside the editor too. Guarded on a per-namespace flag so the
// expensive #include expansion only fires once per editor session.
//
// Logistics.hpp / Placement.hpp call ALiVE_fnc_hashCreate / hashSet
// which are themselves cfgFunctions-registered and not available in
// 3DEN. Alias them to the underlying CBA equivalents so the load
// completes successfully. The real ALiVE wrappers replace these at
// mission init when CBA cfgFunctions actually fires.
if (isNil "ALIVE_factionDefaultTransport" || {isNil "ALIVE_factionDefaultContainers"}) then {
    ["ALIVE listFactionVehicleClasses: registries not loaded - lazy-loading Placement.hpp + Logistics.hpp"] call ALiVE_fnc_dump;
    // Force-override the ALiVE hash wrappers - the cfgFunctions-
    // registered originals aren't reliably callable in 3DEN editor
    // context. CBA equivalents are functionally identical for the
    // operations Logistics.hpp / Placement.hpp use. The real wrappers
    // get reinstalled by cfgFunctions at mission preInit.
    ALIVE_fnc_hashCreate = CBA_fnc_hashCreate;
    ALIVE_fnc_hashSet    = CBA_fnc_hashSet;
    ALIVE_fnc_hashGet    = CBA_fnc_hashGet;
    // Placement.hpp creates ALIVE_factionDefaultSupports / Supplies
    // which Logistics.hpp's CFP/RHS sub-includes reference. Must load
    // Placement FIRST to avoid undefined-hash errors in the cross-
    // referencing entries.
    call compile preprocessFileLineNumbers "\x\alive\addons\main\static\Placement.hpp";
    call compile preprocessFileLineNumbers "\x\alive\addons\main\static\Logistics.hpp";
};

private _factionLookup = createHashMap;
private _registry = if (_registryName != "") then { missionNamespace getVariable [_registryName, nil] } else { nil };
{
    private _seed = [];
    if (!isNil "_registry" && {typeName _registry == "ARRAY"}) then {
        // Use CBA directly - ALIVE_fnc_hashGet may not be available in
        // 3DEN editor context (cfgFunctions registration of addon fns
        // doesn't reliably propagate to Eden).
        private _existing = [_registry, _x] call CBA_fnc_hashGet;
        if (typeName _existing == "ARRAY") then {
            { if (typeName _x == "STRING" && {_x != ""}) then { _seed pushBackUnique _x } } forEach _existing;
        };
    };
    _factionLookup set [_x, _seed];
} forEach _factions;

// Single CfgVehicles walk per kind/faction call. Slow on first
// invocation (a few thousand entries to iterate) but Eden caches the
// caller's view so this only fires once per attribute-open / faction-
// switch.
private _cfg = configFile >> "CfgVehicles";
private _total = count _cfg;

for "_i" from 0 to _total - 1 do {
    private _entry = _cfg select _i;
    if (isClass _entry) then {
        if (getNumber (_entry >> "scope") >= 1) then {
            private _entryFaction = getText (_entry >> "faction");
            if (_entryFaction != "" && {_entryFaction in _factionLookup}) then {
                private _entryClass = configName _entry;
                private _passes = false;
                if (_isVehicleKind) then {
                    if (getNumber (_entry >> "TransportSoldier") >= _minCargo) then {
                        {
                            if (_entryClass isKindOf _x) exitWith { _passes = true };
                        } forEach _kindGates;
                    };
                } else {
                    {
                        if (_entryClass isKindOf _x) exitWith { _passes = true };
                    } forEach _kindGates;
                };
                if (_passes) then {
                    private _bucket = _factionLookup get _entryFaction;
                    if !(_entryClass in _bucket) then { _bucket pushBack _entryClass };
                    _factionLookup set [_entryFaction, _bucket];
                };
            };
        };
    };
};

// ------------------------------------------------------------------------
// Third feeder source: sys_factioncompiler-defined factions.
//
// Mission-makers can compose custom factions in Eden by placing
// ALiVE_sys_factioncompiler modules with category sub-modules
// (ALiVE_sys_factioncompiler_category) and syncing template-group
// units into each category. At Eden time the compiler hasn't run yet,
// but the state is readable.
//
// Scan ALL compiler modules in the mission (not just ones synced to
// the consuming module) so the user is free to wire the compiler
// however they like. A compiler whose factionId matches one of our
// _factions contributes its category template vehicles to that
// faction's pool.
//
// Mirrors fnc_factionCompilerInit's walk: only CAManBase units count
// as group seeds; the unit's group is the template; vehicle _member
// for each member yields the assigned vehicle (heli pilot -> heli).
// ------------------------------------------------------------------------

// Map kind -> category names that should contribute. Container /
// supply kinds aren't a factioncompiler category, so they're empty
// and the compiler walk yields nothing for them.
private _kindCategories = switch (_kind) do {
    case "land":    { ["Motorized", "Motorized_MTP", "Mechanized", "Mechanized_MTP"] };
    case "air":     { ["Air"] };
    case "support": { ["Support"] };
    default         { [] };
};

if (count _kindCategories > 0) then {
    private _systems = all3DENEntities param [3, []];
    private _allCompilers = _systems select { (typeOf _x) isEqualTo "ALiVE_sys_factioncompiler" };
    {
        private _compiler = _x;
        private _compilerFactionId = _compiler getVariable ["factionId", ""];
        if (_compilerFactionId != "" && {_compilerFactionId in _factionLookup}) then {
            private _bucket = _factionLookup get _compilerFactionId;
            // Walk the compiler's syncs to find category sub-modules.
            private _compilerSyncs = (get3DENConnections _compiler) select {(_x select 0) == "Sync"};
            {
                private _catModule = _x select 1;
                if (typeName _catModule == "OBJECT" && {!isNull _catModule} && {(typeOf _catModule) isEqualTo "ALiVE_sys_factioncompiler_category"}) then {
                    private _categoryName = _catModule getVariable ["category", "Infantry"];
                    if (_categoryName in _kindCategories) then {
                        // Walk the category's synced units, follow each
                        // group's units to collect template vehicles.
                        // synchronizedObjects is the runtime-side API and
                        // returns 0 for editor-time entities; the editor-
                        // side equivalent is get3DENConnections.
                        private _seenGroups = [];
                        private _catSyncs = (get3DENConnections _catModule) select {(_x select 0) == "Sync"} apply {_x select 1};
                        {
                            private _unit = _x;
                            if (typeName _unit == "OBJECT" && {!isNull _unit} && {_unit isKindOf "CAManBase"}) then {
                                private _grp = group _unit;
                                if (!isNull _grp && {!(_grp in _seenGroups)}) then {
                                    _seenGroups pushBack _grp;
                                    {
                                        private _member = _x;
                                        private _veh = vehicle _member;
                                        if (!isNull _veh && {!(_veh isEqualTo _member)}) then {
                                            private _vClass = typeOf _veh;
                                            if (_vClass != "" && {!(_vClass in _bucket)}) then {
                                                _bucket pushBack _vClass;
                                            };
                                        };
                                    } forEach (units _grp);
                                };
                            };
                        } forEach _catSyncs;
                    };
                };
            } forEach _compilerSyncs;
            _factionLookup set [_compilerFactionId, _bucket];
        };
    } forEach _allCompilers;
};

// Reassemble result preserving the input faction order.
private _result = [];
{
    private _classes = _factionLookup get _x;
    _classes sort true;
    _result pushBack [_x, _classes];
} forEach _factions;

_result
