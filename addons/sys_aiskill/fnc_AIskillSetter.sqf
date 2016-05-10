#include <\x\alive\addons\sys_aiskill\script_component.hpp>
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

_factionSkills = [ADDON, "factionSkills"] call ALiVE_fnc_AISkill;
_debug = [ADDON, "debug"] call ALiVE_fnc_AISkill;

_faction = faction _unit;
_side = side _unit;

_aimingAccuracy = _unit skill "aimingAccuracy";
_aimingShake = _unit skill "aimingShake";
_aimingSpeed = _unit skill "aimingSpeed";

if ((_faction in (_factionSkills select 1)) && {!(_side == CIVILIAN)}) then {
    _factionSkill = [_factionSkills,_faction] call ALIVE_fnc_hashGet;

    if((_aimingAccuracy != _factionSkill select 2) && (_aimingShake != _factionSkill select 3) && (_aimingSpeed != _factionSkill select 4)) then {

        _minSkill = _factionSkill select 0;
        _maxSkill = _factionSkill select 1;
        _diff = _maxSkill - _minSkill;
        
		_aimingAccuracy = _factionSkill select 2;
		_aimingShake = _factionSkill select 3;
		_aimingSpeed = _factionSkill select 4;
		_endurance = _factionSkill select 5;
		_spotDistance = _factionSkill select 6;
		_spotTime = _factionSkill select 7;
		_courage = _factionSkill select 8;
		_reloadSpeed = _factionSkill select 9;
		_commanding = _factionSkill select 10;
		_general = _factionSkill select 11;

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
        
        if (_debug) then {["ALiVE Skill set on %1: %2",_unit,_factionSkill] call ALiVE_fnc_DumpR};
    };
};

_unit;