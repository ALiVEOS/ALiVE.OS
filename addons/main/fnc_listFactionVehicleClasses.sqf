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
    ["_factions", [], [[]]]
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
    diag_log "ALIVE listFactionVehicleClasses: registries not loaded - lazy-loading Placement.hpp + Logistics.hpp";
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
diag_log format ["ALIVE listFactionVehicleClasses: kind=%1 registry=%2 isNil=%3 type=%4", _kind, _registryName, isNil "_registry", if (isNil "_registry") then {"nil"} else {typeName _registry}];
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

// Reassemble result preserving the input faction order.
private _result = [];
{
    private _classes = _factionLookup get _x;
    _classes sort true;
    _result pushBack [_x, _classes];
} forEach _factions;

_result
