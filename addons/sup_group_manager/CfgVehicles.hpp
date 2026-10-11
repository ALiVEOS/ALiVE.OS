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
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_GM";
                function = "ALIVE_fnc_emptyInit";
                functionPriority = 152;
                isGlobal = 2;
                icon = "x\alive\addons\sup_group_manager\icon_sup_group_manager.paa";
                picture = "x\alive\addons\sup_group_manager\icon_sup_group_manager.paa";
                author = MODULE_AUTHOR;
        };
        // Recruitment (#977): sync to objects; players recruit AI into their own group there.
        class ALiVE_sup_recruit : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_RECRUIT";
                function = "ALIVE_fnc_recruitInit";
                functionPriority = 153;
                isGlobal = 2;
                icon = "x\alive\addons\sup_group_manager\icon_sup_group_manager.paa";
                picture = "x\alive\addons\sup_group_manager\icon_sup_group_manager.paa";
                author = MODULE_AUTHOR;
                class Attributes : AttributesBase
                {
                        class unitClasses : Edit
                        {
                                property = "ALiVE_sup_recruit_unitClasses";
                                displayName = "$STR_ALIVE_RECRUIT_CLASSES";
                                tooltip = "$STR_ALIVE_RECRUIT_CLASSES_COMMENT";
                                defaultValue = """""";
                        };
                        class maxGroupSize : Edit
                        {
                                property = "ALiVE_sup_recruit_maxGroupSize";
                                displayName = "$STR_ALIVE_RECRUIT_MAX";
                                tooltip = "$STR_ALIVE_RECRUIT_MAX_COMMENT";
                                defaultValue = """8""";
                                typeName = "NUMBER";
                        };
                        class recruitSkill : Combo
                        {
                                property = "ALiVE_sup_recruit_recruitSkill";
                                displayName = "$STR_ALIVE_RECRUIT_SKILL";
                                tooltip = "$STR_ALIVE_RECRUIT_SKILL_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                        class Default { name = "Game default"; value = "0"; };
                                        class Low     { name = "Low (0.3)";    value = "0.3"; };
                                        class Medium  { name = "Medium (0.5)"; value = "0.5"; };
                                        class High    { name = "High (0.7)";   value = "0.7"; };
                                        class Elite   { name = "Elite (1.0)";  value = "1"; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_RECRUIT_COMMENT"};
                        sync[] = {"AnyStaticObject", "AnyVehicle", "AnyPerson"};
                };
        };
};
