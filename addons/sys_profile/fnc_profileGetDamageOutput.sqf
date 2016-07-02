#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileGetDamageOutput);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileGetDamageOutput

Description:
Returns the total damage that a profile can inflict on another.
Takes into account profile type, number of units in a squad, vehicles it commands, hit chance, and critical hits
Damage is measured per second

Parameters:
Array -
    Array - Attacking profile
    Array - Victim profile

Returns:
Scalar - total damage output of a profile

Examples:
(begin example)
// get damage output of profile
_damageOutput = [_attacker,_victim] call ALiVE_fnc_profileGetDamageOutput;
(end)

See Also:

Author:
SpyderBlack

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params ["_attacker","_victim"];

private _damageOutput = 0;
private _hitChance = 1;
private _critChance = 0;            // simulates hit such as a helicopter using rocket, inf using rpg
private _critDamage = 0;

if ((_attacker select 2 select 5) == "entity") then {               // [_attacker,"type"] call ALiVE_fnc_hashGet

    //--------------------------
    // attacker is infantry squad
    //--------------------------

     private _unitCount = count (_attacker select 2 select 11);     // [_attacker,"unitClasses"] call ALiVE_fnc_hashGet

    if ((_victim select 2 select 5) == "entity") then {             // [_victim,"type"] call ALiVE_fnc_hashGet

        // victim is infantry squad
        // figure damage of inf vs inf

        _hitChance = 0.75;
        _damageOutput = 0.015 * _unitCount;
        _critChance = 0.15;
        _critDamage = 0.04 * _unitCount;

    } else {

        // victim is in vehicle(s)
        // figure damage of inf vs veh

        private _victimObjectType = _victim select 2 select 6;      // [_victim,"objectType"] call ALiVE_fnc_hashGet

        switch (toLower _victimObjectType) do {
            case "car": {
                _hitChance = 0.90;
                _damageOutput = 0.03 * _unitCount;
                _critChance = 0.15;
                _critDamage = 3 + _damageOutput;
            };
            case "truck": {
                _hitChance = 0.90;
                _damageOutput = 0.03 * _unitCount;
                _critChance = 0.2;
                _critDamage = 3 + _damageOutput;
            };
            case "armored": {
                _hitChance = 0.90;
                _damageOutput = 0.02 * _unitCount;
                _critChance = 0.2;
                _critDamage = 2.5 + _damageOutput;
            };
            case "tank": {
                _hitChance = 0.90;
                _damageOutput = 0.01 * _unitCount;
                _critChance = 0.2;
                _critDamage = 2 + _damageOutput;
            };
            case "ship": {
                _hitChance = 0.75;
                _damageOutput = 0.05 * _unitCount;
                _critChance = 0.1;
                _critDamage = 3 + _damageOutput;
            };
            case "helicopter": {
                _hitChance = 0.3;
                _damageOutput = 0.075 * _unitCount;
                _critChance = 0.2;
                _critDamage = 4 + _damageOutput;
            };
            case "plane": {
                _hitChance = 0.10;
                _damageOutput = 0;
                _critChance = 1;
                _critDamage = 4;
            };
        };

    };

} else {

    //--------------------------
    // attacker is in vehicle(s)
    //--------------------------

    if (([_victim,"type"] call ALiVE_fnc_hashGet) == "entity") then {

        // victim is infantry squad
        // figure damage of veh vs inf
_damageOutput = 0.2;
/*         private _victimObjectType = _victim select 2 select 6; // [_victim,"objectType"] call ALiVE_fnc_hashGet

        switch (toLower _victimObjectType) do {
            case "car": {
                private _victimVehicleClass = _victim select 2 select 11; // [_victim,"vehicleClass"] call ALiVE_fnc_hashGet

                if ([_victimVehicleClass] call ALiVE_fnc_isArmed) then {
                    _hitChance = 0.80;
                    _damageOutput = 0.15;
                    _critChance = 0.15;
                    _critDamage = 1;
                } else {
                    private _commandingEntity = [MOD(profileHandler),"getProfile", (_victim select 2 select 8) select 0] call ALiVE_fnc_profileHandler;
                    private _unitCount = count (_attacker select 2 select 11);

                    _hitChance = 0.75;
                    _damageOutput = 0.015 * _unitCount;
                    _critChance = 0.15;
                    _critDamage = 0.04 * _unitCount;
                };
            };
            case "truck": {
                private _victimVehicleClass = _victim select 2 select 11; // [_victim,"vehicleClass"] call ALiVE_fnc_hashGet

                if ([_victimVehicleClass] call ALiVE_fnc_isArmed) then {
                    _hitChance = 0.80;
                    _damageOutput = 0.175;
                    _critChance = 0.15;
                    _critDamage = 1.1;
                } else {
                    private _commandingEntity = [MOD(profileHandler),"getProfile", (_victim select 2 select 8) select 0] call ALiVE_fnc_profileHandler;
                    private _unitCount = count (_attacker select 2 select 11);

                    _hitChance = 0.75;
                    _damageOutput = 0.015 * _unitCount;
                    _critChance = 0.15;
                    _critDamage = 0.04 * _unitCount;
                };
            };
            case "armored": {

            };
            case "tank": {
                private _victimVehicleClass = _victim select 2 select 11; // [_victim,"vehicleClass"] call ALiVE_fnc_hashGet

                switch true do {
                    case ([_victimVehicleClass] call ALiVE_fnc_isAA): {

                    };
                    case ([_victimVehicleClass] call ALiVE_fnc_isArtillery): {
                        _attackerPos = _attacker select 2 select 2; // [_attacker,"position"] call ALiVE_fnc_hashGet
                        _victimPos = _victim select 2 select 2;     // [_victim,"position"] call ALiVE_fnc_hashGet

                        if (_attackerPos distance2D _victimPos < 300) then {
                            // secondary weapon

                        } else {
                            // main gun

                        };
                    };
                    default {
                        // same as armored
                    };
                };
            };
            case "ship": {
                _hitChance = 0.50;
                _damageOutput = 0.2;
                _critChance = 0.15;
                _critMultiplier = 2;
            };
            case "helicopter": {
                _hitChance = 0.60;
                _damageOutput = 0.2;
                _critChance = 0.15;
                _critMultiplier = 3;
            };
            case "plane": {

            };
        }; */

    } else {
_damageOutput = 0.2;
        // victim is in vehicle(s)
        // figure damage of veh vs veh

    };

};

if (random 1 <= _hitChance) then {
    if (random 1 <= _critChance) then {
        _damageOutput = _critDamage;
    };
} else {
    _damageOutput = 0;
};

_damageOutput