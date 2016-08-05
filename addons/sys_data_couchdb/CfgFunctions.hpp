class cfgFunctions {
        class PREFIX {
            class COMPONENT {
                class writeData_couchdb {
                    description = "Writes a record/document to a data source";
										file = PATHTO_FUNC(writeData);
                    recompile = RECOMPILE;
                };
                class bulkWriteData_couchdb {
                    description = "Writes a record/document to a data source";
										file = PATHTO_FUNC(bulkWriteData);
                    recompile = RECOMPILE;
                };
                class updateData_couchdb {
                    description = "Updates a record stored in a data source";
										file = PATHTO_FUNC(updateData);
                    recompile = RECOMPILE;
                };
                class readData_couchdb {
                    description = "Reads a record/document from a data source";
										file = PATHTO_FUNC(readData);
                    recompile = RECOMPILE;
                };
                class bulkReadData_couchdb {
                    description = "Bulk Reads a set of records/documents from a data source";
										file = PATHTO_FUNC(bulkReadData);
                    recompile = RECOMPILE;
                };
                class convertData_couchdb {
                    description = "Decomposes objects/data to a suitable formatted text string for couchdb";
										file = PATHTO_FUNC(convertData);
                    recompile = RECOMPILE;
                };
                class restoreData_couchdb {
                    description = "Composes objects/data from a couchdb formatted text string";
										file = PATHTO_FUNC(restoreData);
                    recompile = RECOMPILE;
                };
                class saveData_couchdb {
                    description = "Saves all records/documents to a data source";
										file = PATHTO_FUNC(saveData);
                    recompile = RECOMPILE;
                };
                class bulkSaveData_couchdb {
                    description = "Saves all records/documents to a data source";
										file = PATHTO_FUNC(bulkSaveData);
                    recompile = RECOMPILE;
                };
                class loadData_couchdb {
                    description = "Loads all records/documents from a table/document set stored in a data source";
										file = PATHTO_FUNC(loadData);
                    recompile = RECOMPILE;
                };
                class bulkLoadData_couchdb {
                    description = "Bulk Loads all records/documents from a table/document set stored in a data source";
										file = PATHTO_FUNC(bulkLoadData);
                    recompile = RECOMPILE;
                };
                class deleteData_couchdb {
                    description = "Deletes a record stored in a data source";
										file = PATHTO_FUNC(deleteData);
                    recompile = RECOMPILE;
                };

            };
        };
};
