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
        };
    };
};
