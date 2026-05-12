class CfgSFX
{
    class AirRaidSiren
    {
        Alarm_BLUFOR[] = {"A3\Sounds_F\sfx\alarm_blufor",1,1,800,1,0,0,0};
        empty[] = {"", 0, 0, 0, 0, 0, 0, 0};
        name = "Air Raid Siren";
        sounds[] = {"Alarm_BLUFOR"};
    };
};
class CfgVehicles
{
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase
        {
            class Edit;
            class Combo;
            class ModuleDescription;
        };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase
        {
            class ALiVE_ModuleSubTitle;
        };
        class ModuleDescription;
    };
    class ADDON : ModuleAliveBase
    {
        scope = 2;
        displayName = "$STR_ALIVE_ATO";
        function = "ALIVE_fnc_ATOInit";
        author = MODULE_AUTHOR;
        functionPriority = 190;
        isGlobal = 1;
        icon = "x\alive\addons\mil_ato\icon_mil_ATO.paa";
        picture = "x\alive\addons\mil_ato\icon_mil_ATO.paa";
        class Attributes : AttributesBase
        {
                // ---- General --------------------------------------------------------
                class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ato_HDR_GENERAL"; displayName = "GENERAL"; };
                class debug : Combo
                {
                        property = "ALiVE_mil_ato_debug";
                        displayName = "$STR_ALIVE_ATO_DEBUG";
                        tooltip = "$STR_ALIVE_ATO_DEBUG_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; };
                            class No { name = "No"; value = false; default = 1; };
                        };
                };
                class persistent : Combo
                {
                        property = "ALiVE_mil_ato_persistent";
                        displayName = "$STR_ALIVE_ATO_PERSISTENT";
                        tooltip = "$STR_ALIVE_ATO_PERSISTENT_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class No { name = "No"; value = false; default = 1; };
                            class Yes { name = "Yes"; value = true; };
                        };
                };
                // Shared ALiVE_FactionChoice dropdown - see addons/main/CfgVehicles.hpp.
                class faction
                {
                        property     = "ALiVE_mil_ato_faction";
                        displayName  = "$STR_ALIVE_ATO_FACTION";
                        tooltip      = "$STR_ALIVE_ATO_FACTION_COMMENT";
                        control      = "ALiVE_FactionChoice_Military";
                        typeName     = "STRING";
                        expression   = "_this setVariable ['faction', _value];";
                        defaultValue = """OPF_F""";
                };
                // ---- Air Operations ------------------------------------------------
                class HDR_OPS : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ato_HDR_OPS"; displayName = "AIR OPERATIONS"; };
                class types : Edit
                {
                        property = "ALiVE_mil_ato_types";
                        displayName = "$STR_ALIVE_ATO_TYPES";
                        tooltip = "$STR_ALIVE_ATO_TYPES_COMMENT";
                        defaultValue = """['CAP','DCA','SEAD','CAS','Strike','Recce']""";
                };
                class airspace : Edit
                {
                        property = "ALiVE_mil_ato_airspace";
                        displayName = "$STR_ALIVE_ATO_AIRSPACE";
                        tooltip = "$STR_ALIVE_ATO_AIRSPACE_COMMENT";
                        defaultValue = """""";
                };
                class createHQ : Combo
                {
                        property = "ALiVE_mil_ato_createHQ";
                        displayName = "$STR_ALIVE_ATO_CREATE_HQ";
                        tooltip = "$STR_ALIVE_ATO_CREATE_HQ_COMMENT";
                        defaultValue = """true""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; default = 1; };
                            class No { name = "No"; value = false; };
                        };
                };
                class placeAir : Combo
                {
                        property = "ALiVE_mil_ato_placeAir";
                        displayName = "$STR_ALIVE_ATO_PLACE_AIR";
                        tooltip = "$STR_ALIVE_ATO_PLACE_AIR_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; };
                            class No { name = "No"; value = false; default = 1; };
                        };
                };
                class placeAA : Combo
                {
                        property = "ALiVE_mil_ato_placeAA";
                        displayName = "$STR_ALIVE_ATO_PLACE_AA";
                        tooltip = "$STR_ALIVE_ATO_PLACE_AA_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; };
                            class No { name = "No"; value = false; default = 1; };
                        };
                };
                class generateTasks : Combo
                {
                        property = "ALiVE_mil_ato_generateTasks";
                        displayName = "$STR_ALIVE_ATO_GENERATE_TASKS";
                        tooltip = "$STR_ALIVE_ATO_GENERATE_TASKS_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class No { name = "No"; value = false; default = 1; };
                            class Yes { name = "Yes"; value = true; };
                        };
                };
                class generateSEADTasks : Combo
                {
                        property = "ALiVE_mil_ato_generateSEADTasks";
                        displayName = "$STR_ALIVE_ATO_GENERATE_SEADTASKS";
                        tooltip = "$STR_ALIVE_ATO_GENERATE_SEADTASKS_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class No { name = "No"; value = false; default = 1; };
                            class Yes { name = "Yes"; value = true; };
                        };
                };
                class Resupply : Combo
                {
                        property = "ALiVE_mil_ato_Resupply";
                        displayName = "$STR_ALIVE_ATO_RESUPPLY";
                        tooltip = "$STR_ALIVE_ATO_RESUPPLY_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; };
                            class No { name = "No"; value = false; default = 1; };
                        };
                };
                class broadcastOnRadio : Combo
                {
                        property = "ALiVE_mil_ato_broadcastOnRadio";
                        displayName = "$STR_ALIVE_ATO_BROADCASTONRADIO";
                        tooltip = "$STR_ALIVE_ATO_BROADCASTONRADIO_COMMENT";
                        defaultValue = """true""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; default = 1; };
                            class No { name = "No"; value = false; };
                        };
                };
                // ---- Runway Configuration ------------------------------------------
                class HDR_RUNWAY : ALiVE_ModuleSubTitle { property = "ALiVE_mil_ato_HDR_RUNWAY"; displayName = "RUNWAY CONFIGURATION"; };
                class pilotbuilding : Edit
                {
                        property = "ALiVE_mil_ato_pilotbuilding";
                        displayName = "$STR_ALIVE_ATO_PILOTBUILDING";
                        tooltip = "$STR_ALIVE_ATO_PILOTBUILDING_COMMENT";
                        defaultValue = """""";
                        typeName = "STRING";
                };
                class runwaystartpos : Edit
                {
                        property = "ALiVE_mil_ato_runwaystartpos";
                        displayName = "$STR_ALIVE_ATO_RUNWAYSTARTPOS";
                        tooltip = "$STR_ALIVE_ATO_RUNWAYSTARTPOS_COMMENT";
                        defaultValue = """""";
                };
                class runwayendpos : Edit
                {
                        property = "ALiVE_mil_ato_runwayendpos";
                        displayName = "$STR_ALIVE_ATO_RUNWAYENDPOS";
                        tooltip = "$STR_ALIVE_ATO_RUNWAYENDPOS_COMMENT";
                        defaultValue = """""";
                };
                class runwaywidth : Edit
                {
                        property = "ALiVE_mil_ato_runwaywidth";
                        displayName = "$STR_ALIVE_ATO_RUNWAYWIDTH";
                        tooltip = "$STR_ALIVE_ATO_RUNWAYWIDTH_COMMENT";
                        defaultValue = """""";
                };
                class ModuleDescription : ModuleDescription {};
        };
        class ModuleDescription
        {
            description[] = {"$STR_ALIVE_ATO_COMMENT","","$STR_ALIVE_ATO_USAGE"};
            sync[] = {"ALiVE_mil_OPCOM","ALiVE_sys_factioncompiler"};
            class ALiVE_mil_OPCOM
            {
                description[] = {"$STR_ALIVE_OPCOM_COMMENT","","$STR_ALIVE_OPCOM_USAGE"};
                position = 1; direction = 0; optional = 1; duplicate = 1;
            };
            class ALiVE_sys_factioncompiler
            {
                description[] = {"Custom Faction Compiler module."};
                position = 0; direction = 0; optional = 1; duplicate = 0;
            };
        };
    };
    class StaticMGWeapon;
    class AAA_System_01_base_F : StaticMGWeapon { class textureSources { class Sand { factions[] = {"BLU_F","OPF_F"}; }; }; };
    class B_AAA_System_01_F : AAA_System_01_base_F { class EventHandlers; };
    class O_AAA_System_01_F : B_AAA_System_01_F
    {
        class EventHandlers: EventHandlers { init = "if (local (_this select 0)) then {[(_this select 0), """", false, false] call bis_fnc_initVehicle;};"; };
        crew = "O_UAV_AI"; faction = "OPF_F"; side = 0; typicalCargo[] = {"O_UAV_AI"}; textureList[] = {"Sand",1};
    };
    class SAM_System_01_base_F : StaticMGWeapon { class textureSources { class Sand { factions[] = {"BLU_F","OPF_F"}; }; }; };
    class SAM_System_02_base_F : StaticMGWeapon { class textureSources { class Sand { factions[] = {"BLU_F","OPF_F"}; }; }; };
    class B_SAM_System_01_F : SAM_System_01_base_F { class EventHandlers; };
    class O_SAM_System_01_F : B_SAM_System_01_F
    {
        class EventHandlers: EventHandlers { init = "if (local (_this select 0)) then {[(_this select 0), """", false, false] call bis_fnc_initVehicle;};"; };
        crew = "O_UAV_AI"; faction = "OPF_F"; side = 0; typicalCargo[] = {"O_UAV_AI"}; textureList[] = {"Sand",1};
    };
    class B_SAM_System_02_F : SAM_System_02_base_F { class EventHandlers; };
    class O_SAM_System_02_F : B_SAM_System_02_F
    {
        class EventHandlers: EventHandlers { init = "if (local (_this select 0)) then {[(_this select 0), """", false, false] call bis_fnc_initVehicle;};"; };
        crew = "O_UAV_AI"; faction = "OPF_F"; side = 0; typicalCargo[] = {"O_UAV_AI"}; textureList[] = {"Sand",1};
    };
    class Sound;
    class Sound_AirRaidSiren : Sound { author = "ALiVE Team"; displayName = "Air Raid Siren"; scope = 2; sound = "AirRaidSiren"; };
};
