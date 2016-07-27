//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_orbatcreator\script_component.hpp>
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

// display components

#define OC_DISPLAY_ORBAT                        8000
#define OC_DISPLAY_UNITEDITOR                   9000
#define OC_DISPLAY_UNITEDITOR_CREATEUNIT        10000

// interface elements

#define OC_ORBAT_FACTIONS_LIST                  8008
#define OC_ORBAT_BUTTON_BIG_ONE                 8005
#define OC_ORBAT_BUTTON_BIG_TWO                 8006
#define OC_ORBAT_BUTTON_BIG_THREE               8007
#define OC_ORBAT_GROUPS_TREE                    8009

#define OC_UNITEDITOR_BUTTON_BIG_ONE            9008
#define OC_UNITEDITOR_BUTTON_BIG_TWO            9009
#define OC_UNITEDITOR_BUTTON_BIG_THREE          9010
#define OC_UNITEDITOR_CLASSLIST_BUTTON_ONE      9012
#define OC_UNITEDITOR_CLASSLIST_BUTTON_TWO      9013
#define OC_UNITEDITOR_CLASSLIST_BUTTON_THREE    9014
#define OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR     9015
#define OC_UNITEDITOR_CLASSLIST_LIST            9011
#define OC_UNITEDITOR_FACTIONS_LIST             9007

#define OC_UNITEDITOR_CREATEUNIT_SIDEINPUT              10008
#define OC_UNITEDITOR_CREATEUNIT_FACTIONINPUT           10009
#define OC_UNITEDITOR_CREATEUNIT_PARENCLASSESINPUT      10010
#define OC_UNITEDITOR_CREATEUNIT_DISPLAYNAMEINPUT       10011
#define OC_UNITEDITOR_CREATEUNIT_CLASSNAMEINPUT         10012
#define OC_UNITEDITOR_CREATEUNIT_BUTTON_OK              10013
#define OC_UNITEDITOR_CREATEUNIT_BUTTON_CANCEL          10014

#define

// control Macros

#define OC_getControl(disp,ctrl)    ((findDisplay disp) displayCtrl ctrl)
#define OC_getSelData(ctrl)         (lbData [ctrl,(lbCurSel ctrl)])
#define OC_ctrlGetSelData(ctrl)     (ctrl lbData (lbCurSel ctrl))

// general macros

#define ALIVE_COMPATIBLE_GROUP_CATEGORIES   ["Infantry","SpecOps","Motorized","Motorized_MTP","Mechanized","Armored","Artillery","Naval","Air","Support"]


TRACE_1("Orbat Creator - input", _this);

disableSerialization;
private ["_result"];
params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull]
];

