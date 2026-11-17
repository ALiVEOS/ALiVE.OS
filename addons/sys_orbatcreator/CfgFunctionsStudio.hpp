// ORBAT Creator studio functions, included inside class COMPONENT of CfgFunctions.hpp.
// Author: Jman

            class fsDataSchema {
                description = "Schema table of the studio faction model";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataSchema.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataNew {
                description = "Makes a new studio faction with defaults";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataNew.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataId {
                description = "Gives out the next id of a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataId.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataCheckValue {
                description = "Checks one value against one studio rule";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataCheckValue.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataLoadoutCheck {
                description = "Checks a getUnitLoadout array";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataLoadoutCheck.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataToPlain {
                description = "Studio faction to plain arrays";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataToPlain.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataFromPlain {
                description = "Plain arrays to a studio faction, with validation";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataFromPlain.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataMigrate {
                description = "Brings a plain studio faction up to the current schema";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataMigrate.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataToText {
                description = "Studio faction to share text";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataToText.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataParse {
                description = "Share text to a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataParse.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataStore {
                description = "Profile storage of studio factions";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataStore.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataTouch {
                description = "Marks the studio faction changed and saves when due";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataTouch.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataUnit {
                description = "Edits the units of a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataUnit.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataVehicle {
                description = "Edits the vehicles of a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataVehicle.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataGroup {
                description = "Edits the groups of a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataGroup.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataCategory {
                description = "Edits the Eden categories of a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataCategory.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataRefs {
                description = "Finds and removes uses of a unit or vehicle id";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataRefs.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataClassName {
                description = "Builds and checks studio class names";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataClassName.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataFileRead {
                description = "Reads a studio faction data file";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataFileRead.sqf";
                ALIVE_RECOMPILE;
            };

            class fsDataFileWrite {
                description = "Writes a studio faction data file";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataFileWrite.sqf";
                ALIVE_RECOMPILE;
            };

            class fsIndexBuild {
                description = "Builds the studio class index";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsIndexBuild.sqf";
                ALIVE_RECOMPILE;
            };

            class fsIndexFilter {
                description = "Picks rows from the studio class index";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsIndexFilter.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportFactionList {
                description = "Lists config factions with their counts";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportFactionList.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportFaction {
                description = "Imports a config faction into a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportFaction.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportBase {
                description = "Finds the real base class of an exported class";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportBase.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportMan {
                description = "Imports a man class without spawning it";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportMan.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportOldLoadout {
                description = "Reads the loadout of a classic ORBAT export";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportOldLoadout.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportVehicle {
                description = "Imports a vehicle class";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportVehicle.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportGroups {
                description = "Imports the groups of a config faction";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportGroups.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportMerge {
                description = "Merges an incoming faction with de-duplication";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportMerge.sqf";
                ALIVE_RECOMPILE;
            };

            class fsEditorChoice {
                description = "Says which editor an ORBAT Creator module opens";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsEditorChoice.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioStart {
                description = "Starts the studio once per mission";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioStart.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioReopen {
                description = "Brings the studio back on an existing session";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioReopen.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioOpen {
                description = "Creates the studio display";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioOpen.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioClose {
                description = "Closes, suspends or tears down the studio";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioClose.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioKeys {
                description = "Key handler of the studio display";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioKeys.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioTab {
                description = "Shows one tab of the studio";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTab.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioStatus {
                description = "Status line of the studio";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioStatus.sqf";
                ALIVE_RECOMPILE;
            };
