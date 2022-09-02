class CfgVehicles {
        class Item_Base_F;
        class Item_ItemALiVEPhoneOld: Item_Base_F
        {
            scope = 2;
            scopeCurator = 2;
            displayName = "Mobile Phone (Old)";
            author = "ALiVE Mod Team";
            vehicleClass = "Items";
            class TransportItems
            {
                class ItemALiVEPhoneOld
                {
                    name = "ItemALiVEPhoneOld";
                    count = 1;
                };
            };
        };

        class Vest_Base_F;
        class Vest_V_ALiVE_Suicide_Belt: Vest_Base_F
        {
            scope = 2;
            scopeCurator = 2;
            displayName = "Suicide Belt";
            author = "ALiVE Mod Team";
            vehicleClass = "ItemsVests";
            class TransportItems
            {
                class V_ALiVE_Suicide_Belt
                {
                    name = "V_ALiVE_Suicide_Belt";
                    count = 1;
                };
            };
        };
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_OPCOM";
                function = "ALIVE_fnc_OPCOMInit";
                author = MODULE_AUTHOR;
                functionPriority = 180;
                isGlobal = 1;
                icon = "x\alive\addons\mil_opcom\icon_mil_opcom.paa";
                picture = "x\alive\addons\mil_opcom\icon_mil_opcom.paa";

                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_OPCOM_DEBUG";
                                description = "$STR_ALIVE_OPCOM_DEBUG_COMMENT";
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
                                displayName = "$STR_ALIVE_OPCOM_PERSISTENT";
                                description = "$STR_ALIVE_OPCOM_PERSISTENT_COMMENT";
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

                        class customName
                        {
                                displayName = "$STR_ALIVE_OPCOM_NAME";
                                description = "$STR_ALIVE_OPCOM_NAME_COMMENT";                                
                                defaultValue = "";
                        };

                        class controltype
                        {
                                displayName = "$STR_ALIVE_OPCOM_CONTROLTYPE";
                                description = "$STR_ALIVE_OPCOM_CONTROLTYPE_COMMENT";
                                class Values
                                {
                                        class invasion
                                        {
                                                name = "Invasion";
                                                value = "invasion";
                                                default = 1;
                                        };
                                        class occupation
                                        {
                                                name = "Occupation";
                                                value = "occupation";
                                        };
                                        class asymmetric
                                        {
                                                name = "Asymmetric";
                                                value = "asymmetric";
                                        };
                                };
                        };
                        class asym_occupation
                        {
                                displayName = "$STR_ALIVE_OPCOM_OCCUPATION";
                                description = "$STR_ALIVE_OPCOM_OCCUPATION_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class unused
                                        {
                                                name = "Unused";
                                                value = -100;
                                                default = 1;
                                        };
                                        class low
                                        {
                                                name = "Low";
                                                value = 25;
                                        };
                                        class medium
                                        {
                                                name = "Medium";
                                                value = 50;
                                        };
                                        class high
                                        {
                                                name = "High";
                                                value = 75;
                                        };
                                        class extreme
                                        {
                                                name = "Extreme";
                                                value = 100;
                                        };
                                };
                        };
                        class roadblocks
                        {
                                displayName = "$STR_ALIVE_OPCOM_ROADBLOCKS";
                                description = "$STR_ALIVE_OPCOM_ROADBLOCKS_COMMENT";
                                typeName = "BOOL";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };

                                };
                        };
                        class reinforcements
                        {
                                displayName = "$STR_ALIVE_OPCOM_REINFORCEMENTS";
                                description = "$STR_ALIVE_OPCOM_REINFORCEMENTS_COMMENT";
                                class Values
                                {
                                        class Constant
                                        {
                                                name = "Constant";
                                                value = "0.9";
                                                default = 1;
                                        };
                                        class Blocked
                                        {
                                                name = "Packets";
                                                value = "0.75";
                                        };
                                        class Seldom
                                        {
                                                name = "Seldom";
                                                value = "0.5";
                                        };
                                };
                        };
                        class intelchance
                        {
                                displayName = "$STR_ALIVE_OPCOM_INTELCHANCE";
                                description = "$STR_ALIVE_OPCOM_INTELCHANCE_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class none
                                        {
                                                name = "None";
                                                value = 0;
                                                default = 1;
                                        };
                                        class seldom
                                        {
                                                name = "seldom";
                                                value = 5;
                                        };
                                        class often
                                        {
                                                name = "often";
                                                value = 10;
                                        };
                                };
                        };
                        class faction1
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTION";
                                description = "$STR_ALIVE_OPCOM_FACTION_COMMENT";
                                class Values
                                {
                                        class NATO
                                        {
                                                name = "NATO";
                                                value = "BLU_F";
                                                default = 1;
                                        };
                                        class NATOPACIFIC
                                        {
                                                name = "NATO (Pacific)";
                                                value = "BLU_T_F";
                                        };
                                        class NATO_CTRG
                                        {
                                                name = "NATO (CTRG)";
                                                value = "BLU_CTRG_F";
                                        };
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class IRANPACIFIC
                                        {
                                                name = "CSAT (Pacific)";
                                                value = "OPF_T_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
                                        };
                                        class SYNDIKAT
                                        {
                                                name = "Syndikat";
                                                value = "IND_C_F";
                                        };
                                        class REBELS_BLU
                                        {
                                                name = "REBELS BLU";
                                                value = "BLU_G_F";
                                        };
                                        class REBELS_OPF
                                        {
                                                name = "REBELS RED";
                                                value = "OPF_G_F";
                                        };
                                        class NONE
                                        {
                                                name = "NONE";
                                                value = "NONE";
                                        };
                                };
                        };
                        class faction2
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTION";
                                description = "$STR_ALIVE_OPCOM_FACTION_COMMENT";
                                class Values
                                {
                                        class NATO
                                        {
                                                name = "NATO";
                                                value = "BLU_F";
                                        };
                                        class NATOPACIFIC
                                        {
                                                name = "NATO (Pacific)";
                                                value = "BLU_T_F";
                                        };
                                        class NATO_CTRG
                                        {
                                                name = "NATO (CTRG)";
                                                value = "BLU_CTRG_F";
                                        };
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class IRANPACIFIC
                                        {
                                                name = "CSAT (Pacific)";
                                                value = "OPF_T_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
                                        };
                                        class SYNDIKAT
                                        {
                                                name = "Syndikat";
                                                value = "IND_C_F";
                                        };
                                        class REBELS_BLU
                                        {
                                                name = "REBELS BLU";
                                                value = "BLU_G_F";
                                        };
                                        class REBELS_OPF
                                        {
                                                name = "REBELS RED";
                                                value = "OPF_G_F";
                                        };
                                        class NONE
                                        {
                                                name = "NONE";
                                                value = "NONE";
                                                default = 1;
                                        };
                                };
                        };
                        class faction3
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTION";
                                description = "$STR_ALIVE_OPCOM_FACTION_COMMENT";
                                class Values
                                {
                                        class NATO
                                        {
                                                name = "NATO";
                                                value = "BLU_F";
                                        };
                                        class NATOPACIFIC
                                        {
                                                name = "NATO (Pacific)";
                                                value = "BLU_T_F";
                                        };
                                        class NATO_CTRG
                                        {
                                                name = "NATO (CTRG)";
                                                value = "BLU_CTRG_F";
                                        };
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class IRANPACIFIC
                                        {
                                                name = "CSAT (Pacific)";
                                                value = "OPF_T_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
                                        };
                                        class SYNDIKAT
                                        {
                                                name = "Syndikat";
                                                value = "IND_C_F";
                                        };
                                        class REBELS_BLU
                                        {
                                                name = "REBELS BLU";
                                                value = "BLU_G_F";
                                        };
                                        class REBELS_OPF
                                        {
                                                name = "REBELS RED";
                                                value = "OPF_G_F";
                                        };
                                        class NONE
                                        {
                                                name = "NONE";
                                                value = "NONE";
                                                default = 1;
                                        };
                                };
                        };
                        class faction4
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTION";
                                description = "$STR_ALIVE_OPCOM_FACTION_COMMENT";
                                class Values
                                {
                                        class NATO
                                        {
                                                name = "NATO";
                                                value = "BLU_F";
                                        };
                                        class NATOPACIFIC
                                        {
                                                name = "NATO (Pacific)";
                                                value = "BLU_T_F";
                                        };
                                        class NATO_CTRG
                                        {
                                                name = "NATO (CTRG)";
                                                value = "BLU_CTRG_F";
                                        };
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class IRANPACIFIC
                                        {
                                                name = "CSAT (Pacific)";
                                                value = "OPF_T_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
                                        };
                                        class SYNDIKAT
                                        {
                                                name = "Syndikat";
                                                value = "IND_C_F";
                                        };
                                        class REBELS_BLU
                                        {
                                                name = "REBELS BLU";
                                                value = "BLU_G_F";
                                        };
                                        class REBELS_OPF
                                        {
                                                name = "REBELS RED";
                                                value = "OPF_G_F";
                                        };
                                        class NONE
                                        {
                                                name = "NONE";
                                                value = "NONE";
                                                default = 1;
                                        };
                                };
                        };
                        class factions
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTIONS";
                                description = "$STR_ALIVE_OPCOM_FACTIONS_COMMENT";
                                defaultValue = "";
                        };
                        class simultanObjectives
                        {
                                displayName = "$STR_ALIVE_OPCOM_SIMULTAN";
                                description = "$STR_ALIVE_OPCOM_SIMULTAN_COMMENT";
                                typeName = "NUMBER";
                                defaultValue = 10;
                        };
                        class minAgents
                        {
                                displayName = "$STR_ALIVE_OPCOM_MINAGENTS";
                                description = "$STR_ALIVE_OPCOM_MINAGENTS_COMMENT";
                                typeName = "NUMBER";
                                defaultValue = 2;
                        };
                };
                class ModuleDescription
                {
                    //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_OPCOM_COMMENT",
                            "",
                            "$STR_ALIVE_OPCOM_USAGE"
                    };
                    sync[] = {"ALiVE_civ_placement","ALiVE_mil_placement","ALiVE_mil_intelligence","ALiVE_mil_logistics"}; // Array of synced entities (can contain base classes)

                    class ALiVE_civ_placement
                    {
                        description[] = { // Multi-line descriptions are supported
                            "$STR_ALIVE_CP_COMMENT",
                            "",
                            "$STR_ALIVE_CP_USAGE"
                        };
                        position = 0; // Position is taken into effect
                        direction = 0; // Direction is taken into effect
                        optional = 1; // Synced entity is optional
                        duplicate = 1; // Multiple entities of this type can be synced
                    };
                    class ALiVE_mil_placement
                    {
                        description[] = { // Multi-line descriptions are supported
                            "$STR_ALIVE_MP_COMMENT",
                            "",
                            "$STR_ALIVE_MP_USAGE"
                        };
                        position = 0; // Position is taken into effect
                        direction = 0; // Direction is taken into effect
                        optional = 1; // Synced entity is optional
                        duplicate = 1; // Multiple entities of this type can be synced
                    };
                    class ALiVE_mil_logistics
                    {
                        description[] = { // Multi-line descriptions are supported
                            "$STR_ALIVE_ML_COMMENT",
                            "",
                            "$STR_ALIVE_ML_USAGE"
                        };
                        position = 0; // Position is taken into effect
                        direction = 0; // Direction is taken into effect
                        optional = 1; // Synced entity is optional
                        duplicate = 1; // Multiple entities of this type can be synced
                    };
                };
        };
};
