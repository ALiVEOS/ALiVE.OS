// Expected values come from the live profiles before production export.
private _fieldsByAlias = [
    ["mounted", ["unitClasses", "ranks", "unitCount", "speedPerSecond", "vehiclesInCommandOf", "vehicleAssignments"]],
    ["partlyMounted", ["unitClasses", "unitCount", "speedPerSecond", "vehiclesInCommandOf", "vehicleAssignments"]],
    ["multipleVehicles", ["unitClasses", "unitCount", "speedPerSecond", "vehiclesInCommandOf", "vehicleAssignments"]],
    ["onFoot", ["unitClasses", "unitCount", "speedPerSecond", "vehiclesInCommandOf"]],
    ["partialVehicle", []],
    ["fastVehicle", []],
    ["slowVehicle", []],
    ["hook", ["onEachSpawn", "onEachSpawnOnce"]],
    ["injured", ["damages"]],
    ["attritionVehicle", ["fuel", "damage", "ammo"]],
    ["cargo", ["cargo", "slung"]],
    ["carrier", ["slingload"]],
    ["pending", []]
];
PA_fixtures apply {
    _x params ["_alias", "_id"];
    private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
    private _fieldIndex = _fieldsByAlias findIf {(_x select 0) == _alias};
    private _fields = ((_fieldsByAlias select _fieldIndex) select 1) apply {
        private _value = [_profile, _x, "(missing)"] call ALIVE_fnc_hashGet;
        if (_value isEqualType []) then {_value = +_value};
        [_x, _value]
    };
    // Controls ensure profile identity, side and class selection survive.
    {
        _fields pushBack [_x, [_profile, _x] call ALIVE_fnc_hashGet];
    } forEach ["type", "side", "faction"];
    [_alias, _id, _fields]
}
