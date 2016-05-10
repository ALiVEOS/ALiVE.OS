/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_handleRegister.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	CBA magic to call event handler for intel dropping off units.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

if (isServer || isDedicated) then {
	private["_unit"];

	_unit = _this select 0;

	if (ins_debug) then {
		["INS_fnc_handlerRegister called on unit: %1 unit side: %2 debug: %3", _unit, side _unit, ins_debug] call ALIVE_fnc_dump;
	};

	if ((side _unit == EAST) || (side _unit == RESISTANCE)) then {
		_unit addEventHandler ["Killed", {_this call INS_fnc_intelDrop}];
		if (ins_debug) then {
			["EventHandler added to unit"] call ALIVE_fnc_dump;
		};
	} else {
		if (ins_debug) then {
			["Skipping Unit"] call ALIVE_fnc_dump;
		};
	};
};