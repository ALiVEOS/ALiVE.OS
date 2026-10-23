#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(missileArtillery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_missileArtillery

Description:
A missile launcher with no artillery computer, such as the MK41 VLS, used as
artillery. The engine won't aim one at a map position, so each round is one
guided missile fired at a laser target put on the grid, as its crew would at a
lased target. Shared by Combat Support's player batteries and the AI
Commander's artillery.

Operations:
"isLauncher" - classname, gun or crewman, or a list of them (the first vehicle
    in it). True for a launcher with no artillery computer carrying a long-range
    guided missile that reads as HE or CLUSTER. Kept per class.
"range" - [classname, magazine] -> [min, max] in metres: the missile's own lock
    range, the minimum with 50 m added as the artillery fire checks do.
"setup" - [probe (a gun or class), the battery's guns, [[round, count], ...]] ->
    the rounds, each capped at the missiles the launchers carry (rounds with none
    left are dropped). The launchers are locked against UAV terminals for every
    player, now, after a respawn and for anyone joining later.
"fire" - [guns, magazine, target position, dispersion, rounds, seconds between
    rounds, optional [object, variable name] to publish each missile's flight
    time on] -> [missiles fired, flight time of the last one in seconds]. Must run
    scheduled, where the launchers are local; a launcher on another machine, taken
    over from a UAV terminal or out of that magazine sits the mission out.

Parameters:
Any - the operation's arguments
String - the operation

Returns:
Any - see each operation

Examples:
(begin example)
_isLauncher = ["B_Ship_MRLS_01_F", "isLauncher"] call ALIVE_fnc_missileArtillery;
_band = [["B_Ship_MRLS_01_F", "magazine_Missiles_Cruise_01_x18"], "range"] call ALIVE_fnc_missileArtillery;
_rounds = [[_vls, [_vls], [["HE", 30]]], "setup"] call ALIVE_fnc_missileArtillery;
[[[_vls], "magazine_Missiles_Cruise_01_x18", _pos, 75, 2, 2], "fire"] spawn ALIVE_fnc_missileArtillery;
(end)

See Also:
ALIVE_fnc_isArtillery, ALIVE_fnc_getArtyMagazineType

Author:
Jman
---------------------------------------------------------------------------- */

params [["_args", []], ["_operation", "", [""]]];

private _result = nil;

switch (_operation) do {

    case "isLauncher": {
        _result = _args call {
            private _c = _this;
            if (_c isEqualType []) then {
                private _v = "";
                { if (_v == "" && {_x isEqualType objNull} && {!isNull _x} && {!((vehicle _x) isKindOf "CAManBase")}) then { _v = typeOf vehicle _x } } forEach _c;
                _c = _v;
            };
            if (_c isEqualType objNull) then { _c = if (isNull _c) then { "" } else { typeOf vehicle _c } };
            if (!(_c isEqualType "") || {_c == ""}) exitWith { false };
            if (isNil "ALiVE_missileLaunchers") then { ALiVE_missileLaunchers = createHashMap };
            private _known = ALiVE_missileLaunchers get _c;
            if (!isNil "_known") exitWith { _known };
            // a land-attack missile only, reaching well past any gun: anti-air missiles (a Stinger pod, an AA
            // tank, a SAM site) lock air targets, and an aircraft's missiles (an Apache's Hellfires) reach a few km,
            // and both passed the ordnance test alone. The MK41's cruise missile locks nothing in the air and
            // reaches 32 km
            private _r = getNumber (configFile >> "CfgVehicles" >> _c >> "artilleryScanner") == 0
                && {!(_c isKindOf "Air")}
                && {((_c call ALIVE_fnc_getArtyMagazines) findIf {
                    private _a = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    ((["HE", _x, true] call ALIVE_fnc_isMagazineOfOrdnanceType) || {["CLUSTER", _x, true] call ALIVE_fnc_isMagazineOfOrdnanceType})
                    && {getNumber (_a >> "airLock") == 0}
                    && {getNumber (_a >> "missileLockMaxDistance") >= 15000}
                }) >= 0};
            ALiVE_missileLaunchers set [_c, _r];
            _r
        };
    };

    case "range": {
        _args params [["_class", "", [""]], ["_mag", "", [""]]];
        private _a = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        private _min = ((getNumber (_a >> "missileLockMinDistance")) max 50) + 50;
        private _max = getNumber (_a >> "missileLockMaxDistance");
        if (_max <= 0) then { _max = 100000 };
        _result = [_min, _max];
    };

    case "setup": {
        _result = _args call {
            params ["_probe", "_guns", "_rounds"];
            if !([_probe, "isLauncher"] call ALIVE_fnc_missileArtillery) exitWith { _rounds };
            private _launchers = [];
            { if (_x isEqualType objNull && {!isNull _x}) then { _launchers pushBackUnique (vehicle _x) } } forEach _guns;
            _launchers = _launchers select { !(_x isKindOf "CAManBase") };
            if (_launchers isEqualTo []) exitWith { _rounds };
            private _out = _rounds apply {
                private _mag = [_launchers select 0, _x select 0] call ALIVE_fnc_getArtyMagazineType;
                private _have = 0;
                { { if ((_x select 0) == _mag) then { _have = _have + (_x select 2) } } forEach (magazinesAllTurrets _x) } forEach _launchers;
                [_x select 0, (_x select 1) min _have]
            };
            {
                [_x, {
                    if (!hasInterface) exitWith {};
                    _this spawn {
                        waitUntil { sleep 1; !isNull player };
                        player disableUAVConnectability [_this, true];
                        if (isNil "ALiVE_noUavLaunchers") then {
                            ALiVE_noUavLaunchers = [];
                            player addEventHandler ["Respawn", { { if (!isNull _x) then { (_this select 0) disableUAVConnectability [_x, true] } } forEach ALiVE_noUavLaunchers }];
                        };
                        // a launcher the AI Commander fires is a new object each time it spawns
                        ALiVE_noUavLaunchers = ALiVE_noUavLaunchers - [objNull];
                        ALiVE_noUavLaunchers pushBackUnique _this;
                    };
                }] remoteExec ["call", 0, _x];
            } forEach _launchers;
            _out select { (_x select 1) > 0 }
        };
    };

    // The laser sits on a hidden helper so close air support and the laze task take it for a script's, and the
    // side knows of it only while the missile flies.
    case "fire": {
        _result = _args call {
            params ["_guns", "_ordnance", "_targetPos", ["_dispersion", 0], ["_missionRoundCount", 1], ["_rateOfFire", 0], ["_etaTo", []]];
            private _holds = { params ["_g"]; alive _g && {alive gunner _g} && {local _g} && {!isUAVConnected _g}
                && {(magazinesAllTurrets _g) findIf { (_x select 0) == _ordnance && {(_x select 2) > 0} } > -1} };
            private _launchers = _guns select { [_x] call _holds };
            if (_launchers isEqualTo []) exitWith {
                ["ALiVE missile artillery: %1 has no launcher able to fire %2", typeOf (_guns param [0, objNull]), _ordnance] call ALiVE_fnc_dump;
                [0, 0]
            };
            private _side = side group gunner (_launchers select 0);
            private _ltClass = if (_side getFriend WEST > 0.6) then { "LaserTargetW" } else { "LaserTargetE" };
            private _ammo = getText (configFile >> "CfgMagazines" >> _ordnance >> "ammo");
            private _speed = (getNumber (configFile >> "CfgAmmo" >> _ammo >> "maxSpeed")) max 100;
            private _life = ((getNumber (configFile >> "CfgAmmo" >> _ammo >> "timeToLive")) max 60) + 10;
            // each missile as it leaves, counted, and kept so its laser stays only as long as it flies
            private _projEHs = _launchers apply {
                _x setVariable ["ALiVE_missileMag", _ordnance];
                _x setVariable ["ALiVE_missileShots", 0];
                [_x, _x addEventHandler ["Fired", {
                    params ["_gun", "", "", "", "", "_magazine", "_projectile"];
                    if (_magazine == (_gun getVariable ["ALiVE_missileMag", ""])) then {
                        _gun setVariable ["ALiVE_missileLast", _projectile];
                        _gun setVariable ["ALiVE_missileShots", (_gun getVariable ["ALiVE_missileShots", 0]) + 1];
                    };
                }]]
            };
            private _fired = 0;
            private _lastEta = 0;
            private _next = 0;
            for "_i" from 1 to _missionRoundCount do {
                // the next launcher still able to fire, in turn
                private _gun = objNull;
                for "_k" from 0 to (count _launchers - 1) do {
                    private _g = _launchers select ((_next + _k) mod (count _launchers));
                    if (isNull _gun && {[_g] call _holds}) then { _gun = _g; _next = _next + _k + 1 };
                };
                if (isNull _gun) exitWith {};
                // the weapon and turret holding the round, with the round loaded
                private _wt = [];
                { private _t = _x; { if (_wt isEqualTo [] && {_ordnance in compatibleMagazines _x}) then { _wt = [_x, _t] } } forEach (_gun weaponsTurret _t) } forEach ([[-1]] + allTurrets [_gun, false]);
                if (_wt isEqualTo []) exitWith {};
                _wt params ["_weapon", "_path"];
                if ((_gun currentMagazineTurret _path) != _ordnance) then { _gun loadMagazine [_path, _weapon, _ordnance]; sleep 1 };
                if ((_gun currentMagazineTurret _path) != _ordnance) exitWith {
                    ["ALiVE missile artillery: %1 couldn't load %2", typeOf _gun, _ordnance] call ALiVE_fnc_dump;
                };
                private _at = if (_dispersion > 50) then { _targetPos getPos [(_dispersion - 50), random 360] } else { +_targetPos };
                _at set [2, 0];
                private _helper = createVehicle ["Land_HelipadEmpty_F", _at, [], 0, "CAN_COLLIDE"];
                private _lt = createVehicle [_ltClass, _at, [], 0, "CAN_COLLIDE"];
                _lt attachTo [_helper, [0, 0, 1]];
                // the flight, for the splash call: straight out at the missile's speed, and a little for the climb and dive
                private _eta = round ((_gun distance2D _at) / _speed + 15);
                _side reportRemoteTarget [_lt, 320];
                _lt confirmSensorTarget [_side, true];
                (gunner _gun) reveal [_lt, 4];
                (gunner _gun) doTarget _lt;
                sleep 1;
                if (_etaTo isNotEqualTo []) then { (_etaTo select 0) setVariable [_etaTo select 1, _eta] };
                _gun setVariable ["ALiVE_missileLast", objNull];
                private _before = _gun getVariable ["ALiVE_missileShots", 0];
                // asked again every 2 s until it fires, for up to 5 minutes: a launcher that has just fired, or changed missile
                // type, is still reloading (the MK41 takes about 3 minutes to change between its HE and cluster missiles, and
                // nothing it reports says when it's ready, so it's simply asked until it fires)
                private _t = time;
                private _asked = -1;
                waitUntil {
                    if (time - _asked >= 2) then { _asked = time; _gun fireAtTarget [_lt, _weapon] };
                    sleep 0.5;
                    (_gun getVariable ["ALiVE_missileShots", 0]) > _before || {time - _t > 300} || {!([_gun] call _holds)}
                };
                if (time - _t > 10 && {(_gun getVariable ["ALiVE_missileShots", 0]) > _before}) then { ["ALiVE missile artillery: %1 fired %2 after %3 s", typeOf _gun, _ordnance, round (time - _t)] call ALiVE_fnc_dump };
                // a missile that doesn't leave ends the mission, so the caller says it couldn't fire rather than waiting on
                // every round in turn
                if ((_gun getVariable ["ALiVE_missileShots", 0]) == _before) exitWith {
                    ["ALiVE missile artillery: %1 didn't fire at %2 (at %3 m ASL, weapon state %4)", typeOf _gun, mapGridPosition _at, round ((getPosASL _gun) select 2), weaponState [_gun, _path, _weapon]] call ALiVE_fnc_dump;
                    _side reportRemoteTarget [_lt, 0];
                    deleteVehicle _lt; deleteVehicle _helper;
                };
                _fired = _fired + 1;
                _lastEta = _eta;
                // away: the missile steers by the side's report of the laser all the way in (withdrawn at launch, it landed
                // 131 m off instead of 2 to 4 m), so the report and the laser are kept until the missile is gone, then dropped
                _side reportRemoteTarget [_lt, _life];
                [_helper, _lt, _gun getVariable ["ALiVE_missileLast", objNull], _life, _side] spawn {
                    params ["_h", "_l", "_p", "_life", "_s"];
                    private _t = time;
                    waitUntil { sleep 1; isNull _p || {time - _t > _life} };
                    sleep 5;
                    _s reportRemoteTarget [_l, 0];
                    deleteVehicle _l; deleteVehicle _h;
                };
                sleep (_rateOfFire max 2);
            };
            {
                _x params ["_g", "_eh"];
                if (!isNull _g) then {
                    _g removeEventHandler ["Fired", _eh];
                    _g setVariable ["ALiVE_missileMag", nil];
                };
            } forEach _projEHs;
            [_fired, _lastEta]
        };
    };
};

if (isNil "_result") then { nil } else { _result };
