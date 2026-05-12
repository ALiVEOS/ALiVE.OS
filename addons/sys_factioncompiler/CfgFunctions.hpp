class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class factionCompilerInit {
                description = "Compile mission-local faction templates from Eden groups";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerInit.sqf";
                RECOMPILE;
            };

            class factionCompilerResolveForModule {
                description = "Resolve a compiled faction synced to a placement module";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerResolveForModule.sqf";
                RECOMPILE;
            };

            class factionCompilerGetFactionData {
                description = "Get compiled faction registry data";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerGetFactionData.sqf";
                RECOMPILE;
            };

            class factionCompilerGetConfigFaction {
                description = "Resolve the config-backed proxy faction for a compiled faction";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerGetConfigFaction.sqf";
                RECOMPILE;
            };

            class factionCompilerIsCompiledFaction {
                description = "Check whether a faction id belongs to the compiler registry";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerIsCompiledFaction.sqf";
                RECOMPILE;
            };

            class factionCompilerFindVehicleType {
                description = "Return vehicles or units from compiled factions matching a findVehicleType query";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerFindVehicleType.sqf";
                RECOMPILE;
            };

            class factionCompilerApplyLoadout {
                description = "Apply a compiled loadout to a spawned profiled unit";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerApplyLoadout.sqf";
                RECOMPILE;
            };

            class factionCompilerCreateProfilesFromGroup {
                description = "Create profiles from a compiler-managed group definition";
                file = "\x\alive\addons\sys_factioncompiler\fnc_factionCompilerCreateProfilesFromGroup.sqf";
                RECOMPILE;
            };
        };
    };
};

