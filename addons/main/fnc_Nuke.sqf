#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(NUKE);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_Nuke

Description:
ALiVE MP compatible Nuke!
Execute on all localities via BIS_fnc_MP, CBA_fnc_GlobalExecute, or debugconsole (button global);

Parameters:
- Explosion Center
- Radiation Radius
- Radiation Timeout

Examples:
[getposATL player, 1500, 3600] spawn ALIVE_fnc_Nuke;

See Also:

Author:
Highhead, FX from LK Nuke
---------------------------------------------------------------------------- */
private ["_nukepos","_fallouttime","_radzone"];

if (isnil "NUKE_NO") then {NUKE_NO = 0};
NUKE_NO = NUKE_NO + 1;

NUKE_fnc_ExplosionClient = {
    if !(hasInterface) exitwith {};

    _nukepos = _this select 0;
	_radzone = _this select 1;
	_fallouttime = _this select 2;

	private ["_i","_on","_snow","_nukepos","_fallouttime","_expdist","_VD","_Cone","_top","_smoke","_Wave","_light","_top2","_top3","_nuclearrain","_fnc_nuke_ashCreate"];
	_nukepos = _this select 0;
	//_radzone = _this select 1;
	_fallouttime = _this select 2;

	//_vdold = viewdistance;
	_expdist = player distance _nukepos;
	
	waituntil {!isnil "_nukepos"};
	
	"dynamicBlur" ppEffectEnable true;
	"dynamicBlur" ppEffectAdjust [0.5];
	"dynamicBlur" ppEffectCommit 0.5;
	
	sleep 0.5;
	
	"colorCorrections" ppEffectEnable true;
	"colorCorrections" ppEffectAdjust [0.8, 15, 0, [0.5, 0.5, 0.5, 0], [0.0, 0.0, 0.6, 2],[0.3, 0.3, 0.3, 0.1]];"colorCorrections" ppEffectCommit 0.4;
	
	"dynamicBlur" ppEffectAdjust [1];
	"dynamicBlur" ppEffectCommit 3;
	
	0 setfog [0,0,50];
	0 setOvercast 0;
    addCamShake [10, 120, 25];
	
	//important - setting viewdistance or nor Explosion will be seen
    _VD = viewdistance;
	setviewdistance 10000;
    setObjectViewDistance 6000;
    
    waituntil {!(isnil "NUKE_SERVERDAMAGE_PROCESSED") && {NUKE_SERVERDAMAGE_PROCESSED}};
	
	_Cone = "#particlesource" createVehicleLocal _nukepos;
	_Cone setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48], "", "Billboard", 1, 10, [0, 0, 0],[0, 0, 0], 0, 1.275, 1, 0, [40,80], [[0.25, 0.25, 0.25, 0], [0.25, 0.25, 0.25, 0.5],[0.25, 0.25, 0.25, 0.5], [0.25, 0.25, 0.25, 0.05], [0.25, 0.25, 0.25, 0]], [0.25], 0.1, 1, "", "", _nukepos];
	_Cone setParticleRandom [2, [1, 1, 30], [1, 1, 30], 0, 0, [0, 0, 0, 0.1], 0, 0];
	_Cone setParticleCircle [10, [-10, -10, 20]];
	_Cone setDropInterval 0.005;
	
	_top = "#particlesource" createVehicleLocal _nukepos;
	_top setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 3, 48, 0], "", "Billboard", 1, 28, [0, 0, 0],[0, 0, 60], 0, 1.7, 1, 0, [100,120,150], [[1, 1, 1, -10],[1, 1, 1, -7],[1, 1, 1, -4],[1, 1, 1, -0.5],[1, 1, 1, 0]], [0.05], 1, 1, "", "", _nukepos];
	_top setParticleRandom [0, [75, 75, 15], [17, 17, 10], 0, 0, [0, 0, 0, 0], 0, 0, 360];
	_top setDropInterval 0.002;
	
	_smoke = "#particlesource" createVehicleLocal _nukepos;
	_smoke setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard", 1, 38, [0, 0, 0],[0, 0, 70], 0, 1.7, 1, 0, [70,95,120],[[1, 1, 1, 0.4],[1, 1, 1, 0.7],[1, 1, 1, 0.7],[1, 1, 1, 0.7],[1, 1, 1, 0.7],[1, 1, 1, 0.7],[1, 1, 1, 0.7],[1, 1, 1, 0]], [0.5, 0.1], 1, 1, "", "", _nukepos];
	_smoke setParticleRandom [0, [10, 10, 15], [15, 15, 7], 0, 0, [0, 0, 0, 0], 0, 0, 360];
	_smoke setDropInterval 0.005;
	
	_Wave = "#particlesource" createVehicleLocal _nukepos;
	_Wave setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48], "", "Billboard", 1, 20, [0, 0, 0],[0, 0, 0], 0, 1.5, 1, 0, [50, 100], [[0.1, 0.1, 0.1, 0.5],[0.5, 0.5, 0.5, 0.5], [1, 1, 1, 0.3], [1, 1, 1, 0]], [1,0.5], 0.1, 1, "", "", _nukepos];
	_Wave setParticleRandom [2, [20, 20, 20], [5, 5, 0], 0, 0, [0, 0, 0, 0.1], 0, 0];
	_Wave setParticleCircle [50, [-80, -80, 2.5]];
	_Wave setDropInterval 0.0002;
	
	_light = "#lightpoint" createVehicleLocal [(_nukepos select 0),(_nukepos select 1),((_nukepos select 2)+500)];
	//_light setLightAmbient[1500, 1200, 1000];
	//_light setLightColor[1500, 1200, 1000];
	_light setLightBrightness 100000.0;
	
	//[_nukepos,40] execvm "scripts\nuke\nuke_sound_client.sqf";
	//[_nukepos,40] execvm "scripts\nuke\nuke_shockwave_client.sqf";
	//[_nukepos,40] execvm "scripts\nuke\nuke_shockimpact_client.sqf";
	
	sleep 0.1;
	
	/*_xHandle =*/ 
    [] spawn {
		Sleep 4;
		"colorCorrections" ppEffectAdjust [1, 0.8, -0.001, [0.0, 0.0, 0.0, 0.0], [0.8*2, 0.5*2, 0.0, 0.7], [0.9, 0.9, 0.9, 0.0]];
		"colorCorrections" ppEffectCommit 7;
	};
	
	sleep 1;
	
	"dynamicBlur" ppEffectAdjust [0.5];
	"dynamicBlur" ppEffectCommit 1;
	_Wave setDropInterval 0.001;
    
    addCamShake [10, 10, 25];

	deletevehicle _top;
	sleep 5;
	_top2 = "#particlesource" createVehicleLocal _nukepos;
	_top2 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 3, 48, 0], "", "Billboard", 1, 32, [0, 0, 420],[0, 0, 50], 0, 1.7, 1, 0, [80,90,120], [[1, 1, 1, -10],[1, 1, 1, -7],[1, 1, 1, -4],[1, 1, 1, -0.5],[1, 1, 1, 0]], [0.05], 1, 1, "", "", _nukepos];
	_top2 setParticleRandom [0, [75, 75, 15], [17, 17, 10], 0, 0, [0, 0, 0, 0], 0, 0, 360];
	_top2 setDropInterval 0.002;
	sleep 5;
	deleteVehicle _top2;
	sleep 2;
	
	_top3 = "#particlesource" createVehicleLocal _nukepos;
	_top3 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 3, 48, 0], "", "Billboard", 1, 32, [0, 0, 700],[0, 0, 42], 0, 1.7, 1, 0, [100,120,150], [[1, 1, 1, -10],[1, 1, 1, -7],[1, 1, 1, -4],[1, 1, 1, -0.5],[1, 1, 1, 0]], [0.05], 1, 1, "", "", _nukepos];
	_top3 setParticleRandom [0, [75, 75, 15], [17, 17, 10], 0, 0, [0, 0, 0, 0], 0, 0, 360];
	_top3 setDropInterval 0.001;

	sleep 10;
	deleteVehicle _top3;
	sleep 20;
	deleteVehicle _smoke;
	
	_i = 0;
	while {_i < 100} do
	{
		_light setLightBrightness 100.0 - _i;
		_i = _i + 1;
		sleep 0.1;
	};
	deleteVehicle _light;
	
	"colorCorrections" ppEffectAdjust [1, 0.8, -0.001, [0.0, 0.0, 0.0, 0.0], [0.8*2, 0.5*2, 0.0, 0.7], [0.9, 0.9, 0.9, 0.0]];  
	"colorCorrections" ppEffectCommit 3;
	"colorCorrections" ppEffectEnable true;
	"filmGrain" ppEffectEnable true; 
	"filmGrain" ppEffectAdjust [0.02, 1, 1, 0.1, 1, false];
	"filmGrain" ppEffectCommit 5;
	
	sleep 2;
	
	"dynamicBlur" ppEffectAdjust [0];
	"dynamicBlur" ppEffectCommit 5;
	
	_Cone setDropInterval 0.01;
	_smoke setDropInterval 0.006;
	_Wave setDropInterval 0.001;
	
	sleep 2;
	
	_Cone setDropInterval 0.02;
	_Wave setDropInterval 0.01;

	private ["_pos","_dirt"];
	
    for "_i" from 0 to 10 do {
        	_pos = [_nukePos,_radzone/6] call CBA_fnc_RandPos;
        
        	_smoke = "#particlesource" createVehicleLocal _pos;
			_smoke setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal_02", 8, 0, 40],
						"", "Billboard", 1, 7, [0, 0, 0], [0, 0, 0], 1, 1.275, 1, 0, [10,18,24],
						[[0.1,0.1,0.1,0.6],[0.1,0.1,0.1,0.35],[0.1,0.1,0.1,0.01]], [0.5], 0.1, 0.1, "", "", _pos];
			_smoke setParticleRandom [2, [2, 2, 2], [1.5, 1.5, 3.5], 0, 0, [0, 0, 0, 0], 0, 0];
			_smoke setDropInterval 0.02;
			
			_dirt = "#particlesource" createVehicleLocal _pos;
			_dirt setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal",16,12,9,0], "", "Billboard", 1, 5, [0, 0, 0], [0, 0, 5], 0, 5, 1, 0, [7,12],
				  [[0.1,0.1,0.1,0.6],[0.1,0.1,0.1,0.35],[0.1,0.1,0.1,0.01]], [1000], 0, 0, "", "", _pos,360];
			_dirt setParticleRandom [0, [1, 1, 1], [1, 1, 2.5], 0, 0, [0, 0, 0, 0.5], 0, 0];
			_dirt setDropInterval 0.05;
    };
    
	sleep 10;
	
	deleteVehicle _light;
	deleteVehicle _Wave;
	deleteVehicle _cone;
    
    setviewdistance _VD;
    setobjectViewdistance _VD * 0.75;
    
    _this spawn NUKE_fnc_RadiationClient;
};

