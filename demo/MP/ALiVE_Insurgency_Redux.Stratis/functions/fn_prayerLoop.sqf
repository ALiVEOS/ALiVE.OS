/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_prayerLoop.sqf

Author:

	Hazey

Last modified:

	2/12/2015

Description:

	Main loop for the prayer.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

[] spawn {
	private ["_fnc_between","_fnc_prayer"];
	_fnc_between = {
		private ["_a","_b"];
		_a = _this select 0;
		_b = _this select 1;

		(daytime >= _a AND daytime < _b)
	};

	_fnc_prayer = {
		{
			if (isNull _x) then {
				if(ins_debug) then {
					["fn_prayerLoop:: Object NULL exiting"] call ALIVE_fnc_dumpR;
				};
			} else {
				[_x, "prayer"] call CBA_fnc_globalSay3d;
				if(ins_debug) then {
					["fn_prayerLoop:: Global sound added to loudspeaker: %1", _x] call ALIVE_fnc_dumpR;
				};
			};
		} foreach INS_createdLoudSpeakers;
	};

	waitUntil {
		{
			if (_x call _fnc_between) exitwith {
				if(ins_debug) then {
					["fn_prayerLoop:: Prayer time called: %1", _x] call ALIVE_fnc_dumpR;
				};
				_x call _fnc_prayer;
			};
		} foreach [[4.25,4.5],[5.25,5.75],[11.75,12],[15.25,15.5],[17.75,18.25],[19,19.25]];

		sleep 160;
		false;

		if(ins_debug) then {
			["fn_prayerLoop:: Prayer time end"] call ALIVE_fnc_dumpR;
		};
	};

	if(ins_debug) then {
		["fn_prayerLoop:: Prayer time exiting"] call ALIVE_fnc_dumpR;
	};
};