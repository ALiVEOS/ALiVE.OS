class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; class ALiVE_EditMultilineSQF; };
        class ModuleDescription;
    };
        // Military Placement (Garrison Obj.). This addon keeps its folder, CfgPatches name and function
        // names from when the module was built for Spearhead; only the module class was renamed.
        class ALiVE_mil_placement_garrison : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_SPEMP";
                function = "ALIVE_fnc_SPEMPInit";
                author = MODULE_AUTHOR;
                functionPriority = 100;
                isGlobal = 1;
                icon = "x\alive\addons\mil_placement_spe\icon_mil_SPEMP.paa";
                picture = "x\alive\addons\mil_placement_spe\icon_mil_SPEMP.paa";
                class Attributes : AttributesBase
                {
#define ATTR_PREFIX ALiVE_mil_placement_garrison
#include "CfgVehicles_attributes.hpp"
#undef ATTR_PREFIX
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_SPEMP_COMMENT","","$STR_ALIVE_SPEMP_USAGE"};
                    // OPCOM / CQB are intentionally NOT valid sync peers. The
                    // module places profile groups / vehicles at a fixed
                    // position (module direction drives orientation); syncing
                    // it to an OPCOM would sweep the units into its pool and
                    // redeploy them, defeating the fixed-position intent.
                    // OPCOM's runtime filter excludes this class explicitly.
                    // sys_factioncompiler IS a valid sync peer - the module
                    // resolves a synced compiler's compiled faction id at
                    // runtime via the case "faction": accessor.
                    sync[] = {"ALiVE_sys_factioncompiler"};
                    class ALiVE_sys_factioncompiler { description[] = {"Custom Faction Compiler module."}; position=0; direction=0; optional=1; duplicate=0; };
                };
        };
        // The module's old class. Hidden from the editor, but missions saved with it still load and
        // run: it has the same settings under their old property names, which is what those missions
        // stored. Code that looks for the module checks both classes.
        class ALiVE_mil_placement_spe : ALiVE_mil_placement_garrison
        {
                scope = 1;
                class Attributes : AttributesBase
                {
#define ATTR_PREFIX ALiVE_mil_placement_spe
#include "CfgVehicles_attributes.hpp"
#undef ATTR_PREFIX
                };
        };
};
