#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(ied);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_IED
Description:
Creates the server side object to store settings

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled

INT - IED_Threat -
        values[]= {0,50,100,200,350};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 50;
INT - Starting_IED_Threat -
        values[]= {0,50,100,200,350};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 0;
INT - Bomber_Threat -
        values[]= {0,10,20,30,50};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 10;
INT - Locs_IED -
        values[]= {0,1,2};
        texts[]= {"Random","Enemy Occupied Only","Unoccupied"};
        default = 0;
INT - Ambient_VB-IEDs -
        values[]= {0,5,10,15,30};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 5;


Examples:
(begin example)
// Create instance by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_IEDInit>
- <ALIVE_fnc_IEDMenuDef>

Author:
Tupolov, modificationss by Trapw0w

Peer reviewed:
nil

// Arma 2 Classes
DEFAULT_ROADIEDS ["Land_IED_v1_PMC","Land_IED_v2_PMC","Land_IED_v3_PMC","Land_IED_v4_PMC"];
DEFAULT_URBANIEDS ["Land_IED_v1_PMC","Land_IED_v2_PMC","Land_IED_v3_PMC","Land_IED_v4_PMC","Land_IED_v1_PMC","Land_IED_v2_PMC","Land_IED_v3_PMC","Land_IED_v4_PMC","Land_Misc_Rubble_EP1","Land_Misc_Garb_Heap_EP1","Garbage_container","Misc_TyreHeapEP1","Misc_TyreHeap","Garbage_can","Land_bags_EP1"];
DEFAULT_CLUTTER ["Land_Misc_Rubble_EP1","Land_Misc_Garb_Heap_EP1","Garbage_container","Misc_TyreHeapEP1","Misc_TyreHeap","Garbage_can","Land_bags_EP1"]

---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ied
// Threat DEFAULT_ fallbacks are used when the Eden module attribute is not
// explicitly set on the logic (legacy SQMs, upgraded missions, edge cases
// where the attribute-to-logic sync didn't land). These MUST match the
// CfgVehicles `defaultValue` for each attribute or users see surprise
// spawns despite picking "None" in the module UI - see issue #824:
// "empty ambient vehicles whenever I place down an IED Threat module,
//  even with VBIED threat = None".
//
// UI default is "None" (value 0) for all three; VB_IED_Threat and
// Bomber_Threat previously defaulted to 5 and 15 here, producing ~5% of
// towns with surprise VBIED cars and ~15% with suicide bombers on legacy
// missions that never had the attribute synced.
//
// IED_Threat kept at 60 intentionally - if an unconfigured mil_ied module
// produces NO IEDs at all, the module is functionally off and the user
// likely doesn't know why. Non-zero fallback here is "do something useful
// even if unconfigured"; non-zero on Bomber/VBIED is "silently add scary
// things the user didn't ask for". Different trade-off.
#define DEFAULT_BOMBER_THREAT 0
#define DEFAULT_IED_THREAT 60
#define DEFAULT_VB_IED_THREAT 0
#define DEFAULT_VB_IED_SIDE "CIV"
#define DEFAULT_LOCS_IED 0
#define DEFAULT_STARTING_IED_THREAT 0
#define DEFAULT_TAOR []
#define DEFAULT_BLACKLIST []
#define DEFAULT_ROADIEDS ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDUrbanBig_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo"]
#define DEFAULT_URBANIEDS ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDUrbanBig_Remote_Ammo","Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageBags_F","Land_Tyres_F","Land_GarbagePallet_F","Land_Basket_F","Land_Sack_F","Land_Sacks_goods_F","Land_Sacks_heap_F","Land_BarrelTrash_F"]
#define DEFAULT_CLUTTER ["Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageBags_F","Land_Tyres_F","Land_GarbagePallet_F","Land_Basket_F","Land_Sack_F","Land_Sacks_goods_F","Land_Sacks_heap_F","Land_BarrelTrash_F"]

private ["_logic","_operation","_args","_result"];

TRACE_1("IED - input",_this);

