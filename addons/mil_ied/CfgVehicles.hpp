class CfgVehicles {
        class ModuleAliveBase;
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
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_IED_DEBUG";
                                description = "$STR_ALIVE_IED_DEBUG_COMMENT";
                                typeName = "BOOL";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                                default = 1;
                                        };
                                };
                        };
                        class persistence
                        {
                                displayName = "$STR_ALIVE_IED_PERSISTENCE";
                                description = "$STR_ALIVE_IED_PERSISTENCE_COMMENT";
                                typeName = "BOOL";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                                default = 1;
                                        };
                                };
                        };
                        class taor
                        {
                                displayName = "$STR_ALIVE_IED_TAOR";
                                description = "$STR_ALIVE_IED_TAOR_COMMENT";
                                defaultValue = "";
                        };
                        class blacklist
                        {
                                displayName = "$STR_ALIVE_IED_BLACKLIST";
                                description = "$STR_ALIVE_IED_BLACKLIST_COMMENT";
                                defaultValue = "";
                        };
                        class IED_Threat
                        {
                                displayName = "$STR_ALIVE_ied_IED_Threat";
                                description = "$STR_ALIVE_ied_IED_Threat_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class None
                                        {
                                                name = "None";
                                                value = 0;
                                                default = 1;
                                        };
                                        class Low
                                        {
                                                name = "Low";
                                                value = 50;
                                        };
                                        class Med
                                        {
                                                name = "Medium";
                                                value = 100;
                                        };
                                        class High
                                        {
                                                name = "High";
                                                value = 200;
                                        };
                                        class Extreme
                                        {
                                                name = "Extreme";
                                                value = 350;
                                        };
                                };
                        };
                        class IED_Starting_Threat
                        {
                                displayName = "$STR_ALIVE_ied_IED_Starting_Threat";
                                description = "$STR_ALIVE_ied_IED_Starting_Threat_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class None
                                        {
                                                name = "None";
                                                value = 0;
                                                default = 1;
                                        };
                                        class Low
                                        {
                                                name = "Low";
                                                value = 50;
                                        };
                                        class Med
                                        {
                                                name = "Medium";
                                                value = 100;
                                        };
                                        class High
                                        {
                                                name = "High";
                                                value = 200;
                                        };
                                        class Extreme
                                        {
                                                name = "Extreme";
                                                value = 350;
                                        };
                                };
                        };
                        class IED_Detection
                        {
                                displayName = "$STR_ALIVE_ied_IED_Detection";
                                description = "$STR_ALIVE_ied_IED_Detection_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class None
                                        {
                                                name = "None";
                                                value = 0;
                                        };
                                        class Text
                                        {
                                                name = "Text";
                                                value = 1;
                                                default = 1;
                                        };
                                        class Audio
                                        {
                                                name = "Audio";
                                                value = 2;
                                        };
                                };
                        };
                        class IED_Detection_Device
                        {
                                displayName = "$STR_ALIVE_IED_IED_Detection_Device";
                                description = "$STR_ALIVE_IED_IED_Detection_Device_COMMENT";
                                defaultValue = "MineDetector";
                        };
                        class Bomber_Threat
                        {
                                displayName = "$STR_ALIVE_ied_Bomber_Threat";
                                description = "$STR_ALIVE_ied_Bomber_Threat_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class None
                                        {
                                                name = "None";
                                                value = 0;
                                                default = 1;
                                        };
                                        class Low
                                        {
                                                name = "Low";
                                                value = 10;
                                        };
                                        class Med
                                        {
                                                name = "Medium";
                                                value = 20;
                                        };
                                        class High
                                        {
                                                name = "High";
                                                value = 30;
                                        };
                                        class Extreme
                                        {
                                                name = "Extreme";
                                                value = 50;
                                        };
                                };
                        };
                        class Bomber_Type
                        {
                                displayName = "$STR_ALIVE_IED_Bomber_Type";
                                description = "$STR_ALIVE_IED_BOMBER_TYPE_COMMENT";
                                defaultValue = "";
                        };
                        class VB_IED_Threat
                        {
                                displayName = "$STR_ALIVE_ied_VB_IED_Threat";
                                description = "$STR_ALIVE_ied_VB_IED_Threat_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class None
                                        {
                                                name = "None";
                                                value = 0;
                                                default = 1;
                                        };
                                        class Low
                                        {
                                                name = "Low";
                                                value = 10;
                                        };
                                        class Med
                                        {
                                                name = "Medium";
                                                value = 20;
                                        };
                                        class High
                                        {
                                                name = "High";
                                                value = 50;
                                        };
                                        class Extreme
                                        {
                                                name = "Extreme";
                                                value = 70;
                                        };
                                };
                        };
                        class VB_IED_Side
                        {
                                displayName = "$STR_ALIVE_ied_VB_IED_Side";
                                description = "$STR_ALIVE_ied_VB_IED_Side_COMMENT";
                                typeName = "STRING";
                                class Values
                                {
                                        class Civ
                                        {
                                                name = "CIV";
                                                value = "CIV";
                                                default = 1;
                                        };
                                        class East
                                        {
                                                name = "EAST";
                                                value = "EAST";
                                        };
                                        class West
                                        {
                                                name = "WEST";
                                                value = "WEST";
                                        };
                                        class Ind
                                        {
                                                name = "IND";
                                                value = "GUER";
                                        };
                                };
                        };
                        class Locs_IED
                        {
                                displayName = "$STR_ALIVE_ied_Locs_IED";
                                description = "$STR_ALIVE_ied_Locs_IED_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class Random
                                        {
                                                name = "Random";
                                                value = 0;
                                                default = 1;
                                        };
                                        class Occupied
                                        {
                                                name = "Enemy Occupied";
                                                value = 1;
                                        };
                                        class Unoccupied
                                        {
                                                name = "Unoccupied";
                                                value = 2;
                                        };
                                };
                        };
                        class thirdParty
                        {
                                displayName = "$STR_ALIVE_IED_3RDPARTY";
                                description = "$STR_ALIVE_IED_3RDPARTY_COMMENT";
                                typeName = "BOOL";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                                default = 1;
                                        };
                                };
                        };
                       class roadIEDClasses
                        {
                                displayName = "$STR_ALIVE_IED_ROAD_IED_CLASSES";
                                description = "$STR_ALIVE_IED_CLASSES_COMMENT";
                                defaultValue = "ALIVE_IEDUrbanSmall_Remote_Ammo,ALIVE_IEDLandSmall_Remote_Ammo,ALIVE_IEDUrbanBig_Remote_Ammo,ALIVE_IEDLandBig_Remote_Ammo";
                        };
                        class urbanIEDClasses
                        {
                                displayName = "$STR_ALIVE_IED_URBAN_IED_CLASSES";
                                description = "$STR_ALIVE_IED_CLASSES_COMMENT";
                                defaultValue = "ALIVE_IEDUrbanSmall_Remote_Ammo,ALIVE_IEDUrbanBig_Remote_Ammo,Land_JunkPile_F,Land_GarbageContainer_closed_F,Land_GarbageBags_F,Land_Tyres_F,Land_GarbagePallet_F,Land_Basket_F,Land_Sack_F,Land_Sacks_goods_F,Land_Sacks_heap_F,Land_BarrelTrash_F";
                        };
                        class clutterClasses
                        {
                                displayName = "$STR_ALIVE_IED_CLUTTER_CLASSES";
                                description = "$STR_ALIVE_IED_CLASSES_COMMENT";
                                defaultValue = "Land_JunkPile_F,Land_GarbageContainer_closed_F,Land_GarbageBags_F,Land_Tyres_F,Land_GarbagePallet_F,Land_Basket_F,Land_Sack_F,Land_Sacks_goods_F,Land_Sacks_heap_F,Land_BarrelTrash_F";
                        };
                };
        };

        class Thing;
        class Land_Sack_F;
        class ALiVE_IED : Thing {
            author = "ALiVE Mod Team";
            _generalMacro = "ALiVE_IED";
            model = "\A3\Weapons_F\empty.p3d";
            icon = "iconObject";
            vehicleClass = "Objects";
            destrType = "DestructTent";
            cost = 250;
            ace_minedetector_detectable = 1;
        };

        class ALIVE_IEDUrbanSmall_Remote_Ammo : ALiVE_IED {
            scope = 2;
            scopeCurator = 2;
            displayName = "";
            model = "\A3\Weapons_F\Explosives\IED_urban_small";
        };

        class ALIVE_IEDLandSmall_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo {
            model = "\A3\Weapons_F\Explosives\IED_land_small";
        };

        class ALIVE_IEDUrbanBig_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo {
            model = "\A3\Weapons_F\Explosives\IED_urban_big";
        };

        class ALIVE_IEDLandBig_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo {
            model = "\A3\Weapons_F\Explosives\IED_land_big";
        };

        class ALIVE_DemoCharge_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo {
            model = "\A3\Weapons_F\explosives\c4_charge_small";
        };

        class ALIVE_SatchelCharge_Remote_Ammo : ALIVE_IEDUrbanSmall_Remote_Ammo {
            model = "\A3\Weapons_F\Explosives\satchel";
        };

};
