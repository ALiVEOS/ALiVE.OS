params ["_profile"];

// determine profile type

private _pathfindingProcedure = "Man";
private _profileType = _profile select 2 select 5;

private _vehicleTypeToProcedure = {
    private _vehicleType = _this;

    switch (_vehicleType) do {
        case "Car": { "LandRoad" };

        case "Truck";
        case "Tank";
        case "Armored" : { "LandOffRoad" };

        case "Ship": { "Naval" };

        case "Helicopter": { "Heli" };

        case "Plane": { "Plane" };

        default { "LandOffRoad" };
    };
};

if (_profileType == "entity") then {
    _pathfindingProcedure = "Man";

    // check if entity is using vehicles

    private _vehiclesInCommandOf = _profile select 2 select 8;
    private _vehiclesInCargoOf = _profile select 2 select 9;

    if (count _vehiclesInCommandOf > 0) then {
        private _vehicle = [ALiVE_profileHandler,"getProfile", _vehiclesInCommandOf select 0] call ALiVE_fnc_profileHandler;
        private _vehicleClass = _vehicle select 2 select 11;
        private _vehicleType = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

        _pathfindingProcedure = _vehicleType call _vehicleTypeToProcedure;
    } else {
        if (count _vehiclesInCargoOf > 0) then {
            private _vehicle = [ALiVE_profileHandler,"getProfile", _vehiclesInCargoOf select 0] call ALiVE_fnc_profileHandler;
            private _vehicleClass = _vehicle select 2 select 11;
            private _vehicleType = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

            _pathfindingProcedure = _vehicleType call _vehicleTypeToProcedure;
        };
    };
} else {
    private _vehicleClass = _profile select 2 select 11;
    private _vehicleType = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

    _pathfindingProcedure = _vehicleType call _vehicleTypeToProcedure;
};

private _faction = [_profile,"faction"] call ALiVE_fnc_profileEntity;
_result = [Alive_pathfinder,"getPathfindingProcedure",[_pathfindingProcedure,_faction]] call Alive_fnc_pathfinder;

_result;