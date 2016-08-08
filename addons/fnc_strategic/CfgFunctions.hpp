class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            FUNC_FILEPATH(getNearestClusterInArray,"Returns the nearest cluster to the given cluster from a list of clusters");
            FUNC_FILEPATH(findClusterCenter,"Return the centre position of an object cluster");
            FUNC_FILEPATH(consolidateClusters,"Merge cluster objects if they are within close proximity");
            FUNC_FILEPATH(findClusters,"Returns a list of object clusters");
            FUNC_FILEPATH(cluster,"Builds clusters");
            FUNC_FILEPATH(findTargets,"Identify targets within the TAOR");
            FUNC_FILEPATH(setTargets,"Set basic params on clusters");
            FUNC_FILEPATH(clustersInsideMarker,"Return list of clusters inside a marker");
            FUNC_FILEPATH(clustersOutsideMarker,"Return list of clusters outside a marker");
            FUNC_FILEPATH(staticClusterOutput,"Returns clusters in string format for static file storage");
            FUNC_FILEPATH(auto_staticClusterOutput,"Returns clusters in string format for static file storage");
            FUNC_FILEPATH(copyClusters,"Duplicate an array of clusters");
            FUNC_FILEPATH(generateParkingPositions,"Generate parking positions for cluster nodes");
            FUNC_FILEPATH(generateParkingPosition,"Generate parking position for building");
            FUNC_FILEPATH(getParkingPosition,"Gets a parking position for a building");
            FUNC_FILEPATH(findBuildingsInClusterNodes,"Find building names in cluster nodes");
        };
    };
};
