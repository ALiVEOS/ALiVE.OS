/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_setupCache.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Set us up the bomb. Or the cache.

	Calls the first spawm of the cache and sets up our arrays.

______________________________________________________*/

if (isServer || isDedicated) then {

    INS_marker_array = [];
	publicVariable "INS_marker_array";

	if (ins_debug) then {
		INS_cache_marker_array = [];
		publicVariable "INS_cache_marker_array";
    };

    true spawn INS_fnc_spawnCache;
};