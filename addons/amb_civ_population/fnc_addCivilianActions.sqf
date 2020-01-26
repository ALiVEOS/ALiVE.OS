#include "\x\alive\addons\amb_civ_population\script_component.hpp"
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

private _object = _this select 0;

if (side _object != CIVILIAN || {isnil QGVAR(ROLES_DISABLED)} || {GVAR(ROLES_DISABLED)}) exitWith {}; // only add actions if civilian roles module field != none

private _role = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_ROLE_TOWNELDER";
private _text = format[localize "STR_ALIVE_CIV_INTERACT_ACTIONS_TALKTO",_role];
private _params = [];
private _code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; [_object,_caller] call ALiVE_fnc_SelectRoleAction};
private _condition = "alive _target" + "&&" + format["_target getvariable [%1,false]",str(_role)];

private _id = _object addAction [
    _text,
    _code,
    _params,
    1,
    false,
    true,
    "",
    _condition,
    5
];

_role = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_ROLE_MAJOR";
_text = format[localize "STR_ALIVE_CIV_INTERACT_ACTIONS_TALKTO",_role];
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
    _condition,
    5
];

_role = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_ROLE_PRIEST";
_text = format[localize "STR_ALIVE_CIV_INTERACT_ACTIONS_TALKTO",_role];
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
    _condition,
    5
];

_role = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_ROLE_MUEZZIN";
_text = format[localize "STR_ALIVE_CIV_INTERACT_ACTIONS_TALKTO",_role];
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
    _condition,
    5
];

_role = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_ROLE_POLITICIAN";
_text = format[localize "STR_ALIVE_CIV_INTERACT_ACTIONS_TALKTO",_role];
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
    _condition,
    5
];

_text = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_DETAIN";
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
    _condition,
    5
];

_text = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_ARREST";
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; _group = if (side (group _object) == Civilian) then {group _object} else {createGroup Civilian}; [_object] joinsilent _group; _object disableAI "PATH"};
_condition = "alive _target" + "&&" + "(_target getvariable ['detained',false])";

_id = _object addAction [
    _text,
    _code,
    _params,
    1,
    false,
    true,
    "",
    _condition,
    5
];

_text = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_RELEASE";
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; _group = if (side (group _object) == Civilian) then {group _object} else {createGroup Civilian}; [_object] joinsilent _group; _object setvariable ['detained',false,true]; _object enableAI "PATH"};
/*
// Causes units to return to group leader and pile up there - #277)
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; _group = [ALIVE_civilianPopulationSystem, "civGroup"] call ALiVE_fnc_HashSet; [_object] joinsilent _group; _object setvariable ['detained',false,true]};
*/
_condition = "alive _target" + "&&" + "_target getvariable ['detained',false]";

_id = _object addAction [
    _text,
    _code,
    _params,
    1,
    false,
    true,
    "",
    _condition,
    5
];

_text = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_SEARCH";
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
    _condition,
    5
];

if (random 1 > 0.9) then {
    _text = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_GATHERINTEL";
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
        _condition,
        5
    ];
};

true;