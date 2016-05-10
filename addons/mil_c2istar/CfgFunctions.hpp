class CfgFunctions {
	class PREFIX {
		class COMPONENT {
			class C2ISTAR {
				description = "The main class";
				file = "\x\alive\addons\mil_C2ISTAR\fnc_C2ISTAR.sqf";
				recompile = RECOMPILE;
			};
			class C2ISTARInit {
				description = "The module initialisation function";
				file = "\x\alive\addons\mil_C2ISTAR\fnc_C2ISTARInit.sqf";
				recompile = RECOMPILE;
			};
			class C2MenuDef {
                description = "The module menu definition";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_C2MenuDef.sqf";
                recompile = RECOMPILE;
            };
            class C2TabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_C2TabletOnAction.sqf";
                recompile = RECOMPILE;
            };
            class C2TabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_C2TabletOnLoad.sqf";
                recompile = RECOMPILE;
            };
            class C2TabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_C2TabletOnUnLoad.sqf";
                recompile = RECOMPILE;
            };
            class C2TabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_C2TabletEventToClient.sqf";
                recompile = RECOMPILE;
            };
            class C2OnPlayerConnected {
                description = "On player connected handler";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_C2OnPlayerConnected.sqf";
                recompile = RECOMPILE;
            };
            class taskHandler {
                description = "Task Handler";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_taskHandler.sqf";
                recompile = RECOMPILE;
            };
            class taskHandlerClient {
                description = "Task Handler Client";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_taskHandlerClient.sqf";
                recompile = RECOMPILE;
            };
            class taskHandlerEventToClient {
                description = "Task Handler Event To Client";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_taskHandlerEventToClient.sqf";
                recompile = RECOMPILE;
            };
            class taskHandlerLoadData {
                description = "Task Handler Load Data";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_taskHandlerLoadData.sqf";
                recompile = RECOMPILE;
            };
            class taskHandlerSaveData {
                description = "Task Handler Save Data";
                file = "\x\alive\addons\mil_C2ISTAR\fnc_taskHandlerSaveData.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSideCluster {
                description = "Utility get side cluster for tasks";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetSideCluster.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSideSectorCompositionPosition {
                description = "Utility get side sector for tasks";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetSideSectorCompositionPosition.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSideSectorVehicles {
                description = "Utility get side sector that contains vehicles";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetSideSectorVehicles.sqf";
                recompile = RECOMPILE;
            };
            class taskGetRandomSideVehicleFromSector {
                description = "Utility get a random vehicle for a side from a sector";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetRandomSideVehicleFromSector.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSideSectorEntities {
                description = "Utility get side sector that contains entities";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetSideSectorEntities.sqf";
                recompile = RECOMPILE;
            };
            class taskGetRandomSideEntityFromSector {
                description = "Utility get a random vehicle for a side from a sector";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetRandomSideEntityFromSector.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSectorPosition {
                description = "Utility get position based on sector data";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetSectorPosition.sqf";
                recompile = RECOMPILE;
            };
            class taskHavePlayersReachedDestination {
                description = "Utility check if players have reached the destination";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskHavePlayersReachedDestination.sqf";
                recompile = RECOMPILE;
            };
            class taskGetClosestPlayerDistanceToDestination {
                description = "Utility get the distance of the closest player to the destination";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetClosestPlayerDistanceToDestination.sqf";
                recompile = RECOMPILE;
            };
            class taskIsAreaClearOfEnemies {
                description = "Utility check if there are any enemies in the area";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskIsAreaClearOfEnemies.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateMarkersForPlayers {
                description = "Utility mark target position on map";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateMarkersForPlayers.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateMarker {
                description = "Utility create a local marker";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateMarker.sqf";
                recompile = RECOMPILE;
            };
            class taskDeleteMarkersForPlayers {
                description = "Utility delete any markers for players";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskDeleteMarkersForPlayers.sqf";
                recompile = RECOMPILE;
            };
            class taskDeleteMarkers {
                description = "Utility delete local markers";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskDeleteMarkers.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateRadioBroadcastForPlayers {
                description = "Utility broadcast radio message for players";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateRadioBroadcastForPlayers.sqf";
                recompile = RECOMPILE;
            };
            class taskGetNearestLocationName {
                description = "Utility get the nearest location name";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetNearestLocationName.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateRandomMilLogisticsEvent {
                description = "Utility call in a random mil logistics event";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateRandomMilLogisticsEvent.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateVehicleInsertionForUnits {
                description = "Utility create an insertion vehicle for units";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateVehicleInsertionForUnits.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateVehicleExtractionForUnits {
                description = "Utility create an extraction vehicle for units";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateVehicleExtractionForUnits.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateExplosiveProjectile {
                description = "Utility create an explosive projectile orientate towards an object";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateExplosiveProjectile.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateBombardment {
                description = "Utility create a bombardment of explosives";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateBombardment.sqf";
                recompile = RECOMPILE;
            };
            class taskSpawnOnTopOf {
                description = "Utility spawn an object on top of another object";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskSpawnOnTopOf.sqf";
                recompile = RECOMPILE;
            };
            class taskGetNearPlayerVehicles {
                description = "Utility get near player vehicles";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetNearPlayerVehicles.sqf";
                recompile = RECOMPILE;
            };
            class taskDoVehiclesHaveRoomForGroup {
                description = "Utility does any vehicle in an array of vehicles have room for a group";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskDoVehiclesHaveRoomForGroup.sqf";
                recompile = RECOMPILE;
            };
            class taskGetVehicleWithMaxRoom {
                description = "Utility get the vehicle with the biggest amount of room for passengers";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetVehicleWithMaxRoom.sqf";
                recompile = RECOMPILE;
            };
            class taskHaveUnitsLoadedInVehicle {
                description = "Utility have all the units loaded into the vehicle";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskHaveUnitsLoadedInVehicle.sqf";
                recompile = RECOMPILE;
            };
            class taskHaveUnitsUnloadedFromVehicle {
                description = "Utility have all the units unloaded from the vehicle";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskHaveUnitsUnloadedFromVehicle.sqf";
                recompile = RECOMPILE;
            };
            class taskGetStateOfVehicleProfiles {
                description = "Utility have all the vehicle profiles been destroyed";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetStateOfVehicleProfiles.sqf";
                recompile = RECOMPILE;
            };
            class taskGetStateOfEntityProfiles {
                description = "Utility have all the entity profiles been destroyed";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetStateOfEntityProfiles.sqf";
                recompile = RECOMPILE;
            };
            class taskGetStateOfObjects {
                description = "Utility have all the entity profiles been destroyed";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetStateOfObjects.sqf";
                recompile = RECOMPILE;
            };            
            class taskCreateReward {
                description = "Utility create a reward for task completion";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskCreateReward.sqf";
                recompile = RECOMPILE;
            };
            class taskGetInsurgencyLocation {
                description = "Utility to find insurgency location from asymetrical opcoms";
                file = "\x\alive\addons\mil_C2ISTAR\utils\fnc_taskGetInsurgencyLocation.sqf";
                recompile = RECOMPILE;
            };
            class taskMilAssault {
                description = "Task Mil Assault";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskMilAssault.sqf";
                recompile = RECOMPILE;
            };
            class taskMilDefence {
                description = "Task Mil Defence";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskMilDefence.sqf";
                recompile = RECOMPILE;
            };
            class taskCivAssault {
                description = "Task Civ Assault";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskCivAssault.sqf";
                recompile = RECOMPILE;
            };
            class taskAssassination {
                description = "Task Assassination";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskAssassination.sqf";
                recompile = RECOMPILE;
            };
            class taskTransportInsertion {
                description = "Task Transport Insertion";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskTransportInsertion.sqf";
                recompile = RECOMPILE;
            };
            class taskDestroyVehicles {
                description = "Task Destroy Vehicles";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskDestroyVehicles.sqf";
                recompile = RECOMPILE;
            };
            class taskDestroyInfantry {
                description = "Task Destroy Infantry";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskDestroyInfantry.sqf";
                recompile = RECOMPILE;
            };
            class taskSabotageBuilding {
                description = "Task Destroy Infantry";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskSabotageBuilding.sqf";
                recompile = RECOMPILE;
            };
            class taskInsurgencyPatrol {
                description = "Task Insurgency Patrol";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskInsurgencyPatrol.sqf";
                recompile = RECOMPILE;
            };
            class taskInsurgencyDestroyAssets {
                description = "Task Insurgency Destroy Assets";
                file = "\x\alive\addons\mil_C2ISTAR\tasks\fnc_taskInsurgencyDestroyAssets.sqf";
                recompile = RECOMPILE;
            };
        };
	};
};
