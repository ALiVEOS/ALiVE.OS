    #include "\x\alive\addons\mil_convoy\script_component.hpp"

    private ["_logic","_type","_startposi","_startroads","_dire","_grop","_veh","_pos","_facs","_type","_debug"];

    _logic = _this select 0;
    _pos = _this select 1;
    _dire = _this select 2;
    _grop = _this select 3;

    _facs = faction leader _grop;
    _debug = _logic getvariable ["conv_debug_setting",false];
    _type = [3, [_facs], "LandVehicle"] call ALiVE_fnc_findVehicleType;

    if (count _this > 4) then {
        _type = ([3, [_facs], _this select 4] call ALiVE_fnc_findVehicleType);
    };

    _type = (selectRandom _type);

    if (_debug) then {
        ["MIL CONVOY Spawning %1 at %2", _type,_pos] call ALiVE_fnc_dumpR;
    };

    // Route the convoy spawn position through the unified vehicle
    // spawn validator (#850). Convoys originate at military bases /
    // installations and BIS_fnc_spawnVehicle's placement isn't
    // bbox-aware - if the source pos lands the truck clipped against
    // a fence or building corner the convoy detonates before driving
    // off. Falls back to the original _pos when no clear position is
    // found in range; the allowDamage settle window below catches
    // residual cases.
    private _convoySpawnPos = _pos;
    private _spawnResult = [_type, _pos, 50, "auto"] call ALiVE_fnc_findVehicleSpawnPosition;
    if (count _spawnResult >= 2) then {
        _convoySpawnPos = _spawnResult select 0;
        // Direction is set explicitly below (line of march), so we
        // only take the validated position from the validator.
    };

    _veh = [_convoySpawnPos, _dire, _type, _grop] call BIS_fnc_spawnVehicle;
    (_veh select 0) setdir _dire;

    // Same 15 s allowDamage settle as the profile / civilian /
    // logistics-truck paths.
    private _spawnedVeh = _veh select 0;
    _spawnedVeh allowDamage false;
    [{_this allowDamage true;}, _spawnedVeh, 15] call CBA_fnc_waitAndExecute;

    _veh;
