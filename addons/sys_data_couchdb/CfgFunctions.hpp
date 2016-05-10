class cfgFunctions {
        class PREFIX {
			class COMPONENT {
				class writeData_couchdb {
					description = "Writes a record/document to a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_writeData.sqf";
					recompile = RECOMPILE;
				};
				class bulkWriteData_couchdb {
					description = "Writes a record/document to a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_bulkWriteData.sqf";
					recompile = RECOMPILE;
				};
				class updateData_couchdb {
					description = "Updates a record stored in a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_updateData.sqf";
					recompile = RECOMPILE;
				};
				class readData_couchdb {
					description = "Reads a record/document from a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_readData.sqf";
					recompile = RECOMPILE;
				};
				class bulkReadData_couchdb {
					description = "Bulk Reads a set of records/documents from a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_bulkReadData.sqf";
					recompile = RECOMPILE;
				};
				class convertData_couchdb {
					description = "Decomposes objects/data to a suitable formatted text string for couchdb";
					file = "\x\alive\addons\sys_data_couchdb\fnc_convertData.sqf";
					recompile = RECOMPILE;
				};
				class restoreData_couchdb {
					description = "Composes objects/data from a couchdb formatted text string";
					file = "\x\alive\addons\sys_data_couchdb\fnc_restoreData.sqf";
					recompile = RECOMPILE;
				};
				class saveData_couchdb {
					description = "Saves all records/documents to a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_saveData.sqf";
					recompile = RECOMPILE;
				};
				class bulkSaveData_couchdb {
					description = "Saves all records/documents to a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_bulkSaveData.sqf";
					recompile = RECOMPILE;
				};
				class loadData_couchdb {
					description = "Loads all records/documents from a table/document set stored in a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_loadData.sqf";
					recompile = RECOMPILE;
				};
				class bulkLoadData_couchdb {
					description = "Bulk Loads all records/documents from a table/document set stored in a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_bulkLoadData.sqf";
					recompile = RECOMPILE;
				};
				class deleteData_couchdb {
					description = "Deletes a record stored in a data source";
					file = "\x\alive\addons\sys_data_couchdb\fnc_deleteData.sqf";
					recompile = RECOMPILE;
				};

            };
        };
};
