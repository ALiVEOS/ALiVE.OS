#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(detectIEDIntegrations);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_detectIEDIntegrations
Description:
Walks the Cfg3rdPartyIEDs config registry and returns the subset of
entries whose cfgPatchesName is actually loaded as a CfgPatches class.
This is the runtime-detection entry point for the auto-detect 3rd-party
IED integration strategy - see memory note strategy_auto_detect_addons.

Each returned record is a SQF HashMap with keys:
    cfgPatchesName, displayName, mode,
    roadIEDClasses, urbanIEDClasses, clutterClasses, detonator, className

Phase 1 scope: detection + return only. The consumers (armIED, createIED,
removeIED, Object Classes merge) will start using the mode and class
arrays in later phases.

Parameters:
    None.

Returns:
    ARRAY of HashMaps - one per detected integration. Empty if none.

Author:
Jman
---------------------------------------------------------------------------- */

private _result = [];
private _registry = configFile >> "Cfg3rdPartyIEDs";

if (!isClass _registry) exitWith { _result };

for "_i" from 0 to (count _registry - 1) do {
    private _entry = _registry select _i;
    if (isClass _entry) then {
        private _cfgPatchesName = getText (_entry >> "cfgPatchesName");
        // Skip entries without a cfgPatchesName or whose named addon isn't loaded.
        if (_cfgPatchesName != "" && {isClass (configFile >> "CfgPatches" >> _cfgPatchesName)}) then {
            private _record = createHashMap;
            _record set ["cfgPatchesName",   _cfgPatchesName];
            _record set ["displayName",      getText  (_entry >> "displayName")];
            _record set ["mode",             getText  (_entry >> "mode")];
            _record set ["roadIEDClasses",   getArray (_entry >> "roadIEDClasses")];
            _record set ["urbanIEDClasses",  getArray (_entry >> "urbanIEDClasses")];
            _record set ["clutterClasses",   getArray (_entry >> "clutterClasses")];
            _record set ["detonator",        getArray (_entry >> "detonator")];
            _record set ["className",        configName _entry];
            // Vertical placement offset. isNumber check distinguishes
            // "explicitly set to 0" from "not specified" (getNumber returns 0 in both).
            _record set ["placementZ", if (isNumber (_entry >> "placementZ")) then {
                getNumber (_entry >> "placementZ")
            } else {
                -0.1
            }];
            _record set ["chargeOffsetZ", if (isNumber (_entry >> "chargeOffsetZ")) then {
                getNumber (_entry >> "chargeOffsetZ")
            } else {
                0
            }];
            _record set ["stompRadius", if (isNumber (_entry >> "stompRadius")) then {
                getNumber (_entry >> "stompRadius")
            } else {
                0
            }];
            // autoPickEligible flag: when 1, this integration is eligible to
            // be auto-picked by fnc_IED.sqf's resolver under iChoice=_auto
            // EVEN IF its mode is "alive". The default rule auto-picks only
            // mine-mode integrations; this flag is the explicit opt-in for
            // an alive-mode integration whose class pool should override the
            // ALiVE defaults under Auto (e.g. ACE 3 Explosives, where placing
            // vanilla A3 IED ammo classes is the whole point of the entry
            // because ACE's defuse-interaction wheel auto-attaches to them).
            _record set ["autoPickEligible", if (isNumber (_entry >> "autoPickEligible")) then {
                getNumber (_entry >> "autoPickEligible")
            } else {
                0
            }];
            _result pushBack _record;
        };
    };
};

_result
