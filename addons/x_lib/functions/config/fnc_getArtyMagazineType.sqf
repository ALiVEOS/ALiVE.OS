#include <\x\alive\addons\x_lib\script_component.hpp>


/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getArtyMagazineType

Description:
Get magazinesType from config for a weapon class

Parameters:
String - weapon class name

Returns:
Array of magazine types

Examples:
(begin example)
// get weapon magazines
_result = "missiles_DAGR" call ALIVE_fnc_configGetWeaponMagazines;
(end)

See Also:

Author:
Gunny
---------------------------------------------------------------------------- */

private ["_class","_type","_weaponClass","_mags""_result"];

_class = _this select 0;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class	= "B_MBT_01_arty_F"
};
_type = _this select 1;
_weaponType = typeof(vehicle _class);

_weapon = [configfile >> "CfgVehicles" >> _weaponType >> "Turrets" >> "MainTurret" >> "weapons"] call ALiVE_fnc_getConfigValue;

_weaponClass = _weapon select 0;

_mags =[];
_mags = _weaponClass call ALIVE_fnc_configGetWeaponMagazines;

_ords=[];
_ord="";


switch(_type) do {
	case "HE": {
					{
						_he = ["Mo_shells", _x] call BIS_fnc_inString;
						if (!_he) then {
							_he = ["he", _x] call BIS_fnc_inString;
									};
						if (_he) then {
 						_ords = [_ords, _x] call ALIVE_fnc_push;

							};
					} forEach _mags;
				};
	case "SMOKE": {
					{
						_smoke = ["Mo_smoke", _x] call BIS_fnc_inString;
						if (!_smoke) then {
						_smoke = ["smoke", _x] call BIS_fnc_inString;
									};
						if (_smoke) then {
 							_ords = [_ords, _x] call ALIVE_fnc_push;
 					};

					} forEach _mags;
				};
		case "SADARM": {
					{
						_guided = ["Mo_guided", _x] call BIS_fnc_inString;
						if (_guided) then {
 							_ords = [_ords, _x] call ALIVE_fnc_push;
 						};

					} forEach _mags;
				};
		case "CLUSTER": {
					{
						_cluster = ["Mo_Cluster", _x] call BIS_fnc_inString;
						if (_cluster) then {
 							_ords = [_ords, _x] call ALIVE_fnc_push;
 						};

					} forEach _mags;
				};
		case "LASER": {
					{
						_lg = ["Mo_LG", _x] call BIS_fnc_inString;

						if (!_lg) then {
						_lg = ["laser", _x] call BIS_fnc_inString;
								};
						if (_lg) then {
 							_ords = [_ords, _x] call ALIVE_fnc_push;
 						};

					} forEach _mags;
				};
		case "MINE": {
					{
						_mine = ["Mo_mine", _x] call BIS_fnc_inString;
						if (_mine) then {
 							_ords = [_ords, _x] call ALIVE_fnc_push;
 						};

					} forEach _mags;
				};
		case "AT MINE": {
					{
						_atmine = ["Mo_AT_mine", _x] call BIS_fnc_inString;
						if (_atmine) then {
 						_ords = [_ords, _x] call ALIVE_fnc_push;
 						};

					} forEach _mags;
				};
		case "ROCKETS": {
					{
						 _rockets = ["rockets", _x] call BIS_fnc_inString;
						if (_rockets) then {
 							_ords = [_ords, _x] call ALIVE_fnc_push;
 						};

					} forEach _mags;
				};

			case "ILLUM": {
					{
						 _illum = ["illum", _x] call BIS_fnc_inString;
 					if (!_illum) then {
						_illum = ["flare", _x] call BIS_fnc_inString;
						};
						if (_illum) then {
 							_ords = [_ords, _x] call ALIVE_fnc_push;
 						};

					} forEach _mags;
				};
		case default {
					_ord="";
				};
};
;
_ord = _ords select 0;



_ord;



