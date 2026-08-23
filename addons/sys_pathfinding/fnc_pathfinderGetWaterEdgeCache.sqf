    params ["_terrainGrid", "_size"];
    private _edgeCaches = _terrainGrid get "waterEdgeCaches";
    private _signature = [ALiVE_pathfinding_seaLevel, ALiVE_pathfinding_waterMargin, _size];
    private _edgeCache = _edgeCaches get _signature;
    if (isNil "_edgeCache") then {
        _edgeCache = createHashMap;
        _edgeCaches set [_signature, _edgeCache];
    };
    _edgeCache
