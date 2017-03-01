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

            private _nearInstallations = [
                [
                    ["HQ", []],
                    ["WeaponsDepot", []],
                    ["IEDFactory", []],
                    ["Roadblock", []],
                    ["Ambush", []],
                    ["Sabotage", []],
                    ["IED", []],
                    ["Suicide", []]
                ]
            ] call ALiVE_fnc_hashCreate;

            private _nearHostileCiv = [
                [
                    ["unitObject", objNull],
                    ["homePosition", [0,0,0]],
                    ["activeCommands", []]
                ]
            ] call ALiVE_fnc_hashCreate;

            private _currentInteractionData = [
                [
                    ["civObject", objNull],
                    ["civKilledEHID", -1],
                    ["isSearching", false],
                    ["homePosition", [0,0,0]],
                    ["civHostility", 0],
                    ["civTownHostility", 0],
                    ["nearInstallations", _nearInstallations],
                    ["nearHostileCiv", _nearHostileCiv]
                ]
            ] call ALiVE_fnc_hashCreate;

            private _handler = [
                [
                    ["currentInteractionData", _currentInteractionData],
                    ["asymmetricFactions", []],
                    ["conventionalFactions", []],
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
            !isnil QMOD(civInteractionHandler) && {MOD(civInteractionHandler) getvariable ["startupComplete", false]};
        };

        // wait for all OPCOM modules to initialize so we can grab factions

        waitUntil {
            ["ALiVE_mil_OPCOM"] call ALiVE_fnc_isModuleInitialised;
        };

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _asymFac = [_handler,"asymmetricFactions"] call ALiVE_fnc_hashGet;
        private _convenFac = [_handler,"conventionalFactions"] call ALiVE_fnc_hashGet;

        {
            private _factions = [_x,"factions"] call ALiVE_fnc_hashGet;

            if (([_x,"controltype"] call ALiVE_fnc_hashGet) == "asymmetric") then {
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

        // close menu on civilian death

        private _killedEHID = _civ addEventHandler ["Killed", format ["['onCivilianKilled', _this] remoteExecCall ['ALiVE_fnc_civInteractionOnAction',%1]", clientOwner]];

        [_currentInteractionData,"civKilledEHID", _killedEHID] call ALiVE_fnc_hashSet;

		if (_civ getVariable "detained") then {
            private _detainButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_DETAIN_BUTTON );
			_detainButton ctrlSetText "Release";
		};

        // show civilian name and role if they have one

        private _civRole = [_logic,"getCivRole", _civ] call MAINCLASS;
        private _nameText = name _civ;

        if (_civRole != "") then {
            _nameText = format ["%1 (%2)", _nameText, _civRole];
        };

        private _civNameText = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_CIV_NAME );
        _civNameText ctrlsettext _nameText;

        // load default questions to list

        private _listLeft = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_LEFT );
        _listLeft ctrlSetEventHandler ["LBSelChanged", "['onQuestionSelected', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _listRight = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_RIGHT );
        _listRight ctrlShow false;

        private _askQuestionButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_ASKQUESTION_BUTTON );
        _askQuestionButton ctrlShow false;
        _askQuestionButton ctrlSetEventHandler ["MouseButtonDown","['onAskQuestionClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _detainButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_DETAIN_BUTTON );
        _detainButton ctrlSetEventHandler ["MouseButtonDown","['onDetainClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _getDownButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_GETDOWN_BUTTON );
        _getDownButton ctrlSetEventHandler ["MouseButtonDown","['onGetDownClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _goAwayButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_GOAWAY_BUTTON );
        _goAwayButton ctrlSetEventHandler ["MouseButtonDown","['onGoAwayClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _searchButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_SEARCH_BUTTON );
        _searchButton ctrlSetEventHandler ["MouseButtonDown","['onSearchClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _closeButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_CLOSE_BUTTON );
        _closeButton ctrlSetEventHandler ["MouseButtonDown","['onCloseClicked', _this] call ALiVE_fnc_civInteractionOnAction"];

        private _responseText = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_RESPONSE_TEXT );
        _responseText ctrlSetText "Loading . . .";

        // start gathering civ data on server

        ["getCivilianData", [_civ,player]] remoteExecCall [QUOTE(ALiVE_fnc_civInteractionHandlerOnAction),2];

		// create progress bar
        // doesn't like working when created via config

		private _bar = (findDisplay CIV_INTERACTION_DISPLAY) ctrlCreate ["RscProgress", -1];
		_bar ctrlSetPosition [
            0.224375 * safezoneW + safezoneX,
            0.738 * safezoneH + safezoneY,
            0.439687 * safezoneW,
            0.037 * safezoneH
        ];
		_bar ctrlSetTextColor [0.788,0.443,0.157,1];
		_bar progressSetPosition 0;
		_bar ctrlCommit 0;

		[_handler,"progressBar", _bar] call ALiVE_fnc_hashSet;

    };

    case "onUnload": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

        private _civ = [_currentInteractionData,"civObject"] call ALiVE_fnc_hashGet;
        private _isSearching = [_currentInteractionData,"isSearching"] call ALiVE_fnc_hashGet;

        if (!_isSearching) then {
            [_civ,"MOVE"] remoteExecCall ["enableAI", _civ];
        };

        // remove menu-closing EH

        private _ehID = [_currentInteractionData,"civKilledEHID"] call ALiVE_fnc_hashGet;

        _civ removeEventHandler ["Killed", _ehID];

        [_currentInteractionData,"civKilledEHID", -1] call ALiVE_fnc_hashSet;

    };

    case "onCivilianDataReceived": {

        private _civData = _args;

        _civData params ["_installations","_civData","_hostileCivData"];

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

        // set installation data

        private _nearInstallations = [_currentInteractionData,"nearInstallations"] call ALiVE_fnc_hashGet;

        _installations params ["_hq","_weaponsDepot","_iedFactory","_roadblock","_ambush","_sabotage","_ied","_suicide"];

        [_nearInstallations,"HQ", _hq] call ALiVE_fnc_hashSet;
        [_nearInstallations,"WeaponsDepot", _weaponsDepot] call ALiVE_fnc_hashSet;
        [_nearInstallations,"IEDFactory", _iedFactory] call ALiVE_fnc_hashSet;
        [_nearInstallations,"Roadblock", _roadblock] call ALiVE_fnc_hashSet;
        [_nearInstallations,"Ambush", _ambush] call ALiVE_fnc_hashSet;
        [_nearInstallations,"Sabotage", _sabotage] call ALiVE_fnc_hashSet;
        [_nearInstallations,"IED", _ied] call ALiVE_fnc_hashSet;
        [_nearInstallations,"Suicide", _suicide] call ALiVE_fnc_hashSet;

        // set civ data

        _civData params ["_homePosition","_hostility","_townHostility"];

        [_currentInteractionData,"homePosition", _homePosition] call ALiVE_fnc_hashSet;
        [_currentInteractionData,"civHostility", _hostility] call ALiVE_fnc_hashSet;
        [_currentInteractionData,"civTownHostility", _townHostility] call ALiVE_fnc_hashSet;

        // set hostile civ data

        _hostileCivData params ["_unit","_homePosition","_activeCommands"];

        private _hostileCivData = [_currentInteractionData,"nearHostileCiv"] call ALiVE_fnc_hashGet;

        [_hostileCivData,"unitObject", _unit] call ALiVE_fnc_hashSet;
        [_hostileCivData,"homePosition", _homePosition] call ALiVE_fnc_hashSet;
        [_hostileCivData,"activeCommands", _activeCommands] call ALiVE_fnc_hashSet;

        // populate list with questions now that data is received

        [_logic,"loadDefaultQuestionsToList"] call MAINCLASS;

        // remove loading text

        private _responseText = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_RESPONSE_TEXT );
        _responseText ctrlsettext "";

    };

    case "loadDefaultQuestionsToList": {

        // load variables so they are able to be
        // used by the called condition below

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _conventionalFactions = [_handler,"conventionalFactions"] call ALiVE_fnc_hashGet;
        private _asymmetricFactions = [_handler,"asymmetricFactions"] call ALiVE_fnc_hashGet;

        private _currentInteraction = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;
        private _nearInstallations = [_currentInteraction,"nearInstallations"] call ALiVE_fnc_hashGet;
        private _civHostility = [_currentInteraction,"civHostility"] call ALiVE_fnc_hashGet;
        private _townHostility = [_currentInteraction,"civTownHostility"] call ALiVE_fnc_hashGet;
        private _nearHostileCiv = [_currentInteraction,"nearHostileCiv"] call ALiVE_fnc_hashGet;

        private _civ = [_currentInteraction,"civObject"] call ALiVE_fnc_hashGet;

        private _listLeft = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_LEFT );
        private _listRight = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_RIGHT );

        lbclear _listRight;
        _listRight ctrlShow false;

        {
            for "_i" from 0 to (count _x  - 1) do {
                private _entry = _x select _i;

                if (isclass _entry) then {
                    if (getnumber (_entry >> "isDefault") >= 1) then {
                        private _condition = gettext (_entry >> "condition");

                        if (_condition == "" || {call compile _condition}) then {

                            private _text = selectrandom (getarray (_entry >> "texts"));
                            private _configPath = [_entry] call BIS_fnc_configPath;

                            private _index = _listLeft lbAdd _text;
                            _listLeft lbSetData [_index, str _configPath];

                        };

                    };
                };
            };
        } foreach [
            configFile >> "ALiVE_civilian_interaction" >> "Questions",
            missionConfigFile >> "ALiVE_civilian_interaction" >> "Questions"
        ];

    };

    case "loadQuestionsToList": {

        private _questionClassnames = _args;

        private _listLeft = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_LEFT );
        private _listRight = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_RIGHT );

        lbclear _listRight;
        _listRight ctrlShow false;

        // add questions to list in same order
        // as the classname list

        private _configRoot = configFile >> "ALiVE_civilian_interaction" >> "Questions";
        private _missionRoot = missionConfigFile >> "ALiVE_civilian_interaction" >> "Questions";

        {
            private _path =_configRoot >> _x;

            if (!isclass _path) then {_path = _missionRoot >> _x};

            if (isclass _path) then {

                private _text = selectrandom (getarray (_path >> "texts"));
                private _x = str _path;

                private _index = _listLeft lbAdd _text;
                _listLeft lbSetData [_index, _x];

            };
        } foreach _questionClassnames;

    };

    case "onCivilianKilled": {

        [_logic,"onCloseClicked"] call MAINCLASS;

    };

    case "onQuestionSelected": {

        _args params ["_listLeft","_selIndex"];

        if (_selIndex >= 0) then {

            private _selQuestion = _listLeft lbData _selIndex;
            private _selQuestionConfig = [_selQuestion, confignull] call BIS_fnc_configPath;

            // this code should return an array of arrays
            // each child array contains [text,data,tooltip]
            // right list is populated with this data

            private _retrieveArgsCode = gettext (_selQuestionConfig >> "fillArgumentsCode");

            private _enableAskQuestion = true;

            if (_retrieveArgsCode != "") then {
                // init variables for use in called code

                private _handler = [_logic,"handler"] call MAINCLASS;
                private _currentInteraction = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;
                private _civ = [_currentInteraction,"civObject"] call ALiVE_fnc_hashGet;

                private _listRight = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_RIGHT );

                private _questionArgs = call _onSelectedCode;

                if (_questionArgs isEqualType [] && {count _questionArgs > 0}) then {
                    _enableAskQuestion = false;

                    {
                        _x params [
                            ["_text","", [""]],
                            ["_data", ""],
                            ["_tooltip", "", [""]]
                        ];

                        private _index = _listRight lbAdd _text;
                        _listRight lbSetData [_index,_data];
                        _listRight lbSetTooltip [_index,_tooltip];
                    } foreach _questionArgs;
                };
            };

            if (_enableAskQuestion) then {
                private _askQuestionButton = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_ASKQUESTION_BUTTON );
                _askQuestionButton ctrlShow true;
            };

        };

    };

    case "onAskQuestionClicked": {

        private _listLeft = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_LEFT );
        private _listRight = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_LIST_RIGHT );

        // estimate time required to ask question

        private _textToSpeak = ctrlText _listLeft;

        if (ctrlVisible CIV_INTERACTION_LIST_RIGHT) then {
            _textToSpeak = _textToSpeak + " " + ctrlText _listRight;
        };

        private _fillTime = 0.5 + (([_textToSpeak] call ALiVE_fnc_timeToRead) * 2);

        // get function to execute

        private _selQuestion = CI_ctrlGetSelData( _listLeft );
        private _selQuestionConfig = [_selQuestion, confignull] call BIS_fnc_configPath;

        private _arguments = "";
        if (ctrlVisible CIV_INTERACTION_LIST_RIGHT) then {
            _arguments = CI_ctrlGetSelData( _listRight );
        };

        private _functionData = [QUOTE(MAINCLASS),[_logic,"onQuestionAsked", [_selQuestionConfig,_arguments]]];

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _bar = [_handler,"progressBar"] call ALiVE_fnc_hashGet;

        [_logic,"progressFillOverTime", [_bar,_fillTime,true,_functionData]] spawn MAINCLASS;

        private _responseText = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_RESPONSE_TEXT );
        _responseText ctrlsettext "";

    };

    case "onQuestionAsked": {

        _args params ["_questionConfig","_questionArgs"];

        systemchat str _args;

        private _handler = [_logic,"handler"] call MAINCLASS;

        // init variables for use in called code

        private _question = configname _questionConfig;

        private _conventionalFactions = [_handler,"conventionalFactions"] call ALiVE_fnc_hashGet;
        private _asymmetricFactions = [_handler,"asymmetricFactions"] call ALiVE_fnc_hashGet;

        private _currentInteraction = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;
        private _civ = [_currentInteraction,"civObject"] call ALiVE_fnc_hashGet;
        private _civHostility = [_currentInteraction,"civHostility"] call ALiVE_fnc_hashGet;
        private _townHostility = [_currentInteraction,"civTownHostility"] call ALiVE_fnc_hashGet;
        private _nearHostileCiv = [_currentInteraction,"nearHostileCiv"] call ALiVE_fnc_hashGet;

        private _questionResponses = [];
        private _questionResponsePath = _questionConfig >> "Responses";

        // use while loop over recursion
        // to avoid redefining above variables

        private _hasResponses = true;

        while {_hasResponses} do {

            _hasResponses = false;

            for "_i" from 0 to (count _questionResponsePath) do {
                private _entry = _questionResponsePath select _i;

                if (isclass _entry) then {
                    private _condition = gettext (_entry >> "condition");

                    // responses are evalutated in the order
                    // they were defined in config

                    if ([_arguments] call _condition) then {

                        for "_j" from 0 to (count _entry - 1) do {
                            _subResponsePath = _entry select _j;

                            if (isclass _j) exitwith {
                                _hasResponses = true;
                            };
                        };

                        if (_hasResponses) then {
                            _questionResponsePath = _entry;
                        } else {
                            // we've reached our base case
                            // no further branching response paths
                            // select a defined response at random

                            private _responseToDisplay = selectrandom (getarray (_entry >> "texts"));
                            private _onDisplayed = gettext (_entry >> "onDisplayed");
                            private _followUpQuestions = getarray (_entry >> "followupQuestions");

                            private _responseText = CI_getControl( CIV_INTERACTION_DISPLAY , CIV_INTERACTION_RESPONSE_TEXT );
                            _responseText ctrlsettext _responseToDisplay;

                            [_arguments] call _onDisplayed;

                            if (count _followUpQuestions > 0) then {
                                [_logic,"loadQuestionsToList", _followUpQuestions] call MAINCLASS;
                            };
                        };

                    }; // possibly add support for "Else" subresponse path (useful if random conditions are used because it wont be the same value for two branching paths)
                };
            };

        };

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

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

        private _civ = [_currentInteractionData,"civObject"] call ALiVE_fnc_hashGet;

        [_currentInteractionData,"isSearching", true] call ALiVE_fnc_hashGet;

        player action ["Gear", _civ];

        player addEventHandler ["InventoryClosed", {
            private _civ = _this select 1;

            [_civ,"MOVE"] remoteExecCall ["enableAI", _civ];

            private _handler = [ADDON,"handler"] call ALiVE_fnc_civInteraction;
            private _currentInteractionData = [_handler,"currentInteractionData"] call ALiVE_fnc_hashGet;

            [_currentInteractionData,"isSearching", false] call ALiVE_fnc_hashSet;
        }];

    };

    case "onCloseClicked": {

        closeDialog 0;

    };

    // TODO: XLib
    case "progressFillOverTime": {

        _args params [
            ["_bar", controlNull, [controlNull]],
            ["_time", 1, [1]],
            ["_reset", true, [true]],
            ["_functionData", [], [[]]]
        ];

        private _startTime = time;

        while {!isnull _bar && {progressPosition _bar < 1}} do {
            _bar progressSetPosition ((time - _startTime) / _time);
        };

        if !(isnull _bar) then {
            if (_reset) then {
                _bar progressSetPosition 0;
            };

            _functionData params [
                ["_function", {}, [{},""]],
                ["_args", []]
            ];

            if (_function isEqualType "") then {_function = call compile _function};

            [_function, _args] call CBA_fnc_directCall
        };

    };

    case "getCivRole": {

        private _civ = _args;

        private _role = "";
        {
            if (_civ getvariable [_x,false]) exitwith {
                _role = _x;
            };
        } foreach ["townelder","major","priest","muezzin","politician"];

        _role = [_role] call CBA_fnc_capitalize;

        _result = _role;

    };

    default {

        _result = _this call SUPERCLASS;

    };

};

TRACE_1("Civ Interaction - output", _result);

if (!isnil "_result") then {_result} else {nil};