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

#define OC_DISPLAY_ORBAT                            8000
#define OC_DISPLAY_UNITEDITOR                       9000
#define OC_DISPLAY_CREATEUNIT                       10000
#define OC_DISPLAY_GROUPEDITOR                      11000

// interface elements

#define OC_ORBAT_FACTIONS_LIST                      8008
#define OC_ORBAT_BUTTON_BIG_ONE                     8005
#define OC_ORBAT_BUTTON_BIG_TWO                     8006
#define OC_ORBAT_BUTTON_BIG_THREE                   8007
#define OC_ORBAT_GROUPS_TREE                        8009

#define OC_UNITEDITOR_BUTTON_BIG_ONE                9008
#define OC_UNITEDITOR_BUTTON_BIG_TWO                9009
#define OC_UNITEDITOR_BUTTON_BIG_THREE              9010
#define OC_UNITEDITOR_CLASSLIST_BUTTON_ONE          9012
#define OC_UNITEDITOR_CLASSLIST_BUTTON_TWO          9013
#define OC_UNITEDITOR_CLASSLIST_BUTTON_THREE        9014
#define OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR         9015
#define OC_UNITEDITOR_CLASSLIST_LIST                9011
#define OC_UNITEDITOR_FACTIONS_LIST                 9007

#define OC_CREATEUNIT_INPUT_DISPLAYNAME             10010
#define OC_CREATEUNIT_INPUT_CLASSNAME               10011
#define OC_CREATEUNIT_INPUT_SIDE                    10012
#define OC_CREATEUNIT_INPUT_FACTION                 10013
#define OC_CREATEUNIT_INPUT_UNITTYPE_SIDE           10014
#define OC_CREATEUNIT_INPUT_UNITTYPE_FACTION        10015
#define OC_CREATEUNIT_INPUT_UNITTYPE_UNITS          10016
#define OC_CREATEUNIT_BUTTON_CANCEL                 10017
#define OC_CREATEUNIT_BUTTON_CONFIRM                10018
#define OC_CREATEUNIT_BUTTON_AUTOGEN_CLASSNAME      10019
#define OC_CREATEUNIT_INSTRUCTIONS                  10020

