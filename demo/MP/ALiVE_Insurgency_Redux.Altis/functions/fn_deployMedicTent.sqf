/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_deployMedicTent.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Allows medics to create mobile respawn points besides MHQ.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_player","_pos","_distance","_offset","_height","_newspawnpos"];

_player = _this select 1;
_pos = getPos player;
_distance = 2;
_offset = 0;
_height = -4;
_side = playerSide;

if (vehicle _player != player) exitWith {
	private ["_title","_text"];

	_title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
	<img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
	_text = format["%1<t align='center' color='#eaeaea'>Unable to deploy MASH while in a vehicle.</t>
	<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />", _title];

	["openSideTop",1.4] call ALIVE_fnc_displayMenu;
	["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

if ((!isNull INS_MEDICTENT) || (!isNull INS_MEDICTENTFLAG)) then {
	deletevehicle INS_MEDICTENT;
	deletevehicle INS_MEDICTENTFLAG;
};

_player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

INS_MEDICTENT = createVehicle ["Land_TentDome_F",(_this select 1) modelToWorld [0, _distance, 0], [], 0, "CAN_COLLIDE"];
INS_MEDICTENTFLAG = createVehicle ["Flag_RedCrystal_F",(_this select 1) modelToWorld [_offset, _distance, _height], [], 0, "CAN_COLLIDE"];

// Create a new respawn position for the respawn menu
_newspawnpos = [_side, getposATL INS_MEDICTENT] call BIS_fnc_addRespawnPosition;
INS_MEDICTENT setVariable ["alive_respawnpos", _newspawnpos];

_player setVariable ["INS_DEPLOYEDMEDICTENT", INS_MEDICTENT, false];
_player setVariable ["INS_DEPLOYEDMEDICTENTFLAG", INS_MEDICTENTFLAG, false];

_player removeAction (_this select 2);

_id = player addaction ["<t color='#FF0000'>Remove Mash</t>", "call INS_fnc_removeMedicTent", nil, -10, false];