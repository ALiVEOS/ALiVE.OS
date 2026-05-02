#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(listFactionVehicleClasses);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_listFactionVehicleClasses

Description:
Feeder for the ALiVE_FactionStaticDataChoice multi-select listbox. Given
a list of faction class names and a kind token, returns a deduped per-
faction list of CfgVehicles classes that fit that kind. The kind tokens
map to broad isKindOf gates:

    "land"      -> isKindOf "Truck"        (TransportSoldier >= 2)
    "air"       -> isKindOf "Helicopter"   (TransportSoldier >= 2)
    "container" -> isKindOf "ReammoBox_F"  OR  isKindOf "Slingload_01_Base_F"
                   OR  isKindOf "CargoNet_01_base_F"
    "support"   -> isKindOf "Truck"
    "supply"    -> isKindOf "ReammoBox_F"

For vehicle kinds the lookup uses ALIVE_fnc_findVehicleType which already
caches by (faction, type) so repeated control re-opens are cheap. For
container / supply kinds, where ReammoBox-derived classes don't carry a
useful CfgGroups footprint, the iteration walks CfgVehicles directly and
filters by the class's `faction` text plus the isKindOf gate.

Faction classes whose units don't surface anywhere in CfgVehicles (e.g.
inferred / redirect-only factions) yield an empty inner list -- the
caller is expected to fall back to the user's free-text override field.

Parameters:
    [_kind, _factions]
    _kind       : STRING - one of "land", "air", "container", "support",
                  "supply".
    _factions   : ARRAY of STRING - faction class names selected on the
                  consuming module (e.g. mil_logistics' factions array).

Returns:
    Array of [_factionClass, [_classNames...]] pairs. One pair per input
    faction. Inner array is sorted alphabetically and deduped.

Examples:
(begin example)
_pairs = ["land", ["OPF_F", "BLU_F"]] call ALIVE_fnc_listFactionVehicleClasses;
// pairs = [["OPF_F", ["O_Truck_02_covered_F", ...]], ["BLU_F", [...]]]
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_kind", "land", [""]],
    ["_factions", [], [[]]]
];

if (_factions isEqualTo []) exitWith { [] };

// Map kind to isKindOf gate(s) and minimum cargo slot count.
private _kindGates = [];
private _minCargo = 0;
switch (_kind) do {
    case "land":      { _kindGates = ["Truck"];                                                    _minCargo = 2; };
    case "air":       { _kindGates = ["Helicopter"];                                               _minCargo = 2; };
    case "support":   { _kindGates = ["Truck"];                                                    _minCargo = 0; };
    case "container": { _kindGates = ["ReammoBox_F", "Slingload_01_Base_F", "CargoNet_01_base_F"]; _minCargo = 0; };
    case "supply":    { _kindGates = ["ReammoBox_F"];                                              _minCargo = 0; };
    default           { _kindGates = ["Truck"];                                                    _minCargo = 2; };
};

private _isVehicleKind = (_kind in ["land", "air", "support"]);

private _result = [];

{
    private _faction = _x;
    private _hits = [];

    if (_isVehicleKind) then {
        // Vehicle kinds: defer to findVehicleType per gate (cached per faction+type).
        {
            private _gate = _x;
            private _classes = [_minCargo, _faction, _gate] call ALIVE_fnc_findVehicleType;
            { _hits pushBackUnique _x } forEach _classes;
        } forEach _kindGates;
    } else {
        // Box / container kinds: walk CfgVehicles directly.
        // ReammoBox-derived classes don't appear in CfgGroups so the
        // findVehicleType cache path doesn't help here.
        for "_i" from 1 to (count (configFile >> "CfgVehicles") - 1) do {
            private _entry = (configFile >> "CfgVehicles") select _i;
            if (getNumber (_entry >> "scope") >= 1) then {
                private _entryFaction = getText (_entry >> "faction");
                if (_entryFaction == _faction) then {
                    private _entryClass = configName _entry;
                    private _passes = false;
                    {
                        if (_entryClass isKindOf _x) exitWith { _passes = true };
                    } forEach _kindGates;
                    if (_passes) then {
                        _hits pushBackUnique _entryClass;
                    };
                };
            };
        };
    };

    _hits sort true;
    _result pushBack [_faction, _hits];
} forEach _factions;

_result
