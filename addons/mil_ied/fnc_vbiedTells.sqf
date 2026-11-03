#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(vbiedTells);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vbiedTells

Description:
Gives a car bomb the signs a careful player can spot, each one switched on or off in the IED
module's VEHICLE-BORNE IED settings. Server only.

- Load: three shells and a charge bundled under the car, with a satchel beside them, for anyone who
  looks underneath. Every player sees the same load. Not on bikes.
- Sits low: more weight at the back, so the rear sits lower and the nose higher than the same car
  unloaded.
- Beeps: a timer beeps from the car while a player is within 25 m.
- Detector: a player carrying the IED Detector Class item who comes within 10 m is warned the way
  IED Detection Alert is set (as text when that is None). ACE's mine detectors find the charge
  under the car on their own.

The load goes when the car is deleted or wrecked; the beeping and the detector warning stop once the
charge has gone off or been removed.

Parameters:
Object - the car
Object - the charge under it

Returns:
Nothing

Examples:
(begin example)
[_vehicle, _charge] call ALiVE_fnc_vbiedTells;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_car", objNull, [objNull]], ["_charge", objNull, [objNull]]];

if (!isServer || {isNull _car}) exitWith {};

// a setting is Yes or No; without an IED module (a Zeus placing one) the defaults stand
private _fnc_on = {
    params ["_name", "_default"];
    private _v = if (isNil QUOTE(ADDON)) then { _default } else { ADDON getVariable [_name, _default] };
    if (_v isEqualType "") then { _v = parseNumber _v };
    if (_v isEqualType true) then { _v = [0, 1] select _v };
    (_v isEqualType 0) && {_v > 0}
};
private _load   = ["VB_Tell_Load", 1] call _fnc_on;
private _low    = ["VB_Tell_Low", 0] call _fnc_on;
private _beep   = ["VB_Tell_Beep", 1] call _fnc_on;
private _detect = ["VB_Tell_Detector", 1] call _fnc_on;

private _bike = _car isKindOf "Motorcycle" || {_car isKindOf "vn_bicycle_base"} || {_car isKindOf "Quadbike_01_base_F"};
private _props = [];

if (_load && {!_bike}) then {
    // strapped to the underside, between the axles: three shells bundled across the car with a charge
    // taped on, and a satchel beside them. Each piece hangs flush under the floor, found by looking up
    // from the ground under it.
    private _y = -0.5;
    private _fnc_under = {
        params ["_px", "_py"];
        private _hits = (lineIntersectsSurfaces [AGLToASL (_car modelToWorld [_px, _py, -3]), AGLToASL (_car modelToWorld [_px, _py, 0.5]), objNull, objNull, true, 10, "VIEW", "FIRE"]) select {
            ((_x select 2) == _car || {(_x select 3) == _car})
        };
        if (_hits isEqualTo []) then { -1.0 } else { (_car worldToModel (ASLToAGL ((_hits select 0) select 0))) select 2 }
    };
    private _fnc_hang = {
        params ["_model", "_at", "_dir", "_up"];
        private _o = createSimpleObject [_model, [0, 0, 0]];
        _o attachTo [_car, _at];
        _o setVectorDirAndUp [_dir, _up];
        _props pushBack _o;
    };
    // the bundle sits under the lowest point of the floor it spans
    private _under = selectMin ([[-0.3, _y], [0, _y], [0.3, _y]] apply { _x call _fnc_under });
    {
        // a shell's model runs 57 cm back from its nose and is 9 cm across
        ["\A3\Weapons_F\Ammo\shell.p3d", [0.285, _y + _x, _under - 0.05], [1, 0, 0], [0, 0, 1]] call _fnc_hang;
    } forEach [-0.085, 0, 0.085];
    ["\A3\Weapons_F\explosives\c4_charge_small.p3d", [0, _y, _under - 0.1], [0, 1, 0], [0, 0, -1]] call _fnc_hang;
    ["\A3\Weapons_F\Explosives\satchel.p3d", [0, _y + 0.3, ([0, _y + 0.3] call _fnc_under) - 0.01], [0, 1, 0], [0, 0, -1]] call _fnc_hang;
    _car setVariable ["ALiVE_vbiedLoad", _props];
};

if (_low && {!_bike}) then {
    // a third more weight, centred 40 cm further back
    private _mass = (getMass _car) * 1.3;
    private _com = (getCenterOfMass _car) vectorAdd [0, -0.4, 0];
    if (local _car) then {
        _car setMass _mass;
        _car setCenterOfMass _com;
    } else {
        [_car, _mass] remoteExecCall ["setMass", _car];
        [_car, _com] remoteExecCall ["setCenterOfMass", _car];
    };
    _car setVariable ["ALiVE_vbiedLow", [_mass, _com], true];
};

if (_props isNotEqualTo [] && {!(_car getVariable ["ALiVE_vbiedDeletedEH", false])}) then {
    _car setVariable ["ALiVE_vbiedDeletedEH", true];
    _car addEventHandler ["Deleted", {
        params ["_car"];
        { deleteVehicle _x } forEach (_car getVariable ["ALiVE_vbiedLoad", []]);
    }];
};

if (_props isEqualTo [] && {!_beep} && {!_detect}) exitWith {};

[_car, _charge, _props, _beep, _detect] spawn {
    params ["_car", "_charge", "_props", "_beep", "_detect"];
    private _device = if (isNil QUOTE(ADDON)) then { "MineDetector" } else { ADDON getVariable ["IED_Detection_Device", "MineDetector"] };
    private _mode = if (isNil QUOTE(ADDON)) then { 1 } else { ADDON getVariable ["IED_Detection", 1] };
    if !(_mode isEqualType 0) then { _mode = 1 };
    if (_mode == 0) then { _mode = 1 };
    private _warned = [];
    private _beepAt = -10;
    while { !isNull _car && {alive _car} } do {
        sleep 1;
        if (!isNull _charge && {!isNull _car}) then {
            private _players = (allPlayers - entities "HeadlessClient_F") select { alive _x && {(_x distance _car) < 30} };
            // the timer clip runs just under 6 s, so one after another sounds like one timer
            if (_beep && {time - _beepAt >= 6} && {(_players findIf { (_x distance _car) < 25 }) > -1}) then {
                [_car, "Alive_Beep", 25] call CBA_fnc_globalSay3d;
                _beepAt = time;
            };
            if (_detect) then {
                private _new = _players select {
                    (vehicle _x) == _x && {(_x distance _charge) < 10} && {_device in (items _x)} && {!(_x in _warned)}
                };
                if (_new isNotEqualTo []) then {
                    [_charge, _mode, _new, _mode, _device] call ALiVE_fnc_detectIED;
                    _warned append _new;
                    // kept on the car so a debug check can see who was warned
                    _car setVariable ["ALiVE_vbiedWarned", +_warned];
                };
            };
        };
    };
    // wrecked or deleted: the load goes with it
    { deleteVehicle _x } forEach _props;
};
