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
                scope = 2;
                displayName = "$STR_ALIVE_PROFILE_SYSTEM";
                function = "ALIVE_fnc_profileSystemInit";
                author = MODULE_AUTHOR;
                functionPriority = 60;
                isGlobal = 2;
                icon = "x\alive\addons\sys_profile\icon_sys_profile.paa";
                picture = "x\alive\addons\sys_profile\icon_sys_profile.paa";
                class Attributes : AttributesBase
                {
                    // ---- General --------------------------------------------------------
                    class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_profile_HDR_GENERAL"; displayName = "GENERAL"; };
                    class debug : Combo { property = "ALiVE_sys_profile_debug"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_DEBUG"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
                    class persistent : Combo { property = "ALiVE_sys_profile_persistent"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_PERSISTENT"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_PERSISTENT_COMMENT"; defaultValue = """false"""; class Values { class No{name="No";value=false;default=1;}; class Yes{name="Yes";value=true;}; }; };
                    class syncronised : Combo
                    {
                            property = "ALiVE_sys_profile_syncronised";
                            displayName = "$STR_ALIVE_PROFILE_SYSTEM_SYNC";
                            tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SYNC_COMMENT";
                            defaultValue = """ADD""";
                            class Values
                            {
                                class Add { name = "$STR_ALIVE_PROFILE_SYSTEM_SYNC_ADD"; value = "ADD"; default = 1; };
                                class Ignore { name = "$STR_ALIVE_PROFILE_SYSTEM_SYNC_IGNORE"; value = "IGNORE"; };
                            };
                    };
                    class activeLimiter : Edit { property = "ALiVE_sys_profile_activeLimiter"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_ACTIVE_LIMITER"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_ACTIVE_LIMITER_COMMENT"; defaultValue = """144"""; };
                    class zeusSpawn : Combo { property = "ALiVE_sys_profile_zeusSpawn"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_ZEUSSPAWN"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_ZEUSSPAWN_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };

                    // ---- Spawn Radii ----------------------------------------------------
                    class HDR_SPAWN : ALiVE_ModuleSubTitle { property = "ALiVE_sys_profile_HDR_SPAWN"; displayName = "SPAWN RADII"; };
                    class spawnRadius : Edit { property = "ALiVE_sys_profile_spawnRadius"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_RADIUS"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_RADIUS_COMMENT"; defaultValue = """1500"""; };
                    class spawnTypeHeliRadius : Edit { property = "ALiVE_sys_profile_spawnTypeHeliRadius"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_HELI_RADIUS"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_HELI_RADIUS_COMMENT"; defaultValue = """1500"""; };
                    class spawnTypeJetRadius : Edit { property = "ALiVE_sys_profile_spawnTypeJetRadius"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_JET_RADIUS"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_JET_RADIUS_COMMENT"; defaultValue = """0"""; };
                    class spawnRadiusUAV : Edit { property = "ALiVE_sys_profile_spawnRadiusUAV"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_UAV_RADIUS"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_UAV_RADIUS_COMMENT"; defaultValue = """-1"""; };
                    class smoothSpawn : Edit { property = "ALiVE_sys_profile_smoothSpawn"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_SMOOTHSPAWN"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SMOOTHSPAWN_COMMENT"; defaultValue = """0.3"""; };
                    class vehicleSpawnSettleSeconds : Combo
                    {
                            property = "ALiVE_sys_profile_vehicleSpawnSettleSeconds";
                            displayName = "$STR_ALIVE_PROFILE_SYSTEM_VEH_SETTLE";
                            tooltip = "$STR_ALIVE_PROFILE_SYSTEM_VEH_SETTLE_COMMENT";
                            defaultValue = """15""";
                            class Values
                            {
                                class FIVE     { name = "$STR_ALIVE_PROFILE_SYSTEM_VEH_SETTLE_5";  value = "5"; };
                                class TEN      { name = "$STR_ALIVE_PROFILE_SYSTEM_VEH_SETTLE_10"; value = "10"; };
                                class FIFTEEN  { name = "$STR_ALIVE_PROFILE_SYSTEM_VEH_SETTLE_15"; value = "15"; default = 1; };
                                class THIRTY   { name = "$STR_ALIVE_PROFILE_SYSTEM_VEH_SETTLE_30"; value = "30"; };
                            };
                    };

                    // ---- Despawn Linger -------------------------------------------------
                    class HDR_LINGER : ALiVE_ModuleSubTitle { property = "ALiVE_sys_profile_HDR_LINGER"; displayName = "DESPAWN LINGER"; };
                    class playerOccupantGrace : Edit { property = "ALiVE_sys_profile_playerOccupantGrace"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_PLAYER_OCCUPANT_GRACE"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_PLAYER_OCCUPANT_GRACE_COMMENT"; defaultValue = """300"""; };
                    class postDeathGrace : Edit { property = "ALiVE_sys_profile_postDeathGrace"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_POST_DEATH_GRACE"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_POST_DEATH_GRACE_COMMENT"; defaultValue = """120"""; };
                    class postDeathRadius : Edit { property = "ALiVE_sys_profile_postDeathRadius"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_POST_DEATH_RADIUS"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_POST_DEATH_RADIUS_COMMENT"; defaultValue = """500"""; };
                    class midCombatExtension : Edit { property = "ALiVE_sys_profile_midCombatExtension"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_MID_COMBAT_EXTENSION"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_MID_COMBAT_EXTENSION_COMMENT"; defaultValue = """60"""; };

                    // ---- Virtual Combat -------------------------------------------------
                    class HDR_VCOMBAT : ALiVE_ModuleSubTitle { property = "ALiVE_sys_profile_HDR_VCOMBAT"; displayName = "VIRTUAL COMBAT"; };
                    class speedModifier : Combo
                    {
                            property = "ALiVE_sys_profile_speedModifier";
                            displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPEED_MODIFIER";
                            tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SPEED_MODIFIER_COMMENT";
                            defaultValue = """1.00""";
                            class Values
                            {
                                class Insane { name = "Fastest (2.00)"; value = "2.00"; };
                                class Crazy { name = "Faster (1.75)"; value = "1.75"; };
                                class Extremer { name = "Fast (1.50)"; value = "1.75"; };
                                class Extreme { name = "Quick (1.25)"; value = "1.25"; };
                                class None { name = "Regular (1.00)"; value = "1.00"; default = 1; };
                                class High { name = "Slow (0.75)"; value = "0.75"; };
                                class Medium { name = "Slower (0.50)"; value = "0.50"; };
                                class Low { name = "Slowest (0.25)"; value = "0.25"; };
                            };
                    };
                    class virtualcombat_speedmodifier : Combo
                    {
                            property = "ALiVE_sys_profile_virtualcombat_speedmodifier";
                            displayName = "$STR_ALIVE_PROFILE_SYSTEM_VIRTUAL_COMBAT_SPEED_MODIFIER";
                            tooltip = "$STR_ALIVE_PROFILE_SYSTEM_VIRTUAL_COMBAT_SPEED_MODIFIER_COMMENT";
                            defaultValue = """""";
                            class Values
                            {
                                class Fastest { name = "Fastest (1.75)"; Value = 1.75; };
                                class Faster { name = "Faster (1.50)"; Value = 1.50; };
                                class Fast { name = "Fast (1.25)"; Value = 1.25; };
                                class Quick { name = "Quick (1.00)"; Value = 1.00; };
                                class Regular { name = "Regular (0.75)"; Value = 0.75; default = 1; };
                                class Slow { name = "Slow (0.50)"; Value = 0.50; };
                                class Slower { name = "Slower (0.35)"; Value = 0.35; };
                                class Slowest { name = "Slowest (0.10)"; Value = 0.10; };
                            };
                    };
                    class virtualcombat_rangemodifier : Edit { property = "ALiVE_sys_profile_virtualcombat_rangemodifier"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_VIRTUAL_COMBAT_RANGE_MODIFIER"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_VIRTUAL_COMBAT_RANGE_MODIFIER_COMMENT"; defaultValue = """255"""; };

                    // ---- Pathfinding ----------------------------------------------------
                    class HDR_PATH : ALiVE_ModuleSubTitle { property = "ALiVE_sys_profile_HDR_PATH"; displayName = "PATHFINDING"; };
                    class pathfinding : Combo { property = "ALiVE_sys_profile_pathfinding"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_COMMENT"; defaultValue = """false"""; class Values { class No{name="No";value=false;default=1;}; class Yes{name="Yes";value=true;}; }; };
                    class pathfindingSize : Combo
                    {
                            property = "ALiVE_sys_profile_pathfindingSize";
                            displayName = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_GRID";
                            tooltip = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_GRID_COMMENT";
                            defaultValue = """[600,75]""";
                            class Values
                            {
                                class SmallHighRes { name = "10km - High - (200 x 40)"; value = [200,40]; };
                                class SmallMedRes { name = "10km - Med - (250 x 50)"; value = [250,50]; };
                                class SmallLowRes { name = "10km - Low - (300 x 60)"; value = [300,60]; };
                                class MedHighRes { name = "20km - High - (400 x 50)"; value = [400,50]; };
                                class MedMedRes { name = "20km - Med - (480 x 60)"; value = [480,60]; };
                                class MedLowRes { name = "20km - Low - (600 x 75)"; value = [600,75]; default = 1; };
                                class HighHighRes { name = "30km - High - (640 x 80)"; value = [640,80]; };
                                class HighMedRes { name = "30km - Med - 720 x 90)"; value = [720,90]; };
                                class HighLowRes { name = "30km - Low - (800 x 100)"; value = [800,100]; };
                                class UltraHighHighRes { name = "40km - High - (800 x 100)"; value = [800,100]; };
                                class UltraHighMedRes { name = "40km - Med - (1000 x 125)"; value = [1000,125]; };
                                class UltraHighLowRes { name = "40km - Low - (1200 x 150)"; value = [1200,150]; };
                            };
                    };
                    class seaTransport : Combo { property = "ALiVE_sys_profile_seaTransport"; displayName = "$STR_ALIVE_PROFILE_SYSTEM_SEATRANSPORT"; tooltip = "$STR_ALIVE_PROFILE_SYSTEM_SEATRANSPORT_COMMENT"; defaultValue = """false"""; class Values { class No{name="No";value=false;default=1;}; class Yes{name="Yes";value=true;}; }; };

                    class ModuleDescription : ModuleDescription {};
                };
        };
};
