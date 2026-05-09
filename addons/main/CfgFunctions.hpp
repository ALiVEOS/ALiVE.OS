class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class buttonAbort {
                description = "Calls any scripts required when the user disconnects";
                file = "\x\alive\addons\main\fnc_buttonAbort.sqf";
                RECOMPILE;
            };
            class aliveInit {
                description = "ALiVE init function";
                file = "\x\alive\addons\main\fnc_aliveInit.sqf";
                RECOMPILE;
            };
            class Nuke {
                description = "Fires a Nuke at given position";
                file = "\x\alive\addons\main\fnc_Nuke.sqf";
                RECOMPILE;
            };
            class isModuleSynced {
                description = "Checks if modules are synced";
                file = "\x\alive\addons\main\fnc_isModuleSynced.sqf";
                RECOMPILE;
            };
            class isModuleAvailable {
                description = "Checks if modules are available";
                file = "\x\alive\addons\main\fnc_isModuleAvailable.sqf";
                RECOMPILE;
            };
            class versioning {
                description = "Warns or kicks players on version mismatch";
                file = "\x\alive\addons\main\fnc_versioning.sqf";
                RECOMPILE;
            };
            class isModuleInitialised {
                description = "Checks if given modules are initialised";
                file = "\x\alive\addons\main\fnc_isModuleInitialised.sqf";
                RECOMPILE;
            };
            class normalizeFlexiMenuActions {
                description = "Converts CBA flexiMenu code-block actions to string form required by buttonSetAction";
                file = "\x\alive\addons\main\fnc_normalizeFlexiMenuActions.sqf";
                RECOMPILE;
            };
            class spawnObjectiveObjects {
                description = "Parses the objectiveObjects setVariable string from a module logic and spawns the picked classes around the supplied center (#875 shared helper)";
                file = "\x\alive\addons\main\fnc_spawnObjectiveObjects.sqf";
                RECOMPILE;
            };
            class registerForceUpright {
                description = "Tags an entity for force-upright orientation and records its position-grid key for re-application after ALiVE virtualisation cycles";
                file = "\x\alive\addons\main\fnc_registerForceUpright.sqf";
                RECOMPILE;
            };
            class neighbourAwareSearchCap {
                description = "Returns a search-radius ceiling capped at half-distance to the nearest sibling ALiVE placement-class module logic, clamped to [floor, ceiling]";
                file = "\x\alive\addons\main\fnc_neighbourAwareSearchCap.sqf";
                RECOMPILE;
            };
            class pauseModule {
                description = "Pauses given module(s)";
                file = "\x\alive\addons\main\fnc_pauseModule.sqf";
                RECOMPILE;
            };
            class unPauseModule {
                description = "activates given module(s) after pausing";
                file = "\x\alive\addons\main\fnc_unPauseModule.sqf";
                RECOMPILE;
            };
            class pauseModulesAuto {
                description = "Adds EHs to pause all main modules if no players are on server";
                file = "\x\alive\addons\main\fnc_pauseModulesAuto.sqf";
                RECOMPILE;
            };
            class ZEUSinit {
                description = "Initialises Zeus for ALiVE";
                file = "\x\alive\addons\main\fnc_ZEUSinit.sqf";
                RECOMPILE;
            };
            class mainTablet {
                description = "ALiVE Main Tablet";
                file = "\x\alive\addons\main\fnc_mainTablet.sqf";
                RECOMPILE;
            };
            class AI_Distributor {
                description = "Distributes AI to all headless clients";
                file = "\x\alive\addons\main\fnc_AI_Distributor.sqf";
                RECOMPILE;
            };
            class staticDataHandler {
                description = "Serializes loading of staticData";
                file = "\x\alive\addons\main\fnc_staticDataHandler.sqf";
                RECOMPILE;
            };
            class edenValidateOpcomFactions {
                description = "3DEN editor-time validator: warns when OPCOM factions aren't provided by synced placement modules";
                file = "\x\alive\addons\main\fnc_edenValidateOpcomFactions.sqf";
                preInit = 1;
                RECOMPILE;
            };
            class edenValidateFactionCompilerSync {
                description = "3DEN editor-time validator: warns when sys_factioncompiler categories have vehicles synced directly instead of crew";
                file = "\x\alive\addons\main\fnc_edenValidateFactionCompilerSync.sqf";
                preInit = 1;
                RECOMPILE;
            };
            class getVehicleBoundingBox {
                description = "Returns cached [length, width, height] bbox dimensions for a vehicle classname";
                file = "\x\alive\addons\main\fnc_getVehicleBoundingBox.sqf";
                RECOMPILE;
            };
            class findVehicleSpawnPosition {
                description = "Unified vehicle spawn-position validator with bbox-aware footprint check + side-of-road placement";
                file = "\x\alive\addons\main\fnc_findVehicleSpawnPosition.sqf";
                RECOMPILE;
            };
            class findCompositionSpawnPosition {
                description = "Unified composition spawn-position validator (envelope-aware footprint + airfield exclusion + mode bundles for camps / FieldHQ / civilian / roadblock)";
                file = "\x\alive\addons\main\fnc_findCompositionSpawnPosition.sqf";
                RECOMPILE;
            };
            class getCompositionRadius {
                description = "Returns cached composition diameter in metres - walks CfgGroups>Empty config, doubles max-from-origin object distance, adds 5m buffer";
                file = "\x\alive\addons\main\fnc_getCompositionRadius.sqf";
                RECOMPILE;
            };
            class activateReserve {
                description = "Reserve-pool activation tick (one cluster per call) - shared across mil_placement / civ_placement / mil_placement_custom / civ_placement_custom via the cluster's reserveModuleClass hash entry";
                file = "\x\alive\addons\main\fnc_activateReserve.sqf";
                RECOMPILE;
            };
            class getAirfieldGeometry {
                description = "Returns runway and taxiway segments around a position (mil_ato attrs + ALiVE_runway tags + BI substring matches)";
                file = "\x\alive\addons\main\fnc_getAirfieldGeometry.sqf";
                RECOMPILE;
            };
            class findRunwayClear {
                description = "Returns input position unchanged when clear of runway/taxiway segments by `_clearance`m beyond halfWidth, or a perpendicular-nudged position otherwise. One-shot waypoint / unit-sweep helper";
                file = "\x\alive\addons\main\fnc_findRunwayClear.sqf";
                RECOMPILE;
            };
            class listFactionAAUnits {
                description = "Feeder for ALiVE_AAUnitChoiceMulti - returns AA-shape CfgVehicles classes for a faction as 6-tuples [class, display, side, role, category, source]";
                file = "\x\alive\addons\main\fnc_listFactionAAUnits.sqf";
                RECOMPILE;
            };
            class edenAAUnitChoiceLoad {
                description = "Eden attributeLoad handler for ALiVE_AAUnitChoiceMulti (faction-aware AA unit multi-select listbox + Role filter + override field)";
                file = "\x\alive\addons\main\fnc_edenAAUnitChoiceLoad.sqf";
                RECOMPILE;
            };
            class edenAAUnitChoiceSave {
                description = "Eden attributeSave handler for ALiVE_AAUnitChoiceMulti";
                file = "\x\alive\addons\main\fnc_edenAAUnitChoiceSave.sqf";
                RECOMPILE;
            };
            class findAirSpawnPosition {
                description = "Unified air-unit spawn-position validator: helipad/hangar/apron/field cascade, runway+taxiway exclusion, door verification";
                file = "\x\alive\addons\main\fnc_findAirSpawnPosition.sqf";
                RECOMPILE;
            };
            class anyPlayerCanSee {
                description = "True if any alive player within range can see the target (view-cone + LoS) - deferral gate for visible-state changes";
                file = "\x\alive\addons\main\fnc_anyPlayerCanSee.sqf";
                RECOMPILE;
            };
            class listFactionVehicleClasses {
                description = "Feeder for ALiVE_FactionStaticDataChoice - returns kind-filtered CfgVehicles classes per faction";
                file = "\x\alive\addons\main\fnc_listFactionVehicleClasses.sqf";
                RECOMPILE;
            };
            class edenFactionStaticDataLoad {
                description = "Eden attributeLoad handler for ALiVE_FactionStaticDataChoice (multi-select listbox + override field)";
                file = "\x\alive\addons\main\fnc_edenFactionStaticDataLoad.sqf";
                RECOMPILE;
            };
            class edenFactionStaticDataSave {
                description = "Eden attributeSave handler for ALiVE_FactionStaticDataChoice";
                file = "\x\alive\addons\main\fnc_edenFactionStaticDataSave.sqf";
                RECOMPILE;
            };
            class resolveFactionStaticChoice {
                description = "Module-init resolver: parses canonical FACTION=class string and merges into target static-data registry hash";
                file = "\x\alive\addons\main\fnc_resolveFactionStaticChoice.sqf";
                RECOMPILE;
            };
            class edenTaskTypeChoiceLoad {
                description = "Eden attributeLoad handler for ALiVE_TaskTypeChoice (flat-list task-type multi-select with override field)";
                file = "\x\alive\addons\main\fnc_edenTaskTypeChoiceLoad.sqf";
                RECOMPILE;
            };
            class edenTaskTypeChoiceSave {
                description = "Eden attributeSave handler for ALiVE_TaskTypeChoice";
                file = "\x\alive\addons\main\fnc_edenTaskTypeChoiceSave.sqf";
                RECOMPILE;
            };
            class resolveTaskTypeChoice {
                description = "Module-init resolver for flat-list task-type registries (e.g. ALIVE_autoGeneratedTasks)";
                file = "\x\alive\addons\main\fnc_resolveTaskTypeChoice.sqf";
                RECOMPILE;
            };
            class listFactionCompositions {
                description = "Feeder for ALiVE_CompositionChoice - returns [class, displayName] pairs for compositions valid for a given faction";
                file = "\x\alive\addons\main\fnc_listFactionCompositions.sqf";
                RECOMPILE;
            };
            class edenCompositionChoiceLoad {
                description = "Eden attributeLoad handler for ALiVE_CompositionChoice (faction-aware composition multi-select listbox + override field)";
                file = "\x\alive\addons\main\fnc_edenCompositionChoiceLoad.sqf";
                RECOMPILE;
            };
            class edenCompositionChoiceSave {
                description = "Eden attributeSave handler for ALiVE_CompositionChoice";
                file = "\x\alive\addons\main\fnc_edenCompositionChoiceSave.sqf";
                RECOMPILE;
            };
            class edenFilteredMultiSelectLoad {
                description = "Eden attributeLoad handler for ALiVE_FilteredMultiSelect_Base derivatives (single-axis filtered listbox + override edit, consolidated structured-format storage)";
                file = "\x\alive\addons\main\fnc_edenFilteredMultiSelectLoad.sqf";
                RECOMPILE;
            };
            class edenFilteredMultiSelectSave {
                description = "Eden attributeSave handler for ALiVE_FilteredMultiSelect_Base derivatives";
                file = "\x\alive\addons\main\fnc_edenFilteredMultiSelectSave.sqf";
                RECOMPILE;
            };
            class edenFactionTierChoiceLoad {
                description = "Eden attributeLoad handler for ALiVE_FactionTierChoice (swap-selection per-tier picker - all factions visible, filter cycles which tier's ticks display)";
                file = "\x\alive\addons\main\fnc_edenFactionTierChoiceLoad.sqf";
                RECOMPILE;
            };
            class edenFactionTierChoiceSave {
                description = "Eden attributeSave handler for ALiVE_FactionTierChoice";
                file = "\x\alive\addons\main\fnc_edenFactionTierChoiceSave.sqf";
                RECOMPILE;
            };
        };
    };
};
