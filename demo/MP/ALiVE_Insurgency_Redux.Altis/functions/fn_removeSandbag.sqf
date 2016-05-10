/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_removeSandbag.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Removes the insurgency A2 style sandbag

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_sandbag","_player","_unitType"];

_sandbag = INS_SANDBAG;
_player = _this select 1;
_unitType = typeOf (vehicle player);
_distance = _player distance _sandbag;

if (_distance > 5) exitWith {
	private ["_title","_text"];

	_title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
	<img  color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
	_text = format["%1<t align='center' color='#eaeaea'>Unable to remove sandbag. Must be within (5 Meters) of the object</t><br/>
	<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />", _title];

	["openSideTop",1.4] call ALIVE_fnc_displayMenu;
	["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

_player removeAction (_this select 2);
_player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

//--- Delete old sandbag
if (!isNull INS_SANDBAG) then {
	deletevehicle INS_SANDBAG;

};

//--- Verify user is still the same class. If not we'll show him!
if ((_unitType in INS_AUTORIFLE) || (_unitType in INS_ENGINEERS)) then {

	//--- Add sandbag action back to the player.
	_id = player addaction ["<t color='#FFFF00'>Deploy Sandbag</t>", "call INS_fnc_deploySandbag", nil, -10, false];
};