/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_getCountBuildingPositions.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	We do this for alive but I did it anyway again here.
	Gets the amount of building positions a building has.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_building", "_count"];

_building = _this select 0;
_count = 0;
while {str(_building buildingPos _count) != "[0,0,0]"} do
{
	_count = _count + 1;
};

_count