class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class getNearestClusterInArray {
                description = "Returns the nearest cluster to the given cluster from a list of clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_getNearestClusterInArray.sqf";
                ALIVE_RECOMPILE;
            };
            class findClusterCenter {
                description = "Return the centre position of an object cluster";
                file = "\x\alive\addons\fnc_strategic\fnc_findClusterCenter.sqf";
                ALIVE_RECOMPILE;
            };
            class consolidateClusters {
                description = "Merge cluster objects if they are within close proximity";
                file = "\x\alive\addons\fnc_strategic\fnc_consolidateClusters.sqf";
                ALIVE_RECOMPILE;
            };
            class findClusters {
                description = "Returns a list of object clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_findClusters.sqf";
                ALIVE_RECOMPILE;
            };
            class cluster {
                description = "Builds clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_cluster.sqf";
                ALIVE_RECOMPILE;
            };
            class findTargets {
                description = "Identify targets within the TAOR";
                file = "\x\alive\addons\fnc_strategic\fnc_findTargets.sqf";
                ALIVE_RECOMPILE;
            };
            class setTargets {
                description = "Set basic params on clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_setTargets.sqf";
                ALIVE_RECOMPILE;
            };
            class clustersInsideMarker {
                description = "Return list of clusters inside a marker";
                file = "\x\alive\addons\fnc_strategic\fnc_clustersInsideMarker.sqf";
                ALIVE_RECOMPILE;
            };
            class clustersOutsideMarker {
                description = "Return list of clusters outside a marker";
                file = "\x\alive\addons\fnc_strategic\fnc_clustersOutsideMarker.sqf";
                ALIVE_RECOMPILE;
            };
            class clustersDropStrayHelipads {
                description = "Drop military objectives made only of invisible helipads, away from any other military building";
                file = "\x\alive\addons\fnc_strategic\fnc_clustersDropStrayHelipads.sqf";
                ALIVE_RECOMPILE;
            };
            class staticClusterOutput {
                description = "Returns clusters in string format for static file storage";
                file = "\x\alive\addons\fnc_strategic\fnc_staticClusterOutput.sqf";
                ALIVE_RECOMPILE;
            };
            class auto_staticClusterOutput {
                description = "Returns clusters in string format for static file storage";
                file = "\x\alive\addons\fnc_strategic\fnc_auto_staticClusterOutput.sqf";
                ALIVE_RECOMPILE;
            };
            class copyClusters {
                description = "Duplicate an array of clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_copyClusters.sqf";
                ALIVE_RECOMPILE;
            };
            class generateParkingPositions {
                description = "Generate parking positions for cluster nodes";
                file = "\x\alive\addons\fnc_strategic\fnc_generateParkingPositions.sqf";
                ALIVE_RECOMPILE;
            };
            class generateParkingPosition {
                description = "Generate parking position for building";
                file = "\x\alive\addons\fnc_strategic\fnc_generateParkingPosition.sqf";
                ALIVE_RECOMPILE;
            };
            class getParkingPosition {
                description = "Gets a parking position for a building";
                file = "\x\alive\addons\fnc_strategic\fnc_getParkingPosition.sqf";
                ALIVE_RECOMPILE;
            };
            class findBuildingsInClusterNodes {
                description = "Find building names in cluster nodes";
                file = "\x\alive\addons\fnc_strategic\fnc_findBuildingsInClusterNodes.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};
