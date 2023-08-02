// by Bon_Inf*
//Modified by Moser -- 07/18/2014

#include "dialog\definitions.sqf"
disableSerialization;

if (bon_dynamic_list) then {
_scripthandler =[] execVM "bon_recruit_units\recruitable_units.sqf"; 	//executes dynamic arrray builder to find units of player's subfaction
waitUntil{ ScriptDone _scripthandler  };								//MUST wait for script to finish
} else {
#include "recruitable_units_static.sqf"
};

_display = findDisplay BON_RECRUITING_DIALOG;
_unitlist = _display displayCtrl BON_RECRUITING_UNITLIST;
_queuelist = _display displayCtrl BON_RECRUITING_QUEUE;

_queuelist ctrlSetText format["Units queued: %1",count bon_recruit_queue];


_weaponstring = "";
{
	_displname = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
	_picture = getText (configFile >> "CfgVehicles" >> _x >> "portrait");
	_weaponstring = format["%1",_displname,_picture];
	_unitlist lbAdd _weaponstring;
} foreach bon_recruit_recruitableunits;