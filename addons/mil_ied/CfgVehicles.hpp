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
                displayName = "$STR_ALIVE_ied";
                function = "ALIVE_fnc_iedInit";
                isGlobal = 2;
                isPersistent = 0;
                author = MODULE_AUTHOR;
                functionPriority = 130;
                icon = "x\alive\addons\mil_ied\icon_mil_ied.paa";
                picture = "x\alive\addons\mil_ied\icon_mil_ied.paa";
                class Attributes : AttributesBase
                {
                        // ---- General --------------------------------------------------------
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ied_HDR_GENERAL"; displayName = "GENERAL"; };
                        class debug : Combo
                        {
                                property = "ALiVE_mil_ied_debug"; displayName = "$STR_ALIVE_IED_DEBUG"; tooltip = "$STR_ALIVE_IED_DEBUG_COMMENT"; defaultValue = """0""";
                                class Values { class Yes { name="Yes"; value=1; }; class No { name="No"; value=0; default=1; }; };
                        };
                        class persistence : Combo
                        {
                                property = "ALiVE_mil_ied_persistence"; displayName = "$STR_ALIVE_IED_PERSISTENCE"; tooltip = "$STR_ALIVE_IED_PERSISTENCE_COMMENT"; defaultValue = """0""";
                                class Values { class Yes { name="Yes"; value=1; }; class No { name="No"; value=0; default=1; }; };
                        };
                        class taor : Edit { property = "ALiVE_mil_ied_taor"; displayName = "$STR_ALIVE_IED_TAOR"; tooltip = "$STR_ALIVE_IED_TAOR_COMMENT"; defaultValue = """"""; };
                        class blacklist : Edit { property = "ALiVE_mil_ied_blacklist"; displayName = "$STR_ALIVE_IED_BLACKLIST"; tooltip = "$STR_ALIVE_IED_BLACKLIST_COMMENT"; defaultValue = """"""; };
                        class AI_Triggerable : Combo
                        {
                                property = "ALiVE_mil_ied_AI_Triggerable"; displayName = "$STR_ALIVE_IED_AI_TRIGGER"; tooltip = "$STR_ALIVE_IED_AI_TRIGGER_COMMENT"; defaultValue = """0""";
                                class Values { class No{name="No";value=0;default=1;}; class Yes{name="Yes";value=1;}; };
                        };
                        class integrationChoice
                        {
                                property     = "ALiVE_mil_ied_integrationChoice";
                                displayName  = "$STR_ALIVE_IED_INTEGRATION";
                                tooltip      = "$STR_ALIVE_IED_INTEGRATION_COMMENT";
                                control      = "ALiVE_IntegrationChoice";
                                // typeName + expression + defaultValue wire the attribute value
                                // into Eden's SQM serialization + mission-load entity-apply path.
                                // attributeSave explicitly stores the string into Eden's "value"
                                // slot (via setVariable on the control), which is what Eden reads
                                // when emitting the SQM. At mission start, expression fires with
                                // _value = the serialized string and lands it on the logic
                                // variable `integrationChoice` that fnc_IED.sqf's init reads.
                                typeName     = "STRING";
                                expression   = "_this setVariable ['integrationChoice', _value];";
                                defaultValue = """_auto""";
                        };
                        // ---- IED Threat -----------------------------------------------------
                        class HDR_IED : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ied_HDR_IED"; displayName = "IED THREAT"; };
                        class IED_Threat : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Threat"; displayName = "$STR_ALIVE_IED_IED_THREAT"; tooltip = "$STR_ALIVE_IED_IED_THREAT_COMMENT"; defaultValue = """0""";
                                class Values { class None{name="None";value=0;default=1;}; class Low{name="Low";value=50;}; class Med{name="Medium";value=100;}; class High{name="High";value=200;}; class Extreme{name="Extreme";value=350;}; };
                        };
                        class IED_Starting_Threat : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Starting_Threat"; displayName = "$STR_ALIVE_IED_IED_STARTING_THREAT"; tooltip = "$STR_ALIVE_IED_IED_STARTING_THREAT_COMMENT"; defaultValue = """0""";
                                class Values { class None{name="None";value=0;default=1;}; class Low{name="Low";value=50;}; class Med{name="Medium";value=100;}; class High{name="High";value=200;}; class Extreme{name="Extreme";value=350;}; };
                        };
                        class IED_Detection : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Detection"; displayName = "$STR_ALIVE_IED_IED_DETECTION"; tooltip = "$STR_ALIVE_IED_IED_DETECTION_COMMENT"; defaultValue = """1""";
                                class Values { class None{name="None";value=0;}; class Text{name="Text";value=1;default=1;}; class Audio{name="Audio";value=2;}; };
                        };
                        class IED_Detection_Device : Edit { property = "ALiVE_mil_ied_IED_Detection_Device"; displayName = "$STR_ALIVE_IED_IED_DETECTION_DEVICE"; tooltip = "$STR_ALIVE_IED_IED_DETECTION_DEVICE_COMMENT"; defaultValue = """MineDetector"""; };
                        // ---- Suicide Bombers ------------------------------------------------
                        class HDR_BOMBER : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ied_HDR_BOMBER"; displayName = "SUICIDE BOMBERS"; };
                        class Bomber_Threat : Combo
                        {
                                property = "ALiVE_mil_ied_Bomber_Threat"; displayName = "$STR_ALIVE_IED_BOMBER_THREAT"; tooltip = "$STR_ALIVE_IED_BOMBER_THREAT_COMMENT"; defaultValue = """0""";
                                class Values { class None{name="None";value=0;default=1;}; class Low{name="Low";value=10;}; class Med{name="Medium";value=20;}; class High{name="High";value=30;}; class Extreme{name="Extreme";value=50;}; };
                        };
                        class Bomber_Type : Edit { property = "ALiVE_mil_ied_Bomber_Type"; displayName = "$STR_ALIVE_IED_BOMBER_TYPE"; tooltip = "$STR_ALIVE_IED_BOMBER_TYPE_COMMENT"; defaultValue = """"""; };
                        class Bomber_Vest : Edit { property = "ALiVE_mil_ied_Bomber_Vest"; displayName = "$STR_ALIVE_IED_BOMBER_VEST"; tooltip = "$STR_ALIVE_IED_BOMBER_VEST_COMMENT"; defaultValue = """V_ALiVE_Suicide_Vest"""; };
                        // ---- Vehicle-Borne IED ----------------------------------------------
                        class HDR_VBIED : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ied_HDR_VBIED"; displayName = "VEHICLE-BORNE IED"; };
                        class VB_IED_Threat : Combo
                        {
                                property = "ALiVE_mil_ied_VB_IED_Threat"; displayName = "$STR_ALIVE_IED_VB_IED_THREAT"; tooltip = "$STR_ALIVE_IED_VB_IED_THREAT_COMMENT"; defaultValue = """0""";
                                class Values { class None{name="None";value=0;default=1;}; class Low{name="Low";value=10;}; class Med{name="Medium";value=20;}; class High{name="High";value=50;}; class Extreme{name="Extreme";value=70;}; };
                        };
                        class VB_IED_Side : Combo
                        {
                                property = "ALiVE_mil_ied_VB_IED_Side"; displayName = "$STR_ALIVE_IED_VB_IED_SIDE"; tooltip = "$STR_ALIVE_IED_VB_IED_SIDE_COMMENT"; defaultValue = """CIV""";
                                class Values { class Civ{name="CIV";value="CIV";default=1;}; class East{name="EAST";value="EAST";}; class West{name="WEST";value="WEST";}; class Ind{name="IND";value="GUER";}; };
                        };
                        class Locs_IED : Combo
                        {
                                property = "ALiVE_mil_ied_Locs_IED"; displayName = "$STR_ALIVE_IED_LOCS_IED"; tooltip = "$STR_ALIVE_IED_LOCS_IED_COMMENT"; defaultValue = """0""";
                                class Values { class Random{name="Random";value=0;default=1;}; class Occupied{name="Enemy-Occupied Areas";value=1;}; class Unoccupied{name="Unoccupied";value=2;}; };
                        };
                        // ---- Engineer Challenge ---------------------------------------------
                        class HDR_ENGINEER : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ied_HDR_ENGINEER"; displayName = "ENGINEER CHALLENGE"; };
                        class IED_Engineer_Challenge : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Engineer_Challenge";
                                displayName = "$STR_ALIVE_IED_ENGINEER_CHALLENGE";
                                tooltip = "$STR_ALIVE_IED_ENGINEER_CHALLENGE_COMMENT";
                                defaultValue = """1""";
                                class Values { class No{name="No";value=0;}; class Yes{name="Yes";value=1;default=1;}; };
                        };
                        class IED_Dicker_Chance : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Dicker_Chance";
                                displayName = "$STR_ALIVE_IED_DICKER_CHANCE";
                                tooltip = "$STR_ALIVE_IED_DICKER_CHANCE_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                        class None { name="None"; value=0; default=1; };
                                        class Few  { name="10%"; value=10; };
                                        class Some { name="25%"; value=25; };
                                        class Half { name="50%"; value=50; };
                                        class All  { name="All"; value=100; };
                                };
                        };
                        class IED_Engineer_Trip_Base : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Engineer_Trip_Base";
                                displayName = "$STR_ALIVE_IED_ENGINEER_TRIP_BASE";
                                tooltip = "$STR_ALIVE_IED_ENGINEER_TRIP_BASE_COMMENT";
                                defaultValue = """0.02""";
                                class Values
                                {
                                        class Gentle { name="Gentle (0.01)"; value=0.01; };
                                        class Default { name="Default (0.02)"; value=0.02; default=1; };
                                        class Aggressive { name="Aggressive (0.04)"; value=0.04; };
                                        class Brutal { name="Brutal (0.08)"; value=0.08; };
                                };
                        };
                        class IED_Engineer_Trip_ThresholdMin : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Engineer_Trip_ThresholdMin";
                                displayName = "$STR_ALIVE_IED_ENGINEER_TRIP_THRESHOLDMIN";
                                tooltip = "$STR_ALIVE_IED_ENGINEER_TRIP_THRESHOLDMIN_COMMENT";
                                defaultValue = """0.7""";
                                class Values
                                {
                                        class Low { name="Low (0.5)"; value=0.5; };
                                        class Default { name="Default (0.7)"; value=0.7; default=1; };
                                        class High { name="High (1.0)"; value=1.0; };
                                        class VHigh { name="Very High (1.5)"; value=1.5; };
                                };
                        };
                        class IED_Engineer_Trip_ThresholdMax : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Engineer_Trip_ThresholdMax";
                                displayName = "$STR_ALIVE_IED_ENGINEER_TRIP_THRESHOLDMAX";
                                tooltip = "$STR_ALIVE_IED_ENGINEER_TRIP_THRESHOLDMAX_COMMENT";
                                defaultValue = """1.3""";
                                class Values
                                {
                                        class Low { name="Low (1.0)"; value=1.0; };
                                        class Default { name="Default (1.3)"; value=1.3; default=1; };
                                        class High { name="High (1.8)"; value=1.8; };
                                        class VHigh { name="Very High (2.5)"; value=2.5; };
                                };
                        };
                        class IED_Engineer_Decay_Rate : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Engineer_Decay_Rate";
                                displayName = "$STR_ALIVE_IED_ENGINEER_DECAY_RATE";
                                tooltip = "$STR_ALIVE_IED_ENGINEER_DECAY_RATE_COMMENT";
                                defaultValue = """0.01""";
                                class Values
                                {
                                        class Slow { name="Slow (0.005)"; value=0.005; };
                                        class Default { name="Default (0.01)"; value=0.01; default=1; };
                                        class Fast { name="Fast (0.02)"; value=0.02; };
                                        class Instant { name="Instant (0.05)"; value=0.05; };
                                };
                        };
                        class IED_Engineer_Disarm_BaseTime : Edit
                        {
                                property = "ALiVE_mil_ied_IED_Engineer_Disarm_BaseTime";
                                displayName = "$STR_ALIVE_IED_ENGINEER_DISARM_BASETIME";
                                tooltip = "$STR_ALIVE_IED_ENGINEER_DISARM_BASETIME_COMMENT";
                                defaultValue = """60""";
                                typeName = "NUMBER";
                        };
                        class IED_Engineer_Disarm_NewDeviceBase : Combo
                        {
                                property = "ALiVE_mil_ied_IED_Engineer_Disarm_NewDeviceBase";
                                displayName = "$STR_ALIVE_IED_ENGINEER_DISARM_NEWDEVICE";
                                tooltip = "$STR_ALIVE_IED_ENGINEER_DISARM_NEWDEVICE_COMMENT";
                                defaultValue = """0.75""";
                                class Values
                                {
                                        class Often { name="Often (0.60)"; value=0.60; };
                                        class Default { name="Default (0.75)"; value=0.75; default=1; };
                                        class Rare { name="Rare (0.85)"; value=0.85; };
                                        class VRare { name="Very Rare (0.95)"; value=0.95; };
                                };
                        };
                        // ---- Object Classes -------------------------------------------------
                        class HDR_CLASSES : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ied_HDR_CLASSES"; displayName = "OBJECT CLASSES"; };
                        class roadIEDClasses : Edit { property = "ALiVE_mil_ied_roadIEDClasses"; displayName = "$STR_ALIVE_IED_ROAD_IED_CLASSES"; tooltip = "$STR_ALIVE_IED_CLASSES_COMMENT"; defaultValue = """ALIVE_IEDUrbanSmall_Remote_Ammo,ALIVE_IEDLandSmall_Remote_Ammo,ALIVE_IEDUrbanBig_Remote_Ammo,ALIVE_IEDLandBig_Remote_Ammo"""; };
                        class roadIEDClasses_additional : Edit
                        {
                                property = "ALiVE_mil_ied_roadIEDClasses_additional";
                                displayName = "$STR_ALIVE_IED_ROADIED_ADDITIONAL";
                                tooltip = "$STR_ALIVE_IED_ROADIED_ADDITIONAL_COMMENT";
                                defaultValue = """""";
                        };
                        class roadIEDClasses_autoDetect : Combo
                        {
                                property = "ALiVE_mil_ied_roadIEDClasses_autoDetect";
                                displayName = "$STR_ALIVE_IED_ROADIED_AUTODETECT";
                                tooltip = "$STR_ALIVE_IED_ROADIED_AUTODETECT_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                        class Auto { name = "Auto (follow integration)"; value = 0; default = 1; };
                                        class Yes  { name = "Yes (always merge)"; value = 1; };
                                        class No   { name = "No (ignore integration)"; value = 2; };
                                };
                        };
                        class urbanIEDClasses : Edit { property = "ALiVE_mil_ied_urbanIEDClasses"; displayName = "$STR_ALIVE_IED_URBAN_IED_CLASSES"; tooltip = "$STR_ALIVE_IED_CLASSES_COMMENT"; defaultValue = """ALIVE_IEDUrbanSmall_Remote_Ammo,ALIVE_IEDUrbanBig_Remote_Ammo,Land_JunkPile_F,Land_GarbageContainer_closed_F,Land_GarbageBags_F,Land_Tyres_F,Land_GarbagePallet_F,Land_Basket_F,Land_Sack_F,Land_Sacks_goods_F,Land_Sacks_heap_F,Land_BarrelTrash_F"""; };
                        class urbanIEDClasses_additional : Edit
                        {
                                property = "ALiVE_mil_ied_urbanIEDClasses_additional";
                                displayName = "$STR_ALIVE_IED_URBANIED_ADDITIONAL";
                                tooltip = "$STR_ALIVE_IED_URBANIED_ADDITIONAL_COMMENT";
                                defaultValue = """""";
                        };
                        class urbanIEDClasses_autoDetect : Combo
                        {
                                property = "ALiVE_mil_ied_urbanIEDClasses_autoDetect";
                                displayName = "$STR_ALIVE_IED_URBANIED_AUTODETECT";
                                tooltip = "$STR_ALIVE_IED_URBANIED_AUTODETECT_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                        class Auto { name = "Auto (follow integration)"; value = 0; default = 1; };
                                        class Yes  { name = "Yes (always merge)"; value = 1; };
                                        class No   { name = "No (ignore integration)"; value = 2; };
                                };
                        };
                        class clutterClasses : Edit { property = "ALiVE_mil_ied_clutterClasses"; displayName = "$STR_ALIVE_IED_CLUTTER_CLASSES"; tooltip = "$STR_ALIVE_IED_CLASSES_COMMENT"; defaultValue = """Land_JunkPile_F,Land_GarbageContainer_closed_F,Land_GarbageBags_F,Land_Tyres_F,Land_GarbagePallet_F,Land_Basket_F,Land_Sack_F,Land_Sacks_goods_F,Land_Sacks_heap_F,Land_BarrelTrash_F"""; };
                        class clutterClasses_additional : Edit
                        {
                                property = "ALiVE_mil_ied_clutterClasses_additional";
                                displayName = "$STR_ALIVE_IED_CLUTTER_ADDITIONAL";
                                tooltip = "$STR_ALIVE_IED_CLUTTER_ADDITIONAL_COMMENT";
                                defaultValue = """""";
                        };
                        class clutterClasses_autoDetect : Combo
                        {
                                property = "ALiVE_mil_ied_clutterClasses_autoDetect";
                                displayName = "$STR_ALIVE_IED_CLUTTER_AUTODETECT";
                                tooltip = "$STR_ALIVE_IED_CLUTTER_AUTODETECT_COMMENT";
                                defaultValue = """0""";
                                class Values
                                {
                                        class Auto { name = "Auto (follow integration)"; value = 0; default = 1; };
                                        class Yes  { name = "Yes (always merge)"; value = 1; };
                                        class No   { name = "No (ignore integration)"; value = 2; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_IED_COMMENT","","$STR_ALIVE_IED_USAGE"};
                    // IED's runtime iterates its own synchronizedObjects looking
                    // for ALiVE_mil_OPCOM at fnc_IED.sqf:521 to decide whether
                    // to set up starting-threat triggers. Declaration never
                    // existed on the IED side; added under the symmetric-sync
                    // convention and to support editor-time validator checks.
                    sync[] = {"ALiVE_mil_OPCOM"};
                    class ALiVE_mil_OPCOM { description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"}; position=0; direction=0; optional=1; duplicate=1; };
                };
        };
        class Thing;
        class ALiVE_IED : Thing { author="ALiVE Mod Team"; _generalMacro="ALiVE_IED"; model="\A3\Weapons_F\empty.p3d"; icon="iconObject"; vehicleClass="Objects"; destrType="DestructTent"; cost=250; ace_minedetector_detectable=1; };
        class ALIVE_IEDUrbanSmall_Remote_Ammo : ALiVE_IED { scope=2; scopeCurator=2; displayName=""; model="\A3\Weapons_F\Explosives\IED_urban_small"; };
        class ALIVE_IEDLandSmall_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo { model="\A3\Weapons_F\Explosives\IED_land_small"; };
        class ALIVE_IEDUrbanBig_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo { model="\A3\Weapons_F\Explosives\IED_urban_big"; };
        class ALIVE_IEDLandBig_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo { model="\A3\Weapons_F\Explosives\IED_land_big"; };
        class ALIVE_DemoCharge_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo { model="\A3\Weapons_F\explosives\c4_charge_small"; };
        class ALIVE_SatchelCharge_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo { model="\A3\Weapons_F\Explosives\satchel"; };
};
