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

private [
    "_damageOutput","_hitChance","_critChance","_critDamage","_unitCount","_victimObjectType",
    "_attackerObjectType","_attackerVehicleClass","_commandingEntity","_attackerPos","_victimPos",
    "_attackDistance","_accuracyModifier"
];
params ["_attacker","_victim"];

_damageOutput = 0;
_hitChance = 1;
_critChance = 0;            // simulates hit such as a helicopter using rocket, inf using rpg
_critDamage = 0;

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
            default {
                _hitChance = 0.90;
                _damageOutput = 0.03 * _unitCount;
                _critChance = 0.15;
                _critDamage = 3 + _damageOutput;
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

        private _attackerObjectType = _attacker select 2 select 6; // [_attacker,"objectType"] call ALiVE_fnc_hashGet

        switch (toLower _attackerObjectType) do {
            case "car": {
                private _attackerVehicleClass = _attacker select 2 select 11; // [_attacker,"vehicleClass"] call ALiVE_fnc_hashGet

                if ([_attackerVehicleClass] call ALiVE_fnc_isArmed) then {
                    _hitChance = 0.80;
                    _damageOutput = 0.15;
                    _critChance = 0.15;
                    _critDamage = 1;
                } else {
                    private _commandingEntity = [MOD(profileHandler),"getProfile", (_attacker select 2 select 8) select 0] call ALiVE_fnc_profileHandler;
                    private _unitCount = count (_attacker select 2 select 11);

                    _hitChance = 0.75;
                    _damageOutput = 0.015 * _unitCount;
                    _critChance = 0.15;
                    _critDamage = 0.04 * _unitCount;
                };
            };
            case "truck": {
                private _attackerVehicleClass = _attacker select 2 select 11; // [_attacker,"vehicleClass"] call ALiVE_fnc_hashGet

                if ([_attackerVehicleClass] call ALiVE_fnc_isArmed) then {
                    _hitChance = 0.80;
                    _damageOutput = 0.175;
                    _critChance = 0.15;
                    _critDamage = 1.1;
                } else {
                    private _commandingEntity = [MOD(profileHandler),"getProfile", (_attacker select 2 select 8) select 0] call ALiVE_fnc_profileHandler;
                    private _unitCount = count (_attacker select 2 select 11);

                    _hitChance = 0.75;
                    _damageOutput = 0.015 * _unitCount;
                    _critChance = 0.15;
                    _critDamage = 0.04 * _unitCount;
                };
            };
            case "armored": {
                _hitChance = 0.70;
                _damageOutput = 0.25;
                _critChance = 0.15;
                _critDamage = 1.1;
            };
            case "tank": {
                private _attackerVehicleClass = _attacker select 2 select 11; // [_attacker,"vehicleClass"] call ALiVE_fnc_hashGet

                switch true do {
                    case ([_attackerVehicleClass] call ALiVE_fnc_isAA): {
                        _hitChance = 0.90;
                        _damageOutput = 0.175;
                        _critChance = 0.15;
                        _critDamage = 1.5;
                    };
                    case ([_attackerVehicleClass] call ALiVE_fnc_isArtillery): {
                        _attackerPos = _attacker select 2 select 2; // [_attacker,"position"] call ALiVE_fnc_hashGet
                        _victimPos = _victim select 2 select 2;     // [_victim,"position"] call ALiVE_fnc_hashGet
                        _attackDistance = _attackerPos distance2D _victimPos;

                        if (_attackDistance < 300) then {
                            // secondary weapon
                            _hitChance = 0.70;
                            _damageOutput = 0.2;
                            _critChance = 0.15;
                            _critDamage = 1;
                        } else {
                            // main gun
                            _accuracyModifier = (_attackDistance / 100000);

                            _hitChance = 0.35 - _accuracyModifier;
                            _damageOutput = 0.15;
                            _critChance = _hitChance / 2.3;
                            _critDamage = 2;
                        };
                    };
                    default {
                        _hitChance = 0.70;
                        _damageOutput = 0.20;
                        _critChance = 0.2;
                        _critDamage = 1.75;
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
                _critMultiplier = 2.5;
            };
            case "plane": {
                _hitChance = 0.50;
                _damageOutput = 1;
                _critChance = 0.2;
                _critMultiplier = 2;
            };
            default {
                _hitChance = 0.80;
                _damageOutput = 0.15;
                _critChance = 0.15;
                _critDamage = 1;
            };
        };

    } else {

        // victim is in vehicle(s)
        // figure damage of veh vs veh

        private _attackerObjectType = toLower (_attacker select 2 select 6);    // [_attacker,"objectType"] call ALiVE_fnc_hashGet
        private _victimObjectType = toLower (_victim select 2 select 6);        // [_victim,"objectType"] call ALiVE_fnc_hashGet

        switch (_attackerObjectType) do {
            case "car": {
                switch true do {
                    case (_victimObjectType in ["car","truck"]): {
                        _hitChance = 0.825;
                        _damageOutput = 0.22;
                        _critChance = 0.2;
                        _critDamage = 0.8;
                    };
                    case (_victimObjectType in ["armored","tank"]): {
                        _hitChance = 0.85;
                        _damageOutput = 0.075;
                        _critChance = 0.1;
                        _critDamage = 0.5;
                    };
                    case (_victimObjectType == "ship"): {
                        _hitChance = 0.65;
                        _damageOutput = 0.25;
                        _critChance = 0.2;
                        _critDamage = 1.2;
                    };
                    case (_victimObjectType in ["helicopter","plane"]): {
                        _hitChance = 0.25;
                        _damageOutput = 0.28;
                        _critChance = 0.1;
                        _critDamage = 2;
                    };
                };
            };
            case "truck": {
                switch true do {
                    case (_victimObjectType in ["car","truck"]): {
                        _hitChance = 0.825;
                        _damageOutput = 0.24;
                        _critChance = 0.2;
                        _critDamage = 0.9;
                    };
                    case (_victimObjectType in ["armored","tank"]): {
                        _hitChance = 0.85;
                        _damageOutput = 0.085;
                        _critChance = 0.1;
                        _critDamage = 0.6;
                    };
                    case (_victimObjectType == "ship"): {
                        _hitChance = 0.65;
                        _damageOutput = 0.27;
                        _critChance = 0.2;
                        _critDamage = 1.3;
                    };
                    case (_victimObjectType in ["helicopter","plane"]): {
                        _hitChance = 0.25;
                        _damageOutput = 0.30;
                        _critChance = 0.1;
                        _critDamage = 2.1;
                    };
                };
            };
            case "armored": {
                switch true do {
                    case (_victimObjectType in ["car","truck"]): {
                        _hitChance = 0.6;
                        _damageOutput = 0.4;
                        _critChance = 0.1;
                        _critDamage = 1.3;
                    };
                    case (_victimObjectType in ["armored","tank"]): {
                        _hitChance = 0.65;
                        _damageOutput = 0.2;
                        _critChance = 0.125;
                        _critDamage = 1;
                    };
                    case (_victimObjectType == "ship"): {
                        _hitChance = 0.35;
                        _damageOutput = 0.5;
                        _critChance = 0.075;
                        _critDamage = 2;
                    };
                    case (_victimObjectType in ["helicopter","plane"]): {
                        _hitChance = 0.25;
                        _damageOutput = 0.4;
                        _critChance = 0.1;
                        _critDamage = 0.8;
                    };
                };
            };
            case "tank": {
                private _attackerVehicleClass = _attacker select 2 select 11; // [_attacker,"vehicleClass"] call ALiVE_fnc_hashGet

                switch true do {
                    case ([_attackerVehicleClass] call ALiVE_fnc_isAA): {
                        if (_victimObjectType in ["helicopter","plane"]) then {
                            _hitChance = 0.38;
                            _damageOutput = 0.3;
                            _critChance = 0.25;
                            _critDamage = 1;
                        } else {
                            _hitChance = 0.80;
                            _damageOutput = 0.15;
                            _critChance = 0.15;
                            _critDamage = 0.5;
                        };
                    };
                    case ([_attackerVehicleClass] call ALiVE_fnc_isArtillery): {
                        _attackerPos = _attacker select 2 select 2; // [_attacker,"position"] call ALiVE_fnc_hashGet
                        _victimPos = _victim select 2 select 2;     // [_victim,"position"] call ALiVE_fnc_hashGet
                        _attackDistance = _attackerPos distance2D _victimPos;

                        if (_attackDistance < 300) then {
                            // secondary weapon
                                switch true do {
                                    case (_victimObjectType in ["car","truck"]): {
                                        _hitChance = 0.825;
                                        _damageOutput = 0.24;
                                        _critChance = 0.2;
                                        _critDamage = 1.4;
                                    };
                                    case (_victimObjectType in ["armored","tank"]): {
                                        _hitChance = 0.85;
                                        _damageOutput = 0.085;
                                        _critChance = 0.1;
                                        _critDamage = 0.2;
                                    };
                                    case (_victimObjectType == "ship"): {
                                        _hitChance = 0.45;
                                        _damageOutput = 0.3;
                                        _critChance = 0.2;
                                        _critDamage = 1.2;
                                    };
                                    case (_victimObjectType in ["helicopter","plane"]): {
                                        _hitChance = 0.15;
                                        _damageOutput = 0.5;
                                        _critChance = 0.4;
                                        _critDamage = 1.7;
                                    };
                                };
                        } else {
                            // main gun
                            _accuracyModifier = (_attackDistance / 100000);

                            switch true do {
                                case (_victimObjectType in ["car","truck"]): {
                                    _hitChance = 0.35 - _accuracyModifier;
                                    _damageOutput = 0.4;
                                    _critChance = _hitChance / 2.3;
                                    _critDamage = 0.8;
                                };
                                case (_victimObjectType in ["armored","tank"]): {
                                    _hitChance = 0.35 - _accuracyModifier;
                                    _damageOutput = 0.3;
                                    _critChance = _hitChance / 2.3;
                                    _critDamage = 0.5;
                                };
                                case (_victimObjectType == "ship"): {
                                    _hitChance = 0.35 - _accuracyModifier;
                                    _damageOutput = 0.7;
                                    _critChance = _hitChance / 2.3;
                                    _critDamage = 1.4;
                                };
                                case (_victimObjectType in ["helicopter","plane"]): {
                                    _hitChance = 0.01; // why not
                                    _damageOutput = 0.15;
                                    _critChance = 1;
                                    _critDamage = 20;
                                };
                            };
                        };
                    };
                    default {
                        _hitChance = 0.70;
                        _damageOutput = 0.20;
                        _critChance = 0.2;
                        _critDamage = 1.75;
                    };
                };
            };
            case "ship": {
                switch true do {
                    case (_victimObjectType in ["car","truck"]): {
                        _hitChance = 0.75;
                        _damageOutput = 0.25;
                        _critChance = 0.2;
                        _critDamage = 1.4;
                    };
                    case (_victimObjectType in ["armored","tank"]): {
                        _hitChance = 0.85;
                        _damageOutput = 0.11;
                        _critChance = 0.1;
                        _critDamage = 1;
                    };
                    case (_victimObjectType == "ship"): {
                        _hitChance = 0.65;
                        _damageOutput = 0.25;
                        _critChance = 0.2;
                        _critDamage = 1.2;
                    };
                    case (_victimObjectType in ["helicopter","plane"]): {
                        _hitChance = 0.25;
                        _damageOutput = 0.35;
                        _critChance = 0.1;
                        _critDamage = 2;
                    };
                };
            };
            case "helicopter": {
                switch true do {
                    case (_victimObjectType in ["car","truck"]): {
                        _hitChance = 0.7;
                        _damageOutput = 0.3;
                        _critChance = 0.18;
                        _critDamage = 1.5;
                    };
                    case (_victimObjectType in ["armored","tank"]): {
                        _hitChance = 0.75;
                        _damageOutput = 0.225;
                        _critChance = 0.14;
                        _critDamage = 1.5;
                    };
                    case (_victimObjectType == "ship"): {
                        _hitChance = 0.5;
                        _damageOutput = 0.2;
                        _critChance = 0.1;
                        _critDamage = 2;
                    };
                    case (_victimObjectType in ["helicopter","plane"]): {
                        _hitChance = 0.25;
                        _damageOutput = 0.24;
                        _critChance = 0.3;
                        _critDamage = 1.7;
                    };
                };
            };
            case "plane": {
                switch true do {
                    case (_victimObjectType in ["car","truck"]): {
                        _hitChance = 0.4;
                        _damageOutput = 0.7;
                        _critChance = 0.2;
                        _critDamage = 1;
                    };
                    case (_victimObjectType in ["armored","tank"]): {
                        _hitChance = 0.47;
                        _damageOutput = 0.4;
                        _critChance = 0.18;
                        _critDamage = 1.3;
                    };
                    case (_victimObjectType == "ship"): {
                        _hitChance = 0.3;
                        _damageOutput = 0.5;
                        _critChance = 0.35;
                        _critDamage = 1.5;
                    };
                    case (_victimObjectType in ["helicopter","plane"]): {
                        _hitChance = 0.2;
                        _damageOutput = 0.8;
                        _critChance = 0.3;
                        _critDamage = 2;
                    };
                };
            };
            default {
                _hitChance = 0.65;
                _damageOutput = 0.2;
                _critChance = 0.125;
                _critDamage = 1;
            };
        };

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