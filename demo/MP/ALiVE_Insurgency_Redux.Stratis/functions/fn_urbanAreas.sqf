/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_urbanAreas.sqf

Author:

	Sacha

Last modified:

	2/11/2015

Description:

	Finds type Village, City and capitals and adds a bunch of info into the array.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_locations","_cityTypes","_randomLoc","_x","_i","_cities"];
_i = 0;
_cities = [];

_locations = configfile >> "CfgWorlds" >> worldName >> "Names";
_cityTypes = ["NameVillage","NameCity","NameCityCapital"];

for "_x" from 0 to (count _locations - 1) do {
	_randomLoc = _locations select _x;

	// get city info
	private["_cityName","_cityPos","_cityRadA","_cityRadB","_cityType","_cityAngle"];
	_cityName = getText(_randomLoc >> "name");
	_cityPos = getArray(_randomLoc >> "position");
	_cityRadA = getNumber(_randomLoc >> "radiusA");
	_cityRadB = getNumber(_randomLoc >> "radiusB");
	_cityType = getText(_randomLoc >> "type");
	_cityAngle = getNumber(_randomLoc >> "angle");
	if (_cityType in _cityTypes) then {
		_cities set [_i,[_cityName, _cityPos, _cityRadA, _cityRadB, _cityType, _cityAngle]];
		_i = _i + 1;
	};
};
_cities;