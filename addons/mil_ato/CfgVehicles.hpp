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
    class ModuleAliveBase;
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
        class Arguments
        {
                class debug
                {
                        displayName = "$STR_ALIVE_ATO_DEBUG";
                        description = "$STR_ALIVE_ATO_DEBUG_COMMENT";
                        class Values
                        {
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                };
                                class No
                                {
                                        name = "No";
                                        value = false;
                                        default = 1;
                                };
                        };
                };
                class persistent
                {
                        displayName = "$STR_ALIVE_ATO_PERSISTENT";
                        description = "$STR_ALIVE_ATO_PERSISTENT_COMMENT";
                        class Values
                        {
                                class No
                                {
                                        name = "No";
                                        value = false;
                                        default = 1;
                                };
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                };
                        };
                };
                class faction
                {
                        displayName = "$STR_ALIVE_ATO_FACTION";
                        description = "$STR_ALIVE_ATO_FACTION_COMMENT";
                        defaultValue = "OPF_F";
                };
                class types
                {
                        displayName = "$STR_ALIVE_ATO_TYPES";
                        description = "$STR_ALIVE_ATO_TYPES_COMMENT";
                        defaultValue = "[''CAP'',''DCA'',''SEAD'',''CAS'',''Strike'',''Recce'']";
                };

                class airspace
                {
                        displayName = "$STR_ALIVE_ATO_AIRSPACE";
                        description = "$STR_ALIVE_ATO_AIRSPACE_COMMENT";
                        defaultValue = "";
                };
                class createHQ
                {
                        displayName = "$STR_ALIVE_ATO_CREATE_HQ";
                        description = "$STR_ALIVE_ATO_CREATE_HQ_COMMENT";
                        class Values
                        {
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                        default = 1;
                                };
                                class No
                                {
                                        name = "No";
                                        value = false;
                                };
                        };
                };
                class placeAir
                {
                        displayName = "$STR_ALIVE_ATO_PLACE_AIR";
                        description = "$STR_ALIVE_ATO_PLACE_AIR_COMMENT";
                        class Values
                        {
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                };
                                class No
                                {
                                        name = "No";
                                        value = false;
                                        default = 1;
                                };
                        };
                };
                class placeAA
                {
                        displayName = "$STR_ALIVE_ATO_PLACE_AA";
                        description = "$STR_ALIVE_ATO_PLACE_AA_COMMENT";
                        class Values
                        {
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                };
                                class No
                                {
                                        name = "No";
                                        value = false;
                                        default = 1;
                                };
                        };
                };
                class generateTasks
                {
                        displayName = "$STR_ALIVE_ATO_GENERATE_TASKS";
                        description = "$STR_ALIVE_ATO_GENERATE_TASKS_COMMENT";
                        class Values
                        {
                                class No
                                {
                                        name = "No";
                                        value = false;
                                        default = 1;
                                };
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                };
                        };
                };
                class Resupply
                {
                        displayName = "$STR_ALIVE_ATO_RESUPPLY";
                        description = "$STR_ALIVE_ATO_RESUPPLY_COMMENT";
                        class Values
                        {
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                };
                                class No
                                {
                                        name = "No";
                                        value = false;
                                        default = 1;
                                };
                        };
                };
                class broadcastOnRadio
                {
                        displayName = "$STR_ALIVE_ATO_BROADCASTONRADIO";
                        description = "$STR_ALIVE_ATO_BROADCASTONRADIO_COMMENT";
                        class Values
                        {
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                        default = 1;
                                };
                                class No
                                {
                                        name = "No";
                                        value = false;
                                };
                        };
                };
                class pilotbuilding
                {
                        displayName = "$STR_ALIVE_ATO_PILOTBUILDING";
                        description = "$STR_ALIVE_ATO_PILOTBUILDING_COMMENT";
                        defaultValue = "";
                        typeName = "STRING";
                };
        };
        class ModuleDescription
        {
            //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
            description[] = {
                    "$STR_ALIVE_ATO_COMMENT",
                    "",
                    "$STR_ALIVE_ATO_USAGE"
            };
            sync[] = {"ALiVE_mil_OPCOM"}; // Array of synced entities (can contain base classes)

            class ALiVE_mil_OPCOM
            {
                description[] = { // Multi-line descriptions are supported
                    "$STR_ALIVE_OPCOM_COMMENT",
                    "",
                    "$STR_ALIVE_OPCOM_USAGE"
                };
                position = 1; // Position is taken into effect
                direction = 0; // Direction is taken into effect
                optional = 1; // Synced entity is optional
                duplicate = 1; // Multiple entities of this type can be synced
            };

        };
    };
    class StaticMGWeapon;
    class AAA_System_01_base_F : StaticMGWeapon
    {
        class textureSources
        {
            class Sand
            {
                factions[] = {"BLU_F","OPF_F"};
            };
        };
    };
    class B_AAA_System_01_F : AAA_System_01_base_F
    {
        class EventHandlers;
    };
    class O_AAA_System_01_F : B_AAA_System_01_F
    {
        class EventHandlers: EventHandlers {
            init = "if (local (_this select 0)) then {[(_this select 0), """", false, false] call bis_fnc_initVehicle;};";
        };
        crew = "O_UAV_AI";
        faction = "OPF_F";
        side = 0;
        typicalCargo[] = {"O_UAV_AI"};
        textureList[] = {"Sand",1};
    };
    class SAM_System_01_base_F : StaticMGWeapon
    {

        class textureSources
        {
            class Sand
            {
                factions[] = {"BLU_F","OPF_F"};
            };
        };
    };
    class SAM_System_02_base_F : StaticMGWeapon
    {
        class textureSources
        {
            class Sand
            {
                factions[] = {"BLU_F","OPF_F"};
            };
        };
    };
    class B_SAM_System_01_F : SAM_System_01_base_F
    {
        class EventHandlers;
    };
    class O_SAM_System_01_F : B_SAM_System_01_F
    {
        class EventHandlers: EventHandlers {
            init = "if (local (_this select 0)) then {[(_this select 0), """", false, false] call bis_fnc_initVehicle;};";
        };
        crew = "O_UAV_AI";
        faction = "OPF_F";
        side = 0;
        typicalCargo[] = {"O_UAV_AI"};
        textureList[] = {"Sand",1};
    };
    class B_SAM_System_02_F : SAM_System_02_base_F
    {
        class EventHandlers;
    };
    class O_SAM_System_02_F : B_SAM_System_02_F
    {
        class EventHandlers: EventHandlers {
            init = "if (local (_this select 0)) then {[(_this select 0), """", false, false] call bis_fnc_initVehicle;};";
        };
        crew = "O_UAV_AI";
        faction = "OPF_F";
        side = 0;
        typicalCargo[] = {"O_UAV_AI"};
        textureList[] = {"Sand",1};
    };
    class Sound;
    class Sound_AirRaidSiren : Sound
    {
        author = "ALiVE Team";
        displayName = "Air Raid Siren";
        scope = 2;
        sound = "AirRaidSiren";
    };
};

