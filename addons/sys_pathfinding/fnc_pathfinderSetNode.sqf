// Optional final argument is a cumulative cost already checked for improvement.
// Internal search callers pass it only after traversal succeeds, with the final
// movement cost and airsideActive=false. Their cost maps cannot change between
// the check and this synchronous call. Nine-argument callers retain validation.
params ["_cameFromMap", "_costSoFarMap", "_frontier", "_sector", "_cameFromSector", "_distanceToGoal", "_heuristicParams", "_moveCost", "_airsideActive", ["_validatedCost", objNull]];

private _newCostSoFar = _validatedCost;
private _canImprove = true;
if (_airsideActive || {!(_validatedCost isEqualType 0)}) then {
    private _costToHere = _costSoFarMap get (_cameFromSector select 0);
    private _sectorCostSoFar = _costSoFarMap get (_sector select 0);
    if (_airsideActive) then {
        _moveCost = [_sector, _heuristicParams select 4, _moveCost] call ALiVE_fnc_pathfinderGetFinalMovementCost;
    };
    _newCostSoFar = _moveCost + _costToHere;
    _canImprove = isNil "_sectorCostSoFar" || {_newCostSoFar < _sectorCostSoFar};
};

if (_canImprove) then {
    private _priority = _heuristicParams call ALiVE_fnc_pathfinderHeuristic;
    _costSoFarMap set [_sector select 0, _newCostSoFar];
    [_frontier, _distanceToGoal + _priority + _moveCost, _sector, _newCostSoFar] call ALiVE_fnc_pathfinderPriorityAdd;
    _cameFromMap set [_sector select 0, _cameFromSector];
};
