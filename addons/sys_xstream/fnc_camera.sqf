//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_xstream\script_component.hpp"
SCRIPT(camera);

private ["_relpos","_cam","_cameraTarget","_fov","_sceneChoice","_subChoice","_loopHandle"];

params [["_logic", objNull, [objNull]]];

// Setup params from logic
ALiVE_VehicleFired = [];
ALiVE_UnitFired = [];
subjects = [];
infantry = [player];
_cameraTarget = player;

// Spawn a process to hook into units alive and units that are firing
_loopHandle = [] spawn {

    // Set Side to show
    private "_sideMask";

    _sideMask = [WEST,EAST,resistance];

    while {GVAR(cameraStarted)} do {

        // Get List of vehicle subjects from Mission
        { if ((side _x in _sideMask) && (_x != player)) then
            {
                private ["_nn","_fh"];
                 subjects pushback _x;
                _nn = _x getVariable "EHfired";
                if (isNil "_nn") then {
                    _fh = _x addeventhandler["fired", { ALiVE_VehicleFired pushback ([(_this select 0),time])}];
                    _x setVariable["EHfired", _fh];
                };
            };
        } foreach vehicles;

        // Get List of Man units from Mission
        { if ((side _x in _sideMask) && (_x != player) && (_x isKindOf "MAN")) then
            {
                private ["_nn","_fh"];
                infantry pushback _x;
                _nn = _x getVariable "EHfired";
                if (isNil "_nn") then {
                    _fh = _x addeventhandler["fired", { ALiVE_UnitFired pushback ([(_this select 0),time])}];
                    _x setVariable["EHfired", _fh];
                };
            };
        } foreach allUnits;

        diag_log format["Subjects: %1", subjects];
        diag_log format["Infantry: %1", infantry];

        sleep 10;

        // Clean up Fired arrays
        {
            if (time - (_x select 1) > 5) then {
                ALiVE_UnitFired set [_foreachIndex,-1];
            };
        } foreach ALiVE_UnitFired;
        ALiVE_UnitFired = ALiVE_UnitFired - [-1];

        {
            if (time - (_x select 1) > 5) then {
                ALiVE_VehicleFired set [_foreachIndex,-1];
            };
        } foreach ALiVE_VehicleFired;
        ALiVE_VehicleFired = ALiVE_VehicleFired - [-1];

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
/*
    titleCut ["", "BLACK FADED", 0];

    // Close up of subject
    private _cam = "camera" camCreate (position _cameraTarget);
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
*/
//  End Introductory Scenes =======================================================

ALIVE_cameraType = "CAMERA";
GVAR(Camera) = [player,false,"HIGH"] call ALIVE_fnc_addCamera;

private _handle = [player, "Starting ALiVE xStream System", 500, 250, 75, 1, [], 0, true] spawn BIS_fnc_establishingShot;
waitUntil { scriptDone _handle };

diag_log "Starting camera";
[GVAR(Camera),true] call ALIVE_fnc_startCinematic;

// Establishing Shot
[GVAR(Camera),_logic] call ALiVE_fnc_establishShot;

// Loop through series of scenes
while { ((count subjects + count infantry) > 0) && GVAR(cameraStarted)} do {

    diag_log "Looping camera shot selection";
    private _timely = 0;
    private _shotTime = 0;
    private _cameraTarget = subjects select 0;
    private _subChoice = (random 1);
    private _duration = 3;

    //Choose a subject
    diag_log format["Vehicle Fired count:%1 - %2", count ALiVE_VehicleFired, ALiVE_VehicleFired];
    diag_log format["Unit Fired count:%1 - %2", count ALiVE_UnitFired, ALiVE_UnitFired];

    private _firingUnits = ALiVE_UnitFired + ALiVE_VehicleFired;

    if (count _firingUnits < 1) then {

        if (_subChoice > 0.45) then {
            _cameraTarget = (subjects select (floor(random count subjects)));
            if (isnil "_cameraTarget") then {
                _cameraTarget = (infantry select (floor(random count infantry)));
            };
        } else {
            _cameraTarget = (infantry select (floor(random count infantry)));
            if (isnil "_cameraTarget") then {
                _cameraTarget = (subjects select (floor(random count subjects)));
            };
        };
    } else {
        _timely = 6;
        reverse _firingUnits;
        {
            _shotTime = _x select 1;
            _timely = time - _shotTime;
            if (_timely < 6 && alive (_x select 0)) exitWith {
                _cameraTarget = _x select 0;
            };
            if (_timely > 5 || !(alive (_x select 0))) then {

            };
        } foreach _firingUnits;

    };

    if !(isNil "_cameraTarget") then{

        // If the subject is a Man and he is in a vehicle, make the vehicle the subject
        if (vehicle _cameraTarget != _cameraTarget) then {
            _cameraTarget = vehicle _cameraTarget;
        };

        // Make sure the subject is not dead or fatally wounded
        if (((alive _cameraTarget) && ((damage _cameraTarget) < 0.5)) || ((speed _cameraTarget > 0) || ((_timely > 0) && (_timely < 5))) ) then {


            private _sceneChoice = ["ZOOM",0.1,"FLY_OVER",0.2,"CHASE_SIDE",0.3,"CHASE_ANGLE",0.3,"CHASE",0.3,"ANGLE",0.5,"SIDE",0.5];
            private _dist = 0 - ((sizeOf _cameraTarget) / 2);
            private _height = 1;

			// Target is a moving vehicle, then use chase shots or follow shot
            if (!(_cameraTarget isKindOf "MAN") && speed _cameraTarget > 1) then {
                _sceneChoice = ["FLY_OVER",0.2,"CHASE",0.3,"CHASE_SIDE",0.3,"CHASE_ANGLE",0.4,"FOLLOW",0.5];
            };

			// If the target is a stationary man
            if (_cameraTarget isKindOf "MAN" && speed _cameraTarget < 1) then {
                _sceneChoice = _sceneChoice + ["SIDE",0.2,"DOLLYZOOM",0.2,"ANGLE",0.3,"FRONT",0.5];
            };

            // CHeck for recent firing, then set up over the shoulder shot or other close up side/front shot
            if (_timely > 0) then {
                _sceneChoice = ["SIDE",0.3,"FRONT",0.3,"CHASE_TARGET",0.7,"TARGET",0.8];
            };

            private _shot = selectRandomWeighted _sceneChoice;

            private _target1 = _cameraTarget;
            private _target2 = assignedTarget _cameraTarget;

            if !(_target1 isKindOf "MAN") then {
                _target2 = assignedTarget gunner _target1;
                _height = (ASLtoATL (eyepos gunner _target1)) select 2;
            };

            if (isNull _target2) then {
                _target2 = _target1 findNearestEnemy _target1;
                diag_log str(_target2);
            };

            if (_target1 isKindOf "MAN") then {
                _dist = -2;
            };

            diag_log format["%3 - %1 : Target: %2 - %6, Dist: %5 ShotTime: %4", time, typeof _target1, _shot, _shotTime, _dist, _target1];

            if (ALIVE_cameraType == "CAMERA") then {

                switch(_shot) do {
                    case "CHASE_TARGET":{
                        _height = (ASLtoATL (eyepos _target1) select 2);
                        _dist = -0.15;
                        if !(_target1 isKindOf "MAN") then {
                            _dist = -0.2 - (random 5);
                        };
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height. Target2: %4", _shot, _dist, _height, _target2];
                        [GVAR(Camera),_target1, _target2, _duration, false, _dist, _height] spawn ALIVE_fnc_chaseTarget;
                    };
                    case "TARGET":{
                        _height = (ASLtoATL (eyepos _target1) select 2);
                        _dist = -0.15;
                        if !(_target1 isKindOf "MAN") then {
                            _dist = -0.2 - (random 5);
                        };
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height. Target %4", _shot, _dist, _height, _target2];
                        [GVAR(Camera),_target1, _target2, _duration, false, _dist, _height] spawn ALIVE_fnc_targetShot;
                    };                    
                    case "FLY_IN":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height. Target %4", _shot, _dist, _height, _target2];
                        [GVAR(Camera),_target1,_duration] spawn ALIVE_fnc_flyInShot;
                    };
                    case "FLY_OVER":{
                    	_height = 30;
                    	_dist = 60;
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height. Target %4", _shot, _dist, _height, _target2];
                        [GVAR(Camera),_target1,_duration] spawn ALIVE_fnc_flyOverShot;
                    };                    
                    case "ZOOM":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height. Target %4", _shot, _dist, _height, _target2];
                        [GVAR(Camera),_target1,_duration] spawn ALIVE_fnc_zoomShot;
                    };
                    case "DOLLYZOOM":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height. Target %4", _shot, _dist, _height, _target2];
                        [GVAR(Camera),_target1,_duration] spawn ALIVE_fnc_dollyZoomShot;
                    };
                    case "STATIC":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height. Target %4", _shot, _dist, _height, _target2];
                        [GVAR(Camera),_target1,_duration] spawn ALIVE_fnc_staticShot;
                    };
                    case "CHASE":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height", _shot, _dist, _height];
                        [GVAR(Camera),_target1,_duration,false,_dist] spawn ALIVE_fnc_chaseShot;
                    };
                    case "CHASE_SIDE":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height", _shot, _dist, _height];
                        [GVAR(Camera),_target1,_duration,false,_dist,_height] spawn ALIVE_fnc_chaseSideShot;
                    };
                    case "CHASE_ANGLE":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height", _shot, _dist, _height];
                        [GVAR(Camera),_target1,_duration,false,_dist,_height] spawn ALIVE_fnc_chaseAngleShot;
                    };
                    case "SIDE":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height", _shot, _dist, _height];
                        [GVAR(Camera),_target1,_duration,false,_dist,_height] spawn ALIVE_fnc_sideShot;
                    };
                    case "ANGLE":{
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height", _shot, _dist, _height];
                        [GVAR(Camera),_target1,_duration,false,_dist,_height] spawn ALIVE_fnc_angleShot;
                    };                    
                    case "FRONT":{
                        _dist = 0 - _dist;
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height", _shot, _dist, (ASLtoATL (eyepos _target1)) select 2];
                        [GVAR(Camera),_target1,_duration, false, _dist, (ASLtoATL (eyepos _target1)) select 2, 0.3-(random 0.6)] spawn ALIVE_fnc_chaseShot;
                    };
                    case "FOLLOW":{
                        _dist = sizeof _target1 * 5;
                        diag_log format["Spawning %1 camera call with %2 distance and %3 height", _shot, _dist, (ASLtoATL (eyepos _target1)) select 2];
                        [GVAR(Camera),_target1,_duration, false, _dist, (ASLtoATL (eyepos _target1)) select 2, 0.3-(random 0.6)] spawn ALIVE_fnc_followShot;
                    };
                };

            }else{

                [_target1,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;

            };

        };
    };
    sleep (_duration);
};

//exit
[GVAR(Camera),true] call ALIVE_fnc_stopCinematic;
[GVAR(Camera)] call ALIVE_fnc_removeCamera;

exit;

