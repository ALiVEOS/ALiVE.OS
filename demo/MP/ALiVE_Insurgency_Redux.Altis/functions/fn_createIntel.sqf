/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_createIntel.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Function to create intel markers around cache when found.

______________________________________________________*/

private ["_i","_sign","_sign2","_radius","_cache","_pos","_mkr","_range","_intelRadius"];

_cache = CACHE;
_intelRadius = 800;
_i = 0;

while { (getMarkerPos format["%1intel%2", _cache, _i] select 0) != 0} do {
	_i = _i + 1;
};

_sign = 1;

if (random 100 > 50) then {
	_sign = -1;
};

_sign2 = 1;

if (random 100 > 50) then {
	_sign2 = -1;
};

_radius = _intelRadius - _i * 50;

if (_radius < 50) then {
	_radius = 50;
};

_pos = [(getPosATL _cache select 0) + _sign *(random _radius),(getPosATL _cache select 1) + _sign2*(random _radius)];
_mkr = createMarker[format["%1intel%2", _cache, _i], _pos];
_mkr setMarkerType "hd_unknown";
_range = round sqrt(_radius^2*2);
_range = _range - (_range % 50);
_mkr setMarkerText format["%1m", _range];
_mkr setMarkerColor "ColorRed";
_mkr setMarkerSize [0.5,0.5];

INS_marker_array set [count INS_marker_array, _mkr];
publicVariable "INS_marker_array";