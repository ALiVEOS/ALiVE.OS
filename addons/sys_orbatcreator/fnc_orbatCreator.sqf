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

#define OC_DISPLAY_ORBAT        8000
#define OC_DISPLAY_UNITEDITOR   9000

// interface elements

#define OC_ORBAT_FACTIONLIST        8008
#define OC_ORBAT_BUTTON_BIG_ONE     8005
#define OC_ORBAT_BUTTON_BIG_TWO     8006
#define OC_ORBAT_BUTTON_BIG_THREE   8007
#define OC_ORBAT_GROUPS_TREE        8009

#define OC_UNITEDITOR_BUTTON_BIG_ONE            9005
#define OC_UNITEDITOR_BUTTON_BIG_TWO            9006
#define OC_UNITEDITOR_BUTTON_BIG_THREE          9007
#define OC_UNITEDITOR_CLASSLIST_BUTTON_ONE      9009
#define OC_UNITEDITOR_CLASSLIST_BUTTON_TWO      9010
#define OC_UNITEDITOR_CLASSLIST_BUTTON_THREE    9011
#define OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR     9012
#define OC_UNITEDITOR_CLASSLIST_LIST_UNITS      9008

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

        // only one init per instance is allowed

        if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS Orbat Creator - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

        // start init

        _logic setVariable ["initGlobal", false];

        _logic setVariable ["super", QUOTE(SUPERCLASS)];
        _logic setVariable ["class", QUOTE(MAINCLASS)];
        _logic setVariable ["moduleType", "ALIVE_ORBATCREATOR"];
        _logic setVariable ["startupComplete", false];

        // get module settings

        private _debug = call compile (_logic getVariable "debug");

        [_logic,"debug", _debug] call MAINCLASS;

        // data init

        // load static data

        if (isnil "ALiVE_STATIC_DATA_LOADED") then {
            _file = "\x\alive\addons\main\static\staticData.sqf";
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

        [_state,"unitEditor_background", objNull] call ALiVE_fnc_hashSet;

        private _customUnits = +_tmpHash;
        [_state,"customUnits", _customUnits] call ALiVE_fnc_hashSet;

        MOD(orbatCreator) = _logic;

        [_logic,"start"] spawn MAINCLASS;

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

    case "start": {

        waitUntil {time > 0 && {!isnull player} && {!isnil "ALiVE_STATIC_DATA_LOADED"}};

        [_logic,"openInterface", "ORBAT_Viewer"] spawn MAINCLASS;
        ["Preload"] call BIS_fnc_arsenal;

        // set module as startup complete

        _logic setVariable ["startupComplete", true];

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
            case "Group_Editor": {
                closeDialog 0;
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
                _display displayAddEventHandler ["onUnload", "['onUnload', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];

                // init faction list

                private _factionList = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_FACTIONLIST);
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

                _factionList ctrlAddEventHandler ["lbSelChanged","['onORBATFactionListChanged', _this] call ALiVE_fnc_orbatCreatorOnAction"];
                _factionList lbSetCurSel 0;

                // init buttons

                private _button1 = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_BUTTON_BIG_ONE);
                _button1 ctrlSetText "Unit Editor";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_BUTTON_BIG_TWO);
                _button2 ctrlSetText "Group Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl(OC_DISPLAY_ORBAT,OC_ORBAT_BUTTON_BIG_THREE);
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

            };

            case "Unit_Editor": {

                // init buttons

                private _button1 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_BUTTON_BIG_ONE);
                _button1 ctrlSetText "ORBAT Viewer";
                _button1 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'ORBAT_Viewer'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button1 ctrlShow true;

                private _button2 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_BUTTON_BIG_TWO);
                _button2 ctrlSetText "Group Editor";
                _button2 ctrlSetEventHandler ["MouseButtonDown","['openInterface', 'Group_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button2 ctrlShow true;

                private _button3 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_BUTTON_BIG_THREE);
                _button3 ctrlSetText "Generate Config";
                _button3 ctrlSetEventHandler ["MouseButtonDown","['generateConfig', 'Unit_Editor'] call ALiVE_fnc_orbatCreatorOnAction"];
                _button3 ctrlShow true;

                // init class list

                private _classList_button1 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_ONE);
                _classList_button1 ctrlSetText "New";
                _classList_button1 ctrlSetEventHandler ["MouseButtonDown","[] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button1 ctrlShow true;

                private _classList_button2 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_TWO);
                _classList_button2 ctrlSetText "Edit";
                _classList_button2 ctrlSetEventHandler ["MouseButtonDown","[] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button2 ctrlShow true;

                private _classList_button3 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_THREE);
                _classList_button3 ctrlSetText "Save";
                _classList_button3 ctrlSetEventHandler ["MouseButtonDown","[] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button3 ctrlShow true;

                private _classList_button4 = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_BUTTON_FOUR);
                _classList_button3 ctrlSetText "Delete";
                _classList_button3 ctrlSetEventHandler ["MouseButtonDown","[] call ALiVE_fnc_orbatCreatorOnAction"];
                _classList_button4 ctrlShow true;

                // init unit class list

                private _classList_tree = OC_getControl(OC_DISPLAY_UNITEDITOR,OC_UNITEDITOR_CLASSLIST_LIST_UNITS);
                _classList_tree ctrlShow true;

            };

            case "Group_Editor": {



            };

        };

    };

    case "onUnload": {

        private _interface = _args;

        switch (_interface) do {
            case "ORBAT_Viewer": {

            };
            case "Unit_Editor": {

            };
            case "Group_Editor": {

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

};

TRACE_1("Orbat Creator - output", _result);

if (!isnil "_result") then {_result} else {nil};