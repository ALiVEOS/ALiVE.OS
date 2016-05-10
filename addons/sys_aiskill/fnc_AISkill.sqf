//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_aiskill\script_component.hpp>
SCRIPT(AISkill);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AISkill
Description:
Sector Display

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state
Nil - register
Nil - start
String or Array - skillFactionsRecruit
String or Array - skillFactionsRegular
String or Array - skillFactionsVeteran
String or Array - skillFactionsExpert
Scalar - customSkillFactions
Scalar - customSkillAbilityMin
Scalar - customSkillAbilityMax
Scalar - customSkillAimAccuracy
Scalar - customSkillAimShake
Scalar - customSkillAimSpeed
Scalar - customSkillEndurance
Scalar - customSkillSpotDistance
Scalar - customSkillSpotTime
Scalar - customSkillCourage
Scalar - customSkillReload
Scalar - customSkillCommanding
Scalar - customSkillGeneral

Examples:
[_logic, "debug", true] call ALiVE_fnc_AISkill;

See Also:
- <ALIVE_fnc_AISkillInit>

Author:
ARJay

Peer Reviewed:
Wolffy.au 20131113
---------------------------------------------------------------------------- */

/*
* Does this mean that skill of every unit of the faction is identically set?
* Does this impact the allocation of skill based upon rank? If so, my
* preference is to keep the BI model, that different ranks get different skill
* levels, which means team leaders are more skilled and more important to kill
* during game play.
*/

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_AISkill
#define MTEMPLATE "ALiVE_AISKILL_%1"

private ["_logic","_operation","_args","_result","_debug"];

TRACE_1("AISKILL - input",_this);

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

