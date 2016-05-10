#include <\x\alive\addons\mil_IED\script_component.hpp>
SCRIPT(createBomber);

// Suicide Bomber - create Suicide Bomber at location
private ["_location","_debug","_victim","_size","_faction","_bomber"];

if !(isServer) exitWith {diag_log "Suicide Bomber Not running on server!";};

_victim = objNull;

if (typeName (_this select 0) == "ARRAY") then {
	_location = (_this select 0) select 0;
	_size = (_this select 0) select 1;
	_faction = (_this select 0) select 2;
} else {
	_bomber = _this select 0;
};

_victim = (_this select 1) select 0;

_debug = ADDON getVariable ["debug", false];

if(isnil "_debug") then {_debug = false};

// Create suicide bomber
private ["_grp","_side","_pos","_time","_marker","_class","_btype"];

if (isNil "_bomber") then {
	_pos = [_location, 0, _size - 10, 3, 0, 0, 0] call BIS_fnc_findSafePos;
	_side = _faction call ALiVE_fnc_factionSide;
	_grp = createGroup _side;
	_btype = ADDON getVariable ["Bomber_Type", ""];
	if ( isNil "_btype" || _btype == "") then {
		_class = ([[_faction], 1, ALiVE_MIL_CQB_UNITBLACKLIST, false] call ALiVE_fnc_chooseRandomUnits) select 0;
		if (isNil "_class") then {
			_class = ([[_faction], 1, ALiVE_MIL_CQB_UNITBLACKLIST, true] call ALiVE_fnc_chooseRandomUnits) select 0;
		};
	} else {
		_class = (call compile (ADDON getVariable "Bomber_Type")) call BIS_fnc_selectRandom;
	};
	if (isNil "_class") exitWith {diag_log "No bomber class defined."};
	_bomber = _grp createUnit [_class, _pos, [], _size, "NONE"];

	// ["SURFACE %1, %2", surfaceIsWater (position _bomber), (position _bomber)] call ALiVE_fnc_dump;
	if (surfaceIsWater (position _bomber)) exitWith { deleteVehicle _bomber; diag_log "Bomber pos was in water, aborting";};
};

if (isNil "_bomber") exitWith {};

// Add radio, suicide vest and charge
_bomber addweapon (["ItemRadio","ItemALiVEPhoneOld"] call BIS_fnc_selectRandom);
removeVest _bomber;
_bomber addVest "V_ALiVE_Suicide_Vest";
_bomber addItemToVest "DemoCharge_Remote_Mag";

// Select victim
_victim = units (group _victim) call BIS_fnc_selectRandom;
if (isNil "_victim") exitWith {	deletevehicle _bomber;};

// Add debug marker
if (_debug) then {
	diag_log format ["ALIVE-%1 Suicide Bomber: created at %2 going after %3", time, _pos, name _victim];
};

[_victim,_bomber, _pos] spawn {

	private["_victim","_bomber","_debug","_marker","_shell","_pos"];

	_victim = _this select 0;
	_bomber = _this select 1;
	_pos = _this select 2;
	sleep (random 60);

	// Have bomber go after victim for up to 10 minutes
	_time = time + 600;
    _timer = time;
	waitUntil {

		if (!isNil "_victim" && {time - _timer > 15}) then {
            [_bomber, getposATL _victim] call ALiVE_fnc_doMoveRemote;
            if (ADDON getVariable ["debug",false]) then {
            	_marker = _bomber getVariable ["marker", nil];
            	if (isNil "_marker" || {!(_marker in allMapMarkers)}) then {
            		private ["_markers"];
					_marker = [format ["suic_%1", random 1000], position _bomber , "Icon", [1,1], "TEXT:", "Suicide", "TYPE:", "mil_dot", "COLOR:", "ColorRed", "GLOBAL"] call CBA_fnc_createMarker;
					_bomber setVariable ["marker", _marker];
            	} else {
					_marker setmarkerpos position _bomber;
				};
            } else {
	 			_marker = _bomber getVariable ["marker", ""];
				[_marker] call CBA_fnc_deleteEntity;
        	};
            _timer = time;
		};

		sleep 1;

		!(alive _victim) || (isNil "_victim") || (_bomber distance _victim < 8) || (time > _time) || !(alive _bomber)
	};

	if (!(alive _victim) || isNil "_victim") exitWith {	deletevehicle _bomber;};

	// Blow up bomber
	if ((_bomber distance _victim < 8) && (alive _bomber)) then {
		[_bomber, "Alive_Beep", 50] call CBA_fnc_globalSay3d;
		_bomber addRating -2001;
		_bomber playMoveNow "AmovPercMstpSsurWnonDnon";
		sleep 5;
		if ((random 100) > 10) then { // check if bomb goes off
			_bomber disableAI "ANIM";
			_bomber disableAI "MOVE";
			_shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[8,4,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
			_shell createVehicle [(getpos _bomber) select 0, (getpos _bomber) select 1,0];
			sleep 0.3;
			deletevehicle _bomber;
		} else { // Bomb malfunction
            [_bomber, _pos] call ALiVE_fnc_doMoveRemote;
		};
		if (ADDON getVariable ["debug", false]) then {
			diag_log format ["BANG! Suicide Bomber %1", _bomber];
			[_marker] call CBA_fnc_deleteEntity;
		};
	} else {
		sleep 1;
		if (ADDON getVariable ["debug", false]) then {
			diag_log format ["Ending Suicide Bomber %1 as out of time or dead.", _bomber];
			_marker = _bomber getVariable ["marker", ""];
			[_marker] call CBA_fnc_deleteEntity;
		};
		if ((random 100) > 30) then { // Dead man switch
			_shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[8,4,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
			_shell createVehicle [(getpos _bomber) select 0, (getpos _bomber) select 1,0];
			sleep 0.3;
			deletevehicle _bomber;
		} else { // Add bomb to bomber

		};
	};
};
