/*
 * Filename:
 * playerFiredEH.sqf
 *
 * Description: Keeps a record of shots fired for each player. Fires globally, but only executed where player is local. Does not capture players firing from vehicles, see firedEH.
 *
 *
 * Created by Tupolov
 * Jman
 * Creation date: 19/05/2012
 *
 * */

// ====================================================================================
// MAIN

// #define DEBUG_MODE_FULL
#include "script_component.hpp"
if (GVAR(ENABLED)) then {
    private ["_player","_weapon","_muzzle"];

    _player = _this select 0;
    _weapon = _this select 1;
    _muzzle = _this select 2;

    if (player == _player || local _player) then {

        private ["_shotsfired","_weaponName","_i","_shots","_idx"];

        //["playerFired: type:%1, vehicle:%2, %3", typeof _player, typeof vehicle _player, _this] call ALiVE_fnc_dump;

        _shotsfired = GVAR(playerShotsFired);

        // Find weapon in array
        _i = 0;
        _idx = 0;
        {
            private ["_currentWeapon"];
            _currentWeapon = _x;
            if ((_currentWeapon select 0) == _muzzle) then {
                _idx = _i;
            };
            _i = _i + 1;
        } foreach _shotsfired;

        _weaponName = getText (configFile >> "cfgWeapons" >> _weapon >> "displayName");

        private _lastWeapon = [_weapon, _weaponName];
        if (_weaponName == "Throw") then {
            _weaponName = getText (configFile >> "cfgWeapons" >> _weaponName >> _muzzle >> "displayName");
            _lastWeapon set [1, _weaponName];
            _weapon = _muzzle;
        };

        // The last weapon he fired, for a kill credited to him while he holds none (an ACE player
        // with his weapon put away reads no weapon, and the kill was recorded as UNKNOWN).
        // Shared only when it changes, not on every shot.
        if !((_player getVariable [QGVAR(lastWeapon), []]) isEqualTo _lastWeapon) then {
            _player setVariable [QGVAR(lastWeapon), _lastWeapon, true];
        };

        // A grenade or charge goes off later, when he may hold his rifle again, and a kill it made was recorded
        // with that rifle. The blast is kept on him as it happens, what it was, when and where, for the kill
        // handler to find.
        private _proj = _this param [6, objNull];
        if ((_this select 1) in ["Throw", "Put"] && {!isNull _proj}) then {
            private _mag = _this param [5, ""];
            private _magName = getText (configFile >> "CfgMagazines" >> _mag >> "displayName");
            _proj setVariable [QGVAR(blastBy), [_player, _this select 1, [_magName, _weaponName] select (_magName == "")]];
            _proj addEventHandler ["Explode", {
                params ["_p", "_pos"];
                (_p getVariable [QGVAR(blastBy), []]) params [["_u", objNull], ["_type", ""], ["_name", ""]];
                if (!isNull _u) then { _u setVariable [QGVAR(lastBlast), [_type, _name, serverTime, _pos], true] };
            }];
        };

        // Add weapon count to array
        if (_idx == 0) then {
            _shotsfired set [_i, [_muzzle, 1, _weapon, _weaponName]];

        } else {
            _shots = (_shotsfired select _idx) select 1;
            _shotsfired set [_idx, [_muzzle, _shots + 1, _weapon, _weaponName]];
        };

        // ["SF: %1", _shotsfired] call ALiVE_fnc_dump;

        GVAR(playerShotsFired) = _shotsfired;
    };
};
// ====================================================================================