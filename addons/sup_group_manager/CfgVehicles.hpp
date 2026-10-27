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
                icon = "x\alive\addons\sup_group_manager\icon_sup_recruit.paa";
                picture = "x\alive\addons\sup_group_manager\icon_sup_recruit.paa";
                author = MODULE_AUTHOR;
                class Attributes : AttributesBase
                {
                        class HDR_UNITS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_recruit_HDR_UNITS"; displayName = "UNITS"; };
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
                        class HDR_VEHICLES : ALiVE_ModuleSubTitle { property = "ALiVE_sup_recruit_HDR_VEHICLES"; displayName = "VEHICLES"; };
                        class vehicleClasses : Edit
                        {
                                property = "ALiVE_sup_recruit_vehicleClasses";
                                displayName = "$STR_ALIVE_RECRUIT_VEHICLES";
                                tooltip = "$STR_ALIVE_RECRUIT_VEHICLES_COMMENT";
                                defaultValue = """""";
                        };
                        class maxVehicles : Edit
                        {
                                property = "ALiVE_sup_recruit_maxVehicles";
                                displayName = "$STR_ALIVE_RECRUIT_MAX_VEHICLES";
                                tooltip = "$STR_ALIVE_RECRUIT_MAX_VEHICLES_COMMENT";
                                defaultValue = """2""";
                                typeName = "NUMBER";
                        };
                        class HDR_SPAWNING : ALiVE_ModuleSubTitle { property = "ALiVE_sup_recruit_HDR_SPAWNING"; displayName = "SPAWNING"; };
                        class spawnPoints : Edit
                        {
                                property = "ALiVE_sup_recruit_spawnPoints";
                                displayName = "$STR_ALIVE_RECRUIT_SPAWN_POINTS";
                                tooltip = "$STR_ALIVE_RECRUIT_SPAWN_POINTS_COMMENT";
                                defaultValue = """""";
                        };
                        class spawnHeight : Edit
                        {
                                property = "ALiVE_sup_recruit_spawnHeight";
                                displayName = "$STR_ALIVE_RECRUIT_SPAWN_HEIGHT";
                                tooltip = "$STR_ALIVE_RECRUIT_SPAWN_HEIGHT_COMMENT";
                                defaultValue = """0""";
                                typeName = "NUMBER";
                        };
                        class HDR_FORCEPOOL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_recruit_HDR_FORCEPOOL"; displayName = "FORCE POOL"; };
                        class unitCost : Edit
                        {
                                property = "ALiVE_sup_recruit_unitCost";
                                displayName = "$STR_ALIVE_RECRUIT_UNIT_COST";
                                tooltip = "$STR_ALIVE_RECRUIT_UNIT_COST_COMMENT";
                                defaultValue = """0""";
                                typeName = "NUMBER";
                        };
                        class vehicleCost : Edit
                        {
                                property = "ALiVE_sup_recruit_vehicleCost";
                                displayName = "$STR_ALIVE_RECRUIT_VEHICLE_COST";
                                tooltip = "$STR_ALIVE_RECRUIT_VEHICLE_COST_COMMENT";
                                defaultValue = """0""";
                                typeName = "NUMBER";
                        };
                        class costOverrides : Edit
                        {
                                property = "ALiVE_sup_recruit_costOverrides";
                                displayName = "$STR_ALIVE_RECRUIT_COST_CLASSES";
                                tooltip = "$STR_ALIVE_RECRUIT_COST_CLASSES_COMMENT";
                                defaultValue = """""";
                        };
                        class HDR_OPTIONS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_recruit_HDR_OPTIONS"; displayName = "OPTIONS"; };
                        class recruitCode : Edit
                        {
                                property = "ALiVE_sup_recruit_recruitCode";
                                displayName = "$STR_ALIVE_RECRUIT_CODE";
                                tooltip = "$STR_ALIVE_RECRUIT_CODE_COMMENT";
                                control = "EditCodeMulti5";
                                defaultValue = """""";
                        };
                        class recruitInterface : Combo
                        {
                                property = "ALiVE_sup_recruit_recruitInterface";
                                displayName = "$STR_ALIVE_RECRUIT_INTERFACE";
                                tooltip = "$STR_ALIVE_RECRUIT_INTERFACE_COMMENT";
                                defaultValue = """window""";
                                class Values
                                {
                                        class Window  { name = "$STR_ALIVE_RECRUIT_INTERFACE_WINDOW";  value = "window"; };
                                        class Actions { name = "$STR_ALIVE_RECRUIT_INTERFACE_ACTIONS"; value = "actions"; };
                                };
                        };
                        class allowDismiss : Combo
                        {
                                property = "ALiVE_sup_recruit_allowDismiss";
                                displayName = "$STR_ALIVE_RECRUIT_DISMISS";
                                tooltip = "$STR_ALIVE_RECRUIT_DISMISS_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                        class Yes { name = "Yes"; value = "true"; };
                                        class Base { name = "$STR_ALIVE_RECRUIT_DISMISS_BASE"; value = "base"; };
                                        class No  { name = "No";  value = "false"; };
                                };
                        };
                        class syncedTemplates : Combo
                        {
                                property = "ALiVE_sup_recruit_syncedTemplates";
                                displayName = "$STR_ALIVE_RECRUIT_SYNCED";
                                tooltip = "$STR_ALIVE_RECRUIT_SYNCED_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                        class No  { name = "No";  value = "false"; };
                                        class Yes { name = "Yes"; value = "true"; };
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
        // Rally Points: sync to objects; players (and a leader's AI) travel between them.
        class ALiVE_sup_rally : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_RALLY";
                function = "ALIVE_fnc_rallyInit";
                functionPriority = 154;
                isGlobal = 2;
                icon = "x\alive\addons\sup_group_manager\icon_sup_rally.paa";
                picture = "x\alive\addons\sup_group_manager\icon_sup_rally.paa";
                author = MODULE_AUTHOR;
                class Attributes : AttributesBase
                {
                        class HDR_POINTS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_rally_HDR_POINTS"; displayName = "RALLY POINTS"; };
                        class rallyClasses : Edit
                        {
                                property = "ALiVE_sup_rally_rallyClasses";
                                displayName = "$STR_ALIVE_RALLY_CLASSES";
                                tooltip = "$STR_ALIVE_RALLY_CLASSES_COMMENT";
                                defaultValue = """""";
                        };
                        class rallyFOBs : Combo
                        {
                                property = "ALiVE_sup_rally_rallyFOBs";
                                displayName = "$STR_ALIVE_RALLY_FOBS";
                                tooltip = "$STR_ALIVE_RALLY_FOBS_COMMENT";
                                defaultValue = """2""";
                                class Values
                                {
                                        class Off { name = "Off"; value = "0"; };
                                        class T1  { name = "From tier 1 (as soon as it's deployed)"; value = "1"; };
                                        class T2  { name = "From tier 2"; value = "2"; };
                                        class T3  { name = "From tier 3"; value = "3"; };
                                };
                        };
                        class rallyHQs : Combo
                        {
                                property = "ALiVE_sup_rally_rallyHQs";
                                displayName = "$STR_ALIVE_RALLY_HQS";
                                tooltip = "$STR_ALIVE_RALLY_HQS_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                        class Yes { name = "Yes"; value = "true"; };
                                        class No  { name = "No";  value = "false"; };
                                };
                        };
                        class rallySide : Combo
                        {
                                property = "ALiVE_sup_rally_rallySide";
                                displayName = "$STR_ALIVE_RALLY_SIDE";
                                tooltip = "$STR_ALIVE_RALLY_SIDE_COMMENT";
                                defaultValue = """ANY""";
                                class Values
                                {
                                        class Any    { name = "Any side"; value = "ANY"; };
                                        class Blufor { name = "BLUFOR"; value = "WEST"; };
                                        class Opfor  { name = "OPFOR"; value = "EAST"; };
                                        class Indfor { name = "Independent"; value = "GUER"; };
                                };
                        };
                        // placed rally points can be overrun too (A. Ares on Discord, 27 Oct)
                        class pointOverrun : Edit
                        {
                                property = "ALiVE_sup_rally_pointOverrun";
                                displayName = "$STR_ALIVE_RALLY_POINTOVERRUN";
                                tooltip = "$STR_ALIVE_RALLY_POINTOVERRUN_COMMENT";
                                typeName = "NUMBER";
                                defaultValue = "0";
                        };
                        class HDR_TRAVEL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_rally_HDR_TRAVEL"; displayName = "TRAVEL RULES"; };
                        class squadRadius : Edit
                        {
                                property = "ALiVE_sup_rally_squadRadius";
                                displayName = "$STR_ALIVE_RALLY_SQUAD";
                                tooltip = "$STR_ALIVE_RALLY_SQUAD_COMMENT";
                                defaultValue = """150""";
                                typeName = "NUMBER";
                        };
                        class enemyCheck : Combo
                        {
                                property = "ALiVE_sup_rally_enemyCheck";
                                displayName = "$STR_ALIVE_RALLY_ENEMYCHECK";
                                tooltip = "$STR_ALIVE_RALLY_ENEMYCHECK_COMMENT";
                                defaultValue = """BOTH""";
                                class Values
                                {
                                        class Both { name = "Both ends"; value = "BOTH"; };
                                        class Dest { name = "Destination only"; value = "DEST"; };
                                        class Here { name = "Where you are only"; value = "HERE"; };
                                        class Off  { name = "Off"; value = "OFF"; };
                                };
                        };
                        class enemyRadius : Edit
                        {
                                property = "ALiVE_sup_rally_enemyRadius";
                                displayName = "$STR_ALIVE_RALLY_ENEMY";
                                tooltip = "$STR_ALIVE_RALLY_ENEMY_COMMENT";
                                defaultValue = """100""";
                                typeName = "NUMBER";
                        };
                        class cooldown : Edit
                        {
                                property = "ALiVE_sup_rally_cooldown";
                                displayName = "$STR_ALIVE_RALLY_COOLDOWN";
                                tooltip = "$STR_ALIVE_RALLY_COOLDOWN_COMMENT";
                                defaultValue = """60""";
                                typeName = "NUMBER";
                        };
                        class HDR_LEADER : ALiVE_ModuleSubTitle { property = "ALiVE_sup_rally_HDR_LEADER"; displayName = "LEADER RALLY POINTS"; };
                        class leaderRally : Combo
                    {
                            property = "ALiVE_sup_rally_leaderRally";
                            displayName = "$STR_ALIVE_RALLY_LEADER";
                            tooltip = "$STR_ALIVE_RALLY_LEADER_COMMENT";
                            defaultValue = """OFF""";
                            class Values
                            {
                                    class Off   { name = "Off"; value = "OFF"; };
                                    class Group { name = "$STR_ALIVE_RALLY_LEADER_GROUP"; value = "GROUP"; };
                                    class Side  { name = "$STR_ALIVE_RALLY_LEADER_SIDE"; value = "SIDE"; };
                            };
                    };
                    class leaderCooldown : Edit
                    {
                            property = "ALiVE_sup_rally_leaderCooldown";
                            displayName = "$STR_ALIVE_RALLY_LEADERCD";
                            tooltip = "$STR_ALIVE_RALLY_LEADERCD_COMMENT";
                            typeName = "NUMBER";
                            defaultValue = "120";
                    };
                    class leaderOverrun : Edit
                    {
                            property = "ALiVE_sup_rally_leaderOverrun";
                            displayName = "$STR_ALIVE_RALLY_LEADEROVERRUN";
                            tooltip = "$STR_ALIVE_RALLY_LEADEROVERRUN_COMMENT";
                            typeName = "NUMBER";
                            defaultValue = "30";
                    };
                    class leaderRallyClass : Edit
                    {
                            property = "ALiVE_sup_rally_leaderRallyClass";
                            displayName = "$STR_ALIVE_RALLY_LEADERCLASS";
                            tooltip = "$STR_ALIVE_RALLY_LEADERCLASS_COMMENT";
                            typeName = "STRING";
                            defaultValue = """""";
                    };
                    class HDR_DISPLAY : ALiVE_ModuleSubTitle { property = "ALiVE_sup_rally_HDR_DISPLAY"; displayName = "DISPLAY"; };
                    class rallyMarkers : Combo
                        {
                                property = "ALiVE_sup_rally_rallyMarkers";
                                displayName = "$STR_ALIVE_RALLY_MARKERS";
                                tooltip = "$STR_ALIVE_RALLY_MARKERS_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                        class Yes { name = "Yes"; value = "true"; };
                                        class No  { name = "No";  value = "false"; };
                                };
                        };
                        class rallyInterface : Combo
                        {
                                property = "ALiVE_sup_rally_rallyInterface";
                                displayName = "$STR_ALIVE_RALLY_INTERFACE";
                                tooltip = "$STR_ALIVE_RALLY_INTERFACE_COMMENT";
                                defaultValue = """AUTO""";
                                class Values
                                {
                                        class Auto   { name = "Auto"; value = "AUTO"; };
                                        class Scroll { name = "Scroll wheel"; value = "SCROLL"; };
                                        class Ace    { name = "ACE interaction menu"; value = "ACE"; };
                                        class Both   { name = "Both"; value = "BOTH"; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_RALLY_COMMENT"};
                        sync[] = {"AnyStaticObject", "AnyVehicle"};
                };
        };
};
