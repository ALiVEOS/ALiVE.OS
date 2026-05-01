#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civilianPopulationSystemInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civilianPopulationSystemInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module

Returns:
Nil

See Also:

Author:
ARjay, Jman (advanced civs)
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params ["_logic"];

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_civilianPopulationSystem","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

if(isServer) then {

    MOD(amb_civ_population) = _logic;

    private _debug = (_logic getVariable ["debug","false"]) == "true";
    private _spawnRadius = parseNumber (_logic getVariable ["spawnRadius","1500"]);
    private _spawnTypeHeliRadius = parseNumber (_logic getVariable ["spawnTypeHeliRadius","1500"]);
    private _spawnTypeJetRadius = parseNumber (_logic getVariable ["spawnTypeJetRadius","0"]);
    private _activeLimiter = parseNumber (_logic getVariable ["activeLimiter","30"]);
    private _hostilityWest = parseNumber (_logic getVariable ["hostilityWest","0"]);
    private _hostilityEast = parseNumber (_logic getVariable ["hostilityEast","0"]);
    private _hostilityIndep = parseNumber (_logic getVariable ["hostilityIndep","0"]);
    private _ambientCivilianRoles = call compile (_logic getVariable ["ambientCivilianRoles","[]"]);
    private _ambientCrowdSpawn = parseNumber (_logic getVariable ["ambientCrowdSpawn","0"]);
    private _ambientCrowdDensity = parseNumber (_logic getVariable ["ambientCrowdDensity","4"]);
    private _ambientCrowdLimit = parseNumber (_logic getVariable ["ambientCrowdLimit","50"]);
    private _ambientCrowdFaction = (_logic getVariable ["ambientCrowdFaction",""]);

    // Custom water / ration item classnames. Merge the multi-select
    // (ALiVE_ItemChoiceMulti_Water/_Ration) array with the manual-
    // override Edit sibling (comma-separated string) into a deduped
    // array. Backward-compat with legacy SQMs that stored the value as
    // a single comma-separated string, an SQF array literal, or a bare
    // classname. Also fixes a pre-existing variable-name mismatch on
    // the ration field: CfgVehicles property is customHumRatItems but
    // this file previously read customRationItems, so the attribute
    // never reached the runtime.
    private _mergeItems = {
        params ["_primaryKey", "_manualKey"];
        private _raw    = _logic getVariable [_primaryKey, []];
        private _manual = _logic getVariable [_manualKey, ""];
        private _arr = if (typeName _raw == "ARRAY") then {
            +_raw
        } else {
            if (_raw == "") then { [] } else {
                private _trimmed = [_raw, " ", ""] call CBA_fnc_replace;
                if (count _trimmed > 0 && {(_trimmed select [0, 1]) == "["}) then {
                    private _parsed = parseSimpleArray _trimmed;
                    if (typeName _parsed == "ARRAY") then { _parsed } else { [] }
                } else {
                    [_trimmed, ","] call CBA_fnc_split
                }
            }
        };
        private _manualArr = if (_manual == "") then { [] } else {
            [[_manual, " ", ""] call CBA_fnc_replace, ","] call CBA_fnc_split
        };
        private _merged = [];
        {
            if (typeName _x == "STRING" && {_x != ""} && {!(_x in _merged)}) then {
                _merged pushBack _x;
            };
        } forEach (_arr + _manualArr);
        _merged
    };
    private _customWaterItems  = ["customWaterItems",  "customWaterItemsManual"]  call _mergeItems;
    private _customRationItems = ["customHumRatItems", "customHumRatItemsManual"] call _mergeItems;

    // Publish the disable-ambient-sounds toggle as a mission-namespace global
    // so the per-building sound functions (fnc_addAmbientRoomMusic,
    // fnc_addCustomBuildingSound) can early-exit without the crowd activator
    // FSM needing to know about the setting. Issue #857.
    private _disableAmbientSounds = (_logic getVariable ["disableAmbientSounds", "false"]) isEqualTo "true";
    missionNamespace setVariable ["ALiVE_CivPop_AmbientSoundsDisabled", _disableAmbientSounds, true];

    // ----------------------------------------------------------------
    //  Advanced Civilians - read module args and set globals
    //
    //  Note: advciv_section_header is a display-only dummy argument used
    //  as a visual divider in the Eden module UI. It is intentionally not
    //  read or published here.
    // ----------------------------------------------------------------
    private _advciv_enabled          = (_logic getVariable ["advciv_enabled",          "true"]) isEqualTo "true";
    private _advciv_debug            = (_logic getVariable ["advciv_debug",            "false"]) isEqualTo "true";
    private _advciv_tickRate         = parseNumber (_logic getVariable ["advciv_tickRate",         "3"]);
    private _advciv_batchSize        = parseNumber (_logic getVariable ["advciv_batchSize",        "0"]);

    private _advciv_unsuppressedRange = parseNumber (_logic getVariable ["advciv_unsuppressedRange", "250"]);
    private _advciv_suppressedRange   = parseNumber (_logic getVariable ["advciv_suppressedRange",   "50"]);
    private _advciv_explosionRange    = parseNumber (_logic getVariable ["advciv_explosionRange",    "500"]);

    private _advciv_reactionRadius   = parseNumber (_logic getVariable ["advciv_reactionRadius",   "150"]);
    private _advciv_fleeRadius       = parseNumber (_logic getVariable ["advciv_fleeRadius",       "120"]);
    private _advciv_homeRadius       = parseNumber (_logic getVariable ["advciv_homeRadius",       "150"]);
    private _advciv_curiosityRange   = parseNumber (_logic getVariable ["advciv_curiosityRange",   "200"]);
    private _advciv_panicChance      = parseNumber (_logic getVariable ["advciv_panicChance",      "0.7"]);
    private _advciv_alertChance      = parseNumber (_logic getVariable ["advciv_alertChance",      "0.5"]);
    private _advciv_cascadeRadius    = parseNumber (_logic getVariable ["advciv_cascadeRadius",    "20"]);
    private _advciv_cascadeChance    = parseNumber (_logic getVariable ["advciv_cascadeChance",    "0.25"]);
    private _advciv_shotMemoryTime   = parseNumber (_logic getVariable ["advciv_shotMemoryTime",   "30"]);
    private _advciv_handsUpChance    = parseNumber (_logic getVariable ["advciv_handsUpChance",    "0.30"]);
    private _advciv_dropChance       = parseNumber (_logic getVariable ["advciv_dropChance",       "0.25"]);
    private _advciv_freezeChance     = parseNumber (_logic getVariable ["advciv_freezeChance",     "0.15"]);
    private _advciv_screamChance     = parseNumber (_logic getVariable ["advciv_screamChance",     "0.15"]);
    // crawlChance is the implicit fallback in fnc_advciv_react: whatever probability remains
    // after the four explicit chances is assigned to CRAWL. It is not configurable at runtime.
    private _advciv_hideTimeMin      = parseNumber (_logic getVariable ["advciv_hideTimeMin",      "60"]);
    private _advciv_hideTimeMax      = parseNumber (_logic getVariable ["advciv_hideTimeMax",      "180"]);
    private _advciv_preferBuildings  = (_logic getVariable ["advciv_preferBuildings",  "true"])  isEqualTo "true";
    private _advciv_nightSleepAnim   = (_logic getVariable ["advciv_nightSleepAnim",   "true"])  isEqualTo "true";
    private _advciv_voiceEnabled     = (_logic getVariable ["advciv_voiceEnabled",     "false"]) isEqualTo "true";
    private _advciv_voiceChance      = parseNumber (_logic getVariable ["advciv_voiceChance",      "0.6"]);
    private _advciv_orderMenuRange   = parseNumber (_logic getVariable ["advciv_orderMenuRange",   "4"]);
    private _civIntelGatherChance    = parseNumber (_logic getVariable ["civIntelGatherChance",    "30"]);
    private _civHostilityIndicator   = _logic getVariable ["civHostilityIndicator", "OFF"];
    private _civWeaponAimRange       = parseNumber (_logic getVariable ["civWeaponAimRange",       "15"]);
    private _civVehicleStopOnAim     = (_logic getVariable ["civVehicleStopOnAim",     "true"]) isEqualTo "true";
    private _civHostilityDecayRate   = parseNumber (_logic getVariable ["civHostilityDecayRate",   "1"]);

    private _advciv_vehicleEscape       = (_logic getVariable ["advciv_vehicleEscape",       "true"])  isEqualTo "true";
    private _advciv_vehicleEscapeChance = parseNumber (_logic getVariable ["advciv_vehicleEscapeChance", "0.3"]);
    private _advciv_noStealMilitary     = (_logic getVariable ["advciv_noStealMilitary",     "true"])  isEqualTo "true";
    private _advciv_noStealUsed         = (_logic getVariable ["advciv_noStealUsed",         "true"])  isEqualTo "true";
    private _advciv_noStealLoaded       = (_logic getVariable ["advciv_noStealLoaded",       "true"])  isEqualTo "true";
    private _advciv_loadedThreshold     = parseNumber (_logic getVariable ["advciv_loadedThreshold",     "4"]);

    private _advciv_missionCriticalCheck = (_logic getVariable ["advciv_missionCriticalCheck", "true"])  isEqualTo "true";

    // Civilian interaction UI mode (AUTO / DIALOG / CLASSIC / ACE).
    // AUTO picks ACE when ace_interact_menu is loaded, else DIALOG at
    // the addAction registration sites. CLASSIC preserves the legacy
    // scroll-wheel sprawl (advciv_orderMenu + addCivilianActions).
    // ACE is a reserved mode for the forthcoming sys_acemenu civilian
    // branch; today it falls through to DIALOG until that branch lands.
    private _civilianInteractionUI = _logic getVariable ["civilianInteractionUI", "AUTO"];

    // Publish all Advanced Civilian globals
    ALiVE_advciv_enabled          = _advciv_enabled;          publicVariable "ALiVE_advciv_enabled";
    ALiVE_advciv_debug            = _advciv_debug;            publicVariable "ALiVE_advciv_debug";
    ALiVE_advciv_tickRate         = _advciv_tickRate;         publicVariable "ALiVE_advciv_tickRate";
    ALiVE_advciv_batchSize        = _advciv_batchSize;        publicVariable "ALiVE_advciv_batchSize";

    ALiVE_advciv_unsuppressedRange = _advciv_unsuppressedRange; publicVariable "ALiVE_advciv_unsuppressedRange";
    ALiVE_advciv_suppressedRange   = _advciv_suppressedRange;   publicVariable "ALiVE_advciv_suppressedRange";
    ALiVE_advciv_explosionRange    = _advciv_explosionRange;    publicVariable "ALiVE_advciv_explosionRange";

    ALiVE_advciv_reactionRadius   = _advciv_reactionRadius;   publicVariable "ALiVE_advciv_reactionRadius";
    ALiVE_advciv_fleeRadius       = _advciv_fleeRadius;       publicVariable "ALiVE_advciv_fleeRadius";
    ALiVE_advciv_homeRadius       = _advciv_homeRadius;       publicVariable "ALiVE_advciv_homeRadius";
    ALiVE_advciv_curiosityRange   = _advciv_curiosityRange;   publicVariable "ALiVE_advciv_curiosityRange";
    ALiVE_advciv_panicChance      = _advciv_panicChance;      publicVariable "ALiVE_advciv_panicChance";
    ALiVE_advciv_alertChance      = _advciv_alertChance;      publicVariable "ALiVE_advciv_alertChance";
    ALiVE_advciv_cascadeRadius    = _advciv_cascadeRadius;    publicVariable "ALiVE_advciv_cascadeRadius";
    ALiVE_advciv_cascadeChance    = _advciv_cascadeChance;    publicVariable "ALiVE_advciv_cascadeChance";
    ALiVE_advciv_shotMemoryTime   = _advciv_shotMemoryTime;   publicVariable "ALiVE_advciv_shotMemoryTime";
    ALiVE_advciv_handsUpChance    = _advciv_handsUpChance;    publicVariable "ALiVE_advciv_handsUpChance";
    ALiVE_advciv_dropChance       = _advciv_dropChance;       publicVariable "ALiVE_advciv_dropChance";
    ALiVE_advciv_freezeChance     = _advciv_freezeChance;     publicVariable "ALiVE_advciv_freezeChance";
    ALiVE_advciv_screamChance     = _advciv_screamChance;     publicVariable "ALiVE_advciv_screamChance";
    ALiVE_advciv_hideTimeMin      = _advciv_hideTimeMin;      publicVariable "ALiVE_advciv_hideTimeMin";
    ALiVE_advciv_hideTimeMax      = _advciv_hideTimeMax;      publicVariable "ALiVE_advciv_hideTimeMax";
    ALiVE_advciv_preferBuildings  = _advciv_preferBuildings;  publicVariable "ALiVE_advciv_preferBuildings";
    ALiVE_advciv_nightSleepAnim   = _advciv_nightSleepAnim;   publicVariable "ALiVE_advciv_nightSleepAnim";
    ALiVE_advciv_voiceEnabled     = _advciv_voiceEnabled;     publicVariable "ALiVE_advciv_voiceEnabled";
    ALiVE_advciv_voiceChance      = _advciv_voiceChance;      publicVariable "ALiVE_advciv_voiceChance";
    ALiVE_advciv_orderMenuRange   = _advciv_orderMenuRange;   publicVariable "ALiVE_advciv_orderMenuRange";

    ALiVE_amb_civ_population_UIMode = _civilianInteractionUI; publicVariable "ALiVE_amb_civ_population_UIMode";
    ALiVE_amb_civ_population_IntelGatherChance = _civIntelGatherChance; publicVariable "ALiVE_amb_civ_population_IntelGatherChance";
    ALiVE_amb_civ_population_HostilityIndicator = _civHostilityIndicator; publicVariable "ALiVE_amb_civ_population_HostilityIndicator";
    ALiVE_amb_civ_population_WeaponAimRange = _civWeaponAimRange; publicVariable "ALiVE_amb_civ_population_WeaponAimRange";
    ALiVE_amb_civ_population_VehicleStopOnAim = _civVehicleStopOnAim; publicVariable "ALiVE_amb_civ_population_VehicleStopOnAim";
    ALiVE_amb_civ_population_HostilityDecayRate = _civHostilityDecayRate; publicVariable "ALiVE_amb_civ_population_HostilityDecayRate";

    ALiVE_advciv_vehicleEscape       = _advciv_vehicleEscape;       publicVariable "ALiVE_advciv_vehicleEscape";
    ALiVE_advciv_vehicleEscapeChance = _advciv_vehicleEscapeChance; publicVariable "ALiVE_advciv_vehicleEscapeChance";
    ALiVE_advciv_noStealMilitary     = _advciv_noStealMilitary;     publicVariable "ALiVE_advciv_noStealMilitary";
    ALiVE_advciv_noStealUsed         = _advciv_noStealUsed;         publicVariable "ALiVE_advciv_noStealUsed";
    ALiVE_advciv_noStealLoaded       = _advciv_noStealLoaded;       publicVariable "ALiVE_advciv_noStealLoaded";
    ALiVE_advciv_loadedThreshold     = _advciv_loadedThreshold;     publicVariable "ALiVE_advciv_loadedThreshold";

    ALiVE_advciv_missionCriticalCheck = _advciv_missionCriticalCheck; publicVariable "ALiVE_advciv_missionCriticalCheck";

    ALiVE_advciv_activeUnits = [];

    // ----------------------------------------------------------------
    //  Utility functions - defined globally and broadcast to all clients
    // ----------------------------------------------------------------
    ALiVE_fnc_advciv_isMissionCritical = {
        params [["_unit", objNull]];
        if (isNull _unit) exitWith { false };
        if (_unit getVariable ["ALiVE_advciv_blacklist", false]) exitWith { true };
        if (!ALiVE_advciv_missionCriticalCheck) exitWith { false };

        private _grp = group _unit;
        // Only block civs in mixed groups (civ + military together)
        private _mixedGroup = { side _x != civilian } count (units _grp);
        if (_mixedGroup > 0) exitWith { true };
        if (count (synchronizedObjects _unit) > 0) exitWith { true };

        // Smart curator detection: only block explicitly marked units
        private _curated = false;
        if (_unit getVariable ["ALiVE_curator_placed", false]) then { _curated = true; };
        if (_curated) exitWith { true };

        false
    };
    publicVariable "ALiVE_fnc_advciv_isMissionCritical";

    ALiVE_fnc_advciv_isValidCiv = {
        params [["_unit", objNull]];
        if (isNull _unit) exitWith { false };
        if (!alive _unit) exitWith { false };
        if (isPlayer _unit) exitWith { false };
        if (side _unit != civilian) exitWith { false };
        if ([_unit] call ALiVE_fnc_advciv_isMissionCritical) exitWith { false };
        true
    };
    publicVariable "ALiVE_fnc_advciv_isValidCiv";

    // ----------------------------------------------------------------
    //  Voice line arrays
    // ----------------------------------------------------------------
    ALiVE_advciv_voiceLines_panic  = [
        "ALiVE_advciv_dont_shoot_1",
        "ALiVE_advciv_dont_shoot_2",
        "ALiVE_advciv_no_no",
        "ALiVE_advciv_please_no",
        "ALiVE_advciv_help",
        "ALiVE_advciv_scream_1",
        "ALiVE_advciv_scream_2"
    ];
    publicVariable "ALiVE_advciv_voiceLines_panic";

    ALiVE_advciv_voiceLines_hit    = [
        "ALiVE_advciv_dont_shoot_1",
        "ALiVE_advciv_dont_shoot_2",
        "ALiVE_advciv_no_no",
        "ALiVE_advciv_please_no",
        "ALiVE_advciv_scream_1",
        "ALiVE_advciv_scream_2",
        "ALiVE_advciv_crying"
    ];
    publicVariable "ALiVE_advciv_voiceLines_hit";

    ALiVE_advciv_voiceLines_hiding = [
        "ALiVE_advciv_please_no",
        "ALiVE_advciv_go_away",
        "ALiVE_advciv_crying"
    ];
    publicVariable "ALiVE_advciv_voiceLines_hiding";

    ["ALiVE Advanced Civilians - Module parameters loaded. Enabled: %1", _advciv_enabled] call ALIVE_fnc_dump;

    waitUntil {!isnil "ALiVE_STATIC_DATA_LOADED"};

    _logic setVariable ["waterItems", ALiVE_CivPop_Interaction_WaterItems + _customWaterItems, true];
    _logic setVariable ["rationItems", ALiVE_CivPop_Interaction_RationItems + _customRationItems, true];

//Check if a SYS Profile Module is available
    private _errorMessage = "No Virtual AI system module was found! Please use this module in your mission! %1 %2";
    private _error1 = "";
    private _error2 = ""; //defaults

    if !([QMOD(sys_profile)] call ALiVE_fnc_isModuleAvailable) exitwith {
        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpMPH;
    };

    if !([QMOD(amb_civ_population)] call ALiVE_fnc_isModuleAvailable) then {
        ["WARNING: Civilian Placement module not placed!"] call ALiVE_fnc_DumpR;
    };

    ALIVE_civilianHostility = [] call ALIVE_fnc_hashCreate;
    [ALIVE_civilianHostility, "WEST", _hostilityWest] call ALIVE_fnc_hashSet;
    [ALIVE_civilianHostility, "EAST", _hostilityEast] call ALIVE_fnc_hashSet;
    [ALIVE_civilianHostility, "GUER", _hostilityIndep] call ALIVE_fnc_hashSet;

    ALIVE_civilianPopulationSystem = [nil, "create"] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "init"] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "debug", _debug] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "spawnRadius", _spawnRadius] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "spawnTypeJetRadius", _spawnTypeJetRadius] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "spawnTypeHeliRadius", _spawnTypeHeliRadius] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "activeLimiter", _activeLimiter] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCivilianRoles", _ambientCivilianRoles] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdSpawn", _ambientCrowdSpawn] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdDensity", _ambientCrowdDensity] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdLimit", _ambientCrowdLimit] call ALIVE_fnc_civilianPopulationSystem;
    [ALIVE_civilianPopulationSystem, "ambientCrowdFaction", _ambientCrowdFaction] call ALIVE_fnc_civilianPopulationSystem;

    if (count _ambientCivilianRoles == 0) then {GVAR(ROLES_DISABLED) = true} else {GVAR(ROLES_DISABLED) = false};
    PublicVariable QGVAR(ROLES_DISABLED);

    _logic setVariable ["handler",ALIVE_civilianPopulationSystem];

    PublicVariable QMOD(amb_civ_population);

    [ALIVE_civilianPopulationSystem,"start"] call ALIVE_fnc_civilianPopulationSystem;

};

[_logic] call ALiVE_fnc_civInteractInit;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
