
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


if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["MISSION: %1", _this] call ALiVE_fnc_dump; };

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

// Count the shells that actually leave, and take only those off the battery. Its rounds used to come off as
// the order was given, so a mission no gun could fire (out of reach, or a sea point the engine won't aim at)
// still emptied the battery and was reported as fired. Only the mission's own magazine counts, so a
// commander's machine gun doesn't.
private _guns = [];
{
    private _gun = vehicle _x;
    if (!isNull _gun && {!(_gun in _guns)}) then { _guns pushBack _gun };
} forEach (_units + [_battery]);
_battery setVariable ["ALiVE_CS_shotsFired", 0];
_battery setVariable ["ALiVE_CS_shotMagazine", _ordnance];
private _firedEHs = _guns apply {
    _x setVariable ["ALiVE_CS_firingFor", _battery];
    [_x, _x addEventHandler ["Fired", {
        params ["_gun", "", "", "", "", "_magazine"];
        private _b = _gun getVariable ["ALiVE_CS_firingFor", objNull];
        if (!isNull _b && {_magazine == (_b getVariable ["ALiVE_CS_shotMagazine", ""])}) then {
            _b setVariable ["ALiVE_CS_shotsFired", (_b getVariable ["ALiVE_CS_shotsFired", 0]) + 1];
        };
    }]]
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

// The firing is over once every round asked for has left, nothing has left for 30 s since the last shot,
// nothing has left at all after 90 s (the guns can't reach, or won't aim there), or the mission runs too long.
private _t0 = time;
private _lastShot = time;
private _seen = 0;
waitUntil {
    sleep 1;
    private _n = _battery getVariable ["ALiVE_CS_shotsFired", 0];
    if (_n > _seen) then { _seen = _n; _lastShot = time };
    _n >= _missionRoundCount
    || {_seen == 0 && {time - _t0 > 90}}
    || {_seen > 0 && {time - _lastShot > 30}}
    || {time - _t0 > 120 + 20 * _missionRoundCount}
};
{
    _x params ["_gun", "_eh"];
    if (!isNull _gun) then {
        _gun removeEventHandler ["Fired", _eh];
        _gun setVariable ["ALiVE_CS_firingFor", nil];
    };
} forEach _firedEHs;
private _fired = (_battery getVariable ["ALiVE_CS_shotsFired", 0]) min _missionRoundCount;
if (_fired > 0) then {
    private _rounds = +(_battery getVariable ["NEO_radioArtyBatteryRounds", []]);
    {
        _x params ["_round", "_count"];
        if (_round == _ordnanceType) exitWith {
            if (_count - _fired > 0) then { _rounds set [_forEachIndex, [_round, _count - _fired]] } else { _rounds deleteAt _forEachIndex };
        };
    } forEach _rounds;
    _battery setVariable ["NEO_radioArtyBatteryRounds", _rounds, true];
};
if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then {
    ["MISSION: %1 of %2 rounds left the guns and came off the battery", _fired, _missionRoundCount] call ALiVE_fnc_dump;
};

_battery setVariable ["ARTY_COMPLETE", true, true];

sleep 20;

_battery setVariable ["ARTY_ONMISSION", false, true];
