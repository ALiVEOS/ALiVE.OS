    params ["_cameFromMap", "_costSoFarMap", "_frontier", "_sector", "_cameFromSector", "_distanceToGoal", "_heuristicParams", "_moveCost", "_airsideActive"];

    private _size = _heuristicParams select 4;

    private _costToHere = _costSoFarMap get (_cameFromSector select 0);
    private _sectorCostSoFar = _costSoFarMap get (_sector select 0);

    // Make airfield-surface cells dearer to cross for ground procedures, so the
    // router bends around a runway rather than straight over it. The penalty
    // goes on the movement cost, not the heuristic below: it is _moveCost that
    // accumulates into _newCostSoFar and so decides the recorded predecessor,
    // while the heuristic only orders which cells are explored first. A penalty
    // on the heuristic would change exploration order and leave the crossing
    // route in place.
    //
    // Air procedures are exempt: the aircraft need the runway. Sector arrays
    // persist in the grid, so index 5 memoizes their static airside result;
    // existing consumers only read indices 0-4.
    if (_airsideActive) then {
        private _isAirside = if (count _sector > 5) then {
            _sector select 5
        } else {
            // Half the cell as margin, so a cell centre just off a runway strip
            // still counts when the cell itself straddles it.
            private _value = [_sector select 2, _size / 2] call ALiVE_fnc_isAirside;
            _sector set [5, _value];
            _value
        };

        if (_isAirside) then {
            _moveCost = _moveCost * ALiVE_pathfinding_airsideWeight;
        };
    };

    private _newCostSoFar = _moveCost + _costToHere;

    if (isnil "_sectorCostSoFar" || { _newCostSoFar < _sectorCostSoFar }) then {
        // The heuristic is only needed when the node will actually be queued.
        private _priority = _heuristicParams call ALiVE_fnc_pathfinderHeuristic;
        _costSoFarMap set [_sector select 0, _newCostSoFar];
        [_frontier, _distanceToGoal + _priority + _moveCost, _sector, _newCostSoFar] call ALiVE_fnc_pathfinderPriorityAdd;
        _cameFromMap set [_sector select 0, _cameFromSector];
    };
