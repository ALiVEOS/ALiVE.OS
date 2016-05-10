//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_xstream\script_component.hpp>
SCRIPT(camera);


private ["_relpos","_cam","_cameraTarget","_fov","_sceneChoice","_subChoice","_loopHandle","_logic"];

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;

// Setup params from logic



TargetFired = [];
subjects = [player];
infantry = [player];
_cameraTarget = player;

_loopHandle = [] spawn {

    	// Set Side to show
    private "_sideMask";

	_sideMask = [WEST,EAST,resistance, civilian];

    while {GVAR(cameraStarted)} do {

		// Get List of vehicle subjects from Mission
		{ if ((side _x in _sideMask) && (_x != player)) then
			{
				private ["_nn","_fh"];
			 	subjects = subjects + [_x];
				_nn = _x getVariable "EHfired";
				if (isNil "_nn") then {
					_fh = _x addeventhandler["fired", { TargetFired set [count TargetFired, [(_this select 0),time]]}];
					_x setVariable["EHfired", _fh];
				};
			};
		} foreach vehicles;

		// Get List of Man units from Mission
		{ if ((side _x in _sideMask) && (_x != player) && (_x isKindOf "MAN")) then
			{
				private ["_nn","_fh"];
				infantry = infantry + [_x];
				_nn = _x getVariable "EHfired";
				if (isNil "_nn") then {
					_fh = _x addeventhandler["fired", { TargetFired set [count TargetFired, [(_this select 0),time]]}];
					_x setVariable["EHfired", _fh];
				};
			};
		} foreach allUnits;
		diag_log format["Subjects: %1", subjects];
		diag_log format["Infantry: %1", infantry];
		sleep 30;
		subjects = [];
		infantry = [];
	};
};

// Set up visual effects
0 setOvercast random 0.2;

"colorCorrections" ppEffectAdjust [1, 1, -0.004, [0.0, 0.0, 0.0, 0.0], [1, 0.8, 0.6, 0.5],  [0.199, 0.587, 0.114, 0.0]];
"colorCorrections" ppEffectCommit 0;
"colorCorrections" ppEffectEnable false ;
"filmGrain" ppEffectEnable false;
"filmGrain" ppEffectAdjust [0.04, 1, 1, 0.1, 1, false];
"filmGrain" ppEffectCommit 0;

"radialBlur" ppEffectEnable false;
"wetDistortion" ppEffectEnable false;
"chromAberration" ppEffectEnable false;
"dynamicBlur" ppEffectEnable false;

enableRadio false;

// Introductory Scenes =======================================================

titleCut ["", "BLACK FADED", 0];

// Close up of subject
_cam = "camera" camCreate (position _cameraTarget);
_cam cameraEffect ["INTERNAL", "BACK"];
showCinemaBorder true;
cameraEffectEnableHUD false;
showHUD false;

waituntil {(preloadcamera (position _cameraTarget))};
setacctime 0;

setacctime 1;

_cam attachTo [_cameraTarget,[2,15,1]];
_cam camPrepareTarget _cameraTarget;
_cam camPrepareFOV 0.6;
_cam camCommitPrepared 0;
waituntil {camcommitted _cam};

// Author details
titleCut ["", "BLACK IN", 4];

sleep 5;

//Close up of subject
if (count subjects > 0) then {
	_cameraTarget = (subjects select (floor(random count subjects)));
};

waituntil {(preloadcamera (position _cameraTarget)) || time > 5};
_cam attachTo [_cameraTarget,[-2,15,-1]];
_cam camPrepareTarget _cameraTarget;
_cam camPrepareFOV 0.6;
_cam camCommitPrepared 0;
waituntil {camcommitted _cam};

// Map Details
titleCut ["", "BLACK IN", 4];

sleep 5;

_cam cameraEffect ["terminate","back"];
camDestroy _cam;

titleCut ["", "BLACK FADED", 0];

//  End Introductory Scenes =======================================================