params [
    ["_logic", objNull, [objNull]], 
    ["_operation", "", [""]], 
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

switch(_operation) do {
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
        case "create": {
                if (isServer) then {
                    // Ensure only one module is used
                    if !(isNil QUOTE(ADDON)) then {
                        _logic = ADDON;
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_IED_ERROR1");
                    } else {
                        _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];
                        ADDON = _logic;
                    };

                    //Push to clients
                    PublicVariable QUOTE(ADDON);
                };

                TRACE_1("Waiting for object to be ready",true);

                waituntil {!isnil QUOTE(ADDON)};

                _logic = ADDON;

                TRACE_1("Creating class on all localities",true);

                // initialise module game logic on all localities
                _logic setVariable ["super", SUPERCLASS];
                _logic setVariable ["class", MAINCLASS];

                _args = _logic;
        };
        case "init": {
                /*
                MODEL - no visual just reference data
                - server side object only
                - ied threat
                - vb-ied threat
                - bomber threat
                - ied locations
                */

                // Ensure only one module is used
                if (isServer && !(isNil QUOTE(ADDON))) exitWith {
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_ied_ERROR1");
                };

                if (isServer) then {
                    // and publicVariable to clients
                    private ["_debug","_mapInfo","_center","_radius","_taor","_blacklist","_errorMessage","_error1","_error2"];

                    _errorMessage = "Please include the Requires ALiVE module! %1 %2";
                    _error1 = ""; _error2 = ""; //defaults
                    if(
                        !(["ALiVE_require"] call ALiVE_fnc_isModuleavailable)
                       ) exitwith {
                        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                    };

                    ADDON = _logic;

                    // Create store initially on server
                    GVAR(STORE) = [] call ALIVE_fnc_hashCreate;
                    GVAR(Loaded) = false;

                    // if server, initialise module game logic
                    ADDON setVariable ["super", SUPERCLASS];
                    ADDON setVariable ["class", MAINCLASS];
                    ADDON setVariable ["init", true, true];

                    [ADDON, "debug", _logic getVariable ["debug", false]] call MAINCLASS;
                    [ADDON, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
                    [ADDON, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call MAINCLASS;
                    [ADDON, "roadIEDClasses", _logic getVariable ["roadIEDClasses", DEFAULT_ROADIEDS]] call MAINCLASS;
                    [ADDON, "urbanIEDClasses", _logic getVariable ["urbanIEDClasses", DEFAULT_URBANIEDS]] call MAINCLASS;
                    [ADDON, "clutterClasses", _logic getVariable ["clutterClasses", DEFAULT_CLUTTER]] call MAINCLASS;
                    // Legacy migration: earlier versions used a binary `thirdParty` Yes/No,
                    // then a numeric `integrationMode` (0/1/2). The new `integrationChoice`
                    // is a STRING ("_auto", "_force_alive", or a registry className).
                    // Missions saved with either legacy shape get mapped in-place so the
                    // mission-maker doesn't need to re-visit the Eden attribute.
                    private _legacyTp      = _logic getVariable ["thirdParty", nil];
                    private _legacyIMode   = _logic getVariable ["integrationMode", nil];
                    private _iChoiceCurrent = _logic getVariable ["integrationChoice", nil];
                    if (isNil "_iChoiceCurrent") then {
                        private _migrated = nil;
                        if (!isNil "_legacyIMode") then {
                            // 0 = Auto, 1 = ForceDefer (Yes), 2 = ForceALiVE (No)
                            _migrated = switch (_legacyIMode) do {
                                case 2: { "_force_alive" };
                                case 1: { "_auto" };   // old ForceDefer -> Auto (any detected mine wins)
                                default { "_auto" };
                            };
                        } else {
                            if (!isNil "_legacyTp") then {
                                private _on = (_legacyTp isEqualTo true) ||
                                              (_legacyTp isEqualTo 1) ||
                                              (_legacyTp isEqualTo "1") ||
                                              (_legacyTp isEqualTo "true");
                                _migrated = if (_on) then { "_auto" } else { "_force_alive" };
                            };
                        };
                        if (!isNil "_migrated") then {
                            _logic setVariable ["integrationChoice", _migrated];
                            ["ALIVE-%1 MIL_IED: legacy integration setting migrated to integrationChoice='%2' (from thirdParty=%3, integrationMode=%4)",
                                time, _migrated, _legacyTp, _legacyIMode] call ALiVE_fnc_dump;
                        };
                    };
                    [ADDON, "integrationChoice", _logic getVariable ["integrationChoice", "_auto"]] call MAINCLASS;
                    [ADDON, "aiTriggerable", _logic getVariable ["AI_Triggerable", false]] call MAINCLASS;

                    // Normalize numeric/bool Combo attributes through their case handlers.
                    // Eden can store the raw defaultValue string ("0"/"1"/"0.02") when the
                    // user never touched an attribute; each case handler coerces to the
                    // declared type so downstream reads get a clean SCALAR/BOOL.
                    [ADDON, "Persistence",                       _logic getVariable ["Persistence", false]] call MAINCLASS;
                    [ADDON, "IED_Threat",                        _logic getVariable ["IED_Threat", 0]] call MAINCLASS;
                    [ADDON, "IED_Starting_Threat",               _logic getVariable ["IED_Starting_Threat", 0]] call MAINCLASS;
                    [ADDON, "IED_Detection",                     _logic getVariable ["IED_Detection", 1]] call MAINCLASS;
                    [ADDON, "Bomber_Threat",                     _logic getVariable ["Bomber_Threat", 0]] call MAINCLASS;
                    [ADDON, "VB_IED_Threat",                     _logic getVariable ["VB_IED_Threat", 0]] call MAINCLASS;
                    [ADDON, "Locs_IED",                          _logic getVariable ["Locs_IED", 0]] call MAINCLASS;
                    [ADDON, "IED_Engineer_Challenge",            _logic getVariable ["IED_Engineer_Challenge", 1]] call MAINCLASS;
                    [ADDON, "IED_Engineer_Trip_Base",            _logic getVariable ["IED_Engineer_Trip_Base", 0.02]] call MAINCLASS;
                    [ADDON, "IED_Engineer_Trip_ThresholdMin",    _logic getVariable ["IED_Engineer_Trip_ThresholdMin", 0.7]] call MAINCLASS;
                    [ADDON, "IED_Engineer_Trip_ThresholdMax",    _logic getVariable ["IED_Engineer_Trip_ThresholdMax", 1.3]] call MAINCLASS;
                    [ADDON, "IED_Engineer_Decay_Rate",           _logic getVariable ["IED_Engineer_Decay_Rate", 0.01]] call MAINCLASS;
                    [ADDON, "IED_Engineer_Disarm_BaseTime",      _logic getVariable ["IED_Engineer_Disarm_BaseTime", 60]] call MAINCLASS;
                    [ADDON, "IED_Engineer_Disarm_NewDeviceBase", _logic getVariable ["IED_Engineer_Disarm_NewDeviceBase", 0.75]] call MAINCLASS;
                    [ADDON, "roadIEDClasses_autoDetect",         _logic getVariable ["roadIEDClasses_autoDetect", 0]] call MAINCLASS;
                    [ADDON, "urbanIEDClasses_autoDetect",        _logic getVariable ["urbanIEDClasses_autoDetect", 0]] call MAINCLASS;
                    [ADDON, "clutterClasses_autoDetect",         _logic getVariable ["clutterClasses_autoDetect", 0]] call MAINCLASS;

                    publicVariable QUOTE(ADDON);

                    // Auto-detect 3rd-party IED integrations from Cfg3rdPartyIEDs.
                    private _integrations = call ALIVE_fnc_detectIEDIntegrations;
                    ADDON setVariable ["detectedIEDIntegrations", _integrations, true];

                    // Resolve the effective integration mode. integrationChoice is a STRING:
                    //   "_auto"         - pick based on detection (default)
                    //   "_force_alive"  - full ALiVE pipeline, ignore detection
                    //   <className>     - the registry className of a specific integration
                    //                     (e.g. "ACE_Explosives"). If the named integration
                    //                     is currently detected, use its declared mode;
                    //                     otherwise fall back to Auto + warn.
                    //
                    // Auto rule: if any NON-vanilla detected integration declares mode="mine",
                    // use "mine" globally; otherwise use "alive". The vanilla baseline entry
                    // is informational and does not by itself force a mode choice.
                    private _fnAutoResolve = {
                        private _anyMine = (_integrations findIf {
                            (_x get "className") != "ALiVE_Vanilla_A3" &&
                            (_x get "mode") == "mine"
                        }) >= 0;
                        if (_anyMine) then { "mine" } else { "alive" }
                    };
                    private _iChoice = ADDON getVariable ["integrationChoice", "_auto"];
                    private _resolved = switch (true) do {
                        case (_iChoice == "_force_alive"): { "alive" };
                        case (_iChoice == "_auto"):        { call _fnAutoResolve };
                        default {
                            private _match = _integrations findIf { (_x get "className") == _iChoice };
                            if (_match >= 0) then {
                                (_integrations select _match) get "mode"
                            } else {
                                ["ALIVE-%1 MIL_IED WARNING: integrationChoice='%2' is not a currently loaded integration; falling back to Auto", time, _iChoice] call ALiVE_fnc_dump;
                                call _fnAutoResolve
                            };
                        };
                    };
                    ADDON setVariable ["resolvedIntegrationMode", _resolved, true];

                    // ----- Phase 3c: resolved IED class pools with autoDetect + edit detect -
                    // Per-category resolution matrix:
                    //
                    //   autoDetect | edited | source pool
                    //   -----------+--------+--------------------------------------------
                    //   No         | any    | base (current attribute value)
                    //   Yes        | no     | candidate integration's classes (or base if empty)
                    //   Yes        | yes    | base UNION candidate integration's classes
                    //   Auto       | no     | Phase 3b: integration if iChoice/resolved picks it,
                    //              |        | else base
                    //   Auto       | yes    | base (respect user override)
                    //
                    // "edited" = current attribute value differs from compile-time DEFAULT_*.
                    // "candidate integration" = the integration we'd source classes from
                    // regardless of iChoice (for autoDetect=Yes): if iChoice picks a specific
                    // integration use that; otherwise pick the first non-vanilla integration
                    // eligible for auto-pick (mine-mode by default, plus any alive-mode
                    // entry that explicitly sets `autoPickEligible = 1` -- see
                    // Cfg3rdPartyIEDs.hpp ACE_Explosives for the canonical use of that flag).
                    // User's _additional field is ALWAYS appended, de-duplicated.
                    private _candidateIntegration = nil;
                    private _matchIdx = if (_iChoice == "_auto" || _iChoice == "_force_alive") then {
                        _integrations findIf {
                            (_x get "className") != "ALiVE_Vanilla_A3" &&
                            (
                                (_x get "mode") == "mine" ||
                                ((_x getOrDefault ["autoPickEligible", 0]) == 1)
                            )
                        }
                    } else {
                        _integrations findIf { (_x get "className") == _iChoice };
                    };
                    if (_matchIdx >= 0) then {
                        _candidateIntegration = _integrations select _matchIdx;
                    };

                    // _autoModeFollowsIntegration: under autoDetect=Auto, does iChoice imply
                    // we should swap in the integration? Mirrors the Phase 3b rule.
                    private _autoModeFollowsIntegration = !(_iChoice == "_force_alive") &&
                                                          !(_iChoice == "_auto" && _resolved == "alive");

                    private _fnResolveClasses = {
                        params ["_category", "_defaultArr"];
                        private _base       = [ADDON, _category] call MAINCLASS;
                        private _autoDetect = ADDON getVariable [_category + "_autoDetect", 0];
                        private _edited     = !(_base isEqualTo _defaultArr);
                        private _iClasses   = if (!isNil "_candidateIntegration") then {
                            _candidateIntegration get _category
                        } else { [] };
                        private _hasIClasses = (count _iClasses > 0);

                        private _pool = switch (_autoDetect) do {
                            case 2: { +_base };                      // No - never integration
                            case 1: {                                // Yes - always merge if any
                                if (_hasIClasses) then {
                                    if (_edited) then {
                                        // user override - union with integration
                                        private _p = +_base;
                                        { if (!(_x in _p)) then { _p pushBack _x; }; } forEach _iClasses;
                                        _p
                                    } else {
                                        // base is default - replace with integration (Option A)
                                        +_iClasses
                                    };
                                } else { +_base };
                            };
                            default {                                // Auto (0)
                                if (_edited) then {
                                    +_base                            // respect user edits
                                } else {
                                    if (_autoModeFollowsIntegration && _hasIClasses) then {
                                        +_iClasses                    // Phase 3b behaviour
                                    } else {
                                        +_base
                                    };
                                };
                            };
                        };

                        // Stack user's _additional, deduped.
                        private _addStr = _logic getVariable [_category + "_additional", ""];
                        if (typeName _addStr == "STRING" && {_addStr != ""}) then {
                            private _addArr = [_addStr, " ", ""] call CBA_fnc_replace;
                            _addArr = [_addArr, ","] call CBA_fnc_split;
                            {
                                if (_x != "" && {!(_x in _pool)}) then { _pool pushBack _x; };
                            } forEach _addArr;
                        };
                        _pool
                    };

                    ADDON setVariable ["resolvedRoadIEDClasses",  ["roadIEDClasses",  DEFAULT_ROADIEDS]  call _fnResolveClasses, true];
                    ADDON setVariable ["resolvedUrbanIEDClasses", ["urbanIEDClasses", DEFAULT_URBANIEDS] call _fnResolveClasses, true];
                    ADDON setVariable ["resolvedClutterClasses",  ["clutterClasses",  DEFAULT_CLUTTER]  call _fnResolveClasses, true];

                    // Vertical placement offset (Z). When an integration is the active
                    // authority (specific choice, or Auto picked it), use its declared
                    // placementZ. Otherwise fall back to ALiVE's classic burial (-0.1).
                    // chargeOffsetZ travels alongside placementZ - it controls where the
                    // attached ALIVE_DemoCharge_Remote_Ammo sits relative to the IED.
                    private _activeForZ = !isNil "_candidateIntegration" &&
                                          {_autoModeFollowsIntegration || _iChoice == "_force_alive"} &&
                                          {_iChoice != "_force_alive"};
                    private _resolvedPlacementZ = if (_activeForZ) then {
                        _candidateIntegration get "placementZ"
                    } else {
                        -0.1
                    };
                    private _resolvedChargeOffsetZ = if (_activeForZ) then {
                        _candidateIntegration get "chargeOffsetZ"
                    } else {
                        0
                    };
                    private _resolvedStompRadius = if (_activeForZ) then {
                        _candidateIntegration get "stompRadius"
                    } else {
                        0
                    };
                    ADDON setVariable ["resolvedPlacementZ", _resolvedPlacementZ, true];
                    ADDON setVariable ["resolvedChargeOffsetZ", _resolvedChargeOffsetZ, true];
                    ADDON setVariable ["resolvedStompRadius", _resolvedStompRadius, true];

                    if (ADDON getVariable ["debug", false]) then {
                        ["ALIVE-%1 MIL_IED Phase 3c: candidate=%2, road=%3 (autoDetect=%4) urban=%5 (autoDetect=%6) clutter=%7 (autoDetect=%8)",
                            time,
                            if (isNil "_candidateIntegration") then { "(none)" } else { _candidateIntegration get "displayName" },
                            count (ADDON getVariable "resolvedRoadIEDClasses"),  ADDON getVariable ["roadIEDClasses_autoDetect", 0],
                            count (ADDON getVariable "resolvedUrbanIEDClasses"), ADDON getVariable ["urbanIEDClasses_autoDetect", 0],
                            count (ADDON getVariable "resolvedClutterClasses"),  ADDON getVariable ["clutterClasses_autoDetect", 0]] call ALiVE_fnc_dump;
                    };

                    if (count _integrations == 0) then {
                        ["ALIVE-%1 MIL_IED: no 3rd-party IED integrations detected; resolved mode=%2 (choice='%3')",
                            time, _resolved, _iChoice] call ALiVE_fnc_dump;
                    } else {
                        private _summary = _integrations apply {
                            format ["%1 (mode=%2)", _x get "displayName", _x get "mode"]
                        };
                        ["ALIVE-%1 MIL_IED: %2 integration(s) detected: %3 - resolved mode=%4 (choice='%5')",
                            time, count _integrations, _summary joinString ", ", _resolved, _iChoice] call ALiVE_fnc_dump;
                    };

                    _debug = [_logic, "debug"] call MAINCLASS;
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["taor", DEFAULT_TAOR]);
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_BLACKLIST]);

                    // Reset states with provided data;
                    if (_logic getvariable ["Persistence",false]) then {
                        if (isServer && {[QMOD(SYS_DATA)] call ALiVE_fnc_isModuleAvailable}) then {
                            waituntil {!isnil QMOD(SYS_DATA) && {MOD(SYS_DATA) getvariable ["startupComplete",false]}};
                        };

                        _state = [_logic, "load"] call MAINCLASS;
                        if !(typeName _state == "BOOL") then {
                            GVAR(STORE) = _state;
                            GVAR(Loaded) = true;
                            [_logic, "restoreTriggers", [GVAR(STORE), "triggers"] call ALiVE_fnc_hashGet] call MAINCLASS;
                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then { ["IED - IEDs have been loaded from Database"] call ALiVE_fnc_dump; };
                            // DEBUG -------------------------------------------------------------------------------------
                        } else {
                            ["ALiVE IED - No data loaded.. restoring defaults"] call ALiVE_fnc_dump;
                            [GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                            [GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                        };

                    } else {
                        [GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                        [GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                    };

                    GVAR(STORE) call ALIVE_fnc_inspectHash;

                    //Push to clients
                    PublicVariable QGVAR(STORE);

                    [_logic,"start"] call MAINCLASS;

                } else {
                    [_logic, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
                    [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call MAINCLASS;
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["taor", DEFAULT_TAOR]);
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_BLACKLIST]);
                };

              TRACE_2("After module init",ADDON,ADDON getVariable "init");

                // and wait for game logic to initialise
                // TODO merge into lazy evaluation
                waitUntil {!isNil QUOTE(ADDON)};
                waitUntil {ADDON getVariable ["init", false]};

                /*
                VIEW - purely visual
                - initialise menu
                - frequent check to modify menu and display status (ALIVE_fnc_IEDmenuDef)
                */

                /*
                CONTROLLER  - coordination
                - frequent check if player is server admin (ALIVE_fnc_IEDmenuDef)
                */
                _result = ADDON;
        };
        case "start": {
            if (isServer) then {

                private ["_debug","_locations","_placement","_worldName","_file","_clusters","_cluster","_taor","_taorClusters","_blacklist",
                "_sizeFilter","_priorityFilter","_blacklistClusters","_center","_faction","_error"];

                _debug = [_logic, "debug"] call MAINCLASS;

                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["IED - Startup"] call ALiVE_fnc_dump;
                    [true] call ALIVE_fnc_timer;
                };

                _taor = [_logic, "taor"] call MAINCLASS;
                _blacklist = [_logic, "blacklist"] call MAINCLASS;
                _side = _logic getvariable ["VB_IED_Side", DEFAULT_VB_IED_SIDE];

                if !(GVAR(Loaded)) then {
                    // Initialise Locations
                    //
                    // Discover population centres via building-presence clustering
                    // rather than engine `nearestLocations`. The legacy path filtered
                    // on `NameCityCapital`/`NameCity`/`NameVillage`/`Strategic`, which
                    // missed any town the terrain author didn't tag with those
                    // standard classes (e.g. Niakala registers ~3 villages despite
                    // ~25 visible town names — community report 2026-05-13).
                    //
                    // Clustering uses civilian settlement building types — the same
                    // primitive mil_placement and civ_placement use for their own
                    // area discovery, so behaviour stays consistent with what users
                    // see for those modules.
                    //
                    // Each entry in `_locations` is now a tuple [pos, size, label]
                    // rather than an engine LOCATION handle. The downstream
                    // setupTriggers loop and persistence path consume the tuple
                    // shape directly. Best-effort label resolves from a nearby
                    // engine Name* entry if one exists within 200m, else falls
                    // back to a grid-coord synthetic name.
                    //
                    // Cluster discovery depends on `ALIVE_civilianSettlementBuildingTypes`
                    // being populated for the current terrain — done by
                    // staticDataHandler (per-terrain staticData file under
                    // `addons/main/static/`, or hardcoded blocks in Maps.hpp
                    // for known world names). If neither path populated the
                    // list (rare: a terrain entirely unknown to ALiVE), fall
                    // back to the legacy engine `nearestLocations` source so
                    // the module doesn't leave the mission with zero IEDs.
                    private _mapInfo = [] call ALIVE_fnc_getMapInfo;
                    _center = _mapInfo select 0;
                    private _radius = _mapInfo select 2;

                    call ALiVE_fnc_staticDataHandler;

                    private _clusters = [];
                    if (!isNil "ALIVE_civilianSettlementBuildingTypes" && {count ALIVE_civilianSettlementBuildingTypes > 0}) then {
                        _clusters = [ALIVE_civilianSettlementBuildingTypes] call ALIVE_fnc_findTargets;
                        _clusters = [_clusters] call ALIVE_fnc_consolidateClusters;
                    };

                    if (count _clusters > 0) then {
                        _locations = _clusters apply {
                            private _pos = [_x, "center"] call ALIVE_fnc_cluster;
                            private _size = [_x, "size"] call ALIVE_fnc_cluster;
                            if (_size < 250) then { _size = 250 };
                            private _nearLoc = (nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","Strategic"], 200]) select 0;
                            private _label = if (!isNil "_nearLoc" && {!(_nearLoc isEqualTo locationNull)}) then {
                                text _nearLoc
                            } else {
                                format ["Area_%1", mapGridPosition _pos]
                            };
                            [_pos, _size, _label]
                        };
                    } else {
                        // Fallback: legacy engine nearestLocations source.
                        // Convert to the same [pos, size, label] tuple shape so
                        // downstream code can stay uniform.
                        if (_debug) then {
                            ["ALIVE IED - cluster building-types unpopulated for this terrain; falling back to engine nearestLocations"] call ALiVE_fnc_dump;
                        };
                        private _engineLocs = nearestLocations [_center, ["NameCityCapital","NameCity","NameVillage","Strategic"], _radius];
                        _locations = _engineLocs apply {
                            private _pos = position _x;
                            private _size = (size _x) select 0;
                            if (_size < 250) then { _size = 250 };
                            [_pos, _size, text _x]
                        };
                    };

                    if (_debug) then {
                        ["ALIVE IED - location source returned %1 population centres", count _locations] call ALiVE_fnc_dump;
                    };

                    // TAOR / blacklist filtering. The legacy `validateLocations`
                    // helper is built for engine LOCATION / OBJECT inputs; the
                    // tuple shape is simpler to filter inline via `inArea` on the
                    // tuple's position element.
                    if (count _blacklist > 0) then {
                        _locations = _locations select {
                            private _pos = _x select 0;
                            ({ [_pos, _x] call ALiVE_fnc_inArea } count _blacklist) == 0
                        };
                    };
                    if (count _taor > 0) then {
                        _locations = _locations select {
                            private _pos = _x select 0;
                            ({ [_pos, _x] call ALiVE_fnc_inArea } count _taor) > 0
                        };
                    };

                    if (count synchronizedObjects _logic > 0) then {
                        for "_i" from 0 to ((count synchronizedObjects _logic) - 1) do {
                            _mod = (synchronizedObjects _logic) select _i;
                            if (typeof _mod == "ALiVE_mil_OPCOM") then {
                                [_logic, "setupTriggers", [_locations, "starting"]] call MAINCLASS;
                                _locations = [];
                            };
                        };
                    } else {
                        if (!(_logic getVariable["IED_Starting_Threat",0] == 0) && _debug) then {
                            ["ALIVE MIL - Starting IED Threat set without being synced with the OPCOM Commander! Ignoring Starting Threat.."] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    if (count synchronizedObjects _logic == 0) then {
                        // Setup SBIEDs & VBIEDs as they're not yet persisted. Once these are persisted this code can be removed along with the locations hash
                        _locations = [];
                        _locs = {
                            if (_key == "_id" || _key == "_rev") exitWith {};
                            // New-format save: read tuple directly from LocationPos
                            // + LocationLabel keys. Old-format save (pre-cluster-
                            // restructure): legacy LocationObj key held just the
                            // position array; synthesise size/label so the loaded
                            // tuple shape matches the new pipeline.
                            private _locPos = [_value, "LocationPos", []] call ALiVE_fnc_hashGet;
                            private _locLabel = [_value, "LocationLabel", ""] call ALiVE_fnc_hashGet;
                            if (count _locPos == 0) then {
                                // Back-compat: fall back to legacy LocationObj
                                private _legacyPos = [_value, "LocationObj", []] call ALiVE_fnc_hashGet;
                                if (count _legacyPos >= 2) then {
                                    _locPos = (+_legacyPos);
                                    if (count _locPos == 2) then { _locPos pushBack 0 };
                                    _locPos pushBack 250;  // default size
                                    _locLabel = format ["Area_%1", mapGridPosition _legacyPos];
                                };
                            };
                            if (count _locPos >= 4) then {
                                private _pos = [_locPos select 0, _locPos select 1, _locPos select 2];
                                private _size = _locPos select 3;
                                _locations pushBack [_pos, _size, _locLabel];
                            };
                        };

                        [[GVAR(STORE), "locations"] call ALiVE_fnc_hashGet, _locs] call CBA_fnc_hashEachPair;
                        ["ALiVE MIL IED - Setting up new SBIED & VBIED Locations"] call ALiVE_fnc_dump;
                        [_logic, "setupTriggers", [_locations, "regular", true]] call MAINCLASS;
                    };
                    // Data has already been loaded & triggers restored, ensure we don't loop a second time
                    _locations = [];
                };

                [_logic, "setupTriggers", [_locations, "regular"]] call MAINCLASS;

                // DEBUG -------------------------------------------------------------------------------------
                if ([_logic, "debug"] call MAINCLASS) then {
                    ["ALIVE IED - Startup completed"] call ALIVE_fnc_dump;
                    ["ALIVE IED - Count IED Triggers %1", count ([GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet select 1)] call ALIVE_fnc_dump;
                    [] call ALIVE_fnc_timer;
                };
                // DEBUG -------------------------------------------------------------------------------------

                // set module as started
                _logic setVariable ["startupComplete", true];
            };
        };
        case "setupTriggers": {
            private ["_iedThreat", "_startupIED", "_triggerType", "_locations", "_noIED", "_debug"];
            
            // Fetch debug state at start of this case so it is defined even if called standalone
            _debug = [_logic, "debug"] call MAINCLASS;
            
            _locations = _args select 0;
            _triggerType = _args select 1;
            if (count _args > 2) then {
                _noIED = _args select 2;
            } else {
                _noIED = false;
            };

            // Build trigger presence condition based on AI_Triggerable setting.
            // Player-only (default): fires only when at least one player is on foot/vehicle nearby.
            // AI-triggerable: fires when ANY physically spawned alive unit is nearby.
            // Note: ALiVE profiled (virtual) units have no physical presence and cannot
            // enter trigger areas. This setting only affects real spawned units.
            private _aiTriggerable = [_logic, "aiTriggerable"] call MAINCLASS;

            // _trgCondPresence is the inner count check embedded in trigger condition strings.
            // For vehicles: crew members are in thislist; vehicle _x gets the hull;
            // getposATL (vehicle _x) gives hull Z above terrain — checked against 25m.
            private _trgCondPresence =
                if (_aiTriggerable) then {
                    // Any alive unit or vehicle crew at low altitude — players AND AI
                    "({alive _x && ((getposATL (vehicle _x)) select 2 < 25)} count thislist > 0)"
                } else {
                    // Players only: accept either the person object OR their
                    // current vehicle in thisList. When a player boards a
                    // vehicle, the engine stops listing them as a separate
                    // crew entity in the EmptyDetector's thisList - only
                    // the vehicle remains. Checking the person object alone
                    // flips the condition false on boarding, fires the
                    // deactivation handler, and removes the IEDs. Reported
                    // by HepatitisC.TnB on Discord 2026-05-26: "IEDs
                    // disappear when I get in and out of a vehicle". RPT
                    // confirmed the 11s gap between vehicle entry and the
                    // trigger's removeIED dispatch.
                    // NOTE: no curator/Zeus filter here. There is no reliable
                    // server-side way to tell a Game Master flying the Zeus
                    // camera apart from one playing on the ground -
                    // getAssignedCuratorLogic is non-null for ANY Zeus-assigned
                    // player (body or camera), and curatorCamera is client-local
                    // so it reads null on the server. Filtering on it here
                    // suppressed IED spawning for every GM-hosted mission
                    // (Jman 2026-05-30). The bomber-chases-the-camera fix lives
                    // where it belongs - the victim selection in fnc_createBomber
                    // - so a curator hovering over an area can at worst arm a
                    // trigger with no real target nearby, which is harmless.
                    "({((_x in thisList) || ((vehicle _x) in thisList)) && ((getposATL (vehicle _x)) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)"
                };


            switch (_triggerType) do {
                case "starting": {
                    _startupIED = true;
                    _iedThreat = _logic getvariable ["IED_Starting_Threat", DEFAULT_STARTING_IED_THREAT];
                };
                case "regular": {
                    _startupIED = false;
                    _iedThreat = _logic getvariable ["IED_Threat", DEFAULT_IED_THREAT];
                };
            };

            // Set up Bombers and IED triggers at each location (except any player starting location)
            //
            // Each `_x` is a [pos, size, label] tuple produced by the cluster
            // discovery in case "start" (or rebuilt from persistence in the
            // GVAR(Loaded) branch). Legacy engine LOCATION handles are no
            // longer used here — see the rationale comment in case "start".
            {
                private ["_fate","_pos","_size","_label","_trg"];

                _pos   = _x select 0;
                _size  = _x select 1;
                _label = _x select 2;

                if (_debug) then {
                    ["town is %1 at %2. %3m in size", _label, _pos, _size] call ALiVE_fnc_dump;
                };

                // Place triggers if not within distance of players
                if ({(getpos _x distance _pos) < _size} count ([] call BIS_fnc_listPlayers) == 0 || GVAR(Loaded)) then {
                    private ["_sidelist","_sideNum","_factions","_factionClasses"];

                    // If ALiVE Ambient civilians are available get the faction from there
                    if (["ALiVE_amb_civ_placement"] call ALiVE_fnc_isModuleAvailable) then {

                        waituntil {!isnil QMOD(amb_civ_placement)};

                        _factions = [ALiVE_amb_civ_placement getvariable ["faction","CIV_F"]];
                    } else {
                        // Else get faction from side
                        _factions = [];
                        _sidelist = ["EAST","WEST","IND","CIV"];
                        _blacklist = ["Virtual_F","Interactive_F"];
                        _sideNum = _sidelist find _side;
                        _factionClasses = (configfile >> "CfgFactionClasses");
                        for "_i" from 1 to (count _factionClasses - 1) do {
                            private "_element";
                            _element = _factionClasses select _i;
                            if (isclass _element) then {
                                if (getnumber(_element >> "side") == _sideNum && (_blacklist find (configName _element)) == -1) then {
                                    _factions pushback configName _element;
                                };
                            };
                        };
                    };

                    _faction = (selectRandom _factions);

                    //Roll the dice - use 0-100 range so threat values are true percentages
                    if (GVAR(Loaded)) then {
                        _fate = 0;
                    } else {
                        _fate = random 100;
                    };

                    // Per-location persistence record shared by Bombers / VBIEDs /
                    // IEDs. Replaces legacy `LocationObj` (engine LOCATION via
                    // convertLocations getPos) with a [x,y,z,size] numeric array
                    // (convertString-safe) plus a separate label string key.
                    private _storeLocationFn = {
                        if (GVAR(Loaded)) exitWith {};
                        private ["_locs", "_data", "_locPos"];
                        _locs = [GVAR(STORE), "locations", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;
                        _data = [] call ALiVE_fnc_hashCreate;
                        _locPos = [_pos select 0, _pos select 1, _pos select 2, _size];
                        [_data, "LocationPos",   _locPos] call ALiVE_fnc_hashSet;
                        [_data, "LocationLabel", _label]  call ALiVE_fnc_hashSet;
                        [_locs, _label, _data] call ALiVE_fnc_hashSet;
                        [GVAR(STORE), "locations", _locs] call ALiVE_fnc_hashSet;
                    };

                    // Bombers
                    if (_fate < _logic getvariable ["Bomber_Threat", DEFAULT_BOMBER_THREAT] && !(_startupIED)) then {

                        // Place Suicide Bomber trigger

                        _trg = createTrigger["EmptyDetector", _pos];

                        _trg setTriggerArea[(_size+250),(_size+250),0,false];

                        _trg setTriggerActivation["ANY","PRESENT",false];
                        _trg setTriggerStatements[format["this && %1", _trgCondPresence], format ["null = [[getpos thisTrigger,%1,'%2'],thisList] call ALIVE_fnc_createBomber", _size, _faction], ""];

                        if (_debug) then {
                            ["ALIVE-%1 Suicide Bomber Trigger: created at %2 (%3)", time, _label, mapgridposition _pos] call ALiVE_fnc_dump;
                        };

                        call _storeLocationFn;
                    };

                    // VBIEDs
                    if (_fate < _logic getvariable ["VB_IED_Threat", DEFAULT_VB_IED_THREAT] && !(_startupIED)) then {

                        // Place VBIED
                        _trg = createTrigger["EmptyDetector", _pos];

                        _trg setTriggerArea[(_size+250),(_size+250),0,false];

                        _trg setTriggerActivation["ANY","PRESENT",false];
                        _trg setTriggerStatements[format["this && %1", _trgCondPresence], format ["null = [getpos thisTrigger,%1] call ALIVE_fnc_placeVBIED",_size], ""];

                        if (_debug) then {
                            ["ALIVE-%1 VBIED Trigger: created at %2 (%3)", time, _label, mapgridposition _pos] call ALiVE_fnc_dump;
                        };

                        call _storeLocationFn;
                    };

                    // IEDS
                    if (_fate < _iedThreat && !(_noIED)) then {
                        // Place IED trigger
                        _trg = createTrigger["EmptyDetector", _pos];

                        _trg setTriggerArea[(_size+250), (_size+250),0,false];

                        if (_startupIED) then {
                            // IMPROVED: Reduced spawn formula - divisor changed from 50 to 150 for 67% reduction
                            // This makes LOW spawn significantly fewer IEDs
                            _num = round ((_size / 150) * ( _iedThreat / 100));
                            // Ensure minimum of 1 IED if threat > 0
                            if (_num < 1 && _iedThreat > 0) then {_num = 1;};
                            _trg setTriggerActivation["ANY","PRESENT",true]; // true = repeated
                            _trg setTriggerStatements[format["this && %1", _trgCondPresence], format ["null = [getpos thisTrigger,%1,""%2"",%3] call ALIVE_fnc_createIED",_size, _label, _num], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED",_label]];
                            [_logic, "storeTrigger", [_size,_label,_pos, false,"IED",_num]] call MAINCLASS;
                        } else {
                            _trg setTriggerActivation["ANY","PRESENT",true]; // true = repeated
                            _trg setTriggerStatements[format["this && %1", _trgCondPresence], format ["null = [getpos thisTrigger,%1,""%2""] call ALIVE_fnc_createIED",_size, _label], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED", _label]];
                            [_logic, "storeTrigger", [_size,_label,_pos, false, "IED"]] call MAINCLASS;
                        };

                        if (_debug) then {
                            ["ALIVE-%1 IED Trigger: created at %2 (%3)", time, _label, mapgridposition _pos] call ALiVE_fnc_dump;
                        };
                    };

                };
            } foreach _locations;
        };
        // Return TAOR marker
        case "removeIED": {
                if(typeName _args == "OBJECT") then {
                    private ["_IED","_ID","_town","_hash"];
                    _IED = _args;
                    _ID = _IED getvariable ["ID", nil];
                    if (isNil "_ID") exitWith {_result = false;};
                    _town = _IED getvariable "town";
                    _hash = [GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet;
                    _hash = [_hash, _town] call ALIVE_fnc_hashGet;
                    _result = [_hash, _ID] call ALiVE_fnc_hashRem;
                    if ([ADDON, "debug"] call MAINCLASS) then {
                            ["Removed IED %1 at %2", _IED, _town ] call ALIVE_fnc_dump;
                    };
                };
        };
        case "taor": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_TAOR];
        };
        case "blacklist": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_BLACKLIST];
        };
        case "roadIEDClasses": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_ROADIEDS];
        };
        case "urbanIEDClasses": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_URBANIEDS];
        };
        case "clutterClasses": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_CLUTTER];
        };
        case "debug": {
            if (typeName _args == "BOOL") then {
                _logic setVariable ["debug", _args, true];
            } else {
                _args = _logic getVariable ["debug", false];
            };
            // Eden Combo attributes can land on the logic as STRING "1"/"0" or
            // SCALAR 1/0 (not always BOOL). The pre-existing STRING branch only
            // recognised "true"/"false", so a user-selected "Yes" arrived here
            // as STRING "1" and was silently coerced to BOOL false -
            // createMarkers never ran at init and debug markers didn't appear
            // until the admin menu passed BOOL true explicitly.
            if (typeName _args == "STRING") then {
                    _args = (_args in ["1","true"]);
                    _logic setVariable ["debug", _args, true];
            };
            if (typeName _args == "SCALAR") then {
                    _args = _args > 0;
                    _logic setVariable ["debug", _args, true];
            };
            ASSERT_TRUE(typeName _args == "BOOL",str _args);

            [_logic,"deleteMarkers"] call MAINCLASS;

            if (_args) then {
                // Mark each IED, Bomber, VB-IED?
                [_logic,"createMarkers"] call MAINCLASS;
            };
            _result = _args;
        };
        case "locations": {
            _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
        };
        case "integrationChoice": {
            // Custom Eden attribute backed by a STRING token - "_auto",
            // "_force_alive", or a registry className. Coerce non-string
            // inputs (e.g. defaultValue can round-trip as something else)
            // back to a safe default.
            if (typeName _args == "STRING") then {
                _logic setVariable ["integrationChoice", _args];
            } else {
                _args = _logic getVariable ["integrationChoice", "_auto"];
                if (typeName _args != "STRING" || _args == "") then {
                    _args = "_auto";
                    _logic setVariable ["integrationChoice", _args];
                };
            };
            ASSERT_TRUE(typeName _args == "STRING", str _args);
            _result = _args;
        };
        case "aiTriggerable": {
            _result = [_logic,_operation,_args,false] call ALIVE_fnc_OOsimpleOperation;
        };
        case "Persistence": {
            if (typeName _args == "BOOL") then {
                _logic setVariable ["Persistence", _args];
            } else {
                _args = _logic getVariable ["Persistence", false];
            };
            if (typeName _args == "STRING") then {
                _args = (_args in ["1","true"]);
                _logic setVariable ["Persistence", _args];
            };
            if (typeName _args == "SCALAR") then {
                _args = _args > 0;
                _logic setVariable ["Persistence", _args];
            };
            ASSERT_TRUE(typeName _args == "BOOL",str _args);
            _result = _args;
        };
        case "IED_Threat": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Threat", _args];
            } else {
                _args = _logic getVariable ["IED_Threat", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Threat", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Starting_Threat": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Starting_Threat", _args];
            } else {
                _args = _logic getVariable ["IED_Starting_Threat", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Starting_Threat", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Detection": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Detection", _args];
            } else {
                _args = _logic getVariable ["IED_Detection", 1];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Detection", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "Bomber_Threat": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["Bomber_Threat", _args];
            } else {
                _args = _logic getVariable ["Bomber_Threat", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["Bomber_Threat", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "VB_IED_Threat": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["VB_IED_Threat", _args];
            } else {
                _args = _logic getVariable ["VB_IED_Threat", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["VB_IED_Threat", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "Locs_IED": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["Locs_IED", _args];
            } else {
                _args = _logic getVariable ["Locs_IED", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["Locs_IED", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Engineer_Challenge": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Engineer_Challenge", _args];
            } else {
                _args = _logic getVariable ["IED_Engineer_Challenge", 1];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Engineer_Challenge", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Engineer_Trip_Base": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Engineer_Trip_Base", _args];
            } else {
                _args = _logic getVariable ["IED_Engineer_Trip_Base", 0.02];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Engineer_Trip_Base", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Engineer_Trip_ThresholdMin": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Engineer_Trip_ThresholdMin", _args];
            } else {
                _args = _logic getVariable ["IED_Engineer_Trip_ThresholdMin", 0.7];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Engineer_Trip_ThresholdMin", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Engineer_Trip_ThresholdMax": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Engineer_Trip_ThresholdMax", _args];
            } else {
                _args = _logic getVariable ["IED_Engineer_Trip_ThresholdMax", 1.3];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Engineer_Trip_ThresholdMax", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Engineer_Decay_Rate": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Engineer_Decay_Rate", _args];
            } else {
                _args = _logic getVariable ["IED_Engineer_Decay_Rate", 0.01];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Engineer_Decay_Rate", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Engineer_Disarm_BaseTime": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Engineer_Disarm_BaseTime", _args];
            } else {
                _args = _logic getVariable ["IED_Engineer_Disarm_BaseTime", 60];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Engineer_Disarm_BaseTime", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "IED_Engineer_Disarm_NewDeviceBase": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["IED_Engineer_Disarm_NewDeviceBase", _args];
            } else {
                _args = _logic getVariable ["IED_Engineer_Disarm_NewDeviceBase", 0.75];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["IED_Engineer_Disarm_NewDeviceBase", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "roadIEDClasses_autoDetect": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["roadIEDClasses_autoDetect", _args];
            } else {
                _args = _logic getVariable ["roadIEDClasses_autoDetect", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["roadIEDClasses_autoDetect", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "urbanIEDClasses_autoDetect": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["urbanIEDClasses_autoDetect", _args];
            } else {
                _args = _logic getVariable ["urbanIEDClasses_autoDetect", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["urbanIEDClasses_autoDetect", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "clutterClasses_autoDetect": {
            if (typeName _args == "SCALAR") then {
                _logic setVariable ["clutterClasses_autoDetect", _args];
            } else {
                _args = _logic getVariable ["clutterClasses_autoDetect", 0];
            };
            if (typeName _args == "STRING") then {
                _args = parseNumber _args;
                _logic setVariable ["clutterClasses_autoDetect", _args];
            };
            ASSERT_TRUE(typeName _args == "SCALAR",str _args);
            _result = _args;
        };
        case "createMarkers": {

            // Create Markers for locations with IED, Suicide or VB-IED
            private ["_markers"];
            _markers = [];

            _generateMarkers = {
                private ["_pos","_label","_size","_t","_m","_ieds", "_isObj"];
                if (_key == "_id" || _key == "_rev") exitWith {};

                _isObj = [_logic, "convertString", [_value, "TrgObj"] call ALiVE_fnc_hashGet] call MAINCLASS;
                _pos = [_value, "TrgPos"] call ALiVE_fnc_hashGet;
                // `_label` reads explicit TrgLabel (added by storeTrigger).
                // Legacy saves get `_key` as fallback — same string the old
                // path used when the nearestLocations lookup returned no hit.
                _label = [_value, "TrgLabel", _key] call ALiVE_fnc_hashGet;

                if (_isObj) then {
                    _size = [_value, "TrgSize"] call ALiVE_fnc_hashGet;

                    // Mark Locations
                    _t = format["loc_t%1", random 1000];
                    _m = [_t, _pos, "Ellipse", [_size+250,_size+250], "TEXT:", _key, "COLOR:", "ColorYellow", "BRUSH:", "Border", "GLOBAL"] call CBA_fnc_createMarker;
                    _markers pushback _m;

                    // Mark IEDs
                    _ieds = [[GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet, _key, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                } else {
                    _size = [_value, "TrgSize"] call ALiVE_fnc_hashGet;
                    if (_size < 250) then {_size = 250;};

                    // Mark Locations
                    _t = format["loc_t%1", random 1000];
                    _m = [_t, _pos, "Ellipse", [_size+250,_size+250], "TEXT:", _label, "COLOR:", "ColorRed", "BRUSH:", "Border", "GLOBAL"] call CBA_fnc_createMarker;
                    _markers pushback _m;

                    // Mark IEDs
                    _ieds = [[GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet, _label, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                };

                {
                    private ["_t","_m","_text","_iedm","_pos","_type"];

                    //Mark IED position
                    _IED = [_ieds, _x, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                    _t = format["ied_r%1", floor (random 1000)];
                    _pos = [_IED, "IEDpos", [0,0,0]] call ALiVE_fnc_hashGet;
                    _type = [_IED, "IEDtype", "IED"] call ALiVE_fnc_hashGet;
                    _iedm = [_t, _pos, "Icon", [0.5,0.5], "TEXT:", _type, "TYPE:", "mil_dot", "COLOR:", "ColorRed", "GLOBAL"] call CBA_fnc_createMarker;

                    _markers pushback _iedm;

                } foreach (_ieds select 1);

            };

            [[GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet, _generateMarkers] call CBA_fnc_hashEachPair;

            _logic setVariable ["debugMarkers",_markers];

        };
        case "deleteMarkers": {

            // Delete Location markers
            // Delete IED/VB-IED markers
            {
                [_x] call CBA_fnc_deleteEntity;
            } forEach (_logic getVariable ["debugMarkers", []]);

        };
        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];
                        // and publicVariable to clients
                        ADDON = _logic;
                        publicVariable QUOTE(ADDON);
                };

                if(hasInterface) then {
                };
        };

        case "storeTrigger": {
            private ["_num", "_data"];
            // `_twn` here is the location label (was engine-location text;
            // now the cluster tuple's label string). Persisted explicitly as
            // TrgLabel so the restore + debug-marker paths can read it back
            // without re-running `nearestLocations` on the stored position,
            // which fails on terrains with sparse Name* configs (Niakala).
            _args params ["_size", "_twn", "_pos", "_isObj","_type"];

            if (count _args > 5) then {
                _num = _args select 5;
            } else {
                _num = 0;
            };

            _data = [] call ALiVE_fnc_hashCreate;
            [_data, "TrgSize", _size] call ALiVE_fnc_hashSet;
            [_data, "TrgPos", _pos] call ALiVE_fnc_hashSet;
            [_data, "TrgNum", _num] call ALiVE_fnc_hashSet;
            [_data, "TrgType", _type] call ALiVE_fnc_hashSet;
            [_data, "TrgObj", _isObj] call ALiVE_fnc_hashSet;
            [_data, "TrgLabel", _twn] call ALiVE_fnc_hashSet;

            [[GVAR(STORE), "triggers"] call ALiVE_fnc_hashGet, format["%1-%2",_twn,_type], _data] call ALiVE_fnc_hashSet;

            if ([_logic, "debug"] call MAINCLASS) then {
                    ["ALIVE IED - Saving trigger for %1",str(_twn)] call ALiVE_fnc_dump;
            };
        };

        case "restoreTriggers": {
            _restoreTriggers = {
                private ["_data", "_label", "_size", "_num", "_trg"];
                if (_key == "_id" || _key == "_rev") exitWith {};

                // Get data. `_label` reads the explicit TrgLabel key stored
                // by storeTrigger. Falls back to `_key` (the hash key, of
                // shape "<label>-<type>") for legacy saves that pre-date
                // TrgLabel — same fallback the previous nearestLocations
                // path used when no engine location was found near _pos.
                _type = [_value, "TrgType"] call ALiVE_fnc_hashGet;
                _pos = [_value, "TrgPos"] call ALiVE_fnc_hashGet;
                _label = [_value, "TrgLabel", _key] call ALiVE_fnc_hashGet;
                _size = [_value, "TrgSize"] call ALiVE_fnc_hashGet;
                _num = [_value, "TrgNum"] call ALiVE_fnc_hashGet;

                // Build trigger
                _trg = createTrigger["EmptyDetector",_pos];
                _trg setTriggerArea[(_size+250), (_size+250),0,false];
                _trg setTriggerActivation["ANY","PRESENT",true]; // true = repeated

                // Respect AI_Triggerable setting when rebuilding persisted triggers
                private _restoredCond = if ([_logic, "aiTriggerable"] call MAINCLASS) then {
                    "({alive _x && ((getposATL (vehicle _x)) select 2 < 25)} count thislist > 0)"
                } else {
                    // Accept person OR vehicle in thisList - see the
                    // matching comment in case "start" (search for
                    // HepatitisC.TnB) for the vehicle-board issue.
                    // No curator/Zeus filter here - see the matching note in
                    // case "start": there's no reliable server-side test for
                    // "in the Zeus camera vs on the ground", so filtering it
                    // suppressed IED spawning for GM-hosted missions. The
                    // bomber-chase fix is in fnc_createBomber victim selection
                    // (Jman 2026-05-30).
                    "({((_x in thisList) || ((vehicle _x) in thisList)) && ((getposATL (vehicle _x)) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)"
                };

                if (_num > 0) then {
                    _trg setTriggerStatements[format["this && %1", _restoredCond], format ["null = [getpos thisTrigger,%1,""%2"", %3] call ALIVE_fnc_createIED",_size, _label, _num], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED",_label]];
                } else {
                    _trg setTriggerStatements[format["this && %1", _restoredCond], format ["null = [getpos thisTrigger,%1,""%2""] call ALIVE_fnc_createIED",_size, _label], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED",_label]];
                };

                if (_logic getVariable["debug",false]) then {
                    ["ALIVE IED - Restoring %1 trigger in %2",_type,str(_label)] call ALiVE_fnc_dump;
                };

            };

            [_args, _restoreTriggers] call CBA_fnc_hashEachPair;
        };

        case "state": {
            TRACE_1("ALiVE IED state called",_logic);

            if ((isnil "_args") || {!isServer}) exitwith {
                _result = GVAR(STORE)
            };

            // State is being set - restore IEDs
            _result = GVAR(STORE);
        };
        case "load": {
            // Get IEDs from DB
            _result = call ALiVE_fnc_IEDLoadData;
        };

        case "convertLocations": {
            // DEPRECATED. mil_ied's location source switched from engine
            // `nearestLocations` to building-cluster discovery, so the
            // ARRAY<->LOCATION conversion this case provided is no longer
            // needed by the internal call sites. Kept for back-compat in
            // case external code (other addons / mission scripts) still
            // calls `[_logic, "convertLocations", ...] call ALIVE_fnc_ied`.
            // See case "start" for the new pipeline.
            private ["_data"];

            _data = _args select 0;

            switch (typeName _data) do {
                case "ARRAY": {
                    _result = (nearestLocations [_data, ["NameCityCapital","NameCity","NameVillage","Strategic"],5]) select 0;
                };
                case "LOCATION": {
                    _result = getPos _data;
                };
            };
            _result;
        };

        case "convertString": {
            private["_data"];
            _data = _args;
            _type = typeName _data;

            switch (_type) do {
                case "ARRAY": {
                    _converted = [];
                    {
                        if (typeName _x != "SCALAR") then {
                            _converted pushBack (parseNumber _x);
                        } else {
                            _converted pushBack _x;
                        };
                    } forEach _data;
                    _result = _converted;
                };
                case "SCALAR": {
                    _result = _data;
                };
                case "STRING": {
                    switch (_data) do {
                        case "true": {
                            _result = true;
                        };
                        case "false": {
                            _result = false;
                        };
                        case default {
                            _result = parseNumber _data;
                        };
                    };
                };
                case "BOOL": {
                    _result = _data;
                };
            };
        };

        case "convertData": {
            // CouchDB returns SCALAR values encased in "", making them strings. This converts the STRINGS back to SCALAR.
            private["_data", "_locations", "_triggers", "_ieds"];
            _data = _args;

            _locations = [_data, "locations", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;
            _triggers = [_data, "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;
            _ieds = [_data, "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

            _convertLocations = {
                // Convert CouchDB stringified numerics back to SCALAR for the
                // location-position keys. New format: `LocationPos` holds a
                // 4-element [x, y, z, size] numeric array; `LocationLabel`
                // holds a string and needs no conversion. Legacy format:
                // `LocationObj` held a 3-element position array — convert
                // that too so old persisted saves still load (the GVAR(Loaded)
                // branch in case "start" applies a synthesised size + label
                // when only the legacy key is present).
                private ["_loc"];
                if (_key == "_id" || _key == "_rev") exitWith {};

                private _newPos = [_value, "LocationPos", []] call ALiVE_fnc_hashGet;
                if (count _newPos > 0) then {
                    _loc = [_logic, "convertString", _newPos] call MAINCLASS;
                    [_value, "LocationPos", _loc] call ALiVE_fnc_hashSet;
                };

                private _legacyPos = [_value, "LocationObj", []] call ALiVE_fnc_hashGet;
                if (count _legacyPos > 0) then {
                    _loc = [_logic, "convertString", _legacyPos] call MAINCLASS;
                    [_value, "LocationObj", _loc] call ALiVE_fnc_hashSet;
                };
            };

            _convertTriggers = {
                private ["_keys"];
                if (_key == "_id" || _key == "_rev") exitWith {};

                _keys = ["TrgPos", "TrgSize", "TrgNum"];
                {
                    private ["_converted"];
                    _converted = [_logic, "convertString", [_value, _x] call ALiVE_fnc_hashGet] call MAINCLASS;
                    [_value, _x, _converted] call ALiVE_fnc_hashSet;
                } forEach _keys;
            };

            _convertIEDs = {
                private ["_keys"];
                if (_key == "_id" || _key == "_rev") exitWith {};
                
                _script = {
                    _keys = ["IEDpos", "IEDDud"];
                    {
                        private ["_return"];
                        _return = [_logic, "convertString", [_value, _x] call ALiVE_fnc_hashGet] call MAINCLASS;
                        [_value, _x, _return] call ALiVE_fnc_hashSet;

                    } forEach _keys;
                };

                // Each IED location has a sub-hash per IED
                [_value, _script] call CBA_fnc_hashEachPair;
            };

            [_locations, _convertLocations] call CBA_fnc_hashEachPair;
            [_triggers, _convertTriggers] call CBA_fnc_hashEachPair;
            [_ieds, _convertIEDs] call CBA_fnc_hashEachPair;
        };
};
TRACE_1("IED - output",_result);
_result;
