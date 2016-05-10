/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: init.sqf

Author:

	Hazey

Special Thanks:

	Highhead
	ARJay

Last modified:

	2/11/2015

Description:

	Main Init - Starts and runs things.
______________________________________________________*/

//--- Start Init
["Insurgency | ALiVE - Executing init.sqf..."] call ALiVE_fnc_Dump;

// ====================================================================================
	//--- DEFINES/ INCLUDES
	call compile preprocessFile "common_defines.sqf";
// ====================================================================================

//--- Disable Saving
enableSaving [false, false];

//--- Civilian Call to Prayer
if (paramsArray select 2 == 1) then {
	_null = [] spawn INS_fnc_CallToPrayer;
};

//--- Spawn Intel
if (paramsArray select 7 == 1) then {
	if (isServer || isDedicated) then {
		_null = [] spawn INS_fnc_SpawnIntel;
	};
};

//--- Create MHQ
if (paramsArray select 11 == 1) then {
	_null = execVM "scripts\wco\hze_fnc_MHQ.sqf";
};

//--- Enable map teleport on click
if (ins_debug) then {
	[] call INS_fnc_mapTeleport;
};

//--- Game Briefing
[] call compileFinal preprocessfilelinenumbers "scripts\briefings\briefing.sqf";

if (isServer || isDedicated) then {
	_null = [] spawn INS_fnc_setupCache;
};

["Insurgency | ALiVE - END OF INIT..."] call ALiVE_fnc_Dump;

//--- Game Intro
if (!ins_debug) then {
	[] call compileFinal preprocessfilelinenumbers "scripts\intro.sqf";
};