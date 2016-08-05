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

#define OC_DISPLAY_FACTIONEDITOR                    8000
#define OC_DISPLAY_UNITEDITOR                       9000
#define OC_DISPLAY_CREATEUNIT                       10000
#define OC_DISPLAY_GROUPEDITOR                      11000
#define OC_DISPLAY_CREATEGROUP                      12000

// interface elements

#define OC_FACTIONEDITOR_BUTTON_BIG_ONE             8011
#define OC_FACTIONEDITOR_BUTTON_BIG_TWO             8012
#define OC_FACTIONEDITOR_BUTTON_BIG_THREE           8013
#define OC_FACTIONEDITOR_FACTIONS_LIST              8014
#define OC_FACTIONEDITOR_FACTIONS_BUTTON_ONE        8016
#define OC_FACTIONEDITOR_FACTIONS_BUTTON_TWO        8017
#define OC_FACTIONEDITOR_FACTIONS_BUTTON_THREE      8018
#define OC_FACTIONEDITOR_INPUT_SIDE                 8019
#define OC_FACTIONEDITOR_INPUT_NAME                 8020
#define OC_FACTIONEDITOR_INPUT_CLASSNAME            8021
#define OC_FACTIONEDITOR_INPUT_FLAG                 8022
#define OC_FACTIONEDITOR_TREE_GROUPS                8015

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
#define OC_GROUPEDITOR_SELECTEDGROUP_INPUT_UNITRANK 11023
#define OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO     11024
#define OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE   11025
#define OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR    11026

