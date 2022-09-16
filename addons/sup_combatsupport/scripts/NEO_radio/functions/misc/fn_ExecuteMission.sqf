
private ["_battery", "_targetPos", "_missionType", "_ordnanceType", "_rateOfFire",
        "_missionRoundCount", "_missionTimeLength", "_unit", "_ordnance", "_eta","_grp","_dummy","_target","_dispersion","_units"];

_battery = _this select 0;
_targetPos = _this select 1;
_missionType = _this select 2;
_ordnanceType = _this select 3;    //"8Rnd_82mm_Mo_shells";
_rateOfFire = _this select 4; //0
_missionRoundCount = _this select 5;  //6
_missionTimeLength = _this select 5; //6
_unit = _this select 6;
_ordnance = _this select 7;
_dispersion = _this select 8;
_units = _this select 9;


["MISSION: %1", _this] call ALiVE_fnc_dump;

// Arty is on mission
_battery setVariable ["ARTY_SHOTCALLED", false, true];
_battery setVariable ["ARTY_SPLASH", false, true];
_battery setVariable ["ARTY_COMPLETE", false, true];
_battery setVariable ["ARTY_ONMISSION", true, true];

// Ensure that the target position is 3d.
if ((count _targetPos) == 2) then
{
    _targetPos = [_targetPos select 0, _targetPos select 1, 0];
};

sleep 15;

_battery setVariable ["ARTY_SHOTCALLED", true, true];

sleep 2;

[_battery,_targetPos,_ordnance] spawn {

    _battery = _this select 0;
    //Get position for ETA
    _dummy = "Land_HelipadEmpty_F" createVehicleLocal (_this select 1);
    _eta = (vehicle _battery) getArtilleryETA [getPos _dummy, _this select 2];
    deleteVehicle _dummy;
    //["BATTERY: %1 due in %2 seconds", _battery, _eta] call ALiVE_fnc_dump;

    sleep _eta;

    _battery setVariable ["ARTY_SPLASH", true, true];

};

if(_missionRoundCount == 1) then {
    _battery DOArtilleryFire [_targetPos, _ordnance, _missionRoundCount];

} else {
    private _roundsOut = _missionRoundCount;
    private _numUnits = (group _battery) getVariable ["supportWeaponCount",3];
    private _roundsOutEach = [];
    _roundsOutEach resize [_numUnits,0];
    private _i = 0;
    while {_roundsOut > 0} do {
        _roundsOutEach set [_i,(_roundsOutEach select _i) + 1];
        _roundsOut = _roundsOut - 1;
        _i = _i + 1;
        if (_i == _numUnits) then {_i = 0;};
    };

    for "_u" from 0 to (_numUnits -1) do { 
        private "_pos";
        if (_dispersion > 50) then {
            _pos = (_targetPos getPos [(_dispersion - 50), (round (random 360))]);
        } else {
            _pos = _targetPos;
        };
        if (_roundsOutEach select _u > 0) then {
            (_units select _u) DOArtilleryFire [_pos, _ordnance, _roundsOutEach select _u];
            sleep _rateOfFire;
        };
    };
};

_battery setVariable ["ARTY_COMPLETE", true, true];

sleep 20;

_battery setVariable ["ARTY_ONMISSION", false, true];
