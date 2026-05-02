#include "\x\alive\addons\mil_logistics\script_component.hpp"
SCRIPT(MLExcludeKindsFilter);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MLExcludeKindsFilter
Description:
Filters a list of reinforcement candidates against the module's
"Excluded Kinds" attribute. Mission-makers populate the attribute with a
comma-separated list of CfgVehicles parent class names (e.g.
"Tank,Plane"); any candidate whose vehicle inherits from one of those
classes is dropped from the candidate pool.

Two input modes:
  "groups"   - _candidates is an array of group class names; each is
               resolved via ALIVE_fnc_configGetGroup and every unit's
               "vehicle" entry is checked. The group is dropped if ANY
               unit's vehicle isKindOf any excluded class.
  "vehicles" - _candidates is an array of vehicle class names; each is
               checked directly via isKindOf and dropped on a match.

Empty _excludedKinds short-circuits to the original list (no work).

Parameters:
Array  - candidate class names (groups or vehicles depending on _mode)
String - faction class name (only used in "groups" mode)
Array  - excluded CfgVehicles parent class names
String - "groups" or "vehicles"

Returns:
Array - filtered candidate list

Examples:
(begin example)
_filtered = [_motorisedGroups, _eventFaction, _excludedKinds, "groups"] call ALIVE_fnc_MLExcludeKindsFilter;
_filtered = [_planeClasses, "", _excludedKinds, "vehicles"] call ALIVE_fnc_MLExcludeKindsFilter;
(end)

See Also:
- <ALIVE_fnc_ML>

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_candidates", [], [[]]],
    ["_faction", "", [""]],
    ["_excludedKinds", [], [[]]],
    ["_mode", "groups", [""]]
];

if (_excludedKinds isEqualTo []) exitWith { _candidates };
if (_candidates isEqualTo []) exitWith { _candidates };

private _filtered = [];

switch (_mode) do {
    case "groups": {
        {
            private _groupClass = _x;
            private _groupConfig = [_faction, _groupClass] call ALIVE_fnc_configGetGroup;
            private _drop = false;
            if (!isNil "_groupConfig" && {!(_groupConfig isEqualTo [])}) then {
                for "_i" from 0 to (count _groupConfig - 1) do {
                    if (!_drop) then {
                        private _unitConfig = _groupConfig select _i;
                        if (isClass _unitConfig) then {
                            private _vehicle = getText (_unitConfig >> "vehicle");
                            if (_vehicle != "") then {
                                if ((_excludedKinds findIf { _vehicle isKindOf _x }) >= 0) then {
                                    _drop = true;
                                };
                            };
                        };
                    };
                };
            };
            if (!_drop) then { _filtered pushBack _groupClass };
        } forEach _candidates;
    };
    case "vehicles": {
        {
            private _vehicleClass = _x;
            if ((_excludedKinds findIf { _vehicleClass isKindOf _x }) < 0) then {
                _filtered pushBack _vehicleClass;
            };
        } forEach _candidates;
    };
    default {
        // Unknown mode -- return input unchanged rather than silently
        // dropping everything, so a typo doesn't break reinforcements.
        _filtered = _candidates;
    };
};

_filtered
