#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(aliveAutoInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_aliveAutoInit
Description:
Inits all modules and sets defaults

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_alive>

Author:
Tupolov
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Do Something

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

// Only on Server
if (isServer) then {
    private ["_logicVariables","_autoLogic"];
    // Get all logic variables
    _logicVariables = (configFile >> "CfgVehicles" >> "ALiVE" >> "Arguments") call BIS_fnc_getCfgSubClasses;

    // Initialize Data first
    If (isDedicated && (_logic getVariable "Database")) then {
        [] call ALiVE_fnc_dataInit;
    };

    _autoLogic = [
        ["ALiVE_fnc_AISkill",[3,4,5,6]],
        ["ALiVE_fnc_profile",[]],
        ["ALiVE_fnc_civilianPopulationSystem",[7,8,9]],
        ["ALiVE_fnc_ambcp",[0]],
        ["ALiVE_fnc_mp",[0]],
        ["ALiVE_fnc_cp",[0]],
        ["ALiVE_fnc_OPCOM",[0]],
        ["ALiVE_fnc_cqb",[0]],
        ["ALiVE_fnc_C2ISTAR",[0]],
        ["ALiVE_fnc_combatsupport",[0]],
 //       ["ALiVE_fnc_playeroptions",[0]],
        ["ALiVE_fnc_aliveInit",[1,2]]
    ];

    {
        private ["_module","_fnc","_vars","_moduleLogic"];
        _module = _x select 0;
        _fnc = _x select 1;
        _vars = _x select 2;

        // Create
        _moduleLogic = [nil,"create"] call compile _fnc;

        // Set
        {
            _value = _logic getVariable (_logicVariables select _x);
            _moduleLogic setVariable [(_logicVariables select _x), _value];
        } foreach _vars;

        // Init
        [_moduleLogic,"init"] call compile _fnc;
    } forEach _autoLogic;

    // Init all modules

    // DATA including stats, perf, newsfeed, aar


    // AUTO modules - Events, GC, Debug, Markers, Player log, Admin Actions

    // AI SKILL?

    // Need to take settings from autoinit module and apply to AISkill module ...

    // PROFILES

    // CIV POP

    // AMB CIV

    // MIL PLACEMENT

    // CIV PLACEMENT

    // OPCOM

    // CQB

    // C2ISTAR including tasks, intel, msd, psd, sitrep/patrolrep

    // CSS including player resupply, CAS, Transport and arty

    // PLAYER OPTIONS including crew, tags, vd, multispawn, player persistence

    // Requires ALiVE
};

// Only on clients
if (hasInterface) then {
    // Init anything required on client
};

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

["ALiVE Global INIT COMPLETE"] call ALIVE_fnc_dump;
[false,"ALiVE Global Init Timer Complete","INIT"] call ALIVE_fnc_timer;
[" "] call ALIVE_fnc_dump;
