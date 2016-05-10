
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


diag_log format["MISSION: %1", _this];

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
	//diag_log format["BATTERY: %1 due in %2 seconds", _battery, _eta];

	sleep _eta;

	_battery setVariable ["ARTY_SPLASH", true, true];

};

if(_missionRoundCount == 1) then {
	_battery DOArtilleryFire [_targetPos, _ordnance, _missionRoundCount];

} else {
	{
		private "_pos";
		if (_dispersion > 50) then {
			_pos = [_targetPos, _dispersion-50, round(random 360)] call BIS_fnc_relPos;
		} else {
			_pos = _targetPos;
		};
		_x DOArtilleryFire [_pos, _ordnance, _missionRoundCount/((group _battery) getVariable ["supportWeaponCount",3])];
		sleep _rateOfFire;
	} foreach _units;
};

_battery setVariable ["ARTY_COMPLETE", true, true];

sleep 20;

_battery setVariable ["ARTY_ONMISSION", false, true];
