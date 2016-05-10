#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(aliveInit);


/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_aliveInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_alive>

Author:
Wolffy.au
Tupolov
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_aliveInit

#define DEFAULT_DEBUG "false"
#define DEFAULT_GC_THRESHOLD "100"
#define DEFAULT_GC_INTERVAL "300"
#define DEFAULT_GC_INDIVIDUALTYPES ""

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// CREATE MODULE IF IT DOES NOT EXIST
// Check to see if module was placed... (might be auto enabled)
if (isnil "_logic") then {
    if (isServer) then {

        // Ensure only one module is used
        if !(isNil QMOD(require)) then {
            _logic = MOD(require);
            ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_REQUIRESALIVE_ERROR1");
        } else {
            _logic = (createGroup sideLogic) createUnit [QMOD(require), [0,0], [], 0, "NONE"];
            MOD(require) = _logic;
        };

        //Push to clients
        PublicVariable QMOD(require);
    };

    TRACE_1("Waiting for object to be ready",true);

    waituntil {!isnil QMOD(require)};

    TRACE_1("Creating class on all localities",true);

    _logic = MOD(require);

};
// Init ALIVE_Requires

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

//Only one init per instance is allowed
if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE Require - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

//Start init
_logic setVariable ["initGlobal", false];

//["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

//Start ALiVE Requires init
_logic setVariable ["init", false];
_logic setVariable ["super", SUPERCLASS];
_logic setVariable ["class", MAINCLASS];
_logic setVariable ["moduleType", QMOD(require)];
_logic setVariable ["startupComplete", false];

MOD(require) = _logic;

//--------------------------------------------------------------------------------------------------------//
// Init base systems on server and client

TRACE_1("Launching Base ALiVE Systems",true);

// NewsFeed
[] spawn ALiVE_fnc_newsFeedInit;

// Admin Actions
if !(_logic getVariable ["ALIVE_DISABLEADMINACTIONS", false]) then {
    [] spawn ALiVE_fnc_adminActionsInit;
};

// Advanced Markers
if !(_logic getVariable ["ALIVE_DISABLEMARKERS", false]) then {
    [] spawn ALIVE_fnc_spotrepInit;
    [] spawn ALiVE_fnc_markerInit;
};

// Player Logistics
[] spawn ALiVE_fnc_logisticsInit;

// Pause Modules
if (_logic getVariable ["ALIVE_PAUSEMODULES", false]) then {
	call ALiVE_fnc_pauseModulesAuto;
};

// Garbage Collector
private "_GC";
_GC = [nil, "create"] call ALiVE_fnc_GC;
_GC setVariable ["debug", _logic getVariable ["debug", DEFAULT_DEBUG]];
_GC setVariable ["ALiVE_GC_INTERVAL", _logic getVariable ["ALiVE_GC_INTERVAL", DEFAULT_GC_INTERVAL]];
_GC setVariable ["ALiVE_GC_THRESHHOLD", _logic getVariable ["ALiVE_GC_THRESHHOLD", DEFAULT_GC_THRESHOLD]];
_GC setVariable ["ALiVE_GC_INDIVIDUALTYPES", _logic getVariable ["ALiVE_GC_INDIVIDUALTYPES", DEFAULT_GC_INDIVIDUALTYPES]];
[_GC, "init"] spawn ALiVE_fnc_GC;

//---------------------------------------------------------------------------------------------------------//

// Only on Server
if (isServer) then {
    //Sets global type of Versioning (Kick or Warn)
	MOD(VERSIONINGTYPE) = _logic getvariable [QMOD(VERSIONING),"warning"];
	Publicvariable QMOD(VERSIONINGTYPE);

    //Enables/Disables SP saving possibility, default value true due to out of mem crashes
    MOD(DISABLESAVE) = _logic getvariable [QMOD(DISABLESAVE),"true"];
    Publicvariable QMOD(DISABLESAVE);

    //Activates dynamic AI distribution to all available headless clients
    MOD(AI_DISTRIBUTION) = call compile (_logic getvariable [QMOD(AI_DISTRIBUTION),"false"]);
    MOD(AI_DISTRIBUTION) spawn ALiVE_fnc_AI_Distributor;

    // Event Log
    ALIVE_eventLog = [nil, "create"] call ALIVE_fnc_eventLog;
    [ALIVE_eventLog, "init"] call ALIVE_fnc_eventLog;
    [ALIVE_eventLog, "debug", false] call ALIVE_fnc_eventLog;

    //Waiting for the mandatory modules below, mind that not all modules need to be initialised before mission start
	waitUntil {
		[
	        QMOD(amb_civ_placement),
	        QMOD(mil_placement),
	        QMOD(civ_placement),
	        QMOD(mil_placement_custom),
            QMOD(mil_cqb),
            QMOD(mil_OPCOM)
        ] call ALiVE_fnc_isModuleInitialised;
	};
    //This is the last module init to be run, therefore indicates that init of the defined modules above has passed on server
    MOD(REQUIRE_INITIALISED) = true;
    Publicvariable QMOD(REQUIRE_INITIALISED);

    _logic setVariable ["init", true, true];
};

// Only on clients
if (hasInterface) then {
    waituntil {!isnil QMOD(DISABLESAVE)}; // Wait for global var to be set on Server

    if (call compile MOD(DISABLESAVE)) then {enableSaving [false, false]};
};

waitUntil {!(isNil QMOD(REQUIRE_INITIALISED))};

// Indicate Init is finished on server
if (isServer) then {
    _logic setVariable ["startupComplete", true, true];
};

//["%1 - Initialisation Completed...",MOD(require)] call ALiVE_fnc_Dump;
_logic setVariable ["bis_fnc_initModules_activate",true];

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

["ALiVE Global INIT COMPLETE"] call ALIVE_fnc_dump;
[false,"ALiVE Global Init Timer Complete","INIT"] call ALIVE_fnc_timer;
[" "] call ALIVE_fnc_dump;