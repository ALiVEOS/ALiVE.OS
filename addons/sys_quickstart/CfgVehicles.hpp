class CfgVehicles {

    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; };
        class ModuleDescription;
    };
        class ALiVE: ModuleAliveBase {
                author = MODULE_AUTHOR;
                scope = 1;
                displayName = "ALiVE Quick Start";
                icon = "x\alive\addons\sys_quickstart\icon_sys_quickstart.paa";
                picture = "x\alive\addons\sys_quickstart\icon_sys_quickstart.paa";
                functionPriority = 20;
                function = "ALiVE_fnc_quickstartInit";
            class Attributes : AttributesBase
            {
                class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_quickstart_HDR_GENERAL"; displayName = "GENERAL"; };
                class debug : Combo { property = "ALiVE_sys_quickstart_debug"; displayName = "$STR_ALIVE_DEBUG"; tooltip = "$STR_ALIVE_DEBUG_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                class ALiVE_Versioning : Combo
                {
                        property = "ALiVE_sys_quickstart_ALiVE_Versioning";
                        displayName = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING";
                        tooltip = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING_COMMENT";
                        defaultValue = """warning""";
                        class Values
                        {
                            class warning { name = "Warn players"; value = warning; default = 1; };
                            class kick { name = "Kick players"; value = kick; };
                        };
                };
                class ALiVE_DISABLESAVE : Combo { property = "ALiVE_sys_quickstart_ALiVE_DISABLESAVE"; displayName = "$STR_ALIVE_DISABLESAVE"; tooltip = "$STR_ALIVE_DISABLESAVE_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
                class AISKILL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_quickstart_AISKILL"; displayName = "AI SKILL LEVELS"; };
                class skillFactionsRecruit : Edit { property = "ALiVE_sys_quickstart_skillFactionsRecruit"; displayName = "$STR_ALIVE_AISKILL_RECRUIT"; tooltip = "$STR_ALIVE_AISKILL_RECRUIT_COMMENT"; defaultValue = """CIV_F"""; };
                class skillFactionsRegular : Edit { property = "ALiVE_sys_quickstart_skillFactionsRegular"; displayName = "$STR_ALIVE_AISKILL_REGULAR"; tooltip = "$STR_ALIVE_AISKILL_REGULAR_COMMENT"; defaultValue = """IND_F,IND_G_F,BLU_G_F,OPF_G_F"""; };
                class skillFactionsVeteran : Edit { property = "ALiVE_sys_quickstart_skillFactionsVeteran"; displayName = "$STR_ALIVE_AISKILL_VETERAN"; tooltip = "$STR_ALIVE_AISKILL_VETERAN_COMMENT"; defaultValue = """BLU_F,OPF_F"""; };
                class skillFactionsExpert : Edit { property = "ALiVE_sys_quickstart_skillFactionsExpert"; displayName = "$STR_ALIVE_AISKILL_EXPERT"; tooltip = "$STR_ALIVE_AISKILL_EXPERT_COMMENT"; defaultValue = """"""; };
                class CIVILIANS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_quickstart_CIVILIANS"; displayName = "CIVILIAN HOSTILITY"; };
                class hostilityWest : Combo
                {
                        property = "ALiVE_sys_quickstart_hostilityWest"; displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST"; tooltip = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_COMMENT"; defaultValue = """0""";
                        class Values { class LOW{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_LOW";value="0";}; class MEDIUM{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_MEDIUM";value="1";}; class HIGH{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_HIGH";value="2";}; class EXTREME{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_EXTREME";value="3";}; };
                };
                class hostilityEast : Combo
                {
                        property = "ALiVE_sys_quickstart_hostilityEast"; displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST"; tooltip = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_COMMENT"; defaultValue = """0""";
                        class Values { class LOW{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_LOW";value="0";}; class MEDIUM{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_MEDIUM";value="1";}; class HIGH{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_HIGH";value="2";}; class EXTREME{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_EXTREME";value="3";}; };
                };
                class hostilityIndep : Combo
                {
                        property = "ALiVE_sys_quickstart_hostilityIndep"; displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP"; tooltip = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_COMMENT"; defaultValue = """0""";
                        class Values { class LOW{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_LOW";value="0";}; class MEDIUM{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_MEDIUM";value="1";}; class HIGH{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_HIGH";value="2";}; class EXTREME{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_EXTREME";value="3";}; };
                };

                class HDR_CIV_AREA : ALiVE_ModuleSubTitle { property = "ALiVE_sys_quickstart_HDR_CIV_AREA"; displayName = "CIVILIAN AREA"; };
                class taor : Edit { property = "ALiVE_sys_quickstart_taor"; displayName = "$STR_ALIVE_AMBCP_TAOR"; tooltip = "$STR_ALIVE_AMBCP_TAOR_COMMENT"; defaultValue = """"""; };
                class blacklist : Edit { property = "ALiVE_sys_quickstart_blacklist"; displayName = "$STR_ALIVE_AMBCP_BLACKLIST"; tooltip = "$STR_ALIVE_AMBCP_BLACKLIST_COMMENT"; defaultValue = """"""; };
                class sizeFilter : Combo
                {
                        property = "ALiVE_sys_quickstart_sizeFilter"; displayName = "$STR_ALIVE_AMBCP_SIZE_FILTER"; tooltip = "$STR_ALIVE_AMBCP_SIZE_FILTER_COMMENT"; defaultValue = """250""";
                        class Values { class NONE{name="$STR_ALIVE_AMBCP_SIZE_FILTER_NONE";value="160";}; class SMALL{name="$STR_ALIVE_AMBCP_SIZE_FILTER_SMALL";value="250";default=1;}; class MEDIUM{name="$STR_ALIVE_AMBCP_SIZE_FILTER_MEDIUM";value="400";}; class LARGE{name="$STR_ALIVE_AMBCP_SIZE_FILTER_LARGE";value="700";}; };
                };
                class priorityFilter : Combo
                {
                        property = "ALiVE_sys_quickstart_priorityFilter"; displayName = "$STR_ALIVE_AMBCP_PRIORITY_FILTER"; tooltip = "$STR_ALIVE_AMBCP_PRIORITY_FILTER_COMMENT"; defaultValue = """0""";
                        class Values { class NONE{name="$STR_ALIVE_AMBCP_PRIORITY_FILTER_NONE";value="0";}; class LOW{name="$STR_ALIVE_AMBCP_PRIORITY_FILTER_LOW";value="10";}; class MEDIUM{name="$STR_ALIVE_AMBCP_PRIORITY_FILTER_MEDIUM";value="30";}; class HIGH{name="$STR_ALIVE_AMBCP_PRIORITY_FILTER_HIGH";value="40";}; };
                };

                class HDR_CIV_POP : ALiVE_ModuleSubTitle { property = "ALiVE_sys_quickstart_HDR_CIV_POP"; displayName = "CIVILIAN POPULATION"; };
                // Shared ALiVE_FactionChoice dropdown - see addons/main/CfgVehicles.hpp.
                class faction
                {
                        property     = "ALiVE_sys_quickstart_faction";
                        displayName  = "$STR_ALIVE_AMBCP_FACTION";
                        tooltip      = "$STR_ALIVE_AMBCP_FACTION_COMMENT";
                        control      = "ALiVE_FactionChoice_Civilian";
                        typeName     = "STRING";
                        expression   = "_this setVariable ['faction', _value];";
                        defaultValue = """CIV_F""";
                };
                class placementMultiplier : Combo
                {
                        property = "ALiVE_sys_quickstart_placementMultiplier"; displayName = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER"; tooltip = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_COMMENT"; defaultValue = """0.5""";
                        class Values { class LOW{name="$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_LOW";value="0.5";}; class MEDIUM{name="$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_MEDIUM";value="1";}; class HIGH{name="$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_HIGH";value="1.5";}; class EXTREME{name="$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_EXTREME";value="2";}; };
                };
                class ambientVehicleAmount : Combo
                {
                        property = "ALiVE_sys_quickstart_ambientVehicleAmount"; displayName = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT"; tooltip = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_COMMENT"; defaultValue = """0.2""";
                        class Values { class NONE{name="$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_NONE";value="0";}; class LOW{name="$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_LOW";value="0.2";default=1;}; class MEDIUM{name="$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_MEDIUM";value="0.6";}; class HIGH{name="$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_HIGH";value="1";}; };
                };
                class ambientVehicleFaction : Edit { property = "ALiVE_sys_quickstart_ambientVehicleFaction"; displayName = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_FACTION"; tooltip = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_FACTION_COMMENT"; defaultValue = """CIV_F"""; };
                class ModuleDescription : ModuleDescription {};
            };
        };

};
