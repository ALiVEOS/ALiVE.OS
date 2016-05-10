/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_cacheKilled.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Deletes cache when killed, add's single point and calls custom hint box.

______________________________________________________*/

private ["_pos","_x"];

_pos = getPos cache;
_x = 0;

//--- Delete the currently spawned cache.
deleteVehicle cache;

//--- Add +1 to current player score.
INS_west_score = INS_west_score + 1;
publicVariable "INS_west_score";

//--- Create bomb effect. 22 cycles at random intervals using a random sleep.
while { _x <= 22 } do {
	"M_Mo_82mm_AT_LG" createVehicle _pos;
	_x = _x + 1 + random 3;
	sleep (0.2 + (random 3));
};

//--- Call the global cache killed text.
[nil,"INS_fnc_cacheKilledText", nil, false] spawn BIS_fnc_MP;

sleep 4;

[] spawn INS_fnc_spawnCache;