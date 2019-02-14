#include "\x\alive\addons\sys_aiskill\script_component.hpp"
SCRIPT(AISkillSetter);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AISkillSetter
Description:

Sets a defined set of skills on the given unit. Skills are defined on the AI Skill main class

Parameters:
_this select 0: OBJECT - unit

Returns:
_unit

See Also:
- <ALIVE_fnc_AISkillSetter>

Author:
Highhead

Peer Reviewed:

---------------------------------------------------------------------------- */

private ["_unit"];

PARAMS_1(_unit);

// Exit if unit is not local
if !(local _unit) exitwith {};

// Waituntil game starts
// Sadly init EH kicks in on editor placed units before the AI skill main class is created.
waituntil {time > 0};

// Exit if main class is not available (or has not been initialised yet)
if (isnil QUOTE(ADDON) || {!(ADDON getVariable ["startupComplete", false])}) exitwith {
    //["ALiVE AI Skill not active exiting! Unit: %1!",_unit] call ALiVE_fnc_DumpR
};

private _factionSkills = [ADDON, "factionSkills"] call ALiVE_fnc_AISkill;
private _debug = [ADDON, "debug"] call ALiVE_fnc_AISkill;

private _faction = faction _unit;

private _aimingAccuracy = _unit skill "aimingAccuracy";
private _aimingShake = _unit skill "aimingShake";
private _aimingSpeed = _unit skill "aimingSpeed";

if ((_faction in (_factionSkills select 1)) && {!(side _unit == CIVILIAN)}) then {
    _factionSkill = [_factionSkills,_faction] call ALIVE_fnc_hashGet;

    if((_aimingAccuracy != _factionSkill select 2) && {_aimingShake != _factionSkill select 3} && {_aimingSpeed != _factionSkill select 4}) then {

        _factionSkill params [
            "_minSkill","_maxSkill","_aimingAccuracy","_aimingShake",
            "_aimingSpeed","_endurance","_spotDistance","_spotTime",
            "_courage","_fleeing","_reloadSpeed","_commanding","_general"
        ];

        _diff = _maxSkill - _minSkill;

        _unit setUnitAbility (_minSkill + (random _diff));

        _unit setSkill ["aimingAccuracy", _aimingAccuracy];
        _unit setSkill ["aimingShake", _aimingShake];
        _unit setSkill ["aimingSpeed", _aimingSpeed];
        _unit setSkill ["endurance", _endurance];
        _unit setSkill ["spotDistance", _spotDistance];
        _unit setSkill ["spotTime", _spotTime];
        _unit setSkill ["courage", _courage];
        _unit setSkill ["reloadSpeed", _reloadSpeed];
        _unit setSkill ["commanding", _commanding];
        _unit setSkill ["general", _general];

        _unit allowFleeing _fleeing;

        if (_debug) then {["ALiVE Skill set on %1: %2",_unit,_factionSkill] call ALiVE_fnc_DumpR};
    };
};

_unit;