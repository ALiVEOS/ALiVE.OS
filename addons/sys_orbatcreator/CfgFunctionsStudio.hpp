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

            class fsDataPool {
                description = "The faction gear pools: add, rename, slot, items, delete, use";
                file = "\x\alive\addons\sys_orbatcreator\model\fnc_fsDataPool.sqf";
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

            class fsStudioStage {
                description = "The stage the studio preview stands on";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioStage.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioPreview {
                description = "The preview body on the stage";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioPreview.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioCamera {
                description = "The studio orbit camera";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioCamera.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioTabUnits {
                description = "The studio Units tab";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTabUnits.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioBrowser {
                description = "The studio class browser";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioBrowser.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioTabFaction {
                description = "The studio Faction tab";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTabFaction.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioPrompt {
                description = "The studio question popup";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioPrompt.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioHelp {
                description = "The studio help window";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioHelp.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioTextBox {
                description = "The studio text popup";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTextBox.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioFactionPicker {
                description = "The studio faction import popup";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioFactionPicker.sqf";
                ALIVE_RECOMPILE;
            };
            class fsStudioPools {
                description = "The studio gear pools popup";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioPools.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioCargo {
                description = "The studio vehicle cargo popup";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioCargo.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioArsenal {
                description = "The studio Arsenal round trip";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioArsenal.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioLoadoutText {
                description = "A loadout as a short summary";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioLoadoutText.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioTabVehicles {
                description = "The studio Vehicles tab";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTabVehicles.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioTabGroups {
                description = "The studio Groups tab";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTabGroups.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenQuote {
                description = "Quotes free text for a config file";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenQuote.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenArray {
                description = "Writes a value as config array text";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenArray.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenCheck {
                description = "Checks the brace and quote balance of generated config";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenCheck.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenLoadoutArrays {
                description = "Turns a loadout into soldier config arrays";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenLoadoutArrays.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenDeps {
                description = "Works out the addons an exported faction needs";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenDeps.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenPlan {
                description = "Plans a faction export: names, order and problems";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenPlan.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenMan {
                description = "Writes one exported soldier class";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenMan.sqf";
                ALIVE_RECOMPILE;
            };

            class fsPoolRoll {
                description = "A loadout with a weighted random pick from each gear pool";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsPoolRoll.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenTree {
                description = "Writes nested config classes for the turret and pylon stubs";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenTree.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenVehicle {
                description = "Writes one exported vehicle class";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenVehicle.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenGroups {
                description = "Writes the exported CfgGroups block";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenGroups.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenConfig {
                description = "Writes the whole config.cpp of an exported faction";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenConfig.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenModCpp {
                description = "Writes the mod.cpp of an exported faction";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenModCpp.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenReadme {
                description = "Writes the README of an exported faction";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenReadme.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenRebuildBat {
                description = "Writes the rebuild file of an exported faction";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenRebuildBat.sqf";
                ALIVE_RECOMPILE;
            };

            class fsExportToolsInfo {
                description = "Asks the alive_tools extension for its version and folder";
                file = "\x\alive\addons\sys_orbatcreator\export\fnc_fsExportToolsInfo.sqf";
                ALIVE_RECOMPILE;
            };

            class fsExportMod {
                description = "Writes an exported faction mod or copies its config";
                file = "\x\alive\addons\sys_orbatcreator\export\fnc_fsExportMod.sqf";
                ALIVE_RECOMPILE;
            };

            class fsStudioTabAlive {
                description = "The studio ALiVE tab";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTabAlive.sqf";
                ALIVE_RECOMPILE;
            };
            class fsStudioTabExport {
                description = "The studio Export tab";
                file = "\x\alive\addons\sys_orbatcreator\studio\fnc_fsStudioTabExport.sqf";
                ALIVE_RECOMPILE;
            };

            class fsAutoRole {
                description = "A studio man's part in AUTO GROUPS";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAutoRole.sqf";
                ALIVE_RECOMPILE;
            };

            class fsAutoKind {
                description = "A studio vehicle's kind and seats";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAutoKind.sqf";
                ALIVE_RECOMPILE;
            };

            class fsAutoGroups {
                description = "AUTO GROUPS: the groups ALiVE draws from";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAutoGroups.sqf";
                ALIVE_RECOMPILE;
            };

            class fsImportCompiled {
                description = "A faction from ALiVE's Faction Compiler to a studio faction";
                file = "\x\alive\addons\sys_orbatcreator\import\fnc_fsImportCompiled.sqf";
                ALIVE_RECOMPILE;
            };
            class fsAlivePreview {
                description = "What ALiVE will read from a faction's export, row by row";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAlivePreview.sqf";
                ALIVE_RECOMPILE;
            };
            class fsAliveLive {
                description = "What ALiVE has read from the loaded export of a faction";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAliveLive.sqf";
                ALIVE_RECOMPILE;
            };
            class fsAliveCheck {
                description = "How each ALiVE category stands for a faction";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAliveCheck.sqf";
                ALIVE_RECOMPILE;
            };

            class fsAliveCrates {
                description = "A faction's supply crates";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAliveCrates.sqf";
                ALIVE_RECOMPILE;
            };

            class fsAlivePicks {
                description = "The lists a faction declares to ALiVE";
                file = "\x\alive\addons\sys_orbatcreator\alive\fnc_fsAlivePicks.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenCargo {
                description = "The four Transport classes of a vehicle or crate";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenCargo.sqf";
                ALIVE_RECOMPILE;
            };

            class fsGenAlive {
                description = "The CfgALiVEFactions block of an export";
                file = "\x\alive\addons\sys_orbatcreator\gen\fnc_fsGenAlive.sqf";
                ALIVE_RECOMPILE;
            };
