//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(orbatCreator);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreator
Description:
Main handler for the orbat creator

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance

Examples:
[_logic, "debug", true] call ALiVE_fnc_orbatCreator;

See Also:
- <ALiVE_fnc_orbatCreatorInit>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClass
#define MAINCLASS   ALiVE_fnc_orbatCreator

#define PLAYABLE_SIDE_NUMS	[0,1,2,3]


private "_result";
params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull]
];

switch (_operation) do {

    default {
        _result = _this call SUPERCLASS;
    };

    case "init": {

        if (isDedicated) exitWith {};

        // only one init per instance is allowed

        if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS Orbat Creator - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

        _logic setVariable ["initGlobal", false];

        _logic setVariable ["super", QUOTE(SUPERCLASS)];
        _logic setVariable ["class", QUOTE(MAINCLASS)];
        _logic setVariable ["moduleType", QUOTE(ADDON)];
        _logic setVariable ["startupComplete", false];

        // get module settings

        private _debug = ((_logic getVariable ["debug","false"]) == "true");
        private _background = ((_logic getVariable ["background", "true"]) == "true");
        private _prefix = (_logic getVariable ["prefix", ""]);

		private _orbatCreatorGUI = [nil,"create"] call ALiVE_fnc_orbatCreatorGUI;
		[_orbatCreatorGUI,"init"] call ALiVE_fnc_orbatCreatorGUI;
		[_orbatCreatorGUI,"background", _background] call ALiVE_fnc_orbatCreatorGUI;

		private _factionEditorController = [nil,"create"] call ALiVE_fnc_factionEditor;
		[_factionEditorController,"init"] call ALiVE_fnc_factionEditor;
		[_factionEditorController,"prefix", _prefix] call ALiVE_fnc_factionEditor;

		[_logic,"debug", _debug] call MAINCLASS;
		[_logic,"background", _background] call MAINCLASS;
		[_logic,"orbatCreatorGUI", _orbatCreatorGUI] call MAINCLASS;
		[_logic,"factionEditorController", _factionEditorController] call MAINCLASS;

        private _state = [] call ALiVE_fnc_hashCreate;
        [_logic,"state", _state] call MAINCLASS;

		private _factions = [] call ALiVE_fnc_hashCreate;
		[_state,"factions", _factions] call ALiVE_fnc_hashSet;

        private _customUnits = [] call ALiVE_fnc_hashCreate;
        [_state,"customUnits", _customUnits] call ALiVE_fnc_hashSet;

        // load static data
        call ALiVE_fnc_staticDataHandler;

		[_logic,"loadFactionsFromConfig"] call MAINCLASS;

		MOD(orbatCreator) = _logic;

		[_state,"activeInteface", ""] call ALiVE_fnc_hashSet;

		[_logic] spawn {
			params ["_logic"];

			waitUntil {time > 0 && {!isnull player} && {!isnil "ALiVE_STATIC_DATA_LOADED"}};

			[{ [_logic,"start"] call MAINCLASS }] call CBA_fnc_directCall;
		};

	};

    case "start": {

		private _factionEditorController = [_logic,"factionEditorController"] call ALiVE_fnc_hashGet;
		[_factionEditorController,"openUI"] call ALiVE_fnc_factionEditor;

        ["Preload"] call BIS_fnc_arsenal;

        // initialise main menu

        [
            "player",
            [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
            -9500,
            [
                "call ALiVE_fnc_orbatCreatorMenuDef",
                ["main", "alive_flexiMenu_rscPopup"]
            ]
        ] call CBA_fnc_flexiMenu_Add;

        // set module as startup complete

        _logic setVariable ["startupComplete", true];

    };

    case "state": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, []];
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

    case "background": {

        if (_args isEqualType true) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, false];
        };

    };

    case "orbatCreatorGUI": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, []];
        };

    };

    case "factionEditorController": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, []];
        };

    };

    case "destroy": {

        if (isServer) then {

            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];

            [_logic,"destroy"] call SUPERCLASS;

        };

    };

	case "openUI": {



	};

	case "closeUI": {

        // [_logic,"enableUnitEditorBackground", false] call MAINCLASS;

	};

	case "loadFactionsFromConfig": {

		private _tmpHash = [] call ALiVE_fnc_hashCreate;

        private _east = +_tmpHash;
        private _west = +_tmpHash;
        private _indep = +_tmpHash;

		private _state = [_logic,"state"] call MAINCLASS;
		private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

		private _assetsByFaction = [_logic,"sortAssetsByFaction"] call MAINCLASS;

		private _allFactionClassnames = [] call ALiVE_fnc_configGetFactions;
        {
            private _factionClassname = _x;
            private _factionClassConfig = _factionClassname call ALiVE_fnc_configGetFactionClass;
            private _factionSideNum = getNumber (_factionClassConfig >> "side");

            if (_factionSideNum in PLAYABLE_SIDE_NUMS) then {
                private _factionConfigName = _factionClassname;
                private _factionDisplayName = getText (_factionClassConfig >> "displayName");
                private _factionFlag = getText (_factionClassConfig >> "flag");
                private _factionIcon = getText (_factionClassConfig >> "icon");
                private _factionPriority = getNumber (_factionClassConfig >> "priority");

                private _factionAssetData = [_assetsByFaction, _factionConfigName] call ALiVE_fnc_hashGet;

				_factionAssetData params ["_factionAssetCategories","_factionAssets"];

                // create SQF representation of faction

                private _newFaction = [nil,"create",
					[
						_factionConfigName,
						_factionDisplayName,
						_factionFlag,
						_factionIcon,
						_factionPriority,
						_factionSideNum,
						"", // camo
						"", // groupCategoriesRootName
						[], // groupsByCategory
						_factionAssetCategories,
						_factionAssets
					]
				] call ALiVE_fnc_orbatCreatorFaction;

                [_factions,_factionConfigName, _newFaction] call ALiVE_fnc_hashSet;
            };
        } foreach _allFactionClassnames;

		private _state = [_logic,"state"] call MAINCLASS;
		[_state,"factions", _factions] call ALiVE_fnc_hashSet;

	};

	case "sortAssetsByFaction": {

        _result = [] call ALiVE_fnc_hashCreate;

        private _allFactionClassnames = [] call ALiVE_fnc_configGetFactions;

        // build factions list

        {
            private _factionConfig = _x call ALiVE_fnc_configGetFactionClass;
            private _factionSideNum = getnumber (_factionConfig >> "side");

            if (_factionSideNum in PLAYABLE_SIDE_NUMS) then {
                private _factionConfigName = configname _factionConfig;

				private _factionAssetData = [[],[]]; // [asset categories, assets]
                [_result,_factionConfigName, _factionAssetData] call ALiVE_fnc_hashSet;
            };
        } foreach _allFactionClassnames;

        // sort unit classes by faction

        private _configPath = configFile >> "CfgVehicles";
        for "_i" from 0 to (count _configPath - 1) do {
            private _entry = _configPath select _i;

            if (isclass _entry) then {
                private _entryScope = getnumber (_entry >> "scope");

                if (_entryScope >= 2 && {!(configname _entry isKindOf "Static")}) then {
                    private _entrySideNum = getNumber (_entry >> "side");

                    if (_entrySideNum in PLAYABLE_SIDE_NUMS) then {
                        private _entryFactionClass = getText (_entry >> "faction");

                        private _factionData = [_result,_entryFactionClass] call ALiVE_fnc_hashGet;
                        if (!isnil "_factionData") then {
                            private _entryConfigName = configName _entry;
                            private _entryEditorSubcategory = getText (_entry >> "editorSubcategory");

                            (_factionData select 0) pushbackunique _entryEditorSubcategory;
                            (_factionData select 1) pushback _entryConfigName;
                        };
                    };
                };
            };

        };

	};

	case "getFactions": {

		private _state = [_logic,"state"] call MAINCLASS;
		private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

		_result = _factions;

	};

	case "getFaction": {

		private _faction = _args;

		private _factions = [_logic,"getFactions"] call MAINCLASS;
		private _faction = [_factions,_faction] call ALiVE_fnc_hashGet;

		_result = _faction;

	};

	case "addFaction": {

		_args params ["_displayName","_className","_shortName","_side","_flag",["_camo",""]];

        private _newFaction = [nil,"create", [_className,_displayName,_flag,_flag,0,_side]] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"init"] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"shortName", _shortName] call ALiVE_fnc_orbatCreatorFaction;
        if (_camo != "") then {
            [_newFaction,"camo", _camo] call ALiVE_fnc_orbatCreatorFaction;
        };

		private _factions = [_logic,"getFactions"] call MAINCLASS;

		if !(_className in (_factions select 1)) then {
			[_factions,_className, _newFaction] call ALiVE_fnc_hashSet;
		};

		_result = _newFaction;

	};

	case "updateFaction": {

		_args params ["_displayName","_className","_country","_side","_flag","_camo"];

		private _view = [_logic,"view"] call MAINCLASS;
		private _currFaction = [_view,"selectedFaction"] call ALiVE_fnc_hashGet;

		private _faction = [_logic,"getFaction", _currFaction] call ALiVE_fnc_hashGet;

		private _fieldsToCheck = ["displayName","className","shortName","side","flag","icon","camo"];
		private _newValues = _args;

		{
			private _valueToCheck = _x;
			private _newValue = _newValues select _foreachindex;
			private _oldValue = [_faction,_valueToCheck] call ALiVE_fnc_orbatCreatorFaction;

			if !(_newValue isequalto _oldValue) then {
				[_faction,_valueToCheck, _newValue] call ALiVE_fnc_orbatCreatorFaction;
			};
		} foreach _fieldsToCheck;

	};

	case "removeFaction": {

		private _factionClassname = _args;

		private _factions = [_logic,"getFactions"] call MAINCLASS;
		private _faction = [_factions,_factionClassname] call ALiVE_fnc_hashGet;

		if (!isnil "_faction") then {
			[_factions,_factionClassname, nil] call ALiVE_fnc_hashSet;

			// remove any custom units belonging to the faction

			private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
			{
				private _customUnit = _x;
				private _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

				if (_customUnitFaction == _factionClassname) then {
					private _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;

					[_customUnits,_customUnitConfigName, nil] call ALiVE_fnc_hashSet;
				};
			} foreach (_customUnits select 2);
		};

	};

	case "getAllFlags": {

		private _allFlags = [];
		private _markerPath = configFile >> "CfgMarkers";

		for "_i" from 0 to (count _markerPath - 1) do {
			private _marker = _markerPath select _i;

			if (isclass _marker) then {
				private _markerClass = getText (_marker >> "markerClass");

				if (_markerClass == "Flags") then {
					private _markerName = getText (_marker >> "name");
					private _markerIcon = getText (_marker >> "icon");

					_allFlags pushback [_markerName,_markerIcon];
				};
			};
		};

		private _factionPath = configFile >> "CfgFactionClasses";

		for "_i" from 0 to (count _factionPath - 1) do {
			private _factionConfig = _factionPath select _i;

			if (isclass _factionConfig) then {
				private _factionConfigSideNum = getNumber (_factionConfig >> "side");
				private _factionConfigFlag = getText (_factionConfig >> "flag");

				if (_factionConfigSideNum in PLAYABLE_SIDE_NUMS && {!(_factionConfigFlag in _allFlags)}) then {
					private _factionConfigDisplayName = getText (_factionConfig >> "displayName");
					private _factionConfigMarkerName = format ["Flag - %1", _factionConfigDisplayName];

					_allFlags pushback [_factionConfigMarkerName,_factionConfigFlag];
				};
			};
		};

		_result = _allFlags;

	};

};

TRACE_1("Orbat Creator - output", _result);

if (!isnil "_result") then {_result} else {nil};