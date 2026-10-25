#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(createDrivenVBIED);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createDrivenVBIED

Description:
A car bomb driven at a player: a car of the bomber faction is made on a road
near the insurgents who sent it, at least 150 m from its target and with no
player within 150 m of it, and a driver takes it after him. It goes off when it
gets within 15 m of him, when the driver is killed, when the car is wrecked, or
when something explodes under it. Shooting the car body does not set it off;
killing the driver does.

A car that hasn't moved for 20 s is given its order again. One still stuck at
40 s goes off if its target is within 100 m; otherwise it's moved to another
road when no player is within 1 km of it, and left to try again if one is.
After 5 minutes without getting there it goes off if its target is within
100 m, and is removed otherwise. Whatever happens, the driver doesn't outlive
it, so the player can be sent another.

Parameters:
Array - where it starts
Object - the player it goes after
String - the faction of the car and its driver

Returns:
Object - the driver, or objNull when nothing could be made

Author:
Jman
---------------------------------------------------------------------------- */

params ["_from", "_victim", ["_faction", "CIV_F"]];

if (!isServer || {isNull _victim}) exitWith { objNull };
private _debug = ADDON getVariable ["debug", false];

// a car of the faction with a seat or two: not a bike, a quad, a drone or anything armoured
private _cars = ([1, _faction, "Car"] call ALIVE_fnc_findVehicleType) select {
    !(_x isKindOf "Quadbike_01_base_F") && {!(_x isKindOf "Motorcycle")} && {!(_x isKindOf "vn_bicycle_base")}
    && {!(_x isKindOf "Wheeled_APC_F")} && {!(_x isKindOf "MRAP_01_base_F")} && {!(_x isKindOf "MRAP_02_base_F")}
    && {!(_x isKindOf "MRAP_03_base_F")} && {!(_x isKindOf "UGV_01_base_F")} && {!(_x isKindOf "UGV_02_Base_F")}
    && {getNumber (configFile >> "CfgVehicles" >> _x >> "armor") <= 250}
};
if (_cars isEqualTo []) exitWith {
    if (_debug) then { ["ALIVE-%1 Car bomb: the faction %2 has no car to drive", time, _faction] call ALiVE_fnc_dump };
    objNull
};
private _driverClass = ([[_faction], 1, ALiVE_MIL_CQB_UNITBLACKLIST, false] call ALiVE_fnc_chooseRandomUnits) param [0, ""];
if (_driverClass == "") exitWith {
    if (_debug) then { ["ALIVE-%1 Car bomb: the faction %2 has no one to drive", time, _faction] call ALiVE_fnc_dump };
    objNull
};

// a road it can start on: near the insurgents, at least 150 m from its target, no player within 150 m, nothing on it
private _fnc_freeRoad = {
    params ["_around", "_radius"];
    private _ok = (_around nearRoads _radius) select {
        private _p = getPos _x;
        (_p distance2D (vehicle _victim)) > 150
        && {([_p, 150] call ALiVE_fnc_anyPlayersInRange) == 0}
        && {(_p nearEntities [["LandVehicle", "Man"], 8]) isEqualTo []}
        && {!surfaceIsWater _p}
    };
    if (_ok isEqualTo []) then { [] } else { getPos (selectRandom _ok) }
};
private _at = [_from, 300] call _fnc_freeRoad;
if (_at isEqualTo []) exitWith {
    if (_debug) then { ["ALIVE-%1 Car bomb: no clear road within 300 m of %2", time, mapGridPosition _from] call ALiVE_fnc_dump };
    objNull
};

private _car = createVehicle [selectRandom _cars, _at, [], 0, "NONE"];
_car setDir (_at getDir _victim);
private _grp = createGroup [[_faction] call ALiVE_fnc_factionSide, true];
private _driver = if (isNull _grp) then { objNull } else { _grp createUnit [_driverClass, _at, [], 0, "NONE"] };
if (!isNull _driver) then { _driver moveInDriver _car };
// nobody in the driver's seat: nothing goes after the player, and the car goes without a blast
if (isNull _driver || {vehicle _driver != _car}) exitWith {
    if (_debug) then { ["ALIVE-%1 Car bomb: no driver for the %2 (made %3, in it %4)", time, typeOf _car, !isNull _driver, !isNull _driver && {vehicle _driver == _car}] call ALiVE_fnc_dump };
    if (!isNull _driver) then { deleteVehicle _driver };
    deleteVehicle _car;
    objNull
};
// kept on the server, as a headless client given the group would run none of the chase below
{ _x setVariable ["ALiVE_ignore_HC", true, true]; _x setVariable ["ALiVE_advciv_blacklist", true, true] } forEach [_driver, _car];
_grp setBehaviour "CARELESS";
_grp setSpeedMode "FULL";
_driver allowFleeing 0;