// Loop through series of scenes
while { ((count subjects + count infantry) > 0) && GVAR(cameraStarted)} do {

	private ["_timely","_shotTime"];
	//Choose a subject

	diag_log format["TargetFired count:%1 - %2", count TargetFired, TargetFired];

	_timely = 0;
	_shotTime = 0;
	_cameraTarget = vehicles select 0;

	if (count TargetFired < 1) then {
		_subChoice = (random 1);
		if (_subChoice > 0.3) then {
			_cameraTarget = (subjects select (floor(random count subjects)));
		} else {
			_cameraTarget = (infantry select (floor(random count infantry)));
		};
	} else {
		private ["_i"];
		_i = 0;
		_timely = 6;
		while {(_timely > 5 || _i < (count TargetFired - 1) )} do {
			_cameraTarget = (TargetFired select _i) select 0;
			_shotTime = (TargetFired select _i) select 1;
			TargetFired set [_i,-1];
			TargetFired = TargetFired - [-1];
			_timely = time - _shotTime;
			_i = _i + 1;
		};
	};

	// If the subject is a Man and he is in a vehicle, make the vehicle the subject
	if (vehicle _cameraTarget != _cameraTarget) then {
		_cameraTarget = vehicle _cameraTarget;
	};

	// Make sure the subject is not dead or fatally wounded
	if (((alive _cameraTarget) || ((damage _cameraTarget) < 0.4)) && ((speed _cameraTarget > 0) || ((_timely > 0) && (_timely < 5))) ) then {

		// Destroy last camera
		_cam cameraEffect ["terminate","back"];
		camDestroy _cam;

		// Create new camera
		_cam = "camera" camCreate (position _cameraTarget);
		showCinemaBorder true;
		cameraEffectEnableHUD false;
		showHUD false;

		// Randomly set a Field of View
		_fov = 0.2+(random 0.5);

		// Randomly pick a number (0-5 Flyby, 6-7 First Person, 8-10 Follow, 11 Pan)
		_sceneChoice = (round(random 15));

		diag_log format["sys_xstream target:%1, sc:%2, scene:%3, speed:%4",_cameraTarget, _subChoice, _sceneChoice, speed _cameraTarget];

		// Set up scene and Fade into the shot
		_cam camPrepareTarget _cameraTarget;
		_cam camPrepareFOV _fov;
		titleCut ["", "BLACK IN", 2];

		// Over the Shoulder shot looking at target
		if (_timely > 0 || _sceneChoice > 10) then {
			// Check to see if it is a Man, if so get closer
			if (_cameraTarget iskindof "MAN") then {
				x = (2-(round(random 4))) * cos(random 90);
				y = 0.3 + (random 2);
				z = (eyePos _cameraTarget) select 2;
			} else {
				_fov = _fov + 0.3;
				x = (5-(round(random 10))) * cos(random 90);
				y = (sizeOf (typeOf _cameraTarget)) + (random 10);
				z = 3;
			};

			_relpos = [x , y, z];
			_cam attachTo [_cameraTarget,_relpos];
			_cam camSetTarget (assignedTarget _cameraTarget);
			_cam camSetFOV _fov;
			_cam cameraEffect ["INTERNAL", "BACK"];
			_cam camCommit 0;
			sleep 5;
			_sceneChoice = 12;
		};


		// Fly By
		if (_sceneChoice < 6) then {
			if (_cameraTarget iskindof "MAN") then {
				x = 10-(round(random 20));
				y = 10-(round(random 20));
				z = 1+(round(random 2));
			} else {
				x = (round(random 120));
				y = (round(random 120));
				z = 10+(round(random 120));
			};
			_relpos = [x * cos(random 180), y * sin(random 180), z];
			_cam camPrepareRelPos _relpos;
			_cam camSetTarget _cameraTarget;
			_cam camSetRelPos _relpos;
			_cam camSetFOV _fov;
			_cam cameraEffect ["INTERNAL", "BACK"];
			_cam camCommit 0;
			sleep 5;
		};

		// Follow
		if ((_sceneChoice >5) && (_sceneChoice < 11)) then {
			// Check to see if it is a Man, if so get closer
			if (_cameraTarget iskindof "MAN") then {
				x = (2-(round(random 4))) * cos(random 180);
				y = (2+(round(random 8)));
				z = (1.5+(round(random 0.5)));
			} else {
				_fov = _fov + 0.3;
				x = (5-(round(random 10))) * cos(random 180);
				y = (12+(round(random 8)));
				z = (5-(round(random 10))) * sin(random 180);
			};

			_relpos = [x , y, z];
			_cam attachTo [_cameraTarget,_relpos];
			_cam camSetTarget _cameraTarget;
			_cam camSetFOV _fov;
			_cam cameraEffect ["INTERNAL", "BACK"];
			_cam camCommit 0;
			sleep 5;
		};

		/*
		// First Person
		if ((_sceneChoice > 8) && (_sceneChoice < 11)) then {
			_cam camPrepareRelPos (position _cameraTarget);
			_cam cameraEffect ["terminate","back"];
			camDestroy _cam;
			_cameraTarget switchCamera "INTERNAL";
			sleep 5;
		};

		// Pan
		if (_sceneChoice > 10) then {
			// If the target is a person, get closer
			if (_cameraTarget iskindof "MAN") then {
				_dist = 1+(random 4);
				_alt = 1+(random 2);
			} else {
				_dist = (sizeOf (typeOf _cameraTarget)) + (random 10);
                _alt = ((random _dist)/3) + 6;
			};

			_stopScene = false;
			_startTime = time;
			_stopTime = _startTime + 8;
			_newTarget = objNull;
			_istep = 0.22 + (random 3) * (0.001 * 1);
			_groupTarget = createGroup sideLogic;
			_newTarget = _groupTarget createUnit ["Logic", (position _cameraTarget), [], 0, "NONE"];
			_iterator = 0;
			_switchDir = (round(random 1));
			_angle = 0;
			_targetPos = [];
			x = (position _cameraTarget select 0) + _dist;
			y = (position _cameraTarget select 1) + _dist;
			z = (position _cameraTarget select 2) + _alt;
			_relpos = [x , y, z];
			_cam camSetTarget _newTarget;
			_cam camSetPos _relpos;
			_cam camSetFOV _fov;
			_cam cameraEffect ["INTERNAL", "BACK"];
			_cam camCommit 0;
			_startangle = [_cam,_cameraTarget] call BIS_fnc_relativeDirTo;
			_startangle = _startangle % 360;

			while {!_stopScene} do {
				_iterator = _iterator + 1;
				_angle = _startangle + (_iterator * _istep);
				if (_switchDir == 0) then {
					_targetPos = [x + _dist * cos(_angle), y + _dist * sin(_angle), z];
				} else {
					_targetPos = [x + _dist * cos(_angle), y - _dist * sin(_angle), z];
				};
				_newTarget setPos _targetPos;
				sleep 0.001;
				if (time > _stopTime) then {_stopScene = true};
			};
			deleteVehicle _newTarget;
			_groupTarget call ALiVE_fnc_DeleteGroupRemote;
		};

		// Satellite

		// Cameraman

		//
		*/
	};
};

//exit
_cam cameraEffect ["terminate","back"];
camDestroy _cam;
exit;

