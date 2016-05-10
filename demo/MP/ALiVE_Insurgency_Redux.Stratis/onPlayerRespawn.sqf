/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: onPlayerRespawn.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Runs things on players that respawn! Duh!.
______________________________________________________*/
private ["_unitType"];

_unitType = typeOf (vehicle player);

if (paramsArray select 4 == 1) then {
	if ((_unitType in INS_AUTORIFLE) || (_unitType in INS_ENGINEERS)) then {

		//--- Set object start as null.
		INS_SANDBAG = objNull;

		//--- Add sandbag action similar to the one from insurgency A2
		_id = player addaction ["<t color='#FFFF00'>Deploy Sandbag</t>", "call INS_fnc_deploySandbag", nil, -10, false];

		player addEventHandler ["killed", {
			deleteVehicle (player getVariable["INS_DEPLOYEDSANDBAG", INS_SANDBAG]);
		}];
	};

	if (_unitType in INS_MEDICS) then {
		private ["_newspawnpos"];

		//--- Set object start as null.
		INS_MEDICTENT = objNull;
		INS_MEDICTENTFLAG = objNull;

		//--- Add medic tent action. Similar to the above deploy of Sandbag!
		_id = player addaction ["<t color='#FF0000'>Deploy MASH</t>", "call INS_fnc_deployMedicTent", nil, -10, false];

		player addEventHandler ["killed", {
			deleteVehicle (player getVariable["INS_DEPLOYEDMEDICTENT", INS_MEDICTENT]);
			deleteVehicle (player getVariable["INS_DEPLOYEDMEDICTENTFLAG", INS_MEDICTENTFLAG]);

			// Delete respawn location from the respawn menu
			_newspawnpos = INS_MEDICTENT getVariable "alive_respawnpos";
			_newspawnpos call BIS_fnc_removeRespawnPosition;
		}];

	};
};