// the charge, under the car as a parked car bomb's is; anything exploding under it sets the car off. Rigged here
// rather than by createVBIED, which leaves a car alone outside the module's area or not on its car bomb side.
private _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo", getPosATL _car, [], 0, "CAN_COLLIDE"];
_charge attachTo [_car, [0, -1, -1.08]];
_charge setVectorUp [0, 0, -1];
_charge addEventHandler ["HandleDamage", {
    params ["_charge", "", "_damage"];
    // a stray fragment from another blast doesn't set it off (see createVBIED)
    if (_damage < 0.3) exitWith { 0 };
    private _car = attachedTo _charge;
    if (!isNull _car && {!(_car getVariable ["ALiVE_carBombGone", false])}) then {
        _car setVariable ["ALiVE_carBombGone", true];
        private _shell = [["Bomb_04_F","Bomb_03_F","R_60mm_HE"],[3,3,1]] call BIS_fnc_selectRandomWeighted;
        _shell createVehicle [(getPos _car) select 0, (getPos _car) select 1, 0];
    };
    deleteVehicle _charge;
    0
}];

if (_debug) then {
    ["ALIVE-%1 Car bomb: %2 driven by %3 after %4 from %5, %6 m away", time, typeOf _car, typeOf _driver, name _victim, mapGridPosition _at, round (_at distance2D _victim)] call ALiVE_fnc_dump;
};

[_car, _driver, _victim, _debug, _fnc_freeRoad] spawn {
    params ["_car", "_driver", "_victim", "_debug", "_fnc_freeRoad"];
    private _fnc_blast = {
        params ["_car"];
        // a car taken away by something else (a clean-up, Zeus) has nowhere to go off
        if (isNull _car || {_car getVariable ["ALiVE_carBombGone", false]}) exitWith {};
        _car setVariable ["ALiVE_carBombGone", true];
        private _shell = [["Bomb_04_F","Bomb_03_F","R_60mm_HE"],[3,3,1]] call BIS_fnc_selectRandomWeighted;
        _shell createVehicle [(getPos _car) select 0, (getPos _car) select 1, 0];
        { if (typeOf _x == "ALIVE_DemoCharge_Remote_Ammo") then { deleteVehicle _x } } forEach attachedObjects _car;
    };
    private _end = time + 300;
    private _orderAt = -15;     // when it was last sent after the player
    private _retryAt = -15;     // when a stuck car was last given a nudge
    private _movedAt = time;
    private _lastPos = getPos _car;
    private _how = "timeout";
    waitUntil {
        sleep 1;
        private _near = (_car distance (vehicle _victim)) < 100;
        if (time - _orderAt > 5 && {alive _driver} && {alive _victim}) then {
            [_driver, getPos _victim] remoteExecCall ["doMove", _driver];
            _orderAt = time;
        };
        if ((_car distance2D _lastPos) > 5) then { _movedAt = time; _lastPos = getPos _car; };
        // stuck: a nudge 30 m on towards the target at 20 s, then at 40 s moved to another road where nobody's near
        if (time - _movedAt > 20 && {alive _driver}) then {
            if (time - _movedAt > 40) then {
                if (_near) exitWith { _how = "stuck" };
                if (([getPos _car, 1000] call ALiVE_fnc_anyPlayersInRange) == 0) then {
                    private _to = [getPos _car, 300] call _fnc_freeRoad;
                    if (_to isNotEqualTo []) then { _car setPos _to; _lastPos = getPos _car; };
                };
                _movedAt = time;
            } else {
                if (time - _retryAt > 10) then {
                    [_driver, (getPos _car) getPos [30, _car getDir _victim]] remoteExecCall ["doMove", _driver];
                    _retryAt = time;
                    _orderAt = time;
                };
            };
        };
        if (_how == "stuck") exitWith { true };
        if (!alive _car || {_car getVariable ["ALiVE_carBombGone", false]}) exitWith { _how = "destroyed"; true };
        if (!alive _driver || {vehicle _driver != _car}) exitWith { _how = "driver"; true };
        if (!alive _victim) exitWith { _how = "victim"; true };
        if ((_car distance (vehicle _victim)) < 15) exitWith { _how = "reached"; true };
        time > _end
    };
    switch (_how) do {
        case "reached";
        case "stuck";
        case "driver";
        case "destroyed": {
            [_car] call _fnc_blast;
        };
        default {
            // out of time, or its target died: goes off only if he's close, otherwise it's taken away
            if (alive _victim && {(_car distance (vehicle _victim)) < 100}) then {
                [_car] call _fnc_blast;
            } else {
                { deleteVehicle _x } forEach (attachedObjects _car);
                deleteVehicle _car;
            };
        };
    };
    // the driver never outlives it, so the player he was after can be sent another
    if (alive _driver) then {
        if (!isNull _car && {!alive _car || {_car getVariable ["ALiVE_carBombGone", false]}}) then { _driver setDamage 1 } else { deleteVehicle _driver };
    };
    if (_debug) then { ["ALIVE-%1 Car bomb: ended (%2)", time, _how] call ALiVE_fnc_dump };
};

_driver