#define OC_CREATEGROUP_INPUT_NAME                       12006
#define OC_CREATEGROUP_INPUT_CLASSNAME                  12007
#define OC_CREATEGROUP_INPUT_CATEGORY                   12008
#define OC_CREATEGROUP_INPUT_BUTTON_CANCEL              12010
#define OC_CREATEGROUP_INPUT_BUTTON_CONFIRM             12009
#define OC_CREATEGROUP_INSTRUCTIONS                     12011
#define OC_CREATEGROUP_INPUT_BUTTON_AUTOGEN_CLASSNAME   12012

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

                _factionAssets = [_assetsByFaction, _faction] call ALiVE_fnc_hashGet;

                // create SQF representation of faction

                _newFaction = [nil,"create"] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"init"] call ALiVE_fnc_orbatCreatorFaction;

                private _factionGroupCategories = [_newFaction,"groupCategories"] call ALiVE_fnc_hashGet;
                _factionGroupCategories = [_logic,"initFactionGroupCategories", _factionGroupCategories] call MAINCLASS;

                [_newFaction,"configName", _factionConfigName] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"displayName", _factionDisplayName] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"flag", _factionFlag] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"icon", _factionIcon] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"priority", _factionPriority] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"side", _factionSide] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"groupCategories", _factionGroupCategories] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"assets", _factionAssets] call ALiVE_fnc_orbatCreatorFaction;

                [_factions,_factionConfigName,_newFaction] call ALiVE_fnc_hashSet;
            };
        } foreach _allFactions;

        [_state,"factions", _factions] call ALiVE_fnc_hashSet;

        [_state,"factionEditor_selectedFaction", ""] call ALiVE_fnc_hashSet;

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
        [_state,"groupEditor_assetListDragTarget", ""] call ALiVE_fnc_hashSet;

        MOD(orbatCreator) = _logic;

        [_logic,"start"] spawn MAINCLASS;

    };

    case "start": {

        waitUntil {time > 0 && {!isnull player} && {!isnil "ALiVE_STATIC_DATA_LOADED"}};

        [_logic,"openInterface", "Faction_Editor"] spawn MAINCLASS;
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

            case "Faction_Editor": {

                closeDialog 0;
                sleep 0.001; // bis pls
                createDialog "ALiVE_orbatCreator_interface_factionEditor";

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

            case "Create_Group": {

                createDialog "ALiVE_orbatCreator_interface_createGroup";

            };

            case "Edit_Group": {

                createDialog "ALiVE_orbatCreator_interface_editGroup";

            };

        };

        [_logic,"onLoad", _interface] call MAINCLASS;

    };

    case "onLoad": {

        private _interface = _args;
        private _state = [_logic,"state"] call MAINCLASS;

        switch (_interface) do {

            case "Faction_Editor": {

                private [
                    "_faction","_factionDisplayName","_factionConfigName","_factionFlag",
                    "_index","_sideText","_sideTextLong","_marker","_markerClass","_markerName",
                    "_markerIcon"
                ];

                private _display = findDisplay OC_DISPLAY_FACTIONEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', 'Faction_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init side list

                private _inputSide = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_SIDE );

                {
                    _sideText = [_x] call ALiVE_fnc_sideNumberToText;
                    _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;

                    _index = _inputSide lbAdd _sideTextLong;
                    _inputSide lbSetData [_index,str _x];
                } foreach [0,1,2];

                // init flag list

                private _inputFlag = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_FLAG );

                private _markerPath = configFile >> "CfgMarkers";

                for "_i" from 0 to (count _markerPath - 1) do {
                    _marker = _markerPath select _i;

                    if (isClass _marker) then {
                        _markerClass = getText (_marker >> "markerClass");

                        if (_markerClass == "Flags") then {
                            _markerName = getText (_marker >> "name");
                            _markerIcon = getText (_marker >> "icon");

                            _index = _inputFlag lbAdd _markerName;
                            _inputFlag lbSetData [_index,_markerIcon];
                            _inputFlag lbSetPicture [_index,_markerIcon];
                        };
                    };
                };

                // init faction list

                private _factionButton1 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_BUTTON_ONE );
                _factionButton1 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorFactionNewClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionButton1 ctrlSetTooltip "Create a new faction.";
                _factionButton1 ctrlSetText "New";

                private _factionButton2 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_BUTTON_TWO );
                _factionButton2 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorFactionDeleteClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionButton2 ctrlSetTooltip "Delete selected faction   Warning: Will delete the faction, its units, and its groups.";
                _factionButton2 ctrlSetText "Delete";

                private _factionButton3 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_BUTTON_THREE );
                _factionButton3 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorFactionSaveClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionButton3 ctrlSetTooltip "Save Faction Properties";
                _factionButton3 ctrlSetText "Save";

                private _factionList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
                [_logic,"loadFactionToList", _factionList] call MAINCLASS;

                lbSort [_factionList, "ASC"];

                _factionList ctrlSetEventHandler ["LBSelChanged","['onFactionEditorFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // init buttons

                private _button1 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_BUTTON_BIG_ONE );
                _button1 ctrlSetText "Unit Editor";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_BUTTON_BIG_TWO );
                _button2 ctrlSetText "Group Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_BUTTON_BIG_THREE );
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetTooltip "Export selected faction data (Faction class, groups, and units)";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'Faction_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

            };

            case "Unit_Editor": {

                private _display = findDisplay OC_DISPLAY_UNITEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init class list

                private _classList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
                _classList ctrlSetEventHandler ["LBSelChanged","['onUnitEditorUnitListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_FACTIONS_LIST );
                [_logic,"loadFactionToList", _factionList] call MAINCLASS;

                lbSort [_factionList, "ASC"];

                _factionList ctrlSetEventHandler ["LBSelChanged","['onUnitEditorFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // init buttons

                private _button1 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_BUTTON_BIG_ONE );
                _button1 ctrlSetText "Faction Editor";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Faction_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
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
                _classList_button3 ctrlSetTooltip "Edit selected unit properties";
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

                // get faction selected in unit editor

                private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
                private _selectedFaction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
                private _selectedFactionData = [_factions,_selectedFaction] call ALiVE_fnc_hashGet;
                private _selectedFactionSide = [_selectedFactionData,"side"] call ALiVE_fnc_hashGet;

                // lists must init in "reverse" order for events to properly fire on opening

                // init unit type class list

                private _classList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
                _classList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeClassChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction lists

                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
                _unitTypeFactionList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init side lists

                private _sideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_SIDE );
                _sideList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _unitTypeSideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_SIDE );
                _unitTypeSideList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

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
                _classList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeClassChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init side / faction lists

                private _sideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_SIDE );
                _sideList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

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
                _unitTypeSideList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
                _unitTypeFactionList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

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

                private ["_index"];

                private _display = findDisplay OC_DISPLAY_GROUPEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init buttons

                private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_BUTTON_BIG_ONE );
                _button1 ctrlSetText "Faction Editor";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Faction_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
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
                _groupsButton1 ctrlShow true;

                private _groupsButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_TWO );
                _groupsButton2 ctrlSetText "Edit";
                _groupsButton2 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorGroupsEditClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsButton2 ctrlShow true;
                _groupsButton2 ctrlEnable false;

                private _groupsButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_THREE );
                _groupsButton3 ctrlSetText "Delete";
                _groupsButton3 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorGroupsDeleteClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsButton3 ctrlShow true;

                // init asset list

                private _assetCategoryList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_INPUT_CATEGORY );
                _assetCategoryList ctrlSetEventHandler ["lbSelChanged","['onGroupEditorAssetCategoryChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                {
                    _index = _assetCategoryList lbAdd (_x select 0);
                    _assetCategoryList lbSetData [_index,str (_x select 1)];
                } foreach [["Men",["Man"]],["Cars",["Car"]],["APCs",["Wheeled_APC_F","APC_Wheeled_01_base_F","APC_Tracked_01_base_F"]],["Tanks",["Tank"]],["Planes",["Plane"]],["Helicopters",["Helicopter"]],["Ships",["Ship"]],["Static",["StaticWeapon"]]];

                private _assetList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_LIST_UNITS );
                _assetList ctrlSetEventHandler ["LBSelChanged","['onGroupEditorAssetSelected', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetList ctrlSetEventHandler ["LBDrag","['onGroupEditorAssetListDragStart', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetList ctrlShow true;

                private _assetButton1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_ONE );
                _assetButton1 ctrlSetText "Add to Selected Group";
                _assetButton1 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorAssetAddUnitClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetButton1 ctrlEnable false;

                private _assetButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_TWO );
                _assetButton2 ctrlSetText "Open in Unit Editor";
                _assetButton2 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorAssetEditUnitClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetButton2 ctrlEnable false;

                private _assetButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_THREE );
                _assetButton3 ctrlSetText "";
                //_assetButton3 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorAssetClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _assetButton3 ctrlShow false;

                // init selected group list

                private _selectedGroupUnitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
                _selectedGroupUnitList ctrlSetEventHandler ["LBSelChanged","['onGroupEditorSelectedGroupUnitChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupUnitList ctrlSetEventHandler ["LBDrag","['onGroupEditorSelectedGroupListDragStart', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupUnitList ctrlSetEventHandler ["LBDrop","['onGroupEditorSelectedGroupListDragEnd', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _selectedGroupUnitRank = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_INPUT_UNITRANK );
                _selectedGroupUnitRank ctrlSetEventHandler ["LBSelChanged","['onGroupEditorSelectedGroupUnitRankChangedClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                {
                    _index = _selectedGroupUnitRank lbAdd _x;
                    _selectedGroupUnitRank lbSetData [_index, toUpper _x];
                } foreach ["Colonel","Major","Captain","Lieutenant","Sergeant","Corporal","Private"];
                _selectedGroupUnitRank ctrlShow false;

                private _selectedGroupButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO );
                _selectedGroupButton2 ctrlSetText "";
                _selectedGroupButton2 ctrlSetEventHandler ["MouseButtonDown","[''] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupButton2 ctrlShow false;

                private _selectedGroupButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE );
                _selectedGroupButton3 ctrlSetText "Open Unit in Unit Editor";
                _selectedGroupButton3 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorSelectedGroupEditUnitClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupButton3 ctrlShow false;

                private _selectedGroupButton4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR );
                _selectedGroupButton4 ctrlSetText "Remove Unit From Group";
                _selectedGroupButton4 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorSelectedGroupRemoveUnitClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _selectedGroupButton4 ctrlShow false;

                // init faction list
                // init last for events to fire properly on opening

                private _factionList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_FACTIONS_LIST );
                [_logic,"loadFactionToList", _factionList] call MAINCLASS;

                lbSort [_factionList, "ASC"];

                _factionList ctrlSetEventHandler ["lbSelChanged","['onGroupEditorFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // create gray background and camera

                [_logic,"enableUnitEditorBackground", true] call MAINCLASS;

            };

            case "Create_Group": {

                private ["_index"];

                private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
                private _factionData = [_logic,"getFactionData",_faction] call MAINCLASS;
                private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

                // init category list

                private _inputCategory = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CATEGORY );

                {
                    _index = _inputCategory lbAdd _x;
                    _inputCategory lbSetData [_index,_x];
                } foreach (_factionGroupCategories select 1);

                private _selectedCategory = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
                [_inputCategory,_selectedCategory] call ALiVE_fnc_listSelectData;

                // init buttons

                private _buttonAutogenClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogenClassname ctrlSetEventHandler ["MouseButtonDown","['onCreateGroupAutogenClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonCancel = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_CANCEL );
                _buttonCancel ctrlSetEventHandler ["MouseButtonDown","['onCreateGroupCancelClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonConfirm = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_CONFIRM );
                _buttonConfirm ctrlSetEventHandler ["MouseButtonDown","['onCreateGroupConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            };

            case "Edit_Group": {

                [_logic,"onLoad", "Create_Group"] call MAINCLASS;

                private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
                private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
                private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

                private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
                private _groupName = [_groupData,"name"] call ALiVE_fnc_hashGet;
                private _groupConfigName = [_groupData,"configName"] call ALiVE_fnc_hashGet;

                private _inputName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_NAME );
                private _inputClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CLASSNAME );
                private _inputCategory = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CATEGORY );

                _inputName ctrlSetText _groupName;
                _inputClassname ctrlSetText _groupConfigName;

                private _buttonConfirm = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_CONFIRM );
                _buttonConfirm ctrlSetEventHandler ["MouseButtonDown","['onEditGroupConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            };

        };

    };

    case "onUnload": {

        private _interface = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        switch (_interface) do {

            case "Faction_Editor": {



            };

            case "Unit_Editor": {

                [_logic,"enableUnitEditorBackground", false] call MAINCLASS;

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

            case "Create_Group": {



            };

            case "Edit_Group": {



            };

        };

    };


    // helper functions
    // init


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

    case "initFactionGroupCategories": {

        private [
            "_groupCategory","_groupCategoryName","_groupCategoryGroups","_group",
            "_groupConfigName","_groupName","_groupSide","_groupFaction","_units",
            "_groupHash","_unit","_unitSide","_unitVehicle","_unitRank","_unitPosition",
            "_unitHash","_index","_rarityGroup","_groupIcon"
        ];

        private _factionGroupCategories = _args;

        private _tmpHash = [] call ALiVE_fnc_hashCreate;
        private _factionConfigGroupCategories = _faction call ALiVE_fnc_configGetFactionGroups;

        for "_i" from 0 to (count _factionConfigGroupCategories - 1) do {

            _groupCategory = _factionConfigGroupCategories select _i;

            if (isClass _groupCategory) then {

                _groupCategoryDisplayName = getText (_groupCategory >> "name");
                _groupCategoryConfigName = configName _groupCategory;

                if (_groupCategoryConfigName == "Motorized_MTP") then {
                    _groupCategoryDisplayName = "Motorized Infantry (MTP)";
                };

                _groupCategoryGroups = +_tmpHash;

                for "_i" from 0 to (count _groupCategory - 1) do {

                    _group = _groupCategory select _i;

                    if (isClass _group) then {

                        _groupConfigName = configName _group;
                        _groupName = getText (_group >> "name");
                        _groupSide = getNumber (_group >> "side");
                        _groupFaction = getText (_group >> "faction");
                        _groupIcon = getText (_group >> "icon");
                        _rarityGroup = getNumber (_group >> "rarityGroup");

                        if (_rarityGroup == 0) then {
                            _rarityGroup = 0.5;
                        };

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
                        [_groupHash,"icon", _groupIcon] call ALiVE_fnc_hashSet;
                        [_groupHash,"rarityGroup", _rarityGroup] call ALiVE_fnc_hashSet;
                        [_groupHash,"units", _units] call ALiVE_fnc_hashSet;

                        [_groupCategoryGroups,_groupConfigName,_groupHash] call ALiVE_fnc_hashSet;

                    };

                };

                _newGroupCategory = +_tmpHash;
                [_newGroupCategory,"name", _groupCategoryDisplayName] call ALiVE_fnc_hashSet;
                [_newGroupCategory,"configName", _groupCategoryConfigName] call ALiVE_fnc_hashSet;
                [_newGroupCategory,"groups", _groupCategoryGroups] call ALiVE_fnc_hashSet;

                [_factionGroupCategories,_groupCategoryConfigName,_newGroupCategory] call ALiVE_fnc_hashSet;

            };

        };

        _result = _factionGroupCategories;
    };


    // helper functions
    // factions

    case "addFaction": {

        private _factionData = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _factionConfigName = [_factionData,"configName"] call ALiVE_fnc_hashGet;

        [_factions,_factionConfigName, _factionData] call ALiVE_fnc_hashSet;

    };

    case "removeFaction": {

        private _faction = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        {
            _customUnit = _x;
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _faction) then {
                _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;

                [_customUnits,_customUnitConfigName] call ALiVE_fnc_hashRem;
            };
        } foreach (_customUnits select 2);

        [_factions,_faction] call ALiVE_fnc_hashRem;

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

    case "getFactionData": {

        private _faction = _args;

        if (_faction isEqualType "") then {

            private _state = [_logic,"state"] call MAINCLASS;
            private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
            _result = [_factions,_faction] call ALiVE_fnc_hashGet;

        };

    };

    case "setFactionSide": {

        private ["_groupCategory","_groupsInCategory","_group","_groupUnits","_unit","_customUnit","_customUnitFaction"];

        _args params ["_faction","_side"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

        // change side of groups

        {
            _groupCategory = _x;
            _groupsInCategory = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;

            {
                _group = _x;
                _groupUnits = [_group,"units"] call ALiVE_fnc_hashGet;

                {
                    _unit = _x;

                    [_unit,"side", _side] call ALiVE_fnc_hashSet;
                } foreach _units;

                [_group,"side", _side] call ALiVE_fnc_hashSet;
            } foreach (_groupsInCategory select 2);
        } foreach (_factionGroupCategories select 2);

        {
            _customUnit = _x;
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _faction) then {
                [_customUnit,"side", _side] call ALiVE_fnc_hashSet;
            };
        } foreach (_customUnits select 2);

        [_factionData,"side", _side] call ALiVE_fnc_hashSet;

    };

    case "setFactionClassname": {

        private ["_groupCategory","_groupsInCategory","_group","_customUnit"];

        _args params ["_faction","_classname"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionClassname = [_factionData,"configName"] call ALiVE_fnc_hashGet;
        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

        {
            _groupCategory = _x;
            _groupsInCategory = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;

            {
                _group = _x;
                [_group,"faction", _classname] call ALiVE_fnc_hashSet;
            } foreach (_groupsInCategory select 2);
        } foreach (_factionGroupCategories select 2);

        {
            _customUnit = _x;

            [_customUnit,"faction", _classname] call ALiVE_fnc_hashSet;
        } foreach (_customUnits select 2);

        [_factions,_factionClassname] call ALiVE_fnc_hashRem;
        [_factions,_classname,_factionData] call ALiVE_fnc_hashSet;

        [_factionData,"configName", _classname] call ALiVE_fnc_hashSet;

    };

    case "loadFactionToList": {

        private ["_index"];

        private _list = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        lbclear _list;

        {
            _faction = _x;
            _factionDisplayName = [_faction,"displayName"] call ALiVE_fnc_hashGet;
            _factionConfigName = [_faction,"configName"] call ALiVE_fnc_hashGet;

            _index = _list lbAdd (format ["%1 - %2", _factionDisplayName, _factionConfigName]);
            _list lbSetData [_index,_factionConfigName];
        } foreach (_factions select 2);

    };


    // helper functions
    // custom units


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

    case "setCustomUnitClassname": {

        private ["_groupCategory","_groupsInCategory","_group","_groupUnits","_groupUnit","_groupUnitVehicle"];

        _args params ["_unit","_classname"];

        if (_unit isEqualType "") then {
            _unit = [_logic,"getCustomUnit", _unit] call MAINCLASS;
        };

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _unitClassname = [_unit,"configName"] call ALiVE_fnc_hashGet;
        private _unitFaction = [_unit,"faction"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _unitFaction] call MAINCLASS;
        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

        {
            _groupCategory = _x;
            _groupsInCategory = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;

            {
                _group = _x;
                _groupUnits = [_group,"units"] call ALiVE_fnc_hashGet;

                {
                    _groupUnit = _x;
                    _groupUnitVehicle = [_groupUnit,"vehicle"] call ALiVE_fnc_hashGet;

                    if (_groupUnitVehicle == _unitClassname) then {
                        [_groupUnit,"vehicle", _classname] call ALiVE_fnc_hashSet;
                    };
                } foreach _groupUnits;
            } foreach (_groupsInCategory select 2);
        } foreach (_factionGroupCategories select 2);

        [_unit,"configName", _classname] call ALiVE_fnc_hashSet;

        [_customUnits,_unitClassname] call ALiVE_fnc_hashRem;
        [_customUnits,_classname, _unit] call ALiVE_fnc_hashSet;

    };


    // helper functions
    // groups


    case "getFactionGroupCategory": {

        _args params ["_faction","_category"];

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;
        _result = [_factionGroupCategories,_category] call ALiVE_fnc_hashGet;

    };

    case "getFactionCategoryGroup": {

        _args params ["_faction","_category","_group"];

        private _groupCategory = [_logic,"getFactionGroupCategory", [_faction,_category]] call MAINCLASS;
        private _groups = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;
        _result = [_groups,_group] call ALiVE_fnc_hashGet;

    };

    case "factionRemoveCategoryGroup": {

        _args params ["_faction","_category","_group"];

        private _groupCategory = [_logic,"getFactionGroupCategory", [_faction,_category]] call MAINCLASS;
        private _groups = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;

        [_groups,_group] call ALiVE_fnc_hashRem;

    };

    case "groupAddUnit": {

        private ["_unitPosX","_unitPosY"];

        _args params ["_group","_unit"];

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;

        private _units = [_group,"units"] call ALiVE_fnc_hashGet;
        private _unitCount = count _units;

        private _unitPosition = [_logic,"groupGenerateUnitPosition", [_group,_unit]] call MAINCLASS;

        private _newUnit = [] call ALiVE_fnc_hashCreate;
        [_newUnit,"vehicle", _unit] call ALiVE_fnc_hashSet;
        [_newUnit,"rank", if (_unitCount > 0) then {"PRIVATE"} else {"SERGEANT"}] call ALiVE_fnc_hashSet;
        [_newUnit,"side", _factionSide] call ALiVE_fnc_hashSet;
        [_newUnit,"position", _unitPosition] call ALiVE_fnc_hashSet;

        _units pushback _newUnit;

    };

    case "groupRemoveUnit": {

        _args params ["_group","_unitIndex"];

        private _units = [_group,"units"] call ALiVE_fnc_hashGet;
        _units deleteAt _unitIndex;

    };

    case "groupGenerateUnitPosition": {

        _args params ["_group","_unit"];

        _result = [0,0,0];

        private _units = [_group,"units"] call ALiVE_fnc_hashGet;
        private _unitCount = count _units;

        if (_unitCount > 0) then {
            private _prevUnit = _units select (_unitCount - 1);
            private _prevUnitPos = [_prevUnit,"position"] call ALiVE_fnc_hashGet;

            private _realUnit = [_logic,"getRealUnitClass", _unit] call MAINCLASS;

            if (_realUnit isKindOf "Man") then {
                if ((_unitCount % 2) == 0) then {
                    _unitPosX = - (_prevUnitPos select 0);
                    _unitPosY = _prevUnitPos select 1;
                } else {
                    if (_unitCount == 1) then {
                        _unitPosX = 5;
                        _unitPosY = -5;
                    } else {
                        _unitPosX = - ((_prevUnitPos select 0) - 5);
                        _unitPosY = (_prevUnitPos select 1) - 5;
                    };
                };
            } else {
                private _realUnitVeh = _realUnit createVehicle [0,0,0];
                private _bbr = boundingBoxReal _realUnitVeh;
                deleteVehicle _realUnitVeh;

                _bbr params ["_p1","_p2"];
                private _width = abs ((_p2 select 0) - (_p1 select 0));
                private _length = abs ((_p2 select 1) - (_p1 select 1));

                if ((_unitCount % 2) == 0) then {
                    _unitPosX = - (_prevUnitPos select 0);
                    _unitPosY = _prevUnitPos select 1;
                } else {
                    if (_unitCount == 1) then {
                        _unitPosX = round (5 max (_width * 1.5));
                        _unitPosY = - (round (5 max (_length * 1.5)));
                    } else {
                        _unitPosX = - ((_prevUnitPos select 0) - (round (5 max (_width * 1.5))));
                        _unitPosY = (_prevUnitPos select 0) - (round (5 max (_length * 1.5)));
                    };
                };
            };

            _result set [0,_unitPosX];
            _result set [1,_unitPosY];
        };

    };


    // helper functions
    // misc


    case "convertSideToNum": {

        switch (typename _args) do {
            case "OBJECT": {_result = [_args] call ALiVE_fnc_sideObjectToNumber};
            case "STRING": {_result = [_args] call ALiVE_fnc_sideTextToNumber};
            default {_result = _args};
        };

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

    case "validateClassname": {

        private _classname = _args;

        _classname = [_logic,"displayNameToClassname", _classname] call MAINCLASS;

        _result = _classname;

    };


    // faction editor


    case "getFactionGroupsDataSources": {

        private ["_groupCategory","_groupCategoryConfigName","_groupCategoryDataSource"];

        private _faction = _args;

        if (_faction isEqualType "") then {
            _faction = [_logic,"getFactionData", _faction] call MAINCLASS;
        };

        private _factionGroupCategories = [_faction,"groupCategories"] call ALiVE_fnc_hashGet;

        private _compatibleGroupCategories = [];
        private _incompatibleGroupCategories = [];

        {
            _groupCategory = _x;
            _groupCategoryConfigName = [_groupCategory,"configName"] call ALiVE_fnc_hashGet;

            _groupCategoryDataSource = [_logic,"getGroupCategoryDataSource", _groupCategory] call MAINCLASS;

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

    case "getGroupCategoryDataSource": {

        private ["_group","_groupDataSource"];

        private _category = _x;
        private _categoryDisplayName = [_category,"name"] call ALiVE_fnc_hashGet;
        private _categoryGroups = [_category,"groups"] call ALiVE_fnc_hashGet;

        private _groupDataSources = [];
        {
            _group = _x;

            _groupDataSource = [_logic,"getGroupDataSource", _group] call MAINCLASS;
            _groupDataSources pushback _groupDataSource;
        } foreach (_categoryGroups select 2);

        _result = [_categoryDisplayName, "", "", _groupDataSources];

    };

    case "getGroupDataSource": {

        private ["_unit","_unitDataSource"];

        private _group = _args;

        private _groupName = [_group,"name"] call ALiVE_fnc_hashGet;
        private _groupClassname = [_group,"configName"] call ALiVE_fnc_hashGet;
        private _groupUnits = [_group,"units"] call ALiVE_fnc_hashGet;

        private _unitDataSources = [];

        for "_i" from 0 to (count _groupUnits - 1) do {

            _unit = _groupUnits select _i;

            _unitDataSource = [_logic,"getUnitDataSource", _unit] call MAINCLASS;
            _unitDataSources pushback _unitDataSource;

        };

        _result = [_groupName, _groupClassname, "", _unitDataSources];

    };

    case "getUnitDataSource": {

        private ["_unitDisplayName"];

        private _unitHash = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _unitSide = [_unitHash,"side"] call ALiVE_fnc_hashGet;
        private _unitVehicle = [_unitHash,"vehicle"] call ALiVE_fnc_hashGet;
        private _unitRank = [_unitHash,"rank"] call ALiVE_fnc_hashGet;
        private _unitPosition = [_unitHash,"position"] call ALiVE_fnc_hashGet;

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

    case "onFactionEditorFactionChanged": {

        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData(_list);

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"factionEditor_selectedFaction", _faction] call ALiVE_fnc_hashSet;

        [_logic,"factionEditorDisplayFaction", _faction] call MAINCLASS;

    };

    case "factionEditorDisplayFaction": {

        private _faction = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionClassname = [_factionData,"configName"] call ALiVE_fnc_hashGet;
        private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;

        private _inputSide = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_SIDE );
        private _inputDisplayName = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_NAME );
        private _inputClassname = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_CLASSNAME );
        private _inputFlag = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_FLAG );

        // if flag isnt in list
        // add it

        private _allFlags = [];
        for "_i" from 0 to (lbSize _inputFlag -  1) do {
            _allFlags pushback (_inputFlag lbData _i);
        };

        if !(_factionFlag in _allFlags) then {
            private _flagName = format ["Flag %1", _factionDisplayName];

            private _index = _inputFlag lbAdd _flagName;
            _inputFlag lbSetData [_index,_factionFlag];
            _inputFlag lbSetPicture [_index,_factionFlag];
        };

        // update inputs

        [_inputSide,str _factionSide] call ALiVE_fnc_listSelectData;
        _inputDisplayName ctrlSetText _factionDisplayName;
        _inputClassname ctrlSetText _factionClassname;
        [_inputFlag,_factionFlag] call ALiVE_fnc_listSelectData;

        // update group tree

        [_logic,"factionEditorDisplayFactionGroups", _faction] call MAINCLASS;

    };

    case "factionEditorDisplayFactionGroups": {

        private _faction = _args;

        private _tree = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_TREE_GROUPS );
        tvClear _tree;

        private _factionDataSources = [_logic,"getFactionGroupsDataSources", _factionData] call MAINCLASS;

        [_logic,"treeAddDataSourcesArray", [_tree,_factionDataSources]] call MAINCLASS;

    };

    case "onFactionEditorFactionNewClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _numPrefix = 1;
        private _factionConfigName = format ["new_faction_%1", _numPrefix];

        while {_factionConfigName in (_factions select 1)} do {
            _numPrefix = _numPrefix + 1;
            _factionConfigName = format ["new_faction_%1", _numPrefix];
        };

        // get random flag

        private _flagList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_FLAG );
        private _flags = [];

        for "_i" from 0 to (lbSize _flagList - 1) do {
            _flags pushback (_flagList lbData _i);
        };

        private _factionDisplayName = format ["New Faction %1", _numPrefix];
        private _randomFlag = selectRandom _flags;

        private _newFaction = [nil,"create"] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"init"] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"configName", _factionConfigName] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"displayName", _factionDisplayName] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"flag", _randomFlag] call ALiVE_fnc_hashSet;

        [_logic,"addFaction", _newFaction] call MAINCLASS;

        // update list

        private _factionList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
        [_logic,"loadFactionToList", _factionList] call MAINCLASS:
        lbSort [_factionList, "ASC"];
        [_factionList,_factionConfigName] call ALiVE_fnc_listSelectData;

    };

    case "onFactionEditorFactionDeleteClicked": {

        private ["_customUnit","_customUnitConfigName"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"factionEditor_selectedFaction"] call ALiVE_fnc_hashGet;

        [_logic,"removeFaction", _faction] call MAINCLASS;

        // update list

        private _factionList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
        [_logic,"loadFactionToList", _factionList] call MAINCLASS:
        lbSort [_factionList, "ASC"];
        [_factionList,_newClassname] call ALiVE_fnc_listSelectData;

    };

    case "onFactionEditorFactionSaveClicked": {

        private ["_index"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _faction = [_state,"factionEditor_selectedFaction"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionClassname = [_factionData,"configName"] call ALiVE_fnc_hashGet;
        private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;

        private _inputDisplayName = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_NAME );
        private _inputClassname = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_INPUT_CLASSNAME );

        private _newSide = call compile OC_getSelData( OC_FACTIONEDITOR_INPUT_SIDE );
        private _newDisplayName = ctrlText _inputDisplayName;
        private _newClassname = ctrlText _inputClassname;
        private _newFlag = OC_getSelData( OC_FACTIONEDITOR_INPUT_FLAG );

        private _changed = false;

        if (_newSide != _factionSide) then {
            [_logic,"setFactionSide", [_faction,_newSide]] call MAINCLASS;
            _changed = true;
        };

        if (_newDisplayName != _factionDisplayName) then {
            [_factionData,"displayName", _newDisplayName] call ALiVE_fnc_hashSet;
            _changed = true;
        };

        if (_newClassname != _factionClassname) then {
            _newClassname = [_newClassname," ","_"] call CBA_fnc_replace;
            [_logic,"setFactionClassname", [_faction,_newClassname]] call MAINCLASS;
            _changed = true;
        };

        if (_newFlag != _factionFlag) then {
            [_factionData,"flag", _newFlag] call ALiVE_fnc_hashSet;
            _changed = true;
        };

        // update lists if values changed

        if (_changed) then {
            private _factionList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
            [_logic,"loadFactionToList", _factionList] call MAINCLASS:
            lbSort [_factionList, "ASC"];
            [_factionList,_newClassname] call ALiVE_fnc_listSelectData;
        };

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

        [_logic,"displayVehicle", _selectedUnitClassname] call MAINCLASS;

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

    case "displayVehicle": {

        private ["_sideObject","_loadout","_activeUnit"];
        private _vehicle = _args;

        private _buttonEditLoadout = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_TWO );
        private _buttonEditProperties = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_THREE );

        private _state = [_logic,"state"] call MAINCLASS;
        private _cam = [_state,"unitEditor_interfaceCamera"] call ALiVE_fnc_hashGet;
        private _pos = [_state,"unitEditor_activeUnitPosition"] call ALiVE_fnc_hashGet;

        // get unit data

        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _customUnit = [_customUnits,_vehicle] call ALiVE_fnc_hashGet;

        if (!isnil "_customUnit") then {
            _vehicle = [_customUnit,"configName"] call ALiVE_fnc_hashGet;
            _loadout = [_customUnit,"loadout"] call ALiVE_fnc_hashGet;

            private _customUnitSide = [_customUnit,"side"] call ALiVE_fnc_hashGet;
            private _customSideText = [_customUnitSide] call ALiVE_fnc_sideNumberToText;
            _sideObject = [_customSideText] call ALiVE_fnc_sideTextToObject;

            // if custom unit parent is another custom unit
            // keep going up the inheritance tree until you find a real unit

            _vehicle = [_logic,"getRealUnitClass", _vehicle] call MAINCLASS;
        } else {
            private _configPath = configFile >> "CfgVehicles" >> _vehicle;
            private _side = getNumber (_configPath >> "side");
            _sideObject = [_side] call ALiVE_fnc_sideTextToObject;
        };

        // delete existing vehicle

        private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
        deleteVehicle _activeUnit;

        // spawn vehicle

        if (_vehicle isKindOf "Man") then {
            _activeUnit = (createGroup _sideObject) createUnit [_vehicle, [0,0,0], [], 0, "NONE"];
            _activeUnit setPosASL _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;
            _activeUnit switchMove (animationState player);
            _activeUnit switchAction "playerstand";

            _activeUnit setUnitLoadout _loadout;
            _cam camSetRelPos [-0.05,1,0.15];
            _cam camSetFov 0.35;

            _buttonEditLoadout ctrlEnable true;
        } else {
            _activeUnit = _vehicle createVehicle [0,0,0];
            _activeUnit setPosASL _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;

            _cam camSetRelPos [0, (sizeOf _vehicle) * 0.65, (sizeOf _vehicle) * 0.1];
            _cam camSetFov 0.5;

            _buttonEditLoadout ctrlEnable false;
        };

        _activeUnit setDir 25;

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
        [_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

        // update list

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


    // create unit


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

        _classname = [_logic,"validateClassname", _classname] call MAINCLASS;

        // get parent class

        private _parentClass = OC_getSelData( OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
        private _loadout = [];

        if (_parentClass isKindOf "Man") then {
            // spawn parent class and get loadout
            // enables init events to fire

            private _realParentClass = [_logic,"getRealUnitClass", _parentClass] call MAINCLASS;
            private _sideText = [_side] call ALiVE_fnc_sideNumberToText;
            private _sideObject = [_sideText] call ALiVE_fnc_sideTextToObject;
            private _realParentUnit = (createGroup _sideObject) createUnit [_realParentClass, [0,0,0], [], 0, "NONE"];

            _loadout = getUnitLoadout _realParentUnit;

            deleteVehicle _realParentUnit;
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

        private _selectedFaction = [_state,"unitEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        [_logic,"unitEditorDisplayFactionUnits", _selectedFaction] call MAINCLASS;

        private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
        [_unitList,_classname, true] call ALiVE_fnc_listSelectData;

    };

    case "convertConfigUnitToCustomUnit": {

        // TODO: function incomplete

        private _unit = _args;

        if (_unit isEqualType "") then {

            private ["_unitConfig","_unitConfigName","_unitSide","_unitFaction","_unitDisplayName","_unitLoadout"];

            private _state = [_logic,"state"] call MAINCLASS;
            private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

            _unitConfig = configFile >> "CfgVehicles" >> _unit;
            _unitConfigName = configName _unitConfig;
            _unitSide = getNumber (_unitConfig >> "side");
            _unitFaction = getText (_unitConfig >> "faction");
            _unitDisplayName = getText (_unitConfig >> "displayName");
            _unitLoadout = getUnitLoadout _asset;

            _newUnit = [nil,"create"] call ALiVE_fnc_orbatCreatorUnit;
            [_newUnit,"init"] call ALiVE_fnc_orbatCreatorUnit;
            [_newUnit,"inheritsFrom", ""] call ALiVE_fnc_orbatCreatorUnit; // should be array
            [_newUnit,"side", _unitSide] call ALiVE_fnc_hashSet;
            [_newUnit,"faction", _unitFaction] call ALiVE_fnc_hashSet;
            [_newUnit,"displayName", _unitDisplayName] call ALiVE_fnc_hashSet;
            [_newUnit,"configName", _unitConfigName] call ALiVE_fnc_hashSet;
            [_newUnit,"loadout", _unitLoadout] call ALiVE_fnc_hashSet;

            [_customUnits,_unitConfigName, _newUnit] call ALiVE_fnc_hashSet;

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
            _classname = [_logic,"validateClassname", _classname] call MAINCLASS;

            [_logic,"setCustomUnitClassname", [_unitConfigName,_classname]] call MAINCLASS;
            _selectedUnit = _classname; // enables proper re-selection once menu closes
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

        private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
        [_unitList,_selectedUnit, true] call ALiVE_fnc_listSelectData;

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

    };

    case "groupEditorDisplayFactionGroupCategories": {

        private ["_category","_categoryDisplayName","_categoryConfigName","_index"];

        private _faction = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"groupEditor_selectedFaction", _faction] call ALiVE_fnc_hashSet;

        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

        // add categories to list

        private _categoryList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_INPUT_CATEGORY );
        lbClear _categoryList;

        {
            _category = _x;
            _categoryDisplayName = [_category,"name"] call ALiVE_fnc_hashGet;
            _categoryConfigName = [_category,"configName"] call ALiVE_fnc_hashGet;

            _index = _categoryList lbAdd _categoryDisplayName;
            _categoryList lbSetData [_index,_categoryConfigName];
        } foreach (_factionGroupCategories select 2);

        if (lbSize _categoryList > 0) then {
            _categoryList lbSetCurSel 0;
        };

        // reset category list

        private _assetCategories = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_INPUT_CATEGORY );
        _assetCategories lbSetCurSel 0;

    };

    case "onGroupEditorAssetCategoryChanged": {

        _args params ["_list","_index"];

        private _category = call compile OC_ctrlGetSelData( _list );

        // disable buttons

        private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_ONE );
        _button1 ctrlEnable false;

        private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_TWO );
        _button2 ctrlEnable false;

        [_logic,"groupEditorDisplayFactionAssetsInCategory", _category] call MAINCLASS;

    };

    case "groupEditorDisplayFactionAssetsInCategory": {

        private ["_unit","_displayName","_configName","_realUnit","_add","_index"];

        private _category = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;

        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;
        private _customUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;

        // set units to list

        private _assetList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_LIST_UNITS );
        lbClear _assetList;

        {
            _unit = _x;
            _displayName = [_unit,"displayName"] call ALiVE_fnc_hashGet;
            _configName = [_unit,"configName"] call ALiVE_fnc_hashGet;
            _realUnit = [_logic,"getRealUnitClass", _configName] call MAINCLASS;

            _add = false;
            {if (_realUnit isKindOf _x) then {_add = true}} foreach _category;

            if (_add) then {
                _index = _assetList lbAdd _displayName;
                _assetList lbSetData [_index,_configName];
            };
        } foreach _customUnits;

        private _factionAssetDisplayNames = _factionAssets select 1;
        private _factionAssetConfigNames = _factionAssets select 2;

        for "_i" from 0 to (count _factionAssetDisplayNames - 1) do {
            _displayName = _factionAssetDisplayNames select _i;
            _configName = _factionAssetConfigNames select _i;

            _add = false;
            {if (_configName isKindOf _x) exitWith {_add = true}} foreach _category;

            if (_add) then {
                _index = _assetList lbAdd _displayName;
                _assetList lbSetData [_index, _configName];
            };
        };

        if (lbSize _assetList > 0) then {
            _assetList lbSetCurSel 0;
        };

    };

    case "onGroupEditorAssetSelected": {

        _args params ["_list","_index"];

        private _unit = OC_ctrlGetSelData( _list );

        [_logic,"displayVehicle", _unit] call MAINCLASS;

        private _state = [_logic,"state"] call MAINCLASS;
        private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

        // enable buttons

        if (_group != "") then {
            private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_ONE );
            _button1 ctrlEnable true;
        };

        private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_TWO );
        _button2 ctrlEnable true;

    };

    case "onGroupEditorAssetListDragStart": {

        _args params ["_list","_dragData"];

        private _draggedAsset = _dragData select 0 select 2;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"groupEditor_assetListDragTarget", _draggedAsset] call ALiVE_fnc_hashSet;

    };

    case "onGroupEditorSelectedGroupListDragEnd": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _draggedAsset = [_state,"groupEditor_assetListDragTarget"] call ALiVE_fnc_hashGet;

        if (_draggedAsset != "") then {
            private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
            private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
            private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

            private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
            [_logic,"groupAddUnit", [_groupData,_draggedAsset]] call MAINCLASS;

            [_state,"groupEditor_assetListDragTarget", ""] call ALiVE_fnc_hashSet;

            // update list

            [_logic,"groupEditorDisplayGroupUnits", _groupData] call MAINCLASS;
        };

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
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;

        [_state,"groupEditor_selectedGroupCategory", _groupCategory] call ALiVE_fnc_hashSet;

        // if display was forced
        // select category

        private _categoryList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_INPUT_CATEGORY );
        private _currentCategory = OC_ctrlGetSelData( _categoryList );
        if (_currentCategory != _groupCategory) exitWith {
            [_categoryList,_groupCategory] call ALiVE_fnc_listSelectData;
        };

        private _groupCategory = [_logic,"getFactionGroupCategory", [_faction,_groupCategory]] call MAINCLASS;
        private _groups = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;

        // reset asset list

        private _assetButton1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_ONE );
        _assetButton1 ctrlEnable false;

        // reset active group list

        private _selectedGroupHeader = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_HEADER);
        _selectedGroupHeader ctrlSetText "";

        private _selectedGroupUnitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
        lbClear _selectedGroupUnitList;

        private _selectedGroupUnitRank = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_INPUT_UNITRANK );
        _selectedGroupUnitRank ctrlShow false;

        private _selectedGroupButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO );
        _selectedGroupButton2 ctrlShow false;

        private _selectedGroupButton3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE );
        _selectedGroupButton3 ctrlShow false;

        private _selectedGroupButton4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR );
        _selectedGroupButton4 ctrlShow false;

        // reset group list buttons

        private _groupsButton2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_TWO );
        _groupsButton2 ctrlEnable false;

        private _button3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_THREE );
        _button3 ctrlEnable false;

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
        [_state,"groupEditor_selectedGroup", ""] call ALiVE_fnc_hashSet;

        if (lbSize _groupList > 0) then {
            _groupList lbSetCurSel 0;
            _groupList lbSetSelected [0,true];
        };

    };

    case "onGroupEditorGroupSelected": {

        _args params ["_list","_index"];

        private _group = OC_ctrlGetSelData( _list );

        // enable buttons
        // asset list

        private _assetButton1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_ONE );
        _assetButton1 ctrlEnable true;

        // enable buttons
        // group list

        private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_ONE );
        _button1 ctrlEnable true;

        private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_TWO );
        _button2 ctrlEnable true;

        private _button3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_THREE );
        _button3 ctrlEnable true;

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;

        private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;

        [_logic,"groupEditorDisplayGroupUnits", _groupData] call MAINCLASS;

    };

    case "groupEditorDisplayGroupUnits": {

        private ["_unitData","_unitClass","_unitRank","_unitPosition","_unitDisplayName","_tooltip","_index"];

        private _group = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _customUnitClasses = _customUnits select 1;

        private _groupConfigName = [_group,"configName"] call ALiVE_fnc_hashGet;
        private _groupName = [_group,"name"] call ALiVE_fnc_hashGet;
        private _groupUnits = [_group,"units"] call ALiVE_fnc_hashGet;

        [_state,"groupEditor_selectedGroup", _groupConfigName] call ALiVE_fnc_hashSet;

        // set header

        private _selectedGroupHeader = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_HEADER);
        _selectedGroupHeader ctrlSetText _groupName;
        _selectedGroupHeader ctrlShow true;

        // hide buttons

        private _unitRank = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_INPUT_UNITRANK );
        _unitRank ctrlShow false;

        private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_TWO );
        _button1 ctrlShow false;

        private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE );
        _button2 ctrlShow false;

        private _button3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR );
        _button3 ctrlShow false;

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
                _unit = [_customUnits,_unitConfigName] call ALiVE_fnc_hashGet;
                _unitDisplayName = [_unit,"displayName"] call ALiVE_fnc_hashGet;
            } else {
                _unitDisplayName = getText (configFile >> "CfgVehicles" >> _unitConfigName >> "displayName");
            };

            _tooltip = format ["Rank: %1\nPosition: %2\nClass: %3", _unitRank, _unitPosition, _unitConfigName];

            _index = _selectedGroupUnitList lbAdd _unitDisplayName;
            _selectedGroupUnitList lbSetData [_index,_unitConfigName];
            _selectedGroupUnitList lbSetTooltip [_index,_tooltip];
        } foreach _groupUnits;

        [_logic,"displayVehicle", ""] call MAINCLASS;

        if (lbSize _selectedGroupUnitList > 0) then {
            _selectedGroupUnitList lbSetCurSel 0;
        };

    };

    case "onGroupEditorSelectedGroupUnitChanged": {

        _args params ["_list","_index"];

        private _unit = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
        private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

        private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
        private _groupUnits = [_groupData,"units"] call ALiVE_fnc_hashGet;

        private _unitData = _groupUnits select _index;
        private _unitRank = [_unitData,"rank"] call ALiVE_fnc_hashGet;

        private _inputUnitRank = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_INPUT_UNITRANK );
        _inputUnitRank ctrlShow true;
        [_inputUnitRank,_unitRank] call ALiVE_fnc_listSelectData;

        // enable buttons

        private _button3 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_THREE );
        _button3 ctrlShow true;

        private _button4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_BUTTON_FOUR );
        _button4 ctrlShow true;

        // TODO: unified approach to spawning units
        // and handling camera movement

        [_logic,"displayVehicle", _unit] call MAINCLASS;

    };

    case "onGroupEditorSelectedGroupUnitRankChangedClicked": {

        _args params ["_list","_index"];

        private _rank = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
        private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

        private _unitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
        private _unitIndex = lbCurSel _unitList;

        private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
        private _groupUnits = [_groupData,"units"] call ALiVE_fnc_hashGet;

        private _unitData = _groupUnits select _unitIndex;
        private _unitRank = [_unitData,"rank"] call ALiVE_fnc_hashGet;

        if (_rank != _unitRank) then {

            [_unitData,"rank",_rank] call ALiVE_fnc_hashSet;

            // update list

            [_logic,"groupEditorDisplayGroupUnits", _groupData] call MAINCLASS;

            _unitList lbSetCurSel _unitIndex;

        };

    };

    case "onGroupEditorSelectedGroupEditUnitClicked": {

        private _unit = OC_getSelData( OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );

        [_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

        _unit spawn {
            sleep 0.1;
            [ALiVE_orbatCreator,"unitEditorSelectUnit", _this] call MAINCLASS;
        };

    };

    case "onGroupEditorSelectedGroupRemoveUnitClicked": {

        private _unitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
        private _unitIndex = lbCurSel _unitList;

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
        private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

        private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
        [_logic,"groupRemoveUnit", [_groupData,_unitIndex]] call MAINCLASS;

        // update list

        [_logic,"groupEditorDisplayGroupUnits", _groupData] call MAINCLASS;

    };

    case "onGroupEditorGroupsNewClicked": {

        [_logic,"openInterface", "Create_Group"] spawn MAINCLASS;

    };

    case "onGroupEditorGroupsEditClicked": {

        [_logic,"openInterface", "Edit_Group"] spawn MAINCLASS;

    };

    case "onGroupEditorGroupsDeleteClicked": {

        private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
        private _selectedIndices = lbSelection _groupList;
        private _selectedGroups = [];

        {
            _selectedGroups pushback (_groupList lbData _x);
        } foreach _selectedIndices;

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;

        {
            [_logic,"factionRemoveCategoryGroup", [_faction,_category,_x]] call MAINCLASS;
        } foreach _selectedGroups;

        // update list

        [_logic,"groupEditorDisplayFactionGroupsInCategory", _category] call MAINCLASS;

    };

    case "onGroupEditorAssetAddUnitClicked": {

        private _asset = OC_getSelData( OC_GROUPEDITOR_ASSETS_LIST_UNITS );

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
        private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

        if (_group != "") then {

            private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
            [_logic,"groupAddUnit", [_groupData,_asset]] call MAINCLASS;

            // update list

            [_logic,"groupEditorDisplayGroupUnits", _groupData] call MAINCLASS;

        };

    };

    case "onGroupEditorAssetEditUnitClicked": {

        private _asset = OC_getSelData( OC_GROUPEDITOR_ASSETS_LIST_UNITS );

        [_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

        _asset spawn {
            sleep 0.1;
            [ALiVE_orbatCreator,"unitEditorSelectUnit", _this] call MAINCLASS;
        };


    };


    // create group


    case "onCreateGroupAutogenClassnameClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;

        private _inputName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_NAME );
        private _groupName = ctrlText _inputName;

        private _autogenGroupClassname = [_logic,"generateGroupClassname", [_faction,_category,_groupName]] call MAINCLASS;

        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CLASSNAME );
        _inputClassname ctrlSetText _autogenGroupClassname;

    };

    case "generateGroupClassname": {

        _args params ["_faction","_category","_groupName"];

        private _faction = [_faction," ",""] call CBA_fnc_replace;
        _faction = [_faction,"_",""] call CBA_fnc_replace;

        _groupName = [_logic,"displayNameToClassname", _groupName] call MAINCLASS;

        _result = format ["%1_%2_group_%3", _faction, _category, _groupName];
        _result = toLower _result;

    };

    case "onCreateGroupCancelClicked": {

        closeDialog 0;

    };

    case "onCreateGroupConfirmClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;

        private _instructions = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INSTRUCTIONS );

        private _inputName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_NAME );
        private _groupName = ctrlText _inputName;

        if (_groupName == "") exitWith {
            _instructions ctrlSetText "Group name cannot be blank";
        };

        private _inputClassName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CLASSNAME );
        private _groupClassName = ctrlText _inputClassName;

        if (_groupClassName == "") exitWith {
            _instructions ctrlSetText "Class name cannot be blank";
        };

        private _groupCategory = OC_getSelData( OC_CREATEGROUP_INPUT_CATEGORY );

        private _factionGroupCategory = [_logic,"getFactionGroupCategory", [_faction,_groupCategory]] call MAINCLASS;
        private _groups = [_factionGroupCategory,"groups"] call ALiVE_fnc_hashGet;
        private _groupClassnamesInCategory = _groups select 1;

        if (_groupClassName in _groupClassnamesInCategory) exitWith {
            _instructions ctrlSetText "A group with that classname already exists in the selected category";
        };

        _groupClassName = [_logic,"validateClassname", _groupClassName] call MAINCLASS;

        // all verifcations passed, save group

        private _newGroup = [] call ALiVE_fnc_hashCreate;
        [_newGroup,"name", _groupName] call ALiVE_fnc_hashSet;
        [_newGroup,"configName", _groupClassName] call ALiVE_fnc_hashSet;
        [_newGroup,"side", _factionSide] call ALiVE_fnc_hashSet;
        [_newGroup,"faction", _faction] call ALiVE_fnc_hashSet;
        [_newGroup,"units", []] call ALiVE_fnc_hashSet;

        [_groups,_groupClassName, _newGroup] call ALiVE_fnc_hashSet;

        closeDialog 0;

        [_logic,"groupEditorDisplayFactionGroupsInCategory", _groupCategory] call MAINCLASS;

        private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
        [_groupList,_groupClassName, true] call ALiVE_fnc_listSelectData;

    };


    // edit group


    case "onEditGroupConfirmClicked": {

        private _state = [_logic,"state"] call MAINCLASS;

        private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
        private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _currentGroupCategory = [_logic,"getFactionGroupCategory", [_faction,_category]] call MAINCLASS;
        private _currentCategoryGroups = [_currentGroupCategory,"groups"] call ALiVE_fnc_hashGet;

        private _groupData = [_currentCategoryGroups,_group] call ALiVE_fnc_hashGet;
        private _groupName = [_groupData,"name"] call ALiVE_fnc_hashGet;
        private _groupConfigName = [_groupData,"configName"] call ALiVE_fnc_hashGet;

        private _inputName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_NAME );
        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CLASSNAME );
        private _instructions = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INSTRUCTIONS );

        private _newGroupName = ctrlText _inputName;
        private _newGroupClassname = ctrlText _inputClassname;
        private _newCategory = OC_getSelData( OC_CREATEGROUP_INPUT_CATEGORY );

        // verify names aren't blank

        if (_newGroupName == "") exitWith {
            _instructions ctrlSetText "Group name cannot be blank";
        };

        if (_newGroupClassname == "") exitWith {
            _instructions ctrlSetText "Class name cannot be blank";
        };

        private _newGroupCategory = [_logic,"getFactionGroupCategory", [_faction,_newCategory]] call MAINCLASS;
        private _newGroupCategoryGroups = [_newGroupCategory,"groups"] call ALiVE_fnc_hashGet;
        private _newCategoryGroupClassnames = _newGroupCategoryGroups select 1;

        if (!(_newGroupCategory isEqualTo _currentGroupCategory) && {_newGroupClassname in _newCategoryGroupClassnames}) exitWith {
            _instructions ctrlSetText "A group with that classname already exists in the selected category";
        };

        // verification complete

        if (_newGroupName != _groupName) then {
            [_groupData,"name", _newGroupName] call ALiVE_fnc_hashSet;
            _groupName = _newGroupName;
        };

        if (_newGroupClassname != _groupConfigName) then {
            _newGroupClassname = [_logic,"validateClassname", _newGroupClassname] call MAINCLASS;
            [_groupData,"configName", _newGroupClassname] call ALiVE_fnc_hashSet;

            [_currentCategoryGroups,_groupConfigName] call ALiVE_fnc_hashRem;
            [_currentCategoryGroups,_newGroupClassname,_groupData] call ALiVE_fnc_hashSet;
            _groupConfigName = _newGroupClassname;
        };

        if (_newCategory != _category) then {
            [_currentCategoryGroups,_groupConfigName] call ALiVE_fnc_hashRem;
            [_newGroupCategoryGroups,_groupConfigName,_groupData] call ALiVE_fnc_hashSet;
            _category = _newCategory;
        };

        closeDialog 0;

        [_logic,"groupEditorDisplayFactionGroupsInCategory", _category] call MAINCLASS;

        private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
        [_groupList,_groupConfigName, true] call ALiVE_fnc_listSelectData;

    };


    // config generation


    case "generateConfig": {

        private _mode = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        switch (_mode) do {

            case "Faction_Editor": {

                private _faction = [_state,"factionEditor_selectedFaction"] call ALiVE_fnc_hashGet;

                _result = [_logic,"exportFaction", _faction] call MAINCLASS;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

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

            case "Group_Editor": {

                private _faction = [_state,"groupEditor_selectedFaction"] call ALiVE_fnc_hashGet;
                private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;

                private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
                private _selectedIndices = lbSelection _groupList;

                private _groups = [];

                {
                    _groups pushback (_groupList lbData _x);
                } foreach _selectedIndices;

                private _factionGroupCategory = [_logic,"getFactionGroupCategory", [_faction,_category]] call MAINCLASS;

                _result = [_logic,"exportGroupsInCategory", [_factionGroupCategory,_groups]] call MAINCLASS;
                _result = [_logic,"formatGroupCategoriesToFaction", [_faction,_result]] call MAINCLASS;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

        };

    };


    // CfgVehicles


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
            _result = _result + _unitExportString + _newLine;
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

        _result = _result + _newLine + _indent + "};" + _newLine;

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
        private _eventHandlers = [] call ALiVE_fnc_hashCreate;
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
            _initEventHandler = [_eventHandlers,"init",""] call ALiVE_fnc_hashGet;
            _initEventHandler = _initEventHandler + "(_this select 0) forceAddUniform " + "'" + _tmpUnitUniform + "'" + ";";

            [_eventHandlers,"init", _initEventHandler] call ALiVE_fnc_hashSet;
        };

        // persist weapon items

        _initEventHandler = [_eventHandlers,"init",""] call ALiVE_fnc_hashGet;
        private _primaryWeaponItems = primaryWeaponItems _tmpUnit;
        private _secondarWeaponItems = secondaryWeaponItems _tmpUnit;
        private _handgunWeaponItems = handgunItems _tmpUnit;

        {
            if (_x != "") then {
                _initEventHandler = _initEventHandler + "(_this select 0) addPrimaryWeaponItem " + "'" + _x + "'" + ";";
            };
        } foreach _primaryWeaponItems;

        {
            if (_x != "") then {
                _initEventHandler = _initEventHandler + "(_this select 0) addSecondaryWeaponItem " + "'" + _x + "'" + ";";
            };
        } foreach _secondarWeaponItems;

        {
            if (_x != "") then {
                _initEventHandler = _initEventHandler + "(_this select 0) addHandgunItem " + "'" + _x + "'" + ";";
            };
        } foreach _handgunWeaponItems;

        [_eventHandlers,"init", _initEventHandler] call ALiVE_fnc_hashSet;

        // persist gear

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

        _result = _result + _newLine + _newLine + _indent + _indent + "class EventHandlers : EventHandlers {";
        _result = _result + _newLine + _indent + _indent + _indent + "class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {}";

        private _eventHandlerTypes = _eventHandlers select 1;
        private _eventHandlerStrings = _eventHandlers select 2;

        for "_i" from 0 to (count _eventHandlerTypes - 1) do {
            _eventHandlerType = _eventHandlerTypes select _i;
            _eventHandlerStatements = _eventHandlerStrings select _i;

            _EHString = _eventHandlerType + " = " + """" + _eventHandlerStatements + """" + ";";

            _result = _result + _newLine + _indent + _indent + _indent + _EHString;
        };

        _result = _result + _newLine + _indent + _indent + "};" + _newLine;

        deleteVehicle _tmpUnit;
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
        _result = _result + _newLine + _indent + _indent + "};" + _newLine;

    };


    // CfgGroups


    case "formatGroupCategoriesToFaction": {

        _args params ["_faction","_groupCategoryString"];

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
        private _sideText = [_factionSide] call ALiVE_fnc_sideNumberToText;

        if (_sideText == "GUER") then {
            _sideText = "Independant";
        };

        private _newLine = toString [13,10];
        private _indent = "    ";
        _result = "";

        _result = _result + "class CfgGroups {" + _newLine;
        _result = _result + _indent + "class " + _sideText + " {" + _newLine;
        _result = _result + _newLine;

        _result = _result + _indent + _indent + "class " + _faction + " {" + _newLine;
        _result = _result + _indent + _indent + _indent + "name = " + str _factionDisplayName + ";" + _newLine;
        _result = _result + _newLine;

        _result = _result + _groupCategoryString;

        _result = _result + _newLine;
        _result = _result + _indent + _indent + "};" + _newLine;
        _result = _result + _newLine;

        _result = _result + _indent + "};" + _newLine;
        _result = _result + "};";

    };

    case "formatGroupsToGroupCategory": {

        _args params ["_category","_groupsString"];

        private _categoryConfigName = [_category,"configName"] call ALiVE_fnc_hashGet;
        private _categoryDisplayName = [_category,"name"] call ALiVE_fnc_hashGet;

        private _newLine = toString [13,10];
        private _indent = "    ";
        _result = "";

        _result = _result + _indent + _indent + _indent + "class " + _categoryConfigName + " {" + _newLine;
        _result = _result + _indent + _indent + _indent + _indent + "name = " + str _categoryDisplayName + ";" + _newLine;
        _result = _result + _newLine;

        _result = _result + _groupsString;

        _result = _result + _newLine;
        _result = _result + _indent + _indent + _indent + "};" + _newLine;

    };

    case "exportGroupsInCategory": {

        private ["_groupData","_groupsOutputString"];

        _args params ["_category","_groups"];

        private _categoryConfigName = [_category,"configName"] call ALiVE_fnc_hashGet;
        private _categoryDisplayName = [_category,"name"] call ALiVE_fnc_hashGet;
        private _categoryGroups = [_category,"groups"] call ALiVE_fnc_hashGet;

        private _groupHashes = [];
        {
            _groupData = [_categoryGroups,_x] call ALiVE_fnc_hashGet;
            _groupHashes pushback _groupData;
        } foreach _groups;

        private _newLine = toString [13,10];
        private _indent = "    ";
        _result = "";

        _result = _result + _indent + _indent + _indent + "class " + _categoryConfigName + " {" + _newLine;
        _result = _result + _indent + _indent + _indent + _indent + "name = " + str _categoryDisplayName + ";" + _newLine;
        _result = _result + _newLine;

        // get groups ouput

        {
            _groupsOutputString = [_logic,"exportGroup", _x] call MAINCLASS;
            _result = _result + _groupsOutputString;
            _result = _result + _newLine;
        } foreach _groupHashes;

        _result = _result + _indent + _indent + _indent + "};" + _newLine;

    };

    case "exportGroup": {

        private _group = _args;

        if (_group isEqualType []) then {

            private _groupConfigName = [_group,"configName"] call ALiVE_fnc_hashGet;
            private _groupDisplayName = [_group,"name"] call ALiVE_fnc_hashGet;
            private _groupSide = [_group,"side"] call ALiVE_fnc_hashGet;
            private _groupFaction = [_group,"faction"] call ALiVE_fnc_hashGet;
            private _groupIcon = [_group,"icon"] call ALiVE_fnc_hashGet;
            private _groupRarity = [_group,"rarityGroup"] call ALiVE_fnc_hashGet;
            private _groupUnits = [_group,"units"] call ALiVE_fnc_hashGet;

            private _newLine = toString [13,10];
            private _indent = "    ";
            private _indentOuter = _indent + _indent + _indent + _indent;
            private _indentInner = _indentOuter + _indent;
            _result = "";

            _result = _result + _indentOuter + "class " + _groupConfigName + " {" + _newLine;
            _result = _result + _indentInner + "name = " + str _groupDisplayName + ";" + _newLine;
            _result = _result + _indentInner + "side = " + str _groupSide + ";" + _newLine;
            _result = _result + _indentInner + "faction = " + str _groupFaction + ";" + _newLine;
            _result = _result + _indentInner + "icon = " + str _groupIcon + ";" + _newLine;
            _result = _result + _indentInner + "rarityGroup = " + str _groupRarity + ";" + _newLine;

            _result = _result + _newLine;

            {
                _unit = _x;
                _unitPosition = [_unit,"position"] call ALiVE_fnc_hashGet;
                _unitPosition = [_logic,"arrayToConfigArrayString", _unitPosition] call MAINCLASS;
                _unitRank = [_unit,"rank"] call ALiVE_fnc_hashGet;
                _unitSide = [_unit,"side"] call ALiVE_fnc_hashGet;
                _unitVehicle = [_unit,"vehicle"] call ALiVE_fnc_hashGet;

                _result = _result + _indentInner + "class Unit" + str _forEachIndex + " {" + _newLine;
                _result = _result + _indentInner + _indent + "position[] = " + _unitPosition + ";" + _newLine;
                _result = _result + _indentInner + _indent + "rank = " + str _unitRank + ";" + _newLine;
                _result = _result + _indentInner + _indent + "side = " + str _unitSide + ";" + _newLine;
                _result = _result + _indentInner + _indent + "vehicle = " + str _unitVehicle + ";" + _newLine;
                _result = _result + _indentInner + "};" + _newLine;
            } foreach _groupUnits;

            _result = _result + _indentOuter + "};" + _newLine;
        };

    };

    case "exportFaction": {

        private ["_category","_categoryGroups","_categoryGroupClasses","_groupCategoryExportString"];

        private _faction = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionConfigName = [_factionData,"configName"] call ALiVE_fnc_hashGet;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
        private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;
        private _factionIcon = [_factionData,"icon"] call ALiVE_fnc_hashGet;
        private _factionPriority = [_factionData,"priority"] call ALiVE_fnc_hashGet;

        if (_factionIcon == "") then {
            _factionIcon = _factionFlag;
        };

        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;
        private _categoryGroupPairs = [];

        {
            _category = _x;
            _categoryGroups = [_category,"groups"] call ALiVE_fnc_hashGet;
            _categoryGroupClasses = _categoryGroups select 1;

            _categoryGroupPairs pushback [_category,_categoryGroupClasses];
        } foreach (_factionGroupCategories select 2);

        private _newLine = toString [13,10];
        private _indent = "    ";
        _result = "";

        // CfgFactionClasses

        _result = _result + "class CfgFactionClasses {" + _newLine;
        _result = _result + _indent + "class " + _factionConfigName + " {" + _newLine;
        _result = _result + _indent + _indent + "displayName = " + str _factionDisplayName + ";" + _newLine;
        _result = _result + _indent + _indent + "side = " + str _factionSide + ";" + _newLine;
        _result = _result + _indent + _indent + "flag = " + str _factionFlag + ";" + _newLine;
        _result = _result + _indent + _indent + "icon = " + str _factionIcon + ";" + _newLine;
        _result = _result + _indent + _indent + "priority = " + str _factionPriority + ";" + _newLine;
        _result = _result + _indent + "};" + _newLine;
        _result = _result + "};";

        // CfgGroups

        _result = _result + _newLine + _newLine;
        private _CFGgroups = "";
        {
            _groupCategoryExportString = [_logic,"exportGroupsInCategory", _x] call MAINCLASS;
            _CFGgroups = _CFGgroups + _groupCategoryExportString + _newLine;
        } foreach _categoryGroupPairs;

        _CFGgroups = [_logic,"formatGroupCategoriesToFaction", [_faction,_CFGgroups]] call MAINCLASS;

        _result = _result + _CFGgroups;

        // CfgVehicles

        private _factionCustomUnits = [];

        {
            _customUnit = _x;
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;
            _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _faction) then {
                _factionCustomUnits pushback _customUnitConfigName;
            };
        } foreach (_customUnits select 2);

        if (count _factionCustomUnits > 0) then {
            _result = _result + _newLine + _newLine;
            private _CFGvehicles = [_logic,"exportCustomUnits", _factionCustomUnits] call MAINCLASS;
            _result = _result + _CFGvehicles;
        };

    };


    // helper functions
    // config generation


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