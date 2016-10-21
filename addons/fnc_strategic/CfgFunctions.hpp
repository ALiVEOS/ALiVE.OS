class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class getNearestClusterInArray {
                description = "Returns the nearest cluster to the given cluster from a list of clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_getNearestClusterInArray.sqf";
                RECOMPILE;
            };
            class findClusterCenter {
                description = "Return the centre position of an object cluster";
                file = "\x\alive\addons\fnc_strategic\fnc_findClusterCenter.sqf";
                RECOMPILE;
            };
            class consolidateClusters {
                description = "Merge cluster objects if they are within close proximity";
                file = "\x\alive\addons\fnc_strategic\fnc_consolidateClusters.sqf";
                RECOMPILE;
            };
            class findClusters {
                description = "Returns a list of object clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_findClusters.sqf";
                RECOMPILE;
            };
            class cluster {
                description = "Builds clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_cluster.sqf";
                RECOMPILE;
            };
            class findTargets {
                description = "Identify targets within the TAOR";
                file = "\x\alive\addons\fnc_strategic\fnc_findTargets.sqf";
                RECOMPILE;
            };
            class setTargets {
                description = "Set basic params on clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_setTargets.sqf";
                RECOMPILE;
            };
            class clustersInsideMarker {
                description = "Return list of clusters inside a marker";
                file = "\x\alive\addons\fnc_strategic\fnc_clustersInsideMarker.sqf";
                RECOMPILE;
            };
            class clustersOutsideMarker {
                description = "Return list of clusters outside a marker";
                file = "\x\alive\addons\fnc_strategic\fnc_clustersOutsideMarker.sqf";
                RECOMPILE;
            };
            class staticClusterOutput {
                description = "Returns clusters in string format for static file storage";
                file = "\x\alive\addons\fnc_strategic\fnc_staticClusterOutput.sqf";
                RECOMPILE;
            };
            class auto_staticClusterOutput {
                description = "Returns clusters in string format for static file storage";
                file = "\x\alive\addons\fnc_strategic\fnc_auto_staticClusterOutput.sqf";
                RECOMPILE;
            };
            class copyClusters {
                description = "Duplicate an array of clusters";
                file = "\x\alive\addons\fnc_strategic\fnc_copyClusters.sqf";
                RECOMPILE;
            };
            class generateParkingPositions {
                description = "Generate parking positions for cluster nodes";
                file = "\x\alive\addons\fnc_strategic\fnc_generateParkingPositions.sqf";
                RECOMPILE;
            };
            class generateParkingPosition {
                description = "Generate parking position for building";
                file = "\x\alive\addons\fnc_strategic\fnc_generateParkingPosition.sqf";
                RECOMPILE;
            };
            class getParkingPosition {
                description = "Gets a parking position for a building";
                file = "\x\alive\addons\fnc_strategic\fnc_getParkingPosition.sqf";
                RECOMPILE;
            };
            class findBuildingsInClusterNodes {
                description = "Find building names in cluster nodes";
                file = "\x\alive\addons\fnc_strategic\fnc_findBuildingsInClusterNodes.sqf";
                RECOMPILE;
            };
        };
    };
};
