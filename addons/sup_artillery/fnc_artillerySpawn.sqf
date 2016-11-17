#include <\x\alive\addons\sup_artillery\script_component.hpp>
SCRIPT(ArtillerySpawn);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_artillerySpawn
Description:
Spawns the assets associated with the artillery module.

Parameters:
Object - The artillery module

Returns:
Nothing

Examples:
[_logic] call ALIVE_fnc_artillerySpawn;

See Also:

Author:
marceldev89
---------------------------------------------------------------------------- */
private _logic = param [0, objNull, [objNull]];

private _position = position _logic;
private _type = _logic getVariable ["artillery_type", ""];
private _callsign = _logic getVariable ["artillery_callsign", ""];
private _code = _logic getVariable ["artillery_code", ""];

private _side = _type call ALIVE_fnc_classSide;
private _group = createGroup _side;
private _vehicles = [];

for "_i" from 0 to 2 do {
    // TODO: Spawn vehicles in proper fancy formation (see CfgFormations)
    private _vehiclePosition = _position getPos [15 * _i, (getDir _logic) * _i];
    private _vehicle = createVehicle [_type, _vehiclePosition, [], 0, "NONE"];
    _vehicle setDir (getDir _logic);
    _vehicle lock true;
    [_vehicle, _group] call BIS_fnc_spawnCrew;
    _vehicles pushBack _vehicle;
};

if (_type isKindOf "StaticMortar") then {
    // Create group leader
    private _leader = _group createUnit ["B_Soldier_F", position (leader _group), [], 0, "NONE"];
    _group selectLeader _leader;

    // Create gunner assitants
    {
        private _vehicle = _x param [0, objNull];
        _group createUnit ["B_Soldier_F", position _vehicle, [], 0, "NONE"];
    } forEach _vehicles;

    _logic setVariable ["type", TYPE_MORTAR];
} else {
    _logic setVariable ["type", TYPE_ARTILLERY];
};

_group setVariable ["logic", _logic];
_logic setVariable ["group", _group];

// Assign artillery group to NEO_radio
private _rounds = [_logic, "getRounds"] call ALIVE_fnc_artillery;
leader _group setVariable ["NEO_radioArtyBatteryRounds", _rounds, true];
private _a = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _side];
_a set [count _a, [leader _group, _group, _callsign, _vehicles, _rounds]];
NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _side], _a, true];
