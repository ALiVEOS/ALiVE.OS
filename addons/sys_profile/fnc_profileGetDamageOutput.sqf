#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileGetDamageOutput);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileGetDamageOutput

Description:
Returns the total damage that a profile can inflict on another.
Takes into account profile type, number of units in a squad, vehicles it commands, hit chance, and critical hits

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
_damageOutput = 0.05;
    //--------------------------
    // attacker is infantry squad
    //--------------------------

/*     private _unitCount = count (_attacker select 2 select 11);   // [_attacker,"unitClasses"] call ALiVE_fnc_hashGet

    if ((_victim select 2 select 5) == "entity") then {             // [_victim,"type"] call ALiVE_fnc_hashGet

        // victim is infantry squad
        // figure damage of inf vs inf

        _hitChance = 0.80;
        _damageOutput = 0.025 * _unitCount;

        _critChance = 0.15;
        _critMultiplier = 6;

    } else {

        // victim is in vehicle(s)
        // figure damage of inf vs veh

        private _victimObjectType = _victim select 2 select 6; // [_victim,"objectType"] call ALiVE_fnc_hashGet

        switch (toLower _victimObjectType) do {
            case "car": {
                _hitChance = 0.90;
                _damageOutput = 0.015 * _unitCount;
                _critChance = 0.2;
                _critAdditionalDamage = 0.3;
            };
            case "truck": {

            };
            case "armored": {

            };
            case "tank": {
                private _victimVehicleClass = _victim select 2 select 11; // [_victim,"vehicleClass"] call ALiVE_fnc_hashGet

                switch true do {
                    case ([_victimVehicleClass] call ALiVE_fnc_isAA): {

                    };
                    case ([_victimVehicleClass] call ALiVE_fnc_isArtillery): {

                    };
                    default {
                        // same as armored
                    };
                };
            };
            case "ship": {

            };
            case "helicopter": {

            };
            case "plane": {

            };
        };

    }; */

} else {
_damageOutput = 0.1;
/*     //--------------------------
    // attacker is in vehicle(s)
    //--------------------------

    if (([_victim,"type"] call ALiVE_fnc_hashGet) == "entity") then {

        // victim is infantry squad
        // figure damage of veh vs inf

        private _victimObjectType = _victim select 2 select 6; // [_victim,"objectType"] call ALiVE_fnc_hashGet

        switch (toLower _victimObjectType) do {
            case "car": {

            };
            case "truck": {

            };
            case "armored": {

            };
            case "tank": {
                private _victimVehicleClass = _victim select 2 select 11; // [_victim,"vehicleClass"] call ALiVE_fnc_hashGet

                switch true do {
                    case ([_victimVehicleClass] call ALiVE_fnc_isAA): {
                        _hitChance = 0.80;
                        _damageOutput = 0.15;
                        _critChance = 0.20;
                        _critMultiplier = 2;
                    };
                    case ([_victimVehicleClass] call ALiVE_fnc_isArtillery): {
                        _attackerPos = _attacker select 2 select 2; // [_attacker,"position"] call ALiVE_fnc_hashGet
                        _victimPos = _victim select 2 select 2;     // [_victim,"position"] call ALiVE_fnc_hashGet

                        if (_attackerPos distance2D _victimPos < 300) then {
                            // machine gun
                            _hitChance = 0.7;
                            _damageOutput = 0.2;
                            _critChance = 0.15;
                            _critMultiplier = 2;
                        } else {
                            // main gun
                            _hitChance = 0.15;
                            _damageOutput = 1;
                            _critChance = 0.15;
                            _critMultiplier = random [1.5,2,2.5];
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
        };

    } else {

        // victim is in vehicle(s)
        // figure damage of veh vs veh

    }; */

};

if (random 1 <= _hitChance) then {
    if (random 1 <= _critChance) then {
        _damageOutput = _critDamage;
    };
} else {
    _damageOutput = 0;
};

_damageOutput