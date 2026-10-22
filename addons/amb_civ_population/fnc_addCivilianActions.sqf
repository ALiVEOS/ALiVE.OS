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
Jman
---------------------------------------------------------------------------- */

private _object = _this select 0;

if ((side group _object) != CIVILIAN) exitWith {};

// Skip the legacy role-talk + detain / search / intel scroll-wheel
// sprawl unless the mission-maker explicitly selected CLASSIC mode on
// the civilian interaction UI attribute. In every other mode (AUTO /
// DIALOG / ACE) the same verbs are reachable through the dialog
// (`Negotiate` button + gear browser) or the ACE branch, avoiding the
// ~10-item addAction list that motivated the UX consolidation.
if ((missionNamespace getVariable ["ALiVE_amb_civ_population_UIMode", "AUTO"]) != "CLASSIC") exitWith {};

// Hand over aid to the town, as the dialog and the ACE menu offer it. It needs no roles.
_object addAction [
    (localize "STR_ALIVE_CIV_POP_AIDCRATE_ACTION") call ALiVE_fnc_actionTitle,
    {[ALiVE_civInteractHandler, "HandOverCrate", _this select 0] call ALiVE_fnc_civInteract},
    [],
    1,
    false,
    true,
    "",
    "alive _target && {missionNamespace getVariable ['ALiVE_amb_civ_population_AidCrateEnabled', false]} && {!isNull (['nearest', [_target, 15]] call ALiVE_fnc_aidCrate)}",
    5
];

// The rest only with civilian roles on (the module's Civilian Roles field isn't None).
if (isnil QGVAR(ROLES_DISABLED) || {GVAR(ROLES_DISABLED)}) exitWith {};

// Where can I find the town elder (or mayor: the first role in the module's list), as the
// dialog and the ACE menu ask it.
private _wantedRole = (missionNamespace getVariable [QGVAR(ROLES), []]) param [0, "townelder"];
_object addAction [
    (format [localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_FINDROLE", localize format ["STR_ALIVE_CIV_INTERACT_ACTIONS_ROLE_%1", toUpper _wantedRole]]) call ALiVE_fnc_actionTitle,
    {[ALiVE_civInteractHandler, "FindRole", _this select 0] call ALiVE_fnc_civInteract},
    [],
    1,
    false,
    true,
    "",
    // not asked of a hostile civilian, as the dialog and the ACE menu hold it back
    "alive _target && {[_target, 60] call ALiVE_fnc_civAceTierGate}",
    5
];

// Each Talk to entry shows for a civilian carrying that role's flag. The flag was looked up by
// the translated role word, which is the flag's name only in English, and not even there for
// the town elder, so these entries never showed in another language.
private _role = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_ROLE_TOWNELDER";
private _text = format[localize "STR_ALIVE_CIV_INTERACT_ACTIONS_TALKTO",_role];
private _params = [];
private _code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3; [_object,_caller] call ALiVE_fnc_SelectRoleAction};
private _condition = "alive _target && {_target getvariable ['townelder',false]}";

private _id = _object addAction [
    (_text) call ALiVE_fnc_actionTitle,
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
_condition = "alive _target && {_target getvariable ['major',false]}";

_id = _object addAction [
    (_text) call ALiVE_fnc_actionTitle,
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
_condition = "alive _target && {_target getvariable ['priest',false]}";

_id = _object addAction [
    (_text) call ALiVE_fnc_actionTitle,
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
_condition = "alive _target && {_target getvariable ['muezzin',false]}";

_id = _object addAction [
    (_text) call ALiVE_fnc_actionTitle,
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
_condition = "alive _target && {_target getvariable ['politician',false]}";

_id = _object addAction [
    (_text) call ALiVE_fnc_actionTitle,
    _code,
    _params,
    1,
    false,
    true,
    "",
    _condition,
    5
];


_text = localize "STR_ALIVE_CIV_INTERACT_ACTIONS_STOP";
_params = [];
_code = {_object = _this select 0; _caller = _this select 1; _params = _this select 3;  _group = if (side (group _object) == Civilian) then {group _object} else {createGroup Civilian}; _object disableAI "MOVE"; sleep (60 + (ceil random 20)); _object enableAI "MOVE"; _object setUnitPos "AUTO";};
_condition = "alive _target";

_id = _object addAction [
    (_text) call ALiVE_fnc_actionTitle,
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
    (_text) call ALiVE_fnc_actionTitle,
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
    (_text) call ALiVE_fnc_actionTitle,
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
    (_text) call ALiVE_fnc_actionTitle,
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
    (_text) call ALiVE_fnc_actionTitle,
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
        (_text) call ALiVE_fnc_actionTitle,
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