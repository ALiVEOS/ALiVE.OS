//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_civ_interaction\script_component.hpp>
SCRIPT(civInteractionHandler);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteractionHandler
Description:
Serverside handling of civilian interactions

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:

See Also:
- <ALiVE_fnc_civInteraction>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClass
#define MAINCLASS   ALiVE_fnc_civInteractionHandler

TRACE_1("Civ Interaction Handler - input", _this);

private ["_result"];
params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull]
];

switch(_operation) do {

    case "init": {

        // only one init per instance is allowed

        if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS Orbat Creator - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

        // start init

        if (isserver) then {

            MOD(civInteractionHandler) = _logic;

            _logic setVariable ["initGlobal", false];

            _logic setVariable ["super", QUOTE(SUPERCLASS)];
            _logic setVariable ["class", QUOTE(MAINCLASS)];
            _logic setVariable ["moduleType", QUOTE(ADDON)];
            _logic setVariable ["startupComplete", false];

            private _handler = [] call ALiVE_fnc_hashCreate;
            [_handler,"asymmetricFactions", []] call ALiVE_fnc_hashSet;
            [_handler,"conventionalFactions", []] call ALiVE_fnc_hashSet;

            [_logic,"debug", false] call MAINCLASS;
            [_logic,"civilianRoles", []] call MAINCLASS;
            [_logic,"handler", _handler] call MAINCLASS;

            [_logic,"start"] spawn MAINCLASS;

        };

    };

    case "start": {

        // wait for all mil commanders to init
        // exit after 15 minutes to detect commanders who fail init

        private _timer = 0;
        private _timeLimit = 60 * 20;

        waitUntil {
            sleep 1;
            _timer = _timer + 1;
            (_timer > _timeLimit) || {[QMOD(mil_OPCOM)] call ALiVE_fnc_isModuleInitialised};
        };

        if (_timer > _timeLimit) then {
            ["[ALiVE] Civ Interaction Handler - Military Commander stall timer reached"] call ALiVE_fnc_Dump; // don't exit
        };

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _asymmFac = [_handler,"asymmetricFactions"] call ALiVE_fnc_hashGet;
        private _convenFac = [_handler,"conventionalFactions"] call AliVE_fnc_hashGet;

        {
            if ([_x,"startupComplete"] call ALiVE_fnc_hashGet) then {

                private _factions = [_x,"factions"] call ALiVE_fnc_hashGet;

                if (([_x,"controltype"] call ALiVE_fnc_hashGet) == "asymmetric") then {
                    _asymmFac append _factions;
                } else {
                    _convenFac append _factions;
                };

            };
        } foreach OPCOM_instances;

        // set module as startup complete

        _logic setVariable ["startupComplete", true];

        publicVariable QMOD(civInteractionHandler);

    };

    case "destroy": {

        if (isServer) then {

            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];

            [_logic, "destroy"] call SUPERCLASS;

        };

    };

    case "handler": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, [] call ALiVE_fnc_hashCreate];
        };

    };

    case "debug": {

        if (_args isEqualType true) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, false];
        };

    };

    case "civilianRoles": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation,[]];
        };

    };

    case "getObjectiveInstallations": {

        private _objective = _args;

        private _HQ = [nil,"convertObject", [_objective,"HQ"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
        private _depot = [nil,"convertObject", [_objective,"depot"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
        private _factory = [nil,"convertObject", [_objective,"factory"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
        private _roadblocks = [nil,"convertObject", [_objective,"roadblocks"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

        private _ambush = [nil,"convertObject", [_objective,"ambush"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
        private _sabotage = [nil,"convertObject", [_objective,"sabotage"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
        private _ied = [nil,"convertObject", [_objective,"ied"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
        private _suicide = [nil,"convertObject", [_objective,"suicide"] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

        _result = [_HQ,_depot,_factory,_roadblocks,_ambush,_sabotage,_ied,_suicide];

    };

    case "getCivilianData": {

        private _civ = _args;

        private _civPos = getPos _civ;

        // check if there are any asymmetrical commanders

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _asymmFac = [_handler,"asymmetricFactions"] call ALiVE_fnc_hashGet;

        // get nearest objective
        // and grab any installations there

        private _installations = [[],[],[],[]];
        private _actions = [[],[],[],[]];

        if (count _asymmFac > 0) then {

            // get nearest objectives

            private _nearObjectives = [];

            {
                private _opcom = _x;

                {
                    if ({_x in ([_opcom, "factions"] call ALiVE_fnc_hashGet)}) exitwith {
                        private _objectives = [_x, "objectives"] call ALiVE_fnc_hashGet;
                        _objectives = [_objectives,[_civPos],{_Input0 distance2D ([_x, "center"] call ALiVE_fnc_hashGet)},"ASCEND"] call ALiVE_fnc_sortBy;

                        _nearObjectives pushback (_objectives select 0);
                    };
                } foreach _asymmFac;
            } count OPCOM_instances;

            // grab closest of near objectives

            private _objective = if (count _nearObjectives == 1) then {
                _nearObjectives select 0;
            } else {
                ([_nearObjectives,[_civPos],{_Input0 distance2D ([_x, "center"] call ALiVE_fnc_hashGet)},"ASCEND"] call ALiVE_fnc_sortBy) select 0;
            };

			private _objectiveInstallations = [_logic,"getObjectiveInstallations", _objective] call MAINCLASS; // [_HQ,_depot,_factory,_roadblocks,_ambush,_sabotage,_ied,_suicide]

			for "_i" from 0 to 3 do {
				private _installation = _objectiveInstallations select _i;

				if (_installation isEqualType objnull) then {
					(_installations select _i) pushback _installation;
				};
			};

			for "_i" from 4 to 7 do {
				private _installation = _objectiveInstallations select _i;

				if (_installation isEqualType objnull) then {
					(_actions select (_i - 4)) pushback _installation;
				};
			};

        };

        private _installationsByType = [_installations,_actions];

        // get civ and town data

        private _civID = _civ getVariable ["agentID", ""];

        private _civInfo = [];

        if (_civID != "") then {

			// get civ cluster

			private _civProfile = [MOD(agentHandler), "getAgent", _civID] call ALIVE_fnc_agentHandler;
			private _clusterID = (_civProfile select 2) select 9;
			private _cluster = [MOD(clusterHandler), "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;

			private _homePos = (_civProfile select 2) select 10;
			private _hostilityIndividual = (_civProfile select 2) select 12;
			private _hostilityTown = [_cluster, "posture"] call ALiVE_fnc_hashGet;	//_townHostility = (_cluster select 2) select 9; (Different)

			_civInfo = [_homePos,_hostilityIndividual,_hostilityTown];

        };

		// get nearby hostile civilian

		private _hostileCivInfo = [];
		private _insurgentCommands = ["alive_fnc_cc_suicide","alive_fnc_cc_suicidetarget","alive_fnc_cc_rogue","alive_fnc_cc_roguetarget","alive_fnc_cc_sabotage","alive_fnc_cc_getweapons"];
		private _agentsByCluster = [MOD(agentHandler), "agentsByCluster"] call ALiVE_fnc_hashGet;
		private _nearCivs = [_agentsByCluster, _clusterID] call ALiVE_fnc_hashGet;

		{
			_agentID = _x;

			//o nly check active, human agent profiles

			if ([_agentID,"active"] call ALiVE_fnc_hashGet) then {

				if ([_agentID, "type"] call ALiVE_fnc_hashGet == "agent") then {

					private _activeCommands = [_agentID,"activeCommands",[]] call ALiVE_fnc_hashGet;

					// check if any of the agent's current commands are insurgent commands

					if ({(tolower (_x select 0)) in _insurgentCommands} count _activeCommands > 0) then {
						private _unit = [_agentID,"unit"] call ALiVE_fnc_hashGet;

						// don't give yourself up!

						if (name _civ != name _unit) then {
							private _homePos = (_agentID select 2) select 10;

							_hostileCivInfo pushback [_unit,_homePos,_activeCommands];
						};
					};

				};

			};
		} foreach (_nearCivs select 2);

		// if multiple hostile civilians nearby, pick one at random

		if (count _hostileCivInfo > 0) then {_hostileCivInfo = selectrandom _hostileCivInfo};

		// send data to client

		["onCivilianDataReceived", [_installations, _civInfo,_hostileCivInfo]] remoteExecCall [QUOTE(ALiVE_fnc_civInteractionOnAction),_player];

    };

    default {

        _result = _this call SUPERCLASS;

    };

};

TRACE_1("Civ Interaction - output", _result);

if (!isnil "_result") then {_result} else {nil};