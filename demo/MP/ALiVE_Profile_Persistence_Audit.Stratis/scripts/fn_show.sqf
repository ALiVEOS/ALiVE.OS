params ["_caller"];
private _baseline = profileNamespace getVariable [PA_baselineKey, []];
if (count _baseline < 3 || {(_baseline select 0) != "normal"}) exitWith {
    "[PA] Run a Local roundtrip or cold-load normal fixtures before spawning them." remoteExec ["systemChat", 0];
};
private _snapshots = _baseline select 1;
private _origin = getPosATL _caller;
{
    _x params ["_alias", "_id", "_fields"];
    if (_alias in ["hook", "injured", "mounted", "attritionVehicle"]) then {
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        if (!isNil "_profile") then {
            private _position = _origin getPos [25 + 15 * _forEachIndex, 180];
            private _implementation = [ALIVE_fnc_profileEntity, ALIVE_fnc_profileVehicle] select (_alias == "attritionVehicle");
            [_profile, "position", _position] call _implementation;
            [_profile, "despawnPosition", _position] call _implementation;
        };
    };
} forEach _snapshots;
// Entity spawning also brings in its assigned vehicle. No cargo/sling physics
// are needed to demonstrate that their serialized relationships were lost.
{
    _x params ["_alias", "_id"];
    if (_alias in ["hook", "injured", "mounted"]) then {
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        if (!isNil "_profile" && {!([_profile, "active"] call ALIVE_fnc_hashGet)}) then {
            [_profile, "spawn"] call ALIVE_fnc_profileEntity;
        };
    };
} forEach PA_fixtures;
sleep 1;
private _hookID = (PA_fixtures select (PA_fixtures findIf {(_x select 0) == "hook"})) select 1;
private _hookProfile = [ALIVE_profileHandler, "getProfile", _hookID] call ALIVE_fnc_profileHandler;
private _units = [_hookProfile, "units", []] call ALIVE_fnc_hashGet;
["Restored spawn hook actually runs on the spawned unit",
    count _units > 0 && {(_units findIf {!(_x getVariable ["PA_hookRan", false])}) == -1},
    "PA_hookRan=true on every unit", _units apply {_x getVariable ["PA_hookRan", false]}] call PA_fnc_assert;
"[PA] Hook/crew/injury fixtures are spawned nearby. Run fresh Local tests before another comparison." remoteExec ["systemChat", 0];
