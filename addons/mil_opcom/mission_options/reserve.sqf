[
    ["name","reserve"],
    ["priority", 0],
    ["isOffensiveOrder", false],
    ["internalData", [] call ALiVE_fnc_hashCreate],
    ["condition", {
        if (_nearFriendlyCount > 0 && { _nearEnemyCount == 0 }) then {
            true
        } else {
            false
        };
    }],
    ["evaluate", {
        private _objectiveID = [_this,"objective"] call ALiVE_fnc_hashGet;
        private _objective = [_opcomInstance,"getObjectiveByID", _objectiveID] call ALiVE_fnc_OPCOM;
        private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;

        private "_sectionsToTask";
        if (_nearFriendlyCount < _sectionsNeededForReserve) then {
            private _objectivePos = [_objective,"center"] call ALiVE_fnc_hashGet;
            private _sectionsByDistance = [_opcomInstance,"sortSectionsByDistance", [_objectivePos,_allSections]] call ALiVE_fnc_OPCOM;

            _sectionsToTask = _sectionsByDistance select [0, _sectionsNeededForReserve];
        } else {
            _sectionsToTask = (_nearFriendlyInfantry + _nearFriendlyVehicles) select [0, _sectionsNeededForReserve];
        };

        if (count _sectionsToTask >= _sectionsNeededForReserve) then {
            [true, [_objective,_sectionsToTask]];
        } else {
            [false, [_objective,_sectionsToTask]];
        };
    }],
    ["onInit", {

    }],
    ["onTick", {}],
    ["onSuccess", {}],
    ["onFailure", {}]
]