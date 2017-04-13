class cfgFunctions {
        class PREFIX {
            class COMPONENT {
                class writeData_pns {
                    description = "Writes a record/document to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_writeData.sqf";
                    RECOMPILE;
                };
                class bulkWriteData_pns {
                    description = "Writes a record/document to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkWriteData.sqf";
                    RECOMPILE;
                };
                class updateData_pns {
                    description = "Updates a record stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_updateData.sqf";
                    RECOMPILE;
                };
                class readData_pns {
                    description = "Reads a record/document from a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_readData.sqf";
                    RECOMPILE;
                };
                class bulkReadData_pns {
                    description = "Bulk Reads a set of records/documents from a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkReadData.sqf";
                    RECOMPILE;
                };
                class convertData_pns {
                    description = "Decomposes objects/data to a suitable formatted text string for pns";
                    file = "\x\alive\addons\sys_data_pns\fnc_convertData.sqf";
                    RECOMPILE;
                };
                class restoreData_pns {
                    description = "Composes objects/data from a pns formatted text string";
                    file = "\x\alive\addons\sys_data_pns\fnc_restoreData.sqf";
                    RECOMPILE;
                };
                class saveData_pns {
                    description = "Saves all records/documents to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_saveData.sqf";
                    RECOMPILE;
                };
                class bulkSaveData_pns {
                    description = "Saves all records/documents to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkSaveData.sqf";
                    RECOMPILE;
                };
                class loadData_pns {
                    description = "Loads all records/documents from a table/document set stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_loadData.sqf";
                    RECOMPILE;
                };
                class bulkLoadData_pns {
                    description = "Bulk Loads all records/documents from a table/document set stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkLoadData.sqf";
                    RECOMPILE;
                };
                class deleteData_pns {
                    description = "Deletes a record stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_deleteData.sqf";
                    RECOMPILE;
                };
            };
        };
};
