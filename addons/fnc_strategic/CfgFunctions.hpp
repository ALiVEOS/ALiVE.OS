class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class getNearestClusterInArray {
                description = "Returns the nearest cluster to the given cluster from a list of clusters";
								file = PATHTO_FUNC(getNearestClusterInArray);
                recompile = RECOMPILE;
            };
            class findClusterCenter {
                description = "Return the centre position of an object cluster";
								file = PATHTO_FUNC(findClusterCenter);
                recompile = RECOMPILE;
            };
            class consolidateClusters {
                description = "Merge cluster objects if they are within close proximity";
								file = PATHTO_FUNC(consolidateClusters);
                recompile = RECOMPILE;
            };
            class findClusters {
                description = "Returns a list of object clusters";
								file = PATHTO_FUNC(findClusters);
                recompile = RECOMPILE;
            };
            class cluster {
                description = "Builds clusters";
								file = PATHTO_FUNC(cluster);
                recompile = RECOMPILE;
            };
            class findTargets {
                description = "Identify targets within the TAOR";
								file = PATHTO_FUNC(findTargets);
                recompile = RECOMPILE;
            };
            class setTargets {
                description = "Set basic params on clusters";
								file = PATHTO_FUNC(setTargets);
                recompile = RECOMPILE;
            };
            class clustersInsideMarker {
                description = "Return list of clusters inside a marker";
								file = PATHTO_FUNC(clustersInsideMarker);
                recompile = RECOMPILE;
            };
            class clustersOutsideMarker {
                description = "Return list of clusters outside a marker";
								file = PATHTO_FUNC(clustersOutsideMarker);
                recompile = RECOMPILE;
            };
            class staticClusterOutput {
                description = "Returns clusters in string format for static file storage";
								file = PATHTO_FUNC(staticClusterOutput);
                recompile = RECOMPILE;
            };
            class auto_staticClusterOutput {
                description = "Returns clusters in string format for static file storage";
								file = PATHTO_FUNC(auto_staticClusterOutput);
                recompile = RECOMPILE;
            };
            class copyClusters {
                description = "Duplicate an array of clusters";
								file = PATHTO_FUNC(copyClusters);
                recompile = RECOMPILE;
            };
            class generateParkingPositions {
                description = "Generate parking positions for cluster nodes";
								file = PATHTO_FUNC(generateParkingPositions);
                recompile = RECOMPILE;
            };
            class generateParkingPosition {
                description = "Generate parking position for building";
								file = PATHTO_FUNC(generateParkingPosition);
                recompile = RECOMPILE;
            };
            class getParkingPosition {
                description = "Gets a parking position for a building";
								file = PATHTO_FUNC(getParkingPosition);
                recompile = RECOMPILE;
            };
            class findBuildingsInClusterNodes {
                description = "Find building names in cluster nodes";
								file = PATHTO_FUNC(findBuildingsInClusterNodes);
                recompile = RECOMPILE;
            };
        };
    };
};
