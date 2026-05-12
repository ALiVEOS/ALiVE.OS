class CfgVehicles {
    class Logic;
    class Module_F : Logic {
        class AttributesBase {
            class Edit;
            class Combo;
            class ModuleDescription;
        };
    };
    class ModuleAliveBase : Module_F {
        class AttributesBase : AttributesBase {
            class ALiVE_ModuleSubTitle;
        };
        class ModuleDescription;
    };

    class ALiVE_sys_factioncompiler : ModuleAliveBase {
        scope = 2;
        displayName = "ALiVE Custom Faction Compiler";
        function = "ALiVE_fnc_factionCompilerInit";
        author = MODULE_AUTHOR;
        functionPriority = 1;
        isGlobal = 1;
        class Attributes : AttributesBase {
            class debug : Combo {
                property = "ALiVE_sys_factioncompiler_debug";
                displayName = "Debug";
                tooltip = "Enable debug output for compiler processing.";
                defaultValue = """false""";
                class Values {
                    class Yes {name = "Yes"; value = true;};
                    class No {name = "No"; value = false; default = 1;};
                };
            };
            class factionId : Edit {
                property = "ALiVE_sys_factioncompiler_factionId";
                displayName = "Faction ID";
                tooltip = "Internal faction id used by synced placement modules.";
                defaultValue = """ALIVE_CUSTOM_FACTION""";
            };
            class displayName : Edit {
                property = "ALiVE_sys_factioncompiler_displayName";
                displayName = "Display Name";
                tooltip = "Human-readable name stored with the compiled faction.";
                defaultValue = """Custom Faction""";
            };
            class proxyFaction {
                property = "ALiVE_sys_factioncompiler_proxyFaction";
                displayName = "Proxy Faction";
                tooltip = "Config-backed faction used for side, compositions, and static fallback data.";
                control = "ALiVE_FactionChoice_Military";
                typeName = "STRING";
                // Internal setVariable key is "faction" so the shared
                // save / load handlers in addons/main (which hardcode
                // "faction" in their broadcast write + default read
                // path) persist the value end-to-end. Per-attribute
                // attributeLoad overrides on this `class X { control
                // = "Y"; }` shape are not honoured by Eden, so we
                // align the variable name with the handlers' default
                // instead. Init code reads getVariable ["faction"].
                expression = "_this setVariable ['faction', _value];";
                defaultValue = """OPF_F""";
            };
            class deleteTemplates : Combo {
                property = "ALiVE_sys_factioncompiler_deleteTemplates";
                displayName = "Delete Templates";
                tooltip = "Delete synced template groups after they are compiled.";
                defaultValue = """true""";
                class Values {
                    class Yes {name = "Yes"; value = true; default = 1;};
                    class No {name = "No"; value = false;};
                };
            };
            class ModuleDescription : ModuleDescription {};
        };
        class ModuleDescription : ModuleDescription {
            description[] = {
                "Compile synced Eden template groups into a mission-local ALiVE faction.",
                "",
                "Sync one or more category helper modules to this compiler, then sync one unit from each template group to a category helper. Sync placement modules to this compiler to use the compiled faction at runtime."
            };
            sync[] = {
                "ALiVE_sys_factioncompiler_category",
                "ALiVE_mil_placement",
                "ALiVE_mil_placement_custom",
                "ALiVE_mil_placement_spe",
                "ALiVE_civ_placement",
                "ALiVE_civ_placement_custom",
                "ALiVE_mil_ato"
            };
            class ALiVE_sys_factioncompiler_category {
                description[] = {"Group category helper module."};
                position = 0;
                direction = 0;
                optional = 1;
                duplicate = 1;
            };
            class ALiVE_mil_placement {
                description[] = {"Military Placement module."};
                position = 0;
                direction = 0;
                optional = 1;
                duplicate = 1;
            };
            class ALiVE_mil_placement_custom {
                description[] = {"Custom Military Placement module."};
                position = 0;
                direction = 0;
                optional = 1;
                duplicate = 1;
            };
            class ALiVE_mil_placement_spe {
                description[] = {"Garrison-Objective Military Placement module."};
                position = 0;
                direction = 0;
                optional = 1;
                duplicate = 1;
            };
            class ALiVE_civ_placement {
                description[] = {"Military Placement at Civilian Objectives module."};
                position = 0;
                direction = 0;
                optional = 1;
                duplicate = 1;
            };
            class ALiVE_civ_placement_custom {
                description[] = {"Custom Military Placement at Civilian Objectives module."};
                position = 0;
                direction = 0;
                optional = 1;
                duplicate = 1;
            };
            class ALiVE_mil_ato {
                description[] = {"Air Tasking Order module."};
                position = 0;
                direction = 0;
                optional = 1;
                duplicate = 1;
            };
        };
    };

    class ALiVE_sys_factioncompiler_category : ModuleAliveBase {
        scope = 2;
        displayName = "ALiVE Custom Faction Group Category";
        author = MODULE_AUTHOR;
        functionPriority = 2;
        isGlobal = 0;
        class Attributes : AttributesBase {
            class category : Combo {
                property = "ALiVE_sys_factioncompiler_category_category";
                displayName = "Category";
                tooltip = "ALiVE group category assigned to all template groups synced here.";
                defaultValue = """Infantry""";
                class Values {
                    class Infantry {name = "Infantry"; value = "Infantry"; default = 1;};
                    class SpecOps {name = "Spec Ops"; value = "SpecOps";};
                    class Motorized {name = "Motorized"; value = "Motorized";};
                    class MotorizedMTP {name = "Motorized MTP"; value = "Motorized_MTP";};
                    class Mechanized {name = "Mechanized"; value = "Mechanized";};
                    class MechanizedMTP {name = "Mechanized MTP"; value = "Mechanized_MTP";};
                    class Armored {name = "Armored"; value = "Armored";};
                    class Air {name = "Air"; value = "Air";};
                    class Naval {name = "Naval"; value = "Naval";};
                    class Support {name = "Support"; value = "Support";};
                    class Artillery {name = "Artillery"; value = "Artillery";};
                };
            };
            class ModuleDescription : ModuleDescription {};
        };
        class ModuleDescription : ModuleDescription {
            description[] = {
                "Assign synced template groups to an ALiVE force category.",
                "",
                "Sync this module to a compiler module, then sync one unit from each template group to this helper."
            };
            sync[] = {"ALiVE_sys_factioncompiler"};
            class ALiVE_sys_factioncompiler {
                description[] = {"Compiler module."};
                position = 0;
                direction = 0;
                optional = 0;
                duplicate = 0;
            };
        };
    };
};