NUKE_fnc_DamageServer = {
    if !(isServer) exitwith {};
    
    private ["_array","_nukepos","_radzone","_fallouttime","_id","_markername","_markernameicon","_radiationStart"];
    
    _nukepos = _this select 0;
	_radzone = _this select 1;
	_fallouttime = _this select 2;
    
    sleep 1;

    private ["_arrayObjects","_arrayUnits","_entry"];

	//[_nukepos, 1000, 1138, [], true] call bis_fnc_destroyCity;
	_arrayObjects = nearestObjects [_nukepos, [], 500];
    _arrayUnits = _nukepos nearentities [["Tank","Air","Ship","Car","Man"], (_radzone)];
    _arrayObjects = _arrayObjects - _arrayUnits;
    
    {
        _x setdammage 1;
    } foreach _arrayObjects;
    
    NUKE_SERVERDAMAGE_PROCESSED = true; Publicvariable "NUKE_SERVERDAMAGE_PROCESSED";
    
    sleep 1;
    _array = _nukepos nearentities [["Tank","Air","Ship","Car","Man"], (_radzone)];
    {
        	_entry = _x;
            if (_nukepos distance _x < _radzone) then {
                _entry setdammage (getdammage _entry) + 0.4;
            };
            if (_nukepos distance _x < (_radzone/(3/2))) then {
                _entry setdammage (getdammage _entry) + 0.4;
            };
            if (_nukepos distance _x < (_radzone/3)) then {
                _entry setdammage (getdammage _entry) + 1;
            };
    } foreach _arrayUnits;
    sleep 30;
    _this spawn NUKE_fnc_RadiationServer;
    NUKE_SERVERDAMAGE_PROCESSED = false; Publicvariable "NUKE_SERVERDAMAGE_PROCESSED";
};

