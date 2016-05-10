/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_removeMedicTent.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Removes the medic tent objects and adds the action back to player.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_medicTent","_player","_unitType","_side","_newspawnpos"];

_medicTent = INS_MEDICTENT;
_medicTentFlag = INS_MEDICTENTFLAG;
_player = _this select 1;
_side = playerSide;
_unitType = typeOf (vehicle player);
_distance = _player distance _medicTent;

if (_distance > 5) exitWith {
	private ["_title","_text"];

	_title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
	<img  color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
	_text = format["%1<t align='center' color='#eaeaea'>Unable to remove MASH. Must be within (5 Meters) of the object</t><br/>
	<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />", _title];

	["openSideTop",1.4] call ALIVE_fnc_displayMenu;
	["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

_player removeAction (_this select 2);
_player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

if ((!isNull INS_MEDICTENT) || (!isNull INS_MEDICTENTFLAG)) then {
	deletevehicle INS_MEDICTENT;
	deletevehicle INS_MEDICTENTFLAG;
};

//--- Delete respawn location from the respawn menu
_newspawnpos = INS_MEDICTENT getVariable "alive_respawnpos";
_newspawnpos call BIS_fnc_removeRespawnPosition;

if (_unitType in INS_MEDICS) then {

	//--- Add medic tent action. Similar to the above deploy of Sandbag!
	_id = player addaction ["<t color='#FF0000'>Deploy MASH</t>", "call INS_fnc_deployMedicTent", nil, -10, false];
};