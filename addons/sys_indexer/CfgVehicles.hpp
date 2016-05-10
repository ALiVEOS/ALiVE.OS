class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_INDEXER";
				function = "ALIVE_fnc_indexerInit";
                functionPriority = 1;
                isGlobal = 1;
                isPersistent = 1;
                icon = "x\alive\addons\sys_indexer\icon_sys_indexer.paa";
                picture = "x\alive\addons\sys_indexer\icon_sys_indexer.paa";
                 class Arguments
                {
                        class customStatic
                        {
                                displayName = "$STR_ALIVE_INDEXER_STATICDATA";
                                description = "$STR_ALIVE_INDEXER_STATICDATA_COMMENT";
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
                        class mapPath
                        {
                                displayName = "$STR_ALIVE_INDEXER_MAPPATH";
                                description = "$STR_ALIVE_INDEXER_MAPPATH_COMMENT";
                                defaultValue = "@CustomMap\Addons\custom_map.pbo";
                        };
                        class customMapBound
                        {
                                typeName = "NUMBER";
                                displayName = "$STR_ALIVE_INDEXER_MAPBOUND";
                                description = "$STR_ALIVE_INDEXER_MAPBOUND_COMMENT";
                                defaultValue = 0;
                        };
                };

        };
};

