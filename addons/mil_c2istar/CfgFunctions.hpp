class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class C2ISTAR {
                description = "The main class";
                file = "\x\alive\addons\mil_c2istar\fnc_C2ISTAR.sqf";
                ALIVE_RECOMPILE;
            };
            class C2ISTARInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\mil_c2istar\fnc_C2ISTARInit.sqf";
                ALIVE_RECOMPILE;
            };
            class C2MenuDef {
                description = "The module menu definition";
                file = "\x\alive\addons\mil_c2istar\fnc_C2MenuDef.sqf";
                ALIVE_RECOMPILE;
            };
            class C2TabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\mil_c2istar\fnc_C2TabletOnAction.sqf";
                ALIVE_RECOMPILE;
            };
            class C2TabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\mil_c2istar\fnc_C2TabletOnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class C2TabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\mil_c2istar\fnc_C2TabletOnUnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class C2TabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\mil_c2istar\fnc_C2TabletEventToClient.sqf";
                ALIVE_RECOMPILE;
            };
            class C2OnPlayerConnected {
                description = "On player connected handler";
                file = "\x\alive\addons\mil_c2istar\fnc_C2OnPlayerConnected.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHandler {
                description = "Task Handler";
                file = "\x\alive\addons\mil_c2istar\fnc_taskHandler.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHandlerClient {
                description = "Task Handler Client";
                file = "\x\alive\addons\mil_c2istar\fnc_taskHandlerClient.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHandlerEventToClient {
                description = "Task Handler Event To Client";
                file = "\x\alive\addons\mil_c2istar\fnc_taskHandlerEventToClient.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHandlerLoadData {
                description = "Task Handler Load Data";
                file = "\x\alive\addons\mil_c2istar\fnc_taskHandlerLoadData.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHandlerSaveData {
                description = "Task Handler Save Data";
                file = "\x\alive\addons\mil_c2istar\fnc_taskHandlerSaveData.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetSideCluster {
                description = "Utility get side cluster for tasks";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideCluster.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetSideSectorCompositionPosition {
                description = "Utility get side sector for tasks";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideSectorCompositionPosition.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetSideSectorVehicles {
                description = "Utility get side sector that contains vehicles";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideSectorVehicles.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetRandomSideVehicleFromSector {
                description = "Utility get a random vehicle for a side from a sector";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetRandomSideVehicleFromSector.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetSideSectorEntities {
                description = "Utility get side sector that contains entities";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideSectorEntities.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetRandomSideEntityFromSector {
                description = "Utility get a random vehicle for a side from a sector";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetRandomSideEntityFromSector.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetSectorPosition {
                description = "Utility get position based on sector data";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSectorPosition.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHavePlayersReachedDestination {
                description = "Utility check if players have reached the destination";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskHavePlayersReachedDestination.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetClosestPlayerDistanceToDestination {
                description = "Utility get the distance of the closest player to the destination";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetClosestPlayerDistanceToDestination.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetClosestPlayerToPosition {
                description = "Utility get the closest player to the position";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetClosestPlayerToPosition.sqf";
                ALIVE_RECOMPILE;
            };
            class taskIsAreaClearOfEnemies {
                description = "Utility check if there are any enemies in the area";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskIsAreaClearOfEnemies.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateMarkersForPlayers {
                description = "Utility mark target position on map";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateMarkersForPlayers.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateMarker {
                description = "Utility create a local marker";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateMarker.sqf";
                ALIVE_RECOMPILE;
            };
            class taskRefreshAoMarker {
                description = "Show or hide the optional AO ellipse around a task based on its state";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskRefreshAoMarker.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetReturnPosition {
                description = "Resolve the friendly OPCOM main HQ position for tasks with a Return subtask";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetReturnPosition.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDeleteMarkersForPlayers {
                description = "Utility delete any markers for players";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskDeleteMarkersForPlayers.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDeleteMarkers {
                description = "Utility delete local markers";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskDeleteMarkers.sqf";
                ALIVE_RECOMPILE;
            };
            class taskLockProfiles {
                description = "Set busy=true on target profile IDs and register the lock against a taskID";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskLockProfiles.sqf";
                ALIVE_RECOMPILE;
            };
            class taskReleaseTaskLocks {
                description = "Clear busy=false on every profile locked under a taskID";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskReleaseTaskLocks.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateRadioBroadcastForPlayers {
                description = "Utility broadcast radio message for players";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateRadioBroadcastForPlayers.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetNearestLocationName {
                description = "Utility get the nearest location name";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetNearestLocationName.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateRandomMilLogisticsEvent {
                description = "Utility call in a random mil logistics event";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateRandomMilLogisticsEvent.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateVehicleInsertionForUnits {
                description = "Utility create an insertion vehicle for units";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateVehicleInsertionForUnits.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateVehicleExtractionForUnits {
                description = "Utility create an extraction vehicle for units";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateVehicleExtractionForUnits.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateExplosiveProjectile {
                description = "Utility create an explosive projectile orientate towards an object";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateExplosiveProjectile.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateBombardment {
                description = "Utility create a bombardment of explosives";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateBombardment.sqf";
                ALIVE_RECOMPILE;
            };
            class taskSpawnOnTopOf {
                description = "Utility spawn an object on top of another object";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskSpawnOnTopOf.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetNearPlayerVehicles {
                description = "Utility get near player vehicles";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetNearPlayerVehicles.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDoVehiclesHaveRoomForGroup {
                description = "Utility does any vehicle in an array of vehicles have room for a group";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskDoVehiclesHaveRoomForGroup.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetVehicleWithMaxRoom {
                description = "Utility get the vehicle with the biggest amount of room for passengers";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetVehicleWithMaxRoom.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHaveUnitsLoadedInVehicle {
                description = "Utility have all the units loaded into the vehicle";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskHaveUnitsLoadedInVehicle.sqf";
                ALIVE_RECOMPILE;
            };
            class taskHaveUnitsUnloadedFromVehicle {
                description = "Utility have all the units unloaded from the vehicle";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskHaveUnitsUnloadedFromVehicle.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetStateOfVehicleProfiles {
                description = "Utility have all the vehicle profiles been destroyed";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetStateOfVehicleProfiles.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetStateOfEntityProfiles {
                description = "Utility have all the entity profiles been destroyed";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetStateOfEntityProfiles.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDestroyEntityProfiles {
                description = "Utility destroy task-owned entity profiles";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskDestroyEntityProfiles.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetStateOfObjects {
                description = "Utility have all the entity profiles been destroyed";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetStateOfObjects.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCreateReward {
                description = "Utility create a reward for task completion";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateReward.sqf";
                ALIVE_RECOMPILE;
            };
            class taskApplyPopulationEffect {
                description = "Utility apply civilian hostility changes for Hearts and Minds tasks";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskApplyPopulationEffect.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetCivilianSupportState {
                description = "Utility get or create persistent civilian support state for a settlement";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetCivilianSupportState.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetCivilianCluster {
                description = "Utility get a civilian settlement cluster for Hearts and Minds tasking";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetCivilianCluster.sqf";
                ALIVE_RECOMPILE;
            };
            class taskSelectAutoGeneratedType {
                description = "Utility select an autogenerated task type with Hearts and Minds phase awareness";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskSelectAutoGeneratedType.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetCivilianClasses {
                description = "Utility return civilian unit classnames matching the configured Civilian Population faction (with vanilla CIV_F fallback) for Hearts and Minds spawn lists";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetCivilianClasses.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetHVTUnits {
                description = "Utility return HVT-grade unit classnames (officer / commander / leader / captain) from a faction, with chooseRandomUnits fallback";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetHVTUnits.sqf";
                ALIVE_RECOMPILE;
            };
            class taskUpdateCivilianSupportState {
                description = "Utility update persistent civilian support state for Hearts and Minds tasks";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskUpdateCivilianSupportState.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetCivicTaskProfile {
                description = "Utility get civic-state metadata for Hearts and Minds tasks";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetCivicTaskProfile.sqf";
                ALIVE_RECOMPILE;
            };
            class taskRefreshCivilianSupportState {
                description = "Utility derive compatibility support fields from the civic-state model";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskRefreshCivilianSupportState.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetCivicDebugDescription {
                description = "Utility build a civic-state debug summary for task descriptions";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetCivicDebugDescription.sqf";
                ALIVE_RECOMPILE;
            };
            class taskMaybeTriggerRetaliation {
                description = "Utility apply insurgent backlash against improving settlements";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskMaybeTriggerRetaliation.sqf";
                ALIVE_RECOMPILE;
            };
            class taskGetInsurgencyLocation {
                description = "Utility to find insurgency location from asymetrical opcoms";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetInsurgencyLocation.sqf";
                ALIVE_RECOMPILE;
            };
            class taskMilAssault {
                description = "Task Mil Assault";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskMilAssault.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCaptureObjective {
                description = "Task Capture Objective";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskCaptureObjective.sqf";
                ALIVE_RECOMPILE;
            };
            class taskMilDefence {
                description = "Task Mil Defence";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskMilDefence.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCivAssault {
                description = "Task Civ Assault";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskCivAssault.sqf";
                ALIVE_RECOMPILE;
            };
            class taskAssassination {
                description = "Task Assassination";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskAssassination.sqf";
                ALIVE_RECOMPILE;
            };
            class taskTransportInsertion {
                description = "Task Transport Insertion";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskTransportInsertion.sqf";
                ALIVE_RECOMPILE;
            };
            class taskRescue {
                description = "Task Rescue";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskRescue.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCSAR {
                description = "Task Combat Search and Rescue";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskCSAR.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDCA {
                description = "Task Defensive Counter Air";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskDCA.sqf";
                ALIVE_RECOMPILE;
            };
            class taskSEAD {
                description = "Task Suppression of Enemy Air Defenses";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskSEAD.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCAS {
                description = "Task Close Air Support";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskCAS.sqf";
                ALIVE_RECOMPILE;
            };
            class taskLaze {
                description = "Task Laze Target for Air Strike";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskLaze.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDestroyVehicles {
                description = "Task Destroy Vehicles";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskDestroyVehicles.sqf";
                ALIVE_RECOMPILE;
            };
            class taskProtectConvoy {
                description = "Task Protect Convoy";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskProtectConvoy.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDestroyBuilding {
                description = "Task Destroy Building";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskDestroyBuilding.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDestroyInfantry {
                description = "Task Destroy Infantry";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskDestroyInfantry.sqf";
                ALIVE_RECOMPILE;
            };
            class taskSabotageBuilding {
                description = "Task Destroy Infantry";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskSabotageBuilding.sqf";
                ALIVE_RECOMPILE;
            };
            class taskInsurgencyPatrol {
                description = "Task Insurgency Patrol";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskInsurgencyPatrol.sqf";
                ALIVE_RECOMPILE;
            };
            class taskInsurgencyDestroyAssets {
                description = "Task Insurgency Destroy Assets";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskInsurgencyDestroyAssets.sqf";
                ALIVE_RECOMPILE;
            };
            class taskOCA {
                description = "Task Offensive Counter Air";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskOCA.sqf";
                ALIVE_RECOMPILE;
            };
            class taskWiretap {
                description = "Task Wiretap";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskWiretap.sqf";
                ALIVE_RECOMPILE;
            };
            class taskRemoveIED {
                description = "Task IED Disposal (EOD)";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskRemoveIED.sqf";
                ALIVE_RECOMPILE;
            };
            class taskAidDelivery {
                description = "Task Aid Delivery";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskAidDelivery.sqf";
                ALIVE_RECOMPILE;
            };
            class taskSupplyConvoy {
                description = "Task Supply Convoy";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskSupplyConvoy.sqf";
                ALIVE_RECOMPILE;
            };
            class taskMeetLocalLeader {
                description = "Task Meet Local Leader";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskMeetLocalLeader.sqf";
                ALIVE_RECOMPILE;
            };
            class taskRepairCriticalService {
                description = "Task Repair Critical Service";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskRepairCriticalService.sqf";
                ALIVE_RECOMPILE;
            };
            class taskMedicalOutreach {
                description = "Task Medical Outreach";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskMedicalOutreach.sqf";
                ALIVE_RECOMPILE;
            };
            class taskCheckpointPartnership {
                description = "Task Checkpoint Partnership";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskCheckpointPartnership.sqf";
                ALIVE_RECOMPILE;
            };
            class taskInformantExfiltration {
                description = "Task Informant Exfiltration";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskInformantExfiltration.sqf";
                ALIVE_RECOMPILE;
            };
            class taskMarketReopening {
                description = "Task Market Reopening";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskMarketReopening.sqf";
                ALIVE_RECOMPILE;
            };
            class taskVIPEscort {
                description = "Task VIP Escort";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskVIPEscort.sqf";
                ALIVE_RECOMPILE;
            };
            class taskSecureCommunityEvent {
                description = "Task Secure Community Event";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskSecureCommunityEvent.sqf";
                ALIVE_RECOMPILE;
            };
            class taskDisable {
                description = "Disables generated and/or autogenerated tasks";
                file = "\x\alive\addons\mil_c2istar\fnc_taskDisable.sqf";
                ALIVE_RECOMPILE;
            };
            class playerOrders {
                description = "Player group OPCOM order helpers";
                file = "\x\alive\addons\mil_c2istar\fnc_playerOrders.sqf";
                ALIVE_RECOMPILE;
            };
            class taskRequest {
                description = "Requests an autogenerated task";
                file = "\x\alive\addons\mil_c2istar\fnc_taskRequest.sqf";
                ALIVE_RECOMPILE;
            };

            // ================================================================
            // COP — Common Operational Picture (commander intel map overlay)
            // ================================================================
            class COPConfig {
                description = "COP master configuration (tunable globals)";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPConfig.sqf";
                ALIVE_RECOMPILE;
            };
            class COPApplyTier {
                description = "COP tier preset — gates feature/layer flags by commanderIntelMode";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPApplyTier.sqf";
                ALIVE_RECOMPILE;
            };
            class COPLog {
                description = "COP four-tier logging dispatcher";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPLog.sqf";
                ALIVE_RECOMPILE;
            };
            class COPHelpers {
                description = "COP pure helper functions";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPHelpers.sqf";
                ALIVE_RECOMPILE;
            };
            class COPServer {
                description = "COP server-side polling loops (enemies + BFT + objectives)";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPServer.sqf";
                ALIVE_RECOMPILE;
            };
            class COPAsym {
                description = "COP asymmetric-layer polling loop";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPAsym.sqf";
                ALIVE_RECOMPILE;
            };
            class COPClient {
                description = "COP client init and map Draw EH attach";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPClient.sqf";
                ALIVE_RECOMPILE;
            };
            class COPRender {
                description = "COP client-side rendering functions";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPRender.sqf";
                ALIVE_RECOMPILE;
            };
            class COPDebug {
                description = "COP debug command router";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPDebug.sqf";
                ALIVE_RECOMPILE;
            };
            class COPInit {
                description = "COP entry-point orchestrator";
                file = "\x\alive\addons\mil_c2istar\cop\fnc_COPInit.sqf";
                ALIVE_RECOMPILE;
            };
            class C2TabletSetTerrainMode {
                description = "C2ISTAR tablet terrain-mode toggle (#698)";
                file = "\x\alive\addons\mil_c2istar\fnc_C2TabletSetTerrainMode.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};