switch(_operation) do {
	default {
		_result = [_logic, _operation, _args] call SUPERCLASS;
	};

    case "create": {
		_result = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];
    };

	case "destroy": {
		[_logic, "debug", false] call MAINCLASS;
		if (isServer) then {
			// if server
			_logic setVariable ["super", nil];
			_logic setVariable ["class", nil];

			[_logic, "destroy"] call SUPERCLASS;
		};
	};
	case "debug": {
		// FIXME - my preference would be to use a swtich statement here
		// rather than multiple if statements
		if (typeName _args == "BOOL") then {
			_logic setVariable ["debug", _args];
		} else {
			_args = _logic getVariable ["debug", false];
		};
		// FIXME - what is the requirement for STRING input also?
		// Check "typeName" in https://community.bistudio.com/wiki/Arma_3_Module_Framework
		if (typeName _args == "STRING") then {
			if(_args == "true") then {_args = true;} else {_args = false;};
			_logic setVariable ["debug", _args];
		};
		ASSERT_TRUE(typeName _args == "BOOL",str _args);

		_result = _args;
	};
	case "pause": {
        if(typeName _args != "BOOL") then {
            // if no new value was provided return current setting
            _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
        } else {
                // if a new value was provided set groups list
                ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                private ["_state"];
                _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                if (_state && _args) exitwith {};

                //Set value
                _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;
                ["ALiVE Pausing state of %1 instance set to %2!",QUOTE(ADDON),_args] call ALiVE_fnc_DumpR;
        };
        _result = _args;
    };
	// FIXME - state operation does not appear to be required
	// either remove or fix to serialise to string
	case "state": {
		private["_state","_data","_nodes","_simple_operations"];
		/*
		_simple_operations = ["targets", "size","type","faction"];

		if(typeName _args != "ARRAY") then {
			_state = [] call CBA_fnc_hashCreate;
			// Save state
			{
				[_state, _x, _logic getVariable _x] call ALIVE_fnc_hashSet;
			} forEach _simple_operations;

			if ([_logic, "debug"] call MAINCLASS) then {
				diag_log PFORMAT_2(QUOTE(MAINCLASS), _operation,_state);
			};
			_result = _state;
		} else {
			ASSERT_TRUE([_args] call CBA_fnc_isHash,str _args);

			// Restore state
			{
				[_logic, _x, [_args, _x] call ALIVE_fnc_hashGet] call MAINCLASS;
			} forEach _simple_operations;
		};
		*/
	};
    
	// Main process
	case "init": {
		// Using isGlobal = 0 to ensure it is only run on server anyway
        // If setSkill is locality sensitive, we need to run this everywhere
        
		if (isServer) then {
			// if server, initialise module game logic
            if !(isNil QUOTE(ADDON)) then {
                _logic = ADDON;
                
                // Ensure only one module is used
                ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_AISKILL_ERROR1");
            } else {
                ADDON = _logic;
            };
            
	        //Push to clients
	        PublicVariable QUOTE(ADDON);
		};

        TRACE_1("Waiting for object to be ready",true);

        waituntil {!isnil QUOTE(ADDON)};
        
        TRACE_1("Creating class on all localities",true);

        // initialise module game logic on all localities
        ADDON setVariable ["super", QUOTE(SUPERCLASS)];
        ADDON setVariable ["class", QUOTE(MAINCLASS)];

		ADDON setVariable ["moduleType", "ALIVE_AISKill"];
		ADDON setVariable ["startupComplete", false];
        
        
        TRACE_1("After module init",_logic);
        
        if (isServer) then {
			[_logic, "skillFactionsRecruit", _logic getVariable ["skillFactionsRecruit", []]] call MAINCLASS;
			[_logic, "skillFactionsRegular", _logic getVariable ["skillFactionsRegular", []]] call MAINCLASS;
			[_logic, "skillFactionsVeteran", _logic getVariable ["skillFactionsVeteran", []]] call MAINCLASS;
			[_logic, "skillFactionsExpert", _logic getVariable ["skillFactionsExpert", []]] call MAINCLASS;
			[_logic, "customSkillFactions", _logic getVariable ["customSkillFactions", []]] call MAINCLASS;

			[_logic, "start"] call MAINCLASS;            
        };
	};
    
	case "skillFactionsRecruit": {
		// FIXME - my preference would be to use a swtich statement here
		// rather than multiple if statements
		// FIXME - I see this code stanza repeated many times. Can it be made
		// into a main function like OOsimpleOperation?
		if(typeName _args == "STRING") then {
			_args = [_args, " ", ""] call CBA_fnc_replace;
			_args = [_args, ","] call CBA_fnc_split;
			if(count _args > 0) then {
				_logic setVariable [_operation, _args];
			};
		};
		if(typeName _args == "ARRAY") then {
			_logic setVariable [_operation, _args];
		};
		_result = _logic getVariable [_operation, []];
	};
	case "skillFactionsRegular": {
		// FIXME - my preference would be to use a swtich statement here
		// rather than multiple if statements
		if(typeName _args == "STRING") then {
			_args = [_args, " ", ""] call CBA_fnc_replace;
			_args = [_args, ","] call CBA_fnc_split;
			if(count _args > 0) then {
				_logic setVariable [_operation, _args];
			};
		};
		if(typeName _args == "ARRAY") then {
			_logic setVariable [_operation, _args];
		};
		_result = _logic getVariable [_operation, []];
	};
	case "skillFactionsVeteran": {
		// FIXME - my preference would be to use a swtich statement here
		// rather than multiple if statements
		if(typeName _args == "STRING") then {
			_args = [_args, " ", ""] call CBA_fnc_replace;
			_args = [_args, ","] call CBA_fnc_split;
			if(count _args > 0) then {
				_logic setVariable [_operation, _args];
			};
		};
		if(typeName _args == "ARRAY") then {
			_logic setVariable [_operation, _args];
		};
		_result = _logic getVariable [_operation, []];
	};
	case "skillFactionsExpert": {
		// FIXME - my preference would be to use a swtich statement here
		// rather than multiple if statements
		if(typeName _args == "STRING") then {
			_args = [_args, " ", ""] call CBA_fnc_replace;
			_args = [_args, ","] call CBA_fnc_split;
			if(count _args > 0) then {
				_logic setVariable [_operation, _args];
			};
		};
		if(typeName _args == "ARRAY") then {
			_logic setVariable [_operation, _args];
		};
		_result = _logic getVariable [_operation, []];
	};
	case "customSkillFactions": {
		// FIXME - my preference would be to use a swtich statement here
		// rather than multiple if statements
		if(typeName _args == "STRING") then {
			_args = [_args, " ", ""] call CBA_fnc_replace;
			_args = [_args, ","] call CBA_fnc_split;
			if(count _args > 0) then {
				_logic setVariable [_operation, _args];
			};
		};
		if(typeName _args == "ARRAY") then {
			_logic setVariable [_operation, _args];
		};
		_result = _logic getVariable [_operation, []];
	};
	case "customSkillAbilityMin": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillAbilityMax": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillAimAccuracy": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillAimShake": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillAimSpeed": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillEndurance": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillSpotDistance": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillSpotTime": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillCourage": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillReload": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillCommanding": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "customSkillGeneral": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,0]] call ALIVE_fnc_OOsimpleOperation;
	};
	case "factionSkills": {
		_result = [_logic,_operation,_args,_logic getvariable [_operation,[]]] call ALIVE_fnc_OOsimpleOperation;
	};


	/* As a component, I would expect that the spawn process can be started and
	* stopped as required. Personally, I would create an "active"(bool)
	* operation to stop and start the process. I would check for a getVariable
	* at the end of every waitUntil, which can be set remote by a call to
	* active(false).
    * 
    * Edit Highhead: Moved to Init EH completely, no loop needed at all
	*/

	case "start": {
        
        // To be discussed: could be done on all localities to save PVs?
		if !(isServer) exitwith {};

		_debug = [_logic, "debug"] call MAINCLASS;

		private ["_minSkill","_maxSkill","_diff","_factionSkill","_faction","_aimingAccuracy","_aimingShake","_aimingSpeed",
        "_skillFactionsRecruit","_skillFactionsRegular","_skillFactionsVeteran","_customSkillFactions","_customSkillAbilityMin",
		"_customSkillAbilityMax","_customSkillAimAccuracy","_customSkillAimShake","_customSkillAimSpeed","_customSkillEndurance",
		"_customSkillSpotDistance","_customSkillSpotTime","_customSkillCourage","_customSkillReload","_customSkillCommanding",
		"_customSkillGeneral","_recruitSkill","_regularSkill","_veteranSkill","_expertSkill","_customSkill","_factionSkills",
		"_skillFactionsExpert","_countEffected","_side"];

		_skillFactionsRecruit = [_logic, "skillFactionsRecruit"] call MAINCLASS;
		_skillFactionsRegular = [_logic, "skillFactionsRegular"] call MAINCLASS;
		_skillFactionsVeteran = [_logic, "skillFactionsVeteran"] call MAINCLASS;
		_skillFactionsExpert = [_logic, "skillFactionsExpert"] call MAINCLASS;
		_customSkillFactions = [_logic, "customSkillFactions"] call MAINCLASS;
		_customSkillAbilityMin = [_logic, "customSkillAbilityMin"] call MAINCLASS;
		_customSkillAbilityMax = [_logic, "customSkillAbilityMax"] call MAINCLASS;
		_customSkillAimAccuracy = [_logic, "customSkillAimAccuracy"] call MAINCLASS;
		_customSkillAimShake = [_logic, "customSkillAimShake"] call MAINCLASS;
		_customSkillAimSpeed = [_logic, "customSkillAimSpeed"] call MAINCLASS;
		_customSkillEndurance = [_logic, "customSkillEndurance"] call MAINCLASS;
		_customSkillSpotDistance = [_logic, "customSkillSpotDistance"] call MAINCLASS;
		_customSkillSpotTime = [_logic, "customSkillSpotTime"] call MAINCLASS;
		_customSkillCourage = [_logic, "customSkillCourage"] call MAINCLASS;
		_customSkillReload = [_logic, "customSkillReload"] call MAINCLASS;
		_customSkillCommanding = [_logic, "customSkillCommanding"] call MAINCLASS;
		_customSkillGeneral = [_logic, "customSkillGeneral"] call MAINCLASS;


		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE AISKILL Recruit:[%1] Regular:[%2] Veteran:[%3] Expert:[%4]",_skillFactionsRecruit,_skillFactionsRegular,_skillFactionsVeteran,_skillFactionsExpert] call ALIVE_fnc_dump;
			["ALiVE AISKILL Custom Skill: Factions:[%1]",_customSkillFactions] call ALIVE_fnc_dump;
			["ALiVE AISKILL Custom Skill: Min Ability:%1 Max Ability:%2",_customSkillAbilityMin,_customSkillAbilityMax] call ALIVE_fnc_dump;
			["ALiVE AISKILL Custom Skill: Aim Accuracy:%1 Aim Shake:%2 Aim Speed:%3",_customSkillAimAccuracy,_customSkillAimShake,_customSkillAimSpeed] call ALIVE_fnc_dump;
			["ALiVE AISKILL Custom Skill: Courage:%1 Endurance:%2 Spot Distance:%3 Spot Time:%4",_customSkillCourage,_customSkillEndurance,_customSkillSpotDistance,_customSkillSpotTime] call ALIVE_fnc_dump;
			["ALiVE AISKILL Custom Skill: Reload:%1 Commanding:%2 General:%3",_customSkillReload,_customSkillCommanding,_customSkillGeneral] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		if(
		    (count _skillFactionsRecruit == 0) &&
		    (count _skillFactionsRegular == 0) &&
		    (count _skillFactionsVeteran == 0) &&
		    (count _skillFactionsExpert == 0) &&
		    (count _customSkillFactions == 0)
		) then {
            _skillFactionsRegular = ["OPF_F","BLU_F","BLU_GL_F","IND_F"];
		};

		// min abil, max abil, aim acc, aim shake, aim speed, end, sdist, stime, cour, reload, comm, gen
		_recruitSkill = [0.2,0.21,0.01,1,0.05,0.05,0.2,0.2,0.05,0.05,1,0.2];
		_regularSkill = [0.2,0.25,0.05,0.9,0.1,0.1,0.5,0.4,0.1,0.1,1,0.5];
		_veteranSkill = [0.2,0.3,0.1,0.75,0.2,0.2,0.75,0.6,0.2,0.2,1,0.6];
		_expertSkill = [0.3,0.4,0.2,0.55,0.45,0.45,0.85,0.7,0.45,0.45,1,0.75];
		_customSkill = [_customSkillAbilityMin,_customSkillAbilityMax,_customSkillAimAccuracy,_customSkillAimShake,_customSkillAimSpeed,_customSkillEndurance,
		_customSkillSpotDistance,_customSkillSpotTime,_customSkillCourage,_customSkillReload,_customSkillCommanding,_customSkillGeneral];

		_factionSkills = [] call ALIVE_fnc_hashCreate;

		{
			[_factionSkills, _x, _recruitSkill] call ALIVE_fnc_hashSet;
		} forEach _skillFactionsRecruit;

		{
			[_factionSkills, _x, _regularSkill] call ALIVE_fnc_hashSet;
		} forEach _skillFactionsRegular;

		{
			[_factionSkills, _x, _veteranSkill] call ALIVE_fnc_hashSet;
		} forEach _skillFactionsVeteran;

		{
			[_factionSkills, _x, _expertSkill] call ALIVE_fnc_hashSet;
		} forEach _skillFactionsExpert;

		{
			[_factionSkills, _x, _customSkill] call ALIVE_fnc_hashSet;
		} forEach _customSkillFactions;
        
        ADDON setvariable ["factionSkills",_factionSkills,true];

		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE AISKILL Faction Skill Hash:"] call ALIVE_fnc_dump;
			_factionSkills call ALIVE_fnc_inspectHash;
		};
		// DEBUG -------------------------------------------------------------------------------------

		// set module as startup complete
		ADDON setVariable ["startupComplete", true,true];
	};
};

TRACE_1("AISKILL - output",_result);
_result;
