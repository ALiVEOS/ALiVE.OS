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
        displayName = "$STR_ALIVE_CIV_POP";
        function = "ALIVE_fnc_civilianPopulationSystemInit";
        author = MODULE_AUTHOR;
        functionPriority = 70;
        isGlobal = 2;
        icon = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
        picture = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
        class Attributes : AttributesBase
        {
            // ---- General --------------------------------------------------------
            class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_GENERAL"; displayName = "GENERAL"; };
            class debug : Combo { property = "ALiVE_amb_civ_population_debug"; displayName = "$STR_ALIVE_CIV_POP_DEBUG"; tooltip = "$STR_ALIVE_CIV_POP_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
            class spawnRadius : Edit { property = "ALiVE_amb_civ_population_spawnRadius"; displayName = "$STR_ALIVE_CIV_POP_SPAWN_RADIUS"; tooltip = "$STR_ALIVE_CIV_POP_SPAWN_RADIUS_COMMENT"; defaultValue = """1500"""; };
            class spawnTypeHeliRadius : Edit { property = "ALiVE_amb_civ_population_spawnTypeHeliRadius"; displayName = "$STR_ALIVE_CIV_POP_SPAWN_HELI_RADIUS"; tooltip = "$STR_ALIVE_CIV_POP_SPAWN_HELI_RADIUS_COMMENT"; defaultValue = """1500"""; };
            class spawnTypeJetRadius : Edit { property = "ALiVE_amb_civ_population_spawnTypeJetRadius"; displayName = "$STR_ALIVE_CIV_POP_SPAWN_JET_RADIUS"; tooltip = "$STR_ALIVE_CIV_POP_SPAWN_JET_RADIUS_COMMENT"; defaultValue = """0"""; };
            class activeLimiter : Edit { property = "ALiVE_amb_civ_population_activeLimiter"; displayName = "$STR_ALIVE_CIV_POP_ACTIVE_LIMITER"; tooltip = "$STR_ALIVE_CIV_POP_ACTIVE_LIMITER_COMMENT"; defaultValue = """30"""; };

            // ---- Hostility ------------------------------------------------------
            class HDR_HOSTILITY : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_HOSTILITY"; displayName = "CIVILIAN HOSTILITY"; };
            class hostilityWest : Combo { property = "ALiVE_amb_civ_population_hostilityWest"; displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST"; tooltip = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_COMMENT"; defaultValue = """0"""; class Values { class LOW{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_LOW";value="0";default=1;}; class MEDIUM{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_MEDIUM";value="30";}; class HIGH{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_HIGH";value="60";}; class EXTREME{name="$STR_ALIVE_CIV_POP_HOSTILITY_WEST_EXTREME";value="130";}; }; };
            class hostilityEast : Combo { property = "ALiVE_amb_civ_population_hostilityEast"; displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST"; tooltip = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_COMMENT"; defaultValue = """0"""; class Values { class LOW{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_LOW";value="0";default=1;}; class MEDIUM{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_MEDIUM";value="30";}; class HIGH{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_HIGH";value="60";}; class EXTREME{name="$STR_ALIVE_CIV_POP_HOSTILITY_EAST_EXTREME";value="130";}; }; };
            class hostilityIndep : Combo { property = "ALiVE_amb_civ_population_hostilityIndep"; displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP"; tooltip = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_COMMENT"; defaultValue = """0"""; class Values { class LOW{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_LOW";value="0";default=1;}; class MEDIUM{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_MEDIUM";value="30";}; class HIGH{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_HIGH";value="60";}; class EXTREME{name="$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_EXTREME";value="130";}; }; };
            class insurgentFaction
            {
                property     = "ALiVE_amb_civ_population_insurgentFaction";
                displayName  = "$STR_ALIVE_CIV_POP_INSURGENT_FACTION";
                tooltip      = "$STR_ALIVE_CIV_POP_INSURGENT_FACTION_COMMENT";
                control      = "ALiVE_FactionChoiceMulti_Military";
                typeName     = "STRING";
                expression   = "_this setVariable ['insurgentFaction', _value];";
                defaultValue = """[]""";
            };
            class insurgentFactionManual : Edit { property = "ALiVE_amb_civ_population_insurgentFactionManual"; displayName = "$STR_ALIVE_CIV_POP_FACTIONS_MANUAL"; tooltip = "$STR_ALIVE_CIV_POP_FACTIONS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_INSURGENT_FACTION : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_SPACER_INSURGENT_FACTION"; displayName = " "; };

            // ---- Interaction & Crowd --------------------------------------------
            class HDR_CROWD : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_CROWD"; displayName = "INTERACTION & CROWD"; };
            class ambientCivilianRoles : Combo
            {
                    property = "ALiVE_amb_civ_population_ambientCivilianRoles";
                    displayName = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES";
                    tooltip = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_COMMENT";
                    defaultValue = """[]""";
                    class Values
                    {
                        class NONE { name = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_NONE"; value = []; default = 1; };
                        class WESTERN { name = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_WEST"; value = ["major","priest","politician"]; };
                        class EASTERN { name = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_EAST"; value = ["townelder","muezzin","politician"]; };
                    };
            };
            class enableInteraction : Combo { property = "ALiVE_amb_civ_population_enableInteraction"; displayName = "$STR_ALIVE_CIV_POP_ENABLE_INTERACTION"; tooltip = "$STR_ALIVE_CIV_POP_ENABLE_INTERACTION_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
            class civilianInteractionUI : Combo
            {
                property     = "ALiVE_amb_civ_population_civilianInteractionUI";
                displayName  = "$STR_ALIVE_CIV_POP_UI_MODE";
                tooltip      = "$STR_ALIVE_CIV_POP_UI_MODE_COMMENT";
                defaultValue = """AUTO""";
                class Values
                {
                    class AUTO    { name = "$STR_ALIVE_CIV_POP_UI_MODE_AUTO";    value = "AUTO"; default = 1; };
                    class DIALOG  { name = "$STR_ALIVE_CIV_POP_UI_MODE_DIALOG";  value = "DIALOG"; };
                    class CLASSIC { name = "$STR_ALIVE_CIV_POP_UI_MODE_CLASSIC"; value = "CLASSIC"; };
                    class ACE     { name = "$STR_ALIVE_CIV_POP_UI_MODE_ACE";     value = "ACE"; };
                };
            };
            // Property key intentionally retained as `advciv_orderMenuRange` for
            // SQM backward compatibility; attribute scope is broader than advciv
            // (governs the addAction range for every civilian-interaction entry
            // - Interact / Talk to Civilian / advciv quick commands - not just
            // the advciv order menu), hence the relocated section + renamed
            // label. Runtime global stays ALiVE_advciv_orderMenuRange.
            class advciv_orderMenuRange : Edit {
                property = "ALiVE_amb_civ_population_advciv_orderMenuRange";
                displayName = "$STR_ALIVE_CIV_POP_INTERACTION_RANGE";
                tooltip = "$STR_ALIVE_CIV_POP_INTERACTION_RANGE_COMMENT";
                defaultValue = """4""";
            };
            class civIntelGatherChance : Edit {
                property = "ALiVE_amb_civ_population_civIntelGatherChance";
                displayName = "$STR_ALIVE_CIV_POP_INTEL_GATHER_CHANCE";
                tooltip = "$STR_ALIVE_CIV_POP_INTEL_GATHER_CHANCE_COMMENT";
                defaultValue = """30""";
            };
            class civHostilityIndicator : Combo
            {
                property     = "ALiVE_amb_civ_population_civHostilityIndicator";
                displayName  = "$STR_ALIVE_CIV_POP_HOSTILITY_INDICATOR";
                tooltip      = "$STR_ALIVE_CIV_POP_HOSTILITY_INDICATOR_COMMENT";
                defaultValue = """OFF""";
                class Values
                {
                    class OFF         { name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDICATOR_OFF";         value = "OFF"; default = 1; };
                    class DESCRIPTIVE { name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDICATOR_DESCRIPTIVE"; value = "DESCRIPTIVE"; };
                    class NUMERIC     { name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDICATOR_NUMERIC";     value = "NUMERIC"; };
                };
            };
            class civWeaponAimRange : Edit
            {
                property     = "ALiVE_amb_civ_population_civWeaponAimRange";
                displayName  = "$STR_ALIVE_CIV_POP_WEAPON_AIM_RANGE";
                tooltip      = "$STR_ALIVE_CIV_POP_WEAPON_AIM_RANGE_COMMENT";
                defaultValue = """15""";
            };
            class civVehicleStopOnAim : Combo
            {
                property     = "ALiVE_amb_civ_population_civVehicleStopOnAim";
                displayName  = "$STR_ALIVE_CIV_POP_VEHICLE_STOP_ON_AIM";
                tooltip      = "$STR_ALIVE_CIV_POP_VEHICLE_STOP_ON_AIM_COMMENT";
                defaultValue = """true""";
                class Values
                {
                    class Yes { name = "Yes"; value = true; default = 1; };
                    class No  { name = "No";  value = false; };
                };
            };
            class limitInteraction : Edit { property = "ALiVE_amb_civ_population_limitInteraction"; displayName = "$STR_ALIVE_CIV_POP_LIMIT_INTERACTION"; tooltip = "$STR_ALIVE_CIV_POP_LIMIT_INTERACTION_COMMENT"; defaultValue = """"""; };
            class ambientCrowdSpawn : Edit { property = "ALiVE_amb_civ_population_ambientCrowdSpawn"; displayName = "$STR_ALIVE_CIV_POP_CROWD_SPAWN_RADIUS"; tooltip = "$STR_ALIVE_CIV_POP_CROWD_SPAWN_RADIUS_COMMENT"; defaultValue = """0"""; };
            class ambientCrowdDensity : Edit { property = "ALiVE_amb_civ_population_ambientCrowdDensity"; displayName = "$STR_ALIVE_CIV_POP_CROWD_DENSITY"; tooltip = "$STR_ALIVE_CIV_POP_CROWD_DENSITY_COMMENT"; defaultValue = """4"""; };
            class ambientCrowdLimit : Edit { property = "ALiVE_amb_civ_population_ambientCrowdLimit"; displayName = "$STR_ALIVE_CIV_POP_CROWD_ACTIVE_LIMITER"; tooltip = "$STR_ALIVE_CIV_POP_CROWD_ACTIVE_LIMITER_COMMENT"; defaultValue = """50"""; };
            class ambientCrowdFaction
            {
                property     = "ALiVE_amb_civ_population_ambientCrowdFaction";
                displayName  = "$STR_ALIVE_CIV_POP_CROWD_FACTION";
                tooltip      = "$STR_ALIVE_CIV_POP_CROWD_FACTION_COMMENT";
                // Variant control class so Eden persists / restores
                // this selection under setVariable key
                // 'ambientCrowdFaction' rather than 'faction'. No
                // sibling 'faction' attribute on this module today,
                // but the variant guards against future cross-
                // contamination and aligns with the canonical
                // pattern used by amb_civ_placement.ambientVehicleFaction.
                // Per-attribute attributeLoad / attributeSave
                // overrides on the `class X { control = "Y"; }` shape
                // are silently ignored by Eden.
                control      = "ALiVE_FactionChoice_Civilian_AmbientCrowdFaction";
                typeName     = "STRING";
                expression   = "_this setVariable ['ambientCrowdFaction', _value];";
                defaultValue = """CIV_F""";
            };
            class disableAmbientSounds : Combo { property = "ALiVE_amb_civ_population_disableAmbientSounds"; displayName = "$STR_ALIVE_CIV_POP_DISABLE_AMBIENT_SOUNDS"; tooltip = "$STR_ALIVE_CIV_POP_DISABLE_AMBIENT_SOUNDS_COMMENT"; defaultValue = """false"""; class Values { class No { name = "No"; value = false; default = 1; }; class Yes { name = "Yes"; value = true; }; }; };

            // ---- Humanitarian ---------------------------------------------------
            class HDR_HUMANITARIAN : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_HUMANITARIAN"; displayName = "HUMANITARIAN"; };
            class humanitarianHostilityChance : Combo { property = "ALiVE_amb_civ_population_humanitarianHostilityChance"; displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE"; tooltip = "$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE_COMMENT"; defaultValue = """20"""; class Values { class LOW{name="$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE_LOW";value="20";default=1;}; class MEDIUM{name="$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE_MEDIUM";value="40";}; class HIGH{name="$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE_HIGH";value="60";}; class EXTREME{name="$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE_EXTREME";value="80";}; }; };
            class maxAllowAid : Edit { property = "ALiVE_amb_civ_population_maxAllowAid"; displayName = "$STR_ALIVE_CIV_POP_MAX_ALLOWED_AID"; tooltip = "$STR_ALIVE_CIV_POP_MAX_ALLOWED_AID_COMMENT"; defaultValue = """3"""; };
            class customWaterItems
            {
                property     = "ALiVE_amb_civ_population_customWaterItems";
                displayName  = "$STR_ALIVE_CIV_POP_WATER_ITEMS";
                tooltip      = "$STR_ALIVE_CIV_POP_WATER_ITEMS_COMMENT";
                control      = "ALiVE_ItemChoiceMulti_Water";
                typeName     = "STRING";
                expression   = "_this setVariable ['customWaterItems', _value];";
                defaultValue = """[]""";
            };
            class customWaterItemsManual : Edit { property = "ALiVE_amb_civ_population_customWaterItemsManual"; displayName = "$STR_ALIVE_CIV_POP_ITEMS_MANUAL"; tooltip = "$STR_ALIVE_CIV_POP_ITEMS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_CUSTOM_WATER : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_SPACER_CUSTOM_WATER"; displayName = " "; };
            class customHumRatItems
            {
                property     = "ALiVE_amb_civ_population_customHumRatItems";
                displayName  = "$STR_ALIVE_CIV_POP_HUMRAT_ITEMS";
                tooltip      = "$STR_ALIVE_CIV_POP_HUMRAT_ITEMS_COMMENT";
                control      = "ALiVE_ItemChoiceMulti_Ration";
                typeName     = "STRING";
                expression   = "_this setVariable ['customHumRatItems', _value];";
                defaultValue = """[]""";
            };
            class customHumRatItemsManual : Edit { property = "ALiVE_amb_civ_population_customHumRatItemsManual"; displayName = "$STR_ALIVE_CIV_POP_ITEMS_MANUAL"; tooltip = "$STR_ALIVE_CIV_POP_ITEMS_MANUAL_COMMENT"; defaultValue = """"""; typeName = "STRING"; };
            class SPACER_CUSTOM_HUMRAT : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_SPACER_CUSTOM_HUMRAT"; displayName = " "; };

            // ---- Advanced Civilians - General -----------------------------------
            class HDR_ADVCIV : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_ADVCIV"; displayName = "ADVANCED CIVILIANS - GENERAL"; };
            class advciv_enabled : Combo { property = "ALiVE_amb_civ_population_advciv_enabled"; displayName = "$STR_ALIVE_ADVCIV_ENABLED"; tooltip = "$STR_ALIVE_ADVCIV_ENABLED_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
            class advciv_debug : Combo { property = "ALiVE_amb_civ_population_advciv_debug"; displayName = "$STR_ALIVE_ADVCIV_DEBUG"; tooltip = "$STR_ALIVE_ADVCIV_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class No{name="No";value=false;default=1;}; class Yes{name="Yes";value=true;}; }; };
            class advciv_tickRate : Edit { property = "ALiVE_amb_civ_population_advciv_tickRate"; displayName = "$STR_ALIVE_ADVCIV_TICK_RATE"; tooltip = "$STR_ALIVE_ADVCIV_TICK_RATE_COMMENT"; defaultValue = """3"""; };
            class advciv_batchSize : Edit { property = "ALiVE_amb_civ_population_advciv_batchSize"; displayName = "$STR_ALIVE_ADVCIV_BATCH_SIZE"; tooltip = "$STR_ALIVE_ADVCIV_BATCH_SIZE_COMMENT"; defaultValue = """0"""; };

            // ---- Advanced Civilians - Trigger Ranges ----------------------------
            class HDR_ADVCIV_TRIGGERS : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_ADVCIV_TRIGGERS"; displayName = "ADVANCED CIVILIANS - TRIGGER RANGES"; };
            class advciv_unsuppressedRange : Edit { property = "ALiVE_amb_civ_population_advciv_unsuppressedRange"; displayName = "$STR_ALIVE_ADVCIV_UNSUPPRESSED_RANGE"; tooltip = "$STR_ALIVE_ADVCIV_UNSUPPRESSED_RANGE_COMMENT"; defaultValue = """250"""; };
            class advciv_suppressedRange : Edit { property = "ALiVE_amb_civ_population_advciv_suppressedRange"; displayName = "$STR_ALIVE_ADVCIV_SUPPRESSED_RANGE"; tooltip = "$STR_ALIVE_ADVCIV_SUPPRESSED_RANGE_COMMENT"; defaultValue = """50"""; };
            class advciv_explosionRange : Edit { property = "ALiVE_amb_civ_population_advciv_explosionRange"; displayName = "$STR_ALIVE_ADVCIV_EXPLOSION_RANGE"; tooltip = "$STR_ALIVE_ADVCIV_EXPLOSION_RANGE_COMMENT"; defaultValue = """500"""; };

            // ---- Advanced Civilians - Behaviour ---------------------------------
            class HDR_ADVCIV_BEHAV : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_ADVCIV_BEHAV"; displayName = "ADVANCED CIVILIANS - BEHAVIOUR"; };
            class advciv_reactionRadius : Edit { property = "ALiVE_amb_civ_population_advciv_reactionRadius"; displayName = "$STR_ALIVE_ADVCIV_REACTION_RADIUS"; tooltip = "$STR_ALIVE_ADVCIV_REACTION_RADIUS_COMMENT"; defaultValue = """150"""; };
            class advciv_fleeRadius : Edit { property = "ALiVE_amb_civ_population_advciv_fleeRadius"; displayName = "$STR_ALIVE_ADVCIV_FLEE_RADIUS"; tooltip = "$STR_ALIVE_ADVCIV_FLEE_RADIUS_COMMENT"; defaultValue = """120"""; };
            class advciv_homeRadius : Edit { property = "ALiVE_amb_civ_population_advciv_homeRadius"; displayName = "$STR_ALIVE_ADVCIV_HOME_RADIUS"; tooltip = "$STR_ALIVE_ADVCIV_HOME_RADIUS_COMMENT"; defaultValue = """150"""; };
            class advciv_curiosityRange : Edit { property = "ALiVE_amb_civ_population_advciv_curiosityRange"; displayName = "$STR_ALIVE_ADVCIV_CURIOSITY_RANGE"; tooltip = "$STR_ALIVE_ADVCIV_CURIOSITY_RANGE_COMMENT"; defaultValue = """200"""; };
            class advciv_panicChance : Edit { property = "ALiVE_amb_civ_population_advciv_panicChance"; displayName = "$STR_ALIVE_ADVCIV_PANIC_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_PANIC_CHANCE_COMMENT"; defaultValue = """0.7"""; };
            class advciv_alertChance : Edit { property = "ALiVE_amb_civ_population_advciv_alertChance"; displayName = "$STR_ALIVE_ADVCIV_ALERT_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_ALERT_CHANCE_COMMENT"; defaultValue = """0.5"""; };
            class advciv_cascadeRadius : Edit { property = "ALiVE_amb_civ_population_advciv_cascadeRadius"; displayName = "$STR_ALIVE_ADVCIV_CASCADE_RADIUS"; tooltip = "$STR_ALIVE_ADVCIV_CASCADE_RADIUS_COMMENT"; defaultValue = """20"""; };
            class advciv_cascadeChance : Edit { property = "ALiVE_amb_civ_population_advciv_cascadeChance"; displayName = "$STR_ALIVE_ADVCIV_CASCADE_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_CASCADE_CHANCE_COMMENT"; defaultValue = """0.25"""; };
            class advciv_shotMemoryTime : Edit { property = "ALiVE_amb_civ_population_advciv_shotMemoryTime"; displayName = "$STR_ALIVE_ADVCIV_SHOT_MEMORY_TIME"; tooltip = "$STR_ALIVE_ADVCIV_SHOT_MEMORY_TIME_COMMENT"; defaultValue = """30"""; };
            class advciv_handsUpChance : Edit { property = "ALiVE_amb_civ_population_advciv_handsUpChance"; displayName = "$STR_ALIVE_ADVCIV_HANDSUP_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_HANDSUP_CHANCE_COMMENT"; defaultValue = """0.30"""; };
            class advciv_dropChance : Edit { property = "ALiVE_amb_civ_population_advciv_dropChance"; displayName = "$STR_ALIVE_ADVCIV_DROP_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_DROP_CHANCE_COMMENT"; defaultValue = """0.25"""; };
            class advciv_freezeChance : Edit { property = "ALiVE_amb_civ_population_advciv_freezeChance"; displayName = "$STR_ALIVE_ADVCIV_FREEZE_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_FREEZE_CHANCE_COMMENT"; defaultValue = """0.15"""; };
            class advciv_screamChance : Edit { property = "ALiVE_amb_civ_population_advciv_screamChance"; displayName = "$STR_ALIVE_ADVCIV_SCREAM_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_SCREAM_CHANCE_COMMENT"; defaultValue = """0.15"""; };
            class advciv_hideTimeMin : Edit { property = "ALiVE_amb_civ_population_advciv_hideTimeMin"; displayName = "$STR_ALIVE_ADVCIV_HIDE_TIME_MIN"; tooltip = "$STR_ALIVE_ADVCIV_HIDE_TIME_MIN_COMMENT"; defaultValue = """60"""; };
            class advciv_hideTimeMax : Edit { property = "ALiVE_amb_civ_population_advciv_hideTimeMax"; displayName = "$STR_ALIVE_ADVCIV_HIDE_TIME_MAX"; tooltip = "$STR_ALIVE_ADVCIV_HIDE_TIME_MAX_COMMENT"; defaultValue = """180"""; };
            class advciv_preferBuildings : Combo { property = "ALiVE_amb_civ_population_advciv_preferBuildings"; displayName = "$STR_ALIVE_ADVCIV_PREFER_BUILDINGS"; tooltip = "$STR_ALIVE_ADVCIV_PREFER_BUILDINGS_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
            class advciv_voiceEnabled : Combo { property = "ALiVE_amb_civ_population_advciv_voiceEnabled"; displayName = "$STR_ALIVE_ADVCIV_VOICE_ENABLED"; tooltip = "$STR_ALIVE_ADVCIV_VOICE_ENABLED_COMMENT"; defaultValue = """false"""; class Values { class Yes{name="Yes";value=true;}; class No{name="No";value=false;default=1;}; }; };
            class advciv_voiceChance : Edit { property = "ALiVE_amb_civ_population_advciv_voiceChance"; displayName = "$STR_ALIVE_ADVCIV_VOICE_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_VOICE_CHANCE_COMMENT"; defaultValue = """0.6"""; };

            // ---- Advanced Civilians - Vehicle ------------------------------------
            class HDR_ADVCIV_VEHICLE : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_ADVCIV_VEHICLE"; displayName = "ADVANCED CIVILIANS - VEHICLE"; };
            class advciv_vehicleEscape : Combo { property = "ALiVE_amb_civ_population_advciv_vehicleEscape"; displayName = "$STR_ALIVE_ADVCIV_VEHICLE_ESCAPE"; tooltip = "$STR_ALIVE_ADVCIV_VEHICLE_ESCAPE_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
            class advciv_vehicleEscapeChance : Edit { property = "ALiVE_amb_civ_population_advciv_vehicleEscapeChance"; displayName = "$STR_ALIVE_ADVCIV_VEHICLE_ESCAPE_CHANCE"; tooltip = "$STR_ALIVE_ADVCIV_VEHICLE_ESCAPE_CHANCE_COMMENT"; defaultValue = """0.3"""; };
            class advciv_noStealMilitary : Combo { property = "ALiVE_amb_civ_population_advciv_noStealMilitary"; displayName = "$STR_ALIVE_ADVCIV_NO_STEAL_MILITARY"; tooltip = "$STR_ALIVE_ADVCIV_NO_STEAL_MILITARY_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
            class advciv_noStealUsed : Combo { property = "ALiVE_amb_civ_population_advciv_noStealUsed"; displayName = "$STR_ALIVE_ADVCIV_NO_STEAL_USED"; tooltip = "$STR_ALIVE_ADVCIV_NO_STEAL_USED_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
            class advciv_noStealLoaded : Combo { property = "ALiVE_amb_civ_population_advciv_noStealLoaded"; displayName = "$STR_ALIVE_ADVCIV_NO_STEAL_LOADED"; tooltip = "$STR_ALIVE_ADVCIV_NO_STEAL_LOADED_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
            class advciv_loadedThreshold : Edit { property = "ALiVE_amb_civ_population_advciv_loadedThreshold"; displayName = "$STR_ALIVE_ADVCIV_LOADED_THRESHOLD"; tooltip = "$STR_ALIVE_ADVCIV_LOADED_THRESHOLD_COMMENT"; defaultValue = """4"""; };

            // ---- Advanced Civilians - Compatibility ------------------------------
            class HDR_ADVCIV_COMPAT : ALiVE_ModuleSubTitle { property = "ALiVE_amb_civ_population_HDR_ADVCIV_COMPAT"; displayName = "ADVANCED CIVILIANS - COMPATIBILITY"; };
            class advciv_missionCriticalCheck : Combo { property = "ALiVE_amb_civ_population_advciv_missionCriticalCheck"; displayName = "$STR_ALIVE_ADVCIV_MISSION_CRITICAL"; tooltip = "$STR_ALIVE_ADVCIV_MISSION_CRITICAL_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };

            class ModuleDescription : ModuleDescription {};
        };
    };

    class Item_Base_F;
    class ALiVE_Waterbottle_Item: Item_Base_F
    {
        scope = 2; scopeCurator = 2;
        displayName = "ALiVE Water Bottle (Full)";
        author = "ALiVE Mod"; vehicleClass = "Items";
        class TransportItems { class ALiVE_Waterbottle { name = "ALiVE_Waterbottle"; count = 1; }; };
    };
    class ALiVE_Humrat_Item: Item_Base_F
    {
        scope = 2; scopeCurator = 2;
        displayName = "ALiVE Rice Pack";
        author = "ALiVE Mod"; vehicleClass = "Items";
        class TransportItems { class ALiVE_Humrat { name = "ALiVE_Humrat"; count = 1; }; };
    };
    class NATO_Box_Base;
    class ALiVE_Humanitarian_Crates: NATO_Box_Base
    {
        scope = 2; accuracy = 1;
        displayName = "ALiVE Humanitarian Crate";
        transportMaxItems = 2000; maximumload = 2000;
        model = "\A3\weapons_F\AmmoBoxes\WpnsBox_large_F";
        editorPreview = "\A3\EditorPreviews_F\Data\CfgVehicles\Box_NATO_WpsSpecial_F.jpg";
        class TransportItems {
            MACRO_ADDITEM(ALiVE_Waterbottle,100);
            MACRO_ADDITEM(ALiVE_Humrat,100);
        };
    };
};
