class cfgFunctions {
        class PREFIX {
            class COMPONENT {
                class writeData_pns {
                    description = "Writes a record/document to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_writeData.sqf";
                    ALIVE_RECOMPILE;
                };
                class bulkWriteData_pns {
                    description = "Writes a record/document to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkWriteData.sqf";
                    ALIVE_RECOMPILE;
                };
                class updateData_pns {
                    description = "Updates a record stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_updateData.sqf";
                    ALIVE_RECOMPILE;
                };
                class readData_pns {
                    description = "Reads a record/document from a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_readData.sqf";
                    ALIVE_RECOMPILE;
                };
                class bulkReadData_pns {
                    description = "Bulk Reads a set of records/documents from a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkReadData.sqf";
                    ALIVE_RECOMPILE;
                };
                class convertData_pns {
                    description = "Decomposes objects/data to a suitable formatted text string for pns";
                    file = "\x\alive\addons\sys_data_pns\fnc_convertData.sqf";
                    ALIVE_RECOMPILE;
                };
                class restoreData_pns {
                    description = "Composes objects/data from a pns formatted text string";
                    file = "\x\alive\addons\sys_data_pns\fnc_restoreData.sqf";
                    ALIVE_RECOMPILE;
                };
                class saveData_pns {
                    description = "Saves all records/documents to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_saveData.sqf";
                    ALIVE_RECOMPILE;
                };
                class bulkSaveData_pns {
                    description = "Saves all records/documents to a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkSaveData.sqf";
                    ALIVE_RECOMPILE;
                };
                class loadData_pns {
                    description = "Loads all records/documents from a table/document set stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_loadData.sqf";
                    ALIVE_RECOMPILE;
                };
                class bulkLoadData_pns {
                    description = "Bulk Loads all records/documents from a table/document set stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_bulkLoadData.sqf";
                    ALIVE_RECOMPILE;
                };
                class deleteData_pns {
                    description = "Deletes a record stored in a data source";
                    file = "\x\alive\addons\sys_data_pns\fnc_deleteData.sqf";
                    ALIVE_RECOMPILE;
                };
                class autosave_pns {
                    description = "Saves mission state in given interval to local profileNameSpace";
                    file = "\x\alive\addons\sys_data_pns\fnc_autosave.sqf";
                    ALIVE_RECOMPILE;
                };      
            };
        };
};