#define OC_GROUPEDITOR_FACTIONS_LIST                11008
#define OC_GROUPEDITOR_BUTTON_BIG_ONE               11009
#define OC_GROUPEDITOR_BUTTON_BIG_TWO               11010
#define OC_GROUPEDITOR_BUTTON_BIG_THREE             11011
#define OC_GROUPEDITOR_ASSETS_INPUT_CATEGORY        11012
#define OC_GROUPEDITOR_ASSETS_LIST_UNITS            11013
#define OC_GROUPEDITOR_ASSETS_BUTTON_ONE            11014
#define OC_GROUPEDITOR_ASSETS_BUTTON_TWO            11015
#define OC_GROUPEDITOR_ASSETS_BUTTON_THREE          11016
#define OC_GROUPEDITOR_GROUPS_INPUT_CATEGORY        11017
#define OC_GROUPEDITOR_GROUPS_LIST_GROUPS           11018
#define OC_GROUPEDITOR_GROUPS_BUTTON_ONE            11019
#define OC_GROUPEDITOR_GROUPS_BUTTON_TWO            11020
#define OC_GROUPEDITOR_GROUPS_BUTTON_THREE          11021
#define OC_GROUPEDITOR_SELECTEDGROUP_HEADER         11007
#define OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS     11022
#define OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_ONE     11023
#define OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO     11024
#define OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE   11025
#define OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR    11026

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
        [_state,"unitEditor_selectedUnit", ""] call ALiVE_fnc_hashSet;

        [_state,"groupEditor_selectedFaction", ""] call ALiVE_fnc_hashSet;
        [_state,"groupEditor_selectedGroupCategory", ""] call ALiVE_fnc_hashSet;
        [_state,"groupEditor_selectedGroup", ""] call ALiVE_fnc_hashSet;

        MOD(orbatCreator) = _logic;

        [_logic,"start"] spawn MAINCLASS;

    };

    case "start": {

        waitUntil {time > 0 && {!isnull player} && {!isnil "ALiVE_STATIC_DATA_LOADED"}};

        [_logic,"openInterface", "ORBAT_Viewer"] call MAINCLASS;
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

    case "onAction": {

        _args params ["_operation","_args"];

        switch (_operation) do {

            case "openInterface": {
                [_logic,_operation,_args] spawn MAINCLASS;
            };

            default {[_logic,_operation,_args] call MAINCLASS};

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

            case "Create_Unit": {

                createDialog "ALiVE_orbatCreator_interface_createUnit";

            };

            case "Unit_Editor_Edit_Properties": {

                createDialog "ALiVE_orbatCreator_interface_editUnit";

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
        private _state = [_logic,"state"] call MAINCLASS;

        switch (_interface) do {

            case "ORBAT_Viewer": {

                private ["_faction","_factionConfig","_factionSide","_factionName","_index"];

                private _display = findDisplay OC_DISPLAY_ORBAT;
                _display displayAddEventHandler ["unload", "['onUnload', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionList = OC_getControl( OC_DISPLAY_ORBAT , OC_ORBAT_FACTIONS_LIST );
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

                private _button1 = OC_getControl( OC_DISPLAY_ORBAT , OC_ORBAT_BUTTON_BIG_ONE );
                _button1 ctrlSetText "Unit Editor";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl( OC_DISPLAY_ORBAT , OC_ORBAT_BUTTON_BIG_TWO );
                _button2 ctrlSetText "Group Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl( OC_DISPLAY_ORBAT , OC_ORBAT_BUTTON_BIG_THREE );
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

            };

            case "Unit_Editor": {

                private _display = findDisplay OC_DISPLAY_UNITEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init class list

                private _classList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
                _classList ctrlSetEventHandler ["lbSelChanged","['onUnitEditorUnitListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_FACTIONS_LIST );
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

                _factionList ctrlSetEventHandler ["lbSelChanged","['onUnitEditorFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // init buttons

                private _button1 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_BUTTON_BIG_ONE );
                _button1 ctrlSetText "ORBAT Viewer";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_BUTTON_BIG_TWO );
                _button2 ctrlSetText "Group Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_BUTTON_BIG_THREE );
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetTooltip "Export selected units to clipboard";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

                // init class list

                private _classList_button1 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_ONE );
                _classList_button1 ctrlSetText "New";
                _classList_button1 ctrlSetTooltip "Create new unit for selected faction";
                _classList_button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Create_Unit'] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button1 ctrlShow true;

                private _classList_button2 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_TWO );
                _classList_button2 ctrlSetText "Edit Loadout";
                _classList_button2 ctrlSetTooltip "Edit selected unit in the arsenal";
                _classList_button2 ctrlSetEventHandler ["MouseButtonDown","['onUnitEditorEditLoadoutClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button2 ctrlShow true;
                _classList_button2 ctrlEnable false;

                private _classList_button3 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_THREE );
                _classList_button3 ctrlSetText "Edit Properties";
                _classList_button3 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Unit_Editor_Edit_Properties'] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button3 ctrlShow true;
                _classList_button3 ctrlEnable false;

                private _classList_button4 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR );
                _classList_button4 ctrlSetText "Delete";
                _classList_button4 ctrlSetTooltip "Delete selected unit";
                _classList_button4 ctrlSetEventHandler ["MouseButtonDown","['unitEditorDeleteClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button4 ctrlShow true;

                // create gray background and camera

                [_logic,"enableUnitEditorBackground", true] call MAINCLASS;

            };

            case "Create_Unit": {

                private ["_sideNum","_sideText","_sideTextLong","_index"];

                private _state = [_logic,"state"] call MAINCLASS;

                // get faction selected in unit editor

                private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
                private _selectedFaction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
                private _selectedFactionData = [_factions,_selectedFaction] call ALiVE_fnc_hashGet;
                private _selectedFactionSide = [_selectedFactionData,"side"] call ALiVE_fnc_hashGet;

                // lists must init in "reverse" order for events to properly fire on opening

                // init unit type class list

                private _classList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
                _classList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeClassChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction lists

                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
                _unitTypeFactionList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init side lists

                private _sideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_SIDE );
                _sideList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _unitTypeSideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_SIDE );
                _unitTypeSideList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                for "_i" from 0 to 2 do {
                    _sideNum = _i;
                    _sideText = [_sideNum] call ALiVE_fnc_sideNumberToText;
                    _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;

                    _index = _unitTypeSideList lbAdd _sideTextLong;
                    _unitTypeSideList lbSetData [_index,str _sideNum];

                    _index = _sideList lbAdd _sideTextLong;
                    _sideList lbSetData [_index,str _sideNum];

                    if (_sideNum == _selectedFactionSide) then {
                        _unitTypeSideList lbSetCurSel _i;
                        _sideList lbSetCurSel _i;
                    };
                };

                private _selectedFaction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
                private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_FACTION );
                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );

                [_factionList,_selectedFaction] call ALiVE_fnc_listSelectData;
                [_unitTypeFactionList,_selectedFaction] call ALiVE_fnc_listSelectData;

                // init buttons

                private _buttonOK = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CONFIRM );
                _buttonOK ctrlSetEventHandler ["MouseButtonDown","['onCreateUnitConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonCancel = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CANCEL );
                _buttonCancel ctrlSetEventHandler ["MouseButtonDown","['onCreateUnitCancelClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonAutogen = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogen ctrlSetEventHandler ["MouseButtonDown","['onCreateUnitAutogenerateClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            };

            case "Unit_Editor_Edit_Properties": {

                private [
                    "_sideNum","_sideText","_sideTextLong","_index","_indexFaction",
                    "_unitParentSide","_unitParentFaction","_indexUnit"
                ];

                // get selected unit data

                private _state = [_logic,"state"] call MAINCLASS;
                private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
                private _selectedUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
                private _selectedUnitData = [_customUnits,_selectedUnit] call ALiVE_fnc_hashGet;

                private _unitSide = [_selectedUnitData,"side"] call ALiVE_fnc_hashGet;
                private _unitFaction = [_selectedUnitData,"faction"] call ALiVE_fnc_hashGet;
                private _unitParent = [_selectedUnitData,"inheritsFrom"] call ALiVE_fnc_hashGet;
                private _unitDisplayName = [_selectedUnitData,"displayName"] call ALiVE_fnc_hashGet;
                private _unitConfigName = [_selectedUnitData,"configName"] call ALiVE_fnc_hashGet;

                // match input fields to unit properties

                private _displayNameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_DISPLAYNAME );
                private _classnameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_CLASSNAME );

                _displayNameInput ctrlSetText _unitDisplayName;
                _classnameInput ctrlSetText _unitConfigName;

                // lists must init in "reverse" order for events to properly fire on opening

                // init unit type class list

                private _classList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
                _classList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeClassChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init side / faction lists

                private _sideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_SIDE );
                _sideList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                for "_i" from 0 to 2 do {
                    _sideNum = _i;
                    _sideText = [_sideNum] call ALiVE_fnc_sideNumberToText;
                    _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;

                    _index = _sideList lbAdd _sideTextLong;
                    _sideList lbSetData [_index,str _sideNum];

                    if (_sideNum == _unitSide) then {
                        _sideList lbSetCurSel _i;
                    };
                };

                private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_FACTION );
                [_factionList,_unitFaction] call ALiVE_fnc_listSelectData;

                // init unit type side / faction lists

                private _unitTypeSideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_SIDE );
                _unitTypeSideList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
                _unitTypeFactionList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // get parent unit side / faction

                private _unitParentData = [_logic,"getCustomUnit", _unitParent] call MAINCLASS;

                if (isnil "_unitParentData") then {
                    _unitParentData = configFile >> "CfgVehicles" >> _unitParent;
                    _unitParentSide = getNumber(_unitParentData >> "side");
                    _unitParentFaction = getText (_unitParentData >> "faction");
                } else {
                    _unitParentSide = [_unitParentData,"side"] call ALiVE_fnc_hashGet;
                    _unitParentFaction = [_unitParentData,"faction"] call ALiVE_fnc_hashGet;
                };

                for "_i" from 0 to 2 do {
                    _sideNum = _i;
                    _sideText = [_sideNum] call ALiVE_fnc_sideNumberToText;
                    _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;

                    _index = _unitTypeSideList lbAdd _sideTextLong;
                    _unitTypeSideList lbSetData [_index,str _sideNum];

                    if (_sideNum == _unitParentSide) then {
                        _unitTypeSideList lbSetCurSel _i;
                    };
                };

                [_logic,"displaySideFactionsInList", [_unitTypeFactionList,_unitParentSide]] call MAINCLASS;

                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
                [_unitTypeFactionList,_unitParentFaction] call ALiVE_fnc_listSelectData;

                // init classlist

                private _classList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
                private _children = [_logic,"getCustomUnitChildren", _selectedUnit] call MAINCLASS;

                // prevent self inheritence

                private _indicesToDelete = [];
                for "_i" from 0 to (lbSize _classList - 1) do {
                    _indexUnit = _classList lbData _i;

                    if (_indexUnit == _selectedUnit || {_indexUnit in _children}) then {
                        _indicesToDelete pushback _i;
                    };
                };

                {
                    _classList lbDelete (_x - _forEachIndex); // make sure the index stays accurate after deleting indices
                } foreach _indicesToDelete;

                [_classList,_unitParent] call ALiVE_fnc_listSelectData;

                // init buttons

                private _buttonOK = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CONFIRM );
                _buttonOK ctrlSetEventHandler ["MouseButtonDown","['onEditUnitConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonCancel = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CANCEL );
                _buttonCancel ctrlSetEventHandler ["MouseButtonDown","['onEditUnitCancelClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonAutogen = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogen ctrlSetEventHandler ["MouseButtonDown","['onCreateUnitAutogenerateClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            };

            case "Group_Editor": {

                private _display = findDisplay OC_DISPLAY_GROUPEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init buttons

                private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_BUTTON_BIG_ONE );
                _button1 ctrlSetText "ORBAT Viewer";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_BUTTON_BIG_TWO );
                _button2 ctrlSetText "Unit Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_BUTTON_BIG_THREE );
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetTooltip "Export selected groups to clipboard";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

                // init group list

                private _groupCategoryList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_INPUT_CATEGORY );
                _groupCategoryList ctrlSetEventHandler ["lbSelChanged","['onGroupEditorGroupCategorySelected', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupCategoryList ctrlShow true;

                private _groupsList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
                _groupsList ctrlSetEventHandler ["lbSelChanged","['onGroupEditorGroupSelected', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsList ctrlShow true;

                private _groupsButton1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_ONE );
                _groupsButton1 ctrlSetText "New";
                _groupsButton1 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorGroupsNewClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsButton1 ctrlShow false;

                private _groupsButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_TWO );
                _groupsButton2 ctrlSetText "Edit";
                _groupsButton2 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorGroupsEditClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsButton2 ctrlShow false;

                private _groupsButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_THREE );
                _groupsButton3 ctrlSetText "Delete";
                _groupsButton3 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorGroupsDeleteClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsButton3 ctrlShow false;

                // init asset list

                private _assetButton1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_ONE );
                _assetButton1 ctrlSetText "Add to Selected Group";
                _assetButton1 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorAssetAddClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetButton1 ctrlShow false;

                private _assetButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_TWO );
                _assetButton2 ctrlSetText "Open in Unit Editor";
                _assetButton2 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorAssetEditClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetButton2 ctrlShow false;

                private _assetButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_THREE );
                _assetButton3 ctrlSetText "";
                //_assetButton3 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorAssetClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetButton3 ctrlShow false;

                // init selected group list

                private _selectedGroupUnitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
                _selectedGroupUnitList ctrlSetEventHandler ["lbSelChanged","['onGroupEditorSelectedGroupUnitChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _selectedGroupButton1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_ONE );
                _selectedGroupButton1 ctrlSetText "Edit Group";
                _selectedGroupButton1 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorSelectedGroupClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupButton1 ctrlShow false;

                private _selectedGroupButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO );
                _selectedGroupButton2 ctrlSetText "";
                _selectedGroupButton2 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorSelectedGroupClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupButton2 ctrlShow false;

                private _selectedGroupButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE );
                _selectedGroupButton3 ctrlSetText "Open Unit in Unit Editor";
                _selectedGroupButton3 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorSelectedGroupClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupButton3 ctrlShow false;

                private _selectedGroupButton4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR );
                _selectedGroupButton4 ctrlSetText "Remove Unit From Group";
                _selectedGroupButton4 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorSelectedGroupClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupButton4 ctrlShow false;

                // init faction list
                // init last for events to fire properly on opening

                private _factionList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_FACTIONS_LIST );
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

                _factionList ctrlSetEventHandler ["lbSelChanged","['onGroupEditorFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // create gray background and camera

                [_logic,"enableUnitEditorBackground", true] call MAINCLASS;

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

                [_state,"unitEditor_interfaceBackground", objNull] call ALiVE_fnc_hashSet;
                [_state,"unitEditor_interfaceCamera", objNull] call ALiVE_fnc_hashSet;
                [_state,"unitEditor_activeUnitPosition", [0,0,0]] call ALiVE_fnc_hashSet;
                [_state,"unitEditor_activeUnitObject", objNull] call ALiVE_fnc_hashSet;
                [_state,"unitEditor_selectedFaction", ""] call ALiVE_fnc_hashSet;
                [_state,"unitEditor_selectedUnit", ""] call ALiVE_fnc_hashSet;

            };

            case "Create_Unit": {



            };

            case "Unit_Editor_Edit_Properties": {



            };

            case "Group_Editor": {

                [_logic,"enableUnitEditorBackground", false] call MAINCLASS;

                [_state,"groupEditor_selectedFaction", ""] call ALiVE_fnc_hashSet;
                [_state,"groupEditor_selectedGroupCategory", ""] call ALiVE_fnc_hashSet;
                [_state,"groupEditor_selectedGroup", ""] call ALiVE_fnc_hashSet;

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
                        [_groupHash,"configName", _groupConfigName] call ALiVE_fnc_hashSet;
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

        {
            if !(_x in (_ALiVE_compatibleGroups select 1)) then {
                [_ALiVE_compatibleGroups,_x, +_tmpHash] call ALiVE_fnc_hashSet;
            };
        } foreach ALIVE_COMPATIBLE_GROUP_CATEGORIES;

    };

    case "convertSideToNum": {

        switch (typename _args) do {
            case "OBJECT": {_result = [_args] call ALiVE_fnc_sideObjectToNumber};
            case "STRING": {_result = [_args] call ALiVE_fnc_sideTextToNumber};
            default {_result = _args};
        };

    };

    case "getFactionsBySide": {

        private _side = _args;
        _side = [_logic,"convertSideToNum", _side] call MAINCLASS;

        _result = [];

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        {
            if (([_x,"side"] call ALiVE_fnc_hashGet) == _side) then {
                _result pushback _x;
            };
        } foreach (_factions select 2);

    };

    case "getCustomUnitsByFaction": {

        private _faction = _args;

        _result = [];

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        {
            if (([_x,"faction"] call ALiVE_fnc_hashGet) == _faction) then {
                _result pushback _x;
            };
        } foreach (_customUnits select 2);

    };

    case "getCustomUnitsBySide": {

        private _side = _args;

        _result = [];

        private _sideFactions = [_logic,"getFactionsBySide", _side] call MAINCLASS;

        {
            _factionConfigName = [_x,"configName"] call ALiVE_fnc_hashGet;
            _factionUnits = [_logic,"getCustomUnitsByFaction", _factionConfigName] call MAINCLASS;

            _result append _factionUnits;
        } foreach (_sideFactions select 2);

    };

    case "getCustomUnit": {

        private _classname = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        _result = [_customUnits,_classname] call ALiVE_fnc_hashGet;

    };

    case "getCustomUnitChildren": {

        private ["_entryParent","_entryClass","_childrenFound","_entries"];

        private _classname = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _allEntries = [];
        {
            _entryParent = [_x,"inheritsFrom"] call ALiVE_fnc_hashGet;
            _entryClass = [_x,"configName"] call ALiVE_fnc_hashGet;

            if (_entryClass != _classname) then {
                _allEntries pushback [_entryParent,_entryClass];
            };
        } foreach (_customUnits select 2);

        _result = [];
        private _exit = false;

        while {!_exit} do {
            _childrenFound = 0;
            _entries = [];

            {
                _x params ["_parentClass","_class"];

                if (_parentClass == _classname || {_parentClass in _result}) then {
                    _result pushback _class;
                    _childrenFound = _childrenFound + 1;
                } else {
                    _entries pushback _x;
                };
            } foreach _allEntries;

            _allEntries = _entries;

            if (_childrenFound == 0) then {
                _exit = true;
            };
        };

    };


    // orbat viewer


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

        private _groupName = [_groupHash,"name"] call ALiVE_fnc_hashGet;
        private _groupUnits = [_groupHash,"units"] call ALiVE_fnc_hashGet;

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

        private _unitSide = [_unitHash,"side"] call ALiVE_fnc_hashGet;
        private _unitVehicle = [_unitHash,"vehicle"] call ALiVE_fnc_hashGet;
        private _unitRank = [_unitHash,"rank"] call ALiVE_fnc_hashGet;
        private _unitPosition = [_unitHash,"position"] call ALiVE_fnc_hashGet;

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

    case "listAddDataSourcesArray": {

        private ["_index"];

        _args params ["_list","_dataSource"];

        {
            _x params ["_text","_data","_image"];

            _index = _tree lbAdd _text;
            _tree tvSetData [_index,_data];
            _tree tvSetPicture [_index,_image];
        } foreach _dataSource;

    };

    case "onORBATFactionListChanged": {

        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData(_list);

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;

        private _tree = OC_getControl( OC_DISPLAY_ORBAT , OC_ORBAT_GROUPS_TREE );
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

    case "onUnitEditorFactionChanged": {

        private ["_index"];
        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData(_list);

        [_logic,"unitEditorDisplayFactionUnits", _faction] call MAINCLASS;

    };

    case "unitEditorDisplayFactionUnits": {

        private _faction = _args;

        if (_faction isEqualType "") then {

            private _state = [_logic,"state"] call MAINCLASS;
            private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
            private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

            private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
            deleteVehicle _activeUnit;

            // get custom units for faction

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

            // populate list

            private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
            lbClear _unitList;

            {
                _index = _unitList lbAdd (_x select 0);
                _unitList lbSetData [_index, _x select 1];
            } foreach _units;

            [_state,"unitEditor_selectedFaction", _faction] call ALiVE_fnc_hashSet;

        };

    };

    case "onUnitEditorUnitListChanged": {

        private ["_customUnitParentEntry","_customUnitParent"];
        _args params ["_list","_index"];

        private _selectedUnitClassname = OC_ctrlGetSelData(_list);

        [_logic,"unitEditorDisplayVehicle", _selectedUnitClassname] call MAINCLASS;

    };

    case "getRealUnitClass": {

        private _unit = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _found = false;

        if (_unit isEqualType "") then {
            if (isClass (configFile >> "CfgVehicles" >> _unit)) exitWith {
                _result = _unit;
                _found = true;
            };

            _unit = [_customUnits,_unit] call ALiVE_fnc_hashGet;
        };

        if (!_found) then {
            private _unitParent = [_unit,"inheritsFrom"] call ALiVE_fnc_hashGet;
            private _configPath = configFile >> "CfgVehicles" >> _unitParent;

            while {!isClass _configPath} do {
                __unitParentEntry = [_customUnits,_unitParent] call ALiVE_fnc_hashGet;
                _unitParent = [__unitParentEntry,"inheritsFrom"] call ALiVE_fnc_hashGet;
                _configPath = configFile >> "CfgVehicles" >> _unitParent;

            };

            _result = _unitParent;
        };

    };

    case "unitEditorDisplayVehicle": {

        private _vehicle = _args;

        private _buttonEditLoadout = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_TWO );
        private _buttonEditProperties = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_THREE );

        private _state = [_logic,"state"] call MAINCLASS;
        private _cam = [_state,"unitEditor_interfaceCamera"] call ALiVE_fnc_hashGet;
        private _pos = [_state,"unitEditor_activeUnitPosition"] call ALiVE_fnc_hashGet;

        // get unit data

        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _customUnit = [_customUnits,_selectedUnitClassname] call ALiVE_fnc_hashGet;
        private _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;
        private _customUnitLoadout = [_customUnit,"loadout"] call ALiVE_fnc_hashGet;

        private _customUnitSide = [_customUnit,"side"] call ALiVE_fnc_hashGet;
        private _customSideText = [_customUnitSide] call ALiVE_fnc_sideNumberToText;
        private _customUnitSideObject = [_customSideText] call ALiVE_fnc_sideTextToObject;

        // if custom unit parent is another custom unit
        // keep going up the inheritance tree until you find a real unit

        _customUnitConfigName = [_logic,"getRealUnitClass", _customUnitConfigName] call MAINCLASS;

        // delete existing vehicle

        private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
        deleteVehicle _activeUnit;

        // spawn vehicle

        if (_customUnitConfigName isKindOf "Man") then {
            _activeUnit = (createGroup _customUnitSideObject) createUnit [_customUnitConfigName, [0,0,0], [], 0, "NONE"];
            _activeUnit setPosASL _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;
            _activeUnit switchMove (animationState player);
            _activeUnit switchAction "playerstand";

            _activeUnit setUnitLoadout _customUnitLoadout;
            _cam camSetRelPos [-0.05,1,0.15];
            _cam camSetFov 0.35;

            _buttonEditLoadout ctrlEnable true;
        } else {
            _activeUnit = _customUnitConfigName createVehicle [0,0,0];
            _activeUnit setPosASL _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;

            _cam camSetRelPos [0, (sizeOf _customUnitConfigName) * 0.65, (sizeOf _customUnitConfigName) * 0.1];
            _cam camSetFov 0.5;

            _buttonEditLoadout ctrlEnable false;
        };

        _cam camCommit 0;
        _buttonEditProperties ctrlEnable true;

        [_state,"unitEditor_activeUnitObject", _activeUnit] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_selectedUnit", _selectedUnitClassname] call ALiVE_fnc_hashSet;

    };

    case "onUnitEditorEditLoadoutClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

        if (_activeUnit isKindOf "Man") then {

            // hide buttons

            for "_i" from 9001 to 9016 do {
                ctrlShow [_i, false]; // hardcoded idca for sanity
            };

            // open interface

            ["Open",[true,objNull,_activeUnit]] call BIS_fnc_arsenal;

            [] spawn {
                waitUntil {!isNull (findDisplay -1)};
                disableSerialization;

                // a3\addons\ui_f\hpp\defineResinclDesign

                // set button actions

                private _closeButton = findDisplay -1 displayCtrl 44448;
                _closeButton ctrlSetText "Cancel Changes";
                (ctrlParent _closeButton) displayAddEventHandler ["Unload", "['onUnitEditorArsenalClosed', false] spawn ALiVE_fnc_orbatCreatorOnAction"];

                _ctrlButtonOK = findDisplay -1 displayctrl 44346;
                _ctrlButtonOK ctrlShow true;
                _ctrlButtonOK ctrlEnable true;
                _ctrlButtonOK ctrlSetText "Save Changes";
                _ctrlButtonOK buttonSetAction "['onUnitEditorArsenalClosed', true] spawn ALiVE_fnc_orbatCreatorOnAction";

                // hide unneeded buttons

                _ctrlButtonSave = findDisplay -1 displayctrl 44146;
                _ctrlButtonSave ctrlEnable false;

                _ctrlButtonLoad = findDisplay -1 displayctrl 44147;
                _ctrlButtonLoad ctrlEnable false;

                _ctrlButtonExport = findDisplay -1 displayctrl 44148;
                _ctrlButtonExport ctrlEnable false;

                _ctrlButtonImportant = findDisplay -1 displayctrl 44149;
                _ctrlButtonImportant ctrlEnable false;

            };

        };

    };

    case "onUnitEditorArsenalClosed": {

        private _saveChanges = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        // reset camera

        if (_saveChanges) then {
            private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
            private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

            private _selectedUnitClassname = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
            private _selectedUnitData = [_customUnits,_selectedUnitClassname] call ALiVE_fnc_hashGet;

            private _newLoadout = getUnitLoadout _activeUnit;
            [_selectedUnitData,"loadout", _newLoadout] call ALiVE_fnc_hashSet;
        };

        // reopen interface
        // thanks to BIS Arsenal for closing my dialog automatically

        closeDialog 0;
        [_logic,"openInterface", "Unit_Editor"] call MAINCLASS;

        // reselect unit

        private _selectedUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;

        _selectedUnit spawn {
            sleep 0.1; // delay needed
            [ALiVE_orbatCreator,"unitEditorSelectUnit", _this] call MAINCLASS;
        };

    };

    case "unitEditorSelectUnit": {

        private _unitClassname = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        // get unit data

        private _customUnit = [_customUnits,_unitClassname] call ALiVE_fnc_hashGet;

        if (isnil "_customUnit") exitWith {};

        private _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

        // get faction index to select

        private _factionList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_FACTIONS_LIST );
        [_factionList,_customUnitFaction] call ALiVE_fnc_listSelectData;

        // get unit classname to select

        private _classList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
        [_classList,_unitClassname, true] call ALiVE_fnc_listSelectData;

    };

    case "unitEditorDeleteClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );

        // get selected units

        private _selectedIndices = lbSelection _unitList;
        private _selectedUnits = [];

        {
            _selectedUnits pushback (_unitList lbData _x);
        } foreach _selectedIndices;

        // delete selected units

        {
            [_customUnits,_x] call ALiVE_fnc_hashRem;
        } foreach _selectedUnits;

        // rebuild list

        private _faction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        [_logic,"unitEditorDisplayFactionUnits", _faction] call MAINCLASS;

        // if no entries remain in list
        // delete active unit

        if (lbSize _unitList == 0) then {
            private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
            deleteVehicle _activeUnit;
        };

    };


    // unit editor - create unit


    case "displaySideFactionsInList": {

        private ["_factionDisplayName","_factionConfigName","_index"];

        _args params ["_list","_side"];

        private _factions = [_logic,"getFactionsBySide", _side] call MAINCLASS;
        lbClear _list;

        {
            _factionDisplayName = [_x,"displayName"] call ALiVE_fnC_hashGet;
            _factionConfigName = [_x,"configName"] call ALiVE_fnc_hashGet;

            _index = _list lbAdd _factionDisplayName;
            _list lbSetData [_index, _factionConfigName];
        } foreach _factions;

        if (lbSize _list > 0) then {
            _list lbSetCurSel 0;
        };

    };

    case "onCreateUnitSideChanged": {

        // a side has been selected
        // display all factions belonging to side

        _args params ["_list","_index"];

        private _sideNum = OC_ctrlGetSelData(_list);
        _sideNum = call compile _sideNum;

        private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_FACTION );
        [_logic,"displaySideFactionsInList", [_factionList,_sideNum]] call MAINCLASS;

    };

    case "onCreateUnitUnitTypeSideChanged": {

        // a side has been selected
        // display all factions belonging to side

        private ["_faction","_side","_factionDisplayName","_factionConfigName"];
        _args params ["_list","_index"];

        private _sideNum = OC_ctrlGetSelData(_list);
        _sideNum = call compile _sideNum;

        private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
        [_logic,"displaySideFactionsInList", [_factionList,_sideNum]] call MAINCLASS;

    };

    case "onCreateUnitUnitTypeFactionChanged": {

        // a faction has been selected
        // display all units belonging to faction

        private ["_customUnit","_customUnitFaction","_customUnitDisplayName","_customUnitConfigName"];
        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData(_list);

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _assetsToDisplay = [];

        // get custom units for faction

        private _factionCustomUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;

        {
            _unitDisplayName = [_x,"displayName"] call ALiVE_fnc_hashGet;
            _unitConfigName = [_x,"configName"] call ALiVE_fnc_hashGet;

            _assetsToDisplay pushback [_unitDisplayName,_unitConfigName];
        } foreach _factionCustomUnits;

        // get faction assets

        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;

        private _factionAssetDisplayNames = _factionAssets select 1;
        private _factionAssetConfigNames = _factionAssets select 2;

        for "_i" from 0 to (count _factionAssetDisplayNames - 1) do {
            _assetsToDisplay pushback [_factionAssetDisplayNames select _i, _factionAssetConfigNames select _i];
        };

        // populate list

        private _classList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
        lbClear _classList;

        {
            _x params ["_displayName","_configName"];

            _index = _classList lbAdd _displayName;
            _classList lbSetData [_index, _configName];
        } foreach _assetsToDisplay;

        private _buttonOK = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CONFIRM );
        _buttonOK ctrlEnable false;

    };

    case "onCreateUnitUnitTypeClassChanged": {

        private _buttonOK = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CONFIRM );
        _buttonOK ctrlEnable true;

    };

    case "onCreateUnitAutogenerateClassnameClicked": {

        private _side = call compile OC_getSelData( OC_CREATEUNIT_INPUT_SIDE );
        private _faction = OC_getSelData( OC_CREATEUNIT_INPUT_FACTION );

        // parse display name to get classname

        private _inputDisplayName = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_DISPLAYNAME );
        private _displayName = ctrlText _inputDisplayName;

        private _generatedClassname = [_logic,"generateClassname", [_side,_faction,_displayName]] call MAINCLASS;

        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_CLASSNAME );
        _inputClassname ctrlSetText _generatedClassname;

    };

    case "generateClassname": {

        _args params ["_side","_faction","_displayName"];

        _side = [_logic,"convertSideToNum", _side] call MAINCLASS;
        private _sideText = [_side] call ALiVE_fnc_sideNumberToText;
        private _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;
        _sideTextLong = [_sideTextLong] call CBA_fnc_leftTrim;
        private _sidePrefix = _sideTextLong select [0,1];

        private _factionPrefix = [_faction," ",""] call CBA_fnc_replace;
        _factionPrefix = [_faction,"_",""] call CBA_fnc_replace;

        private _autogenClassname = [_logic,"displayNameToClassname", _displayName] call MAINCLASS;

        // get number postfix

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _customUnitClassnames = _customUnits select 1;

        private _postNum = 1;
        private _autogenClassnameNoNum = format ["%1_%2_%3", _sidePrefix, _factionPrefix, _autogenClassname];

        if (_postNum < 10) then {
            _autogenClassname = format ["%1_0%2", _autogenClassnameNoNum, _postNum];
        } else {
            _autogenClassname = format ["%1_%2", _autogenClassnameNoNum, _postNum];
        };

        while {_autogenClassname in _customUnitClassnames} do {
            _postNum = _postNum + 1;

            if (_postNum < 10) then {
                _autogenClassname = format ["%1_0%2", _autogenClassnameNoNum, _postNum];
            } else {
                _autogenClassname = format ["%1_%2", _autogenClassnameNoNum, _postNum];
            };
        };

        // format result

        _result = _autogenClassname

    };

    case "displayNameToClassname": {

        private _displayName = _args;
        private _displayNameArray = toArray _displayName;
        private _displayNameSize = count _displayNameArray;

        private _validChars = [
            'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
            '1','2','3','4','5','6','7','8','9','0'
        ];

        private _currIndex = 0;
        private _currString = "";
        private _classnameComponents = [];

        while {_currIndex != _displayNameSize} do {

            _nextChar = _displayNameArray select _currIndex;
            _nextChar = toLower (toString [_nextChar]);

            if (_nextChar in _validChars) then {
                _currString = _currString + _nextChar;

                // if letter is last in name, finish string

                if (_currIndex + 1 == _displayNameSize) then {
                    _classnameComponents pushback _currString;
                };
            } else {
                if (count _currString > 1) then {
                    _classnameComponents pushback _currString;
                    _currString = "";
                };
            };

            _currIndex = _currIndex + 1;

        };

        _result = "";

        {
            if (_result != "") then {
                _result = format ["%1_%2", _result, _x];
            } else {
                _result = _x;
            };
        } foreach _classnameComponents;

    };

    case "onCreateUnitConfirmClicked": {

        // validate prerequisites

        private _instructions = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INSTRUCTIONS );

        private _displayNameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_DISPLAYNAME );
        private _classnameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_CLASSNAME );
        private _displayName = ctrlText _displayNameInput;
        private _classname = ctrlText _classnameInput;

        if (_displayName == "") exitWith {_instructions ctrlSetText "Display name cannot be left blank"};
        if (_classname == "") exitWith {_instructions ctrlSetText "Class name cannot be left blank"};

        private _state = [_logic,"state"] call MAINCLASS;

        // get side/faction

        private _side = call compile OC_getSelData( OC_CREATEUNIT_INPUT_SIDE );
        private _faction = OC_getSelData( OC_CREATEUNIT_INPUT_FACTION );

        // get displayname/configname

        _classname = [_classname," ","_"] call CBA_fnc_replace;

        // get parent class

        private _parentClass = OC_getSelData( OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
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

        // close display
        // refresh unit editor custom units list

        closeDialog 0;

        private _factionList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_FACTIONS_LIST );
        _factionList lbSetCurSel (lbCurSel _factionList);

    };

    case "convertFactionConfigUnitsToCustomUnits": {

        private _faction = _args;

        if (_faction isEqualType "") then {

            private ["_asset","_assetConfig","_assetSide","_assetFaction","_assetDisplayName","_assetLoadout"];

            private _state = [_logic,"state"] call MAINCLASS;

            private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
            private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
            private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;

            private _configUnits = [_state,"configUnits"] call ALiVE_fnc_hashGet;

            {
                _asset = _x;
                _assetConfig = configFile >> "CfgVehicles" >> _asset;
                _assetSide = getNumber (_assetConfig >> "side");
                _assetFaction = getText (_assetConfig >> "faction");
                _assetDisplayName = getText (_assetConfig >> "displayName");
                _assetLoadout = getUnitLoadout _asset;

                _newUnit = [nil,"create"] call ALiVE_fnc_orbatCreatorUnit;
                [_newUnit,"init"] call ALiVE_fnc_orbatCreatorUnit;
                [_newUnit,"inheritsFrom", _asset] call ALiVE_fnc_orbatCreatorUnit;
                [_newUnit,"side", _assetSide] call ALiVE_fnc_hashSet;
                [_newUnit,"faction", _assetFaction] call ALiVE_fnc_hashSet;
                [_newUnit,"displayName", _assetDisplayName] call ALiVE_fnc_hashSet;
                [_newUnit,"configName", _asset] call ALiVE_fnc_hashSet;
                [_newUnit,"loadout", _assetLoadout] call ALiVE_fnc_hashSet;

            } foreach _factionAssets;

        };

    };

    case "onCreateUnitCancelClicked": {

        closeDialog 0;

    };


    // edit unit


    case "onEditUnitConfirmClicked": {

        // unit is being edited
        // user has clicked confirm to save changes

        private ["_parentLoadout"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _selectedUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
        private _selectedUnitData = [_customUnits,_selectedUnit] call ALiVE_fnc_hashGet;

        private _displayNameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_DISPLAYNAME );
        private _classnameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_CLASSNAME );
        private _displayName = ctrlText _displayNameInput;
        private _classname = ctrlText _classnameInput;

        private _side = call compile OC_getSelData( OC_CREATEUNIT_INPUT_SIDE );
        private _faction = OC_getSelData( OC_CREATEUNIT_INPUT_FACTION );
        private _parentClass = OC_getSelData( OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );

        private _unitSide = [_selectedUnitData,"side"] call ALiVE_fnc_hashGet;
        private _unitFaction = [_selectedUnitData,"faction"] call ALiVE_fnc_hashGet;
        private _unitParentClass = [_selectedUnitData,"inheritsFrom"] call ALiVE_fnc_hashGet;
        private _unitDisplayName = [_selectedUnitData,"displayName"] call ALiVE_fnc_hashGet;
        private _unitConfigName = [_selectedUnitData,"configName"] call ALiVE_fnc_hashGet;

        // validate prerequisites

        private _instructions = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INSTRUCTIONS );

        if (_displayName == "") exitWith {_instructions ctrlSetText "Display name cannot be left blank"};
        if (_classname == "") exitWith {_instructions ctrlSetText "Class name cannot be left blank"};

        // prerequisites verified, begin saving

        // if unit side/faction changes
        // user is responsible for correcting groups
        // Change????? or maybe log an error?????

        if (_displayName != _unitDisplayName) then {
            [_selectedUnitData,"displayName", _displayName] call ALiVE_fnc_hashSet;
        };

        if (_classname != _unitConfigName) then {
            _classname = [_classname," ","_"] call CBA_fnc_replace;

            [_selectedUnitData,"configName", _classname] call ALiVE_fnc_hashSet;
            _selectedUnit = _classname; // enables proper re-selection once menu closes

            [_customUnits,_unitConfigName] call ALiVE_fnc_hashRem;
            [_customUnits,_classname,_selectedUnitData] call ALiVE_fnc_hashSet;
        };

        if (_side != _unitSide) then {
            [_selectedUnitData,"side", _side] call ALiVE_fnc_hashSet;
        };

        if (_faction != _unitFaction) then {
            [_selectedUnitData,"faction", _faction] call ALiVE_fnc_hashSet;
        };

        if (_parentClass != _unitParentClass) then {
            [_selectedUnitData,"inheritsFrom", _parentClass] call ALiVE_fnc_hashSet;

            private _parentEntry = [_customUnits,_parentClass] call ALiVE_fnc_hashGet;

            if (!isnil "_parentEntry") then {
                _parentLoadout = [_parentEntry,"loadout"] call ALiVE_fnc_hashGet;
            } else {
                _parentLoadout = getUnitLoadout _parentClass;
            };

            [_selectedUnitData,"loadout", _parentLoadout] call ALiVE_fnc_hashSet;
        };

        closeDialog 0;

        private _selectedFaction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        [_logic,"unitEditorDisplayFactionUnits", _selectedFaction] call MAINCLASS;

        _selectedUnit spawn {
            sleep 0.1; // delay needed
            [ALiVE_orbatCreator,"unitEditorSelectUnit", _this] call MAINCLASS;
        };

    };

    case "onEditUnitCancelClicked": {

        closeDialog 0;

    };


    // group editor


    case "onGroupEditorFactionChanged": {

        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;

        [_logic,"groupEditorDisplayFactionGroupCategories", _faction] call MAINCLASS;
        [_logic,"groupEditorDisplayFactionAssets", _faction] call MAINCLASS;

    };

    case "groupEditorDisplayFactionGroupCategories": {

        private ["_index"];

        private _faction = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"groupEditor_selectedFaction", _faction] call ALiVE_fnc_hashSet;

        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionGroups = [_factionData,"groupsByCategory"] call ALiVE_fnc_hashGet;

        private _compatibleGroups = [_factionGroups,"ALiVE_compatible"] call ALiVE_fnc_hashGet;
        private _incompatibleGroups = [_factionGroups,"ALiVE_incompatible"] call ALiVE_fnc_hashGet;

        // add categories to list

        private _categoryList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_INPUT_CATEGORY );
        lbClear _categoryList;

        {
            _index = _categoryList lbAdd _x;
            _categoryList lbSetData [_index,_x];
        } foreach ((_compatibleGroups select 1) + (_incompatibleGroups select 1));

        if (lbSize _categoryList > 0) then {
            _categoryList lbSetCurSel 0;
        };

    };

    case "groupEditorDisplayFactionAssets": {

        private _faction = _args;

    };

    case "onGroupEditorGroupCategorySelected": {

        _args params ["_list","_index"];

        private _groupCategory = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;

        [_logic,"groupEditorDisplayFactionGroupsInCategory", _groupCategory] call MAINCLASS;

    };

    case "groupEditorDisplayFactionGroupsInCategory": {

        private ["_group","_groupDisplayName","_groupConfigName","_index"];

        private _groupCategory = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"groupEditor_selectedGroupCategory", _groupCategory] call ALiVE_fnc_hashSet;

        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionGroups = [_factionData,"groupsByCategory"] call ALiVE_fnc_hashGet;

        private _compatibleGroupCategories = [_factionGroups,"ALiVE_compatible"] call ALiVE_fnc_hashGet;
        private _incompatibleGroupCategories = [_factionGroups,"ALiVE_incompatible"] call ALiVE_fnc_hashGet;

        private _groups = [_compatibleGroupCategories,_groupCategory] call ALiVE_fnc_hashGet;
        if (isnil "_groups") then {
            _groups = [_incompatibleGroupCategories,_groupCategory] call ALiVE_fnc_hashGet;
        };

        // reset active group list

        private _selectedGroupHeader = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_HEADER);
        _selectedGroupHeader ctrlSetText "";

        private _selectedGroupUnitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
        lbClear _selectedGroupUnitList;

        private _selectedGroupButton1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_ONE );
        _selectedGroupButton1 ctrlShow false;

        private _selectedGroupButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO );
        _selectedGroupButton2 ctrlShow false;

        private _selectedGroupButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE );
        _selectedGroupButton3 ctrlShow false;

        private _selectedGroupButton4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR );
        _selectedGroupButton4 ctrlShow false;

        // reset group list buttons

        private _groupsButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_TWO );
        _groupsButton2 ctrlEnable false;

        // add groups to list

        private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
        lbClear _groupList;

        {
            _group = _x;
            _groupDisplayName = [_group,"name"] call ALiVE_fnc_hashGet;
            _groupConfigName = [_group,"configName"] call ALiVE_fnc_hashGet;

            _index = _groupList lbAdd _groupDisplayName;
            _groupList lbSetData [_index,_groupConfigName];
        } foreach (_groups select 2);

        private _selectedGroupHeader = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_HEADER);
        _selectedGroupHeader ctrlSetText "";

        if (lbSize _groupList > 0) then {
            _groupList lbSetCurSel 0;
        };

    };

    case "onGroupEditorGroupSelected": {

        _args params ["_list","_index"];

        private _group = OC_ctrlGetSelData( _list );

        // enable buttons

        private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_ONE );
        _button1 ctrlShow true;

        private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_TWO );
        _button2 ctrlShow true;
        _button2 ctrlEnable true;

        private _button3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_THREE );
        _button3 ctrlShow true;

        [_logic,"groupEditorDisplayGroupUnits", _group] call MAINCLASS;

    };

    case "groupEditorDisplayGroupUnits": {

        private ["_unitData","_unitClass","_unitRank","_unitPosition","_unitDisplayName","_tooltip","_index"];

        private _group = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"groupEditor_selectedGroup", _group] call ALiVE_fnc_hashSet;

        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _customUnitClasses = _customUnits select 1;

        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;

        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionGroups = [_factionData,"groupsByCategory"] call ALiVE_fnc_hashGet;

        private _compatibleGroups = [_factionGroups,"ALiVE_compatible"] call ALiVE_fnc_hashGet;
        private _incompatibleGroups = [_factionGroups,"ALiVE_incompatible"] call ALiVE_fnc_hashGet;

        private _groupCategory = [_compatibleGroups,_category] call ALiVE_fnc_hashGet;
        if (isnil "_groupCategory") then {
            _groupCategory = [_incompatibleGroups,_category] call ALiVE_fnc_hashGet;
        };

        private _groupData = [_groupCategory,_group] call ALiVE_fnc_hashGet;
        private _groupName = [_groupData,"name"] call ALiVE_fnc_hashGet;
        private _groupUnits = [_groupData,"units"] call ALiVE_fnc_hashGet;

        // set header

        private _selectedGroupHeader = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_HEADER);
        _selectedGroupHeader ctrlSetText _groupName;
        _selectedGroupHeader ctrlShow true;

        // set units to list

        private _selectedGroupUnitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
        lbClear _selectedGroupUnitList;
        _selectedGroupUnitList ctrlShow true;

        {
            _unitData = _x;
            _unitConfigName = [_unitData,"vehicle"] call ALiVE_fnc_hashGet;
            _unitRank = [_unitData,"rank"] call ALiVE_fnc_hashGet;
            _unitPosition = [_unitData,"position"] call ALiVE_fnc_hashGet;

            if (_unitConfigName in _customUnitClasses) then {
                _unit = [_customUnitClasses,_unitConfigName] call ALiVE_fnc_hashGet;
                _unitDisplayName = [_unit,"displayName"] call ALiVE_fnc_hashGet;
            } else {
                _unitDisplayName = getText (configFile >> "CfgVehicles" >> _unitConfigName >> "displayName");
            };

            _tooltip = format ["Rank: %1\nPosition: %2\nClass: %3", _unitRank, _unitPosition, _unitConfigName];

            _index = _selectedGroupUnitList lbAdd _unitDisplayName;
            _selectedGroupUnitList lbSetData [_index,_unitConfigName];
            _selectedGroupUnitList lbSetTooltip [_index,_tooltip];
        } foreach _groupUnits;

        // init buttons

        private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_ONE );
        _button1 ctrlShow true;

        //private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO );
        //_button2 ctrlShow true;

    };

    case "onGroupEditorSelectedGroupUnitChanged": {

        _args params ["_list","_index"];

        private _unit = OC_ctrlGetSelData( _list );

        // enable buttons

        private _button3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE );
        _button3 ctrlShow true;

        private _button4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR );
        _button4 ctrlShow true;

        // TODO: unified approach to spawning units
        // and handling camera movement

        // spawn selected unit onto screen

    };

    case "onGroupEditorGroupsNewClicked": {



    };

    case "onGroupEditorGroupsEditClicked": {



    };

    case "onGroupEditorGroupsDeleteClicked": {



    };

    case "onGroupEditorAssetAddClicked": {



    };

    case "onGroupEditorAssetEditClicked": {



    };


    // config generation


    case "generateConfig": {

        private _mode = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        switch (_mode) do {

            case "Unit_Editor": {

                private _classList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
                private _selectedIndices = lbSelection _classList;
                private _selectedUnits = [];

                {
                    _selectedUnits pushback (_classList lbData _x);
                } foreach _selectedIndices;

                _result = [_logic,"exportCustomUnits", _selectedUnits] call MAINCLASS;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

        };

    };

    case "exportCustomUnits": {

        private ["_unitClass","_unit","_unitParentConfigName","_unitExportString"];

        private _unitclasses = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _forwardDeclared = [];

        _result = "";
        private _indent = "    ";
        private _newLine = toString [13,10];

        // forward declare eventhandler class for forceAdding uniforms

        _result = _result + "class EventHandlers;";
        _result = _result + _newLine + "class CBA_Extended_EventHandlers_base;";

        _result = _result + _newLine + _newLine + "class CfgVehicles {" + _newLine;

        // reorder units to maintain timely definitions

        private _unitsToExport = [];

        {
            _unitClass = _x;
            _unit = [_customUnits,_unitClass] call ALiVE_fnc_hashGet;
            _unitParentConfigName = [_unit,"inheritsFrom"] call ALiVE_fnc_hashGet;

            if (_unitParentConfigName in _unitclasses) then {
                _unitsToExport pushbackunique _unitParentConfigName;
            };

            _unitsToExport pushbackunique _unitClass;
        } foreach _unitclasses;

        // forward declare non-local inherited units

        _result = _result + _newLine;
        {
            _unit = [_customUnits,_x] call ALiVE_fnc_hashGet;
            _unitParentConfigName = [_unit,"inheritsFrom"] call ALiVE_fnc_hashGet;

            if (!(_unitParentConfigName in _forwardDeclared) && {!(_unitParentConfigName in _unitsToExport)}) then {
                _result = _result + _indent + "class " + _unitParentConfigName + ";" + _newLine;
                _forwardDeclared pushback _unitParentConfigName;
            };
        } foreach _unitsToExport;
        _result = _result + _newLine;

        // export units

        {
            _unitExportString = [_logic,"exportCustomUnit", _x] call MAINCLASS;
            _result = _result + _unitExportString + _newLine + _newLine;
        } foreach _unitsToExport;

        _result = _result + "};";

    };

    case "exportCustomUnit": {

        private ["_nextChar","_rangeEnd"];

        private _unit = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        if (_unit isEqualType "") then {
            _unit = [_customUnits,_unit] call ALiVE_fnc_hashGet;
        };

        if (isnil "_unit") exitWith {
            ["[ALiVE] Orbat Creator : exportCustomUnit - Unit is undefined, exiting. Called from %1", _fnc_scriptNameParent] call ALiVE_fnc_Dump;
        };

        // get unit data

        private _newLine = toString [13,10];
        private _indent = "    ";
        _result = "";

        // start export

        private _unitParent = [_unit,"inheritsFrom"] call ALiVE_fnc_hashGet;
        private _unitConfigName = [_unit,"configName"] call ALiVE_fnc_hashGet;
        private _unitDisplayName = [_unit,"displayName"] call ALiVE_fnc_hashGet;
        private _unitSide = [_unit,"side"] call ALiVE_fnc_hashGet;
        private _unitFaction = [_unit,"faction"] call ALiVE_fnc_hashGet;

        _result = _result + _indent + "class " + _unitConfigName;

        if (_unitParent != "") then {
            _result = _result + " : " + _unitParent;
        };

        _result = _result + " {";

        // general properties

        _result = _result + _newLine + _indent + _indent + ("author = " + str profileName + ";");
        _result = _result + _newLine + _indent + _indent + ("displayName = " + str _unitDisplayName + ";");
        _result = _result + _newLine + _indent + _indent + ("side = " + str _unitSide + ";");
        _result = _result + _newLine + _indent + _indent + ("faction = " + str _unitFaction + ";");

        // get type-specific properties

        private _unitRealConfigName = [_logic,"getRealUnitClass", _unitConfigName] call MAINCLASS;
        if (_unitRealConfigName isKindOf "Man") then {
            _result = _result + _newLine + _newLine + ([_logic,"exportCustomUnitMan", _unit] call MAINCLASS);
        } else {
            _result = _result + ([_logic,"exportCustomUnitVehicle", _unit] call MAINCLASS);
        };

        // finish export

        _result = _result + _newLine + _indent + "};";

    };

    case "exportCustomUnitMan": {

        private _unit = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        if (_unit isEqualType "") then {
            _unit = [_customUnits,_unit] call ALiVE_fnc_hashGet;
        };

        // get unit data

        private _unitConfigName = [_unit,"configName"] call ALiVE_fnc_hashGet;
        private _unitSide = [_unit,"side"] call ALiVE_fnc_hashGet;
        private _unitLoadout = [_unit,"loadout"] call ALiVE_fnc_hashGet;

        // format result

        private _newLine = toString [13,10];
        private _indent = "    ";
        private _eventHandlers = [];
        _eventHandlers pushback ("class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {}");
        _result = "";

        // loadout
        // create unit for easy data collection

        private _tmpUnitClass = [_logic,"getRealUnitClass", _unitConfigName] call MAINCLASS;
        private _tmpUnitSideText = [_unitSide] call ALiVE_fnc_sideNumberToText;
        private _tmpUnitSideObject = [_tmpUnitSideText] call ALiVE_fnc_sideTextToObject;
        private _tmpUnit = (createGroup _tmpUnitSideObject) createUnit [_tmpUnitClass, [0,0,0], [], 0, "NONE"];
        _tmpUnit setUnitLoadout _unitLoadout;

        private _tmpUnitItems = [_logic,"arrayToConfigArrayString", items _tmpUnit] call MAINCLASS;

        private _tmpUnitUniform = uniform _tmpUnit;
        private _tmpUnitBackpack = backpack _tmpUnit;
        private _tmpUnitLinkedItems = assignedItems _tmpUnit;
        private _tmpUnitVest = vest _tmpUnit;
        private _tmpUnitHeadgear = headgear _tmpUnit;
        private _tmpUnitGoggles = goggles _tmpUnit;
        if (_tmpUnitVest != "") then {_tmpUnitLinkedItems pushback _tmpUnitVest};
        if (_tmpUnitHeadgear != "") then {_tmpUnitLinkedItems pushback _tmpUnitHeadgear};
        if (_tmpUnitGoggles != "") then {_tmpUnitLinkedItems pushback _tmpUnitGoggles};

        private _tmpUnitLinkedItems = [_logic,"arrayToConfigArrayString", _tmpUnitLinkedItems] call MAINCLASS;
        private _tmpUnitMagazines = [_logic,"arrayToConfigArrayString", magazines _tmpUnit] call MAINCLASS;
        private _tmpUnitWeapons = [_logic,"arrayToConfigArrayString", weapons _tmpUnit + ["Throw","Put"]] call MAINCLASS;

        private _tmpUnitUniformWearer = getText (configFile >> "CfgWeapons" >> _tmpUnitUniform >> "ItemInfo" >> "uniformClass");
        private _tmpUnitUniformSide = getNumber (configFile >> "CfgVehicles" >> _tmpUnitUniformWearer >> "side");

        if (_tmpUnitUniformSide == _unitSide) then {
            _result = _result + _indent + _indent + ("uniformClass = " + str uniform _tmpUnit + ";") + _newLine;
        } else {
            _eventHandlers pushback ("init = " + """" + "(_this select 0) forceAddUniform " + "'" + _tmpUnitUniform + "'" + """");
        };

        _result = _result + _indent + _indent + ("backpack = " + str _tmpUnitBackpack + ";");

        _result = _result + _newLine;
        _result = _result + _newLine + _indent + _indent + ("Items[] = " + _tmpUnitItems + ";");
        _result = _result + _newLine + _indent + _indent + ("linkedItems[] = " + _tmpUnitLinkedItems + ";");
        _result = _result + _newLine + _indent + _indent + ("magazines[] = " + _tmpUnitMagazines + ";");
        _result = _result + _newLine + _indent + _indent + ("weapons[] = " + _tmpUnitWeapons + ";");

        // respawn variants

        _result = _result + _newLine;
        _result = _result + _newLine + _indent + _indent + ("respawnItems[] = " + _tmpUnitItems + ";");
        _result = _result + _newLine + _indent + _indent + ("respawnLinkedItems[] = " + _tmpUnitLinkedItems + ";");
        _result = _result + _newLine + _indent + _indent + ("respawnMagazines[] = " + _tmpUnitMagazines + ";");
        _result = _result + _newLine + _indent + _indent + ("respawnWeapons[] = " + _tmpUnitWeapons + ";");

        //_result = _result + _newLine;
        //_result = _result + _newLine + _indent + _indent + ("role = " + str "Rifleman" + ";");

        // event handlers

        _result = _result + _newLine + _newLine + _indent + _indent + ("class EventHandlers : EventHandlers {");
        {
            _result = _result + _newLine + _indent + _indent + _indent + _x + ";";
        } foreach _eventHandlers;
        _result = _result + _newLine + _indent + _indent + "};";

    };

    case "exportCustomUnitVehicle": {

        private _unit = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        if (_unit isEqualType "") then {
            _unit = [_customUnits,_unit] call ALiVE_fnc_hashGet;
        };

        // get unit data

        private _unitConfigName = [_unit,"configName"] call ALiVE_fnc_hashGet;
        private _unitSide = [_unit,"side"] call ALiVE_fnc_hashGet;

        // format result

        private _newLine = toString [13,10];
        private _indent = "    ";
        private _eventHandlers = [];
        _eventHandlers pushback ("class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {}");
        _result = "";

        // event handlers

        _result = _result + _newLine + _indent + _indent + ("class EventHandlers : EventHandlers {");
        {
            _result = _result + _newLine + _indent + _indent + _indent + _x + ";";
        } foreach _eventHandlers;
        _result = _result + _newLine + _indent + _indent + "};";

    };

    case "arrayToConfigArrayString": {

        private _array = _args;
        _result = "{";

        {
            if (_forEachIndex > 0) then {
                _result = _result + ", " + str _x + " ";
            } else {
                _result = _result + " " + str _x + " ";
            };
        } foreach _array;

        _result = _result + "}";

    };

};

TRACE_1("Orbat Creator - output", _result);

if (!isnil "_result") then {_result} else {nil};