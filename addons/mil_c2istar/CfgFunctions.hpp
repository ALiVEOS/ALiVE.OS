class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            FUNC_FILEPATH(C2ISTAR,"The main class");
            FUNC_FILEPATH(C2ISTARInit,"The module initialisation function");
            FUNC_FILEPATH(C2MenuDef,"The module menu definition");
            FUNC_FILEPATH(C2TabletOnAction,"The module Radio Action function");
            FUNC_FILEPATH(C2TabletOnLoad,"The module tablet on load function");
            FUNC_FILEPATH(C2TabletOnUnLoad,"The module tablet on unload function");
            FUNC_FILEPATH(C2TabletEventToClient,"Call the tablet on the client from the server");
            FUNC_FILEPATH(C2OnPlayerConnected,"On player connected handler");
            FUNC_FILEPATH(taskHandler,"Task Handler");
            FUNC_FILEPATH(taskHandlerClient,"Task Handler Client");
            FUNC_FILEPATH(taskHandlerEventToClient,"Task Handler Event To Client");
            FUNC_FILEPATH(taskHandlerLoadData,"Task Handler Load Data");
            FUNC_FILEPATH(taskHandlerSaveData,"Task Handler Save Data");
            class taskGetSideCluster {
                description = "Utility get side cluster for tasks";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideCluster.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSideSectorCompositionPosition {
                description = "Utility get side sector for tasks";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideSectorCompositionPosition.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSideSectorVehicles {
                description = "Utility get side sector that contains vehicles";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideSectorVehicles.sqf";
                recompile = RECOMPILE;
            };
            class taskGetRandomSideVehicleFromSector {
                description = "Utility get a random vehicle for a side from a sector";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetRandomSideVehicleFromSector.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSideSectorEntities {
                description = "Utility get side sector that contains entities";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSideSectorEntities.sqf";
                recompile = RECOMPILE;
            };
            class taskGetRandomSideEntityFromSector {
                description = "Utility get a random vehicle for a side from a sector";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetRandomSideEntityFromSector.sqf";
                recompile = RECOMPILE;
            };
            class taskGetSectorPosition {
                description = "Utility get position based on sector data";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetSectorPosition.sqf";
                recompile = RECOMPILE;
            };
            class taskHavePlayersReachedDestination {
                description = "Utility check if players have reached the destination";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskHavePlayersReachedDestination.sqf";
                recompile = RECOMPILE;
            };
            class taskGetClosestPlayerDistanceToDestination {
                description = "Utility get the distance of the closest player to the destination";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetClosestPlayerDistanceToDestination.sqf";
                recompile = RECOMPILE;
            };
            class taskIsAreaClearOfEnemies {
                description = "Utility check if there are any enemies in the area";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskIsAreaClearOfEnemies.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateMarkersForPlayers {
                description = "Utility mark target position on map";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateMarkersForPlayers.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateMarker {
                description = "Utility create a local marker";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateMarker.sqf";
                recompile = RECOMPILE;
            };
            class taskDeleteMarkersForPlayers {
                description = "Utility delete any markers for players";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskDeleteMarkersForPlayers.sqf";
                recompile = RECOMPILE;
            };
            class taskDeleteMarkers {
                description = "Utility delete local markers";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskDeleteMarkers.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateRadioBroadcastForPlayers {
                description = "Utility broadcast radio message for players";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateRadioBroadcastForPlayers.sqf";
                recompile = RECOMPILE;
            };
            class taskGetNearestLocationName {
                description = "Utility get the nearest location name";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetNearestLocationName.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateRandomMilLogisticsEvent {
                description = "Utility call in a random mil logistics event";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateRandomMilLogisticsEvent.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateVehicleInsertionForUnits {
                description = "Utility create an insertion vehicle for units";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateVehicleInsertionForUnits.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateVehicleExtractionForUnits {
                description = "Utility create an extraction vehicle for units";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateVehicleExtractionForUnits.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateExplosiveProjectile {
                description = "Utility create an explosive projectile orientate towards an object";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateExplosiveProjectile.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateBombardment {
                description = "Utility create a bombardment of explosives";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateBombardment.sqf";
                recompile = RECOMPILE;
            };
            class taskSpawnOnTopOf {
                description = "Utility spawn an object on top of another object";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskSpawnOnTopOf.sqf";
                recompile = RECOMPILE;
            };
            class taskGetNearPlayerVehicles {
                description = "Utility get near player vehicles";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetNearPlayerVehicles.sqf";
                recompile = RECOMPILE;
            };
            class taskDoVehiclesHaveRoomForGroup {
                description = "Utility does any vehicle in an array of vehicles have room for a group";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskDoVehiclesHaveRoomForGroup.sqf";
                recompile = RECOMPILE;
            };
            class taskGetVehicleWithMaxRoom {
                description = "Utility get the vehicle with the biggest amount of room for passengers";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetVehicleWithMaxRoom.sqf";
                recompile = RECOMPILE;
            };
            class taskHaveUnitsLoadedInVehicle {
                description = "Utility have all the units loaded into the vehicle";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskHaveUnitsLoadedInVehicle.sqf";
                recompile = RECOMPILE;
            };
            class taskHaveUnitsUnloadedFromVehicle {
                description = "Utility have all the units unloaded from the vehicle";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskHaveUnitsUnloadedFromVehicle.sqf";
                recompile = RECOMPILE;
            };
            class taskGetStateOfVehicleProfiles {
                description = "Utility have all the vehicle profiles been destroyed";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetStateOfVehicleProfiles.sqf";
                recompile = RECOMPILE;
            };
            class taskGetStateOfEntityProfiles {
                description = "Utility have all the entity profiles been destroyed";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetStateOfEntityProfiles.sqf";
                recompile = RECOMPILE;
            };
            class taskGetStateOfObjects {
                description = "Utility have all the entity profiles been destroyed";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetStateOfObjects.sqf";
                recompile = RECOMPILE;
            };
            class taskCreateReward {
                description = "Utility create a reward for task completion";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskCreateReward.sqf";
                recompile = RECOMPILE;
            };
            class taskGetInsurgencyLocation {
                description = "Utility to find insurgency location from asymetrical opcoms";
                file = "\x\alive\addons\mil_c2istar\utils\fnc_taskGetInsurgencyLocation.sqf";
                recompile = RECOMPILE;
            };
            class taskMilAssault {
                description = "Task Mil Assault";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskMilAssault.sqf";
                recompile = RECOMPILE;
            };
            class taskMilDefence {
                description = "Task Mil Defence";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskMilDefence.sqf";
                recompile = RECOMPILE;
            };
            class taskCivAssault {
                description = "Task Civ Assault";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskCivAssault.sqf";
                recompile = RECOMPILE;
            };
            class taskAssassination {
                description = "Task Assassination";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskAssassination.sqf";
                recompile = RECOMPILE;
            };
            class taskTransportInsertion {
                description = "Task Transport Insertion";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskTransportInsertion.sqf";
                recompile = RECOMPILE;
            };
            class taskDestroyVehicles {
                description = "Task Destroy Vehicles";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskTransportInsertion.sqf";
                recompile = RECOMPILE;
            };
            class taskDestroyInfantry {
                description = "Task Destroy Infantry";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskDestroyInfantry.sqf";
                recompile = RECOMPILE;
            };
            class taskSabotageBuilding {
                description = "Task Destroy Infantry";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskSabotageBuilding.sqf";
                recompile = RECOMPILE;
            };
            class taskInsurgencyPatrol {
                description = "Task Insurgency Patrol";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskInsurgencyPatrol.sqf";
                recompile = RECOMPILE;
            };
            class taskInsurgencyDestroyAssets {
                description = "Task Insurgency Destroy Assets";
                file = "\x\alive\addons\mil_c2istar\tasks\fnc_taskInsurgencyDestroyAssets.sqf";
                recompile = RECOMPILE;
            };
        };
    };
};
