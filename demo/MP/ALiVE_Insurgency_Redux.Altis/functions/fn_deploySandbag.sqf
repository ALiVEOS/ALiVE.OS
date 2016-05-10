/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_deploySandbag.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Deploy the insurgency A2 style sandbag

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_player","_pos","_distance","_offset","_playerDirection"];

_player = _this select 1;
_pos = getPos player;
_distance = 1;
_offset = 0;
_playerDirection = ((getDir _player)+ _offset) mod 360;

if (vehicle _player != player) exitWith {
	private ["_title","_text"];

	_title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
	<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
	_text = format["%1<t align='center' color='#eaeaea'>Unable to deploy Sandbag while in a vehicle.</t>
	<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />", _title];

	["openSideTop",1.4] call ALIVE_fnc_displayMenu;
	["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

if (!isNull INS_SANDBAG) then {
	deletevehicle INS_SANDBAG;
};

_player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

INS_SANDBAG = createVehicle ["Land_BagFence_Short_F",(_this select 1) modelToWorld [0, _distance, 0], [], 0, "CAN_COLLIDE"];
INS_SANDBAG setDir _playerDirection;

_player setVariable ["INS_DEPLOYEDSANDBAG", INS_SANDBAG, false];

_player removeAction (_this select 2);

_id = player addaction ["<t color='#FFFF00'>Remove Sandbag</t>", "call INS_fnc_removeSandbag", nil, -10, false];