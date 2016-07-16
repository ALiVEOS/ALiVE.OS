class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_TRANSPORT";
                function = "ALIVE_fnc_TRANSPORTInit";
                author = MODULE_AUTHOR;
                functionPriority = 163;
                isGlobal = 2;
                icon = "x\alive\addons\sup_transport\icon_sup_transport.paa";
                picture = "x\alive\addons\sup_transport\icon_sup_transport.paa";
                class Arguments
                {
                        class transport_callsign
                        {
                                displayName = "$STR_ALIVE_TRANSPORT_CALLSIGN";
                                description = "$STR_ALIVE_TRANSPORT_CALLSIGN_DESC";
                                defaultValue ="RODEO TWO";
                        };
                        class transport_type
                        {
                                displayName = "$STR_ALIVE_TRANSPORT_TYPE";
                                description = "$STR_ALIVE_TRANSPORT_TYPE_DESC";
                                defaultValue="B_Heli_Transport_01_camo_F";
                        };
                        class transport_height
                        {
                                displayName = "$STR_ALIVE_TRANSPORT_HEIGHT";
                                description = "$STR_ALIVE_TRANSPORT_HEIGHT_DESC";
                                defaultValue=0;
                        };
                        class transport_code
                        {
                                displayName = "$STR_ALIVE_TRANSPORT_CODE";
                                description = "$STR_ALIVE_TRANSPORT_CODE_DESC";
                                defaultValue="";
                        };
                        class transport_slingloading
                        {
                                displayName = "$STR_ALIVE_TRANSPORT_SLINGLOADING";
                                description = "$STR_ALIVE_TRANSPORT_SLINGLOADING_DESC";
                                typeName = "BOOL";
                                class Values
                                {

                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;

                                        };
                                };
                        };

                        class transport_containers
                        {
                                displayName = "$STR_ALIVE_TRANSPORT_CONTAINERS";
                                description = "$STR_ALIVE_TRANSPORT_CONTAINERS_DESC";
                                typeName = "NUMBER";
                                defaultValue=0;
                        };
                };
                class ModuleDescription
                {
                        //description = "$STR_ALIVE_TRANSPORT_COMMENT"; // Short description, will be formatted as structured text
                        description[] = {
                                "$STR_ALIVE_TRANSPORT_COMMENT",
                                "",
                                "$STR_ALIVE_TRANSPORT_USAGE"
                        };
                };
        };
};
