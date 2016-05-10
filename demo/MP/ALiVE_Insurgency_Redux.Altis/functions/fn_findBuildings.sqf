/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_findBuildings.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Find buildings in given radius

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_center","_radius","_buildings","_house"];
_buildings = [];

_center = _this select 0;
_radius = _this select 1;
_buildings = nearestObjects [_center, ["house"], _radius];
_buildings