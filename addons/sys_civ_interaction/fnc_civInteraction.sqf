//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_civ_interaction\script_component.hpp>
SCRIPT(civInteraction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteraction
Description:
Main handler for civilian interaction

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:
[_logic, "debug", true] call ALiVE_fnc_civInteraction;

See Also:
- <ALiVE_fnc_civInteractionInit>
- <ALiVE_fnc_civInteractionHandler>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClass
#define MAINCLASS   ALiVE_fnc_civInteraction

// UI components

#include <\x\alive\addons\sys_civ_interaction\data\ui\include.hpp>

// control Macros

#define CI_getControl(disp,ctrl)    ((findDisplay disp) displayCtrl ctrl)
#define CI_getSelData(ctrl)         (lbData [ctrl,(lbCurSel ctrl)])
#define CI_ctrlGetSelData(ctrl)     (ctrl lbData (lbCurSel ctrl))

// general macros

#define COLOR_SIDE_EAST [profilenamespace getvariable ["Map_OPFOR_R",0],profilenamespace getvariable ["Map_OPFOR_G",1],profilenamespace getvariable ["Map_OPFOR_B",1],profilenamespace getvariable ["Map_OPFOR_A",0.8]]
#define COLOR_SIDE_WEST [profilenamespace getvariable ["Map_BLUFOR_R",0],profilenamespace getvariable ["Map_BLUFOR_G",1],profilenamespace getvariable ["Map_BLUFOR_B",1],profilenamespace getvariable ["Map_BLUFOR_A",0.8]]
#define COLOR_SIDE_GUER [profilenamespace getvariable ["Map_Independent_R",0],profilenamespace getvariable ["Map_Independent_G",1],profilenamespace getvariable ["Map_Independent_B",1],profilenamespace getvariable ["Map_Independent_A",0.8]]


TRACE_1("Civ Interaction - input", _this);

disableSerialization;
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

            _logic setVariable ["initGlobal", false];

            _logic setVariable ["super", QUOTE(SUPERCLASS)];
            _logic setVariable ["class", QUOTE(MAINCLASS)];
            _logic setVariable ["moduleType", QUOTE(ADDON)];
            _logic setVariable ["startupComplete", false];

            private _questionsConfig = [_logic,"loadQuestionsFromConfig", configFile >> "ALiVE_civilian_interaction" >> "questions"] call MAINCLASS;
            private _questionsMission = [_logic,"loadQuestionsFromConfig", missionConfigFile >> "ALiVE_civilian_interaction" >> "questions"] call MAINCLASS;

            // iterate through mission questions second to allow overriding of config

            private _allQuestions = _questionsConfig + _questionsMission;
            private _questions = [] call ALiVE_fnc_hashCreate;

            {
                private _questionClassname = [_x,"classname"] call ALiVE_fnc_hashGet;

                [_questions, _questionClassname, _x] call ALiVE_fnc_hashSet;
            } foreach _allQuestions;

            private _currentInteractionData = [
                [
                    ["civObject", objNull]
                ]
            ] call ALiVE_fnc_hashCreate;

            private _handler = [
                [
                    ["asymmetricFactions", []],
                    ["conventionalFactions", []],
                    ["questionss", _questions],
                    ["progessBar", controlNull]
                ]
            ] call ALiVE_fnc_hashCreate;

            [_logic,"debug", false] call MAINCLASS;
            [_logic,"handler", _handler] call MAINCLASS;

            ADDON = _logic;

            [_logic,"start"] spawn MAINCLASS;

        };

    };

    case "start": {

        // wait until serverside interaction handler has initialized

        waitUntil {
            !isnil QMOD(civInteractionHandler) && {[MOD(civInteractionHandler),"startupComplete"] call ALiVE_fnc_hashGet};
        };

        // wait for all OPCOM modules to initialize so we can grab factions

        waitUntil {
            ["ALiVE_mil_OPCOM"] call ALiVE_fnc_isModuleInitialised;
        };

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _asymFac = [_handler,"asymmetricFactions"] call ALiVE_fnc_hashGet;
        private _convenFac = [_handler,"conventionalFactions"] call AliVE_fnc_hashGet;

        {
            private _factions = [_x,"factions"] call ALiVE_fnc_hashGet;

            if (([_x,"controlType"] call ALiVE_fnc_hashGet) == "asymmetric") then {
                {_asymFac pushbackunique _x} foreach _factions;
            } else {
                {_convenFac pushbackunique _x} foreach _factions;
            };
        } foreach OPCOM_instances;

        // set module as startup complete

        _logic setVariable ["startupComplete", true];

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
            _result = _logic getVariable [_operation, []];
        };

    };

    case "onAction": {

        _args params ["_operation","_args"];

        /*
        switch (_operation) do {

            default {[_logic,_operation,_args] call MAINCLASS};

        };
        */

        [_logic,_operation,_args] call MAINCLASS;

    };

    case "loadQuestionsFromConfig": {

        private _configRoot = _args;

        _result = [];

        for "_i" from 0 to (count _configRoot - 1) do {

            private _configEntry = _configRoot select _i;

            if (isclass _configEntry) then {

                private _question = [_logic,"createQuestion", _configEntry] call MAINCLASS;

                _result pushback _question;

            };

        };

    };

    case "createQuestion": {

        private _questionArgs = _args;

        private ["_classname","_function","_questionTexts","_isDefault","_followupQuestions","_threatLevel"];

        switch (typename _questionArgs) do {

            case "CONFIG": {

                _classname = configname _configEntry;
                _function = gettext (_configEntry >> "function");
                _questionTexts = getarray (_configEntry >> "questionTexts");
                _isDefault = getnumber (_configEntry >> "isDefault");
                _followupQuestions = getarray (_configEntry >> "followupQuestions");
                _threatLevel = getnumber (_configEntry >> "threatLevel");

            };

            case "ARRAY": {

                _classname = _questionArgs select 0;
                _function = _questionArgs select 1;
                _questionTexts = _questionArgs select 2;
                _isDefault = _questionArgs select 3;
                _followupQuestions = _questionArgs select 4;
                _threatLevel = _questionArgs select 5;

            };

        };

        _isDefault = [_isDefault] call ALiVE_fnc_toBool;

        if (_threatLevel < 0) then {
            _threatLevel = 0;
        } else {
            if (_threatLevel > 3) then {
                _threatLevel = 3;
            };
        };

        _result = [
            [
                ["classname", _classname],
                ["function", _function],
                ["questionTexts", _questionTexts],
                ["isDefault", _isDefault],
                ["followupQuestions", _followupQuestions],
                ["threatLevel", _threatLevel]
            ]
        ] call ALiVE_fnc_hashCreate;

    };

    case "addQuestions": {

        private _questions = _args;

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _questions = [_handler,"questions"] call ALiVE_fnc_hashGet;

        {
            private _questionClassname = [_x,"classname"] call ALiVE_fnc_hashGet;

            [_questions,_questionClassname, _x] call ALiVE_fnc_hashSet;
        } foreach _questions;

    };

    case "openInterface": {

        private _civ = _args;

		// civ attacks if armed

		if !((weapons _civ) isEqualTo []) exitWith {
            // maybe exit only if they have a gun / ignore explosives?
        };

        createDialog "ALiVE_civ_interaction_menu";

        [_logic,"onLoad", _civ] call MAINCLASS;

    };

    case "onLoad": {

        private _civ = _args;

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

        [_currentInteractionData,"civObject", _civ] call ALiVE_fnc_hashSet;

		// stop civ from running

        [_civ,"MOVE"] remoteExecCall ["disableAI", _civ];
		//[_civ, {_this disableAI "MOVE"}] remoteExecCall ["BIS_fnc_spawn",_civ];

        // close menu on civilian death

        _civ addEventHandler ["Killed", format ["['onCivilianKilled'] remoteExecCall [%1,%2]"], QUOTE(ALiVE_fnc_civInteractionOnAction), clientOwner];

		if (_civ getVariable "detained") then {
            private _detainButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_DETAIN_BUTTON );
			_detainButton ctrlSetText "Release";
		};

        // start gathering civ data on server

        [nil,"", _civ] remoteExecCall [QUOTE(civInteractionHandler),2];

        // load default questions to list

        private _listLeft = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_LEFT );

        private _questions = [_currentInteractionData,"questions"] call ALiVE_fnc_hashGet;

        {
            if ([_x,"isDefault"] call ALiVE_fnc_hashGet) then {
                private _questionClassname = [_x,"classname"] call ALiVE_fnc_hashGet;
                private _questionTexts = [_x,"questionTexts"] call ALiVE_fnc_hashGet;
                private _quetionText = selectrandom _questionTexts;

                private _index = _listLeft lbAdd _questionText;
                _listLeft lbSetData [_questionText, _questionClassname];
            };
        } foreach _questions;

        private _askQuestionButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_DETAIN_BUTTON );
        _askQuestionButton ctrlSetEventHandler ["MouseButtonDown","['onAskQuestionClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _detainButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_DETAIN_BUTTON );
        _detainButton ctrlSetEventHandler ["MouseButtonDown","['onDetainClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _getDownButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_GETDOWN_BUTTON );
        _getDownButton ctrlSetEventHandler ["MouseButtonDown","['onGetDownClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _goAwayButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_GOAWAY_BUTTON );
        _goAwayButton ctrlSetEventHandler ["MouseButtonDown","['onGoAwayClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _searchButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_SEARCh_BUTTON );
        _searchButton ctrlSetEventHandler ["MouseButtonDown","['onSearchClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _closeButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_CLOSE_BUTTON );
        _closeButton ctrlSetEventHandler ["MouseButtonDown","['onCloseClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

		// create progress bar
        // doesn't like working when created via config

		private _bar = CIV_INTERACTION_DISPLAY ctrlCreate ["RscProgress", -1];
		_bar ctrlSetPosition [-0.0275, 0.86, 0.85, 0.04]; // should be set relative to background location
		_bar ctrlSetTextColor [0.788,0.443,0.157,1];
		_bar progressSetPosition 0;
		_bar ctrlCommit 0;

		[_handler,"progressBar", _bar] call ALiVE_fnc_hashSet;

    };

    case "onUnload": {

        private _handler = [_logic,"handler"] call ALiVE_fnc_hashGet;

    };

    case "onCivilianKilled": {

        [_logic,"onCloseClicked"] call MAINCLASS;

    };

    case "onAskQuestionClicked": {



    };

    case "onDetainClicked": {

		// exactly the same as amb_civ_pop arrest action

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

		private _civ = [_currentInteractionData, "civObject"] call ALiVE_fnc_hashGet;

		[_logic,"onCloseClicked"] call MAINCLASS;

		if (!isnil "_civ") then {
			if !(_civ getvariable ["detained", false]) then {
				// join player group

				[_civ] joinSilent (group player);
				_civ setvariable ["detained", true, true];
			} else {
				// join newly created civilian group

				[_civ] joinSilent (createGroup civilian);
				_civ setvariable ["detained", false, true];
			};
		};

    };

    case "onGetDownClicked": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

		private _civ = [_currentInteractionData, "civObject"] call ALiVE_fnc_hashGet;

		[_logic,"onCloseClicked"] call MAINCLASS;

		if (!isnil "_civ") then {

			[_civ] spawn {
				params ["_civ"];

				sleep 1;

				_civ disableAI "MOVE";
				_civ setUnitPos "DOWN";

				sleep (10 + (ceil random 20));

				_civ enableAI "MOVE";
				_civ setUnitPos "AUTO";
			};

		};

    };

    case "onGoAwayClicked": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

		private _civ = [_currentInteractionData, "civObject"] call ALiVE_fnc_hashGet;

		[_logic,"onCloseClicked"] call MAINCLASS;

		if (!isnil "_civ") then {

			[_civ] spawn {
				params ["_civ"];

				sleep 1;

				_civ setUnitPos "AUTO";
				private _fleePos = [getPos _civ, 30, 50, 1, 0, 1, 0] call BIS_fnc_findSafePos;
				_civ doMove _fleePos;
			};

		};

    };

    case "onSearchClicked": {



    };

    case "onCloseClicked": {

        closeDialog 0;

    };

    default {

        _result = _this call SUPERCLASS;

    };

};

TRACE_1("Civ Interaction - output", _result);

if (!isnil "_result") then {_result} else {nil};