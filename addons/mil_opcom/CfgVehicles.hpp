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
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
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
                                		class NONE
                                        {
                                                name = "NONE";
                                                value = "NONE";
                                                default = 1;
                                        };
                                        class NATO
                                        {
                                                name = "NATO";
                                                value = "BLU_F";
                                        };
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
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
                                };
                        };
                        class faction3
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTION";
                                description = "$STR_ALIVE_OPCOM_FACTION_COMMENT";
                                class Values
                                {
                                		class NONE
                                        {
                                                name = "NONE";
                                                value = "NONE";
                                                default = 1;
                                        };
                                        class NATO
                                        {
                                                name = "NATO";
                                                value = "BLU_F";
                                        };
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
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
                                };
                        };
                        class faction4
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTION";
                                description = "$STR_ALIVE_OPCOM_FACTION_COMMENT";
                                class Values
                                {
                                		class NONE
                                        {
                                                name = "NONE";
                                                value = "NONE";
                                                default = 1;
                                        };
                                        class NATO
                                        {
                                                name = "NATO";
                                                value = "BLU_F";
                                        };
                                        class IRAN
                                        {
                                                name = "CSAT";
                                                value = "OPF_F";
                                        };
                                        class GREEKARMY
                                        {
                                                name = "AAF";
                                                value = "IND_F";
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
                                };
                        };
                        class factions
                        {
                                displayName = "$STR_ALIVE_OPCOM_FACTIONS";
                                description = "$STR_ALIVE_OPCOM_FACTIONS_COMMENT";
                                defaultValue = "";
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