NUKE_fnc_RadiationClient = {
    if !(hasInterface) exitwith {};
    
    _nukepos = _this select 0;
	_radzone = _this select 1;
	_fallouttime = _this select 2;
    
    _on = false;
    _nuclearrain = false;

	_fnc_nuke_ashCreate = {
		private ["_pos","_parray","_snow"];
		_pos = _this select 0;
		_parray = [
		/* 00 */		["\A3\data_f\ParticleEffects\Universal\Universal.p3d", 16, 12, 8, 1],
		/* 01 */		"",
		/* 02 */		"Billboard",
		/* 03 */		1,
		/* 04 */		4,
		/* 05 */		[0,0,0],
		/* 06 */		[0,0,0],
		/* 07 */		1,
		/* 08 */		0.000001,
		/* 09 */		0,
		/* 10 */		1.4,
		/* 11 */		[0.05,0.05],
		/* 12 */		[[0.1,0.1,0.1,1]],
		/* 13 */		[0,1],
		/* 14 */		0.2,
		/* 15 */		1.2,
		/* 16 */		"",
		/* 17 */		"",
		/* 18 */		vehicle player
		];
        
		_snow = "#particlesource" createVehicleLocal _pos;  
		_snow setParticleParams _parray;
		_snow setParticleRandom [0, [10, 10, 7], [0, 0, 0], 0, 0.01, [0, 0, 0, 0.1], 0, 0];
		_snow setParticleCircle [0.0, [0, 0, 0]];
		_snow setDropInterval 0.003;
		_snow;
	};
    
    _fnc_inTriggerCheck = {
        _intrigger = false;
        for "_i" from 0 to 9 do {
            _trigger = format["rad_zone_id_%1",_i];
            if ([getposASL player,_trigger] call ALiVE_fnc_inArea) exitwith {_intrigger = true}; 
        };
        _intrigger;
    };

	for "_i" from 0 to (_fallouttime / 30) do {
	    if (call _fnc_inTriggerCheck) then {
	
			if !(_on) then {
				_on = true;
	
				if !(_nuclearrain) then {25 setovercast 1};
				"colorCorrections" ppEffectAdjust [1, 0.8, -0.001, [0.0, 0.0, 0.0, 0.0], [0.8*2, 0.5*2, 0.0, 0.7], [0.9, 0.9, 0.9, 0.0]];  
				"colorCorrections" ppEffectCommit 5;
				"colorCorrections" ppEffectEnable true;
				"dynamicBlur" ppEffectAdjust [random 0.3];
				"dynamicBlur" ppEffectCommit 5;
				"dynamicBlur" ppEffectEnable true;
				"filmGrain" ppEffectAdjust [0.02, 1, 2.5, 0.5, 1, true];
				"filmGrain" ppEffectCommit 5;
				"filmGrain" ppEffectEnable true;
	
				_snow = [getposATL player] call _fnc_nuke_ashCreate;
			};
	  	} else {
			if (_on) then {
				_on = false;
	
				if (_nuclearrain) then {25 setovercast 0.2};
				"dynamicBlur" ppEffectAdjust [0];
				"dynamicBlur" ppEffectCommit 5;
				"dynamicBlur" ppEffectEnable true;
				"colorCorrections" ppEffectAdjust [1, 1, 0, [0.5, 0.5, 0.5, 0], [1.0, 1.0, 0.8, 0.4],[0.3, 0.3, 0.3, 0.1]];
				"colorCorrections" ppEffectCommit 10;
				"colorCorrections" ppEffectEnable TRUE;
				"filmGrain" ppEffectAdjust [0.001, 0.001, 0.001, 0.001, 0.001, true];
				"filmGrain" ppEffectCommit 5;
				"filmGrain" ppEffectEnable true;
				
				sleep 5;
				"dynamicBlur" ppEffectEnable false;
				"filmGrain" ppEffectEnable false;
		
				if !(isnil "_snow") then {deletevehicle _snow};
			};
	    };
		sleep 5;
	};
};

