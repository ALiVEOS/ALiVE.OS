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

// UI components

#include "\x\alive\addons\sys_orbatcreator\data\ui\include.hpp"

// control Macros

#define OC_getControl(disp,ctrl)    ((findDisplay disp) displayCtrl ctrl)
#define OC_getSelData(ctrl)         (lbData [ctrl,(lbCurSel ctrl)])
#define OC_ctrlGetSelData(ctrl)     (ctrl lbData (lbCurSel ctrl))

// general macros

#define ALIVE_COMPATIBLE_GROUP_CATEGORIES   ["Infantry","SpecOps","Motorized","Motorized_MTP","Mechanized","Armored","Artillery","Naval","Air","Support"]

#define FACTION_BLACKLIST ["Virtual_F","Interactive_F"]

#define COLOR_SIDE_EAST [profilenamespace getvariable ["Map_OPFOR_R",0],profilenamespace getvariable ["Map_OPFOR_G",1],profilenamespace getvariable ["Map_OPFOR_B",1],profilenamespace getvariable ["Map_OPFOR_A",0.8]]
#define COLOR_SIDE_WEST [profilenamespace getvariable ["Map_BLUFOR_R",0],profilenamespace getvariable ["Map_BLUFOR_G",1],profilenamespace getvariable ["Map_BLUFOR_B",1],profilenamespace getvariable ["Map_BLUFOR_A",0.8]]
#define COLOR_SIDE_GUER [profilenamespace getvariable ["Map_Independent_R",0],profilenamespace getvariable ["Map_Independent_G",1],profilenamespace getvariable ["Map_Independent_B",1],profilenamespace getvariable ["Map_Independent_A",0.8]]

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

        private _debug = ((_logic getVariable ["debug","false"]) == "true");

        [_logic,"debug", _debug] call MAINCLASS;

        private _background = ((_logic getVariable ["background", "true"]) == "true");

        [_logic,"background", _background] call MAINCLASS;

        private _prefix = (_logic getVariable ["prefix", ""]);

        [_logic,"prefix", _prefix] call MAINCLASS;

        // data init

        // load static data
        call ALiVE_fnc_staticDataHandler;

        private _tmpHash = [] call ALiVE_fnc_hashCreate;

        private _state = +_tmpHash;
        [_logic,"state", _state] call MAINCLASS;

        // init factions by side
        _east = +_tmpHash;
        _west = +_tmpHash;
        _indep = +_tmpHash;

        private _factions = +_tmpHash;

        private _assetsByFaction = [_logic,"initAssetsByFaction"] call MAINCLASS;

        private _allFactions = [] call ALiVE_fnc_configGetFactions;

        {
            private _faction = _x;
            private _factionClass = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSide = getNumber (_factionClass >> "side");

            if (_factionSide >= 0 && {_factionSide <= 3}) then {
                private _factionConfigName = _faction;
                private _factionDisplayName = getText (_factionClass >> "displayName");
                private _factionFlag = getText (_factionClass >> "flag");
                private _factionIcon = getText (_factionClass >> "icon");
                private _factionPriority = getNumber (_factionClass >> "priority");

                private _factionAssetData = [_assetsByFaction, tolower _faction] call ALiVE_fnc_hashGet;
                private _factionAssetCategories = _factionAssetData select 0;
                private _factionAssets = _factionAssetData select 1;

                // create SQF representation of faction

                _newFaction = [nil,"create"] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"init"] call ALiVE_fnc_orbatCreatorFaction;

                private _factionGroupCategories = [_newFaction,"groupCategories"] call ALiVE_fnc_hashGet;
                _factionGroupCategoriesData = [_logic,"initFactionGroupCategories", _factionGroupCategories] call MAINCLASS;

                _factionGroupCategoriesData params ["_factionGroupCategoriesName","_factionGroupCategories"];

                [_newFaction,"configName", _factionConfigName] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"displayName", _factionDisplayName] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"flag", _factionFlag] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"icon", _factionIcon] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"priority", _factionPriority] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"side", _factionSide] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"groupCategoriesRootName", _factionGroupCategoriesName] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"groupCategories", _factionGroupCategories] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"assetCategories", _factionAssetCategories] call ALiVE_fnc_orbatCreatorFaction;
                [_newFaction,"assets", _factionAssets] call ALiVE_fnc_orbatCreatorFaction;

                [_factions,_factionConfigName,_newFaction] call ALiVE_fnc_hashSet;
            };
        } foreach _allFactions;

        [_state,"factions", _factions] call ALiVE_fnc_hashSet;

        private _customUnits = +_tmpHash;
        [_state,"customUnits", _customUnits] call ALiVE_fnc_hashSet;

        [_state,"activeInteface", ""] call ALiVE_fnc_hashSet;
        [_state,"selectedFaction", ""] call ALiVE_fnc_hashSet;

        [_state,"factionEditor_treeDisplayType", ""] call ALiVE_fnc_hashSet;

        [_state,"unitEditor_interfaceBackground", objNull] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_interfaceCamera", objNull] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_activeUnitPosition", [0,0,0]] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_activeUnitObject", objNull] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_selectedUnit", ""] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_unitToSelect", ""] call ALiVE_fnc_hashSet;
        [_state,"unitEditor_arsenalOpen", false] call ALiVE_fnc_hashSet;

        [_state,"editVehicle_vehicle", ""] call ALiVE_fnc_hashSet;
        [_state,"editVehicle_selectedCrewBySlot", +_tmpHash] call ALiVE_fnc_hashSet;
        [_state,"editVehicle_selectedTexture", []] call ALiVE_fnc_hashSet;

        [_state,"groupEditor_selectedGroupCategory", ""] call ALiVE_fnc_hashSet;
        [_state,"groupEditor_selectedGroup", ""] call ALiVE_fnc_hashSet;
        [_state,"groupEditor_selectedGroupDragTargetIndex", -1] call ALiVE_fnc_hashSet;
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
                ["main", "alive_flexiMenu_rscPopup"]
            ]
        ] call CBA_fnc_flexiMenu_Add;

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

    case "prefix": {

        if (_args isEqualType "") then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, ""];
        };

    };

    case "copyParent": {

        if (_args isEqualType true) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, false];
        };

    };
    case "state": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, [] call ALiVE_fnc_hashCreate];
        };

    };

    case "onAction": {

        _args params ["_operation","_args"];

        /*
        switch (_operation) do {

            default {[_logic,_operation,_args] call MAINCLASS};

        };
        */

        [_logic,_operation,_args] call MAINCLASS

    };

    case "openInterface": {

        private _interface = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        switch (_interface) do {

            case "Faction_Editor": {

                closeDialog 0;
                sleep 0.001; // bis pls
                createDialog "ALiVE_orbatCreator_interface_factionEditor";

                // if reopening orbat creator
                // init background

                private _background = [_state,"unitEditor_interfaceBackground"] call ALiVE_fnc_hashGet;
                if (isnull _background) then {
                    [_logic,"enableUnitEditorBackground", true] call MAINCLASS;
                };

            };

            case "Create_Faction": {

                createDialog "ALiVE_orbatCreator_interface_createFaction";

            };

            case "Edit_Faction": {

                createDialog "ALiVE_orbatCreator_interface_editFaction";

            };

            case "Copy_Faction": {

                createDialog "ALiVE_orbatCreator_interface_createFaction";

            };

            case "Unit_Editor": {

                closeDialog 0;
                sleep 0.03; // bis pls
                createDialog "ALiVE_orbatCreator_interface_unitEditor";

            };

            case "Create_Unit": {

                createDialog "ALiVE_orbatCreator_interface_createUnit";

            };

            case "Unit_Editor_Edit_Properties": {

                createDialog "ALiVE_orbatCreator_interface_editUnit";

            };

            case "Edit_Vehicle": {

                createDialog "ALiVE_orbatCreator_interface_editVehicle";

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
        [_state,"activeInteface", _interface] call ALiVE_fnc_hashSet;

    };

    case "onLoad": {

        private _interface = _args;
        private _state = [_logic,"state"] call MAINCLASS;

        switch (_interface) do {

            case "Faction_Editor": {

                private [
                    "_faction","_factionDisplayName","_factionConfigName","_factionFlag",
                    "_index","_sideText","_sideTextLong","_marker","_markerClass","_markerName",
                    "_markerIcon","_factionConfig","_factionConfigFlag","_factionConfigDisplayName",
                    "_factionConfigMarkerName"
                ];

                private _display = findDisplay OC_DISPLAY_FACTIONEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', ['Faction_Editor',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionButton1 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_BUTTON_ONE );
                _factionButton1 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorNewClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionButton1 ctrlSetTooltip "Create a new faction.";
                _factionButton1 ctrlSetText "New";

                private _factionButton2 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_BUTTON_TWO );
                _factionButton2 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorEditClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionButton2 ctrlSetTooltip "Edit selected faction";
                _factionButton2 ctrlSetText "Edit";

                private _factionButton3 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_BUTTON_THREE );
                _factionButton3 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorCopyClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionButton3 ctrlSetTooltip "Copy Selected Faction";
                _factionButton3 ctrlSetText "Copy";

                private _factionButton4 = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_BUTTON_FOUR );
                _factionButton4 ctrlSetEventHandler ["MouseButtonDown","['onFactionEditorDeleteClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionButton4 ctrlSetTooltip "Delete selected faction   Warning: Will delete the faction, its units, and its groups.";
                _factionButton4 ctrlSetText "Delete";

                private _factionList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
                _factionList ctrlSetEventHandler ["LBSelChanged","['onFactionEditorFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                [_logic,"loadFactionToList", _factionList] call MAINCLASS;
                lbSort [_factionList, "ASC"];

                private _selectedFaction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                if (_selectedFaction == "") then {
                    _factionList lbSetCurSel 0;
                } else {
                    [_factionList,_selectedFaction] call ALiVE_fnc_listSelectData;
                };

            };

            case "Create_Faction": {

                private [
                    "_index","_marker","_markerClass","_markerName","_markerIcon",
                    "_factionConfig","_factionConfigSide","_factionConfigFlag",
                    "_factionConfigDisplayName","_factionConfigMarkerName"
                ];

                private _display = findDisplay OC_DISPLAY_CREATEFACTION;
                _display displayAddEventHandler ["unload", "['onUnload', ['Create_Faction',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonOk = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_BUTTON_OK );
                _buttonOk ctrlSetEventHandler ["MouseButtonDown","['onCreateFactionOkClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonAutogen = OC_getControl( OC_DISPLAY_CREATEFACTION, OC_CREATEFACTION_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogen ctrlSetEventHandler ["MouseButtonDown","['onCreateFactionAutogenerateClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _inputSide = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_SIDE );
                private _inputFlag = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_FLAG );

                // populate side list

                [_logic,"loadSidesToList", _inputSide] call MAINCLASS;

                // populate flag list

                private _allFlags = [];
                private _markerPath = configFile >> "CfgMarkers";

                for "_i" from 0 to (count _markerPath - 1) do {
                    _marker = _markerPath select _i;

                    if (isClass _marker) then {
                        _markerClass = getText (_marker >> "markerClass");

                        if (_markerClass == "Flags") then {
                            _markerName = getText (_marker >> "name");
                            _markerIcon = getText (_marker >> "icon");

                            _allFlags pushback [_markerName,_markerIcon];
                        };
                    };
                };

                private _factionPath = configFile >> "CfgFactionClasses";

                for "_i" from 0 to (count _factionPath - 1) do {
                    _factionConfig = _factionPath select _i;

                    if (isClass _factionConfig) then {
                        _factionConfigSide = getNumber (_factionConfig >> "side");
                        _factionConfigFlag = getText (_factionConfig >> "flag");

                        if (_factionConfigSide >= 0 && {_factionConfigSide <= 3} && {!(_factionConfigFlag in _allFlags)}) then {
                            _factionConfigDisplayName = getText (_factionConfig >> "displayName");
                            _factionConfigMarkerName = format ["Flag - %1", _factionConfigDisplayName];

                            _allFlags pushback [_factionConfigMarkerName,_factionConfigFlag];
                        };
                    };
                };

                {
                    _x params ["_name","_path"];

                    _index = _inputFlag lbAdd _name;
                    _inputFlag lbSetData [_index,_path];
                    _inputFlag lbSetPicture [_index,_path];
                } foreach _allFlags;

                _inputSide lbSetCurSel 0;
                _inputFlag lbSetCurSel 0;

            };

            case "Edit_Faction": {

                [_logic,"onLoad", "Create_Faction"] call MAINCLASS;

                private _display = findDisplay OC_DISPLAY_CREATEFACTION;
                _display displayAddEventHandler ["unload", "['onUnload', ['Edit_Faction',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonOk = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_BUTTON_OK );
                _buttonOk ctrlSetEventHandler ["MouseButtonDown","['onEditFactionOkClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonAutogen = OC_getControl( OC_DISPLAY_CREATEFACTION, OC_CREATEFACTION_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogen ctrlSetEventHandler ["MouseButtonDown","['onCreateFactionAutogenerateClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
                private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
                private _factionClassname = [_factionData,"configName"] call ALiVE_fnc_hashGet;
                private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
                private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;

                private _header = OC_getControl( OC_DISPLAY_CREATEFACTION , 8301 );
                _header ctrlSetText format["Edit %1 Faction", _factionDisplayName];

                private _inputDisplayName = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_DISPLAYNAME );
                private _inputClassName = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CLASSNAME );
                private _inputSide = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_SIDE );
                private _inputFlag = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_FLAG );

                _inputDisplayName ctrlSetText _factionDisplayName;
                _inputClassName ctrlSetText _factionClassname;

                [_inputSide,str _factionSide] call ALiVE_fnc_listSelectData;
                [_inputFlag,_factionFlag] call ALiVE_fnc_listSelectData;

            };

			case "Copy_Faction": {

				private [
                    "_index","_marker","_markerClass","_markerName","_markerIcon",
                    "_factionConfig","_factionConfigSide","_factionConfigFlag",
                    "_factionConfigDisplayName","_factionConfigMarkerName"
                ];

                private _display = findDisplay OC_DISPLAY_CREATEFACTION;
                _display displayAddEventHandler ["unload", "['onUnload', ['Create_Faction',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonOk = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_BUTTON_OK );
                _buttonOk ctrlSetEventHandler ["MouseButtonDown","['onCopyFactionOkClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonAutogen = OC_getControl( OC_DISPLAY_CREATEFACTION, OC_CREATEFACTION_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogen ctrlSetEventHandler ["MouseButtonDown","['onCreateFactionAutogenerateClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
                private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
                private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;
                private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;

                private _header = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_HEADER );
                _header ctrlSetText format["Copy %1 Faction", _factionDisplayName];

                private _inputSide = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_SIDE );
                private _inputFlag = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_FLAG );

                // populate side list
                [_logic,"loadSidesToList", _inputSide] call MAINCLASS;

                // populate flag list

                private _allFlags = [];
                private _markerPath = configFile >> "CfgMarkers";

                for "_i" from 0 to (count _markerPath - 1) do {
                    _marker = _markerPath select _i;

                    if (isClass _marker) then {
                        _markerClass = getText (_marker >> "markerClass");

                        if (_markerClass == "Flags") then {
                            _markerName = getText (_marker >> "name");
                            _markerIcon = getText (_marker >> "icon");

                            _allFlags pushback [_markerName,_markerIcon];
                        };
                    };
                };

                private _factionPath = configFile >> "CfgFactionClasses";

                for "_i" from 0 to (count _factionPath - 1) do {
                    _factionConfig = _factionPath select _i;

                    if (isClass _factionConfig) then {
                        _factionConfigSide = getNumber (_factionConfig >> "side");
                        _factionConfigFlag = getText (_factionConfig >> "flag");

                        if (_factionConfigSide >= 0 && {_factionConfigSide <= 3} && {!(_factionConfigFlag in _allFlags)}) then {
                            _factionConfigDisplayName = getText (_factionConfig >> "displayName");
                            _factionConfigMarkerName = format ["Flag - %1", _factionConfigDisplayName];

                            _allFlags pushback [_factionConfigMarkerName,_factionConfigFlag];
                        };
                    };
                };

                {
                    _x params ["_name","_path"];

                    _index = _inputFlag lbAdd _name;
                    _inputFlag lbSetData [_index,_path];
                    _inputFlag lbSetPicture [_index,_path];
                } foreach _allFlags;

                [_inputSide,str _factionSide] call ALiVE_fnc_listSelectData;
                [_inputFlag,_factionFlag] call ALiVE_fnc_listSelectData;

			};

            case "Unit_Editor": {

                private _display = findDisplay OC_DISPLAY_UNITEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', ['Unit_Editor',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                // init class list

                private _classList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
                _classList ctrlSetEventHandler ["LBSelChanged","['onUnitEditorUnitListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_FACTIONS_LIST );
                [_logic,"loadFactionToList", _factionList] call MAINCLASS;

                lbSort [_factionList, "ASC"];

                _factionList ctrlSetEventHandler ["LBSelChanged","['onUnitEditorFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

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

                /*
                private _classList_button4 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR );
                _classList_button4 ctrlSetText "Copy";
                _classList_button4 ctrlSetTooltip "Create new unit from selected unit (No Inheritance)";
                _classList_button4 ctrlSetEventHandler ["MouseButtonDown","['unitEditorCopyClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button4 ctrlShow true;
                _classList_button4 ctrlEnable false;
                */

                private _classList_button4 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR );
                _classList_button4 ctrlSetText "Delete";
                _classList_button4 ctrlSetTooltip "Delete selected units";
                _classList_button4 ctrlSetEventHandler ["MouseButtonDown","['unitEditorDeleteClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button4 ctrlShow true;
                _classList_button4 ctrlEnable false;

                private _classList_button5 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FIVE );
                _classList_button5 ctrlShow false;

                private _classList_button6 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_SIX );
                _classList_button6 ctrlSetText "Import Units From Config";
                _classList_button6 ctrlSetTooltip "Import all faction units for editing";
                _classList_button6 ctrlSetEventHandler ["MouseButtonDown","['unitEditorImportConfigClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button6 ctrlShow true;
                _classList_button6 ctrlShow false;

                // execute last to ensure all EH's set

                private _selectedFactionGlobal = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                if (_selectedFactionGlobal == "") then {
                    _factionList lbSetCurSel 0;
                } else {
                    [_factionList,_selectedFactionGlobal] call ALiVE_fnc_listSelectData;
                };

                private _unitToSelect = [_state,"unitEditor_unitToSelect"] call ALiVE_fnc_hashGet;

                if (_unitToSelect != "") then {
                    [_classList,[_unitToSelect], true] call ALiVE_fnc_listSelectData;
                    [_state,"unitEditor_unitToSelect", ""] call ALiVE_fnc_hashSet;
                };

                private _cam = [_state,"unitEditor_interfaceCamera"] call ALiVE_fnc_hashGet;

                if !(isnull _cam) then {
                    _cam cameraEffect ["Internal", "Back"];
                } else {
                    [_logic,"enableUnitEditorBackground", true] call MAINCLASS;
                };

            };

            case "Create_Unit": {

                private ["_sideNum","_sideText","_sideTextLong","_index","_voice"];

                private _display = findDisplay OC_DISPLAY_CREATEUNIT;
                _display displayAddEventHandler ["unload", "['onUnload', ['Create_Unit',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                // get faction selected in unit editor

                private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
                private _selectedFaction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _selectedFactionData = [_factions,_selectedFaction] call ALiVE_fnc_hashGet;
                private _selectedFactionSide = [_selectedFactionData,"side"] call ALiVE_fnc_hashGet;

                // lists must init in "reverse" order for events to properly fire on opening

                // init unit type class list

                private _classList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
                _classList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeClassChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init unit type unit category list

                private _unitTypeCategoryList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_CATEGORY );
                _unitTypeCategoryList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeUnitCategoryChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init unit type faction list

                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
                _unitTypeFactionList ctrlSetEventHandler ["lbSelChanged","['onCreateUnitUnitTypeFactionChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init side lists

                private _sideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_SIDE );
                _sideList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _unitTypeSideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_SIDE );
                _unitTypeSideList ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitTypeSideChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                for "_i" from 0 to 3 do {
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

                private _selectedFaction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_FACTION );
                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );

                [_factionList,_selectedFaction] call ALiVE_fnc_listSelectData;
                [_unitTypeFactionList,_selectedFaction] call ALiVE_fnc_listSelectData;

                // init buttons

                private _buttonOK = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CONFIRM );
                _buttonOK ctrlSetEventHandler ["MouseButtonDown","['onCreateUnitConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonAutogen = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogen ctrlSetEventHandler ["MouseButtonDown","['onCreateUnitAutogenerateClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            };

            case "Unit_Editor_Edit_Properties": {

                private [
                    "_sideNum","_sideText","_sideTextLong","_index","_indexFaction",
                    "_unitParentSide","_unitParentFaction","_indexUnit","_unitParentEditorSubcategory"
                ];

                private _display = findDisplay OC_DISPLAY_CREATEUNIT;
                _display displayAddEventHandler ["unload", "['onUnload', ['Unit_Editor_Edit_Properties',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                [_logic,"onLoad", "Create_Unit"] call MAINCLASS;

                // overwrite unit type category list event

                private _unitTypeCategoryList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_CATEGORY );
                _unitTypeCategoryList ctrlSetEventHandler ["LBSelChanged","['onEditUnitUnitTypeUnitCategoryChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // get selected unit data

                private _selectedUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
                private _selectedUnitData = [_logic,"getCustomUnit", _selectedUnit] call MAINCLASS;

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

                private _sideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_SIDE );
                private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_FACTION );

                private _unitFactionData = [_logic,"getFactionData", _unitFaction] call MAINCLASS;
                private _factionSide = [_unitFactionData,"side"] call ALiVE_fnc_hashGet;

                [_sideList, str _factionSide] call ALiVE_fnc_listSelectData;
                [_factionList, _unitFaction] call ALiVE_fnc_listSelectData;

                // get parent unit side / faction

                private _unitParentData = [_logic,"getCustomUnit", _unitParent] call MAINCLASS;
                private _cfgVehicles = configFile >> "CfgVehicles";

                if (isnil "_unitParentData") then {
                    _unitParentData = _cfgVehicles >> _unitParent;
                    _unitParentFaction = tolower (getText (_unitParentData >> "faction"));
                    _unitParentEditorSubcategory = getText (_unitParentData >> "editorSubcategory");

                    private _unitParentFactionClass = _unitParentFaction call ALiVE_fnc_configGetFactionClass;
                    _unitParentSide = getNumber (_unitParentFactionClass >> "side");
                } else {
                    _unitParentFaction = [_unitParentData,"faction"] call ALiVE_fnc_hashGet;

                    private _unitParentFactionData = [_logic,"getFactionData", _unitParentFaction] call MAINCLASS;
                    _unitParentSide = [_unitParentFactionData,"side"] call ALiVE_fnc_hashGet;

                    _realUnitParent = [_logic,"getRealUnitClass", _unitParent] call MAINCLASS;
                    _unitParentEditorSubcategory = getText (_cfgVehicles >> _realUnitParent >> "editorSubcategory");
                };

                private _unitTypeSideList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_SIDE );
                private _unitTypeFactionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
                private _unitTypeCategoryList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_CATEGORY );

                [_unitTypeSideList, str _unitParentSide] call ALiVE_fnc_listSelectData;
                [_unitTypeFactionList,_unitParentFaction] call ALiVE_fnc_listSelectData;
                [_unitTypeCategoryList,_unitParentEditorSubcategory] call ALiVE_fnc_listSelectData;

                // init buttons

                private _buttonOK = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_BUTTON_CONFIRM );
                _buttonOK ctrlSetEventHandler ["MouseButtonDown","['onEditUnitConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            };

            case "Edit_Vehicle": {

                private _display = findDisplay OC_DISPLAY_EDITVEHICLE;
                _display displayAddEventHandler ["unload", "['onUnload', ['Edit_Vehicle',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

                // init bottom control bar

                private _controlBar_bottom_cancel = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_CONTROLBAR_CANCEL );
                _controlBar_bottom_cancel ctrlSetEventHandler ["MouseButtonDown","['onEditVehicleCancelClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _controlBar_bottom_save = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_CONTROLBAR_SAVE );
                _controlBar_bottom_save ctrlSetEventHandler ["MouseButtonDown","['onEditVehicleSaveClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                // init left side buttons

                private _left_icon_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_ICON_ONE );
                _left_icon_one ctrlSetText "\A3\Ui_f\data\GUI\Rsc\RscDisplayGarage\crew_ca.paa";

                private _left_button_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_BUTTON_ONE );
                _left_button_one ctrlSetEventHandler ["MouseButtonDown","['onEditVehicleCrewClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _left_button_one ctrlSetTooltip "Crew";

                private _left_list_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_ONE );
                _left_list_one ctrlSetEventHandler ["lbSelChanged","['onEditVehicleCrewChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _left_list_one ctrlshow false;

                private _left_icon_two = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_ICON_TWO );
                _left_icon_two ctrlSetText "\A3\Ui_f\data\GUI\Rsc\RscDisplayGarage\textureSources_ca.paa";

                private _left_button_two = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_BUTTON_TWO );
                _left_button_two ctrlSetEventHandler ["MouseButtonDown","['onEditVehicleAppearanceClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _left_button_two ctrlSetTooltip "Appearance";

                private _left_list_two = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_TWO );
                _left_list_two ctrlSetEventHandler ["lbSelChanged","['onEditVehicleAppearanceSelected', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _left_list_two ctrlshow false;

                private _left_icon_three = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_ICON_THREE );
                _left_icon_three ctrlshow false;

                private _left_button_three = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_BUTTON_THREE );
                _left_button_three ctrlshow false;

                private _left_list_three = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_THREE );
                _left_list_three ctrlSetEventHandler ["lbSelChanged","['onEditVehicleListThreeSelected', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _left_list_three ctrlshow false;

                private _rightListOneTitle = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE_TITLE );
                _rightListOneTitle ctrlSetText "Crew Slot";
                _rightListOneTitle ctrlShow false;

                private _rightListOne = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE );
                _rightListOne ctrlSetEventHandler ["LBSelChanged","['onEditVehicleCrewSlotChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _rightListOne ctrlShow false;

                // init selected items

                private _selectedVehicle = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
                private _selectedVehicleData = [_logic,"getCustomUnit", _selectedVehicle] call MAINCLASS;

                private _selectedVehicleCrew = [_selectedVehicleData,"crew"] call ALiVE_fnc_hashGet;
                private _selectedVehicleTurrets = [_selectedVehicleData,"turrets"] call ALiVE_fnc_hashGet;
                private _selectedVehicleTexture = [_selectedVehicleData,"texture"] call ALiVE_fnc_hashGet;

                private _selectedCrewBySlot = [] call ALiVE_fnc_hashCreate;
                [_selectedCrewBySlot,"crew", _selectedVehicleCrew] call ALiVE_fnc_hashSet;

                {
                    [_selectedCrewBySlot,(_x select 0), _x select 2] call ALiVE_fnc_hashSet;
                } foreach (_selectedVehicleTurrets select 2);

                [_state,"editVehicle_vehicle", _selectedVehicle] call ALiVE_fnc_hashSet;
                [_state,"editVehicle_selectedCrewBySlot", _selectedCrewBySlot] call ALiVE_fnc_hashSet;
                [_state,"editVehicle_selectedTexture", _selectedVehicleTexture] call ALiVE_fnc_hashSet;

                // populate crew list

                private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
                private _cfgVehicles = configfile >> "CfgVehicles";
                private _addedUnits = [];

                private _index = _left_list_one lbAdd "None";
                _left_list_one lbSetData [_index,""];

                {
                    private _customUnit = _x;
                    private _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;
                    private _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;

                    if (_customUnitFaction == _faction) then {
                        private _customUnitRealUnit = [_logic,"getRealUnitClass", _customUnitConfigName] call MAINCLASS;

                        if (_customUnitRealUnit isKindOf "Man") then {
                            private _customUnitDisplayName = [_customUnit,"displayName"] call ALiVE_fnc_hashGet;

                            private _index = _left_list_one lbAdd _customUnitDisplayName;
                            _left_list_one lbSetData [_index,_customUnitConfigName];

                            _addedUnits pushback _customUnitConfigName;
                        };
                    };
                } foreach (_customUnits select 2);

                private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
                private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;

                private _cfgVehicles = configFile >> "CfgVehicles";
                {
                    private _assetConfigName = _x;

                    if (!(_assetConfigName in _addedUnits) && {_assetConfigName isKindOf "Man"}) then {
                        private _assetConfig = _cfgVehicles >> _assetConfigName;
                        private _assetDisplayName = getText (_assetConfig >> "displayName");

                        _index = _left_list_one lbAdd _assetDisplayName;
                        _left_list_one lbSetData [_index,_assetConfigName];
                    };
                } foreach _factionAssets;

                // populate crew slots

                private _selectedUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
                private _selectedUnitData = [_logic,"getCustomUnit", _selectedUnit] call MAINCLASS;

                private _turrets = [_selectedUnitData,"turrets"] call ALiVE_fnc_hashGet;

                private _selectedUnitClassname = [_selectedUnitData,"configName"] call ALiVE_fnc_hashGet;
                private _selectedUnitRootClassname = [_logic,"getRealUnitClass", _selectedUnitClassname] call MAINCLASS;
                private _selectedUnitConfig = configfile >> "CfgVehicles" >> _selectedUnitRootClassname;
                private _selectedUnitHasDriver = getNumber (_selectedUnitConfig >> "hasDriver");

                if (_selectedUnitHasDriver == 1) then {
                    private _index = _rightListOne lbAdd "Driver";
                    _rightListOne lbSetData [_index,"crew"];
                };

                {
                    _x params ["_turretConfigName","_turretDisplayName"];

                    private _index = _rightListOne lbAdd _turretDisplayName;
                    _rightListOne lbSetData [_index,_turretConfigName];
                } foreach (_turrets select 2);

            };

            case "Group_Editor": {

                private ["_index"];

                private _display = findDisplay OC_DISPLAY_GROUPEDITOR;
                _display displayAddEventHandler ["unload", "['onUnload', ['Group_Editor',_this]] call ALiVE_fnc_orbatCreatorOnAction"];

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
                _groupsButton3 ctrlSetText "Copy";
                _groupsButton3 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorGroupsCopyClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsButton3 ctrlShow true;

                private _groupsButton4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_FOUR );
                _groupsButton4 ctrlSetText "Delete";
                _groupsButton4 ctrlSetEventHandler ["MouseButtonDown","['onGroupEditorGroupsDeleteClicked'] call ALiVE_fnc_orbatCreatorOnAction"];
                _groupsButton4 ctrlShow true;

                // init asset list

                private _assetCategoryList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_INPUT_CATEGORY );
                _assetCategoryList ctrlSetEventHandler ["lbSelChanged","['onGroupEditorAssetCategoryChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

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

                private _groupUnitListGreenCover = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS_GREENCOVER );
                _groupUnitListGreenCover ctrlshow false;

                private _selectedGroupUnitRank = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_INPUT_UNITRANK );
                _selectedGroupUnitRank ctrlSetEventHandler ["LBSelChanged","['onGroupEditorSelectedGroupUnitRankChangedClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _cfgRanks = configFile >> "CfgRanks";

                // process in reverse order to have higher ranks higher in the list
                for "_i" from (count _cfgRanks - 1) to 0 step -1 do {
                    _rank = _cfgRanks select _i;
                    _rankDisplayName = getText (_rank >> "displayName");
                    _rankImage = getText (_rank >> "texture");

                    if (_rankDisplayName != "General") then {
                        _index = _selectedGroupUnitRank lbAdd _rankDisplayName;
                        _selectedGroupUnitRank lbSetData [_index,toUpper _rankDisplayName];
                        _selectedGroupUnitRank lbSetPicture [_index,_rankImage];
                    };
                };

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

                private _selectedFactionGlobal = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                if (_selectedFactionGlobal == "") then {
                    _factionList lbSetCurSel 0;
                } else {
                    [_factionList,_selectedFactionGlobal] call ALiVE_fnc_listSelectData;
                };

            };

            case "Create_Group": {

                private ["_sideMarkerClass","_sideColor","_sidePrefix","_icon"];

                private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

                private _factionData = [_logic,"getFactionData",_faction] call MAINCLASS;
                private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;

                // init category list

                private _inputCategory = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CATEGORY );
                [_logic,"loadFactionGroupCategoriesToList", [_inputCategory,_faction]] call MAINCLASS;

                private _selectedCategory = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
                [_inputCategory,_selectedCategory] call ALiVE_fnc_listSelectData;

                // init icon list

                private _inputIcon = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_ICON );

                private _colorSideEAST = COLOR_SIDE_EAST;
                private _colorSideWEST = COLOR_SIDE_WEST;
                private _colorSideGUER = COLOR_SIDE_GUER;

                switch (_factionSide) do {
                    case 0: {
                        _sideMarkerClass = "NATO_OPFOR";
                        _sideColor = _colorSideEAST;
                        _sidePrefix = 'o';
                    };
                    case 1: {
                        _sideMarkerClass = "NATO_BLUFOR";
                        _sideColor = _colorSideWEST;
                        _sidePrefix = 'b';
                    };
                    case 2: {
                        _sideMarkerClass = "NATO_Independent";
                        _sideColor = _colorSideGUER;
                        _sidePrefix = 'n';
                    };
                    default {
                        _sideMarkerClass = "NATO_BLUFOR";
                        _sideColor = _colorSideWEST;
                        _sidePrefix = 'b';
                    };
                };

                private _markerPath = configFile >> "CfgMarkers";
                private _markerBlacklist = ["Installation","HQ"];

                for "_i" from 0 to (count _markerPath - 1) do {
                    private _marker = _markerPath select _i;
                    private _markerClass = getText (_marker >> "markerClass");

                    if (_markerClass == _sideMarkerClass) then {
                        private _markerDisplayName = getText (_marker >> "name");

                        if !(_markerDisplayName in _markerBlacklist) then {
                            private _markerIcon = getText (_marker >> "icon");

                            private _index = _inputIcon lbAdd _markerDisplayName;
                            _inputIcon lbSetData [_index,_markerIcon];
                            _inputIcon lbSetPicture [_index,_markerIcon];
                            _inputIcon lbSetPictureColor [_index,_sideColor];
                            _inputIcon lbSetPictureColorSelected [_index,_sideColor];
                        };
                    };
                };

                // select default icon based on selected group category

                switch (_selectedCategory) do {
                    case "Infantry": {
                        _icon = "inf";
                    };
                    case "SpecOps": {
                        _icon = "recon";
                    };
                    case "Motorized": {
                        _icon = "motor_inf";
                    };
                    case "Motorized_MTP": {
                        _icon = "motor_inf";
                    };
                    case "Support": {
                        _icon = "support";
                    };
                    case "Mechanized": {
                        _icon = "mech_inf";
                    };
                    case "Armored": {
                        _icon = "armor";
                    };
                    case "Artillery": {
                        _icon = "art";
                    };
                    case "Naval": {
                        _icon = "naval";
                    };
                    case "Air": {
                        _icon = "air";
                    };

                    default {
                        _icon = "unknown";
                    };
                };

                _icon = format ["\A3\ui_f\data\map\markers\nato\%1_%2.paa", _sidePrefix, _icon];
                [_inputIcon,_icon] call ALiVE_fnc_listSelectData;

                // init buttons

                private _buttonAutogenClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_AUTOGEN_CLASSNAME );
                _buttonAutogenClassname ctrlSetEventHandler ["MouseButtonDown","['onCreateGroupAutogenClassnameClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _buttonConfirm = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_CONFIRM );
                _buttonConfirm ctrlSetEventHandler ["MouseButtonDown","['onCreateGroupConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            };

            case "Edit_Group": {

                [_logic,"onLoad", "Create_Group"] call MAINCLASS;

                private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
                private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

                private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
                private _groupName = [_groupData,"name"] call ALiVE_fnc_hashGet;
                private _groupConfigName = [_groupData,"configName"] call ALiVE_fnc_hashGet;
                private _groupIcon = [_groupData,"icon"] call ALiVE_fnc_hashGet;

                private _inputName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_NAME );
                private _inputClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CLASSNAME );
                private _inputCategory = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CATEGORY );

                _inputName ctrlSetText _groupName;
                _inputClassname ctrlSetText _groupConfigName;

                private _inputIcon = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_ICON );
                [_inputIcon,_groupIcon] call ALiVE_fnc_listSelectData;

                private _buttonConfirm = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_CONFIRM );
                _buttonConfirm ctrlSetEventHandler ["MouseButtonDown","['onEditGroupConfirmClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _listGroups = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
                private _selectedIndices = lbSelection _listGroups;

                if (count _selectedIndices > 1) then {
                    _inputName ctrlSetText "";
                    _inputName ctrlEnable false;

                    _inputClassname ctrlSetText "";
                    _inputClassname ctrlEnable false;

                    private _buttonAutogenClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_BUTTON_AUTOGEN_CLASSNAME );
                    _buttonAutogenClassname ctrlEnable false;
                };

            };

        };

    };

    case "onUnload": {

        _args params ["_interface","_eventData"];

        _eventData params ["_display","_exitCode"];

        private _state = [_logic,"state"] call MAINCLASS;

        switch (_interface) do {

            case "Faction_Editor": {

                if (_exitCode == 2) then {
                    [_logic,"enableUnitEditorBackground", false] call MAINCLASS;
                };

            };

            case "Create_Faction": {

                [_state,"activeInteface", "Faction_Editor"] call ALiVE_fnc_hashSet;

            };

            case "Edit_Faction": {

                [_state,"activeInteface", "Faction_Editor"] call ALiVE_fnc_hashSet;

            };

            case "Unit_Editor": {

                if (_exitCode == 2) then {
                    private _arsenalOpen = [_state,"unitEditor_arsenalOpen"] call ALiVE_fnc_hashGet;

                    if (!_arsenalOpen) then {
                        [_logic,"enableUnitEditorBackground", false] call MAINCLASS;
                    };
                };

            };

            case "Create_Unit": {

                [_state,"activeInteface", "Unit_Editor"] call ALiVE_fnc_hashSet;

            };

            case "Unit_Editor_Edit_Properties": {

                [_state,"activeInteface", "Unit_Editor"] call ALiVE_fnc_hashSet;

            };

            case "Edit_Vehicle": {

                [_state,"activeInteface", "Unit_Editor"] call ALiVE_fnc_hashSet;

            };

            case "Group_Editor": {

                [_state,"groupEditor_selectedGroupCategory", ""] call ALiVE_fnc_hashSet;
                [_state,"groupEditor_selectedGroup", ""] call ALiVE_fnc_hashSet;

                if (_exitCode == 2) then {
                    [_logic,"enableUnitEditorBackground", false] call MAINCLASS;
                };

            };

            case "Create_Group": {

                [_state,"activeInteface", "Group_Editor"] call ALiVE_fnc_hashSet;

            };

            case "Edit_Group": {

                [_state,"activeInteface", "Group_Editor"] call ALiVE_fnc_hashSet;

            };

        };

    };

    // menu strip

    case "onMenuStripButtonClicked": {

        _args params ["_control","_menuPath"];

        private _op = menuData [OC_COMMON_MENUSTRIP,_menuPath];

        switch (_op) do {

            case "orbatCreatorClose": {

                [_logic,"closeOrbatCreator"] call MAINCLASS;

            };

            case "factionEditorOpen": {

                [_logic,"openInterface", "Faction_Editor"] spawn MAINCLASS;

            };

            case "unitEditorOpen": {

                [_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

            };

            case "groupEditorOpen": {

                [_logic,"openInterface", "Group_Editor"] spawn MAINCLASS;

            };

            case "exportFaction": {

                [_logic,"exportConfig", "Faction"] call MAINCLASS;

            };

            case "exportCrates": {

                [_logic,"exportConfig", "Crates"] call MAINCLASS;

            };

            case "exportImages": {

                [_logic,"exportConfig", "Images"] call MAINCLASS;

            };

            case "exportUnitsSelected": {

                [_logic,"exportConfig", "UnitsSelected"] call MAINCLASS;

            };

            case "exportUnitsAll": {

                [_logic,"exportConfig", "UnitsAll"] call MAINCLASS;

            };

            case "exportUnitsClasses": {

                [_logic,"exportConfig", "UnitsClasses"] call MAINCLASS;

            };

            case "exportGroupsSelected": {

                [_logic,"exportConfig", "GroupsSelected"] call MAINCLASS;

            };

            case "exportGroupsAll": {

                [_logic,"exportConfig", "GroupsAll"] call MAINCLASS;

            };

            case "exportGroupsAllStaticData": {

                [_logic,"exportConfig", "GroupsAllStaticData"] call MAINCLASS;

            };

            case "exportFull": {

                [_logic,"exportConfig", "Full"] call MAINCLASS;

            };

            case "exportCfgPatches": {

                [_logic,"exportConfig", "CfgPatches"] call MAINCLASS;

            };

            case "exportFullWrite": {

                [_logic,"exportConfig", "FullWrite"] call MAINCLASS;

            };

            case "exportFullWriteImages": {

                [_logic,"exportConfig", "FullWriteImages"] call MAINCLASS;

            };
        };

    };

    case "closeOrbatCreator": {

        closeDialog 0;

        [_logic,"enableUnitEditorBackground", false] call MAINCLASS;

    };

    // helper functions
    // init

    case "initAssetsByFaction": {

        private [
            "_factionConfig","_factionConfigName","_entry","_entryScope",
            "_entrySide","_entryFaction","_factionUnits","_entryDisplayName",
            "_entryConfigName"
        ];

        _result = [] call ALiVE_fnc_hashCreate;

        private _allFactions = [] call ALiVE_fnc_configGetFactions;

        // build factions list

        {
            _factionConfig = _x call ALiVE_fnc_configGetFactionClass;
            _factionSide = getNumber (_factionConfig >> "side");

            if (_factionSide >= 0 && {_factionSide <= 3}) then {
                _factionConfigName = tolower (configName _factionConfig);

                [_result,_factionConfigName, [[],[]]] call ALiVE_fnc_hashSet;
            };
        } foreach _allFactions;

        // set unit classes to factions

        private _configPath = configFile >> "CfgVehicles";
        for "_i" from 0 to (count _configPath - 1) do {

            _entry = _configPath select _i;

            if (isClass _entry) then {

                _entryScope = getNumber (_entry >> "scope");

                if (_entryScope >= 2 && {!(configname _entry isKindOf "Static")}) then {
                    _entrySide = getNumber (_entry >> "side");

                    if (_entrySide >= 0 && {_entrySide <= 3}) then {
                        _entryFaction = tolower (getText (_entry >> "faction"));

                        _factionData = nil;
                        _factionData = [_result,_entryFaction] call ALiVE_fnc_hashGet;

                        if (!isnil "_factionData") then {
                            _entryConfigName = configName _entry;
                            _entryEditorSubcategory = getText (_entry >> "editorSubcategory");

                            (_factionData select 0) pushbackunique _entryEditorSubcategory;
                            (_factionData select 1) pushback _entryConfigName;
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
        private _factionConfigGroupCategoryName = configname _factionConfigGroupCategories;

        for "_i" from 0 to (count _factionConfigGroupCategories - 1) do {

            _groupCategory = _factionConfigGroupCategories select _i;

            if (isClass _groupCategory) then {

                //_groupCategoryDisplayName = getText (_groupCategory >> "name");
                _groupCategoryDisplayName = configname _groupCategory;
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
                        _groupFaction = tolower (getText (_group >> "faction"));
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

        _result = [_factionConfigGroupCategoryName,_factionGroupCategories];

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

                [_customUnits,_customUnitConfigName, nil] call ALiVE_fnc_hashSet;
            };
        } foreach (_customUnits select 2);

        [_factions,_faction, nil] call ALiVE_fnc_hashSet;

    };

    case "getFactionsBySide": {

        private _side = _args;
        _side = [_logic,"convertSideToNum", _side] call MAINCLASS;

        _result = [];

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        {
            private _factionSide = [_x,"side"] call ALiVE_fnc_hashGet;
            if (_factionSide == _side) then {
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
                } foreach _groupUnits;

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
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _factionClassname) then {
                [_customUnit,"faction", _classname] call ALiVE_fnc_hashSet;
            };
        } foreach (_customUnits select 2);

        [_factions,_factionClassname, nil] call ALiVE_fnc_hashSet;
        [_factions,_classname,_factionData] call ALiVE_fnc_hashSet;

        [_factionData,"configName", _classname] call ALiVE_fnc_hashSet;

    };

    case "setFactionShortName": {

        private ["_groupCategory","_groupsInCategory","_group","_customUnit"];

        _args params ["_faction","_shortName"];

        /* Potentially update classname of units and groups?
        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        */

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        [_factionData,"shortName", _shortName] call ALiVE_fnc_hashSet;

    };

    case "setFactionCamo": {

        private ["_groupCategory","_groupsInCategory","_group","_customUnit"];

        _args params ["_faction","_camo"];

        /* Potentially update classname of units and groups?
        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        */

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        [_factionData,"camo", _camo] call ALiVE_fnc_hashSet;

    };

    case "loadFactionToList": {

        private _list = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        lbclear _list;

        {
            private _faction = _x;
            private _factionDisplayName = [_faction,"displayName"] call ALiVE_fnc_hashGet;
            private _factionConfigName = [_faction,"configName"] call ALiVE_fnc_hashGet;

            if !(_factionConfigName in FACTION_BLACKLIST) then {
                private _index = _list lbAdd (format ["%1 - %2", _factionDisplayName, _factionConfigName]);
                _list lbSetData [_index,_factionConfigName];
            };
        } foreach (_factions select 2);

    };

    case "getFactionAssetCategories": {

        private ["_customUnit","_customUnitFaction","_asset","_assetConfig","_assetEditorSubcategory"];

        private _faction = _args;

        _result = [];

        private _cfgVehicles = configFile >> "CfgVehicles";

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        {
            _customUnit = _x;
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _faction) then {
                private _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;
                private _realUnitClass = [_logic,"getRealUnitClass", _customUnitConfigName] call MAINCLASS;
                private _realUnitConfig = _cfgVehicles >> _realUnitClass;
                private _realUnitEditorSubCategory = getText (_realUnitConfig >> "editorSubcategory");

                _result pushbackunique _realUnitEditorSubCategory;
            };
        } foreach (_customUnits select 2);

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;

        {
            _asset = _x;
            _assetConfig = _cfgVehicles >> _asset;
            _assetEditorSubcategory = getText (_assetConfig >> "editorSubcategory");

            _result pushbackunique _assetEditorSubcategory;
        } foreach _factionAssets;

    };

    case "getFactionAssetCategoriesByName": {

        private ["_category","_categoryConfig","_categoryDisplayName"];

        private _faction = _args;

        private _factionAssetCategories = [_logic,"getFactionAssetCategories", _faction] call MAINCLASS;

        private _editorSubcategoryCFG = configFile >> "CfgEditorSubcategories";

        _result = [];

        {
            _category = _x;
            _categoryConfig = _editorSubcategoryCFG >> _category;
            _categoryDisplayName = getText (_categoryConfig >> "displayName");

            _result pushback [_categoryDisplayName,_category];
        } foreach _factionAssetCategories;

    };

    case "loadFactionAssetCategoriesToList": {

        _args params ["_faction","_list"];

        private _assetCategoriesByName = [_logic,"getFactionAssetCategoriesByName", _faction] call MAINCLASS;

        lbClear _list;

        {
            _x params ["_categoryDisplayName","_categoryConfigName"];

            _index = _list lbAdd _categoryDisplayName;
            _list lbSetData [_index,_categoryConfigName];
        } foreach _assetCategoriesByName;

        lbSort [_list,"ASC"];

    };

    case "loadFactionAssetsInCategoryToList": {

        private [
            "_customUnit","_customUnitConfigName","_customUnitDisplayName","_realUnit","_realUnitEditorSubCategory",
            "_index","_assetConfigName","_assetConfig","_assetEditorSubcategory","_assetDisplayName","_customUnitFaction"
        ];

        _args params ["_faction","_category","_list",["_toExclude",[],[]]];

        lbClear _list;

        private _cfgVehicles = configFile >> "CfgVehicles";
        private _classesAdded = [];

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        {
            _customUnit = _x;
            _customUnitFaction = [_customUnit,"faction"] call ALiVE_fnc_hashGet;

            if (_customUnitFaction == _faction) then {

                _customUnitConfigName = [_customUnit,"configName"] call ALiVE_fnc_hashGet;
                _customUnitDisplayName = [_customUnit,"displayName"] call ALiVE_fnc_hashGet;

                _realUnit = [_logic,"getRealUnitClass", _customUnitConfigName] call MAINCLASS;
                _realUnitEditorSubCategory = getText (_cfgVehicles >> _realUnit >> "editorSubcategory");

                if (_realUnitEditorSubCategory == _category && {!(_customUnitConfigName in _toExclude)}) then {
                    _index = _list lbAdd _customUnitDisplayName;
                    _list lbSetData [_index,_customUnitConfigName];

                    _classesAdded pushback _customUnitConfigName;
                };

            };
        } foreach (_customUnits select 2);

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;
        private _factionAssetsImportedConfig = [_factionData,"assetsImportedConfig"] call ALiVE_fnc_hashGet;

        if (!_factionAssetsImportedConfig) then {
            {
                _assetConfigName = _x;
                _assetConfig = _cfgVehicles >> _assetConfigName;
                _assetEditorSubcategory = getText (_assetConfig >> "editorSubcategory");

                if (_assetEditorSubcategory == _category && {!(_assetConfigName in _toExclude)} && {!(_assetConfigName in _classesAdded)}) then {
                    _assetDisplayName = getText (_assetConfig >> "displayName");

                    _index = _list lbAdd _assetDisplayName;
                    _list lbSetData [_index,_assetConfigName];
                };
            } foreach _factionAssets;
        };

    };

    // helper functions
    // custom units

    case "addCustomUnit": {

        private _unit = _args;

        if (_unit isEqualType []) then {

            private _state = [_logic,"state"] call MAINCLASS;
            private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

            private _unitClassname = [_unit,"configName"] call ALiVE_fnc_hashGet;

            [_customUnits,_unitClassname, _unit] call ALiVE_fnc_hashSet;

           //  ([_customUnits, _unitClassname] call ALiVE_fnc_hashGet) call ALiVE_fnc_inspectHash;
        };

    };

    case "removeCustomUnit": {

        private _unitToRemove = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        if (_unitToRemove isEqualType "") then {
            _unitToRemove = [_customUnits,_unitToRemove] call ALiVE_fnc_hashGet;
        };

        private _unitToRemoveClassname = [_unitToRemove,"configName"] call ALiVE_fnc_hashGet;
        private _unitToRemoveParent = [_unitToRemove,"inheritsFrom"] call ALiVE_fnc_hashGet;

        {
            private _parent = [_x,"inheritsFrom"] call ALiVE_fnc_hashGet;

            if (_parent == _unitToRemoveClassname) then {
                [_x,"inheritsFrom", _unitToRemoveParent] call ALiVE_fnc_hashSet;
            };
        } foreach (_customUnits select 2);

        [_customUnits,_unitToRemoveClassname, nil] call ALiVE_fnc_hashSet;

    };

    case "getCustomUnit": {

        private _classname = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        _result = [_customUnits,_classname] call ALiVE_fnc_hashGet;

    };

    case "copyCustomUnit": {

        private _unit = _args;

        if (_unit isEqualType "") then {

            private _state = [_logic,"state"] call MAINCLASS;
            private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
            private _customUnitClasses = _customUnits select 1;

            private _unitData = [_logic,"getCustomUnit", _unit] call MAINCLASS;
            private _unitConfigName = [_unitData,"configName"] call ALiVE_fnc_hashGet;
            private _unitDisplayName = [_unitData,"displayName"] call ALiVE_fnc_hashGet;

            private _numPrefix = 1;
            private _newUnitConfigName = format ["%1_copy_%2", _unitConfigName, _numPrefix];

            while {_newUnitConfigName in _customUnitClasses} do {
                _numPrefix = _numPrefix + 1;
                _newUnitConfigName = format ["%1_copy_%2", _unitConfigName, _numPrefix];
            };

            private _newUnitDisplayName = format ["%1 Copy %2", _unitDisplayName, _numPrefix];

            private _newUnit = +_unitData;
            [_newUnit,"configName", _newUnitConfigName] call ALiVE_fnc_hashSet;
            [_newUnit,"displayName", _newUnitDisplayName] call ALiVE_fnc_hashSet;

            [_logic,"addCustomUnit", _newUnit] call MAINCLASS;

            _result = _newUnitConfigName;

        };

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

    case "getRealUnitClass": {

        private ["_unitParentEntry"];

        private _unit = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _cfgVehicles = configFile >> "CfgVehicles";

        private _unitData = [_customUnits,_unit] call ALiVE_fnc_hashGet;

        // if unit exists in config and (doesn't exist in custom units or it's parent hasn't been modified)
        // exit
        //["CHECK %1, %2, %3", _unit, configname (inheritsFrom (_cfgVehicles >> _unit)), ([_unitData,"inheritsFrom"] call ALiVE_fnc_hashGet)] call ALiVE_fnc_dump;

        if (isClass (_cfgVehicles >> _unit) && {(isnil "_unitData" || {getNumber(_cfgVehicles >> _unit >> "ALiVE_orbatCreator_owned") == 1} || {configname (inheritsFrom (_cfgVehicles >> _unit)) == ([_unitData,"inheritsFrom"] call ALiVE_fnc_hashGet)})}) exitWith {
            _result = _unit;
        };

        private _unitParent = [_unitData,"inheritsFrom"] call ALiVE_fnc_hashGet;
        private _unitParentConfigPath = configFile >> "CfgVehicles" >> _unitParent;

        while {!isClass _unitParentConfigPath} do {
            _unitParentEntry = [_customUnits,_unitParent] call ALiVE_fnc_hashGet;
            _unitParent = [_unitParentEntry,"inheritsFrom"] call ALiVE_fnc_hashGet;
            _unitParentConfigPath = _cfgVehicles >> _unitParent;
        };

        _unitParent = [_unitParent,"_OCimport_01",""] call CBA_fnc_replace;
        _unitParent = [_unitParent,"_OCimport_02",""] call CBA_fnc_replace;

        _result = _unitParent;

    };

    case "displayVehicle": {

        private ["_sideObject","_loadout","_activeUnit","_face","_faceIdentityTypes"];
        private _vehicle = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _cam = [_state,"unitEditor_interfaceCamera"] call ALiVE_fnc_hashGet;
        private _pos = [_state,"unitEditor_activeUnitPosition"] call ALiVE_fnc_hashGet;


        // get unit data

        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _customUnit = [_customUnits,_vehicle] call ALiVE_fnc_hashGet;

        private _crew = "";
        private _texture = [];

        if (!isnil "_customUnit") then {
            _vehicle = [_customUnit,"configName"] call ALiVE_fnc_hashGet;
            _loadout = [_customUnit,"loadout"] call ALiVE_fnc_hashGet;
            _crew = [_customUnit,"crew"] call ALiVE_fnc_hashGet;
            _texture = [_customUnit,"texture"] call ALiVE_fnc_hashGet;

            private _customUnitSide = [_customUnit,"side"] call ALiVE_fnc_hashGet;
            private _customSideText = [_customUnitSide] call ALiVE_fnc_sideNumberToText;
            _sideObject = [_customSideText] call ALiVE_fnc_sideTextToObject;

            _vehicle = [_logic,"getRealUnitClass", _vehicle] call MAINCLASS;

        }  else {
            private _configPath = configFile >> "CfgVehicles" >> _vehicle;
            private _side = getNumber (_configPath >> "side");
            private _sideText = [_side] call ALiVE_fnc_sideNumberToText;
            _sideObject = [_sideText] call ALiVE_fnc_sideTextToObject;

            _crew = getText (_configPath >> "crew");
            _texture = (getArray (_configPath >> "textureList")) select 0;
        };

        // delete existing vehicle

        private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
        [_logic,"deleteUnit", _activeUnit] call MAINCLASS;

        // spawn vehicle

        if (_vehicle isKindOf "Man") then {
            private _identityTypes = [_customUnit,"identityTypes"] call ALiVE_fnc_hashGet;
            private _identityFace = [_identityTypes,"face"] call ALiVE_fnc_hashGet;
            private _identityVoice = [_identityTypes,"voice"] call ALiVE_fnc_hashGet;
            private _identityInsignia = [_identityTypes,"insignia"] call ALiVE_fnc_hashGet;

            // get all faces belong to face identity type

            private _cfgFaces = configfile >> "CfgFaces" >> "Man_A3";
            private _allFacesForType = [];
            for "_i" from 0 to (count _cfgFaces - 1) do {
                _face = _cfgFaces select _i;

                if (isclass _face) then {
                    if (getnumber(_face >> "disabled") == 0) then {
                        _faceIdentityTypes = getArray(_face >> "identityTypes");

                        if (_identityFace in _faceIdentityTypes) then {
                            _allFacesForType pushback (configname _face);
                        };
                    };
                };
            };

            _activeUnit = (createGroup _sideObject) createUnit [_vehicle, [0,0,0], [], 0, "NONE"];
            _activeUnit setPos _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;
            _activeUnit switchMove (animationState player);
            _activeUnit switchAction "playerstand";

             // _loadout call ALIVE_fnc_inspectArray;

            if (count _loadout > 0) then {
                _activeUnit setUnitLoadout _loadout;
            };

            _cam camSetRelPos [-0.05,1,0.15];
            _cam camSetFov 0.35;

            // this must be spawned otherwise something overwrites it shortly after.. idk what, just go with it
            [_activeUnit,_allFacesForType] spawn {
                params ["_unit","_faces"];
                _unit setFace (selectRandom _faces);
            };
            _activeUnit setSpeaker _identityVoice;

            [_activeUnit,_identityInsignia] call BIS_fnc_setUnitInsignia;
        } else {
            _activeUnit = _vehicle createVehicle [0,0,0];
            _activeUnit setPos _pos;
            _activeUnit enableSimulation false;
            _activeUnit setDir 0;

            [_logic,"setVehicleTexure", [_activeUnit,_texture]] call MAINCLASS;

            _cam camSetRelPos [0, (sizeOf _vehicle) * 0.65, (sizeOf _vehicle) * 0.1];
            _cam camSetFov 0.5;
        };

        _activeUnit setDir 25;

        _cam camCommit 0;

        [_state,"unitEditor_activeUnitObject", _activeUnit] call ALiVE_fnc_hashSet;
        if !(isNil "_selectedUnitClassname") then {
            [_state,"unitEditor_selectedUnit", _selectedUnitClassname] call ALiVE_fnc_hashSet;
        };
        _result = _activeUnit;

    };

    case "setCustomUnitClassname": {

        _args params ["_unit","_classname"];

        if (_unit isEqualType "") then {
            _unit = [_logic,"getCustomUnit", _unit] call MAINCLASS;
        };

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _unitClassname = [_unit,"configName"] call ALiVE_fnc_hashGet;
        private _unitFaction = [_unit,"faction"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _unitFaction] call MAINCLASS;

        // replace classname in groups

        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

        {
            private _groupCategory = _x;
            private _groupsInCategory = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;

            {
                private _group = _x;
                private _groupUnits = [_group,"units"] call ALiVE_fnc_hashGet;

                {
                    private _groupUnit = _x;
                    private _groupUnitVehicle = [_groupUnit,"vehicle"] call ALiVE_fnc_hashGet;

                    if (_groupUnitVehicle == _unitClassname) then {
                        [_groupUnit,"vehicle", _classname] call ALiVE_fnc_hashSet;
                    };
                } foreach _groupUnits;
            } foreach (_groupsInCategory select 2);
        } foreach (_factionGroupCategories select 2);

        // replace classname in vehicle turrets

        {
            private _customUnit = _x;
            private _turrets = [_customUnit,"turrets"] call ALiVE_fnc_hashGet;

            {
                private _turretInfo = _x;

                if ((_x select 2) == _unitClassname) exitWith {
                    _turretInfo set [2, _classname];
                };
            } foreach (_turrets select 2);
        } foreach (_customUnits select 2);

        [_unit,"configName", _classname] call ALiVE_fnc_hashSet;

        [_customUnits,_unitClassname, nil] call ALiVE_fnc_hashSet;
        [_customUnits,_classname, _unit] call ALiVE_fnc_hashSet;

    };

    case "importUnitFromConfig": {

        private _unit = _args;

        _result = [];

        if (_unit isEqualType "") then {

            private _state = [_logic,"state"] call MAINCLASS;
            private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

            private _unitConfig = configFile >> "CfgVehicles" >> _unit;
            private _unitParent = configName (inheritsFrom _unitConfig);
            private _unitDisplayName = getText (_unitConfig >> "displayName");
            private _unitSide = getNumber (_unitConfig >> "side");
            private _unitFaction = tolower (getText (_unitConfig >> "faction"));
            private _import = true;
            private _identityTypes = [_logic,"getUnitIdentityTypes", _unit] call MAINCLASS;

            // hide importer classes from user

            _unitParent = [_unitParent,"_OCimport_01",""] call CBA_fnc_replace;
            _unitParent = [_unitParent,"_OCimport_02",""] call CBA_fnc_replace;

            private _newUnit = [nil,"create"] call ALiVE_fnc_orbatCreatorUnit;
            [_newUnit,"init"] call ALiVE_fnc_orbatCreatorUnit;
            [_newUnit,"configName", _unit] call ALiVE_fnc_hashSet;
            [_newUnit,"displayName", _unitDisplayName] call ALiVE_fnc_hashSet;
            [_newUnit,"inheritsFrom", _unitParent] call ALiVE_fnc_hashSet;
            [_newUnit,"side", _unitSide] call ALiVE_fnc_hashSet;
            [_newUnit,"faction", _unitFaction] call ALiVE_fnc_hashSet;
            [_newUnit,"identityTypes", _identityTypes] call ALiVE_fnc_hashset;

            if (_unit isKindOf "Man") then {
                // spawn unit to get loadout
                // give EH's chance to fire?

                private _unitSideText = [_unitSide] call ALiVE_fnc_sideNumberToText;
                private _unitSideObject = [_unitSideText] call ALiVE_fnc_sideTextToObject;
				private _loadout = [];

				// Check to see if this is an ORBATRON unit and get loadout
				if (getNumber(_unitConfig >> "ALiVE_orbatCreator_owned") == 1) then {
					_loadout = getArray(_unitConfig >> "ALiVE_orbatCreator_loadout");
                    if (count _loadout == 0) then {
                        // importing an old ORBATRON config
                        private _init = getText (_unitConfig >> "Eventhandlers" >> "ALiVE_orbatCreator" >> "init");
                        private _initArray = _init splitString ";";
                        if ((_init find "setunitloadout") != -1) then {
                            _init = _initArray select 5;
                            _init = [_init,"_this setunitloadout ",""] call CBA_fnc_replace;
                            _init = [_init,"_unit setunitloadout ",""] call CBA_fnc_replace;
                            _loadout = call compile _init;
                        } else {
                            _import = false;
                        };
                    };
				} else {
                	private _realUnit = (createGroup _unitSideObject) createUnit [_unit, [0,0,0], [], 0, "NONE"];
                	_loadout = getUnitLoadout _realUnit;
				};

                [_newUnit,"loadout", _loadout] call ALiVE_fnc_hashSet;

                [_logic,"deleteUnit", _realUnit] call MAINCLASS;
            } else {
                private _crew = getText (_unitConfig >> "crew");

                private _turrets = [] call ALiVE_fnc_hashCreate;
                private _turretsConfig = _unitConfig >> "turrets";

                for "_i" from 0 to (count _turretsConfig - 1) do {
                    _turretConfig = _turretsConfig select _i;

                    if (isclass _turretConfig) then {
                        _turretConfigName = configname _turretConfig;
                        _turretDisplayName = getText(_turretConfig >> "gunnerName");
                        _turretGunnerType = getText(_turretConfig >> "gunnerType");

                        [_turrets,_turretConfigName, [_turretConfigName,_turretDisplayName,_turretGunnerType]] call ALiVE_fnc_hashSet;
                    };
                };

                private _texture = getText (_unitConfig >> "ALiVE_orbatCreator_texture");

                [_newUnit,"crew", _crew] call ALiVE_fnc_hashSet;
                [_newUnit,"turrets", _turrets] call ALiVE_fnc_hashSet;
                [_newUnit,"texture", _texture] call ALiVE_fnc_hashSet;

                [_logic,"deleteUnit", _realUnit] call MAINCLASS;
            };

			// Check to see if unit was imported correctly.
			// _newUnit call ALiVE_fnc_inspectHash;

            if (_import) then {
                _result = _newUnit;
            };

        };

    };

    case "importFactionUnitsFromConfig": {

        private ["_importedUnit"];

        private _faction = _args;

        _result = [];

        if (_faction isEqualType "") then {

            private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
            private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;

            {
                _importedUnit = [_logic,"importUnitFromConfig", _x] call MAINCLASS;
                [_logic,"addCustomUnit", _importedUnit] call MAINCLASS;

                _result pushback _importedUnit;
            } foreach _factionAssets;

        };

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

        [_groups,_group, nil] call ALiVE_fnc_hashSet;

    };

    case "groupAddUnit": {

        _args params ["_group","_unit"];

        // verify unit is non static item

        if (_unit isKindOf "StaticWeapon" || {_unit isKindOf "Static"}) exitWith {systemChat "Cannot add noh human/vehicle units to groups"};

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

        private ["_unitPosX","_unitPosY"];

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
                [_logic,"deleteUnit", _realUnitVeh] call MAINCLASS;

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

    case "copyCategoryGroup": {

        _args params ["_category","_group"];

        private _categoryGroups = [_category,"groups"] call ALiVE_fnc_hashGet;
        private _groupClasses = _categoryGroups select 1;

        private _groupConfigName = [_group,"configName"] call ALiVE_fnc_hashGet;
        private _groupDisplayName = [_group,"name"] call ALiVE_fnc_hashGet;

        private _numPrefix = 1;
        private _newGroupConfigName = format ["%1_copy_%2", _groupConfigName, _numPrefix];

        while {_newGroupConfigName in _groupClasses} do {
            _numPrefix = _numPrefix + 1;
            _newGroupConfigName = format ["%1_copy_%2", _groupConfigName, _numPrefix];
        };

        private _newGroupDisplayName = format ["%1 Copy %2", _groupDisplayName, _numPrefix];

        private _newGroup = +_group;
        [_newGroup,"configName", _newGroupConfigName] call ALiVE_fnc_hashSet;
        [_newGroup,"name", _newGroupDisplayName] call ALiVE_fnc_hashSet;

        [_categoryGroups,_newGroupConfigName,_newGroup] call ALiVE_fnc_hashSet;

        _result = _newGroupConfigName;

    };

    case "loadFactionGroupCategoriesToList": {

        _args params ["_list","_faction"];

        private _factionData = [_logic,"getFactionData",_faction] call MAINCLASS;
        private _factionGroupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

        lbClear _list;

        {
            _category = _x;
            _categoryDisplayName = [_category,"name"] call ALiVE_fnc_hashGet;
            _categoryConfigName = [_category,"configName"] call ALiVE_fnc_hashGet;

            _index = _list lbAdd _categoryDisplayName;
            _list lbSetData [_index,_categoryConfigName];

            if !(_categoryConfigName in ALIVE_COMPATIBLE_GROUP_CATEGORIES) then {
                _list lbSetColor [_index, [255, 0, 0, 0.60]];
                _list lbSetTooltip [_index,"This group category is not compatible with ALiVE!"];
            };
        } foreach (_factionGroupCategories select 2);

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

        _args params ["_list","_side"];

        private _factions = [_logic,"getFactionsBySide", _side] call MAINCLASS;
        lbClear _list;

        {
            private _factionDisplayName = [_x,"displayName"] call ALiVE_fnC_hashGet;
            private _factionConfigName = [_x,"configName"] call ALiVE_fnc_hashGet;

            if !(_factionConfigName in FACTION_BLACKLIST) then {
                private _index = _list lbAdd _factionDisplayName;
                _list lbSetData [_index, _factionConfigName];
            };
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
            '1','2','3','4','5','6','7','8','9','0',
            '_'
        ];

        private _currIndex = 0;
        private _currString = "";
        private _classnameComponents = [];

        while {_currIndex != _displayNameSize} do {

            _nextChar = _displayNameArray select _currIndex;
            _nextChar = toString [_nextChar];

            if ((toLower _nextChar) in _validChars) then {
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

    case "deleteUnit": {

        private _unit = _args;

        private _group = group _unit;
        deleteVehicle _unit;
        deleteGroup _group;

    };

    case "getVehicleTextureSourcesByName": {

        private _vehicle = _args;

        if (_vehicle isEqualType "") then {

            private _vehicleConfig = configFile >> "CfgVehicles" >> _vehicle;

            if (isClass _vehicleConfig) then {

                private ["_textureSource","_textureSourceDisplayName","_textureSourceTextures"];

                _result = [];

                private _textureSources = _vehicleConfig >> "textureSources";

                for "_i" from 0 to (count _textureSources - 1) do {
                    _textureSource = _textureSources select _i;
                    _textureSourceConfigName = configName _textureSource;
                    _textureSourceDisplayName = getText (_textureSource >> "displayName");
                    _textureSourceTextures = getArray (_textureSource >> "textures");

                    _result pushback [_textureSourceConfigName,_textureSourceDisplayName,_textureSourceTextures];
                };

            };

        };

    };

    case "getVehicleTextureSources": {

        private _vehicle = _args;

        _result = configFile >> "CfgVehicles" >> _vehicle >> "textureSources";

    };

    case "getVehicleTextureConfig": {

        _args params ["_vehicle","_texture"];

        private _textureSources = [_logic,"getVehicleTextureSources", _vehicle] call MAINCLASS;

        if (_textureSources isEqualType configNull) then {
            _result = _textureSources >> _texture;
        };

    };

    case "getVehicleTextureArray": {

        _args params ["_vehicle","_texture"];

        private _vehicleTexture = [_logic,"getVehicleTextureConfig", [_vehicle,_texture]] call MAINCLASS;
        _result = getArray (_vehicleTexture >> "textures");

    };

    case "setVehicleTexure": {

        _args params ["_vehicle","_texture"];

        private _textureArray = [_logic,"getVehicleTextureArray", [typeof _vehicle,_texture]] call MAINCLASS;

        {
            _vehicle setObjectTexture [_forEachIndex, _textureArray select _forEachIndex];
        } foreach _textureArray;

    };

    case "loadSidesToList": {

        private ["_sideNum","_sideText","_index"];

        private _list = _args;

        lbClear _list;

        for "_i" from 0 to 3 do {
            _sideNum = _i;
            _sideText = [_sideNum] call ALiVE_fnc_sideNumberToText;
            _sideText = [_sideText] call ALiVE_fnc_sideTextToLong;

            _index = _list lbAdd _sideText;
            _list lbSetData [_index,str _sideNum];
        };

    };

    case "getFacesByIdentityType": {

        private ["_face","_faceTypes","_faceType","_facesForType"];

        _result = [] call ALiVE_fnc_hashCreate;
        private _cfgFaces = configFile >> "CfgFaces" >> "Man_A3";

        for "_i" from 0 to (count _cfgFaces - 1) do {
            _face = _cfgFaces select _i;

            if (isclass _face) then {
                if (getnumber(_face >> "disabled") == 0) then {
                    _faceTypes = getArray(_face >> "identityTypes");

                    {
                        _faceType = _x;
                        _facesForType = [_result,_faceType] call ALiVE_fnc_hashGet;

                        if (isnil "_facesForType") then {
                            [_result,_faceType, [configname _face]] call ALiVE_fnc_hashSet;
                        } else {
                            _facesForType pushback (configname _face);
                        };
                    } foreach _faceTypes;
                };
            };
        };

    };

    case "getVoiceIdentityType": {

        private _voice = _args;

        _result = "";

        if (_voice isEqualType "") then {

            private _voiceEntry = configfile >> "CfgVoice" >> _voice;
            private _voiceEntryIdentityTypes = getArray(_voiceEntry >> "identityTypes");

            {if (_x isEqualType "" && {_x find "Language" != -1}) exitWith {_result = _x}} foreach _voiceEntryIdentityTypes;

        };

    };

    case "getVoicesByIdentityType": {

        private [];

        _result = [] call ALiVE_fnc_hashCreate;

        private _cfgVoice = configFile >> "CfgVoice";
        for "_i" from 0 to (count _cfgVoice - 1) do {
            _voice = _cfgVoice select _i;

            if (isClass _voice) then {
                if (getnumber(_voice >> "scope") >= 2) then {
                    _voiceIdentityType = [_logic,"getVoiceIdentityType", configname _voice] call MAINCLASS;

                    if (_voiceIdentityType != "") then {
                        _identityTypeVoices = [_result,_voiceIdentityType] call ALiVE_fnc_hashGet;

                        if (isnil "_identityTypeVoices") then {
                            [_result,_voiceIdentityType, [configname _voice]] call ALiVE_fnc_hashSet;
                        } else {
                            _identityTypeVoices pushback (configname _voice);
                        };
                    };
                };
            };
        };

    };

    case "getUnitIdentityTypes": {

        private _unit = _args;

        private _realUnitClass = [_logic,"getRealUnitClass", _unit] call MAINCLASS;

        if (_realUnitClass isKindOf "Man") then {
            private ["_voice","_insignia"];

            private _unitData = [_logic,"getCustomUnit", _unit] call MAINCLASS;

            if (isnil "_unitData") then {

                private _identityTypes = [] call ALiVE_fnc_hashCreate;
                [_identityTypes,"face", ""] call ALiVE_fnc_hashSet;
                [_identityTypes,"voice", ""] call ALiVE_fnc_hashSet;
                [_identityTypes,"insignia", ""] call ALiVE_fnc_hashSet;

                // get identityTypes info
                // must be compared lowercase because some mods aren't consistent

                private _allFaceTypes = ([_logic,"getFacesByIdentityType"] call MAINCLASS) select 1;
                private _allVoices = [];

                private _cfgVoice = configFile >> "CfgVoice";
                for "_i" from 0 to (count _cfgVoice - 1) do {
                    _voice = _cfgVoice select _i;

                    if (isClass _voice) then {
                        if (getnumber(_voice >> "scope") >= 2) then {
                            _voiceIdentityTypes = getArray(_voice >> "identityTypes");
                            _allVoices append _voiceIdentityTypes;
                        };
                    };
                };

                private _allFaceTypesLower = _allFaceTypes apply {if (_x isEqualType "") then {tolower _x}};
                private _allVoicesLower = _allVoices apply {if (_x isEqualType "") then {tolower _x}};

                private _unitConfig = configFile >> "CfgVehicles" >> _unit;
                private _unitIdentityInfo = getArray(_unitConfig >> "identityTypes");

                {
                    if ((tolower _x) in _allFaceTypesLower) then {
                        [_identityTypes,"face", _x] call ALiVE_fnc_hashSet;
                    };

                    if ((tolower _x) in _allVoicesLower) then {
                        [_identityTypes,"voice", _x] call ALiVE_fnc_hashSet;
                    };
                } foreach _unitIdentityInfo;

                private _insignia = getText(_unitConfig >> "ALiVE_orbatCreator_insignia");
                [_identityTypes,"insignia", _insignia] call ALiVE_fnc_hashSet;

                private _allUnitIdentityTypes = getArray(_unitConfig >> "identityTypes");
                private _uniqueIdentityTypes = [];

                {
                    private _identityTypeLower = tolower _x;
                    private _unique = true;

                    if (_identityTypeLower in _allFaceTypesLower) then {_unique = false};

                    if (_unique) then {
                        if (_identityTypeLower in _allVoicesLower) then {_unique = false};
                    };

                    if (_unique) then {
                        _uniqueIdentityTypes pushback _x;
                    };
                } foreach _allUnitIdentityTypes;

                [_identityTypes,"misc", _uniqueIdentityTypes] call ALiVE_fnc_hashSet;

                _result = _identityTypes;
            } else {
                _result = [_unitData,"identityTypes"] call ALiVE_fnc_hashGet;
            };
        };

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
        [_state,"selectedFaction", _faction] call ALiVE_fnc_hashSet;

        [_logic,"factionEditorDisplayFaction", _faction] call MAINCLASS;

    };

    case "factionEditorDisplayFaction": {

        private _faction = _args;

        private _inputFactionFlag = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_FLAG );
        _inputFactionFlag ctrlShow false;

        private _tree = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_TREE_GROUPS );
        tvClear _tree;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;

        if (!isnil "_factionData") then {

            private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
            private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
            private _factionClassname = [_factionData,"configName"] call ALiVE_fnc_hashGet;
            private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;

            _inputFactionFlag ctrlShow true;
            _inputFactionFlag ctrlSetText _factionFlag;

            // update group tree

            [_logic,"factionEditorDisplayFactionGroups", _faction] call MAINCLASS;

        };

    };

    case "factionEditorDisplayFactionGroups": {

        private _faction = _args;

        private _tree = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_TREE_GROUPS );
        tvClear _tree;

        private _factionDataSources = [_logic,"getFactionGroupsDataSources", _factionData] call MAINCLASS;

        [_logic,"treeAddDataSourcesArray", [_tree,_factionDataSources]] call MAINCLASS;

    };

    case "onFactionEditorNewClicked": {

        [_logic,"openInterface", "Create_Faction"] spawn MAINCLASS;

    };

    case "onFactionEditorEditClicked": {

        [_logic,"openInterface", "Edit_Faction"] spawn MAINCLASS;

    };

    case "onFactionEditorCopyClicked": {

        [_logic,"openInterface", "Copy_Faction"] spawn MAINCLASS;

    };

    case "onFactionEditorDeleteClicked": {

        private ["_customUnit","_customUnitConfigName"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

        [_logic,"removeFaction", _faction] call MAINCLASS;

        // update list

        private _factionList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
        [_logic,"loadFactionToList", _factionList] call MAINCLASS:
        lbSort [_factionList, "ASC"];
        _factionList lbSetCurSel 0;

    };

    case "onCreateFactionAutogenerateClassnameClicked": {

        private _side = call compile OC_getSelData( OC_CREATEFACTION_INPUT_SIDE );
        private _faction = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_COUNTRY );
        private _force = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_FORCE );
        private _camo = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CAMO );

        private _suffix = "";

        if (_force != "") then {
            _faction = format["%1%2",_faction, _force];
        };

        if (_camo != "") then {
            _suffix = _camo;
        };

        private _generatedClassname = [_logic,"generateFactionClassname", [_side,_faction,_suffix]] call MAINCLASS;

        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CLASSNAME );
        _inputClassname ctrlSetText _generatedClassname;

    };

    case "generateFactionClassname": {

        _args params ["_side","_faction","_camo"];

        _side = [_logic,"convertSideToNum", _side] call MAINCLASS;

        private _prefix = [_logic,"prefix"] call MAINCLASS;

        private _sideText = [_side] call ALiVE_fnc_sideNumberToText;
        private _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;
        _sideTextLong = [_sideTextLong] call CBA_fnc_leftTrim;
        private _sidePrefix = _sideTextLong select [0,1];

        private _factionPrefix = [_faction," ",""] call CBA_fnc_replace;
        _factionPrefix = [_factionPrefix,"_",""] call CBA_fnc_replace;

        private _autogenClassname = format ["%1_%2", _sidePrefix, _factionPrefix];

        if (_prefix != "") then {
            _autogenClassname = format ["%1_%2", _prefix, _autogenClassname];
        };

        if (_camo != "") then {
            _autogenClassname = format ["%1_%2", _autogenClassname, _camo];
        };

        // format result

        _result = _autogenClassname

    };

    // create faction

    case "onCreateFactionOkClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _inputDisplayname = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_DISPLAYNAME );
        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CLASSNAME );

        private _displayName = ctrlText _inputDisplayname;
        private _className = ctrlText _inputClassname;
        private _side = call compile OC_getSelData( OC_CREATEFACTION_INPUT_SIDE );
        private _flag = OC_getSelData( OC_CREATEFACTION_INPUT_FLAG );

        private _country = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_COUNTRY );
        private _force = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_FORCE );
        private _camo = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CAMO );

        // validate input

        private _context = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_CONTEXT );

        if (_displayName == "") exitWith {
            _context ctrlSetText "Display name cannot be left blank";
        };

        if (_country == "") exitWith {
            _context ctrlSetText "Country name cannot be left blank";
        };

        if (_className == "") exitWith {
            _context ctrlSetText "Class name cannot be left blank";
        };

        if (_className in (_factions select 1)) exitWith {
            _context ctrlSetText "A faction with that class name already exists!";
        };

        // validation complete
        _className = [_logic,"validateClassname", _className] call MAINCLASS;
        _country = [_logic,"validateClassname", _country] call MAINCLASS;
        _force = [_logic,"validateClassname", _force] call MAINCLASS;
        _camo = [_logic,"validateClassname", _camo] call MAINCLASS;

        // Format shortname
        private _shortName = _country;

        if (_force != "") then {
            _shortName = format["%1%2",_country,_force];
        };

        private _newFaction = [nil,"create"] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"init"] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"displayName", _displayName] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"configName", _className] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"shortName", _shortName] call ALiVE_fnc_hashSet;
        [_newFaction,"side", _side] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"flag", _flag] call ALiVE_fnc_hashSet;
        [_newFaction,"icon", _flag] call ALiVE_fnc_hashSet;

        if (_camo != "") then {
            [_newFaction,"camo", _camo] call ALiVE_fnc_hashSet;
        };

        [_logic,"addFaction", _newFaction] call MAINCLASS;

        closeDialog 0;

        // update list

        private _listFactions = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
        [_logic,"loadFactionToList", _listFactions] call MAINCLASS:

        lbSort [_listFactions, "ASC"];
        [_listFactions,_className] call ALiVE_fnc_listSelectData;

    };

    // edit faction

    case "onEditFactionOkClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionClassname = [_factionData,"configName"] call ALiVE_fnc_hashGet;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
        private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;
        private _factionShortName = [_factionData,"shortName",""] call ALiVE_fnc_hashGet;
        private _factionCamo = [_factionData,"camo",""] call ALiVE_fnc_hashGet;

        private _inputDisplayName = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_DISPLAYNAME );
        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CLASSNAME );

        private _newDisplayName = ctrlText _inputDisplayName;
        private _newClassname = ctrlText _inputClassname;
        private _newSide = call compile OC_getSelData( OC_CREATEFACTION_INPUT_SIDE );
        private _newFlag = OC_getSelData( OC_CREATEFACTION_INPUT_FLAG );

        private _country = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_COUNTRY );
        private _force = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_FORCE );
        private _camo = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CAMO );

        // validate input

        private _context = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_CONTEXT );

        if (_newDisplayName == "") exitWith {
            _context ctrlSetText "Display name cannot be left blank";
        };

        if (_newClassname == "") exitWith {
            _context ctrlSetText "Class name cannot be left blank";
        };

        if (_newClassname in (_factions select 1)) exitWith {
            _context ctrlSetText "A faction with that class name already exists!";
        };

        // validation complete

        _country = [_logic,"validateClassname", _country] call MAINCLASS;
        _force = [_logic,"validateClassname", _force] call MAINCLASS;
        _camo = [_logic,"validateClassname", _camo] call MAINCLASS;

        // Format shortname
        private _shortName = _country;
        if (_country != "" && {_force != ""}) then {
            _shortName = format["%1%2",_country,_force];
        };

        if (_shortName != _factionShortName) then {
            [_logic,"setFactionShortName", [_faction,_shortName]] call MAINCLASS;
        };

        if (_camo != _factionCamo) then {
            [_logic,"setFactionCamo", [_faction,_camo]] call MAINCLASS;
        };

        if (_newSide != _factionSide) then {
            [_logic,"setFactionSide", [_faction,_newSide]] call MAINCLASS;
        };

        if (_newDisplayName != _factionDisplayName) then {
            [_factionData,"displayName", _newDisplayName] call ALiVE_fnc_hashSet;
        };

        if (_newClassname != _factionClassname) then {
            _newClassname = [_logic,"validateClassname", _newClassname] call MAINCLASS;
            [_logic,"setFactionClassname", [_factionClassname,_newClassname]] call MAINCLASS;
        };

        if (_newFlag != _factionFlag) then {
            [_factionData,"flag", _newFlag] call ALiVE_fnc_hashSet;
            [_factionData,"icon", _newFlag] call ALiVE_fnc_hashSet;
        };

        closeDialog 0;

        // update lists

        private _factionList = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
        [_logic,"loadFactionToList", _factionList] call MAINCLASS:
        lbSort [_factionList, "ASC"];
        _factionList lbSetCurSel 0;
        [_factionList,_newClassname] call ALiVE_fnc_listSelectData;

    };

    // copy faction

    case "onCopyFactionOkClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _copyParent = [_logic,"copyParent", false] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;

        private _inputDisplayname = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_DISPLAYNAME );
        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CLASSNAME );

        private _displayName = ctrlText _inputDisplayname;
        private _className = ctrlText _inputClassname;
        private _side = call compile OC_getSelData( OC_CREATEFACTION_INPUT_SIDE );
        private _flag = OC_getSelData( OC_CREATEFACTION_INPUT_FLAG );

        private _country = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_COUNTRY );
        private _force = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_FORCE );
        private _camo = ctrlText OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_INPUT_CAMO );

        // validate input

        private _context = OC_getControl( OC_DISPLAY_CREATEFACTION , OC_CREATEFACTION_CONTEXT );

        if (_displayName == "") exitWith {
            _context ctrlSetText "Display name cannot be left blank";
        };

        if (_country == "") exitWith {
            _context ctrlSetText "Country name cannot be left blank";
        };

        if (_className == "") exitWith {
            _context ctrlSetText "Class name cannot be left blank";
        };

        if (_className in (_factions select 1)) exitWith {
            _context ctrlSetText "A faction with that class name already exists!";
        };

        // validation complete

        _country = [_logic,"validateClassname", _country] call MAINCLASS;
        _force = [_logic,"validateClassname", _force] call MAINCLASS;
        _camo = [_logic,"validateClassname", _camo] call MAINCLASS;

        // Format shortname
        private _shortName = _country;

        if (_force != "") then {
            _shortName = format["%1%2",_country,_force];
        };

        _className = [_logic,"validateClassname", _className] call MAINCLASS;

        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;

        private _newFaction = +_factionData;
        [_newFaction,"displayName", _displayName] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"configName", _className] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"shortName", _shortName] call ALiVE_fnc_hashSet;
        [_newFaction,"side", _side] call ALiVE_fnc_orbatCreatorFaction;
        [_newFaction,"flag", _flag] call ALiVE_fnc_hashSet;
        [_newFaction,"icon", _flag] call ALiVE_fnc_hashSet;
        if (_camo != "") then {
            [_newFaction,"camo", _camo] call ALiVE_fnc_hashSet;
        };
        [_newFaction,"assets", []] call ALiVE_fnc_hashSet;

        [_logic,"addFaction", _newFaction] call MAINCLASS;

        private _factionUnits = +([_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS);

        private _factionAssetsImported = [_factionData,"assetsImportedConfig"] call ALiVE_fnc_hashGet;
        if (!_factionAssetsImported) then {
            private _importedAssets = [_logic,"importFactionUnitsFromConfig", _faction] call MAINCLASS;
            _factionUnits append _importedAssets;
        };

        // Update Units
        // rule out duplicates
        private _unitsToCopy = [];
        private _collectedClassnames = [];

        {
            private _unit = _x;
            private _unitClass = [_unit,"configName"] call ALiVE_fnc_hashGet;

            if !(_unitClass in _collectedClassnames) then {
                _unitsToCopy pushbackunique _unit;
                _collectedClassnames pushback _unitClass;
            };
        } foreach _factionUnits;

        {
            private _importedUnit = _x;
            private _importedUnitDisplayName = [_importedUnit,"displayName"] call ALiVE_fnc_hashGet;
            private _importedUnitConfigName = [_importedUnit,"configName"] call ALiVE_fnc_hashGet;

            private _newClassname = [_logic,"generateClassname", [_side,_classname,_importedUnitDisplayName]] call MAINCLASS;

            [_importedUnit,"faction", _className] call ALiVE_fnc_hashSet; // must be set before changing classname

            // Store the original copied unit name in case we need it?
            [_importedUnit,"copiedFrom", _importedUnitConfigName] call ALiVE_fnc_hashSet;

            if !(_copyParent) then {
                // When copying a faction units, make sure imported unit is based on existing unit (not existing unit's parent)
                [_importedUnit,"inheritsFrom", _importedUnitConfigName] call ALiVE_fnc_hashSet;
            };

            [_logic,"setCustomUnitClassname", [_importedUnitConfigName,_newClassname]] call MAINCLASS; // must be ran before the unit's classname is changed

            [_logic,"addCustomUnit", _importedUnit] call MAINCLASS;
        } foreach _unitsToCopy;

        // Update Groups
        private _factionGroupCategories = [_newFaction,"groupCategories"] call ALiVE_fnc_hashGet;

        {
            private _groupCategory = _x;
            private _groupCategoryConfigName = [_groupCategory,"configName"] call ALiVE_fnc_hashGet;
            private _groupsInCategory = [_groupCategory,"groups"] call ALiVE_fnc_hashGet;

            {
                private _group = _x;

                [_group,"faction", _classname] call ALiVE_fnc_hashSet;
                private _oldConfigName = [_group,"configName"] call ALiVE_fnc_hashGet;
                private _groupName = [_group,"name"] call ALiVE_fnc_hashGet;

                private _configName = [_logic,"generateGroupClassname", [_classname,_groupCategoryConfigName,_groupName]] call MAINCLASS;
                [_group,"configName", _configName] call ALiVE_fnc_hashSet;

                [_group,"side", _side] call ALiVE_fnc_hashSet;

                [_groupsInCategory,_configName, _group] call ALiVE_fnc_hashSet;
                [_groupsInCategory,_oldConfigName] call ALiVE_fnc_hashRem;

            } foreach (_groupsInCategory select 2);
        } foreach (_factionGroupCategories select 2);

        closeDialog 0;

        // update list

        private _listFactions = OC_getControl( OC_DISPLAY_FACTIONEDITOR , OC_FACTIONEDITOR_FACTIONS_LIST );
        [_logic,"loadFactionToList", _listFactions] call MAINCLASS:

        lbSort [_listFactions, "ASC"];
        [_listFactions,_className] call ALiVE_fnc_listSelectData;

    };

    // unit editor

    case "enableUnitEditorBackground": {

        private _enable = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        if (_enable) then {
            private _pos = getPos _logic;

            0 fadeSound 0;

            // init background
            private _background = createVehicle ["HeliHEmpty",[0,0,0],[],0,"none"];
            if ([_logic,"background"] call MAINCLASS) then {
                _background = createVehicle ["Sphere_3DEN",[0,0,0],[],0,"none"];
                _pos set [2,500];
            };
            _background setPos _pos;
            _background setDir 0;

            [_state,"unitEditor_interfaceBackground", _background] call ALiVE_fnc_hashSet;

            // init camera

            private _tempUnit = createVehicle [typeOf player,position player,[],0,"none"];
            _tempUnit setPos _pos;
            _tempUnit setDir 0;
            _tempUnit switchAction "playerstand";
            _tempUnit enableSimulation false;

            [_state,"unitEditor_activeUnitPosition", getPos _tempUnit] call ALiVE_fnc_hashSet;

            private _target = _tempUnit modelToWorld [0,4,1.6];
            [_logic,"deleteUnit", _tempUnit] call MAINCLASS;

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

            [_logic,"deleteUnit", _activeUnit] call MAINCLASS;
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

            private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
            private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;
            private _factionAssetsImported = [_factionData,"assetsImportedConfig"] call ALiVE_fnc_hashGet;

            private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
            [_logic,"deleteUnit", _activeUnit] call MAINCLASS;

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

            // reset unit list buttons

            private _classList_button2 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_TWO );
            _classList_button2 ctrlEnable false;

            private _classList_button3 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_THREE );
            _classList_button3 ctrlEnable false;

            private _classList_button4 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR );
            _classList_button4 ctrlEnable false;

            private _classList_button5 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FIVE );
            _classList_button5 ctrlEnable false;

            private _classList_button6 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_SIX );

            if (!_factionAssetsImported && {count _factionAssets > 0}) then {
                _classList_button6 ctrlShow true;
            } else {
                _classList_button6 ctrlShow false;
            };

            // populate list

            private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
            lbClear _unitList;

            {
                _index = _unitList lbAdd (_x select 0);
                _unitList lbSetData [_index, _x select 1];
            } foreach _units;

            [_state,"selectedFaction", _faction] call ALiVE_fnc_hashSet;

        };

    };

    case "onUnitEditorUnitListChanged": {

        private ["_customUnitParentEntry","_customUnitParent"];
        _args params ["_list","_index"];

        private _selectedUnitClassname = OC_ctrlGetSelData(_list);

        private _activeUnit = [_logic,"displayVehicle", _selectedUnitClassname] call MAINCLASS;

        private _realUnitClassname = [_logic,"getRealUnitClass", _selectedUnitClassname] call MAINCLASS;

        // reset unit list buttons

        private _unitListbutton2 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_TWO );
        _unitListbutton2 ctrlEnable true;

        private _unitListbutton3 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_THREE );
        _unitListbutton3 ctrlEnable true;

        private _unitListbutton4 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR );
        _unitListbutton4 ctrlEnable true;

        private _unitListbutton5 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_FIVE );
        _unitListbutton5 ctrlEnable true;

        if (_realUnitClassname isKindOf "Man") then {

            _unitListbutton2 ctrlSetText "Edit Loadout";
            _unitListbutton2 ctrlSetTooltip "Edit selected unit in the arsenal";
            _unitListbutton2 ctrlSetEventHandler ["MouseButtonDown","['onUnitEditorEditLoadoutClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

        } else {

            _unitListbutton2 ctrlSetText "Edit Vehicle";
            _unitListbutton2 ctrlSetTooltip "Edit selected vehicle";
            _unitListbutton2 ctrlSetEventHandler ["MouseButtonDown","['onUnitEditorEditVehicleClicked', _this] call ALiVE_fnc_orbatCreatorOnAction"];

            /*
            if (_realUnitClassname isKindOf "StaticWeapon") then {
                _unitListbutton2 ctrlEnable false;
            };
            */

        };

    };

    case "onUnitEditorEditLoadoutClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

        if (_activeUnit isKindOf "Man") then {

            // hide buttons

            private _display = findDisplay OC_DISPLAY_UNITEDITOR;
            private _displayControls = allControls _display;

            {
                _x ctrlShow false;
            } foreach _displayControls;

            // open interface

            ["Open",[true,objNull,_activeUnit]] call BIS_fnc_arsenal;

            [_logic,_state] spawn {
                private [
                    "_face","_index","_voice","_faceIdentityType",
                    "_facesForIdentity","_unitInsignia","_voiceIdentityType",
                    "_voicesForIdentity"
                ];

                params ["_logic","_state"];

                private _selUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
                private _selUnitData = [_logic,"getCustomUnit", _selUnit] call MAINCLASS;

                private _selUnitIdenityTypes = [_selUnitData,"identityTypes"] call ALiVE_fnc_hashGet;
                private _selUnitFace = [_selUnitIdenityTypes,"face"] call ALiVE_fnc_hashGet;
                private _selUnitVoice = [_selUnitIdenityTypes,"voice"] call ALiVE_fnc_hashGet;
                private _selUnitInsignia = [_selUnitIdenityTypes,"insignia"] call ALiVE_fnc_hashGet;

                waitUntil {!isNull (findDisplay -1)};
                disableSerialization;

                // a3\addons\ui_f\hpp\defineResinclDesign

                private _displayArsenal = findDisplay -1;

                // set button actions

                private _closeButton = _displayArsenal displayCtrl 44448;
                _closeButton ctrlSetText "Cancel Changes";
                (ctrlParent _closeButton) displayAddEventHandler ["Unload", "['onUnitEditorArsenalClosed', false] call ALiVE_fnc_orbatCreatorOnAction"];

                private _ctrlButtonOK = _displayArsenal displayctrl 44346;
                _ctrlButtonOK ctrlShow true;
                _ctrlButtonOK ctrlEnable true;
                _ctrlButtonOK ctrlSetText "Save Changes";
                _ctrlButtonOK buttonSetAction "['onUnitEditorArsenalClosed', true] call ALiVE_fnc_orbatCreatorOnAction";

                // hide unneeded buttons

                private _ctrlButtonSave = _displayArsenal displayctrl 44146;
                _ctrlButtonSave ctrlSetTooltip "Save loadout to arsenal.";
                //_ctrlButtonSave ctrlEnable false;

                private _ctrlButtonLoad = _displayArsenal displayctrl 44147;
                _ctrlButtonLoad ctrlSetTooltip "Load loadout from arsenal.";
                //_ctrlButtonLoad ctrlEnable false;

                private _ctrlButtonExport = _displayArsenal displayctrl 44148;
                _ctrlButtonExport ctrlSetTooltip "Export loadout to clipboard.";
                //_ctrlButtonExport ctrlEnable false;

                private _ctrlButtonImport = _displayArsenal displayctrl 44149;
                _ctrlButtonImport ctrlSetTooltip "Import loadout from clipboard.";
                //_ctrlButtonImport ctrlEnable false;

                private _iconList = 960;

                // fill faces list if blank

                private _ctrlListFaces = _displayArsenal displayCtrl (15 + _iconList);
                lbClear _ctrlListFaces;
                _ctrlListFaces ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitFaceChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _allFaceTypes = [_logic,"getFacesByIdentityType"] call MAINCLASS;

                private _faceIdentityTypes = _allFaceTypes select 1;
                private _facesArray = _allFaceTypes select 2;

                for "_i" from 0 to (count _faceIdentityTypes - 1) do {
                    _faceIdentityType = _faceIdentityTypes select _i;
                    _facesForIdentity = _facesArray select _i;

                    private _faceDisplayName = _faceIdentityType;
                    switch (tolower _faceIdentityType) do {
                        // vanilla
                        case "head_tk": {_faceDisplayName = "Persian"};
                        case "head_tk_camo_arid": {_faceDisplayName = "Persian (Camo,Arid)"};
                        case "head_tk_camo_lush": {_faceDisplayName = "Persian (Camo,Lush)"};
                        case "head_tk_camo_semiarid": {_faceDisplayName = "Persian (Camo,Semi-Arid)"};
                        case "head_nato": {_faceDisplayName = "NATO"};
                        case "head_euro": {_faceDisplayName = "European"};
                        case "head_nato_camo_arid": {_faceDisplayName = "NATO (Camo,Arid)"};
                        case "head_nato_camo_lush": {_faceDisplayName = "NATO (Camo,Lush)"};
                        case "head_nato_camo_semiarid": {_faceDisplayName = "NATO (Camo,Semi-Arid)"};
                        case "head_african": {_faceDisplayName = "African"};
                        case "head_greek": {_faceDisplayName = "Greek"};
                        case "head_greek_camo_arid": {_faceDisplayName = "Greek (Camo,Arid)"};
                        case "head_greek_camo_lush": {_faceDisplayName = "Greek (Camo,Lush)"};
                        case "head_greek_camo_semiarid": {_faceDisplayName = "Greek (Camo,Semi-Arid)"};
                        case "head_rangemaster": {_faceDisplayName = "Rangemaster"};
                        case "head_asian": {_faceDisplayName = "Asian"};
                        case "head_tanoan": {_faceDisplayName = "Tanoan"};

                        // cup

                        // rhs
                    };

                    _index = _ctrlListFaces lbAdd _faceDisplayName;
                    _ctrlListFaces lbSetData [_index, str [_faceIdentityType,_facesForIdentity]];

                    if (_faceIdentityType == _selUnitFace) then {
                        _ctrlListFaces lbSetCurSel _i;
                    };
                };

                // fill voices list if blank

                private _ctrlListVoices = _displayArsenal displayCtrl (16 + _iconList);
                lbClear _ctrlListVoices;
                _ctrlListVoices ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitVoiceChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _voicesByIdentityType = [_logic,"getVoicesByIdentityType"] call MAINCLASS;

                private _voiceIdentityTypes = _voicesByIdentityType select 1;
                private _voicesArray = _voicesByIdentityType select 2;

                for "_i" from 0 to (count _voiceIdentityTypes - 1) do {
                    _voiceIdentityType = _voiceIdentityTypes select _i;
                    _voicesForIdentity = _voicesArray select _i;

                    // manual mapped languages

                    private _voiceDisplayName = _voiceIdentityType;

                    switch (tolower _voiceIdentityType) do {
                        // vanilla
                        case "languageeng_f": {_voiceDisplayName = "English"};
                        case "languageengb_f": {_voiceDisplayName = "English (British)"};
                        case "languagegre_f": {_voiceDisplayName = "English (Altian)"};
                        case "languageper_f": {_voiceDisplayName = "Farsi"};
                        case "languageengvr_f": {_voiceDisplayName = "English (VR)"};
                        case "languagegrevr_f": {_voiceDisplayName = "English (Altian,VR)"};
                        case "languagepervr_f": {_voiceDisplayName = "Farsi (VR)"};
                        case "languagechi_f": {_voiceDisplayName = "Chinese"};
                        case "languagefre_f": {_voiceDisplayName = "French"};
                        case "languageengfre_f": {_voiceDisplayName = "English (French)"};

                        // cup
                        case "cup_d_language_ru": {_voiceDisplayName = "Russian (CUP)"};

                        // rhs
                        case "languagerus": {_voiceDisplayName = "Russian (RHS)"};
                    };

                    _index = _ctrlListVoices lbAdd _voiceDisplayName;
                    _ctrlListVoices lbSetData [_index, str [_voiceIdentityType,_voicesForIdentity]];

                    if (_voiceIdentityType == _SelUnitVoice) then {
                        _ctrlListVoices lbSetCurSel _i;
                    };
                };

                // fill insignia list if blank

                private _ctrlListInsignia = _displayArsenal displayCtrl (17 + _iconList);
                lbClear _ctrlListInsignia;
                _ctrlListInsignia ctrlSetEventHandler ["LBSelChanged","['onCreateUnitUnitInsigniaChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];

                private _cfgUnitInsignia = configFile >> "cfgunitinsignia";

                _index = _ctrlListInsignia lbAdd "<None>";
                _ctrlListInsignia lbSetData [_index, ""];

                for "_i" from 0 to (count _cfgUnitInsignia - 1) do {
                    _unitInsignia = _cfgUnitInsignia select _i;

                    if (isclass _unitInsignia) then {
                        _index = _ctrlListInsignia lbAdd ([_unitInsignia] call bis_fnc_displayname);
                        _ctrlListInsignia lbSetData [_index, configname _unitInsignia];
                        _ctrlListInsignia lbSetPicture [_index, getText(_unitInsignia >> "texture")];
                    };
                };

                [_ctrlListInsignia,_selUnitInsignia] call ALiVE_fnc_listSelectData;


            };

            [_state,"unitEditor_arsenalOpen", true] call ALiVE_fnc_hashSet;

        };

    };

    case "onUnitEditorEditVehicleClicked": {

        [_logic,"openInterface", "Edit_Vehicle"] spawn MAINCLASS;

    };

    case "onUnitEditorArsenalClosed": {

        private _saveChanges = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _arsenalOpen = [_state,"unitEditor_arsenalOpen"] call ALiVE_fnc_hashGet;

        if (_arsenalOpen) then {

            private _selectedUnitClassname = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;

            // reset camera

            if (_saveChanges) then {

                private _selectedUnitData = [_logic,"getCustomUnit", _selectedUnitClassname] call MAINCLASS;

                private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

                private _newLoadout = getUnitLoadout _activeUnit;
                [_selectedUnitData,"loadout", _newLoadout] call ALiVE_fnc_hashSet;

                // save face, voice, insignia

                private _displayArsenal = findDisplay -1;
                private _iconList = 960;

                private _ctrlListFaces = _displayArsenal displayCtrl (15 + _iconList);
                private _ctrlListVoices = _displayArsenal displayCtrl (16 + _iconList);
                private _ctrlListInsignia = _displayArsenal displayCtrl (17 + _iconList);

                private _selVoiceIdentityType = [_logic,"getVoiceIdentityType", _selVoice select 0] call MAINCLASS;

                private _identityTypes = [_selectedUnitData,"identityTypes"] call ALiVE_fnc_hashGet;

                if (lbCurSel _ctrlListFaces > -1) then {
                    private _selFaceData = call compile (OC_ctrlGetSelData( _ctrlListFaces ));
                    [_identityTypes,"face", _selFaceData select 0] call ALiVE_fnc_hashSet;
                };

                if (lbCurSel _selVoice > -1) then {
                    private _selVoice = call compile (OC_ctrlGetSelData( _ctrlListVoices ));
                    [_identityTypes,"voice", _selVoice select 0] call ALiVE_fnc_hashSet;
                };

                if (lbCurSel _ctrlListInsignia > -1) then {
                    private _selInsignia = OC_ctrlGetSelData( _ctrlListInsignia );
                    [_identityTypes,"insignia", _selInsignia] call ALiVE_fnc_hashSet;
                };

            };

            // update list

            [_state,"unitEditor_unitToSelect", _selectedUnitClassname] call ALiVE_fnc_hashSet;

            // reopen interface
            // if user pressed escape it closed all open dialogs -- bis pls

            closeDialog 0;
            [_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

            [_state,"unitEditor_arsenalOpen", false] call ALiVE_fnc_hashSet;

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
        [_classList,[_unitClassname], true] call ALiVE_fnc_listSelectData;

    };

    case "unitEditorCopyClicked": {

        private ["_unitClassname"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

        private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );

        // get selected units

        private _selectedIndices = lbSelection _unitList;
        private _selectedUnits = [];

        {
            _selectedUnits pushback (_unitList lbData _x);
        } foreach _selectedIndices;

        private _newUnitClasses = [];
        {
            _unitClassname = [_logic,"copyCustomUnit", _x] call MAINCLASS;
            _newUnitClasses pushback _unitClassname;
        } foreach _selectedUnits;

        // update list

        [_logic,"unitEditorDisplayFactionUnits", _faction] call MAINCLASS;
        [_unitList,_newUnitClasses, true] call ALiVE_fnc_listSelectData;

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
            [_logic,"removeCustomUnit", _x] call MAINCLASS;
        } foreach _selectedUnits;

        // rebuild list

        private _currIndex = lbCurSel _unitList;

        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
        [_logic,"unitEditorDisplayFactionUnits", _faction] call MAINCLASS;

        // if no entries remain in list
        // delete active unit

        if (lbSize _unitList == 0) then {
            private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;
            [_logic,"deleteUnit", _activeUnit] call MAINCLASS;
        };

    };

    case "unitEditorImportConfigClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

        private _importedUnits = [_logic,"importFactionUnitsFromConfig", _faction] call MAINCLASS;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        [_factionData,"assetsImportedConfig", true] call ALiVE_fnc_hashSet;

        // update lists

        private _unitListButton6 = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_BUTTON_SIX );
        _unitListButton6 ctrlShow false;

        private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
        private _currData = OC_getSelData( OC_UNITEDITOR_CLASSLIST_LIST );

        [_logic,"unitEditorDisplayFactionUnits", _faction] call MAINCLASS;

        [_unitList,[_currData],true] call ALiVE_fnc_listSelectData;

    };

    // create unit

    case "onCreateUnitSideChanged": {

        // a side has been selected
        // display all factions belonging to side

        _args params ["_list","_index"];

        private _sideNum = OC_ctrlGetSelData( _list );
        _sideNum = call compile _sideNum;

        private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_FACTION );
        [_logic,"displaySideFactionsInList", [_factionList,_sideNum]] call MAINCLASS;

    };

    case "onCreateUnitUnitTypeSideChanged": {

        // a side has been selected
        // display all factions belonging to side

        private ["_faction","_side","_factionDisplayName","_factionConfigName"];
        _args params ["_list","_index"];

        private _sideNum = OC_ctrlGetSelData( _list );
        _sideNum = call compile _sideNum;

        private _factionList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
        [_logic,"displaySideFactionsInList", [_factionList,_sideNum]] call MAINCLASS;

    };

    case "onCreateUnitUnitTypeFactionChanged": {

        private ["_unitDisplayName","_unitConfigName","_configName","_configPath","_displayName"];
        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData( _list );

        private _categoryList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_CATEGORY );

        [_logic,"loadFactionAssetCategoriesToList", [_faction,_categoryList]] call MAINCLASS;
        _categoryList lbSetCurSel 0;

    };

    case "onCreateUnitUnitTypeUnitCategoryChanged": {

        _args params ["_list","_index"];

        private _faction = OC_getSelData( OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
        private _category = OC_ctrlGetSelData( _list );

        private _unitList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );

        [_logic,"loadFactionAssetsInCategoryToList", [_faction,_category,_unitList]] call MAINCLASS;

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

        private _prefix = [_logic,"prefix"] call MAINCLASS;

        _side = [_logic,"convertSideToNum", _side] call MAINCLASS;
        private _sideText = [_side] call ALiVE_fnc_sideNumberToText;
        private _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;
        _sideTextLong = [_sideTextLong] call CBA_fnc_leftTrim;
        private _sidePrefix = _sideTextLong select [0,1];

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _shortName = [_factionData,"shortName", ""] call ALiVE_fnc_hashGet;
        private _camo = [_factionData,"camo",""] call ALiVE_fnC_hashGet;

        private _factionPrefix = [_faction," ",""] call CBA_fnc_replace;
        _factionPrefix = [_factionPrefix,"_",""] call CBA_fnc_replace;

        private _autogenClassname = [_logic,"displayNameToClassname", _displayName] call MAINCLASS;

        if (_shortName != "") then {
            _factionPrefix = _shortName;
        };

        // get number postfix
        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _customUnitClassnames = _customUnits select 1;

        private _postNum = 1;
        private _autogenClassnameNoNum = format ["%1_%2_%3", _sidePrefix, _factionPrefix, _autogenClassname];

        if (_prefix != "") then {
            _autogenClassnameNoNum = format ["%1_%2_%3_%4", _prefix, _sidePrefix, _factionPrefix, _autogenClassname];
        };

        if (_camo != "") then {
            _autogenClassnameNoNum = format["%1_%2",_autogenClassnameNoNum,_camo];
        };


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

    case "onCreateUnitUnitVoiceChanged": {

        _args params ["_list","_index"];

        private _voiceData = call compile (OC_ctrlGetSelData( _list ));
        _voiceData params ["_selVoiceIdentityType","_voices"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _unit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

        _unit setSpeaker (selectRandom _voices);


    };

    case "onCreateUnitUnitFaceChanged": {

        _args params ["_list","_index"];

        private _faceData = call compile (OC_ctrlGetSelData( _list ));
        _faceData params ["_identityType","_identityFaces"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _unit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

        _unit setFace (selectRandom _identityFaces);

    };

    case "onCreateUnitUnitInsigniaChanged": {

        _args params ["_list","_index"];

        private _insignia = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;
        private _unit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

        [_unit,_insignia] call BIS_fnc_setUnitInsignia;

    };

    case "onCreateUnitConfirmClicked": {

        private ["_turretConfig","_turretConfigName","_turretDisplayName","_turretGunnerType"];

        // validate prerequisites

        private _instructions = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_CONTEXT );
        private _parentUnitList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );

        private _displayNameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_DISPLAYNAME );
        private _classnameInput = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_CLASSNAME );
        private _displayName = ctrlText _displayNameInput;
        private _classname = ctrlText _classnameInput;

        if (_displayName == "") exitWith {_instructions ctrlSetText "Display name cannot be left blank"};
        if (_classname == "") exitWith {_instructions ctrlSetText "Class name cannot be left blank"};
        if (lbCurSel _parentUnitList == -1) exitWith {_instructions ctrlSetText "A unit type must be selected from the list"};

        private _state = [_logic,"state"] call MAINCLASS;

        // get side/faction

        private _side = call compile OC_getSelData( OC_CREATEUNIT_INPUT_SIDE );
        private _faction = OC_getSelData( OC_CREATEUNIT_INPUT_FACTION );

        // get displayname/configname

        _classname = [_logic,"validateClassname", _classname] call MAINCLASS;

        // get parent class

        private _parentClass = OC_getSelData( OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
        private _customUnit = [_logic,"getCustomUnit", _parentClass] call MAINCLASS;
        private _realParentClass = [_logic,"getRealUnitClass", _parentClass] call MAINCLASS;

        // create new custom unit

        private _newUnit = [nil,"create"] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"init"] call ALiVE_fnc_orbatCreatorUnit;
        [_newUnit,"inheritsFrom", _parentClass] call ALiVE_fnc_hashSet;
        [_newUnit,"side", _side] call ALiVE_fnc_hashSet;
        [_newUnit,"faction", _faction] call ALiVE_fnc_hashSet;
        [_newUnit,"displayName", _displayName] call ALiVE_fnc_hashSet;
        [_newUnit,"configName", _classname] call ALiVE_fnc_hashSet;

        if (isnil "_customUnit") then {
            private _parentCopy = [_logic,"importUnitFromConfig", _parentClass] call MAINCLASS;

            if (_realParentClass isKindOf "Man") then {
                private _loadout = +([_parentCopy,"loadout"] call ALiVE_fnc_hashGet);
                private _identityTypes = +([_parentCopy,"identityTypes"] call ALiVE_fnc_hashGet);

                [_newUnit,"loadout", _loadout] call ALiVE_fnc_hashSet;
                [_newUnit,"identityTypes", _identityTypes] call ALiVE_fnc_hashSet;
            } else {
                private _turrets = + ([_parentCopy,"turrets"] call ALiVE_fnc_hashGet);
                private _crew = [_parentCopy,"crew"] call ALiVE_fnc_hashGet;
                private _texture = [_parentCopy,"texture"] call ALiVE_fnc_hashGet;

                [_newUnit,"turrets", _turrets] call ALiVE_fnc_hashSet;
                [_newUnit,"crew", _crew] call ALiVE_fnc_hashSet;
                [_newUnit,"texture", _texture] call ALiVE_fnc_hashSet;
            };
        } else {
            private _realParentClass = [_logic,"getRealUnitClass", _parentClass] call MAINCLASS;

            if (_realParentClass isKindOf "Man") then {
                private _loadout = +([_customUnit,"loadout"] call ALiVE_fnc_hashGet);
                private _identityTypes = +([_customUnit,"identityTypes"] call ALiVE_fnc_hashGet);

                [_newUnit,"loadout", _loadout] call ALiVE_fnc_hashSet;
                [_newUnit,"identityTypes", _identityTypes] call ALiVE_fnc_hashSet;
            } else {
                private _turrets = + ([_customUnit,"turrets"] call ALiVE_fnc_hashGet);
                private _crew = [_customUnit,"crew"] call ALiVE_fnc_hashGet;
                private _texture = [_customUnit,"texture"] call ALiVE_fnc_hashGet;

                [_newUnit,"turrets", _turrets] call ALiVE_fnc_hashSet;
                [_newUnit,"crew", _crew] call ALiVE_fnc_hashSet;
                [_newUnit,"texture", _texture] call ALiVE_fnc_hashSet;
            };
        };

        [_logic,"addCustomUnit", _newUnit] call MAINCLASS;

        // close display
        // refresh unit editor custom units list

        closeDialog 0;

        private _selectedFaction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
        [_logic,"unitEditorDisplayFactionUnits", _selectedFaction] call MAINCLASS;

        private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
        [_unitList,[_classname], true] call ALiVE_fnc_listSelectData;

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
            _unitFaction = tolower (getText (_unitConfig >> "faction"));
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

    // edit unit

    case "onEditUnitUnitTypeUnitCategoryChanged": {

        _args params ["_list","_index"];

        private _faction = OC_getSelData( OC_CREATEUNIT_INPUT_UNITTYPE_FACTION );
        private _category = OC_ctrlGetSelData( _list );

        private _unitList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );

        // get unit classes to exclude

        private _state = [_logic,"state"] call MAINCLASS;
        private _selectedUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
        private _selectedUnitData = [_logic,"getCustomUnit", _selectedUnit] call MAINCLASS;

        private _unitParent = [_selectedUnitData,"inheritsFrom"] call ALiVE_fnc_hashGet;

        private _unitParentScope = getNumber(configFile >> "CfgVehicles" >> _unitParent >> "scope");

        if (_unitParentScope < 2) then {
            _unitParent = _selectedUnit;
        };

        private _children = [_logic,"getCustomUnitChildren", _selectedUnit] call MAINCLASS;
        private _customUnitConfig = configFile >> "CfgVehicles" >> _selectedUnit;

        private _unitsToExclude = [];
        _unitsToExclude append _children;

        if (!isClass _customUnitConfig) then {
            _unitsToExclude pushback _selectedUnit;
        };

        [_logic,"loadFactionAssetsInCategoryToList", [_faction,_category,_unitList,_unitsToExclude]] call MAINCLASS;

        private _classList = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_INPUT_UNITTYPE_UNITS );
        [_classList,_unitParent] call ALiVE_fnc_listSelectData;

    };

    case "onEditUnitConfirmClicked": {

        // unit is being edited
        // user has clicked confirm to save changes

        private ["_parentLoadout"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _selectedUnit = [_state,"unitEditor_selectedUnit"] call ALiVE_fnc_hashGet;
        private _selectedUnitData = [_logic,"getCustomUnit",_selectedUnit] call MAINCLASS;

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

        private _instructions = OC_getControl( OC_DISPLAY_CREATEUNIT , OC_CREATEUNIT_CONTEXT );

        if (_displayName == "") exitWith {_instructions ctrlSetText "Display name cannot be left blank"};
        if (_classname == "") exitWith {_instructions ctrlSetText "Class name cannot be left blank"};

        // prerequisites verified, begin saving

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

        if (_parentClass != _selectedUnit && {_parentClass != _unitParentClass}) then {
            [_selectedUnitData,"inheritsFrom", _parentClass] call ALiVE_fnc_hashSet;

            private _parentClassUnit = [_logic,"getCustomUnit", _parentClass] call MAINCLASS;
            private _realParentClass = [_logic,"getRealUnitClass", _unitParentClass] call MAINCLASS;

            if (isnil "_parentClassUnit") then {
                private _parentCopy = [_logic,"importUnitFromConfig", _parentClass] call MAINCLASS;

                if (_realParentClass isKindOf "Man") then {
                    private _loadout = +([_parentCopy,"loadout"] call ALiVE_fnc_hashGet);
                    private _identityTypes = +([_parentCopy,"identityTypes"] call ALiVE_fnc_hashGet);

                    [_selectedUnitData,"loadout", _loadout] call ALiVE_fnc_hashSet;
                    [_selectedUnitData,"identityTypes", _identityTypes] call ALiVE_fnc_hashSet;
                } else {
                    private _turrets = + ([_parentCopy,"turrets"] call ALiVE_fnc_hashGet);
                    private _crew = [_parentCopy,"crew"] call ALiVE_fnc_hashGet;
                    private _texture = [_parentCopy,"texture"] call ALiVE_fnc_hashGet;

                    [_selectedUnitData,"turrets", _turrets] call ALiVE_fnc_hashSet;
                    [_selectedUnitData,"crew", _crew] call ALiVE_fnc_hashSet;
                    [_selectedUnitData,"texture", _texture] call ALiVE_fnc_hashSet;
                };
            } else {
                if (_realParentClass isKindOf "Man") then {
                    private _loadout = +([_parentClassUnit,"loadout"] call ALiVE_fnc_hashGet);
                    private _identityTypes = +([_parentClassUnit,"identityTypes"] call ALiVE_fnc_hashGet);

                    [_selectedUnitData,"loadout", _loadout] call ALiVE_fnc_hashSet;
                    [_selectedUnitData,"identityTypes", _identityTypes] call ALiVE_fnc_hashSet;
                } else {
                    private _turrets = + ([_parentClassUnit,"turrets"] call ALiVE_fnc_hashGet);
                    private _crew = [_parentClassUnit,"crew"] call ALiVE_fnc_hashGet;
                    private _texture = [_parentClassUnit,"texture"] call ALiVE_fnc_hashGet;

                    [_selectedUnitData,"turrets", _turrets] call ALiVE_fnc_hashSet;
                    [_selectedUnitData,"crew", _crew] call ALiVE_fnc_hashSet;
                    [_selectedUnitData,"texture", _texture] call ALiVE_fnc_hashSet;
                };
            };
        };

        private _realUnitClass = [_logic,"getRealUnitClass", _selectedUnit] call MAINCLASS;

        closeDialog 0;

        private _selectedFaction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
        [_logic,"unitEditorDisplayFactionUnits", _selectedFaction] call MAINCLASS;

        private _unitList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
        [_unitList,[_selectedUnit], true] call ALiVE_fnc_listSelectData;

    };

    // edit vehicle

    case "onEditVehicleCancelClicked": {

        closeDialog 0;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"activeInteface", "Unit_Editor"] call ALiVE_fnc_hashSet; // hack because unit editor is never closeds

    };

    case "onEditVehicleResetClicked": {

        // this method is currently unused

        private _state = [_logic,"state"] call MAINCLASS;
        private _vehicle = [_state,"editVehicle_vehicle"] call ALiVE_fnc_hashGet;

        private _realVehicle = [_logic,"getRealUnitClass", _vehicle] call MAINCLASS;
        private _realVehicleConfig = configFile >> "CfgVehicles" >> _realVehicle;

        private _realVehicleCrew = getText (_realVehicleConfig >> "crew");
        private _realVehicleTexture = (getArray (_realVehicleConfig >> "textureList")) select 0;

        [_state,"editVehicle_selectedCrew", _realVehicleCrew] call ALiVE_fnc_hashSet; // editVehicle_selectedCrewBySlot
        [_state,"editVehicle_selectedTexture", _realVehicleTexture] call ALiVE_fnc_hashSet;

        private _left_list_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_ONE );
        _left_list_one ctrlshow false;

        private _left_list_two = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_TWO );
        _left_list_two ctrlshow false;

        private _left_list_three = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_THREE );
        _left_list_three ctrlshow false;

    };

    case "onEditVehicleSaveClicked": {

        private ["_turretData","_newCrew","_oldCrew"];

        private _state = [_logic,"state"] call MAINCLASS;

        private _vehicle = [_state,"editVehicle_vehicle"] call ALiVE_fnc_hashGet;
        private _crewBySlot = [_state,"editVehicle_selectedCrewBySlot"] call ALiVE_fnc_hashGet;
        private _texture = [_state,"editVehicle_selectedTexture"] call ALiVE_fnc_hashGet;

        private _vehicleData = [_logic,"getCustomUnit", _vehicle] call MAINCLASS;
        private _vehicleCrew = [_vehicleData,"crew"] call ALiVE_fnc_hashGet;
        private _vehicleTurrets = [_vehicleData,"turrets"] call ALiVE_fnc_hashGet;
        private _vehicleTexture = [_vehicleData,"texture"] call ALiVE_fnc_hashGet;

        private _crew = [_crewBySlot,"crew"] call ALiVE_fnc_hashGet;
        if (_crew != _vehicleCrew) then {
            [_vehicleData,"crew", _crew] call ALiVE_fnc_hashSet;
        };

        [_crewBySlot,"crew", nil] call ALiVE_fnc_hashSet;

        private _vehicleTurretClasses = _vehicleTurrets select 1;
        {
            _turretData = [_vehicleTurrets,_x] call ALiVE_fnc_hashGet;

            _newCrew = [_crewBySlot,_x, "noChange"] call ALiVE_fnc_hashGet; // default cannot be "" as this represents empty slot
            _oldCrew = _turretData select 0;

            if (_newCrew != "noChange" && {_newCrew != _oldCrew}) then {
                _turretData set [2,_newCrew];
            };
        } foreach _vehicleTurretClasses;

        if !(_texture == _vehicleTexture) then {
            [_vehicleData,"texture", _texture] call ALiVE_fnc_hashSet;
        };

        closeDialog 0;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"activeInteface", "Unit_Editor"] call ALiVE_fnc_hashSet; // hack because unit editor is never closed

    };

    case "onEditVehicleCrewClicked": {

        private _rightListOne = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE );

        if (ctrlShown _rightListOne) exitWith {
            _rightListOne ctrlShow false;

            private _rightListOneTitle = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE_TITLE );
            _rightListOneTitle ctrlShow false;

            private _left_list_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_ONE );
            _left_list_one ctrlShow false;
        };

        private _left_list_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_ONE );
        _left_list_one ctrlShow true;

        private _left_list_two = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_TWO );
        _left_list_two ctrlshow false;

        private _left_list_three = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_THREE );
        _left_list_three ctrlshow false;

        private _rightListOneTitle = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE_TITLE );
        _rightListOneTitle ctrlShow true;

        private _rightListOne = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE );
        _rightListOne ctrlShow true;
        _rightListOne lbSetCurSel 0;

    };

    case "onEditVehicleCrewSlotChanged": {

        _args params ["_list","_index"];

        private _slot = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;

        private _selectedCrewBySlot = [_state,"editVehicle_selectedCrewBySlot"] call ALiVE_fnc_hashGet;
        private _selectedCrew = [_selectedCrewBySlot,_slot] call ALiVE_fnc_hashGet;

        private _left_list_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_ONE );
        [_left_list_one,_selectedCrew] call ALiVE_fnc_listSelectData;

    };

    case "onEditVehicleCrewChanged": {

        _args params ["_list","_index"];

        private _unit = OC_ctrlGetSelData( _list );
        private _slot = OC_getSelData( OC_EDITVEHICLE_RIGHT_LIST_ONE );

        private _state = [_logic,"state"] call MAINCLASS;

        private _selectedCrewBySlot = [_state,"editVehicle_selectedCrewBySlot"] call ALiVE_fnc_hashGet;
        [_selectedCrewBySlot,_slot,_unit] call ALiVE_fnc_hashSet;

    };

    case "onEditVehicleAppearanceClicked": {

        private ["_index"];

        private _rightListOneTitle = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE_TITLE );
        _rightListOneTitle ctrlShow false;

        private _rightListOne = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_RIGHT_LIST_ONE );
        _rightListOne ctrlRemoveAllEventHandlers "MouseButtonDown";
        _rightListOne ctrlShow false;

        private _left_list_two = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_TWO );

        if (ctrlShown _left_list_two) then {
            _left_list_two ctrlshow false;

            private _left_list_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_ONE );
            _left_list_one ctrlshow false;

            private _left_list_three = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_THREE );
            _left_list_three ctrlshow false;
        } else {
            _left_list_two ctrlshow true;

            private _left_list_one = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_ONE );
            _left_list_one ctrlshow false;

            private _left_list_three = OC_getControl( OC_DISPLAY_EDITVEHICLE , OC_EDITVEHICLE_LEFT_LIST_THREE );
            _left_list_three ctrlshow false;
        };

        private _state = [_logic,"state"] call MAINCLASS;

        private _selectedVehicle = [_state,"editVehicle_vehicle"] call ALiVE_fnc_hashGet;
        private _realVehClass = [_logic,"getRealUnitClass", _selectedVehicle] call MAINCLASS;

        private _textures = [_logic,"getVehicleTextureSourcesByName", _realVehClass] call MAINCLASS;

        lbClear _left_list_two;

        {
            _x params ["_textureConfigName","_textureDisplayName","_textureArray"];

            _index = _left_list_two lbAdd _textureDisplayName;
            _left_list_two lbSetData [_index, _textureConfigName];
        } foreach _textures;

        private _selectedTexture = [_state,"editVehicle_selectedTexture"] call ALiVE_fnc_hashGet;
        [_left_list_two,str _selectedTexture] call ALiVE_fnc_listSelectData;

    };

    case "onEditVehicleAppearanceSelected": {

        _args params ["_list","_index"];

        private _selectedTexture = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;
        private _activeObject = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

        [_state,"editVehicle_selectedTexture", _selectedTexture] call ALiVE_fnc_hashSet;

        [_logic,"setVehicleTexure", [_activeObject,_selectedTexture]] call MAINCLASS;

    };

    // group editor

    case "onGroupEditorFactionChanged": {

        _args params ["_list","_index"];

        private _faction = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;

        [_logic,"groupEditorDisplayFactionGroupCategories", _faction] call MAINCLASS;
        [_logic,"groupEditorDisplayFactionAssetCategories", _faction] call MAINCLASS;

    };

    case "groupEditorDisplayFactionGroupCategories": {

        private ["_category","_categoryDisplayName","_categoryConfigName","_index"];

        private _faction = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"selectedFaction", _faction] call ALiVE_fnc_hashSet;

        // add categories to list

        private _categoryList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_INPUT_CATEGORY );
        [_logic,"loadFactionGroupCategoriesToList", [_categoryList,_faction]] call MAINCLASS;

        if (lbSize _categoryList > 0) then {
            _categoryList lbSetCurSel 0;
        };

        // reset category list

        private _assetCategories = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_INPUT_CATEGORY );
        _assetCategories lbSetCurSel 0;

    };

    case "groupEditorDisplayFactionAssetCategories": {

        private ["_index"];

        private _faction = _args;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionAssetCategories = [_factionData,"assetCategories"] call ALiVE_fnc_hashGet;

        private _inputCategories = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_INPUT_CATEGORY );
        lbClear _inputCategories;

        [_logic,"loadFactionAssetCategoriesToList", [_faction,_inputCategories]] call MAINCLASS;
        _inputCategories lbSetCurSel 0;

    };

    case "onGroupEditorAssetCategoryChanged": {

        _args params ["_list","_index"];

        private _category = OC_ctrlGetSelData( _list );

        // disable buttons

        private _button1 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_ONE );
        _button1 ctrlEnable false;

        private _button2 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_BUTTON_TWO );
        _button2 ctrlEnable false;

        [_logic,"groupEditorDisplayFactionAssetsInCategory", _category] call MAINCLASS;

    };

    case "groupEditorDisplayFactionAssetsInCategory": {

        private [
            "_unitConfigName","_unitDisplayName","_realUnit","_realUnitEditorSubCategory",
            "_add","_index","_assetConfigName","_assetConfigPath","_assetEditorSubcategory",
            "_assetDisplayName"
        ];

        private _category = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

        private _factionData = [_factions,_faction] call ALiVE_fnc_hashGet;
        private _factionAssets = [_factionData,"assets"] call ALiVE_fnc_hashGet;
        private _customUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;

        // set units to list

        private _assetList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_ASSETS_LIST_UNITS );
        lbClear _assetList;

        [_logic,"loadFactionAssetsInCategoryToList", [_faction,_category,_assetList]] call MAINCLASS;

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

        (findDisplay OC_DISPLAY_GROUPEDITOR) displayAddEventHandler ["MouseButtonUp", "['groupEditorOnDragEnd', _this] call ALiVE_fnc_orbatCreatorOnAction"];

        private _groupUnitListGreenCover = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS_GREENCOVER );
        _groupUnitListGreenCover ctrlshow true;

    };

    case "onGroupEditorSelectedGroupListDragStart": {

        _args params ["_list","_dragData"];

        private _selIndex = _dragData select 0 select 1;

        private _state = [_logic,"state"] call MAINCLASS;
        [_state,"groupEditor_selectedGroupDragTargetIndex", _selIndex] call ALiVE_fnc_hashSet;

        (findDisplay OC_DISPLAY_GROUPEDITOR) displayAddEventHandler ["MouseButtonUp","['groupEditorOnDragEnd', _this] call ALiVE_fnc_orbatCreatorOnAction"];

        // clicking the unit list causes it to be above the green cover
        //private _groupUnitListGreenCover = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS_GREENCOVER );
        //_groupUnitListGreenCover ctrlshow true;

    };

    case "groupEditorOnDragEnd": {

        _args params ["_display","_button","_mouseX","_mouseY"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _assetListDragTarget = [_state,"groupEditor_assetListDragTarget"] call ALiVE_fnc_hashGet;
        private _selectedGroupDragTargetIndex = [_state,"groupEditor_selectedGroupDragTargetIndex"] call ALiVE_fnc_hashGet;

        private _posWithinCtrls = {
            params ["_pos","_ctrls"];

            private _validDrop = false;

            {
                private _ctrlPos = ctrlPosition _x;

                if (
                    _pos select 0 >= _ctrlPos select 0 &&
                    {_pos select 1 >= _ctrlPos select 1} &&
                    {_pos select 0 <= (_ctrlPos select 0) + (_ctrlPos select 2)} &&
                    {_pos select 1 <= (_ctrlPos select 1) + (_ctrlPos select 3)}
                ) then {
                    _validDrop = true;
                };
            } foreach _ctrls;

            _validDrop
        };

        // asset list to selected group unit list

        if (_assetListDragTarget != "") then {
            private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

            if (_group != "") then {

                private _validControlsForDrop = [_display displayCtrl OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS, _display displayCtrl OC_GROUPEDITOR_SELECTEDGROUP_HEADER];

                private _validDrop = [[_mouseX,_mouseY],_validControlsForDrop] call _posWithinCtrls;

                if (_validDrop) then {
                    private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                    private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
                    private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

                    private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
                    [_logic,"groupAddUnit", [_groupData,_assetListDragTarget]] call MAINCLASS;

                    // update list

                    [_logic,"groupEditorDisplayGroupUnits", _groupData] call MAINCLASS;
                };
            };

            [_state,"groupEditor_assetListDragTarget", ""] call ALiVE_fnc_hashSet;

            private _groupUnitListGreenCover = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS_GREENCOVER );
            _groupUnitListGreenCover ctrlshow false;
        };

        // selected group unit list to anywhere outside the list

        if (_selectedGroupDragTargetIndex != -1) then {
            private _ctrlsToAvoid = [_display displayCtrl OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS, _display displayCtrl OC_GROUPEDITOR_SELECTEDGROUP_HEADER];

            private _validDrop = !([[_mouseX,_mouseY],_ctrlsToAvoid] call _posWithinCtrls);

            if (_validDrop) then {
                private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
                private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

                private _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_group]] call MAINCLASS;
                [_logic,"groupRemoveUnit", [_groupData,_selectedGroupDragTargetIndex]] call MAINCLASS;

                // update list

                [_logic,"groupEditorDisplayGroupUnits", _groupData] call MAINCLASS;

                private _groupUnitListGreenCover = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS_GREENCOVER );
                _groupUnitListGreenCover ctrlshow false;
            };

            [_state,"groupEditor_selectedGroupDragTargetIndex", -1] call ALiVE_fnc_hashSet;
        };

        (findDisplay OC_DISPLAY_GROUPEDITOR) displayRemoveAllEventHandlers  "onMouseButtonUp";

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
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

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

        private _button4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_FOUR );
        _button4 ctrlEnable false;

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

        private _button4 = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_BUTTON_FOUR );
        _button4 ctrlEnable true;

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
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
            _selectedGroupUnitList lbSetValue [_index, _index];
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
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
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

        [_logic,"displayVehicle", _unit] call MAINCLASS;

    };

    case "onGroupEditorSelectedGroupUnitRankChangedClicked": {

        _args params ["_list","_index"];

        private _rank = OC_ctrlGetSelData( _list );

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
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

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnit = [_logic,"getCustomUnit", _unit] call MAINCLASS;

        if (isnil "_customUnit") then {
            private _newUnit = [_logic,"importUnitFromConfig", _unit] call MAINCLASS;
            [_logic,"addCustomUnit", _newUnit] call MAINCLASS;
        };

        [_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

        [_state,"unitEditor_unitToSelect", _unit] call ALiVE_fnc_hashSet;

    };

    case "onGroupEditorSelectedGroupRemoveUnitClicked": {

        private _unitList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_SELECTEDGROUP_LIST_UNITS );
        private _unitIndex = lbCurSel _unitList;

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
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

    case "onGroupEditorGroupsCopyClicked": {

        private ["_groupData","_groupClassname"];

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
        private _categoryData = [_logic,"getFactionGroupCategory", [_faction,_category]] call MAINCLASS;

        private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );

        // get selected groups

        private _selectedIndices = lbSelection _groupList;
        private _selectedGroups = [];

        {
            _selectedGroups pushback (_groupList lbData _x);
        } foreach _selectedIndices;

        private _newGroupClasses = [];
        {
            _groupData = [_logic,"getFactionCategoryGroup", [_faction,_category,_x]] call MAINCLASS;
            _groupClassname = [_logic,"copyCategoryGroup", [_categoryData,_groupData]] call MAINCLASS;
            _newGroupClasses pushback _groupClassname;
        } foreach _selectedGroups;

        // update list

        [_logic,"groupEditorDisplayFactionGroupsInCategory", _category] call MAINCLASS;
        [_groupList,_newGroupClasses, true] call ALiVE_fnc_listSelectData;

    };

    case "onGroupEditorGroupsDeleteClicked": {

        private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
        private _selectedIndices = lbSelection _groupList;
        private _selectedGroups = [];

        {
            _selectedGroups pushback (_groupList lbData _x);
        } foreach _selectedIndices;

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
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
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
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

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnit = [_logic,"getCustomUnit", _asset] call MAINCLASS;

        if (isnil "_customUnit") then {
            private _newUnit = [_logic,"importUnitFromConfig", _asset] call MAINCLASS;
            [_logic,"addCustomUnit", _newUnit] call MAINCLASS;
        };

        [_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

        [_state,"unitEditor_unitToSelect", _asset] call ALiVE_fnc_hashSet;

    };

    // create group

    case "onCreateGroupAutogenClassnameClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;

        private _inputName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_NAME );
        private _groupName = ctrlText _inputName;

        private _autogenGroupClassname = [_logic,"generateGroupClassname", [_faction,_category,_groupName]] call MAINCLASS;

        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CLASSNAME );
        _inputClassname ctrlSetText _autogenGroupClassname;

    };

    case "generateGroupClassname": {

        _args params ["_faction","_category","_groupName"];

        private _prefix = [_logic,"prefix"] call MAINCLASS;
        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;

        private _side = [_factionData,"side"] call ALiVE_fnC_hashGet;
        private _sideText = [_side] call ALiVE_fnc_sideNumberToText;
        private _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;
        _sideTextLong = [_sideTextLong] call CBA_fnc_leftTrim;
        private _sidePrefix = _sideTextLong select [0,1];
        private _shortName = [_factionData,"shortName",""] call ALiVE_fnC_hashGet;
        private _camo = [_factionData,"camo",""] call ALiVE_fnC_hashGet;

        _groupName = [_logic,"displayNameToClassname", _groupName] call MAINCLASS;

        if (_shortName == "") then {
            private _factionPrefix = [_faction," ",""] call CBA_fnc_replace;
            _shortName = [_factionPrefix,"_",""] call CBA_fnc_replace;
        };

        _result = format ["%1_%2_%3_%4", _sidePrefix, _shortName, _category, _groupName];

        if (_prefix != "") then {
            _result = format ["%1_%2_%3_%4_%5", _prefix, _sidePrefix, _shortName, _category, _groupName];
        };

        if (_camo != "") then {
            _result = format ["%1_%2",_result,_camo];
        };

        _result = toLower _result;

    };

    case "onCreateGroupConfirmClicked": {

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;

        private _instructions = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_CONTEXT );

        private _groupIcon = OC_getSelData( OC_CREATEGROUP_INPUT_ICON );

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
        [_newGroup,"icon", _groupIcon] call ALiVE_fnc_hashSet;
        [_newGroup,"rarityGroup", 0.5] call ALiVE_fnc_hashSet;
        [_newGroup,"units", []] call ALiVE_fnc_hashSet;

        [_groups,_groupClassName, _newGroup] call ALiVE_fnc_hashSet;

        closeDialog 0;

        [_logic,"groupEditorDisplayFactionGroupsInCategory", _groupCategory] call MAINCLASS;

        private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
        [_groupList,[_groupClassName], true] call ALiVE_fnc_listSelectData;

    };

    // edit group

    case "onEditGroupConfirmClicked": {

        private _state = [_logic,"state"] call MAINCLASS;

        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
        private _category = [_state,"groupEditor_selectedGroupCategory"] call ALiVE_fnc_hashGet;
        private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _currentGroupCategory = [_logic,"getFactionGroupCategory", [_faction,_category]] call MAINCLASS;
        private _currentCategoryGroups = [_currentGroupCategory,"groups"] call ALiVE_fnc_hashGet;

        private _inputName = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_NAME );
        private _inputClassname = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_INPUT_CLASSNAME );
        private _instructions = OC_getControl( OC_DISPLAY_CREATEGROUP , OC_CREATEGROUP_CONTEXT );

        private _selGroupName = ctrlText _inputName;
        private _selGroupClassname = ctrlText _inputClassname;
        private _selCategory = OC_getSelData( OC_CREATEGROUP_INPUT_CATEGORY );
        private _selIcon = OC_getSelData( OC_CREATEGROUP_INPUT_ICON );

        private _newGroupCategory = [_logic,"getFactionGroupCategory", [_faction,_selCategory]] call MAINCLASS;
        private _newGroupCategoryGroups = [_newGroupCategory,"groups"] call ALiVE_fnc_hashGet;
        private _newCategoryGroupClassnames = _newGroupCategoryGroups select 1;

        private _saveAborted = false;
        private _groupsToSelect = [];

        private _listGroups = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
        private _selectedIndices = lbSelection _listGroups;

        if (count _selectedIndices > 1) then {
            // editing multiple groups

            private _groups = [];

            {
                private _group = _listGroups lbData _x;

                _groups pushback _group;
            } foreach _selectedIndices;

            // if selected category has changed
            // and any of the selected group config names
            // exist in selected category, abort save

            private _sharedConfigNames = _newCategoryGroupClassnames arrayIntersect _groups;

            if (_selCategory != _category && {count _sharedConfigNames > 0}) exitWith {
                _instructions ctrlSetText (format ["At least one of the selected group's config names already exists in the selected category %1", _sharedConfigNames]);
                _saveAborted = true;
            };

            {
                private _groupConfigName = _x;
                private _groupData = [_currentCategoryGroups,_groupConfigName] call ALiVE_fnc_hashGet;
                private _groupIcon = [_groupData,"icon"] call ALiVE_fnc_hashGet;

                if (_selIcon != _groupIcon) then {
                    [_groupData,"icon", _selIcon] call ALiVE_fnc_hashSet;
                };

                if (_selCategory != _category) then {
                    [_currentCategoryGroups,_groupConfigName, nil] call ALiVE_fnc_hashSet;
                    [_newGroupCategoryGroups,_groupConfigName, _groupData] call ALiVE_fnc_hashSet;
                };
            } foreach _groups;

            _groupsToSelect = _groups;
        } else {
            // editing single group

            // verify valid input

            if (_selGroupName == "") exitWith {
                _instructions ctrlSetText "Group name cannot be blank";
                _saveAborted = true;
            };

            if (_selGroupClassname == "") exitWith {
                _instructions ctrlSetText "Class name cannot be blank";
                _saveAborted = true;
            };

            private _group = [_state,"groupEditor_selectedGroup"] call ALiVE_fnc_hashGet;

            private _groupData = [_currentCategoryGroups,_group] call ALiVE_fnc_hashGet;
            private _groupName = [_groupData,"name"] call ALiVE_fnc_hashGet;
            private _groupConfigName = [_groupData,"configName"] call ALiVE_fnc_hashGet;
            private _groupIcon = [_groupData,"icon"] call ALiVE_fnc_hashGet;

            // if config name was changed
            // and the new config name exists
            // in the selected category, abort save

            if ((_selGroupClassname != _groupConfigName || {_selCategory != _category}) && {_selGroupClassname in _newCategoryGroupClassnames}) exitWith {
                _instructions ctrlSetText "A group with that classname already exists in the selected category";
                _saveAborted = true;
            };

            if (_selGroupName != _groupName) then {
                [_groupData,"name", _selGroupName] call ALiVE_fnc_hashSet;
                _groupName = _selGroupName;
            };

            if (_selGroupClassname != _groupConfigName) then {
                _selGroupClassname = [_logic,"validateClassname", _selGroupClassname] call MAINCLASS;
                [_groupData,"configName", _selGroupClassname] call ALiVE_fnc_hashSet;

                [_currentCategoryGroups, _groupConfigName, nil] call ALiVE_fnc_hashSet;
                [_currentCategoryGroups,_selGroupClassname, _groupData] call ALiVE_fnc_hashSet;
                _groupConfigName = _selGroupClassname;
            };

            if (_selIcon != _groupIcon) then {
                [_groupData,"icon", _selIcon] call ALiVE_fnc_hashSet;
            };

            if (_selCategory != _category) then {
                [_currentCategoryGroups,_groupConfigName, nil] call ALiVE_fnc_hashSet;
                [_newGroupCategoryGroups,_groupConfigName,_groupData] call ALiVE_fnc_hashSet;
            };

            _groupsToSelect pushback _groupConfigName;
        };

        if (!_saveAborted) then {
            closeDialog 0;

            [_logic,"groupEditorDisplayFactionGroupsInCategory", _selCategory] call MAINCLASS;

            private _groupList = OC_getControl( OC_DISPLAY_GROUPEDITOR , OC_GROUPEDITOR_GROUPS_LIST_GROUPS );
            [_groupList,_groupsToSelect, true] call ALiVE_fnc_listSelectData;
        };

    };

    // config generation

    case "exportConfig": {

        private _mode = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;

        switch (_mode) do {

            case "Faction": {

                _result = [_logic,"getFactionClassExportString", _faction] call MAINCLASS;

                _result = [_logic,"formatFullExportToComment", _result] call MAINCLASS;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

            case "Crates" : {

                private _factionUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;
                private _factionUnitClasses = [];

                {
                    _factionUnitClasses pushback ([_x,"configName"] call ALiVE_fnc_hashGet);
                } foreach _factionUnits;

                [_faction, _factionUnitCLasses, _logic] spawn {
                    systemchat "Processing faction for crates, please wait....";

                    _result = [_this select 2, "exportFactionCrates", [_this select 0, _this select 1]] call MAINCLASS;

                    systemchat "Faction crates copied to clipboard";

                    copyToClipboard _result;
                };

            };

            case "Images" : {

                private _factionUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;
                private _factionUnitClasses = [];
                {
                    _factionUnitClasses pushback ([_x,"configName"] call ALiVE_fnc_hashGet);
                } foreach _factionUnits;

                _faction = [toLower(_faction),format["%1_",_prefix],""] call CBA_fnc_replace;

                private _path = format["addons\%1\data\preview", _faction];
                private _handle = [1,_factionUnitClasses,_path,_prefix,_faction,_logic] spawn ALiVE_fnc_exportORBATEditorPreviews;

                systemchat "WARNING! Editor preview images saved to your profile under Screenshots. Resize images and convert to JPG. Copy to your mod addons folder.";

            };

            case "UnitsSelected": {

                private _currentState = [_state, "activeInteface"] call ALiVE_fnc_hashGet;

                if (_currentState == "Unit_Editor") then {

                    private _classList = OC_getControl( OC_DISPLAY_UNITEDITOR , OC_UNITEDITOR_CLASSLIST_LIST );
                    private _selectedIndices = lbSelection _classList;
                    private _selectedUnits = [];

                    {
                        _selectedUnits pushback (_classList lbData _x);
                    } foreach _selectedIndices;

                    _result = [_logic,"exportCustomUnits", _selectedUnits] call MAINCLASS;

                    _result = [_logic,"formatFullExportToComment", _result] call MAINCLASS;

                    systemchat "Config data copied to clipboard";
                    copyToClipboard _result;

                };

            };

            case "UnitsAll": {

                private _factionUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;
                private _factionUnitClasses = [];

                {
                    _factionUnitClasses pushback ([_x,"configName"] call ALiVE_fnc_hashGet);
                } foreach _factionUnits;

                 _result = [_logic,"exportCustomUnits", _factionUnitClasses] call MAINCLASS;

                 _result = [_logic,"formatFullExportToComment", _result] call MAINCLASS;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

            case "UnitsClasses": {

                private _factionUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;
                private _factionUnitClasses = [];

                {
                    _factionUnitClasses pushback ([_x,"configName"] call ALiVE_fnc_hashGet);
                } foreach _factionUnits;

                _result = "";
                private _indent = "    ";
                private _newLine = toString [13,10];

                // convert to vertical string

                {
                    if (_forEachIndex != 0) then {
                        _result = _result + _newLine;
                    };

                    _result = _result + str _x;

                    if (_forEachIndex != (count _factionUnitClasses) - 1) then {
                        _result = _result + ",";
                    };
                } foreach _factionUnitClasses;

                systemchat "Unit classnames copied to clipboard";
                copyToClipboard _result;
            };

            case "GroupsSelected": {

                private _currentState = [_state,"activeInteface"] call ALiVE_fnc_hashGet;

                if (_currentState == "Group_Editor") then {

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

                    _result = [_logic,"formatFullExportToComment", _result] call MAINCLASS;

                    systemchat "Config data copied to clipboard";
                    copyToClipboard _result;

                };

            };

            case "GroupsAll": {

                private ["_category","_categoryGroups","_categoryGroupClasses"];

                private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
                private _groupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

                _result = "";
                private _indent = "    ";
                private _newLine = toString [13,10];

                // get groups by category

                private _categoryGroupPairs = [];

                {
                    _category = _x;
                    _categoryGroups = [_category,"groups"] call ALiVE_fnc_hashGet;
                    _categoryGroupClasses = _categoryGroups select 1;

                    _categoryGroupPairs pushback [_category,_categoryGroupClasses];
                } foreach (_groupCategories select 2);

                private _CFGgroups = "";
                {
                    _groupCategoryExportString = [_logic,"exportGroupsInCategory", _x] call MAINCLASS;
                    _CFGgroups = _CFGgroups + _groupCategoryExportString + _newLine;
                } foreach _categoryGroupPairs;

                _result = [_logic,"formatGroupCategoriesToFaction", [_faction,_CFGgroups]] call MAINCLASS;

                _result = [_logic,"formatFullExportToComment", _result] call MAINCLASS;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

            case "GroupsAllStaticData": {

                private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
                private _groupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

                _result = "";
                private _indent = "    ";
                private _newLine = toString [13,10];

                // type mappings

                private _typeMappingsVar = format ["%1_typeMappings", _faction];

                private _typeMappings = "";
                _typeMappings = _typeMappings + _typeMappingsVar + " = [] call ALiVE_fnc_hashCreate;" + _newLine;

                // custom groups

                private _groupCategories = [_factionData,"groupCategories"] call ALiVE_fnc_hashGet;

                private _factionCustomGroupsVar = format ["%1_factionCustomGroups", _faction];

                private _factionCustomGroups = "";
                _factionCustomGroups = _factionCustomGroups + _factionCustomGroupsVar + " = [] call ALiVE_fnc_hashCreate;" + _newLine;

                {
                    private _groupCategory = [_groupCategories,_x] call ALiVE_fnc_hashGet;
                    private _configName = [_groupCategory,"configName"] call ALiVE_fnc_hashGet;
                    private _groups = ([_groupCategory,"groups"] call ALiVE_fnc_hashGet) select 2;

                    private _groupClassnames = _groups apply {[_x,"configName"] call ALiVE_fnc_hashGet};

                    _factionCustomGroups = _factionCustomGroups + (format ["[%1,%2, %3] call ALiVE_fnc_hashSet;", _factionCustomGroupsVar, str _configName, _groupClassnames]) + _newLine;
                } foreach ALIVE_COMPATIBLE_GROUP_CATEGORIES;

                // faction mappings

                private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
                private _factionSideText = [_factionSide] call ALiVE_fnc_sideNumberToText;

                if (_factionSideText == "GUER") then {_factionSideText == "INDEP"};

                private _groupCategoriesRootName = [_factionData,"groupCategoriesRootName"] call ALiVE_fnc_hashGet;

                private _factionMappingsVar = format ["%1_mappings", _faction];

                private _factionMappings = "";
                _factionMappings = _factionMappings + _factionMappingsVar + " = [] call ALiVE_fnc_hashCreate;" + _newLine;
                _factionMappings = _factionMappings + (format ["[%1,""Side"", %2] call ALiVE_fnc_hashSet;", _factionMappingsVar, str _factionSideText]) + _newLine;
                _factionMappings = _factionMappings + (format ["[%1,""GroupSideName"", %2] call ALiVE_fnc_hashSet;", _factionMappingsVar, str _factionSideText]) + _newLine;
                _factionMappings = _factionMappings + (format ["[%1,""FactionName"", %2] call ALiVE_fnc_hashSet;", _factionMappingsVar, str _faction]) + _newLine;
                _factionMappings = _factionMappings + (format ["[%1,""GroupFactionName"", %2] call ALiVE_fnc_hashSet;", _factionMappingsVar, str _groupCategoriesRootName]) + _newLine;
                _factionMappings = _factionMappings + (format ["[%1,""GroupFactionTypes"", %2] call ALiVE_fnc_hashSet;", _factionMappingsVar, _typeMappingsVar]) + _newLine;
                _factionMappings = _factionMappings + (format ["[%1,""Groups"", %2] call ALiVE_fnc_hashSet;", _factionMappingsVar, _factionCustomGroupsVar]) + _newLine;

                _result = "";
                _result = _result + _typeMappings + _newLine + _factionCustomGroups + _newLine + _factionMappings + _newLine;
                _result = _result + (format ["[ALiVE_factionCustomMappings,%1, %2] call ALiVE_fnc_hashSet;", str _faction, _factionMappingsVar]) + _newLine;

                systemchat "Static data copied to clipboard";
                copyToClipboard _result;

            };

            case "Full": {

                _result = [_logic,"exportFaction", _faction] call MAINCLASS;
                _result = [_logic,"formatFullExportToComment", _result] call MAINCLASS;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

            case "FullWrite": {

                private _prefix = [_logic,"prefix"] call MAINCLASS;
                private _patches = [_logic,"exportConfig", "CfgPatches"] call MAINCLASS;
                private _classes = [_logic,"exportConfig", "Faction"] call MAINCLASS;
                private _groups = [_logic,"exportConfig", "GroupsAll"] call MAINCLASS;
                private _vehicles = [_logic,"exportConfig", "UnitsAll"] call MAINCLASS;

                _faction = [toLower(_faction),format["%1_",_prefix],""] call CBA_fnc_replace;

                _outputString = "exportConfig~" +  _faction + "|" + _patches + "|" + _classes + "|" + _groups + "|" + _vehicles + "|" + _prefix;

                _result = "ALiVEClient" callExtension _outputString;

                if (_result == "DONE") then {
                    systemchat "Config data copied written to file.";
                } else {
                    systemchat format["Config data file write failed due to %1",_result];
                };
            };

            case "FullWriteImages": {

                private _prefix = [_logic,"prefix"] call MAINCLASS;

                [_state, "editorPreviews", true] call ALiVE_fnc_hashSet;

                private _patches = [_logic,"exportConfig", "CfgPatches"] call MAINCLASS;
                private _classes = [_logic,"exportConfig", "Faction"] call MAINCLASS;
                private _groups = [_logic,"exportConfig", "GroupsAll"] call MAINCLASS;
                private _vehicles = [_logic,"exportConfig", "UnitsAll"] call MAINCLASS;
                private _factionUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;

                [_state, "editorPreviews", false] call ALiVE_fnc_hashSet;

                _faction = [toLower(_faction),format["%1_",_prefix],""] call CBA_fnc_replace;

                _outputString = "exportConfig~" +  _faction + "|" + _patches + "|" + _classes + "|" + _groups + "|" + _vehicles + "|" + _prefix;

                _result = "ALiVEClient" callExtension _outputString;

                if (_result == "DONE") then {
                    systemchat "Config data copied written to file. Configs include references to Editor Preview images.";
                } else {
                    systemchat format["Config data file write failed due to %1",_result];
                };

                // Create Images
                private _images = [_logic, "exportConfig", "Images"] call MAINCLASS;

            };

            case "CfgPatches": {

                _result = "";
                private _indent = "    ";
                private _newLine = toString [13,10];

                private _state = [_logic,"state"] call MAINCLASS;
                private _faction = [_state,"selectedFaction"] call ALiVE_fnc_hashGet;
                private _factionUnits = [_logic,"getCustomUnitsByFaction", _faction] call MAINCLASS;

                // get unit classnames

                private _unitClassnames = [];
                private _unitClassnamesString = "";

                {
                    _unitClassnames pushback ([_x,"configName"] call ALiVE_fnc_hashGet);
                } foreach _factionUnits;

                // convert to vertical string

                {
                    _unitClassnamesString = _unitClassnamesString + _indent + _indent + _indent;

                    _unitClassnamesString = _unitClassnamesString + str _x;

                    if (_forEachIndex != (count _unitClassnames) - 1) then {
                        _unitClassnamesString = _unitClassnamesString + ",";
                    };

                    _unitClassnamesString = _unitClassnamesString + _newLine;
                } foreach _unitClassnames;

                // get required addons

                private _requiredAddons = [];
                private _requiredAddonsString = "";
                private _cfgVehicles = configFile >> "CfgVehicles";

                {
                    private _unitClass = [_x,"configName"] call ALiVE_fnc_hashGet;
                    private _realUnitClass = [_logic,"getRealUnitClass", _unitClass] call MAINCLASS;
                    private _parentChain = [configFile >> "CfgVehicles" >> _realUnitClass, false] call BIS_fnc_returnParents;

                    {
                        private _requiredAddonList = configSourceAddonList _x;

                        {
                            _requiredAddons pushbackunique _x;
                        } foreach _requiredAddonList;
                    } foreach _parentChain;
                } foreach _factionUnits;

                _requiredAddons deleteAt (_requiredAddons find _faction);

                // convert to vertical string

                {
                    _requiredAddonsString = _requiredAddonsString + _indent + _indent + _indent;

                    _requiredAddonsString = _requiredAddonsString + str _x;

                    if (_forEachIndex != (count _requiredAddons) - 1) then {
                        _requiredAddonsString = _requiredAddonsString + ",";
                    };

                    _requiredAddonsString = _requiredAddonsString + _newLine;
                } foreach _requiredAddons;

                _result = _result + "class CfgPatches {" + _newLine;

                _result = _result + _indent + "class " + _faction + " {" + _newLine;
                _result = _result + _indent + _indent + "units[] = {" + _newLine + _unitClassnamesString + _indent + _indent + "};" + _newLine;
                _result = _result + _indent + _indent + "weapons[] = {};" + _newLine;
                _result = _result + _indent + _indent + "requiredVersion = 1.62;" + _newLine;
                _result = _result + _indent + _indent + "requiredAddons[] = {" + _newLine + _requiredAddonsString + _indent + _indent + "};" + _newLine;
                _result = _result + _indent + _indent + "author = " + str profileName + ";" + _newLine;
                _result = _result + _indent + _indent + "authors[] = " + ([_logic,"arrayToConfigArrayString", [profileName]] call MAINCLASS) + ";" + _newLine;
                _result = _result + _indent + "};" + _newLine;

                _result = _result + "};" + _newLine;

                systemchat "Config data copied to clipboard";
                copyToClipboard _result;

            };

        };

    };

    // CfgVehicles

    case "exportCustomUnits": {

        private _unitclasses = _args;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;
        private _forwardDeclared = [];

        _result = "";
        private _indent = "    ";
        private _newLine = toString [13,10];

        _result = _result + _newLine + "class CBA_Extended_EventHandlers_base;" + _newLine;
        _result = _result + _newLine + "class CfgVehicles {" + _newLine;

        // reorder units to maintain timely definitions

        private _unitsToExport = [];
        private _unitsToForwardDeclare = [];

        private _gatherRequiredUnitsToExport = {
            private _unitConfigName = _this;
            private _unit = [_customUnits,_unitConfigName] call ALiVE_fnc_hashGet;
            private _unitParentConfigName = [_unit,"inheritsFrom"] call ALiVE_fnc_hashGet;

            if !(_unitParentConfigName in _unitsToExport) then {
                private _parentUnit = [_customUnits,_unitParentConfigName] call ALiVE_fnc_hashGet;

                // if parent unit is also a custom unit
                // make sure we output it's parents as well
                if (!isnil "_parentUnit") then {
                    _unitParentConfigName call _gatherRequiredUnitsToExport;
                } else {
                    _unitsToForwardDeclare pushbackunique _unitParentConfigName;
                };
            };

            _unitsToExport pushbackunique _unitConfigName;
        };

        {
            _x call _gatherRequiredUnitsToExport;
        } foreach _unitClasses;

        // forward declare non-imported units

        private _cfgVehicles = configFile >> "CfgVehicles";

        _result = _result + _newLine;
        {
            private _unitConfigName = _x;
            private _unit = [_customUnits,_unitConfigName] call ALiVE_fnc_hashGet;

            if (isnil "_unit") then {
                // parent is in config and isn't imported
                // we need to forward declare it with imports

                private _importClass1 = _unitConfigName + "_OCimport_01";
                private _importClass2 = _unitConfigName + "_OCimport_02";

                private _realUnitClass = [_logic,"getRealUnitClass", _unitConfigName] call MAINCLASS;

                _result = _result + _indent + "class " + _unitConfigName + ";" + _newLine;

                if (_realUnitClass isKindOf "Man") then {
                    _result = _result + _indent + "class " + _importClass1 + " : " + _unitConfigName + " { scope = 0; class EventHandlers; };" + _newLine;
                    _result = _result + _indent + "class " + _importClass2 + " : " + _importClass1 + " { class EventHandlers; };" + _newLine;
                } else {
                    private _turretConfig = _cfgVehicles >> _realUnitClass >> "Turrets";
                    if (isClass _turretConfig) then {
                        private _unitTurretClasses = [];
                        for "_i" from 0 to (count _turretConfig - 1) do {
                            private _turretConfig = _turretConfig select _i;

                            if (isclass _turretConfig) then {
                                private _turretConfigName = configname _turretConfig;
                                _unitTurretClasses pushback _turretConfigName;
                            };
                        };

                        if (count _unitTurretClasses > 0) then {
                            _result = _result + _indent + "class " + _importClass1 + " : " + _unitConfigName + " { scope = 0; class EventHandlers; class Turrets; };" + _newLine;

                            _result = _result + _indent + "class " + _importClass2 + " : " + _importClass1 + " { " + _newLine;
                            _result = _result + _indent + _indent + "class EventHandlers; " + _newLine;
                            _result = _result + _indent + _indent +  "class Turrets : Turrets {" + _newLine;

                            {
                                _result = _result + _indent + _indent + _indent + "class " + _x + ";" + _newLine;
                            } foreach _unitTurretClasses;

                            _result = _result + _indent + _indent +  "};" + _newLine;
                            _result = _result + _indent + "};" + _newLine;
                        } else {
                            _result = _result + _indent + "class " + _importClass1 + " : " + _unitConfigName + " { scope = 0; class EventHandlers; };" + _newLine;
                            _result = _result + _indent + "class " + _importClass2 + " : " + _importClass1 + " { scope = 0; class EventHandlers; };" + _newLine;
                        };
                    };
                };

                _result = _result + _newLine;
                _unitsToForwardDeclare set [_foreachindex, _importClass2];
            };
        } foreach _unitsToForwardDeclare;

        _result = _result + _newLine;

        // export units

        {
            private _unitExportString = [_logic,"exportCustomUnit", _x] call MAINCLASS;
            _result = _result + _unitExportString + _newLine;
        } foreach _unitsToExport;

        _result = _result + "};";

    };

    case "exportCustomUnit": {

        private _unit = _args;
        private _prefix = [_logic,"prefix"] call MAINCLASS;
        private _state = [_logic,"state"] call MAINCLASS;
        private _factions = [_state,"factions"] call ALiVE_fnc_hashGet;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _editorPreviews = [_state,"editorPreviews",false] call ALiVE_fnc_hashGet;

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
        private _unitTexture = [_unit,"texture"] call ALiVE_fnc_hashGet;
        private _fillMissingAttributes = false;

        private _cfgVehicles = configFile >> "CfgVehicles";

        /*
        if (_unitParent == _unitConfigName) then {
            _unitParent = configname (inheritsFrom (_cfgVehicles >> _unitParent));
            _fillMissingAttributes = true;
        };
        */

        _result = _result + _indent + "class " + _unitConfigName;

        /*
        if (_unitParent != "") then {
            if (isClass (_cfgVehicles >> _unitParent)) then {
                _result = _result + " : " + _unitParent + "_OCimport_02";
            } else {
                _result = _result + " : " + _unitParent;
            };
        };
        */
        private _unitParentCustomUnit = [_customUnits,_unitParent] call ALiVE_fnc_hashGet;
        if (isnil "_unitParentCustomUnit") then {
            _result = _result + " : " + _unitParent + "_OCimport_02";
        } else {
            _result = _result + " : " + _unitParent;
        };

        _result = _result + " {";

        // general properties

        _result = _result + _newLine;

        if (_editorPreviews) then {
            private _mod = [toLower(_unitFaction),format["%1_",_prefix],""] call CBA_fnc_replace;
            private _previewFile = format["\x\%1\addons\%2\data\preview\%3.JPG",_prefix,_mod,_unitConfigName];
            _result = _result + _indent + _indent + ("editorPreview = " + _previewFile + ";") + _newLine;
        };

        _result = _result + _indent + _indent + ("author = " + str profileName + ";") + _newLine;
        _result = _result + _indent + _indent + ("scope = 2;") + _newLine;
        _result = _result + _indent + _indent + ("scopeCurator = 2;") + _newLine;
        _result = _result + _indent + _indent + ("displayName = " + str _unitDisplayName + ";") + _newLine;
        _result = _result + _indent + _indent + ("side = " + str _unitSide + ";") + _newLine;
        _result = _result + _indent + _indent + ("faction = " + str _unitFaction + ";"); // newline handled by type specific properties

        // get type-specific properties

        private _unitRealConfigName = [_logic,"getRealUnitClass", _unitConfigName] call MAINCLASS;
        if (_unitRealConfigName isKindOf "Man") then {
            private _unitExportString = [_logic,"exportCustomUnitMan", _unit] call MAINCLASS;
            _result = _result + _newLine + _newLine + _unitExportString;
        } else {
            private _unitExportString = [_logic,"exportCustomUnitVehicle", _unit] call MAINCLASS;
            _result = _result + _unitExportString;
        };

        // if unit is overwriting a config unit
        // find all properties it must fill to be complete

        if (_fillMissingAttributes) then {
            private _cfgVehicles = configFile >> "CfgVehicles";

            private _baseClass = _cfgVehicles >> _unitConfigName;
            private _parentClass = _cfgVehicles >> _unitParent;
            private _attributesToFill = [_baseClass,_parentClass] call ALiVE_fnc_configGetDifferences;

            _result = _result + _newLine;
            _result = _result + _indent + _indent + "// Autofilled values" + _newLine;

            // hard coded blacklist to prevent re-defining attributes defined during exportation
            // this (along with exportation in general) could probably be done in a more automated way
            // that takes effort though so this'll do for now

            private _attributeBlacklist = [
                "author","scope","scopecurator","displayname","side","faction","uniformclass","backpack",
                "items","linkeditems","magazines","weapons","respawnitems","respawnlinkeditems",
                "respawnmagazines","respawnweapons","eventhandlers","crew","cba_extended_hventHandlers",
                "alive_orbatcreator_owned","alive_orbatcreator_texture","Turrets","alive_orbatcreator_insignia"
            ];

            {
                _x params ["_attribute","_value"];

                if !((toLower _attribute) in _attributeBlacklist) then {
                    _attributeString = [_logic,"getAttributeExportString", [2,_attribute,_value]] call MAINCLASS;
                    _result = _result + _attributeString;
                };
            } foreach _attributesToFill;
        };

        // custom attributes

        private _identityTypes = [_unit,"identityTypes"] call ALiVE_fnc_hashGet;
        private _identityInsignia = [_identityTypes,"insignia"] call ALiVE_fnc_hashGet;

        _result = _result + _newLine;
        _result = _result + _indent + _indent + "// custom attributes (do not delete)" + _newLine;
        _result = _result + _indent + _indent + "ALiVE_orbatCreator_owned = 1;" + _newLine;

        if (_identityInsignia != "") then {
            _result = _result + _indent + _indent + "ALiVE_orbatCreator_insignia = " + str _identityInsignia + ";" + _newLine;
        };

        if (_unitTexture != "") then {
            _result = _result + _indent + _indent + "ALiVE_orbatCreator_texture = " + str _unitTexture + ";" + _newLine;
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

        private _identityTypes = [_unit,"identityTypes"] call ALiVE_fnc_hashGet;
        private _identityFace = [_identityTypes,"face"] call ALiVE_fnc_hashGet;
        private _identityVoice = [_identityTypes,"voice"] call ALiVE_fnc_hashGet;
        private _identityMisc = [_identityTypes,"misc"] call ALiVE_fnc_hashGet;

        private _identityInsignia = [_identityTypes,"insignia"] call ALiVE_fnc_hashGet;

        // format result

        private _newLine = toString [13,10];
        private _indent = "    ";
        private _eventHandlers = [] call ALiVE_fnc_hashCreate;
        _result = "";

        // prepare string versions of data

        private _identityTypesString = [_logic,"arrayToConfigArrayString", [_identityFace,_identityVoice] + _identityMisc - [""]] call MAINCLASS;
        private _loadoutStringArray = [_logic,"arrayToConfigArrayString", _unitLoadout] call MAINCLASS;

        private _loadoutString = [str _unitLoadout,"""","'"] call CBA_fnc_replace;

        private _initEventHandler = [_eventHandlers,"init",""] call ALiVE_fnc_hashGet;
        _initEventHandler = _initEventHandler + "if (local (_this select 0)) then {";
        _initEventHandler = _initEventHandler + "_onSpawn = {_this = _this select 0;";
        _initEventHandler = _initEventHandler + "sleep 0.2; _backpack = gettext(configfile >> 'cfgvehicles' >> (typeof _this) >> 'backpack'); waituntil {sleep 0.2; backpack _this == _backpack};";
        _initEventHandler = _initEventHandler + "if !(_this getVariable ['ALiVE_OverrideLoadout',false]) then {_loadout = getArray(configFile >> 'CfgVehicles' >> (typeOf _this) >> 'ALiVE_orbatCreator_loadout'); _this setunitloadout _loadout;";

        // insignia can only be added via SQF (after loadout has been applied)
        if (_identityInsignia != "") then {
            _initEventHandler = _initEventHandler + format["[_this, '%1'] call BIS_fnc_setUnitInsignia;",_identityInsignia];
        };

        _initEventHandler = _initEventHandler + "reload _this";

        _initEventHandler = _initEventHandler + "};};"; // _onSpawn close
        _initEventHandler = _initEventHandler + "_this spawn _onSpawn;";
        _initEventHandler = _initEventHandler + "(_this select 0) addMPEventHandler ['MPRespawn', _onSpawn];";
        _initEventHandler = _initEventHandler + "};"; // if (local _unit) close

        [_eventHandlers,"init", _initEventHandler] call ALiVE_fnc_hashSet;

        // apply identity
        _result = _result + _indent + _indent + "identityTypes[] = " + _identityTypesString + ";" + _newLine;
        _result = _result + _newLine;

        // Add uniform to prevent any conflicting side uniform RPT spam
        private _uniform = (_unitLoadout select 3) select 0;
        if (isnil "_uniform") then { _uniform = "" };
        _result = _result + _indent + _indent + "uniformClass = " + str _uniform + ";" + _newLine;
        _result = _result + _newLine;

        // Add helmet, vest and items
        private _vest = if (count (_unitLoadout select 4) > 0) then {(_unitLoadout select 4) select 0} else {""};
        private _linkedItems = [_vest, (_unitLoadout select 6)] + (_unitLoadout select 9) - [""];
        private _linkedItemsStringArray = [_logic,"arrayToConfigArrayString", _linkedItems] call MAINCLASS;
        _result = _result + _indent + _indent + "linkedItems[] = " + _linkedItemsStringArray + ";" + _newLine;
        _result = _result + _indent + _indent + "respawnlinkedItems[] = " + _linkedItemsStringArray + ";" + _newLine;
        _result = _result + _newLine;

        // Add weapons
        private _primary = if (count (_unitLoadout select 0) > 0) then {(_unitLoadout select 0) select 0} else {""};
        private _secondary = if (count (_unitLoadout select 1) > 0) then {(_unitLoadout select 1) select 0} else {""};
        private _handgun = if (count (_unitLoadout select 2) > 0) then {(_unitLoadout select 2) select 0} else {""};
        private _bino = if (count (_unitLoadout select 8) > 0) then {(_unitLoadout select 8) select 0} else {""};
        private _weapons = [_primary, _secondary, _Handgun, _bino] - [""];
        private _weaponsItemsStringArray = [_logic,"arrayToConfigArrayString", _weapons] call MAINCLASS;
        _result = _result + _indent + _indent + "weapons[] = " + _weaponsItemsStringArray + ";" + _newLine;
        _result = _result + _indent + _indent + "respawnWeapons[] = " + _weaponsItemsStringArray + ";" + _newLine;
        _result = _result + _newLine;

        // Add magazines
        private _primarymag = if (count (_unitLoadout select 0) > 0) then {(_unitLoadout select 0) select 4 select 0} else {""};
        private _primarysecmag = if (count (_unitLoadout select 0) > 0) then {(_unitLoadout select 0) select 5 select 0} else {""};
        private _secondarymag = if (count (_unitLoadout select 1) > 0) then {(_unitLoadout select 1) select 4 select 0} else {""};
        private _handgunmag = if (count (_unitLoadout select 2) > 0) then {(_unitLoadout select 2) select 4 select 0} else {""};
        private _binomag = if (count (_unitLoadout select 8) > 0) then {(_unitLoadout select 8) select 4 select 0} else {""};
        private _mags = [_primarymag, _primarysecmag, _secondarymag, _handgunmag, _binomag, _primarymag, _primarysecmag, _handgunmag, _binomag] - [""];
        private _magsItemsStringArray = [_logic,"arrayToConfigArrayString", _mags] call MAINCLASS;
        _result = _result + _indent + _indent + "magazines[] = " + _magsItemsStringArray + ";" + _newLine;
        _result = _result + _indent + _indent + "respawnMagazines[] = " + _magsItemsStringArray + ";" + _newLine;
        _result = _result + _newLine;

        // Add backpack
        private _backpack = if (count (_unitLoadout select 5) > 0) then {(_unitLoadout select 5) select 0} else {""};
        if (_backpack != "") then {
            _result = _result + _indent + _indent + "backpack = " + str _backpack + ";" + _newLine;
            _result = _result + _newLine;
        };

        // Store their loadout
        _result = _result + _indent + _indent + "ALiVE_orbatCreator_loadout[] = " + _loadoutStringArray + ";" + _newLine;
        _result = _result + _newLine;

        // event handlers
        _result = _result + _newLine + _indent + _indent + "class EventHandlers : EventHandlers {";
        _result = _result + _newLine + _indent + _indent + _indent + "class CBA_Extended_EventHandlers : CBA_Extended_EventHandlers_base {};" + _newLine;
        _result = _result + _newLine;
        _result = _result + _indent + _indent + _indent + "class ALiVE_orbatCreator {";

        private _eventHandlerTypes = _eventHandlers select 1;
        private _eventHandlerStrings = _eventHandlers select 2;

        for "_i" from 0 to (count _eventHandlerTypes - 1) do {
            _eventHandlerType = _eventHandlerTypes select _i;
            _eventHandlerStatements = _eventHandlerStrings select _i;

            _EHString = _eventHandlerType + " = " + """" + _eventHandlerStatements + """" + ";";

            _result = _result + _newLine + _indent + _indent + _indent + _indent + _EHString;
        };
        _result = _result + _newLine + _indent + _indent + _indent + "};" + _newLine;
        _result = _result + _newLine + _indent + _indent + "};" + _newLine;

        [_logic,"deleteUnit", _tmpUnit] call MAINCLASS;
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
        private _unitFaction = [_unit,"faction"] call ALiVE_fnc_hashGet;
        private _unitSide = [_unit,"side"] call ALiVE_fnc_hashGet;
        private _unitCrew = [_unit,"crew"] call ALiVE_fnc_hashGet;
        private _unitTurrets = [_unit,"turrets"] call ALiVE_fnc_hashGet;
        private _unitTexture = [_unit,"texture"] call ALiVE_fnc_hashGet;

        // format result

        private _newLine = toString [13,10];
        private _indent = "    ";
        private _eventHandlers = [] call ALiVE_fnc_hashCreate;
        _result = "";

        private _initEventHandler = "if (local (_this select 0)) then {";
        _initEventHandler = _initEventHandler + "_onSpawn = {sleep 0.3; _unit = _this select 0;";

        private _realVehicle = [_logic,"getRealUnitClass", _unitConfigName] call MAINCLASS;
        private _unitTextureArray = [_logic,"getVehicleTextureArray", [_realVehicle,_unitTexture]] call MAINCLASS;

        if (count _unitTextureArray > 0) then {
            {
                _initEventHandler = _initEventHandler + "_unit setObjectTextureGlobal " + (format ["[%1,'%2']",_forEachIndex,_x]) + ";";
            } foreach _unitTextureArray;
            [_eventHandlers,"init", _initEventHandler] call ALiVE_fnc_hashSet;
        };

        _result = _result + _newLine;
        _result = _result + _indent + _indent + "crew = " + str _unitCrew + ";" + _newLine;

        private _unitTurretValues = _unitTurrets select 2;

        if (count _unitTurretValues > 0) then {
            _result = _result + _newLine;
            _result = _result + _indent + _indent + "class Turrets : Turrets {" + _newLine;

            {
                _x params ["_turretConfigName","_turretDisplayName","_turretGunnerType"];

                _result = _result + _indent + _indent + _indent + "class " + _turretConfigName + " : " + _turretConfigName + " { " + "gunnerType = " + (format ["""%1""; ", _turretGunnerType]) + "};" + _newLine;
            } foreach _unitTurretValues;

            _result = _result + _indent + _indent + "};" + _newLine;
            _result = _result + _newLine;
        };

        _initEventHandler = _initEventHandler + "};"; // _onSpawn close
        _initEventHandler = _initEventHandler + "_this spawn _onSpawn;";
        _initEventHandler = _initEventHandler + "(_this select 0) addMPEventHandler ['MPRespawn', _onSpawn];";

        _initEventHandler = _initEventHandler + "};"; // if (local (_this select 0)) close
        [_eventHandlers,"init", _initEventHandler] call ALiVE_fnc_hashSet;

        // event handlers

        _result = _result + _newLine + _newLine + _indent + _indent + "class EventHandlers : EventHandlers {";
        _result = _result + _newLine + _indent + _indent + _indent + "class CBA_Extended_EventHandlers : CBA_Extended_EventHandlers_base {};" + _newLine;
        _result = _result + _newLine;
        _result = _result + _indent + _indent + _indent + "class ALiVE_orbatCreator {";

        private _eventHandlerTypes = _eventHandlers select 1;
        private _eventHandlerStrings = _eventHandlers select 2;

        for "_i" from 0 to (count _eventHandlerTypes - 1) do {
            private _eventHandlerType = _eventHandlerTypes select _i;
            private _eventHandlerStatements = _eventHandlerStrings select _i;

            private _EHString = _eventHandlerType + " = " + """" + _eventHandlerStatements + """" + ";";

            _result = _result + _newLine + _indent + _indent + _indent + _indent + _EHString;
        };
        _result = _result + _newLine + _indent + _indent + _indent + "};" + _newLine;
        _result = _result + _newLine + _indent + _indent + "};" + _newLine;

    };

    // Export faction crates
    case "exportFactionCrates": {
        // Creates a number crates based on the weapons and ammo used in the faction

        private _faction = _args select 0;
        private _unitclasses = _args select 1;

        private _state = [_logic,"state"] call MAINCLASS;
        private _customUnits = [_state,"customUnits"] call ALiVE_fnc_hashGet;

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionConfigName = [_factionData,"configName"] call ALiVE_fnc_hashGet;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;

        _result = "";
        private _indent = "    ";
        private _newLine = toString [13,10];

        private _weaponList = []; // rifles and handguns
        private _weaponAmmoList = []; // rifles and handgun ammo
        private _weaponItemsList = []; // attachments
        private _ammoList = []; // all ammo
        private _launcherList = []; // launchers
        private _launcherAmmoList = []; // launchers ammo
        private _launcherItemsList = []; // launcher items
        private _itemList = []; // items, helmets, vests, backpacks, goggles etc
        private _uniformList = []; // uniforms

        private _factionCrates = [];

        // Go through each unit in the faction and get items
        {
            private _unitclass = _x;
            if (([_logic,"getRealUnitClass", _unitclass] call MAINCLASS) iskindof "Man") then {

                private _unit = [_logic,"displayVehicle",_unitclass] call MAINCLASS;

                sleep 1;

                // diag_log format["%1 : %2", _unitclass, weapons _unit];

                _weaponList pushBackUnique (primaryWeapon _unit);
                {
                    _weaponAmmoList pushBackUnique _x;
                } foreach (primaryWeaponMagazine _unit);

                _weaponList pushBackUnique (handgunweapon _unit);

                {
                    _weaponAmmoList pushBackUnique _x;
                } foreach (handgunMagazine _unit);

                {
                    _weaponItemsList pushBackUnique _x;
                } foreach (primaryWeaponItems _unit);

                {
                    _weaponItemsList pushBackUnique _x;
                } foreach (handgunItems _unit);

                _launcherList pushBackUnique (secondaryWeapon _unit);

                {
                    _launcherAmmoList pushBackUnique _x;
                } foreach (secondaryWeaponMagazine _unit);

                {
                    _launcherItemsList pushBackUnique _x;
                } foreach (secondaryWeaponItems _unit);

                _itemList pushBackUnique (binocular _unit);
                _itemList pushBackUnique (vest _unit);
                _itemList pushBackUnique (headgear _unit);
                _itemList pushBackUnique (goggles _unit);
                _itemList pushBackUnique (backpack _unit);
                _itemList pushBackUnique (hmd _unit);
                _uniformList pushBackUnique (uniform _unit);

                {
                    _itemList pushBackUnique _x;
                } foreach (assignedItems _unit);

                {
                    _ammoList pushBackUnique _x;
                } foreach (magazines _unit);

                deleteVehicle _unit;
            };

        } foreach _unitclasses;

        // remove empties from arrays
        _weaponList = _weaponList - [""];
        _weaponAmmoList = _weaponAmmoList - [""];
        _weaponItemsList = _weaponItemsList - [""];
        _uniformList = _uniformList - [""];
        _launcherList = _launcherList - [""];
        _launcherAmmoList = _launcherAmmoList - [""];
        _launcherItemsList = _launcherItemsList - [""];
        _ammoList = _ammoList - [""];
        _itemList = _itemList - [""];

        // Start text
        _result = _result + "// Copy this part to your config.cpp" + _newline;
        _result = _result + "#define mag_xx(a,b) class _xx_##a {magazine = ##a; count = b;}" + _newline;
        _result = _result + "#define weap_xx(a,b) class _xx_##a {weapon = ##a; count = b;}" + _newline;
        _result = _result + "#define item_xx(a,b) class _xx_##a {name = a; count = b;}" + _newline;
        _result = _result + _newline;
        _result = _result + "// Copy this part to your CfgVehicles config. Switch the Arma 3 vanilla boxes for CUP ones if necessary (replace all instances)." + _newline;
        _result = _result + _indent;

        _result = _result + "class Box_East_Ammo_F; // CUP_RUBasicAmmunitionBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_NATO_Ammo_F; // CUP_USBasicAmmunitionBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_East_Wps_F; // CUP_RUBasicWeaponsBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_NATO_Wps_F; // CUP_USBasicWeaponsBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_East_Support_F; // CUP_RUSpecialWeaponsBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_NATO_Support_F; // CUP_USSpecialWeaponsBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_East_WpsLaunch_F; // CUP_RULaunchersBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_NATO_WpsLaunch_F; // CUP_USLaunchersBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_East_Uniforms_F; // CUP_RUBasicWeaponsBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class Box_NATO_Uniforms_F; // CUP_USBasicWeaponsBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class O_SupplyCrate_F; // CUP_RUVehicleBox" + _newline;
        _result = _result + _indent;
        _result = _result + "class B_SupplyCrate_F; // CUP_USVehicleBox" + _newline;
        _result = _result + _newline;

        // Create an ammo box
            // ammo + grenades
            private _boxName = format["%1_AmmoBox",_factionConfigName];
            _factionCrates pushback _boxName;
            private _boxParent = if (_factionSide == 0) then {"Box_East_Ammo_F"} else {"Box_NATO_Ammo_F"};
            _result = _result + _indent;
            _result = _result + "class " + _boxName + " : " + _boxParent + " {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "author = ALiVE ORBAT CREATOR;" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + format["displayName = %1 Ammo Box;", _factionDisplayName] + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportMagazines {" + _newline;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["mag_xx(%1,%2);",_x, 50] + _newline;
            } foreach _ammoList;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportWeapons {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportItems {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent;
            _result = _result + "};" + _newline;

        // Create a basic weapons box
            // For each rifle and handgun and ammo
            private _boxName = format["%1_WeaponsBox",_factionConfigName];
            _factionCrates pushback _boxName;
            private _boxParent = if (_factionSide == 0) then {"Box_East_Wps_F"} else {"Box_NATO_Wps_F"};
            _result = _result + _indent;
            _result = _result + "class " + _boxName + " : " + _boxParent + " {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "author = ALiVE ORBAT CREATOR;" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + format["displayName = %1 Weapons Box;", _factionDisplayName] + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportMagazines {" + _newline;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["mag_xx(%1,%2);",_x, 50] + _newline;
            } foreach _weaponAmmoList;

            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;
            _result = _result + _indent + _indent;

            _result = _result + "class TransportWeapons {" + _newline;

            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["weap_xx(%1,%2);",_x, 10] + _newline;
            } foreach _weaponList;

            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;
            _result = _result + _indent + _indent;

            _result = _result + "class TransportItems {" + _newline;

            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 10] + _newline;
            } foreach _weaponItemsList;

            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;
            _result = _result + _indent;

            _result = _result + "};" + _newline;

        // Create a launchers weapons box
            // For each launcher, ammo
            private _boxName = format["%1_LaunchersBox",_factionConfigName];
            _factionCrates pushback _boxName;
            private _boxParent = if (_factionSide == 0) then {"Box_East_WpsLaunch_F"} else {"Box_NATO_WpsLaunch_F"};
            _result = _result + _indent;
            _result = _result + "class " + _boxName + " : " + _boxParent + " {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "author = ALiVE ORBAT CREATOR;" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + format["displayName = %1 Launchers Box;", _factionDisplayName] + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "class TransportMagazines {" + _newline;

            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["mag_xx(%1,%2);",_x, 5] + _newline;
            } foreach _launcherAmmoList;

            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;
            _result = _result + _indent + _indent;

            _result = _result + "class TransportWeapons {" + _newline;

            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["weap_xx(%1,%2);",_x, 5] + _newline;
            } foreach _launcherList;

            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;
            _result = _result + _indent + _indent;

            _result = _result + "class TransportItems {" + _newline;

            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 5] + _newline;
            } foreach _launcherItemsList;

            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;
            _result = _result + _indent;

            _result = _result + "};" + _newline;

        // Create a uniform box
            // For each uniform
            private _boxName = format["%1_UniformBox",_factionConfigName];
            _factionCrates pushback _boxName;
            private _boxParent = if (_factionSide == 0) then {"Box_East_Uniforms_F"} else {"Box_NATO_Uniforms_F"};
            _result = _result + _indent;
            _result = _result + "class " + _boxName + " : " + _boxParent + " {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "author = ALiVE ORBAT CREATOR;" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + format["displayName = %1 Uniform Box;", _factionDisplayName] + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportWeapons {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportMagazines {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportItems {" + _newline;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 15] + _newline;
            } foreach _uniformList;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;


            _result = _result + _indent;
            _result = _result + "};" + _newline;

        // Create a support box
            // For each item, backpack
            private _boxName = format["%1_SupportBox",_factionConfigName];
            _factionCrates pushback _boxName;
            private _boxParent = if (_factionSide == 0) then {"Box_East_Support_F"} else {"Box_NATO_Support_F"};
            _result = _result + _indent;
            _result = _result + "class " + _boxName + " : " + _boxParent + " {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "author = ALiVE ORBAT CREATOR;" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + format["displayName = %1 Support Box;", _factionDisplayName] + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportWeapons {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportMagazines {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportItems {" + _newline;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 10] + _newline;
            } foreach _itemList;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent;
            _result = _result + "};" + _newline;

        // Supply Box
            // Everything?
            private _boxName = format["%1_SupplyBox",_factionConfigName];
            _factionCrates pushback _boxName;
            private _boxParent = if (_factionSide == 0) then {"O_SupplyCrate_F"} else {"B_SupplyCrate_F"};
            _result = _result + _indent;
            _result = _result + "class " + _boxName + " : " + _boxParent + " {" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + "author = ALiVE ORBAT CREATOR;" + _newline;
            _result = _result + _indent + _indent;
            _result = _result + format["displayName = %1 Supply Box;", _factionDisplayName] + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportMagazines {" + _newline;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["mag_xx(%1,%2);",_x, 50] + _newline;
            } foreach _ammoList;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportWeapons {" + _newline;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["weap_xx(%1,%2);",_x, 10] + _newline;
            } foreach _weaponList;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["weap_xx(%1,%2);",_x, 10] + _newline;
            } foreach _launcherList;
            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;

            _result = _result + _indent + _indent;
            _result = _result + "class TransportItems {" + _newline;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 10] + _newline;
            } foreach _weaponItemsList;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 10] + _newline;
            } foreach _itemList;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 10] + _newline;
            } foreach _uniformList;
            {
                _result = _result + _indent + _indent + _indent;
                _result = _result + format["item_xx(%1,%2);",_x, 5] + _newline;
            } foreach _launcherItemsList;

            _result = _result + _indent + _indent;
            _result = _result + "};" + _newline;
            _result = _result + _indent;
            _result = _result + "};" + _newline;

        // Create the ALiVE logistics data
        _result = _result + _newline;
        _result = _result + "// Copy this part to ALiVE logistics static data" + _newline;
        _result = _result + format["[ALIVE_factionDefaultSupplies, %1, %2] call ALIVE_fnc_hashSet;", str(_factionConfigName), _factionCrates];

    };
    // CfgGroups

    case "formatGroupCategoriesToFaction": {

        _args params ["_faction","_groupCategoryString"];

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
        private _sideText = [_factionSide] call ALiVE_fnc_sideNumberToText;

        switch (_sideText) do {
            case "GUER": {
                _sideText = "Indep";
            };
            case "CIV": {
                _sideText = "Civilian";
            };
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

    case "getFactionClassExportString": {

        private _faction = _args;

        private _newLine = toString [13,10];
        private _indent = "    ";
        _result = "";

        private _factionData = [_logic,"getFactionData", _faction] call MAINCLASS;
        private _factionConfigName = [_factionData,"configName"] call ALiVE_fnc_hashGet;
        private _factionDisplayName = [_factionData,"displayName"] call ALiVE_fnc_hashGet;
        private _factionSide = [_factionData,"side"] call ALiVE_fnc_hashGet;
        private _factionFlag = [_factionData,"flag"] call ALiVE_fnc_hashGet;
        private _factionIcon = [_factionData,"icon"] call ALiVE_fnc_hashGet;
        private _factionPriority = [_factionData,"priority"] call ALiVE_fnc_hashGet;

        private _factionClassString = "";
        _factionClassString = _factionClassString + "class CfgFactionClasses {" + _newLine;
        _factionClassString = _factionClassString + _indent + "class " + _factionConfigName + " {" + _newLine;
        _factionClassString = _factionClassString + _indent + _indent + "displayName = " + str _factionDisplayName + ";" + _newLine;
        _factionClassString = _factionClassString + _indent + _indent + "side = " + str _factionSide + ";" + _newLine;
        _factionClassString = _factionClassString + _indent + _indent + "flag = " + str _factionFlag + ";" + _newLine;
        _factionClassString = _factionClassString + _indent + _indent + "icon = " + str _factionIcon + ";" + _newLine;
        _factionClassString = _factionClassString + _indent + _indent + "priority = " + str _factionPriority + ";" + _newLine;
        _factionClassString = _factionClassString + _indent + "};" + _newLine;
        _factionClassString = _factionClassString + "};";

        _result = _result + _factionClassString;

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

        private _CFGFactionClassesString = [_logic,"getFactionClassExportString", _faction] call MAINCLASS;
        _result = _result + _CFGFactionClassesString;

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

        if (_array isEqualType []) then {
             _result = "{";
            {
                if (_x isEqualType []) then {
                    _result = _result + ([_logic,"arrayToConfigArrayString", _x] call MAINCLASS) + ",";
                } else {
                    _result = _result + str _x + ",";
                };
            } foreach _array;
            _result = [_result, 0, (count _result) - 1] call CBA_fnc_substr;
            _result = _result + "}";
        };

    };

    case "getAttributeExportString": {

        _args params ["_level","_attribute","_value"];

        private _newLine = toString [13,10];
        private _indent = "    ";

        private _indentOuter = "";
        for "_i" from 1 to _level do {_indentOuter = _indentOuter + _indent};

        private _indentInner = _indentOuter + _indent;
        _result = "";

        if ([_value] call CBA_fnc_isHash) then {
            private _subAttributes = _value select 1;
            private _subValues = _value select 2;

            _result = _result + _newLine;
            _result = _result + _indentOuter + "class " + _attribute + " {" + _newLine;

            for "_i" from 0 to (count _subAttributes - 1) do {
                _subAttribute = _subAttributes select _i;
                _subValue = _subValues select _i;

                _attributeString = [_logic,"getAttributeExportString", [_level + 1,_subAttribute,_subValue]] call MAINCLASS;
                _result = _result + _indentOuter + _attributeString;
            };

            _result = _result + _newLine + _indentOuter + "};" + _newLine;
        } else {
            if (_value isEqualType []) then {
                private _valueString = [_logic,"arrayToConfigArrayString", _value] call MAINCLASS;
                _result = _result + _indentOuter + _attribute + "[]" + " = " + _valueString + ";" + _newLine;
            } else {
                _result = _result + _indentOuter + _attribute + " = " + str _value + ";" + _newLine;
            };
        };

    };

    case "getClassHashDataString": {

        _args params ["_class","_classParent","_classProperties",["_level",0]];

        private _newLine = toString [13,10];
        private _indent = "    ";
        private _classString = "";

        _classString = _classString + _class;

        if (_classParent != "") then {
            _classString = _classString + " : " + _classParent;
        };

        _classString = _classString + " {" + _newLine;

    };

    case "formatFullExportToComment": {

        private _output = _args;

        private _productVersion = productVersion;
        _productVersion params ["_productName","_productNameShort","_productVersion","_productBuild","_productBranch","_modsEnabled","_productPlatform"];

        private _outputPropertiesA3 = format [" Generated with %1 version %2.%3 on %4 branch", _productName, _productVersion, _productBuild, _productBranch];
        private _outputPropertiesALiVE = format [" Generated with ALiVE version %1", QUOTE(VERSION)];

        private _newLine = toString [13,10];
        private _indent = "    ";
        _result = "";

        private _comment = "";
        private _commentShort = "//";
        private _commentLong = "";
        for "_i" from 0 to 40 do {_commentLong = _commentLong + _commentShort};

        _comment = _comment + _commentLong + _newLine;
        _comment = _comment + _commentShort + " Config Automatically Generated by ALiVE ORBAT Creator" + _newLine;
        _comment = _comment + _commentShort + _outputPropertiesA3 + _newLine;
        _comment = _comment + _commentShort + _outputPropertiesALiVE + _newLine;
        _comment = _comment + _commentLong + _newLine;

        _result = _result + _comment;
        _result = _result + _newLine;
        _result = _result + _output;

    };

};

TRACE_1("Orbat Creator - output", _result);

if (!isnil "_result") then {_result} else {nil};
