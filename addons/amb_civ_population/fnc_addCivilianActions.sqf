#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(addCivilianActions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addCivilianActions

Description:
Adds civilian actions

Parameters:

Returns:
Bool - true

Examples:
(begin example)
//
_result = _unit call ALIVE_fnc_addCivilianActions;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_object","_operation","_id","_condition","_text"];

_object = _this select 0;

if (side _object != CIVILIAN || {isnil QGVAR(ROLES_DISABLED)} || {GVAR(ROLES_DISABLED)}) exitWith {}; // only add actions if civilian roles module field != none

_role = "townelder";
_text = format["Talk to %1",_role];
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; [_object,_caller] call ALiVE_fnc_SelectRoleAction};
_condition = "alive _target" + "&&" + format["_target getvariable [%1,false]",str(_role)];

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

_role = "major";
_text = format["Talk to %1",_role];
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; [_object,_caller] call ALiVE_fnc_SelectRoleAction};
_condition = "alive _target" + "&&" + format["_target getvariable [%1,false]",str(_role)];

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

_role = "priest";
_text = format["Talk to %1",_role];
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; [_object,_caller] call ALiVE_fnc_SelectRoleAction};
_condition = "alive _target" + "&&" + format["_target getvariable [%1,false]",str(_role)];

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

_role = "muezzin";
_text = format["Talk to %1",_role];
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; [_object,_caller] call ALiVE_fnc_SelectRoleAction};
_condition = "alive _target" + "&&" + format["_target getvariable [%1,false]",str(_role)];

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

_role = "politician";
_text = format["Talk to %1",_role];
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; [_object,_caller] call ALiVE_fnc_SelectRoleAction};
_condition = "alive _target" + "&&" + format["_target getvariable [%1,false]",str(_role)];

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

_text = "Arrest";
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; _group = group _object; [_object] joinsilent (group _caller); _object setvariable ['detained',true,true]; _group call ALiVE_fnc_DeleteGroupRemote};
_condition = "alive _target" + "&&" + "!(_target getvariable ['detained',false])";

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

_text = "Release";
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; _group = createGroup Civilian; [_object] joinsilent _group; _object setvariable ['detained',false,true]};
_condition = "alive _target" + "&&" + "_target getvariable ['detained',false]";

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

_text = "Search";
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; _caller action ["Gear", _object]};
_condition = "alive _target";

_id = _object addAction [
	_text,
	_code,
	_params,
	1,
	false,
	true,
	"",
	_condition
];

if (random 1 > 0.9) then {
	_text = "Gather Intel";
	_params = [];
	_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; openmap true; [getposATL _object, 2000] call ALiVE_fnc_OPCOMToggleInstallations; _object setvariable ["intelGathered",true]};
	_condition = "alive _target && {isnil {_target getvariable 'intelGathered'}}";
	
	_id = _object addAction [
		_text,
		_code,
		_params,
		1,
		false,
		true,
		"",
		_condition
	];
};
true;