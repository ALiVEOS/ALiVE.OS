#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskGetCivilianClasses);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_taskGetCivilianClasses

Description:
Returns a list of civilian unit classnames suitable for spawning in
Hearts and Minds tasks (AidDelivery, MarketReopening, MeetLocalLeader,
MedicalOutreach, SecureCommunityEvent, CheckpointPartnership,
InformantExfiltration, VIPEscort, SupplyConvoy).

Resolves the configured civilian faction from the Civilian Population
System module's `ambientCrowdFaction` attribute and pulls the matching
"Man"-kindOf class list. Falls back to the vanilla A3 CIV_F class set
when no module is loaded or no classes are found for the configured
faction.

Mirrors the scope-bump logic used by amb_civ_placement so factions
whose generic Man units have BI internal scope=1 (CIV_F, C_VIET,
SPE_CIV) still produce a populated list.

Parameters:
ARRAY (optional) - fallback class list if faction lookup fails
                   (default: vanilla CIV_F polo / worker / fugitive set)

Returns:
ARRAY - list of civilian unit classnames

Examples:
(begin example)
private _civClass = selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses);
private _unit = _group createUnit [_civClass, _pos, [], 0, "NONE"];
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_fallback", [
        "C_man_1",
        "C_man_polo_1_F",
        "C_man_polo_2_F",
        "C_man_polo_4_F",
        "C_man_polo_5_F",
        "C_man_p_fugitive_F",
        "C_man_shorts_1_F",
        "C_man_w_worker_F"
    ], [[]]]
];

private _faction = "CIV_F";

if (!isNil "ALIVE_civilianPopulationSystem") then {
    private _configured = [ALIVE_civilianPopulationSystem, "ambientCrowdFaction", ""] call ALiVE_fnc_hashGet;
    if (_configured isEqualType "" && {_configured != ""}) then {
        _faction = _configured;
    };
};

private _minScope = 1;
if (_faction in ["CIV_F", "C_VIET", "SPE_CIV"]) then { _minScope = 2 };

private _classes = [0, _faction, "Man", false, _minScope] call ALiVE_fnc_findVehicleType;

if (_classes isEqualTo []) exitWith { _fallback };

_classes