NUKE_fnc_RadiationServer = {
    	if !(isServer) exitwith {};
    
        _nukepos = _this select 0;
		_radzone = _this select 1;
		_fallouttime = _this select 2;

    	_id = NUKE_NO;
		_markername = format["rad_zone_id_%1",_id];
		_markerobj = createMarkerLocal [_markername, _nukepos];
		_markername setMarkerShape "ELLIPSE";
		_markername setMarkerType "mil_destroy";
		_markername setMarkerColor "ColorOrange";
		_markername setMarkerSize [1000,1000];
		_markername setMarkerBrush "SOLID";
		_markername setMarkerAlpha 0.3;
		
		_markernameicon = format["rad_zone_icon_id_%1",_id];
		_markerobj1 = createMarkerLocal [_markernameicon, _nukepos];
		_markernameicon setMarkerShape "ICON";
		_markernameicon setMarkerColor "ColorRed";
		_markernameicon setMarkerType "mil_destroy";
		_markernameicon setMarkerText "Nuclear Radiation";
		
		//Radiation damage
		_radiationStart = time;
		while {(time - _radiationStart) < _fallouttime} do {
			_array = _nukepos nearentities ["Man", _radzone + floor(random (_radzone/2))];
			{_x setdammage ((getdammage _x) + 0.03)} forEach _array;
			sleep 1;
			
			_array = _nukepos nearentities [["Tank","Air","Ship","Car","Man"], (_radzone/2)];
			{_x setdammage ((getdammage _x) + 0.01)} forEach _array;
			sleep 1;
			
			_array = _nukepos nearentities [["Tank","Air","Ship","Car"], (_radzone/4)];
			{_x setdammage ((getdammage _x) + 0.05)} forEach _array;
			sleep 8;
		};
        
        //Cleanup Radiation
		deletemarker _markername;
		deletemarker _markernameicon;
};

_this spawn {
	_this spawn NUKE_fnc_DamageServer;
	sleep 5;
	_this spawn NUKE_fnc_ExplosionClient;
};
