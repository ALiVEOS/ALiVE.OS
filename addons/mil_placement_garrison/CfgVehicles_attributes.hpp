// The module's settings, included twice by CfgVehicles.hpp: once for ALiVE_mil_placement_garrison
// and once for the hidden old class ALiVE_mil_placement_spe. ATTR_PREFIX gives the property names
// ("<prefix>_faction" and so on); missions saved with the old class carry the old names, so the old
// class keeps them. The attribute class names (faction, speInfantryClass, ...) are the variable
// names fnc_SPEMP.sqf reads, so both classes keep those as they are.
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = QUOTE(DOUBLES(ATTR_PREFIX,HDR_GENERAL)); displayName = "GENERAL"; };

                        class debug : Combo
                        {
                                property = QUOTE(DOUBLES(ATTR_PREFIX,debug));
                                displayName = "$STR_ALIVE_SPEMP_DEBUG";
                                tooltip = "$STR_ALIVE_SPEMP_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        // Shared ALiVE_FactionChoice dropdown - see addons/main/CfgVehicles.hpp.
                        // Defaults to BLU_F.
                        class faction
                        {
                                property     = QUOTE(DOUBLES(ATTR_PREFIX,faction));
                                displayName  = "$STR_ALIVE_SPEMP_FACTION";
                                tooltip      = "$STR_ALIVE_SPEMP_FACTION_COMMENT";
                                control      = "ALiVE_FactionChoice_Military";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['faction', _value];";
                                defaultValue = """BLU_F""";
                        };
                        class priority : Edit { property = QUOTE(DOUBLES(ATTR_PREFIX,priority)); displayName = "$STR_ALIVE_SPEMP_PRIORITY"; tooltip = "$STR_ALIVE_SPEMP_PRIORITY_COMMENT"; defaultValue = """50"""; };
                        class size : Edit { property = QUOTE(DOUBLES(ATTR_PREFIX,size)); displayName = "$STR_ALIVE_SPEMP_SIZE"; tooltip = "$STR_ALIVE_SPEMP_SIZE_COMMENT"; defaultValue = """50"""; };

                        class HDR_UNITS : ALiVE_ModuleSubTitle { property = QUOTE(DOUBLES(ATTR_PREFIX,HDR_UNITS)); displayName = "SPAWNED UNITS"; };
                        class speInfantryClass : Edit { property = QUOTE(DOUBLES(ATTR_PREFIX,speInfantryClass)); displayName = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_CLASS"; tooltip = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_CLASS_COMMENT"; defaultValue = """"""; };
                        class speInfantryBehaviour : Combo
                        {
                                property = QUOTE(DOUBLES(ATTR_PREFIX,speInfantryBehaviour));
                                displayName = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_BEHAVIOUR";
                                tooltip = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_BEHAVIOUR_COMMENT";
                                defaultValue = """AWARE""";
                                class Values
                                {
                                    class AWARE { name = "Aware"; value = "AWARE"; default = 1; };
                                    class COMBAT { name = "Combat"; value = "COMBAT"; };
                                    class STEALTH { name = "Stealth"; value = "STEALTH"; };
                                    class SAFE { name = "Safe"; value = "SAFE"; };
                                    class CARELESS { name = "Careless"; value = "CARELESS"; };
                                };
                        };
                        class speVehicleClass : Edit { property = QUOTE(DOUBLES(ATTR_PREFIX,speVehicleClass)); displayName = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_CLASS"; tooltip = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_CLASS_COMMENT"; defaultValue = """"""; };
                        class speVehicleEmpty : Combo
                        {
                                property = QUOTE(DOUBLES(ATTR_PREFIX,speVehicleEmpty));
                                displayName = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_EMPTY";
                                tooltip = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_EMPTY_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        // Hidden: the AI commander leaves a Garrison Obj. alone, so its objective never
                        // gets an owner and player tasks never reach it, whatever this says. Kept, not
                        // removed, so a mission's saved choice still loads.
                        class allowPlayerTasking
                        {
                                property = QUOTE(DOUBLES(ATTR_PREFIX,allowPlayerTasking));
                                displayName = "";
                                control = "ALiVE_HiddenAttribute";
                                typeName = "STRING";
                                expression = "_this setVariable ['allowPlayerTasking', _value];";
                                defaultValue = """true""";
                        };
                        // ---- On Spawn Hook --------------------------------------------------
                        class HDR_HOOK : ALiVE_ModuleSubTitle { property = QUOTE(DOUBLES(ATTR_PREFIX,HDR_HOOK)); displayName = "ON SPAWN HOOK"; };
                        class onEachSpawn : ALiVE_EditMultilineSQF
                        {
                                property = QUOTE(DOUBLES(ATTR_PREFIX,onEachSpawn));
                                displayName = "$STR_ALIVE_MP_ON_EACH_SPAWN";
                                tooltip = "$STR_ALIVE_MP_ON_EACH_SPAWN_COMMENT";
                                defaultValue = """""";
                        };
                        class onEachSpawnOnce : Combo
                        {
                                property = QUOTE(DOUBLES(ATTR_PREFIX,onEachSpawnOnce));
                                displayName = "$STR_ALIVE_MP_ON_EACH_SPAWN_ONCE";
                                tooltip = "$STR_ALIVE_MP_ON_EACH_SPAWN_ONCE_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
