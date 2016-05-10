/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_RandomBuildingPosition.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Returns random building position.
	Also see fn_getCountBuildingPositions.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_building", "_count", "_position"];

_building = _this select 0;
_count = [_building] call INS_fnc_getCountBuildingPositions;

if(_count == 0) then {
	_position = getPos _building;
} else {
	_position = random _count;
	_position = _building buildingPos _position;
};

if((_position select 0) == 0) then {
	_position = getPos _building;
};

_position