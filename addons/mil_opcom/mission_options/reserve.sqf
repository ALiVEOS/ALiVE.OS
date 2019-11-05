[
    ["name","reserve"],
    ["priority", 100],
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
        private _objectiveSize = [_objective,"size"] call ALiVE_fnc_hashGet;

        private _opcomSide = [_opcomInstance,"side"] call ALiVE_fnc_hashGet;

        private _nearFriendlies = [_objectivePosition, _objectiveSize * 1.15, [_opcomSide,"entity","none"]] call ALIVE_fnc_getNearProfiles;
        private _nearFriendlyCount = count _nearFriendlies;

        private _sectionsToTask = if (_nearFriendlyCount >= _sectionsNeededForReserve) then {
            _nearFriendlies select [0, _sectionsNeededForReserve]
        } else {
            private _sectionsByDistance = [_opcomInstance,"sortSectionsByDistance", [_objectivePosition,_allSections, true]] call ALiVE_fnc_OPCOM;

            private _additionalSections = _sectionsByDistance select [0, _sectionsNeededForReserve - _nearFriendlyCount];

            _nearFriendlies + _additionalSections
        };

        [count _sectionsToTask >= _sectionsNeededForReserve, _sectionsToTask]
    }],
    ["onInit", {
        private _taskedProfiles = [_this,"sections"] call ALiVE_fnc_hashGet;
        private _objectiveID = [_this,"objective"] call ALiVE_fnc_hashGet;

        private _objective = [_opcomInstance,"getObjectiveByID", _objectiveID] call ALiVE_fnc_OPCOM;
        private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
        private _objectiveSize = [_objective,"size"] call ALiVE_fnc_hashGet;

        {
            private _profile = ALiVE_profileMap getvariable _x;

            if (!isnil "_profile") then {
                private _waypointPos = [_objectivePosition, _objectiveSize * 0.6] call CBA_fnc_randPos;
                private _profileWaypoint = [_waypointPos, 50] call ALiVE_fnc_createProfileWaypoint;
                [_profile,"addWaypoint", _profileWaypoint] call ALiVE_fnc_profileEntity;

                systemchat "waypoint set";
            };
        } foreach _taskedProfiles;
    }],
    ["onTick", {
        private _taskedProfiles = [_this,"sections"] call ALiVE_fnc_hashGet;
        private _killedProfiles = [_opcomInstance,"profileListRemoveDead", _taskedProfiles] call ALiVE_fnc_OPCOM;

        private _casualties = [_this,"casualties"] call ALiVE_fnc_hashGet;
        _casualties = _casualties + (count _killedProfiles);
        [_this,"casualties", _casualties] call ALiVE_fnc_hashSet;

        private _needReinforcementCount = _sectionsNeededForReserve - count _taskedProfiles;
        if (_needReinforcementCount > 0) then {
            // reinforce tasked profiles
            systemchat "WTF?";
        };

        if (_casualties > _sectionsNeededForReserve + 1 || { _taskedProfiles isequalto [] }) then {
            [_this,"state","failed"] call ALiVE_fnc_hashSet;
        } else {
            private _allProfilesReachedDestination = true;
            {
                private _profile = ALiVE_profileMap getvariable _x;
                private _waypoints = [_profile,"waypoints"] call ALiVE_fnc_hashGet;

                if !(_waypoints isequalto []) exitwith {
                    _waypoints = false;
                };
            } foreach _taskedProfiles;

            if (_allProfilesReachedDestination) then {
                [_this,"state","complete"] call ALiVE_fnc_hashSet;
            };
        };
    }],
    ["onSuccess", {
        systemchat "yaaaaaaaaaaaaaaaaaaaaaaaaaa";
    }],
    ["onFailure", {
        systemchat "ah fuck";
    }]
]