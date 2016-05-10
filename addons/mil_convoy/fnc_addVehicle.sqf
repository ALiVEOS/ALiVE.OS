	#include <\x\alive\addons\mil_convoy\script_component.hpp>

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
    
    _type = _type call BIS_fnc_selectRandom;
    
    if (_debug) then {
		["ALiVE MIL CONVOY Spawning %1 at %2", _type,_pos] call ALiVE_fnc_DumpR;
	};
    
    _veh = [_pos, _dire, _type, _grop] call BIS_fnc_spawnVehicle;
    (_veh select 0) setdir _dire;
	_veh;
