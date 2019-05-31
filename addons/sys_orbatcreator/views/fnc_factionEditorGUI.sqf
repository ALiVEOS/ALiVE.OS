//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\include.hpp"
SCRIPT(factionEditorGUI);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_FactionEditorGUI
Description:

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:


See Also:

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_factionEditorGUI


private "_result";
params [
    ["_logic", objNull, [objNull, []]],
    ["_operation", "", [""]],
    ["_args", objNull]
];

disableSerialization;

switch (_operation) do {

    default {
        _result = _this call SUPERCLASS;
    };

	case "init": {

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet;
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;

	};

	case "openUI": {

		createDialog "ALiVE_orbatCreator_interface_factionEditor";

	};

	case "onLoad": {

		// delay onLoad function by one frame
		// so the display is actually loaded

		ALiVE_factionEditor_onLoadFrameHandler = [{
			private _args = _this select 0;
			_args set [1, "onLoad2"];

			_args call MAINCLASS;
		}, 0, _this] call CBA_fnc_addPerFrameHandler;

	};

	case "onLoad2": {

		[ALiVE_factionEditor_onLoadFrameHandler] call CBA_fnc_removePerFrameHandler;

		private _display = finddisplay OC_DISPLAY_FACTIONEDITOR;

		_display displayAddEventHandler ["unload", format ["[%1,'onUnload', 2] call ALiVE_fnc_FactionEditorGUI", _logic]];
		// init faction list

		private _factionButton1 = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_BUTTON_ONE );
		_factionButton1 ctrlSetEventHandler ["MouseButtonDown", format ["[%1,'onFactionCreateClicked'] call ALiVE_fnc_FactionEditorGUI", _logic]];
		_factionButton1 ctrlSetTooltip "Create a new faction.";
		_factionButton1 ctrlSetText "New";

		private _factionButton2 = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_BUTTON_TWO );
		_factionButton2 ctrlSetEventHandler ["MouseButtonDown", format ["[%1,'onFactionEditClicked'] call ALiVE_fnc_FactionEditorGUI", _logic]];
		_factionButton2 ctrlSetTooltip "Edit selected faction";
		_factionButton2 ctrlSetText "Edit";

		private _factionButton3 = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_BUTTON_THREE );
		//_factionButton3 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorCopyClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
		_factionButton3 ctrlSetTooltip "Copy Selected Faction";
		_factionButton3 ctrlSetText "Copy";

		private _factionButton4 = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_BUTTON_FOUR );
		_factionButton4 ctrlSetEventHandler ["MouseButtonDown", format ["[%1,'onFactionDeleteClicked'] call ALiVE_fnc_FactionEditorGUI", _logic]];
		_factionButton4 ctrlSetTooltip "Delete selected faction   Warning: Will delete the faction, its units, and its groups.";
		_factionButton4 ctrlSetText "Delete";

		private _factionList = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_LIST );
		_factionList ctrlSetEventHandler ["LBSelChanged", format ["[%1,'onFactionListSelectionChanged'] call ALiVE_fnc_FactionEditorGUI", _logic]];

		[_logic,"loadFactionList"] call MAINCLASS;

	};

	case "closeUI": {

		closeDialog 1;

	};

	case "onUnload": {



	};

	case "loadFactionList": {

		private _display = finddisplay OC_DISPLAY_FACTIONEDITOR;
		private _factionList = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_LIST );
		lbclear _factionList;

        private _factions = [MOD(orbatCreator),"getFactions"] call ALiVE_fnc_orbatCreator;

        {
            private _faction = _x;
            private _factionDisplayName = [_faction,"displayName"] call ALiVE_fnc_orbatCreatorFaction;
            private _factionConfigName = [_faction,"configName"] call ALiVE_fnc_orbatCreatorFaction;

            if !(_factionConfigName in FACTION_BLACKLIST) then {
                private _index = _factionList lbAdd (format ["%1 - %2", _factionDisplayName, _factionConfigName]);
                _factionList lbSetData [_index,_factionConfigName];
            };
        } foreach (_factions select 2);

		lbSort [_factionList, "ASC"];
		[_logic,"refreshFactionSelection"] call MAINCLASS;

	};

	case "refreshFactionSelection": {

		private _display = finddisplay OC_DISPLAY_FACTIONEDITOR;
		private _factionList = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_LIST );

		private _orbatCreatorGUI = [MOD(orbatCreator),"orbatCreatorGUI"] call ALiVE_fnc_orbatCreator;
		private _selectedFaction = [_orbatCreatorGUI,"selectedFaction"] call ALiVE_fnc_orbatCreatorGUI;
		if (_selectedFaction == "") then {
			_factionList lbSetCurSel 0;
		} else {
			[_factionList,_selectedFaction] call ALiVE_fnc_listSelectData;
		};

	};

	case "onFactionListSelectionChanged": {

        _args params ["_list","_index"];

		private _display = finddisplay OC_DISPLAY_FACTIONEDITOR;
		private _factionList = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_LIST );

        private _selectedFaction = OC_ctrlGetSelData(_factionList);

		private _orbatCreatorGUI = [MOD(orbatCreator),"orbatCreatorGUI"] call ALiVE_fnc_orbatCreator;
		[_orbatCreatorGUI,"selectedFaction", _selectedFaction] call ALiVE_fnc_orbatCreatorGUI;

        [_logic,"displayFactionInfo", _selectedFaction] call MAINCLASS;

	};

	case "displayFactionInfo": {

		private _faction = _args;

		private _display = finddisplay OC_DISPLAY_FACTIONEDITOR;

        private _inputFactionFlag = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_FLAG );
        _inputFactionFlag ctrlShow false;

        private _tree = OC_getControl( _display , OC_FACTIONEDITOR_TREE_GROUPS );
        tvClear _tree;

        private _faction = [MOD(orbatCreator),"getFaction", _faction] call ALiVE_fnc_orbatCreator;

        if (!isnil "_faction") then {
            private _factionFlag = [_faction,"flag"] call ALiVE_fnc_orbatCreatorFaction;

            _inputFactionFlag ctrlShow true;
            _inputFactionFlag ctrlSetText _factionFlag;
			_inputFactionFlag ctrlSetText _factionFlag;
			_inputFactionFlag ctrlCommit 0;

            [_logic,"displayFactionGroups", _faction] call MAINCLASS;
        };

	};

	case "displayFactionGroups": {

        private _faction = _args;

        private _factionDataSources = [_logic,"createFactionsGroupsDataSource", _faction] call MAINCLASS;

        [_logic,"groupsTreeAddDataSources", [_factionDataSources]] call MAINCLASS;

	};

	case "createFactionsGroupsDataSource": {

        private _faction = _args;

        if (_faction isequaltype "") then {
            _faction = [MOD(orbatCreator),"getFaction", _faction] call ALiVE_fnc_orbatCreator;
        };

        private _factionGroupCategories = [_faction,"groupCategories"] call ALiVE_fnc_orbatCreatorFaction;

        private _compatibleGroupCategories = [];
        private _incompatibleGroupCategories = [];

        {
            private _groupCategory = _x;
            private _groupCategoryConfigName = [_groupCategory,"configName"] call ALiVE_fnc_hashGet;

            private _groupCategoryDataSource = [_logic,"createGroupCategoryDataSource", _groupCategory] call MAINCLASS;

            if (_groupCategoryConfigName in ALIVE_COMPATIBLE_GROUP_CATEGORIES) then {
                _compatibleGroupCategories pushback _groupCategoryDataSource;
            } else {
                _incompatibleGroupCategories pushback _groupCategoryDataSource;
            };
        } foreach (_factionGroupCategories select 2);

        _result = [
            ["ALiVE Compatible Groups", "", "", _compatibleGroupCategories],
            ["ALiVE Incompatible Groups", "", "", _incompatibleGroupCategories]
        ];

	};

	case "createGroupCategoryDataSource": {

		private _groupCategory = _args;

        private _category = _x;
        private _categoryDisplayName = [_category,"name"] call ALiVE_fnc_hashGet;
        private _categoryGroups = [_category,"groups"] call ALiVE_fnc_hashGet;

        private _groupDataSources = [];
        {
            private _group = _x;
            private _groupDataSource = [_logic,"createGroupDataSource", _group] call MAINCLASS;

            _groupDataSources pushback _groupDataSource;
        } foreach (_categoryGroups select 2);

        _result = [_categoryDisplayName, "", "", _groupDataSources];

	};

	case "createGroupDataSource": {

		private _group = _args;

        private _groupName = [_group,"name"] call ALiVE_fnc_hashGet;
        private _groupClassname = [_group,"configName"] call ALiVE_fnc_hashGet;
        private _groupUnits = [_group,"units"] call ALiVE_fnc_hashGet;

        private _unitDataSources = [];

        for "_i" from 0 to (count _groupUnits - 1) do {
            private _unit = _groupUnits select _i;
            private _unitDataSource = [_logic,"createUnitDataSource", _unit] call MAINCLASS;

            _unitDataSources pushback _unitDataSource;
        };

        _result = [_groupName, _groupClassname, "", _unitDataSources];

	};

	case "createUnitDataSource": {

        private _unit = _args;

        private _orbatCreatorState = [MOD(orbatCreator),"state"] call ALiVE_fnc_orbatCreator;
        private _customUnits = [_orbatCreatorState,"customUnits"] call ALiVE_fnc_hashGet;

        private _unitSide = [_unit,"side"] call ALiVE_fnc_hashGet;
        private _unitVehicle = [_unit,"vehicle"] call ALiVE_fnc_hashGet;
        private _unitRank = [_unit,"rank"] call ALiVE_fnc_hashGet;
        private _unitPosition = [_unit,"position"] call ALiVE_fnc_hashGet;

		private "_unitDisplayName";
        if (_unitVehicle in (_customUnits select 1)) then {
            private _customUnit = [_customUnits,_unitVehicle] call ALiVE_fnc_hashGet;
            _unitDisplayName = [_customUnit,"displayName"] call ALiVE_fnc_hashGet;
        } else {
            private _vehicleConfig = configFile >> "CfgVehicles" >> _unitVehicle;
            _unitDisplayName = getText (_vehicleConfig >> "displayName");
        };

        private _vehicleClassDisplayName = format ["Class : %1", _unitVehicle];
        private _unitSideDisplayName = [[_unitSide] call ALiVE_fnc_sideNumberToText] call ALiVE_fnc_sideTextToLong;
        _unitSideDisplayName = format ["Side : %1", _unitSideDisplayName];
        private _unitRankDisplayName = format ["Rank : %1", _unitRank];
        private _unitPositionDisplayName = format ["Position : %1", _unitPosition];

        private _unitProperties = [
            [_vehicleClassDisplayName,"","",[]],
            [_unitSideDisplayName,"","",[]],
            [_unitRankDisplayName,"","",[]],
            [_unitPositionDisplayName,"","",[]]
        ];

        _result = [_unitDisplayName, _unitVehicle, "", _unitProperties];

	};

	case "groupsTreeAddDataSources": {

        _args params ["_dataSource",["_index",[]]];

		private _display = finddisplay OC_DISPLAY_FACTIONEDITOR;
        private _tree = OC_getControl( _display , OC_FACTIONEDITOR_TREE_GROUPS );

        {
            _x params ["_text","_data","_image","_children"];

            _tree tvAdd [_index,_text];
            _tree tvSetData [_index,_data];
            _tree tvSetPicture [_index,_image];

            [_logic,"groupsTreeAddDataSources", [_children,_index + [_forEachIndex]]] call MAINCLASS;
        } foreach _dataSource;

	};

	case "onFactionDeleteClicked": {

		private _display = finddisplay OC_DISPLAY_FACTIONEDITOR;
		private _factionList = OC_getControl( _display , OC_FACTIONEDITOR_FACTIONS_LIST );

        private _selectedFaction = OC_ctrlGetSelData(_factionList);

        [MOD(orbatCreator),"removeFaction", _selectedFaction] call ALiVE_fnc_orbatCreator;

        // update list

		[_logic,"loadFactionList"] call MAINCLASS;

	};



	// create faction



	case "onFactionCreateClicked": {

		ALiVE_factionEditor_createFactionUI = "create";
		createDialog "ALiVE_orbatCreator_interface_createFaction"

	};

	case "onLoadCreateFaction": {

		// delay onLoad function by one frame
		// so the display is actually loaded

		ALiVE_factionEditor_createFaction_onLoadFrameHandler = [{
			private _args = _this select 0;
			if (ALiVE_factionEditor_createFactionUI == "create") then {
				_args set [1, "onLoadCreateFaction2"];
			} else {
				_args set [1, "onLoadEditFaction2"];
			};

			_args call MAINCLASS;
		}, 0, _this] call CBA_fnc_addPerFrameHandler;

	};

	case "onLoadCreateFaction2": {

		[ALiVE_factionEditor_createFaction_onLoadFrameHandler] call CBA_fnc_removePerFrameHandler;

		private _display = findDisplay OC_DISPLAY_CREATEFACTION;
		_display displayAddEventHandler ["unload", format ["[%1,'onUnloadCreateFaction', 2] call ALiVE_fnc_FactionEditorGUI", _logic]];

		private _buttonOk = OC_getControl(_display,OC_CREATEFACTION_BUTTON_OK);
		_buttonOk ctrlSetEventHandler ["MouseButtonDown", format ["[%1,'onCreateFactionOKClicked'] call ALiVE_fnc_FactionEditorGUI", _logic]];

		private _buttonAutogen = OC_getControl(_display,OC_CREATEFACTION_BUTTON_AUTOGEN_CLASSNAME);
		_buttonAutogen ctrlSetEventHandler ["MouseButtonDown", format ["[%1,'onGenerateClassnameClicked'] call ALiVE_fnc_FactionEditorGUI", _logic]];

		private _inputSide = OC_getControl(_display,OC_CREATEFACTION_INPUT_SIDE);
		private _inputFlag = OC_getControl(_display,OC_CREATEFACTION_INPUT_FLAG);

		[nil,"loadSidesToList", _inputSide] call ALiVE_fnc_orbatCreatorGUI;
		[nil,"loadFlagsToList", _inputFlag] call ALiVE_fnc_orbatCreatorGUI;

		_inputSide lbSetCurSel 0;
		_inputFlag lbSetCurSel 0;

	};

	case "onUnloadCreateFaction": {

		[MOD(orbatCreator),"activeInteface", "Faction_Editor"] call ALiVE_fnc_orbatCreator;

	};

	case "onGenerateClassnameClicked": {

		private _display = findDisplay OC_DISPLAY_CREATEFACTION;

		private _sideList = OC_getControl(_display,OC_CREATEFACTION_INPUT_SIDE);
		private _countryInput = OC_getControl(_display,OC_CREATEFACTION_INPUT_COUNTRY);
		private _forceInput = OC_getControl(_display,OC_CREATEFACTION_INPUT_FORCE);
		private _camoInput = OC_getControl(_display,OC_CREATEFACTION_INPUT_CAMO);

        private _side = call compile OC_ctrlGetSelData(_sideList);
        private _country = ctrlText _countryInput;
        private _force = ctrlText _forceInput;
        private _camo = ctrlText _camoInput;

		private _classname = [nil,"generateFactionClassname", [_side,_country,_force,_camo]] call ALiVE_fnc_factionEditor;

        private _inputClassname = OC_getControl(_display,OC_CREATEFACTION_INPUT_CLASSNAME);
        _inputClassname ctrlSetText _classname;

	};

	case "validateFactionCreationInputs": {

		private _allowedClassnames = _this param [2, []];

		_result = true;

        private _inputDisplayname = OC_getControl(_display,OC_CREATEFACTION_INPUT_DISPLAYNAME);
        private _inputClassname = OC_getControl(_display,OC_CREATEFACTION_INPUT_CLASSNAME);
		private _inputCountry = OC_getControl(_display,OC_CREATEFACTION_INPUT_COUNTRY);

        private _displayName = ctrlText _inputDisplayname;
        private _className = ctrlText _inputClassname;
        private _country = ctrlText _inputCountry;

        private _context = OC_getControl(_display,OC_CREATEFACTION_CONTEXT);

        if (_displayName == "") exitwith {
			_result = false;
            _context ctrlSetText "Display name cannot be left blank";
        };

        if (_country == "") exitwith {
			_result = false;
            _context ctrlSetText "Country name cannot be left blank";
        };

        if (_className == "") exitwith {
			_result = false;
            _context ctrlSetText "Class name cannot be left blank";
        };

		private _factions = [MOD(orbatCreator),"getFactions"] call ALiVE_fnc_orbatCreator;
		private _existingClassnames = (_factions select 1) - _allowedClassnames;
        if (_className in _existingClassnames) exitwith {
			_result = false;
            _context ctrlSetText "A faction with that class name already exists!";
        };

	};

	case "onCreateFactionOKClicked": {

		private _display = findDisplay OC_DISPLAY_CREATEFACTION;

        private _inputDisplayname = OC_getControl(_display,OC_CREATEFACTION_INPUT_DISPLAYNAME);
        private _inputClassname = OC_getControl(_display,OC_CREATEFACTION_INPUT_CLASSNAME);
		private _sideList = OC_getControl(_display,OC_CREATEFACTION_INPUT_SIDE);
		private _flagList = OC_getControl(_display,OC_CREATEFACTION_INPUT_FLAG);
		private _inputCountry = OC_getControl(_display,OC_CREATEFACTION_INPUT_COUNTRY);
		private _inputForce = OC_getControl(_display,OC_CREATEFACTION_INPUT_FORCE);
		private _inputCamo = OC_getControl(_display,OC_CREATEFACTION_INPUT_CAMO);

        private _displayName = ctrlText _inputDisplayname;
        private _className = ctrlText _inputClassname;
        private _side = call compile OC_ctrlGetSelData(_sideList);
        private _flag = OC_ctrlGetSelData(_flagList);
        private _country = ctrlText _inputCountry;
        private _force = ctrlText _inputForce;
        private _camo = ctrlText _inputCamo;

        private _fieldsAreValid = [_logic,"validateFactionCreationInputs"] call MAINCLASS;

		if (!_fieldsAreValid) exitwith {};

        private _shortName = _country + _force;

		private _newFaction = [MOD(orbatCreator),"addFaction", [_displayName,_className,_shortName,_side,_flag,_camo]] call ALiVE_fnc_orbatCreator;

        closeDialog 0;

        // update list

        [_logic,"loadFactionList"] call MAINCLASS;

		private _factionList = OC_getControl(_display,OC_FACTIONEDITOR_FACTIONS_LIST);
        [_factionList,_className] call ALiVE_fnc_listSelectData;

	};

	case "onFactionEditClicked": {

		ALiVE_factionEditor_createFactionUI = "edit";
		createDialog "ALiVE_orbatCreator_interface_createFaction"

	};

	case "onLoadEditFaction2": {

		[ALiVE_factionEditor_createFaction_onLoadFrameHandler] call CBA_fnc_removePerFrameHandler;

		private _display = findDisplay OC_DISPLAY_CREATEFACTION;
		_display displayAddEventHandler ["unload", format ["[%1,'onUnloadEditFaction', 2] call ALiVE_fnc_FactionEditorGUI", _logic]];

		private _buttonOk = OC_getControl(_display,OC_CREATEFACTION_BUTTON_OK);
		_buttonOk ctrlSetEventHandler ["MouseButtonDown", format ["[%1,'onEditFactionOKClicked'] call ALiVE_fnc_FactionEditorGUI", _logic]];

		private _buttonAutogen = OC_getControl(_display,OC_CREATEFACTION_BUTTON_AUTOGEN_CLASSNAME);
		_buttonAutogen ctrlSetEventHandler ["MouseButtonDown", format ["[%1,'onGenerateClassnameClicked'] call ALiVE_fnc_FactionEditorGUI", _logic]];

        private _inputDisplayname = OC_getControl(_display,OC_CREATEFACTION_INPUT_DISPLAYNAME);
        private _inputClassname = OC_getControl(_display,OC_CREATEFACTION_INPUT_CLASSNAME);
		private _inputCountry = OC_getControl(_display,OC_CREATEFACTION_INPUT_COUNTRY);
		private _inputSide = OC_getControl(_display,OC_CREATEFACTION_INPUT_SIDE);
		private _inputFlag = OC_getControl(_display,OC_CREATEFACTION_INPUT_FLAG);

		[nil,"loadSidesToList", _inputSide] call ALiVE_fnc_orbatCreatorGUI;
		[nil,"loadFlagsToList", _inputFlag] call ALiVE_fnc_orbatCreatorGUI;

		_inputSide lbSetCurSel 0;
		_inputFlag lbSetCurSel 0;

		private _view = [MOD(orbatCreator),"orbatCreatorGUI"] call ALiVE_fnc_orbatCreator;
		private _selectedFaction = [_view,"selectedFaction"] call ALiVE_fnc_orbatCreatorGUI;
		private _faction = [MOD(orbatCreator),"getFaction", _selectedFaction] call ALiVE_fnc_orbatCreator;

		private _factionDisplayName = [_faction,"displayName"] call ALiVE_fnc_orbatCreatorFaction;
		private _factionConfigName = [_faction,"configName"] call ALiVE_fnc_orbatCreatorFaction;
		private _factionShortName = [_faction,"shortName"] call ALiVE_fnc_orbatCreatorFaction;
		private _factionSide = [_faction,"side"] call ALiVE_fnc_orbatCreatorFaction;
		private _factionFlag = [_faction,"flag"] call ALiVE_fnc_orbatCreatorFaction;

		_inputDisplayname ctrlSetText _factionDisplayName;
		_inputClassname ctrlSetText _factionConfigName;
		_inputCountry ctrlSetText _factionShortName;

		[_inputSide,str _factionSide] call ALiVE_fnc_listSelectData;
		[_inputFlag,_factionFlag] call ALiVE_fnc_listSelectData;

	};

	case "onUnloadEditFaction": {

		[MOD(orbatCreator),"activeInteface", "Faction_Editor"] call ALiVE_fnc_orbatCreator;

	};

	case "onEditFactionOKClicked": {

		private _display = findDisplay OC_DISPLAY_CREATEFACTION;

        private _inputDisplayname = OC_getControl(_display,OC_CREATEFACTION_INPUT_DISPLAYNAME);
        private _inputClassname = OC_getControl(_display,OC_CREATEFACTION_INPUT_CLASSNAME);
		private _sideList = OC_getControl(_display,OC_CREATEFACTION_INPUT_SIDE);
		private _flagList = OC_getControl(_display,OC_CREATEFACTION_INPUT_FLAG);
		private _inputCountry = OC_getControl(_display,OC_CREATEFACTION_INPUT_COUNTRY);
		private _inputForce = OC_getControl(_display,OC_CREATEFACTION_INPUT_FORCE);
		private _inputCamo = OC_getControl(_display,OC_CREATEFACTION_INPUT_CAMO);

        private _displayName = ctrlText _inputDisplayname;
        private _className = ctrlText _inputClassname;
        private _side = call compile OC_ctrlGetSelData(_sideList);
        private _flag = OC_ctrlGetSelData(_flagList);
        private _country = ctrlText _inputCountry;
        private _force = ctrlText _inputForce;
        private _camo = ctrlText _inputCamo;

		private _orbatCreatorGUI = [MOD(orbatCreator),"orbatCreatorGUI"] call ALiVE_fnc_orbatCreator;
		private _selectedFaction = [_orbatCreatorGUI,"selectedFaction"] call ALiVE_fnc_orbatCreatorGUI;
		private _faction = [MOD(orbatCreator),"getFaction", _selectedFaction] call ALiVE_fnc_orbatCreator;
		private _oldFactionClassname = [_faction,"configName"] call ALiVE_fnc_orbatCreatorFaction;

        private _fieldsAreValid = [_logic,"validateFactionCreationInputs", [_oldFactionClassname]] call MAINCLASS;

		if (!_fieldsAreValid) exitwith {};

		// update faction

		[MOD(orbatCreator),"updateFaction", [_displayName,_className,_country,_side,_flag,_camo]] call ALiVE_fnc_orbatCreator;

        closeDialog 0;

        // update list

        [_logic,"loadFactionList"] call MAINCLASS;

		private _factionList = OC_getControl(_display,OC_FACTIONEDITOR_FACTIONS_LIST);
        [_factionList,_className] call ALiVE_fnc_listSelectData;

	};

};

TRACE_1("Orbat Creator - output", _result);

if (!isnil "_result") then {_result} else {nil};