switch(_operation) do {

    default {
        _result = _this call SUPERCLASS;
    };

    case "init": {

        if (isDedicated) exitWith {};

        // only one init per instance is allowed

        if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS Orbat Creator - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

        // start init

        _logic setVariable ["initGlobal", false];

        _logic setVariable ["super", QUOTE(SUPERCLASS)];
        _logic setVariable ["class", QUOTE(MAINCLASS)];
        _logic setVariable ["moduleType", QUOTE(ADDON)];
        _logic setVariable ["startupComplete", false];

        // get module settings

        private _debug = call compile (_logic getVariable "debug");

        [_logic,"debug", _debug] call MAINCLASS;

        // data init

        // load static data

        if (isnil "ALiVE_STATIC_DATA_LOADED") then {
            private _file = "\x\alive\addons\main\static\staticData.sqf";
            call compile preprocessFileLineNumbers _file;
        };

        private _tmpHash = [] call ALiVE_fnc_hashCreate;

        private _state = +_tmpHash;
        [_logic,"state", _state] call MAINCLASS;

        // init factions by side

        _east = +_tmpHash;
        _west = +_tmpHash;
        _indep = +_tmpHash;

        private _factions = +_tmpHash;

        private _assetsByFaction = [_logic,"getUnitsByFaction"] call MAINCLASS;

        private _allFactions = [] call ALiVE_fnc_configGetFactions;

        {
            _faction = _x;
            _factionClass = _faction call ALiVE_fnc_configGetFactionClass;
            _factionSide = getNumber (_factionClass >> "side");

            if (_factionSide >= 0 && {_factionSide <= 2}) then {
                _factionConfigName = _faction;
                _factionDisplayName = getText (_factionClass >> "displayName");
                _factionFlag = getText (_factionClass >> "flag");
                _factionIcon = getText (_factionClass >> "icon");
                _factionPriority = getNumber (_factionClass >> "priority");
                _factionSide = getNumber (_factionClass >> "side");

                _factionGroups = [_logic,"getFactionGroups", _faction] call MAINCLASS;
                _factionAssets = [_assetsByFaction, _faction] call ALiVE_fnc_hashGet;

                // create SQF representation of faction

                _newFaction = [nil,"create"] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"init"] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"configName", _factionConfigName] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"displayName", _factionDisplayName] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"flag", _factionFlag] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"icon", _factionIcon] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"priority", _factionPriority] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"side", _factionSide] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"groupsByCategory", _factionGroups] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"assets", _factionAssets] call ALiVE_fnc_orbatCreatorFaction;

                [_factions,_factionConfigName,_newFaction] call ALiVE_fnc_hashSet;
            };
        } foreach _allFactions;

        [_state,"factions", _factions] call ALiVE_fnc_hashSet;

        [_state,"orbatViewer_selectedFaction", ""] call ALiVE_fnc_hashSet;

        private _customUnits = +_tmpHash;
        [_state,"customUnits", _customUnits] call ALiVE_fnc_hashSet;

        [_state,"unitEditor_interfaceBackground", objNull] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_interfaceCamera", objNull] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_activeUnitPosition", [0,0,0]] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_activeUnitObject", objNull] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_selectedFaction", ""] call ALiVE_fnc_hashSet;

        MOD(orbatCreator) = _logic;

        [_logic,"start"] spawn MAINCLASS;

    };

    case "start": {

        waitUntil {time > 0 && {!isnull player} && {!isnil "ALiVE_STATIC_DATA_LOADED"}};

        ["ORBAT_Viewer"] spawn ALiVE_fnc_orbatCreatorOpenInterface;
        ["Preload"] call BIS_fnc_arsenal;

        // initialise main menu

        [
            "player",
            [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
            -9500,
            [
                "call ALiVE_fnc_orbatCreatorMenuDef",
                "main"
            ]
        ] call ALIVE_fnc_flexiMenu_Add;

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

    case "debug": {

        if (typeName _args == "BOOL") then {
            _logic setVariable ["debug", _args];
            _result = _args;
        } else {
            _result = _logic getVariable ["debug", false];
        };

    };

    case "state": {

        if (typeName _args == "ARRAY") then {
            _logic setVariable ["debug", _args];
            _result = _args;
        } else {
            _result = _logic getVariable ["debug", false];
        };

    };

    case "openInterface": {

        private _interface = _args;

        switch (_interface) do {
            case "ORBAT_Viewer": {
                closeDialog 0;
                sleep 0.001; // bis pls
                createDialog "ALiVE_orbatCreator_interface_orbatViewer";
            };
            case "Unit_Editor": {
                closeDialog 0;
                sleep 0.001; // bis pls
                createDialog "ALiVE_orbatCreator_interface_unitEditor";
            };
            case "Unit_Editor_Create_Unit": {
                createDialog "ALiVE_orbatCreator_interface_unitEditor_createUnit";
            };
            case "Group_Editor": {
                closeDialog 0;
                sleep 0.001; // bis pls
                createDialog "ALiVE_orbatCreator_interface_groupEditor";
            };
        };

        [_logic,"onLoad", _interface] call MAINCLASS;

    };

    case "onLoad": {

        private _interface = _args;

        switch (_interface) do {

            case "ORBAT_Viewer": {

                private ["_faction","_factionConfig","_factionSide","_factionName","_index"];

                private _display = findDisplay OC_DISPLAY_ORBAT;
                _display displayAddEventHandler ["unload", "['onUnload', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionList = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_FACTIONS_LIST);
                private _allFactions = [] call ALiVE_fnc_configGetFactions;

                {
                    _faction = _x;
                    _factionConfig = _x call ALiVE_fnc_configGetFactionClass;
                    _factionSide = getNumber (_factionConfig >> "side");

                    if (_factionSide <= 2 && {_factionSide >= 0}) then {
                        _factionName = getText (_factionConfig >> "displayName");
                        _factionName = format ["%1 - %2", _factionName, _faction];
                        _index = _factionList lbAdd _factionName;
                        _factionList lbSetData [_index,_x];
                    };
                } foreach _allFactions;

                lbSort [_factionList, "ASC"];

                _factionList ctrlSetEventHandler ["lbSelChanged","['onORBATFactionListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // init buttons

                private _button1 = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_BUTTON_BIG_ONE);
                _button1 ctrlSetText "Unit Editor";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['Unit_Editor'] call ALiVE_fnc_orbatCreatorOpenInterface"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_BUTTON_BIG_TWO);
                _button2 ctrlSetText "Group Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['Group_Editor'] call ALiVE_fnc_orbatCreatorOpenInterface"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_BUTTON_BIG_THREE);
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

            };

            case "Unit_Editor": {

                private _display = findDisplay OC_DISPLAY_UNITEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionList = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_FACTIONS_LIST);
                private _allFactions = [] call ALiVE_fnc_configGetFactions;

                {
                    _faction = _x;
                    _factionConfig = _x call ALiVE_fnc_configGetFactionClass;
                    _factionSide = getNumber (_factionConfig >> "side");

                    if (_factionSide <= 2 && {_factionSide >= 0}) then {
                        _factionName = getText (_factionConfig >> "displayName");
                        _factionName = format ["%1 - %2", _factionName, _faction];
                        _index = _factionList lbAdd _factionName;
                        _factionList lbSetData [_index,_x];
                    };
                } foreach _allFactions;

                lbSort [_factionList, "ASC"];

                _factionList ctrlSetEventHandler ["lbSelChanged","['onUnitEditorFactionListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // init buttons

                private _button1 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_BUTTON_BIG_ONE);
                _button1 ctrlSetText "ORBAT Viewer";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOpenInterface"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_BUTTON_BIG_TWO);
                _button2 ctrlSetText "Group Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['Group_Editor'] call ALiVE_fnc_orbatCreatorOpenInterface"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_BUTTON_BIG_THREE);
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

                // init class list

                private _classList_button1 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_ONE);
                _classList_button1 ctrlSetText "New";
                _classList_button1 ctrlSetTooltip "Create new unit for selected faction";
                _classList_button1 ctrlSetEventHandler ["MouseButtonDown","['Unit_Editor_Create_Unit'] call ALiVE_fnc_orbatCreatorOpenInterface"];
                _classList_button1 ctrlShow true;

                private _classList_button2 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_TWO);
                _classList_button2 ctrlSetText "Edit";
                _classList_button2 ctrlSetTooltip "Edit selected unit in the arsenal";
                _classList_button2 ctrlSetEventHandler ["MouseButtonDown","['onUnitEditorEditClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button2 ctrlShow true;

                private _classList_button3 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_THREE);
                _classList_button3 ctrlSetText "Save";
                _classList_button3 ctrlSetEventHandler ["MouseButtonDown","[] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button3 ctrlShow true;

                private _classList_button4 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR);
                _classList_button4 ctrlSetText "Delete";
                _classList_button4 ctrlSetTooltip "Delete selected unit";
                _classList_button4 ctrlSetEventHandler ["MouseButtonDown","[] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button4 ctrlShow true;

                // init unit class list

                private _assetList = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_LIST);
                _assetList ctrlSetEventHandler ["lbSelChanged","['onUnitEditorAssetListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetList ctrlShow true;

                [_logic,"enableUnitEditorBackground", true] call MAINCLASS;

            };

            case "Unit_Editor_Create_Unit": {

                private ["_sideNum","_sideText","_sideTextLong","_index"];

                // init input fields

                private _state = [_logic,"state"] call MAINCLASS;
                private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
                private _selectedFaction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;

                private _selectedFactionData = [_factions,_selectedFaction] call ALiVE_fnc_hashGet;
                private _selectedFactionSide = [_selectedFactionData,"side"] call ALiVE_fnc_hashGet;
                private _indexToSelect = -1;

                private _sideList = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_SIDEINPUT);
                _sideList ctrlShow true;

                private _sides = [0,1,2];
                {
                    _sideNum = _x;
                    _sideText = [_sideNum] call ALiVE_fnc_sideNumberToText;
                    _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;

                    _index = _sideList lbAdd _sideTextLong;
                    _sideList lbSetData [_index,str _sideNum];

                    if (_sideNum == _selectedFactionSide) then {
                        _indexToSelect = _forEachIndex;
                    };
                } foreach _sides;

                _sideList ctrlSetEventHandler ["lbSelChanged","['onUnitEditorCreateUnitSideListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                if (_indexToSelect == -1) then {
                    _sideList lbSetCurSel 0;
                } else {
                    _sideList lbSetCurSel _indexToSelect;
                };

                // init buttons

                private _buttonOK = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_BUTTON_OK);
                _buttonOK ctrlSetEventHandler ["MouseButtonDown","['onUnitEditorCreateUnitOkClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _buttonOK ctrlShow true;

                private _buttonCancel = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_BUTTON_CANCEL);
                _buttonCancel ctrlSetEventHandler ["MouseButtonDown","closeDialog 0"];
                _buttonCancel ctrlShow true;

            };

            case "Group_Editor": {



            };

        };

    };

    case "onUnload": {

        private _interface = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        switch (_interface) do {
            case "ORBAT_Viewer": {

            };
            case "Unit_Editor": {
                [_logic,"enableUnitEditorBackground", false] call MAINCLASS;
            };
            case "Group_Editor": {

            };
        };

    };

    case "getUnitsByFaction": {

        private [
            "_factionConfig","_factionConfigName","_entry","_entryScope",
            "_entrySide","_entryFaction","_factionUnits","_entryDisplayName",
            "_entryConfigName"
        ];

        private _tmpHash = [] call ALiVE_fnc_hashCreate;

        _result = +_tmpHash;

        private _allFactions = [] call ALiVE_fnc_configGetFactions;

        // build factions list

        {
            _factionConfig = _x call ALiVE_fnc_configGetFactionClass;
            _factionSide = getNumber (_factionConfig >> "side");

            if (_factionSide >= 0 && {_factionSide <= 2}) then {
                _factionConfigName = configName _factionConfig;

                [_result,_factionConfigName, +_tmpHash] call ALiVE_fnc_hashSet;
            };
        } foreach _allFactions;

        // set unit classes to factions

        private _configPath = configFile >> "CfgVehicles";
        for "_i" from 0 to (count _configPath - 1) do {

            _entry = _configPath select _i;

            if (isClass _entry) then {

                _entryScope = getNumber (_entry >> "scope");

                if (_entryScope >= 2) then {
                    _entrySide = getNumber (_entry >> "side");

                    if (_entrySide <= 2 && {_entrySide >= 0}) then {
                        _entryFaction = getText (_entry >> "faction");

                        _factionUnits = nil;
                        _factionUnits = [_result,_entryFaction] call ALiVE_fnc_hashGet;

                        if (!isnil "_factionUnits") then {
                            _entryDisplayName = getText (_entry >> "displayName");
                            _entryConfigName = configName _entry;

                            [_factionUnits,_entryDisplayName, _entryConfigName] call ALiVE_fnc_hashSet;
                        };
                    };
                };
            };

        };

    };

    case "getFactionGroups": {

        private [
            "_groupCategory","_groupCategoryName","_groupCategoryGroups","_group",
            "_groupConfigName","_groupName","_groupSide","_groupFaction","_units",
            "_groupHash","_unit","_unitSide","_unitVehicle","_unitRank","_unitPosition",
            "_unitHash"
        ];

        private _faction = _args;
        private _factionGroupCategories = _faction call ALiVE_fnc_configGetFactionGroups;

        private _tmpHash = [] call ALiVE_fnc_hashCreate;

        private _ALiVE_compatibleGroups = +_tmpHash;
        private _ALiVE_incompatibleGroups = +_tmpHash;

        _result = +_tmpHash;
        [_result,"ALiVE_compatible", _ALiVE_compatibleGroups] call ALiVE_fnc_hashSet;
        [_result,"ALiVE_incompatible", _ALiVE_incompatibleGroups] call ALiVE_fnc_hashSet;

        for "_i" from 0 to (count _factionGroupCategories - 1) do {

            _groupCategory = _factionGroupCategories select _i;

            if (isClass _groupCategory) then {

                _groupCategoryName = configName _groupCategory;
                _groupCategoryGroups = +_tmpHash;

                for "_i" from 0 to (count _groupCategory - 1) do {

                    _group = _groupCategory select _i;

                    if (isClass _group) then {

                        _groupConfigName = configName _group;
                        _groupName = getText (_group >> "name");
                        _groupSide = getNumber (_group >> "side");
                        _groupFaction = getText (_group >> "faction");
                        //_rarityGroup = getNumber (_group >> "rarityGroup");

                        _units = [];

                        for "_i" from 0 to (count _group - 1) do {

                            _unit = _group select _i;

                            if (isClass _unit) then {
                                _unitSide = getNumber (_unit >> "side");
                                _unitVehicle = getText (_unit >> "vehicle");
                                _unitRank = getText (_unit >> "rank");
                                _unitPosition = getArray (_unit >> "position");

                                _unitHash = +_tmpHash;
                                [_unitHash,"side", _unitSide] call ALiVE_fnc_hashSet;
                                [_unitHash,"vehicle", _unitVehicle] call ALiVE_fnc_hashSet;
                                [_unitHash,"rank", _unitRank] call ALiVE_fnc_hashSet;
                                [_unitHash,"position", _unitPosition] call ALiVE_fnc_hashSet;

                                _units pushback _unitHash;
                            };

                        };

                        _groupHash = +_tmpHash;
                        [_groupHash,"name", _groupName] call ALiVE_fnc_hashSet;
                        [_groupHash,"side", _groupSide] call ALiVE_fnc_hashSet;
                        [_groupHash,"faction", _groupFaction] call ALiVE_fnc_hashSet;
                        [_groupHash,"units", _units] call ALiVE_fnc_hashSet;

                        [_groupCategoryGroups,_groupConfigName,_groupHash] call ALiVE_fnc_hashSet;

                    };

                };

                if (_groupCategoryName in ALIVE_COMPATIBLE_GROUP_CATEGORIES) then {
                    [_ALiVE_compatibleGroups,_groupCategoryName,_groupCategoryGroups] call ALiVE_fnc_hashSet;
                } else {
                    [_ALiVE_incompatibleGroups,_groupCategoryName,_groupCategoryGroups] call ALiVE_fnc_hashSet;
                };

            };

        };

    };

    case "getFactionGroupsDataSources": {

        private ["_groupCategoryName","_groupCategoryData","_groupCategoryDataSource"];

        private _faction = _args;
        _result = [];

        if (_faction isEqualType "") then {
            private _state = [_logic,"state"] call MAINCLASS;
            private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
            _faction = [_factions,_faction] call ALiVE_fnc_hashGet;
        };

        private _factionGroupCategories = [_faction,"groupsByCategory"] call ALiVE_fnc_hashGet;
        private _compatibleGroups = [_factionGroupCategories,"ALiVE_compatible"] call ALiVE_fnc_hashGet;
        private _incompatibleGroups = [_factionGroupCategories,"ALiVE_incompatible"] call ALiVE_fnc_hashGet;

        // get ALiVE compatible group categories

        private _groupCategories = [];

        private _compatibleGroupCategoryNames = _compatibleGroups select 1;
        private _compatibleGroupCategoryData = _compatibleGroups select 2;

        for "_i" from 0 to (count _compatibleGroupCategoryNames - 1) do {
            _groupCategoryName = _compatibleGroupCategoryNames select _i;
            _groupCategoryData = _compatibleGroupCategoryData select _i;

            _groupCategoryDataSource = [_logic,"getGroupCategoryDataSource", [_groupCategoryName,_groupCategoryData]] call MAINCLASS;
            _groupCategories pushback _groupCategoryDataSource;
        };

        _result pushback ["ALiVE Compatible Groups", "", "", _groupCategories];

        // get ALiVE incompatible group categories

        _groupCategories = [];

        private _incompatibleGroupCategoryNames = _incompatibleGroups select 1;
        private _incompatibleGroupCategoryData = _incompatibleGroups select 2;

        for "_i" from 0 to (count _incompatibleGroupCategoryNames - 1) do {
            _groupCategoryName = _incompatibleGroupCategoryNames select _i;
            _groupCategoryData = _incompatibleGroupCategoryData select _i;

            _groupCategoryDataSource = [_logic,"getGroupCategoryDataSource", [_groupCategoryName,_groupCategoryData]] call MAINCLASS;
            _groupCategories pushback _groupCategoryDataSource;
        };

        _result pushback ["ALiVE Incompatible Groups", "", "", _groupCategories];

    };

    case "getGroupCategoryDataSource": {

        private ["_groupClassname","_groupHash","_groupDataSource"];
        _args params ["_groupCategoryName","_groupsInCategory"];

        private _groups = [];

        private _groupNames = _groupsInCategory select 1;
        private _groupData = _groupsInCategory select 2;

        for "_i" from 0 to (count _groupNames - 1) do {
            _groupClassname = _groupNames select _i;
            _groupHash = _groupData select _i;

            _groupDataSource = [_logic,"getGroupDataSource", [_groupClassname,_groupHash]] call MAINCLASS;
            _groups pushback _groupDataSource;

        };

        _result = [_groupCategoryName, "", "", _groups];

    };

    case "getGroupDataSource": {

        private ["_unit","_unitDataSource"];
        _args params ["_groupClassname","_groupHash"];

        private _groupName = _groupHash select 2 select 0;      // [_groupHash,"name"] call ALiVE_fnc_hashGet;
        private _groupUnits = _groupHash select 2 select 3;     // [_groupHash,"units"] call ALiVE_fnc_hashGet;

        private _unitDataSources = [];

        for "_i" from 0 to (count _groupUnits - 1) do {

            _unit = _groupUnits select _i;

            _unitDataSource = [_logic,"getUnitDataSource", _unit] call MAINCLASS;
            _unitDataSources pushback _unitDataSource;

        };

        _result = [_groupName, _groupClassname, "", _unitDataSources];

    };

    case "getUnitDataSource": {

        private _unitHash = _args;

        private _unitSide = _unitHash select 2 select 0;        // [_unitHash,"side"] call ALiVE_fnc_hashGet;
        private _unitVehicle = _unitHash select 2 select 1;     // [_unitHash,"vehicle"] call ALiVE_fnc_hashGet;
        private _unitRank = _unitHash select 2 select 2;        // [_unitHash,"rank"] call ALiVE_fnc_hashGet;
        private _unitPosition = _unitHash select 2 select 3;    // [_unitHash,"position"] call ALiVE_fnc_hashGet;

        private _vehicleConfig = configFile >> "CfgVehicles" >> _unitVehicle;
        private _unitDisplayName = getText (_vehicleConfig >> "displayName");

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

    case "treeAddDataSourcesArray": {

        _args params ["_tree","_dataSource",["_index",[]]];

        {
            _x params ["_text","_data","_image","_children"];

            _tree tvAdd [_index,_text];
            _tree tvSetData [_index,_data];
            _tree tvSetPicture [_index,_image];

            [_logic,"treeAddDataSourcesArray", [_tree,_children,_index + [_forEachIndex]]] call MAINCLASS;
        } foreach _dataSource;

    };

    case "onORBATFactionListChanged": {

        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData(_list);

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;

        private _tree = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_GROUPS_TREE);
        tvClear _tree;
        _tree ctrlShow true;

        private _factionDataSources = [_logic,"getFactionGroupsDataSources", _factionData] call MAINCLASS;

        [_logic,"treeAddDataSourcesArray", [_tree,_factionDataSources]] call MAINCLASS;

        [_state,"orbatViewer_selectedFaction", _faction] call ALiVE_fnc_hashSet;

    };



    // unit editor



    case "enableUnitEditorBackground": {

        private _enable = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        if (_enable) then {
            private _pos = getPos player;
            _pos set [2,500];

            // init background

            private _background = createVehicle ["Sphere_3DEN",[0,0,0],[],0,"none"];
            _background setPosATL _pos;
            _background setDir 0;

            [_state,"unitEditor_interfaceBackground", _background] call ALiVE_fnc_hashSet;

            // init camera

            private _tempUnit = createVehicle [typeOf player,position player,[],0,"none"];
            _tempUnit setPosATL _pos;
            _tempUnit setDir 0;
            _tempUnit switchAction "playerstand";
            _tempUnit enableSimulation false;

            [_state,"unitEditor_activeUnitPosition", getPosASL _tempUnit] call ALiVE_fnc_hashSet;

            private _target = _tempUnit modelToWorld [0,4,1.6];
            deleteVehicle _tempUnit;

            private _cam = "camera" camCreate _pos;
            _cam camSetFov 0.35;
            _cam setDir (_cam getRelDir _tempUnit);
            _cam camSetTarget _target;
            _cam camSetRelPos [-0.05,1,0.15];
            _cam cameraEffect ["Internal", "Back"];
            _cam camcommit 0;

            showcinemaborder false;

            [_state,"unitEditor_interfaceCamera", _cam] call ALiVE_fnc_hashSet;
        } else {
            private _interfaceCamera = [_state,"unitEditor_interfaceCamera"] call ALiVE_fnc_hashGet;
            private _interfaceBackground = [_state,"unitEditor_interfaceBackground"] call ALiVE_fnc_hashGet;
            private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

            _interfaceCamera cameraEffect ["terminate","back"];
            camDestroy _interfaceCamera;

            deleteVehicle _activeUnit;
            deleteVehicle _interfaceBackground;

            [player,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;
        };

    };

    case "onUnitEditorFactionListChanged": {

        private ["_index"];
        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData(_list);

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _units = [];

        {
            _customUnit = _x;
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;
            _customUnitDisplayName = [_customUnit,"displayName"] call ALiVE_fnc_hashGet;
            _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _faction) then {
                _units pushback [_customUnitDisplayName,_customUnitConfigName];
            };
        } foreach (_customUnits select 2);

        // add assets to list

        private _assetList = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_LIST);
        lbClear _assetList;

        {
            _index = _assetList lbAdd (_x select 0);
            _assetList lbSetData [_index, _x select 1];
        } foreach _units;

        [_state,"unitEditor_selectedFaction", _faction] call ALiVE_fnc_hashSet;

    };

    case "onUnitEditorAssetListChanged": {

        private ["_customUnitParentEntry","_customUnitParent"];
        _args params ["_list","_index"];

        private _selectedUnitClassname = OC_ctrlGetSelData(_list);
        private _buttonEdit = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_TWO);

        private _state = [_logic,"state"] call MAINCLASS;
        private _cam = [_state,"unitEditor_interfaceCamera"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        // get selected unit

        private _customUnit = [_customUnits,_selectedUnitClassname] call ALiVE_fnc_hashGet;
        private _customUnitLoadout = [_customUnit,"loadout"] call ALiVE_fnc_hashGet;
        private _customUnitParent = [_customUnit,"inheritsFrom"] call ALiVE_fnc_hashGet;

        // if custom unit parent is another custom unit
        // keep going up the inheritance tree until you find a real unit

        private _configPath = configFile >> "CfgVehicles" >> _customUnitParent;

        while {!isClass _configPath} do {

            _customUnitParentEntry = [_customUnits,_customUnitParent] call ALiVE_fnc_hashGet;
            _customUnitParent = [_customUnitParentEntry,"inheritsFrom"] call ALiVE_fnc_hashGet;
            _configPath = configFile >> "CfgVehicles" >> _customUnitParent;

        };

        // get unit side object

        private _customUnitSide = [_customUnit,"side"] call ALiVE_fnc_hashGet;
        private _customSideText = [_customUnitSide] call ALiVE_fnc_sideNumberToText;
        private _customUnitSideObject = [_customSideText] call ALiVE_fnc_sideTextToObject;

        private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
        deleteVehicle _activeUnit;

        private _pos = [_state,"unitEditor_activeUnitPosition"] call ALiVE_fnc_hashGet;

        if (_customUnitParent isKindOf "Man") then {
            _activeUnit = (createGroup _customUnitSideObject) createUnit [_customUnitParent, [0,0,0], [], 0, "NONE"];
            _activeUnit setPosASL _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;
            _activeUnit switchMove (animationState player);
            _activeUnit switchAction "playerstand";

            _activeUnit setUnitLoadout _customUnitLoadout;
            _cam camSetRelPos [-0.05,1,0.15];
            _cam camSetFov 0.35;

            _buttonEdit ctrlEnable true;
        } else {
            _activeUnit = _customUnitParent createVehicle [0,0,0];
            _activeUnit setPosASL _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;

            _cam camSetRelPos [0, (sizeOf _customUnitParent) * 0.65, (sizeOf _customUnitParent) * 0.1];
            _cam camSetFov 0.5;

            _buttonEdit ctrlEnable false;
        };

        _activeUnit = [_state,"unitEditor_activeUnitObject", _activeUnit] call ALiVE_fnc_hashSet;
        _cam camCommit 0;

    };

    case "onUnitEditorEditClicked": {



    };



    // unit editor - create unit



    case "onUnitEditorCreateUnitSideListChanged": {

        private ["_faction","_side","_factionDisplayName","_factionConfigName"];
        _args params ["_list","_index"];

        private _sideNum = OC_ctrlGetSelData(_list);
        _sideNum = call compile _sideNum;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _sideFactions = [];
        {
            _faction = _x;
            _side = [_faction,"side"] call ALiVE_fnc_hashGet;

            if (_side == _sideNum) then {
                _factionDisplayName = [_faction,"displayName"] call ALiVE_fnC_hashGet;
                _factionConfigName = [_faction,"configName"] call ALiVE_fnc_hashGet;

                _sideFactions pushback [_factionDisplayName,_factionConfigName];
            };
        } foreach (_factions select 2);

        private _selectedFaction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _indexToSelect = -1;

        private _factionList = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_FACTIONINPUT);
        lbClear _factionList;
        _factionList ctrlSetEventHandler ["lbSelChanged","['onUnitEditorCreateUnitFactionListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

        {
            _x params ["_factionDisplayName","_factionConfigName"];

            _index = _factionList lbAdd _factionDisplayName;
            _factionList lbSetData [_index, _factionConfigName];

            if (_factionConfigName == _selectedFaction) then {
                _indexToSelect = _forEachIndex;
            };
        } foreach _sideFactions;

        if (_indexToSelect == -1) then {
            _factionList lbSetCurSel 0;
        } else {
            _factionList lbSetCurSel _indexToSelect;
        };

    };

    case "onUnitEditorCreateUnitFactionListChanged": {

        private ["_customUnit","_customUnitFaction","_customUnitDisplayName","_customUnitConfigName"];
        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData(_list);
        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _assetsToDisplay = [];

        // get custom units for faction

        {
            _customUnit = _x;
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _faction) then {
                _customUnitDisplayName = [_customUnit,"displayName"] call ALiVE_fnc_hashGet;
                _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;

                _assetsToDisplay pushback [_customUnitDisplayName,_customUnitConfigName];
            };
        } foreach (_customUnits select 2);

        // get faction assets

        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;

        private _factionAssetDisplayNames = _factionAssets select 1;
        private _factionAssetConfigNames = _factionAssets select 2;

        for "_i" from 0 to (count _factionAssetDisplayNames - 1) do {
            _assetsToDisplay pushback [_factionAssetDisplayNames select _i, _factionAssetConfigNames select _i];
        };

        // populate list

        private _buttonOK = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_BUTTON_OK);
        _buttonOK ctrlEnable false;

        private _parentClassesList = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_PARENCLASSESINPUT);
        lbClear _parentClassesList;
        _parentClassesList ctrlshow true;
        _parentClassesList ctrlSetEventHandler ["lbSelChanged","['onUnitEditorCreateUnitParentClassesListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

        {
            _x params ["_displayName","_configName"];

            _index = _parentClassesList lbAdd _displayName;
            _parentClassesList lbSetData [_index, _configName];
        } foreach _assetsToDisplay;

        if (lbSize _parentClassesList > 0) then {
            _parentClassesList lbSetCurSel 0;
        };

    };

    case "onUnitEditorCreateUnitParentClassesListChanged": {

        private _buttonOK = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_BUTTON_OK);
        _buttonOK ctrlEnable true;

    };

    case "onUnitEditorCreateUnitOkClicked": {

        private _state = [_logic,"state"] call MAINCLASS;

        // get side/faction

        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _faction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _side = [_factionData,"side"] call ALiVE_fnc_hashGet;

        // get parent class

        private _parentClass = OC_getSelData(OC_UNITEDITOR_CREATEUNIT_PARENCLASSESINPUT);

        // get displayname/configname

        private _displayNameInput = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_DISPLAYNAMEINPUT);
        private _classnameInput = OC_getControl(OC_DISPLAY_UNITEDITOR_CREATEUNIT,OC_UNITEDITOR_CREATEUNIT_CLASSNAMEINPUT);
        private _displayName = ctrlText _displayNameInput;
        private _classname = ctrlText _classnameInput;

        private _loadout = [];

        if (_parentClass isKindOf "Man") then {
            _loadout = getUnitLoadout _parentClass;
        };

        // create new custom unit

        private _newUnit = [nil,"create"] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"init"] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"inheritsFrom", _parentClass] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"side", _side] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"faction", _faction] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"displayName", _displayName] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"configName", _classname] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"loadout", _loadout] call ALiVE_fnc_orbatCreatorUnit;

        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        [_customUnits,_classname,_newUnit] call ALiVE_fnc_hashSet;

        closeDialog 0;

        private _factionList = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_FACTIONS_LIST);
        _factionList lbSetCurSel (lbCurSel _factionList);

    };

};

TRACE_1("Orbat Creator - output", _result);

if (!isnil "_result") then {_result} else {nil};